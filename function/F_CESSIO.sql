--------------------------------------------------------
--  DDL for Function F_CESSIO
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "AXIS"."F_CESSIO" (psproces IN NUMBER, pmotiu IN NUMBER, pmoneda IN NUMBER,
pfdatagen IN DATE DEFAULT f_sysdate)
   RETURN NUMBER IS
   /***********************************************************************
      F_CESSIO       : Fer cessions de reassegurança per totes
                       les garanties d'una pòlissa determinada.
                       Parteix de l'informació que hi ha a la
                       taula auxiliar CESIONESAUX (omplert per
                       la funció f_buscactrrea).
                       Estat (cestado) del registres a CESIONESAUX:
                       0 - Registre inicial, a refondre ...
                       1 - Registres ja refosos...
                       2 - Registres per els que es pot fer la cessió...
                       Si la funció torna un perr 99, significa que hi
                       ha un facultatiu pendent i que no s'ha fet la
                       cessió...
   REVISIONES:
         Ver        Fecha        Autor             Descripción
         ---------  ----------  -------  -------------------------------------
         1.0        XX/XX/XXXX   XXX     1. Creación de la función.
         2.0        18/03/2010   AVT     2. 12682: CRE996 - Creación de producto Credit Vida Privats
         3.0        07/04/2010   AVT     3. 13946: CRE200 - Incidencia cartera - pólizas retenidas por facultativo
         4.0        03/05/2010   AVT     4. 14400: CRE203 - Pólizas de Saldo Deutors paradas por cúmulo/facultativo
         5.0        14/05/2010   AVT     5. 14536: CRE200 - Reaseguro: Se requiere que un contrato se pueda utilizar
                                                   en varias agrupaciones de producto
         6.0        26/05/2010   AVT     6. 14404: CIV200 - ERROR EN CAPITALES CEDIDOS DE REASEGURO
         7.0        30/07/2010   AVT     7. 15590: CRE800 - Quadres facultatius
         8.0        08/10/2010   AVT     8. 16263: AGA003 - Error de definición de los contratos de reaseguro de los
                                                   productos de hogar y comunidades
         9.0        20/12/2011   JGR     9. 20606: LCOL_T004-LCOL_T001- Recalcul de les cessions per cúmul amb facultatiu - Nota:0101205
        10.0        02/01/2012   AVT    10. 19484: LCOL_T001: Retención por facultativo antes de emitir la propuesta: ajustar quan hi ha més d'un q.fac
        11.0        06/03/2012   AVT    11. 21559: LCOL999-Cambios en el Reaseguro: Distribución de los Capitales con base en la garantía principal
        12.0        14/05/2012   AVT    12. 22237: LCOL_A002-Incidencias de QT sobre el reaseguro proporcional QT:4564
        13.0        25/07/2012   AVT    13. 22686: LCOL_A004-Cumulos anulados anteriormente a la alta de polizas
        14.0        27/07/2012   GAG    14. 0022666: LCOL_A002-Qtracker: 0004556: Cesion capitales en riesgo
        15.0        13/08/2012   AVT    15. 22660: CALI003-Incidencies amb el contracte de la reasseguran
        16.0        15/02/2013   DCT    16. 0025502: LCOL_T020-Qtracker: 0005655: Validacion campos pantalla facultativos
        17.0        04/03/2013   KBR    17. 0026142: LCOL_A004-Qtracker: 6428: Error al emitir certificado cero después de realizar un supl en un certif individual
        18.0        14/03/2013   KBR    18. 0026283: Incidencia de cúmulo para colectivos Liberty
        19.0        07/08/2013   AVT    19. 0026663: POSPG400-(POSPG400)- Parametrizacion Reaseguro, Coaseguro - Parametrizacion contratos
        20.0        16/10/2013   MMM    20. 0026194_NOTA_0156003_Qtracker 0006484 Cesion de prima por emision
        21.0        28/10/2013   AVT    21. 0028492: LCOLF3BREA-Revisi?n de los contratos de REASEGURO F3B (NOTA:0156038)
        22.0        29/11/2013   MMM    22. 0028082 LCOL_A004-0008810 CLF2-4054 LISTADOS DE PRIMAS CEDIDAS VIDA PROPORCIONAL
        23.0        03/04/2014   DCT    23. 0030326: LCOL_A004-Qtracker: 11612 y 11610 (11903)
        24.0        08/04/2014   AGG    24. Se añaden trazas de proceso
        25.0        25/04/2014   AGG    25. Adaptación del proceso para los cambios requeridos por Positiva
        26.0        08/05/2014   AGG    26. 0026622: POSND100-(POSDE400)-Desarrollo-GAPS Reaseguro, Coaseguro -Id 97 - Comisiones calculadas solo sobre extraprima
        27.0        25/07/2014   DCT    27. 0032363: LCOL_PROD-QT 0013676: La solicitud de poliza No 30063906 hizo cesion sin haber sido emitida y en estado anulada
        28.0        18/09/2014   AVT    28. 0031921: LCOL_A004-Qtracker: 0013142: Validar Límites de Contratos
        29.0        02/09/2016   HRE    29. CONF-250: Se incluye manejo de contratos Q1, Q2, Q3
        30.0        20/01/2017   HRE    30. CONF-479: Suplemento aumento de valor
		31.0        04/12/2019   INFORCOL 31. Reaseguro Fase 1 Ajustes en facultativo para RC
        32.0        06/05/2020   INFORCOL 32. Bug 10555-10556 Reaseguro Ajustes para facultativo Dolares/Euros
        33.0        26/05/2020   DFRP   33.IAXIS-5361: Modificar el facultativo antes de la emisión
   ***********************************************************************/
   lpleno         NUMBER;
   lnmovigen      cesionesrea.nmovigen%TYPE;
   perr           NUMBER := 0;
   codi_error     NUMBER;
   w_fconini      cesionesaux.fconini%TYPE;
   w_dias         NUMBER;
   w_iprirea      cesionesrea.icesion%TYPE;
   w_ipritarrea   cesionesrea.ipritarrea%TYPE;
   w_idtosel      cesionesrea.idtosel%TYPE;
   w_iextrea      cesionesrea.iextrea%TYPE;   --BUG 30326/171842 - DCT - 03/04/2014
   w_iextrap      cesionesrea.iextrap%TYPE;   --BUG 30326/171842 - DCT - 03/04/2014
   w_icomext      cesionesrea.icomext%TYPE;   --GAP 97 Positiva 07/05/2014 AGG
   w_spleno       codicontratos.spleno%TYPE;
   w_ipleno       cesionesaux.ipleno%TYPE;
   w_ccalif1      cesionesaux.ccalif1%TYPE;
   w_ccalif2      cesionesaux.ccalif2%TYPE;
   w_icapital     cesionesaux.icapital%TYPE;
   w_cgarant      garanpro.cgarant%TYPE;
   w_trobat       NUMBER(1);
   w_nriesgo      cesionesaux.nriesgo%TYPE;
   w_scontra      cesionesaux.scontra%TYPE;
   w_nversio      cesionesaux.nversio%TYPE;
   w_scumulo      cesionesaux.scumulo%TYPE;
   cum_capital    cesionesaux.icapital%TYPE;
   w_icapaci      contratos.icapaci%TYPE;
   w_ctiprea      seguros.ctiprea%TYPE;
   w_nplenos      tramos.nplenos%TYPE;
   w_cestado      NUMBER(2);
   pfacult        cuafacul.sfacult%TYPE;
   pncesion       cuafacul.ncesion%TYPE;
   w_plocal       cuafacul.plocal%TYPE;
   w_sproces      cesionesaux.sproces%TYPE;
   w_sseguro      seguros.sseguro%TYPE;
   w_nmovimi      cesionesaux.nmovimi%TYPE;
   w_pcedido      contratos.pcedido%TYPE;
   w_cduraci      seguros.cduraci%TYPE;
   w_ctipre_seg   seguros.ctiprea%TYPE;   -- Ind. tipus reaseguranca ->> CVALOR = 60
   w_ifacced      cuafacul.ifacced%TYPE;
   w_porcgarant   NUMBER(5, 2);
   w_switchgarant NUMBER(1);
   w_icapacigarant capgarant.icapaci%TYPE;
   w_porcaux      NUMBER(5, 2);
   w_cvidaga      codicontratos.cvidaga%TYPE;
   w_nagrupa      cesionesaux.nagrupa%TYPE;
   --w_nagrupavi    NUMBER(4); 13195 AVT 16-02-2010
   w_cgar         garanseg.cgarant%TYPE;
   w_cforpag      seguros.cforpag%TYPE;
   w_divisoranual NUMBER;
   -- Divisor prorrateos año bisiesto
   w_dias_origen  NUMBER;
   w_fefecto      seguros.fefecto%TYPE;
   w_fvencim      seguros.fvencim%TYPE;
   lcapicum       NUMBER;
   lplecum        NUMBER;
   lcapacum       NUMBER;
   lassumir       NUMBER;
   lcapaci_cum    NUMBER;
   lcapcumtram    NUMBER;
   lcapcum_tot    NUMBER;
   lplecum_tot    NUMBER;
   w_captram_tot  NUMBER;
   w_sproduc      seguros.sproduc%TYPE;
   w_cramo        seguros.cramo%TYPE;
   w_cmodali      seguros.cmodali%TYPE;
   w_ctipseg      seguros.ctipseg%TYPE;
   w_ccolect      seguros.ccolect%TYPE;
   w_cactivi      seguros.cactivi%TYPE;
   w_cempres      seguros.cempres%TYPE;
   registre       cesionesaux%ROWTYPE;
   w_nmovigen     NUMBER;
   avui           DATE;
   w_gar_princ    NUMBER;   -- 21559 / 111590
   w_fac_princ    NUMBER;   -- 22237
   w_registre     NUMBER := 0;
   w_capital      NUMBER := 0;   -- 22237 AVT 15/05/2012
   w_capital_principal NUMBER;
   w_cdetces      NUMBER;   --28492 AVT 13-11-13
   v_hiha_ces     NUMBER := 0;   -- 21/01/2014 AVT
   vpar_traza     VARCHAR2(80) := 'TRAZA_CESIONES_REA';   -- 08/04/2014 AGG
   v_nom_paquete  VARCHAR2(80) := NULL;
   v_nom_funcion  VARCHAR2(80) := 'F_CESSIO';
   v_base_rea     NUMBER := 0;   -- AGG 25/04/2014
   v_crecimiento  NUMBER := 0;   -- AGG 25/04/2014
   v_tiene_facul  NUMBER := 0;   -- AGG 25/04/2014
   v_cramo seguros.cramo%TYPE;   --BUG CONF-1080  Fecha (14/09/2017) - HRE - Cumulo por zonas geograficas
   --INFORCOL INICIO 06-05-2020 Bug 10555-10556 Facultativo Dolares/Euros
   w_moninst          monedas.cmonint%TYPE;
   w_monpol           monedas.cmonint%TYPE;
   --INFORCOL FIN 06-05-2020 Bug 10555-10556 Facultativo Dolares/Euros

   CURSOR cur_aux_1 IS
      SELECT   *
          FROM cesionesaux
         WHERE sproces = psproces
      ORDER BY (icapaci - icapital), cgarant DESC;   -- 19484 AVT 02/01/2012

   CURSOR cur_aux_2 IS
      SELECT   *
          FROM cesionesaux
         WHERE cestado = 0
           AND sproces = psproces
      ORDER BY nriesgo, spleno, ccalif1, ccalif2, scontra, nversio, scumulo, nagrupa, cgarant;

   CURSOR cur_aux_3 IS
      SELECT cgarant, iprirea, icapital, ipritarrea, idtosel
        FROM cesionesaux
       WHERE NVL(nriesgo, 0) = NVL(w_nriesgo, 0)
         AND NVL(spleno, 0) = NVL(w_spleno, 0)
         AND NVL(ccalif1, ' ') = NVL(w_ccalif1, ' ')
         AND NVL(ccalif2, 0) = NVL(w_ccalif2, 0)
         AND NVL(scontra, 0) = NVL(w_scontra, 0)
         AND NVL(nversio, 0) = NVL(w_nversio, 0)
         AND NVL(scumulo, 0) = NVL(w_scumulo, 0)
         AND NVL(nagrupa, 0) = NVL(w_nagrupa, 0)
         AND cgarant IS NULL
         AND cestado = 1
         AND sproces = psproces;

   CURSOR cur_aux_4 IS
      SELECT cgarant, iprirea, icapital, ipritarrea, idtosel
        FROM cesionesaux
       WHERE NVL(nriesgo, 0) = NVL(w_nriesgo, 0)
         AND NVL(spleno, 0) = NVL(w_spleno, 0)
         AND NVL(ccalif1, ' ') = NVL(w_ccalif1, ' ')
         AND NVL(ccalif2, 0) = NVL(w_ccalif2, 0)
         AND NVL(scontra, 0) = NVL(w_scontra, 0)
         AND NVL(nversio, 0) = NVL(w_nversio, 0)
         AND NVL(scumulo, 0) = NVL(w_scumulo, 0)
         AND NVL(nagrupa, 0) = NVL(w_nagrupa, 0)
         AND cgarant IS NOT NULL
         AND NVL(cgarant, 0) <> NVL(w_cgarant, 0)
         AND cestado = 1
         AND sproces = psproces;

   CURSOR cur_aux_5 IS
      SELECT cgarant, iprirea, icapital, ipritarrea, idtosel
        FROM cesionesaux
       WHERE NVL(nriesgo, 0) = NVL(w_nriesgo, 0)
         AND NVL(spleno, 0) = NVL(w_spleno, 0)
         AND NVL(ccalif1, ' ') = NVL(w_ccalif1, ' ')
         AND NVL(ccalif2, 0) = NVL(w_ccalif2, 0)
         AND NVL(scontra, 0) = NVL(w_scontra, 0)
         AND NVL(nversio, 0) = NVL(w_nversio, 0)
         AND NVL(scumulo, 0) = NVL(w_scumulo, 0)
         AND NVL(nagrupa, 0) = NVL(w_nagrupa, 0)
         AND cgarant IS NOT NULL
         AND NVL(cgarant, 0) = NVL(w_cgarant, 0)
         AND cestado = 1
         AND sproces = psproces;

   CURSOR cur_trams(wscontra NUMBER, wnversio NUMBER) IS
      SELECT nplenos, DECODE(ctramo, 6, 0, ctramo) ctramo   -- 28492 AVT 28/10/2013
        FROM tramos
       WHERE scontra = wscontra
         AND nversio = wnversio;

   -- 21559 AVT 12/03/2012
   CURSOR garantia_principal(p_cgarant IN NUMBER, p_sproces IN NUMBER, p_sseguro IN NUMBER,
   p_nmovimi IN NUMBER,   -- AVT 26/03/2012 per la migració sempre és el mateix procés
   p_motiu IN NUMBER) IS
      SELECT   *
          FROM cesionesrea c
         WHERE c.sproces = p_sproces
           AND c.sseguro = p_sseguro
           AND c.cgarant = p_cgarant
           AND nmovimi = p_nmovimi
           AND cgenera = p_motiu
      ORDER BY ctramo;   -- AVT 14/03/2012

   -- 22686 AVT 25/07/2012
   -- BUG 32363 - DCT - 25/07/2014
   CURSOR riesgos_anul(p_cumul IN NUMBER) IS
      SELECT DISTINCT s.sseguro, s.fanulac
                 FROM reariesgos r, seguros s, cesionesrea c
                WHERE r.scumulo = p_cumul
                  AND r.scumulo = c.scumulo
                  AND r.sseguro = c.sseguro
                  AND r.sseguro = s.sseguro
                  AND s.fanulac IS NOT NULL
                  AND freafin IS NULL;

   --INI BUG CONF-1080  Fecha (14/09/2017) - HRE - Cumulo por zonas geograficas
      CURSOR cur_tiprea(pcempres NUMBER, pmotiu NUMBER, pcramo NUMBER, pfefecto DATE) IS
       SELECT c.ctiprea
           FROM codicontratos c, contratos v, agr_contratos a
          WHERE c.scontra = v.scontra
            AND c.scontra = a.scontra
            AND c.cempres = pcempres
            AND a.cgarant IS NULL
            AND(c.ctiprea = DECODE(NVL(pmotiu, 0), 11, 3)
                OR(DECODE(NVL(pmotiu, 0), 11, 1, 0) = 0
                   AND(c.ctiprea = 1
                       OR c.ctiprea = 2
                       OR c.ctiprea = 5)))--BUG CONF-250  Fecha (02/09/2016) - HRE - se incluye v_valor
            AND a.cramo = pcramo
            AND a.cmodali IS NULL
            AND a.ctipseg IS NULL
            AND a.ccolect IS NULL
            AND a.cactivi IS NULL
            AND v.fconini <= pfefecto
            AND(v.fconfin IS NULL
                OR v.fconfin > pfefecto)
            AND c.nconrel IS NULL;
   --FIN BUG CONF-1080  - Fecha (14/09/2017) - HRE

