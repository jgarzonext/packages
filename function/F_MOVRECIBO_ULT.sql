--------------------------------------------------------
--  DDL for Function F_MOVRECIBO_ULT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_MOVRECIBO_ULT" (pnrecibo IN NUMBER)
   RETURN NUMBER
IS
   v_smovrec   movrecibo.smovrec%TYPE;
BEGIN
   SELECT MAX (smovrec)
     INTO v_smovrec
     FROM movrecibo
    WHERE nrecibo = pnrecibo AND fmovfin IS NULL;

   RETURN v_smovrec;
EXCEPTION
   WHEN NO_DATA_FOUND
   THEN
      RETURN NULL;
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_MOVRECIBO_ULT" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_MOVRECIBO_ULT" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_MOVRECIBO_ULT" TO "PROGRAMADORESCSI";
