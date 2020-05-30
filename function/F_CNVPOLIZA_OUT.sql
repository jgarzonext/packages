--------------------------------------------------------
--  DDL for Function F_CNVPOLIZA_OUT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_CNVPOLIZA_OUT" (psseguro NUMBER) RETURN NUMBER IS
/************************************************************
  F_CNVPOLIZA_OUT: Devuelve el num. póliza de HOST dado el sseguro.
				  Devolverá '-1' en caso de ERROR.

*************************************************************/
pcseghos NUMBER;
BEGIN
   SELECT cseghos
   INTO pcseghos
   FROM SEGUROS_ULK
   WHERE sseguro = psseguro;
   return pcseghos;
EXCEPTION
   WHEN OTHERS THEN
      return -1;
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_CNVPOLIZA_OUT" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_CNVPOLIZA_OUT" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_CNVPOLIZA_OUT" TO "PROGRAMADORESCSI";
