--------------------------------------------------------
--  DDL for Package Body PAC_SIMUL_AHO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_SIMUL_AHO" AS
/******************************************************************************
   NOMBRE:     Pac_Simul_Aho
   PROPÓSITO:  Funciones para la simulacion de Ahorro

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        XX/XX/XXXX   XXX                1. Creación del package.
   2.0        30/04/2009   APD                2. Bug 9685 - primero se ha de buscar para la actividad en concreto
                                                 y si no se encuentra nada ir a buscar a GARANFORMULA para la actividad cero
   2.1        30/04/2009   APD                3. Bug 9685 - en lugar de coger la actividad de la tabla seguros, llamar a la
                                                 función pac_seguros.ff_get_actividad
******************************************************************************/

   --  f_get_dades_calculades
   --    Únicament preparada per simulacions
   --
   --  Paràmetres
   --      pssolicit  :  número de la simulació
   --      pfefecto   :  data d'alta de la pòlissa
   --      piprima    :  prima
   --      pcidioma_user: idioma del usuario
   --
   FUNCTION f_get_dades_calculades(
      pssolicit IN NUMBER,
      pfefecto IN DATE,
      piprima IN NUMBER,
      pcidioma_user IN literales.cidioma%TYPE,
      pnum_err OUT NUMBER)
      RETURN ob_resp_simula_pu IS
      -- Utilitzats per omplir la simulació
      v_tipo_penalizacion NUMBER;
      v_imp_penalizacion NUMBER;
      v_rendimiento  NUMBER(5, 2);
      vtsimulaanys   t_det_simula_pu := t_det_simula_pu();
      v_errores      ob_errores;
      vsimulacion    ob_resp_simula_pu;
      vintany        NUMBER(5, 2);
      v_fecha_calculo DATE;
      vcapfall       NUMBER;   --NUMBER(13, 2);
      vcapgar        NUMBER;   --NUMBER(13, 2);
      vprovmat       NUMBER;   --NUMBER(13, 2);
      v_error        literales.slitera%TYPE;
      vintprom       solpregunseg.crespue%TYPE;   -- NUMBER(5, 2);
      vintfin        NUMBER(5, 2);
      vintmin        NUMBER(5, 2);

      TYPE rt_dades IS RECORD(
         clave          garanformula.clave%TYPE,
         ccampo         garanformula.ccampo%TYPE
      );

      vr_garan       rt_dades;
      vr_fall        rt_dades;
      vr_provmat     rt_dades;
      ex_error       EXCEPTION;
      v_traza        tab_error.ntraza%TYPE;

      PROCEDURE validar(perror IN NUMBER) IS
      BEGIN
         IF perror <> 0 THEN
            v_errores := ob_errores(perror, f_axis_literales(perror, pcidioma_user));
            RAISE ex_error;
         END IF;
      END;
   BEGIN
      v_traza := 1;

      FOR rdades IN (
                     -- Bug 9685 - APD - 30/04/2009 - en lugar de coger la actividad de la tabla seguros, llamar a la función pac_seguros.ff_get_actividad
                     SELECT s.sproduc,
                            pac_seguros.ff_get_actividad(s.ssolicit, g.nriesgo, 'SOL')
                                                                                      cactivi,
                            s.fvencim, g.cgarant, s.ccolect, s.ctipseg, s.cmodali, s.cramo
                       FROM solgaranseg g, solseguros s
                      WHERE g.ssolicit = s.ssolicit
                        AND f_pargaranpro_v(s.cramo, s.cmodali, s.ctipseg, s.ccolect, 0,
                                            g.cgarant, 'TIPO') = 5   -- Capital garantizado
                        AND s.ssolicit = pssolicit
                                                  -- Bug 9685 - APD - 30/04/2009 - Fin
                   ) LOOP
         FOR rformula IN (
                          -- Bug 9685 - APD - 30/04/2009 - primero se ha de buscar para la actividad en concreto
                          -- y si no se encuentra nada ir a buscar a GARANFORMULA para la actividad cero
                          SELECT gf.clave, gf.ccampo
                            FROM garanformula gf
                           WHERE gf.cgarant = rdades.cgarant
                             AND gf.cramo = rdades.cramo
                             AND gf.cmodali = rdades.cmodali
                             AND gf.ctipseg = rdades.ctipseg
                             AND gf.ccolect = rdades.ccolect
                             AND gf.cactivi = rdades.cactivi
                          UNION
                          SELECT gf.clave, gf.ccampo
                            FROM garanformula gf
                           WHERE gf.cgarant = rdades.cgarant
                             AND gf.cramo = rdades.cramo
                             AND gf.cmodali = rdades.cmodali
                             AND gf.ctipseg = rdades.ctipseg
                             AND gf.ccolect = rdades.ccolect
                             AND gf.cactivi = 0
                             AND NOT EXISTS(SELECT gf.clave, gf.ccampo
                                              FROM garanformula gf
                                             WHERE gf.cgarant = rdades.cgarant
                                               AND gf.cramo = rdades.cramo
                                               AND gf.cmodali = rdades.cmodali
                                               AND gf.ctipseg = rdades.ctipseg
                                               AND gf.ccolect = rdades.ccolect
                                               AND gf.cactivi = rdades.cactivi)
                                                                               -- Bug 9685 - APD - 30/04/2009 - Fin
                        ) LOOP
            CASE rformula.ccampo
               WHEN 'ICGARAC' THEN
                  vr_garan.clave := rformula.clave;
                  vr_garan.ccampo := rformula.ccampo;
                  NULL;
               WHEN 'IPROVAC' THEN
                  vr_provmat.clave := rformula.clave;
                  vr_provmat.ccampo := rformula.ccampo;
               WHEN 'ICFALLAC' THEN
                  vr_fall.clave := rformula.clave;
                  vr_fall.ccampo := rformula.ccampo;
               ELSE
                  NULL;
            END CASE;
         END LOOP;

         FOR v_i IN 1 .. 1 LOOP   -- solo devolvemos el primer año
            v_fecha_calculo := ADD_MONTHS(pfefecto, 12 * v_i) - 1;
            v_traza := 10;
            validar(pac_calculo_formulas.calc_formul(v_fecha_calculo, rdades.sproduc,
                                                     rdades.cactivi, rdades.cgarant, 1,
                                                     pssolicit, vr_garan.clave, vcapgar, NULL,
                                                     NULL, 0, pfefecto, 'R'));
            v_traza := 11;
            validar(pac_calculo_formulas.calc_formul(v_fecha_calculo, rdades.sproduc,
                                                     rdades.cactivi, rdades.cgarant, 1,
                                                     pssolicit, vr_fall.clave, vcapfall, NULL,
                                                     NULL, 0, pfefecto, 'R'));
            v_traza := 111;
            validar(pac_calculo_formulas.calc_formul(v_fecha_calculo, rdades.sproduc,
                                                     rdades.cactivi, rdades.cgarant, 1,
                                                     pssolicit, vr_provmat.clave, vprovmat,
                                                     NULL, NULL, 0, pfefecto, 'R'));
            v_traza := 12;
            vintany := pac_inttec.ff_int_producto(rdades.sproduc, 3, v_fecha_calculo, piprima);
            -- pctipmov => Rescates totales
            v_traza := 13;
            validar(f_penalizacion(3, 2, rdades.sproduc, NULL, pfefecto, v_imp_penalizacion,
                                   v_tipo_penalizacion, 'SOL', 1));
            v_traza := 14;
            vtsimulaanys.EXTEND;
            vtsimulaanys(vtsimulaanys.LAST) :=
               ob_det_simula_pu(v_i, v_fecha_calculo, vcapgar, vcapfall, vprovmat,
                                CASE v_tipo_penalizacion
                                   WHEN 1 THEN NVL(v_imp_penalizacion, 0)
                                   ELSE 100 - NVL(v_imp_penalizacion, 0)
                                END,
                                vintany);
         END LOOP;

         v_traza := 30;

         -- Dades de la simulació
         IF vtsimulaanys.FIRST IS NOT NULL THEN
            -- Nota : Calcula mesos enlloc d'anys per si agafem un anys parcial
            v_rendimiento := ROUND(((vcapgar / piprima) **(12
                                                           / MONTHS_BETWEEN(rdades.fvencim,
                                                                            pfefecto))
                                    - 1)
                                   * 100,
                                   2);
         ELSE
            -- Com ho calculem si hi ha aportacions posteriors a la prima inicial ?
            v_rendimiento := NULL;
         END IF;

         v_traza := 31;

         -- Calculamos el interés promocional
         BEGIN
            SELECT DECODE(crespue, 0, vintany, crespue)
              INTO vintprom
              FROM solpregunseg
             WHERE ssolicit = pssolicit
               AND crespue = 6;
         EXCEPTION
            WHEN OTHERS THEN
               vintprom := vintany;
         END;

         v_traza := 32;
         -- Calculamos el interés financiero
         vintfin := ROUND(((vprovmat / piprima) - 1) * 100, 2);
         v_traza := 33;
         -- Calculamos el interés mínimo garantizado
         vintmin := pac_inttec.ff_int_producto(rdades.sproduc, 1, v_fecha_calculo, piprima);
         v_traza := 34;
         vsimulacion := ob_resp_simula_pu(pssolicit, vtsimulaanys, piprima, v_rendimiento,
                                          vcapgar, vintprom, vintfin, vintmin, v_errores);
         EXIT;   -- Només hi ha d'haver un registre
      END LOOP;

      RETURN vsimulacion;
   EXCEPTION
      WHEN ex_error THEN
         p_tab_error(f_sysdate, f_user, 'pac_simul_aho.f_get_dades_calculades', v_traza,
                     'parametros: pssolicit =' || pssolicit || ' piprima =' || piprima,
                     'ERROR-' || v_errores.cerror || ':' || v_errores.terror);
         RETURN ob_resp_simula_pu(pssolicit, vtsimulaanys, NULL, NULL, NULL, NULL, NULL, NULL,
                                  v_errores);
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_simul_aho.f_get_dades_calculades', v_traza,
                     'parametros: pssolicit =' || pssolicit || ' piprima =' || piprima,
                     SQLERRM);
         RETURN ob_resp_simula_pu(pssolicit, vtsimulaanys, NULL, NULL, NULL, NULL, NULL, NULL,
                                  ob_errores(180160, f_axis_literales(180160, pcidioma_user)));
   END;

   FUNCTION f_genera_sim_pu(
      ptipo IN NUMBER,
      psproduc IN NUMBER,
      pnombre1 IN VARCHAR2,
      ptapelli1 IN VARCHAR2,
      pfnacimi1 IN DATE,
      psexo1 IN NUMBER,
      pnombre2 IN VARCHAR2,
      ptapelli2 IN VARCHAR2,
      pfnacimi2 IN DATE,
      psexo2 IN NUMBER,
      piprima IN NUMBER,
      pndurper IN NUMBER,
      pfvencim IN DATE,
      ppinttec IN NUMBER,
      psseguro IN NUMBER,
      pfefecto IN DATE,
      pssolicit OUT NUMBER)
      RETURN NUMBER IS
      /**********************************************************************************************************************************
            f_genera_sim_pu: Función que genera la simulación y la tarificación (calcula datos)
           26-2-2007. CSI
           Vida Ahorro

           La función retornará
               a) Si todo es correcto: 0
              b) Si hay un error: código de error

      **********************************************************************************************************************************/
      v_ssolicit     NUMBER;
      num_err        NUMBER;
      v_nduraci      NUMBER;
      v_fvencim      DATE;
      v_errores      ob_errores;
      error          EXCEPTION;
      v_traza        tab_error.ntraza%TYPE;
   BEGIN
  --------------------------
  -- se crea la solicitud --
