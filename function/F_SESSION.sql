--------------------------------------------------------
--  DDL for Function F_SESSION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_SESSION" 
RETURN NUMBER AS
   S_ID NUMBER(20);
BEGIN
  SELECT sys_context('USERENV','SESSIONID')
    INTO S_ID
    FROM DUAL;
RETURN S_ID;
END;

 
 

/

  GRANT EXECUTE ON "AXIS"."F_SESSION" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_SESSION" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_SESSION" TO "PROGRAMADORESCSI";
