--------------------------------------------------------
--  DDL for Function FF_DESCLAUSULA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."FF_DESCLAUSULA" (pnclausula IN NUMBER, psmodo CHAR, pnidioma IN NUMBER)
   RETURN VARCHAR2 IS
   stexto         VARCHAR2(4000);
   nreturn        NUMBER;
BEGIN
   nreturn := f_desclausula(pnclausula, CASE psmodo
                               WHEN 'T' THEN 1
                               ELSE 2
                            END, pnidioma, stexto);

   IF nreturn = 0 THEN
      RETURN stexto;
   ELSE
      RETURN nreturn;
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      RETURN '**';
END;

/

  GRANT EXECUTE ON "AXIS"."FF_DESCLAUSULA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."FF_DESCLAUSULA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."FF_DESCLAUSULA" TO "PROGRAMADORESCSI";
