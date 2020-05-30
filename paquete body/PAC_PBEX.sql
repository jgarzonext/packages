--------------------------------------------------------
--  DDL for Package Body PAC_PBEX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_PBEX" IS
/****************************************************************************

   NOMBRE:       PAC_CTASEGURO
   PROPÓSITO:  Funciones para cuenta seguro

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ----------------------------------
   1.0           -          -               Creació del package
   2.0        20/04/2009   APD              Bug 9685 - en lugar de coger la acticad de la tabla seguros, llamar a la función pac_seguros.ff_get_actividad
****************************************************************************/
   CURSOR c_polizas_provmat(fecha DATE, empresa NUMBER) IS
      -- Bug 9685 - APD - 20/04/2009 - en lugar de coger la acticad de la tabla seguros, llamar a la función pac_seguros.ff_get_actividad
      SELECT c.cempres, s.cramo, s.cmodali, s.ctipseg, s.ccolect, s.sseguro,
             NVL(s.fcaranu, s.fvencim) ffinal, s.fefecto, s.npoliza, s.ncertif, p.cramdgs,
             s.nduraci, p.pinttec, p.pgasext, p.pgasint,
             pac_seguros.ff_get_actividad(s.sseguro, g.nriesgo) cactivi, s.cforpag, s.fvencim,
             g.nriesgo, g.cgarant, g.icapital, g.iprianu, gp.ctabla, gp.cprovis
        FROM productos p, seguros s, codiram c, garanpro gp, garanseg g
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
         AND p.ccolect = s.ccolect
         AND g.sseguro = s.sseguro
         AND gp.cramo = p.cramo
         AND gp.cmodali = p.cmodali
         AND gp.ctipseg = p.ctipseg
         AND gp.ccolect = p.ccolect
         --AND gp.cactivi = s.cactivi
         AND gp.cactivi = pac_seguros.ff_get_actividad(s.sseguro, g.nriesgo)
         AND g.cgarant = gp.cgarant
         AND(g.ffinefe > fecha
             OR g.ffinefe IS NULL)
         AND gp.cprovis = 11
         AND g.cgarant = 389;

        -- Bug 9685 - APD - 20/04/2009 - Fin
   -- Seleccionamos las garantías vigentes de la póliza que calculan provisiones matemáticas
-----------------------------------------------------------------------
   FUNCTION f_matriz_provmat11(
      panyo IN NUMBER,
      pedad IN NUMBER,
      psexo IN NUMBER,
      nduraci IN NUMBER,
      psproces IN NUMBER,
      pinttec IN NUMBER,
      picapini IN NUMBER,
      pcrevali IN NUMBER,
      pprevali IN NUMBER,
      pctiptab IN NUMBER,
      ppgasint IN NUMBER,
      picapgar IN NUMBER,
      pcmoneda IN NUMBER)
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
      prima_unica    NUMBER := 0;

      CURSOR c_matrizprov IS
         SELECT   *
             FROM matrizprovmatpj
            WHERE sproces = psproces
         ORDER BY cindice;
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
                       DECODE(pcrevali,
                              1,(picapini *(1 +((pprevali / 100) * anyo))),
                              2,(picapini *(POWER((1 +(pprevali / 100)), anyo))),
                              0)
                       *(ppgasint / 100) igaspvi,
                       DECODE(pcrevali,
                              1,(picapini *(1 +((pprevali / 100) * anyo))),
                              2,(picapini *(POWER((1 +(pprevali / 100)), anyo))),
                              0)
                       *(ppgasint / 100) *(DECODE(psexo, 1, vmascul, 2, vfemeni, 0) / p_factor)
                       *(POWER((1 +(pinttec / 100)), -indice)) ippgasvi,
                       0 ipcmort, 0 ippmort, 0 ipinviv, 0 ippinvi, psproces
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

      -- Calculamos la prima única
      BEGIN
         SELECT f_round(((SUM(DECODE(nanyos, nduraci,(picapgar * vecvida), 0)))
                         +(SUM(DECODE(nanyos, nduraci, 0, ipgasvi))))
                        /(1 - SUM(vecmort)),
                        pcmoneda)
           INTO prima_unica
           FROM matrizprovmatpj
          WHERE sproces = psproces;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 107109;
      END;

      FOR reg IN c_matrizprov LOOP
         BEGIN
            UPDATE matrizprovmatpj
               SET ipcmort = prima_unica,
                   ippmort = prima_unica * reg.vecmort
             WHERE sproces = psproces
               AND cindice = reg.cindice;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 107109;
         END;
      END LOOP;

      RETURN 0;
   END f_matriz_provmat11;

------------------------------------------------------------------------------------------------
   FUNCTION f_calcul_pbex(
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
      pcforpag IN NUMBER,
      picapital IN NUMBER)
      RETURN NUMBER IS
