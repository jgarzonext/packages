--------------------------------------------------------
--  DDL for Package PAC_PROPIO_ALBVAL_CONF
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE PAC_PROPIO_ALBVAL_CONF IS
   /******************************************************************************
      NOMBRE:    PAC_PROPIO_ALBVAL_CONF
      PROPÓSITO: Validación de preguntas y garantías.
      REVISIONES:
      Ver        Fecha       Autor  Descripción
      ---------  ----------  -----  ------------------------------------
      1.0        25/11/2016  LPP    Creación
      2.0        22/01/2017  VCG   0001813: Nota Técnica, funcionalidad parámetro Experiencia - Ramo Cumplimiento
   ******************************************************************************/

   FUNCTION f_val_preg_no_modif_sup(
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
      ptrespue IN VARCHAR2,
      pcpregun IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_val_porcen_contragar(
      ptablas IN VARCHAR2,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pfefecto IN DATE,
      pnmovimi IN NUMBER,
      cgarant IN NUMBER,
      psproces IN NUMBER,
      pnmovima IN NUMBER,
      picapital IN NUMBER,
      pcrespue IN NUMBER,
      ptrespue IN VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_val_exento_contragar(
      ptablas IN VARCHAR2,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pfefecto IN DATE,
      pnmovimi IN NUMBER,
      cgarant IN NUMBER,
      psproces IN NUMBER,
      pnmovima IN NUMBER,
      picapital IN NUMBER,
      pcrespue IN NUMBER,
      ptrespue IN VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_val_gest_comer(
      ptablas IN VARCHAR2,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pfefecto IN DATE,
      pnmovimi IN NUMBER,
      cgarant IN NUMBER,
      psproces IN NUMBER,
      pnmovima IN NUMBER,
      picapital IN NUMBER,
      pcrespue IN NUMBER,
      ptrespue IN VARCHAR2)
      RETURN NUMBER;
 --Ini-Qtracker 0001813-VCG-22/01/2018- Se elimina la pregunta 6551
 /* FUNCTION f_val_anyo_cargue(
      ptablas IN VARCHAR2,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pfefecto IN DATE,
      pnmovimi IN NUMBER,
      cgarant IN NUMBER,
      psproces IN NUMBER,
      pnmovima IN NUMBER,
      picapital IN NUMBER,
      pcrespue IN NUMBER,
      ptrespue IN VARCHAR2)
      RETURN NUMBER;*/
 --Fin-Qtracker 0001813-VCG-22/01/2018- Se elimina la pregunta 6551
   FUNCTION f_valida_dto(
      ptablas IN VARCHAR2,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pfefecto IN DATE,
      pnmovimi IN NUMBER,
      cgarant IN NUMBER,
      psproces IN NUMBER,
      pnmovima IN NUMBER,
      picapital IN NUMBER,
      pcrespue IN NUMBER,
      ptrespue IN VARCHAR2)
      RETURN NUMBER;


   FUNCTION f_valida_consorcio(
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
      ptrespue IN VARCHAR2,
      pcpregun IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_valida_minimo(
      ptablas IN VARCHAR2,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pfefecto IN DATE,
      pnmovimi IN NUMBER,
      cgarant IN NUMBER,
      psproces IN NUMBER,
      pnmovima IN NUMBER,
      picapital IN NUMBER,
      pcrespue IN NUMBER,
      ptrespue IN VARCHAR2,
      pminimo IN NUMBER)
      RETURN NUMBER;

     FUNCTION f_val_nit_contratante(
      ptablas IN VARCHAR2,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pfefecto IN DATE,
      pnmovimi IN NUMBER,
      cgarant IN NUMBER,
      psproces IN NUMBER,
      pnmovima IN NUMBER,
      picapital IN NUMBER,
      pcrespue IN NUMBER,
      ptrespue IN VARCHAR2)
      RETURN NUMBER;

    FUNCTION f_val_preg_valor(
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
     ptrespue IN VARCHAR2,
     pcpregun IN NUMBER)
     RETURN NUMBER;

-- Ini IAXIS-3628 -- ECP -- 27/07/2019
FUNCTION f_val_preg_recargo(
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
     ptrespue IN VARCHAR2,
     pcpregun IN NUMBER)
     RETURN NUMBER;
     -- Fin  IAXIS-3628 -- ECP -- 27/07/2019


END;

/