-- *********************************************************************
-- *********************************************************************
-- *********************************************************************
   PROCEDURE cabfacul(regaux1 cur_aux_1%ROWTYPE) IS
      /**********************************************************************
         procediment CABFACUL per fer insert a capçalera de facultatiu (CUAFACUL)
      I A FACPENDIENTES ( si ja existeix, no fa res)...
      **********************************************************************/
      w_sfacult      cuafacul.sfacult%TYPE;
      w_pfacced      cuafacul.pfacced%TYPE;
      w_ifacced      cuafacul.ifacced%TYPE;
      w_controllat   NUMBER(1);
      w_cramo        seguros.cramo%TYPE;
      w_scontra      reaseguroaux.scontra%TYPE;
      w_nversio      reaseguroaux.nversio%TYPE;
      w_sproduc      seguros.sproduc%TYPE;
   --w_capital_principal NUMBER;
   BEGIN
      p_traza_proceso(24, 'TRAZA_CESIONES_REA', psproces, v_nom_paquete,
                      'F_CESSIO_AMC', 'cabfacul', 273,
                      'regaux1.scontra:' || regaux1.scontra);

      ----dbms_outpuT.put_line('Entra a cabfacul');
      IF regaux1.scontra IS NULL THEN
         -- Busquem el ram per el SCONTRA ( si facultatiu pur)...
         BEGIN   -- Busquem el ram per el SCONTRA ( si facultatiu pur)...
            SELECT cramo
              INTO w_scontra
              FROM seguros
             WHERE sseguro = regaux1.sseguro;
         END;

         w_nversio := 1;
      ELSE
         w_scontra := regaux1.scontra;
         w_nversio := regaux1.nversio;
      END IF;

      p_traza_proceso(24, 'TRAZA_CESIONES_REA', psproces, v_nom_paquete,
                      'F_CESSIO_AMC', 'cabfacul', 283,
                      'w_scontra:' || w_scontra || ' w_nversio:' || w_nversio ||
                      ' regaux1.sseguro:'|| regaux1.sseguro || ' regaux1.nriesgo:' ||
                      regaux1.nriesgo || ' regaux1.cgarant:'|| regaux1.cgarant || 
                      ' regaux1.nmovimi:' || regaux1.nmovimi || ' w_cramo:'|| w_cramo);
      w_controllat := 0;

      p_traza_proceso(24, 'TRAZA_CESIONES_REA', psproces, v_nom_paquete,
                      'F_CESSIO_AMC', 'cabfacul', 308,
                      'regaux1.sseguro:'|| regaux1.sseguro || ' regaux1.nriesgo:' ||
                      regaux1.nriesgo || ' regaux1.cgarant:'|| regaux1.cgarant || 
                      ' regaux1.nmovimi:' || regaux1.nmovimi || ' w_cramo:'|| w_cramo);
      BEGIN
         SELECT COUNT(*)
           INTO w_sfacult
           FROM cuafacul   /* BUG 10462: ETM:16/06/2009:--ANTES--facpendientes*/
          WHERE sseguro = regaux1.sseguro
            AND nriesgo = regaux1.nriesgo
            AND NVL(cgarant, 0) = NVL(regaux1.cgarant, 0)
            AND nmovimi = regaux1.nmovimi
            AND cestado = 1;   /* BUG 10462: ETM:16/06/2009:--AÑADIMOS-- CESTADO=1-*/

         IF w_sfacult > 0 THEN
            w_controllat := 1;   -- Ja está a FACPENDIENTES...
         END IF;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            NULL;
         WHEN OTHERS THEN
            perr := 105032;
      END;
      p_traza_proceso(24, 'TRAZA_CESIONES_REA', psproces, v_nom_paquete,
                      'F_CESSIO_AMC', 'cabfacul', 323,
                      'w_sfacult:' || w_sfacult || ' w_controllat:' || w_controllat ||
                      ' regaux1.scumulo:' || regaux1.scumulo || ' perr:' || perr);

      ----dbms_outpuT.put_line(' DINS DE CABFACUL garantia '||regaux1.cgarant);
      ----dbms_outpuT.put_line(' DINS DE CABFACUL el cumul és '||regaux1.scumulo);
      IF w_controllat = 0 THEN   -- Tenim que fer l'insert en FACPENDIENTES
         IF regaux1.scumulo IS NOT NULL THEN
            -- No existeix un registre de pendent i sí que forma cumul...
            -- Si ja existeix capçalera iniciada per el cumul, s'agafará
            -- el num. de cumul i es donará l'alta a FACPENDIENTES
            -- solsament...
            -- Si no existeix capçalera, es dona d'alta als dos llocs...
            ----dbms_outpuT.put_line(' cabfacul TE CUMUL ');
            BEGIN
               SELECT sfacult
                 INTO w_sfacult
                 FROM cuafacul
                WHERE scumulo = regaux1.scumulo
                  AND(cgarant = regaux1.cgarant
                      OR regaux1.cgarant IS NULL)
                  AND cestado = 1;

               ----dbms_outpuT.put_line(' cabfacul TE QUADRE ');
               w_controllat := 2;   -- No hem de fer l'insert a CUAFACUL
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  NULL;
               ----dbms_outpuT.put_line(' INsert pendent ');
               WHEN OTHERS THEN
                  perr := 104486;
            END;
         END IF;

      p_traza_proceso(24, 'TRAZA_CESIONES_REA', psproces, v_nom_paquete,
                      'F_CESSIO_AMC', 'cabfacul', 361,
                      'w_sfacult:' || w_sfacult || ' w_controllat:' || w_controllat ||
                      ' regaux1.scumulo:' || regaux1.scumulo || ' perr:' || perr);

         IF w_controllat = 0 THEN   -- No tenim identificador de facultatiu
            SELECT sfacult.NEXTVAL
              INTO w_sfacult
              FROM DUAL;
         END IF;

      p_traza_proceso(24, 'TRAZA_CESIONES_REA', psproces, v_nom_paquete,
                      'F_CESSIO_AMC', 'cabfacul', 371,
                      'w_sfacult:' || w_sfacult || ' w_controllat:' || w_controllat ||
                      ' regaux1.scontra:' || regaux1.scontra || ' perr:' || perr);

         /* BUG 10462: ETM:16/06/2009:--ANTES
                       -- Donem d'alta un registre a FACPENDIENTES
          BEGIN
             INSERT INTO facpendientes
                         (sproces, nnumlin, sseguro, iprirea,
                          icapital, cfacult, cestado, nriesgo,
                          nmovimi, ccalif1, ccalif2, spleno,
                          cgarant, scontra, nversio, fconini,
                          fconfin, ipleno,
                          icapaci, scumulo,
                          sfacult)
                  VALUES (regaux1.sproces, regaux1.nnumlin, regaux1.sseguro, regaux1.iprirea,
                          regaux1.icapital, regaux1.cfacult, regaux1.cestado, regaux1.nriesgo,
                          regaux1.nmovimi, regaux1.ccalif1, regaux1.ccalif2, regaux1.spleno,
                          regaux1.cgarant, regaux1.scontra, regaux1.nversio, regaux1.fconini,
                          regaux1.fconfin, DECODE(regaux1.scontra, NULL, 0, regaux1.ipleno),
                          DECODE(regaux1.scontra, NULL, 0, regaux1.icapaci), regaux1.scumulo,
                          w_sfacult);
          EXCEPTION
             WHEN OTHERS THEN
                perr := 104706;
          END;
         /* BUG 10462: ETM:16/06/2009:--*/
         IF w_controllat = 0 THEN
            -- Donem d'alta la capçalera nova a CUAFACUL
            IF regaux1.scontra IS NOT NULL THEN
               BEGIN
                  BEGIN
                     SELECT cempres, cramo,   --ctiprea, 22660 AGM 13/08/2012
                                           cmodali, ctipseg, ccolect, cactivi,
                            sproduc
                       INTO w_cempres, w_cramo,   --w_ctiprea,
                                               w_cmodali, w_ctipseg, w_ccolect, w_cactivi,
                            w_sproduc
                       FROM seguros
                      WHERE sseguro = regaux1.sseguro;
                  EXCEPTION
                     WHEN OTHERS THEN
                        perr := 101919;
                  END;

      p_traza_proceso(24, 'TRAZA_CESIONES_REA', psproces, v_nom_paquete,
                      'F_CESSIO_AMC', 'cabfacul', 415,
                      'w_gar_princ:' || w_gar_princ || ' w_controllat:' || w_controllat ||
                      ' w_sproduc:' || w_sproduc || ' perr:' || perr);

                  --BUG 21559 - INICIO - 23/05/2013 - DCT
                  IF NVL(pac_parametros.f_parproducto_n(w_sproduc, 'GAR_PRINCIPAL_REA'), 0) = 1
                     AND w_gar_princ <> regaux1.cgarant THEN   -- 21559 / 111590
                     BEGIN
                        SELECT ifacced   --pfacced     22666/117640
                          INTO w_ifacced   --w_pfacced   22666/117640
                          FROM cuafacul c
                         WHERE (sseguro = regaux1.sseguro
                                OR scumulo = regaux1.scumulo)
                           AND c.cgarant = w_gar_princ
                           AND cestado = 1;
                     EXCEPTION
                        WHEN OTHERS THEN
                           perr := 104486;
                     END;
      p_traza_proceso(24, 'TRAZA_CESIONES_REA', psproces, v_nom_paquete,
                      'F_CESSIO_AMC', 'cabfacul', 434,
                      'w_ifacced:' || w_ifacced || ' perr:' || perr);

                     -->DBMS_OUTPUT.put_line('>>> pfacced ' || w_pfacced);
                     -- 22237 AVT 14/05/2012 falta dividir per 100
                     -->>  w_ifacced := regaux1.icapital * w_pfacced ;
                     --w_ifacced := regaux1.icapital * w_pfacced / 100;               -- 22666 - GAG  - 27/07/2012
                     --25502/138082 - INICIO - DCT - 15/02/2013
                     w_pfacced := w_ifacced / w_capital_principal * 100;
                     --25502/138082 - FIN - DCT - 15/02/2013
                     w_ifacced := regaux1.icapital * w_ifacced / w_capital_principal;   -- 22666 - GAG  - 27/07/2012
                  -->DBMS_OUTPUT.put_line('>>> pfacced ' || w_pfacced);
                  -->DBMS_OUTPUT.put_line('>>> ifcaced ' || w_ifacced);
      p_traza_proceso(24, 'TRAZA_CESIONES_REA', psproces, v_nom_paquete,
                      'F_CESSIO_AMC', 'cabfacul', 447,
                      'w_pfacced:'|| w_pfacced ||' w_ifacced:' || w_ifacced ||
                      ' w_capital_principal:'|| w_capital_principal|| ' perr:' || perr);
                  ELSE
                     w_pfacced :=(100 *(regaux1.icapital - lcapaci_cum) / regaux1.icapital);
                     w_ifacced := regaux1.icapital - lcapaci_cum;
      p_traza_proceso(24, 'TRAZA_CESIONES_REA', psproces, v_nom_paquete,
                      'F_CESSIO_AMC', 'cabfacul', 454,
                      'w_ifacced:' || w_ifacced || ' perr:' || perr);

                  END IF;
               --regaux1.icapaci;
               ----dbms_output.put_line ('regaux1.icapital ='||regaux1.icapital);
               ----dbms_output.put_line ('lcapaci_cum ='||lcapaci_cum);
               ----dbms_output.put_line ('regaux1.icapaci ='||regaux1.icapaci);
               ----dbms_output.put_line ('ifacced ='||w_ifacced);
               EXCEPTION
                  WHEN OTHERS THEN
                     w_pfacced := 0;
                     w_ifacced := 0;
      p_traza_proceso(24, 'TRAZA_CESIONES_REA', psproces, v_nom_paquete,
                      'F_CESSIO_AMC', 'cabfacul', 466,
                      'w_pfacced = 0 - w_ifacced = 0 perr:' || perr);
               END;
            ELSE
               w_pfacced := 100;
               w_ifacced := regaux1.icapital;
      p_traza_proceso(24, 'TRAZA_CESIONES_REA', psproces, v_nom_paquete,
                      'F_CESSIO_AMC', 'cabfacul', 474,
                      'w_pfacced :'||w_pfacced || ' w_ifacced:'|| w_ifacced ||' perr:' || perr);

            END IF;

            -->DBMS_OUTPUT.put_line('pfacced ' || w_pfacced);
            -->DBMS_OUTPUT.put_line('ifcaced ' || w_ifacced);

      p_traza_proceso(24, 'TRAZA_CESIONES_REA', psproces, v_nom_paquete,
                      'F_CESSIO_AMC', 'cabfacul', 482,
                      'w_sfacult:' || w_sfacult || ' w_controllat:' || w_controllat ||
                      ' regaux1.scumulo:' || regaux1.scumulo || ' perr:' || perr);
            --IF w_controllat > 0 THEN
            -- 13946 AVT 06-04-2010 s'afegeix el SCONTRA i la NVERSIO.
            BEGIN   -- Posem data final al quadre anterior...
               UPDATE cuafacul
                  SET ffincuf = regaux1.fconini
                WHERE (sseguro = regaux1.sseguro
                       OR scumulo = NVL(regaux1.scumulo, -1))
                  AND NVL(nriesgo, 0) = DECODE(scumulo,
                                               NULL, regaux1.nriesgo,
                                               0)   -- 15590 AVT 30-07-2010
                  AND(cgarant IS NULL
                      OR cgarant = regaux1.cgarant)
                  AND ffincuf IS NULL
                  AND scontra = w_scontra
                  AND nversio = w_nversio;
            EXCEPTION
               WHEN OTHERS THEN
                  perr := 107512;
            END;

            BEGIN
               INSERT INTO cuafacul
                           (sfacult, cestado, finicuf, cfrebor, scontra, nversio,
                            sseguro,
                            cgarant, ccalif1, ccalif2,
                            spleno, nmovimi, scumulo,
                            nriesgo, ffincuf, plocal,
                            fultbor, pfacced, ifacced, ncesion)
                    VALUES (w_sfacult, 1, regaux1.fconini, 1, w_scontra, w_nversio,
                            DECODE(regaux1.scumulo, NULL, regaux1.sseguro, NULL),
                            regaux1.cgarant, regaux1.ccalif1, regaux1.ccalif2,
                            regaux1.spleno, regaux1.nmovimi, regaux1.scumulo,
                            DECODE(regaux1.scumulo, NULL, regaux1.nriesgo, NULL), NULL, NULL,
                            NULL, w_pfacced, w_ifacced, 1);
            EXCEPTION
               WHEN OTHERS THEN
                  perr := 104343;
            END;
         END IF;
      END IF;
   END cabfacul;

-- *********************************************************************
-- *********************************************************************
-- *********************************************************************
   FUNCTION f_facult(psseguro IN NUMBER, pnriesgo IN NUMBER, pccalif1 IN VARCHAR2,
   pccalif2 IN NUMBER, pcgarant IN NUMBER, pscontra IN NUMBER, pnversio IN NUMBER,
   pfinicuf IN DATE, pscumulo IN NUMBER, ptrovat OUT NUMBER, pcestado OUT NUMBER,
   pfacult OUT NUMBER, pifacced OUT NUMBER)
      RETURN NUMBER IS
      /***********************************************************************
            F_FACULT        : Buscar si existeix un facultatiu.
      ***********************************************************************/
      perr           NUMBER := 0;

      CURSOR cur_facult IS
         SELECT   cestado, sfacult, ifacced
             FROM cuafacul c
            WHERE (sseguro = psseguro
                   OR scumulo = pscumulo)
              AND(nriesgo = pnriesgo
                  OR nriesgo IS NULL)
              AND(ccalif1 = pccalif1
                  OR ccalif1 IS NULL)
              AND(ccalif2 = pccalif2
                  OR ccalif2 IS NULL)
              AND(cgarant = pcgarant
                  OR cgarant IS NULL)
              AND(scontra = pscontra
                  OR pscontra IS NULL
                  OR pfdatagen <> f_sysdate)   -- pfdatagen viene informado en la migración
              AND finicuf <= pfinicuf
              AND(ffincuf > pfinicuf
                  OR ffincuf IS NULL)
         ORDER BY sfacult DESC;   --finicuf; DESC; -- 19484 AVT 02/01/2012
   -- Necessitem el registre correcte.
   -- 19484 AVT 02/01/2012 ja estem tractan els cúmuls en el primer cursor --
   /*CURSOR c_fac_cum(pscumulo IN NUMBER) IS
        SELECT *
       FROM cuafacul
      WHERE scumulo =  sseguro IN(SELECT sseguro
                                 FROM reariesgos
                                WHERE scumulo = 4363
                                  AND freafin IS NULL); */
   -- fi 19484 AVT 02/01/2012
   BEGIN
      ptrovat := 0;
      pcestado := NULL;
      pfacult := NULL;

      --DBMS_OUTPUT.put_line(' CONTRACTE a f_facult ' || pscontra);
      --DBMS_OUTPUT.put_line(' GARNATIA a f_facult ' || pcgarant);
      FOR regfacult IN cur_facult LOOP
         ptrovat := 1;
         pcestado := regfacult.cestado;
         pfacult := regfacult.sfacult;
         pifacced := regfacult.ifacced;
         EXIT;
      END LOOP;

      --DBMS_OUTPUT.put_line(' ptrovat:' || ptrovat || ' pscumulo:' || pscumulo);
      -- si no l'he trobat, miro si hi ha alguna pòlissa del cumul
      -- amb quadre
      -- 19484 AVT 02/01/2012
      /* IF ptrovat = 0
               AND pscumulo IS NOT NULL THEN
         FOR v_fac_cum IN c_fac_cum(pscumulo) LOOP
            UPDATE cuafacul
               SET scumulo = pscumulo,
                   sseguro = NULL
             WHERE sfacult = v_fac_cum.sfacult
               AND ffincuf IS NULL;
            ptrovat := 1;
            pcestado := v_fac_cum.cestado;
            pfacult := v_fac_cum.sfacult;
            pifacced := v_fac_cum.ifacced;
            --DBMS_OUTPUT.put_line(' pifacced:' || pifacced);
            EXIT;
         END LOOP;
      END IF;*/
      RETURN(perr);
   END f_facult;

-- *********************************************************************
-- *********************************************************************
-- *********************************************************************
--------------------------------------------------------------------------
--  Funció que fa l'insert
   FUNCTION f_insert_ces(pp_capces IN NUMBER, pp_tramo IN NUMBER, pp_facult IN NUMBER,
   pp_cesio IN NUMBER, pp_porce IN NUMBER, pp_sproduc IN NUMBER)
      RETURN NUMBER IS
      -- vsproduc       NUMBER; 13195 AVT 16-02-2010
      w_scesrea      cesionesrea.scesrea%TYPE;
      v_fconfin      DATE;
      v_irecarg      garanseg.irecarg%TYPE;
      v_iextrap      garanseg.iextrap%TYPE;
      v_icapital     garanseg.icapital%TYPE;
      v_pcomext      contratos.pcomext%TYPE;
      --INI BUG CONF-479  Fecha (20/01/2017) - HRE - Suplemento de aumento de valor
      w_porce        NUMBER := 0;
      w_capces       NUMBER := 0;
      numerr         NUMBER := 0;
      v_traza        NUMBER := 0;
      --FIN BUG CONF-479  - Fecha (20/01/2017) - HRE
   BEGIN
      --INI BUG CONF-479  Fecha (20/01/2017) - HRE - Suplemento de aumento de valor
      v_traza:=1;
      numerr := pac_cesionesrea.f_mantener_repartos_supl(pmotiu, w_sproduc, registre.scontra,
                                                         registre.sseguro, registre.nversio,
                                                         registre.cgarant, pp_tramo, pp_porce,
                                                         pp_capces, registre.icapital,w_capces, w_porce);
														 
	   p_control_error('bart_ces1','numerr:'||numerr,'SQLERRM:'||SQLERRM);													 
														 
      v_traza:=2;
      IF numerr <> 0 THEN
         p_tab_error(f_sysdate, f_user, 'f_cessio', 1, 'f_insert_ces', SQLERRM);
         perr := 104692;
         RETURN(perr);
      END IF;
      --FIN BUG CONF-479  - Fecha (20/01/2017) - HRE
      SELECT scesrea.NEXTVAL
        INTO w_scesrea
        FROM DUAL;

      v_traza:=3;--BUG CONF-479  Fecha (20/01/2017) - HRE - suplemento aumento de valor
      -- BUG 0010844 - 14/09/2009 - FAL - Substituir f_round_forpag per f_round a f_insert_ces
      -->DBMS_OUTPUT.put_line('2.1 registre.iprirea:' || registre.iprirea);

      --INI BUG CONF-479  Fecha (20/01/2017) - HRE - Suplemento de aumento de valor
      w_iprirea := f_round(registre.iprirea * w_porce, pmoneda);   -- INI BUG 18423 - 15/12/2011 - JLB - LCOL000 - Multimoneda
      w_ipritarrea := f_round(registre.ipritarrea * w_porce, pmoneda);   -- INI BUG 18423 - 15/12/2011 - JLB - LCOL000 - Multimoneda
      w_idtosel := f_round(registre.idtosel * w_porce, pmoneda);   -- INI BUG 18423 - 15/12/2011 - JLB - LCOL000 - Multimoneda
      w_iextrea := f_round(registre.iextrea * w_porce, pmoneda);   --BUG 30326/171842 - DCT - 03/04/2014
      w_iextrap := f_round(registre.iextrap * w_porce, pmoneda);   --BUG 30326/171842 - DCT - 03/04/2014
      v_traza:=4;
      --FIN BUG CONF-479  - Fecha (20/01/2017) - HRE

      -- FI BUG 0010844 - 14/09/2009 - FAL
      -->DBMS_OUTPUT.put_line('>>> Registre.CGARANT:' || registre.cgarant);
      -->DBMS_OUTPUT.put_line(' w_iprirea :' || w_iprirea || ' registre.iprirea:'
      --> || registre.iprirea || ' w_porce:' || w_porce || ' pmoneda:'
      -->|| pmoneda);
      ----dbms_outpuT.put_line('dif data 1 '||TO_CHAR(regaux1.fconini,'dd/mm/yyyy')||'-'|| TO_CHAR(w_fconfin,'dd/mm/yyyy'));
      -- 20.0 - 16/10/2013 - MMM - 0026194_NOTA_0156003_Qtracker 0006484 Cesion de prima por emision - Inicio
      --codi_error := f_difdata(registre.fconini, registre.fconfin, 1, 3, w_dias);

      --AGG 06/03/2014 Se puede dar el caso de que el campo fconfin no esté actualizado
      --ya que se calcula en un paso posterior a este, si es así, lo calculamos de la misma manera
      --que se calcula posteriormente
      IF registre.fconfin IS NULL THEN
         v_traza:=5;--BUG CONF-479  Fecha (20/01/2017) - HRE - suplemento aumento de valor
         SELECT DECODE(fcaranu, NULL, fvencim, fcaranu)
           INTO v_fconfin
           FROM seguros
          WHERE sseguro = registre.sseguro;

         codi_error := f_difdata(registre.fconini, v_fconfin, 3, 3, w_dias);
      ELSE
         v_traza:=6;--BUG CONF-479  Fecha (20/01/2017) - HRE - suplemento aumento de valor
         codi_error := f_difdata(registre.fconini, registre.fconfin, 3, 3, w_dias);
      END IF;

      -- 20.0 - 16/10/2013 - MMM - 0026194_NOTA_0156003_Qtracker 0006484 Cesion de prima por emision - Fin

      -- nos indica que sí se deberían prorratear los movimientos de suplementos.
      -- No hacemos diferencias por forma de pago (entre f.ini i fin max 1 año).

      -- BUG 0011512 - 21/10/2009 - FAL - Covertir el paràmetre de instal.lació de prorrateig en la N.P per un parproducto
      IF (pmotiu IN(9, 4, 1, 3)) THEN   -- Añadimos el pmotiu 1
         -- BUG 0010844 - 31/08/2009 - FAL - Afegir prorrateig de la cessio en la Nova Producció unicament per CIV. Añadimos el pmotiu 3
         v_traza:=7;--BUG CONF-479  Fecha (20/01/2017) - HRE - suplemento aumento de valor
         IF pmotiu = 3
            AND   -->> Per defecte tots els productes prorrategen <<--
               NVL(f_parproductos_v(pp_sproduc, 'NO_PRORRATEA_REA'), 0) = 1 THEN
            v_traza:=8;--BUG CONF-479  Fecha (20/01/2017) - HRE - suplemento aumento de valor
            NULL;   -- >> NO PRORRATEJA!
         ELSE
            IF NVL(f_parproductos_v(pp_sproduc, 'NO_PRORRATEA_REA_SUP'), 0) = 1 THEN
               v_traza:=9;--BUG CONF-479  Fecha (20/01/2017) - HRE - suplemento aumento de valor
               NULL;   -- >> NO PRORRATEJA!
            ELSE
               v_traza:=10;--BUG CONF-479  Fecha (20/01/2017) - HRE - suplemento aumento de valor
               -- FI BUG 0011512 - 21/10/2009 - FAL
               -- 20.0 - 16/10/2013 - MMM - 0026194_NOTA_0156003_Qtracker 0006484 Cesion de prima por emision - Inicio
               --codi_error := f_difdata(registre.fconini, ADD_MONTHS(registre.fconini, 12), 1,3, w_divisoranual);   --Año bisiesto
               codi_error := f_difdata(registre.fconini, ADD_MONTHS(registre.fconini, 12), 3,
                                       3, w_divisoranual);
               -- 20.0 - 16/10/2013 - MMM - 0026194_NOTA_0156003_Qtracker 0006484 Cesion de prima por emision - Fin
               -- BUG 0010844 - 14/09/2009 - FAL - Substituir f_round_forpag per f_round a f_insert_ces
               w_iprirea := f_round((w_iprirea * w_dias) / w_divisoranual, pmoneda);   -- INI BUG 18423 - 15/12/2011 - JLB - LCOL000 - Multimoneda
               w_ipritarrea := f_round((w_ipritarrea * w_dias) / w_divisoranual, pmoneda);   -- INI BUG 18423 - 15/12/2011 - JLB - LCOL000 - Multimoneda
               w_idtosel := f_round((w_idtosel * w_dias) / w_divisoranual, pmoneda);   -- INI BUG 18423 - 15/12/2011 - JLB - LCOL000 - Multimoneda
               w_iextrea := f_round((w_iextrea * w_dias) / w_divisoranual, pmoneda);   --BUG 30326/171842 - DCT - 03/04/2014
               w_iextrap := f_round((w_iextrap * w_dias) / w_divisoranual, pmoneda);   --BUG 30326/171842 - DCT - 03/04/2014
            -- FI BUG 0010844 - 14/09/2009 - FAL
            END IF;
         END IF;
      END IF;
      v_traza:=11;--BUG CONF-479  Fecha (20/01/2017) - HRE - suplemento aumento de valor
      --07/05/2014 AGG Añadimos la comisión de la extra prima
      BEGIN
         SELECT pcomext
           INTO v_pcomext
           FROM contratos
          WHERE scontra = registre.scontra
            AND nversio = registre.nversio;

         w_icomext := w_iextrea * v_pcomext;
      EXCEPTION
         WHEN OTHERS THEN
            w_icomext := 0;
      END;
      v_traza:=12;--BUG CONF-479  Fecha (20/01/2017) - HRE - suplemento aumento de valor
      INSERT INTO cesionesrea
                  (scesrea, ncesion, icesion, icapces, sseguro,
                   nversio,
                   scontra,
                   ctramo, sfacult, nriesgo,
                   icomisi, icomreg, scumulo, cgarant,
                   spleno,
                   ccalif1,
                   ccalif2, fefecto,
                   fvencim, pcesion, sproces, cgenera, fgenera,
                   nmovimi, ipritarrea, idtosel, psobreprima,
                   cdetces, fanulac, fregula, nmovigen,
                   ipleno, icapaci, iextrea,
                                            -- 22.0 - 29/11/2013 - MMM - 0028082 LCOL_A004-0008810 CLF2-4054 LISTADOS DE PRIMAS CEDIDAS VIDA PROPORCIONAL - Inicio
                                            iextrap,
                   itarifrea, icomext)   --07/05/2014 AGG Se incorpora el campo ICOMEXT
           -- 22.0 - 29/11/2013 - MMM - 0028082 LCOL_A004-0008810 CLF2-4054 LISTADOS DE PRIMAS CEDIDAS VIDA PROPORCIONAL - Fin
      VALUES      (w_scesrea, pp_cesio, w_iprirea, w_capces, registre.sseguro,--BUG CONF-479  Fecha (20/01/2017) - HRE - suplemento aumento de valor
                   DECODE(registre.cfacult, 0, registre.nversio, NULL),
                   DECODE(registre.cfacult, 0, registre.scontra, NULL),
                   DECODE(pp_tramo, 6, 0, 7, 0, 8, 0, pp_tramo),   -- 26663 AVT 08/07/2013 es guarden els trams com a propis
                                                                pp_facult, registre.nriesgo,
                   NULL, NULL, registre.scumulo, registre.cgarant,
                   DECODE(registre.cfacult, 0, registre.spleno, NULL),
                   DECODE(registre.cfacult, 0, registre.ccalif1, NULL),
                   DECODE(registre.cfacult, 0, registre.ccalif2, NULL), registre.fconini,
                   registre.fconfin,(w_porce * 100), registre.sproces, pmotiu, avui,--BUG CONF-479  Fecha (20/01/2017) - HRE - suplemento aumento de valor
                   registre.nmovimi, w_ipritarrea, w_idtosel, registre.psobreprima,
                   registre.cdetces, registre.fanulac, registre.fregula, w_nmovigen,
                   registre.ipleno, registre.icapaci, w_iextrea,   --registre.iextrea, --BUG 30326/171842 - DCT - 03/04/2014
                                                                -- 22.0 - 29/11/2013 - MMM - 0028082 LCOL_A004-0008810 CLF2-4054 LISTADOS DE PRIMAS CEDIDAS VIDA PROPORCIONAL - Inicio
                                                                --registre.iextrap,
                                                                w_iextrap,   --BUG 30326/171842 - DCT - 03/04/2014
                   registre.itarifrea, w_icomext);
      -- 22.0 - 29/11/2013 - MMM - 0028082 LCOL_A004-0008810 CLF2-4054 LISTADOS DE PRIMAS CEDIDAS VIDA PROPORCIONAL - Fin
      v_traza:=13;
      RETURN(0);
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'f_cessio', v_traza, 'f_insert_ces', SQLERRM);--BUG CONF-479  Fecha (20/01/2017) - HRE - suplemento aumento de valor
         perr := 104692;
         RETURN(perr);
   END f_insert_ces;

