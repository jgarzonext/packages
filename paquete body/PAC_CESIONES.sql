/* Formatted on 2019/12/17 16:00 (Formatter Plus v4.8.8) */
--------------------------------------------------------
--  DDL for Package Body PAC_CESIONES
--------------------------------------------------------

CREATE OR REPLACE PACKAGE BODY pac_cesiones
IS
  /******************************************************************************
   NOMBRE:     PAC_CESIONES
   PROPÓSITO:  Funciones cesiones al reaseguro (personalización Confianza)
   REVISIONES:
   Ver    Fecha        Autor             Descripción
   -----  ----------  -------- ------------------------------------
   1.0    27/04/2020   DFR     1. Creación cabecera de paquete para llevar trazabilidad de los cambios 
   2.0    27/04/2020   DFR     2. IAXIS-12992: Cesión en contratos con más de un tramo. 
   3.0    26/05/2020   DFR     3. IAXIS-5361: Modificar el facultativo antes de la emisión
  ******************************************************************************/
   w_ctiprea          seguros.ctiprea%TYPE        := 1;
----BUG CONF-695  Fecha (29/05/2017) - HRE - Redistribucion Reaseguros, cumulos, Esta funcionalidad aplica solamente para cuotas partes
   v_porc_min_disp    NUMBER;
--porcentaje minimo disponible del consorcio/tomador en el tramo, BUG CONF-298  Fecha (23/03/2017) - HRE - cumulos
   v_formula          sgt_formulas.formula%TYPE;
   v_reparte_q3       NUMBER (1)                  := 0;
                                               --No reparte al q3 por defecto
   v_claveq3          sgt_formulas.clave%TYPE     := 999783;
                                                         --formula para el q3
   vnerror            NUMBER;
   psesion            PLS_INTEGER;
   v_capareal         NUMBER;
   lcapcumtram        NUMBER                      := 0;
            --BUG CONF-620  Fecha (01/03/2017) - HRE - Reaseguro moneda local
   lpleno             NUMBER                      := 0;
            --BUG CONF-620  Fecha (01/03/2017) - HRE - Reaseguro moneda local
   lcapcumtram_ret    NUMBER                      := 0;
            --BUG CONF-620  Fecha (01/03/2017) - HRE - Reaseguro moneda local
   lpleno_ret         NUMBER                      := 0;
            --BUG CONF-620  Fecha (01/03/2017) - HRE - Reaseguro moneda local
   lcapaci_cum        NUMBER;
   --INI BUG CONF-620  Fecha (01/03/2017) - HRE - Reaseguro moneda local
   w_moninst          monedas.cmonint%TYPE;
   w_monpol           monedas.cmonint%TYPE;
   w_pfdatagen        DATE;
   w_scesrea          NUMBER (8);
                           --BUG CONF-298  Fecha (23/03/2017) - HRE - cumulos
   v_tomador          per_personas.sperson%TYPE;
                           --BUG CONF-298  Fecha (23/03/2017) - HRE - cumulos
  					   
   v_consorcio        VARCHAR2 (1);
                           --BUG CONF-298  Fecha (23/03/2017) - HRE - cumulos
   w_tipper           VARCHAR2 (1);
                           --BUG CONF-298  Fecha (23/03/2017) - HRE - cumulos
   --FIN BUG CONF-620  - Fecha (01/03/2017) - HRE
   v_lim_ret_global   NUMBER                      := 300000000;
   v_lim_ret_cum      NUMBER                      := 500000000;
   v_ctiprea          seguros.ctiprea%TYPE;
                                   ----BUG CONF-695  Fecha (29/05/2017) - HRE
   v_ctipcoa          seguros.ctipcoa%TYPE;                  ----COA ACEPTADO
   v_cgesfac          NUMBER;
   w_facmod           NUMBER := 0; -- IAXIS-5361 26/05/2020 

   CURSOR cur_capacontra (wscontra NUMBER, wnversio NUMBER, p_q3 NUMBER)
   IS
      SELECT SUM (t.itottra)
        FROM tramos t
       WHERE t.scontra = wscontra                          --registre.scontra
         AND t.nversio = wnversio                           --registre.nversio
         AND (ctramo != 3 OR (ctramo = 3 AND p_q3 = 1));

   --INI BUG CONF-298 Fecha (23/03/2017) - HRE - Cumulos
   CURSOR cur_consorcio (
      psperson     per_personas.sperson%TYPE,
      pconsorcio   VARCHAR2
   )
   IS
      SELECT   sperson_rel sperson, pparticipacion, 'P' tip_per --participante
          FROM per_personas_rel
         WHERE sperson = psperson AND ctipper_rel = 0 AND pconsorcio = 'S'
      UNION ALL
      SELECT   psperson, 100, 'C'                                  --consorcio
          FROM DUAL
         WHERE pconsorcio = 'S'
      UNION ALL
      SELECT   psperson, 100, 'I'                         --cliente individual
          FROM DUAL
         WHERE pconsorcio = 'N'
      ORDER BY 3, 2 DESC;

   --FIN BUG CONF-298  - Fecha (23/03/2017) - HRE
   FUNCTION f_ces_qn (
      pnnumlin      IN   NUMBER,
      pmotiu        IN   NUMBER,
      pfacult       IN   NUMBER,
      pnmovigen     IN   NUMBER,
      psproduc      IN   NUMBER,
      pctiprea      IN   NUMBER,
      pctipre_seg   IN   NUMBER,                                             --
      psproces           NUMBER,
      v_base_rea         NUMBER,
      pfdatagen     IN   DATE,
      ptablas       IN   VARCHAR2 DEFAULT 'EST'
   )
      RETURN NUMBER
   IS
      /***********************************************************************
                                                    F_CES        : Realitza realment la cessió, creant registres
      a "CESIONESREA".
      ***********************************************************************/
      perr                NUMBER                      := 0;
      w_captram           NUMBER;
      w_captram_cons      NUMBER;
                           --BUG CONF-298  Fecha (23/03/2017) - HRE - Cumulos
      w_resto             NUMBER;
      w_resto_consorcio   NUMBER;
                           --BUG CONF-298  Fecha (23/03/2017) - HRE - Cumulos
      w_resto_total       NUMBER;
                           --BUG CONF-298  Fecha (23/03/2017) - HRE - Cumulos
      w_volta             NUMBER (2);
      w_yacedido          NUMBER;
      w_porce             NUMBER;       -- Falta de precisión NUMBER (10, 7);
      w_iprirea           cesionesaux.iprirea%TYPE;
      w_res               cesionesaux.iprirea%TYPE;
      w_scesrea           cesionesrea.scesrea%TYPE;
      w_nomes00           NUMBER (1);
      w_cramo             NUMBER (8);
      w_icapital2         cesionesaux.icapital%TYPE;
      w_ffalseado         NUMBER (1);
      w_ifacced           cuafacul.ifacced%TYPE;
      w_norden            tramos.norden%TYPE;
      lcapcum             NUMBER;
      lplecum             NUMBER;
      lcapacum            NUMBER;
      lcaptram            NUMBER;
      lcapcum_tot         NUMBER;
      lplecum_tot         NUMBER;
      w_captram_tot       NUMBER;
      w_contgar           NUMBER;
      w_cramo             seguros.cramo%TYPE;
      w_cmodali           seguros.cmodali%TYPE;
      w_ctipseg           seguros.ctipseg%TYPE;
      w_ccolect           seguros.ccolect%TYPE;
      w_cactivi           seguros.cactivi%TYPE;
      w_cempres           seguros.cempres%TYPE;
      --hiha_formula   NUMBER;   -- 22660 AVT 13/08/2012
      v_porcaux           NUMBER                      := 1;
                             --porcentaje que se va calculando e cada proceso
      v_cescont           NUMBER;
      v_indporc           NUMBER                      := 0;
------------------------------------------
      registre            cesionesaux%ROWTYPE;
      --registre_0     cesionesaux%ROWTYPE;
      v_crecimiento       NUMBER;
      v_tiene_facul       NUMBER;
      w_ipleno            NUMBER;
      --w_switchgarant NUMBER;
      pncesion            NUMBER;
      w_plocal            NUMBER;
      avui                DATE;
      w_nmovigen          NUMBER;
      w_sproduc           NUMBER;
      v_limpol            NUMBER;
      v_limcum            NUMBER;
      count_cum           NUMBER;
                       --FEPP  06/09/2019 IAXIS-4773 CONTADOR PARA ACUMULADOS
      acum_cum            NUMBER;
 --FEPP FIN 06/09/2019 IAXIS-4773 ACUMULADOR DEL VALOR DE POLIZAS DEL TOMADOR
      v_scontra           contratos.scontra%TYPE;
      v_nversio           contratos.nversio%TYPE;
      v_lim_retencion     NUMBER;
      --v_formula sgt_formulas.formula%TYPE;
      v_clave             sgt_formulas.clave%TYPE     := 999785;
      --v_clave_ret_cum sgt_formulas.clave%TYPE := 999786;
      --v_ctiprea seguros.ctiprea%TYPE;----BUG CONF-695  Fecha (29/05/2017) - HRE
      v_pcapcum           NUMBER;
      v_picapaci          NUMBER;
      v_lim_ret           NUMBER;
      v_lim_cum           NUMBER;
      --v_lim_ret_cum NUMBER;
      v_porcutoff         NUMBER;
	  
	  --INI IAXIS BUG 13246 AABG: Variable para facultativo cesion manual
      v_valor_facult      NUMBER := 0;
      --FIN IAXIS BUG 13246 AABG: Variable para facultativo cesion manual
	 
           --BUG CONF-910  Fecha (12/07/2017) - HRE - Ajuste Contratos Cutoff

      TYPE tb_porc_disp IS TABLE OF NUMBER
         INDEX BY BINARY_INTEGER;
                           --BUG CONF-298  Fecha (23/03/2017) - HRE - Cumulos

      tb_pocentajes       tb_porc_disp;
                           --BUG CONF-298  Fecha (23/03/2017) - HRE - Cumulos

      --INI BUG CONF-910 Fecha (12/07/2017) - HRE - Ajuste Contratos Cutoff
      CURSOR cur_cutoff (
         pscontra   cuadroces.scontra%TYPE,
         pnversio   cuadroces.nversio%TYPE,
         pctramo    cuadroces.ctramo%TYPE
      )
      IS
         SELECT NVL (SUM (pcesion), 0)
           FROM cuadroces cce, companias cia
          WHERE cce.ccompani = cia.ccompani
            AND cia.ctipcom = 0
            AND cia.fbaja IS NOT NULL
            AND scontra = pscontra
            AND nversio = pnversio
            AND cce.ctramo = pctramo;

      --FIN BUG CONF-910  - Fecha (12/07/2017) - HRE
      --v_claveq3 sgt_formulas.clave%TYPE := 999783;--formula para el q3
      --v_reparte_q3 NUMBER(1) := 0;--No reparte al q3 por defecto
      CURSOR cur_trams (wscontra NUMBER, wnversio NUMBER, p_q3 NUMBER)
      IS
         SELECT   t.scontra, t.nversio,
                  DECODE (t.ctramo, 6, 0, t.ctramo) ctramo, t.itottra,
                  t.norden, t.ncesion, t.plocal,
                  DECODE (t.norden,
                          (SELECT MAX (t2.norden)
                             FROM tramos t2
                            WHERE t2.scontra = t.scontra
                              AND t2.nversio = t.nversio), 'F',
                          ''
                         ) ulttram,
                  (SELECT SUM (t3.itottra)
                     FROM tramos t3
                    WHERE t3.scontra = t.scontra
                      AND t3.nversio = t.nversio
                      AND t3.norden < t.norden) restcapaci
             FROM tramos t
            WHERE t.scontra = wscontra                      --registre.scontra
              AND t.nversio = wnversio                      --registre.nversio
              AND (ctramo != 3 OR (ctramo = 3 AND p_q3 = 1))
         ORDER BY t.norden;
   --Fin Bug 33993-214688 KJSC 25/09/2015 TODO CEDE AL CONTRATO INDEPENDIENTEMENTE DE SI SUPERA
   BEGIN
      avui := pfdatagen;
      --w_nmovigen := pnmovigen;
      w_sproduc := psproduc;

      SELECT *
        INTO registre
        FROM cesionesaux
       WHERE nnumlin = pnnumlin AND sproces = psproces AND cestado != 7;
                                                       -- reaseguro x garantia

      --INI- EDBR - 11/06/2019 - IAXIS3338 - se toma el valor de retenciòn por poliza de la tabla contratos
      --FEPP INI 06/09/2019 IAXIS-4773  SE LLAMA A V_LIM_RET_CUM para crear tramos ppor cumulo
      BEGIN
         SELECT NVL (nretpol, v_lim_ret_global), NVL (nretcul, v_lim_ret_cum)
           INTO v_lim_ret, v_lim_cum
           FROM contratos
          WHERE scontra = registre.scontra AND fconfin IS NULL;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            v_lim_ret := v_lim_ret_global;
            v_lim_cum := v_lim_ret_cum;
      END;

       --FEPP FIN 06/09/2019 IAXIS-4773
      --FIN- EDBR - 11/06/2019 - IAXIS3338 - se toma el valor de retenciòn por poliza de la tabla contratos
      p_traza_proceso (24,
                       'TRAZA_CESIONES_REA',
                       777,
                       'PAC_CESIONES',
                       'F_CES_QN',
                       NULL,
                       2,
                          'Error: paso 0,
    pnnumlin: '
                       || pnnumlin
                       || ' psproces:'
                       || psproces
                       || ' registre.sseguro:'
                       || registre.sseguro
                       || ' registre.icapital:'
                       || registre.icapital
                       || ' registre.cestado:'
                       || registre.cestado
                       || ' registre.cgarant:'
                       || registre.cgarant
                       || ' registre.scontra:'
                       || registre.scontra
                      );

      -- 22660 AVT 16-08-2012 ho canviem de lloc
      BEGIN
         SELECT cempres, ctiprea,
                ctipcoa               --BUG CONF-695  Fecha (29/05/2017) - HRE
           INTO w_cempres, v_ctiprea,
                v_ctipcoa                                      --COAS ACEPTADO
           FROM seguros seg
          WHERE seg.sseguro = registre.sseguro;

         p_traza_proceso (24,
                          'TRAZA_CESIONES_REA',
                          777,
                          'PAC_CESIONES',
                          'F_CES_QN',
                          NULL,
                          2,
                             'Error: paso 0_1'
                          || ' v_ctiprea:'
                          || v_ctiprea
                          || ' registre.sseguro:'
                          || registre.sseguro
                         );
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            SELECT cempres, ctiprea,
                   ctipcoa            --BUG CONF-695  Fecha (29/05/2017) - HRE
              INTO w_cempres, v_ctiprea,
                   v_ctipcoa                                   --COAS ACEPTADO
              FROM estseguros seg
             WHERE seg.sseguro = registre.sseguro;

            p_traza_proceso (24,
                             'TRAZA_CESIONES_REA',
                             777,
                             'PAC_CESIONES',
                             'F_CES_QN',
                             NULL,
                             2,
                                'Error: paso 0_2'
                             || ' v_ctiprea:'
                             || v_ctiprea
                             || ' registre.sseguro:'
                             || registre.sseguro
                            );
      END;

      IF registre.cfacult = 0
      THEN                                    -- No es un facultatiu forçat...
         --   Aquí mirem si ja existeix un quadre de facultatiu per l'assegurança
         --   amb un import superior al que en principi li tocaria (capital pòlissa -
         --   capacitat contracte). Si existeix forçarem les quantitats que van contra
         --   el contracte en funció del import d'aquest facultatiu (w_ffalseado = 1)...
         --   També forçarem el facultatiu si es un cas de tipus "embarcacions" amb
         --   capacitats a nivell de garantia (w_switchgarant = 1)...
         w_icapital2 := registre.icapital;
         w_nomes00 := 0;
         w_volta := 0;
         w_yacedido := 0;
/*        --formula para obtener el valor limite de la poliza para determinar si va a retencion global o a los contratos, 300.000.000
        SELECT sgt_sesiones.NEXTVAL
        INTO psesion
        FROM DUAL;

        SELECT formula
          INTO v_formula
          FROM sgt_formulas
         WHERE clave = v_clave;

        vnerror := pac_sgt.put(psesion, 'SSEGURO', registre.sseguro);                  */
         vnerror :=
            pac_cesionesrea.f_ple_cumul_qn
               (registre.sseguro,
                registre.scumulo,
                registre.cgarant,
                w_moninst,
                pfdatagen,
             --BUG CONF-620  Fecha (01/03/2017) - HRE - Reaseguro moneda local
                v_pcapcum,
                v_lim_retencion,
                v_picapaci,
                ptablas
               );
         --v_lim_ret := 300000000;--se debe configurar posteriormente en una subtabla por cada contrato - vigencia
         --v_lim_ret_cum := 500000000;
         p_traza_proceso
            (24,
             'TRAZA_CESIONES_REA',
             777,
             'PAC_CESIONES',
             'F_CES_QN',
             NULL,
             2,
                'Error: paso 0_2_1'
             || ' v_ctiprea:'
             || v_ctiprea
             || ' registre.sseguro:'
             || registre.sseguro
             || ' registre.icapital:'
             || registre.icapital
             || ' v_lim_ret:'
             || v_lim_ret
             || ' pfdatagen:'
             || pfdatagen
             || ' v_tomador:'
             || v_tomador
             || ' registre.scontra:'
             || registre.scontra
             || ' registre.nversio:'
             || registre.nversio
             || ' w_monpol:'
             || w_monpol
             || ' w_moninst:'
             || w_moninst
             || ' v_consorcio:'
             || v_consorcio
             || ' cumulo disponible en tramo:'
             || pac_cumulos_conf.f_calcula_disponible_tramo
                      (pfdatagen,
                       v_tomador,
                       registre.scontra,
                       registre.nversio,
                       0,
                       pac_eco_tipocambio.f_importe_cambio (w_monpol,
                                                            w_moninst,
                                                            pfdatagen,
                                                            registre.icapital
                                                           ),
                       v_consorcio,
                       v_ctipcoa,
                      --) >= 1)--BUG CONF-298  Fecha (23/03/2017) - HRE - Cumulos
                       -- Inicio IAXIS-12992 27/04/2020
                       registre.sseguro,
                       pmotiu,
                       ptablas
                       -- Fin IAXIS-12992 27/04/2020
                      )
            );

         --FEPP INI 06/09/2019 IAXIS-4773
        -- Ini IAXIS-5359 --ECP -- 16/12/2019
         --FEPP INI 06/09/2019 IAXIS-4773
         SELECT COUNT (*)
           INTO count_cum
           FROM (SELECT   sseguro
                     FROM cesionesrea cr
                    WHERE sseguro IN (
                             SELECT sg.sseguro
                               FROM tomadores tm INNER JOIN seguros sg
                                    ON sg.sseguro = tm.sseguro
                              WHERE tm.sperson = v_tomador
                                AND pfdatagen < sg.fvencim)
                                 and cr.ncesion = 100
                                 and icesion > 0
                                 and fanulac is null
                               and cr.nmovimi = (select max(cr1.nmovimi) from cesionesrea cr1 where cr1.sseguro = cr.sseguro and cr1.ncesion = cr.ncesion)
                 GROUP BY sseguro);

         --FEPP FIN 06/09/2019 IAXIS-4773

         --FEPP INI 06/09/2019 IAXIS-4773  CUMULO POR TOMADOR
         -- Ini IAXIS-5359 --ECP -- 13/12/2019
         SELECT SUM (cr.icapces)
           INTO acum_cum
           FROM cesionesrea cr
          WHERE sseguro IN (
                       SELECT sg.sseguro
                         FROM tomadores tm INNER JOIN seguros sg
                              ON sg.sseguro = tm.sseguro
                        WHERE tm.sperson = v_tomador
                              AND pfdatagen < sg.fvencim)
                              and cr.ncesion = 100
                              and icesion > 0
                              and fanulac is null
                               and cr.nmovimi = (select max(cr1.nmovimi) from cesionesrea cr1 where cr1.sseguro = cr.sseguro and cr1.ncesion = cr.ncesion);
-- Ini IAXIS-5359 --ECP -- 13/12/2019
         --INI - IAXIS 2437: AABG SE CAMBIA MONTO A DOLARES O PESOS
         acum_cum :=
            pac_eco_tipocambio.f_importe_cambio (w_monpol,
                                                 w_moninst,
                                                 pfdatagen,
                                                 acum_cum
                                                );
         --INI - IAXIS 2437: AABG SE CAMBIA MONTO A DOLARES O PESOS

         --FEPP FIN 06/09/2019 IAXIS-4773
         p_traza_proceso
            (24,
             'TRAZA_CESIONES_REA',
             777,
             'PAC_CESIONES',
             'F_CESSIO',
             NULL,
             2,
                'FEPP100: paso 1,
                                  Count_cum: '
             || count_cum
             || ' Acum_cum:'
             || acum_cum
             || ' v_lim_cum:'
             || v_lim_cum
            );

         --FEPP FIN 06/09/2019 IAXIS-4773  SE MODIFICO CONDICIONAL PARA CUMULO POR POLIZA
         IF (   (    count_cum = 0
                 AND pac_eco_tipocambio.f_importe_cambio (w_monpol,
                                                          w_moninst,
                                                          pfdatagen,
                                                          registre.icapital
                                                         ) <=
                        v_lim_ret
             --BUG CONF-620  Fecha (01/03/2017) - HRE - Reaseguro moneda local
                 AND pac_cumulos_conf.f_calcula_disponible_tramo
                        (pfdatagen,
                         v_tomador,
                         registre.scontra,
                         registre.nversio,
                         0,
                         pac_eco_tipocambio.f_importe_cambio
                                                            (w_monpol,
                                                             w_moninst,
                                                             pfdatagen,
                                                             registre.icapital
                                                            ),
                         v_consorcio,
                         v_ctipcoa,                             --COAS ACEPTADO
                        --) >= 1)--BUG CONF-298  Fecha (23/03/2017) - HRE - Cumulos
                        -- Inicio IAXIS-12992 27/04/2020
                         registre.sseguro,
                         pmotiu,
                         ptablas
                       -- Fin IAXIS-12992 27/04/2020
                        ) >= 1
                )
             OR (    count_cum >= 1
                 AND pac_eco_tipocambio.f_importe_cambio (w_monpol,
                                                          w_moninst,
                                                          pfdatagen,
                                                          registre.icapital
                                                         ) <= v_lim_ret
                 AND acum_cum <= v_lim_cum
                 AND v_lim_cum - acum_cum >= pac_eco_tipocambio.f_importe_cambio (w_monpol,
                                                          w_moninst,
                                                          pfdatagen,
                                                          registre.icapital
                                                         )
                )
             
             OR v_ctiprea = 1
            )
--BUG CONF-298  Fecha (23/03/2017) - HRE - Cumulos, BUG CONF-695  Fecha (29/05/2017) - HRE
         --FEPP FIN 06/09/2019 IAXIS-4773
         -- Fin IAXIS-5359 --ECP -- 16/12/2019
         THEN
            w_porce := 1;

