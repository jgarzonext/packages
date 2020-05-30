--------------------------------------------------------
--  DDL for Function F_DESUSUARIO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_DESUSUARIO" (pcusuari IN VARCHAR2, tnom IN OUT VARCHAR2)
RETURN NUMBER authid current_user IS
/***********************************************************************
	F_DESCAUSA: Devuelve el nombre del usuario.
	ALLIBMFM
***********************************************************************/
BEGIN
	SELECT 	tusunom
	INTO	tnom
	FROM	USUARIOS
	WHERE	cusuari = pcusuari;
	RETURN 0;
EXCEPTION
  	WHEN others THEN
		RETURN 102610;	-- Usuario no encontrado
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_DESUSUARIO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_DESUSUARIO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_DESUSUARIO" TO "PROGRAMADORESCSI";
