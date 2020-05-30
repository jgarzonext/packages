--------------------------------------------------------
--  DDL for Package Body PAC_PLAN_CONTAB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_PLAN_CONTAB" AS
---------------------------------------------------------------------------------------------------------------------------
FUNCTION f_plan_contab(pcempres IN NUMBER, ppath IN VARCHAR2 ,pfecha IN DATE, pcidioma IN NUMBER ) RETURN NUMBER IS
---------------------------------------------------------------------------------------------------------------------------
-- Crida a totes les plantilles
---------------------------------------------------------------------------------------------------------------------------
num_err NUMBER;
ltfitxer VARCHAR2(50);
BEGIN
   ltfitxer := 'PLAN_REC_EMI_'||TO_CHAR(pfecha,'mm_yyyy')||'.TXT';
   num_err := f_recibos_emitidos (pcempres , ppath ,ltfitxer, pfecha , pcidioma   );
   IF num_err = 0 THEN
      ltfitxer := 'PLAN_REC_COB_'||TO_CHAR(pfecha,'mm_yyyy')||'.TXT';
      num_err := f_recibos_cobrados(pcempres , ppath ,ltfitxer , pfecha  , pcidioma  );
      IF num_err = 0 THEN
         ltfitxer := 'PLAN_REC_PEN_'||TO_CHAR(pfecha,'mm_yyyy')||'.TXT';
         num_err := f_recibos_pendientes(pcempres , ppath ,ltfitxer , pfecha, pcidioma   );
         IF num_err = 0 THEN
            ltfitxer := 'PLAN_REC_EXT_'||TO_CHAR(pfecha,'mm_yyyy')||'.TXT';
            num_err := f_recibos_extornados (pcempres , ppath ,ltfitxer, pfecha , pcidioma );
            IF num_err = 0 THEN
               ltfitxer := 'PLAN_REC_ANU_'||TO_CHAR(pfecha,'mm_yyyy')||'.TXT';
               num_err := f_recibos_anulados (pcempres , ppath  ,ltfitxer , pfecha   ,pcidioma);
               IF num_Err = 0 THEN
                  ltfitxer := 'PLAN_SALDOS_'||TO_CHAR(pfecha,'mm_yyyy')||'.TXT';
                  num_err := f_saldos (ppath  ,ltfitxer , pfecha   ,pcidioma);
                  IF num_Err = 0 THEN
                     ltfitxer := 'RETENCIONES_'||TO_CHAR(pfecha,'mm_yyyy')||'.TXT';
                     num_err := f_retenciones (ppath  ,ltfitxer , pfecha   ,pcidioma);
                  END IF;
               END IF;
            END IF;
         END IF;
      END IF;
   END IF;
   RETURN num_err;
END f_plan_contab;
---------------------------------------------------------------------------------------------------------------------------
FUNCTION f_recibos_emitidos (pcempres IN NUMBER, ppath IN VARCHAR2 ,ptfitxer IN VARCHAR2,
                             pfecha IN DATE, pcidioma IN NUMBER ) RETURN NUMBER IS
---------------------------------------------------------------------------------------------------------------------------
-- Plantilla de recibos emitidos. Se obtienen los datos de meritación, vdetrecibos y
-- ctaseguro (comisiones de ahorro)
-- Es mira els signe pq les anul.lacions sense efecte estan en les mateixes columnes
-- però amb signe negatiu
---------------------------------------------------------------------------------------------------------------------------
   fitxer      UTL_FILE.file_type;
   linia       VARCHAR2(300);
   CURSOR c_emi (wcempres NUMBER, wfecha DATE, wcidioma NUMBER) IS
      SELECT producte,
             SUM(prima_neta  ) prima_neta,
             SUM(ips         ) ips,
             SUM(iconsor     ) iconsor,
             SUM(comis       ) comis,
             SUM(prima_bruta ) prima_bruta
      FROM
      (
         SELECT NVL(d.tvalpar,'ALTRES') producte,
                --m.cramo, m.cmodali, m.ctipseg, m.ccolect,
                SUM(
                    DECODE(SIGN(m.prima_meritada)     ,0,0,1, v.iprinet )+
                    DECODE(SIGN(m.prima_meritada_cia) ,0,0,1, v.iprinet)
                                                                         ) prima_neta,
                SUM(
                    DECODE(SIGN(m.prima_meritada     ),0,0,1,   v.iips)+
                    DECODE(SIGN(m.prima_meritada_cia ),0,0,1,   v.iips)
                                                                         ) ips,
                SUM(
                    DECODE(SIGN(m.prima_meritada     ),0,0,1,   v.iconsor)+
                    DECODE(SIGN(m.prima_meritada_cia ),0,0,1,   v.iconsor)
                                                                         ) iconsor,
               SUM( DECODE(SIGN(m.comis_meritada_agen     ),0,0,1, m.comis_meritada_agen     )+
                    DECODE(SIGN(m.comis_meritada_cia_agen ),0,0,1, m.comis_meritada_cia_agen )
                                                                          ) comis,
                SUM(DECODE(SIGN(m.prima_meritada      ),0,0,1,m.prima_meritada       )+
                    DECODE(SIGN(m.prima_meritada_cia  ),0,0,1,m.prima_meritada_cia   )
                                                                          ) Prima_bruta
         FROM MERITACION m,  VDETRECIBOS v, PRODUCTOS p, PARPRODUCTOS n, DETPARPRO d
         WHERE m.cempres = wcempres
           AND m.fcierre = wfecha
           AND m.nrecibo = v.nrecibo
           AND m.cramo   = p.cramo
           AND m.cmodali = p.cmodali
           AND m.ctipseg = p.ctipseg
           AND m.ccolect = p.ccolect
           AND p.sproduc = n.sproduc (+)
           AND n.cparpro (+) = 'NOMBRE'
           AND n.cparpro     = d.cparpro (+)
           AND n.cvalpar     = d.cvalpar (+)
           AND d.cidioma (+) = wcidioma
         GROUP BY NVL(d.tvalpar,'ALTRES')
      UNION
         SELECT NVL(d.tvalpar,'ALTRES') producte,
                0 prima_neta,
                0 ips,
                0 iconsor,
                SUM(imovimi) comis,
                0 prima_bruta
         FROM SEGUROS s, CTASEGURO c, PARPRODUCTOS p, DETPARPRO d
         WHERE s.sseguro = c.sseguro
           AND s.sproduc = p.sproduc (+)
           AND p.cparpro (+) = 'NOMBRE'
           AND fvalmov >= wfecha
           AND fvalmov < wfecha + 1
           AND c.cmovimi =29
           AND s.cramo LIKE '%'
           AND s.cmodali LIKE '%'
           AND s.ctipseg LIKE '%'
           AND s.ccolect  LIKE '%'
           AND p.cparpro     = d.cparpro (+)
           AND p.cvalpar     = d.cvalpar (+)
           AND d.cidioma (+) = wcidioma
         GROUP BY NVL(d.tvalpar,'ALTRES')
   )
   GROUP BY producte;
BEGIN
   fitxer := utl_file.fopen (ppath, ptfitxer, 'w');
   linia := 'PRODUCTO;PRIMA_NETA;IPS;ICONSORCIO;COMISION;PRIMA_BRUTA';
   UTL_FILE.Put_Line(fitxer, linia);
   FOR v_emi IN c_emi (pcempres, pfecha, pcidioma) LOOP
      linia := RTRIM(v_emi.producte)||';'||v_emi.prima_neta||';'||v_emi.ips||';'||v_emi.iconsor||';'||v_emi.comis
               ||';'||v_emi.prima_bruta;
      UTL_FILE.Put_Line(fitxer, linia);
   END LOOP;
   UTL_FILE.fclose(fitxer);
   RETURN 0;
