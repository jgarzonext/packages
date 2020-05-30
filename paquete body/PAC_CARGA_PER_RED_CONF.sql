CREATE OR REPLACE PACKAGE BODY "PAC_CARGA_PER_RED_CONF" IS
   /***************************************************************************
      NOMBRE:       pac_carga_per_red_conf
      PROPÓSITO:    Proceso de traspaso de informacion de las tablas base _BS
                    a las distintas tablas MIG_ de AXIS (Capítulo Personas)
      REVISIONES:
      Ver        Fecha       Autor       Descripción
      ---------  ----------  ----------  --------------------------------------
       1.0        11/10/2017  HAG         Creacion package de carga
       1.1        26/01/2018  HAG         Creación tablas base _BS
       1.2        14/02/2019  AABC        TC464 adicion al cursor para tablas mig_personas
       1.3        19/02/2019  CJMR        TCS-344: Nueva funcionalidad de marcas
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
   gcant_a_cargar NUMBER := 0;
   gcant_cargada  NUMBER := 0;
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
   /**************************************************************************
      PROCEDURE p_borra_personas
      Procedimiento que borra los registros grabados en MIG_PERSONAS y relacionados en MIG
   ***************************************************************************/
   PROCEDURE p_borra_personas(p_all NUMBER)
   IS
   BEGIN
     --
     IF p_all = 1
     THEN
       --
       DELETE FROM mig_personas;
       DELETE FROM mig_direcciones;
       DELETE FROM mig_personas_rel;
       DELETE FROM mig_agentes;
       DELETE FROM mig_per_agr_marcas;
       DELETE FROM mig_regimenfiscal;
       DELETE FROM mig_parpersonas;
       --
     END IF;
     --
   END p_borra_personas;
