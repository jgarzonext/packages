--------------------------------------------------------
--  DDL for Function F_CAPEQUIP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_CAPEQUIP" (pcempres IN NUMBER, pcagente IN
		  NUMBER,pfecha IN DATE)
RETURN NUMBER authid current_user IS
/***************************************************************************
	F_CAPEQUIP:	Devuelve "como valor" el jefe de equipo de un agente.
	ALLIBMFM
***************************************************************************/
	padre		NUMBER;
	tipage	NUMBER:= 7;
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

  GRANT EXECUTE ON "AXIS"."F_CAPEQUIP" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_CAPEQUIP" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_CAPEQUIP" TO "PROGRAMADORESCSI";
