--------------------------------------------------------
--  DDL for Package Body PAC_PROVIMAT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_PROVIMAT" IS
/******************************************************************************
   NOMBRE:     pac_provimat
   PROPÓSITO:  Funcion que calcula la provision matématica

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        XX/XX/XXXX   XXX                1. Creación del package.
   2.0        27/04/2009   APD                2. Bug 9685 - primero se ha de buscar para la actividad en concreto
                                                 y si no se encuentra nada ir a buscar a PREGUNPROGARAN para la actividad cero
                                                 También en lugar de coger la actividad de la tabla seguros, llamar a la función
                                                 pac_seguros.ff_get_actividad
   3.0        02/11/2011   JMP                3. 0018423: LCOL000 - Multimoneda
******************************************************************************/

   -- Cursor que nos selecciona todas las pólizas vigentes que calculan provisiones matemáticas
   CURSOR c_polizas_provmat(fecha DATE, empresa NUMBER) IS
      SELECT c.cempres, s.cramo, s.cmodali, s.ctipseg, s.ccolect, s.sseguro,
             NVL(s.fcaranu, s.fvencim) ffinal, s.fefecto, s.npoliza, s.ncertif, p.cramdgs,
             s.nduraci, p.pinttec, p.pgasext, p.pgasint, s.cforpag, s.fvencim
        FROM productos p, seguros s, codiram c
       WHERE (s.fvencim > fecha
              OR s.fvencim IS NULL)
         AND(s.fanulac > fecha
             OR s.fanulac IS NULL)
         AND s.fefecto <= fecha
         AND s.csituac <> 4
         AND s.cramo = c.cramo
         AND c.cempres = empresa
         AND TRUNC(MONTHS_BETWEEN(NVL(fvencim, fefecto), fefecto) / 12) > 1
         AND p.cramo = s.cramo
         AND p.cmodali = s.cmodali
         AND p.ctipseg = s.ctipseg
         AND p.ccolect = s.ccolect;

   -- Seleccionamos las garantías vigentes de la póliza que calculan provisiones matemáticas
      -- Bug 9699 - APD - 27/04/2009 - primero se ha de buscar para la actividad en concreto
      -- y si no se encuentra nada ir a buscar a GARANPRO para la actividad cero
   CURSOR c_garantias_provmat(
      seguro NUMBER,
      ramo NUMBER,
      modalidad NUMBER,
      tipseg NUMBER,
      colect NUMBER,
      fecha DATE) IS
      SELECT DISTINCT nriesgo, g.cgarant, ctabla, cprovis
                 FROM garanpro gp, garanseg g
                WHERE g.sseguro = seguro
                  AND cprovis IS NOT NULL
                  AND(ffinefe > fecha
                      OR ffinefe IS NULL)
                  AND g.cgarant = gp.cgarant
                  AND gp.cramo = ramo
                  AND gp.cmodali = modalidad
                  AND gp.ctipseg = tipseg
                  AND gp.ccolect = colect
                  AND gp.cactivi = pac_seguros.ff_get_actividad(g.sseguro, g.nriesgo)
      UNION
      SELECT DISTINCT nriesgo, g.cgarant, ctabla, cprovis
                 FROM garanpro gp, garanseg g
                WHERE g.sseguro = seguro
                  AND cprovis IS NOT NULL
                  AND(ffinefe > fecha
                      OR ffinefe IS NULL)
                  AND g.cgarant = gp.cgarant
                  AND gp.cramo = ramo
                  AND gp.cmodali = modalidad
                  AND gp.ctipseg = tipseg
                  AND gp.ccolect = colect
                  AND gp.cactivi = 0
                  AND NOT EXISTS(SELECT DISTINCT nriesgo, g.cgarant, ctabla, cprovis
                                            FROM garanpro gp, garanseg g
                                           WHERE g.sseguro = seguro
                                             AND cprovis IS NOT NULL
                                             AND(ffinefe > fecha
                                                 OR ffinefe IS NULL)
                                             AND g.cgarant = gp.cgarant
                                             AND gp.cramo = ramo
                                             AND gp.cmodali = modalidad
                                             AND gp.ctipseg = tipseg
                                             AND gp.ccolect = colect
                                             AND gp.cactivi =
                                                   pac_seguros.ff_get_actividad(g.sseguro,
                                                                                g.nriesgo));

   -- Bug 9699 - APD - 27/04/2009 - Fin

   -------------------------------------------------------------------------------------------------
   FUNCTION f_matriz_provmat2(
      panyo IN NUMBER,
      pedad IN NUMBER,
      psexo IN NUMBER,
      nduraci IN NUMBER,
      psproces IN NUMBER,
      pinttec IN NUMBER,
      picapini IN NUMBER,
      pcrevali IN NUMBER,
      pirevali IN NUMBER,
      pprevali IN NUMBER,
      pipricom IN NUMBER,
      pipriinv IN NUMBER,
      pctiptab IN NUMBER,
      ppgasadm IN NUMBER)
      RETURN NUMBER IS
/************************************************************************************************
    F_MATRIZ_PROVMAT: nos calcula la matriz personalizada para una poliza basada en los
            valores de las tablas de mortalidad, PARA PRIMAS REGULARES
    ALLIBPRO
************************************************************************************************/
      indice         NUMBER;
      edad           NUMBER;
      anyo           NUMBER;
      p_factor       NUMBER;
      p_factor1      NUMBER;
      pripag         NUMBER := 0;
   BEGIN
      indice := 0;
      edad := pedad;

      -- Calculamos el valor de la tabla de mortalidad
      BEGIN
         SELECT DECODE(psexo, 1, vmascul, 2, vfemeni, 0)
           INTO p_factor
           FROM mortalidad
          WHERE nedad = pedad
            AND ctabla = pctiptab;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 107108;
      END;

--    FOR i IN 0..panyo-1 LOOP
--        IF pcrevali = 1 THEN
--            --pripag := pripag + ((pipricom *(1+((pprevali/100))*i))/picapini);
--            pripag := pripag +(pipricom *(1+((pprevali/100)*i)));
--        ELSIF pcrevali = 2 THEN
--            pripag := pripag + (pipricom*(POWER((1+(pprevali/100)),i)));
--        END IF;
--    END LOOP;
      FOR anyo IN panyo .. nduraci LOOP
         pripag := 0;

         FOR i IN 0 .. anyo LOOP
            IF pcrevali = 1 THEN
               pripag := pripag +(pipricom *(1 +((pprevali / 100) * i)));
            ELSIF pcrevali = 2 THEN
               pripag := pripag +(pipricom *(POWER((1 +(pprevali / 100)), i)));
            END IF;
         END LOOP;

         BEGIN
            SELECT DECODE(psexo, 1, vmascul, 2, vfemeni, 0)
              INTO p_factor1
              FROM mortalidad
             WHERE nedad = edad + 1
               AND ctabla = pctiptab;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 107108;
         END;

         BEGIN
            INSERT INTO matrizprovmat
                        (cindice, nanyos, nedad, ix, tpx, tpx1, tqx, vn, vn2, iimpori,
                         ipvppag, ipripen, ipvppen, igasadm, ipvgadm, ioblase, sproces)
               (SELECT indice, anyo, edad, DECODE(psexo, 1, vmascul, 2, vfemeni, 0) ix,
                       DECODE(psexo, 1, vmascul, 2, vfemeni, 0) / p_factor tpx,
                       p_factor1 / p_factor tpx1,
                       (DECODE(psexo, 1, vmascul, 2, vfemeni, 0) / p_factor)
                       -(p_factor1 / p_factor) tqx,
                       POWER((1 +(pinttec / 100)), -indice) vn,
                       POWER((1 +(pinttec / 100)), -(indice +(1 / 2))) vn2,
                       DECODE(pcrevali,
                              1,(picapini
                                 *(1
                                   +((pprevali / 100) * DECODE(anyo, nduraci, anyo - 1, anyo)))),
                              2,(picapini
                                 *(POWER((1 +(pprevali / 100)),
                                         DECODE(anyo, nduraci, anyo - 1, anyo)))),
                              0) iimpori,
                       pripag
                       *((DECODE(psexo, 1, vmascul, 2, vfemeni, 0) / p_factor)
                         -(p_factor1 / p_factor))
                       *(POWER((1 +(pinttec / 100)), -(indice +(1 / 2)))) ipvppag,
                       DECODE(pcrevali,
                              1,(pipriinv
                                 *(1
                                   +((pprevali / 100) * DECODE(anyo, nduraci, anyo - 1, anyo)))),
                              2,(pipriinv
                                 *(POWER((1 +(pprevali / 100)),
                                         DECODE(anyo, nduraci, anyo - 1, anyo)))),
                              0) ipripen,
                       (DECODE(pcrevali,
                               1,(pipriinv
                                  *(1
                                    +((pprevali / 100) * DECODE(anyo, nduraci, anyo - 1, anyo)))),
                               2,(pipriinv
                                  *(POWER((1 +(pprevali / 100)),
                                          DECODE(anyo, nduraci, anyo - 1, anyo)))),
                               0))
                       *((DECODE(psexo, 1, vmascul, 2, vfemeni, 0) / p_factor)
                         -(p_factor1 / p_factor))
                       *(POWER((1 +(pinttec / 100)), -(indice +(1 / 2)))) ipvppen,
                       (ppgasadm / 100)
                       *(DECODE(pcrevali,
                                1,(picapini
                                   *(1
                                     +((pprevali / 100) * DECODE(anyo,
                                                                 nduraci, anyo - 1,
                                                                 anyo)))),
                                2,(picapini
                                   *(POWER((1 +(pprevali / 100)),
                                           DECODE(anyo, nduraci, anyo - 1, anyo)))),
                                0)) igasadm,
                       (ppgasadm / 100)
                       *(DECODE(pcrevali,
                                1,(picapini
                                   *(1
                                     +((pprevali / 100) * DECODE(anyo,
                                                                 nduraci, anyo - 1,
                                                                 anyo)))),
                                2,(picapini
                                   *(POWER((1 +(pprevali / 100)),
                                           DECODE(anyo, nduraci, anyo - 1, anyo)))),
                                0))
                       *((DECODE(psexo, 1, vmascul, 2, vfemeni, 0) / p_factor))
                       *(POWER((1 +(pinttec / 100)), -indice)) ipvgadm,
                       ((DECODE(psexo, 1, vmascul, 2, vfemeni, 0) / p_factor))
                       *(POWER((1 +(pinttec / 100)), -indice))
                       *((DECODE(pcrevali,
                                 1,(pipriinv
                                    *(1
                                      +((pprevali / 100)
                                        * DECODE(anyo, nduraci, anyo - 1, anyo)))),
                                 2,(pipriinv
                                    *(POWER((1 +(pprevali / 100)),
                                            DECODE(anyo, nduraci, anyo - 1, anyo)))),
                                 0))) ioblase,
                       psproces
                  FROM mortalidad
                 WHERE nedad = edad
                   AND ctabla = pctiptab);
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 107109;
         END;

         indice := indice + 1;
         edad := edad + 1;
      END LOOP;

      RETURN 0;
   END f_matriz_provmat2;

