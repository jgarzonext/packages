--------------------------------------------------------
--  DDL for Function F_EMPRES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_EMPRES" RETURN NUMBER
authid current_user IS

/***********************************************************************
   04/2007  Recuperación de la empresa
         Guardada en la variable de contexto Usuario y atributo "Empresa"
***********************************************************************/

  vempres        varchar2(20);
  vusu_context varchar2(100);

BEGIN
    vusu_context := F_parinstalacion_T ('CONTEXT_USER');
    vempres := pac_contexto.f_contextovalorparametro(vusu_context,'empresa');

    RETURN TO_NUMBER(vempres);

EXCEPTION
    WHEN others THEN
        RETURN NULL;
END; 
 
 

/

  GRANT EXECUTE ON "AXIS"."F_EMPRES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_EMPRES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_EMPRES" TO "PROGRAMADORESCSI";
