--------------------------------------------------------
--  DDL for Function FF_STRSTD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."FF_STRSTD" (ptext IN VARCHAR2) RETURN VARCHAR2 authid current_user IS
/****************************************************************************
	F_STRSTD: Transforma una cadena de caracteres con acentos en una cadena
		    sin acentos
	ALLIBMFM.
	Se eliminan también los caracteres ' I ', ' DE ', ' D' '
	Se eliminan tambien los puntos y las comas.
****************************************************************************/
	V_ERROR   NUMBER;
	V_SORTIDA VARCHAR2(32000);
BEGIN
   V_ERROR := F_STRSTD(ptext, V_SORTIDA);

   IF V_ERROR <> 0 THEN
      RETURN(NULL);
   END IF;

   RETURN(V_SORTIDA);
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."FF_STRSTD" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."FF_STRSTD" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."FF_STRSTD" TO "PROGRAMADORESCSI";
