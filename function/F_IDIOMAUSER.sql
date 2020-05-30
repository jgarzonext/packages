--------------------------------------------------------
--  DDL for Function F_IDIOMAUSER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_IDIOMAUSER" (pcusuari IN VARCHAR2 DEFAULT F_USER) RETURN NUMBER AUTHID current_user IS
/****************************************************************************
    11/04/2007 APD
    F_IdiomaUser: Función que devuelve el idioma por defecto del usuario.
****************************************************************************/
  v_cidioma  NUMBER;
BEGIN
	SELECT  cidioma
	INTO	v_cidioma
	FROM	USUARIOS
	WHERE	UPPER(cusuari) = UPPER(pcusuari);

	RETURN v_cidioma;
EXCEPTION
    WHEN OTHERS THEN
        RETURN 2;    -- Si ha habido alguún error devolverá por defecto 2 (Castellano)
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_IDIOMAUSER" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_IDIOMAUSER" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_IDIOMAUSER" TO "PROGRAMADORESCSI";
