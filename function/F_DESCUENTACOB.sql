--------------------------------------------------------
--  DDL for Function F_DESCUENTACOB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_DESCUENTACOB" (pccobban IN NUMBER, pncuenta IN OUT NUMBER)
RETURN NUMBER authid current_user IS
error NUMBER;
BEGIN
SELECT ncuenta
INTO pncuenta
FROM COBBANCARIO
WHERE ccobban = pccobban;
RETURN 0;
EXCEPTION
WHEN no_data_found THEN
	RETURN 102374;		-- Cobrador bancari no trobat a COBBANCARIO
WHEN others THEN
	RETURN 101916;		-- Error a la Base de Dades
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_DESCUENTACOB" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_DESCUENTACOB" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_DESCUENTACOB" TO "PROGRAMADORESCSI";