-------------------------------------------------------------------------------------------------
   FUNCTION f_calcul_provmat2(
      pcempres IN NUMBER,
      psseguro IN NUMBER,
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      pcramdgs IN NUMBER,
      pnriesgo IN NUMBER,
      pcgarant IN NUMBER,
      pfefecto IN DATE,
      pfcalcul IN DATE,
      psproces IN NUMBER,
      pnduraci IN NUMBER,
      ppinttec IN NUMBER,
      ppgasext IN NUMBER,
      ppgasint IN NUMBER,
      pctabla IN NUMBER,
      pcprovis IN NUMBER,
      pcmoneda IN NUMBER)
      RETURN NUMBER IS
/************************************************************************************************
    Proceso que nos calcula las provisiones de vida ahorro diferido de primas regulares
    (MODULO 1)
************************************************************************************************/
      sexo           NUMBER;
      año            NUMBER;
      edad_actual    NUMBER;
      aux_fefeini    DATE;
      ttexto         VARCHAR2(20);
      nlin           NUMBER;
      num_err        NUMBER;
      conta_err      NUMBER := 0;
      xicapini       NUMBER;
      xcrevali       NUMBER;
      xirevali       NUMBER;
      xprevali       NUMBER;
      xipriini       NUMBER;
      frenova        DATE;
      xprovmat_prox  NUMBER;
      dias           NUMBER;
   BEGIN
      -- Calculamos los datos iniciales de la poliza (capital inicial, prima inicial, etc..)
      BEGIN
         SELECT icapital, crevali, irevali, prevali, iprianu
           INTO xicapini, xcrevali, xirevali, xprevali, xipriini
           FROM garanseg
          WHERE sseguro = psseguro
            AND nriesgo = pnriesgo
            AND cgarant = pcgarant
            AND nmovimi = 1;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN 103839;
      END;

      -- Calculamos el número de año actual real --no actuarial
      num_err := f_difdata(pfefecto, pfcalcul, 1, 1, año);

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      -- Calculamos la eda actual actuarial;
      frenova := ADD_MONTHS(pfefecto, 12 * año);
      num_err := f_edad_sexo(psseguro, frenova, 2, edad_actual, sexo);

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      -- Calculamos los días desde la fecha de renovación hasta la fecha de calculo
      num_err := f_difdata(frenova, pfcalcul, 1, 3, dias);

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      -- Calculamos la provision del año siguiente
      num_err := f_matriz_provmat2(año + 1, edad_actual + 1, sexo, NVL(pnduraci, 0), psproces,
                                   NVL(ppinttec, 6), NVL(xicapini, 0), xcrevali, xirevali,
                                   xprevali, xipriini, xipriini *(1 -(NVL(ppgasext, 0) / 100)),
                                   pctabla, NVL(ppgasint, 0));

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      BEGIN
         SELECT f_round((SUM(DECODE(nanyos, pnduraci, tpx, 0))
                         * SUM(DECODE(nanyos, pnduraci, vn, 0))
                         * SUM(DECODE(nanyos, pnduraci, iimpori, 0)))
                        +(SUM(DECODE(nanyos, pnduraci, 0, ipvppag)))
                        + SUM(DECODE(nanyos, pnduraci, 0, ipvgadm))
                        - SUM(DECODE(nanyos, pnduraci, 0, ioblase)),
                        pcmoneda)
           INTO xprovmat_prox
           FROM matrizprovmat
          WHERE sproces = psproces;
      EXCEPTION
         WHEN OTHERS THEN
            num_err := 107110;
      END;

      -- Borramos la matriz para volver a calcular la provision del año actual
      BEGIN
         DELETE FROM matrizprovmat
               WHERE sproces = psproces;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 107110;
      END;

      -- Calculamos la provision del año actual
      num_err := f_matriz_provmat2(año, edad_actual, sexo, NVL(pnduraci, 0), psproces,
                                   NVL(ppinttec, 6), NVL(xicapini, 0), xcrevali, xirevali,
                                   xprevali, xipriini, xipriini *(1 -(NVL(ppgasext, 0) / 100)),
                                   pctabla, NVL(ppgasint, 0));

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      BEGIN
         INSERT INTO provmat
                     (cempres, fcalcul, sproces, cramdgs, cramo, cmodali, ctipseg, ccolect,
                      sseguro, nriesgo, cgarant, cprovis, ipriini, ivalact, icapgar, ipromat,
                      cerror)
            (SELECT pcempres, pfcalcul, psproces, NVL(pcramdgs, 0), pcramo, pcmodali,
                    pctipseg, pccolect, psseguro, pnriesgo, pcgarant, pcprovis, xipriini,
                    f_round(DECODE(xcrevali,
                                   1,(xicapini *(1 +((xprevali / 100) * año))),
                                   2,(xicapini *(POWER((1 +(xprevali / 100)), año))),
                                   0),
                            pcmoneda),
                    f_round(DECODE(xcrevali,
                                   1,(xicapini *(1 +((xprevali / 100) *(pnduraci - 1)))),
                                   2,(xicapini *(POWER((1 +(xprevali / 100)),(pnduraci - 1)))),
                                   0),
                            pcmoneda),
                    f_round(((SUM(DECODE(nanyos, pnduraci, tpx, 0))
                              * SUM(DECODE(nanyos, pnduraci, vn, 0))
                              * SUM(DECODE(nanyos, pnduraci, iimpori, 0)))
                             +(SUM(DECODE(nanyos, pnduraci, 0, ipvppag)))
                             + SUM(DECODE(nanyos, pnduraci, 0, ipvgadm))
                             - SUM(DECODE(nanyos, pnduraci, 0, ioblase)))
                            +(dias / 365.25
                              *(xprovmat_prox
                                -((SUM(DECODE(nanyos, pnduraci, tpx, 0))
                                   * SUM(DECODE(nanyos, pnduraci, vn, 0))
                                   * SUM(DECODE(nanyos, pnduraci, iimpori, 0)))
                                  +(SUM(DECODE(nanyos, pnduraci, 0, ipvppag)))
                                  + SUM(DECODE(nanyos, pnduraci, 0, ipvgadm))
                                  - SUM(DECODE(nanyos, pnduraci, 0, ioblase)))))
                            +((1 - dias / 365.25) * SUM(DECODE(nanyos, año, ipripen, 0))),
                            pcmoneda),
                    0
               FROM matrizprovmat
              WHERE sproces = psproces);
      EXCEPTION
         WHEN OTHERS THEN
            num_err := 107110;
      END;

      IF num_err = 0 THEN
         DELETE FROM matrizprovmat
               WHERE sproces = psproces;

         COMMIT;
      ELSE
         RETURN num_err;
      END IF;

      RETURN 0;
   END f_calcul_provmat2;

------------------------------------------------------------------------------------------------
   FUNCTION f_matriz_provmat3(
      panyo IN NUMBER,
      pedad IN NUMBER,
      psexo IN NUMBER,
      nduraci IN NUMBER,
      psproces IN NUMBER,
      pinttec IN NUMBER,
      picapini IN NUMBER,
      pcrevali IN NUMBER,
      pirevali IN NUMBER,
      pprevali IN NUMBER,
      pipricom IN NUMBER,
      pipriinv IN NUMBER,
      pctiptab IN NUMBER,
      ppgasadm IN NUMBER)
      RETURN NUMBER IS
/************************************************************************************************
    F_MATRIZ_PROVMAT: nos calcula la matriz personalizada para una poliza basada en los
            valores de las tablas de mortalidad, PARA PRIMAS UNICAS
    ALLIBPRO
************************************************************************************************/
      indice         NUMBER;
      edad           NUMBER;
      anyo           NUMBER;
      p_factor       NUMBER;
      p_factor1      NUMBER;
      pripag         NUMBER := 0;
   BEGIN
      indice := 0;
      edad := pedad;

      -- Calculamos el valor de la tabla de mortalidad
      BEGIN
         SELECT DECODE(psexo, 1, vmascul, 2, vfemeni, 0)
           INTO p_factor
           FROM mortalidad
          WHERE nedad = pedad
            AND ctabla = pctiptab;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 107108;
      END;

      -- Las primas pagadas es la prima única inicial
      pripag := pipricom;

      FOR anyo IN panyo .. nduraci LOOP
         BEGIN
            SELECT DECODE(psexo, 1, vmascul, 2, vfemeni, 0)
              INTO p_factor1
              FROM mortalidad
             WHERE nedad = edad + 1
               AND ctabla = pctiptab;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 107108;
         END;

         BEGIN
            INSERT INTO matrizprovmat
                        (cindice, nanyos, nedad, ix, tpx, tpx1, tqx, vn, vn2, iimpori,
                         ipvppag, ipripen, ipvppen, igasadm, ipvgadm, ioblase, sproces)
               (SELECT indice, anyo, edad, DECODE(psexo, 1, vmascul, 2, vfemeni, 0) ix,
                       DECODE(psexo, 1, vmascul, 2, vfemeni, 0) / p_factor tpx,
                       p_factor1 / p_factor tpx1,
                       (DECODE(psexo, 1, vmascul, 2, vfemeni, 0) / p_factor)
                       -(p_factor1 / p_factor) tqx,
                       POWER((1 +(pinttec / 100)), -indice) vn,
                       POWER((1 +(pinttec / 100)), -(indice +(1 / 2))) vn2,
                       DECODE(pcrevali,
                              1,(picapini
                                 *(1
                                   +((pprevali / 100) * DECODE(anyo, nduraci, anyo - 1, anyo)))),
                              2,(picapini
                                 *(POWER((1 +(pprevali / 100)),
                                         DECODE(anyo, nduraci, anyo - 1, anyo)))),
                              0) iimpori,
                       pripag
                       *((DECODE(psexo, 1, vmascul, 2, vfemeni, 0) / p_factor)
                         -(p_factor1 / p_factor))
                       *(POWER((1 +(pinttec / 100)), -(indice +(1 / 2)))) ipvppag,
                       0 ipripen, 0 ipvppen,
                       (ppgasadm / 100)
                       *(DECODE(pcrevali,
                                1,(picapini
                                   *(1
                                     +((pprevali / 100) * DECODE(anyo,
                                                                 nduraci, anyo - 1,
                                                                 anyo)))),
                                2,(picapini
                                   *(POWER((1 +(pprevali / 100)),
                                           DECODE(anyo, nduraci, anyo - 1, anyo)))),
                                0)) igasadm,
                       (ppgasadm / 100)
                       *(DECODE(pcrevali,
                                1,(picapini
                                   *(1
                                     +((pprevali / 100) * DECODE(anyo,
                                                                 nduraci, anyo - 1,
                                                                 anyo)))),
                                2,(picapini
                                   *(POWER((1 +(pprevali / 100)),
                                           DECODE(anyo, nduraci, anyo - 1, anyo)))),
                                0))
                       *((DECODE(psexo, 1, vmascul, 2, vfemeni, 0) / p_factor))
                       *(POWER((1 +(pinttec / 100)), -indice)) ipvgadm,
                       0 ioblase, psproces
                  FROM mortalidad
                 WHERE nedad = edad
                   AND ctabla = pctiptab);
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 107109;
         END;

         indice := indice + 1;
         edad := edad + 1;
      END LOOP;

      RETURN 0;
   END f_matriz_provmat3;

