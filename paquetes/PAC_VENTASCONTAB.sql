--------------------------------------------------------
--  DDL for Package PAC_VENTASCONTAB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_VENTASCONTAB" AUTHID CURRENT_USER IS
   FUNCTION f_vanu_excant(
      w_sseguro IN NUMBER,
      w_excant IN NUMBER,
      w_fcierreefe IN DATE,
      w_fanulac IN DATE,
      p_moneda IN NUMBER,
      w_vanu_excant OUT NUMBER)
      RETURN NUMBER;

   FUNCTION f_vanu_excant_gar(
      w_sseguro IN NUMBER,
      w_cgarant IN NUMBER,
      w_nriesgo IN NUMBER,
      w_excant IN NUMBER,
      w_fcierreefe IN DATE,
      w_fanulac IN DATE,
      p_moneda IN NUMBER,
      w_vanu_excant OUT NUMBER)
      RETURN NUMBER;

   FUNCTION f_pe_excant(
      w_sseguro IN NUMBER,
      w_fefecto IN DATE,
      w_fvencim IN DATE,
      w_excant IN NUMBER,
      w_fcierreefe IN DATE,
      w_fcierreproc IN DATE,
      p_moneda IN NUMBER,
      w_pe_excant OUT NUMBER)
      RETURN NUMBER;

   FUNCTION f_pe_excant_gar(
      w_sseguro IN NUMBER,
      w_nriesgo IN NUMBER,
      w_cgarant IN NUMBER,
      w_fefecto IN DATE,
      w_fvencim IN DATE,
      w_excant IN NUMBER,
      w_fcierreefe IN DATE,
      w_fcierreproc IN DATE,
      p_moneda IN NUMBER,
      w_pe_excant_gar OUT NUMBER)
      RETURN NUMBER;

   FUNCTION calculo_ventas(
      psproces IN NUMBER,
      pmodo IN NUMBER,
      pcempres IN NUMBER,
      pmoneda IN NUMBER,
      pfperfin IN DATE,
      text_error OUT VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_renovapost(w_sseguro IN NUMBER, w_excant IN NUMBER, w_frenova OUT DATE)
      RETURN NUMBER;

   FUNCTION f_trasllat_prima(
      w_sseguro IN NUMBER,
      w_dataini IN DATE,
      w_datafi IN DATE,
      w_fgaran IN DATE,
      p_moneda IN NUMBER,
      w_import OUT NUMBER,
      w_diespnoe OUT NUMBER)
      RETURN NUMBER;
END;

/

  GRANT EXECUTE ON "AXIS"."PAC_VENTASCONTAB" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_VENTASCONTAB" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_VENTASCONTAB" TO "PROGRAMADORESCSI";
