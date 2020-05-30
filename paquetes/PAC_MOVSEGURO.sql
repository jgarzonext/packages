--------------------------------------------------------
--  DDL for Package PAC_MOVSEGURO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_MOVSEGURO" AUTHID CURRENT_USER IS
   /*************************************************************
           F_NMOVIMI_ULT: Obtener el útlimo NMOVIMI
   **************************************************************/
   FUNCTION f_nmovimi_ult(psseguro IN NUMBER)
      RETURN NUMBER;

   /*************************************************************
           F_NMOVIMI_VALIDO: Obtener el útlimo NMOVIMI valido
   **************************************************************/
   FUNCTION f_nmovimi_valido(psseguro IN NUMBER)
      RETURN NUMBER;

   /*************************************************************
           F_GET_CESTADOCOL: Obtener el valor del campo cestadocol
   **************************************************************/
-- Bug 24278 - APD - 05/12/2012
   FUNCTION f_get_cestadocol(psseguro IN NUMBER, pnmovimi IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

   /*************************************************************
           F_SET_CESTADOCOL: Actualiza el valor del campo cestadocol
   **************************************************************/
-- Bug 24278 - APD - 05/12/2012
   FUNCTION f_set_cestadocol(
      psseguro IN NUMBER,
      pcestadocol IN NUMBER,
      pnmovimi IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

   /*************************************************************
           F_GET_FEFECTO: Obtener el valor del campo fefecto
   **************************************************************/
-- Bug 24278 - APD - 05/12/2012
   FUNCTION f_get_fefecto(psseguro IN NUMBER, pnmovimi IN NUMBER DEFAULT NULL)
      RETURN DATE;
END pac_movseguro;

/

  GRANT EXECUTE ON "AXIS"."PAC_MOVSEGURO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MOVSEGURO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MOVSEGURO" TO "PROGRAMADORESCSI";