--------------------------------------------------------------------------
   FUNCTION f_ces(pnnumlin IN NUMBER, pmotiu IN NUMBER, pfacult IN NUMBER, pnmovigen IN NUMBER,
   psproduc IN NUMBER,   -- 13195 AVT 16-02-2010 afegitS SPRODUC I CTIPREA
                      pctiprea IN NUMBER,   -- de CODICONTRATOS
                                         pctipre_seg IN NUMBER)   -- de SEGUROS
      RETURN NUMBER IS
      /***********************************************************************
                                                    F_CES        : Realitza realment la cessió, creant registres
      a "CESIONESREA".
      ***********************************************************************/
      perr           NUMBER := 0;
      --      registre       cesionesaux%ROWTYPE;
      --w_ctiprea      NUMBER(2); 13195 AVT 16-02-2010
      w_captram      NUMBER;
      w_resto        NUMBER;
      w_volta        NUMBER(2);
      w_yacedido     NUMBER;
      w_porce        NUMBER;   -- Falta de precisión NUMBER (10, 7);
      w_iprirea      cesionesaux.iprirea%TYPE;
      w_res          cesionesaux.iprirea%TYPE;
      w_scesrea      cesionesrea.scesrea%TYPE;
      w_nomes00      NUMBER(1);
      --w_ctipre       NUMBER(1); 13195 AVT 16-02-2010
      w_cramo        NUMBER(8);
      w_icapital2    cesionesaux.icapital%TYPE;
      w_ffalseado    NUMBER(1);
      w_ifacced      cuafacul.ifacced%TYPE;
      w_norden       tramos.norden%TYPE;
      lcapcum        NUMBER;
      lplecum        NUMBER;
      lcapacum       NUMBER;
      lcaptram       NUMBER;
      lcapcum_tot    NUMBER;
      lplecum_tot    NUMBER;
      w_captram_tot  NUMBER;
      w_contgar      NUMBER;
      w_cramo        seguros.cramo%TYPE;
      w_cmodali      seguros.cmodali%TYPE;
      w_ctipseg      seguros.ctipseg%TYPE;
      w_ccolect      seguros.ccolect%TYPE;
      w_cactivi      seguros.cactivi%TYPE;
      w_cempres      seguros.cempres%TYPE;
      hiha_formula   NUMBER;   -- 22660 AVT 13/08/2012

      --Ini Bug 33993-214688 KJSC 25/09/2015 TODO CEDE AL CONTRATO INDEPENDIENTEMENTE DE SI SUPERA
      /*CURSOR cur_trams(wscontra NUMBER, wnversio NUMBER) IS
         SELECT   scontra, nversio, DECODE(ctramo, 6, 0, ctramo) ctramo, itottra, norden,
                  ncesion   -- 28492 AVT 28/10/2013
             FROM tramos
            WHERE scontra = wscontra   --registre.scontra
              AND nversio = wnversio   --registre.nversio
         ORDER BY norden;*/
      CURSOR cur_trams(wscontra NUMBER, wnversio NUMBER) IS
         SELECT   t.scontra, t.nversio, DECODE(t.ctramo, 6, 0, t.ctramo) ctramo, t.itottra,
                  t.norden, t.ncesion,
                  DECODE(t.norden,
                         (SELECT MAX(t2.norden)
                            FROM tramos t2
                           WHERE t2.scontra = t.scontra
                             AND t2.nversio = t.nversio), 'F',
                         '') ulttram,
                  (SELECT SUM(t3.itottra)
                     FROM tramos t3
                    WHERE t3.scontra = t.scontra
                      AND t3.nversio = t.nversio
                      AND t3.norden < t.norden) restcapaci
             FROM tramos t
            WHERE t.scontra = wscontra   --registre.scontra
              AND t.nversio = wnversio   --registre.nversio
         ORDER BY t.norden;
   --Fin Bug 33993-214688 KJSC 25/09/2015 TODO CEDE AL CONTRATO INDEPENDIENTEMENTE DE SI SUPERA
   BEGIN
      avui := pfdatagen;
      w_nmovigen := pnmovigen;

      SELECT *
        INTO registre
        FROM cesionesaux
       WHERE nnumlin = pnnumlin
         AND sproces = psproces;

      -- 22660 AVT 16-08-2012 ho canviem de lloc
      SELECT cempres
        INTO w_cempres
        FROM seguros seg
       WHERE seg.sseguro = registre.sseguro;

p_traza_proceso(24, 'TRAZA_CESIONES_REA', psproces, v_nom_paquete, 'F_CESSIO.F_CES', NULL, 742,
                   'registre.cfacult:'||registre.cfacult);

      IF registre.cfacult = 0 THEN   -- No es un facultatiu forçat...
         --   Aquí mirem si ja existeix un quadre de facultatiu per l'assegurança
         --   amb un import superior al que en principi li tocaria (capital pòlissa -
         --   capacitat contracte). Si existeix forçarem les quantitats que van contra
         --   el contracte en funció del import d'aquest facultatiu (w_ffalseado = 1)...
         --   També forçarem el facultatiu si es un cas de tipus "embarcacions" amb
         --   capacitats a nivell de garantia (w_switchgarant = 1)...
         w_icapital2 := registre.icapital;
         w_ifacced := NULL;
         w_ffalseado := 0;
p_traza_proceso(24, 'TRAZA_CESIONES_REA', psproces, v_nom_paquete, 'F_CESSIO.F_CES', NULL, 743,
                   'registre.cfacult:'||registre.cfacult||' registre.icapital:'||registre.icapital
                    ||' registre.icapaci:'|| registre.icapaci||' w_ifacced:'||w_ifacced||
                    ' pctiprea:'||pctiprea||' registre.scumulo:'||registre.scumulo);

         ----dbms_outpuT.put_line(' F_CES capital garantia '||registre.cgarant||' = '||registre.icapital);
		 --INFORCOL INICIO 06-05-2020 Bug 10555-10556 Facultativo Dolares/Euros
         --IF registre.icapital > registre.icapaci THEN   -- Es necessitarà facultatiu...
		 IF registre.icapital > (registre.icapaci / pac_eco_tipocambio.f_cambio (w_monpol, w_moninst, pfdatagen) ) THEN   -- Es necessitarà facultatiu...
         --INFORCOL FIN 06-05-2020 Bug 10555-10556 Facultativo Dolares/Euros
            BEGIN
               SELECT ifacced
                 INTO w_ifacced
                 FROM cuafacul
                WHERE sseguro = registre.sseguro
                  AND nriesgo = registre.nriesgo
				  --INFORCOL INICIO 06-05-2020 Bug 10555-10556 Facultativo Dolares/Euros
				  AND NVL(cgarant,0) = NVL(registre.cgarant,0)
				  --INFORCOL FIN 06-05-2020 Bug 10555-10556 Facultativo Dolares/Euros
                  AND cestado = 2
                  AND finicuf <= registre.fconini
                  AND(ffincuf > registre.fconini
                      OR ffincuf IS NULL);

p_traza_proceso(24, 'TRAZA_CESIONES_REA', psproces, v_nom_paquete, 'F_CESSIO.F_CES', NULL, 744,
                   'registre.cfacult:'||registre.cfacult||' registre.icapital:'||registre.icapital
                    ||' registre.icapaci:'|| registre.icapaci||' w_ifacced:'||w_ifacced||
                    ' pctiprea:'||pctiprea||' registre.scumulo:'||registre.scumulo);

            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  w_ifacced := NULL;
               WHEN OTHERS THEN
                  perr := 104486;
                  RETURN(perr);
            END;

            IF w_ifacced IS NOT NULL
               --INFORCOL INICIO 06-05-2020 Bug 10555-10556 Facultativo Dolares/Euros
               AND w_ifacced > (registre.icapital - (registre.icapaci / pac_eco_tipocambio.f_cambio (w_monpol, w_moninst, pfdatagen))) THEN
			   --INFORCOL FIN 06-05-2020 Bug 10555-10556 Facultativo Dolares/Euros
               w_icapital2 := registre.icapital - w_ifacced;
               w_ffalseado := 1;
            END IF;
         END IF;

         w_nomes00 := 0;
         w_volta := 0;
         w_yacedido := 0;

----dbms_outpuT.put_line(' ctiprea '||w_ctiprea);
-------------------------
-- Ple net de retenció --
-------------------------
         IF pctiprea IN(2, 3) THEN   -- Creació tram 00... 28492 AVT 28/10/2013
p_traza_proceso(24, 'TRAZA_CESIONES_REA', psproces, v_nom_paquete, 'F_CESSIO.F_CES', NULL, 745,
                   'registre.cfacult:'||registre.cfacult||' registre.icapital:'||registre.icapital
                    ||' registre.icapaci:'|| registre.icapaci||' w_ifacced:'||w_ifacced||
                    ' pctiprea:'||pctiprea||' registre.scumulo:'||registre.scumulo);

            w_volta := 1;

            -- Si te cúmul, caldrà anar a mirar què s'ha assumit d'aquest cúmul
            IF registre.scumulo IS NOT NULL THEN
               ----dbms_outpuT.put_line(' TE cumul '||registre.scumulo||'-'||registre.cgarant||'-'||registre.ipleno||'-'||registre.icapaci);
               -- Calculem el capital assumit, el ple màxim i la capacitat màxima
               --INFORCOL INICIO 06-05-2020 Bug 10555-10556 Facultativo Dolares/Euros
               --perr := pac_cesionesrea.f_ple_cumul(registre.sseguro, registre.scumulo,
               --                                    registre.cgarant, registre.fconini,
               --                                    lcapcum, lplecum, lcapacum);
               perr := pac_cesionesrea.f_ple_cumul_est_mon(registre.sseguro, registre.scumulo,
                                                   registre.cgarant, registre.fconini,
                                                   w_moninst, pfdatagen,
                                                   lcapcum, lplecum, lcapacum);
                                                                                                               
               --INFORCOL FIN 06-05-2020 Bug 10555-10556 Facultativo Dolares/Euros

               ----dbms_outpuT.put_line(' ple_cumul: '||lcapcum||'-'||lplecum||'-'||lcapacum);
               IF perr <> 0 THEN
                  RETURN perr;
               END IF;

               -- Cal actualitzar el valor del ple amb el màxim del cúmul
               IF NVL(lplecum, 0) > registre.ipleno THEN
                  registre.ipleno := lplecum;
               END IF;

               -- Cal actualitzar el valor de la capacitat amb el màxim del cúmul
               IF NVL(lcapacum, 0) > registre.icapaci THEN
                  registre.icapaci := lcapacum;
               END IF;

               -- BUG 9704 - 15/04/09 - ICV - Cambio del parametro REACUMGAR por REACUM de parempresas.
               -- 22660 AVT 16-08-2012 ho canviem de lloc
               --               SELECT cempres
               --                 INTO w_cempres
               --                 FROM seguros seg
               --                WHERE seg.sseguro = registre.sseguro;

               --  Calculamos aquí el número de garantias
               IF NVL(pac_parametros.f_parempresa_n(w_cempres, 'REACUM'), 0) = 1 THEN
                  --IF f_parinstalacion_n ('REACUMGAR') = 1 THEN
                  --FI BUG 9704  - 15/04/09 – ICV
                  -- Dividir capital fins el ple pel número de garanties acumulables per cumul, segons F_Pargaranpro_v('REACUMGAR')
                  -- (mort amb mort i IAC amb IAC) de la pòlissa tractada --> JGR
                  SELECT COUNT(DISTINCT c.cgarant)
                    INTO w_contgar
                    FROM seguros s, cesionesaux c, reariesgos r
                   WHERE sproces = psproces
                     AND(c.fanulac > registre.fconini
                         OR c.fanulac IS NULL)
                     AND(c.fregula > registre.fconini
                         OR c.fregula IS NULL)
                     AND r.scumulo = c.scumulo
                     AND r.sseguro = c.sseguro
                     AND(r.freafin > registre.fconini
                         OR r.freafin IS NULL)
                     AND r.sseguro = registre.sseguro
                     AND s.sseguro = c.sseguro
                     AND NVL(f_pargaranpro_v(s.cramo, s.cmodali, s.ctipseg, s.ccolect,
                                             pac_seguros.ff_get_actividad(s.sseguro, r.nriesgo),
                                             c.cgarant, 'REACUMGAR'),
                             c.cgarant) =
                           NVL(f_pargaranpro_v(s.cramo, s.cmodali, s.ctipseg, s.ccolect,
                                               pac_seguros.ff_get_actividad(s.sseguro,
                                                                            r.nriesgo),
                                               registre.cgarant, 'REACUMGAR'),
                               registre.cgarant);   -- 15007 AVT 23-06-2010 afegit el control del NVL

                  IF NVL(w_contgar, 0) = 0 THEN
                     w_contgar := 1;
                  END IF;

                  lcapcum := lcapcum / w_contgar;
               END IF;

               --INFORCOL INICIO 06-05-2020 Bug 10555-10556 Facultativo Dolares/Euros
               IF (pctiprea = 3 AND w_ifacced IS NOT NULL) THEN
                  w_captram := registre.icapital - w_ifacced;
               ELSE
                  w_captram := registre.ipleno - lcapcum;
               END IF;
               --INFORCOL FIN 06-05-2020 Bug 10555-10556 Facultativo Dolares/Euros

               ----dbms_outpuT.PUT_LINE(' ------------ PLE '||REGISTRE.IPLENO);
               ----dbms_outpuT.PUT_LINE(' ------------ CAPCUM '||LCAPCUM);
               ----dbms_outpuT.PUT_LINE(' ------------ CAPITAL DEL TRAM '||W_CAPTRAM);
               IF w_captram < 0 THEN
                  w_captram := 0;
               END IF;

               IF w_captram > 0 THEN
                  -- Una vegada trobat el capital que pot cedir la garantia(ella sola)
                  -- dins el cúmul, mirem la totalitat de les garanties que
                  -- van juntes més les de la pròpia pòlissa (no la garantia que tractem)
                  perr := pac_cesionesrea.f_ple_cumul_tot(registre.sseguro, registre.scumulo,
                                                          registre.cgarant, registre.fconini,
                                                          registre.scontra, registre.nversio,
                                                          lcapcum_tot, lplecum_tot);

                  ----dbms_outpuT.PUT_LINE('RETURN de ple_cumul_tot '||perr||' '||lcapcum_tot||' '||lplecum_tot);
                  IF perr <> 0 THEN
                     RETURN perr;
                  END IF;

                  w_captram_tot := lplecum_tot - lcapcum_tot;

                  IF w_captram_tot < 0 THEN
                     w_captram_tot := 0;
                  END IF;

                  -- BUG 9704 - 15/04/09 - ICV - Cambio del parametro REACUMGAR por REACUM de parempresas.
                  -- 22660 AVT 16-08-2012 ho canviem de lloc
                  --                  SELECT cempres
                  --                    INTO w_cempres
                  --                    FROM seguros seg
                  --                   WHERE seg.sseguro = registre.sseguro;
                  IF NVL(pac_parametros.f_parempresa_n(w_cempres, 'REACUM'), 0) = 1 THEN
                     --IF f_parinstalacion_n('REACUMGAR') = 1 THEN   -- DESDE
                     --FI BUG 9704  - 15/04/09 – ICV
                     w_captram_tot := w_captram_tot / w_contgar;
                  END IF;   -- HASTA

                  -- Ens quedem amb l'import menor
                  IF w_captram_tot < w_captram THEN
                     -- si és menor canviem el valor del capital del tram
                     w_captram := w_captram_tot;
                  --ELSE
                  -- si és més gran ja és correcte assumuir w_captram
                  END IF;
               END IF;
            ELSE
               --INFORCOL INICIO 06-05-2020 Bug 10555-10556 Facultativo Dolares/Euros
               IF (pctiprea = 3 AND w_ifacced IS NOT NULL) THEN
                  w_captram := registre.icapital - w_ifacced;
               ELSE        
                  w_captram := registre.ipleno;
               END IF;
			   --INFORCOL FIN 06-05-2020 Bug 10555-10556 Facultativo Dolares/Euros
               
            END IF;

            --NUNUw_resto := registre.icapital - registre.ipleno;
            w_resto := registre.icapital - w_captram;

            ----dbms_outpuT.put_line('cap tram '||w_captram);
            ----dbms_outpuT.put_line(' Resto per tram 0 '||w_resto);
            IF w_resto > 0 THEN
               w_porce := w_captram / registre.icapital;
               -->DBMS_OUTPUT.put_line('1. registre.iprirea:' || registre.iprirea);
               --INFORCOL INICIO 06-05-2020 Bug 10555-10556 Facultativo Dolares/Euros
			   --perr := f_insert_ces(w_captram, 00, NULL, 0, w_porce, psproduc);   -- 13195 AVT 16-02-2010
               IF (w_captram > 0) THEN
                  perr := f_insert_ces(w_captram, 00, NULL, 0, w_porce, psproduc);   -- 13195 AVT 16-02-2010
               END IF;
               --INFORCOL FIN 06-05-2020 Bug 10555-10556 Facultativo Dolares/Euros

               IF perr <> 0 THEN
                  RETURN perr;
               END IF;

               w_yacedido := w_yacedido + w_captram;
            ELSE
               w_nomes00 := 1;
               w_porce := 1;

               --w_res := registre.icapital;

               --IF registre.icapital = 0 THEN
               --w_porce := 1;
               --ELSE
               --   w_porce := w_res / registre.icapital;
               --END IF;
               -->DBMS_OUTPUT.put_line('2. registre.iprirea:' || registre.iprirea);
               IF pctiprea = 3
                  AND registre.icapital = 0
                  AND registre.iprirea = 0 THEN   --AVT 28/07/2014
                  NULL;
               ELSE
                  perr := f_insert_ces(registre.icapital, 00, NULL, 0, w_porce, psproduc);   -- 13195 AVT 16-02-2010

                  IF perr <> 0 THEN
                     RETURN perr;
                  END IF;
               END IF;
            END IF;
         END IF;

         IF w_nomes00 = 0 THEN   --> Resto ya es <= 0
p_traza_proceso(24, 'TRAZA_CESIONES_REA', psproces, v_nom_paquete, 'F_CESSIO.F_CES', NULL, 746,
                   'registre.cfacult:'||registre.cfacult||' registre.icapital:'||registre.icapital
                    ||' registre.icapaci:'|| registre.icapaci||' w_ifacced:'||w_ifacced||
                    ' pctiprea:'||pctiprea||' registre.scumulo:'||registre.scumulo);

            ----dbms_outpuT.put_line(' NOOOOO  NOMES 00');
            IF pctipre_seg = 1
               OR pctipre_seg = 3 THEN   -- REASEGURO QUE NUNCA SE PASA DE
               BEGIN   -- CAPACIDAD...SE FUERZA...
                  SELECT MAX(norden)
                    INTO w_norden
                    FROM tramos
                   WHERE scontra = registre.scontra
                     AND nversio = registre.nversio;
               END;
            ELSE
               w_norden := NULL;
            END IF;

p_traza_proceso(24, 'TRAZA_CESIONES_REA', psproces, v_nom_paquete, 'F_CESSIO.F_CES', NULL, 747,
                   'registre.cfacult:'||registre.cfacult||' registre.icapital:'||registre.icapital
                    ||' registre.icapaci:'|| registre.icapaci||' w_ifacced:'||w_ifacced||
                    ' pctiprea:'||pctiprea||' registre.scumulo:'||registre.scumulo||' w_norden:'||w_norden);

            FOR regtrams IN cur_trams(registre.scontra, registre.nversio) LOOP
p_traza_proceso(24, 'TRAZA_CESIONES_REA', psproces, v_nom_paquete, 'F_CESSIO.F_CES', NULL, 748,
                   'registre.cfacult:'||registre.cfacult||' registre.icapital:'||registre.icapital
                    ||' registre.icapaci:'|| registre.icapaci||' w_ifacced:'||w_ifacced||
                    ' pctiprea:'||pctiprea||' registre.scumulo:'||registre.scumulo||' w_norden:'||w_norden);

               --      El importe del primer tramo depende del número de garantías de la póliza
               --       por lo que el número de tramos no nos vale el precalculado en tabla de tramos
               --       optamos por informar simpre el capital del tramo final con el resto.
               --       Trozo comentado DESDE (*)
               --       w_captram := w_icapital2;   -- Descomentado después no hace tramos 05 facultativo

               -- Si te cúmul, calcularem el capital
               -- que s'ha assignat en aques tram, i deixarem com a
               -- capacitat el que sobri
               --dbms_outpuT.put_line('---->> 4. scontra:' || registre.scontra
               --|| ' regtrams.ctramo:' || regtrams.ctramo);
               IF registre.scumulo IS NOT NULL THEN