--------------------------
      v_traza := 1;
      num_err := pk_simulaciones.f_crea_solicitud(psproduc, v_ssolicit, 1, pfefecto);

      IF num_err <> 0 THEN
         RAISE error;
      END IF;

 ---------------------------------------
-- actualizamos los datos del riesgo --
---------------------------------------
      v_traza := 2;
      num_err := pac_simul_comu.f_actualiza_riesgo(v_ssolicit, 1, pfnacimi1, psexo1, pnombre1,
                                                   ptapelli1);

      IF num_err <> 0 THEN
         RAISE error;
      END IF;

------------------------------------------
-- actualizamos los datos del asegurado --
------------------------------------------
      v_traza := 3;
      num_err := pac_simul_comu.f_actualiza_asegurado(v_ssolicit, 1, pfnacimi1, psexo1,
                                                      pnombre1, ptapelli1);

      IF num_err <> 0 THEN
         RAISE error;
      END IF;

---------------------------------------------
-- Informa los datos del segundo asegurado --
---------------------------------------------
      v_traza := 4;

      IF pfnacimi2 IS NOT NULL THEN   -- hay 2 asegurados
         num_err := pac_simul_comu.f_crea_solasegurado(v_ssolicit, 2, ptapelli2, pnombre2,
                                                       pfnacimi2, psexo2);

         IF num_err <> 0 THEN
            RAISE error;
         END IF;
      END IF;

  ---------------------------
