--------------------------------------------------------
--  DDL for Function F_DESCAUSA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_DESCAUSA" (pccausin IN NUMBER, pcidioma IN NUMBER,
tnom IN OUT VARCHAR2)
RETURN NUMBER authid current_user IS
/***********************************************************************
	F_DESCAUSA: Retorna la descripción de la causa del siniestro.
	ALLIBMFM
***********************************************************************/
BEGIN
	SELECT 	tcausin
	INTO	tnom
	FROM	CAUSASINI
	WHERE	cidioma = pcidioma
		AND ccausin = pccausin;
	RETURN 0;
EXCEPTION
	WHEN others THEN
		RETURN 100535;	-- Causa del sinistre inexistent
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_DESCAUSA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_DESCAUSA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_DESCAUSA" TO "PROGRAMADORESCSI";
