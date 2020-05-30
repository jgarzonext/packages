--------------------------------------------------------
--  DDL for Function F_DESTARIFA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_DESTARIFA" (pctarifa IN NUMBER, pcidioma IN NUMBER,
pttarifa IN OUT VARCHAR2)
RETURN NUMBER authid current_user IS
/***********************************************************************
	F_DESTARIFA: Descripción de la Tarifa.
	ALLIBMFM
***********************************************************************/
BEGIN
	SELECT ttarifa
	INTO	pttarifa
	FROM	DESTARIFA
	WHERE	cidioma = pcidioma
		AND ctarifa = pctarifa;
	RETURN 0;
EXCEPTION
	WHEN others THEN
		pttarifa := NULL;
		RETURN 100569; 	-- Tarifa inexistent
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_DESTARIFA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_DESTARIFA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_DESTARIFA" TO "PROGRAMADORESCSI";
