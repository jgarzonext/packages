--------------------------------------------------------
--  DDL for Function F_OBTENER_TIDENTI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_OBTENER_TIDENTI" (pt_docu VARCHAR2) RETURN NUMBER IS

    v_tidenti    NUMBER(1) := null;
    BEGIN
      IF pt_docu = 'D' THEN
         -- NIF
         v_tidenti := 1;
      ELSIF (pt_docu = 'A' OR pt_docu = 'E') THEN
         -- Autorización de residencia
         v_tidenti := 4;
      ELSIF (pt_docu = 'C' OR pt_docu = 'I') THEN
         -- CIF
         v_tidenti := 2;
      ELSIF (pt_docu = 'F' OR pt_docu = 'S') THEN
         -- Menores
         v_tidenti := 6;
      ELSIF pt_docu = 'K' THEN
         -- Menores extranjeros
         v_tidenti := 7;
      ELSIF pt_docu = 'P' THEN
         -- Pasaporte
         v_tidenti := 3;
      ELSIF pt_docu = 'T' THEN
         -- Autorización de residencia 2
         v_tidenti := 5;
      END IF;

      RETURN v_tidenti;

   END;

 
 

/

  GRANT EXECUTE ON "AXIS"."F_OBTENER_TIDENTI" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_OBTENER_TIDENTI" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_OBTENER_TIDENTI" TO "PROGRAMADORESCSI";
