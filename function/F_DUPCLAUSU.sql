--------------------------------------------------------
--  DDL for Function F_DUPCLAUSU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_DUPCLAUSU" (psseguro IN NUMBER, pfefecto IN DATE,
pmovimi IN NUMBER)
RETURN NUMBER authid current_user IS
/************************************************************************
	F_DUPGARAN		Duplica les garanties actives amb el nou nº de
				moviment
	ALLIBCTR
	Añadimos los distinct
*************************************************************************/
BEGIN
	INSERT INTO CLAUBENSEG (FINICLAU, SCLABEN, SSEGURO, NRIESGO,
		NMOVIMI, FFINCLAU)
	SELECT distinct pfefecto, SCLABEN, SSEGURO, NRIESGO, pmovimi, null
	FROM CLAUBENSEG
	WHERE sseguro = psseguro AND ffinclau IS NULL
		AND nmovimi <> pmovimi;
	INSERT INTO CLAUSUESP (NMOVIMI, SSEGURO, CCLAESP, NORDCLA,
		NRIESGO, FINICLAU, SCLAGEN, TCLAESP, FFINCLAU)
	SELECT distinct pmovimi, SSEGURO, CCLAESP, NORDCLA,
		NRIESGO, pfefecto, SCLAGEN, TCLAESP, FFINCLAU
	FROM CLAUSUESP
	WHERE sseguro = psseguro AND ffinclau IS NULL
		AND nmovimi <> pmovimi;
	UPDATE CLAUBENSEG
	SET ffinclau = pfefecto
	WHERE sseguro = psseguro
		AND ffinclau IS NULL
		AND nmovimi <> pmovimi;
	UPDATE CLAUSUESP
	SET ffinclau = pfefecto
	WHERE sseguro = psseguro
		AND ffinclau IS NULL
		AND nmovimi <> pmovimi;
	RETURN 0;
EXCEPTION
	WHEN OTHERS THEN
		RETURN 101968;
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_DUPCLAUSU" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_DUPCLAUSU" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_DUPCLAUSU" TO "PROGRAMADORESCSI";
