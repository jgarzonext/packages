--------------------------------------------------------
--  DDL for Package PAC_MORTALIDAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_MORTALIDAD" AUTHID CURRENT_USER IS
   FUNCTION ff_mortalidad_mr_mk(
      sesion IN NUMBER,
      ptabla IN NUMBER,
      pedad_1 IN NUMBER,
      pedad_2 IN NUMBER,
      psexo IN NUMBER,
      psimbolo IN VARCHAR2)
      RETURN NUMBER;
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_MORTALIDAD" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MORTALIDAD" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MORTALIDAD" TO "PROGRAMADORESCSI";
