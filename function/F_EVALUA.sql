--------------------------------------------------------
--  DDL for Function F_EVALUA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_EVALUA" (
   pcusuari IN VARCHAR2,
   psseguro IN NUMBER,
   pnriesgo IN NUMBER,
   pnmovimi IN NUMBER,
   ptablas IN VARCHAR2,
   pautorizacion OUT NUMBER)
   RETURN NUMBER IS
   xcramo         NUMBER;
   xcmodali       NUMBER;
   xctipseg       NUMBER;
   xccolect       NUMBER;
   xcactivi       NUMBER;
   xclave         NUMBER;
   xautoriza      VARCHAR2(2);
   xcrespue       NUMBER;
   xcperfexg      NUMBER;
   xerror         NUMBER;
   perfil_usuario NUMBER;
   dummy          NUMBER;
   regla_aceptada BOOLEAN;
   grupo_aceptado BOOLEAN;
   error          NUMBER;
BEGIN
--  BUSCAR DATOS SEGURO
   IF ptablas = 'SOL' THEN
      SELECT cramo, cmodali, ctipseg, ccolect,
             pac_seguros.ff_get_actividad(sseguro, pnriesgo, 'SOL')
        INTO xcramo, xcmodali, xctipseg, xccolect,
             xcactivi
        FROM solseguros
       WHERE ssolicit = psseguro;
   ELSE   -- 'SEG'
      SELECT cramo, cmodali, ctipseg, ccolect, pac_seguros.ff_get_actividad(sseguro, pnriesgo)
        INTO xcramo, xcmodali, xctipseg, xccolect, xcactivi
        FROM seguros
       WHERE sseguro = psseguro;
   END IF;

-- GRABAR AUTORIZACIONES
   BEGIN
      IF ptablas = 'SOL' THEN
         SELECT sautpsr, DECODE(cusuaut, NULL, 'NO', 'SI')
           INTO xclave, xautoriza
           FROM autorizaciones
          WHERE ssolicit = psseguro
            AND nriesgo = pnriesgo
            AND nmovimi = pnmovimi;
      ELSE
         SELECT sautpsr, DECODE(cusuaut, NULL, 'NO', 'SI')
           INTO xclave, xautoriza
           FROM autorizaciones
          WHERE sseguro = psseguro
            AND nriesgo = pnriesgo
            AND nmovimi = pnmovimi;
      END IF;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         NULL;
   END;

   IF xautoriza = 'SI' THEN
-- TRASPASO A HISTORICO
      error := f_trasp_hist_autori(xclave);
   END IF;

   IF error <> 0 THEN
      p_tab_error(f_sysdate, f_user, 'F_EVALUA', 1, 'ERROR ' || TO_CHAR(error), SQLERRM);
   --DBMS_OUTPUT.put_line('ERROR AL TRASPASAR HISTORICO' || SQLERRM);
   END IF;

   DELETE FROM detautorizaciones
         WHERE sautpsr = xclave;

   DELETE FROM autorizaciones
         WHERE sautpsr = xclave;

   xclave := NULL;

   SELECT sautpsr.NEXTVAL
     INTO xclave
     FROM DUAL;

   --DBMS_OUTPUT.put_line('CLAVE ' || xclave);
   IF ptablas = 'SOL' THEN
      INSERT INTO autorizaciones
                  (sautpsr, sseguro, nriesgo, nmovimi, cusupet, fpetici, cperfexg, cestaut,
                   ssolicit)
           VALUES (xclave, psseguro, pnriesgo, pnmovimi, pcusuari, f_sysdate, 1, 0,
                   psseguro);
   ELSE
      INSERT INTO autorizaciones
                  (sautpsr, sseguro, nriesgo, nmovimi, cusupet, fpetici, cperfexg, cestaut)
           VALUES (xclave, psseguro, pnriesgo, pnmovimi, pcusuari, f_sysdate, 1, 0);
   END IF;

-- PARA CADA REGLA DE ESE PRODUCTO
   FOR r IN (SELECT cregla, cgarant
               FROM par_reglas_aplicables
              WHERE cramo = xcramo
                AND(cmodali = xcmodali
                    OR cmodali IS NULL)
                AND(ctipseg = xctipseg
                    OR ctipseg IS NULL)
                AND(ccolect = xccolect
                    OR ccolect IS NULL)
                AND(cactivi = xcactivi
                    OR cactivi IS NULL)) LOOP
      --DBMS_OUTPUT.put_line('REGLA.' || r.cregla);
      regla_aceptada := FALSE;

--   COMPROBAR  SI LA REGLA SE TIENE QUE APLICAR (ACTIVIDAD/GARANTIA)
      BEGIN
         IF ptablas = 'SOL' THEN
            SELECT 1
              INTO dummy
              FROM solgaranseg
             WHERE ssolicit = psseguro
               AND nriesgo = pnriesgo
               AND(cgarant = r.cgarant
                   OR r.cgarant IS NULL);
         ELSE   -- 'SEG'
            SELECT 1
              INTO dummy
              FROM garanseg
             WHERE sseguro = psseguro
               AND nriesgo = pnriesgo
               AND nmovimi = pnmovimi
               AND(cgarant = r.cgarant
                   OR r.cgarant IS NULL);
         END IF;
      EXCEPTION
         WHEN TOO_MANY_ROWS THEN
            NULL;
         WHEN NO_DATA_FOUND THEN
            regla_aceptada := TRUE;
      END;

      BEGIN
         SELECT 1
           INTO dummy
           FROM detautorizaciones
          WHERE sautpsr = xclave
            AND cregla = r.cregla;

         regla_aceptada := TRUE;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            NULL;
      END;

