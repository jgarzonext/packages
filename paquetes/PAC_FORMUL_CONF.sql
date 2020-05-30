/* Formatted on 2019/08/07 22:39 (Formatter Plus v4.8.8) */
--------------------------------------------------------
--  DDL for Package PAC_FORMUL_CONF
--------------------------------------------------------

CREATE OR REPLACE PACKAGE pac_formul_conf
AS
/******************************************************************************
   NAME:       pac_formul_conf
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        02/09/2016    HRE            1. Created this package body.--Nuevo paquete de negocio que contiene las funciones de formulacion de confianza
   2.0        10/06/2019    ECP            IAXIS-3628. Nota Tècnica
******************************************************************************/
   FUNCTION f_aplica_q3 (
      p_nsesion   IN   NUMBER,
      psseguro    IN   NUMBER,
      pscontra    IN   NUMBER,
      pnversio    IN   NUMBER,
      pctramo     IN   NUMBER
   )
      RETURN NUMBER;

   FUNCTION f_tiene_cumulo (p_nsesion IN NUMBER, p_sseguro IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_prima_rcmedica (
      psseguro   IN   NUMBER,
      pnmovimi   IN   NUMBER,
      pnriesgo   IN   NUMBER,
      pcapital   IN   NUMBER
   )
      RETURN NUMBER;

   FUNCTION f_prima_rcclinica (
      psseguro   IN   NUMBER,
      pnmovimi   IN   NUMBER,
      pnriesgo   IN   NUMBER,
      pcapital   IN   NUMBER
   )
      RETURN NUMBER;

   FUNCTION f_tasa_rai (
      psseguro   IN   NUMBER,
      pnmovimi   IN   NUMBER,
      pnriesgo   IN   NUMBER
   )
      RETURN NUMBER;

   FUNCTION f_capita_nota (
      psseguro   IN   NUMBER,
      pnmovimi   IN   NUMBER,
      pnriesgo   IN   NUMBER
   )
      RETURN NUMBER;

   FUNCTION f_tasa_suplemento (
      psseguro   IN   NUMBER,
      pnriesgo   IN   NUMBER,
      pnmovimi   IN   NUMBER,
      pcgarant   IN   NUMBER
   )
      RETURN NUMBER;

--IAXIS-3628 -- ECP -- 10/06/2019
   FUNCTION f_tasa_referencia (
      psseguro   IN   NUMBER,
      pnmovimi   IN   NUMBER,
      pnriesgo   IN   NUMBER
   )
      RETURN NUMBER;

   --IAXIS-3628 -- ECP --    01/08/2019
   FUNCTION f_capital_suplemento (
      psseguro   IN   NUMBER,
      pnriesgo   IN   NUMBER,
      pnmovimi   IN   NUMBER,
      pcgarant   IN   NUMBER
   )
      RETURN NUMBER;

--IAXIS-3628 -- ECP --    01/08/2019
--IAXIS-4802 -- ECP --    07/08/2019
   FUNCTION f_tasa_convenio_rc (
      psseguro   IN   NUMBER,
      pnriesgo   IN   NUMBER,
      pnmovimi   IN   NUMBER
   )
      RETURN NUMBER;
--IAXIS-4802 -- ECP --    07/08/2019
END pac_formul_conf;
--IAXIS-3628 -- ECP -- 10/06/2019
/