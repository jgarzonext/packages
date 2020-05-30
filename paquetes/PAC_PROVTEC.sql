--------------------------------------------------------
--  DDL for Package PAC_PROVTEC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_PROVTEC" AUTHID CURRENT_USER IS
   FUNCTION f_commit_calcul_ppnc(
      cempres IN NUMBER,
      aux_factual IN DATE,
      psproces IN NUMBER,
      pcidioma IN NUMBER,
      pcmoneda IN NUMBER,
      pmodo IN VARCHAR2 DEFAULT 'R')
      RETURN NUMBER;

   FUNCTION f_commit_calcul_ppnc_fracc(
      cempres IN NUMBER,
      aux_factual IN DATE,
      psproces IN NUMBER,
      pcidioma IN NUMBER,
      pcmoneda IN NUMBER,
      pmodo IN VARCHAR2 DEFAULT 'R')
      RETURN NUMBER;

   -- Bug 0026214 - 22/04/2013 - JMF
   FUNCTION f_commit_calcul_ppncrea(
      cempres IN NUMBER,
      aux_factual IN DATE,
      psproces IN NUMBER,
      pcidioma IN NUMBER,
      pcmoneda IN NUMBER,
      pmodo IN VARCHAR2 DEFAULT 'R')
      RETURN NUMBER;

   FUNCTION f_commit_calcul_pestab(
      cempres IN NUMBER,
      aux_factual IN DATE,
      psproces IN NUMBER,
      pcidioma IN NUMBER,
      pcmoneda IN NUMBER,
      pmodo IN VARCHAR2 DEFAULT 'R')
      RETURN NUMBER;

   FUNCTION f_commit_calcul_ibnr(
      cempres IN NUMBER,
      aux_factual IN DATE,
      psproces IN NUMBER,
      pcidioma IN NUMBER,
      pcmoneda IN NUMBER,
      pmodo IN VARCHAR2 DEFAULT 'R')
      RETURN NUMBER;

   FUNCTION f_commit_calcul_pplp(
      cempres IN NUMBER,
      aux_factual IN DATE,
      psproces IN NUMBER,
      pcidioma IN NUMBER,
      pcmoneda IN NUMBER,
      pmodo IN VARCHAR2 DEFAULT 'R')
      RETURN NUMBER;

   ----------------------------------------------------------------------------
-- IBNR_RAM
----------------------------------------------------------------------------
   FUNCTION f_commit_calcul_ibnr_ram(
      pcempres IN NUMBER,
      aux_factual IN DATE,
      psproces IN NUMBER,
      pcidioma IN NUMBER,
      pcmoneda IN NUMBER,
      pmodo IN VARCHAR2 DEFAULT 'R')
      RETURN NUMBER;

   ----------------------------------------------------------------------------
-- IBNER
----------------------------------------------------------------------------
-- Bug 21715 - APD - se crea la funcion
   FUNCTION f_commit_calcul_ibner(
      pcempres IN NUMBER,
      aux_factual IN DATE,
      psproces IN NUMBER,
      pcidioma IN NUMBER,
      pcmoneda IN NUMBER,
      pmodo IN VARCHAR2 DEFAULT 'R')
      RETURN NUMBER;

   ----------------------------------------------------------------------------
-- PTGILS
----------------------------------------------------------------------------
-- Bug 21715 - APD - se crea la funcion
   FUNCTION f_commit_calcul_ptgils(
      pcempres IN NUMBER,
      aux_factual IN DATE,
      psproces IN NUMBER,
      pcidioma IN NUMBER,
      pcmoneda IN NUMBER,
      pmodo IN VARCHAR2 DEFAULT 'R')
      RETURN NUMBER;

--0035670/ 202759: KJSC Nueva funcion F_Commit_calcul_pplpgar
   FUNCTION f_commit_calcul_pplpgar(
      cempres IN NUMBER,
      aux_factual IN DATE,
      psproces IN NUMBER,
      pcidioma IN NUMBER,
      pcmoneda IN NUMBER,
      pmodo IN VARCHAR2 DEFAULT 'R')
      RETURN NUMBER;

-- 0038522/0226513: EEDA Nueva función que el llamado a la función f_difdata, con el return sin el uso de variables.
	FUNCTION f_difdata_consulta(
	   pdatain IN DATE,
	   pdatafin IN DATE,
	   ptipo IN NUMBER,
	   punid IN NUMBER)
    RETURN NUMBER;

END;

/

  GRANT EXECUTE ON "AXIS"."PAC_PROVTEC" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_PROVTEC" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_PROVTEC" TO "PROGRAMADORESCSI";
