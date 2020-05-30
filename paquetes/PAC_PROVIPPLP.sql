--------------------------------------------------------
--  DDL for Package PAC_PROVIPPLP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_PROVIPPLP" authid current_user IS
/***************************************************************************
	PAC_LISTA: Package para calcular provisiones.
	ALLIBP01 - Package de procedimientos de B.D.
***************************************************************************/
FUNCTION f_commit_calcul_pplp(cempres IN NUMBER, aux_factual IN DATE,
    psproces IN NUMBER, pcidioma  IN NUMBER, pcmoneda IN NUMBER) RETURN NUMBER;
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_PROVIPPLP" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_PROVIPPLP" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_PROVIPPLP" TO "PROGRAMADORESCSI";
