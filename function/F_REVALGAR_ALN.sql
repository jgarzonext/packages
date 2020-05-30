--------------------------------------------------------
--  DDL for Function F_REVALGAR_ALN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_REVALGAR_ALN" (
   psseguro IN NUMBER,
   pcmanual IN NUMBER,
   pcgarant IN NUMBER,
   pcactivi IN NUMBER,
   pcramo IN NUMBER,
   pcmodali IN NUMBER,
   pctipseg IN NUMBER,
   pccolect IN NUMBER,
   picapital IN NUMBER,
   piprianu IN NUMBER,
   pcrevali IN NUMBER,
   pirevali IN NUMBER,
   pprevali IN NUMBER,
   pmes IN NUMBER,
   pany IN NUMBER,
   prevcap OUT NUMBER,
   prevprima OUT NUMBER,
   pfactor OUT NUMBER)
   RETURN NUMBER AUTHID CURRENT_USER IS
/***********************************************************************
   F_REVALGAR : Retorna el capital revalorizado.
   ALLIBCTR - Gestión de datos referentes a los seguros
   Modificació: Se añade otro caso de revalorización y se distingue si
                la tarifa es manual. Si es así se revaloriza también la prima.
   Modificació: Se añade el caso de revalorización de prima y de capital
   Modificació: Se añade el caso pcmanual=3
   Modificació: Se añade el tipo crevali = 5. Será revalorización según
                el IPC anual (no el mensual)
   Modificació: Se añade el caso pcmanual = 4.(automático. Revaloriza prima)
   Modificació: Se controla que retorne el mismo capital que entra en los casos
                que el pcmanual sea 1 ó 4, hasta ahora retornaba NULL.
***********************************************************************/
   ppicapital     NUMBER(13, 2);   --   GARANSEG.ICAPITAL%TYPE;
   ppipc          NUMBER;
   ppipc_ant      NUMBER;
   ppsalida       NUMBER;
   procrevali     garanpro.crevali%TYPE; --25803 NUMBER;
   proprevali     garanpro.prevali%TYPE; --25803 NUMBER;
   proirevali     garanpro.irevali%TYPE; --25803 NUMBER;
   num_err        NUMBER;

   FUNCTION f_revalorizar(
      pentrada IN NUMBER,
      codi_revali IN NUMBER,
      por_revali IN NUMBER,
      imp_revali IN NUMBER,
      psalida OUT NUMBER)
      RETURN NUMBER IS
      ramo           NUMBER;
      modali         NUMBER;
      tipseg         NUMBER;
      colect         NUMBER;
      cap_max        garanpro.icaprev%TYPE;   --       cap_max        NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_tipo         NUMBER(1);   -- BUG 0021638 - 08/03/2012 - JMF
   BEGIN
      -- Selecciono el capital máximo que puede alcanzar la garantía.
      BEGIN
         SELECT icaprev
           INTO cap_max
           FROM garanpro
          WHERE cramo = ramo
            AND cmodali = pcmodali
            AND ctipseg = pctipseg
            AND ccolect = pccolect
            AND cactivi = pcactivi
            AND cgarant = pcgarant;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            BEGIN
               SELECT icaprev
                 INTO cap_max
                 FROM garanpro
                WHERE cramo = ramo
                  AND cmodali = modali
                  AND ctipseg = tipseg
                  AND ccolect = colect
                  AND cactivi = 0
                  AND cgarant = pcgarant;
            EXCEPTION
               WHEN OTHERS THEN
                  cap_max := 0;
            END;
         WHEN OTHERS THEN
            cap_max := 0;
      END;

      IF codi_revali = 0 THEN
         ppsalida := pentrada;
         pfactor := 0;   --no hay revalorización
      ELSIF codi_revali = 1 THEN
         ppsalida := pentrada + imp_revali;
         pfactor := ((ppsalida / pentrada) - 1) * 100;
      ELSIF codi_revali = 2 THEN
         ppsalida := pentrada *(1 + por_revali / 100);
         pfactor := por_revali;   --el prevali
      ELSIF codi_revali = 3 THEN
         -- BUG 0021638 - 08/03/2012 - JMF
         ppipc := f_ipc(pmes, pany, 1, 1);

         IF ppipc IS NULL THEN
            RETURN 101847;
         END IF;

         -- BUG 0021638 - 08/03/2012 - JMF
         ppipc_ant := f_ipc(pmes, pany - 1, 1, 1);

         IF ppipc_ant IS NULL THEN
            RETURN 101847;
         END IF;

         ppsalida := pentrada *(ppipc / ppipc_ant);
         pfactor := ppipc;   --ipc del año y del mes
      ELSIF codi_revali = 5 THEN   -- según IPC anual
         -- BUG 0021638 - 08/03/2012 - JMF
         ppipc := f_ipc(0, pany, 1, 1);

         IF ppipc IS NULL THEN
            RETURN 101847;
         END IF;

         ppsalida := pentrada *(1 + ppipc / 100);
         pfactor := ppipc;   --ipc del año
      ELSIF codi_revali IN(12, 13, 14) THEN
         -- BUG 0021638 - 08/03/2012 - JMF
         -- 12-IPCV
         -- 13-BEC
         -- 14-IPC mensual por factor
         IF codi_revali = 14 THEN
            v_tipo := 1;
         ELSIF codi_revali = 13 THEN
            v_tipo := 2;
         ELSIF codi_revali = 12 THEN
            v_tipo := 3;
         ELSE
            v_tipo := 0;
         END IF;

         ppipc := f_ipc(pmes, pany, v_tipo, 2);

         IF ppipc IS NULL THEN
            RETURN 101847;
         END IF;

         ppsalida := pentrada *(1 + ppipc);
         pfactor := ppipc;
      END IF;

      IF NVL(cap_max, 0) = 0 THEN
         psalida := f_round(NVL(ppsalida, 0));
      ELSIF f_round(NVL(ppsalida, 0)) > NVL(cap_max, 0) THEN
         IF codi_revali <> 0 THEN
            psalida := cap_max;
         ELSE
            psalida := f_round(NVL(ppsalida, 0));
         END IF;
      ELSE
         psalida := f_round(NVL(ppsalida, 0));
      END IF;

      RETURN 0;
   END;