--4773 --> TRAMO VALOR 0
            FOR rg_consorcio IN cur_consorcio (v_tomador, v_consorcio)
            LOOP
               perr :=
                  f_insert_ces (  registre.icapital
                                * rg_consorcio.pparticipacion
                                / 100,
                                00,
                                NULL,
                                100,
                                NULL,
                                w_porce,
                                psproduc,
                                registre,
                                pmotiu,
                                psproces,
                                pnmovigen,
                                rg_consorcio.sperson,
                                rg_consorcio.tip_per
                               );
                            --BUG CONF-298  Fecha (23/03/2017) - HRE - Cumulos
               p_traza_proceso
                  (24,
                   'TRAZA_CESIONES_REA',
                   777,
                   'PAC_CESIONES',
                   'F_CES_QN',
                   NULL,
                   2,
                      'FEPP5: paso 1,
                                  rg_consorcio.sperson: '
                   || rg_consorcio.sperson
                   || ' psproces:'
                   || psproces
                   || ' psproduc:'
                   || psproduc
                  );
            END LOOP;

            IF perr <> 0
            THEN
               RETURN perr;
            END IF;
         ELSE
            FOR rg_consorcio IN cur_consorcio (v_tomador, v_consorcio)
            LOOP
               v_indporc := 0;

               IF (rg_consorcio.tip_per = 'C')
               THEN
                  w_resto_consorcio := registre.icapital;
                           --BUG CONF-298  Fecha (23/03/2017) - HRE - Cumulos
               END IF;

               SELECT sgt_sesiones.NEXTVAL
                 INTO psesion
                 FROM DUAL;

               SELECT formula
                 INTO v_formula
                 FROM sgt_formulas
                WHERE clave = v_claveq3;

               vnerror := pac_sgt.put (psesion, 'SSEGURO', registre.sseguro);
               vnerror := pac_sgt.put (psesion, 'SCONTRA', registre.scontra);
               vnerror := pac_sgt.put (psesion, 'NVERSIO', registre.nversio);
               vnerror := pac_sgt.put (psesion, 'CTRAMO', 3);
               v_reparte_q3 := pk_formulas.eval (v_formula, psesion);
               p_traza_proceso
                          (24,
                           'TRAZA_CESIONES_REA',
                           777,
                           'PAC_CESIONES',
                           'F_CES_QN',
                           NULL,
                           2,
                              'Error: paso 5,
                  w_icapital2:'
                           || w_icapital2
                          );
               w_icapital2 := registre.icapital;
               p_traza_proceso
                  (24,
                   'TRAZA_CESIONES_REA',
                   777,
                   'PAC_CESIONES',
                   'F_CES_QN',
                   NULL,
                   2,
                      'Error: paso 5_1,
                  registre.icapital:'
                   || registre.icapital
                  );

               IF (rg_consorcio.tip_per != 'C')
               THEN         --BUG CONF-298  Fecha (23/03/2017) - HRE - Cumulos
                  w_resto :=
                        registre.icapital * rg_consorcio.pparticipacion / 100;
               END IF;
			   
			   --INI IAXIS BUG 13246 AABG: Para restar el facultativo manual al valor del contrato             
               perr := f_obtener_fac(registre.sseguro, registre.nversio, pmotiu, psproduc, registre.scontra, v_valor_facult);
                IF perr <> 0
                  THEN
                     RETURN perr;
                  END IF;
               IF v_valor_facult > 0 THEN
                w_resto := w_resto - v_valor_facult;
               END IF;              
               --FIN IAXIS BUG 13246 AABG: Para restar el facultativo manual al valor del contrato
               -- 
               -- Inicio IAXIS-5361 26/05/2020
               --
               -- Acá se obtiene el valor del facultativo modificado por el usuario antes de la emisión a través de la pantalla de
               -- mantenimiento de cuadros facultativos.
               -- De momento, no aplicable si existe distribución manual. Por lo que se dará prioridad a la distribución manual.
               --
               IF pfacult IS NOT NULL AND v_valor_facult = 0 THEN
                 BEGIN
                   SELECT c.ifacced 
                     INTO w_facmod
                     FROM cuafacul c
                    WHERE c.sfacult = pfacult
                      AND c.ffincuf IS NULL;
                 EXCEPTION WHEN OTHERS THEN
                   perr := 104736;
                   RETURN (perr);   
                 END;   
              END IF;   
              -- 
              -- Fin IAXIS-5361 26/05/2020
              --
               OPEN cur_capacontra (registre.scontra,
                                    registre.nversio,
                                    v_reparte_q3
                                   );

               FETCH cur_capacontra
                INTO v_capareal;

               CLOSE cur_capacontra;

               -- INI - ML - BUG 4775
                /*IF (v_ctipcoa = 8) THEN--COAS ACEPTADO
                   v_capareal := v_capareal / 2;
                END IF;
                */
                -- FIN - ML - BUG 4774
               registre.icapaci := v_capareal;

               FOR regtrams IN cur_trams (registre.scontra,
                                          registre.nversio,
                                          v_reparte_q3
                                         )
               LOOP
                  v_cescont := 0;
                  w_porce :=
                     pac_cesionesrea.f_porcentaje_tramos_manual
                                                           (regtrams.ctramo,
                                                            regtrams.scontra,
                                                            regtrams.nversio
                                                           );

                  IF (w_porce IS NULL)
                  THEN
                     w_porce := 1;
                  END IF;

                  --INI BUG CONF-298 Fecha (23/03/2017) - HRE - Cumulos
                  IF (NOT tb_pocentajes.EXISTS (regtrams.ctramo))
                  THEN
                     v_porc_min_disp :=
                        pac_cumulos_conf.f_calcula_disponible_tramo
                           (pfdatagen,
                            v_tomador,
                            registre.scontra,
                            registre.nversio,
                            regtrams.ctramo,
                            pac_eco_tipocambio.f_importe_cambio
                                                            (w_monpol,
                                                             w_moninst,
                                                             pfdatagen,
                                                             (registre.icapital - w_facmod) -- IAXIS-5361 26/05/2020
                                                            ),
                            v_consorcio,
                            v_ctipcoa,                          --COAS ACEPTADO
                            -- Inicio IAXIS-12992 27/04/2020
                            registre.sseguro,
                            pmotiu,
                            ptablas
                            -- Fin IAXIS-12992 27/04/2020
                           );
                     tb_pocentajes (regtrams.ctramo) := v_porc_min_disp;
                  ELSE
                     v_porc_min_disp := tb_pocentajes (regtrams.ctramo);
                  END IF;

                  p_traza_proceso
                     (24,
                      'TRAZA_CESIONES_REA',
                      777,
                      'PAC_CESIONES',
                      'F_CES_QN',
                      NULL,
                      2,
                         'Error: paso 5_2,
                  v_porc_min_disp: '
                      || v_porc_min_disp
                      || ' w_porce:'
                      || w_porce
                      || ' registre.icapital:'
                      || registre.icapital
                      || ' ptablas:'
                      || ptablas
                      || ' registre.sseguro:'
                      || registre.sseguro
                     );
					 
			

                  IF (v_porc_min_disp < w_porce OR (v_indporc = 1))
                  THEN
                     w_porce := v_porc_min_disp;
                     v_indporc := 1;
                  END IF;

                  IF (rg_consorcio.tip_per = 'C')
                  THEN
                     w_captram_cons := w_icapital2 * w_porce;
                  ELSE
                     w_captram :=
                          (w_icapital2 - w_facmod) -- IAXIS-5361 26/05/2020
                        * w_porce
                        * rg_consorcio.pparticipacion
                        / 100;
                     p_traza_proceso
                           (24,
                            'TRAZA_CESIONES_REA',
                            777,
                            'PAC_CESIONES',
                            'F_CES_QN',
                            NULL,
                            2,
                               'Error: paso 4,
                  w_captram: '
                            || w_captram
                            || ' w_icapital2:'
                            || w_icapital2
                            || ' w_porce:'
                            || w_porce
                            || ' rg_consorcio.pparticipacion:'
                            || rg_consorcio.pparticipacion
                           );
                  END IF;

                  IF (rg_consorcio.tip_per = 'C')
                  THEN
                     IF (w_captram_cons > w_resto_consorcio)
                     THEN
                        w_captram_cons := w_resto_consorcio;
                        w_porce := ROUND (w_captram_cons / w_icapital2, 5);
                     END IF;
                  ELSE
                     p_traza_proceso
                          (24,
                           'TRAZA_CESIONES_REA',
                           777,
                           'PAC_CESIONES',
                           'F_CES_QN',
                           NULL,
                           2,
                              'Error: paso 3,
                  w_captram: '
                           || w_captram
                           || ' w_resto:'
                           || w_resto
                          );

                     IF (w_captram > w_resto)
                     THEN
                        w_captram := w_resto;
                        w_porce := ROUND (w_captram / w_icapital2, 5);
                     END IF;

                     p_traza_proceso
                           (24,
                            'TRAZA_CESIONES_REA',
                            777,
                            'PAC_CESIONES',
                            'F_CES_QN',
                            NULL,
                            2,
                               'Error: paso 2,
                  w_captram: '
                            || w_captram
                            || ' w_resto:'
                            || w_resto
                            || ' w_porce:'
                            || w_porce
                            || ' w_icapital2:'
                            || w_icapital2
                           );
                  END IF;

                  --FIN BUG CONF-298  - Fecha (23/03/2017) - HRE
                  IF (w_captram < 0)
                  THEN
                     w_captram := 0;
                  END IF;

                  IF (w_captram_cons < 0)
                  THEN
                     w_captram_cons := 0;
                  END IF;

                  IF (rg_consorcio.tip_per = 'C')
                  THEN
                     w_resto_consorcio := w_resto_consorcio - w_captram_cons;
                  ELSE
                     w_resto := (w_resto - w_facmod) - w_captram; -- IAXIS-5361 26/05/2020
                  END IF;

                  OPEN cur_cutoff (regtrams.scontra,
                                   regtrams.nversio,
                                   regtrams.ctramo
                                  );

                  FETCH cur_cutoff
                   INTO v_porcutoff;

                  CLOSE cur_cutoff;

                  IF (rg_consorcio.tip_per = 'C')
                  THEN
                     IF (w_captram_cons > 0)
                     THEN
                        -- INI - ML - 5028 - 04/09/2019 - CORRECCION EN CESION PARA CUTOFF
                        -- ML - REV1 - PORCENTAJE Y VALORES ADICIONALES
                        perr :=
                           f_insert_ces (w_captram_cons,
                                         regtrams.ctramo,
                                         NULL,
                                         regtrams.ncesion,
                                         regtrams.plocal,
                                           rg_consorcio.pparticipacion
                                         / 100
                                         * (100 - v_porcutoff)
                                         / 100,
                                         psproduc,
                                         registre,
                                         pmotiu,
                                         psproces,
                                         pnmovigen,
                                         rg_consorcio.sperson,
                                         rg_consorcio.tip_per,
                                         NULL,
                                         CASE
                                            WHEN v_porcutoff > 0
                                               THEN 'S'
                                            ELSE 'N'
                                         END
                                        );
                     -- FIN - ML - 5028 - 04/09/2019 - CORRECCION EN CESION PARA CUTOFF
                     END IF;
                  ELSE
                     IF (w_captram > 0)
                     THEN
                        p_traza_proceso
                           (24,
                            'TRAZA_CESIONES_REA',
                            777,
                            'PAC_CESIONES',
                            'F_CES_QN',
                            NULL,
                            2,
                               'Error: paso 1,
                          w_captram: '
                            || w_captram
                            || ' w_porce:'
                            || w_porce
                            || ' rg_consorcio.pparticipacion:'
                            || rg_consorcio.pparticipacion
                            || ' v_porcutoff '
                            || v_porcutoff
                           );
                        -- INI - ML - 5028 - 04/09/2019 - CORRECCION EN CESION PARA CUTOFF
                         -- ML - REV1 - PORCENTAJE Y VALORES ADICIONALES
                        perr :=
                           f_insert_ces (w_captram,
                                         regtrams.ctramo,
                                         NULL,
                                         regtrams.ncesion,
                                         regtrams.plocal,
                                           rg_consorcio.pparticipacion
                                         / 100
                                         * (100 - v_porcutoff)
                                         / 100,
                                         psproduc,
                                         registre,
                                         pmotiu,
                                         psproces,
                                         pnmovigen,
                                         rg_consorcio.sperson,
                                         rg_consorcio.tip_per,
                                         NULL,
                                         CASE
                                            WHEN v_porcutoff > 0
                                               THEN 'S'
                                            ELSE 'N'
                                         END
                                        );
                     -- FIN - ML - 5028 - 04/09/2019 - CORRECCION EN CESION PARA CUTOFF
                     END IF;
                  END IF;

                  IF perr <> 0
                  THEN
                     RETURN perr;
                  END IF;
               END LOOP;

               --INI BUG IAXIS 13246 AABG: Ajuste para Facultativo manual                 
               perr := f_obtener_fac(registre.sseguro, 
                                     registre.nversio, 
                                     pmotiu, 
                                     psproduc, 
                                     registre.scontra, 
                                     v_valor_facult); -- IAXIS-5361 26/05/2020
                IF perr <> 0
                  THEN
                     RETURN perr;
                  END IF;
               --FIN BUG IAXIS 13246 AABG: Ajuste para Facultativo manual
               --
               -- Inicio IAXIS-5361 26/05/2020
               -- 
               -- Nuevamente, se respeta el uso de la distribución manual por sobre la modificación del facultativo
               -- antes de la emisión.
               --
               IF v_valor_facult = 0 THEN
                  w_resto := w_facmod;
               ELSE
                  w_resto := v_valor_facult;
               END IF;   
               --
               -- Fin IAXIS-5361 26/05/2020
               --
               --INI BUG CONF-298 Fecha (23/03/2017) - HRE - Cumulos
               IF (w_resto > 0 AND rg_consorcio.tip_per = 'P')
               --FIN BUG IAXIS 13246 AABG: Ajuste para Facultativo manual
               THEN
                  -- Hi han cessions a facultatiu...
                  -- se va al facultativo
                  BEGIN
                     SELECT ncesion
                       INTO pncesion
                       FROM cuafacul
                      WHERE sfacult = pfacult;
                  EXCEPTION
                     WHEN NO_DATA_FOUND
                     THEN
                        perr := 104736;
                        RETURN (perr);
                     WHEN OTHERS
                     THEN
                        perr := 104486;
                        RETURN (perr);
                  END;

                  w_porce := ROUND (w_resto / registre.icapital, 5);
                  perr :=
                     f_insert_ces (w_resto,
                                   05,
                                   pfacult,
                                   NVL (pncesion, 0),
                                   NULL,
                                   w_porce,
                                   psproduc,
                                   registre,
                                   pmotiu,
                                   psproces,
                                   pnmovigen,
                                   rg_consorcio.sperson,
                                   rg_consorcio.tip_per
                                  );
                  p_traza_proceso
                     (24,
                      'TRAZA_CESIONES_REA',
                      777,
                      'PAC_CESIONES',
                      'F_CES_QN',
                      NULL,
                      2,
                         'FEPP92: paso 1,
                                  rg_consorcio.sperson: '
                      || rg_consorcio.sperson
                      || ' psproces:'
                      || psproces
                      || ' psproduc:'
                      || psproduc
                     );

                  IF perr <> 0
                  THEN
                     RETURN perr;
                  END IF;
               END IF;

               --FIN BUG CONF-298  - Fecha (23/03/2017) - HRE
               IF (rg_consorcio.tip_per != 'C')
               THEN
                  w_resto_total := NVL (w_resto_total, 0) + w_resto;
               END IF;
            END LOOP;       --BUG CONF-298  Fecha (23/03/2017) - HRE - Cumulos

            IF w_resto_consorcio > w_resto_total
            THEN
               w_resto := w_resto_consorcio;
            ELSE
               w_resto := w_resto_total;
            END IF;

            --
            -- Inicio IAXIS-5361 26/05/2020
            -- 
            -- Nuevamente, se respeta el uso de la distribución manual por sobre la modificación del facultativo
            -- antes de la emisión.
            --
            IF v_valor_facult = 0 THEN
               w_resto := w_facmod;
            ELSE
               w_resto := v_valor_facult;
            END IF;   
            --
            -- Fin IAXIS-5361 26/05/2020
            -- 
            IF w_resto > 0
            THEN
               -- Hi han cessions a facultatiu...
               -- se va al facultativo
               BEGIN
                  SELECT ncesion
                    INTO pncesion
                    FROM cuafacul
                   WHERE sfacult = pfacult;
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     perr := 104736;
                     RETURN (perr);
                  WHEN OTHERS
                  THEN
                     perr := 104486;
                     RETURN (perr);
               END;

               w_porce := ROUND (w_resto / registre.icapital, 5);

               IF (v_cgesfac != -1)
               THEN
                  perr :=
                     f_insert_ces (w_resto,
                                   05,
                                   pfacult,
                                   pncesion,
                                   NULL,
                                   w_porce,
                                   psproduc,
                                   registre,
                                   pmotiu,
                                   psproces,
                                   pnmovigen,
                                   v_tomador,
                                   w_tipper
                                  );
                            --BUG CONF-298  Fecha (23/03/2017) - HRE - Cumulos
                  p_traza_proceso
                     (24,
                      'TRAZA_CESIONES_REA',
                      777,
                      'PAC_CESIONES',
                      'F_CES_QN',
                      NULL,
                      2,
                         'FEPP99: paso 1,
                                  v_tomador.sperson: '
                      || v_tomador
                      || ' psproces:'
                      || psproces
                      || ' psproduc:'
                      || psproduc
                     );
               END IF;

               IF perr <> 0
               THEN
                  RETURN perr;
               ELSE
                  IF v_base_rea = 1
                  THEN
                     UPDATE cuafacul
                        SET ifacced = w_resto                          --w_res
                      WHERE sfacult = pfacult;
                  END IF;
               --fin AGG 25/04/2014
               END IF;
            END IF;
         END IF;
      ELSE                           -- Es un facultatiu forçat... cfacult = 1
         BEGIN
            SELECT ncesion, plocal        -- Busquem % nostre i num. cessió...
              INTO pncesion, w_plocal
              FROM cuafacul
             WHERE sfacult = pfacult;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               ----dbms_outpuT.PUT_LINE(' 22222222222 ');
               perr := 104736;
               RETURN (perr);
            WHEN OTHERS
            THEN
               perr := 104486;
               RETURN (perr);
         END;

         /*IF w_plocal IS NOT NULL THEN   -- Es crea tram 00 nostre...
            w_res := (registre.icapital * w_plocal) / 100;
            w_porce := w_plocal / 100;
            -->DBMS_OUTPUT.put_line('6. registre.iprirea:' || registre.iprirea);
            perr := f_insert_ces(w_res, 00, pfacult, pncesion, NULL, w_porce, psproduc,
            registre, pmotiu, psproces, pnmovigen, v_tomador, w_tipper--BUG CONF-298  Fecha (23/03/2017) - HRE - Cumulos
            );

            IF perr <> 0 THEN
               RETURN perr;
            END IF;
         END IF;*/
         -- Tram 05 del facultatiu...
         w_porce := (100 - NVL (w_plocal, 0));
         w_res := (registre.icapital * w_porce) / 100;
         w_porce := w_porce / 100;
         -->DBMS_OUTPUT.put_line('7. registre.iprirea:' || registre.iprirea);
         perr :=
            f_insert_ces (w_res,
                          05,
                          pfacult,
                          pncesion,
                          NULL,
                          w_porce,
                          psproduc,
                          registre,
                          pmotiu,
                          psproces,
                          pnmovigen,
                          v_tomador,
                          w_tipper
                         ); --BUG CONF-298  Fecha (23/03/2017) - HRE - Cumulos
         p_traza_proceso
            (24,
             'TRAZA_CESIONES_REA',
             777,
             'PAC_CESIONES',
             'F_CES_QN',
             NULL,
             2,
                'FEPP94: paso 1,
                                  v_tomador.sperson: '
             || v_tomador
             || ' psproces:'
             || psproces
             || ' psproduc:'
             || psproduc
            );

         IF perr <> 0
         THEN
            RETURN perr;
         END IF;
      END IF;

      ---------
      RETURN (perr);
   END f_ces_qn;

   FUNCTION f_insert_ces (
      pp_capces    IN   NUMBER,
      pp_tramo     IN   NUMBER,
      pp_facult    IN   NUMBER,
      pp_cesio     IN   NUMBER,
      pp_local     IN   NUMBER,
      pp_porce     IN   NUMBER,
      pp_sproduc   IN   NUMBER,                                              --
      registre          cesionesaux%ROWTYPE,
      pmotiu            NUMBER,
      psproces          NUMBER,
      pnmovigen    IN   NUMBER,
      psperson          NUMBER,
      ptipper           VARCHAR2,
                            --BUG CONF-298  Fecha (23/03/2017) - HRE - Cumulos
      pctrampa          NUMBER DEFAULT NULL,
      pcutoff           VARCHAR2 DEFAULT NULL,
      pp_cgesfac   IN   NUMBER DEFAULT 0
   )
      RETURN NUMBER
   IS
      v_fconfin         DATE;
      v_irecarg         garanseg.irecarg%TYPE;               --08/05/2014 AGG
      v_iextrap         garanseg.iextrap%TYPE;               --08/05/2014 AGG
      v_icapital        garanseg.icapital%TYPE;              --08/05/2014 AGG
      v_pcomext         NUMBER;
      v_cvidaga         codicontratos.cvidaga%TYPE;
      w_sdetcesrea      det_cesionesrea.sdetcesrea%TYPE;
      v_cmodali         productos.cmodali%TYPE;
      v_ccolect         productos.ccolect%TYPE;
      v_ctipseg         productos.ctipseg%TYPE;
      v_cramo           productos.cramo%TYPE;
      v_cactivi         seguros.cactivi%TYPE;
      v_creaseg_garan   garanpro.creaseg%TYPE;
      v_porcgara        NUMBER;
      v_porcprim        NUMBER;
      v_totgaran        NUMBER;
      v_totprim         NUMBER;
----------------------------------------------------------
      w_iprirea         NUMBER;
      pmoneda           NUMBER;
      w_ipritarrea      NUMBER;
      w_idtosel         NUMBER;
      w_iextrea         NUMBER;
      w_iextrap         NUMBER;
      codi_error        NUMBER;
      w_dias            NUMBER;
      w_divisoranual    NUMBER;
      w_icomext         NUMBER;
      w_nmovigen        NUMBER;
      avui              DATE;
      perr              NUMBER;
      --
      w_porce           NUMBER                            := 0;
      w_capces          NUMBER                            := 0;
      numerr            NUMBER;
      --INI BUG CONF-479  Fecha (20/01/2017) - HRE - Suplemento de aumento de valor
      w_pp_porce        NUMBER;                                      --AYMAMI
      w_pp_capce        NUMBER;                                      --AYMAMI
      --FIN BUG CONF-479  - Fecha (20/01/2017) - HRE
	  
	  --INI IAXIS BUG 13246 AABG: Para almacenar valores de Q
      w_pp_porceq       NUMBER;
      w_pp_capq         NUMBER;
      w_pp_supl         NUMBER := 0;
      --FIN IAXIS BUG 13246 AABG: Para almacenar valores de Q
	  
      --INICIO - BUG38692 - DCT - 17/11/2015.
      v_frenova         seguros.frenova%TYPE;
      v_nrenova         seguros.nrenova%TYPE;
      v_fefecto         seguros.fefecto%TYPE;
      w_iprirea_l       NUMBER;
      w_capces_l        NUMBER;
      w_porce_l         NUMBER;
      w_ipritarrea_l    NUMBER;
      w_idtosel_l       NUMBER;
      w_psobreprima_l   NUMBER;
      w_iextrea_l       NUMBER;
      w_iextrap_l       NUMBER;
      w_itarifrea_l     NUMBER;
      w_icomext_l       NUMBER;
      w_psobreprima     NUMBER;
      w_itarifrea       NUMBER;
      w_pp_local        NUMBER;
      v_ctrampa         cesionesrea.ctrampa%TYPE;
      v_add_fac         NUMBER                            := 0;   --CONF-1082
	  
	  --INI IAXIS BUG 10563 AABG: Variable para almacenar el nuevo parametro calculado para porcentaje cesion
      v_porc_cesion NUMBER;
      --FIN IAXIS BUG 10563 AABG: Variable para almacenar el nuevo parametro calculado para porcentaje cesion

      --IAXIS -  4773 FEPP 22/08/2019
      CURSOR cur_aux_6
      IS
         SELECT   *
             FROM cesionesaux
            WHERE sproces = psproces AND cestado = 7
         ORDER BY (icapaci - icapital), cgarant DESC;

         --IAXIS -  4773 FEPP 22/08/2019
      -- INI - ML - 5028 - 04/09/2019 - FUNC PARA INSERTAR REGISTRO EN det_cesionesrea
      -- INI - REV1 - CORRECCION DE PORCENTAJES
      FUNCTION insert_rdet_cesionesrea (w_scesrea_ NUMBER, w_capces NUMBER)
         RETURN NUMBER
      AS
         porcentaje_cesion   NUMBER := 0;
      BEGIN
         w_scesrea := w_scesrea_;

         --se graba el reaseguro x garantia
         SELECT NVL (SUM (icapital), 0), NVL (SUM (iprirea), 0)
           INTO v_totgaran, v_totprim
           FROM cesionesaux
          WHERE sproces = psproces AND cestado = 7;

         FOR regaux1 IN cur_aux_6
         LOOP
            BEGIN
               SELECT cvidaga
                 INTO v_cvidaga
                 FROM codicontratos
                WHERE scontra = regaux1.scontra;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  v_cvidaga := -1;
                               -- -1;--BUG CONF-695  Fecha (29/05/2017) - HRE
            END;

            SELECT sdetcesrea.NEXTVAL
              INTO w_sdetcesrea
              FROM DUAL;

            IF v_cvidaga = 1
            THEN
               BEGIN
                  BEGIN
                     SELECT cmodali, ccolect, ctipseg, cactivi,
                            cramo
                       INTO v_cmodali, v_ccolect, v_ctipseg, v_cactivi,
                            v_cramo
                       FROM /*est*/ seguros
                      WHERE sseguro /*ssegpol*/ = regaux1.sseguro;
                  EXCEPTION
                     WHEN NO_DATA_FOUND
                     THEN
                        v_cmodali := -1;
                        v_ccolect := -1;
                        v_ctipseg := -1;
                        v_cactivi := -1;
                        v_cramo := -1;
                  END;

                  BEGIN
                     SELECT creaseg
                       INTO v_creaseg_garan
                       FROM garanpro
                      WHERE cmodali = v_cmodali
                        AND ccolect = v_ccolect
                        AND ctipseg = v_ctipseg
                        AND cgarant = regaux1.cgarant
                        AND cactivi = v_cactivi
                        AND cramo = v_cramo;
                  EXCEPTION
                     WHEN NO_DATA_FOUND
                     THEN
                        v_creaseg_garan := -1;
                  END;

                  IF v_creaseg_garan = 1
                  THEN
                     v_porcgara := regaux1.icapital / v_totgaran;
                     v_porcprim := regaux1.iprirea / v_totprim;

                     --
                     --INI BUG CONF-298 Fecha (23/03/2017) - HRE - Cumulos
                     IF (ptipper = 'P')
                     THEN
                        w_scesrea :=
                           pac_cumulos_conf.f_get_cons_cesionesrea
                                                            (regaux1.sseguro,
                                                             regaux1.scontra,
                                                             regaux1.nversio,
                                                             pp_tramo,
                                                             regaux1.nriesgo,
                                                             NULL,
                                                             pmotiu,
                                                             regaux1.nmovimi
                                                            );
                     END IF;

                       --FIN BUG CONF-298  - Fecha (23/03/2017) - HRE
                     -- OBTENER PORCENTAJE DE CESION => 4 DECIMALES DE PRECISION
                     porcentaje_cesion :=
                        ROUND ((  NVL (w_capces, 0)
                                * NVL (v_porcgara, 0)
                                / registre.icapital
                                * 100
                               ),
                               14 -- IAXIS-12992 27/04/2020
                              );
                     p_control_error ('ML_ERRORF',
                                      'PAC_CESIONES 686',
                                         'w_capces: '
                                      || w_capces
                                      || ' v_porcgara: '
                                      || v_porcgara
                                      || ' registre.icapital: '
                                      || registre.icapital
                                     );

                     INSERT INTO det_cesionesrea
                                 (scesrea, sdetcesrea, sseguro,
                                  nmovimi,
                                  ptramo,
                                  cgarant, icesion,
                                  icapces,
                                  pcesion,
                                  psobreprima,
                                  iextrap,
                                  iextrea,
                                  ipritarrea,
                                  itarifrea,
                                  icomext, ccompani, falta,
                                  cusualt, fmodifi, cusumod, cdepura,
                                  fefecdema, nmovidep, sperson
                                 )
                            --BUG CONF-298  Fecha (23/03/2017) - HRE - Cumulos
                          VALUES (w_scesrea, w_sdetcesrea, regaux1.sseguro,
                                  regaux1.nmovimi,
                                  DECODE (pp_tramo,
                                          6, 0,
                                          7, 0,
                                          8, 0,
                                          pp_tramo
                                         ),
                                  regaux1.cgarant, w_iprirea * v_porcprim,
                                  w_capces * v_porcgara,
                                  porcentaje_cesion /*w_porce * v_porcgara * 100*/
                                                                                  /*regaux1.pcesion*/,
                                  w_psobreprima * v_porcgara,
                                                        --regaux1.psobreprima,
                                  w_iextrap * v_porcgara,   --regaux1.iextrap,
                                  w_iextrea * v_porcgara,   --regaux1.iextrea,
                                  w_ipritarrea * v_porcgara,
                                                         --regaux1.ipritarrea,
                                  w_itarifrea * v_porcgara,
                                                          --regaux1.itarifrea,
                                  w_icomext * v_porcgara,   --regaux1.icomext,
                                                         NULL, f_sysdate,
                                  f_user, NULL, NULL, 'N',
                                  NULL, 1, psperson
                                 );
                            --BUG CONF-298  Fecha (23/03/2017) - HRE - Cumulos
                  END IF;
               END;
            END IF;
         END LOOP;

         --reaseguro x garantia
         RETURN 0;
      EXCEPTION
         WHEN OTHERS
         THEN
            RETURN 1;
      END;

      -- FIN - ML - 5028 - 04/09/2019 - FUNC PARA INSERTAR REGISTRO EN det_cesionesrea

      -- INI - ML - 5028 - 04/09/2019 - FUNC PARA INSERTAR REGISTRO EN CESIONESREA
      FUNCTION insert_rcesionesrea (
         valor           NUMBER,
         pp_cesio        NUMBER,
         w_iprirea       NUMBER,
         registre        cesionesaux%ROWTYPE,
         pp_tramo        NUMBER,
         pp_facult       NUMBER,
         v_fefecto       seguros.fefecto%TYPE,
         v_fconfin       DATE,
         pmotiu          NUMBER,
         avui            DATE,
         w_ipritarrea    NUMBER,
         w_idtosel       NUMBER,
         w_psobreprima   NUMBER,
         w_nmovigen      NUMBER,
         w_iextrea       NUMBER,
         w_iextrap       NUMBER,
         w_itarifrea     NUMBER,
         w_icomext       NUMBER,
         ctrampa         NUMBER,
         cutoff          VARCHAR2
      )
         RETURN NUMBER
      AS
         llave_primaria      NUMBER := 0;
         porcentaje_cesion   NUMBER := 0;
		 prima_cedida 		 NUMBER := 0; -- BUG-10559
      BEGIN
         -- OBTENER CONSECUTIVO DE LLAVE PRIMARIA DE CESIONESREA
         SELECT scesrea.NEXTVAL
           INTO llave_primaria
           FROM DUAL;

         -- OBTENER PORCENTAJE DE CESION => 4 DECIMALES DE PRECISION
         porcentaje_cesion := ROUND ((valor / registre.icapital * 100), 4);
		 -- BUG-10559
         prima_cedida := f_round((registre.iprirea * porcentaje_cesion / 100), pmoneda);

         INSERT INTO cesionesrea
                     (scesrea, ncesion, icesion, icapces,
                      sseguro,
                      nversio,
                      scontra,
                      ctramo,
                      sfacult, nriesgo, icomisi, icomreg,
                      scumulo, cgarant,
                      spleno,
                      ccalif1,
                      ccalif2,
                      fefecto, fvencim, pcesion,
                      sproces, cgenera, fgenera, nmovimi,
                      ipritarrea, idtosel,
                      psobreprima,
                      cdetces, fanulac, fregula,
                      nmovigen, ipleno, icapaci,
                      iextrea,
                              -- 47.0 - 29/11/2013 - MMM - 0028082 LCOL_A004-0008810 CLF2-4054 LISTADOS DE PRIMAS CEDIDAS VIDA PROPORCIONAL - Inicio
                              iextrap, itarifrea,
                                                 --08/05/2014 AGG se aade la comisin de la extra prima
                                                 icomext, ctrampa,
                      ccutoff
                     )
              -- 47.0 - 29/11/2013 - MMM - 0028082 LCOL_A004-0008810 CLF2-4054 LISTADOS DE PRIMAS CEDIDAS VIDA PROPORCIONAL - Fin
         VALUES      (llave_primaria, pp_cesio, 
					  prima_cedida, -- BUG-10559
					  valor,
                      registre.sseguro,
                      DECODE (registre.cfacult, 0, registre.nversio, NULL),
                      DECODE (registre.cfacult, 0, registre.scontra, NULL),
                      DECODE (pp_tramo, 6, 0, 7, 0, 8, 0, pp_tramo),
                    -- 26663 AVT 08/07/2013 es guarden els trams com a propis,
                      pp_facult, registre.nriesgo, NULL, NULL,
                      registre.scumulo, registre.cgarant,
                      DECODE (registre.cfacult, 0, registre.spleno, NULL),
                      DECODE (registre.cfacult, 0, registre.ccalif1, NULL),
                      DECODE (registre.cfacult, 0, registre.ccalif2, NULL),
                      v_fefecto, v_fconfin,
                                         --registre.fconini, registre.fconfin,
                                           porcentaje_cesion,
                      registre.sproces, pmotiu, avui, registre.nmovimi,
                      w_ipritarrea, w_idtosel,
                      w_psobreprima /*registre.psobreprima*/,
                      registre.cdetces, registre.fanulac, registre.fregula,
                      w_nmovigen, registre.ipleno, registre.icapaci,
                      w_iextrea,
                                --registre.iextrea, --BUG 30326/171842 - DCT -
                                -- 03/04/2014
                                -- 47.0 - 29/11/2013 - MMM - 0028082 LCOL_A004-0008810 CLF2-4054 LISTADOS DE PRIMAS CEDIDAS VIDA PROPORCIONAL - Inicio
                                --registre.iextrap,
                                w_iextrap,
                                         --BUG 30326/171842 - DCT - 03/04/2014
                                          /*registre.itarifrea*/
                                          w_itarifrea,
                                                      --08/05/2014 AGG
                                                      w_icomext, ctrampa,
                      cutoff
                     );

         RETURN insert_rdet_cesionesrea (llave_primaria, valor);
      EXCEPTION
         WHEN OTHERS
         THEN
            RETURN 1;
      END;
   -- FIN - ML - 5028 - 04/09/2019 - FUNC PARA INSERTAR REGISTRO EN CESIONESREA
   BEGIN
      --INICIO - BUG38692 - DCT - 17/11/2015. Si el pp_cgesfac = 1 quiere decir que hemos apretado el botón de Crear Facultativo
      --y por lo tanto no debemos crear las cesionesrea

      --INI BUG CONF-479  Fecha (20/01/2017) - HRE - Suplemento de aumento de valor

      --CONF-1082
      IF NVL (registre.sfacult, 0) != 0
      THEN                     --Si en la distribicion actual hay facultativo
         SELECT COUNT (*)
           INTO v_add_fac
           FROM cesionesrea c
          WHERE c.sseguro = registre.sseguro AND c.nmovimi = 1
                AND c.ctramo = 5;

         IF v_add_fac > 0
         THEN                                --Habia facultativo en la emisi£¿
            v_add_fac := 1;
         END IF;
      ELSE
         v_add_fac := 2;
      END IF;

      --CONF-1082
      p_traza_proceso (24,
                       'TRAZA_CESIONES_REA',
                       777,
                       'PAC_CESIONES',
                       'F_INSERT_CES',
                       NULL,
                       2,
                          'Error: paso 1,
                  pp_capces: '
                       || pp_capces
                       || ' pp_porce:'
                       || pp_porce
                      );

      IF v_add_fac IN (1, 2)
      THEN                                                         --CONF-1082
         --INI IAXIS BUG 13246 AABG: Se llama nueva funcion para nuevos parametros de salida
         
         numerr :=
            pac_cesionesrea.f_mantener_repartos_supl_man (pmotiu,
                                                      pp_sproduc,
                                                      registre.scontra,
                                                      registre.sseguro,
                                                      registre.nversio,
                                                      registre.cgarant,
                                                      pp_tramo,
                                                      pp_porce,
                                                      pp_capces,
                                                      registre.icapital,
                                                      w_pp_capce,
                                                      w_pp_porce,
                                                      w_pp_capq,
                                                      w_pp_porceq,
                                                      w_pp_supl
                                                     );
                                                      
    --FIN IAXIS BUG 13246 AABG: Se llama nueva funcion para nuevos parametros de salida  
      ELSE                                                         --CONF-1082
         w_pp_capce := pp_capces;
         w_pp_porce := pp_porce;         
      END IF;

      p_traza_proceso (24,
                       'TRAZA_CESIONES_REA',
                       777,
                       'PAC_CESIONES',
                       'F_INSERT_CES',
                       NULL,
                       2,
                          'Error: paso 2,
                  w_pp_capce: '
                       || w_pp_capce
                       || ' w_pp_porce:'
                       || w_pp_porce
                       || ' registre.cgarant:'
                       || registre.cgarant
                       || ' pp_tramo:'
                       || pp_tramo
                      );

      --FIN BUG CONF-479  - Fecha (20/01/2017) - HRE
      IF pp_cgesfac = 0
      THEN
        -- INI - ML - 5028 - 04/09/2019 - LA SECUENCIA SE LA OBTIENE EN LOS INSERT DE ABAJO
