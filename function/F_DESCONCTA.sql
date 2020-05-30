--------------------------------------------------------
--  DDL for Function F_DESCONCTA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_DESCONCTA" (pcconcta IN NUMBER,
pcidioma IN NUMBER, pttexto IN OUT VARCHAR2)
RETURN NUMBER authid current_user IS
/***********************************************************************
	F_DESCONTA: Obtención del Título de un concepto de CTACTE.
	ALLIBMFM
***********************************************************************/
	num_err		NUMBER;
	pctitulo	NUMBER;
BEGIN
	num_err := 100541; 	-- Concepto inexistente
	pttexto := NULL;
	SELECT 	tconcta
	INTO	pttexto
	FROM	CONCEPTOS
	WHERE   cconcta = pcconcta
AND  cidioma = pcidioma;
	RETURN 0;
EXCEPTION
WHEN NO_DATA_FOUND THEN
RETURN 100541;
	WHEN others THEN
		RETURN num_err;
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_DESCONCTA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_DESCONCTA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_DESCONCTA" TO "PROGRAMADORESCSI";
