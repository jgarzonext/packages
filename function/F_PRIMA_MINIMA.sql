--------------------------------------------------------
--  DDL for Function F_PRIMA_MINIMA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_PRIMA_MINIMA" (psseguro IN NUMBER,
                                           pnriesgo OUT NUMBER)
RETURN NUMBER authid current_user IS
/*
      Función que devuelve :
	          a.- 0: Si la prima a nivel de recibo supera la prima minima.
			  b.- 1: Si la prima a nivel de recibo no supera la prima minima.

*/
xiprimin   NUMBER := 0;
xtipreb    NUMBER := 0;
xcforpag   NUMBER := 0;
xtotprima  NUMBER := 0;
BEGIN
-- Validación de parámetros
 IF psseguro IS NULL
 THEN
   RETURN 101901;
 END IF;
-- Obtención de la prima minima, tipo de recibo y forma de pago
 SELECT NVL(p.iprimin,0), s.ctipreb, NVL(s.cforpag,0)
 INTO xiprimin, xtipreb, xcforpag
 FROM productos p, seguros s
 WHERE s.sseguro = psseguro
 AND p.cramo = s.cramo
 AND p.cmodali = s.cmodali
 AND p.ctipseg = s.ctipseg
 AND p.ccolect = s.ccolect;
-- Tratamiento en función del tipo de objeto asegurado
IF xtipreb = 1 THEN
   SELECT SUM(iprianu) INTO xtotprima FROM garanseg WHERE
   sseguro = psseguro AND
   nmovimi = (SELECT MAX(nmovimi) FROM garanseg WHERE
   sseguro = psseguro) AND ffinefe IS NULL;
   IF xcforpag <> 0 THEN
       xtotprima := xtotprima/xcforpag;
	   IF xtotprima < xiprimin  THEN
	      pnriesgo := NULL;
	      RETURN 1 ;
	   END IF;
   ELSE
       IF xtotprima < xiprimin  THEN
	      pnriesgo := NULL;
	      RETURN 1 ;
	   END IF;
   END IF;
ELSE
   FOR x IN (SELECT SUM(iprianu) iprianu, nriesgo  FROM garanseg WHERE
             sseguro = psseguro AND
			 nmovimi = (SELECT MAX(nmovimi) FROM garanseg WHERE
			 sseguro = psseguro) AND ffinefe IS NULL
			 GROUP BY sseguro, nriesgo)
	LOOP
	  IF xcforpag <> 0 THEN
         xtotprima := x.iprianu/xcforpag;
	     IF xtotprima < xiprimin  THEN
		    pnriesgo := x.nriesgo;
		    RETURN 1 ;
	     END IF;
      ELSE
         IF x.iprianu < xiprimin  THEN
		    pnriesgo := x.nriesgo;
	        RETURN 1 ;
	     END IF;
      END IF;
	END LOOP;
END IF;
RETURN 0;
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_PRIMA_MINIMA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_PRIMA_MINIMA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_PRIMA_MINIMA" TO "PROGRAMADORESCSI";
