--------------------------------------------------------
--  DDL for Function F_COMERCIAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_COMERCIAL" (pcempres IN NUMBER, pcagente IN
		  NUMBER,pfecha IN DATE)
RETURN NUMBER authid current_user IS
/***************************************************************************
	F_COMERCIAL:	Devuelve "como valor" el comercial de un agente.
	ALLIBMFM
***************************************************************************/
	padre		NUMBER;
	tipage	NUMBER:= 4;
	fbusca	DATE := pfecha;
BEGIN
	IF pcempres IS NULL OR pcagente IS NULL OR pfecha IS NULL THEN
		RETURN 0;
	ELSE
		IF f_buscapadre2(pcempres,pcagente,tipage,fbusca,padre)=0 THEN
			RETURN NVL(padre,0);
		ELSE
			RETURN 0;
		END IF;
	END IF;
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_COMERCIAL" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_COMERCIAL" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_COMERCIAL" TO "PROGRAMADORESCSI";
