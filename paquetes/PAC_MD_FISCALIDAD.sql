--------------------------------------------------------
--  DDL for Package PAC_MD_FISCALIDAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_MD_FISCALIDAD" AS
/******************************************************************************
   NOMBRE:    PAC_MD_FISCALIDAD
   PROPÓSITO: Contiene el módulo de fiscalidad de la capa MD

   REVISIONES:
   Ver        Fecha       Autor            Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        08/10/2008  SBG              1. Creación del package.
******************************************************************************/

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
      RETURN NUMBER;

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
      RETURN sys_refcursor;

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
      RETURN sys_refcursor;

   FUNCTION f_fecu(
      pidioma IN NUMBER,
      fecha_desde IN VARCHAR2,
      fecha_hasta IN VARCHAR2,
      vimp OUT t_iax_impresion,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;
END pac_md_fiscalidad;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_FISCALIDAD" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_FISCALIDAD" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_FISCALIDAD" TO "PROGRAMADORESCSI";
