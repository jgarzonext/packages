--------------------------------------------------------
--  DDL for Package Body PK_AUTOM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PK_AUTOM" AS
PROCEDURE inicio(ano_proc IN NUMBER,
                 mes_proc IN NUMBER) IS
BEGIN
	IF iniciar = 0 THEN
		iniciar        := 1;
		actualizar     := TRUE;
		cerrado        := TRUE;
		long_grabada   := 0;
      aaproc         := ano_proc;
      mmproc         := mes_proc;
		segmentos      := 0;
		sub_segmentos  := 0;
		long_grabada   := 0;
		EOF	           := FALSE;
		cond           := FALSE;
    END IF;
END inicio;
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
END pk_autom;

/

  GRANT EXECUTE ON "AXIS"."PK_AUTOM" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PK_AUTOM" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PK_AUTOM" TO "PROGRAMADORESCSI";
