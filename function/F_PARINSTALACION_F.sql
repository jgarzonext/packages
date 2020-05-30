--------------------------------------------------------
--  DDL for Function F_PARINSTALACION_F
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_PARINSTALACION_F" (p_cparame IN VARCHAR2)
   RETURN DATE AUTHID CURRENT_USER IS
/*************************************************************************
   FUNCTION F_PARINSTALACION_F
   Obtiene el valor de un parámetro de PARINSTALACION de tipo Fecha
     param in p_cparame : código del parámetro
     return             : el valor del parámetro
*************************************************************************/
BEGIN
   -- BUG 8999 - 29/11/2010 - JMP - Se llama al PAC_PARAMETROS
   RETURN pac_parametros.f_parinstalacion_f(UPPER(p_cparame));
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      RETURN NULL;
END f_parinstalacion_f;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_PARINSTALACION_F" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_PARINSTALACION_F" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_PARINSTALACION_F" TO "PROGRAMADORESCSI";
