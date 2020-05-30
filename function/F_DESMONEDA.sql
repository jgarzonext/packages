--------------------------------------------------------
--  DDL for Function F_DESMONEDA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_DESMONEDA" (pcmoneda IN NUMBER,pcidioma IN NUMBER,
ptmoneda IN OUT VARCHAR2)
RETURN NUMBER authid current_user IS
/***********************************************************************
	F_DESMONEDA: Retorna la descripción de la moneda.
	ALLIBMFM
***********************************************************************/
BEGIN
	SELECT tdescri
	INTO	ptmoneda
	FROM	MONEDAS
	WHERE	cidioma = pcidioma
		AND cmoneda = pcmoneda;
	RETURN 0;
EXCEPTION
	WHEN others THEN
		RETURN 102338;	-- Moneda inexistente
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_DESMONEDA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_DESMONEDA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_DESMONEDA" TO "PROGRAMADORESCSI";
