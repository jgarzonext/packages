--------------------------------------------------------
--  DDL for Package PAC_PROPIO_ALBVAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_PROPIO_ALBVAL" AUTHID CURRENT_USER IS
/***************************************************************
    PAC_PROPIO_ALBVAL: Especificación del paquete de las funciones
                    de validacion
   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        04/11/2010   APD               1. Creación del package.
***************************************************************/
   resultado      NUMBER;

   /***********************************************************************
      Realiza la validación de que el porcetaje esté comprendido entre 0 y
      100

      param in ptablas   :
      param in psseguro  :
      param in pnriesgo  :
      param in pfefecto  :
      param in pnmovimi  :
      param in pcgarant  :
      param in psproces  :
      param in pnmovima  :
      param in picapital :
      param in pcrespue  :
      param in ptrespue  :
      return             : Number
   ***********************************************************************/
   -- Bug 16095 - 04/11/2010 - APD -
   -- Función que realiza la validación del valor del porcentaje
   FUNCTION f_valida_porcentaje(
      ptablas IN VARCHAR2,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pfefecto IN DATE,
      pnmovimi IN NUMBER,
      pcgarant IN NUMBER,
      psproces IN NUMBER,
      pnmovima IN NUMBER,
      picapital IN NUMBER,
      pcrespue IN NUMBER,
      ptrespue IN VARCHAR)
      RETURN NUMBER;

-- Fin Bug 16095 - 04/11/2010 - APD -

   /***********************************************************************
      Realiza la validación de que el formato de la fecha sea correcto

      param in ptablas   :
      param in psseguro  :
      param in pnriesgo  :
      param in pfefecto  :
      param in pnmovimi  :
      param in pcgarant  :
      param in psproces  :
      param in pnmovima  :
      param in picapital :
      param in pcrespue  :
      param in ptrespue  :
      return             : Number
   ***********************************************************************/
   -- Bug 16095 - 04/11/2010 - APD -
   -- Función que realiza la validación del formato de fecha
   FUNCTION f_valida_formato_fecha(
      ptablas IN VARCHAR2,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pfefecto IN DATE,
      pnmovimi IN NUMBER,
      pcgarant IN NUMBER,
      psproces IN NUMBER,
      pnmovima IN NUMBER,
      picapital IN NUMBER,
      pcrespue IN NUMBER,
      ptrespue IN VARCHAR)
      RETURN NUMBER;

-- Fin Bug 16095 - 04/11/2010 - APD -

   /***********************************************************************
      Realiza la validación de que el formato de la fecha sea correcto

      param in ptablas   :
      param in psseguro  :
      param in pnriesgo  :
      param in pfefecto  :
      param in pnmovimi  :
      param in pcgarant  :
      param in psproces  :
      param in pnmovima  :
      param in picapital :
      param in pcrespue  :
      param in ptrespue  :
      return             : Number
   ***********************************************************************/
   -- Bug 18856 - 28/06/2011 - APD -
   -- Función que realiza la validación del formato de fecha YYYYMMDD
   FUNCTION f_valida_formato_fecha_sgt(
      ptablas IN VARCHAR2,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pfefecto IN DATE,
      pnmovimi IN NUMBER,
      pcgarant IN NUMBER,
      psproces IN NUMBER,
      pnmovima IN NUMBER,
      picapital IN NUMBER,
      pcrespue IN NUMBER,
      ptrespue IN VARCHAR)
      RETURN NUMBER;
-- Fin Bug 18856 - 28/06/2011 - APD -
END pac_propio_albval;
 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_PROPIO_ALBVAL" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_PROPIO_ALBVAL" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_PROPIO_ALBVAL" TO "PROGRAMADORESCSI";
