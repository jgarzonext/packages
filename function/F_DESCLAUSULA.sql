--------------------------------------------------------
--  DDL for Function F_DESCLAUSULA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_DESCLAUSULA" (psclagen IN NUMBER, pntexto IN NUMBER,
pcidioma IN NUMBER, pttexto IN OUT VARCHAR2)
RETURN NUMBER authid current_user IS
/***********************************************************************
	F_DESPRODUCTO: Obtención del Título o Rótulo de una Cláusula.
	ALLIBMFM
***********************************************************************/
	num_err		NUMBER;
	pctitulo	NUMBER;
BEGIN
	num_err := 101789; 	-- Cláusula inexistent
	pttexto := NULL;
	SELECT DECODE(pntexto, 1, tclatit, 2, tclatex)
	INTO	pttexto
	FROM	CLAUSUGEN
	WHERE	sclagen = psclagen
		AND cidioma = pcidioma;
	RETURN 0;
EXCEPTION
	WHEN others THEN
		RETURN num_err;
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_DESCLAUSULA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_DESCLAUSULA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_DESCLAUSULA" TO "PROGRAMADORESCSI";
