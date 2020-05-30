--------------------------------------------------------
--  DDL for Package Body PAC_PROD_RENTAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_PROD_RENTAS" AS
/****************************************************************************

   NOMBRE:       PAC_PROD_RENTAS
   PROPÓSITO:  Funciones para productos de rentas

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ----------  ----------------------------------
   1.0           -          -         Creació del package
   2.0        20/04/2009   APD        Bug 9685 - en lugar de coger la acticad de la tabla seguros, llamar a la función pac_seguros.ff_get_actividad
   3.0        11/02/2013   NMM        26. 24735: (POSDE600)-Desarrollo-GAPS Tecnico-Id 33 - Mesadas Extras diferentes a la propia (preguntas)
****************************************************************************/

   /********************************************************************************************************************************
       Función que modifica la forma de pago de la prestación
       Parámetros de entrada: . pcfprest = Código de la nueva forma de pago de la prestación (0.Capital; 1. Renta Mensual Vitalicia)
    *****************************************************************************************************************************/
   FUNCTION f_post_penalizacion(psseguro IN NUMBER)
      RETURN NUMBER IS
      v_nmovimi      NUMBER;
      v_nanyo        NUMBER;

      CURSOR cur_penaliseg IS
         SELECT   (100 - ppenali) rescate
             FROM penaliseg p1
            WHERE p1.sseguro = psseguro
              AND p1.nmovimi = (SELECT MAX(p2.nmovimi)
                                  FROM penaliseg p2
                                 WHERE p2.sseguro = p1.sseguro)
         ORDER BY niniran, nfinran;
   BEGIN
      -- Se busca el valor del movimiento de penalización
      SELECT MAX(nmovimi)
        INTO v_nmovimi
        FROM penaliseg
       WHERE sseguro = psseguro;

      -- Se insertan los mismos registros que en el último movimiento, pero con nmovimi = al movimiento de penalización
      INSERT INTO evoluprovmatseg
                  (sseguro, nmovimi, nanyo, fprovmat, iprovmat, icapfall, prescate, pinttec,
                   iprovest, crevisio)
         SELECT   evo.sseguro, v_nmovimi, evo.nanyo, evo.fprovmat, evo.iprovmat, evo.icapfall,
                  evo.prescate, evo.pinttec, evo.iprovest, evo.crevisio   --Tarea 6966
             FROM evoluprovmatseg evo
            WHERE evo.sseguro = psseguro
              AND evo.nmovimi = (SELECT MAX(evo2.nmovimi)
                                   FROM evoluprovmatseg evo2
                                  WHERE evo2.sseguro = evo.sseguro)
         ORDER BY evo.nanyo, evo.fprovmat;

      -- Se busca el valor mínimo del año para saber a partir de qué año se deben actualizar los rescates
      SELECT   MIN(nanyo)
          INTO v_nanyo
          FROM evoluprovmatseg evo
         WHERE evo.sseguro = psseguro
           AND evo.nmovimi = (SELECT MAX(evo2.nmovimi)
                                FROM evoluprovmatseg evo2
                               WHERE evo2.sseguro = evo.sseguro)
      ORDER BY evo.nanyo, evo.fprovmat;

      FOR reg IN cur_penaliseg LOOP
         -- Se actualiza la tabla evoluprovmatseg con los rescates obtenidos a partir de la tabla de penalizacion
         UPDATE evoluprovmatseg evo
            SET prescate = reg.rescate
          WHERE evo.sseguro = psseguro
            AND evo.nmovimi = (SELECT MAX(evo2.nmovimi)
                                 FROM evoluprovmatseg evo2
                                WHERE evo2.sseguro = evo.sseguro)
            AND evo.nanyo = v_nanyo;

         v_nanyo := v_nanyo + 1;
      END LOOP;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Pac_Prod_Rentas==> f_post_penalizacion', NULL,
                     'parámetros : SSEGURO =' || psseguro, SQLERRM);
         RETURN 107405;   -- ERROR AL CALCULAR LOS VALORES DE RESCATE
   END f_post_penalizacion;

