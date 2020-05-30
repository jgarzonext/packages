--------------------------------------------------------
--  DDL for Package Body PAC_IAX_FIC_PROCESOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IAX_FIC_PROCESOS" AS
/******************************************************************************
   NOMBRE:       PAC_IAX_FIC_PROCESOS
   PROPÓSITO: Nuevo paquete de la capa IAX que tendrá las funciones para la gestión de procesos del gestor de informes.
              Controlar todos posibles errores con PAC_IOBJ_MNSAJES.P_TRATARMENSAJE


   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        16/06/2009   JMG                1. Creación del package.
******************************************************************************/

   /*F_get_Ficprocesos
   Nueva función de la capa IAX que devolverá los procesos del gestor de informes

   Parámetros

   1. pcempres IN NUMBER
   2. psproces IN NUMBER
   3. ptgestor IN VARCHAR2
   4. ptformat IN VARCHAR2
   5. ptanio   IN VARCHAR2
   6. ptmes    IN VARCHAR2
   7. ptdiasem IN VARCHAR2
   8. pcusuari IN VARCHAR2
   9. pfproini IN DATE
   10. mensajes OUT T_IAX_MENSAJES

   */
   FUNCTION f_get_ficprocesos(
      pcempres IN NUMBER,
      psproces IN NUMBER,
      ptgestor IN VARCHAR2,
      ptformat IN VARCHAR2,
      ptanio IN VARCHAR2,
      ptmes IN VARCHAR2,
      ptdiasem IN VARCHAR2,
      pnerror IN NUMBER,
      pcusuari IN VARCHAR2,
      pfproini IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      t_proc         sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'pcempres=' || pcempres || ' psproces=' || psproces || ' ptgestor=' || ptgestor
            || ' ptformat=' || ptformat || ' ptanio=' || ptanio || ' ptmes=' || ptmes
            || ' ptdiasem=' || ptdiasem || ' pnerror=' || pnerror || ' pcusuari=' || pcusuari
            || ' pfproini=' || pfproini;
      vobject        VARCHAR2(200) := 'PAC_IAX_FIC_PROCESOS.F_get_Ficprocesos';
   BEGIN
      IF pcempres IS NULL THEN
         RAISE e_param_error;
      END IF;

      t_proc := pac_md_fic_procesos.f_get_ficprocesos(pcempres, psproces, ptgestor, ptformat,
                                                      ptanio, ptmes, ptdiasem, pnerror,
                                                      pcusuari, pfproini, mensajes);
      RETURN t_proc;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN t_proc;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN t_proc;
   END f_get_ficprocesos;

/*******************************************************************************
           f_get_ficprocesosdet
     Nueva función de la capa MD que devolverá el detalle de los procesos del gestor de informes

     Parámetros

     2. psproces IN NUMBER
     3. mensajes OUT T_IAX_MENSAJES

     Retorna : objeto type t_iax_procesoslin.
********************************************************************************/
   FUNCTION f_get_ficprocesosdet(psproces IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN t_iax_fic_procesosdet IS
      cur            sys_refcursor;
      procesoss      t_iax_fic_procesosdet;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(250) := 'param: - SPROCES : ' || psproces;
      vobject        VARCHAR2(200) := 'PAC_IAX_FIC_PROCESOS.F_get_ficprocesosdet';
   BEGIN
      procesoss := pac_md_fic_procesos.f_get_ficprocesosdet(psproces, mensajes);
      vpasexec := 2;
      RETURN procesoss;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_ficprocesosdet;
END pac_iax_fic_procesos;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_FIC_PROCESOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_FIC_PROCESOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_FIC_PROCESOS" TO "PROGRAMADORESCSI";
