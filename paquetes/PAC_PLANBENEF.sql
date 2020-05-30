--------------------------------------------------------
--  DDL for Package PAC_PLANBENEF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_PLANBENEF" AS
/******************************************************************************
   NOMBRE:       PAC_PLANBENEF
   PROPÓSITO:  Funciones necesarias para guardar/obtener informacion de los
               descuentos por plan de beneficios

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        10/04/2013   APD               1. Creación del package.
   2.0        10/04/2013   APD               2. 0026662: LCOL - AUT - Plan de beneficios
   3.0        20/05/2013   FAC               3. 0026638: FAC LCOL - TEC - Cartera para Autos. (id 176-19)
******************************************************************************/

   /*************************************************************************
      FUNCTION f_get_planbenef
         Función que devuelve el codigo del plan de beneficios
         param in ptablas   : Modo de acceso ('EST','CAR','POL')
         param in psseguro  : Identificador del seguro
         param in pnriesgo  : Identificador del riesgo
         param in pnmovimi  : Numero de movimiento
         return             : Codigo del plan de beneficios
   *************************************************************************/
   FUNCTION f_get_planbenef(
      ptablas IN VARCHAR2,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
      FUNCTION f_garant_planbenef
         Función que indica si una garantia pertenece a un plan de beneficio
         param in pcempres : Codigo de empresa
         param in pcplan : Codigo del plan de beneficio
         param in pcaccion : Acción sobre la que se aplica el descuento del plan (v.f. 1130)
         param in cgarant : Codigo de garantia
         return             : 0 -> La garantia no pertenece al plan de beneficio
                              1 -> La garantia si pertenece al plan de beneficio
                              num_err -> S'ha produit un error
   *************************************************************************/
   FUNCTION f_garant_planbenef(
      pcempres IN NUMBER,
      pcplan IN NUMBER,
      pcaccion IN NUMBER,
      pcgarant IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
      FUNCTION f_capital_planbenef
         Función que devuelve el capital de una garantia de un plan de beneficio
         param in pcempres : Codigo de empresa
         param in pcplan : Codigo del plan de beneficio
         param in pcaccion : Acción sobre la que se aplica el descuento del plan (v.f. 1130)
         param in cgarant : Codigo de garantia
         return             : Capital de la garantia
   *************************************************************************/
   FUNCTION f_capital_planbenef(
      pcempres IN NUMBER,
      pcplan IN NUMBER,
      pcaccion IN NUMBER,
      pcgarant IN NUMBER)
      RETURN NUMBER;

   --BUG 0026638: FAC LCOL - TEC - Cartera para Autos. (id 176-19)
   /*************************************************************************
      FUNCTION f_autos_siniestros
         Función que devuelve el numero de siniestros que tiene una poliza en determinado tiempo
         param in ptablas
         param in psseguro :
         param in pnriesgo :
         param in pfefecto :
         param in pnmovimi
         param in pcgarant
         param in psproces
         param in pnmovima
         param in picapital
         param in pcpregun
         return             : numero de siniestros
   *************************************************************************/
   FUNCTION f_autos_siniestros(
      ptablas IN VARCHAR2,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pfefecto IN DATE,
      pnmovimi IN NUMBER,
      pcgarant IN NUMBER,
      psproces IN NUMBER,
      pnmovima IN NUMBER,
      picapital IN NUMBER,
      pcpregun IN NUMBER)
      RETURN NUMBER;

   -- Bug 26638/160974 - 19/12/2013 - AMC
   FUNCTION f_set_planbeneficios(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      psproces IN NUMBER,
      ptablas IN VARCHAR2)
      RETURN NUMBER;
END pac_planbenef;

/

  GRANT EXECUTE ON "AXIS"."PAC_PLANBENEF" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_PLANBENEF" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_PLANBENEF" TO "PROGRAMADORESCSI";
