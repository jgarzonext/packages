--------------------------------------------------------
--  DDL for Function F_REVALGAR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_REVALGAR" (
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
   pfactor OUT NUMBER,
   pnriesgo IN NUMBER DEFAULT 1)
   RETURN NUMBER AUTHID CURRENT_USER IS
/***********************************************************************
   F_REVALGAR : Retorna el capital revalorizado.
   ALLIBCTR - Gestión de datos referentes a los seguros
   Modificació: Se añade otro caso de revalorización y se
                distingue si la tarifa es manual. Si es así se revaloriza
                también la prima.
   Modificació: Se añade el caso de revalorización de prima y de capital
   Modificació: Se añade el caso pcmanual=3
   Modificació: Se añade el tipo crevali = 5. Será revalorización según
                el IPC anual (no el mensual)
   Modificació: Se añade el caso pcmanual = 4.(automático. Revaloriza prima)
   Modificació: Se controla que retorne el mismo capital que entra en los casos
                que el pcmanual sea 1 ó 4, hasta ahora retornaba NULL.
    -- Bug 9524: APR - Renovación de cartera: se añaden los tipos crevali 8 y 9
        que implican revalorización de prima y crevali = 7 (adaptación fiscal)
        Se tiene en cuenta el máximo de prima en el caso de crevali 8 y 9
        Se añade el parámetro pnriesgo para poder pasarlo a la función f_adaptacion_fiscal
***********************************************************************/
   ppicapital     NUMBER(13, 2);   --   GARANSEG.ICAPITAL%TYPE;
   ppipc          NUMBER;
   ppipc_ant      NUMBER;
   ppsalida       NUMBER;
   procrevali     NUMBER;
   proprevali     NUMBER;
   proirevali     NUMBER;
   num_err        NUMBER;
   v_modo         NUMBER;
   --JRH 27/10/2013 Corrección
   vfechacart     DATE;
   v_importesalant NUMBER;

   --JRH FIN

   -- Bug 9794 - YIL - 21/04/2009 - Se da de alta una nueva función f_adaptacion_fiscal para controlar la prima máxima
--                               según la fiscalidad establecida (LIMITES_AHORRO)
   FUNCTION f_adaptacion_fiscal(
      psseguro IN NUMBER,
      pcgarant IN NUMBER,
      pmes IN NUMBER,
      pany IN NUMBER,
      pprimarev OUT NUMBER)
      RETURN NUMBER IS