--JRH IMP Esto hay que ponerlo en el PAC_PROD_COMU
   FUNCTION f_grabar_garantias_rentas(
      pmodo IN NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      pfefecto IN DATE,
      prima_per IN NUMBER,
      pfallaseg IN NUMBER)
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

      /*UPDATE estgaranseg
      SET  prevali = pprevali
      WHERE sseguro = psseguro
        AND cgarant IN (SELECT cgarant FROM garanpro
                          WHERE sproduc = v_sproduc
                          AND crevali <> 0) ;*/

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
                   0) = 6
               AND NVL(f_pargaranpro_v(v_cramo, v_cmodali, v_ctipseg, v_ccolect, v_cactivi,
                                       gar.cgarant, 'PROPIETARIO'),
                       0) = 1 THEN
            IF pfallaseg <> 0 THEN
               v_cobliga := 1;
            -- JRH  Va por fórmula v_icapital:=rounD(prima_per*pcfallaseg1/100,2);
            ELSIF pfallaseg = 0 THEN
               --v_cobliga := 0; JRH IMP Siempre la contratamos
               v_cobliga := 1;
               v_icapital := 0;
            END IF;
         -- PRIMA FALLECIMIENTO SEGUNDO ASEGURADO
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
         p_tab_error(f_sysdate, f_user, 'pk_nueva_produccion2.f_grabar_garantias_rentas',
                     traza,
                     'parametros: pmodo =' || pmodo || ' psseguro =' || psseguro
                     || ' pnriesgo =' || pnriesgo || ' pnmovimi =' || pnmovimi
                     || ' pfefecto =' || pfefecto || ' prima_inicial = ' || 0
                     || ' prima_per =' || prima_per || ' pprevali=' || 0 || ' pcfallaseg1 ='
                     || pfallaseg || ' pcfallaseg2 =' || 0 || ' pcaccaseg1=' || 0
                     || ' pcaccaseg2 =' || 0,
                     SQLERRM);
         RETURN 108190;   -- Error General
   END f_grabar_garantias_rentas;

   FUNCTION f_graba_propuesta_rentas(
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
      psclaben IN NUMBER,
      ptclaben IN VARCHAR2,
      prima_per IN NUMBER,
      pfallaseg IN NUMBER,
      tab_pregun pac_prod_comu.t_preguntas,
      pforpagorenta IN NUMBER,
      psseguro IN OUT NUMBER)
      RETURN NUMBER IS
      /*****************************************************************************************************************************************
        En esta función se grabará una póliza de ahorro en las tablas EST con todos los datos y se tarifará.
        Devolverá el capital garantizado al vencimiento, el capital de fallecimiento (primer periodo) y el capital garantizado
        en el primer periodo.

             Si el parámetro psseguro NO viene infomado será una propuesta nueva, por lo tanto se inserta en las tablas EST
             Si el parámetro psseguro SI llega informado será una modificación de los datos de la propuesta.

             La función retorna:
                -- 0: si todo es correcto
                -- codigo error: si hay error.
      ************************************************************************************************************************************/
      error          EXCEPTION;
      num_err        NUMBER;
      tramolrc       NUMBER;
   BEGIN
      -- Primero inicializamos la propuesta, es decir, grabamos todos los datos y tarifamos
      num_err := pac_prod_comu.f_inicializa_propuesta(psproduc, psperson1, pcdomici1,
                                                      psperson2, pcdomici2, pcagente,
                                                      pcidioma, pfefecto, pnduraci, pfvencim,
                                                      pcforpag, pcbancar, psclaben, ptclaben,
                                                      0, prima_per, 0, pfallaseg, 0, 0, 0,
                                                      psseguro, tab_pregun, pforpagorenta);

      IF num_err <> 0 THEN
         RAISE error;
      ELSE
         -- Recuperamos los datos que mostraremos por pantalla JRH Aui hemos de poner lo que se muestra en el caso de las rentas
         /*IF nvl(f_parproductos_v(psproduc, 'TRAMOINTTEC'), 0) = 3 THEN
                  tramoLRC:=pnduraci||LPAD(1,3,0); --Hemos de escoger la primera anualidad que toca
              ELSE
                  tramoLRC:=0;
            END IF;


         num_err := pac_calc_rentas.f_get_capitales_rentas(psproduc, psseguro, pfefecto,tramoLRC,1,1,rentabruta, rentamin, capfall,intgarant);

         IF num_err <> 0 THEN
            RAISE error;
              END IF;*/
         NULL;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN error THEN
         RETURN num_err;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Pac_Prod_Rentas.f_graba_propuesta_rentas', NULL,
                     'parametros: psproduc =' || psproduc || ' psperson1 =' || psperson1
                     || ' pcdomici1 =' || pcdomici1 || ' psperson2 =' || psperson2
                     || ' pcdomici2 =' || pcdomici2 || ' pcagente=' || pcagente
                     || ' pcidioma=' || pcidioma || ' pfefecto=' || pfefecto || ' pnduraci='
                     || pnduraci || ' pfvencim=' || pfvencim || ' pcforpag=' || pcforpag
                     || ' pcbancar=' || pcbancar || ' psclaben=' || psclaben || ' ptclaben='
                     || ptclaben || ' prima_inicial = ' || 0 || ' prima_per =' || prima_per
                     || ' prevali=' || 0 || ' pcfallaseg1 =' || pfallaseg || ' pcfallaseg2 ='
                     || 0 || ' pcaccaseg1=' || 0 || ' pcaccaseg2 =' || 0 || ' psseguro='
                     || psseguro,
                     SQLERRM);
         RETURN(108190);   -- Error general
   END f_graba_propuesta_rentas;