/************************************************************************************************
    Proceso que nos calcula las provisiones de participación en beneficions
    (MODULO 11)
************************************************************************************************/
      edad           NUMBER;
      sexo           NUMBER;
      anyo           NUMBER;
      edad_actual    NUMBER;
      aux_fefeini    DATE;
      ttexto         VARCHAR2(20);
      nlin           NUMBER;
      num_err        NUMBER;
      conta_err      NUMBER := 0;
      saldo          NUMBER;
      capini_act     NUMBER;
      xcrevali       NUMBER;
      xprevali       NUMBER;
      frenova        DATE;
      dias           NUMBER;
      xpbex_prox     NUMBER;
   BEGIN
      -- Averiguamos el tipo de revalorización de la garantía principal
      BEGIN
         SELECT crevali, prevali
           INTO xcrevali, xprevali
           FROM garanseg
          WHERE sseguro = psseguro
            AND nmovimi = 1
            AND norden = (SELECT MIN(norden)
                            FROM garanseg
                           WHERE sseguro = psseguro
                             AND nmovimi = 1);
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 107109;
      END;

      -- Calculamos el capital actualizado
      IF xcrevali = 1 THEN
         capini_act := NVL(picapital, 0) /(1 +((NVL(xprevali, 0) / 100) * pnduraci));
      ELSIF xcrevali = 2 THEN
         capini_act := NVL(picapital, 0) / POWER((1 +(NVL(xprevali, 0) / 100)), pnduraci);
      END IF;

      -- Calculamos la edad ACTUARIAL del asegurado en la fecha de efecto de la póliza
      num_err := f_edad_sexo(psseguro, pfefecto, 2, edad, sexo);

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      -- Calculamos el número de anyo actual real no actuarial
      num_err := f_difdata(pfefecto, pfcalcul, 1, 1, anyo);

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      -- Calculamos la eda actual actuarial;
      --edad_actual := edad + anyo;
      frenova := ADD_MONTHS(pfefecto, 12 * anyo);
      num_err := f_edad_sexo(psseguro, frenova, 2, edad_actual, sexo);

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      -- Calculamos los días desde la fecha de renovación hasta la fecha de calculo
      num_err := f_difdata(frenova, pfcalcul, 1, 3, dias);

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      -- Calculamos la provision del anyo siguiente
      num_err := f_matriz_provmat11(anyo + 1, edad_actual + 1, sexo, NVL(pnduraci, 0),
                                    psproces, NVL(ppinttec, 6), NVL(capini_act, 0), xcrevali,
                                    xprevali, pctabla, NVL(ppgasint, 0), NVL(picapital, 0),
                                    pcmoneda);

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      BEGIN
         SELECT f_round((SUM(DECODE(nanyos, pnduraci, picapital, 0))
                         * SUM(DECODE(nanyos, pnduraci, vecvida, 0)))
                        +(SUM(DECODE(pcforpag, 0, 0, DECODE(nanyos, pnduraci, 0, ipgasvi))))
                        +(SUM(DECODE(nanyos, pnduraci, 0, ippmort))),
                        pcmoneda)
           INTO xpbex_prox
           FROM matrizprovmatpj
          WHERE sproces = psproces;
      EXCEPTION
         WHEN OTHERS THEN
            num_err := 107110;
      END;

      -- Borramos la matriz para volver a calcular la provision del anyo actual
      BEGIN
         DELETE FROM matrizprovmatpj
               WHERE sproces = psproces;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 107110;
      END;

      -- Calculamos la provision del anyo actual
      num_err := f_matriz_provmat11(anyo, edad_actual, sexo, NVL(pnduraci, 0), psproces,
                                    NVL(ppinttec, 6), NVL(capini_act, 0), xcrevali, xprevali,
                                    pctabla, NVL(ppgasint, 0), NVL(picapital, 0), pcmoneda);

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      BEGIN
         INSERT INTO pbex
                     (cempres, fcalcul, sproces, cramdgs, cramo, cmodali, ctipseg, ccolect,
                      sseguro, nriesgo, cgarant, ivalact, icapgar, ipromat, cerror)
            (SELECT pcempres, pfcalcul, psproces, NVL(pcramdgs, 0), pcramo, pcmodali,
                    pctipseg, pccolect, psseguro, pnriesgo, pcgarant,
                    f_round(DECODE(xcrevali,
                                   1,(capini_act *(1 +((xprevali / 100) * anyo))),
                                   2,(capini_act *(POWER((1 +(xprevali / 100)), anyo))),
                                   0),
                            pcmoneda),
                    picapital,
                    f_round(((SUM(DECODE(nanyos, pnduraci, picapital, 0))
                              * SUM(DECODE(nanyos, pnduraci, vecvida, 0)))
                             +(SUM(DECODE(pcforpag,
                                          0, 0,
                                          DECODE(nanyos, pnduraci, 0, ipgasvi))))
                             +(SUM(DECODE(nanyos, pnduraci, 0, ippmort))))
                            +(dias / 365.25
                              *(xpbex_prox
                                -((SUM(DECODE(nanyos, pnduraci, picapital, 0))
                                   * SUM(DECODE(nanyos, pnduraci, vecvida, 0)))
                                  +(SUM(DECODE(pcforpag,
                                               0, 0,
                                               DECODE(nanyos, pnduraci, 0, ipgasvi))))
                                  +(SUM(DECODE(nanyos, pnduraci, 0, ippmort)))))),
                            pcmoneda),
                    0
               FROM matrizprovmatpj
              WHERE sproces = psproces);
      EXCEPTION
         WHEN OTHERS THEN
            num_err := 107110;
      END;

      IF num_err = 0 THEN
         DELETE FROM matrizprovmatpj
               WHERE sproces = psproces;

         COMMIT;
      ELSE
         RETURN num_err;
      END IF;

      RETURN 0;
   END f_calcul_pbex;