-------------------------------------------------------------------------------------------------
   FUNCTION f_calcul_provmat3(
      pcempres IN NUMBER,
      psseguro IN NUMBER,
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      pcramdgs IN NUMBER,
      pnriesgo IN NUMBER,
      pcgarant IN NUMBER,
      pfefecto IN DATE,
      pfcalcul IN DATE,
      psproces IN NUMBER,
      pnduraci IN NUMBER,
      ppinttec IN NUMBER,
      ppgasext IN NUMBER,
      ppgasint IN NUMBER,
      pctabla IN NUMBER,
      pcprovis IN NUMBER,
      pcmoneda IN NUMBER)
      RETURN NUMBER IS
/************************************************************************************************
    Proceso que nos calcula las provisiones de vida ahorro diferido de PRIMAS UNICAS
    (MODULO 1)
************************************************************************************************/
      sexo           NUMBER;
      año            NUMBER;
      edad_actual    NUMBER;
      aux_fefeini    DATE;
      ttexto         VARCHAR2(20);
      nlin           NUMBER;
      num_err        NUMBER;
      conta_err      NUMBER := 0;
      xicapini       NUMBER;
      xcrevali       NUMBER;
      xirevali       NUMBER;
      xprevali       NUMBER;
      xipriini       NUMBER;
      frenova        DATE;
      dias           NUMBER;
      xprovmat_prox  NUMBER;
   BEGIN
      -- Calculamos los datos iniciales de la poliza (capital inicial, prima inicial, etc..)
      BEGIN
         SELECT icapital, crevali, irevali, prevali, iprianu
           INTO xicapini, xcrevali, xirevali, xprevali, xipriini
           FROM garanseg
          WHERE sseguro = psseguro
            AND nriesgo = pnriesgo
            AND cgarant = pcgarant
            AND nmovimi = 1;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN 103839;
      END;

      -- Calculamos el número de año actual real --no actuarial
      num_err := f_difdata(pfefecto, pfcalcul, 1, 1, año);

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      frenova := ADD_MONTHS(pfefecto, 12 * año);
      num_err := f_edad_sexo(psseguro, frenova, 2, edad_actual, sexo);

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      -- Calculamos los días desde la fecha de renovación hasta la fecha de calculo
      num_err := f_difdata(frenova, pfcalcul, 1, 3, dias);

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      -- Calculamos la provision del año siguiente
      num_err := f_matriz_provmat3(año + 1, edad_actual + 1, sexo, NVL(pnduraci, 0), psproces,
                                   NVL(ppinttec, 6), NVL(xicapini, 0), xcrevali, xirevali,
                                   xprevali, xipriini, xipriini *(1 -(NVL(ppgasext, 0) / 100)),
                                   pctabla, NVL(ppgasint, 0));

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      BEGIN
         SELECT f_round((SUM(DECODE(nanyos, pnduraci, tpx, 0))
                         * SUM(DECODE(nanyos, pnduraci, vn, 0))
                         * SUM(DECODE(nanyos, pnduraci, iimpori, 0)))
                        +(SUM(DECODE(nanyos, pnduraci, 0, ipvppag)))
                        + SUM(DECODE(nanyos, pnduraci, 0, ipvgadm))
                        - SUM(DECODE(nanyos, pnduraci, 0, ioblase)),
                        pcmoneda)
           INTO xprovmat_prox
           FROM matrizprovmat
          WHERE sproces = psproces;
      EXCEPTION
         WHEN OTHERS THEN
            num_err := 107110;
      END;

      -- Borramos la matriz para volver a calcular la provision del año actual
      BEGIN
         DELETE FROM matrizprovmat
               WHERE sproces = psproces;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 107110;
      END;

      -- Calculamos la provision del año actual
      num_err := f_matriz_provmat3(año, edad_actual, sexo, NVL(pnduraci, 0), psproces,
                                   NVL(ppinttec, 6), NVL(xicapini, 0), xcrevali, xirevali,
                                   xprevali, xipriini, xipriini *(1 -(NVL(ppgasext, 0) / 100)),
                                   pctabla, NVL(ppgasint, 0));

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      BEGIN
         INSERT INTO provmat
                     (cempres, fcalcul, sproces, cramdgs, cramo, cmodali, ctipseg, ccolect,
                      sseguro, nriesgo, cgarant, cprovis, ipriini, ivalact, icapgar, ipromat,
                      cerror)
            (SELECT pcempres, pfcalcul, psproces, NVL(pcramdgs, 0), pcramo, pcmodali,
                    pctipseg, pccolect, psseguro, pnriesgo, pcgarant, pcprovis, xipriini,
                    f_round(DECODE(xcrevali,
                                   1,(xicapini *(1 +((xprevali / 100) * año))),
                                   2,(xicapini *(POWER((1 +(xprevali / 100)), año))),
                                   0),
                            pcmoneda),
                    f_round(DECODE(xcrevali,
                                   1,(xicapini *(1 +((xprevali / 100) *(pnduraci - 1)))),
                                   2,(xicapini *(POWER((1 +(xprevali / 100)),(pnduraci - 1)))),
                                   0),
                            pcmoneda),
                    f_round(((SUM(DECODE(nanyos, pnduraci, tpx, 0))
                              * SUM(DECODE(nanyos, pnduraci, vn, 0))
                              * SUM(DECODE(nanyos, pnduraci, iimpori, 0)))
                             +(SUM(DECODE(nanyos, pnduraci, 0, ipvppag)))
                             + SUM(DECODE(nanyos, pnduraci, 0, ipvgadm)))
                            +(dias / 365.25
                              *(xprovmat_prox
                                -((SUM(DECODE(nanyos, pnduraci, tpx, 0))
                                   * SUM(DECODE(nanyos, pnduraci, vn, 0))
                                   * SUM(DECODE(nanyos, pnduraci, iimpori, 0)))
                                  +(SUM(DECODE(nanyos, pnduraci, 0, ipvppag)))
                                  + SUM(DECODE(nanyos, pnduraci, 0, ipvgadm)))))
                            +((1 - dias / 365.25) * SUM(DECODE(nanyos, año, ipripen, 0))),
                            pcmoneda),
                    0
               FROM matrizprovmat
              WHERE sproces = psproces);
      EXCEPTION
         WHEN OTHERS THEN
            num_err := 107110;
      END;

      IF num_err = 0 THEN
         DELETE FROM matrizprovmat
               WHERE sproces = psproces;

         COMMIT;
      ELSE
         RETURN num_err;
      END IF;

      RETURN 0;
   END f_calcul_provmat3;

------------------------------------------------------------------------------------------------
   FUNCTION f_matriz_provmat4(
      panyo IN NUMBER,
      pedad IN NUMBER,
      psexo IN NUMBER,
      nduraci IN NUMBER,
      psproces IN NUMBER,
      pinttec IN NUMBER,
      picapini IN NUMBER,
      pcrevali IN NUMBER,
      pirevali IN NUMBER,
      pprevali IN NUMBER,
      pipricom IN NUMBER,
      pipriinv IN NUMBER,
      pctiptab IN NUMBER,
      ppgasadm IN NUMBER)
      RETURN NUMBER IS
