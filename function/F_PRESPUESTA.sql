--------------------------------------------------------
--  DDL for Function F_PRESPUESTA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_PRESPUESTA" (pcpregun IN NUMBER, pcrespue IN NUMBER,
pcgrupo IN NUMBER)
RETURN NUMBER authid current_user IS
/***********************************************************************
	F_PRESPUESTA: Retorna el percentatge corresponent a una certa
		resposta.
	ALLIBCTR - Gestión de datos referentes a los seguros
***********************************************************************/
	percen	NUMBER;
BEGIN
	SELECT ptarifa INTO percen
	FROM 	RESTARIFAS
	WHERE cpregun = pcpregun
		AND crespue = pcrespue
		AND (cgrupo = pcgrupo OR pcgrupo IS NULL);
	RETURN(percen);
EXCEPTION
	WHEN others THEN
		RETURN null;
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_PRESPUESTA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_PRESPUESTA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_PRESPUESTA" TO "PROGRAMADORESCSI";