------------------------------------------------------------------------------------------------
   FUNCTION f_commit_pbex(
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

         num_err := f_calcul_pbex(reg.cempres, reg.sseguro, reg.cramo, reg.cmodali,
                                  reg.ctipseg, reg.ccolect, reg.cramdgs, reg.nriesgo,
                                  reg.cgarant, reg.fefecto, aux_factual, psproces,
                                  NVL(reg.nduraci, duracion), reg.pinttec, reg.pgasext,
                                  reg.pgasint, reg.ctabla, reg.cprovis, pcmoneda, reg.cforpag,
                                  reg.icapital);

         IF num_err <> 0 THEN
            ROLLBACK;
            ttexto := f_axis_literales(num_err, pcidioma);
            num_err := f_proceslin(psproces, ttexto || ' - PTPBEX', reg.sseguro, nlin);
            COMMIT;
            conta_err := conta_err + 1;
            nlin := NULL;
         ELSE
            COMMIT;
         END IF;
      END LOOP;

      RETURN 0;
   END f_commit_pbex;

   PROCEDURE proceso_batch_cierre(
      pmodo IN NUMBER,
      pcempres IN NUMBER,
      pmoneda IN NUMBER,
      pcidioma IN NUMBER,
      pfperini IN DATE,
      pfperfin IN DATE,
      pfcierre IN DATE,
      pcerror OUT NUMBER,
      psproces OUT NUMBER,
      pfproces OUT DATE) IS
      -- 16/9/04 CPM:
      --
      --    Proceso que lanzará el proceso de cierre de ahorro de forma batch
      --
      --   Esta llamada tiene parámetros que no son necesarios por ser requeridos
      --     para que sea compatible con el resto de cierres programados.
      --
      vnum_err       NUMBER := 0;
      vindice        NUMBER;
      v_modo         VARCHAR2(1);
      vtitulo        VARCHAR2(100);

      FUNCTION f_provision_vigente(pcprovis IN NUMBER, pfcierre IN DATE, pcempres IN NUMBER)
         RETURN NUMBER IS
         v_vigente      NUMBER;
      BEGIN
         SELECT COUNT(*)
           INTO v_vigente
           FROM codprovi_emp
          WHERE cprovis = pcprovis
            AND cempres = pcempres
            AND(fbaja IS NULL
                OR fbaja > pfcierre);

         RETURN v_vigente;
      END f_provision_vigente;
   BEGIN
      --p_control_error('rcl', '0 PAC_PBEX.proceso_batch_cierre', '-- STARTS --');
      IF pmodo = 2 THEN
         v_modo := 'R';
      ELSE
         v_modo := 'P';
      END IF;

      IF f_provision_vigente(11, pfcierre, pcempres) = 1 THEN   -- sólo se calculan las provisiones que están pendientes
         IF v_modo = 'P' THEN   -- previo del cierre
            DELETE FROM pbex_previo p
                  WHERE p.fcalcul = pfperfin
                    AND p.cempres = pcempres;

            COMMIT;
            vtitulo := 'Previo cierre Provisión PU';
         ELSE
            DELETE FROM pbex p
                  WHERE p.fcalcul = pfperfin
                    AND p.cempres = pcempres;

            COMMIT;
            vtitulo := 'Cierre Provisión PU';
         END IF;

         vnum_err := f_procesini(f_user, pcempres, 'CIERRE_PB', vtitulo, psproces);

         IF vnum_err <> 0 THEN
            vnum_err := 109388;
            pcerror := vnum_err;
         END IF;

         vnum_err := pac_provimat_pbex.f_commit_pbex(pcempres, pfcierre, psproces, pcidioma,
                                                     pmoneda, v_modo);

         INSERT INTO ctrl_provis
                     (cempres, fcalcul, fmodifi, cprovis, sproces, cusuari, cerror)
              VALUES (pcempres, pfperfin, f_sysdate, 11, psproces, f_user, pcerror);

         COMMIT;
         vnum_err := f_procesfin(psproces, vnum_err);
         pfproces := f_sysdate;

         -- p_control_error('rcl', '1 PAC_PROVIMAT_PBEX.proceso_batch_cierre', '-- RESULT --' || vnum_err);
         IF vnum_err = 0 THEN
            pcerror := 0;
            COMMIT;
         ELSE
            pcerror := vnum_err;
            ROLLBACK;
         END IF;
      --pfproces := f_sysdate;
      END IF;
   END proceso_batch_cierre;
END;

/

  GRANT EXECUTE ON "AXIS"."PAC_PBEX" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_PBEX" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_PBEX" TO "PROGRAMADORESCSI";