p_traza_proceso(24, 'TRAZA_CESIONES_REA', psproces, v_nom_paquete, 'F_CESSIO.F_CES', NULL, 749,
                   'registre.cfacult:'||registre.cfacult||' registre.icapital:'||registre.icapital
                    ||' registre.icapaci:'|| registre.icapaci||' w_ifacced:'||w_ifacced||
                    ' pctiprea:'||pctiprea||' registre.scumulo:'||registre.scumulo||' w_norden:'||w_norden||
                    ' lcaptram:'||lcaptram
                    );

                  --perr :=0;
                  -- 28777 AVT 13-11-2013 OBVIEM EL TRAM 0 DEL XL
                  lcaptram := 0;

                  IF regtrams.ctramo > 0 THEN
                     perr := pac_cesionesrea.f_captram_cumul(registre.sseguro,
                                                             registre.scumulo,
                                                             registre.cgarant,
                                                             registre.fconini,
                                                             regtrams.ctramo,
                                                             registre.scontra,
                                                             registre.nversio, lcaptram,
                                                             registre.ipleno);


p_traza_proceso(24, 'TRAZA_CESIONES_REA', psproces, v_nom_paquete, 'F_CESSIO.F_CES', NULL, 750,
                   'registre.cfacult:'||registre.cfacult||' registre.icapital:'||registre.icapital
                    ||' registre.icapaci:'|| registre.icapaci||' w_ifacced:'||w_ifacced||
                    ' pctiprea:'||pctiprea||' registre.scumulo:'||registre.scumulo||' w_norden:'||w_norden||
                    ' lcaptram:'||lcaptram);

                     IF perr <> 0 THEN
                        RETURN perr;
                     END IF;
                  END IF;

                  ----dbms_outpuT.put_line('registre.ipleno='||registre.ipleno||' regtrams.nplenos='||regtrams.nplenos||' lcaptram='||lcaptram);
                  -- CPM 26/10/06: Se modifica el calculo
                  --w_captram := (registre.ipleno * regtrams.nplenos) - lcaptram;
                  -- BUG: 12971 05-02-2010 AVT per productes que no tarifiquen és el captial del tram del contracte
                  -- BUG: 13195 16-02-2010 AVT depenent del tipus de reassegurança
p_traza_proceso(24, 'TRAZA_CESIONES_REA', psproces, v_nom_paquete, 'F_CESSIO.F_CES', NULL, 7501,
                   'registre.cfacult:'||registre.cfacult||' registre.icapital:'||registre.icapital
                    ||' registre.icapaci:'|| registre.icapaci||' w_ifacced:'||w_ifacced||
                    ' pctiprea:'||pctiprea||' registre.scumulo:'||registre.scumulo||' w_norden:'||w_norden||
                    ' lcaptram:'||lcaptram||' w_captram:'||w_captram||' registre.ipleno:'||registre.ipleno);
                  IF NVL(f_parproductos_v(w_sproduc, 'NO_REA_SGT'), 0) = 1
                     OR pctiprea = 1 THEN
                     w_captram := regtrams.itottra - lcaptram;
                  --dbms_outpuT.put_line('5. w_captram:' || w_captram);
                  ELSE
                     w_captram := (registre.icapaci - NVL(registre.ipleno, 0)) - lcaptram;   -- 28492 AVT 28/10/2013
                  --dbms_outpuT.put_line('6. w_captram:' || w_captram);
                  END IF;
p_traza_proceso(24, 'TRAZA_CESIONES_REA', psproces, v_nom_paquete, 'F_CESSIO.F_CES', NULL, 7502,
                   'registre.cfacult:'||registre.cfacult||' registre.icapital:'||registre.icapital
                    ||' registre.icapaci:'|| registre.icapaci||' w_ifacced:'||w_ifacced||
                    ' pctiprea:'||pctiprea||' registre.scumulo:'||registre.scumulo||' w_norden:'||w_norden||
                    ' lcaptram:'||lcaptram||' w_captram:'||w_captram||' registre.ipleno:'||registre.ipleno);

                  IF w_captram < 0 THEN
                     w_captram := 0;
                  END IF;
               ELSE
p_traza_proceso(24, 'TRAZA_CESIONES_REA', psproces, v_nom_paquete, 'F_CESSIO.F_CES', NULL, 751,
                   'registre.cfacult:'||registre.cfacult||' registre.icapital:'||registre.icapital
                    ||' registre.icapaci:'|| registre.icapaci||' w_ifacced:'||w_ifacced||
                    ' pctiprea:'||pctiprea||' registre.scumulo:'||registre.scumulo||' w_norden:'||w_norden||
                    ' lcaptram:'||lcaptram||' w_captram:'||w_captram||' registre.ipleno:'||registre.ipleno);

                  IF w_norden IS NULL
                     OR regtrams.norden <> w_norden THEN
                     --w_captram := registre.ipleno * regtrams.nplenos;
                     -- BUG: 12971 05-02-2010 AVT per productes que no tarifiquen és el captial del tram del contracte
                     -- BUG: 13195 16-02-2010 AVT depenent del tipus de reassegurança
                     --dbms_outpuT.put_line('7. w_sproduc:' || w_sproduc);
                     --dbms_outpuT.put_line('7. pctiprea:' || pctiprea);
                     --dbms_outpuT.put_line('7. pctiprea:' || pctiprea);
                     IF NVL(f_parproductos_v(w_sproduc, 'NO_REA_SGT'), 0) = 1
                        OR pctiprea = 1 THEN   -- Quota PART
                        -- 16263 AVT 08-10-2010
                        IF registre.icapaci < regtrams.itottra THEN
                           w_captram := registre.icapaci;
                        ELSE
                           --Ini Bug 33993-214688 KJSC 25/09/2015 TODO CEDE AL CONTRATO INDEPENDIENTEMENTE DE SI SUPERA
                           IF regtrams.ulttram = 'F' THEN
                              w_captram := registre.icapaci - NVL(regtrams.restcapaci, 0);   -- AVT BUG-0040378 03/02/2016
                           ELSE
                              w_captram := regtrams.itottra;
                           END IF;
                        --Fin Bug 33993-214688 KJSC 25/09/2015 TODO CEDE AL CONTRATO INDEPENDIENTEMENTE DE SI SUPERA
                        END IF;

                        IF pctiprea = 3 THEN
                           --w_captram := registre.icapaci;   -- 002666325/07/2013 capacitat del XL ??????????????????????
                           w_captram := registre.icapaci - NVL(registre.ipleno, 0);   -- 31921/0187652 AVT 18/09/2014
                        END IF;
                     --w_captram := regtrams.itottra;
                     --dbms_outpuT.put_line('7. w_captram:' || w_captram);
                     ELSE
                        -->>  la capacitat del tram = Capacitat - ple (si només hi ha un exedent)
                        w_captram := registre.icapaci - NVL(registre.ipleno, 0);   -- 28492 AVT 28/10/2013

                        --dbms_outpuT.put_line('8. w_captram:' || w_captram);

                        -- BUG: 12682 AVT 18-03-2010 en el cas d'haver-hi més d'un tram en un ple net de retenció
                        IF w_captram > regtrams.itottra THEN
---------------------------------------------------------------
-- 22660 AVT 13/08/2012 En cas que el ple estigui Formulat: ---
-- hem de seguir restant el ple. La manera de definir els   ---
-- trams del contractes és diferent_ SUM(ITOTTRA) = ICAPACI ---
---------------------------------------------------------------
                           IF NVL(pac_parametros.f_parempresa_n(w_cempres,
                                                                'SUM_TRAM_IGUAL_CAPIT'),
                                  0) = 1 THEN
                              hiha_formula := 0;

                              BEGIN
                                 SELECT COUNT(*)
                                   INTO hiha_formula
                                   FROM reaformula
                                  WHERE ccampo = 'IPLENO'
                                    AND scontra = registre.scontra
                                    AND nversio = registre.nversio
                                    AND cgarant = registre.cgarant;
                              EXCEPTION
                                 WHEN NO_DATA_FOUND THEN
                                    hiha_formula := 0;
                                 WHEN OTHERS THEN
                                    perr := 108423;
                                    RETURN(perr);
                              END;

                              IF hiha_formula = 0 THEN
                                 IF v_base_rea = 0 THEN
                                    w_captram := regtrams.itottra;
                                 ELSE
                                    --AGG 25/04/2014
                                    BEGIN
                                       SELECT crespue
                                         INTO v_crecimiento
                                         FROM pregungaranseg
                                        WHERE sseguro = registre.sseguro
                                          AND cgarant = registre.cgarant
                                          AND nmovimi = 1
                                          AND cpregun = 4072;
                                    EXCEPTION
                                       WHEN NO_DATA_FOUND THEN
                                          v_crecimiento := 0;
                                       WHEN OTHERS THEN
                                          NULL;
                                    END;

                                    BEGIN
                                       SELECT COUNT(1)
                                         INTO v_tiene_facul
                                         FROM cuafacul
                                        WHERE sseguro = registre.sseguro;
                                    EXCEPTION
                                       WHEN NO_DATA_FOUND THEN
                                          v_tiene_facul := 0;
                                       WHEN OTHERS THEN
                                          NULL;
                                    END;

                                    --AGG Si tiene crecimiento y tiene facultativo
                                    IF v_crecimiento > 0
                                       AND v_tiene_facul > 0 THEN
                                       DECLARE
                                          v_pcesion_orig NUMBER := 0;
                                       BEGIN
                                          SELECT pcesion
                                            INTO v_pcesion_orig
                                            FROM cesionesrea
                                           WHERE sseguro = registre.sseguro
                                             AND ctramo = 2
                                             AND cgarant = registre.cgarant
                                             AND nmovimi = 1;

                                          w_captram := registre.icapital * v_pcesion_orig / 100;
                                       EXCEPTION
                                          WHEN NO_DATA_FOUND THEN
                                             w_captram := regtrams.itottra;
                                          WHEN OTHERS THEN
                                             NULL;
                                       END;
                                    ELSE
                                       w_captram := regtrams.itottra;
                                    END IF;
                                 END IF;
                              --fin AGG 25/04/2014
                              ELSIF hiha_formula = 1
                                    AND(regtrams.itottra + registre.ipleno) <= w_ipleno THEN
                                 w_captram := w_ipleno - registre.ipleno;
                              ELSE
                                 --AGG 25/04/2014 El total del tramo ya tiene restado el pleno
                                 --   w_captram := regtrams.itottra - registre.ipleno;
                                 IF v_base_rea = 0 THEN
                                    --AGG 25/04/2014 El total del tramo ya tiene restado el pleno
                                    w_captram := regtrams.itottra;   -- - registre.ipleno;
                                 ELSE
                                    --AGG 25/04/2014
                                    BEGIN
                                       SELECT crespue
                                         INTO v_crecimiento
                                         FROM pregungaranseg
                                        WHERE sseguro = registre.sseguro
                                          AND cgarant = registre.cgarant
                                          AND nmovimi = 1
                                          AND cpregun = 4072;
                                    EXCEPTION
                                       WHEN NO_DATA_FOUND THEN
                                          v_crecimiento := 0;
                                       WHEN OTHERS THEN
                                          NULL;
                                    END;

                                    BEGIN
                                       SELECT COUNT(1)
                                         INTO v_tiene_facul
                                         FROM cuafacul
                                        WHERE sseguro = registre.sseguro;
                                    EXCEPTION
                                       WHEN NO_DATA_FOUND THEN
                                          v_tiene_facul := 0;
                                       WHEN OTHERS THEN
                                          NULL;
                                    END;

                                    --AGG Si tiene crecimiento y tiene facultativo
                                    IF v_crecimiento > 0
                                       AND v_tiene_facul > 0 THEN
                                       DECLARE
                                          v_pcesion_orig NUMBER := 0;
                                       BEGIN
                                          SELECT pcesion
                                            INTO v_pcesion_orig
                                            FROM cesionesrea
                                           WHERE sseguro = registre.sseguro
                                             AND ctramo = 2
                                             AND cgarant = registre.cgarant
                                             AND nmovimi = 1;

                                          w_captram := registre.icapital * v_pcesion_orig / 100;
                                       EXCEPTION
                                          WHEN NO_DATA_FOUND THEN
                                             w_captram := regtrams.itottra;
                                          WHEN OTHERS THEN
                                             NULL;
                                       END;
                                    ELSE
                                       w_captram := regtrams.itottra;
                                    END IF;
                                 END IF;
                              END IF;
                              --Fin AGG 25/04/2014
                           -- 22660 AVT 13/08/2012 FI -----------------------------------
                           ELSE
                              w_captram := regtrams.itottra;
                           END IF;
                        END IF;
                     --dbms_outpuT.put_line('9. w_captram:' || w_captram);
                     END IF;
                  ELSE
                     IF regtrams.norden = w_norden THEN
                        w_captram := w_icapital2;
                     END IF;
                  END IF;
               END IF;

               --       Trozo comentado HASTA (*)

               ----dbms_outpuT.put_line(' CAPITAL DEL TRAM '||W_CAPTRAM);
               IF w_switchgarant = 1 THEN   -- CASO ESPECIAL TIPO "EMBARCACIONES"...
                  w_icapital2 := registre.icapaci;
               END IF;


p_traza_proceso(24, 'TRAZA_CESIONES_REA', psproces, v_nom_paquete, 'F_CESSIO.F_CES', NULL, 7501,
                   'registre.cfacult:'||registre.cfacult||' registre.icapital:'||registre.icapital
                    ||' registre.icapaci:'|| registre.icapaci||' w_ifacced:'||w_ifacced||
                    ' pctiprea:'||pctiprea||' registre.scumulo:'||registre.scumulo||' w_norden:'||w_norden||
                    ' lcaptram:'||lcaptram||' w_captram:'||w_captram||' registre.ipleno:'||registre.ipleno||
                    ' w_volta:'||w_volta||' w_resto:'||w_resto||' w_icapital2:'||w_icapital2);

               ----dbms_outpuT.put_line(' VOLTA '||W_VOLTA);
               IF w_volta = 0 THEN
                  w_resto := w_icapital2 - w_captram;
                  w_volta := 1;
               ELSE
                  w_resto := w_resto - w_captram;
               END IF;

               ----dbms_outpuT.put_line(' RESTO '||W_RESTO);
               IF w_resto > 0 THEN
                  w_porce := w_captram / registre.icapital;

                  -->DBMS_OUTPUT.put_line('3. registre.iprirea:' || registre.iprirea);
                  IF   --w_porce = 0
                       --AND NVL(registre.scumulo, 0) <> 0
                     w_porce > 0   -- 28492 AVT 13-11-2013 ES TIRA ENRERA EL CANVI DEL 28/10/2013
                                THEN   -- 28492 AVT 28/10/2013
p_traza_proceso(24, 'TRAZA_CESIONES_REA', psproces, v_nom_paquete, 'F_CESSIO.F_CES', NULL, 7502,
                   'registre.cfacult:'||registre.cfacult||' registre.icapital:'||registre.icapital
                    ||' registre.icapaci:'|| registre.icapaci||' w_ifacced:'||w_ifacced||
                    ' pctiprea:'||pctiprea||' registre.scumulo:'||registre.scumulo||' w_norden:'||w_norden||
                    ' lcaptram:'||lcaptram||' w_captram:'||w_captram||' registre.ipleno:'||registre.ipleno||
                    ' w_volta:'||w_volta||' w_resto:'||w_resto||' w_icapital2:'||w_icapital2||
                    ' regtrams.ctramo:'||regtrams.ctramo||' w_porce:'||w_porce||' pfacult:'||pfacult);

                     perr := f_insert_ces(w_captram, regtrams.ctramo, NULL, regtrams.ncesion,
                                          w_porce, psproduc);   -- 13195 AVT 16-02-2010

                     IF perr <> 0 THEN
                        RETURN perr;
                     END IF;

                     UPDATE tramos
                        SET ncesion =(NVL(regtrams.ncesion, 0) + 1)
                      WHERE scontra = regtrams.scontra
                        AND nversio = regtrams.nversio
                        AND ctramo = DECODE(pctiprea, 3, 6, regtrams.ctramo);   -- 28492 AVT 28/10/2013

                     w_yacedido := w_yacedido + w_captram;
                  END IF;
               ELSE
                  w_res := w_icapital2 - w_yacedido;

                  IF registre.icapital = 0 THEN
                     w_porce := 1;
                  ELSE
                     w_porce := w_res / registre.icapital;
                  END IF;

                  -->DBMS_OUTPUT.put_line('4. registre.iprirea:' || registre.iprirea);
                  IF w_res > 0 THEN -- IAXIS-5361 26/05/2020
                    IF NVL(pfacult, 0) > 0 AND pctiprea = 3   -- 28492 AVT 13/11/2013 DETECTAT PER XL POS
                      THEN 
                     perr := f_insert_ces(w_res, 05, pfacult, regtrams.ncesion, w_porce,
                                          psproduc);
                  ELSE
                     perr := f_insert_ces(w_res, regtrams.ctramo, NULL, regtrams.ncesion,
                                          w_porce, psproduc);   -- 13195 AVT 16-02-2010
                    END IF;
                  END IF; -- IAXIS-5361 26/05/2020

                  IF perr <> 0 THEN
                     RETURN perr;
                  END IF;

                  UPDATE tramos
                     SET ncesion =(NVL(regtrams.ncesion, 0) + 1)
                   WHERE scontra = regtrams.scontra
                     AND nversio = regtrams.nversio
                     AND ctramo = DECODE(pctiprea, 3, 6, regtrams.ctramo);   -- 28492 AVT 28/10/2013

                  w_yacedido := w_yacedido + w_res;
                  EXIT;   -- Ja ho hem cedit tot...
               END IF;
            END LOOP;
p_traza_proceso(24, 'TRAZA_CESIONES_REA', psproces, v_nom_paquete, 'F_CESSIO.F_CES', NULL, 7503,
                   'registre.cfacult:'||registre.cfacult||' registre.icapital:'||registre.icapital
                    ||' registre.icapaci:'|| registre.icapaci||' w_ifacced:'||w_ifacced||
                    ' pctiprea:'||pctiprea||' registre.scumulo:'||registre.scumulo||' w_norden:'||w_norden||
                    ' lcaptram:'||lcaptram||' w_captram:'||w_captram||' registre.ipleno:'||registre.ipleno||
                    ' w_volta:'||w_volta||' w_resto:'||w_resto||' w_icapital2:'||w_icapital2||
                    /*' regtrams.ctramo:'||regtrams.ctramo||*/' w_porce:'||w_porce);

            IF w_resto > 0
               OR w_ffalseado = 1
               OR w_switchgarant = 1 THEN   -- Hi han cessions a facultatiu...
               BEGIN
                  SELECT ncesion
                    INTO pncesion
                    FROM cuafacul
                   WHERE sfacult = pfacult;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     ----dbms_outpuT.PUT_LINE(' 11111111111 '||registre.scontra);
                     perr := 104736;
                     RETURN(perr);
                  WHEN OTHERS THEN
                     perr := 104486;
                     RETURN(perr);
               END;
p_traza_proceso(24, 'TRAZA_CESIONES_REA', psproces, v_nom_paquete, 'F_CESSIO.F_CES', NULL, 7502,
                   'registre.cfacult:'||registre.cfacult||' registre.icapital:'||registre.icapital
                    ||' registre.icapaci:'|| registre.icapaci||' w_ifacced:'||w_ifacced||
                    ' pctiprea:'||pctiprea||' registre.scumulo:'||registre.scumulo||' w_norden:'||w_norden||
                    ' lcaptram:'||lcaptram||' w_captram:'||w_captram||' registre.ipleno:'||registre.ipleno||
                    ' w_volta:'||w_volta||' w_resto:'||w_resto||' w_icapital2:'||w_icapital2||
                    /*' regtrams.ctramo:'||regtrams.ctramo||*/' w_porce:'||w_porce||' w_ffalseado:'||w_ffalseado
                    );

               IF w_ffalseado = 1 THEN
                  w_res := w_ifacced;
               ELSE
                  w_res := registre.icapital - w_yacedido;
               END IF;

               w_porce := w_res / registre.icapital;

p_traza_proceso(24, 'TRAZA_CESIONES_REA', psproces, v_nom_paquete, 'F_CESSIO.F_CES', NULL, 7502,
                   'registre.cfacult:'||registre.cfacult||' registre.icapital:'||registre.icapital
                    ||' registre.icapaci:'|| registre.icapaci||' w_ifacced:'||w_ifacced||
                    ' pctiprea:'||pctiprea||' registre.scumulo:'||registre.scumulo||' w_norden:'||w_norden||
                    ' lcaptram:'||lcaptram||' w_captram:'||w_captram||' registre.ipleno:'||registre.ipleno||
                    ' w_volta:'||w_volta||' w_resto:'||w_resto||' w_icapital2:'||w_icapital2||
                    /*' regtrams.ctramo:'||regtrams.ctramo||*/' w_porce:'||w_porce||' w_ffalseado:'||w_ffalseado||
                    ' w_res:'||w_res||' w_porce:'||w_porce
                    );

               -->DBMS_OUTPUT.put_line('5. registre.iprirea:' || registre.iprirea);
               perr := f_insert_ces(w_res, 05, pfacult, pncesion, w_porce, psproduc);   -- 13195 AVT 16-02-2010

               IF perr <> 0 THEN
                  RETURN perr;
               --AGG 25/04/2014
               ELSE
                  IF v_base_rea = 1 THEN
                     UPDATE cuafacul
                        SET ifacced = w_res
                      WHERE sfacult = pfacult;
                  END IF;
               --fin AGG 25/04/2014
               END IF;
            END IF;
         END IF;
      ELSE   -- Es un facultatiu forçat... cfacult = 1
        p_traza_proceso(24, 'TRAZA_CESIONES_REA', psproces, v_nom_paquete, 'F_CESSIO.F_CES', NULL, 744,
                   'registre.cfacult:'||registre.cfacult);

         BEGIN
            SELECT ncesion, plocal   -- Busquem % nostre i num. cessió...
              INTO pncesion, w_plocal
              FROM cuafacul
             WHERE sfacult = pfacult;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               ----dbms_outpuT.PUT_LINE(' 22222222222 ');
               perr := 104736;
               RETURN(perr);
            WHEN OTHERS THEN
               perr := 104486;
               RETURN(perr);
         END;

         IF w_plocal IS NOT NULL THEN   -- Es crea tram 00 nostre...
            w_res := (registre.icapital * w_plocal) / 100;
            w_porce := w_plocal / 100;
            -->DBMS_OUTPUT.put_line('6. registre.iprirea:' || registre.iprirea);
            perr := f_insert_ces(w_res, 00, pfacult, pncesion, w_porce, psproduc);   -- 13195 AVT 16-02-2010

            IF perr <> 0 THEN
               RETURN perr;
            END IF;
         END IF;

         -- Tram 05 del facultatiu...
         w_porce :=(100 - NVL(w_plocal, 0));
         w_res := (registre.icapital * w_porce) / 100;
         w_porce := w_porce / 100;
         -->DBMS_OUTPUT.put_line('7. registre.iprirea:' || registre.iprirea);
         perr := f_insert_ces(w_res, 05, pfacult, pncesion, w_porce, psproduc);   -- 13195 AVT 16-02-2010

         IF perr <> 0 THEN
            RETURN perr;
         END IF;
      END IF;

      ---------
      RETURN(perr);
   END f_ces;
