--------------------------------------------------------
--  DDL for Function F_OS_USER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_OS_USER" 
RETURN VARCHAR2 AS
	   OS_USER  VARCHAR2(1000);
BEGIN

	 SELECT substr(sys_context('USERENV','OS_USER'),instr(sys_context('USERENV','OS_USER'),'\')+1)
	  INTO OS_USER
	  FROM DUAL;

	 RETURN os_user;
END;

 
 

/

  GRANT EXECUTE ON "AXIS"."F_OS_USER" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_OS_USER" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_OS_USER" TO "PROGRAMADORESCSI";
