--------------------------------------------------------
--  DDL for Function F_DESESPECIFIC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_DESESPECIFIC" (pcespecif IN NUMBER, pcidioma IN NUMBER,
pttexto IN OUT VARCHAR2)
RETURN NUMBER authid current_user IS
/***********************************************************************
	F_DESSUBCODIGO: Retorna la descripció de l'especific.
	ALLIBMFM
***********************************************************************/
BEGIN
	SELECT tespeci
	INTO	pttexto
	FROM	ESPECIFIC
	WHERE	cidioma = pcidioma
		AND cespeci = pcespecif;
	RETURN 0;
EXCEPTION
	WHEN others THEN
		RETURN 103082;	-- Especif. inexistent
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_DESESPECIFIC" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_DESESPECIFIC" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_DESESPECIFIC" TO "PROGRAMADORESCSI";