--         IF (ptipper != 'P' OR (ptipper = 'P' AND pp_tramo = 5)) THEN--para participantes de consorcios no se crea cesionesrea, solo el detalle
--            SELECT scesrea.NEXTVAL
--              INTO w_scesrea
--              FROM DUAL;
--         END IF;
       -- FIN - ML - 5028 - 04/09/2019 - LA SECUENCIA SE LA OBTIENE EN LOS INSERT DE ABAJO
         w_nmovigen := pnmovigen;
         -- BUG 0010844 - 14/09/2009 - FAL - Substituir f_round_forpag per f_round a f_insert_ces
         -->DBMS_OUTPUT.put_line('2.1 registre.iprirea:' || registre.iprirea);
         w_iprirea :=
                 f_round (registre.iprirea * w_pp_porce /*pp_porce*/,
                          pmoneda);
--BUG CONF-479  Fecha (20/01/2017) - HRE - suplemento aumento de valor    -- INI BUG 18423 - 15/12/2011 - JLB - LCOL000 - Multimoneda
         w_ipritarrea :=
              f_round (registre.ipritarrea * w_pp_porce /*pp_porce*/,
                       pmoneda);
--BUG CONF-479  Fecha (20/01/2017) - HRE - suplemento aumento de valor -- INI BUG 18423 - 15/12/2011 - JLB - LCOL000 - Multimoneda
         w_idtosel :=
                 f_round (registre.idtosel * w_pp_porce /*pp_porce*/,
                          pmoneda);
--BUG CONF-479  Fecha (20/01/2017) - HRE - suplemento aumento de valor    -- INI BUG 18423 - 15/12/2011 - JLB - LCOL000 - Multimoneda
         w_iextrea :=
                 f_round (registre.iextrea * w_pp_porce /*pp_porce*/,
                          pmoneda);
--BUG CONF-479  Fecha (20/01/2017) - HRE - suplemento aumento de valor    --BUG 30326/171842 - DCT - 03/04/2014
         w_iextrap :=
                 f_round (registre.iextrap * w_pp_porce /*pp_porce*/,
                          pmoneda);
--BUG CONF-479  Fecha (20/01/2017) - HRE - suplemento aumento de valor    --BUG 30326/171842 - DCT - 03/04/2014

         -- FI BUG 0010844 - 14/09/2009 - FAL
         -->DBMS_OUTPUT.put_line('>>> Registre.CGARANT:' || registre.cgarant);
         -->DBMS_OUTPUT.put_line(' w_iprirea :' || w_iprirea || ' registre.iprirea:'
         --> || registre.iprirea || ' pp_porce:' || pp_porce || ' pmoneda:'
         -->|| pmoneda);
         ----dbms_outpuT.put_line('dif data 1 '||TO_CHAR(regaux1.fconini,'dd/mm/yyyy')||'-'|| TO_CHAR(w_fconfin,'dd/mm/yyyy'));
         -- 44.0 - 16/10/2013 - MMM - 0026194: NOTA_0156003_Qtracker 0006484 Cesion de prima por emision - Inicio
         --codi_error := f_difdata(registre.fconini, registre.fconfin, 1, 3, w_dias);

         --AGG 06/03/2014 Se puede dar el caso de que el campo fconfin no esté actualizado
         --ya que se calcula en un paso posterior a este, si es así, lo calculamos de la misma manera
         --que se calcula posteriormente
         IF registre.fconfin IS NULL
         THEN
            SELECT DECODE (fcaranu, NULL, fvencim, fcaranu), frenova,
                   nrenova, fefecto, cramo, cmodali, ctipseg,
                   ccolect
              INTO v_fconfin, v_frenova,
                   v_nrenova, v_fefecto, v_cramo, v_cmodali, v_ctipseg,
                   v_ccolect
              FROM seguros
             WHERE sseguro = registre.sseguro;

            --INICIO - BUG38692 - DCT - 17/11/2015
            IF v_fconfin IS NULL
            THEN
               --Calculamos la fecha de vencimiento. Para la ppoliza propuesta de alta la fcaranu aun no esta calculada, por
               --esto llamamos a la función para que la calcule
               v_fconfin :=
                  pac_cesionesrea.f_calcula_vto_poliza (v_frenova,
                                                        v_nrenova,
                                                        v_fefecto,
                                                        v_cramo,
                                                        v_cmodali,
                                                        v_ctipseg,
                                                        v_ccolect
                                                       );
            END IF;

            --FIN - BUG38692 - DCT - 17/11/2015
            codi_error :=
                         f_difdata (registre.fconini, v_fconfin, 3, 3, w_dias);
         ELSE
            codi_error :=
                 f_difdata (registre.fconini, registre.fconfin, 3, 3, w_dias);
         END IF;

         SELECT fvencim, fefecto
           INTO v_fconfin, v_fefecto
           FROM seguros
          WHERE sseguro = registre.sseguro;

         -- 44.0 - 16/10/2013 - MMM - 0026194: NOTA_0156003_Qtracker 0006484 Cesion de prima por emision - Fin

         -- nos indica que sí se deberían prorratear los movimientos de suplementos.
         -- No hacemos diferencias por forma de pago (entre f.ini i fin max 1 año).

         -- BUG 0011512 - 21/10/2009 - FAL - Covertir el paràmetre de instal.lació de prorrateig en la N.P per un parproducto
         IF (pmotiu IN (9, 4, 1, 3))
         THEN                                          -- Añadimos el pmotiu 1
            -- BUG 0010844 - 31/08/2009 - FAL - Afegir prorrateig de la cessio en la Nova Producció unicament per CIV. Añadimos el pmotiu 3
            IF     pmotiu = 3
               AND        -->> Per defecte tots els productes prorrategen <<--
                   NVL (f_parproductos_v (pp_sproduc, 'NO_PRORRATEA_REA'), 0) =
                                                                             1
            THEN
               NULL;                                     -- >> NO PRORRATEJA!
            ELSE
               -- FI BUG 0011512 - 21/10/2009 - FAL
               -- 44.0 - 16/10/2013 - MMM - 0026194: NOTA_0156003_Qtracker 0006484 Cesion de prima por emision - Inicio
               --codi_error := f_difdata(registre.fconini, ADD_MONTHS(registre.fconini, 12), 1, 3, w_divisoranual);   --Año bisiesto
               codi_error :=
                  f_difdata (registre.fconini,
                             ADD_MONTHS (registre.fconini, 12),
                             3,
                             3,
                             w_divisoranual
                            );
               -- 44.0 - 16/10/2013 - MMM - 0026194: NOTA_0156003_Qtracker 0006484 Cesion de prima por emision - Fin
               -- BUG 0010844 - 14/09/2009 - FAL - Substituir f_round_forpag per f_round a f_insert_ces
               w_iprirea :=
                      f_round ((w_iprirea * w_dias) / w_divisoranual, pmoneda);
                   -- INI BUG 18423 - 15/12/2011 - JLB - LCOL000 - Multimoneda
               w_ipritarrea :=
                   f_round ((w_ipritarrea * w_dias) / w_divisoranual, pmoneda);
                   -- INI BUG 18423 - 15/12/2011 - JLB - LCOL000 - Multimoneda
               w_idtosel :=
                      f_round ((w_idtosel * w_dias) / w_divisoranual, pmoneda);
                   -- INI BUG 18423 - 15/12/2011 - JLB - LCOL000 - Multimoneda
               w_iextrea :=
                      f_round ((w_iextrea * w_dias) / w_divisoranual, pmoneda);
                                         --BUG 30326/171842 - DCT - 03/04/2014
               w_iextrap :=
                      f_round ((w_iextrap * w_dias) / w_divisoranual, pmoneda);
                                         --BUG 30326/171842 - DCT - 03/04/2014
            -- FI BUG 0010844 - 14/09/2009 - FAL
            END IF;
         END IF;

         --08/05/2014 AGG Añadimos la comisión de la extra prima
         BEGIN
            SELECT irecarg, iextrap, icapital
              INTO v_irecarg, v_iextrap, v_icapital
              FROM garanseg
             WHERE sseguro = registre.sseguro AND cgarant = registre.cgarant;

            SELECT pcomext
              INTO v_pcomext
              FROM contratos
             WHERE scontra = registre.scontra AND nversio = registre.nversio;

            --Comisión extra prima
            --(Extra prima cedia por salud + Valor extra prima cedida por ocupación) * %Comisión extraprima
            w_icomext := (v_irecarg + (v_iextrap * v_icapital)) * v_pcomext;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               w_icomext := 0;
            WHEN OTHERS
            THEN
               w_icomext := 0;
         END;

         w_psobreprima := registre.psobreprima;
         w_itarifrea := registre.itarifrea;
         p_traza_proceso (24,
                          'TRAZA_CESIONES_REA',
                          777,
                          'PAC_CESIONES',
                          'F_INSERT_CES',
                          NULL,
                          2,
                             'Error: paso 3,
        w_capces: '
                          || w_capces
                          || ' w_porce:'
                          || w_porce
                          || ' w_pp_capce:'
                          || w_pp_capce
                          || ' w_pp_porce:'
                          || w_pp_porce
                         );
         w_capces := w_pp_capce;
        --BUG CONF-479  Fecha (20/01/2017) - HRE - suplemento aumento de valor
         w_porce := w_pp_porce;
        --BUG CONF-479  Fecha (20/01/2017) - HRE - suplemento aumento de valor

		--INI IAXIS BUG 10563 AABG: Se coloca valor de porcentaje calculado en pp_local  
         IF w_pp_porce IS NOT NULL AND w_pp_porce > 0 AND pmotiu = 4 THEN
            v_porc_cesion := w_pp_porce;
         ELSE
            v_porc_cesion := pp_local;
         END IF;
		 
         --FIN AGG 08/05/2014
          -- 4472 - INI - TOMAR REPARTICION DE % DE AMPARO PARA FACULTATIVO
		 IF (pp_tramo NOT IN (0, 5) AND NVL (v_porc_cesion, 0) > 0)
         --FIN IAXIS BUG 10563 AABG: Se coloca valor de porcentaje calculado en pp_local
         THEN
            w_iprirea_l := w_iprirea;
            w_capces_l := w_pp_capce;
       --BUG CONF-479  Fecha (20/01/2017) - HRE - suplemento aumento de valor
            w_porce_l := w_pp_porce;
       --BUG CONF-479  Fecha (20/01/2017) - HRE - suplemento aumento de valor
            w_ipritarrea_l := w_ipritarrea;
            w_idtosel_l := w_idtosel;
            w_psobreprima_l := registre.psobreprima;
            w_iextrea_l := w_iextrea;
            w_iextrap_l := w_iextrap;
            w_itarifrea_l := registre.itarifrea;
            w_icomext_l := w_icomext;
            --
            --INI IAXIS 10563 AABG: Se obtiene el pp_local para calculos posteriores
            w_pp_local := v_porc_cesion / 100;
            --w_pp_local := pp_local / 100;
            --FIN IAXIS 10563 AABG: Se obtiene el pp_local para calculos posteriores
            w_iprirea := w_iprirea * (1 - w_pp_local);
            w_capces := w_pp_capce /*pp_capces*/ * (1 - w_pp_local);
       --BUG CONF-479  Fecha (20/01/2017) - HRE - suplemento aumento de valor
            w_porce := w_pp_porce /*pp_porce*/ * (1 - w_pp_local);
       --BUG CONF-479  Fecha (20/01/2017) - HRE - suplemento aumento de valor
            p_traza_proceso (24,
                             'TRAZA_CESIONES_REA',
                             777,
                             'PAC_CESIONES',
                             'F_INSERT_CES',
                             NULL,
                             2,
                                'Error: paso 4,
        w_capces: '
                             || w_capces
                             || ' w_pp_capce:'
                             || w_pp_capce
                             || ' w_pp_local:'
                             || w_pp_local
                             || ' w_porce:'
                             || w_porce
                             || ' w_pp_porce:'
                             || w_pp_porce
                            );
            w_ipritarrea := w_ipritarrea * (1 - w_pp_local);
            w_idtosel := w_idtosel * (1 - w_pp_local);
            w_psobreprima := registre.psobreprima * (1 - w_pp_local);
            w_iextrea := w_iextrea * (1 - w_pp_local);
            w_iextrap := w_iextrap * (1 - w_pp_local);
            w_itarifrea := registre.itarifrea * (1 - w_pp_local);
            w_icomext := w_icomext * (1 - w_pp_local);
         END IF;

         -- 4472 - FIN - TOMAR REPARTICION DE % DE AMPARO PARA FACULTATIVO
         IF (ptipper != 'P' OR (ptipper = 'P' AND pp_tramo = 5))
         THEN
    --para participantes de consorcios no se crea cesionesrea, solo el detalle
            IF (ptipper = 'C' AND pp_tramo = 5)
            THEN
               v_ctrampa := 5;
            ELSE
               v_ctrampa := pctrampa;                                 --NULL;
            END IF;

            -- INI - ML - 5028 - 04/09/2019 - CORRECCION EN CESION PARA CUTOFF
            -- ML - REV1 - PORCENTAJE pp_local
            DECLARE
               valor_retencion        NUMBER := 0;
               porcentaje_q           NUMBER := 0;
               valor_qn               NUMBER := 0;
               valor_cutoff           NUMBER := 0;
               porcentaje_cesion      NUMBER := 0;
               linea                  NUMBER := 0;
               resp                   NUMBER := 0;
               porcentaje_retencion   NUMBER := 0;
            BEGIN
               -- 0 NORMALIZAR PORCENTAJE
               --INI IAXIS 10563 AABG: Se obtiene el pp_local para calculos posteriores
               porcentaje_retencion := NVL (v_porc_cesion, 0) / 100;
               --porcentaje_retencion := NVL (pp_local, 0) / 100;
               --FIN IAXIS 10563 AABG: Se obtiene el pp_local para calculos posteriores
               -- 1 CALCULAR VALOR DE RETENCION DEL TRAMO => VALOR DEL TRAMO * PORCENTAJE RETENCION (CUOTA PARTE DEL TRAMO)
                --INI IAXIS BUG 13246 AABG: Para calcular u obtener el valor de Q dependiendo si es Endoso
               IF (pmotiu = 4 AND NVL(pac_parametros.f_parcontrato_n(registre.scontra, 'REA_MANTIENE_SUPL', pp_sproduc),0) = 1 AND w_pp_supl = 1 AND w_pp_capce > 0) THEN
                valor_retencion := w_pp_capce / 100;
               ELSE
                valor_retencion := pp_capces * porcentaje_retencion;
               END IF;               
               --FIN IAXIS BUG 13246 AABG: Para calcular u obtener el valor de Q dependiendo si es Endoso
               -- 2 CALCULAR EL PORCENTAJE PARA Q => 1 - PORCENTAJE RETENCION (CUOTA PARTE DEL TRAMO)
               porcentaje_q := 1 - porcentaje_retencion;
               -- 3 CALCULAR VALOR PARA QN => VALOR DEL TRAMO * %Q
               --INI IAXIS BUG 13246 AABG: Para calcular u obtener el valor de Q dependiendo si es Endoso
               IF (pmotiu = 4 AND NVL(pac_parametros.f_parcontrato_n(registre.scontra, 'REA_MANTIENE_SUPL', pp_sproduc),0) = 1 AND w_pp_supl = 1 AND w_pp_capq > 0) THEN
                valor_qn := w_pp_capq / 100;
               ELSE
                valor_qn := pp_capces * porcentaje_q;
               END IF;               
               --FIN IAXIS BUG 13246 AABG: Para calcular u obtener el valor de Q dependiendo si es Endoso

               -- 4 CALCULO VALOR PARA CUT OFF => VALOR DE QN * %CUT OFF
               IF pcutoff = 'S'
               THEN
                  valor_cutoff := valor_qn * (1 - pp_porce);
               END IF;

               -- 5 INSERT DE VALOR QN
               resp :=
                  insert_rcesionesrea ((valor_qn - valor_cutoff),
                                       pp_cesio,
                                       w_iprirea,
                                       registre,
                                       pp_tramo,
                                       pp_facult,
                                       v_fefecto,
                                       v_fconfin,
                                       pmotiu,
                                       avui,
                                       w_ipritarrea,
                                       w_idtosel,
                                       w_psobreprima,
                                       w_nmovigen,
                                       w_iextrea,
                                       w_iextrap,
                                       w_itarifrea,
                                       w_icomext,
                                       NULL,
                                       'N'
                                      );

               IF resp != 0
               THEN
                  RAISE VALUE_ERROR;
               END IF;

               linea := 1;

               -- 6 INSERT DE RETENCION POR TRAMO
               IF porcentaje_retencion > 0
               THEN
                  resp :=
                     insert_rcesionesrea (valor_retencion,
                                          pp_cesio,
                                          w_iprirea,
                                          registre,
                                          0,
                                          pp_facult,
                                          v_fefecto,
                                          v_fconfin,
                                          pmotiu,
                                          avui,
                                          w_ipritarrea,
                                          w_idtosel,
                                          w_psobreprima,
                                          w_nmovigen,
                                          w_iextrea,
                                          w_iextrap,
                                          w_itarifrea,
                                          w_icomext,
                                          pp_tramo, -- IAXIS-12992 27/04/2020
                                          'N'
                                         );

                  IF resp != 0
                  THEN
                     RAISE VALUE_ERROR;
                  END IF;
               END IF;

               linea := 2;

               -- 7 INSERT DE RETENCION CUTOFF
               IF pcutoff = 'S'
               THEN
                  resp :=
                     insert_rcesionesrea (valor_cutoff,
                                          pp_cesio,
                                          w_iprirea,
                                          registre,
                                          0,
                                          pp_facult,
                                          v_fefecto,
                                          v_fconfin,
                                          pmotiu,
                                          avui,
                                          w_ipritarrea,
                                          w_idtosel,
                                          w_psobreprima,
                                          w_nmovigen,
                                          w_iextrea,
                                          w_iextrap,
                                          w_itarifrea,
                                          w_icomext,
                                          1,
                                          'S'
                                         );

                  IF resp != 0
                  THEN
                     RAISE VALUE_ERROR;
                  END IF;
               END IF;

               linea := 3;
            EXCEPTION
               WHEN OTHERS
               THEN
                  -- REGISTRAR ERROR
                  p_tab_error (f_sysdate,
                               f_user,
                               'PAC_CESIONES',
                               linea,
                               'f_insert_ces',
                               SQLERRM
                              );
                  RAISE VALUE_ERROR;
            END;
         -- FIN - ML - 5028 - 04/09/2019 - CORRECCION EN CESION PARA CUTOFF
         END IF;
      END IF;                              --FIN - BUG38692 - DCT - 17/11/2015

      -- 47.0 - 29/11/2013 - MMM - 0028082 LCOL_A004-0008810 CLF2-4054 LISTADOS DE PRIMAS CEDIDAS VIDA PROPORCIONAL - Fin
      RETURN (0);
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'f_cessio',
                      1,
                      'f_insert_ces',
                      SQLERRM
                     );
         perr := 104692;
         RETURN (perr);
   END f_insert_ces;

-- *********************************************************************
   PROCEDURE cabfacul (
      regaux1        cesionesaux%ROWTYPE,
      ptablas   IN   VARCHAR2 DEFAULT 'EST'
   )
   IS
      /**********************************************************************
         procediment CABFACUL per fer insert a capçalera de facultatiu (CUAFACUL)
      I A FACPENDIENTES ( si ja existeix, no fa res)...
      **********************************************************************/
      w_sfacult             cuafacul.sfacult%TYPE;
      w_pfacced             cuafacul.pfacced%TYPE;
      w_ifacced             cuafacul.ifacced%TYPE;
      w_controllat          NUMBER (1);
      w_cramo               seguros.cramo%TYPE;
      w_scontra             reaseguroaux.scontra%TYPE;
      w_nversio             reaseguroaux.nversio%TYPE;
      w_sproduc             seguros.sproduc%TYPE;
	  
	  --INI IAXIS BUG 13246 AABG: Varibale para contabilizar el facultativo
      w_fac_maual           NUMBER := 0;
      w_val_porc_ces        NUMBER := 0;
      --FIN IAXIS BUG 13246 AABG: Varibale para contabilizar el facultativo
	  
--w_capital_principal NUMBER;
----------------
      perr                  NUMBER                      := 0;
      w_cempres             NUMBER;
      w_cmodali             NUMBER;
      w_ctipseg             NUMBER;
      w_ccolect             NUMBER;
      w_cactivi             NUMBER;  --,                            w_sproduc
      w_gar_princ           NUMBER;
      w_capital_principal   NUMBER;
----------------
   BEGIN
      p_traza_proceso (24,
                       'TRAZA_CESIONES_REA',
                       777,
                       'PAC_CESIONES',
                       'CABFACUL',
                       NULL,
                       1143,
                          'ptablas:'
                       || ptablas
                       || ' regaux1.scontra:'
                       || regaux1.scontra
                      );

      ----dbms_outpuT.put_line('Entra a cabfacul');
      IF regaux1.scontra IS NULL
      THEN
         -- Busquem el ram per el SCONTRA ( si facultatiu pur)...
         IF ptablas = 'EST'
         THEN
            BEGIN    -- Busquem el ram per el SCONTRA ( si facultatiu pur)...
               SELECT cramo, sproduc
                 INTO w_scontra, w_sproduc
                 FROM estseguros
                WHERE sseguro = regaux1.sseguro;
            --INI BUG CONF-695  Fecha (29/05/2017) - HRE - Redistribucion Reaseguro
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  SELECT cramo, sproduc
                    INTO w_scontra, w_sproduc
                    FROM seguros
                   WHERE sseguro = regaux1.sseguro;
            --FIN BUG CONF-695  - Fecha (29/05/2017) - HRE
            END;
         ELSIF ptablas = 'CAR'
         THEN
            BEGIN    -- Busquem el ram per el SCONTRA ( si facultatiu pur)...
               SELECT cramo, sproduc
                 INTO w_scontra, w_sproduc
                 FROM seguros
                WHERE sseguro = regaux1.sseguro;
            END;
         ELSE
            BEGIN    -- Busquem el ram per el SCONTRA ( si facultatiu pur)...
               SELECT cramo
                 INTO w_scontra
                 FROM seguros
                WHERE sseguro = regaux1.sseguro;
            END;
         END IF;

         w_nversio := 1;
      ELSE
         w_scontra := regaux1.scontra;
         w_nversio := regaux1.nversio;
      END IF;

      w_controllat := 0;
	  
	  --INI IAXIS BUG 13246 AABG: Ajuste para creacion de facultativo al tener cesion manual con facultativo
      SELECT COUNT(*) INTO w_fac_maual
           FROM cesionesrea 
          WHERE sseguro = regaux1.sseguro
            AND nriesgo = regaux1.nriesgo
            AND NVL (cgarant, 0) = NVL (regaux1.cgarant, 0)
            AND nmovimi = regaux1.nmovimi
            AND sfacult IS NOT NULL
            AND ctramo = 5
            AND ctipomov = 'M';  
    
        
            
       IF w_fac_maual > 0 THEN
        UPDATE cuafacul SET cestado = 2 
        WHERE sseguro = regaux1.sseguro
            AND nriesgo = regaux1.nriesgo
            AND NVL (cgarant, 0) = NVL (regaux1.cgarant, 0)
            AND nmovimi = regaux1.nmovimi;
            
        SELECT pcesion INTO w_val_porc_ces
           FROM cesionesrea 
          WHERE sseguro = regaux1.sseguro
            AND nriesgo = regaux1.nriesgo
            AND NVL (cgarant, 0) = NVL (regaux1.cgarant, 0)
            AND nmovimi = regaux1.nmovimi
            AND sfacult IS NOT NULL
            AND ctramo = 5
            AND ctipomov = 'M';
            
       END IF;
      --FIN IAXIS BUG 13246 AABG: Ajuste para creacion de facultativo al tener cesion manual con facultativo
	  
      p_traza_proceso (24,
                       'TRAZA_CESIONES_REA',
                       777,
                       'PAC_CESIONES',
                       'CABFACUL',
                       NULL,
                       1186,
                          'w_scontra:'
                       || w_scontra
                       || ' w_nversio:'
                       || w_nversio
                       || ' w_cramo:'
                       || w_cramo
                      );

      BEGIN
         SELECT COUNT (*)
           INTO w_sfacult
           FROM cuafacul /* BUG 10462: ETM:16/06/2009:--ANTES--facpendientes*/
          WHERE sseguro = regaux1.sseguro
            AND nriesgo = regaux1.nriesgo
            AND NVL (cgarant, 0) = NVL (regaux1.cgarant, 0)
            AND nmovimi = regaux1.nmovimi
            AND cestado = 1;
                        /* BUG 10462: ETM:16/06/2009:--AÑADIMOS-- CESTADO=1-*/

         p_traza_proceso (24,
                          'TRAZA_CESIONES_REA',
                          777,
                          'PAC_CESIONES',
                          'CABFACUL',
                          NULL,
                          1199,
                             'regaux1.sseguro:'
                          || regaux1.sseguro
                          || ' regaux1.nriesgo:'
                          || regaux1.nriesgo
                          || ' regaux1.cgarant:'
                          || regaux1.cgarant
                          || ' regaux1.nmovimi:'
                          || regaux1.nmovimi
                          || ' w_cramo:'
                          || w_cramo
                         );

         IF w_sfacult > 0
         THEN
            w_controllat := 1;                  -- Ja está a FACPENDIENTES...
         END IF;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            NULL;
         WHEN OTHERS
         THEN
            perr := 105032;
      END;

      p_traza_proceso (24,
                       'TRAZA_CESIONES_REA',
                       777,
                       'PAC_CESIONES',
                       'CABFACUL',
                       NULL,
                       1255,
                          'w_controllat:'
                       || w_controllat
                       || ' w_sfacult:'
                       || w_sfacult
                       || ' regaux1.sseguro:'
                       || regaux1.sseguro
                       || ' regaux1.nriesgo:'
                       || regaux1.nriesgo
                       || ' regaux1.cgarant:'
                       || regaux1.cgarant
                       || ' regaux1.nmovimi:'
                       || regaux1.nmovimi
                       || ' regaux1.scumulo:'
                       || regaux1.scumulo
                       || ' perr:'
                       || perr
                      );

      ----dbms_outpuT.put_line(' DINS DE CABFACUL garantia '||regaux1.cgarant);
      ----dbms_outpuT.put_line(' DINS DE CABFACUL el cumul és '||regaux1.scumulo);
      IF w_controllat = 0
      THEN                          -- Tenim que fer l'insert en FACPENDIENTES
         IF regaux1.scumulo IS NOT NULL
         THEN
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
                  AND (cgarant = regaux1.cgarant OR regaux1.cgarant IS NULL)
                  AND cestado = 1;

               w_controllat := 2;         -- No hem de fer l'insert a CUAFACUL
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  p_traza_proceso (24,
                                   'TRAZA_CESIONES_REA',
                                   777,
                                   'PAC_CESIONES',
                                   'CABFACUL',
                                   NULL,
                                   1284,
                                   'NO_DATA_FOUND'
                                  );
                  NULL;
               ----dbms_outpuT.put_line(' INsert pendent ');
               WHEN OTHERS
               THEN
                  perr := 104486;
            END;
         END IF;

         p_traza_proceso (24,
                          'TRAZA_CESIONES_REA',
                          777,
                          'PAC_CESIONES',
                          'CABFACUL',
                          NULL,
                          1291,
                             'w_controllat:'
                          || w_controllat
                          || ' w_sfacult:'
                          || w_sfacult
                          || ' regaux1.sseguro:'
                          || regaux1.sseguro
                          || ' regaux1.nriesgo:'
                          || regaux1.nriesgo
                          || ' regaux1.cgarant:'
                          || regaux1.cgarant
                          || ' regaux1.nmovimi:'
                          || regaux1.nmovimi
                          || ' regaux1.scumulo:'
                          || regaux1.scumulo
                          || ' perr:'
                          || perr
                         );

         IF w_controllat = 0
         THEN                          -- No tenim identificador de facultatiu
            SELECT sfacult.NEXTVAL
              INTO w_sfacult
              FROM DUAL;
         END IF;

         p_traza_proceso (24,
                          'TRAZA_CESIONES_REA',
                          777,
                          'PAC_CESIONES',
                          'CABFACUL',
                          NULL,
                          1235,
                             'w_controllat:'
                          || w_controllat
                          || ' w_sfacult:'
                          || w_sfacult
                          || ' regaux1.sseguro:'
                          || regaux1.sseguro
                          || ' regaux1.nriesgo:'
                          || regaux1.nriesgo
                          || ' regaux1.cgarant:'
                          || regaux1.cgarant
                          || ' regaux1.nmovimi:'
                          || regaux1.nmovimi
                          || ' regaux1.scumulo:'
                          || regaux1.scumulo
                          || ' perr:'
                          || perr
                         );

         IF w_controllat = 0
         THEN
            -- Donem d'alta la capçalera nova a CUAFACUL
            IF regaux1.scontra IS NOT NULL
            THEN
               BEGIN
                  BEGIN
                     SELECT cempres, cramo,    --ctiprea, 22660 AGM 13/08/2012
                                           cmodali, ctipseg,
                            ccolect, cactivi, sproduc
                       INTO w_cempres, w_cramo,                   --w_ctiprea,
                                               w_cmodali, w_ctipseg,
                            w_ccolect, w_cactivi, w_sproduc
                       FROM seguros
                      WHERE sseguro = regaux1.sseguro;
                  EXCEPTION
                     WHEN OTHERS
                     THEN
                        perr := 101919;
                  END;

                  --BUG 21559 - INICIO - 23/05/2013 - DCT
                  IF     NVL
                            (pac_parametros.f_parproducto_n
                                                          (w_sproduc,
                                                           'GAR_PRINCIPAL_REA'
                                                          ),
                             0
                            ) = 1
                     --BUG 21559 - FIN - 23/05/2013 - DCT
                     AND w_gar_princ <> regaux1.cgarant
                  THEN                                       -- 21559 / 111590
                     BEGIN
                        SELECT ifacced              --pfacced     22666/117640
                          INTO w_ifacced            --w_pfacced   22666/117640
                          FROM cuafacul c
                         WHERE (   sseguro = regaux1.sseguro
                                OR scumulo = regaux1.scumulo
                               )
                           AND c.cgarant = w_gar_princ
                           AND cestado = 1;
                     EXCEPTION
                        WHEN OTHERS
                        THEN
                           perr := 104486;
                     END;

                     w_pfacced := w_ifacced / w_capital_principal * 100;
                     w_ifacced :=
                            regaux1.icapital * w_ifacced / w_capital_principal;
                                                  -- 22666 - GAG  - 27/07/2012
                  ELSE
                     --  En lugar de la capacidad màxima del registro, cogemos
                     --  la capacidad del cumulo
                     --IAXIS INI BUG 13246 AABG: Validacion para calcular el porcCesion y cesion
                     IF w_fac_maual > 0 THEN
                        w_pfacced := w_val_porc_ces;
                        w_ifacced := (regaux1.icapital * w_val_porc_ces) / 100;
                     ELSE 
                          w_pfacced :=
                        (  100
                         * (  regaux1.icapital
                            - lcapaci_cum
             --BUG CONF-620  Fecha (01/03/2017) - HRE - Reaseguro moneda local
                           )
                         / regaux1.icapital
                        );
                        w_ifacced := regaux1.icapital - lcapaci_cum;
                     END IF;
                     --IAXIS FIN BUG 13246 AABG: Validacion para calcular el porcCesion y cesion
             --BUG CONF-620  Fecha (01/03/2017) - HRE - Reaseguro moneda local
                  END IF;

                  p_traza_proceso (24,
                                   'TRAZA_CESIONES_REA',
                                   777,
                                   'PAC_CESIONES',
                                   'CABFACUL',
                                   NULL,
                                   1281,
                                      'w_controllat:'
                                   || w_controllat
                                   || ' w_sfacult:'
                                   || w_sfacult
                                   || ' regaux1.cgarant:'
                                   || regaux1.cgarant
                                   || ' w_gar_princ:'
                                   || w_gar_princ
                                   || ' perr:'
                                   || perr
                                  );
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     w_pfacced := 0;
                     w_ifacced := 0;
               END;
            ELSE
               w_pfacced := 100;
               w_ifacced := regaux1.icapital;
            END IF;

            BEGIN                    -- Posem data final al quadre anterior...
               UPDATE cuafacul
                  SET ffincuf = regaux1.fconini
                WHERE (   sseguro = regaux1.sseguro
                       OR scumulo = NVL (regaux1.scumulo, -1)
                      )
                  AND NVL (nriesgo, 0) =
                         DECODE (scumulo,
                                 NULL, regaux1.nriesgo,
                                 0
                                )                      -- 15590 AVT 30-07-2010
                  AND (cgarant IS NULL OR cgarant = regaux1.cgarant)
                  AND ffincuf IS NULL
                  AND scontra = w_scontra
                  AND nversio = w_nversio;
            EXCEPTION
               WHEN OTHERS
               THEN
                  perr := 107512;
            END;

            BEGIN
               --
               -- Inicio IAXIS-5361 26/05/2020
               --
               -- Agregamos el nuevo campo a la tabla cuafacul ifaccedini a fin de poder almacenar el facultativo calculado automáticamente por la aplicación.
               -- Esto permitirá a futuro realizar posibles validaciones y tomas de decisiones. Además se conservará cierta trazabilidad sobre los valores 
               -- fijados y modificados del facultativo.
               --
               INSERT INTO cuafacul
                           (sfacult, cestado, finicuf, cfrebor, scontra,
                            nversio, sseguro, cgarant,
                            ccalif1, ccalif2,
                            spleno, nmovimi,
                            scumulo,
                            nriesgo,
                            ffincuf, plocal, fultbor, pfacced, ifacced,
                            ncesion, ifaccedini 
                           )
                    VALUES (w_sfacult, 1, regaux1.fconini, 1, w_scontra,
                            w_nversio,
                                      --DECODE(regaux1.scumulo, NULL, regaux1.sseguro, NULL),
                                      regaux1.sseguro, regaux1.cgarant,
                            regaux1.ccalif1, regaux1.ccalif2,
                            regaux1.spleno, regaux1.nmovimi,
                            regaux1.scumulo,
                            DECODE (regaux1.scumulo,
                                    NULL, regaux1.nriesgo,
                                    NULL
                                   ),
                            NULL, NULL, NULL, w_pfacced, w_ifacced,
                            1, w_ifacced 
                           );
               --
               -- Fin IAXIS-5361 26/05/2020
               --            
            EXCEPTION
               WHEN OTHERS
               THEN
                  perr := 104343;
            END;
         END IF;
      END IF;
   END cabfacul;

