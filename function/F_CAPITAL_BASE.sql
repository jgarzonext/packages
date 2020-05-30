--------------------------------------------------------
--  DDL for Function F_CAPITAL_BASE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_CAPITAL_BASE" (
   psseg      IN   NUMBER,
   pnries     IN   NUMBER,
   pfini      IN   DATE DEFAULT NULL,
   pnmovimi   IN   NUMBER DEFAULT NULL
)
   RETURN NUMBER
IS
   wicapital   NUMBER;
--
-- 2004-03-23 JGR - Retorna el capital de la garantía base d'un risc.
-- 2004-05-19 JGR - Quan no es l'últim movimient la garantia base ha
--                  de ser la que tenia en aquella data (<= PFINI)
-- 2004-06-17 JGR - Que es pugui buscar per NMOVIMI, i evitar que quan dos moviment tenen la mateixa
--                  data FMOVINI s'equivoqui de moviment.
-- CPM 10/3/06: Si es un producto vinculado, se devolverá un nulo.
--                    Así cogerá el capital pdte de amortización ya calculado.
-- AVT 06-05-2008 bug: 5315 (Modificació anterior afegida)
--
BEGIN
--dbms_output.put_line ('Capital_base pfini='||pfini||' movimi='||pnmovimi);
   IF pnmovimi IS NOT NULL
   THEN
      -- Quan no es l'últim movimient la garantia base ha de ser la que tenia en aquella data (<= PFINI)
      SELECT g.icapital
        INTO wicapital
        FROM seguros s, garanseg g
       WHERE s.sseguro = psseg
         AND g.sseguro = psseg
         AND g.nmovimi =
                (SELECT MAX (nmovimi)
                   FROM garanseg g1
                  WHERE g1.sseguro = psseg
                    AND g1.nriesgo = pnries
                    AND g1.cgarant = g.cgarant
                    AND g1.nmovimi <= pnmovimi)
         AND g.nriesgo = pnries
         AND f_prod_vinc (s.sproduc) = 0        -- No es un producto vinculado
         AND 1 = f_pargaranpro_v (s.cramo, s.cmodali, s.ctipseg, s.ccolect, s.cactivi, g.cgarant, 'BASE_CAPITAL');
   ELSIF pfini IS NOT NULL
   THEN
      -- Quan no es l'últim movimient la garantia base ha de ser la que tenia en aquella data (<= PFINI)
      SELECT g.icapital
        INTO wicapital
        FROM seguros s, garanseg g
       WHERE s.sseguro = psseg
         AND g.sseguro = psseg
         AND g.nmovimi =
                (SELECT MAX (nmovimi)
                   FROM garanseg g1
                  WHERE g1.sseguro = psseg
                    AND g1.nriesgo = pnries
                    AND g1.cgarant = g.cgarant
                    AND g1.finiefe <= pfini)
         AND g.nriesgo = pnries
         AND f_prod_vinc (s.sproduc) = 0        -- No es un producto vinculado
         AND 1 =
                f_pargaranpro_v (s.cramo, s.cmodali, s.ctipseg, s.ccolect, s.cactivi, g.cgarant, 'BASE_CAPITAL');
   ELSE
      SELECT g.icapital
        INTO wicapital
        FROM seguros s, garanseg g
       WHERE s.sseguro = psseg
         AND g.sseguro = psseg
         AND g.nmovimi =
                (SELECT MAX (nmovimi)
                   FROM garanseg g1
                  WHERE g1.sseguro = psseg
                    AND g1.nriesgo = pnries
                    AND g1.cgarant = g.cgarant)
         AND g.nriesgo = pnries
         AND f_prod_vinc (s.sproduc) = 0        -- No es un producto vinculado
         AND 1 =
                f_pargaranpro_v (s.cramo,
                                 s.cmodali,
                                 s.ctipseg,
                                 s.ccolect,
                                 s.cactivi,
                                 g.cgarant,
                                 'BASE_CAPITAL'
                                );
   END IF;

  --
--dbms_output.put_line ('Capital_base ='||wicapital);
   RETURN wicapital;
EXCEPTION
   WHEN NO_DATA_FOUND
   THEN
--dbms_output.put_line ('Capital_base a nulo');
      RETURN NULL;
   WHEN OTHERS
   THEN
      p_tab_error (SYSDATE,
                   f_user,
                   'f_capital_Base',
                   1,
                   'Error no controlado',
                   SQLERRM
                  );
      RETURN NULL;
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_CAPITAL_BASE" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_CAPITAL_BASE" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_CAPITAL_BASE" TO "PROGRAMADORESCSI";
