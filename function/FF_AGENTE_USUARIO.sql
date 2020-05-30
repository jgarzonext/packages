--------------------------------------------------------
--  DDL for Function FF_AGENTE_USUARIO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."FF_AGENTE_USUARIO" (pcusuario IN VARCHAR2 )
RETURN NUMBER AUTHID current_user IS
  vcagente NUMBER;
BEGIN
  SELECT cdelega
   INTO vcagente
  FROM USUARIOS
  WHERE cusuari = pcusuario;

  RETURN vcagente;
EXCEPTION
 WHEN OTHERS THEN
  RETURN NULL;
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."FF_AGENTE_USUARIO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."FF_AGENTE_USUARIO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."FF_AGENTE_USUARIO" TO "PROGRAMADORESCSI";
