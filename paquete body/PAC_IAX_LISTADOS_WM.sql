--------------------------------------------------------
--  DDL for Package Body PAC_IAX_LISTADOS_WM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IAX_LISTADOS_WM" IS
/******************************************************************************
   NOMBRE:       pac_wm_listado
   PROPÓSITO:    Contiene la generación de diversos listado por agente y rango de fechas.

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        09/06/2010   SRA              1. Creación del package.
******************************************************************************/

   /******************************************************************************
   F_LISTADO_CARTERA - Genera el listado de cartera
         p_finicar IN VARCHAR2,
         p_ffincar IN VARCHAR2)
         RETURN sys_refcursor
   ********************************************************************************/

   --Define las varibles tipos contexto
   cxtidioma      VARCHAR2(100) := 'IAX_IDIOMA';
   cxtusuario     VARCHAR2(100) := 'IAX_USUARIO';
   cxtagente      VARCHAR2(100) := 'IAX_AGENTE';
   cxtempresa     VARCHAR2(100) := 'IAX_EMPRESA';
   cxtagenteprod  VARCHAR2(100) := 'IAX_AGENTEPROD';
   cxtterminal    VARCHAR2(100) := 'IAX_TERMINAL';
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;
   msgintern      t_iax_mensajes;

   FUNCTION f_listado_cartera(
      p_finicar IN DATE,
      p_ffincar IN DATE,
      p_cagente IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN t_iax_listadocartera_wm IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(500)
         := 'finicar = ' || p_finicar || ', ffincar = ' || p_ffincar || ', p_cagente = '
            || p_cagente;
      vobject        VARCHAR2(200) := 'PAC_iax_LISTADOS_WM.p_listado_cartera';
      v_tlistacartera t_iax_listadocartera_wm := t_iax_listadocartera_wm();
   BEGIN
      pac_md_listados_wm.p_listado_cartera(p_finicar, p_ffincar, p_cagente, v_tlistacartera,
                                           mensajes);
      vpasexec := 2;
      RETURN v_tlistacartera;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(msgintern, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN v_tlistacartera;
   END f_listado_cartera;

   FUNCTION f_listado_polizas(
      p_finicar IN DATE,
      p_ffincar IN DATE,
      p_cagente IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN t_iax_listadopolizas_wm IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(500)
         := 'finicar = ' || p_finicar || ', ffincar = ' || p_ffincar || ', p_cagente = '
            || p_cagente;
      vobject        VARCHAR2(200) := 'PAC_iax_LISTADOS_WM.p_listado_polizas';
      v_tlistapolizas t_iax_listadopolizas_wm := t_iax_listadopolizas_wm();
   BEGIN
      pac_md_listados_wm.p_listado_polizas(p_finicar, p_ffincar, p_cagente, v_tlistapolizas,
                                           mensajes);
      vpasexec := 2;
      RETURN v_tlistapolizas;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(msgintern, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN v_tlistapolizas;
   END f_listado_polizas;

   FUNCTION f_listado_siniestros(
      p_finicar IN DATE,
      p_ffincar IN DATE,
      p_cagente IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN t_iax_listadosiniestros_wm IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(500)
         := 'finicar = ' || p_finicar || ', ffincar = ' || p_ffincar || ', p_cagente = '
            || p_cagente;
      vobject        VARCHAR2(200) := 'PAC_iax_LISTADOS_WM.p_listado_siniestros';
      v_tlistasiniestros t_iax_listadosiniestros_wm := t_iax_listadosiniestros_wm();
   BEGIN
      pac_md_listados_wm.p_listado_siniestros(p_finicar, p_ffincar, p_cagente,
                                              v_tlistasiniestros, mensajes);
      vpasexec := 2;
      RETURN v_tlistasiniestros;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(msgintern, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN v_tlistasiniestros;
   END f_listado_siniestros;
END pac_iax_listados_wm;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_LISTADOS_WM" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_LISTADOS_WM" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_LISTADOS_WM" TO "PROGRAMADORESCSI";
