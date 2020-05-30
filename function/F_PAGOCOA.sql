--------------------------------------------------------
--  DDL for Function F_PAGOCOA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_PAGOCOA" (
   pcempres IN NUMBER,
   pnsinies IN NUMBER,
   psidepag IN NUMBER,
   pisinret IN NUMBER,
   pctipcoa IN NUMBER,
   pctippag IN NUMBER,
   pmoneda IN NUMBER,
   pestpag IN NUMBER)   -- 6.0 MMM - 0025872: LCOL_F002-Revision Qtrackers contabilidad F2 - Nota 0148800
   RETURN NUMBER IS
/***************************************************************************
   F_PAGOCOA: Función que inserta en la tabla CtaCoaseguro cuando se
      realiza un pago o recobro por la totalidad.
   ALLIBCOA

/******************************************************************************
      NOMBRE:       F_INSDETREC
   PROPÓSITO:    Insertar un registro en la tabla de detrecibos.
   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        ??/??/????  ???                1. Creación del package.
   2.0        22/08/2012  JMP                2. 23187: LCOL_T020-COA-Circuit de Sinistres amb coasseguran
   3.0        27/09/2012  AVT                3. 22076: LCOL_A004-Mantenimientos de cuenta tecnica del reaseguro y del coaseguro
   4.0        01/11/2012  AVT                4. 0023183: LCOL_T020-COA-Circuit d'alta de propostes amb coasseguran
   5.0        20/02/2013  FAL                5. 0025357: LCOL_T020-LCOL-COA Nuevos conceptos Cuenta Coaseguro
   6.0        12/07/2013  MMM                6. 0025872-LCOL_F002-Revision Qtrackers contabilidad F2 - Nota 0148800
   7.0        19/05/2014  KBR                7. 0031458: POSPG100-Configuracion de IVA
   8.0        20/06/2014  EDA                8. 024462: LCOL_A004-Qreacker: 11203 y 11707 (176931) Modificación del circuito de siniestros-coaseguro
****************************************************************************/
   vobj           VARCHAR2(100) := 'F_PAGOCOA';
   vpar           VARCHAR2(1000)
      := 'e=' || pcempres || ' s=' || pnsinies || ' p=' || psidepag || ' r=' || pisinret
         || ' c=' || pctipcoa || ' t=' || pctippag || ' m=' || pmoneda;
   vpas           NUMBER;
   xsseguro       NUMBER;
   xncuacoa       NUMBER;
   xpcescoa       NUMBER;
   xcmovimi       NUMBER;
   xsigno         NUMBER;
   ximporte       NUMBER;
   xempr          NUMBER;
   xfmovimi       DATE;
   err            NUMBER;
   v_fcambio      DATE;   -- 23187 AVT 14/09/2012 s'afegeix la moneda
   v_importe_mon  NUMBER;
   v_importe_mon_cia NUMBER;
   v_itasa        NUMBER;
   v_cmultimon    parempresas.nvalpar%TYPE
                             := NVL(pac_parametros.f_parempresa_n(pcempres, 'MULTIMONEDA'), 0);
   v_cmoncontab   parempresas.nvalpar%TYPE
                                    := pac_parametros.f_parempresa_n(pcempres, 'MONEDACONTAB');
   v_cmonpro      codidivisa.cmoneda%TYPE;
   xnmovres       NUMBER(4);
   xcgarant       NUMBER(4);
   xntramit       NUMBER(3);
   -- KBR 20/05/2014 31458
   xcmovimi_iva   NUMBER;
   v_importe_iva  NUMBER;
   v_importe_ivamon NUMBER;
   ximporte_iva   NUMBER;
   ximporte_iva_moncia NUMBER;
   v_pagos_coa_pen parempresas.nvalpar%TYPE;   -- 20/06/2014 EDA Bug 24462/176931 Modificación del circuito de siniestros-coaseguro
   v_coasepag     NUMBER;   -- 20/06/2014 EDA Bug 24462/176931 Modificación del circuito de siniestros-coaseguro

   -- 23183 AVT 01/11/2012 S'AFEGEIX EL COA ACCEPTAT I EL CANVI SEGONS MONEDA DEL PAGO
   CURSOR empreses IS
      SELECT ccompan, pcescoa, sproduc, ccompapr
        FROM (SELECT c.ccompan, ploccoa pcescoa, sproduc, s.ccompani ccompapr
                FROM coacuadro c, seguros s
               WHERE c.sseguro = s.sseguro
                 AND s.ctipcoa = 8
                 AND c.sseguro = xsseguro
                 AND c.ncuacoa = xncuacoa
              UNION
              SELECT ccompan, pcescoa, sproduc, s.ccompani ccompapr
                FROM coacedido c, seguros s
               WHERE s.sseguro = c.sseguro
                 AND c.sseguro = xsseguro
                 AND c.ncuacoa = s.ncuacoa
                 AND s.ctipcoa = 1
                 AND c.ncuacoa = xncuacoa);

   -- Cursor en función de tipo de reserva (sólo estará informada la garantía cuando el tipo sea 1.-Indemnizatoria)
   -- KBR 20/05/2014 31458
   CURSOR cur_gar IS
      SELECT   ctipres, cmonres, cmonpag, SUM(isinret) isinret, SUM(isinretpag) isinretpag,
               SUM(iiva) iiva, SUM(iivapag) iivapag
          FROM sin_tramita_pago_gar
         WHERE sidepag = psidepag
      GROUP BY ctipres, cmonres, cmonpag;
