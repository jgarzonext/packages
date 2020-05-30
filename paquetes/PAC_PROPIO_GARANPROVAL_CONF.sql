--------------------------------------------------------
--  DDL for Package PAC_PROPIO_GARANPROVAL_CONF
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE PAC_PROPIO_GARANPROVAL_CONF IS
/******************************************************************************
   NOMBRE    : PAC_PROPIO_GARANPROVAL_CONF
   ARCHIVO   : PAC_PROPIO_GARANPROVAL_CONF.PKS
   PROPÓSITO : Package con funciones propias de la funcionalidad de
                Avisos de CONF.

   REVISIONES:
   Ver    Fecha      Autor     Descripción
   ------ ---------- --------- ------------------------------------------------
   1.0    02-09-2016 LPASTOR   Creación del package.
                               Creación de función F_VAL_CAPMIN
   2.0    05/08/2019    CJMR   IAXIS-4200: Validación de preguntas
  ******************************************************************************/

   FUNCTION f_val_capmin(
      ptablas IN VARCHAR2,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      pcgarant IN NUMBER,
      pcactivi IN NUMBER,
      pcgardep IN NUMBER,
      pporcent IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_val_capmax(
      ptablas IN VARCHAR2,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      pcgarant IN NUMBER,
      pcactivi IN NUMBER,
      pcgardep IN NUMBER,
      pporcent IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_salario_min_legal_vigente(
      ptablas IN VARCHAR2,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pfefecto IN DATE,
      pnmovimi IN NUMBER,
      pcgarant IN NUMBER,
      psproces IN NUMBER,
      pnmovima IN NUMBER,
      picapital IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_val_preg_incom(
      ptablas IN VARCHAR2,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      pcgarant IN NUMBER,
      pcactivi IN NUMBER,
      ppreginc IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

   FUNCTION f_val_vigencia(
      ptablas IN VARCHAR2,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      pcgarant IN NUMBER,
      pcactivi IN NUMBER)
      RETURN NUMBER;


   FUNCTION f_valida_dto(
      ptablas IN VARCHAR2,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      pcgarant IN NUMBER,
      pcactivi IN NUMBER)
      RETURN NUMBER;


   FUNCTION f_gar_migraciones(
      ptablas IN VARCHAR2,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      pcgarant IN NUMBER,
      pcactivi IN NUMBER)
      RETURN NUMBER;


   FUNCTION f_val_rec_tarif(
      ptablas IN VARCHAR2,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      pcgarant IN NUMBER,
      pcactivi IN NUMBER)
      RETURN NUMBER;


   -- INI IAXIS-4200 CJMR 05/08/2019
   FUNCTION f_val_preg_val_contrato_rc(
      ptablas IN VARCHAR2,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      pcgarant IN NUMBER,
      pcactivi IN NUMBER)
      RETURN NUMBER;
   -- FIN IAXIS-4200 CJMR 05/08/2019

END pac_propio_garanproval_conf;

/