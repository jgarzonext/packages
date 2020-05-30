--------------------------------------------------------
--  DDL for Function F_DESCIPSAP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_DESCIPSAP" (pccipsap IN VARCHAR2, pcidioma IN NUMBER,
pttexto IN OUT VARCHAR2)
RETURN NUMBER authid current_user IS
/***********************************************************************
	F_DESCIPSAP: Retorna la descripció de cipsap.
	ALLIBMFM
***********************************************************************/
BEGIN
	SELECT tcipsap
	INTO	pttexto
	FROM	CIPSAP
	WHERE	cidioma = pcidioma
		AND ccipsap = pccipsap;
	RETURN 0;
EXCEPTION
	WHEN others THEN
		RETURN 103081;	-- Subcodi inexistent
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_DESCIPSAP" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_DESCIPSAP" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_DESCIPSAP" TO "PROGRAMADORESCSI";