-- *********************************************************************
-- *********************************************************************
-- *********************************************************************
BEGIN
   -- PART 1:
   -- ******
   -- AQUI ES PRORRATEJEN LES PRIMES ANUALS DE LES GARANTIES EN FUNCIÓ DE
   -- LES DATES INICIAL I FINAL D'ASSIGNACIÓ A UN CONTRACTE...
   -- TAMBÉ S'ADEQÜEN LES PRIMES DELS CONTRACTES SI EXISTEIX UN % DE REDUCCIÓ
   -- A NIVELL DE CONTRACTE (PCEDIDO)...
   -- TAMBÉ S'OMPLE EL CAMP NAGRUPA SEGONS CVIDAGA DE CODICONTRATOS (NO VIDA O
   -- GARANTIA A GARANTIA)
   P_CONTROL_ERROR('LRB','psproces',psproces);
   w_nagrupa := 0;
   --w_nagrupavi := 0; 13195 AVT 16-02-2010
   w_porcgarant := 0;
   w_switchgarant := 0;
   w_registre := 0;

   --INI BUG CONF-250  Fecha (02/09/2016) - HRE - Contratos q1,q2,q3
   /*SELECT ctiprea
         INTO w_ctiprea
         FROM codicontratos
        WHERE scontra in (SELECT scontra
                            FROM cesionesaux
                           WHERE sproces = psproces)
          AND ROWNUM = 1;*/
   p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 1,
                      'f_cessio paso 6_0');
					  
    --INFORCOL INICIO 06-05-2020 Bug 10555-10556 Facultativo Dolares/Euros
    BEGIN
       SELECT cmoneda
         INTO w_moninst
         FROM codicontratos
        WHERE scontra = (SELECT scontra
                           FROM cesionesaux
                          WHERE sproces = psproces
                          GROUP BY scontra);
    EXCEPTION
       WHEN NO_DATA_FOUND THEN
          SELECT cmonint
            INTO w_moninst
            FROM monedas
           WHERE cidioma = pac_md_common.f_get_cxtidioma
             AND cmoneda = pac_parametros.f_parinstalacion_n ('MONEDAINST');
    END;
      --      
    SELECT cmonint
      INTO w_monpol
      FROM monedas
     WHERE cidioma = pac_md_common.f_get_cxtidioma AND cmoneda = pmoneda;
    --INFORCOL FIN 06-05-2020 Bug 10555-10556 Facultativo Dolares/Euros

   BEGIN
      SELECT cramo
        INTO v_cramo
        FROM estseguros
       WHERE sseguro = (SELECT sseguro
                          FROM cesionesaux
                         WHERE sproces = psproces
                           AND ROWNUM = 1);

      p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 1,
                      'pac_cesionesrea.f_cessio_est paso 3, psproces:'||psproces||' v_cramo:'||v_cramo);
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 1,
         'f_cessio paso 4, psproces:'||psproces);

         SELECT cramo
           INTO v_cramo
           FROM seguros
          WHERE sseguro = (SELECT sseguro
                             FROM cesionesaux
                            WHERE sproces = psproces
                              AND ROWNUM = 1);
         p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 1,
         'f_cessio paso 5, psproces:'||psproces||' v_cramo:'||v_cramo);

   END;
   p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 1,
   'f_cessio paso 6, psproces:'||psproces||' v_cramo:'||v_cramo||' pfdatagen:'||
   pfdatagen||' pmotiu:'||pmotiu);

   OPEN cur_tiprea(pac_md_common.f_get_cxtempresa, pmotiu, v_cramo, pfdatagen);
   FETCH cur_tiprea INTO w_ctiprea/*v_ctiprea*/;
   CLOSE cur_tiprea;


   --w_ctiprea := 5;
   IF (w_ctiprea = 5) THEN
      p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 1,
                      'f_cessio paso 6_1, psproces:'||psproces||' v_cramo:'||v_cramo||' pfdatagen:'||
                      pfdatagen||' pmotiu:'||pmotiu||' w_ctiprea:'||w_ctiprea);

          perr := pac_cesiones.f_cessio(psproces, pmotiu, pmoneda, pfdatagen,0, 'POL');

   ELSE
      p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 1,
                      'f_cessio paso 6_2, psproces:'||psproces||' v_cramo:'||v_cramo||' pfdatagen:'||
                      pfdatagen||' pmotiu:'||pmotiu||' w_ctiprea:'||w_ctiprea);

   --FIN BUG CONF-250  Fecha (02/09/2016) - HRE - Contratos q1,q2,q3
   -->DBMS_OUTPUT.put_line('-- DINS DE F_CESSIO ----');
   FOR regaux1 IN cur_aux_1 LOOP
      ----dbms_outpuT.put_line('IPRIREA    '||regaux1.IPRIREA        );
      ----dbms_outpuT.put_line('ICAPITAL   '||regaux1.ICAPITAL       );
      ----dbms_outpuT.put_line('IPRITARREA '||regaux1.IPRITARREA);
      ----dbms_outpuT.put_line('IDTOSEL    '||regaux1.IDTOSEL        );
      w_fconini := regaux1.fconini;

      BEGIN   -- Busquem si prima prorratejable o no...
         SELECT cempres, cduraci, fefecto, fvencim, sproduc, cramo, ctiprea,
                cmodali, ctipseg, ccolect, cactivi
           INTO w_cempres, w_cduraci, w_fefecto, w_fvencim, w_sproduc, w_cramo, w_ctiprea,
                w_cmodali, w_ctipseg, w_ccolect, w_cactivi
           FROM seguros
          WHERE sseguro = regaux1.sseguro;
      EXCEPTION
         WHEN OTHERS THEN
            perr := 101919;
            RETURN(perr);
      END;

      --AGG 08/04/2014
      p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 1,
                      'Inicio de proceso: ' || psproces || ' Motivo: ' || pmotiu || ' Moneda: '
                      || pmoneda || ' Fecha: ' || pfdatagen);
      w_ctipre_seg := w_ctiprea;   -- 22660 AVT 13/08/2012 es mante aquesta inicialització tot i que no és ? ctiprea de seguros de contratos ¿?....

      -- 21559 27/03/2012 AVT
      --BUG 21559 - INICIO - 23/05/2013 - DCT
      IF NVL(pac_parametros.f_parproducto_n(w_sproduc, 'GAR_PRINCIPAL_REA'), 0) = 1 THEN
         w_registre := w_registre + 1;

         IF w_registre = 1 THEN
            w_capital_principal := regaux1.icapital;   -- 22666 - GAG  - 27/07/2012
            w_gar_princ := regaux1.cgarant;
         END IF;
      END IF;

      -- 21559 AVT 09/03/2012 només reaprtim segons garantia principal --
      --BUG 21559 - INICIO - 23/05/2013 - DCT
      IF (NVL(pac_parametros.f_parproducto_n(w_sproduc, 'GAR_PRINCIPAL_REA'), 0) = 1
          AND w_gar_princ = regaux1.cgarant)   -- 21559 / 111590
         OR NVL(pac_parametros.f_parproducto_n(w_sproduc, 'GAR_PRINCIPAL_REA'), 0) = 0 THEN
         BEGIN   -- Busquem si hi ha % de reducció de prima...
            SELECT pcedido   --, icapaci   -- 13195 AVT 16-02-2010
              INTO w_pcedido   --, w_icapaci
              FROM contratos
             WHERE scontra = regaux1.scontra
               AND nversio = regaux1.nversio;
         ----dbms_outpuT.put_line(' reducció de prima ');
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               w_pcedido := NULL;
            WHEN OTHERS THEN
               perr := 104704;
               --AGG 08/04/2014
               p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion,
                               NULL, 2, 'Error: ' || perr);
               RETURN(perr);
         END;

         --AGG 08/04/2014
         p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL,
                         3,
                         '% Cedido: ' || w_pcedido || ' Capacidad del Contrato: ' || w_icapaci);

         ----dbms_outpuT.put_line(' pcedido '||w_pcedido);
         IF w_pcedido IS NOT NULL THEN
            w_iprirea := (regaux1.iprirea * w_pcedido) / 100;
            w_ipritarrea := (regaux1.ipritarrea * w_pcedido) / 100;
            w_idtosel := (regaux1.idtosel * w_pcedido) / 100;
         ELSE
            w_iprirea := regaux1.iprirea;
            w_ipritarrea := regaux1.ipritarrea;
            w_idtosel := regaux1.idtosel;
         END IF;

         --AGG 08/04/2014
         p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL,
                         4, 'Contrato: ' || regaux1.scontra);
----dbms_outpuT.put_line(' scontra '||regaux1.scontra);
--------------
-- AQUI ES BUSQUEN EL SPLENO,CCALIF1,CCALIF2 I IPLENO EN FUNCIÓ DEL
-- CONTRACTE/VERSIÓ ASSIGNAT...
-------------
         w_spleno := NULL;
         w_ccalif1 := NULL;
         w_ccalif2 := NULL;
         w_cgar := NULL;   -- 13195 AVT 16-02-2010
         --AGG 08/04/2014
         p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL,
                         5, 'Facultativo: ' || regaux1.cfacult);

         -- Posem aquí la par dos pq es el mateix cursor
         ----dbms_outpuT.put_line(' a f_cessio IF regaux1.cfacult '||regaux1.cfacult);
         IF regaux1.cfacult <> 1 THEN
            -- No es un facultatiu forçat...(si forçat No busquem res )
            BEGIN
               -- SELECT a.cgarant, cvidaga, spleno, ctiprea -- 13195 AVT 21-05-2010
               --  INTO w_cgar, w_cvidaga, w_spleno, w_ctiprea
               SELECT cvidaga, spleno, ctiprea
                 INTO w_cvidaga, w_spleno, w_ctiprea
                 FROM codicontratos   -- c, agr_contratos a  -- 13195 AVT 21-05-2010
                WHERE scontra = regaux1.scontra;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  perr := 104697;
                  --AGG 08/04/2014
                  p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete,
                                  v_nom_funcion, NULL, 6, 'Error: ' || perr);
                  RETURN(perr);
               WHEN OTHERS THEN
                  perr := 104516;
                  p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete,
                                  v_nom_funcion, NULL, 7, 'Error: ' || perr);
                  RETURN(perr);
            END;

            -- 13195 AVT 16-02-2010 Aquí es mira si cessions garantia a garantia (vida)...
            IF w_cvidaga = 2 THEN
               -- w_nagrupavi := w_nagrupavi + 1; AVT 16-02-2010
               -- w_nagrupa := w_nagrupavi; AVT 16-02-2010
               w_nagrupa := w_nagrupa + 1;
            ELSE
               w_nagrupa := 0;
            END IF;

            p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion,
                            NULL, 8,
                            'F_BUSCACALIFI. ws_pleno: ' || w_spleno || ' sseguro: '
                            || regaux1.sseguro);

            /*******************************************************************
                             F_BUSCACALIFI : Devuelve el ipleno y la calificacion de un riesgo
            segun el seguro y el spleno (w_spleno de CODICONTRATOS)
            ********************************************************************/
            IF w_spleno IS NOT NULL THEN
               codi_error := f_buscacalifi(regaux1.sseguro, w_spleno, w_ccalif1, w_ccalif2,
                                           w_ipleno);

               IF codi_error <> 0 THEN
                  perr := codi_error;
                  RETURN(perr);
               END IF;
            ELSE
               w_ccalif1 := NULL;
               w_ccalif2 := NULL;

               /***************************
                           w_ctiprea = 1 - Quota PART
               ***************************/
               IF w_ctiprea = 1 THEN
                  w_ipleno := 0;   -- bug 19484 AVT 24/11/2011
               /*BEGIN
                                                  SELECT itottra
                    INTO w_ipleno
                    FROM tramos
                   WHERE scontra = regaux1.scontra
                     AND nversio = regaux1.nversio
                     AND ctramo = 1;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     perr := 104713;
                     RETURN(perr);
                  WHEN OTHERS THEN
                     perr := 104714;
                     RETURN(perr);
               END;           */
               /*********************************
                              w_ctiprea = 2 - Ple NET RETENCIO
               **********************************/
               ELSIF w_ctiprea = 2 THEN
                  BEGIN
                     ----dbms_outpuT.put_line(' SELECT DEL PLE ');
                     p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete,
                                     v_nom_funcion, NULL, 9,
                                     'select del pleno. scontra: ' || regaux1.scontra
                                     || ' nversio: ' || regaux1.nversio);

                     SELECT iretenc
                       INTO w_ipleno
                       FROM contratos
                      WHERE scontra = regaux1.scontra
                        AND nversio = regaux1.nversio;

                     p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete,
                                     v_nom_funcion, NULL, 10, 'Retención Pleno: ' || w_ipleno);
                  ----dbms_outpuT.put_line('           IRETENC  = '||w_ipleno);
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        perr := 104332;
                        p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete,
                                        v_nom_funcion, NULL, 11, 'Error: ' || perr);
                        RETURN(perr);
                     WHEN OTHERS THEN
                        perr := 104704;
                        p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete,
                                        v_nom_funcion, NULL, 12, 'Error: ' || perr);
                        RETURN(perr);
                  END;
               -- 28492 AVT 28/10/2013
               /*********************************
                w_ctiprea = 3 - COBERT PER XL
               **********************************/
               ELSIF w_ctiprea = 3 THEN
                  p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete,
                                  v_nom_funcion, NULL, 13,
                                  'CTIPREA = 3 - CUBIERTO POR XL' || ' sseguro: '
                                  || regaux1.sseguro || ' fconini: ' || regaux1.fconini
                                  || ' cgarant: ' || regaux1.cgarant || ' cramo: ' || w_cramo
                                  || ' cmodali: ' || w_cmodali || ' ctipseg: ' || w_ctipseg
                                  || ' ccolect: ' || w_ccolect || ' cactivi: ' || w_cactivi
                                  || ' cevento: ' || w_cdetces);
                  --28492 AVT 13/11/2013 LA SELECT NO SERVEIX SI UN CONTRACTE COBREIS DOS O MÉS PRODUCTES.
                  perr := f_buscacontrato(regaux1.sseguro, regaux1.fconini, w_cempres,
                                          regaux1.cgarant, w_cramo, w_cmodali, w_ctipseg,
                                          w_ccolect, w_cactivi, 11, w_scontra, w_nversio,
                                          w_ipleno, w_icapaci, w_cdetces);   -- revisar evento!!!

                  IF perr <> 0 THEN
                     p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete,
                                     v_nom_funcion, NULL, 14, 'Error: ' || perr);
                     RETURN(perr);
                  END IF;
--                  BEGIN
--                     -- 28777 AVT 13-11-13
----                        SELECT icapaci
----                          INTO w_ipleno
----                          FROM contratos
----                         WHERE scontra = regaux1.scontra
----                           AND nversio = regaux1.nversio;
--                     SELECT NVL(a.ilimsub, icapaci)
--                       INTO w_ipleno
--                       FROM contratos c, agr_contratos a
--                      WHERE c.scontra = a.scontra
--                        AND c.scontra = regaux1.scontra
--                        AND c.nversio = regaux1.nversio;
--                  EXCEPTION
--                     WHEN NO_DATA_FOUND THEN
--                        perr := 104332;
--                        RETURN(perr);
--                     WHEN OTHERS THEN
--                        perr := 104704;
--                        RETURN(perr);
--                  END;
               END IF;
            END IF;

-- PART 2 BIS:
-- **********
-- AQUI ES MIRA SI ES UN CONTRACTE DE TIPUS "EMBARCACIONS" PER EL QUE
-- TENIM DE CONSIDERAR LES CAPACITATS A NIVELL DE GARANTIA (TAULA
-- "CAPGARANT") PER VEURE EL % QUE ANIRÀ A FACULTATIU ( EL % DE LA MÉS GRAN ).
-- A w_porcgarant QUEDA EL % MÉS GRAN DE SUPERACIÓ DE CAPACITAT, I QUE
-- ES TINDRÀ D'APLICAR COM A % A PASSAR A FACULTATIU PER TOTES LES
-- GARANTIES...
-- S'ADAPTA LA CAPACITAT EN FUNCIÓ D'AQUEST %...
----dbms_outpuT.put_line('capaci');
            p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion,
                            NULL, 15,
                            'CAPACIDAD Contrato: ' || regaux1.scontra || ' nversio: '
                            || regaux1.nversio || ' cgarant: ' || regaux1.cgarant);

            BEGIN
               SELECT icapaci
                 INTO w_icapacigarant
                 FROM capgarant
                WHERE scontra = regaux1.scontra
                  AND nversio = regaux1.nversio
                  AND cgarant = regaux1.cgarant;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  w_icapacigarant := NULL;
               WHEN OTHERS THEN
                  p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete,
                                  v_nom_funcion, NULL, 16, 'Error: ' || perr);
                  perr := 105756;
                  RETURN(perr);
            END;
            --INFORCOL INICIO 06-05-2020 Bug 10555-10556 Facultativo Dolares/Euros
            IF w_icapacigarant IS NOT NULL
               --AND regaux1.icapital > w_icapacigarant THEN
			   AND regaux1.icapital > ( w_icapacigarant / pac_eco_tipocambio.f_cambio (w_monpol, w_moninst, pfdatagen)) THEN
               w_switchgarant := 1;
               --w_porcaux := (100 *(regaux1.icapital - w_icapacigarant)) / regaux1.icapital;
				 w_porcaux := ( 100 * (regaux1.icapital - (w_icapacigarant / pac_eco_tipocambio.f_cambio (w_monpol, w_moninst, pfdatagen))) ) / regaux1.icapital;
            --INFORCOL FIN 06-05-2020 Bug 10555-10556 Facultativo Dolares/Euros

               IF w_porcaux > w_porcgarant THEN   -- Es selecciona el %
                  w_porcgarant := w_porcaux;   -- més gran...
               END IF;
            END IF;
         END IF;

-------------
------------
         BEGIN
            UPDATE cesionesaux
               SET iprirea = w_iprirea,
                   ipritarrea = w_ipritarrea,
                   idtosel = w_idtosel,
                   nagrupa = DECODE(nagrupa, NULL, w_nagrupa, nagrupa),
                   spleno = NVL(w_spleno, spleno),
                   ccalif1 = NVL(w_ccalif1, ccalif1),
                   ccalif2 = NVL(w_ccalif2, ccalif2),
                   ipleno = NVL(ipleno, w_ipleno)   -- s'agafa sepre el ple que vingui formulat primer
             -- Pot ser que ja estigui calculat de SGT
            WHERE  nnumlin = regaux1.nnumlin
               AND sproces = psproces;
         --       post;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               perr := 104695;
               p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion,
                               NULL, 17, 'Error: ' || perr || ' nnumlin: ' || regaux1.nnumlin);
               RETURN(perr);
            WHEN OTHERS THEN
               perr := 104696;
               p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion,
                               NULL, 18, 'Error: ' || perr || ' nnumlin: ' || regaux1.nnumlin);
               RETURN(perr);
         END;
      END IF;   -- 21559 fi
   END LOOP;

   p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 19,
                   'Fusión Registros CESIONESAUX');

