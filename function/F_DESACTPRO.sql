--------------------------------------------------------
--  DDL for Function F_DESACTPRO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_DESACTPRO" (pcactivi IN NUMBER, pcidioma IN NUMBER,
pttexto IN OUT VARCHAR2)
RETURN NUMBER authid current_user IS
/***********************************************************************
	F_DESACTPRO: Retorna la descripción de la actividad del professional.
	ALLIBMFM
***********************************************************************/
BEGIN
	SELECT tactpro
	INTO	pttexto
	FROM	ACTIVIPROF
	WHERE	cidioma = pcidioma
		AND cactpro = pcactivi;
	RETURN 0;
EXCEPTION
	WHEN others THEN
		RETURN 102020;	-- Activitat inexistent
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_DESACTPRO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_DESACTPRO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_DESACTPRO" TO "PROGRAMADORESCSI";