EXCEPTION
   WHEN OTHERS THEN
      DBMS_OUTPUT.put_line(SQLERRM);
      RETURN 107914;
END f_recibos_emitidos;
---------------------------------------------------------------------------------------------------------------------------
FUNCTION f_recibos_cobrados(pcempres IN NUMBER, ppath IN VARCHAR2 ,ptfitxer IN VARCHAR2,
                            pfecha IN DATE, pcidioma IN NUMBER ) RETURN NUMBER IS
---------------------------------------------------------------------------------------------------------------------------
-- Plantilla de recibos cobrados. Se obtienen los datos de cuadre_cc
---------------------------------------------------------------------------------------------------------------------------
   fitxer      UTL_FILE.file_type;
   linia       VARCHAR2(300);
   CURSOR c_cob (wcempres NUMBER, wfecha DATE, wcidioma NUMBER) IS
      SELECT NVL(d.tvalpar, 'ALTRES') producte, SUM(c.itotalr) prima_cobrada
      FROM CUADRE_CC c, PARPRODUCTOS p, DETPARPRO d
      WHERE c.cempres = wcempres
        AND c.fcierre = wfecha
        AND c.sproduc = p.sproduc (+)
        AND p.cparpro (+) = 'NOMBRE'
        AND p.cparpro = d.cparpro (+)
        AND p.cvalpar = d.cvalpar (+)
        AND d.cidioma (+) = wcidioma
      GROUP BY NVL(d.tvalpar, 'ALTRES');
BEGIN
   fitxer := utl_file.fopen (ppath, ptfitxer, 'w');
   linia := 'PRODUCTO;TOTAL_RECIBO';
   UTL_FILE.Put_Line(fitxer, linia);
   FOR v_cob IN c_cob(pcempres, pfecha, pcidioma) LOOP
      linia := RTRIM(v_cob.producte)||';'||v_cob.prima_cobrada;
      UTL_FILE.Put_Line(fitxer, linia);
   END LOOP;
   UTL_FILE.fclose(fitxer);
   RETURN 0;
EXCEPTION
   WHEN OTHERS THEN
      DBMS_OUTPUT.put_line(SQLERRM);
      RETURN 107914;
END f_recibos_cobrados;
---------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------
/*FUNCTION f_recibos_pendientes(pcempres IN NUMBER, ppath IN VARCHAR2 ,ptfitxer IN VARCHAR2,
                              pfecha IN DATE , pcidioma IN NUMBER) RETURN NUMBER IS
---------------------------------------------------------------------------------------------------------------------------
-- Plantilla de recibos pendientes. Se obtienen los datos de recibos por situación y
-- por periodo de venta
---------------------------------------------------------------------------------------------------------------------------
   fitxer      UTL_FILE.file_type;
   linia       VARCHAR2(300);
   CURSOR c_pen (wcempres NUMBER, wfecha DATE, wcidioma NUMBER) IS
      SELECT NVL(d.tvalpar, 'ALTRES') producte,
            SUM(DECODE(r.ctiprec,9,-1,1) * DECODE(nperven, TO_CHAR(wfecha,'yyyymm'),itotalr,0)) prima_pend_periodo,
            SUM(DECODE(r.ctiprec,9,-1,1) * DECODE(nperven, TO_CHAR(wfecha,'yyyymm'),0,itotalr)) prima_periodo_ant
      FROM movrecibo  m, recibos r, vdetrecibos v,seguros s, parproductos p, detparpro d
      WHERE r.cempres = wcempres
        AND r.nrecibo = m.nrecibo
        AND r.sseguro = s.sseguro
        AND m.fmovini <= wfecha
        AND (m.fmovfin > wfecha OR m.fmovfin IS NULL)
        AND r.nrecibo = v.nrecibo
        AND m.cestrec = 0
        AND s.cramo like '%'
        AND s.cmodali like '%'
        AND s.ctipseg like '%'
        AND s.ccolect like '%'
        AND r.nperven <= TO_CHAR(wfecha,'yyyymm')
        AND s.sproduc = p.sproduc (+)
        AND p.cparpro (+) = 'NOMBRE'
        AND p.cparpro = d.cparpro (+)
        AND p.cvalpar = d.cvalpar (+)
      GROUP BY NVL(d.tvalpar, 'ALTRES');
BEGIN
   fitxer := utl_file.fopen (ppath, ptfitxer, 'w');
   linia := 'PRODUCTO;PRIMA_DEL_PERIODO;PRIMA_PERIODOS_ANT';
   UTL_FILE.Put_Line(fitxer, linia);
   FOR v_pen IN c_pen(pcempres, pfecha, pcidioma) LOOP
      linia := RTRIM(v_pen.producte)||';'||v_pen.prima_pend_periodo
                    ||';'||v_pen.prima_periodo_ant;
      UTL_FILE.Put_Line(fitxer, linia);
   END LOOP;
   UTL_FILE.fclose(fitxer);
   RETURN 0;
EXCEPTION
   WHEN OTHERS THEN
      DBMS_OUTPUT.put_line(SQLERRM);
      RETURN 107914;
END f_recibos_pendientes;
*/
---------------------------------------------------------------------------------------------------------------------------
FUNCTION f_recibos_pendientes(pcempres IN NUMBER, ppath IN VARCHAR2 ,ptfitxer IN VARCHAR2,
                              pfecha IN DATE , pcidioma IN NUMBER) RETURN NUMBER IS
---------------------------------------------------------------------------------------------------------------------------
-- Plantilla de recibos pendientes. Se obtienen los datos de recibos por situación y
-- por periodo de venta
---------------------------------------------------------------------------------------------------------------------------
   fitxer      UTL_FILE.file_type;
   linia       VARCHAR2(300);
   litotalr    NUMBER;
   lprima_periode_act NUMBER;
   lprima_periode_ant NUMBER;
   CURSOR c_agr ( wcidioma NUMBER) IS
      SELECT DISTINCT NVL(d.tvalpar,'ALTRES') producte
      FROM PRODUCTOS p, PARPRODUCTOS t, DETPARPRO d
      WHERE p.sproduc = t.sproduc (+)
        AND t.cparpro (+) = 'NOMBRE'
        AND t.cparpro = d.cparpro (+)
        AND t.cvalpar = d.cvalpar (+)
        AND d.cidioma (+)= wcidioma;
    CURSOR c_prods ( wcidioma NUMBER, wproducte VARCHAR2) IS
       SELECT p.cramo, p.cmodali, p.ctipseg, p.ccolect
       FROM PRODUCTOS p, PARPRODUCTOS t, DETPARPRO d
       WHERE p.sproduc = t.sproduc (+)
         AND t.cparpro (+) = 'NOMBRE'
         AND t.cparpro = d.cparpro (+)
         AND t.cvalpar = d.cvalpar (+)
         AND d.cidioma (+)= wcidioma
         AND NVL(d.tvalpar,'ALTRES') = wproducte;
   CURSOR c_pen (wcramo NUMBER,wcmodali NUMBER, wctipseg NUMBER, wccolect NUMBER,
                 wfecha DATE) IS
      SELECT r.nrecibo,DECODE(r.ctiprec,9,-1,1) signe ,nperven
      FROM MOVRECIBO  m, RECIBOS r,SEGUROS s
      WHERE r.nrecibo = m.nrecibo
        AND r.sseguro = s.sseguro
        AND m.fmovini <= wfecha
        AND (m.fmovfin > wfecha OR m.fmovfin IS NULL)
        AND m.cestrec = 0
        AND s.cramo   = wcramo
        AND s.cmodali = wcmodali
        AND s.ctipseg = wctipseg
        AND s.ccolect = wccolect
        AND r.nperven <= TO_CHAR(wfecha,'yyyymm');
