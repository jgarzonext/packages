--------------------------------------------------------
--  DDL for Package Body PAC_PROD_ULK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_PROD_ULK" AS
/****************************************************************************

   NOMBRE:       PAC_PROD_ULK
   PROPÓSITO:  Funciones para productos de UnitLink

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ----------------------------------
   1.0           -          -               Creació del package
   2.0        20/04/2009   APD              Bug 9685 - en lugar de coger la acticad de la tabla seguros, llamar a la función pac_seguros.ff_get_actividad
****************************************************************************/
   FUNCTION f_grabar_garantias_index(
      pmodo IN NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      pfefecto IN DATE,
      prima_inicial IN NUMBER,
      prima_per IN NUMBER,
      pprevali IN NUMBER)
      RETURN NUMBER IS
      /***********************************************************************************************************************************
         Función que inserta las garantías en la tabla ESTGARANSEG actualizando el capital

         pmodo: 1 -- alta de la propuesta
                2 -- actualización de capital
       **************************************************************************************************************************************/
      v_accion       VARCHAR2(5);
      vmensa         VARCHAR2(1000);
      vnmovima       NUMBER;
      num_err        NUMBER;
      v_icapital     NUMBER;
      traza          NUMBER;
      v_sproduc      NUMBER;
      v_cramo        NUMBER;
      v_cmodali      NUMBER;
      v_ctipseg      NUMBER;
      v_ccolect      NUMBER;
      v_cactivi      NUMBER;
      v_cobliga      NUMBER;

      CURSOR c_gar(c_sseguro IN NUMBER) IS
         SELECT   *
             FROM estgaranseg
            WHERE sseguro = c_sseguro
         ORDER BY cgarant;
   BEGIN
      traza := 1;

      -- Bug 9685 - APD - 21/04/2009 - en lugar de coger la actividad de la tabla seguros, llamar a la función pac_seguros.ff_get_actividad
      SELECT sproduc, cramo, cmodali, ctipseg, ccolect,
             pac_seguros.ff_get_actividad(psseguro, pnriesgo, 'EST') cactivi
        INTO v_sproduc, v_cramo, v_cmodali, v_ctipseg, v_ccolect,
             v_cactivi
        FROM estseguros
       WHERE sseguro = psseguro;

      -- Bug 9685 - APD - 21/04/2009 - Fin
      IF pmodo = 1 THEN   -- si es alta insertamos las garantías
         traza := 2;
         num_err := pk_nueva_produccion.f_garanpro_estgaranseg(psseguro, pnriesgo, pnmovimi,
                                                               v_sproduc, pfefecto, 0);

         IF num_err <> 0 THEN
            RETURN num_err;
         END IF;
      ELSE   -- si es modificación actualizamos las fechas
         UPDATE estgaranseg
            SET ftarifa = pfefecto,
                finiefe = pfefecto
          WHERE sseguro = psseguro;
      END IF;

      -- Actualizamos la revalorización
      UPDATE estseguros
         SET prevali = pprevali
       WHERE sseguro = psseguro;

      UPDATE estgaranseg
         SET prevali = pprevali
       WHERE sseguro = psseguro
         AND cgarant IN(SELECT cgarant
                          FROM garanpro
                         WHERE sproduc = v_sproduc
                           AND crevali <> 0);

      -- Actualizamos el capital
      FOR gar IN c_gar(psseguro) LOOP
         v_cobliga := gar.cobliga;
         v_icapital := gar.icapital;

         -- PRIMA AHORRO
         IF NVL(f_pargaranpro_v(v_cramo, v_cmodali, v_ctipseg, v_ccolect, v_cactivi,
                                gar.cgarant, 'TIPO'),
                0) = 3 THEN
            v_cobliga := 1;
            v_icapital := prima_per;
         -- PRIMA EXTRAORDINARIA/INICIAL
         ELSIF NVL(f_pargaranpro_v(v_cramo, v_cmodali, v_ctipseg, v_ccolect, v_cactivi,
                                   gar.cgarant, 'TIPO'),
                   0) = 4 THEN
            v_cobliga := 1;
            v_icapital := prima_inicial;
         END IF;

         -- actualizamos el capital de las diferentes garantías
         UPDATE estgaranseg
            SET icapital = v_icapital,
                cobliga = v_cobliga
          WHERE sseguro = psseguro
            AND nriesgo = pnriesgo
            AND nmovimi = pnmovimi
            AND cgarant = gar.cgarant;

         IF v_cobliga = 0 THEN
            v_accion := 'DESEL';
         ELSIF v_cobliga = 1 THEN
            v_accion := 'SEL';
         END IF;

         num_err := pk_nueva_produccion.f_validacion_cobliga(psseguro, pnriesgo, pnmovimi,
                                                             gar.cgarant, v_accion, v_sproduc,
                                                             v_cactivi, vmensa, gar.nmovima);
      END LOOP;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Pac_Prod_Ulk.f_grabar_garantias_index', traza,
                     'parametros: pmodo =' || pmodo || ' psseguro =' || psseguro
                     || ' pnriesgo =' || pnriesgo || ' pnmovimi =' || pnmovimi
                     || ' pfefecto =' || pfefecto || ' prima_inicial = ' || prima_inicial
                     || ' prima_per =' || prima_per || ' pprevali=' || pprevali,
                     SQLERRM);
         RETURN 108190;   -- Error General
   END f_grabar_garantias_index;

   FUNCTION f_graba_propuesta_index(
      psproduc IN NUMBER,
      psperson1 IN NUMBER,
      pcdomici1 IN NUMBER,
      psperson2 IN NUMBER,
      pcdomici2 IN NUMBER,
      pcagente IN NUMBER,
      pcidioma IN NUMBER,
      pfefecto IN DATE,
      pnduraci IN NUMBER,
      pfvencim IN DATE,
      pcforpag IN NUMBER,
      pcbancar IN VARCHAR2,
      pcmodinv IN NUMBER,
      pmodinv IN pac_ref_contrata_ulk.cartera,
      psclaben IN NUMBER,
      ptclaben IN VARCHAR2,
      prima_inicial IN NUMBER,
      prima_per IN NUMBER,
      prevali IN NUMBER,
      psseguro IN OUT NUMBER)
      RETURN NUMBER IS
      /************************************************************************************************************************************
        RSC 13/07/2007
        En esta función se grabará una póliza de vida-indexado en las tablas EST con todos los datos y se tarifará.
        Si el parámetro psseguro NO viene infomado será una propuesta nueva, por lo tanto se inserta en las tablas EST
        Si el parámetro psseguro SI llega informado será una modificación de los datos de la propuesta.

        Finalmente graba la configuración de modelo de inversión en ESTSEGDISIN2 y actualiza los valores de codigo
        de modelo de inversión y codigos del modelo de gastos.

         La función retorna:
                -- 0: si todo es correcto
                -- codigo error: si hay error.
      ************************************************************************************************************************************/
      error          EXCEPTION;
      num_err        NUMBER;
      --JRH Nuevo parametro para insertar preguntas a nivel de póliza. En el caso de AHO no tenemos.
      tab_pregun     pac_prod_comu.t_preguntas;
   BEGIN
      -- Primero inicializamos la propuesta, es decir, grabamos todos los datos y tarifamos
      num_err := pac_prod_comu.f_inicializa_propuesta(psproduc, psperson1, pcdomici1,
                                                      psperson2, pcdomici2, pcagente,
                                                      pcidioma, pfefecto, pnduraci, pfvencim,
                                                      pcforpag, pcbancar, psclaben, ptclaben,
                                                      prima_inicial, prima_per, prevali, 0, 0,
                                                      0, 0, psseguro, tab_pregun);

      -- A estas alturas psseguro ya esta dado de alta
      IF num_err <> 0 THEN
         RAISE error;
      ELSE
         -- Grabamos las preguntas parametrizadas en el producto
         --num_err := F_grabar_preguntas(psseguro,1,1, psproduc);
         --IF num_err <> 0 THEN
         --   RAISE error;
         --ELSE
           -- grabar_distribucion_cestas (ESTSEGDISIN2)
         num_err := f_grabar_distribucion_cestas(psseguro, 1, 1, pfefecto, NULL, pmodinv);

         IF num_err <> 0 THEN
            RAISE error;
         ELSE
            -- grabar_codigo_modelo_inversión (ESTSEGUROS_ULK) (necesitamos pcmodinv)
            num_err := f_actualiza_modinversion(psseguro, pcmodinv);

            IF num_err <> 0 THEN
               RAISE error;
            ELSE
               -- grabar_modelo de gastos por defecto (ESTSEGUROS_ULK)
               num_err := f_actualiza_modelogastos(psseguro, 1, NULL, NULL);

               IF num_err <> 0 THEN
                  RAISE error;
               END IF;
            END IF;
         END IF;
      --END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN error THEN
         RETURN num_err;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Pac_Prod_Ulk.f_graba_propuesta_index', NULL,
                     'parametros: psproduc =' || psproduc || ' psperson1 =' || psperson1
                     || ' pcdomici1 =' || pcdomici1 || ' psperson2 =' || psperson2
                     || ' pcdomici2 =' || pcdomici2 || ' pcagente=' || pcagente
                     || ' pcidioma=' || pcidioma || ' pfefecto=' || pfefecto || ' pnduraci='
                     || pnduraci || ' pfvencim=' || pfvencim || ' pcforpag=' || pcforpag
                     || ' pcbancar=' || pcbancar || ' psclaben=' || psclaben || ' ptclaben='
                     || ptclaben || ' prima_inicial = ' || prima_inicial || ' prima_per ='
                     || prima_per || ' prevali=' || prevali || ' psseguro=' || psseguro,
                     SQLERRM);
         RETURN(108190);   -- Error general
   END f_graba_propuesta_index;

   /*
       RSC -- 17-09-2007 (Deprecated: La cláusula de No Penalización no la parametrizamos a traves de una pregunta de producto)
   */
   FUNCTION f_grabar_preguntas(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      psproduc IN NUMBER)
      RETURN NUMBER IS
      /***********************************************************************************************************************************
        RSC 12/09/2007
        Esta función actualiza la tabla estpregunseg con la información de la preguntas asociadas al producto
        La función retorna:
                -- 0: si todo es correcto
                -- codigo error: si hay error.
      ************************************************************************************************************************************/

      -- Preguntas parametrizadas en el producto
      CURSOR regs_pregun IS
         SELECT cpregun, cresdef
           FROM pregunpro
          WHERE sproduc = psproduc;

      num_err        NUMBER;
   BEGIN
      FOR regs IN regs_pregun LOOP
         num_err := pk_nueva_produccion.f_ins_estpregunseg(psseguro, pnriesgo, pnmovimi,
                                                           regs.cpregun, regs.cresdef);

         IF num_err <> 0 THEN
            RETURN num_err;
         END IF;
      END LOOP;

      RETURN(0);
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Pac_Prod_Ulk.F_grabar_preguntas', NULL,
                     'parametros: psseguro =' || psseguro || '  pnriesgo =' || pnriesgo
                     || ' pnmovimi =' || pnmovimi || ' psproduc =' || psproduc,
                     SQLERRM);
         RETURN 108190;   -- Error General
   END f_grabar_preguntas;

   FUNCTION f_grabar_distribucion_cestas(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      pfefecto IN DATE,
      pffin IN DATE,
      pmodinv IN pac_ref_contrata_ulk.cartera)
      RETURN NUMBER IS
   /***********************************************************************************************************************************
     RSC 13/07/2007
     Esta función realiza la insersión de la distribución de cesta escogida por el usuario (ya sea AGRESIVO, EQUILIBRADO, DINAMICO
     o LIBRE) en la tabla ESTSEGDISIN2. En caso de existir el registro para el seguro, riesgo,nmovimi i cesta dadas simplemente
     se realiza la modificación del porcentaje. Esta no es la función a llamar en caso de suplemento de póliza.

          La función retorna:
             -- 0: si todo es correcto
             -- codigo error: si hay error.
   ************************************************************************************************************************************/
   BEGIN
      --iteramos sobre el objeto cartera para sumar la distribución de cestas
      FOR i IN 1 .. pmodinv.LAST LOOP
         BEGIN
            INSERT INTO estsegdisin2
                        (sseguro, nriesgo, nmovimi, finicio, ffin,
                         ccesta,
                         pdistrec)
                 VALUES (psseguro, pnriesgo, pnmovimi, pfefecto, pffin,
                         pac_util.splitt(pmodinv(i), 1, '|'),
                         pac_util.splitt(pmodinv(i), 2, '|'));
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               UPDATE estsegdisin2
                  SET finicio = pfefecto,
                      ffin = pffin,
                      pdistrec = pac_util.splitt(pmodinv(i), 2, '|')
                WHERE sseguro = psseguro
                  AND nriesgo = pnriesgo
                  AND nmovimi = pnmovimi
                  AND ccesta = pac_util.splitt(pmodinv(i), 1, '|');
         END;
      END LOOP;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Pac_Prod_Ulk.F_grabar_distribucion_cestas', NULL,
                     'parametros: psseguro =' || psseguro || ' nriesgo =' || pnriesgo
                     || ' nmovimi =' || pnmovimi || ' pfefecto =' || pfefecto || ' pffin ='
                     || pffin,
                     SQLERRM);
         RETURN(108190);   -- Error general
   END f_grabar_distribucion_cestas;

   FUNCTION f_actualiza_modinversion(psseguro IN NUMBER, pcmodinv IN NUMBER)
      RETURN NUMBER IS
   /***********************************************************************************************************************************
     RSC 13/07/2007
     Esta función actualiza el codigo de modelo de inversión selecionado en ESTSEGUROS_ULK.
     La función retorna:
             -- 0: si todo es correcto
             -- codigo error: si hay error.
   ************************************************************************************************************************************/
   BEGIN
