--------------------------------------------------------
--  DDL for Package Body PAC_MD_JOBS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MD_JOBS" AS
/******************************************************************************
   NOMBRE:    PAC_MD_JOBS
   PROPÓSITO: Funciones para gestion de los jobs

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        12/05/2009   AMC               1. Creación del package.
   2.0        13/07/2015   AQM               2. BUG 35980
******************************************************************************/

   /*************************************************************************
      Función que recupera los procesos que hay en la vista DBA_JOBS
      param in pNumJob    : Id. número de job
      param in pFechaDesde : Fecha inicial
      param in pFechaHasta : Fecha final
      param in pBloqueado : Indica si esta bloqueado
      param in pFuncion   : Nombre del procedimiento
      param out mensajes  : Mensajes de error
      return              : sys_refcursor
   *************************************************************************/
   FUNCTION f_get_procesos(
      pnumjob IN NUMBER,
      pfechadesde IN DATE,
      pfechahasta IN DATE,
      pbloqueado IN VARCHAR2,
      pfuncion IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_JOBS.F_get_procesos';
      vparam         VARCHAR2(500)
         := 'parámetros - pNumJob: ' || pnumjob || ', pFechaDesde: ' || pfechadesde
            || ' pFechaHasta:' || pfechahasta || ', pBloqueado: ' || pbloqueado;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vcursor        sys_refcursor;
      vsquery        VARCHAR2(9000);
      vscondi        VARCHAR2(1000);
      vfuncion       VARCHAR2(1000);   -- BUG 38344/217178 - 29/10/2015 - ACL
   BEGIN
      -- BUG 35980 - 10/07/2015 - AQM - Modificacion de select, adicionando interval
      vsquery :=
         'SELECT job,what,broken,TO_CHAR(last_date,''DD/MM/YY-HH24:MI:SS'') last_date,TO_CHAR(next_date,''DD/MM/YY-HH24:MI:SS'') next_date, replace(interval,''null'','''') interval, failures'
         || ' FROM user_jobs ';

      IF pnumjob IS NOT NULL THEN
         IF vscondi IS NULL THEN
            vscondi := ' WHERE JOB = ' || pnumjob;
         ELSE
            vscondi := vscondi || ' and JOB = ' || pnumjob;
         END IF;
      END IF;

      IF pfechadesde IS NOT NULL THEN
         IF vscondi IS NULL THEN
            vscondi := ' WHERE trunc(LAST_DATE) >= TO_DATE(''' || TO_CHAR(pfechadesde)
                       || ''') ';
         ELSE
            vscondi := vscondi || ' AND trunc(LAST_DATE) >= TO_DATE('''
                       || TO_CHAR(pfechadesde) || ''') ';
         END IF;
      END IF;

      IF pfechahasta IS NOT NULL THEN
         IF vscondi IS NULL THEN
            vscondi := ' WHERE trunc(LAST_DATE) <= TO_DATE(''' || TO_CHAR(pfechahasta)
                       || ''') ';
         ELSE
            vscondi := vscondi || ' AND trunc(LAST_DATE) <= TO_DATE('''
                       || TO_CHAR(pfechahasta) || ''') ';
         END IF;
      END IF;

      IF pbloqueado IS NOT NULL THEN
         IF vscondi IS NULL THEN
            vscondi := ' WHERE BROKEN = ''' || pbloqueado || '''';
         ELSE
            vscondi := vscondi || ' and BROKEN = ''' || pbloqueado || '''';
         END IF;
      END IF;

      IF pfuncion IS NOT NULL THEN
         -- Inicio BUG 38344/217178 - 29/10/2015 - ACL
         vfuncion := pfuncion;
         vfuncion := REPLACE(vfuncion, CHR(39), CHR(39) || CHR(39));

         IF vscondi IS NULL THEN
            vscondi := ' WHERE upper(WHAT) like ''%' || UPPER(vfuncion) || '%''';
         ELSE
            vscondi := vscondi || ' and upper(WHAT) like ''%' || UPPER(vfuncion) || '%''';
         -- Fin BUG 38344/217178 - 29/10/2015 - ACL
         END IF;
      END IF;

      vsquery := vsquery || ' ' || vscondi || ' order by job desc';
      p_tab_error(f_sysdate, f_user, 'pac_md_jobs', 1, vsquery, SQLERRM);
      vcursor := pac_md_listvalores.f_opencursor(vsquery, mensajes);
      RETURN vcursor;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
   END f_get_procesos;

   /*************************************************************************
     Función que elimina un proceso de la cola
     param in pNumJob    : Id. número de job
     param out mensajes  : Mensajes de error
     return              : Devolverá 0 - OK o 1 - KO
   *************************************************************************/
   FUNCTION f_eliminar(pnumjob IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_JOBS.F_Eliminar';
      vparam         VARCHAR2(500) := 'parámetros - pNumJob: ' || pnumjob;
      vpasexec       NUMBER(5) := 1;
   BEGIN
      DBMS_JOB.remove(pnumjob);
      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_md_jobs', 1, 'sqlcode:' || SQLCODE, SQLERRM);

         IF SQLCODE = -23421 THEN
            p_tab_error(f_sysdate, f_user, 'pac_md_jobs', 2, ' entra sqlcode:' || SQLCODE,
                        SQLERRM);
            pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 109905, vpasexec, vparam,
                                              psqcode => SQLCODE, psqerrm => SQLERRM);
         ELSE
            pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec,
                                              vparam, psqcode => SQLCODE, psqerrm => SQLERRM);
         END IF;

         ROLLBACK;
         RETURN 1;
   END f_eliminar;

   /*************************************************************************
     Función que ejecuta al momento un job
     param in pNumJob    : Id. número de job
     param out mensajes  : Mensajes de error
     return              : Devolverá 0 - OK o 1 - KO
   *************************************************************************/
   FUNCTION f_ejecutar(pnumjob IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_JOBS.F_Ejecutar';
      vparam         VARCHAR2(500) := 'parámetros - pNumJob: ' || pnumjob;
      vpasexec       NUMBER(5) := 1;
   BEGIN
      DBMS_JOB.run(pnumjob);
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_ejecutar;

   /*************************************************************************
     Función que da de alta un proceso en la cola de trabajo
     param in pFuncion   : Función a ejecutar
     param in Proximafecha   : Fecha de ejecución
     param in pIntervalo : Intervalo
     param in pbloqueado : Si esta bloqueado
     param out pNumJob    : Id. número de job
     param out mensajes  : Mensajes de error
     return              : Devolverá 0 - OK o 1 - KO
   *************************************************************************/
   FUNCTION f_set_altaproceso(
      pfuncion IN VARCHAR2,
      proximafecha IN VARCHAR2,   --BUG 35980_212027 KJSC 12/08/2015 SE PASA A VARCHAR PROXIMAFECHA
      pcintervalo IN VARCHAR2,   -- BUG 35980 - 10/07/2015 - AQM
      pbloqueado IN NUMBER,
      pnumjob OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_JOBS.F_set_AltaProceso';
      vparam         VARCHAR2(500)
         := 'parámetros - pFuncion:' || pfuncion || ' Proximafecha:' || proximafecha
            || ' pCIntervalo:' || pcintervalo || ' pbloqueado:' || pbloqueado;
      vpasexec       NUMBER(5) := 1;
      vvalor         VARCHAR2(400);
      v_error        NUMBER;
   BEGIN
      IF TO_DATE(proximafecha, 'DD/MM/YYYY HH24:MI:SS ') < TRUNC(f_sysdate) THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000147, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
      END IF;

       -- INI BUG 35980 - 10/07/2015 - AQM
      --BUG 35980-210151 KJSC 16/07/2015 SE PASA A VARCHAR EL INTERVALO
      /*BEGIN
         SELECT valor
           INTO vvalor
           FROM job_intervalos
          WHERE valor = pcintervalo;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            vvalor := NULL;
      END;*/

      -- FIN BUG 35980 - 10/07/2015 - AQM
      DBMS_JOB.submit(pnumjob, pfuncion, TO_DATE(proximafecha, 'DD/MM/YYYY HH24:MI:SS '),
                      pcintervalo);   --BUG 35980_212027 KJSC 12/08/2015 AGREGAR HORA EN LA CREACION Y MODIFICACION DE LOS JOBS

      IF pbloqueado = 1 THEN
         v_error := f_set_modbloqueo(pnumjob, TRUE,
                                     TO_DATE(proximafecha, 'DD/MM/YYYY HH24:MI:SS '),
                                     mensajes);
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_set_altaproceso;

   /*************************************************************************
     Función que realiza modificaciones en los procesos que hay en cola
     param in pNumJob    : Id. número de job
     param in pFuncion   : Función a ejecutar
     param in Proximafecha   : Fecha de ejecución
     param in pIntervalo : Intervalo
     param in pbloqueado : Si esta bloqueado
     param out mensajes  : Mensajes de error
     return              : Devolverá 0 - OK o 1 - KO
   *************************************************************************/
   FUNCTION f_set_modproceso(
      pnumjob IN NUMBER,
      pfuncion IN VARCHAR2,
      proximafecha IN VARCHAR2,   --BUG 35980_212027 KJSC 12/08/2015 SE PASA A VARCHAR PROXIMAFECHA
      pcintervalo IN VARCHAR2,   --BUG 35980-210151 KJSC 16/07/2015 SE PASA A VARCHAR EL INTERVALO
      pbloqueado IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_JOBS.F_set_ModProceso';
      vparam         VARCHAR2(500)
         := 'parámetros - pNumJob:' || pnumjob || ' pFuncion:' || pfuncion || ' Proximafecha:'
            || proximafecha || ' pCIntervalo:' || pcintervalo;
      vpasexec       NUMBER(5) := 1;
      vvalor         VARCHAR2(400);
      v_error        NUMBER;
   BEGIN
       --BUG 35980-210151 KJSC 16/07/2015 SE PASA A VARCHAR EL INTERVALO
      /*BEGIN
         SELECT valor
           INTO vvalor
           FROM job_intervalos
          WHERE VALOR = NVL(pcintervalo,'1');
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            vvalor := '1';
      END;*/

      --BUG 35980_212027 KJSC 12/08/2015 AGREGAR HORA EN LA CREACION Y MODIFICACION DE LOS JOBS
      DBMS_JOB.CHANGE(pnumjob, pfuncion, TO_DATE(proximafecha, 'DD/MM/YYYY HH24:MI:SS '),
                      pcintervalo);

      IF pbloqueado = 1 THEN
         v_error := f_set_modbloqueo(pnumjob, TRUE,
                                     TO_DATE(proximafecha, 'DD/MM/YYYY HH24:MI:SS '),
                                     mensajes);
      ELSE
         v_error := f_set_modbloqueo(pnumjob, FALSE,
                                     TO_DATE(proximafecha, 'DD/MM/YYYY HH24:MI:SS '),
                                     mensajes);
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_set_modproceso;

   /*************************************************************************
     Función que realiza la modificación del estado "Bloqueado" de un proceso en la cola
     param in pNumJob    : Id. número de job
     param in pBloqueado  : Indica el estado
     param in Proximafecha   : Fecha de ejecución
     param out mensajes  : Mensajes de error
     return              : Devolverá 0 - OK o 1 - KO
   *************************************************************************/
   FUNCTION f_set_modbloqueo(
      pnumjob IN NUMBER,
      pbloqueado IN BOOLEAN,
      proximafecha IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_JOBS.F_set_ModBloqueo';
      vparam         VARCHAR2(500)
                     := 'parámetros - pNumJob:' || pnumjob || ' Proximafecha:' || proximafecha;
      vpasexec       NUMBER(5) := 1;
   BEGIN
      DBMS_JOB.broken(pnumjob, pbloqueado, proximafecha);
      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_set_modbloqueo;

   /*************************************************************************
     Función que recupera los tipos de intervalos que se pueden utilizar en un proceso
     param out mensajes  : Mensajes de error
     return              : sys_refcursor
   *************************************************************************/
   FUNCTION f_get_intervalos(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_JOBS.F_get_Intervalos';
      vparam         VARCHAR2(500) := '';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vcursor        sys_refcursor;
      vsquery        VARCHAR2(9000);
      vcidioma       NUMBER;
   BEGIN
      vcidioma := pac_md_common.f_get_cxtidioma();
      vsquery := 'SELECT CINTERVALO,SLITERA,F_AXIS_LITERALES(slitera,' || vcidioma
                 || ') TLITERA,VALOR' || ' FROM JOB_INTERVALOS ORDER BY CINTERVALO';
      vcursor := pac_md_listvalores.f_opencursor(vsquery, mensajes);
      RETURN vcursor;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
   END f_get_intervalos;

   /*************************************************************************
      Función que recupera los procesos que hay en la vista DBA_JOBS
      param in pNumJob    : Id. número de job
      param out pWhat     : función
      param out pNextdate : proxima fecha
      param out pBroken   : Indica si esta bloqueado
      param out mensajes  : Mensajes de error
      return              : number
   *************************************************************************/
   FUNCTION f_get_proceso(
      pnumjob IN NUMBER,
      pwhat OUT VARCHAR2,
      pnextdate OUT DATE,
      pinterval OUT VARCHAR2,
      pbroken OUT NUMBER,
      phora OUT VARCHAR2,   --BUG 35980_212027 KJSC 12/08/2015 AGREGAR HORA EN LA CREACION Y MODIFICACION DE LOS JOBS
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_JOBS.F_get_proceso';
      vparam         VARCHAR2(500) := 'parámetros - pNumJob: ' || pnumjob;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vsquery        VARCHAR2(9000);
   BEGIN
      SELECT v.what, TRUNC(v.next_date),
                                        --j.cintervalo,
                                        REPLACE(v.INTERVAL, 'null', '') INTERVAL,
             DECODE(v.broken, 'N', 0, 'Y', 1) broken,
             SUBSTR
                ((TO_CHAR(v.next_date, 'DD/MM/YYYY HH24:MI ')), 12)   --BUG 35980_212027 KJSC 12/08/2015 AGREGAR HORA EN LA CREACION Y MODIFICACION DE LOS JOBS
        INTO pwhat, pnextdate, pinterval,
             pbroken,
             phora
        FROM user_jobs v
       --, job_intervalos j
      WHERE  job = pnumjob;

      --  AND v.INTERVAL = j.valor(+)
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_get_proceso;
END pac_md_jobs;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_JOBS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_JOBS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_JOBS" TO "PROGRAMADORESCSI";
