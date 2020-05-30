--------------------------------------------------------
--  DDL for Function GETUSER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."GETUSER" RETURN VARCHAR2 IS
/***********************************************************************
LMM5570, 08/04/2005.-
   Funció que captura el paràmetre 'client_identifier' de la sessio.
   Si el valor capturat és NULL retorna el valor de la variable getUSER,
   sino retorna el valor capturat.
JFD 17/09/2007 -- hacemos que la función llame a f_user.   
***********************************************************************/

vUser varchar2(20);

BEGIN
	
       vuser := f_user;

	   RETURN vUser;

EXCEPTION
	WHEN others THEN
		RETURN USER;
END; 
 
 

/

  GRANT EXECUTE ON "AXIS"."GETUSER" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."GETUSER" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."GETUSER" TO "PROGRAMADORESCSI";
