--------------------------------------------------------
--  DDL for Package PAC_PROVIMAT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_PROVIMAT" authid current_user IS
/***************************************************************************
    PAC_LISTA: Package para calcular provisiones.
    ALLIBP01 - Package de procedimientos de B.D.
***************************************************************************/
  FUNCTION f_commit_provmat(cempres IN NUMBER, aux_factual IN DATE,
    psproces IN NUMBER, pcidioma  IN NUMBER, pcmoneda IN NUMBER) RETURN NUMBER;
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_PROVIMAT" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_PROVIMAT" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_PROVIMAT" TO "PROGRAMADORESCSI";
