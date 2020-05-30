--------------------------------------------------------
--  DDL for Package PAC_IAX_CODIGOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_IAX_CODIGOS" AS
/******************************************************************************
   NOMBRE:      pac_iax_codigos
   PROPÓSITO:

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        10/02/2012   XPL               1. Creación del package.

******************************************************************************/
   FUNCTION f_get_idiomas_activos(pcuridiomas OUT sys_refcursor, mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_tipcodigos(pcurtipcodigos OUT sys_refcursor, mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

/*

*/
   FUNCTION f_get_codigos(
      pparams IN CLOB,
      pcodigo OUT VARCHAR2,
      ptinfo OUT ob_iax_info,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_set_codsproduc(
      pcempres IN NUMBER,
      pcidioma IN NUMBER,
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pccolect IN NUMBER,
      pctipseg IN NUMBER,
      pcodigo OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_set_codcgarant(
      pcempres IN NUMBER,
      pcidioma IN NUMBER,
      pcodigo OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_set_codpregun(
      pcempres IN NUMBER,
      pcidioma IN NUMBER,
      pcodigo OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_set_codramo(
      pcempres IN NUMBER,
      pcidioma IN NUMBER,
      pcodigo OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_set_codactivi(
      pcramo IN NUMBER,
      pcempres IN NUMBER,
      pcidioma IN NUMBER,
      pcodigo OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_set_codliterales(
      ptlitera_1 IN VARCHAR2,
      ptlitera_2 IN VARCHAR2,
      ptlitera_3 IN VARCHAR2,
      ptlitera_4 IN VARCHAR2,
      ptlitera_5 IN VARCHAR2,
      ptlitera_6 IN VARCHAR2,
      ptlitera_7 IN VARCHAR2,
      ptlitera_8 IN VARCHAR2,
      ptlitera_9 IN VARCHAR2,
      ptlitera_10 IN VARCHAR2,
      pcempres IN NUMBER,
      pcidioma IN NUMBER,
      pcodigo OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;
END pac_iax_codigos;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_CODIGOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_CODIGOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_CODIGOS" TO "PROGRAMADORESCSI";
