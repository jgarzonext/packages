--------------------------------------------------------
--  DDL for Function F_DESRAMO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_DESRAMO" (pccodram IN NUMBER, pcidioma IN NUMBER,
ptdescri IN OUT VARCHAR2)
RETURN NUMBER authid current_user IS
/***********************************************************************
	F_DESRAMO: Descripción del Ramo.
	ALLIBMFM
***********************************************************************/
BEGIN
	SELECT	tramo
	INTO	ptdescri
	FROM	RAMOS
	WHERE	cidioma = pcidioma
		AND cramo = pccodram;
	RETURN 0;
EXCEPTION
	WHEN others THEN
		ptdescri := NULL;
		RETURN 100502; 	-- Ram inexistent
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_DESRAMO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_DESRAMO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_DESRAMO" TO "PROGRAMADORESCSI";
