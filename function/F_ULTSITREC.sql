--------------------------------------------------------
--  DDL for Function F_ULTSITREC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_ULTSITREC" (pnrecibo IN NUMBER, pcestant IN OUT NUMBER,
pcestrec IN OUT NUMBER, pfmovini IN OUT DATE, pfcontab IN OUT DATE,
pcusuari IN OUT VARCHAR2)
RETURN NUMBER authid current_user IS
/************************************************************************
	F_ULTSITREC		Devuelve datos de la última situación de un recibo
			Si no encuentra un recibo retorna un error
			Si no tiene fmovfin a NULL retorna otro error
			Si tiene más de una fmovfin a NULL retorna otro error
	ALLIBADM
**************************************************************************/
	fecha		DATE;
BEGIN
	BEGIN
		SELECT fmovfin
		INTO fecha
		FROM movrecibo
		WHERE nrecibo=pnrecibo;
	EXCEPTION
			WHEN NO_DATA_FOUND THEN
				RETURN 101731; 	-- Recibo no encontrado
			WHEN TOO_MANY_ROWS THEN
				NULL;
	END;
	BEGIN
		SELECT cestant,cestrec,fmovini,fcontab,cusuari
		INTO pcestant,pcestrec,pfmovini,pfcontab,pcusuari
		FROM movrecibo
		WHERE nrecibo=pnrecibo
			AND fmovfin IS NULL;
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			RETURN 101733;   -- No encuentra fmovfin=null
		WHEN TOO_MANY_ROWS THEN
			RETURN 101735;  -- Encuentra mas de una fmovfin nula
	END;
	RETURN 0;
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_ULTSITREC" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_ULTSITREC" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_ULTSITREC" TO "PROGRAMADORESCSI";
