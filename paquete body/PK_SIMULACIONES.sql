--------------------------------------------------------
--  DDL for Package Body PK_SIMULACIONES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PK_SIMULACIONES" AS
   /******************************************************************************
      NOMBRE:     PK_SIMULACIONES
      PROPÓSITO:  Funciones de simulacion

      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.0        XX/XX/XXXX   XXX                1. Creación del package.
      1.1        27/03/2009   JMR                2. Bug 9446 (precisiones var numericas)
      2.0        17/04/2009   APD                3. Bug 9699 - primero se ha de buscar para la actividad en concreto
                                                    y si no se encuentra nada ir a buscar a PREGUNPROGARAN para la actividad cero
      3.0        09/04/2009   JTS                4. BUG9748 - IAX -ACTIVIDAD - Selects contra INCOMPAGARAN, tener en cuenta la actividad
      4.0        26/06/2009   ETM                5. BUG 0010549: CIV - ESTRUC - Fecha de efecto fija para un producto
      5.0        22/10/2009   DRA                6. 0009496: IAX - Contractació: Gestió de preguntes de garantia + control selecció mínim 1 garantia
      7.0        27/01/2014   JTT                7. 0027429: Persistencia simulaciones
      8.0        07/03/2014   CML                8. 0028955: Añadir nuevo caso de fecha de efecto día 1
                                                             (mes actual hasta el día 15 y mes posterior después del 15)
   ******************************************************************************/
   /***********************************************************************************************************************
      Vida Ahorro
      Se añade la función f_control_edad_suma: valida la suma de capitales de los dos asegurados (2 cabezas)
     **********************************************************************************************************************/
   FUNCTION f_crea_solicitud(
      psproduc IN NUMBER,
      pssolicit OUT NUMBER,
      pnumriesgos IN NUMBER DEFAULT 1,
      pfefecto IN DATE DEFAULT f_sysdate)
      RETURN NUMBER IS
      vcactivi       solseguros.cactivi%TYPE := 0;
      vcestat        solseguros.cestat%TYPE := 0;
      vctipcol       solseguros.ctipcol%TYPE := 1;
      pnriesgo       riesgos.nriesgo%TYPE;
      num_err        NUMBER;
      solreg         solseguros%ROWTYPE;
      vcdurmin       productos.cdurmin%TYPE;
      vnvtomin       productos.nvtomin%TYPE;
      v_fvtomin      DATE;
      v_coficina     NUMBER;
      v_fefecto      DATE;
      vcagrpro       productos.cagrpro%TYPE;
      vcsubpro       productos.csubpro%TYPE;
      v_traza        tab_error.ntraza%TYPE;
   BEGIN
      v_traza := 20;

      SELECT ssolicit.NEXTVAL
        INTO pssolicit
        FROM DUAL;

      -- BUG 10549 - 26/06/2009 - ETM - Fecha de efecto fija para un producto--INI
      IF pac_parametros.f_parproducto_f(psproduc, 'DIA_EFECTO') IS NOT NULL THEN
         v_fefecto := pac_parametros.f_parproducto_f(psproduc, 'DIA_EFECTO');
      -- BUG 10549 - 26/06/2009 - ETM - Fecha de efecto fija para un producto--FIN
      ELSIF NVL(f_parproductos_v(psproduc, 'DIA_INICIO_01'), 0) IN(1, 3) THEN
         -- la fecha de efecto será el 1 del mes siguiente
         v_fefecto := TO_DATE('01' || TO_CHAR((LAST_DAY(pfefecto) + 1), 'mmyyyy'), 'ddmmyyyy');
      ELSIF NVL(f_parproductos_v(psproduc, 'DIA_INICIO_01'), 0) IN(2, 4) THEN
         -- la fecha de efecto será el 1 del mes en curso
         v_fefecto := TO_DATE('01' || TO_CHAR(pfefecto, 'mmyyyy'), 'ddmmyyyy');
      ELSIF NVL(f_parproductos_v(psproduc, 'DIA_INICIO_01'), 0) IN(5)
            AND TO_NUMBER(TO_CHAR(TRUNC(f_sysdate), 'dd')) > 15 THEN
         -- la fecha de efecto será el 1 del mes siguiente
         v_fefecto := TO_DATE('01' || TO_CHAR((LAST_DAY(pfefecto) + 1), 'mmyyyy'), 'ddmmyyyy');
      ELSIF NVL(f_parproductos_v(psproduc, 'DIA_INICIO_01'), 0) IN(5)
            AND TO_NUMBER(TO_CHAR(TRUNC(f_sysdate), 'dd')) <= 15 THEN
         -- la fecha de efecto será el 1 del mes en curso
         v_fefecto := TO_DATE('01' || TO_CHAR(pfefecto, 'mmyyyy'), 'ddmmyyyy');
      ELSE
         v_fefecto := pfefecto;
      END IF;

      v_traza := 21;

      SELECT cdurmin, nvtomin, cagrpro, csubpro
        INTO vcdurmin, vnvtomin, vcagrpro, vcsubpro
        FROM productos
       WHERE sproduc = psproduc;

      --Calculamos el vencimiento mínimo y vencimiento máximo según
      -- el producto
      IF vcdurmin IS NOT NULL THEN
         IF vcdurmin = 0 THEN   -- aÑOS
            v_fvtomin := ADD_MONTHS(v_fefecto, vnvtomin * 12);
         ELSIF vcdurmin = 1 THEN   -- meses
            v_fvtomin := ADD_MONTHS(v_fefecto, vnvtomin);
         ELSIF vcdurmin = 2 THEN   -- días
            v_fvtomin := v_fefecto + vnvtomin;
         ELSIF vcdurmin = 3 THEN   -- mes y día
            v_fvtomin := ADD_MONTHS(v_fefecto, vnvtomin) + 1;
         END IF;
      END IF;

      /*
      {Si la duración mínima es nula, miramos si tiene duración fija
       ESTO ES UNA PEQUEÑA CHAPUZA}
      */
      IF vcdurmin IS NULL THEN
         vnvtomin := f_parproductos_v(psproduc, 'DURAC_FIJA');
         v_fvtomin := ADD_MONTHS(v_fefecto, vnvtomin * 12);
      END IF;

      v_traza := 22;
      v_coficina := NVL(pk_nueva_produccion.f_oficina_mv, 100);

      BEGIN
         INSERT INTO solseguros
                     (ssolicit, cramo, cmodali, ctipseg, ccolect, cagente, falta, cobjase,
                      csubpro, cactivi, cestat, cduraci, nduraci, cforpag, ndurcob, cusuari,
                      ctarman, ctipcol, fvencim, crevali, prevali, irevali, sproduc)
            SELECT pssolicit, p.cramo, p.cmodali, p.ctipseg, p.ccolect,
                                                                       --v_coficina, TO_CHAR (f_sysdate, 'dd/mm/yyyy'), p.cobjase,
                                                                       v_coficina, v_fefecto,
                   p.cobjase, p.csubpro, vcactivi, vcestat, p.cduraci, vnvtomin, p.cpagdef,
                   p.ndurcob, f_user, p.ctarman, vctipcol, v_fvtomin, p.crevali, p.prevali,
                   p.crevali, psproduc
              FROM productos p
             WHERE sproduc = psproduc;
      EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, 'pk_simulaciones.f_crea_solicitud', 1,
                        'error al insertar en solseguros. ( ssolicit =' || pssolicit || '  )',
                        SQLERRM);
            RETURN 140256;
      END;

      IF f_prod_ahorro(psproduc) = 1 THEN   -- es un producto de ahorro
         --  INSERTAMOS EN LA TABLA SOLSEGUROS_AHO
         BEGIN
            INSERT INTO solseguros_aho
                        (ssolicit, pinttec, pintpac, fsusapo, ndurper)
                 VALUES (pssolicit, NULL, NULL, NULL, NULL);
         EXCEPTION
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, 'pk_simulaciones.f_crea_solicitud', 2,
                           'error al insertar en seguros_aho.',
                           SQLERRM || ' ( ssolicit =' || pssolicit || '  )');
               RETURN 180180;
         END;
      END IF;

          --JRH  Esto no estaba en el source safe, habrá que ponerlo
      -- si es una poliza producto de rentas grabamos en ESTSEGUROS_REN
      IF NVL(f_parproductos_v(psproduc, 'ES_PRODUCTO_RENTAS'), 0) = 1 THEN   -- es un producto de rentas
         --  JRH TABIÉN INSERTAMOS EN LA TABLA ESTSEGUROS_AHO
         BEGIN
            INSERT INTO solseguros_aho
                        (ssolicit, pinttec, pintpac, fsusapo, ndurper)
                 VALUES (pssolicit, NULL, NULL, NULL, NULL);
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               NULL;
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, 'pk_simulaciones.f_crea_solicitud', 2,
                           'error al insertar en seguros_aho.',
                           SQLERRM || ' ( ssolicit =' || pssolicit || '  )');
               RETURN 180180;
         END;

         BEGIN
            INSERT INTO solseguros_ren
                        (ssolicit, f1paren,
                         fuparen, cforpag, ibruren)   --JRH
                 VALUES (pssolicit, TO_DATE('01/01/2008', 'DD/MM/YYYY'),
                         TO_DATE('01/01/2008', 'DD/MM/YYYY'), 0, 123);
         EXCEPTION
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, 'pk_simulaciones.f_ins_estseguros', NULL,
                           'error al insertar en estseguros_ren.',
                           SQLERRM || ' ( sseguro =' || pssolicit || '  )');
               RETURN 140256;
         END;
      END IF;

      v_traza := 24;

      SELECT *
        INTO solreg
        FROM solseguros
       WHERE ssolicit = pssolicit;

      num_err := f_crea_solasegurado(pssolicit, 1);

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      FOR xnriesgo IN 1 .. pnumriesgos LOOP
         v_traza := 25;
         num_err := f_crea_solriesgo(pssolicit, xnriesgo, psproduc);

         IF num_err <> 0 THEN
            RETURN num_err;
         END IF;

         v_traza := 26;
         num_err := f_crea_solgarant(pssolicit, xnriesgo, solreg.cramo, solreg.cmodali,
                                     solreg.ctipseg, solreg.ccolect, psproduc, solreg.cactivi,
                                     v_fefecto);

         IF num_err <> 0 THEN
            RETURN num_err;
         END IF;
      END LOOP;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pk_simulaciones.f_crea_solicitud', v_traza, 'error',
                     SQLERRM);
         RETURN 108190;
   END f_crea_solicitud;

/*************************************************************************
   FUNCTION  f_crea_solriesgo
******************************************************************************/
   FUNCTION f_crea_solriesgo(pssolicit IN NUMBER, pnriesgo IN NUMBER, psproduc IN NUMBER)
      RETURN NUMBER IS
   BEGIN
      BEGIN
         INSERT INTO solriesgos
                     (ssolicit, nriesgo, tapelli, tnombre, fnacimi, csexper)
              VALUES (pssolicit, pnriesgo, '*', '*', NULL, NULL);
      EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, 'pk_simulaciones.f_crea_solriesgo', 1,
                        'error al insertar en solriesgos. ( ssolicit =' || pssolicit
                        || ' pnriesgo =' || pnriesgo || ' psproduc =' || psproduc || '  )',
                        SQLERRM);
            RETURN 140258;   -- Error al insertar en solriesgos.
      END;

      --Insertamos las preguntas a nivel de riesgo
      BEGIN
         INSERT INTO solpregunseg
                     (ssolicit, nriesgo, cpregun, crespue, nmovimi)
            SELECT pssolicit, pnriesgo, cpregun, 0, 1
              FROM pregunpro
             WHERE sproduc = psproduc;
      EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, 'pk_simulaciones.f_crea_solriesgo', 2,
                        'error al insertar en solpregunseg. ( ssolicit =' || pssolicit
                        || ' pnriesgo =' || pnriesgo || ' psproduc =' || psproduc || '  )',
                        SQLERRM);
            RETURN 140258;   -- Error al insertar en solriesgos.
      END;

      RETURN 0;
   END f_crea_solriesgo;

