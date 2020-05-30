CREATE OR REPLACE FUNCTION f_provisiogar(
   pnsinies IN NUMBER,
   pcgarant IN NUMBER,
   pprovisio IN OUT NUMBER,
   pdata IN DATE,
   ptipo IN NUMBER DEFAULT 0)
   RETURN NUMBER AUTHID CURRENT_USER IS
/***********************************************************************
   F_PROVISIO: Cálculo de la provisión de una garantía de un siniestro.
   ALLIBSIN - Funciones de siniestros
   Modificacions: Afegim un parametre d'entrada que ens indiqui fins a quina data hem de realitzar els càlculs
   Modificacions: No tindrem en compte els recobros quan calculem la provisió.
   Modificacions: Es considera el tema de coaseguro.
   Modificaciones: Se crea un parametro ptipo para diferenciar entre reaseguro y provisiones. Para reaseguro se ha de ir con la moneda normal porque despues
   aplica las tasas. Para las provisiones hemos de ir con la moneda contable porque no aplica las tasas.

      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  -------  -------------------------------------
      1.0        XX/XX/XXXX   XXX     1. Creación de la función.
      2.0        22/04/2010   AVT     2. 14203: CEM800 - Se detectan pólizas migradas sin reaseguro
      3.0        20/09/2011   JGR     3. 19216: CRE - PPNC producte CVCapital. Patch: AXIS3055
      4.0        25/01/2012   JMP     4. 18423/104212: LCOL705 - Multimoneda
      5.0        15/03/2013   ASN     5. 0026108: LCOL_S010-SIN - LCOL Tipo de gasto en reservas
      6.0        05/08/2013   AVT     6. 0027847: LCOL_A004-Qtracker: 0008669: SE GENERO CIERRE DE AUT PARA PROVISIONES, REASEGUROS, XLS, PRESTAMOS, Y REMUNERCION LA CANAL Y NOGE
      7.0        04/07/2014   JTT     7. 0031294: Pasamos el parametro idres a f_tramita_reserva
      8.0        03/03/2015   KBR     8. 0035032: LAG8_895-0016940: Siniestro no cedido: Se obtienen los pagos en el caso que no esten en estado REMESADO/PAGADO
                                                                    para ser sumados a la reserva (MODULO NUEVO)
      9.0        27/04/2020   JLTS    9. IAXIS-13133: Se adidiona un nuevo ptipo para que no se haga el cobro dos (2) veces								    
***********************************************************************/
   xvaloracions   NUMBER;
   xpagaments     pagosini.isinret%TYPE;
   num_err        NUMBER;
   w_sseguro      sin_siniestro.sseguro%TYPE;
   w_ncuacoa      sin_siniestro.ncuacoa%TYPE;
   w_ctipcoa      seguros.ctipcoa%TYPE;
   w_ploccoa      coacuadro.ploccoa%TYPE;
   w_cpagcoa      pagosini.cpagcoa%TYPE;
   apl_coa_prov   BOOLEAN;
   apl_coa_pag    BOOLEAN;
   v_cempres      seguros.cempres%TYPE;
   vireserva      NUMBER;
   v_cmultimon    parempresas.nvalpar%TYPE;
   v_sproduc      seguros.sproduc%TYPE;
   v_cmonprod     monedas.cmonint%TYPE;
   v_fcambio      DATE;
   v_itasa        eco_tipocambio.itasa%TYPE;
