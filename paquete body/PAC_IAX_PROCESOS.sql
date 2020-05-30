--------------------------------------------------------
--  DDL for Package Body PAC_IAX_PROCESOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IAX_PROCESOS" AS
/******************************************************************************
   NOMBRE:    PAC_IAX_PROCESOS
   PROPÓSITO:

   REVISIONES:
   Ver        Fecha       Autor  Descripción
   ---------  ----------  -----  ------------------------------------
   1.0        22/02/10    JRB     Creació del package.

******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   /***********************************************************************
      Comentarios
      param in  pSPROCES     : NUMBER
      param in  pFPROINI     : DATE
      param in  pCPROCES     : NUMBER
      param in  pNERROR      : NUMBER
      param in  pCUSUARI     : VARCHAR2
      param out mensajes     : T_IAX_MENSAJES
      return                 : ref cursor
   ***********************************************************************/
   FUNCTION f_set_consultaprocesoscab(
      pcempres IN NUMBER,
      psproces IN NUMBER,
      pfproini IN DATE,
      pcproces IN VARCHAR2,
      pnerror IN NUMBER,
      pcusuari IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN t_iax_procesoscab IS
      cur            sys_refcursor;
      procesoss      t_iax_procesoscab;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(250)
         := 'param: - CEMPRES : ' || pcempres || ' - SPROCES : ' || psproces
            || ' - FPROINI : ' || pfproini || ' - CPROCES : ' || pcproces || ' - NERROR : '
            || pnerror || ' - CUSUARI : ' || pcusuari;
      vobject        VARCHAR2(200) := 'PAC_IAX_PROCESOS.F_Set_ConsultaPROCESOSCAB';
   BEGIN
      IF pcempres IS NULL THEN
         procesoss := NULL;
         RAISE e_param_error;
      END IF;

      procesoss := pac_md_procesos.f_set_consultaprocesoscab(pcempres, psproces, pfproini,
                                                             pcproces, pnerror, pcusuari,
                                                             mensajes);
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
   END f_set_consultaprocesoscab;

/***********************************************************************
      Comentarios
      param in out mensajes : T_IAX_MENSAJES
      return                : ref cursor
   ***********************************************************************/
   FUNCTION f_set_consultaprocesoslin(psproces IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN t_iax_procesoslin IS
      cur            sys_refcursor;
      procesoss      t_iax_procesoslin;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(250) := 'param: - SPROCES : ' || psproces;
      vobject        VARCHAR2(200) := 'PAC_IAX_PROCESOS.F_Set_ConsultaPROCESOSLIN';
   BEGIN
      procesoss := pac_md_procesos.f_set_consultaprocesoslin(psproces, mensajes);
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
   END f_set_consultaprocesoslin;
END pac_iax_procesos;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_PROCESOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_PROCESOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_PROCESOS" TO "PROGRAMADORESCSI";
