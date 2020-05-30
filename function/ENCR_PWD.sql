--------------------------------------------------------
--  DDL for Function ENCR_PWD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."ENCR_PWD" (usu IN VARCHAR2, pwd IN VARCHAR2)
 RETURN RAW
 IS
 xpwd   RAW(10);
 xusu   RAW(10);
BEGIN
	xusu := UTL_RAW.CAST_TO_RAW(usu);
	xpwd := UTL_RAW.CAST_TO_RAW(pwd);
	IF usu = pwd THEN
	   xusu := UTL_RAW.REVERSE(xusu);
	END IF;
	xpwd := UTL_RAW.BIT_XOR(xpwd, xusu);
	RETURN xpwd;
END Encr_Pwd;

 
 

/

  GRANT EXECUTE ON "AXIS"."ENCR_PWD" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."ENCR_PWD" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."ENCR_PWD" TO "PROGRAMADORESCSI";
