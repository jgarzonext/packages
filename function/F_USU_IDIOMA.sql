--------------------------------------------------------
--  DDL for Function F_USU_IDIOMA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_USU_IDIOMA" 
   RETURN NUMBER AUTHID CURRENT_USER
IS
/***********************************************************************
   04/2007  Recuperación del idioma del usuario
         Guardada en la variable de contexto Usuario y atributo "usu_idioma"
***********************************************************************/
   vidioma        VARCHAR2 (20);
   vusu_context   VARCHAR2 (100);
BEGIN
   vusu_context := f_parinstalacion_t ('CONTEXT_USER');
   vidioma :=
           pac_contexto.f_contextovalorparametro (vusu_context, 'usu_idioma');
   RETURN TO_NUMBER (vidioma);
EXCEPTION
   WHEN OTHERS
   THEN
      RETURN 1;
-- svj. Siempre devolvemos un código de idioma.
-- De esta manera si se ejectua desde el Toad o sql plus funcionará aunque no se inicialicen los
-- atributos contextuales.
END; 
 
 

/

  GRANT EXECUTE ON "AXIS"."F_USU_IDIOMA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_USU_IDIOMA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_USU_IDIOMA" TO "PROGRAMADORESCSI";
