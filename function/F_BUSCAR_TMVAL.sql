--------------------------------------------------------
--  DDL for Function F_BUSCAR_TMVAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_BUSCAR_TMVAL" (
   ptablas IN VARCHAR2,
   psseguro IN NUMBER,
   pnriesgo IN NUMBER,
   pfefecto IN DATE,
   pnmovimi IN NUMBER,
   pcgarant IN NUMBER,
   ppinttec IN garanseg.pinttec%TYPE,
   pcrevali IN garanseg.crevali%TYPE,
   pprevali IN garanseg.prevali%TYPE,
   pirevali IN garanseg.irevali%TYPE,
   pltabla IN NUMBER,
   x_scod OUT NUMBER)
   RETURN NUMBER IS
   resultado      NUMBER := 0;
   x_scodmorpar   NUMBER;
   x_cramo        NUMBER;
   x_cmodali      NUMBER;
   x_ctipseg      NUMBER;
   x_ccolect      NUMBER;
   x_cactivi      NUMBER;
   x_cpregun      NUMBER;
   x_dto          NUMBER;
   preg           NUMBER;
   x_vig          NUMBER;
   x_fini_vig     DATE;
   x_ffin_vig     DATE;
   x_trobat       NUMBER;
   x_pintec       NUMBER;

   CURSOR estpreg IS
      SELECT e.cpregun, e.crespue
        FROM estpregunseg e, codipregun c
       WHERE e.sseguro = psseguro
         AND e.nriesgo = pnriesgo
         AND c.cpregun = e.cpregun
         AND e.nmovimi = pnmovimi
         AND c.ctippor = 4;

   CURSOR solpreg IS
      SELECT s.cpregun, s.crespue
        FROM solpregunseg s, codipregun c
       WHERE s.ssolicit = psseguro
         AND s.nriesgo = pnriesgo
         AND c.cpregun = s.cpregun
         AND c.ctippor = 4;

   CURSOR segpreg IS
      SELECT p.cpregun, p.crespue
        FROM pregunseg p, codipregun c
       WHERE p.sseguro = psseguro
         AND p.nriesgo = pnriesgo
         AND p.nmovimi = pnmovimi
         AND c.cpregun = p.cpregun
         AND c.ctippor = 4;

   CURSOR tm(
      xcramo NUMBER,
      xcmodali NUMBER,
      xctipseg NUMBER,
      xccolect NUMBER,
      xcactivi NUMBER,
      xcgarant NUMBER) IS
      SELECT cg.scodmorpar, cg.fini_vig, cg.ffin_vig
        FROM codmorpar_garanpro cg, codmortalidad_par cp
       WHERE cg.cramo = xcramo
         AND cg.cmodali = xcmodali
         AND cg.ctipseg = xctipseg
         AND cg.ccolect = xccolect
         AND cg.cactivi = xcactivi
         AND cg.cgarant = xcgarant
         AND cg.scodmorpar = cp.scodmorpar
         AND cp.prev = pprevali
         AND cp.pint = ppinttec;