/*************************************************************************
   FUNCTION  f_crea_solasegurado
******************************************************************************/
   FUNCTION f_crea_solasegurado(
      pssolicit IN NUMBER,
      pnorden IN NUMBER,
      ptapelli IN VARCHAR2 DEFAULT '*',
      ptnombre IN VARCHAR2 DEFAULT '*',
      pfnacimi IN DATE DEFAULT NULL,
      pcsexper IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
   BEGIN
      BEGIN
         INSERT INTO solasegurados
                     (ssolicit, norden, fnacimi, csexper,
                      tapelli, tnombre)
              VALUES (pssolicit, pnorden, NVL(pfnacimi, f_sysdate), NVL(pcsexper, 0),
                      ptapelli, ptnombre);
      EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, 'pk_simulaciones.f_creasolasegurado', NULL,
                        'insert en solasegurados',
                        SQLERRM || ' ( ssolicit =' || pssolicit || '  )');
            RETURN 151707;   -- Error al insertar en solasegurados
      END;

      RETURN 0;
   END f_crea_solasegurado;

/*************************************************************************
   FUNCTION  f_crea_solgarant
******************************************************************************/
   FUNCTION f_crea_solgarant(
      pssolicit IN NUMBER,
      pnriesgo IN NUMBER,
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pfefecto IN DATE)
      RETURN NUMBER IS
      CURSOR garantias IS
         -- Bug 9699 - APD - 23/04/2009 - primero se ha de buscar para la actividad en concreto
         -- y si no se encuentra nada ir a buscar a GARANPRO para la actividad cero
         SELECT *
           FROM garanpro g
          WHERE g.sproduc = psproduc
            AND g.cactivi = pcactivi
         UNION
         SELECT *
           FROM garanpro g
          WHERE g.sproduc = psproduc
            AND g.cactivi = 0
            AND NOT EXISTS(SELECT *
                             FROM garanpro g
                            WHERE g.sproduc = psproduc
                              AND g.cactivi = pcactivi);

      vcobliga       solgaranseg.cobliga%TYPE;
      vicapital      solgaranseg.icapital%TYPE;
      pmensa         VARCHAR2(3000);
      num_err        NUMBER;
   BEGIN
      FOR g IN garantias LOOP
         IF g.ctipgar = 2 THEN
            vcobliga := 1;
            num_err := pk_simulaciones.f_validacion_cobliga(pssolicit, pnriesgo, 1, g.cgarant,
                                                            'SEL', psproduc, pcactivi, pmensa);
           --informamos el k segun el tipo de kapital de la garantia
         --  IF g.ctipcap = 1 THEN
           --   vicapital    := g.icapmax;
           --ELSIF g.ctipcap IN (4, 5) THEN
            --  vicapital    := 0;
           --ELSE
             -- vicapital    := NULL;
           --END IF;
         ELSE
            vcobliga := 0;
            vicapital := NULL;
         END IF;

         BEGIN
            INSERT INTO solgaranseg
                        (ssolicit, nriesgo, cgarant, finiefe, norden, ctarifa,
                         icapital, iprianu, cformul, ctipfra, ifranqu, ipritar, itarifa,
                         crevali, prevali, irevali, cobliga, ctipgar)
                 VALUES (pssolicit, pnriesgo, g.cgarant,
                                                        --TO_CHAR (f_sysdate, 'dd/mm/yyyy'), g.norden,
                                                        pfefecto, g.norden, g.ctarifa,
                         vicapital, NULL, g.cformul, g.ctipfra, g.ifranqu, 0, 0,
                         g.crevali, g.prevali, g.irevali, vcobliga, g.ctipgar);
         EXCEPTION
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, 'pk_simulaciones.f_crea_solgarant', 1,
                           'error al insertar en solgaranseg. ( ssolicit =' || pssolicit
                           || ' pnriesgo =' || pnriesgo || ' psproduc =' || psproduc || '  )',
                           SQLERRM);
               RETURN 140267;   --Error al insertar en solgranseg
         END;

         IF vcobliga = 1 THEN
            BEGIN
               -- Bug 9699 - APD - 08/04/2009 - primero se ha de buscar para la actividad en concreto
               -- y si no se encuentra nada ir a buscar a PREGUNPROGARAN para la actividad cero
               INSERT INTO solpregungaranseg
                           (ssolicit, nriesgo, cgarant, cpregun, crespue)
                  SELECT pssolicit, pnriesgo, cgarant, cpregun, 0
                    FROM pregunprogaran
                   WHERE sproduc = psproduc
                     AND cactivi = pcactivi
                     AND cgarant = g.cgarant
                  UNION
                  SELECT pssolicit, pnriesgo, cgarant, cpregun, 0
                    FROM pregunprogaran
                   WHERE sproduc = psproduc
                     AND cactivi = 0
                     AND cgarant = g.cgarant
                     AND NOT EXISTS(SELECT pssolicit, pnriesgo, cgarant, cpregun, 0
                                      FROM pregunprogaran
                                     WHERE sproduc = psproduc
                                       AND cactivi = pcactivi
                                       AND cgarant = g.cgarant);
            -- Bug 9699 - APD - 08/04/2009 - Fin
            END;
         END IF;
      END LOOP;

      RETURN 0;
   END f_crea_solgarant;

   /*************************************************************************
      FUNCTION  f_calculo_capital_calculado
   ******************************************************************************/
   FUNCTION f_calculo_capital_calculado(
      pfecha IN DATE,
      psseguro IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      porigen IN NUMBER,
      pcapital OUT NUMBER)   -- 0.- sol, 1.- est, 2.- SEG
      RETURN NUMBER IS
      v_sproduc      garanpro.sproduc%TYPE;
      v_ctipcap      garanpro.ctipcap%TYPE;
      clav           NUMBER;
      num_err        NUMBER;
      v_cramo        seguros.cramo%TYPE;
      v_cmodali      seguros.cmodali%TYPE;
      v_ctipseg      seguros.ctipseg%TYPE;
      v_ccolect      seguros.ccolect%TYPE;
   --  pcactivi      number;
   BEGIN
      --  Comprobamos que el capital es calculado
      BEGIN
         SELECT s.sproduc, ctipcap, s.cramo, s.cmodali, s.ctipseg, s.ccolect
           INTO v_sproduc, v_ctipcap, v_cramo, v_cmodali, v_ctipseg, v_ccolect
           FROM solseguros s, garanpro g
          WHERE ssolicit = psseguro
            AND s.sproduc = g.sproduc
            AND g.cgarant = pcgarant
            AND g.cactivi = pcactivi;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            SELECT s.sproduc, ctipcap
              INTO v_sproduc, v_ctipcap
              FROM solseguros s, garanpro g
             WHERE ssolicit = psseguro
               AND s.sproduc = g.sproduc
               AND g.cgarant = pcgarant
               AND g.cactivi = 0;
         WHEN OTHERS THEN
            RETURN 101903;
      END;

      IF v_ctipcap <> 5 THEN
         RETURN 112349;
      END IF;

      -- Calculamos la clave de la fórmula
      num_err := pac_tarifas.f_clave(pcgarant, v_cramo, v_cmodali, v_ctipseg, v_ccolect,
                                     pcactivi, 'ICAPCAL', clav);

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      num_err := pac_calculo_formulas.calc_formul(pfecha, v_sproduc, pcactivi, pcgarant,
                                                  pnriesgo, psseguro, clav, pcapital, pnmovimi,
                                                  NULL, 0);

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      RETURN 0;
   END f_calculo_capital_calculado;

