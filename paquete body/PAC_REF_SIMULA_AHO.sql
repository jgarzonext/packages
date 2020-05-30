--------------------------------------------------------
--  DDL for Package Body PAC_REF_SIMULA_AHO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_REF_SIMULA_AHO" AS
   FUNCTION f_valida_prima_aho(
      ptipo IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      picapital IN NUMBER,
      pcforpag IN NUMBER,
      psperson IN NUMBER,
      pcpais IN NUMBER,
      pcidioma_user IN NUMBER DEFAULT f_idiomauser,
      coderror OUT NUMBER,
      msgerror OUT VARCHAR2)
      RETURN NUMBER IS
      num_err        NUMBER;
      v_capmin       NUMBER;
      v_capmax       NUMBER;
   BEGIN
      num_err := pac_val_comu.f_valida_capital(ptipo, psproduc, pcactivi, pcgarant, picapital,
                                               pcforpag, v_capmin, v_capmax);

      IF num_err = 151289 THEN   -- la prima no supera la prima mínima
         coderror := num_err;
         msgerror := f_axis_literales(coderror, pcidioma_user) || ' ' || v_capmin;
         RETURN NULL;
      ELSIF num_err = 140601 THEN   -- Prima max:
         coderror := num_err;
         msgerror := f_axis_literales(coderror, pcidioma_user) || ' ' || v_capmax;
         RETURN NULL;
      ELSIF num_err <> 0 THEN
         coderror := num_err;
         msgerror := f_axis_literales(coderror, pcidioma_user);
         RETURN NULL;
      END IF;

      num_err := pac_val_comu.f_valida_capital_persona(ptipo, psproduc, pcactivi, pcgarant,
                                                       picapital, psperson, pcpais);

      IF num_err <> 0 THEN
         coderror := num_err;
         msgerror := f_axis_literales(coderror, pcidioma_user);
         RETURN NULL;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         coderror := -999;
         msgerror := 'Pac_Ref_Simula_Aho.f_valida_prima_aho: Error General';
         p_tab_error(f_sysdate, f_user, 'Pac_Ref_Simula_Aho.f_valida_prima_aho', NULL,
                     'parametros: ptipo=' || ptipo || ' psproduc=' || psproduc || ' pcactivi='
                     || pcactivi || ' pcgarant=' || pcgarant || ' picapital=' || picapital
                     || ' pcforpag=' || pcforpag || ' psperson=' || psperson || ' pcpais='
                     || pcpais,
                     SQLERRM);
         RETURN NULL;
   END f_valida_prima_aho;

   FUNCTION f_valida_poliza_renova(
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      pcidioma_user IN NUMBER DEFAULT f_idiomauser,
      ocoderror OUT NUMBER,
      omsgerror OUT VARCHAR2)
      RETURN NUMBER IS
      /********************************************************************************************************************************
         Función que valida si una póliza es apta para hacer la simulación de la renovación/revisión.

         Parámetros de entrada:
              . pnpoliza = Número de póliza
              . pncertif = Número de certificado
         Parámetros de salida:
              . ocoderror = Código de Error
              . omsgerror = Descripción del error

            La función retorna:
               0 - si ha ido bien
              Null - si no cumple alguna validación o hay un error.
      *********************************************************************************************************************************/
      num_err        NUMBER;
      v_sseguro      NUMBER;
      error          EXCEPTION;
   BEGIN
      -- Se busca el sseguro de la póliza
      v_sseguro := ff_buscasseguro(pnpoliza, pncertif);

      IF v_sseguro IS NULL THEN
         num_err := 111995;   -- Es obligatorio informar el número de seguro
         RAISE error;
      END IF;

      -- Se valida que el producto admite renovación/revisión y que la póliza está en período de renovación/revisión
      num_err := pac_val_comu.f_valida_poliza_renova(v_sseguro, 1);   -- 1 = Simulación renovación/revisión

      IF num_err <> 0 THEN
         RAISE error;
      END IF;

      -- Todo OK
      RETURN 0;
   EXCEPTION
      WHEN error THEN
         ocoderror := num_err;
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RETURN NULL;
      WHEN OTHERS THEN
         ocoderror := 108190;   -- Error General
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         p_tab_error(f_sysdate, f_user, 'Pac_Ref_Simula_Aho.f_valida_poliza_renova', NULL,
                     'parametros: pnpoliza=' || pnpoliza || ' pncertif=' || pncertif, SQLERRM);
         RETURN NULL;
   END f_valida_poliza_renova;

   FUNCTION f_valida_duracion_renova(
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      pndurper IN NUMBER,
      pcidioma_user IN NUMBER DEFAULT f_idiomauser,
      ocoderror OUT NUMBER,
      omsgerror OUT VARCHAR2)
      RETURN NUMBER IS
      /********************************************************************************************************************************
         Función que valida la duración de la renovación según la parametrizacion del producto.

         Parámetros de entrada:
              . pnpoliza = Número de póliza
              . pncertif = Número de certificado
              . pndurper = Duración período
         Parámetros de salida:
              . ocoderror = Código de Error
              . omsgerror = Descripción del error

            La función retorna:
               0 - si ha ido bien
              Null - si no cumple alguna validación o hay un error.
      *********************************************************************************************************************************/
      num_err        NUMBER;
      v_sseguro      NUMBER;
      error          EXCEPTION;
   BEGIN
      -- Se busca el sseguro de la póliza
      v_sseguro := ff_buscasseguro(pnpoliza, pncertif);

      IF v_sseguro IS NULL THEN
         num_err := 111995;   -- Es obligatorio informar el número de seguro
         RAISE error;
      END IF;

      -- Se valida que el producto admite renovación/revisión y que la póliza está en período de renovación/revisión
      num_err := pac_val_comu.f_valida_duracion_renova(v_sseguro, pndurper);

      IF num_err <> 0 THEN
         RAISE error;
      END IF;

      -- Todo OK
      RETURN 0;
   EXCEPTION
      WHEN error THEN
         ocoderror := num_err;
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RETURN NULL;
      WHEN OTHERS THEN
         ocoderror := 108190;   -- Error General
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         p_tab_error(f_sysdate, f_user, 'Pac_Ref_Simula_Aho.f_valida_duracion_renova', NULL,
                     'parametros: pnpoliza=' || pnpoliza || ' pncertif=' || pncertif
                     || ' pndurper=' || pndurper,
                     SQLERRM);
         RETURN NULL;
   END f_valida_duracion_renova;

   FUNCTION f_simulacion_pu(
      ptipo IN NUMBER,
      psproduc IN NUMBER,
      psperson1 IN NUMBER,
      pnombre1 IN VARCHAR2,
      ptapelli1 IN VARCHAR2,
      pfnacimi1 IN DATE,
      psexo1 IN NUMBER,
      pcpais1 IN NUMBER,
      psperson2 IN NUMBER,
      pnombre2 IN VARCHAR2,
      ptapelli2 IN VARCHAR2,
      pfnacimi2 IN DATE,
      psexo2 IN NUMBER,
      pcpais2 IN NUMBER,
      pcidioma IN NUMBER,
      pcidioma_user IN NUMBER DEFAULT f_idiomauser,
      piprima IN NUMBER,
      pndurper IN NUMBER,
      pfvencim IN DATE,
      ppinttec IN NUMBER,
      pcagente IN NUMBER,
      pnpoliza IN NUMBER,
      pncertif IN NUMBER)
      RETURN ob_resp_simula_pu IS
      /**********************************************************************************************************************************
         F_SIMULACION_PU: función para simular la contratación de pólizas de prima única (EUROPLAZO16, EUROTERM16,
                                                       y AHORRO SEGURO
        2-1-2007. CSI
        Vida Ahorro

        La función retornará  un objeto de tipo ob_resp_simula_pu con los datos de los valores garantizados y el error
        (si se ha producido)
        ptipo: 1 .- Alta
               2.- Revisión
        Si ptipo =2 (revisión) los parámetros pnpoliza y pncertif deben venir informados
      **********************************************************************************************************************************/
      v_ob_resp_simula_pu ob_resp_simula_pu;
      v_t_det_simula_pu t_det_simula_pu := t_det_simula_pu();
      v_ob_det_simula_pu ob_det_simula_pu;
      v_errores      ob_errores;
      ndir           NUMBER := 0;
      num_err        NUMBER;
      v_ssolicit     NUMBER;
      v_sseguro      NUMBER;
      vcapvenci      NUMBER;
      vcapndurper    NUMBER;
      ncontador      NUMBER;
      prendimiento   NUMBER;
      v_fefecto      DATE;
      v_frevisio     DATE;
      v_nanyos_transcurridos NUMBER := 0;
      v_nduraci      NUMBER;
      v_fvencim      DATE;
      v_traza        tab_error.ntraza%TYPE;
      error          EXCEPTION;
      ocoderror      NUMBER;
      omsgerror      VARCHAR2(1000);
   BEGIN
      v_traza := 1;

 -- --------------------------------------------------------------
