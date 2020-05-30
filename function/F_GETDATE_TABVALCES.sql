--------------------------------------------------------
--  DDL for Function F_GETDATE_TABVALCES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_GETDATE_TABVALCES" (pcesta IN NUMBER, pfecha IN DATE) RETURN DATE IS
  /*
    RSC 16/01/2008
    Retorna la fecha del ultimo valor liquidativo menor que una fecha dada para una cesta dada.
  */
  vresultat  DATE;

BEGIN
    select max(fvalor) INTO vresultat
    FROM TABVALCES
    WHERE ccesta = pcesta
      AND trunc(fvalor) < trunc(pfecha);

    RETURN vresultat;
EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_GETDATE_TABVALCES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_GETDATE_TABVALCES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_GETDATE_TABVALCES" TO "PROGRAMADORESCSI";
