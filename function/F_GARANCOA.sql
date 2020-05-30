--------------------------------------------------------
--  DDL for Function F_GARANCOA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_GARANCOA" (
   tipo IN VARCHAR2,
   porcen IN NUMBER,
   psseguro IN NUMBER,
   pnmovimi IN NUMBER DEFAULT 1)
   RETURN NUMBER AUTHID CURRENT_USER IS
/***************************************************************************
   F_GARANCOA: Función que modifica los importes segun el reparto
      del coaseguro.
   ALLIBCOA
***************************************************************************/
   viprianu       NUMBER;
   vipritot       NUMBER;
   vicapital      NUMBER;
   vicaptot       NUMBER;
BEGIN
   IF tipo = 'R' THEN
      -- Bug 23183/125094 - 10/10/2012 - AMC
      UPDATE garanseg
         SET iprianu = NVL(ipritot, iprianu) * NVL(porcen, 100) / 100,
             icapital = NVL(icaptot, icapital) * NVL(porcen, 100) / 100,
             ipritot = NVL(ipritot, iprianu),
             icaptot = NVL(icaptot, icapital)
       WHERE sseguro = psseguro
         AND nmovimi = pnmovimi;

      IF SQL%ROWCOUNT = 0 THEN
         UPDATE estgaranseg
            SET iprianu = NVL(ipritot, iprianu) * NVL(porcen, 100) / 100,
                icapital = NVL(icaptot, icapital) * NVL(porcen, 100) / 100,
                ipritot = NVL(ipritot, iprianu),
                icaptot = NVL(icaptot, icapital)
          WHERE sseguro = psseguro
            AND nmovimi = pnmovimi;
      END IF;
   -- Fi Bug 23183/125094 - 10/10/2012 - AMC
   ELSE
      UPDATE garancar
         SET iprianu = NVL(ipritot, iprianu) * NVL(porcen, 100) / 100,
             icapital = NVL(icaptot, icapital) * NVL(porcen, 100) / 100,
             ipritot = NVL(ipritot, iprianu),
             icaptot = NVL(icaptot, icapital)
       WHERE sseguro = psseguro;
   END IF;

   RETURN 0;
EXCEPTION
   WHEN OTHERS THEN
      RETURN 105577;
END;

/

  GRANT EXECUTE ON "AXIS"."F_GARANCOA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_GARANCOA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_GARANCOA" TO "PROGRAMADORESCSI";
