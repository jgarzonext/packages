--------------------------------------------------------
--  DDL for Function FF_DESPREGUNTA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."FF_DESPREGUNTA" (pcpregun IN NUMBER, pcidioma IN NUMBER)
   RETURN VARCHAR2 AUTHID CURRENT_USER IS
/***********************************************************************
    FF_DESGARANTIA: Retorna la descripción de la pregunta como valor.
    EfrainMarquez
***********************************************************************/
   vttexto        preguntas.tpregun%TYPE;
BEGIN
   SELECT tpregun
     INTO vttexto
     FROM preguntas
    WHERE cidioma = pcidioma
      AND cpregun = pcpregun;

   RETURN vttexto;
EXCEPTION
   WHEN OTHERS THEN
      RETURN NULL;
END;

/

  GRANT EXECUTE ON "AXIS"."FF_DESPREGUNTA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."FF_DESPREGUNTA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."FF_DESPREGUNTA" TO "PROGRAMADORESCSI";
