--------------------------------------------------------
--  DDL for Function F_DESACTIVI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_DESACTIVI" (pcactivi IN NUMBER, pcramo IN NUMBER, pcidioma IN NUMBER,
pttexto IN OUT VARCHAR2)
RETURN NUMBER authid current_user IS
/***********************************************************************
	F_DESACTIVI: Retorna la descripción de la actividad del seguro.
	ALLIBMFM
***********************************************************************/
BEGIN
	SELECT tactivi
	INTO	pttexto
	FROM	ACTIVISEGU
	WHERE	cidioma = pcidioma
AND cramo   = pcramo
		AND cactivi = pcactivi;
	RETURN 0;
EXCEPTION
	WHEN others THEN
		RETURN 102020;	-- Activitat inexistent
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_DESACTIVI" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_DESACTIVI" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_DESACTIVI" TO "PROGRAMADORESCSI";
