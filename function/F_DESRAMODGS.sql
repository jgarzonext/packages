--------------------------------------------------------
--  DDL for Function F_DESRAMODGS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_DESRAMODGS" (pccodram IN NUMBER, pcidioma IN NUMBER,
ptdescri IN OUT VARCHAR2)
RETURN NUMBER authid current_user IS
/***********************************************************************
	F_DESRAMODGS: Descripción del Ramo DGS.
	ALLIBMFM
***********************************************************************/
BEGIN
	SELECT	tramdgs
	INTO	ptdescri
	FROM	DESRAMODGS
	WHERE	cidioma = pcidioma
		AND cramdgs = pccodram;
	RETURN 0;
EXCEPTION
	WHEN others THEN
		ptdescri := NULL;
		RETURN 107114; 	-- Ram inexistent
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_DESRAMODGS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_DESRAMODGS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_DESRAMODGS" TO "PROGRAMADORESCSI";
