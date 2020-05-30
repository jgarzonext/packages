--------------------------------------------------------
--  DDL for Function F_DESPOBLAC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_DESPOBLAC" (pcpoblac IN NUMBER,pcprovin IN NUMBER,
ptpoblac IN OUT VARCHAR2)
RETURN NUMBER authid current_user IS
/***********************************************************************
	F_DESPOBLAC: Retorna la descripción de la población.
	ALLIBMFM
***********************************************************************/
BEGIN
	SELECT tpoblac
	INTO	ptpoblac
	FROM	POBLACIONES
	WHERE	cprovin = pcprovin
		AND cpoblac = pcpoblac;
	RETURN 0;
EXCEPTION
	WHEN others THEN
		RETURN 102330;	-- Población inexistente
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_DESPOBLAC" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_DESPOBLAC" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_DESPOBLAC" TO "PROGRAMADORESCSI";
