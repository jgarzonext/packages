--------------------------------------------------------
--  DDL for Package PAC_FORMULAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_FORMULAS" AUTHID CURRENT_USER IS
   FUNCTION f_permf2000(
      ptabla IN NUMBER,
      pedad IN NUMBER,
      psexo IN NUMBER,
      pnacim IN NUMBER,
      ptipo IN NUMBER,
      psimbolo IN VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_lx_i(
      pfecha1 IN DATE,
      pfecha2 IN DATE,
      psexo IN NUMBER,
      pnacim IN NUMBER,
      ptipo IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_cr(
      pfecha1 IN DATE,
      pfecha2 IN DATE,
      psexo IN NUMBER,
      pnacim IN NUMBER,
      ptipo IN NUMBER,
      paportacion IN NUMBER,
      pinteres IN NUMBER)
      RETURN NUMBER;

   -- BUG24926:DRA:29/01/2013:Inici
   FUNCTION f_tabmort(
      sesion IN NUMBER,
      ptabla IN NUMBER,
      pedad IN NUMBER,
      psexo IN NUMBER,
      pnano_nacim IN NUMBER,
      ptipo IN NUMBER,
      psimbolo IN VARCHAR2)
      RETURN NUMBER;
   -- BUG24926:DRA:29/01/2013:Fi
END pac_formulas;

/

  GRANT EXECUTE ON "AXIS"."PAC_FORMULAS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_FORMULAS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_FORMULAS" TO "PROGRAMADORESCSI";