------CUERPO DE LA FUNCION-----------
-------------------------------------
BEGIN
   --revalorización de capital
   IF pcmanual IN(0, 2, 3) THEN
      IF pcrevali <> 4 THEN
         num_err := f_revalorizar(picapital, pcrevali, pprevali, pirevali, prevcap);

         IF num_err <> 0 THEN
            RETURN num_err;
         END IF;
      ELSIF pcrevali = 4 THEN
         BEGIN
            SELECT garanpro.crevali, garanpro.prevali, garanpro.irevali
              INTO procrevali, proprevali, proirevali
              FROM garanpro, productos, seguros
             WHERE seguros.sseguro = psseguro
               AND productos.cramo = seguros.cramo
               AND productos.cmodali = seguros.cmodali
               AND productos.ctipseg = seguros.ctipseg
               AND productos.ccolect = seguros.ccolect
               AND garanpro.cramo = productos.cramo
               AND garanpro.cmodali = productos.cmodali
               AND garanpro.ctipseg = productos.ctipseg
               AND garanpro.ccolect = productos.ccolect
               AND garanpro.cgarant = pcgarant
               AND garanpro.cactivi = pcactivi;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               BEGIN
                  SELECT garanpro.crevali, garanpro.prevali, garanpro.irevali
                    INTO procrevali, proprevali, proirevali
                    FROM garanpro, productos, seguros
                   WHERE seguros.sseguro = psseguro
                     AND productos.cramo = seguros.cramo
                     AND productos.cmodali = seguros.cmodali
                     AND productos.ctipseg = seguros.ctipseg
                     AND productos.ccolect = seguros.ccolect
                     AND garanpro.cramo = productos.cramo
                     AND garanpro.cmodali = productos.cmodali
                     AND garanpro.ctipseg = productos.ctipseg
                     AND garanpro.ccolect = productos.ccolect
                     AND garanpro.cgarant = pcgarant
                     AND garanpro.cactivi = 0;
               EXCEPTION
                  WHEN OTHERS THEN
                     RETURN 103275;
               END;
            WHEN OTHERS THEN
               RETURN 103275;
         END;

         num_err := f_revalorizar(picapital, procrevali, proprevali, proirevali, prevcap);

         IF num_err <> 0 THEN
            RETURN num_err;
         END IF;
      END IF;
   ELSE
      prevcap := picapital;
   END IF;

   --revalorización de prima.
   IF pcmanual IN(1, 2, 3, 4) THEN
      IF pcrevali <> 4 THEN
         num_err := f_revalorizar(piprianu, pcrevali, pprevali, pirevali, prevprima);

         IF num_err <> 0 THEN
            RETURN num_err;
         END IF;
      ELSIF pcrevali = 4 THEN
         BEGIN
            SELECT garanpro.crevali, garanpro.prevali, garanpro.irevali
              INTO procrevali, proprevali, proirevali
              FROM garanpro, productos, seguros
             WHERE seguros.sseguro = psseguro
               AND productos.cramo = seguros.cramo
               AND productos.cmodali = seguros.cmodali
               AND productos.ctipseg = seguros.ctipseg
               AND productos.ccolect = seguros.ccolect
               AND garanpro.cramo = productos.cramo
               AND garanpro.cmodali = productos.cmodali
               AND garanpro.ctipseg = productos.ctipseg
               AND garanpro.ccolect = productos.ccolect
               AND garanpro.cgarant = pcgarant
               AND garanpro.cactivi = pcactivi;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               BEGIN
                  SELECT garanpro.crevali, garanpro.prevali, garanpro.irevali
                    INTO procrevali, proprevali, proirevali
                    FROM garanpro, productos, seguros
                   WHERE seguros.sseguro = psseguro
                     AND productos.cramo = seguros.cramo
                     AND productos.cmodali = seguros.cmodali
                     AND productos.ctipseg = seguros.ctipseg
                     AND productos.ccolect = seguros.ccolect
                     AND garanpro.cramo = productos.cramo
                     AND garanpro.cmodali = productos.cmodali
                     AND garanpro.ctipseg = productos.ctipseg
                     AND garanpro.ccolect = productos.ccolect
                     AND garanpro.cgarant = pcgarant
                     AND garanpro.cactivi = 0;
               EXCEPTION
                  WHEN OTHERS THEN
                     RETURN 103275;
               END;
            WHEN OTHERS THEN
               RETURN 103275;
         END;

         num_err := f_revalorizar(piprianu, procrevali, proprevali, proirevali, prevprima);

         IF num_err <> 0 THEN
            RETURN num_err;
         END IF;
      END IF;
   END IF;

   RETURN 0;
END;

/

  GRANT EXECUTE ON "AXIS"."F_REVALGAR_ALN" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_REVALGAR_ALN" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_REVALGAR_ALN" TO "PROGRAMADORESCSI";
