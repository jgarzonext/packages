--------------------------------------------------------
--  DDL for Function F_DESCLABEN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_DESCLABEN" (psclaben IN NUMBER, pcidioma IN NUMBER,
ptclaben IN OUT VARCHAR2)
RETURN NUMBER authid current_user IS
/***********************************************************************
	F_DESCLABEN: Descripción de la clàusula de beneficiari.
	ALLIBMFM
***********************************************************************/
BEGIN
	SELECT tclaben
	INTO	ptclaben
	FROM	CLAUSUBEN
	WHERE	cidioma = pcidioma
		AND sclaben = psclaben;
	RETURN 0;
EXCEPTION
	WHEN others THEN
		ptclaben := NULL;
		RETURN 101806; 	-- Clàusula de beneficiari inexistent
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_DESCLABEN" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_DESCLABEN" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_DESCLABEN" TO "PROGRAMADORESCSI";
