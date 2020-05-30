--------------------------------------------------------
--  DDL for Function FULTPROVCALC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."FULTPROVCALC" (sesion IN NUMBER, psseguro IN NUMBER, pnriesgo IN NUMBER,
                                   pcgarant IN NUMBER, pfecha IN NUMBER, pmodo IN NUMBER)
RETURN NUMBER AUTHID current_user IS
/*********************************************************************************************
    ultima provision matemática calculada en el cierre de provisiones a fecha
	pmodo : 0.- a nivel de sseguro (pero de una sola garantía)
	        1.- a nivel de riego (pero de una sola garantía)
			2.- a nivel de seguro "total"
			3.- a nivel de riesgo "total"

*********************************************************************************************/


  v_iprovmat     NUMBER;

BEGIN
      SELECT SUM(ipromat)
	  INTO v_iprovmat
	  FROM provmat
	  WHERE sseguro = psseguro
	   AND fcalcul = (SELECT MAX(fcalcul) FROM provmat
	                  WHERE sseguro = psseguro
					  AND fcalcul <= TO_DATE(pfecha,'yyyymmdd'))
	   AND nriesgo = DECODE(pmodo,0,nriesgo,2,nriesgo,3,pnriesgo,1,pnriesgo)
	      AND cgarant = DECODE(pmodo,0,  pcgarant, 1, pcgarant, 2,cgarant,3,cgarant);

	  IF v_iprovmat IS NULL THEN -- todavía no se ha calculado en ningún cierre
	     SELECT SUM(iprovt0)
	     INTO v_iprovmat
	     FROM garansegprovmat
	     WHERE sseguro = psseguro
	      AND nmovimi = (SELECT MAX(nmovimi) FROM garansegprovmat
	                                       WHERE sseguro = psseguro
						                           AND nriesgo = DECODE(pmodo,0,nriesgo,2,nriesgo,3,pnriesgo,1,pnriesgo)
	                                               AND cgarant = DECODE(pmodo,0,  pcgarant, 1, pcgarant, 2,cgarant,3,cgarant))
	       AND nriesgo = DECODE(pmodo,0,nriesgo,2,nriesgo,3,pnriesgo,1,pnriesgo)
	      AND cgarant = DECODE(pmodo,0,  pcgarant, 1, pcgarant, 2,cgarant,3,cgarant);
	   END IF;
   RETURN v_iprovmat;
EXCEPTION
   WHEN OTHERS THEN
      p_tab_error(f_sysdate, F_USER, 'FULTPROVCALC', 1,
              'SSEGURO ='||PSSEGURO||' NRIESGO ='||pnriesgo||' PCGARANT ='||pcgarant||
			  ' PFECHA='||PFECHA,SQLERRM);
      RETURN NULL; -- error al leer de garanseg
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."FULTPROVCALC" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."FULTPROVCALC" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."FULTPROVCALC" TO "PROGRAMADORESCSI";
