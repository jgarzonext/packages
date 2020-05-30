--------------------------------------------------------
--  DDL for Function CONTRACTADES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."CONTRACTADES" (
   psesion IN NUMBER,
   psseguro IN NUMBER,
   pcgarant IN NUMBER,
   pnmovimi IN NUMBER DEFAULT NULL)
   RETURN NUMBER AUTHID CURRENT_USER IS
/******************************************************************************
   NOMBRE:      CONTRACTADES
   PROPÓSITO:   Retorna nº de garanties contractades per una pòlissa de la mateixa agrupació que pcgarant

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1                                       1. Creación de la función.
   2          02/04/2009   FAL             1. Modificacions a la select per recuperar el nº de garanties contractades. Bug: 9681
   3          28/04/2009   DCT             1. Modificar activi de f_pargaranpro_v.  Bug:0009783
******************************************************************************/
/* JGR - Variant de la funció CONTRATADA però en comptes de dir si una garantía
         está o no contractada, ens diu cuantes garantíes te un contracte */
   lc             NUMBER;
BEGIN
   IF pnmovimi IS NOT NULL THEN
/*
    SELECT COUNT(*) INTO lc
      FROM garanseg
     WHERE sseguro = psseguro
       AND nmovimi = pnmovimi;
*/
-- FAL. 02/04/2008. Bug 9681. Modificacions a la select per recuperar el nº de garanties contractades.
      --BUG 9783 - 29/04/2009 - DCT - Canviar cactivi per pac_seguros.ff_get_actividad(s.sseguro, g.nriesgo)
      SELECT COUNT(*)
        INTO lc
        FROM garanseg g, seguros s, garanpro p
       WHERE g.sseguro = s.sseguro
         AND g.sseguro = psseguro
         AND g.nmovimi = pnmovimi
         AND s.sproduc = p.sproduc
         AND g.cgarant = p.cgarant
         AND p.creaseg IN(1, 3)   -- CVALOR:134 (Acumulan capital)
         AND f_pargaranpro_v(s.cramo, s.cmodali, s.ctipseg, s.ccolect,
                             pac_seguros.ff_get_actividad(s.sseguro, g.nriesgo), g.cgarant,
                             'REACUMGAR') =
               f_pargaranpro_v(s.cramo, s.cmodali, s.ctipseg, s.ccolect,
                               pac_seguros.ff_get_actividad(s.sseguro, g.nriesgo), pcgarant,
                               'REACUMGAR');
      --FI BUG 9783 - 29/04/2009 - DCT
   ELSE
/*
    SELECT COUNT(*) INTO lc
    FROM garanseg
    WHERE sseguro = psseguro
      AND ffinefe IS NULL;
*/

      -- FAL. 02/04/2008. Bug 9681. Modificacions a la select per recuperar el nº de garanties contractades.
      --BUG 9783 - 29/04/2009 - DCT - Canviar cactivi per pac_seguros.ff_get_actividad(s.sseguro, g.nriesgo)
      SELECT COUNT(*)
        INTO lc
        FROM garanseg g, seguros s, garanpro p
       WHERE g.sseguro = s.sseguro
         AND g.sseguro = psseguro
         --   AND g.nmovimi = pnmovimi
         AND g.ffinefe IS NULL
         AND s.sproduc = p.sproduc
         AND g.cgarant = p.cgarant
         AND p.cactivi = pac_seguros.ff_get_actividad(s.sseguro, g.nriesgo)
         AND p.creaseg IN(1, 3)   -- CVALOR:134 (Acumulan capital)
         AND f_pargaranpro_v(s.cramo, s.cmodali, s.ctipseg, s.ccolect,
                             pac_seguros.ff_get_actividad(s.sseguro, g.nriesgo), g.cgarant,
                             'REACUMGAR') =
               f_pargaranpro_v(s.cramo, s.cmodali, s.ctipseg, s.ccolect,
                               pac_seguros.ff_get_actividad(s.sseguro, g.nriesgo), pcgarant,
                               'REACUMGAR');
       --FI BUG 9783 - 29/04/2009 - DCT
   END IF;

   RETURN lc;
EXCEPTION
   WHEN OTHERS THEN
      RETURN 0;
END contractades;
 
 

/

  GRANT EXECUTE ON "AXIS"."CONTRACTADES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."CONTRACTADES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."CONTRACTADES" TO "PROGRAMADORESCSI";