/*************************************************************************
   FUNCTION  f_validacion_cobliga
******************************************************************************/
   FUNCTION f_validacion_cobliga(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      pcgarant IN NUMBER,
      paccion IN VARCHAR2,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pmensa IN OUT VARCHAR2,
      pnmovima NUMBER DEFAULT 1)
      RETURN NUMBER IS
      CURSOR garantias(
         p_sseguro IN NUMBER,
         p_nriesgo IN NUMBER,
         p_nmovimi IN NUMBER,
         p_cgarant IN NUMBER,
         p_nmovima IN NUMBER) IS
         SELECT cgarant, ctipgar, cobliga, icapital, pdtocom, iprianu, precarg, iextrap,
                finiefe
           FROM solgaranseg
          WHERE ssolicit = p_sseguro
            AND nriesgo = p_nriesgo
            AND cgarant = p_cgarant;

      num_err        NUMBER := 0;
      gpro_reg       garanpro%ROWTYPE;
      seg_reg        solseguros%ROWTYPE;
      vcobliga       solgaranseg.cobliga%TYPE;
      vicapital      solgaranseg.icapital%TYPE;
      vpdtocom       solgaranseg.pdtocom%TYPE;
      viprianu       solgaranseg.iprianu%TYPE;
      vprecarg       solgaranseg.precarg%TYPE;
      viextrap       solgaranseg.iextrap%TYPE;
      ex_update      EXCEPTION;
      vicapital_bck  NUMBER;
      tipo           NUMBER;
      mens           NUMBER;
      num_err2       NUMBER;
   BEGIN
      -- Bug 9699 - APD - 23/04/2009 - primero se ha de buscar para la actividad en concreto
      -- y si no se encuentra nada ir a buscar a GARANPRO para la actividad cero
      BEGIN
         SELECT *
           INTO gpro_reg
           FROM garanpro
          WHERE cgarant = pcgarant
            AND sproduc = psproduc
            AND cactivi = pcactivi;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            SELECT *
              INTO gpro_reg
              FROM garanpro
             WHERE cgarant = pcgarant
               AND sproduc = psproduc
               AND cactivi = 0;
      END;

      -- Bug 9699 - APD - 23/04/2009 - Fin
      SELECT *
        INTO seg_reg
        FROM solseguros
       WHERE ssolicit = psseguro;

      FOR c IN garantias(psseguro, pnriesgo, pnmovimi, pcgarant, pnmovima) LOOP
         vcobliga := c.cobliga;
         vicapital := c.icapital;
         vpdtocom := c.pdtocom;
         viprianu := c.iprianu;
         vprecarg := c.precarg;
         viextrap := c.iextrap;

         IF c.ctipgar = 2
            AND c.cobliga <> 1
            AND f_validar_edad(psseguro, pnriesgo, psproduc, pcactivi, c.cgarant) = 0 THEN
            --validamos la edad, y solo marcamos aquella que cumplen la edad.
            -- no devolvemos el error si no que las que ni cumplen no se marcan
            vcobliga := 1;
            num_err := 101656;   --error pero continuamos
            RAISE ex_update;
         END IF;

         IF c.cobliga = 1 THEN
            tipo := f_prod_ahorro(seg_reg.sproduc);

            -- Bug 9699 - APD - 23/04/2009 - en lugar de coger la acticad de la tabla seguros, llamar a la función pac_seguros.ff_get_actividad
            IF tipo = 1
               AND seg_reg.cforpag = 0
               AND f_pargaranpro_v(seg_reg.cramo, seg_reg.cmodali, seg_reg.ctipseg,
                                   seg_reg.ccolect,
                                   pac_seguros.ff_get_actividad(psseguro, pnriesgo, 'SOL'),
                                   c.cgarant, 'TIPO') = 4 THEN
               vcobliga := 0;
               vicapital := NULL;
               viprianu := NULL;
               num_err := 151242;
               RAISE ex_update;
            END IF;

            -- Bug 9699 - APD - 23/04/2009 - fin

            -- Bug 9699 - APD - 23/04/2009 - en lugar de coger la acticad de la tabla seguros, llamar a la función pac_seguros.ff_get_actividad
            num_err := f_valida_incompatibles(c.cgarant, c.cobliga, seg_reg.sseguro, pnriesgo,
                                              seg_reg.cramo, seg_reg.cmodali, seg_reg.ctipseg,
                                              seg_reg.ccolect,
                                              pac_seguros.ff_get_actividad(psseguro, pnriesgo,
                                                                           'SOL'),
                                              pmensa);

            -- Bug 9699 - APD - 23/04/2009 - fin
            IF num_err = 0 THEN
               -- Bug 9699 - APD - 23/04/2009 - en lugar de coger la acticad de la tabla seguros, llamar a la función pac_seguros.ff_get_actividad
               num_err := f_marcar_dep_obliga(paccion, psproduc,
                                              pac_seguros.ff_get_actividad(psseguro, pnriesgo,
                                                                           'SOL'),
                                              c.cgarant, psseguro, pnriesgo, pnmovimi, pmensa,
                                              1);
               -- Bug 9699 - APD - 23/04/2009 - fin

               -- Bug 9699 - APD - 23/04/2009 - en lugar de coger la acticad de la tabla seguros, llamar a la función pac_seguros.ff_get_actividad
               num_err := f_valida_dependencias(paccion, psproduc, seg_reg.cramo,
                                                seg_reg.cmodali, seg_reg.ctipseg,
                                                seg_reg.ccolect,
                                                pac_seguros.ff_get_actividad(psseguro,
                                                                             pnriesgo, 'SOL'),
                                                psseguro, pnriesgo, pnmovimi, c.cgarant,
                                                pmensa, 1);

               -- Bug 9699 - APD - 23/04/2009 - fin
               IF num_err = 0 THEN   --valida_dependencias
                  num_err := f_validar_edad(psseguro, pnriesgo, psproduc, pcactivi, c.cgarant);

                  IF num_err <> 0 THEN   -- si falla la edad
                     --tipo de garantia
                     IF c.ctipgar = 2 THEN
                        vcobliga := 0;   --ya no son obligatorias
                        num_err := 0;
                        RAISE ex_update;
                     ELSE
                        vcobliga := 0;
                        num_err := 140468;
                        RAISE ex_update;
                     END IF;
                  ELSE
                     IF gpro_reg.ctipcap = 1 THEN   --capital fijo
                        vicapital := gpro_reg.icapmax;
                     ELSE
                        -- Bug 9699 - APD - 23/04/2009 - en lugar de coger la acticad de la tabla seguros, llamar a la función pac_seguros.ff_get_actividad
                        num_err :=
                           f_valida_dependencias_k(paccion, psseguro, pnriesgo, pnmovimi,
                                                   c.cgarant, psproduc,
                                                   pac_seguros.ff_get_actividad(psseguro,
                                                                                pnriesgo,
                                                                                'SOL'),
                                                   1);
                        -- Bug 9699 - APD - 23/04/2009 - fin
                     --capturamos el error pero se utiliza más tarde;
                     END IF;

                     IF gpro_reg.ctipcap = 4 THEN
                        vicapital := 0;
                     END IF;

                     IF gpro_reg.ctipcap = 5 THEN
                        num_err2 := f_calculo_capital_calculado(c.finiefe, psseguro, pcactivi,
                                                                c.cgarant, pnriesgo, pnmovimi,
                                                                1, vicapital);

                        IF num_err2 <> 0 THEN
                           vicapital := 0;
                        END IF;

                        UPDATE solgaranseg
                           SET icapital = vicapital
                         WHERE ssolicit = psseguro
                           AND nriesgo = pnriesgo
                           AND cgarant = pcgarant;
                     END IF;

                     IF num_err = 0 THEN
                        -- Bug 9699 - APD - 23/04/2009 - en lugar de coger la acticad de la tabla seguros, llamar a la función pac_seguros.ff_get_actividad
                        num_err :=
                           f_validar_capital_max_depen
                                                     (psseguro, pnriesgo, pnmovimi, pcgarant,
                                                      c.cgarant,
                                                      pac_seguros.ff_get_actividad(psseguro,
                                                                                   pnriesgo,
                                                                                   'SOL'),
                                                      1);
                     -- Bug 9699 - APD - 23/04/2009 - fin
                     END IF;

                     IF gpro_reg.ctipcap = 7 THEN
                        num_err := f_cargar_lista_valores;
                     END IF;

                     IF gpro_reg.cdtocom = 1
                        AND c.pdtocom IS NULL THEN
                        vpdtocom := seg_reg.pdtocom;
                     END IF;
                  END IF;
               ELSE
                  RAISE ex_update;
               END IF;
            ELSE
               RAISE ex_update;
            END IF;
         ELSE   --des-seleccionamos
            -- ponemos todas las primas a null del seguro
            UPDATE solgaranseg
               SET iprianu = NULL
             WHERE ssolicit = psseguro
               AND nriesgo = pnriesgo;

            vicapital_bck := c.icapital;
            vicapital := NULL;
            -- Bug 9699 - APD - 23/04/2009 - en lugar de coger la acticad de la tabla seguros, llamar a la función pac_seguros.ff_get_actividad
            num_err := f_valida_dependencias(paccion, psproduc, seg_reg.cramo, seg_reg.cmodali,
                                             seg_reg.ctipseg, seg_reg.ccolect,
                                             pac_seguros.ff_get_actividad(psseguro, pnriesgo,
                                                                          'SOL'),
                                             psseguro, pnriesgo, pnmovimi, c.cgarant, pmensa,
                                             1);

            -- Bug 9699 - APD - 23/04/2009 - fin
            IF num_err = 0 THEN   --valida dependencias
               IF gpro_reg.ctipcap = 7 THEN
                  num_err := f_borra_lista;
               END IF;

               IF gpro_reg.ctipcap = 5 THEN
                  vicapital := NULL;
               END IF;

               -- Bug 9699 - APD - 23/04/2009 - en lugar de coger la acticad de la tabla seguros, llamar a la función pac_seguros.ff_get_actividad
               num_err := f_marcar_dep_obliga(paccion, psproduc,
                                              pac_seguros.ff_get_actividad(psseguro, pnriesgo,
                                                                           'SOL'),
                                              c.cgarant, psseguro, pnriesgo, pnmovimi, pmensa,
                                              1);
               -- Bug 9699 - APD - 23/04/2009 - fin
               vicapital := NULL;
               viprianu := NULL;
               vprecarg := NULL;
               vpdtocom := NULL;
               viextrap := NULL;
            ELSE
               vicapital := vicapital_bck;
               RAISE ex_update;
            END IF;
         END IF;   --cobliga =1
      END LOOP;

      RETURN 0;
   EXCEPTION
      WHEN ex_update THEN
         UPDATE solgaranseg
            SET cobliga = vcobliga,
                icapital = vicapital,
                pdtocom = vpdtocom
          WHERE ssolicit = psseguro
            AND nriesgo = pnriesgo
            AND cgarant = pcgarant;

         COMMIT;
         RETURN num_err;
   END f_validacion_cobliga;

/*************************************************************************
   FUNCTION  f_valida_incompatibles
******************************************************************************/
   FUNCTION f_valida_incompatibles(
      pcgarant IN NUMBER,
      pcobliga IN NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      pcactivi IN NUMBER,
      pmensa IN OUT VARCHAR2)
      RETURN NUMBER IS
      CURSOR otras_gar IS
         SELECT cgarant, cobliga
           FROM solgaranseg
          WHERE ssolicit = psseguro
            AND nriesgo = pnriesgo
            AND cgarant <> pcgarant;

      aux_garan      incompgaran.cgarant%TYPE;   -- NUMBER(4);
   BEGIN
      IF pcobliga = 1 THEN
         pmensa := NULL;

         FOR c IN otras_gar LOOP
            DECLARE
               v_cactivi      garanpro.cactivi%TYPE;   --NUMBER(4);
            BEGIN
               --BUG9748 - 09/04/2009 - JTS - IAX -ACTIVIDAD - Selects contra INCOMPAGARAN, tener en cuenta la actividad
               SELECT DECODE(COUNT(*), 0, 0, pcactivi)
                 INTO v_cactivi
                 FROM garanpro
                WHERE cramo = pcramo
                  AND ccolect = pccolect
                  AND cmodali = pcmodali
                  AND cgarant = pcgarant
                  AND cactivi = pcactivi;

               --Fi BUG9748
               SELECT cgarant
                 INTO aux_garan
                 FROM incompgaran
                WHERE cramo = pcramo
                  AND cmodali = pcmodali
                  AND ctipseg = pctipseg
                  AND ccolect = pccolect
                  AND cactivi = v_cactivi
                  AND cgarant = c.cgarant
                  AND cgarinc = pcgarant;

               pmensa := ' (' || c.cgarant || ' - ' || pcgarant || ' )';
               RETURN 100791;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  NULL;
            END;
         END LOOP;
      END IF;

      RETURN 0;
   END f_valida_incompatibles;

/*************************************************************************
   FUNCTION  f_marcar_dep_obliga
******************************************************************************/
   FUNCTION f_marcar_dep_obliga(
      paccion VARCHAR2,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      pmensa IN OUT VARCHAR2,
      pnmovima IN NUMBER)
      RETURN NUMBER IS
      -- Bug 9699 - APD - 23/04/2009 - primero se ha de buscar para la actividad en concreto
      -- y si no se encuentra nada ir a buscar a GARANPRO para la actividad cero
      CURSOR garantias IS
         SELECT cgarant
           FROM garanpro
          WHERE sproduc = psproduc
            AND cgardep = pcgarant
            AND cactivi = pcactivi
            AND ctipgar = 4
         UNION
         SELECT cgarant
           FROM garanpro
          WHERE sproduc = psproduc
            AND cgardep = pcgarant
            AND cactivi = 0
            AND ctipgar = 4
            AND NOT EXISTS(SELECT cgarant
                             FROM garanpro
                            WHERE sproduc = psproduc
                              AND cgardep = pcgarant
                              AND cactivi = pcactivi
                              AND ctipgar = 4);

      -- Bug 9699 - APD - 23/04/2009 - Fin
      num_err        NUMBER;
   BEGIN
      FOR c IN garantias LOOP
         IF paccion = 'SEL' THEN
            UPDATE solgaranseg
               SET cobliga = 1
             WHERE ssolicit = psseguro
               AND nriesgo = pnriesgo
               AND cgarant = c.cgarant;
         ELSE
            UPDATE solgaranseg
               SET cobliga = 0
             WHERE ssolicit = psseguro
               AND nriesgo = pnriesgo
               AND cgarant = c.cgarant;
         END IF;

         num_err := f_validacion_cobliga(psseguro, pnriesgo, pnmovimi, c.cgarant, paccion,
                                         psproduc, pcactivi, pmensa, pnmovima);
      END LOOP;

      COMMIT;
      -- hay que hacer la validación de incompatibles.
      RETURN 0;
   END f_marcar_dep_obliga;

