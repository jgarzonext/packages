--------------------------------------------------------
--  DDL for Package PAC_PROD_RENTAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_PROD_RENTAS" AUTHID CURRENT_USER IS
/****************************************************************************

   NOMBRE:       PAC_PROD_RENTAS
   PROPÓSITO:  Funciones para productos de rentas

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ----------  ----------------------------------
   1.0           -          -         Creació del package
   2.0        11/02/2013   NMM        2.0 24735: (POSDE600)-Desarrollo-GAPS Tecnico-Id 33 - Mesadas Extras diferentes a la propia (preguntas)
****************************************************************************/--JRH
   FUNCTION f_post_penalizacion(psseguro IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_grabar_garantias_rentas(
      pmodo IN NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      pfefecto IN DATE,
      prima_per IN NUMBER,
      pfallaseg IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_graba_propuesta_rentas(
      psproduc IN NUMBER,
      psperson1 IN NUMBER,
      pcdomici1 IN NUMBER,
      psperson2 IN NUMBER,
      pcdomici2 IN NUMBER,
      pcagente IN NUMBER,
      pcidioma IN NUMBER,
      pfefecto IN DATE,
      pnduraci IN NUMBER,
      pfvencim IN DATE,
      pcforpag IN NUMBER,
      pcbancar IN VARCHAR2,
      psclaben IN NUMBER,
      ptclaben IN VARCHAR2,
      prima_per IN NUMBER,
      pfallaseg IN NUMBER,
      tab_pregun pac_prod_comu.t_preguntas,
      pforpagorenta IN NUMBER,
      psseguro IN OUT NUMBER)
      RETURN NUMBER;

-- JRH 11/2007 Lo hemos puesto en el comu
   --FUNCTION f_programa_revision_renovacion(psseguro IN NUMBER, pndurper IN NUMBER, ppinttec IN NUMBER,pcapital IN Number)
  -- RETURN NUMBER;

   -- JRH 11/2007 Lo hemos puesto en el comu
--   PROCEDURE p_revision_renovacion(pfecha IN DATE, psproduc IN NUMBER, psproces IN NUMBER);
   FUNCTION f_leer_nmesextra(
      pnmesextra IN VARCHAR2,
      pnmes1 OUT NUMBER,
      pnmes2 OUT NUMBER,
      pnmes3 OUT NUMBER,
      pnmes4 OUT NUMBER,
      pnmes5 OUT NUMBER,
      pnmes6 OUT NUMBER,
      pnmes7 OUT NUMBER,
      pnmes8 OUT NUMBER,
      pnmes9 OUT NUMBER,
      pnmes10 OUT NUMBER,
      pnmes11 OUT NUMBER,
      pnmes12 OUT NUMBER)
      RETURN NUMBER;

   FUNCTION f_set_nmesextra(psseguro IN NUMBER, pmesesextra IN VARCHAR2)
      RETURN NUMBER;

---------------------------------------------------------------------------
-- 24735.NMM.i
   FUNCTION f_leer_imesextra(
      pimesextra IN VARCHAR2,
      pimes1 OUT NUMBER,
      pimes2 OUT NUMBER,
      pimes3 OUT NUMBER,
      pimes4 OUT NUMBER,
      pimes5 OUT NUMBER,
      pimes6 OUT NUMBER,
      pimes7 OUT NUMBER,
      pimes8 OUT NUMBER,
      pimes9 OUT NUMBER,
      pimes10 OUT NUMBER,
      pimes11 OUT NUMBER,
      pimes12 OUT NUMBER)
      RETURN NUMBER;

   --
   FUNCTION f_set_imesextra(psseguro IN NUMBER, pimesesextra IN VARCHAR2)
      RETURN NUMBER;
-- 24735.NMM.i
---------------------------------------------------------------------------
END pac_prod_rentas;

/

  GRANT EXECUTE ON "AXIS"."PAC_PROD_RENTAS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_PROD_RENTAS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_PROD_RENTAS" TO "PROGRAMADORESCSI";
