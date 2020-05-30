--------------------------------------------------------
--  DDL for Package Body PAC_IAX_FISCALIDAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IAX_FISCALIDAD" AS
/******************************************************************************
   NOMBRE:    PAC_IAX_FISCALIDAD
   PROPÓSITO: Contiene el módulo de fiscalidad de la capa IAX

   REVISIONES:
   Ver        Fecha       Autor            Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        09/10/2008  SBG              1. Creación del package.
******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   /*************************************************************************
      Genera el fichero
      param in P_EMPRESA        : Empresa presentadora
      param in P_MODELO         : Modelo fiscal a generar
      param in P_FICHERO_IN     : Nombre Fichero
      param in P_FECHA_INI      : Fecha inicio periodo
      param in P_FECHA_FIN      : Fecha fin periodo
      param in P_ANOFISCAL      : Año fiscal
      param in P_TIPOSOPORTE    : Tipo de soporte entrega
      param in P_TIPOCIUDADANO  : Tipo de ciudadano
      param in P_IDIOMA         : idioma (para el mensaje de salida)
      param out P_FICHERO_OUT   : path + nombre del fichero
      param out MENSAJES        : mensajes de error o de ok.
   *************************************************************************/
   FUNCTION f_generar(
      p_empresa IN NUMBER,
      p_modelo IN VARCHAR2,
      p_fichero_in IN VARCHAR2,
      p_fecha_ini IN DATE,
      p_fecha_fin IN DATE,
      p_anofiscal IN VARCHAR2,
      p_tiposoporte IN VARCHAR2,
      p_tipociudadano IN VARCHAR2,
      p_idioma IN NUMBER,
      p_fichero_out OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(900)
         := 'OB_FIS_PARAMETROS: EMPRESA=' || p_empresa || ', MODELO=' || p_modelo
            || ', FICHERO=' || p_fichero_in || ', FECHA_INI='
            || TO_CHAR(p_fecha_ini, 'DD/MM/YYYY') || ', FECHA_FIN='
            || TO_CHAR(p_fecha_fin, 'DD/MM/YYYY') || ', ANOFISCAL=' || p_anofiscal
            || ', TIPOSOPORTE=' || p_tiposoporte || ', TIPOCIUDADANO=' || p_tipociudadano
            || ', P_IDIOMA=' || p_idioma;
      vobject        VARCHAR2(200) := 'PAC_IAX_FISCALIDAD.F_GENERAR';
      v_ofp          ob_fis_parametros := ob_fis_parametros();
      v_error        NUMBER;
   BEGIN
      IF p_empresa IS NULL
         OR p_modelo IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;

      IF p_fecha_ini IS NOT NULL
         AND p_fecha_fin IS NOT NULL
         AND p_fecha_ini > p_fecha_fin THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 101922);
         RETURN -1;
      END IF;

      vpasexec := 3;

      IF p_fecha_ini IS NULL
         AND p_fecha_fin IS NOT NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 700169);
         RETURN -1;
      END IF;

      vpasexec := 4;
      v_ofp.empresa := p_empresa;
      v_ofp.modelo := p_modelo;
      v_ofp.fichero := p_fichero_in;
      v_ofp.fecha_ini := p_fecha_ini;
      v_ofp.fecha_fin := p_fecha_fin;
      v_ofp.anofiscal := p_anofiscal;
      v_ofp.tiposoporte := p_tiposoporte;
      v_ofp.tipociudadano := p_tipociudadano;
      vpasexec := 5;
      v_error := pac_md_fiscalidad.f_generar(v_ofp, p_idioma, p_fichero_out, mensajes);
      RETURN v_error;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN -1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN -1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN -1;
   END f_generar;

   /*************************************************************************
      Retorna un cursor a los modelos fiscales activos para la empresa
      param in P_EMPRESA : código empresa
      p<r<m in P_IDIOMA  : idioma
      param out MENSAJES : mensajes de error
   *************************************************************************/
   FUNCTION f_get_modelos(p_empresa IN NUMBER, p_idioma IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'P_EMPRESA = ' || p_empresa;
      vobject        VARCHAR2(200) := 'PAC_IAX_FISCALIDAD.F_GET_MODELOS';
      cur            sys_refcursor;
   BEGIN
      cur := pac_md_fiscalidad.f_get_modelos(p_empresa, p_idioma, mensajes);
      RETURN cur;
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
   END f_get_modelos;

   /*************************************************************************
      Retorna un cursor con los diferentes valores y descripciones
      param in P_EMPRESA : código empresa
      param in P_CVALOR  : valor
      param in P_IDIOMA  : idioma
      param out MENSAJES : mensajes de error
   *************************************************************************/
   FUNCTION f_getdetvalores(
      p_empresa IN NUMBER,
      p_cvalor IN VARCHAR2,
      p_idioma IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'P_EMPRESA = ' || p_empresa || ', P_CVALOR = ' || p_cvalor || ', P_IDIOMA = '
            || p_idioma;
      vobject        VARCHAR2(200) := 'PAC_IAX_FISCALIDAD.F_GETDETVALORES';
      cur            sys_refcursor;
   BEGIN
      cur := pac_md_fiscalidad.f_getdetvalores(p_empresa, p_cvalor, p_idioma, mensajes);
      RETURN cur;
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
   END f_getdetvalores;

   FUNCTION f_fecu(
      pidioma IN NUMBER,
      fecha_desde IN VARCHAR2,
      fecha_hasta IN VARCHAR2,
      vimp OUT t_iax_impresion,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobj           VARCHAR2(500) := 'pac_IAX_fiscalidad.F_FECU';
      vpar           VARCHAR2(500)
                           := 'parámetros - ini: ' || fecha_desde || ' - fin :' || fecha_hasta;
      vpas           NUMBER(5) := 1;
      vnumerr        NUMBER;
   BEGIN
      vnumerr := pac_md_fiscalidad.f_fecu(pidioma, fecha_desde, fecha_hasta, vimp, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      --Se debe realizar el control de errores mediante  el PAC_IOBJ_MENSAJES.P_TRATARMENSAJE.
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000006, vpas, vpar);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000005, vpas, vpar);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000001, vpas, vpar,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_fecu;
END pac_iax_fiscalidad;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_FISCALIDAD" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_FISCALIDAD" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_FISCALIDAD" TO "PROGRAMADORESCSI";