-- *********************************************************************
   FUNCTION f_facult (
      psseguro    IN       NUMBER,
      pnriesgo    IN       NUMBER,
      pccalif1    IN       VARCHAR2,
      pccalif2    IN       NUMBER,
      pcgarant    IN       NUMBER,
      pscontra    IN       NUMBER,
      pnversio    IN       NUMBER,
      pfinicuf    IN       DATE,
      pscumulo    IN       NUMBER,
      pfdatagen   IN       DATE,
      ptrovat     OUT      NUMBER,
      pcestado    OUT      NUMBER,
      pfacult     OUT      NUMBER,
      pifacced    OUT      NUMBER
   )
      RETURN NUMBER
   IS
      /***********************************************************************
            F_FACULT        : Buscar si existeix un facultatiu.
      ***********************************************************************/
      perr   NUMBER := 0;

      CURSOR cur_facult
      IS
         SELECT   cestado, sfacult, ifacced
             FROM cuafacul c
            WHERE (sseguro = psseguro OR scumulo = pscumulo)
              AND (nriesgo = pnriesgo OR nriesgo IS NULL)
              AND (ccalif1 = pccalif1 OR ccalif1 IS NULL)
              AND (ccalif2 = pccalif2 OR ccalif2 IS NULL)
              AND (cgarant = pcgarant OR cgarant IS NULL)
              AND (   scontra = pscontra
                   OR pscontra IS NULL
                   OR pfdatagen <> f_sysdate
                  )               -- pfdatagen viene informado en la migración
              AND finicuf <= pfinicuf
              AND (ffincuf > pfinicuf OR ffincuf IS NULL)
         ORDER BY sfacult DESC;       --finicuf; DESC; -- 19484 AVT 02/01/2012
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
      FOR regfacult IN cur_facult
      LOOP
         ptrovat := 1;
         pcestado := regfacult.cestado;
         pfacult := regfacult.sfacult;
         pifacced := regfacult.ifacced;
         EXIT;
      END LOOP;

      RETURN (perr);
   END f_facult;

   FUNCTION f_cessio (
      psproces    IN   NUMBER,
      pmotiu      IN   NUMBER,
      pmoneda     IN   NUMBER,
      pfdatagen   IN   DATE DEFAULT f_sysdate,
      pcgesfac    IN   NUMBER DEFAULT 0,
                            -- AQUÍ S'HAURÀ DE CONTROLAR SI VENIM DE L'EMISSIÓ
      ptablas     IN   VARCHAR2 DEFAULT 'EST'
   )                                         -- 19484 1-Fer o 0-No Facultatiu)
      RETURN NUMBER
   IS
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
              9.0        28/10/2013   JGR/AVT 9. 20606: LCOL_T004-LCOL_T001- Recalcul de les cessions per cúmul amb facultatiu - Nota:0101205
              10.0        02/01/2012   AVT    10. 19484: LCOL_T001: Retención por facultativo antes de emitir la propuesta: ajustar quan hi ha més d'un q.fac
              11.0        06/03/2012   AVT    11. 21559: LCOL999-Cambios en el Reaseguro: Distribución de los Capitales con base en la garantía principal
              12.0        14/05/2012   AVT    12. 22237: LCOL_A002-Incidencias de QT sobre el reaseguro proporcional QT:4564
              13.0        25/07/2012   AVT    13. 22686: LCOL_A004-Cumulos anulados anteriormente a la alta de polizas
              14.0        27/07/2012   GAG    14. 0022666: LCOL_A002-Qtracker: 0004556: Cesion capitales en riesgo
              15.0        13/08/2012   AVT    15. 22660: CALI003-Incidencies amb el contracte de la reasseguran
              16.0        15/02/2013   DCT    16. 0025502: LCOL_T020-Qtracker: 0005655: Validacion campos pantalla facultativos
              17.0        04/03/2013   KBR    17. 0026142: LCOL_A004-Qtracker: 6428: Error al emitir certificado cero después de realizar un supl en un certif
              individual
              18.0        14/03/2013   KBR    18. 0026283: Incidencia de cúmulo para colectivos Liberty
              19.0        07/08/2013   AVT    19. 0026663: POSPG400-(POSPG400)- Parametrizacion Reaseguro, Coaseguro - Parametrizacion contratos (???)
              20.0        16/10/2013   MMM    20. 0026194_NOTA_0156003_Qtracker 0006484 Cesion de prima por emision
              21.0        28/10/2013   AVT    21. 0028492: LCOLF3BREA-Revisi?n de los contratos de REASEGURO F3B (NOTA:0156038)
              22.0        04/12/2019   INFORCOL 22. REASEGURO FASE 1 Sprint 1 Ajustes para reaseguro facultativo RC
      ***********************************************************************/
        --lpleno         NUMBER;
      lnmovigen             cesionesrea.nmovigen%TYPE;
      perr                  NUMBER                        := 0;
      codi_error            NUMBER;
      w_fconini             cesionesaux.fconini%TYPE;
      w_dias                NUMBER;
      w_iprirea             cesionesrea.icesion%TYPE;
      w_ipritarrea          cesionesrea.ipritarrea%TYPE;
      w_idtosel             cesionesrea.idtosel%TYPE;
      w_iextrea             cesionesrea.iextrea%TYPE;
                                        --BUG 30326/171842 - DCT - 03/04/2014
      w_iextrap             cesionesrea.iextrap%TYPE;
                                        --BUG 30326/171842 - DCT - 03/04/2014
      w_icomext             cesionesrea.icomext%TYPE;
                                             --GAP 97 Positiva 07/05/2014 AGG
      w_spleno              codicontratos.spleno%TYPE;
      w_ipleno              cesionesaux.ipleno%TYPE;
      w_ccalif1             cesionesaux.ccalif1%TYPE;
      w_ccalif2             cesionesaux.ccalif2%TYPE;
      w_icapital            cesionesaux.icapital%TYPE;
      w_cgarant             garanpro.cgarant%TYPE;
      w_trobat              NUMBER (1);
      w_nriesgo             cesionesaux.nriesgo%TYPE;
      w_scontra             cesionesaux.scontra%TYPE;
      w_nversio             cesionesaux.nversio%TYPE;
      w_scumulo             cesionesaux.scumulo%TYPE;
      cum_capital           cesionesaux.icapital%TYPE;
      w_icapaci             contratos.icapaci%TYPE;
      --w_ctiprea      seguros.ctiprea%TYPE := 1;--Esta funcionalidad aplica solamente para cuotas partes
      w_nplenos             tramos.nplenos%TYPE;
      w_impfac              NUMBER (15, 2);
      w_cestado             NUMBER (2);
      pfacult               cuafacul.sfacult%TYPE;
      pncesion              cuafacul.ncesion%TYPE;
      w_plocal              cuafacul.plocal%TYPE;
      w_sproces             cesionesaux.sproces%TYPE;
      w_sseguro             seguros.sseguro%TYPE;
      w_nmovimi             cesionesaux.nmovimi%TYPE;
      w_pcedido             contratos.pcedido%TYPE;
      w_cduraci             seguros.cduraci%TYPE;
      w_ctipre_seg          seguros.ctiprea%TYPE;
                                   -- Ind. tipus reaseguranca ->> CVALOR = 60
      w_ifacced             cuafacul.ifacced%TYPE;
      w_porcgarant          NUMBER (5, 2);
      w_switchgarant        NUMBER (1);
      w_icapacigarant       capgarant.icapaci%TYPE;
      w_porcaux             NUMBER (5, 2);
      w_capmax              NUMBER;
                              -- 25803: Ampliar los decimales  NUMBER(15, 2);
      w_cvidaga             codicontratos.cvidaga%TYPE;
      w_nagrupa             cesionesaux.nagrupa%TYPE;
      --w_nagrupavi    NUMBER(4); 13195 AVT 16-02-2010
      w_cgar                garanseg.cgarant%TYPE;
      w_cforpag             seguros.cforpag%TYPE;
      w_divisoranual        NUMBER;
      -- Divisor prorrateos año bisiesto
      w_dias_origen         NUMBER;
      w_fefecto             seguros.fefecto%TYPE;
      w_fvencim             seguros.fvencim%TYPE;
      lcforamor             NUMBER;
      lcapicum              NUMBER;
      lplecum               NUMBER;
      lcapacum              NUMBER;
      lassumir              NUMBER;
      --lcapcumtram    NUMBER;
      lcapcum_tot           NUMBER;
      lplecum_tot           NUMBER;
      w_captram_tot         NUMBER;
      w_sproduc             seguros.sproduc%TYPE;
      w_cramo               seguros.cramo%TYPE;
      w_cmodali             seguros.cmodali%TYPE;
      w_ctipseg             seguros.ctipseg%TYPE;
      w_ccolect             seguros.ccolect%TYPE;
      w_cactivi             seguros.cactivi%TYPE;
      w_cempres             seguros.cempres%TYPE;
      registre              cesionesaux%ROWTYPE;
      w_nmovigen            NUMBER;
      avui                  DATE;
      w_gar_princ           NUMBER;                         -- 21559 / 111590
      w_fac_princ           NUMBER;                                  -- 22237
      w_registre            NUMBER                        := 0;
      w_capital             NUMBER                        := 0;
                                                      -- 22237 AVT 15/05/2012
      w_capital_principal   NUMBER;
      w_cdetces             NUMBER;                      --28492 AVT 13-11-13
      v_hiha_ces            NUMBER                        := 0;
                                                            -- 21/01/2014 AVT
      vpar_traza            VARCHAR2 (80)             := 'TRAZA_CESIONES_REA';
                                                            -- 08/04/2014 AGG
      v_nom_paquete         VARCHAR2 (80)                 := NULL;
      v_nom_funcion         VARCHAR2 (80)                 := 'F_CESSIO';
      v_base_rea            NUMBER                        := 0;
                                                            -- AGG 25/04/2014
      v_crecimiento         NUMBER                        := 0;
                                                            -- AGG 25/04/2014
      v_tiene_facul         NUMBER                        := 0;
                                                            -- AGG 25/04/2014
      v_secuencia           NUMBER                        := 0;
      v_capagrup            NUMBER                        := 0;             --
      v_sconagr             NUMBER                        := 4;             --
      v_claveq3             sgt_formulas.clave%TYPE       := 999783;
                                                         --formula para el q3
      v_lim_ret             NUMBER;
      v_lim_cum             NUMBER;
	  
	   --INI IAXIS 13246 AABG: Variable para validar el facultativo
      v_apl_facul           NUMBER := 0;
	  --FIN IAXIS 13246 AABG: Variable para validar el facultativo
	  
	
      CURSOR cur_aux_1
      IS
         SELECT   *
             FROM cesionesaux
            WHERE sproces = psproces AND cestado != 7  --reaseguro x garantia
         ORDER BY (icapaci - icapital), cgarant DESC; -- 19484 AVT 02/01/2012

      CURSOR cur_aux_2
      IS
         SELECT   *
             FROM cesionesaux
            WHERE cestado = 0 AND sproces = psproces
         ORDER BY nriesgo,
                  spleno,
                  ccalif1,
                  ccalif2,
                  scontra,
                  nversio,
                  scumulo,
                  nagrupa,
                  cgarant;

      CURSOR cur_aux_3
      IS
         SELECT cgarant, iprirea, icapital, ipritarrea, idtosel
           FROM cesionesaux
          WHERE NVL (nriesgo, 0) = NVL (w_nriesgo, 0)
            AND NVL (spleno, 0) = NVL (w_spleno, 0)
            AND NVL (ccalif1, ' ') = NVL (w_ccalif1, ' ')
            AND NVL (ccalif2, 0) = NVL (w_ccalif2, 0)
            AND NVL (scontra, 0) = NVL (w_scontra, 0)
            AND NVL (nversio, 0) = NVL (w_nversio, 0)
            AND NVL (scumulo, 0) = NVL (w_scumulo, 0)
            AND NVL (nagrupa, 0) = NVL (w_nagrupa, 0)
            AND cgarant IS NULL
            AND cestado = 1
            AND sproces = psproces;

      CURSOR cur_aux_4
      IS
         SELECT cgarant, iprirea, icapital, ipritarrea, idtosel
           FROM cesionesaux
          WHERE NVL (nriesgo, 0) = NVL (w_nriesgo, 0)
            AND NVL (spleno, 0) = NVL (w_spleno, 0)
            AND NVL (ccalif1, ' ') = NVL (w_ccalif1, ' ')
            AND NVL (ccalif2, 0) = NVL (w_ccalif2, 0)
            AND NVL (scontra, 0) = NVL (w_scontra, 0)
            AND NVL (nversio, 0) = NVL (w_nversio, 0)
            AND NVL (scumulo, 0) = NVL (w_scumulo, 0)
            AND NVL (nagrupa, 0) = NVL (w_nagrupa, 0)
            AND cgarant IS NOT NULL
            AND NVL (cgarant, 0) <> NVL (w_cgarant, 0)
            AND cestado = 1
            AND sproces = psproces;

      CURSOR cur_aux_5
      IS
         SELECT cgarant, iprirea, icapital, ipritarrea, idtosel
           FROM cesionesaux
          WHERE NVL (nriesgo, 0) = NVL (w_nriesgo, 0)
            AND NVL (spleno, 0) = NVL (w_spleno, 0)
            AND NVL (ccalif1, ' ') = NVL (w_ccalif1, ' ')
            AND NVL (ccalif2, 0) = NVL (w_ccalif2, 0)
            AND NVL (scontra, 0) = NVL (w_scontra, 0)
            AND NVL (nversio, 0) = NVL (w_nversio, 0)
            AND NVL (scumulo, 0) = NVL (w_scumulo, 0)
            AND NVL (nagrupa, 0) = NVL (w_nagrupa, 0)
            AND cgarant IS NOT NULL
            AND NVL (cgarant, 0) = NVL (w_cgarant, 0)
            AND cestado = 1
            AND sproces = psproces;

      --reaseguro x garantia
      CURSOR cur_aux_6
      IS
         SELECT   *
             FROM cesionesaux
            WHERE sproces = psproces AND cestado = 7    --reaseguro x garantia
         ORDER BY (icapaci - icapital), cgarant DESC;  -- 19484 AVT 02/01/2012

      --reaseguro x garantia
      CURSOR cur_trams (wscontra NUMBER, wnversio NUMBER, p_q3 NUMBER)
      IS
         --SELECT nplenos, DECODE(ctramo, 6, 0, ctramo) ctramo   -- 28492 AVT 28/10/2013
         SELECT nplenos,
                ctramo
             --BUG CONF-620  Fecha (01/03/2017) - HRE - Reaseguro moneda local
           FROM tramos
          WHERE scontra = wscontra
            AND nversio = wnversio
            AND (ctramo != 3 OR (ctramo = 3 AND p_q3 = 1));

      -- 21559 AVT 12/03/2012
      --4773
      CURSOR garantia_principal (
         p_cgarant   IN   NUMBER,
         p_sproces   IN   NUMBER,
         p_sseguro   IN   NUMBER,
         p_nmovimi   IN   NUMBER,
                  -- AVT 26/03/2012 per la migració sempre és el mateix procés
         p_motiu     IN   NUMBER
      )
      IS
         SELECT   *
             FROM cesionesrea c
            WHERE c.sproces = p_sproces
              AND c.sseguro = p_sseguro
              AND c.cgarant = p_cgarant
              AND nmovimi = p_nmovimi
              AND cgenera = p_motiu
         ORDER BY ctramo;                                    -- AVT 14/03/2012

      -- BUG 32363 - DCT - 28/07/2014
      -- 22686 AVT 25/07/2012
      -- BUG 32363 - DCT - 25/07/2014
      CURSOR riesgos_anul (p_cumul IN NUMBER)
      IS
         SELECT DISTINCT s.sseguro, s.fanulac
                    FROM reariesgos r, seguros s, cesionesrea c
                   WHERE r.scumulo = p_cumul
                     AND r.scumulo = c.scumulo
                     AND r.sseguro = c.sseguro
                     AND r.sseguro = s.sseguro
                     AND s.fanulac IS NOT NULL
                     AND freafin IS NULL;
-- *********************************************************************
   BEGIN
      -- PART 1:
      -- ******
      --INI BUG CONF-620  Fecha (01/03/2017) - HRE - Reaseguro moneda local
      p_traza_proceso (24,
                       'TRAZA_CESIONES_REA',
                       777,
                       'PAC_CESIONES',
                       'F_CESIO',
                       NULL,
                       2,
                       'Error: paso 0 '
                      );
      w_pfdatagen := pfdatagen;
      v_cgesfac := pcgesfac;

      --INI - IAXIS 2437: AABG SE CONSULTA EL TIPO DE MONEDA DEL CONTRATO
      BEGIN
         SELECT cmoneda
           INTO w_moninst
           FROM codicontratos
          WHERE scontra = (SELECT   scontra
                               FROM cesionesaux
                              WHERE sproces = psproces
                           GROUP BY scontra);
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            SELECT cmonint
              INTO w_moninst
              FROM monedas
             WHERE cidioma = pac_md_common.f_get_cxtidioma
               AND cmoneda = pac_parametros.f_parinstalacion_n ('MONEDAINST');
      END;

      --FIN - IAXIS 2437: AABG SE CONSULTA EL TIPO DE MONEDA DEL CONTRATO
      SELECT cmonint
        INTO w_monpol
        FROM monedas
       WHERE cidioma = pac_md_common.f_get_cxtidioma AND cmoneda = pmoneda;

      --FIN BUG CONF-620  - Fecha (01/03/2017) - HRE
      p_traza_proceso (24,
                       'TRAZA_CESIONES_REA',
                       777,
                       'PAC_CESIONES',
                       'F_CESIO',
                       NULL,
                       2,
                       'Error: paso 1 '
                      );
      -- AQUI ES PRORRATEJEN LES PRIMES ANUALS DE LES GARANTIES EN FUNCIÓ DE
      -- LES DATES INICIAL I FINAL D'ASSIGNACIÓ A UN CONTRACTE...
      -- TAMBÉ S'ADEQÜEN LES PRIMES DELS CONTRACTES SI EXISTEIX UN % DE REDUCCIÓ
      -- A NIVELL DE CONTRACTE (PCEDIDO)...
      -- TAMBÉ S'OMPLE EL CAMP NAGRUPA SEGONS CVIDAGA DE CODICONTRATOS (NO VIDA O
      -- GARANTIA A GARANTIA)
      w_nagrupa := 0;
      --w_nagrupavi := 0; 13195 AVT 16-02-2010
      w_porcgarant := 0;
      w_switchgarant := 0;
      w_registre := 0;

      --AGG 10/04/2014
      --p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 1, 'Inicio de proceso: ' || psproces || ' Motivo: ' || pmotiu ||
      --' Moneda: ' || pmoneda || ' Fecha: ' || pfdatagen || ' cgesfac: ' || pcgesfac || ' ptablas: ' || ptablas);

      ----dbms_outpuT.put_line('-- DINS DE F_CESSIO ----');
      FOR regaux1 IN cur_aux_1
      LOOP
         p_traza_proceso (24,
                          'TRAZA_CESIONES_REA',
                          777,
                          'PAC_CESIONES',
                          'F_CESSIO',
                          NULL,
                          2,
                             'Error: paso -1,
     regaux1.sseguro:'
                          || regaux1.sseguro
                          || ' regaux1.icapital:'
                          || regaux1.icapital
                          || ' regaux1.cestado:'
                          || regaux1.cestado
                          || ' regaux1.cgarant:'
                          || regaux1.cgarant
                          || ' regaux1.scontra:'
                          || regaux1.scontra
                         );
         ----dbms_outpuT.put_line('IPRIREA    '||regaux1.IPRIREA        );
         ----dbms_outpuT.put_line('ICAPITAL   '||regaux1.ICAPITAL       );
         ----dbms_outpuT.put_line('IPRITARREA '||regaux1.IPRITARREA);
         ----dbms_outpuT.put_line('IDTOSEL    '||regaux1.IDTOSEL        );
         w_fconini := regaux1.fconini;

         IF ptablas = 'EST'
         THEN
            BEGIN                   -- Busquem si prima prorratejable o no...
               SELECT cempres, cduraci, fefecto, fvencim, sproduc,
                      cramo, cmodali, ctipseg, ccolect, cactivi,
                      ctiprea, sproduc
                 INTO w_cempres, w_cduraci, w_fefecto, w_fvencim, w_sproduc,
                      w_cramo, w_cmodali, w_ctipseg, w_ccolect, w_cactivi,
                      w_ctiprea, w_sproduc
                 FROM estseguros
                WHERE sseguro = regaux1.sseguro;
            EXCEPTION
               WHEN OTHERS
               THEN
                  perr := 101919;
                  p_traza_proceso (w_cempres,
                                   vpar_traza,
                                   psproces,
                                   v_nom_paquete,
                                   v_nom_funcion,
                                   NULL,
                                   2,
                                   'Error: ' || perr
                                  );
                  RETURN (perr);
            END;
         ELSIF ptablas = 'CAR'
         THEN
            BEGIN                   -- Busquem si prima prorratejable o no...
               SELECT cempres, cduraci, fefecto, fvencim, sproduc,
                      cramo, cmodali, ctipseg, ccolect, cactivi,
                      ctiprea, sproduc
                 INTO w_cempres, w_cduraci, w_fefecto, w_fvencim, w_sproduc,
                      w_cramo, w_cmodali, w_ctipseg, w_ccolect, w_cactivi,
                      w_ctiprea, w_sproduc
                 FROM seguros
                WHERE sseguro = regaux1.sseguro;
            EXCEPTION
               WHEN OTHERS
               THEN
                  perr := 101919;
                  p_traza_proceso (w_cempres,
                                   vpar_traza,
                                   psproces,
                                   v_nom_paquete,
                                   v_nom_funcion,
                                   NULL,
                                   3,
                                   'Error: ' || perr
                                  );
                  RETURN (perr);
            END;
         ELSE
            BEGIN                   -- Busquem si prima prorratejable o no...
               SELECT cempres, cduraci, fefecto, fvencim, sproduc,
                      cramo, cmodali, ctipseg, ccolect, cactivi,
                      ctiprea, sproduc
                 INTO w_cempres, w_cduraci, w_fefecto, w_fvencim, w_sproduc,
                      w_cramo, w_cmodali, w_ctipseg, w_ccolect, w_cactivi,
                      w_ctiprea, w_sproduc
                 FROM seguros
                WHERE sseguro = regaux1.sseguro;
            EXCEPTION
               WHEN OTHERS
               THEN
                  perr := 101919;
                  p_traza_proceso (w_cempres,
                                   vpar_traza,
                                   psproces,
                                   v_nom_paquete,
                                   v_nom_funcion,
                                   NULL,
                                   4,
                                   'Error: ' || perr
                                  );
                  RETURN (perr);
            END;
         END IF;

         w_ctipre_seg := w_ctiprea;
-- 22660 AVT 13/08/2012 es mante aquesta inicialització tot i que no és ? ctiprea de seguros de contratos ¿?....
         p_traza_proceso (w_cempres,
                          vpar_traza,
                          psproces,
                          v_nom_paquete,
                          v_nom_funcion,
                          NULL,
                          5,
                          'ctiprea: ' || w_ctiprea
                         );

         -- 21559 27/03/2012 AVT
         --BUG 21559 - INICIO - 23/05/2013 - DCT
         IF NVL (pac_parametros.f_parproducto_n (w_sproduc,
                                                 'GAR_PRINCIPAL_REA'
                                                ),
                 0
                ) = 1
         THEN
            --BUG 21559 - FIN - 23/05/2013 - DCT
            w_registre := w_registre + 1;

            --w_capital_principal := regaux1.icapital;   --bug: 22666 -- 24794 AVT 17/11/2012 (23/11/2012)
            IF w_registre = 1
            THEN
               w_capital_principal := regaux1.icapital;
                                         -- 24794 AVT 17/11/2012 (23/11/2012)
               w_gar_princ := regaux1.cgarant;
            END IF;
         END IF;

         -- 21559 AVT 09/03/2012 només reaprtim segons garantia principal --
         --BUG 21559 - INICIO - 23/05/2013 - DCT
         IF    (    NVL (pac_parametros.f_parproducto_n (w_sproduc,
                                                         'GAR_PRINCIPAL_REA'
                                                        ),
                         0
                        ) = 1
                AND w_gar_princ = regaux1.cgarant
               )                                             -- 21559 / 111590
            OR NVL (pac_parametros.f_parproducto_n (w_sproduc,
                                                    'GAR_PRINCIPAL_REA'
                                                   ),
                    0
                   ) = 0
         THEN
            BEGIN               -- Busquem si hi ha % de reducció de prima...
               SELECT pcedido            --, icapaci   -- 13195 AVT 16-02-2010
                 INTO w_pcedido                                  --, w_icapaci
                 FROM contratos
                WHERE scontra = regaux1.scontra AND nversio = regaux1.nversio;
            ----dbms_outpuT.put_line(' reducció de prima ');
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  w_pcedido := NULL;
                  p_traza_proceso (w_cempres,
                                   vpar_traza,
                                   psproces,
                                   v_nom_paquete,
                                   v_nom_funcion,
                                   NULL,
                                   6,
                                      'NO DATA FOUND scontra: '
                                   || regaux1.scontra
                                   || ' nversio: '
                                   || regaux1.nversio
                                  );
               WHEN OTHERS
               THEN
                  perr := 104704;
                  p_traza_proceso (w_cempres,
                                   vpar_traza,
                                   psproces,
                                   v_nom_paquete,
                                   v_nom_funcion,
                                   NULL,
                                   7,
                                   'Error: ' || perr
                                  );
                  RETURN (perr);
            END;

            p_traza_proceso (w_cempres,
                             vpar_traza,
                             psproces,
                             v_nom_paquete,
                             v_nom_funcion,
                             NULL,
                             8,
                             'pcedido: ' || w_pcedido
                            );

            ----dbms_outpuT.put_line(' pcedido '||w_pcedido);
            IF w_pcedido IS NOT NULL
            THEN
               w_iprirea := (regaux1.iprirea * w_pcedido) / 100;
               w_ipritarrea := (regaux1.ipritarrea * w_pcedido) / 100;
               w_idtosel := (regaux1.idtosel * w_pcedido) / 100;
            ELSE
               w_iprirea := regaux1.iprirea;
               w_ipritarrea := regaux1.ipritarrea;
               w_idtosel := regaux1.idtosel;
            END IF;