/************************************************************************************************
    F_MATRIZ_PROVMAT: nos calcula la matriz personalizada para una poliza basada en los
            valores de las tablas de mortalidad, PARA PRIMAS REGULARES DE PF30
    ALLIBPRO
************************************************************************************************/
      indice         NUMBER;
      edad           NUMBER;
      anyo           NUMBER;
      p_factor       NUMBER;
      p_factor1      NUMBER;
   BEGIN
      indice := 0;
      edad := pedad;

      -- Calculamos el valor de la tabla de mortalidad
      BEGIN
         SELECT DECODE(psexo, 1, vmascul, 2, vfemeni, 0)
           INTO p_factor
           FROM mortalidad
          WHERE nedad = pedad
            AND ctabla = pctiptab;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 107108;
      END;

      FOR anyo IN panyo .. nduraci LOOP
         BEGIN
            SELECT DECODE(psexo, 1, vmascul, 2, vfemeni, 0)
              INTO p_factor1
              FROM mortalidad
             WHERE nedad = edad + 1
               AND ctabla = pctiptab;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 107108;
         END;

         BEGIN
            INSERT INTO matrizprovmat
                        (cindice, nanyos, nedad, ix, tpx, tpx1, tqx, vn, vn2, iimpori,
                         ipvppag, ipripen, ipvppen, igasadm, ipvgadm, ioblase, sproces)
               (SELECT indice, anyo, edad, DECODE(psexo, 1, vmascul, 2, vfemeni, 0) ix,
                       DECODE(psexo, 1, vmascul, 2, vfemeni, 0) / p_factor tpx,
                       p_factor1 / p_factor tpx1,
                       (DECODE(psexo, 1, vmascul, 2, vfemeni, 0) / p_factor)
                       -(p_factor1 / p_factor) tqx,
                       POWER((1 +(pinttec / 100)), -indice) vn,
                       POWER((1 +(pinttec / 100)), -(indice +(1 / 2))) vn2,
                       DECODE(pcrevali,
                              1,(picapini
                                 *(1
                                   +((pprevali / 100) * DECODE(anyo, nduraci, anyo - 1, anyo)))),
                              2,(picapini
                                 *(POWER((1 +(pprevali / 100)),
                                         DECODE(anyo, nduraci, anyo - 1, anyo)))),
                              0) iimpori,
                       (DECODE(pcrevali,
                               1,(picapini
                                  *(1
                                    +((pprevali / 100) * DECODE(anyo, nduraci, anyo - 1, anyo)))),
                               2,(picapini
                                  *(POWER((1 +(pprevali / 100)),
                                          DECODE(anyo, nduraci, anyo - 1, anyo)))),
                               0))
                       *((DECODE(psexo, 1, vmascul, 2, vfemeni, 0) / p_factor)
                         -(p_factor1 / p_factor))
                       *(POWER((1 +(pinttec / 100)), -(indice +(1 / 2)))) ipvppag,
                       DECODE(pcrevali,
                              1,(pipriinv
                                 *(1
                                   +((pprevali / 100) * DECODE(anyo, nduraci, anyo - 1, anyo)))),
                              2,(pipriinv
                                 *(POWER((1 +(pprevali / 100)),
                                         DECODE(anyo, nduraci, anyo - 1, anyo)))),
                              0) ipripen,
                       (DECODE(pcrevali,
                               1,(pipriinv
                                  *(1
                                    +((pprevali / 100) * DECODE(anyo, nduraci, anyo - 1, anyo)))),
                               2,(pipriinv
                                  *(POWER((1 +(pprevali / 100)),
                                          DECODE(anyo, nduraci, anyo - 1, anyo)))),
                               0))
                       *((DECODE(psexo, 1, vmascul, 2, vfemeni, 0) / p_factor)
                         -(p_factor1 / p_factor))
                       *(POWER((1 +(pinttec / 100)), -(indice +(1 / 2)))) ipvppen,
                       (ppgasadm / 100)
                       *(DECODE(pcrevali,
                                1,(picapini
                                   *(1
                                     +((pprevali / 100) * DECODE(anyo,
                                                                 nduraci, anyo - 1,
                                                                 anyo)))),
                                2,(picapini
                                   *(POWER((1 +(pprevali / 100)),
                                           DECODE(anyo, nduraci, anyo - 1, anyo)))),
                                0)) igasadm,
                       (ppgasadm / 100)
                       *(DECODE(pcrevali,
                                1,(picapini
                                   *(1
                                     +((pprevali / 100) * DECODE(anyo,
                                                                 nduraci, anyo - 1,
                                                                 anyo)))),
                                2,(picapini
                                   *(POWER((1 +(pprevali / 100)),
                                           DECODE(anyo, nduraci, anyo - 1, anyo)))),
                                0))
                       *((DECODE(psexo, 1, vmascul, 2, vfemeni, 0) / p_factor))
                       *(POWER((1 +(pinttec / 100)), -indice)) ipvgadm,
                       ((DECODE(psexo, 1, vmascul, 2, vfemeni, 0) / p_factor))
                       *(POWER((1 +(pinttec / 100)), -indice))
                       *((DECODE(pcrevali,
                                 1,(pipriinv
                                    *(1
                                      +((pprevali / 100)
                                        * DECODE(anyo, nduraci, anyo - 1, anyo)))),
                                 2,(pipriinv
                                    *(POWER((1 +(pprevali / 100)),
                                            DECODE(anyo, nduraci, anyo - 1, anyo)))),
                                 0))) ioblase,
                       psproces
                  FROM mortalidad
                 WHERE nedad = edad
                   AND ctabla = pctiptab);
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 107109;
         END;

         indice := indice + 1;
         edad := edad + 1;
      END LOOP;

      RETURN 0;
   END f_matriz_provmat4;

-------------------------------------------------------------------------------------------------
   FUNCTION f_calcul_provmat4(
      pcempres IN NUMBER,
      psseguro IN NUMBER,
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      pcramdgs IN NUMBER,
      pnriesgo IN NUMBER,
      pcgarant IN NUMBER,
      pfefecto IN DATE,
      pfcalcul IN DATE,
      psproces IN NUMBER,
      pnduraci IN NUMBER,
      ppinttec IN NUMBER,
      ppgasext IN NUMBER,
      ppgasint IN NUMBER,
      pctabla IN NUMBER,
      pcprovis IN NUMBER,
      pcmoneda IN NUMBER)
      RETURN NUMBER IS
/************************************************************************************************
    Proceso que nos calcula las provisiones de vida mixto revalorizable prima periódica PF30
    (MODULO 3)
************************************************************************************************/
      sexo           NUMBER;
      año            NUMBER;
      edad_actual    NUMBER;
      aux_fefeini    DATE;
      ttexto         VARCHAR2(20);
      nlin           NUMBER;
      num_err        NUMBER;
      conta_err      NUMBER := 0;
      xicapini       NUMBER;
      xcrevali       NUMBER;
      xirevali       NUMBER;
      xprevali       NUMBER;
      xipriini       NUMBER;
      frenova        DATE;
      dias           NUMBER;
      xprovmat_prox  NUMBER;
   BEGIN
      -- Calculamos los datos iniciales de la poliza (capital inicial, prima inicial, etc..)
      BEGIN
         SELECT icapital, crevali, irevali, prevali, iprianu
           INTO xicapini, xcrevali, xirevali, xprevali, xipriini
           FROM garanseg
          WHERE sseguro = psseguro
            AND nriesgo = pnriesgo
            AND cgarant = pcgarant
            AND nmovimi = 1;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN 103839;
      END;

      -- Calculamos el número de año actual real --no actuarial
      num_err := f_difdata(pfefecto, pfcalcul, 1, 1, año);

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      -- Calculamos la eda actual actuarial;
      frenova := ADD_MONTHS(pfefecto, 12 * año);
      num_err := f_edad_sexo(psseguro, frenova, 2, edad_actual, sexo);
      -- Calculamos los días desde la fecha de renovación hasta la fecha de calculo
      num_err := f_difdata(frenova, pfcalcul, 1, 3, dias);

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      -- Calculamos la provision del año siguiente
      num_err := f_matriz_provmat4(año + 1, edad_actual + 1, sexo, NVL(pnduraci, 0), psproces,
                                   NVL(ppinttec, 6), NVL(xicapini, 0), xcrevali, xirevali,
                                   xprevali, xipriini, xipriini *(1 -(NVL(ppgasext, 0) / 100)),
                                   pctabla, NVL(ppgasint, 0));

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      BEGIN
         SELECT f_round((SUM(DECODE(nanyos, pnduraci, tpx, 0))
                         * SUM(DECODE(nanyos, pnduraci, vn, 0))
                         * SUM(DECODE(nanyos, pnduraci, iimpori, 0)))
                        +(SUM(DECODE(nanyos, pnduraci, 0, ipvppag)))
                        + SUM(DECODE(nanyos, pnduraci, 0, ipvgadm))
                        - SUM(DECODE(nanyos, pnduraci, 0, ioblase)),
                        pcmoneda)
           INTO xprovmat_prox
           FROM matrizprovmat
          WHERE sproces = psproces;
      EXCEPTION
         WHEN OTHERS THEN
            num_err := 107110;
      END;

      -- Borramos la matriz para volver a calcular la provision del año actual
      BEGIN
         DELETE FROM matrizprovmat
               WHERE sproces = psproces;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 107110;
      END;

      -- Calculamos la provision del año actual
      num_err := f_matriz_provmat4(año, edad_actual, sexo, NVL(pnduraci, 0), psproces,
                                   NVL(ppinttec, 6), NVL(xicapini, 0), xcrevali, xirevali,
                                   xprevali, xipriini, xipriini *(1 -(NVL(ppgasext, 0) / 100)),
                                   pctabla, NVL(ppgasint, 0));

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      BEGIN
         INSERT INTO provmat
                     (cempres, fcalcul, sproces, cramdgs, cramo, cmodali, ctipseg, ccolect,
                      sseguro, nriesgo, cgarant, cprovis, ipriini, ivalact, icapgar, ipromat,
                      cerror)
            (SELECT pcempres, pfcalcul, psproces, NVL(pcramdgs, 0), pcramo, pcmodali,
                    pctipseg, pccolect, psseguro, pnriesgo, pcgarant, pcprovis, xipriini,
                    f_round(DECODE(xcrevali,
                                   1,(xicapini *(1 +((xprevali / 100) * año))),
                                   2,(xicapini *(POWER((1 +(xprevali / 100)), año))),
                                   0),
                            pcmoneda),
                    f_round(DECODE(xcrevali,
                                   1,(xicapini *(1 +((xprevali / 100) *(pnduraci - 1)))),
                                   2,(xicapini *(POWER((1 +(xprevali / 100)),(pnduraci - 1)))),
                                   0),
                            pcmoneda),
                    f_round(((SUM(DECODE(nanyos, pnduraci, tpx, 0))
                              * SUM(DECODE(nanyos, pnduraci, vn, 0))
                              * SUM(DECODE(nanyos, pnduraci, iimpori, 0)))
                             +(SUM(DECODE(nanyos, pnduraci, 0, ipvppag)))
                             + SUM(DECODE(nanyos, pnduraci, 0, ipvgadm))
                             - SUM(DECODE(nanyos, pnduraci, 0, ioblase)))
                            +(dias / 365.25
                              *(xprovmat_prox
                                -((SUM(DECODE(nanyos, pnduraci, tpx, 0))
                                   * SUM(DECODE(nanyos, pnduraci, vn, 0))
                                   * SUM(DECODE(nanyos, pnduraci, iimpori, 0)))
                                  +(SUM(DECODE(nanyos, pnduraci, 0, ipvppag)))
                                  + SUM(DECODE(nanyos, pnduraci, 0, ipvgadm))
                                  - SUM(DECODE(nanyos, pnduraci, 0, ioblase)))))
                            +((1 - dias / 365.25) * SUM(DECODE(nanyos, año, ipripen, 0))),
                            pcmoneda),
                    0
               FROM matrizprovmat
              WHERE sproces = psproces);
      EXCEPTION
         WHEN OTHERS THEN
            num_err := 107110;
      END;

      IF num_err = 0 THEN
         DELETE FROM matrizprovmat
               WHERE sproces = psproces;

         COMMIT;
      ELSE
         RETURN num_err;
      END IF;

      RETURN 0;
   END f_calcul_provmat4;

