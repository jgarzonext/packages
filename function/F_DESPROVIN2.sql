--------------------------------------------------------
--  DDL for Function F_DESPROVIN2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_DESPROVIN2" (pcprovin IN NUMBER, pcpais IN NUMBER)
   RETURN VARCHAR2 AUTHID CURRENT_USER IS
/*
   Función que devuelve la descripción de la provincia
*/
   ptprovin       VARCHAR2(100) := NULL;
BEGIN
   SELECT tprovin
     INTO ptprovin
     FROM provincias
    WHERE cprovin = pcprovin;

   RETURN ptprovin;
EXCEPTION
   WHEN OTHERS THEN
      RETURN ' ';   -- Provincia o país inexistente
END;

/

  GRANT EXECUTE ON "AXIS"."F_DESPROVIN2" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_DESPROVIN2" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_DESPROVIN2" TO "PROGRAMADORESCSI";
