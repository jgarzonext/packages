--------------------------------------------------------
--  DDL for Function F_ESTREC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_ESTREC" (pnrecibo IN NUMBER)
     RETURN NUMBER IS
  estrec  NUMBER;
BEGIN
   SELECT cestrec
     INTO estrec
        FROM movrecibo
       WHERE nrecibo = pnrecibo
      AND fmovfin is null;
  RETURN estrec;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        Null;
      WHEN OTHERS THEN
        Null;
END F_ESTREC;

 
 

/

  GRANT EXECUTE ON "AXIS"."F_ESTREC" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_ESTREC" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_ESTREC" TO "PROGRAMADORESCSI";
