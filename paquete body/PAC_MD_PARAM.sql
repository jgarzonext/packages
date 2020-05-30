--------------------------------------------------------
--  DDL for Package Body PAC_MD_PARAM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MD_PARAM" IS
/******************************************************************************
 NOMBRE: PAC_MD_PARAM
   PROPÓSITO:   Parametros

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        17/03/2009    FAL               1. Creación del package. Bug 7657
   2.0        11/03/2010    AMC               2. Bug 12124 Se añade la función f_parempresa_nn
   3.0        11/01/2011    SMF               3. Se modifica los parametros para  hacerslo de entrada / salida (16683)
   4.0        23/02/2012    DRA               4. 0021378: CALI701-Comunicacion BONSAI (iAXIS-Bonsai-iAXIS)
******************************************************************************/
   e_param_error  EXCEPTION;
   e_object_error EXCEPTION;

   /*******************************************************************************
   FUNCION f_parinstalacion_nn
    Devuelve el valor numérico de un parámetro de instalación

      param in p_cparam : código del parámetro
      param out mensajes: mensajes de error
      return : valor numérico del parámetro de instalación p_cparam
   ********************************************************************************/
   FUNCTION f_parinstalacion_nn(p_cparam IN VARCHAR2, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(200) := 'pac_md_param.f_parinstalacion_nn';
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(2000) := 'parámetros - p_cparam: ' || p_cparam;
   BEGIN
      IF p_cparam IS NULL THEN
         RAISE e_param_error;
      END IF;

      RETURN f_parinstalacion_n(p_cparam);
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
   END f_parinstalacion_nn;

   /*******************************************************************************
   FUNCION f_parinstalacion_tt
    Devuelve el valor cadena de un parámetro de instalación

      param in p_cparam : código del parámetro
      param out mensajes: mensajes de error
      return : valor cadena del parámetro de instalación p_cparam
   ********************************************************************************/
   FUNCTION f_parinstalacion_tt(p_cparam IN VARCHAR2, mensajes IN OUT t_iax_mensajes)
      RETURN VARCHAR2 IS
      vobjectname    VARCHAR2(200) := 'pac_md_param.f_parinstalacion_tt';
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(2000) := 'parámetros - p_cparam: ' || p_cparam;
   BEGIN
      IF p_cparam IS NULL THEN
         RAISE e_param_error;
      END IF;

      RETURN f_parinstalacion_t(p_cparam);
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
   END f_parinstalacion_tt;

   /*******************************************************************************
   FUNCION f_parinstalacion_ff
    Devuelve el valor fecha de un parámetro de instalación

      param in p_cparam : código del parámetro
      param out mensajes: mensajes de error
      return : valor fecha del parámetro de instalación p_cparam
   ********************************************************************************/
   FUNCTION f_parinstalacion_ff(p_cparam IN VARCHAR2, mensajes IN OUT t_iax_mensajes)
      RETURN DATE IS
      vobjectname    VARCHAR2(200) := 'pac_md_param.f_parinstalacion_ff';
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(2000) := 'parámetros - p_cparam: ' || p_cparam;
   BEGIN
      IF p_cparam IS NULL THEN
         RAISE e_param_error;
      END IF;

      RETURN f_parinstalacion_f(p_cparam);
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
   END f_parinstalacion_ff;

   /*******************************************************************************
   FUNCION f_get_parproducto_n
    Devuelve el valor numérico de un parámetro de instalación
      param in psproduc  : código producte
      param in pcparam   : código del parámetro
      param out mensajes : mensajes de error
      return : valor fecha del parámetro de instalación p_cparam
   ********************************************************************************/
   FUNCTION f_get_parproducto_n(
      psproduc IN NUMBER,
      pcparam IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(200) := 'pac_md_param.f_get_parproducto_n';
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(2000)
                             := 'parámetros - psproduc: ' || psproduc || 'pcparam:' || pcparam;
   BEGIN
      IF pcparam IS NULL THEN
         RAISE e_param_error;
      END IF;

      RETURN pac_parametros.f_parproducto_n(psproduc, pcparam);
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
   END f_get_parproducto_n;

   /*******************************************************************************
    FUNCION f_parempresa_nn
    Devuelve el valor numérico de un parámetro de empresa

      param in p_cparam : código del parámetro
      param out mensajes: mensajes de error
      return : valor numérico del parámetro de instalación p_cparam

      Bug 12124 - 11/03/2010 - AMC
   ********************************************************************************/
   FUNCTION f_parempresa_nn(p_cparam IN VARCHAR2, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(200) := 'pac_md_param.f_parempresa_nn';
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(2000) := 'parámetros - p_cparam: ' || p_cparam;
   BEGIN
      IF p_cparam IS NULL THEN
         RAISE e_param_error;
      END IF;

      RETURN pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa(), p_cparam);
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
   END f_parempresa_nn;

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
      vobjectname    VARCHAR2(200) := 'pac_md_param.f_parempresa_n';
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(2000)
                         := 'parámetros - p_cparam:' || p_cparam || ' p_cempres:' || p_cempres;
      vcempres       NUMBER;
   BEGIN
      IF p_cparam IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF p_cempres IS NULL THEN
         vcempres := pac_md_common.f_get_cxtempresa();
      ELSE
         vcempres := p_cempres;
      END IF;

      RETURN pac_parametros.f_parempresa_n(vcempres, p_cparam);
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
      vobjectname    VARCHAR2(200) := 'pac_md_param.f_parempresa_t';
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(2000)
                         := 'parámetros - p_cparam:' || p_cparam || ' p_cempres:' || p_cempres;
      vcempres       NUMBER;
   BEGIN
      IF p_cparam IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF p_cempres IS NULL THEN
         vcempres := pac_md_common.f_get_cxtempresa();
      ELSE
         vcempres := p_cempres;
      END IF;

      RETURN pac_parametros.f_parempresa_t(vcempres, p_cparam);
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
      vobjectname    VARCHAR2(200) := 'pac_md_param.f_parempresa_f';
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(2000)
                         := 'parámetros - p_cparam:' || p_cparam || ' p_cempres:' || p_cempres;
      vcempres       NUMBER;
   BEGIN
      IF p_cparam IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF p_cempres IS NULL THEN
         vcempres := pac_md_common.f_get_cxtempresa();
      ELSE
         vcempres := p_cempres;
      END IF;

      RETURN pac_parametros.f_parempresa_f(vcempres, p_cparam);
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
      vobjectname    VARCHAR2(200) := 'pac_md_param.f_pargaranpro_n';
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(2000) := 'parámetros - pcparam:' || pcparam;
      vcempres       NUMBER;
   BEGIN
      IF pcparam IS NULL THEN
         RAISE e_param_error;
      END IF;

      RETURN pac_parametros.f_pargaranpro_n(psproduc, pcactivi, pcgarant, pcparam);
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
END pac_md_param;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_PARAM" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_PARAM" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_PARAM" TO "PROGRAMADORESCSI";
