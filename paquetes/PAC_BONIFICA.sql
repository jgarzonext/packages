--------------------------------------------------------
--  DDL for Package PAC_BONIFICA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_BONIFICA" AUTHID CURRENT_USER IS
    /******************************************************************************
      NOMBRE:     PAC_BONIFICA
      PROPÓSITO:  Càlculs de la bonificació.

      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.0        XX/XX/XXXX   XXX                1. Creación del package.
      2.0        04/06/2009   RSC                2. Bug 10350: APR - Detalle garantías (tarificación)
   ******************************************************************************/

   /******************************************************************
   f_bonifica_poliza.Càlcul de la bonificació de les pòlisses que renoven en data fcaranu
   *******************************************************************/
   FUNCTION f_bonifica_poliza(
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      psseguro IN NUMBER,
      pfcaranu IN DATE,
      pfefecto IN DATE,
      ppercent OUT NUMBER,
      paplica_bonifica OUT NUMBER)
      RETURN NUMBER;

   FUNCTION f_obte_bonifica(
      psseguro IN NUMBER,
      pfcaranu IN DATE,
      ppbonifi OUT NUMBER,
      ppbonifiman OUT NUMBER)
      RETURN NUMBER;

   /********************************************************************************
    Retorna el percentatge de bonificació, null si no en te
   ********************************************************************************/
   FUNCTION calcul_bonificacio_actual(
      psseguro IN NUMBER,
      psproces IN NUMBER,
      pnmovimi IN NUMBER,
      pnmovimi_ant OUT NUMBER)
      RETURN NUMBER;

   FUNCTION calcul_prima_ant(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pnriesgo IN NUMBER,
      pcgarant IN NUMBER,
      pndetgar IN NUMBER DEFAULT NULL)
      RETURN NUMBER;
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_BONIFICA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_BONIFICA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_BONIFICA" TO "PROGRAMADORESCSI";
