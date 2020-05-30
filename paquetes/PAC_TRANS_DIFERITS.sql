--------------------------------------------------------
--  DDL for Package PAC_TRANS_DIFERITS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_TRANS_DIFERITS" 
IS
   FUNCTION f_valida (psseguro IN NUMBER,data IN DATE) RETURN NUMBER;
   PROCEDURE p_traspaso_diferits (pdata IN DATE, pcramo NUMBER  DEFAULT NULL,
                                  pcmodali NUMBER  DEFAULT NULL, pctipseg NUMBER  DEFAULT NULL,
                                  pccolect NUMBER DEFAULT NULL);
END pac_trans_diferits;

 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_TRANS_DIFERITS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_TRANS_DIFERITS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_TRANS_DIFERITS" TO "PROGRAMADORESCSI";
