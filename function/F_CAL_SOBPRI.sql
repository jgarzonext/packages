--------------------------------------------------------
--  DDL for Function F_CAL_SOBPRI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_CAL_SOBPRI" (psseguro IN NUMBER, pnriesgo IN NUMBER, pcgarant IN NUMBER, pfiniefe IN DATE,
                     picapital IN NUMBER, pipritar IN NUMBER, pprecarg IN OUT NUMBER, pirecarg IN OUT NUMBER,
                     piprianu IN OUT NUMBER, pnmovimi IN NUMBER, pltabla IN NUMBER DEFAULT 0)
RETURN NUMBER authid current_user IS
/*******************************************************************************
 Funció per tal de recalcular les sobreprimes.
*******************************************************************************/
wnmovimi NUMBER;
CURSOR cur_estsbpri IS
    SELECT *
	FROM ESTGARANSEG_SBPRI
	WHERE SSEGURO = psseguro
	  AND NRIESGO = pnriesgo
	  AND CGARANT = pcgarant
	  AND nmovimi = pnmovimi;
	  --AND FINIEFE = pfiniefe;

CURSOR cur_sbpri IS
    SELECT *
	FROM GARANSEG_SBPRI
	WHERE SSEGURO = psseguro
	  AND NRIESGO = pnriesgo
	  AND CGARANT = pcgarant
	  AND nmovimi = pnmovimi
	  AND FINIEFE = pfiniefe;

IMPORT NUMBER := 0;

BEGIN
  If nvl(pnmovimi,0) =0 then
    begin
     SELECT MAX(g.nmovimi) INTO wnmovimi
     FROM MOVSEGURO m,GARANSEG g
     WHERE m.sseguro=g.sseguro
     AND m.sseguro = psseguro
     AND m.nmovimi=g.nmovimi
     --AND finiefe <= TRUNC(pfefecto)
     --AND (ffinefe IS NULL OR ffinefe >=  TRUNC(pfefecto))
     AND femisio IS NOT NULL
     AND cmovseg NOT IN (3,6,52);
   exception
     WHEN OTHERS THEN
       return(110873);
   end;
   wnmovimi := nvl(wnmovimi,0)+1;
  else
     wnmovimi := pnmovimi;
  end if;
  IF pltabla = 0 THEN
    FOR v_estsbpri IN cur_estsbpri LOOP
      IF v_estsbpri.ccalsbr = 1 THEN
        IMPORT := IMPORT + ((v_estsbpri.pvalor * pipritar)/100);
      ELSIF v_estsbpri.ccalsbr = 2 THEN
        IMPORT := IMPORT + ((v_estsbpri.pvalor * picapital)/100);
      ELSIF v_estsbpri.ccalsbr = 3 THEN
        IMPORT := IMPORT + v_estsbpri.pvalor;
      END IF;
    END LOOP;
  ELSIF pltabla = 1 THEN -- Se llama en el proceso de cartera
    FOR v_sbpri IN cur_sbpri LOOP
      IF v_sbpri.ccalsbr = 1 THEN
        IMPORT := IMPORT + ((v_sbpri.pvalor * pipritar)/100);
      ELSIF v_sbpri.ccalsbr = 2 THEN
        IMPORT := IMPORT + ((v_sbpri.pvalor * picapital)/100);
      ELSIF v_sbpri.ccalsbr = 3 THEN
        IMPORT := IMPORT + v_sbpri.pvalor;
      END IF;
    END LOOP;
	piprianu := piprianu + IMPORT;
  END IF;

  IF NVL(import,0) = 0 THEN
    RETURN 1;
  ELSE
    pirecarg := pirecarg + IMPORT;
    pprecarg := pprecarg + ((IMPORT/pipritar)*100);
    -- piprianu := piprianu + IMPORT;
  END IF;

  RETURN 0;
END;

 
 

/

  GRANT EXECUTE ON "AXIS"."F_CAL_SOBPRI" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_CAL_SOBPRI" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_CAL_SOBPRI" TO "PROGRAMADORESCSI";