----dbms_outpuT.put_line(' scontra '||regaux1.scontra);
--------------
-- AQUI ES BUSQUEN EL SPLENO,CCALIF1,CCALIF2 I IPLENO EN FUNCIÓ DEL
-- CONTRACTE/VERSIÓ ASSIGNAT...
-------------
            w_spleno := NULL;
            w_ccalif1 := NULL;
            w_ccalif2 := NULL;
            w_cgar := NULL;                            -- 13195 AVT 16-02-2010

            -- Posem aquí la par dos pq es el mateix cursor
            ----dbms_outpuT.put_line(' a f_cessio IF regaux1.cfacult '||regaux1.cfacult);
            IF regaux1.cfacult <> 1
            THEN
               -- No es un facultatiu forçat...(si forçat No busquem res )
               BEGIN
                  -- SELECT a.cgarant, cvidaga, spleno, ctiprea -- 13195 AVT 21-05-2010
                  --  INTO w_cgar, w_cvidaga, w_spleno, w_ctiprea
                  SELECT cvidaga, spleno, ctiprea
                    INTO w_cvidaga, w_spleno, w_ctiprea
                    FROM codicontratos
                                -- c, agr_contratos a  -- 13195 AVT 21-05-2010
                   WHERE scontra = regaux1.scontra;
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     perr := 104697;
                     p_traza_proceso (w_cempres,
                                      vpar_traza,
                                      psproces,
                                      v_nom_paquete,
                                      v_nom_funcion,
                                      NULL,
                                      9,
                                      'Error: ' || perr
                                     );
                     RETURN (perr);
                  WHEN OTHERS
                  THEN
                     perr := 104516;
                     p_traza_proceso (w_cempres,
                                      vpar_traza,
                                      psproces,
                                      v_nom_paquete,
                                      v_nom_funcion,
                                      NULL,
                                      10,
                                      'Error: ' || perr
                                     );
                     RETURN (perr);
               END;

               -- 13195 AVT 16-02-2010 Aquí es mira si cessions garantia a garantia (vida)...
               IF w_cvidaga = 2
               THEN
                  -- w_nagrupavi := w_nagrupavi + 1; AVT 16-02-2010
                  -- w_nagrupa := w_nagrupavi; AVT 16-02-2010
                  w_nagrupa := w_nagrupa + 1;
               ELSE
                  w_nagrupa := 0;
               END IF;

               /*******************************************************************
               F_BUSCACALIFI : Devuelve el ipleno y la calificacion de un riesgo
               segun el seguro y el spleno (w_spleno de CODICONTRATOS)
               ********************************************************************/
               IF w_spleno IS NOT NULL
               THEN
                  codi_error :=
                     f_buscacalifi (regaux1.sseguro,
                                    w_spleno,
                                    w_ccalif1,
                                    w_ccalif2,
                                    w_ipleno
                                   );

                  IF codi_error <> 0
                  THEN
                     perr := codi_error;
                     RETURN (perr);
                  END IF;
               ELSE
                  w_ccalif1 := NULL;
                  w_ccalif2 := NULL;

                  /***************************
                  w_ctiprea = 1 - Quota PART
                  ***************************/
                  ----dbms_outpuT.put_line('a f_cessio  tot tra '||w_ctiprea);
                  IF w_ctiprea = 1
                  THEN
                     w_ipleno := 0;               -- bug 19484 AVT 24/11/2011
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
                  END;*/
                  /*********************************
                  w_ctiprea = 2 - Ple NET RETENCIO
                  **********************************/
                  ELSIF w_ctiprea = 2
                  THEN
                     BEGIN
                        ----dbms_outpuT.put_line(' SELECT DEL PLE ');
                        SELECT iretenc
                          INTO w_ipleno
                          FROM contratos
                         WHERE scontra = regaux1.scontra
                           AND nversio = regaux1.nversio;

                        ----dbms_outpuT.put_line('           IRETENC  = '||w_ipleno);
                        p_traza_proceso (w_cempres,
                                         vpar_traza,
                                         psproces,
                                         v_nom_paquete,
                                         v_nom_funcion,
                                         NULL,
                                         11,
                                         'ipleno: ' || w_ipleno
                                        );
                     EXCEPTION
                        WHEN NO_DATA_FOUND
                        THEN
                           perr := 104332;
                           p_traza_proceso (w_cempres,
                                            vpar_traza,
                                            psproces,
                                            v_nom_paquete,
                                            v_nom_funcion,
                                            NULL,
                                            12,
                                            'Error: ' || perr
                                           );
                           RETURN (perr);
                        WHEN OTHERS
                        THEN
                           perr := 104704;
                           p_traza_proceso (w_cempres,
                                            vpar_traza,
                                            psproces,
                                            v_nom_paquete,
                                            v_nom_funcion,
                                            NULL,
                                            13,
                                            'Error: ' || perr
                                           );
                           RETURN (perr);
                     END;
                  -- 28492 AVT 28/10/2013
                  /*********************************
                  w_ctiprea = 3 - COBERT PER XL
                  **********************************/
                  ELSIF w_ctiprea = 3
                  THEN
                     --28492 AVT 13/11/2013 LA SELECT NO SERVEIX SI UN CONTRACTE COBREIS DOS O MÉS PRODUCTES.
                     perr :=
                        f_buscacontrato (regaux1.sseguro,
                                         regaux1.fconini,
                                         w_cempres,
                                         regaux1.cgarant,
                                         w_cramo,
                                         w_cmodali,
                                         w_ctipseg,
                                         w_ccolect,
                                         w_cactivi,
                                         11,
                                         w_scontra,
                                         w_nversio,
                                         w_ipleno,
                                         w_icapaci,
                                         w_cdetces
                                        );                -- revisar evento!!!

                     IF perr <> 0
                     THEN
                        RETURN (perr);
                     END IF;
                  --                     BEGIN
                  --                     -- 28777 AVT 13-11-13
                  ----                        SELECT icapaci
                  ----                          INTO w_ipleno
                  ----                          FROM contratos
                  ----                         WHERE scontra = regaux1.scontra
                  ----                           AND nversio = regaux1.nversio;
                  --                        SELECT NVL(a.ilimsub, icapaci)
                  --                          INTO w_ipleno
                  --                          FROM contratos c, agr_contratos a
                  --                         WHERE c.scontra = a.scontra
                  --                           AND c.scontra = regaux1.scontra
                  --                           AND c.nversio = regaux1.nversio;
                  --                     EXCEPTION
                  --                        WHEN NO_DATA_FOUND THEN
                  --                           perr := 104332;
                  --                           RETURN(perr);
                  --                        WHEN OTHERS THEN
                  --                           perr := 104704;
                  --                           RETURN(perr);
                  --                     END;
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
               BEGIN
                  SELECT icapaci
                    INTO w_icapacigarant
                    FROM capgarant
                   WHERE scontra = regaux1.scontra
                     AND nversio = regaux1.nversio
                     AND cgarant = regaux1.cgarant;
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     w_icapacigarant := NULL;
                  WHEN OTHERS
                  THEN
                     perr := 105756;
                     p_traza_proceso (w_cempres,
                                      vpar_traza,
                                      psproces,
                                      v_nom_paquete,
                                      v_nom_funcion,
                                      NULL,
                                      15,
                                      'Error: ' || perr
                                     );
                     RETURN (perr);
               END;

               IF     w_icapacigarant IS NOT NULL
                  AND regaux1.icapital >
                         (  w_icapacigarant
                          / pac_eco_tipocambio.f_cambio (w_monpol,
                                                         w_moninst,
                                                         pfdatagen
                                                        )
                         )
             --BUG CONF-620  Fecha (01/03/2017) - HRE - Reaseguro moneda local
               THEN
                  w_switchgarant := 1;
                  w_porcaux :=
                       (  100
                        * (  regaux1.icapital
                           - (  w_icapacigarant
                              / pac_eco_tipocambio.f_cambio (w_monpol,
                                                             w_moninst,
                                                             pfdatagen
                                                            )
                             )
                          )
                       )
                     / regaux1.icapital;
             --BUG CONF-620  Fecha (01/03/2017) - HRE - Reaseguro moneda local

                  IF w_porcaux > w_porcgarant
                  THEN                                   -- Es selecciona el %
                     w_porcgarant := w_porcaux;                -- més gran...
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
                      nagrupa = DECODE (nagrupa, NULL, w_nagrupa, nagrupa),
                      spleno = NVL (w_spleno, spleno),
                      ccalif1 = NVL (w_ccalif1, ccalif1),
                      ccalif2 = NVL (w_ccalif2, ccalif2),
                      ipleno = NVL (ipleno, w_ipleno)
                -- Pot ser que ja estigui calculat de SGT
               WHERE  nnumlin = regaux1.nnumlin AND sproces = psproces;
            --       post;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  perr := 104695;
                  p_traza_proceso (w_cempres,
                                   vpar_traza,
                                   psproces,
                                   v_nom_paquete,
                                   v_nom_funcion,
                                   NULL,
                                   16,
                                   'Error: ' || perr
                                  );
                  RETURN (perr);
               WHEN OTHERS
               THEN
                  perr := 104696;
                  p_traza_proceso (w_cempres,
                                   vpar_traza,
                                   psproces,
                                   v_nom_paquete,
                                   v_nom_funcion,
                                   NULL,
                                   17,
                                   'Error: ' || perr
                                  );
                  RETURN (perr);
            END;
         END IF;                                                   -- 21559 fi
      END LOOP;

         ------------------------------------------------------------------------
         -- PART 3:
         -- ******
------------------------------------------------------------------------
-- AQUI SE FUSIONAN LOS REGISTROS DE "CESIONESAUX" EN FUNCIÓN DE LA IGUALDAD
-- DE RIESGO, SPLENO, CCALIF1, CCALIF2, SCONTRA, NVERSIO, SCUMULO, NAGRUPA ...
-- UTILIZAREMOS EL CAMPO CESTADO PARA DISTINGUIR LOS REGISTROS NO fusionados
-- (Cestado = 0) LOS fusionados (cestado = 1) ...
      FOR regaux2 IN cur_aux_2
      LOOP
         p_traza_proceso (24,
                          'TRAZA_CESIONES_REA',
                          777,
                          'PAC_CESIONES',
                          'F_CESSIO',
                          NULL,
                          2,
                             'Error: paso 0,
     regaux2.sseguro:'
                          || regaux2.sseguro
                          || ' regaux2.icapital:'
                          || regaux2.icapital
                          || ' regaux2.cestado:'
                          || regaux2.cestado
                          || ' regaux2.cgarant:'
                          || regaux2.cgarant
                          || ' regaux2.scontra:'
                          || regaux2.scontra
                         );

         INSERT INTO cesionesaux
                     (sproces, nnumlin, sseguro,
                      iprirea, icapital, cestado, cfacult,
                      nriesgo, nmovimi, cgarant,
                      scontra, fconini, fconfin,
                      nversio, scumulo, nagrupa,
                      icapit2, iextrap, precarg,
                      cdetces, icapaci, ipleno,
                      iextrea, ipritarrea, idtosel,
                      psobreprima, itarifrea,
                      ccalif1, ccalif2, sfacult,
                      fanulac, fregula, icomext
                     )
              VALUES (regaux2.sproces, regaux2.nnumlin * -2, regaux2.sseguro,
                      regaux2.iprirea, regaux2.icapital, 7, regaux2.cfacult,
                      regaux2.nriesgo, regaux2.nmovimi, regaux2.cgarant,
                      regaux2.scontra, regaux2.fconini, regaux2.fconfin,
                      regaux2.nversio, regaux2.scumulo, regaux2.nagrupa,
                      regaux2.icapit2, regaux2.iextrap, regaux2.precarg,
                      regaux2.cdetces, regaux2.icapaci, regaux2.ipleno,
                      regaux2.iextrea, regaux2.ipritarrea, regaux2.idtosel,
                      regaux2.psobreprima, regaux2.itarifrea,
                      regaux2.ccalif1, regaux2.ccalif2, regaux2.sfacult,
                      regaux2.fanulac, regaux2.fregula, regaux2.icomext
                     );

         ---- 21559 AVT 09/03/2012  A les garanties no principals tb els hi actualitzem l'estat ............
         ---- 26142 KBR 04/03/2013  Cambiamos el estado 1 por 2 para que se salte el próximo paso
         --BUG 21559 - INICIO - 23/05/2013 - DCT
         IF ptablas = 'EST'
         THEN
            BEGIN
               SELECT sproduc
                 INTO w_sproduc
                 FROM estseguros
                WHERE sseguro = regaux2.sseguro;
            EXCEPTION
               WHEN OTHERS
               THEN
                  perr := 101919;
                  p_traza_proceso (w_cempres,
                                   vpar_traza,
                                   psproces,
                                   v_nom_paquete,
                                   v_nom_funcion,
                                   NULL,
                                   18,
                                   'Error: ' || perr
                                  );
                  RETURN (perr);
            END;
         ELSIF ptablas = 'CAR'
         THEN
            BEGIN
               SELECT sproduc
                 INTO w_sproduc
                 FROM seguros
                WHERE sseguro = regaux2.sseguro;
            EXCEPTION
               WHEN OTHERS
               THEN
                  perr := 101919;
                  p_traza_proceso (w_cempres,
                                   vpar_traza,
                                   psproces,
                                   v_nom_paquete,
                                   v_nom_funcion,
                                   NULL,
                                   19,
                                   'Error: ' || perr
                                  );
                  RETURN (perr);
            END;
         ELSE
            BEGIN                   -- Busquem si prima prorratejable o no...
               SELECT sproduc
                 INTO w_sproduc
                 FROM seguros
                WHERE sseguro = regaux2.sseguro;
            EXCEPTION
               WHEN OTHERS
               THEN
                  perr := 101919;
                  p_traza_proceso (w_cempres,
                                   vpar_traza,
                                   psproces,
                                   v_nom_paquete,
                                   v_nom_funcion,
                                   NULL,
                                   20,
                                   'Error: ' || perr
                                  );
                  RETURN (perr);
            END;
         END IF;

         IF     NVL (pac_parametros.f_parproducto_n (w_sproduc,
                                                     'GAR_PRINCIPAL_REA'
                                                    ),
                     0
                    ) = 1
            --BUG 21559 - FIN - 23/05/2013 - DCT
            AND w_gar_princ <> regaux2.cgarant
         THEN                                                -- 21559 / 111590
            UPDATE cesionesaux
               SET cestado = 2
             WHERE sproces = psproces AND cgarant = regaux2.cgarant;
         END IF;

         -- 21559 AVT 09/03/2012 només reaprtim segons garantia principal --
         --BUG 21559 - INICIO - 23/05/2013 - DCT
         IF    (    NVL (pac_parametros.f_parproducto_n (w_sproduc,
                                                         'GAR_PRINCIPAL_REA'
                                                        ),
                         0
                        ) = 1
                AND w_gar_princ = regaux2.cgarant
               )                                             -- 21559 / 111590
            OR NVL (pac_parametros.f_parproducto_n (w_sproduc,
                                                    'GAR_PRINCIPAL_REA'
                                                   ),
                    0
                   ) = 0
         THEN
            --BUG 21559 - FIN - 23/05/2013 - DCT
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

            IF regaux2.cfacult <> 1
            THEN
               -- bug: 14404 AVT 25-05-2010 una mateixa pòlissa pot tenir 2 ó més contractes de tipus diferent
               BEGIN
                  SELECT ctiprea
                    INTO w_ctiprea                     -- 13195 AVT 16-02-2010
                    FROM codicontratos
                   WHERE scontra = regaux2.scontra;
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     perr := 104697;
                     p_traza_proceso (w_cempres,
                                      vpar_traza,
                                      psproces,
                                      v_nom_paquete,
                                      v_nom_funcion,
                                      NULL,
                                      21,
                                      'Error: ' || perr
                                     );
                     RETURN (perr);
                  WHEN OTHERS
                  THEN
                     perr := 104516;
                     p_traza_proceso (w_cempres,
                                      vpar_traza,
                                      psproces,
                                      v_nom_paquete,
                                      v_nom_funcion,
                                      NULL,
                                      22,
                                      'Error: ' || perr
                                     );
                     RETURN (perr);
               END;
            END IF;

            FOR regaux3 IN cur_aux_3
            LOOP
               w_trobat := 1;

               BEGIN
                  w_iprirea := regaux3.iprirea + regaux2.iprirea;
                  w_ipritarrea := regaux3.ipritarrea + regaux2.ipritarrea;
                  w_idtosel := regaux3.idtosel + regaux2.idtosel;
                  p_traza_proceso
                     (24,
                      'TRAZA_CESIONES_REA',
                      777,
                      'PAC_CESIONES',
                      'F_CESSIO',
                      NULL,
                      2,
                         'Error: paso 1,
     regaux2.sseguro:'
                      || regaux2.sseguro
                      || ' regaux2.icapital:'
                      || regaux2.icapital
                      || ' regaux2.cestado:'
                      || regaux2.cestado
                      || ' regaux2.cgarant:'
                      || regaux2.cgarant
                      || ' regaux2.scontra:'
                      || regaux2.scontra
                      || 
                         --'regaux3.sseguro:'||regaux3.sseguro||
                         ' regaux3.icapital:'
                      || regaux3.icapital
                                      --||' regaux3.cestado:'||regaux3.cestado
                      || ' regaux3.cgarant:'
                      || regaux3.cgarant
                                      --||' regaux3.scontra:'||regaux3.scontra
                     );
                  p_traza_proceso (24,
                                   'TRAZA_CESIONES_REA',
                                   777,
                                   'PAC_CESIONES',
                                   'F_CESSIO',
                                   NULL,
                                   2,
                                      'Error: paso 1_1,regaux2.scumulo:'
                                   || regaux2.scumulo
                                  );

                  -- Aquí busquem capital per tot el cúmul...
                  IF regaux2.scumulo IS NOT NULL
                  THEN
                     cum_capital := regaux3.icapital + regaux2.icapital;
                     p_traza_proceso
                        (24,
                         'TRAZA_CESIONES_REA',
                         777,
                         'PAC_CESIONES',
                         'F_CESSIO',
                         NULL,
                         2,
                            'Error: paso 1_2,
                    cum_capital:'
                         || cum_capital
                        );
                     --INI BUG CONF-620  Fecha (01/03/2017) - HRE - Reaseguro moneda local
                     cum_capital :=
                        NVL (pac_eco_tipocambio.f_importe_cambio (w_monpol,
                                                                  w_moninst,
                                                                  pfdatagen,
                                                                  cum_capital
                                                                 ),
                             0
                            );
                     p_traza_proceso
                        (24,
                         'TRAZA_CESIONES_REA',
                         777,
                         'PAC_CESIONES',
                         'F_CESSIO',
                         NULL,
                         2,
                            'Error: paso 1_3,
                    cum_capital:'
                         || cum_capital
                        );
                     codi_error :=
                        pac_cesionesrea.f_capital_cumul_est_mon
                                                             (w_ctiprea,
                                                              regaux2.scumulo,
                                                              regaux2.fconini,
                                                              regaux3.cgarant,
                                                              w_moninst,
                                                              pfdatagen,
                                                              cum_capital,
                                                              ptablas
                                                             );
                     p_traza_proceso
                        (24,
                         'TRAZA_CESIONES_REA',
                         777,
                         'PAC_CESIONES',
                         'F_CESSIO',
                         NULL,
                         2,
                            'Error: paso 1_4,
                    cum_capital:'
                         || cum_capital
                        );

                     --FIN BUG CONF-620  - Fecha (01/03/2017) - HRE
                     --FI BUG 11100 - 16/09/2009 – FAL
                     IF codi_error <> 0
                     THEN
                        perr := codi_error;
                        RETURN (perr);
                     ELSE
                        w_icapital :=
                             cum_capital
                           / pac_eco_tipocambio.f_cambio (w_monpol,
                                                          w_moninst,
                                                          pfdatagen
                                                         );
             --BUG CONF-620  Fecha (01/03/2017) - HRE - Reaseguro moneda local
                        p_traza_proceso
                           (24,
                            'TRAZA_CESIONES_REA',
                            777,
                            'PAC_CESIONES',
                            'F_CESSIO',
                            NULL,
                            2,
                               'Error: paso 1_5,
                    cum_capital:'
                            || cum_capital
                            || ' w_icapital:'
                            || w_icapital
                           );
                     END IF;
                  ELSE
                     w_icapital := regaux3.icapital + regaux2.icapital;
                     p_traza_proceso
                        (24,
                         'TRAZA_CESIONES_REA',
                         777,
                         'PAC_CESIONES',
                         'F_CESSIO',
                         NULL,
                         2,
                            'Error: paso 1_6,
                    cum_capital:'
                         || cum_capital
                         || ' w_icapital:'
                         || w_icapital
                        );
                  END IF;

                  UPDATE cesionesaux
                     SET iprirea = w_iprirea,
                         ipritarrea = w_ipritarrea,
                         idtosel = w_idtosel,
                         icapital = w_icapital
                   WHERE NVL (nriesgo, 0) = NVL (regaux2.nriesgo, 0)
                     AND NVL (spleno, 0) = NVL (regaux2.spleno, 0)
                     AND NVL (ccalif1, ' ') = NVL (regaux2.ccalif1, ' ')
                     AND NVL (ccalif2, 0) = NVL (regaux2.ccalif2, 0)
                     AND NVL (scontra, 0) = NVL (regaux2.scontra, 0)
                     AND NVL (nversio, 0) = NVL (regaux2.nversio, 0)
                     AND NVL (scumulo, 0) = NVL (regaux2.scumulo, 0)
                     AND NVL (nagrupa, 0) = NVL (regaux2.nagrupa, 0)
                     AND cgarant IS NULL
                     AND cestado = 1
                     AND sproces = psproces;

                  --           post;
                  EXIT;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     perr := 104700;
                     p_traza_proceso (w_cempres,
                                      vpar_traza,
                                      psproces,
                                      v_nom_paquete,
                                      v_nom_funcion,
                                      NULL,
                                      23,
                                      'Error: ' || perr
                                     );
                     RETURN (perr);
               END;
            END LOOP;

            IF w_trobat = 0
            THEN
               FOR regaux4 IN cur_aux_4
               LOOP
                  w_trobat := 1;
                  p_traza_proceso
                     (24,
                      'TRAZA_CESIONES_REA',
                      777,
                      'PAC_CESIONES',
                      'F_CESSIO',
                      NULL,
                      2,
                         'Error: paso 2,
     regaux2.sseguro:'
                      || regaux2.sseguro
                      || ' regaux2.icapital:'
                      || regaux2.icapital
                      || ' regaux2.cestado:'
                      || regaux2.cestado
                      || ' regaux2.cgarant:'
                      || regaux2.cgarant
                      || ' regaux2.scontra:'
                      || regaux2.scontra
                      || 
                         --'regaux4.sseguro:'||regaux4.sseguro||
                         ' regaux4.icapital:'
                      || regaux4.icapital
                                      --||' regaux4.cestado:'||regaux4.cestado
                      || ' regaux4.cgarant:'
                      || regaux4.cgarant
                                      --||' regaux4.scontra:'||regaux4.scontra
                     );

                  BEGIN
                     w_iprirea := regaux4.iprirea + regaux2.iprirea;
                     w_ipritarrea := regaux4.ipritarrea + regaux2.ipritarrea;
                     w_idtosel := regaux4.idtosel + regaux2.idtosel;

                     -- Aquí busquem capital per tot el cúmul...
                     IF regaux2.scumulo IS NOT NULL
                     THEN
                        cum_capital := regaux4.icapital + regaux2.icapital;
                        --INI BUG CONF-620  Fecha (01/03/2017) - HRE - Reaseguro moneda local
                        cum_capital :=
                           NVL
                              (pac_eco_tipocambio.f_importe_cambio
                                                                  (w_monpol,
                                                                   w_moninst,
                                                                   pfdatagen,
                                                                   cum_capital
                                                                  ),
                               0
                              );
                        codi_error :=
                           pac_cesionesrea.f_capital_cumul_est_mon
                                                             (w_ctiprea,
                                                              regaux2.scumulo,
                                                              regaux2.fconini,
                                                              regaux4.cgarant,
                                                              w_moninst,
                                                              pfdatagen,
                                                              cum_capital,
                                                              ptablas
                                                             );

                        --FIN BUG CONF-620  - Fecha (01/03/2017) - HRE
                        --FI BUG 11100 - 16/09/2009 – FAL
                        IF codi_error <> 0
                        THEN
                           perr := codi_error;
                           RETURN (perr);
                        ELSE
                           w_icapital :=
                                cum_capital
                              / pac_eco_tipocambio.f_cambio (w_monpol,
                                                             w_moninst,
                                                             pfdatagen
                                                            );
             --BUG CONF-620  Fecha (01/03/2017) - HRE - Reaseguro moneda local
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
                      WHERE NVL (nriesgo, 0) = NVL (regaux2.nriesgo, 0)
                        AND NVL (spleno, 0) = NVL (regaux2.spleno, 0)
                        AND NVL (ccalif1, ' ') = NVL (regaux2.ccalif1, ' ')
                        AND NVL (ccalif2, 0) = NVL (regaux2.ccalif2, 0)
                        AND NVL (scontra, 0) = NVL (regaux2.scontra, 0)
                        AND NVL (nversio, 0) = NVL (regaux2.nversio, 0)
                        AND NVL (scumulo, 0) = NVL (regaux2.scumulo, 0)
                        AND NVL (nagrupa, 0) = NVL (regaux2.nagrupa, 0)
                        AND cgarant IS NOT NULL
                        AND NVL (cgarant, 0) <> NVL (regaux2.cgarant, 0)
                        AND cestado = 1
                        AND sproces = psproces;

                     --              post;
                     EXIT;
                  EXCEPTION
                     WHEN OTHERS
                     THEN
                        perr := 104701;
                        p_traza_proceso (w_cempres,
                                         vpar_traza,
                                         psproces,
                                         v_nom_paquete,
                                         v_nom_funcion,
                                         NULL,
                                         24,
                                         'Error: ' || perr
                                        );
                        RETURN (perr);
                  END;
               END LOOP;
            END IF;

            IF w_trobat = 0
            THEN
               FOR regaux5 IN cur_aux_5
               LOOP
                  w_trobat := 1;
                  p_traza_proceso
                     (24,
                      'TRAZA_CESIONES_REA',
                      777,
                      'PAC_CESIONES',
                      'F_CESSIO',
                      NULL,
                      2,
                         'Error: paso 3,
     regaux2.sseguro:'
                      || regaux2.sseguro
                      || ' regaux2.icapital:'
                      || regaux2.icapital
                      || ' regaux2.cestado:'
                      || regaux2.cestado
                      || ' regaux2.cgarant:'
                      || regaux2.cgarant
                      || ' regaux2.scontra:'
                      || regaux2.scontra
                      || 
                         --'regaux5.sseguro:'||regaux5.sseguro||
                         ' regaux5.icapital:'
                      || regaux5.icapital
                                      --||' regaux5.cestado:'||regaux5.cestado
                      || ' regaux5.cgarant:'
                      || regaux5.cgarant
                                      --||' regaux5.scontra:'||regaux5.scontra
                     );

                  BEGIN
                     w_iprirea := regaux5.iprirea + regaux2.iprirea;
                     w_ipritarrea := regaux5.ipritarrea + regaux2.ipritarrea;
                     w_idtosel := regaux5.idtosel + regaux2.idtosel;

                     -- Aquí busquem capital per tot el cúmul...
                     IF regaux2.scumulo IS NOT NULL
                     THEN
                        cum_capital := regaux5.icapital + regaux2.icapital;
                        --INI BUG CONF-620  Fecha (01/03/2017) - HRE - Reaseguro moneda local
                        cum_capital :=
                           NVL
                              (pac_eco_tipocambio.f_importe_cambio
                                                                  (w_monpol,
                                                                   w_moninst,
                                                                   pfdatagen,
                                                                   cum_capital
                                                                  ),
                               0
                              );
                        codi_error :=
                           pac_cesionesrea.f_capital_cumul_est_mon
                                                             (w_ctiprea,
                                                              regaux2.scumulo,
                                                              regaux2.fconini,
                                                              regaux5.cgarant,
                                                              w_moninst,
                                                              pfdatagen,
                                                              cum_capital,
                                                              ptablas
                                                             );

                        --FIN BUG CONF-620  - Fecha (01/03/2017) - HRE
                        --FI BUG 11100 - 16/09/2009 – FAL
                        IF codi_error <> 0
                        THEN
                           perr := codi_error;
                           p_traza_proceso (w_cempres,
                                            vpar_traza,
                                            psproces,
                                            v_nom_paquete,
                                            v_nom_funcion,
                                            NULL,
                                            25,
                                            'Error: ' || perr
                                           );
                           RETURN (perr);
                        ELSE
                           w_icapital :=
                                cum_capital
                              / pac_eco_tipocambio.f_cambio (w_monpol,
                                                             w_moninst,
                                                             pfdatagen
                                                            );
             --BUG CONF-620  Fecha (01/03/2017) - HRE - Reaseguro moneda local
                        END IF;
                     ELSE
                        w_icapital := regaux5.icapital + regaux2.icapital;
                     END IF;

                     p_traza_proceso (w_cempres,
                                      vpar_traza,
                                      psproces,
                                      v_nom_paquete,
                                      v_nom_funcion,
                                      NULL,
                                      26,
                                         'iprirea: '
                                      || w_iprirea
                                      || ' ipritarrea: '
                                      || w_ipritarrea
                                      || ' idtosel: '
                                      || w_idtosel
                                      || ' icapital: '
                                      || w_icapital
                                     );

                     UPDATE cesionesaux
                        SET iprirea = w_iprirea,
                            ipritarrea = w_ipritarrea,
                            idtosel = w_idtosel,
                            icapital = w_icapital
                      WHERE NVL (nriesgo, 0) = NVL (regaux2.nriesgo, 0)
                        AND NVL (spleno, 0) = NVL (regaux2.spleno, 0)
                        AND NVL (ccalif1, ' ') = NVL (regaux2.ccalif1, ' ')
                        AND NVL (ccalif2, 0) = NVL (regaux2.ccalif2, 0)
                        AND NVL (scontra, 0) = NVL (regaux2.scontra, 0)
                        AND NVL (nversio, 0) = NVL (regaux2.nversio, 0)
                        AND NVL (scumulo, 0) = NVL (regaux2.scumulo, 0)
                        AND NVL (nagrupa, 0) = NVL (regaux2.nagrupa, 0)
                        AND cgarant IS NOT NULL
                        AND NVL (cgarant, 0) = NVL (regaux2.cgarant, 0)
                        AND cestado = 1
                        AND sproces = psproces;

                     --              post;
                     EXIT;
                  EXCEPTION
                     WHEN OTHERS
                     THEN
                        perr := 104701;
                        p_traza_proceso (w_cempres,
                                         vpar_traza,
                                         psproces,
                                         v_nom_paquete,
                                         v_nom_funcion,
                                         NULL,
                                         27,
                                         'Error: ' || perr
                                        );
                        RETURN (perr);
                  END;
               END LOOP;
            END IF;

            IF w_trobat = 0
            THEN
               BEGIN
                  w_cgar := NULL;
