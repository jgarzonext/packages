--------------------------------------------------------
--  DDL for Package Body PK_ENV_COMU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PK_ENV_COMU" AS
PROCEDURE hora(trazas IN UTL_FILE.FILE_TYPE) is
begin
utl_file.put(trazas,TO_CHAR(SYSDATE,'HH24-MI-SS'));
end hora;
PROCEDURE Traza(trazas IN UTL_FILE.FILE_TYPE, depurar IN NUMBER, msg VARCHAR2) IS
BEGIN
	if depurar = 1 then
		utl_file.Put(trazas,msg);
		utl_file.NEW_LINE(trazas);
	end if;
EXCEPTION
	when UTL_FILE.INVALID_PATH THEN
		dbms_output.put_line('(Traza) invalid path');
	when UTL_FILE.INVALID_MODE  THEN
		dbms_output.put_line('(Traza) invalid mode');
	when UTL_FILE.INVALID_OPERATION  THEN
		dbms_output.put_line('(Traza) invalid operation');
	when UTL_FILE.INVALID_FILEHANDLE   THEN
		dbms_output.put_line('(Traza) invalid file Handle');
	when UTL_FILE.WRITE_ERROR   THEN
		dbms_output.put_line('(Traza) Write Error');
	WHEN OTHERS THEN
		dbms_output.put_line('(Traza)' ||sqlerrm);
END Traza;
END pk_env_comu;

/

  GRANT EXECUTE ON "AXIS"."PK_ENV_COMU" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PK_ENV_COMU" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PK_ENV_COMU" TO "PROGRAMADORESCSI";
