--------------------------------------------------------
--  DDL for Package Body PAC_IAX_PARAM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IAX_PARAM" IS
/******************************************************************************
   NOMBRE:      PAC_IAX_PARAM
   PROPÓSITO:   Parametros

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        17/03/2009    FAL               1. Creación del package. Bug 7657
   2.0        23/02/2012    DRA               2. 0021378: CALI701-Comunicacion BONSAI (iAXIS-Bonsai-iAXIS)
******************************************************************************/
   e_param_error  EXCEPTION;
   e_object_error EXCEPTION;

   /*******************************************************************************
   FUNCION f_parinstalacion_n
    Devuelve el valor numérico de un parámetro de instalación

      param in p_cparam : código del parámetro
      param out mensajes: mensajes de error
      return : valor numérico del parámetro de instalación p_cparam
   ********************************************************************************/
   FUNCTION f_parinstalacion_nn(p_cparam IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
   BEGIN
      RETURN pac_md_param.f_parinstalacion_nn(p_cparam, mensajes);
   END f_parinstalacion_nn;

   /*******************************************************************************
   FUNCION f_parinstalacion_t
    Devuelve el valor cadena de un parámetro de instalación

      param in p_cparam : código del parámetro
      param out mensajes: mensajes de error
      return : valor cadena del parámetro de instalación p_cparam
   ********************************************************************************/
   FUNCTION f_parinstalacion_tt(p_cparam IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN VARCHAR2 IS
   BEGIN
      RETURN pac_md_param.f_parinstalacion_tt(p_cparam, mensajes);
   END f_parinstalacion_tt;

   /*******************************************************************************
   FUNCION f_parinstalacion_ff
    Devuelve el valor fecha de un parámetro de instalación

      param in p_cparam : código del parámetro
      param out mensajes: mensajes de error
      return : valor fecha del parámetro de instalación p_cparam
   ********************************************************************************/
   FUNCTION f_parinstalacion_ff(p_cparam IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN DATE IS
   BEGIN
      RETURN pac_md_param.f_parinstalacion_ff(p_cparam, mensajes);
   END f_parinstalacion_ff;

   /*******************************************************************************
    FUNCION f_parempresa_n
    Devuelve el valor numérico de un parámetro de empresa

      param in p_cparam : código del parámetro
      param in p_cempres : codigo de la empresa
      param out mensajes: mensajes de error
      return : valor numérico del parámetro de instalación p_cparam

      Bug 19049/89656- 15/07/2011 - AMC
   ********************************************************************************/
   FUNCTION f_parempresa_n(
      p_cparam IN VARCHAR2,
      p_cempres IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(200) := 'pac_iax_param.f_parempresa_n';
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(2000) := 'parámetros - p_cparam: ' || p_cparam;
   BEGIN
      IF p_cparam IS NULL THEN
         RAISE e_param_error;
      END IF;

      RETURN pac_md_param.f_parempresa_n(p_cparam, p_cempres, mensajes);
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_parempresa_n;

   FUNCTION f_parempresa_t(
      p_cparam IN VARCHAR2,
      p_cempres IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN VARCHAR2 IS
      vobjectname    VARCHAR2(200) := 'pac_iax_param.f_parempresa_t';
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(2000) := 'parámetros - p_cparam: ' || p_cparam;
   BEGIN
      IF p_cparam IS NULL THEN
         RAISE e_param_error;
      END IF;

      RETURN pac_md_param.f_parempresa_t(p_cparam, p_cempres, mensajes);
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_parempresa_t;

   FUNCTION f_parempresa_f(
      p_cparam IN VARCHAR2,
      p_cempres IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN DATE IS
      vobjectname    VARCHAR2(200) := 'pac_iax_param.f_parempresa_f';
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(2000) := 'parámetros - p_cparam: ' || p_cparam;
   BEGIN
      IF p_cparam IS NULL THEN
         RAISE e_param_error;
      END IF;

      RETURN pac_md_param.f_parempresa_f(p_cparam, p_cempres, mensajes);
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_parempresa_f;

   FUNCTION f_pargaranpro_n(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pcparam IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(200) := 'pac_iax_param.f_pargaranpro_n';
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(2000) := 'parámetros - pcparam: ' || pcparam;
   BEGIN
      IF pcparam IS NULL THEN
         RAISE e_param_error;
      END IF;

      RETURN pac_md_param.f_pargaranpro_n(psproduc, pcactivi, pcgarant, pcparam, mensajes);
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_pargaranpro_n;
END pac_iax_param;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_PARAM" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_PARAM" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_PARAM" TO "PROGRAMADORESCSI";