-- actualizamos la prima --
---------------------------
      v_traza := 5;
      num_err := pac_simul_comu.f_actualiza_capital(v_ssolicit, 1, 48, piprima);

      IF num_err <> 0 THEN
         RAISE error;
      END IF;

 ----------------------------------------------------------
-- actualizamos la duración periodo interés garantizado --
----------------------------------------------------------
      v_traza := 6;
      v_nduraci := pndurper;
      v_fvencim := pfvencim;

      IF pfvencim IS NOT NULL THEN
         -- MSR Ref 1991
         num_err := pac_calc_comu.f_calcula_fvencim_nduraci(psproduc, pfnacimi1, pfefecto,
                                                            NULL, v_nduraci, v_fvencim);
      END IF;

      -- el producto utiliza duración periodo
      IF NVL(f_parproductos_v(psproduc, 'DURPER'), 0) = 1 THEN   -- Producto Europlazo 16 o Euroterm 16
         v_traza := 7;
         num_err := pac_simul_comu.f_actualiza_duracion_periodo(v_ssolicit, v_nduraci);

         IF num_err <> 0 THEN
            RAISE error;
         END IF;
      ELSE   -- psproduc IN (85, 86, 87, 88, 89, 90) = Producto Ahorro Seguro
         v_traza := 8;
         num_err := pac_simul_comu.f_actualiza_duracion(v_ssolicit, v_nduraci, v_fvencim);

         IF num_err <> 0 THEN
            RAISE error;
         END IF;
      END IF;

 -------------------------------------
