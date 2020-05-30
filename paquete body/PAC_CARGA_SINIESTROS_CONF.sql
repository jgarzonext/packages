--------------------------------------------------------
--  DDL for Package Body PAC_CARGA_SINIESTROS_CONF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_CARGA_SINIESTROS_CONF" IS
   /***************************************************************************
      NOMBRE:       pac_carga_siniestros_conf
      PROPÓSITO:    Proceso de traspaso de informacion de las tablas base _BS
                    a las distintas tablas MIG_ de AXIS (Capítulo Siniestros)
      REVISIONES:
      Ver        Fecha       Autor       Descripción
      ---------  ----------  ----------  --------------------------------------
       1.0        11/10/2017  HAG         Creacion package de carga
       1.1        05/02/2018  HAG         Creación tablas base _BS
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
   --
   /***************************************************************************
      PROCEDURE p_carga_siniestro
      Procedimiento que inserta los registros grabados en MIG_SIN_SINIESTRO_bs, en la tabla
      MIG_SEGUROS de iAXIS.
   ***************************************************************************/
   PROCEDURE p_carga_siniestros
   IS
     --
     TYPE t_mig_sin_siniestro IS TABLE OF mig_sin_siniestro%ROWTYPE;
     l_reg_mig_mcc t_mig_sin_siniestro;
     --
      CURSOR lc_mig_siniestros IS
       SELECT 14440 NCARGA, 1 CESTMIG, a.MIG_PK,	a.MIG_FK, a.NSINIES, 0 SSEGURO,	a.NRIESGO,	a.NMOVIMI,
       a.FSINIES,	a.FNOTIFI,	a.CCAUSIN,	a.CMOTSIN,	a.CEVENTO,	a.CCULPAB,	a.CRECLAMA,	a.NASEGUR,	a.CMEDDEC,
       a.CTIPDEC,	a.TNOM1DEC TNOMDEC,	a.TAPE1DEC,	a.TAPE2DEC,	a.TTELDEC,	a.TSINIES,	NVL(a.CUSUALT, 'CONF_MIG'),	NVL(a.FALTA, F_SYSDATE),	NVL(a.CUSUMOD, 'CONF_MIG'),
       a.FMODIFI,	a.NCUACOA,	a.NSINCOA,	a.CSINCIA, a.TEMAILDEC, a.CTIPIDE, a.NNUMIDE, a.TNOM2DEC, a.TNOM1DEC, NULL CAGENTE, NULL CCARPETA
       --SELECT *
        FROM mig_sin_siniestro_bs a, mig_seguros s
       WHERE 1 = 1
          AND a.mig_fk = s.mig_pk
          AND s.sseguro <> 0
          /*AND d.mig_fk = p.mig_pk (+)*/
        ORDER BY a.mig_pk
          ;
          --SELECT * FROM mig_sin_siniestro_conf s for update; WHERE s.mig_pk = '131050100DL0200681';
          --SELECT * FROM mig_sin_siniestro s for update WHERE s.mig_pk = 'RD30094778';
          --SELECT * FROM sin_prof_indicadores s WHERE mig_fk = '1023871325';
     --
  BEGIN
    --
    -----------------------------------------
    --siniestros
    -----------------------------------------
    OPEN lc_mig_siniestros;
    LOOP
      --
      FETCH lc_mig_siniestros BULK COLLECT INTO l_reg_mig_mcc LIMIT 100000;  -- limit to 10k to avoid out of memory
      --
      --FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
      --DELETE FROM mig_siniestros WHERE mig_pk = l_reg_mig_mcc(i).mig_pk;
      --
      BEGIN
        --
        FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
        INSERT INTO mig_sin_siniestro VALUES l_reg_mig_mcc(i);
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
          p_control_error(g_user,'01_mig_siniestros','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
          --
        END LOOP;
        --
      END;
      --
      dbms_output.put_line('siniestros - F - paso bullk');
      --
      COMMIT;
      --
      EXIT WHEN lc_mig_siniestros%NOTFOUND;
       --
     END LOOP;
     --
     gcant_a_cargar   := lc_mig_siniestros%ROWCOUNT;
     --
     SELECT COUNT(*) INTO gcant_a_cargar_bs FROM mig_sin_siniestro_bs;
     SELECT COUNT(*) INTO gcant_cargada FROM mig_sin_siniestro;
     --
     CLOSE lc_mig_siniestros;
     --
   END p_carga_siniestros;
   --
   /***************************************************************************
      PROCEDURE p_carga_sin_movsiniestro
      Procedimiento que inserta los registros grabados en MIG_SIN_TRAMITA_JUDICIAL_bs, en la tabla
      MIG_SIN_TRAMITA_JUDICIAL de iAXIS.
   ****************************************************************************/
   PROCEDURE p_carga_sin_movsiniestro
   IS
     --
     TYPE t_mig_sin_movsiniestro IS TABLE OF mig_sin_movsiniestro%ROWTYPE;
     l_reg_mig_mcc t_mig_sin_movsiniestro;
     --
      CURSOR lc_mig_sin_movsiniestro IS
       SELECT 17441 NCARGA, 1 CESTMIG, a.MIG_PK, a.MIG_FK, 0 NSINIES, a.NMOVSIN,
              a.CESTSIN, NVL(a.FESTSIN, s.falta) FESTSIN, a.CCAUEST, a.CUNITRA, a.CTRAMITAD, NVL(a.CUSUALT, 'CONF_MIGRA'), NVL(a.FALTA, s.falta)
        --select count(*)
        FROM mig_sin_movsiniestro_bs a, mig_sin_siniestro s
       WHERE 1 = 1
          AND a.mig_fk = s.mig_pk
          AND s.sseguro <> 0
  --        AND a.mig_pk = '11501020013718'
        ORDER BY a.mig_pk
          ;
          --SELECT * FROM mig_sin_movsiniestro_conf s for update; WHERE s.mig_pk = '131050100DL0200681';
          --SELECT * FROM mig_sin_movsiniestro s for update WHERE s.mig_pk = 'RD30094778';
          --SELECT * FROM sin_prof_indicadores s WHERE mig_fk = '1023871325';
     --
  BEGIN
    --
    -----------------------------------------
    --MIG_SIN_MOVSINIESTRO
    -----------------------------------------
    OPEN lc_mig_sin_movsiniestro;
    LOOP
      --
      FETCH lc_mig_sin_movsiniestro BULK COLLECT INTO l_reg_mig_mcc LIMIT 100000;  -- limit to 10k to avoid out of memory
      --
      --FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
      --DELETE FROM mig_sin_movsiniestro WHERE mig_pk = l_reg_mig_mcc(i).mig_pk;
      --
      BEGIN
        --
        FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
        INSERT INTO mig_sin_movsiniestro VALUES l_reg_mig_mcc(i);
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
          p_control_error(g_user,'03_mig_sin_movsiniestro','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
          --
        END LOOP;
        --
      END;
      --
      dbms_output.put_line('lc_mig_sin_movsiniestro - F - paso bullk');
      --
      EXIT WHEN lc_mig_sin_movsiniestro%NOTFOUND;
       --
     END LOOP;
     --
     gcant_a_cargar   := lc_mig_sin_movsiniestro%ROWCOUNT;
     --
     SELECT COUNT(*) INTO gcant_a_cargar_bs FROM mig_sin_movsiniestro_bs;
     SELECT COUNT(*) INTO gcant_cargada FROM mig_sin_movsiniestro;
     --
     CLOSE lc_mig_sin_movsiniestro;
     --
   END p_carga_sin_movsiniestro;
   --
   /***************************************************************************
      PROCEDURE p_carga_tramita_judicial
      Procedimiento que inserta los registros grabados en MIG_SIN_TRAMITA_JUDICIAL_bs, en la tabla
      MIG_SIN_TRAMITA_JUDICIAL de iAXIS.
   ***************************************************************************
   PROCEDURE p_carga_tramita_judicial
   IS
    --
     TYPE t_mig_sin_tramita_judicial IS TABLE OF mig_sin_tramita_judicial%ROWTYPE;
     l_reg_mig_mcc t_mig_sin_tramita_judicial;
     --
      CURSOR lc_mig_sin_tramita_judicial IS
       SELECT 17458 NCARGA, 1 CESTMIG, 0 nsinies, 0 ntramit, a.MIG_PK,	a.MIG_FK,	a.MIG_FK2,	a.NORDEN,	a.CPROCESO,	a.TPROCESO,	a.CPOSTAL,
       a.CPOBLAC,	a.CPROVIN,	a.TIEXTERNO,	a.SPROFES,	a.FRECEP,	a.FNOTIFI,	a.FVENCIMI,	a.FRESPUES,	a.FCONCIL,	a.FDESVIN,
       a.TPRETEN,	a.TEXCEP1,	a.TEXCEP2,	a.FAUDIEN,	a.HAUDIEN,	a.TAUDIEN,	a.CCONTI,	a.CDESPA,	a.TLAUDIE,	a.CAUDIEN,
       a.CDESPAO,	a.TLAUDIEO,	a.CAUDIENO,	a.SABOGAU,	a.CORAL,	a.CESTADO,	a.CRESOLU,	a.FINSTA1,	a.FINSTA2, a.FNUEVA, a.TRESULT,
       a.CPOSICI,	a.CDEMAND,	a.SAPODERA,	a.IDEMAND,	a.FTDEMAN,	a.ICONDEN, a.CSENTEN, a.FSENTE1, a.FSENTE2, a.CTSENTE, a.TFALLO, a.FMODIFI, a.CUSUALT
       , NULL CASACION,	NULL FCASACI,	NULL CSENTEN2,	NULL FTSENTE --Ojo habilitar para la version 25. Ya deberían estar inf estos campos
       --select *
       --select Count(*)
        FROM mig_sin_tramita_judicial_bs a, mig_sin_siniestro s, mig_sin_tramitacion t
       WHERE 1 = 1
          AND a.mig_fk = s.mig_pk
          AND a.mig_fk2 = t.mig_pk
          AND s.nsinies <> 0
          AND t.nsinies <> 0
        ORDER BY a.mig_pk
          ;
     --
  BEGIN
    --
    -----------------------------------------
    --sin_tramita_judicial
    -----------------------------------------
    OPEN lc_mig_sin_tramita_judicial;
    LOOP
      --
      FETCH lc_mig_sin_tramita_judicial BULK COLLECT INTO l_reg_mig_mcc LIMIT 100000;  -- limit to 10k to avoid out of memory
      --
      --FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
      --DELETE FROM mig_sin_tramita_judicial WHERE mig_pk = l_reg_mig_mcc(i).mig_pk;
      --
      BEGIN
        --
        FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
        INSERT INTO mig_sin_tramita_judicial VALUES l_reg_mig_mcc(i);
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
          p_control_error(g_user,'03_mig_sin_tramita_judicial','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
          --
        END LOOP;
        --
      END;
      --
      dbms_output.put_line('lc_mig_sin_tramita_judicial - F - paso bullk');
      --
      EXIT WHEN lc_mig_sin_tramita_judicial%NOTFOUND;
       --
     END LOOP;
     --
     gcant_a_cargar   := lc_mig_sin_tramita_judicial%ROWCOUNT;
     --
     SELECT COUNT(*) INTO gcant_a_cargar_bs FROM mig_sin_tramita_judicial_bs;
     SELECT COUNT(*) INTO gcant_cargada FROM mig_sin_tramita_judicial;
     --
     CLOSE lc_mig_sin_tramita_judicial;
     --
   END p_carga_tramita_judicial;*/
   --
   --
   /***************************************************************************
      PROCEDURE p_carga_sin_tramitacion
      Procedimiento que inserta los registros grabados en MIG_SIN_TRAMITA_JUDICIAL_bs, en la tabla
      MIG_SIN_TRAMITA_JUDICIAL de iAXIS.
   ****************************************************************************/
   PROCEDURE p_carga_sin_tramitacion
   IS
      --
     TYPE t_mig_sin_tramitacion IS TABLE OF mig_sin_tramitacion%ROWTYPE;
     l_reg_mig_mcc t_mig_sin_tramitacion;
     --
      CURSOR lc_mig_sin_tramitacion IS
       SELECT 17442 NCARGA, 1 CESTMIG, a.MIG_PK, a.MIG_FK, 0 NSINIES, a.NTRAMIT, a.CTRAMIT,
              a.CTCAUSIN, a.CINFORM, NVL(a.CUSUALT, 'CONF_MIGRA'), NVL(a.FALTA, s.falta), a.CUSUMOD, a.FMODIFI, NULL FFORMALIZACION , a.NRADICA /* hag: Add este campo, parche*/
       --select count(*)
        FROM mig_sin_tramitacion_bs a, mig_sin_siniestro s
       WHERE 1 = 1
          AND a.mig_fk = s.mig_pk
          AND s.sseguro <> 0
          --AND a.mig_pk = '10101020012256:2012-01000'
        ORDER BY a.mig_pk
          ;
        --SELECT * FROM mig_sin_tramitacion_conf s for update; WHERE s.mig_pk = '131050100DL0200681';
        --SELECT * FROM mig_sin_tramitacion s for update WHERE s.mig_pk = 'RD30094778';
        --SELECT * FROM sin_tramitacion s WHERE mig_fk = '1023871325';
     --
  BEGIN
    --
    -----------------------------------------
    --MIG_sin_tramitacion
    -----------------------------------------
    OPEN lc_mig_sin_tramitacion;
    LOOP
      --
      FETCH lc_mig_sin_tramitacion BULK COLLECT INTO l_reg_mig_mcc LIMIT 100000;  -- limit to 10k to avoid out of memory
      --
      --FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
      --DELETE FROM mig_sin_tramitacion WHERE mig_pk = l_reg_mig_mcc(i).mig_pk;
      --
      BEGIN
        --
        FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
        INSERT INTO mig_sin_tramitacion VALUES l_reg_mig_mcc(i);
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
          p_control_error(g_user,'03_mig_sin_tramitacion','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
          --
        END LOOP;
        --
      END;
      --
      dbms_output.put_line('lc_mig_sin_tramitacion - F - paso bullk');
      --
      EXIT WHEN lc_mig_sin_tramitacion%NOTFOUND;
       --
     END LOOP;
     --
     gcant_a_cargar   := lc_mig_sin_tramitacion%ROWCOUNT;
     --
     SELECT COUNT(*) INTO gcant_a_cargar_bs FROM mig_sin_tramitacion_bs;
     SELECT COUNT(*) INTO gcant_cargada FROM mig_sin_tramitacion;
     --
     CLOSE lc_mig_sin_tramitacion;
     --
   END p_carga_sin_tramitacion;
   --
   /***************************************************************************
      PROCEDURE p_carga_tramita_movimiento
      Procedimiento que inserta los registros grabados en MIG_SIN_TRAMITA_MVTO_BS, en la tabla
      MIG_SIN_TRAMITA_MOVIMIENTO de iAXIS.
   ***************************************************************************
   PROCEDURE p_carga_tramita_movimiento
   IS
     --
     TYPE t_mig_sin_tramita_movimiento IS TABLE OF mig_sin_tramita_movimiento%ROWTYPE;
     l_reg_mig_mcc t_mig_sin_tramita_movimiento;
     --
      CURSOR lc_mig_sin_tramita_movimiento IS
      SELECT 17443 NCARGA, 1 CESTMIG,  a.MIG_PK, a.MIG_FK, 0 NSINIES, a.NTRAMIT, a.NMOVTRA,
                  a.CUNITRA, a.CTRAMITAD, a.CESTTRA, a.CSUBTRA, a.FESTTRA, a.CUSUALT, a.FALTA, a.CCAUEST
        --Select count(*)
        FROM mig_sin_tramita_mvto_bs a, mig_sin_tramitacion s
       WHERE 1 = 1
          AND a.mig_fk = s.mig_pk
          AND s.nsinies <> 0
        ORDER BY a.mig_pk;
      --SELECT COUNT(*) FROM mig_sin_tramita_movimiento_bs s; --A cargar: 747651
     --
  BEGIN
    --
    -----------------------------------------
    --SIN_TRAMITA_MOVIMIENTO
    -----------------------------------------
    OPEN lc_mig_sin_tramita_movimiento;
    LOOP
      --
      FETCH lc_mig_sin_tramita_movimiento BULK COLLECT INTO l_reg_mig_mcc LIMIT 100000;  -- limit to 10k to avoid out of memory
      --
      dbms_output.put_line('mig_sin_tramita_movimiento - I - paso bullk');
      --
      --FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
      --DELETE FROM mig_sin_tramita_movimiento WHERE mig_pk = l_reg_mig_mcc(i).mig_pk;
      --
      BEGIN
        --
        FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
        INSERT INTO mig_sin_tramita_movimiento VALUES l_reg_mig_mcc(i);
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
          p_control_error(g_user,'06_mig_sin_tramita_movimiento','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
          --
        END LOOP;
        --
      END;
      --
      dbms_output.put_line('mig_sin_tramita_movimiento - F - paso bullk');
      --
      COMMIT;
      --
      EXIT WHEN lc_mig_sin_tramita_movimiento%NOTFOUND;
       --
     END LOOP;
     --
     gcant_a_cargar   := lc_mig_sin_tramita_movimiento%ROWCOUNT;
     --
     SELECT COUNT(*) INTO gcant_a_cargar_bs FROM mig_sin_tramita_movimiento_bs;
     SELECT COUNT(*) INTO gcant_cargada FROM mig_sin_tramita_movimiento;
     --
     CLOSE lc_mig_sin_tramita_movimiento;
     --
   END p_carga_tramita_movimiento;*/
   --
   /***************************************************************************
      PROCEDURE p_carga_tramita_reserva
      Procedimiento que inserta los registros grabados en MIG_SIN_TRAMITA_RESERVA_BS, en la tabla
      MIG_SIN_TRAMITA_RESERVA de iAXIS.
   ***************************************************************************/
   PROCEDURE p_carga_tramita_reserva
   IS
     --
     TYPE t_mig_sin_tramita_reserva IS TABLE OF mig_sin_tramita_reserva%ROWTYPE;
     l_reg_mig_mcc t_mig_sin_tramita_reserva;
     --
     CURSOR lc_mig_sin_tramita_reserva IS
     SELECT 17444 NCARGA, 1 CESTMIG, a.MIG_PK, a.MIG_FK, 0 NSINIES, a.NTRAMIT, a.CTIPRES, a.NMOVRES, a.CGARANT, a.CCALRES, a.FMOVRES,
          a.CMONRES, a.IRESERVA, a.IPAGO, a.IINGRESO, a.IRECOBRO, a.ICAPRIE, a.IPENALI, a.FRESINI, a.FRESFIN, a.FULTPAG, 0 SPROCES, a.FCONTAB,
          NVL(a.CUSUALT, 'MIGRA_CONF'), a.FALTA, a.CUSUMOD, a.FMODIFI, a.IPREREC, a.CTIPGAS, NULL IRESERVA_MONCIA, NULL IPAGO_MONCIA, NULL IINGRESO_MONCIA,
          NULL IRECOBRO_MONCIA, NULL ICAPRIE_MONCIA, NULL IPENALI_MONCIA, NULL IPREREC_MONCIA, NULL FCAMBIO, a.IFRANQ, NULL IFRANQ_MONCIA,
          NULL IDRES, NULL CMOVRES, NULL SIDEPAG
--select count(*)
      FROM mig_sin_tramita_reserva_bs a, mig_sin_tramitacion s
     WHERE 1 = 1
        AND a.mig_fk = s.mig_pk
        AND s.nsinies <> 0
      ORDER BY a.mig_pk
        ;
        --SELECT * FROM mig_sin_tramita_reserva_conf s for update; WHERE s.mig_pk = '131050100DL0200681';
        --SELECT * FROM mig_sin_tramita_reserva s for update WHERE s.mig_pk = 'RD30094778';
     --
  BEGIN
    --
    -----------------------------------------
    --sin_tramita_reserva
    -----------------------------------------
    OPEN lc_mig_sin_tramita_reserva;
    LOOP
      --
      FETCH lc_mig_sin_tramita_reserva BULK COLLECT INTO l_reg_mig_mcc LIMIT 100000;  -- limit to 10k to avoid out of memory
      --
      dbms_output.put_line('mig_sin_tramita_reserva - I - paso bullk');
      --
      --FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
      --DELETE FROM mig_sin_tramita_reserva WHERE mig_pk = l_reg_mig_mcc(i).mig_pk;
      --
      BEGIN
        --
        FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
        INSERT INTO mig_sin_tramita_reserva VALUES l_reg_mig_mcc(i);
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
          p_control_error(g_user,'10_mig_sin_tramita_reserva','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
          --
        END LOOP;
        --
      END;
      --
      dbms_output.put_line('mig_sin_tramita_reserva - F - paso bullk');
      --
      COMMIT;
      --
      EXIT WHEN lc_mig_sin_tramita_reserva%NOTFOUND;
       --
     END LOOP;
     --
     gcant_a_cargar   := lc_mig_sin_tramita_reserva%ROWCOUNT;
     --
     SELECT COUNT(*) INTO gcant_a_cargar_bs FROM mig_sin_tramita_reserva_bs;
     SELECT COUNT(*) INTO gcant_cargada FROM mig_sin_tramita_reserva;
     --
     CLOSE lc_mig_sin_tramita_reserva;
     --
   END p_carga_tramita_reserva;
   --
   /***************************************************************************
      PROCEDURE p_carga_tramita_pago
      Procedimiento que inserta los registros grabados en MIG_SIN_TRAMITA_PAGO_BS, en la tabla
      MIG_SIN_TRAMITA_PAGO de iAXIS.
   ***************************************************************************/
   PROCEDURE p_carga_tramita_pago
   IS
     --
     TYPE t_mig_sin_tramita_pago IS TABLE OF mig_sin_tramita_pago%ROWTYPE;
     l_reg_mig_mcc t_mig_sin_tramita_pago;
     --
      CURSOR lc_mig_sin_tramita_pago IS
      SELECT 17445 NCARGA, 1 CESTMIG, a.MIG_PK, a.MIG_FK, a.MIG_FK2, 0 SIDEPAG, 0 NSINIES, a.NTRAMIT, 0 SPERSON, a.CTIPDES, a.CTIPPAG, NVL(a.CCONPAG, 0), a.CCAUIND,
        NVL(a.CFORPAG, 0), a.FORDPAG, a.CTIPBAN, a.CBANCAR, a.CMONRES, a.ISINRET, a.IRETENC, a.IIVA, a.ISUPLID, a.IFRANQ, a.IRESRCM, a.IRESRED, a.CMONPAG,
         a.ISINRETPAG, a.IRETENCPAG, a.IIVAPAG, a.ISUPLIDPAG, a.IFRANQPAG, a.IRESRCMPAG, a.IRESREDPAG, a.FCAMBIO, a.NFACREF, a.FFACREF,NVL(a.CUSUALT, 'CONF_MIG'), NVL(a.FALTA, F_SYSDATE),	NVL(a.CUSUMOD, 'CONF_MIG'),
         a.FMODIFI, a.CTRANSFER, a.CULTPAG, a.IRETEIVA, a.IRETEICA, 0 IICA, 0 IRETEIVAPAG, 0 IRETEICAPAG, 0 IICAPAG, 0 CTRIBUTA, 0 SPERSON_PRESENTADOR,
         null TOBSERVA, 0 IOTROSGAS, 0 IOTROSGASPAG, 0 IBASEIPOC, 0 IBASEIPOCPAG, 0 IIPOCONSUMO, 0 IIPOCONSUMOPAG
         FROM mig_sin_tramita_pago_bs a, mig_sin_tramitacion s, mig_personas p
       WHERE 1 = 1
       AND s.mig_pk = a.mig_fk2
       AND p.mig_pk = a.mig_fk
       AND s.nsinies <> 0
        ORDER BY a.mig_pk
          ;
          --SELECT count(*) FROM mig_sin_tramita_pago_bs s WHERE s.mig_pk = '131050100DL0200681';
     --
  BEGIN
    --
    dbms_output.put_line('mig_sin_tramita_pago - I - paso bullk');
    -----------------------------------------
    --mig_sin_tramita_pago
    -----------------------------------------
    OPEN lc_mig_sin_tramita_pago;
    LOOP
      --
      FETCH lc_mig_sin_tramita_pago BULK COLLECT INTO l_reg_mig_mcc LIMIT 100000;  -- limit to 10k to avoid out of memory
      --
      --FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
      --DELETE FROM mig_sin_tramita_pago WHERE mig_pk = l_reg_mig_mcc(i).mig_pk;
      --
      BEGIN
        --
        FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
        INSERT INTO mig_sin_tramita_pago VALUES l_reg_mig_mcc(i);
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
          p_control_error(g_user,'13_mig_sin_tramita_pago','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
          --
        END LOOP;
        --
      END;
      --
      dbms_output.put_line('mig_sin_tramita_pago - F - paso bullk');
      --
      COMMIT;
      --
      EXIT WHEN lc_mig_sin_tramita_pago%NOTFOUND;
       --
     END LOOP;
     --
     gcant_a_cargar   := lc_mig_sin_tramita_pago%ROWCOUNT;
     --
     SELECT COUNT(*) INTO gcant_a_cargar_bs FROM mig_sin_tramita_pago_bs;
     SELECT COUNT(*) INTO gcant_cargada FROM mig_sin_tramita_pago;
     --
     CLOSE lc_mig_sin_tramita_pago;
     --
   END p_carga_tramita_pago;
   --
   /***************************************************************************
      PROCEDURE p_carga_tramita_movpago
      Procedimiento que inserta los registros grabados en MIG_TRAMITA_MOVPAGO_BS, en la tabla
      MIG_TRAMITA_MOVPAGO de iAXIS.
   ***************************************************************************
   PROCEDURE p_carga_tramita_movpago
   IS
     --
     TYPE t_mig_sin_tramita_movpago IS TABLE OF mig_sin_tramita_movpago%ROWTYPE;
     l_reg_mig_mcc t_mig_sin_tramita_movpago;
     --
      CURSOR lc_mig_sin_tramita_movpago IS
     SELECT 17445 NCARGA, 1 CESTMIG, a.MIG_PK, a.MIG_FK, 0 SIDEPAG, a.NMOVPAG, a.CESTPAG, a.FEFEPAG,
            a.CESTVAL, a.FCONTAB, 0 SPROCES, a.CUSUALT, a.FALTA, a.CSUBPAG
      FROM mig_sin_tramita_movpago_bs a, mig_sin_tramita_pago s
     WHERE 1 = 1
        AND s.sidepag <> 0
        AND a.mig_fk = s.mig_pk
      ORDER BY a.mig_pk
        ;
          --SELECT count(*) FROM mig_sin_tramita_movpago_bs s WHERE s.mig_pk = '131050100DL0200681';
     --
  BEGIN
    --
    -----------------------------------------
    --CLAUSUESP
    -----------------------------------------
    OPEN lc_mig_sin_tramita_movpago;
    LOOP
      --
      FETCH lc_mig_sin_tramita_movpago BULK COLLECT INTO l_reg_mig_mcc LIMIT 10000;  -- limit to 10k to avoid out of memory
      --
      FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
      DELETE FROM mig_sin_tramita_movpago WHERE mig_pk = l_reg_mig_mcc(i).mig_pk;
      --
      BEGIN
        --
        FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
        INSERT INTO mig_sin_tramita_movpago VALUES l_reg_mig_mcc(i);
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
          p_control_error(g_user,'16_mig_sin_tramita_movpago','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
          --
        END LOOP;
        --
      END;
      --
      dbms_output.put_line('mig_sin_tramita_movpago - F - paso bullk');
      --
      COMMIT;
      --
      EXIT WHEN lc_mig_sin_tramita_movpago%NOTFOUND;
       --
     END LOOP;
     --
     --
     gcant_a_cargar   := lc_mig_sin_tramita_movpago%ROWCOUNT;
     --
     SELECT COUNT(*) INTO gcant_a_cargar_bs FROM mig_sin_tramita_movpago_bs;
     SELECT COUNT(*) INTO gcant_cargada FROM mig_sin_tramita_movpago;
     --
     CLOSE lc_mig_sin_tramita_movpago;
     --
   END p_carga_clausuesp;*/
   --
   /***************************************************************************
      PROCEDURE p_carga_tram_judi_detper
      Procedimiento que inserta los registros grabados en TRAM_JUDI_DETPER_BS, en la tabla
      TRAM_JUDI_DETPER de iAXIS.
   ***************************************************************************
   PROCEDURE p_carga_tram_judi_detper
   IS
     --
     TYPE t_mig_sin_tram_judi_detper IS TABLE OF mig_sin_tram_judi_detper%ROWTYPE;
     l_reg_mig_mcc t_mig_sin_tram_judi_detper;
     --
    CURSOR lc_mig_sin_tram_judi_detper IS
     SELECT 17459 NCARGA, 1 CESTMIG, 0 nsinies, 0 ntramit, a.MIG_PK,	a.MIG_FK,	a.MIG_FK2,	a.NORDEN,	a.NROL,	a.NPERSONA,	a.NTIPPER,
            a.NNUMIDE,	a.TNOMBRE,	a.IIMPORTE,	a.FBAJA,	a.FMODIFI,	a.CUSUALT
      FROM mig_sin_tram_judi_detper_bs a, mig_sin_siniestro s, mig_sin_tramita_judicial t
     WHERE 1 = 1
        AND a.mig_fk = s.mig_pk
        AND a.mig_fk2 = t.mig_pk
        AND s.nsinies <> 0
        AND t.nsinies <> 0
      ORDER BY a.mig_pk
        ;
          --SELECT * FROM mig_sin_tram_judi_detper s WHERE s.mig_pk = '131050100DL0200681';
     --
  BEGIN
    --
    -----------------------------------------
    --mig_sin_tram_judi_detper
    -----------------------------------------
    OPEN lc_mig_sin_tram_judi_detper;
    LOOP
      --
      FETCH lc_mig_sin_tram_judi_detper BULK COLLECT INTO l_reg_mig_mcc LIMIT 100000;  -- limit to 10k to avoid out of memory
      --
      --FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
      --DELETE FROM mig_sin_tram_judi_detper WHERE mig_pk = l_reg_mig_mcc(i).mig_pk;
      --
      BEGIN
        --
        FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
        INSERT INTO mig_sin_tram_judi_detper VALUES l_reg_mig_mcc(i);
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
          p_control_error(g_user,'19_mig_sin_tram_judi_detper','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
          --
        END LOOP;
        --
      END;
      --
      dbms_output.put_line('mig_sin_tram_judi_detper - F - paso bullk');
      --
      COMMIT;
      --
      EXIT WHEN lc_mig_sin_tram_judi_detper%NOTFOUND;
       --
     END LOOP;
     --
     gcant_a_cargar   := lc_mig_sin_tram_judi_detper%ROWCOUNT;
     --
     SELECT COUNT(*) INTO gcant_a_cargar_bs FROM mig_sin_tram_judi_detper_bs;
     SELECT COUNT(*) INTO gcant_cargada FROM mig_sin_tram_judi_detper;
     --
     CLOSE lc_mig_sin_tram_judi_detper;
     --
   END p_carga_tram_judi_detper;*/
   --
   /***************************************************************************
      PROCEDURE p_carga_sin_tram_valpret
      Procedimiento que inserta los registros grabados en MIG_SIN_TRAM_VALPRET_BS, en la tabla
      MIG_SIN_TRAM_VALPRET de iAXIS.
   ***************************************************************************
   PROCEDURE p_carga_sin_tram_valpret
   IS
     --
     TYPE t_mig_sin_tram_valpret IS TABLE OF mig_sin_tram_valpret%ROWTYPE;
     l_reg_mig_mcc t_mig_sin_tram_valpret;
     --
      CURSOR lc_mig_sin_tram_valpret IS
       SELECT 17450 NCARGA, 1 CESTMIG, 0 nsinies, 0 ntramit, a.MIG_PK, a.MIG_FK, a.MIG_FK2, a.NORDEN, a.CGARANT,
              a.IPRETEN, a.FBAJA, a.FMODIFI, a.CUSUALT
        FROM mig_sin_tram_valpret_bs a, mig_sin_siniestro s, mig_sin_tramita_judicial t
       WHERE 1 = 1
          AND a.mig_fk = s.mig_pk
          AND a.mig_fk2 = t.mig_pk
          AND s.nsinies <> 0
          AND t.nsinies <> 0
        ORDER BY a.mig_pk;
        --SELECT * FROM mig_pregunseg_bs s WHERE s.mig_pk = '131050100DL0200681';
     --
  BEGIN
    --
    -----------------------------------------
    --MIG_SIN_TRAM_VALPRET
    -----------------------------------------
    DELETE control_error s WHERE TRUNC(s.fecha) = TRUNC(SYSDATE) AND s.donde = '22_sin_tram_valpret';
    --
    OPEN lc_mig_sin_tram_valpret;
    LOOP
      --
      FETCH lc_mig_sin_tram_valpret BULK COLLECT INTO l_reg_mig_mcc LIMIT 100000;  -- limit to 10k to avoid out of memory
      --
      dbms_output.put_line('mig_sin_tram_valpret - I - paso bullk');
      --
      --FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
      --DELETE FROM mig_sin_tram_valpret WHERE mig_pk = l_reg_mig_mcc(i).mig_pk;
      --
      BEGIN
        --
        FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
        INSERT INTO mig_sin_tram_valpret VALUES l_reg_mig_mcc(i);
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
          p_control_error(g_user,'22_mig_sin_tram_valpret','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
          --
        END LOOP;
        --
      END;
      --
      dbms_output.put_line('mig_sin_tram_valpret - F - paso bullk');
      --
      COMMIT;
      --
      EXIT WHEN lc_mig_sin_tram_valpret%NOTFOUND;
       --
     END LOOP;
     --
     gcant_a_cargar   := lc_mig_sin_tram_valpret%ROWCOUNT;
     --
     SELECT COUNT(*) INTO gcant_a_cargar_bs FROM mig_sin_tram_valpret_bs;
     SELECT COUNT(*) INTO gcant_cargada FROM mig_sin_tram_valpret;
     CLOSE lc_mig_sin_tram_valpret;
     --
   END p_carga_sin_tram_valpret;*/
   --
   /***************************************************************************
      PROCEDURE p_carga_tramita_fiscal
      Procedimiento que inserta los registros grabados en MIG_SIN_TRAMITA_FISCAL_BS, en la tabla
      MIG_SIN_TRAMITA_FISCAL de iAXIS.
   ***************************************************************************/
   PROCEDURE p_carga_tramita_fiscal
   IS
     --
     TYPE t_mig_sin_tramita_fiscal IS TABLE OF mig_sin_tramita_fiscal%ROWTYPE;
     l_reg_mig_mcc t_mig_sin_tramita_fiscal;
     --
      CURSOR lc_mig_sin_tramita_fiscal IS
       SELECT 17461 NCARGA, 1 CESTMIG, 0 nsinies, 0 ntramit, a.MIG_PK,	a.MIG_FK,	a.MIG_FK2,	a.NORDEN,	a.FAPERTU,	a.FIMPUTA,	a.FNOTIFI,
       a.FAUDIEN,	a.HAUDIEN,	a.CAUDIEN,	a.SPROFES,	a.COTERRI,	a.CCONTRA,	a.CUESPEC,	a.TCONTRA,	a.CTIPTRA,	a.TESTADO,	a.CMEDIO,	a.FDESCAR,
       a.FFALLO,	a.CFALLO,	NULL TFALLO /*Ojo deben crear*/, a.CRECURSO, a.FMODIFI, a.CUSUALT
      --SELECT COUNT(*)
        FROM mig_sin_tramita_fiscal_bs a, mig_sin_siniestro s, mig_sin_tramita_judicial t
       WHERE 1 = 1
          AND a.mig_fk  = s.mig_pk
          AND a.mig_fk2 = t.mig_pk
          AND s.nsinies <> 0
          AND t.nsinies <> 0
        ORDER BY a.mig_pk;
          --SELECT * FROM mig_sin_tramita_fiscal_conf s WHERE s.mig_pk = '131050100DL0200681';
     --
  BEGIN
    --
    -----------------------------------------
    --CTASEGURO
    -----------------------------------------
    OPEN lc_mig_sin_tramita_fiscal;
    LOOP
      --
      FETCH lc_mig_sin_tramita_fiscal BULK COLLECT INTO l_reg_mig_mcc LIMIT 10000;  -- limit to 10k to avoid out of memory
      --
      dbms_output.put_line('ctaseguro - I - paso bullk');
      --
      dbms_output.put_line('...');
      --
      --FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
      --DELETE FROM mig_sin_tramita_fiscal WHERE mig_pk = l_reg_mig_mcc(i).mig_pk;
      --
      BEGIN
        --
        FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
        INSERT INTO mig_sin_tramita_fiscal VALUES l_reg_mig_mcc(i);
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
          p_control_error(g_user,'25_mig_sin_tramita_fiscal','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
          --
        END LOOP;
        --
      END;
      --
      dbms_output.put_line('ctaseguro - F - paso bullk');
      --
      COMMIT;
      --
      EXIT WHEN lc_mig_sin_tramita_fiscal%NOTFOUND;
       --
     END LOOP;
     --
     gcant_a_cargar   := lc_mig_sin_tramita_fiscal%ROWCOUNT;
     --
     SELECT COUNT(*) INTO gcant_a_cargar_bs FROM mig_sin_tramita_fiscal_bs;
     SELECT COUNT(*) INTO gcant_cargada FROM mig_sin_tramita_fiscal;
     CLOSE lc_mig_sin_tramita_fiscal;
     --
   END p_carga_tramita_fiscal;
   --
   /***************************************************************************
      PROCEDURE p_carga_sin_tram_vpretfis
      Procedimiento que inserta los registros grabados en MIG_SIN_TRAM_VPRETFIS_BS, en la tabla
      MIG_SIN_TRAM_VPRETFIS de iAXIS.
   ***************************************************************************
   PROCEDURE p_carga_sin_tram_vpretfis
   IS
     --
     TYPE t_mig_sin_tram_vpretfis IS TABLE OF mig_sin_tram_vpretfis%ROWTYPE;
     l_reg_mig_mcc t_mig_sin_tram_vpretfis;
     --
      CURSOR lc_mig_sin_tram_vpretfis IS
       SELECT 17452 NCARGA,1 CESTMIG, a.MIG_PK, a.MIG_FK, 0 SSEGURO,
              a.FALTA, a.CTIPREG, a.CESTADO, a.TTITULO, a.FFINALI, a.TTEXTOS, a.CMANUAL
          FROM mig_sin_tram_vpretfis_bs a, mig_seguros s
         WHERE s.mig_pk = a.mig_fk
      ORDER BY a.mig_pk
          --AND s.mig_pk = '131050100DL0200681'
          ;
          --SELECT * FROM mig_sin_tram_vpretfis_conf s WHERE s.mig_pk = '131050100DL0200681';
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
    --MIG_AGENSEGU
    -----------------------------------------
    OPEN lc_mig_sin_tram_vpretfis;
    LOOP
      --
      FETCH lc_mig_sin_tram_vpretfis BULK COLLECT INTO l_reg_mig_mcc LIMIT 10000;  -- limit to 10k to avoid out of memory
      --
      dbms_output.put_line('agensegu - I - paso bullk');
      --
      dbms_output.put_line('...');
      --
      --FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
      --DELETE FROM mig_sin_tram_vpretfis WHERE mig_pk = l_reg_mig_mcc(i).mig_pk;
      --
      BEGIN
        --
        FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
        INSERT INTO mig_sin_tram_vpretfis VALUES l_reg_mig_mcc(i);
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
          p_control_error(g_user,'31_mig_sin_tram_vpretfis','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
          --
        END LOOP;
        --
      END;
      --
      dbms_output.put_line('mig_sin_tram_vpretfis - F - paso bullk');
      --
      COMMIT;
      --
      EXIT WHEN lc_mig_sin_tram_vpretfis%NOTFOUND;
       --
     END LOOP;
     --
     gcant_a_cargar   := lc_mig_sin_tram_vpretfis%ROWCOUNT;
     --
     SELECT COUNT(*) INTO gcant_a_cargar_bs FROM mig_sin_tram_vpretfis_bs;
     SELECT COUNT(*) INTO gcant_cargada FROM mig_sin_tram_vpretfis;
     CLOSE lc_mig_sin_tram_vpretfis;
     --
   END p_carga_sin_tram_vpretfis;*/
   --
   /***************************************************************************
      PROCEDURE p_carga_tramita_citaciones
      Procedimiento que inserta los registros grabados en MIG_PREGUNGARANSEG_bs, en la tabla
      MIG_PREGUNGARANSEG de iAXIS.
   ***************************************************************************
   PROCEDURE p_carga_tramita_citaciones
   IS
     --
     TYPE t_mig_sin_tramita_citaciones IS TABLE OF mig_sin_tramita_citaciones%ROWTYPE;
     l_reg_mig_mcc t_mig_sin_tramita_citaciones;
     --
    CURSOR lc_mig_sin_tramita_citaciones IS
     SELECT 17428 NCARGA, 1 CESTMIG, a.MIG_PK, a.MIG_FK, 0 NSINIES, 0 NTRAMIT, a.NCITACION, a.FCITACION, a.HCITACION, a.SPERSON,
            a.CPAIS, a.CPROVIN, a.CPOBLAC, a.TLUGAR, a.FALTA, a.TAUDIEN, a.CORAL, a.CESTADO, a.CRESOLU, a.FNUEVA, a.TRESULT, a.CMEDIO
     --Select count(*)
      FROM mig_sin_tramita_citaciones_bs a, mig_sin_tramitacion t
     WHERE 1 = 1
        AND a.mig_fk  = t.mig_pk
        AND t.nsinies <> 0
        AND t.ntramit <> 0
      ORDER BY a.mig_pk
        ;
          --SELECT * FROM mig_sin_tramita_citaciones_conf s WHERE s.mig_pk = '131050100DL0200681';
     --
  BEGIN
    --
    -----------------------------------------
    --MIG_sin_tramita_citaciones
    -----------------------------------------
    OPEN lc_mig_sin_tramita_citaciones;
    LOOP
      --
      FETCH lc_mig_sin_tramita_citaciones BULK COLLECT INTO l_reg_mig_mcc LIMIT 10000;  -- limit to 10k to avoid out of memory
      --
      dbms_output.put_line('mig_sin_tramita_citaciones - I - paso bullk');
      --
      dbms_output.put_line('...');
      --
      --FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
      --DELETE FROM mig_sin_tramita_citaciones WHERE mig_pk = l_reg_mig_mcc(i).mig_pk;
      --
      BEGIN
        --
        FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
        INSERT INTO mig_sin_tramita_citaciones VALUES l_reg_mig_mcc(i);
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
          p_control_error(g_user,'34_mig_sin_tramita_citaciones','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
          --
        END LOOP;
        --
      END;
      --
      dbms_output.put_line('mig_sin_tramita_citaciones - F - paso bullk');
      --
      COMMIT;
      --
      EXIT WHEN lc_mig_sin_tramita_citaciones%NOTFOUND;
       --
     END LOOP;
     --
     gcant_a_cargar   := lc_mig_sin_tramita_citaciones%ROWCOUNT;
     --
     SELECT COUNT(*) INTO gcant_a_cargar_bs FROM mig_sin_tramita_citaciones_bs;
     SELECT COUNT(*) INTO gcant_cargada FROM mig_sin_tramita_citaciones;
     CLOSE lc_mig_sin_tramita_citaciones;
     --
   END p_carga_tramita_citaciones;*/
   --
   /***************************************************************************
      PROCEDURE p_carga_sin_tramita_apoyo
      Procedimiento que inserta los registros grabados en MIG_SIN_TRAMITA_APOYO_BS, en la tabla
      MIG_SIN_TRAMITA_APOYO de iAXIS.
   ***************************************************************************
   PROCEDURE p_carga_sin_tramita_apoyo
   IS
     --
     TYPE t_mig_sin_tramita_apoyo IS TABLE OF mig_sin_tramita_apoyo%ROWTYPE;
     l_reg_mig_mcc t_mig_sin_tramita_apoyo;
     --
    CURSOR lc_mig_sin_tramita_apoyo IS
     SELECT 17455 NCARGA, 1 CESTMIG, a.MIG_PK, a.MIG_FK, a.MIG_FK2, a.SINTAPO, 0 NSINIES, 0 NTRAMIT, a.NAPOYO, a.CUNITRA,
            a.CTRAMITAD, a.FINGRESO, a.FTERMINO, a.FSALIDA, a.TOBSERVA, a.TLOCALI, a.CSIGLAS, a.TNOMVIA, a.NNUMVIA, a.TCOMPLE,
            a.CPAIS, a.CPROVIN, a.CPOBLAC, a.CPOSTAL, a.CVIAVP, a.CLITVP, a.CBISVP, a.CORVP, a.NVIAADCO, a.CLITCO, a.CORCO,
            a.NPLACACO, a.COR2CO, a.CDET1IA, a.TNUM1IA, a.CDET2IA, a.TNUM2IA, a.CDET3IA, a.TNUM3IA, a.LOCALIDAD, a.FALTA,
            a.CUSUALT, a.FMODIFI, a.CUSUMOD, a.TOBSERVA2, a.CAGENTE, a.SPERSON
     --Select count(*)
     --select *
      FROM mig_sin_tramita_apoyo_bs a, mig_sin_siniestro s
     WHERE 1 = 1
        AND a.mig_fk  = s.mig_pk
        AND s.nsinies <> 0
      ORDER BY a.mig_pk
        ;
          --SELECT * FROM mig_sin_tramita_apoyo_conf s WHERE s.mig_pk = '131050100DL0200681';
     --
  BEGIN
    --
    -----------------------------------------
    --MIG_SIN_TRAMITA_APOYO
    -----------------------------------------
    OPEN lc_mig_sin_tramita_apoyo;
    LOOP
      --
      FETCH lc_mig_sin_tramita_apoyo BULK COLLECT INTO l_reg_mig_mcc LIMIT 100000;  -- limit to 10k to avoid out of memory
      --
      dbms_output.put_line('sitriesgo - I - paso bullk');
      --
      dbms_output.put_line('...');
      --
      --FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
      --DELETE FROM mig_sin_tramita_apoyo WHERE mig_pk = l_reg_mig_mcc(i).mig_pk;
      --
      BEGIN
        --
        FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
        INSERT INTO mig_sin_tramita_apoyo VALUES l_reg_mig_mcc(i);
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
          p_control_error(g_user,'37_mig_sin_tramita_apoyo','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
          --
        END LOOP;
        --
      END;
      --
      dbms_output.put_line('sitriesgo - F - paso bullk');
      --
      COMMIT;
      --
      EXIT WHEN lc_mig_sin_tramita_apoyo%NOTFOUND;
       --
     END LOOP;
     --
     gcant_a_cargar   := lc_mig_sin_tramita_apoyo%ROWCOUNT;
     --
     SELECT COUNT(*) INTO gcant_a_cargar_bs FROM mig_sin_tramita_apoyo_bs;
     SELECT COUNT(*) INTO gcant_cargada FROM mig_sin_tramita_apoyo;
     CLOSE lc_mig_sin_tramita_apoyo;
     --
   END p_carga_sin_tramita_apoyo;*/
   --
   /***************************************************************************
      PROCEDURE p_carga_agd_observaciones
      Procedimiento que inserta los registros grabados en MIG_AGD_OBSERVACIONES_BS, en la tabla
      MIG_AGD_OBSERVACIONES de iAXIS.
   ****************************************************************************
   PROCEDURE p_carga_agd_observaciones
   IS
     --
     TYPE t_mig_agd_observaciones IS TABLE OF mig_agd_observaciones%ROWTYPE;
     l_reg_mig_mcc t_mig_agd_observaciones;
     --
      CURSOR lc_mig_agd_observaciones IS
       SELECT 17454 NCARGA,1 CESTMIG, a.MIG_PK, a.MIG_FK, a.CTIPOBS, a.TTITOBS
              a.TOBS, a.CTIPAGD, a.NTRAMIT, a.PUBLICO, a.CCONOBS, NVL(a.FALTA, TRUNC(SYSDATE))
       --SELECT COUNT(*)
       --select *
        FROM mig_agd_observaciones_bs a, mig_sin_siniestro s
       WHERE 1 = 1
         AND s.mig_pk = a.mig_fk2
       ORDER BY a.mig_pk
          ;
          --SELECT * FROM mig_agd_observaciones_conf s WHERE s.mig_pk = '131050100DL0200681';
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
    --MIG_AGD_OBSERVACIONES
    -----------------------------------------
    OPEN lc_mig_agd_observaciones;
    LOOP
      --
      FETCH lc_mig_agd_observaciones BULK COLLECT INTO l_reg_mig_mcc LIMIT 100000;  -- limit to 10k to avoid out of memory
      --
      dbms_output.put_line('ctgar_contragarantia - I - paso bullk');
      --
      dbms_output.put_line('...');
      --
      --FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
      --DELETE FROM mig_agd_observaciones WHERE mig_pk = l_reg_mig_mcc(i).mig_pk;
      --
      BEGIN
        --
        FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
        INSERT INTO mig_agd_observaciones VALUES l_reg_mig_mcc(i);
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
          p_control_error(g_user,'40_mig_agd_observaciones','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
          --
        END LOOP;
        --
      END;
      --
      dbms_output.put_line('ctgar_contragarantia - F - paso bullk');
      --
      EXIT WHEN lc_mig_agd_observaciones%NOTFOUND;
       --
     END LOOP;
     --
     gcant_a_cargar   := lc_mig_agd_observaciones%ROWCOUNT;
     --
     SELECT COUNT(*) INTO gcant_a_cargar_bs FROM mig_agd_observaciones_bs;
     SELECT COUNT(*) INTO gcant_cargada FROM mig_agd_observaciones;
     CLOSE lc_mig_agd_observaciones;
     --
   END p_carga_agd_observaciones;*/
   /***************************************************************************
      PROCEDURE p_carga_sini
      Procedimiento que ejecuta el cargue de un fichero particular
         param in  ptab_des:     Descripción de la tabla.
   ***************************************************************************/
   PROCEDURE p_carga_sini(ptab_des VARCHAR2)
   IS
     --
     l_timestart       NUMBER;
     l_timeend         NUMBER;
     l_time            NUMBER;
     vdummy            NUMBER;
     --
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
     IF ptab_des = 'MIG_SIN_SINIESTRO'
     THEN
       --
       p_carga_siniestros;
      --
     ELSIF ptab_des = 'MIG_SIN_TRAMITA_JUDICIAL'
     THEN
       --
       --p_carga_tramita_judicial;
       dbms_output.put_line('por definir . . . p_carga_tramita_judicial '||g_user);
       --
     ELSIF ptab_des = 'MIG_SIN_MOVSINIESTRO'
     THEN
       --
       p_carga_sin_movsiniestro;
       --
     ELSIF ptab_des = 'MIG_SIN_TRAMITACION'
     THEN
       --
       p_carga_sin_tramitacion;
       --
     ELSIF ptab_des = 'MIG_SIN_TRAMITA_MOVIMIENTO'
     THEN
       --
       --p_carga_tramita_movimiento;
       dbms_output.put_line('por definir . . . p_carga_tramita_movimiento '||g_user);
       --
     ELSIF ptab_des = 'MIG_SIN_TRAMITA_PAGO'
     THEN
       --
       p_carga_tramita_pago;
       --
     ELSIF ptab_des = 'MIG_SIN_TRAMITA_MOVPAGO'
     THEN
       --
       --p_carga_tramita_movpago;
       dbms_output.put_line('por definir . . . p_carga_tramita_movpago '||g_user);
       --
     ELSIF ptab_des = 'MIG_SIN_TRAM_JUDI_DETPER'
     THEN
       --
       --p_carga_tram_judi_detper;
       dbms_output.put_line('por definir . . . p_carga_tram_judi_detper '||g_user);
       --
     ELSIF ptab_des = 'MIG_SIN_TRAM_VALPRET'
     THEN
       --
       --p_carga_sin_tram_valpret;
       dbms_output.put_line('por definir . . . p_carga_sin_tram_valpret '||g_user);
       --
     ELSIF ptab_des = 'MIG_SIN_TRAMITA_FISCAL'
     THEN
       --
       p_carga_tramita_fiscal;
       --dbms_output.put_line('por definir . . . p_carga_ctaseguro '||g_user);
       --
     ELSIF ptab_des = 'MIG_SIN_TRAM_VPRETFIS'
     THEN
       --
       --p_carga_sin_tram_vpretfis;
       dbms_output.put_line('por definir . . . p_carga_sin_tram_vpretfis '||g_user);
       --
     ELSIF ptab_des = 'MIG_SIN_TRAMITA_CITACIONES'
     THEN
       --
       --p_carga_tramita_citaciones;
       dbms_output.put_line('por definir . . . p_carga_tramita_citaciones '||g_user);
       --
     ELSIF ptab_des = 'MIG_SIN_TRAMITA_APOYO'
     THEN
       --
       --p_carga_sin_tramita_apoyo;
       dbms_output.put_line('por definir . . . p_carga_sin_tramita_apoyo '||g_user);
       --
     ELSIF ptab_des = 'MIG_AGD_OBSERVACIONES'
     THEN
       --
       --p_carga_agd_observaciones;
       dbms_output.put_line('por definir . . . p_carga_agd_observaciones '||g_user);
       --
     END IF;
     --
     l_timeend := dbms_utility.get_time();
     l_time    := (l_timeend - l_timestart) / 100;
     v_texto   := gcant_a_cargar_bs || '/' || gcant_cargada || ' reg cargados de ' || gcant_a_cargar || '. Tiempo de Ejecución: '|| l_time || ' seg';
     p_control_error(g_user, ptab_des, v_texto);
     dbms_output.put_line(v_texto);
     --
   END p_carga_sini;
   --
END pac_carga_siniestros_conf;

/

  GRANT EXECUTE ON "AXIS"."PAC_CARGA_SINIESTROS_CONF" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_CARGA_SINIESTROS_CONF" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_CARGA_SINIESTROS_CONF" TO "PROGRAMADORESCSI";
