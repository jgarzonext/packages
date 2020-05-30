--------------------------------------------------------
--  DDL for Package Body PAC_JOBS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_JOBS" AS
/******************************************************************************
   NOMBRE:       PAC_JOBS
   PROPÓSITO: Funciones para lanzar Oracle Jobs

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        12/03/2009   DCT             1. Creación del package.
   2.0        22/04/2014   MMM             2. 0030693: LCOL_MILL-0011853 / 11863: Valores Cero en el informe...
   3.0        14/06/2014   JGR             3. 0032151: LCOL_MILL-0013488: Al generar el informe detallado de contabilidad por Batch aparece error
******************************************************************************/--BUG7352 - 17/06/2009 - DCT - IAX - Desarrollo PL Cierres
   /*************************************************************************
      Registra un Job, retornando un SPROCES. Mas de todo para las trazas,
      se añade el usuario quien solicita al Job.
      param in pcusuari  : usuario quien solicita el SPROCES
      param out psproces : código del proceso
      param out          : mensajes de error
      return             : 0 todo ha sido correcto
                           1 ha habido un error
   *************************************************************************/
   -- BUG 21546_108727- 23/02/2012 - JLTS - Se elimina el envío de mensajes
   FUNCTION f_registrar_job(pcusuari IN VARCHAR, psproces OUT NUMBER)
      RETURN NUMBER AS
   BEGIN
      /* TODO implementation required */
      -- para pruebas, una select a saco
      SELECT sproces.NEXTVAL
        INTO psproces
        FROM DUAL;

      RETURN psproces;
   END f_registrar_job;

   --BUG7352 - 17/06/2009 - DCT - IAX - Desarrollo PL Cierres
   /*************************************************************************
      Lanza un job con el nombre tnombre y posibles parametros ptparams, separados por "|"'s
      param in psproces  : usuario quien solicita el SPROCES
      param in ptnombre  : nombre del job a ejecutar
      param in ptparams  : posibles parametros, separados por "|"'s, permite (NULL)
      param out          : mensajes de error
      return             : 0 todo ha sido correcto
                           1 ha habido un error
   *************************************************************************/
   -- BUG 21546_108727- 23/02/2012 - JLTS - Se elimina el envío de mensajes
   FUNCTION f_ejecuta_job(psproces IN NUMBER, ptnombre IN VARCHAR, ptparams IN VARCHAR)
      RETURN NUMBER AS
      vjob           NUMBER;
      nerror         NUMBER;
      vobject        VARCHAR2(200) := 'PAC_JOBS.f_ejecuta_job';
      vpasexec       NUMBER(8) := 1;
      v_ptparams     VARCHAR2(300);
      vparam         VARCHAR2(900)
                                 := 'p=' || psproces || ' n=' || ptnombre || ' p=' || ptparams;

      CURSOR c_vjob_run IS
         SELECT v.job, v.this_date
           FROM user_jobs v
          WHERE UPPER(v.what) LIKE UPPER(ptnombre);

      TYPE data_t IS TABLE OF VARCHAR2(100)
         INDEX BY VARCHAR2(50);

      v_data         data_t;
      param          CLOB;
      pos            NUMBER;
      plong          NUMBER;
      pos_prev       NUMBER := 0;
      loop_size      NUMBER := 1;
      long_param     NUMBER := 1;
      v_submit       VARCHAR2(500);
   --v_noparse      BOOLEAN := false;
   --v_force        BOOLEAN := false;
   BEGIN
      -- bug 0022185
      vpasexec := 10;
      nerror := 0;
      /* TODO implementation required */
      vpasexec := 20;

      FOR reg IN c_vjob_run LOOP
         --Validamos si existe el proceso ya programado o ejecutándose
         vpasexec := 30;

         IF reg.this_date IS NOT NULL THEN
            --El proceso programado se está ejecutando
            --PAC_IOBJ_MENSAJES.Crea_Nuevo_Mensaje(mensajes,6,9001145);
            nerror := 9001145;
            p_tab_error(f_sysdate, f_user, vobject, vpasexec,

                        -- 3. 0032151: LCOL_MILL-0013488: - Inicio
                        --vparam || ' err=' || nerror,
                        SUBSTR(vparam || ' err=' || nerror, 1, 500),

                        -- 3. 0032151: LCOL_MILL-0013488: - Final
                        'j=' || reg.job || ' d=' || reg.this_date);
         END IF;
      END LOOP;

      vpasexec := 40;

      IF nerror = 0 THEN
         IF ptparams IS NOT NULL THEN
            vpasexec := 50;
            v_ptparams := ptparams;
            --Inicializamos v_data
            v_data('NEXT_DATE') := NULL;
            v_data('INTERVAL') := NULL;
            v_data('NO_PARSE') := NULL;
            v_data('INSTANCE') := NULL;
            v_data('FORCE') := NULL;

            ---Parseamos los parametros
            IF REGEXP_REPLACE(v_ptparams, '[^#]', '') IS NOT NULL THEN
               loop_size := LENGTH(REGEXP_REPLACE(v_ptparams, '[^#]', '')) + 1;
            END IF;

            vpasexec := 51;

            FOR i IN 1 .. loop_size LOOP
               pos := INSTR(v_ptparams, '#', 1, i);
               plong := pos - pos_prev - 1;

               IF pos = 0 THEN
                  pos := LENGTH(v_ptparams);
                  plong := pos - pos_prev;
               END IF;

               param := SUBSTR(v_ptparams, pos_prev + 1, plong);
               pos_prev := pos;
               v_data(SUBSTR(param, 0, INSTR(param, ';', 1, 1) - 1)) :=
                                       SUBSTR(param, INSTR(param, ';', 1, 1) + 1,
                                              LENGTH(param));
            END LOOP;

            vpasexec := 52;
            v_submit := 'declare vjob NUMBER;' || '  begin dbms_job.submit(vjob,' || CHR(39)
                        || ptnombre || CHR(39) || ',' || NVL(v_data('NEXT_DATE'), 'NULL')
                        || ',' || NVL(v_data('INTERVAL'), 'NULL') || ','
                        || NVL(v_data('NO_PARSE'), 'false') || ','
                        || NVL(v_data('INSTANCE'), 0) || ',' || NVL(v_data('FORCE'), 'false')
                        || ');' || '  commit; end;';
            vpasexec := 53;

            EXECUTE IMMEDIATE v_submit;
         ELSE
            DBMS_JOB.submit(vjob, ptnombre);
         END IF;

         /*
         -- bug 0022185
         vpasexec := 55;
         nerror := pac_log.f_log_consultas(vjob || ' --> ' || ptnombre, vobject, 1);
         IF nerror <> 0 THEN
            p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam || ' err=' || nerror,
                        SQLCODE || ' ' || SQLERRM);
            nerror := 0;
         END IF;
         */
         vpasexec := 60;
         COMMIT;
      END IF;

      --return vJob;
      vpasexec := 70;
      p_tab_error(f_sysdate, f_user, vobject, vpasexec,

                  -- 3. 0032151: LCOL_MILL-0013488: - Inicio
                  --'bug 0022185 ' || vparam,
                  SUBSTR('bug 0022185 ' || vparam, 1, 500),

                  -- 3. 0032151: LCOL_MILL-0013488: - Final
                  ' nerror=' || nerror || ' vjob=' || vjob);
      RETURN nerror;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec,

                     -- 3. 0032151: LCOL_MILL-0013488: - Inicio
                     --'bug 0022185 ' || 'OTHERS ' || vparam || ' err=' || nerror,
                     SUBSTR('bug 0022185 ' || 'OTHERS ' || vparam || ' err=' || nerror, 1,
                            500),

                     -- 3. 0032151: LCOL_MILL-0013488: - Final
                     SQLCODE || ' ' || SQLERRM);
         RETURN 108953;
   END f_ejecuta_job;

   --BUG7352 - 17/06/2009 - DCT - IAX - Desarrollo PL Cierres
   /*************************************************************************
       Retorna el estado de un proceso identificado como psproces.
       param in psproces  : usuario quien solicita el SPROCES
       param out pcstatus : estado del proceso
       param out          : mensajes de error
       return             : 0 todo ha sido correcto
                            1 ha habido un error
    *************************************************************************/
    -- BUG 21546_108727- 23/02/2012 - JLTS - Se elimina el envío de mensajes
   FUNCTION f_status_job(psproces IN NUMBER, pcstatus OUT NUMBER)
      RETURN NUMBER AS
   BEGIN
      /* TODO implementation required */
      -- para pruebas, retorno un -1 a saco
      RETURN -1;
   END f_status_job;

