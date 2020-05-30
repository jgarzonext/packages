--------------------------------------------------------
--  DDL for Package Body PAC_PROVI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_PROVI" IS
/******************************************************************************
   NOMBRE:     pac_provi
   PROPÓSITO:  Funciones de provisiones

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        XX/XX/XXXX   XXX                1. Creación del package.
   2.0        27/04/2009   APD                2. Bug 9699 - primero se ha de buscar para la actividad en concreto
                                                 y si no se encuentra nada ir a buscar a GARANFORMULA para la actividad cero
   2.1        27/04/2009   APD                3. Bug 9685 - en lugar de coger la actividad de la tabla seguros, llamar a la
                                                 función pac_seguros.ff_get_actividad
******************************************************************************/

   /*********************************************************************************************
      Si está como propuesta de alta (csituac = 4), no se selecciona
   ***********************************************************************************************/
   CURSOR c_polizas(fecha DATE, empresa NUMBER) IS
      SELECT c.cempres, s.cramo, s.cmodali, s.ctipseg, s.ccolect, s.sseguro, s.fvencim,
             s.fcaranu, s.fefecto, s.npoliza, s.ncertif, NVL(p.cramdgs, 0) cramdgs, s.cduraci,
             s.nduraci
        FROM productos p, seguros s, codiram c
       WHERE ((s.fvencim > fecha
               AND TO_CHAR(s.fvencim, 'yyyy') <> TO_CHAR(fecha, 'yyyy'))
              OR s.fvencim IS NULL)
         AND(s.fanulac > fecha
             OR s.fanulac IS NULL)
         AND s.fefecto <= fecha
         AND s.csituac <> 4
         AND s.cramo = c.cramo
         AND c.cempres = empresa
         AND p.cramo = s.cramo
         AND p.cmodali = s.cmodali
         AND p.ctipseg = s.ctipseg
         AND p.ccolect = s.ccolect;