-- Validamos que los parámetros obligatorios vengan informados --
-- --------------------------------------------------------------
      IF (ptipo IS NULL) THEN
         v_errores := ob_errores(-999, 'f_simulacion_pu: Param PTIPO is null');
         RAISE error;
      END IF;

      IF (psproduc IS NULL) THEN
         v_errores := ob_errores(-999, 'f_simulacion_pu: Param PSPRODUC is null');
         RAISE error;
      END IF;

      IF (ptapelli1 IS NULL
          OR pnombre1 IS NULL) THEN
         v_errores := ob_errores(-999, 'f_simulacion_pu: Param PNOMBRE1 is null');
         RAISE error;
      END IF;

      IF pfnacimi1 IS NULL THEN
         v_errores := ob_errores(-999, 'f_simulacion_pu: Param PFNACIMI1 is null');
         RAISE error;
      END IF;

      IF psexo1 IS NULL THEN
         v_errores := ob_errores(-999, 'f_simulacion_pu: Param PSEXO1 is null');
         RAISE error;
      END IF;

      IF pcpais1 IS NULL THEN
         v_errores := ob_errores(-999, 'f_simulacion_pu: Param PCPAIS1 is null');
         RAISE error;
      END IF;

      IF (pnombre2 IS NOT NULL
          OR ptapelli2 IS NOT NULL)
         AND(pfnacimi2 IS NULL
             OR psexo2 IS NULL
             OR pcpais2 IS NULL) THEN
         v_errores := ob_errores(-999,
                                 'f_simulacion_pu: Faltan parametros del segundo asegurado');
         RAISE error;
      END IF;

      IF piprima IS NULL THEN
         v_errores := ob_errores(-999, 'f_simulacion_pu: Param PPRIMA is null');
         RAISE error;
      END IF;

      IF ptipo = 2
         AND(pnpoliza IS NULL
             OR pncertif IS NULL) THEN
         v_errores := ob_errores(-999, 'f_simulacion_pu: Param PNPOLIZA-PNCERTIF is null');
         RAISE error;
      END IF;

      IF (pndurper IS NULL)
         AND pfvencim IS NULL THEN
         v_errores := ob_errores(-999, 'f_simulacion_pu: Param PNDURPER is null');
         RAISE error;
      END IF;

      IF NVL(f_parproductos_v(psproduc, 'DURPER'), 0) <> 1
         AND pfvencim IS NULL THEN
         v_errores := ob_errores(-999, 'f_simulacion_pu: Param PFVENCIM is null');
         RAISE error;
      END IF;

      IF (ppinttec IS NULL) THEN
         v_errores := ob_errores(-999, 'f_simulacion_pu: Param PPINTTEC is null');
         RAISE error;
      END IF;

      IF ptipo = 2 THEN   --JRH 0372008 Validamos si la póliza puede simular la revisión
         num_err := f_valida_poliza_renova(pnpoliza, pncertif, pcidioma_user, ocoderror,
                                           omsgerror);

         IF num_err IS NULL THEN
            v_errores := ob_errores(ocoderror, omsgerror);
            RAISE error;
         END IF;
      END IF;

