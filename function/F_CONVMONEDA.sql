--------------------------------------------------------
--  DDL for Function F_CONVMONEDA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_CONVMONEDA" (pimport IN number, pmonori IN number, pmondest IN number)
REturn number is
  XEURO NUMBER := 166.386;
begin
  IF pmonori = pmondest THEN
    RETURN pimport;
  ELSIF pmonori = 1 and pmondest = 2 THEN
    RETURN f_round(pimport*xeuro,pmondest);
  ELSIF pmonori = 2 and pmondest = 1 THEN
    RETURN f_round(pimport/xeuro,pmondest);
  ELSE
    RETURN pimport;
  END IF;
END;

 
 

/

  GRANT EXECUTE ON "AXIS"."F_CONVMONEDA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_CONVMONEDA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_CONVMONEDA" TO "PROGRAMADORESCSI";