--   PARA CADA GRUPO DE ESTA REGLA (ORDEN CPERFEXG )  ?
      FOR g IN (SELECT sasocia, cperfexg
                  FROM codiasoccond
                 WHERE cregla = r.cregla) LOOP
         --DBMS_OUTPUT.put_line('GRUPO' || g.sasocia || ' PERFIL EX:' || g.cperfexg);
         IF regla_aceptada THEN
            EXIT;
         END IF;

         grupo_aceptado := FALSE;

--     PARA CADA CONDICION DE ESTE GRUPO
         FOR c IN (SELECT d.scondreg, cgarant, cpregun, crespue, nvalinf, nvalsup
                     FROM par_condic_reglas p, detasoccond d
                    WHERE p.scondreg = d.scondreg
                      AND d.sasocia = g.sasocia) LOOP
            --DBMS_OUTPUT.put_line('CONDIC:' || c.cpregun);
            BEGIN
               IF ptablas = 'SOL' THEN
                  IF c.cgarant IS NOT NULL THEN
                     SELECT crespue
                       INTO xcrespue
                       FROM solpregungaranseg
                      WHERE ssolicit = psseguro
                        AND nriesgo = pnriesgo
                        AND cpregun = c.cpregun
                        AND cgarant = c.cgarant;
                  ELSE
                     SELECT crespue
                       INTO xcrespue
                       FROM solpregunseg
                      WHERE ssolicit = psseguro
                        AND nriesgo = pnriesgo
                        AND cpregun = c.cpregun;
                  END IF;
               ELSE   -- 'SEG'
                  IF c.cgarant IS NOT NULL THEN
                     SELECT crespue
                       INTO xcrespue
                       FROM pregungaranseg
                      WHERE sseguro = psseguro
                        AND nriesgo = pnriesgo
                        AND nmovimi = pnmovimi
                        AND cgarant = c.cgarant
                        AND cpregun = c.cpregun;
                  ELSE
                     SELECT crespue
                       INTO xcrespue
                       FROM pregunseg
                      WHERE sseguro = psseguro
                        AND nriesgo = pnriesgo
                        AND nmovimi = pnmovimi
                        AND cpregun = c.cpregun;
                  END IF;
               END IF;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  grupo_aceptado := TRUE;
                  EXIT;
            END;

            IF c.crespue IS NULL THEN
               IF xcrespue < c.nvalinf
                  OR xcrespue > c.nvalsup THEN
                  grupo_aceptado := TRUE;
                  EXIT;
               END IF;
            ELSE
               IF c.crespue <> xcrespue THEN
                  grupo_aceptado := TRUE;
                  EXIT;
               END IF;
            END IF;

            INSERT INTO detautorizaciones
                        (sautpsr, cregla, sasocia, scondreg, cperfexg, crespue)
                 VALUES (xclave, r.cregla, g.sasocia, c.scondreg, g.cperfexg, xcrespue);
         --DBMS_OUTPUT.put_line('GRABA DETAUTORIZACIONES R:' || r.cregla || ' GR:'
         --                     || g.sasocia || ' C:' || c.cpregun);
         END LOOP;   -- (condiciones)

         IF grupo_aceptado THEN
            p_tab_error(f_sysdate, f_user, 'F_EVALUA', 1, ' grupo aceptado ', SQLERRM);
         --DBMS_OUTPUT.put_line('SI GRUPO ' || g.sasocia);
         ELSE
            p_tab_error(f_sysdate, f_user, 'F_EVALUA', 2, ' no grupo aceptado ', SQLERRM);
         --DBMS_OUTPUT.put_line('NO GRUPO ' || g.sasocia);
         END IF;

         IF grupo_aceptado THEN
            DELETE FROM detautorizaciones
                  WHERE sautpsr = xclave
                    AND sasocia = g.sasocia;
         END IF;
      END LOOP;   -- (grupos)
   END LOOP;   -- (reglas)

   SELECT MIN(cperfexg)
     INTO xcperfexg
     FROM detautorizaciones
    WHERE sautpsr = xclave;

   IF xcperfexg IS NULL THEN
      DELETE FROM autorizaciones
            WHERE sautpsr = xclave;

      pautorizacion := 1;
   ELSE
      UPDATE autorizaciones
         SET cperfexg = xcperfexg
       WHERE sautpsr = xclave;

      pautorizacion := 0;
   END IF;

   RETURN 0;
EXCEPTION
   WHEN OTHERS THEN
      --DBMS_OUTPUT.put_line('ERROR GENERAL' || SQLERRM);
      RETURN SQLCODE;
END f_evalua;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_EVALUA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_EVALUA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_EVALUA" TO "PROGRAMADORESCSI";