-- JRH 11/2007 Lo hemos puesto en el comu
  --JRH IMP En principio la duración no se puede cambiar
   /********************************************************************************************************************************
      Función que marca una póliza para su renovación/revisión con los nuevos valores a aplicar: duración y
      % de interés garantizado.

      Parámetros de entrada:
           . psseguro = Identificador de la póliza
           . pndurper = Duración Período
           . ppinttec = % de interés técnico
                     . pcapital = nuevo capital de fallecimiento para rentas

           La función retorna:
              0 - si ha ido bien
              codigo error - si hay algún error.
   *********************************************************************************************************************************/
   FUNCTION f_leer_nmesextra(
      pnmesextra IN VARCHAR2,
      pnmes1 OUT NUMBER,
      pnmes2 OUT NUMBER,
      pnmes3 OUT NUMBER,
      pnmes4 OUT NUMBER,
      pnmes5 OUT NUMBER,
      pnmes6 OUT NUMBER,
      pnmes7 OUT NUMBER,
      pnmes8 OUT NUMBER,
      pnmes9 OUT NUMBER,
      pnmes10 OUT NUMBER,
      pnmes11 OUT NUMBER,
      pnmes12 OUT NUMBER)
      RETURN NUMBER IS
      vvalor         VARCHAR2(3);
      vmes           NUMBER := 1;
   BEGIN
      FOR vmes IN 1 .. 12 LOOP
         IF vmes = 1 THEN
            vvalor := SUBSTR(pnmesextra, 1, 1);
         ELSE
            vvalor := SUBSTR(pnmesextra, INSTR(pnmesextra, '|', 1, vmes - 1) + 1,
                             LENGTH(vmes));
         END IF;

         IF vmes = 1 THEN
            IF vvalor = TO_CHAR(vmes) THEN
               pnmes1 := 1;
            ELSE
               pnmes1 := 0;
            END IF;
         ELSIF vmes = 2 THEN
            IF vvalor = TO_CHAR(vmes) THEN
               pnmes2 := 1;
            ELSE
               pnmes2 := 0;
            END IF;
         ELSIF vmes = 3 THEN
            IF vvalor = TO_CHAR(vmes) THEN
               pnmes3 := 1;
            ELSE
               pnmes3 := 0;
            END IF;
         ELSIF vmes = 4 THEN
            IF vvalor = TO_CHAR(vmes) THEN
               pnmes4 := 1;
            ELSE
               pnmes4 := 0;
            END IF;
         ELSIF vmes = 5 THEN
            IF vvalor = TO_CHAR(vmes) THEN
               pnmes5 := 1;
            ELSE
               pnmes5 := 0;
            END IF;
         ELSIF vmes = 6 THEN
            IF vvalor = TO_CHAR(vmes) THEN
               pnmes6 := 1;
            ELSE
               pnmes6 := 0;
            END IF;
         ELSIF vmes = 7 THEN
            IF vvalor = TO_CHAR(vmes) THEN
               pnmes7 := 1;
            ELSE
               pnmes7 := 0;
            END IF;
         ELSIF vmes = 8 THEN
            IF vvalor = TO_CHAR(vmes) THEN
               pnmes8 := 1;
            ELSE
               pnmes8 := 0;
            END IF;
         ELSIF vmes = 9 THEN
            IF vvalor = TO_CHAR(vmes) THEN
               pnmes9 := 1;
            ELSE
               pnmes9 := 0;
            END IF;
         ELSIF vmes = 10 THEN
            IF vvalor = TO_CHAR(vmes) THEN
               pnmes10 := 1;
            ELSE
               pnmes10 := 0;
            END IF;
         ELSIF vmes = 11 THEN
            IF vvalor = TO_CHAR(vmes) THEN
               pnmes11 := 1;
            ELSE
               pnmes11 := 0;
            END IF;
         ELSIF vmes = 12 THEN
            IF vvalor = TO_CHAR(vmes) THEN
               pnmes12 := 1;
            ELSE
               pnmes12 := 0;
            END IF;
         END IF;
      END LOOP;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Pac_Prod_Rentas.f_leer_nmesextra', 1,
                     'parametros: pnmesextra: ' || pnmesextra, SQLERRM);
         RETURN(108190);   -- Error general
   END f_leer_nmesextra;

   FUNCTION f_set_nmesextra(psseguro IN NUMBER, pmesesextra IN VARCHAR2)
      RETURN NUMBER IS
      vcount         NUMBER;
   BEGIN
      UPDATE estseguros_ren
         SET nmesextra = pmesesextra
       WHERE sseguro = psseguro;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Pac_Prod_Rentas.f_set_nmesextra', 1,
                     'parametros psseguro: ' || psseguro, SQLERRM);
         ROLLBACK;
         RETURN(108190);   -- Error general
   END f_set_nmesextra;

   -- 24735.NMM.#6.02/2013.i.
   FUNCTION f_leer_imesextra(
      pimesextra IN VARCHAR2,
      pimes1 OUT NUMBER,
      pimes2 OUT NUMBER,
      pimes3 OUT NUMBER,
      pimes4 OUT NUMBER,
      pimes5 OUT NUMBER,
      pimes6 OUT NUMBER,
      pimes7 OUT NUMBER,
      pimes8 OUT NUMBER,
      pimes9 OUT NUMBER,
      pimes10 OUT NUMBER,
      pimes11 OUT NUMBER,
      pimes12 OUT NUMBER)
      RETURN NUMBER IS
      wimport        VARCHAR2(100);
      vmes           NUMBER := 1;
      wocurrencia    PLS_INTEGER := 0;   -- Ocurrència actual
      wocurrencia_ant PLS_INTEGER := 0;   -- Ocurrència anterior
      wpos_ini       PLS_INTEGER := 0;
      wpos_fi        PLS_INTEGER := 0;
      wlong          PLS_INTEGER := 0;
      wpas           PLS_INTEGER := 0;
   --
   BEGIN
      wpas := 1;

      FOR vmes IN 1 .. 12 LOOP
         wpas := 2;

         -- Trobem l'import   dins una cadena del tipus:
         -- 254.3||||||541.2|5214.122|6587.132|45.2|215.3|4654.122|
         IF vmes = 1 THEN
            wpas := 3;
            wimport := SUBSTR(pimesextra, 1, INSTR(pimesextra, '|', 1) - 1);
         ELSE
            wpas := 4;
            wpos_ini := INSTR(pimesextra, '|', 1, vmes - 1) + 1;
            wpos_fi := INSTR(pimesextra, '|', 1, vmes);
            wlong := wpos_fi - wpos_ini;
            wimport := SUBSTR(pimesextra, wpos_ini, wlong);
         END IF;

         wpas := 5;

         -- Assignem el valor trobat al mes corresponent.
         IF vmes = 1 THEN
            pimes1 := NVL(wimport, 0);
         ELSIF vmes = 2 THEN
            pimes2 := NVL(wimport, 0);
         ELSIF vmes = 3 THEN
            pimes3 := NVL(wimport, 0);
         ELSIF vmes = 4 THEN
            pimes4 := NVL(wimport, 0);
         ELSIF vmes = 5 THEN
            pimes5 := NVL(wimport, 0);
         ELSIF vmes = 6 THEN
            pimes6 := NVL(wimport, 0);
         ELSIF vmes = 7 THEN
            pimes7 := NVL(wimport, 0);
         ELSIF vmes = 8 THEN
            pimes8 := NVL(wimport, 0);
         ELSIF vmes = 9 THEN
            pimes9 := NVL(wimport, 0);
         ELSIF vmes = 10 THEN
            pimes10 := NVL(wimport, 0);
         ELSIF vmes = 11 THEN
            pimes11 := NVL(wimport, 0);
         ELSIF vmes = 12 THEN
            pimes12 := NVL(wimport, 0);
         END IF;
      END LOOP;

      wpas := 6;
