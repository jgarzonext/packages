--------------------------------------------------------
--  DDL for Package PAC_ALBVAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_ALBVAL" AUTHID CURRENT_USER IS
/******************************************************************************
   NOMBRE:    PAC_ALBVAL
   PROPÓSITO: Funciones de validación

   REVISIONES:
   Ver        Fecha       Autor  Descripción
   ---------  ----------  -----  ------------------------------------
   1.0                           Creació del package.
   2.0        04/05/2009  SBG    Eliminació funció F_Valida_Altura (Bug 5388)
******************************************************************************/
   cerror         NUMBER;

   FUNCTION f_tprefor(
      ptprefor IN VARCHAR2,
      pvalor IN NUMBER,
      ptablas IN VARCHAR2,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pfefecto IN DATE,
      pnmovimi IN NUMBER,
      pcgarant IN NUMBER,
      resultat OUT NUMBER)
      RETURN NUMBER;
END pac_albval;
 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_ALBVAL" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_ALBVAL" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_ALBVAL" TO "PROGRAMADORESCSI";