/***************************************************************************
      PROCEDURE p_carga_personas
      Procedimiento que inserta los registros grabados en MIG_PERSONAS_CL1, en la tabla
      MIG_PERSONAS de iAXIS.
   ***************************************************************************/
   PROCEDURE p_carga_personas
   IS
     --
     TYPE t_mig_personas IS TABLE OF mig_personas%ROWTYPE;
     l_reg_mig_mcc t_mig_personas;
     --
      CURSOR lc_mig_personas IS
       SELECT 17413 NCARGA, 1 CESTMIG, a.MIG_PK,  0 IDPERSON,  a.SNIP,  a.CTIPIDE,  a.NNUMIDE,  a.CESTPER,  a.CPERTIP,  a.FULTMOD,  a.SWPUBLI,
              DECODE(LENGTH(CSEXPER), 1, CSEXPER, 0) CSEXPER,
              a.FNACIMI,  a.CAGENTE,  a.TAPELLI1,  a.TAPELLI2,  a.TNOMBRE,  a.CESTCIV,  a.CPAIS,  a.CPROFES,  a.CNACIO,  NULL CTIPDIR,
              NULL CTIPVIA,  NULL TNOMVIA,  NULL NNUMVIA,  NULL TCOMPLE,  NULL CPOSTAL,  NULL CPOBLAC,  NULL CPROVIN,  NULL CTIPDIR2,
              NULL CTIPVIA2,  NULL TNOMVIA2,  NULL NNUMVIA2,  NULL TCOMPLE2,  NULL CPOSTAL2,  NULL CPOBLAC2,  NULL CPROVIN2,  NULL TNUMTEL,
              NULL TNUMFAX,  NULL TNUMMOV,  NULL TEMAIL,  a.CTIPBAN,  a.CBANCAR,  a.CIDIOMA,  NULL CTIPIDE2,  NULL NNUMIDE2,
              NULL FJUBILA,  a.TNOMBRE2,  a.TDIGITOIDE,  NULL PROCESO,  NULL FVENCIM,  NULL COCUPACION,  NULL FANTIGUEDAD,  a.FDEFUNC
              , NULL NNUMIDE_DEUD, NULL NNUMIDE_ACRE  -- TC464 AABC 14/02/2019 Se adicionan los campos adicionados en la tabla de mig_personas V.1.2.
         FROM mig_personas_bs a
         WHERE 1 = 1
      ORDER BY a.CTIPIDE, a.NNUMIDE
          ;
     --
  BEGIN
    --
    -----------------------------------------
    --PERSONAS
    -----------------------------------------
    OPEN lc_mig_personas;
    LOOP
      --
      FETCH lc_mig_personas BULK COLLECT INTO l_reg_mig_mcc LIMIT 10000;
      --
      dbms_output.put_line('Mig_personas -I - paso bullk');
      --
      dbms_output.put_line('...');
      --
      FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
      DELETE FROM mig_personas WHERE mig_pk = l_reg_mig_mcc(i).mig_pk;
      --
      BEGIN
        --
        FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
        INSERT INTO mig_personas VALUES l_reg_mig_mcc(i);
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
          p_control_error(g_user,'01_mig_personas','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
          --
        END LOOP;
        --
      END;
      --
      dbms_output.put_line('Mig_personas - F - paso bullk');
      --
      COMMIT;
      --
      EXIT WHEN lc_mig_personas%NOTFOUND;
       --
     END LOOP;
     --
     gcant_a_cargar   := lc_mig_personas%ROWCOUNT;
     --
     SELECT COUNT(*)
       INTO gcant_cargada
       FROM mig_personas;
     --
     CLOSE lc_mig_personas;
     --
   END p_carga_personas;
   --
   /***************************************************************************
      PROCEDURE p_carga_direcciones
      Procedimiento que inserta los registros grabados en MIG_DIRECCIONES_CL1, en la tabla
      MIG_DIRECCIONES de iAXIS.
   ***************************************************************************/
   PROCEDURE p_carga_direcciones
   IS
      --
     v_limit_records   NUMBER := 100000; -- limit to 10k to avoid out of memory
     --
     TYPE t_mig_direcciones IS TABLE OF mig_direcciones%ROWTYPE;
     l_reg_mig_mcc t_mig_direcciones;
     --
      CURSOR lc_mig_direcciones IS
       SELECT 17413 NCARGA, 1 CESTMIG, a.MIG_PK,  a.MIG_FK, a.SPERSON,  a.CAGENTE,  a.CDOMICI,  a.CPOSTAL,  a.CPROVIN,  a.CPOBLAC,
              NULL CSIGLAS, a.TNOMVIA,  NULL NNUMVIA, NULL TCOMPLE, a.CTIPDIR,  a.CVIAVP, a.CLITVP, a.CBISVP, a.CORVP,  a.NVIAADCO, a.CLITCO,
              a.CORCO,  a.NPLACACO, a.COR2CO, a.CDET1IA,  a.TNUM1IA,  a.CDET2IA,  a.TNUM2IA,  a.CDET3IA,  a.TNUM3IA,  a.LOCALIDAD,
              NULL PROCESO, a.TNUMTEL,  a.TNUMFAX,  a.TNUMMOV,  a.TEMAIL, a.TALIAS
         --SELECT COUNT(*)
         FROM mig_direcciones_bs a, mig_personas p
         WHERE 1 = 1 --37.297
           AND a.mig_fk = p.mig_pk
         --AND a.mig_fk NOT IN (SELECT p.mig_pk FROM mig_personas p WHERE p.ncarga = 17413 AND p.ctipide = 0 AND p.idperson = 0)
         --AND IN (SELECT p.mig_pk FROM mig_personas p WHERE p.ncarga = 17413 AND p.mig_pk IN (SELECT mig_fk FROM mig_seguros WHERE sseguro = 0);
         --AND a.mig_fk IN (SELECT mig_fk FROM mig_seguros WHERE sseguro = 0)
         --AND a.mig_pk = 'A00005041'
        --select * from mig_direcciones_bs
      ORDER BY a.MIG_PK
          ;
     --
  BEGIN
    --
    -----------------------------------------
    --DIRECCIONES
    -----------------------------------------
    OPEN lc_mig_direcciones;
    LOOP
      --
      FETCH lc_mig_direcciones BULK COLLECT INTO l_reg_mig_mcc LIMIT v_limit_records;
      --
      dbms_output.put_line('mig_direcciones - I - paso bullk');
      --
      FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
      DELETE FROM mig_direcciones WHERE mig_pk = l_reg_mig_mcc(i).mig_pk;
      --
      BEGIN
        --
        FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
        INSERT INTO mig_direcciones VALUES l_reg_mig_mcc(i);
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
          p_control_error(g_user,'02_mig_direcciones','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
          --
        END LOOP;
        --
      END;
      --
      dbms_output.put_line('mig_direcciones - F - paso bullk');
      --
      COMMIT;
      --
      EXIT WHEN lc_mig_direcciones%NOTFOUND;
       --
     END LOOP;
     --
     gcant_a_cargar   := lc_mig_direcciones%ROWCOUNT;
     --
     SELECT COUNT(*)
       INTO gcant_cargada
       FROM mig_direcciones;
     --
     CLOSE lc_mig_direcciones;
     --
   END p_carga_direcciones;
   --
   /***************************************************************************
      PROCEDURE p_carga_personas_rel
      Procedimiento que inserta los registros grabados en PERSONAS_REL_CL1, en la tabla
      MIG_PERSONAS_REL de iAXIS.
   ***************************************************************************/
   PROCEDURE p_carga_personas_rel
   IS
     --
     TYPE t_mig_personas_rel IS TABLE OF mig_personas_rel%ROWTYPE;
     l_reg_mig_mcc t_mig_personas_rel;
     --
      CURSOR lc_mig_personas_rel IS--EZ SE AGREGAN LOS NUEVOS CAMPOS DE MIGRACION
       --SELECT 17413 NCARGA, 1 CESTMIG, a.MIG_PK, a.MIG_FK, a.FKREL, a.CTIPREL, a.PPARTICIPACION, a.ISLIDER
     SELECT 17413 NCARGA, 1 CESTMIG, a.MIG_PK, a.MIG_FK, a.FKREL, a.CTIPREL, a.PPARTICIPACION, a.ISLIDER, a.CAGRUPA, a.FAGRUPA
         FROM mig_personas_rel_bs a
         WHERE 1 = 1 --38.597 tipo = 0, se pasarían 37.207
         --AND a.mig_fk IN (SELECT p.mig_pk FROM mig_personas p WHERE p.ncarga = 17413 AND p.ctipide = 0 AND p.idperson = 0)
        --select * from mig_personas_rel_bs
      ORDER BY a.mig_pk
          ;
     --
  BEGIN
    --
    -----------------------------------------
    --PERSONAS_REL
    -----------------------------------------
    OPEN lc_mig_personas_rel;
    LOOP
      --
      FETCH lc_mig_personas_rel BULK COLLECT INTO l_reg_mig_mcc LIMIT 100000;
      --
      dbms_output.put_line('PERSONAS_REL - I - paso bullk');
      --
      dbms_output.put_line('...');
      --
      --FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
      --DELETE FROM mig_personas_rel WHERE mig_pk = l_reg_mig_mcc(i).mig_pk;
      --
      BEGIN
        --
        FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
        INSERT INTO mig_personas_rel VALUES l_reg_mig_mcc(i);
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
          p_control_error(g_user,'03_mig_personas_rel','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
          --
        END LOOP;
        --
      END;
      --
      dbms_output.put_line('F - paso bullk');
      --
      COMMIT;
      --
      EXIT WHEN lc_mig_personas_rel%NOTFOUND;
       --
     END LOOP;
     --
     gcant_a_cargar   := lc_mig_personas_rel%ROWCOUNT;
     --
     SELECT COUNT(*)
       INTO gcant_cargada
       FROM mig_personas_rel;
     --
     CLOSE lc_mig_personas_rel;
     --
   END p_carga_personas_rel;
   --
   /***************************************************************************
      PROCEDURE p_carga_agentes
      Procedimiento que inserta los registros grabados en MIG_AGENTES_CL1, en la tabla
      MIG_AGENTES de iAXIS.
   ***************************************************************************/
   PROCEDURE p_carga_agentes
   IS
     --
     vncarga           mig_cargas.ncarga%TYPE := 17413;
     v_agente_pervisio NUMBER := 19000; -- agente vision personas por defecto si no viene informado
     vdummy            NUMBER;
     b_error           BOOLEAN;
     --
     BEGIN
      --
      SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
        INTO vdummy
        FROM dual;
      --
      b_error        := FALSE;
      --
     -----------------------------------------
     --PERSONAS
     -----------------------------------------
     --
     FOR l_per IN ( SELECT a.* --mpc.mig_pk, count(*)
                     FROM mig_personas_bs mpc, mig_agentes_bs a
                    WHERE 1 = 1
                      AND mpc.mig_pk = a.mig_fk
                      AND  (    ctipide  IS NOT NULL
                            AND cestper  IS NOT NULL
                            AND cpertip  IS NOT NULL
                            AND swpubli  IS NOT NULL
                            AND tapelli1 IS NOT NULL
                           )
                      /*AND mpc.mig_pk NOT IN (SELECT DISTINCT mp.mig_pk --, COUNT(*) --Se excuyen Agentes ya existentes
                                           FROM mig_personas_bs mp, per_personas p, agentes a
                                          WHERE 1 = 1
                                            AND a.sperson  = p.sperson
                                            AND mp.nnumide = p.nnumide
                                            AND mp.ctipide = p.ctipide
                                            AND  (    mp.ctipide  IS NOT NULL
                                                  AND mp.cestper  IS NOT NULL
                                                  AND mp.cpertip  IS NOT NULL
                                                  AND mp.swpubli  IS NOT NULL
                                                  AND mp.tapelli1 IS NOT NULL
                                                 )
                                            AND (SELECT COUNT(pp.sperson)
                                                   FROM per_personas pp, agentes ag
                                                  WHERE pp.nnumide = mp.nnumide
                                                    AND pp.ctipide = mp.ctipide
                                                    AND pp.sperson = ag.sperson) > 0
                                                    --GROUP BY  mp.mig_pk HAVING COUNT(*) > 0
                                              )*/ --Recibir instruccion, para borrar personas ya creadas
                  --GROUP BY mpc.mig_pk HAVING COUNT(*) > 0
                  ORDER BY mpc.CTIPIDE, mpc.NNUMIDE
                  )
     LOOP
       --
       BEGIN
         --
         BEGIN
           --
           INSERT INTO mig_agentes(ncarga, cestmig, mig_pk, mig_fk, cagente, idperson, ctipage, cactivo,
                           cretenc, ctipiva, ccomisi, cpadre, fmovini, fmovfin, cpervisio,
                           cpernivel, cpolvisio, cpolnivel, finivig, cdomici)
          VALUES(vncarga,
                 1,
                 l_per.mig_pk,
                 l_per.mig_fk,
                 f_set_agente(24, l_per.ctipage) ,
                 0 , --idperson
                 l_per.ctipage, -- nvl(ctipage,5),
                 --ojo con esto la aspecifiación es incorrecta 0 activo 1- inactivo, cuando es al reves
                 l_per.cactivo,
                 l_per.cretenc,
                 l_per.ctipiva,
                 to_number(REPLACE(REPLACE(REPLACE(l_per.ccomisi, 'GC', ''),
                                           '#N/A',
                                           1),
                                   'GR',
                                   '')) ,
                 l_per.cpadre,
                 NVL(l_per.fmovini, f_sysdate),
                 l_per.fmovfin,
                 v_agente_pervisio,
                 DECODE(l_per.cpernivel, 0, 1, l_per.cpernivel),
                 v_agente_pervisio,
                 DECODE(l_per.cpolnivel, 0, 1, l_per.cpolnivel) , --cpolnivel
                 l_per.fmovini, l_per.cdomici);
           --
         EXCEPTION
         WHEN OTHERS THEN
           --
           p_control_error(g_user,'04_Mig_Agentes', 'l_per.mig_pk: '||l_per.mig_pk||' ERR:'||SQLERRM);
           b_error := TRUE;
           --
         END;
         --
         /*v_cant := v_cant + 1;
         --
         IF MOD(v_cant,20)= 0
         THEN
           --
           p_control_error(g_user,'04_Mig_Agentes','v_cant:'||v_cant);
           --
         END IF;*/
         --
       EXCEPTION
       WHEN OTHERS THEN
         --
         dbms_output.put_line('LOOP PERSONAS [' ||l_per.MIG_PK||', '|| l_per.MIG_FK ||'] - ERR:'||SQLERRM);
         b_error := TRUE;
         --
       END;
       --
     END LOOP;
     --
     SELECT COUNT(*)
       INTO gcant_a_cargar
       FROM mig_agentes_bs;
     --
     SELECT COUNT(*)
       INTO gcant_cargada
       FROM mig_agentes;
     --
   END p_carga_agentes;
   /***************************************************************************
      PROCEDURE p_carga_per_agr_marcas
      Procedimiento que inserta los registros grabados en PER_AGR_MARCAS_CL1, en la tabla
      PER_AGR_MARCAS de iAXIS.
   ***************************************************************************/
   PROCEDURE p_carga_per_agr_marcas
   IS
     --
     TYPE t_mig_per_agr_marcas IS TABLE OF mig_per_agr_marcas%ROWTYPE;
     l_reg_mig_mcc t_mig_per_agr_marcas;
     --
      CURSOR lc_mig_per_agr_marcas IS
       SELECT 17413 NCARGA, 1 CESTMIG, a.MIG_PK, a.MIG_FK, a.CMARCA, a.CTIPO, a.CTOMADOR, a.CCONSORCIO, a.CASEGURADO,
              a.CCODEUDOR, a.CBENEF, a.CACCIONISTA, a.CINTERMED, a.CREPRESEN, a.CAPODERADO, a.CPAGADOR, a.TOBSEVA, a.NMOVIMI, a.CPROVEEDOR   -- TCS-344 CJMR 19/02/2019
       --Select Count(*)
         FROM mig_per_agr_marcas_bs a, mig_personas p
         WHERE 1 = 1
           AND a.mig_fk = p.mig_pk
      ORDER BY a.mig_pk
          ;
     --
    BEGIN
    --
    -----------------------------------------
    --PER_AGR_MARCAS
    -----------------------------------------
    OPEN lc_mig_per_agr_marcas;
    LOOP
      --
      FETCH lc_mig_per_agr_marcas BULK COLLECT INTO l_reg_mig_mcc LIMIT 10000;
      --
      dbms_output.put_line('per_agr_marcas - I - paso bullk');
      --
      dbms_output.put_line('...');
      --
      --FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
      --DELETE FROM mig_per_agr_marcas WHERE mig_pk = l_reg_mig_mcc(i).mig_pk;
      --
      BEGIN
        --
        FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
        INSERT INTO mig_per_agr_marcas VALUES l_reg_mig_mcc(i);
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
          p_control_error(g_user,'05_mig_per_agr_marcas','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
          --
        END LOOP;
        --
      END;
      --
      dbms_output.put_line('per_agr_marcas - F - paso bullk');
      --
      COMMIT;
      EXIT WHEN lc_mig_per_agr_marcas%NOTFOUND;
       --
     END LOOP;
     --
     gcant_a_cargar   := lc_mig_per_agr_marcas%ROWCOUNT;
     --
     SELECT COUNT(*)
       INTO gcant_cargada
       FROM mig_per_agr_marcas;
     --
     CLOSE lc_mig_per_agr_marcas;
     --
   END p_carga_per_agr_marcas;
   /***************************************************************************
      PROCEDURE p_carga_regimenfiscal
      Procedimiento que inserta los registros grabados en mig_regimenfiscal_bs, en la tabla
      mig_regimenfiscal de iAXIS.
   ***************************************************************************/
   PROCEDURE p_carga_regimenfiscal
   IS
     --
     TYPE t_mig_regimenfiscal IS TABLE OF mig_regimenfiscal%ROWTYPE;
     l_reg_mig_mcc t_mig_regimenfiscal;
     --
      CURSOR lc_mig_regimenfiscal IS
       SELECT 17413 NCARGA, 1 CESTMIG, a.MIG_PK, a.MIG_FK, a.nanuali, a.fefecto, a.cregfis
       --Select Count(*)
         FROM mig_regimenfiscal_bs a, mig_personas p
         WHERE 1 = 1
           AND a.mig_fk = p.mig_pk
      ORDER BY a.mig_pk
          ;
     --
    BEGIN
    --
    -----------------------------------------
    --REGIMENFISCAL
    -----------------------------------------
    OPEN lc_mig_regimenfiscal;
    LOOP
      --
      FETCH lc_mig_regimenfiscal BULK COLLECT INTO l_reg_mig_mcc LIMIT 10000;
      --
      dbms_output.put_line('per_regimenfiscal - I - paso bullk');
      --
      dbms_output.put_line('...');
      --
      --FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
      --DELETE FROM mig_regimenfiscal WHERE mig_pk = l_reg_mig_mcc(i).mig_pk;
      --
      BEGIN
        --
        FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
        INSERT INTO mig_regimenfiscal VALUES l_reg_mig_mcc(i);
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
          p_control_error(g_user,'06_mig_regimenfiscal','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
          --
        END LOOP;
        --
      END;
      --
      dbms_output.put_line('per_regimenfiscal - F - paso bullk');
      --
      COMMIT;
      EXIT WHEN lc_mig_regimenfiscal%NOTFOUND;
       --
     END LOOP;
     --
     gcant_a_cargar   := lc_mig_regimenfiscal%ROWCOUNT;
     --
     SELECT COUNT(*)
       INTO gcant_cargada
       FROM mig_regimenfiscal;
     --
     CLOSE lc_mig_regimenfiscal;
     --
   END p_carga_regimenfiscal;
   /***************************************************************************
      PROCEDURE p_carga_parpersonas
      Procedimiento que inserta los registros grabados en mig_parpersonas_bs, en la tabla
      mig_parpersonas de iAXIS.
   ***************************************************************************/
   PROCEDURE p_carga_parpersonas
   IS
     --
     TYPE t_mig_parpersonas IS TABLE OF mig_parpersonas%ROWTYPE;
     l_reg_mig_mcc t_mig_parpersonas;
     --
      CURSOR lc_mig_parpersonas IS
       SELECT 17413 NCARGA, 1 CESTMIG, a.MIG_PK, a.MIG_FK, a.CPARAM, a.TIPVAL, a.VALVAL
       --Select Count(*)
         FROM mig_parpersonas_bs a, mig_personas p
         WHERE 1 = 1
           AND a.mig_fk = p.mig_pk
      ORDER BY a.mig_pk
          ;
     --
    BEGIN
    --
    -----------------------------------------
    --PARPERSONAS
    -----------------------------------------
    OPEN lc_mig_parpersonas;
    LOOP
      --
      FETCH lc_mig_parpersonas BULK COLLECT INTO l_reg_mig_mcc LIMIT 10000;
      --
      dbms_output.put_line('per_parpersonas - I - paso bullk');
      --
      dbms_output.put_line('...');
      --
      --FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
      --DELETE FROM mig_parpersonas WHERE mig_pk = l_reg_mig_mcc(i).mig_pk;
      --
      BEGIN
        --
        FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
        INSERT INTO mig_parpersonas VALUES l_reg_mig_mcc(i);
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
          p_control_error(g_user,'07_mig_parpersonas','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
          --
        END LOOP;
        --
      END;
      --
      dbms_output.put_line('per_parpersonas - F - paso bullk');
      --
      COMMIT;
      EXIT WHEN lc_mig_parpersonas%NOTFOUND;
       --
     END LOOP;
     --
     gcant_a_cargar   := lc_mig_parpersonas%ROWCOUNT;
     --
     SELECT COUNT(*)
       INTO gcant_cargada
       FROM mig_parpersonas;
     --
     CLOSE lc_mig_parpersonas;
     --
   END p_carga_parpersonas;
   --
   /***************************************************************************
      PROCEDURE p_carga_person
      Procedimiento que ejecuta el cargue de un fichero particular
         param in  ptab_des:     Descripción de la tabla.
   ***************************************************************************/
   PROCEDURE p_carga_person(ptab_des VARCHAR2)
   IS
     --
     l_timestart       NUMBER;
     l_timeend         NUMBER;
     l_time            NUMBER;
     vdummy            NUMBER;
     --
   BEGIN
     --
      l_timestart := dbms_utility.get_time();
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
     IF ptab_des = 'MIG_PERSONAS'
     THEN
       --
       p_carga_personas;
       --
     ELSIF ptab_des = 'MIG_DIRECCIONES'
     THEN
       --
       p_carga_direcciones;
       --
     ELSIF ptab_des = 'MIG_PERSONAS_REL'
     THEN
       --
       p_carga_personas_rel;
       --
     ELSIF ptab_des = 'MIG_AGENTES'
     THEN
       --
       p_carga_agentes;
       --
     ELSIF ptab_des = 'MIG_PER_AGR_MARCAS'
     THEN
       --
       p_carga_per_agr_marcas;
       --
     ELSIF ptab_des = 'MIG_REGIMENFISCAL'
     THEN
       --
       p_carga_regimenfiscal;
       --
       --
     ELSIF ptab_des = 'MIG_PARPERSONAS'
     THEN
       --
       p_carga_parpersonas;
       --
     END IF;
     --
     l_timeend := dbms_utility.get_time();
     l_time    := (l_timeend - l_timestart) / 100;
     p_control_error(g_user, ptab_des, gcant_cargada || ' reg cargados de ' || gcant_a_cargar || '. Tiempo de Ejecución: '|| l_time || ' seg');
     dbms_output.put_line(ptab_des || '. '|| gcant_cargada || ' reg cargados de ' || gcant_a_cargar || '. Tiempo de Ejecución: ' || l_time || ' seg');
     --
   END p_carga_person;
   --
END pac_carga_per_red_conf;
/