/***********************************************************************
    F_adaptacion fiscal: calcula la nueva prima según el límite fiscal
       -- de prima establecido

    revisar los returns
    poner p_tab_error

***********************************************************************/
      v_sproduc      productos.sproduc%TYPE;
      v_limite       limites_ahorro.iaportanual%TYPE;
      v_tot_prima    garanseg.iprianu%TYPE;
      v_factor       NUMBER;
      v_fecha        DATE;
      num_err        NUMBER;
      importe        NUMBER;
      imp_restar     NUMBER;
      v_param        VARCHAR2(1000)
         := 'sseguro =' || psseguro || ' pcgarant =' || pcgarant || ' pmes =' || pmes
            || ' pany =' || pany;
      v_traza        NUMBER;
      -- Bug 10759 - RSC - 21/07/2009 - APR - Revalorización tipo Adaptación Fiscal 'proporcional'
      v_prima        garanseg.iprianu%TYPE;
      v_maximo_fiscal pregunseg.crespue%TYPE;
      v_fecha2       DATE;
      v_limite2      limites_ahorro.iaportanual%TYPE;
      imp_restar1    NUMBER;
      imp_restar2    NUMBER;
      importe1       NUMBER;
      importe2       NUMBER;
   -- Fin Bug 10759
   BEGIN
      v_traza := 1;

      BEGIN
         SELECT sproduc
           INTO v_sproduc
           FROM seguros
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, 'F_REVALGAR.F_ADAPTACION_FISCAL', v_traza, v_param,
                        SQLERRM);
            RETURN 101919;   -- ERROR AL LEER DATOS DE LA TABLA SEGUROS
      END;

      -- Primero debemos mirar el límite de prima establecido para ese año
      v_fecha := TRUNC(TO_DATE(LPAD(pmes, 2, '0') || pany, 'MMYYYY'));
      v_traza := 2;
      v_limite :=
         pac_limites_ahorro.ff_iaportanual
            (NVL
                (pac_parametros.f_parproducto_n(v_sproduc, 'TIPO_LIMITE_PRIMA'),   /*-- BUG 10231 - 27/05/2009 - ETM -Límite de aportaciones en productos fiscales--TIPO_LIMITE */
                 0),
             v_fecha);
      -- Bug 10759 - RSC - 21/07/2009 - APR - Revalorización tipo Adaptación Fiscal 'proporcional'
      v_fecha2 := TRUNC(TO_DATE(LPAD(pmes, 2, '0') ||(pany - 1), 'MMYYYY'));
      v_traza := 22;
      v_limite2 :=
         pac_limites_ahorro.ff_iaportanual
            (NVL
                (pac_parametros.f_parproducto_n(v_sproduc, 'TIPO_LIMITE_PRIMA'),   /*-- BUG 10231 - 27/05/2009 - ETM -Límite de aportaciones en productos fiscales--TIPO_LIMITE */
                 0),
             v_fecha2);

      -- Fin Bug 10759

      -- Bug 10759 - RSC - 21/07/2009 - APR - Revalorización tipo Adaptación Fiscal 'proporcional'
      BEGIN
         SELECT crespue
           INTO v_maximo_fiscal
           FROM pregunseg
          WHERE sseguro = psseguro
            AND nriesgo = pnriesgo
            AND cpregun = 9002   -- Pregunta fija
            AND nmovimi = (SELECT MAX(nmovimi)
                             FROM pregunseg p2
                            WHERE p2.sseguro = pregunseg.sseguro
                              AND p2.nriesgo = pregunseg.nriesgo
                              AND p2.cpregun = pregunseg.cpregun);
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            v_maximo_fiscal := 1;   -- Por defecto máximo fiscal
      END;

      IF v_maximo_fiscal = 1 THEN
         -- Fin Bug 10759
         IF v_limite IS NOT NULL THEN   -- hay límite de aportacion
            v_traza := 3;
            -- El límite establecido es con impuestos, tasas y forfait. Hay que descontarlo
            -- Se hace en el pac_porpio para que cada instalación reste sus impuestos, tasas, etc...
            num_err := pac_propio.f_restar_limite_anual(NULL, psseguro, pcgarant, v_limite,
                                                        v_fecha, imp_restar);

            IF num_err <> 0 THEN
               RETURN num_err;
            ELSE
               importe := v_limite - NVL(imp_restar, 0);
               -- Segundo: averiguar el peso de la prima de nuestra garantía sobre el total de prima de las garantías que
               -- aplican límite
               v_traza := 4;

               BEGIN
                  SELECT SUM(g.iprianu)
                    INTO v_tot_prima
                    FROM garanseg g, garanpro gp, seguros s
                   WHERE g.sseguro = s.sseguro
                     AND s.sseguro = psseguro
                     AND s.sproduc = gp.sproduc
                     AND g.cgarant = gp.cgarant
                     AND s.cactivi = gp.cactivi
                     AND g.ffinefe IS NULL
                     AND g.nriesgo = pnriesgo
                     AND gp.cbasica = 1;

                  SELECT iprianu / v_tot_prima
                    INTO v_factor
                    FROM garanseg
                   WHERE sseguro = psseguro
                     AND cgarant = pcgarant
                     AND nriesgo = pnriesgo
                     AND ffinefe IS NULL;
               EXCEPTION
                  WHEN OTHERS THEN
                     p_tab_error(f_sysdate, f_user, 'F_REVALGAR.F_ADAPTACION_FISCAL', v_traza,
                                 v_param, SQLERRM);
                     RETURN 140999;   -- Error no controlado
               END;

               -- La nueva prima se calcula aplicando el factor al nuevo límite anual
               pprimarev := f_round(importe * v_factor
                                                      -- BUG 18423 - I - 27/12/2011 - JLB - LCOL000 - Multimoneda
                                    ,
                                    pac_monedas.f_moneda_producto(v_sproduc)
                                                                            -- BUG 18423 - F - 27/12/2011 - JLB - LCOL000 - Multimoneda
                           );
            END IF;
         ELSE
            pprimarev := NULL;   -- no hay prima límite
         END IF;

         -- Bug 10350 - RSC - 06/08/2009 - Detalle de garantía (Tarificación)
         pfactor := v_limite / v_limite2;

         IF pfactor <= 1 THEN
            pfactor := 0;
         END IF;
      -- Fin Bug 10350
      ELSE
         IF v_limite2 IS NOT NULL
            AND v_limite IS NOT NULL THEN
            -- El límite establecido es con impuestos, tasas y forfait. Hay que descontarlo
            -- Se hace en el pac_porpio para que cada instalación reste sus impuestos, tasas, etc...
            num_err := pac_propio.f_restar_limite_anual(NULL, psseguro, pcgarant, v_limite,
                                                        v_fecha, imp_restar1);

            IF num_err <> 0 THEN
               RETURN num_err;
            ELSE
               importe1 := v_limite - NVL(imp_restar1, 0);
               -- El límite establecido es con impuestos, tasas y forfait. Hay que descontarlo
                -- Se hace en el pac_porpio para que cada instalación reste sus impuestos, tasas, etc...
               num_err := pac_propio.f_restar_limite_anual(NULL, psseguro, pcgarant,
                                                           v_limite2, v_fecha2, imp_restar2);

               IF num_err <> 0 THEN
                  RETURN num_err;
               END IF;

               importe2 := v_limite2 - NVL(imp_restar2, 0);
            END IF;

            v_factor := 1 /(importe2 / importe1);

            SELECT iprianu
              INTO v_prima
              FROM garanseg
             WHERE sseguro = psseguro
               AND cgarant = pcgarant
               AND nriesgo = pnriesgo
               AND ffinefe IS NULL;

            -- La nueva prima se calcula aplicando el factor de
            -- crecimiento proporcional a la prima
            pprimarev := f_round(v_prima * v_factor
                                                   -- BUG 18423 - I - 27/12/2011 - JLB - LCOL000 - Multimoneda
                                 , pac_monedas.f_moneda_producto(v_sproduc)
                                                                           -- BUG 18423 - F - 27/12/2011 - JLB - LCOL000 - Multimoneda
                        );
         ELSE
            pprimarev := NULL;
         END IF;

         -- Bug 10350 - RSC - 06/08/2009 - Detalle de garantía (Tarificación)
         pfactor := 1 /(importe2 / importe1);

         IF pfactor <= 1 THEN
            pfactor := 0;
         END IF;
      -- Fin Bug 10350
      END IF;

      RETURN 0;
   END f_adaptacion_fiscal;

   FUNCTION f_revalorizar(
      pentrada IN NUMBER,
      codi_revali IN NUMBER,
      por_revali IN NUMBER,
      imp_revali IN NUMBER,
      psalida OUT NUMBER,
      pmodo IN NUMBER,
      pcgarant IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      -- Bug 9794 - YIL - 21/04/2009 - Se añade el parámetro pmodo para poder diferenciar si estamos revalorizando prima o capital
      --       1.- capital
      --       2.- prima
      -- Se añaden los nuevos tipos de revalorización crevali 7, 8 y 9
      -- F_revalorizar: se controla el máximo de prima sólo si se entra en modo revalorización prima,
      --        y no si entra en modo revalorización de capital
      cap_max        NUMBER;
      prima_max      NUMBER;
      -- Bug 20163 - RSC - 02/12/2012 - LCOL_T004-Completar parametrización de los productos de Vida Individual (2ª parte)
      v_imp_revali_gar NUMBER;
        -- Fin Bug 20163
      -- BUG 18423 - I - 27/12/2011 - JLB - LCOL000 - Multimoneda
      vmoneda        monedas.cmoneda%TYPE;
      -- BUG 18423 - F - 27/12/2011 - JLB - LCOL000 - Multimoneda
      v_tipo         NUMBER(1);   -- BUG 0021638 - 08/03/2012 - JMF
      -- BUG24804:DRA:28/02/2013:Inici
      v_importe      NUMBER;
      v_cmonseg      monedas.cmonint%TYPE;
      v_fecha        DATE;
      v_smlv_min     NUMBER;
      v_sproduc      productos.sproduc%TYPE;
      v_smlv_max     NUMBER;
      vicapital      NUMBER;   -- BUG 27305 - MMS - 20131010
      -- BUG24804:DRA:28/02/2013:Fi
      v_meses_restar NUMBER;
      v_limite_ipc   NUMBER;
      v_mes          NUMBER;
      v_any          NUMBER;
      v_cgarant      NUMBER;
   BEGIN
      IF pmodo = 1 THEN   -- revaloriza capital
         -- Selecciono el capital máximo que puede alcanzar la garantía.
         BEGIN
            SELECT icaprev
              INTO cap_max
              FROM garanpro
             WHERE cramo = pcramo
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
                   WHERE cramo = pcramo
                     AND cmodali = pcmodali
                     AND ctipseg = pctipseg
                     AND ccolect = pccolect
                     AND cactivi = 0
                     AND cgarant = pcgarant;
               EXCEPTION
                  WHEN OTHERS THEN
                     cap_max := 0;
               END;
            WHEN OTHERS THEN
               cap_max := 0;
         END;
      ELSIF pmodo = 2 THEN
         -- buscamos el máximo de prima según la adaptación fiscal
         num_err := f_adaptacion_fiscal(psseguro, pcgarant, pmes, pany, prima_max);

         IF num_err <> 0 THEN
            RETURN num_err;
         END IF;
      END IF;

      vmoneda := pac_monedas.f_moneda_producto(pac_productos.f_get_sproduc(pcramo, pcmodali,
                                                                           pctipseg, pccolect));

      /********************************
      0-No revalorización
      1-Revalorización lineal
      2-Revalorización geométrica
      3-I.P.C. mensual
      4-La del producto
      5-I.P.C. anual
      6-Lineal porcentaje
      7-Adaptación fiscal
      8-IPC Mensual (Revaloriza prima)
      9-IPC Anual (Revaloriza prima)
      10-Revalorización Semigeométrica
      11-Revalirización Lineal Calculada
      12-IPCV
      13-BEC
      14-IPC mensual por factor
      ********************************/
      IF codi_revali = 0 THEN
         ppsalida := pentrada;
         pfactor := 0;   --no hay revalorización
      ELSIF codi_revali = 1 THEN
         ppsalida := pentrada + imp_revali;
         pfactor := ((ppsalida / pentrada) - 1) * 100;
      ELSIF codi_revali = 2 THEN
         ppsalida := pentrada *(1 + por_revali / 100);
         pfactor := por_revali;   --el prevali
      ELSIF codi_revali IN(3, 8) THEN
         -- BUG 0021638 - 08/03/2012 - JMF
         ppipc := f_ipc(pmes, pany, 1, 1);

         IF ppipc IS NULL THEN
            RETURN 101847;
         END IF;

         ppipc_ant := f_ipc(pmes, pany - 1, 1, 1);

         IF ppipc_ant IS NULL THEN
            RETURN 101847;
         END IF;

         ppsalida := pentrada *(ppipc / ppipc_ant);
         -- Bug 10350 - RSC - 06/08/2009 - Detalle de garantía (Tarificación)
         -- Antes: pfactor := ppipc;   --ipc del año y del mes
         pfactor := ppipc / ppipc_ant;

         IF pfactor <= 1 THEN
            pfactor := 0;
         END IF;
      -- Fin Bug 10350
      ELSIF codi_revali IN(5, 9, 17) THEN   -- según IPC anual
         -- BUG 0021638 - 08/03/2012 - JMF
         SELECT sproduc
           INTO v_sproduc
           FROM seguros
          WHERE sseguro = psseguro;

         v_meses_restar := f_parproductos_v(v_sproduc, 'MESES_RESTAR_IPC');

         IF v_meses_restar IS NOT NULL THEN
            -- Si tiene parametrizado un numero de meses a restar entonces habrá que buscar el IPC en el mes concreto
            -- Si el mes es < 1 es que el més era Enero o Febrero y hay que ir al año anterior
            v_mes := TO_CHAR(ADD_MONTHS(TO_DATE('01/' || pmes || '/' || pany, 'DD/MM/YYYY'),
                                        (-1 * v_meses_restar)),
                             'MM');
            v_any := TO_CHAR(ADD_MONTHS(TO_DATE('01/' || pmes || '/' || pany, 'DD/MM/YYYY'),
                                        (-1 * v_meses_restar)),
                             'YYYY');
            ppipc := f_ipc(v_mes, v_any, 1, 1);
         ELSE
            ppipc := f_ipc(0, pany, 1, 1);
         END IF;

         IF ppipc IS NULL THEN
            RETURN 101847;
         END IF;

         -- BUG24804:DRA:28/02/2013:Inici
         IF codi_revali = 17 THEN
            ppipc := ppipc + NVL(por_revali, 0);
         END IF;

         v_limite_ipc := f_parproductos_v(v_sproduc, 'LIMITE_MAX_REVAL_IPC') / 100;   --JRH Los parametros no permiten decimales, pondremos el valor multiplicado por 100

         -- Si tiene parametrizado un límite de revaloración se usa este si se supera
         IF v_limite_ipc IS NOT NULL THEN
            IF ppipc > v_limite_ipc THEN
               ppipc := v_limite_ipc;
            END IF;
         END IF;

         -- BUG24804:DRA:28/02/2013:Fi
         ppsalida := pentrada *(1 + ppipc / 100);
         pfactor := ppipc;   --ipc del año
      -- Bug 20163 - RSC - 02/12/2012 - LCOL_T004-Completar parametrización de los productos de Vida Individual (2ª parte)
      ELSIF codi_revali IN(6, 10, 11) THEN   -- Semigeométrica / Lineal mensual calculado
         BEGIN
            SELECT crespue
              INTO v_imp_revali_gar
              FROM pregungaranseg
             WHERE sseguro = psseguro
               AND nriesgo = pnriesgo
               AND cgarant = pcgarant
               AND cpregun = 4072
               AND nmovimi = (SELECT MAX(nmovimi)
                                FROM pregungaranseg p2
                               WHERE p2.sseguro = pregungaranseg.sseguro
                                 AND p2.nriesgo = pregungaranseg.nriesgo
                                 AND p2.cgarant = pregungaranseg.cgarant
                                 AND p2.cpregun = pregungaranseg.cpregun);
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               v_imp_revali_gar := 0;   -- Por defecto máximo fiscal
         END;

         ppsalida := pentrada + v_imp_revali_gar;
         pfactor := ((ppsalida / pentrada) - 1) * 100;
      ELSIF codi_revali IN(12, 13, 14, 15) THEN
         -- BUG 0021638 - 08/03/2012 - JMF
         -- 12-IPCV
         -- 13-BEC
         -- 14-IPC mensual por factor
         -- BUG 0021638 - 12/11/2012 - JMF
         -- 15-IPI
         IF codi_revali = 14 THEN
            v_tipo := 1;
         ELSIF codi_revali = 13 THEN
            v_tipo := 2;
         ELSIF codi_revali = 12 THEN
            v_tipo := 3;
         ELSIF codi_revali = 15 THEN
            v_tipo := 4;
         ELSE
            v_tipo := 0;
         END IF;

         ppipc := f_ipc(pmes, pany, v_tipo, 2);

         IF ppipc IS NULL THEN
            RETURN 101847;
         END IF;

         ppsalida := pentrada *(1 + ppipc);
         pfactor := ppipc;
      ELSIF codi_revali = 16 THEN   -- SMLMV
         -- BUG24804:DRA:28/02/2013:Inici
         ppipc := f_ipc(0, pany, 6, 1);

         IF ppipc IS NULL THEN
            RETURN 9905057;
         END IF;

         -- INICIO BUG 27305 - MMS - 20131010
         SELECT icapital
           INTO vicapital
           FROM garanseg g
          WHERE g.sseguro = psseguro
            AND g.nriesgo = pnriesgo
            AND g.cgarant = pcgarant
            AND g.nmovimi IN(SELECT MAX(nmovimi)
                               FROM garanseg g2
                              WHERE g2.sseguro = g.sseguro
                                AND g2.nriesgo = g.nriesgo
                                AND g2.cgarant = g.cgarant
                                AND g2.nmovimi = (SELECT MAX(g3.nmovimi)
                                                    FROM movseguro g3
                                                   WHERE g3.sseguro = g2.sseguro
                                                     AND g3.cmotmov IN(100, 404, 406)));

         ppsalida := vicapital *(1 + ppipc / 100);
         --ppsalida := pentrada *(1 + ppipc / 100);
         -- FIN BUG 27305 - MMS - 20131010
         pfactor := ppipc;   --ipc del año

         -- Ini BUG 27304 - MDS - 23/04/2014 - controlar que para aux.fun. se quede dentro de un rango
         -- teniendo en cuenta que no se revaloriza el aux.fun., sinó que nos basamos en la renta mensual revalorizada
         IF pcgarant = 710 THEN
            SELECT sproduc
              INTO v_sproduc
              FROM seguros
             WHERE sseguro = psseguro;

            -- para RV, la renta mensual es la garantía 52
            -- para CP, la renta mensual es la garantía 1702
            v_cgarant := f_parproductos_v(v_sproduc, 'CGARANT_DEP_AUXFUN');
            -- mínimo, que debería de ser 5
            v_smlv_min := pac_subtablas.f_vsubtabla(NULL, 34003, 3, 1, v_sproduc);
            -- máximo, que debería de ser 10
            v_smlv_max := pac_subtablas.f_vsubtabla(NULL, 34003, 3, 2, v_sproduc);

            -- si el rango está informado, entonces controlar que la 710 revalorizada quede dentro de un rango cuando es por SMLV
            IF v_cgarant IS NOT NULL
               AND v_smlv_min IS NOT NULL
               AND v_smlv_max IS NOT NULL THEN
               --  teniendo en cuenta que no se revaloriza el aux.fun., sinó que nos basamos en la renta mensual revalorizada
               SELECT icapital
                 INTO ppsalida
                 FROM tmp_garancar g
                WHERE g.sseguro = psseguro
                  AND g.nriesgo = pnriesgo
                  AND g.cgarant = v_cgarant
                  AND g.sproces = (SELECT MAX(sproces)
                                     FROM tmp_garancar g2
                                    WHERE g2.sseguro = psseguro
                                      AND g2.nriesgo = pnriesgo
                                      AND g2.cgarant = v_cgarant);

               IF NVL(vicapital, 0) <> 0 THEN
                  pfactor :=(((ppsalida / vicapital) - 1) * 100);
               ELSE
                  pfactor := 0;
               END IF;

               -- importe SMLV
               v_cmonseg := NVL(pac_monedas.f_moneda_seguro_char('SEG', psseguro),
                                pac_monedas.f_cmoneda_t(vmoneda));
               v_fecha := pac_eco_tipocambio.f_fecha_max_cambio(v_cmonseg, 'SMV',
                                                                TRUNC(TO_DATE(LPAD(pmes, 2,
                                                                                   '0')
                                                                              || pany,
                                                                              'MMYYYY')));
               v_importesalant := pac_eco_tipocambio.f_importe_cambio('SMV', v_cmonseg,
                                                                      v_fecha, 1);

               -- si la renta mensual revalorizada es < 5 SMLV
               IF ppsalida < v_smlv_min * v_importesalant THEN
                  ppsalida := v_smlv_min * v_importesalant;

                  IF NVL(vicapital, 0) <> 0 THEN
                     pfactor :=(((ppsalida / vicapital) - 1) * 100);
                  ELSE
                     pfactor := 0;
                  END IF;
               END IF;

               -- si la renta mensual revalorizada es > 10 SMLV
               IF ppsalida > v_smlv_max * v_importesalant THEN
                  ppsalida := v_smlv_max * v_importesalant;

                  IF NVL(vicapital, 0) <> 0 THEN
                     pfactor :=(((ppsalida / vicapital) - 1) * 100);
                  ELSE
                     pfactor := 0;
                  END IF;
               END IF;
            END IF;
         END IF;
      -- Fin BUG 27304 - MDS - 23/04/2014
      ELSIF codi_revali = 18 THEN   -- IPC limite SMLMV
         v_cmonseg := NVL(pac_monedas.f_moneda_seguro_char('SEG', psseguro),
                          pac_monedas.f_cmoneda_t(vmoneda));

         --JRH 27/10/2013 Corrección
         SELECT icapital, finiefe
           INTO vicapital, vfechacart
           FROM garanseg g
          WHERE g.sseguro = psseguro
            AND g.nriesgo = pnriesgo
            AND g.cgarant = pcgarant
            AND g.nmovimi IN(SELECT MAX(nmovimi)
                               FROM garanseg g2
                              WHERE g2.sseguro = g.sseguro
                                AND g2.nriesgo = g.nriesgo
                                AND g2.cgarant = g.cgarant
                                AND g2.nmovimi = (SELECT MAX(g3.nmovimi)
                                                    FROM movseguro g3
                                                   WHERE g3.sseguro = g2.sseguro
                                                     AND g3.cmotmov IN(100, 404, 406)));

         v_fecha := pac_eco_tipocambio.f_fecha_max_cambio(v_cmonseg, 'SMV', vfechacart);
         v_importesalant := pac_eco_tipocambio.f_importe_cambio('SMV', v_cmonseg, v_fecha, 1);

         IF vicapital = v_importesalant THEN   --JRH 27/10/2013  Si era por salarios , sigue siendo por salarios
            v_fecha := pac_eco_tipocambio.f_fecha_max_cambio(v_cmonseg, 'SMV',
                                                             TRUNC(TO_DATE(LPAD(pmes, 2, '0')
                                                                           || pany,
                                                                           'MMYYYY')));
            ppsalida := pac_eco_tipocambio.f_importe_cambio('SMV', v_cmonseg, v_fecha, 1);

            IF NVL(vicapital, 0) <> 0 THEN
               pfactor :=(((ppsalida / vicapital) - 1) * 100);   --Factor será el capital anterior y el nuevo
            ELSE
               pfactor := 0;
            END IF;
         ELSE   --Que haga lo que hacía ahora
            -- BUG24804:DRA:28/02/2013:Inici
            ppipc := f_ipc(0, pany, 1, 1);

            IF ppipc IS NULL THEN
               RETURN 101847;
            END IF;

            ppsalida := pentrada *(1 + ppipc / 100);
            pfactor := ppipc;   --ipc del año
            v_fecha := pac_eco_tipocambio.f_fecha_max_cambio(v_cmonseg, 'SMV',
                                                             TRUNC(TO_DATE(LPAD(pmes, 2, '0')
                                                                           || pany,
                                                                           'MMYYYY')));

--            v_importe := pac_eco_tipocambio.f_importe_cambio(v_cmonseg, 'SMV', v_fecha,
--                                                             ppsalida);

            --JRH La funcón anterior tiene problemas con los redondeos
            SELECT ppsalida / itasa
              INTO v_importe
              FROM eco_tipocambio e
             WHERE e.cmonori = 'SMV'
               AND e.cmondes = v_cmonseg
               AND e.fcambio = (SELECT MAX(fcambio)
                                  FROM eco_tipocambio e2
                                 WHERE e2.cmonori = e.cmonori
                                   AND e2.cmondes = e.cmondes
                                   AND e2.fcambio <=
                                            TRUNC(TO_DATE(LPAD(pmes, 2, '0') || pany, 'MMYYYY')));

            --
            SELECT sproduc
              INTO v_sproduc
              FROM seguros
             WHERE sseguro = psseguro;

            v_smlv_min := NVL(f_parproductos_v(v_sproduc, 'SMLMV_MIN'), 1);
            v_smlv_max := NVL(f_parproductos_v(v_sproduc, 'SMLMV_MAX'), 25);

            IF v_importe < v_smlv_min THEN
               -- Si es inferior a 1, se fija a 1
               ppsalida := pac_eco_tipocambio.f_importe_cambio('SMV', v_cmonseg, v_fecha,
                                                               v_smlv_min);

               IF NVL(pentrada, 0) <> 0 THEN
                  pfactor :=(((ppsalida / pentrada) - 1) * 100);   ---f_ipc(0, pany, 6, 1);
               ELSE
                  pfactor := 0;
               END IF;
            ELSIF v_importe > v_smlv_max THEN
               ppsalida := pac_eco_tipocambio.f_importe_cambio('SMV', v_cmonseg, v_fecha,
                                                               v_smlv_max);

               IF NVL(pentrada, 0) <> 0 THEN
                  pfactor :=(((ppsalida / pentrada) - 1) * 100);
               ELSE
                  pfactor := 0;
               END IF;
            END IF;
         END IF;
      END IF;

      -- Ini Bug 27305 - MDS - 06/10/2014
      -- exclusivamente para la Mesada 14, una vez revalorizada, controlar los 15 SMLV
      IF (pcgarant = 1703)
         AND(codi_revali <> 0) THEN
         -- capital y fecha de último movimiento, antes de revalorizar
         SELECT icapital, finiefe
           INTO vicapital, vfechacart
           FROM garanseg g
          WHERE g.sseguro = psseguro
            AND g.nriesgo = pnriesgo
            AND g.cgarant = pcgarant
            AND g.nmovimi IN(SELECT MAX(nmovimi)
                               FROM garanseg g2
                              WHERE g2.sseguro = g.sseguro
                                AND g2.nriesgo = g.nriesgo
                                AND g2.cgarant = g.cgarant
                                -- INI RLLF 26022015 Error pac_dincartera BUG-34956
                                --                    AND g2.nmovimi = (SELECT MAX(g3.nmovimi)
                                --                                       FROM movseguro g3
                                --                                       WHERE g3.sseguro = g2.sseguro
                                --                                         AND g3.cmovseg NOT IN(52)));
                                AND g2.nmovimi = (SELECT MAX(g3.nmovimi)
                                                    FROM garanseg g3
                                                   WHERE g3.sseguro = g2.sseguro
                                                     AND g3.nriesgo = g2.nriesgo
                                                     AND g3.cgarant = g2.cgarant));

         -- FIN RLLF 26022015 Error pac_dincartera BUG-34956

         -- importe 15 SMLV antes de revalorizar
         SELECT sproduc
           INTO v_sproduc
           FROM seguros
          WHERE sseguro = psseguro;

         v_smlv_max := NVL(f_parproductos_v(v_sproduc, 'SMLMV_MAX_MESADA14'), 15);
         v_cmonseg := NVL(pac_monedas.f_moneda_seguro_char('SEG', psseguro),
                          pac_monedas.f_cmoneda_t(vmoneda));
         v_fecha := pac_eco_tipocambio.f_fecha_max_cambio(v_cmonseg, 'SMV', vfechacart);
         v_importesalant := pac_eco_tipocambio.f_importe_cambio('SMV', v_cmonseg, v_fecha,
                                                                v_smlv_max);

         -- Mantenerse en los 15 SMLV actuales
         IF vicapital = v_importesalant THEN
            -- que se quede en 15 SMLV actuales, en lugar de la revalorización hecha
            v_fecha := pac_eco_tipocambio.f_fecha_max_cambio(v_cmonseg, 'SMV',
                                                             TRUNC(TO_DATE(LPAD(pmes, 2, '0')
                                                                           || pany,
                                                                           'MMYYYY')));
            v_importesalant := pac_eco_tipocambio.f_importe_cambio('SMV', v_cmonseg, v_fecha,
                                                                   v_smlv_max);
            ppsalida := v_importesalant;

            IF NVL(vicapital, 0) <> 0 THEN
               pfactor :=(((ppsalida / vicapital) - 1) * 100);
            ELSE
               pfactor := 0;
            END IF;
         ELSE
            --  No pasarse de los 15 SMLV actuales
            v_fecha := pac_eco_tipocambio.f_fecha_max_cambio(v_cmonseg, 'SMV',
                                                             TRUNC(TO_DATE(LPAD(pmes, 2, '0')
                                                                           || pany,
                                                                           'MMYYYY')));
            v_importesalant := pac_eco_tipocambio.f_importe_cambio('SMV', v_cmonseg, v_fecha,
                                                                   v_smlv_max);

            -- si la mesada ya revalorizada es > 15 SMLV,
            -- que se quede en 15 SMLV actuales, en lugar de la revalorización hecha
            IF ppsalida > v_importesalant THEN
               ppsalida := v_importesalant;

               IF NVL(vicapital, 0) <> 0 THEN
                  pfactor :=(((ppsalida / vicapital) - 1) * 100);
               ELSE
                  pfactor := 0;
               END IF;
            END IF;
         END IF;
      END IF;

      -- Fin Bug 27305 - MDS - 06/10/2014

      -- Fin Bug 20163
      IF pmodo = 1 THEN   -- revalorizacion de capital
         IF NVL(cap_max, 0) = 0 THEN
            psalida := f_round(NVL(ppsalida, 0), vmoneda);   -- BUG 18423 - F - 27/12/2011 - JLB - LCOL000 - Multimoneda
         ELSIF f_round(NVL(ppsalida, 0)) > NVL(cap_max, 0) THEN
            IF codi_revali <> 0 THEN
               psalida := cap_max;
            ELSE
               psalida := f_round(NVL(ppsalida, 0), vmoneda);   -- BUG 18423 - F - 27/12/2011 - JLB - LCOL000 - Multimoneda
            END IF;
         ELSE
            psalida := f_round(NVL(ppsalida, 0), vmoneda);   -- BUG 18423 - F - 27/12/2011 - JLB - LCOL000 - Multimoneda
         END IF;
      ELSE
         IF NVL(prima_max, 0) = 0 THEN
            psalida := f_round(NVL(ppsalida, 0), vmoneda);   -- BUG 18423 - F - 27/12/2011 - JLB - LCOL000 - Multimoneda
         -- BUG 18423 - I - 27/12/2011 - JLB - LCOL000 - Multimoneda
               --ELSIF f_round(NVL(ppsalida, 0)) > NVL(prima_max, 0) THEN
         ELSIF f_round(NVL(ppsalida, 0), vmoneda) > NVL(prima_max, 0) THEN
            -- BUG 18423 - F - 27/12/2011 - JLB - LCOL000 - Multimoneda
            IF codi_revali <> 0 THEN
               psalida := prima_max;
            ELSE
               psalida := f_round(NVL(ppsalida, 0), vmoneda);   -- BUG 18423 - F - 27/12/2011 - JLB - LCOL000 - Multimoneda
            END IF;
         ELSE
            psalida := f_round(NVL(ppsalida, 0), vmoneda);   -- BUG 18423 - F - 27/12/2011 - JLB - LCOL000 - Multimoneda
         END IF;
      END IF;

      RETURN 0;
   END f_revalorizar;

   /*bug 24926 Nota 134066, JDS: 15/01/2013 */
   FUNCTION f_puede_revalorizar(
      psseguro IN NUMBER,
      pcgarant IN NUMBER,
      pcactivi IN NUMBER,
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER)
      RETURN NUMBER IS
      vsperson       per_personas.sperson%TYPE;
      vfnacimi       per_personas.fnacimi%TYPE;
      vnedamrv       garanpro.nedamrv%TYPE;
      vtipo          NUMBER(1);
      vedad          NUMBER(2);
      vret           NUMBER(1) := 0;
      v_fecha        DATE;
      v_traza        NUMBER(2);
   BEGIN
      v_traza := 1;

      --recuperación código persona
      SELECT a.sperson
        INTO vsperson
        FROM asegurados a
       WHERE a.sseguro = psseguro
         AND a.norden = (SELECT MIN(a1.norden)
                           FROM asegurados a1
                          WHERE a1.sseguro = a.sseguro);

      v_traza := 2;

      --recuperación código fecha nacimiento de la persona.
      SELECT fnacimi
        INTO vfnacimi
        FROM per_personas
       WHERE sperson = vsperson;

      v_traza := 3;

      --recuperación de la edad (NEDAMRV) de la garantía.
      BEGIN
         SELECT DECODE(ciedmrv, 0, 2, 1, 1) ciedmrv, nedamrv
           INTO vtipo, vnedamrv
           FROM garanpro
          WHERE cgarant = pcgarant
            AND cramo = pcramo
            AND cmodali = pcmodali
            AND ccolect = pccolect
            AND ctipseg = pctipseg
            AND cactivi = pcactivi;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            BEGIN
               v_traza := 4;

               SELECT DECODE(ciedmrv, 0, 2, 1, 1) ciedmrv, nedamrv
                 INTO vtipo, vnedamrv
                 FROM garanpro
                WHERE cgarant = pcgarant
                  AND cramo = pcramo
                  AND cmodali = pcmodali
                  AND ccolect = pccolect
                  AND ctipseg = pctipseg
                  AND cactivi = 0;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  RETURN 1;
            END;
      END;

      --se determina la edad del asegurado según el ptipo --> tipo=1: 'edad real', tipo=2: 'edad acturial'
      v_traza := 5;
      v_fecha := TRUNC(TO_DATE(LPAD(pmes, 2, '0') || pany, 'MMYYYY'));
      v_traza := 6;
      vedad := fedad(-1, TO_CHAR(vfnacimi, 'YYYYMMDD'), TO_CHAR(v_fecha, 'YYYYMMDD'), vtipo);

      --si la edad retornada por FEDAD es menor o igual que la informada en el campo NEDAMRV, sí se puede revalorizar (ret=1)
      IF (NVL(vnedamrv, 999) >= vedad) THEN
         vret := 1;   --(ret = 1) se podrá revalorizar, (ret =0 ) no se podrá revalorizar.
      END IF;

      RETURN vret;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'F_REVALGAR.f_puede_revalorizar', v_traza,
                     psseguro || '-' || pcgarant || '-' || pcactivi || '-' || pcramo || '-'
                     || pcmodali || '-' || pctipseg || '-' || pccolect || '-' || vsperson
                     || '-' || TO_CHAR(vfnacimi, 'YYYYMMDD') || '-'
                     || TO_CHAR(v_fecha, 'YYYYMMDD'),
                     SQLERRM);
         RETURN 1;   -- Quiero que continue haciendo lo que hacía antes
   END f_puede_revalorizar;
