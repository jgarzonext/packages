--------------------------------------------------------
--  DDL for Function F_BASECON
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_BASECON" (psseguro IN NUMBER, pfefecto IN DATE,
pnriesgo IN NUMBER, pcgarant IN NUMBER, pcramo IN NUMBER, pcmodali IN NUMBER,
pccolect IN NUMBER, pctipseg IN NUMBER, pcmodo IN VARCHAR2,
pcactivi IN NUMBER, psproces IN NUMBER, pnmovimi IN NUMBER,
pnerror OUT NUMBER, pfiniefe IN DATE, pfuncion IN VARCHAR2 DEFAULT 'CAR')
   RETURN NUMBER AUTHID CURRENT_USER IS
--
-- ALLIBADM. CALCULA EL CAPITAL DE LES GARANTIES
-- CONSORCIABLES DEL RISC INTRODUÏT COM A PARÀMETRE.
--
--
--         SE MODIFICA ICAPITAL POR ICAPTOT DEBIDO AL COASEGURO.
--         SE MODIFICA IPRIANU POR IPRITOT DEBIDO AL COASEGURO.
--         EN RECIBOS SIEMPRE TRABAJAMOS CON LOS IMPORTES TOTALES
--         SE RECIBE LA FECHA INICIO DE EFECTO DE LA GARANTIA
--         POR SER NECESARIA EN LA CLAVE DE ACCESO A GARANSEG.
/*
 {Se añade el parametro de funcion ('TAR','CAR') para el caso que solo
  se este tarifando y precalculando el importe del primer recibo no vaya
  a la tabla garancar sino a tmp_garancar para el calculo de importes}
*/
/***********    SEGURAMENTE NO ESTÁ BIÉN
CURSOR CUR_GARANT IS
  SELECT DISTINCT(CGARANT)
    FROM GARANSEG
   WHERE SSEGURO = PSSEGURO
     AND TRUNC(PFEFECTO) >= TRUNC(FINIEFE)
     AND TRUNC(PFEFECTO) < TRUNC(NVL(FFINEFE, PFEFECTO + 2))
     AND NRIESGO = NVL(PNRIESGO, NRIESGO);
**************/
   xiprima      NUMBER := 0;
   xtotprima    NUMBER := 0;
   xcgarant     NUMBER;
   xcramo       NUMBER;
   xcmodali     NUMBER;
   xctipseg     NUMBER;
   xccolect     NUMBER;
   xcactivi     NUMBER;
   xcimpcon     NUMBER;
   error        NUMBER;
   xicapital    NUMBER;
BEGIN
   IF pcmodo IN ('R', 'N') THEN
      BEGIN
         SELECT cimpcon
           INTO xcimpcon
           FROM garanpro
          WHERE cramo = pcramo
            AND cmodali = pcmodali
            AND ccolect = pccolect
            AND ctipseg = pctipseg
            AND cgarant = pcgarant
            AND cactivi = NVL (pcactivi, 0);
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            BEGIN
               SELECT NVL (cimpcon, 0)
                 INTO xcimpcon
                 FROM garanpro
                WHERE cramo = pcramo
                  AND cmodali = pcmodali
                  AND ccolect = pccolect
                  AND ctipseg = pctipseg
                  AND cgarant = pcgarant
                  AND cactivi = 0;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  pnerror := 104110;         -- PRODUCTE NO TROBAT A GARANPRO
                  RETURN 0;
               WHEN OTHERS THEN
                  pnerror := 103503;  -- ERROR AL LLEGIR DE LA TAULA GARANPRO
                  RETURN 0;
            END;
         WHEN OTHERS THEN
            pnerror := 103503;        -- ERROR AL LLEGIR DE LA TAULA GARANPRO
            RETURN 0;
      END;

      IF xcimpcon = 1 THEN                -- ES SUMA EL CAPITAL DE LA GARANTIA
         BEGIN
            SELECT NVL (icaptot, 0)
              INTO xicapital
              FROM garanseg
             WHERE sseguro = psseguro
               AND nriesgo = pnriesgo
               AND cgarant = pcgarant
               AND nmovimi = pnmovimi
               AND finiefe = pfiniefe;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               NULL;
            WHEN OTHERS THEN
               pnerror := 103500;     -- ERROR AL LLEGIR DE LA TAULA GARANSEG
               RETURN 0;
         END;
      END IF;

      pnerror := 0;
      RETURN NVL (xicapital, 0);
   ELSIF pcmodo = 'P' THEN                                   -- MODE DE PROVES
      BEGIN
         SELECT cimpcon
           INTO xcimpcon
           FROM garanpro
          WHERE cramo = pcramo
            AND cmodali = pcmodali
            AND ccolect = pccolect
            AND ctipseg = pctipseg
            AND cgarant = pcgarant
            AND cactivi = NVL (pcactivi, 0);
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            BEGIN
               SELECT NVL (cimpcon, 0)
                 INTO xcimpcon
                 FROM garanpro
                WHERE cramo = pcramo
                  AND cmodali = pcmodali
                  AND ccolect = pccolect
                  AND ctipseg = pctipseg
                  AND cgarant = pcgarant
                  AND cactivi = 0;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  pnerror := 104110;         -- PRODUCTE NO TROBAT A GARANPRO
                  RETURN 0;
               WHEN OTHERS THEN
                  pnerror := 103503;  -- ERROR AL LLEGIR DE LA TAULA GARANPRO
                  RETURN 0;
            END;
         WHEN OTHERS THEN
            pnerror := 103503;        -- ERROR AL LLEGIR DE LA TAULA GARANPRO
            RETURN 0;
      END;

      IF xcimpcon = 1 THEN
         -- ES SUMA EL CAPITAL DE LA GARANTIA
         IF pfuncion = 'CAR' THEN
            BEGIN
               SELECT NVL (icaptot, 0)
                 INTO xicapital
                 FROM garancar
                WHERE sproces = psproces
                  AND sseguro = psseguro
                  AND nriesgo = pnriesgo
                  AND cgarant = pcgarant
                  AND finiefe = pfiniefe;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  NULL;
               WHEN OTHERS THEN
                  pnerror := 103502;  -- ERROR AL LLEGIR DE LA TAULA GARANCAR
                  RETURN 0;
            END;
         ELSIF pfuncion = 'TAR' THEN
            BEGIN
               SELECT NVL (icapital, 0)
                 INTO xicapital
                 FROM tmp_garancar
                WHERE sproces = psproces
                  AND sseguro = psseguro
                  AND nriesgo = pnriesgo
                  AND cgarant = pcgarant
                  AND finiefe = pfiniefe;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  NULL;
               WHEN OTHERS THEN
                  pnerror := 103502;  -- ERROR AL LLEGIR DE LA TAULA GARANCAR
                  RETURN 0;
            END;
         END IF;
      END IF;

      pnerror := 0;
      RETURN NVL (xicapital, 0);
   ELSIF pcmodo = 'D' THEN       -- OPCIÓ DIRECTA, QUAN NOMÉS SABEM EL SSEGURO
      -- I LA DATA D' EFECTE I EL NRIESGO (OPCIONAL)
      pnerror := 999999;
   ELSE
      pnerror := 101901;          -- PAS DE PARÀMETRES INCORRECTE A LA FUNCIÓ
      RETURN 0;
   END IF;
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_BASECON" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_BASECON" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_BASECON" TO "PROGRAMADORESCSI";
