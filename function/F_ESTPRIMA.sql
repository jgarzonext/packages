--------------------------------------------------------
--  DDL for Function F_ESTPRIMA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_ESTPRIMA" (psseguro IN NUMBER, pfecha IN DATE)
RETURN NUMBER authid current_user IS
/***********************************************************************
	F_SEGPRIMA: Calcula la prima anual de una póliza de estudios.
	ALLIBCTR
***********************************************************************/
	pipseg	NUMBER;
BEGIN
	SELECT sum(g.iprianu * nvl(r.nasegur,1))
	INTO	pipseg
	FROM  ESTRIESGOS r, ESTGARANSEG g
	WHERE (r.fanulac IS NULL OR r.fanulac > pfecha)
		AND r.nriesgo = g.nriesgo
		AND r.sseguro = g.sseguro
		AND (g.ffinefe > pfecha OR g.ffinefe IS NULL)
		AND g.finiefe <= pfecha
		AND g.sseguro = psseguro;
	RETURN pipseg;
EXCEPTION
	WHEN others THEN
		RETURN 0;
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_ESTPRIMA" TO "PROGRAMADORESCSI";
  GRANT EXECUTE ON "AXIS"."F_ESTPRIMA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_ESTPRIMA" TO "CONF_DWH";
