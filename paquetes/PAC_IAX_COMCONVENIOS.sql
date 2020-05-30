--------------------------------------------------------
--  DDL for Package PAC_IAX_COMCONVENIOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_IAX_COMCONVENIOS" AS
   /******************************************************************************
     NOMBRE:     pac_iax_comconvenios
     PROPÓSITO:  Package para gestionar los convenios de sobrecomisión

     REVISIONES:
     Ver        Fecha        Autor             Descripción
     ---------  ----------  ---------------  ------------------------------------
     1.0        11/02/2012   FAL             0025988: LCOL_C004: Realizar desarrollo Convenio Liberty web
    ******************************************************************************/
   FUNCTION f_get_lstconvenios(
      psproduc IN NUMBER,
      pcagente IN NUMBER,
      pfinivig IN DATE,
      pffinvig IN DATE,
      pcramo IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_get_convenio_vig(
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

   FUNCTION f_get_prodconvenio(pscomconv IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_get_modcom_conv(
      pscomconv IN NUMBER,
      pfinivig IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_val_convenio(
      pcmodo IN NUMBER,
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
      pscomconv IN NUMBER,
      pcagente IN NUMBER,
      pfinivig IN DATE,
      pffinvig IN DATE,
      psproduc IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_val_modcom_convenio(
      pscomconv IN NUMBER,
      pcmodcom IN NUMBER,
      ppcomisi IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_alta_convenio(
      pscomconv IN NUMBER,
      ptconvenio IN VARCHAR2,
      pcagente IN NUMBER,
      pfinivig IN DATE,
      pffinvig IN DATE,
      piimporte IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_alta_prod_convenio(
      pscomconv IN NUMBER,
      psproduc IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_alta_modcom_convenio(
      pscomconv IN NUMBER,
      pcmodcom IN NUMBER,
      pfinivig IN DATE,
      ppcomisi IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_set_convenio_fec(
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

   FUNCTION f_alta_convenio_web(
      pcmodo IN NUMBER,
      pscomconv IN NUMBER,
      ptconvenio IN VARCHAR2,
      pcagente IN NUMBER,
      pfinivig IN DATE,
      pffinvig IN DATE,
      pfanul IN DATE,
      piimporte IN NUMBER,
      plistaprods IN t_iax_info,
      plistacomis IN t_iax_info,
      pfinivig_out OUT DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_next_conv(mensajes OUT t_iax_mensajes)
      RETURN NUMBER;
END pac_iax_comconvenios;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_COMCONVENIOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_COMCONVENIOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_COMCONVENIOS" TO "PROGRAMADORESCSI";