--RAL BUG 0035314: FACTURABLE - Reaseguro - Incidencia por movimientos Reaseguro poliza 7000280  22/06/2015

                  -- 26283 KBR 14/03/2013 Incidencia al momento de hacer cúmulo para colectivos de Liberty
                  IF    w_cvidaga = 2
                     OR w_nagrupa <> 0
                     OR NVL
                           (pac_parametros.f_parproducto_n
                                                          (w_sproduc,
                                                           'GAR_PRINCIPAL_REA'
                                                          ),
                            0
                           ) = 1
                  THEN                                        --KBR 04/12/2013
                     w_cgar := regaux2.cgarant;
                     w_icapital := regaux2.icapital;
                  ELSE
                     -- Aquí busquem capital per tot el cúmul...
                     IF regaux2.scumulo IS NOT NULL
                     THEN
                        cum_capital := regaux2.icapital;
                        --INI BUG CONF-620  Fecha (01/03/2017) - HRE - Reaseguro moneda local
                        cum_capital :=
                           NVL
                              (pac_eco_tipocambio.f_importe_cambio
                                                                  (w_monpol,
                                                                   w_moninst,
                                                                   pfdatagen,
                                                                   cum_capital
                                                                  ),
                               0
                              );
                        codi_error :=
                           pac_cesionesrea.f_capital_cumul_mon
                                                             (w_ctiprea,
                                                              regaux2.scumulo,
                                                              regaux2.fconini,
                                                              regaux2.cgarant,
                                                              w_moninst,
                                                              pfdatagen,
                                                              cum_capital
                                                             );

                        --FIN BUG CONF-620  - Fecha (01/03/2017) - HRE
                        IF codi_error <> 0
                        THEN
                           perr := codi_error;
                           RETURN (perr);
                        ELSE
                           w_icapital :=
                                cum_capital
                              / pac_eco_tipocambio.f_cambio (w_monpol,
                                                             w_moninst,
                                                             pfdatagen
                                                            );
             --BUG CONF-620  Fecha (01/03/2017) - HRE - Reaseguro moneda local
                        END IF;
                     ELSE
                        w_icapital := regaux2.icapital;
                     END IF;
                  END IF;

                  p_traza_proceso (w_cempres,
                                   vpar_traza,
                                   psproces,
                                   v_nom_paquete,
                                   v_nom_funcion,
                                   NULL,
                                   28,
                                   'capital: ' || w_icapital
                                  );

                  -- FIN 26283 KBR 14/03/2013
                  INSERT INTO cesionesaux
                              (sproces, nnumlin,
                               sseguro, iprirea, icapital,
                               cfacult, cestado, nriesgo,
                               nmovimi, ccalif1,
                               ccalif2, spleno, cgarant,
                               scontra, nversio,
                               fconini, fconfin,
                               ipleno, icapaci,
                               scumulo, sfacult,
                               nagrupa, iextrap,
                               precarg, ipritarrea,
                               idtosel, psobreprima,
                               cdetces, fanulac,
                               fregula, iextrea,
                               -- 47.0 - 29/11/2013 - MMM - 0028082 LCOL_A004-0008810 CLF2-4054 LISTADOS DE PRIMAS CEDIDAS VIDA PROPORCIONAL - Inicio
                               itarifrea
                              )
                       -- 47.0 - 29/11/2013 - MMM - 0028082 LCOL_A004-0008810 CLF2-4054 LISTADOS DE PRIMAS CEDIDAS VIDA PROPORCIONAL - Fin
                  VALUES      (regaux2.sproces, (regaux2.nnumlin * -1),
                               regaux2.sseguro, regaux2.iprirea, w_icapital,
                                     -- 21559 AVT 13/03/2012 regaux2.icapital,
                               -- w_icapital  BUG:14400 03-04-2010 AVT
                               regaux2.cfacult, 1, regaux2.nriesgo,
                               regaux2.nmovimi, regaux2.ccalif1,
                               regaux2.ccalif2, regaux2.spleno, w_cgar,
                               regaux2.scontra, regaux2.nversio,
                               regaux2.fconini, regaux2.fconfin,
                               regaux2.ipleno, regaux2.icapaci,
                               regaux2.scumulo, regaux2.sfacult,
                               regaux2.nagrupa, regaux2.iextrap,
                               regaux2.precarg, regaux2.ipritarrea,
                               regaux2.idtosel, regaux2.psobreprima,
                               regaux2.cdetces, regaux2.fanulac,
                               regaux2.fregula, regaux2.iextrea,
                               -- 47.0 - 29/11/2013 - MMM - 0028082 LCOL_A004-0008810 CLF2-4054 LISTADOS DE PRIMAS CEDIDAS VIDA PROPORCIONAL - Inicio
                               regaux2.itarifrea
                              );
               -- 47.0 - 29/11/2013 - MMM - 0028082 LCOL_A004-0008810 CLF2-4054 LISTADOS DE PRIMAS CEDIDAS VIDA PROPORCIONAL - Fin
               --             post;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     ----dbms_outpuT.put_line(SQLERRM);
                     p_traza_proceso (w_cempres,
                                      vpar_traza,
                                      psproces,
                                      v_nom_paquete,
                                      v_nom_funcion,
                                      NULL,
                                      29,
                                      'Error: ' || perr
                                     );
                     perr := 104702;
                     RETURN (perr);
               END;
            END IF;
         END IF;                         -- 21559 AVT 09/03/2012 fi ----------
      END LOOP;

      p_traza_proceso (24,
                       'TRAZA_CESIONES_REA',
                       777,
                       'PAC_CESIONES',
                       'F_CESIO',
                       NULL,
                       2,
                       'Error: paso 2 '
                      );

------------------------------------------------------------------------
-- PART 4:
-- ******
-- AQUI S'ESBORREN ELS REGISTRES DE "CESIONESAUX" AMB CESTADO A 0 PERQUÈ
-- JA S'HAN FUSIONAT...
      BEGIN
         -->P_Borrar_Jgr (88); --> BORRAR JGR
         DELETE FROM cesionesaux
               WHERE cestado = 0 AND sproces = psproces;
      --   post;
      EXCEPTION
         WHEN OTHERS
         THEN
            perr := 104703;
            p_traza_proceso (w_cempres,
                             vpar_traza,
                             psproces,
                             v_nom_paquete,
                             v_nom_funcion,
                             NULL,
                             30,
                             'Error: ' || perr
                            );
            RETURN (perr);
      END;

------------------------------------------------------------------------
-- PART 5:
-- ******
-- AQUI ES BUSCA EL ICAPACI EN FUNCIO DELS PLENS...
      FOR regaux1 IN cur_aux_1
      LOOP
         IF regaux1.cfacult = 1
         THEN                                   -- Es un facultatiu forçat...
            EXIT;
         END IF;

         --BUG 21559 - INICIO - 23/05/2013 - DCT
         IF ptablas = 'EST'
         THEN
            BEGIN
               SELECT sproduc
                 INTO w_sproduc
                 FROM estseguros
                WHERE sseguro = regaux1.sseguro;
            EXCEPTION
               WHEN OTHERS
               THEN
                  perr := 101919;
                  p_traza_proceso (w_cempres,
                                   vpar_traza,
                                   psproces,
                                   v_nom_paquete,
                                   v_nom_funcion,
                                   NULL,
                                   31,
                                   'Error: ' || perr
                                  );
                  RETURN (perr);
            END;
         ELSIF ptablas = 'CAR'
         THEN
            BEGIN
               SELECT sproduc
                 INTO w_sproduc
                 FROM seguros
                WHERE sseguro = regaux1.sseguro;
            EXCEPTION
               WHEN OTHERS
               THEN
                  perr := 101919;
                  p_traza_proceso (w_cempres,
                                   vpar_traza,
                                   psproces,
                                   v_nom_paquete,
                                   v_nom_funcion,
                                   NULL,
                                   32,
                                   'Error: ' || perr
                                  );
                  RETURN (perr);
            END;
         ELSE
            BEGIN                   -- Busquem si prima prorratejable o no...
               SELECT sproduc
                 INTO w_sproduc
                 FROM seguros
                WHERE sseguro = regaux1.sseguro;
            EXCEPTION
               WHEN OTHERS
               THEN
                  perr := 101919;
                  p_traza_proceso (w_cempres,
                                   vpar_traza,
                                   psproces,
                                   v_nom_paquete,
                                   v_nom_funcion,
                                   NULL,
                                   33,
                                   'Error: ' || perr
                                  );
                  RETURN (perr);
            END;
         END IF;

         -- 21559 AVT 09/03/2012 només reaprtim segons garantia principal --
         IF    (    NVL (pac_parametros.f_parproducto_n (w_sproduc,
                                                         'GAR_PRINCIPAL_REA'
                                                        ),
                         0
                        ) = 1
                AND w_gar_princ = regaux1.cgarant
               )                                             -- 21559 / 111590
            OR NVL (pac_parametros.f_parproducto_n (w_sproduc,
                                                    'GAR_PRINCIPAL_REA'
                                                   ),
                    0
                   ) = 0
         THEN
            --BUG 21559 - FIN - 23/05/2013 - DCT
            -- bug: 14404 AVT 25-05-2010 una mateixa pòlissa pot tenir 2 ó més contractes de tipus diferent
            BEGIN
               SELECT ctiprea
                 INTO w_ctiprea                        -- 13195 AVT 16-02-2010
                 FROM codicontratos
                WHERE scontra = regaux1.scontra;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  perr := 104697;
                  p_traza_proceso (w_cempres,
                                   vpar_traza,
                                   psproces,
                                   v_nom_paquete,
                                   v_nom_funcion,
                                   NULL,
                                   34,
                                   'Error: ' || perr
                                  );
                  RETURN (perr);
               WHEN OTHERS
               THEN
                  perr := 104516;
                  RETURN (perr);
            END;

            IF regaux1.spleno IS NOT NULL
            THEN                                       -- 13195 AVT 16-02-2010
               w_scontra := regaux1.scontra;
               w_nversio := regaux1.nversio;

               IF w_ctiprea = 1
               THEN
                  w_nplenos := 0;
               ELSE
                  w_nplenos := 1;
               END IF;

               FOR regtram IN cur_trams (regaux1.scontra, regaux1.nversio, 1)
               LOOP
                  w_nplenos := w_nplenos + regtram.nplenos;
               END LOOP;

               w_icapaci :=
                    (  regaux1.ipleno
                     / pac_eco_tipocambio.f_cambio (w_monpol,
                                                    w_moninst,
                                                    pfdatagen
                                                   )
                    )
                  * w_nplenos;
             --BUG CONF-620  Fecha (01/03/2017) - HRE - Reaseguro moneda local
            END IF;

            IF w_ctipre_seg = 1 OR w_ctipre_seg = 3
            THEN
               w_switchgarant := 0;
               w_icapaci := w_icapital;
                               -- regaux1.icapital; BUG: 14400 03-04-2010 AVT
               --AGG 24/07/2014  Modificació per que no salte facultativo
               v_base_rea :=
                  NVL (pac_parametros.f_parproducto_n (w_sproduc,
                                                       'CESION_BASE_REA'
                                                      ),
                       0
                      );

               IF v_base_rea = 1
               THEN
                  BEGIN
                     UPDATE cesionesaux
                        SET icapaci =
                               w_icapaci
                                  -- sempre agafem primer la que s'ha formulat
                      --Per si ve calculat del SGT
                     WHERE  nnumlin = regaux1.nnumlin AND sproces = psproces;
                  --       post;
                  EXCEPTION
                     WHEN OTHERS
                     THEN
                        perr := 104705;
                        p_traza_proceso (w_cempres,
                                         vpar_traza,
                                         psproces,
                                         v_nom_paquete,
                                         v_nom_funcion,
                                         NULL,
                                         37,
                                            'Error: '
                                         || perr
                                         || ' nnumlin: '
                                         || regaux1.nnumlin
                                        );
                        RETURN (perr);
                  END;
               END IF;
            --fin AGG 14/04/2014
            ELSE
               IF w_switchgarant = 1
               THEN
                  w_icapaci :=
                       regaux1.icapital
                     - ((regaux1.icapital * w_porcgarant) / 100);
               END IF;
            END IF;

            BEGIN
               UPDATE cesionesaux
                  SET icapaci = NVL (icapaci, w_icapaci)
                --Per si ve calculat del SGT
               WHERE  nnumlin = regaux1.nnumlin AND sproces = psproces;
            --       post;
            EXCEPTION
               WHEN OTHERS
               THEN
                  perr := 104705;
                  p_traza_proceso (w_cempres,
                                   vpar_traza,
                                   psproces,
                                   v_nom_paquete,
                                   v_nom_funcion,
                                   NULL,
                                   35,
                                   'Error: ' || perr
                                  );
                  RETURN (perr);
            END;
         END IF;                     -- 21559 AVT 09/03/2012 fi --------------

         -- A les garanties no principals tb els hi actualitzem l'estat ............
         --BUG 21559 - INICIO - 23/05/2013 - DCT
         IF     NVL (pac_parametros.f_parproducto_n (w_sproduc,
                                                     'GAR_PRINCIPAL_REA'
                                                    ),
                     0
                    ) = 1
            --BUG 21559 - FIN - 23/05/2013 - DCT
            AND w_gar_princ <> regaux1.cgarant
         THEN                                                -- 21559 / 111590
            UPDATE cesionesaux
               SET cestado = 2
             WHERE sproces = psproces AND cgarant = regaux1.cgarant;
         END IF;
      END LOOP;

      p_traza_proceso (24,
                       'TRAZA_CESIONES_REA',
                       777,
                       'PAC_CESIONES',
                       'F_CESIO',
                       NULL,
                       2,
                       'Error: paso 3 '
                      );
------------------------------------------------------------------------
-- PART 6:
-- ******
-- AQUI ES MIRA SI ES NECESSITA FACULTATIU I SI EXISTEIX JA...
------------------------------------------------------------------------
      perr := 0;
      pfacult := NULL;
      lcapaci_cum := 0;     --BUG CONF-298  Fecha (23/03/2017) - HRE - Cumulos

      FOR regaux1 IN cur_aux_1
      LOOP
         p_traza_proceso (24,
                          'TRAZA_CESIONES_REA',
                          777,
                          'PAC_CESIONES',
                          'F_CESIO',
                          NULL,
                          2,
                             'Error: paso 3_1, regaux1.sseguro:'
                          || regaux1.sseguro
                         );

         --INI BUG CONF-298 Fecha (23/03/2017) - HRE - Cumulos
         BEGIN
            SELECT spereal
              INTO v_tomador
              FROM estper_personas
             WHERE sperson = (SELECT sperson
                                FROM esttomadores
                               WHERE sseguro = regaux1.sseguro);
         EXCEPTION
            WHEN OTHERS
            THEN
               SELECT sperson
                 INTO v_tomador
                 FROM per_personas
                WHERE sperson = (SELECT sperson
                                   FROM tomadores
                                  WHERE sseguro = regaux1.sseguro);
         END;

         SELECT DECODE (COUNT (0), 0, 'N', 'S'),
                DECODE (COUNT (0), 0, 'I', 'C')
           INTO v_consorcio,
                w_tipper
           FROM per_parpersonas
          WHERE sperson = v_tomador
            AND cparam = 'PER_ASO_JURIDICA'
            AND nvalpar = 1;

         --FIN BUG CONF-298  - Fecha (23/03/2017) - HRE
         BEGIN
            SELECT /*cempres,*/ ctiprea, ctipcoa
                                      --BUG CONF-695  Fecha (29/05/2017) - HRE
              INTO /*w_cempres,*/ v_ctiprea, v_ctipcoa          --COA ACEPTADO
              FROM seguros seg
             WHERE seg.sseguro = regaux1.sseguro;

            p_traza_proceso (24,
                             'TRAZA_CESIONES_REA',
                             777,
                             'PAC_CESIONES',
                             'F_CES_QN',
                             NULL,
                             2,
                                'Error: paso 0_1'
                             || ' v_ctiprea:'
                             || v_ctiprea
                             || ' regaux1.sseguro:'
                             || regaux1.sseguro
                            );
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               SELECT /*cempres,*/ ctiprea,
                       ctipcoa        --BUG CONF-695  Fecha (29/05/2017) - HRE
                 INTO /*w_cempres,*/ v_ctiprea,
                       v_ctipcoa                                --COA ACEPTADO
                 FROM estseguros seg
                WHERE seg.sseguro = regaux1.sseguro;

               p_traza_proceso (24,
                                'TRAZA_CESIONES_REA',
                                777,
                                'PAC_CESIONES',
                                'F_CES_QN',
                                NULL,
                                2,
                                   'Error: paso 0_2'
                                || ' v_ctiprea:'
                                || v_ctiprea
                                || ' regaux1.sseguro:'
                                || regaux1.sseguro
                               );
         END;

            --FEPP 4773
         --INI- EDBR - 11/06/2019 - IAXIS3338 - se toma el valor de retenciòn por poliza de la tabla contratos
         BEGIN
            SELECT NVL (nretpol, v_lim_ret_global)
              INTO v_lim_ret
              FROM contratos
             WHERE scontra = regaux1.scontra AND fconfin IS NULL;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               v_lim_ret := v_lim_ret_global;
         END;

         --FIN- EDBR - 11/06/2019 - IAXIS3338 - se toma el valor de retenciòn por poliza de la tabla contratos
         p_traza_proceso
            (24,
             'TRAZA_CESIONES_REA',
             777,
             'PAC_CESIONES',
             'F_CESIO',
             NULL,
             2,
                'Error: paso 3 '
             || ' w_monpol:'
             || w_monpol
             || ' w_moninst:'
             || w_moninst
             || ' pfdatagen:'
             || pfdatagen
             || ' regaux1.icapita;'
             || regaux1.icapital
             || ' v_lim_ret:'
             || v_lim_ret
             || ' v_tomador:'
             || v_tomador
             || ' regaux1.scontra:'
             || regaux1.scontra
             || ' regaux1.nversio:'
             || regaux1.nversio
             || ' v_consorcio:'
             || v_consorcio
             || ' v_ctiprea:'
             || v_ctiprea
             || ' cumulo disponible tramo:'
             || pac_cumulos_conf.f_calcula_disponible_tramo
                       (pfdatagen,
                        v_tomador,
                        regaux1.scontra,
                        regaux1.nversio,
                        0,
                        pac_eco_tipocambio.f_importe_cambio (w_monpol,
                                                             w_moninst,
                                                             pfdatagen,
                                                             regaux1.icapital
                                                            ),
                        v_consorcio,
                        v_ctipcoa,                              --COAS ACEPTADO
                       --) >= 1)--BUG CONF-298  Fecha (23/03/2017) - HRE - Cumulos
                        -- Inicio IAXIS-12992 27/04/2020
                        regaux1.sseguro,
                        pmotiu,
                        ptablas
                        -- Fin IAXIS-12992 27/04/2020
                     )
            );

         ---FEPP 4773
         IF (    (   (    pac_eco_tipocambio.f_importe_cambio
                                                             (w_monpol,
                                                              w_moninst,
                                                              pfdatagen,
                                                              regaux1.icapital
                                                             ) <=
                             v_lim_ret
             --BUG CONF-620  Fecha (01/03/2017) - HRE - Reaseguro moneda local
                      AND pac_cumulos_conf.f_calcula_disponible_tramo
                             (pfdatagen,
                              v_tomador,
                              regaux1.scontra,
                              regaux1.nversio,
                              0,
                              pac_eco_tipocambio.f_importe_cambio
                                                             (w_monpol,
                                                              w_moninst,
                                                              pfdatagen,
                                                              regaux1.icapital
                                                             ),
                              v_consorcio,
                              v_ctipcoa,                        --COAS ACEPTADO
                             --) >= 1)--BUG CONF-298  Fecha (23/03/2017) - HRE - Cumulos
                              -- Inicio IAXIS-12992  27/04/2020
                              regaux1.sseguro,
                              pmotiu,
                              ptablas
                              -- Fin IAXIS-12992 27/04/2020
                              ) >= 1
                     )
                  OR v_ctiprea = 1
                 )
             AND v_ctiprea != 2
            )
