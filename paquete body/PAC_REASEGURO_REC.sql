--------------------------------------------------------
--  DDL for Package Body PAC_REASEGURO_REC
--------------------------------------------------------

CREATE OR REPLACE PACKAGE BODY "PAC_REASEGURO_REC" IS
   /******************************************************************************
      NOMBRE:     pac_reaseguro_rec
      PROP?SITO:     Proceso batch mensual que realiza el Border? de Reaseguro

      REVISIONES:
      Ver        Fecha        Autor             Descripci?n
      ---------  ----------  -------  ------------------------------------
      1.0        XX/XX/XXXX   XXX     1. Creaci?n del package.
      2.0        27/04/2009   APD     2. Bug 9685 - en lugar de coger la actividad de la tabla seguros, llamar a la
                                                    funci?n pac_seguros.ff_get_actividad
      3.0        13/05/2009   AVT     3. 0009549: CRE - Reaseguro de ahorro.
      4.0        06/07/2009   FAL     4. Bug 10637: Se a?ade que el modo de reaseguro sea cesi?n por prima anual para siniestros
      5.0        31/07/2009   FAL     5. Bug 10844: Se corrige para se agigne la sobreprima en el cierre
      6.0        07/09/2009   FAL     6. Bug 11051: CRE - Pagos sin cesiones. Creaci?n p_genera_ces_pago y f_genera_ces_pago para
                                                    generar cesion de pagos de siniestros.
      7.0        16/09/2009   FAL     7. Bug 11051: CRE - Pagos sin cesiones. Informar camps de comptabilitat a partir de cesionesrea
                                      8. Bug 11100: CRE046 - Revisi?n de cesionesrea. Crida a la pac_cesionesrea.f_gar_rea per si garantia reasegurable
      8.0        05/10/2009   FAL     9. Bug 11350: CRE - La tabla LIQRESREAAUX contemplar? provisi?n aunque el pago este creado.
                                                    Se a?ade f_reamovpagos que realiza el c?lculo de reservas a nivel de pago para aquellos pagos a?n pendientes
                                                    Se a?ade TRUNC al ce.fefecto del cursor cur_ces para incluir en el cierre reembolsos con misma fecha efecto
      9.0        02/11/2009   APD     10. Bug 11595: CEM - Siniestros. Adaptaci?n al nuevo m?dulo de siniestros
      10.        01/12/2009   NMM     11. 11845.CRE - Ajustar reasseguran?a d'estalvi.
      11.        22/04/2010   AVT     12. 14203: CEM800 - Se detectan p?lizas migradas sin reaseguro
      12.        14/05/2010   AVT     13. 0014536: CRE200 - Reaseguro: Se requiere que un contrato se pueda utilizar
                                          en varias agrupaciones de producto
      13.        03/06/2010   AVT     14. 14833: CEM800 - Reaseguro: Modificaci?n de la funci?n f_liquidaresreas
      13         23/06/2010   AVT     15. 15173: CRE - Error en el c?lcul de comissions de reasseguran?a
      14         20/12/2010   JGR     16. 17059: CRE800 - Revisi? de errors en Tancament de Nov 2010
      15         23/02/2011   JGR     17. 17672: CEM800 - Contracte Reaseguro 2011 - A?adir nuevo par?metro w_cdetces
      16.0       11/04/2011   APD     18. 0018225: AGM704 - Realizar la modificaci?n de precisi?n el cagente
      17.0       17/10/2011   JMP     19. 0019027: LCOL760 - Tamany del camp CRAMO
      18.0       02/11/2011   JMP     20. 0018423: LCOL000 - Multimoneda
      19.0       21/01/2011   JGR     21. 0021012: LCOL_A002-Reaseguro: no se puede cerrar el mes de diciembre en UAT - Nota: 104627
      20.0       15/02/2011   JGR     22. 0021342: LCOL_A002-Error en cierre previo reaseguro entorno capacitacion - Nota: 0107223
      21.0       15/02/2011   JMP     23. 0021102/107455: LCOL_F001-UAT - Contabilidad
      22.0       23/02/2012   AVT     24. 0021398: LCOL_A002-No hay cesion de comision facultativa
      23.0       04/04/2012   JMP     25. Bug 20836/111077: CRE800: Error cessions reemborsaments
      24.0       14/05/2012   AVT     26. 0022237: LCOL_A002-Incidencias de QT sobre el reaseguro proporcional: Reservas
      25.0       25/05/2012   AVT     27. 0022076: LCOL_A004-Mantenimientos de cuenta tecnica del reaseguro y del coaseguro
      26.0       13/06/2012   AVT     28. 0022076: afegit el deslg?s per p?lissa i sinistre separant el c?lcul de la MOVCTAAUX: f_llenar_movcta_aux
      27.0       01/08/2012   AVT     29. 022799: AGM800-Cuenta tecnica del reaseguro
      28.0       06/09/2012   AVT     30. 0023618: AGM101-Definici?n contrato reaseguro explotaciones agropecuarias.
      29.0       26/09/2012   AVT     31. 0023771: AGM800-Modificaciones en la Cta. Tecnica
      30.0       13/11/2012   AVT     32. 0024109: AGM800-Contabilidad de Septiembre. Falta una cuenta y se duplica otra
      31.0       11/01/2013   AVT     33. 0024463: LCOL_A004-Companyies Vida/No Vida de LCOL als Tancaments REA
      32.0       18/03/2013   AFM     34. 0025803: RSA001 - Ampliar los decimales que utiliza iAXIS
      33.0       20/03/2013   KBR     35. 0025822: RSA003 - Se debe incluir la historificación de los impuestos y rating en las cias reaseguadoas
      34.0       21/03/2012   KBR     36. 0026252: RSA003 - Realizar la cesión del reaseguro por recibo cobrado
      35.0       05/04/2013   KBR     37. 0025373/0136481: AGM800 - Revisión cuenta técnica    (Cálculo de fechas en reembolso de reservas)
      36.0       24/04/2013   KBR     38. 0026252/0143094: RSA003 - Realizar la cesión del reaseguro por recibo cobrado (Ajustes)
      37.0       10/06/2013   AVT     39. 0026800/0146275: RSA701-Informes reaseguro
      38.0       17/06/2013   ETM     39.0025860: (POSDE400)-Desarrollo-GAPS Reaseguro, Coaseguro -Id 81 - Monitorizacion tasas variables/comisiones (Fase 1)
      39.0       25/07/2013   JRH     39.0026444: (POSDE400)-Desarrollo-GAPS Reaseguro, Coaseguro -Id 150 -entidad economica de las agrupaciones (Fase3)
      40.0       10/09/2013   DCT     40.0023830: LCOL_A004 Ajustar el Manteniment dels Comptes de Reasseguranca (Nota: 22076/0123753)
      41.0       18/10/2013   FAL     41. 0025373: AGM800 - Revisión cuenta técnica
      42.0       11/12/2013   KBR     42. 0028991: (POSPG400)-Parametrización de los siniestros en Cúmulo.
      43.0       18/02/2014   DCT     43. 0030203: LCOL_A004-Qtracker: 8993, 8995, 9865, 8987, 8991 Liquidaci?n de saldos
      44.0       25/03/2014   KBR     44. 0028991: (POSPG400)-Parametrización de los siniestros en Cúmulo.
      45.0       07/05/2014   ERP     45. 0025373:  Se cambia el parametro tipo, pasandole un 2 en lugar de un 3, para el calculo de w_divisoranual
      46.0       15/05/2014   AGG     46. 0026622: POSND100-(POSDE400)-Desarrollo-GAPS Reaseguro, Coaseguro -Id 97 - Comisiones calculadas solo sobre extraprima
      47.0       27/05/2014   EDA     47. 0031477: LCOL_F002-0012644: Proceso cierre reaseguro.
      48.0       17/06/2014   JMV     48. 0028475: LCOL_A004-Qtracker: 11697:
      49.0       03/07/2014   AGG     49. 0026622: POSND100-(POSDE400)-Desarrollo-GAPS Reaseguro, Coaseguro -Id 97 - Comisiones calculadas solo sobre extraprima
      50.0       08/07/2014   SHA     50. 0028475: LCOL_A004-Qtracker: 9549: Revision del reporte de la Cuenta T?cnica Reaseguro Automatio Cedido- Contratos No Proporcionales
      51.0       14/07/2014   EDA     51. 0031477: LCOL_F002-0012644: Inclusión de pólizas con cumulos en los reembolsos - depositos
      52.0       31/12/2014   KBR     52. 0034064: Error en Proceso de cierre de Mes de Reaseguros (bug hermano interno)
      53.0       23/03/2015   KBR     53. 0033244: LCOL_PROD-Bug para tratar qtrackers de produccion - Reaseguro / Coaseguro (QTs 17287, 16809)
      54.0       08/05/2015   KBR     54. 0033295: LCOLF3BREA-Revisión temas Fase 3B - Reaseguro / Coaseguro
      55.0       22/05/2015   CJMR    55. 0033158: Actualización campo CCORRED en los cierres de Reaseguro
      56.0       19/11/2015   FAL     56. 0038439: INCIDENCIA EN LA CARGA DE FICHEROS DE CONTABILIDAD (bug hermano interno)
	  57.0       08/12/2019   FEPP    57.0 IAXIS-4821 :MODIFICACIONES FACULTATIVAS LA INFORMACION DE FACULTATIVOS NO PASSA A LA TABLA REASEGURO
	  58.0       18/11/2019   INFORCOL 58.0 Reaseguro Fase 1 Sprint 1
	  59.0       23/12/2019   INFORCOL 59.0 Reaseguro Fase 1 Sprint 3 Se inhabilita la comision escalonada debido a que presenta error para el pre-cierre de reaseguro y este tipo de comision no es utilizada en Confianza
	  60.0       15/01/2020   INFORCOL 60.0 Reaseguro Ajuste error pre-cierre reaseguro (no llena las tablas temporales aux)
	  61.0       12/03/2020   INFORCOL 61.0 Reaseguro Deposito en prima ajuste deposito retenido a cargo de la compania
      62.0       27/04/2020   JLTS    62. IAXIS-13133: Ajuste de la funcion de LLENAR_BORDERO_AUX e inclusión del parámetro 2 de f_provisiogar
      63.0       22/05/2020   MPC     63. IAXIS-13164: Funcionalidad llenado de tabla LIQRESREAAUXDET Movimientos cesiones cedidas.
      64.0       27/04/2020   JLTS    64. IAXIS-13133: Ajuste de la funcion de F_REAMOVPAGOS, exclusión de algunas condiciones.
      65.0       27/05/2020   MPC     65. IAXIS-13164: Funcionalidad llenado de tabla LIQRESREAAUXDET Movimientos cesiones cedidas.
   ******************************************************************************/
   vg_nmesven     NUMBER;
   vg_nanyven     NUMBER;
   vany           NUMBER(4) := 0;
   error          NUMBER(7) := 0;
   vramo          NUMBER(6) := 0;
   vtipram        NUMBER(2) := 0;
   vplocali       NUMBER;
   vitotal        liqresreaaux.itotal%TYPE;   -- BUG 0025803 NUMBER(14, 2) := 0;   -- Importe Total
   vicompa        liqresreaaux.icompan%TYPE;   -- BUG 0025803 NUMBER(14, 2) := 0;   -- Importe compa?ia
   v_traza        NUMBER(4);
   v_cmonpol      codidivisa.cmoneda%TYPE;
   v_cesdet       liqresreaauxdet%ROWTYPE; --BUG 13164 22/05/2020 MPC Se extrae detalle analizado de tabla sin_tramita_reservadet.

-------------------------------------------------------------------------------------------------
   FUNCTION f_llenar_movcta_aux(
      pcempres IN NUMBER,
      pmes IN NUMBER,
      pany IN NUMBER,
      pproces IN NUMBER)
      RETURN NUMBER IS
      /***********************************************************************************************
          nova funci? interna que agrupa el trasp?s dels c?lculs del bordero als comptes t?cnics
          -- CONCEPTES CALCULATS -- VF: 128 --
          01 - Primes
          02 - Comissions
          03/52 - Reserves
          04 - Interessos s/reserves
          05 - Pagaments de sinistres
          06/51 - Reemborsament de reserves
          07 - Retenci? sobre els interessis (depenent del Pa?s)
          09 - Primes anulades
          12 - Participaci? de beneficis ??? PENDENT !!! --> ctapbaux
          25 - Reserves de sinistres --> liqresreaaux
          14 - Regul. comissions Variable
          24 - Regul. comissions Variable Provisional
      ************************************************************************************************/
      perror         NUMBER := 0;
      w_nnumlin      NUMBER := 0;
      psql           NUMBER := 0;
      w_cestado      NUMBER := 0;
      w_cdebhab      movctaaux.cdebhab%TYPE;   -- BUG 0025803  NUMBER := 0;
      w_cconcep      movctaaux.cconcep%TYPE;   -- BUG 0025803  NUMBER := 0;
      w_reserva      NUMBER := 0;
      pfin           DATE;
      pini           DATE;
      w_reemb        movctaaux.iimport%TYPE;   -- BUG 0025803  NUMBER(13, 2);
      w_int          movctaaux.iimport%TYPE;   -- BUG 0025803  NUMBER(13, 2);
      existe         NUMBER(2);
      w_preten       cuadroces.pintres%TYPE;   -- BUG 0025803  NUMBER(7, 5);
      w_reten        movctaaux.iimport%TYPE;   -- BUG 0025803  NUMBER(13, 2);
      w_fcierre      movctaaux.fcierre%TYPE;   -- BUG 0025803  DATE
      w_ctadet       NUMBER(1);
      w_freini       NUMBER(2);   -- 22076 AVT 18/06/2012
      w_periodo_rea  parempresas.nvalpar%TYPE;   -- 25373 KBR 18/03/2013
      v_pctpart      clausulas_reas_det.pctpart%TYPE;   -- 25822 KBR 19/03/2013
      v_reserv_tax   movctaaux.iimport%TYPE;   -- 25822 KBR 19/03/2013
      v_prima_anual  movctatecnica.iimport%TYPE;   --BUG 25860 ETM
      v_pagos_sin_anual movctatecnica.iimport%TYPE;   --BUG 25860 ETM
      v_comis_anual  movctatecnica.iimport%TYPE;   --BUG 25860 ETM
      v_siniestralitat NUMBER(13, 2);   --BUG 25860 ETM
      v_reserva_anual liqresreaaux.icompan%TYPE;   --BUG 25860 ETM
      v_pcomisi      clausulas_reas_det.pctmin%TYPE;   --BUG 25860 ETM
      v_comision_esc NUMBER(13, 2);   --BUG 25860 ETM
      v_comision_esc_total NUMBER(13, 2);   --BUG 25860 ETM
      w_pcomias      NUMBER(13, 2);   --BUG 25860 ETM
      w_cempres      NUMBER;
      codi_error     NUMBER := 0;
      w_dias         NUMBER;
      w_divisoranual NUMBER;
      v_ccorred      NUMBER;

      CURSOR reaseg(wempresa IN NUMBER, wproces IN NUMBER, wctadet IN NUMBER) IS
         SELECT   r.cempres, r.fcierre, r.sproces, r.scontra, r.nversio, r.ctramo, r.ccompani,
                  r.sfacult, pcesion, sproduc, s.ccompani ccompapr,   -- 24463 AVT 11/01/2013 s'afegeix la Cia pr¨°pia
                  DECODE(wctadet, 1, DECODE(r.ctramo, 5, r.npoliza, 0), 0) npoliza,
                  DECODE(wctadet, 1, DECODE(r.ctramo, 5, r.ncertif, 0), 0) ncertif,
                  DECODE(wctadet, 1, DECODE(r.cgenera, 2, nsinies, 0), 0) nsinies,
                  DECODE(r.cgenera, 2, 0, 6, 2, 1) cmotces, SUM(icesion) icesion,
                  SUM(icomisi) icomisi, SUM(idtosel) idtosel,
                  SUM(iretencionf) iretencionf --CONFCC-5
             FROM reaseguroaux r, seguros s
            WHERE r.sproces = wproces
              AND r.cempres = wempresa
              AND s.sseguro = r.sseguro
              AND r.ctramo < 6   -- AGG 03/04/2014 S¨®lo trmamos proporcionales
         GROUP BY r.cempres, r.fcierre, r.sproces, r.scontra, r.nversio, r.ctramo, r.ccompani,
                  r.sfacult, pcesion, sproduc,
                  DECODE(wctadet, 1, DECODE(r.ctramo, 5, r.npoliza, 0), 0),
                  DECODE(wctadet, 1, DECODE(r.ctramo, 5, r.ncertif, 0), 0),
                  DECODE(wctadet, 1, DECODE(r.cgenera, 2, nsinies, 0), 0),
                  DECODE(r.cgenera, 2, 0, 6, 2, 1),
                  s.ccompani   -- 24463 AVT 11/01/2013 s'afegeix la Cia pr¨°pia
           HAVING SUM(icesion) <>
                     0   --KBR 11/12/2013 Para que no se inserten registros con importe 0 en movctatecnica
         ORDER BY r.scontra, r.nversio, r.ctramo, r.ccompani, r.sfacult;

      CURSOR cur_cuadroces(
         wscontra NUMBER,
         wnversio NUMBER,
         wctramo NUMBER,
         wsfacult NUMBER,
         wcia NUMBER) IS
         SELECT cc.ccorred, cc.preserv, cc.ctramocomision
           FROM cuadroces cc
          WHERE scontra = wscontra
            AND nversio = wnversio
            AND ctramo = wctramo
            AND ccompani = wcia
            AND ctramo <> 5
         UNION
		 -- INICIO INFORCOL 12-03-2020
         SELECT ccorred, presrea/*preserv*/, ctramocomision
		 -- FIN INFORCOL 12-03-2020
           FROM cuacesfac
          WHERE sfacult = wsfacult
            AND ccompani = wcia;

      CURSOR cur_frac_reemb(wcempres IN NUMBER, wctadet IN NUMBER) IS
         SELECT DISTINCT c.scontra, c.nversio, c.ctramo,   -- 0 sfacult, -- 27/05/2014 EDA Bugs 31477
                                                        0 npoliza, 0 ncertif, c.ccompani,
                         NVL(cfreres, 12) cfreres, pintres, cintres, co.pimpint
                    FROM cuadroces c, codicontratos ct, companias co
                   WHERE c.scontra = ct.scontra
                     AND ct.ctiprea IN(1, 2)
                     AND c.ccompani = co.ccompani
                     AND ct.cempres = wcempres
                     AND c.ctramo < 6   -- AGG 03/04/2014 Sólo trmamos proporcionales
         UNION
         SELECT DISTINCT ct.scontra, ct.nversio, 5 ctramo,   -- c.sfacult, -- 27/05/2014 EDA Bugs 31477
                         DECODE(wctadet, 1, s.npoliza, 0) npoliza,
                         DECODE(wctadet, 1, s.ncertif, 0) ncertif, c.ccompani,
                         NVL(cfreres, 12) cfreres, pintres, cintres, co.pimpint
                    FROM cuacesfac c, cuafacul ct, seguros s, companias co
                   WHERE c.sfacult = ct.sfacult
                     AND ct.sseguro = s.sseguro
                     AND c.ccompani = co.ccompani
                     AND s.cempres = wcempres
         UNION
         SELECT DISTINCT ct.scontra, ct.nversio, 5 ctramo,   -- 14/07/2014 EDA 31477 Inclusión de pólizas con cumulos en los reembolsos - depositos. QT 12644
                         DECODE(wctadet, 1, s.npoliza, 0) npoliza,
                         DECODE(wctadet, 1, s.ncertif, 0) ncertif, c.ccompani,
                         NVL(cfreres, 12) cfreres, pintres, cintres, co.pimpint
                    FROM cuacesfac c, cuafacul ct, reariesgos r, seguros s, companias co
                   WHERE c.sfacult = ct.sfacult
                     AND ct.scumulo = r.scumulo
                     AND r.sseguro = s.sseguro
                     AND c.ccompani = co.ccompani
                     AND s.cempres = wcempres
                ORDER BY scontra, ctramo;

      CURSOR cur_reemb(
         wcempres NUMBER,
         wscontra IN NUMBER,
         wnversio IN NUMBER,
         wctramo IN NUMBER,
         wccompani IN NUMBER,
         wnpoliza IN NUMBER,
         wncertif IN NUMBER,
         wctadet IN NUMBER,
         wini DATE,
         wfin DATE) IS
         SELECT   m.ccompani, m.scontra, m.nversio, m.ctramo, m.cdebhab, m.iimport, m.cestado,
                  m.nnumlin, m.sproduc, m.npoliza, m.ncertif, m.ccompapr, m.ccorred
             FROM movctatecnica m
            WHERE m.scontra = wscontra
              AND m.nversio = wnversio
              AND m.ccompani = wccompani
              AND(m.ctramo = 5
                  AND DECODE(wctadet, 1, m.npoliza, 0) = wnpoliza
                  AND DECODE(wctadet, 1, m.ncertif, 0) = wncertif
                  OR m.ctramo < 5)
              AND m.ctramo = wctramo
              AND m.cconcep = 03
              AND m.fmovimi BETWEEN wini AND wfin
         ORDER BY m.scontra, m.nversio, m.ctramo;

      CURSOR cur_reserves(wempresa IN NUMBER, wproces IN NUMBER, wctadet IN NUMBER) IS
         SELECT   r.cempres, r.fcierre, r.sproces, r.scontra, r.nversio, r.ctramo, r.ccompani,
                  pcompan pcesion, sproduc, s.ccompani ccompapr,
                  DECODE(wctadet, 1, nsinies, 0) nsinies, SUM(icompan) ires
             FROM liqresreaaux r, seguros s
            WHERE r.cempres = wempresa
              AND r.sseguro = s.sseguro
              AND r.sproces = wproces
              AND r.ctramo < 6   -- AGG 03/04/2014 S¨®lo trmamos proporcionales
         GROUP BY r.cempres, r.fcierre, r.sproces, r.scontra, r.nversio, r.ctramo, r.ccompani,
                  pcompan, sproduc, DECODE(wctadet, 1, nsinies, 0), s.ccompani;
   BEGIN
      v_traza := 0;
      w_ctadet := pac_parametros.f_parempresa_n(pcempres, 'CTACES_DET');
      v_traza := 1;

------------------------------------
-- Dades del tancament: REASEGURO --
------------------------------------
      FOR reg IN reaseg(pcempres, pproces, NVL(w_ctadet, 0)) LOOP
         v_traza := 2;

         IF perror = 0 THEN
            BEGIN
               SELECT NVL(MAX(nnumlin), 0)
                 INTO w_nnumlin
                 FROM movctaaux
                WHERE scontra = reg.scontra
                  AND nversio = reg.nversio
                  AND ctramo = reg.ctramo
                  AND ccompani = reg.ccompani
                  AND sproduc = reg.sproduc   -- xxxxx
                  AND NVL(npoliza, 0) = NVL(reg.npoliza, 0)
                  AND NVL(ncertif, 0) = NVL(reg.ncertif, 0)
                  AND NVL(nsinies, 0) = NVL(reg.nsinies, 0);
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  w_nnumlin := 1;
               WHEN OTHERS THEN
                  p_tab_error(f_sysdate, f_user, 'pac_reaseguro_rec.f_llenar_movcta_aux',
                              v_traza,
                              'Err SELECT  FROM movctaaux:' || reg.cempres || ', '
                              || reg.sproduc || ', ' || reg.ccompani || ', ' || reg.nversio
                              || ', ' || reg.scontra || ', ' || reg.ctramo,
                              ' SQLERRM = ' || SQLERRM);
                  perror := 104863;
                  psql := SQLERRM;
            END;

            w_nnumlin := w_nnumlin + 1;
            v_traza := 3;
         END IF;

         FOR cia IN cur_cuadroces(reg.scontra, reg.nversio, reg.ctramo, reg.sfacult,
                                  reg.ccompani) LOOP
------------------------------------------------------
-- Aqu? busquen l'estat del compte a CTATECNICA... ---
------------------------------------------------------
            v_traza := 4;

            IF perror = 0 THEN
               BEGIN
                  SELECT cestado
                    INTO w_cestado
                    FROM ctatecnica
                   WHERE scontra = reg.scontra
                     AND nversio = reg.nversio
                     AND ctramo = reg.ctramo
                     AND ccompani = reg.ccompani
                     AND sproduc = reg.sproduc;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     w_cestado := 1;
                     v_traza := 5;

                     --                                 DBMS_OUTPUT.put_line('es nuevo, insertamos en ctatecnica');
                     BEGIN
                        INSERT INTO ctatecnica
                                    (ccompani, nversio, scontra, ctramo, nctatec,
                                     cfrecul, cestado, festado, fcierre, cempres, sproduc,
                                     ccorred)   -- 22076 AVT 25/05/2012 nous camps
                             VALUES (reg.ccompani, reg.nversio, reg.scontra, reg.ctramo, 1,
                                     3, 1, NULL, NULL, reg.cempres, reg.sproduc,
                                     cia.ccorred);
                     EXCEPTION
                        WHEN OTHERS THEN
                           p_tab_error(f_sysdate, f_user,
                                       'pac_reaseguro_rec.f_llenar_movcta_aux', v_traza,
                                       'Err INSERT ctatecnica:' || reg.cempres || ', '
                                       || reg.sproduc || ', ' || reg.ccompani || ', '
                                       || reg.nversio || ', ' || reg.scontra || ', '
                                       || reg.ctramo,
                                       ' SQLERRM = ' || SQLERRM);
                           perror := 1;
                     END;
                  WHEN OTHERS THEN
                     p_tab_error(f_sysdate, f_user, 'pac_reaseguro_rec.f_llenar_movcta_aux',
                                 v_traza,
                                 'Err SELECT ctatecnica:' || reg.cempres || ', '
                                 || reg.sproduc || ', ' || reg.ccompani || ', ' || reg.nversio
                                 || ', ' || reg.scontra || ', ' || reg.ctramo,
                                 ' SQLERRM = ' || SQLERRM);
                     perror := 104866;
                     psql := SQLERRM;
               END;
            END IF;

            v_traza := 06;

------------------------------------------------------
-- Aqu? es contabilitzen les Primes i els sinistres --
------------------------------------------------------
            IF perror = 0 THEN
               IF reg.cmotces = 0 THEN   -- Pagament de sinistre
                  w_cdebhab := 1;   --> cdebhab de tipoctarea!
                  w_cconcep := 05;   -- sinistre
               ELSIF reg.cmotces IN(1, 3) THEN
                  w_cdebhab := 2;   --> cdebhab de tipoctarea!
                  w_cconcep := 01;   -- Primes
               END IF;

               v_traza := 7;

---------------------------------------------------------
-- Aqu? fem realment l'insert                          --
-- del pagaments de sinistre o les primes no anulades. --
---------------------------------------------------------
               IF reg.cmotces IN(0, 1, 3) THEN
                  v_traza := 8;

                  IF w_ctadet = 0
                     AND reg.ctramo = 5 THEN
                     ----- Igual com es feia abans acumulant per compa??a en els facultatius
                     BEGIN
                        UPDATE movctaaux
                           SET iimport = iimport + reg.icesion
                         WHERE scontra = reg.scontra
                           AND nversio = reg.nversio
                           AND ctramo = reg.ctramo
                           AND ccompani = reg.ccompani
                           AND NVL(ccompapr, 0) =
                                 NVL
                                    (reg.ccompapr, 0)   -- 24463 AVT 11/01/2013 s'afegeix la Cia pròpia
                           AND cconcep = w_cconcep;

                        v_traza := 9;

                        IF SQL%ROWCOUNT = 0 THEN   -- No ha actualitzat, insertem
                           BEGIN
                              INSERT INTO movctaaux
                                          (ccompani, nversio, scontra,
                                           ctramo, nnumlin, fmovimi, sproduc,
                                           npoliza, ncertif, nsinies,
                                           fefecto, cconcep, cdebhab, iimport, cestado,
                                           sproces, cempres, fcierre,
                                           ccompapr,   -- 24463 AVT 11/01/2013 s'afegeix la Cia pròpia
                                                    ccorred)   -- 22/05/2015  CJMR  0033158: Actualización campo CCORRED en los cierres de Reaseguro
                                   VALUES (reg.ccompani, reg.nversio, reg.scontra,
                                           reg.ctramo, w_nnumlin, reg.fcierre, reg.sproduc,
                                           reg.npoliza, reg.ncertif, reg.nsinies,
                                           reg.fcierre, w_cconcep, w_cdebhab, reg.icesion, 1,
                                           reg.sproces, reg.cempres, reg.fcierre,
                                           reg.ccompapr,   -- 24463 AVT 11/01/2013 s'afegeix la Cia pròpia
                                                        cia.ccorred);   -- 22/05/2015  CJMR  0033158: Actualización campo CCORRED en los cierres de Reaseguro
                           EXCEPTION
                              WHEN OTHERS THEN
                                 p_tab_error(f_sysdate, f_user,
                                             'pac_reaseguro_rec.f_llenar_movcta_aux', v_traza,
                                             'Err INSERT movctaaux:' || reg.ccompani || ', '
                                             || reg.nversio || ', ' || reg.scontra || ', '
                                             || reg.ctramo,
                                             ' SQLERRM = ' || SQLERRM);
                                 perror := 105802;
                                 psql := SQLERRM;
                           END;
                        END IF;

                        v_traza := 10;
                     EXCEPTION
                        WHEN OTHERS THEN
                           p_tab_error(f_sysdate, f_user,
                                       'pac_reaseguro_rec.f_llenar_movcta_aux', v_traza,
                                       'Err UPDATE movctaaux:' || reg.ccompani || ', '
                                       || reg.nversio || ', ' || reg.scontra || ', '
                                       || reg.ctramo,
                                       ' SQLERRM = ' || SQLERRM);
                           perror := 105801;
                           psql := SQLERRM;
                     END;

                     -----
                     v_traza := 11;
                  ELSE
                     --CONFCC-5 Inicio
                     IF w_cconcep = 1
                       AND NVL(pac_parametros.f_parempresa_n(pcempres, 'APLICA_RET_PRIMAS'), 0 ) = 1
                     THEN
                       BEGIN
                          INSERT INTO movctaaux
                                      (ccompani, nversio, scontra, ctramo,
                                       nnumlin, fmovimi, sproduc, npoliza,
                                       ncertif, nsinies, fefecto, cconcep,
                                       cdebhab, iimport, cestado, sproces, cempres,
                                       fcierre, ccompapr, ccorred)
                               VALUES (reg.ccompani, reg.nversio, reg.scontra, reg.ctramo,
                                       w_nnumlin, reg.fcierre, reg.sproduc, reg.npoliza,
                                       reg.ncertif, reg.nsinies, reg.fcierre, 45,
                                       1, reg.iretencionf, 1, reg.sproces, reg.cempres,
                                       reg.fcierre, reg.ccompapr, cia.ccorred);
                       EXCEPTION
                          WHEN OTHERS THEN
                             p_tab_error(f_sysdate, f_user,
                                         'pac_reaseguro_rec.f_llenar_movcta_aux', v_traza,
                                         'Err INSERT movctaaux Ret:' || reg.ccompani || ', '
                                         || reg.nversio || ', ' || reg.scontra || ', '
                                         || reg.ctramo,
                                         ' SQLERRM = ' || SQLERRM);
                             perror := 105802;
                             psql := SQLERRM;
                       END;
                     END IF;
                     --CONFCC-5 Fin

                     BEGIN
                        INSERT INTO movctaaux
                                    (ccompani, nversio, scontra, ctramo,
                                     nnumlin, fmovimi, sproduc, npoliza,
                                     ncertif, nsinies, fefecto, cconcep,
                                     cdebhab, iimport, cestado, sproces, cempres,
                                     fcierre, ccompapr,   -- 24463 AVT 11/01/2013 s'afegeix la Cia pròpia
                                                       ccorred)   -- 22/05/2015  CJMR  0033158: Actualización campo CCORRED en los cierres de Reaseguro
                             VALUES (reg.ccompani, reg.nversio, reg.scontra, reg.ctramo,
                                     w_nnumlin, reg.fcierre, reg.sproduc, reg.npoliza,
                                     reg.ncertif, reg.nsinies, reg.fcierre, w_cconcep,
                                     w_cdebhab, reg.icesion, 1, reg.sproces, reg.cempres,
                                     reg.fcierre, reg.ccompapr,   -- 24463 AVT 11/01/2013 s'afegeix la Cia pròpia);
                                                               cia.ccorred);   -- 22/05/2015  CJMR  0033158: Actualización campo CCORRED en los cierres de Reaseguro
                     EXCEPTION
                        WHEN OTHERS THEN
                           p_tab_error(f_sysdate, f_user,
                                       'pac_reaseguro_rec.f_llenar_movcta_aux', v_traza,
                                       'Err INSERT movctaaux:' || reg.ccompani || ', '
                                       || reg.nversio || ', ' || reg.scontra || ', '
                                       || reg.ctramo,
                                       ' SQLERRM = ' || SQLERRM);
                           perror := 105802;
                           psql := SQLERRM;
                     END;

                     v_traza := 12;
                  END IF;
               END IF;
            END IF;

            IF NVL(pac_parametros.f_parempresa_n(pcempres, 'REA_RESERV_PPNC'), 0) = 0 THEN
-----------------------------------------------------------
--Aqu? es fa el insert de les reserves, si existeixen, a --
--efectiu i a dip?sit...                                 --
-----------------------------------------------------------
               IF reg.cmotces <> 0
                  AND cia.preserv IS NOT NULL THEN
                  v_traza := 13;

                  IF perror = 0 THEN
                     ----- Igual com es feia abans acumulant per compa??a en els facultatius
                     IF w_ctadet = 0
                        AND reg.ctramo = 5 THEN
                        w_reserva := (reg.icesion * cia.preserv) / 100;
                        v_traza := 14;

                        BEGIN
                           UPDATE movctaaux
                              SET iimport = iimport + w_reserva
                            WHERE scontra = reg.scontra
                              AND nversio = reg.nversio
                              AND ctramo = reg.ctramo
                              AND ccompani = reg.ccompani
                              AND NVL(ccompapr, 0) =
                                    NVL
                                       (reg.ccompapr, 0)   -- 24463 AVT 11/01/2013 s'afegeix la Cia pròpia
                              AND cconcep = 03;

                           IF SQL%ROWCOUNT = 0 THEN
                              v_traza := 15;

                              BEGIN
                                 INSERT INTO movctaaux
                                             (ccompani, nversio, scontra,
                                              ctramo, nnumlin, fmovimi,
                                              sproduc, npoliza, ncertif,
                                              fefecto, cconcep, cdebhab, iimport, cestado,
                                              sproces, scesrea, cempres, fcierre,
                                              ccompapr,   -- 24463 AVT 11/01/2013 s'afegeix la Cia pròpia
                                                       ccorred)   -- 22/05/2015  CJMR  0033158: Actualización campo CCORRED en los cierres de Reaseguro
                                      VALUES (reg.ccompani, reg.nversio, reg.scontra,
                                              reg.ctramo, w_nnumlin, reg.fcierre,
                                              reg.sproduc, reg.npoliza, reg.ncertif,
                                              reg.fcierre, 03, 1, w_reserva, w_cestado,
                                              --> cdebhab de TIPOCTAREA
                                              reg.sproces, NULL, reg.cempres, reg.fcierre,
                                              reg.ccompapr,   -- 24463 AVT 11/01/2013 s'afegeix la Cia pròpia
                                                           cia.ccorred);   -- 22/05/2015  CJMR  0033158: Actualización campo CCORRED en los cierres de Reaseguro
                              EXCEPTION
                                 WHEN OTHERS THEN
                                    p_tab_error(f_sysdate, f_user,
                                                'pac_reaseguro_rec.f_llenar_movcta_aux',
                                                v_traza,
                                                'Err INSERT movctaaux:' || reg.ccompani
                                                || ', ' || reg.nversio || ', ' || reg.scontra
                                                || ', ' || reg.ctramo,
                                                ' SQLERRM = ' || SQLERRM);
                                    perror := 105802;
                                    psql := SQLERRM;
                              END;
                           END IF;
                        EXCEPTION
                           WHEN OTHERS THEN
                              p_tab_error(f_sysdate, f_user,
                                          'pac_reaseguro_rec.f_llenar_movcta_aux', v_traza,
                                          'Err UPDATE movctaaux:' || reg.ccompani || ', '
                                          || reg.nversio || ', ' || reg.scontra || ', '
                                          || reg.ctramo,
                                          ' SQLERRM = ' || SQLERRM);
                              perror := 105801;
                              psql := SQLERRM;
                        END;
-------------
                     ELSE
                        w_reserva := (reg.icesion * cia.preserv) / 100;
                        v_traza := 16;

                        BEGIN
                           INSERT INTO movctaaux
                                       (ccompani, nversio, scontra, ctramo,
                                        nnumlin, fmovimi, sproduc, npoliza,
                                        ncertif, fefecto, cconcep, cdebhab, iimport,
                                        cestado, sproces, scesrea, cempres,
                                        fcierre, ccompapr,   -- 24463 AVT 11/01/2013 s'afegeix la Cia pròpia
                                                          ccorred)   -- 22/05/2015  CJMR  0033158: Actualización campo CCORRED en los cierres de Reaseguro
                                VALUES (reg.ccompani, reg.nversio, reg.scontra, reg.ctramo,
                                        w_nnumlin, reg.fcierre, reg.sproduc, reg.npoliza,
                                        reg.ncertif, reg.fcierre, 03, 1, w_reserva,   --> cdebhab de TIPOCTAREA
                                        w_cestado, reg.sproces, NULL, reg.cempres,
                                        reg.fcierre, reg.ccompapr,   -- 24463 AVT 11/01/2013 s'afegeix la Cia pròpia
                                                                  cia.ccorred);   -- 22/05/2015  CJMR  0033158: Actualización campo CCORRED en los cierres de Reaseguro
                        EXCEPTION
                           WHEN OTHERS THEN
                              p_tab_error(f_sysdate, f_user,
                                          'pac_reaseguro_rec.f_llenar_movcta_aux', v_traza,
                                          'Err INSERT movctaaux:' || reg.ccompani || ', '
                                          || reg.nversio || ', ' || reg.scontra || ', '
                                          || reg.ctramo,
                                          ' SQLERRM = ' || SQLERRM);
                              perror := 105802;
                              psql := SQLERRM;
                        END;
                     END IF;
                  END IF;

                  IF perror = 0 THEN
                     IF w_ctadet = 0
                        AND reg.ctramo = 5 THEN
                        ----- Igual com es feia abans acumulant per compa??a en els facultatius
                        w_reserva := (reg.icesion * cia.preserv) / 100;
                        v_traza := 17;

                        BEGIN
                           UPDATE movctaaux
                              SET iimport = iimport + w_reserva
                            WHERE scontra = reg.scontra
                              AND nversio = reg.nversio
                              AND ctramo = reg.ctramo
                              AND ccompani = reg.ccompani
                              AND NVL(ccompapr, 0) =
                                    NVL
                                       (reg.ccompapr, 0)   -- 24463 AVT 11/01/2013 s'afegeix la Cia pròpia
                              AND cconcep = 52;

                           IF SQL%ROWCOUNT = 0 THEN
                              v_traza := 18;

                              BEGIN
                                 INSERT INTO movctaaux
                                             (ccompani, nversio, scontra,
                                              ctramo, nnumlin, fmovimi,
                                              sproduc, npoliza, ncertif,
                                              fefecto, cconcep, cdebhab, iimport, cestado,
                                              sproces, scesrea, cempres, fcierre,
                                              ccompapr,   -- 24463 AVT 11/01/2013 s'afegeix la Cia pròpia
                                                       ccorred)   -- 22/05/2015  CJMR  0033158: Actualización campo CCORRED en los cierres de Reaseguro
                                      VALUES (reg.ccompani, reg.nversio, reg.scontra,
                                              reg.ctramo, w_nnumlin, reg.fcierre,
                                              reg.sproduc, reg.npoliza, reg.ncertif,
                                              reg.fcierre, 52, 2, w_reserva, w_cestado,   --> cdebhab de TIPOCTAREA
                                              reg.sproces, NULL, reg.cempres, reg.fcierre,
                                              reg.ccompapr,   -- 24463 AVT 11/01/2013 s'afegeix la Cia pròpia
                                                           cia.ccorred);   -- 22/05/2015  CJMR  0033158: Actualización campo CCORRED en los cierres de Reaseguro
                              EXCEPTION
                                 WHEN OTHERS THEN
                                    p_tab_error(f_sysdate, f_user,
                                                'pac_reaseguro_rec.f_llenar_movcta_aux',
                                                v_traza,
                                                'Err INSERT movctaaux:' || reg.ccompani
                                                || ', ' || reg.nversio || ', ' || reg.scontra
                                                || ', ' || reg.ctramo,
                                                ' SQLERRM = ' || SQLERRM);
                                    perror := 105802;
                                    psql := SQLERRM;
                              END;
                           END IF;
                        EXCEPTION
                           WHEN OTHERS THEN
                              p_tab_error(f_sysdate, f_user,
                                          'pac_reaseguro_rec.f_llenar_movcta_aux', v_traza,
                                          'Err UPDATE movctaaux:' || reg.ccompani || ', '
                                          || reg.nversio || ', ' || reg.scontra || ', '
                                          || reg.ctramo,
                                          ' SQLERRM = ' || SQLERRM);
                              perror := 105801;
                              psql := SQLERRM;
                        END;
-------------
                     ELSE
                        v_traza := 19;

                        BEGIN
                           INSERT INTO movctaaux
                                       (ccompani, nversio, scontra, ctramo,
                                        nnumlin, fmovimi, sproduc, npoliza,
                                        ncertif, fefecto, cconcep, cdebhab, iimport,
                                        cestado, sproces, cempres, fcierre,
                                        ccompapr,   -- 24463 AVT 11/01/2013 s'afegeix la Cia pròpia
                                                 ccorred)   -- 22/05/2015  CJMR  0033158: Actualización campo CCORRED en los cierres de Reaseguro
                                VALUES (reg.ccompani, reg.nversio, reg.scontra, reg.ctramo,
                                        w_nnumlin, reg.fcierre, reg.sproduc, reg.npoliza,
                                        reg.ncertif, reg.fcierre, 52, 2, w_reserva,   --> cdebhab de TIPOCTAREA
                                        w_cestado, reg.sproces, reg.cempres, reg.fcierre,
                                        reg.ccompapr,   -- 24463 AVT 11/01/2013 s'afegeix la Cia pròpia
                                                     cia.ccorred);   -- 22/05/2015  CJMR  0033158: Actualización campo CCORRED en los cierres de Reaseguro
                        EXCEPTION
                           WHEN OTHERS THEN
                              p_tab_error(f_sysdate, f_user,
                                          'pac_reaseguro_rec.f_llenar_movcta_aux', v_traza,
                                          'Err INSERT movctaaux:' || reg.ccompani || ', '
                                          || reg.nversio || ', ' || reg.scontra || ', '
                                          || reg.ctramo,
                                          ' SQLERRM = ' || SQLERRM);
                              perror := 105802;
                              psql := SQLERRM;
                        END;
                     END IF;
                  END IF;
               END IF;
            END IF;   -- 22799 AVT 01/08/2012 FI ------------------------------

-------------------------------------------------------------
--Aqu? es fa el insert de les comissions, si existeixen... --
-------------------------------------------------------------
            IF perror = 0 THEN
               IF reg.icomisi <> 0 THEN
                  v_traza := 20;

                  ----- Igual com es feia abans acumulant per compa??a en els facultatius
                  IF w_ctadet = 0
                     AND reg.ctramo = 5 THEN
                     v_traza := 21;

                     BEGIN
                        UPDATE movctaaux
                           SET iimport = iimport + reg.icomisi
                         WHERE scontra = reg.scontra
                           AND nversio = reg.nversio
                           AND ctramo = reg.ctramo
                           AND ccompani = reg.ccompani
                           AND NVL(ccompapr, 0) =
                                 NVL
                                    (reg.ccompapr, 0)   -- 24463 AVT 11/01/2013 s'afegeix la Cia pròpia
                           AND cconcep = 02;

                        IF SQL%ROWCOUNT = 0 THEN
                           v_traza := 22;

                           BEGIN
                              INSERT INTO movctaaux
                                          (ccompani, nversio, scontra,
                                           ctramo, nnumlin, fmovimi, sproduc,
                                           npoliza, ncertif, fefecto, cconcep, cdebhab,
                                           iimport, cestado, sproces, cempres,
                                           fcierre, ccompapr,   -- 24463 AVT 11/01/2013 s'afegeix la Cia pròpia
                                                             ccorred)   -- 22/05/2015  CJMR  0033158: Actualización campo CCORRED en los cierres de Reaseguro
                                   VALUES (reg.ccompani, reg.nversio, reg.scontra,
                                           reg.ctramo, w_nnumlin, reg.fcierre, reg.sproduc,
                                           reg.npoliza, reg.ncertif, reg.fcierre, 02, 1,   --> cdebhab de TIPOCTAREA
                                           reg.icomisi, w_cestado, reg.sproces, reg.cempres,
                                           reg.fcierre, reg.ccompapr,   -- 24463 AVT 11/01/2013 s'afegeix la Cia pròpia
                                                                     cia.ccorred);   -- 22/05/2015  CJMR  0033158: Actualización campo CCORRED en los cierres de Reaseguro
                           EXCEPTION
                              WHEN OTHERS THEN
                                 p_tab_error(f_sysdate, f_user,
                                             'pac_reaseguro_rec.f_llenar_movcta_aux', v_traza,
                                             'Err INSERT movctaaux:' || reg.ccompani || ', '
                                             || reg.nversio || ', ' || reg.scontra || ', '
                                             || reg.ctramo,
                                             ' SQLERRM = ' || SQLERRM);
                                 perror := 105802;
                                 psql := SQLERRM;
                           END;
                        END IF;
                     EXCEPTION
                        WHEN OTHERS THEN
                           p_tab_error(f_sysdate, f_user,
                                       'pac_reaseguro_rec.f_llenar_movcta_aux', v_traza,
                                       'Err UPDATE movctaaux:' || reg.ccompani || ', '
                                       || reg.nversio || ', ' || reg.scontra || ', '
                                       || reg.ctramo,
                                       ' SQLERRM = ' || SQLERRM);
                           perror := 105801;
                           psql := SQLERRM;
                     END;
                  ELSE
                     --------
                     v_traza := 23;

                     BEGIN
                        INSERT INTO movctaaux
                                    (ccompani, nversio, scontra, ctramo,
                                     nnumlin, fmovimi, sproduc, npoliza,
                                     ncertif, fefecto, cconcep, cdebhab, iimport, cestado,
                                     sproces, cempres, fcierre, ccompapr,   -- 24463 AVT 11/01/2013 s'afegeix la Cia pròpia
                                     ccorred)   -- 22/05/2015  CJMR  0033158: Actualización campo CCORRED en los cierres de Reaseguro
                             VALUES (reg.ccompani, reg.nversio, reg.scontra, reg.ctramo,
                                     w_nnumlin, reg.fcierre, reg.sproduc, reg.npoliza,
                                     reg.ncertif, reg.fcierre, 02, 1, reg.icomisi, w_cestado,   --> cdebhab de TIPOCTAREA
                                     reg.sproces, reg.cempres, reg.fcierre, reg.ccompapr,   -- 24463 AVT 11/01/2013 s'afegeix la Cia pròpia
                                     cia.ccorred);   -- 22/05/2015  CJMR  0033158: Actualización campo CCORRED en los cierres de Reaseguro
                     EXCEPTION

                        WHEN OTHERS THEN
                           p_tab_error(f_sysdate, f_user,
                                       'pac_reaseguro_rec.f_llenar_movcta_aux', v_traza,
                                       'Err INSERT movctaaux:' || reg.ccompani || ', '
                                       || reg.nversio || ', ' || reg.scontra || ', '
                                       || reg.ctramo,
                                       ' SQLERRM = ' || SQLERRM);
                           perror := 105802;
                           psql := SQLERRM;
                     END;
                  END IF;
               END IF;
            END IF;

            --bug 25860 ETM 08/04/202013 INI---------------
            IF cia.ctramocomision IS NOT NULL THEN
               v_traza := 40;

-------------------------------------------------------------------------------------------
-- SINIESTRALIDAD = Siniestro incurrido / Prima devengada                                --
-- Siniestro incurrido = Siniestro pagado - recobros + reserva de siniestros pendientes  --
-- Prima devengada = Prima cedida - Saldo deposito de primas retenido                    --
-------------------------------------------------------------------------------------------
               BEGIN
                  SELECT NVL(SUM(m.iimport), 0) + NVL(SUM(x.iimport), 0)
                    INTO v_prima_anual
                    FROM movctatecnica m, movctaaux x
                   WHERE m.fmovimi >= TO_DATE('0101' || pany, 'ddmmyyyy')
                     AND x.fmovimi = reg.fcierre
                     AND m.scontra = x.scontra(+)
                     AND m.nversio = x.nversio(+)
                     AND m.ctramo = x.ctramo(+)
                     AND m.ccompani = x.ccompani(+)
                     AND m.scontra = reg.scontra
                     AND m.nversio = reg.nversio
                     AND m.ctramo = reg.ctramo
                     AND m.ccompani = reg.ccompani
                     AND m.cconcep = x.cconcep(+)
                     AND m.sproduc = x.sproduc(+)
                     AND m.sproduc = reg.sproduc
                     AND m.cconcep = 1;

                  IF v_prima_anual = 0 THEN
                     v_prima_anual := 1;
                  END IF;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     SELECT NVL(SUM(x.iimport), 1)
                       INTO v_prima_anual
                       FROM movctaaux x
                      WHERE x.fmovimi = reg.fcierre
                        AND x.scontra = reg.scontra
                        AND x.nversio = reg.nversio
                        AND x.ctramo = reg.ctramo
                        AND x.ccompani = reg.ccompani
                        AND x.cconcep = 1
                        AND x.sproduc = reg.sproduc;
               END;

               BEGIN
                  SELECT NVL(SUM(m.iimport), 0) + NVL(SUM(x.iimport), 0)
                    INTO v_pagos_sin_anual
                    FROM movctatecnica m, movctaaux x
                   WHERE m.fmovimi >= TO_DATE('0101' || pany, 'ddmmyyyy')
                     AND x.fmovimi = reg.fcierre
                     AND m.scontra = x.scontra(+)
                     AND m.nversio = x.nversio(+)
                     AND m.ctramo = x.ctramo(+)
                     AND m.ccompani = x.ccompani(+)
                     AND m.scontra = reg.scontra
                     AND m.nversio = reg.nversio
                     AND m.ctramo = reg.ctramo
                     AND m.ccompani = reg.ccompani
                     AND m.sproduc = x.sproduc(+)
                     AND m.sproduc = reg.sproduc
                     AND m.cconcep = x.cconcep(+)
                     AND m.cconcep = 5;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     SELECT NVL(SUM(x.iimport), 0)
                       INTO v_pagos_sin_anual
                       FROM movctaaux x
                      WHERE x.fmovimi = reg.fcierre
                        AND x.scontra = reg.scontra
                        AND x.nversio = reg.nversio
                        AND x.ctramo = reg.ctramo
                        AND x.ccompani = reg.ccompani
                        AND x.cconcep = 5
                        AND x.sproduc = reg.sproduc;
               END;

               SELECT NVL(SUM(l.icompan), 0)
                 INTO v_reserva_anual
                 FROM liqresreaaux l, seguros s
                WHERE l.sseguro = s.sseguro
                  AND l.scontra = reg.scontra
                  AND l.nversio = reg.nversio
                  AND l.ctramo = reg.ctramo
                  AND l.fcierre = reg.fcierre
                  AND l.ccompani = reg.ccompani
                  AND s.sproduc = reg.sproduc;

               --nsinies = reg.nsinies
               v_traza := 41;
               v_siniestralitat := (v_pagos_sin_anual + v_reserva_anual) / v_prima_anual;
               v_traza := 42;
               -- INICIO INFORCOL 23-12-2019 - Se inhabilita la comision escalonada debido a que presenta error para el pre-cierre de reaseguro y este tipo de comision no es utilizada en Confianza
               --perror := f_com_escalonada(reg.cempres, cia.ctramocomision, v_siniestralitat,
               --                           w_pcomias);
               -- FIN INFORCOL 23-12-2019 - Se inhabilita la comision escalonada debido a que presenta error para el pre-cierre de reaseguro y este tipo de comision no es utilizada en Confianza

               IF perror = 0 THEN
                  v_comision_esc := v_prima_anual * w_pcomias / 100;

                  BEGIN
                     SELECT NVL(SUM(m.iimport), 0) + NVL(SUM(x.iimport), 0)
                       INTO v_comis_anual
                       FROM movctatecnica m, movctaaux x
                      WHERE m.fmovimi >= TO_DATE('0101' || pany, 'ddmmyyyy')
                        AND x.fmovimi = reg.fcierre
                        AND m.scontra = x.scontra(+)
                        AND m.nversio = x.nversio(+)
                        AND m.ctramo = x.ctramo(+)
                        AND m.ccompani = x.ccompani(+)
                        AND m.scontra = reg.scontra
                        AND m.nversio = reg.nversio
                        AND m.ctramo = reg.ctramo
                        AND m.ccompani = reg.ccompani
                        AND m.cconcep = x.cconcep(+)
                        AND m.sproduc = x.sproduc(+)
                        AND m.sproduc = reg.sproduc
                        AND m.cconcep = 02;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        SELECT NVL(SUM(x.iimport), 0)
                          INTO v_comis_anual
                          FROM movctaaux x
                         WHERE x.fmovimi = reg.fcierre
                           AND x.scontra = reg.scontra
                           AND x.nversio = reg.nversio
                           AND x.ctramo = reg.ctramo
                           AND x.ccompani = reg.ccompani
                           AND x.cconcep = 02
                           AND x.sproduc = reg.sproduc;
                  END;

                  IF v_comision_esc > v_comis_anual THEN
                     v_traza := 43;
                     v_comision_esc_total := v_comision_esc - v_comis_anual;

                     IF pmes = 12 THEN
                        w_cconcep := 14;   --Regul. comissiones Variables
                     ELSE
                        w_cconcep := 24;   --Regul. comissiones Variables Provisionals
                     END IF;

                     BEGIN
                        UPDATE movctaaux
                           SET iimport = v_comision_esc_total
                         WHERE scontra = reg.scontra
                           AND nversio = reg.nversio
                           AND ctramo = reg.ctramo
                           AND ccompani = reg.ccompani
                           AND NVL(ccompapr, 0) = NVL(reg.ccompapr, 0)
                           AND cconcep = w_cconcep;

                        IF SQL%ROWCOUNT = 0 THEN
                           v_traza := 44;

                           BEGIN
                              INSERT INTO movctaaux
                                          (ccompani, nversio, scontra,
                                           ctramo, nnumlin, fmovimi, sproduc,
                                           npoliza, ncertif, fefecto, cconcep,
                                           cdebhab, iimport, cestado, sproces,
                                           cempres, fcierre, ccompapr, ccorred)   -- 22/05/2015  CJMR  0033158: Actualización campo CCORRED en los cierres de Reaseguro
                                   VALUES (reg.ccompani, reg.nversio, reg.scontra,
                                           reg.ctramo, w_nnumlin, reg.fcierre, reg.sproduc,
                                           reg.npoliza, reg.ncertif, reg.fcierre, w_cconcep,
                                           1, v_comision_esc_total, w_cestado, reg.sproces,
                                           reg.cempres, reg.fcierre, reg.ccompapr, cia.ccorred);   -- 22/05/2015  CJMR  0033158: Actualización campo CCORRED en los cierres de Reaseguro
                           EXCEPTION
                              WHEN OTHERS THEN
                                 p_tab_error(f_sysdate, f_user,
                                             'pac_reaseguro_rec.f_llenar_movcta_aux', v_traza,
                                             'Err INSERT movctaaux:' || reg.ccompani || ', '
                                             || reg.nversio || ', ' || reg.scontra || ', '
                                             || reg.ctramo || ', ' || w_cconcep,
                                             ' SQLERRM = ' || SQLERRM);
                                 perror := 105802;
                                 psql := SQLERRM;
                           END;
                        END IF;
                     EXCEPTION
                        WHEN OTHERS THEN
                           p_tab_error(f_sysdate, f_user,
                                       'pac_reaseguro_rec.f_llenar_movcta_aux', v_traza,
                                       'Err UPDATE movctaaux:' || reg.ccompani || ', '
                                       || reg.nversio || ', ' || reg.scontra || ', '
                                       || reg.ctramo || ', ' || w_cconcep,
                                       ' SQLERRM = ' || SQLERRM);
                           perror := 105801;
                           psql := SQLERRM;
                     END;
                  END IF;
               END IF;
            END IF;

         --bug 25860 ETM 08/04/202013 FIN---------------
-------------------------------------------------------------------
-- Aqu? es fa el insert de les primes anulades, si existeixen... --
-------------------------------------------------------------------
            IF reg.cmotces IN(2, 4) THEN
               v_traza := 24;

               IF perror = 0 THEN
                  ----- Igual com es feia abans acumulant per compa??a en els facultatius
                  IF w_ctadet = 0
                     AND reg.ctramo = 5 THEN
                     v_traza := 25;

                     BEGIN
                        UPDATE movctaaux
                           SET iimport =(iimport - reg.icesion)
                         WHERE scontra = reg.scontra
                           AND nversio = reg.nversio
                           AND ctramo = reg.ctramo
                           AND ccompani = reg.ccompani
                           AND NVL(ccompapr, 0) =
                                 NVL
                                    (reg.ccompapr, 0)   -- 24463 AVT 11/01/2013 s'afegeix la Cia pròpia
                           AND cconcep = 09;

                        IF SQL%ROWCOUNT = 0 THEN
                           v_traza := 26;

                           BEGIN
                              INSERT INTO movctaaux
                                          (ccompani, nversio, scontra,
                                           ctramo, nnumlin, fmovimi, sproduc,
                                           npoliza, ncertif, fefecto, cconcep, cdebhab,
                                           iimport, cestado, sproces, cempres,
                                           fcierre, ccompapr,   -- 24463 AVT 11/01/2013 s'afegeix la Cia pròpia
                                                             ccorred)   -- 22/05/2015  CJMR  0033158: Actualización campo CCORRED en los cierres de Reaseguro
                                   VALUES (reg.ccompani, reg.nversio, reg.scontra,
                                           reg.ctramo, w_nnumlin, reg.fcierre, reg.sproduc,
                                           reg.npoliza, reg.ncertif, reg.fcierre, 09, 1,   --> cdebhab de TIPOCTAREA
                                           -reg.icesion, w_cestado, reg.sproces, reg.cempres,
                                           reg.fcierre, reg.ccompapr,   -- 24463 AVT 11/01/2013 s'afegeix la Cia pròpia
                                                                     cia.ccorred);   -- 22/05/2015  CJMR  0033158: Actualización campo CCORRED en los cierres de Reaseguro
                           EXCEPTION
                              WHEN OTHERS THEN
                                 p_tab_error(f_sysdate, f_user,
                                             'pac_reaseguro_rec.f_llenar_movcta_aux', v_traza,
                                             'Err INSERT movctaaux:' || reg.ccompani || ', '
                                             || reg.nversio || ', ' || reg.scontra || ', '
                                             || reg.ctramo,
                                             ' SQLERRM = ' || SQLERRM);
                                 perror := 105802;
                                 psql := SQLERRM;
                           END;
                        END IF;
                     EXCEPTION
                        WHEN OTHERS THEN
                           p_tab_error(f_sysdate, f_user,
                                       'pac_reaseguro_rec.f_llenar_movcta_aux', v_traza,
                                       'Err UPDATE movctaaux:' || reg.ccompani || ', '
                                       || reg.nversio || ', ' || reg.scontra || ', '
                                       || reg.ctramo,
                                       ' SQLERRM = ' || SQLERRM);
                           perror := 105801;
                           psql := SQLERRM;
                     END;
                  ELSE
                     --------
                     v_traza := 27;

                     --CONFCC-5 Inicio
                     IF NVL(pac_parametros.f_parempresa_n(pcempres, 'APLICA_RET_PRIMAS'), 0 ) = 1
                     THEN
                       BEGIN
                          INSERT INTO movctaaux
                                      (ccompani, nversio, scontra, ctramo,
                                       nnumlin, fmovimi, sproduc, npoliza,
                                       ncertif, nsinies, fefecto, cconcep,
                                       cdebhab, iimport, cestado, sproces, cempres,
                                       fcierre, ccompapr, ccorred)
                               VALUES (reg.ccompani, reg.nversio, reg.scontra, reg.ctramo,
                                       w_nnumlin, reg.fcierre, reg.sproduc, reg.npoliza,
                                       reg.ncertif, reg.nsinies, reg.fcierre, 45,
                                       1, reg.iretencionf, 1, reg.sproces, reg.cempres,
                                       reg.fcierre, reg.ccompapr, cia.ccorred);
                       EXCEPTION
                          WHEN OTHERS THEN
                             p_tab_error(f_sysdate, f_user,
                                         'pac_reaseguro_rec.f_llenar_movcta_aux', v_traza,
                                         'Err INSERT movctaaux Ret:' || reg.ccompani || ', '
                                         || reg.nversio || ', ' || reg.scontra || ', '
                                         || reg.ctramo,
                                         ' SQLERRM = ' || SQLERRM);
                             perror := 105802;
                             psql := SQLERRM;
                       END;
                     END IF;
                     --CONFCC-5 Fin

                     BEGIN
                        INSERT INTO movctaaux
                                    (ccompani, nversio, scontra, ctramo,
                                     nnumlin, fmovimi, sproduc, npoliza,
                                     ncertif, fefecto, cconcep, cdebhab, iimport,
                                     cestado, sproces, cempres, fcierre,
                                     ccompapr,   -- 24463 AVT 11/01/2013 s'afegeix la Cia pròpia
                                              ccorred)   -- 22/05/2015  CJMR  0033158: Actualización campo CCORRED en los cierres de Reaseguro
                             VALUES (reg.ccompani, reg.nversio, reg.scontra, reg.ctramo,
                                     w_nnumlin, reg.fcierre, reg.sproduc, reg.npoliza,
                                     reg.ncertif, reg.fcierre, 09, 1, -reg.icesion,   --> cdebhab de TIPOCTAREA
                                     w_cestado, reg.sproces, reg.cempres, reg.fcierre,
                                     reg.ccompapr,   -- 24463 AVT 11/01/2013 s'afegeix la Cia pròpia
                                                  cia.ccorred);   -- 22/05/2015  CJMR  0033158: Actualización campo CCORRED en los cierres de Reaseguro
                     EXCEPTION
                        WHEN OTHERS THEN
                           p_tab_error(f_sysdate, f_user,
                                       'pac_reaseguro_rec.f_llenar_movcta_aux', v_traza,
                                       'Err INSERT movctaaux:' || reg.ccompani || ', '
                                       || reg.nversio || ', ' || reg.scontra || ', '
                                       || reg.ctramo,
                                       ' SQLERRM = ' || SQLERRM);
                           perror := 105802;
                           psql := SQLERRM;
                     END;
                  END IF;
               END IF;
            END IF;

-- 25822 KBR 19/03/2013
------------------------------------------------------
-- Aquí se contabilizan las tax --
-----------------------------------------------------
            IF reg.cmotces <> 0 THEN
               IF perror = 0 THEN
                  w_cdebhab := 1;   --> cdebhab de tipoctarea!
                  w_cconcep := 27;   --> Nuevo valor creado en detvalores 124

                  -- buscamos el tramo de impuestos
                  BEGIN
                     v_traza := 98;

                     SELECT cd.pctpart
                       INTO v_pctpart
                       FROM companias cc, clausulas_reas_det cd, cod_clausulas_reas cr
                      WHERE cc.ccompani = reg.ccompani
                        AND cc.ctramtax = cd.ctramo
                        AND cd.ccodigo = cr.ccodigo
                        --AND cr.ctipo = 3   --Tipo:3 TAXES/TASAS VF:346
                        AND cr.ctipo =
                              5   --  25860 16/08/2013 avt (cambiamos 3 por 5 para no entrar en conflicto con las tasas XL)
                        AND reg.fcierre > cr.fefecto
                        AND(reg.fcierre <= cr.fvencim
                            OR cr.fvencim IS NULL);

                     v_reserv_tax := reg.icesion * v_pctpart / 100;

                     BEGIN
                        INSERT INTO movctaaux
                                    (ccompani, nversio, scontra, ctramo,
                                     nnumlin, fmovimi, sproduc, npoliza,
                                     ncertif, nsinies, fefecto, cconcep,
                                     cdebhab, iimport, cestado, sproces, cempres,
                                     fcierre, ccompapr,   -- 24463 AVT 11/01/2013 s'afegeix la Cia pròpia
                                                       ccorred)   -- 22/05/2015  CJMR  0033158: Actualización campo CCORRED en los cierres de Reaseguro
                             VALUES (reg.ccompani, reg.nversio, reg.scontra, reg.ctramo,
                                     w_nnumlin, reg.fcierre, reg.sproduc, reg.npoliza,
                                     reg.ncertif, reg.nsinies, reg.fcierre, w_cconcep,
                                     w_cdebhab, v_reserv_tax, 1, reg.sproces, reg.cempres,
                                     reg.fcierre, reg.ccompapr, cia.ccorred);   -- 22/05/2015  CJMR  0033158: Actualización campo CCORRED en los cierres de Reaseguro
                     EXCEPTION
                        WHEN OTHERS THEN
                           p_tab_error(f_sysdate, f_user,
                                       'pac_reaseguro_rec.f_llenar_movcta_aux', v_traza,
                                       'Err INSERT movctaaux:' || reg.ccompani || ', '
                                       || reg.nversio || ', ' || reg.scontra || ', '
                                       || reg.ctramo,
                                       ' SQLERRM = ' || SQLERRM);
                           perror := 105802;
                           psql := SQLERRM;
                     END;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        NULL;   -- no hay tax en esta cia
                  END;
               END IF;
            END IF;
-- 25822 KBR 19/03/2013
         END LOOP;
      END LOOP;

------------------------------------------------------
-- Dades de les reserves al tancament: LIQRESREAAUX --
------------------------------------------------------
      FOR res IN cur_reserves(pcempres, pproces, w_ctadet) LOOP
         v_traza := 28;

         IF perror = 0 THEN
            BEGIN
               SELECT NVL(MAX(nnumlin), 0)
                 INTO w_nnumlin
                 FROM movctaaux
                WHERE scontra = res.scontra
                  AND nversio = res.nversio
                  AND ctramo = res.ctramo
                  AND ccompani = res.ccompani
                  AND sproduc = res.sproduc   -- xxxxx
                  AND NVL(nsinies, 0) = NVL(res.nsinies, 0);
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  w_nnumlin := 1;
               WHEN OTHERS THEN
                  p_tab_error(f_sysdate, f_user, 'pac_reaseguro_rec.f_llenar_movcta_aux',
                              v_traza,
                              'Err SELECT movctaaux:' || res.ccompani || ', ' || res.nversio
                              || ', ' || res.scontra || ', ' || res.ctramo,
                              ' SQLERRM = ' || SQLERRM);
                  perror := 104863;
                  psql := SQLERRM;
            END;

            --faltaría la gestión por corredor del Facultativo (ctramo = 5)
            BEGIN
               SELECT ccorred
                 INTO v_ccorred
                 FROM cuadroces
                WHERE res.ctramo <> 5
                  AND scontra = res.scontra
                  AND nversio = res.nversio
                  AND ctramo = res.ctramo
                  AND ccompani = res.ccompani;
            EXCEPTION
               WHEN OTHERS THEN
                  v_ccorred := NULL;
            END;

            w_nnumlin := w_nnumlin + 1;
            v_traza := 29;

            BEGIN
               INSERT INTO movctaaux
                           (ccompani, nversio, scontra, ctramo, nnumlin,
                            fmovimi, sproduc, fefecto, cconcep, cdebhab, iimport, cestado,
                            sproces, cempres, fcierre, nsinies, ccompapr,
                            ccorred)   -- 24463 AVT 16/01/2013 s'afegeix el nsinies i la Cia pròpia
                    VALUES (res.ccompani, res.nversio, res.scontra, res.ctramo, w_nnumlin,
                            res.fcierre, res.sproduc, res.fcierre, 25, 2, res.ires, 1,   --> cdebhab de TIPOCTAREA
                            res.sproces, res.cempres, res.fcierre, res.nsinies, res.ccompapr,
                            v_ccorred);   -- 24463 AVT 16/01/2013 s'afegeix el nsinies i la Cia pròpia
            EXCEPTION
               WHEN OTHERS THEN
                  p_tab_error(f_sysdate, f_user, 'pac_reaseguro_rec.f_llenar_movcta_aux',
                              v_traza,
                              'Err INSERT movctaaux:' || res.ccompani || ', ' || res.nversio
                              || ', ' || res.scontra || ', ' || res.ctramo,
                              ' SQLERRM = ' || SQLERRM);
                  perror := 105802;
                  psql := SQLERRM;
            END;
         END IF;
      END LOOP;

------------------------------------------------------------------------------
-- Aqu? es crean els moviments de Compte T?cnic referents a Reemborsament  ---
-- de Reserves (Reemborsament de Reserves, interessos sobre reemborsament, ---
-- retenci? sobre interessos) segons freq. de reemborsament cfreres VF:17  ---
------------------------------------------------------------------------------
      IF perror = 0 THEN
         -- 25373 KBR 18/03/2012 Afegir un paràmetre per empresa que indiqui el reemborsament de les reserves del reasseguro
         w_periodo_rea := NVL(pac_parametros.f_parempresa_n(pcempres, 'PER_REEMBOLSO_REA'), 0);

         FOR fre IN cur_frac_reemb(pcempres, w_ctadet) LOOP
            -- 25373 KBR 05042013 Cálculo de fecha para el reembolso de reservas
            v_traza := 30;
            w_fcierre := LAST_DAY(TO_DATE('01/' || pmes || '/' || pany, 'dd/mm/yyyy'));
            w_freini := 0;

            -- 25373 KBR 08/04/2012  Como hasta ahora, reembolso anual cada mes.
            IF w_periodo_rea = 0 THEN
               w_freini := 1;   -- 25373 KBR 18/03/2012
            ELSE
               --Existen dos formas de reembolsar los depósitos:
               --1. Frecuencia de reembolso/devolución: Es la utilizada por AGM y
               --estará activo en aquellos clientes con el parámetro 'REA_PRORRATA_INT'
               --sigue como premisa que según la frecuencia definida (mensual, bimestral,
               --trimestra, semestra o anual) se hará la devolución de los depósitos
               --en el mes que corresponda.
               --2. Período de reembolso/devolución: Es cuando la compañía que retiene
               --los depósitos debe hacer el retorno de los mismos mes a mes, de
               --aquellos que fueron constituidos X (fre.cfreres) meses antes.
               IF NVL(pac_parametros.f_parempresa_n(w_cempres, 'REA_PRORRATA_INT'), 0) = 1 THEN
                  IF fre.cfreres = 1   -- Reemborsament Mensual
                     OR(fre.cfreres = 2   -- Reemborsament Bimestral
                        AND(pmes = 02
                            OR pmes = 04
                            OR pmes = 06
                            OR pmes = 08
                            OR pmes = 10
                            OR pmes = 12))
                     OR(fre.cfreres = 3   -- Reemborsament Trimestral
                        AND(pmes = 03
                            OR pmes = 06
                            OR pmes = 09
                            OR pmes = 12))
                     OR(fre.cfreres = 4   -- Reemborsament Quatrimestral
                        AND(pmes = 04
                            OR pmes = 08
                            OR pmes = 12))
                     OR(fre.cfreres = 6   -- Reemborsament Semestral
                        AND(pmes = 06
                            OR pmes = 12))
                     OR(fre.cfreres = 12   -- Reemborsament Anual
                        AND pmes = 12) THEN
                     w_freini := fre.cfreres;
                     pfin := ADD_MONTHS(w_fcierre, -w_freini);
                     pini := ADD_MONTHS(pfin, -w_freini) + 1;
                  END IF;
               ELSE
                  w_freini := fre.cfreres;
                  pfin := ADD_MONTHS(w_fcierre, -w_freini);
                  pini := ADD_MONTHS(TO_DATE('01/' || pmes || '/' || pany, 'dd/mm/yyyy'),
                                     -w_freini);
               END IF;
            END IF;

            IF w_freini > 0 THEN
               -->> Reemborsament reserves
               FOR regemb IN cur_reemb(pcempres, fre.scontra, fre.nversio, fre.ctramo,
                                       fre.ccompani, fre.npoliza, fre.ncertif, w_ctadet, pini,
                                       pfin) LOOP
                  v_traza := 31;
                  v_ccorred := regemb.ccorred;

                  -- Aqu? busquem el ?ltim NNUMLIN...
                  BEGIN
                     SELECT NVL(MAX(nnumlin), 0)
                       INTO w_nnumlin
                       FROM movctaaux
                      WHERE scontra = regemb.scontra
                        AND nversio = regemb.nversio
                        AND ctramo = regemb.ctramo
                        AND ccompani = regemb.ccompani
                        AND sproduc = regemb.sproduc   -- xxxxx
                        AND NVL(npoliza, 0) = NVL(regemb.npoliza, 0)
                        AND NVL(ncertif, 0) = NVL(regemb.ncertif, 0);
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        v_traza := 32;

                        BEGIN
                           SELECT NVL(MAX(nnumlin), 0)
                             INTO w_nnumlin
                             FROM movctaaux
                            WHERE scontra = regemb.scontra
                              AND nversio = regemb.nversio
                              AND ctramo = regemb.ctramo
                              AND ccompani = regemb.ccompani
                              AND sproduc = 0   -- xxxxx
                              AND NVL(npoliza, 0) = NVL(regemb.npoliza, 0)
                              AND NVL(ncertif, 0) = NVL(regemb.ncertif, 0);
                        EXCEPTION
                           WHEN NO_DATA_FOUND THEN
                              w_nnumlin := 1;
                           WHEN OTHERS THEN
                              p_tab_error(f_sysdate, f_user,
                                          'pac_reaseguro_rec.f_llenar_movcta_aux', v_traza,
                                          'Err SELECT FROM movctaaux:' || regemb.ccompani
                                          || ', ' || regemb.nversio || ', ' || regemb.scontra
                                          || ', ' || regemb.ctramo || ', ' || regemb.sproduc,
                                          ' SQLERRM = ' || SQLERRM);
                              psql := SQLERRM;
                              RETURN 104863;
                        END;
                     WHEN OTHERS THEN
                        p_tab_error(f_sysdate, f_user,
                                    'pac_reaseguro_rec.f_llenar_movcta_aux', v_traza,
                                    'Err SELECT FROM movctaaux:' || regemb.ccompani || ', '
                                    || regemb.nversio || ', ' || regemb.scontra || ', '
                                    || regemb.ctramo || ', ' || regemb.sproduc,
                                    ' SQLERRM = ' || SQLERRM);
                        psql := SQLERRM;
                        RETURN 104863;
                  END;

                  -- 25373 KBR 19/03/2013 No se debe cambiar el signo del importe
                  w_reemb := regemb.iimport;
                  v_traza := 33;

                  BEGIN
                     INSERT INTO movctaaux
                                 (ccompani, nversio, scontra,
                                  sproduc, npoliza, ncertif,
                                  ctramo, nnumlin, fmovimi, fefecto, cconcep, cdebhab,
                                  iimport, cestado, sproces, cempres, fcierre, ccompapr,
                                  ccorred)   -- 24463 AVT 11/01/2013 s'afegeix la Cia pròpia
                          VALUES (regemb.ccompani, regemb.nversio, regemb.scontra,
                                  regemb.sproduc, regemb.npoliza, regemb.ncertif,
                                  regemb.ctramo, w_nnumlin, w_fcierre, w_fcierre, 06, 2,   --> cdebhab de TIPOCTAREA
                                  w_reemb, 1, pproces, pcempres, w_fcierre,   -- BUG 30203 DCT 18/02/2014 -Poner el estado a 1-Pendiente
                                                                           regemb.ccompapr,
                                  v_ccorred);   -- 24463 AVT 11/01/2013 s'afegeix la Cia pròpia
                  -- canvi pfcierre -> w_fcierre
                  EXCEPTION
                     WHEN OTHERS THEN
                        p_tab_error(f_sysdate, f_user,
                                    'pac_reaseguro_rec.f_llenar_movcta_aux', v_traza,
                                    'Err INSERT movctaaux:' || regemb.ccompani || ', '
                                    || regemb.nversio || ', ' || regemb.scontra || ', '
                                    || regemb.ctramo || ', ' || regemb.sproduc,
                                    ' SQLERRM = ' || SQLERRM);
                        psql := SQLERRM;
                        RETURN 105802;
                  END;

                  v_traza := 34;

--Reemborsament reserves
                  BEGIN
                     INSERT INTO movctaaux
                                 (ccompani, nversio, scontra,
                                  sproduc, npoliza, ncertif,
                                  ctramo, nnumlin, fmovimi, fefecto, cconcep, cdebhab,
                                  iimport, cestado, sproces, cempres, fcierre, ccompapr,
                                  ccorred)   -- 24463 AVT 11/01/2013 s'afegeix la Cia pròpia
                          VALUES (regemb.ccompani, regemb.nversio, regemb.scontra,
                                  regemb.sproduc, regemb.npoliza, regemb.ncertif,
                                  regemb.ctramo, w_nnumlin, w_fcierre, w_fcierre, 51, 1,   --> cdebhab de TIPOCTAREA
                                  w_reemb, 1, pproces, pcempres, w_fcierre,   --BUG 30203 DCT 18/02/2014 -Poner el estado a 1-Pendiente
                                                                           regemb.ccompapr,
                                  v_ccorred);   -- 24463 AVT 11/01/2013 s'afegeix la Cia pròpia
                  -- canvi pfcierre -> w_fcierre
                  EXCEPTION
                     WHEN OTHERS THEN
                        p_tab_error(f_sysdate, f_user,
                                    'pac_reaseguro_rec.f_llenar_movcta_aux', v_traza,
                                    'Err INSERT movctaaux:' || regemb.ccompani || ', '
                                    || regemb.nversio || ', ' || regemb.scontra || ', '
                                    || regemb.ctramo || ', ' || regemb.sproduc,
                                    ' SQLERRM = ' || SQLERRM);
                        psql := SQLERRM;
                        RETURN 105802;
                  END;

                  v_traza := 35;
                  w_int := 0;   -- Se inicializa variable BUG: 35050 - 19/03/2015

                  --interessos o codi
                  IF NVL(fre.pintres, 0) <> 0 THEN   -- Interes fixe
                     IF fre.cfreres < 12
                        AND NVL(pac_parametros.f_parempresa_n(w_cempres, 'REA_PRORRATA_INT'),
                                0) = 1 THEN
                        codi_error := f_difdata(pini, pfin, 2, 3, w_dias);
                        codi_error := f_difdata(pini, ADD_MONTHS(pini, 12), 2, 3,
                                                w_divisoranual);
                        w_int := (w_reemb * fre.pintres / 100) * w_dias / w_divisoranual;
                     ELSE
                        w_int := (w_reemb * fre.pintres * NVL(fre.cfreres, 12) / 12) / 100;
                     END IF;
                  ELSIF NVL(fre.cintres, 0) <> 0 THEN   -- Interes variable(codi)
                     BEGIN
                        SELECT COUNT(*)
                          INTO existe
                          FROM interesrea
                         WHERE cintres = fre.cintres
                           AND fintres = pfin;

                        IF existe = 0 THEN
                           p_tab_error(f_sysdate, f_user,
                                       'pac_reaseguro_rec.f_llenar_movcta_aux', v_traza,
                                       'Err SELECT FROM interesrea - existe =0:'
                                       || fre.cintres || ', ' || pfin || ', '
                                       || regemb.ccompani || ', ' || regemb.nversio || ', '
                                       || regemb.scontra || ', ' || regemb.ctramo || ', '
                                       || regemb.sproduc,
                                       ' SQLERRM = ' || SQLERRM);
                           RETURN SQLCODE;
                        END IF;
                     EXCEPTION
                        WHEN OTHERS THEN
                           p_tab_error(f_sysdate, f_user,
                                       'pac_reaseguro_rec.f_llenar_movcta_aux', v_traza,
                                       'Err SELECT FROM interesrea:' || fre.cintres || ', '
                                       || pfin || ', ' || regemb.ccompani || ', '
                                       || regemb.nversio || ', ' || regemb.scontra || ', '
                                       || regemb.ctramo || ', ' || regemb.sproduc,
                                       ' SQLERRM = ' || SQLERRM);
                           psql := SQLERRM;
                           RETURN SQLCODE;
                     END;

                     v_traza := 36;
                     perror := f_interesrea(w_reemb, fre.cintres, pini, pfin, w_int);

                     IF perror <> 0 THEN
                        p_tab_error(f_sysdate, f_user,
                                    'pac_reaseguro_rec.f_llenar_movcta_aux', v_traza,
                                    'error a f_interesrea:' || w_reemb || ', ' || fre.cintres
                                    || ', ' || pini || ', ' || pfin || ', ' || w_int,
                                    ' SQLERRM = ' || SQLERRM);
                        psql := 'error a f_interesrea';
                        RETURN perror;
                     END IF;
                  END IF;

-- cconcep = 04 Interessos s/ reserves
                  IF NVL(w_int, 0) <> 0
                     AND perror = 0 THEN
                     v_traza := 37;

                     BEGIN
                        INSERT INTO movctaaux
                                    (ccompani, nversio, scontra,
                                     sproduc, npoliza, ncertif,
                                     ctramo, nnumlin, fmovimi, fefecto, cconcep, cdebhab,
                                     iimport, cestado, sproces, cempres, fcierre, ccompapr,
                                     ccorred)   -- 24463 AVT 11/01/2013 s'afegeix la Cia pròpia
                             VALUES (regemb.ccompani, regemb.nversio, regemb.scontra,
                                     regemb.sproduc, regemb.npoliza, regemb.ncertif,
                                     regemb.ctramo, w_nnumlin, w_fcierre, w_fcierre, 04, 2,   --> cdebhab de TIPOCTAREA
                                     w_int, 1, pproces, pcempres, w_fcierre,   --BUG 30203 DCT 18/02/2014 -Poner el estado a 1-Pendiente
                                                                            regemb.ccompapr,
                                     v_ccorred);   -- 24463 AVT 11/01/2013 s'afegeix la Cia pròpia
                     -- canvi pfcierre -> w_fcierre
                     EXCEPTION
                        WHEN OTHERS THEN
                           p_tab_error(f_sysdate, f_user,
                                       'pac_reaseguro_rec.f_llenar_movcta_aux', v_traza,
                                       'Err INSERT movctaaux:' || regemb.ccompani || ', '
                                       || regemb.nversio || ', ' || regemb.scontra || ', '
                                       || regemb.ctramo || ', ' || regemb.sproduc,
                                       ' SQLERRM = ' || SQLERRM);
                           psql := SQLERRM;
                           RETURN 105802;
                     END;
                  END IF;

-- Busquem el % de retenci? segons el pais...
                  IF perror = 0 THEN
                     v_traza := 38;

                     -- 22076 AVT 20/06/2012 IMPOSTOS DEL QUADRE PER DEFECTE
                     IF NVL(fre.pimpint, 0) <> 0 THEN
                        w_preten := fre.pimpint;
                     ELSE
                        BEGIN   -- Busquem el % de retenci? segons el pais...
                           SELECT p.pretenc
                             INTO w_preten
                             FROM paises p, companias c
                            WHERE c.ccompani = regemb.ccompani
                              AND p.cpais = c.cpais;
                        EXCEPTION
                           WHEN NO_DATA_FOUND THEN
                              w_preten := 0;
                           WHEN OTHERS THEN
                              p_tab_error(f_sysdate, f_user,
                                          'pac_reaseguro_rec.f_llenar_movcta_aux', v_traza,
                                          'Err paises p, companias c:' || regemb.ccompani,
                                          ' SQLERRM = ' || SQLERRM);
                              psql := SQLERRM;
                              RETURN 105249;
                        END;
                     END IF;

                     IF NVL(w_preten, 0) <> 0 THEN
                        v_traza := 39;
                        w_reten := (w_int * w_preten) / 100;

                        --  Retenci? sobre interessos...
                        BEGIN
                           INSERT INTO movctaaux
                                       (ccompani, nversio, scontra,
                                        sproduc, npoliza, ncertif,
                                        ctramo, nnumlin, fmovimi, fefecto, cconcep,
                                        cdebhab, iimport, cestado, sproces, cempres, fcierre,
                                        ccompapr, ccorred)   -- 24463 AVT 11/01/2013 s'afegeix la Cia pròpia
                                VALUES (regemb.ccompani, regemb.nversio, regemb.scontra,
                                        regemb.sproduc, regemb.npoliza, regemb.ncertif,
                                        regemb.ctramo, w_nnumlin, w_fcierre, w_fcierre, 07,
                                        1, w_reten, 1, pproces, pcempres,   --> cdebhab de TIPOCTAREA  --BUG 30203 DCT 18/02/2014 -Poner el estado a 1-Pendiente
                                                                         w_fcierre,
                                        regemb.ccompapr, v_ccorred);   -- 24463 AVT 11/01/2013 s'afegeix la Cia pròpia
                        -- canvi pfcierre -> w_fcierre
                        EXCEPTION
                           WHEN OTHERS THEN
                              p_tab_error(f_sysdate, f_user,
                                          'pac_reaseguro_rec.f_llenar_movcta_aux', v_traza,
                                          'Err INSERT movctaaux:' || regemb.ccompani || ', '
                                          || regemb.nversio || ', ' || regemb.scontra || ', '
                                          || regemb.ctramo || ', ' || regemb.sproduc,
                                          ' SQLERRM = ' || SQLERRM);
                              psql := SQLERRM;
                              RETURN 105802;
                        END;
                     END IF;
                  END IF;

                  IF perror <> 0 THEN
                     RETURN(perror);
                  END IF;
               END LOOP;
            END IF;
         END LOOP;
      -- COMMIT;
      END IF;

      RETURN(perror);
   END f_llenar_movcta_aux;

-- *********************************************************

FUNCTION f_llenar_readeposito_aux(
    PCEMPRES IN NUMBER,
    PPROCES IN NUMBER)
    RETURN NUMBER AS

      perror            NUMBER := 0;
      r_moneda          NUMBER := 0;
      w_nnumlin         NUMBER := 0;
      psql              NUMBER := 0;
      v_traza           NUMBER;
      w_int             NUMBER(13, 2);
      pfin              DATE;
      pini              DATE;
      w_ctadet          NUMBER(1);
      w_cintres         NUMBER:=0;
      w_pintres         NUMBER:=0;
      w_fcierre         readepositoaux.fcierre%TYPE;
      w_freini          NUMBER := 0;
      v_cmoncontab      parempresas.nvalpar%TYPE := pac_parametros.f_parempresa_n(pcempres, 'MONEDACONTAB');
      v_itasa           eco_tipocambio.itasa%TYPE;
      v_fcambio         DATE;
      w_ireserv         readepositoaux.ireserv%TYPE;
      w_pinteresdep     readepositoaux.pinteresdep%TYPE;
      w_iinterdep       readepositoaux.iinterdep%TYPE;
      w_pimpint         readepositoaux.pimpint%TYPE;
      w_iimpint         readepositoaux.iimpint%TYPE;
      w_icesion_moncon  readepositoaux.icesion_moncon%TYPE;
	   v_preserv_aux     NUMBER:=0; -- EDBR - 07/07/2019 - IAXIS4617 Se agreagan variable auxiliar para setear luego cuando se determine si es un siniestro
      v_ireserv_aux     NUMBER:=0; -- EDBR - 07/07/2019 - IAXIS4617 Se agreagan variable auxiliar para setear luego cuando se determine si es un siniestro
      v_icesion_aux     NUMBER:=0; -- EDBR - 07/07/2019 - IAXIS4617 Se agreagan variable auxiliar para setear luego cuando se determine si es un siniestro



CURSOR reaseg(wempresa IN NUMBER, wproces IN NUMBER) IS
SELECT
r.cempres,
r.fcierre,
trunc(r.fcierre) - (to_number(to_char(r.fcierre,'DD')) - 1) fini,
r.sproces,
r.scontra,
r.nversio,
r.ctramo,
r.ccompani,
r.pcesion,
sproduc,
s.ccompani ccompapr,
r.scesrea,
s.sseguro,
s.npoliza,
r.ncertif,
r.nsinies,
NVL(ac.cagente, r.cagente) cagente,
--INI IAXIS BUG 12994 AABG: Se obtiene el icesion sin corretaje
--pac_corretaje.f_impcor_agente(r.icesion, ac.cagente, s.sseguro, r.nmovimi) icesion,
r.icesion icesion,
--FIN IAXIS BUG 12994 AABG: Se obtiene el icesion sin corretaje
nvl (ppartici, 100) ppartici,
NVL(cc.preserv, 0) PRESERV,
cc.cintres,
cc.pintres,
--INI IAXIS BUG 12994 AABG: Se toma la fecha de efecto del Seguro
s.fefecto
--FIN IAXIS BUG 12994 AABG: Se toma la fecha de efecto del Seguro
FROM
reaseguroaux r,
seguros s,
age_corretaje ac,
(SELECT preserv, scontra, nversio, ctramo, ccompani, 0 sfacult , cintres, pintres
FROM cuadroces
WHERE ctramo <> 5
UNION
-- INICIO INFORCOL 12-03-2020
SELECT presrea/*preserv*/,  0 scontra,  0 nversio,  5 ctramo, ccompani, sfacult, cintres, pintres FROM cuacesfac) cc
-- FIN INFORCOL 12-03-2020
WHERE r.sproces = wproces
AND r.cempres = wempresa
AND s.sseguro = r.sseguro
AND r.ctramo < 6   -- Solo tomamos proporcionales
AND s.sseguro = ac.sseguro (+)
AND (ac.nmovimi IS NULL
OR (ac.nmovimi = (SELECT MAX (nmovimi) FROM age_corretaje ac2 WHERE ac2.sseguro = ac.sseguro
                  AND ac2.nmovimi <= nvl (r.nmovimi, 99))))
                  AND cc.ccompani = r.ccompani
                  AND cc.ctramo = r.ctramo
                  AND ((cc.sfacult = r.sfacult) OR
                   (cc.scontra = r.scontra AND cc.nversio = r.nversio))
ORDER BY r.scontra, r.nversio, r.ctramo, r.ccompani;


   BEGIN
      v_traza := 0;

------------------------------------
-- Dades del tancament: READEPOSITO --
------------------------------------
      FOR reg IN reaseg(pcempres, pproces) LOOP

      v_traza := 2;
      v_cmoncontab:= pac_oper_monedas.f_moncontab(reg.sseguro);
      --INI IAXIS BUG 12994 AABG: Se envia la fecha de efecto del Seguro
      r_moneda := pac_oper_monedas.f_datos_contraval(reg.sseguro, NULL, reg.scontra, reg.fefecto, v_cmoncontab, v_itasa, v_fcambio);
      --INI IAXIS BUG 12994 AABG: Se envia la fecha de efecto del Seguro

IF perror = 0 THEN
   BEGIN

    w_fcierre := reg.fcierre;
    pfin := w_fcierre;
    pini := reg.fini;

    /* Calculo de Ireserv, aplicando el % preserv a icesion */
      w_ireserv := (reg.icesion * reg.preserv) / 100;

    /* Calculo de Ireserv, aplicando el % preserv a icesion */

      w_pinteresdep := f_interesrea(w_ireserv, reg.pintres, pini, pfin, w_int);

   /* Calculo de iinterdep, aplicando el % pinteresdep a ireserv */
      w_iinterdep := (w_pinteresdep * w_ireserv) / 100;


      BEGIN   -- Busquem el % de retenci? segons el pais...
        SELECT p.pretenc INTO w_pimpint  FROM paises p, companias c WHERE c.ccompani = reg.ccompani AND p.cpais = c.cpais;
        EXCEPTION
        WHEN NO_DATA_FOUND

        THEN w_pimpint := 0;

        WHEN OTHERS
        THEN p_tab_error(f_sysdate, f_user,
                         'pac_reaseguro_rec.f_llenar_readeposito_aux', v_traza,
                         'Err paises p, companias c:' || reg.ccompani,
                         'SQLERRM = ' || SQLERRM);
                          psql := SQLERRM;
        RETURN 105249;
     END;
     IF NVL(w_pimpint, 0) <> 0
     THEN v_traza := 39;
          w_iimpint := (w_iinterdep * w_pimpint) / 100;
     END IF;

            IF reg.preserv <> 0 THEN

            BEGIN

			-- INI - EDBR - 07/07/2019 - IAXIS4617 Se agrega condicional para determinar si es sinisetro
            IF reg.NSINIES IS NULL THEN
              v_preserv_aux     :=reg.preserv;                
              v_icesion_aux     :=reg.icesion;               
            ELSE            
             v_preserv_aux     :=0;                
              v_icesion_aux     :=0; 
              w_ireserv     :=0;              
            END IF;
            -- FIN - EDBR - 07/07/2019 - IAXIS4617 Se agrega condicional para determinar si es sinisetro
                     INSERT INTO READEPOSITOAUX
                                 (
                                  ccompani, nversio, scontra,
                                  ctramo, sproces, scesrea,
                                  cempres, fcierre, sproduc,
                                  sseguro, npoliza, ncertif,
                                  nsinies, cagente, ppartici,
                                  ccompapr, icesion, preserv,
                                  ireserv,
                                  icesion_moncon,
                                  ireserv_moncon,
                                  pinteresdep, iinterdep,
                                  iinterdep_moncon,
                                  pimpint, iimpint,
                                  iimpint_moncon
                                )
                          VALUES (
                                  reg.ccompani, reg.nversio, reg.scontra,
                                  reg.ctramo, reg.sproces, reg.scesrea,
                                  reg.cempres, reg.fcierre, reg.sproduc,
                                  reg.sseguro, reg.npoliza, reg.ncertif,
                                  reg.nsinies, reg.cagente, reg.pcesion /*reg.ppartici*/,                    -- EDBR - 07/07/2019 - IAXIS4617 Se cAjusta para que el campo partici tenga el porcentaje de cesion
                                  reg.ccompapr, /*reg.icesion*/v_icesion_aux, /*reg.preserv*/ v_preserv_aux, -- EDBR - 07/07/2019 - IAXIS4617 Se cambian los valores por las variables auxiliares
                                  w_ireserv,
                                  f_round(/*reg.icesion*/v_icesion_aux * v_itasa, v_cmoncontab),
                                  f_round(w_ireserv * v_itasa, v_cmoncontab),
                                  w_pinteresdep, w_iinterdep,
                                  f_round(w_iinterdep * v_itasa, v_cmoncontab),
                                  w_pimpint, w_iimpint,
                                  f_round(w_iimpint * v_itasa, v_cmoncontab)
                                  );
                  EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                  w_nnumlin := 1;
                     WHEN OTHERS THEN
                        p_tab_error(f_sysdate, f_user,
                                    'pac_reaseguro_rec.f_llenar_readeposito_aux', v_traza,
                                    'Err INSERT readepositoaux:' || reg.nversio || ', ' || reg.scontra || ', '
                                    || reg.ctramo || ', ' || reg.sproduc,
                                    ' SQLERRM = ' || SQLERRM);
                        psql := SQLERRM;
                        RETURN 105802;
                        END;
                     END IF;
               END;
          END IF;
  END LOOP;
RETURN 0;
END F_LLENAR_READEPOSITO_AUX;



-- *********************************************************
   PROCEDURE proceso_batch_cierre(
      pmodo IN NUMBER,
      pcempres IN NUMBER,
      pmoneda IN NUMBER,
      pcidioma IN NUMBER,
      pfperini IN DATE,
      pfperfin IN DATE,
      pfcierre IN DATE,
      pcerror OUT NUMBER,
      psproces OUT NUMBER,
      pfproces OUT DATE) IS
      /***********************************************************************************************
          Proceso que lanzar? el proceso de cierre del Border? de Reaseguro.
      ************************************************************************************************/
      -- 15/9/04 CPM: Se a?aden par?metros a la llamada, aunque no son necesarios
      --     para que sea compatible con el resto de cierres programados.
      num_err        NUMBER := 0;
      text_error     VARCHAR2(500);
      pnnumlin       NUMBER;
      texto          VARCHAR2(400);
      indice_error   NUMBER := 0;
      v_estado       NUMBER;
      v_titulo       procesoscab.tproces%TYPE;   -- BUG 0025803 VARCHAR2(50);
      psql           VARCHAR2(500);
      pscesrea       cesionesrea.scesrea%TYPE;   -- BUG 0025803  NUMBER(8);
      v_cursor       INTEGER;
      v_truncatereaseguroaux VARCHAR2(40);
      v_truncatemovctaaux VARCHAR2(40);
      v_numrows      INTEGER;
      hiha           NUMBER;
      vpar_traza     VARCHAR2(80) := 'TRAZA_CIERRE_PROP';
      v_nom_paquete  VARCHAR2(80) := 'PAC_REASEGURO_REC';
      v_nom_procedimiento VARCHAR2(80) := 'PROCESO_BATCH_CIERRE';
      v_traza        NUMBER := 0;
   BEGIN
      p_Control_Error ('PAC_REAEGURO_REC','PROCESO_BATCH_CIERRE','PASO 7777_1');
      IF pmodo = 1 THEN
         v_titulo := 'Borderó Reaseguro Mensual Previo';
      ELSIF pmodo = 2 THEN
         v_titulo := 'Borderó Reaseguro Mensual Definitivo';
      END IF;

      -- *** Insertamos en la tabla PROCESOSCAB el registro identificativo de proceso -----
      num_err := f_procesini(f_user, pcempres, 'REASEGURO1', v_titulo, psproces);
      v_traza := 41;
      p_traza_proceso(pcempres, vpar_traza, psproces, v_nom_paquete, NULL, v_nom_procedimiento,
                      v_traza,
                      'Inicio de proceso: ' || psproces || ' pmodo: ' || pmodo || ' pmoneda: '
                      || pmoneda || ' pcidioma: ' || pcidioma || ' pfperini: ' || pfperini
                      || ' pfperfin: ' || pfperfin || ' pfcierre: ' || pfcierre);

      -- BUG 11051 - 07/09/2009 - FAL - Llamada a p_genera_ces_pago si empresa definida como genarar cesion de pagos de siniestros
      IF pac_parametros.f_parempresa_n(pcempres, 'GEN_CES_PAG') = 1 THEN
         p_genera_ces_pago(pcempres, NULL, NULL, psproces, pcidioma, pfcierre);
         p_genera_ces_reemb(pcempres, NULL, NULL, psproces, pcidioma, pfcierre);   -- BUG 20836/111077 - 04/04/2012 - JMP -
         COMMIT;
      END IF;

      v_traza := 42;
       p_Control_Error ('PAC_REAEGURO_REC','PROCESO_BATCH_CIERRE','PASO 7777_2');
      -- FI Bug 11051 - 07/09/2009 - FAL
      IF num_err <> 0 THEN
         pcerror := 1;
         texto := f_axis_literales(num_err, pcidioma);
         pnnumlin := NULL;
         num_err := f_proceslin(psproces, SUBSTR(texto || ' ' || text_error, 1, 120), 0,
                                pnnumlin);
         COMMIT;
      --SET TRANSACTION USE ROLLBACK SEGMENT rollbig;
      ELSE
         p_Control_Error ('PAC_REAEGURO_REC','PROCESO_BATCH_CIERRE','PASO 7777_3');
         -- Esborrem nom?s all? que anem a generar
         COMMIT;
         p_traza_proceso(pcempres, vpar_traza, psproces, v_nom_paquete, NULL,
                         v_nom_procedimiento, v_traza, 'DELETE movctaaux');

         DELETE FROM movctaaux
               WHERE cempres = pcempres
                 AND TRUNC(fcierre) = TRUNC(pfperfin)
                 AND ctramo < 6
                 AND nid IS NULL;

		 -- AVT 01-08-2013 CONTROL NO BORRAR MOVIMIENTOS MANUALES
         COMMIT;
         p_traza_proceso(pcempres, vpar_traza, psproces, v_nom_paquete, NULL,
                         v_nom_procedimiento, v_traza, 'DELETE reaseguroaux');

         DELETE FROM reaseguroaux
               WHERE cempres = pcempres;

         DELETE FROM readepositoaux
               WHERE cempres = pcempres;

         COMMIT;
         v_traza := 43;

         IF num_err <> 0 THEN
            pcerror := 1;
            texto := f_axis_literales(num_err, pcidioma);
            pnnumlin := NULL;
            text_error := SUBSTR(texto || ' ' || psql, 1, 120);
            num_err := f_proceslin(psproces, text_error, pscesrea || '1', pnnumlin);
            COMMIT;
         -- SET TRANSACTION USE ROLLBACK SEGMENT rollbig;
         ELSE
--------------------------------------------------
--------------------------------------------------
   --  DBMS_OUTPUT.put_line ('VAMOS A TABLAS AUXILIARES');
    -- *** Se llenan las tablas auxiliares...
    -- BUG 9549 - 12/05/2009 - AVT - Se a?ade el reaseguro de ahorro por par?metro
            hiha := 0;
            p_Control_Error ('PAC_REAEGURO_REC','PROCESO_BATCH_CIERRE','PASO 7777_4');
            BEGIN
               SELECT COUNT(*)
                 INTO hiha
                 FROM cierres c, pds_program_cierres p
                WHERE c.ctipo = 11   -- 21012 AVT 20/01/2012
                  AND tdepen LIKE '%11%'
                  AND p.ctipo = 4
                  AND c.cestado = 1
                  AND p.cempres = c.cempres
                  AND p.cempres = pcempres
                  AND fperfin = pfperfin;
            EXCEPTION
               WHEN OTHERS THEN
                  p_tab_error(f_sysdate, f_user, 'pac_reaseguro_rec.proceso_batch_cierre',
                              v_traza,
                              'Err SELECT FROM cierres c, pds_program_cierres:' || pcempres
                              || ', ' || pfperfin,
                              ' SQLERRM = ' || SQLERRM);
                  num_err := 1;
            END;

            IF hiha = 1 THEN
               p_traza_proceso(pcempres, vpar_traza, psproces, v_nom_paquete, NULL,
                               v_nom_procedimiento, v_traza, 'Entramos en P_CESIONES_AHORRO');
               pac_cesionesrea.p_cesiones_ahorro(psproces, TO_CHAR(pfperfin, 'mm'),
                                                 TO_CHAR(pfperfin, 'yyyy'));
            END IF;

            p_Control_Error ('PAC_REAEGURO_REC','PROCESO_BATCH_CIERRE','PASO 7777_5');
            v_traza := 44;
            -- BUG 9549 - 12/05/2009 - AVT - Fi..........
            p_traza_proceso(pcempres, vpar_traza, psproces, v_nom_paquete, NULL,
                            v_nom_procedimiento, v_traza, 'Entramos en LLENAR_BORDERO_AUX');
            -- INICIO INFORCOL 15-01-2020
            num_err := llenar_bordero_aux(pcempres, pmodo, TO_CHAR(pfperfin, 'mm'),
                                          -- canvi pfcierre -> pfperfin
                                          TO_CHAR(pfperfin, 'yyyy'), pfcierre, psproces, psql,
                                          pscesrea, pfperfin);
            -- FIN INFORCOL 15-01-2020
            p_Control_Error ('PAC_REAEGURO_REC','PROCESO_BATCH_CIERRE','PASO 7777_6');
                                          p_traza_proceso(pcempres, vpar_traza, psproces, v_nom_paquete, NULL,
                            v_nom_procedimiento, v_traza, 'Entramos en LLENAR_BORDERO_AUX '||num_err);
            v_traza := 45;

            --            DBMS_OUTPUT.put_line('ERROR DE LLENAR_BORDERO_AUX: ' || num_err);
            IF num_err <> 0 THEN
               pcerror := num_err;
               texto := f_axis_literales(num_err, pcidioma);
               pnnumlin := NULL;
               text_error := SUBSTR(texto || ' ' || psql, 1, 120);
               num_err := f_proceslin(psproces, text_error, pscesrea || '2', pnnumlin);
               COMMIT;
            --  SET TRANSACTION USE ROLLBACK SEGMENT rollbig;
            ELSE
               p_Control_Error ('PAC_REAEGURO_REC','PROCESO_BATCH_CIERRE','PASO 7777_7');
               COMMIT;   -- COMMIT PRINCIPAL DEL PROCESO...
               -- SET TRANSACTION USE ROLLBACK SEGMENT rollbig;
               pcerror := 0;
               --
--               DBMS_OUTPUT.put_line('CIERRE DE RESERVAS DE SINIESTROS');
-- Llamamos al cierre de reservas de siniestros por la Reaseguro
--------------------------------------------------
--------------------------------------------------
               p_traza_proceso(pcempres, vpar_traza, psproces, v_nom_paquete, NULL,
                               v_nom_procedimiento, v_traza, 'Entramos en F_RESERVES_SINI');
               num_err := f_reserves_sini(psproces, pcempres, pfperfin, pcidioma);
               v_traza := 46;

               IF num_err <> 0 THEN
                  pcerror := 1;
                  texto := f_axis_literales(num_err, pcidioma);
                  pnnumlin := NULL;
                  text_error := SUBSTR(texto || ' ' || psql, 1, 120);
                  num_err := f_proceslin(psproces, text_error, pscesrea || '3', pnnumlin);
               ELSE
                  /*p_traza_proceso(pcempres, vpar_traza, psproces, v_nom_paquete, NULL,
                                  v_nom_procedimiento, v_traza, 'Entramos en F_CALCUL_PB');
                  num_err := f_calcul_pb(pmodo, pcempres, pfperfin, TO_CHAR(pfperfin, 'yyyy'), psproces); --CONF-587 (nuevo param psproces)
                  v_traza := 47;

                  IF num_err <> 0 THEN
                     pcerror := 1;
                     texto := f_axis_literales(num_err, pcidioma);
                     pnnumlin := NULL;
                     text_error := SUBSTR(texto || ' ' || psql, 1, 120);
                     num_err := f_proceslin(psproces, text_error, pscesrea || '3', pnnumlin);
--------------------------------------------------------
-- 13/06/2012 AVT 22076 crida a la nova funci? ---------
--------------------------------------------------------
                  ELSIF num_err = 0 THEN*/
                     p_traza_proceso(pcempres, vpar_traza, psproces, v_nom_paquete, NULL,
                                     v_nom_procedimiento, v_traza,
                                     'Entramos en F_LLENAR_MOVCTA_AUX');
                     num_err := f_llenar_movcta_aux(pcempres, TO_CHAR(pfperfin, 'mm'),
                                                    TO_CHAR(pfperfin, 'yyyy'), psproces);
                     v_traza := 48;


                     p_traza_proceso(pcempres, vpar_traza, psproces, v_nom_paquete, NULL,
                                     v_nom_procedimiento, v_traza,
                                     'Entramos en F_LLENAR_READEPOSITO_AUX');
                     num_err := f_llenar_readeposito_aux(pcempres, psproces);
                     v_traza := 49;
                     p_Control_Error ('PAC_REAEGURO_REC','PROCESO_BATCH_CIERRE','PASO 7777_8, num_err:'||num_err);
                     IF num_err <> 0 THEN
                        pcerror := 1;
                        texto := f_axis_literales(num_err, pcidioma);
                        pnnumlin := NULL;
                        text_error := SUBSTR(texto || ' ' || psql, 1, 120);
                        num_err := f_proceslin(psproces, text_error, pscesrea || '3',
                                               pnnumlin);
                     ELSE

                        p_traza_proceso(pcempres, vpar_traza, psproces, v_nom_paquete, NULL,
                                        v_nom_procedimiento, v_traza, 'Entramos en F_CALCUL_PB');
                        -- INICIO INFORCOL 18-11-2019
                        num_err := 0; -- f_calcul_pb(pmodo, pcempres, pfperfin, TO_CHAR(pfperfin, 'yyyy'), psproces); --CONF-587 (nuevo param psproces)
                        -- FIN INFORCOL 18-11-2019
                        v_traza := 47;
                        p_Control_Error ('PAC_REAEGURO_REC','PROCESO_BATCH_CIERRE','PASO 7777_9');
                        IF num_err <> 0 THEN
                           pcerror := 1;
                           texto := f_axis_literales(num_err, pcidioma);
                           pnnumlin := NULL;
                           text_error := SUBSTR(texto || ' ' || psql, 1, 120);
                           num_err := f_proceslin(psproces, text_error, pscesrea || '3', pnnumlin);

                        ELSE

                           IF pmodo = 2 THEN   -- BORDER? DEFINITIVO...

                              p_traza_proceso(pcempres, vpar_traza, psproces, v_nom_paquete, NULL,
                                              v_nom_procedimiento, v_traza,
                                              'Entramos en LLENAR_TABLAS_DEFI');

                                              num_err :=llenar_tablas_defi(psql, pscesrea, pcempres, pfperfin);

                                            --  llenar_tablas_defi(psql, pscesrea, pcempres, pfperfin);
                              v_traza := 49;

                                p_traza_proceso(pcempres, vpar_traza, psproces, v_nom_paquete, NULL,
                                              v_nom_procedimiento, 51,
                                              'Entramos en LLENAR_TABLAS_DEFI2 '||num_err||'-'||pfperfin||'-'||pcempres||'-'||pscesrea||'-'||psql);

                              IF num_err <> 0 THEN
                                 pcerror := 1;
                                 texto := f_axis_literales(num_err, pcidioma);
                                 pnnumlin := NULL;
                                 text_error := SUBSTR(texto || ' ' || psql, 1, 120);
                                 num_err := f_proceslin(psproces, text_error, pscesrea || '3',
                                                        pnnumlin);
                                 COMMIT;
                              ELSE
                                 COMMIT;

								 --CONF-692 Inicio
                                 --
                                 p_reexpresion_principal(pcempres,
                                                         psproces,
                                                         pfperfin,
                                                         num_err);
                                 --
                                 --CONF-692 Fin

                                 pcerror := 0;
                                 p_traza_proceso(pcempres, vpar_traza, psproces, v_nom_paquete,
                                                 NULL, v_nom_procedimiento, v_traza,
                                                 'Entramos en ACTU_DATES');
                                 num_err := actu_dates(pcempres, TO_NUMBER(TO_CHAR(pfperfin, 'mm')),
                                                       TO_NUMBER(TO_CHAR(pfperfin, 'yyyy')),
                                                       pfcierre, psql, pscesrea);
                                 v_traza := 50;

                                 IF num_err <> 0 THEN
                                    pcerror := 1;
                                    texto := f_axis_literales(num_err, pcidioma);
                                    pnnumlin := NULL;
                                    text_error := SUBSTR(texto || ' ' || psql, 1, 120);
                                    num_err := f_proceslin(psproces, text_error, pscesrea || '4',
                                                           pnnumlin);
                                    COMMIT;
                                 ELSE
      --------------------------------------------------
      --------------------------------------------------
      -- Tanquem la participaci? en beneficis
                                    p_traza_proceso(pcempres, vpar_traza, psproces, v_nom_paquete,
                                                    NULL, v_nom_procedimiento, v_traza,
                                                    'Entramos en F_CALCUL_PB');
                                    num_err := f_calcul_pb(pmodo, pcempres, pfperfin,
                                                           TO_CHAR(pfperfin, 'yyyy'), psproces); --CONF-587 (nuevo param psproces)
                                    v_traza := 51;

                                    IF num_err <> 0 THEN
                                       pcerror := 1;
                                       texto := f_axis_literales(num_err, pcidioma);
                                       pnnumlin := NULL;
                                       text_error := SUBSTR(texto || ' ' || psql, 1, 120);
                                       num_err := f_proceslin(psproces, text_error, pscesrea || '4',
                                                              pnnumlin);
                                       COMMIT;
                                    ELSE
                                       --AGG 24/03/2014
                                       p_traza_proceso(pcempres, vpar_traza, psproces,
                                                       v_nom_paquete, NULL, v_nom_procedimiento,
                                                       v_traza, 'Entramos en F_INSERT_SALDO');
                                       num_err := f_insert_saldo(pcempres, TO_CHAR(pfperfin, 'mm'),
                                                                 TO_CHAR(pfperfin, 'yyyy'),
                                                                 psproces);
                                       v_traza := 52;

                                       IF num_err <> 0 THEN
                                          pcerror := 1;
                                          texto := f_axis_literales(num_err, pcidioma);
                                          pnnumlin := NULL;
                                          text_error := SUBSTR(texto || ' ' || psql, 1, 120);
                                          num_err := f_proceslin(psproces, text_error,
                                                                 pscesrea || '4', pnnumlin);
                                          COMMIT;
                                       ELSE
                                          COMMIT;
                                       END IF;
                                    END IF;
                                 END IF;
                              END IF;
                           END IF;
                        END IF;
                  END IF;
               END IF;
            END IF;
         END IF;
      END IF;
      p_Control_Error ('PAC_REAEGURO_REC','PROCESO_BATCH_CIERRE','PASO 7777_10');
      num_err := f_procesfin(psproces, pcerror);
      pfproces := f_sysdate;

      IF num_err = 0 THEN
         --         DBMS_OUTPUT.put_line ('fin del proceso. hacemos commit');
         COMMIT;
      --SET TRANSACTION USE ROLLBACK SEGMENT rollbig;
      END IF;
   END proceso_batch_cierre;

-- **********************************************************
   FUNCTION llenar_bordero_aux(
      pcempres IN NUMBER,
      pdefi IN NUMBER,
      pmes IN NUMBER,
      pany IN NUMBER,
      pfcierre IN DATE,
      pproces IN NUMBER,
      psql OUT VARCHAR2,
      pscesrea OUT NUMBER,
      pfperfin IN DATE)
      RETURN NUMBER IS
      perror         NUMBER := 0;
      texto          VARCHAR2(100);
      w_proces       procesoscab.sproces%TYPE;   -- BUG 0025803 NUMBER(6);
      w_icomisi      reaseguroaux.icomisi%TYPE;   -- BUG 0025803 NUMBER(13, 2);
      w_scontra      cesionesrea.scontra%TYPE;   -- BUG 0025803 NUMBER(6);
      w_nversio      cesionesrea.nversio%TYPE;   -- BUG 0025803 NUMBER(2);
      w_ctramo       cesionesrea.ctramo%TYPE;   -- BUG 0025803 NUMBER(2);
      w_ccomrea      comisreas.ccomrea%TYPE;   -- BUG 0025803 NUMBER(4);
      w_fefecto      cesionesrea.fefecto%TYPE;   -- BUG 0025803 DATE;
      w_fvencim      cesionesrea.fvencim%TYPE;   -- BUG 0025803 DATE;
      w_cgarant      garangen.cgarant%TYPE;   -- BUG 0025803 NUMBER(4);
      w_scomrea      NUMBER(6);
      w_sseguro      seguros.sseguro%TYPE;   --Mantis 0001487 --Ampliaci?n tama?o campo SSEGURO
      w_pcomias      reaseguroaux.pcomisi%TYPE;   -- BUG 0025803 NUMBER(5, 2);
      w_icesion      reaseguroaux.icesion%TYPE;   -- BUG 0025803 NUMBER(13, 2) := 0;
      w_idtosel      NUMBER;
      w_ipritarrea   NUMBER;
      w_psobreprima  NUMBER;
      nrecibo        NUMBER;
      w_icapces      reaseguroaux.icapces%TYPE;   -- BUG 0025803 NUMBER(15, 2);
      numlin         NUMBER := 0;
      w_nnumlin      movctaaux.nnumlin%TYPE;   -- BUG 0025803 NUMBER(6);
      w_cconcep      NUMBER(2);
      w_cdebhab      NUMBER(1);
      w_cestado      NUMBER(2);
      w_reserva      movctaaux.iimport%TYPE;   -- BUG 0025803 NUMBER(13, 2);
      w_pcesion      cesionesrea.pcesion%TYPE;   -- BUG 0025803 NUMBER(8, 5) := 0;
      w_aux          cesionesrea.icapces%TYPE;   -- BUG 0025803 NUMBER(13, 2);
      w_pnostre      NUMBER(8, 5);
      w_porce        NUMBER(8, 5);
      w_icestot      reaseguroaux.icesion%TYPE;   -- BUG 0025803 NUMBER(13, 2) := 0;
      w_idtoseltot   NUMBER;
      w_ipritarreatot NUMBER;
      w_icaptot      reaseguroaux.icapces%TYPE;   -- BUG 0025803 NUMBER(15, 2);
      w_volta        NUMBER(1);
      w_dataseg      DATE;
      w_nriesgo      cesionesrea.nriesgo%TYPE;   -- BUG 0025803 NUMBER(6);
      data_t         DATE;
      avui           DATE;
      w_cramo        seguros.cramo%TYPE;
      w_cmodali      seguros.cmodali%TYPE;   -- BUG 0025803 NUMBER(4);
      w_ctipseg      seguros.ctipseg%TYPE;   -- BUG 0025803 NUMBER(4);
      w_ccolect      seguros.ccolect%TYPE;   -- BUG 0025803 NUMBER(4);
      w_cactivi      seguros.cactivi%TYPE;   -- BUG 0025803 NUMBER(4);
      w_cagente      seguros.cagente%TYPE;   -- BUG 0025803 NUMBER;
--VARCHAR2(8);   -- Bug 18225 - APD - 11/04/2011 - la precisi?n debe ser NUMBER
      w_cagrpro      seguros.cagrpro%TYPE;   -- BUG 0025803 NUMBER(2);
      w_npoliza      seguros.npoliza%TYPE;   -- BUG 0025803 NUMBER(10);
      w_sfacult      cesionesrea.sfacult%TYPE;   -- BUG 0025803 NUMBER(6);
      w_ncertif      seguros.ncertif%TYPE;   -- BUG 0025803 NUMBER(6);
      w_idtoseltotot NUMBER;
      contador       NUMBER := 0;
      error          NUMBER;
      vcpais         NUMBER;
      -- AVT 20/04/2005
      v_protegit_xl  NUMBER;
      v_pxl          NUMBER;
      w_ctrxl        NUMBER;
      w_verxl        NUMBER;
      w_traxl        NUMBER;
      -- AVT 27/04/2005
      v_nomes_comis  NUMBER;
      w_sproduc      NUMBER;
      -- AVT 05/07/2005
      v_nfaccor      NUMBER;
      v_icesbonus    NUMBER;
      -- BUG 11595 - 04/11/2009 - APD - Adaptaci?n al nuevo m?dulo de siniestros
      w_cempres      NUMBER;
      -- 26252 KBR Recibos cobrados parcialmente 24042013
      v_continua     NUMBER(1) := 0;
      --BUG 0026444 - 27/07/2013 - JRH - Prima XL Facultativo
      vprimatotces   NUMBER;
      w_iextrea      reaseguroaux.iextrea%TYPE;
      w_iextreatot   reaseguroaux.iextrea%TYPE;
      v_iretenido    NUMBER; --CONFCC-5



      --Fi BUG 0026444 - 27/07/2013 - JRH
      -- INI -IAXIS-13133 -27/04/2020
      CURSOR cur_ces(wcempres NUMBER, wdefi NUMBER, wfcierre DATE, wmes NUMBER, wany NUMBER) IS
      SELECT ce.scontra,
             ce.nversio,
             ce.ctramo,
             ce.cgarant,
             ce.sseguro,
             ce.nriesgo,
             ce.nmovimi,
             ce.sfacult,
             ce.fefecto,
             ce.fvencim,
             ce.pcesion,
             ce.icesion,
             ce.icapces,
             ce.scesrea,
             0 sreaemi,
             ce.cgenera,
             ce.sproces,
             ce.nsinies,
             ce.sidepag,
             0 ifacced,
             decode(tr.ctramo, 1, tr.plocal, NULL) plocal,
             decode(tr.ctramo, 1, tr.imaxplo, NULL) imaxplo,
             decode(tr.ctramo, 1, tr.nsegcon, NULL) nsegcon,
             decode(tr.ctramo, 1, tr.nsegver, NULL) nsegver,
             decode(ce.cgenera, 2, 0, 6, 2, 1) cmotces,
             -- 0 cmotces,  -- BUG 9549 - 13/05/2009 - AVT - Se a?ade el reaseguro de ahorro
             0 nrecibo,
             -- BUG 10844 - 31/07/2009 - FAL - Se corrige para se agigne la sobreprima en el cierre
             --              0 ipritarrea, 0 idtosel, 0 psobreprima,
             nvl(ce.ipritarrea, 0) ipritarrea,
             nvl(ce.idtosel, 0) idtosel,
             nvl(ce.psobreprima, 0) psobreprima,
             -- FI Bug 10844 - 31/07/2009 - FAL
             tr.nctrxl,
             tr.nverxl,
             tr.ptasaxl, -- AVT 25/04/2005

             -- BUG 11051 - 16/09/2009 - FAL - Informar camps de comptabilitat a partir de cesionesrea
             ce.nreemb,
             ce.nfact,
             ce.nlinea,
             0         ctipfac, --BUG 0026444 - 27/07/2013 - JRH - Sacamos ctipfacPrima XL Facultativo
             -- FI Bug 11051 - 16/09/2009 - FAL
             ce.icomext, --AGG 08/05/2014 Se añade la comisión de la extra prima
             ce.iextrea --AGG 02/07/2014 Se añade la extra prima
        FROM tramos        tr,
             cesionesrea   ce,
             codicontratos ct,
             seguros       s
       WHERE ct.cempres = wcempres
         AND ce.sseguro = s.sseguro
            --BUG-13084 INI
         AND ((ce.cgenera = 2 OR nvl(ce.cdetces, 0) = 0)
             -- BUG: 17672 JGR 23/02/2011 hasta
             --ML 5066 - 11/09/2019 - 4 SON LAS CESIONES MANUALES
             -- ML REV1 - 13084 - ESPECIFICACION DE APUNTES MANUALES CON FILTRO EXTRA
             OR (ce.cgenera = 4 AND ce.ctipomov = 'M'))
            --BUG-13084 FIN
            -- FI Bug 10637 - 06/07/2009 - FAL
         AND ct.scontra = ce.scontra
         AND ce.fgenera < wfcierre + 1
         AND ((wdefi < 3 AND ce.fcontab IS NULL) OR (wdefi = 2 AND ce.fcontab = last_day(to_date('01' || '/' || wmes || '/' || wany, 'dd/mm/yyyy'))))
         AND trunc (ce.fefecto) <= last_day(to_date('01' || '/' || wmes || '/' || wany, 'dd/mm/yyyy'))
         AND tr.scontra = ce.scontra
         AND tr.nversio = ce.nversio
         AND tr.ctramo = ce.ctramo
         AND (tr.fultbor IS NULL OR wdefi = 2 OR (tr.cfrebor = 1 AND tr.fultbor < to_date('01' || '/' || wmes || '/' || wany, 'dd/mm/yyyy')) OR
             (tr.cfrebor = 2 AND tr.fultbor < add_months(to_date('01' || '/' || wmes || '/' || wany, 'dd/mm/yyyy'), -1)) OR
             (tr.cfrebor = 3 AND tr.fultbor < add_months(to_date('01' || '/' || wmes || '/' || wany, 'dd/mm/yyyy'), -2)) OR
             (tr.cfrebor = 4 AND tr.fultbor < add_months(to_date('01' || '/' || wmes || '/' || wany, 'dd/mm/yyyy'), -3)) OR
             (tr.cfrebor = 6 AND tr.fultbor < add_months(to_date('01' || '/' || wmes || '/' || wany, 'dd/mm/yyyy'), -5)) OR
             (tr.cfrebor = 12 AND tr.fultbor < add_months(to_date('01' || '/' || wmes || '/' || wany, 'dd/mm/yyyy'), -11)))
      UNION
      SELECT cu.scontra,
             cu.nversio,
             ce.ctramo,
             ce.cgarant,
             ce.sseguro,
             ce.nriesgo,
             ce.nmovimi,
             ce.sfacult,
             ce.fefecto,
             ce.fvencim,
             ce.pcesion,
             ce.icesion,
             ce.icapces,
             ce.scesrea,
             0          sreaemi,
             ce.cgenera,
             ce.sproces,
             ce.nsinies,
             ce.sidepag,
             cu.ifacced,
             0          plocal,
             NULL       imaxplo,
             NULL       nsegcon,
             NULL       nsegver,
             0          cmotces,
             0          nrecibo,
             -- BUG 10844 - 31/07/2009 - FAL - Se corrige para se agigne la sobreprima en el cierre
             --              0 ipritarrea, 0 idtosel, 0 psobreprima,
             nvl(ce.ipritarrea, 0) ipritarrea,
             nvl(ce.idtosel, 0) idtosel,
             nvl(ce.psobreprima, 0) psobreprima,
             -- FI Bug 10844 - 31/07/2009 - FAL
             0          nctrxl,
             0          nverxl,
             cu.ptasaxl ptasaxl, --BUG 0026444 - 27/07/2013 - JRH - Prima XL Facultativo volvemos a poner el tasaXL  -- AVT 25/04/2005
             -- BUG 11051 - 16/09/2009 - FAL - Informar camps de comptabilitat a partir de cesionesrea
             ce.nreemb,
             ce.nfact,
             ce.nlinea,
             cu.ctipfac ctipfac, --BUG 0026444 - 27/07/2013 - JRH -Sacamos ctipfac
             -- FI Bug 11051 - 16/09/2009 - FAL
             ce.icomext, --AGG 08/05/2014 Se añade la comisión de la extra prima
             ce.iextrea --AGG 02/07/2014 Se añade la extra prima
        FROM cesionesrea ce,
             cuafacul    cu,
             seguros     s
       WHERE ce.sseguro = s.sseguro
         AND s.cempres = wcempres
         AND(ce.cgenera = 2 OR NVL(ce.cdetces, 0) = 0)
            -- FI Bug 10637 - 06/07/2009 - FAL
         AND ce.sfacult = cu.sfacult
         AND ce.fgenera < wfcierre + 1
         AND ((wdefi < 3 AND ce.fcontab IS NULL)
             -- Per tal de controlar que no es contabilitzin registres posteriorment als tancament de ventes
             OR (wdefi = 2 AND ce.fcontab = last_day(to_date('01' || '/' || wmes || '/' || wany, 'dd/mm/yyyy'))))
         AND ce.fefecto <= last_day(to_date('01' || '/' || wmes || '/' || wany, 'dd/mm/yyyy'))
         AND ce.ctramo = 5
            --BUG 0026444 - 27/07/2013 - JRH - Prima XL Facultativo Generamos la tasa del XL Facultativo (pero sólo la tasa , la partede siniestros va en el cierre)
         AND (nvl(cu.ctipfac, 0) = 0 OR (nvl(cu.ctipfac, 0) <> 0 AND ce.cgenera <> 2))
      --Fi BUG 0026444 - 27/07/2013 - JRH
      UNION
      SELECT de.scontra,
             de.nversio,
             de.ctramo,
             de.cgarant,
             re.sseguro,
             de.nriesgo,
             ce.nmovimi,
             de.sfacult,
             re.fefecte,
             re.fvencim,
             de.pcesion,
             de.icesion,
             de.icapces,
             ce.scesrea,
             de.sreaemi,
             --de.sreaemi scesrea, AVT
             ce.cgenera,
             re.sproces,
             0 nsinies,
             0 sidepag,
             0 ifacced,
             decode(tr.ctramo, 1, tr.plocal, NULL) plocal,
             decode(tr.ctramo, 1, tr.imaxplo, NULL) imaxplo,
             decode(tr.ctramo, 1, tr.nsegcon, NULL) nsegcon,
             decode(tr.ctramo, 1, tr.nsegver, NULL) nsegver,
             re.cmotces,
             re.nrecibo,
             de.ipritarrea,
             de.idtosel,
             de.psobreprima,
             tr.nctrxl,
             tr.nverxl,
             tr.ptasaxl, -- AVT 25/04/2005

             -- BUG 11051 - 16/09/2009 - FAL - Informar camps de comptabilitat a partir de cesionesrea
             ce.nreemb,
             ce.nfact,
             ce.nlinea,
             0         ctipfac, --BUG 0026444 - 27/07/2013 - JRH -Sacanmos ctipfac
             -- FI Bug 11051 - 16/09/2009 - FAL
             ce.icomext, --AGG 08/05/2014 Se añade la comisión de la extra prima
             ce.iextrea --AGG 02/07/2014 Se añade la extra prima
        FROM tramos        tr,
             reasegemi     re,
             detreasegemi  de,
             codicontratos ct,
             cesionesrea   ce
       WHERE ct.cempres = wcempres
         AND ct.scontra = de.scontra
         AND re.fgenera < wfcierre + 1
         AND nvl(ce.cdetces, 0) = 1
            -- BUG: 17672 JGR 23/02/2011 - Volem el detall per rebut
         AND ((wdefi < 3 AND re.fcierre IS NULL)
             -- Per tal de controlar que no es contabilitzin registres posteriorment als tancament de ventes
             OR (wdefi = 2 AND re.fcierre = last_day(to_date('01' || '/' || wmes || '/' || wany, 'dd/mm/yyyy'))))
         AND re.fefecte <= last_day(to_date('01' || '/' || wmes || '/' || wany, 'dd/mm/yyyy'))
         AND tr.scontra = de.scontra
         AND tr.nversio = de.nversio
         AND re.sreaemi = de.sreaemi
         AND tr.ctramo = de.ctramo
         AND de.scesrea = ce.scesrea
         AND (tr.fultbor IS NULL OR wdefi = 2 OR (tr.cfrebor = 1 AND tr.fultbor < to_date('01' || '/' || wmes || '/' || wany, 'dd/mm/yyyy')) OR
             (tr.cfrebor = 2 AND tr.fultbor < add_months(to_date('01' || '/' || wmes || '/' || wany, 'dd/mm/yyyy'), -1)) OR
             (tr.cfrebor = 3 AND tr.fultbor < add_months(to_date('01' || '/' || wmes || '/' || wany, 'dd/mm/yyyy'), -2)) OR
             (tr.cfrebor = 4 AND tr.fultbor < add_months(to_date('01' || '/' || wmes || '/' || wany, 'dd/mm/yyyy'), -3)) OR
             (tr.cfrebor = 6 AND tr.fultbor < add_months(to_date('01' || '/' || wmes || '/' || wany, 'dd/mm/yyyy'), -5)) OR
             (tr.cfrebor = 12 AND tr.fultbor < add_months(to_date('01' || '/' || wmes || '/' || wany, 'dd/mm/yyyy'), -11)))
      UNION
      SELECT de.scontra,
             de.nversio,
             de.ctramo,
             de.cgarant,
             re.sseguro,
             de.nriesgo,
             ce.nmovimi,
             de.sfacult,
             re.fefecte,
             re.fvencim,
             de.pcesion,
             de.icesion,
             de.icapces,
             ce.scesrea,
             de.sreaemi,
             --de.sreaemi scesrea, AVT
             ce.cgenera,
             re.sproces,
             0              nsinies,
             0              sidepag,
             cu.ifacced,
             0              plocal,
             NULL           imaxplo,
             NULL           nsegcon,
             NULL           nsegver,
             re.cmotces,
             re.nrecibo,
             de.ipritarrea,
             de.idtosel,
             de.psobreprima,
             0              nctrxl,
             0              nverxl,
             cu.ptasaxl     ptasaxl, --BUG 0026444 - 27/07/2013 - JRH - volvemos a poner el tasaXL
             -- AVT 25/04/2005
             -- BUG 11051 - 16/09/2009 - FAL - Informar camps de comptabilitat a partir de cesionesrea
             ce.nreemb,
             ce.nfact,
             ce.nlinea,
             cu.ctipfac ctipfac, --BUG 0026444 - 27/07/2013 - JRH - Sacamos ctipfac
             ce.icomext, --AGG 08/05/2014 Se añade la comisión de la extra prima
             ce.iextrea --AGG 02/07/2014 Se añade la extra prima
      -- FI Bug 11051 - 16/09/2009 - FAL
        FROM reasegemi    re,
             detreasegemi de,
             cuafacul     cu,
             seguros      s,
             cesionesrea  ce
       WHERE re.sseguro = s.sseguro
         AND s.cempres = wcempres
         AND de.sfacult = cu.sfacult
         AND de.scesrea = ce.scesrea
         AND re.fgenera < wfcierre + 1
         AND nvl(ce.cdetces, 0) = 1
            -- BUG: 17672 JGR 23/02/2011 - Volem el detall per rebut
         AND ((wdefi < 3 AND re.fcierre IS NULL)
             -- Per tal de controlar que no es contabilitzin registres posteriorment als tancament de ventes
             OR (wdefi = 2 AND re.fcierre = last_day(to_date('01' || '/' || wmes || '/' || wany, 'dd/mm/yyyy'))))
         AND re.fefecte <= last_day(to_date('01' || '/' || wmes || '/' || wany, 'dd/mm/yyyy'))
         AND re.sreaemi = de.sreaemi
         AND de.ctramo = 5
            --BUG 0026444 - 27/07/2013 - JRH - Generamos la tasa del XL Facultativo (pero sólo la tasa , la partede siniestros va en el cierre)
         AND (nvl(cu.ctipfac, 0) = 0 OR (nvl(cu.ctipfac, 0) <> 0 AND ce.cgenera <> 2));
      -- FIN -IAXIS-13133 -27/04/2020
      --Fi BUG 0026444 - 27/07/2013 - JRH
      CURSOR cur_cuadroces(wscontra NUMBER, wnversio NUMBER, wctramo NUMBER, wsfacult NUMBER) IS
         SELECT   cc.ccompani, cc.ccomrea, pctcomis pcomisi,
                                                            -- 21398 AVT 23/02/2012
                                                            cc.icomfij, cc.pcesion, cc.preserv,
                  scontra, ccorred   -- 22076 AVT 25/05/2012
             FROM cuadroces cc
            WHERE scontra = wscontra
              AND nversio = wnversio
              AND ctramo = wctramo
              AND ctramo <> 5
			  AND f_compania_cutoff(cc.ccompani, TRUNC(SYSDATE)) = 0 --CONF-910
         UNION
         SELECT   ccompani, ccomrea,   -- 21398 AVT 23/02/2012
                                    -- INICIO INFORCOL 12-03-2020
                                    pcomisi, icomfij, pcesion, presrea/*preserv*/, 0 scontra,
                                    -- FIN INFORCOL 12-03-2020
                  ccompani ccorred   -- 22076 AVT 25/05/2012
             FROM cuacesfac
            WHERE sfacult = wsfacult
			  AND f_compania_cutoff(ccompani, TRUNC(SYSDATE)) = 0 --CONF-910
         ORDER BY pcesion DESC;

      CURSOR cur_comisrea(wccomrea NUMBER, wfefecto DATE, wfvencim DATE) IS
         SELECT scomrea, fcomini, fcomfin
           FROM comisreas
          WHERE ccomrea = wccomrea
            AND fcomini <= wfefecto
            AND(fcomfin > wfvencim
                OR fcomfin IS NULL);
------------------------------------------------------------------------
------------------------------------------------------------------------
   BEGIN
      --  DBMS_OUTPUT.put_line ('LEEMOS LOS MOVIMIENTOS DE CESIONESREA');
      -- AQU? LLEGEIXO ELS MOVIMENTS DE CESIONESREA AFECTATS I CREO REASEGUROAUX
      -- AMB DADES DE COMISSIONS,ETC...
      w_proces := pproces;
      perror := pdefi;
      v_traza := 52;


      p_traza_proceso(pcempres, 'TRAZA_CIERRE_PROP', pproces, 'REASEGURO REC', NULL,
                            'Bordero', 52, 'Entramos en LLENAR_BORDERO_AUX '||perror);

      FOR regces IN cur_ces(pcempres, pdefi, pfcierre, pmes, pany) LOOP
         perror:=0;
         -- 26252 KBR 21/03/2013 Permitir Reaseguro por recibo parcialmente cobrado
         IF NVL(pac_parametros.f_parempresa_n(pcempres, 'CESION_COBRO_PARCIAL'), 0) = 1
            --  AND regces.nrecibo IS NOT NULL THEN -- 0026800/0146275 AVT 10/06/2013
            AND NVL(regces.nrecibo, 0) <> 0 THEN   -- 0026800/0146275 AVT 10/06/2013 en cas de sinistres el NRECIBO = 0
            --Validamos que el recibo no ha sido tratado antes
            BEGIN
               SELECT DISTINCT 1
                          INTO v_continua
                          FROM reaseguro rr
                         WHERE rr.nrecibo = regces.nrecibo;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  v_continua := 0;
               WHEN OTHERS THEN
                  v_continua := 0;
            END;

            IF v_continua = 0 THEN
               BEGIN
                  --Cobrado parcialmente
                  SELECT DISTINCT 1
                             INTO v_continua
                             FROM detmovrecibo dr
                            WHERE dr.nrecibo = regces.nrecibo;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     BEGIN
                        --Cobrado totalmente (CESTREC = 1, CESTANT = 0) o devuelto (CESTREC = 0, CESTANT = 1)
                        SELECT DISTINCT 1
                                   INTO v_continua
                                   FROM movrecibo mr
                                  WHERE mr.smovrec = (SELECT MAX(mr2.smovrec)
                                                        FROM movrecibo mr2
                                                       WHERE mr2.nrecibo = regces.nrecibo)
                                    AND((mr.cestrec = 1
                                         AND mr.cestant = 0)
                                        OR(mr.cestrec = 0
                                           AND mr.cestant = 1));
                     EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                           v_continua := 0;
                     END;
                  WHEN OTHERS THEN
                     v_continua := 0;
               END;
            END IF;
         ELSE
            v_continua := 1;
         END IF;

         IF v_continua = 1 THEN
        --  DBMS_OUTPUT.put_line ('sseguro :' || regces.sseguro);
--------------------------
        --  DBMS_OUTPUT.put_line ('DENTRO DEL CURSOR DE LLENADO DE BORDERO');
            w_scontra := regces.scontra;
            w_nversio := regces.nversio;
            w_ctramo := regces.ctramo;
            w_fefecto := regces.fefecto;
            w_fvencim := regces.fvencim;
            w_cgarant := regces.cgarant;
            w_sseguro := regces.sseguro;
            w_nriesgo := regces.nriesgo;
            w_sfacult := regces.sfacult;
            v_traza := 53;

            -- BUG 0038439 - FAL - 19/11/2015 - round a moneda producto
            SELECT pac_monedas.f_moneda_producto(sproduc)
              INTO v_cmonpol
              FROM seguros
             WHERE sseguro = w_sseguro;

            -- FI BUG 0038439
            BEGIN
               -- Bug 9685 - APD - 27/04/2009 - en lugar de coger la actividad de la tabla seguros, llamar a la funci?n pac_seguros.ff_get_actividad
               SELECT cramo, cmodali, ctipseg, ccolect,
                      pac_seguros.ff_get_actividad(sseguro, w_nriesgo) cactivi, cagente,
                      cagrpro, npoliza, ncertif, sproduc, cempres
                 -- -- BUG 11595 - 04/11/2009 - APD - Adaptaci?n al nuevo m?dulo de siniestros
               INTO   w_cramo, w_cmodali, w_ctipseg, w_ccolect,
                      w_cactivi, w_cagente,
                      w_cagrpro, w_npoliza, w_ncertif, w_sproduc,
                                                                 --27/04/2005
                                                                 w_cempres
                 -- BUG 11595 - 04/11/2009 - APD - Adaptaci?n al nuevo m?dulo de siniestros
               FROM   seguros
                WHERE sseguro = regces.sseguro;
            -- Bug 9685 - APD - 27/04/2009 - Fin
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  p_tab_error(f_sysdate, f_user, 'pac_reaseguro_rec.llenar_bordero_aux',
                              v_traza, 'Err NO_DATA_FOUND FROM seguros:' || regces.sseguro,
                              ' SQLERRM = ' || SQLERRM);
                  perror := 101903;
                  psql := SQLERRM;
                  pscesrea := regces.scesrea;
               WHEN OTHERS THEN
                  p_tab_error(f_sysdate, f_user, 'pac_reaseguro_rec.llenar_bordero_aux',
                              v_traza, 'Err SELECT FROM seguros:' || regces.sseguro,
                              ' SQLERRM = ' || SQLERRM);
                  perror := 101919;
                  psql := SQLERRM;
                  pscesrea := regces.scesrea;
            END;

            v_traza := 54;

            -- Aquí se mira si es una cesión del tramo 1 con un máximo de retención 
            -- por parte nuestro (IMAXPLO de tramo 1 informado) ... 
            -- Si es un pago de siniestro (CGENERA = 2) y pertenece al tramo 1 de un 
            -- contrato con imaxplo, busca los % reales de la cesión original en el 
            -- único lugar donde se guardan, es decir en la tabla REASEGURO (en un 
            -- pago de siniestro, hemos guardado el SCESREA original de la cesión 
            -- en el campo SPROCES de CESIONESREA) ... 
            -- Tambien se mira si hay un contrato secundario que cubra nuestra 
            -- participación en un "cuota parte" ... 
            -- Aquí se preparan los campos para llamar el desglose por compañías (una sola 
            -- vez, si no hay contrato secundario, o dos veces si es tramo 1 y hay un 
            -- contrato secundario (NSEGCON)) ..
            IF perror = 0 THEN
               w_icomisi := 0;
               w_pcomias := 0;
               w_icestot := regces.icesion;
			   --CONF-910 Inicio
               w_icestot := f_total_concutoff(w_scontra,
                                              w_nversio,
                                              w_ctramo,
                                              TRUNC(SYSDATE),
                                              w_icestot,
                                              perror);
               --CONF-910 Fin
               --
               w_iextreatot := regces.iextrea;
               --  DBMS_OUTPUT.put_line ('w_icestot :' || w_icestot);
               w_idtoseltot := regces.idtosel;
               w_ipritarreatot := regces.ipritarrea;
               w_icaptot := regces.icapces;
			   --CONF-910 Inicio
               w_icaptot := f_total_concutoff(w_scontra,
                                              w_nversio,
                                              w_ctramo,
                                              TRUNC(SYSDATE),
                                              w_icaptot,
                                              perror);
               --CONF-910 Fin

               IF regces.nsegcon IS NOT NULL THEN
                  w_volta := 0;

                  IF regces.cgenera = 2 THEN   -- si es un pago, cogemos la..
                     v_traza := 55;

                     BEGIN   -- la data del sinistros...
                        -- BUG 11595 - 04/11/2009 - APD - Adaptaci?n al nuevo m?dulo de siniestros
                        IF NVL(pac_parametros.f_parempresa_n(w_cempres, 'MODULO_SINI'), 0) = 0 THEN
                           SELECT fsinies
                             INTO w_dataseg
                             FROM siniestros
                            WHERE nsinies = regces.nsinies;
                        ELSE
                           SELECT fsinies
                             INTO w_dataseg
                             FROM sin_siniestro
                            WHERE nsinies = regces.nsinies;
                        END IF;
                     -- Fin BUG 11595 - 04/11/2009 - APD - Adaptaci?n al nuevo m?dulo de siniestros
                     EXCEPTION
                        WHEN OTHERS THEN
                           p_tab_error(f_sysdate, f_user,
                                       'pac_reaseguro_rec.llenar_bordero_aux', v_traza,
                                       'Err SELECT FROM siniestros:' || regces.nsinies,
                                       ' SQLERRM = ' || SQLERRM);
                           perror := 105144;
                           psql := SQLERRM;
                           pscesrea := regces.scesrea;
                     END;
                  ELSE
                     w_dataseg := w_fefecto;
                  END IF;

                  IF perror = 0 THEN
                     w_nversio := regces.nsegver;
                  END IF;
               ELSE
                  w_volta := 1;
               END IF;
            END IF;

            v_traza := 56;

            --  DBMS_OUTPUT.put_line (   'w_volta : '
                --                   || w_volta
                  --                 || ' regces.cgenera:'
                    --               || regces.cgenera
                      --            );
             --DBMS_OUTPUT.put_line ('regces.nctrxl : ' || regces.nctrxl);

            -- AVT 25/04/2005 Miramos si el contrato informado es un XL de protección (menos si es un siniestro)
            IF NVL(regces.nctrxl, 0) = 0 THEN
               v_protegit_xl := 0;
            ELSIF regces.cgenera <> 02 THEN
               v_protegit_xl := 1;
            END IF;

----------------------------------------------------------------------------------------------
            IF perror = 0 THEN
               WHILE w_volta < 2 LOOP
                  v_traza := 57;

                  IF w_volta = 0 THEN
                     w_icestot := (w_icestot * regces.plocal) / 100;
                     w_ipritarreatot := (w_ipritarreatot * regces.plocal) / 100;
                     w_idtoseltotot := (w_idtoseltot * regces.plocal) / 100;
                     w_icaptot := (w_icaptot * regces.plocal) / 100;
                     w_iextreatot := (w_iextreatot * regces.plocal) / 100;
                     w_ctramo := 1;
                     w_porce := 100;
                     w_scontra := regces.nsegcon;
                     w_nversio := regces.nsegver;
                  ELSE
------------------------------------------------------------
-- AVT 20/04/2005 ------------------------------------------
------------------------------------------------------------
                 --  DBMS_OUTPUT.put_line ('v_protegit_xl : ' || v_protegit_xl);
                     IF v_protegit_xl = 1 THEN
                        -- AVt Nom?s preparat per un sol tram de XL ....
                        w_porce := 100;
                        w_traxl := 6;
                        v_pxl := regces.ptasaxl;
                        w_ctrxl := regces.nctrxl;
                        w_verxl := regces.nverxl;
                        --  DBMS_OUTPUT.put_line ('w_icestot 1:' || w_icestot);
                        w_icestot := (w_icestot * v_pxl) / 100;
                        w_ipritarreatot := (w_ipritarreatot * v_pxl) / 100;
                        w_idtoseltotot := (w_idtoseltot * v_pxl) / 100;
                        w_icaptot := (w_icaptot * v_pxl) / 100;
                        w_iextreatot := (w_iextreatot * v_pxl) / 100;

                        --  DBMS_OUTPUT.put_line ('w_icestot 2:' || w_icestot);
                        --  DBMS_OUTPUT.put_line ('>>>>>>>>>>>>>>>> DINS xl');

                        -- aquí podríamos hacer el insert en las tablas para el tramo de XL ... 
                        -- y con lo que sobra que haga el procedimiento normal ...
                        FOR regcia IN cur_cuadroces(w_ctrxl, w_verxl, w_traxl, w_sfacult) LOOP
                          --if regces.sseguro=10521 then

                               -- END IF;
                           --DBMS_OUTPUT.put_line
                             --         (   '------------------------------- CIA:'
                               --        || regcia.ccompani
                                 --     );
                           ---------
                           --DBMS_OUTPUT.put_line (   'regcia.ccomrea : '
                             --                    || regcia.ccomrea
                               --                 );
                           v_traza := 58;

                           IF regcia.icomfij IS NOT NULL THEN
                              w_icomisi := regcia.icomfij;
                           ELSIF regcia.ccomrea IS NOT NULL THEN
                              w_ccomrea := regcia.ccomrea;

                              FOR curcomis IN cur_comisrea(w_ccomrea, w_fefecto, w_fvencim) LOOP
                                 IF perror = 0 THEN
                                    perror := f_buscomgarant(curcomis.scomrea, w_sseguro,
                                                             w_cgarant, w_fefecto, w_pcomias);

                                    IF perror <> 0 THEN
                                       psql := SQLERRM;
                                       pscesrea := regces.scesrea;
                                    END IF;
                                 END IF;
                              END LOOP;
                           -- 21398 AVT 23/02/2012 s'afegeix el c?lcul de la comissi? per % fix (PCOMISI)
                           ELSIF regcia.pcomisi IS NOT NULL THEN
                              w_pcomias := regcia.pcomisi;
                           END IF;

                           IF NVL(w_pcomias, 0) <> 0 THEN
                              w_icomisi := (((w_icestot * w_pcesion) / 100) * w_pcomias) / 100;
                           END IF;

                           v_traza := 59;

                           -- END IF; 21398 AVT 23/02/2012


                           IF perror = 0 THEN
                              ---------
                              BEGIN
                                 --DBMS_OUTPUT.put_line
                                   --             ('INSERTAMOS EN REASEGUROAUX XL');
                                 w_pcesion := regcia.pcesion;
                                 w_icesion := w_icestot * w_pcesion / 100;
                                 w_icapces := (w_icaptot * w_pcesion) / 100;
                                 --AGG 02/07/2014 Se añade la extra prima
                                 w_iextrea := (w_iextreatot * w_pcesion) / 100;

                                 --CONFCC-5 Inicio
                                 --
                                 p_calcula_retencion(w_cempres,
                                                     regces.sseguro,
                                                     regces.cgenera,
                                                     regcia.ccompani,
                                                     regces.fefecto,
                                                     w_icesion,
                                                     v_iretenido,
                                                     perror);
                                 --
                                 --CONFCC-5 Fin

                                 INSERT INTO reaseguroaux
                                             (codtipo, cempres, sproces, scesrea,
                                              fefecto, fvencim, sseguro,
                                              nriesgo, cgarant, nmovimi,
                                              cgenera, nsinies, sidepag, scontra, nversio,
                                              ctramo, pporcen, sfacult,
                                              icesiot, icapcet,
                                              fcierre,
                                              ccompani, pcesion, pcomisi,
                                              icesion,
                                              icapces,
                                              icomisi, fcalcul,
                                              cramo, cmodali, ctipseg, ccolect,
                                              cactivi, cagente, cagrpro, npoliza,
                                              ncertif, idtosel, ipritarrea,
                                              psobreprima, nrecibo,
                                              idtoseltot, ipritarreatot,
                                                                        -- BUG 11051 - 16/09/2009 - FAL - Informar camps de comptabilitat a partir de cesionesrea
                                                                        nreemb,
                                              nfact, nlinea, sreaemi,   -- 14833 AVT 18-06-2010
                                              -- FI Bug 11051 - 16/09/2009 - FAL
                                              icomext,   --AGG 08/05/2014 Se a`ade la comisi?n de la extra prima
                                                      iextrea,   --AGG 02/07/2014 Se a`ade la extra prima
                                                      iretencionf) --CONFCC-5
                                      VALUES (1, pcempres, pproces, regces.scesrea,
                                              regces.fefecto, regces.fvencim, regces.sseguro,
                                              regces.nriesgo, regces.cgarant, regces.nmovimi,
                                              regces.cgenera, NULL, NULL, w_ctrxl, w_verxl,
                                              w_traxl, w_porce, regces.sfacult,
                                              regces.icesion, regces.icapces,
                                              LAST_DAY(TO_DATE('01/' || pmes || '/' || pany,
                                                               'dd/mm/yyyy')),
                                              regcia.ccompani, w_pcesion, w_pcomias,
                                              f_round(w_icesion, v_cmonpol),
                                              f_round(w_icapces, v_cmonpol),
                                              f_round(w_icomisi, v_cmonpol), f_sysdate,   -- BUG 0038439 - FAL - 19/11/2015 - round a moneda producto
                                              w_cramo, w_cmodali, w_ctipseg, w_ccolect,
                                              w_cactivi, w_cagente, w_cagrpro, w_npoliza,
                                              w_ncertif, w_idtosel, w_ipritarrea,
                                              regces.psobreprima, regces.nrecibo,
                                              w_idtoseltot, w_ipritarreatot,
                                                                            -- BUG 11051 - 16/09/2009 - FAL - Informar camps de comptabilitat a partir de cesionesrea
                                                                            regces.nreemb,
                                              regces.nfact, regces.nlinea,
                                                                          -- FI Bug 11051 - 16/09/2009 - FAL
                                                                          regces.sreaemi,
                                              -- 14833 AVT 18-06-2010
                                              regces.icomext,   --AGG 08/05/2014 Se a`ade la comisi?n de la extra prima
                                                             w_iextrea,   --AGG 02/07/2014 Se a`ade la extra prima
                                                             v_iretenido); --CONFCC-5
                              EXCEPTION
                                 WHEN DUP_VAL_ON_INDEX THEN
                                    p_tab_error(f_sysdate, f_user,
                                                'pac_reaseguro_rec.llenar_bordero_aux',
                                                v_traza,
                                                'Err INSERT REASEGUROAUX:' || regces.scesrea,
                                                ' SQLERRM = ' || SQLERRM);
                                    perror := 105805;
                                    psql := SQLERRM;
                                    pscesrea := regces.scesrea;
                                 WHEN OTHERS THEN
                                    --                                 DBMS_OUTPUT.put_line('error:' || SQLERRM);
                                    p_tab_error(f_sysdate, f_user,
                                                'pac_reaseguro_rec.llenar_bordero_aux',
                                                v_traza,
                                                'Err INSERT REASEGUROAUX:' || regces.scesrea,
                                                ' SQLERRM = ' || SQLERRM);
                                    perror := 105804;
                                    psql := SQLERRM;
                                    pscesrea := regces.scesrea;
                              END;
                           END IF;   -- avt provis

                           v_traza := 60;

                        -----------------
                  -- AQU? ES CREA EL COMPTE T?CNIC... ?????????????????????????????
-- Aqu? busquem el ?ltim NNUMLIN...
                       --  DBMS_OUTPUT.put_line ('CUENTA TECNICAS');
                           IF perror = 0 THEN
                              BEGIN
                                 SELECT NVL(MAX(nnumlin), 0)
                                   INTO w_nnumlin
                                   FROM movctaaux
                                  WHERE scontra = w_scontra
                                    AND nversio = w_nversio
                                    AND ctramo = w_ctramo
                                    AND ccompani = regcia.ccompani;

                                 w_nnumlin := w_nnumlin + 1;
                              EXCEPTION
                                 WHEN NO_DATA_FOUND THEN
                                    w_nnumlin := 1;
                                 WHEN OTHERS THEN
                                    p_tab_error(f_sysdate, f_user,
                                                'pac_reaseguro_rec.llenar_bordero_aux',
                                                v_traza,
                                                'Err SELECT MOVCTAAUX:' || regcia.ccompani
                                                || ', ' || w_nversio || ', ' || w_scontra
                                                || ', ' || w_ctramo,
                                                ' SQLERRM = ' || SQLERRM);
                                    perror := 104863;
                                    psql := SQLERRM;
                                    pscesrea := regces.scesrea;
                              END;
                           END IF;

                           v_traza := 61;

                           -- Aqu? busquen l'estat del compte a CTATECNICA...
                                                  --  DBMS_OUTPUT.put_line
                                                               --       ('buscamos el estado en ctatecnica');
                           IF perror = 0 THEN
                              BEGIN
                                 SELECT cestado
                                   INTO w_cestado
                                   FROM ctatecnica
                                  WHERE scontra = w_scontra
                                    AND nversio = w_nversio
                                    AND ctramo = w_ctramo
                                    AND ccompani = regcia.ccompani
                                    AND sproduc = w_sproduc;
                              --OR NVL(sproduc, 0) = 0); 23830 AVT 17/12/2012
                              EXCEPTION
                                 WHEN NO_DATA_FOUND THEN
                                    w_cestado := 1;

                                    --                                 DBMS_OUTPUT.put_line('es nuevo, insertamos en ctatecnica');
                                    BEGIN
                                       INSERT INTO ctatecnica
                                                   (ccompani, nversio, scontra,
                                                    ctramo, nctatec, cfrecul, cestado,
                                                    festado, fcierre, cempres, sproduc,
                                                    ccorred)
                                            -- 22076 AVT 25/05/2012 nous camps
                                       VALUES      (regcia.ccompani, w_nversio, w_scontra,
                                                    w_ctramo, 1, 3, w_cestado,
                                                    NULL, NULL, pcempres, w_sproduc,
                                                    regcia.ccorred);
                                    EXCEPTION
                                       WHEN OTHERS THEN
                                          p_tab_error(f_sysdate, f_user,
                                                      'pac_reaseguro_rec.llenar_bordero_aux',
                                                      v_traza,
                                                      'Err INSERT ctatecnica:'
                                                      || regcia.ccompani || ', ' || w_nversio
                                                      || ', ' || w_scontra || ', ' || w_ctramo,
                                                      ' SQLERRM = ' || SQLERRM);
                                          perror := 1;
                                    END;
                                 WHEN OTHERS THEN
                                    p_tab_error(f_sysdate, f_user,
                                                'pac_reaseguro_rec.llenar_bordero_aux',
                                                v_traza,
                                                'Err SELECT ctatecnica:' || regcia.ccompani
                                                || ', ' || w_nversio || ', ' || w_scontra
                                                || ', ' || w_ctramo,
                                                ' SQLERRM = ' || SQLERRM);
                                    perror := 104866;
                                    psql := SQLERRM;
                                    pscesrea := regces.scesrea;
                              END;
                           END IF;

                           v_traza := 62;

-----------------
                           IF perror = 0 THEN
                              IF regces.cgenera <> 02 THEN
                                 w_cdebhab := 2;
                                 w_cconcep := 01;   -- Primas
                              END IF;

                              -- Aquí hacermos realmente el INSERT o el UPDATE
                              IF regces.cgenera <> 2
                                 AND regces.cmotces IN(1, 3) THEN
                                 BEGIN
                                    UPDATE movctaaux
                                       SET iimport = iimport + w_icesion
                                     WHERE scontra = w_ctrxl
                                       AND nversio = w_verxl
                                       AND ctramo = w_traxl
                                       AND ccompani = regcia.ccompani
                                       AND cconcep = w_cconcep;

                                    IF SQL%ROWCOUNT = 0 THEN   -- No ha actualitzat, insertem
                                       --                                    DBMS_OUTPUT.put_line
                                       --                                              ('no ha actualitzat INSERT !!!');
                                       BEGIN
                                          INSERT INTO movctaaux
                                                      (ccompani, nversio, scontra,
                                                       ctramo, nnumlin,
                                                       fmovimi,
                                                       fefecto, cconcep, cdebhab,
                                                       iimport, cestado, sproces,
                                                       scesrea, cempres, fcierre)
                                               VALUES (regcia.ccompani, w_verxl, w_ctrxl,
                                                       w_traxl, w_nnumlin,
                                                       LAST_DAY(TO_DATE('01/' || pmes || '/'
                                                                        || pany,
                                                                        'dd/mm/yyyy')),
                                                       regces.fefecto, w_cconcep, w_cdebhab,
                                                       w_icesion, w_cestado, pproces,
                                                       regces.scesrea, pcempres, LAST_DAY(TO_DATE('01/' || pmes || '/'
                                                                        || pany,
                                                                        'dd/mm/yyyy')));
                                       EXCEPTION
                                          WHEN DUP_VAL_ON_INDEX THEN
                                             p_tab_error
                                                      (f_sysdate, f_user,
                                                       'pac_reaseguro_rec.llenar_bordero_aux',
                                                       v_traza,
                                                       'Err INSERT movctaaux:'
                                                       || regcia.ccompani || ', ' || w_verxl
                                                       || ', ' || w_ctrxl || ', ' || w_traxl,
                                                       ' SQLERRM = ' || SQLERRM);
                                             perror := 105800;
                                             psql := SQLERRM;
                                             pscesrea := regces.scesrea;
                                          WHEN OTHERS THEN
                                             p_tab_error
                                                      (f_sysdate, f_user,
                                                       'pac_reaseguro_rec.llenar_bordero_aux',
                                                       v_traza,
                                                       'Err INSERT movctaaux:'
                                                       || regcia.ccompani || ', ' || w_verxl
                                                       || ', ' || w_ctrxl || ', ' || w_traxl,
                                                       ' SQLERRM = ' || SQLERRM);
                                             perror := 105802;
                                             psql := SQLERRM;
                                             pscesrea := regces.scesrea;
                                       END;
                                    END IF;
                                 EXCEPTION
                                    WHEN OTHERS THEN
                                       p_tab_error(f_sysdate, f_user,
                                                   'pac_reaseguro_rec.llenar_bordero_aux',
                                                   v_traza,
                                                   'Err UPDATE movctaaux:' || regcia.ccompani
                                                   || ', ' || w_verxl || ', ' || w_ctrxl
                                                   || ', ' || w_traxl,
                                                   ' SQLERRM = ' || SQLERRM);
                                       perror := 105801;
                                       psql := SQLERRM;
                                       pscesrea := regces.scesrea;
                                 END;
                              END IF;
                           END IF;

                           v_traza := 63;

-----------------
                        --Aquï se hace el INSERT de las reservas, si existen, un 
                        --efectivo y un deposito
                           IF regces.cgenera <> 2
                              AND regcia.preserv IS NOT NULL THEN
                              IF perror = 0 THEN
                                 w_reserva := (w_icesion * regcia.preserv) / 100;
                                 w_nnumlin := w_nnumlin + 1;

                                 BEGIN
                                    UPDATE movctaaux
                                       SET iimport = iimport + w_reserva
                                     WHERE scontra = w_ctrxl
                                       AND nversio = w_verxl
                                       AND ctramo = w_traxl
                                       AND ccompani = regcia.ccompani
                                       AND cconcep = 03;

                                    IF SQL%ROWCOUNT = 0 THEN
                                       BEGIN
                                          INSERT INTO movctaaux
                                                      (ccompani, nversio, scontra,
                                                       ctramo, nnumlin,
                                                       fmovimi,
                                                       fefecto, cconcep, cdebhab, iimport,
                                                       cestado, sproces, scesrea,
                                                       cempres, fcierre)
                                               VALUES (regcia.ccompani, w_verxl, w_ctrxl,
                                                       w_traxl, w_nnumlin,
                                                       LAST_DAY(TO_DATE('01/' || pmes || '/'
                                                                        || pany,
                                                                        'dd/mm/yyyy')),
                                                       regces.fefecto, 03, 1, w_reserva,   --> cdebhab de TIPOCTAREA
                                                       w_cestado, pproces, regces.scesrea,
                                                       pcempres, LAST_DAY(TO_DATE('01/' || pmes || '/'
                                                                        || pany,
                                                                        'dd/mm/yyyy')));
                                       -- canvi pfcierre -> pfperfin
                                       EXCEPTION
                                          WHEN DUP_VAL_ON_INDEX THEN
                                             p_tab_error
                                                      (f_sysdate, f_user,
                                                       'pac_reaseguro_rec.llenar_bordero_aux',
                                                       v_traza,
                                                       'Err INSERT movctaaux:'
                                                       || regcia.ccompani || ', ' || w_verxl
                                                       || ', ' || w_ctrxl || ', ' || w_traxl,
                                                       ' SQLERRM = ' || SQLERRM);
                                             perror := 105800;
                                             psql := SQLERRM;
                                             pscesrea := regces.scesrea;
                                          WHEN OTHERS THEN
                                             p_tab_error
                                                      (f_sysdate, f_user,
                                                       'pac_reaseguro_rec.llenar_bordero_aux',
                                                       v_traza,
                                                       'Err INSERT movctaaux:'
                                                       || regcia.ccompani || ', ' || w_verxl
                                                       || ', ' || w_ctrxl || ', ' || w_traxl,
                                                       ' SQLERRM = ' || SQLERRM);
                                             perror := 105802;
                                             psql := SQLERRM;
                                             pscesrea := regces.scesrea;
                                       END;
                                    END IF;
                                 EXCEPTION
                                    WHEN OTHERS THEN
                                       p_tab_error(f_sysdate, f_user,
                                                   'pac_reaseguro_rec.llenar_bordero_aux',
                                                   v_traza,
                                                   'Err UPDATE movctaaux:' || regcia.ccompani
                                                   || ', ' || w_verxl || ', ' || w_ctrxl
                                                   || ', ' || w_traxl,
                                                   ' SQLERRM = ' || SQLERRM);
                                       perror := 105801;
                                       psql := SQLERRM;
                                       pscesrea := regces.scesrea;
                                 END;
                              END IF;

                              v_traza := 64;

                              IF perror = 0 THEN
                                 w_nnumlin := w_nnumlin + 1;

                                 BEGIN
                                    UPDATE movctaaux
                                       SET iimport = iimport + w_reserva
                                     WHERE scontra = w_ctrxl
                                       AND nversio = w_verxl
                                       AND ctramo = w_traxl
                                       AND ccompani = regcia.ccompani
                                       AND cconcep = 52;

                                    IF SQL%ROWCOUNT = 0 THEN
                                       BEGIN
                                          INSERT INTO movctaaux
                                                      (ccompani, nversio, scontra,
                                                       ctramo, nnumlin,
                                                       fmovimi,
                                                       fefecto, cconcep, cdebhab, iimport,
                                                       cestado, sproces, scesrea,
                                                       cempres, fcierre)
                                               VALUES (regcia.ccompani, w_verxl, w_ctrxl,
                                                       w_traxl, w_nnumlin,
                                                       LAST_DAY(TO_DATE('01/' || pmes || '/'
                                                                        || pany,
                                                                        'dd/mm/yyyy')),
                                                       regces.fefecto, 52, 2, w_reserva,   --> cdebhab de TIPOCTAREA
                                                       w_cestado, pproces, regces.scesrea,
                                                       pcempres, LAST_DAY(TO_DATE('01/' || pmes || '/'
                                                                        || pany,
                                                                        'dd/mm/yyyy')));
                                       -- canvi pfcierre -> pfperfin
                                       EXCEPTION
                                          WHEN DUP_VAL_ON_INDEX THEN
                                             p_tab_error
                                                      (f_sysdate, f_user,
                                                       'pac_reaseguro_rec.llenar_bordero_aux',
                                                       v_traza,
                                                       'Err INSERT movctaaux:'
                                                       || regcia.ccompani || ', ' || w_verxl
                                                       || ', ' || w_ctrxl || ', ' || w_traxl,
                                                       ' SQLERRM = ' || SQLERRM);
                                             perror := 105800;
                                             psql := SQLERRM;
                                             pscesrea := regces.scesrea;
                                          WHEN OTHERS THEN
                                             p_tab_error
                                                      (f_sysdate, f_user,
                                                       'pac_reaseguro_rec.llenar_bordero_aux',
                                                       v_traza,
                                                       'Err INSERT movctaaux:'
                                                       || regcia.ccompani || ', ' || w_verxl
                                                       || ', ' || w_ctrxl || ', ' || w_traxl,
                                                       ' SQLERRM = ' || SQLERRM);
                                             perror := 105802;
                                             psql := SQLERRM;
                                             pscesrea := regces.scesrea;
                                       END;
                                    END IF;
                                 EXCEPTION
                                    WHEN OTHERS THEN
                                       p_tab_error(f_sysdate, f_user,
                                                   'pac_reaseguro_rec.llenar_bordero_aux',
                                                   v_traza,
                                                   'Err UPDATE movctaaux:' || regcia.ccompani
                                                   || ', ' || w_verxl || ', ' || w_ctrxl
                                                   || ', ' || w_traxl,
                                                   ' SQLERRM = ' || SQLERRM);
                                       perror := 105801;
                                       psql := SQLERRM;
                                       pscesrea := regces.scesrea;
                                 END;
                              END IF;
                           END IF;

                           v_traza := 65;

                           --Aqu? es fa el insert de les comissions, si existeixen...
                           IF perror = 0 THEN
                              IF w_icomisi <> 0 THEN
                                 w_nnumlin := w_nnumlin + 1;

                                 BEGIN
                                    UPDATE movctaaux
                                       SET iimport = iimport + w_icomisi
                                     WHERE scontra = w_ctrxl
                                       AND nversio = w_verxl
                                       AND ctramo = w_traxl
                                       AND ccompani = regcia.ccompani
                                       AND cconcep = 02;

                                    IF SQL%ROWCOUNT = 0 THEN
                                       BEGIN
                                          INSERT INTO movctaaux
                                                      (ccompani, nversio, scontra,
                                                       ctramo, nnumlin,
                                                       fmovimi,
                                                       fefecto, cconcep, cdebhab, iimport,
                                                       cestado, sproces, scesrea,
                                                       cempres, fcierre)
                                               VALUES (regcia.ccompani, w_verxl, w_ctrxl,
                                                       w_traxl, w_nnumlin,
                                                       LAST_DAY(TO_DATE('01/' || pmes || '/'
                                                                        || pany,
                                                                        'dd/mm/yyyy')),
                                                       regces.fefecto, 02, 1, w_icomisi,   --> cdebhab de TIPOCTAREA
                                                       w_cestado, pproces, regces.scesrea,
                                                       pcempres, LAST_DAY(TO_DATE('01/' || pmes || '/'
                                                                        || pany,
                                                                        'dd/mm/yyyy')));
                                       -- canvi pfcierre -> pfperfin
                                       EXCEPTION
                                          WHEN DUP_VAL_ON_INDEX THEN
                                             p_tab_error
                                                      (f_sysdate, f_user,
                                                       'pac_reaseguro_rec.llenar_bordero_aux',
                                                       v_traza,
                                                       'Err INSERT movctaaux:'
                                                       || regcia.ccompani || ', ' || w_verxl
                                                       || ', ' || w_ctrxl || ', ' || w_traxl,
                                                       ' SQLERRM = ' || SQLERRM);
                                             perror := 105800;
                                             psql := SQLERRM;
                                             pscesrea := regces.scesrea;
                                          WHEN OTHERS THEN
                                             p_tab_error
                                                      (f_sysdate, f_user,
                                                       'pac_reaseguro_rec.llenar_bordero_aux',
                                                       v_traza,
                                                       'Err INSERT movctaaux:'
                                                       || regcia.ccompani || ', ' || w_verxl
                                                       || ', ' || w_ctrxl || ', ' || w_traxl,
                                                       ' SQLERRM = ' || SQLERRM);
                                             perror := 105802;
                                             psql := SQLERRM;
                                             pscesrea := regces.scesrea;
                                       END;
                                    END IF;
                                 EXCEPTION
                                    WHEN OTHERS THEN
                                       p_tab_error(f_sysdate, f_user,
                                                   'pac_reaseguro_rec.llenar_bordero_aux',
                                                   v_traza,
                                                   'Err UPDATE movctaaux:' || regcia.ccompani
                                                   || ', ' || w_verxl || ', ' || w_ctrxl
                                                   || ', ' || w_traxl,
                                                   ' SQLERRM = ' || SQLERRM);
                                       perror := 105801;
                                       psql := SQLERRM;
                                       pscesrea := regces.scesrea;
                                 END;
                              END IF;
                           END IF;
-----------------
                     --
                        END LOOP;

                        v_traza := 66;
                        -- AQU? CONTINUA AMB EL CONTRACTE QUE PROTEGIA.........
                        w_scontra := regces.scontra;
                        w_nversio := regces.nversio;
                        w_ctramo := regces.ctramo;
                        -- avt 21/04/2005
                        w_icestot := regces.icesion - w_icestot;
                        --  DBMS_OUTPUT.put_line ('** w_icestot : ' || w_icestot);
                        w_idtoseltot := regces.idtosel;
                        w_ipritarreatot := regces.ipritarrea;
                        w_icaptot := regces.icapces;
                        w_porce := regces.pcesion;
                        w_iextreatot := regces.iextrea;


-------------------- AVT FI.................. xl     ---------------------------------
                     ELSE
                        w_scontra := regces.scontra;
                        w_nversio := regces.nversio;
                        w_ctramo := regces.ctramo;
                        w_icestot := regces.icesion;
                        w_idtoseltot := regces.idtosel;
                        w_ipritarreatot := regces.ipritarrea;
                        w_icaptot := regces.icapces;
                        w_porce := regces.pcesion;
                        w_iextreatot := regces.iextrea;
						--CONF-910 Inicio
                        w_icestot := f_total_concutoff(w_scontra,
                                                       w_nversio,
                                                       w_ctramo,
                                                       TRUNC(SYSDATE),
                                                       w_icestot,
                                                       perror);
                        w_icaptot := f_total_concutoff(w_scontra,
                                                       w_nversio,
                                                       w_ctramo,
                                                       TRUNC(SYSDATE),
                                                       w_icaptot,
                                                       perror);


                        --CONF-910 Fin
                     END IF;
                  END IF;

                  v_traza := 67;
                  w_volta := w_volta + 1;

                    IF perror = 0 THEN
                     -- AVT 05/07/2005 C?lcul de la Prima-Bonus --------

                     FOR regcia IN cur_cuadroces(w_scontra, w_nversio, w_ctramo, w_sfacult) LOOP
                        v_traza := 68;
                        --  DBMS_OUTPUT.put_line
                            --           (   '------------------------------- CIA:'
                              --          || regcia.ccompani
                                --       );
                        --  DBMS_OUTPUT.put_line
                            --('DENTRO DEL CURSOR DE LLENADO DE BORDERO. CESIONES A COMPA?IAS'
                            --);
                        IF perror = 0 THEN
                           w_pcesion := NVL(regcia.pcesion, 0);

                           --> 22. JGR 0021342: LCOL_A002-Error cierre previo - a?adir NVL()
                           IF NVL(regces.imaxplo, 0) <> 0 THEN
                              IF regces.cgenera <> 2 THEN
                                 -- Si hi ha m?xim import local, es mira si aplicant el percentatge
                                 -- excedim aquest m?xim. Si s'excedeix, es calcula a l'inversa, ?s
                                 -- a dir, busquem quin percentatge s'ha d'aplicar per tal de que
                                 -- doni el m?xim, i aix? continuar treballant amb percentatges.
                                 w_aux := (regces.icapces * regces.plocal) / 100;

                                 IF w_aux > regces.imaxplo THEN
                                    BEGIN
                                       --> 22. JGR 0021342: LCOL_A002-Error cierre previo - a?adir NVL()
                                       w_pnostre :=
                                               NVL((regces.plocal * regces.imaxplo) / w_aux,
                                                   0);
                                       w_pcesion :=
                                          NVL((regcia.pcesion *(100 - w_pnostre))
                                              /(100 - regces.plocal),
                                              0);
                                    --> 22. JGR 0021342: LCOL_A002-Error cierre previo - a?adir NVL()
                                    EXCEPTION
                                       WHEN OTHERS THEN
                                          p_tab_error(f_sysdate, f_user,
                                                      'pac_reaseguro_rec.llenar_bordero_aux',
                                                      v_traza,
                                                      'Err calculo:' || regces.plocal || ' ,'
                                                      || regces.imaxplo || ' ,' || w_aux,
                                                      ' SQLERRM = ' || SQLERRM);
                                          perror := 104704;
                                          psql := SQLERRM;
                                          pscesrea := regces.scesrea;
                                    END;
                                 END IF;
                              ELSE
                                 BEGIN
                                    SELECT pcesion
                                      INTO w_pcesion
                                      FROM reaseguro
                                     WHERE scesrea = regces.sproces
                                       AND ccompani = regcia.ccompani
                                       AND sproces IN(
                                             SELECT MAX(sproces)
                                               FROM reaseguroaux
                                              WHERE scesrea = regces.sproces
                                                AND ccompani = regcia.ccompani);
                                 EXCEPTION
                                    WHEN NO_DATA_FOUND THEN
                                       NULL;
                                    WHEN OTHERS THEN
                                       p_tab_error(f_sysdate, f_user,
                                                   'pac_reaseguro_rec.llenar_bordero_aux',
                                                   v_traza,
                                                   'Err SELECT REASEGURO:' || regces.sproces
                                                   || ', ' || regcia.ccompani,
                                                   ' SQLERRM = ' || SQLERRM);
                                       perror := 105769;
                                       psql := SQLERRM;
                                       pscesrea := regces.scesrea;
                                 END;
                              END IF;
                           END IF;

                           v_traza := 69;

                           IF perror = 0 THEN
                              w_icomisi := 0;
                              w_pcomias := 0;

--BUG 0026444 - 27/07/2013 - JRH - Calculo cesión de prima
                              IF w_ctramo = 5
                                 AND NVL(regces.ctipfac, 0) = 1 THEN   --JRH Tasa de Facultativo XL. Dejo aqui la select para que se vea bien lo que se está haciendo.
                                 SELECT NVL(SUM(icesion), 0)
                                   INTO vprimatotces
                                   FROM cesionesrea
                                  WHERE sseguro = regces.sseguro
                                    AND nversio = regces.nversio   --JRH IMP?
                                    AND scontra = regces.scontra
                                    AND nriesgo = regces.nriesgo
                                    AND cgarant = regces.cgarant
                                    AND sproces = regces.sproces;

                                 --JRH IMP Alicia el nmovimegn iria bien no? Los cumulos? AND nmovigen = regces.nmovigen;
                                 w_icesion := vprimatotces * NVL(regces.ptasaxl, 0) / 100;   -- No hago nada mas sólo esta prima
                              ELSE
                                 w_icesion := (w_icestot * w_pcesion) / 100;   --Ojo esto es lo de antes, para el resto de contratos
                              END IF;

--Fi BUG 0026444 - 27/07/2013 - JRH
                              w_idtosel := (w_idtoseltot * w_pcesion) / 100;
                              w_ipritarrea := (w_ipritarreatot * w_pcesion) / 100;
                              w_icapces := (w_icaptot * w_pcesion) / 100;
                              --AGG 02/07/2014 Se añade la extra prima
                              w_iextrea := (w_iextreatot * w_pcesion) / 100;

                              -- BUG 0038439 - FAL - 19/11/2015 - round a moneda producto
                              SELECT pac_monedas.f_moneda_producto(sproduc)
                                INTO v_cmonpol
                                FROM seguros
                               WHERE sseguro = regces.sseguro;

                              -- FI BUG 0038439
                              IF regces.cgenera <> 2 THEN

                                 -- els pagaments no tenen
                                                              --  DBMS_OUTPUT.put_line (   'regcia.ccomrea : '
                                                              --                       || regcia.ccomrea
                                                                --                    );             -- comiss...
                                                              --  DBMS_OUTPUT.put_line (   'regcia.icomfij: '
                                                              --                       || regcia.icomfij
                                                                --                    );             -- comiss...
                                 IF regcia.icomfij IS NOT NULL THEN
                                    w_icomisi := regcia.icomfij;
                                 ELSIF regcia.ccomrea IS NOT NULL THEN
                                    w_ccomrea := regcia.ccomrea;

                                    FOR curcomis IN cur_comisrea(w_ccomrea, w_fefecto,
                                                                 w_fvencim) LOOP
                                       --  DBMS_OUTPUT.put_line
                                       --                  (   'curcomis.scomrea: '
                                         --                 || curcomis.scomrea
                                            --              );
                                       --  DBMS_OUTPUT.put_line
                                       --                   (   'w_sseguro       : '
                                         --                  || w_sseguro
                                           --               );
                                       --  DBMS_OUTPUT.put_line
                                       --                   (   'w_cgarant       : '
                                         --                  || w_cgarant
                                           --               );
                                       --  DBMS_OUTPUT.put_line
                                       --                   (   'w_fefecto       : '
                                         --                  || w_fefecto
                                           --               );

                                       IF perror = 0 THEN
                                          perror :=
                                             f_buscomgarant(curcomis.scomrea, w_sseguro,
                                                            w_cgarant, w_fefecto, w_pcomias);

                                          --  DBMS_OUTPUT.put_line
                                          --                (   'w_pcomias       : '
                                            --               || w_pcomias
                                              --            );
                                          IF perror <> 0 THEN
                                             psql := SQLERRM;
                                             pscesrea := regces.scesrea;
                                          END IF;
                                       END IF;
                                    END LOOP;
                                 -- 21398 AVT 23/02/2012 s'afegeix el c?lcul de la comissi? per % fix (PCOMISI)
                                 ELSIF regcia.pcomisi IS NOT NULL THEN
                                    w_pcomias := regcia.pcomisi;
                                 END IF;

                                 v_traza := 70;

                                 IF NVL(w_pcomias, 0) <> 0 THEN
                                    --  DBMS_OUTPUT.put_line (   'w_icestot :'
                                    --                       || w_icestot
                                      --                    );
                                    --  DBMS_OUTPUT.put_line (   'w_pcesion :'
                                    --                       || w_pcesion
                                      --                    );
                                     -- AVT si ?s un XL protegit pot haver-hi definida una cia amb pcesion = 0
                                     -- per? amb comissi? (27/04/2005)
                                    perror := f_parproductos(w_sproduc, 'COMIS_REA',
                                                             v_nomes_comis);



                                    IF v_nomes_comis = 1
                                       AND w_pcesion = 0 THEN
                                       --  DBMS_OUTPUT.put_line
                                       --                (   'regces.scesrea : '
                                         --               || regces.scesrea
                                           --            );
                                       --  DBMS_OUTPUT.put_line
                                       --                 (   'regces.sSEGURO : '
                                         --                || regces.sseguro
                                           --             );
                                       BEGIN
                                          SELECT icesion, NVL(plocal, 0)
                                            --> 22. JGR 0021342: LCOL_A002-Error cierre previo - a?adir NVL()
                                          INTO   w_icesion, w_pcesion
                                            FROM cesionesrea c, tramos t
                                           WHERE scesrea = regces.scesrea
                                             AND c.scontra = t.scontra
                                             AND c.nversio = t.nversio
                                             AND c.ctramo = t.ctramo;
                                       EXCEPTION
                                          WHEN OTHERS THEN
                                             --  DBMS_OUTPUT.put_line('err: ' || SQLERRM);
                                             p_tab_error
                                                (f_sysdate, f_user,
                                                 'pac_reaseguro_rec.llenar_bordero_aux',
                                                 v_traza,
                                                 'Err SELECT FROM cesionesrea c, tramos t:'
                                                 || regces.scesrea,
                                                 ' SQLERRM = ' || SQLERRM);
                                       END;

                                       v_traza := 71;

                                       IF v_nomes_comis = 1 THEN
                                          --  DBMS_OUTPUT.put_line
                                          --             (   'XL 1 w_icestot : '
                                            --            || w_icestot
                                              --          || ' * '
                                                --        || w_pcesion
                                                  --     );
                                          w_icestot := w_icestot - w_icestot * w_pcesion / 100;
                                          --  DBMS_OUTPUT.put_line
                                          --              (   'XL 2 w_icestot : '
                                            --             || w_icestot
                                              --           || ' * '
                                                --         || w_pcomias
                                                  --      );
                                          w_icomisi := (w_icestot * w_pcomias) / 100;
                                       --  DBMS_OUTPUT.put_line
                                       --                   (   'w_icomisi 1:'
                                         --                  || w_icomisi
                                           --               );
                                       ELSE
                                          w_icomisi :=
                                              (((w_icestot * w_pcesion) / 100) * w_pcomias)
                                              / 100;
                                       END IF;

                                       --  DBMS_OUTPUT.put_line
                                       --                 (   'XL 3 w_icestot : '
                                         --                || w_icestot
                                           --             );
                                       --  DBMS_OUTPUT.put_line (   'w_icomisi 2:'
                                       --                       || w_icomisi
                                         --                    );
                                       w_icestot := 0;
                                       --tornem a inicialitzar la cessi?...
                                       w_pcesion := 0;
                                       w_icesion := 0;
                                       w_icapces := 0;
                                       w_iextrea := 0;
                                       w_ipritarreatot := 0;
                                       w_iextreatot := 0;
                                    ELSE
                                       w_icomisi :=
                                              (((w_icestot * w_pcesion) / 100) * w_pcomias)
                                              / 100;
                                    END IF;
                                 END IF;

                                 v_traza := 72;

                                 --CONFCC-5 Inicio
                                 --
                                 p_calcula_retencion(w_cempres,
                                                     regces.sseguro,
                                                     regces.cgenera,
                                                     regcia.ccompani,
                                                     regces.fefecto,
                                                     w_icesion,
                                                     v_iretenido,
                                                     perror);
                                 --
                                 --CONFCC-5 Fin

                                 -- END IF; 21398 AVT 23/02/2012 fi

                                 --                              DBMS_OUTPUT.put_line ('perror :' || perror);


                                 IF perror =0 THEN

                                    BEGIN
                                       --  DBMS_OUTPUT.put_line
                                       --             ('INSERTAMOS EN REASEGUROAUX');
                                       INSERT INTO reaseguroaux
                                                   (codtipo, cempres, sproces, scesrea,
                                                    fefecto, fvencim,
                                                    sseguro, nriesgo,
                                                    cgarant, nmovimi,
                                                    cgenera, nsinies, sidepag, scontra,
                                                    nversio, ctramo, pporcen,
                                                    sfacult, icesiot,
                                                    icapcet,
                                                    fcierre,
                                                    ccompani, pcesion, pcomisi,
                                                    icesion,
                                                    icapces,
                                                    icomisi, fcalcul,
                                                    cramo, cmodali, ctipseg, ccolect,
                                                    cactivi, cagente, cagrpro,
                                                    npoliza, ncertif, idtosel,
                                                    ipritarrea, psobreprima,
                                                    nrecibo, idtoseltot,
                                                    ipritarreatot,   --, ipribon
                                                                  -- BUG 11051 - 16/09/2009 - FAL - Informar camps de comptabilitat a partir de cesionesrea
                                                                  nreemb,
                                                    nfact, nlinea,
                                                    -- FI Bug 11051 - 16/09/2009 - FAL
                                                    sreaemi, icomext,   -- 14833 AVT 18-06-2010
                                                                     iextrea,   --AGG 02/07/2014 Se a`ade la extra prima
                                                                     iretencionf) --CONFCC-5
                                            VALUES (1, pcempres, pproces, regces.scesrea,
                                                    regces.fefecto, regces.fvencim,
                                                    regces.sseguro, regces.nriesgo,
                                                    regces.cgarant, regces.nmovimi,
                                                    regces.cgenera, NULL, NULL, w_scontra,
                                                    w_nversio, w_ctramo, w_porce,
                                                    regces.sfacult, regces.icesion,
                                                    regces.icapces,
                                                    LAST_DAY(TO_DATE('01/' || pmes || '/'
                                                                     || pany,
                                                                     'dd/mm/yyyy')),
                                                    regcia.ccompani, w_pcesion, w_pcomias,
                                                    f_round(w_icesion, v_cmonpol),
                                                    f_round(w_icapces, v_cmonpol),
                                                    f_round(w_icomisi, v_cmonpol),   -- BUG 0038439 - FAL - 19/11/2015 - round a moneda producto
                                                                                  f_sysdate,
                                                    w_cramo, w_cmodali, w_ctipseg, w_ccolect,
                                                    w_cactivi, w_cagente, w_cagrpro,
                                                    w_npoliza, w_ncertif, w_idtosel,
                                                    w_ipritarrea, regces.psobreprima,
                                                    regces.nrecibo, w_idtoseltot,
                                                    w_ipritarreatot, regces.nreemb,
                                                    regces.nfact, regces.nlinea,
                                                    regces.sreaemi,
                                                                   --AGG 08/05/2014 se añade comisión de la extra prima
                                                                   regces.icomext,
                                                                                  --AGG 02/07/2014 Se a`ade la extra prima
                                                                                  w_iextrea,
                                                                                  v_iretenido); --CONFCC-5
                                    EXCEPTION
                                       WHEN DUP_VAL_ON_INDEX THEN
                                          p_tab_error(f_sysdate, f_user,
                                                      'pac_reaseguro_rec.llenar_bordero_aux',
                                                      v_traza,
                                                      'Err INSERT REASEGURO:'
                                                      || regces.scesrea,
                                                      ' SQLERRM = ' || SQLERRM);
                                          perror := 105805;
                                          psql := SQLERRM;
                                          pscesrea := regces.scesrea;
                                       WHEN OTHERS THEN
                                          p_tab_error(f_sysdate, f_user,
                                                      'pac_reaseguro_rec.llenar_bordero_aux',
                                                      v_traza,
                                                      'Err INSERT REASEGURO:'
                                                      || regces.scesrea,
                                                      ' SQLERRM = ' || SQLERRM);
                                          perror := 105804;
                                          psql := SQLERRM;
                                          pscesrea := regces.scesrea;
                                    END;
                                 END IF;
                              ELSE   -- Pagament de sinistre
                                 v_traza := 73;


                                 BEGIN
                                    INSERT INTO reaseguroaux
                                                (codtipo, cempres, sproces, scesrea,
                                                 fefecto, fvencim, sseguro,
                                                 nriesgo, cgarant, nmovimi,
                                                 cgenera, nsinies,
                                                 sidepag, scontra, nversio,
                                                 ctramo, pporcen, sfacult,
                                                 icesiot, icapcet,
                                                 fcierre,
                                                 ccompani, pcesion, pcomisi,
                                                 icesion, icapces,
                                                 icomisi, fcalcul,
                                                 cramo, cmodali, ctipseg, ccolect,
                                                 cactivi, cagente, cagrpro, npoliza,
                                                 ncertif, nreemb, nfact,
                                                 nlinea, sreaemi,
                                                 icomext,
                                                 iextrea)
                                         VALUES (2, pcempres, pproces, regces.scesrea,
                                                 regces.fefecto, NULL, regces.sseguro,
                                                 regces.nriesgo, regces.cgarant, NULL,
                                                 regces.cgenera, regces.nsinies,
                                                 regces.sidepag, w_scontra, w_nversio,
                                                 w_ctramo, w_porce, regces.sfacult,
                                                 regces.icesion, NULL,
                                                 LAST_DAY(TO_DATE('01/' || pmes || '/' || pany,
                                                                  'dd/mm/yyyy')),
                                                 regcia.ccompani, w_pcesion, w_pcomias,
                                                 -- 21398 AVT 23/02/2012
                                                 f_round(w_icesion, v_cmonpol), NULL,
                                                 f_round(w_icomisi, v_cmonpol),   -- BUG 0038439 - FAL - 19/11/2015 - round a moneda producto
                                                                               -- 21398 AVT 23/02/2012
                                                                               f_sysdate,
                                                 w_cramo, w_cmodali, w_ctipseg, w_ccolect,
                                                 w_cactivi, w_cagente, w_cagrpro, w_npoliza,
                                                 w_ncertif,
                                                           -- ,  v_icesbonus   --  AVT 07/07/2005
                                                                 -- BUG 11051 - 16/09/2009 - FAL - Informar camps de comptabilitat a partir de cesionesrea
                                                           regces.nreemb, regces.nfact,
                                                 regces.nlinea
                                                              -- FI Bug 11051 - 16/09/2009 - FAL
                                    ,            regces.sreaemi,
                                                 regces.icomext,   --AGG 08/05/2014 se añade comisión de la extra prima
                                                 w_iextrea   --AGG 02/07/2014 Se añade la extra prima
                                                          -- 14833 AVT 18-06-2010
                                                );
                                 EXCEPTION
                                    WHEN DUP_VAL_ON_INDEX THEN
                                       p_tab_error(f_sysdate, f_user,
                                                   'pac_reaseguro_rec.llenar_bordero_aux',
                                                   v_traza,
                                                   'Err INSERT REASEGURO:' || regces.scesrea,
                                                   ' SQLERRM = ' || SQLERRM);
                                       perror := 105805;
                                       psql := SQLERRM;
                                       pscesrea := regces.scesrea;
                                    WHEN OTHERS THEN
                                       p_tab_error(f_sysdate, f_user,
                                                   'pac_reaseguro_rec.llenar_bordero_aux',
                                                   v_traza,
                                                   'Err INSERT REASEGURO:' || regces.scesrea,
                                                   ' SQLERRM = ' || SQLERRM);
                                       perror := 105804;
                                       psql := SQLERRM;
                                       pscesrea := regces.scesrea;
                                 END;
                              END IF;
                           END IF;

                           v_traza := 74;
                        END IF;
                     END LOOP;
                  END IF;
               END LOOP;

               IF pdefi = 2 THEN
                  v_traza := 75;
                --FEPP
                  BEGIN
                     UPDATE cesionesrea
                        SET fcontab = LAST_DAY(TO_DATE('01/' || pmes || '/' || pany,
                                                       'dd/mm/yyyy'))
                      WHERE scesrea = regces.scesrea
                        AND fcontab IS NULL;
                  EXCEPTION
                     WHEN OTHERS THEN
                        p_tab_error(f_sysdate, f_user, 'pac_reaseguro_rec.llenar_bordero_aux',
                                    v_traza,
                                    'Err UPDATE cesionesrea:'
                                    || LAST_DAY(TO_DATE('01/' || pmes || '/' || pany,
                                                        'dd/mm/yyyy'))
                                    || ', ' || regces.scesrea,
                                    ' SQLERRM = ' || SQLERRM);
                        perror := 104859;
                        psql := SQLERRM;
                        pscesrea := regces.scesrea;
                  END;

                  v_traza := 76;
                --FEPP
                 BEGIN
                     UPDATE reasegemi
                        SET fcierre = LAST_DAY(TO_DATE('01/' || pmes || '/' || pany,
                                                       'dd/mm/yyyy'))
                      WHERE sreaemi = regces.sreaemi
                        AND fcierre IS NULL;
                  EXCEPTION
                     WHEN OTHERS THEN
                        p_tab_error(f_sysdate, f_user, 'pac_reaseguro_rec.llenar_bordero_aux',
                                    v_traza,
                                    'Err UPDATE reasegemi:'
                                    || LAST_DAY(TO_DATE('01/' || pmes || '/' || pany,
                                                        'dd/mm/yyyy'))
                                    || ', ' || regces.sreaemi,
                                    ' SQLERRM = ' || SQLERRM);
                        perror := 104859;
                        psql := SQLERRM;
                        pscesrea := regces.scesrea;
                  END;
               END IF;
            END IF;

            v_traza := 77;

            IF perror = 0 THEN
               IF contador >= 5 THEN
                  contador := 0;
                  --COMMIT;
               --SET TRANSACTION USE ROLLBACK SEGMENT rollbig;
               END IF;

               contador := contador + 1;
            ELSE
               EXIT;
            END IF;
         END IF;   -- 26252 KBR Recibos cobrados parcialmente 24042013
      END LOOP;

      v_traza := 78;

      UPDATE cesionesrea
         SET fcontab = LAST_DAY(TO_DATE('01' || '/' || pmes || '/' || pany, 'dd/mm/yyyy'))
       WHERE fgenera < pfcierre + 1
         AND pdefi = 2
         -- < 3 AVT 28-02-2005 nom?s ha d'actualitzar les cessions en cas de Tancament Definitiu.
         AND fcontab IS NULL
         AND fefecto <= LAST_DAY(TO_DATE('01' || '/' || pmes || '/' || pany, 'dd/mm/yyyy'));

      v_traza := 79;
      -- fi cursor
      --indexat ok
         --   COMMIT;
      RETURN(perror);
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_reaseguro_rec.llenar_bordero_aux', v_traza,
                     'Err Incontrolat', ' SQLERRM = ' || SQLERRM);
         perror := 108190;
         psql := SQLERRM;
         pscesrea := SQLCODE;
         RETURN(perror);
   END llenar_bordero_aux;

-- ********************************************************************
   FUNCTION llenar_tablas_defi(
      psql OUT VARCHAR2,
      pscesrea OUT NUMBER,
      pcempres IN NUMBER,
      pfperfin IN DATE)   -- canvi pfcierre -> pfperfin
     return number IS

      perror         NUMBER := 12;
      numlin         NUMBER := 0;
      w_nnumlin      movctatecnica.nnumlin%TYPE;   -- BUG 0025803  NUMBER(6);
      contador       NUMBER := 0;
      sprocess         NUMBER;
      countReas         NUMBER;
	  fecha_conversion DATE; --bug-12994

      CURSOR cur_movaux IS
         SELECT ROWID, m.*
           FROM movctaaux m
          WHERE m.cempres = pcempres
            AND m.fcierre = last_day(TO_dATE(pfperfin,'DD-MM-RRRR')) --last_day(pfperfin)
         AND NVL(m.iimport, 0) <> 0
           AND ctramo < 6;   --AGG 03/04/2014 El tramo debe ser proporcional

      --BUG 23830 - INICIO - DCT - 10/09/2013 - LCOL_A004 Ajustar el Manteniment dels comptes de Reassegurança
      -- canvi pfcierre -> pfperfin
      CURSOR cur_detces IS
         SELECT ROWID, r.*
           FROM reaseguroaux r
          WHERE r.cempres = pcempres
            AND r.fcierre = last_day(TO_dATE(pfperfin,'DD-MM-RRRR')) --last_day(pfperfin)
            AND ctramo < 6;   --AGG 03/04/2014 El tramo debe ser proporcional


         CURSOR cur_readepositoaux IS
         SELECT ROWID, r.*
           FROM readepositoaux r
          WHERE r.cempres = pcempres
            AND r.fcierre = pfperfin;


      -- canvi pfcierre -> pfperfin
      --BUG 23830 - FIN - DCT - 10/09/2013 - LCOL_A004 Ajustar el Manteniment dels comptes de Reassegurança
      v_cmultimon    parempresas.nvalpar%TYPE
                              := NVL(pac_parametros.f_parempresa_n(pcempres, 'MULTIMONEDA'), 0);
      v_cmoncontab   parempresas.nvalpar%TYPE
                                     := pac_parametros.f_parempresa_n(pcempres, 'MONEDACONTAB');
      v_itasa        eco_tipocambio.itasa%TYPE;
      v_fcambio      DATE;
      --KBR 17/02/2015 - Facultativos puros
      v_sseguro      seguros.sseguro%TYPE;
      v_scontra      contratos.scontra%TYPE;


   BEGIN
   v_traza := 80;
      COMMIT;

            --SET TRANSACTION USE ROLLBACK SEGMENT rollbig;
      --      DBMS_OUTPUT.put_line ('estamos en defi');
      FOR regmov IN cur_movaux LOOP
         BEGIN
    perror:=0;
            SELECT NVL(MAX(nnumlin), 0)
              INTO w_nnumlin
              FROM movctatecnica
             WHERE scontra = regmov.scontra
               AND nversio = regmov.nversio
               AND ctramo = regmov.ctramo
               AND ccompani = regmov.ccompani;

            w_nnumlin := w_nnumlin + 1;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               w_nnumlin := 1;
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, 'pac_reaseguro_rec.llenar_tablas_defi', v_traza,
                           'Err SELECT FROM movctatecnica:' || regmov.scontra || ', '
                           || regmov.nversio || ', ' || regmov.ctramo || ', '
                           || regmov.ccompani,
                           ' SQLERRM = ' || SQLERRM);
               perror := 104863;
               psql := SQLERRM;
               pscesrea := TO_NUMBER(TO_CHAR(regmov.scontra) || TO_CHAR(regmov.nversio)
                                     || TO_CHAR(regmov.ctramo) || TO_CHAR(regmov.ccompani));
         END;

         v_traza := 81;

           p_traza_proceso(pcempres, 81, 28880, 'PAC_REASEGURO.BOFY', NULL,
                                              'BATCH_CIERRE', v_traza,
                                              'Entramos en LLENAR_TABLAS_DEFI');

         IF perror = 0 THEN
            BEGIN
               IF v_cmultimon = 1 THEN
                  v_sseguro := NULL;
                  v_scontra := regmov.scontra;

                  IF regmov.ctramo = 5 THEN
                     BEGIN
                        IF NVL(regmov.npoliza, 0) = 0 THEN
                           IF NVL(regmov.nsinies, 0) != 0 THEN
                              SELECT sseguro
                                INTO v_sseguro
                                FROM sin_siniestro
                               WHERE nsinies = regmov.nsinies;

                              v_scontra := NULL;
                           END IF;
                        ELSE
                           SELECT sseguro
                             INTO v_sseguro
                             FROM seguros
                            WHERE npoliza = regmov.npoliza
                              AND ncertif = regmov.ncertif;

                           v_scontra := NULL;
                        END IF;
                     EXCEPTION
                        WHEN OTHERS THEN
                           p_tab_error(f_sysdate, f_user,
                                       'pac_reaseguro_rec.llenar_tablas_defi', v_traza,
                                       'Err SELECT FROM SEGUROS:' || regmov.npoliza || ', '
                                       || regmov.ncertif,
                                       ' SQLERRM = ' || SQLERRM);
                           perror := 111360;
                           psql := SQLERRM;
                           pscesrea := TO_NUMBER(TO_CHAR(regmov.scontra)
                                                 || TO_CHAR(regmov.nversio)
                                                 || TO_CHAR(regmov.ctramo)
                                                 || TO_CHAR(regmov.ccompani));
                     END;
                  END IF;

                  perror := pac_oper_monedas.f_datos_contraval(v_sseguro, NULL, v_scontra,
                                                               regmov.fmovimi, 3, v_itasa,
                                                               v_fcambio);

                  IF perror <> 0 THEN
                     psql := SQLERRM;
                     pscesrea := TO_NUMBER(TO_CHAR(regmov.scontra) || TO_CHAR(regmov.nversio)
                                           || TO_CHAR(regmov.ctramo)
                                           || TO_CHAR(regmov.ccompani));
                  END IF;
               END IF;

               v_traza := 82;


                -- FIN BUG 18423 - 02/11/2011 - JMP - LCOL000 - Multimoneda
               INSERT INTO movctatecnica
                           (ccompani, nversio, scontra, ctramo,
                            nnumlin, fmovimi, fefecto, cconcep,
                            cdebhab, iimport, cestado,
                            sproces, scesrea,
                            -- BUG 18423 - 02/11/2011 - JMP - LCOL000 - Multimoneda
                            iimport_moncon,
                            fcambio
                                   -- FIN BUG 18423 - 02/11/2011 - JMP - LCOL000 - Multimoneda
               ,
                            cempres, sproduc, npoliza, ncertif,
                            nsinies   -- 22076 AVT 18/06/2012
                                   , ccompapr,   -- 24463 AVT 11/01/2013 s'afegeix la Cia pròpia
                            ccorred,
                            nid -- ML - 4818 - APUNTES MANUALES
                            )   -- 22/05/2015  CJMR  0033158: Actualización campo CCORRED en los cierres de Reaseguro
                    VALUES (regmov.ccompani, regmov.nversio, regmov.scontra, regmov.ctramo,
                            w_nnumlin, regmov.fmovimi, regmov.fefecto, regmov.cconcep,
                            regmov.cdebhab, NVL(regmov.iimport, 0), regmov.cestado,
                            regmov.sproces,
                                           --AVT 10/05/05 en alguns XL l'import ve a NULL
                            NULL,
                            -- BUG 18423 - 02/11/2011 - JMP - LCOL000 - Multimoneda
                            f_round(NVL(regmov.iimport, 0) * v_itasa, v_cmoncontab),
                            DECODE(v_cmultimon, 0, NULL, NVL(v_fcambio, regmov.fmovimi))
                                                                                        -- FIN BUG 18423 - 02/11/2011 - JMP - LCOL000 - Multimoneda
               ,
                            regmov.cempres, regmov.sproduc, regmov.npoliza, regmov.ncertif,
                            regmov.nsinies   -- 22076 AVT 18/06/2012
                                          , regmov.ccompapr,   -- 24463 AVT 11/01/2013 s'afegeix la Cia pròpia
                            regmov.ccorred,
                            regmov.nid -- ML - APUNTES MANUALES - 4818
                            );   -- 22/05/2015  CJMR  0033158: Actualización campo CCORRED en los cierres de Reaseguro

               v_traza := 83;

               -- ML - 4818 - APUNTES MANUALES
				 -- INSERT EN CTATECNICA
				 IF regmov.nid IS NOT NULL THEN
				 	BEGIN
					  perror := PAC_REA.F_SET_CTATECNICA(regmov.ccompani, regmov.scontra, regmov.nversio, regmov.ctramo, 1, 3, 1, NULL, NULL, regmov.cempres, regmov.sproduc, regmov.ccorred);
					EXCEPTION
						WHEN OTHERS THEN
							NULL;
					END;
				 END IF;

               DELETE FROM movctaaux
                     WHERE ROWID = regmov.ROWID;
            EXCEPTION
               WHEN DUP_VAL_ON_INDEX THEN
                  perror := 104862;
                  psql := SQLERRM;
                  pscesrea := TO_NUMBER(TO_CHAR(regmov.scontra) || TO_CHAR(regmov.nversio)
                                        || TO_CHAR(regmov.ctramo) || TO_CHAR(regmov.ccompani));
               WHEN OTHERS THEN
                  p_tab_error(f_sysdate, f_user, 'pac_reaseguro_rec.llenar_tablas_defi',
                              v_traza,
                              'Err INSERT INTO movctatecnica:' || regmov.scontra || ', '
                              || regmov.nversio || ', ' || regmov.ctramo || ', '
                              || regmov.ccompani,
                              ' SQLERRM = ' || SQLERRM);
                  perror := 104861;
                  psql := SQLERRM;
                  pscesrea := TO_NUMBER(TO_CHAR(regmov.scontra) || TO_CHAR(regmov.nversio)
                                        || TO_CHAR(regmov.ctramo) || TO_CHAR(regmov.ccompani));
            END;
         END IF;
      END LOOP;

      /* SELECT count(*)
       into countReas
           FROM reaseguroaux r
          WHERE r.cempres = pcempres
            AND r.fcierre = TO_dATE(pfperfin,'DD-MM-YYYY') --last_day(pfperfin)
            AND ctramo < 6;*/

      v_traza := 84;
      --perror:=12;
      IF perror = 0 THEN
       -- perror:=12;
         FOR regces IN cur_detces LOOP

            BEGIN
               v_traza := 85;

               -- BUG 18423 - 02/11/2011 - JMP - LCOL000 - Multimoneda
               IF v_cmultimon = 1 THEN
			     -- ini bug-12994
               	  BEGIN
	               	  -- si es siniestro tomar la fecha de pago
	               	  IF regces.NSINIES IS NOT NULL AND regces.SIDEPAG IS NOT NULL THEN
	               	  	SELECT FCAMBIO INTO fecha_conversion FROM SIN_TRAMITA_PAGO WHERE SIDEPAG = regces.SIDEPAG AND NSINIES = regces.NSINIES;
	               	  ELSE
	               	  	-- de lo contrario tomar la fecha de emision
	               	  	SELECT FEMISIO INTO fecha_conversion FROM SEGUROS WHERE SSEGURO = regces.sseguro;
	               	  END IF;
	              EXCEPTION
	              	WHEN OTHERS THEN
	              		fecha_conversion := SYSDATE;
	              END;
	              -- fin bug-12994
                  perror := pac_oper_monedas.f_datos_contraval(regces.sseguro, NULL, NULL,
                                                                fecha_conversion, --bug-12994
															   3, v_itasa,
                                                               v_fcambio);

                  IF perror <> 0 THEN
                     psql := SQLERRM;
                     pscesrea := regces.scesrea;
                  END IF;
               END IF;

               v_traza := 86;

                p_tab_error(f_sysdate, f_user, 'pac_reaseguro_rec.llenar_tablas_defi',
                              v_traza,
                              'Err INSERT INTO movctatecnica:',
                              ' SQLERRM = ' );

               -- FIN BUG 18423 - 02/11/2011 - JMP - LCOL000 - Multimoneda
              -- perror:=112;
               INSERT INTO reaseguro
                           (codtipo, cempres, sproces, scesrea,
                            fefecto, fvencim, sseguro, nriesgo,
                            cgarant, nmovimi, cgenera, nsinies,
                            sidepag, scontra, nversio, ctramo,
                            pporcen, sfacult, icesiot, icapcet,
                            fcierre, ccompani, pcesion, pcomisi,
                            icesion, icapces, icomisi, fcalcul,
                            cramo, cmodali, ctipseg, ccolect,
                            cactivi, cagente, cagrpro, npoliza,
                            ncertif, nrecibo, idtosel, ipritarrea,
                            psobreprima, idtoseltot, ipritarreatot,
-- BUG 11051 - 16/09/2009 - FAL - Informar camps de comptabilitat a partir de cesionesrea
                            nreemb, nfact, nlinea,
                                                  -- FI Bug 11051 - 16/09/2009 - FAL
                                                  sreaemi,   -- 14833 AVT 18-06-2010
                            -- BUG 18423 - 02/11/2011 - JMP - LCOL000 - Multimoneda
                            icesion_moncon,
                            icapces_moncon,
                            icomisi_moncon,
                            fcambio,
                            -- FIN BUG 18423 - 02/11/2011 - JMP - LCOL000 - Multimoneda
                            icomext,   --AGG 08/05/2014 Se a`ade la comisi?n de la extra prima
                                    iextrea,   --AGG 02/07/2014 Se a`ade la extra prima
                                      iretencionf, --CONFCC-5
                            -- INI- ML - 4610 - RETENCION EN MONEDA CONTABLE
                                    iretencionf_moncon) -- 4610
                            -- FIN- ML - 4610 - RETENCION EN MONEDA CONTABLE
                    VALUES (regces.codtipo, regces.cempres, regces.sproces, regces.scesrea,
                            regces.fefecto, regces.fvencim, regces.sseguro, regces.nriesgo,
                            regces.cgarant, regces.nmovimi, regces.cgenera, regces.nsinies,
                            regces.sidepag, regces.scontra, regces.nversio, regces.ctramo,
                            regces.pporcen, regces.sfacult, regces.icesiot, regces.icapcet,
                            regces.fcierre, regces.ccompani, regces.pcesion, regces.pcomisi,
                            regces.icesion, regces.icapces, regces.icomisi, regces.fcalcul,
                            regces.cramo, regces.cmodali, regces.ctipseg, regces.ccolect,
                            regces.cactivi, regces.cagente, regces.cagrpro, regces.npoliza,
                            regces.ncertif, regces.nrecibo, regces.idtosel, regces.ipritarrea,
                            regces.psobreprima, regces.idtoseltot, regces.ipritarreatot,
                            -- BUG 11051 - 16/09/2009 - FAL - Informar camps de comptabilitat a partir de cesionesrea
                            regces.nreemb, regces.nfact, regces.nlinea,
                                                                       -- FI Bug 11051 - 16/09/2009 - FAL
                                                                       regces.sreaemi,   -- 14833 AVT 18-06-2010
                            -- BUG 18423 - 02/11/2011 - JMP - LCOL000 - Multimoneda
                            f_round(regces.icesion * v_itasa, v_cmoncontab),
                            f_round(regces.icapces * v_itasa, v_cmoncontab),
                            f_round(regces.icomisi * v_itasa, v_cmoncontab),
                            DECODE(v_cmultimon, 0, NULL, NVL(v_fcambio, regces.fcierre)),
                            -- FIN BUG 18423 - 02/11/2011 - JMP - LCOL000 - Multimoneda
                            regces.icomext,   --AGG 08/05/2014 Se a`ade la comisi?n de la extra prima
                                           regces.iextrea,   --AGG 02/07/2014 Se a`ade la extra prima
                                           regces.iretencionf,--CONFCC-5
                            -- INI- ML - 4610 - RETENCION EN MONEDA CONTABLE
                            f_round(regces.iretencionf * v_itasa, v_cmoncontab)); -- 4610
                            -- FIN- ML - 4610 - RETENCION EN MONEDA CONTABLE

               v_traza := 87;

               DELETE FROM reaseguroaux
                     WHERE ROWID = regces.ROWID;
            EXCEPTION
               WHEN DUP_VAL_ON_INDEX THEN
                  p_tab_error(f_sysdate, f_user, 'pac_reaseguro_rec.llenar_tablas_defi',
                              v_traza,
                              'Err INSERT INTO reaseguro:' || regces.scontra || ', '
                              || regces.nversio || ', ' || regces.ctramo || ', '
                              || regces.ccompani || ', ' || regces.scesrea,
                              ' SQLERRM = ' || SQLERRM);
                  perror := 108187;
                  psql := SQLERRM;
                  pscesrea := regces.scesrea;
               WHEN OTHERS THEN
                  perror := 108188;
                  psql := SQLERRM;
                  pscesrea := regces.scesrea;
            END;

            v_traza := 88;
            contador := contador + 1;

            IF contador >= 5 THEN
               contador := 0;
               COMMIT;
            --SET TRANSACTION USE ROLLBACK SEGMENT rollbig;
            END IF;
         END LOOP;

         COMMIT;
      --SET TRANSACTION USE ROLLBACK SEGMENT rollbig;
      END IF;

      v_traza := 89;


   ---------------------------   *******************************************************
   -- LLENAR TABLA READEPOSITO

        IF perror = 0 THEN
         FOR reg IN cur_readepositoaux LOOP
            BEGIN
               v_traza := 86;


                INSERT INTO READEPOSITO
                                 (
                                  ccompani, nversio, scontra,
                                  ctramo, sproces, scesrea,
                                  cempres, fcierre, sproduc,
                                  sseguro, npoliza, ncertif,
                                  nsinies, cagente, ppartici,
                                  ccompapr, icesion, preserv,
                                  ireserv,
                                  icesion_moncon,
                                  ireserv_moncon,
                                  pinteresdep, iinterdep,
                                  iinterdep_moncon,
                                  pimpint, iimpint,
                                  iimpint_moncon
                                )
                          VALUES (
                                  reg.ccompani, reg.nversio, reg.scontra,
                                  reg.ctramo, reg.sproces, reg.scesrea,
                                  reg.cempres, reg.fcierre, reg.sproduc,
                                  reg.sseguro, reg.npoliza, reg.ncertif,
                                  reg.nsinies, reg.cagente, reg.ppartici,
                                  reg.ccompapr, reg.icesion, reg.preserv,
                                  reg.ireserv, reg.icesion_moncon,
                                  reg.ireserv_moncon, reg.pinteresdep,
                                  reg.iinterdep, reg.iinterdep_moncon,
                                  reg.pimpint, reg.iimpint, reg.iimpint_moncon
                                  );

               v_traza := 87;

               DELETE FROM readepositoaux
                     WHERE ROWID = reg.ROWID;
            EXCEPTION
               WHEN DUP_VAL_ON_INDEX THEN
                  p_tab_error(f_sysdate, f_user, 'pac_reaseguro_rec.llenar_tablas_defi',
                              v_traza,
                              'Err INSERT INTO reaseguro:' || reg.scontra || ', '
                              || reg.nversio || ', ' || reg.ctramo || ', '
                              || reg.ccompani || ', ' || reg.scesrea,
                              ' SQLERRM = ' || SQLERRM);
                  perror := 108187;
                  psql := SQLERRM;
                  pscesrea := reg.scesrea;
               WHEN OTHERS THEN
                  perror := 108188;
                  psql := SQLERRM;
                  pscesrea := reg.scesrea;
            END;
         END LOOP;
        COMMIT;
       END IF;

   ---------------------------   *******************************************************


      /****************** cml.- Ho esborrarem simult?niament amb els inserts d'adalt
          IF perror = 0 THEN
             COMMIT;
             SET TRANSACTION USE ROLLBACK SEGMENT rollbig;
             DELETE
             FROM  movctaaux
             WHERE cempres = pcempres
               AND fcierre = pfperfin; -- canvi pfcierre -> pfperfin
             COMMIT;
             SET TRANSACTION USE ROLLBACK SEGMENT rollbig;
             DELETE
             FROM  reaseguroaux
             WHERE cempres = pcempres
               AND fcierre = pfperfin; -- canvi pfcierre -> pfperfin
          END IF;
      ************/
     RETURN(perror);
   EXCEPTION
      WHEN OTHERS THEN
         perror := 108190;
         psql := SQLERRM;
         pscesrea := SQLCODE;
         RETURN(perror);
   END llenar_tablas_defi;

-- ********************************************************************
   FUNCTION actu_dates(
      pcempres IN NUMBER,
      pmes IN NUMBER,
      pany IN NUMBER,
      pfcierre IN DATE,
      psql OUT VARCHAR2,
      pscesrea OUT NUMBER)
      RETURN NUMBER IS
      perror         NUMBER := 0;

      CURSOR cur_ces IS
         SELECT ce.scontra, ce.nversio, ce.ctramo, ce.scesrea, 0 sreaemi, 0 sfacult
           FROM tramos tr, cesionesrea ce, codicontratos ct
          WHERE ct.cempres = pcempres
            AND ct.scontra = ce.scontra
            AND ce.fgenera < pfcierre + 1
            AND ce.fcontab = LAST_DAY(TO_DATE('01' || '/' || pmes || '/' || pany, 'dd/mm/yyyy'))
            AND ce.ctramo <> 5
            AND tr.scontra = ce.scontra
            AND tr.nversio = ce.nversio
            AND tr.ctramo = ce.ctramo
            AND(tr.fultbor IS NULL
                OR(tr.cfrebor = 1
                   AND tr.fultbor < TO_DATE('01' || '/' || pmes || '/' || pany, 'dd/mm/yyyy'))
                OR(tr.cfrebor = 2
                   AND tr.fultbor < ADD_MONTHS(TO_DATE('01' || '/' || pmes || '/' || pany,
                                                       'dd/mm/yyyy'),
                                               -1))
                OR(tr.cfrebor = 3
                   AND tr.fultbor < ADD_MONTHS(TO_DATE('01' || '/' || pmes || '/' || pany,
                                                       'dd/mm/yyyy'),
                                               -2))
                OR(tr.cfrebor = 4
                   AND tr.fultbor < ADD_MONTHS(TO_DATE('01' || '/' || pmes || '/' || pany,
                                                       'dd/mm/yyyy'),
                                               -3))
                OR(tr.cfrebor = 6
                   AND tr.fultbor < ADD_MONTHS(TO_DATE('01' || '/' || pmes || '/' || pany,
                                                       'dd/mm/yyyy'),
                                               -5))
                OR(tr.cfrebor = 12
                   AND tr.fultbor < ADD_MONTHS(TO_DATE('01' || '/' || pmes || '/' || pany,
                                                       'dd/mm/yyyy'),
                                               -11)))
         UNION
         SELECT de.scontra, de.nversio, de.ctramo, de.scesrea, de.sreaemi, de.sfacult
           FROM reasegemi re, detreasegemi de, codicontratos ct, cuafacul cu
          WHERE ct.cempres = pcempres
            AND ct.scontra = de.scontra
            AND de.sfacult = cu.sfacult
            AND re.fgenera < pfcierre + 1
            AND re.sreaemi = de.sreaemi
            AND(cu.fultbor IS NULL
                OR(cu.cfrebor = 1
                   AND cu.fultbor < TO_DATE('01' || '/' || pmes || '/' || pany, 'dd/mm/yyyy'))
                OR(cu.cfrebor = 2
                   AND cu.fultbor < ADD_MONTHS(TO_DATE('01' || '/' || pmes || '/' || pany,
                                                       'dd/mm/yyyy'),
                                               -1))
                OR(cu.cfrebor = 3
                   AND cu.fultbor < ADD_MONTHS(TO_DATE('01' || '/' || pmes || '/' || pany,
                                                       'dd/mm/yyyy'),
                                               -2))
                OR(cu.cfrebor = 4
                   AND cu.fultbor < ADD_MONTHS(TO_DATE('01' || '/' || pmes || '/' || pany,
                                                       'dd/mm/yyyy'),
                                               -3))
                OR(cu.cfrebor = 6
                   AND cu.fultbor < ADD_MONTHS(TO_DATE('01' || '/' || pmes || '/' || pany,
                                                       'dd/mm/yyyy'),
                                               -5))
                OR(cu.cfrebor = 12
                   AND cu.fultbor < ADD_MONTHS(TO_DATE('01' || '/' || pmes || '/' || pany,
                                                       'dd/mm/yyyy'),
                                               -11)))
            AND re.fcierre = LAST_DAY(TO_DATE('01/' || pmes || '/' || pany, 'dd/mm/yyyy'));
   BEGIN
      v_traza := 90;

      FOR c IN cur_ces LOOP
         -- AVT 28-02-2005 Actualitzaci? dels contractes (per tots els trams diferents al de Facultatiu)
         IF c.ctramo <> 5 THEN
            BEGIN
               UPDATE tramos
                  SET fultbor = LAST_DAY(TO_DATE(pmes || '/' || pany, 'mm/yyyy'))
                WHERE scontra = c.scontra
                  AND nversio = c.nversio
                  AND ctramo = c.ctramo
                  AND(fultbor < LAST_DAY(TO_DATE(pmes || '/' || pany, 'mm/yyyy'))
                      OR fultbor IS NULL);
            EXCEPTION
               WHEN OTHERS THEN
                  perror := 103823;
                  psql := SQLERRM;
                  pscesrea := c.scesrea;
            END;

            v_traza := 91;
            COMMIT;
         ELSE   -- Actualitza la cab?alera del Facultatiu
            BEGIN
               UPDATE cuafacul
                  SET fultbor = LAST_DAY(TO_DATE(pmes || '/' || pany, 'mm/yyyy'))
                WHERE sfacult = c.sfacult
                  AND(fultbor < LAST_DAY(TO_DATE(pmes || '/' || pany, 'mm/yyyy'))
                      OR fultbor IS NULL   -- AVT 10/06/2005
                                        );
            EXCEPTION
               WHEN OTHERS THEN
                  perror := 103823;
                  psql := SQLERRM;
                  pscesrea := c.scesrea;
                  RETURN(perror);
            END;

            v_traza := 92;
            COMMIT;
         END IF;
      END LOOP;

      IF perror = 0 THEN
         BEGIN
            UPDATE empresas
               SET fborrea = LAST_DAY(TO_DATE(pmes || '/' || pany, 'mm/yyyy'))
             WHERE cempres = pcempres;
         EXCEPTION
            WHEN OTHERS THEN
               perror := 102531;
               psql := SQLERRM;
               pscesrea := pcempres;
         END;

         v_traza := 93;
         COMMIT;
      END IF;

      RETURN(perror);
   END actu_dates;

-- **********************************************************************
   FUNCTION f_buscomgarant(
      pscomrea IN NUMBER,
      psseguro IN NUMBER,
      pcgarant IN NUMBER,
      pfefecto IN DATE,
      ppcomias OUT NUMBER)
      RETURN NUMBER IS
--  ***********************************************************************
--  AQU? ES BUSCA EL % DE COMISSI? QUE CORRESPON A UN CODI DE COMISSI?
--  (CCOMREA), EN FUNCI? D'UNA GARANTIA...
-- ***********************************************************************
      codi_error     NUMBER := 0;
      regcontin      comcontin%ROWTYPE;
      w_fini         DATE;
      w_ffin         DATE;
      w_cduraci      seguros.cduraci%TYPE;   -- BUG 0025803NUMBER(1);
      w_nduraci      seguros.nduraci%TYPE;   -- BUG 0025803  NUMBER(3);
      w_durex        comgarant.cdurdes%TYPE;   -- BUG 0025803 NUMBER(3);
      W_EDAD         COMGARANT.CANYDES%TYPE;   -- BUG 0025803 NUMBER(3);
      w_cempres      NUMBER := pac_parametros.F_PARINSTALACION_N('EMPRESADEF');

      CURSOR cur_comgarant1 IS
         SELECT *
           FROM comgarant
          WHERE scomrea = pscomrea
            AND cgaraux <> 0
            AND canydes <= w_edad
            AND canyhas > w_edad
            AND cdurdes <= w_durex
            AND cdurhas > w_durex;

      CURSOR cur_comgarant2 IS
         SELECT *
           FROM comgarant
          WHERE scomrea = pscomrea
            AND cgaraux = 0
            AND canydes <= w_edad
            AND canyhas > w_edad
            AND cdurdes <= w_durex
            AND cdurhas > w_durex;
   BEGIN
      --       Aqu? llegim la data inicial del seguro i la duraci?...
      v_traza := 94;

      IF NVL(psseguro, 0) <> 0 THEN
         BEGIN
            SELECT fefecto, fvencim, cduraci, nduraci
              INTO w_fini, w_ffin, w_cduraci, w_nduraci
              FROM seguros
             WHERE sseguro = psseguro;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               p_tab_error(f_sysdate, f_user, 'pac_reaseguro_rec.f_buscomgarant', v_traza,
                           'Err SELECT FROM seguros:' || psseguro, ' SQLERRM = ' || SQLERRM);
               codi_error := 101903;
               RETURN(codi_error);
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, 'pac_reaseguro_rec.f_buscomgarant', v_traza,
                           'Err SELECT FROM seguros:' || psseguro, ' SQLERRM = ' || SQLERRM);
               codi_error := 101919;
               RETURN(codi_error);
         END;

         IF w_cduraci = 0
            OR w_cduraci = 4 THEN
            w_durex := 98;   -- 15173 AVT 23-06-2010
         ELSIF w_cduraci = 1 THEN
            w_durex := w_nduraci;
         ELSIF W_CDURACI = 2 THEN
            w_durex := w_nduraci / 12;
         ELSIF w_cduraci = 3 THEN
            w_durex := MONTHS_BETWEEN(w_ffin, w_fini) / 12;
         END IF;

         v_traza := 95;

         IF w_durex IS NULL THEN
            w_durex := 98;   -- 15173 AVT 23-06-2010
         END IF;

         w_edad := MONTHS_BETWEEN(pfefecto, w_fini) / 12;
      ELSE
         w_durex := 1;
      END IF;
      IF TO_CHAR(W_FINI, 'yyyy') < TO_CHAR(F_SYSDATE, 'yyyy')
            AND NVL(PAC_PARAMETROS.F_PAREMPRESA_N(w_cempres, 'RETROACTIVA_REA'), 0) = 1 THEN
            w_edad := 1;
         ELSE
            W_EDAD := MONTHS_BETWEEN(PFEFECTO, W_FINI) / 12;
         END IF;

      --       Aqu? llegim el COMGARANT i el COMCONTIN...
      FOR reggar1 IN cur_comgarant1 LOOP
         IF reggar1.cgaraux = pcgarant
            AND pcgarant IS NOT NULL THEN
            ppcomias := reggar1.pcomias;
            v_traza := 96;

            BEGIN
               SELECT *
                 INTO regcontin
                 FROM comcontin
                WHERE scomrea = reggar1.scomrea
                  AND cgaraux = reggar1.cgaraux;

               IF TO_CHAR(pfefecto, 'mm') = 01 THEN
                  ppcomias := regcontin.pcomi01;
               ELSIF TO_CHAR(pfefecto, 'mm') = 02 THEN
                  ppcomias := regcontin.pcomi02;
               ELSIF TO_CHAR(pfefecto, 'mm') = 03 THEN
                  ppcomias := regcontin.pcomi03;
               ELSIF TO_CHAR(pfefecto, 'mm') = 04 THEN
                  ppcomias := regcontin.pcomi04;
               ELSIF TO_CHAR(pfefecto, 'mm') = 05 THEN
                  ppcomias := regcontin.pcomi05;
               ELSIF TO_CHAR(pfefecto, 'mm') = 06 THEN
                  ppcomias := regcontin.pcomi06;
               ELSIF TO_CHAR(pfefecto, 'mm') = 07 THEN
                  ppcomias := regcontin.pcomi07;
               ELSIF TO_CHAR(pfefecto, 'mm') = 08 THEN
                  ppcomias := regcontin.pcomi08;
               ELSIF TO_CHAR(pfefecto, 'mm') = 09 THEN
                  ppcomias := regcontin.pcomi09;
               ELSIF TO_CHAR(pfefecto, 'mm') = 10 THEN
                  ppcomias := regcontin.pcomi10;
               ELSIF TO_CHAR(pfefecto, 'mm') = 11 THEN
                  ppcomias := regcontin.pcomi11;
               ELSIF TO_CHAR(pfefecto, 'mm') = 12 THEN
                  ppcomias := regcontin.pcomi12;
               END IF;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  NULL;
               WHEN OTHERS THEN
                  p_tab_error(f_sysdate, f_user, 'pac_reaseguro_rec.f_buscomgarant', v_traza,
                              'Err SELECT FROM comcontin:' || psseguro,
                              ' SQLERRM = ' || SQLERRM);
                  codi_error := 104851;
                  RETURN(codi_error);
            END;

            RETURN(codi_error);
         END IF;
      END LOOP;

      v_traza := 97;

      FOR reggar2 IN cur_comgarant2 LOOP
         ppcomias := reggar2.pcomias;

         BEGIN
            SELECT *
              INTO regcontin
              FROM comcontin
             WHERE scomrea = reggar2.scomrea
               AND cgaraux = reggar2.cgaraux;

            IF TO_CHAR(pfefecto, 'mm') = 01 THEN
               ppcomias := regcontin.pcomi01;
            ELSIF TO_CHAR(pfefecto, 'mm') = 02 THEN
               ppcomias := regcontin.pcomi02;
            ELSIF TO_CHAR(pfefecto, 'mm') = 03 THEN
               ppcomias := regcontin.pcomi03;
            ELSIF TO_CHAR(pfefecto, 'mm') = 04 THEN
               ppcomias := regcontin.pcomi04;
            ELSIF TO_CHAR(pfefecto, 'mm') = 05 THEN
               ppcomias := regcontin.pcomi05;
            ELSIF TO_CHAR(pfefecto, 'mm') = 06 THEN
               ppcomias := regcontin.pcomi06;
            ELSIF TO_CHAR(pfefecto, 'mm') = 07 THEN
               ppcomias := regcontin.pcomi07;
            ELSIF TO_CHAR(pfefecto, 'mm') = 08 THEN
               ppcomias := regcontin.pcomi08;
            ELSIF TO_CHAR(pfefecto, 'mm') = 09 THEN
               ppcomias := regcontin.pcomi09;
            ELSIF TO_CHAR(pfefecto, 'mm') = 10 THEN
               ppcomias := regcontin.pcomi10;
            ELSIF TO_CHAR(pfefecto, 'mm') = 11 THEN
               ppcomias := regcontin.pcomi11;
            ELSIF TO_CHAR(pfefecto, 'mm') = 12 THEN
               ppcomias := regcontin.pcomi12;
            END IF;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               NULL;
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, 'pac_reaseguro_rec.f_buscomgarant', v_traza,
                           'Err SELECT FROM comcontin:' || psseguro, ' SQLERRM = ' || SQLERRM);
               codi_error := 104851;
               RETURN(codi_error);
         END;

         RETURN(codi_error);
      END LOOP;

      RETURN(codi_error);
   END f_buscomgarant;

   --CONF-587 Inicio
-- **********************************************************************
   FUNCTION f_genera_recobros(
      pcempres IN NUMBER,
      pfperfin IN DATE,
      psalvam  IN NUMBER) RETURN NUMBER IS

      CURSOR c_siniestros (pfini DATE) IS
        SELECT DISTINCT si.nsinies, si.fsinies, si.sseguro, si.nriesgo, s.npoliza, s.cobjase,
               s.cramo, s.cmodali, s.ctipseg, s.ccolect, s.cactivi, s.sproduc,
               NVL(NVL(s.fcaranu, s.fanulac), s.fvencim) fvencim, s.fefecto fefecto,
               si.fnotifi, pa.sidepag, m.cestpag, pa.isinret,
               (pa.isinret - NVL(pa.iretenc,0) - NVL(pa.iiva,0)) iimpsin
          FROM seguros s, sin_siniestro si, sin_tramitacion t, sin_tramita_pago pa,
               sin_tramita_movpago m, productos p
         WHERE s.sseguro = si.sseguro
           AND s.cempres = pcempres
           AND s.ctiprea <> 2
           AND si.nsinies = t.nsinies
           AND t.nsinies = pa.nsinies
           AND t.ntramit = pa.ntramit
           AND pa.sidepag = m.sidepag
           AND m.nmovpag = (SELECT MAX(nmovpag)
                              FROM sin_tramita_movpago
                             WHERE sidepag = m.sidepag)
           AND m.cestpag NOT IN (8) --no esta anulado
           --AND TRUNC(pa.fordpag) BETWEEN TO_DATE(TO_CHAR(pfperfin, 'mmyyyy'), 'mmyyyy') AND pfperfin
           AND TRUNC(pa.fordpag) BETWEEN pfini AND pfperfin
           /*AND (TRUNC(m.fefepag) > pfperfin
                OR m.fefepag IS NULL)*/ --??? Esta condici£¿ debe ir? o la siguiente?
           --IAXIS-13089 AABC Cambios en el recobro para asignaciongeneracion del codigo 39
           -- se deja la segunda condicion para que tome las fechas que deben ser
           -- AND (TRUNC(m.fefepag) BETWEEN TO_DATE('0101' || TO_CHAR(pfperfin, 'yyyy'), 'ddmmyyyy') AND pfperfin
           --     OR m.fefepag IS NULL)
           AND p.sproduc = s.sproduc
           AND pa.ctippag = 7 --Recobro
           --AND pa.cconpag = DECODE(psalvam, 111, 111, pa.cconpag) --Reemplazar 111 por el codigo real de Salvamentos en Siniestros
           AND p.creaseg = 1;

      CURSOR c_cesiones(p_sseguro NUMBER) IS
        SELECT c.scontra, c.nversio, c.ctramo, c.pcesion pctcontrato, d.ccompani, d.pcesion pctcompani
          FROM cesionesrea c, cuadroces d
         WHERE c.sseguro = p_sseguro
           AND c.cgenera = 3
           AND c.icesion > 0
           AND c.scontra = d.scontra
           AND c.nversio = d.nversio
           AND c.ctramo = d.ctramo
           AND c.ctramo IS NOT NULL
           AND c.ctrampa IS NULL;

      nvalor   NUMBER;
      v_fini   DATE:=  trunc(pfperfin,'mm') ;

   BEGIN

     FOR sini IN c_siniestros (v_fini) LOOP

       FOR ces IN c_cesiones(sini.sseguro) LOOP

        nvalor := (sini.isinret * ces.pctcontrato) / 100;
        nvalor := (nvalor * ces.pctcompani) / 100;

        IF NVL(nvalor, 0) <> 0 THEN
           BEGIN
              INSERT INTO ctapbaux
                          (sproces, fcierre, scontra, ccompani, cconceppb, tipo, iimport,
                           cempres, nversio, ctramo, sproduc)
                   VALUES (NULL, pfperfin, ces.scontra, ces.ccompani, 39, 2, nvalor,
                           pcempres, ces.nversio, ces.ctramo, sini.sproduc);
           EXCEPTION
              WHEN OTHERS THEN
                 p_tab_error(f_sysdate, f_user, 'f_genera_recobros', 2,
                             'Err INSERT INTO ctapbaux:' || pcempres || ', ' || pfperfin
                             || ', ' || ces.scontra || ', ' || ces.ccompani || ', ' || 39,
                             ' SQLERRM = ' || SQLERRM);
                 ROLLBACK;
                 RETURN(SQLCODE);
           END;
        END IF;

      END LOOP;

    END LOOP;

    RETURN 0;

   END f_genera_recobros;

-- **********************************************************************
   FUNCTION f_arrastre_perdidas(
      pcempres  IN NUMBER,
      pscontra  IN NUMBER,
      pccompani IN NUMBER,
      pnversio  IN NUMBER,
      pctramo   IN NUMBER,
      psproduc  IN NUMBER,
      pfperfin  IN DATE) RETURN NUMBER IS
--  *********************************************************************
--  Retorna el valor de arrastre de p£¿didas a guardar para el contrato/tramo/version/compania/producto
--  basado en la configuraci£¿ de anhos de arrastre y el acumulado a la fecha.
-- **********************************************************************

      CURSOR cperdidas IS
         SELECT SUM(c.iimport) importe
           FROM ctapb c
          WHERE c.cempres = pcempres
            AND c.ccompani = pccompani
            AND c.scontra = pscontra
            AND c.nversio = pnversio
            AND c.ctramo = pctramo
            AND c.sproduc = psproduc
            AND c.cconceppb = 69 --Resultado CTO
            AND c.fcierre = pfperfin
            --AND TO_CHAR(c.fcierre,'mm') = '12' --Cierre de fin de anho
         HAVING SUM(c.iimport) < 0 --P£¿dida
         ORDER BY c.fcierre DESC;

      nanhos    NUMBER;
      nanhosarr NUMBER;
      nvalor    NUMBER := 0;
      ncount    NUMBER := 0;
      bind      BOOLEAN := FALSE;

   BEGIN

      --Revisar la configuraci£¿ de Arrastre en Tramos

      v_traza := 201;

      BEGIN
        SELECT t.nanyosloss, t.narrastrecont
          INTO nanhos, nanhosarr
          FROM tramos t
         WHERE t.scontra = pscontra
           AND t.nversio = pnversio
           AND t.ctramo  = pctramo;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            nanhos    := NULL;
            nanhosarr := NULL;
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, 'pac_reaseguro_rec.f_arrastre_perdidas', v_traza,
                        'Err SELECT FROM tramos:' || pscontra || ', ' || pnversio || ', ' || pctramo
                        || ', ' || pccompani || ', ' || psproduc,
                        ' SQLERRM = ' || SQLERRM);
      END;

      IF NVL(nanhos,0) != 0
        AND NVL(nanhos,0) != NVL(nanhosarr,0) THEN

        ncount := NVL(nanhosarr,0);

        --Revisar si existe p£¿dida para el contrato/version al corte
        FOR cp IN cperdidas LOOP

           nvalor := nvalor + cp.importe;
           ncount := ncount + 1;
           bind   := TRUE;

           --IF ncount = nanhos THEN
              EXIT;
           --END IF;

        END LOOP;

      END IF;

      RETURN nvalor;

   END f_arrastre_perdidas;

-- **********************************************************************
   FUNCTION f_actu_cont_arrastre(
      pcempres  IN NUMBER,
      pfperfin  IN DATE) RETURN NUMBER IS
--  *********************************************************************
--  Actualiza el contador de anhos de arrastre.
-- **********************************************************************

      CURSOR cperdidas(pscontra NUMBER, pnversio NUMBER, pctramo NUMBER) IS
         SELECT SUM(c.iimport) importe
           FROM ctapb c
          WHERE c.cempres = pcempres
            AND c.scontra = pscontra
            AND c.nversio = pnversio
            AND c.ctramo = pctramo
            AND c.cconceppb = 69 --Resultado CTO
            AND c.fcierre = pfperfin
            --AND TO_CHAR(c.fcierre,'mm') = '12' --Cierre de fin de anho
         HAVING SUM(c.iimport) < 0 --P£¿dida
         ORDER BY c.fcierre DESC;

      CURSOR cctapb IS
         SELECT scontra, nversio, ctramo
           FROM ctapbaux
          WHERE fcierre = pfperfin
            AND cempres = pcempres
         GROUP BY scontra, nversio, ctramo;

      nanhos    NUMBER;
      nanhosarr NUMBER;
      ncount    NUMBER := 0;
      bind      BOOLEAN := FALSE;
      nreturn   NUMBER := 0;

   BEGIN

      FOR ct IN cctapb LOOP

        bind   := FALSE;

        --Revisar la configuraci£¿ de Arrastre en Tramos

        v_traza := 202;

        BEGIN
          SELECT t.nanyosloss, t.narrastrecont
            INTO nanhos, nanhosarr
            FROM tramos t
           WHERE t.scontra = ct.scontra
             AND t.nversio = ct.nversio
             AND t.ctramo  = ct.ctramo;
        EXCEPTION
           WHEN NO_DATA_FOUND THEN
              nanhos    := NULL;
              nanhosarr := NULL;
           WHEN OTHERS THEN
              p_tab_error(f_sysdate, f_user, 'pac_reaseguro_rec.f_actu_cont_arrastre', v_traza,
                          'Err SELECT FROM tramos:' || ct.scontra || ', ' || ct.nversio || ', ' || ct.ctramo,
                          ' SQLERRM = ' || SQLERRM);
              RETURN SQLCODE;
        END;

        IF NVL(nanhos,0) != 0
          AND NVL(nanhos,0) != NVL(nanhosarr,0) THEN

          ncount := NVL(nanhosarr,0);

          --Revisar si existe p£¿dida para el contrato/version al corte
          FOR cp IN cperdidas(ct.scontra, ct.nversio, ct.ctramo) LOOP

             ncount := ncount + 1;
             bind   := TRUE;

             --IF ncount = nanhos THEN
                EXIT;
             --END IF;

          END LOOP;

          --Actualiza el contador de a£¿s de arrastre solo si se recuper£¿p£¿dida
          IF bind THEN
            BEGIN
              UPDATE tramos
                 SET narrastrecont = NVL(narrastrecont,0) + 1
               WHERE scontra = ct.scontra
                 AND nversio = ct.nversio
                 AND ctramo  = ct.ctramo;
            EXCEPTION
               WHEN OTHERS THEN
                  p_tab_error(f_sysdate, f_user, 'pac_reaseguro_rec.f_actu_cont_arrastre', v_traza,
                              'Err SELECT FROM tramos:' || ct.scontra || ', ' || ct.nversio || ', ' || ct.ctramo,
                              ' SQLERRM = ' || SQLERRM);
                  RETURN SQLCODE;
            END;
          END IF;

        END IF;

      END LOOP;

      RETURN nreturn;

   END f_actu_cont_arrastre;

-- **********************************************************************
   FUNCTION f_actualiza_ctapb(
      psproces   IN NUMBER,
      pcempres   IN NUMBER,
      pscontra   IN NUMBER,
      pccompani  IN NUMBER,
      pnversio   IN NUMBER,
      pctramo    IN NUMBER,
      pcconceppb IN NUMBER,
      ptipo      IN NUMBER,
      psproduc   IN NUMBER,
      pimporte   IN NUMBER,
      pfperfin   IN DATE,
      ptraza     IN NUMBER) RETURN NUMBER IS
--  *********************************************************************
--  Actualiza el importe de las tabla ctapbaux, acumulando el valor
--  **********************************************************************

      nerror    NUMBER := 0;

   BEGIN

     BEGIN
       UPDATE ctapbaux
          SET iimport = NVL(iimport,0) + pimporte
        WHERE scontra = pscontra
          AND ccompani = pccompani
          AND nversio = pnversio
          AND ctramo = pctramo
          AND cconceppb = pcconceppb
          AND sproduc = psproduc
          AND fcierre = pfperfin;
     EXCEPTION
       WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user,
                     'pac_reaseguro_rec.f_actualiza_ctapb', ptraza,
                     'Err UPDATE ctapbaux:' || pccompani || ', '
                     || pnversio || ', ' || pscontra || ', ' || pcconceppb || ', ' || psproduc || ', '
                     || pctramo,
                     ' SQLERRM = ' || SQLERRM);
         ROLLBACK;
         RETURN SQLCODE;
     END;

     IF SQL%ROWCOUNT = 0 THEN
       BEGIN
          INSERT INTO ctapbaux
                  (sproces, fcierre, scontra, ccompani, cconceppb, tipo, iimport,
                   cempres, nversio, ctramo, sproduc)
           VALUES (psproces, pfperfin, pscontra, pccompani, pcconceppb, ptipo, pimporte,
                   pcempres, pnversio, pctramo, psproduc);
       EXCEPTION
          WHEN OTHERS THEN
             p_tab_error(f_sysdate, f_user,
                         'pac_reaseguro_rec.f_actualiza_ctapb', v_traza,
                         'Err INSERT ctapbaux:' || pccompani || ', '
                         || pnversio || ', ' || pscontra || ', ' || pcconceppb || ', ' || psproduc || ', '
                         || pctramo,
                         ' SQLERRM = ' || SQLERRM);
             ROLLBACK;
             RETURN SQLCODE;
       END;
     END IF;

     RETURN 0;

   END f_actualiza_ctapb;

   --CONF-587 Fin

-- **********************************************************************
    FUNCTION f_calcul_pb(pmodo IN NUMBER, pcempres IN NUMBER, pfperfin IN DATE, pany IN NUMBER, psproces IN NUMBER)
      RETURN NUMBER IS
--  ***********************************************************************
--  PRIMER BUSQUEM ELS CONCEPTES DE COMPTE TECNIC A MOVCTATECNICA (1,5,9,11)
--  I DESPRES CALCULEM ELS DE COMPTE TECNIC DE PARTICIPACI? EN BENEFICIS
--  I FEM ELS INSERTS A LA TAULA CTAPBAUX. (DESPESES, PB, PNC,PPLP)
-- ***********************************************************************
      codi_error     NUMBER := 0;
      wsproces       procesoscab.sproces%TYPE;   -- BUG 0025803 NUMBER;
      gastos         contratos.pgastos%TYPE;   -- BUG 0025803 NUMBER(5, 2);
      partbene       contratos.ppartbene%TYPE;   -- BUG 0025803 NUMBER(15, 2);
      entrada        ctapbaux.iimport%TYPE;   -- BUG 0025803 NUMBER(15, 2);
      salida         ctapbaux.iimport%TYPE;   -- BUG 0025803 NUMBER(15, 2);
      par_ced        ctapbaux.iimport%TYPE;   -- BUG 0025803 NUMBER(15, 2);
      import         ctapbaux.iimport%TYPE;   -- BUG 0025803 NUMBER(15, 2);
      total          ctapbaux.iimport%TYPE;   -- BUG 0025803 NUMBER(15, 2);
      val            ctapbaux.iimport%TYPE;   -- BUG 0025803 NUMBER(15, 2);
      wany_ant       NUMBER;
      saldo          ctapbaux.iimport%TYPE;   -- BUG 0025803 NUMBER(15, 2);
      --Inicio CONF-587
      pct_cesion     NUMBER;
      siniestralidad NUMBER;
      resultcto      NUMBER;
      perdida_arr    NUMBER;
      resultcto_fin  NUMBER;
      parutil_act    NUMBER;
      parutil_ant    NUMBER;
      reservas_lib   NUMBER;
      salvamentos    NUMBER;
      pagos_sini     NUMBER;
      comisiones     NUMBER;
      reserva_ced    NUMBER;
      reserva_sin    NUMBER;
      res_sin_ant    NUMBER;
      ajuste_act     NUMBER;
      pct_part_util  NUMBER;
      res_ced_ant    NUMBER;
      numdecimales   NUMBER := 0;
      vcescomp       NUMBER(10, 5) := 0;
      vicompa        reamovpagos.icompan%TYPE := 0;
      vicesion       reamovpagos.itramo%TYPE := 0;
      gastoscia      contratos.pgastos%TYPE;
      vfeccierrant   DATE;
      w_nnumlin      NUMBER;

    con_gastosrea  CONSTANT NUMBER(3) := 41; --Gastos del reasegurador
	con_salvament  CONSTANT NUMBER(3) := 39; --Salvamentos
	con_arrastrep  CONSTANT NUMBER(3) := 62; --Arrastre de p#?didas
	con_perdiant   CONSTANT NUMBER(3) := 67; --Perdida a#? anterior
	con_resulcto   CONSTANT NUMBER(3) := 69; --Resultado CTO
	con_resctofin  CONSTANT NUMBER(3) := 70; --Resultado CTO Final
	con_pbactual   CONSTANT NUMBER(3) := 71; --PB Actual AABG Se comenta para no ser insertado
	con_pbant      CONSTANT NUMBER(3) := 72; --PB Corte Anterior
	con_pbtotal    CONSTANT NUMBER(3) := 73; --PB total del a#? actual AABG Se comenta para no ser insertado
	con_siniestral CONSTANT NUMBER(3) := 74; --Siniestralidad
	con_resprimant CONSTANT NUMBER(3) := 75; --Reserva primas a#? anterior
	con_ressinant  CONSTANT NUMBER(3) := 76; --Reservas de siniestros a#? anterior
	con_resersini  CONSTANT NUMBER(3) := 25; --Reservas de siniestros
	con_sinipag    CONSTANT NUMBER(3) := 5; --Siniestros pagados
	con_reembolsos CONSTANT NUMBER(3) := 6; --Reembolso reservas o Reservas Liberadas
	con_comisiones CONSTANT NUMBER(3) := 2; --Comisiones
	con_depositos  CONSTANT NUMBER(3) := 3; --Depositos o RESERVA PRIMAS CEDIDAS
	con_pb         CONSTANT NUMBER(3) := 12; --Participaci#? beneficios AABG Se comenta para no ser insertado
      --Fin CONF-587


      CURSOR conceptes(wcempres NUMBER, wfperfin DATE) IS
         SELECT compania, contrato, version, ctramo, sproduc, concepte, tipo, SUM(importe) importe FROM
           (
           --Movimientos desde el inicio del a£¿ hasta la fecha de cierre (valores definitivos)
           SELECT   t.ccompani compania, t.scontra contrato, t.nversio VERSION, m.ctramo, m.sproduc,
                    m.cconcep concepte, DECODE(m.cconcep, 2, 1, 3, 1, 5, 1, 9, 1, 11, 1, 25, 1, 41, 1, 62, 1,
                                                          1, 2, 6, 2, 39, 2,
                                                          2) tipo,
                    --SUM(m.iimport_moncon * DECODE(m.cdebhab, 1, -1, 1)) importe
                    SUM(m.iimport_moncon) importe
               FROM ctatecnica t, codicontratos c, movctatecnica m, contratos ct
              WHERE c.cempres = wcempres
                AND t.scontra = c.scontra
                AND m.cconcep IN (1, 2, 3, 5, 6, 9, 11, 62, 68, 25) --CONF-587
                AND t.scontra = m.scontra
                AND t.nversio = m.nversio
                AND t.ccompani = m.ccompani
                AND m.fmovimi <= wfperfin
                AND m.fmovimi >= TO_DATE('01/01/' || pany, 'dd/mm/yyyy')
                AND t.scontra = ct.scontra
                AND t.sproduc = m.sproduc --CONF-587
                AND DECODE(pmodo, 2, 1, 0) = 1 --Si es cierre definitivo
        AND t.ctramo = m.ctramo --OJSO
                AND ct.nversio = m.nversio --OJSO
           GROUP BY t.ccompani, t.scontra, t.nversio, m.ctramo, m.sproduc, m.cconcep
           UNION ALL
           --Movimientos desde el inicio del a£¿ hasta la fecha de cierre (valores Aux)
           SELECT   t.ccompani compania, t.scontra contrato, t.nversio VERSION, m.ctramo, m.sproduc,
                    m.cconcep concepte, DECODE(m.cconcep, 2, 1, 3, 1, 5, 1, 9, 1, 11, 1, 25, 1, 41, 1, 62, 1,
                                                          1, 2, 6, 2, 39, 2,
                                                          2) tipo,
                    --SUM(m.iimport_moncon * DECODE(m.cdebhab, 1, -1, 1)) importe
                    SUM(m.iimport) importe
               FROM ctatecnica t, codicontratos c, movctaaux m, contratos ct
              WHERE c.cempres = wcempres
                AND t.scontra = c.scontra
                AND m.cconcep IN (1, 2, 3, 5, 6, 9, 11, 62, 68, 25) --CONF-587
                AND t.scontra = m.scontra
                AND t.nversio = m.nversio
                AND t.ccompani = m.ccompani
                AND m.fmovimi <= wfperfin
                AND m.fmovimi >= TO_DATE('01/01/' || pany, 'dd/mm/yyyy')
                AND t.scontra = ct.scontra
                AND t.sproduc = m.sproduc --CONF-587
                AND DECODE(pmodo, 2, 0, 1) = 1 --Si es cierre Previo
        AND t.ctramo = m.ctramo --OJSO
                AND ct.nversio = m.nversio --OJSO
           GROUP BY t.ccompani, t.scontra, t.nversio, m.ctramo, m.sproduc, m.cconcep
           UNION ALL
           --Saldo al cierre final del a£¿ anterior por cada concepto
           SELECT   pb.ccompani compania, pb.scontra contrato, pb.nversio, pb.ctramo, pb.sproduc,
                    pb.cconceppb, DECODE(pb.cconceppb, 2, 1, 3, 1, 5, 1, 9, 1, 11, 1, 25, 1, 62, 1,
                                                       1, 2, 6, 2, 39, 2,
                                                       2) tipo,
                    --SUM(pb.iimport * DECODE(pb.tipo, 1, -1, 1)) importeant
                    SUM(pb.iimport) importeant
               FROM ctapb pb
              WHERE pb.cempres = wcempres
                AND pb.cconceppb IN (1, 2, 3, 5, 6, 9, 11, 62, 68, 25, 39, 72)
                AND pb.fcierre = vfeccierrant
           GROUP BY pb.ccompani, pb.scontra, pb.nversio, pb.ctramo, pb.sproduc, pb.cconceppb
           )
           GROUP BY compania, contrato, version, ctramo, sproduc, concepte, tipo;

      CURSOR ctapb(wcempres NUMBER, wfperfin DATE, wany NUMBER) IS
         SELECT   ccompani, scontra, nversio, ctramo, sproduc
             FROM ctapbaux
            WHERE fcierre = wfperfin
              AND cempres = wcempres
         GROUP BY ccompani, scontra, nversio, ctramo, sproduc;


   BEGIN
      DELETE FROM ctapbaux
            WHERE cempres = pcempres
            AND fcierre = pfperfin; --CONF-587

      COMMIT;

      wany_ant := pany - 1;

      vfeccierrant := LAST_DAY(TO_DATE('01' || '/' || '12' || '/' || wany_ant, 'dd/mm/yyyy')); --Fecha de cierre definitivo A£¿ anterior

      codi_error := f_genera_recobros(pcempres, pfperfin, NULL); --CONF-587

      v_traza := 98;

      --Se insertan todos los conceptos: Saldo A£¿ anterior + Movimientos a fecha de cierre
      FOR a IN conceptes(pcempres, pfperfin) LOOP
         IF NVL(a.importe, 0) <> 0 THEN
            BEGIN
               INSERT INTO ctapbaux
                           (sproces, fcierre, scontra, ccompani, cconceppb, tipo,
                            iimport, cempres, nversio, ctramo, sproduc)
                    VALUES (wsproces, pfperfin, a.contrato, a.compania, a.concepte, a.tipo,
                            a.importe, pcempres, a.version, a.ctramo, a.sproduc);
            EXCEPTION
               WHEN OTHERS THEN
                  --DBMS_OUTPUT.put_line (' 1 ' || SQLERRM);
                  p_tab_error(f_sysdate, f_user, 'pac_reaseguro_rec.f_calcul_pb', v_traza,
                              'Err INSERT INTO ctapbaux:' || wsproces || ', ' || pfperfin
                              || ', ' || a.contrato || ', ' || a.compania || ', '
                              || a.concepte || ', ' || a.tipo || ', ' || a.ctramo || ', ' || a.sproduc,
                              ' SQLERRM = ' || SQLERRM);
                  ROLLBACK;
                  --codi_error := Error l'insertar a la taula CTAPBAUX'
                  RETURN(codi_error);
            END;
         END IF;
      END LOOP;

      v_traza := 99;

      FOR b IN ctapb(pcempres, pfperfin, pany) LOOP

         gastos         := NULL; --CONF-587
         gastoscia      := NULL; --CONF-587
         import         := NULL; --CONF-587
         total          := NULL; --CONF-587
         val            := NULL; --CONF-587
         pct_cesion     := NULL; --CONF-587
         siniestralidad := NULL; --CONF-587
         resultcto      := NULL; --CONF-587
         perdida_arr    := NULL; --CONF-587
         resultcto_fin  := NULL; --CONF-587
         parutil_act    := NULL; --CONF-587
         parutil_ant    := NULL; --CONF-587
         reservas_lib   := NULL; --CONF-587
         salvamentos    := NULL; --CONF-587
         pagos_sini     := NULL; --CONF-587
         comisiones     := NULL; --CONF-587
         reserva_ced    := NULL; --CONF-587
         reserva_sin    := NULL; --CONF-587
         ajuste_act     := NULL; --CONF-587
         pct_part_util  := NULL; --CONF-587
         res_sin_ant    := NULL; --CONF-587
         res_ced_ant    := NULL; --CONF-587

         BEGIN
            SELECT pgastos, ppartbene
              --busquem el % de despeses i de participacio en beneficis
            INTO   gastos, partbene
              FROM contratos
             WHERE scontra = b.scontra
               AND nversio = b.nversio;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               gastos := NULL;
               partbene := NULL;
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, 'pac_reaseguro_rec.f_calcul_pb', v_traza,
                           'Err SELECT FROM contratos:' || b.scontra || ', ' || b.nversio,
                           ' SQLERRM = ' || SQLERRM);
         END;

         v_traza := 111;

         --CONF-587 Inicio

         BEGIN
           SELECT pctgastos, pcesion -- % GASTOS DEL REASEGURADOR y % de Cesion
             INTO gastoscia, pct_cesion
             FROM cuadroces c
            WHERE c.scontra = b.scontra
              AND c.nversio = b.nversio
              AND c.ccompani = b.ccompani
              AND c.ctramo = b.ctramo;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               gastoscia := NULL;
               pct_cesion := NULL;
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, 'pac_reaseguro_rec.f_calcul_pb', v_traza,
                           'Err SELECT FROM cuadroces:' || b.scontra || ', ' || b.nversio || ', ' || b.ccompani || ', '
                           || b.ctramo || ', ' || b.sproduc,
                           ' SQLERRM = ' || SQLERRM);
         END;

         gastos := NVL(gastoscia, gastos);

         --Obtener % Participacion de utilidades

         BEGIN
           SELECT DISTINCT(t.pctpb)
             INTO pct_part_util
             FROM tramos t
            WHERE t.scontra = b.scontra
              AND t.nversio = b.nversio
              AND t.ctramo = b.ctramo;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               pct_part_util := NULL;
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, 'pac_reaseguro_rec.f_calcul_pb', v_traza,
                           'Err SELECT tramos:' || wsproces || ', ' || pfperfin || ', '
                           || b.scontra || ', ' || b.ccompani || ', ' || b.ctramo || ', ' || b.sproduc,
                           ' SQLERRM = ' || SQLERRM);
               RETURN SQLCODE;
         END;

         --CONF-587 Fin

         v_traza := 122;

         IF gastos IS NULL OR pct_cesion IS NULL OR pct_part_util IS NULL THEN

           p_tab_error(f_sysdate, f_user, 'pac_reaseguro_rec.f_calcul_pb', v_traza,
                           'Err params gastos:' || gastos || ', pct_cesion: ' || pct_cesion || ', pct_part_util ' || pct_part_util,
                           ' SQLERRM = ');
         ELSE

           IF gastos IS NOT NULL THEN

              SELECT SUM(iimport)
                --busquem l'import de les primes - anulacions i li apliquem el % de despesa
              INTO   import
                FROM ctapbaux
               WHERE scontra = b.scontra
                 AND nversio = b.nversio
                 AND ccompani = b.ccompani
                 AND cconceppb IN(1, 9)
                 AND fcierre = pfperfin
                 AND ctramo = b.ctramo
                 AND sproduc = b.sproduc;

              total := (import * gastos) / 100;
              v_traza := 101;

              --INI IAXIS 4551 AABG SE QUITA INSERT DE CONCEPTO 41
							 /*IF NVL(total, 0) <> 0 THEN
                  codi_error := f_actualiza_ctapb(wsproces, pcempres, b.scontra, b.ccompani, b.nversio, b.ctramo,
                                                  con_gastosrea, 1, b.sproduc, total, pfperfin, v_traza);
                  IF codi_error != 0 THEN
                     RETURN codi_error;
                  END IF;
               END IF;*/
							 --FIN IAXIS 4551 AABG SE QUITA INSERT DE CONCEPTO 41

              --
           END IF;

           --CONF-587 Inicio

           --Reservas de primas a£¿ anterior (Nuevo Concepto 75)

           /*SELECT SUM(iimport)
           INTO   res_ced_ant
             FROM ctapbaux
            WHERE scontra = b.scontra
              AND nversio = b.nversio
              AND ccompani = b.ccompani
              AND ctramo = b.ctramo
              AND sproduc = b.sproduc
              AND cconceppb = con_depositos --Depositos o Reserva primas cedidas
              AND fcierre = vfeccierrant; --A£¿ anterior

           v_traza := 123;

           IF NVL(res_ced_ant,0) != 0 THEN
             codi_error := f_actualiza_ctapb(wsproces, pcempres, b.scontra, b.ccompani, b.nversio, b.ctramo,
                                             con_resprimant, 2, b.sproduc, res_ced_ant, pfperfin, v_traza);
             IF codi_error != 0 THEN
               RETURN codi_error;
             END IF;
           END IF;*/

           --Reservas de siniestros a£¿ anterior (Nuevo Concepto 76)

           /*SELECT SUM(iimport)
           INTO   res_sin_ant
             FROM ctapbaux
            WHERE scontra = b.scontra
              AND nversio = b.nversio
              AND ccompani = b.ccompani
              AND ctramo = b.ctramo
              AND sproduc = b.sproduc
              AND cconceppb = con_resersini --Reserva Siniestros
              AND fcierre = vfeccierrant; --A£¿ anterior

           v_traza := 124;

           IF NVL(res_sin_ant,0) != 0 THEN
             codi_error := f_actualiza_ctapb(wsproces, pcempres, b.scontra, b.ccompani, b.nversio, b.ctramo,
                                             con_ressinant, 2, b.sproduc, res_sin_ant, pfperfin, v_traza);
             IF codi_error != 0 THEN
               RETURN codi_error;
             END IF;
           END IF;*/

           --Obtener el valor de los Salvamentos o Recobros
           SELECT SUM(iimport)
            INTO  salvamentos
              FROM ctapbaux
             WHERE scontra = b.scontra
               AND nversio = b.nversio
               AND ccompani = b.ccompani
               AND ctramo = b.ctramo
               AND sproduc = b.sproduc
               AND cconceppb = con_salvament
               AND fcierre = pfperfin;

           --Calculo de Siniestralidad -> (RESERVA DE SINIESTROS + SINIESTROS PAGADOS - SALVAMENTOS) / PRIMAS CEDIDAS

           --Obtener Siniestros pagados

           SELECT SUM(iimport)
            INTO   pagos_sini
              FROM ctapbaux
             WHERE scontra = b.scontra
               AND nversio = b.nversio
               AND ccompani = b.ccompani
               AND ctramo = b.ctramo
               AND sproduc = b.sproduc
               AND cconceppb = con_sinipag
               AND fcierre = pfperfin;

           --Obtener reserva Siniestros

           SELECT SUM(iimport)
           INTO   reserva_sin
             FROM ctapbaux
            WHERE scontra = b.scontra
              AND nversio = b.nversio
              AND ccompani = b.ccompani
              AND ctramo = b.ctramo
              AND sproduc = b.sproduc
              AND cconceppb = con_resersini
              AND fcierre = pfperfin;
           --
           v_traza := 114;
           --
           siniestralidad := ROUND((reserva_sin + NVL(pagos_sini,0) - NVL(salvamentos,0)) / import * 100, 3);
           --
           IF NVL(siniestralidad, 0) != 0 THEN
             codi_error := f_actualiza_ctapb(wsproces, pcempres, b.scontra, b.ccompani, b.nversio, b.ctramo,
                                             con_siniestral, 1, b.sproduc, siniestralidad, pfperfin, v_traza);
             IF codi_error != 0 THEN
               RETURN codi_error;
             END IF;
           END IF;

           --CONF-587 Fin

           v_traza := 104;

           --perdida_arr := f_arrastre_perdidas(pcempres, b.scontra, b.ccompani, b.nversio, b.ctramo, b.sproduc, pfperfin);
           perdida_arr := 0; --OJO Revisar

           v_traza := 105;

           IF NVL(perdida_arr, 0) <> 0 THEN
              codi_error := f_actualiza_ctapb(wsproces, pcempres, b.scontra, b.ccompani, b.nversio, b.ctramo,
                                              con_arrastrep, 2, b.sproduc, perdida_arr, pfperfin, v_traza);
              IF codi_error != 0 THEN
                RETURN codi_error;
              END IF;
           END IF;
           --
           --CONF-587 Inicio

           --Resultado Contrato (Nuevo Concepto 69 - Resultado CTO)

           v_traza := 113;

           SELECT SUM(iimport)
            INTO   reservas_lib
              FROM ctapbaux
             WHERE scontra = b.scontra
               AND nversio = b.nversio
               AND ccompani = b.ccompani
               AND ctramo = b.ctramo
               AND sproduc = b.sproduc
               AND cconceppb = con_reembolsos --Reembolso reservas o Reservas Liberadas
               AND fcierre = pfperfin;

           SELECT SUM(iimport)
            INTO   comisiones
              FROM ctapbaux
             WHERE scontra = b.scontra
               AND nversio = b.nversio
               AND ccompani = b.ccompani
               AND ctramo = b.ctramo
               AND sproduc = b.sproduc
               AND cconceppb = con_comisiones --Comisiones
               AND fcierre = pfperfin;

           SELECT SUM(iimport)
           INTO   reserva_ced
             FROM ctapbaux
            WHERE scontra = b.scontra
              AND nversio = b.nversio
              AND ccompani = b.ccompani
              AND ctramo = b.ctramo
              AND sproduc = b.sproduc
              AND cconceppb = con_depositos --Depositos o RESERVA PRIMAS CEDIDAS
              AND fcierre = pfperfin;

           resultcto := import + NVL(reservas_lib,0) + NVL(salvamentos,0) + NVL(res_ced_ant, 0) + NVL(res_sin_ant, 0)
                        - comisiones - reserva_ced - NVL(pagos_sini,0) - NVL(reserva_sin,0) - total;

           v_traza := 117;

           codi_error := f_actualiza_ctapb(wsproces, pcempres, b.scontra, b.ccompani, b.nversio, b.ctramo,
                                           con_resulcto, 1, b.sproduc, resultcto, pfperfin, v_traza);
           IF codi_error != 0 THEN
             RETURN codi_error;
           END IF;

           --Resultado CTO Final (Nuevo Concepto 70) PERDIDA ARRASTRADA + RESULTADO CTO

           IF resultcto > 0 THEN
              resultcto_fin := NVL(perdida_arr,0) + resultcto;
           ELSE
              resultcto_fin := resultcto;
           END IF;

           v_traza := 118;

           codi_error := f_actualiza_ctapb(wsproces, pcempres, b.scontra, b.ccompani, b.nversio, b.ctramo,
                                           con_resctofin, 1, b.sproduc, resultcto_fin, pfperfin, v_traza);
           IF codi_error != 0 THEN
             RETURN codi_error;
           END IF;

           --PARTICIPACION DE UTILIDADES AL CORTE ACTUAL (Nuevo Concepto 71)

           parutil_act := (resultcto_fin * pct_part_util) / 100;

           v_traza := 119;

           -- INI AABG IAXIS 4551 Se comenta para no ser insertado el concepto 71
						/*codi_error := f_actualiza_ctapb(wsproces, pcempres, b.scontra, b.ccompani, b.nversio, b.ctramo,
                                            con_pbactual, 1, b.sproduc, parutil_act, pfperfin, v_traza);
            IF codi_error != 0 THEN
              RETURN codi_error;
            END IF;*/
		   -- FIN AABG IAXIS 4551 Se comenta para no ser insertado el concepto 71


           /*IF TO_CHAR(pfperfin,'mm') = '12' THEN
             codi_error := f_actualiza_ctapb(wsproces, pcempres, b.scontra, b.ccompani, b.nversio, b.ctramo,
                                             con_pb, 1, b.sproduc, parutil_act, pfperfin, v_traza);
             IF codi_error != 0 THEN
               RETURN codi_error;
             END IF;
           END IF;*/ --OJSO

           --PARTICIPACION DE UTILIDADES AL CORTE ANTERIOR (Nuevo Concepto 72)

           SELECT SUM(iimport)
           INTO   parutil_ant
             FROM ctapbaux
            WHERE scontra = b.scontra
              AND nversio = b.nversio
              AND ccompani = b.ccompani
              AND ctramo = b.ctramo
              AND sproduc = b.sproduc
              AND cconceppb = con_pbant --Participaci£¿ de utilidades A£¿ Anterior
              AND fcierre = pfperfin;

           -- INI AABG IAXIS 4551 Se comenta para no ser insertado el concepto 72
			/*IF NVL(parutil_ant,0) = 0 THEN


             --Busca la PB del A£¿ Anterior
             SELECT SUM(iimport)
             INTO   parutil_ant
               FROM ctapbaux
              WHERE scontra = b.scontra
                AND nversio = b.nversio
                AND ccompani = b.ccompani
                AND ctramo = b.ctramo
                AND sproduc = b.sproduc
                AND cconceppb = con_pbactual --Participaci£¿ de utilidades
                AND fcierre = LAST_DAY(TO_DATE('01' || '/' || '12' || '/' || wany_ant, 'dd/mm/yyyy')); --A£¿ anterior

             v_traza := 120;

             IF NVL(parutil_ant,0) != 0 THEN
               codi_error := f_actualiza_ctapb(wsproces, pcempres, b.scontra, b.ccompani, b.nversio, b.ctramo,
                                               con_pbant, 1, b.sproduc, parutil_ant, pfperfin, v_traza);
               IF codi_error != 0 THEN
                 RETURN codi_error;
               END IF;
             END IF;

           END IF;*/
		   -- FIN AABG IAXIS 4551 Se comenta para no ser insertado el concepto 72


           --AJUSTE COMISION A£¿ ACTUAL (Nuevo Concepto 73)

           --IF NVL(parutil_ant,0) >= 0 THEN --OJSO

             ajuste_act := parutil_act - NVL(parutil_ant,0);

             v_traza := 121;

             -- INI AABG IAXIS 4551 Se comenta para no ser insertado concepto 73
						/*codi_error := f_actualiza_ctapb(wsproces, pcempres, b.scontra, b.ccompani, b.nversio, b.ctramo,
                                            con_pbtotal, 1, b.sproduc, ajuste_act, pfperfin, v_traza);
            IF codi_error != 0 THEN
              RETURN codi_error;
            END IF;*/
			-- FIN AABG IAXIS 4551 Se comenta para no ser insertado concepto 73


           --END IF; --OJSO

           BEGIN
              SELECT NVL(MAX(nnumlin), 0)
                INTO w_nnumlin
                FROM movctaaux
               WHERE cempres = pcempres
                 AND scontra = b.scontra
                 AND nversio = b.nversio
                 AND ctramo = b.ctramo
                 AND ccompani = b.ccompani
                 AND sproduc = b.sproduc;
           EXCEPTION
              WHEN NO_DATA_FOUND THEN
                 w_nnumlin := 1;
              WHEN OTHERS THEN
                 p_tab_error(f_sysdate, f_user, 'pac_reaseguro_rec.f_calcul_pb',
                             v_traza,
                             'Err SELECT  FROM movctaaux:' || pcempres || ', '
                             || b.sproduc || ', ' || b.ccompani || ', ' || b.nversio
                             || ', ' || b.scontra || ', ' || b.ctramo,
                             ' SQLERRM = ' || SQLERRM);
                 codi_error := 104863;
                 RETURN codi_error;
           END;
           w_nnumlin := w_nnumlin + 1;

           DELETE FROM movctaaux
            WHERE ccompani = b.ccompani
              AND nversio = b.nversio
              AND scontra = b.scontra
              AND ctramo = b.ctramo
              AND fefecto = pfperfin
			  AND sproduc = b.sproduc --AABG IAXIS 4551 Se filtra por product para no borrar toda la info de la tabla
              AND cconcep IN (con_gastosrea, con_pb);

           --Traspasar nuevos conceptos a cuenta t£¿nica aux
            -- INI AABG IAXIS 4551 Se realiza validacion para insertar unicamente el cconceppb y no el con_pb

			BEGIN
				 INSERT INTO movctaaux
						(ccompani, nversio, scontra, ctramo, nnumlin, fmovimi, fefecto, cconcep, cdebhab, iimport,
						 cestado, sproces, scesrea, cempres, fcierre, sproduc, npoliza, ncertif, nsinies, ccompapr,
						 cevento, nid, cramo, ccorred)
						SELECT ccompani, nversio, scontra, ctramo, w_nnumlin, fcierre, fcierre,
									 DECODE(cconceppb, con_pbtotal, con_pb, cconceppb), tipo, iimport, 1, psproces, NULL,
									 cempres, fcierre, sproduc, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL
							FROM ctapbaux
						 WHERE fcierre = pfperfin
							 AND cempres = pcempres
							 AND scontra = b.scontra
							 AND ccompani = b.ccompani
							 AND nversio = b.nversio
							 AND ctramo = b.ctramo
							 AND sproduc = b.sproduc
							 AND cconceppb IN (con_gastosrea, con_pbtotal)
							 AND iimport IS NOT NULL;

			EXCEPTION
				 WHEN OTHERS THEN
						p_tab_error(f_sysdate, f_user, 'pac_reaseguro_rec.f_calcul_pb', v_traza,
												'ERROR AL INSERTAR EN MOVCTAAUX', ' SQLERRM = ' || SQLERRM);
			END;
			-- FIN AABG IAXIS 4551 Se realiza validacion para insertar unicamente el cconceppb y no el con_pb


           --Es el cierre definitivo del a£¿, traspasar a movctatecnica
           IF /*TO_CHAR(pfperfin,'mm') = '12' AND*/ pmodo = 2 THEN

             DELETE FROM movctatecnica
              WHERE ccompani = b.ccompani
                AND nversio = b.nversio
                AND scontra = b.scontra
                AND ctramo = b.ctramo
                AND fefecto = pfperfin
				AND sproduc = b.sproduc --AABG IAXIS 4551 Se filtra por product para no borrar toda la info de la tabla
                AND cconcep IN (con_gastosrea, con_pb);

             FOR cm IN (SELECT m.ccompani, m.nversio, m.scontra, m.ctramo, m.fmovimi, m.fefecto, m.cconcep, m.cdebhab, m.iimport, m.cestado,
                               m.sproces, m.scesrea, m.cempres, m.sproduc, m.npoliza, m.ncertif, m.nsinies,
                               m.ccompapr, m.cevento, m.nid,
                               m.cramo, m.ccorred
                          FROM movctaaux m
                         WHERE m.cempres = pcempres
                           AND m.fcierre = pfperfin
                           AND m.scontra = b.scontra
                           AND m.ccompani = b.ccompani
                           AND m.nversio = b.nversio
                           AND m.ctramo = b.ctramo
                           AND m.sproduc = b.sproduc
                           AND m.cconcep IN (con_gastosrea, con_pb)) LOOP

               BEGIN
                  SELECT NVL(MAX(nnumlin), 0)
                    INTO w_nnumlin
                    FROM movctatecnica
                   WHERE scontra = cm.scontra
                     AND nversio = cm.nversio
                     AND ctramo = cm.ctramo
                     AND ccompani = cm.ccompani;
                     --AND sproduc = b.sproduc;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     w_nnumlin := 1;
                  WHEN OTHERS THEN
                     p_tab_error(f_sysdate, f_user, 'pac_reaseguro_rec.f_calcul_pb',
                                 v_traza,
                                 'Err SELECT  FROM movctatecnica:' || pcempres || ', '
                                 || b.sproduc || ', ' || b.ccompani || ', ' || b.nversio
                                 || ', ' || b.scontra || ', ' || b.ctramo,
                                 ' SQLERRM = ' || SQLERRM);
                     codi_error := 104863;
                     --RETURN codi_error;
               END;
               w_nnumlin := w_nnumlin + 1;

               INSERT INTO movctatecnica (ccompani, nversio, scontra, ctramo, nnumlin, fmovimi, fefecto, cconcep, cdebhab, iimport, cestado,
                                          sproces, scesrea, iimport_moncon, fcambio, cempres, ctipmov, sproduc, npoliza, ncertif, nsinies,
                                          tdescri, tdocume, fliquid, ccompapr, spagrea, cevento, nid, fcontab, sidepag, cusucre, fcreac,
                                          cusumod, fmodif, cramo, ccorred)
               VALUES (cm.ccompani, cm.nversio, cm.scontra, cm.ctramo, w_nnumlin, cm.fmovimi, cm.fefecto, cm.cconcep, cm.cdebhab, cm.iimport, cm.cestado,
                       cm.sproces, cm.scesrea, cm.iimport, NULL, cm.cempres, NULL, cm.sproduc, cm.npoliza, cm.ncertif, cm.nsinies,
                       NULL, NULL, NULL, cm.ccompapr, NULL, cm.cevento, cm.nid, NULL, NULL, NULL, TRUNC(SYSDATE),
                       NULL, NULL, cm.cramo, cm.ccorred);

				-- ML - 4818 - APUNTES MANUALES
				-- INSERT EN CTATECNICA
				IF cm.nid IS NOT NULL THEN
				 	BEGIN
					  codi_error := PAC_REA.F_SET_CTATECNICA(cm.ccompani, cm.scontra, cm.nversio, cm.ctramo, 1, 3, 1, NULL, NULL, cm.cempres, cm.sproduc, cm.ccorred);
					EXCEPTION
						WHEN OTHERS THEN
							NULL;
					END;
				 END IF;

             END LOOP;

           END IF;

           --CONF-587 Fin

         END IF;

      END LOOP;

      v_traza := 110;

      -- si ?s definitiu
      IF pmodo = 2 THEN

         DELETE FROM ctapb
            WHERE cempres = pcempres
            AND fcierre = pfperfin;

         BEGIN
            INSERT INTO ctapb
                        (sproces, fcierre, scontra, ccompani, cconceppb, tipo, iimport,
                         cempres, nversio, ctramo, sproduc)
               SELECT sproces, fcierre, scontra, ccompani, cconceppb, tipo, iimport, cempres,
                      nversio, ctramo, sproduc
                 FROM ctapbaux
                WHERE fcierre = pfperfin
                  AND cempres = pcempres;
         EXCEPTION
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, 'pac_reaseguro_rec.f_calcul_pb', v_traza,
                           'Err INSERT INTO ctapb:' || wsproces || ', ' || pfperfin || ', '
                           || pcempres,
                           ' SQLERRM = ' || SQLERRM);
         END;
      END IF;

      --CONF-587 Inicio
      /*IF TO_CHAR(pfperfin,'mm') = '12' THEN

        codi_error := f_actu_cont_arrastre(pcempres,  pfperfin);

        IF codi_error != 0 THEN
          RETURN codi_error;
        END IF;

      END IF;*/ --OJO Revisar
      --CONF-587 Fin

      RETURN(codi_error);

   END f_calcul_pb;

   FUNCTION anyo_contrato(
      pscontra IN NUMBER,
      pnversio IN NUMBER,
      psfacult IN NUMBER,
      pexperr IN OUT VARCHAR2)
      RETURN NUMBER IS
      /* ***************************************************************************************************************************
          Funcion que mira si deber ir a buscar el a?o en que se inicio el contrato
       **************************************************************************************************************************** */

      -- ********************************** BUSCAR ANYO CONTRATO **************************************************
      FUNCTION buscar_ano_contratos(
         pscontra IN NUMBER,
         pnversio IN NUMBER,
         pexperr IN OUT VARCHAR2)
         RETURN NUMBER IS
      /* ***************************************************************************************************************************
          Funcion que retorna el a?o en que se inicio el contrato
       **************************************************************************************************************************** */
      BEGIN
         v_traza := 111;

         SELECT TO_CHAR(fconini, 'yyyy')
           INTO vany
           FROM contratos
          WHERE scontra = pscontra
            AND nversio = pnversio;

         RETURN(0);
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            p_tab_error(f_sysdate, f_user, 'pac_reaseguro_rec.buscar_ano_contratos', v_traza,
                        'Err SELECT FROM contratos:' || pscontra || ', ' || pnversio,
                        ' SQLERRM = ' || SQLERRM);
            pexperr := pexperr || ' ' || pscontra || ' ' || pnversio || ' ' || SQLERRM || ' '
                       || TO_CHAR(SQLCODE);
            RETURN(104332);   -- Contrato no encontrado en la tabla CONTRATOS
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, 'pac_reaseguro_rec.buscar_ano_contratos', v_traza,
                        'Err SELECT FROM contratos:' || pscontra || ', ' || pnversio,
                        ' SQLERRM = ' || SQLERRM);
            pexperr := pexperr || ' ' || pscontra || ' ' || pnversio || ' ' || SQLERRM || ' '
                       || TO_CHAR(SQLCODE);
            RETURN(104704);   -- Error al leer de CONTRATOS
      END buscar_ano_contratos;

      FUNCTION buscar_ano_cuafacul(psfacult IN NUMBER, pexperr IN OUT VARCHAR2)
         RETURN NUMBER IS
      /* ***************************************************************************************************************************
          Funcion que retorna el a?o en que se inicio el cuadro facultativo
       **************************************************************************************************************************** */
      BEGIN
         v_traza := 112;

         SELECT TO_CHAR(finicuf, 'yyyy')
           INTO vany
           FROM cuafacul
          WHERE sfacult = psfacult;

         RETURN(0);
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            p_tab_error(f_sysdate, f_user, 'pac_reaseguro_rec.buscar_ano_cuafacul', v_traza,
                        'Err SELECT FROM cuafacul:' || psfacult, ' SQLERRM = ' || SQLERRM);
            pexperr := pexperr || ' ' || psfacult || ' ' || SQLERRM || ' ' || TO_CHAR(SQLCODE);
            RETURN(104487);   -- Todavia no hay cuadro de facultativo
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, 'pac_reaseguro_rec.buscar_ano_cuafacul', v_traza,
                        'Err SELECT FROM cuafacul:' || psfacult, ' SQLERRM = ' || SQLERRM);
            pexperr := pexperr || ' ' || psfacult || ' ' || SQLERRM || ' ' || TO_CHAR(SQLCODE);
            RETURN(107518);   -- Error al leer de CUAFACUL
      END buscar_ano_cuafacul;
   BEGIN
      IF pscontra IS NOT NULL THEN
         error := buscar_ano_contratos(pscontra, pnversio, pexperr);
      ELSE
         error := buscar_ano_cuafacul(psfacult, pexperr);
      END IF;

      RETURN(error);
   EXCEPTION
      WHEN OTHERS THEN
         error := SQLCODE;
         RETURN(error);
   END anyo_contrato;

   FUNCTION buscar_tipocon(pscontra IN NUMBER, pexperr IN OUT VARCHAR2)
      RETURN NUMBER IS
/* ***************************************************************************************************************
   Funcion que busca el CONTRATO O AGRUPACION
  **************************************************************************************************************** */
   BEGIN
      IF pscontra IS NOT NULL THEN
         BEGIN
            SELECT NVL(sconagr, scontra), DECODE(sconagr, NULL, 2, 1)
              INTO vramo, vtipram
              FROM codicontratos
             WHERE scontra = pscontra;

            RETURN(0);
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               pexperr := pexperr || ' ' || pscontra || ' ' || SQLERRM || ' '
                          || TO_CHAR(SQLCODE);
               RETURN(104697);   -- Contrato no encontrado en CODICONTRATOS
            WHEN OTHERS THEN
               pexperr := pexperr || ' ' || pscontra || ' ' || SQLERRM || ' '
                          || TO_CHAR(SQLCODE);
               RETURN(104516);   -- Error en CODICONTRATOS
         END;
      ELSE
         vtipram := 3;
         RETURN(0);
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         error := SQLCODE;
         RETURN(error);
   END buscar_tipocon;

   -- *********************************** CALCULO DE LOS IMPORTES **************************************************
   FUNCTION proceso_tramo_1(
      pscontra IN NUMBER,
      pnversio IN NUMBER,
      picesion IN OUT NUMBER,
      ppcesion IN OUT NUMBER,
      pnsegcon OUT NUMBER,
      pnsegver OUT NUMBER)
      RETURN NUMBER IS
      /* ****************************************************************************************************************************
        Funcion que realiza el tratamiento especial del importe y porcentaje de la cesion en el tramo 1 (obligatorio)
        **************************************************************************************************************************** */
      error          NUMBER;
      vplocal        NUMBER;
      vplocpro       NUMBER;
      vversiopro     NUMBER;
   BEGIN
      error := pac_llibsin.busca_plocal(pscontra, pnversio, vplocal, pnsegcon, pnsegver);

      IF error <> 0 THEN
         RETURN(error);
      END IF;
      -- INICIO INFORCOL 18-11-2019
      vplocali := NVL(vplocal,0);
      ppcesion := ppcesion - (NVL(vplocal,0) * ppcesion) / 100;
      picesion := picesion - (NVL(vplocal,0) * picesion) / 100;
      -- FIN INFORCOL 18-11-2019
      RETURN(0);
   EXCEPTION
      WHEN OTHERS THEN
         error := SQLCODE;
         RETURN(error);
   END proceso_tramo_1;

   FUNCTION importe_total(pitramo IN NUMBER, pptramo IN NUMBER)
      RETURN NUMBER IS
      error          NUMBER;
   /* **************************************************************************************************************************
     Procedimiento que calcula el importe y porcentaje reasegurado por cada registro
     S'ha canviat la procedure per una funci? per tal de poder controlar l'error
   ************************************************************************************************************************* */
   BEGIN
      IF NVL(pptramo, 0) <> 0 THEN
         vitotal := (pitramo / pptramo) * 100;
      -- ojo!! regla de tres al rev?s
      ELSE
         vitotal := 0;
      END IF;   -- para obtener el total...

      RETURN(0);
   EXCEPTION
      WHEN OTHERS THEN
         error := SQLCODE;
         RETURN(error);
   END importe_total;

   PROCEDURE importe_compania(pitotal IN NUMBER, ppcompan IN NUMBER, picompa OUT NUMBER) IS
   /* **********************************************************************************************************************
      Funcion que calcula el importe de cada una de las compa?ias que intervienen en el reaseguro
      ************************************************************************************************************************* */
   BEGIN
      picompa := (pitotal * ppcompan) / 100;
   END importe_compania;

------------------------------------------------------------
   FUNCTION f_liquidaresreas(
      psproces IN NUMBER,
      pcempres IN NUMBER,
      pffin IN DATE,
      pexperr IN OUT VARCHAR2,
      pcmodo   IN NUMBER DEFAULT 0) --BUG 13164 12/05/2020 MPC Se CMODO = 3 Solo Llena tabla detalle ó CMODO = 0 continua proceso normal 
      RETURN NUMBER IS
-- *******************************************
-- Declaracion de las variables globales
-- *******************************************
      vnombre        liqresreaaux.tnombre%TYPE := ' ';   -- BUG 0025803 VARCHAR2(60) := ' ';
      vsitrie        liqresreaaux.tsitrie%TYPE := ' ';   -- BUG 0025803 VARCHAR2(150) := '';   --Situacion riesgo
      vfsin          liqresreaaux.fsin%TYPE;   -- BUG 0025803  DATE := NULL;
      vporrea        reamovpagos.ppropio%TYPE := 0;   -- BUG 0025803  NUMBER(8, 5) := 0;   -- % reasegurado
      vnsegcon       reamovpagos.scontra%TYPE;   -- BUG 0025803  NUMBER(6);
      vcpceco        NUMBER(8, 5) := 0;   -- % Compa?ia
      error          NUMBER(7) := 0;
      vpcesion       cesionesrea.pcesion%TYPE := 0;   -- BUG 0025803  NUMBER(8, 5) := 0;
      -- Pcesion con el tratamiento del tramo 1 si hace falta
      vicesion       cesionesrea.icesion%TYPE := 0;   -- BUG 0025803  NUMBER(14, 2) := 0;
      -- Icesion  con el tratamiento del tramo 1 si hace falta
      vcescomp       NUMBER(10, 5) := 0;
      -- Porcentaje de la compa??a respecto al % cedido en el tramo

      -- Tipo de ramo, 1 sconagr(codicontratos), 2 scontra (codicontratos),
      --   3 cramo(seguros)
      vscontra       cesionesrea.scontra%TYPE;   -- BUG 0025803 NUMBER(6);
      vnversio       cesionesrea.nversio%TYPE;   -- BUG 0025803 NUMBER(2);
      vimpres        liqresreaaux.itramo%TYPE := 0;   -- BUG 0025803 NUMBER(14, 2) := 0;
      -- Importe de la reserva de un siniestro a una fecha dada.
      w_param        NUMBER(1);
	  -- INICIO INFORCOL 18-11-2019
      w_creaseg      NUMBER;
	  -- FIN INFORCOL 18-11-2019
      vitotal_pro    liqresreaaux.itotal%TYPE := 0;   -- BUG 0025803  NUMBER(15, 2) := 0;
      vpcesion_pro   cesionesrea.pcesion%TYPE := 0;   -- BUG 0025803  NUMBER(8, 5) := 0;
      vicesion_pro   cesionesrea.icapces%TYPE := 0;   -- BUG 0025803  NUMBER(15, 2) := 0;
      ppropio_pro    liqresreaaux.ppropio%TYPE := 0;   -- BUG 0025803  NUMBER(8, 5) := 0;
      ipropio_pro    liqresreaaux.ipropio%TYPE := 0;   -- BUG 0025803  NUMBER(15, 2) := 0;
      vicompa_pro    liqresreaaux.icompan%TYPE := 0;   -- BUG 0025803  NUMBER(15, 2) := 0;
      vplocpro       NUMBER;
      vversiopro     liqresreaaux.nversio%TYPE;   -- BUG 0025803  NUMBER(2);

-- *********************************************
-- Declaracion de cursores
-- *********************************************
      CURSOR c_liqres(pcempres IN NUMBER, pffin IN DATE) IS
         -- Bug 9685 - APD - 27/04/2009 - en lugar de coger la actividad de la tabla seguros, llamar a la funci?n pac_seguros.ff_get_actividad
         -- BUG 11595 - 04/11/2009 - APD - Adaptaci?n al nuevo m?dulo de siniestros
         SELECT   TO_CHAR(si.nsinies) nsinies, si.fsinies fsinies, si.sseguro sseguro,
                  si.nriesgo nriesgo, s.npoliza npoliza, s.cobjase, s.cramo, s.cmodali,
                  s.ctipseg, s.ccolect,
                  pac_seguros.ff_get_actividad(s.sseguro, si.nriesgo) cactivi,
                  NVL(NVL(s.fcaranu, s.fanulac), s.fvencim) fvencim, s.fefecto fefecto,
                  si.fnotifi, s.sproduc
             FROM seguros s, siniestros si
            WHERE s.sseguro = si.sseguro
              AND s.cempres = pcempres
              AND s.ctiprea <> 2
              AND si.fsinies <(pffin + 1)
              AND si.fnotifi <(pffin + 1)
              AND(si.cestsin IN(0, 4)   -- 14933 AVT 03-06-2010
                  OR(si.cestsin = 1
                     AND si.festsin >=(pffin + 1)))
              AND NVL(pac_parametros.f_parempresa_n(s.cempres, 'MODULO_SINI'), 0) = 0
         UNION
         SELECT   si.nsinies nsinies, si.fsinies fsinies, si.sseguro sseguro,
                  si.nriesgo nriesgo, s.npoliza npoliza, s.cobjase, s.cramo, s.cmodali,
                  s.ctipseg, s.ccolect,
                  pac_seguros.ff_get_actividad(s.sseguro, si.nriesgo) cactivi,
                  NVL(NVL(s.fcaranu, s.fanulac), s.fvencim) fvencim, s.fefecto fefecto,
                  si.fnotifi, s.sproduc
             FROM seguros s, sin_siniestro si, sin_movsiniestro m
            WHERE s.sseguro = si.sseguro
              AND si.nsinies = m.nsinies
              AND m.nmovsin = (SELECT MAX(nmovsin)
                                 FROM sin_movsiniestro
                                WHERE nsinies = m.nsinies
                                  AND festsin <= pffin)
              -- 14933 AVT 03-06-2010
              AND s.cempres = pcempres
              AND s.ctiprea <> 2
              AND si.fsinies <(pffin + 1)
              AND si.fnotifi <(pffin + 1)
              AND m.cestsin IN(0, 4)   -- 14933 AVT 03-06-2010
              --AND(m.cestsin = 0
              AND NVL(pac_parametros.f_parempresa_n(s.cempres, 'MODULO_SINI'), 0) = 1
         ORDER BY nsinies;

      -- Bug 9685 - APD - 27/04/2009 - Fin
      CURSOR c_valor(pfsinies_c1 IN VARCHAR2)   --NUMBER) AVT
                                             IS
         -- BUG 11595 - 04/11/2009 - APD - Adaptaci?n al nuevo m?dulo de siniestros
		 -- INICIO INFORCOL 18-11-2019
          /*SELECT UNIQUE cgarant
                  FROM valorasini
                 WHERE nsinies = pfsinies_c1
                   AND NVL(pac_parametros.f_parempresa_n(pcempres, 'MODULO_SINI'), 0) = 0
                   AND cgarant IS NOT NULL
         -- 22237 AVT 15/05/2012 les despeses no es reasseguren
         UNION*/ -- FIN INFORCOL 18-11-2019
         SELECT UNIQUE cgarant
                  FROM sin_tramita_reserva
                 WHERE nsinies = pfsinies_c1
                   AND NVL(pac_parametros.f_parempresa_n(pcempres, 'MODULO_SINI'), 0) = 1
                   AND cgarant IS NOT NULL;

      -- 22237 AVT 15/05/2012 les despeses no es reasseguren

      --        and  cgarant <> 9998;         -- La garantia 9998 no se considera...
      CURSOR c_tramo(
         sseguro_c1 IN NUMBER,
         pfsinies_c1 IN DATE,
         pnriesgo_c1 IN NUMBER,
         pcgarant_c1 IN NUMBER,
         param_c1 IN NUMBER) IS
         SELECT scontra, nversio, ctramo, sfacult, pcesion, sseguro
           FROM cesionesrea
          WHERE sseguro = sseguro_c1
            AND cgenera IN(1, 3, 4, 5, 9, 40)
            AND nriesgo = pnriesgo_c1
            AND((param_c1 = 1
                 AND cgarant IS NOT NULL
                 AND cgarant = pcgarant_c1)
                OR(param_c1 = 2
                   AND cgarant IS NULL)
                OR(param_c1 = 3
                   AND(pcgarant_c1 = 9999
                       OR pcgarant_c1 = 9998)))
            AND fefecto <= pfsinies_c1
            AND fvencim > pfsinies_c1
            AND(fregula IS NULL
                OR fregula > pfsinies_c1)
            AND(fanulac IS NULL
                OR fanulac > pfsinies_c1)
            AND ctramo > 0
            AND ctramo < 6;

      v_cmultimon    parempresas.nvalpar%TYPE
                              := NVL(pac_parametros.f_parempresa_n(pcempres, 'MULTIMONEDA'), 0);
      v_cmoncontab   parempresas.nvalpar%TYPE
                                     := pac_parametros.f_parempresa_n(pcempres, 'MONEDACONTAB');
      v_itasa        eco_tipocambio.itasa%TYPE;
      v_fcambio      DATE;
      v_error        axis_literales.slitera%TYPE;

      --          ORDER BY CTRAMO;
      CURSOR c_companias(
         pscontra_c1 IN NUMBER,
         pnversio_c1 IN NUMBER,
         pctramo_c2 IN NUMBER,
         psseguro_c2 IN NUMBER,
         pfsinies_c1 IN DATE) IS
         SELECT ccompani, pcesion
           FROM cuadroces
          WHERE pctramo_c2 <> 5
            AND scontra = pscontra_c1
            AND nversio = pnversio_c1
            AND ctramo = pctramo_c2
         UNION
         SELECT cc.ccompani, cc.pcesion
           FROM cuacesfac cc, cuafacul c
          WHERE pctramo_c2 = 5
            AND c.sseguro = psseguro_c2
            AND cc.sfacult = c.sfacult
            AND c.finicuf <= pfsinies_c1
            AND(c.ffincuf > pfsinies_c1
                OR ffincuf IS NULL);

-- *************************************************************************
      FUNCTION buscar_importe_reserva(
         pnsinies IN VARCHAR2,
         pfin IN DATE,
         pireser IN OUT NUMBER,
         pcgarant IN NUMBER,
         pexperr IN OUT VARCHAR2)
         RETURN NUMBER IS
      /* ***************************************************************************************************************************
          Funcion que devuelve importe de la reserva del siniestros a una fecha determinada
       **************************************************************************************************************************** */
      BEGIN
         pireser := 0;
	 -- INI -IAXIS-13133 -27/04/2020. Se adiciona el ptipo=2
         error := f_provisiogar(pnsinies, pcgarant, pireser, pfin,2);
	 -- FIN -IAXIS-13133 -27/04/2020.

         IF error <> 0 THEN
            pexperr := pexperr || ' ' || pnsinies || SQLERRM || TO_CHAR(SQLCODE);
         END IF;

         RETURN(error);
      EXCEPTION
         WHEN OTHERS THEN
            error := SQLCODE;
            RETURN(error);
      END buscar_importe_reserva;

      -- *********************************** FUNCION DE INSERTAR EN LA TABLA TEMPORAL **************************
      FUNCTION insertar_tabla_liqresreaaux(
         pcempres IN NUMBER,
         pffin IN DATE,
         pnsinies IN VARCHAR2,
         pscontra IN NUMBER,
         pnversio IN NUMBER,
         pctramo IN NUMBER,
         pptramo IN NUMBER,
         pitramo IN NUMBER,
         pnpoliza IN NUMBER,
         pfvencim IN DATE,
         pccompani IN VARCHAR2,
         ppcompan IN NUMBER,
         pitotal IN NUMBER,
         psproces IN NUMBER,
         psseguro IN NUMBER,
         pcgarant IN NUMBER,
         pfefecto IN DATE,
         pfnotifi IN DATE,
         pexperr IN OUT VARCHAR2)
         RETURN NUMBER IS
      BEGIN
         -- BUG 21102/107455 - 15/02/2012 - JMP - Contravalores tabla LIQRESREAAUX
         IF v_cmultimon = 1 THEN
            --INI BUG 13164 22/05/2020 MPC Se extrae detalle analizado de tabla LIQRESREAAUX
            v_error := pac_oper_monedas.f_datos_contraval(psseguro, NULL, NULL, pffin, 3,
                                                          v_itasa, v_fcambio);
            --
            /*v_error := pac_oper_monedas.f_datos_contraval(NULL, NULL, pscontra, pffin, 3,
                                                          v_itasa, v_fcambio);*/
            --FIN BUG 13164 22/05/2020 MPC Se extrae detalle analizado de tabla LIQRESREAAUX
            IF v_error <> 0 THEN
               RETURN v_error;
            END IF;
         END IF;

         -- FIN BUG 21102/107455 - 15/02/2012 - JMP - Contravalores tabla LIQRESREAAUX

         -- BUG 0038439 - FAL - 19/11/2015 - round a moneda producto
         SELECT pac_monedas.f_moneda_producto(sproduc)
           INTO v_cmonpol
           FROM seguros
          WHERE sseguro = psseguro;

         -- FI BUG 0038439
         INSERT INTO liqresreaaux
                     (cempres, fcierre, nsinies, scontra, nversio, ctramo, ptramo,
                      itramo, npoliza, fvencim, cramo, ctipram,
                      ccompani, nanyo, tsitrie, fsin, pcompan, tnombre,
                      itotal, icompan, sproces,
                      sseguro, cgarant, fefecto, fnotifi,
                      itramo_moncon,
                      itotal_moncon,
                      icompan_moncon,
                      fcambio)
              VALUES (pcempres, pffin, pnsinies, pscontra, pnversio, pctramo, pptramo,
                      f_round(pitramo, v_cmonpol), pnpoliza, pfvencim, vramo, vtipram,
                      pccompani, vany, vsitrie, vfsin, ppcompan, vnombre,
                      f_round(pitotal, v_cmonpol), f_round(vicompa, v_cmonpol), psproces,
                      psseguro,   -- BUG 0038439 - FAL - 19/11/2015 - round a moneda producto
                               pcgarant, pfefecto, pfnotifi,
                      f_round(pitramo * v_itasa, v_cmoncontab),
                      f_round(pitotal * v_itasa, v_cmoncontab),
                      f_round(vicompa * v_itasa, v_cmoncontab),
                      DECODE(v_cmultimon, 0, NULL, NVL(v_fcambio, pffin)));

         RETURN(0);
      EXCEPTION
         WHEN OTHERS THEN
            RETURN(107516);   -- Error al inserta en la tabla LIQRESREAAUX
      END insertar_tabla_liqresreaaux;

-- ********************************************************************************************************************************************
-- *********************************** FUNCION DE MODIFICA EL % E IMPORTE PROPIO  **************************
      FUNCTION modificar_propios(
         pnsinies IN VARCHAR2,
         pscontra IN NUMBER,
         pnversio IN NUMBER,
         psproces IN NUMBER,
         pcgarant IN NUMBER,   --KBR 17/04/2014
         pexperr IN OUT VARCHAR2,         --BUG 13164 22/05/2020 MPC Se extrae detalle analizado de tabla LIQRESREAAUX
         psseguro IN NUMBER DEFAULT NULL) --BUG 13164 22/05/2020 MPC Se extrae detalle analizado de tabla LIQRESREAAUX
         RETURN NUMBER IS
         vporcen        NUMBER(8, 4);
         vimporte       NUMBER(14, 2);
      BEGIN
         -- BUG 21102/107455 - 15/02/2012 - JMP - Contravalores tabla LIQRESREAAUX
         IF v_cmultimon = 1 THEN
            SELECT DISTINCT fcambio
                       INTO v_fcambio
                       FROM liqresreaaux
                      WHERE nsinies = pnsinies
                        AND scontra = pscontra
                        AND nversio = pnversio
                        AND sproces = psproces
                        AND cgarant = pcgarant;   --KBR 17/04/2014

            IF v_fcambio IS NULL THEN
               RETURN 9902592;
            -- No se ha encontrado el tipo de cambio entre monedas
            END IF;
            --
            --INI BUG 13164 22/05/2020 MPC Se extrae detalle analizado de tabla LIQRESREAAUX
            v_error := pac_oper_monedas.f_datos_contraval(psseguro, NULL, NULL, v_fcambio, 3,
                                                          v_itasa, v_fcambio);
            /*v_error := pac_oper_monedas.f_datos_contraval(NULL, NULL, pscontra, v_fcambio, 3,
                                                          v_itasa, v_fcambio);*/
            --FIN BUG 13164 22/05/2020 MPC Se extrae detalle analizado de tabla LIQRESREAAUX
            IF v_error <> 0 THEN
               RETURN v_error;
            END IF;
         END IF;

         -- BUG 0038439 - FAL - 19/11/2015 - round a moneda producto
         SELECT pac_monedas.f_moneda_producto(s.sproduc)
           INTO v_cmonpol
           FROM sin_siniestro t, seguros s
          WHERE t.nsinies = pnsinies
            AND t.sseguro = s.sseguro;

         -- FI BUG 0038439

         --KBR 17/04/2014
         UPDATE liqresreaaux
            SET ppropio = 100 - ptramo,
                ipropio = f_round((itotal *(100 - ptramo)) / 100, v_cmonpol),   -- BUG 0038439 - FAL - Round a la moneda producto
                ipropio_moncon = f_round(((itotal *(100 - ptramo)) / 100) * v_itasa,
                                         v_cmoncontab)
          WHERE nsinies = pnsinies
            AND scontra = pscontra
            AND nversio = pnversio
            AND sproces = psproces
            AND cgarant = pcgarant;

         RETURN(0);
      EXCEPTION
         WHEN OTHERS THEN
            pexperr := pnsinies || ' ' || pscontra || ' ' || pnversio || ' ' || pcgarant;
            RETURN(107519);   -- Error al modificar en la tabla LIQRESREAAUX
      END modificar_propios;

-- **********************************************************************************************
-- GRABAR INCIDENCIAS DEL LISTADO
-- **********************************************************************************************
      PROCEDURE grabar_incidencia(
         pcempres IN NUMBER,
         pffin IN DATE,
         pnsinies IN VARCHAR2,
         pscontra IN NUMBER,
         pnversio IN NUMBER,
         pctramo IN NUMBER,
         pptramo IN NUMBER,
         pitramo IN NUMBER,
         pnpoliza IN NUMBER,
         pfvencim IN DATE,
         pccompani IN NUMBER,
         ppcompan IN NUMBER,
         pitotal IN NUMBER,
         psproces IN NUMBER,
         psseguro IN NUMBER,
         pexperr IN OUT VARCHAR2) IS
      BEGIN
         -- BUG 0038439 - FAL - 19/11/2015 - round a moneda producto
         SELECT pac_monedas.f_moneda_producto(sproduc)
           INTO v_cmonpol
           FROM seguros
          WHERE sseguro = psseguro;

         -- FI BUG 0038439
         INSERT INTO liqresreaaux_err
                     (cempres, fcierre, nsinies, scontra, nversio, ctramo, ptramo,
                      itramo, npoliza, fvencim, cramo, ccompani, nanyo,
                      tsitrie, fsin, pcompan, tnombre, itotal,
                      icompan, sproces, sseguro, incidenc)
              VALUES (pcempres, pffin, pnsinies, pscontra, pnversio, pctramo, pptramo,
                      f_round(pitramo, v_cmonpol), pnpoliza, pfvencim, vramo, pccompani, vany,
                      vsitrie, vfsin, ppcompan, vnombre, f_round(pitotal, v_cmonpol),
                      f_round(vicompa, v_cmonpol), psproces, psseguro, pexperr);   -- BUG 0038439 - FAL - 19/11/2015 - round a moneda producto
      EXCEPTION
         WHEN OTHERS THEN
            pexperr := 'error grabar incidencia';
      END grabar_incidencia;
-- ************************************************************************************
--                     CUERPO DE LA FUNCION PRINCIPAL
-- ***********************************************************************************
   BEGIN
       p_Control_Error ('PAC_REASERGURO_REC','F_LIQUIDARESREAS','PASO 7777_1, pffin:'||pffin||' '||DBMS_UTILITY.format_call_stack);
      FOR r_liqres IN c_liqres(pcempres, pffin) LOOP
         p_Control_Error ('PAC_REASERGURO_REC','F_LIQUIDARESREAS','PASO 7777_2,
         r_liqres.nsinies:'||r_liqres.nsinies||' pffin:'||pffin);
         -- Mantis 11845.12/2009.NMM.CRE - Ajustar reasseguran?a d'estalvi .i.
         IF pac_cesionesrea.producte_reassegurable(r_liqres.sproduc) = 1 THEN
            vporrea := 0;
            vcpceco := 0;
            vramo := r_liqres.cramo;

            -- BUG: 12967 03-02-2010 AVT es prescindeix d'una s?rie de funcions
            -- error := nombre_tomador(r_liqres.sseguro, pexperr);
            --IF error = 0 THEN
            -- BUG: 12967 03-02-2010 AVT es prescindeix d'una s?rie de funcions
            -- error := situacion_riesgo(r_liqres.nriesgo, r_liqres.sseguro, r_liqres.cobjase,
            --                          pexperr);

            --IF error = 0 THEN
            FOR r_valor IN c_valor(r_liqres.nsinies) LOOP
               p_Control_Error ('PAC_REASERGURO_REC','F_LIQUIDARESREAS','PASO 7777_4_111, r_liqres.nsinies:'||
               r_liqres.nsinies);
               -- BUG 11100 - 16/09/2009 - FAL - Crida a la pac_cesionesrea.f_gar_rea per si garantia reasegurable
               /* INFORCOL BEGIN
               error := pac_cesionesrea.f_gar_rea(r_liqres.cramo, r_liqres.cmodali,
                                                  r_liqres.ctipseg, r_liqres.ccolect,
                                                  r_liqres.cactivi, r_valor.cgarant,
                                                  w_creaseg);
               EXCEPTION
                 WHEN OTHERS THEN
                 p_Control_Error ('PAC_REASERGURO_REC','F_LIQUIDARESREAS','PASO 7777_20, r_liqres.nsinies:'||
               r_liqres.nsinies);
                  w_creaseg := 0;
               END;*/



        BEGIN
        SELECT creaseg -- es reassegura...
           INTO w_creaseg
           FROM garanpro
          WHERE cramo = r_liqres.cramo
            AND cmodali = r_liqres.cmodali
            AND ctipseg = r_liqres.ctipseg
            AND ccolect = r_liqres.ccolect
            AND cactivi = r_liqres.cactivi
            AND cgarant = r_valor.cgarant;
      EXCEPTION
         WHEN OTHERS --no_data_found
           THEN
            BEGIN
               --v_errlin := 5050;
               SELECT creaseg
                 INTO w_creaseg
                 FROM garanpro
                WHERE cramo = r_liqres.cramo
                  AND cmodali = r_liqres.cmodali
                  AND ctipseg = r_liqres.ctipseg
                  AND ccolect = r_liqres.ccolect
                  AND cactivi = 0
                  AND cgarant = r_valor.cgarant;
            EXCEPTION
               WHEN OTHERS THEN --no_data_found THEN
                  --p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM,
                  --            v_errpar);
               w_creaseg := 0;
             END;
           END;
               --w_creaseg := 1;


               --FI BUG 11100 - 16/09/2009 ? FAL
               p_Control_Error ('PAC_REASERGURO_REC','F_LIQUIDARESREAS','PASO 7777_5, r_liqres.nsinies:'||
               r_liqres.nsinies||' error:'||error||' w_creaseg:'||w_creaseg);
               -- INICIO INFORCOL 18-11-2019
               IF NVL(w_creaseg,0) > 0 THEN
			   -- FIN INFORCOL 18-11-2019
                  vfsin := r_liqres.fsinies;
                  vporrea := 0;
                  vimpres := 0;
                  p_Control_Error ('PAC_REASERGURO_REC','F_LIQUIDARESREAS','PASO 7777_5_1, r_liqres.nsinies:'||
                  r_liqres.nsinies||' pffin:'||pffin||' r_valor.cgarant:'||r_valor.cgarant);
                  error := buscar_importe_reserva(r_liqres.nsinies, pffin, vimpres,
                                                  r_valor.cgarant, pexperr);

               p_Control_Error ('PAC_REASERGURO_REC','F_LIQUIDARESREAS','PASO 7777_6, r_liqres.nsinies:'||
               r_liqres.nsinies||' error:'||error||' w_creaseg:'||w_creaseg||' vimpres:'||vimpres||
               ' pexperr:'||pexperr);

                  IF error = 0 THEN
                     --INI BUG 13164 22/05/2020 MPC Se adiciona codigo para llenado de tabla de detalle
                     v_cesdet :=   NULL;
                     --
                     v_cesdet.cempres  := pcempres;
                     v_cesdet.sproduc  := r_liqres.sproduc;
                     v_cesdet.cramo    := r_liqres.cramo;
                     v_cesdet.npoliza  := r_liqres.npoliza;
                     v_cesdet.sseguro  := r_liqres.sseguro;
                     v_cesdet.nsinies  := r_liqres.nsinies;
                     v_cesdet.fefecto  := r_liqres.fefecto;
                     v_cesdet.fsinies  := r_liqres.fsinies;
                     v_cesdet.cgarant  := r_valor.cgarant;
                     v_cesdet.sproces  := psproces;
                     v_cesdet.fcierre  := pffin;
                     v_cesdet.isalres  := vimpres;
                     v_cesdet.ctipram  := vtipram;
                     --
                     IF vimpres = 0 
                     THEN
                        --
                        error := f_ext_sintramitareservadet(psproces,pcempres,pffin,r_liqres.nsinies,1);
                        --
                     END IF;
                     --
                     --FIN BUG 13164 22/05/2020 MPC Se adiciona codigo para llenado de tabla de detalle
                     IF vimpres <> 0 THEN   -- no se tratan las reservas a 0...
                        w_param := 1;

                        WHILE w_param < 4 LOOP
                           vscontra := NULL;
                           p_Control_Error ('PAC_REASERGURO_REC','F_LIQUIDARESREAS','PASO 7777_7, r_liqres.nsinies:'||
                           r_liqres.nsinies||' error:'||error||' w_creaseg:'||w_creaseg||' vimpres:'||vimpres||
                           ' r_liqres.sseguro:'||r_liqres.sseguro||' r_valor.cgarant:'||r_valor.cgarant||
                           ' w_param:'||w_param );
                           FOR r_tramo IN c_tramo(r_liqres.sseguro, r_liqres.fsinies,
                                                  r_liqres.nriesgo, r_valor.cgarant, w_param) LOOP
                              w_param := 5;

                           p_Control_Error ('PAC_REASERGURO_REC','F_LIQUIDARESREAS','PASO 7777_8, r_liqres.nsinies:'||
                           r_liqres.nsinies||' error:'||error||' w_creaseg:'||w_creaseg||' vimpres:'||vimpres||
                           ' r_liqres.sseguro:'||r_liqres.sseguro||' r_valor.cgarant:'||r_valor.cgarant||
                           ' w_param:'||w_param );
                              IF vscontra IS NULL
                                 OR(vscontra IS NOT NULL
                                    AND r_tramo.scontra = vscontra) THEN
                                    p_Control_Error ('PAC_REASERGURO_REC','F_LIQUIDARESREAS','PASO 7777_9, r_liqres.nsinies:'||
                           r_liqres.nsinies||' error:'||error||' w_creaseg:'||w_creaseg||' vimpres:'||vimpres||
                           ' r_liqres.sseguro:'||r_liqres.sseguro||' r_valor.cgarant:'||r_valor.cgarant||
                           ' w_param:'||w_param );
                                 vscontra := r_tramo.scontra;
                                 vnversio := r_tramo.nversio;
                                 vany := 0;
                                 error := anyo_contrato(r_tramo.scontra, r_tramo.nversio,
                                                        r_tramo.sfacult, pexperr);

                                 IF error = 0 THEN
                                    error := buscar_tipocon(r_tramo.scontra, pexperr);

                                    IF error = 0 THEN
                                       vicesion := (vimpres * r_tramo.pcesion) / 100;
                                       vpcesion := r_tramo.pcesion;

                                       IF r_tramo.ctramo = 1 THEN
                                          error :=
                                             proceso_tramo_1(r_tramo.scontra, r_tramo.nversio,
                                                             vicesion, vpcesion, vnsegcon,
                                                             vversiopro);

                                          IF error != 0 THEN
                                             pexperr :=
                                                r_tramo.scontra || ' ' || r_tramo.nversio
                                                || ' ' || r_liqres.nsinies;
                                          END IF;
                                       END IF;

                                       IF error = 0 THEN
                                          vporrea := vporrea + vpcesion;
                                          error := importe_total(vicesion, vpcesion);

                                          IF error != 0 THEN
                                             pexperr :=
                                                r_tramo.scontra || ' ' || r_tramo.nversio
                                                || ' ' || r_liqres.nsinies;
                                          END IF;
                           p_Control_Error ('PAC_REASERGURO_REC','F_LIQUIDARESREAS','PASO 7777_10, r_liqres.nsinies:'||
                           r_liqres.nsinies||' error:'||error||' w_creaseg:'||w_creaseg||' vimpres:'||vimpres||
                           ' r_liqres.sseguro:'||r_liqres.sseguro||' r_valor.cgarant:'||r_valor.cgarant||
                           ' w_param:'||w_param );

                                          FOR r_companias IN c_companias(r_tramo.scontra,
                                                                         r_tramo.nversio,
                                                                         r_tramo.ctramo,
                                                                         r_tramo.sseguro,
                                                                         r_liqres.fsinies) LOOP
                                             /* Cambiamos el % del tramo 1 */
                                            p_Control_Error ('PAC_REASERGURO_REC','F_LIQUIDARESREAS','PASO 7777_11, r_liqres.nsinies:'||
                                            r_liqres.nsinies||' error:'||error||' w_creaseg:'||w_creaseg||' vimpres:'||vimpres||
                                            ' r_liqres.sseguro:'||r_liqres.sseguro||' r_valor.cgarant:'||r_valor.cgarant||
                                            ' w_param:'||w_param );
                                             IF r_tramo.ctramo = 1 THEN
                                                -- buscamos que representa el tanto por ciento de la compa??a
                                                -- respecto al tanto por ciento de cesi?n de este tramo.
                                                -- vcescomp := r_companias.pcesion * 100 / NVL(vpcesion,0);
                                                vcescomp :=
                                                   (r_companias.pcesion * 100)
												   -- INICIO INFORCOL 18-11-2019
                                                   /(100 - NVL(vplocali,0));
												   -- FIN INFORCOL 18-11-2019
                                             ELSE
                                                vcescomp := r_companias.pcesion;
                                             END IF;

                                             IF vtipram = 3 THEN   -- facultativo puro...
                                                importe_compania(vitotal, vcescomp, vicompa);
                                             -- 14833 AVT 03-06-2010
                                             ELSE
                                                importe_compania(vicesion, vcescomp, vicompa);
                                             -- 14833 AVT 03-06-2010
                                             END IF;
                                             --INI BUG 13164 22/05/2020 MPC Se adiciona codigo para llenado de tabla de detalle
                                             v_cesdet.scontra       := r_tramo.scontra;
                                             v_cesdet.nversio       := r_tramo.nversio;
                                             v_cesdet.nanyo         := vany;
                                             v_cesdet.ctramo        := r_tramo.ctramo;
                                             v_cesdet.pcedido_total := r_tramo.pcesion;
                                             v_cesdet.ccompani      := r_companias.ccompani;
                                             v_cesdet.pcedido_cia   := r_companias.pcesion;                      
                                             --
                                             p_ins_liqresreaauxdet;
                                             --
                                             IF pcmodo != 3 
                                             THEN
                                             --FIN BUG 13164 22/05/2020 MPC Se adiciona codigo para llenado de tabla de detalle
                                             p_Control_Error ('PAC_REASERGURO_REC','F_LIQUIDARESREAS','PASO 7777_12, r_liqres.nsinies:'||
                          r_liqres.nsinies||' error:'||error||' w_creaseg:'||w_creaseg||' vimpres:'||vimpres||
                           ' r_liqres.sseguro:'||r_liqres.sseguro||' r_valor.cgarant:'||r_valor.cgarant||
                           ' w_param:'||w_param );
                                             error :=
                                                insertar_tabla_liqresreaaux
                                                                         (pcempres, pffin,
                                                                          r_liqres.nsinies,
                                                                          r_tramo.scontra,
                                                                          r_tramo.nversio,
                                                                          r_tramo.ctramo,
                                                                          vpcesion, vicesion,
                                                                          r_liqres.npoliza,
                                                                          r_liqres.fvencim,
                                                                          r_companias.ccompani,
                                                                          r_companias.pcesion,
                                                                          vitotal, psproces,
                                                                          r_liqres.sseguro,
                                                                          r_valor.cgarant,
                                                                          r_liqres.fefecto,
                                                                          r_liqres.fnotifi,
                                                                          pexperr);

                                             IF error != 0 THEN
                                                pexperr := error || ' : ' || pexperr;
                                                grabar_incidencia(pcempres, pffin,
                                                                  r_liqres.nsinies,
                                                                  r_tramo.scontra,
                                                                  r_tramo.nversio,
                                                                  r_tramo.ctramo, vpcesion,
                                                                  vicesion, r_liqres.npoliza,
                                                                  r_liqres.fvencim,
                                                                  r_companias.ccompani,
                                                                  r_companias.pcesion,
                                                                  vitotal, psproces,
                                                                  r_liqres.sseguro, pexperr);
                                                error := 0;
                                             END IF;
                                             --INI BUG 13164 22/05/2020 MPC Se adiciona codigo para llenado de tabla de detalle
                                             END IF;
                                             --FIN BUG 13164 22/05/2020 MPC Se adiciona codigo para llenado de tabla de detalle
                                             COMMIT;
                                          END LOOP;
                                          --INI BUG 13164 22/05/2020 MPC Se adiciona codigo para llenado de tabla de detalle
                                          IF pcmodo != 3 
                                          THEN
                                          --FIN BUG 13164 22/05/2020 MPC Se adiciona codigo para llenado de tabla de detalle
                                          IF r_tramo.ctramo = 1
                                             AND vnsegcon IS NOT NULL THEN
                                             vitotal_pro :=
                                                (vimpres * r_tramo.pcesion / 100) * vplocali
                                                / 100;
                                             vpcesion_pro :=(100 - vplocpro);
                                             vicesion_pro :=
                                                            vitotal_pro *(100 - vplocpro)
                                                            / 100;
                                             ppropio_pro := vplocpro;
                                             ipropio_pro := vitotal_pro * vplocpro / 100;

                                             p_Control_Error ('PAC_REASERGURO_REC','F_LIQUIDARESREAS','PASO 7777_13, r_liqres.nsinies:'||
                                             r_liqres.nsinies||' error:'||error||' w_creaseg:'||w_creaseg||' vimpres:'||vimpres||
                                             ' r_liqres.sseguro:'||r_liqres.sseguro||' r_valor.cgarant:'||r_valor.cgarant||
                                             ' w_param:'||w_param );
                                             FOR r_companias IN c_companias(vnsegcon,
                                                                            vversiopro, 1,
                                                                            r_liqres.sseguro,
                                                                            r_liqres.fsinies) LOOP
                                                vicompa_pro :=
                                                       vitotal_pro * r_companias.pcesion / 100;

                                                BEGIN
                                                   -- BUG 21102/107455 - 15/02/2012 - JMP - Contravalores tabla LIQRESREAAUX
                                                   IF v_cmultimon = 1 THEN
                                                     --INI BUG 13164 22/05/2020 MPC Se extrae detalle analizado de tabla LIQRESREAAUX
                                                     v_error :=
                                                         pac_oper_monedas.f_datos_contraval
                                                                                    (r_liqres.sseguro,
                                                                                     NULL,
                                                                                     NULL,
                                                                                     pffin, 3,
                                                                                     v_itasa,
                                                                                     v_fcambio);
                                                      /*v_error :=
                                                         pac_oper_monedas.f_datos_contraval
                                                                                    (NULL,
                                                                                     NULL,
                                                                                     vnsegcon,
                                                                                     pffin, 3,
                                                                                     v_itasa,
                                                                                     v_fcambio);*/
                                                      --FIN BUG 13164 22/05/2020 MPC Se extrae detalle analizado de tabla LIQRESREAAUX
                                                      IF v_error <> 0 THEN
                                                         pexperr :=
                                                            'error insert' || r_tramo.scontra
                                                            || ' ' || r_tramo.nversio || ' '
                                                            || r_liqres.nsinies || ': '
                                                            || v_error;
                                                      END IF;
                                                   END IF;

                                                   -- BUG 0038439 - FAL - 19/11/2015 - round a moneda producto
                                                   SELECT pac_monedas.f_moneda_producto
                                                                                       (sproduc)
                                                     INTO v_cmonpol
                                                     FROM seguros
                                                    WHERE sseguro = r_liqres.sseguro;

                                                   -- FI BUG 0038439

                                                   -- FIN BUG 21102/107455 - 15/02/2012 - JMP - Contravalores tabla LIQRESREAAUX
                                                   p_Control_Error ('PAC_REASERGURO_REC','F_LIQUIDARESREAS','PASO 7777_14, r_liqres.nsinies:'||
                                                   r_liqres.nsinies||' error:'||error||' w_creaseg:'||w_creaseg||' vimpres:'||vimpres||
                                                   ' r_liqres.sseguro:'||r_liqres.sseguro||' r_valor.cgarant:'||r_valor.cgarant||
                                                   ' w_param:'||w_param );
                                                   INSERT INTO liqresreaaux
                                                               (cempres, fcierre,
                                                                nsinies,
                                                                sseguro, scontra,
                                                                nversio, ctramo,
                                                                ccompani, cramo,
                                                                ctipram, npoliza,
                                                                fvencim, nanyo,
                                                                tsitrie, fsin, tnombre,
                                                                itotal,
                                                                ppropio,
                                                                ipropio,
                                                                ptramo,
                                                                itramo,
                                                                pcompan,
                                                                icompan,
                                                                sproces, cgarant,
                                                                fefecto,
                                                                fnotifi,
                                                                itotal_moncon,
                                                                ipropio_moncon,
                                                                itramo_moncon,
                                                                icompan_moncon,
                                                                fcambio)
                                                        VALUES (pcempres, pffin,
                                                                r_liqres.nsinies,
                                                                r_liqres.sseguro, vnsegcon,
                                                                vversiopro, r_tramo.ctramo,
                                                                r_companias.ccompani, vramo,
                                                                vtipram, r_liqres.npoliza,
                                                                r_liqres.fvencim, vany,
                                                                vsitrie, vfsin, vnombre,
                                                                f_round(vitotal_pro, v_cmonpol),
                                                                ppropio_pro,
                                                                f_round(ipropio_pro, v_cmonpol),
                                                                vpcesion_pro,
                                                                f_round(vicesion_pro,
                                                                        v_cmonpol),
                                                                r_companias.pcesion,
                                                                f_round(vicompa_pro, v_cmonpol),
                                                                psproces,   -- BUG 0038439 - FAL - 19/11/2015 - round a moneda producto
                                                                         r_valor.cgarant,
                                                                r_liqres.fvencim,
                                                                r_liqres.fnotifi,
                                                                f_round(vitotal_pro * v_itasa,
                                                                        v_cmoncontab),
                                                                f_round(ipropio_pro * v_itasa,
                                                                        v_cmoncontab),
                                                                f_round(vicesion_pro * v_itasa,
                                                                        v_cmoncontab),
                                                                f_round(vicompa_pro * v_itasa,
                                                                        v_cmoncontab),
                                                                DECODE(v_cmultimon,
                                                                       0, NULL,
                                                                       NVL(v_fcambio, pffin)));
                                                EXCEPTION
                                                   WHEN OTHERS THEN
                                                      pexperr :=
                                                         'error insert' || r_tramo.scontra
                                                         || ' ' || r_tramo.nversio || ' '
                                                         || r_liqres.nsinies;
                                                END;

                                                --CONF-692 Inicio
                                                /*p_reexpresion(pcempres,
                                                              psproces,
                                                              r_liqres.sseguro,
                                                              vfsin,
                                                              vnsegcon,
                                                              r_companias.ccompani,
                                                              vversiopro,
                                                              r_tramo.ctramo,
                                                              NULL,
                                                              0,
                                                              1,
                                                              6,
                                                              f_round(vicompa_pro, v_cmonpol),
                                                              NULL,
                                                              NULL,
                                                              r_liqres.nsinies,
                                                              v_error);*/
                                                --CONF-692 Fin
                                                COMMIT;
                                             END LOOP;
                                          END IF;
                                          --INI BUG 13164 22/05/2020 MPC Se adiciona codigo para llenado de tabla de detalle
                                          END IF;
                                          --FIN BUG 13164 22/05/2020 MPC Se adiciona codigo para llenado de tabla de detalle
                                       END IF;
                                    END IF;
                                 END IF;

                                 IF error != 0 THEN
                                    pexperr := error || ' : ' || pexperr;
                                    grabar_incidencia(pcempres, pffin, r_liqres.nsinies,
                                                      r_tramo.scontra, r_tramo.nversio,
                                                      r_tramo.ctramo, vpcesion, vicesion,
                                                      r_liqres.npoliza, r_liqres.fvencim, 0,
                                                      0, vitotal, psproces, r_liqres.sseguro,
                                                      pexperr);
                                    error := 0;
                                 END IF;
                              END IF;
                           END LOOP;

                           w_param := w_param + 1;
                        END LOOP;

                        IF w_param >= 5 THEN
                           --KBR 17/04/2014
                           --INI BUG 13164 22/05/2020 MPC Se adiciona codigo para llenado de tabla LIQRESREAAUX
                           error := modificar_propios(r_liqres.nsinies, vscontra, vnversio,
                                                      psproces, r_valor.cgarant, pexperr,r_liqres.sseguro);
                           --FIN BUG 13164 22/05/2020 MPC Se adiciona codigo para llenado de tabla LIQRESREAAUX
                        END IF;
                     END IF;
                  END IF;
               END IF;
               p_Control_Error ('PAC_REASERGURO_REC','F_LIQUIDARESREAS','PASO 7777_16_1, r_liqres.nsinies:'||
               r_liqres.nsinies||' r_liqres.cramo:'||r_liqres.cramo||' r_liqres.cmodali:'||r_liqres.cmodali||
               ' r_liqres.ctipseg:'||r_liqres.ctipseg||' r_liqres.ccolect:'||r_liqres.ccolect||
               ' r_liqres.cactivi:'||r_liqres.cactivi
               );
            END LOOP;   --Fin cvalor: Cursor de garantías

            --END IF; -- BUG: 12967 03-02-2010 AVT es prescindeix d'una s?rie de funcions

            --END IF; -- BUG: 12967 03-02-2010 AVT es prescindeix d'una s?rie de funcions
            IF error != 0 THEN
               pexperr := error || ' : ' || pexperr;
               grabar_incidencia(pcempres, pffin, r_liqres.nsinies, vscontra, vnversio, 0,
                                 vpcesion, vicesion, r_liqres.npoliza, r_liqres.fvencim, 0, 0,
                                 vitotal, psproces, r_liqres.sseguro, pexperr);
            END IF;
         END IF;
         p_Control_Error ('PAC_REASERGURO_REC','F_LIQUIDARESREAS','PASO 7777_17');
      END LOOP;   --Fin liqres: Cursor ppal
      --INI BUG 13164 22/05/2020 MPC Se adiciona codigo para Terminar el llenado de tabla de detalle
      error := f_ext_sintramitareservadet(psproces,pcempres,pffin,NULL,0);
      --FIN BUG 13164 22/05/2020 MPC Se adiciona codigo para Terminar el llenado de tabla de detalle
      RETURN(0);
   EXCEPTION
      WHEN OTHERS THEN
         error := SQLCODE;
         p_Control_Error ('PAC_REASERGURO_REC','F_LIQUIDARESREAS','PASO 7777_18, error:'||error);
         RETURN(error);
   END f_liquidaresreas;

-----------------------------------------------------------
   FUNCTION f_reserves_sini(
      psproces IN NUMBER,
      pcempres IN NUMBER,
      pfcierre IN DATE,
      pcidioma IN NUMBER,
      pcmodo   IN NUMBER DEFAULT 0) --BUG 13164 22/05/2020 MPC Se CMODO = 3 Solo Llena tabla detalle ó CMODO = 0 continua proceso normal 
      RETURN NUMBER IS
-----------------------------------------------------------------
-- C?lcul de reserves de sinistres a carrec dels reasseguradors
-----------------------------------------------------------------
      num_err        NUMBER;
      vexperr        VARCHAR2(120);
      ttexto         VARCHAR2(400);
      vlin           NUMBER := 0;
   BEGIN
      --INI BUG 13164 22/05/2020 MPC Se adiciona limpieza de tabla nueva de detalle
      IF pcmodo != 3 
      THEN
      --
      DELETE FROM liqresreaaux
            WHERE cempres = pcempres
              AND fcierre = pfcierre;

      COMMIT;
      --
      END IF;
      DELETE FROM liqresreaauxdet
            WHERE cempres = pcempres
              AND fcierre = pfcierre;
      --
      COMMIT;
      --      DBMS_OUTPUT.put_line('estmos en reservas de siniestros');
      num_err := f_liquidaresreas(psproces, pcempres, pfcierre, vexperr, pcmodo);
      --
      IF pcmodo = 3 
      THEN
        --
        RETURN 0;
        --
      END IF;
      --FIN BUG 13164 22/05/2020 MPC Se adiciona limpieza de tabla nueva de detalle
      IF vexperr = 'error grabar incidencia' THEN
         ttexto := f_axis_literales(105413, pcidioma);
         -- Se han producido errores
         ttexto := SUBSTR(vexperr || ttexto || ' ' || num_err, 1, 120);
         num_err := f_proceslin(psproces, ttexto, num_err, vlin);
      END IF;

      COMMIT;

      SELECT COUNT(*)
        INTO num_err
        FROM liqresreaaux_err
       WHERE sproces = psproces;

      IF num_err <> 0 THEN
         --Existe error
         ttexto := f_axis_literales(105413, pcidioma);
         -- Se han producido errores
         ttexto := SUBSTR(vexperr || ttexto || ' ' || num_err, 1, 120);
         num_err := f_proceslin(psproces, ttexto, num_err, vlin);
      END IF;

      COMMIT;
      -- BUG 11350 - 05/10/2009 - FAL - Creaci?n f_reamovpagos que realitza el c?lcul de reserves a nivell de pagament per aquells pagos encara pendents
      vexperr := NULL;
      num_err := f_reamovpagos(psproces, pcempres, pfcierre, vexperr);

      IF num_err <> 0 THEN
         --Existe error
         ttexto := f_axis_literales(105413, pcidioma);
         -- Se han producido errores
         ttexto := SUBSTR(vexperr || ttexto || ' ' || num_err, 1, 120);
         num_err := f_proceslin(psproces, ttexto, num_err, vlin);
      END IF;

      -- FI Bug 11350 - 05/10/2009 - FAL
      RETURN 0;
   END f_reserves_sini;

-- ***********************************************************************
   -- BUG 11051 - 07/09/2009 - FAL - Creaci?n p_genera_ces_pago y f_genera_ces_pago para generar cesion de pagos de siniestros
   /*************************************************************************
      Recupera los pagos de siniestros para generar la cesi?n
      param in pcempres   : c?digo empresa
      param in pnsinies   : c?digo siniestro
      param in pnpoliza   : c?digo p?liza
      param in psproces   : c?digo proceso
      param in pcidioma   : c?digo idioma
      param in pfcierre   : fecha cierre
   *************************************************************************/
   PROCEDURE p_genera_ces_pago(
      pcempres IN NUMBER,
      pnsinies IN NUMBER,
      pnpoliza IN NUMBER,
      psproces IN NUMBER,
      pcidioma IN NUMBER,
      pfcierre IN DATE) IS
      CURSOR pagos_sinces(
         pempresa IN NUMBER,
         pnsinies IN NUMBER,
         psseguro IN NUMBER,
         ppol IN NUMBER) IS
         SELECT s.cempres, s.cramo, s.cmodali, s.ctipseg, s.ccolect, s.cactivi, p.*
           FROM pagossinces p, seguros s
          WHERE p.sseguro = s.sseguro
            AND s.cempres = pempresa
            AND(p.nsinies = pnsinies
                OR pnsinies IS NULL)
            AND(p.sseguro = psseguro
                OR psseguro IS NULL)
            AND(s.npoliza = ppol
                OR ppol IS NULL)
            AND p.crevisi = 1;

      wsseguro       NUMBER;
      err            NUMBER := 0;
      pmotiu         NUMBER := 2;
      v_scontra      NUMBER := NULL;
      v_nversio      NUMBER;
      v_ipleno       NUMBER;
      v_icapaci      NUMBER;
      v_cdetces      NUMBER;   -- BUG: 17672 JGR 23/02/2011
      nprolin        NUMBER;
      num_err        NUMBER;
      ltexto         VARCHAR2(200);
   BEGIN
      v_traza := 113;

      IF pnpoliza IS NOT NULL THEN
         BEGIN
            SELECT sseguro
              INTO wsseguro
              FROM seguros
             WHERE npoliza = pnpoliza;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               -- 23261 AVT 20/082012 pòlissa amb certificats
               wsseguro := NULL;
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, 'pac_reaseguro_rec.p_genera_ces_pago', v_traza,
                           'Err SELECT FROM seguros:' || pnpoliza, ' SQLERRM = ' || SQLERRM);
               ltexto := f_axis_literales(111360, pcidioma);
               -- La p?liza no existe
               num_err := f_proceslin(psproces, ltexto, pnpoliza, nprolin);
               err := 1;
         END;
      END IF;

      IF err = 0 THEN
         v_traza := 114;

         FOR reg IN pagos_sinces(pcempres, pnsinies, wsseguro, pnpoliza) LOOP
            err := 0;
            err := f_buscacontrato(reg.sseguro, reg.fsinies, reg.cempres, reg.cgarant,
                                   reg.cramo, reg.cmodali, reg.ctipseg, reg.ccolect,
                                   reg.cactivi, pmotiu, v_scontra, v_nversio, v_ipleno,
                                   v_icapaci, v_cdetces);   -- BUG: 17672 JGR 23/02/2011

            IF err = 0
               AND v_scontra IS NOT NULL THEN
               err := pac_reaseguro_rec.f_genera_ces_pago(reg.nsinies, reg.sidepag,
                                                          reg.cgarant, reg.fefepag,
                                                          reg.isinret, v_scontra, v_nversio,
                                                          psproces, pcidioma, pfcierre);
               v_traza := 115;

               IF err = 0 THEN
                  BEGIN
                     UPDATE pagossinces
                        SET crevisi = 2,
                            frevisi = f_sysdate,
                            cusuari = f_user
                      WHERE sidepag = reg.sidepag;
                  EXCEPTION
                     WHEN OTHERS THEN
                        p_tab_error(f_sysdate, f_user, 'pac_reaseguro_rec.p_genera_ces_pago',
                                    v_traza, 'Err UPDATE pagossinces:' || reg.sidepag,
                                    ' SQLERRM = ' || SQLERRM);
                        ltexto := f_axis_literales(9002133, pcidioma);
                        -- Error al modificar pagossinces
                        num_err := f_proceslin(psproces, ltexto, reg.sseguro, nprolin);
                  END;
               --               ELSE
               --                  ltexto := f_axis_literales(9002134, pcidioma);   -- Error al generar la cesi?n del pago
               --                  num_err := f_proceslin(psproces, ltexto, reg.sseguro, nprolin);
               END IF;

               v_traza := 116;
            ELSE
               ltexto := f_axis_literales(104485, pcidioma);
               -- No se encuentra el contrato
               num_err := f_proceslin(psproces, ltexto, reg.sseguro, nprolin);
            END IF;
         END LOOP;
      END IF;
   END p_genera_ces_pago;

-- **********************************************************************

   /*************************************************************************
      Genera la cesi?n de los pagos de siniestros
      param in pnsinies   : c?digo siniestro
      param in psidepag   : c?digo pago siniestro
      param in pcgarant   : c?digo garantia
      param in pfefepag   : fecha efecto pago
      param in pisinret   : importe siniestro
      param in pscontra   : c?digo contrato
      param in pnversio   : c?digo versi?n
      param in psproces   : c?digo proceso
      param in pcidioma   : c?digo idioma
      param in pfcierre   : fecha cierre
   *************************************************************************/
   FUNCTION f_genera_ces_pago(
      pnsinies IN NUMBER,
      psidepag IN NUMBER,
      pcgarant IN NUMBER,
      pfefepag IN DATE,
      pisinret IN NUMBER,
      pscontra IN NUMBER,
      pnversio IN NUMBER,
      psproces IN NUMBER,
      pcidioma IN NUMBER,
      pfcierre IN DATE)
      RETURN NUMBER IS
-----------------------------------------------------------------
-- Genera cesiones de pagos de siniestros
-----------------------------------------------------------------
      CURSOR c_cessio(p_sidepag IN NUMBER) IS
         SELECT *
           FROM cesionesrea
          WHERE scesrea IN(SELECT MIN(scesrea)
                             FROM cesionesrea
                            WHERE cgarant = pcgarant
                              -- 17059: CRE - REvisi? de errors en Tancament de Nov 2010
                              AND sseguro IN(SELECT sseguro
                                               FROM pagossinces
                                              WHERE sidepag = p_sidepag))
            AND cgenera <> 2;

-- 23618 - AVT - 06/09/2012 es corretgeix perque també funcioni amb cessions agrupades (cgarant = null).
      CURSOR c_cessio_agr(p_sidepag IN NUMBER) IS
         SELECT *
           FROM cesionesrea
          WHERE scesrea IN(SELECT MIN(scesrea)
                             FROM cesionesrea
                            WHERE cgarant IS NULL
                              -- 17059: CRE - REvisi? de errors en Tancament de Nov 2010
                              AND sseguro IN(SELECT sseguro
                                               FROM pagossinces
                                              WHERE sidepag = p_sidepag))
            AND cgenera <> 2;

      v_trams        NUMBER;
      nprolin        NUMBER;
      ltexto         VARCHAR2(200);
      num_err        NUMBER;
      wnumces        NUMBER := 0;
      v_vidaga       NUMBER;
   BEGIN
      --SELECT MAX(ctramo) 14 20/12/2010 JGR 16. 17059: CRE - REvisi? de errors en Tancament de Nov 2010
      SELECT   c.cvidaga, COUNT(ctramo)
-- 14 20/12/2010 JGR 16. 17059: CRE - REvisi? de errors en Tancament de Nov 2010
      INTO     v_vidaga, v_trams
          FROM tramos t, codicontratos c
         WHERE c.scontra = t.scontra
           AND t.scontra = pscontra
           AND t.nversio = pnversio
      GROUP BY c.cvidaga;

      --IF v_trams = 1 THEN 14 20/12/2010 JGR 16. 17059: CRE - REvisi? de errors en Tancament de Nov 2010
      IF v_trams >= 1 THEN
-- 14 20/12/2010 JGR 16. 17059: CRE - REvisi? de errors en Tancament de Nov 2010
         IF NVL(v_vidaga, 2) = 2 THEN
            FOR ces IN c_cessio(psidepag) LOOP
               wnumces := wnumces + 1;

               BEGIN
                  INSERT INTO cesionesrea
                              (scesrea, ncesion, icesion, icapces, sseguro,
                               nversio, scontra, ctramo, nriesgo, cgarant,
                               nsinies, fefecto, fvencim, pcesion, sproces, cgenera,
                               fgenera, sidepag, cdetces, nmovigen)
                       VALUES (scesrea.NEXTVAL, ces.ncesion + 1, pisinret, 0, ces.sseguro,
                               pnversio, pscontra, ces.ctramo, ces.nriesgo, pcgarant,
                               pnsinies, pfefepag, pfefepag, ces.pcesion, ces.scesrea, 2,
                               pfcierre, psidepag, ces.cdetces, 0);
               EXCEPTION
                  WHEN OTHERS THEN
                     ltexto := f_axis_literales(105200, pcidioma);
                     -- Error al insertar en CESIONESREA
                     num_err := f_proceslin(psproces, ltexto || '-Pago: ' || psidepag,
                                            ces.sseguro || '-Error:' || SQLERRM, nprolin);
                     RETURN 1;
               END;
            END LOOP;

            IF wnumces = 0 THEN
               ltexto := f_axis_literales(9002138, pcidioma);
               -- No se han generado cesiones para el pago
               num_err := f_proceslin(psproces, ltexto || '-Pago: ' || psidepag, psidepag,
                                      nprolin);
               RETURN 1;
            END IF;
         ELSE
            -- 23618 - AVT - 06/09/2012 es corretgeix perque també funcioni amb cessions agrupades (cgarant = null).
            FOR ces IN c_cessio_agr(psidepag) LOOP
               wnumces := wnumces + 1;

               BEGIN
                  INSERT INTO cesionesrea
                              (scesrea, ncesion, icesion, icapces, sseguro,
                               nversio, scontra, ctramo, nriesgo, cgarant,
                               nsinies, fefecto, fvencim, pcesion, sproces, cgenera,
                               fgenera, sidepag, cdetces, nmovigen)
                       VALUES (scesrea.NEXTVAL, ces.ncesion + 1, pisinret, 0, ces.sseguro,
                               pnversio, pscontra, ces.ctramo, ces.nriesgo, pcgarant,
                               pnsinies, pfefepag, pfefepag, ces.pcesion, ces.scesrea, 2,
                               pfcierre, psidepag, ces.cdetces, 0);
               EXCEPTION
                  WHEN OTHERS THEN
                     ltexto := f_axis_literales(105200, pcidioma);
                     -- Error al insertar en CESIONESREA
                     num_err := f_proceslin(psproces, ltexto || '-Pago: ' || psidepag,
                                            ces.sseguro || '-Error:' || SQLERRM, nprolin);
                     RETURN 1;
               END;
            END LOOP;

            IF wnumces = 0 THEN
               ltexto := f_axis_literales(9002138, pcidioma);
               -- No se han generado cesiones para el pago
               num_err := f_proceslin(psproces, ltexto || '-Pago: ' || psidepag, psidepag,
                                      nprolin);
               RETURN 1;
            END IF;
         END IF;
      ELSE
         ltexto := f_axis_literales(9002135, pcidioma);
-- No se ha podido generar cesi?n. Existe m?s de un tramo por contrato y versi?n. Pago:
         num_err := f_proceslin(psproces,
                                ltexto || psidepag || ' -pscontra:' || pscontra
                                || '-pnversio:' || pnversio,
                                pnsinies, nprolin);
         RETURN 1;
      END IF;

      RETURN 0;
   END f_genera_ces_pago;

   -- FI Bug 11051 - 07/09/2009 - FAL

   -- BUG 11350 - 05/10/2009 - FAL - Creaci?n f_reamovpagos que realitza el c?lcul de reserves a nivell de pagament per aquells pagos encara pendents
   /*************************************************************************
      Recupera los pagos de siniestros para generar la cesi?n
      param in psproces   : c?digo proceso
      param in pcempres   : c?digo empresa
      param in pffin      : fecha fin orden de pago
      param in pexperr    : descripci?n del error
   *************************************************************************/
   FUNCTION f_reamovpagos(
      psproces IN NUMBER,
      pcempres IN NUMBER,
      pffin IN DATE,
      pexperr OUT VARCHAR2)
      RETURN NUMBER IS
-- *******************************************
-- Declaracion de las variables globales
-- *******************************************
      vramo          reamovpagos.cramo%TYPE := 0;   -- BUG 0025803 NUMBER(6) := 0;
      vany           reamovpagos.nanyo%TYPE := 0;   -- BUG 0025803 NUMBER(4) := 0;
      vfsin          reamovpagos.fsin%TYPE := NULL;   -- BUG 0025803 DATE := NULL;
      vitotal        reamovpagos.itotal%TYPE := 0;   -- BUG 0025803 NUMBER(14, 2) := 0;   -- Importe Total
      vicompa        reamovpagos.icompan%TYPE := 0;   -- BUG 0025803 NUMBER(14, 2) := 0;   -- Importe compa?ia
      vporrea        reamovpagos.ppropio%TYPE := 0;   -- BUG 0025803 NUMBER(8, 5) := 0;   -- % reasegurado
      vnsegcon       reamovpagos.scontra%TYPE;   -- NUMBER(6);
      vcpceco        NUMBER(8, 5) := 0;   -- % Compa?ia
      error          NUMBER(7) := 0;
      vpcesion       reamovpagos.ptramo%TYPE := 0;   -- BUG 0025803 NUMBER(8, 5) := 0;
      -- Pcesion con el tratamiento del tramo 1 si hace falta
      vicesion       reamovpagos.itramo%TYPE := 0;   -- BUG 0025803 NUMBER(14, 2) := 0;
      -- Icesion  con el tratamiento del tramo 1 si hace falta
      vcescomp       NUMBER(10, 5) := 0;
      -- Porcentaje de la compa??a respecto al % cedido en el tramo
      vtipram        reamovpagos.ctipram%TYPE := 0;   -- BUG 0025803  NUMBER(2) := 0;
        -- Tipo de ramo, 1 sconagr(codicontratos), 2 scontra (codicontratos),
      --   3 cramo(seguros)
      vscontra       cesionesrea.scontra%TYPE;   -- BUG 0025803 NUMBER(6);
      vnversio       cesionesrea.nversio%TYPE;   -- BUG 0025803 NUMBER(2);
      vimpres        liqresreaaux.itramo%TYPE := 0;   -- BUG 0025803 NUMBER(14, 2) := 0;
      -- Importe de la reserva de un siniestro a una fecha dada.
      vplocali       NUMBER;
      w_param        NUMBER(1);
      w_creaseg      NUMBER(1);
      vitotal_pro    reamovpagos.itotal%TYPE := 0;   -- BUG 0025803  NUMBER(15, 2) := 0;
      vpcesion_pro   reamovpagos.ptramo%TYPE := 0;   -- BUG 0025803  NUMBER(8, 5) := 0;
      vicesion_pro   reamovpagos.itramo%TYPE := 0;   -- BUG 0025803  NUMBER(15, 2) := 0;
      ppropio_pro    reamovpagos.ppropio%TYPE := 0;   -- BUG 0025803  NUMBER(8, 5) := 0;
      ipropio_pro    reamovpagos.ipropio%TYPE := 0;   -- BUG 0025803  NUMBER(15, 2) := 0;
      vicompa_pro    reamovpagos.icompan%TYPE := 0;   -- BUG 0025803  NUMBER(15, 2) := 0;
      vplocpro       NUMBER;
      vversiopro     reamovpagos.nversio%TYPE;   -- BUG 0025803  NUMBER(2);
      vsidepag       NUMBER;
      nlin           NUMBER;

-- *********************************************
-- Declaracion de cursores
-- *********************************************
      CURSOR c_reapagos(pcempres IN NUMBER, pffin IN DATE) IS
         -- BUG 11595 - 04/11/2009 - APD - Adaptaci?n al nuevo m?dulo de siniestros
         SELECT   TO_CHAR(si.nsinies) nsinies, si.fsinies, si.sseguro, si.nriesgo, s.npoliza,
                  s.cobjase, s.cramo, s.cmodali, s.ctipseg, s.ccolect, s.cactivi,
                  NVL(NVL(s.fcaranu, s.fanulac), s.fvencim) fvencim, s.fefecto fefecto,
                  si.fnotifi, pa.sidepag, pa.cestpag, pa.iimpsin, pg.cgarant, pg.isinret
             FROM seguros s, siniestros si, pagosini pa,   --pagosinitrami pa, AVT
                                                        pagogarantia pg, productos p
            WHERE s.sseguro = si.sseguro
              AND s.cempres = pcempres
              AND s.ctiprea <> 2
              AND pa.nsinies = si.nsinies
              AND pa.cestpag NOT IN(8)   --(1, 2) 14833 AVT 03-06-2010
              AND pg.sidepag = pa.sidepag
              AND TRUNC(pa.fordpag) BETWEEN TO_DATE(TO_CHAR(pffin, 'mmyyyy'), 'mmyyyy') AND pffin
              AND(TRUNC(pa.fefepag) > pffin
                  OR pa.fefepag IS NULL)   -- 14833 AVT 03-06-2010
              AND p.sproduc = s.sproduc
              AND p.creaseg = 1
              AND NVL(pac_parametros.f_parempresa_n(s.cempres, 'MODULO_SINI'), 0) = 0
         UNION
         SELECT   si.nsinies, si.fsinies, si.sseguro, si.nriesgo, s.npoliza, s.cobjase,
                  s.cramo, s.cmodali, s.ctipseg, s.ccolect, s.cactivi,
                  NVL(NVL(s.fcaranu, s.fanulac), s.fvencim) fvencim, s.fefecto fefecto,
                  si.fnotifi, pa.sidepag, m.cestpag,
                  (pa.isinret - pa.iretenc - pa.iiva) iimpsin, pg.cgarant, pg.isinret
             FROM seguros s, sin_siniestro si, sin_tramitacion t, sin_tramita_pago pa,   --pagosinitrami pa, AVT
                  sin_tramita_movpago m, sin_tramita_pago_gar pg, productos p
            WHERE s.sseguro = si.sseguro
              AND s.cempres = pcempres
              AND s.ctiprea <> 2
              AND si.nsinies = t.nsinies
              AND t.nsinies = pa.nsinies
              AND t.ntramit = pa.ntramit
              AND pa.sidepag = m.sidepag
              AND m.nmovpag = (SELECT MAX(nmovpag)
                                 FROM sin_tramita_movpago
                                WHERE sidepag = m.sidepag)
              AND m.cestpag NOT IN(8)   --(1, 2) 14833 AVT 03-06-2010
              AND pg.sidepag = pa.sidepag
              AND pg.ctipres not in (5) -- IAXIS-13133 -22/05/2020
              AND TRUNC(pa.fordpag) BETWEEN TO_DATE(TO_CHAR(pffin, 'mmyyyy'), 'mmyyyy') AND pffin
              -- INI -- IAXIS-13133 -JLTS -22/05/2020
              /*AND(TRUNC(m.fefepag) > pffin  
                  OR m.fefepag IS NULL)*/ -- 14833 AVT 03-06-2010
              -- FIN -- IAXIS-13133 -22/05/2020
              AND p.sproduc = s.sproduc
              AND p.creaseg = 1
              AND NVL(pac_parametros.f_parempresa_n(s.cempres, 'MODULO_SINI'), 0) = 1
         ORDER BY nsinies;

      CURSOR c_tramo(
         sseguro_c1 IN NUMBER,
         pfsinies_c1 IN DATE,
         pnriesgo_c1 IN NUMBER,
         pcgarant_c1 IN NUMBER,
         param_c1 IN NUMBER) IS
         SELECT scontra, nversio, ctramo, sfacult, pcesion, sseguro
           FROM cesionesrea
          WHERE sseguro = sseguro_c1
            AND cgenera IN(1, 3, 4, 5, 9, 40)
            AND nriesgo = pnriesgo_c1
            AND((param_c1 = 1
                 AND cgarant IS NOT NULL
                 AND cgarant = pcgarant_c1)
                OR(param_c1 = 2
                   AND cgarant IS NULL)
                OR(param_c1 = 3
                   AND(pcgarant_c1 = 9999
                       OR pcgarant_c1 = 9998)))
            AND fefecto <= pfsinies_c1
            AND fvencim > pfsinies_c1
            AND(fregula IS NULL
                OR fregula > pfsinies_c1)
            AND(fanulac IS NULL
                OR fanulac > pfsinies_c1)
            AND ctramo > 0
            AND ctramo < 6;

      --          ORDER BY CTRAMO;
      CURSOR c_companias(
         pscontra_c1 IN NUMBER,
         pnversio_c1 IN NUMBER,
         pctramo_c2 IN NUMBER,
         psseguro_c2 IN NUMBER,
         pfsinies_c1 IN DATE) IS
         SELECT ccompani, pcesion
           FROM cuadroces
          WHERE pctramo_c2 <> 5
            AND scontra = pscontra_c1
            AND nversio = pnversio_c1
            AND ctramo = pctramo_c2
         UNION
         SELECT cc.ccompani, cc.pcesion
           FROM cuacesfac cc, cuafacul c
          WHERE pctramo_c2 = 5
            AND c.sseguro = psseguro_c2
            AND cc.sfacult = c.sfacult
            AND c.finicuf <= pfsinies_c1   -- AVT Afegit: 15/05/2001
            AND(c.ffincuf > pfsinies_c1
                OR ffincuf IS NULL);

      -- Es restringeix per dates per tal
      -- de que no es dupliquin les dades

      -- *******************************************
-- Declaracion de las funciones locales
-- *******************************************
-- *******************************************************************************************************************
-- *********************************** FUNCION DE MODIFICA EL % E IMPORTE PROPIO  **************************
      FUNCTION modificar_propios_p(
         pnsinies IN VARCHAR2,
         pscontra IN NUMBER,
         pnversio IN NUMBER,
         psproces IN NUMBER,
         pcgarant IN NUMBER,   --KBR 17/04/2014
         pexperr IN OUT VARCHAR2)
         RETURN NUMBER IS
         vporcen        NUMBER(8, 4);
         vimporte       NUMBER(14, 2);
      BEGIN
         --KBR 17/04/2014
         UPDATE reamovpagos
            SET ppropio = 100 - ptramo,
                ipropio = (itotal *(100 - ptramo)) / 100
          WHERE nsinies = pnsinies
            AND scontra = pscontra
            AND nversio = pnversio
            AND sproces = psproces
            AND cgarant = pcgarant;

         RETURN(0);
      EXCEPTION
         WHEN OTHERS THEN
            pexperr := pnsinies || ' ' || pscontra || ' ' || pnversio || ' ' || pcgarant;
            RETURN(9002160);   -- Error al modificar en la tabla reamovpagos
      END modificar_propios_p;
-- ************************************************************************************
--                     CUERPO DE LA FUNCION PRINCIPAL
-- ***********************************************************************************
   BEGIN
      BEGIN
         DELETE      reamovpagos
               WHERE fcierre = pffin
                 AND cempres = pcempres;
      EXCEPTION
         WHEN OTHERS THEN
            --DBMS_OUTPUT.put_line('ERR:' || SQLERRM);
            pexperr := 'Error delete reamovpagos. Fcierre' || pffin;
      END;

      FOR r_reapagos IN c_reapagos(pcempres, pffin) LOOP
         vsidepag := r_reapagos.sidepag;
         vporrea := 0;
         vcpceco := 0;
         vramo := r_reapagos.cramo;
         error :=   -- garantia_reasegurable AVT
            pac_cesionesrea.f_gar_rea(r_reapagos.cramo, r_reapagos.cmodali,
                                      r_reapagos.ctipseg, r_reapagos.ccolect,
                                      r_reapagos.cactivi, r_reapagos.cgarant, w_creaseg);

         IF w_creaseg > 0 THEN
            vfsin := r_reapagos.fsinies;
            vporrea := 0;
            vimpres := 0;

            IF r_reapagos.iimpsin <> 0 THEN   -- no se tratan las reservas a 0...
               w_param := 1;

               WHILE w_param < 4 LOOP
                  vscontra := NULL;

                  FOR r_tramo IN c_tramo(r_reapagos.sseguro, r_reapagos.fsinies,
                                         r_reapagos.nriesgo, r_reapagos.cgarant, w_param) LOOP
                     w_param := 5;

                     IF vscontra IS NULL
                        OR(vscontra IS NOT NULL
                           AND r_tramo.scontra = vscontra) THEN
                        vscontra := r_tramo.scontra;
                        vnversio := r_tramo.nversio;
                        vany := 0;
                        error := anyo_contrato(r_tramo.scontra, r_tramo.nversio,
                                               r_tramo.sfacult, pexperr);

                        IF error = 0 THEN
                           error := buscar_tipocon(r_tramo.scontra, pexperr);

                           IF error = 0 THEN
                              vicesion := (r_reapagos.iimpsin * r_tramo.pcesion) / 100;
                              vpcesion := r_tramo.pcesion;

                              IF r_tramo.ctramo = 1 THEN
                                 error := proceso_tramo_1(r_tramo.scontra, r_tramo.nversio,
                                                          vicesion, vpcesion, vnsegcon,
                                                          vversiopro);

                                 IF error != 0 THEN
                                    pexperr := r_tramo.scontra || ' ' || r_tramo.nversio
                                               || ' ' || r_reapagos.nsinies;
                                 END IF;
                              END IF;

                              IF error = 0 THEN
                                 vporrea := vporrea + vpcesion;
                                 error := importe_total(vicesion, vpcesion);

                                 IF error != 0 THEN
                                    pexperr := r_tramo.scontra || ' ' || r_tramo.nversio
                                               || ' ' || r_reapagos.nsinies;
                                 END IF;

                                 FOR r_companias IN c_companias(r_tramo.scontra,
                                                                r_tramo.nversio,
                                                                r_tramo.ctramo,
                                                                r_tramo.sseguro,
                                                                r_reapagos.fsinies) LOOP
                                    /* EAS: 03/02/00 Cambiamos el % del tramo 1 */
                                    IF r_tramo.ctramo = 1 THEN
                                                                                -- buscamos que representa el tanto por ciento de la compa??a
                                                                             -- respecto al tanto por ciento de cesi?n de este tramo.
                                       --                                               vcescomp := r_companias.pcesion * 100 / NVL(vpcesion,0);
                                       vcescomp :=
                                          (r_companias.pcesion * 100)
                                          /(100 - NVL(vplocali, 0));
                                    ELSE
                                       vcescomp := r_companias.pcesion;
                                    END IF;

                                    IF vtipram = 3 THEN   -- facultativo puro...
                                       importe_compania(vitotal, vcescomp, vicompa);
                                    -- 14833 AVT 03-06-2010
                                    ELSE
                                       importe_compania(vicesion, vcescomp, vicompa);
                                    -- 14833 AVT 03-06-2010
                                    END IF;

                                    BEGIN
                                       INSERT INTO reamovpagos
                                                   (cempres, fcierre, nsinies,
                                                    sidepag, scontra,
                                                    nversio, ctramo,
                                                    ptramo, itramo, npoliza,
                                                    fvencim, cramo, ctipram,
                                                    ccompani, nanyo, fsin,
                                                    pcompan, itotal, icompan,
                                                    sproces, sseguro,
                                                    cgarant, fefecto,
                                                    fnotifi)
                                            VALUES (pcempres, pffin, r_reapagos.nsinies,
                                                    r_reapagos.sidepag, r_tramo.scontra,
                                                    r_tramo.nversio, r_tramo.ctramo,
                                                    vpcesion, vicesion, r_reapagos.npoliza,
                                                    r_reapagos.fvencim, vramo, vtipram,
                                                    r_companias.ccompani, vany, vfsin,
                                                    r_companias.pcesion, vitotal, vicompa,
                                                    psproces, r_reapagos.sseguro,
                                                    r_reapagos.cgarant, r_reapagos.fefecto,
                                                    r_reapagos.fnotifi);

                                       COMMIT;
                                    EXCEPTION
                                       WHEN OTHERS THEN
                                          pexperr :=
                                             'error insert' || r_tramo.scontra || ' '
                                             || r_tramo.nversio || ' ' || r_reapagos.nsinies;
                                    END;
                                 END LOOP;
                              END IF;
                           END IF;
                        END IF;
                     END IF;
                  END LOOP;

                  w_param := w_param + 1;
               END LOOP;

               IF w_param >= 5 THEN
                  --KBR 17/04/2014
                  error := modificar_propios_p(r_reapagos.nsinies, vscontra, vnversio,
                                               psproces, r_reapagos.cgarant, pexperr);
               END IF;
            END IF;
         END IF;
      END LOOP;

      RETURN(0);
   EXCEPTION
      WHEN OTHERS THEN
         error := SQLCODE;
         ROLLBACK;
         error := f_proceslin(psproces, pexperr, vsidepag, nlin);
         COMMIT;
         RETURN(error);
   END f_reamovpagos;

-- FI Bug 11350 - 05/10/2009 - FAL
   -- BUG 20836/111077 - 04/04/2012 - JMP - CRE800: Error cessions reemborsaments
   /*************************************************************************
      Crea les cessions dels reemborsaments en base a les cessions existents.
      param in pnreemb     : N?m. de reemborsament
      param in pnfact      : N?m. de factura intern
      param in pnlinea     : N?m. de l?nia
      param in psseguro    : Id. de seguro
      param in pcgarant    : Codi de garantia
      param in pnriesgo    : N?m. de risc
      param in pfefecto    : Data d'efecte
      param in pipago      : Import a pagar (acceptat)
      param in pscontra    : Id. de contracte
      param in pnversio    : Versi? del contracte
      param in pfcierre    : Data de tancament
      param in psproces    : Id. del proc?s
      param in pcidioma    : Codi idioma
      retorna              : 0 ok; 1 ko
   *************************************************************************/
   FUNCTION f_genera_ces_reemb(
      pnreemb IN NUMBER,
      pnfact IN NUMBER,
      pnlinea IN NUMBER,
      psseguro IN NUMBER,
      pcgarant IN NUMBER,
      pnriesgo IN NUMBER,
      pfefecto IN DATE,
      pipago IN NUMBER,
      pscontra IN NUMBER,
      pnversio IN NUMBER,
      pfcierre IN DATE,
      psproces IN NUMBER,
      pcidioma IN NUMBER)
      RETURN NUMBER IS
      CURSOR c_cessio IS
         SELECT *
           FROM cesionesrea
          WHERE scesrea IN(SELECT MIN(scesrea)
                             FROM cesionesrea
                            WHERE sseguro = psseguro
                              AND cgarant = pcgarant
                              AND nriesgo = pnriesgo)
            AND cgenera <> 2;

      v_trams        NUMBER;
      nprolin        NUMBER;
      ltexto         VARCHAR2(200);
      num_err        NUMBER;
      wnumces        NUMBER := 0;
   BEGIN
      SELECT COUNT(ctramo)
        INTO v_trams
        FROM tramos
       WHERE scontra = pscontra
         AND nversio = pnversio;

      IF v_trams >= 1 THEN
         FOR ces IN c_cessio LOOP
            wnumces := wnumces + 1;

            BEGIN
               INSERT INTO cesionesrea
                           (scesrea, ncesion, icesion, icapces, sseguro,
                            nversio, scontra, ctramo, nriesgo, cgarant, fefecto,
                            fvencim, pcesion, sproces, cgenera, fgenera, cdetces, nmovigen,
                            nreemb, nfact, nlinea)
                    VALUES (scesrea.NEXTVAL, ces.ncesion + 1, pipago, 0, ces.sseguro,
                            pnversio, pscontra, ces.ctramo, ces.nriesgo, pcgarant, pfefecto,
                            pfefecto, ces.pcesion, ces.scesrea, 2, pfcierre, ces.cdetces, 0,
                            pnreemb, pnfact, pnlinea);
            EXCEPTION
               WHEN OTHERS THEN
                  ltexto := f_axis_literales(105200, pcidioma);
                  -- Error al insertar en CESIONESREA
                  num_err := f_proceslin(psproces,
                                         ltexto || '-N.Reemb/Fact./Ln.: ' || pnreemb || '/'
                                         || pnfact || '/' || pnlinea,
                                         ces.sseguro || '-Error:' || SQLERRM, nprolin);
                  RETURN 1;
            END;
         END LOOP;

         IF wnumces = 0 THEN
            ltexto := f_axis_literales(9903553, pcidioma);
            -- No se han generado cesiones para el reembolso
            num_err := f_proceslin(psproces,
                                   ltexto || '-N.Reemb/Fact./L?n.: ' || pnreemb || '/'
                                   || pnfact || '/' || pnlinea,
                                   psseguro, nprolin);
            RETURN 1;
         END IF;
      ELSE
         ltexto := f_axis_literales(9903554, pcidioma);
-- No se ha podido generar cesi?n. Existe m?s de un tramo por contrato y versi?n. N.Reemb./Fact./L?n.:
         num_err := f_proceslin(psproces,
                                ltexto || pnreemb || '/' || pnfact || '/' || pnlinea
                                || ' -pscontra:' || pscontra || '-pnversio:' || pnversio,
                                psseguro, nprolin);
         RETURN 1;
      END IF;

      RETURN 0;
   END f_genera_ces_reemb;

   /*************************************************************************
      En base als reemborsaments sense cessi?, busca el contracte que li
      correspon segons data d'efecte i crida a la generaci? de les cessions.
      param in pcempres   : c?digo empresa
      param in pnpoliza   : c?digo p?liza
      param in pnreemb    : n?mero de reembolso
      param in psproces   : c?digo proceso cierre reaseguro
      param in pcidioma   : c?digo idioma
      param in pfcierre   : fecha cierre
   *************************************************************************/
   PROCEDURE p_genera_ces_reemb(
      pcempres IN NUMBER,
      pnpoliza IN NUMBER,
      pnreemb IN NUMBER,
      psproces IN NUMBER,
      pcidioma IN NUMBER,
      pfcierre IN DATE) IS
      CURSOR reemb_sinces(pempresa IN NUMBER, psseguro IN NUMBER, ppol IN NUMBER) IS
         SELECT s.cempres, s.cramo, s.cmodali, s.ctipseg, s.ccolect, s.cactivi, r.*
           FROM reembsinces r, seguros s
          WHERE r.sseguro = s.sseguro
            AND s.cempres = pempresa
            AND(r.sseguro = psseguro
                OR psseguro IS NULL)
            AND(s.npoliza = ppol
                OR ppol IS NULL)
            AND(r.nreemb = pnreemb
                OR pnreemb IS NULL)
            AND r.crevisi = 1;

      wsseguro       NUMBER;
      err            NUMBER := 0;
      pmotiu         NUMBER := 2;
      v_scontra      NUMBER := NULL;
      v_nversio      NUMBER;
      v_ipleno       NUMBER;
      v_icapaci      NUMBER;
      v_cdetces      NUMBER;
      nprolin        NUMBER;
      num_err        NUMBER;
      ltexto         VARCHAR2(200);
   BEGIN
      IF pnpoliza IS NOT NULL THEN
         BEGIN
            SELECT sseguro
              INTO wsseguro
              FROM seguros
             WHERE npoliza = pnpoliza;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               -- 23261 AVT 20/082012 pòlissa amb certificats
               wsseguro := NULL;
            WHEN OTHERS THEN
               ltexto := f_axis_literales(111360, pcidioma);
               -- La p?liza no existe
               num_err := f_proceslin(psproces, ltexto, pnpoliza, nprolin);
               err := 1;
         END;
      END IF;

      IF err = 0 THEN
         FOR reg IN reemb_sinces(pcempres, wsseguro, pnpoliza) LOOP
            err := 0;
            err := f_buscacontrato(reg.sseguro, reg.fefecto, reg.cempres, reg.cgarant,
                                   reg.cramo, reg.cmodali, reg.ctipseg, reg.ccolect,
                                   reg.cactivi, pmotiu, v_scontra, v_nversio, v_ipleno,
                                   v_icapaci, v_cdetces);

            IF err = 0
               AND v_scontra IS NOT NULL THEN
               err := pac_reaseguro_rec.f_genera_ces_reemb(reg.nreemb, reg.nfact, reg.nlinea,
                                                           reg.sseguro, reg.cgarant,
                                                           reg.nriesgo, reg.fefecto,
                                                           reg.ipago, v_scontra, v_nversio,
                                                           pfcierre, psproces, pcidioma);

               IF err = 0 THEN
                  BEGIN
                     UPDATE reembsinces
                        SET crevisi = 2,
                            frevisi = f_sysdate,
                            cusuari = f_user
                      WHERE nreemb = reg.nreemb
                        AND nfact = reg.nfact
                        AND nlinea = reg.nlinea;
                  EXCEPTION
                     WHEN OTHERS THEN
                        ltexto := f_axis_literales(9903557, pcidioma);
                        -- Error al modificar REEMBSINCES
                        num_err := f_proceslin(psproces, ltexto, reg.sseguro, nprolin);
                  END;
               END IF;
            ELSE
               ltexto := f_axis_literales(104485, pcidioma);
               -- No se encuentra el contrato
               num_err := f_proceslin(psproces, ltexto, reg.sseguro, nprolin);
            END IF;
         END LOOP;
      END IF;
   END p_genera_ces_reemb;

-- 22799 AVT 01/08/2012  AGM TREU EL C?LCUL DE RESERVES DEL TANCMENT PER FER-LO POST PPNC
-- 24109 AVT 13/11/2012 ES SIMPLIFICA I S'AJUSTA EL CÀLCUL
   FUNCTION f_diposit_ppnc_rea(
      pcempres IN NUMBER,
      pmes IN NUMBER,
      pany IN NUMBER,
      pproces IN NUMBER)
      RETURN NUMBER IS
      perror         NUMBER := 0;
      w_nnumlin      NUMBER := 0;
      psql           NUMBER := 0;
      w_cestado      NUMBER := 0;
      w_reserva      NUMBER := 0;
      w_fcierre      DATE;
      v_traza        NUMBER(2) := 0;
      pscesrea       NUMBER(8);
      text_error     VARCHAR2(500);
      w_objecte      VARCHAR2(100) := 'pac_reaseguro_rec.f_diposit_ppnc_rea';
      pnnumlin       NUMBER;
      texto          VARCHAR2(400);
      w_scontra      NUMBER;
      w_nversio      NUMBER;
      w_ipleno       NUMBER;
      w_icapaci      NUMBER;
      w_cdetces      NUMBER;
      w_icomisi      NUMBER;
      v_sproces      NUMBER;
      w_pcomias      NUMBER;
      w_ccomrea      NUMBER;

      CURSOR provis(c_emp IN NUMBER, c_pro IN NUMBER) IS
         SELECT   cempres, sproduc, p.fcalcul fcierre, cramo, cmodali, ctipseg, ccolect,
                  TO_DATE('0101' || TO_CHAR(fefeini, 'yyyy'), 'ddmmyyyy') fefeini,
                  SUM(ipncsrc) ipn
             FROM ppnc_rea p
            WHERE p.cempres = c_emp
              AND p.sproces = c_pro
              AND NVL(ipncsrc, 0) <> 0
              AND ntramo <> 5
         GROUP BY cempres, sproduc, p.fcalcul, cramo, cmodali, ctipseg, ccolect,
                  TO_DATE('0101' || TO_CHAR(fefeini, 'yyyy'), 'ddmmyyyy')
         ORDER BY cramo, cmodali, ctipseg, ccolect,
                  TO_DATE('0101' || TO_CHAR(fefeini, 'yyyy'), 'ddmmyyyy');   -- 19/07/2013 avt

      CURSOR cur_cuadroces(wscontra NUMBER, wnversio NUMBER) IS
         SELECT   cc.scontra, cc.nversio, cc.ctramo, cc.ccompani, cc.ccorred, cc.preserv,   -- AVT 22/07/2013
                  cc.ccomrea, pctcomis pcomisi, cc.icomfij
             FROM cuadroces cc
            WHERE scontra = wscontra
              AND nversio = wnversio
              AND NVL(preserv, 0) <> 0
         ORDER BY cc.ctramo, cc.ccompani;

      CURSOR cur_comisrea(wccomrea NUMBER, wfefecto DATE, wfvencim DATE) IS
         SELECT scomrea, fcomini, fcomfin
           FROM comisreas
          WHERE ccomrea = wccomrea
            AND fcomini <= wfefecto
            AND(fcomfin > wfvencim
                OR fcomfin IS NULL);
   BEGIN
      v_traza := 1;

      FOR reg IN provis(pcempres, pproces) LOOP
         w_fcierre := reg.fcierre;
         v_traza := 3;

         SELECT MAX(sproces)
           INTO v_sproces
           FROM movctatecnica
          WHERE cempres = pcempres
            AND fmovimi = w_fcierre;

         perror := f_buscacontrato(0, reg.fefeini, reg.cempres, 0, reg.cramo, reg.cmodali,
                                   reg.ctipseg, reg.ccolect, 0, 3, w_scontra, w_nversio,
                                   w_ipleno, w_icapaci, w_cdetces);

         FOR cta IN cur_cuadroces(w_scontra, w_nversio) LOOP
            v_traza := 2;
            w_icomisi := 0;   -- 19/07/2013 avt

            IF cta.icomfij IS NOT NULL THEN
               w_icomisi := cta.icomfij;
            ELSIF cta.ccomrea IS NOT NULL THEN
               w_ccomrea := cta.ccomrea;

               FOR curcomis IN cur_comisrea(w_ccomrea, reg.fefeini, reg.fefeini) LOOP
                  perror := f_buscomgarant(curcomis.scomrea, 0, 0, reg.fefeini, w_pcomias);

                  IF perror <> 0 THEN
                     p_tab_error(f_sysdate, f_user, w_objecte, v_traza,
                                 'Err f_buscomgarant:' || curcomis.scomrea || ', '
                                 || reg.fefeini || ', ' || w_pcomias,
                                 ' SQLERRM = ' || SQLERRM);
                  END IF;
               END LOOP;
            -- 21398 AVT 23/02/2012 s'afegeix el c?lcul de la comissi? per % fix (PCOMISI)
            ELSIF cta.pcomisi IS NOT NULL THEN
               w_pcomias := cta.pcomisi;
            END IF;

            IF NVL(w_pcomias, 0) <> 0 THEN
               --w_icomisi := (((reg.ipn * cta.pcesion) / 100) * w_pcomias) / 100;
               w_icomisi := (reg.ipn * w_pcomias) / 100;
            END IF;

-----------------------------------------------------
-- Aqu? busquen l'estat del compte a CTATECNICA... ---
------------------------------------------------------
            v_traza := 4;

            IF perror = 0 THEN
               BEGIN
                  SELECT cestado
                    INTO w_cestado
                    FROM ctatecnica
                   WHERE scontra = cta.scontra
                     AND nversio = cta.nversio
                     AND ctramo = cta.ctramo
                     AND ccompani = cta.ccompani
                     AND sproduc = reg.sproduc;
               --OR NVL(sproduc, 0) = 0); 23830 AVT 17/12/2012
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     w_cestado := 1;
                     v_traza := 5;

                     --                                 DBMS_OUTPUT.put_line('es nuevo, insertamos en ctatecnica');
                     BEGIN
                        INSERT INTO ctatecnica
                                    (ccompani, nversio, scontra, ctramo, nctatec,
                                     cfrecul, cestado, festado, fcierre, cempres, sproduc,
                                     ccorred)   -- 22076 AVT 25/05/2012 nous camps
                             VALUES (cta.ccompani, cta.nversio, cta.scontra, cta.ctramo, 1,
                                     3, 1, NULL, NULL, reg.cempres, reg.sproduc,
                                     cta.ccorred);
                     EXCEPTION
                        WHEN OTHERS THEN
                           p_tab_error(f_sysdate, f_user, w_objecte, v_traza,
                                       'Err INSERT ctatecnica:' || reg.cempres || ', '
                                       || reg.sproduc || ', ' || cta.ccompani || ', '
                                       || cta.nversio || ', ' || cta.scontra || ', '
                                       || cta.ctramo,
                                       ' SQLERRM = ' || SQLERRM);
                           perror := 1;
                     END;
                  WHEN OTHERS THEN
                     p_tab_error(f_sysdate, f_user, w_objecte, v_traza,
                                 'Err SELECT ctatecnica:' || reg.cempres || ', '
                                 || reg.sproduc || ', ' || cta.ccompani || ', ' || cta.nversio
                                 || ', ' || cta.scontra || ', ' || cta.ctramo,
                                 ' SQLERRM = ' || SQLERRM);
                     perror := 104866;
                     psql := SQLERRM;
               END;
            END IF;

            v_traza := 6;

            IF perror = 0 THEN
               BEGIN
                  SELECT NVL(MAX(nnumlin), 0)
                    INTO w_nnumlin
                    FROM movctaaux
                   WHERE scontra = cta.scontra
                     AND nversio = cta.nversio
                     AND ctramo = cta.ctramo
                     AND ccompani = cta.ccompani;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     w_nnumlin := 1;
                  WHEN OTHERS THEN
                     p_tab_error(f_sysdate, f_user, 'pac_reaseguro_rec.f_diposit_rea',
                                 v_traza,
                                 'Err SELECT  FROM movctaaux:' || cta.ccompani || ', '
                                 || cta.nversio || ', ' || cta.scontra || ', ' || cta.ctramo,
                                 ' SQLERRM = ' || SQLERRM);
                     perror := 104863;
                     psql := SQLERRM;
               END;

               w_nnumlin := w_nnumlin + 1;
               v_traza := 7;
            END IF;

-----------------------------------------------------------
--Aqu? es fa el insert de les reserves, si existeixen, a --
--efectiu i a dip?sit...                                 --
-----------------------------------------------------------
            v_traza := 8;

            IF perror = 0 THEN
               -- 23771 - AVT - 26/09/2012  (reg.icesion - v_icomisi)
               w_reserva := 0;   --19/07/20213
               w_reserva := ((reg.ipn - w_icomisi) * cta.preserv) / 100;
               v_traza := 9;

               BEGIN
                  UPDATE movctaaux
                     SET iimport = iimport + w_reserva
                   WHERE scontra = cta.scontra
                     AND nversio = cta.nversio
                     AND ctramo = cta.ctramo
                     AND ccompani = cta.ccompani
                     AND sproduc = reg.sproduc   --19/07/20213
                     AND cconcep = 03;

                  IF SQL%ROWCOUNT = 0 THEN
                     v_traza := 10;

                     BEGIN
                        INSERT INTO movctaaux
                                    (ccompani, nversio, scontra, ctramo,
                                     nnumlin, fmovimi, sproduc, fefecto, cconcep, cdebhab,
                                     iimport, cestado, sproces, scesrea, cempres,
                                     fcierre)
                             VALUES (cta.ccompani, cta.nversio, cta.scontra, cta.ctramo,
                                     w_nnumlin,LAST_DAY(TO_DATE('01/' || pmes || '/'
                                                                        || pany,
                                                                        'dd/mm/yyyy')), reg.sproduc, w_fcierre, 03, 1,
                                     w_reserva, w_cestado, v_sproces, NULL, reg.cempres,
                                     LAST_DAY(TO_DATE('01/' || pmes || '/'
                                                                        || pany,
                                                                        'dd/mm/yyyy')));
                     EXCEPTION
                        WHEN OTHERS THEN
                           p_tab_error(f_sysdate, f_user, w_objecte, v_traza,
                                       'Err INSERT movctaaux:' || cta.ccompani || ', '
                                       || cta.nversio || ', ' || cta.scontra || ', '
                                       || cta.ctramo,
                                       ' SQLERRM = ' || SQLERRM);
                           perror := 105802;
                           psql := SQLERRM;
                     END;
                  END IF;
               EXCEPTION
                  WHEN OTHERS THEN
                     p_tab_error(f_sysdate, f_user, w_objecte, v_traza,
                                 'Err UPDATE movctaaux:' || cta.ccompani || ', '
                                 || cta.nversio || ', ' || cta.scontra || ', ' || cta.ctramo,
                                 ' SQLERRM = ' || SQLERRM);
                     perror := 105801;
                     psql := SQLERRM;
               END;

               v_traza := 11;

               -- concpete dipòsit  --
               BEGIN
                  UPDATE movctaaux
                     SET iimport = iimport + w_reserva
                   WHERE scontra = cta.scontra
                     AND nversio = cta.nversio
                     AND ctramo = cta.ctramo
                     AND ccompani = cta.ccompani
                     AND cconcep = 52;

                  IF SQL%ROWCOUNT = 0 THEN
                     v_traza := 12;

                     BEGIN
                        INSERT INTO movctaaux
                                    (ccompani, nversio, scontra, ctramo,
                                     nnumlin, fmovimi, sproduc, fefecto, cconcep, cdebhab,
                                     iimport, cestado, sproces, cempres, fcierre)
                             VALUES (cta.ccompani, cta.nversio, cta.scontra, cta.ctramo,
                                     w_nnumlin, LAST_DAY(TO_DATE('01/' || pmes || '/'
                                                                        || pany,
                                                                        'dd/mm/yyyy')), reg.sproduc, w_fcierre, 52, 2,   -- 1, -- BUG 25373 - FAL - 18/10/2013. Concepto 52 al haber
                                     w_reserva, w_cestado, v_sproces, reg.cempres, LAST_DAY(TO_DATE('01/' || pmes || '/'
                                                                        || pany,
                                                                        'dd/mm/yyyy')));
                     EXCEPTION
                        WHEN OTHERS THEN
                           p_tab_error(f_sysdate, f_user, w_objecte, v_traza,
                                       'Err INSERT movctaaux:' || cta.ccompani || ', '
                                       || cta.nversio || ', ' || cta.scontra || ', '
                                       || cta.ctramo,
                                       ' SQLERRM = ' || SQLERRM);
                           perror := 105802;
                           psql := SQLERRM;
                     END;
                  END IF;
               EXCEPTION
                  WHEN OTHERS THEN
                     p_tab_error(f_sysdate, f_user, w_objecte, v_traza,
                                 'Err UPDATE movctaaux:' || cta.ccompani || ', '
                                 || cta.nversio || ', ' || cta.scontra || ', ' || cta.ctramo,
                                 ' SQLERRM = ' || SQLERRM);
                     perror := 105801;
                     psql := SQLERRM;
               END;
-------------
            END IF;
                      --
-----------
         END LOOP;
      END LOOP;

      v_traza := 13;

      IF perror = 0 THEN
         COMMIT;
         perror := pac_reaseguro_rec.llenar_tablas_defi(psql, pscesrea, pcempres, w_fcierre);
         v_traza := 14;

         IF perror <> 0 THEN
            p_tab_error(f_sysdate, f_user, w_objecte, v_traza,
                        'f_diposit_ppnc_rea:' || perror, ' SQLERRM = ' || SQLERRM);
            texto := f_axis_literales(perror, 2);
            pnnumlin := NULL;
            text_error := SUBSTR(texto || ' ' || psql, 1, 120);
            perror := f_proceslin(v_sproces, text_error, pscesrea || '3', pnnumlin);
            ROLLBACK;
         ELSE
            COMMIT;
         END IF;
      END IF;

      v_traza := 15;
      RETURN perror;
   END f_diposit_ppnc_rea;

/***********************************************************************************************
    Nova funció:
    Funcio que retorna el % de comisión escalonada
    Parametres: pcempres, cia.comis_rea, v_siniestralitat
    Sortida:w_pcomias

    22/01/2013   AVT     0024998: MDP_T003-Comisiones Escalonadas
 ******************************************************************************************** */

   --bug 25860 ETM 08/04/202013 INI---------------
   FUNCTION f_com_escalonada(
      pcempres IN NUMBER,
      pccomis IN NUMBER,
      psinies IN NUMBER,
      pcomias OUT VARCHAR2)
      RETURN NUMBER IS
      pexperr        NUMBER;
      v_sin_min      clausulas_reas_det.ilim_inf%TYPE;
      v_sin_max      clausulas_reas_det.ilim_sup%TYPE;
      v_com_min      clausulas_reas_det.pctmin%TYPE;
      v_com_max      clausulas_reas_det.pctmax%TYPE;
   BEGIN
      v_traza := 1110;

      IF NVL(pac_parametros.f_parempresa_n(pcempres, 'COMIS_REA_PONDERADA'), 0) = 1 THEN
         SELECT MAX(ilim_inf), MAX(ilim_sup), MAX(pctmin), MAX(pctmax)
           INTO v_sin_min, v_sin_max, v_com_min, v_com_max
           FROM clausulas_reas_det
          WHERE ccodigo = pccomis;

         --PCTMIN + (ILIM_SUP-SINIESTRALIDAD REAL)* (PCTMAX-PCTMIN) / (ILIM_SUP- ILIM_INF)
          --clausulas_reas_det
         pcomias := v_com_min
                    + (v_sin_max - psinies) *(v_com_max - v_com_min) /(v_sin_max - v_sin_min);
      ELSE
         SELECT pctmin
           INTO pcomias
           FROM clausulas_reas_det
          WHERE ccodigo = pccomis
            AND ilim_inf <= psinies
            AND ilim_sup >= psinies;
      END IF;

      RETURN(0);
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         p_tab_error(f_sysdate, f_user, 'pac_reaseguro_rec.f_com_escalonada', v_traza,
                     'Err:' || pccomis || ', ' || psinies, ' SQLERRM = ' || SQLERRM);
         pexperr := pexperr || ', ' || pccomis || ', ' || psinies || ', ' || pcomias || ', '
                    || SQLERRM || ', ' || TO_CHAR(SQLCODE);
         RETURN(104332);   -- Contrato no encontrado en la tabla CONTRATOS
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_reaseguro_rec.f_com_escalonada', v_traza,
                     'Err SELECT FROM contratos:' || pccomis || ', ' || psinies,
                     ' SQLERRM = ' || SQLERRM);
         pexperr := pexperr || ' ' || pccomis || ', ' || psinies || ', ' || pcomias || ', '
                    || SQLERRM || ', ' || TO_CHAR(SQLCODE);
         RETURN(104704);   -- Error al leer de CONTRATOS
   END f_com_escalonada;

--bug 25860 ETM 08/04/202013 FIN---------------

   /***********************************************************************************************
        Funcio que retorna el nº de una línea
        Parametres: p_scontra, p_nversio, p_ctramo, p_ccompani, p_error
        Sortida:w_pcomias

        24/03/2014   AGG
     ********************************************************************************************  */
   FUNCTION f_obtener_numlin(
      p_scontra IN NUMBER,
      p_nversio IN NUMBER,
      p_ctramo IN NUMBER,
      p_ccompani IN NUMBER,
      p_error OUT NUMBER)
      RETURN NUMBER IS
      v_error        NUMBER := 0;
      v_aux          NUMBER := 0;
      v_traza        NUMBER := 99;
   BEGIN
      BEGIN
         SELECT NVL(MAX(nnumlin), 0)
           INTO v_aux
           FROM movctatecnica
          WHERE scontra = p_scontra
            AND nversio = p_nversio
            AND ctramo = p_ctramo
            AND ccompani = p_ccompani;

         v_aux := v_aux + 1;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            v_aux := 1;
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, 'pac_reaseguro_xl.f_insert_saldo', v_traza,
                        'Err SELECT FROM movctatecnica:' || p_scontra || ', ' || p_nversio
                        || ', ' || p_ctramo || ', ' || p_ccompani,
                        ' SQLERRM = ' || SQLERRM);
            v_error := 104863;
      END;

      p_error := v_error;
      RETURN v_aux;
   END;

   /***********************************************************************************************
        Función que inserta un saldo en movctatecnica
        Parametros: pcempres, pmes, panu, psproces
        Sortida:w_pcomias

        24/03/2014   AGG
        17/06/2014   JMV
        08/07/2014   SHA
     ********************************************************************************************  */
   FUNCTION f_insert_saldo(
      pcempres IN NUMBER,
      pmes IN NUMBER,
      pany IN NUMBER,
      psproces IN NUMBER,
      pstiporea IN NUMBER DEFAULT 1)
      RETURN NUMBER IS
      v_error        NUMBER := 0;
   BEGIN
      --08/07/2014 SHA: Se unifica la función de saldos en PAC_REASEGURO_XL para proporcional i no propocional (28475)
      v_error := pac_reaseguro_xl.f_insert_saldo(pcempres, pmes, pany, psproces, pstiporea);
      RETURN v_error;
   END f_insert_saldo;

   --CONF-692 Inicio
   /***********************************************************************************************
        Función que calcula y guarda la reexpresion de saldos seg£¿ el tipo

   ********************************************************************************************  */
   PROCEDURE p_reexpresion(p_cempres      IN  NUMBER,
                           p_sproces      IN  NUMBER,
                           p_sseguro      IN  NUMBER,
                           p_fecreex      IN  DATE,
                           p_scontra      IN  NUMBER,
                           p_ccompani     IN  NUMBER,
                           p_nversio      IN  NUMBER,
                           p_ctramo       IN  NUMBER,
                           p_sproduc      IN  NUMBER,
                           p_nmovimi      IN  NUMBER,
                           p_tipo         IN  NUMBER,
                           p_tipo_reexp   IN  NUMBER,
                           p_importe      IN  NUMBER,
                           p_imp_comision IN  NUMBER,
                           p_sfacult      IN  NUMBER,
                           p_nsinies      IN  NUMBER,
                           p_error        OUT NUMBER) IS
      v_imp_reex     NUMBER;
      v_imp_base     NUMBER;
      v_fecha_ant    DATE;
      v_importe      NUMBER;
      v_preserv      NUMBER;
      v_reserva      NUMBER;
      v_proces_ant   reexpresiones.sproces%TYPE;
      v_itasa_ini    eco_tipocambio.itasa%TYPE;
      v_itasa_fin    eco_tipocambio.itasa%TYPE;
      v_itasa_inicon eco_tipocambio.itasa%TYPE;
      v_itasa_fincon eco_tipocambio.itasa%TYPE;
      v_valor_inicon NUMBER;
      v_valor_fincon NUMBER;
      v_valor_ini    NUMBER;
      v_valor_fin    NUMBER;
      v_traza        NUMBER(4);
      v_fmovimi      DATE;
      v_monconn      parempresas.nvalpar%TYPE;
      v_moncon       monedas.cmonint%TYPE;
      v_moneda_prodn monedas.cmoneda%TYPE;
      v_cmonori      monedas.cmonint%TYPE;
      v_cmondes      monedas.cmonint%TYPE;

      v_txt_valores_ini VARCHAR2(1000);
      v_txt_valores_fin VARCHAR2(1000);
      v_txt_operac_ini  VARCHAR2(1000);
      v_txt_operac_fin  VARCHAR2(1000);
      v_tipo            VARCHAR2(100);
      v_tipo_reexp      NUMBER;

      CURSOR cierresant IS
        SELECT r.imp_mondes_fin, r.freexp, r.sproces
          FROM reexpresiones r
         WHERE r.cempres   = p_cempres
           AND r.sseguro   = p_sseguro
           AND r.scontra   = p_scontra
           AND r.ccompani  = p_ccompani
           AND r.nversio   = p_nversio
           AND r.ctramo    = p_ctramo
           AND r.sproduc   = p_sproduc
           AND r.nmovimi   = p_nmovimi
           AND r.tiporeexp = p_tipo_reexp
           AND r.freexp   != p_fecreex
           AND r.cmonori   = v_cmonori
           AND r.cmondes   = v_cmondes
         ORDER BY r.freexp DESC;

      CURSOR cur_cuadroces(pscontra NUMBER,
                           pnversio NUMBER,
                           pctramo NUMBER,
                           psfacult NUMBER,
                           pcia NUMBER) IS
        SELECT DISTINCT cc.preserv
          FROM cuadroces cc
         WHERE scontra  = pscontra
           AND nversio  = pnversio
           AND ctramo   = pctramo
           AND ccompani = pcia
           AND ctramo <> 5
        UNION
        -- INICIO INFORCOL 12-03-2020
        SELECT DISTINCT presrea/*preserv*/
        -- FIN INFORCOL 12-03-2020
          FROM cuacesfac
         WHERE sfacult  = psfacult
           AND ccompani = pcia;

    BEGIN

      p_error   := 0;
      v_tipo_reexp := p_tipo_reexp;

      --Se busca la moneda original del producto
      v_moneda_prodn := pac_monedas.f_moneda_producto(p_sproduc);
      v_cmonori      := pac_monedas.f_cmoneda_t(v_moneda_prodn);

      v_monconn := pac_parametros.f_parempresa_n(p_cempres, 'MONEDACONTAB');
      v_moncon  := pac_monedas.f_cmoneda_t(v_monconn);

      IF v_cmonori != v_moncon THEN

        IF v_cmonori NOT IN ('USD','COP') THEN
          v_cmondes := 'USD';
        ELSE
          v_cmondes := v_moncon;
        END IF;

        --Se busca si ya existen cierres realizados previamente y qu£¿importe tomo
         OPEN cierresant;
        FETCH cierresant INTO v_imp_base, v_fecha_ant, v_proces_ant;
        CLOSE cierresant;

        IF v_proces_ant IS NULL THEN

          SELECT DISTINCT m.fmovimi
            INTO v_fmovimi
            FROM movseguro m
           WHERE m.sseguro = p_sseguro
             AND m.nmovimi = p_nmovimi;

           OPEN cur_cuadroces(p_scontra, p_nversio, p_ctramo, p_sfacult, p_ccompani);
          FETCH cur_cuadroces INTO v_preserv;
          CLOSE cur_cuadroces;

          v_reserva := (p_importe * NVL(v_preserv,20)) / 100;

          IF p_tipo_reexp = 1 THEN --Mvto Seguro

            --Al importe cedido se le resta la comisi£¿ y los dep£¿itos para tener el valor cedido neto
            v_importe := p_importe - NVL(p_imp_comision,0) - NVL(v_reserva,0);

          ELSIF p_tipo_reexp = 3 THEN --Reembolso Reserva

            v_importe := NVL(v_reserva,0);

          ELSE

            v_importe := p_importe;

          END IF;

        END IF;

        IF v_proces_ant IS NULL
          AND v_cmondes != v_moncon THEN

          --Recuperar tasa de cambio en fecha del mvto, para Moneda de Origen - Moneda Destino
          v_itasa_ini := pac_eco_tipocambio.f_cambio(v_cmonori,
                                                     v_cmondes,
                                                     v_fmovimi);

          v_valor_ini := v_importe * v_itasa_ini;

          --Recuperar tasa a fecha de reexpresi£¿ (cierre o liquidacion), para Moneda Origen - Moneda Destino
          v_itasa_fin := pac_eco_tipocambio.f_cambio(v_cmonori,
                                                     v_cmondes,
                                                     p_fecreex);

          v_valor_fin  := v_importe * v_itasa_fin;

          --Recuperar tasa a fecha del mvto £¿fecha del ultimo cierre, para Moneda Destino - Moneda Contable
          v_itasa_inicon := pac_eco_tipocambio.f_cambio(v_cmondes,
                                                        v_moncon,
                                                        v_fmovimi);

          v_valor_inicon := v_valor_ini * v_itasa_inicon;

          --Recuperar tasa de cambio en fecha de reexpresi£¿ (cierre o liquidacion), para Moneda Destino - Moneda Contable
          v_itasa_fincon := pac_eco_tipocambio.f_cambio(v_cmondes,
                                                        v_moncon,
                                                        p_fecreex);

          v_valor_fincon := v_valor_fin * v_itasa_fincon;

        ELSIF v_proces_ant IS NULL
          AND v_cmondes = v_moncon THEN

          v_valor_ini := v_importe;
          v_valor_fin := v_importe;

          --Recuperar tasa a fecha del mvto £¿fecha del ultimo cierre, para Moneda Origen - Moneda Contable
          v_itasa_inicon := pac_eco_tipocambio.f_cambio(v_cmonori,
                                                        v_moncon,
                                                        v_fmovimi);

          v_valor_inicon := v_importe * v_itasa_inicon;

          --Recuperar tasa de cambio en fecha de reexpresi£¿ (cierre o liquidacion), para Moneda Origen - Moneda Contable
          v_itasa_fincon := pac_eco_tipocambio.f_cambio(v_cmonori,
                                                        v_moncon,
                                                        p_fecreex);

          v_valor_fincon := v_importe * v_itasa_fincon;
          v_itasa_ini := v_itasa_inicon;
          v_itasa_fin := v_itasa_fincon;

        ELSIF v_proces_ant IS NOT NULL
          AND v_cmondes != v_moncon THEN

          v_valor_ini := v_imp_base;
          v_valor_fin := v_imp_base;

          --Recuperar tasa a fecha del ultimo cierre, para Moneda Destino - Moneda Contable
          v_itasa_inicon := pac_eco_tipocambio.f_cambio(v_cmondes,
                                                        v_moncon,
                                                        v_fecha_ant);

          v_valor_inicon := v_imp_base * v_itasa_inicon;

          --Recuperar tasa de cambio en fecha de reexpresi£¿ (cierre o liquidacion), para Moneda Destino - Moneda Contable
          v_itasa_fincon := pac_eco_tipocambio.f_cambio(v_cmondes,
                                                        v_moncon,
                                                        p_fecreex);

          v_valor_fincon := v_imp_base * v_itasa_fincon;

          v_itasa_ini := v_itasa_inicon;
          v_itasa_fin := v_itasa_fincon;
          v_importe := v_imp_base;

        ELSIF v_proces_ant IS NOT NULL
          AND v_cmondes = v_moncon THEN

          v_valor_ini := v_imp_base;
          v_valor_fin := v_imp_base;

          --Recuperar tasa a fecha del ultimo cierre, para Moneda Origen - Moneda Contable
          v_itasa_inicon := pac_eco_tipocambio.f_cambio(v_cmonori,
                                                        v_moncon,
                                                        v_fecha_ant);

          v_valor_inicon := v_imp_base * v_itasa_inicon;

          --Recuperar tasa de cambio en fecha de reexpresi£¿ (cierre o liquidacion), para Moneda Origen - Moneda Contable
          v_itasa_fincon := pac_eco_tipocambio.f_cambio(v_cmonori,
                                                        v_moncon,
                                                        p_fecreex);

          v_valor_fincon := v_imp_base * v_itasa_fincon;
          v_importe      := v_imp_base;
          v_itasa_ini    := v_itasa_inicon;
          v_itasa_fin    := v_itasa_fincon;

        END IF;

        --Reexpresion
        v_imp_reex := v_valor_fincon - v_valor_inicon;

        v_traza := 1;

        --Guardar los valores reexpresados
        BEGIN

          INSERT INTO reexpresiones(cempres, sproces, tiporeexp, freexp, finicial, scontra, ccompani, nversio, ctramo, sproduc, sseguro, nmovimi, tipo,
                                    cmonori, imp_monori, cmondes, imp_mondes_ini, imp_mondes_fin, cmoncon, imp_moncon_ini, imp_moncon_fin, imp_reexp, fcreac, usucrea)
          VALUES (p_cempres, p_sproces, v_tipo_reexp, p_fecreex, NVL(v_fecha_ant, v_fmovimi), p_scontra, p_ccompani, p_nversio, p_ctramo, p_sproduc, p_sseguro, p_nmovimi, p_tipo,
                  v_cmonori, v_importe, v_cmondes, v_valor_ini, v_valor_fin, v_moncon, v_valor_inicon, v_valor_fincon, v_imp_reex, SYSDATE, USER);

        EXCEPTION
          WHEN DUP_VAL_ON_INDEX THEN

            UPDATE reexpresiones
               SET imp_monori     = p_importe,
                   imp_mondes_ini = v_valor_ini,
                   imp_mondes_fin = v_valor_fin,
                   imp_moncon_ini = v_valor_inicon,
                   imp_moncon_fin = v_valor_fincon,
                   imp_reexp      = v_imp_reex
             WHERE sseguro = p_sseguro
               AND nmovimi = p_nmovimi
               AND freexp  = p_fecreex
               AND tipo    = p_tipo
               AND sproces = p_sproces
               AND cmonori = v_cmonori
               AND cmondes = v_cmondes;

          WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, 'p_reexpresion', v_traza,
                                           'Err INSERT INTO reexpresiones:' || p_sproces || ', ' || p_fecreex
                                           || ', ' || p_scontra || ', ' || p_ccompani || ', '
                                           || p_nversio || ', ' || p_ctramo || ', ' || p_sseguro || ', ' || p_nmovimi,
                                           ' SQLERRM = ' || SQLERRM);
            p_error := SQLCODE;
        END;

      END IF;

    END p_reexpresion;

    /***********************************************************************************************
        Procedimiento que reexpresa saldos totales de cierres anteriores

    ********************************************************************************************  */
    PROCEDURE p_reexpresion_totales(p_cempres      IN  NUMBER,
                                    p_sproces      IN  NUMBER,
                                    p_fecreex      IN  DATE,
                                    p_tipo         IN  NUMBER,
                                    p_error        OUT NUMBER) IS
      v_imp_reex     NUMBER;
      v_itasa_inicon eco_tipocambio.itasa%TYPE;
      v_itasa_fincon eco_tipocambio.itasa%TYPE;
      v_valor_inicon NUMBER;
      v_valor_fincon NUMBER;
      v_traza        NUMBER(4);
      v_monconn      parempresas.nvalpar%TYPE;
      v_moncon       monedas.cmonint%TYPE;
      v_moneda_prodn monedas.cmoneda%TYPE;
      v_cmonori      monedas.cmonint%TYPE;
      v_cmondes      monedas.cmonint%TYPE;

      v_tipo            NUMBER;
      v_tipo_reexp      NUMBER;

      CURSOR cierreant IS
        SELECT r.scontra, r.nversio, r.ctramo, r.ccompani, r.sproduc, r.cmonori, r.cmondes,
               (r.imp_monori - NVL(rp.imp_monori,0)) imp_monori,
               (r.imp_mondes_ini - NVL(rp.imp_mondes_ini,0)) imp_mondes_ini,
               (r.imp_mondes_fin - NVL(rp.imp_mondes_fin,0)) imp_mondes_fin,
               (r.imp_moncon_ini - NVL(rp.imp_moncon_ini,0)) imp_moncon_ini,
               (r.imp_moncon_fin - NVL(rp.imp_moncon_fin,0)) imp_moncon_fin,
               r.freexp
          FROM reexpresiones r, (SELECT s.scontra, s.nversio, s.ctramo, s.ccompani, s.sproduc, s.cmonori, s.imp_monori, s.cmondes,
                                        s.imp_mondes_ini, s.imp_mondes_fin, s.imp_moncon_ini, s.imp_moncon_fin, s.freexp
                                   FROM reexpresiones s
                                  WHERE s.cempres   = p_cempres
                                    AND s.tiporeexp = 4 --Saldo Total Cierre
                                    AND s.freexp    BETWEEN TO_DATE('01' || TO_CHAR(p_fecreex,'MM') || TO_CHAR(p_fecreex,'YYYY'), 'DDMMYYYY') AND p_fecreex) rp
         WHERE r.cempres   = p_cempres
           AND r.tiporeexp = 2 --Saldo Total Cierre
           AND r.freexp    = (SELECT MAX(rr.freexp)
                                FROM reexpresiones rr
                               WHERE rr.cempres = r.cempres
                                 AND rr.tiporeexp = r.tiporeexp
                                 AND rr.freexp    < p_fecreex)
           AND r.scontra   = rp.scontra(+)
           AND r.nversio   = rp.nversio(+)
           AND r.ctramo    = rp.ctramo(+)
           AND r.ccompani  = rp.ccompani(+)
           AND r.sproduc   = rp.sproduc(+)
           AND r.cmonori   = rp.cmonori(+)
           AND r.cmondes   = rp.cmondes(+);

      CURSOR cur_pagos IS
        SELECT p.scontra, p.nversio, p.ctramo, p.ccompani, p.sproduc, p.fliquid, SUM(p.iimport_moncon) iimporte_moncon, SUM(p.iimport) iimport
          FROM movctatecnica p
         WHERE p.cempres = p_cempres
           AND p.cconcep = 10 --Saldo liquidado
           AND p.fliquid = p_fecreex
        GROUP BY p.scontra, p.nversio, p.ctramo, p.ccompani, p.sproduc, p.fliquid;

    BEGIN

      p_error   := 0;
      v_monconn := pac_parametros.f_parempresa_n(p_cempres, 'MONEDACONTAB');
      v_moncon  := pac_monedas.f_cmoneda_t(v_monconn);

      v_tipo := p_tipo;

      IF v_tipo = 1 THEN

        v_tipo_reexp := 2; --Saldo de Cierre

        DELETE reexpresiones
         WHERE cempres   = p_cempres
           --AND sproces   = p_sproces
           AND freexp    = p_fecreex
           AND finicial  < p_fecreex
           AND tiporeexp = 2;

        --Reexpresar saldos de cierres anteriores
        FOR c_cie IN cierreant LOOP

          --Recuperar tasa a fecha del ultimo cierre, para Moneda Destino - Moneda Contable
          v_itasa_inicon := pac_eco_tipocambio.f_cambio(c_cie.cmondes,
                                                        v_moncon,
                                                        c_cie.freexp);

          v_valor_inicon := c_cie.imp_mondes_fin * v_itasa_inicon;

          --Recuperar tasa de cambio en fecha de reexpresi£¿, para Moneda destino - Moneda Contable
          v_itasa_fincon := pac_eco_tipocambio.f_cambio(c_cie.cmondes,
                                                        v_moncon,
                                                        p_fecreex);

          v_valor_fincon := c_cie.imp_mondes_fin * v_itasa_fincon;

          --Reexpresion
          v_imp_reex := v_valor_fincon - v_valor_inicon;

          v_traza := 1;

          --Guardar los valores reexpresados
          BEGIN

            INSERT INTO reexpresiones(cempres, sproces, tiporeexp, freexp, finicial, scontra, ccompani, nversio, ctramo, sproduc, sseguro, nmovimi, tipo,
                                      cmonori, imp_monori, cmondes, imp_mondes_ini, imp_mondes_fin, cmoncon, imp_moncon_ini, imp_moncon_fin, imp_reexp, fcreac, usucrea)
            VALUES (p_cempres, p_sproces, v_tipo_reexp, p_fecreex, c_cie.freexp, c_cie.scontra, c_cie.ccompani, c_cie.nversio, c_cie.ctramo, c_cie.sproduc, 0, 0, v_tipo,
                    c_cie.cmonori, c_cie.imp_monori, c_cie.cmondes, c_cie.imp_mondes_ini, c_cie.imp_mondes_fin, v_moncon, c_cie.imp_moncon_ini, c_cie.imp_moncon_fin, v_imp_reex, SYSDATE, USER);

          EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN

              UPDATE reexpresiones
                 SET imp_moncon_ini = v_valor_inicon,
                     imp_moncon_fin = v_valor_fincon,
                     imp_reexp      = v_imp_reex
               WHERE freexp  = p_fecreex
                 AND tipo    = v_tipo
                 AND sproces = p_sproces
                 AND cmonori = c_cie.cmonori
                 AND cmondes = c_cie.cmondes;

            WHEN OTHERS THEN
              p_tab_error(f_sysdate, f_user, 'p_reexpresion_totales', v_traza,
                                             'Err INSERT INTO reexpresiones:' || p_sproces || ', ' || p_fecreex
                                             || ', ' || c_cie.scontra || ', ' || c_cie.ccompani || ', '
                                             || c_cie.nversio || ', ' || c_cie.ctramo,
                                             ' SQLERRM = ' || SQLERRM);
              p_error := SQLCODE;
          END;

        END LOOP;

      ELSIF v_tipo = 2 THEN --En liquidación

        v_tipo_reexp := 4; --Pago Reexpresado

        --Reexpresar pagos realizados
        FOR c_pag IN cur_pagos LOOP

          --Se busca la moneda original del producto
          v_moneda_prodn := pac_monedas.f_moneda_producto(c_pag.sproduc);
          v_cmonori      := pac_monedas.f_cmoneda_t(v_moneda_prodn);

          IF v_cmonori NOT IN ('USD','COP') THEN
            v_cmondes := 'USD';
          ELSE
            v_cmondes := v_moncon;
          END IF;

          --Recuperar tasa a fecha del ultimo cierre, para Moneda Destino - Moneda Contable
          v_itasa_inicon := pac_eco_tipocambio.f_cambio(v_cmondes,
                                                        v_moncon,
                                                        c_pag.fliquid);

          v_valor_inicon := c_pag.iimport * v_itasa_inicon;

          --Recuperar tasa de cambio en fecha de reexpresi£¿, para Moneda destino - Moneda Contable
          v_itasa_fincon := pac_eco_tipocambio.f_cambio(v_cmondes,
                                                        v_moncon,
                                                        p_fecreex);

          v_valor_fincon := c_pag.iimport * v_itasa_fincon;

          --Reexpresion
          v_imp_reex := v_valor_fincon - v_valor_inicon;

          v_traza := 1;

          --Guardar los valores reexpresados
          BEGIN

            INSERT INTO reexpresiones(cempres, sproces, tiporeexp, freexp, finicial, scontra, ccompani, nversio, ctramo, sproduc, sseguro, nmovimi, tipo,
                                      cmonori, imp_monori, cmondes, imp_mondes_ini, imp_mondes_fin, cmoncon, imp_moncon_ini, imp_moncon_fin, imp_reexp, fcreac, usucrea)
            VALUES (p_cempres, p_sproces, v_tipo_reexp, p_fecreex, c_pag.fliquid, c_pag.scontra, c_pag.ccompani, c_pag.nversio, c_pag.ctramo, c_pag.sproduc, 0, 0, v_tipo,
                    v_cmonori, 0, v_cmondes, c_pag.iimport, c_pag.iimport, v_moncon, v_valor_inicon, v_valor_fincon, v_imp_reex, SYSDATE, USER);


          EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN

              UPDATE reexpresiones
                 SET imp_moncon_ini = v_valor_inicon,
                     imp_moncon_fin = v_valor_fincon,
                     imp_reexp      = v_imp_reex
               WHERE freexp  = p_fecreex
                 AND tipo    = v_tipo
                 AND sproces = p_sproces
                 AND cmonori = v_cmonori
                 AND cmondes = v_cmondes;

            WHEN OTHERS THEN
              p_tab_error(f_sysdate, f_user, 'p_reexpresion_totales', v_traza,
                                             'Err INSERT INTO reexpresiones:' || p_sproces || ', ' || p_fecreex
                                             || ', ' || c_pag.scontra || ', ' || c_pag.ccompani || ', '
                                             || c_pag.nversio || ', ' || c_pag.ctramo,
                                             ' SQLERRM = ' || SQLERRM);
              p_error := SQLCODE;
          END;

          --Restar los valores liquidados del total a la fecha, para reexpresar el saldo restante en el siguiente cierre
          FOR c_cie IN cierreant LOOP

            UPDATE reexpresiones
               SET imp_moncon_ini = v_valor_inicon,
                   imp_moncon_fin = v_valor_fincon,
                   imp_reexp      = v_imp_reex
             WHERE freexp  = p_fecreex
               AND tipo    = v_tipo
               AND sproces = p_sproces
               AND cmonori = v_cmonori
               AND cmondes = v_cmondes;

          END LOOP;

        END LOOP;

      END IF;

    END p_reexpresion_totales;

    /***********************************************************************************************
        Procedimiento principal de reexpresiones

    ********************************************************************************************  */
    PROCEDURE p_reexpresion_principal(p_cempres      IN  NUMBER,
                                      p_sproces      IN  NUMBER,
                                      p_fecreex      IN  DATE,
                                      p_error        OUT NUMBER) IS

      CURSOR movimientos IS
      SELECT r.cempres, r.sseguro, r.nmovimi, r.fcierre, r.sproces, r.scontra, r.nversio, r.ctramo, r.ccompani,
             r.sfacult, pcesion, sproduc, s.ccompani ccompapr,
             DECODE(0, 1, DECODE(r.ctramo, 5, r.npoliza, 0), 0) npoliza,
             DECODE(0, 1, DECODE(r.ctramo, 5, r.ncertif, 0), 0) ncertif,
             DECODE(0, 1, DECODE(r.cgenera, 2, nsinies, 0), 0) nsinies,
             DECODE(r.cgenera, 2, 0, 6, 2, 1) cmotces, SUM(icesion) icesion,
             SUM(icomisi) icomisi, SUM(idtosel) idtosel
        FROM reaseguro r, seguros s
       WHERE r.sproces = p_sproces
         AND r.cempres = p_cempres
         AND s.sseguro = r.sseguro
         AND r.ctramo  = 5   -- Solo facultativos
    GROUP BY r.cempres, r.sseguro, r.nmovimi, r.fcierre, r.sproces, r.scontra, r.nversio, r.ctramo, r.ccompani,
             r.sfacult, pcesion, sproduc,
             DECODE(0, 1, DECODE(r.ctramo, 5, r.npoliza, 0), 0),
             DECODE(0, 1, DECODE(r.ctramo, 5, r.ncertif, 0), 0),
             DECODE(0, 1, DECODE(r.cgenera, 2, nsinies, 0), 0),
             DECODE(r.cgenera, 2, 0, 6, 2, 1),
             s.ccompani
    HAVING SUM(icesion) <> 0
       AND DECODE(r.cgenera, 2, 0, 6, 2, 1) IN (1,3) --> Primas
    ORDER BY r.scontra, r.nversio, r.ctramo, r.ccompani, r.sfacult;

    CURSOR cur_reemb(fini DATE,
                     ffin DATE) IS
      SELECT r.cempres, r.sseguro, r.nmovimi, r.fcierre, r.sproces, r.scontra, r.nversio, r.ctramo, r.ccompani,
             r.sfacult, pcesion, sproduc, s.ccompani ccompapr,
             DECODE(r.cgenera, 2, 0, 6, 2, 1) cmotces, SUM(icesion) icesion
        FROM reaseguro r, seguros s
       WHERE r.sproces = p_sproces
         AND r.cempres = p_cempres
         AND s.sseguro = r.sseguro
         AND r.ctramo  = 5   -- Solo facultativos
         AND r.fcierre BETWEEN fini AND ffin
    GROUP BY r.cempres, r.sseguro, r.nmovimi, r.fcierre, r.sproces, r.scontra, r.nversio, r.ctramo, r.ccompani,
             r.sfacult, pcesion, sproduc,
             DECODE(r.cgenera, 2, 0, 6, 2, 1),
             s.ccompani
    HAVING SUM(icesion) <> 0
       AND DECODE(r.cgenera, 2, 0, 6, 2, 1) IN (1,3) --> Primas
    ORDER BY r.scontra, r.nversio, r.ctramo, r.ccompani, r.sfacult;

    CURSOR cur_saldomov(psseguro NUMBER,
                        pnmovimi NUMBER) IS
      SELECT r.sseguro, r.nmovimi, r.fcierre, r.sproces, r.scontra, r.nversio, r.ctramo, r.ccompani,
             SUM(icesion) icesion, SUM(icomisi) icomisi
        FROM reaseguro r, seguros s
       WHERE r.sproces = p_sproces
         AND r.cempres = p_cempres
         AND s.sseguro = r.sseguro
         AND r.sseguro = psseguro
         AND r.nmovimi = pnmovimi - 1 --Movimiento anterior
         AND r.ctramo  = 5   -- Solo facultativos
    GROUP BY r.cempres, r.sseguro, r.nmovimi, r.fcierre, r.sproces, r.scontra, r.nversio, r.ctramo, r.ccompani,
             r.sfacult, pcesion, sproduc,
             DECODE(0, 1, DECODE(r.ctramo, 5, r.npoliza, 0), 0),
             DECODE(0, 1, DECODE(r.ctramo, 5, r.ncertif, 0), 0),
             DECODE(0, 1, DECODE(r.cgenera, 2, nsinies, 0), 0),
             DECODE(r.cgenera, 2, 0, 6, 2, 1),
             s.ccompani
    HAVING SUM(icesion) <> 0
       AND DECODE(r.cgenera, 2, 0, 6, 2, 1) IN (1,3) --> Primas
    ORDER BY r.scontra, r.nversio, r.ctramo, r.ccompani, r.sseguro, r.nmovimi;

    v_icesion  reaseguro.icesion%TYPE;
    v_icomisi  reaseguro.icomisi%TYPE;

  BEGIN

    p_error   := 0;

    DELETE reexpresiones
     WHERE cempres   = p_cempres
       --AND sproces   = p_sproces
       AND freexp    = p_fecreex
       AND tiporeexp = 1;

    --Se reexpresan los movimientos generados durante el proceso de cierre
    FOR c_mov IN movimientos LOOP

      v_icesion := 0;
      v_icomisi := 0;

      IF c_mov.nmovimi > 1 THEN

        FOR c_movant IN cur_saldomov(c_mov.sseguro, c_mov.nmovimi) LOOP

          v_icesion := c_movant.icesion;
          v_icomisi := c_movant.icomisi;
          EXIT;

        END LOOP;

      END IF;

      v_icesion := c_mov.icesion - NVL(v_icesion, 0);
      v_icomisi := c_mov.icomisi - NVL(v_icomisi, 0);
      dbms_output.put_line(v_icesion);

      p_reexpresion(p_cempres,
                    p_sproces,
                    c_mov.sseguro,
                    p_fecreex,
                    c_mov.scontra,
                    c_mov.ccompani,
                    c_mov.nversio,
                    c_mov.ctramo,
                    c_mov.sproduc,
                    c_mov.nmovimi,
                    1, --En Cierre
                    1, --Mvto seguro
                    v_icesion,
                    v_icomisi,
                    c_mov.sfacult,
                    NULL,
                    p_error);

    END LOOP;

    --Se reexpresan los Reembolsos de Reservas
    FOR c_reem IN cur_reemb(ADD_MONTHS(TO_DATE('01/' || TO_CHAR(p_fecreex,'MM') || '/' || TO_CHAR(p_fecreex,'YYYY'), 'dd/mm/yyyy'), -12),
                            ADD_MONTHS(p_fecreex, -12)) LOOP

      p_reexpresion(p_cempres,
                    p_sproces,
                    c_reem.sseguro,
                    p_fecreex,
                    c_reem.scontra,
                    c_reem.ccompani,
                    c_reem.nversio,
                    c_reem.ctramo,
                    c_reem.sproduc,
                    c_reem.nmovimi,
                    1, --En Cierre
                    3, --Reembolso
                    c_reem.icesion,
                    0,
                    c_reem.sfacult,
                    NULL,
                    p_error);
    END LOOP;

    --Se insertan los saldos acumulados para el Cierre/Liquidacion
    DELETE reexpresiones
     WHERE cempres   = p_cempres
       --AND sproces   = p_sproces
       AND freexp    = p_fecreex
       AND tiporeexp = 2;

    INSERT INTO reexpresiones(cempres, sproces, tiporeexp, freexp, finicial, scontra, ccompani, nversio, ctramo, sproduc, sseguro, nmovimi, tipo,
                              cmonori, imp_monori, cmondes, imp_mondes_ini, imp_mondes_fin, cmoncon, imp_moncon_ini, imp_moncon_fin, imp_reexp, fcreac, usucrea)
    SELECT p_cempres, p_sproces, 2, p_fecreex, p_fecreex, r.scontra, r.ccompani, r.nversio, r.ctramo, r.sproduc, 0, 0, 1,
           r.cmonori, SUM(r.imp_monori), r.cmondes, SUM(r.imp_mondes_ini), SUM(r.imp_mondes_fin), r.cmoncon, SUM(r.imp_moncon_ini), SUM(r.imp_moncon_fin), SUM(r.imp_reexp), SYSDATE, USER
      FROM reexpresiones r
     WHERE r.cempres   = p_cempres
       AND r.sproces   = p_sproces
       AND r.tiporeexp IN (1,3) --Mvtos de seguros y Reembolsos
       AND r.freexp    = p_fecreex
    GROUP BY r.scontra, r.ccompani, r.nversio, r.ctramo, r.sproduc, r.cmonori, r.cmondes, r.cmoncon;

    --Se realiza la reexpresi£¿ de los saldos pendientes del cierre anterior
    p_reexpresion_totales(p_cempres,
                          p_sproces,
                          p_fecreex,
                          1, --Cierre
                          p_error);

   END p_reexpresion_principal;

  --CONF-692 Fin

  --CONF-910 Inicio

  /***********************************************************************************************
        Función que indica si una Compañía reaseguradora se encuentra en Cut-Off (1 - SI, 0 - NO)

  ********************************************************************************************  */
  FUNCTION f_compania_cutoff(p_ccompani     IN  NUMBER,
                             p_fecmov       IN  DATE) RETURN NUMBER IS

    v_fbaja  companias.fbaja%TYPE;
    v_res    NUMBER := 0;

  BEGIN

    BEGIN
      SELECT fbaja
        INTO v_fbaja
        FROM companias
       WHERE ccompani =  p_ccompani
         AND TRUNC(fbaja) <= TRUNC(p_fecmov);
    EXCEPTION WHEN OTHERS THEN
      v_fbaja := NULL;
    END;

    IF v_fbaja IS NOT NULL THEN
      v_res := 1;
    END IF;

    RETURN v_res;

  END f_compania_cutoff;

  /***********************************************************************************************
        Función que devuelve el valor total cedido (100%) de acuerdo a las compañías en CutOff

  ********************************************************************************************  */
  FUNCTION f_total_concutoff(p_scontra      IN  NUMBER,
                             p_nversio      IN  NUMBER,
                             p_ctramo       IN  NUMBER,
                             p_fecmov       IN  DATE,
                             p_valor        IN  NUMBER,
                             p_error        OUT NUMBER) RETURN NUMBER IS

    v_fbaja  companias.fbaja%TYPE;
    v_total  NUMBER;
    v_porc   NUMBER;

    CURSOR cur_cesiones IS
      SELECT c.ccompani, c.pcesion
        FROM cuadroces c
       WHERE c.scontra = p_scontra
         AND c.nversio = p_nversio
         AND c.ctramo  = p_ctramo;

  BEGIN

    p_error := 0;

    v_total := 100;
    v_porc  := v_total;

    FOR c_comp IN cur_cesiones LOOP

      IF f_compania_cutoff(c_comp.ccompani, p_fecmov) = 1 THEN
        v_porc := v_porc - c_comp.pcesion;
      END IF;

    END LOOP;

    IF v_total != v_porc THEN
      v_total := ROUND((v_total * p_valor) / v_porc, 2);
    ELSE
      v_total := p_valor;
    END IF;

    RETURN v_total;

  END f_total_concutoff;

  --CONF-910 Fin

  --CONFCC-5 Inicio
  /***********************************************************************************************
        Función que indica si una Compañia reaseguradora está excenta de retención (CERTIFICADO DE RESIDENCIA FISCAL)

  ********************************************************************************************  */
  FUNCTION f_compania_exenta(p_ccompani     IN  NUMBER,
                             p_fecmov       IN  DATE) RETURN NUMBER IS

    v_fbaja  companias.fbaja%TYPE;
    v_res    NUMBER := 0;

    CURSOR cur_compani_exenta IS
      SELECT c.cvalpar
        FROM par_companias_rea c
       WHERE c.ccompani = p_ccompani
         AND c.cparcomp = 'EXENTA_RETENCION'
         AND NVL(c.mcainh,'N') = 'N'
         AND c.cvalpar = 1
         AND p_fecmov BETWEEN c.ffini AND c.fffin;
         /*AND c.fvalidez = (SELECT MAX(b.fvalidez)
                             FROM par_companias_rea b
                            WHERE b.ccompani = c.ccompani
                              AND b.cparcomp = c.cparcomp
                              AND NVL(b.mcainh,'N') = 'N'
                              AND b.cvalpar = b.cvalpar
                              AND b.fvalidez <= p_fecmov);*/

  BEGIN

    --Se busca si la empresa tiene CERTIFICADO DE RESIDENCIA FISCAL (es decir está exenta de retención)
    FOR c_comp IN cur_compani_exenta LOOP

      v_res := 1;
      EXIT;

    END LOOP;

    RETURN v_res;

  END f_compania_exenta;
  --
  /***********************************************************************************************
        Procedimiento que calcula la retención

  ********************************************************************************************  */
  PROCEDURE p_calcula_retencion(p_cempres      IN  NUMBER,
                                p_sseguro      IN  NUMBER,
                                p_cgenera      IN  NUMBER,
                                p_ccompani     IN  NUMBER,
                                p_fecmov       IN  DATE,
                                p_valor        IN  NUMBER,
                                p_valret       OUT NUMBER,
                                p_error        OUT NUMBER) IS

    v_porc       NUMBER;
    v_exenta     NUMBER;
    v_fec_aplica DATE;
    v_fec_ini    DATE;

    CURSOR cur_expedicion_poliza IS
      SELECT m.fmovimi
        FROM movseguro m
       WHERE m.sseguro = p_sseguro
         AND m.nmovimi = 1;

  BEGIN

    p_error  := 0;
    v_exenta := 0;
    p_valret := 0;

    --Si para la empresa aplica la retención en primas cedidas
    IF NVL(pac_parametros.f_parempresa_n(p_cempres, 'APLICA_RET_PRIMAS'), 0 ) = 1
    THEN

      v_porc := NVL(pac_parametros.f_parempresa_n(p_cempres, 'PORC_RET_PRIMAS'), 0);

      IF v_porc > 0 THEN

        --Se busca la fecha de emisión de la póliza
        IF p_sseguro IS NOT NULL
        THEN
          FOR c_fini IN cur_expedicion_poliza LOOP
            v_fec_ini := c_fini.fmovimi;
          END LOOP;
        END IF;

        v_fec_ini := NVL(v_fec_ini, p_fecmov);

        v_exenta := f_compania_exenta(p_ccompani,
                                      v_fec_ini);

        IF v_exenta != 1
        THEN
          IF p_cgenera IN (3,4,6,7)
            OR p_cgenera IS NULL
          THEN
            v_fec_aplica := pac_parametros.f_parempresa_f(p_cempres, 'FEC_APLICA_RET');

            --Si la fecha del movimiento es mayor o igual a la fecha desde la que aplica la retención
            IF v_fec_ini >= v_fec_aplica
            THEN

              p_valret := p_valor * v_porc / 100;

            END IF;
          END IF;
        END IF;

      END IF;

    END IF;

  END p_calcula_retencion;
  --
  --CONFCC-5 Fin
  --INI BUG 13164 22/05/2020 MPC Se extrae detalle analizado de tabla sin_tramita_reservadet.
  PROCEDURE p_ins_liqresreaauxdet
  IS
  --
  v_obj VARCHAR2(100) := 'PAC_REASEGURO_REC.p_ins_liqresreaauxdet';
  --
  BEGIN
    --
    --@P_CONTROL_ERROR('MPC',v_obj,'ENTRO');
    v_cesdet.falta    := F_SYSDATE;
    v_cesdet.cusualta := F_USER;
    --
    INSERT INTO liqresreaauxdet
         VALUES v_cesdet;
    --
    --@P_CONTROL_ERROR('MPC',v_obj,'FIN');
  EXCEPTION WHEN OTHERS 
  THEN
     --
     p_tab_error(f_sysdate, f_user, v_obj, 1,
                     'ERROR INSERT:' || v_cesdet.nsinies || ', '|| v_cesdet.nversio || ', ' || v_cesdet.scontra || ', ' || v_cesdet.ctramo,
                     ' SQLERRM = ' || SQLERRM);
     --
  END p_ins_liqresreaauxdet;
  --
  PROCEDURE p_upd_liqresreaauxdet
  IS
  --
  v_obj VARCHAR2(100) := 'PAC_REASEGURO_REC.p_upd_liqresreaauxdet';
  --
  BEGIN
    --
    --@P_CONTROL_ERROR('IBNR_UP',v_obj,'ENTRO v_cesdet.nsinies:'||v_cesdet.nsinies||' v_cesdet.sproces:'||v_cesdet.sproces||' v_cesdet.fcierre:'||v_cesdet.fcierre);
    --
    UPDATE liqresreaauxdet
       SET  iresperio            = v_cesdet.iresperio,
            iresperio_moncia     = v_cesdet.iresperio_moncia,   
            iresperio_moncia_c   = v_cesdet.iresperio_moncia_c,            
            isalres              = v_cesdet.isalres,             
            isalres_moncia       = v_cesdet.isalres_moncia,      
            isalres_moncia_c     = v_cesdet.isalres_moncia_c,    
            isalresaant          = v_cesdet.isalresaant,         
            isalresaant_moncia   = v_cesdet.isalresaant_moncia,  
            isalresaant_moncia_c = v_cesdet.isalresaant_moncia_c,
            isalresaact          = v_cesdet.isalresaact,         
            isalresaact_moncia   = v_cesdet.isalresaact_moncia,  
            isalresaact_moncia_c = v_cesdet.isalresaact_moncia_c,
            iconstres            = v_cesdet.iconstres,           
            iconstres_moncia     = v_cesdet.iconstres_moncia,    
            iconstres_moncia_c   = v_cesdet.iconstres_moncia_c,  
            iaumenres            = v_cesdet.iaumenres, 
            iaumenres_moncia     = v_cesdet.iaumenres_moncia,           
            iaumenres_moncia_c   = v_cesdet.iaumenres_moncia_c,  
            iliberares           = v_cesdet.iliberares,          
            iliberares_moncia    = v_cesdet.iliberares_moncia,   
            iliberares_moncia_c  = v_cesdet.iliberares_moncia_c, 
            idismires            = v_cesdet.idismires,           
            idismires_moncia     = v_cesdet.idismires_moncia,    
            idismires_moncia_c   = v_cesdet.idismires_moncia_c,
            ctiprea              = v_cesdet.ctiprea,
            cmonres              = v_cesdet.cmonres   
     WHERE nsinies  = v_cesdet.nsinies
       AND cgarant  = v_cesdet.cgarant
       AND ccompani = v_cesdet.ccompani
       AND scontra  = v_cesdet.scontra
       AND nversio  = v_cesdet.nversio
       AND nanyo    = v_cesdet.nanyo
       AND ctramo   = v_cesdet.ctramo
       AND fcierre  = v_cesdet.fcierre
       AND sproces  = v_cesdet.sproces;
    --
    COMMIT;
    --
    --@P_CONTROL_ERROR('IBNR',v_obj,'FIN');
  EXCEPTION WHEN OTHERS 
  THEN
     --
     p_tab_error(f_sysdate, f_user, v_obj, 1,
                     'ERROR UPDATE:' || v_cesdet.nsinies || ', '|| v_cesdet.nversio || ', ' || v_cesdet.scontra || ', ' || v_cesdet.ctramo,
                     ' SQLERRM = ' || SQLERRM);
     --
  END p_upd_liqresreaauxdet;
  --
  FUNCTION f_calc_cesionesaux(pnsinies NUMBER, 
                               pcgarant NUMBER,
                               pscontra NUMBER,
                               pimpres  NUMBER,
                               pcempres NUMBER,
                               pffin    DATE)
  RETURN NUMBER IS
  w_param         NUMBER := 1;
  v_scontra       cesionesrea.scontra%TYPE;
  v_obj           VARCHAR2(100) := 'PAC_REASEGURO_REC.F_CALC_CESIONESAUX';
  v_param         VARCHAR2(4000) := 'PARAM pnsinies:'||pnsinies||' pcgarant:'||pcgarant||' pscontra:'||pscontra||' pimpres:'||pimpres||' pcempres:'||pcempres||' pffin:'||pffin;
  v_nversio       cesionesrea.nversio%TYPE;
  v_any           NUMBER;
  v_error         NUMBER;
  v_experr        VARCHAR2(32000);
  v_pcesion       cesionesrea.pcesion%TYPE;
  v_porrea        reamovpagos.ppropio%TYPE := 0;   
  --
  CURSOR c_companias(pc_scontra IN NUMBER,
                     pc_nversio IN NUMBER,
                     pc_ctramo  IN NUMBER,
                     pc_sseguro IN NUMBER,
                     pc_fsinies IN DATE) 
  IS
  SELECT ccompani, pcesion
    FROM cuadroces
   WHERE pc_ctramo <> 5
     AND scontra = pc_scontra
     AND nversio = pc_nversio
     AND ctramo = pc_ctramo
  UNION
  SELECT cc.ccompani, cc.pcesion
    FROM cuacesfac cc, cuafacul c
   WHERE pc_ctramo = 5
     AND c.sseguro = pc_sseguro
     AND cc.sfacult = c.sfacult
     AND c.finicuf <= pc_fsinies
     AND(c.ffincuf > pc_fsinies
         OR c.ffincuf IS NULL);
  --
  CURSOR c_tramo(pc_sseguro IN NUMBER,
                 pc_fsinies IN DATE,
                 pc_nriesgo IN NUMBER,
                 pc_cgarant IN NUMBER,
                 pc_param   IN NUMBER) 
  IS
  SELECT scontra, nversio, ctramo, sfacult, pcesion, sseguro
    FROM cesionesrea
   WHERE sseguro = pc_sseguro
     AND cgenera IN(1, 3, 4, 5, 9, 40)
     AND nriesgo = pc_nriesgo
     AND(   (    pc_param = 1
             AND cgarant IS NOT NULL
             AND cgarant = pc_cgarant)
          OR(    pc_param = 2
              AND cgarant IS NULL)
          OR(    pc_param = 3
              AND(   pc_cgarant = 9999
                  OR pc_cgarant = 9998)))
      AND fefecto <= pc_fsinies
      AND fvencim > pc_fsinies
      AND(   fregula IS NULL
          OR fregula > pc_fsinies)
      AND(   fanulac IS NULL
          OR fanulac > pc_fsinies)
      AND ctramo > 0
      AND ctramo < 6;
  --
  CURSOR c_sini(pc_nsinies sin_siniestro.nsinies%TYPE)
  IS
  SELECT *
    FROM sin_siniestro
   WHERE nsinies = pc_nsinies;
  --
  l_sini c_sini%ROWTYPE;
  --
  BEGIN
    --
    P_CONTROL_ERROR('MPC',v_obj,'ENTRO');
    v_scontra := pscontra;
    --
    OPEN c_sini(pnsinies);
    --
    FETCH c_sini
     INTO l_sini;
    --
    CLOSE c_sini;
    --
    WHILE w_param < 4 
    LOOP
       --
       v_scontra := NULL;
       --
       FOR r_tramo IN c_tramo(l_sini.sseguro, l_sini.fsinies,l_sini.nriesgo, pcgarant, w_param) 
       LOOP
          --
          w_param := 5;
          --
          IF v_scontra IS NULL
             OR(    v_scontra IS NOT NULL
                AND r_tramo.scontra = v_scontra) 
          THEN
             --
             v_scontra := r_tramo.scontra;
             v_nversio := r_tramo.nversio;
             v_any := 0;
             v_error := anyo_contrato(r_tramo.scontra, r_tramo.nversio, r_tramo.sfacult, v_experr);
             --
             IF v_error = 0 
             THEN
                --
                v_error := buscar_tipocon(r_tramo.scontra, v_experr);
                --
                IF v_error = 0 
                THEN
                   --
                   v_pcesion := r_tramo.pcesion;
                   --
                    IF v_error = 0 
                    THEN
                       --
                       v_porrea := v_porrea + v_pcesion;
                       FOR r_companias IN c_companias(r_tramo.scontra,
                                                      r_tramo.nversio,
                                                      r_tramo.ctramo,
                                                      r_tramo.sseguro,
                                                      l_sini.fsinies) 
                       LOOP
                          --
                          v_cesdet.scontra       := r_tramo.scontra;
                          v_cesdet.nversio       := r_tramo.nversio;
                          v_cesdet.nanyo         := v_any;
                          v_cesdet.ctramo        := r_tramo.ctramo;
                          v_cesdet.pcedido_total := r_tramo.pcesion;
                          v_cesdet.ccompani      := r_companias.ccompani;
                          v_cesdet.pcedido_cia   := r_companias.pcesion;
                          v_cesdet.isalres       := pimpres;
                          v_cesdet.ctipram       := vtipram;
                          --
                          p_ins_liqresreaauxdet;
                          --
                          IF v_error != 0 
                          THEN
                             --
                             v_experr := v_error || ' : ' || v_experr;
                             v_error := 0;
                             --
                           END IF;
                           --
                           COMMIT;
                           --
                       END LOOP;
                       --
                    END IF;
                    --
                 END IF;
                 --
              END IF;
              --
              IF v_error != 0 
              THEN
                 --
                 v_experr := v_error || ' : ' || v_experr;
                 --
                 v_error := 0;
                 --
              END IF;
              --
           END IF;
           --
        END LOOP;
        --
        w_param := w_param + 1;
        --
     END LOOP;
     --
     --@P_CONTROL_ERROR('MPC',v_obj,'FIN');
     RETURN 0;
     --
  EXCEPTION WHEN OTHERS 
  THEN
     --
     RETURN 1;
     --
     p_tab_error(f_sysdate, f_user,v_obj, 1, v_param||
                     ' ERROR: nversio:' || v_cesdet.nversio || ' scontra:' || v_cesdet.scontra || ' ctramo:' || v_cesdet.ctramo,
                     ' SQLERRM = ' || SQLERRM);
     --
  END f_calc_cesionesaux;
  --
  FUNCTION f_ext_sintramitareservadet(psproces IN NUMBER,
                                      pcempres IN NUMBER,
                                      pffin    IN DATE,
                                      pnsinies IN NUMBER DEFAULT NULL,
                                      pbandera IN NUMBER DEFAULT 0)
      RETURN NUMBER IS
  --
  v_obj            VARCHAR2(100)  := 'PAC_REASEGURO_REC.f_ext_sintramitareservadet';
  v_param          VARCHAR2(4000) := 'PARAM psproces:'||psproces||' pcempres:'||pcempres||' pffin:'||pffin||' pnsinies:'||pnsinies||' pbandera:'||pbandera;
  v_finicierre_ant DATE;
  v_ffincierre_ant DATE;
  v_fini           DATE;
  v_error          NUMBER;
  v_experr         VARCHAR2(32000);
  v_anyo_ant       NUMBER;
  v_anyo_act       NUMBER;
  v_ncuacoa        sin_siniestro.ncuacoa%TYPE;
  v_ctipcoa        seguros.ctipcoa%TYPE;
  v_ploccoa        coacuadro.ploccoa%TYPE;
  v_cpagcoa        pagosini.cpagcoa%TYPE;
  apl_coa_prov     BOOLEAN;
  apl_coa_pag      BOOLEAN;
  --
  CURSOR c_movres(pc_nsinies NUMBER,
                  pc_cgarant NUMBER,
                  pc_fini    DATE,
                  pc_ffin    DATE)
  IS
  SELECT NVL(SUM(NVL(iconstres,0)),0)          iconstres,
         NVL(SUM(NVL(iconstres_moncia,0)),0)   iconstres_moncia,
         NVL(SUM(NVL(iaumenres,0)),0)          iaumenres,
         NVL(SUM(NVL(iaumenres_moncia,0)),0)   iaumenres_moncia,
         NVL(SUM(NVL(iliberares,0)),0)         iliberares,
         NVL(SUM(NVL(iliberares_moncia,0)),0)  iliberares_moncia,
         NVL(SUM(NVL(idismires,0)),0)          idismires,
         NVL(SUM(NVL(idismires_moncia,0)),0)   idismires_moncia
    FROM sin_tramita_reservadet t,
         sin_tramita_reserva s
   WHERE t.nsinies = pc_nsinies
     AND NVL(s.cgarant,-1) = NVL(pc_cgarant,-1)
     AND s.ctipres NOT IN (5)
     AND t.nsinies = s.nsinies
     AND t.idres   = s.idres
     AND t.nmovres = s.nmovres
     AND t.cmonres = s.cmonres
     AND s.fmovres BETWEEN pc_fini AND pc_ffin;
  --
  CURSOR c_itotalres(pc_nsinies NUMBER,
                     pc_cgarant NUMBER,
                     pc_fini DATE,
                     pc_ffin DATE,
                     pc_bandera NUMBER DEFAULT NULL)
  IS
  SELECT NVL(SUM(NVL(t.isalres,0)),0)            isalres,
         NVL(SUM(NVL(t.isalres_moncia,0)),0)     isalres_moncia,
         NVL(SUM(NVL(t.isalresaant,0)),0)        isalresaant,
         NVL(SUM(NVL(t.isalresaant_moncia,0)),0) isalresaant_moncia,
         NVL(SUM(NVL(t.isalresaact,0)),0)        isalresaact,
         NVL(SUM(NVL(t.isalresaact_moncia,0)),0) isalresaact_moncia
    FROM sin_tramita_reservadet t,
         sin_tramita_reserva s
   WHERE t.nsinies = pc_nsinies
     AND NVL(s.cgarant,-1) = NVL(pc_cgarant,-1)
     AND s.ctipres NOT IN (5)
     AND t.nsinies = s.nsinies
     AND t.idres   = s.idres
     AND t.nmovres = s.nmovres
     AND t.nmovres = (SELECT MAX(nmovres)
                        FROM sin_tramita_reserva
                       WHERE nsinies = t.nsinies
                         AND idres   = t.idres
                         AND cmonres = t.cmonres
                         AND fmovres <= pc_ffin)
     AND t.nmovresdet = (SELECT MAX(nmovresdet)
                           FROM sin_tramita_reservadet
                          WHERE nsinies = t.nsinies
                            AND idres   = t.idres
                            AND nmovres = t.nmovres
                            AND cmonres = t.cmonres)
     AND (s.fmovres BETWEEN pc_fini AND pc_ffin
          OR pc_bandera = 1
          OR (    pc_bandera = 2
              AND s.fmovres <= pc_ffin));
  --
  CURSOR c_d_principal(pc_nsinies NUMBER)
  IS
  SELECT *
    FROM liqresreaauxdet t
   WHERE sproces = psproces
     AND fcierre = pffin
     AND (   pc_nsinies IS NULL
          OR nsinies = nsinies);
  --
  l_itotalres      c_itotalres%ROWTYPE;
  l_itotalres_ant  c_itotalres%ROWTYPE;
  l_movres         c_movres%ROWTYPE;
  --
  BEGIN
    --
    --@P_CONTROL_ERROR('MPC',v_obj,'ENTRO');
    v_fini := TO_DATE('01/'||TO_CHAR(pffin,'MM/YYYY'),'DD/MM/YYYY');
    v_finicierre_ant := ADD_MONTHS(v_fini,-1);
    v_ffincierre_ant := LAST_DAY(v_finicierre_ant);
    --
    IF pbandera = 1
    THEN
       --
       v_error := f_calc_cesionesaux(pnsinies,v_cesdet.cgarant,NULL,v_cesdet.isalres,pcempres,pffin);
       RETURN 0;
       --
    END IF;
    --
    FOR i IN c_d_principal(pnsinies)
    LOOP
      --
      v_cesdet := i;
      --
      BEGIN
         SELECT ncuacoa
           INTO v_ncuacoa
           FROM sin_siniestro
          WHERE nsinies = v_cesdet.nsinies;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            SELECT ncuacoa
              INTO v_ncuacoa
              FROM siniestros
             WHERE nsinies = v_cesdet.nsinies;
      END;
      --
      v_error := pac_llibsin.datos_coa_sin(v_cesdet.sseguro, v_ncuacoa, v_ctipcoa, v_ploccoa);
      --
      IF v_error <> 0 
      THEN
         --
         p_tab_error(f_sysdate, f_user,v_obj, 1, v_param||
                     'pac_llibsin.datos_coa_sin sproces:'||v_cesdet.sproces||' nsinies:'||v_cesdet.nsinies||' ERROR:'||v_error,
                     ' SQLERRM = ' || SQLERRM);
         --@p_control_error('IBNR',v_obj,'pac_llibsin.datos_coa_sin sproces:'||v_cesdet.sproces||' nsinies:'||v_cesdet.nsinies||' ERROR:'||v_error);
         --
      END IF;
      --
      v_error := pac_llibsin.valida_aplica_coa(v_ctipcoa, v_cesdet.nsinies, v_cpagcoa, apl_coa_prov, apl_coa_pag);
      --
      IF v_error <> 0 
      THEN
         --
         p_tab_error(f_sysdate, f_user,v_obj, 1, v_param||
                     'pac_llibsin.valida_aplica_coa sproces:'||v_cesdet.sproces||' nsinies:'||v_cesdet.nsinies||' ERROR:'||v_error,
                     ' SQLERRM = ' || SQLERRM);
         --@p_control_error('IBNR',v_obj,'pac_llibsin.valida_aplica_coa sproces:'||v_cesdet.sproces||' nsinies:'||v_cesdet.nsinies||' ERROR:'||v_error);
         --
      END IF;
      --
      v_error := buscar_tipocon(i.scontra, v_experr);
      --
      BEGIN
        --
        SELECT NVL(ctiprea,0)
          INTO v_cesdet.ctiprea 
          FROM companias 
         WHERE ccompani = i.ccompani;
        --
      EXCEPTION WHEN OTHERS THEN
        --
        p_tab_error(f_sysdate, f_user,v_obj, 1, v_param||
                     'NSINIES:'||I.NSINIES||' COMPANI:'||I.CCOMPANI||'ERROR01:'||SQLERRM,
                     ' SQLERRM = ' || SQLERRM);
        --@P_CONTROL_ERROR('IBNR',v_obj,'NSINIES:'||I.NSINIES||' COMPANI:'||I.CCOMPANI||'ERROR01:'||SQLERRM);
        --
      END;
      --
      BEGIN
        --
        SELECT DISTINCT cmonres
          INTO v_cesdet.cmonres 
          FROM sin_tramita_reserva
         WHERE nsinies = i.nsinies;
      --
      EXCEPTION WHEN OTHERS THEN
        --
        p_tab_error(f_sysdate, f_user,v_obj, 1, v_param||
                    'NSINIES:'||I.NSINIES||' COMPANI:'||I.CCOMPANI||'ERROR02:'||SQLERRM,
                     ' SQLERRM = ' || SQLERRM);
        --@P_CONTROL_ERROR('IBNR',v_obj,'NSINIES:'||I.NSINIES||' COMPANI:'||I.CCOMPANI||'ERROR02:'||SQLERRM);
        --
      END;
      --
      l_itotalres     := NULL;
      l_itotalres_ant := NULL;
      --
      OPEN c_itotalres(i.nsinies,i.cgarant, v_fini, pffin, 1);
      --
      FETCH c_itotalres INTO l_itotalres;
      --
      CLOSE c_itotalres;
      --
      OPEN c_itotalres(i.nsinies,i.cgarant, v_finicierre_ant, v_ffincierre_ant, 2);
      --
      FETCH c_itotalres INTO l_itotalres_ant;
      --
      CLOSE c_itotalres;
      --
      v_cesdet.isalres_moncia       := l_itotalres.isalres_moncia;
      --
      l_movres := NULL;
      --
      OPEN c_movres(i.nsinies,i.cgarant, v_fini, pffin);
      --
      FETCH c_movres INTO l_movres;
      --
      CLOSE c_movres;
      --
      v_cesdet.iconstres           := l_movres.iconstres;
      v_cesdet.iconstres_moncia    := l_movres.iconstres_moncia;
      v_cesdet.iaumenres           := l_movres.iaumenres;
	    v_cesdet.iaumenres_moncia    := l_movres.iaumenres_moncia;
      v_cesdet.iliberares          := l_movres.iliberares;
      v_cesdet.iliberares_moncia   := l_movres.iliberares_moncia;
      v_cesdet.idismires           := l_movres.idismires;
      v_cesdet.idismires_moncia    := l_movres.idismires_moncia;
      --PERIODO ACTUAL DE CIERRE
      v_cesdet.iresperio           := l_itotalres.isalresaact - l_itotalres_ant.isalresaact;
      v_cesdet.iresperio_moncia    := (l_itotalres.isalresaact_moncia - l_itotalres_ant.isalresaact_moncia);
      --
      --ANO ANTERIOR
      v_cesdet.isalresaant          := l_itotalres.isalresaant + v_cesdet.iliberares ;
      v_cesdet.isalresaant_moncia   := l_itotalres.isalresaant_moncia + v_cesdet.iliberares_moncia;
      --
      --SOLO ANIO ACTUAL HASTA EL CIERRE ANTERIOR ES DECIR SE EXCLUYE LO DEL ANIO ANTERIOR.
      v_cesdet.isalresaact          := l_itotalres.isalresaact - (v_cesdet.iconstres + v_cesdet.iaumenres - v_cesdet.idismires);
      v_cesdet.isalresaact_moncia   := l_itotalres.isalresaact_moncia - (v_cesdet.iconstres_moncia + v_cesdet.iaumenres_moncia - v_cesdet.idismires_moncia);
      --
      IF apl_coa_prov = TRUE 
      THEN
         --
         v_cesdet.isalres_moncia_c     := (((((v_cesdet.isalres_moncia * v_ploccoa)/100)*i.pcedido_total)/100) * i.pcedido_cia)/100;
         v_cesdet.isalresaant_moncia_c := (((((v_cesdet.isalresaant_moncia * v_ploccoa)/100)*i.pcedido_total)/100) * i.pcedido_cia)/100;
         v_cesdet.iconstres_moncia_c   := (((((v_cesdet.iconstres_moncia * v_ploccoa)/100) * i.pcedido_total)/100) * i.pcedido_cia)/100;
         v_cesdet.iaumenres_moncia_c   := (((((v_cesdet.iaumenres_moncia * v_ploccoa)/100) * i.pcedido_total)/100) * i.pcedido_cia)/100;
         v_cesdet.iliberares_moncia_c  := (((((v_cesdet.iliberares_moncia * v_ploccoa)/100) * i.pcedido_total)/100) * i.pcedido_cia)/100;
         v_cesdet.idismires_moncia_c   := (((((v_cesdet.idismires_moncia * v_ploccoa)/100) * i.pcedido_total)/100) * i.pcedido_cia)/100;
         v_cesdet.iresperio_moncia_c   := (((((v_cesdet.iresperio_moncia * v_ploccoa)/100) * i.pcedido_total)/100) * i.pcedido_cia)/100;
         v_cesdet.isalresaact_moncia_c := (((((v_cesdet.isalresaact_moncia * v_ploccoa)/100) * i.pcedido_total)/100) * i.pcedido_cia)/100;
         --
      ELSE
         --
         v_cesdet.isalres_moncia_c     := (((v_cesdet.isalres_moncia * i.pcedido_total)/100) * i.pcedido_cia)/100;
         v_cesdet.isalresaant_moncia_c := (((v_cesdet.isalresaant_moncia * i.pcedido_total)/100) * i.pcedido_cia)/100;
         v_cesdet.iconstres_moncia_c   := (((v_cesdet.iconstres_moncia * i.pcedido_total)/100) * i.pcedido_cia)/100;
         v_cesdet.iaumenres_moncia_c   := (((v_cesdet.iaumenres_moncia * i.pcedido_total)/100) * i.pcedido_cia)/100;
         v_cesdet.iliberares_moncia_c  := (((v_cesdet.iliberares_moncia * i.pcedido_total)/100) * i.pcedido_cia)/100;
         v_cesdet.idismires_moncia_c  := (((v_cesdet.idismires_moncia * i.pcedido_total)/100) * i.pcedido_cia)/100;
         v_cesdet.iresperio_moncia_c  := (((v_cesdet.iresperio_moncia * i.pcedido_total)/100) * i.pcedido_cia)/100;
         v_cesdet.isalresaact_moncia_c := (((v_cesdet.isalresaact_moncia * i.pcedido_total)/100) * i.pcedido_cia)/100;
         --
      END IF;
      --
      p_upd_liqresreaauxdet;
      --
    END LOOP;
    --
    --@P_CONTROL_ERROR('IBNR',v_obj,'FIN');
    COMMIT;
    RETURN 0;
    --
  EXCEPTION WHEN OTHERS THEN
    --
    p_tab_error(f_sysdate, f_user,v_obj, 1, v_param, ' SQLERRM = ' || SQLERRM);
    --@P_CONTROL_ERROR('IBNR',v_obj,'ERROR:'||SQLERRM);
    --
  END f_ext_sintramitareservadet;
  --
  --FIN BUG 13164 22/05/2020 MPC Se extrae detalle analizado de tabla sin_tramita_reservadet.
END pac_reaseguro_rec;

/