BEGIN
   fitxer := utl_file.fopen (ppath, ptfitxer, 'w');
   linia := 'PRODUCTO;PRIMA_DEL_PERIODO;PRIMA_PERIODOS_ANT';
   UTL_FILE.Put_Line(fitxer, linia);
   FOR v_agr IN c_agr (pcidioma) LOOP
      lprima_periode_act := 0;
      lprima_periode_ant := 0;
      FOR v_prod IN c_prods (pcidioma, v_agr.producte) LOOP
         FOR v_pen IN c_pen(v_prod.cramo, v_prod.cmodali, v_prod.ctipseg,v_prod.ccolect, pfecha) LOOP
            SELECT NVL(itotalr,0) INTO litotalr
            FROM VDETRECIBOS
            WHERE nrecibo = v_pen.nrecibo;
            IF v_pen.nperven = TO_CHAR(pfecha,'yyyymm') THEN
              lprima_periode_act := lprima_periode_act + (litotalr * v_pen.signe);
            ELSE
               lprima_periode_ant := lprima_periode_ant + (litotalr * v_pen.signe);
            END IF;
         END LOOP;
      END LOOP;
      IF lprima_periode_act <>0 OR lprima_periode_ant <>0 THEN
         linia := RTRIM(v_agr.producte)||';'||lprima_periode_act
                     ||';'||lprima_periode_ant;
         UTL_FILE.Put_Line(fitxer, linia);
      END IF;
   END LOOP;
   UTL_FILE.fclose(fitxer);
   RETURN 0;
EXCEPTION
   WHEN OTHERS THEN
      DBMS_OUTPUT.put_line(SQLERRM);
      RETURN 107914;
END f_recibos_pendientes;
---------------------------------------------------------------------------------------------------------------------------
FUNCTION f_recibos_extornados (pcempres IN NUMBER, ppath IN VARCHAR2 ,ptfitxer IN VARCHAR2,
                               pfecha IN DATE, pcidioma IN NUMBER) RETURN NUMBER IS
   fitxer      UTL_FILE.file_type;
   linia       VARCHAR2(300);
   CURSOR c_ext (wcempres NUMBER, wfecha DATE, wcidioma NUMBER) IS
         SELECT NVL(d.tvalpar, 'ALTRES') producte,
                SUM(DECODE(TO_CHAR(m.fefecto,'yyyymm'),m.nperven,
                                   (SIGN(m.prima_extornada      )* v.iprinet+
                                    SIGN(m.prima_extornada_cia  )* v.iprinet+
                                    SIGN(m.prima_extorn_anul    )* - v.iprinet+
                                    SIGN(m.prima_extorn_anul_cia)* - v.iprinet),
                            0 )                                            ) ext_peract,
                SUM(DECODE(TO_CHAR(m.fefecto,'yyyymm'),m.nperven,
                                   (SIGN(m.prima_extornada       )* v.iips+
                                    SIGN(m.prima_extornada_cia   )* v.iips+
                                    SIGN(m.prima_extorn_anul     )* - v.iips+
                                    SIGN(m.prima_extorn_anul_cia )* - v.iips),
                            0)                                             ) ips_peract,
                SUM(DECODE(TO_CHAR(m.fefecto,'yyyymm'),m.nperven,
                                   (SIGN(m.prima_extornada       )* v.iconsor+
                                    SIGN(m.prima_extornada_cia   )* v.iconsor+
                                    SIGN(m.prima_extorn_anul     )* - v.iconsor+
                                    SIGN(m.prima_extorn_anul_cia )* - v.iconsor),
                           0)                                              ) iconsor_peract,
               SUM(DECODE(TO_CHAR(m.fefecto,'yyyymm'),m.nperven,
                                 ( DECODE(m.comis_extornada_agen      ,0,0,m.comis_extornada_agen      )+
                                   DECODE(m.comis_extornada_cia_agen  ,0,0,m.comis_extornada_cia_agen  )+
                                   DECODE(m.comis_extorn_anul_agen    ,0,0,-m.comis_extorn_anul_agen    )+
                                   DECODE(m.comis_extorn_anul_cia_agen,0,0,-m.comis_extorn_anul_cia_agen) ),
                          0)                                                ) comis_peract,
                SUM(DECODE(TO_CHAR(m.fefecto,'yyyymm'),m.nperven,
                                   (DECODE(m.prima_extornada      ,0,0,   m.prima_extornada       )+
                                    DECODE(m.prima_extornada_cia  ,0,0, + m.prima_extornada_cia   )+
                                    DECODE(m.prima_extorn_anul    ,0,0, - m.prima_extorn_anul     )+
                                    DECODE(m.prima_extorn_anul_cia,0,0, - m.prima_extorn_anul_cia )) ,
                          0)                          ) bruta_peract,
                SUM(DECODE(TO_CHAR(m.fefecto,'yyyymm'),m.nperven, 0,
                                   (SIGN(m.prima_extornada      ) * v.iprinet+
                                    SIGN(m.prima_extornada_cia  ) * v.iprinet+
                                    SIGN(m.prima_extorn_anul    ) * - v.iprinet+
                                    SIGN(m.prima_extorn_anul_cia) * - v.iprinet)
                             )                                            ) ext_perant,
                SUM(DECODE(TO_CHAR(m.fefecto,'yyyymm'),m.nperven,0,
                                   (SIGN(m.prima_extornada      )* v.iips+
                                    SIGN(m.prima_extornada_cia  )* v.iips+
                                    SIGN(m.prima_extorn_anul    )* - v.iips+
                                    SIGN(m.prima_extorn_anul_cia)* - v.iips)
                            )                                             ) ips_perant,
                SUM(DECODE(TO_CHAR(m.fefecto,'yyyymm'),m.nperven,0,
                                   (DECODE(SIGN(m.prima_extornada       )  ,0,0,1, v.iconsor)+
                                    DECODE(SIGN(m.prima_extornada_cia   )  ,0,0,1, v.iconsor)+
                                    DECODE(SIGN(m.prima_extorn_anul     )  ,0,0,1, - v.iconsor)+
                                    DECODE(SIGN(m.prima_extorn_anul_cia )  ,0,0,1, - v.iconsor))
                           )                                              ) iconsor_perant,
                SUM(DECODE(TO_CHAR(m.fefecto,'yyyymm'),m.nperven,0,
                                 (DECODE(m.comis_extornada_agen      ,0,0,   m.comis_extornada_agen       )+
                                  DECODE(m.comis_extornada_cia_agen  ,0,0,   m.comis_extornada_cia_agen   )+
                                  DECODE(m.comis_extorn_anul_agen    ,0,0, - m.comis_extorn_anul_agen     )+
                                  DECODE(m.comis_extorn_anul_cia_agen,0,0, - m.comis_extorn_anul_cia_agen ))
                          )                                                ) comis_perant,
                SUM(DECODE(TO_CHAR(m.fefecto,'yyyymm'),m.nperven,0,
                                 (DECODE(m.prima_extornada      ,0,0,   m.prima_extornada      )+
                                  DECODE(m.prima_extornada_cia  ,0,0,   m.prima_extornada_cia  )+
                                  DECODE(m.prima_extorn_anul    ,0,0, - m.prima_extorn_anul    )+
                                  DECODE(m.prima_extorn_anul_cia,0,0, - m.prima_extorn_anul_cia) )
                          )                          ) bruta_perant
         FROM MERITACION m,  VDETRECIBOS v, PRODUCTOS p, PARPRODUCTOS n, DETPARPRO d
         WHERE m.cempres = wcempres
           AND m.fcierre = wfecha
           AND m.nrecibo = v.nrecibo
           AND m.cramo   = p.cramo
           AND m.cmodali = p.cmodali
           AND m.ctipseg = p.ctipseg
           AND m.ccolect = p.ccolect
           AND p.sproduc = n.sproduc (+)
           AND n.cparpro (+) = 'NOMBRE'
           AND n.cparpro     = d.cparpro (+)
           AND n.cvalpar     = d.cvalpar (+)
           AND d.cidioma (+) = wcidioma
         GROUP BY NVL(d.tvalpar,'ALTRES');
