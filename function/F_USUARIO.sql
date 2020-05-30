--------------------------------------------------------
--  DDL for Function F_USUARIO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_USUARIO" (pcusuari IN NUMBER,
pcidioma OUT NUMBER, pcempresa OUT NUMBER, ptusunom OUT VARCHAR2,
pcprovin OUT NUMBER, pcpoblac OUT NUMBER)
RETURN NUMBER authid current_user IS
/***********************************************************************
	F_USUARIO:  Retorna los datos descriptivos de un usuario
( idioma, empresa, nombre, provincia y población ().
	ALLIBMFM
***********************************************************************/
BEGIN
	SELECT  cidioma, cempres, tusunom, cprovin, cpoblac
	INTO	pcidioma, pcempresa, ptusunom, pcprovin, pcpoblac
	FROM	USUARIOS
	WHERE	cusuari = pcusuari;
	RETURN 0;
EXCEPTION
	WHEN others THEN
		RETURN 102610;	-- Usuario inexistente
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_USUARIO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_USUARIO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_USUARIO" TO "PROGRAMADORESCSI";
