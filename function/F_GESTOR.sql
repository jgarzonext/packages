--------------------------------------------------------
--  DDL for Function F_GESTOR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_GESTOR" (pcempres IN NUMBER, pcagente IN NUMBER, pfecha IN DATE)
RETURN NUMBER authid current_user IS
/***************************************************************************
	F_GESTOR	Devuelve "como valor" el gestor de un agente. Si no
				lo encuentra devuelve un 0.
	ALLIBMFM
	Si l'agent no té gestor, serà la delegació
***************************************************************************/
	delega	NUMBER;
	padre		NUMBER;
	tipage	NUMBER:=2;
	fbusca	DATE := pfecha;
BEGIN
	IF pcempres IS NULL OR pcagente IS NULL OR pfecha IS NULL THEN
		RETURN 0;
	ELSE
		IF f_buscapadre(pcempres,pcagente,tipage,fbusca,padre)=0 THEN
			RETURN NVL(padre, 0);
		ELSE
			-- Mirem si és una delegació
			tipage := 1;
			IF f_buscapadre(pcempres,pcagente,tipage,fbusca,
			   padre)=0 THEN
				RETURN NVL(padre, 0);
			ELSE
				RETURN 0;
			END IF;
		END IF;
	END IF;
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_GESTOR" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_GESTOR" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_GESTOR" TO "PROGRAMADORESCSI";