BEGIN
   fitxer := utl_file.fopen (ppath, ptfitxer, 'w');
   linia := 'PRODUCTO;PRIMA_EXTORNADA_PERIODO_ACTUAL;IPS_PERIODO_ACTUAL;'||
            'CONSORCIO_PERIODO_ACTUAL;COMISION_PERIODO_ACTUAL;PRIMA_BRUTA_PERIODO_ACTUAL;'||
            'PRIMA_EXTORNADA_PERIODO_ANTERIOR;IPS_PERIODO_ANTERIOR;CONSORCIO_PERIODO_ANTERIOR;'||
            'COMISION_PERIODO_ANTERIOR;PRIMA_BRUTA_PERIODO_ANTERIOR';
   UTL_FILE.Put_Line(fitxer, linia);
   FOR v_ext IN c_ext(pcempres, pfecha, pcidioma) LOOP
      linia := RTRIM(v_ext.producte)||';'||v_ext.ext_peract     ||';'||
              v_ext.ips_peract     ||';'||v_ext.iconsor_peract ||';'||
              v_ext.comis_peract   ||';'||v_ext.bruta_peract   ||';'||
              v_ext.ext_perant     ||';'||v_ext.ips_perant     ||';'||
              v_ext.iconsor_perant ||';'||v_ext.comis_perant   ||';'||
              v_ext.bruta_perant   ;
      UTL_FILE.Put_Line(fitxer, linia);
   END LOOP;
   UTL_FILE.fclose(fitxer);
   RETURN 0;
EXCEPTION
   WHEN OTHERS THEN
      DBMS_OUTPUT.put_line(SQLERRM);
      RETURN 107914;
END f_recibos_extornados;
---------------------------------------------------------------------------------------------------------------------------
FUNCTION f_recibos_anulados (pcempres IN NUMBER, ppath IN VARCHAR2 ,ptfitxer IN VARCHAR2,
                             pfecha IN DATE, pcidioma IN NUMBER) RETURN NUMBER IS
---------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------
   fitxer      UTL_FILE.file_type;
   linia       VARCHAR2(2000);