/*************************************************************************
   FUNCTION  f_valida_dependencias
******************************************************************************/
   FUNCTION f_valida_dependencias(
      paccion VARCHAR2,
      psproduc IN NUMBER,
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      pcactivi IN NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      pcgarant IN NUMBER,
      pmensa IN OUT VARCHAR2,
      pnmovima IN NUMBER DEFAULT 1)
      RETURN NUMBER IS
      num_err        NUMBER := 0;
      garpro         garanpro%ROWTYPE;
      estgar         solgaranseg%ROWTYPE;
      vcobliga       solgaranseg.cobliga%TYPE := 0;
      ex_update      EXCEPTION;
      vtrotgar       VARCHAR2(40);
   BEGIN
      num_err := f_valida_obligatorias(paccion, psproduc, pcramo, pcmodali, pctipseg,
                                       pccolect, pcactivi, psseguro, pnriesgo, pnmovimi,
                                       pcgarant, pmensa, pnmovima);

      -- Bug 9699 - APD - 23/04/2009 - primero se ha de buscar para la actividad en concreto
      -- y si no se encuentra nada ir a buscar a GARANPRO para la actividad cero
      BEGIN
         SELECT *
           INTO garpro
           FROM garanpro
          WHERE sproduc = psproduc
            AND cactivi = pcactivi
            AND cgarant = pcgarant;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            SELECT *
              INTO garpro
              FROM garanpro
             WHERE sproduc = psproduc
               AND cactivi = 0
               AND cgarant = pcgarant;
      END;

      -- Bug 9699 - APD - 23/04/2009 - Fin
      SELECT *
        INTO estgar
        FROM solgaranseg
       WHERE ssolicit = psseguro
         AND nriesgo = pnriesgo
         AND cgarant = pcgarant;

      IF paccion = 'SEL'
         AND num_err = 0 THEN
         IF garpro.cgardep IS NOT NULL THEN
            SELECT NVL(cobliga, 0)
              INTO vcobliga
              FROM solgaranseg
             WHERE ssolicit = psseguro
               AND nriesgo = pnriesgo
               AND cgarant = garpro.cgardep;

            IF vcobliga = 0 THEN
               num_err := 108388;

               --BUG8916-06/02/2009-XVILA: s'afegeix el ròtul de la garantia
               BEGIN
                  SELECT trotgar
                    INTO vtrotgar
                    FROM garangen
                   WHERE cidioma = NVL(f_usu_idioma, 1)
                     AND cgarant = garpro.cgardep;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     vtrotgar := NULL;
               END;

               pmensa := vtrotgar;
               --BUG8916-06/02/2009-XVILA: s'afegeix el ròtul de la garantia
               RAISE ex_update;
            END IF;
         END IF;
      ELSIF paccion = 'DESEL'
            AND num_err = 0 THEN
         IF estgar.ctipgar = 4 THEN
            SELECT NVL(cobliga, 0)
              INTO vcobliga
              FROM solgaranseg
             WHERE ssolicit = psseguro
               AND nriesgo = pnriesgo
               AND cgarant = garpro.cgardep;

            IF vcobliga = 1 THEN
               num_err := 108389;
               pmensa := garpro.cgardep;
               RAISE ex_update;
            END IF;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN ex_update THEN
         UPDATE solgaranseg
            SET cobliga = vcobliga
          WHERE ssolicit = psseguro
            AND nriesgo = pnriesgo
            AND cgarant = pcgarant;

         RETURN num_err;
   END f_valida_dependencias;

/*************************************************************************
   FUNCTION  f_valida_obligatorias
******************************************************************************/
   FUNCTION f_valida_obligatorias(
      paccion VARCHAR2,
      psproduc IN NUMBER,
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      pcactivi IN NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      pcgarant IN NUMBER,
      pmensa IN OUT VARCHAR2,
      pnmovima IN NUMBER DEFAULT 1)
      RETURN NUMBER IS
      CURSOR garantias_hijas(pcpargar IN VARCHAR2, pcvalpar IN NUMBER) IS
         -- Bug 9699 - APD - 08/04/2009 - primero se ha de buscar para la actividad en concreto
         -- y si no se encuentra nada ir a buscar a PARGARANPRO para la actividad cero
         SELECT   cgarant
             FROM pargaranpro
            WHERE cmodali = pcmodali
              AND cramo = pcramo
              AND ctipseg = pctipseg
              AND ccolect = pccolect
              AND cactivi = pcactivi
              AND cpargar = pcpargar
              AND cvalpar = pcvalpar
         UNION
         SELECT   cgarant
             FROM pargaranpro
            WHERE cmodali = pcmodali
              AND cramo = pcramo
              AND ctipseg = pctipseg
              AND ccolect = pccolect
              AND cactivi = 0
              AND cpargar = pcpargar
              AND cvalpar = pcvalpar
              AND NOT EXISTS(SELECT cgarant
                               FROM pargaranpro
                              WHERE cmodali = pcmodali
                                AND cramo = pcramo
                                AND ctipseg = pctipseg
                                AND ccolect = pccolect
                                AND cactivi = pcactivi
                                AND cpargar = pcpargar
                                AND cvalpar = pcvalpar)
         ORDER BY cgarant;

      -- Bug 9699 - APD - 08/04/2009 - Fin
      CURSOR garantias_hijas_obli(psproduc IN NUMBER, pcgarant IN NUMBER) IS
         SELECT DISTINCT (g.cgarant) cgarant, g.ctipgar ctipgar, g.cpardep cpardep,
                         g.cvalpar cvalpar
                    FROM garanpro g, pargaranpro pg
                   WHERE g.cramo = pg.cramo
                     AND g.cmodali = pg.cmodali
                     AND g.ctipseg = pg.ctipseg
                     AND g.ccolect = pg.ccolect
                     AND g.cactivi = pg.cactivi
                     AND g.cpardep = pg.cpargar
                     AND g.cvalpar = pg.cvalpar
                     AND g.sproduc = psproduc
                     AND pg.cgarant = pcgarant;

      CURSOR garantias_padres(pcpargar IN VARCHAR2, pcvalpar IN NUMBER) IS
         -- Bug 9699 - APD - 08/04/2009 - primero se ha de buscar para la actividad en concreto
         -- y si no se encuentra nada ir a buscar a PARGARANPRO para la actividad cero
         SELECT   cgarant
             FROM pargaranpro
            WHERE cmodali = pcmodali
              AND cramo = pcramo
              AND ctipseg = pctipseg
              AND ccolect = pccolect
              AND cactivi = pcactivi
              AND cpargar = pcpargar
              AND cvalpar = pcvalpar
         UNION
         SELECT   cgarant
             FROM pargaranpro
            WHERE cmodali = pcmodali
              AND cramo = pcramo
              AND ctipseg = pctipseg
              AND ccolect = pccolect
              AND cactivi = 0
              AND cpargar = pcpargar
              AND cvalpar = pcvalpar
              AND NOT EXISTS(SELECT cgarant
                               FROM pargaranpro
                              WHERE cmodali = pcmodali
                                AND cramo = pcramo
                                AND ctipseg = pctipseg
                                AND ccolect = pccolect
                                AND cactivi = pcactivi
                                AND cpargar = pcpargar
                                AND cvalpar = pcvalpar)
         ORDER BY cgarant;

      -- Bug 9699 - APD - 08/04/2009 - Fin
      CURSOR garantias_marcadas IS
         SELECT cgarant, cobliga, ssolicit, nriesgo
           FROM solgaranseg
          WHERE ssolicit = psseguro
            AND nriesgo = pnriesgo
            AND cobliga = 1;

      estgar         solgaranseg%ROWTYPE;
      garpro         garanpro%ROWTYPE;
      salir          BOOLEAN := FALSE;
      num_err        NUMBER := 0;
      ex_update      EXCEPTION;
      v_cobliga      solgaranseg.cobliga%TYPE;   --NUMBER(1);
   BEGIN
      SELECT *
        INTO estgar
        FROM solgaranseg
       WHERE cgarant = pcgarant
         AND ssolicit = psseguro
         AND nriesgo = pnriesgo;

      -- Bug 9699 - APD - 23/04/2009 - primero se ha de buscar para la actividad en concreto
      -- y si no se encuentra nada ir a buscar a GARANPRO para la actividad cero
      BEGIN
         SELECT *
           INTO garpro
           FROM garanpro
          WHERE sproduc = psproduc
            AND cactivi = pcactivi
            AND cgarant = pcgarant;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            SELECT *
              INTO garpro
              FROM garanpro
             WHERE sproduc = psproduc
               AND cactivi = 0
               AND cgarant = pcgarant;
      END;

      v_cobliga := estgar.cobliga;

      IF paccion = 'SEL'
         AND estgar.cobliga = 1 THEN
         IF estgar.ctipgar IN(5, 6) THEN
            FOR c IN garantias_hijas(garpro.cpardep, garpro.cvalpar) LOOP
               --Miramos si todas las garantias padre estan seleccionadas
               FOR g IN garantias_marcadas LOOP
                  IF c.cgarant = g.cgarant THEN
                     salir := TRUE;
                  END IF;
               END LOOP;

               IF salir THEN
                  EXIT;   --salimos porque ya hemos encontrado una
               END IF;
            END LOOP;

            IF NOT salir THEN
               num_err := 108388;
               --Falta seleccionar alguna garantia de la cual depende
               v_cobliga := 0;
               RAISE ex_update;
            END IF;
         ELSE
            --Miramos si es padre de una garantia obligatoria
            FOR c IN garantias_hijas_obli(psproduc, pcgarant) LOOP
               IF c.ctipgar = 6 THEN
                  FOR g IN garantias_marcadas LOOP
                     num_err := f_validacion_cobliga(g.ssolicit, g.nriesgo, 1, g.cgarant,
                                                     'SEL', psproduc, pcactivi, pmensa, 1);

                     IF num_err <> 0 THEN
                        RAISE ex_update;
                     END IF;
                  END LOOP;
               END IF;
            END LOOP;
         END IF;
      ELSE   --deseleccion
         IF estgar.ctipgar = 6 THEN
            FOR c IN garantias_hijas(garpro.cpardep, garpro.cvalpar) LOOP
               --Miramos las garantias padres si están deseleccionadas
               FOR g IN garantias_marcadas LOOP
                  IF c.cgarant = g.cgarant THEN
                     num_err := 108389;
                     pmensa := g.cgarant;
                     v_cobliga := 0;
                     RAISE ex_update;
                  END IF;
               END LOOP;
            END LOOP;
         ELSE
            FOR c IN garantias_hijas_obli(psproduc, pcgarant) LOOP
               IF c.ctipgar IN(5, 6) THEN
                  FOR g IN garantias_padres(c.cpardep, c.cvalpar) LOOP
                     FOR h IN garantias_marcadas LOOP
                        UPDATE solgaranseg
                           SET cobliga = 1
                         WHERE ssolicit = h.ssolicit
                           AND nriesgo = h.nriesgo
                           AND cgarant = h.cgarant;

                        num_err := f_validacion_cobliga(h.ssolicit, h.nriesgo, 1, h.cgarant,
                                                        'SEL', psproduc, pcactivi, pmensa, 1);

                        IF num_err <> 0 THEN
                           RAISE ex_update;
                        END IF;
                     END LOOP;
                  END LOOP;

                  FOR h IN garantias_marcadas LOOP
                     IF c.cgarant = h.cgarant THEN
                        UPDATE solgaranseg
                           SET cobliga = 0
                         WHERE ssolicit = h.ssolicit
                           AND nriesgo = h.nriesgo
                           AND cgarant = h.cgarant;

                        num_err := f_validacion_cobliga(h.ssolicit, h.nriesgo, 1, h.cgarant,
                                                        'DESEL', psproduc, pcactivi, pmensa, 1);

                        IF num_err <> 0 THEN
                           RAISE ex_update;
                        END IF;
                     END IF;
                  END LOOP;
               END IF;
            END LOOP;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN ex_update THEN
         UPDATE solgaranseg
            SET cobliga = v_cobliga
          WHERE ssolicit = psseguro
            AND nriesgo = pnriesgo
            AND cgarant = pcgarant;

         RETURN num_err;
   END f_valida_obligatorias;

