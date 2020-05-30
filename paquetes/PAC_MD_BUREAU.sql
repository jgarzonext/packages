--------------------------------------------------------
--  DDL for Package PAC_MD_BUREAU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_MD_BUREAU" AS

  FUNCTION f_get_bureau(psseguro IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

  FUNCTION f_genera_ficha(psseguro IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

  FUNCTION f_anula_ficha(pfbureau IN NUMBER, pnsuplem IN NUMBER , pnmovimi IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

  FUNCTION f_valida_pol(psseguro IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

  FUNCTION f_asocia_doc(psseguro IN NUMBER, pnsuplem IN NUMBER , pnmovimi IN NUMBER ,  piddoc IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

END PAC_MD_BUREAU;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_BUREAU" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_BUREAU" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_BUREAU" TO "PROGRAMADORESCSI";