CURSOR c_anu (wcempres NUMBER, wfecha DATE, wcidioma NUMBER ) IS
   SELECT producte,
          SUM(neta_Anul_excact_cob)    neta_Anul_excact_cob,
          SUM(ips_anul_excact_cob )    ips_anul_excact_cob ,
          SUM(iconsor_anul_excact_cob) iconsor_anul_excact_cob,
          SUM(comis_anul_excact_cob)   comis_anul_excact_cob,
          SUM(bruta_anul_excact_cob)   bruta_anul_excact_cob,
          SUM(neta_Anul_excant_cob)    neta_Anul_excant_cob,
          SUM(ips_anul_excant_cob )    ips_anul_excant_cob ,
          SUM(iconsor_anul_excant_cob) iconsor_anul_excant_cob,
          SUM(comis_anul_excant_cob)   comis_anul_excant_cob,
          SUM(bruta_anul_excant_cob)   bruta_anul_excant_cob,
          SUM(neta_Anul_excact_pen)    neta_Anul_excact_pen,
          SUM(ips_anul_excact_pen)     ips_anul_excact_pen,
          SUM(iconsor_anul_excact_pen) iconsor_anul_excact_pen,
          SUM(comis_anul_excact_pen)   comis_anul_excact_pen,
          SUM(bruta_anul_excact_pen)   bruta_anul_excact_pen,
          SUM(neta_Anul_excant_pen)    neta_Anul_excant_pen,
          SUM(ips_anul_excant_pen)     ips_anul_excant_pen,
          SUM(iconsor_anul_excant_pen) iconsor_anul_excant_pen,
          SUM(comis_anul_excant_pen)   comis_anul_excant_pen,
          SUM(bruta_anul_excant_pen)   bruta_anul_excant_pen
   FROM (
      SELECT NVL(d.tvalpar, 'ALTRES') producte,
             SUM(DECODE(SUBSTR(TO_CHAR(nperven),1,4),TO_CHAR(wfecha,'yyyy'),
                            (DECODE(SIGN(m.prima_meritada)    ,-1, v.iprinet,0) +
                             DECODE(SIGN(m.prima_meritada_cia),-1, v.iprinet,0) +
                             DECODE(m.prima_merit_anul        ,0,0, v.iprinet)+
                             DECODE(m.prima_merit_anul_cia    ,0,0, v.iprinet)),
                        0)                                              ) neta_Anul_excact_cob,
             SUM(DECODE(SUBSTR(TO_CHAR(nperven),1,4),TO_CHAR(wfecha,'yyyy'),
                            (DECODE(SIGN(m.prima_meritada)    ,-1, v.iips,0) +
                             DECODE(SIGN(m.prima_meritada_cia),-1, v.iips,0) +
                             DECODE(m.prima_merit_anul        ,0,0, v.iips)+
                             DECODE(m.prima_merit_anul_cia    ,0,0, v.iips)),
                        0)                                              ) ips_anul_excact_cob,
             SUM(DECODE(SUBSTR(TO_CHAR(nperven),1,4),TO_CHAR(wfecha,'yyyy'),
                            (DECODE(SIGN(m.prima_meritada)    ,-1, v.iconsor,0) +
                             DECODE(SIGN(m.prima_meritada_cia),-1, v.iconsor,0) +
                             DECODE(m.prima_merit_anul        ,0,0, v.iconsor)+
                             DECODE(m.prima_merit_anul_cia    ,0,0, v.iconsor)),
                        0)                                              ) iconsor_anul_excact_cob,
            SUM(DECODE(SUBSTR(TO_CHAR(nperven),1,4),TO_CHAR(wfecha,'yyyy'),
                             (  DECODE(SIGN(m.comis_meritada    ),-1,-m.comis_meritada    -m.comis_meritada_agen    ,0)
                              + DECODE(SIGN(m.comis_meritada_cia),-1,-m.comis_meritada_cia-m.comis_meritada_cia_agen,0)
                              + m.comis_merit_anul_agen
                              + m.comis_merit_anul_cia_agen),
                       0)                                                 ) comis_anul_excact_cob,
             SUM(DECODE(SUBSTR(TO_CHAR(nperven),1,4),TO_CHAR(wfecha,'yyyy'),
                               ( DECODE(SIGN(m.prima_meritada    ),-1,-m.prima_meritada    ,0)
                               + DECODE(SIGN(m.prima_meritada_cia),-1,-m.prima_meritada_cia,0)
                               +  m.prima_merit_anul
                               + m.prima_merit_anul_cia ),
                       0)                                   ) bruta_anul_excact_cob,
             SUM(DECODE(SUBSTR(TO_CHAR(nperven),1,4),TO_CHAR(wfecha,'yyyy'),
                           0,
                            (DECODE(SIGN(m.prima_meritada)    ,-1, v.iprinet,0) +
                             DECODE(SIGN(m.prima_meritada_cia),-1, v.iprinet,0) +
                             DECODE(m.prima_merit_anul        ,0,0, v.iprinet)+
                             DECODE(m.prima_merit_anul_cia    ,0,0, v.iprinet))
                            )                                              ) neta_Anul_excant_cob,
             SUM(DECODE(SUBSTR(TO_CHAR(nperven),1,4),TO_CHAR(wfecha,'yyyy'),
                            0,
                            (DECODE(SIGN(m.prima_meritada)    ,-1, v.iips,0) +
                             DECODE(SIGN(m.prima_meritada_cia),-1, v.iips,0) +
                             DECODE(m.prima_merit_anul        ,0,0, v.iips)+
                             DECODE(m.prima_merit_anul_cia    ,0,0, v.iips))
                        )                                              ) ips_anul_excant_cob,
             SUM(DECODE(SUBSTR(TO_CHAR(nperven),1,4),TO_CHAR(wfecha,'yyyy'),
                           0,
                            (DECODE(SIGN(m.prima_meritada)    ,-1, v.iconsor,0) +
                             DECODE(SIGN(m.prima_meritada_cia),-1, v.iconsor,0) +
                             DECODE(m.prima_merit_anul        ,0,0, v.iconsor)+
                             DECODE(m.prima_merit_anul_cia    ,0,0, v.iconsor))
                        )                                              ) iconsor_anul_excant_cob,
            SUM(DECODE(SUBSTR(TO_CHAR(nperven),1,4),TO_CHAR(wfecha,'yyyy'),
                            0,
                             (  DECODE(SIGN(m.comis_meritada    ),-1,-m.comis_meritada    -m.comis_meritada_agen  ,0  )
                              + DECODE(SIGN(m.comis_meritada_cia),-1,-m.comis_meritada_cia-m.comis_meritada_cia_agen,0)
                              + m.comis_merit_anul_agen
                              + m.comis_merit_anul_cia_agen)
                       )                                                 ) comis_anul_excant_cob,
             SUM(DECODE(SUBSTR(TO_CHAR(nperven),1,4),TO_CHAR(wfecha,'yyyy'),
                            0,
                               ( DECODE(SIGN(m.prima_meritada    ),-1,-m.prima_meritada    ,0)
                               + DECODE(SIGN(m.prima_meritada_cia),-1,-m.prima_meritada_cia,0)
                               + m.prima_merit_anul
                               + m.prima_merit_anul_cia)
                       )                                   ) bruta_anul_excant_cob,
             0 neta_Anul_excact_pen,
             0 ips_anul_excact_pen,
             0 iconsor_anul_excact_pen,
             0 comis_anul_excact_pen,
             0 bruta_anul_excact_pen,
             0 neta_Anul_excant_pen,
             0 ips_anul_excant_pen,
             0 iconsor_anul_excant_pen,
             0 comis_anul_excant_pen,
             0 bruta_anul_excant_pen
      FROM MERITACION m,  VDETRECIBOS v, PRODUCTOS p, PARPRODUCTOS n, DETPARPRO d
      WHERE m.cempres = wcempres
        AND m.fcierre = wfecha
        AND m.nrecibo = v.nrecibo
        AND EXISTS ( SELECT nrecibo
                     FROM MOVRECIBO
                     WHERE nrecibo = m.nrecibo
                       AND cestrec = 1)
        AND m.cramo   = p.cramo
        AND m.cmodali = p.cmodali
        AND m.ctipseg = p.ctipseg
        AND m.ccolect = p.ccolect
        AND p.sproduc = n.sproduc (+)
        AND n.cparpro (+) = 'NOMBRE'
        AND n.cparpro     = d.cparpro (+)
        AND n.cvalpar     = d.cvalpar (+)
        AND d.cidioma (+) = wcidioma
      GROUP BY NVL(d.tvalpar,'ALTRES')
      UNION
      SELECT NVL(d.tvalpar,'ALTRES') producte,
             0 neta_Anul_excact_cob,
             0 ips_anul_excact_cob ,
             0 iconsor_anul_excact_cob,
             0 comis_anul_excact_cob,
             0 bruta_anul_excact_cob,
             0 neta_Anul_excant_cob,
             0 ips_anul_excant_cob ,
             0 iconsor_anul_excant_cob,
             0 comis_anul_excant_cob,
             0 bruta_anul_excant_cob,
             SUM(DECODE(SUBSTR(TO_CHAR(nperven),1,4),TO_CHAR(wfecha,'yyyy'),
                            (DECODE(SIGN(m.prima_meritada)    ,-1, v.iprinet,0) +
                             DECODE(SIGN(m.prima_meritada_cia),-1, v.iprinet,0) +
                             DECODE(m.prima_merit_anul        ,0,0, v.iprinet)+
                             DECODE(m.prima_merit_anul_cia    ,0,0, v.iprinet)),
                        0)                                              ) neta_Anul_excact_pen,
             SUM(DECODE(SUBSTR(TO_CHAR(nperven),1,4),TO_CHAR(wfecha,'yyyy'),
                            (DECODE(SIGN(m.prima_meritada)    ,-1, v.iips,0) +
                             DECODE(SIGN(m.prima_meritada_cia),-1, v.iips,0) +
                             DECODE(m.prima_merit_anul        ,0,0, v.iips)+
                             DECODE(m.prima_merit_anul_cia    ,0,0, v.iips)),
                        0)                                              ) ips_anul_excact_pen,
             SUM(DECODE(SUBSTR(TO_CHAR(nperven),1,4),TO_CHAR(wfecha,'yyyy'),
                            (DECODE(SIGN(m.prima_meritada)    ,-1, v.iconsor,0) +
                             DECODE(SIGN(m.prima_meritada_cia),-1, v.iconsor,0) +
                             DECODE(m.prima_merit_anul        ,0,0, v.iconsor)+
                             DECODE(m.prima_merit_anul_cia    ,0,0, v.iconsor)),
                        0)                                              ) iconsor_anul_excact_pen,
            SUM(DECODE(SUBSTR(TO_CHAR(nperven),1,4),TO_CHAR(wfecha,'yyyy'),
                             (  DECODE(SIGN(m.comis_meritada    ),-1,-m.comis_meritada    -m.comis_meritada_agen    ,0)
                              + DECODE(SIGN(m.comis_meritada_cia),-1,-m.comis_meritada_cia-m.comis_meritada_cia_agen,0)
                              + m.comis_merit_anul_agen
                              + m.comis_merit_anul_cia_agen),
                       0)                                                 ) comis_anul_excact_pen,
             SUM(DECODE(SUBSTR(TO_CHAR(nperven),1,4),TO_CHAR(wfecha,'yyyy'),
                               ( DECODE(SIGN(m.prima_meritada    ),-1,-m.prima_meritada    ,0)
                               + DECODE(SIGN(m.prima_meritada_cia),-1,-m.prima_meritada_cia,0)
                               +  m.prima_merit_anul
                               + m.prima_merit_anul_cia),
                       0)                                   ) bruta_anul_excact_pen,
             SUM(DECODE(SUBSTR(TO_CHAR(nperven),1,4),TO_CHAR(wfecha,'yyyy'),
                           0,
                            (DECODE(SIGN(m.prima_meritada)    ,-1, v.iprinet,0) +
                             DECODE(SIGN(m.prima_meritada_cia),-1, v.iprinet,0) +
                             DECODE(m.prima_merit_anul        ,0,0, v.iprinet)+
                             DECODE(m.prima_merit_anul_cia    ,0,0, v.iprinet))
                            )                                              ) neta_Anul_excant_pen,
             SUM(DECODE(SUBSTR(TO_CHAR(nperven),1,4),TO_CHAR(wfecha,'yyyy'),
                            0,
                            (DECODE(SIGN(m.prima_meritada)    ,-1, v.iips,0) +
                             DECODE(SIGN(m.prima_meritada_cia),-1, v.iips,0) +
                             DECODE(m.prima_merit_anul        ,0,0, v.iips)+
                             DECODE(m.prima_merit_anul_cia    ,0,0, v.iips))
                        )                                              ) ips_anul_excant_pen,
             SUM(DECODE(SUBSTR(TO_CHAR(nperven),1,4),TO_CHAR(wfecha,'yyyy'),
                           0,
                            (DECODE(SIGN(m.prima_meritada)    ,-1, v.iconsor,0) +
                             DECODE(SIGN(m.prima_meritada_cia),-1, v.iconsor,0) +
                             DECODE(m.prima_merit_anul        ,0,0, v.iconsor)+
                             DECODE(m.prima_merit_anul_cia    ,0,0, v.iconsor))
                        )                                              ) iconsor_anul_excant_pen,
            SUM(DECODE(SUBSTR(TO_CHAR(nperven),1,4),TO_CHAR(wfecha,'yyyy'),
                            0,
                             (  DECODE(SIGN(m.comis_meritada    ),-1,-m.comis_meritada    -m.comis_meritada_agen    ,0)
                              + DECODE(SIGN(m.comis_meritada_cia),-1,-m.comis_meritada_cia-m.comis_meritada_cia_agen,0)
                              + m.comis_merit_anul_agen
                              + m.comis_merit_anul_cia_agen)
                       )                                                 ) comis_anul_excant_pen,
             SUM(DECODE(SUBSTR(TO_CHAR(nperven),1,4),TO_CHAR(wfecha,'yyyy'),
                            0,
                               ( DECODE(SIGN(m.prima_meritada    ),-1,-m.prima_meritada    ,0)
                               + DECODE(SIGN(m.prima_meritada_cia),-1,-m.prima_meritada_cia,0)
                               + m.prima_merit_anul
                               + m.prima_merit_anul_cia)
                       )                                   ) bruta_anul_excant_pen
      FROM MERITACION m,  VDETRECIBOS v, PRODUCTOS p, PARPRODUCTOS n, DETPARPRO d
      WHERE m.cempres = wcempres
        AND m.fcierre = wfecha
        AND m.nrecibo = v.nrecibo
        AND NOT EXISTS ( SELECT nrecibo
                     FROM MOVRECIBO
                     WHERE nrecibo = m.nrecibo
                       AND cestrec = 1)
        AND m.cramo   = p.cramo
        AND m.cmodali = p.cmodali
        AND m.ctipseg = p.ctipseg
        AND m.ccolect = p.ccolect
        AND p.sproduc = n.sproduc (+)
        AND n.cparpro (+) = 'NOMBRE'
        AND n.cparpro     = d.cparpro (+)
        AND n.cvalpar     = d.cvalpar (+)
        AND d.cidioma (+) = wcidioma
      GROUP BY NVL(d.tvalpar,'ALTRES')
   )
   GROUP BY producte;
