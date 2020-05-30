--------------------------------------------------------
--  DDL for Function F_DESSUBCODIGO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_DESSUBCODIGO" (pcsubcodi IN VARCHAR2, pcidioma IN NUMBER,
pttexto IN OUT VARCHAR2)
RETURN NUMBER authid current_user IS
/***********************************************************************
	F_DESSUBCODIGO: Retorna la descripció del subcodi.
	ALLIBMFM
***********************************************************************/
BEGIN
	SELECT tsubcod
	INTO	pttexto
	FROM	SUBCODIGO
	WHERE	cidioma = pcidioma
		AND csubcod = pcsubcodi;
	RETURN 0;
EXCEPTION
	WHEN others THEN
		RETURN 103081;	-- Subcodi inexistent
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_DESSUBCODIGO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_DESSUBCODIGO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_DESSUBCODIGO" TO "PROGRAMADORESCSI";
