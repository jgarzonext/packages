--------------------------------------------------------
--  DDL for Function F_DUPPREGUNGARANSEG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_DUPPREGUNGARANSEG" (
   psseguro IN NUMBER,
   pfefecto IN DATE,
   pmovimi IN NUMBER)
   RETURN NUMBER AUTHID CURRENT_USER IS
/************************************************************************
    F_DUPPREGUNGARANSEG    Duplica las preguntas de garantías activas con el nuevo nº de
                movimiento
*************************************************************************/
   nerror         NUMBER;
   vcramo         NUMBER;
   vcmodali       NUMBER;
   vctipseg       NUMBER;
   vccolect       NUMBER;
   vcactivi       NUMBER;
   vnriesgo       NUMBER;
BEGIN
   SELECT cramo, cmodali, ctipseg, ccolect, cactivi
     INTO vcramo, vcmodali, vctipseg, vccolect, vcactivi
     FROM seguros
    WHERE sseguro = psseguro;

   INSERT INTO pregungaranseg
               (sseguro, nriesgo, cgarant, nmovimi, cpregun, crespue, nmovima, finiefe,
                trespue)
      SELECT sseguro, nriesgo, cgarant, pmovimi, cpregun, crespue, nmovima, pfefecto, trespue
        FROM pregungaranseg
       WHERE sseguro = psseguro
         AND nmovimi <> pmovimi
         -- AND cgarant != 282 --No duplicamos la Prima Extra
         AND NVL(f_pargaranpro_v(vcramo, vcmodali, vctipseg, vccolect,
                                 pac_seguros.ff_get_actividad(pregungaranseg.sseguro,
                                                              pregungaranseg.nriesgo),
                                 pregungaranseg.cgarant, 'TIPO'),
                 0) <> 4   --No duplicamos la Prima Extra
         AND nmovimi = (SELECT MAX(nmovimi)
                          FROM pregungaranseg seg1
                         WHERE seg1.sseguro = psseguro
                           AND seg1.nmovimi <> pmovimi
                           AND seg1.cgarant != 282);

   RETURN 0;
EXCEPTION
   WHEN OTHERS THEN
      RETURN 111658;
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_DUPPREGUNGARANSEG" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_DUPPREGUNGARANSEG" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_DUPPREGUNGARANSEG" TO "PROGRAMADORESCSI";