--BUG CONF-298  Fecha (23/03/2017) - HRE - Cumulos, BUG CONF-695  Fecha (29/05/2017) - HRE
         THEN
            --w_porce := 1;
            p_traza_proceso (24,
                             'TRAZA_CESIONES_REA',
                             777,
                             'PAC_CESIONES',
                             'F_CESIO',
                             NULL,
                             360,
                             'Error: paso 36_0 '
                            );
            v_base_rea :=
               NVL (pac_parametros.f_parproducto_n (w_sproduc,
                                                    'CESION_BASE_REA'
                                                   ),
                    0
                   );
            w_sproces := regaux1.sproces;
            w_sseguro := regaux1.sseguro;
            w_nmovimi := regaux1.nmovimi;

            UPDATE cesionesaux
               SET cestado = 2,
                   sfacult = NULL
             WHERE nnumlin = regaux1.nnumlin AND sproces = psproces;

            SELECT sgt_sesiones.NEXTVAL
              INTO psesion
              FROM DUAL;
         ELSE
            -- 21559 AVT 09/03/2012 només reaprtim segons garantia principal --
            -->DBMS_OUTPUT.put_line('*** GAR_PRINCIPAL_REA regaux1.cgarant:' || regaux1.cgarant);
            --INI BUG CONF-298 Fecha (23/03/2017) - HRE - Cumulos
            /*BEGIN
               SELECT spereal
                 INTO v_tomador
                 FROM estper_personas
                WHERE sperson = (SELECT sperson
                                   FROM esttomadores
                                  WHERE sseguro = regaux1.sseguro);

            EXCEPTION
               WHEN OTHERS THEN
                  SELECT sperson
                    INTO v_tomador
                    FROM per_personas
                   WHERE sperson =    (SELECT sperson
                                      FROM tomadores
                                     WHERE sseguro = regaux1.sseguro);
            END;

            SELECT DECODE(COUNT(0), 0, 'N','S'), DECODE(COUNT(0), 0, 'I','C')
              INTO v_consorcio, w_tipper
              FROM per_parpersonas
             WHERE sperson = v_tomador
               AND cparam = 'PER_ASO_JURIDICA'
               AND nvalpar = 1;
            --FIN BUG CONF-298  - Fecha (23/03/2017) - HRE        */
            --BUG 21559 - INICIO - 23/05/2013 - DCT
            /* obtiene capacidad real de acuerdo a la capacidad de los tramos
               y teniendo en cuenta si cede o no al q3*/
            p_traza_proceso
                       (24,
                        'TRAZA_CESIONES_REA',
                        777,
                        'PAC_CESIONES',
                        'F_CESSIO',
                        NULL,
                        2809,
                           'ENTRA POR ELSE CALCULO:'
                        || pac_eco_tipocambio.f_importe_cambio
                                                             (w_monpol,
                                                              w_moninst,
                                                              pfdatagen,
                                                              regaux1.icapital
                                                             )
                       );

            SELECT sgt_sesiones.NEXTVAL
              INTO psesion
              FROM DUAL;

            SELECT formula
              INTO v_formula
              FROM sgt_formulas
             WHERE clave = v_claveq3;

            vnerror := pac_sgt.put (psesion, 'SSEGURO', regaux1.sseguro);
            vnerror := pac_sgt.put (psesion, 'SCONTRA', regaux1.scontra);
            vnerror := pac_sgt.put (psesion, 'NVERSIO', regaux1.nversio);
            vnerror := pac_sgt.put (psesion, 'CTRAMO', 3);
            v_reparte_q3 := pk_formulas.eval (v_formula, psesion);
            p_traza_proceso (24,
                             'TRAZA_CESIONES_REA',
                             777,
                             'PAC_CESIONES',
                             'F_CESSIO',
                             NULL,
                             2828,
                             'v_reparte_q3:' || v_reparte_q3
                            );

            OPEN cur_capacontra (regaux1.scontra,
                                 regaux1.nversio,
                                 v_reparte_q3
                                );

            FETCH cur_capacontra
             INTO v_capareal;

            CLOSE cur_capacontra;

            p_traza_proceso (24,
                             'TRAZA_CESIONES_REA',
                             777,
                             'PAC_CESIONES',
                             'F_CESSIO',
                             NULL,
                             2835,
                                'v_capareal:'
                             || v_capareal
                             || ' v_ctipcoa:'
                             || v_ctipcoa
                            );

            --INI BUG 12564 AABG 02-14-2020: Se comenta para error de facultativo
            /*IF (v_ctipcoa = 8)
            THEN                                                --COA ACEPTADO
               v_capareal := v_capareal / 2;
            END IF;*/
            --FIN BUG 12564 AABG 02-14-2020: Se comenta para error de facultativo

            --INFORCOL INI 20191204
            IF w_cramo <> 802
            THEN
               regaux1.icapaci := v_capareal;
            END IF;

            p_traza_proceso (24,
                             'TRAZA_CESIONES_REA',
                             777,
                             'PAC_CESIONES',
                             'F_CESSIO',
                             NULL,
                             2844,
                                'ptablas:'
                             || ptablas
                             || ' regaux1.icapaci:'
                             || regaux1.icapaci
                            );

            --INFORCOL FIN 20191204

            /*fin capacidad real*/
            IF ptablas = 'EST'
            THEN
               BEGIN
                  SELECT sproduc
                    INTO w_sproduc
                    FROM estseguros
                   WHERE sseguro = regaux1.sseguro;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     perr := 101919;
                     p_traza_proceso (w_cempres,
                                      vpar_traza,
                                      psproces,
                                      v_nom_paquete,
                                      v_nom_funcion,
                                      NULL,
                                      36,
                                      'Error: ' || perr
                                     );
                     RETURN (perr);
               END;
            ELSIF ptablas = 'CAR'
            THEN
               BEGIN
                  SELECT sproduc
                    INTO w_sproduc
                    FROM seguros
                   WHERE sseguro = regaux1.sseguro;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     perr := 101919;
                     p_traza_proceso (w_cempres,
                                      vpar_traza,
                                      psproces,
                                      v_nom_paquete,
                                      v_nom_funcion,
                                      NULL,
                                      37,
                                      'Error: ' || perr
                                     );
                     RETURN (perr);
               END;
            ELSE
               BEGIN                -- Busquem si prima prorratejable o no...
                  SELECT sproduc
                    INTO w_sproduc
                    FROM seguros
                   WHERE sseguro = regaux1.sseguro;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     perr := 101919;
                     p_traza_proceso (w_cempres,
                                      vpar_traza,
                                      psproces,
                                      v_nom_paquete,
                                      v_nom_funcion,
                                      NULL,
                                      38,
                                      'Error: ' || perr
                                     );
                     RETURN (perr);
               END;
            END IF;

            IF    (    NVL
                          (pac_parametros.f_parproducto_n (w_sproduc,
                                                           'GAR_PRINCIPAL_REA'
                                                          ),
                           0
                          ) = 1
                   AND w_gar_princ = regaux1.cgarant
                  )                                          -- 21559 / 111590
               OR NVL (pac_parametros.f_parproducto_n (w_sproduc,
                                                       'GAR_PRINCIPAL_REA'
                                                      ),
                       0
                      ) = 0
            THEN
               --BUG 21559 - FIN - 23/05/2013 - DCT
               w_sproces := regaux1.sproces;
               w_sseguro := regaux1.sseguro;
               w_nmovimi := regaux1.nmovimi;
               p_traza_proceso (24,
                                'TRAZA_CESIONES_REA',
                                777,
                                'PAC_CESIONES',
                                'F_CESIO',
                                NULL,
                                2,
                                'Error: paso 4 '
                               );

               IF NVL (regaux1.cfacult, 0) <> 0
               THEN                                    -- FACULTATIU FORÇAT...
                  w_fac_princ := 1;

                  ------        buscar facultatiu...
                  IF regaux1.sfacult IS NOT NULL
                  THEN
                     w_trobat := 1;
                     pfacult := regaux1.sfacult;
                     p_traza_proceso (24,
                                      'TRAZA_CESIONES_REA',
                                      777,
                                      'PAC_CESIONES',
                                      'F_CESIO',
                                      NULL,
                                      2,
                                      'Error: paso 5 '
                                     );
                  ELSE
                     p_traza_proceso (24,
                                      'TRAZA_CESIONES_REA',
                                      777,
                                      'PAC_CESIONES',
                                      'F_CESIO',
                                      NULL,
                                      2,
                                      'Error: paso 6 '
                                     );
                     codi_error :=
                        f_facult (regaux1.sseguro,
                                  regaux1.nriesgo,
                                  regaux1.ccalif1,
                                  regaux1.ccalif2,
                                  regaux1.cgarant,
                                  NULL,
                                  NULL,
                                  regaux1.fconini,
                                  regaux1.scumulo,
                                  pfdatagen,
                                  w_trobat,
                                  w_cestado,
                                  pfacult,
                                  w_ifacced
                                 );

                     IF codi_error <> 0
                     THEN
                        p_traza_proceso (w_cempres,
                                         vpar_traza,
                                         psproces,
                                         v_nom_paquete,
                                         v_nom_funcion,
                                         NULL,
                                         39,
                                         'Error: ' || codi_error
                                        );
                        RETURN (codi_error);
                     END IF;

                     -->> AVT 21/01/2014  inici control dels facultatius existents en cas de cúmul
                     IF NVL (regaux1.scumulo, 0) > 0
                     THEN
                        BEGIN
                           SELECT COUNT (*)
                             INTO v_hiha_ces
                             FROM cesionesrea
                            WHERE sfacult = pfacult;
                        EXCEPTION
                           WHEN NO_DATA_FOUND
                           THEN
                              v_hiha_ces := 0;
                           WHEN OTHERS
                           THEN
                              v_hiha_ces := 0;
                              p_traza_proceso (w_cempres,
                                               vpar_traza,
                                               psproces,
                                               v_nom_paquete,
                                               v_nom_funcion,
                                               NULL,
                                               40,
                                               'Error facult: ' || pfacult
                                              );
                              p_tab_error (f_sysdate,
                                           f_user,
                                           'f_cessio',
                                           1,
                                           'cesionesrea sfacult:' || pfacult,
                                           SQLCODE || ' - ' || SQLERRM
                                          );
                        END;
                     ELSE
                        v_hiha_ces := 0;
                     END IF;
                  -->> AVT 21/01/2014  fi
                  END IF;

                  IF w_trobat = 1 AND v_hiha_ces = 0
                  THEN                                     -->> AVT 21/01/2014
                     IF w_cestado = 2 AND w_ifacced = regaux1.icapital
                     THEN
                        ------              cessió...
                        BEGIN
                           UPDATE cesionesaux
                              SET cestado = 2,
                                  sfacult = pfacult
                            WHERE nnumlin = regaux1.nnumlin
                              AND sproces = psproces;
                        EXCEPTION
                           WHEN NO_DATA_FOUND
                           THEN
                              perr := 104695;
                              p_traza_proceso (w_cempres,
                                               vpar_traza,
                                               psproces,
                                               v_nom_paquete,
                                               v_nom_funcion,
                                               NULL,
                                               41,
                                               'Error: ' || perr
                                              );
                              RETURN (perr);
                           WHEN OTHERS
                           THEN
                              perr := 104696;
                              p_traza_proceso (w_cempres,
                                               vpar_traza,
                                               psproces,
                                               v_nom_paquete,
                                               v_nom_funcion,
                                               NULL,
                                               42,
                                               'Error: ' || perr
                                              );
                              RETURN (perr);
                        END;
                     ELSE
                        p_traza_proceso (24,
                                         'TRAZA_CESIONES_REA',
                                         777,
                                         'PAC_CESIONES',
                                         'F_CESIO',
                                         NULL,
                                         2,
                                            'Error: paso 7, pcgesfac: '
                                         || pcgesfac
                                        );

                        ------              a taula pendent...
                        --IF w_ifacced <> regaux1.icapital THEN
                        -- nunu trec trec If pq no fa la capçalera
                        -- 19484 cgesfac = 0-No generar QUADRE 1-Si generar QUADRE
                        IF pcgesfac = 1
                        THEN
                           cabfacul (regaux1);

                           IF perr <> 0 AND perr <> 99
                           THEN
                              p_traza_proceso (w_cempres,
                                               vpar_traza,
                                               psproces,
                                               v_nom_paquete,
                                               v_nom_funcion,
                                               NULL,
                                               43,
                                               'Error: ' || perr
                                              );
                              RETURN (perr);
                           END IF;

                           -- 19484 - AVT 02/01/2012
                           perr := 99;
                           p_traza_proceso (w_cempres,
                                            vpar_traza,
                                            psproces,
                                            v_nom_paquete,
                                            v_nom_funcion,
                                            NULL,
                                            44,
                                            'Error: ' || perr
                                           );
                        ELSE
                           perr := 99;
                           p_traza_proceso (w_cempres,
                                            vpar_traza,
                                            psproces,
                                            v_nom_paquete,
                                            v_nom_funcion,
                                            NULL,
                                            45,
                                            'Error: ' || perr
                                           );
                           EXIT;
                        END IF;
                     END IF;
                  ELSE
                     p_traza_proceso (24,
                                      'TRAZA_CESIONES_REA',
                                      777,
                                      'PAC_CESIONES',
                                      'F_CESIO',
                                      NULL,
                                      2,
                                      'Error: paso 8, pcgesfac: ' || pcgesfac
                                     );

                     ------           a taula pendent...
                     -- 19484 cgesfac = 0-No generar QUADRE 1-Si generar QUADRE
                     IF pcgesfac = 1
                     THEN
                        cabfacul (regaux1);

                        IF perr <> 0 AND perr <> 99
                        THEN
                           p_traza_proceso (w_cempres,
                                            vpar_traza,
                                            psproces,
                                            v_nom_paquete,
                                            v_nom_funcion,
                                            NULL,
                                            46,
                                            'Error: ' || perr
                                           );
                           RETURN (perr);
                        END IF;

                        -- 19484 - AVT 02/01/2012
                        perr := 99;
                        p_traza_proceso (w_cempres,
                                         vpar_traza,
                                         psproces,
                                         v_nom_paquete,
                                         v_nom_funcion,
                                         NULL,
                                         47,
                                         'Error: ' || perr
                                        );
                     ELSE
                        perr := 99;
                        p_traza_proceso (w_cempres,
                                         vpar_traza,
                                         psproces,
                                         v_nom_paquete,
                                         v_nom_funcion,
                                         NULL,
                                         48,
                                         'Error: ' || perr
                                        );
                        EXIT;
                     END IF;
                  END IF;
               ELSE                                              -- del forçat
                  --nunununu
                  p_traza_proceso (24,
                                   'TRAZA_CESIONES_REA',
                                   777,
                                   'PAC_CESIONES',
                                   'F_CESSIO',
                                   NULL,
                                   2,
                                   'Error: paso 9, pcgesfac: ' || pcgesfac
                                  );

                  -- Cal veure si te cúmul per saber si excedeix del capital i va
                  -- a facultatiu
                  IF regaux1.scumulo IS NOT NULL 
		    -- Inicio IAXIS-12992 27/04/2020
                    OR (regaux1.scumulo IS NULL AND pac_cumulos_conf.f_cum_total_tom_otros(v_tomador,
                                                                                           pfdatagen,
                                                                                           regaux1.sseguro,
                                                                                           regaux1.scontra,
                                                                                           regaux1.nversio,NULL) > 0)
		    -- Fin IAXIS-12992 27/04/2020								   
                  THEN
                     p_traza_proceso (24,
                                      'TRAZA_CESIONES_REA',
                                      777,
                                      'PAC_CESIONES',
                                      'F_CESSIO',
                                      NULL,
                                      2,
                                      'Error: paso 9_1, pcgesfac: '
                                      || pcgesfac
                                     );
                     -- Buscar el capital del cúmul
                     perr :=
                        pac_cesionesrea.f_ple_cumul_est (regaux1.sseguro,
                                                         regaux1.scumulo,
                                                         regaux1.cgarant,
                                                         regaux1.fconini,
                                                         lcapicum,
                                                         lplecum,
                                                         lcapacum,
                                                         ptablas
                                                        );
                     p_traza_proceso (24,
                                      'TRAZA_CESIONES_REA',
                                      777,
                                      'PAC_CESIONES',
                                      'F_CESSIO',
                                      NULL,
                                      2,
                                         'Error: paso 9_2, pcgesfac: '
                                      || pcgesfac
                                      || ' lcapicum:'
                                      || lcapicum
                                      || ' lplecum:'
                                      || lplecum
                                      || ' lcapacum:'
                                      || lcapacum
                                      || ' regaux1.ipleno:'
                                      || regaux1.ipleno
                                      || ' regaux1.icapaci:'
                                      || regaux1.icapaci
                                     );

                     IF perr <> 0
                     THEN
                        p_traza_proceso (w_cempres,
                                         vpar_traza,
                                         psproces,
                                         v_nom_paquete,
                                         v_nom_funcion,
                                         NULL,
                                         49,
                                         'Error: ' || perr
                                        );
                        RETURN perr;
                     END IF;

                     -- Cal actualitzar el valor del ple amb el màxim del cúmul
                     IF    NVL (lplecum, 0) > regaux1.ipleno
                        OR NVL (lcapacum, 0) > regaux1.icapaci
                     THEN
                        p_traza_proceso (24,
                                         'TRAZA_CESIONES_REA',
                                         777,
                                         'PAC_CESIONES',
                                         'F_CESSIO',
                                         NULL,
                                         2,
                                            'Error: paso 9_3, pcgesfac: '
                                         || pcgesfac
                                         || ' lcapicum:'
                                         || lcapicum
                                         || ' lplecum:'
                                         || lplecum
                                         || ' lcapacum:'
                                         || lcapacum
                                         || ' regaux1.ipleno:'
                                         || regaux1.ipleno
                                         || ' regaux1.icapaci:'
                                         || regaux1.icapaci
                                        );

                        IF NVL (lplecum, 0) > regaux1.ipleno
                        THEN
                           regaux1.ipleno := lplecum;
                        END IF;

                        -- Cal actualitzar el valor de la capacitat amb el màxim del cúmul
                        IF NVL (lcapacum, 0) > regaux1.icapaci
                        THEN
                           regaux1.icapaci := lcapacum;
                        END IF;

                        UPDATE cesionesaux
                           SET ipleno = regaux1.ipleno,
                               icapaci = regaux1.icapaci
                         WHERE nnumlin = regaux1.nnumlin
                               AND sproces = psproces;
                     END IF;

                     ----dbms_outpuT.put_line('******** capicum ****' || lcapicum);
                     -- Valor que podem assumir
                     lassumir := regaux1.ipleno - lcapicum;
                     p_traza_proceso (24,
                                      'TRAZA_CESIONES_REA',
                                      777,
                                      'PAC_CESIONES',
                                      'F_CESSIO',
                                      NULL,
                                      2,
                                         'Error: paso 9_4, lassumir:'
                                      || lassumir
                                      || ' regaux1.ipleno:'
                                      || regaux1.ipleno
                                      || ' lcapicum:'
                                      || lcapicum
                                     );

                     IF lassumir < 0
                     THEN
                        lassumir := 0;
                     END IF;

                     -- Una vegada trobat el capital que pot cedir la garantia(ella sola)
                     -- dins el cúmul, mirem la totalitat de les garanties que
                     -- van juntes més les de la pròpia pòlissa (no la garantia que tractem)
                     IF lassumir > 0
                     THEN
                        p_traza_proceso (24,
                                         'TRAZA_CESIONES_REA',
                                         777,
                                         'PAC_CESIONES',
                                         'F_CESSIO',
                                         NULL,
                                         2,
                                            'Error: paso 9_5, lassumir:'
                                         || lassumir
                                         || ' regaux1.ipleno:'
                                         || regaux1.ipleno
                                         || ' lcapicum:'
                                         || lcapicum
                                        );
                        perr :=
                           pac_cesionesrea.f_ple_cumul_tot_est_mon
                                                             (regaux1.sseguro,
                                                              regaux1.scumulo,
                                                              regaux1.cgarant,
                                                              regaux1.fconini,
                                                              regaux1.scontra,
                                                              regaux1.nversio,
                                                              w_moninst,
                                                              pfdatagen,
                                                              lcapcum_tot,
                                                              lplecum_tot,
                                                              ptablas
                                                             );
             --BUG CONF-620  Fecha (01/03/2017) - HRE - Reaseguro moneda local
                        p_traza_proceso (24,
                                         'TRAZA_CESIONES_REA',
                                         777,
                                         'PAC_CESIONES',
                                         'F_CESSIO',
                                         NULL,
                                         2,
                                            'Error: paso 9_6, lcapcum_tot:'
                                         || lcapcum_tot
                                         || ' lplecum_tot:'
                                         || lplecum_tot
                                        );

                        IF perr <> 0
                        THEN
                           p_traza_proceso (w_cempres,
                                            vpar_traza,
                                            psproces,
                                            v_nom_paquete,
                                            v_nom_funcion,
                                            NULL,
                                            50,
                                            'Error: ' || perr
                                           );
                           RETURN perr;
                        END IF;

                        w_captram_tot := lplecum_tot - lcapcum_tot;
                        p_traza_proceso (24,
                                         'TRAZA_CESIONES_REA',
                                         777,
                                         'PAC_CESIONES',
                                         'F_CESSIO',
                                         NULL,
                                         2,
                                            'Error: paso 9_7, lcapcum_tot:'
                                         || lcapcum_tot
                                         || ' lplecum_tot:'
                                         || lplecum_tot
                                         || ' w_captram_tot:'
                                         || w_captram_tot
                                        );

                        -- Ens quedem amb l'import menor
                        IF w_captram_tot < lassumir
                        THEN
                           -- si és menor canviem el valor del capital del tram
                           lassumir := w_captram_tot;
                           p_traza_proceso
                                          (24,
                                           'TRAZA_CESIONES_REA',
                                           777,
                                           'PAC_CESIONES',
                                           'F_CESSIO',
                                           NULL,
                                           2,
                                              'Error: paso 9_8, lcapcum_tot:'
                                           || lcapcum_tot
                                           || ' lplecum_tot:'
                                           || lplecum_tot
                                           || ' w_captram_tot:'
                                           || w_captram_tot
                                           || ' lassumir:'
                                           || lassumir
                                          );
                        --ELSE
                        -- si és més gran ja és correcte assumuir lassumir
                        END IF;
                     END IF;

                     -- la capacitat li restem el que NO HEM assumit encara
                     --lcapaci_cum := regaux1.icapaci - (regaux1.ipleno - lassumir); --BUG CONF-298  Fecha (23/03/2017) - HRE - Cumulos

                     ----dbms_outpuT.put_line('************ lcapaci_cum ' || lcapaci_cum);

                     --Cal descomptar de la capacitat el que portem assumit de cada tram
                     FOR v_tram IN cur_trams (regaux1.scontra,
                                              regaux1.nversio,
                                              v_reparte_q3
                                             )
                     LOOP
                        lcapcumtram := 0;

                        IF v_tram.ctramo > 0
                        THEN                            -- 28777 AVT 13-11-13
                           perr :=
                              pac_cesionesrea.f_captram_cumul_est_mon
                                 (regaux1.sseguro,
                                  regaux1.scumulo,
                                  regaux1.cgarant,
                                  regaux1.fconini,
                                  v_tram.ctramo,
                                  regaux1.scontra,
                                  regaux1.nversio,
                                  w_moninst,
                                  pfdatagen,
             --BUG CONF-620  Fecha (01/03/2017) - HRE - Reaseguro moneda local
                                  lcapcumtram,
                                  lpleno,
                                  ptablas
                                 );                                 --nunu ???
                           perr :=
                              pac_cesionesrea.f_captram_cumul_ret
                                 (regaux1.sseguro,
                                  regaux1.scumulo,
                                  regaux1.cgarant,
                                  regaux1.fconini,
                                  v_tram.ctramo,
                                  regaux1.scontra,
                                  regaux1.nversio,
                                  w_moninst,
                                  pfdatagen,
             --BUG CONF-620  Fecha (01/03/2017) - HRE - Reaseguro moneda local
                                  lcapcumtram_ret,
                                  lpleno_ret,
                                  ptablas
                                 );

                           IF perr <> 0
                           THEN
                              p_traza_proceso (w_cempres,
                                               vpar_traza,
                                               psproces,
                                               v_nom_paquete,
                                               v_nom_funcion,
                                               NULL,
                                               51,
                                               'Error: ' || perr
                                              );
                              RETURN perr;
                           END IF;
                        END IF;

                        --INI BUG CONF-298 Fecha (23/03/2017) - HRE - Cumulos
                        v_porc_min_disp :=
                           pac_cumulos_conf.f_calcula_disponible_tramo
                              (pfdatagen,
                               v_tomador,
                               regaux1.scontra,
                               regaux1.nversio,
                               v_tram.ctramo,
                               pac_eco_tipocambio.f_importe_cambio
                                                             (w_monpol,
                                                              w_moninst,
                                                              pfdatagen,
                                                              regaux1.icapital
                                                             ),
                               v_consorcio,
                               v_ctipcoa,                       --COA ACEPTADO
                               -- Inicio IAXIS-12992 27/04/2020
                               regaux1.sseguro,
                               pmotiu,
                               ptablas 
                               -- Fin IAXIS-12992 27/04/2020
                              );
                        lcapaci_cum :=
                             NVL (lcapaci_cum, 0)
                           + regaux1.icapital * v_porc_min_disp;
                        p_traza_proceso
                           (24,
                            'TRAZA_CESIONES_REA',
                            777,
                            'PAC_CESIONES',
                            'F_CESSIO',
                            NULL,
                            2,
                               'Error: paso 9_9,
                     v_porc_min_disp:'
                            || v_porc_min_disp
                            || ' lcapaci_cum:'
                            || lcapaci_cum
                            || ' regaux1.icapital:'
                            || regaux1.icapital
                            || ' regaux1.sseguro:'
                            || regaux1.sseguro
                            || ' ptablas:'
                            || ptablas
                            || ' v_tram.ctramo:'
                            || v_tram.ctramo
                           );
                     END LOOP;

                     --FIN BUG CONF-298  - Fecha (23/03/2017) - HRE
                     IF lcapaci_cum < 0
                     THEN
                        lcapaci_cum := 0;
                     END IF;
                  ELSE
                     lcapaci_cum :=
                          regaux1.icapaci
                        / pac_eco_tipocambio.f_cambio (w_monpol,
                                                       w_moninst,
                                                       w_pfdatagen
                                                      );
                  END IF;

                  -- nunununu
                  ----dbms_outpuT.put_line(regaux1.icapital || '>' || lcapaci_cum);
                  p_traza_proceso
                     (24,
                      'TRAZA_CESIONES_REA',
                      777,
                      'PAC_CESIONES',
                      'F_CESSIO',
                      NULL,
                      2,
                         'Error: paso 9_10,
                     v_porc_min_disp:'
                      || v_porc_min_disp
                      || ' lcapaci_cum:'
                      || lcapaci_cum
                      || ' regaux1.icapital:'
                      || regaux1.icapital
                     );
				 
				
                --INI IAXIS BUG 13246 AABG: Validacion para facultativo manual
                  codi_error := f_existe_fac(regaux1.sseguro,
                                             regaux1.nversio,
                                             pmotiu,
                                             w_sproduc,
                                             regaux1.scontra,
                                             v_apl_facul);
                  IF codi_error <> 0
                  THEN
                    RETURN (codi_error);
                  END IF;
                  --FIN IAXIS BUG 13246 AABG: Validacion para facultativo manual 

                IF    regaux1.icapital >
                           (lcapaci_cum /*/ pac_eco_tipocambio.f_cambio(w_monpol, w_moninst, pfdatagen)*/
                           )
             --BUG CONF-620  Fecha (01/03/2017) - HRE - Reaseguro moneda local
                     OR w_switchgarant = 1
                     --INI IAXIS BUG 13246 AABG: Validacion para facultativo cesion manual
                     OR v_apl_facul = 1
                     --FIN IAXIS BUG 13246 AABG: Validacion para facultativo cesion manual
                  THEN                             -- NECESSITEM FACULTATIU...
                     p_traza_proceso
                        (24,
                         'TRAZA_CESIONES_REA',
                         777,
                         'PAC_CESIONES',
                         'F_CESSIO',
                         NULL,
                         2,
                            'Error: paso 9_11,
                     v_porc_min_disp:'
                         || v_porc_min_disp
                         || ' lcapaci_cum:'
                         || lcapaci_cum
                         || ' regaux1.icapital:'
                         || regaux1.icapital
                        );
                     w_fac_princ := 1;                                 --22237
                     ------        buscar facultatiu...
                     codi_error :=
                        f_facult (regaux1.sseguro,
                                  regaux1.nriesgo,
                                  regaux1.ccalif1,
                                  regaux1.ccalif2,
                                  regaux1.cgarant,
                                  regaux1.scontra,
                                  regaux1.nversio,
                                  regaux1.fconini,
                                  regaux1.scumulo,
                                  pfdatagen,
                                  w_trobat,
                                  w_cestado,
                                  pfacult,
                                  w_ifacced
                                 );

                     IF codi_error <> 0
                     THEN
                        p_traza_proceso (w_cempres,
                                         vpar_traza,
                                         psproces,
                                         v_nom_paquete,
                                         v_nom_funcion,
                                         NULL,
                                         52,
                                         'Error: ' || perr
                                        );
                        RETURN (codi_error);
                     END IF;

                     p_traza_proceso
                        (24,
                         'TRAZA_CESIONES_REA',
                         777,
                         'PAC_CESIONES',
                         'F_CESSIO',
                         NULL,
                         2,
                            'Error: paso 9_12,
                     codi_error:'
                         || codi_error
                         || ' regaux1.scumulo:'
                         || regaux1.scumulo
                        );

                     -->> AVT 21/01/2014  inici control dels facultatius existents en cas de cúmul
                     IF NVL (regaux1.scumulo, 0) > 0
                     THEN
                        BEGIN
                           SELECT COUNT (*)
                             INTO v_hiha_ces
                             FROM cesionesrea
                            WHERE sfacult = pfacult;
                        EXCEPTION
                           WHEN NO_DATA_FOUND
                           THEN
                              v_hiha_ces := 0;
                           WHEN OTHERS
                           THEN
                              v_hiha_ces := 0;
                              p_traza_proceso (w_cempres,
                                               vpar_traza,
                                               psproces,
                                               v_nom_paquete,
                                               v_nom_funcion,
                                               NULL,
                                               53,
                                               'Error facult: ' || pfacult
                                              );
                              p_tab_error (f_sysdate,
                                           f_user,
                                           'f_cessio',
                                           1,
                                           'cesionesrea sfacult:' || pfacult,
                                           SQLCODE || ' - ' || SQLERRM
                                          );
                        END;
                     ELSE
                        v_hiha_ces := 0;
                     END IF;

                     -->> AVT 21/01/2014  fi

                     ----dbms_outpuT.put_line(w_trobat || ' =1');
                     p_traza_proceso
                        (24,
                         'TRAZA_CESIONES_REA',
                         777,
                         'PAC_CESIONES',
                         'F_CESSIO',
                         NULL,
                         2,
                            'Error: paso 9_13,
                     w_trobat:'
                         || w_trobat
                         || ' v_hiha_ces:'
                         || v_hiha_ces
                        );

                     IF w_trobat = 1 AND v_hiha_ces = 0
                     THEN                                  -->> AVT 21/01/2014
                        -- CPM 26/5/06: En lugar de la capacidad màxima del registro, cogemos
                        --  la capacidad del cumulo
                        ----dbms_outpuT.put_line(w_cestado || ' = 2 AND ' || w_switchgarant || ' <> 1 AND'
                        --                    || w_ifacced);
                        --AGG 24/07/2014
                        v_base_rea :=
                           NVL
                              (pac_parametros.f_parproducto_n
                                                            (w_sproduc,
                                                             'CESION_BASE_REA'
                                                            ),
                               0
                              );
                        p_traza_proceso
                           (24,
                            'TRAZA_CESIONES_REA',
                            777,
                            'PAC_CESIONES',
                            'F_CESSIO',
                            NULL,
                            2,
                               'Error: paso 9_14,
                     w_cestado:'
                            || w_cestado
                            || ' w_switchgarant:'
                            || w_switchgarant
                            || ' w_ifacced:'
                            || w_ifacced
                            || ' regaux1.icapital:'
                            || regaux1.icapital
                            || ' lcapaci_cum:'
                            || lcapaci_cum
                           );

                        IF    (w_cestado = 2 AND w_switchgarant <> 1
                                                                    -- q1,q2,q3 se debe habilitar con cumulos AND w_ifacced =(regaux1.icapital - lcapaci_cum)
                              )
                           OR (    w_cestado = 2
                               AND w_switchgarant =
                                      1
--  w_switchgarant = 1 -> Si tinguèssim Capacitat definida per garantia  (taula: capgarant)
                               AND w_ifacced =
                                      (  regaux1.icapital
                                       - (lcapaci_cum /*/ pac_eco_tipocambio.f_cambio(w_monpol, w_moninst, pfdatagen)*/
                                         )
             --BUG CONF-620  Fecha (01/03/2017) - HRE - Reaseguro moneda local
                                      )
                              )
                        THEN
                           -------             cessió...
                           p_traza_proceso
                              (24,
                               'TRAZA_CESIONES_REA',
                               777,
                               'PAC_CESIONES',
                               'F_CESSIO',
                               NULL,
                               2,
                                  'Error: paso 9_15,
                     w_cestado:'
                               || w_cestado
                               || ' w_switchgarant:'
                               || w_switchgarant
                               || ' w_ifacced:'
                               || w_ifacced
                               || ' regaux1.icapital:'
                               || regaux1.icapital
                               || ' lcapaci_cum:'
                               || lcapaci_cum
                              );

                           BEGIN
                              UPDATE cesionesaux
                                 SET cestado = 2,
                                     sfacult = pfacult
                               WHERE nnumlin = regaux1.nnumlin
                                 AND sproces = psproces;
                           EXCEPTION
                              WHEN NO_DATA_FOUND
                              THEN
                                 perr := 104695;
                                 p_traza_proceso (w_cempres,
                                                  vpar_traza,
                                                  psproces,
                                                  v_nom_paquete,
                                                  v_nom_funcion,
                                                  NULL,
                                                  55,
                                                  'Error: ' || perr
                                                 );
                                 RETURN (perr);
                              WHEN OTHERS
                              THEN
                                 perr := 104696;
                                 p_traza_proceso (w_cempres,
                                                  vpar_traza,
                                                  psproces,
                                                  v_nom_paquete,
                                                  v_nom_funcion,
                                                  NULL,
                                                  56,
                                                  'Error: ' || perr
                                                 );
                                 RETURN (perr);
                           END;
                        ELSE
                           p_traza_proceso
                              (24,
                               'TRAZA_CESIONES_REA',
                               777,
                               'PAC_CESIONES',
                               'F_CESSIO',
                               NULL,
                               2,
                                  'Error: paso 9_16,
                     w_cestado:'
                               || w_cestado
                               || ' w_switchgarant:'
                               || w_switchgarant
                               || ' w_ifacced:'
                               || w_ifacced
                               || ' regaux1.icapital:'
                               || regaux1.icapital
                               || ' lcapaci_cum:'
                               || lcapaci_cum
                              );

                           -- 19484 cgesfac = 0-No generar QUADRE 1-Si generar QUADRE
                           IF pcgesfac = 1
                           THEN
                              p_traza_proceso
                                 (24,
                                  'TRAZA_CESIONES_REA',
                                  777,
                                  'PAC_CESIONES',
                                  'F_CESSIO',
                                  NULL,
                                  2,
                                     'Error: paso 9_17,
                     w_cestado:'
                                  || w_cestado
                                  || ' w_switchgarant:'
                                  || w_switchgarant
                                  || ' w_ifacced:'
                                  || w_ifacced
                                  || ' regaux1.icapital:'
                                  || regaux1.icapital
                                  || ' lcapaci_cum:'
                                  || lcapaci_cum
                                 );
                              cabfacul (regaux1);

                              IF perr <> 0 AND perr <> 99
                              THEN
                                 p_traza_proceso (w_cempres,
                                                  vpar_traza,
                                                  psproces,
                                                  v_nom_paquete,
                                                  v_nom_funcion,
                                                  NULL,
                                                  57,
                                                  'Error: ' || perr
                                                 );
                                 RETURN (perr);
                              END IF;

                              p_traza_proceso
                                 (24,
                                  'TRAZA_CESIONES_REA',
                                  777,
                                  'PAC_CESIONES',
                                  'F_CESSIO',
                                  NULL,
                                  2,
                                     'Error: paso 9_18,
                     w_cestado:'
                                  || w_cestado
                                  || ' w_switchgarant:'
                                  || w_switchgarant
                                  || ' w_ifacced:'
                                  || w_ifacced
                                  || ' regaux1.icapital:'
                                  || regaux1.icapital
                                  || ' lcapaci_cum:'
                                  || lcapaci_cum
                                 );
                              -- 19484 - AVT 02/01/2012
                              perr := 99;
                              p_traza_proceso (w_cempres,
                                               vpar_traza,
                                               psproces,
                                               v_nom_paquete,
                                               v_nom_funcion,
                                               NULL,
                                               58,
                                               'Error: ' || perr
                                              );
                           ELSE
                              p_traza_proceso
                                 (24,
                                  'TRAZA_CESIONES_REA',
                                  777,
                                  'PAC_CESIONES',
                                  'F_CESSIO',
                                  NULL,
                                  2,
                                     'Error: paso 9_19,
                     w_cestado:'
                                  || w_cestado
                                  || ' w_switchgarant:'
                                  || w_switchgarant
                                  || ' w_ifacced:'
                                  || w_ifacced
                                  || ' regaux1.icapital:'
                                  || regaux1.icapital
                                  || ' lcapaci_cum:'
                                  || lcapaci_cum
                                 );

                              --agg 15/04/2014
                              IF (ptablas = 'CAR' AND v_base_rea = 1)
                              THEN
                                 UPDATE cuafacul
                                    SET ifacced =
                                             regaux1.icapital
                                           - lcapaci_cum
             --BUG CONF-620  Fecha (01/03/2017) - HRE - Reaseguro moneda local
                                  WHERE sfacult = pfacult;

                                 perr := 0;
                              ELSE
                                 p_traza_proceso
                                    (24,
                                     'TRAZA_CESIONES_REA',
                                     777,
                                     'PAC_CESIONES',
                                     'F_CESSIO',
                                     NULL,
                                     2,
                                        'Error: paso 9_20,
                     w_cestado:'
                                     || w_cestado
                                     || ' w_switchgarant:'
                                     || w_switchgarant
                                     || ' w_ifacced:'
                                     || w_ifacced
                                     || ' regaux1.icapital:'
                                     || regaux1.icapital
                                     || ' lcapaci_cum:'
                                     || lcapaci_cum
                                    );
                                 perr := 99;
                                 p_traza_proceso (w_cempres,
                                                  vpar_traza,
                                                  psproces,
                                                  v_nom_paquete,
                                                  v_nom_funcion,
                                                  NULL,
                                                  59,
                                                  'Error: ' || perr
                                                 );
                                 EXIT;
                              END IF;
                           --fin agg 15/04/2014
                           END IF;
                        END IF;
                     ELSE
                        p_traza_proceso
                           (24,
                            'TRAZA_CESIONES_REA',
                            777,
                            'PAC_CESIONES',
                            'F_CESSIO',
                            NULL,
                            2,
                               'Error: paso 9_21,
                     w_cestado:'
                            || w_cestado
                            || ' w_switchgarant:'
                            || w_switchgarant
                            || ' w_ifacced:'
                            || w_ifacced
                            || ' regaux1.icapital:'
                            || regaux1.icapital
                            || ' lcapaci_cum:'
                            || lcapaci_cum
                           );

                        -------          a taula pendent...
                        -- 19484 cgesfac = 0-No generar QUADRE 1-Si generar QUADRE
                        IF pcgesfac = 1
                        THEN
                           cabfacul (regaux1);

                           IF perr <> 0 AND perr <> 99
                           THEN
                              p_traza_proceso (w_cempres,
                                               vpar_traza,
                                               psproces,
                                               v_nom_paquete,
                                               v_nom_funcion,
                                               NULL,
                                               60,
                                               'Error: ' || perr
                                              );
                              RETURN (perr);
                           END IF;

                           p_traza_proceso
                              (24,
                               'TRAZA_CESIONES_REA',
                               777,
                               'PAC_CESIONES',
                               'F_CESSIO',
                               NULL,
                               2,
                                  'Error: paso 9_22,
                     w_cestado:'
                               || w_cestado
                               || ' w_switchgarant:'
                               || w_switchgarant
                               || ' w_ifacced:'
                               || w_ifacced
                               || ' regaux1.icapital:'
                               || regaux1.icapital
                               || ' lcapaci_cum:'
                               || lcapaci_cum
                              );
                           -- 19484 - AVT 02/01/2012
                           perr := 99;
                           p_traza_proceso (w_cempres,
                                            vpar_traza,
                                            psproces,
                                            v_nom_paquete,
                                            v_nom_funcion,
                                            NULL,
                                            61,
                                            'Error: ' || perr
                                           );
                        ELSE
                           p_traza_proceso
                              (24,
                               'TRAZA_CESIONES_REA',
                               777,
                               'PAC_CESIONES',
                               'F_CESSIO',
                               NULL,
                               2,
                                  'Error: paso 9_23,
                     w_cestado:'
                               || w_cestado
                               || ' w_switchgarant:'
                               || w_switchgarant
                               || ' w_ifacced:'
                               || w_ifacced
                               || ' regaux1.icapital:'
                               || regaux1.icapital
                               || ' lcapaci_cum:'
                               || lcapaci_cum
                              );

                           --AGG 26/05/2014 Modificación para que no salte facultativo
                           --en la renovación de cartera para POSITIVA
                           IF (ptablas = 'CAR' AND v_base_rea = 1)
                           THEN
                              UPDATE cuafacul
                                 SET ifacced =
                                          regaux1.icapital
                                        - lcapaci_cum
             --BUG CONF-620  Fecha (01/03/2017) - HRE - Reaseguro moneda local
                               WHERE sfacult = pfacult;

                              perr := 0;
                           ELSE
                              p_traza_proceso
                                 (24,
                                  'TRAZA_CESIONES_REA',
                                  777,
                                  'PAC_CESIONES',
                                  'F_CESSIO',
                                  NULL,
                                  2,
                                     'Error: paso 9_24,
                     w_cestado:'
                                  || w_cestado
                                  || ' w_switchgarant:'
                                  || w_switchgarant
                                  || ' w_ifacced:'
                                  || w_ifacced
                                  || ' regaux1.icapital:'
                                  || regaux1.icapital
                                  || ' lcapaci_cum:'
                                  || lcapaci_cum
                                 );
                              perr := 99;
                              p_traza_proceso (w_cempres,
                                               vpar_traza,
                                               psproces,
                                               v_nom_paquete,
                                               v_nom_funcion,
                                               NULL,
                                               62,
                                               'Error: ' || perr
                                              );
                              EXIT;
                           END IF;
                        END IF;
                     END IF;
                  ELSE
                     ------        cessió...
                     BEGIN
                        UPDATE cesionesaux
                           SET cestado = 2,
                               sfacult = NULL
                         WHERE nnumlin = regaux1.nnumlin
                               AND sproces = psproces;
                     EXCEPTION
                        WHEN NO_DATA_FOUND
                        THEN
                           perr := 104695;
                           p_traza_proceso (w_cempres,
                                            vpar_traza,
                                            psproces,
                                            v_nom_paquete,
                                            v_nom_funcion,
                                            NULL,
                                            63,
                                            'Error: ' || perr
                                           );
                           RETURN (perr);
                        WHEN OTHERS
                        THEN
                           perr := 104696;
                           p_traza_proceso (w_cempres,
                                            vpar_traza,
                                            psproces,
                                            v_nom_paquete,
                                            v_nom_funcion,
                                            NULL,
                                            64,
                                            'Error: ' || perr
                                           );
                           RETURN (perr);
                     END;
                  END IF;
               END IF;
            ELSIF                      --BUG 21559 - INICIO - 23/05/2013 - DCT
                     NVL (pac_parametros.f_parproducto_n (w_sproduc,
                                                          'GAR_PRINCIPAL_REA'
                                                         ),
                          0
                         ) = 1
                 AND w_gar_princ <> regaux1.cgarant
            THEN                                         -- A les garanties no
               -- principals tb els hi actualitzem l'estat ............
               -->DBMS_OUTPUT.put_line('abans del UPDATE regaux1.cgarant:' || regaux1.cgarant);
               -- 21559 / 111590
               -- 22237 AVT 24/05/2012 PER SI TENIM ELS QUADRES JA COMPLERTS PER LA RESTA DE GARANTIES
               p_traza_proceso
                       (24,
                        'TRAZA_CESIONES_REA',
                        777,
                        'PAC_CESIONES',
                        'F_CESSIO',
                        NULL,
                        2,
                           'Error: paso 9_25,
                   w_cestado:'
                        || w_cestado
                        || ' w_switchgarant:'
                        || w_switchgarant
                        || ' w_ifacced:'
                        || w_ifacced
                        || ' regaux1.icapital:'
                        || regaux1.icapital
                        || ' lcapaci_cum:'
                        || lcapaci_cum
                       );

               IF w_fac_princ = 1
               THEN
                  ------        buscar facultatiu...
                  codi_error :=
                     f_facult (regaux1.sseguro,
                               regaux1.nriesgo,
                               regaux1.ccalif1,
                               regaux1.ccalif2,
                               regaux1.cgarant,
                               NULL,
                               NULL,
                               regaux1.fconini,
                               regaux1.scumulo,
                               pfdatagen,
                               w_trobat,
                               w_cestado,
                               pfacult,
                               w_ifacced
                              );

                  IF codi_error <> 0
                  THEN
                     p_traza_proceso (w_cempres,
                                      vpar_traza,
                                      psproces,
                                      v_nom_paquete,
                                      v_nom_funcion,
                                      NULL,
                                      65,
                                      'Error: ' || codi_error
                                     );
                     RETURN (codi_error);
                  END IF;

                  -->> AVT 21/01/2014  inici control dels facultatius existents en cas de cúmul
                  IF NVL (regaux1.scumulo, 0) > 0
                  THEN
                     BEGIN
                        SELECT COUNT (*)
                          INTO v_hiha_ces
                          FROM cesionesrea
                         WHERE sfacult = pfacult;
                     EXCEPTION
                        WHEN NO_DATA_FOUND
                        THEN
                           v_hiha_ces := 0;
                        WHEN OTHERS
                        THEN
                           v_hiha_ces := 0;
                           p_traza_proceso (w_cempres,
                                            vpar_traza,
                                            psproces,
                                            v_nom_paquete,
                                            v_nom_funcion,
                                            NULL,
                                            66,
                                            'Error facult ' || pfacult
                                           );
                           p_tab_error (f_sysdate,
                                        f_user,
                                        'f_cessio',
                                        1,
                                        'cesionesrea sfacult:' || pfacult,
                                        SQLCODE || ' - ' || SQLERRM
                                       );
                     END;
                  ELSE
                     v_hiha_ces := 0;
                  END IF;

                  -->> AVT 21/01/2014  fi
                  IF w_trobat = 1 AND v_hiha_ces = 0
                  THEN                                     -->> AVT 21/01/2014
                     IF w_cestado = 2
                     THEN
                        ------              cessió...
                        BEGIN
                           UPDATE cesionesaux
                              SET sfacult = pfacult
                            WHERE nnumlin = regaux1.nnumlin
                              AND sproces = psproces;
                        EXCEPTION
                           WHEN NO_DATA_FOUND
                           THEN
                              perr := 104695;
                              p_traza_proceso (w_cempres,
                                               vpar_traza,
                                               psproces,
                                               v_nom_paquete,
                                               v_nom_funcion,
                                               NULL,
                                               67,
                                               'Error: ' || perr
                                              );
                              RETURN (perr);
                           WHEN OTHERS
                           THEN
                              perr := 104696;
                              p_traza_proceso (w_cempres,
                                               vpar_traza,
                                               psproces,
                                               v_nom_paquete,
                                               v_nom_funcion,
                                               NULL,
                                               68,
                                               'Error: ' || perr
                                              );
                              RETURN (perr);
                        END;
                     ELSE
                        cabfacul (regaux1, ptablas);

                        IF perr <> 0 AND perr <> 99
                        THEN
                           RETURN (perr);
                           p_traza_proceso (w_cempres,
                                            vpar_traza,
                                            psproces,
                                            v_nom_paquete,
                                            v_nom_funcion,
                                            NULL,
                                            69,
                                            'Error: ' || perr
                                           );
                        END IF;

                        perr := 99;
                        p_traza_proceso (w_cempres,
                                         vpar_traza,
                                         psproces,
                                         v_nom_paquete,
                                         v_nom_funcion,
                                         NULL,
                                         70,
                                         'Error: ' || perr
                                        );
                     END IF;
                  ELSE
                     ------           a taula pendent...
                     cabfacul (regaux1, ptablas);

                     IF perr <> 0 AND perr <> 99
                     THEN
                        RETURN (perr);
                        p_traza_proceso (w_cempres,
                                         vpar_traza,
                                         psproces,
                                         v_nom_paquete,
                                         v_nom_funcion,
                                         NULL,
                                         71,
                                         'Error: ' || perr
                                        );
                     END IF;

                     perr := 99;      -- El perr 99 significa que ja no es pot
                     -- fer cap cessió perquè falta algún facultatiu
                     p_traza_proceso (w_cempres,
                                      vpar_traza,
                                      psproces,
                                      v_nom_paquete,
                                      v_nom_funcion,
                                      NULL,
                                      72,
                                      'Error: ' || perr
                                     );
                  END IF;
               END IF;

               -- 22237 AVT 24/05/2012 FI
               UPDATE cesionesaux
                  SET cestado = 3
                WHERE sproces = psproces
                  AND cgarant = regaux1.cgarant
                  AND nnumlin = regaux1.nnumlin;
            END IF;                     -- 21559 AVT 09/03/2012  fi-----------
         END IF;
      END LOOP;

      p_traza_proceso (24,
                       'TRAZA_CESIONES_REA',
                       777,
                       'PAC_CESIONES',
                       'F_CESIO',
                       NULL,
                       721,
                       'Error: paso 72_1'
                      );