------------------------------------------------------------------------
-- PART 3:
-- ******
-- AQUI ES FUSIONEN ELS REGISTRES DE "CESIONESAUX" EN FUNCIÓ DE L'IGUALTAT
-- DE RISC,SPLENO,CCALIF1,CCALIF2,SCONTRA,NVERSIO,SCUMULO,NAGRUPA...
-- UTILITZAREM EL CAMP CESTADO PER DISTINGIR ELS REGISTRES NO FUSIONATS
-- (cestado = 0) DELS FUSIONATS (cestado = 1)...
   FOR regaux2 IN cur_aux_2 LOOP
      ---- 21559 AVT 09/03/2012  A les garanties no principals tb els hi actualitzem l'estat ............
      ---- 26142 KBR 04/03/2013  Cambiamos el estado 1 por 2 para que se salte el próximo paso
      --BUG 21559 - INICIO - 23/05/2013 - DCT
      BEGIN   -- Busquem si prima prorratejable o no...
         SELECT sproduc
           INTO w_sproduc
           FROM seguros
          WHERE sseguro = regaux2.sseguro;
      EXCEPTION
         WHEN OTHERS THEN
            perr := 101919;
            p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion,
                            NULL, 20,
                            'Error: ' || perr || ' regaux2.sseguro: ' || regaux2.sseguro);
            RETURN(perr);
      END;

      IF NVL(pac_parametros.f_parproducto_n(w_sproduc, 'GAR_PRINCIPAL_REA'), 0) = 1
         AND w_gar_princ <> regaux2.cgarant THEN   -- 21559 / 111590
         UPDATE cesionesaux
            SET cestado = 2
          WHERE sproces = psproces
            AND cgarant = regaux2.cgarant;
      END IF;

      -- 21559 AVT 09/03/2012 només reaprtim segons garantia principal --
      --BUG 21559 - INICIO - 23/05/2013 - DCT
      IF (NVL(pac_parametros.f_parproducto_n(w_sproduc, 'GAR_PRINCIPAL_REA'), 0) = 1
          AND w_gar_princ = regaux2.cgarant)   -- 21559 / 111590
         OR NVL(pac_parametros.f_parproducto_n(w_sproduc, 'GAR_PRINCIPAL_REA'), 0) = 0 THEN
         w_nriesgo := regaux2.nriesgo;
         w_spleno := regaux2.spleno;
         w_ccalif1 := regaux2.ccalif1;
         w_ccalif2 := regaux2.ccalif2;
         w_scontra := regaux2.scontra;
         w_nversio := regaux2.nversio;
         w_scumulo := regaux2.scumulo;
         w_nagrupa := regaux2.nagrupa;
         w_cgarant := regaux2.cgarant;
         w_trobat := 0;

         IF regaux2.cfacult <> 1 THEN
            -- bug: 14404 AVT 25-05-2010 una mateixa pòlissa pot tenir 2 ó més contractes de tipus diferent
            BEGIN
               SELECT ctiprea
                 INTO w_ctiprea   -- 13195 AVT 16-02-2010
                 FROM codicontratos
                WHERE scontra = regaux2.scontra;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  perr := 104697;
                  p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete,
                                  v_nom_funcion, NULL, 21,
                                  'Error: ' || perr || ' regaux2.scontra: ' || regaux2.scontra);
                  RETURN(perr);
               WHEN OTHERS THEN
                  perr := 104516;
                  p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete,
                                  v_nom_funcion, NULL, 22,
                                  'Error: ' || perr || ' regaux2.scontra: ' || regaux2.scontra);
                  RETURN(perr);
            END;
         END IF;

         FOR regaux3 IN cur_aux_3 LOOP
            w_trobat := 1;

            BEGIN
               w_iprirea := regaux3.iprirea + regaux2.iprirea;
               w_ipritarrea := regaux3.ipritarrea + regaux2.ipritarrea;
               w_idtosel := regaux3.idtosel + regaux2.idtosel;

               -- Aquí busquem capital per tot el cúmul...
               IF regaux2.scumulo IS NOT NULL THEN
                  -- BUG 11100 - 16/09/2009 - FAL - Substituir crides a f_cumul per f_capital_cumul
                  cum_capital := regaux3.icapital + regaux2.icapital;
                  /*
                                    codi_error := f_cumul(w_ctiprea, regaux2.scumulo, regaux2.fconini,
                                        regaux3.cgarant, cum_capital);
                  */
                  -- w_ctiprea = 2 (PLE NET RETENCIÓ) -->> cum_capita és sempre el d'entrada
                  --INFORCOL INICIO 06-05-2020 Bug 10555-10556 Facultativo Dolares/Euros
                  --codi_error := f_capital_cumul(w_ctiprea, regaux2.scumulo, regaux2.fconini,
                  --                              regaux3.cgarant, cum_capital);
                  cum_capital := NVL (pac_eco_tipocambio.f_importe_cambio (w_monpol, w_moninst, pfdatagen, cum_capital),0);
                  codi_error := pac_cesionesrea.f_capital_cumul_mon (w_ctiprea, regaux2.scumulo, regaux2.fconini, regaux3.cgarant, 
                                                                     w_moninst, pfdatagen, cum_capital);
                  --INFORCOL FIN 06-05-2020 Bug 10555-10556 Facultativo Dolares/Euros
												
                  --FI BUG 11100 - 16/09/2009 – FAL
                  IF codi_error <> 0 THEN
                     perr := codi_error;
                     RETURN(perr);
                  ELSE
                     --INFORCOL INICIO 06-05-2020 Bug 10555-10556 Facultativo Dolares/Euros
                     --w_icapital := cum_capital;
                     w_icapital := cum_capital / pac_eco_tipocambio.f_cambio (w_monpol, w_moninst, pfdatagen);
                     --INFORCOL FIN 06-05-2020 Bug 10555-10556 Facultativo Dolares/Euros
                  END IF;
               ELSE
                  w_icapital := regaux3.icapital + regaux2.icapital;
               END IF;

               UPDATE cesionesaux
                  SET iprirea = w_iprirea,
                      ipritarrea = w_ipritarrea,
                      idtosel = w_idtosel,
                      icapital = w_icapital
                WHERE NVL(nriesgo, 0) = NVL(regaux2.nriesgo, 0)
                  AND NVL(spleno, 0) = NVL(regaux2.spleno, 0)
                  AND NVL(ccalif1, ' ') = NVL(regaux2.ccalif1, ' ')
                  AND NVL(ccalif2, 0) = NVL(regaux2.ccalif2, 0)
                  AND NVL(scontra, 0) = NVL(regaux2.scontra, 0)
                  AND NVL(nversio, 0) = NVL(regaux2.nversio, 0)
                  AND NVL(scumulo, 0) = NVL(regaux2.scumulo, 0)
                  AND NVL(nagrupa, 0) = NVL(regaux2.nagrupa, 0)
                  AND cgarant IS NULL
                  AND cestado = 1
                  AND sproces = psproces;

               --           post;
               EXIT;
            EXCEPTION
               WHEN OTHERS THEN
                  perr := 104700;
                  p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete,
                                  v_nom_funcion, NULL, 23, 'Error: ' || perr);
                  RETURN(perr);
            END;
         END LOOP;

         IF w_trobat = 0 THEN
            FOR regaux4 IN cur_aux_4 LOOP
               w_trobat := 1;

               BEGIN
                  w_iprirea := regaux4.iprirea + regaux2.iprirea;
                  w_ipritarrea := regaux4.ipritarrea + regaux2.ipritarrea;
                  w_idtosel := regaux4.idtosel + regaux2.idtosel;

                  -- Aquí busquem capital per tot el cúmul...
                  IF regaux2.scumulo IS NOT NULL THEN
                     -- BUG 11100 - 16/09/2009 - FAL - Substituir crides a f_cumul per f_capital_cumul
                     cum_capital := regaux4.icapital + regaux2.icapital;
                     /*
                                          codi_error := f_cumul(w_ctiprea, regaux2.scumulo, regaux2.fconini,
                                           regaux4.cgarant, cum_capital);
                     */
                     -- w_ctiprea = 2 (PLE NET RETENCIÓ) -->> cum_capita és sempre el d'entrada
                     --INFORCOL INICIO 06-05-2020 Bug 10555-10556 Facultativo Dolares/Euros
                     -- codi_error := f_capital_cumul(w_ctiprea, regaux2.scumulo,
                     --                              regaux2.fconini, regaux4.cgarant,
                     --                              cum_capital);
                     cum_capital := NVL (pac_eco_tipocambio.f_importe_cambio (w_monpol, w_moninst, pfdatagen, cum_capital),0);
                     codi_error := pac_cesionesrea.f_capital_cumul_mon (w_ctiprea, regaux2.scumulo, regaux2.fconini, regaux4.cgarant, 
                                                                        w_moninst, pfdatagen, cum_capital);
                     --INFORCOL FIN 06-05-2020 Bug 10555-10556 Facultativo Dolares/Euros
												   
                     --FI BUG 11100 - 16/09/2009 – FAL
                     IF codi_error <> 0 THEN
                        perr := codi_error;
                        p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete,
                                        v_nom_funcion, NULL, 24,
                                        'Error: ' || perr || ' w_iprirea: ' || w_iprirea
                                        || ' w_ipritarrea: ' || w_ipritarrea || ' w_idtosel: '
                                        || w_idtosel);
                        RETURN(perr);
                     ELSE
                        --INFORCOL INICIO 06-05-2020 Bug 10555-10556 Facultativo Dolares/Euros
                        --w_icapital := cum_capital;
                        w_icapital := cum_capital / pac_eco_tipocambio.f_cambio (w_monpol, w_moninst, pfdatagen);
                        --INFORCOL FIN 06-05-2020 Bug 10555-10556 Facultativo Dolares/Euros
                     END IF;
                  ELSE
                     w_icapital := regaux4.icapital + regaux2.icapital;
                  END IF;

                  UPDATE cesionesaux
                     SET iprirea = w_iprirea,
                         ipritarrea = w_ipritarrea,
                         idtosel = w_idtosel,
                         icapital = w_icapital,
                         cgarant = NULL
                   WHERE NVL(nriesgo, 0) = NVL(regaux2.nriesgo, 0)
                     AND NVL(spleno, 0) = NVL(regaux2.spleno, 0)
                     AND NVL(ccalif1, ' ') = NVL(regaux2.ccalif1, ' ')
                     AND NVL(ccalif2, 0) = NVL(regaux2.ccalif2, 0)
                     AND NVL(scontra, 0) = NVL(regaux2.scontra, 0)
                     AND NVL(nversio, 0) = NVL(regaux2.nversio, 0)
                     AND NVL(scumulo, 0) = NVL(regaux2.scumulo, 0)
                     AND NVL(nagrupa, 0) = NVL(regaux2.nagrupa, 0)
                     AND cgarant IS NOT NULL
                     AND NVL(cgarant, 0) <> NVL(regaux2.cgarant, 0)
                     AND cestado = 1
                     AND sproces = psproces;

                  --              post;
                  EXIT;
               EXCEPTION
                  WHEN OTHERS THEN
                     perr := 104701;
                     p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete,
                                     v_nom_funcion, NULL, 25,
                                     'Error: ' || perr || ' w_iprirea: ' || w_iprirea
                                     || ' w_ipritarrea: ' || w_ipritarrea || ' w_idtosel: '
                                     || w_idtosel || ' w_icapital: ' || w_icapital);
                     RETURN(perr);
               END;
            END LOOP;
         END IF;

         IF w_trobat = 0 THEN
            FOR regaux5 IN cur_aux_5 LOOP
               w_trobat := 1;

               BEGIN
                  w_iprirea := regaux5.iprirea + regaux2.iprirea;
                  w_ipritarrea := regaux5.ipritarrea + regaux2.ipritarrea;
                  w_idtosel := regaux5.idtosel + regaux2.idtosel;
                  p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete,
                                  v_nom_funcion, NULL, 26,
                                  'Buscamos capital por todo el cúmulo.' || ' w_iprirea: '
                                  || w_iprirea || ' w_ipritarrea: ' || w_ipritarrea
                                  || ' w_idtosel: ' || w_idtosel);

                  -- Aquí busquem capital per tot el cúmul...
                  IF regaux2.scumulo IS NOT NULL THEN
                     cum_capital := regaux5.icapital + regaux2.icapital;
                     -- BUG 11100 - 16/09/2009 - FAL - Substituir crides a f_cumul per f_capital_cumul
                     -- w_ctiprea = 2 (PLE NET RETENCIÓ) -->> cum_capita és sempre el d'entrada
                     --INFORCOL INICIO 06-05-2020 Bug 10555-10556 Facultativo Dolares/Euros
                     --codi_error := f_capital_cumul(w_ctiprea, regaux2.scumulo,
                     --                              regaux2.fconini, regaux5.cgarant,
                     --                              cum_capital);
                     cum_capital := NVL (pac_eco_tipocambio.f_importe_cambio (w_monpol, w_moninst, pfdatagen, cum_capital),0);
                     codi_error := pac_cesionesrea.f_capital_cumul_mon (w_ctiprea, regaux2.scumulo, regaux2.fconini, regaux5.cgarant,
                                                                        w_moninst, pfdatagen, cum_capital);
                     --INFORCOL FIN 06-05-2020 Bug 10555-10556 Facultativo Dolares/Euros
												   
                     --FI BUG 11100 - 16/09/2009 – FAL
                     IF codi_error <> 0 THEN
                        perr := codi_error;
                        p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete,
                                        v_nom_funcion, NULL, 27,
                                        'Error: ' || perr || 'w_ctiprea: ' || w_ctiprea
                                        || ' regaux2.scumulo: ' || regaux2.scumulo
                                        || ' regaux2.fconini:' || regaux2.fconini
                                        || ' regaux5.cgarant: ' || regaux5.cgarant);
                        RETURN(perr);
                     ELSE
                        --INFORCOL INICIO 06-05-2020 Bug 10555-10556 Facultativo Dolares/Euros
                        --w_icapital := cum_capital;
                        w_icapital := cum_capital / pac_eco_tipocambio.f_cambio (w_monpol, w_moninst, pfdatagen);
                        --INFORCOL FIN 06-05-2020 Bug 10555-10556 Facultativo Dolares/Euros
                     END IF;
                  ELSE
                     w_icapital := regaux5.icapital + regaux2.icapital;
                  END IF;

                  UPDATE cesionesaux
                     SET iprirea = w_iprirea,
                         ipritarrea = w_ipritarrea,
                         idtosel = w_idtosel,
                         icapital = w_icapital
                   WHERE NVL(nriesgo, 0) = NVL(regaux2.nriesgo, 0)
                     AND NVL(spleno, 0) = NVL(regaux2.spleno, 0)
                     AND NVL(ccalif1, ' ') = NVL(regaux2.ccalif1, ' ')
                     AND NVL(ccalif2, 0) = NVL(regaux2.ccalif2, 0)
                     AND NVL(scontra, 0) = NVL(regaux2.scontra, 0)
                     AND NVL(nversio, 0) = NVL(regaux2.nversio, 0)
                     AND NVL(scumulo, 0) = NVL(regaux2.scumulo, 0)
                     AND NVL(nagrupa, 0) = NVL(regaux2.nagrupa, 0)
                     AND cgarant IS NOT NULL
                     AND NVL(cgarant, 0) = NVL(regaux2.cgarant, 0)
                     AND cestado = 1
                     AND sproces = psproces;

                  --              post;
                  EXIT;
               EXCEPTION
                  WHEN OTHERS THEN
                     perr := 104701;
                     p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete,
                                     v_nom_funcion, NULL, 28, 'Error: ' || perr);
                     RETURN(perr);
               END;
            END LOOP;
         END IF;

         IF w_trobat = 0 THEN
            BEGIN
               w_cgar := NULL;   --RAL BUG 0035314: FACTURABLE - Reaseguro - Incidencia por movimientos Reaseguro poliza 7000280  22/06/2015

               -- 26283 KBR 14/03/2013 Incidencia al momento de hacer cúmulo para colectivos de Liberty
               IF w_cvidaga = 2
                  OR w_nagrupa <> 0
                  OR NVL(pac_parametros.f_parproducto_n(w_sproduc, 'GAR_PRINCIPAL_REA'), 0) = 1 THEN   --KBR 04/12/2013
                  w_cgar := regaux2.cgarant;
                  w_icapital := regaux2.icapital;
               ELSE
                  -- Aquí busquem capital per tot el cúmul...
                  IF regaux2.scumulo IS NOT NULL THEN
                     cum_capital := regaux2.icapital;
                     --INFORCOL INICIO 06-05-2020 Bug 10555-10556 Facultativo Dolares/Euros
                     --codi_error := f_capital_cumul(w_ctiprea, regaux2.scumulo,
                     --                              regaux2.fconini, regaux2.cgarant,
                     --                              cum_capital);
                     cum_capital := NVL (pac_eco_tipocambio.f_importe_cambio (w_monpol, w_moninst, pfdatagen, cum_capital),0);
                     codi_error := pac_cesionesrea.f_capital_cumul_mon (w_ctiprea, regaux2.scumulo, regaux2.fconini, regaux2.cgarant, w_moninst, pfdatagen, cum_capital);
                     --INFORCOL FIN 06-05-2020 Bug 10555-10556 Facultativo Dolares/Euros

                     IF codi_error <> 0 THEN
                        perr := codi_error;
                        p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete,
                                        v_nom_funcion, NULL, 29,
                                        'Error: ' || perr || ' w_ctiprea: ' || w_ctiprea
                                        || ' scumulo: ' || regaux2.scumulo || ' fconini: '
                                        || regaux2.fconini || ' cgarant: ' || regaux2.cgarant);
                        RETURN(perr);
                     ELSE
                        --INFORCOL INICIO 06-05-2020 Bug 10555-10556 Facultativo Dolares/Euros
                        --w_icapital := cum_capital;
                        w_icapital := cum_capital / pac_eco_tipocambio.f_cambio (w_monpol, w_moninst, pfdatagen);
                        --INFORCOL FIN 06-05-2020 Bug 10555-10556 Facultativo Dolares/Euros
                     END IF;
                  ELSE
                     w_icapital := regaux2.icapital;
                  END IF;
               END IF;

               -- FIN 26283 KBR 14/03/2013
               INSERT INTO cesionesaux
                           (sproces, nnumlin, sseguro,
                            iprirea, icapital, cfacult, cestado, nriesgo,
                            nmovimi, ccalif1, ccalif2, spleno,
                            cgarant, scontra, nversio, fconini,
                            fconfin, ipleno, icapaci, scumulo,
                            sfacult, nagrupa, iextrap,
                            precarg, ipritarrea, idtosel,
                            psobreprima, cdetces, fanulac,
                            fregula, iextrea,
                                             -- 22.0 - 29/11/2013 - MMM - 0028082 LCOL_A004-0008810 CLF2-4054 LISTADOS DE PRIMAS CEDIDAS VIDA PROPORCIONAL - Inicio
                                             itarifrea,
                            --AGG 08/05/2014 Se añade icomext
                            icomext)
                    -- 22.0 - 29/11/2013 - MMM - 0028082 LCOL_A004-0008810 CLF2-4054 LISTADOS DE PRIMAS CEDIDAS VIDA PROPORCIONAL - Fin
               VALUES      (regaux2.sproces,(regaux2.nnumlin * -1), regaux2.sseguro,
                            regaux2.iprirea, w_icapital,   -- 21559 AVT 13/03/2012 regaux2.icapital,
                                                           -- w_icapital  BUG:14400 03-04-2010 AVT
                                                        regaux2.cfacult, 1, regaux2.nriesgo,
                            regaux2.nmovimi, regaux2.ccalif1, regaux2.ccalif2, regaux2.spleno,
                            w_cgar, regaux2.scontra, regaux2.nversio, regaux2.fconini,
                            regaux2.fconfin, regaux2.ipleno, regaux2.icapaci, regaux2.scumulo,
                            regaux2.sfacult, regaux2.nagrupa, regaux2.iextrap,
                            regaux2.precarg, regaux2.ipritarrea, regaux2.idtosel,
                            regaux2.psobreprima, regaux2.cdetces, regaux2.fanulac,
                            regaux2.fregula, regaux2.iextrea,
                                                             -- 22.0 - 29/11/2013 - MMM - 0028082 LCOL_A004-0008810 CLF2-4054 LISTADOS DE PRIMAS CEDIDAS VIDA PROPORCIONAL - Inicio
                                                             regaux2.itarifrea,
                            --AGG 08/05/2014 Se añade icomext
                            regaux2.icomext);
                            -- 22.0 - 29/11/2013 - MMM - 0028082 LCOL_A004-0008810 CLF2-4054 LISTADOS DE PRIMAS CEDIDAS VIDA PROPORCIONAL - Fin
            --             post;
            EXCEPTION
               WHEN OTHERS THEN
                  ----dbms_outpuT.put_line(SQLERRM);
                  p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete,
                                  v_nom_funcion, NULL, 30, 'Error: ' || perr);
                  perr := 104702;
                  RETURN(perr);
            END;
         END IF;
      END IF;   -- 21559 AVT 09/03/2012 fi ----------
   END LOOP;

   p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 31,
                   'Parte 4 sproces: ' || psproces);

------------------------------------------------------------------------
-- PART 4:
-- ******
-- AQUI S'ESBORREN ELS REGISTRES DE "CESIONESAUX" AMB CESTADO A 0 PERQUÈ
-- JA S'HAN FUSIONAT...
   BEGIN
      -->P_Borrar_Jgr (88); --> BORRAR JGR
      DELETE FROM cesionesaux
            WHERE cestado = 0
              AND sproces = psproces;
   --   post;
   EXCEPTION
      WHEN OTHERS THEN
         perr := 104703;
         p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL,
                         32, 'Error: ' || perr);
         RETURN(perr);
   END;

------------------------------------------------------------------------
-- PART 5:
-- ******
-- AQUI ES BUSCA EL ICAPACI EN FUNCIO DELS PLENS...
   FOR regaux1 IN cur_aux_1 LOOP
      p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 33,
                      'Parte 5 sseguro: ' || regaux1.sseguro);

      IF regaux1.cfacult = 1 THEN   -- Es un facultatiu forçat... cfacult = 1
         EXIT;
      END IF;

      -- 21559 AVT 09/03/2012 només reaprtim segons garantia principal --
      --BUG 21559 - INICIO - 23/05/2013 - DCT
      BEGIN   -- Busquem si prima prorratejable o no...
         SELECT sproduc
           INTO w_sproduc
           FROM seguros
          WHERE sseguro = regaux1.sseguro;
      EXCEPTION
         WHEN OTHERS THEN
            perr := 101919;
            p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion,
                            NULL, 34, 'Error: ' || perr);
            RETURN(perr);
      END;

      IF (NVL(pac_parametros.f_parproducto_n(w_sproduc, 'GAR_PRINCIPAL_REA'), 0) = 1
          AND w_gar_princ = regaux1.cgarant)   -- 21559 / 111590
         OR NVL(pac_parametros.f_parproducto_n(w_sproduc, 'GAR_PRINCIPAL_REA'), 0) = 0 THEN
         -- bug: 14404 AVT 25-05-2010 una mateixa pòlissa pot tenir 2 ó més contractes de tipus diferent
         BEGIN
            SELECT ctiprea
              INTO w_ctiprea   -- 13195 AVT 16-02-2010
              FROM codicontratos
             WHERE scontra = regaux1.scontra;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               perr := 104697;
               p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion,
                               NULL, 35, 'Error: ' || perr || ' scontra: ' || regaux1.scontra);
               RETURN(perr);
            WHEN OTHERS THEN
               perr := 104516;
               p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion,
                               NULL, 36, 'Error: ' || perr || ' scontra: ' || regaux1.scontra);
               RETURN(perr);
         END;

         -- SPLENO DEFINIT A NIVELL DE CODICONTRATOS  --
         IF regaux1.spleno IS NOT NULL THEN   -- 13195 AVT 16-02-2010
            w_scontra := regaux1.scontra;
            w_nversio := regaux1.nversio;

            -- Quota part (ctiprea = 1)
            IF w_ctiprea = 1 THEN
               w_nplenos := 0;
            ELSE   -- Ple net de retenció (ctiprea = 2)
               w_nplenos := 1;
            END IF;

            FOR regtram IN cur_trams(regaux1.scontra, regaux1.nversio) LOOP
               w_nplenos := w_nplenos + regtram.nplenos;
            END LOOP;

            -- Si tenim plens definits a nivell de trams es calcula la Capacitat en base a ells --
            
            --INFORCOL INICIO 06-05-2020 Bug 10555-10556 Facultativo Dolares/Euros
            --w_icapaci := regaux1.ipleno * w_nplenos;
            w_icapaci := ( regaux1.ipleno / pac_eco_tipocambio.f_cambio (w_monpol, w_moninst, pfdatagen) ) * w_nplenos;
            --INFORCOL FIN 06-05-2020 Bug 10555-10556 Facultativo Dolares/Euros

         END IF;

         -- Modificació per que no salte facultativo
         IF w_ctipre_seg = 1
            OR w_ctipre_seg = 3 THEN
            w_switchgarant := 0;
            --KBR 30702 29/05/2014
            --w_icapaci := w_icapital;   -- regaux1.icapital; BUG: 14400 03-04-2010 AVT (Accepta tot el Caital assegurat dins del Ctr.)
            w_icapaci := regaux1.icapaci;   -- regaux1.icapital; BUG: 14400 03-04-2010 AVT (Accepta tot el Caital assegurat dins del Ctr.)

            --KBR 30702 29/05/2014
            BEGIN
               UPDATE cesionesaux
                  SET icapaci = w_icapaci   -- sempre agafem primer la que s'ha formulat
                --Per si ve calculat del SGT
               WHERE  nnumlin = regaux1.nnumlin
                  AND cgarant = regaux1.cgarant
                  AND sproces = psproces;
            --       post;
            EXCEPTION
               WHEN OTHERS THEN
                  perr := 104705;
                  p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete,
                                  v_nom_funcion, NULL, 37,
                                  'Error: ' || perr || ' nnumlin: ' || regaux1.nnumlin);
                  RETURN(perr);
            END;
         ELSE
            IF w_switchgarant = 1 THEN   -- Si tinguèssim Capacitat definida per garantia  (taula: capgarant)
               w_icapaci := regaux1.icapital -((regaux1.icapital * w_porcgarant) / 100);
            END IF;

            --KBR 30702 29/05/2014
            BEGIN
               UPDATE cesionesaux
                  SET icapaci = NVL(icapaci, w_icapaci)   -- sempre agafem primer la que s'ha formulat
                --Per si ve calculat del SGT
               WHERE  nnumlin = regaux1.nnumlin
                  AND cgarant = regaux1.cgarant
                  AND sproces = psproces;
            --       post;
            EXCEPTION
               WHEN OTHERS THEN
                  perr := 104705;
                  p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete,
                                  v_nom_funcion, NULL, 38,
                                  'Error: ' || perr || ' nnumlin: ' || regaux1.nnumlin
                                  || ' icapaci: ' || w_icapaci);
                  RETURN(perr);
            END;
         END IF;
      -- fin Modificació per que no salte facultativo
      END IF;   -- 21559 AVT 09/03/2012 fi --------------

      -- A les garanties no principals tb els hi actualitzem l'estat ............
      --BUG 21559 - INICIO - 23/05/2013 - DCT
      IF NVL(pac_parametros.f_parproducto_n(w_sproduc, 'GAR_PRINCIPAL_REA'), 0) = 1
         AND w_gar_princ <> regaux1.cgarant THEN   -- 21559 / 111590
         UPDATE cesionesaux
            SET cestado = 2
          WHERE sproces = psproces
            AND cgarant = regaux1.cgarant;
      END IF;
   END LOOP;

   ---------------------------------------------------------------------
