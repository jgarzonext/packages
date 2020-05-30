--------------------------------------------------------
--  DDL for Package PAC_IAX_FISCALIDAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_IAX_FISCALIDAD" AS
/******************************************************************************
   NOMBRE:    PAC_IAX_FISCALIDAD
   PROPÓSITO: Contiene el módulo de fiscalidad de la capa IAX

   REVISIONES:
   Ver        Fecha       Autor            Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        08/10/2008  SBG              1. Creación del package.
******************************************************************************/

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
      RETURN NUMBER;

   /*************************************************************************
      Retorna un cursor a los modelos fiscales activos para la empresa
      param in P_EMPRESA : código empresa
      p<r<m in P_IDIOMA  : idioma
      param out MENSAJES : mensajes de error
   *************************************************************************/
   FUNCTION f_get_modelos(p_empresa IN NUMBER, p_idioma IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

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
      RETURN sys_refcursor;

   FUNCTION f_fecu(
      pidioma IN NUMBER,
      fecha_desde IN VARCHAR2,
      fecha_hasta IN VARCHAR2,
      vimp OUT t_iax_impresion,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;
END pac_iax_fiscalidad;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_FISCALIDAD" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_FISCALIDAD" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_FISCALIDAD" TO "PROGRAMADORESCSI";
