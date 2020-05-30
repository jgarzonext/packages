--------------------------------------------------------
--  DDL for Function F_USER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_USER" 
   RETURN VARCHAR2 AUTHID CURRENT_USER IS
   /***********************************************************************
       MCA 01/2007  Recuperación del usuario guardado
                    en la variable de contexto Usuario

       04/214 NMM  Mantis 27843: CIV998-Vistas materializadas DWH - Incrementales
   ***********************************************************************/
   vuser          VARCHAR2(20);
   vusu_context   VARCHAR2(100);
BEGIN
   vusu_context := f_parinstalacion_t('CONTEXT_USER');
   vuser := pac_contexto.f_contextovalorparametro(vusu_context, 'nombre');
   RETURN(NVL( vuser, USER));
EXCEPTION
   WHEN OTHERS THEN
      RETURN( USER);
END;

/

  GRANT EXECUTE ON "AXIS"."F_USER" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_USER" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_USER" TO "PROGRAMADORESCSI";
