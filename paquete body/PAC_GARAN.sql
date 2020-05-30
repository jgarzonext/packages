--------------------------------------------------------
--  DDL for Package Body PAC_GARAN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_GARAN" IS
------------------------------------------------
   PROCEDURE QUERY(resultset IN OUT lista_ref) IS
   BEGIN
      OPEN resultset FOR
         SELECT   s.norden, s.sseguro sseguro, g.cgarant, g.tgarant, SUM(s.icapital) icapital,
                  s.ctipfra franquicia
             FROM movseguro m, riesgos r, garangen g, garanseg s
            WHERE m.cmovseg <> 6
              AND m.sseguro = s.sseguro
              AND m.nmovimi = s.nmovimi
              AND((s.cgarant = 39
                   AND r.sperson IS NOT NULL)
                  OR s.cgarant <> 39)
              AND r.nriesgo = s.nriesgo
              AND r.sseguro = s.sseguro
              AND g.cidioma = var_idioma
              AND g.cgarant = s.cgarant
              AND s.finiefe <= var_fecha
              AND(s.ffinefe IS NULL
                  OR ffinefe > var_fecha)
              AND(s.sseguro = var_seguro
                  AND s.nriesgo = var_riesgo)
         GROUP BY s.norden, s.sseguro, g.cgarant, g.tgarant, s.ctipfra
         UNION
         SELECT 9999 norden, -1 sseguro, g.cgarant, g.tgarant,
                DECODE(cgarant, 1, 1, NULL) icapital, DECODE(cgarant, 1, 1, NULL) franquicia
           FROM garangen g
          WHERE g.cgarant = 9999
            AND g.cidioma = var_idioma;
   END QUERY;

------------------------------------------------------------------
   PROCEDURE omplir_valora(
      pseguro IN NUMBER,
      pidioma IN NUMBER,
      pnriesgo IN NUMBER,
      pfecha IN DATE) IS
   BEGIN
      var_seguro := pseguro;
      var_idioma := pidioma;
      var_riesgo := pnriesgo;
      var_fecha := pfecha;
   END omplir_valora;
END;

/

  GRANT EXECUTE ON "AXIS"."PAC_GARAN" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_GARAN" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_GARAN" TO "PROGRAMADORESCSI";
