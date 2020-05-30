--------------------------------------------------------
--  DDL for Function F_DESPREGUNTA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_DESPREGUNTA" (
   pcpregun   IN       NUMBER,
   pcidioma   IN       NUMBER,
   ptpregun   OUT      VARCHAR2
)
   RETURN NUMBER AUTHID CURRENT_USER
IS
   xtpregun   preguntas.tpregun%TYPE;
BEGIN
   SELECT tpregun
     INTO xtpregun
     FROM preguntas
    WHERE cpregun = pcpregun
      AND cidioma = pcidioma;

   ptpregun := xtpregun;
   RETURN 0;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      RETURN 102741;      -- PREGUNTA NO EXISTENT A LA TAULA PREGUNTAS
   WHEN OTHERS THEN
      RETURN 101916;      -- ERROR A LA B.D.
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_DESPREGUNTA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_DESPREGUNTA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_DESPREGUNTA" TO "PROGRAMADORESCSI";
