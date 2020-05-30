--------------------------------------------------------
--  DDL for Function F_EMPSEGURO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_EMPSEGURO" (wseguro IN NUMBER)
RETURN NUMBER authid current_user IS
 wcempres NUMBER;
BEGIN
 SELECT  c.cempres
 INTO wcempres
 FROM seguros s, codiram c
 WHERE c.cramo = s.cramo
 AND s.sseguro = wseguro;
 RETURN(wcempres);
END f_empseguro;

 
 

/

  GRANT EXECUTE ON "AXIS"."F_EMPSEGURO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_EMPSEGURO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_EMPSEGURO" TO "PROGRAMADORESCSI";
