--------------------------------------------------------
--  DDL for Function F_SEGPRIMA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_SEGPRIMA" (psseguro IN NUMBER, pfecha IN DATE, ptablas IN VARCHAR2 DEFAULT 'SEG')
RETURN NUMBER authid current_user IS
/***********************************************************************
	F_SEGPRIMA: Calcula la prima anual de una póliza.
	ALLIBCTR
	Modificació: La taula GARANCOLEC no existeix ni el camp NASEGUR
***********************************************************************/
	pipseg	NUMBER;
BEGIN

  -----------------------
  --  ptablas = 'EST'  --
  -----------------------
  IF ptablas = 'EST' THEN

	SELECT sum(g.iprianu * nvl(r.nasegur,1))
	INTO	pipseg
	FROM  ESTRIESGOS r, ESTGARANSEG g
	WHERE (r.fanulac IS NULL OR r.fanulac > pfecha)
		AND r.nriesgo = g.nriesgo
		AND r.sseguro = g.sseguro
		AND (g.ffinefe > pfecha OR g.ffinefe IS NULL)
		AND g.finiefe <= pfecha
		AND g.sseguro = psseguro;

  -----------------------
  --  ptablas = 'SOL'  --
  -----------------------
  ELSIF ptablas = 'SOL' THEN

	SELECT sum(g.iprianu * nvl(r.nasegur,1))
	INTO	pipseg
	FROM  SOLRIESGOS r, SOLGARANSEG g
	WHERE r.nriesgo = g.nriesgo
		AND r.ssolicit = g.ssolicit
		AND g.finiefe <= pfecha
		AND g.ssolicit = psseguro;

  ------------------------
  --  ptablas 'reales'  --
  ------------------------
  ELSE

	SELECT sum(g.iprianu * nvl(r.nasegur,1))
	INTO	pipseg
	FROM  RIESGOS r, GARANSEG g
	WHERE (r.fanulac IS NULL OR r.fanulac > pfecha)
		AND r.nriesgo = g.nriesgo
		AND r.sseguro = g.sseguro
		AND (g.ffinefe > pfecha OR g.ffinefe IS NULL)
		AND g.finiefe <= pfecha
		AND g.sseguro = psseguro;

  END IF;

  RETURN pipseg;

EXCEPTION
	WHEN others THEN
		RETURN 0;
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_SEGPRIMA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_SEGPRIMA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_SEGPRIMA" TO "PROGRAMADORESCSI";