-------------------------------------------------------------------
   FUNCTION f_get_tproces(pcproces IN NUMBER)
      RETURN VARCHAR2 AS
      vtproces       job_descproces.tproces%TYPE;
   BEGIN
      SELECT tproces
        INTO vtproces
        FROM job_descproces
       WHERE cproces = pcproces
         AND cidioma = pac_md_common.f_get_cxtidioma;

      RETURN vtproces;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END;

   FUNCTION f_exist_proces(pcproces IN NUMBER, ptclave IN VARCHAR2, pmodo IN VARCHAR2)
      RETURN BOOLEAN AS
      vcont          NUMBER;
      velemento      VARCHAR2(30);
      vposini        NUMBER := 1;
      vposfin        NUMBER;
      vsigue         BOOLEAN;
      vlong          NUMBER;
   BEGIN
      --Si se trata de una cartera por productos, el tratamiento es diferente tclave tiene una cadena con todos los productos afectados.
      IF pcproces = 6 THEN
         --tratamos cada uno de los productos y comprobamos si existen en otro proceso
         vposfin := INSTR(ptclave, '|', vposini, 1);
         vlong := LENGTH(ptclave);

         IF vposfin > 0 THEN
            vsigue := TRUE;
         END IF;

         WHILE vsigue LOOP
            velemento := SUBSTR(ptclave, vposini, vposfin - vposini);

            --
            SELECT COUNT(*)
              INTO vcont
              FROM job_colaproces
             WHERE cestado <> 2
               AND cproces = pcproces
               AND INSTR(tclave, velemento, 1, 1) > 0;

            IF vcont > 0 THEN
               RETURN TRUE;
            END IF;

            --
            vposini := vposfin + 1;

            IF vposini > vlong THEN
               EXIT;
            END IF;

            vposfin := INSTR(ptclave, '|', vposini, 1);
         END LOOP;

         RETURN FALSE;
      END IF;

      IF pmodo = 'INS' THEN
         SELECT COUNT(*)
           INTO vcont
           FROM job_colaproces
          WHERE cestado <> 2
            AND tclave = ptclave;
      ELSE
         SELECT COUNT(*)
           INTO vcont
           FROM job_colaproces
          WHERE cestado = 1
            AND tclave = ptclave;
      END IF;

      IF vcont = 0 THEN
         RETURN FALSE;
      ELSE
         RETURN TRUE;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_jobs.f_exist_proces', 0, 'Error no controlado',
                     SQLERRM);
         RETURN TRUE;
   END f_exist_proces;

   FUNCTION f_inscolaproces(
      pcproces IN NUMBER,
      ptsentencia IN VARCHAR2,
      ppproces IN VARCHAR2,
      ptclave IN VARCHAR2)
      RETURN NUMBER AS
      vnprior        job_codiproces.nprior%TYPE;
      vidjob         job_colaproces.idjob%TYPE;
      v_jobtype      NUMBER;
   BEGIN
      v_jobtype := NVL(f_parinstalacion_n('JOB_TYPE'), 0);

      IF v_jobtype = 2 THEN
         IF pcproces IN(1, 5) THEN
            -- Las cargas y emisiones de colectivos administrados no controlamos que no puedan lanzarlas 2 veces.
            IF f_exist_proces(pcproces, ptclave, 'INS') THEN
               RETURN 9905979;
            END IF;
         END IF;

         SELECT nprior
           INTO vnprior
           FROM job_codiproces
          WHERE cproces = pcproces;

         vidjob := 'JOB' || LPAD(pcproces, 2, '0')
                   || TO_CHAR(SYSTIMESTAMP, 'yyyymmddhh24misssss');

         INSERT INTO job_colaproces
                     (idjob, cproces, nprior, tsentencia, pproces, cestado, fproprg, cusuari,
                      tclave)
              VALUES (vidjob, pcproces, vnprior, ptsentencia, ppproces, 0, f_sysdate, f_user,
                      ptclave);
      END IF;

      DBMS_SCHEDULER.create_job(job_name => vidjob, job_type => 'PLSQL_BLOCK',
                                job_action => ptsentencia, start_date => NULL,
                                comments => f_get_tproces(pcproces));

      IF v_jobtype = 1 THEN
         DBMS_SCHEDULER.ENABLE(vidjob);
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_jobs.f_inscolaproces', 1, 'Error',
                     SQLCODE || '-' || SQLERRM);
         RETURN 1;
   END f_inscolaproces;

   PROCEDURE p_get_colaproces AS
      vnjobs         NUMBER := 2;   --hecer que sea un parempresas
      vnjob_run      NUMBER;
      vstatus        VARCHAR2(30);
      vfproini       DATE;
      vfprofin       DATE;
   BEGIN
      --En primer lugar revisamos los jobs en espera o que se estan ejecutando
      --para comprobar si ya han terminado para actualizar la tabla job_colaproces
      FOR x IN (SELECT   *
                    FROM job_colaproces
                   WHERE cestado IN(0, 1)
                ORDER BY nprior DESC, fproprg) LOOP
         --En primer lugar miramos si se esta ejecutando, si es así actualizamos el estado en job_colaproces.
         BEGIN
            SELECT state
              INTO vstatus
              FROM all_scheduler_jobs
             WHERE job_name = x.idjob;

            IF vstatus = 'RUNNING' THEN
               UPDATE job_colaproces
                  SET cestado = 1
                WHERE idjob = x.idjob;

               COMMIT;
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;

         --En segundo lugar miramos si ha terminado correctamente, si es así actualizamos el estado y las fecha de job_colaproces.
         BEGIN
            SELECT status, actual_start_date, log_date
              INTO vstatus, vfproini, vfprofin
              FROM all_scheduler_job_run_details
             WHERE job_name = x.idjob
               AND log_id = (SELECT MAX(log_id)
                               FROM all_scheduler_job_log
                              WHERE job_name = x.idjob);

            IF vstatus = 'SUCCEEDED' THEN
               UPDATE job_colaproces
                  SET fproini = vfproini,
                      fprofin = vfprofin,
                      cestado = 2
                WHERE idjob = x.idjob;

               COMMIT;
            END IF;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               NULL;   --Todavia no ha sido ejecutado
         END;
      END LOOP;

      SELECT COUNT(*)
        INTO vnjob_run
        FROM job_colaproces
       WHERE cestado = 1;

      IF vnjob_run < vnjobs THEN
         --hay menos jobs corriendo que los definidos para que se ejecuten a la vez
         FOR x IN (SELECT   *
                       FROM job_colaproces
                      WHERE cestado = 0
                   ORDER BY nprior DESC, fproprg) LOOP
            IF NOT f_exist_proces(x.cproces, x.tclave, 'RUN') THEN
               DBMS_SCHEDULER.ENABLE(x.idjob);

               UPDATE job_colaproces
                  SET cestado = 1
                WHERE idjob = x.idjob;

               COMMIT;
               vnjob_run := vnjob_run + 1;

               IF vnjob_run >= vnjobs THEN
                  EXIT;
               END IF;
            END IF;
         END LOOP;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_jobs.p_get_colaproces', 0, '¡¡¡¡¡Error!!!!!',
                     SQLERRM);
   END p_get_colaproces;
END pac_jobs;

/

  GRANT EXECUTE ON "AXIS"."PAC_JOBS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_JOBS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_JOBS" TO "PROGRAMADORESCSI";