-- se inserta el interés técnico --
-------------------------------------
      v_traza := 9;
      num_err := pac_simul_comu.f_ins_inttec(v_ssolicit, pfefecto, ppinttec);

      IF num_err <> 0 THEN
         RAISE error;
      END IF;

 ---------------
-- tarifamos --
---------------
      v_traza := 10;
      num_err := pac_tarifas.f_tarifar_riesgo_tot('SOL', v_ssolicit, 1, 1,

                                                  -- JLB - I - BUG 18423 COjo la moneda del producto
                                                                                         --       1, ,
                                                  pac_monedas.f_moneda_producto(psproduc),

                                                  -- JLB - F- BUG 18423 COjo la moneda del producto
                                                  pfefecto);

      IF num_err <> 0 THEN
         RAISE error;
      END IF;

-----------------------
-- Valor de ssolicit --
-----------------------
      v_traza := 11;
      pssolicit := v_ssolicit;
      RETURN 0;   -- Todo OK
   EXCEPTION
      WHEN error THEN
         RETURN num_err;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_simul_aho.f_genera_sim_pu', v_traza,
                     'parametros: sproduc =' || psproduc || ' ptipo =' || ptipo
                     || ' pnombre1=' || pnombre1 || ' ptapelli1=' || ptapelli1
                     || ' pfnacimi1=' || pfnacimi1 || ' psexo1=' || psexo1 || ' pnombre2='
                     || pnombre2 || ' ptapelli2=' || ptapelli2 || ' pfnacimi2=' || pfnacimi2
                     || ' psexo1=' || psexo2 || ' piprima=' || piprima || ' pndurper='
                     || pndurper || ' ppinttec=' || ppinttec || ' psseguro=' || psseguro,
                     SQLERRM);
         RETURN(108190);   -- Error general
   END f_genera_sim_pu;

