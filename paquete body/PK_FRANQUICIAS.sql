--------------------------------------------------------
--  DDL for Package Body PK_FRANQUICIAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PK_FRANQUICIAS" IS
FUNCTION f_codifranq (pcramo NUMBER, pcmodali NUMBER, pctipseg NUMBER, pcactivi NUMBER, cfranq OUT NUMBER) RETURN NUMBER IS
 error NUMBER:=0;
BEGIN
	BEGIN
	  SELECT cfranq
	  INTO cfranq
	  FROM CODIFRANQUICIAS
	  WHERE cramo = pcramo
	    AND cmodali = pcmodali
	    AND ctipseg = pctipseg
	    AND cactivi = pcactivi;
	 RETURN error;
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			-- Se busca para la actividad 0
			BEGIN
			  SELECT cfranq
			  INTO cfranq
			  FROM CODIFRANQUICIAS
			  WHERE cramo =pcramo
			    AND cmodali = pcmodali
			    AND ctipseg = pctipseg
			    AND cactivi = 0;
			EXCEPTION
				WHEN OTHERS THEN
				  error:= SQLCODE;
			END;
		WHEN OTHERS THEN
			error:= SQLCODE;
	END;

  	RETURN error;

END f_codifranq;

FUNCTION f_versiofranq_garan (pcfranq NUMBER, pdata DATE,pcgarant NUMBER, nfraver OUT NUMBER, clave_sgt OUT NUMBER) RETURN NUMBER IS
error NUMBER:=0;
BEGIN

 SELECT DISTINCT a.nfraver, b.clave_sgt
 INTO nfraver, clave_sgt
 FROM FRANQUICIASVER a, FRANQGARAN b
 WHERE a.cfranq = pcfranq
 AND b.cfranq = a.cfranq
 AND b.NFRAVER = a.nfraver
 AND b.ngrpgara =  (SELECT ngrpgara
                    FROM DETFRANQGARAN
                    WHERE cgarant = pcgarant
                    AND cfranq = a.cfranq
				    AND nfraver = a.nfraver)
 AND a.ffraini <= pdata
 AND a.cestado = 1 -- que estigui activa la versió
 AND (a.ffrafin IS NULL OR a.ffrafin > pdata) --f_sysdate)
 AND a.ffraact = ( SELECT MAX(ffraact)
                 FROM FRANQUICIASVER
                 WHERE cfranq= pcfranq
                 AND cestado = 1
                 AND TRUNC(ffraini) <= TRUNC (pdata) --f_sysdate)
                 AND (ffrafin IS NULL OR ffrafin > TRUNC (pdata)) --f_sysdate))
               );
  RETURN error;
EXCEPTION WHEN OTHERS THEN
  error:= SQLCODE;
  RETURN error;
END f_versiofranq_garan;

FUNCTION f_versiofranq (pcfranq NUMBER, pdata DATE, nfraver OUT NUMBER, clave_sgt OUT NUMBER) RETURN NUMBER IS
error NUMBER:=0;
BEGIN

 SELECT DISTINCT a.nfraver, b.clave_sgt
 INTO nfraver, clave_sgt
 FROM FRANQUICIASVER a, FRANQGARAN b
 WHERE a.cfranq = pcfranq
 AND b.cfranq = a.cfranq
 AND b.NFRAVER = a.nfraver
 AND b.ngrpgara =  (SELECT distinct ngrpgara
                    FROM DETFRANQGARAN
                    WHERE cfranq = a.cfranq
				    AND nfraver = a.nfraver)
 AND a.ffraini <= pdata
 AND a.cestado = 1 -- que estigui activa la versió
 AND (a.ffrafin IS NULL OR a.ffrafin > pdata)
 AND a.ffraact = ( SELECT MAX(ffraact)
                 FROM FRANQUICIASVER
                 WHERE cfranq= pcfranq
                 AND cestado = 1
                 AND TRUNC(ffraini) <= TRUNC (pdata)
                 AND (ffrafin IS NULL OR ffrafin > TRUNC (pdata))
               );
  RETURN error;
EXCEPTION WHEN OTHERS THEN
  error:= SQLCODE;
  RETURN error;
END f_versiofranq;

FUNCTION f_grupogaran_garan (pcfranq NUMBER, pnfraver NUMBER, pcgarant NUMBER,  ngrpgara OUT NUMBER) RETURN NUMBER IS
error NUMBER:=0;
BEGIN

 SELECT DISTINCT c.ngrpgara
 INTO ngrpgara
 FROM DETFRANQGARAN c
 WHERE c.cfranq = pcfranq
 AND c.nfraver = pnfraver
 AND c.cgarant = pcgarant;
  RETURN error;
EXCEPTION WHEN OTHERS THEN
  error:= SQLCODE;
  RETURN error;
END f_grupogaran_garan;

END Pk_Franquicias;

/

  GRANT EXECUTE ON "AXIS"."PK_FRANQUICIAS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PK_FRANQUICIAS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PK_FRANQUICIAS" TO "PROGRAMADORESCSI";
