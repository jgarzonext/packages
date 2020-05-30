--------------------------------------------------------
--  DDL for Function DECR_PWD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."DECR_PWD" (usu IN VARCHAR2, pwd IN RAW)
 RETURN VARCHAR2
 IS
 xpwd   RAW(10);
 xusu   RAW(10);
 cpwd   VARCHAR2(20);
BEGIN
	xusu := UTL_RAW.CAST_TO_RAW(usu);
	xpwd := pwd;
	xpwd := UTL_RAW.BIT_XOR(xpwd, xusu);
	IF xpwd = UTL_RAW.REVERSE(xusu) THEN
	   xpwd := UTL_RAW.REVERSE(XPWD);
	END IF;
--	cpwd := UTL_RAW.CAST_TO_VARCHAR2(xpwd);
	cpwd := REPLACE(UTL_RAW.CAST_TO_VARCHAR2(xpwd),CHR(0),'');
	RETURN cpwd;
END Decr_Pwd;

 
 

/

  GRANT EXECUTE ON "AXIS"."DECR_PWD" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."DECR_PWD" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."DECR_PWD" TO "PROGRAMADORESCSI";
