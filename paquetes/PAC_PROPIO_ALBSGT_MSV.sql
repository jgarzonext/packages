--------------------------------------------------------
--  DDL for Package PAC_PROPIO_ALBSGT_MSV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_PROPIO_ALBSGT_MSV" AUTHID CURRENT_USER IS
   /******************************************************************************
      NOMBRE:     PAC_PROPIO_ALBSGT_MSV
      PROPÓSITO:  Cuerpo del paquete de las funciones para
                  el cáculo de las preguntas relacionadas con
                  productos de MSV

      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.0        15/10/2013   CML             1. Cáluculo de la edad de los asegurados.
   ******************************************************************************/
   resultado      NUMBER;

   FUNCTION f_edad_asegurado1(
      ptablas IN VARCHAR2,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pfefecto IN DATE,
      pnmovimi IN NUMBER,
      cgarant IN NUMBER,
      psproces IN NUMBER,
      pnmovima IN NUMBER,
      picapital IN NUMBER)
      RETURN NUMBER;

--------------------------------------------------------------------------
   FUNCTION f_edad_asegurado2(
      ptablas IN VARCHAR2,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pfefecto IN DATE,
      pnmovimi IN NUMBER,
      cgarant IN NUMBER,
      psproces IN NUMBER,
      pnmovima IN NUMBER,
      picapital IN NUMBER)
      RETURN NUMBER;

--------------------------------------------------------------------------
   FUNCTION f_edad_tomador(
      ptablas IN VARCHAR2,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pfefecto IN DATE,
      pnmovimi IN NUMBER,
      cgarant IN NUMBER,
      psproces IN NUMBER,
      pnmovima IN NUMBER,
      picapital IN NUMBER)
      RETURN NUMBER;
--------------------------------------------------------------------------
END pac_propio_albsgt_msv; 

/

  GRANT EXECUTE ON "AXIS"."PAC_PROPIO_ALBSGT_MSV" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_PROPIO_ALBSGT_MSV" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_PROPIO_ALBSGT_MSV" TO "PROGRAMADORESCSI";
