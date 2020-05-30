--------------------------------------------------------
--  DDL for Function F_MODELCARTA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_MODELCARTA" (pcmodelo IN NUMBER, pcbloque IN NUMBER,
				pcidioma IN NUMBER)
return varchar authid current_user IS
/***************************************************************************
	P_MODELCARTA: Selecciona el texto del bloque que elegimos de un
			  modelo de carta.
***************************************************************************/
texto  varchar2(2000);
BEGIN
  	SELECT ttextos INTO texto
	FROM DETMODELO
	WHERE cbloque = pcbloque
	AND   cmodelo = pcmodelo
	AND	cidioma = pcidioma;

	return texto;
EXCEPTION
	WHEN OTHERS THEN
		return null;
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_MODELCARTA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_MODELCARTA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_MODELCARTA" TO "PROGRAMADORESCSI";
