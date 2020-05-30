--------------------------------------------------------
--  DDL for Function TABCOUNT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."TABCOUNT" (
  tab IN VARCHAR2,
  whr IN VARCHAR2 := NULL,
  sch IN VARCHAR2 := NULL)
  RETURN INTEGER
IS
  retval INTEGER;
BEGIN
  EXECUTE IMMEDIATE
   'SELECT COUNT(*)
     FROM ' || NVL (sch, F_USER) || '.' || tab ||
   ' WHERE ' || NVL (whr, '1=1')
   INTO retval;
  RETURN retval;
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."TABCOUNT" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."TABCOUNT" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."TABCOUNT" TO "PROGRAMADORESCSI";