/*************************************************************************
   FUNCTION  f_validar_edad
******************************************************************************/
   FUNCTION f_validar_edad(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER)
      RETURN NUMBER IS
      vfefecto       DATE;
      vsperson       per_personas.sperson%TYPE;
      vnedamic       productos.nedamic%TYPE;
      vnedamac       productos.nedamac%TYPE;
      vciedmic       productos.ciedmic%TYPE;
      vciedmac       productos.ciedmic%TYPE;
      vnsedmac       productos.nsedmac%TYPE;
      vcobjase       productos.cobjase%TYPE;
      vfnacimi       DATE;
      num_err        NUMBER;
   BEGIN
      -- Bug 9699 - APD - 23/04/2009 - primero se ha de buscar para la actividad en concreto
      -- y si no se encuentra nada ir a buscar a GARANPRO para la actividad cero
      BEGIN
         SELECT g.nedamic, g.nedamac, g.ciedmic, g.ciedmac, cobjase
           INTO vnedamic, vnedamac, vciedmic, vciedmac, vcobjase
           FROM garanpro g, productos p
          WHERE g.sproduc = psproduc
            AND g.cactivi = pcactivi
            AND g.cgarant = pcgarant
            AND g.sproduc = p.sproduc;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            SELECT g.nedamic, g.nedamac, g.ciedmic, g.ciedmac, cobjase
              INTO vnedamic, vnedamac, vciedmic, vciedmac, vcobjase
              FROM garanpro g, productos p
             WHERE g.sproduc = psproduc
               AND g.cactivi = 0
               AND g.cgarant = pcgarant
               AND g.sproduc = p.sproduc;
      END;

      -- Bug 9699 - APD - 23/04/2009 - Fin
      IF vcobjase = 1 THEN
         SELECT r.sperson, fnacimi, s.falta
           INTO vsperson, vfnacimi, vfefecto
           FROM solriesgos r, solseguros s
          WHERE r.ssolicit = psseguro
            AND r.nriesgo = pnriesgo
            AND r.ssolicit = s.ssolicit;

         --         num_err := f_control_edat(
           --                     vsperson, vfefecto, NVL(vnedamic, 0), NVL(vciedmic, 0),
             --                   NVL(vnedamac, 999), NVL(vciedmac, 0), NULL, NULL, NULL
              --               );
         IF vfnacimi IS NOT NULL THEN
            num_err := f_control_edat_sim(vfnacimi, vfefecto, NVL(vnedamic, 0),
                                          NVL(vciedmic, 0), NVL(vnedamac, 999),
                                          NVL(vciedmac, 0));

            IF num_err <> 0 THEN
               RETURN num_err;
            END IF;
         END IF;
      /*********** falta las validaciones de 2 cabeza **************/
      END IF;

      RETURN 0;
   END f_validar_edad;

   /*************************************************************************
      FUNCTION  f_validar_capital_max_depen
   ******************************************************************************/
   FUNCTION f_validar_capital_max_depen(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      pcgarant IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pnmovima IN NUMBER DEFAULT 1)
      RETURN NUMBER IS
      garpro         garanpro%ROWTYPE;
      capital        NUMBER;
   BEGIN
      NULL;
      RETURN 0;
   END f_validar_capital_max_depen;

/*************************************************************************
   FUNCTION  f_valida_dependencias_k
******************************************************************************/
   FUNCTION f_valida_dependencias_k(
      paccion IN VARCHAR2,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      pcgarant IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pnmovima IN NUMBER DEFAULT 1)
      RETURN NUMBER IS
      garpro         garanpro%ROWTYPE;
      estgar         solgaranseg%ROWTYPE;
      capital_principal NUMBER;
      capital_dependiente NUMBER;
      capital        NUMBER;
      capmax         NUMBER;
   BEGIN
      -- Bug 9699 - APD - 23/04/2009 - primero se ha de buscar para la actividad en concreto
      -- y si no se encuentra nada ir a buscar a GARANPRO para la actividad cero
      BEGIN
         SELECT *
           INTO garpro
           FROM garanpro
          WHERE sproduc = psproduc
            AND cactivi = pcactivi
            AND cgarant = pcgarant;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            SELECT *
              INTO garpro
              FROM garanpro
             WHERE sproduc = psproduc
               AND cactivi = 0
               AND cgarant = pcgarant;
      END;

      SELECT *
        INTO estgar
        FROM solgaranseg
       WHERE ssolicit = psseguro
         AND nriesgo = pnriesgo
         AND cgarant = pcgarant;

      capital := estgar.icapital;

      IF garpro.ctipcap = 3
         AND garpro.cgardep IS NOT NULL THEN
         SELECT NVL(icapital, 0)
           INTO capital_principal
           FROM solgaranseg
          WHERE ssolicit = psseguro
            AND nriesgo = pnriesgo
            AND cgarant = garpro.cgardep;

         /*si hay más de una por nmovima que hacemos*/
         capital_dependiente := capital_principal *(NVL(garpro.pcapdep, 0) / 100);
         capmax := f_capital_maximo_garantia(psproduc, pcactivi, pcgarant);
         capital := LEAST(GREATEST(capital_dependiente, NVL(garpro.icapmin, 0)),
                          NVL(capmax, GREATEST(capital_dependiente, NVL(garpro.icapmin, 0))));
      ELSIF garpro.ctipcap = 6
            AND garpro.cgardep IS NOT NULL THEN
         SELECT NVL(icapital, 0)
           INTO capital_principal
           FROM solgaranseg
          WHERE ssolicit = psseguro
            AND nriesgo = pnriesgo
            AND cgarant = garpro.cgardep;

         IF estgar.icapital IS NOT NULL THEN
            capmax := f_capital_maximo_garantia(psproduc, pcactivi, pcgarant);
            capital_dependiente := capital_principal *(NVL(garpro.pcapdep, 0) / 100);
            capmax := LEAST(GREATEST(capital_dependiente, NVL(garpro.icapmin, 0)),
                            NVL(capmax, GREATEST(capital_dependiente, NVL(garpro.icapmin, 0))));
            capital := LEAST(estgar.icapital, capmax);
         ELSE
            capmax := f_capital_maximo_garantia(psproduc, pcactivi, pcgarant);
            capital_dependiente := capital_principal *(NVL(garpro.pcapdep, 0) / 100);
            capital := LEAST(GREATEST(capital_dependiente, NVL(garpro.icapmin, 0)),
                             NVL(capmax,
                                 GREATEST(capital_dependiente, NVL(garpro.icapmin, 0))));
            capital := LEAST(capital, capmax);
         END IF;
      END IF;

      UPDATE solgaranseg
         SET icapital = capital
       WHERE cgarant = pcgarant
         AND nriesgo = pnriesgo
         AND ssolicit = psseguro;

      RETURN 0;
   END f_valida_dependencias_k;

/*************************************************************************
   FUNCTION  f_cargar_lista_valores
******************************************************************************/
   FUNCTION f_cargar_lista_valores
      RETURN NUMBER IS
   BEGIN
      RETURN 0;
   END f_cargar_lista_valores;

/*************************************************************************
   FUNCTION  f_borra_lista
******************************************************************************/
   FUNCTION f_borra_lista
      RETURN NUMBER IS
   BEGIN
      RETURN 0;
   END f_borra_lista;

/*************************************************************************
   FUNCTION  f_capital_maximo_garantia
******************************************************************************/
   FUNCTION f_capital_maximo_garantia(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER)
      RETURN NUMBER IS
      garpro         garanpro%ROWTYPE;
      vicapmax       garanpro.icapmax%TYPE;
   BEGIN
      -- Bug 9699 - APD - 23/04/2009 - primero se ha de buscar para la actividad en concreto
      -- y si no se encuentra nada ir a buscar a GARANPRO para la actividad cero
      BEGIN
         SELECT *
           INTO garpro
           FROM garanpro
          WHERE sproduc = psproduc
            AND cgarant = pcgarant
            AND cactivi = pcactivi;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            SELECT *
              INTO garpro
              FROM garanpro
             WHERE sproduc = psproduc
               AND cgarant = pcgarant
               AND cactivi = 0;
      END;

      -- Bug 9699 - APD - 23/04/2009 - Fin

      -- Utilizamos los campos garanpro.ip_icapmax, y garanpro.ip_icapmin porque el capital máximo
      -- puede ir cambiando ON-LINE (depende del tipo de capital, etc...)
      IF garpro.ccapmax = 1 THEN   -- Fijo
         RETURN garpro.icapmax;
      ELSIF garpro.ccapmax = 2 THEN   -- Depende de otro
         -- Bug 9699 - APD - 23/04/2009 - primero se ha de buscar para la actividad en concreto
         -- y si no se encuentra nada ir a buscar a GARANPRO para la actividad cero
         BEGIN
            SELECT icapmax
              INTO vicapmax
              FROM garanpro
             WHERE sproduc = psproduc
               AND cgarant = garpro.cgardep
               AND cactivi = pcactivi;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               SELECT icapmax
                 INTO vicapmax
                 FROM garanpro
                WHERE sproduc = psproduc
                  AND cgarant = garpro.cgardep
                  AND cactivi = 0;
         END;

         -- Bug 9699 - APD - 23/04/2009 - Fin
         RETURN vicapmax;
      ELSE   -- Ilimitado
         RETURN NULL;
      END IF;
   END f_capital_maximo_garantia;