----------------------------------------------------------------------------------------
  -- Inicializamos la variable pg_idioma para ser utilizada desde el resto de funciones --
----------------------------------------------------------------------------------------
  -- Se valida que el idioma esté informado
      v_traza := 2;
      num_err := pac_val_comu.f_valida_idioma(pcidioma);

      IF num_err <> 0 THEN
         v_errores := ob_errores(num_err, f_axis_literales(num_err, pcidioma_user));
         RAISE error;
      END IF;

-------------------------------------------------------------------------
-- Inicializamos la variable v_sseguro (número de seguro de la póliza) --
-- en caso de Renovacion y se obtiene su fecha de revision/renovacion  --
-------------------------------------------------------------------------
      v_traza := 3;

      IF ptipo = 2 THEN   -- Renovacion
         v_sseguro := ff_buscasseguro(pnpoliza, pncertif);

         IF v_sseguro IS NULL THEN
            v_errores := ob_errores(101903, f_axis_literales(101903, pcidioma_user));
            RAISE error;
         END IF;

         v_traza := 4;

         BEGIN
            SELECT seg_aho.frevisio, TRUNC(MONTHS_BETWEEN(seg_aho.frevisio, seg.fefecto) / 12)
              INTO v_frevisio, v_nanyos_transcurridos
              FROM seguros seg, seguros_aho seg_aho
             WHERE seg.sseguro = seg_aho.sseguro
               AND seg_aho.sseguro = v_sseguro;
         EXCEPTION
            WHEN OTHERS THEN
               v_errores := ob_errores(120445, f_axis_literales(120445, pcidioma_user));   -- Error al leer de SEGUROS_AHO
               RAISE error;
         END;
      END IF;

