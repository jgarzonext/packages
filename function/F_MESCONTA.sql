--------------------------------------------------------
--  DDL for Function F_MESCONTA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_MESCONTA" RETURN VARCHAR2 authid current_user IS
/***********************************************************************
	F_MESCONTA: MES EN EL QUE SE DEBEN CONTABILIZAR LOS MOVIMIENTOS.
	ALLIBMFM
***********************************************************************/
	FDATA	VARCHAR2(6);
BEGIN
	SELECT 	SUBSTR(TVALOR, 1, 6)
	INTO	FDATA
	FROM	TABLAS
	WHERE	TCLAVE = 0
		AND NTABLA = 1;
	RETURN FDATA;
EXCEPTION
	WHEN OTHERS THEN
		RETURN '000000';
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_MESCONTA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_MESCONTA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_MESCONTA" TO "PROGRAMADORESCSI";
