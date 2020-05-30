--------------------------------------------------------
--  DDL for Function F_DESGARANTIA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_DESGARANTIA" (pcgarant IN NUMBER, pcidioma IN NUMBER,
pttexto IN OUT VARCHAR2)
RETURN NUMBER authid current_user IS
/***********************************************************************
	F_DESGARANTIA: Retorna la descripción de la garantia.
	ALLIBMFM
***********************************************************************/
BEGIN
	SELECT	tgarant
	INTO	pttexto
	FROM	GARANGEN
	WHERE	cidioma = pcidioma
		AND cgarant = pcgarant;
	RETURN 0;
EXCEPTION
	WHEN others THEN
		RETURN 100536;	-- Garantia inexistent
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_DESGARANTIA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_DESGARANTIA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_DESGARANTIA" TO "PROGRAMADORESCSI";