------------------------------------------------------------------------------------------------
   FUNCTION f_matriz_provmat5(
      panyo IN NUMBER,
      pedad IN NUMBER,
      psexo IN NUMBER,
      nduraci IN NUMBER,
      psproces IN NUMBER,
      pinttec IN NUMBER,
      pctiptab IN NUMBER,
      ppgasint IN NUMBER,
      ppgasext IN NUMBER,
      picapaho IN NUMBER,
      pirevcapaho IN NUMBER,
      picapries IN NUMBER,
      pirevcapries IN NUMBER,
      piprimaho IN NUMBER,
      pirevprimaho IN NUMBER,
      piprimries IN NUMBER,
      pirevprimries IN NUMBER,
      pduragar IN NUMBER,
      pcapmuer IN NUMBER,
      pirevprimriestot IN NUMBER,
      piprimriestot IN NUMBER)
      RETURN NUMBER IS
/************************************************************************************************
    F_MATRIZ_PROVMAT: nos calcula la matriz personalizada para una poliza basada en los
            valores de las tablas de mortalidad, PARA LOS PF20
    ALLIBPRO
************************************************************************************************/
      indice         NUMBER;
      edad           NUMBER;
      anyo           NUMBER;
      p_factor       NUMBER;
      p_factor1      NUMBER;
      pripag         NUMBER := 0;
      wvalgar        NUMBER := 0;
      anyories       NUMBER;
      priahoinvacum  NUMBER := 0;
   BEGIN
      IF (panyo - pduragar) < 0 THEN
         anyories := 0;
      ELSE
         anyories := panyo - pduragar;
      END IF;

      indice := 0;
      edad := pedad;

      -- Calculamos el valor de la tabla de mortalidad
      BEGIN
         SELECT DECODE(psexo, 1, vmascul, 2, vfemeni, 0)
           INTO p_factor
           FROM mortalidad
          WHERE nedad = pedad
            AND ctabla = pctiptab;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 107108;
      END;

      FOR anyo IN panyo .. nduraci LOOP
         IF anyo >= pduragar THEN
-- variable que vale 1 cuando se llega al final de la duración de la garantía de muerte y entra
-- en vigor la garantía de capital garantizado. Es decir, año 0 de la nueva garantía y ambas estan
-- en vigor.
            wvalgar := 1;
            anyories := anyo - pduragar;
         END IF;

         priahoinvacum := 0;

         FOR i IN 0 .. anyo LOOP
            IF i - pduragar < 0 THEN
               priahoinvacum := priahoinvacum
                                +((piprimaho +(pirevprimaho * i)) *(1 - ppgasext / 100));
            ELSE
               priahoinvacum := priahoinvacum
                                + ((piprimaho + pirevprimaho * i)
                                   +(piprimriestot + pirevprimriestot *(i - pduragar + 1)))
                                  *(1 - ppgasext / 100);
            END IF;
         END LOOP;

         IF anyories = 0 THEN
            priahoinvacum := priahoinvacum + pcapmuer;
         END IF;

         BEGIN
            SELECT DECODE(psexo, 1, vmascul, 2, vfemeni, 0)
              INTO p_factor1
              FROM mortalidad
             WHERE nedad = edad + 1
               AND ctabla = pctiptab;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 107108;
         END;

         BEGIN
            INSERT INTO matrizprovmatpf20
                        (cindice, nanyos, nanyosries, nedad, ix, tpx, tpx1, tqx, vn, vn2,
                         vecvida, vecmort, icapaho, icapries, iprimaho, iprahoinv, iprimries,
                         itotprim, ipriminv, igascapv, ipgascapv, ipcmort, ippmort, ipinvvid,
                         ippinvvi, sproces)
               (SELECT indice, anyo, anyories, edad,
                       DECODE(psexo, 1, vmascul, 2, vfemeni, 0) ix,
                       DECODE(psexo, 1, vmascul, 2, vfemeni, 0) / p_factor tpx,
                       p_factor1 / p_factor tpx1,
                       (DECODE(psexo, 1, vmascul, 2, vfemeni, 0) / p_factor)
                       -(p_factor1 / p_factor) tqx,
                       POWER((1 +(pinttec / 100)), -indice) vn,
                       POWER((1 +(pinttec / 100)), -(indice +(1 / 2))) vn2,
                       (DECODE(psexo, 1, vmascul, 2, vfemeni, 0) / p_factor)
                       *(POWER((1 +(pinttec / 100)), -indice)) vecvida,
                       ((DECODE(psexo, 1, vmascul, 2, vfemeni, 0) / p_factor)
                        -(p_factor1 / p_factor))
                       *(POWER((1 +(pinttec / 100)), -(indice +(1 / 2)))) vecmort,
                       picapaho + pirevcapaho * anyo icapaho,
                       DECODE(wvalgar, 0, 0, 1, picapries + pirevcapries * anyories) icapries,
                       DECODE(wvalgar,
                              0,(piprimaho + pirevprimaho * anyo),
                              (piprimaho + pirevprimaho * anyo)
                              +(piprimriestot + pirevprimriestot *(anyories + 1))) iprimaho,
                       DECODE(wvalgar,
                              0,((piprimaho + pirevprimaho * anyo) *(1 - ppgasext / 100)),
                              (((piprimaho + pirevprimaho * anyo)
                                +(piprimriestot + pirevprimriestot *(anyories + 1)))
                               *(1 - ppgasext / 100))) iprahoinv,
                       DECODE(wvalgar, 0, piprimries, 1, 0) iprimries,
                       DECODE(wvalgar,
                              0,(piprimaho + pirevprimaho * anyo),
                              (piprimaho + pirevprimaho * anyo)
                              +(piprimriestot + pirevprimriestot *(anyories + 1)))
                       + DECODE(wvalgar, 0, piprimries, 1, 0) itotprim,
                       (DECODE(wvalgar,
                               0,(piprimaho + pirevprimaho * anyo),
                               (piprimaho + pirevprimaho * anyo)
                               +(piprimriestot + pirevprimriestot *(anyories + 1)))
                        + DECODE(wvalgar, 0, piprimries, 1, 0))
                       *(1 - ppgasext / 100) ipriminv,
                       ((picapaho + pirevcapaho * anyo)
                        + DECODE(wvalgar, 0, 0, 1, picapries + pirevcapries * anyories))
                       *(ppgasint / 100) igascapv,
                       (((picapaho + pirevcapaho * anyo)
                         + DECODE(wvalgar, 0, 0, 1, picapries + pirevcapries * anyories))
                        *(ppgasint / 100))
                       *((DECODE(psexo, 1, vmascul, 2, vfemeni, 0) / p_factor)
                         *(POWER((1 +(pinttec / 100)), -indice))) ipgascapv,
                       priahoinvacum ipcmort,
                       priahoinvacum
                       *(((DECODE(psexo, 1, vmascul, 2, vfemeni, 0) / p_factor)
                          -(p_factor1 / p_factor))
                         *(POWER((1 +(pinttec / 100)), -(indice +(1 / 2))))) ippmort,
                       (DECODE(wvalgar,
                               0,(piprimaho + pirevprimaho * anyo),
                               (piprimaho + pirevprimaho * anyo)
                               +(piprimriestot + pirevprimriestot *(anyories + 1)))
                        + DECODE(wvalgar, 0, piprimries, 1, 0))
                       *(1 - ppgasext / 100) ipinvvid,
                       (DECODE(wvalgar,
                               0,(piprimaho + pirevprimaho * anyo),
                               (piprimaho + pirevprimaho * anyo)
                               +(piprimriestot + pirevprimriestot *(anyories + 1)))
                        + DECODE(wvalgar, 0, piprimries, 1, 0))
                       *(1 - ppgasext / 100)
                       *((DECODE(psexo, 1, vmascul, 2, vfemeni, 0) / p_factor)
                         *(POWER((1 +(pinttec / 100)), -indice))) ippinvvi,
                       psproces
                  FROM mortalidad
                 WHERE nedad = edad
                   AND ctabla = pctiptab);
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 107109;
         END;

         indice := indice + 1;
         edad := edad + 1;
      END LOOP;

      RETURN 0;
   END f_matriz_provmat5;

-------------------------------------------------------------------------------------------------
   FUNCTION f_calcul_provmat5(
      pcempres IN NUMBER,
      psseguro IN NUMBER,
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      pcramdgs IN NUMBER,
      pnriesgo IN NUMBER,
      pcgarant IN NUMBER,
      pfefecto IN DATE,
      pfcalcul IN DATE,
      psproces IN NUMBER,
      pnduraci IN NUMBER,
      ppinttec IN NUMBER,
      ppgasext IN NUMBER,
      ppgasint IN NUMBER,
      pctabla IN NUMBER,
      pcprovis IN NUMBER,
      pcmoneda IN NUMBER,
      pcforpag IN NUMBER)
      RETURN NUMBER IS