-- ---------------------------------------------------------------------------------------
--       f_get_evoluprovmat: Devuelve los datos de la simulación
--
--       La función retornará
--           a) Si todo es correcto: 0
--           b) Si hay un error: código de error en el parámetro de salida pnum_err
--
-- ---------------------------------------------------------------------------------------
   FUNCTION f_get_evoluprovmat(
      pssolicit IN NUMBER,
      pndurper IN NUMBER,
      pnanyos_transcurridos IN NUMBER,
      pnum_err OUT NUMBER)
      RETURN t_det_simula_pu IS
      /**********************************************************************************************************************************
             f_get_evoluprovmat: Devuelve los datos de la tabla SOLEVOLUPROVMATSEG
             2-1-2007. CSI
             Vida Ahorro

             La función retornará
                 a) Si todo es correcto: 0
                 b) Si hay un error: código de error en el parámetro de salida pnum_err

      **********************************************************************************************************************************/
      v_t_det_simula_pu t_det_simula_pu := t_det_simula_pu();
      v_ob_det_simula_pu ob_det_simula_pu;
      ncount         NUMBER := 0;

      CURSOR c_prov IS
         SELECT   *
             FROM solevoluprovmatseg
            WHERE ssolicit = pssolicit
              AND nanyo <= pndurper
         ORDER BY nanyo, fprovmat;
   BEGIN
      pnum_err := 0;
      v_t_det_simula_pu.DELETE;

      FOR prov IN c_prov LOOP
         ncount := ncount + 1;
         v_t_det_simula_pu.EXTEND;
         v_ob_det_simula_pu := ob_det_simula_pu(prov.nanyo + pnanyos_transcurridos,
                                                prov.fprovmat, prov.iprovmat, prov.icapfall,
                                                prov.iprovest, prov.prescate, prov.pinttec);
         v_t_det_simula_pu(ncount) := v_ob_det_simula_pu;
      END LOOP;

      RETURN v_t_det_simula_pu;
   EXCEPTION
      WHEN OTHERS THEN
         v_ob_det_simula_pu := NULL;
         v_t_det_simula_pu.DELETE;
         pnum_err := 180160;   -- Error al leer de la tabla EVOLUPROVMATSEG
         p_tab_error(f_sysdate, f_user, 'pac_simul_aho.f_get_evoluprovmat', NULL,
                     'parametros: pssolicit =' || pssolicit || ' pndurper =' || pndurper,
                     SQLERRM);
         RETURN v_t_det_simula_pu;
   END f_get_evoluprovmat;

      -- Ref 2253. : F_GENERA_SIM_PP.
   --
   --       F_GENERA_SIM_PP:
   --
   --       La función retornará
   --           a) Si todo es correcto: 0
   --           b) Si hay un error: código de error en el parámetro de salida pnum_err
   --
   FUNCTION f_genera_sim_pp(
      psproduc IN NUMBER,
      psseguro IN NUMBER,
      -- Persona 1
      ptnombre1 IN VARCHAR2,
      ptapellido1 IN VARCHAR2,
      pfnacimiento1 IN DATE,
      pcsexo1 IN NUMBER,
      -- Persona 2
      ptnombre2 IN VARCHAR2,
      ptapellido2 IN VARCHAR2,
      pfnacimiento2 IN VARCHAR2,
      pcsexo2 IN NUMBER,
      pfefecto IN DATE,
      pfvencim IN DATE,
      piprima IN NUMBER,
      piperiodico IN NUMBER,
      ppinteres IN NUMBER,
      pprevalorizacion IN NUMBER,
      ppinteres_pres IN NUMBER,
      pprevalorizacion_pres IN NUMBER DEFAULT NULL,
      preversion_pres IN NUMBER DEFAULT NULL,
      panosrenta_pres IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      num_err        NUMBER;
      v_lineas       NUMBER;
      exerror        EXCEPTION;
      v_traza        tab_error.ntraza%TYPE;
   BEGIN
---------------
-- tarifamos --
---------------
      v_traza := 1;
      num_err :=
         pac_simulacion.f_simulacion_apor_pp(pfnacimiento1, pfnacimiento2, pcsexo1, pcsexo2,
                                             pfvencim,
                                             TRUNC(MONTHS_BETWEEN(pfvencim, pfnacimiento1)
                                                   / 12),
                                             ptnombre1, ptnombre2, piperiodico,
                                             NVL(piprima, 0), NVL(ppinteres, 0),
                                             NVL(pprevalorizacion, 0), NVL(ppinteres_pres, 0),
                                             NVL(pprevalorizacion_pres, 0),
                                             NVL(preversion_pres,
                                                 CASE
                                                    WHEN pfnacimiento2 IS NOT NULL THEN 100
                                                    ELSE 0
                                                 END),
                                             NVL(panosrenta_pres, 0), v_lineas);

      IF num_err <> 0 THEN
         num_err := 108029;
         RAISE exerror;
      END IF;

      RETURN 0;   -- Todo OK
   EXCEPTION
      WHEN exerror THEN
         RETURN num_err;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_simul_aho.f_genera_sim_pu', v_traza,
                     'parametros: sproduc =' || psproduc || ' ptNombre1=' || ptnombre1
                     || ' ptApellido1=' || ptapellido1 || ' pfNacimiento1=' || pfnacimiento1
                     || ' pcSexo1=' || pcsexo1 || ' ptNombre2=' || ptnombre2
                     || ' ptApellido2=' || ptapellido2 || ' pfNacimiento2=' || pfnacimiento2
                     || ' pcSexo2=' || pcsexo2 || ' piprima=' || piprima || ' ppInteres='
                     || ppinteres || ' psseguro=' || psseguro,
                     SQLERRM);
         RETURN(108190);   -- Error general
   END;

   -- Ref 2253
   --
   --  F_GET_DADES_PP: Carrega les dades que són a SIMULAPP i DETSIMULAPP a un objecte tipus OB_RESP_SIMULA_PP
   --
   --  Paràmetres
   --    pcidioma_user   Idioma en que mostrar l'error
   FUNCTION f_get_dades_pp(pcidioma_user IN literales.cidioma%TYPE)
      RETURN ob_resp_simula_pp IS
      v_ob_resp_simula_pp ob_resp_simula_pp;
      llista         t_det_simula_pp := t_det_simula_pp();
      v_traza        tab_error.ntraza%TYPE;
   BEGIN
      v_traza := 1;

      FOR rcap IN (SELECT aporrea, duranos, durmeses, rentavit
                     FROM simulapp
                    WHERE sesion = USERENV('SESSIONID')) LOOP
         FOR rdades IN (SELECT   sesion, ejercicio, ffinejer, apormes, capital
                            FROM detsimulapp
                           WHERE sesion = USERENV('SESSIONID')
                        ORDER BY sesion, ejercicio) LOOP
            v_traza := 2;
            llista.EXTEND;
            v_traza := 3;
            llista(llista.LAST) := ob_det_simula_pp(rdades.ejercicio, rdades.ffinejer,
                                                    rdades.apormes, rdades.capital);
         END LOOP;

         v_traza := 4;
         v_ob_resp_simula_pp := ob_resp_simula_pp(llista, llista(llista.LAST).icapital,
                                                  rcap.aporrea, rcap.duranos, rcap.durmeses,
                                                  rcap.rentavit, ob_errores(0, NULL));
      END LOOP;

      RETURN v_ob_resp_simula_pp;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_simul_aho.f_get_dades_pp', v_traza,
                     'parametros: sessionid =' || USERENV('SESSIONID'), SQLERRM);
         RETURN ob_resp_simula_pp(llista, NULL, NULL, NULL, NULL, NULL,
                                  ob_errores(180431, f_axis_literales(180431, pcidioma_user)));
   END;
END pac_simul_aho;

/

  GRANT EXECUTE ON "AXIS"."PAC_SIMUL_AHO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_SIMUL_AHO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_SIMUL_AHO" TO "PROGRAMADORESCSI";
