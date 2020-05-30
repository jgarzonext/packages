--------------------------------------------------------
--  DDL for Function F_INSCTACOAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_INSCTACOAS" (
   pnrecibo IN NUMBER,
   pcestrec IN NUMBER,
   pcempres IN empresas.cempres%TYPE DEFAULT pac_md_common.f_get_cxtempresa,   -- 23183 - AVT - 26/10/2012
   psmovrec IN NUMBER,
   pfmovimi IN DATE)
   RETURN NUMBER IS
/* ****************************************************************************************************
   F_INSCTACOAS : Insertar un registro en la tabla CTACOACEDIDO.
   ALLIBADM - Gestión de datos referentes a los recibos
        funcion que inserta un registro por
                 cada compañia que comparte un coaseguro cedido.

      REVISIONES:
      Ver        Fecha        Autor             Descripci¿n
      ---------  ----------  -------  -------------------------------------
      1.0        XX/XX/XXXX   XXX     1. Creaci¿n de la funci¿n.
      1.1        26/10/2012   AVT     2. 23183: LCOL_T020-COA-Circuit d'alta de propostes amb coasseguran
      1.2        08/11/2012   XVM     3. 0023183: LCOL_T020-COA-Circuit d'alta de propostes amb coasseguran
      1.3        24/12/2012   DCT     4. 0025357: LCOL_T020-LCOL-COA Nuevos conceptos Cuenta Coaseguro
      1.4        20/02/2013   FAL     5. 0025357: LCOL_T020-LCOL-COA Nuevos conceptos Cuenta Coaseguro
      1.5        25/02/2013   JSV     6. 0027260: LCOL_A004-Qtracker: 0008015: INCONSISTENCIAS RECAUDO PRIMAS
      1.6        17/10/2013   KBR     7. 0027879: LCOL_T020-Qtracker: 0008849: ERROR AL VISUALIZAR POLIZAS ANULADAS
      1.7        06/11/2013   KBR     8. 0027879: LCOL_T020-Qtracker: 0008849: ERROR AL VISUALIZAR POLIZAS ANULADAS
      1.8        22/11/2013   MMM     9. 0028986: LCOL_A004-Qtracker: 10043, 10046, 10051
      1.9        18/03/2014   AGG    10. 0029080: POSCOA API Incluir Campo Gastos de Administracion Coaseguro Aceptado
      1.9        16/07/2014   EDA    11. 0032085: LCOL_A004-QT LISTADOS COASEGURO: Cambio del signo D/H cuando el recibo es una anulación
****************************************************************************************************** */

   -- ini BUG 0026035 - 12/02/2013 - JMF
   v_obj          VARCHAR2(200) := 'F_INSCTACOAS';
   v_par          VARCHAR2(500) := 'rec=' || pnrecibo || ' est=' || pcestrec || 'emp=' || pcempres || ' mov=' || psmovrec || ' fec=' || pfmovimi;
   -- fin BUG 0026035 - 12/02/2013 - JMF
   error          NUMBER := 0;
   xctipcoa       NUMBER;
   xncuacoa       NUMBER;
   xsseguro       NUMBER;
   xtiprec        NUMBER;
   xtipimp        NUMBER;
   ximporte       NUMBER;
   xsmovcoa       NUMBER;
   xitpri         NUMBER;
   xitcon         NUMBER;
   xittotr        NUMBER;
   xicombru       NUMBER;
   xpcescoa       NUMBER;
   xsignoprima    NUMBER;
   xsignocomis    NUMBER;
   xcestaux       recibos.cestaux%TYPE;
   v_pgasadm      NUMBER;
   vpasexec       NUMBER;
-- Bug 0023183 - DCG - 14/08/2012 - LCOL_T020-COA-Circuit d'alta de propostes amb coasseguran
   xcmoneda       NUMBER;
   v_fcambio      DATE;
   v_importe_mon  NUMBER;
   v_itasa        NUMBER;
   v_cmultimon    parempresas.nvalpar%TYPE;
   v_cmoncontab   parempresas.nvalpar%TYPE;
   xsproduc       seguros.sproduc%TYPE;
   xccompapr      seguros.ccompani%TYPE;
   --CONF-905 inicio
   xiretced       NUMBER;
   xisobcom       NUMBER;
   xiretsob       NUMBER;
   xicascom       NUMBER;
   xreticom       NUMBER;
   v_calgastemi   parempresas.nvalpar%TYPE;

   --CONF-905 fin

   -- Fin Bug 0023183

   -- Bug 0023183 - DCG - 14/08/2012 - LCOL_T020-COA-Circuit d'alta de propostes amb coasseguran
   -- 23183 - AVT - 26/10/2012 s'afegeix el Coasseguro acceptat.
   -- 23183 - AVT - 01/11/2012 afegim SPRODUC i CCOMPAPR
   CURSOR cur_compania(cpseguro NUMBER, cpcuacoa NUMBER) IS
      SELECT sseguro, ncuacoa, ccompan, pcescoa, pcomcoa, pcomcon, pcomgas, pcesion
        FROM (SELECT c.sseguro, c.ncuacoa, c.ccompan, ploccoa pcescoa, 0 pcomcoa, 0 pcomcon,
                     NVL(pac_preguntas.ff_buscapregunpolseg(s.sseguro, 5700, NULL), 0) pcomgas,
                     ploccoa pcesion
                FROM coacuadro c, seguros s
               WHERE c.sseguro = s.sseguro
                 AND s.ctipcoa = 8
                 AND c.sseguro = cpseguro
                 AND c.ncuacoa = cpcuacoa
              UNION
              SELECT c.sseguro, c.ncuacoa, c.ccompan, c.pcescoa, c.pcomcoa, c.pcomcon,
                     c.pcomgas, c.pcesion
                FROM coacedido c, seguros s
               WHERE c.sseguro = s.sseguro
                 AND s.ctipcoa = 1
                 AND c.sseguro = cpseguro
                 AND c.ncuacoa = cpcuacoa);

   regcom         coacedido%ROWTYPE;
   xcempres       seguros.cempres%TYPE;
   vtmpcontrol    NUMBER;
    --QT 2057
    VCDEBHAB        NUMBER;
    VCIMPORT        NUMBER;
    VPORGASTO       NUMBER;
    VPORRETEIVA     NUMBER;
    VPORRETEICA     NUMBER;
    VPORRETFTEGASADM    NUMBER;
    VPTIPIVA        NUMBER;
    VGASADM         NUMBER;
    VIVAGASADM      NUMBER;
    VRETIVAGASADM   NUMBER;
    VRETFTEGASADM   NUMBER;
    VRETICAGASADM   NUMBER;
    VCCOMPANI       COMPANIAS.CCOMPANI%TYPE;
    VVALOR          NUMBER;
    XXSESION        NUMBER;
    VRET            NUMBER;
    VIMOVIMI        NUMBER;

