--------------------------------------------------------
--  DDL for Function ULK_PRIMAS_APORTADAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."ULK_PRIMAS_APORTADAS" (psseguro IN NUMBER,
	   	  		  		   						pfrescat IN DATE)
	   	  		  RETURN NUMBER IS

  ur_numAport  NUMBER;
  PrimasAportadas NUMBER;

BEGIN

   BEGIN
       SELECT nvl(norden, 0)
	     INTO ur_numAport
		 FROM ulreten
		WHERE sseguro = psseguro
		  AND nmovimi = (SELECT MAX(nmovimi)
		  	  		  	   FROM ulreten
						  WHERE sseguro = psseguro);
   EXCEPTION
       WHEN NO_DATA_FOUND THEN
	       ur_numAport := 0;
   END;

   SELECT sum(imovimi)
     INTO PrimasAportadas
	 FROM ctaseguro
	WHERE cmovimi IN (1,2,4)
	  AND sseguro = psseguro
	  AND nnumlin > ur_numAport
	  AND ffecmov < ultima_hora(pfrescat);

   RETURN PrimasAportadas;

   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       RETURN Null;
     WHEN OTHERS THEN
       RETURN Null;
END ULK_PRIMAS_APORTADAS;

 
 

/

  GRANT EXECUTE ON "AXIS"."ULK_PRIMAS_APORTADAS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."ULK_PRIMAS_APORTADAS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."ULK_PRIMAS_APORTADAS" TO "PROGRAMADORESCSI";