/************************************************************************************************
    Proceso de cálculo de provisiones para los PF20
    (MODULO 5)
************************************************************************************************/
      sexo           NUMBER;
      año            NUMBER;
      edad_actual    NUMBER;
      aux_fefeini    DATE;
      ttexto         VARCHAR2(20);
      nlin           NUMBER;
      num_err        NUMBER;
      conta_err      NUMBER := 0;
      xcrevali       NUMBER;
      xirevali       NUMBER;
      xprevali       NUMBER;
      saldo          NUMBER;
      xicapaho       NUMBER;
      xirevcapaho    NUMBER;
      xiprimaho      NUMBER;
      xirevprimaho   NUMBER;
      xipriries      NUMBER;
      xirevprimries  NUMBER;
      xicapries      NUMBER;
      xirevcapries   NUMBER;
      xcapmue        NUMBER;
      duracion_gar   NUMBER;
      xfiniefe       DATE;
      frenova        DATE;
      xipririestot   NUMBER := 0;
      xirevprimriestot NUMBER;
      dias           NUMBER;
      xprovmat_prox  NUMBER;
   BEGIN
      -- Calculamos los datos iniciales de la poliza (capital inicial, prima inicial, etc..)
      BEGIN
         SELECT NVL(icapital, 0), NVL(crevali, 0), NVL(irevali, 0), NVL(prevali, 0),
                NVL(iprianu, 0)
           INTO xicapaho, xcrevali, xirevali, xprevali,
                xiprimaho
           FROM garanseg
          WHERE sseguro = psseguro
            AND nriesgo = pnriesgo
            AND cgarant = 8019
            AND nmovimi = 1;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN 103839;
      END;

      -- Calculamos la prima de riesgo de la garantía de muerte
      BEGIN
         SELECT NVL(iprianu, 0), NVL(icapital, 0)
           INTO xipriries, xcapmue
           FROM garanseg
          WHERE sseguro = psseguro
            AND nriesgo = pnriesgo
            AND cgarant = 8022
            AND nmovimi = 1;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN 103839;
      END;

      -- Calculamos la suma de las primas de riesgo, para poder saber la revalorización del
      -- capital cuando venza la garantía de muerte
      BEGIN
         SELECT SUM(NVL(iprianu, 0))
           INTO xipririestot
           FROM garanseg
          WHERE sseguro = psseguro
            AND nriesgo = pnriesgo
            AND cgarant NOT IN(283, 286, 8019)
            AND nmovimi = 1;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN 103839;
      END;

      -- Calculamos la fecha inicio de la garantia 286
      BEGIN
         SELECT finiefe, NVL(icapital, 0)
           INTO xfiniefe, xicapries
           FROM garanseg
          WHERE sseguro = psseguro
            AND nriesgo = pnriesgo
            AND cgarant = 286
            AND nmovimi = (SELECT MIN(nmovimi)
                             FROM garanseg
                            WHERE sseguro = psseguro
                              AND nriesgo = pnriesgo
                              AND cgarant = 286);
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN 103839;
      END;

      -- Cálculo de la duración de la garantía de muerte
      num_err := f_difdata(pfefecto, xfiniefe, 1, 1, duracion_gar);

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      -- Calculamos el número de año actual real --no actuarial
      num_err := f_difdata(pfefecto, pfcalcul, 1, 1, año);

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      -- revalorizacion lineal para todo el producto, por definición del mismo
         -- importe de revalorización de la prima de ahorro
      xirevprimaho := xiprimaho * xprevali / 100;
      -- importe de revalorización del capital de ahorro
      xirevcapaho := xicapaho * xprevali / 100;
      -- importe de revalorización del capital de riesgo
      xirevcapries := xicapries * xprevali / 100;
      -- importe de revalorización de la prima de riesgo
      xirevprimries := xipriries * xprevali / 100;
      -- importe de revalorización de la prima de riesgo total
      xirevprimriestot := xipririestot * xprevali / 100;
      frenova := ADD_MONTHS(pfefecto, 12 * año);
      num_err := f_edad_sexo(psseguro, frenova, 2, edad_actual, sexo);
      -- Calculamos los días desde la fecha de renovación hasta la fecha de calculo
      num_err := f_difdata(frenova, pfcalcul, 1, 3, dias);

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      -- Calculamos la provision del año siguiente
      num_err := f_matriz_provmat5(año + 1, edad_actual + 1, sexo, NVL(pnduraci, 0), psproces,
                                   NVL(ppinttec, 6), pctabla, NVL(ppgasint, 0), ppgasext,
                                   xicapaho, xirevcapaho, xicapries, xirevcapries, xiprimaho,
                                   xirevprimaho, xipriries, xirevprimries, duracion_gar,
                                   xcapmue, xirevprimriestot, xipririestot);

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      BEGIN
         SELECT f_round(((SUM(DECODE(nanyos, pnduraci, icapaho, 0))
                          + SUM(DECODE(nanyos, pnduraci, icapries, 0)))
                         * SUM(DECODE(nanyos, pnduraci, vecvida, 0)))
                        + SUM(DECODE(nanyos, pnduraci, 0, ipgascapv))
                        + SUM(DECODE(nanyos, pnduraci, 0, ippmort))
                        - SUM(DECODE(nanyos, pnduraci, 0, ippinvvi)),
                        pcmoneda)
           INTO xprovmat_prox
           FROM matrizprovmatpf20
          WHERE sproces = psproces;
      EXCEPTION
         WHEN OTHERS THEN
            num_err := 107110;
      END;

      -- Borramos la matriz para volver a calcular la provision del año actual
      BEGIN
         DELETE FROM matrizprovmatpf20
               WHERE sproces = psproces;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 107110;
      END;

      -- Calculamos la provision del año actual
      num_err := f_matriz_provmat5(año, edad_actual, sexo, NVL(pnduraci, 0), psproces,
                                   NVL(ppinttec, 6), pctabla, NVL(ppgasint, 0), ppgasext,
                                   xicapaho, xirevcapaho, xicapries, xirevcapries, xiprimaho,
                                   xirevprimaho, xipriries, xirevprimries, duracion_gar,
                                   xcapmue, xirevprimriestot, xipririestot);

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      BEGIN
         INSERT INTO provmat
                     (cempres, fcalcul, sproces, cramdgs, cramo, cmodali, ctipseg, ccolect,
                      sseguro, nriesgo, cgarant, cprovis, ipriini, ivalact, icapgar, ipromat,
                      cerror)
            (SELECT pcempres, pfcalcul, psproces, NVL(pcramdgs, 0), pcramo, pcmodali,
                    pctipseg, pccolect, psseguro, pnriesgo, pcgarant, pcprovis, xiprimaho,
                    f_round(SUM(DECODE(nanyos, año,(icapaho + icapries), 0)), pcmoneda),
                    f_round((SUM(DECODE(nanyos, pnduraci, icapaho, 0))
                             + SUM(DECODE(nanyos, pnduraci, icapries, 0))),
                            pcmoneda),
                    f_round((((SUM(DECODE(nanyos, pnduraci, icapaho, 0))
                               + SUM(DECODE(nanyos, pnduraci, icapries, 0)))
                              * SUM(DECODE(nanyos, pnduraci, vecvida, 0)))
                             + SUM(DECODE(nanyos, pnduraci, 0, ipgascapv))
                             + SUM(DECODE(nanyos, pnduraci, 0, ippmort))
                             - SUM(DECODE(nanyos, pnduraci, 0, ippinvvi)))
                            +(dias / 365.25
                              *(xprovmat_prox
                                -(((SUM(DECODE(nanyos, pnduraci, icapaho, 0))
                                    + SUM(DECODE(nanyos, pnduraci, icapries, 0)))
                                   * SUM(DECODE(nanyos, pnduraci, vecvida, 0)))
                                  + SUM(DECODE(nanyos, pnduraci, 0, ipgascapv))
                                  + SUM(DECODE(nanyos, pnduraci, 0, ippmort))
                                  - SUM(DECODE(nanyos, pnduraci, 0, ippinvvi)))))
                            +((1 - dias / 365.25) * SUM(DECODE(nanyos, año, ipinvvid, 0))),
                            pcmoneda),
                    0
               FROM matrizprovmatpf20
              WHERE sproces = psproces);
      EXCEPTION
         WHEN OTHERS THEN
            num_err := 107110;
      END;

      IF num_err = 0 THEN
         DELETE FROM matrizprovmatpf20
               WHERE sproces = psproces;

         COMMIT;
      ELSE
         RETURN num_err;
      END IF;

      RETURN 0;
   END f_calcul_provmat5;

------------------------------------------------------------------------------------------------
   FUNCTION f_matriz_provmat6(
      panyo IN NUMBER,
      pedad IN NUMBER,
      psexo IN NUMBER,
      nduraci IN NUMBER,
      psproces IN NUMBER,
      pinttec IN NUMBER,
      picapini IN NUMBER,
      pcrevali IN NUMBER,
      pirevali IN NUMBER,
      pprevali IN NUMBER,
      pipricom IN NUMBER,
      pipriinv IN NUMBER,
      pctiptab IN NUMBER,
      ppgasint IN NUMBER,
      ppgasext IN NUMBER,
      pcforpag IN NUMBER)
      RETURN NUMBER IS
/************************************************************************************************
    F_MATRIZ_PROVMAT: nos calcula la matriz personalizada para una poliza basada en los
            valores de las tablas de mortalidad, PARA PLANES DE JUBILACION
    ALLIBPRO
************************************************************************************************/
      indice         NUMBER;
      edad           NUMBER;
      anyo           NUMBER;
      p_factor       NUMBER;
      p_factor1      NUMBER;
      pripag         NUMBER := 0;
   BEGIN
      indice := 0;
      edad := pedad;

      -- Calculamos el valor de la tabla de mortalidad
      BEGIN
         SELECT DECODE(psexo, 1, vmascul, 2, vfemeni, 0)
           INTO p_factor
           FROM mortalidad
          WHERE nedad = pedad
            AND ctabla = pctiptab;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 107108;
      END;

      FOR anyo IN panyo .. nduraci LOOP
         IF pcforpag = 0 THEN   -- prima única
            pripag := pipricom *(1 - ppgasext / 100);
         ELSE
            pripag := 0;

            FOR i IN 0 .. anyo LOOP
               pripag := pripag +((pipricom +(pirevali * i)) *(1 - ppgasext / 100));
            END LOOP;
         END IF;

         BEGIN
            SELECT DECODE(psexo, 1, vmascul, 2, vfemeni, 0)
              INTO p_factor1
              FROM mortalidad
             WHERE nedad = edad + 1
               AND ctabla = pctiptab;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 107108;
         END;

         BEGIN
            INSERT INTO matrizprovmatpj
                        (cindice, nanyos, nedad, ix, tpx, tpx1, tqx, vn, vn2, vecvida,
                         vecmort, igaspvi, ipgasvi, ipcmort, ippmort, ipinviv, ippinvi,
                         sproces)
               (SELECT indice, anyo, edad, DECODE(psexo, 1, vmascul, 2, vfemeni, 0) ix,
                       DECODE(psexo, 1, vmascul, 2, vfemeni, 0) / p_factor tpx,
                       p_factor1 / p_factor tpx1,
                       (DECODE(psexo, 1, vmascul, 2, vfemeni, 0) / p_factor)
                       -(p_factor1 / p_factor) tqx,
                       POWER((1 +(pinttec / 100)), -indice) vn,
                       POWER((1 +(pinttec / 100)), -(indice +(1 / 2))) vn2,
                       (DECODE(psexo, 1, vmascul, 2, vfemeni, 0) / p_factor)
                       *(POWER((1 +(pinttec / 100)), -indice)) vecvida,
                       ((DECODE(psexo, 1, vmascul, 2, vfemeni, 0) / p_factor)
                        -(p_factor1 / p_factor))
                       *(POWER((1 +(pinttec / 100)), -(indice +(1 / 2)))) vecmort,
                       (NVL((pipricom +(pirevali * anyo)), 0)) *(1 - ppgasext / 100)
                       *(ppgasint / 100) igaspvi,
                       (NVL((pipricom +(pirevali * anyo)), 0)) *(1 - ppgasext / 100)
                       *(ppgasint / 100)
                       *(DECODE(psexo, 1, vmascul, 2, vfemeni, 0) / p_factor)
                       *(POWER((1 +(pinttec / 100)), -indice)) ippgasvi,
                       pripag ipcmort,
                       pripag
                       *((DECODE(psexo, 1, vmascul, 2, vfemeni, 0) / p_factor)
                         -(p_factor1 / p_factor))
                       *(POWER((1 +(pinttec / 100)), -(indice +(1 / 2)))) ippmort,
                       NVL((pipricom +(pirevali * anyo)), 0) *(1 - ppgasext / 100) ipinviv,
                       NVL((pipricom +(pirevali * anyo)), 0) *(1 - ppgasext / 100)
                       *(DECODE(psexo, 1, vmascul, 2, vfemeni, 0) / p_factor)
                       *(POWER((1 +(pinttec / 100)), -indice)) ippinvi,
                       psproces
                  FROM mortalidad
                 WHERE nedad = edad
                   AND ctabla = pctiptab);
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 107109;
         END;

         indice := indice + 1;
         edad := edad + 1;
      END LOOP;

      RETURN 0;
   END f_matriz_provmat6;