BEGIN
   fitxer := utl_file.fopen (ppath, ptfitxer, 'w');
   linia := 'PRODUCTO;neta_Anul_excact_cob    ;ips_anul_excact_cob     ;iconsor_anul_excact_cob ;'||
            'comis_anul_excact_cob;bruta_anul_excact_cob   ;neta_Anul_excact_pen    ;ips_anul_excact_pen;'||
            'iconsor_anul_excact_pen ;comis_anul_excact_pen   ;       bruta_anul_excact_pen   ;neta_Anul_excant_cob    ;      '||
            'ips_anul_excant_cob     ;iconsor_anul_excant_cob ;comis_anul_excant_cob   ;bruta_anul_excant_cob   ;             '||
            'neta_Anul_excant_pen;ips_anul_excant_pen     ;iconsor_anul_excant_pen ;comis_anul_excant_pen   ;bruta_anul_excant_pen';
   UTL_FILE.Put_Line(fitxer, linia);
   FOR v_anu IN c_anu (pcempres, pfecha, pcidioma) LOOP
      linia := RTRIM(v_anu.producte)||';'||
             v_anu.neta_Anul_excact_cob    ||';'||
             v_anu.ips_anul_excact_cob     ||';'||
             v_anu.iconsor_anul_excact_cob ||';'||
             v_anu.comis_anul_excact_cob   ||';'||
             v_anu.bruta_anul_excact_cob   ||';'||
             v_anu.neta_Anul_excact_pen    ||';'||
             v_anu.ips_anul_excact_pen     ||';'||
             v_anu.iconsor_anul_excact_pen ||';'||
             v_anu.comis_anul_excact_pen   ||';'||
             v_anu.bruta_anul_excact_pen   ||';'||
             v_anu.neta_Anul_excant_cob    ||';'||
             v_anu.ips_anul_excant_cob     ||';'||
             v_anu.iconsor_anul_excant_cob ||';'||
             v_anu.comis_anul_excant_cob   ||';'||
             v_anu.bruta_anul_excant_cob   ||';'||
             v_anu.neta_Anul_excant_pen    ||';'||
             v_anu.ips_anul_excant_pen     ||';'||
             v_anu.iconsor_anul_excant_pen ||';'||
             v_anu.comis_anul_excant_pen   ||';'||
             v_anu.bruta_anul_excant_pen;
      UTL_FILE.Put_Line(fitxer, linia);
   END LOOP;
   UTL_FILE.fclose(fitxer);
   RETURN 0;
EXCEPTION
   WHEN OTHERS THEN
      DBMS_OUTPUT.put_line(SQLERRM);
      RETURN 107914;
END f_recibos_anulados;
---------------------------------------------------------------------------------------------------------------------------
FUNCTION f_saldos(ppath IN VARCHAR2 ,ptfitxer IN VARCHAR2, pfecha IN DATE  , pcidioma IN NUMBER) RETURN NUMBER IS
---------------------------------------------------------------------------------------------------------------------------
-- Lectura dels saldos del mes en questió
---------------------------------------------------------------------------------------------------------------------------
   fitxer      UTL_FILE.file_type;
   linia       VARCHAR2(2000);
   CURSOR c_saldo (wfecha DATE, wcidioma NUMBER ) IS
         SELECT NVL(d.tvalpar,'ALTRES') producte,
                SUM(imovimi) saldo
         FROM SEGUROS s, CTASEGURO c, PARPRODUCTOS p, DETPARPRO d
         WHERE s.sseguro = c.sseguro
           AND s.sproduc = p.sproduc (+)
           AND p.cparpro (+) = 'NOMBRE'
           AND fvalmov >= wfecha
           AND fvalmov < wfecha + 1
           AND c.cmovimi =0
           AND s.cramo LIKE '%'
           AND s.cmodali LIKE '%'
           AND s.ctipseg LIKE '%'
           AND s.ccolect  LIKE '%'
           AND p.cparpro     = d.cparpro (+)
           AND p.cvalpar     = d.cvalpar (+)
           AND d.cidioma (+) = wcidioma
         GROUP BY NVL(d.tvalpar,'ALTRES');
BEGIN
   fitxer := utl_file.fopen (ppath, ptfitxer, 'w');
   linia := 'PRODUCTO;saldo';
   UTL_FILE.Put_Line(fitxer, linia);
   FOR v_saldo IN c_saldo (pfecha, pcidioma) LOOP
      linia := RTRIM(v_saldo.producte)||';'||v_saldo.saldo;
      UTL_FILE.Put_Line(fitxer, linia);
   END LOOP;
   UTL_FILE.fclose(fitxer);
   RETURN 0;
EXCEPTION
   WHEN OTHERS THEN
      DBMS_OUTPUT.put_line(SQLERRM);
      RETURN 107914;
