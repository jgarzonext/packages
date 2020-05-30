--------------------------------------------------------
--  DDL for Package PAC_CLAUSULAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_CLAUSULAS" AUTHID CURRENT_USER IS
   FUNCTION f_ins_clausulas(
      psseguro IN estseguros.sseguro%TYPE,
      pnriesgo IN estriesgos.nriesgo%TYPE,
      pnmovimi IN movseguro.nmovimi%TYPE,
      pfefecto IN estgaranseg.finiefe%TYPE,
      pcidioma IN NUMBER DEFAULT 2)
      RETURN NUMBER;

   FUNCTION f_valida_clausulas(
      psseguro estseguros.sseguro%TYPE,
      pnriesgo estriesgos.nriesgo%TYPE,
      pcidioma IN NUMBER DEFAULT 2)
      RETURN NUMBER;

   -- Bug 18362 - APD - 17/05/2011 - se crea la funcion
   -- BUG 21546_108727- 23/02/2012 - JLTS - Se quita la utilizacion del objeto mensajes
   FUNCTION f_ins_clauobj(poliza IN OUT ob_iax_detpoliza)
      RETURN NUMBER;

   -- BUG20067:DRA:08/11/2011:Inici
   /***********************************************************************
      Devuelve la descripción de una clausula con parametros
      param in  sclaben  : código de la clausula
      param in  sseguro  : sseguro de la pòliza
      param out mensajes : mensajes de error
      return             : descripción garantia
   ***********************************************************************/
   FUNCTION f_get_descclausulapar(psclagen IN NUMBER, psseguro IN NUMBER, pcidioma IN NUMBER)
      RETURN VARCHAR2;
-- BUG20067:DRA:08/11/2011:Fi
END;

/

  GRANT EXECUTE ON "AXIS"."PAC_CLAUSULAS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_CLAUSULAS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_CLAUSULAS" TO "PROGRAMADORESCSI";
