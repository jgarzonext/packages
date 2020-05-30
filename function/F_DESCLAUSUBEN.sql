--------------------------------------------------------
--  DDL for Function F_DESCLAUSUBEN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_DESCLAUSUBEN" (psclaben IN NUMBER, pcidioma IN NUMBER)
RETURN VARCHAR2 authid current_user IS
ptclaben clausuben.tclaben%type;
BEGIN
	SELECT tclaben
	INTO	ptclaben
	FROM	CLAUSUBEN
	WHERE	cidioma = pcidioma
		AND sclaben = psclaben;
	RETURN ptclaben;
EXCEPTION
	WHEN others THEN
		RETURN NULL;

END;

 
 

/

  GRANT EXECUTE ON "AXIS"."F_DESCLAUSUBEN" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_DESCLAUSUBEN" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_DESCLAUSUBEN" TO "PROGRAMADORESCSI";
