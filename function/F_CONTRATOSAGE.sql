--------------------------------------------------------
--  DDL for Function F_CONTRATOSAGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_CONTRATOSAGE" (pcagente IN NUMBER, pcramo IN NUMBER)
RETURN NUMBER authid current_user IS
	aux	NUMBER;
BEGIN
	SELECT r.cagente INTO aux
	FROM 	CONTRATOSAGE r, CODIRAM c
	WHERE r.cempres = c.cempres
		AND c.cramo = pcramo
		AND r.cagente = pcagente;
	RETURN 0;
EXCEPTION
	WHEN others THEN
		RETURN 103020;
END;

 
 

/

  GRANT EXECUTE ON "AXIS"."F_CONTRATOSAGE" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_CONTRATOSAGE" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_CONTRATOSAGE" TO "PROGRAMADORESCSI";