-----------------------------------------------------------------------
   FUNCTION f_commit_calcul_ppnc(
      cempres IN NUMBER,
      aux_factual IN DATE,
      psproces IN NUMBER,
      pcidioma IN NUMBER,
      pcmoneda IN NUMBER)
      RETURN NUMBER IS
      aux_fefeini    DATE;
      ttexto         VARCHAR2(400);
      nlin           NUMBER;
      num_err        NUMBER;
      conta_err      NUMBER := 0;
      aux_ffinal     DATE;
      ffinal         DATE;
      wfcaranu       DATE;
      wnmovimi       NUMBER;
      wprorrata      NUMBER;
      dias           NUMBER;
      wcmodcom       NUMBER;
   BEGIN
      FOR reg IN c_polizas(aux_factual, cempres) LOOP
         num_err := f_fechainifin(reg.sseguro, aux_factual, reg.fvencim, reg.fcaranu, ffinal,
                                  aux_fefeini, wprorrata, wcmodcom);

         IF num_err != 0 THEN
            ROLLBACK;
            ttexto := f_axis_literales(num_err, pcidioma);
            num_err := f_proceslin(psproces, ttexto, reg.sseguro, nlin);
            conta_err := conta_err + 1;
            nlin := NULL;
            COMMIT;
         END IF;

         BEGIN
            -- Bug 9699 - APD - 27/04/2009 - primero se ha de buscar para la actividad en concreto
            -- y si no se encuentra nada ir a buscar a GARANPRO para la actividad cero
            -- Bug 9685 - APD - 27/04/2009 - en lugar de coger la actividad de la tabla seguros, llamar a la función pac_seguros.ff_get_actividad
            INSERT INTO ppnc
                        (cempres, fcalcul, sproces, cramdgs, cramo, cmodali, ctipseg, ccolect,
                         sseguro, npoliza, ncertif, cgarant, nmovimi, nriesgo, ipridev,
                         iprincs, ipdevrc, ipncsrc, fefeini, ffinefe)
               SELECT reg.cempres, aux_factual, psproces, reg.cramdgs, reg.cramo, reg.cmodali,
                      reg.ctipseg, reg.ccolect, reg.sseguro, reg.npoliza, reg.ncertif,
                      g.cgarant, g.nmovimi, g.nriesgo,
                      NVL(g.iprianu * wprorrata * NVL(nasegur, 1), 0),
                      f_round(NVL((g.iprianu * wprorrata * NVL(nasegur, 1))
                                  *(1 -(NVL(gg.precseg, 0) / 100)) /(ffinal - aux_fefeini)
                                  *(ffinal - aux_factual),
                                  0),
                              pcmoneda),
                      NULL, NULL, aux_fefeini, ffinal
                 FROM garanpro gg, garanseg g, riesgos r
                WHERE g.sseguro = reg.sseguro
                  AND g.finiefe <= aux_factual
                  AND(g.ffinefe > aux_factual
                      OR g.ffinefe IS NULL)
                  AND gg.cgarant = g.cgarant
                  AND gg.cramo = reg.cramo
                  AND gg.cmodali = reg.cmodali
                  AND gg.ctipseg = reg.ctipseg
                  AND gg.ccolect = reg.ccolect
                  AND gg.cactivi = pac_seguros.ff_get_actividad(g.sseguro, g.nriesgo)
                  AND gg.cprovis IS NULL
                  AND g.iprianu <> 0
                  AND r.sseguro = g.sseguro
                  AND r.fefecto <= aux_factual
                  AND(r.fanulac > aux_factual
                      OR r.fanulac IS NULL)
                  AND(g.nriesgo = r.nriesgo
                      OR g.nriesgo IS NULL)
                  AND(ffinal > aux_factual)
               UNION
               SELECT reg.cempres, aux_factual, psproces, reg.cramdgs, reg.cramo, reg.cmodali,
                      reg.ctipseg, reg.ccolect, reg.sseguro, reg.npoliza, reg.ncertif,
                      g.cgarant, g.nmovimi, g.nriesgo,
                      NVL(g.iprianu * wprorrata * NVL(nasegur, 1), 0),
                      f_round(NVL((g.iprianu * wprorrata * NVL(nasegur, 1))
                                  *(1 -(NVL(gg.precseg, 0) / 100)) /(ffinal - aux_fefeini)
                                  *(ffinal - aux_factual),
                                  0),
                              pcmoneda),
                      NULL, NULL, aux_fefeini, ffinal
                 FROM garanpro gg, garanseg g, riesgos r
                WHERE g.sseguro = reg.sseguro
                  AND g.finiefe <= aux_factual
                  AND(g.ffinefe > aux_factual
                      OR g.ffinefe IS NULL)
                  AND gg.cgarant = g.cgarant
                  AND gg.cramo = reg.cramo
                  AND gg.cmodali = reg.cmodali
                  AND gg.ctipseg = reg.ctipseg
                  AND gg.ccolect = reg.ccolect
                  AND gg.cactivi = 0
                  AND gg.cprovis IS NULL
                  AND g.iprianu <> 0
                  AND r.sseguro = g.sseguro
                  AND r.fefecto <= aux_factual
                  AND(r.fanulac > aux_factual
                      OR r.fanulac IS NULL)
                  AND(g.nriesgo = r.nriesgo
                      OR g.nriesgo IS NULL)
                  AND(ffinal > aux_factual)
                  AND NOT EXISTS(SELECT reg.cempres, aux_factual, psproces, reg.cramdgs,
                                        reg.cramo, reg.cmodali, reg.ctipseg, reg.ccolect,
                                        reg.sseguro, reg.npoliza, reg.ncertif, g.cgarant,
                                        g.nmovimi, g.nriesgo,
                                        NVL(g.iprianu * wprorrata * NVL(nasegur, 1), 0),
                                        f_round(NVL((g.iprianu * wprorrata * NVL(nasegur, 1))
                                                    *(1 -(NVL(gg.precseg, 0) / 100))
                                                    /(ffinal - aux_fefeini)
                                                    *(ffinal - aux_factual),
                                                    0),
                                                pcmoneda),
                                        NULL, NULL, aux_fefeini, ffinal
                                   FROM garanpro gg, garanseg g, riesgos r
                                  WHERE g.sseguro = reg.sseguro
                                    AND g.finiefe <= aux_factual
                                    AND(g.ffinefe > aux_factual
                                        OR g.ffinefe IS NULL)
                                    AND gg.cgarant = g.cgarant
                                    AND gg.cramo = reg.cramo
                                    AND gg.cmodali = reg.cmodali
                                    AND gg.ctipseg = reg.ctipseg
                                    AND gg.ccolect = reg.ccolect
                                    AND gg.cactivi =
                                             pac_seguros.ff_get_actividad(g.sseguro, g.nriesgo)
                                    AND gg.cprovis IS NULL
                                    AND g.iprianu <> 0
                                    AND r.sseguro = g.sseguro
                                    AND r.fefecto <= aux_factual
                                    AND(r.fanulac > aux_factual
                                        OR r.fanulac IS NULL)
                                    AND(g.nriesgo = r.nriesgo
                                        OR g.nriesgo IS NULL)
                                    AND(ffinal > aux_factual));
         -- Bug 9699 - APD - 27/04/2009 - Fin
         -- Bug 9685 - APD - 27/04/2009 - Fin
         EXCEPTION
            WHEN OTHERS THEN
               ROLLBACK;
               ttexto := f_axis_literales(103869, pcidioma);
               num_err := f_proceslin(psproces, ttexto || ' PPNC', reg.sseguro, nlin);
               conta_err := conta_err + 1;
               nlin := NULL;
               COMMIT;
         END;

         COMMIT;
      END LOOP;

      DELETE FROM ppnc
            WHERE ipridev <= 0
              AND sproces = psproces;

      RETURN 0;
   END f_commit_calcul_ppnc;
END;

/

  GRANT EXECUTE ON "AXIS"."PAC_PROVI" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_PROVI" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_PROVI" TO "PROGRAMADORESCSI";
