--------------------------------------------------------
--  DDL for Function F_EMPRESEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_EMPRESEL" RETURN NUMBER
authid current_user IS

/***********************************************************************
   27/07/2007  Recuperación de la empresa  de la consulta.
         Guardada en la variable de contexto Usuario y atributo "empresasel"
***********************************************************************/

  vempres        varchar2(20);
  vusu_context varchar2(100);

BEGIN
    vusu_context := F_parinstalacion_T ('CONTEXT_USER');
    vempres := pac_contexto.f_contextovalorparametro(vusu_context,'empresasel');

    RETURN TO_NUMBER(vempres);

EXCEPTION
    WHEN others THEN
        RETURN NULL;
END; 
 
 

/

  GRANT EXECUTE ON "AXIS"."F_EMPRESEL" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_EMPRESEL" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_EMPRESEL" TO "PROGRAMADORESCSI";