BEGIN
   vpas := 100;

   -- ini Bug 0023187 - 22/08/2012 - JMF
   IF pac_parametros.f_parempresa_n(pcempres, 'MODULO_SINI') = 1 THEN
      vpas := 110;

      SELECT ncuacoa, sseguro
        INTO xncuacoa, xsseguro
        FROM sin_siniestro
       WHERE nsinies = pnsinies;

      vpas := 120;

      -- KBR 19/05/2014 31458
      SELECT fordpag, NVL(iiva, 0)
        INTO xfmovimi, v_importe_iva
        FROM sin_tramita_pago
       WHERE nsinies = pnsinies
         AND sidepag = psidepag;
   ELSE
      vpas := 130;

      SELECT ncuacoa, sseguro
        INTO xncuacoa, xsseguro
        FROM siniestros
       WHERE nsinies = pnsinies;

      vpas := 140;

      -- KBR 19/05/2014 31458
      SELECT fordpag, NVL(iimpiva, 0)
        INTO xfmovimi, v_importe_iva
        FROM pagosini
       WHERE nsinies = pnsinies
         AND sidepag = psidepag;
   END IF;

   -- fin Bug 0023187 - 22/08/2012 - JMF
   vpas := 150;
   -- buscamos el tipo de movimiento
   -- pago  KBR 19/05/2014 31458
   xcmovimi_iva := 29;

   IF pctippag = 2 THEN
      xcmovimi := 10;   -- pago
   ELSIF pctippag = 3 THEN
      xcmovimi := 12;   -- anulación pago
   ELSIF pctippag = 7 THEN
      xcmovimi := 11;   -- recobro
   ELSIF pctippag = 8 THEN
      xcmovimi := 13;   -- anulación recobro
   END IF;

   vpas := 160;
   -- 6. MMM - 0025872-LCOL_F002-Revision Qtrackers contabilidad F2 - Nota 0148800 - Inicio.
   -- Se incluye la comprobacion de si el pago se da por cobrado o anulado
   -- buscamos el signo
   --20/06/2014 EDA Bug 24462/176931 Modificación del circuito siniestros-coaseguro
   v_pagos_coa_pen := NVL(pac_parametros.f_parempresa_n(pcempres, 'PAGOS_COA_PEN'), 0);

   IF pctipcoa IN(1, 2)
      AND(pestpag = 1
          AND v_pagos_coa_pen = 0)
      OR(pestpag = 0
         AND v_pagos_coa_pen = 1) THEN   -- 20/06/2014 EDA Bug 24462/176931
      xsigno := 2;   -- cedido (haber)
   ELSIF pctipcoa IN(1, 2)
         AND pestpag = 8 THEN
      xsigno := 1;   -- anulacion cedido (debe)
   ELSIF pctipcoa IN(8, 9)
         AND pestpag = 1 THEN
      xsigno := 1;   -- aceptado (debe)
   ELSIF pctipcoa IN(8, 9)
         AND pestpag = 8 THEN
      xsigno := 2;   -- anulacion aceptado (debe)
   END IF;

   -- 6. MMM - 0025872-LCOL_F002-Revision Qtrackers contabilidad F2 - Nota 0148800 - Fin.
   vpas := 170;

   FOR emp IN empreses LOOP
      ---
      IF v_cmultimon = 1 THEN
         vpas := 171;
         -- 23187 AVT 14/09/2012 s'afegeix la moneda
         v_fcambio := xfmovimi;

         FOR reggar IN cur_gar LOOP
            vpas := 173;

            -- 23183 - 01/11/2012 - AVT busquem la moneda del producte i la comparem amb la de la reserva i la del pagament ---
            IF pac_monedas.f_cmoneda_n(reggar.cmonres) =
                                                    pac_monedas.f_moneda_producto(emp.sproduc)
               OR NVL(pac_monedas.f_cmoneda_n(reggar.cmonpag), 0) = 0 THEN
               vpas := 173;
               v_importe_mon := reggar.isinret;
               -- KBR 20/05/2014 31458
               v_importe_ivamon := reggar.iiva;
            ELSIF pac_monedas.f_cmoneda_n(reggar.cmonres) <>
                                                     pac_monedas.f_moneda_producto(emp.sproduc)
                  AND pac_monedas.f_cmoneda_n(reggar.cmonres) <>
                                                        pac_monedas.f_cmoneda_n(reggar.cmonpag) THEN
               vpas := 174;
               v_importe_mon := reggar.isinretpag;
               -- KBR 20/05/2014 31458
               v_importe_ivamon := reggar.iivapag;
            ELSE
               vpas := 175;
               v_cmonpro :=
                           pac_monedas.f_cmoneda_t(pac_monedas.f_moneda_producto(emp.sproduc));
               vpas := 176;
               v_itasa := pac_eco_tipocambio.f_cambio(reggar.cmonpag, v_cmonpro, xfmovimi);
               vpas := 177;
               -- KBR 20/05/2014 31458, cambiamos ximporte por reggar.isinret
               v_importe_mon := f_round(NVL(reggar.isinret, 0) * v_itasa,
                                        pac_monedas.f_moneda_producto(emp.sproduc));
               -- KBR 20/05/2014 31458
               v_importe_ivamon := f_round(NVL(reggar.iiva, 0) * v_itasa,
                                           pac_monedas.f_moneda_producto(emp.sproduc));
            END IF;
         END LOOP;
      END IF;

      -- buscamos el importe a grabar en la cuenta
      IF pctipcoa IN(1, 2) THEN   -- cedido
         vpas := 180;
         err := f_importecoa(xsseguro, xncuacoa, pisinret, emp.ccompan, emp.pcescoa, pmoneda,
                             ximporte);
         --KBR 19/05/2014 31458
         vpas := 181;
         err := f_importecoa(xsseguro, xncuacoa, v_importe_iva, emp.ccompan, emp.pcescoa,
                             pmoneda, ximporte_iva);

         IF v_cmultimon = 1 THEN
            vpas := 182;
            err := f_importecoa(xsseguro, xncuacoa, v_importe_mon, emp.ccompan, emp.pcescoa,
                                pmoneda, v_importe_mon_cia);
            --KBR 19/05/2014 31458
            vpas := 183;
            err := f_importecoa(xsseguro, xncuacoa, v_importe_ivamon, emp.ccompan,
                                emp.pcescoa, pmoneda, ximporte_iva_moncia);
         END IF;
      ELSIF pctipcoa IN(8, 9) THEN   -- aceptado
         vpas := 190;
         ximporte := pisinret;

         IF v_cmultimon = 1 THEN
            vpas := 191;
            v_importe_mon_cia := v_importe_mon;
         END IF;
      END IF;

      IF err <> 0 THEN
         p_tab_error(f_sysdate, f_user, vobj, vpas, vpar, 'err=' || err);
         RETURN err;
      END IF;

      -- 6.0 MMM - BUG_0025872-LCOL_F002-Revision Qtrackers contabilidad F2 Nota 0148800 - Inicio
      vpas := 192;

      SELECT NVL(MAX(nmovres), -1)
        INTO xnmovres
        FROM sin_tramita_reserva
       WHERE nsinies = pnsinies
         AND sidepag = psidepag;

      vpas := 193;

      SELECT cgarant, ntramit
        INTO xcgarant, xntramit
        FROM sin_tramita_reserva
       WHERE nsinies = pnsinies
         AND sidepag = psidepag
         AND nmovres = xnmovres;

      -- 20/06/2014 EDA Bug 24462/176931 Modificación del circuito de siniestros-coaseguro
      SELECT COUNT(*)
        INTO v_coasepag
        FROM ctacoaseguro
       WHERE ccompani = emp.ccompan
         AND cimport = 5
         AND ctipcoa = pctipcoa
         AND cmovimi = xcmovimi
         AND fmovimi = xfmovimi
         AND cdebhab = xsigno
         AND sseguro = xsseguro
         AND cempres = pcempres
         AND sidepag = psidepag
         AND nsinies = pnsinies
         AND nmovres = xnmovres
         AND cgarant = xcgarant;

      -- 6.0 MMM - BUG_0025872-LCOL_F002-Revision Qtrackers contabilidad F2 Nota 0148800 - Fin
      IF v_coasepag = 0 THEN   --- 20/06/2014 EDA Bug 24462/176931 Debido a que en siniestros pasa dos veces, se crea esta condición
         BEGIN
            -- insertamos el registro en la tabla ctacoaseguro
            vpas := 200;

            INSERT INTO ctacoaseguro
                        (smovcoa, ccompani, cimport, ctipcoa, cmovimi, imovimi,
                         fmovimi, fcontab, cdebhab, fliqcia, pcescoa, sidepag,
                         imovimi_moncon, fcambio, cmoneda, ctipmov, sseguro, cempres,
                         sproduc, cestado, nsinies, ccompapr, fcierre, ntramit, nmovres,
                         cgarant)
                 VALUES (smovcoa.NEXTVAL, emp.ccompan, 5, pctipcoa, xcmovimi, ximporte,
                         xfmovimi, NULL, xsigno, NULL, emp.pcescoa, psidepag,
                         v_importe_mon_cia, v_fcambio, pmoneda, 0, xsseguro, pcempres,
                         emp.sproduc, 1, pnsinies, emp.ccompapr, NULL, xntramit, xnmovres,
                         xcgarant);
         EXCEPTION
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, vobj, vpas, vpar, SQLCODE || ' ' || SQLERRM);
               RETURN 105578;
         END;

         --KBR 19/05/2014 31458
         -- insertamos el registro en la tabla ctacoaseguro siempre y cuando esté parametrizado para el cliente
         IF NVL(pac_parametros.f_parempresa_n(pcempres, 'APLICA_IVA_COACED'), 0) = 1
            AND ximporte_iva_moncia <> 0 THEN
            BEGIN
               vpas := 210;

               INSERT INTO ctacoaseguro
                           (smovcoa, ccompani, cimport, ctipcoa, cmovimi,
                            imovimi, fmovimi, fcontab, cdebhab, fliqcia, pcescoa,
                            sidepag, imovimi_moncon, fcambio, cmoneda, ctipmov, sseguro,
                            cempres, sproduc, cestado, nsinies, ccompapr, fcierre, ntramit,
                            nmovres, cgarant)
                    VALUES (smovcoa.NEXTVAL, emp.ccompan, 5, pctipcoa, xcmovimi_iva,
                            ximporte_iva, xfmovimi, NULL, xsigno, NULL, emp.pcescoa,
                            psidepag, ximporte_iva_moncia, v_fcambio, pmoneda, 0, xsseguro,
                            pcempres, emp.sproduc, 1, pnsinies, emp.ccompapr, NULL, xntramit,
                            xnmovres, xcgarant);
            EXCEPTION
               WHEN OTHERS THEN
                  p_tab_error(f_sysdate, f_user, vobj, vpas, vpar, SQLCODE || ' ' || SQLERRM);
                  RETURN 105578;
            END;
         END IF;
      --KBR 19/05/2014 31458
      END IF;
   END LOOP;

   vpas := 220;
   RETURN 0;
EXCEPTION
   WHEN OTHERS THEN
      p_tab_error(f_sysdate, f_user, vobj, vpas, vpar, SQLCODE || ' ' || SQLERRM);
      RETURN 105716;
END;

/

  GRANT EXECUTE ON "AXIS"."F_PAGOCOA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_PAGOCOA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_PAGOCOA" TO "PROGRAMADORESCSI";