-------------------------------------------------------------------------------------------------------------------
-- Si ptipo = 1 (Alta), la fecha de efecto es hoy, si ptipo = 2 (Renovacion), la fecha de efecto es la fecha --
-- de revisión
-------------------------------------------------------------------------------------------------------------------
      v_traza := 5;

      IF ptipo = 1 THEN
         v_fefecto := TRUNC(f_sysdate);
      ELSE   -- ptipo = 2 THEN
         v_fefecto := v_frevisio;
      END IF;

----------------------------------------
-- Validamos los datos: edad, etc...  --
----------------------------------------
      v_traza := 6;
      num_err := pac_ref_simula_comu.f_valida_asegurados(psproduc, psperson1, pfnacimi1,
                                                         psexo1, pcpais1, psperson2, pfnacimi2,
                                                         psexo2, pcpais2, v_fefecto, NULL,
                                                         NULL, 0, pcidioma_user, ocoderror,
                                                         omsgerror);

      IF num_err IS NULL THEN
         v_errores := ob_errores(ocoderror, omsgerror);
         RAISE error;
      END IF;

----------------------------------------
-- Validamos la prima                 --
----------------------------------------
      v_traza := 7;
      num_err := f_valida_prima_aho(ptipo, psproduc, 0, 48, piprima, 0, psperson1, pcpais1,
                                    pcidioma_user, ocoderror, omsgerror);

      IF num_err IS NULL THEN
         v_errores := ob_errores(ocoderror, omsgerror);
         RAISE error;
      END IF;

----------------------------------------
-- Validamos la duración              --
----------------------------------------
 -- MSR 3/7/2007. Incluore Ahorro Seguro / PE / PPA
      IF NVL(f_parproductos_v(psproduc, 'DURPER'), 0) = 1 THEN   -- Producto Europlazo 16 o Euroterm 16
         IF ptipo = 1 THEN   -- Alta
            v_traza := 8;
            num_err := pac_val_comu.f_valida_duracion(psproduc, pfnacimi1, v_fefecto,
                                                      pndurper, pfvencim);

            IF num_err <> 0 THEN
               v_errores := ob_errores(num_err, f_axis_literales(num_err, pcidioma_user));
               RAISE error;
            END IF;
         ELSE   -- ptipo = 2 -- Renovación
            -- Se valida la nueva duración seleccionada
            v_traza := 9;
            num_err := pac_val_comu.f_valida_duracion_renova(v_sseguro, pndurper);

            IF num_err <> 0 THEN
               v_errores := ob_errores(num_err, f_axis_literales(num_err, pcidioma_user));
               RAISE error;
            END IF;
         END IF;
      ELSE   -- Ahorro Seguro, PE, PPA
         v_traza := 10;
         v_nduraci := pndurper;
         v_fvencim := pfvencim;
         num_err := pac_calc_comu.f_calcula_fvencim_nduraci(psproduc, pfnacimi1, v_fefecto,
                                                            NULL, v_nduraci, v_fvencim);

         IF num_err <> 0 THEN
            v_errores := ob_errores(num_err, f_axis_literales(num_err, pcidioma_user));
            RAISE error;
         END IF;
      END IF;

 ------------------------------------------------------------
-- Si todo es correcto generamos la solicitud y tarifamos --
------------------------------------------------------------
      v_traza := 11;
      num_err := pac_simul_aho.f_genera_sim_pu(ptipo, psproduc, pnombre1, ptapelli1, pfnacimi1,
                                               psexo1, pnombre2, ptapelli2, pfnacimi2, psexo2,
                                               piprima, pndurper, pfvencim, ppinttec,
                                               v_sseguro, v_fefecto, v_ssolicit);

      IF num_err <> 0 THEN
         v_errores := ob_errores(num_err, f_axis_literales(num_err, pcidioma_user));
         RAISE error;
      END IF;

 ---------------------------
