--------------------------------------------------------
--  DDL for Function F_DUPGARAN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_DUPGARAN" (psseguro IN NUMBER, pfefecto IN DATE,
pmovimi IN NUMBER)
RETURN NUMBER authid current_user IS
/************************************************************************
	F_DUPGARAN		Duplica las garantías activas con el nuevo nº de
				movimiento
	ALLIBCTR

	Se añaden los campos IPRITOT, ICAPTOT
	NO se duplica la Prima Extra

	--JRH 11/2008 Se mira por el tipo la cobertura
*************************************************************************/
	nerror NUMBER;
	vcramo NUMBER;
	vcmodali NUMBER;
	vctipseg NUMBER;
	vccolect NUMBER;
	vcactivi NUMBER;
BEGIN

  select cramo,cmodali,ctipseg,ccolect,cactivi
  into  vcramo,vcmodali,vctipseg,vccolect,vcactivi
  from
  seguros
  where sseguro=psseguro;

	INSERT INTO GARANSEG (CGARANT, NRIESGO, NMOVIMI, SSEGURO, FINIEFE, NORDEN,
                          CREVALI, CTARIFA, ICAPITAL, PRECARG, IEXTRAP, IPRIANU,
                          FFINEFE, CFORMUL, CTIPFRA, IFRANQU, IRECARG, IPRITAR,
                          PDTOCOM, IDTOCOM, PREVALI, IREVALI, ITARIFA, ITARREA,
                          IPRITOT, ICAPTOT, PDTOINT, IDTOINT, FTARIFA, FEPREV,
                          FPPREV, PERCRE)

    SELECT CGARANT, NRIESGO, pmovimi, SSEGURO, pfefecto, NORDEN,
           CREVALI, CTARIFA, ICAPITAL, PRECARG, IEXTRAP, IPRIANU,
           FFINEFE, CFORMUL, CTIPFRA, IFRANQU, IRECARG, IPRITAR,
           PDTOCOM, IDTOCOM, PREVALI, IREVALI, ITARIFA, ITARREA,
           IPRITOT, ICAPTOT, PDTOINT, IDTOINT, FTARIFA, FEPREV,
           FPPREV, PERCRE
	FROM GARANSEG
	WHERE sseguro = psseguro AND ffinefe IS NULL
		AND nmovimi <> pmovimi
		--AND cgarant != 282; --No duplicamos la Prima Extra
		AND NVL(f_pargaranpro_v(vcramo, vcmodali, vctipseg,
                      vccolect, vcactivi, GARANSEG.cgarant, 'TIPO') ,0)<>4;  --No duplicamos la Prima Extra
	UPDATE GARANSEG
	SET ffinefe = pfefecto
	WHERE sseguro = psseguro
		AND ffinefe IS NULL
		AND nmovimi <> pmovimi;
--DUPLICAR DISTRIBUCION Y VALORES DE RESCATE
nerror := f_dupgaran_ulk (psseguro,pfefecto,pmovimi);
if nerror != 0 then
		return nerror;
end if;
	RETURN 0;
EXCEPTION
	WHEN OTHERS THEN
--		RETURN sqlcode;
		RETURN 103500;
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_DUPGARAN" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_DUPGARAN" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_DUPGARAN" TO "PROGRAMADORESCSI";
