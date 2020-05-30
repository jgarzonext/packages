--------------------------------------------------------
--  DDL for Package PAC_MD_SIN_IMPUESTOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_MD_SIN_IMPUESTOS" AS
/******************************************************************************
   NOMBRE:    pac_md_sin_impuestos
   PROPÓSITO: Funciones para calculo de impuestos

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
    1.0       13/08/2013   NSS             Creacion
******************************************************************************/
   FUNCTION f_opencursor(squery IN VARCHAR2, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Abre un cursor con la sentencia suministrada
      param in squery    : consulta a executar
      param out mensajes : mesajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_impuestos(
      pcconcep IN NUMBER,
      pccodimp IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_set_impuesto(
      pcconcep IN NUMBER,
      pccodimp IN NUMBER,
      pfdesde IN DATE,
      pctipper IN NUMBER,
      pcregfiscal IN NUMBER,
      pctipcal IN NUMBER,
      pifijo IN NUMBER,
      pcbasecal IN NUMBER,
      pcbasemin IN NUMBER,
      pcbasemax IN NUMBER,
      pnporcent IN NUMBER,
      pimin IN NUMBER,
      pimax IN NUMBER,
      pnordimp IN NUMBER,
      pcsubtab IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_del_impuesto(
      pcconcep IN NUMBER,
      pccodimp IN NUMBER,
      pnordimp IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_impuesto(
      pcconcep IN NUMBER,
      pccodimp IN NUMBER,
      pnordimp IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_get_lstimpuestos(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_get_tdescri_subtab(pcsubtab IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_copia_impuesto(
      pcconcep IN NUMBER,
      pcconcep_ant IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_lstconceptos(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_get_definiciones_reteica(
      pcpais IN NUMBER,
      pcprovin IN NUMBER,
      pcpoblac IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_set_valores_reteica(
      pcpais IN NUMBER,
      pcprovin IN NUMBER,
      pcpoblac IN NUMBER,
      pfdesde IN DATE,
      pvalores_reteica IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;
END pac_md_sin_impuestos;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_SIN_IMPUESTOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_SIN_IMPUESTOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_SIN_IMPUESTOS" TO "PROGRAMADORESCSI";
