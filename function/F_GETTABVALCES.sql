--------------------------------------------------------
--  DDL for Function F_GETTABVALCES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_GETTABVALCES" (pcesta IN NUMBER, pfecha IN DATE) RETURN NUMBER IS
  /*
    RSC 16/01/2008
    Retorna el ultimo valor liquidativo menor que una fecha dada para una cesta dada.
  */
  vresultat  NUMBER;

BEGIN
    SELECT t.iuniact INTO vresultat
    FROM TABVALCES t
    WHERE t.ccesta = pcesta
      and t.fvalor = (select max(t2.fvalor)
                      FROM TABVALCES t2
                      WHERE t2.ccesta = t.ccesta
                        AND trunc(t2.fvalor) < trunc(pfecha));

    RETURN vresultat;
EXCEPTION
  WHEN OTHERS THEN
    RETURN 180619;
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_GETTABVALCES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_GETTABVALCES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_GETTABVALCES" TO "PROGRAMADORESCSI";