/*************************************************************************
   FUNCTION  f_valida_capital
******************************************************************************/
   FUNCTION f_valida_capital(
      paccion IN VARCHAR2,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      pcgarant IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pmensa IN OUT VARCHAR2,
      pnmovima IN NUMBER DEFAULT 1)
      RETURN NUMBER IS
      garpro         garanpro%ROWTYPE;
      estgar         solgaranseg%ROWTYPE;
      capmax         NUMBER;
      capmin         NUMBER;
      capital        NUMBER;
      vcforpag       solseguros.cforpag%TYPE;
      num_err        NUMBER;
   BEGIN
      -- Bug 9699 - APD - 23/04/2009 - primero se ha de buscar para la actividad en concreto
      -- y si no se encuentra nada ir a buscar a GARANPRO para la actividad cero
      BEGIN
         SELECT *
           INTO garpro
           FROM garanpro
          WHERE sproduc = psproduc
            AND cactivi = pcactivi
            AND cgarant = pcgarant;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            SELECT *
              INTO garpro
              FROM garanpro
             WHERE sproduc = psproduc
               AND cactivi = 0
               AND cgarant = pcgarant;
      END;

      -- Bug 9699 - APD - 23/04/2009 - Fin
      SELECT *
        INTO estgar
        FROM solgaranseg
       WHERE ssolicit = psseguro
         AND nriesgo = pnriesgo
         AND cgarant = pcgarant;

      -- pongo siempre la prima anual a 0
      UPDATE solgaranseg
         SET iprianu = NULL
       WHERE ssolicit = psseguro
         AND nriesgo = pnriesgo;

      SELECT cforpag
        INTO vcforpag
        FROM solseguros
       WHERE ssolicit = psseguro;

      -- incializamos la variable capital
      capital := estgar.icapital;

      IF estgar.cobliga = 1
         AND estgar.icapital IS NOT NULL THEN
         --verificar que no supere ni el máximo ni el mínimo
         num_err := f_validar_capitalmin(psproduc, pcactivi, vcforpag, estgar.cgarant,
                                         estgar.icapital, capmin);
         pmensa := capmin;

         IF num_err <> 0 THEN
            RETURN num_err;
         END IF;

         capmax := f_capital_maximo_garantia(psproduc, pcactivi, pcgarant);

         IF (estgar.icapital > capmax
             AND capmax IS NOT NULL)
            OR(estgar.icapital < NVL(garpro.icapmin, 0)) THEN
            pmensa := NVL(garpro.icapmin, 0) || '- ' || capmax;
            RETURN 101681;   -- El capital ha de tener nu valor entre
         ELSIF garpro.ctipcap = 1
               AND estgar.icapital <> capmax THEN
            capital := capmax;
         ELSIF garpro.ctipcap = 4
               AND estgar.icapital > 0 THEN
            capital := 0;
         END IF;
      ELSIF estgar.icapital IS NOT NULL
            AND estgar.cobliga = 0 THEN
         UPDATE solgaranseg
            SET icapital = NULL,
                iprianu = NULL
          WHERE ssolicit = psseguro
            AND nriesgo = pnriesgo
            AND cgarant = pcgarant;

         RETURN 101680;
      ELSIF estgar.icapital IS NULL
            AND estgar.cobliga = 1 THEN
         IF f_prod_ahorro(psproduc) = 1 THEN
            RETURN 151359;
         ELSE
            RETURN 101679;
         END IF;
      END IF;

      UPDATE solgaranseg
         SET icapital = capital,
             iprianu = NULL
       WHERE ssolicit = psseguro
         AND nriesgo = pnriesgo
         AND cgarant = pcgarant;

      num_err := f_valida_dependencias_k(paccion, psseguro, pnriesgo, pnmovimi, pcgarant,
                                         psproduc, pcactivi, pnmovima);

      IF num_err <> 0 THEN
         RETURN num_err;
      ELSE
         num_err := reseleccionar_gar_dependientes(psseguro, pnriesgo, pnmovimi, pcgarant,
                                                   'SEL', psproduc, pcactivi, pmensa,
                                                   pnmovima);

         IF num_err <> 0 THEN
            RETURN num_err;
         END IF;
      END IF;

      RETURN 0;
   END f_valida_capital;

   /*************************************************************************
      FUNCTION  reseleccionar_gar_dependientes
   ******************************************************************************/
   FUNCTION reseleccionar_gar_dependientes(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      pcgarant IN NUMBER,
      paccion IN VARCHAR2,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pmensa IN OUT VARCHAR2,
      pnmovima NUMBER DEFAULT 1)
      RETURN NUMBER IS
      -- Bug 9699 - APD - 23/04/2009 - primero se ha de buscar para la actividad en concreto
      -- y si no se encuentra nada ir a buscar a GARANPRO para la actividad cero
      CURSOR garantias IS
         SELECT e.cgarant, 1 nmovima, g.cgardep, e.cobliga
           FROM solgaranseg e, garanpro g
          WHERE e.ssolicit = psseguro
            AND e.nriesgo = pnriesgo
            AND g.sproduc = psproduc
            AND g.cactivi = pcactivi
            AND g.cgarant = e.cgarant
         UNION
         SELECT e.cgarant, 1 nmovima, g.cgardep, e.cobliga
           FROM solgaranseg e, garanpro g
          WHERE e.ssolicit = psseguro
            AND e.nriesgo = pnriesgo
            AND g.sproduc = psproduc
            AND g.cactivi = 0
            AND g.cgarant = e.cgarant
            AND NOT EXISTS(SELECT e.cgarant, 1 nmovima, g.cgardep, e.cobliga
                             FROM solgaranseg e, garanpro g
                            WHERE e.ssolicit = psseguro
                              AND e.nriesgo = pnriesgo
                              AND g.sproduc = psproduc
                              AND g.cactivi = pcactivi
                              AND g.cgarant = e.cgarant);

      -- Bug 9699 - APD - 23/04/2009 - Fin
      num_err        NUMBER;
   BEGIN
      FOR c IN garantias LOOP
         IF c.cobliga = 1
            AND c.cgardep = pcgarant THEN
            num_err := f_validacion_cobliga(psseguro, pnriesgo, pnmovimi, c.cgarant, 'SEL',
                                            psproduc, pcactivi, pmensa, pnmovima);

            IF num_err <> 0 THEN
               RETURN num_err;
            END IF;
         END IF;
      END LOOP;

      RETURN 0;
   END reseleccionar_gar_dependientes;

   /*************************************************************************
      FUNCTION  f_validar_garantias_al_tarifar
   ******************************************************************************/
   FUNCTION f_validar_garantias_al_tarifar(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pmensa IN OUT VARCHAR2)
      RETURN NUMBER IS
      CURSOR garantias IS
         SELECT cgarant, 1 nmovima
           FROM solgaranseg
          WHERE ssolicit = psseguro
            AND nriesgo = pnriesgo
            AND cobliga = 1;

      num_err        NUMBER;
   BEGIN
      FOR c IN garantias LOOP
         num_err := f_validacion_cobliga(psseguro, pnriesgo, pnmovimi, c.cgarant, 'SEL',
                                         psproduc, pcactivi, pmensa, c.nmovima);

         IF num_err <> 0 THEN
            RETURN num_err;
         END IF;

         num_err := f_valida_capital('SEL', psseguro, pnriesgo, pnmovimi, c.cgarant, psproduc,
                                     pcactivi, pmensa, c.nmovima);

         IF num_err <> 0 THEN
            RETURN num_err;
         END IF;
      END LOOP;

      RETURN 0;
   END f_validar_garantias_al_tarifar;

/*************************************************************************
   FUNCTION  f_validar_garantias
******************************************************************************/
   FUNCTION f_validar_garantias(psseguro IN NUMBER, pnriesgo IN NUMBER, pnmovimi IN NUMBER)
      RETURN NUMBER IS
      num_err        NUMBER;
   BEGIN
      --verificamos que las garantias marcadas han sido tarifadas
      SELECT COUNT(1)
        INTO num_err
        FROM solgaranseg
       WHERE ssolicit = psseguro
         AND nriesgo = pnriesgo
         AND cobliga = 1
         AND iprianu IS NULL;

      IF num_err <> 0 THEN
         RETURN 101689;
      END IF;

      RETURN 0;
   END f_validar_garantias;

/*************************************************************************
   FUNCTION  f_marcar_basicas
******************************************************************************/
   FUNCTION f_marcar_basicas(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER)
      RETURN NUMBER IS
      CURSOR garantias_a_marcar IS
         SELECT cgarant, 1 nmovima, icapital
           FROM solgaranseg
          WHERE ssolicit = psseguro
            AND nriesgo = pnriesgo
            AND ctipgar = 2;

      num_err        NUMBER;
      v_mensa        VARCHAR2(500);
   BEGIN
      -- desmarcamos todas las garantias para que
      -- no tengamos problemas de dependencias
      UPDATE solgaranseg
         SET cobliga = 0,
             iprianu = NULL,
             ipritar = NULL
       WHERE ssolicit = psseguro
         AND nriesgo = pnriesgo
         AND ctipgar = 2;

      UPDATE solgaranseg
         SET cobliga = 0,
             icapital = NULL,
             iprianu = NULL,
             ipritar = NULL
       WHERE ssolicit = psseguro
         AND nriesgo = pnriesgo
         AND ctipgar <> 2;

      FOR c IN garantias_a_marcar LOOP
         --validamos la edad, y solo marcamos aquella que cumplen la edad.
         num_err := f_validar_edad(psseguro, pnriesgo, psproduc, pcactivi, c.cgarant);

         -- no devolvemos el error si no que las que ni cumplen no se marcan
         IF num_err = 0 THEN
            UPDATE solgaranseg
               SET cobliga = 1,
                   icapital = NVL(c.icapital, 0)
             WHERE ssolicit = psseguro
               AND nriesgo = pnriesgo
               AND cgarant = c.cgarant;

            --llamo a la función para que me marque las dependientes
            -- obligatorias de las obligatorias
            num_err := f_validacion_cobliga(psseguro, pnriesgo, pnmovimi, c.cgarant, 'SEL',
                                            psproduc, pcactivi, v_mensa, c.nmovima);

            IF num_err <> 0 THEN
               RETURN num_err;
            END IF;
         END IF;
      END LOOP;

      COMMIT;
      RETURN 0;
   END f_marcar_basicas;

/*************************************************************************
   FUNCTION  f_marcar_completo
******************************************************************************/
   FUNCTION f_marcar_completo(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER)
      RETURN NUMBER IS
      num_err        NUMBER;

      CURSOR garantias IS
         SELECT   cgarant, 1 nmovima, ctipgar, icapital
             FROM solgaranseg
            WHERE ssolicit = psseguro
              AND nriesgo = pnriesgo
         ORDER BY ctipgar;

      v_mensa        VARCHAR2(100);
      vicapital      solgaranseg.icapital%TYPE;   --NUMBER(15, 2);
      v_cactivi      garanpro.cactivi%TYPE;   --NUMBER(4);
   BEGIN
      -- miramos si hay incompatibles, si no hay las marcamos todas,
      --en caso contrario retornamos un error.
      -- Bug 9699 - APD - 23/04/2009 - primero se ha de buscar para la actividad en concreto
      -- y si no se encuentra nada ir a buscar a GARANPRO para la actividad cero

      --BUG9748 - 09/04/2009 - JTS - IAX -ACTIVIDAD - Selects contra INCOMPAGARAN, tener en cuenta la actividad
      SELECT DECODE(COUNT(*), 0, 0, pcactivi)
        INTO v_cactivi
        FROM garanpro
       WHERE sproduc = psproduc
         AND cactivi = pcactivi;

      --Fi BUG9748
      SELECT COUNT(1)
        INTO num_err
        FROM incompgaran i, garanpro g
       WHERE i.cramo = g.cramo
         AND i.cmodali = g.cmodali
         AND i.ctipseg = g.ctipseg
         AND i.ccolect = g.ccolect
         AND i.cactivi = g.cactivi
         AND i.cgarant = g.cgarant
         AND g.sproduc = psproduc
         AND g.cactivi = v_cactivi;

      IF num_err = 0 THEN
         SELECT COUNT(1)
           INTO num_err
           FROM incompgaran i, garanpro g
          WHERE i.cramo = g.cramo
            AND i.cmodali = g.cmodali
            AND i.ctipseg = g.ctipseg
            AND i.ccolect = g.ccolect
            AND i.cactivi = g.cactivi
            AND i.cgarant = g.cgarant
            AND g.sproduc = psproduc
            AND g.cactivi = 0;
      END IF;

      -- Bug 9699 - APD - 23/04/2009 - Fin
      IF num_err > 0 THEN
         RETURN 151247;
      END IF;

      FOR c IN garantias LOOP
         --validamos la edad, y solo marcamos aquella que cumplen la edad.
         num_err := f_validar_edad(psseguro, pnriesgo, psproduc, pcactivi, c.cgarant);

         -- no devolvemos el error si no que las que ni cumplen no se marcan
         IF num_err = 0 THEN
            IF c.ctipgar = 2 THEN
               vicapital := NVL(c.icapital, 0);
            ELSE
               vicapital := 0;
            END IF;

            UPDATE solgaranseg
               SET cobliga = 1,
                   icapital = vicapital,
                   iprianu = NULL
             WHERE ssolicit = psseguro
               AND nriesgo = pnriesgo
               AND cgarant = c.cgarant;

            --llamo a la función para que me marque las dependientes
            -- obligatorias de las obligatorias
            num_err := f_validacion_cobliga(psseguro, pnriesgo, pnmovimi, c.cgarant, 'SEL',
                                            psproduc, pcactivi, v_mensa, c.nmovima);

            IF num_err <> 0 THEN
               COMMIT;
               RETURN num_err;
            END IF;
         ELSE
            UPDATE solgaranseg
               SET cobliga = 0,
                   icapital = NULL,
                   iprianu = NULL
             WHERE ssolicit = psseguro
               AND nriesgo = pnriesgo
               AND cgarant = c.cgarant;
         END IF;
      END LOOP;

      COMMIT;
      RETURN 0;
   END f_marcar_completo;