--------------------------------------------------------------------------
-- Se modifican el campo estseguros_ulk.cmodinv
--------------------------------------------------------------------------
      UPDATE estseguros_ulk
         SET cmodinv = pcmodinv
       WHERE sseguro = psseguro;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Pac_Prod_Ulk.f_actualiza_modinversion', NULL,
                     'parametros: psseguro =' || psseguro || '  pcmodinv =' || pcmodinv,
                     SQLERRM);
         RETURN 108190;   -- Error General
   END f_actualiza_modinversion;

   FUNCTION f_actualiza_modelogastos(
      psseguro IN NUMBER,
      pcdefecto IN NUMBER,
      pcgasges IN NUMBER,
      pcgasred IN NUMBER)
      RETURN NUMBER IS
      /***********************************************************************************************************************************
        RSC 13/07/2007
        Esta función actualiza los códigos de gastos de gestión y redistribución en la tabla ESTSEGUROS_ULK.
        La función retorna:
                -- 0: si todo es correcto
                -- codigo error: si hay error.
      ************************************************************************************************************************************/
      v_cgasges_def  NUMBER;
      v_cgasred_def  NUMBER;
      num_err        NUMBER;
      v_sproduc      NUMBER;
   BEGIN
      SELECT sproduc
        INTO v_sproduc
        FROM estseguros
       WHERE sseguro = psseguro;

      -- RSC 06/11/2008 Se establece una tabla de parametrización de gastos
      -- de Unit Linked para estos productos -------------------------------
      BEGIN
         SELECT cgasto
           INTO v_cgasges_def
           FROM gastosprodulk
          WHERE sproduc = v_sproduc
            AND ctipo = 1;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN(180428);
      END;

      BEGIN
         SELECT cgasto
           INTO v_cgasred_def
           FROM gastosprodulk
          WHERE sproduc = v_sproduc
            AND ctipo = 2;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN(180428);
      END;

      -- Actualizamos los gastos de gestión y redistribución en ESTSEGUROS_ULK con los valores por defecto
      BEGIN
         UPDATE estseguros_ulk
            SET cgasges = v_cgasges_def,
                cgasred = v_cgasred_def
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, 'Produccion_Ulk.F_actualiza_modelogastos', NULL,
                        'haciendo el update estseguros_ulk : psseguro =' || psseguro
                        || ' pcdefecto =' || pcdefecto || ' pcgasges =' || pcgasges
                        || ' pcgasred =' || pcgasred,
                        SQLERRM);
            RETURN 108190;   -- Error General
      END;