END f_saldos;
---------------------------------------------------------------------------------------------------------------------------
FUNCTION f_retenciones (ppath IN VARCHAR2 ,ptfitxer IN VARCHAR2, pfecha IN DATE  , pcidioma IN NUMBER) RETURN NUMBER IS
---------------------------------------------------------------------------------------------------------------------------
-- Prestacions
---------------------------------------------------------------------------------------------------------------------------
   CURSOR c_agr ( wcidioma NUMBER) IS
      SELECT DISTINCT NVL(d.tvalpar,'ALTRES') producte
      FROM PRODUCTOS p, PARPRODUCTOS t, DETPARPRO d
      WHERE p.sproduc = t.sproduc (+)
        AND t.cparpro (+) = 'NOMBRE'
        AND t.cparpro = d.cparpro (+)
        AND t.cvalpar = d.cvalpar (+)
        AND d.cidioma (+)= wcidioma;
    CURSOR c_prods ( wcidioma NUMBER, wproducte VARCHAR2) IS
       SELECT p.cramo, p.cmodali, p.ctipseg, p.ccolect
       FROM PRODUCTOS p, PARPRODUCTOS t, DETPARPRO d
       WHERE p.sproduc = t.sproduc (+)
         AND t.cparpro (+) = 'NOMBRE'
         AND t.cparpro = d.cparpro (+)
         AND t.cvalpar = d.cvalpar (+)
         AND d.cidioma (+)= wcidioma
         AND NVL(d.tvalpar,'ALTRES') = wproducte;
   -- Positives
   CURSOR c_reten (wnumpet NUMBER, wpfiscal NUMBER,
                   wcramo NUMBER,wcmodali NUMBER, wctipseg NUMBER, wccolect NUMBER) IS
      SELECT DECODE(ctipo,'RTO','RESC', 'RPA','RESC',
                    ctipo) ctipo,
             SUM(ibruto) tot_prest,
             SUM(DECODE(csubtipo,999,0,998,0,NVL(ibruto,0))) subj_reten,
             SUM(DECODE(csubtipo,999,NVL(ibruto,0),998,NVL(ibruto,0),0)) NOsubj_reten,
             SUM(NVL(ibase  ,0)) base,
             SUM(NVL(iretenc,0)) retenc,
             SUM(NVL(ineto  ,0)) liquid
      FROM  FIS_DETCIERREPAGO d
      WHERE d.nnumpet  = wnumpet
        AND d.pfiscal = wpfiscal
        AND d.cramo   = wcramo
        AND d.cmodali = wcmodali
        AND d.ctipseg = wctipseg
        AND d.ccolect = wccolect
        AND d.csigbase ='P'
      GROUP BY DECODE(ctipo,'RTO','RESC', 'RPA','RESC',
                    ctipo);
   -- Negatives
   CURSOR c_reten_neg (wnumpet NUMBER, wpfiscal NUMBER,
                       wcramo NUMBER,wcmodali NUMBER, wctipseg NUMBER, wccolect NUMBER) IS
      SELECT SUM(ibruto) tot_prest,
             0  subj_reten,
             SUM(NVL(ibruto, 0)) NOsubj_reten,
             SUM(NVL(ibase  ,0)) base,
             SUM(NVL(iretenc,0)) retenc,
             SUM(NVL(ineto  ,0)) liquid
      FROM  FIS_DETCIERREPAGO d
      WHERE d.nnumpet  = wnumpet
        AND d.pfiscal = wpfiscal
        AND d.cramo   = wcramo
        AND d.cmodali = wcmodali
        AND d.ctipseg = wctipseg
        AND d.ccolect = wccolect
        AND d.csigbase ='N';
   lnnumpet                NUMBER;
   l_vto_tot_prest         NUMBER;
   l_vto_tot_subj_reten    NUMBER;
   l_vto_tot_NOsubj_reten  NUMBER;
   l_vto_tot_base          NUMBER;
   l_vto_tot_retenc        NUMBER;
   l_vto_tot_liquid        NUMBER;
   l_sin_tot_prest         NUMBER;
   l_sin_tot_subj_reten    NUMBER;
   l_sin_tot_NOsubj_reten  NUMBER;
   l_sin_tot_base          NUMBER;
   l_sin_tot_retenc        NUMBER;
   l_sin_tot_liquid        NUMBER;
   l_ren_tot_prest         NUMBER;
   l_ren_tot_subj_reten    NUMBER;
   l_ren_tot_NOsubj_reten  NUMBER;
   l_ren_tot_base          NUMBER;
   l_ren_tot_retenc        NUMBER;
   l_ren_tot_liquid        NUMBER;
   l_res_tot_prest         NUMBER;
   l_res_tot_subj_reten    NUMBER;
   l_res_tot_NOsubj_reten  NUMBER;
   l_res_tot_base          NUMBER;
   l_res_tot_retenc        NUMBER;
   l_res_tot_liquid        NUMBER;
   l_neg_tot_prest         NUMBER;
   l_neg_tot_subj_reten    NUMBER;
   l_neg_tot_NOsubj_reten  NUMBER;
   l_neg_tot_base          NUMBER;
   l_neg_tot_retenc        NUMBER;
   l_neg_tot_liquid        NUMBER;
   fitxer      UTL_FILE.file_type;
   linia       VARCHAR2(500);
