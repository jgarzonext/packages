--------------------------------------------------------
--  DDL for Package PAC_CARTERA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_CARTERA" AUTHID CURRENT_USER IS
---------------------------------------------------------------------------------------------
   PROCEDURE continente_contenido(
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      pcactivi IN NUMBER,
      cont IN NUMBER,
      parms_transitorios IN OUT pac_parm_tarifas.parms_transitorios_tabtyb);

---------------------------------------------------------------------------------------------
   PROCEDURE prima_max_min(
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      prima IN OUT NUMBER);

---------------------------------------------------------------------------------------------
   FUNCTION f_garantarifa_sgt(
      pmodo IN VARCHAR2,
      psseguro IN NUMBER,
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pcobjase IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      pctipo IN NUMBER,
      pnduraci IN NUMBER,
      conta_proces IN NUMBER,
      pcdurcob IN NUMBER,
      pfcarpro IN DATE,
      pmes IN VARCHAR2,
      panyo IN NUMBER,
      tipo IN NUMBER,
      pcagrpro IN NUMBER,
      pcmanual IN NUMBER,
      pcactivi IN NUMBER,
      num_risc IN NUMBER,
      pfemisio IN DATE,
      movimiento OUT NUMBER,
      anulado OUT NUMBER,
      pmoneda IN NUMBER,
      parms_transitorios IN OUT pac_parm_tarifas.parms_transitorios_tabtyb,
      pbonifica IN NUMBER,
      paplica_bonifica IN NUMBER,
      psproduc IN NUMBER,
      pcforpag IN NUMBER,
      pidioma IN NUMBER,
      pcgarant_regu IN NUMBER,
      pnorden IN NUMBER,
      pcprimin IN NUMBER,
      piprimin IN NUMBER,
      pcclapri IN NUMBER,
      pnedamar IN NUMBER,
      pciedmar IN NUMBER)
      RETURN NUMBER;

---------------------------------------------------------------------------------------------
   FUNCTION f_anuledad(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pcgarant IN NUMBER,
      pnmovimi IN NUMBER,
      pfiniefe IN DATE,
      pfcarpro IN DATE,
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      pcobjase IN NUMBER,
      pmodo IN VARCHAR2,
      pnedamar IN NUMBER,
      pciedmar IN NUMBER,
      estat_garan OUT VARCHAR2)
      RETURN NUMBER;

---------------------------------------------------------------------------------------------
   FUNCTION f_tarifar_sgt(
      pmoneda IN NUMBER,
      psesion IN NUMBER,
      pcmanual IN NUMBER,
      psseguro IN NUMBER,
      pcgarant IN NUMBER,
      cont IN NUMBER,
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      priesgo IN NUMBER,
      prevcap IN OUT NUMBER,
      tasa IN OUT NUMBER,
      pipritar IN OUT NUMBER,
      piprianu IN OUT NUMBER,
      pcactivi IN NUMBER,
      pnum_risc IN NUMBER,
      mensa IN OUT VARCHAR2,
      parms_transitorios IN OUT pac_parm_tarifas.parms_transitorios_tabtyb)
      RETURN NUMBER;

---------------------------------------------------------------------------------------------
   FUNCTION f_dto_vol(
      psesion IN NUMBER,
      psseguro IN NUMBER,
      pcgarant IN NUMBER,
      cont IN NUMBER,
      prima_total IN NUMBER,
      piprianu IN OUT NUMBER,
      mensa IN OUT VARCHAR2,
      parms_transitorios IN OUT pac_parm_tarifas.parms_transitorios_tabtyb)
      RETURN NUMBER;

---------------------------------------------------------------------------------------------
   FUNCTION f_anular(
      psseguro IN NUMBER,
      pfcaranu IN DATE,
      psproces IN NUMBER,
      pfcontab IN DATE,
      pfemisio IN DATE,
      pnmovimi OUT NUMBER,
      panulado OUT NUMBER)
      RETURN NUMBER;

---------------------------------------------------------------------------------------------
   FUNCTION p_cartera(
      pmoneda IN NUMBER,
      pidioma IN NUMBER,
      pmes IN NUMBER,
      panyo IN NUMBER,
      p_sseguro IN NUMBER,
      p_cramo IN NUMBER,
      p_cmodali IN NUMBER,
      p_ctipseg IN NUMBER,
      p_ccolect IN NUMBER,
      p_ctarman IN NUMBER,
      p_ccobban IN NUMBER,
      p_nrenova IN NUMBER,
      p_ctipreb IN NUMBER,
      p_cforpag IN NUMBER,
      p_nduraci IN NUMBER,
      p_ndurcob IN NUMBER,
      p_cactivi IN OUT NUMBER,
      p_csubpro IN NUMBER,
      p_cobjase IN NUMBER,
      p_cagrpro IN NUMBER,
      p_fefecto IN DATE,
      p_fvencim IN DATE,
      p_fcarpro IN OUT DATE,
      p_fcaranu IN OUT DATE,
      p_nanuali OUT NUMBER,
      p_nfracci OUT NUMBER,
      p_fcarant OUT DATE,
      ppsproces IN NUMBER,
      indice IN OUT NUMBER,
      indice_error IN OUT NUMBER,
      pfemisio IN DATE,
      pcorrecte OUT NUMBER,
      p_sproduc IN NUMBER,
      p_nsuplem IN NUMBER,
      pcgarant_regu IN NUMBER,
      pnorden IN NUMBER,
      pcprimin IN NUMBER,
      piprimin IN NUMBER,
      pcclapri IN NUMBER,
      pnedamar IN NUMBER,
      pciedmar IN NUMBER)
      RETURN NUMBER;