BEGIN
   IF pltabla = 1 THEN
      x_dto := NULL;

      IF ptablas = 'EST' THEN
         SELECT cramo, cmodali, ctipseg, ccolect,
                pac_seguros.ff_get_actividad(sseguro, pnriesgo, 'EST')
           INTO x_cramo, x_cmodali, x_ctipseg, x_ccolect,
                x_cactivi
           FROM estseguros
          WHERE sseguro = psseguro;

         FOR v_reg IN estpreg LOOP
            x_dto := f_prespuesta(v_reg.cpregun, v_reg.crespue, NULL);
         END LOOP;
      ELSIF ptablas = 'SOL' THEN
         SELECT cramo, cmodali, ctipseg, ccolect,
                pac_seguros.ff_get_actividad(sseguro, pnriesgo, 'SOL')
           INTO x_cramo, x_cmodali, x_ctipseg, x_ccolect,
                x_cactivi
           FROM solseguros
          WHERE ssolicit = psseguro;

         FOR v_reg IN solpreg LOOP
            x_dto := f_prespuesta(v_reg.cpregun, v_reg.crespue, NULL);
         END LOOP;
      ELSE
         SELECT cramo, cmodali, ctipseg, ccolect,
                pac_seguros.ff_get_actividad(sseguro, pnriesgo)
           INTO x_cramo, x_cmodali, x_ctipseg, x_ccolect,
                x_cactivi
           FROM seguros
          WHERE sseguro = psseguro;

         FOR v_reg IN segpreg LOOP
            x_dto := f_prespuesta(v_reg.cpregun, v_reg.crespue, NULL);
         END LOOP;
      END IF;

      OPEN tm(x_cramo, x_cmodali, x_ctipseg, x_ccolect, x_cactivi, pcgarant);

      x_vig := 0;
      x_trobat := 0;
      x_scod := 0;

      LOOP
         FETCH tm
          INTO x_scodmorpar, x_fini_vig, x_ffin_vig;

         EXIT WHEN tm%NOTFOUND;
         x_trobat := x_trobat + 1;

         IF (pfefecto >= x_fini_vig
             AND x_ffin_vig IS NULL)
            OR(pfefecto >= x_fini_vig
               AND(pfefecto <= x_ffin_vig
                   AND x_ffin_vig IS NOT NULL)) THEN
            x_vig := x_vig + 1;
            x_scod := x_scodmorpar;
         END IF;
      END LOOP;
      -- BUG 21546_108724 - 08/02/2012 - JLTS - Cierre de posibles cursores abiertos
      IF tm%ISOPEN THEN
      close tm;
       END IF;
      IF x_trobat = 0 THEN
         resultado := 111299;   /* La garantia no te taules de mortalitat, no es error */
      ELSIF x_vig = 0 THEN
         resultado := 111300;   /* La garantia no te taules vigents, es error */
      ELSIF x_vig = 1 THEN
         SELECT COUNT(1)
           INTO x_pintec
           FROM codmortalidad_par cg
          WHERE cg.scodmorpar = x_scodmorpar
            AND cg.prev = pprevali
            AND cg.pint = ppinttec;

         IF x_pintec = 0 THEN
            resultado := 111301;
         /*No troba CODMORTALIDAD_PAR amb l'interés i valorització*/
         END IF;
      ELSE
         IF x_dto IS NULL THEN
            resultado := 111303;   /* No hi ha pregunta asociada per escollir la taula */
         ELSE
            BEGIN
               SELECT cp.scodmorpar
                 INTO x_scodmorpar
                 FROM codmorpar_garanpro cg, codmortalidad c, codmortalidad_par cp
                WHERE cg.cramo = x_cramo
                  AND cg.cmodali = x_cmodali
                  AND cg.ctipseg = x_ctipseg
                  AND cg.ccolect = x_ccolect
                  AND cg.cactivi = x_cactivi
                  AND cg.cgarant = pcgarant
                  AND cg.fini_vig <= pfefecto
                  AND(cg.ffin_vig >= pfefecto
                      OR cg.ffin_vig IS NULL)
                  AND cg.scodmorpar = cp.scodmorpar
                  AND cp.ctabla = c.ctabla
                  AND cp.pdto = x_dto
                  AND cp.prev = pprevali
                  AND cp.pint = ppinttec;

               x_scod := x_scodmorpar;
            EXCEPTION
               WHEN OTHERS THEN
                  resultado := 111302;
            /*No troba CODMORTALIDAD_PAR amb l' interés i valorrització i decompte*/
            END;
         END IF;
      END IF;
   END IF;

   BEGIN
      INSERT INTO tmp_garanseg
                  (sseguro, nriesgo, cgarant, nmovimi, finiefe, tmgaran, crevali,
                   prevali, irevali)
           VALUES (psseguro, pnriesgo, pcgarant, pnmovimi, pfefecto, x_scodmorpar, pcrevali,
                   pprevali, pirevali);
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         UPDATE tmp_garanseg
            SET tmgaran = x_scodmorpar,
                crevali = pcrevali,
                prevali = pprevali,
                irevali = pirevali
          WHERE sseguro = psseguro
            AND nriesgo = pnriesgo
            AND cgarant = pcgarant
            AND nmovimi = pnmovimi
            AND finiefe = pfefecto;
      WHEN OTHERS THEN
         RETURN 111418;
   END;

   RETURN resultado;
EXCEPTION
   WHEN OTHERS THEN
      -- BUG 21546_108724 - 08/02/2012 - JLTS - Cierre de posibles cursores abiertos
      IF tm%ISOPEN THEN
      close tm;
       END IF;
      RETURN 111419;
END f_buscar_tmval;

/

  GRANT EXECUTE ON "AXIS"."F_BUSCAR_TMVAL" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_BUSCAR_TMVAL" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_BUSCAR_TMVAL" TO "PROGRAMADORESCSI";
