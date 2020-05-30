--------------------------------------------------------
--  DDL for Package Body PAC_CFG_FILE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_CFG_FILE" AS
/******************************************************************************
   NOMBRE:       PAC_CFG_FILE
   PROP¿SITO:    Control y gesti¿n de tratamiento de ficheros

   REVISIONES:
   Ver        Fecha        Autor             Descripci¿n
   ---------  ----------  ---------------  ------------------------------------
   1.0        12/02/2009   JTS                1. Creaci¿n del package.
   2.0        31/05/2010   PFA                2. 14750: ENSA101 - Reproceso de procesos ya existentes
   3.0        14/09/2010   PFA                3. 15730: CRT - Avisar que el fichero ya esta cargado
   4.0        15/10/2010   DRA                4. 0016130: CRT - Error informando el codigo de proceso en carga
   5.0        04/11/2010   FAL                5. 0016525: CRT002 - Incidencias en cargas (primera carga inicial)
   6.0        05/10/2011   JMC                6. 0019689: AGM703 - Cambio llamada EXECUTE IMMNEDIATE por DBMS_SQL
   7.0        05/07/2013   JGR                7. 0027594: LCOL_A003-Deben ser eliminados los cobradores bancarios - QT-8291 Nota: 33666
   8.0        17/06/2014   SSM                8. 0031628: VERSIONES EN CARGAS de DEDUCIBLES y TASAS se modifican las funciones para que pueda cargar mas de una versi¿n
   9.0        18/08/2014   SSM                9. 29952/181608 LCOL895-QT 4345: Validacion de Campos Listado Superfinanciera y otros QT de Fases
******************************************************************************/

   /*************************************************************************
      BUG9077 - 12/02/2009 - JTS
      Abre un cursor con los procesos definidos en CFG_FILES
      param out p_tprocesos : sys_refcursor
      return                : 0.-    OK
                              otro.- error
   *************************************************************************/
   FUNCTION f_get_procesos(
      p_cempres IN NUMBER,
      p_cidioma IN NUMBER,
      p_tprocesos OUT sys_refcursor)
      RETURN NUMBER IS
   BEGIN
      OPEN p_tprocesos FOR 'SELECT cproceso, tdestino, f_axis_literales(cdescrip,'
                           || p_cidioma
                           || ') tdescrip, tproceso, tpantalla FROM cfg_files where cempres='
                           || p_cempres
                           || ' and cactivo = 1 ORDER BY cproceso'   -- 7. 0027594 - QT-8291 Nota: 33666
                                                ;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         -- BUG -21546_108724- 07/02/2012 - JLTS - Cierre de posibles cursores abiertos
         IF p_tprocesos%ISOPEN THEN
            CLOSE p_tprocesos;
         END IF;

         RETURN SQLCODE;
   END f_get_procesos;

   /*************************************************************************
      BUG9077 - 12/02/2009 - JTS
      Retorna los par¿metros para la ejecuci¿n de un proceso
      param in  p_cproceso : Id. del proceso
      param out p_tdestino : Directorio de destino
      param out p_tproceso : Proceso de base de datos
      return               : 0.-    OK
                             otro.- error
   *************************************************************************/
   FUNCTION f_get_datos_proceso(
      p_cproceso IN NUMBER,
      p_cempres IN NUMBER,
      p_tdestino OUT VARCHAR2,
      p_tproceso OUT VARCHAR2,
      -- Bug 0016525. FAL. 04/11/2010. Se a¿ade parametro q indica si borrar fichero del servidor
      p_borrafich OUT NUMBER)
      -- Fi Bug 0016525
   RETURN NUMBER IS
   BEGIN
      SELECT tdestino, tproceso, cborra_fich
        INTO p_tdestino, p_tproceso, p_borrafich
        FROM cfg_files
       WHERE cproceso = p_cproceso
         AND cempres = p_cempres;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN SQLCODE;
   END f_get_datos_proceso;

   /*************************************************************************
      BUG9077 - 12/02/2009 - JTS
      Realiza el tratamiento del fichero
      param in  p_cproceso : Id. del proceso
      param in  p_tfile    : Nombre del fichero
      param in out p_sproces  : Num de proceso
      param out p_tpantalla: Pantalla de navegaci¿n siguiente
      return               : 0.-    OK
                             otro.- error
   *************************************************************************/
   FUNCTION f_ejecuta_proceso(
      p_cproceso IN NUMBER,
      p_tfile IN VARCHAR2,
      p_cempres IN NUMBER,
      p_sproces IN OUT NUMBER,   --Bug 14750-PFA-31/05/2010- psproces IN OUT
      p_nnumcaso IN NUMBER,   -- Bug 28263/156016 - 15/10/2013 - AMC
      p_tpantalla OUT VARCHAR2)
      RETURN NUMBER IS
      v_error        NUMBER(8);
      v_sql          VARCHAR2(1000);
      v_tproceso     VARCHAR2(100);
      v_tdestino     VARCHAR2(100);
      v_cursor       NUMBER;
      v_filas        NUMBER;
      vcjob          NUMBER;
      vmensaje       VARCHAR2(1000);
   BEGIN
      SELECT tpantalla, tproceso, tdestino_bbdd, cjob
        INTO p_tpantalla, v_tproceso, v_tdestino, vcjob
        FROM cfg_files
       WHERE cproceso = p_cproceso
         AND cempres = p_cempres;

      IF (((vcjob IS NULL
            OR vcjob = 0)
           OR p_sproces IS NOT NULL)
          OR(vcjob = 2
             AND p_sproces IS NULL)) THEN
         IF (vcjob = 2
             AND p_sproces IS NOT NULL) THEN   -- Reproceso carga vida
            -- Bug 33221/0191203 - 06/11/2014 - JLTS - Se adiciona el contexto
            v_sql := 'declare v_error NUMBER; v_proceso NUMBER := ' || p_sproces
                     || '; begin v_error:= pac_contexto.f_inicializarctx(' || CHR(39)
                     || f_user || CHR(39) || ');' || CHR(10) || ' v_error := ' || v_tproceso
                     || '(''' || p_tfile || ''',''' || v_tdestino || ''',''' || p_cproceso
                     || ''', ' || 'v_proceso' || ' ';

            IF p_nnumcaso IS NOT NULL THEN
               v_sql := v_sql || ',' || CHR(39) || p_nnumcaso || CHR(39);
            END IF;

            v_sql := v_sql || '); end;';
            vmensaje := pac_jobs.f_ejecuta_job(NULL, v_sql, NULL);

            IF vmensaje > 0 THEN
               RETURN 180856;
            END IF;

            RETURN 9907390;
         ELSE
            -- Bug 28263/156016 - 15/10/2013 - AMC
            v_sql := 'begin :verror := ' || v_tproceso || '(''' || p_tfile || ''','''
                     || v_tdestino || ''',''' || p_cproceso   -- BUG16130:DRA:15/10/2010
                     || ''', :psproces ';

            IF p_nnumcaso IS NOT NULL THEN
               v_sql := v_sql || ',' || CHR(39) || p_nnumcaso || CHR(39);
            END IF;

            v_sql := v_sql || '); end;';

            IF DBMS_SQL.is_open(v_cursor) THEN
               DBMS_SQL.close_cursor(v_cursor);
            END IF;

            v_cursor := DBMS_SQL.open_cursor;
            DBMS_SQL.parse(v_cursor, v_sql, DBMS_SQL.native);
            DBMS_SQL.bind_variable(v_cursor, ':verror', v_error);
            DBMS_SQL.bind_variable(v_cursor, ':psproces', p_sproces);
            v_filas := DBMS_SQL.EXECUTE(v_cursor);
            DBMS_SQL.variable_value(v_cursor, 'verror', v_error);
            DBMS_SQL.variable_value(v_cursor, 'psproces', p_sproces);

            IF DBMS_SQL.is_open(v_cursor) THEN
               DBMS_SQL.close_cursor(v_cursor);
            END IF;

            IF v_error = 3 THEN
               RETURN 9906830;
            END IF;
         END IF;
      ELSE
         p_procesini(f_user, p_cempres, p_cproceso, SUBSTR(v_tproceso, 1, 100), p_sproces);
         v_sql := 'declare nerror number; vsproces number := ' || p_sproces
                  || '; begin nerror:= pac_contexto.f_inicializarctx(' || CHR(39) || f_user
                  || CHR(39) || '); nerror:= ' || v_tproceso || '(''' || p_tfile || ''','''
                  || v_tdestino || ''',''' || p_cproceso || ''', vsproces ';

         IF p_nnumcaso IS NOT NULL THEN
            v_sql := v_sql || ',' || CHR(39) || p_nnumcaso || CHR(39);
         END IF;

         v_sql := v_sql || '); end;';
         vmensaje := pac_jobs.f_ejecuta_job(NULL, v_sql, NULL);

         IF vmensaje > 0 THEN
            p_tab_error(f_sysdate, f_user, 'pac_cfg_file.f_ejecuta_proceso', 1,
                        ' p_sproces = ' || p_sproces || ' p_cproceso = ' || p_cproceso,
                        SQLERRM);
            p_proceslin(p_sproces, 'Error:' || vmensaje || ' al crear job', vmensaje, 1);
            RETURN 180856;
         END IF;

         p_proceslin(p_sproces, 'Carga programada correctamente', 0, 4);
         RETURN 9901606;
      END IF;

      -- Fin BUG 19689 - 05-10-2011 - JMC
      RETURN v_error;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_cfg_file.f_ejecuta_proceso', 2,
                     ' p_sproces = ' || p_sproces || ' p_cproceso = ' || p_cproceso, SQLERRM);
         RETURN SQLCODE;
   END f_ejecuta_proceso;

   /*************************************************************************
      BUG15730 - 14/09/2010 - PFA
      Comprueba si el fichero ya est¿ cargado
      param in  pcproceso     : Id. del proceso
      param in  ptfichero     : Nombre del fichero
      return                  : 0.- OK
                                1.- error
   *************************************************************************/
   FUNCTION f_get_proceso_cargado(pcproceso IN NUMBER, ptfichero IN VARCHAR2)
      RETURN NUMBER IS
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(200)
                                := 'pcproceso = ' || pcproceso || ' ptfichero = ' || ptfichero;
      v_object       VARCHAR2(200) := 'PAC_CFG_FILE.f_get_proceso_cargado';
      vcount         NUMBER(8);
   BEGIN
      SELECT COUNT(*)
        INTO vcount
        FROM int_carga_ctrl
       WHERE cproceso = pcproceso
         AND tfichero = ptfichero;

      IF vcount > 0 THEN
         RETURN 1;
      ELSE
         RETURN vcount;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN SQLCODE;
   END f_get_proceso_cargado;
END pac_cfg_file;

/

  GRANT EXECUTE ON "AXIS"."PAC_CFG_FILE" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_CFG_FILE" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_CFG_FILE" TO "PROGRAMADORESCSI";
