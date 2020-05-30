--------------------------------------------------------
--  DDL for Package Body PAC_CARGA_SEGUROS_CONF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_CARGA_SEGUROS_CONF" IS
   /***************************************************************************
      NOMBRE:       pac_carga_seguros_conf
      PROPÓSITO:    Proceso de traspaso de informacion de las tablas base _BS
                    a las distintas tablas MIG_ de AXIS (Capítulo Seguros)
      REVISIONES:
      Ver        Fecha       Autor       Descripción
      ---------  ----------  ----------  --------------------------------------
       1.0        11/10/2017  HAG         Creacion package de carga
       1.1        26/01/2018  HAG         Creación tablas base _BS
       1.2        31/01/2018  HAG         Ajuste cursor mig_pregungaranseg + varios
       1.3        05/02/2018  HAG         Inclusión Capítulo de Administración(Recibos, ...)
   ***************************************************************************/
   /**************************************************************************
        Clave MIG_PK_MIG_AXIS.PK_AXIS
   ***************************************************************************
   PER_PERSONAS             SPERSON
   **************************************************************************/
   --
   dml_errors EXCEPTION;
   PRAGMA EXCEPTION_INIT(dml_errors, -24381);
   l_errors  NUMBER;
   l_errno   NUMBER;
   l_msg     VARCHAR2(4000);
   l_idx     NUMBER;
   gcant_a_cargar_bs  NUMBER := 0;
   gcant_cargada  NUMBER := 0;
   gcant_a_cargar NUMBER := 0;
   g_user         VARCHAR2(30);
   --
   /***************************************************************************
      PROCEDURE p_asigna_user
      Procedimiento que asigna usuario de carga
         param in  puser:     Descripción del usuario.
   ***************************************************************************/
   PROCEDURE p_asigna_user(puser VARCHAR2)
   IS
   BEGIN
     --
     g_user := puser;
     --
   END p_asigna_user;
   /***************************************************************************
      PROCEDURE p_carga_bureau
      Procedimiento que inserta los registros grabados en MIG_BUREAU_bs, en la tabla
      MIG_BUREAU de iAXIS.
   ***************************************************************************/
   PROCEDURE p_carga_bureau
   IS
     --
     TYPE t_mig_bureau IS TABLE OF mig_bureau%ROWTYPE;
     l_reg_mig_mcc t_mig_bureau;
     --
      CURSOR lc_mig_bureau IS
       SELECT 17419 NCARGA, 1 CESTMIG, a.MIG_PK, a.SBUREAU, a.NMOVIMI, a.CANULADA, a.CTIPO, a.NSUPLEM, a.CUSUALT,
              a.FALTA, a.CUSUMOD, a.FMODIF --, NULL CINTERMED, NULL CREPRESEN, NULL CAPODERADO, NULL CPAGADOR, NULL TOBSEVA
         FROM mig_bureau_bs a --, mig_recibos r, mig_seguros s, mig_siniestros sn
        WHERE 1 = 1
          --AND a.mig_pk = '101010100GU0943631'
        ORDER BY a.mig_pk
          ;
          --SELECT * FROM mig_bureau s;
          --SELECT * FROM mig_bureau_conf s WHERE s =  ORDER BY s ;
          --SELECT * FROM mig_movrecibo s;
          --SELECT * FROM mig_bureau_conf s for update WHERE s.mig_pk = 'RD30094778';
          --SELECT * FROM pppc_conf s WHERE mig_fk = '1023871325';
     --
  BEGIN
    --
    -----------------------------------------
    --BUREAU
    -----------------------------------------
    OPEN lc_mig_bureau;
    LOOP
      --
      FETCH lc_mig_bureau BULK COLLECT INTO l_reg_mig_mcc ;--LIMIT v_limit_records;
      --
      dbms_output.put_line('mig_bureau - I - paso bullk');
      --
      dbms_output.put_line('...');
      --
      --FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
      --DELETE FROM mig_bureau WHERE mig_pk = l_reg_mig_mcc(i).mig_pk;
      --
      BEGIN
        --
        FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
        INSERT INTO mig_bureau VALUES l_reg_mig_mcc(i);
        --
      EXCEPTION
      WHEN DML_ERRORS THEN
        --
        l_errors := SQL%bulk_exceptions.count;
        --
        dbms_output.put_line('l_errors:'||l_errors);
        --
        FOR i IN 1 .. l_errors
        LOOP
          --
          l_errno := SQL%BULK_EXCEPTIONS(i).error_code;
          l_msg   := SQLERRM(-l_errno);
          l_idx   := SQL%BULK_EXCEPTIONS(i).error_index;
          --
          p_control_error(g_user,'01_mig_bureau','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
          --
        END LOOP;
        --
      END;
      --
      dbms_output.put_line('mig_bureau - F - paso bullk');
      --
      EXIT WHEN lc_mig_bureau%NOTFOUND;
       --
     END LOOP;
     --
     gcant_a_cargar   := lc_mig_bureau%ROWCOUNT;
     --
     SELECT COUNT(*) INTO gcant_a_cargar_bs FROM mig_bureau_bs;
     SELECT COUNT(*) INTO gcant_cargada FROM mig_bureau;
     --
     CLOSE lc_mig_bureau;
     --
   END p_carga_bureau;
   --
   /***************************************************************************
      PROCEDURE p_carga_seguros
      Procedimiento que inserta los registros grabados en MIG_SEGUROS_bs, en la tabla
      MIG_SEGUROS de iAXIS.
   ***************************************************************************/
   PROCEDURE p_carga_seguros
   IS
     --
     TYPE t_mig_seguros IS TABLE OF mig_seguros%ROWTYPE;
     l_reg_mig_mcc t_mig_seguros;
     --
      CURSOR lc_mig_seguros IS
       SELECT 17420 ncarga,1 CESTMIG, s.MIG_PK,  s.MIG_FK, s.MIG_FKDIR, a.CAGENTE,  s.NPOLIZA,  s.NCERTIF,  s.FEFECTO,  s.CREAFAC,  s.CACTIVI,
       DECODE(s.CCOBBAN, 0, NULL, s.CCOBBAN) CCOBBAN,  s.CTIPCOA,  s.CTIPREA,  s.CTIPCOM,  s.FVENCIM,  s.FEMISIO,  s.FANULAC,  NULL FCANCEL,  s.CSITUAC,  s.IPRIANU,  s.CIDIOMA,
       s.CFORPAG,  s.CRETENI,  s.SCIACOA,  s.PPARCOA,  s.NPOLCOA,  s.NSUPCOA,  s.PDTOCOM,  s.NCUACOA,  s.CEMPRES,  s.SPRODUC,  s.CCOMPANI,
       s.CTIPCOB,  s.CREVALI,  s.PREVALI,  s.IREVALI,  s.CTIPBAN,  s.CBANCAR,  s.CASEGUR,  s.NSUPLEM,  0 SSEGURO,  0 SPERSON,  s.CDOMICI,
       s.NPOLINI,  NULL CTIPBAN2,  NULL CBANCOB,
       --
       --s.FCARANT,  s.FCARPRO,  --Averiguar de donde sacamos estas fechas en esta parte del cargue (mirar en el proceso de historicoseguros)
       s.FEFECTO FCARANT, ADD_MONTHS(FEFECTO, 12) FCARPRO,
       s.CRECFRA,  s.NDURCOB,  s.FCARANU,  NULL CTIPRETR,  NULL CINDREVFRAN,
       NULL PRECARG,  NULL PDTOTEC,  NULL PRECCOM,  NULL FRENOVA,  s.NPOLINI CPOLCIA,  s.NEDAMAR,  17417 PROCESO,  s.NDURACI,  s.MIG_FK2
         FROM mig_seguros_bs s, agentes a
        WHERE 1 = 1
          --AND s.mig_fk2 /*debe ser mig_fk3*/ = a.mig_pk --(+)
          AND s.cagente = a.cagente
          ;
          --SELECT count(*) FROM mig_seguros_bs s;
          --SELECT * FROM mig_seguros;
          --SELECT * FROM mig_seguros_bs s;
          --SELECT * FROM mig_agentes a;
          --SELECT * FROM mig_seguros_bs WHERE fefeplazo IS NOT NULL;
     --
  BEGIN
    --
    -----------------------------------------
    --SEGUROS
    -----------------------------------------
    OPEN lc_mig_seguros;
    LOOP
      --
      FETCH lc_mig_seguros BULK COLLECT INTO l_reg_mig_mcc LIMIT 100000;  -- limit to 10k to avoid out of memory
      --
      --FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
      --DELETE FROM mig_seguros WHERE mig_pk = l_reg_mig_mcc(i).mig_pk;
      --
      BEGIN
        --
        FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
        INSERT INTO mig_seguros VALUES l_reg_mig_mcc(i);
        --
      EXCEPTION
      WHEN DML_ERRORS THEN
        --
        l_errors := SQL%bulk_exceptions.count;
        --
        dbms_output.put_line('l_errors:'||l_errors);
        --
        FOR i IN 1 .. l_errors
        LOOP
          --
          l_errno := SQL%BULK_EXCEPTIONS(i).error_code;
          l_msg   := SQLERRM(-l_errno);
          l_idx   := SQL%BULK_EXCEPTIONS(i).error_index;
          --
          p_control_error(g_user,'01_mig_seguros','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
          --
        END LOOP;
        --
      END;
      --
      dbms_output.put_line('Seguros - F - paso bullk');
      --
      COMMIT;
      --
      EXIT WHEN lc_mig_seguros%NOTFOUND;
       --
     END LOOP;
     --
     gcant_a_cargar   := lc_mig_seguros%ROWCOUNT;
     --
     SELECT COUNT(*) INTO gcant_a_cargar_bs FROM mig_seguros_bs;
     SELECT COUNT(*) INTO gcant_cargada FROM mig_seguros;
     --
     CLOSE lc_mig_seguros;
     --
   END p_carga_seguros;
   --
   /***************************************************************************
      PROCEDURE p_carga_movseguro
      Procedimiento que inserta los registros grabados en MIG_MOVSEGURO_bs, en la tabla
      MIG_MOVSEGURO de iAXIS.
   ***************************************************************************/
   PROCEDURE p_carga_movseguro
   IS
     --
     TYPE t_mig_movseguro IS TABLE OF mig_movseguro%ROWTYPE;
     l_reg_mig_mcc t_mig_movseguro;
     --
      CURSOR lc_mig_movseguro IS
       SELECT 17423 NCARGA,1 CESTMIG, m.MIG_PK, m.MIG_FK, 0 SSEGURO, m.NMOVIMI,
             /*DECODE(m.NMOVIMI, 1, 100, 666)*/ m.CMOTMOV, /*Ojo hag: validar motivos que deben cargar*/
             m.FMOVIMI, m.FEFECTO, m.CUSUMOV, m.CMOTVEN, m.cmovseg, m.nmovimi_ant
     --       SELECT COUNT(*)
         FROM mig_movseguro_bs m, mig_seguros s
        WHERE 1 = 1
          AND m.mig_fk  = s.mig_pk
          ;
          --SELECT * FROM mig_movseguro_conf s;
          --SELECT * FROM mig_movseguro s;
     --
  BEGIN
    --
    -----------------------------------------
    --MOVSEGURO
    -----------------------------------------
    OPEN lc_mig_movseguro;
    LOOP
      --
      FETCH lc_mig_movseguro BULK COLLECT INTO l_reg_mig_mcc LIMIT 100000;  -- limit to 10k to avoid out of memory
      --
      --FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
      --DELETE FROM mig_movseguro WHERE mig_pk = l_reg_mig_mcc(i).mig_pk;
      --
      BEGIN
        --
        FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
        INSERT INTO mig_movseguro VALUES l_reg_mig_mcc(i);
        --
      EXCEPTION
      WHEN DML_ERRORS THEN
        --
        l_errors := SQL%bulk_exceptions.count;
        --
        dbms_output.put_line('l_errors:'||l_errors);
        --
        FOR i IN 1 .. l_errors
        LOOP
          --
          l_errno := SQL%BULK_EXCEPTIONS(i).error_code;
          l_msg   := SQLERRM(-l_errno);
          l_idx   := SQL%BULK_EXCEPTIONS(i).error_index;
          --
          p_control_error(g_user,'03_mig_movseguro','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
          --
        END LOOP;
        --
      END;
      --
      dbms_output.put_line('lc_mig_movseguro - F - paso bullk');
      --
      EXIT WHEN lc_mig_movseguro%NOTFOUND;
       --
     END LOOP;
     --
     gcant_a_cargar   := lc_mig_movseguro%ROWCOUNT;
     --
     SELECT COUNT(*) INTO gcant_a_cargar_bs FROM mig_movseguro_bs;
     SELECT COUNT(*) INTO gcant_cargada FROM mig_movseguro;
     --
     CLOSE lc_mig_movseguro;
     --
   END p_carga_movseguro;
   --
   /***************************************************************************
      PROCEDURE p_carga_historicoseguros
      Procedimiento que inserta los registros grabados en MIG_HISTORICOSEGUROS_bs, en la tabla
      MIG_HISTORICOSEGUROS de iAXIS.
   ***************************************************************************/
   PROCEDURE p_carga_historicoseguros
   IS
     --
     TYPE t_MIG_HISTORICOSEGUROS IS TABLE OF MIG_HISTORICOSEGUROS%ROWTYPE;
     l_reg_mig_mcc t_MIG_HISTORICOSEGUROS;
     --
      CURSOR lc_MIG_HISTORICOSEGUROS IS
       SELECT 17420 NCARGA,1 CESTMIG, a.MIG_PK, a.MIG_FK, a.MIG_FK2, a.MIG_FKDIR, a.CAGENTE, a.NCERTIF, a.FEFECTO, a.CACTIVI,
              a.CCOBBAN, a.CTIPREA, a.CREAFAC, a.CTIPCOM, a.CSITUAC, a.FVENCIM, a.FEMISIO, a.FANULAC, a.IPRIANU, a.CIDIOMA, a.CFORPAG,
              a.CRETENI, a.CTIPCOA, a.SCIACOA, a.PPARCOA, a.NPOLCOA, a.NSUPCOA, a.NCUACOA, a.PDTOCOM, a.CEMPRES, a.SPRODUC, a.CCOMPANI,
              a.CTIPCOB, a.CREVALI, a.PREVALI, a.IREVALI, a.CTIPBAN, a.CBANCAR, a.CASEGUR, a.NSUPLEM, a.CDOMICI, a.NPOLINI, a.FCARANT,
              a.FCARPRO, a.CRECFRA, a.NDURCOB, a.FCARANU, a.NDURACI, a.NEDAMAR, a.FEFEPLAZO, a.FVENCPLAZO, a.MIG_FK3
       --SELECT count(*)
        FROM MIG_HISTORICOSEGUROS_bs a, mig_movseguro s
       WHERE 1 = 1
          AND a.mig_fk2 = s.mig_pk
    ORDER BY a.mig_pk
          ;
          --SELECT * FROM MIG_HISTORICOSEGUROS_conf s WHERE s.mig_pk = '131050100DL0200681';
          --SELECT * FROM mig_movseguro s WHERE s.mig_pk = '101010100GU1282421';
          --select * from seguros where sseguro = 482235;
     --
     dml_errors EXCEPTION;
     PRAGMA EXCEPTION_INIT(dml_errors, -24381);
     l_errors  NUMBER;
     l_errno   NUMBER;
     l_msg     VARCHAR2(4000);
     l_idx     NUMBER;
     --
  BEGIN
    --
    -----------------------------------------
    --MIG_HISTORICOSEGUROS
    -----------------------------------------
    OPEN lc_MIG_HISTORICOSEGUROS;
    LOOP
      --
      FETCH lc_MIG_HISTORICOSEGUROS BULK COLLECT INTO l_reg_mig_mcc LIMIT 100000;  -- limit to 10k to avoid out of memory
      --
      dbms_output.put_line('HISTORICOSEGUROS - I - paso bullk');
      --
      dbms_output.put_line('...');
      --
      --FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
      --DELETE FROM MIG_HISTORICOSEGUROS WHERE mig_pk = l_reg_mig_mcc(i).mig_pk;
      --
      BEGIN
        --
        FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
        INSERT INTO MIG_HISTORICOSEGUROS VALUES l_reg_mig_mcc(i);
        --
      EXCEPTION
      WHEN DML_ERRORS THEN
        --
        l_errors := SQL%bulk_exceptions.count;
        --
        dbms_output.put_line('l_errors:' || l_errors);
        --
        FOR i IN 1 .. l_errors
        LOOP
          --
          l_errno := SQL%BULK_EXCEPTIONS(i).error_code;
          l_msg   := SQLERRM(-l_errno);
          l_idx   := SQL%BULK_EXCEPTIONS(i).error_index;
          --
          p_control_error(g_user,'04_MIG_HISTORICOSEGUROS','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
          --
        END LOOP;
        --
      END;
      --
      dbms_output.put_line('HISTORICOSEGUROS - F - paso bullk');
      --
      COMMIT;
      --
      EXIT WHEN lc_MIG_HISTORICOSEGUROS%NOTFOUND;
       --
     END LOOP;
     --
     gcant_a_cargar   := lc_mig_historicoseguros%ROWCOUNT;
     --
     SELECT COUNT(*) INTO gcant_a_cargar_bs FROM mig_historicoseguros_bs;
     SELECT COUNT(*) INTO gcant_cargada FROM MIG_HISTORICOSEGUROS;
     --
     CLOSE lc_MIG_HISTORICOSEGUROS;
     --
   END p_carga_historicoseguros;
   --
   /***************************************************************************
      PROCEDURE p_carga_asegurados
      Procedimiento que inserta los registros grabados en MIG_ASEGURADOS_bs, en la tabla
      MIG_ASEGURADOS de iAXIS.
   ***************************************************************************/
   PROCEDURE p_carga_asegurados
   IS
     --
     TYPE t_mig_asegurados IS TABLE OF mig_asegurados%ROWTYPE;
     l_reg_mig_mcc t_mig_asegurados;
     --
      CURSOR lc_mig_asegurados IS
       SELECT 17422 ncarga,1 CESTMIG, s.MIG_PK, s.MIG_FK, s.MIG_FK2, 0 SSEGURO,
              0 SPERSON, s.NORDEN, s.CDOMICI, s.FFECINI, s.FFECFIN, s.FFECMUE, s.FECRETROACT, NULL CPAREN
         --SELECT COUNT(*)
         FROM mig_asegurados_bs s, mig_personas p, mig_seguros e
        WHERE 1 = 1
          AND s.mig_fk  = p.mig_pk --(+)
          AND s.mig_fk2 = e.mig_pk --(+) 43138 inclusive sseguro = 0, 38980 con sseguro <> 0
        --AND e.sseguro <> 0
          ;
          --SELECT COUNT(*) FROM mig_asegurados_bs s; --A cargar: 747651
     --
  BEGIN
    --
    -----------------------------------------
    --ASEGURADOS
    -----------------------------------------
    OPEN lc_mig_asegurados;
    LOOP
      --
      FETCH lc_mig_asegurados BULK COLLECT INTO l_reg_mig_mcc LIMIT 100000;  -- limit to 10k to avoid out of memory
      --
      dbms_output.put_line('mig_asegurados - I - paso bullk');
      --
      --FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
      --DELETE FROM mig_asegurados WHERE mig_pk = l_reg_mig_mcc(i).mig_pk;
      --
      BEGIN
        --
        FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
        INSERT INTO mig_asegurados VALUES l_reg_mig_mcc(i);
        --
      EXCEPTION
      WHEN DML_ERRORS THEN
        --
        l_errors := SQL%bulk_exceptions.count;
        --
        dbms_output.put_line('l_errors:'||l_errors);
        --
        FOR i IN 1 .. l_errors
        LOOP
          --
          l_errno := SQL%BULK_EXCEPTIONS(i).error_code;
          l_msg   := SQLERRM(-l_errno);
          l_idx   := SQL%BULK_EXCEPTIONS(i).error_index;
          --
          p_control_error(g_user,'06_mig_asegurados','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
          --
        END LOOP;
        --
      END;
      --
      dbms_output.put_line('mig_asegurados - F - paso bullk');
      --
      COMMIT;
      --
      EXIT WHEN lc_mig_asegurados%NOTFOUND;
       --
     END LOOP;
     --
     gcant_a_cargar   := lc_mig_asegurados%ROWCOUNT;
     --
     SELECT COUNT(*) INTO gcant_a_cargar_bs FROM mig_asegurados_bs;
     SELECT COUNT(*) INTO gcant_cargada FROM mig_asegurados;
     --
     CLOSE lc_mig_asegurados;
     --
   END p_carga_asegurados;
   --
   /***************************************************************************
      PROCEDURE p_carga_riesgos
      Procedimiento que inserta los registros grabados en MIG_RIESGOS_bs, en la tabla
      MIG_RIESGOS de iAXIS.
   ***************************************************************************/
   PROCEDURE p_carga_riesgos
   IS
     --
     TYPE t_mig_riesgos IS TABLE OF mig_riesgos%ROWTYPE;
     l_reg_mig_mcc t_mig_riesgos;
     --
      CURSOR lc_mig_riesgos IS
       SELECT 17424 ncarga,1 CESTMIG, s.MIG_PK, s.MIG_FK, s.MIG_FK2,
                s.NRIESGO, 0 SSEGURO, s.NMOVIMA, s.FEFECTO, 0 SPERSON, s.NMOVIMB, s.FANULAC,
                s.TNATRIE, s.PDTOCOM, s.PRECARG, s.PDTOTEC, s.PRECCOM, s.TDESCRIE
       --SELECT COUNT(*)
         FROM mig_riesgos_bs s, mig_personas p, mig_seguros e
        WHERE 1 = 1
          AND s.mig_fk  = p.mig_pk
          AND s.mig_fk2 = e.mig_pk
          AND e.sseguro <> 0
          --AND p.idperson <> 0
          --AND s.mig_pk = '131050100DL0200681'
          ;
          --SELECT count(*) FROM mig_riesgos_bs s WHERE s.mig_pk = '131050100DL0200681';
     --
  BEGIN
    --
    -----------------------------------------
    --RIESGOS
    -----------------------------------------
    OPEN lc_mig_riesgos;
    LOOP
      --
      FETCH lc_mig_riesgos BULK COLLECT INTO l_reg_mig_mcc LIMIT 100000;  -- limit to 10k to avoid out of memory
      --
      dbms_output.put_line('mig_riesgos - I - paso bullk');
      --
      --FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
      --DELETE FROM mig_riesgos WHERE mig_pk = l_reg_mig_mcc(i).mig_pk;
      --
      BEGIN
        --
        FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
        INSERT INTO mig_riesgos VALUES l_reg_mig_mcc(i);
        --
      EXCEPTION
      WHEN DML_ERRORS THEN
        --
        l_errors := SQL%bulk_exceptions.count;
        --
        dbms_output.put_line('l_errors:'||l_errors);
        --
        FOR i IN 1 .. l_errors
        LOOP
          --
          l_errno := SQL%BULK_EXCEPTIONS(i).error_code;
          l_msg   := SQLERRM(-l_errno);
          l_idx   := SQL%BULK_EXCEPTIONS(i).error_index;
          --
          p_control_error(g_user,'10_mig_riesgos','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
          --
        END LOOP;
        --
      END;
      --
      dbms_output.put_line('mig_riesgos - F - paso bullk');
      --
      COMMIT;
      --
      EXIT WHEN lc_mig_riesgos%NOTFOUND;
       --
     END LOOP;
     --
     gcant_a_cargar   := lc_mig_riesgos%ROWCOUNT;
     --
     SELECT COUNT(*) INTO gcant_a_cargar_bs FROM mig_riesgos_bs;
     SELECT COUNT(*) INTO gcant_cargada FROM mig_riesgos;
     --
     CLOSE lc_mig_riesgos;
     --
   END p_carga_riesgos;
   --
   /***************************************************************************
      PROCEDURE p_carga_garanseg
      Procedimiento que inserta los registros grabados en MIG_SIN_TRAMITACION_bs, en la tabla
      MIG_SIN_TRAMITACION de iAXIS.
   ***************************************************************************/
   PROCEDURE p_carga_garanseg
   IS
     --
     TYPE t_mig_garanseg IS TABLE OF mig_garanseg%ROWTYPE;
     l_reg_mig_mcc t_mig_garanseg;
     --
      CURSOR lc_mig_garanseg IS
       SELECT 17426 ncarga,1 CESTMIG, a.MIG_PK, a.MIG_FK, a.CGARANT, a.NRIESGO, a.NMOVIMI, 0 SSEGURO,
            a.FINIEFE, a.ICAPITAL, a.PRECARG, a.IEXTRAP, a.IPRIANU, a.FFINEFE, a.IRECARG, a.IPRITAR, a.FALTA,
            a.CREVALI, a.PREVALI, a.IREVALI, a.NMOVIMA, a.PDTOCOM, a.IDTOCOM, a.TOTANU, 0 PDTOTEC, a.PRECCOM,
            a.IDTOTEC, a.IRECCOM, a.FINIVIG, a.FFINVIG, 0 CCOBPRIMA, 0 IPRIDEV
            --SELECT COUNT(*)
          FROM mig_garanseg_bs a, mig_seguros s, mig_movseguro m
         WHERE m.mig_pk = a.mig_fk
           AND s.mig_pk = m.mig_fk
           --AND s.sseguro <> 0
           --AND m.sseguro <> 0
          --AND s.mig_pk = '131050100DL0200681'
          ;
          --SELECT count(*) FROM mig_garanseg_bs s WHERE s.mig_pk = '131050100DL0200681';
     --
  BEGIN
    --
    dbms_output.put_line('mig_garanseg - I - paso bullk');
    -----------------------------------------
    --MIG_GARANSEG
    -----------------------------------------
    OPEN lc_mig_garanseg;
    LOOP
      --
      FETCH lc_mig_garanseg BULK COLLECT INTO l_reg_mig_mcc LIMIT 100000;  -- limit to 10k to avoid out of memory
      --
      --FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
      --DELETE FROM mig_garanseg WHERE mig_pk = l_reg_mig_mcc(i).mig_pk;
      --
      BEGIN
        --
        FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
        INSERT INTO mig_garanseg VALUES l_reg_mig_mcc(i);
        --
      EXCEPTION
      WHEN DML_ERRORS THEN
        --
        l_errors := SQL%bulk_exceptions.count;
        --
        dbms_output.put_line('l_errors:'||l_errors);
        --
        FOR i IN 1 .. l_errors
        LOOP
          --
          l_errno := SQL%BULK_EXCEPTIONS(i).error_code;
          l_msg   := SQLERRM(-l_errno);
          l_idx   := SQL%BULK_EXCEPTIONS(i).error_index;
          --
          p_control_error(g_user,'13_mig_garanseg','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
          --
        END LOOP;
        --
      END;
      --
      dbms_output.put_line('mig_garanseg - F - paso bullk');
      --
      COMMIT;
      --
      EXIT WHEN lc_mig_garanseg%NOTFOUND;
       --
     END LOOP;
     --
     gcant_a_cargar   := lc_mig_garanseg%ROWCOUNT;
     --
     SELECT COUNT(*) INTO gcant_a_cargar_bs FROM mig_garanseg_bs;
     SELECT COUNT(*) INTO gcant_cargada FROM mig_garanseg;
     --
     CLOSE lc_mig_garanseg;
     --
   END p_carga_garanseg;
   --
   /***************************************************************************
      PROCEDURE p_carga_clausuesp
      Procedimiento que inserta los registros grabados en MIG_CLAUSUESP_bs, en la tabla
      MIG_CLAUSUESP de iAXIS.
   ***************************************************************************/
   PROCEDURE p_carga_clausuesp
   IS
     --
     TYPE t_mig_clausuesp IS TABLE OF mig_clausuesp%ROWTYPE;
     l_reg_mig_mcc t_mig_clausuesp;
     --
      CURSOR lc_mig_clausuesp IS
       SELECT 17427 ncarga,1 CESTMIG, a.MIG_PK, a.MIG_FK, a.NMOVIMI, 0 SSEGURO, a.CCLAESP,
              a.NORDCLA, a.NRIESGO, a.FINICLAU, a.SCLAGEN, a.TCLAESP, a.FFINCLAU
          --SELECT COUNT(*)
          FROM mig_clausuesp_bs a, mig_movseguro m --,mig_seguros s,
         WHERE 1 = 1
           --AND s.mig_pk = m.mig_fk
           AND m.mig_pk = a.mig_fk
          --AND s.mig_pk = '131050100DL0200681'
          ;
          --SELECT count(*) FROM mig_clausuesp_bs s WHERE s.mig_pk = '131050100DL0200681';
     --
  BEGIN
    --
    -----------------------------------------
    --CLAUSUESP
    -----------------------------------------
    OPEN lc_mig_clausuesp;
    LOOP
      --
      FETCH lc_mig_clausuesp BULK COLLECT INTO l_reg_mig_mcc LIMIT 10000;  -- limit to 10k to avoid out of memory
      --
      FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
      DELETE FROM mig_clausuesp WHERE mig_pk = l_reg_mig_mcc(i).mig_pk;
      --
      BEGIN
        --
        FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
        INSERT INTO mig_clausuesp VALUES l_reg_mig_mcc(i);
        --
      EXCEPTION
      WHEN DML_ERRORS THEN
        --
        l_errors := SQL%bulk_exceptions.count;
        --
        dbms_output.put_line('l_errors:'||l_errors);
        --
        FOR i IN 1 .. l_errors
        LOOP
          --
          l_errno := SQL%BULK_EXCEPTIONS(i).error_code;
          l_msg   := SQLERRM(-l_errno);
          l_idx   := SQL%BULK_EXCEPTIONS(i).error_index;
          --
          p_control_error(g_user,'16_mig_clausuesp','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
          --
        END LOOP;
        --
      END;
      --
      dbms_output.put_line('mig_clausuesp - F - paso bullk');
      --
      COMMIT;
      --
      EXIT WHEN lc_mig_clausuesp%NOTFOUND;
       --
     END LOOP;
     --
     --
     gcant_a_cargar   := lc_mig_clausuesp%ROWCOUNT;
     --
     SELECT COUNT(*) INTO gcant_a_cargar_bs FROM mig_clausuesp_bs;
     SELECT COUNT(*) INTO gcant_cargada FROM mig_clausuesp;
     --
     CLOSE lc_mig_clausuesp;
     --
   END p_carga_clausuesp;
   --
   /***************************************************************************
      PROCEDURE p_carga_benespseg
      Procedimiento que inserta los registros grabados en MIG_BENESPSEG_bs, en la tabla
      MIG_BENESPSEG de iAXIS.
   ***************************************************************************/
   PROCEDURE p_carga_benespseg
   IS
     --
     TYPE t_mig_benespseg IS TABLE OF mig_benespseg%ROWTYPE;
     l_reg_mig_mcc t_mig_benespseg;
     --
      CURSOR lc_mig_benespseg IS
       SELECT 17428 ncarga,1 CESTMIG, a.MIG_PK, a.MIG_FK, a.MIG_FK2, a.NBENEF NBENEFIC, 0 SSEGURO, a.NRIESGO, a.CGARANT,
              a.NMOVIMI, 0 SPERSON, NULL CTIPIDE_CONT, NULL NNUMIDE_CONT, NULL TAPELLI1_CONT, NULL TAPELLI2_CONT, NULL TNOMBRE1_CONT,
              NULL TNOMBRE2_CONT, NULL FINIBEN, NULL FFINBEN, a.TIPO_DE_BENEFICIARIO CTIPBEN, a.PARENTESCO CPAREN, a.PORCENTAJE PPARTICIP,
              a.CUSUARI, a.FMOVIMI, a.CESTADO, NULL CTIPOCON
         --SELECT *
          FROM mig_benespseg_bs a , mig_movseguro m --,mig_seguros s,
         WHERE 1 = 1
           --AND s.mig_pk = m.mig_fk
           AND m.mig_pk = a.mig_fk
          --AND s.mig_pk = '131050100DL0200681'
          ;
          --SELECT * FROM mig_benespseg s WHERE s.mig_pk = '131050100DL0200681';
     --
  BEGIN
    --
    -----------------------------------------
    --MIG_BENESPSEG
    -----------------------------------------
    OPEN lc_mig_benespseg;
    LOOP
      --
      FETCH lc_mig_benespseg BULK COLLECT INTO l_reg_mig_mcc LIMIT 100000;  -- limit to 10k to avoid out of memory
      --
      --FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
      --DELETE FROM mig_benespseg WHERE mig_pk = l_reg_mig_mcc(i).mig_pk;
      --
      BEGIN
        --
        FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
        INSERT INTO mig_benespseg VALUES l_reg_mig_mcc(i);
        --
      EXCEPTION
      WHEN DML_ERRORS THEN
        --
        l_errors := SQL%bulk_exceptions.count;
        --
        dbms_output.put_line('l_errors:'||l_errors);
        --
        FOR i IN 1 .. l_errors
        LOOP
          --
          l_errno := SQL%BULK_EXCEPTIONS(i).error_code;
          l_msg   := SQLERRM(-l_errno);
          l_idx   := SQL%BULK_EXCEPTIONS(i).error_index;
          --
          p_control_error(g_user,'19_mig_benespseg','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
          --
        END LOOP;
        --
      END;
      --
      dbms_output.put_line('mig_benespseg - F - paso bullk');
      --
      COMMIT;
      --
      EXIT WHEN lc_mig_benespseg%NOTFOUND;
       --
     END LOOP;
     --
     gcant_a_cargar   := lc_mig_benespseg%ROWCOUNT;
     --
     SELECT COUNT(*) INTO gcant_a_cargar_bs FROM mig_benespseg_bs;
     SELECT COUNT(*) INTO gcant_cargada FROM mig_benespseg;
     --
     CLOSE lc_mig_benespseg;
     --
   END p_carga_benespseg;
   --
   /***************************************************************************
      PROCEDURE p_carga_pregunseg
      Procedimiento que inserta los registros grabados en MIG_PREGUNSEG_bs, en la tabla
      MIG_PREGUNSEG de iAXIS.
   ***************************************************************************/
   PROCEDURE p_carga_pregunseg
   IS
     --
     TYPE t_mig_pregunseg IS TABLE OF mig_pregunseg%ROWTYPE;
     l_reg_mig_mcc t_mig_pregunseg;
     --
      CURSOR lc_mig_pregunseg IS
       SELECT 17429 ncarga,1 CESTMIG, a.MIG_PK, a.MIG_FK, a.NRIESGO, 0 SSEGURO , a.CPREGUN, a.CRESPUE, a.NMOVIMI
          --SELECT COUNT(*)
            FROM mig_pregunseg_bs a, mig_seguros s , codipregun p , pregunpro pro
           --FROM mig_pregunseg_bs;
        WHERE 1 = 1
             AND s.mig_pk = a.mig_fk
             AND p.cpregun = a.cpregun
             AND pro.cpregun = a.cpregun
             AND pro.sproduc = s.sproduc
             --AND a.mig_pk IN ('128010100GU0049411010101030', '101010100GU0001451010101016')
        ORDER BY a.mig_pk
          --AND s.mig_pk = '131050100DL0200681'
          ;
          --SELECT * FROM mig_pregunseg_bs s WHERE s.mig_pk = '131050100DL0200681';
     --
  BEGIN
    --
    -----------------------------------------
    --MIG_PREGUNSEG
    -----------------------------------------
    DELETE control_error s WHERE TRUNC(s.fecha) = TRUNC(SYSDATE) AND s.donde = '22_mig_pregunseg';
    --
    OPEN lc_mig_pregunseg;
    LOOP
      --
      FETCH lc_mig_pregunseg BULK COLLECT INTO l_reg_mig_mcc LIMIT 100000;  -- limit to 10k to avoid out of memory
      --
      dbms_output.put_line('mig_pregunseg - I - paso bullk');
      --
      --FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
      --DELETE FROM mig_pregunseg WHERE mig_pk = l_reg_mig_mcc(i).mig_pk;
      --
      BEGIN
        --
        FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
        INSERT INTO mig_pregunseg VALUES l_reg_mig_mcc(i);
        --
      EXCEPTION
      WHEN DML_ERRORS THEN
        --
        l_errors := SQL%bulk_exceptions.count;
        --
        dbms_output.put_line('l_errors:'||l_errors);
        --
        FOR i IN 1 .. l_errors
        LOOP
          --
          l_errno := SQL%BULK_EXCEPTIONS(i).error_code;
          l_msg   := SQLERRM(-l_errno);
          l_idx   := SQL%BULK_EXCEPTIONS(i).error_index;
          --
          p_control_error(g_user,'22_mig_pregunseg','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
          --
        END LOOP;
        --
      END;
      --
      dbms_output.put_line('mig_pregunseg - F - paso bullk');
      --
      COMMIT;
      --
      EXIT WHEN lc_mig_pregunseg%NOTFOUND;
       --
     END LOOP;
     --
     gcant_a_cargar   := lc_mig_pregunseg%ROWCOUNT;
     --
     SELECT COUNT(*) INTO gcant_a_cargar_bs FROM mig_pregunseg_bs;
     SELECT COUNT(*) INTO gcant_cargada FROM mig_pregunseg;
     CLOSE lc_mig_pregunseg;
     --
   END p_carga_pregunseg;
   --
   /***************************************************************************
      PROCEDURE p_carga_ctaseguro
      Procedimiento que inserta los registros grabados en MIG_CTASEGURO_bs, en la tabla
      MIG_CTASEGURO de iAXIS.
   ***************************************************************************
   PROCEDURE p_carga_ctaseguro
   IS
     --
     TYPE t_mig_ctaseguro IS TABLE OF mig_ctaseguro%ROWTYPE;
     l_reg_mig_mcc t_mig_ctaseguro;
     --
      CURSOR lc_mig_ctaseguro IS
       SELECT 17428 NCARGA,1 CESTMIG, 0 SSEGURO,  a.MIG_PK,  a.MIG_FK,  a.FCONTAB,
       a.NNUMLIN,  a.FFECMOV,  a.FVALMOV,  a.CMOVIMI,  a.IMOVIMI,  a.CCALINT,  a.IMOVIM2,
       a.NRECIBO,  a.NSINIES,  a.CMOVANU,  a.SMOVREC,  a.CESTA,  a.NUNIDAD,  a.CESTADO,
       a.FASIGN,  a.NPARPLA,  a.CESTPAR,  a.IEXCESO,  a.SPERMIN,  a.SIDEPAG,  a.CTIPAPOR,  a.SRECREN
          FROM mig_ctaseguro_bs a, mig_seguros s
         WHERE s.mig_pk = a.mig_fk
      ORDER BY a.mig_pk
          --AND s.mig_pk = '131050100DL0200681'
          ;
          --SELECT * FROM mig_ctaseguro_conf s WHERE s.mig_pk = '131050100DL0200681';
     --
  BEGIN
    --
    -----------------------------------------
    --CTASEGURO
    -----------------------------------------
    OPEN lc_mig_ctaseguro;
    LOOP
      --
      FETCH lc_mig_ctaseguro BULK COLLECT INTO l_reg_mig_mcc LIMIT 10000;  -- limit to 10k to avoid out of memory
      --
      dbms_output.put_line('ctaseguro - I - paso bullk');
      --
      dbms_output.put_line('...');
      --
      --FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
      --DELETE FROM mig_ctaseguro WHERE mig_pk = l_reg_mig_mcc(i).mig_pk;
      --
      BEGIN
        --
        FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
        INSERT INTO mig_ctaseguro VALUES l_reg_mig_mcc(i);
        --
      EXCEPTION
      WHEN DML_ERRORS THEN
        --
        l_errors := SQL%bulk_exceptions.count;
        --
        dbms_output.put_line('l_errors:'||l_errors);
        --
        FOR i IN 1 .. l_errors
        LOOP
          --
          l_errno := SQL%BULK_EXCEPTIONS(i).error_code;
          l_msg   := SQLERRM(-l_errno);
          l_idx   := SQL%BULK_EXCEPTIONS(i).error_index;
          --
          p_control_error(g_user,'25_mig_ctaseguro','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
          --
        END LOOP;
        --
      END;
      --
      dbms_output.put_line('ctaseguro - F - paso bullk');
      --
      COMMIT;
      --
      EXIT WHEN lc_mig_ctaseguro%NOTFOUND;
       --
     END LOOP;
     --
     gcant_a_cargar   := lc_mig_ctaseguro%ROWCOUNT;
     --
     SELECT COUNT(*) INTO gcant_a_cargar_bs FROM mig_ctaseguro_bs;
     SELECT COUNT(*) INTO gcant_cargada FROM mig_ctaseguro;
     CLOSE lc_mig_ctaseguro;
     --
   END p_carga_ctaseguro;*/
   --
   /***************************************************************************
      PROCEDURE p_carga_agensegu
      Procedimiento que inserta los registros grabados en MIG_AGENSEGU_bs, en la tabla
      MIG_AGENSEGU de iAXIS.
   ***************************************************************************/
   PROCEDURE p_carga_agensegu
   IS
     --
     TYPE t_mig_agensegu IS TABLE OF mig_agensegu%ROWTYPE;
     l_reg_mig_mcc t_mig_agensegu;
     --
      CURSOR lc_mig_agensegu IS
       SELECT 17432 NCARGA,1 CESTMIG, a.MIG_PK, a.MIG_FK, 0 SSEGURO,
              a.FALTA, a.CTIPREG, a.CESTADO, a.TTITULO, a.FFINALI, a.TTEXTOS, a.CMANUAL
          FROM mig_agensegu_bs a, mig_seguros s
         WHERE s.mig_pk = a.mig_fk
      ORDER BY a.mig_pk
          --AND s.mig_pk = '131050100DL0200681'
          ;
          --SELECT * FROM mig_agensegu_conf s WHERE s.mig_pk = '131050100DL0200681';
     --
     dml_errors EXCEPTION;
     PRAGMA EXCEPTION_INIT(dml_errors, -24381);
     l_errors  NUMBER;
     l_errno   NUMBER;
     l_msg     VARCHAR2(4000);
     l_idx     NUMBER;
     --
  BEGIN
    --
    -----------------------------------------
    --AGENSEGU
    -----------------------------------------
    OPEN lc_mig_agensegu;
    LOOP
      --
      FETCH lc_mig_agensegu BULK COLLECT INTO l_reg_mig_mcc LIMIT 10000;  -- limit to 10k to avoid out of memory
      --
      dbms_output.put_line('agensegu - I - paso bullk');
      --
      dbms_output.put_line('...');
      --
      --FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
      --DELETE FROM mig_agensegu WHERE mig_pk = l_reg_mig_mcc(i).mig_pk;
      --
      BEGIN
        --
        FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
        INSERT INTO mig_agensegu VALUES l_reg_mig_mcc(i);
        --
      EXCEPTION
      WHEN DML_ERRORS THEN
        --
        l_errors := SQL%bulk_exceptions.count;
        --
        dbms_output.put_line('l_errors:'||l_errors);
        --
        FOR i IN 1 .. l_errors
        LOOP
          --
          l_errno := SQL%BULK_EXCEPTIONS(i).error_code;
          l_msg   := SQLERRM(-l_errno);
          l_idx   := SQL%BULK_EXCEPTIONS(i).error_index;
          --
          p_control_error(g_user,'31_mig_agensegu','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
          --
        END LOOP;
        --
      END;
      --
      dbms_output.put_line('MIG_AGENSEGU - F - paso bullk');
      --
      COMMIT;
      --
      EXIT WHEN lc_mig_agensegu%NOTFOUND;
       --
     END LOOP;
     --
     gcant_a_cargar   := lc_mig_agensegu%ROWCOUNT;
     --
     SELECT COUNT(*) INTO gcant_a_cargar_bs FROM mig_agensegu_bs;
     SELECT COUNT(*) INTO gcant_cargada FROM mig_agensegu;
     CLOSE lc_mig_agensegu;
     --
   END p_carga_agensegu;
   --
   /***************************************************************************
      PROCEDURE p_carga_mig_pregungaranseg
      Procedimiento que inserta los registros grabados en MIG_PREGUNGARANSEG_bs, en la tabla
      MIG_PREGUNGARANSEG de iAXIS.
   ***************************************************************************/
   PROCEDURE p_carga_pregungaranseg
   IS
     --
     TYPE t_mig_pregungaranseg IS TABLE OF mig_pregungaranseg%ROWTYPE;
     l_reg_mig_mcc t_mig_pregungaranseg;
     --
      CURSOR lc_mig_pregungaranseg IS
       SELECT 17433 NCARGA,1 CESTMIG, a.MIG_PK, a.MIG_FK,
              0 SSEGURO, a.NRIESGO, a.CGARANT, a.CPREGUN, to_number(replace(a.CRESPUE, '.', ','))
           --SELECT COUNT(*)
  FROM     mig_pregungaranseg a, mig_seguros s, mig_movseguro m, codipregun p
     WHERE m.mig_pk = a.mig_fk
       AND s.mig_pk = m.mig_fk
       AND p.cpregun = a.cpregun
          ;
          --SELECT * FROM mig_pregungaranseg_conf s WHERE s.mig_pk = '131050100DL0200681';
     --
  BEGIN
    --
    -----------------------------------------
    --MIG_PREGUNGARANSEG
    -----------------------------------------
    OPEN lc_mig_pregungaranseg;
    LOOP
      --
      FETCH lc_mig_pregungaranseg BULK COLLECT INTO l_reg_mig_mcc LIMIT 10000;  -- limit to 10k to avoid out of memory
      --
      dbms_output.put_line('mig_pregungaranseg - I - paso bullk');
      --
      dbms_output.put_line('...');
      --
      --FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
      --DELETE FROM mig_pregungaranseg WHERE mig_pk = l_reg_mig_mcc(i).mig_pk;
      --
      BEGIN
        --
        FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
        INSERT INTO mig_pregungaranseg VALUES l_reg_mig_mcc(i);
        --
      EXCEPTION
      WHEN DML_ERRORS THEN
        --
        l_errors := SQL%bulk_exceptions.count;
        --
        dbms_output.put_line('l_errors:'||l_errors);
        --
        FOR i IN 1 .. l_errors
        LOOP
          --
          l_errno := SQL%BULK_EXCEPTIONS(i).error_code;
          l_msg   := SQLERRM(-l_errno);
          l_idx   := SQL%BULK_EXCEPTIONS(i).error_index;
          --
          p_control_error(g_user,'34_mig_pregungaranseg','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
          --
        END LOOP;
        --
      END;
      --
      dbms_output.put_line('mig_pregungaranseg - F - paso bullk');
      --
      COMMIT;
      --
      EXIT WHEN lc_mig_pregungaranseg%NOTFOUND;
       --
     END LOOP;
     --
     gcant_a_cargar   := lc_mig_pregungaranseg%ROWCOUNT;
     --
     SELECT COUNT(*) INTO gcant_a_cargar_bs FROM mig_pregungaranseg_bs;
     SELECT COUNT(*) INTO gcant_cargada FROM mig_pregungaranseg;
     CLOSE lc_mig_pregungaranseg;
     --
   END p_carga_pregungaranseg;
   --
   /***************************************************************************
      PROCEDURE p_carga_sitriesgo
      Procedimiento que inserta los registros grabados en MIG_SITRIESGO_bs, en la tabla
      MIG_SITRIESGO de iAXIS.
   ***************************************************************************/
   PROCEDURE p_carga_sitriesgo
   IS
     --
     TYPE t_mig_sitriesgo IS TABLE OF mig_sitriesgo%ROWTYPE;
     l_reg_mig_mcc t_mig_sitriesgo;
     --
      CURSOR lc_mig_sitriesgo IS
       SELECT 17425 NCARGA,1 CESTMIG, a.MIG_PK,  a.MIG_FK,  a.NRIESGO,  0 SSEGURO,  NVL(a.iddomici, '0') TDOMICI,  a.CPROVIN,  a.CPOSTAL,
       a.CPOBLAC,  a.CSIGLAS,  a.TNOMVIA,  a.NNUMVIA,  a.TCOMPLE,  NULL CCIUDAD,
       a.FGISX,  a.FGISY,  a.FGISZ,  a.CVALIDA
       /*Ojo se estarían perdiendo unos campos informados en _conf*/
       --SELECT *
        FROM mig_sitriesgo_bs a, mig_riesgos r
       WHERE r.mig_pk  = a.mig_fk
         AND a.cprovin IS NOT NULL
    ORDER BY a.mig_pk
          ;
          --SELECT * FROM mig_sitriesgo_conf s WHERE s.mig_pk = '131050100DL0200681';
     --
  BEGIN
    --
    -----------------------------------------
    --SITRIESGO
    -----------------------------------------
    OPEN lc_mig_sitriesgo;
    LOOP
      --
      FETCH lc_mig_sitriesgo BULK COLLECT INTO l_reg_mig_mcc LIMIT 100000;  -- limit to 10k to avoid out of memory
      --
      dbms_output.put_line('sitriesgo - I - paso bullk');
      --
      dbms_output.put_line('...');
      --
      --FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
      --DELETE FROM mig_sitriesgo WHERE mig_pk = l_reg_mig_mcc(i).mig_pk;
      --
      BEGIN
        --
        FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
        INSERT INTO mig_sitriesgo VALUES l_reg_mig_mcc(i);
        --
      EXCEPTION
      WHEN DML_ERRORS THEN
        --
        l_errors := SQL%bulk_exceptions.count;
        --
        dbms_output.put_line('l_errors:'||l_errors);
        --
        FOR i IN 1 .. l_errors
        LOOP
          --
          l_errno := SQL%BULK_EXCEPTIONS(i).error_code;
          l_msg   := SQLERRM(-l_errno);
          l_idx   := SQL%BULK_EXCEPTIONS(i).error_index;
          --
          p_control_error(g_user,'37_mig_sitriesgo','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
          --
        END LOOP;
        --
      END;
      --
      dbms_output.put_line('sitriesgo - F - paso bullk');
      --
      COMMIT;
      --
      EXIT WHEN lc_mig_sitriesgo%NOTFOUND;
       --
     END LOOP;
     --
     gcant_a_cargar   := lc_mig_sitriesgo%ROWCOUNT;
     --
     SELECT COUNT(*) INTO gcant_a_cargar_bs FROM mig_sitriesgo_bs;
     SELECT COUNT(*) INTO gcant_cargada FROM mig_sitriesgo;
     CLOSE lc_mig_sitriesgo;
     --
   END p_carga_sitriesgo;
   --
   /***************************************************************************
      PROCEDURE p_carga_ctgar_contragarantia
      Procedimiento que inserta los registros grabados en MIG_CTGAR_CONTRAGARANTIA_bs, en la tabla
      MIG_CTGAR_CONTRAGARANTIA de iAXIS.
   ****************************************************************************/
   PROCEDURE p_carga_ctgar_contragarantia
   IS
     --
     TYPE t_mig_ctgar_contragarantia IS TABLE OF mig_ctgar_contragarantia%ROWTYPE;
     l_reg_mig_mcc t_mig_ctgar_contragarantia;
     --
      CURSOR lc_mig_ctgar_contragarantia IS
       SELECT 17434 NCARGA,1 CESTMIG, a.MIG_PK, a.MIG_FK, a.SCONTGAR, a.NMOVIMI, a.TDESCRIPCION,
              a.CTIPO, a.CCLASE, a.CMONEDA, a.IVALOR, a.FVENCIMI, a.NEMPRESA, a.NRADICA, a.FCREA, a.DOCUMENTO,
              a.CTENEDOR, a.TOBSTEN, a.CESTADO, a.CORIGEN, a.TCAUSA, a.TAUXILIA, a.CIMPRESO, a.CUSUALT, a.FALTA
       --SELECT COUNT(*)
        FROM MIG_CTGAR_CONTRAGARANTIA_bs a
       WHERE 1 = 1
          --AND a.mig_pk IN ('RD2002507102', 'RD31090590131', 'RD7004255107', 'RD2002888102', 'RD23020493123', 'CF100005102', 'CF100007102')
       ORDER BY a.mig_pk
          ;
          --SELECT * FROM mig_ctgar_contragarantia_conf s WHERE s.mig_pk = '131050100DL0200681';
          --SELECT * FROM MIG_CTGAR_DET_bs WHERE cbanco IS NOT NULL;
     --
     dml_errors EXCEPTION;
     PRAGMA EXCEPTION_INIT(dml_errors, -24381);
     l_errors  NUMBER;
     l_errno   NUMBER;
     l_msg     VARCHAR2(4000);
     l_idx     NUMBER;
     --
  BEGIN
    --
    -----------------------------------------
    --CTGAR_CONTRAGARANTIA
    -----------------------------------------
    OPEN lc_mig_ctgar_contragarantia;
    LOOP
      --
      FETCH lc_mig_ctgar_contragarantia BULK COLLECT INTO l_reg_mig_mcc LIMIT 100000;  -- limit to 10k to avoid out of memory
      --
      dbms_output.put_line('ctgar_contragarantia - I - paso bullk');
      --
      dbms_output.put_line('...');
      --
      --FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
      --DELETE FROM mig_ctgar_contragarantia WHERE mig_pk = l_reg_mig_mcc(i).mig_pk;
      --
      BEGIN
        --
        FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
        INSERT INTO mig_ctgar_contragarantia VALUES l_reg_mig_mcc(i);
        --
      EXCEPTION
      WHEN DML_ERRORS THEN
        --
        l_errors := SQL%bulk_exceptions.count;
        --
        dbms_output.put_line('l_errors:'||l_errors);
        --
        FOR i IN 1 .. l_errors
        LOOP
          --
          l_errno := SQL%BULK_EXCEPTIONS(i).error_code;
          l_msg   := SQLERRM(-l_errno);
          l_idx   := SQL%BULK_EXCEPTIONS(i).error_index;
          --
          p_control_error(g_user,'40_mig_ctgar_contragarantia','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
          --
        END LOOP;
        --
      END;
      --
      dbms_output.put_line('ctgar_contragarantia - F - paso bullk');
      --
      EXIT WHEN lc_mig_ctgar_contragarantia%NOTFOUND;
       --
     END LOOP;
     --
     gcant_a_cargar   := lc_mig_ctgar_contragarantia%ROWCOUNT;
     --
     SELECT COUNT(*) INTO gcant_a_cargar_bs FROM mig_ctgar_contragarantia_bs;
     SELECT COUNT(*) INTO gcant_cargada FROM mig_ctgar_contragarantia;
     CLOSE lc_mig_ctgar_contragarantia;
     --
   END p_carga_ctgar_contragarantia;
   --
   /***************************************************************************
      PROCEDURE p_carga_ctgar_seguro
      Procedimiento que inserta los registros grabados en MIG_CTGAR_SEGURO_bs, en la tabla
      MIG_CTGAR_SEGURO de iAXIS.
   ****************************************************************************/
   PROCEDURE p_carga_ctgar_seguro
   IS
     --
     TYPE t_mig_ctgar_seguro IS TABLE OF mig_ctgar_seguro%ROWTYPE;
     l_reg_mig_mcc t_mig_ctgar_seguro;
     --
      CURSOR lc_mig_ctgar_seguro IS
         SELECT 17435 ncarga,1 cestmig, a.mig_pk, a.mig_fk, c.scontgar
           FROM mig_ctgar_seguro_bs a, mig_ctgar_contragarantia_bs c
         WHERE 1 = 1
           AND a.mig_fk2 = c.mig_pk
      ORDER BY a.mig_pk;
          --SELECT * FROM mig_ctgar_seguro_conf s WHERE s.mig_pk = '131050100DL0200681';
          --SELECT * FROM MIG_CTGAR_DET_bs WHERE cbanco IS NOT NULL;
     --
     dml_errors EXCEPTION;
     PRAGMA EXCEPTION_INIT(dml_errors, -24381);
     l_errors  NUMBER;
     l_errno   NUMBER;
     l_msg     VARCHAR2(4000);
     l_idx     NUMBER;
     --
  BEGIN
    --
    -----------------------------------------
    --CTGAR_SEGURO
    -----------------------------------------
    OPEN lc_mig_ctgar_seguro;
    LOOP
      --
      FETCH lc_mig_ctgar_seguro BULK COLLECT INTO l_reg_mig_mcc LIMIT 100000;  -- limit to 10k to avoid out of memory
      --
      dbms_output.put_line('ctgar_seguro - I - paso bullk');
      --
      dbms_output.put_line('...');
      --
      --FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
      --DELETE FROM mig_ctgar_seguro WHERE mig_pk = l_reg_mig_mcc(i).mig_pk;
      --
      BEGIN
        --
        FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
        INSERT INTO mig_ctgar_seguro VALUES l_reg_mig_mcc(i);
        --
      EXCEPTION
      WHEN DML_ERRORS THEN
        --
        l_errors := SQL%bulk_exceptions.count;
        --
        dbms_output.put_line('l_errors:'||l_errors);
        --
        FOR i IN 1 .. l_errors
        LOOP
          --
          l_errno := SQL%BULK_EXCEPTIONS(i).error_code;
          l_msg   := SQLERRM(-l_errno);
          l_idx   := SQL%BULK_EXCEPTIONS(i).error_index;
          --
          p_control_error(g_user,'47_mig_ctgar_seguro','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
          --
        END LOOP;
        --
      END;
      --
      dbms_output.put_line('ctgar_seguro - F - paso bullk');
      --
      EXIT WHEN lc_mig_ctgar_seguro%NOTFOUND;
       --
     END LOOP;
     --
     gcant_a_cargar   := lc_mig_ctgar_seguro%ROWCOUNT;
     --
     SELECT COUNT(*) INTO gcant_a_cargar_bs FROM mig_ctgar_seguro_bs;
     SELECT COUNT(*) INTO gcant_cargada FROM mig_ctgar_seguro;
     CLOSE lc_mig_ctgar_seguro;
     --
   END p_carga_ctgar_seguro;
   --
   /***************************************************************************
      PROCEDURE p_carga_age_corretaje
      Procedimiento que inserta los registros grabados en MIG_AGE_CORRETAJE_BS, en la tabla
      MIG_AGE_CORRETAJE de iAXIS.
   ****************************************************************************/
   PROCEDURE p_carga_age_corretaje
   IS
     --
     TYPE t_mig_age_corretaje IS TABLE OF mig_age_corretaje%ROWTYPE;
     l_reg_mig_mcc t_mig_age_corretaje;
     --
      CURSOR lc_mig_age_corretaje IS
       SELECT 17436 NCARGA,1 CESTMIG, a.MIG_PK, a.MIG_FK,
              0 SSEGURO, a.NMOVIMI, a.NORDAGE, a.CAGENTE, a.PCOMISI, a.PPARTICI, a.ISLIDER
       --SELECT COUNT(*)
        FROM mig_age_corretaje_bs a, mig_seguros s
       WHERE 1 = 1
          AND a.mig_fk = s.mig_pk
    ORDER BY a.mig_pk;
          --SELECT * FROM mig_age_corretaje_conf s WHERE s.mig_pk = '131050100DL0200681';
          --SELECT * FROM MIG_CTGAR_DET_bs WHERE cbanco IS NOT NULL;
     --
     dml_errors EXCEPTION;
     PRAGMA EXCEPTION_INIT(dml_errors, -24381);
     l_errors  NUMBER;
     l_errno   NUMBER;
     l_msg     VARCHAR2(4000);
     l_idx     NUMBER;
     --
  BEGIN
    --
    -----------------------------------------
    --AGE_CORRETAJE
    -----------------------------------------
    OPEN lc_mig_age_corretaje;
    LOOP
      --
      FETCH lc_mig_age_corretaje BULK COLLECT INTO l_reg_mig_mcc LIMIT 100000;  -- limit to 10k to avoid out of memory
      --
      dbms_output.put_line('age_corretaje - I - paso bullk');
      --
      dbms_output.put_line('...');
      --
      --FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
      --DELETE FROM mig_age_corretaje WHERE mig_pk = l_reg_mig_mcc(i).mig_pk;
      --
      BEGIN
        --
        FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
        INSERT INTO mig_age_corretaje VALUES l_reg_mig_mcc(i);
        --
      EXCEPTION
      WHEN DML_ERRORS THEN
        --
        l_errors := SQL%bulk_exceptions.count;
        --
        dbms_output.put_line('l_errors:'||l_errors);
        --
        FOR i IN 1 .. l_errors
        LOOP
          --
          l_errno := SQL%BULK_EXCEPTIONS(i).error_code;
          l_msg   := SQLERRM(-l_errno);
          l_idx   := SQL%BULK_EXCEPTIONS(i).error_index;
          --
          p_control_error(g_user,'50_mig_age_corretaje','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
          --
        END LOOP;
        --
      END;
      --
      dbms_output.put_line('age_corretaje - F - paso bullk');
      --
      EXIT WHEN lc_mig_age_corretaje%NOTFOUND;
       --
     END LOOP;
     --
     gcant_a_cargar   := lc_mig_age_corretaje%ROWCOUNT;
     --
     SELECT COUNT(*) INTO gcant_a_cargar_bs FROM mig_age_corretaje_bs;
     SELECT COUNT(*) INTO gcant_cargada FROM mig_age_corretaje;
     CLOSE lc_mig_age_corretaje;
     --
   END p_carga_age_corretaje;
   --
   /***************************************************************************
      PROCEDURE p_carga_psu_retenidas
      Procedimiento que inserta los registros grabados en MIG_psu_retenidas_BS, en la tabla
      MIG_psu_retenidas de iAXIS.
   ****************************************************************************/
   PROCEDURE p_carga_psu_retenidas
   IS
     --
     TYPE t_mig_psu_retenidas IS TABLE OF mig_psu_retenidas%ROWTYPE;
     l_reg_mig_mcc t_mig_psu_retenidas;
     --
      CURSOR lc_mig_psu_retenidas IS
       SELECT 17437 NCARGA,1 CESTMIG, a.MIG_PK, a.MIG_FK, a.SSEGURO, a.FMOVIMI, a.CMOTRET, a.CUSURET, a.FFECRET,
              a.CUSUAUT, a.FFECAUT, a.OBSERV, a.CDETMOTREC, a.POSTPPER, a.PERPOST
       --SELECT COUNT(*)
        FROM mig_psu_retenidas_bs a, mig_movseguro s
       WHERE 1 = 1
          AND a.mig_fk = s.mig_pk
    ORDER BY a.mig_pk;
          --SELECT * FROM mig_psu_retenidas_conf s WHERE s.mig_pk = '131050100DL0200681';
          --SELECT * FROM MIG_CTGAR_DET_bs WHERE cbanco IS NOT NULL;
     --
     dml_errors EXCEPTION;
     PRAGMA EXCEPTION_INIT(dml_errors, -24381);
     l_errors  NUMBER;
     l_errno   NUMBER;
     l_msg     VARCHAR2(4000);
     l_idx     NUMBER;
     --
  BEGIN
    --
    -----------------------------------------
    --psu_retenidas
    -----------------------------------------
    OPEN lc_mig_psu_retenidas;
    LOOP
      --
      FETCH lc_mig_psu_retenidas BULK COLLECT INTO l_reg_mig_mcc LIMIT 100000;  -- limit to 10k to avoid out of memory
      --
      dbms_output.put_line('psu_retenidas - I - paso bullk');
      --
      dbms_output.put_line('...');
      --
      --FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
      --DELETE FROM mig_psu_retenidas WHERE mig_pk = l_reg_mig_mcc(i).mig_pk;
      --
      BEGIN
        --
        FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
        INSERT INTO mig_psu_retenidas VALUES l_reg_mig_mcc(i);
        --
      EXCEPTION
      WHEN DML_ERRORS THEN
        --
        l_errors := SQL%bulk_exceptions.count;
        --
        dbms_output.put_line('l_errors:'||l_errors);
        --
        FOR i IN 1 .. l_errors
        LOOP
          --
          l_errno := SQL%BULK_EXCEPTIONS(i).error_code;
          l_msg   := SQLERRM(-l_errno);
          l_idx   := SQL%BULK_EXCEPTIONS(i).error_index;
          --
          p_control_error(g_user,'65_mig_psu_retenidas','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
          --
        END LOOP;
        --
      END;
      --
      dbms_output.put_line('psu_retenidas - F - paso bullk');
      --
      EXIT WHEN lc_mig_psu_retenidas%NOTFOUND;
       --
     END LOOP;
     --
     gcant_a_cargar   := lc_mig_psu_retenidas%ROWCOUNT;
     --
     SELECT COUNT(*) INTO gcant_a_cargar_bs FROM mig_psu_retenidas_bs;
     SELECT COUNT(*) INTO gcant_cargada FROM mig_psu_retenidas;
     CLOSE lc_mig_psu_retenidas;
     --
   END p_carga_psu_retenidas;
   --
   /***************************************************************************
      PROCEDURE p_carga_bf_bonfranseg
      Procedimiento que inserta los registros grabados en MIG_BF_BONFRANSEG_BS, en la tabla
      MIG_BF_BONFRANSEG de iAXIS.
   ****************************************************************************
   PROCEDURE p_carga_bf_bonfranseg
   IS
     --
     TYPE t_mig_bf_bonfranseg IS TABLE OF mig_bf_bonfranseg%ROWTYPE;
     l_reg_mig_mcc t_mig_bf_bonfranseg;
     --
      CURSOR lc_mig_bf_bonfranseg IS
       SELECT 17488 NCARGA,1 CESTMIG, a.MIG_PK, a.MIG_FK, a.SSEGURO, a.FMOVIMI, a.CMOTRET, a.CUSURET, a.FFECRET,
              a.CUSUAUT, a.FFECAUT, a.OBSERV, a.CDETMOTREC, a.POSTPPER, a.PERPOST
       --SELECT COUNT(*)
        FROM mig_bf_bonfranseg_bs, mig_movseguro ms, mig_riesgos r
       WHERE 1 = 1
          AND a.mig_fk = ms.mig_pk
          AND a.mig_fk2 = r.mig_pk
    ORDER BY a.mig_pk;
          --SELECT * FROM mig_bf_bonfranseg_conf s WHERE s.mig_pk = '131050100DL0200681';
          --SELECT * FROM MIG_CTGAR_DET_bs WHERE cbanco IS NOT NULL;
     --
     dml_errors EXCEPTION;
     PRAGMA EXCEPTION_INIT(dml_errors, -24381);
     l_errors  NUMBER;
     l_errno   NUMBER;
     l_msg     VARCHAR2(4000);
     l_idx     NUMBER;
     --
  BEGIN
    --
    -----------------------------------------
    --BF_BONFRANSEG
    -----------------------------------------
    OPEN lc_mig_bf_bonfranseg;
    LOOP
      --
      FETCH lc_mig_bf_bonfranseg BULK COLLECT INTO l_reg_mig_mcc LIMIT 100000;  -- limit to 10k to avoid out of memory
      --
      dbms_output.put_line('bf_bonfranseg - I - paso bullk');
      --
      dbms_output.put_line('...');
      --
      --FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
      --DELETE FROM mig_bf_bonfranseg WHERE mig_pk = l_reg_mig_mcc(i).mig_pk;
      --
      BEGIN
        --
        FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
        INSERT INTO mig_bf_bonfranseg VALUES l_reg_mig_mcc(i);
        --
      EXCEPTION
      WHEN DML_ERRORS THEN
        --
        l_errors := SQL%bulk_exceptions.count;
        --
        dbms_output.put_line('l_errors:'||l_errors);
        --
        FOR i IN 1 .. l_errors
        LOOP
          --
          l_errno := SQL%BULK_EXCEPTIONS(i).error_code;
          l_msg   := SQLERRM(-l_errno);
          l_idx   := SQL%BULK_EXCEPTIONS(i).error_index;
          --
          p_control_error(g_user,'67_mig_bf_bonfranseg','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
          --
        END LOOP;
        --
      END;
      --
      dbms_output.put_line('bf_bonfranseg - F - paso bullk');
      --
      EXIT WHEN lc_mig_bf_bonfranseg%NOTFOUND;
       --
     END LOOP;
     --
     gcant_a_cargar   := lc_mig_bf_bonfranseg%ROWCOUNT;
     --
     SELECT COUNT(*) INTO gcant_a_cargar_bs FROM mig_bf_bonfranseg_bs;
     SELECT COUNT(*) INTO gcant_cargada FROM mig_bf_bonfranseg;
     CLOSE lc_mig_bf_bonfranseg;
     --
   END p_carga_bf_bonfranseg;*/
   --
   /***************************************************************************
      PROCEDURE p_carga_recibos
      Procedimiento que inserta los registros grabados en MIG_RECIBOS_BS, en la tabla
      MIG_RECIBOS de iAXIS.
   ****************************************************************************/
   PROCEDURE p_carga_recibos
   IS
     --
     TYPE t_mig_recibos IS TABLE OF mig_recibos%ROWTYPE;
     l_reg_mig_mcc t_mig_recibos;
     --
     CURSOR lc_mig_recibos IS
     SELECT 17456 NCARGA, 1 CESTMIG, a.MIG_PK, a.MIG_FK, a.NMOVIMI, a.FEMISIO, a.FEFECTO, a.FVENCIM, a.CTIPREC, 0 SSEGURO, a.NRIESGO, a.NRECIBO, a.CESTREC, a.FRECCOB,
	          a.CESTIMP, a.ESCCERO, a.CRECCIA, a.NRECAUX
     --SELECT count(*)
      FROM mig_recibos_bs a, mig_seguros s
     WHERE 1 = 1
        AND a.mig_fk  = s.mig_pk
        --AND s.nrecibo <> 0
      ORDER BY a.mig_pk
        ;
          --SELECT * FROM mig_recibos_conf s WHERE s.mig_pk = '131050100DL0200681';
          --SELECT * FROM MIG_CTGAR_DET_bs WHERE cbanco IS NOT NULL;
     --
     dml_errors EXCEPTION;
     PRAGMA EXCEPTION_INIT(dml_errors, -24381);
     l_errors  NUMBER;
     l_errno   NUMBER;
     l_msg     VARCHAR2(4000);
     l_idx     NUMBER;
     --
  BEGIN
    --
    -----------------------------------------
    --MIG_RECIBOS
    -----------------------------------------
    OPEN lc_mig_recibos;
    LOOP
      --
      FETCH lc_mig_recibos BULK COLLECT INTO l_reg_mig_mcc LIMIT 100000;  -- limit to 10k to avoid out of memory
      --
      dbms_output.put_line('psu_retenidas - I - paso bullk');
      --
      dbms_output.put_line('...');
      --
      --FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
      --DELETE FROM mig_recibos WHERE mig_pk = l_reg_mig_mcc(i).mig_pk;
      --
      BEGIN
        --
        FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
        INSERT INTO mig_recibos VALUES l_reg_mig_mcc(i);
        --
      EXCEPTION
      WHEN DML_ERRORS THEN
        --
        l_errors := SQL%bulk_exceptions.count;
        --
        dbms_output.put_line('l_errors:'||l_errors);
        --
        FOR i IN 1 .. l_errors
        LOOP
          --
          l_errno := SQL%BULK_EXCEPTIONS(i).error_code;
          l_msg   := SQLERRM(-l_errno);
          l_idx   := SQL%BULK_EXCEPTIONS(i).error_index;
          --
          p_control_error(g_user,'01_mig_recibos','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
          --
        END LOOP;
        --
      END;
      --
      dbms_output.put_line('psu_retenidas - F - paso bullk');
      --
      EXIT WHEN lc_mig_recibos%NOTFOUND;
       --
     END LOOP;
     --
     gcant_a_cargar   := lc_mig_recibos%ROWCOUNT;
     --
     SELECT COUNT(*) INTO gcant_a_cargar_bs FROM mig_recibos_bs;
     SELECT COUNT(*) INTO gcant_cargada FROM mig_recibos;
     CLOSE lc_mig_recibos;
     --
   END p_carga_recibos;
   --
   /***************************************************************************
      PROCEDURE p_carga_movrecibo
      Procedimiento que inserta los registros grabados en MIG_MOVRECIBO_BS, en la tabla
      MIG_MOVRECIBO de iAXIS.
   ****************************************************************************/
   PROCEDURE p_carga_movrecibo
   IS
     --
     TYPE t_mig_movrecibo IS TABLE OF mig_movrecibo%ROWTYPE;
     l_reg_mig_mcc t_mig_movrecibo;
     --
    CURSOR lc_mig_movrecibo IS
     SELECT 17457 NCARGA, 1 CESTMIG, a.MIG_PK, a.MIG_FK, 0 NRECIBOS, 0 SMOVREC, a.CESTREC, a.FMOVINI, a.FMOVFIN, a.FEFEADM, a.FMOVDIA, a.CMOTMOV
     --SELECT count(*)
      FROM mig_movrecibo_bs a, mig_movrecibo s
     WHERE 1 = 1
        AND a.mig_fk  = s.mig_pk
        --AND s.nrecibo <> 0
      ORDER BY a.mig_pk
        ;
          --SELECT * FROM mig_movrecibo_conf s WHERE s.mig_pk = '131050100DL0200681';
          --SELECT * FROM MIG_CTGAR_DET_bs WHERE cbanco IS NOT NULL;
     --
     dml_errors EXCEPTION;
     PRAGMA EXCEPTION_INIT(dml_errors, -24381);
     l_errors  NUMBER;
     l_errno   NUMBER;
     l_msg     VARCHAR2(4000);
     l_idx     NUMBER;
     --
  BEGIN
    --
    -----------------------------------------
    --MIG_MOVRECIBO
    -----------------------------------------
    OPEN lc_mig_movrecibo;
    LOOP
      --
      FETCH lc_mig_movrecibo BULK COLLECT INTO l_reg_mig_mcc LIMIT 100000;  -- limit to 10k to avoid out of memory
      --
      dbms_output.put_line('psu_retenidas - I - paso bullk');
      --
      dbms_output.put_line('...');
      --
      --FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
      --DELETE FROM mig_movrecibo WHERE mig_pk = l_reg_mig_mcc(i).mig_pk;
      --
      BEGIN
        --
        FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
        INSERT INTO mig_movrecibo VALUES l_reg_mig_mcc(i);
        --
      EXCEPTION
      WHEN DML_ERRORS THEN
        --
        l_errors := SQL%bulk_exceptions.count;
        --
        dbms_output.put_line('l_errors:'||l_errors);
        --
        FOR i IN 1 .. l_errors
        LOOP
          --
          l_errno := SQL%BULK_EXCEPTIONS(i).error_code;
          l_msg   := SQLERRM(-l_errno);
          l_idx   := SQL%BULK_EXCEPTIONS(i).error_index;
          --
          p_control_error(g_user,'02_mig_movrecibo','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
          --
        END LOOP;
        --
      END;
      --
      dbms_output.put_line('psu_retenidas - F - paso bullk');
      --
      EXIT WHEN lc_mig_movrecibo%NOTFOUND;
       --
     END LOOP;
     --
     gcant_a_cargar   := lc_mig_movrecibo%ROWCOUNT;
     --
     SELECT COUNT(*) INTO gcant_a_cargar_bs FROM mig_movrecibo_bs;
     SELECT COUNT(*) INTO gcant_cargada FROM mig_movrecibo;
     CLOSE lc_mig_movrecibo;
     --
   END p_carga_movrecibo;
   --
   /***************************************************************************
      PROCEDURE p_carga_detrecibos
      Procedimiento que inserta los registros grabados en MIG_DETRECIBOS_BS, en la tabla
      MIG_DETRECIBOS de iAXIS.
   ****************************************************************************/
   PROCEDURE p_carga_detrecibos
   IS
     --
     TYPE t_mig_detrecibos IS TABLE OF mig_detrecibos%ROWTYPE;
     l_reg_mig_mcc t_mig_detrecibos;
     --
    CURSOR lc_mig_detrecibos IS
     SELECT 17458 NCARGA, 1 CESTMIG, a.MIG_PK, a.MIG_FK, a.CCONCEP, a.CGARANT, a.NRIESGO, a.ICONCEP, a.NMOVIMA, a.FCAMBIO, a.ICONCEP_MONPOL
     --select count(*)
      FROM mig_detrecibos_bs a, mig_recibos s
     WHERE 1 = 1
        AND a.mig_fk  = s.mig_pk
        AND s.nrecibo <> 0
      ORDER BY a.mig_pk
        ;
     --SELECT * FROM mig_detrecibos_conf s WHERE s.mig_pk = '131050100DL0200681';
     --SELECT * FROM MIG_CTGAR_DET_bs WHERE cbanco IS NOT NULL;
     --
     dml_errors EXCEPTION;
     PRAGMA EXCEPTION_INIT(dml_errors, -24381);
     l_errors  NUMBER;
     l_errno   NUMBER;
     l_msg     VARCHAR2(4000);
     l_idx     NUMBER;
     --
  BEGIN
    --
    -----------------------------------------
    --MIG_DETRECIBOS
    -----------------------------------------
    OPEN lc_mig_detrecibos;
    LOOP
      --
      FETCH lc_mig_detrecibos BULK COLLECT INTO l_reg_mig_mcc LIMIT 100000;  -- limit to 10k to avoid out of memory
      --
      dbms_output.put_line('psu_retenidas - I - paso bullk');
      --
      dbms_output.put_line('...');
      --
      --FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
      --DELETE FROM mig_detrecibos WHERE mig_pk = l_reg_mig_mcc(i).mig_pk;
      --
      BEGIN
        --
        FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
        INSERT INTO mig_detrecibos VALUES l_reg_mig_mcc(i);
        --
      EXCEPTION
      WHEN DML_ERRORS THEN
        --
        l_errors := SQL%bulk_exceptions.count;
        --
        dbms_output.put_line('l_errors:'||l_errors);
        --
        FOR i IN 1 .. l_errors
        LOOP
          --
          l_errno := SQL%BULK_EXCEPTIONS(i).error_code;
          l_msg   := SQLERRM(-l_errno);
          l_idx   := SQL%BULK_EXCEPTIONS(i).error_index;
          --
          p_control_error(g_user,'03_mig_detrecibos','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
          --
        END LOOP;
        --
      END;
      --
      dbms_output.put_line('psu_retenidas - F - paso bullk');
      --
      EXIT WHEN lc_mig_detrecibos%NOTFOUND;
       --
     END LOOP;
     --
     gcant_a_cargar   := lc_mig_detrecibos%ROWCOUNT;
     --
     SELECT COUNT(*) INTO gcant_a_cargar_bs FROM mig_detrecibos_bs;
     SELECT COUNT(*) INTO gcant_cargada FROM mig_detrecibos;
     CLOSE lc_mig_detrecibos;
     --
   END p_carga_detrecibos;
   --
   /***************************************************************************
      PROCEDURE p_carga_detmovrecibo
      Procedimiento que inserta los registros grabados en MIG_DETMOVRECIBO_BS, en la tabla
      MIG_DETMOVRECIBO de iAXIS.
   ****************************************************************************/
   PROCEDURE p_carga_detmovrecibo
   IS
     --
     TYPE t_mig_detmovrecibo IS TABLE OF mig_detmovrecibo%ROWTYPE;
     l_reg_mig_mcc t_mig_detmovrecibo;
     --
    CURSOR lc_mig_detmovrecibo IS
     SELECT 17459 NCARGA, 1 CESTMIG, a.MIG_PK, a.MIG_FK, 0 NRECIBO, 0 SMOVREC, a.NORDEN, a.IIMPORTE,
            a.FMOVIMI, a.FEFEADM, a.CUSUARI, a.TDESCRIP, a.FCONTAB, a.IIMPORTE_MONCON, a.FCAMBIO
     --select count(*)
      FROM mig_detmovrecibo_bs a, mig_movrecibo s
     WHERE 1 = 1
        AND a.mig_fk  = s.mig_pk
        AND s.nrecibo <> 0
      ORDER BY a.mig_pk
        ;
     --SELECT * FROM mig_detmovrecibo_conf s WHERE s.mig_pk = '131050100DL0200681';
     --SELECT * FROM MIG_CTGAR_DET_bs WHERE cbanco IS NOT NULL;
     --
     dml_errors EXCEPTION;
     PRAGMA EXCEPTION_INIT(dml_errors, -24381);
     l_errors  NUMBER;
     l_errno   NUMBER;
     l_msg     VARCHAR2(4000);
     l_idx     NUMBER;
     --
  BEGIN
    --
    -----------------------------------------
    --MIG_DETMOVRECIBO
    -----------------------------------------
    OPEN lc_mig_detmovrecibo;
    LOOP
      --
      FETCH lc_mig_detmovrecibo BULK COLLECT INTO l_reg_mig_mcc LIMIT 100000;  -- limit to 10k to avoid out of memory
      --
      dbms_output.put_line('psu_retenidas - I - paso bullk');
      --
      dbms_output.put_line('...');
      --
      --FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
      --DELETE FROM mig_detmovrecibo WHERE mig_pk = l_reg_mig_mcc(i).mig_pk;
      --
      BEGIN
        --
        FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
        INSERT INTO mig_detmovrecibo VALUES l_reg_mig_mcc(i);
        --
      EXCEPTION
      WHEN DML_ERRORS THEN
        --
        l_errors := SQL%bulk_exceptions.count;
        --
        dbms_output.put_line('l_errors:'||l_errors);
        --
        FOR i IN 1 .. l_errors
        LOOP
          --
          l_errno := SQL%BULK_EXCEPTIONS(i).error_code;
          l_msg   := SQLERRM(-l_errno);
          l_idx   := SQL%BULK_EXCEPTIONS(i).error_index;
          --
          p_control_error(g_user,'04_mig_detmovrecibo','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
          --
        END LOOP;
        --
      END;
      --
      dbms_output.put_line('psu_retenidas - F - paso bullk');
      --
      EXIT WHEN lc_mig_detmovrecibo%NOTFOUND;
       --
     END LOOP;
     --
     gcant_a_cargar   := lc_mig_detmovrecibo%ROWCOUNT;
     --
     SELECT COUNT(*) INTO gcant_a_cargar_bs FROM mig_detmovrecibo_bs;
     SELECT COUNT(*) INTO gcant_cargada FROM mig_detmovrecibo;
     CLOSE lc_mig_detmovrecibo;
     --
   END p_carga_detmovrecibo;
   --
   /***************************************************************************
      PROCEDURE p_carga_detmovrecibo_parcial
      Procedimiento que inserta los registros grabados en MIG_DETMOVRECIBO_PARCIAL_BS, en la tabla
      MIG_DETMOVRECIBO_PARCIAL de iAXIS.
   ****************************************************************************/
   PROCEDURE p_carga_detmovrecibo_parcial
   IS
     --
     TYPE t_mig_detmovrecibo_parcial IS TABLE OF mig_detmovrecibo_parcial%ROWTYPE;
     l_reg_mig_mcc t_mig_detmovrecibo_parcial;
     --
    CURSOR lc_mig_detmovrecibo_parcial IS
     SELECT 17460 NCARGA, 1 CESTMIG,a.MIG_PK, a.MIG_FK, 0 NRECIBO, 0 SMOVREC, 0 NORDEN, a.CCONCEP, a.CGARANT, a.NRIESGO,
            a.FMOVIMI, a.ICONCEP, a.ICONCEP_MONPOL, a.NMOVIMA, a.FCAMBIO
     --select *
      FROM mig_detmovrecibo_parcial_bs a, mig_movrecibo s
     WHERE 1 = 1
        AND a.mig_fk  = s.mig_pk
        AND s.nrecibo <> 0
      ORDER BY a.mig_pk
        ;
     --SELECT * FROM mig_detmovrecibo_parcial_conf s WHERE s.mig_pk = '131050100DL0200681';
     --SELECT * FROM MIG_CTGAR_DET_bs WHERE cbanco IS NOT NULL;
     --
     dml_errors EXCEPTION;
     PRAGMA EXCEPTION_INIT(dml_errors, -24381);
     l_errors  NUMBER;
     l_errno   NUMBER;
     l_msg     VARCHAR2(4000);
     l_idx     NUMBER;
     --
  BEGIN
    --
    -----------------------------------------
    --mig_detmovrecibo_parcial
    -----------------------------------------
    OPEN lc_mig_detmovrecibo_parcial;
    LOOP
      --
      FETCH lc_mig_detmovrecibo_parcial BULK COLLECT INTO l_reg_mig_mcc LIMIT 100000;  -- limit to 10k to avoid out of memory
      --
      dbms_output.put_line('psu_retenidas - I - paso bullk');
      --
      dbms_output.put_line('...');
      --
      --FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
      --DELETE FROM mig_detmovrecibo_parcial WHERE mig_pk = l_reg_mig_mcc(i).mig_pk;
      --
      BEGIN
        --
        FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
        INSERT INTO mig_detmovrecibo_parcial VALUES l_reg_mig_mcc(i);
        --
      EXCEPTION
      WHEN DML_ERRORS THEN
        --
        l_errors := SQL%bulk_exceptions.count;
        --
        dbms_output.put_line('l_errors:'||l_errors);
        --
        FOR i IN 1 .. l_errors
        LOOP
          --
          l_errno := SQL%BULK_EXCEPTIONS(i).error_code;
          l_msg   := SQLERRM(-l_errno);
          l_idx   := SQL%BULK_EXCEPTIONS(i).error_index;
          --
          p_control_error(g_user,'04_mig_detmovrecibo_parcial','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
          --
        END LOOP;
        --
      END;
      --
      dbms_output.put_line('psu_retenidas - F - paso bullk');
      --
      EXIT WHEN lc_mig_detmovrecibo_parcial%NOTFOUND;
       --
     END LOOP;
     --
     gcant_a_cargar   := lc_mig_detmovrecibo_parcial%ROWCOUNT;
     --
     SELECT COUNT(*) INTO gcant_a_cargar_bs FROM mig_detmovrecibo_parcial_bs;
     SELECT COUNT(*) INTO gcant_cargada FROM mig_detmovrecibo_parcial;
     CLOSE lc_mig_detmovrecibo_parcial;
     --
   END p_carga_detmovrecibo_parcial;
   --
   /***************************************************************************
      PROCEDURE p_carga_liquidacab
      Procedimiento que inserta los registros grabados en MIG_LIQUIDACAB_BS, en la tabla
      MIG_LIQUIDACAB de iAXIS.
   ****************************************************************************/
   PROCEDURE p_carga_liquidacab
   IS
     --
     TYPE t_mig_liquidacab IS TABLE OF mig_liquidacab%ROWTYPE;
     l_reg_mig_mcc t_mig_liquidacab;
     --
    CURSOR lc_mig_liquidacab IS
     SELECT 17461 NCARGA, 1 CESTMIG, a.MIG_PK, a.CAGENTE, a.NLIQMEN, a.FLIQUID, a.FMOVIMI, a.CTIPOLIQ, a.CESTADO, a.CUSUARI, a.FCOBRO
     --SELECT COUNT(*)
      FROM mig_liquidacab_bs a, agentes g
     WHERE 1 = 1
       AND a.cagente = g.cagente
      ORDER BY a.mig_pk
        ;
     --SELECT * FROM mig_liquidacab_conf s WHERE s.mig_pk = '131050100DL0200681';
     --SELECT * FROM MIG_CTGAR_DET_bs WHERE cbanco IS NOT NULL;
     --
     dml_errors EXCEPTION;
     PRAGMA EXCEPTION_INIT(dml_errors, -24381);
     l_errors  NUMBER;
     l_errno   NUMBER;
     l_msg     VARCHAR2(4000);
     l_idx     NUMBER;
     --
  BEGIN
    --
    -----------------------------------------
    --MIG_LIQUIDACAB
    -----------------------------------------
    OPEN lc_mig_liquidacab;
    LOOP
      --
      FETCH lc_mig_liquidacab BULK COLLECT INTO l_reg_mig_mcc LIMIT 100000;  -- limit to 10k to avoid out of memory
      --
      dbms_output.put_line('psu_retenidas - I - paso bullk');
      --
      dbms_output.put_line('...');
      --
      --FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
      --DELETE FROM mig_liquidacab WHERE mig_pk = l_reg_mig_mcc(i).mig_pk;
      --
      BEGIN
        --
        FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
        INSERT INTO mig_liquidacab VALUES l_reg_mig_mcc(i);
        --
      EXCEPTION
      WHEN DML_ERRORS THEN
        --
        l_errors := SQL%bulk_exceptions.count;
        --
        dbms_output.put_line('l_errors:'||l_errors);
        --
        FOR i IN 1 .. l_errors
        LOOP
          --
          l_errno := SQL%BULK_EXCEPTIONS(i).error_code;
          l_msg   := SQLERRM(-l_errno);
          l_idx   := SQL%BULK_EXCEPTIONS(i).error_index;
          --
          p_control_error(g_user,'05_mig_liquidacab','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
          --
        END LOOP;
        --
      END;
      --
      dbms_output.put_line('psu_retenidas - F - paso bullk');
      --
      EXIT WHEN lc_mig_liquidacab%NOTFOUND;
       --
     END LOOP;
     --
     gcant_a_cargar   := lc_mig_liquidacab%ROWCOUNT;
     --
     SELECT COUNT(*) INTO gcant_a_cargar_bs FROM mig_liquidacab_bs;
     SELECT COUNT(*) INTO gcant_cargada FROM mig_liquidacab;
     CLOSE lc_mig_liquidacab;
     --
   END p_carga_liquidacab;
   --
   /***************************************************************************
      PROCEDURE p_carga_liquidalin
      Procedimiento que inserta los registros grabados en MIG_LIQUIDALIN_BS, en la tabla
      MIG_LIQUIDALIN de iAXIS.
   ****************************************************************************/
   PROCEDURE p_carga_liquidalin
   IS
     --
     TYPE t_mig_liquidalin IS TABLE OF mig_liquidalin%ROWTYPE;
     l_reg_mig_mcc t_mig_liquidalin;
     --
    CURSOR lc_mig_liquidalin IS
     SELECT 17462 NCARGA, 1 CESTMIG, a.MIG_PK, a.MIG_FK, a.MIG_FK2, a.ITOTIMP, a.ITOTALR, a.IPRINET, a.ICOMISI, a.IRETENCCOM, a.ISOBRECOMISION, a.IRETENCSOBRECOM, a.ICONVOLEDUCTO,
             a.IRETENCOLEODUCTO, a.CTIPOLIQ, a.ITOTIMP_MONCIA, a.ITOTALR_MONCIA, a.IPRINET_MONCIA, a.ICOMISI_MONCIA, a.IRETENCCOM_MONCIA, a.ISOBRECOM_MONCIA, a.IRETENCSCOM_MONCIA, a.ICONVOLEOD_MONCIA,
             a.IRETOLEOD_MONCIA, a.FCAMBIO
     --SELECT COUNT(*)
      FROM mig_liquidalin_bs a
     WHERE 1 = 1
      ORDER BY a.mig_pk
      ;
     --SELECT * FROM mig_liquidalin_conf s WHERE s.mig_pk = '131050100DL0200681';
     --SELECT * FROM MIG_CTGAR_DET_bs WHERE cbanco IS NOT NULL;
     --
     dml_errors EXCEPTION;
     PRAGMA EXCEPTION_INIT(dml_errors, -24381);
     l_errors  NUMBER;
     l_errno   NUMBER;
     l_msg     VARCHAR2(4000);
     l_idx     NUMBER;
     --
  BEGIN
    --
    -----------------------------------------
    --MIG_LIQUIDALIN
    -----------------------------------------
    OPEN lc_mig_liquidalin;
    LOOP
      --
      FETCH lc_mig_liquidalin BULK COLLECT INTO l_reg_mig_mcc LIMIT 100000;  -- limit to 10k to avoid out of memory
      --
      dbms_output.put_line('psu_retenidas - I - paso bullk');
      --
      dbms_output.put_line('...');
      --
      --FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
      --DELETE FROM mig_liquidalin WHERE mig_pk = l_reg_mig_mcc(i).mig_pk;
      --
      BEGIN
        --
        FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
        INSERT INTO mig_liquidalin VALUES l_reg_mig_mcc(i);
        --
      EXCEPTION
      WHEN DML_ERRORS THEN
        --
        l_errors := SQL%bulk_exceptions.count;
        --
        dbms_output.put_line('l_errors:'||l_errors);
        --
        FOR i IN 1 .. l_errors
        LOOP
          --
          l_errno := SQL%BULK_EXCEPTIONS(i).error_code;
          l_msg   := SQLERRM(-l_errno);
          l_idx   := SQL%BULK_EXCEPTIONS(i).error_index;
          --
          p_control_error(g_user,'06_mig_liquidalin','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
          --
        END LOOP;
        --
      END;
      --
      dbms_output.put_line('psu_retenidas - F - paso bullk');
      --
      EXIT WHEN lc_mig_liquidalin%NOTFOUND;
       --
     END LOOP;
     --
     gcant_a_cargar   := lc_mig_liquidalin%ROWCOUNT;
     --
     SELECT COUNT(*) INTO gcant_a_cargar_bs FROM mig_liquidalin_bs;
     SELECT COUNT(*) INTO gcant_cargada FROM mig_liquidalin;
     CLOSE lc_mig_liquidalin;
     --
   END p_carga_liquidalin;
   --
   --
   /***************************************************************************
      PROCEDURE p_carga_ctactes
      Procedimiento que inserta los registros grabados en MIG_CTACTES_BS, en la tabla
      MIG_ctactes de iAXIS.
   ****************************************************************************/
   PROCEDURE p_carga_ctactes
   IS
     --
     TYPE t_mig_ctactes IS TABLE OF mig_ctactes%ROWTYPE;
     l_reg_mig_mcc t_mig_ctactes;
     --
    CURSOR lc_mig_ctactes IS
     SELECT 17463 NCARGA, 1 CESTMIG, a.* --, r.nrecibo, s.sseguro, sn.nsinies
     --SELECT *
       FROM mig_ctactes_BS a --, mig_recibos r, mig_seguros s, mig_siniestros sn
      WHERE 1 = 1
      ORDER BY a.mig_pk
      ;
     --SELECT * FROM mig_ctactes_conf s WHERE s.mig_pk = '131050100DL0200681';
     --SELECT * FROM MIG_CTGAR_DET_bs WHERE cbanco IS NOT NULL;
     --
     dml_errors EXCEPTION;
     PRAGMA EXCEPTION_INIT(dml_errors, -24381);
     l_errors  NUMBER;
     l_errno   NUMBER;
     l_msg     VARCHAR2(4000);
     l_idx     NUMBER;
     --
  BEGIN
    --
    -----------------------------------------
    --mig_ctactes
    -----------------------------------------
    OPEN lc_mig_ctactes;
    LOOP
      --
      FETCH lc_mig_ctactes BULK COLLECT INTO l_reg_mig_mcc LIMIT 100000;  -- limit to 10k to avoid out of memory
      --
      dbms_output.put_line('psu_retenidas - I - paso bullk');
      --
      dbms_output.put_line('...');
      --
      --FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
      --DELETE FROM mig_ctactes WHERE mig_pk = l_reg_mig_mcc(i).mig_pk;
      --
      BEGIN
        --
        FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
        INSERT INTO mig_ctactes VALUES l_reg_mig_mcc(i);
        --
      EXCEPTION
      WHEN DML_ERRORS THEN
        --
        l_errors := SQL%bulk_exceptions.count;
        --
        dbms_output.put_line('l_errors:'||l_errors);
        --
        FOR i IN 1 .. l_errors
        LOOP
          --
          l_errno := SQL%BULK_EXCEPTIONS(i).error_code;
          l_msg   := SQLERRM(-l_errno);
          l_idx   := SQL%BULK_EXCEPTIONS(i).error_index;
          --
          p_control_error(g_user,'06_mig_ctactes','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
          --
        END LOOP;
        --
      END;
      --
      dbms_output.put_line('psu_retenidas - F - paso bullk');
      --
      EXIT WHEN lc_mig_ctactes%NOTFOUND;
       --
     END LOOP;
     --
     gcant_a_cargar   := lc_mig_ctactes%ROWCOUNT;
     --
     SELECT COUNT(*) INTO gcant_a_cargar_bs FROM mig_ctactes_bs;
     SELECT COUNT(*) INTO gcant_cargada FROM mig_ctactes;
     CLOSE lc_mig_ctactes;
     --
   END p_carga_ctactes;
   --
   /***************************************************************************
      PROCEDURE p_carga_segu
      Procedimiento que ejecuta el cargue de un fichero particular
         param in  ptab_des:     Descripción de la tabla.
   ***************************************************************************/
   PROCEDURE p_carga_segu(ptab_des VARCHAR2)
   IS
     --
     l_timestart       NUMBER;
     l_timeend         NUMBER;
     l_time            NUMBER;
     vdummy            NUMBER;
     --
     --b_error           BOOLEAN;
     v_texto           VARCHAR2(500);
     --
   BEGIN
     --
      gcant_a_cargar_bs := 0;
      gcant_cargada  := 0;
      gcant_a_cargar := 0;
      --
      IF g_user IS NULL
      THEN
        --
        g_user := 'CONF_MIGRA';
        --
      END IF;
      --
      SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
        INTO vdummy
        FROM dual;
     --
     IF ptab_des = 'MIG_BUREAU'
     THEN
       --
       p_carga_bureau;
      --
     ELSIF ptab_des = 'MIG_SEGUROS'
     THEN
       --
       p_carga_seguros;
       --
     ELSIF ptab_des = 'MIG_MOVSEGURO'
     THEN
       --
       p_carga_movseguro;
       --
     ELSIF ptab_des = 'MIG_HISTORICOSEGUROS'
     THEN
       --
       p_carga_historicoseguros;
       --
     ELSIF ptab_des = 'MIG_ASEGURADOS'
     THEN
       --
       p_carga_asegurados;
       --
     ELSIF ptab_des = 'MIG_RIESGOS'
     THEN
       --
       p_carga_riesgos;
       --
     ELSIF ptab_des = 'MIG_GARANSEG'
     THEN
       --
       p_carga_garanseg;
       --
     ELSIF ptab_des = 'MIG_CLAUSUESP'
     THEN
       --
       p_carga_clausuesp;
       --
     ELSIF ptab_des = 'MIG_BENESPSEG'
     THEN
       --
       p_carga_benespseg;
       --
     ELSIF ptab_des = 'MIG_PREGUNSEG'
     THEN
       --
       p_carga_pregunseg;
       --
     ELSIF ptab_des = 'MIG_CTASEGURO'
     THEN
       --
       --p_carga_ctaseguro;
       dbms_output.put_line('por definir . . . p_carga_ctaseguro '||g_user);
       --
     ELSIF ptab_des = 'MIG_AGENSEGU'
     THEN
       --
       p_carga_agensegu;
       --
     ELSIF ptab_des = 'MIG_PREGUNGARANSEG'
     THEN
       --
       p_carga_pregungaranseg;
       --
     ELSIF ptab_des = 'MIG_SITRIESGO'
     THEN
       --
       p_carga_sitriesgo;
     ELSIF ptab_des = 'MIG_CTGAR_CONTRAGARANTIA'
     THEN
       --
       p_carga_ctgar_contragarantia;
       --
     ELSIF ptab_des = 'MIG_CTGAR_SEGURO'
     THEN
       --
       p_carga_ctgar_seguro;
       --
     ELSIF ptab_des = 'MIG_AGE_CORRETAJE'
     THEN
       --
       p_carga_age_corretaje;
       --
     ELSIF ptab_des = 'MIG_PSU_RETENIDAS'
     THEN
       --
       p_carga_psu_retenidas;
       --
     ELSIF ptab_des = 'MIG_BF_BONFRANSEG'
     THEN
       --
       --p_carga_bf_bonfranseg;
       --
       dbms_output.put_line('por definir . . . p_carga_bf_bonfranseg '||g_user);
       --
     ELSIF ptab_des = 'MIG_RECIBOS'
     THEN
       --
       p_carga_recibos;
       --
     ELSIF ptab_des = 'MIG_MOVRECIBO'
     THEN
       --
       p_carga_movrecibo;
       --
     ELSIF ptab_des = 'MIG_DETECIBOS'
     THEN
       --
       p_carga_detrecibos;
       --
     ELSIF ptab_des = 'MIG_DETMOVECIBO'
     THEN
       --
       p_carga_detmovrecibo;
       --
     ELSIF ptab_des = 'MIG_DETMOVECIBO_PARCIAL'
     THEN
       --
       p_carga_detmovrecibo_parcial;
       --
     ELSIF ptab_des = 'MIG_LIQUIDACAB'
     THEN
       --
       p_carga_liquidacab;
       --
     ELSIF ptab_des = 'MIG_LIQUIDALIN'
     THEN
       --
       p_carga_liquidalin;
       --
     ELSIF ptab_des = 'MIG_CTACTES'
     THEN
       --
       p_carga_ctactes;
       --
     END IF;
     --
     l_timeend := dbms_utility.get_time();
     l_time    := (l_timeend - l_timestart) / 100;
     v_texto   := gcant_a_cargar_bs || '/' || gcant_cargada || ' reg cargados de ' || gcant_a_cargar || '. Tiempo de Ejecución: '|| l_time || ' seg';
     p_control_error(g_user, ptab_des, v_texto);
     dbms_output.put_line(v_texto);
     --
   END p_carga_segu;
   --
END pac_carga_seguros_conf;

/

  GRANT EXECUTE ON "AXIS"."PAC_CARGA_SEGUROS_CONF" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_CARGA_SEGUROS_CONF" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_CARGA_SEGUROS_CONF" TO "PROGRAMADORESCSI";
