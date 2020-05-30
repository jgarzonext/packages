--------------------------------------------------------
--  DDL for Function F_TERMINAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_TERMINAL" 
RETURN VARCHAR2 AS
	   TERMINAL  VARCHAR2(1000);
BEGIN

	 SELECT sys_context('USERENV','TERMINAL')
	  INTO terminal
	  FROM DUAL;

	 RETURN terminal;
END;

 
 

/

  GRANT EXECUTE ON "AXIS"."F_TERMINAL" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_TERMINAL" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_TERMINAL" TO "PROGRAMADORESCSI";
