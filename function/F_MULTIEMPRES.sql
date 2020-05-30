--------------------------------------------------------
--  DDL for Function F_MULTIEMPRES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_MULTIEMPRES" RETURN NUMBER
authid current_user IS

/***********************************************************************
   04/2007  Recuperación de si un usuario es multi-empresa
         Guardada en la variable de contexto Usuario y atributo "multiempres"
***********************************************************************/

  vmulti        varchar2(20);
  vusu_context varchar2(100);

BEGIN
    vusu_context := F_parinstalacion_T ('CONTEXT_USER');
    vmulti:= pac_contexto.f_contextovalorparametro(vusu_context,'multiempres');

    RETURN TO_NUMBER(nvl( vmulti, 0) ); -- Si no se había inicializado devolvemos un cero que es un usuario NO multiempresa

EXCEPTION
    WHEN others THEN
        RETURN 0; --NO multiempresa
END; 
 
 

/

  GRANT EXECUTE ON "AXIS"."F_MULTIEMPRES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_MULTIEMPRES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_MULTIEMPRES" TO "PROGRAMADORESCSI";