--      p_tab_error(f_sysdate, f_user, 'Pac_Prod_Rentas.f_leer_imesextra', 1,
--                     'param: pimesxtra: ' || pimesextra
--              ||'1:'||pimes1||':2:'||pimes2||':3:'||pimes3||':4:'||pimes4||':5:'||pimes5||':6:'||pimes6
--              ||':7:'||pimes7||':8:'||pimes8||':9:'||pimes9||':10:'||pimes10||':11:'||pimes11||':12:'||pimes12
--              , SQLERRM);
      RETURN(0);
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Pac_Prod_Rentas.f_leer_imesextra', 1,
                     'param: pimesextra: ' || pimesextra, SQLERRM);
         RETURN(108190);   -- Error general
   END f_leer_imesextra;

   --
   FUNCTION f_set_imesextra(psseguro IN NUMBER, pimesesextra IN VARCHAR2)
      RETURN NUMBER IS
      vcount         NUMBER;
   BEGIN
      UPDATE estseguros_ren
         SET imesextra = pimesesextra
       WHERE sseguro = psseguro;

      COMMIT;
      RETURN(0);
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Pac_Prod_Rentas.f_set_nmesextra', 1,
                     'parametros psseguro: ' || psseguro, SQLERRM);
         ROLLBACK;
         RETURN(108190);   -- Error general
   END f_set_imesextra;
-- 24735.NMM.#6.02/2013.f.
END pac_prod_rentas;

/

  GRANT EXECUTE ON "AXIS"."PAC_PROD_RENTAS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_PROD_RENTAS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_PROD_RENTAS" TO "PROGRAMADORESCSI";
