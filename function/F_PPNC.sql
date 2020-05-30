--------------------------------------------------------
--  DDL for Function F_PPNC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_PPNC" (
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
         AND p.ccolect = s.ccolect
         --Xt
         AND p.cramo = 15
         AND p.cmodali = 1;
BEGIN
--FUNCTION f_commit_calcul_ppnc (cempres IN NUMBER, aux_factual IN DATE,
--  psproces IN NUMBER, pcidioma IN NUMBER, pcmoneda IN NUMBER) RETURN NUMBER IS
   FOR reg IN c_polizas(aux_factual, cempres) LOOP
      num_err := f_fechainifin(reg.sseguro, aux_factual, reg.fvencim, reg.fcaranu, ffinal,
                               aux_fefeini, wprorrata, wcmodcom);

      IF num_err != 0 THEN
         ROLLBACK;
         ttexto := f_axis_literales(num_err, pcidioma);
         num_err := f_proceslin(psproces, ttexto, reg.sseguro, nlin);
         conta_err := conta_err + 1;
         nlin := NULL;
      --commit;
      END IF;

      --DBMS_OUTPUT.put_line(' aux_factual: ' || aux_factual);
      --DBMS_OUTPUT.put_line(' cempres: ' || cempres);
      BEGIN
         INSERT INTO ppnc
                     (cempres, fcalcul, sproces, cramdgs, cramo, cmodali, ctipseg, ccolect,
                      sseguro, npoliza, ncertif, cgarant, nmovimi, nriesgo, ipridev, iprincs,
                      ipdevrc, ipncsrc, fefeini, ffinefe)
            SELECT reg.cempres, aux_factual, psproces, reg.cramdgs, reg.cramo, reg.cmodali,
                   reg.ctipseg, reg.ccolect, reg.sseguro, reg.npoliza, reg.ncertif, g.cgarant,
                   g.nmovimi, g.nriesgo, NVL(g.iprianu * wprorrata * NVL(nasegur, 1), 0),
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
               AND(ffinal > aux_factual);
      EXCEPTION
         WHEN OTHERS THEN
            ROLLBACK;
            ttexto := f_axis_literales(103869, pcidioma);
            num_err := f_proceslin(psproces, ttexto || ' PPNC', reg.sseguro, nlin);
            conta_err := conta_err + 1;
            nlin := NULL;
      --  commit;
      END;
   --commit;
   END LOOP;

   --DELETE FROM PPNC
   --WHERE IPRIDEV <= 0
   --AND sproces = psproces;
   RETURN 0;
--END f_commit_calcul_ppnc;
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_PPNC" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_PPNC" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_PPNC" TO "PROGRAMADORESCSI";
