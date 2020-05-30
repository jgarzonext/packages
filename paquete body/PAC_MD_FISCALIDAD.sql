--------------------------------------------------------
--  DDL for Package Body PAC_MD_FISCALIDAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MD_FISCALIDAD" AS
/******************************************************************************
   NOMBRE:    PAC_MD_FISCALIDAD
   PROPÓSITO: Contiene el módulo de fiscalidad de la capa MD

   REVISIONES:
   Ver        Fecha       Autor            Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        09/10/2008  SBG              1. Creación del package.
   2.0        21/10/2010  ICV              2. 0016312: CEM - Models fiscals
******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   /*************************************************************************
      Genera el fichero
      param in     P_OFP    : objeto de tipo OB_FIS_PARAMETROS
      param in     P_IDIOMA : idioma (para el mensaje de salida)
      param in out P_FICH   : path + nombre del fichero
      param in out MENSAJES : mensajes de error o de ok.
   *************************************************************************/
   FUNCTION f_generar(
      p_ofp IN ob_fis_parametros,
      p_idioma IN NUMBER,
      p_fich IN OUT VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(900)
         := 'OB_FIS_PARAMETROS: EMPRESA=' || p_ofp.empresa || ', MODELO=' || p_ofp.modelo
            || ', FICHERO=' || p_ofp.fichero || ', FECHA_INI='
            || TO_CHAR(p_ofp.fecha_ini, 'DD/MM/YYYY') || ', FECHA_FIN='
            || TO_CHAR(p_ofp.fecha_fin, 'DD/MM/YYYY') || ', ANOFISCAL=' || p_ofp.anofiscal
            || ', TIPOSOPORTE=' || p_ofp.tiposoporte || ', TIPOCIUDADANO='
            || p_ofp.tipociudadano || ', IDIOMA=' || p_idioma;
      vobject        VARCHAR2(200) := 'PAC_MD_FISCALIDAD.F_GENERAR';
      v_error        NUMBER;
      v_linia        VARCHAR2(2000);
      v_texto        VARCHAR2(200);
      v_ofp          ob_fis_parametros := ob_fis_parametros();
      vlparame       VARCHAR2(4000);
   BEGIN
      --Ini Bug.: 16312 - ICV - 21/10/2010 - Si el modelo que se va a lanzar va por fechas pero solo se pasa el año se coge todo el año ejemplo con el modelo 480
      v_ofp := p_ofp;

      SELECT lparame
        INTO vlparame
        FROM fis_modelosdet
       WHERE cempresa = v_ofp.empresa
         AND cmodelo = v_ofp.modelo;

      IF vlparame LIKE '%#FECHA_FIN|#FECHA_INI%'
         AND v_ofp.anofiscal IS NOT NULL
         AND v_ofp.fecha_ini IS NULL
         AND v_ofp.fecha_fin IS NULL THEN
         v_ofp.fecha_ini := TO_DATE('01/01/' || v_ofp.anofiscal, 'dd/mm/rrrr');
         v_ofp.fecha_fin := TO_DATE('31/12/' || v_ofp.anofiscal, 'dd/mm/rrrr');
      END IF;

      --Fin Bug.: 16312
      v_linia := v_ofp.f_componerlinea(v_error);

      IF v_error <> 0 THEN
         RAISE e_object_error;
      END IF;

      vpasexec := 2;
      v_error := pac_fiscierre.f_generar(v_ofp.empresa, v_ofp.modelo, v_linia, v_ofp.fichero,
                                         p_fich);

      IF v_error <> 0 THEN
         v_texto := f_axis_literales(151632, p_idioma) || ' ' || p_fich;
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, v_error, v_texto);
         RETURN -1;
      END IF;

      vpasexec := 3;
      v_texto := f_axis_literales(105267, p_idioma) || p_fich;
      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, v_error, v_texto);
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
      param in P_EMPRESA    : código empresa
      param in P_IDIOMA     : idioma
      param in out MENSAJES : mensajes de error
   *************************************************************************/
   FUNCTION f_get_modelos(
      p_empresa IN NUMBER,
      p_idioma IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'P_EMPRESA = ' || p_empresa;
      vobject        VARCHAR2(200) := 'PAC_MD_FISCALIDAD.F_GET_MODELOS';
      cur            sys_refcursor;
      v_error        NUMBER;
   BEGIN
      cur := pac_fiscierre.f_get_modelos(p_empresa, p_idioma, v_error);

      IF v_error = -1 THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
      ELSIF v_error = -2 THEN
         RAISE e_param_error;
      END IF;

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
      param in P_EMPRESA    : código empresa
      param in P_CVALOR     : valor
      param in P_IDIOMA     : idioma
      param in out MENSAJES : mensajes de error
   *************************************************************************/
   FUNCTION f_getdetvalores(
      p_empresa IN NUMBER,
      p_cvalor IN VARCHAR2,
      p_idioma IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'P_EMPRESA = ' || p_empresa || ', P_CVALOR = ' || p_cvalor || ', P_IDIOMA = '
            || p_idioma;
      vobject        VARCHAR2(200) := 'PAC_MD_FISCALIDAD.F_GETDETVALORES';
      cur            sys_refcursor;
      v_error        NUMBER;
   BEGIN
      cur := pac_fiscierre.f_getdetvalores(p_empresa, p_cvalor, p_idioma, v_error);

      IF v_error = -1 THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
      ELSIF v_error = -2 THEN
         RAISE e_param_error;
      END IF;

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
      vobject        VARCHAR2(500) := 'pac_MD_fiscalidad.F_FECU';
      vparam         VARCHAR2(500)
                           := 'parámetros - ini: ' || fecha_desde || ' - fin :' || fecha_hasta;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vpropio        VARCHAR2(200);
      vemp           empresas.cempres%TYPE;
      vsent          VARCHAR2(3000);
      ex_nodeclared  EXCEPTION;
      PRAGMA EXCEPTION_INIT(ex_nodeclared, -6550);
   BEGIN
      vpasexec := 10;
      vemp := NVL(f_empres, f_parinstalacion_n('EMPRESADEF'));
      vpasexec := 20;

      SELECT MAX(tvalpar)
        INTO vpropio
        FROM parempresas
       WHERE cparam = 'SUFIJO_EMP'
         AND cempres = vemp;

      vpasexec := 30;
      vsent := 'BEGIN :vnumerr := pac_informes_' || vpropio
               || '.f_751(:pidioma, :fecha_desde, :fecha_hasta, :vIMP); END;';
      vpasexec := 40;

      EXECUTE IMMEDIATE (vsent)
                  USING OUT vnumerr, IN pidioma, IN fecha_desde, IN fecha_hasta, OUT vimp;

      vpasexec := 50;
      RETURN NVL(vnumerr, 0);
   EXCEPTION
      WHEN ex_nodeclared THEN
         RETURN 0;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam || ': Error' || SQLCODE,
                     SQLERRM || CHR(10) || vsent);
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_fecu;
END pac_md_fiscalidad;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_FISCALIDAD" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_FISCALIDAD" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_FISCALIDAD" TO "PROGRAMADORESCSI";