-------------------------------------------------------------------------------------------------
   FUNCTION f_calcul_provmat6(
      pcempres IN NUMBER,
      psseguro IN NUMBER,
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      pcramdgs IN NUMBER,
      pnriesgo IN NUMBER,
      pcgarant IN NUMBER,
      pfefecto IN DATE,
      pfcalcul IN DATE,
      psproces IN NUMBER,
      pnduraci IN NUMBER,
      ppinttec IN NUMBER,
      ppgasext IN NUMBER,
      ppgasint IN NUMBER,
      pctabla IN NUMBER,
      pcprovis IN NUMBER,
      pcmoneda IN NUMBER,
      pcforpag IN NUMBER)
      RETURN NUMBER IS
/************************************************************************************************
    Proceso que nos calcula las provisiones de vida de planes de jubilación
    (MODULO 6)
************************************************************************************************/
      sexo           NUMBER;
      año            NUMBER;
      edad_actual    NUMBER;
      aux_fefeini    DATE;
      ttexto         VARCHAR2(20);
      nlin           NUMBER;
      num_err        NUMBER;
      conta_err      NUMBER := 0;
      xicapini       NUMBER;
      xcrevali       NUMBER;
      xirevali       NUMBER;
      xprevali       NUMBER;
      xipriini       NUMBER;
      xicapgar       NUMBER;
      saldo          NUMBER;
      xipriinv       NUMBER;
      frenova        DATE;
      dias           NUMBER;
      xprovmat_prox  NUMBER;
      provision      NUMBER;
      provision_total NUMBER;
   BEGIN
      -- Calculamos los datos iniciales de la poliza (capital inicial, prima inicial, etc..)
      BEGIN
         SELECT icapital, crevali, irevali, prevali, iprianu
           INTO xicapini, xcrevali, xirevali, xprevali, xipriini
           FROM garanseg
          WHERE sseguro = psseguro
            AND nriesgo = pnriesgo
            AND cgarant = pcgarant
            AND nmovimi = 1;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN 103839;
      END;

      -- Calculamos las primas inventario, y la revalorizacion inventario
      xipriinv := xipriini *(1 - ppgasext / 100);
      -- revalorizacion lineal
      xirevali := xipriini * NVL(xprevali, 0) / 100;

      -- Calculamos el capital garantizado
      BEGIN
         SELECT icapital
           INTO xicapgar
           FROM garanseg
          WHERE sseguro = psseguro
            AND nriesgo = pnriesgo
            AND cgarant = 283
            AND ffinefe IS NULL;
      EXCEPTION
         WHEN OTHERS THEN
            xicapgar := 0;
      END;

      -- Calculamos el número de año actual real --no actuarial
      num_err := f_difdata(pfefecto, pfcalcul, 1, 1, año);

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      frenova := ADD_MONTHS(pfefecto, 12 * año);
      num_err := f_edad_sexo(psseguro, frenova, 2, edad_actual, sexo);

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      -- Calculamos los días desde la fecha de renovación hasta la fecha de calculo
      num_err := f_difdata(frenova, pfcalcul, 1, 3, dias);

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      -- Calculamos la provision del año siguiente
      num_err := f_matriz_provmat6(año + 1, edad_actual + 1, sexo, NVL(pnduraci, 0), psproces,
                                   NVL(ppinttec, 6), NVL(xicapini, 0), xcrevali, xirevali,
                                   xprevali, xipriini, xipriinv, pctabla, NVL(ppgasint, 0),
                                   ppgasext, pcforpag);

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      BEGIN
         SELECT f_round((SUM(DECODE(nanyos, pnduraci, xicapgar, 0))
                         * SUM(DECODE(nanyos, pnduraci, vecvida, 0)))
                        +(SUM(DECODE(pcforpag, 0, 0, DECODE(nanyos, pnduraci, 0, ipgasvi))))
                        +(SUM(DECODE(nanyos, pnduraci, 0, ippmort)))
                        -(SUM(DECODE(pcforpag, 0, 0, DECODE(nanyos, pnduraci, 0, ippinvi)))),
                        pcmoneda)
           INTO xprovmat_prox
           FROM matrizprovmatpj
          WHERE sproces = psproces;
      EXCEPTION
         WHEN OTHERS THEN
            num_err := 107110;
      END;

      -- Borramos la matriz para volver a calcular la provision del año actual
      BEGIN
         DELETE FROM matrizprovmatpj
               WHERE sproces = psproces;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 107110;
      END;

      -- Calculamos la provision del año actual
      num_err := f_matriz_provmat6(año, edad_actual, sexo, NVL(pnduraci, 0), psproces,
                                   NVL(ppinttec, 6), NVL(xicapini, 0), xcrevali, xirevali,
                                   xprevali, xipriini, xipriinv, pctabla, NVL(ppgasint, 0),
                                   ppgasext, pcforpag);

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      -- Calculamos el valor actual, que corresponde con el saldo actual
      num_err := f_saldo(psseguro, pfcalcul, saldo);

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      BEGIN
         SELECT f_round(((SUM(DECODE(nanyos, pnduraci, xicapgar, 0))
                          * SUM(DECODE(nanyos, pnduraci, vecvida, 0)))
                         +(SUM(DECODE(pcforpag, 0, 0, DECODE(nanyos, pnduraci, 0, ipgasvi))))
                         +(SUM(DECODE(nanyos, pnduraci, 0, ippmort)))
                         -(SUM(DECODE(pcforpag, 0, 0, DECODE(nanyos, pnduraci, 0, ippinvi)))))
                        +(dias / 365.25
                          *(xprovmat_prox
                            -((SUM(DECODE(nanyos, pnduraci, xicapgar, 0))
                               * SUM(DECODE(nanyos, pnduraci, vecvida, 0)))
                              +(SUM(DECODE(pcforpag,
                                           0, 0,
                                           DECODE(nanyos, pnduraci, 0, ipgasvi))))
                              +(SUM(DECODE(nanyos, pnduraci, 0, ippmort)))
                              -(SUM(DECODE(pcforpag,
                                           0, 0,
                                           DECODE(nanyos, pnduraci, 0, ippinvi)))))))
                        +((1 - dias / 365.25)
                          * SUM(DECODE(pcforpag, 0, 0, DECODE(nanyos, año, ipinviv, 0)))),
                        pcmoneda)
           INTO provision
           FROM matrizprovmatpj
          WHERE sproces = psproces;
      EXCEPTION
         WHEN OTHERS THEN
            provision_total := 0;
      END;

      IF pcforpag = 0 THEN   -- SI ES PRIMA ÚNCA LA PROVISIÓN SERÁ EL SALDO
         provision_total := saldo;
      ELSE
         IF saldo > provision THEN
            provision_total := saldo;
         ELSE
            provision_total := provision;
         END IF;
      END IF;

      BEGIN
         INSERT INTO provmat
                     (cempres, fcalcul, sproces, cramdgs, cramo, cmodali,
                      ctipseg, ccolect, sseguro, nriesgo, cgarant, cprovis, ipriini,
                      ivalact, icapgar, ipromat, cerror)
              VALUES (pcempres, pfcalcul, psproces, NVL(pcramdgs, 0), pcramo, pcmodali,
                      pctipseg, pccolect, psseguro, pnriesgo, pcgarant, pcprovis, xipriini,
                      NVL(saldo, 0), xicapgar, provision_total, 0);
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 107110;
      END;

      IF num_err = 0 THEN
         DELETE FROM matrizprovmatpj
               WHERE sproces = psproces;

         COMMIT;
      ELSE
         RETURN num_err;
      END IF;

      RETURN 0;
   END f_calcul_provmat6;

-----------------------------------------------------------------------------------------------
   FUNCTION f_calcul_provmat7(
      pcempres IN NUMBER,
      psseguro IN NUMBER,
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      pcramdgs IN NUMBER,
      pnriesgo IN NUMBER,
      pcgarant IN NUMBER,
      pprimini IN NUMBER,
      pfcalcul IN DATE,
      psproces IN NUMBER,
      pcmoneda IN NUMBER)
      RETURN NUMBER IS
