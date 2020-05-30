--------------------------------------------------------
--  DDL for Package Body PAC_LOG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_LOG" AS
   /*************************************************************************
      Traspasa de LOG_CONSULTAS a HISLOG_CONSULTAS  y de LOG_ACTIVIDAD a HISLOG_ACTIVIDAD.
      return    NUMBER         : 0 -> Traspaso realizado correctamente.
                               : 1 -> Error traspasando
   *************************************************************************/
   FUNCTION f_traspaso_log
      RETURN NUMBER IS
      PRAGMA AUTONOMOUS_TRANSACTION;
      v_err          NUMBER;
   BEGIN
      --Comprovem si la instalació disposa de registres de LOGS. Si no s'indica el contrari, l'opció de
      --registre de LOGS està sempre activada.
      IF NVL(f_parinstalacion_n('REG_LOGS'), 1) = 1 THEN
         v_err := 180851;   -- Error insertant al log de l'històric de consultes

         INSERT INTO hislog_consultas
                     (slogconsul, fconsulta, cusuari, corigen, ctipo, tconsulta, tllamada,
                      ftraspaso)
            SELECT l.slogconsul, l.fconsulta, l.cusuari, l.corigen, l.ctipo, l.tconsulta,
                   l.tllamada, f_sysdate
              FROM log_consultas l;

         v_err := 180852;   -- Error esborrant del log de consultes

         DELETE      log_consultas;

-----------------------------------------------------------------------
         v_err := 180853;   -- Error insertant al log de l'històric d'activitats

         INSERT INTO hislog_actividad
                     (slogact, fmovimi, cusuari, torigen, ftraspaso, tmodo, tcolumna, tvalor,
                      tdescripcion, ttipo, fichero)
            SELECT l.slogact, l.fmovimi, l.cusuari, l.torigen, f_sysdate, l.tmodo, l.tcolumna,
                   l.tvalor, l.tdescripcion, l.ttipo,
                   l.fichero   -- BUG 14955 - XPL - Anadir campo TMODO,TCOLUMNA, TVALOR,  TDESCRIPCION,  TTIPO
              FROM log_actividad l;

         v_err := 180854;   -- Error esborrant del log d'activitats

         DELETE      log_actividad;

-----------------------------------------------------------------------
-- Mantis 9692.#6.i.
         v_err := 9001690;   -- Error en insertar a hislog_interfases.

         INSERT INTO hislog_interfases
            SELECT i.*, f_sysdate()
              FROM log_interfases i;

         v_err := 9001702;   -- Error al esborrar de log_interfases.

         DELETE      log_interfases;

