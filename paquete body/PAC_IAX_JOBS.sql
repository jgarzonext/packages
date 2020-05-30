--------------------------------------------------------
--  DDL for Package Body PAC_IAX_JOBS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IAX_JOBS" AS
/******************************************************************************
   NOMBRE:    PAC_IAX_JOBS
   PROPÓSITO: Funciones para gestion de los jobs

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        12/05/2009   AMC               1. Creación del package.
   2.0        13/07/2015   AQM               2. BUG 35980 : Modificacion de campos
******************************************************************************/
   e_param_error  EXCEPTION;

    /*************************************************************************
      Función que recupera los procesos que hay en la vista DBA_JOBS
      param in pNumJob    : Id. número de job
      param in pFechaDesde : Fecha inicial
      param in pFechaHasta : Fecha final
      param in pBloqueado : Indica si esta bloqueado
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
            || ' pFechaHasta:' || pfechahasta || ', pBloqueado: ' || pbloqueado
            || ' pFuncion:' || pfuncion;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vcursor        sys_refcursor;
      vsquery        VARCHAR2(9000);
   BEGIN
      vcursor := pac_md_jobs.f_get_procesos(pnumjob, pfechadesde, pfechahasta, pbloqueado,
                                            pfuncion, mensajes);
      RETURN vcursor;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN NULL;
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
      v              NUMBER;
   BEGIN
      IF pnumjob IS NULL THEN
         RAISE e_param_error;
      END IF;

      v := pac_md_jobs.f_eliminar(pnumjob, mensajes);
      RETURN v;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
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
      IF pnumjob IS NULL THEN
         RAISE e_param_error;
      END IF;

      RETURN pac_md_jobs.f_ejecutar(pnumjob, mensajes);
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_ejecutar;

   /*************************************************************************
     Función que da de alta un proceso en la cola de trabajo
     param in pFuncion      : Función a ejecutar
     param in Proximafecha    : Fecha de ejecución
     param in pIntervalo : Intervalo
     param in pbloqueado : Si esta bloqueado
     param out pNumJob    : Id. número de job
     param out mensajes  : Mensajes de error
     return              : Devolverá 0 - OK o 1 - KO
   *************************************************************************/
   FUNCTION f_set_altaproceso(
      pfuncion IN VARCHAR2,
      proximafecha IN VARCHAR2,   -- BUG 35980_212027 KJSC 12/08/2015 SE PASA A VARCHAR2 PROXIMAFECHA
      pcintervalo IN VARCHAR2,   -- BUG 35982 - AQM - Tipo de dato
      pbloqueado IN NUMBER,
      pnumjob OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_JOBS.F_set_AltaProceso';
      vparam         VARCHAR2(500)
         := 'parámetros - pFuncion:' || pfuncion || ' Proximafecha:' || proximafecha
            || ' pCIntervalo:' || pcintervalo;
      vpasexec       NUMBER(5) := 1;
   BEGIN
      IF pfuncion IS NULL
         OR proximafecha IS NULL
         --OR pcintervalo IS NULL   -- BUG 35980 - AQM - Comentariar pcintervalo
         OR pbloqueado IS NULL THEN
         RAISE e_param_error;
      END IF;

      RETURN pac_md_jobs.f_set_altaproceso(pfuncion, proximafecha, pcintervalo, pbloqueado,
                                           pnumjob, mensajes);
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
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
      proximafecha IN VARCHAR2,   --BUG 35980_212027 KJSC 12/08/2015 SE PASA A VARCHAR2 PROXIMAFECHA
      pcintervalo IN VARCHAR2,   --BUG 35980-210151 KJSC 16/07/2015 SE PASA A VARCHAR EL INTERVALO
      pbloqueado IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_JOBS.F_set_ModProceso';
      vparam         VARCHAR2(500)
         := 'parámetros - pNumJob:' || pnumjob || ' pFuncion:' || pfuncion || ' Proximafecha:'
            || proximafecha || ' pCIntervalo:' || pcintervalo;
      vpasexec       NUMBER(5) := 1;
   BEGIN
      IF pnumjob IS NULL
         OR pfuncion IS NULL
         OR proximafecha IS NULL
         --OR pcintervalo IS NULL --BUG 35980-210151 KJSC 16/07/2015 SE QUITA EL INTERVALO
         OR pbloqueado IS NULL THEN
         RAISE e_param_error;
      END IF;

      RETURN pac_md_jobs.f_set_modproceso(pnumjob, pfuncion, proximafecha, pcintervalo,
                                          pbloqueado, mensajes);
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_set_modproceso;

   /*************************************************************************
     Función que realiza la modificación del estado "Bloqueado" de un proceso en la cola
     param in pNumJob    : Id. número de job
     param in pBloqueado    : Indica el estado
     param in Proximafecha    : Fecha de ejecución
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
      IF pnumjob IS NULL
         OR pbloqueado IS NULL
         OR proximafecha IS NULL THEN
         RAISE e_param_error;
      END IF;

      RETURN pac_md_jobs.f_set_modbloqueo(pnumjob, pbloqueado, proximafecha, mensajes);
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
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
   BEGIN
      vcursor := pac_md_jobs.f_get_intervalos(mensajes);
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
      param out phora     : Indica la hora
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
      vobjectname    VARCHAR2(500) := 'PAC_IAX_JOBS.F_get_proceso';
      vparam         VARCHAR2(500) := 'parámetros - pNumJob: ' || pnumjob;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vsquery        VARCHAR2(9000);
   BEGIN
      IF pnumjob IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr :=
         pac_md_jobs.f_get_proceso
            (pnumjob, pwhat, pnextdate, pinterval, pbroken, phora,   --BUG 35980_212027 KJSC 12/08/2015 AGREGAR HORA EN LA CREACION Y MODIFICACION DE LOS JOBS
             mensajes);
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_get_proceso;
END pac_iax_jobs;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_JOBS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_JOBS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_JOBS" TO "PROGRAMADORESCSI";