/*************************************************************************
   FUNCTION  f_primas_a_null
******************************************************************************/
   FUNCTION f_primas_a_null(psseguro IN NUMBER, pnriesgo IN NUMBER, pnmovimi IN NUMBER)
      RETURN NUMBER IS
   BEGIN
      UPDATE solgaranseg
         SET iprianu = NULL
       WHERE ssolicit = psseguro
         AND nriesgo = pnriesgo;

      COMMIT;
      RETURN 0;
   END f_primas_a_null;

/*************************************************************************
   FUNCTION  f_int_estimado
******************************************************************************/
   FUNCTION f_int_estimado(psproduc IN NUMBER, pcactivi IN NUMBER)
      RETURN NUMBER IS
      contador       NUMBER;
   BEGIN
      -- Bug 9699 - APD - 23/04/2009 - primero se ha de buscar para la actividad en concreto
      -- y si no se encuentra nada ir a buscar a GARANPRO para la actividad cero
      SELECT COUNT(1)
        INTO contador
        FROM garanpro
       WHERE sproduc = psproduc
         AND cactivi = pcactivi
         AND f_pargaranpro_v(cramo, cmodali, ctipseg, ccolect, cactivi, cgarant,
                             'MOSTRAR_CAMPOS') = 1;

      IF contador = 0 THEN
         SELECT COUNT(1)
           INTO contador
           FROM garanpro
          WHERE sproduc = psproduc
            AND cactivi = 0
            AND f_pargaranpro_v(cramo, cmodali, ctipseg, ccolect, cactivi, cgarant,
                                'MOSTRAR_CAMPOS') = 1;
      END IF;

      -- Bug 9699 - APD - 23/04/2009 - Fin
      RETURN contador;
   END f_int_estimado;

/*************************************************************************
   FUNCTION  f_control_edad_suma
******************************************************************************/
   FUNCTION f_control_edad_suma(
      pfnacimi IN DATE,
      pfecha IN DATE,
      pfnacimi2 IN DATE,
      pnsedmac IN NUMBER,
      pcisemac IN NUMBER)
      RETURN NUMBER IS
      num_err        NUMBER := 0;
      valor1         NUMBER;
      valor2         NUMBER;
      suma_edad      NUMBER;
   BEGIN
      --Edat màxima
      --mirem l'edat segons CIEDMIC,CIEMAC (1 Real ,0 Actuarial)
      IF pfnacimi IS NULL
         OR pfecha IS NULL
         OR pfnacimi2 IS NULL
         OR pnsedmac IS NULL
         OR pcisemac IS NULL THEN
         num_err := 100;   -- error de paso de parámetros
      ELSE
         IF pcisemac = 0 THEN   -- edad actuarial
            num_err := f_difdata(pfnacimi, pfecha, 2, 1, valor1);
            num_err := f_difdata(pfnacimi2, pfecha, 2, 1, valor2);
         ELSIF pcisemac = 1 THEN   -- edad real
            num_err := f_difdata(pfnacimi, pfecha, 1, 1, valor1);
            num_err := f_difdata(pfnacimi2, pfecha, 1, 1, valor1);
         END IF;

         suma_edad := valor1 + valor2;

         IF suma_edad > pnsedmac THEN
            num_err := 103366;
         -- edad no comprendida entre la maxima y mínima de contratación
         END IF;
      END IF;

      RETURN num_err;
   END f_control_edad_suma;

/*************************************************************************
   FUNCTION  f_validar_edad_prod
******************************************************************************/
   FUNCTION f_validar_edad_prod(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pfefecto IN DATE,
      pfnacimi IN DATE,
      pssolicit IN NUMBER DEFAULT NULL,
      pfnacimi2 IN DATE DEFAULT NULL)
      RETURN NUMBER IS
      vnedamac       productos.nedamac%TYPE;   --edad max. permitida primer asegurado
      vnedamic       productos.nedamic%TYPE;   -- edad min. permitida primer asegurado
      vciedmac       productos.ciedmac%TYPE;   -- indicador edad real o actuarial en max. permitida primer asegurado
      vciedmic       productos.ciedmic%TYPE;   -- indicador edad real o actuarial en min. permitida primer asegurado
      vnedma2c       productos.nedma2c%TYPE;   -- edad max. permitida segundo asegurado
      vnedmi2c       productos.nedmi2c%TYPE;   -- edad min. permitida segundo asegurado
      vciema2c       productos.ciema2c%TYPE;   -- indicador edad real o actuarial en max. permitida segundo asegurado
      vciemi2c       productos.ciemi2c%TYPE;   -- indicador edad real o actuarial en min. permitida segundo asegurado
      vnsedmac       productos.nsedmac%TYPE;   -- máximo de contratación de la suma de edades (productos 2 cabezas)
      vcisemac       productos.cisemac%TYPE;   -- indicar edad real o actuarial máximo de suma de edades
      num_err        NUMBER;
   BEGIN
      SELECT nedamac, nedamic, ciedmac, ciedmic, nedma2c, ciema2c, nedmi2c, ciemi2c,
             nsedmac, cisemac
        INTO vnedamac, vnedamic, vciedmac, vciedmic, vnedma2c, vciema2c, vnedmi2c, vciemi2c,
             vnsedmac, vcisemac
        FROM productos
       WHERE sproduc = psproduc;

      -- Controlamos la edad del primer asegurado
      num_err := f_control_edat_sim(pfnacimi, pfefecto, NVL(vnedamic, 0), NVL(vciedmic, 0),
                                    NVL(vnedamac, 999), NVL(vciedmac, 0));

      -- Controlamos la edad del segundo asegurado (2 cabezas)
      IF pfnacimi2 IS NOT NULL THEN
         num_err := f_control_edat_sim(pfnacimi2, pfefecto, NVL(vnedmi2c, 0),
                                       NVL(vciemi2c, 0), NVL(vnedma2c, 999), NVL(vciema2c, 0));

         IF num_err = 0 THEN   -- validamos la suma de edades
            num_err := f_control_edad_suma(pfnacimi, pfefecto, pfnacimi2, NVL(vnsedmac, 999),
                                           NVL(vcisemac, 0));
         END IF;
      END IF;

      IF num_err = 0 THEN
         num_err := pac_propio.f_validar_edad_prod(pssolicit, psproduc, pfnacimi);
      END IF;

      RETURN num_err;
   END f_validar_edad_prod;

/*************************************************************************
   FUNCTION  f_control_edat_sim
******************************************************************************/
   FUNCTION f_control_edat_sim(
      pfnacimi IN DATE,
      pfecha IN DATE,
      pnedamic IN NUMBER,
      pciedmic IN NUMBER,
      pnedamac IN NUMBER,
      pciedmac IN NUMBER)
      RETURN NUMBER IS
      n_ciedamic     productos.ciedmic%TYPE;
      n_ciedamac     productos.ciedmac%TYPE;
      n_ciedamac2    productos.ciedmac%TYPE;
      num_err        NUMBER := 0;
      valor          NUMBER;
   BEGIN
      --Edat màxima
      --mirem l'edat segons CIEDMIC,CIEMAC (1 Real ,0 Actuarial)
      IF pfnacimi IS NULL
         OR pfecha IS NULL
         OR pnedamic IS NULL
         OR pciedmic IS NULL
         OR pnedamac IS NULL
         OR pciedmac IS NULL THEN
         num_err := 100;   -- error de paso de parámetros
      ELSE
         IF pciedmac = 0 THEN   -- edad actuarial
            num_err := f_difdata(pfnacimi, pfecha, 2, 1, valor);
            n_ciedamac := valor;
         ELSIF pciedmac = 1 THEN   -- edad real
            num_err := f_difdata(pfnacimi, pfecha, 1, 1, valor);
            n_ciedamac := valor;
         END IF;

         IF pciedmic = 0 THEN   -- edad actuarial
            num_err := f_difdata(pfnacimi, pfecha, 2, 1, valor);
            n_ciedamic := valor;
         ELSIF pciedmic = 1 THEN   --edad real
            num_err := f_difdata(pfnacimi, pfecha, 1, 1, valor);
            n_ciedamic := valor;
         END IF;

         IF (n_ciedamic < pnedamic
             OR n_ciedamac > pnedamac)
            AND(n_ciedamac IS NOT NULL
                AND n_ciedamic IS NOT NULL) THEN
            num_err := 103366;
         -- edad no comprendida entre la maxima y mínima de contratación
         END IF;
      END IF;

      RETURN num_err;
   END f_control_edat_sim;

/*************************************************************************
   FUNCTION  f_calcula_importe_maximo
******************************************************************************/
   FUNCTION f_calcula_importe_maximo(
      psproduc IN NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      anyo NUMBER,
      pcforpag IN NUMBER,
      pfefecto IN DATE,
      pfnacimi IN DATE,
      pcestado IN NUMBER DEFAULT 0)
      RETURN NUMBER IS
      v_cestado      NUMBER;
      ntipo_aport    NUMBER;
      fin_anyo       DATE;
      edad           NUMBER;
      num_err        NUMBER;
      limite         NUMBER;
      valor          NUMBER;
      v_apperiodo    NUMBER;
      v_apextraordi  NUMBER;
      v_fcarpro      DATE;
      prima_inicial  NUMBER;
      v_prima_pend   NUMBER;
      lmeses         NUMBER;
      aport_max_2    NUMBER;
      aport_max      NUMBER;
      v_cforpag      seguros.cforpag%TYPE;
      prima_anual    NUMBER;
      v_nrenova      NUMBER;
      v_ctipefe      NUMBER;
      v_fecha        DATE;
   BEGIN
      -- miramos si hay que comprobar el máximo de aportaciones
      num_err := f_parproductos(psproduc, 'APORTMAXIMAS', valor);

      IF NVL(valor, 0) = 1 THEN
         -- obtenemos las primas_periodo (3) y las extraordinarias(4)
         -- Bug 9699 - APD - 23/04/2009 - en lugar de coger la acticad de la tabla seguros, llamar a la función pac_seguros.ff_get_actividad
         SELECT NVL(SUM(icapital), 0)
           INTO v_apperiodo
           FROM solgaranseg s, solseguros x
          WHERE s.ssolicit = psseguro
            AND s.nriesgo = pnriesgo
            AND s.cobliga = 1
            AND x.ssolicit = s.ssolicit
            AND f_pargaranpro_v(x.cramo, x.cmodali, x.ctipseg, x.ccolect,
                                pac_seguros.ff_get_actividad(psseguro, pnriesgo, 'SOL'),
                                s.cgarant, 'TIPO') = 3;

         -- Bug 9699 - APD - 23/04/2009 - fin

         -- Bug 9699 - APD - 23/04/2009 - en lugar de coger la acticad de la tabla seguros, llamar a la función pac_seguros.ff_get_actividad
         SELECT NVL(SUM(icapital), 0)
           INTO v_apextraordi
           FROM solgaranseg s, solseguros x
          WHERE s.ssolicit = psseguro
            AND s.nriesgo = pnriesgo
            AND s.cobliga = 1
            AND x.ssolicit = s.ssolicit
            AND f_pargaranpro_v(x.cramo, x.cmodali, x.ctipseg, x.ccolect,
                                pac_seguros.ff_get_actividad(psseguro, pnriesgo, 'SOL'),
                                s.cgarant, 'TIPO') = 4;

         -- Bug 9699 - APD - 23/04/2009 - fin
         IF v_cestado = 1 THEN
            ntipo_aport := 2;
         ELSE
            ntipo_aport := 1;
         END IF;

         -- Calculamos nrenova
         BEGIN
            SELECT ctipefe
              INTO v_ctipefe
              FROM productos
             WHERE sproduc = psproduc;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 102705;
         END;

         IF v_ctipefe = 2 THEN
            IF TO_CHAR(pfefecto, 'dd') = 1 THEN
               v_fecha := pfefecto;
            ELSE
               v_fecha := ADD_MONTHS(pfefecto, 1);
            END IF;

            v_nrenova := TO_CHAR(v_fecha, 'mm') || '01';
         ELSIF v_ctipefe = 3 THEN
            v_nrenova := TO_CHAR(pfefecto, 'mm') || '01';
         ELSE
            v_nrenova := TO_CHAR(pfefecto, 'mmdd');
         END IF;

         aport_max := NVL(pac_ppa_planes.calcula_imp_maximo_simulacion(anyo, pfnacimi, 1), 0);

         IF pcforpag = 0 THEN
            v_cforpag := 1;
         ELSE
            v_cforpag := pcforpag;
         END IF;

         v_fcarpro := pac_ppa_planes.f_fcarpro(psproduc, v_cforpag, v_nrenova, pfefecto);

         IF v_apextraordi = 0 THEN
            prima_inicial := v_apperiodo;
         ELSE
            prima_inicial := v_apextraordi;
         END IF;

         v_prima_pend := prima_inicial;
         lmeses := 12 / v_cforpag;

         WHILE v_fcarpro <= TO_DATE('3112' || anyo, 'ddmmyyyy') LOOP
            v_prima_pend := v_prima_pend + v_apperiodo;
            v_fcarpro := ADD_MONTHS(v_fcarpro, lmeses);
         END LOOP;

         IF v_prima_pend > aport_max THEN
            limite := 109538;
         ELSE
            limite := 0;
         END IF;

         IF limite = 0 THEN
            -- HA pasado la validación del primer año, ahora validamos el segundo
            aport_max_2 := NVL(pac_ppa_planes.calcula_imp_maximo_simulacion(anyo + 1,
                                                                            pfnacimi, 1),
                               0);

            IF pcforpag = 0 THEN
               v_cforpag := 1;
            ELSE
               v_cforpag := pcforpag;
            END IF;

            prima_anual := v_apperiodo * v_cforpag;

            IF prima_anual > aport_max_2 THEN
               limite := 109538;
            ELSE
               limite := 0;
            END IF;
         END IF;

         RETURN limite;
      END IF;

      RETURN 0;
   END f_calcula_importe_maximo;