---------------------------------------------------------------------------------------------
   FUNCTION f_garantarifa(
      pmoneda IN NUMBER,
      psseguro IN NUMBER,
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pcobjase IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      pctipo IN NUMBER,
      pnduraci IN NUMBER,
      conta_proces IN NUMBER,
      pcdurcob IN NUMBER,
      pfcarpro IN DATE,
      pmes IN VARCHAR2,
      panyo IN NUMBER,
      tipo IN NUMBER,
      pcagrpro IN NUMBER,
      pcmanual IN NUMBER,
      pcactivi IN NUMBER,
      num_risc IN NUMBER,
      pfemisio IN DATE,
      movimiento OUT NUMBER,
      anulado OUT NUMBER)
      RETURN NUMBER;

---------------------------------------------------------------------------------------------
   FUNCTION f_traspasgar(
      psproces IN NUMBER,
      psseguro IN NUMBER,
      pdata IN DATE,
      pnmovimi IN NUMBER)
      RETURN NUMBER;

---------------------------------------------------------------------------------------------
   FUNCTION f_tarifar(
      pmoneda IN NUMBER,
      psseguro IN NUMBER,
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      pnriesgo IN NUMBER,
      pcobjase IN NUMBER,
      pctarifa IN NUMBER,
      pcformul IN NUMBER,
      picapital IN NUMBER,
      pprecarg IN NUMBER,
      piextrap IN NUMBER,
      pnduraci IN NUMBER,
      pndurcob IN NUMBER,
      tipo IN NUMBER,
      pcagrpro IN NUMBER,
      pipritar IN OUT NUMBER,
      tasa OUT NUMBER,
      piprianu IN OUT NUMBER,
      pcactivi IN NUMBER,
      num_risc IN NUMBER,
      pfcarpro IN DATE,
      ptecnic IN NUMBER,
      ptarifar IN NUMBER,
      pcmanual IN NUMBER,
      pmes IN NUMBER,
      panyo IN NUMBER)
      RETURN NUMBER;

---------------------------------------------------------------------------------------------
   PROCEDURE buscar_respue(
      preg1 IN OUT NUMBER,
      preg2 IN OUT NUMBER,
      preg3 IN OUT NUMBER,
      preg4 IN OUT NUMBER,
      preg5 IN OUT NUMBER,
      preg6 IN OUT NUMBER,
      preg7 IN OUT NUMBER,
      preg8 IN OUT NUMBER,
      preg9 IN OUT NUMBER,
      preg10 IN OUT NUMBER,
      preg11 IN OUT NUMBER,
      preg12 IN OUT NUMBER,
      preg13 IN OUT NUMBER,
      psseguro IN NUMBER,
      tipo IN NUMBER,
      modali IN NUMBER,
      riesgo IN NUMBER,
      pcagrpro IN NUMBER,
      num_risc IN NUMBER);

---------------------------------------------------------------------------------------------
   PROCEDURE verifica_tarifa(
      psseguro IN NUMBER,
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      conta_proces IN NUMBER);

---------------------------------------------------------------------------------------------
   PROCEDURE verifica_tarifa_comunidades(
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pcmanual IN NUMBER,
      pcactivi IN NUMBER,
      pmes IN NUMBER,
      panyo IN NUMBER,
      capital_total OUT NUMBER);

---------------------------------------------------------------------------------------------
   PROCEDURE verifica_garan(
      psseguro IN NUMBER,
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      cte_cto IN OUT NUMBER);

---------------------------------------------------------------------------------------------
   FUNCTION cartera_producte(
      pempresa IN NUMBER,
      psproces_prod IN NUMBER,
      psproces IN NUMBER,
      pmes IN NUMBER,
      panyo IN NUMBER,
      pidioma IN NUMBER,
      pmoneda IN NUMBER,
      pfemisio IN DATE,
      indice OUT NUMBER,
      indice_error OUT NUMBER)
      RETURN NUMBER;

---------------------------------------------------------------------------------------------
   PROCEDURE garantia_regularitzacio(
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      pcprimin OUT NUMBER,
      piprimin OUT NUMBER,
      pcclapri OUT NUMBER,
      pcgarant_regu OUT NUMBER,
      pnorden OUT NUMBER);

---------------------------------------------------------------------------------------------
   FUNCTION f_excepcionsegu(psseguro IN NUMBER, pcconcep IN NUMBER, pcvalor OUT NUMBER)
      RETURN NUMBER;
END;

/

  GRANT EXECUTE ON "AXIS"."PAC_CARTERA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_CARTERA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_CARTERA" TO "PROGRAMADORESCSI";
