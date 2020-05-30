--------------------------------------------------------
--  DDL for Package PAC_MD_COMCONVENIOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_MD_COMCONVENIOS" AS
   /******************************************************************************
     NOMBRE:     pac_md_comconvenios
     PROPÓSITO:  Package para gestionar los convenios de sobrecomisión

     REVISIONES:
     Ver        Fecha        Autor             Descripción
     ---------  ----------  ---------------  ------------------------------------
     1.0        11/02/2012   FAL             0025988: LCOL_C004: Realizar desarrollo Convenio Liberty web
    ******************************************************************************/
   FUNCTION f_get_lstconvenios(
      pcempres IN NUMBER,
      psproduc IN NUMBER,
      pcagente IN NUMBER,
      pfinivig IN DATE,
      pffinvig IN DATE,
      pcramo IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_get_convenio_vig(
      pcempres_in IN NUMBER,
      pscomconv_in IN NUMBER,
      pfinivig_in IN DATE,
      ptconvenio OUT VARCHAR2,
      pcagente OUT NUMBER,
      ptnomage OUT VARCHAR2,
      pffinvig OUT DATE,
      piimporte OUT NUMBER,
      pfanul OUT DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_prodconvenio(
      pcempres IN NUMBER,
      pscomconv IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_get_modcom_conv(
      pcempres IN NUMBER,
      pscomconv IN NUMBER,
      pfinivig IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_val_convenio(
      pcmodo IN NUMBER,
      pcempres IN NUMBER,
      pscomconv IN NUMBER,
      ptconvenio IN VARCHAR2,
      pcagente IN NUMBER,
      pfinivig IN DATE,
      pffinvig IN DATE,
      piimporte IN NUMBER,
      pfanul IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_val_prod_convenio(
      pcempres IN NUMBER,
      pscomconv IN NUMBER,
      pcagente IN NUMBER,
      pfinivig IN DATE,
      pffinvig IN DATE,
      psproduc IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_val_modcom_convenio(
      pcempres IN NUMBER,
      pscomconv IN NUMBER,
      pcmodcom IN NUMBER,
      ppcomisi IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_alta_convenio(
      pcempres IN NUMBER,
      pscomconv IN NUMBER,
      ptconvenio IN VARCHAR2,
      pcagente IN NUMBER,
      pfinivig IN DATE,
      pffinvig IN DATE,
      piimporte IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_alta_prod_convenio(
      pcempres IN NUMBER,
      pscomconv IN NUMBER,
      psproduc IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_alta_modcom_convenio(
      pcempres IN NUMBER,
      pscomconv IN NUMBER,
      pcmodcom IN NUMBER,
      pfinivig IN DATE,
      ppcomisi IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_set_convenio_fec(
      pcempres IN NUMBER,
      pcmodo IN NUMBER,
      pscomconv IN NUMBER,
      ptconvenio IN VARCHAR2,
      pcagente IN NUMBER,
      pfinivig IN DATE,
      pffinvig IN DATE,
      piimporte IN NUMBER,
      pfanul IN DATE,
      pfinivig_out OUT DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_next_conv(mensajes OUT t_iax_mensajes)
      RETURN NUMBER;
END pac_md_comconvenios;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_COMCONVENIOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_COMCONVENIOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_COMCONVENIOS" TO "PROGRAMADORESCSI";