------CUERPO DE LA FUNCION-----------
-------------------------------------
BEGIN
   --revalorización de capital
   IF pcmanual IN(0, 2, 3)
      AND pcrevali NOT IN(7, 8, 9)
      AND f_puede_revalorizar(psseguro, pcgarant, pcactivi, pcramo, pcmodali, pctipseg,
                              pccolect) = 1 THEN
      IF pcrevali <> 4 THEN
         num_err := f_revalorizar(picapital, pcrevali, pprevali, pirevali, prevcap, 1,
                                  pcgarant);

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

         num_err := f_revalorizar(picapital, procrevali, proprevali, proirevali, prevcap, 1);

         IF num_err <> 0 THEN
            RETURN num_err;
         END IF;
      END IF;
   ELSE
      prevcap := picapital;
   END IF;

   --revalorización de prima.
   IF (pcmanual IN(1, 2, 3, 4)
       OR(pcmanual = 0
          AND pcrevali IN(7, 8, 9)))
      AND f_puede_revalorizar(psseguro, pcgarant, pcactivi, pcramo, pcmodali, pctipseg,
                              pccolect) = 1 THEN
      IF pcrevali <> 4 THEN
         --num_err := f_revalorizar(piprianu, pcrevali, pprevali, pirevali, prevprima);
         IF pcrevali = 7 THEN   -- adaptacion fiscal de prima
            num_err := f_adaptacion_fiscal(psseguro, pcgarant, pmes, pany, prevprima);
         ELSE
            IF pcrevali IN(8, 9) THEN   -- para que calcule el máximo de prima según adaptación fiscal
               v_modo := 2;
            ELSE
               v_modo := 0;   -- para que NO calcule el máximo de prima según adaptación fiscal
            END IF;

            num_err := f_revalorizar(piprianu, pcrevali, pprevali, pirevali, prevprima, v_modo);
         END IF;

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

         --num_err := f_revalorizar(piprianu,procrevali,proprevali,proirevali,prevprima);
         IF pcrevali = 7 THEN   -- adaptacion fiscal
            num_err := f_adaptacion_fiscal(psseguro, pcgarant, pmes, pany, prevprima);
         ELSE
            IF pcrevali IN(8, 9) THEN   -- para que calcule el máximo de prima según adaptación fiscal
               v_modo := 2;
            ELSE
               v_modo := 0;   -- para que NO calcule el máximo de prima según adaptación fiscal
            END IF;

            num_err := f_revalorizar(piprianu, pcrevali, pprevali, pirevali, prevprima, v_modo);
         END IF;

         IF num_err <> 0 THEN
            RETURN num_err;
         END IF;
      END IF;
   END IF;

   RETURN 0;
END f_revalgar;

/

  GRANT EXECUTE ON "AXIS"."F_REVALGAR" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_REVALGAR" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_REVALGAR" TO "PROGRAMADORESCSI";