-- Devolvemos los datos  --
---------------------------
      v_traza := 12;

      IF NVL(f_parproductos_v(psproduc, 'EVOLUPROVMATSEG'), 0) = 1 THEN
         -- Agafa dels que han desat les dades a SOLEVOLUPROVMATSEG
         v_t_det_simula_pu := pac_simul_aho.f_get_evoluprovmat(v_ssolicit, pndurper,
                                                               v_nanyos_transcurridos,
                                                               num_err);

         IF num_err <> 0 THEN
            v_errores := ob_errores(num_err, f_axis_literales(num_err, pcidioma_user));
            RAISE error;
         END IF;

         v_traza := 13;
         ncontador := 0;
         vcapvenci := NULL;
         prendimiento := NULL;
         ncontador := v_t_det_simula_pu.COUNT;

         IF ncontador <> 0 THEN
            IF ptipo = 1 THEN   -- Alta
               vcapndurper := v_t_det_simula_pu(ncontador).icapgar;
               prendimiento := ROUND(((POWER((vcapndurper / piprima),(1 / pndurper)) - 1) * 100),
                                     2);
            ELSE
               NULL;   -- Falta añadir la función del rendimiento en la Renovación
            END IF;
         END IF;

         v_traza := 14;
         vcapvenci := pac_calc_comu.ff_capital_gar_tipo('SOL', v_ssolicit, 1, 5, 1);

         IF vcapvenci IS NULL THEN
            v_errores := ob_errores(153052, f_axis_literales(153052, pcidioma_user));   -- Error al buscar el capital de la garantía
            RAISE error;
         END IF;

         v_ob_resp_simula_pu := ob_resp_simula_pu(v_ssolicit, v_t_det_simula_pu, piprima,
                                                  prendimiento, vcapvenci, NULL, NULL, NULL,
                                                  v_errores);
      ELSE
         -- Agafa dels que NO han desat les dades a SOLEVOLUPROVMATSEG
         v_ob_resp_simula_pu := pac_simul_aho.f_get_dades_calculades(v_ssolicit, v_fefecto,
                                                                     piprima, pcidioma_user,
                                                                     num_err);
      END IF;

--------------------------------------------------------------------------------------------------------
-- Se inserta un registro en SIMULAESTADIST para realizar estadísticas de las simulaciones realizadas --
--------------------------------------------------------------------------------------------------------
      v_traza := 15;
      num_err := pac_simul_comu.f_ins_simulaestadist(pcagente, psproduc, ptipo);

      IF num_err <> 0 THEN
         v_errores := ob_errores(num_err, f_axis_literales(num_err, pcidioma_user));
         RAISE error;
      END IF;