/************************************************************************************************
    Proceso que nos calcula las provisiones de vida ahorro saldo cuenta
    (MODULO 3)
************************************************************************************************/
      ttexto         VARCHAR2(20);
      nlin           NUMBER;
      num_err        NUMBER;
      conta_err      NUMBER := 0;
      xsaldo         NUMBER;
      xicapgar       NUMBER;
      duracion       NUMBER;
   BEGIN
      -- Calculamos los datos de la poliza (capital garantizado actual, etc...)
      BEGIN
         SELECT icapital
           INTO xicapgar
           FROM garanseg
          WHERE sseguro = psseguro
            AND nriesgo = pnriesgo
            AND cgarant = 287
            AND(ffinefe > pfcalcul
                OR ffinefe IS NULL)
            AND nmovimi = (SELECT MIN(nmovimi)
                             FROM garanseg
                            WHERE sseguro = psseguro
                              AND nriesgo = pnriesgo
                              AND cgarant = 287
                              AND(ffinefe > pfcalcul
                                  OR ffinefe IS NULL));
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            xicapgar := 0;
      END;

      num_err := f_saldo(psseguro, pfcalcul, xsaldo);

      IF num_err <> 0 THEN
         RETURN num_err;
      ELSE
         BEGIN
            INSERT INTO provmat
                        (cempres, fcalcul, sproces, cramdgs, cramo, cmodali, ctipseg,
                         ccolect, sseguro, nriesgo, cgarant, cprovis, ipriini, ivalact,
                         icapgar, ipromat, cerror)
                 VALUES (pcempres, pfcalcul, psproces, pcramdgs, pcramo, pcmodali, pctipseg,
                         pccolect, psseguro, pnriesgo, pcgarant, 7, pprimini, NVL(xsaldo, 0),
                         NVL(xicapgar, 0), NVL(xsaldo, 0), 0);
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 107110;
         END;

         COMMIT;
      END IF;

      RETURN 0;
   END f_calcul_provmat7;

------------------------------------------------------------------------------------------------
   FUNCTION f_commit_provmat(
      cempres IN NUMBER,
      aux_factual IN DATE,
      psproces IN NUMBER,
      pcidioma IN NUMBER,
      pcmoneda IN NUMBER)
      RETURN NUMBER IS
/**********************************************************************************************
    Proceso general para el cálculo de las provisiones matemáticas. Dependiendo del tipo
    de provision llamaremos a una función de cálculo o a otra
**********************************************************************************************/
      contador       NUMBER;
      actividad      NUMBER;
      num_err        NUMBER;
      ttexto         VARCHAR2(400);
      nlin           NUMBER;
      conta_err      NUMBER;
      xiprini        NUMBER;
      xcgarant       NUMBER;
      duracion       NUMBER;
   BEGIN
      -- Abrimos el cursor general de las pólizas
      FOR reg IN c_polizas_provmat(aux_factual, cempres) LOOP
         num_err := 0;

         -- Si nduraci del seguro no está informado, calculamos nosotros la duración
         IF reg.nduraci IS NULL THEN
            num_err := f_difdata(reg.fefecto, reg.fvencim, 1, 1, duracion);
         END IF;

         -- Miramos si calcula la provisión tipo 7 o no
         -- Bug 9699 - APD - 27/04/2009 - primero se ha de buscar para la actividad en concreto
         -- y si no se encuentra nada ir a buscar a GARANPRO para la actividad cero
         BEGIN
            SELECT SUM(icapital), MIN(g.cgarant)
              INTO xiprini, xcgarant
              FROM garanpro gp, garanseg g
             WHERE g.sseguro = reg.sseguro
               AND cprovis = 7
               AND g.cgarant = gp.cgarant
               AND gp.cramo = reg.cramo
               AND gp.cmodali = reg.cmodali
               AND gp.ctipseg = reg.ctipseg
               AND gp.ccolect = reg.ccolect
               AND gp.cactivi = pac_seguros.ff_get_actividad(g.sseguro, g.nriesgo)
               AND g.nmovimi = 1;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               BEGIN
                  SELECT SUM(icapital), MIN(g.cgarant)
                    INTO xiprini, xcgarant
                    FROM garanpro gp, garanseg g
                   WHERE g.sseguro = reg.sseguro
                     AND cprovis = 7
                     AND g.cgarant = gp.cgarant
                     AND gp.cramo = reg.cramo
                     AND gp.cmodali = reg.cmodali
                     AND gp.ctipseg = reg.ctipseg
                     AND gp.ccolect = reg.ccolect
                     AND gp.cactivi = 0
                     AND g.nmovimi = 1;
               EXCEPTION
                  WHEN OTHERS THEN
                     num_err := 103503;
               END;
         END;

         -- Bug 9699 - APD - 27/04/2009 - Fin
         IF num_err = 0 THEN
            IF NVL(xiprini, 0) = 0 THEN
               FOR reggar IN c_garantias_provmat(reg.sseguro, reg.cramo, reg.cmodali,
                                                 reg.ctipseg, reg.ccolect, aux_factual) LOOP
                  IF reggar.cprovis = 2 THEN   -- Modulo 1 (vida ahorro diferido prima regular)
                     num_err := f_calcul_provmat2(reg.cempres, reg.sseguro, reg.cramo,
                                                  reg.cmodali, reg.ctipseg, reg.ccolect,
                                                  reg.cramdgs, reggar.nriesgo, reggar.cgarant,
                                                  reg.fefecto, aux_factual, psproces,
                                                  NVL(reg.nduraci, duracion), reg.pinttec,
                                                  reg.pgasext, reg.pgasint, reggar.ctabla,
                                                  reggar.cprovis, pcmoneda);
                  ELSIF reggar.cprovis = 3 THEN   -- Módulo 2 (vida ahorro diferido prima única)
                     num_err := f_calcul_provmat3(reg.cempres, reg.sseguro, reg.cramo,
                                                  reg.cmodali, reg.ctipseg, reg.ccolect,
                                                  reg.cramdgs, reggar.nriesgo, reggar.cgarant,
                                                  reg.fefecto, aux_factual, psproces,
                                                  NVL(reg.nduraci, duracion), reg.pinttec,
                                                  reg.pgasext, reg.pgasint, reggar.ctabla,
                                                  reggar.cprovis, pcmoneda);
                  ELSIF reggar.cprovis = 4 THEN   -- Módulo 3 (mixto revalorizable prima periódica)
                     num_err := f_calcul_provmat4(reg.cempres, reg.sseguro, reg.cramo,
                                                  reg.cmodali, reg.ctipseg, reg.ccolect,
                                                  reg.cramdgs, reggar.nriesgo, reggar.cgarant,
                                                  reg.fefecto, aux_factual, psproces,
                                                  NVL(reg.nduraci, duracion), reg.pinttec,
                                                  reg.pgasext, reg.pgasint, reggar.ctabla,
                                                  reggar.cprovis, pcmoneda);
                  ELSIF(reggar.cprovis = 5
                        AND reggar.cgarant = 8019) THEN   -- Módulo 5 (PF20)
                     num_err := f_calcul_provmat5(reg.cempres, reg.sseguro, reg.cramo,
                                                  reg.cmodali, reg.ctipseg, reg.ccolect,
                                                  reg.cramdgs, reggar.nriesgo, reggar.cgarant,
                                                  reg.fefecto, aux_factual, psproces,
                                                  NVL(reg.nduraci, duracion), reg.pinttec,
                                                  reg.pgasext, reg.pgasint, reggar.ctabla,
                                                  reggar.cprovis, pcmoneda, reg.cforpag);
                  ELSIF(reggar.cprovis = 6
                        AND reggar.cgarant != 283) THEN   -- Módulo 6 (planes de jubilación)
                     num_err := f_calcul_provmat6(reg.cempres, reg.sseguro, reg.cramo,
                                                  reg.cmodali, reg.ctipseg, reg.ccolect,
                                                  reg.cramdgs, reggar.nriesgo, reggar.cgarant,
                                                  reg.fefecto, aux_factual, psproces,
                                                  NVL(reg.nduraci, duracion), reg.pinttec,
                                                  reg.pgasext, reg.pgasint, reggar.ctabla,
                                                  reggar.cprovis, pcmoneda, reg.cforpag);
                  END IF;

                  -- BUG 18423 - 02/11/2011 - JMP - LCOL000 - Multimoneda
                  IF num_err = 0 THEN
                     IF NVL(pac_parametros.f_parempresa_n(reg.cempres, 'MULTIMONEDA'), 0) = 1 THEN
                        num_err := pac_oper_monedas.f_contravalores_provmat(psproces,
                                                                            reg.sseguro,
                                                                            reggar.nriesgo,
                                                                            reggar.cgarant,
                                                                            aux_factual);
                     END IF;
                  END IF;

                  -- FIN BUG 18423 - 02/11/2011 - JMP - LCOL000 - Multimoneda
                  IF num_err <> 0 THEN
                     ROLLBACK;
                     ttexto := f_axis_literales(num_err, pcidioma);
                     num_err := f_proceslin(psproces, ttexto, reg.sseguro, nlin);
                     COMMIT;
                     conta_err := conta_err + 1;
                     nlin := NULL;
                  ELSE
                     COMMIT;
                  END IF;
               END LOOP;
            ELSE
               num_err := f_calcul_provmat7(reg.cempres, reg.sseguro, reg.cramo, reg.cmodali,
                                            reg.ctipseg, reg.ccolect, reg.cramdgs, 1,
                                            xcgarant, xiprini, aux_factual, psproces,
                                            pcmoneda);

               -- BUG 18423 - 02/11/2011 - JMP - LCOL000 - Multimoneda
               IF num_err = 0 THEN
                  IF NVL(pac_parametros.f_parempresa_n(reg.cempres, 'MULTIMONEDA'), 0) = 1 THEN
                     num_err := pac_oper_monedas.f_contravalores_provmat(psproces,
                                                                         reg.sseguro, 1,
                                                                         xcgarant,
                                                                         aux_factual);
                  END IF;
               END IF;
            -- FIN BUG 18423 - 02/11/2011 - JMP - LCOL000 - Multimoneda
            END IF;
         END IF;

         IF num_err <> 0 THEN
            ROLLBACK;
            ttexto := f_axis_literales(num_err, pcidioma);
            num_err := f_proceslin(psproces, ttexto, reg.sseguro, nlin);
            COMMIT;
            conta_err := conta_err + 1;
            nlin := NULL;
         ELSE
            COMMIT;
         END IF;
      END LOOP;

      RETURN 0;
   END f_commit_provmat;
END;

/

  GRANT EXECUTE ON "AXIS"."PAC_PROVIMAT" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_PROVIMAT" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_PROVIMAT" TO "PROGRAMADORESCSI";
