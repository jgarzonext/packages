--------------------------------------------------------
--  DDL for Function F_STRSTD2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_STRSTD2" (ptentrada IN VARCHAR2, ptsalida IN OUT VARCHAR2)
RETURN NUMBER authid current_user IS
/****************************************************************************
	F_STRSTD: Elimina dos espacios en blanco seguidos en una cadena de caracteres.
	ALLIBMFM.
****************************************************************************/
	xtentrada varchar2(223);
	yentrada  varchar2(223);
	zentrada  varchar2(223);
BEGIN
	ptsalida := replace(ptentrada, '  ', ' ');
	return 0;
EXCEPTION
	WHEN OTHERS THEN
		RETURN 102842;   ---Error en la función f_strstd
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_STRSTD2" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_STRSTD2" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_STRSTD2" TO "PROGRAMADORESCSI";