/*
          IF NVL(f_parproductos_v(v_sproduc,'PRODUCTO_MIXTO'),0) = 1 THEN -- Ibex 35 Garantizado
            BEGIN
              select cgasto INTO v_cgasges_def
              from detgastos_ulk
              where pgasto = 0
                and ctipo = 1;  -- Gestión
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                  RETURN (180428);
            END;

            BEGIN
              select cgasto INTO v_cgasred_def
              from detgastos_ulk
              where pgasto = 0
                and ctipo = 2;  -- Redistribución
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                  RETURN (180428);
            END;

            -- Actualizamos los gastos de gestión y redistribución en ESTSEGUROS_ULK con los valores por defecto
            BEGIN
                UPDATE estseguros_ulk
                SET cgasges = v_cgasges_def, cgasred = v_cgasred_def
                WHERE sseguro = psseguro;
            EXCEPTION
                WHEN OTHERS THEN
                           p_tab_error (f_sysdate,  F_USER, 'Pac_Prod_Ulk.F_actualiza_modelogastos', NULL,
                               'haciendo el update estseguros_ulk : psseguro ='||psseguro||' pcdefecto ='||pcdefecto||' pcgasges ='||pcgasges||' pcgasred ='||pcgasred,SQLERRM);
                    RETURN 108190;  -- Error General
            END;
          ELSE
            --------------------------------------------------------------------------
            -- Se modifican el campo estseguros_ulk.cmodinv
            --------------------------------------------------------------------------
            IF pcdefecto = 1 THEN
              -- Obtenemos el gasto de gestión por defecto
              BEGIN
                  SELECT cgasto INTO v_cgasges_def
                  FROM DETGASTOS_ULK
                  WHERE ctipo=1
                        AND cdefect = 1
                        AND ffinvig is null;
              EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                      RETURN (180428);
              END;

              -- Obtenemos el gasto de redistribución por defecto
              BEGIN
                  SELECT cgasto INTO v_cgasred_def
                  FROM DETGASTOS_ULK
                  WHERE ctipo=2
                        AND cdefect = 1
                        AND ffinvig is null;
              EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                      RETURN (180428);
              END;

              -- Actualizamos los gastos de gestión y redistribución en ESTSEGUROS_ULK con los
              -- valores por defecto.
              BEGIN
                  UPDATE estseguros_ulk
                  SET cgasges = v_cgasges_def, cgasred = v_cgasred_def
                  WHERE sseguro = psseguro;
              EXCEPTION
                  WHEN OTHERS THEN
                             p_tab_error (f_sysdate,  F_USER, 'Pac_Prod_Ulk.F_actualiza_modelogastos', NULL,
                                 'haciendo el update estseguros_ulk : psseguro ='||psseguro||' pcdefecto ='||pcdefecto||' pcgasges ='||pcgasges||' pcgasred ='||pcgasred,SQLERRM);
                      RETURN 108190;  -- Error General
              END;
            ELSE
              -- Si le pasamos los codigos de gasto de gestión y redistribución
              -- pues simplemente actualizamos los valores en estseguros_ulk
              BEGIN
                  UPDATE estseguros_ulk
                  SET cgasges = pcgasges, cgasred = pcgasred
                  WHERE sseguro = psseguro;
              EXCEPTION
                  WHEN OTHERS THEN
                             p_tab_error (f_sysdate,  F_USER, 'Pac_Prod_Ulk.F_actualiza_modelogastos', NULL,
                                 'haciendo el update estseguros_aho : psseguro ='||psseguro||' pcdefecto ='||pcdefecto||' pcgasges ='||pcgasges||' pcgasred ='||pcgasred,SQLERRM);
                      RETURN 108190;  -- Error General
              END;
            END IF;
          END IF;
*/
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Pac_Prod_Ulk.F_actualiza_modelogastos', NULL,
                     'haciendo el update estseguros_aho : psseguro =' || psseguro
                     || ' pcdefecto =' || pcdefecto || ' pcgasges =' || pcgasges
                     || ' pcgasred =' || pcgasred,
                     SQLERRM);
         RETURN 108190;   -- Error General
   END f_actualiza_modelogastos;

   FUNCTION f_cambio_gastos(v_est_sseguro IN NUMBER, pcgasges IN NUMBER, pcgasred IN NUMBER)
      RETURN NUMBER IS
   BEGIN
      IF pcgasges IS NOT NULL THEN
         UPDATE estseguros_ulk
            SET cgasges = pcgasges
          WHERE sseguro = v_est_sseguro;
      END IF;

      IF pcgasred IS NOT NULL THEN
         UPDATE estseguros_ulk
            SET cgasred = pcgasred
          WHERE sseguro = v_est_sseguro;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Pac_Prod_Ulk.f_cambio_gastos', NULL,
                     'parametros: v_est_sseguro =' || v_est_sseguro || '  pcgasges ='
                     || pcgasges || '  pcgasred = ' || pcgasred,
                     SQLERRM);
         RETURN 180482;   -- Error al modificar los gastos asociadosd
   END f_cambio_gastos;

   FUNCTION f_cambio_minversion(
      v_est_sseguro IN NUMBER,
      pcmodinv IN NUMBER,
      pmodinv IN pac_ref_contrata_ulk.cartera)
      RETURN NUMBER IS
      CURSOR cur_estsegdisin2 IS
         SELECT nriesgo, nmovimi, finicio, ccesta
           FROM estsegdisin2
          WHERE sseguro = v_est_sseguro
            AND ffin IS NULL
            AND nmovimi = (SELECT MAX(nmovimi)
                             FROM estsegdisin2
                            WHERE sseguro = v_est_sseguro
                              AND ffin IS NULL);

      v_nriesgo      NUMBER;
      v_nmovimi      NUMBER;
      v_finicio      DATE;
   BEGIN
      UPDATE estseguros_ulk
         SET cmodinv = pcmodinv
       WHERE sseguro = v_est_sseguro;

      -- esborrem la distribució actual de estsegdisin2 (posteriorment la tornarem a crear)
      FOR regs IN cur_estsegdisin2 LOOP
         v_nriesgo := regs.nriesgo;
         v_nmovimi := regs.nmovimi;
         v_finicio := regs.finicio;

         DELETE FROM estsegdisin2
               WHERE sseguro = v_est_sseguro
                 AND nriesgo = regs.nriesgo
                 AND nmovimi = regs.nmovimi
                 AND ccesta = regs.ccesta;
      END LOOP;

      FOR i IN 1 .. pmodinv.LAST LOOP
         INSERT INTO estsegdisin2
                     (sseguro, nriesgo, nmovimi, finicio, ffin,
                      ccesta, pdistrec)
              VALUES (v_est_sseguro, v_nriesgo, v_nmovimi, TRUNC(f_sysdate), NULL,
                      pac_util.splitt(pmodinv(i), 1, '|'), pac_util.splitt(pmodinv(i), 2, '|'));
      END LOOP;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Pac_Prod_Ulk.f_cambio_minversion', NULL,
                     'parametros: v_est_sseguro =' || v_est_sseguro || '  pcmodinv ='
                     || pcmodinv,
                     SQLERRM);
         RETURN 180482;   -- Error al modificar el modelo de inversión asociado
   END f_cambio_minversion;

   FUNCTION f_generar_redistribucion(v_est_sseguro IN NUMBER, pfefecto IN DATE)
      RETURN NUMBER IS
      num_err        NUMBER;
   BEGIN
      num_err := pac_operativa_ulk.f_redistribucion_fondos(v_est_sseguro);

      IF num_err <> 0 THEN
         p_tab_error(f_sysdate, f_user, 'Pac_Prod_Ulk.f_generar_redistribucion', NULL,
                     'parametros: v_est_sseguro = ' || v_est_sseguro,
                     f_literal(num_err, f_idiomauser));
         RETURN num_err;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Pac_Prod_Ulk.f_generar_redistribucion', NULL,
                     'parametros: v_est_sseguro = ' || v_est_sseguro,
                     f_literal(num_err, f_idiomauser));
         RETURN 180482;   -- Error al modificar el modelo de inversión asociado
   END f_generar_redistribucion;
END pac_prod_ulk;

/

  GRANT EXECUTE ON "AXIS"."PAC_PROD_ULK" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_PROD_ULK" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_PROD_ULK" TO "PROGRAMADORESCSI";