--------------------
-- Todo ha ido OK --
--------------------
      COMMIT;
      RETURN v_ob_resp_simula_pu;
   EXCEPTION
      WHEN error THEN
         v_ob_det_simula_pu := NULL;
         v_t_det_simula_pu.DELETE;
         v_ob_resp_simula_pu := ob_resp_simula_pu(v_ssolicit, v_t_det_simula_pu, NULL, NULL,
                                                  NULL, NULL, NULL, NULL, v_errores);
         ROLLBACK;
         RETURN v_ob_resp_simula_pu;
      WHEN OTHERS THEN
         v_ob_det_simula_pu := NULL;
         v_t_det_simula_pu.DELETE;
         v_errores := ob_errores(-999,
                                 'Pac_Ref_Simula_Aho.f_simulacion_pu: '
                                 || f_axis_literales(108190, pcidioma));   -- Error General
         v_ob_resp_simula_pu := ob_resp_simula_pu(v_ssolicit, v_t_det_simula_pu, NULL, NULL,
                                                  NULL, NULL, NULL, NULL, v_errores);
         ROLLBACK;
         p_tab_error(f_sysdate, f_user, 'Pac_Ref_Simula_Aho.f_simulacion_pu', v_traza,
                     'f_simulacion_pu', SQLERRM);
         RETURN v_ob_resp_simula_pu;
   END f_simulacion_pu;

   --
   -- Ref 2253. : F_SIMULACION_PP.
   --
   --   La función retornará  un objeto de tipo ob_resp_simula_pp con los datos de los valores garantizados y el error
   --   (si se ha producido)
   --
   --  Paràmetres
   --    psProduc                Producte
   --    pcAgente
   --    pcIdioma_user           Idioma de la pantalla
   --    pPersona1               Estructura amb les dades de la persona 1
   --      sPerson                 Identificador de l'assegurat. Pot ser a NULL per la simulació.
   --      tNombre                 Nom de l'assegurat
   --      tApellido               Cognom de l'assegurat
   --      fNacimiento             Data de Naixement de l'assegurat
   --      cSexo                   Sexe de l'assegurat:     1 - Home,  2- Dona
   --      cPais                   Codi de l'estat de residència de l'assegurat
   --      cIdioma                 Idioma per la impressió de la simulació.
   --    pPersona2               Estructura amb les dades de la persona 2
   --      sPerson                 Identificador de l'assegurat. Pot ser a NULL per la simulació.
   --      tNombre                 Nom de l'assegurat
   --      tApellido               Cognom de l'assegurat
   --      fNacimiento             Data de Naixement de l'assegurat
   --      cSexo                   Sexe de l'assegurat:     1 - Home,  2- Dona
   --      cPais                   Codi de l'estat de residència de l'assegurat
   --      cIdioma                 No utilitzat.
   --    pfVencim                Data de la jubilació de la Persona 1
   --    piPrima                 Import de la prima inicial. Mínim 30€.
   --    piPeriodico             Aportació periòdica. Mínim 30€.
   --    ppInteres               Percentatge d'interès
   --    ppRevalorizacion        Percentatge de revalorització
   --    ppInteres_Pres          Interès de les prestacions
   --    ppRevalorizacion_Pres   Percentatge de revalorització de les prestacions. A NULL per PE i PPA
   --    ppReversion_Pres        Percentatge de reversió a les prestacions. A NULL per PE i PPA
   --    pAnosRenta_Pres
   --

   --
   --  Funció per ser cridada des del Java
   --
   FUNCTION f_simulacion_pp(
      psproduc IN NUMBER,
      pcagente IN NUMBER,
      pcidioma_user IN NUMBER DEFAULT 1,
      -- Persona 1
      psperson1 IN NUMBER,
      ptnombre1 IN VARCHAR2,
      ptapellido1 IN VARCHAR2,
      pfnacimiento1 IN DATE,
      pcsexo1 IN NUMBER,
      pcpais1 IN NUMBER,
      pcidioma IN NUMBER,
      -- Persona 2
      psperson2 IN NUMBER,
      ptnombre2 IN VARCHAR2,
      ptapellido2 IN VARCHAR2,
      pfnacimiento2 IN VARCHAR2,
      pcsexo2 IN NUMBER,
      pcpais2 IN NUMBER,
      -- Otros
      pfvencim IN DATE,
      piprima IN NUMBER,
      piperiodico IN NUMBER,
      ppinteres IN NUMBER,
      pprevalorizacion IN NUMBER,
      ppinteres_pres IN NUMBER,
      pprevalorizacion_pres IN NUMBER DEFAULT NULL,
      ppreversion_pres IN NUMBER DEFAULT NULL,
      panosrenta_pres IN NUMBER DEFAULT NULL)
      RETURN ob_resp_simula_pp IS
      v_ob_resp_simula_pp ob_resp_simula_pp;
      v_t_det_simula_pp t_det_simula_pp := t_det_simula_pp();
      v_ob_det_simula_pp ob_det_simula_pp;
      v_errores      ob_errores;
      num_err        NUMBER;
      v_sseguro      NUMBER;
      v_fefecto      DATE;
      v_traza        tab_error.ntraza%TYPE;
      v_cidioma_user per_detper.cidioma%TYPE;
      v_anys         NUMBER;
      exerror        EXCEPTION;
      ocoderror      NUMBER;
      omsgerror      VARCHAR2(1000);
      vplapensions   BOOLEAN;   -- A TRUE quan som dins el procés d'un Pla de Pensions

      -- Cridar per comprobacions que els paràmetres són passats correctament
      PROCEDURE assegura(pcondicio IN BOOLEAN, ptexterror IN VARCHAR2) IS
      BEGIN
         IF NOT pcondicio THEN
            v_errores := ob_errores(-999, ptexterror);
            RAISE exerror;
         END IF;
      END;
   BEGIN
      v_traza := 1;

-- --------------------------------------------------------------
-- Detectem si el producte es un Pla de Pensions o un PE / PPA
-- --------------------------------------------------------------
      FOR rproducto IN (SELECT cagrpro
                          FROM productos
                         WHERE sproduc = psproduc) LOOP
         -- Els plans de pensions tenen cagrpro = 11
         vplapensions :=(rproducto.cagrpro = 11);
      END LOOP;

