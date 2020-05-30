--------------------------------------------------------
--  DDL for Package PAC_PROVIIBNR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_PROVIIBNR" authid current_user IS
/***************************************************************************
    PAC_LISTA: Package para calcular provisiones.
    ALLIBP01 - Package de procedimientos de B.D.
***************************************************************************/
FUNCTION f_commit_calcul_ibnr(cempres IN NUMBER, aux_factual IN DATE,
    psproces IN NUMBER, pcidioma  IN NUMBER, pcmoneda IN NUMBER) RETURN NUMBER;
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_PROVIIBNR" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_PROVIIBNR" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_PROVIIBNR" TO "PROGRAMADORESCSI";
