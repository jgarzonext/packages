--------------------------------------------------------
--  DDL for Function FF_DESPAIS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."FF_DESPAIS" (pcpais IN NUMBER, pcidioma IN NUMBER DEFAULT f_usu_idioma)
   RETURN VARCHAR2 AUTHID CURRENT_USER IS
   vtexto         despaises.tpais%TYPE;
BEGIN
   vtexto := NULL;

   BEGIN
      SELECT tpais
        INTO vtexto
        FROM despaises
       WHERE cpais = pcpais
         AND cidioma = pcidioma;

      RETURN vtexto;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN ' ';   -- Error al llegir de EMPRESAS
   END;

   RETURN 0;
END;

/

  GRANT EXECUTE ON "AXIS"."FF_DESPAIS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."FF_DESPAIS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."FF_DESPAIS" TO "PROGRAMADORESCSI";