-- PART 6:
-- ******
-- AQUI ES MIRA SI ES NECESSITA FACULTATIU I SI EXISTEIX JA...
------------------------------------------------------------------------
   perr := 0;
   pfacult := NULL;

   FOR regaux1 IN cur_aux_1 LOOP
      p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 39,
                      'Parte 6 sseguro: ' || regaux1.sseguro);

---

      -- 21559 AVT 09/03/2012 només reaprtim segons garantia principal --
      -->DBMS_OUTPUT.put_line('*** GAR_PRINCIPAL_REA regaux1.cgarant:' || regaux1.cgarant);
      --BUG 21559 - INICIO - 23/05/2013 - DCT
      --BUG 21559 - INICIO - 23/05/2013 - DCT
      --INFORCOL INI 20190412 - Se agrega el campo ramo a la consulta
      BEGIN   -- Busquem si prima prorratejable o no...
         SELECT sproduc, cramo
           INTO w_sproduc, w_cramo
           FROM seguros
          WHERE sseguro = regaux1.sseguro;
      --INFORCOL FIN 20190412 - Se agrega el campo ramo a la consulta
      EXCEPTION
         WHEN OTHERS THEN
            perr := 101919;
            p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion,
                            NULL, 40, 'Error: ' || perr);
            RETURN(perr);
      END;

      IF (NVL(pac_parametros.f_parproducto_n(w_sproduc, 'GAR_PRINCIPAL_REA'), 0) = 1
          AND w_gar_princ = regaux1.cgarant)   -- 21559 / 111590
         OR NVL(pac_parametros.f_parproducto_n(w_sproduc, 'GAR_PRINCIPAL_REA'), 0) = 0 THEN
         w_sproces := regaux1.sproces;
         w_sseguro := regaux1.sseguro;
         w_nmovimi := regaux1.nmovimi;

         -->DBMS_OUTPUT.put_line('*** GAR_PRINCIPAL_REA regaux1.cgarant:' || regaux1.cgarant);
         IF NVL(regaux1.cfacult, 0) <> 0 THEN   -- FACULTATIU FORÇAT... cfacult = 1 Frontting
            ------        buscar facultatiu...
            w_fac_princ := 1;

            IF regaux1.sfacult IS NOT NULL THEN
               w_trobat := 1;
               pfacult := regaux1.sfacult;
            ELSE
               codi_error := f_facult(regaux1.sseguro, regaux1.nriesgo, regaux1.ccalif1,
                                      regaux1.ccalif2, regaux1.cgarant, NULL, NULL,
                                      regaux1.fconini, regaux1.scumulo, w_trobat, w_cestado,
                                      pfacult, w_ifacced);

               IF codi_error <> 0 THEN
                  RETURN(codi_error);
               END IF;

-->> AVT 21/01/2014  inici control dels facultatius existents en cas de cúmul
               IF NVL(regaux1.scumulo, 0) > 0 THEN
                  BEGIN
                     SELECT COUNT(*)
                       INTO v_hiha_ces
                       FROM cesionesrea
                      WHERE sfacult = pfacult;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        v_hiha_ces := 0;
                     WHEN OTHERS THEN
                        v_hiha_ces := 0;
                        p_tab_error(f_sysdate, f_user, 'f_cessio', 1,
                                    'cesionesrea sfacult:' || pfacult,
                                    SQLCODE || ' - ' || SQLERRM);
                        p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete,
                                        v_nom_funcion, NULL, 41,
                                        'Cesión: ' || v_hiha_ces || ', Facultativo: '
                                        || pfacult);
                  END;
               ELSE
                  v_hiha_ces := 0;
               END IF;
-->> AVT 21/01/2014  fi
            END IF;

            IF w_trobat = 1
               AND v_hiha_ces = 0 THEN   -->> AVT 21/01/2014
               IF w_cestado = 2
                  AND w_ifacced = regaux1.icapital THEN
                  ------              cessió...
                  BEGIN
                     UPDATE cesionesaux
                        SET cestado = 2,
                            sfacult = pfacult
                      WHERE nnumlin = regaux1.nnumlin
                        AND sproces = psproces;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        perr := 104695;
                        p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete,
                                        v_nom_funcion, NULL, 42,
                                        'Error: ' || perr || ' nnumlin: ' || regaux1.nnumlin);
                        RETURN(perr);
                     WHEN OTHERS THEN
                        perr := 104696;
                        p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete,
                                        v_nom_funcion, NULL, 43,
                                        'Error: ' || perr || ' nnumlin: ' || regaux1.nnumlin);
                        RETURN(perr);
                  END;
               ELSE
                  ------              a taula pendent...
                  --IF w_ifacced <> regaux1.icapital THEN
                  -- nunu trec trec If pq no fa la capçalera
                  cabfacul(regaux1);

                  IF perr <> 0
                     AND perr <> 99 THEN
                     p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete,
                                     v_nom_funcion, NULL, 44, 'Error: ' || perr);
                     RETURN(perr);
                  END IF;

                  --END IF;
                  perr := 99;
                  p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete,
                                  v_nom_funcion, NULL, 45, 'Error: ' || perr);
               END IF;
            ELSE
               ------           a taula pendent...
               p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion,
                               NULL, 46, 'CABFACUL');
               cabfacul(regaux1);

               IF perr <> 0
                  AND perr <> 99 THEN
                  p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete,
                                  v_nom_funcion, NULL, 47, 'Error: ' || perr);
                  RETURN(perr);
               END IF;

               perr := 99;   -- El perr 99 significa que ja no es pot
               p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion,
                               NULL, 48, 'Error: ' || perr);
            -- fer cap cessió perquè falta algún facultatiu
            END IF;
         ELSE   -- del forçat
            --nunununu
            -- Cal veure si te cúmul per saber si excedeix del capital i va
            -- a facultatiu
            IF regaux1.scumulo IS NOT NULL THEN
               -- Buscar el capital del cúmul
               perr := pac_cesionesrea.f_ple_cumul(regaux1.sseguro, regaux1.scumulo,
                                                   regaux1.cgarant, regaux1.fconini, lcapicum,
                                                   lplecum, lcapacum);

               IF perr <> 0 THEN
                  RETURN perr;
               END IF;

               -- Cal actualitzar el valor del ple amb el màxim del cúmul
               -- 22660 AVT 13/08/2012 això funcionarà amb contractes amb el IMPLENO formulat ????????????
               IF NVL(lplecum, 0) > regaux1.ipleno
                  OR NVL(lcapacum, 0) > regaux1.icapaci THEN
                  IF NVL(lplecum, 0) > regaux1.ipleno THEN
                     regaux1.ipleno := lplecum;
                  END IF;

                  -- Cal actualitzar el valor de la capacitat amb el màxim del cúmul
                  IF NVL(lcapacum, 0) > regaux1.icapaci THEN
                     regaux1.icapaci := lcapacum;
                  END IF;

                  UPDATE cesionesaux
                     SET ipleno = regaux1.ipleno,
                         icapaci = regaux1.icapaci
                   WHERE nnumlin = regaux1.nnumlin
                     AND sproces = psproces;
               END IF;

               p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion,
                               NULL, 49,
                               'capicum: ' || lcapicum || ' lplecum: ' || lplecum
                               || ' ipleno: ' || regaux1.ipleno);
               ----dbms_outpuT.put_line('******** capicum ****' || lcapicum);
               -- Valor que podem assumir
               lassumir := regaux1.ipleno - lcapicum;

               IF lassumir < 0 THEN
                  lassumir := 0;
               END IF;

               -- Una vegada trobat el capital que pot cedir la garantia(ella sola)
               -- dins el cúmul, mirem la totalitat de les garanties que
               -- van juntes més les de la pròpia pòlissa (no la garantia que tractem)
               IF lassumir > 0 THEN
                  --INFORCOL INICIO 06-05-2020 Bug 10555-10556 Facultativo Dolares/Euros
                  --perr := pac_cesionesrea.f_ple_cumul_tot(regaux1.sseguro, regaux1.scumulo,
                  --                                        regaux1.cgarant, regaux1.fconini,
                  --                                        regaux1.scontra, regaux1.nversio,
                  --                                        lcapcum_tot, lplecum_tot);
                  perr := pac_cesionesrea.f_ple_cumul_tot_est_mon (regaux1.sseguro, regaux1.scumulo, regaux1.cgarant, regaux1.fconini, regaux1.scontra, regaux1.nversio,
                                                                   w_moninst, pfdatagen, lcapcum_tot, lplecum_tot);
                  --INFORCOL FIN 06-05-2020 Bug 10555-10556 Facultativo Dolares/Euros
				  
                  IF perr <> 0 THEN
                     RETURN perr;
                  END IF;

                  w_captram_tot := lplecum_tot - lcapcum_tot;

                  -- Ens quedem amb l'import menor
                  IF w_captram_tot < lassumir THEN
                     -- si és menor canviem el valor del capital del tram
                     lassumir := w_captram_tot;
                  --ELSE
                  -- si és més gran ja és correcte assumuir lassumir
                  END IF;
               END IF;

               -- la capacitat li restem el que NO HEM assumit encara
               lcapaci_cum := regaux1.icapaci -(regaux1.ipleno - lassumir);
               ----dbms_outpuT.put_line('************ lcapaci_cum ' || lcapaci_cum);
               p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion,
                               NULL, 50, 'Capacidad del cúmulo: ' || lcapaci_cum);

               --Cal descomptar de la capacitat el que portem assumit de cada tram
               FOR v_tram IN cur_trams(regaux1.scontra, regaux1.nversio) LOOP
                  lcapcumtram := 0;

                  -- 28777 AVT 13-112013
                  IF v_tram.ctramo > 0 THEN
                     --INFORCOL INICIO 06-05-2020 Bug 10555-10556 Facultativo Dolares/Euros
                     --perr := pac_cesionesrea.f_captram_cumul(regaux1.sseguro, regaux1.scumulo,
                     --                                        regaux1.cgarant, regaux1.fconini,
                     --                                        v_tram.ctramo, regaux1.scontra,
                     --                                        regaux1.nversio, lcapcumtram,
                     --                                        lpleno);   --nunu ???
                     perr := pac_cesionesrea.f_captram_cumul_est_mon (regaux1.sseguro, regaux1.scumulo, regaux1.cgarant, regaux1.fconini, v_tram.ctramo, regaux1.scontra, 
                                                                      regaux1.nversio, w_moninst, pfdatagen, lcapcumtram, lpleno);
                     --INFORCOL FIN 06-05-2020 Bug 10555-10556 Facultativo Dolares/Euros
                  IF perr <> 0 THEN
                        RETURN perr;
                     END IF;
                  p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion,
                               NULL, 501, 'lcapcumtram: ' || lcapcumtram||' regaux1.scumulo:'||regaux1.scumulo
                               ||' lcapaci_cum:'||lcapaci_cum);
                  END IF;

                  lcapaci_cum := lcapaci_cum - NVL(lcapcumtram, 0);   -- 22660 AVT 13/08/2012 no hauríem de restar el pleno?....
                  p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion,
                               NULL, 502, 'lcapcumtram: ' || lcapcumtram||' regaux1.scumulo:'||regaux1.scumulo
                               ||' lcapaci_cum:'||lcapaci_cum);

               END LOOP;

               IF lcapaci_cum < 0 THEN
                  lcapaci_cum := 0;
               END IF;
            ELSE
               lcapaci_cum := regaux1.icapaci;
            END IF;

            p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion,
                            NULL, 51, 'lcapaci_cum: ' || lcapaci_cum||' regaux1.icapital:'||
                            regaux1.icapital);
            --INFORCOL 042020 INICIA
            --lcapaci_cum := regaux1.icapaci;
            lcapaci_cum := lcapaci_cum / pac_eco_tipocambio.f_cambio (w_monpol, w_moninst, pfdatagen);
            --INFORCOL 042020 TERMINA
							
         -- INFORCOL INI 20191204 - El proceso no aplica para RC
            IF w_cramo <> 802 THEN
         -- INFORCOL FIN 20191204
            -- nunununu
            ----dbms_outpuT.put_line(regaux1.icapital || '>' || lcapaci_cum);
            IF regaux1.icapital > lcapaci_cum
               OR w_switchgarant = 1 THEN   -- NECESSITEM FACULTATIU...
               --  w_switchgarant = 1 -> Si tinguèssim Capacitat definida per garantia  (taula: capgarant)
               w_fac_princ := 1;
               ------        buscar facultatiu...
               codi_error := f_facult(regaux1.sseguro, regaux1.nriesgo, regaux1.ccalif1,
                                      regaux1.ccalif2, regaux1.cgarant, regaux1.scontra,
                                      regaux1.nversio, regaux1.fconini, regaux1.scumulo,
                                      w_trobat, w_cestado, pfacult, w_ifacced);

               IF codi_error <> 0 THEN
                  p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete,
                                  v_nom_funcion, NULL, 52, 'Error: ' || codi_error);
                  RETURN(codi_error);
               END IF;

-->> AVT 21/01/2014  inici control dels facultatius existents en cas de cúmul
               IF NVL(regaux1.scumulo, 0) > 0 THEN
                  BEGIN
                     SELECT COUNT(*)
                       INTO v_hiha_ces
                       FROM cesionesrea
                      WHERE sfacult = pfacult;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        v_hiha_ces := 0;
                     WHEN OTHERS THEN
                        v_hiha_ces := 0;
                        p_tab_error(f_sysdate, f_user, 'f_cessio', 1,
                                    'cesionesrea sfacult:' || pfacult,
                                    SQLCODE || ' - ' || SQLERRM);
                        p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete,
                                        v_nom_funcion, NULL, 53,
                                        'Error: ' || SQLCODE || ' - ' || SQLERRM);
                  END;
               ELSE
                  v_hiha_ces := 0;
               END IF;

-->> AVT 21/01/2014  fi

               ----dbms_outpuT.put_line(w_trobat || ' =1');
               IF w_trobat = 1
                  AND v_hiha_ces = 0 THEN   -->> AVT 21/01/2014
                  -- CPM 26/5/06: En lugar de la capacidad màxima del registro, cogemos
                  --  la capacidad del cumulo
                  ----dbms_outpuT.put_line(w_cestado || ' = 2 AND ' || w_switchgarant || ' <> 1 AND'
                  --                    || w_ifacced);
                  p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete,
                                  v_nom_funcion, NULL, 54,
                                  'Estado: ' || w_cestado || ' Garantia: ' || w_switchgarant
                                  ||' w_ifacced:'||w_ifacced||' regaux1.icapital:'||regaux1.icapital
                                  ||' lcapaci_cum:'||lcapaci_cum);

                  IF (w_cestado = 2
                      AND w_switchgarant <> 1
                      AND w_ifacced =(regaux1.icapital - lcapaci_cum))
                     OR(w_cestado = 2
                        AND w_switchgarant =
                              1   --  w_switchgarant = 1 -> Si tinguèssim Capacitat definida per garantia  (taula: capgarant)
                        AND w_ifacced =(regaux1.icapital - lcapaci_cum)) THEN
                     -------             cessió...
                     BEGIN
                        UPDATE cesionesaux
                           SET cestado = 2,
                               sfacult = pfacult
                         WHERE nnumlin = regaux1.nnumlin
                           AND sproces = psproces;
                     EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                           perr := 104695;
                           p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete,
                                           v_nom_funcion, NULL, 55, 'Error: ' || perr);
                           RETURN(perr);
                        WHEN OTHERS THEN
                           perr := 104696;
                           p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete,
                                           v_nom_funcion, NULL, 56, 'Error: ' || perr);
                           RETURN(perr);
                     END;
                  ELSE
                     p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete,
                                     v_nom_funcion, NULL, 57,
                                     'CABFACUL sseguro: ' || regaux1.sseguro);
                     cabfacul(regaux1);

                     IF perr <> 0
                        AND perr <> 99 THEN
                        p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete,
                                        v_nom_funcion, NULL, 58, 'Error: ' || perr);
                        RETURN(perr);
                     END IF;

                     perr := 99;
                     p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete,
                                     v_nom_funcion, NULL, 59, 'Error: ' || perr);
                  END IF;
               ELSE
                  -------          a taula pendent...
                  cabfacul(regaux1);

                  IF perr <> 0
                     AND perr <> 99 THEN
                     p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete,
                                     v_nom_funcion, NULL, 60, 'Error: ' || perr);
                     RETURN(perr);
                  END IF;

                  perr := 99;
                  p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete,
                                  v_nom_funcion, NULL, 61, 'Error: ' || perr);
               END IF;
            ELSE
               --AGG 24/07/2014 Cambios
               v_base_rea := NVL(pac_parametros.f_parproducto_n(w_sproduc, 'CESION_BASE_REA'),
                                 0);

               IF v_base_rea = 1 THEN
                  --DBMS_OUTPUT.put_line('fac 5');
                  codi_error := f_facult(regaux1.sseguro, regaux1.nriesgo, regaux1.ccalif1,
                                         regaux1.ccalif2, regaux1.cgarant, regaux1.scontra,
                                         regaux1.nversio, regaux1.fconini, regaux1.scumulo,
                                         w_trobat, w_cestado, pfacult, w_ifacced);

                  IF codi_error <> 0 THEN
                     p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete,
                                     v_nom_funcion, NULL, 52, 'Error: ' || codi_error);
                     RETURN(codi_error);
                  END IF;

                  BEGIN
                     UPDATE cesionesaux
                        SET cestado = 2,
                            sfacult = pfacult
                      WHERE nnumlin = regaux1.nnumlin
                        AND sproces = psproces;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        perr := 104695;
                        p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete,
                                        v_nom_funcion, NULL, 62, 'Error: ' || perr);
                        RETURN(perr);
                     WHEN OTHERS THEN
                        perr := 104696;
                        p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete,
                                        v_nom_funcion, NULL, 63, 'Error: ' || perr);
                        RETURN(perr);
                  END;
               ELSE
                  -- FIN AGG 25/04/2014
                  ------        cessió...
                  BEGIN
                     UPDATE cesionesaux
                        SET cestado = 2,
                            sfacult = NULL
                      WHERE nnumlin = regaux1.nnumlin
                        AND sproces = psproces;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        perr := 104695;
                        p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete,
                                        v_nom_funcion, NULL, 62, 'Error: ' || perr);
                        RETURN(perr);
                     WHEN OTHERS THEN
                        perr := 104696;
                        p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete,
                                        v_nom_funcion, NULL, 63, 'Error: ' || perr);
                        RETURN(perr);
                  END;
               END IF;
            END IF;
         --INFORCOL INI 20191204 - REASEGURO FACULTATTIVO PARA RC
            ELSE
              IF regaux1.icapital > lcapaci_cum
                 OR w_switchgarant = 1 THEN   -- NECESSITEM FACULTATIU...
                 --  w_switchgarant = 1 -> Si tinguèssim Capacitat definida per garantia  (taula: capgarant)
                 w_fac_princ := 1;
                 ------        buscar facultatiu...
                 codi_error := f_facult(regaux1.sseguro, regaux1.nriesgo, regaux1.ccalif1,
                                        regaux1.ccalif2, regaux1.cgarant, regaux1.scontra,
                                        regaux1.nversio, regaux1.fconini, regaux1.scumulo,
                                        w_trobat, w_cestado, pfacult, w_ifacced);
                 p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete,
                                    v_nom_funcion, NULL, 2963, 'w_ifacced: ' || w_ifacced);
                 w_ifacced := regaux1.icapital - lcapaci_cum;
                 p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete,
                                    v_nom_funcion, NULL, 2966, 'w_ifacced: ' || w_ifacced);
                 IF codi_error <> 0 THEN
                    p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete,
                                    v_nom_funcion, NULL, 2968, 'Error: ' || codi_error);
                    RETURN(codi_error);
                 END IF;

                 -->> AVT 21/01/2014  inici control dels facultatius existents en cas de cúmul
                 IF NVL(regaux1.scumulo, 0) > 0 THEN
                    BEGIN
                       SELECT COUNT(*)
                         INTO v_hiha_ces
                         FROM cesionesrea
                        WHERE sfacult = pfacult;
                    EXCEPTION
                       WHEN NO_DATA_FOUND THEN
                          v_hiha_ces := 0;
                       WHEN OTHERS THEN
                          v_hiha_ces := 0;
                          p_tab_error(f_sysdate, f_user, 'f_cessio', 1,
                                      'cesionesrea sfacult:' || pfacult,
                                      SQLCODE || ' - ' || SQLERRM);
                          p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete,
                                          v_nom_funcion, NULL, 2989,
                                          'Error: ' || SQLCODE || ' - ' || SQLERRM);
                    END;
                 ELSE
                    v_hiha_ces := 0;
                 END IF;

                 -->> AVT 21/01/2014  fi

                 ----dbms_outpuT.put_line(w_trobat || ' =1');
                 IF w_trobat = 1
                    AND v_hiha_ces = 0 THEN   -->> AVT 21/01/2014
                    -- CPM 26/5/06: En lugar de la capacidad màxima del registro, cogemos
                    --  la capacidad del cumulo
                    ----dbms_outpuT.put_line(w_cestado || ' = 2 AND ' || w_switchgarant || ' <> 1 AND'
                    --                    || w_ifacced);
                    p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete,
                                    v_nom_funcion, NULL, 3006,
                                    'Estado: ' || w_cestado || ' Garantia: ' || w_switchgarant
                                    ||' w_ifacced:'||w_ifacced||' regaux1.icapital:'||regaux1.icapital
                                    ||' lcapaci_cum:'||lcapaci_cum);

                    IF (w_cestado = 2
                        AND w_switchgarant <> 1
                        AND w_ifacced =(regaux1.icapital - lcapaci_cum))
                       OR(w_cestado = 2
                          AND w_switchgarant =
                                1   --  w_switchgarant = 1 -> Si tinguèssim Capacitat definida per garantia  (taula: capgarant)
                          AND w_ifacced =(regaux1.icapital - lcapaci_cum)) THEN
                       -------             cessió...
                       BEGIN
                          UPDATE cesionesaux
                             SET cestado = 2,
                                 sfacult = pfacult
                           WHERE nnumlin = regaux1.nnumlin
                             AND sproces = psproces;
                       EXCEPTION
                          WHEN NO_DATA_FOUND THEN
                             perr := 104695;
                             p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete,
                                             v_nom_funcion, NULL, 3029, 'Error: ' || perr);
                             RETURN(perr);
                          WHEN OTHERS THEN
                             perr := 104696;
                             p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete,
                                             v_nom_funcion, NULL, 3034, 'Error: ' || perr);
                             RETURN(perr);
                       END;
                    ELSE
                       p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete,
                                       v_nom_funcion, NULL, 3039,
                                       'CABFACUL sseguro: ' || regaux1.sseguro);
                       cabfacul(regaux1);

                       IF perr <> 0
                          AND perr <> 99 THEN
                          p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete,
                                          v_nom_funcion, NULL, 3046, 'Error: ' || perr);
                          RETURN(perr);
                       END IF;

                       perr := 99;
                       p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete,
                                       v_nom_funcion, NULL, 3051, 'Error: ' || perr);
                    END IF;
                 ELSE
                    -------          a taula pendent...
                    cabfacul(regaux1);

                    IF perr <> 0
                       AND perr <> 99 THEN
                       p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete,
                                       v_nom_funcion, NULL, 3061, 'Error: ' || perr);
                       RETURN(perr);
                    END IF;

                    perr := 99;
                    p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete,
                                    v_nom_funcion, NULL, 3067, 'Error: ' || perr);
                 END IF;
              ELSE
                 --AGG 24/07/2014 Cambios
                 v_base_rea := NVL(pac_parametros.f_parproducto_n(w_sproduc, 'CESION_BASE_REA'),
                                   0);

                 IF v_base_rea = 1 THEN
                    --DBMS_OUTPUT.put_line('fac 5');
                    codi_error := f_facult(regaux1.sseguro, regaux1.nriesgo, regaux1.ccalif1,
                                           regaux1.ccalif2, regaux1.cgarant, regaux1.scontra,
                                           regaux1.nversio, regaux1.fconini, regaux1.scumulo,
                                           w_trobat, w_cestado, pfacult, w_ifacced);

                    IF codi_error <> 0 THEN
                       p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete,
                                       v_nom_funcion, NULL, 3082, 'Error: ' || codi_error);
                       RETURN(codi_error);
                    END IF;

                    BEGIN
                       UPDATE cesionesaux
                          SET cestado = 2,
                              sfacult = pfacult
                        WHERE nnumlin = regaux1.nnumlin
                          AND sproces = psproces;
                    EXCEPTION
                       WHEN NO_DATA_FOUND THEN
                          perr := 104695;
                          p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete,
                                          v_nom_funcion, NULL, 3097, 'Error: ' || perr);
                          RETURN(perr);
                       WHEN OTHERS THEN
                          perr := 104696;
                          p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete,
                                          v_nom_funcion, NULL, 3102, 'Error: ' || perr);
                          RETURN(perr);
                    END;
                 ELSE
                    -- FIN AGG 25/04/2014
                    ------        cessió...
                    BEGIN
                       UPDATE cesionesaux
                          SET cestado = 2,
                              sfacult = NULL
                        WHERE nnumlin = regaux1.nnumlin
                          AND sproces = psproces;
                    EXCEPTION
                       WHEN NO_DATA_FOUND THEN
                          perr := 104695;
                          p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete,
                                          v_nom_funcion, NULL, 3118, 'Error: ' || perr);
                          RETURN(perr);
                       WHEN OTHERS THEN
                          perr := 104696;
                          p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete,
                                          v_nom_funcion, NULL, 3123, 'Error: ' || perr);
                          RETURN(perr);
                    END;
                 END IF;
              END IF;
            END IF;
         --INFORCOL FIN 20191204 - REASEGURO FACULTATTIVO PARA RC
         END IF;
      ELSIF NVL(pac_parametros.f_parproducto_n(w_sproduc, 'GAR_PRINCIPAL_REA'), 0) = 1
            AND w_gar_princ <> regaux1.cgarant THEN   -- A les garanties no principals tb els hi actualitzem l'estat ............
         -->DBMS_OUTPUT.put_line('abans del UPDATE regaux1.cgarant:' || regaux1.cgarant);
         -- 21559 / 111590
         -- 22237 AVT 24/05/2012 PER SI TENIM ELS QUADRES JA COMPLERTS PER LA RESTA DE GARANTIES
         IF w_fac_princ = 1 THEN
            ------        buscar facultatiu...
            codi_error := f_facult(regaux1.sseguro, regaux1.nriesgo, regaux1.ccalif1,
                                   regaux1.ccalif2, regaux1.cgarant, NULL, NULL,
                                   regaux1.fconini, regaux1.scumulo, w_trobat, w_cestado,
                                   pfacult, w_ifacced);

            IF codi_error <> 0 THEN
               RETURN(codi_error);
               p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion,
                               NULL, 64, 'Error: ' || codi_error);
            END IF;

