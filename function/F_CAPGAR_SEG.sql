--------------------------------------------------------
--  DDL for Function F_CAPGAR_SEG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_CAPGAR_SEG" (
   pssesion   NUMBER,
   porigen    NUMBER,
   psseguro   NUMBER,
   pnriesgo   NUMBER,
   pcgarant   NUMBER,
   pfecha     NUMBER
)
   RETURN NUMBER
IS
/*
  Descr : Retorna el capital assegurat d'una garantia. No controla els errors
    perquè aquesta funció es cridada per SGT.
    porigen = 1 - Taules EST
    porigen = 2 - Taules SEG
  Autor : ATS5656.
  Fecha : 22-05-2007.
*/
   icapital   NUMBER;
   fecha      DATE;
BEGIN
   fecha := TO_DATE (pfecha, 'YYYYMMDD');

   IF porigen = 1 THEN
      SELECT icapital
        INTO icapital
        FROM estgaranseg g
       WHERE g.sseguro = psseguro
         AND g.nriesgo = pnriesgo
         AND g.cgarant = pcgarant
         AND g.nmovimi =
                (SELECT MAX (g1.nmovimi)
                   FROM estgaranseg g1
                  WHERE g1.sseguro = psseguro
                    AND g1.cgarant = pcgarant
                    AND g1.nriesgo = pnriesgo
                    AND (   (fecha BETWEEN g1.finiefe AND g1.ffinefe)
                         OR (g1.ffinefe IS NULL AND g1.finiefe <= fecha)
                        ));
   ELSE
      SELECT icapital
        INTO icapital
        FROM garanseg g
       WHERE g.sseguro = psseguro
         AND g.nriesgo = pnriesgo
         AND g.cgarant = pcgarant
         AND g.nmovimi =
                (SELECT MAX (g1.nmovimi)
                   FROM garanseg g1
                  WHERE g1.sseguro = psseguro
                    AND g1.cgarant = pcgarant
                    AND g1.nriesgo = pnriesgo
                    AND (   (fecha BETWEEN g1.finiefe AND g1.ffinefe)
                         OR (g1.ffinefe IS NULL AND g1.finiefe <= fecha)
                        ));
   END IF;

   RETURN icapital;
EXCEPTION
   WHEN OTHERS THEN
      RETURN NULL;
END f_capgar_seg;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_CAPGAR_SEG" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_CAPGAR_SEG" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_CAPGAR_SEG" TO "PROGRAMADORESCSI";