/*************************************************************************
   FUNCTION  f_validar_capitalmin
******************************************************************************/
   FUNCTION f_validar_capitalmin(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcforpag IN NUMBER,
      pcgarant IN NUMBER,
      pcicapital IN NUMBER,
      pcicapmin IN OUT NUMBER)
      RETURN NUMBER IS
      vccapmin       garanpro.ccapmin%TYPE;
   BEGIN
      -- miramos que tipo de capital mínimo tiene
      -- 0 .- fijo, 1.- segun forma de pago
      -- Bug 9699 - APD - 23/04/2009 - primero se ha de buscar para la actividad en concreto
      -- y si no se encuentra nada ir a buscar a GARANPRO para la actividad cero
      BEGIN
         SELECT ccapmin, icapmin
           INTO vccapmin, pcicapmin
           FROM garanpro
          WHERE sproduc = psproduc
            AND cactivi = pcactivi
            AND cgarant = pcgarant;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            SELECT ccapmin, icapmin
              INTO vccapmin, pcicapmin
              FROM garanpro
             WHERE sproduc = psproduc
               AND cactivi = 0
               AND cgarant = pcgarant;
      END;

      -- Bug 9699 - APD - 23/04/2009 - Fin
      IF NVL(vccapmin, 0) = 1 THEN
         BEGIN
            SELECT icapmin
              INTO pcicapmin
              FROM capitalmin
             WHERE sproduc = psproduc
               AND cactivi = pcactivi
               AND cforpag = pcforpag
               AND cgarant = pcgarant;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               NULL;   -- si no está es que no límit mínim
         END;
      END IF;

      IF pcicapmin IS NOT NULL
         AND pcicapmin > pcicapital THEN
         RETURN 151289;   --La prima no supera la prima mínima
      END IF;

      RETURN 0;
   END f_validar_capitalmin;

/*************************************************************************
   FUNCTION  f_valida_datosgestion
 *************************************************************************/
   FUNCTION f_valida_datosgestion(psseguro IN NUMBER, psproduc IN NUMBER)
      RETURN NUMBER IS
      /*****************************************************************************
      Función que valida los datos de gestión.
      *****************************************************************************/
      vfefecto       DATE;
      vfvencim       DATE;
      num_err        NUMBER;
      vdias_a        NUMBER;
      vdias_d        NUMBER;
      vmeses_a       NUMBER;
      vmeses_d       NUMBER;
      vcduraci       solseguros.cduraci%TYPE;
   BEGIN
      SELECT fvencim, falta, cduraci
        INTO vfvencim, vfefecto, vcduraci
        FROM solseguros
       WHERE ssolicit = psseguro;

      num_err := f_parproductos(psproduc, 'DIASATRAS', vdias_a);
      num_err := f_parproductos(psproduc, 'DIASDESPU', vdias_d);
      -- 34866/206242
      vmeses_a := NVL(f_parproductos_v(psproduc, 'MESESATRAS'), 0);
      vmeses_d := NVL(f_parproductos_v(psproduc, 'MESESDESPU'), 0);

      -- Calcular v_dias:
      -- Si la fecha de efecto esta en diferente año al actual de la emisión de la
      -- la propuesta, solo se permitirá retroactividad hasta el principio del año:
      --
      IF vmeses_a != 0 THEN
         IF (ADD_MONTHS(vfefecto, vmeses_a) >= TRUNC(f_sysdate)) THEN
            IF TO_NUMBER(TO_CHAR(vfefecto, 'YYYY')) <> TO_NUMBER(TO_CHAR(f_sysdate, 'YYYY')) THEN
               vmeses_a := NULL;
               vdias_a := TRUNC(f_sysdate
                                - TO_DATE('01/01/' || TO_CHAR(f_sysdate, 'YYYY'),
                                          'dd/mm/yyyy'));
            ELSE
               vmeses_a := NULL;
               vdias_a := TRUNC(f_sysdate - vfefecto);
            END IF;
         ELSE
            IF ADD_MONTHS(vfefecto, vmeses_a) < TRUNC(f_sysdate) THEN
               vmeses_a := NULL;
               vdias_a := f_sysdate - ADD_MONTHS(f_sysdate, -1 * vmeses_a);
            END IF;
         END IF;
      END IF;

      -- Calcular v_dias_d
      IF (vmeses_d != 0) THEN
         vdias_d := TRUNC(ADD_MONTHS(f_sysdate, vmeses_d) - f_sysdate);
      END IF;

      -- Validar retroactividad
      --
      IF vdias_d = -1 THEN   --primer dia del mes siguiente
         vdias_d := LAST_DAY(f_sysdate) + 1 - f_sysdate;
      END IF;

      IF vfefecto IS NULL THEN
         RETURN 104532;
      ELSIF vfefecto + NVL(vdias_a, 0) < TRUNC(f_sysdate) THEN
         RETURN 109909;
      ELSIF vfefecto > TRUNC(f_sysdate) + NVL(vdias_d, 0) THEN
         RETURN 101490;
      END IF;

      IF vfvencim IS NOT NULL THEN
         IF vfvencim <= vfefecto THEN
            RETURN 100022;
         END IF;
      ELSE
         IF vcduraci NOT IN(0, 4) THEN
            RETURN 151288;
         END IF;
      END IF;

      RETURN 0;
   END f_valida_datosgestion;

/*************************************************************************
   FUNCTION  f_valida_solpregunseg
******************************************************************************/
   FUNCTION f_valida_solpregunseg(
      p_in_ssolicit IN solseguros.ssolicit%TYPE,
      pnriesgo IN NUMBER,
      psproduc IN NUMBER,
      tipo OUT NUMBER,
      campo OUT VARCHAR2)
      RETURN NUMBER IS
      cont           NUMBER;
   BEGIN
      -- diferencia simulador i emisión de TF. Las preguntas se insertan antes aquí,en emisión no se PRE-insertan
      SELECT COUNT(1)
        INTO cont
        FROM (SELECT cpregun
                FROM pregunpro p
               WHERE p.sproduc = psproduc
                 AND p.cpreobl = 1   --obligatorias
              MINUS
              SELECT cpregun
                FROM solpregunseg
               WHERE ssolicit = p_in_ssolicit
                 AND nriesgo = pnriesgo
                 AND NVL(crespue, trespue) IS NOT NULL);

      IF cont > 0 THEN
         tipo := 5;
         campo := NULL;
         RETURN 120307;
      END IF;

      RETURN 0;
   END f_valida_solpregunseg;

/*************************************************************************
   FUNCTION  f_valida_pregun_garant
******************************************************************************/
   FUNCTION f_valida_pregun_garant(
      p_in_sseguro IN seguros.sseguro%TYPE,
      pnriesgo IN riesgos.nriesgo%TYPE,
      pnmovimi IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pmensa OUT VARCHAR2)
      RETURN NUMBER IS
      num_err        NUMBER;
   BEGIN
      -- Comprobació preguntes a nivel de garantia
      pk_nueva_produccion.p_define_modo('SOL');
      num_err := pk_nueva_produccion.f_valida_pregun_garant(p_in_sseguro, pnriesgo, pnmovimi,
                                                            psproduc, pcactivi, NULL,   -- BUG9496:DRA:22/10/2009
                                                            pmensa);
      RETURN num_err;
   END f_valida_pregun_garant;

   /*************************************************************************
      Grabar un registro en la tabla PERSISTENCIA_SIMUL si no existe
      param in psseguro     : cdigo de solicitud
      param in out mensajes : mensajes error
      return                : 0 todo correcto
                              1 ha habido un error
   *************************************************************************/
   FUNCTION f_alta_persistencia_simul(psseguro IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100) := 'psseguro=' || psseguro;
      vobject        VARCHAR2(200) := 'PK_SIMULACIONES.F_alta_persistencia_simul';
   BEGIN
      BEGIN
         INSERT INTO persistencia_simul
                     (sseguro, fpersis)
              VALUES (psseguro, f_sysdate);

         COMMIT;
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            NULL;
      END;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_alta_persistencia_simul;

   /*************************************************************************
      Actualiza el estado de la simulacion a 4 y borra la simulacion de la tabla de persisntecia
      param in psseguro     : cdigo de solicitud
      param in out mensajes : mensajes error
      return                : 0 todo correcto
                              1 ha habido un error
   *************************************************************************/
   FUNCTION f_actualizar_persistencia(psseguro IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100) := 'psseguro=' || psseguro;
      vobject        VARCHAR2(200) := 'PK_SIMULACIONES.F_actualiza_persistencia';
   BEGIN
      BEGIN
         UPDATE estseguros
            SET csituac = 7
          WHERE sseguro = psseguro;
      END;

      vpasexec := 2;

      BEGIN
         DELETE FROM persistencia_simul
               WHERE sseguro = psseguro;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            NULL;
      END;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_actualizar_persistencia;
-- Fi Bug 27429
END pk_simulaciones;

/

  GRANT EXECUTE ON "AXIS"."PK_SIMULACIONES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PK_SIMULACIONES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PK_SIMULACIONES" TO "PROGRAMADORESCSI";
