--------------------------------------------------------
--  DDL for Package PAC_BUREAU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_BUREAU" AS

  FUNCTION f_get_bureau(psseguro IN NUMBER)
      RETURN sys_refcursor;

  FUNCTION f_genera_ficha(psseguro IN NUMBER)
      RETURN NUMBER;

  FUNCTION f_anula_ficha(pfbureau IN NUMBER, pnsuplem IN NUMBER , pnmovimi IN NUMBER)
      RETURN NUMBER;

  FUNCTION f_valida_pol(psseguro IN NUMBER)
      RETURN NUMBER;

  FUNCTION f_asocia_doc(psseguro IN NUMBER, pnsuplemen IN NUMBER , pnmovimi IN NUMBER ,  piddoc IN NUMBER)
      RETURN NUMBER;

END PAC_BUREAU;

/

  GRANT EXECUTE ON "AXIS"."PAC_BUREAU" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_BUREAU" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_BUREAU" TO "PROGRAMADORESCSI";
