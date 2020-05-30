--------------------------------------------------------
--  DDL for Function F_DUPGARAN_ULK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_DUPGARAN_ULK" (psseguro IN NUMBER, pfefecto IN DATE,
pmovimi IN NUMBER)
RETURN NUMBER authid current_user IS
/************************************************************************
	F_DUPGARAN		Duplica las garantías activas con el nuevo nº de
				movimiento
	ALLIBCTR
	18/02/1999	CPM	(STRATEGY)
	13/07/1999	JAMF	(STRATEGY)	Se añaden los campos IPRITOT, ICAPTOT
        04/01/2000      DPC     (STRATEGY)      Se duplica la distribución y los valores de
 						rescate
*************************************************************************/
BEGIN
    --ACTUALIZAR TABLA DE DISTRIBUCION
    INSERT INTO SEGDISIN2 (SSEGURO,NRIESGO,NMOVIMI,FINICIO,
            CCESTA,PDISTREC,PDISTUNI,PDISTEXT)
    SELECT SSEGURO,NRIESGO,pmovimi,pfefecto,CCESTA,PDISTREC,PDISTUNI,PDISTEXT
    FROM SEGDISIN2
    WHERE SSEGURO = psseguro
      AND ffin IS NULL
      AND nmovimi <> pmovimi;



    UPDATE SEGDISIN2
    SET ffin = pfefecto
    WHERE sseguro = psseguro
      AND ffin IS NULL
      AND nmovimi <> pmovimi;

    --ACTUALIZAR TABLA DE VALORES DE RESCATE
    -- RSC 02/01/2008
    /*
        INSERT INTO V_RESCATE (SSEGURO,FEMISIO,FRESCAT,IVALRES,NMOVIMI,
                FINIEFE,FFINEFE)
        SELECT SSEGURO,FEMISIO,FRESCAT,IVALRES,pmovimi,
                pfefecto,FFINEFE
        FROM V_RESCATE
             WHERE SSEGURO = psseguro AND ffinefe IS NULL
             AND nmovimi <> pmovimi;
        UPDATE V_RESCATE
    	SET ffinefe = pfefecto
	    WHERE sseguro = psseguro
	      AND ffinefe IS NULL
	      AND nmovimi <> pmovimi;
    */
    RETURN 0;
EXCEPTION
      WHEN OTHERS THEN
              RETURN 103500;
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_DUPGARAN_ULK" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_DUPGARAN_ULK" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_DUPGARAN_ULK" TO "PROGRAMADORESCSI";