BEGIN
   BEGIN
      BEGIN
         SELECT sseguro, ncuacoa
           INTO w_sseguro, w_ncuacoa
           FROM sin_siniestro
          WHERE nsinies = pnsinies;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            SELECT sseguro, ncuacoa
              INTO w_sseguro, w_ncuacoa
              FROM siniestros
             WHERE nsinies = pnsinies;
      END;
   END;

   SELECT cempres, sproduc
     INTO v_cempres, v_sproduc
     FROM seguros
    WHERE sseguro = w_sseguro;

   num_err := pac_llibsin.datos_coa_sin(w_sseguro, w_ncuacoa, w_ctipcoa, w_ploccoa);

   IF num_err <> 0 THEN
      RETURN(num_err);
   END IF;

   num_err := pac_llibsin.valida_aplica_coa(w_ctipcoa, pnsinies, w_cpagcoa, apl_coa_prov,
                                            apl_coa_pag);

   IF num_err <> 0 THEN
      RETURN(num_err);
   END IF;

   num_err := 100539;

   IF NVL(pac_parametros.f_parempresa_n(v_cempres, 'MODULO_SINI'), 0) = 0 THEN
      num_err := pac_sin.f_valoracio_sini(pnsinies, pcgarant, pdata, xvaloracions);
   ELSE
      xvaloracions := 0;
      v_cmultimon := NVL(pac_parametros.f_parempresa_n(v_cempres, 'MULTIMONEDA'), 0);
      v_cmonprod := pac_monedas.f_cmoneda_t(pac_monedas.f_moneda_producto(v_sproduc));
      --IAXIS 13057 AABC Quitar la reserva ULAE 
      FOR r1 IN (SELECT DISTINCT ntramit, ctipres, cmonres, ctipgas, idres   -- 31294
                            FROM sin_tramita_reserva v1
                           WHERE v1.nsinies = pnsinies
                             AND (v1.cgarant = pcgarant OR pcgarant IS NULL)
                             AND v1.ctipres <> 5) LOOP
         --IAXIS 13057 AABC Quitar la reserva ULAE
         --BUG40962-XVM. Inicio
	 -- IAXIS-13133 -27/04/2020. Se adiciona el ptipo igual a 2
         IF ptipo in (0,2) THEN
         --Viene de reaseguro, hemos de operar con la moneda normal
         num_err := pac_siniestros.f_tramita_reserva(pnsinies, r1.ntramit, r1.ctipres,
                                                     r1.ctipgas, pcgarant, r1.cmonres, pdata,
                                                     vireserva, r1.idres, 0,1);
        ELSE
        --Viene de provisiones, hemos de operar con la moneda contable.
         num_err := pac_siniestros.f_tramita_reserva(pnsinies, r1.ntramit, r1.ctipres,
                                                     r1.ctipgas, pcgarant, r1.cmonres, pdata,
                                                     vireserva, r1.idres, 0);
        END IF;
        --BUG40962-XVM. Fin


         IF num_err = 0 THEN
            /*IF v_cmultimon = 1 THEN
               IF r1.cmonres = v_cmonprod THEN
                  v_itasa := 1;
               ELSE
                  v_fcambio := pac_eco_tipocambio.f_fecha_max_cambio(r1.cmonres, v_cmonprod,
                                                                     f_sysdate);

                  IF v_fcambio IS NULL THEN
                     RETURN 9902592;
                  END IF;

                  v_itasa := pac_eco_tipocambio.f_cambio(r1.cmonres, v_cmonprod, v_fcambio);
               END IF;
            ELSE
               v_itasa := 1;
            END IF;

            vireserva := vireserva * NVL(v_itasa,1);*/
            xvaloracions := xvaloracions + vireserva;
         ELSE
            RETURN num_err;
         END IF;
      END LOOP;
   END IF;

   IF apl_coa_prov = TRUE THEN
      xvaloracions := xvaloracions * w_ploccoa / 100;
   END IF;

   num_err := 100540;

   IF NVL(pac_parametros.f_parempresa_n(v_cempres, 'MODULO_SINI'), 0) = 0 THEN
      SELECT SUM(DECODE(p.ctippag, 2, NVL(g.isinret, 0), 3, 0 - NVL(g.isinret, 0), 0))
        INTO xpagaments
        FROM pagogarantia g, pagosini p
       WHERE p.nsinies = pnsinies
         AND TRUNC(p.fordpag) <= TRUNC(pdata)
         AND p.cestpag <> 8
         AND p.sidepag = g.sidepag
         AND g.cgarant = pcgarant;
   ELSE
      BEGIN
         SELECT SUM(DECODE(p.ctippag, 2, NVL(g.isinret, 0), 3, 0 - NVL(g.isinret, 0), 0))
           INTO xpagaments
           FROM sin_tramita_pago_gar g, sin_tramita_pago p, sin_tramita_movpago m
          WHERE p.nsinies = pnsinies
            AND TRUNC(p.fordpag) <= TRUNC(pdata)
            AND p.sidepag = m.sidepag
            AND m.nmovpag = (SELECT MAX(nmovpag)
                               FROM sin_tramita_movpago
                              WHERE sidepag = m.sidepag
                                AND TRUNC(falta) <= TRUNC(pdata))
            AND m.cestpag NOT IN
                  (NVL
                      (pac_parametros.f_parempresa_n
                                              (pac_parametros.f_parinstalacion_n('EMPRESADEF'),
                                               'EDO_PAGO_PROCESA_REA'),
                       2),
                   2)   -- 36633 AVT 03/07/2015 los pagados después de remesados tb se deben exluir
            AND p.sidepag = g.sidepag
            AND g.cgarant = pcgarant;

         xpagaments := xpagaments * -1;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            xpagaments := 0;
      END;
   END IF;

   IF apl_coa_pag = TRUE THEN
      xpagaments := xpagaments * w_ploccoa / 100;
   END IF;
   -- INI -IAXIS-13133 -27/04/2020. Se condiciona el ptipo2
   IF ptipo = 2 THEN
     pprovisio := NVL(xvaloracions, 0);
   ELSE
     pprovisio := NVL(xvaloracions, 0) - NVL(xpagaments, 0);
   END IF;
   -- FIN -IAXIS-13133 -27/04/2020.
   RETURN 0;
EXCEPTION
   WHEN OTHERS THEN
      RETURN num_err;
END;

/

