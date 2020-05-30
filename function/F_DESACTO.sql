--------------------------------------------------------
--  DDL for Function F_DESACTO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_DESACTO" (pcacto IN VARCHAR2, pcidioma IN NUMBER)
   RETURN VARCHAR2 IS
/*********************************************************************************
    F_DESACTO: Función que devuelve la descripción del acto.
 ********************************************************************************/
   vtacto         VARCHAR2(150);
BEGIN
   BEGIN
      SELECT tacto
        INTO vtacto
        FROM desactos
       WHERE cacto = UPPER(pcacto)   -- BUG10631:DRA:06/07/2009
         AND cidioma = pcidioma;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         vtacto := NULL;
   END;

   RETURN vtacto;
EXCEPTION
   WHEN OTHERS THEN
      RETURN NULL;
END f_desacto;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_DESACTO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_DESACTO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_DESACTO" TO "PROGRAMADORESCSI";
