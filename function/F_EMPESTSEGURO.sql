--------------------------------------------------------
--  DDL for Function F_EMPESTSEGURO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_EMPESTSEGURO" (wseguro IN NUMBER)
RETURN NUMBER authid current_user IS
 wcempres NUMBER;
BEGIN
 SELECT  c.cempres
   INTO wcempres
 FROM estseguros s, codiram c
 WHERE c.cramo = s.cramo
   AND s.sseguro = wseguro;
 RETURN(wcempres);
END f_empEstSeguro; 
 
 

/

  GRANT EXECUTE ON "AXIS"."F_EMPESTSEGURO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_EMPESTSEGURO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_EMPESTSEGURO" TO "PROGRAMADORESCSI";
