--------------------------------------------------------
--  DDL for Function FF_TIPO_USUARIO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."FF_TIPO_USUARIO" (pcempres IN NUMBER, pcusuario IN VARCHAR2 )
RETURN NUMBER AUTHID current_user IS  
  vtipusu NUMBER;
BEGIN
 SELECT ctipusu
    INTO vtipusu
 FROM USU_AGENTES
 WHERE cusuari = pcusuario
      AND cempres = pcempres;
 
  RETURN vtipusu;  
EXCEPTION
 WHEN OTHERS THEN
  RETURN NULL;
END; 
 
 

/

  GRANT EXECUTE ON "AXIS"."FF_TIPO_USUARIO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."FF_TIPO_USUARIO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."FF_TIPO_USUARIO" TO "PROGRAMADORESCSI";
