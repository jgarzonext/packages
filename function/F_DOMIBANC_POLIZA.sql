--------------------------------------------------------
--  DDL for Function F_DOMIBANC_POLIZA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_DOMIBANC_POLIZA" ( psseguro IN NUMBER,
				tbanco OUT VARCHAR2,
				toficina OUT VARCHAR2,
				diroficina OUT VARCHAR2,
				poblacion OUT VARCHAR2,
				numcuenta  OUT VARCHAR2)
RETURN NUMBER authid current_user IS
--
--
-- Librería
--  			Obtiene los datos de domiciliación bancaria del documento de
--                     poliza que se trate.

BEGIN
	BEGIN
		SELECT o.tbanco, o.toficin, o.tdirecc, o.tpobla1, substr(s.cbancar,11,9)
		INTO tbanco, toficina, diroficina, poblacion, numcuenta
		FROM seguros s, oficinas o
		WHERE s.sseguro = psseguro AND
		      to_number(substr(s.cbancar,1,4)) = o.cbanco AND
			  to_number(substr(s.cbancar,5,4)) = o.coficin;
	EXCEPTION
	    WHEN NO_DATA_FOUND THEN
		     NULL;
		WHEN OTHERS THEN
			RETURN 101919; -- error al acceder a la tabla SEGUROS
	END;
	RETURN 0;
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_DOMIBANC_POLIZA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_DOMIBANC_POLIZA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_DOMIBANC_POLIZA" TO "PROGRAMADORESCSI";