-- Mantis 9692.#6.f.
-----------------------------------------------------------------------
         COMMIT;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_LOG.F_TRASPASO_LOG', 1,
                     'error no controlat : ' || SQLCODE, SQLERRM);
         RETURN v_err;
   END f_traspaso_log;

   /*************************************************************************
      Inserta los parámetros de entrada en la tabla LOG_CONSULTAS.
      param in  ptconsulta     : Consulta realizada
      param in  ptllamada      : Nombre de la función desde donde se llama
      param in  pctipo         : Tipo de consulta: 1: Búsqueda, 2:Selección
      param in  pcorigen       : Donde se ha realizado la consulta
      param in  pfconsulta     : Fecha en que se realiza la consulta
      param in  pcusuari       : Usuario que ha realizado la consulta
      return    NUMBER         : 0 -> Finaliza correctamente.
                               : 1 -> Finaliza con error.
   *************************************************************************/
   FUNCTION f_log_consultas(
      ptconsulta IN VARCHAR2,
      ptllamada IN VARCHAR2,
      pctipo IN NUMBER,
      pcorigen IN NUMBER DEFAULT 0,
      pfconsulta IN DATE DEFAULT f_sysdate,
      pcusuari IN VARCHAR2 DEFAULT f_user)
      RETURN NUMBER IS
      PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
      --Comprovem si la instal·lació disposa de registres de LOGS. Si no s'indica el contrari, l'opció de
      --registre de LOGS està sempre activada.
      IF NVL(f_parinstalacion_n('REG_LOGS'), 1) = 1 THEN
         INSERT INTO log_consultas
                     (slogconsul, fconsulta, cusuari, corigen,
                      ctipo, tconsulta, tllamada)
              VALUES (slogconsul.NEXTVAL, pfconsulta, NVL(pcusuari, f_user), pcorigen,
                      pctipo, ptconsulta, ptllamada);
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAG_LOG.F_LOG_CONSULTAS', 1,
                     'error no controlat : ' || SQLCODE, SQLERRM);
         RETURN 180855;   -- Error insertant al log de consultes
   END f_log_consultas;

   /*************************************************************************
      Inserta los parámetros de entrada en la tabla LOG_ACTIVIDAD.
      param in  pcorigen       : Qué opción hemos consultado
      param in  pfconsulta     : Fecha en que se realiza la consulta
      param in  pcusuari       : Usuario que ha realizado la consulta
      param in  ptmodo         : modo acceso pantalla
      return    NUMBER         : 0 -> Finaliza correctamente.
                               : 1 -> Finaliza con error.
   *************************************************************************/
   FUNCTION f_set_log_actividad(
      pslogact IN NUMBER,
      pfecha IN DATE DEFAULT f_sysdate,
      pcusuari IN VARCHAR2 DEFAULT f_user,
      ptorigen IN VARCHAR2,
      ptmodo IN VARCHAR2,
      ptcolumna IN VARCHAR2,
      ptvalor IN VARCHAR2,
      ptdescripcion IN VARCHAR2,
      pttipo IN VARCHAR2,
      pfichero IN VARCHAR2)
      RETURN NUMBER IS
   BEGIN
      INSERT INTO log_actividad
                  (slogact, fmovimi, cusuari, torigen, tmodo, tcolumna,
                   tvalor, tdescripcion, ttipo, fichero)
           VALUES (pslogact, pfecha, NVL(pcusuari, f_user), ptorigen, ptmodo, ptcolumna,
                   ptvalor, ptdescripcion, pttipo, pfichero);

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAG_LOG.F_LOG_ACTIVIDAD', 1,
                     'error no controlat : ' || SQLCODE, SQLERRM);
         RETURN 180856;   -- Error insertant al log d'activitats
   END f_set_log_actividad;

   /*************************************************************************
      Inserta los parámetros de entrada en la tabla LOG_ACTIVIDAD.
      param in  pcorigen       : Qué opción hemos consultado
      param in  pfconsulta     : Fecha en que se realiza la consulta
      param in  pcusuari       : Usuario que ha realizado la consulta
      param in  ptmodo         : modo acceso pantalla
      return    NUMBER         : 0 -> Finaliza correctamente.
                               : 1 -> Finaliza con error.
   *************************************************************************/
   FUNCTION f_log_actividad(
      ptorigen IN VARCHAR2,
      pfecha IN DATE DEFAULT f_sysdate,
      pcusuari IN VARCHAR2 DEFAULT f_user,
      ptmodo IN VARCHAR2,
      piddoc IN NUMBER,
      ptcolumna IN VARCHAR2,
      ptvalor IN VARCHAR2,
      ptdescripcion IN VARCHAR2,
      pttipo IN VARCHAR2,
      pcidioma IN NUMBER,
      pfichero IN VARCHAR2)   --xpl 19042011 bug 15685)
      RETURN NUMBER IS
      PRAGMA AUTONOMOUS_TRANSACTION;
      vtcolumna      VARCHAR2(2000);
      vtvalor        VARCHAR2(2000);
      vtdescripcion  VARCHAR2(2000);
      vttipo         VARCHAR2(2000);
      vnumerr        NUMBER;
      vnpoliza       VARCHAR2(50);
      vsproduc       VARCHAR2(500);
      vslogact       NUMBER;
      vnsinies       VARCHAR2(50);
      vntramit       NUMBER;
      vndocume       NUMBER;
      vafegit        NUMBER := 0;
      vtmodo         VARCHAR2(400);
      vcagente       NUMBER;
   BEGIN
      --Comprovem si la instalació disposa de registres de LOGS. Si no s'indica el contrari, l'opció de
      --registre de LOGS està sempre activada.
      IF NVL(f_parinstalacion_n('REG_LOGS'), 1) = 1 THEN
         vtmodo := ff_desvalorfijo(207, pcidioma, ptmodo);   --Aceso al documento

         IF vtmodo IS NULL THEN
            IF ptmodo IS NULL
               AND pfichero IS NOT NULL THEN
               vtmodo := ff_desvalorfijo(207, pcidioma, 3);   --Si es nulo, por defecto aceso Lectura
            ELSE
               vtmodo := ptmodo;
            END IF;
         END IF;

         vtcolumna := ptcolumna;
         vtvalor := ptvalor;
         vtdescripcion := ptdescripcion;
         vttipo := pttipo;

         IF ptorigen = 'axisgedox' THEN
            IF piddoc IS NOT NULL THEN
               vttipo := pac_axisgedox.categoria(pac_axisgedox.f_get_catdoc(piddoc), pcidioma);
               vtdescripcion := pac_axisgedox.f_get_descdoc(piddoc);
            END IF;

            BEGIN
               SELECT npoliza || ' - ' || ncertif
                 INTO vnpoliza
                 FROM docummovseg d, seguros s
                WHERE iddocgedox = piddoc
                  AND d.sseguro = s.sseguro;

               SELECT slogact.NEXTVAL
                 INTO vslogact
                 FROM DUAL;

               --Insertamos el N Póliza
               vnumerr := f_set_log_actividad(vslogact, pfecha, pcusuari, ptorigen, vtmodo,
                                              f_axis_literales(800242, pcidioma), vnpoliza,
                                              vtdescripcion, vttipo, pfichero);
               --f_axis_literales(9002213, pcidioma) || ' - '
               vafegit := 1;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  BEGIN
                     SELECT nsinies, ntramit, ndocume
                       INTO vnsinies, vntramit, vndocume
                       FROM sin_tramita_documento
                      WHERE iddoc = piddoc;

                     -- vtcolumna := f_axis_literales(9901463, pcidioma);
                     SELECT slogact.NEXTVAL
                       INTO vslogact
                       FROM DUAL;

                     --Insertamos el Num. Siniestro
                     vnumerr := f_set_log_actividad(vslogact, pfecha, pcusuari, ptorigen,
                                                    vtmodo, f_axis_literales(100585, pcidioma),
                                                    vnsinies, vtdescripcion, vttipo, pfichero);
                     vafegit := 1;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        BEGIN
                           SELECT cagente
                             INTO vcagente
                             FROM age_documentos
                            WHERE iddocgedox = piddoc;

                           -- vtcolumna := f_axis_literales(9901463, pcidioma);
                           SELECT slogact.NEXTVAL
                             INTO vslogact
                             FROM DUAL;

                           --Insertamos el Num. Siniestro
                           vnumerr := f_set_log_actividad(vslogact, pfecha, pcusuari, ptorigen,
                                                          vtmodo,
                                                          f_axis_literales(100585, pcidioma),
                                                          vcagente, vtdescripcion, vttipo,
                                                          pfichero);
                           vafegit := 1;
                        EXCEPTION
                           WHEN OTHERS THEN
                              p_tab_error
                                 (f_sysdate, f_user, 'PAC_LOG.F_LOG_ACTIVIDAD', 1,
                                  'error no controlat, buscando datos docs siniestros/pólizas/agentes : '
                                  || SQLCODE || ' - ' || piddoc || ' - ' || vslogact || ' - '
                                  || vttipo || ' - ' || pfichero || ' - ' || vtdescripcion
                                  || ' - ' || ptorigen,
                                  SQLERRM);
                        END;
                  END;
            END;
         END IF;

         IF vafegit = 0 THEN
            SELECT slogact.NEXTVAL
              INTO vslogact
              FROM DUAL;

            vnumerr := f_set_log_actividad(vslogact, pfecha, NVL(pcusuari, f_user), ptorigen,
                                           vtmodo, vtcolumna, vtvalor, vtdescripcion, vttipo,
                                           pfichero);
         END IF;
      --BUG9290-02032009-XVM-Activar log activitat
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAG_LOG.F_LOG_ACTIVIDAD', 1,
                     'error no controlat : ' || SQLCODE, SQLERRM);
         RETURN 180856;   -- Error insertant al log d'activitats
   END f_log_actividad;

   FUNCTION f_log_interfases(
      pcusuario VARCHAR2,
      pfinterf DATE,
      psinterf NUMBER,
      pcinterf VARCHAR2,
      pnresult NUMBER,
      pterror VARCHAR2,
      ptindentificador VARCHAR2,
      pnidentificador VARCHAR2,
      pobservaciones VARCHAR2)
      RETURN NUMBER IS
   BEGIN
      INSERT INTO log_interfases
                  (cusuario, finterf, sinterf, cinterf, nresult, terror,
                   tindentificador, nidentificador, observaciones)
           VALUES (pcusuario, pfinterf, psinterf, pcinterf, pnresult, pterror,
                   ptindentificador, pnidentificador, pobservaciones);

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_CON.F_SET_log_interfases', 1,
                     'error:' || SQLERRM, SQLERRM);
         RETURN -1;
   END f_log_interfases;

   -- Bug 24278 - APD - 12/12/2012 - se crea la funcion
   /*************************************************************************
      Inserta los parámetros de entrada en la tabla LOG_SUP_DIFERIDOS.
      param in  psseguro     : Identificador del seguro
      param in  pctiplog     : Tipo del registro insertado en el LOG
      param in  pttexto         : Texto
      param in  ptllamada      : Nombre de la función desde donde se llama
      param in  pntraza         : Numero de la traza
      return    NUMBER         : 0 -> Finaliza correctamente.
                               : 1 -> Finaliza con error.
   *************************************************************************/
   PROCEDURE p_log_sup_diferidos(
      psseguro IN NUMBER,
      pctiplog IN NUMBER,
      pttexto IN VARCHAR2,
      ptllamada IN VARCHAR2,
      pntraza IN NUMBER) IS
      PRAGMA AUTONOMOUS_TRANSACTION;
      vparam         VARCHAR2(4000)
         := 'psseguro = ' || psseguro || '; pctiplog = ' || pctiplog || '; pttexto = '
            || pttexto || '; ptllamada = ' || ptllamada || '; pntraza = ' || pntraza;
      salir          EXCEPTION;
   BEGIN
      --Comprovem si la instal·lació disposa de registres de LOGS. Si no s'indica el contrari, l'opció de
      --registre de LOGS està sempre activada.
      IF NVL(f_parinstalacion_n('REG_LOGS'), 1) = 1 THEN
         INSERT INTO log_sup_diferidos
                     (slogsup, sseguro, ctiplog, ttexto, tllamada, ntraza)
              VALUES (slogsup.NEXTVAL, psseguro, pctiplog, pttexto, ptllamada, pntraza);
      END IF;

      COMMIT;
   EXCEPTION
      WHEN salir THEN
         ROLLBACK;
         p_tab_error(f_sysdate, f_user, 'PAG_LOG.P_LOG_SUP_DIFERIDOS', 1,
                     SUBSTR(vparam, 1, 500), f_axis_literales(9904627));   --Error insertando en el log de suplementos diferidos.
      WHEN OTHERS THEN
         ROLLBACK;
         p_tab_error(f_sysdate, f_user, 'PAG_LOG.P_LOG_SUP_DIFERIDOS', 1,
                     SUBSTR(vparam, 1, 500), SQLCODE || '.- ' || SQLERRM);
   END p_log_sup_diferidos;
END pac_log;

/

  GRANT EXECUTE ON "AXIS"."PAC_LOG" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_LOG" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_LOG" TO "PROGRAMADORESCSI";
