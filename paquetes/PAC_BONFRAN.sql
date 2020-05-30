--------------------------------------------------------
--  DDL for Package PAC_BONFRAN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_BONFRAN" IS
/******************************************************************************
   NOMBRE    : PAC_BONFRAN
   ARCHIVO   : PAC_BONFRAN_SPE.sql
   PROP¿SITO : Package con funciones propias de la funcionalidad de Franquicias

   REVISIONES:
   Ver    Fecha      Autor     Descripci¿n
   ------ ---------- --------- ------------------------------------------------
   1.0    16-10-2012 M.Redondo Creaci¿n del package.
   2.0    23-06-2014 S.S.M     Modificaci¿n, se a¿ade parametro  de entrada  pcodgrup
                               a la function f_resuelve_formula
******************************************************************************/

   /*****************************************************************************

    F_RESUELVE_FORMULA

    Resuelve la f¿rmula que recibe.

    param in      : P_ACCION  Codi de l'acci¿ que estem fent:
                              1 = Nova Producci¿
                              2 = Suplement
                              3 = Renovaci¿
                              4 = Cotizaci¿n
                              5 = Siniestros
    param in      : P_SSEGURO  N¿mero identificativo interno de SEGUROS
    param in      : P_FEFECTO  Fecha para validar la versi¿n de Franquicias
    param in      : P_NRIESGO  Riesgo que estamos tratando
    param in      : P_CFORMULA Clave de SGT_FORMULAS que estamos ejecutando
    param in      : P_NMOVIMI  N¿mero de moviento en el que estamos
    param in out  : Resultado de la ejecuci¿n de la f¿rmula
    param in      : pcodgrup  clave grupo tabla bf_bonfranseg

    Devuelve      : 0 => Correcto ¿ 1 => Error.

   *****************************************************************************/
   FUNCTION f_resuelve_formula(
      p_accion IN NUMBER,
      p_sseguro IN NUMBER,
      p_cactivi IN NUMBER,
      psproduc IN NUMBER,
      pcodgrup IN NUMBER,
      p_fefecto IN DATE,
      p_nriesgo IN NUMBER,
      p_cformula IN NUMBER,
      p_nmovimi IN NUMBER,
      p_resultat OUT NUMBER)
      RETURN NUMBER;

----------------------------------------------------------------------------
/* Torna el percentatje que implica el GRUP/SUBGRUP/VERSI¿/NIVELL */
   FUNCTION f_porcen_bonus(
      p_cgrup IN NUMBER,
      p_csubgrup IN NUMBER,
      p_cversion IN NUMBER,
      p_cnivel IN NUMBER)
      RETURN NUMBER;
----------------------------------------------------------------------------
   FUNCTION f_set_deducible(
      pcgrup IN NUMBER,
      pcsubgrup IN NUMBER,
      pcversion IN NUMBER,
      pcnivel IN NUMBER,
      pcvalor1 IN NUMBER,
      pimpvalor1 IN NUMBER,
      pcimpmin IN NUMBER,
      pimpmin IN NUMBER,
      pcimpmax IN NUMBER,
      pimpmax IN NUMBER)
      RETURN NUMBER;
   FUNCTION f_validar_deducible_manual(
      pcgrup IN NUMBER,
      pcsubgrup IN NUMBER,
      pcversion IN NUMBER,
      pcnivel IN NUMBER,
      pcvalor1 OUT NUMBER,
      pimpvalor1 OUT NUMBER,
      pcimpmin OUT NUMBER,
      pimpmin OUT NUMBER,
      pcimpmax OUT NUMBER,
      pimpmax OUT NUMBER)
      RETURN NUMBER;
END pac_bonfran;

/

  GRANT EXECUTE ON "AXIS"."PAC_BONFRAN" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_BONFRAN" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_BONFRAN" TO "PROGRAMADORESCSI";
