--------------------------------------------------------
--  DDL for Package Body PAC_PROPIO_ALBVAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_PROPIO_ALBVAL" IS
/***************************************************************
    PAC_PROPIO_ALBVAL_APR: Body del paquete de las funciones
                    de validacion
     REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        04/11/2010   APD               1. Creación del package.
***************************************************************/

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
      RETURN NUMBER IS
      v_ndurcob      NUMBER;
   BEGIN
      IF pcrespue < 0
         OR pcrespue > 100 THEN
         RETURN 1000390;   --El porcentage debe estar comprendido entre 0 y 100%
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PROPIO_ALBVAL_APR.f_valida_porcentaje', 1,
                     'ptablas = ' || ptablas || ' psseguro = ' || psseguro || ' pnriesgo = '
                     || pnriesgo || ' pfefecto = ' || pfefecto || ' pnmovimi = ' || pnmovimi
                     || ' pcgarant = ' || pcgarant || ' psproces = ' || psproces
                     || ' pnmovima = ' || pnmovima || ' picapital = ' || picapital,
                     SQLERRM);
         RETURN 1;
   END f_valida_porcentaje;

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
      RETURN NUMBER IS
      v_test_date    DATE;
   BEGIN
      BEGIN
         v_test_date := TO_DATE(ptrespue, 'dd/mm/yyyy');
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 9901605;   -- Formato de fecha incorrecto (Formato: DD/MM/AAAA)
      END;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PROPIO_ALBVAL.f_valida_formato_fecha', 1,
                     'ptablas = ' || ptablas || ' psseguro = ' || psseguro || ' pnriesgo = '
                     || pnriesgo || ' pfefecto = ' || pfefecto || ' pnmovimi = ' || pnmovimi
                     || ' pcgarant = ' || pcgarant || ' psproces = ' || psproces
                     || ' pnmovima = ' || pnmovima || ' picapital = ' || picapital,
                     SQLERRM);
         RETURN 1;
   END f_valida_formato_fecha;

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
      RETURN NUMBER IS
      v_test_date    DATE;
   BEGIN
      BEGIN
         v_test_date := TO_DATE(ptrespue, 'yyyymmdd');
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 9902153;   -- Formato de fecha incorrecto (Formato: AAAAMMDD)
      END;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PROPIO_ALBVAL.f_valida_formato_fecha', 1,
                     'ptablas = ' || ptablas || ' psseguro = ' || psseguro || ' pnriesgo = '
                     || pnriesgo || ' pfefecto = ' || pfefecto || ' pnmovimi = ' || pnmovimi
                     || ' pcgarant = ' || pcgarant || ' psproces = ' || psproces
                     || ' pnmovima = ' || pnmovima || ' picapital = ' || picapital,
                     SQLERRM);
         RETURN 1;
   END f_valida_formato_fecha_sgt;
-- Fin Bug 18856 - 28/06/2011 - APD -
END pac_propio_albval;

/

  GRANT EXECUTE ON "AXIS"."PAC_PROPIO_ALBVAL" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_PROPIO_ALBVAL" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_PROPIO_ALBVAL" TO "PROGRAMADORESCSI";
