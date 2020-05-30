--------------------------------------------------------
--  DDL for Function ULK_RT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."ULK_RT" (psseguro IN NUMBER,
	   	  		  		   		  pfrescat IN DATE,
								  pr       IN NUMBER,
								  pfcontab IN DATE,
								  pimovimi IN NUMBER)
	   	  		  RETURN NUMBER IS

  rt NUMBER;
  SumaPrimas NUMBER;

BEGIN

   SumaPrimas := 0;
   FOR r IN (SELECT imovimi, fcontab
   	   	       FROM ctaseguro
			  WHERE sseguro = psseguro
			    AND cmovimi IN (1,2,4))
   LOOP
       SumaPrimas := SumaPrimas +
	   		   	  r.imovimi * ulk_kyt(psseguro, r.fcontab, r.imovimi) * MONTHS_BETWEEN(pfrescat, r.fcontab);
dbms_output.put_line(SumaPrimas);
   END LOOP;

   rt := pr *
   	  	 (pimovimi * ulk_kyt(psseguro, pfcontab, pimovimi) * MONTHS_BETWEEN(pfrescat, pfcontab) /
		 SumaPrimas);

dbms_output.put_line('rt='||to_char(rt)||', pr='||to_char(pr));

   RETURN rt;

   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       RETURN Null;
     WHEN OTHERS THEN
       RETURN Null;
END ULK_RT;

 
 

/

  GRANT EXECUTE ON "AXIS"."ULK_RT" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."ULK_RT" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."ULK_RT" TO "PROGRAMADORESCSI";
