--------------------------------------------------------
--  DDL for Package Body PAC_IAX_COMMON
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IAX_COMMON" AS
/******************************************************************************
   NOMBRE:       PAC_IAX_COMMON
   PROP¿SITO:  Funciones de uso general para el IAxis

   REVISIONES:
   Ver        Fecha        Autor             Descripci¿n
   ---------  ----------  ---------------  ------------------------------------
   1.0        02/08/2007   ACC                1. Creaci¿n del package.
   2.0        26/09/2007   ACC                2. Funciones para recuperar
                                                 partes objeto
   3.0        19/10/2007   ACC                3. Funciones para recuperar y
                                                 asignar varibles de contexto
   4.0        21/11/2007   ACC                4. Nueva funcionalidades
   5.0        25/01/2008   ACC                5. Reorganizar package
   6.0        01/12/2009   AMC                6. bug 11308.Se a¿ade la funci¿n f_extrae_npoliza
   7.0        27/08/2010   FAL                2. 0015750: CRE998 - Modificacions m¿dul domiciliacions
******************************************************************************/

   --Define las varibles tipos contexto
   cxtidioma      VARCHAR2(100) := 'IAX_IDIOMA';
   cxtusuario     VARCHAR2(100) := 'IAX_USUARIO';
   cxtagente      VARCHAR2(100) := 'IAX_AGENTE';
   cxtempresa     VARCHAR2(100) := 'IAX_EMPRESA';
   cxtagenteprod  VARCHAR2(100) := 'IAX_AGENTEPROD';
   --
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;
   msgintern      t_iax_mensajes;

   /*************************************************************************
      Establece una variable de contexto
      param in clave         : clave del contexto
      param in valor         : valor del contexto
      param in out mensajes  : colecci¿n de mensajes
   *************************************************************************/
   PROCEDURE p_set_contextparam(
      clave IN VARCHAR2,
      valor IN VARCHAR2,
      mensajes OUT t_iax_mensajes) IS
      pctxt          VARCHAR2(100) := pac_md_common.f_get_parinstalacion_t('CONTEXT_USER');
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(500) := 'clave=' || clave || ' valor=' || valor;
      vobject        VARCHAR2(200) := 'PAC_IAX_COMMON.P_Set_ContextParam';
   BEGIN
      pac_md_common.p_contextoasignaparametro(pctxt, clave, valor, mensajes);
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
   END p_set_contextparam;

   /*************************************************************************
      Devuelve valor variable de contexto
      param in clave         : clave del contexto
      param in out mensajes  : colecci¿n de mensajes
      return                 : valor del contexto
   *************************************************************************/
   FUNCTION f_get_contextparam(clave IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN VARCHAR2 IS
      pctxt          VARCHAR2(100) := pac_md_common.f_get_parinstalacion_t('CONTEXT_USER');
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(500) := 'clave=' || clave;
      vobject        VARCHAR2(200) := 'PAC_IAX_COMMON.F_Get_ContextParam';
   BEGIN
      RETURN pac_md_common.f_contextovalorparametro(pctxt, clave, mensajes);
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
   END f_get_contextparam;

   /*************************************************************************
      Define el idioma como contexto
      param in valor         : valor del contexto
   *************************************************************************/
   PROCEDURE p_set_cxtidioma(valor IN NUMBER) IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(500) := 'valor=' || valor;
      vobject        VARCHAR2(200) := 'PAC_IAX_COMMON.P_Set_CXTIdioma';
   BEGIN
      p_set_contextparam(cxtidioma, valor, msgintern);
      vpasexec := 2;
      --Asignaci¿ context especial per F_USU_IDIOMA
      p_set_contextparam('usu_idioma', valor, msgintern);
   --
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(msgintern, vobject, 1000005, vpasexec, vparam);
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(msgintern, vobject, 1000006, vpasexec, vparam);
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(msgintern, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
   END p_set_cxtidioma;

   /*************************************************************************
      Recupera el idioma como contexto
      return   : valor del contexto
   *************************************************************************/
   FUNCTION f_get_cxtidioma
      RETURN NUMBER IS
      vtmp           VARCHAR2(10);
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(500) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAX_COMMON.F_Get_CXTIdioma';
   BEGIN
      vtmp := f_get_contextparam(cxtidioma, msgintern);
      vtmp := pac_md_common.checkidioma(vtmp);
      RETURN NVL(vtmp, 0);
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(msgintern, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(msgintern, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(msgintern, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_cxtidioma;

   /*************************************************************************
      Define el usuario como contexto
      param in valor  : valor del contexto
   *************************************************************************/
   PROCEDURE p_set_cxtusuario(valor IN VARCHAR2) IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(500) := 'valor=' || valor;
      vobject        VARCHAR2(200) := 'PAC_IAX_COMMON.P_Set_CXTUsuario';
   BEGIN
      p_set_contextparam(cxtusuario, valor, msgintern);
      vpasexec := 2;
      --Asignaci¿ context especial per F_USER
      p_set_contextparam('nombre', valor, msgintern);
   --
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(msgintern, vobject, 1000005, vpasexec, vparam);
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(msgintern, vobject, 1000006, vpasexec, vparam);
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(msgintern, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
   END p_set_cxtusuario;

   /*************************************************************************
      Recupera el usuario como contexto
      return   : valor del contexto
   *************************************************************************/
   FUNCTION f_get_cxtusuario
      RETURN VARCHAR2 IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(500) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAX_COMMON.P_Set_CXTUsuario';
   BEGIN
      RETURN f_get_contextparam(cxtusuario, msgintern);
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(msgintern, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(msgintern, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(msgintern, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_cxtusuario;

   /*************************************************************************
      Define el agente como contexto
      param in valor  : valor del contexto
   *************************************************************************/
   PROCEDURE p_set_cxtagente(valor IN NUMBER) IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(500) := 'valor=' || valor;
      vobject        VARCHAR2(200) := 'PAC_IAX_COMMON.P_Set_CXTAgente';
   BEGIN
      p_set_contextparam(cxtagente, valor, msgintern);
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(msgintern, vobject, 1000005, vpasexec, vparam);
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(msgintern, vobject, 1000006, vpasexec, vparam);
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(msgintern, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
   END p_set_cxtagente;

   /*************************************************************************
      Recupera el agente como contexto
      return   : valor del contexto
   *************************************************************************/
   FUNCTION f_get_cxtagente
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(500) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAX_COMMON.P_Set_CXTAgente';
   BEGIN
      RETURN f_get_contextparam(cxtagente, msgintern);
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(msgintern, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(msgintern, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(msgintern, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_cxtagente;

   /*************************************************************************
      Define el agente para producci¿ncomo contexto
      param in valor  : valor del contexto
   *************************************************************************/
   PROCEDURE p_set_cxtagenteprod(valor IN NUMBER) IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(500) := 'valor=' || valor;
      vobject        VARCHAR2(200) := 'PAC_IAX_COMMON.P_Set_CXTAgenteProd';
   BEGIN
      p_set_contextparam(cxtagenteprod, valor, msgintern);
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(msgintern, vobject, 1000005, vpasexec, vparam);
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(msgintern, vobject, 1000006, vpasexec, vparam);
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(msgintern, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
   END p_set_cxtagenteprod;

   /*************************************************************************
      Recupera el agente para producci¿n como contexto
      return   : valor del contexto
   *************************************************************************/
   FUNCTION f_get_cxtagenteprod
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(500) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAX_COMMON.F_Get_CXTAgenteProd';
   BEGIN
      RETURN f_get_contextparam(cxtagenteprod, msgintern);
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(msgintern, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(msgintern, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(msgintern, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_cxtagenteprod;

   /*************************************************************************
      Define la empresa como contexto
      param in valor  : valor del contexto
   *************************************************************************/
   PROCEDURE p_set_cxtempresa(valor IN NUMBER) IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(500) := 'valor=' || valor;
      vobject        VARCHAR2(200) := 'PAC_IAX_COMMON.P_Set_CXTEmpresa';
   BEGIN
      p_set_contextparam(cxtempresa, valor, msgintern);
      vpasexec := 2;
      --Asignaci¿ context especial per f_empresel
      p_set_contextparam('empresasel', valor, msgintern);
      vpasexec := 3;
      p_set_contextparam('empresa', valor, msgintern);
      vpasexec := 4;
      p_set_contextparam('multiempres', valor, msgintern);
   --
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(msgintern, vobject, 1000005, vpasexec, vparam);
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(msgintern, vobject, 1000006, vpasexec, vparam);
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(msgintern, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
   END p_set_cxtempresa;

   /*************************************************************************
      Recupera la empresa como contexto
      return   : valor del contexto
   *************************************************************************/
   FUNCTION f_get_cxtempresa
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(500) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAX_COMMON.P_Set_CXTEmpresa';
   BEGIN
      RETURN f_get_contextparam(cxtempresa, msgintern);
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(msgintern, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(msgintern, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(msgintern, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_cxtempresa;

   /************************************************************************
      Indica si el usuario actual puede hacer un cambio de agente en la
      emisi¿n de p¿liza
      return   :  1 puede cambiar el agente para emitir p¿liza
                  0 el agente es l'actual
   ************************************************************************/
   FUNCTION f_permitecagente
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(500) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAX_COMMON.F_PermiteCAgente';
   BEGIN
      RETURN 1;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(msgintern, vobject, 1000005, vpasexec, vparam);
         RETURN 0;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(msgintern, vobject, 1000006, vpasexec, vparam);
         RETURN 0;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(msgintern, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 0;
   END f_permitecagente;

   /***********************************************************************
      Indica si el campo para identificar una persona en host puede
      ser visible
      return   : 1 indica que el campo se debe mostrar
                 0 el campo se debe ocultar
   ***********************************************************************/
   FUNCTION f_permitirsip
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(500) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAX_COMMON.F_PermitirSIP';
   BEGIN
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(msgintern, vobject, 1000005, vpasexec, vparam);
         RETURN 0;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(msgintern, vobject, 1000006, vpasexec, vparam);
         RETURN 0;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(msgintern, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 0;
   END f_permitirsip;

   /***********************************************************************
      Indica si desde la pantalla de busqueda de personas se puede dar
      de alta una nueva persona
      return   : 1 indica se puede dar de alta
                 0 no puede dar de alta
   ***********************************************************************/
   FUNCTION f_permitirnuevapersona
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(500) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAX_COMMON.F_PermitirNuevaPersona';
   BEGIN
      RETURN 1;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(msgintern, vobject, 1000005, vpasexec, vparam);
         RETURN 0;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(msgintern, vobject, 1000006, vpasexec, vparam);
         RETURN 0;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(msgintern, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 0;
   END f_permitirnuevapersona;

   /***********************************************************************
      Dado un n¿mero de p¿liza devuelve el c¿digo del ramo
      param in pnpoliza     : n¿mero p¿liza
      param in out mensajes : mensajes error
      return                : c¿digo ramo o nulo si se produce error
   ***********************************************************************/
   FUNCTION f_get_polramo(pnpoliza IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      cram           NUMBER := NULL;
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(500) := 'pnpoliza=' || pnpoliza;
      vobject        VARCHAR2(200) := 'PAC_IAX_COMMON.F_Get_PolRamo';
   BEGIN
      cram := pac_md_common.f_get_polramo(pnpoliza, mensajes);
      RETURN cram;
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
   END f_get_polramo;

   /***********************************************************************
      Dado un c¿digo de seguro
      param in psseguro     : c¿digo seguro
      param in pmode        : mode consulta EST POL
      param out onpoliza    : n¿mero p¿liza
      param out oncertif    : n¿mero certificado
      param in out mensajes : mensajes error
   ***********************************************************************/
   PROCEDURE f_get_npoliza(
      psseguro IN NUMBER,
      pmode IN VARCHAR2,
      onpoliza OUT NUMBER,
      oncertif OUT NUMBER,
      mensajes OUT t_iax_mensajes) IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'psseguro=' || psseguro;
      vobject        VARCHAR2(200) := 'PAC_IAX_COMMON.F_Get_PolRamo';
   BEGIN
      pac_md_common.f_get_npoliza(psseguro, pmode, onpoliza, oncertif, mensajes);
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
   END f_get_npoliza;

   /***********************************************************************
      Formatea la cuenta bancaria
      param in ctipban : tipo cuenta
      param in cbancar : cuenta bancaria
      return           : cuenta formateada si ha podido aplicar el formato
                         sino devuelve la cuenta
   ***********************************************************************/
   FUNCTION f_formatccc(ctipban IN NUMBER, cbancar IN VARCHAR2)
      RETURN VARCHAR2 IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(500) := 'ctipban=' || ctipban || ' cbancar=' || cbancar;
      vobject        VARCHAR2(200) := 'PAC_IAX_COMMON.F_FormatCCC';
      RESULT         VARCHAR2(500);
      nerr           NUMBER;
      mensajes       t_iax_mensajes;
   BEGIN
      RESULT := pac_md_common.f_formatccc(ctipban, cbancar);
      RETURN RESULT;
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
   END f_formatccc;

   /***********************************************************************
       Devuelve el entorno de trabajo: test, validaci¿n, producci¿n..
       param in out mensajes : mensajes error
       return                : varchar2

       llamada a la funci¿n F_Get_Parinstalacion pasando c¿digo de
       parametro para que devuelva el valor del parametro de entorno
    ***********************************************************************/
   FUNCTION f_get_entorno(mensajes OUT t_iax_mensajes)
      RETURN VARCHAR2 IS
      vpasexec       NUMBER := 1;
      vobject        VARCHAR2(200) := 'PAC_IAX_COMMON.F_Get_Entorno';
      vparam         VARCHAR2(500) := NULL;
   BEGIN
      RETURN pac_md_common.f_get_parinstalacion_t('ENTORNO');
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
   END f_get_entorno;

   /***********************************************************************
      Devuelve el modo de trabajo: POL, EST
      param in out mensajes : mensajes error
      return                : varchar2
   ***********************************************************************/
   FUNCTION f_get_ptablas(pmodo IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN VARCHAR2 IS
      vpasexec       NUMBER := 1;
      vobject        VARCHAR2(200) := 'PAC_IAX_COMMON.F_Get_ptablas';
      vparam         VARCHAR2(500) := 'pmodo : ' || pmodo;
   BEGIN
      RETURN pac_md_common.f_get_ptablas(pmodo, mensajes);
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
   END f_get_ptablas;

    -- BUG 8339
    /***************************************************************************
     Funci¿n que retornar¿ el c¿digo de proceso temporal para la gesti¿n del proceso de cartera.
     Par¿metros:
      Salida :
       Mensajes   OUT T_IAX_MENSAJES
     Retorna: el n¿mero de la secuencia
   *****************************************************************************/
   FUNCTION f_get_proceso(psproces OUT NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER;
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(500) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAX_COMMON.F_GET_PROCESO';
   BEGIN
      -- Deber¿ realizar una llamada a la funci¿n de la capa md pac_md_common.f_get_proceso que nos retornar¿ el c¿digo de proceso
      -- para la pantalla
      vnumerr := pac_md_common.f_get_proceso(psproces, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN(vnumerr);
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(msgintern, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(msgintern, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(msgintern, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_get_proceso;

-- Bug 11308 - 01/12/2009 - AMC
   /*************************************************************************
      FUNCTION f_extrae_npoliza
        Extrae el n¿ de poliza del c¿digo de cuenta interno
        param in pncontinter   : C¿digo de cuenta interno
        return             : N¿ poliza
   *************************************************************************/
   FUNCTION f_extrae_npoliza(pncontinter IN VARCHAR2)
      RETURN NUMBER IS
      vsprocar       NUMBER;
      vpasexec       NUMBER;
      vparam         VARCHAR2(500) := NULL;
      vobject        VARCHAR2(200) := 'f_extrae_npoliza';
      vnpoliza       NUMBER;
   BEGIN
      IF pncontinter IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnpoliza := pac_md_common.f_extrae_npoliza(pncontinter);

      IF vnpoliza IS NULL THEN
         RAISE e_object_error;
      END IF;

      RETURN vnpoliza;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(msgintern, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(msgintern, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(msgintern, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_extrae_npoliza;

--Fi Bug 11308 - 01/12/2009 - AMC

--Ini CONF-219 AP
   /*************************************************************************
      FUNCTION f_extrae_npoliza
        Extrae el n¿ de poliza del n¿mero de contrato (pregunta 4097)
        param in pncontinter   : N¿mero de contrato
        return             : N¿ poliza
   *************************************************************************/
   FUNCTION F_EXTRAE_NPOLCONTRA(pncontrato IN VARCHAR2)
     RETURN NUMBER IS
      vsprocar       NUMBER;
      vpasexec       NUMBER;
      vparam         VARCHAR2(500) := NULL;
      vobject        VARCHAR2(200) := 'f_extrae_npolcontra';
      vnpoliza       NUMBER;
   BEGIN
      IF pncontrato IS NULL THEN
         RAISE e_param_error;
      END IF;
      vnpoliza := pac_md_common.F_EXTRAE_NPOLCONTRA(pncontrato);

      IF vnpoliza IS NULL THEN
         RAISE e_object_error;
      END IF;

      RETURN vnpoliza;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(msgintern, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(msgintern, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(msgintern, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END F_EXTRAE_NPOLCONTRA;

--Fi CONF-219 AP

   -- Bug 15750 - FAL - 27/08/2010 - Permitir seleccionar varios productos en el proceso domiciliaci¿n
    /***************************************************************************
     Funci¿n que retornar¿ el c¿digo de proceso temporal para la gesti¿n del proceso de domiciliaci¿n.
     Par¿metros:
      Salida :
       Mensajes   OUT T_IAX_MENSAJES
     Retorna: el n¿mero de la secuencia
   *****************************************************************************/
   FUNCTION f_get_procesodom(psproces OUT NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER;
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(500) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAX_COMMON.F_GET_PROCESODOM';
   BEGIN
      -- Deber¿ realizar una llamada a la funci¿n de la capa md pac_md_common.f_get_proceso que nos retornar¿ el c¿digo de proceso
      -- para la pantalla
      vnumerr := pac_md_common.f_get_procesodom(psproces, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN(vnumerr);
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(msgintern, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(msgintern, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(msgintern, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_get_procesodom;

-- FI Bug 15750 - FAL - 27/08/2010 - Permitir seleccionar varios productos en el proceso domiciliaci¿n
   FUNCTION f_obtener_formatos_moneda(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vsprocar       NUMBER;
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(500) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAX_COMMON.f_obtener_formatos_moneda';
      cur            sys_refcursor;
   BEGIN
      cur := pac_md_common.f_obtener_formatos_moneda(mensajes);

      IF cur IS NULL THEN
         RAISE e_object_error;
      END IF;

      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(msgintern, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(msgintern, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(msgintern, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_obtener_formatos_moneda;

   FUNCTION f_obtener_formatos_moneda1(
      pmoneda IN eco_codmonedas.cmoneda%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN VARCHAR2 IS
      vsprocar       NUMBER;
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(500) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAX_COMMON.f_obtener_formatos_moneda1';
      varret         eco_codmonedas.patron%TYPE;
   BEGIN
      varret := pac_md_common.f_obtener_formatos_moneda1(pmoneda, mensajes);

      IF varret IS NULL THEN
         RAISE e_object_error;
      END IF;

      RETURN varret;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(msgintern, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(msgintern, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(msgintern, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_obtener_formatos_moneda1;

   FUNCTION f_obtener_formatos_moneda2(
      pmoneda IN monedas.cmoneda%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN VARCHAR2 IS
      vsprocar       NUMBER;
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(500) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAX_COMMON.f_obtener_formatos_moneda2';
      varret         eco_codmonedas.patron%TYPE;
   BEGIN
      varret := pac_md_common.f_obtener_formatos_moneda2(pmoneda, mensajes);

      IF varret IS NULL THEN
         RAISE e_object_error;
      END IF;

      RETURN varret;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(msgintern, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(msgintern, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(msgintern, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_obtener_formatos_moneda2;
END pac_iax_common;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_COMMON" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_COMMON" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_COMMON" TO "PROGRAMADORESCSI";
