--------------------------------------------------------
--  DDL for Function LITERAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."LITERAL" (nliteral IN NUMBER)
	   RETURN VARCHAR2 IS
tliteral VARCHAR2(100);
BEGIN
     SELECT tlitera
	   INTO tliteral
       FROM literales
      WHERE slitera = nliteral
       and cidioma = (SELECT cidioma from usuarios where cusuari = F_USER);

  RETURN tliteral;

EXCEPTION
          WHEN NO_DATA_FOUND THEN
            RETURN Null;
          WHEN OTHERS THEN
            RETURN Null;

END LITERAL;
 
 

/

  GRANT EXECUTE ON "AXIS"."LITERAL" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."LITERAL" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."LITERAL" TO "PROGRAMADORESCSI";