-- --------------------------------------------------------------
-- Validamos que los parámetros obligatorios vengan informados --
-- --------------------------------------------------------------
      assegura(psproduc IS NOT NULL,
               'Pac_Ref_Simula_Aho.f_simulacion_pp: Param PSPRODUC is null');
      assegura(ptapellido1 IS NOT NULL
               AND ptnombre1 IS NOT NULL,
               'Pac_Ref_Simula_Aho.f_simulacion_pp: Persona 1 Param NOMBRE / APELLIDO is null');
      assegura(pfnacimiento1 IS NOT NULL,
               'Pac_Ref_Simula_Aho.f_simulacion_pp: Persona 1 Param FNACIMIENTO is null');
      assegura(pcsexo1 IS NOT NULL,
               'Pac_Ref_Simula_Aho.f_simulacion_pp: Persona 1 Param CSEXO is null');
      assegura(pcpais1 IS NOT NULL,
               'Pac_Ref_Simula_Aho.f_simulacion_pp: Persona 1 Param CPAIS is null');

      IF (ptnombre2 IS NOT NULL
          OR ptapellido2 IS NOT NULL
          OR pfnacimiento2 IS NOT NULL
          OR pcsexo2 IS NOT NULL
          OR pcpais2 IS NOT NULL) THEN
         assegura
              (ptapellido2 IS NOT NULL
               AND ptnombre2 IS NOT NULL,
               'Pac_Ref_Simula_Aho.f_simulacion_pp: Persona 2 Param NOMBRE / APELLIDO is null');
         assegura(pfnacimiento2 IS NOT NULL,
                  'Pac_Ref_Simula_Aho.f_simulacion_pp: Persona 2 Param FNACIMIENTO is null');
         assegura(pcsexo2 IS NOT NULL,
                  'Pac_Ref_Simula_Aho.f_simulacion_pp: Persona 2 Param CSEXO is null');
         assegura(pcpais2 IS NOT NULL,
                  'Pac_Ref_Simula_Aho.f_simulacion_pp: Persona 2 Param CPAIS is null');
      END IF;

      assegura(piprima IS NOT NULL, 'Pac_Ref_Simula_Aho.f_simulacion_pp: Param PPRIMA is null');
      assegura(pfvencim IS NOT NULL,
               'Pac_Ref_Simula_Aho.f_simulacion_pp: Param PFVENCIM is null');
      assegura(ppinteres IS NOT NULL,
               'Pac_Ref_Simula_Aho.f_simulacion_pp: Param PPINTERES is null');
      assegura(piperiodico IS NOT NULL,
               'Pac_Ref_Simula_Aho.f_simulacion_pp: Param PIPERIODICO is null');
      assegura(pprevalorizacion IS NOT NULL,
               'Pac_Ref_Simula_Aho.f_simulacion_pp: Param PPREVALORIZACION is null');
      assegura(ppinteres_pres IS NOT NULL,
               'Pac_Ref_Simula_Aho.f_simulacion_pp: Param PPINTERES_PRES is null');

      IF vplapensions THEN
         assegura(pprevalorizacion_pres IS NOT NULL,
                  'Pac_Ref_Simula_Aho.f_simulacion_pp: Param PPREVALORIZACION_PRES is null');
         assegura(ppreversion_pres IS NOT NULL,
                  'Pac_Ref_Simula_Aho.f_simulacion_pp: Param PPREVERSION_PRES is null');
         assegura(panosrenta_pres IS NOT NULL,
                  'Pac_Ref_Simula_Aho.f_simulacion_pp: Param PANOSRENTA_PRES is null');
      END IF;

      -- Inicializamos la variable v_cidioma_user
      v_cidioma_user := NVL(pcidioma_user, pcidioma);
      -- Se valida que el idioma esté informado
      v_traza := 2;
      num_err := pac_val_comu.f_valida_idioma(v_cidioma_user);

      IF num_err <> 0 THEN
         v_errores := ob_errores(num_err, f_axis_literales(num_err, pcidioma));
         RAISE exerror;
      END IF;

-------------------------------------------------------------------------------------------------------------------
-- Data d'efecte
-------------------------------------------------------------------------------------------------------------------
      v_traza := 5;
      v_fefecto := TRUNC(f_sysdate);
----------------------------------------
-- Validamos los datos: edad, etc...  --
----------------------------------------
      v_traza := 6;
      num_err := pac_ref_simula_comu.f_valida_asegurados(psproduc, psperson1, pfnacimiento1,
                                                         pcsexo1, pcpais1, psperson2,
                                                         pfnacimiento2, pcsexo2, pcpais2,
                                                         v_fefecto, NULL, NULL, 0, pcidioma,
                                                         ocoderror, omsgerror);

      IF num_err IS NULL THEN
         v_errores := ob_errores(ocoderror, omsgerror);
         RAISE exerror;
      END IF;

----------------------------------------
-- Validamos la prima inicial       --
----------------------------------------
      v_traza := 8;
      num_err := f_valida_prima_aho(1, psproduc, 0, 282, piprima, 0, psperson1, pcpais1,
                                    pcidioma, ocoderror, omsgerror);

      IF num_err IS NULL THEN
         v_errores := ob_errores(ocoderror, omsgerror);
         RAISE exerror;
      END IF;

----------------------------------------
-- Validamos la prima periodica       --
----------------------------------------
      v_traza := 9;
      num_err := f_valida_prima_aho(1, psproduc, 0, 48, piperiodico, 0, psperson1, pcpais1,
                                    pcidioma, ocoderror, omsgerror);

      IF num_err IS NULL THEN
         v_errores := ob_errores(ocoderror, omsgerror);
         RAISE exerror;
      END IF;

