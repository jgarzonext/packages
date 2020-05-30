--------------------------------------------------------
--  DDL for Function F_SEGPRIMA2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_SEGPRIMA2" (psseguro IN NUMBER, pfecha IN DATE)
RETURN NUMBER authid current_user IS
/***********************************************************************
	F_SEGPRIMA: Calcula la prima anual de una póliza.
	ALLIBCTR
	Modificació: La taula GARANCOLEC no existeix ni el camp NASEGUR
***********************************************************************/
	pipseg	NUMBER;
BEGIN
	SELECT sum(g.iprianu * nvl(r.nasegur,1))
	INTO	pipseg
	FROM  RIESGOS r, GARANSEG g
	WHERE (r.fanulac IS NULL OR r.fanulac > pfecha)
		AND r.nriesgo = g.nriesgo
		AND r.sseguro = g.sseguro
		AND g.nmovimi in
		(SELECT max(nmovimi)
		FROM  GARANSEG
		WHERE (ffinefe > pfecha OR ffinefe IS NULL)
			AND finiefe <= pfecha
			AND sseguro = psseguro)
		AND g.sseguro = psseguro;
	RETURN pipseg;
EXCEPTION
	WHEN others THEN
		RETURN 0;
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_SEGPRIMA2" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_SEGPRIMA2" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_SEGPRIMA2" TO "PROGRAMADORESCSI";
