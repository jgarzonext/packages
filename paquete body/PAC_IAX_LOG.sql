--------------------------------------------------------
--  DDL for Package Body PAC_IAX_LOG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IAX_LOG" AS
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

/*************************************************************************
REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        13/09/2010   XPL                15685: CIV998 - Preparar la aplicación para que registre campos concretos en log_actividad
********************************************************************************/
   /*************************************************************************
      Inserta los parámetros de entrada en la tabla LOG_CONSULTAS.
      param in  ptconsulta     : Consulta realizada
      param in  ptllamada      : Nombre de la función desde donde se llama
      param in  pctipo         : Tipo de consulta: 1: Búsqueda, 2:Selección
      param in  pcorigen       : Donde se ha realizado la consulta
      param out mensajes       : mensajes de error
      return    NUMBER         : 0 -> Finaliza correctamente.
                               : 1 -> Finaliza con error.
   *************************************************************************/
   FUNCTION f_log_consultas(
      ptconsulta IN VARCHAR2,
      ptllamada IN VARCHAR2,
      pctipo IN NUMBER,
      pcorigen IN NUMBER DEFAULT 0,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(50) := 'PAC_LOG.F_LOG_CONSULTAS';
      vparam         VARCHAR2(4000)
         := 'parámetros - ptconsulta=' || ptconsulta || ', ptllamada=' || ptllamada
            || ', pctipo=' || pctipo || ', pcorigen=' || pcorigen;
      vpasexec       NUMBER(2) := 1;
      vret           NUMBER(1);
   BEGIN
      vret := pac_md_log.f_log_consultas(ptconsulta, ptllamada, pctipo, pcorigen, mensajes);
      RETURN vret;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, NULL,
                                           SQLCODE, SQLERRM);
         RETURN 1;
   END f_log_consultas;

   /*************************************************************************
      Inserta los parámetros de entrada en la tabla LOG_ACTIVIDAD.
      param in  pcorigen       : Qué opción hemos consultado
      param in  ptmodo         : modo acceso pantalla
      param out mensajes       : mensajes de error
      return    NUMBER         : 0 -> Finaliza correctamente.
                               : 1 -> Finaliza con error.
   *************************************************************************/
   FUNCTION f_log_actividad(
      ptorigen IN VARCHAR2,
      ptmodo IN VARCHAR2,   --BUG9290-02032009-XVM-Activar log activitat
      piddoc IN NUMBER,   --xpl 13092010 bug 15685
      pcontador IN NUMBER,   --xpl 13092010 bug 15685
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(50) := 'PAC_LOG.F_LOG_ACTIVIDAD';
      vparam         VARCHAR2(4000) := 'parámetros - ptorigen=' || ptorigen;
      vpasexec       NUMBER(2) := 1;
      vret           NUMBER(1);
      vfichero       VARCHAR2(500) := ptmodo;
   BEGIN
      vret := pac_md_log.f_log_actividad(ptorigen, NULL, piddoc, pac_iax_impresion.pimpresion,
                                         pcontador, vfichero, mensajes);
      RETURN vret;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, NULL,
                                           SQLCODE, SQLERRM);
         RETURN 1;
   END f_log_actividad;

   -- Bug 24278 - APD - 12/12/2012 - se crea la funcion
   /*************************************************************************
      Inserta los par�metros de entrada en la tabla LOG_SUP_DIFERIDOS.
      param in  psseguro     : Identificador del seguro
      param in  pctiplog     : Tipo del registro insertado en el LOG
      param in  pttexto         : Texto
      param in  ptllamada      : Nombre de la funci�n desde donde se llama
      param in  pntraza         : Numero de la traza
      param out mensajes       : mensajes de error
      return    NUMBER         : 0 -> Finaliza correctamente.
                               : 1 -> Finaliza con error.
   *************************************************************************/
   PROCEDURE p_log_sup_diferidos(
      psseguro IN NUMBER,
      pctiplog IN NUMBER,
      pttexto IN VARCHAR2,
      ptllamada IN VARCHAR2,
      pntraza IN NUMBER,
      mensajes OUT t_iax_mensajes) IS
      vobject        VARCHAR2(50) := 'PAC_IAX_LOG.P_LOG_SUP_DIFERIDOS';
      vparam         VARCHAR2(4000)
         := 'psseguro = ' || psseguro || '; pctiplog = ' || pctiplog || '; pttexto = '
            || pttexto || '; ptllamada = ' || ptllamada || '; pntraza = ' || pntraza;
      vpasexec       NUMBER(2) := 1;
      vret           NUMBER(1);
   BEGIN
      pac_md_log.p_log_sup_diferidos(psseguro, pctiplog, pttexto, ptllamada, pntraza,
                                     mensajes);
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, NULL,
                                           SQLCODE, SQLERRM);
   END p_log_sup_diferidos;
END pac_iax_log;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_LOG" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_LOG" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_LOG" TO "PROGRAMADORESCSI";
