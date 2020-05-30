--------------------------------------------------------
--  DDL for Function F_REDUCIDO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_REDUCIDO" (psseguro IN NUMBER)
RETURN NUMBER authid current_user IS
	numero	NUMBER;
BEGIN
	SELECT COUNT(*)
	INTO numero
	FROM movseguro
	WHERE sseguro=psseguro
	  AND cmotmov=251;		--Reducción de capital
	IF numero>0 THEN
		RETURN 1;
	END IF;
	RETURN 0;
END;

 
 

/

  GRANT EXECUTE ON "AXIS"."F_REDUCIDO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_REDUCIDO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_REDUCIDO" TO "PROGRAMADORESCSI";