---------------------------------------------------
-- Validamos la prima inicial vs. periodica      --
---------------------------------------------------
      v_traza := 7;

      IF piprima < piperiodico THEN
         v_errores := ob_errores(180432, f_axis_literales(180432, pcidioma));
         RAISE exerror;
      END IF;

----------------------------------------
-- Validamos la edad                  --
----------------------------------------
      v_traza := 10;
      num_err := pac_val_comu.f_valida_edad_prod(psproduc, v_fefecto, pfnacimiento1,
                                                 pfnacimiento2);

      IF num_err <> 0 THEN
         v_errores := ob_errores(num_err, f_axis_literales(180430, pcidioma));
         RAISE exerror;
      END IF;

-- Originalment al Forms hi havia això
--      num_err := F_DIFDATA ( pPersona1.fNacimiento, F_SYSDATE, 1, 1, v_anys );
--      IF num_err <> 0 THEN
--        v_errores := ob_errores(num_err, F_AXIS_LITERALES(num_err, pcidioma));
--        RAISE exError;
--      END IF;
--      IF ( v_anys < 18 or (v_anys > 65 AND vPlaPensions)  ) THEN
--          v_errores := ob_errores(num_err, F_AXIS_LITERALES(180430, pcidioma));
--          RAISE exError;
--      END IF;

      ------------------------------------------------------------
-- Si todo es correcto generamos la solicitud y tarifamos --
------------------------------------------------------------
      v_traza := 11;
      num_err := pac_simul_aho.f_genera_sim_pp(psproduc, v_sseguro, ptnombre1, ptapellido1,
                                               pfnacimiento1, pcsexo1, ptnombre2, ptapellido2,
                                               pfnacimiento2, pcsexo2, v_fefecto, pfvencim,
                                               piprima, piperiodico, ppinteres,
                                               pprevalorizacion, ppinteres_pres,
                                               pprevalorizacion_pres, ppreversion_pres,
                                               panosrenta_pres);

      IF num_err <> 0 THEN
         v_errores := ob_errores(num_err, f_axis_literales(num_err, pcidioma));
         RAISE exerror;
      END IF;

--------------------------------------------------------------------------------------------------------
-- Agafa les dades de les taules SIMULAPP i DETSIMULAPP
--------------------------------------------------------------------------------------------------------
      v_traza := 12;
      v_ob_resp_simula_pp := pac_simul_aho.f_get_dades_pp(v_cidioma_user);

      IF v_ob_resp_simula_pp.errores IS NOT NULL THEN
         IF NVL(v_ob_resp_simula_pp.errores.cerror, 0) <> 0 THEN
            v_errores := v_ob_resp_simula_pp.errores;
            RAISE exerror;
         END IF;
      END IF;

--------------------------------------------------------------------------------------------------------
-- Se inserta un registro en SIMULAESTADIST para realizar estadísticas de las simulaciones realizadas --
--------------------------------------------------------------------------------------------------------
      v_traza := 15;
      num_err := pac_simul_comu.f_ins_simulaestadist(pcagente, psproduc, 1);

      IF num_err <> 0 THEN
         v_errores := ob_errores(num_err, f_axis_literales(num_err, pcidioma));
         RAISE exerror;
      END IF;

--------------------
-- Todo ha ido OK --
--------------------
      COMMIT;
      RETURN v_ob_resp_simula_pp;
   EXCEPTION
      WHEN exerror THEN
         v_t_det_simula_pp.DELETE;
         ROLLBACK;
         RETURN ob_resp_simula_pp(v_t_det_simula_pp, NULL, NULL, NULL, NULL, NULL, v_errores);
      WHEN OTHERS THEN
         v_t_det_simula_pp.DELETE;
         v_errores := ob_errores(-999,
                                 'Pac_Ref_Simula_Aho.f_simulacion_pp: '
                                 || f_axis_literales(108190, pcidioma));   -- Error General
         ROLLBACK;
         p_tab_error(f_sysdate, f_user, 'Pac_Ref_Simula_Aho.f_simulacion_pp', v_traza,
                     'f_simulacion_pp', SQLERRM);
         RETURN ob_resp_simula_pp(v_t_det_simula_pp, NULL, NULL, NULL, NULL, NULL, v_errores);
   END;
END pac_ref_simula_aho;

/

  GRANT EXECUTE ON "AXIS"."PAC_REF_SIMULA_AHO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_REF_SIMULA_AHO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_REF_SIMULA_AHO" TO "PROGRAMADORESCSI";
