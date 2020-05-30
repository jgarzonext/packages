--------------------------------------------------------
--  DDL for Package PAC_PROVTEC_SAM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_PROVTEC_SAM" AUTHID CURRENT_USER IS
   FUNCTION f_comi_ces(
      pscomrea IN NUMBER,
      psseguro IN NUMBER,
      pcgarant IN NUMBER,
      pcomisi IN NUMBER,
      pfefecto IN DATE)
      RETURN NUMBER;

   FUNCTION f_commit_calcul_rrcsam(
      cempres IN NUMBER,
      aux_factual IN DATE,
      psproces IN NUMBER,
      pcidioma IN NUMBER,
      pcmoneda IN NUMBER,
      pmodo IN VARCHAR2 DEFAULT 'R')
      RETURN NUMBER;

   FUNCTION f_commit_calcul_rrcreasam(
      cempres IN NUMBER,
      aux_factual IN DATE,
      psproces IN NUMBER,
      pcidioma IN NUMBER,
      pcmoneda IN NUMBER,
      pmodo IN VARCHAR2 DEFAULT 'R')
      RETURN NUMBER;


END;

/

  GRANT EXECUTE ON "AXIS"."PAC_PROVTEC_SAM" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_PROVTEC_SAM" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_PROVTEC_SAM" TO "PROGRAMADORESCSI";
