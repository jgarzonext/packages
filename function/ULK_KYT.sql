--------------------------------------------------------
--  DDL for Function ULK_KYT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."ULK_KYT" (psseguro IN NUMBER,
	   	  		  		   		   pfcontab IN DATE,
								   pimovimi IN NUMBER)
	   	  		  RETURN NUMBER IS

  kyt  NUMBER;
  prima NUMBER;
  rescate NUMBER;

BEGIN

    BEGIN
       SELECT iprires
         INTO rescate
    	 FROM ulreten
    	WHERE sseguro = psseguro
    	  AND frescat = (SELECT max(frescat)
		  	  		  	   FROM ulreten
						  WHERE sseguro = psseguro
						    AND frescat >= pfcontab);
    EXCEPTION
	  WHEN NO_DATA_FOUND THEN
	  	   RETURN 1;
	END;

   kyt := 1-(pimovimi-rescate)/pimovimi;

   RETURN kyt;

   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       RETURN Null;
     WHEN OTHERS THEN
       RETURN Null;
END ULK_KYT;

 
 

/

  GRANT EXECUTE ON "AXIS"."ULK_KYT" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."ULK_KYT" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."ULK_KYT" TO "PROGRAMADORESCSI";
