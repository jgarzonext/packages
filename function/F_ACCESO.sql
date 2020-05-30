--------------------------------------------------------
--  DDL for Function F_ACCESO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_ACCESO" (pcusuari IN VARCHAR2, pcnompro IN VARCHAR,
ptaccion IN VARCHAR2)
RETURN NUMBER authid current_user IS
/***********************************************************************
	F_ACCESO: Mirem si tenim accés o no a un cert programa.
		Retorna 0 => Si no té accés, 1 => Si té accés
	ALLIBMFM
***********************************************************************/
	ttexto	ACCESOS.CUSUARI%TYPE;
BEGIN
	SELECT cusuari INTO ttexto
	FROM	ACCESOS
	WHERE	cusuari = pcusuari
		AND cnompro = pcnompro
		AND taccion = ptaccion;
	RETURN 1;
EXCEPTION
	WHEN others THEN
		RETURN 0;
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_ACCESO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_ACCESO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_ACCESO" TO "PROGRAMADORESCSI";
