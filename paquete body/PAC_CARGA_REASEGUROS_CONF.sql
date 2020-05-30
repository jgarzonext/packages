create or replace PACKAGE BODY "PAC_CARGA_REASEGUROS_CONF" IS
   /***************************************************************************
      NOMBRE:       pac_carga_reaseguros_conf
      PROPÃ“SITO:    Proceso de traspaso de informacion de las tablas base _BS
                    a las distintas tablas MIG_ de AXIS (CapÃ­tulo ReaSeguros)
      REVISIONES:
      Ver        Fecha       Autor       DescripciÃ³n
      ---------  ----------  ----------  --------------------------------------
       1.0        12/02/2018  HAG         Creacion package de carga
       1.1        16/02/2018  HAG         Incluir cargas de coacedido, ctacoaseguro
       1.2        26/01/2020  INFORCOL    Reaseguro facultativo - ajuste para deposito en prima retenida
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
         param in  puser:     DescripciÃ³n del usuario.
   ***************************************************************************/
   PROCEDURE p_asigna_user(puser VARCHAR2)
   IS
   BEGIN
     --
     g_user := puser;
     --
   END p_asigna_user;
   /***************************************************************************
      PROCEDURE p_carga_companias
      Procedimiento que inserta los registros grabados en MIG_COMPANIAS_BS, en la tabla
      mig_companias de iAXIS.
   ***************************************************************************/
   PROCEDURE p_carga_companias
   IS
     --
     TYPE t_mig_companias IS TABLE OF mig_companias%ROWTYPE;
     l_reg_mig_mcc t_mig_companias;
     --
      CURSOR lc_mig_companias IS
       SELECT 17415 ncarga,1 CESTMIG, a.MIG_PK, a.MIG_FK, 0 CCOMPANI, a.TCOMPANI, a.CTIPCOM,a.PCTIPREA
         FROM mig_companias_bs a
        WHERE 1 = 1
          ;
          --SELECT * FROM mig_companias s;
          --SELECT * FROM mig_companias_conf s WHERE s =  ORDER BY s ;
          --SELECT * FROM mig_movrecibo s;
          --SELECT * FROM mig_companias_conf s for update WHERE s.mig_pk = 'RD30094778';
          --SELECT * FROM pppc_conf s WHERE mig_fk = '1023871325';
     --
  BEGIN
    --
    -----------------------------------------
    --BUREAU
    -----------------------------------------
    OPEN lc_mig_companias;
    LOOP
      --
      FETCH lc_mig_companias BULK COLLECT INTO l_reg_mig_mcc ;--LIMIT v_limit_records;
      --
      dbms_output.put_line('mig_companias - I - paso bullk');
      --
      dbms_output.put_line('...');
      --
      --FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
      --DELETE FROM mig_companias WHERE mig_pk = l_reg_mig_mcc(i).mig_pk;
      --
      BEGIN
        --
        FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
        INSERT INTO mig_companias VALUES l_reg_mig_mcc(i);
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
          p_control_error(g_user,'01_mig_companias','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
          --
        END LOOP;
        --
      END;
      --
      dbms_output.put_line('mig_companias - F - paso bullk');
      --
      EXIT WHEN lc_mig_companias%NOTFOUND;
       --
     END LOOP;
     --
     gcant_a_cargar   := lc_mig_companias%ROWCOUNT;
     --
     SELECT COUNT(*) INTO gcant_a_cargar_bs FROM mig_companias_bs;
     SELECT COUNT(*) INTO gcant_cargada FROM mig_companias;
     --
     CLOSE lc_mig_companias;
     --
   END p_carga_companias;
   --
   /***************************************************************************
      PROCEDURE p_carga_codicontratos
      Procedimiento que inserta los registros grabados en MIG_CODICONTRATOS_BS, en la tabla
      MIG_CODICONTRATOS de iAXIS.
   ***************************************************************************/
   PROCEDURE p_carga_codicontratos
   IS
     --
     TYPE t_mig_codicontratos IS TABLE OF mig_codicontratos%ROWTYPE;
     l_reg_mig_mcc t_mig_codicontratos;
     --
      CURSOR lc_mig_codicontratos IS
       SELECT DISTINCT 20047 ncarga,1 CESTMIG, MIG_PK, MIG_FK, NVERSION, 0 SCONTRA, SPLENO, CEMPRES, CTIPREA, FINICTR,
              FFINCTR, NCONREL, SCONAGR, CVIDAGA, CVIDAIR, CTIPCUM, CVALID, CRETIRA, CMONEDA, TDESCRIPCION, CDEVENTO
         FROM mig_CodiContratos_bs mcc
        WHERE 1 = 1
          --AND mcc.mig_pk = '200127001'
          ;
          --SELECT count(*) FROM mig_codicontratos_bs s;
          --SELECT * FROM mig_codicontratos;
          --SELECT * FROM mig_codicontratos_bs s;
          --SELECT * FROM mig_agentes a;
          --SELECT * FROM mig_codicontratos_bs WHERE fefeplazo IS NOT NULL;
     --
  BEGIN
    --
    -----------------------------------------
    --CODICONTRATOS
    -----------------------------------------
    OPEN lc_mig_codicontratos;
    LOOP
      --
      FETCH lc_mig_codicontratos BULK COLLECT INTO l_reg_mig_mcc LIMIT 100000;  -- limit to 10k to avoid out of memory
      --
      --FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
      --DELETE FROM mig_codicontratos WHERE mig_pk = l_reg_mig_mcc(i).mig_pk;
      --
      BEGIN
        --
        FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
        INSERT INTO mig_codicontratos VALUES l_reg_mig_mcc(i);
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
          p_control_error(g_user,'01_mig_codicontratos','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
          --
        END LOOP;
        --
      END;
      --
      dbms_output.put_line('Seguros - F - paso bullk');
      --
      COMMIT;
      --
      EXIT WHEN lc_mig_codicontratos%NOTFOUND;
       --
     END LOOP;
     --
     gcant_a_cargar   := lc_mig_codicontratos%ROWCOUNT;
     --
     SELECT COUNT(*) INTO gcant_a_cargar_bs FROM mig_codicontratos_bs;
     SELECT COUNT(*) INTO gcant_cargada FROM mig_codicontratos;
     --
     CLOSE lc_mig_codicontratos;
     --
   END p_carga_codicontratos;
   --
   /***************************************************************************
      PROCEDURE p_carga_agr_contratos
      Procedimiento que inserta los registros grabados en MIG_AGR_CONTRATOS_BS, en la tabla
      MIG_AGR_CONTRATOS de iAXIS.
   ***************************************************************************/
   PROCEDURE p_carga_agr_contratos
   IS
     --
     TYPE t_mig_agr_contratos IS TABLE OF mig_agr_contratos%ROWTYPE;
     l_reg_mig_mcc t_mig_agr_contratos;
     --
      CURSOR lc_mig_agr_contratos IS
     SELECT 17415 ncarga,1 CESTMIG, a.MIG_PK, a.MIG_FK, 0 SCONTRA, a.CRAMO, a.CMODALI,
            a.CCOLECT, a.CTIPSEG, a.CACTIVI, a.CGARANT, a.NVERSIO, a.ILIMSUB
     --SELECT COUNT(*)
       FROM mig_Agr_contratos_bs a, mig_codicontratos c
      WHERE 1 = 1
        AND a.mig_fk = c.mig_pk
          ;
          --SELECT * FROM mig_agr_contratos_conf s;
          --SELECT * FROM mig_agr_contratos s;
     --
  BEGIN
    --
    -----------------------------------------
    --MOVSEGURO
    -----------------------------------------
    OPEN lc_mig_agr_contratos;
    LOOP
      --
      FETCH lc_mig_agr_contratos BULK COLLECT INTO l_reg_mig_mcc LIMIT 100000;  -- limit to 10k to avoid out of memory
      --
      --FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
      --DELETE FROM mig_agr_contratos WHERE mig_pk = l_reg_mig_mcc(i).mig_pk;
      --
      BEGIN
        --
        FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
        INSERT INTO mig_agr_contratos VALUES l_reg_mig_mcc(i);
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
          p_control_error(g_user,'03_mig_agr_contratos','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
          --
        END LOOP;
        --
      END;
      --
      dbms_output.put_line('lc_mig_agr_contratos - F - paso bullk');
      --
      EXIT WHEN lc_mig_agr_contratos%NOTFOUND;
       --
     END LOOP;
     --
     gcant_a_cargar   := lc_mig_agr_contratos%ROWCOUNT;
     --
     SELECT COUNT(*) INTO gcant_a_cargar_bs FROM mig_agr_contratos_bs;
     SELECT COUNT(*) INTO gcant_cargada FROM mig_agr_contratos;
     --
     CLOSE lc_mig_agr_contratos;
     --
   END p_carga_agr_contratos;
   --
   /***************************************************************************
      PROCEDURE p_carga_contratos
      Procedimiento que inserta los registros grabados en MIG_CONTRATOS_BS, en la tabla
      MIG_CONTRATOS de iAXIS.
   ***************************************************************************/
   PROCEDURE p_carga_contratos
   IS
     --
     TYPE t_mig_contratos IS TABLE OF mig_contratos%ROWTYPE;
     l_reg_mig_mcc t_mig_contratos;
     --
      CURSOR lc_mig_contratos IS
     SELECT 17416 ncarga,1 CESTMIG, MIG_PK, MIG_FK,  NVERSIO, 0 SCONTRA,NVERSIO, 0 NPRIORI,FCONINI,NCONREL,FCONFIN,IAUTORI,
          IRETENC,IMINCES,ICAPACI,IPRIOXL,PPRIOSL,TCONTRA,TOBSERV,PCEDIDO,PRIESGOS,PDESCUENTO,
          PGASTOS,PPARTBENE,CREAFAC,PCESEXT,CGARREL,CFRECUL,SCONQP,NVERQP,IAGREGA,IMAXAGR,
          PDEPOSITO,CDETCES,CLAVECBR,CERCARTERA,NANYOSLOSS,CBASEXL,CLOSSCORRIDOR,CCAPPEDRATIO,
          SCONTRAPROT,CESTADO,NVERSIOPROT,IPRIMAESPERADAS,CTPREEST,PCOMEXT, NULL, NULL, NULL /*FCONFINAUX  Ojo Incluir*/
       --SELECT count(*)
       FROM mig_contratos_bs mcc
      WHERE 1 = 1
      ORDER BY MIG_PK
          ;
          --SELECT * FROM mig_contratos_conf s WHERE s.mig_pk = '131050100DL0200681';
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
    --mig_contratos
    -----------------------------------------
    OPEN lc_mig_contratos;
    LOOP
      --
      FETCH lc_mig_contratos BULK COLLECT INTO l_reg_mig_mcc LIMIT 100000;  -- limit to 10k to avoid out of memory
      --
      dbms_output.put_line('CONTRATOS - I - paso bullk');
      --
      dbms_output.put_line('...');
      --
      --FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
      --DELETE FROM mig_contratos WHERE mig_pk = l_reg_mig_mcc(i).mig_pk;
      --
      BEGIN
        --
        FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
        INSERT INTO mig_contratos VALUES l_reg_mig_mcc(i);
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
          p_control_error(g_user,'04_mig_contratos','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
          --
        END LOOP;
        --
      END;
      --
      dbms_output.put_line('CONTRATOS - F - paso bullk');
      --
      COMMIT;
      --
      EXIT WHEN lc_mig_contratos%NOTFOUND;
       --
     END LOOP;
     --
     gcant_a_cargar   := lc_mig_contratos%ROWCOUNT;
     --
     SELECT COUNT(*) INTO gcant_a_cargar_bs FROM mig_contratos_bs;
     SELECT COUNT(*) INTO gcant_cargada FROM mig_contratos;
     --
     CLOSE lc_mig_contratos;
     --
   END p_carga_contratos;
   --
   /***************************************************************************
      PROCEDURE p_carga_tramos
      Procedimiento que inserta los registros grabados en MIG_TRAMOS_BS, en la tabla
      MIG_TRAMOS de iAXIS.
   ***************************************************************************/
   PROCEDURE p_carga_tramos
   IS
     --
     TYPE t_mig_tramos IS TABLE OF mig_tramos%ROWTYPE;
     l_reg_mig_mcc t_mig_tramos;
     --
      CURSOR lc_mig_tramos IS
     SELECT DISTINCT 17417 ncarga,1 CESTMIG, MIG_PK, MIG_FK, NVERSIO, 0 SCONTRA, TO_NUMBER(SUBSTR(CTRAMO,1 , 2)) CTRAMO, ITOTTRA, NPLENOS, CFREBOR, PLOCAL,
                  IXLPRIO, IXLEXCE, PSLPRIO, PSLEXCE, NCESION, FULTBOR, IMAXPLO, TO_NUMBER(SUBSTR(NORDEN, 1, 2)) NORDEN, NSEGCON, NSEGVER, IMINXL, IDEPXL, NCTRXL,
                  NVERXL, PTASAXL, IPMD, CFREPMD, CAPLIXL, PLIMGAS, PLIMINX, IDAA, ILAA, CTPRIMAXL, IPRIMAFIJAXL, IPRIMAESTIMADA,
                  CAPLICTASAXL, CTIPTASAXL, CTRAMOTASAXL, PCTPDXL, CFORPAGPDXL, PCTMINXL, PCTPB, NANYOSLOSS, CLOSSCORRIDOR, CCAPPEDRATIO,
                  CREPOS, IBONOREC, IMPAVISO, IMPCONTADO, PCTCONTADO, PCTGASTOS, PTASAAJUSTE, ICAPCOASEG, PREEST, ICOSTOFIJO, PCOMISINTERM,
                  NARRASTRECONT, NULL PTRAMO, PPIPRIO /*Ojo leer este campo*/ --  -- RABQ - IAXIS-4611 Paramaetro faltante PPIPRIO 
      -- SELECT COUNT(*)
      -- SELECT *
       FROM mig_tramos_bs mcc
      WHERE 1 = 1
          ;
          --SELECT COUNT(*) FROM mig_tramos_bs s; --A cargar: 747651
     --
  BEGIN
    --
    -----------------------------------------
    --MIG_TRAMOS
    -----------------------------------------
    OPEN lc_mig_tramos;
    LOOP
      --
      FETCH lc_mig_tramos BULK COLLECT INTO l_reg_mig_mcc LIMIT 100000;  -- limit to 10k to avoid out of memory
      --
      dbms_output.put_line('mig_tramos - I - paso bullk');
      --
      --FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
      --DELETE FROM mig_tramos WHERE mig_pk = l_reg_mig_mcc(i).mig_pk;
      --
      BEGIN
        --
        FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
        INSERT INTO mig_tramos VALUES l_reg_mig_mcc(i);
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
          p_control_error(g_user,'06_mig_tramos','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
          --
        END LOOP;
        --
      END;
      --
      dbms_output.put_line('mig_tramos - F - paso bullk');
      --
      COMMIT;
      --
      EXIT WHEN lc_mig_tramos%NOTFOUND;
       --
     END LOOP;
     --
     gcant_a_cargar   := lc_mig_tramos%ROWCOUNT;
     --
     SELECT COUNT(*) INTO gcant_a_cargar_bs FROM mig_tramos_bs;
     SELECT COUNT(*) INTO gcant_cargada FROM mig_tramos;
     --
     CLOSE lc_mig_tramos;
     --
   END p_carga_tramos;
   --
   /***************************************************************************
      PROCEDURE p_carga_cuadroces
      Procedimiento que inserta los registros grabados en MIG_CUADROCES_BS, en la tabla
      MIG_CUADROCES de iAXIS.
   ***************************************************************************/
   PROCEDURE p_carga_cuadroces
   IS
     --
     TYPE t_mig_cuadroces IS TABLE OF mig_cuadroces%ROWTYPE;
     l_reg_mig_mcc t_mig_cuadroces;
     --
      CURSOR lc_mig_cuadroces IS
     SELECT 17418 ncarga,1 CESTMIG,  a.MIG_PK, a.MIG_FK, a.MIG_FK2, a.NVERSIO, 0 SCONTRA, a.CTRAMO, a.CCOMREA, a.PCESION,
            a.NPLENOS, a.ICESFIJ, a.ICOMFIJ, a.ISCONTA, a.PRESERV, a.PINTRES, a.ILIACDE, a.PPAGOSL, a.CCORRED, a.CINTRES, a.CINTREF, a.CRESREF,
            a.IRESERV, a.PTASAJ, a.FULTLIQ, a.IAGREGA, a.IMAXAGR, a.CTIPCOMIS, a.PCTCOMIS, a.CTRAMOCOMISION, a.CFRERES, a.pctgastos
       --select count(*)
       --SELECT *
       FROM mig_cuadroces_bs a
      WHERE 1 = 1
          --AND p.idperson <> 0
          --AND s.mig_pk = '131050100DL0200681'
          ;
          --SELECT count(*) FROM mig_cuadroces_bs s WHERE s.mig_pk = '131050100DL0200681';
     --
  BEGIN
    --
    -----------------------------------------
    --CUADROCES
    -----------------------------------------
    OPEN lc_mig_cuadroces;
    LOOP
      --
      FETCH lc_mig_cuadroces BULK COLLECT INTO l_reg_mig_mcc LIMIT 100000;  -- limit to 10k to avoid out of memory
      --
      dbms_output.put_line('mig_cuadroces - I - paso bullk');
      --
      --FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
      --DELETE FROM mig_cuadroces WHERE mig_pk = l_reg_mig_mcc(i).mig_pk;
      --
      BEGIN
        --
        FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
        INSERT INTO mig_cuadroces VALUES l_reg_mig_mcc(i);
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
          p_control_error(g_user,'10_mig_cuadroces','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
          --
        END LOOP;
        --
      END;
      --
      dbms_output.put_line('mig_cuadroces - F - paso bullk');
      --
      COMMIT;
      --
      EXIT WHEN lc_mig_cuadroces%NOTFOUND;
       --
     END LOOP;
     --
     gcant_a_cargar   := lc_mig_cuadroces%ROWCOUNT;
     --
     SELECT COUNT(*) INTO gcant_a_cargar_bs FROM mig_cuadroces_bs;
     SELECT COUNT(*) INTO gcant_cargada FROM mig_cuadroces;
     --
     CLOSE lc_mig_cuadroces;
     --
   END p_carga_cuadroces;
   --
   /***************************************************************************
      PROCEDURE p_carga_clausulas_reas
      Procedimiento que inserta los registros grabados en MIG_CLAUSULAS_REAS_BS, en la tabla
      MIG_CLAUSULAS_REAS de iAXIS.
   ***************************************************************************/
   PROCEDURE p_carga_clausulas_reas
   IS
     --
     TYPE t_mig_clausulas_reas IS TABLE OF mig_clausulas_reas%ROWTYPE;
     l_reg_mig_mcc t_mig_clausulas_reas;
     --
      CURSOR lc_mig_clausulas_reas IS
       SELECT 17467 ncarga,1 CESTMIG, a.mig_pk, a.ccodigo, a.tdescripcion
            --SELECT COUNT(*)
          FROM mig_clausulas_reas_bs a
          ;
          --SELECT count(*) FROM mig_clausulas_reas_bs s WHERE s.mig_pk = '131050100DL0200681';
     --
  BEGIN
    --
    dbms_output.put_line('mig_clausulas_reas - I - paso bullk');
    -----------------------------------------
    --MIG_CLAUSULAS_REAS
    -----------------------------------------
    OPEN lc_mig_clausulas_reas;
    LOOP
      --
      FETCH lc_mig_clausulas_reas BULK COLLECT INTO l_reg_mig_mcc LIMIT 100000;  -- limit to 10k to avoid out of memory
      --
      FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
      DELETE FROM mig_clausulas_reas WHERE mig_pk = l_reg_mig_mcc(i).mig_pk;
      --
      BEGIN
        --
        FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
        INSERT INTO mig_clausulas_reas VALUES l_reg_mig_mcc(i);
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
          p_control_error(g_user,'13_mig_clausulas_reas','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
          --
        END LOOP;
        --
      END;
      --
      dbms_output.put_line('mig_clausulas_reas - F - paso bullk');
      --
      COMMIT;
      --
      EXIT WHEN lc_mig_clausulas_reas%NOTFOUND;
       --
     END LOOP;
     --
     gcant_a_cargar   := lc_mig_clausulas_reas%ROWCOUNT;
     --
     SELECT COUNT(*) INTO gcant_a_cargar_bs FROM mig_clausulas_reas_bs;
     SELECT COUNT(*) INTO gcant_cargada FROM mig_clausulas_reas;
     --
     CLOSE lc_mig_clausulas_reas;
     --
   END p_carga_clausulas_reas;
   --
   /***************************************************************************
      PROCEDURE p_carga_ctatecnica
      Procedimiento que inserta los registros grabados en MIG_CTATECNICA_BS, en la tabla
      MIG_CTATECNICA de iAXIS.
   ***************************************************************************/
   PROCEDURE p_carga_ctatecnica
   IS
     --
     TYPE t_mig_ctatecnica IS TABLE OF mig_ctatecnica%ROWTYPE;
     l_reg_mig_mcc t_mig_ctatecnica;
     --
     CURSOR lc_mig_ctatecnica IS
     SELECT 17468 NCARGA, 1 CESTMIG, a.MIG_PK,  a.MIG_FK, a.MIG_FK2, a.NVERSION,  a.SCONTRA,  a.TRAMO,  a.NNUMLIN,  a.FMOVIMI,  a.FEFECTO,  a.CCONCEP,
       a.CDEDHAB, a.IIMPORT,  a.CESTADO,  a.IIMPORT_MONCON, a.FCAMBIO,  a.CTIPMOV,  a.SPRODUC,  a.NPOLIZA,  a.NSINIESTRO, a.TDESCRI,  a.TDOCUME,
       a.FLIQUID, a.CEVENTO,  a.FCONTAB,  a.SIDEPAG,  a.CUSUCRE,  a.FCREAC, a.CRAMO,  a.CCORRED
       FROM mig_ctatecnica_bs a
      WHERE 1 = 1;
          --SELECT count(*) FROM mig_ctatecnica_bs s WHERE s.mig_pk = '131050100DL0200681';
     --
  BEGIN
    --
    -----------------------------------------
    --MIG_CTATECNICA
    -----------------------------------------
    OPEN lc_mig_ctatecnica;
    LOOP
      --
      FETCH lc_mig_ctatecnica BULK COLLECT INTO l_reg_mig_mcc LIMIT 10000;  -- limit to 10k to avoid out of memory
      --
      FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
      DELETE FROM mig_ctatecnica WHERE mig_pk = l_reg_mig_mcc(i).mig_pk;
      --
      BEGIN
        --
        FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
        INSERT INTO mig_ctatecnica VALUES l_reg_mig_mcc(i);
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
          p_control_error(g_user,'16_mig_ctatecnica','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
          --
        END LOOP;
        --
      END;
      --
      dbms_output.put_line('mig_ctatecnica - F - paso bullk');
      --
      COMMIT;
      --
      EXIT WHEN lc_mig_ctatecnica%NOTFOUND;
       --
     END LOOP;
     --
     --
     gcant_a_cargar   := lc_mig_ctatecnica%ROWCOUNT;
     --
     SELECT COUNT(*) INTO gcant_a_cargar_bs FROM mig_ctatecnica_bs;
     SELECT COUNT(*) INTO gcant_cargada FROM mig_ctatecnica;
     --
     CLOSE lc_mig_ctatecnica;
     --
   END p_carga_ctatecnica;
   --
   /***************************************************************************
      PROCEDURE p_carga_cesionesrea
      Procedimiento que inserta los registros grabados en MIG_CESIONESREA_BS, en la tabla
      MIG_CESIONESREA de iAXIS.
   ***************************************************************************/
   PROCEDURE p_carga_cesionesrea
   IS
     --
     TYPE t_mig_cesionesrea IS TABLE OF mig_cesionesrea%ROWTYPE;
     l_reg_mig_mcc t_mig_cesionesrea;
     --
      CURSOR lc_mig_cesionesrea IS
     SELECT 17469 NCARGA, 1 CESTMIG, a.MIG_PK, NVL(a.SCESREA, 0) SCESREA, a.NCESION, a.ICESION, a.ICAPCES, NVL(s.sseguro, 0)MIG_FKSEG,
          a.NVERSIO, a.SCONTRA, /*Ojo estos datos los deben actualizar con la data cargada de Contratos*/
          a.CTRAMO, a.SFACULT, a.NRIESGO, a.CGARANT, NVL(NULL, 0) MIF_FKSINI, a.FEFECTO, a.FVENCIM, a.FCONTAB, a.PCESION, a.CGENERA,
          a.FGENERA, a.FREGULA, a.FANULAC, a.NMOVIMI, a.IPRITARREA, a.IDTOSEL, a.PSOBREPRIMA, a.CDETCES, a.IPLENO, a.ICAPACI, a.NMOVIGEN,
          a.CTRAMPA, NULL CTIPOMOV, NULL CCUTOFF, /*a.CTIPOMOV, a.CCUTOFF, ojo ubicar en fuente esta inf*/ a.mig_fk2
       FROM mig_cesionesrea_bs a, mig_contratos c, mig_seguros s
      WHERE 1 = 1
        AND a.mig_fkseg = s.mig_pk (+)
        AND a.mig_fk2 = c.mig_pk
      ORDER BY a.mig_pk
          ;
          --SELECT * FROM mig_cesionesrea s WHERE s.mig_pk = '131050100DL0200681';
     --
  BEGIN
    --
    -----------------------------------------
    --MIG_CESIONESREA
    -----------------------------------------
    OPEN lc_mig_cesionesrea;
    LOOP
      --
      FETCH lc_mig_cesionesrea BULK COLLECT INTO l_reg_mig_mcc LIMIT 100000;  -- limit to 10k to avoid out of memory
      --
      --FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
      --DELETE FROM mig_cesionesrea WHERE mig_pk = l_reg_mig_mcc(i).mig_pk;
      --
      BEGIN
        --
        FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
        INSERT INTO mig_cesionesrea VALUES l_reg_mig_mcc(i);
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
          p_control_error(g_user,'19_mig_cesionesrea','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
          --
        END LOOP;
        --
      END;
      --
      dbms_output.put_line('mig_cesionesrea - F - paso bullk');
      --
      COMMIT;
      --
      EXIT WHEN lc_mig_cesionesrea%NOTFOUND;
       --
     END LOOP;
     --
     gcant_a_cargar   := lc_mig_cesionesrea%ROWCOUNT;
     --
     SELECT COUNT(*) INTO gcant_a_cargar_bs FROM mig_cesionesrea_bs;
     SELECT COUNT(*) INTO gcant_cargada FROM mig_cesionesrea;
     --
     CLOSE lc_mig_cesionesrea;
     --
   END p_carga_cesionesrea;
   --
   /***************************************************************************
      PROCEDURE p_carga_det_cesionesrea
      Procedimiento que inserta los registros grabados en mig_det_cesionesrea_bs, en la tabla
      mig_det_cesionesrea de iAXIS.
   ***************************************************************************/
   PROCEDURE p_carga_det_cesionesrea
   IS
     --
     TYPE t_mig_det_cesionesrea IS TABLE OF mig_det_cesionesrea%ROWTYPE;
     l_reg_mig_mcc t_mig_det_cesionesrea;
     --
      CURSOR lc_mig_det_cesionesrea IS
     SELECT 17470 NCARGA, 1 CESTMIG, a.MIG_PK, a.MIG_FK, c.scesrea SCESREA, NVL(a.SDETCESREA, 0) SDETCESREA, nvl(a.SSEGURO, 0) sseguro, a.NMOVIMI,
            a.PTRAMO, a.CGARANT, a.ICESION, a.ICAPCES, a.PCESION, a.PSOBREPRIMA, a.IEXTRAP, a.IEXTREA, a.IPRITARREA, a.ITARIFREA, a.ICOMEXT,
            a.CCOMPANI, a.FALTA, a.CUSUALT, a.FMODIFI, a.CUSUMOD, null CDEPURA, null FEFECDEMA, null NMOVDEP, null SPERSON
    --select count(*) --2.761.261
       FROM mig_det_cesionesrea_bs a, mig_cesionesrea c
      WHERE 1 = 1
        and a.MIG_FK = C.MIG_PK
        --and a.mig_pk = '13101A093252610CPT1999001010040444444138'
      ORDER BY a.mig_pk
          --AND s.mig_pk = '131050100DL0200681'
          ;
          --SELECT * FROM mig_det_cesionesrea_bs s WHERE s.mig_pk = '131050100DL0200681';
     --
  BEGIN
    --
    -----------------------------------------
    --MIG_DET_CESIONESREA
    -----------------------------------------
    DELETE control_error s WHERE TRUNC(s.fecha) = TRUNC(SYSDATE) AND s.donde = '22_mig_det_cesionesrea';
    --
    OPEN lc_mig_det_cesionesrea;
    LOOP
      --
      FETCH lc_mig_det_cesionesrea BULK COLLECT INTO l_reg_mig_mcc LIMIT 100000;  -- limit to 10k to avoid out of memory
      --
      dbms_output.put_line('mig_det_cesionesrea - I - paso bullk');
      --
      FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
      DELETE FROM mig_det_cesionesrea WHERE mig_pk = l_reg_mig_mcc(i).mig_pk;
      --
      BEGIN
        --
        FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
        INSERT INTO mig_det_cesionesrea VALUES l_reg_mig_mcc(i);
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
          p_control_error(g_user,'22_mig_det_cesionesrea','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
          --
        END LOOP;
        --
      END;
      --
      dbms_output.put_line('mig_det_cesionesrea - F - paso bullk');
      --
      COMMIT;
      --
      EXIT WHEN lc_mig_det_cesionesrea%NOTFOUND;
       --
     END LOOP;
     --
     gcant_a_cargar   := lc_mig_det_cesionesrea%ROWCOUNT;
     --
     SELECT COUNT(*) INTO gcant_a_cargar_bs FROM mig_det_cesionesrea_bs;
     SELECT COUNT(*) INTO gcant_cargada FROM mig_det_cesionesrea;
     CLOSE lc_mig_det_cesionesrea;
     --
   END p_carga_det_cesionesrea;
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
      PROCEDURE p_carga_cuafacul
      Procedimiento que inserta los registros grabados en MIG_CUAFACUL_BS, en la tabla
      MIG_CUAFACUL de iAXIS.
   ***************************************************************************/
   PROCEDURE p_carga_cuafacul
   IS
     --
     TYPE t_mig_cuafacul IS TABLE OF mig_cuafacul%ROWTYPE;
     l_reg_mig_mcc t_mig_cuafacul;
     --
      CURSOR lc_mig_cuafacul IS
     SELECT 17471 NCARGA, 1 CESTMIG, a.MIG_PK, a.MIG_FK, a.MIG_FK2, 0 SFACULT, a.CESTADO, a.FINICUF, a.CFREBOR, 0 SCONTRA,
            0 NVERSIO, 0 SSEGURO, a.CCALIF1, a.CCALIF2, a.SPLENO, a.NMOVIMI, a.SCUMULO, a.NRIESGO, a.FFINCUF, a.PLOCAL,
            a.FULTBOR, a.PFACCED, a.IFACCED, a.NCESION, a.CTIPFAC, a.PTASAXL, null CNOTACES, a.CGARANT
      --select count(*)
       FROM mig_cuafacul_bs a, mig_contratos c, mig_seguros s
      WHERE 1 = 1
        AND a.mig_fk  = c.mig_pk
        AND a.mig_fk2 = s.mig_pk
        AND s.sseguro <> 0
        AND c.scontra <> 0
      ORDER BY a.mig_pk
          ;
          --SELECT * FROM mig_cuafacul_conf s WHERE s.mig_pk = '131050100DL0200681';
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
    --MIG_CUAFACUL
    -----------------------------------------
    OPEN lc_mig_cuafacul;
    LOOP
      --
      FETCH lc_mig_cuafacul BULK COLLECT INTO l_reg_mig_mcc LIMIT 10000;  -- limit to 10k to avoid out of memory
      --
      dbms_output.put_line('agensegu - I - paso bullk');
      --
      dbms_output.put_line('...');
      --
      FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
      DELETE FROM mig_cuafacul WHERE mig_pk = l_reg_mig_mcc(i).mig_pk;
      --
      BEGIN
        --
        FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
        INSERT INTO mig_cuafacul VALUES l_reg_mig_mcc(i);
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
          p_control_error(g_user,'31_mig_cuafacul','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
          --
        END LOOP;
        --
      END;
      --
      dbms_output.put_line('mig_cuafacul - F - paso bullk');
      --
      COMMIT;
      --
      EXIT WHEN lc_mig_cuafacul%NOTFOUND;
       --
     END LOOP;
     --
     gcant_a_cargar   := lc_mig_cuafacul%ROWCOUNT;
     --
     SELECT COUNT(*) INTO gcant_a_cargar_bs FROM mig_cuafacul_bs;
     SELECT COUNT(*) INTO gcant_cargada FROM mig_cuafacul;
     CLOSE lc_mig_cuafacul;
     --
   END p_carga_cuafacul;
   --
   /***************************************************************************
      PROCEDURE p_carga_cuacesfac
      Procedimiento que inserta los registros grabados en MIG_CUACESFAC_BS, en la tabla
      MIG_CUACESFAC de iAXIS.
   ***************************************************************************/
   PROCEDURE p_carga_cuacesfac
   IS
     --
     TYPE t_mig_cuacesfac IS TABLE OF mig_cuacesfac%ROWTYPE;
     l_reg_mig_mcc t_mig_cuacesfac;
     --
      CURSOR lc_mig_cuacesfac IS
     SELECT 17472 NCARGA, 1 CESTMIG, a.MIG_PK, a.MIG_FK, a.MIG_FK2, 0 SFACULT, 0 CCOMPANI, a.CCOMREA,
            a.PCESION, a.ICESFIJ, a.ICOMFIJ, a.ISCONTA, a.PRESERV, a.PINTRES, a.PCOMISI, a.CINTRES, a.CCORRED,
            -- INICIO INFORCOL 26-01-2020 Reaseguro facultativo - ajuste para deposito en prima retenida
            a.CFRERES, a.CRESREA, a.CCONREC, a.FGARPRI, a.FGARDEP, a.PIMPINT, a.CTRAMOCOMISION, a.TIDFCOM, a.PRESREA
            -- FIN INFORCOL 26-01-2020 Reaseguro facultativo - ajuste para deposito en prima retenida
       FROM mig_cuacesfac_bs a, MIG_CUAFACUL c, MIG_COMPANIAS s
      WHERE 1 = 1
        AND a.mig_fk  = c.mig_pk
        AND a.mig_fk2 = s.mig_pk
        AND s.ccompani <> 0
        AND c.sfacult <> 0
      ORDER BY a.mig_pk
          ;
          --SELECT * FROM mig_cuacesfac_conf s WHERE s.mig_pk = '131050100DL0200681';
     --
  BEGIN
    --
    -----------------------------------------
    --mig_cuacesfac
    -----------------------------------------
    OPEN lc_mig_cuacesfac;
    LOOP
      --
      FETCH lc_mig_cuacesfac BULK COLLECT INTO l_reg_mig_mcc LIMIT 10000;  -- limit to 10k to avoid out of memory
      --
      dbms_output.put_line('mig_cuacesfac - I - paso bullk');
      --
      dbms_output.put_line('...');
      --
      --FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
      --DELETE FROM mig_cuacesfac WHERE mig_pk = l_reg_mig_mcc(i).mig_pk;
      --
      BEGIN
        --
        FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
        INSERT INTO mig_cuacesfac VALUES l_reg_mig_mcc(i);
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
          p_control_error(g_user,'34_mig_cuacesfac','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
          --
        END LOOP;
        --
      END;
      --
      dbms_output.put_line('mig_cuacesfac - F - paso bullk');
      --
      COMMIT;
      --
      EXIT WHEN lc_mig_cuacesfac%NOTFOUND;
       --
     END LOOP;
     --
     gcant_a_cargar   := lc_mig_cuacesfac%ROWCOUNT;
     --
     SELECT COUNT(*) INTO gcant_a_cargar_bs FROM mig_cuacesfac_bs;
     SELECT COUNT(*) INTO gcant_cargada FROM mig_cuacesfac;
     CLOSE lc_mig_cuacesfac;
     --
   END p_carga_cuacesfac;
   --
   /***************************************************************************
      PROCEDURE p_carga_eco_tipocambio
      Procedimiento que inserta los registros grabados en MIG_ECO_TIPOCAMBIO_BS, en la tabla
      MIG_ECO_TIPOCAMBIO de iAXIS.
   ***************************************************************************/
   PROCEDURE p_carga_eco_tipocambio
   IS
     --
     TYPE t_mig_eco_tipocambio IS TABLE OF mig_eco_tipocambio%ROWTYPE;
     l_reg_mig_mcc t_mig_eco_tipocambio;
     --
      CURSOR lc_mig_eco_tipocambio IS
      SELECT 17473 NCARGA,1 CESTMIG, a.CMONORI, a.CMONDES, a.FCAMBIO, a.ITASA, a.MIG_PK
      --select count(*)
      --select *
        FROM mig_eco_tipocambio /*_bs Descomentar*/ a
       WHERE 1 = 1
          ;
          --SELECT * FROM mig_eco_tipocambio_conf s WHERE s.mig_pk = '131050100DL0200681';
     --
  BEGIN
    --
    -----------------------------------------
    --MIG_ECO_TIPOCAMBIO
    -----------------------------------------
    OPEN lc_mig_eco_tipocambio;
    LOOP
      --
      FETCH lc_mig_eco_tipocambio BULK COLLECT INTO l_reg_mig_mcc LIMIT 100000;  -- limit to 10k to avoid out of memory
      --
      dbms_output.put_line('ecotipocambio - I - paso bullk');
      --
      dbms_output.put_line('...');
      --
      --FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
      --DELETE FROM mig_eco_tipocambio WHERE mig_pk = l_reg_mig_mcc(i).mig_pk;
      --
      BEGIN
        --
        FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
        INSERT INTO mig_eco_tipocambio VALUES l_reg_mig_mcc(i);
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
          p_control_error(g_user,'37_mig_eco_tipocambio','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
          --
        END LOOP;
        --
      END;
      --
      dbms_output.put_line('ecotipocambio - F - paso bullk');
      --
      COMMIT;
      --
      EXIT WHEN lc_mig_eco_tipocambio%NOTFOUND;
       --
     END LOOP;
     --
     gcant_a_cargar   := lc_mig_eco_tipocambio%ROWCOUNT;
     --
     SELECT COUNT(*) INTO gcant_a_cargar_bs FROM mig_eco_tipocambio; --Ajustar a _BS
     SELECT COUNT(*) INTO gcant_cargada FROM mig_eco_tipocambio;
     CLOSE lc_mig_eco_tipocambio;
     --
   END p_carga_eco_tipocambio;
   --
   /***************************************************************************
      PROCEDURE p_carga_coacuadro
      Procedimiento que inserta los registros grabados en MIG_COACUADRO_BS, en la tabla
      MIG_COACUADRO de iAXIS.
   ****************************************************************************/
   PROCEDURE p_carga_coacuadro
   IS
     --
     TYPE t_mig_coacuadro IS TABLE OF mig_coacuadro%ROWTYPE;
     l_reg_mig_mcc t_mig_coacuadro;
     --
      CURSOR lc_mig_coacuadro IS
     SELECT 17481 ncarga,1 CESTMIG, a.MIG_PK, a.MIG_FK, a.NCUACOA, a.finicoa, a.ffincoa, a.ploccoa, a.fcuacoa, c.ccompani, a.npoliza, 0 sseguro
     --select count(*)
     --select *
       FROM mig_coacuadro_bs a, mig_seguros s, mig_companias c
      WHERE 1 = 1
        and a.MIG_FK = S.MIG_PK
        AND a.mig_fk2 = c.mig_pk (+)
          ;
          --SELECT * FROM mig_coacuadro_conf s WHERE s.mig_pk = '131050100DL0200681';
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
    --COACUADRO
    -----------------------------------------
    OPEN lc_mig_coacuadro;
    LOOP
      --
      FETCH lc_mig_coacuadro BULK COLLECT INTO l_reg_mig_mcc LIMIT 100000;  -- limit to 10k to avoid out of memory
      --
      dbms_output.put_line('coacuadro - I - paso bullk');
      --
      dbms_output.put_line('...');
      --
      --FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
      --DELETE FROM mig_coacuadro WHERE mig_pk = l_reg_mig_mcc(i).mig_pk;
      --
      BEGIN
        --
        FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
        INSERT INTO mig_coacuadro VALUES l_reg_mig_mcc(i);
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
          p_control_error(g_user,'40_mig_coacuadro','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
          --
        END LOOP;
        --
      END;
      --
      dbms_output.put_line('coacuadro - F - paso bullk');
      --
      EXIT WHEN lc_mig_coacuadro%NOTFOUND;
       --
     END LOOP;
     --
     gcant_a_cargar   := lc_mig_coacuadro%ROWCOUNT;
     --
     SELECT COUNT(*) INTO gcant_a_cargar_bs FROM mig_coacuadro_bs;
     SELECT COUNT(*) INTO gcant_cargada FROM mig_coacuadro;
     CLOSE lc_mig_coacuadro;
     --
   END p_carga_coacuadro;
   --
   /***************************************************************************
      PROCEDURE p_carga_coacedido
      Procedimiento que inserta los registros grabados en MIG_COACEDIDO_BS, en la tabla
      MIG_COACEDIDO de iAXIS.
   ****************************************************************************/
   PROCEDURE p_carga_coacedido
   IS
     --
     TYPE t_mig_coacedido IS TABLE OF mig_coacedido%ROWTYPE;
     l_reg_mig_mcc t_mig_coacedido;
     --
      CURSOR lc_mig_coacedido IS
       SELECT 17482 ncarga,1 CESTMIG, a.MIG_PK, a.MIG_FK, a.NCUACOA, c.ccompani ccompan, a.PCESCOA, a.PCOMCOA, a.PCOMCON, a.PCOMGAS, a.PCESION
       --select count(*)
       --select *
         FROM mig_coacedido_bs a, mig_seguros s, mig_companias c
        WHERE 1 = 1
          AND a.mig_fk = s.mig_pk
          and a.MIG_FK2 = C.MIG_PK
          and c.ccompani <> 0
          ;
          --SELECT * FROM mig_coacedido_conf s WHERE s.mig_pk = '131050100DL0200681';
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
    --MIG_COACEDIDO
    -----------------------------------------
    OPEN lc_mig_coacedido;
    LOOP
      --
      FETCH lc_mig_coacedido BULK COLLECT INTO l_reg_mig_mcc LIMIT 100000;  -- limit to 10k to avoid out of memory
      --
      dbms_output.put_line('mig_coacedido - I - paso bullk');
      --
      dbms_output.put_line('...');
      --
      FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
      DELETE FROM mig_coacedido WHERE mig_pk = l_reg_mig_mcc(i).mig_pk;
      --
      BEGIN
        --
        FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
        INSERT INTO mig_coacedido VALUES l_reg_mig_mcc(i);
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
          p_control_error(g_user,'47_mig_coacedido','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
          --
        END LOOP;
        --
      END;
      --
      dbms_output.put_line('mig_coacedido - F - paso bullk');
      --
      EXIT WHEN lc_mig_coacedido%NOTFOUND;
       --
     END LOOP;
     --
     gcant_a_cargar   := lc_mig_coacedido%ROWCOUNT;
     --
     SELECT COUNT(*) INTO gcant_a_cargar_bs FROM mig_coacedido_bs;
     SELECT COUNT(*) INTO gcant_cargada FROM mig_coacedido;
     CLOSE lc_mig_coacedido;
     --
   END p_carga_coacedido;
   --
   /***************************************************************************
      PROCEDURE p_carga_ctacoaseguro
      Procedimiento que inserta los registros grabados en MIG_AGE_CORRETAJE_BS, en la tabla
      MIG_AGE_CORRETAJE de iAXIS.
   ****************************************************************************/
   PROCEDURE p_carga_ctacoaseguro
   IS
     --
     TYPE t_mig_ctacoaseguro IS TABLE OF mig_ctacoaseguro%ROWTYPE;
     l_reg_mig_mcc t_mig_ctacoaseguro;
     --
      CURSOR lc_mig_ctacoaseguro IS
     SELECT 17483 ncarga,1 CESTMIG, a.MIG_PK, a.SMOVCOA, a.MIG_FK2, a.CIMPORT, a.CTIPCOA, a.CMOVIMI, a.IMOVIMI, a.FMOVIMI,
            a.FCONTAB, a.CDEBHAB, a.FLIQCIA, a.PCESCOA, a.SIDEPAG, 0 NRECIBO, 0 SMOVREC, a.CEMPRES, 0 SSEGURO, a.SPRODUC, a.CESTADO,
            a.CTIPMOV, a.TDESCRI, a.TDOCUME, a.IMOVIMI_MONCON, a.FCAMBIO, a.NSINIES, a.CCOMPAPR, a.CMONEDA, a.SPAGCOA, a.CTIPGAS,
            a.FCIERRE, a.NTRAMIT, a.NMOVRES, a.CGARANT, a.MIG_FK3, a.MIG_FK4, a.MIG_FK5
     --select count(*)
     --select *
       FROM mig_ctacoaseguro_bs a, mig_companias c, mig_seguros s, mig_recibos r, mig_siniestros sn
      WHERE 1 = 1
        AND a.mig_fk2 = c.mig_pk
        AND a.mig_fk3 = s.mig_pk (+)
        AND a.mig_fk4 = r.mig_pk (+)
        AND a.mig_fk5 = sn.mig_pk (+);
          --SELECT * FROM mig_ctacoaseguro_conf s WHERE s.mig_pk = '131050100DL0200681';
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
    OPEN lc_mig_ctacoaseguro;
    LOOP
      --
      FETCH lc_mig_ctacoaseguro BULK COLLECT INTO l_reg_mig_mcc LIMIT 100000;  -- limit to 10k to avoid out of memory
      --
      dbms_output.put_line('age_corretaje - I - paso bullk');
      --
      dbms_output.put_line('...');
      --
      --FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
      --DELETE FROM mig_ctacoaseguro WHERE mig_pk = l_reg_mig_mcc(i).mig_pk;
      --
      BEGIN
        --
        FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
        INSERT INTO mig_ctacoaseguro VALUES l_reg_mig_mcc(i);
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
          p_control_error(g_user,'50_mig_ctacoaseguro','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
          --
        END LOOP;
        --
      END;
      --
      dbms_output.put_line('age_corretaje - F - paso bullk');
      --
      EXIT WHEN lc_mig_ctacoaseguro%NOTFOUND;
       --
     END LOOP;
     --
     gcant_a_cargar   := lc_mig_ctacoaseguro%ROWCOUNT;
     --
     SELECT COUNT(*) INTO gcant_a_cargar_bs FROM mig_ctacoaseguro_bs;
     SELECT COUNT(*) INTO gcant_cargada FROM mig_ctacoaseguro;
     CLOSE lc_mig_ctacoaseguro;
     --
   END p_carga_ctacoaseguro;
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
      PROCEDURE p_carga_reaseg
      Procedimiento que ejecuta el cargue de un fichero particular
         param in  ptab_des:     DescripciÃ³n de la tabla.
   ***************************************************************************/
   PROCEDURE p_carga_reaseg(ptab_des VARCHAR2)
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
     IF ptab_des = 'MIG_COMPANIAS'
     THEN
       --
       p_carga_companias;
      --
     ELSIF ptab_des = 'MIG_CODICONTRATOS'
     THEN
       --
       p_carga_codicontratos;
       --
     ELSIF ptab_des = 'MIG_AGR_CONTRATOS'
     THEN
       --
       p_carga_agr_contratos;
       --
     ELSIF ptab_des = 'MIG_CONTRATOS'
     THEN
       --
       p_carga_contratos;
       --
     ELSIF ptab_des = 'MIG_TRAMOS'
     THEN
       --
       p_carga_tramos;
       --
     ELSIF ptab_des = 'MIG_CUADROCES'
     THEN
       --
       p_carga_cuadroces;
       --
     ELSIF ptab_des = 'MIG_CLAUSULAS_REAS'
     THEN
       --
       p_carga_clausulas_reas;
       --
     ELSIF ptab_des = 'MIG_CTATECNICA'
     THEN
       --
       p_carga_ctatecnica;
       --
     ELSIF ptab_des = 'MIG_CESIONESREA'
     THEN
       --
       p_carga_cesionesrea;
       --
     ELSIF ptab_des = 'MIG_DET_CESIONESREA'
     THEN
       --
       p_carga_det_cesionesrea;
       --
     ELSIF ptab_des = 'MIG_CTASEGURO'
     THEN
       --
       --p_carga_ctaseguro;
       dbms_output.put_line('por definir . . . p_carga_ctaseguro '||g_user);
       --
     ELSIF ptab_des = 'MIG_CUAFACUL'
     THEN
       --
       p_carga_cuafacul;
       --
     ELSIF ptab_des = 'MIG_CUACESFAC'
     THEN
       --
       p_carga_cuacesfac;
       --
     ELSIF ptab_des = 'MIG_ECO_TIPOCAMBIO'
     THEN
       --
       p_carga_eco_tipocambio;
       --
     ELSIF ptab_des = 'MIG_COACUADRO'
     THEN
       --
       --p_carga_coacuadro;
       dbms_output.put_line('por definir . . . p_carga_coacuadro '||g_user);
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
     v_texto   := gcant_a_cargar_bs || '/' || gcant_cargada || ' reg cargados de ' || gcant_a_cargar || '. Tiempo de EjecuciÃ³n: '|| l_time || ' seg';
     p_control_error(g_user, ptab_des, v_texto);
     dbms_output.put_line(v_texto);
     --
   END p_carga_reaseg;
   --
END pac_carga_reaseguros_conf;

/