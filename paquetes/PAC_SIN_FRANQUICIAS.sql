--------------------------------------------------------
--  DDL for Package PAC_SIN_FRANQUICIAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_SIN_FRANQUICIAS" IS
/******************************************************************************
   NOMBRE    : PAC_SIN_FRANQUICIAS
   ARCHIVO   : PAC_SIN_FRANQUICIAS.sql
   PROPÓSITO : Package con funciones propias de la funcionalidad de Franquicias en siniestros

   REVISIONES:
   Ver    Fecha      Autor     Descripción
   ------ ---------- --------- ------------------------------------------------
   1.0    04-02-2013 D.Ciurans Creación del package.
   2.0    21-03-2013 JLTS      Modificacion del package.
******************************************************************************/

   /*****************************************************************************

    F_FRANQUICIA

    Resuelve la fórmula que recibe.

    param in  P_SSEGURO  Número identificativo interno de SEGUROS
    param in  P_NMOVIMI  Número de moviento en el que estamos
    param in  P_NRIESGO  Riesgo que estamos tratando
    param in  P_CGARANT  Garanrtia que estamos tratando
    param in  P_FECHA    Fecha

    param in out P_CVALOR1  1=Porcentaje; 2=Importe Fijo; 3=Descripción; 4 = SMMLV


    Devuelve      : 0 => Correcto ó 1 => Error.

   *****************************************************************************/
   FUNCTION f_franquicia(
      p_sseguro IN NUMBER,
      p_nmovimi IN NUMBER,
      p_nriesgo IN NUMBER,
      p_cgarant IN NUMBER,
      p_fecha IN NUMBER,
      p_cvalor1 OUT NUMBER,
      p_impvalor1 OUT NUMBER,
      p_cimpmin OUT NUMBER,
      p_impmin OUT NUMBER,
      p_cimpmax OUT NUMBER,
      p_impmax OUT NUMBER)
      RETURN NUMBER;

----------------------------------------------------------------------------
/* Duevuelve el porcentaje o Importe fijo o pimp * (importe final) */
   FUNCTION f_fran_val(
      p_cvalor IN NUMBER,
      p_imp IN NUMBER,
      p_importe IN NUMBER,
      p_fecha IN NUMBER)
      RETURN NUMBER;

----------------------------------------------------------------------------
/* */
   FUNCTION f_fran_tot(
      p_sseguro IN NUMBER,
      p_nmovimi IN NUMBER,
      p_nriesgo IN NUMBER,
      p_cgarant IN NUMBER,
      p_importe IN NUMBER,
      p_fecha IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_cob_ded(p_sseguro IN NUMBER, p_nmovimi IN NUMBER, p_nriesgo IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_get_nmovimi_gar(
      p_sseguro IN NUMBER,
      p_cgarant IN NUMBER,
      p_fecha IN DATE,
      p_nmovimi OUT NUMBER)
      RETURN NUMBER;
END pac_sin_franquicias;

/

  GRANT EXECUTE ON "AXIS"."PAC_SIN_FRANQUICIAS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_SIN_FRANQUICIAS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_SIN_FRANQUICIAS" TO "PROGRAMADORESCSI";
