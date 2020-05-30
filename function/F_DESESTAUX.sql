--------------------------------------------------------
--  DDL for Function F_DESESTAUX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_DESESTAUX" (pcestaux IN NUMBER, pcidioma IN NUMBER,
ptestaux IN OUT VARCHAR2)
RETURN NUMBER authid current_user IS
/***********************************************************************
	F_DESESTAUX: Obtener la descripción de un estado auxiliar
	ALLIBMFM
***********************************************************************/
BEGIN
	SELECT	testaux
	INTO	ptestaux
	FROM	SUBESTREC
	WHERE	cestaux = pcestaux
		AND cidioma = pcidioma;
	RETURN 0;
EXCEPTION
	WHEN others THEN
		RETURN 100544;	-- Subestat inexistent
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_DESESTAUX" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_DESESTAUX" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_DESESTAUX" TO "PROGRAMADORESCSI";