BEGIN
   -- Obtenim la ultima petició correcte
   BEGIN
      SELECT MAX(nnumpet) INTO lnnumpet
      FROM FIS_CABCIERRE;
      --NUNU nunununununununun WHERE ccierre = 1;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 9;
   END;
   IF lnnumpet IS NULL THEN
      RETURN 9;
   ELSE
      fitxer := utl_file.fopen (ppath, ptfitxer, 'w');
      linia := ' ;;Total prestacions (brutes);Subjectes a retenció;No subjectes a retenció;'||
               'Base de retenció;Retenció;Líquid';
      UTL_FILE.Put_Line(fitxer, linia);
      FOR v_agr IN c_agr (pcidioma) LOOP
         l_vto_tot_prest         := 0;
         l_vto_tot_subj_reten    := 0;
         l_vto_tot_NOsubj_reten  := 0;
         l_vto_tot_base          := 0;
         l_vto_tot_retenc        := 0;
         l_vto_tot_liquid        := 0;
         l_sin_tot_prest         := 0;
         l_sin_tot_subj_reten    := 0;
         l_sin_tot_NOsubj_reten  := 0;
         l_sin_tot_base          := 0;
         l_sin_tot_retenc        := 0;
         l_sin_tot_liquid        := 0;
         l_ren_tot_prest         := 0;
         l_ren_tot_subj_reten    := 0;
         l_ren_tot_NOsubj_reten  := 0;
         l_ren_tot_base          := 0;
         l_ren_tot_retenc        := 0;
         l_ren_tot_liquid        := 0;
         l_res_tot_prest         := 0;
         l_res_tot_subj_reten    := 0;
         l_res_tot_NOsubj_reten  := 0;
         l_res_tot_base          := 0;
         l_res_tot_retenc        := 0;
         l_res_tot_liquid        := 0;
         FOR v_prods IN c_prods (pcidioma, v_agr.producte) LOOP
            FOR v_reten IN c_reten (lnnumpet, TO_CHAR(pfecha,'yyyymm'),
                                    v_prods.cramo,v_prods.cmodali ,
                                    v_prods.ctipseg, v_prods.ccolect ) LOOP
               IF v_reten.ctipo = 'VTO' THEN
                  l_vto_tot_prest        := l_vto_tot_prest        + NVL(v_reten.tot_prest    ,0);
                  l_vto_tot_subj_reten   := l_vto_tot_subj_reten   + NVL(v_reten.subj_reten   ,0);
                  l_vto_tot_NOsubj_reten := l_vto_tot_NOsubj_reten + NVL(v_reten.NOsubj_reten ,0);
                  l_vto_tot_base         := l_vto_tot_base         + NVL(v_reten.base         ,0);
                  l_vto_tot_retenc       := l_vto_tot_retenc       + NVL(v_reten.retenc       ,0);
                  l_vto_tot_liquid       := l_vto_tot_liquid       + NVL(v_reten.liquid       ,0);
               END IF;
               IF v_reten.ctipo = 'SIN' THEN
                  l_sin_tot_prest        := l_sin_tot_prest        + NVL(v_reten.tot_prest   ,0) ;
                  l_sin_tot_subj_reten   := l_sin_tot_subj_reten   + NVL(v_reten.subj_reten  ,0) ;
                  l_sin_tot_NOsubj_reten := l_sin_tot_NOsubj_reten + NVL(v_reten.NOsubj_reten,0) ;
                  l_sin_tot_base         := l_sin_tot_base         + NVL(v_reten.base        ,0) ;
                  l_sin_tot_retenc       := l_sin_tot_retenc       + NVL(v_reten.retenc      ,0) ;
                  l_sin_tot_liquid       := l_sin_tot_liquid       + NVL(v_reten.liquid      ,0) ;
               END IF;
               IF v_reten.ctipo = 'REN' THEN
                  l_ren_tot_prest        := l_ren_tot_prest        + NVL(v_reten.tot_prest    ,0);
                  l_ren_tot_subj_reten   := l_ren_tot_subj_reten   + NVL(v_reten.subj_reten   ,0);
                  l_ren_tot_NOsubj_reten := l_ren_tot_NOsubj_reten + NVL(v_reten.NOsubj_reten ,0);
                  l_ren_tot_base         := l_ren_tot_base         + NVL(v_reten.base         ,0);
                  l_ren_tot_retenc       := l_ren_tot_retenc       + NVL(v_reten.retenc       ,0);
                  l_ren_tot_liquid       := l_ren_tot_liquid       + NVL(v_reten.liquid       ,0);
               END IF;
               IF v_reten.ctipo = 'RESC' THEN
                  l_res_tot_prest        := l_res_tot_prest        + NVL(v_reten.tot_prest   ,0) ;
                  l_res_tot_subj_reten   := l_res_tot_subj_reten   + NVL(v_reten.subj_reten  ,0) ;
                  l_res_tot_NOsubj_reten := l_res_tot_NOsubj_reten + NVL(v_reten.NOsubj_reten,0) ;
                  l_res_tot_base         := l_res_tot_base         + NVL(v_reten.base  ,0)       ;
                  l_res_tot_retenc       := l_res_tot_retenc       + NVL(v_reten.retenc,0)       ;
                  l_res_tot_liquid       := l_res_tot_liquid       + NVL(v_reten.liquid,0)       ;
               END IF;
            END LOOP;
         END LOOP;
         IF (v_agr.producte ='ALTRES' OR v_agr.producte ='OTROS') AND
             l_vto_tot_prest=0 AND l_vto_tot_subj_reten=0  AND l_vto_tot_NOsubj_reten=0 AND
             l_vto_tot_base =0 AND l_vto_tot_retenc=0      AND l_vto_tot_liquid =0      AND
             l_sin_tot_prest=0 AND l_sin_tot_subj_reten= 0 AND l_sin_tot_NOsubj_reten=0 AND
             l_sin_tot_base =0 AND l_sin_tot_retenc =0     AND l_sin_tot_liquid =0      AND
             l_ren_tot_prest=0 AND l_ren_tot_subj_reten=0  AND l_ren_tot_NOsubj_reten=0 AND
             l_ren_tot_base =0 AND l_ren_tot_retenc=0      AND l_ren_tot_liquid=0       AND
             l_res_tot_prest=0 AND l_res_tot_subj_reten=0  AND l_res_tot_NOsubj_reten=0 AND
             l_res_tot_base=0  AND l_res_tot_retenc=0      AND l_res_tot_liquid=0 THEN
            NULL;
         ELSE
            linia := v_agr.producte;
            UTL_FILE.Put_Line(fitxer, linia);
            linia := ';Venciments'||';'||l_vto_tot_prest||';'||l_vto_tot_subj_reten   ||';'||
                         l_vto_tot_NOsubj_reten ||';'||l_vto_tot_base ||';'||
                         l_vto_tot_retenc       ||';'||l_vto_tot_liquid ;
            UTL_FILE.Put_Line(fitxer, linia);
            linia := ';Mort/Invalidesa'||';'||l_sin_tot_prest        ||';'||l_sin_tot_subj_reten   ||';'||
                              l_sin_tot_NOsubj_reten ||';'||l_sin_tot_base ||';'||
                              l_sin_tot_retenc       ||';'||l_sin_tot_liquid ;
            UTL_FILE.Put_Line(fitxer, linia);
            linia := ';Rendes'||';'||l_ren_tot_prest        ||';'||l_ren_tot_subj_reten   ||';'||
                            l_ren_tot_NOsubj_reten ||';'||l_ren_tot_base ||';'||
                            l_ren_tot_retenc       ||';'||l_ren_tot_liquid ;
            UTL_FILE.Put_Line(fitxer, linia);
            linia := ';Rescats'||';'||l_res_tot_prest        ||';'||l_res_tot_subj_reten   ||';'||
                             l_res_tot_NOsubj_reten ||';'||l_res_tot_base ||';'||
                             l_res_tot_retenc       ||';'||l_res_tot_liquid ;
            UTL_FILE.Put_Line(fitxer, linia);
         END IF;
      END LOOP;
      -- Negatives
      linia := 'BASES NEGATIVES ';
      UTL_FILE.Put_Line(fitxer, linia);
      FOR v_agr IN c_agr (pcidioma) LOOP
         l_neg_tot_prest         := 0;
         l_neg_tot_subj_reten    := 0;
         l_neg_tot_NOsubj_reten  := 0;
         l_neg_tot_base          := 0;
         l_neg_tot_retenc        := 0;
         l_neg_tot_liquid        := 0;
         FOR v_prods IN c_prods (pcidioma, v_agr.producte) LOOP
            FOR v_reten_neg IN c_reten_neg (lnnumpet, TO_CHAR(pfecha,'yyyymm'),
                                            v_prods.cramo,v_prods.cmodali ,
                                            v_prods.ctipseg, v_prods.ccolect ) LOOP
               l_neg_tot_prest        := l_neg_tot_prest        + NVL(v_reten_neg.tot_prest   ,0) ;
               l_neg_tot_subj_reten   := l_neg_tot_subj_reten   + NVL(v_reten_neg.subj_reten  ,0) ;
               l_neg_tot_NOsubj_reten := l_neg_tot_NOsubj_reten + NVL(v_reten_neg.NOsubj_reten,0) ;
               l_neg_tot_base         := l_neg_tot_base         + NVL(v_reten_neg.base        ,0) ;
               l_neg_tot_retenc       := l_neg_tot_retenc       + NVL(v_reten_neg.retenc      ,0) ;
               l_neg_tot_liquid       := l_neg_tot_liquid       + NVL(v_reten_neg.liquid      ,0) ;
            END LOOP;
         END LOOP;
         IF (v_agr.producte ='ALTRES' OR v_agr.producte ='OTROS') AND
             NVL(l_neg_tot_prest,0)=0 AND NVL(l_neg_tot_subj_reten,0)=0  AND NVL(l_neg_tot_NOsubj_reten,0)=0 AND
             NVL(l_neg_tot_base ,0)=0 AND NVL(l_neg_tot_retenc,0)=0      AND NVL(l_neg_tot_liquid,0) =0      THEN
            NULL;
         ELSE
            linia := v_agr.producte||';;'||l_neg_tot_prest||';'||l_neg_tot_subj_reten   ||';'||
                         l_neg_tot_NOsubj_reten ||';'||l_neg_tot_base ||';'||
                         l_neg_tot_retenc       ||';'||l_neg_tot_liquid ;
            UTL_FILE.Put_Line(fitxer, linia);
         END IF;
      END LOOP;
      UTL_FILE.fclose(fitxer);
   END IF;
   RETURN 0;
EXCEPTION
   WHEN OTHERS THEN
      UTL_FILE.fclose(fitxer);
      RETURN 9;
END f_retenciones;
END Pac_Plan_Contab;

/

  GRANT EXECUTE ON "AXIS"."PAC_PLAN_CONTAB" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_PLAN_CONTAB" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_PLAN_CONTAB" TO "PROGRAMADORESCSI";
