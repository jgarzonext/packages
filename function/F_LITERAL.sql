--------------------------------------------------------
--  DDL for Function F_LITERAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_LITERAL" (numlit IN NUMBER, idioma IN NUMBER)
   RETURN VARCHAR2 IS
   vttexto        axis_literales.tlitera%TYPE;
BEGIN
   BEGIN
      SELECT l.tlitera
        INTO vttexto
        FROM axis_literales_instalacion l
       WHERE l.cidioma = idioma
         AND l.slitera = numlit;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         SELECT l.tlitera
           INTO vttexto
           FROM axis_literales l
          WHERE l.cidioma = idioma
            AND l.slitera = numlit;
   END;

   RETURN vttexto;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      BEGIN
         SELECT l.tlitera
           INTO vttexto
           FROM literales l
          WHERE l.cidioma = idioma
            AND l.slitera = numlit;

         RETURN vttexto;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN TO_CHAR(numlit * 10 + idioma);
      END;
   WHEN OTHERS THEN
      RETURN TO_CHAR(numlit * 10 + idioma);
END f_literal;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_LITERAL" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_LITERAL" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_LITERAL" TO "PROGRAMADORESCSI";