-->> AVT 21/01/2014  inici control dels facultatius existents en cas de cúmul
            IF NVL(regaux1.scumulo, 0) > 0 THEN
               BEGIN
                  SELECT COUNT(*)
                    INTO v_hiha_ces
                    FROM cesionesrea
                   WHERE sfacult = pfacult;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     v_hiha_ces := 0;
                  WHEN OTHERS THEN
                     v_hiha_ces := 0;
                     p_tab_error(f_sysdate, f_user, 'f_cessio', 1,
                                 'cesionesrea sfacult:' || pfacult,
                                 SQLCODE || ' - ' || SQLERRM);
                     p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete,
                                     v_nom_funcion, NULL, 65,
                                     'Error: ' || SQLCODE || ' - ' || SQLERRM);
               END;
            ELSE
               v_hiha_ces := 0;
            END IF;

-->> AVT 21/01/2014  fi
            IF w_trobat = 1
               AND v_hiha_ces = 0 THEN   -->> AVT 21/01/2014
               IF w_cestado = 2 THEN   -- no controlem els capitals a les garanties secundaries....
                  ------              cessió...
                  BEGIN
                     UPDATE cesionesaux
                        SET sfacult = pfacult
                      WHERE nnumlin = regaux1.nnumlin
                        AND sproces = psproces;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        perr := 104695;
                        p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete,
                                        v_nom_funcion, NULL, 66, 'Error: ' || perr);
                        RETURN(perr);
                     WHEN OTHERS THEN
                        perr := 104696;
                        p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete,
                                        v_nom_funcion, NULL, 67, 'Error: ' || perr);
                        RETURN(perr);
                  END;
               ELSE
                  cabfacul(regaux1);

                  IF perr <> 0
                     AND perr <> 99 THEN
                     RETURN(perr);
                  END IF;

                  perr := 99;
                  p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete,
                                  v_nom_funcion, NULL, 68,
                                  'Error: ' || perr || ' sseguro: ' || regaux1.sseguro);
               END IF;
            ELSE
               ------           a taula pendent...
               cabfacul(regaux1);

               IF perr <> 0
                  AND perr <> 99 THEN
                  RETURN(perr);
               END IF;

               perr := 99;   -- El perr 99 significa que ja no es pot
               p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion,
                               NULL, 69, 'Error: ' || perr || ' sseguro: ' || regaux1.sseguro);
            -- fer cap cessió perquè falta algún facultatiu
            END IF;
         END IF;

         -- 22237 AVT 24/05/2012 FI
         UPDATE cesionesaux
            SET cestado = 3
          WHERE sproces = psproces
            AND cgarant = regaux1.cgarant
            AND nnumlin = regaux1.nnumlin;
      END IF;   -- 21559 AVT 09/03/2012  fi-----------
   END LOOP;

   ----dbms_outpuT.put_line('ffacult:' || perr);
   p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 70,
                   'Parte 7 faculativo: ' || perr);

   ------------------------------------------------------------------------
-- PART 7:
-- ******
-- AQUI ES FAN REALMENT LES CESSIONS I S'ESBORRA FACPENDIENTES SI HI HAVIA
-- QUELCOM...
-- SI ES UN SUPLEMENT (MOTIU = 04), PRIMER ES CRIDA A UNA FUNCIÓ
-- (F_ATRAS) QUE ANUL.LI LES ULTIMES CESSIONS CORRESPONENTS
-- A TOT EL SEGURO AFECTAT I CREI PARTS PRORRATEJADES EN SIGNE CONTRARI,
-- DESDE LA DATA DEL SUPLEMENT FINS AL VENCIMENT DEL SUPLEMENT...
   IF perr <> 99 THEN   -- No falta cap facultatiu...
      -- Obtenim el nº nmovigen
      BEGIN
         SELECT NVL(MAX(nmovigen), 0) + 1
           INTO lnmovigen
           FROM cesionesrea
          WHERE sseguro = w_sseguro;
      EXCEPTION
         WHEN OTHERS THEN
            lnmovigen := 1;
      END;

      IF pmotiu = 04 THEN   -- Es un suplement...
         codi_error := f_atras(psproces, w_sseguro, w_fconini, 07, pmoneda, lnmovigen,
                               pfdatagen);

         IF codi_error <> 0 THEN
            perr := codi_error;
            p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion,
                            NULL, 71, 'Error: ' || perr);
            RETURN(perr);
         END IF;
      END IF;

      FOR regaux1 IN cur_aux_1 LOOP
         --BUG 21559 - INICIO - 23/05/2013 - DCT
         BEGIN   -- Busquem si prima prorratejable o no...
            SELECT sproduc
              INTO w_sproduc
              FROM seguros
             WHERE sseguro = regaux1.sseguro;
         EXCEPTION
            WHEN OTHERS THEN
               perr := 101919;
               p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion,
                               NULL, 72, 'Error: ' || perr);
               RETURN(perr);
         END;

         w_scumulo := regaux1.scumulo;   -- AVT 15007 17-06-2010

         -->DBMS_OUTPUT.put_line('regaux1.cestado:' || regaux1.cestado);
         IF regaux1.cestado = 2 THEN
            IF regaux1.cfacult <> 1 THEN   -- AVT 16-11-2011
               -- bug: 14404 AVT 25-05-2010 una mateixa pòlissa pot tenir 2 ó més contractes de tipus diferent
               BEGIN
                  SELECT ctiprea
                    INTO w_ctiprea   -- 13195 AVT 16-02-2010
                    FROM codicontratos
                   WHERE scontra = regaux1.scontra;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     PERR := 104697;
                     P_CONTROL_ERROR('LRB','104697', regaux1.scontra);
                     p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete,
                                     v_nom_funcion, NULL, 73, 'Error: ' || perr);
                     RETURN(perr);
                  WHEN OTHERS THEN
                     perr := 104516;
                     p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete,
                                     v_nom_funcion, NULL, 74, 'Error: ' || perr);
                     RETURN(perr);
               END;
            END IF;

            -- BUG 10462: ETM:16/06/2009:--ANTES
            -- 13195 AVT 16-02-2010 afegim w_sproduc, w_ctipre a la crida a la funció F_CES

            p_traza_proceso(24, 'TRAZA_CESIONES_REA', psproces, v_nom_paquete, 'F_CESSIO', NULL, 741,
                   'regaux1.nnumlin: ' || regaux1.nnumlin||' pmotiu:'||pmotiu||' regaux1.sfacult:'||
                   regaux1.sfacult||' lnmovigen:'||lnmovigen||' w_sproduc:'||w_sproduc||' w_ctiprea:'||
                   w_ctiprea||' w_ctipre_seg:'||w_ctipre_seg);


            codi_error := f_ces(regaux1.nnumlin, pmotiu, regaux1.sfacult, lnmovigen, w_sproduc,
                                w_ctiprea, w_ctipre_seg);

            IF codi_error <> 0 THEN
               p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion,
                               NULL, 75, 'Error: ' || codi_error);
               RETURN(codi_error);
            END IF;

            --           AQUI ES CANVIA EL CTIPREA DE 3 A 0, SI ERA 3...(SENSE FACULTATIU
            --           OPCIONALMENT)...I DE 5 A 0...(SUPLEMENT AMB FACULTATIU QUE S'HA
            --           TIRAT ENDAVANT)...
            BEGIN
               IF w_ctipre_seg = 3
                  OR w_ctipre_seg = 5 THEN
                  UPDATE seguros
                     SET ctiprea = 0
                   WHERE sseguro = regaux1.sseguro;
               END IF;
            EXCEPTION
               WHEN OTHERS THEN
                  perr := 105841;
                  p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete,
                                  v_nom_funcion, NULL, 76, 'Error: ' || perr);
                  RETURN(perr);
            END;
         END IF;

         -->DBMS_OUTPUT.put_line('>>>>>>>>>>>>>>>>>>>>>> w_cempres:' || w_cempres);

         -- 21559 AVT 09/03/2012 només reaprtim segons garantia principal --
         --BUG 21559 - INICIO - 23/05/2013 - DCT
         IF NVL(pac_parametros.f_parproducto_n(w_sproduc, 'GAR_PRINCIPAL_REA'), 0) = 1
            AND w_gar_princ <> regaux1.cgarant THEN   -- 21559 / 111590
            -->DBMS_OUTPUT.put_line('>>>>>>>>>>>>>>>>>>>>>>regaux1.cgarant:' || regaux1.cgarant
            -->                  || ' regaux1.cestado:' || regaux1.cestado);
            IF regaux1.cestado = 3 THEN
               -->DBMS_OUTPUT.put_line('>>>>>>>>>>>>>>>>>>>>>>abans cursro:' || w_cramo || '-'
               -->                  || w_cmodali || '-' || w_ctipseg || '-' || w_ccolect
               -->               || '-' || w_cactivi || '-' || psproces);
               FOR reg IN garantia_principal(w_gar_princ, psproces, regaux1.sseguro,
                                             regaux1.nmovimi, pmotiu) LOOP
                  -->DBMS_OUTPUT.put_line('>>>>>>>>>>>>>>>>>>>>>despres cursro:' || w_cramo
                  -->                  || '-' || w_cmodali || '-' || w_ctipseg || '-'
                  -->               || w_ccolect || '-' || w_cactivi || '-' || psproces);
                  SELECT *
                    INTO registre
                    FROM cesionesaux
                   WHERE nnumlin = regaux1.nnumlin
                     AND sproces = psproces;

                  -- variables globals que s'estan actualitzan a F_CES INI --
                  -->>>>>>>>w_porce := reg.pcesion / 100;
                  w_nmovigen := lnmovigen;
                  avui := pfdatagen;
------------------------------------------ F_CES FI -------
-->DBMS_OUTPUT.put_line('8. registre.iprirea:' || registre.iprirea);
-- w_capital := regaux1.icapital * reg.pcesion / 100; -- 22666 - GAG  - 27/07/2012
                  
                  --INFORCOL 042020 INICIA
                  --w_capital := regaux1.icapital * reg.icapces / w_capital_principal;   -- 22666 - GAG  - 27/07/2012
                  w_capital := regaux1.icapital * ( reg.icapces / pac_eco_tipocambio.f_cambio (w_monpol, w_moninst, pfdatagen) ) / w_capital_principal;
                  --INFORCOL 042020 TERMINA

                  IF reg.ctramo = 5 THEN
                     --perr := f_insert_ces(w_capital, reg.ctramo, regaux1.sfacult, 0,  -- 22666 - GAG  - 27/07/2012
                     --                     reg.pcesion / 100, w_sproduc);             -- 22666 - GAG  - 27/07/2012
                     --INFORCOL 042020 INICIA
                     --perr := f_insert_ces(w_capital, reg.ctramo, regaux1.sfacult, 0,   -- 22666 - GAG  - 27/07/2012
                     --                     reg.icapces / w_capital_principal, w_sproduc);   -- 22666 - GAG  - 27/07/2012
                     perr := f_insert_ces(w_capital, reg.ctramo, regaux1.sfacult, 0,
                              (  reg.icapces / pac_eco_tipocambio.f_cambio (w_monpol, w_moninst, pfdatagen)) / w_capital_principal , w_sproduc);
                     --INFORCOL 042020 TERMINA
                  
                  ELSE
                     --perr := f_insert_ces(w_capital, reg.ctramo, NULL, 0, reg.pcesion  -- 22666 - GAG  - 27/07/2012
                     --/  100, w_sproduc);                      -- 22666 - GAG  - 27/07/2012
                     perr := f_insert_ces(w_capital, reg.ctramo, NULL, 0,   -- 22666 - GAG  - 27/07/2012
                                          reg.icapces / w_capital_principal, w_sproduc);   -- 22666 - GAG  - 27/07/2012
                  END IF;

                  IF perr <> 0 THEN
                     p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete,
                                     v_nom_funcion, NULL, 77, 'Error: ' || perr);
                     RETURN(perr);
                  END IF;
               END LOOP;
            END IF;
         END IF;   -- 21559 AVT 09/03/2012 -------------
      END LOOP;
   --   ELSIF perr = 99 THEN   -- 21559 AVT 09/03/2012 només reaprtim segons garantia principal --
   --      FOR regaux1 IN cur_aux_1 LOOP
   --         IF NVL(pac_parametros.f_parempresa_n(w_cempres, 'GAR_PRINCIPAL_REA'), 0) = 1
   --            AND w_gar_princ <> regaux1.cgarant THEN   -- 21559 / 111590
   --            cabfacul(regaux1);

   --            IF perr <> 0
   --               AND perr <> 99 THEN
   --               RETURN(perr);
   --            END IF;
   --         END IF;
   --      END LOOP;
   END IF;

   p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 78,
                   'Parte 8 sseguro : ' || w_sseguro);

------------------------------------------------------------------------
-- PART 8:
-- ******
-- AIXO ES EL FINAL...
--      AQUI ESBORREM QUALSEVOL COSA QUE HI HAGI A LA TAULA CESIONESAUX...

   --IF perr = 0          -- 9. 20606: LCOL_T004-LCOL_T001- Recalcul de les cessions - Nota:0101205
   --   OR perr = 99 THEN -- 9. 20606: LCOL_T004-LCOL_T001- Recalcul de les cessions - Nota:0101205
   BEGIN
      DELETE FROM cesionesaux
            WHERE sproces = psproces;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         NULL;
      WHEN OTHERS THEN
         perr := 104703;
         p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL,
                         79, 'Error: ' || perr);
         RETURN(perr);
   END;

   -- 15007 AVT 17-06-2010 En cas de suplement d'una pòlissa amb cúmul recalculem la resta de pòlisses --
   IF perr = 0   -- 9. 20606: LCOL_T004-LCOL_T001- Recalcul de les cessions - Nota:0101205
      AND pmotiu = 04
      AND w_scumulo IS NOT NULL
      AND NVL(pfacult, 0) = 0 THEN   -- 19484 AVT 04/01/2012 Només recosntruirem la resta de cessions sinó necessita quadre facultatiu
      --BUG 19484 - 19/10/2011 - JRB - Se añade la empresa por parámetro.
      SELECT cempres
        INTO w_cempres
        FROM seguros seg
       WHERE seg.sseguro = w_sseguro;

      codi_error := pac_cesionesrea.f_recalcula_cumul(w_sseguro, w_fconini, psproces,
                                                      w_cempres);

      IF codi_error <> 0 THEN
         perr := codi_error;
         p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL,
                         80, 'Error: ' || perr);
         RETURN(perr);
      ELSE
         BEGIN
            DELETE FROM cesionesaux
                  WHERE sproces = psproces;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               NULL;
            WHEN OTHERS THEN
               perr := 104703;
               p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion,
                               NULL, 81, 'Error: ' || perr);
               RETURN(perr);
         END;
      END IF;
   END IF;

   -- 15007 AVT 17-06-2010 FI ---------------------------------------------------------------------------
   -- BUG: 22686 - AVT -25/07/2012 es dona de baixa la pòlissa que tot i formar part del cúmul ja està anulada
   IF perr = 0
      AND pmotiu IN(03, 05)
      AND w_scumulo IS NOT NULL
      AND NVL(pfacult, 0) = 0 THEN
      -- es busquen pòlisses del cúmul anul·lades
      FOR reg IN riesgos_anul(w_scumulo) LOOP
         codi_error := pac_anulacion.f_baja_rea(reg.sseguro, reg.fanulac, pmoneda);

         IF codi_error <> 0 THEN
            perr := codi_error;
            p_tab_error(f_sysdate, f_user, 'f_cessio', 1,
                        'pac_anulacion.f_baja_rea:' || reg.sseguro || ' - ' || reg.fanulac
                        || ' - ' || pmoneda,
                        codi_error);
            p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion,
                            NULL, 82, 'Error: ' || perr);
            RETURN(perr);
         END IF;
      END LOOP;
   END IF;

   --BUG 36059 - dct - 02/09/2015
   --KBR 10/06/2015 Se agrega esta validación para evitar cumulos huerfanos en REARIESGOS QT-PROD 18759
   DELETE FROM reariesgos r
         WHERE r.sseguro = w_sseguro
           AND NOT EXISTS(SELECT 1
                            FROM cesionesrea c1
                           WHERE c1.sseguro = r.sseguro
                             AND c1.scumulo = r.scumulo
                          UNION
                          SELECT 1
                            FROM cesionesaux c2
                           WHERE c2.sseguro = r.sseguro
                             AND c2.scumulo = r.scumulo);

   p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 83,
                   'Fin Proceso. Error: ' || perr);
   -- BUG: 22686 - AVT -25/07/2012  fi -------------------------
   END IF;--BUG CONF-250  Fecha (02/09/2016) - HRE
   RETURN(perr);
EXCEPTION
   WHEN OTHERS THEN
      p_tab_error(f_sysdate, f_user, 'F_Cessio =' || psproces, NULL,
                  SUBSTR('error incontrolado', 1, 500), SQLERRM);
      ----dbms_outpuT.PUT_LINE(SQLERRM );
      p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 84,
                      'Error: ' || SQLCODE || ' - ' || SQLERRM);
      RETURN(perr);
END f_cessio;

/

  GRANT EXECUTE ON "AXIS"."F_CESSIO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_CESSIO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_CESSIO" TO "PROGRAMADORESCSI";