------------------------------------------------------------------------
-- PART 7:
-- ******
-- AQUI ES FAN REALMENT LES CESSIONS I S'ESBORRA FACPENDIENTES SI HI HAVIA
-- QUELCOM...
-- SI ES UN SUPLEMENT (MOTIU = 04), PRIMER ES CRIDA A UNA FUNCIÓ
-- (F_ATRAS) QUE ANUL.LI LES ULTIMES CESSIONS CORRESPONENTS
-- A TOT EL SEGURO AFECTAT I CREI PARTS PRORRATEJADES EN SIGNE CONTRARI,
-- DESDE LA DATA DEL SUPLEMENT FINS AL VENCIMENT DEL SUPLEMENT...
--KBR 05/03/2014 Solo debe entrar si las tablas son las definitivas: REA
      IF ptablas NOT IN ('EST', 'CAR')
      THEN                       -- IGUALAR F_CESSIO / F_CESSIO_EST 28/10/2013
         p_traza_proceso (24,
                          'TRAZA_CESIONES_REA',
                          777,
                          'PAC_CESIONES',
                          'F_CESIO',
                          NULL,
                          722,
                          'Error: paso 72_2'
                         );

         IF perr <> 99
         THEN                                    -- No falta cap facultatiu...
            -- Obtenim el nº nmovigen
            BEGIN
               SELECT NVL (MAX (nmovigen), 0) + 1
                 INTO lnmovigen
                 FROM cesionesrea
                WHERE sseguro = w_sseguro;
            EXCEPTION
               WHEN OTHERS
               THEN
                  lnmovigen := 1;
            END;

            IF pmotiu = 04
            THEN                                         -- Es un suplement...
               IF (pcgesfac != -1)
               THEN
                  codi_error :=
                     f_atras (psproces,
                              w_sseguro,
                              w_fconini,
                              07,
                              pmoneda,
                              lnmovigen,
                              pfdatagen
                             );

                  IF codi_error <> 0
                  THEN
                     perr := codi_error;
                     p_traza_proceso (w_cempres,
                                      vpar_traza,
                                      psproces,
                                      v_nom_paquete,
                                      v_nom_funcion,
                                      NULL,
                                      73,
                                      'Error: ' || perr
                                     );
                     RETURN (perr);
                  END IF;
               END IF;
            END IF;

            FOR regaux1 IN cur_aux_1
            LOOP
               --BUG 21559 - INICIO - 23/05/2013 - DCT
               BEGIN                -- Busquem si prima prorratejable o no...
                  SELECT sproduc
                    INTO w_sproduc
                    FROM seguros
                   WHERE sseguro = regaux1.sseguro;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     perr := 101919;
                     p_traza_proceso (w_cempres,
                                      vpar_traza,
                                      psproces,
                                      v_nom_paquete,
                                      v_nom_funcion,
                                      NULL,
                                      74,
                                      'Error: ' || perr
                                     );
                     RETURN (perr);
               END;

               w_scumulo := regaux1.scumulo;           -- AVT 15007 17-06-2010

               -->DBMS_OUTPUT.put_line('regaux1.cestado:' || regaux1.cestado);
               IF regaux1.cestado = 2
               THEN
                  IF regaux1.cfacult <> 1
                  THEN                                      -- AVT 16-11-2011
                     -- bug: 14404 AVT 25-05-2010 una mateixa pòlissa pot tenir 2 ó més contractes de tipus diferent
                     BEGIN
                        SELECT ctiprea
                          INTO w_ctiprea               -- 13195 AVT 16-02-2010
                          FROM codicontratos
                         WHERE scontra = regaux1.scontra;
                     EXCEPTION
                        WHEN NO_DATA_FOUND
                        THEN
                           perr := 104697;
                           p_traza_proceso (w_cempres,
                                            vpar_traza,
                                            psproces,
                                            v_nom_paquete,
                                            v_nom_funcion,
                                            NULL,
                                            75,
                                            'Error: ' || perr
                                           );
                           RETURN (perr);
                        WHEN OTHERS
                        THEN
                           perr := 104516;
                           p_traza_proceso (w_cempres,
                                            vpar_traza,
                                            psproces,
                                            v_nom_paquete,
                                            v_nom_funcion,
                                            NULL,
                                            76,
                                            'Error: ' || perr
                                           );
                           RETURN (perr);
                     END;
                  END IF;

                  -- BUG 10462: ETM:16/06/2009:--ANTES
                  -- 13195 AVT 16-02-2010 afegim w_sproduc, w_ctipre a la crida a la funció F_CES
                  p_traza_proceso (w_cempres,
                                   vpar_traza,
                                   psproces,
                                   v_nom_paquete,
                                   v_nom_funcion,
                                   NULL,
                                   731,
                                   'Error 73_1: ' || perr
                                  );

                  IF (pcgesfac != -1)
                  THEN
                     codi_error :=
                        f_ces_qn (regaux1.nnumlin,
                                  pmotiu,
                                  regaux1.sfacult,
                                  lnmovigen,
                                  w_sproduc,
                                  w_ctiprea,
                                  w_ctipre_seg,
                                  psproces,
                                  v_base_rea,
                                  pfdatagen,
                                  ptablas
                                 );

                     IF codi_error <> 0
                     THEN
                        p_traza_proceso (w_cempres,
                                         vpar_traza,
                                         psproces,
                                         v_nom_paquete,
                                         v_nom_funcion,
                                         NULL,
                                         77,
                                         'Error: ' || codi_error
                                        );
                        RETURN (codi_error);
                     END IF;
                  END IF;

                  --           AQUI ES CANVIA EL CTIPREA DE 3 A 0, SI ERA 3...(SENSE FACULTATIU
                  --           OPCIONALMENT)...I DE 5 A 0...(SUPLEMENT AMB FACULTATIU QUE S'HA
                  --           TIRAT ENDAVANT)...
                  BEGIN
                     IF w_ctipre_seg = 3 OR w_ctipre_seg = 5
                     THEN
                        UPDATE seguros
                           SET ctiprea = 0
                         WHERE sseguro = regaux1.sseguro;
                     END IF;
                  EXCEPTION
                     WHEN OTHERS
                     THEN
                        perr := 105841;
                        p_traza_proceso (w_cempres,
                                         vpar_traza,
                                         psproces,
                                         v_nom_paquete,
                                         v_nom_funcion,
                                         NULL,
                                         78,
                                         'Error: ' || perr
                                        );
                        RETURN (perr);
                  END;
               END IF;

               -->DBMS_OUTPUT.put_line('>>>>>>>>>>>>>>>>>>>>>> w_cempres:' || w_cempres);

               -- 21559 AVT 09/03/2012 només reaprtim segons garantia principal --
               --BUG 21559 - INICIO - 23/05/2013 - DCT
               IF     NVL
                         (pac_parametros.f_parproducto_n (w_sproduc,
                                                          'GAR_PRINCIPAL_REA'
                                                         ),
                          0
                         ) = 1
                  AND w_gar_princ <> regaux1.cgarant
               THEN                                          -- 21559 / 111590
                  -->DBMS_OUTPUT.put_line('>>>>>>>>>>>>>>>>>>>>>>regaux1.cgarant:' || regaux1.cgarant
                  -->                  || ' regaux1.cestado:' || regaux1.cestado);
                  IF regaux1.cestado = 3
                  THEN
                     -->DBMS_OUTPUT.put_line('>>>>>>>>>>>>>>>>>>>>>>abans cursro:' || w_cramo || '-'
                     -->                  || w_cmodali || '-' || w_ctipseg || '-' || w_ccolect
                     -->               || '-' || w_cactivi || '-' || psproces);
                     FOR reg IN garantia_principal (w_gar_princ,
                                                    psproces,
                                                    regaux1.sseguro,
                                                    regaux1.nmovimi,
                                                    pmotiu
                                                   )
                     LOOP
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
                        w_capital :=
                             regaux1.icapital
                           * (  reg.icapces
                              / pac_eco_tipocambio.f_cambio (w_monpol,
                                                             w_moninst,
                                                             pfdatagen
                                                            )
                             )
             --BUG CONF-620  Fecha (01/03/2017) - HRE - Reaseguro moneda local
                           / w_capital_principal; -- 22666 - GAG  - 27/07/2012

                        IF reg.ctramo = 5
                        THEN
                           --perr := f_insert_ces(w_capital, reg.ctramo, regaux1.sfacult, 0,  -- 22666 - GAG  - 27/07/2012
                           --                     reg.pcesion / 100, w_sproduc);             -- 22666 - GAG  - 27/07/2012

                           --4773
                           perr :=
                              f_insert_ces
                                 (w_capital,
                                  reg.ctramo,
                                  regaux1.sfacult,
                                  0,              -- 22666 - GAG  - 27/07/2012
                                  NULL,
                                    (  reg.icapces
                                     / pac_eco_tipocambio.f_cambio (w_monpol,
                                                                    w_moninst,
                                                                    pfdatagen
                                                                   )
                                    )
             --BUG CONF-620  Fecha (01/03/2017) - HRE - Reaseguro moneda local
                                  / w_capital_principal,
                                  w_sproduc,
                                  registre,
                                  pmotiu,
                                  psproces,
                                  lnmovigen,
                                  v_tomador,
                                  w_tipper,
                            --BUG CONF-298  Fecha (23/03/2017) - HRE - Cumulos
                                  pcgesfac
                                 );               -- 22666 - GAG  - 27/07/2012
                           p_traza_proceso
                              (24,
                               'TRAZA_CESIONES_REA',
                               777,
                               'PAC_CESIONES',
                               'F_CES_QN',
                               NULL,
                               2,
                                  'FEPP95: paso 1,
                                  v_tomador: '
                               || v_tomador
                               || ' psproces:'
                               || psproces
                               || ' w_sproduc:'
                               || w_sproduc
                               || ' reg.ctramo:'
                               || reg.ctramo
                               || ' w_sseguro:'
                               || w_sseguro
                              );
                        ELSE
                           --perr := f_insert_ces(w_capital, reg.ctramo, NULL, 0, reg.pcesion  -- 22666 - GAG  - 27/07/2012
                           --/  100, w_sproduc);                      -- 22666 - GAG  - 27/07/2012
                           perr :=
                              f_insert_ces
                                 (w_capital,
                                  reg.ctramo,
                                  NULL,
                                  0,              -- 22666 - GAG  - 27/07/2012
                                  NULL,
                                    (  reg.icapces
                                     / pac_eco_tipocambio.f_cambio (w_monpol,
                                                                    w_moninst,
                                                                    pfdatagen
                                                                   )
                                    )
             --BUG CONF-620  Fecha (01/03/2017) - HRE - Reaseguro moneda local
                                  / w_capital_principal,
                                  w_sproduc,
                                  registre,
                                  pmotiu,
                                  psproces,
                                  lnmovigen,
                                  v_tomador,
                                  w_tipper,
                            --BUG CONF-298  Fecha (23/03/2017) - HRE - Cumulos
                                  pcgesfac
                                 );               -- 22666 - GAG  - 27/07/2012
                           p_traza_proceso
                              (24,
                               'TRAZA_CESIONES_REA',
                               777,
                               'PAC_CESIONES',
                               'F_CES_QN',
                               NULL,
                               2,
                                  'FEPP96: paso 1,
                                  v_tomador: '
                               || v_tomador
                               || ' psproces:'
                               || psproces
                               || ' w_sproduc:'
                               || w_sproduc
                               || ' reg.ctramo:'
                               || reg.ctramo
                               || ' w_sseguro:'
                               || w_sseguro
                              );
                        END IF;

                        IF perr <> 0
                        THEN
                           p_traza_proceso (w_cempres,
                                            vpar_traza,
                                            psproces,
                                            v_nom_paquete,
                                            v_nom_funcion,
                                            NULL,
                                            79,
                                            'Error: ' || perr
                                           );
                           RETURN (perr);
                        END IF;
                     END LOOP;
                  END IF;
               END IF;                   -- 21559 AVT 09/03/2012 -------------
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
      END IF;

---------------------------------
-- PART 8:
-- ******
-- AIXO ES EL FINAL...
--IF perr = 0          -- 9. 20606: LCOL_T004-LCOL_T001- Recalcul de les cessions - Nota:0101205
--   OR perr = 99 THEN -- 9. 20606: LCOL_T004-LCOL_T001- Recalcul de les cessions - Nota:0101205
--BUG 32363 - DCT - 25/07/2014
      p_traza_proceso (24,
                       'TRAZA_CESIONES_REA',
                       777,
                       'PAC_CESIONES',
                       'F_CESIO',
                       NULL,
                       723,
                       'Error: paso 72_3'
                      );

      IF NVL (pcgesfac, 0) = 0 AND ptablas = 'EST'
      THEN
         BEGIN
            --BUG 0036059 - DCT - 02/09/2015. Borramos reariesgos que no esten tambie´n en la tabla cesionesaux
            --BUG 18981 JRB -
            DELETE FROM reariesgos r
                  WHERE r.sseguro = w_sseguro
                    AND NOT EXISTS (
                           SELECT 1
                             FROM cesionesrea c
                            WHERE c.sseguro = r.sseguro
                              AND c.scumulo = r.scumulo
                           UNION
                           SELECT 1
                             FROM cesionesaux c2
                            WHERE c2.sseguro = r.sseguro
                              AND c2.scumulo = r.scumulo);
         -- AVT 05/12/2013 evitar deje registros en reariesgos
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               p_traza_proceso (w_cempres,
                                vpar_traza,
                                psproces,
                                v_nom_paquete,
                                v_nom_funcion,
                                NULL,
                                80,
                                'Error no_data_found: ' || perr
                               );
            WHEN OTHERS
            THEN
               perr := 104666;
               p_traza_proceso (w_cempres,
                                vpar_traza,
                                psproces,
                                v_nom_paquete,
                                v_nom_funcion,
                                NULL,
                                80,
                                'Error: ' || perr
                               );
               RETURN (perr);
         END;
      END IF;

      BEGIN
         DELETE FROM cesionesaux
               WHERE sproces = psproces;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            NULL;
         WHEN OTHERS
         THEN
            perr := 104703;
            p_traza_proceso (w_cempres,
                             vpar_traza,
                             psproces,
                             v_nom_paquete,
                             v_nom_funcion,
                             NULL,
                             81,
                             'Error: ' || perr
                            );
            RETURN (perr);
      END;

      -- END IF;

      -- 15007 AVT 17-06-2010 En cas de suplement d'una pòlissa amb cúmul recalculem la resta de pòlisses --
      --KBR 05/03/2014 Solo debe entrar si las tablas son las definitivas: REA
      p_traza_proceso (24,
                       'TRAZA_CESIONES_REA',
                       777,
                       'PAC_CESIONES',
                       'F_CESIO',
                       NULL,
                       724,
                       'Error: paso 72_4'
                      );

      IF ptablas NOT IN ('EST', 'CAR')
      THEN                       -- IGUALAR F_CESSIO / F_CESSIO_EST 28/10/2013
         p_traza_proceso (24,
                          'TRAZA_CESIONES_REA',
                          777,
                          'PAC_CESIONES',
                          'F_CESIO',
                          NULL,
                          725,
                          'Error: paso 72_5'
                         );

         IF     perr =
                   0
     -- 9. 20606: LCOL_T004-LCOL_T001- Recalcul de les cessions - Nota:0101205
            AND pmotiu = 04
            AND w_scumulo IS NOT NULL
            AND NVL (pfacult, 0) = 0
         THEN
         -- 19484 AVT 04/01/2012 Només recosntruirem la resta de cessions sinó
            -- necessita quadre facultatiu
            --BUG 19484 - 19/10/2011 - JRB - Se añade la empresa por parámetro.
            SELECT cempres
              INTO w_cempres
              FROM seguros seg
             WHERE seg.sseguro = w_sseguro;

            --codi_error            := pac_cesionesrea.f_recalcula_cumul(w_sseguro, w_fconini, psproces, w_cempres);
            IF codi_error <> 0
            THEN
               perr := codi_error;
               p_traza_proceso (w_cempres,
                                vpar_traza,
                                psproces,
                                v_nom_paquete,
                                v_nom_funcion,
                                NULL,
                                82,
                                'Error: ' || perr
                               );
               RETURN (perr);
            ELSE
               BEGIN
                  DELETE FROM cesionesaux
                        WHERE sproces = psproces;
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     NULL;
                  WHEN OTHERS
                  THEN
                     perr := 104703;
                     p_traza_proceso (w_cempres,
                                      vpar_traza,
                                      psproces,
                                      v_nom_paquete,
                                      v_nom_funcion,
                                      NULL,
                                      83,
                                      'Error: ' || perr
                                     );
                     RETURN (perr);
               END;
            END IF;
         END IF;

         -- BUG: 22686 - AVT -25/07/2012 es dona de baixa la pòlissa que tot i formar part del cúmul ja està anulada
         IF     perr = 0
            AND pmotiu IN (03, 05)
            AND w_scumulo IS NOT NULL
            AND NVL (pfacult, 0) = 0
         THEN
            -- es busquen pòlisses del cúmul anul·lades
            FOR reg IN riesgos_anul (w_scumulo)
            LOOP
               codi_error :=
                  pac_anulacion.f_baja_rea (reg.sseguro, reg.fanulac,
                                            pmoneda);

               IF codi_error <> 0
               THEN
                  perr := codi_error;
                  p_traza_proceso (w_cempres,
                                   vpar_traza,
                                   psproces,
                                   v_nom_paquete,
                                   v_nom_funcion,
                                   NULL,
                                   84,
                                   'Error: ' || perr
                                  );
                  p_tab_error (f_sysdate,
                               f_user,
                               'f_cessio',
                               1,
                                  'pac_anulacion.f_baja_rea:'
                               || reg.sseguro
                               || ' - '
                               || reg.fanulac
                               || ' - '
                               || pmoneda,
                               codi_error
                              );
                  RETURN (perr);
               END IF;
            END LOOP;
         END IF;
      END IF;

      -- BUG: 22686 - AVT -25/07/2012  fi -------------------------
      ----dbms_outpuT.put_line('ffacult:' || perr);
      p_traza_proceso (w_cempres,
                       vpar_traza,
                       psproces,
                       v_nom_paquete,
                       v_nom_funcion,
                       NULL,
                       85,
                       'Error: ' || perr
                      );
      RETURN (perr);
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                         'final F_Cessio_est ='
                      || psproces
                      || '  w_sseguro:'
                      || w_sseguro,
                      NULL,
                      SUBSTR ('error incontrolado', 1, 500),
                      SQLERRM
                     );
         RETURN (perr);
   END f_cessio;
   
   --INI IAXIS BUG 13246 AABG: Funcion para calcular el facultativo  
 FUNCTION f_obtener_fac(
   psseguro IN NUMBER,
   pnversio IN NUMBER,
   pmotiu IN NUMBER,
   psproduc IN NUMBER,
   pscontra IN NUMBER,
   ppcapces_out IN OUT NUMBER
 )
 RETURN NUMBER IS
     vobjectname VARCHAR2(500)         := 'PAC_CESIONES.f_obtener_fac';
     vparam      VARCHAR2(500)          := 'pmotiu:'||pmotiu||' ,psproduc:'||psproduc||' ,pscontra:'||pscontra ||' ,psseguro:'||psseguro ||' ,pnversio:'||pnversio
                                                 ||' ,ppcapces_out:'||ppcapces_out;
     v_traza     NUMBER :=0; 
     
     v_existe_facult NUMBER := 0;
     
     BEGIN    
        IF (pmotiu = 4 AND NVL(pac_parametros.f_parcontrato_n(pscontra, 'REA_MANTIENE_SUPL', psproduc),0) = 1) THEN
            SELECT COUNT(*) INTO v_existe_facult
               FROM cesionesrea c
              WHERE c.sseguro = psseguro
                AND c.scontra = pscontra
                AND c.nversio = pnversio
                AND c.ctramo = 5
                AND c.nmovigen = (SELECT MAX(cr.nmovigen) FROM cesionesrea cr WHERE cr.sseguro = psseguro AND cr.cgenera = 4 and cr.ctipomov = 'M')                                                           
             ORDER BY scesrea DESC;
             
             IF v_existe_facult > 0 THEN
                SELECT IFACCED INTO ppcapces_out  FROM CUAFACUL WHERE SSEGURO = psseguro AND FFINCUF IS NULL;
             END IF;
        END IF;       
        RETURN 0;
     EXCEPTION WHEN OTHERS THEN
      p_tab_error (f_sysdate, f_user, vobjectname, v_traza, vparam, 'ERROR: ' || SQLCODE || ' - ' || SQLERRM );
      RETURN -99;
 
 END f_obtener_fac;
 --FIN IAXIS BUG 13246 AABG: Funcion para calcular el facultativo
 
 --INI IAXIS BUG 13246 AABG: Funcion para validar el facultativo  
 FUNCTION f_existe_fac(
   psseguro IN NUMBER,
   pnversio IN NUMBER,
   pmotiu IN NUMBER,
   psproduc IN NUMBER,
   pscontra IN NUMBER,
   p_respuesta OUT NUMBER
 )
 RETURN NUMBER IS
     vobjectname VARCHAR2(500)         := 'PAC_CESIONES.f_existe_fac';
     vparam      VARCHAR2(500)          := 'pmotiu:'||pmotiu||' ,psproduc:'||psproduc||' ,pscontra:'||pscontra ||' ,psseguro:'||psseguro ||' ,pnversio:'||pnversio
                                                 ||' ,p_respuesta:'||p_respuesta;
     v_traza     NUMBER :=0; 
     
     v_existe_facult NUMBER := 0;
     v_seg_original NUMBER;
     
     BEGIN
     p_respuesta := 0;
        IF (pmotiu = 4 AND NVL(pac_parametros.f_parcontrato_n(pscontra, 'REA_MANTIENE_SUPL', psproduc),0) = 1) THEN
        
        BEGIN
            SELECT ssegpol INTO v_seg_original FROM estseguros WHERE sseguro = psseguro;
        EXCEPTION WHEN NO_DATA_FOUND THEN
            v_seg_original := psseguro;
        END;        
        
        SELECT COUNT(*) INTO v_existe_facult
           FROM cesionesrea c
          WHERE c.sseguro = v_seg_original
            AND c.scontra = pscontra
            AND c.nversio = pnversio
            AND c.ctramo = 5
            AND c.nmovigen = (SELECT MAX(cr.nmovigen) FROM cesionesrea cr WHERE cr.sseguro = v_seg_original AND cr.cgenera = 4 and cr.ctipomov = 'M')                                                           
         ORDER BY scesrea DESC;
             IF v_existe_facult > 0 THEN
                p_respuesta := v_existe_facult;
             END IF;
        END IF;         
        RETURN 0;
     EXCEPTION WHEN OTHERS THEN
      p_tab_error (f_sysdate, f_user, vobjectname, v_traza, vparam, 'ERROR: ' || SQLCODE || ' - ' || SQLERRM );
      RETURN -99;
 
 END f_existe_fac;
 --FIN IAXIS BUG 13246 AABG: Funcion para validar el facultativo  
   
END pac_cesiones;