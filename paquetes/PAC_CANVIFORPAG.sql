--------------------------------------------------------
--  DDL for Package PAC_CANVIFORPAG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_CANVIFORPAG" AUTHID CURRENT_USER IS
------------------------------------------------------------------------------------------
   FUNCTION f_canvi_forpag(
      pcempres IN NUMBER,
      psproces IN NUMBER,
      psseguro IN NUMBER,
      pnsuplem IN NUMBER,
      pfefecto IN DATE,
      pfcaranu IN DATE,
      pfcarpro IN DATE,
      pfsuplem IN DATE,
      pcforpag_ant IN NUMBER,
      pcforpag_nou IN NUMBER,
      pctipreb IN NUMBER,
      paplica IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_ultim_venciment(psseguro IN NUMBER, pfefecto OUT DATE)
      RETURN NUMBER;

   FUNCTION f_anular_pendents(pcempres IN NUMBER, psseguro IN NUMBER, pdata IN DATE)
      RETURN NUMBER;

   FUNCTION f_copiagaran(psseguro IN NUMBER, pfefecto IN DATE, pmovimi IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_recalcula_rebut(
      psproces IN NUMBER,
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pfefecto IN DATE,
      pfcaranu IN DATE)
      RETURN NUMBER;

   FUNCTION f_calcula_fcarpro(
      pfcaranu IN DATE,
      pcforpag IN NUMBER,
      pfefecto IN DATE,
      pfefepol IN DATE)
      RETURN DATE;

   FUNCTION f_duppregun(psseguro NUMBER, pnmovimi NUMBER, pfsuplem DATE)
      RETURN NUMBER;

   FUNCTION f_dupclausules(psseguro NUMBER, pfsuplem DATE, pnmovimi NUMBER)
      RETURN NUMBER;

   FUNCTION f_dupexclucarenseg(psseguro NUMBER, pfsuplem DATE, pnmovimi NUMBER)
      RETURN NUMBER;

   FUNCTION f_dupgaran_ocs(psseguro NUMBER, pfsuplem DATE, pnmovimi NUMBER)
      RETURN NUMBER;

   FUNCTION f_prorrateo(
      psseguro IN NUMBER,
      pfinicial IN DATE,
      pffinal IN DATE,
      pfacnet OUT NUMBER,
      pfacdev OUT NUMBER,
      pfacnetsup OUT NUMBER,
      pfacdevsup OUT NUMBER)
      RETURN NUMBER;

   FUNCTION f_rebut_prima_deveng_ahorro(
      psseguro IN NUMBER,
      pfcarpro_ant IN DATE,
      pfcarpro_nou IN DATE,
      pcforpag_ant IN NUMBER,
      pcforpag_nou IN NUMBER,
      pfcaranu IN DATE,
      pnmovimi IN NUMBER,
      pfsuplem IN DATE,
      pnriesgo IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_fcarpro_final(
      psseguro IN NUMBER,
      pfsuplem IN DATE,
      pcforpag_nou IN NUMBER,
      pcforpag_ant IN NUMBER,
      pfcarpro OUT DATE,
      pfeferec OUT DATE)
      RETURN NUMBER;

   FUNCTION f_canvi_forpag_tf(
      pcempres IN NUMBER,
      psproces IN NUMBER,
      psseguro IN NUMBER,
      pfefecto IN DATE,
      pfcaranu IN DATE,
      pfcarpro IN DATE,
      pfsuplem IN DATE,
      pcforpag_ant IN NUMBER,
      pcforpag_nou IN NUMBER,
      pctipreb IN NUMBER,
      paplica IN NUMBER,
      pnmovimi IN NUMBER)
      RETURN NUMBER;
END;

/

  GRANT EXECUTE ON "AXIS"."PAC_CANVIFORPAG" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_CANVIFORPAG" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_CANVIFORPAG" TO "PROGRAMADORESCSI";
