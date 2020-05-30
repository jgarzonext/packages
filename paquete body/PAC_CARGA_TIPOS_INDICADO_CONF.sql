--------------------------------------------------------
--  DDL for Package Body PAC_CARGA_TIPOS_INDICADO_CONF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_CARGA_TIPOS_INDICADO_CONF" IS
   /***************************************************************************
      NOMBRE:       pac_carga_siniestros_conf
      PROPÓSITO:    Proceso de traspaso de informacion de las tablas _BS a las
                    tablas MIG_ de AXIS (Capítulo TIPOS_INDICADORES)
      REVISIONES:
      Ver        Fecha       Autor       Descripción
      ---------  ----------  ----------  --------------------------------------
       1.0        27/10/2017  HAG         Creacion package de carga
   ***************************************************************************/
   /**************************************************************************
        Clave MIG_PK_MIG_AXIS.PK_AXIS
   ***************************************************************************
   ****** ******
   **************************************************************************/
   --
   /***************************************************************************
      PROCEDURE p_asigna_user
      Procedimiento que asigna usuario de carga
         param in  puser:     Descripción del usuario.
   ***************************************************************************/
   dml_errors EXCEPTION;
   PRAGMA EXCEPTION_INIT(dml_errors, -24381);
   l_errors  NUMBER;
   l_errno   NUMBER;
   l_msg     VARCHAR2(4000);
   gtab_des  VARCHAR2(500);
   l_idx     NUMBER;
   gcant_a_cargar NUMBER := 0;
   gcant_cargada  NUMBER := 0;
   g_user         VARCHAR2(30);
   --
   PROCEDURE p_asigna_user(puser VARCHAR2)
   IS
   BEGIN
     --
     g_user := puser;
     --
   END p_asigna_user;
   --
   /**************************************************************************
      PROCEDURE p_borra_tipos_indicadores
      Procedimiento que borra los registros grabados en MIG_TIPOS_INDICADORES y relacionados, en iAxis
   ***************************************************************************/
   PROCEDURE p_borra_tipos_indicadores
   IS
   BEGIN
     --
     DELETE FROM sin_prof_indicadores;
     DELETE FROM RETENCIONES WHERE CTIPIND IS NOT NULL;
     DELETE FROM tipos_indicadores_det;
     DELETE FROM tipos_indicadores;
     --
   END p_borra_tipos_indicadores;
   --
   /***************************************************************************
      PROCEDURE p_carga_tipos_indicadores
      Procedimiento que inserta los registros grabados en MIG_TIPOS_INDICADORES_CL1, en la tabla
      MIG_TIPOS_INDICADORES de iAXIS.
   ***************************************************************************/
   PROCEDURE p_carga_tipos_indicadores
   IS
     --
     TYPE t_mig_tipos_indicadores IS TABLE OF mig_tipos_indicadores%ROWTYPE;
     l_reg_mig_mcc t_mig_tipos_indicadores;
     --
      CURSOR lc_mig_tipos_indicadores IS
  SELECT 17414 NCARGA,1 CESTMIG, a.MIG_PK, a.tindica, a.carea, a.ctipreg, a.cimpret, NVL(a.ccindid, a.cindsap) ccindid,
              CASE
                WHEN a.ccindid IS NULL     THEN NULL
                WHEN a.ccindid IS NOT NULL THEN a.cindsap
              END cindsap, --casos cuando reportan ccindid = NULL
              a.porcent, a.cclaing,  a.ibasmin, a.cprovin, a.cpoblac, nvl(a.fvigor, to_date('01012013', 'ddmmyyyy')) fvigor
        FROM mig_tipos_indicadores_bs a
       WHERE 1 = 1
          --AND a.mig_fk = s.mig_pk (+)
    ORDER BY a.mig_pk
          ;
          --SELECT * FROM mig_tipos_indicadores_conf s;
          --SELECT * FROM mig_tipos_indicadores s WHERE s.mig_pk = '131050100DL0200681';
      CURSOR lc_indicadores_actuales IS
        SELECT p.sprofes,  f_nombre (p.sperson, 1) persona, i.carea,
              CASE i.carea
              WHEN 1 THEN '1 - Reaseguro'
              WHEN 2 THEN '2 - Intermediario'
              WHEN 3 THEN '3 - Siniestros'
              WHEN 4 THEN '4 - Produccion'
              END TAREA,
              i.ctipind, i.tindica, d.porcent, d.ibasmin, d.cpostal
        FROM per_detper dp,
             sin_prof_profesionales p,
             sin_prof_indicadores   s,
             tipos_indicadores i,
             tipos_indicadores_det d
        WHERE 1 = 1
          AND dp.sperson = p.sperson
          AND p.sprofes = s.sprofes
          AND s.ctipind = i.ctipind
          AND i.ctipind = d.ctipind;
     --
     l_reg_ind_act lc_indicadores_actuales%ROWTYPE;
     --
     CURSOR lc_retenciones IS
     SELECT * FROM RETENCIONES WHERE CTIPIND IS NOT NULL;
     l_reg_retenciones lc_retenciones%ROWTYPE;
     --
     CURSOR lc_tipos_indicadores IS
     SELECT * FROM tipos_indicadores;
     l_reg_tip_indicadores lc_tipos_indicadores%ROWTYPE;
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
    --TIPOS_INDICADORES
    -----------------------------------------
    OPEN lc_indicadores_actuales;
    FETCH lc_indicadores_actuales INTO l_reg_ind_act;
    --
    OPEN lc_retenciones;
    FETCH lc_retenciones INTO l_reg_retenciones;
    --
    OPEN lc_tipos_indicadores;
    FETCH lc_tipos_indicadores INTO l_reg_tip_indicadores;
    --
    IF    lc_indicadores_actuales%NOTFOUND
      AND lc_retenciones%NOTFOUND
      AND lc_tipos_indicadores%NOTFOUND
    THEN
      --
      OPEN lc_mig_tipos_indicadores;
      LOOP
        --
        FETCH lc_mig_tipos_indicadores BULK COLLECT INTO l_reg_mig_mcc LIMIT 1000;  -- limit to 10k to avoid out of memory
        --
        dbms_output.put_line('mig_tipos_indicadores - I - paso bullk');
        --
        dbms_output.put_line('...');
        --
        FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
        DELETE FROM mig_tipos_indicadores WHERE mig_pk = l_reg_mig_mcc(i).mig_pk;
        --
        BEGIN
          --
          FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
          INSERT INTO mig_tipos_indicadores VALUES l_reg_mig_mcc(i);
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
            p_control_error(g_user,'01_mig_tipos_indicadores','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
            --
          END LOOP;
          --
        END;
        --
        dbms_output.put_line('mig_tipos_indicadores - F - paso bullk');
        --
        COMMIT;
        --
        EXIT WHEN lc_mig_tipos_indicadores%NOTFOUND;
         --
       END LOOP;
       --
       gcant_a_cargar   := lc_mig_tipos_indicadores%ROWCOUNT;
       --
       SELECT COUNT(*)
         INTO gcant_cargada
         FROM mig_tipos_indicadores;
       --
       CLOSE lc_mig_tipos_indicadores;
       --
     ELSE
       --
       dbms_output.put_line('. . . Hay indicadores asociados a profesionales/retenciones/tipos indicador . . . Se deben borrar!');
       --
     END IF;
     --
     CLOSE lc_indicadores_actuales;
     CLOSE lc_retenciones;
     CLOSE lc_tipos_indicadores;
     --
   END p_carga_tipos_indicadores;
   --
   /***************************************************************************
      PROCEDURE p_carga_indica
      Procedimiento que ejecuta el cargue de un fichero particular
         param in  ptab_des:     Descripción de la tabla.
   ***************************************************************************/
   PROCEDURE p_carga_indica(ptab_des VARCHAR2)
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
      SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
        INTO vdummy
        FROM dual;
      --
      gtab_des   := ptab_des;
      --
     IF ptab_des = 'MIG_TIPOS_INDICADORES'
     THEN
       --
       p_carga_tipos_indicadores;
       --
     END IF;
     --
     l_timeend := dbms_utility.get_time();
     l_time    := (l_timeend - l_timestart) / 100;
     p_control_error(g_user, ptab_des, gcant_cargada || ' reg cargados de ' || gcant_a_cargar || '. Tiempo de Ejecución: '|| l_time || ' seg');
     dbms_output.put_line(gcant_cargada || ' reg cargados de ' || gcant_a_cargar || '. Tiempo de Ejecución: ' || l_time || ' seg');
     --
   END p_carga_indica;
   --
END pac_carga_tipos_indicado_conf;

/

  GRANT EXECUTE ON "AXIS"."PAC_CARGA_TIPOS_INDICADO_CONF" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_CARGA_TIPOS_INDICADO_CONF" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_CARGA_TIPOS_INDICADO_CONF" TO "PROGRAMADORESCSI";