BEGIN
   vpasexec := 1;

   -- 1.8 - 22/11/2013 - MMM - 9. 0028986: LCOL_A004-Qtracker: 10043, 10046, 10051 - Inicio
   -- Para evitar problemas si se llama más de una vez para el mismo recibo se incluye un control
   -- Si ya existe el recibo en ctacoaseguro, no hacemos nada y salimos de la función
   SELECT COUNT(1)
     INTO vtmpcontrol
     FROM ctacoaseguro
    WHERE nrecibo = pnrecibo
      AND smovrec = psmovrec;

   IF vtmpcontrol > 0 THEN
      p_tab_error(f_sysdate, f_user, 'F_INSCTACOAS = ' || pnrecibo, vpasexec,
                  'Recibo ya existente en CTACOASEGURO', SQLERRM);
      RETURN 0;
   END IF;

   -- 1.8 - 22/11/2013 - MMM - 9. 0028986: LCOL_A004-Qtracker: 10043, 10046, 10051 - Fin

   -- Buscamos el tipo de coaseguro, y el numero de cuadro
   BEGIN
      SELECT r.ctipcoa, r.ncuacoa, r.sseguro, r.ctiprec, r.cempres, s.sproduc, s.ccompani,
             r.cestaux
        INTO xctipcoa, xncuacoa, xsseguro, xtiprec, xcempres, xsproduc, xccompapr,
             xcestaux
        FROM recibos r, seguros s
       WHERE s.sseguro = r.sseguro
         AND nrecibo = pnrecibo;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         p_tab_error(f_sysdate, f_user, 'F_INSCTACOAS = ' || pnrecibo, vpasexec,
                     'NO_DATA_FOUND FROM recibos error:' || error, SQLERRM);
         RETURN 101902;   -- Recibo no encontrado en la tabla
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'F_INSCTACOAS = ' || pnrecibo, vpasexec,
                     'OTHERS FROM recibos error:' || error, SQLERRM);
         RETURN 102367;   -- Error al leer de la tabla RECIBOS
   END;

   vpasexec := 2;
   v_cmultimon := NVL(pac_parametros.f_parempresa_n(NVL(pcempres, xcempres), 'MULTIMONEDA'), 0);
   v_cmoncontab := pac_parametros.f_parempresa_n(NVL(pcempres, xcempres), 'MONEDACONTAB');
   v_calgastemi := NVL(pac_parametros.f_parempresa_n(NVL(pcempres, xcempres),
                                                     'CALCULA_GASTOS_EMI'),
                       0);
   xccompapr := 1;

   --1 Cedido
   --8 Aceptado
   IF (xctipcoa = 1 OR xctipcoa = 8) AND xcestaux <> 2 THEN   --Bug 23183-XVM-08/11/2012.Añadimos condición cestaux
      -- Se trata de un coaseguro de recibo unico
      IF error = 0 THEN
         -- Obtenemos los importes totales cedidos del recibo
         BEGIN
            IF xctipcoa = 1 THEN
               vpasexec := 3;

               --BUG 0025357: DCT: 21/12/2012: INICIO: LCOL_T020-LCOL-COA Nuevos conceptos Cuenta Coaseguro. Se añade NVL(icedcbr, 0)
               -- coaseguro cedido necesitamos los importes de la parte cedida
               BEGIN
                  SELECT NVL(it2pri, 0), NVL(it2con, 0), NVL(it2totr, 0), NVL(icedcbr, 0),
                         NVL(icedcrt, 0), NVL(iimp_5, 0), NVL(iimp_6, 0), NVL(iimp_7, 0),
                         NVL(iimp_8, 0)
                    -- SE AÑADE LA COMISIÓN BRUTA CEDIDA
                    -- Se añade la retencion por IVA sobre comision cedida
                  INTO   xitpri, xitcon, xittotr, xicombru,
                         xiretced, xisobcom, xiretsob, xicascom,
                         xreticom
                    FROM vdetrecibos
                   WHERE nrecibo = pnrecibo;
               EXCEPTION
                  WHEN OTHERS THEN
                     p_tab_error(f_sysdate, f_user, 'F_INSCTACOAS = ' || pnrecibo, vpasexec,
                                 'OTHERS FROM vdetrecibos error:' || error, SQLERRM);
               END;

               --BUG 0025357: DCT: 21/12/2012: FIN: LCOL_T020-LCOL-COA Nuevos conceptos Cuenta Coaseguro. Se añade NVL(icedcbr, 0)

               -- Buscamos si es un concepto del Debe o del Haber
               -- 27879 KBR. 17/10/2013 No tomamos en cuenta el estado del recibo, solo el tipo de recibo
               IF xtiprec != 9 THEN
                  xsignoprima := 1;   -- Debe
                  xsignocomis := 2;   -- Haber
               ELSE
                  xsignoprima := 2;   --Haber
                  xsignocomis := 1;   -- Debe
               END IF;
            -- 27879 KBR. 17/10/2013
            ELSE
               vpasexec := 4;

               BEGIN
                  SELECT NVL(it1pri, 0), NVL(it1con, 0), NVL(icombru, 0), NVL(it1totr, 0)
                    INTO xitpri, xitcon, xicombru, xittotr
                    FROM vdetrecibos
                   WHERE nrecibo = pnrecibo;
               EXCEPTION
                  WHEN OTHERS THEN
                     p_tab_error(f_sysdate, f_user, 'F_INSCTACOAS = ' || pnrecibo, vpasexec,
                                 'OTHERS FROM vdetrecibos error:' || error, SQLERRM);
               END;

               vpasexec := 5;

               -- Buscamos el signo
               -- 27879 KBR. 06/11/2013 Ajustes en signos de cta coaseguro
               --9: Extornos
               IF xtiprec = 9 THEN
                  xsignoprima := 1;
                  xsignocomis := 2;
               ELSE
                  -- gastos honorarios retorno (13: old=Anulacion recobro new=Retorno)
                  IF xtiprec = 13 THEN
                     xsignoprima := 2;
                  -- gastos honorarios (15: old=Nuestra remesa new=Recobro del retorno)
                  ELSIF xtiprec = 15 THEN
                     xsignoprima := 1;
                  ELSE
                     xsignoprima := 2;
                  END IF;

                  xsignocomis := 1;
               END IF;
            -- 27879 KBR. 17/10/2013
            END IF;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               p_tab_error(f_sysdate, f_user, 'F_INSCTACOAS = ' || pnrecibo, vpasexec,
                           'NO_DATA_FOUND 103936', SQLERRM);
               RETURN 103936;   -- Registro no encontrado en VDETRECIBOS
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, 'F_INSCTACOAS = ' || pnrecibo, vpasexec,
                           'NO_DATA_FOUND 103920', SQLERRM);
               RETURN 103920;   -- Error al leer en la tabla VDETRECIBOS
         END;

         vpasexec := 6;
         VCDEBHAB := xsignoprima;

         OPEN cur_compania(xsseguro, xncuacoa);

         FETCH cur_compania
          INTO regcom;

         WHILE cur_compania%FOUND LOOP
            BEGIN
               xpcescoa := regcom.pcescoa;
               -- ***** Prima (total del recibo) *****
               -- Buscamos el siguiente numero de secuencia
               vpasexec := 7;

               BEGIN
                  SELECT smovcoa.NEXTVAL
                    INTO xsmovcoa
                    FROM DUAL;
               EXCEPTION
                  WHEN OTHERS THEN
                     p_tab_error(f_sysdate, f_user, 'F_INSCTACOAS = ' || pnrecibo, vpasexec,
                                 'OTHERS xsmovcoa 105575', SQLERRM);
                     RETURN 105575;
               -- Error al leer la secuencia (smovcoa de la Bds
               END;

               --BUG 0025357: DCT: 21/12/2012: INICIO: LCOL_T020-LCOL-COA Nuevos conceptos Cuenta Coaseguro. Añadir IF xtiprec IN(13, 15) THEN  xtipimp := 8
               IF xtiprec IN(13, 15) THEN
                  xtipimp := 8;   -- nou vf:150 Gastos honorarios
               ELSE
                  xtipimp := 1; -- Prima
               END IF;

               --BUG 0025357: DCT: 21/12/2012: FIN: LCOL_T020-LCOL-COA Nuevos conceptos Cuenta Coaseguro. Añadir IF xtiprec IN(13, 15) THEN  xtipimp := 8
               IF xctipcoa = 1 THEN
                  ximporte := xittotr *(regcom.pcesion / 100);
               ELSE
                  ximporte := xittotr;
               END IF;

               vpasexec := 8;

               -- Bug 0023183 - DCG - 14/08/2012 - LCOL_T020-COA-Circuit d'alta de propostes amb coasseguran
               BEGIN
                  SELECT cmoneda
                    INTO xcmoneda
                    FROM seguros
                   WHERE sseguro = xsseguro;
               EXCEPTION
                  WHEN OTHERS THEN
                     p_tab_error(f_sysdate, f_user, 'F_INSCTACOAS = ' || pnrecibo, vpasexec,
                                 'NO_DATA_FOUND Moneda', SQLERRM);
               END;

               v_fcambio := pfmovimi;

               IF v_cmultimon = 1 THEN
                  vpasexec := 81;
                  error := pac_oper_monedas.f_datos_contraval(xsseguro, NULL, NULL, v_fcambio,
                                                              3, v_itasa, v_fcambio);

                  IF error <> 0 THEN
                     p_tab_error(f_sysdate, f_user, 'F_INSCTACOAS = ' || xsseguro, vpasexec,
                                 'f_datos_contraval:' || error, SQLERRM);
                     RETURN error;
                  END IF;

                  v_importe_mon := f_round(NVL(ximporte, 0) * v_itasa, v_cmoncontab);
               END IF;

               -- Fin Bug 0023183
               IF ximporte != 0 THEN
                    ximporte := round(ximporte,0);
                  BEGIN
                    INSERT INTO ctacoaseguro
                                (smovcoa, ccompani, cimport, ctipcoa, cmovimi, imovimi, fmovimi, fcontab,
                                 cdebhab, fliqcia,
                                 pcescoa, nrecibo, smovrec, sseguro, imovimi_moncon, fcambio,
                                 cempres, cmoneda, cestado, ctipmov, sproduc, ccompapr, fcierre)
                         VALUES (xsmovcoa, regcom.ccompan, xtipimp, xctipcoa, xtiprec, ximporte, pfmovimi, NULL,
                                 DECODE(pcestrec,
                                        -- 16/07/2014   EDA  Bug 0032085/179140 Cuando el recibo se anula cambia el signo origen
                                        2, DECODE(xsignoprima, 1, 2, 2, 1), xsignoprima), NULL,
                                 xpcescoa, pnrecibo, psmovrec, xsseguro, v_importe_mon, v_fcambio,
                                 NVL(pcempres, xcempres), xcmoneda, 1, 0, xsproduc, xccompapr, NULL);
                  EXCEPTION
                     WHEN OTHERS THEN
                        p_tab_error(f_sysdate, f_user, 'F_INSCTACOAS = ' || pnrecibo,
                                    vpasexec, 'INSERT INTO ctacoaseguro', SQLERRM);
                  END;
                  VIMOVIMI := ximporte;
               END IF;

               --BUG 0025357: DCT: 21/12/2012: INICIO: LCOL_T020-LCOL-COA Nuevos conceptos Cuenta Coaseguro.
               IF xtiprec NOT IN(13, 15) THEN
                  -- Buscamos el siguiente numero de secuencia
                  vpasexec := 9;

                  BEGIN
                     SELECT smovcoa.NEXTVAL
                       INTO xsmovcoa
                       FROM DUAL;
                  EXCEPTION
                     WHEN OTHERS THEN
                        p_tab_error(f_sysdate, f_user, 'F_INSCTACOAS = ' || pnrecibo,
                                    vpasexec, 'OTHERS xsmovcoa 105575', SQLERRM);
                        RETURN 105575;
                  -- Error al leer la secuencia (smovcoa de la Bds
                  END;

                  xtipimp := 2; --Comisión agente
                  vpasexec := 10;

                  IF xctipcoa = 1 THEN
                     --BUG 0025357: DCT: 21/12/2012: INICIO: LCOL_T020-LCOL-COA Nuevos conceptos Cuenta Coaseguro.
                     IF NVL(regcom.pcomcoa, 0) <> 0 THEN
                        ximporte := xitpri *(regcom.pcesion / 100) *(regcom.pcomcoa / 100);
                     ELSE
                        ximporte := xicombru *(regcom.pcesion / 100);
                     END IF;
                  --BUG 0025357: DCT: 21/12/2012: FIN: LCOL_T020-LCOL-COA Nuevos conceptos Cuenta Coaseguro.
                  ELSE
                     BEGIN
                        SELECT pgasadm
                          INTO v_pgasadm
                          FROM companias_gastos
                         WHERE cempres = NVL(pcempres, xcempres)
                           AND sproduc = 0
                           AND finigac > pfmovimi
                           AND(ffingac IS NULL
                               OR ffingac < pfmovimi);

                        ximporte := xitpri *(v_pgasadm / 100);
                     EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                           p_tab_error(f_sysdate, f_user, 'F_INSCTACOAS = ' || pnrecibo,
                                       vpasexec, 'NO_DATA_FOUND  FROM companias_gastos',
                                       SQLERRM);

                           -- INI RLLF BUG-32591 28/05/2015 no inserta el coaseguro en ctacoaseguro y no se envia a sap
                           --IF regcom.pcomcoa IS NULL THEN
                           IF NVL(regcom.pcomcoa, 0) = 0 THEN
                              -- FIN RLLF BUG-32591 28/05/2015 no inserta el coaseguro en ctacoaseguro y no se envia a sap
                              ximporte := xicombru;
                           ELSE
                              ximporte := xitpri *(regcom.pcomcoa / 100);
                           END IF;
                     END;
                  END IF;

                  BEGIN
                     SELECT cmoneda
                       INTO xcmoneda
                       FROM seguros
                      WHERE sseguro = xsseguro;
                  EXCEPTION
                     WHEN OTHERS THEN
                        p_tab_error(f_sysdate, f_user, 'F_INSCTACOAS = ' || pnrecibo,
                                    vpasexec, 'NO_DATA_FOUND  Moneda', SQLERRM);
                  END;

                  vpasexec := 11;
                  v_fcambio := pfmovimi;

                  IF v_cmultimon = 1 THEN
                     vpasexec := 82;
                     error := pac_oper_monedas.f_datos_contraval(xsseguro, NULL, NULL,
                                                                 v_fcambio, 3, v_itasa,
                                                                 v_fcambio);

                     IF error <> 0 THEN
                        p_tab_error(f_sysdate, f_user, 'F_INSCTACOAS = ' || xsseguro,
                                    vpasexec, 'f_datos_contraval:' || error, SQLERRM);
                        RETURN error;
                     END IF;

                     v_importe_mon := f_round(NVL(ximporte, 0) * v_itasa, v_cmoncontab);
                  END IF;

                    -- Fin Bug 0023183
                  IF ximporte != 0 THEN
                     ximporte := round(ximporte,0);
                     BEGIN
                        INSERT INTO ctacoaseguro
                                    (smovcoa, ccompani, cimport, ctipcoa, cmovimi,
                                     imovimi, fmovimi, fcontab,
                                     cdebhab,
                                     fliqcia, pcescoa, nrecibo, smovrec, sseguro,
                                     imovimi_moncon, fcambio, cempres,
                                     cmoneda, cestado, ctipmov, sproduc, ccompapr, fcierre)
                             VALUES (xsmovcoa, regcom.ccompan, xtipimp, xctipcoa, xtiprec,
                                     ximporte, pfmovimi, NULL,
                                     DECODE(pcestrec,
                        -- 16/07/2014   EDA  Bug 0032085/179140 Cuando el recibo se anula cambia el signo origen
                                            2, DECODE(xsignocomis, 1, 2, 2, 1),
                                            xsignocomis),
                                     NULL, xpcescoa, pnrecibo, psmovrec, xsseguro,
                                     v_importe_mon, v_fcambio, NVL(pcempres, xcempres),
                                     xcmoneda, 1, 0, xsproduc, xccompapr, NULL);
                     EXCEPTION
                        WHEN OTHERS THEN
                           p_tab_error(f_sysdate, f_user, 'F_INSCTACOAS = ' || pnrecibo,
                                       vpasexec, 'INSERT INTO ctacoaseguro', SQLERRM);
                     END;
                  END IF;

                  vpasexec := 12;

                  -- ****** Comision consorcio *****
                  -- Buscamos el siguiente numero de secuencia
                    BEGIN
                     SELECT smovcoa.NEXTVAL
                       INTO xsmovcoa
                       FROM DUAL;
                    EXCEPTION
                     WHEN OTHERS THEN
                        p_tab_error(f_sysdate, f_user, 'F_INSCTACOAS = ' || pnrecibo,
                                    vpasexec, 'OTHERS xsmovcoa 105575', SQLERRM);
                        RETURN 105575;
                  -- Error al leer la secuencia (smovcoa de la Bds
                    END;


--INICIO JAAB 18/04/2018 QT 2057
--Los cambios hechos aquí deben replicarse en f_insctacoas y pac_coa.F_SET_REMESA_CTACOA y pac_coa.F_insctacoas_parcial
                    IF pcempres = 24 THEN --confianza
                        vpasexec := 500;
                        vccompani := regcom.ccompan;

                        -- Retefuente
                        BEGIN
                            SELECT DECODE (r.cregfiscal, 6, 0, 8, 0, DECODE (p.ctipper, 1, 1, 2))
                              INTO vvalor
                              FROM companias cp, per_personas p,(SELECT sperson, cregfiscal
                                                                   FROM per_regimenfiscal
                                                                  WHERE (sperson, fefecto) IN (SELECT   sperson, MAX (fefecto)
                                                                                                 FROM per_regimenfiscal
                                                                                             GROUP BY sperson)) r
                             WHERE cp.ccompani = Vccompani
                               AND p.sperson = cp.sperson
                               AND p.sperson = r.sperson(+);

                            SELECT sgt_sesiones.NEXTVAL
                              INTO xxsesion
                              FROM DUAL;

                            SELECT vtramo (xxsesion, 800064, vvalor)
                              INTO VPORRETFTEGASADM
                              FROM DUAL;

                        EXCEPTION
                            WHEN OTHERS THEN
                                p_tab_error (f_sysdate, f_user, v_obj, vpasexec, v_par, 107885 || ' - ' || SQLCODE || ' - ' || SQLERRM);
                        END;


                        vpasexec := 501;

                        VPORGASTO   := NVL(pac_parametros.f_parempresa_n(pcempres, 'PORGAST_ADMCOA'), 0);--Porcentaje Gastos de Administración
                        VPORRETEIVA := NVL(pac_parametros.f_parempresa_n(pcempres, 'PORRETIVA_ADMCOA'), 0);--Porcentaje RETEIVA Gastos de Administración

                        BEGIN--Porcentaje IVA
                            SELECT ptipiva
                              INTO vptipiva
                              FROM tipoiva t, companias co
                             WHERE co.ccompani = Vccompani
                               AND co.ctipiva = t.ctipiva
                               AND t.ffinvig IS NULL;
                        EXCEPTION
                            WHEN NO_DATA_FOUND THEN
                                Vptipiva := 0;
                            WHEN OTHERS THEN
                                p_tab_error(f_sysdate, f_user, v_obj, vpasexec, V_PAR,  107885 || ' ' || NVL(SQLERRM, SQLCODE || ' ' || SQLERRM));
                        END;

                        vpasexec := 502;
                        --ReteICA
                        VPORRETEICA := PAC_IMPUESTOS_CONF.F_RETEICA_INDICADOR_COA (vccompani);

                        BEGIN
                            SELECT cmoneda
                              INTO xcmoneda
                              FROM seguros
                             WHERE sseguro = xsseguro;
                        EXCEPTION
                            WHEN OTHERS THEN
                                p_tab_error(f_sysdate, f_user, 'F_INSCTACOAS = ' || pnrecibo, vpasexec, 'NO_DATA_FOUND Moneda', SQLERRM);
                        END;

                        IF v_cmultimon = 1 THEN
                            vpasexec := 503;
                            v_fcambio := pfmovimi;
                            error := pac_oper_monedas.f_datos_contraval(xsseguro, NULL, NULL, v_fcambio, 3, v_itasa, v_fcambio);

                            IF error <> 0 THEN
                                p_tab_error(f_sysdate, f_user, 'F_INSCTACOAS = ' || xsseguro, vpasexec, 'f_datos_contraval:' || error, SQLERRM);
                                RETURN error;
                            END IF;
                        END IF;

                        --Se calculan los conceptos automàticos
                        IF Vcdebhab = 1 THEN
                            Vcdebhab := 2;
                        ELSIF Vcdebhab = 2 THEN
                            Vcdebhab := 1;
                        END IF;

                        vpasexec := 504;
                        VCIMPORT := 4; --Gastos de Administración
                        SELECT smovcoa.NEXTVAL
                          INTO xsmovcoa
                          FROM DUAL;

                        VGASADM := ROUND(VIMOVIMI * VPORGASTO / 100, 0);
                        v_importe_mon := f_round(NVL(VGASADM, 0) * v_itasa, v_cmoncontab);

                        vpasexec := 505;
                        BEGIN
                            INSERT INTO ctacoaseguro
                                    (smovcoa, ccompani, cimport, ctipcoa, cmovimi, imovimi, fmovimi, fcontab, cdebhab, fliqcia,
                                    pcescoa, nrecibo, smovrec, sseguro, imovimi_moncon, fcambio,cempres, cmoneda, cestado, ctipmov,
                                    sproduc, ccompapr, fcierre)
                            VALUES (xsmovcoa, Vccompani, VCIMPORT, xctipcoa, xtiprec, VGASADM, pfmovimi, NULL, VCDEBHAB, NULL,
                                    xpcescoa, pnrecibo, psmovrec, xsseguro, v_importe_mon, v_fcambio, NVL(pcempres, xcempres), xcmoneda, 1, 0,
                                    xsproduc, xccompapr, NULL);
                        EXCEPTION
                            WHEN OTHERS THEN
                                p_tab_error(f_sysdate, f_user, 'F_INSCTACOAS = ' || pnrecibo, vpasexec, 'INSERT INTO ctacoaseguro', SQLERRM);
                        END;

                        vpasexec := 506;
                        VCIMPORT := 13; --IVA sobre gastos de Administración
                        SELECT smovcoa.NEXTVAL
                          INTO xsmovcoa
                          FROM DUAL;

                        VIVAGASADM := ROUND(VGASADM * vptipiva / 100, 0);
                        v_importe_mon := f_round(NVL(VIVAGASADM, 0) * v_itasa, v_cmoncontab);

                        vpasexec := 507;
                        BEGIN
                            INSERT INTO ctacoaseguro
                                    (smovcoa, ccompani, cimport, ctipcoa, cmovimi, imovimi, fmovimi, fcontab, cdebhab, fliqcia,
                                    pcescoa, nrecibo, smovrec, sseguro, imovimi_moncon, fcambio,cempres, cmoneda, cestado, ctipmov,
                                    sproduc, ccompapr, fcierre)
                            VALUES (xsmovcoa, Vccompani, VCIMPORT, xctipcoa, xtiprec, VIVAGASADM, pfmovimi, NULL, VCDEBHAB, NULL,
                                    xpcescoa, pnrecibo, psmovrec, xsseguro, v_importe_mon, v_fcambio, NVL(pcempres, xcempres), xcmoneda, 1, 0,
                                    xsproduc, xccompapr, NULL);
                        EXCEPTION
                            WHEN OTHERS THEN
                                p_tab_error(f_sysdate, f_user, 'F_INSCTACOAS = ' || pnrecibo, vpasexec, 'INSERT INTO ctacoaseguro', SQLERRM);
                        END;

                        --Cambia el signo para las retenciones
                        IF Vcdebhab = 1 THEN
                            Vcdebhab := 2;
                        ELSIF Vcdebhab = 2 THEN
                            Vcdebhab := 1;
                        END IF;

                        vpasexec := 508;
                        VCIMPORT := 38; --Retención de IVA sobre gastos de Administración
                        SELECT smovcoa.NEXTVAL
                          INTO xsmovcoa
                          FROM DUAL;

                        VRETIVAGASADM := ROUND(VIVAGASADM * VPORRETEIVA / 100, 0);
                        v_importe_mon := f_round(NVL(VRETIVAGASADM, 0) * v_itasa, v_cmoncontab);

                        vpasexec := 509;
                        BEGIN
                            INSERT INTO ctacoaseguro
                                    (smovcoa, ccompani, cimport, ctipcoa, cmovimi, imovimi, fmovimi, fcontab, cdebhab, fliqcia,
                                    pcescoa, nrecibo, smovrec, sseguro, imovimi_moncon, fcambio,cempres, cmoneda, cestado, ctipmov,
                                    sproduc, ccompapr, fcierre)
                            VALUES (xsmovcoa, Vccompani, VCIMPORT, xctipcoa, xtiprec, VRETIVAGASADM, pfmovimi, NULL, VCDEBHAB, NULL,
                                    xpcescoa, pnrecibo, psmovrec, xsseguro, v_importe_mon, v_fcambio, NVL(pcempres, xcempres), xcmoneda, 1, 0,
                                    xsproduc, xccompapr, NULL);
                        EXCEPTION
                            WHEN OTHERS THEN
                                p_tab_error(f_sysdate, f_user, 'F_INSCTACOAS = ' || pnrecibo, vpasexec, 'INSERT INTO ctacoaseguro', SQLERRM);
                        END;

                        vpasexec := 510;
                        VCIMPORT := 39; --Retención en la fuente sobre gastos de Administración
                        SELECT smovcoa.NEXTVAL
                          INTO xsmovcoa
                          FROM DUAL;

                        VRETFTEGASADM := ROUND(VGASADM * VPORRETFTEGASADM / 100, 0);
                        v_importe_mon := f_round(NVL(VRETFTEGASADM, 0) * v_itasa, v_cmoncontab);

                        vpasexec := 511;
                        BEGIN
                            INSERT INTO ctacoaseguro
                                    (smovcoa, ccompani, cimport, ctipcoa, cmovimi, imovimi, fmovimi, fcontab, cdebhab, fliqcia,
                                    pcescoa, nrecibo, smovrec, sseguro, imovimi_moncon, fcambio,cempres, cmoneda, cestado, ctipmov,
                                    sproduc, ccompapr, fcierre)
                            VALUES (xsmovcoa, Vccompani, VCIMPORT, xctipcoa, xtiprec, VRETFTEGASADM, pfmovimi, NULL, VCDEBHAB, NULL,
                                    xpcescoa, pnrecibo, psmovrec, xsseguro, v_importe_mon, v_fcambio, NVL(pcempres, xcempres), xcmoneda, 1, 0,
                                    xsproduc, xccompapr, NULL);
                        EXCEPTION
                            WHEN OTHERS THEN
                                p_tab_error(f_sysdate, f_user, 'F_INSCTACOAS = ' || pnrecibo, vpasexec, 'INSERT INTO ctacoaseguro', SQLERRM);
                        END;

                        vpasexec := 512;
                        VCIMPORT := 42;	--Retención de ICA sobre gastos de Administración
                        SELECT smovcoa.NEXTVAL
                          INTO xsmovcoa
                          FROM DUAL;

                        VRETICAGASADM := ROUND(VGASADM * VPORRETEICA / 1000, 0);
                        v_importe_mon := f_round(NVL(VRETICAGASADM, 0) * v_itasa, v_cmoncontab);

                        vpasexec := 513;
                        BEGIN
                            INSERT INTO ctacoaseguro
                                    (smovcoa, ccompani, cimport, ctipcoa, cmovimi, imovimi, fmovimi, fcontab, cdebhab, fliqcia,
                                    pcescoa, nrecibo, smovrec, sseguro, imovimi_moncon, fcambio,cempres, cmoneda, cestado, ctipmov,
                                    sproduc, ccompapr, fcierre)
                            VALUES (xsmovcoa, Vccompani, VCIMPORT, xctipcoa, xtiprec, VRETICAGASADM, pfmovimi, NULL, VCDEBHAB, NULL,
                                    xpcescoa, pnrecibo, psmovrec, xsseguro, v_importe_mon, v_fcambio, NVL(pcempres, xcempres), xcmoneda, 1, 0,
                                    xsproduc, xccompapr, NULL);
                        EXCEPTION
                            WHEN OTHERS THEN
                                p_tab_error(f_sysdate, f_user, 'F_INSCTACOAS = ' || pnrecibo, vpasexec, 'INSERT INTO ctacoaseguro', SQLERRM);
                        END;

                    ELSE
--FIN JAAB 18/04/2018 QT 2057
--DE AQUÍ EN ADELANTE ES LA VERSIÓN ORIGINAL DE ESTA FUNCIÓN
                          xtipimp := 3;
                          vpasexec := 13;

                          IF xctipcoa = 1 THEN
                             ximporte := xitcon *(regcom.pcesion / 100) *(regcom.pcomcon / 100);
                          ELSE
                             ximporte := xitcon *(regcom.pcomcon / 100);
                          END IF;

                          -- Bug 0023183 - DCG - 14/08/2012 - LCOL_T020-COA-Circuit d'alta de propostes amb coasseguran
                          BEGIN
                             SELECT cmoneda
                               INTO xcmoneda
                               FROM seguros
                              WHERE sseguro = xsseguro;
                          EXCEPTION
                             WHEN OTHERS THEN
                                p_tab_error(f_sysdate, f_user, 'F_INSCTACOAS = ' || pnrecibo,
                                            vpasexec, 'NO_DATA_FOUND  Moneda', SQLERRM);
                          END;

                          v_fcambio := pfmovimi;

                          IF v_cmultimon = 1 THEN
                             vpasexec := 81;
                             error := pac_oper_monedas.f_datos_contraval(xsseguro, NULL, NULL,
                                                                         v_fcambio, 3, v_itasa,
                                                                         v_fcambio);

                             IF error <> 0 THEN
                                p_tab_error(f_sysdate, f_user, 'F_INSCTACOAS = ' || xsseguro,
                                            vpasexec, 'f_datos_contraval:' || error, SQLERRM);
                                RETURN error;
                             END IF;

                             v_importe_mon := f_round(NVL(ximporte, 0) * v_itasa, v_cmoncontab);
                          END IF;

                            -- Fin Bug 0023183
                          IF ximporte != 0 THEN
                             BEGIN
                                INSERT INTO ctacoaseguro
                                            (smovcoa, ccompani, cimport, ctipcoa, cmovimi,
                                             imovimi, fmovimi, fcontab,
                                             cdebhab,
                                             fliqcia, pcescoa, nrecibo, smovrec, sseguro,
                                             imovimi_moncon, fcambio, cempres,
                                             cmoneda, cestado, ctipmov, sproduc, ccompapr, fcierre)
                                     VALUES (xsmovcoa, regcom.ccompan, xtipimp, xctipcoa, xtiprec,
                                             ximporte, pfmovimi, NULL,
                                             DECODE(pcestrec,
                                                -- 16/07/2014   EDA  Bug 0032085/179140 Cuando el recibo se anula cambia el signo origen
                                                    2, DECODE(xsignocomis, 1, 2, 2, 1),
                                                    xsignocomis),
                                             NULL, xpcescoa, pnrecibo, psmovrec, xsseguro,
                                             v_importe_mon, v_fcambio, NVL(pcempres, xcempres),
                                             xcmoneda, 1, 0, xsproduc, xccompapr, NULL);
                             EXCEPTION
                                WHEN OTHERS THEN
                                   p_tab_error(f_sysdate, f_user, 'F_INSCTACOAS = ' || pnrecibo,
                                               vpasexec, 'INSERT INTO ctacoaseguro', SQLERRM);
                             END;
                          END IF;

                          vpasexec := 14;

                          --CONF-905 Inicio parempresas
                          IF v_calgastemi = 0 THEN
                             -- ****** Comision gastos *******
                             -- Buscamos el siguiente numero de secuencia
                             BEGIN
                                SELECT smovcoa.NEXTVAL
                                  INTO xsmovcoa
                                  FROM DUAL;
                             EXCEPTION
                                WHEN OTHERS THEN
                                   p_tab_error(f_sysdate, f_user, 'F_INSCTACOAS = ' || pnrecibo,
                                               vpasexec, 'OTHERS xsmovcoa 105575', SQLERRM);
                                   RETURN 105575;
                             -- Error al leer la secuencia (smovcoa de la Bds
                             END;

                             xtipimp := 4;

                             IF xctipcoa = 1 THEN
                                ximporte := xittotr *(regcom.pcesion / 100) *(regcom.pcomgas / 100);
                             ELSE
                                ximporte := xittotr *(regcom.pcomgas / 100);
                             END IF;

                             -- 0027260/0149814- JSV - 24/07/2013 - FIN
                             vpasexec := 15;
                             -- Bug 0023183 - DCG - 14/08/2012 - LCOL_T020-COA-Circuit d'alta de propostes amb coasseguran
                             v_fcambio := pfmovimi;

                             IF v_cmultimon = 1 THEN
                                vpasexec := 81;
                                error := pac_oper_monedas.f_datos_contraval(xsseguro, NULL, NULL,
                                                                            v_fcambio, 3, v_itasa,
                                                                            v_fcambio);

                                IF error <> 0 THEN
                                   p_tab_error(f_sysdate, f_user, 'F_INSCTACOAS = ' || xsseguro,
                                               vpasexec, 'f_datos_contraval:' || error, SQLERRM);
                                   RETURN error;
                                END IF;

                                v_importe_mon := f_round(NVL(ximporte, 0) * v_itasa, v_cmoncontab);
                             END IF;

                             -- Fin Bug 0023183
                             BEGIN
                                SELECT cmoneda
                                  INTO xcmoneda
                                  FROM seguros
                                 WHERE sseguro = xsseguro;
                             EXCEPTION
                                WHEN OTHERS THEN
                                   p_tab_error(f_sysdate, f_user, 'F_INSCTACOAS = ' || pnrecibo,
                                               vpasexec, 'NO_DATA_FOUND  Moneda', SQLERRM);
                             END;

                             IF ximporte != 0 THEN
                                BEGIN
                                   INSERT INTO ctacoaseguro
                                               (smovcoa, ccompani, cimport, ctipcoa, cmovimi,
                                                imovimi, fmovimi, fcontab,
                                                cdebhab,
                                                fliqcia, pcescoa, nrecibo, smovrec, sseguro,
                                                imovimi_moncon, fcambio, cempres,
                                                cmoneda, cestado, ctipmov, sproduc, ccompapr,
                                        -- Bug 0023183 - DCG - 14/08/2012 - LCOL_T020-COA-Circuit d'alta de propostes amb coasseguran
                                                                                             fcierre)
                                        -- BUG 0025357/0138513 - FAL - 19/02/2013
                                   VALUES      (xsmovcoa, regcom.ccompan, xtipimp, xctipcoa, xtiprec,
                                                ximporte, pfmovimi, NULL,
                                                DECODE(pcestrec,
                                        -- 16/07/2014   EDA  Bug 0032085/179140 Cuando el recibo se anula cambia el signo origen
                                                       2, DECODE(xsignocomis, 1, 2, 2, 1),
                                                       xsignocomis),
                                                NULL, xpcescoa, pnrecibo, psmovrec, xsseguro,
                                                v_importe_mon, v_fcambio, NVL(pcempres, xcempres),
                                                xcmoneda, 1, 0, xsproduc, xccompapr,
                                        -- Bug 0023183 - DCG - 14/08/2012 - LCOL_T020-COA-Circuit d'alta de propostes amb coasseguran
                                                NULL);
                                -- BUG 0025357/0138513 - FAL - 19/02/2013
                                EXCEPTION
                                   WHEN OTHERS THEN
                                      p_tab_error(f_sysdate, f_user, 'F_INSCTACOAS = ' || pnrecibo,
                                                  vpasexec, 'INSERT INTO ctacoaseguro', SQLERRM);
                                END;
                             END IF;
                          END IF;

                          --CONF-905 INICIO
                          --par_empresas
                          -- Buscamos el siguiente numero de secuencia
                          BEGIN
                             SELECT smovcoa.NEXTVAL
                               INTO xsmovcoa
                               FROM DUAL;
                          EXCEPTION
                             WHEN OTHERS THEN
                                p_tab_error(f_sysdate, f_user, 'F_INSCTACOAS = ' || pnrecibo,
                                            vpasexec, 'OTHERS xsmovcoa 105575', SQLERRM);
                                RETURN 105575;
                          END;

                          xtipimp := 6;

                          IF xctipcoa = 1 THEN
                             ximporte := xiretced *(regcom.pcesion / 100) *(regcom.pcomgas / 100);
                          ELSE
                             ximporte := xiretced *(regcom.pcomgas / 100);
                          END IF;

                          v_fcambio := pfmovimi;

                          IF v_cmultimon = 1 THEN
                             vpasexec := 81;
                             error := pac_oper_monedas.f_datos_contraval(xsseguro, NULL, NULL,
                                                                         v_fcambio, 3, v_itasa,
                                                                         v_fcambio);

                             IF error <> 0 THEN
                                p_tab_error(f_sysdate, f_user, 'F_INSCTACOAS = ' || xsseguro,
                                            vpasexec, 'f_datos_contraval:' || error, SQLERRM);
                                RETURN error;
                             END IF;

                             v_importe_mon := f_round(NVL(ximporte, 0) * v_itasa, v_cmoncontab);
                          END IF;

                          BEGIN
                             SELECT cmoneda
                               INTO xcmoneda
                               FROM seguros
                              WHERE sseguro = xsseguro;
                          EXCEPTION
                             WHEN OTHERS THEN
                                p_tab_error(f_sysdate, f_user, 'F_INSCTACOAS = ' || pnrecibo,
                                            vpasexec, 'NO_DATA_FOUND  Moneda', SQLERRM);
                          END;

                          IF ximporte != 0 THEN
                             BEGIN
                                INSERT INTO ctacoaseguro
                                            (smovcoa, ccompani, cimport, ctipcoa, cmovimi,
                                             imovimi, fmovimi, fcontab,
                                             cdebhab,
                                             fliqcia, pcescoa, nrecibo, smovrec, sseguro,
                                             imovimi_moncon, fcambio, cempres,
                                             cmoneda, cestado, ctipmov, sproduc, ccompapr,
                                    -- Bug 0023183 - DCG - 14/08/2012 - LCOL_T020-COA-Circuit d'alta de propostes amb coasseguran
                                                                                          fcierre)
                                     -- BUG 0025357/0138513 - FAL - 19/02/2013
                                VALUES      (xsmovcoa, regcom.ccompan, xtipimp, xctipcoa, xtiprec,
                                             ximporte, pfmovimi, NULL,
                                             DECODE(pcestrec,
                                -- 16/07/2014   EDA  Bug 0032085/179140 Cuando el recibo se anula cambia el signo origen
                                                    2, DECODE(xsignocomis, 1, 2, 2, 1),
                                                    xsignocomis),
                                             NULL, xpcescoa, pnrecibo, psmovrec, xsseguro,
                                             v_importe_mon, v_fcambio, NVL(pcempres, xcempres),
                                             xcmoneda, 1, 0, xsproduc, xccompapr,
                            -- Bug 0023183 - DCG - 14/08/2012 - LCOL_T020-COA-Circuit d'alta de propostes amb coasseguran
                                             NULL);
                             -- BUG 0025357/0138513 - FAL - 19/02/2013
                             EXCEPTION
                                WHEN OTHERS THEN
                                   p_tab_error(f_sysdate, f_user, 'F_INSCTACOAS = ' || pnrecibo,
                                               vpasexec, 'INSERT INTO ctacoaseguro', SQLERRM);
                             END;
                          END IF;

                          --Concep 82
                          BEGIN
                             SELECT smovcoa.NEXTVAL
                               INTO xsmovcoa
                               FROM DUAL;
                          EXCEPTION
                             WHEN OTHERS THEN
                                p_tab_error(f_sysdate, f_user, 'F_INSCTACOAS = ' || pnrecibo,
                                            vpasexec, 'OTHERS xsmovcoa 105575', SQLERRM);
                                RETURN 105575;
                          END;

                          xtipimp := 34;

                          IF xctipcoa = 1 THEN
                             ximporte := xisobcom *(regcom.pcomgas / 100);
                          ELSE
                             ximporte := xisobcom *(regcom.pcesion / 100) *(regcom.pcomgas / 100);
                          END IF;

                          v_fcambio := pfmovimi;

                          IF v_cmultimon = 1 THEN
                             vpasexec := 81;
                             error := pac_oper_monedas.f_datos_contraval(xsseguro, NULL, NULL,
                                                                         v_fcambio, 3, v_itasa,
                                                                         v_fcambio);

                             IF error <> 0 THEN
                                p_tab_error(f_sysdate, f_user, 'F_INSCTACOAS = ' || xsseguro,
                                            vpasexec, 'f_datos_contraval:' || error, SQLERRM);
                                RETURN error;
                             END IF;

                             v_importe_mon := f_round(NVL(ximporte, 0) * v_itasa, v_cmoncontab);
                          END IF;

                          BEGIN
                             SELECT cmoneda
                               INTO xcmoneda
                               FROM seguros
                              WHERE sseguro = xsseguro;
                          EXCEPTION
                             WHEN OTHERS THEN
                                p_tab_error(f_sysdate, f_user, 'F_INSCTACOAS = ' || pnrecibo,
                                            vpasexec, 'NO_DATA_FOUND  Moneda', SQLERRM);
                          END;

                          IF ximporte != 0 THEN
                             BEGIN
                                INSERT INTO ctacoaseguro
                                            (smovcoa, ccompani, cimport, ctipcoa, cmovimi,
                                             imovimi, fmovimi, fcontab,
                                             cdebhab,
                                             fliqcia, pcescoa, nrecibo, smovrec, sseguro,
                                             imovimi_moncon, fcambio, cempres,
                                             cmoneda, cestado, ctipmov, sproduc, ccompapr,
                                            -- Bug 0023183 - DCG - 14/08/2012 - LCOL_T020-COA-Circuit d'alta de propostes amb coasseguran
                                                                                          fcierre)
                                     -- BUG 0025357/0138513 - FAL - 19/02/2013
                                VALUES      (xsmovcoa, regcom.ccompan, xtipimp, xctipcoa, xtiprec,
                                             ximporte, pfmovimi, NULL,
                                             DECODE(pcestrec,
                                            -- 16/07/2014   EDA  Bug 0032085/179140 Cuando el recibo se anula cambia el signo origen
                                                    2, DECODE(xsignocomis, 1, 2, 2, 1),
                                                    xsignocomis),
                                             NULL, xpcescoa, pnrecibo, psmovrec, xsseguro,
                                             v_importe_mon, v_fcambio, NVL(pcempres, xcempres),
                                             xcmoneda, 1, 0, xsproduc, xccompapr,
                                            -- Bug 0023183 - DCG - 14/08/2012 - LCOL_T020-COA-Circuit d'alta de propostes amb coasseguran
                                             NULL);
                             -- BUG 0025357/0138513 - FAL - 19/02/2013
                             EXCEPTION
                                WHEN OTHERS THEN
                                   p_tab_error(f_sysdate, f_user, 'F_INSCTACOAS = ' || pnrecibo,
                                               vpasexec, 'INSERT INTO ctacoaseguro', SQLERRM);
                             END;
                          END IF;

                          --concep83
                          BEGIN
                             SELECT smovcoa.NEXTVAL
                               INTO xsmovcoa
                               FROM DUAL;
                          EXCEPTION
                             WHEN OTHERS THEN
                                p_tab_error(f_sysdate, f_user, 'F_INSCTACOAS = ' || pnrecibo,
                                            vpasexec, 'OTHERS xsmovcoa 105575', SQLERRM);
                                RETURN 105575;
                          END;

                          xtipimp := 35;

                          IF xctipcoa = 1 THEN
                             ximporte := xiretsob *(regcom.pcesion / 100) *(regcom.pcomgas / 100);
                          ELSE
                             ximporte := xiretsob *(regcom.pcomgas / 100);
                          END IF;

                          v_fcambio := pfmovimi;

                          IF v_cmultimon = 1 THEN
                             vpasexec := 81;
                             error := pac_oper_monedas.f_datos_contraval(xsseguro, NULL, NULL,
                                                                         v_fcambio, 3, v_itasa,
                                                                         v_fcambio);

                             IF error <> 0 THEN
                                p_tab_error(f_sysdate, f_user, 'F_INSCTACOAS = ' || xsseguro,
                                            vpasexec, 'f_datos_contraval:' || error, SQLERRM);
                                RETURN error;
                             END IF;

                             v_importe_mon := f_round(NVL(ximporte, 0) * v_itasa, v_cmoncontab);
                          END IF;

                          BEGIN
                             SELECT cmoneda
                               INTO xcmoneda
                               FROM seguros
                              WHERE sseguro = xsseguro;
                          EXCEPTION
                             WHEN OTHERS THEN
                                p_tab_error(f_sysdate, f_user, 'F_INSCTACOAS = ' || pnrecibo,
                                            vpasexec, 'NO_DATA_FOUND  Moneda', SQLERRM);
                          END;

                          IF ximporte != 0 THEN
                             BEGIN
                                INSERT INTO ctacoaseguro
                                            (smovcoa, ccompani, cimport, ctipcoa, cmovimi,
                                             imovimi, fmovimi, fcontab,
                                             cdebhab,
                                             fliqcia, pcescoa, nrecibo, smovrec, sseguro,
                                             imovimi_moncon, fcambio, cempres,
                                             cmoneda, cestado, ctipmov, sproduc, ccompapr,
                                            -- Bug 0023183 - DCG - 14/08/2012 - LCOL_T020-COA-Circuit d'alta de propostes amb coasseguran
                                                                                          fcierre)
                                            -- BUG 0025357/0138513 - FAL - 19/02/2013
                                VALUES      (xsmovcoa, regcom.ccompan, xtipimp, xctipcoa, xtiprec,
                                             ximporte, pfmovimi, NULL,
                                             DECODE(pcestrec,
                                                -- 16/07/2014   EDA  Bug 0032085/179140 Cuando el recibo se anula cambia el signo origen
                                                    2, DECODE(xsignocomis, 1, 2, 2, 1),
                                                    xsignocomis),
                                             NULL, xpcescoa, pnrecibo, psmovrec, xsseguro,
                                             v_importe_mon, v_fcambio, NVL(pcempres, xcempres),
                                             xcmoneda, 1, 0, xsproduc, xccompapr,
                                            -- Bug 0023183 - DCG - 14/08/2012 - LCOL_T020-COA-Circuit d'alta de propostes amb coasseguran
                                             NULL);
                                            -- BUG 0025357/0138513 - FAL - 19/02/2013
                             EXCEPTION
                                WHEN OTHERS THEN
                                   p_tab_error(f_sysdate, f_user, 'F_INSCTACOAS = ' || pnrecibo,
                                               vpasexec, 'INSERT INTO ctacoaseguro', SQLERRM);
                             END;
                          END IF;

                          --concep85
                          BEGIN
                             SELECT smovcoa.NEXTVAL
                               INTO xsmovcoa
                               FROM DUAL;
                          EXCEPTION
                             WHEN OTHERS THEN
                                p_tab_error(f_sysdate, f_user, 'F_INSCTACOAS = ' || pnrecibo,
                                            vpasexec, 'OTHERS xsmovcoa 105575', SQLERRM);
                                RETURN 105575;
                          END;

                          xtipimp := 36;

                          IF xctipcoa = 1 THEN
                             ximporte := xicascom *(regcom.pcesion / 100) *(regcom.pcomgas / 100);
                          ELSE
                             ximporte := xicascom *(regcom.pcomgas / 100);
                          END IF;

                          v_fcambio := pfmovimi;

                          IF v_cmultimon = 1 THEN
                             vpasexec := 81;
                             error := pac_oper_monedas.f_datos_contraval(xsseguro, NULL, NULL,
                                                                         v_fcambio, 3, v_itasa,
                                                                         v_fcambio);

                             IF error <> 0 THEN
                                p_tab_error(f_sysdate, f_user, 'F_INSCTACOAS = ' || xsseguro,
                                            vpasexec, 'f_datos_contraval:' || error, SQLERRM);
                                RETURN error;
                             END IF;

                             v_importe_mon := f_round(NVL(ximporte, 0) * v_itasa, v_cmoncontab);
                          END IF;

                          BEGIN
                             SELECT cmoneda
                               INTO xcmoneda
                               FROM seguros
                              WHERE sseguro = xsseguro;
                          EXCEPTION
                             WHEN OTHERS THEN
                                p_tab_error(f_sysdate, f_user, 'F_INSCTACOAS = ' || pnrecibo,
                                            vpasexec, 'NO_DATA_FOUND  Moneda', SQLERRM);
                          END;

                          IF ximporte != 0 THEN
                             BEGIN
                                INSERT INTO ctacoaseguro
                                            (smovcoa, ccompani, cimport, ctipcoa, cmovimi,
                                             imovimi, fmovimi, fcontab,
                                             cdebhab,
                                             fliqcia, pcescoa, nrecibo, smovrec, sseguro,
                                             imovimi_moncon, fcambio, cempres,
                                             cmoneda, cestado, ctipmov, sproduc, ccompapr,
                                        -- Bug 0023183 - DCG - 14/08/2012 - LCOL_T020-COA-Circuit d'alta de propostes amb coasseguran
                                                                                          fcierre)
                                     -- BUG 0025357/0138513 - FAL - 19/02/2013
                                VALUES      (xsmovcoa, regcom.ccompan, xtipimp, xctipcoa, xtiprec,
                                             ximporte, pfmovimi, NULL,
                                             DECODE(pcestrec,
                                        -- 16/07/2014   EDA  Bug 0032085/179140 Cuando el recibo se anula cambia el signo origen
                                                    2, DECODE(xsignocomis, 1, 2, 2, 1),
                                                    xsignocomis),
                                             NULL, xpcescoa, pnrecibo, psmovrec, xsseguro,
                                             v_importe_mon, v_fcambio, NVL(pcempres, xcempres),
                                             xcmoneda, 1, 0, xsproduc, xccompapr,
                                    -- Bug 0023183 - DCG - 14/08/2012 - LCOL_T020-COA-Circuit d'alta de propostes amb coasseguran
                                             NULL);
                             -- BUG 0025357/0138513 - FAL - 19/02/2013
                             EXCEPTION
                                WHEN OTHERS THEN
                                   p_tab_error(f_sysdate, f_user, 'F_INSCTACOAS = ' || pnrecibo,
                                               vpasexec, 'INSERT INTO ctacoaseguro', SQLERRM);
                             END;
                          END IF;

                          --concep84
                          BEGIN
                             SELECT smovcoa.NEXTVAL
                               INTO xsmovcoa
                               FROM DUAL;
                          EXCEPTION
                             WHEN OTHERS THEN
                                p_tab_error(f_sysdate, f_user, 'F_INSCTACOAS = ' || pnrecibo,
                                            vpasexec, 'OTHERS xsmovcoa 105575', SQLERRM);
                                RETURN 105575;
                          END;

                          xtipimp := 41;

                          IF xctipcoa = 1 THEN
                             ximporte := xreticom *(regcom.pcesion / 100) *(regcom.pcomgas / 100);
                          ELSE
                             ximporte := xreticom *(regcom.pcomgas / 100);
                          END IF;

                          v_fcambio := pfmovimi;

                          IF v_cmultimon = 1 THEN
                             vpasexec := 81;
                             error := pac_oper_monedas.f_datos_contraval(xsseguro, NULL, NULL,
                                                                         v_fcambio, 3, v_itasa,
                                                                         v_fcambio);

                             IF error <> 0 THEN
                                p_tab_error(f_sysdate, f_user, 'F_INSCTACOAS = ' || xsseguro,
                                            vpasexec, 'f_datos_contraval:' || error, SQLERRM);
                                RETURN error;
                             END IF;

                             v_importe_mon := f_round(NVL(ximporte, 0) * v_itasa, v_cmoncontab);
                          END IF;

                          BEGIN
                             SELECT cmoneda
                               INTO xcmoneda
                               FROM seguros
                              WHERE sseguro = xsseguro;
                          EXCEPTION
                             WHEN OTHERS THEN
                                p_tab_error(f_sysdate, f_user, 'F_INSCTACOAS = ' || pnrecibo,
                                            vpasexec, 'NO_DATA_FOUND  Moneda', SQLERRM);
                          END;

                          IF ximporte != 0 THEN
                             BEGIN
                                INSERT INTO ctacoaseguro
                                            (smovcoa, ccompani, cimport, ctipcoa, cmovimi,
                                             imovimi, fmovimi, fcontab,
                                             cdebhab,
                                             fliqcia, pcescoa, nrecibo, smovrec, sseguro,
                                             imovimi_moncon, fcambio, cempres,
                                             cmoneda, cestado, ctipmov, sproduc, ccompapr,
                                -- Bug 0023183 - DCG - 14/08/2012 - LCOL_T020-COA-Circuit d'alta de propostes amb coasseguran
                                                                                          fcierre)
                                     -- BUG 0025357/0138513 - FAL - 19/02/2013
                                VALUES      (xsmovcoa, regcom.ccompan, xtipimp, xctipcoa, xtiprec,
                                             ximporte, pfmovimi, NULL,
                                             DECODE(pcestrec,
                                -- 16/07/2014   EDA  Bug 0032085/179140 Cuando el recibo se anula cambia el signo origen
                                                    2, DECODE(xsignocomis, 1, 2, 2, 1),
                                                    xsignocomis),
                                             NULL, xpcescoa, pnrecibo, psmovrec, xsseguro,
                                             v_importe_mon, v_fcambio, NVL(pcempres, xcempres),
                                             xcmoneda, 1, 0, xsproduc, xccompapr,
                                -- Bug 0023183 - DCG - 14/08/2012 - LCOL_T020-COA-Circuit d'alta de propostes amb coasseguran
                                             NULL);
                             -- BUG 0025357/0138513 - FAL - 19/02/2013
                             EXCEPTION
                                WHEN OTHERS THEN
                                   p_tab_error(f_sysdate, f_user, 'F_INSCTACOAS = ' || pnrecibo,
                                               vpasexec, 'INSERT INTO ctacoaseguro', SQLERRM);
                             END;
                          END IF;
                          --HASTA AQUÍ ES LA VERSIÓN ORIGINAL DE ESTA FUNCIÓN
                    END IF;--<> 24 NO CONFIANZA
               --CONF-905 FIN
               END IF;   --IF xtiprec NOT IN(13, 15) THEN
            --BUG 0025357: DCT: 21/12/2012: INICIO: LCOL_T020-LCOL-COA Nuevos conceptos Cuenta Coaseguro.
            EXCEPTION
               WHEN DUP_VAL_ON_INDEX THEN
                  RETURN 105579;   -- registre duplicat en CTACOASEGURO
               WHEN OTHERS THEN
                  RETURN 105578;   -- Error a l' inserir a CTACOASEGURO
            END;

            FETCH cur_compania
             INTO regcom;
         END LOOP;

         -- BUG 21546_108724 - 13/02/2012 - JLTS - Cierre de posibles cursores abiertos.
         IF cur_compania%ISOPEN THEN
            CLOSE cur_compania;
         END IF;

         RETURN 0;
      ELSE
         RETURN error;
      END IF;
   ELSE
      -- Cualquiera de los otros casos. No tenemos que hacer nada
      RETURN 0;
   END IF;

-- BUG 21546_108724 - 07/02/2012 - JLTS - Cierre de posibles cursores abiertos, se adiciona EXCEPTION
EXCEPTION
   WHEN OTHERS THEN
      IF cur_compania%ISOPEN THEN
         CLOSE cur_compania;
      END IF;

      RETURN 140999;
END f_insctacoas;

/

  GRANT EXECUTE ON "AXIS"."F_INSCTACOAS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_INSCTACOAS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_INSCTACOAS" TO "PROGRAMADORESCSI";
