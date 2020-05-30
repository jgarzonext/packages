--------------------------------------------------------
--  DDL for Package Body PAC_REF_CONTRATA_AHO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_REF_CONTRATA_AHO" AS
   /****************************************************************************
      NOMBRE:       pac_ref_contrata_aho
      PROPÓSITO:  Funciones para la gestión de productos de ahorro.

      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ----------------------------------
      2.0        12/02/2009   RSC             Adaptacion a colectivos multiples
                                              con certificados
      3.0        15/06/2009   JTS             Se modifica la llamada de cobro de recibo
   ****************************************************************************/
   FUNCTION f_valida_garantias_aho(
      psproduc IN NUMBER,
      psperson1 IN NUMBER,
      psperson2 IN NUMBER,
      pfefecto IN DATE,
      prima_inicial IN NUMBER,
      prima_per IN NUMBER,
      prevali IN NUMBER,
      pcforpag IN NUMBER,
      pcfallaseg1 IN NUMBER,
      pcfallaseg2 IN NUMBER,
      pcaccaseg1 IN NUMBER,
      pcaccaseg2 IN NUMBER,
      pcagente IN NUMBER,
      pcidioma_user IN NUMBER DEFAULT f_idiomauser,
      ocoderror OUT NUMBER,
      omsgerror OUT VARCHAR2)
      RETURN NUMBER IS
    /************************************************************************************************************************************
       Función que valida los importes de primas y la revalorización
******************************************************************************************************************************************/
      v_garant       NUMBER;
      v_ctipgar      NUMBER;
      v_capital      NUMBER;
      v_fefecto      DATE;
      num_err        NUMBER;
      error          EXCEPTION;
   BEGIN
      -- La fecha de efecto debe estar truncada
      v_fefecto := TRUNC(pfefecto);
-------------------------------------------------------------------------------------------------------
-- Validamos las prima periodo (la prima única en el caso de producto prima única)
-------------------------------------------------------------------------------------------------------
      v_garant := pac_calc_comu.f_cod_garantia(psproduc, 3, NULL, v_ctipgar);

      IF prima_per IS NULL
         AND v_ctipgar = 2 THEN   -- si la garantía es obligatoria y no viene informado el capital
         ocoderror := 180181;   -- Prima obligatoria
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error;
      ELSE
         v_capital := prima_per;
         num_err := pac_val_aho.f_valida_prima_aho(1, psproduc, psperson1, 3, v_capital,
                                                   pcforpag);

         IF num_err <> 0 THEN
            ocoderror := num_err;
            omsgerror := f_axis_literales(ocoderror, pcidioma_user);
            RAISE error;
         END IF;
      END IF;

-------------------------------------------------------------------------------------------------------
-- Validamos las prima inicial
-------------------------------------------------------------------------------------------------------
      v_garant := pac_calc_comu.f_cod_garantia(psproduc, 4, NULL, v_ctipgar);

      IF v_garant IS NOT NULL THEN   -- en el producto hay prima inicial
         IF prima_inicial IS NULL THEN
            -- si la garantía es obligatoria y no viene informado el capital
            ocoderror := 180189;   -- Prima inicial obligatoria
            omsgerror := f_axis_literales(ocoderror, pcidioma_user);
            RAISE error;
         ELSE
            --IF f_usuario_cobro(pcagente, psproduc) = 1 THEN   -- Sí se puede realizar el cobro On_Line
            v_capital := prima_inicial;
            num_err := pac_val_aho.f_valida_prima_aho(1, psproduc, psperson1, 4, v_capital,
                                                      pcforpag);

            IF num_err <> 0 THEN
               ocoderror := num_err;
               omsgerror := f_axis_literales(ocoderror, pcidioma_user);
               RAISE error;
            END IF;
         /*ELSE
            IF prima_inicial <> 0 THEN
               ocoderror := 180389;
               -- El usuario no permite cobro On-Line. La prima inicial debe ser 0.
               omsgerror := f_axis_literales(ocoderror, pcidioma_user);
               RAISE error;
            END IF;
         END IF;*/
         END IF;
      END IF;

-------------------------------------------------------------------------------------------------------
-- Validamos las garantias de fallecimiento y accidente del asegurado 1 y asegurado 2
-------------------------------------------------------------------------------------------------------
-- Garantia Fallecimiento Asegurado 1
      num_err := pac_val_aho.f_valida_garantia_adicional(psproduc, psperson1, pcfallaseg1, 6,
                                                         1, v_fefecto);

      IF num_err <> 0 THEN
         ocoderror := num_err;
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error;
      END IF;

      -- Garantia Fallecimiento Asegurado 2
      num_err := pac_val_aho.f_valida_garantia_adicional(psproduc, psperson2, pcfallaseg2, 6,
                                                         2, v_fefecto);

      IF num_err <> 0 THEN
         ocoderror := num_err;
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error;
      END IF;

      -- Garantia Accidente Asegurado 1
      num_err := pac_val_aho.f_valida_garantia_adicional(psproduc, psperson1, pcaccaseg1, 7, 1,
                                                         v_fefecto);

      IF num_err <> 0 THEN
         ocoderror := num_err;
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error;
      END IF;

      -- Garantia Accidente Asegurado 2
      num_err := pac_val_aho.f_valida_garantia_adicional(psproduc, psperson2, pcaccaseg2, 7, 2,
                                                         v_fefecto);

      IF num_err <> 0 THEN
         ocoderror := num_err;
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN error THEN
         RETURN NULL;
      WHEN OTHERS THEN
         ocoderror := -999;
         omsgerror :=
                    'Pac_Ref_Contrata_Aho.f_valida_garantias_aho: Error general en la función';
         p_tab_error(f_sysdate, getuser, 'Pac_Ref_Contrata_Aho.f_valida_garantias_aho', NULL,
                     'parametros: psproduc = ' || psproduc || '  psperson1 = ' || psperson1
                     || ' psperson2 = ' || psperson2 || '  pfefecto = ' || pfefecto
                     || ' prima_inicial = ' || prima_inicial || ' prima_per = ' || prima_per
                     || ' prevali = ' || prevali || ' pcforpag = ' || pcforpag
                     || ' pcfallaseg1 = ' || pcfallaseg1 || ' pcfallaseg2 = ' || pcfallaseg2
                     || ' pcaccaseg1 = ' || pcaccaseg1 || ' pcaccaseg2 = ' || pcaccaseg2
                     || ' pcagente = ' || pcagente || ' pcidioma_user = ' || pcidioma_user,
                     SQLERRM);
         RETURN NULL;
   END f_valida_garantias_aho;

/*
LA FUNCION f_valida_primas_aho QUEDA SUSTITUIDA POR LA FUNCIO f_valida_garantias_aho

   FUNCTION f_valida_primas_aho(psproduc IN NUMBER, psperson IN NUMBER, pfefecto IN DATE, prima_inicial IN NUMBER, prima_per IN NUMBER,
           prevali IN NUMBER,  pcforpag IN NUMBER, pcfallaseg1 IN NUMBER, pcfallaseg2 IN NUMBER, pcaccaseg1 IN NUMBER,
         pcaccaseg2 IN NUMBER, pcagente IN NUMBER, pcidioma_user IN NUMBER DEFAULT F_IdiomaUser, oCODERROR OUT NUMBER, oMSGERROR OUT VARCHAR2) RETURN NUMBER IS
*/ /************************************************************************************************************************************
      Función que valida los importes de primas y la revalorización
******************************************************************************************************************************************/
/*
      v_garant       NUMBER;
     v_ctipgar       NUMBER;
     v_capital       NUMBER;
      v_fefecto      DATE;
     num_err        NUMBER;
     error          EXCEPTION;

       -- Definimos funciones propias dentro de la función para averiguar el tipo de garantía y validar las garantias

      FUNCTION f_valida(ptipo IN NUMBER, psproduc IN NUMBER, pcactivi IN NUMBER, pcgarant IN NUMBER, picapital IN NUMBER,
         pcforpag IN NUMBER, psperson IN NUMBER, pcidioma_user IN NUMBER DEFAULT F_IdiomaUser, coderror OUT NUMBER, msgerror OUT VARCHAR2)
         RETURN NUMBER IS
            num_err       NUMBER;
           v_capmin      NUMBER;
           v_capmax       NUMBER;
         BEGIN
             num_err := Pac_Val_Comu.f_valida_capital(ptipo, psproduc, pcactivi,pcgarant, picapital, pcforpag, v_capmin, v_capmax);
             IF num_err = 151289 THEN -- la prima no supera la prima mínima
                CODERROR := num_err;
               MSGERROR := f_axis_literales(CODERROR, pcidioma_user)||' '||v_capmin;
               RETURN NULL;
             ELSIF num_err = 140601 THEN  -- Prima max:
                CODERROR := num_err;
               MSGERROR := f_axis_literales(CODERROR, pcidioma_user)||' '||v_capmax;
               RETURN NULL;
             ELSIF num_err <> 0 THEN
                 CODERROR := num_err;
              MSGERROR := f_axis_literales(CODERROR, pcidioma_user);
              RETURN NULL;
              END IF;
             num_err := Pac_Val_Comu.f_valida_capital_persona(ptipo, psproduc, pcactivi, pcgarant, picapital, psperson, null);
             IF num_err <> 0 THEN
                CODERROR := num_err;
             MSGERROR := f_axis_literales(CODERROR, pcidioma_user);
                 RETURN NULL;
             END IF;
             RETURN 0;
         END f_valida;


   BEGIN

      -- La fecha de efecto debe estar truncada
      v_fefecto := trunc(pfefecto);

      -------------------------------------------------------------------------------------------------------
     -- Validamos las prima periodo (la prima única en el caso de producto prima única)
     -------------------------------------------------------------------------------------------------------
     v_garant := Pac_Calc_Comu.f_cod_garantia(psproduc, 3, NULL,v_ctipgar);
     IF prima_per IS NULL AND v_ctipgar = 2 THEN  -- si la garantía es obligatoria y no viene informado el capital
        oCODERROR := 180181; -- Prima obligatoria
       oMSGERROR := f_axis_literales(oCODERROR, pcidioma_user);
       RAISE error;
     ELSE
        v_capital := prima_per;
        num_err := f_valida(1, psproduc, 0, v_garant, v_capital, pcforpag, psperson, pcidioma_user, oCODERROR, oMSGERROR);
        IF num_err IS NULL THEN
           RAISE error;
        END IF;
     END IF;
     -------------------------------------------------------------------------------------------------------
     -- Validamos las prima inicial
     -------------------------------------------------------------------------------------------------------
     v_garant := Pac_Calc_Comu.f_cod_garantia(psproduc, 4, NULL, v_ctipgar);
      IF v_garant IS NOT NULL THEN -- en el producto hay prima inicial
        IF prima_inicial IS NULL THEN  -- si la garantía es obligatoria y no viene informado el capital
           oCODERROR := 180189; -- Prima inicial obligatoria
          oMSGERROR := f_axis_literales(oCODERROR, pcidioma_user);
          RAISE error;
        ELSE
            IF f_usuario_cobro(pcagente, psproduc) = 1 THEN -- Sí se puede realizar el cobro On_Line
                v_capital := prima_inicial;
               num_err := f_valida(1, psproduc, 0, v_garant, v_capital, pcforpag, psperson, pcidioma_user, oCODERROR, oMSGERROR);
               IF num_err IS NULL THEN
                  RAISE error;
               END IF;
            ELSE
              IF prima_inicial <> 0 THEN
                oCODERROR := 180389; -- El usuario no permite cobro On-Line. La prima inicial debe ser 0.
               oMSGERROR := f_axis_literales(oCODERROR, pcidioma_user);
               RAISE error;
              END IF;
            END IF;
        END IF;
    END IF;
     -------------------------------------------------------------------------------------------------------
     -- Validamos el capital de fallecimiento asegurado 1
     -------------------------------------------------------------------------------------------------------
   --  IF pcfallaseg = 1 THEN -- el capital de fallecimiento del asegurado 1 está informado
        RETURN 0;


   EXCEPTION
     WHEN error THEN
         RETURN NULL;
     WHEN OTHERS THEN
       oCODERROR := -999;
      oMSGERROR := 'Pac_Ref_Contrata_Aho.f_valida_primas_aho: Error general en la función';
      p_tab_error(f_sysdate,  getUSER,  'Pac_Ref_Contrata_Aho.f_valida_primas_aho',NULL,
                    'parametros: psproduc = '||psproduc||'  psperson = '||psperson||'  pfefecto = '||pfefecto,
                      SQLERRM);
        RETURN NULL;
   END f_valida_primas_aho;
*/
   FUNCTION f_suplemento_interes(
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      pndurper IN NUMBER,
      ppinttec IN NUMBER,
      poficina IN VARCHAR2,
      pterminal IN VARCHAR2,
      pcidioma_user IN NUMBER DEFAULT f_idiomauser,
      ocoderror OUT NUMBER,
      omsgerror OUT VARCHAR2)
      RETURN NUMBER IS
      /********************************************************************************************************************************
         Función que graba el suplemento de cambio de interés técnico con efecto retroactivo al inicio de la póliza o última renovación.

         La función retornará:
            0.- Si todo es correcto
            NULL -- si hay error o no se cumple alguan de las validaciones. El código de error y el texto se informarán
                            en los parámetros oCODERROR y oMSGERROR
      *****************************************************************************************************************************/
      num_err        NUMBER;
      v_sseguro      NUMBER;
      v_nmovimi      NUMBER;
      v_est_sseguro  NUMBER;
      v_npoliza      NUMBER;
      v_ncertif      NUMBER;
      v_nrecibo      NUMBER;
      v_nsolici      NUMBER;
      v_sproduc      NUMBER;
      v_frevant      DATE;
      v_cont         NUMBER;
      vcmotmov       NUMBER;
      v_fefecto      DATE;
      error          EXCEPTION;
      error_fin_supl EXCEPTION;
      num_reg        NUMBER;
   BEGIN
      -- Código del motivo de movimiento (suplemento)
      vcmotmov := 522;

--------------------------------------------------------------------------
-- Validamos que estén informados los datos del suplemento
--------------------------------------------------------------------------
      IF pnpoliza IS NULL
         OR pncertif IS NULL THEN
         ocoderror := 140896;   -- Se tiene que informar la poliza
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error;
      END IF;

/*
      IF v_fefecto IS NULL THEN
         oCODERROR := 120077;  -- Falta informar la fecha efecto
            oMSGERROR := f_axis_literales(oCODERROR, pcidioma_user);
         RAISE error;
      END IF;
*/
      IF NVL(f_parproductos_v(v_sproduc, 'DURPER'), 0) = 1 THEN
         IF pndurper IS NULL THEN
            ocoderror := 151288;   -- La duración es obligatoria
            omsgerror := f_axis_literales(ocoderror, pcidioma_user);
            RAISE error;
         END IF;
      END IF;

      IF ppinttec IS NULL THEN
         ocoderror := 112139;   -- El importe del interés es obligatorio
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error;
      END IF;

      IF poficina IS NULL THEN
         ocoderror := 180252;   -- Es obligatorio introducir la oficina
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error;
      END IF;

/*
      IF pterminal IS NULL THEN
         oCODERROR := 180253;  -- Es obligatorio introducir el terminal
            oMSGERROR := f_axis_literales(oCODERROR, pcidioma_user);
         RAISE error;
      END IF;
*/    -------------------------------------------------
      -- Se busca el valor del sseguro y del sproduc --
      -------------------------------------------------
      v_sseguro := ff_buscasseguro(pnpoliza, pncertif);

      SELECT sproduc
        INTO v_sproduc
        FROM seguros
       WHERE sseguro = v_sseguro;

      -- La fecha del suplemento será la fecha de alta o última renovación de la póliza
      -- La fecha debe estar truncada
      v_fefecto := TO_DATE(frenovacion(NULL, v_sseguro, 2), 'yyyy/mm/dd');
--------------------------------------------------------------------------
-- Validar que la póliza permite el suplemento
--------------------------------------------------------------------------
      num_err := pac_ref_contrata_comu.f_valida_poliza_permite_supl(pnpoliza, pncertif,
                                                                    v_fefecto, vcmotmov,
                                                                    pcidioma_user, ocoderror,
                                                                    omsgerror);

      IF num_err IS NULL THEN
         RAISE error;
      END IF;

---------------------------------------------------------------
-- Se valida que la duración esté permitida para el producto --
---------------------------------------------------------------
-- Sólo se validará para los productos para los cuales su duración es por años (no por fecha de vencimiento)
      IF NVL(f_parproductos_v(v_sproduc, 'DURPER'), 0) = 1 THEN
         BEGIN
            SELECT frevant
              INTO v_frevant
              FROM seguros_aho
             WHERE sseguro = v_sseguro;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               v_frevant := NULL;
            WHEN OTHERS THEN
               ocoderror := 120445;   -- Error al leer de SEGUROS_AHO
               omsgerror := f_axis_literales(ocoderror, pcidioma_user);
               RAISE error;
         END;

         IF v_frevant IS NULL THEN
            num_err := pac_val_comu.f_valida_durper(v_sproduc, pndurper, v_fefecto);

            IF num_err <> 0 THEN
               ocoderror := num_err;
               omsgerror := f_axis_literales(ocoderror, pcidioma_user);
               RAISE error;
            END IF;
         ELSE
            num_err := pac_val_comu.f_valida_duracion_renova(v_sseguro, pndurper);

            IF num_err <> 0 THEN
               ocoderror := num_err;
               omsgerror := f_axis_literales(ocoderror, pcidioma_user);
               RAISE error;
            END IF;
         END IF;
      ELSIF NVL(f_parproductos_v(v_sproduc, 'DURACI'), 0) = 1 THEN
         IF num_reg <> 0 THEN
            num_err := pac_val_comu.f_valida_durper(v_sproduc, pndurper, v_fefecto);

            IF num_err <> 0 THEN
               ocoderror := num_err;
               omsgerror := f_axis_literales(ocoderror, pcidioma_user);
               RAISE error;
            END IF;
         END IF;
      END IF;

-------------------------------------------------------------------------------------------
-- Se traspasan los datos a las tablas EST y se dejan preparadas para hacer el suplemento
-------------------------------------------------------------------------------------------
-- Todas las funciones a partir de esta deben tener RAISE error_fin_supl
      num_err := pk_suplementos.f_inicializar_suplemento(v_sseguro, 'SUPLEMENTO', v_fefecto,
                                                         'BBDD', '*', vcmotmov, v_est_sseguro,
                                                         v_nmovimi);

      IF num_err <> 0 THEN
         ocoderror := num_err;
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error_fin_supl;
      END IF;

-------------------------------------------------------------------------------------------
-- Se realiza la modificación del interés en las tablas EST
-------------------------------------------------------------------------------------------
      num_err := pac_prod_comu.f_cambio_interes(v_est_sseguro, pndurper, ppinttec, v_nmovimi);

      IF num_err <> 0 THEN
         ocoderror := num_err;
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error_fin_supl;
      END IF;

-------------------------------------------------------------------------------------------
-- Se valida que se haya realizado algún cambio
-------------------------------------------------------------------------------------------
      num_err := pk_suplementos.f_validar_cambios(f_user, v_est_sseguro, v_nmovimi, v_sproduc,
                                                  'BBDD', 'SUPLEMENTO');

      IF num_err <> 0 THEN
         ocoderror := num_err;
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error_fin_supl;
      END IF;

      BEGIN
         -- primero hay que validar que hay regisros en detmovseguro
         SELECT COUNT(*)
           INTO v_cont
           FROM estdetmovseguro
          WHERE sseguro = v_est_sseguro;
      EXCEPTION
         WHEN OTHERS THEN
            ocoderror := 180264;   -- Error al leer de la tabla ESTDETMOVSEGURO
            omsgerror := f_axis_literales(ocoderror, pcidioma_user);
            RAISE error_fin_supl;
      END;

      IF v_cont = 0 THEN   -- No ha habido ningún cambio
         ocoderror := 107804;   -- No se ha realizado ningún cambio
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error_fin_supl;
      END IF;

-------------------------------------------------------------------------------------------
-- Se graba el suplemento en las tablas reales
-------------------------------------------------------------------------------------------
      num_err := pk_suplementos.f_grabar_suplemento_poliza(v_est_sseguro, v_nmovimi);

      IF num_err <> 0 THEN
         ocoderror := num_err;
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error_fin_supl;
      END IF;

-------------------------------------------------------------------------------------------
-- Se emite el suplemento
-------------------------------------------------------------------------------------------
      num_err := pac_prod_comu.f_emite_propuesta(v_sseguro, v_npoliza, v_ncertif, v_nrecibo,
                                                 v_nsolici);

      IF num_err <> 0 THEN
         ocoderror := num_err;
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error_fin_supl;
      END IF;

-------------------------------------------------------------------------------------------
-- Se envia correo a la oficina de gestión si corresponde
-------------------------------------------------------------------------------------------
      num_err := pac_avisos.f_accion(1, v_sseguro, 1, pcidioma_user, 'REAL', vcmotmov, 5,
                                     poficina, pterminal, v_nmovimi);

      IF num_err <> 0 THEN
         ocoderror := num_err;
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error_fin_supl;
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN error THEN
         ROLLBACK;
         RETURN NULL;
      WHEN error_fin_supl THEN
         ROLLBACK;
         num_err := pk_suplementos.f_final_suplemento(v_est_sseguro, v_nmovimi, v_sseguro);
         COMMIT;
         RETURN NULL;
      WHEN OTHERS THEN
         ocoderror := -999;
         omsgerror :=
                     'Pac_Ref_Contrata_Comu.f_suplemento_interes: Error general en la función';
         ROLLBACK;
         p_tab_error(f_sysdate, getuser, 'Pac_Ref_Contrata_Comu.f_suplemento_interes', NULL,
                     'parametros: pnpoliza = ' || pnpoliza || ' pncertif =' || pncertif
                     || ' pndurper = ' || pndurper || ' ppinttec = ' || ppinttec
                     || ' poficina =' || poficina || ' pterminal =' || pterminal,
                     SQLERRM);
         num_err := pk_suplementos.f_final_suplemento(v_est_sseguro, v_nmovimi, v_sseguro);
         COMMIT;
         RETURN NULL;
   END f_suplemento_interes;

   FUNCTION f_suplemento_forpag_prestacion(
      psseguro IN NUMBER,
      pfefecto IN DATE,
      pcfprest IN NUMBER,
      poficina IN VARCHAR2,
      pterminal IN VARCHAR2,
      pcidioma_user IN NUMBER DEFAULT f_idiomauser,
      ocoderror OUT NUMBER,
      omsgerror OUT VARCHAR2)
      RETURN NUMBER IS
      /********************************************************************************************************************************
         Función que graba el suplemento de cambio de forma de pago de la prestación
         Parámetros de entrada: . pcfprest = Código de la nueva forma de pago de la prestación (0.Capital; 1. Renta Mensual Vitalicia)

         La función retornará:
            0.- Si todo es correcto
            NULL -- si hay error o no se cumple alguan de las validaciones. El código de error y el texto se informarán
                            en los parámetros oCODERROR y oMSGERROR
      *****************************************************************************************************************************/
      num_err        NUMBER;
--       v_sseguro          NUMBER;
      v_nmovimi      NUMBER;
      v_est_sseguro  NUMBER;
      v_npoliza      NUMBER;
      v_ncertif      NUMBER;
      v_nrecibo      NUMBER;
      v_nsolici      NUMBER;
      v_sproduc      NUMBER;
      v_cont         NUMBER;
      vcmotmov       NUMBER;
      v_fefecto      DATE;
      error          EXCEPTION;
      error_fin_supl EXCEPTION;
   BEGIN
      -- Código del motivo de movimiento (suplemento)
      vcmotmov := 521;
      -- La fecha de efecto debe estar truncada
      v_fefecto := TRUNC(pfefecto);
--------------------------------------------------------------------------
-- Validar que la póliza permite el suplemento
--------------------------------------------------------------------------
      num_err := f_buscapoliza(psseguro, v_npoliza, v_ncertif);

      IF num_err <> 0 THEN
         ocoderror := num_err;
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error;
      END IF;

      num_err := pac_ref_contrata_comu.f_valida_poliza_permite_supl(v_npoliza, v_ncertif,
                                                                    v_fefecto, vcmotmov,
                                                                    pcidioma_user, ocoderror,
                                                                    omsgerror);

      IF num_err IS NULL THEN
         RAISE error;
      END IF;

--------------------------------------------------------------------------
-- Validamos que estén informados los datos del suplemento
--------------------------------------------------------------------------
      IF psseguro IS NULL THEN
         ocoderror := 111995;   -- Es obligatorio informar el número de seguro
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error;
      END IF;

      IF v_fefecto IS NULL THEN
         ocoderror := 120077;   -- Falta informar la fecha efecto
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error;
      END IF;

      IF pcfprest IS NULL THEN
         ocoderror := 180418;
         -- Es obligatorio introducir la forma de pago de la prestación
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error;
      END IF;

      IF poficina IS NULL THEN
         ocoderror := 180252;   -- Es obligatorio introducir la oficina
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error;
      END IF;

      IF pterminal IS NULL THEN
         ocoderror := 180253;   -- Es obligatorio introducir el terminal
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error;
      END IF;

-------------------------------------------------------------------------------------------
-- Se traspasan los datos a las tablas EST y se dejan preparadas para hacer el suplemento
-------------------------------------------------------------------------------------------
-- Todas las funciones a partir de esta deben tener RAISE error_fin_supl
      num_err := pk_suplementos.f_inicializar_suplemento(psseguro, 'SUPLEMENTO', v_fefecto,
                                                         'BBDD', '*', vcmotmov, v_est_sseguro,
                                                         v_nmovimi);

      IF num_err <> 0 THEN
         ocoderror := num_err;
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error_fin_supl;
      END IF;

-------------------------------------------------------------------------------------------
-- Se realiza la modificación de la forma de pago de la prestación en las tablas EST
-------------------------------------------------------------------------------------------
      num_err := pac_prod_aho.f_cambio_forpag_prest(v_est_sseguro, pcfprest);

      IF num_err <> 0 THEN
         ocoderror := num_err;
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error_fin_supl;
      END IF;

-------------------------------------------------------------------------------------------
-- Se valida que se haya realizado algún cambio
-------------------------------------------------------------------------------------------
      SELECT sproduc
        INTO v_sproduc
        FROM seguros
       WHERE sseguro = psseguro;

      num_err := pk_suplementos.f_validar_cambios(f_user, v_est_sseguro, v_nmovimi, v_sproduc,
                                                  'BBDD', 'SUPLEMENTO');

      IF num_err <> 0 THEN
         ocoderror := num_err;
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error_fin_supl;
      END IF;

      BEGIN
         -- primero hay que validar que hay regisros en detmovseguro
         SELECT COUNT(*)
           INTO v_cont
           FROM estdetmovseguro
          WHERE sseguro = v_est_sseguro;
      EXCEPTION
         WHEN OTHERS THEN
            ocoderror := 180264;   -- Error al leer de la tabla ESTDETMOVSEGURO
            omsgerror := f_axis_literales(ocoderror, pcidioma_user);
            RAISE error_fin_supl;
      END;

      IF v_cont = 0 THEN   -- No ha habido ningún cambio
         ocoderror := 107804;   -- No se ha realizado ningún cambio
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error_fin_supl;
      END IF;

-------------------------------------------------------------------------------------------
-- Se graba el suplemento en las tablas reales
-------------------------------------------------------------------------------------------
      num_err := pk_suplementos.f_grabar_suplemento_poliza(v_est_sseguro, v_nmovimi);

      IF num_err <> 0 THEN
         ocoderror := num_err;
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error_fin_supl;
      END IF;

-------------------------------------------------------------------------------------------
-- Se emite el suplemento
-------------------------------------------------------------------------------------------
      num_err := pac_prod_comu.f_emite_propuesta(psseguro, v_npoliza, v_ncertif, v_nrecibo,
                                                 v_nsolici);

      IF num_err <> 0 THEN
         ocoderror := num_err;
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error_fin_supl;
      END IF;

-------------------------------------------------------------------------------------------
-- Se envia correo a la oficina de gestión si corresponde
-------------------------------------------------------------------------------------------
      num_err := pac_avisos.f_accion(1, psseguro, 1, pcidioma_user, 'REAL', vcmotmov, 5,
                                     poficina, pterminal, v_nmovimi);

      IF num_err <> 0 THEN
         ocoderror := num_err;
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error_fin_supl;
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN error THEN
         ROLLBACK;
         RETURN NULL;
      WHEN error_fin_supl THEN
         ROLLBACK;
         num_err := pk_suplementos.f_final_suplemento(v_est_sseguro, v_nmovimi, psseguro);
         COMMIT;
         RETURN NULL;
      WHEN OTHERS THEN
         ocoderror := -999;
         omsgerror :=
            'Pac_Ref_Contrata_Aho.f_suplemento_forpag_prestacion: Error general en la función';
         ROLLBACK;
         p_tab_error(f_sysdate, getuser,
                     'Pac_Ref_Contrata_Aho.f_suplemento_forpag_prestacion', NULL,
                     'parametros: psseguro = ' || psseguro || ' pfefecto =' || pfefecto
                     || ' pcfprest = ' || pcfprest || ' poficina =' || poficina
                     || ' pterminal =' || pterminal || ' pcidioma_user =' || pcidioma_user,
                     SQLERRM);
         num_err := pk_suplementos.f_final_suplemento(v_est_sseguro, v_nmovimi, psseguro);
         COMMIT;
         RETURN NULL;
   END f_suplemento_forpag_prestacion;

   FUNCTION f_suplemento_aportacion_revali(
      psseguro IN NUMBER,
      pfefecto IN DATE,
      pcforpag IN NUMBER,
      pprima IN NUMBER,
      prevali IN NUMBER,
      poficina IN VARCHAR2,
      pterminal IN VARCHAR2,
      pcidioma_user IN NUMBER DEFAULT f_idiomauser,
      ocoderror OUT NUMBER,
      omsgerror OUT VARCHAR2)
      RETURN NUMBER IS
      /********************************************************************************************************************************
         Función que graba el suplemento de cambio de aportación, cambio de revalorización y suspensión/rehabilitación del pago periódico (cambio
         de forma de pago: única -> mensual, mensual -> única)
         Parámetros de entrada: . pcforpag = Código de la nueva forma de pago
                                . pprima = Importe prima periódica
                                . prevali = Porcentaje de revalorización

         La función retornará:
            0.- Si todo es correcto
            NULL -- si hay error o no se cumple alguan de las validaciones. El código de error y el texto se informarán
                            en los parámetros oCODERROR y oMSGERROR
      *****************************************************************************************************************************/
      num_err        NUMBER;
--       v_sseguro          NUMBER;
      v_nmovimi      NUMBER;
      v_est_sseguro  NUMBER;
      v_npoliza      NUMBER;
      v_ncertif      NUMBER;
      v_nrecibo      NUMBER;
      v_nsolici      NUMBER;
      v_sproduc      NUMBER;
      v_cont         NUMBER;
      vcmotmov       NUMBER;
      v_fefecto      DATE;
      v_sperson      NUMBER;
      error          EXCEPTION;
      error_fin_supl EXCEPTION;
   BEGIN
      -- Código del motivo de movimiento (suplemento)
      vcmotmov := 267;
      -- La fecha de efecto debe estar truncada
      v_fefecto := TRUNC(pfefecto);
--------------------------------------------------------------------------
-- Validar que la póliza permite el suplemento
--------------------------------------------------------------------------
      num_err := f_buscapoliza(psseguro, v_npoliza, v_ncertif);

      IF num_err <> 0 THEN
         ocoderror := num_err;
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error;
      END IF;

      num_err := pac_ref_contrata_comu.f_valida_poliza_permite_supl(v_npoliza, v_ncertif,
                                                                    v_fefecto, vcmotmov,
                                                                    pcidioma_user, ocoderror,
                                                                    omsgerror);

      IF num_err IS NULL THEN
         RAISE error;
      END IF;

--------------------------------------------------------------------------
-- Validamos que estén informados los datos del suplemento
--------------------------------------------------------------------------
      IF psseguro IS NULL THEN
         ocoderror := 111995;   -- Es obligatorio informar el número de seguro
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error;
      END IF;

      IF v_fefecto IS NULL THEN
         ocoderror := 120077;   -- Falta informar la fecha efecto
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error;
      END IF;

      IF pcforpag IS NULL THEN
         ocoderror := 120079;   -- Falta informar la forma de pago
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error;
      END IF;

      IF pprima IS NULL THEN
         ocoderror := 151359;   -- Falta informar la prima
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error;
      END IF;

      IF prevali IS NULL THEN
         ocoderror := 101630;   -- Falta el porcentaje de la revalorización
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error;
      END IF;

      IF poficina IS NULL THEN
         ocoderror := 180252;   -- Es obligatorio introducir la oficina
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error;
      END IF;

      IF pterminal IS NULL THEN
         ocoderror := 180253;   -- Es obligatorio introducir el terminal
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error;
      END IF;

--------------------------------------------------------------------------
-- Validar que:
--   . si pprima = 0  --> pcforpag debe ser 0
--   . si pprima <> 0 --> pcforpag NO debe ser 0
--------------------------------------------------------------------------
      IF pprima = 0
         AND pcforpag <> 0 THEN
         ocoderror := 180419;   -- La forma de pago debe ser Única
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error;
      END IF;

      IF pprima <> 0
         AND pcforpag = 0 THEN
         ocoderror := 180422;   -- La forma de pago no puede ser Única
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error;
      END IF;

--------------------------------------------------------------------------
-- Validar que si la póliza está reducida, no se puede hacer otro cambio
-- que no sea rehabilitar la póliza
--------------------------------------------------------------------------
      IF pac_ctaseguro.f_esta_reducida(psseguro) = 1
         AND pprima = 0 THEN
         ocoderror := 151980;   -- Póliza reducida
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error;
      END IF;

--------------------------------------------------------------------------
-- Validar el importe de la prima (si pprima <> 0)
--------------------------------------------------------------------------
      SELECT sproduc
        INTO v_sproduc
        FROM seguros
       WHERE sseguro = psseguro;

      IF pprima <> 0 THEN
         SELECT sperson
           INTO v_sperson
           FROM asegurados
          WHERE sseguro = psseguro
            AND norden = 1;

         num_err := pac_val_aho.f_valida_prima_aho(2, v_sproduc, v_sperson, 3, pprima,
                                                   pcforpag);

         IF num_err <> 0 THEN
            ocoderror := num_err;
            omsgerror := f_axis_literales(ocoderror, pcidioma_user);
            RAISE error;
         END IF;
      END IF;

-------------------------------------------------------------------------------------------
-- Se traspasan los datos a las tablas EST y se dejan preparadas para hacer el suplemento
-------------------------------------------------------------------------------------------
-- Todas las funciones a partir de esta deben tener RAISE error_fin_supl
      num_err := pk_suplementos.f_inicializar_suplemento(psseguro, 'SUPLEMENTO', v_fefecto,
                                                         'BBDD', '*', vcmotmov, v_est_sseguro,
                                                         v_nmovimi);

      IF num_err <> 0 THEN
         ocoderror := num_err;
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error_fin_supl;
      END IF;

------------------------------------------------------------------------------------------------------------
-- Se realiza la modificación del porcentaje de revalorización y la aportación periódica en las tablas EST
------------------------------------------------------------------------------------------------------------
      num_err := pac_prod_aho.f_cambio_aportacion_revali(v_est_sseguro, pcforpag, pprima,
                                                         prevali, v_nmovimi, v_fefecto);

      IF num_err <> 0 THEN
         ocoderror := num_err;
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error_fin_supl;
      END IF;

      -------------------------------------------------------------------------------------------
      -- Se valida que se haya realizado algún cambio
      -------------------------------------------------------------------------------------------
/*
      Select sproduc
      into v_sproduc
      From seguros
      Where sseguro = psseguro;
*/
      num_err := pk_suplementos.f_validar_cambios(f_user, v_est_sseguro, v_nmovimi, v_sproduc,
                                                  'BBDD', 'SUPLEMENTO');

      IF num_err <> 0 THEN
         ocoderror := num_err;
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error_fin_supl;
      END IF;

      BEGIN
         -- primero hay que validar que hay regisros en detmovseguro
         SELECT COUNT(*)
           INTO v_cont
           FROM estdetmovseguro
          WHERE sseguro = v_est_sseguro;
      EXCEPTION
         WHEN OTHERS THEN
            ocoderror := 180264;   -- Error al leer de la tabla ESTDETMOVSEGURO
            omsgerror := f_axis_literales(ocoderror, pcidioma_user);
            RAISE error_fin_supl;
      END;

      IF v_cont = 0 THEN   -- No ha habido ningún cambio
         ocoderror := 107804;   -- No se ha realizado ningún cambio
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error_fin_supl;
      END IF;

-------------------------------------------------------------------------------------------
-- Se graba el suplemento en las tablas reales
-------------------------------------------------------------------------------------------
      num_err := pk_suplementos.f_grabar_suplemento_poliza(v_est_sseguro, v_nmovimi);

      IF num_err <> 0 THEN
         ocoderror := num_err;
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error_fin_supl;
      END IF;

-------------------------------------------------------------------------------------------
-- Se emite el suplemento
-------------------------------------------------------------------------------------------
      num_err := pac_prod_comu.f_emite_propuesta(psseguro, v_npoliza, v_ncertif, v_nrecibo,
                                                 v_nsolici);

      IF num_err <> 0 THEN
         ocoderror := num_err;
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error_fin_supl;
      END IF;

-------------------------------------------------------------------------------------------
-- Se envia correo a la oficina de gestión si corresponde
-------------------------------------------------------------------------------------------
      num_err := pac_avisos.f_accion(1, psseguro, 1, pcidioma_user, 'REAL', vcmotmov, 5,
                                     poficina, pterminal, v_nmovimi);

      IF num_err <> 0 THEN
         ocoderror := num_err;
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error_fin_supl;
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN error THEN
         ROLLBACK;
         RETURN NULL;
      WHEN error_fin_supl THEN
         ROLLBACK;
         num_err := pk_suplementos.f_final_suplemento(v_est_sseguro, v_nmovimi, psseguro);
         COMMIT;
         RETURN NULL;
      WHEN OTHERS THEN
         ocoderror := -999;
         omsgerror :=
            'Pac_Ref_Contrata_Aho.f_suplemento_aportacion_revali: Error general en la función';
         ROLLBACK;
         p_tab_error(f_sysdate, getuser,
                     'Pac_Ref_Contrata_Aho.f_suplemento_aportacion_revali', NULL,
                     'parametros: psseguro = ' || psseguro || ' pfefecto =' || pfefecto
                     || ' pcforpag = ' || pcforpag || ' pprima = ' || pprima || ' prevali = '
                     || prevali || ' poficina =' || poficina || ' pterminal =' || pterminal
                     || ' pcidioma_user =' || pcidioma_user,
                     SQLERRM);
         num_err := pk_suplementos.f_final_suplemento(v_est_sseguro, v_nmovimi, psseguro);
         COMMIT;
         RETURN NULL;
   END f_suplemento_aportacion_revali;

   FUNCTION f_suplemento_modif_gar(
      psseguro IN NUMBER,
      pfefecto IN DATE,
      pcfallaseg1 IN NUMBER,
      pcfallaseg2 IN NUMBER,
      pcaccaseg1 IN NUMBER,
      pcaccaseg2 IN NUMBER,
      poficina IN VARCHAR2,
      pterminal IN VARCHAR2,
      pcidioma_user IN NUMBER DEFAULT f_idiomauser,
      ocoderror OUT NUMBER,
      omsgerror OUT VARCHAR2)
      RETURN NUMBER IS
      /********************************************************************************************************************************
         Función que graba el suplemento de cambio de forma de pago de la prestación
         Parámetros de entrada: . pcfallaseg1 = Indicador garantía fallecimiento asegurado 1 contratada
                                . pcfallaseg2 = Indicador garantía fallecimiento asegurado 2 contratada
                                . pcaccaseg1 = Indicador garantía accidentes asegurado 1 contratada
                                . pcaccaseg2 = Indicador garantía accidentes asegurado 2 contratada

         La función retornará:
            0.- Si todo es correcto
            NULL -- si hay error o no se cumple alguan de las validaciones. El código de error y el texto se informarán
                            en los parámetros oCODERROR y oMSGERROR
      *****************************************************************************************************************************/
      num_err        NUMBER;
--       v_sseguro          NUMBER;
      v_nmovimi      NUMBER;
      v_est_sseguro  NUMBER;
      v_npoliza      NUMBER;
      v_ncertif      NUMBER;
      v_nrecibo      NUMBER;
      v_nsolici      NUMBER;
      v_sproduc      NUMBER;
      v_cont         NUMBER;
      vcmotmov       NUMBER;
      v_fefecto      DATE;
      v_cfallaseg1   NUMBER;
      v_cfallaseg2   NUMBER;
      v_caccaseg1    NUMBER;
      v_caccaseg2    NUMBER;
      v_sperson1     NUMBER;
      v_sperson2     NUMBER;
      error          EXCEPTION;
      error_fin_supl EXCEPTION;

      CURSOR c_asegurados IS
         SELECT   sperson, norden
             FROM asegurados
            WHERE sseguro = psseguro
         ORDER BY norden;
   BEGIN
      -- Código del motivo de movimiento (suplemento)
      vcmotmov := 524;
      -- La fecha de efecto debe estar truncada
      v_fefecto := TRUNC(pfefecto);
--------------------------------------------------------------------------
-- Validar que la póliza permite el suplemento
--------------------------------------------------------------------------
      num_err := f_buscapoliza(psseguro, v_npoliza, v_ncertif);

      IF num_err <> 0 THEN
         ocoderror := num_err;
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error;
      END IF;

      num_err := pac_ref_contrata_comu.f_valida_poliza_permite_supl(v_npoliza, v_ncertif,
                                                                    v_fefecto, vcmotmov,
                                                                    pcidioma_user, ocoderror,
                                                                    omsgerror);

      IF num_err IS NULL THEN
         RAISE error;
      END IF;

--------------------------------------------------------------------------
-- Validamos que estén informados los datos del suplemento
--------------------------------------------------------------------------
      IF psseguro IS NULL THEN
         ocoderror := 111995;   -- Es obligatorio informar el número de seguro
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error;
      END IF;

      IF v_fefecto IS NULL THEN
         ocoderror := 120077;   -- Falta informar la fecha efecto
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error;
      END IF;

      -- Los valores de los parámetros de las garantías adicionales deben ser 0 o 1 ya que su valor viene de un check box
      -- que indicará 0.No contratada o 1.Contratada
      -- Si el parámetro no viene informado se considera que la garantía no está contratada.
      v_cfallaseg1 := NVL(pcfallaseg1, 0);
      v_cfallaseg2 := NVL(pcfallaseg2, 0);
      v_caccaseg1 := NVL(pcaccaseg1, 0);
      v_caccaseg2 := NVL(pcaccaseg2, 0);

      IF v_cfallaseg1 NOT IN(0, 1)
         OR v_cfallaseg2 NOT IN(0, 1)
         OR v_caccaseg1 NOT IN(0, 1)
         OR v_caccaseg2 NOT IN(0, 1) THEN
         ocoderror := 107839;   -- Error en los parámetros de entrada
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error;
      END IF;

      IF poficina IS NULL THEN
         ocoderror := 180252;   -- Es obligatorio introducir la oficina
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error;
      END IF;

      IF pterminal IS NULL THEN
         ocoderror := 180253;   -- Es obligatorio introducir el terminal
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error;
      END IF;

-------------------------------------------------------------------------------------------------------
-- Validamos las garantias de fallecimiento y accidente del asegurado 1 y asegurado 2
-------------------------------------------------------------------------------------------------------
      SELECT sproduc
        INTO v_sproduc
        FROM seguros
       WHERE sseguro = psseguro;

      v_sperson1 := NULL;
      v_sperson2 := NULL;

      FOR reg IN c_asegurados LOOP
         IF reg.norden = 1 THEN
            v_sperson1 := reg.sperson;
         ELSE
            v_sperson2 := reg.sperson;
         END IF;
      END LOOP;

      -- Garantia Fallecimiento Asegurado 1
      num_err := pac_val_aho.f_valida_garantia_adicional(v_sproduc, v_sperson1, v_cfallaseg1,
                                                         6, 1, v_fefecto);

      IF num_err <> 0 THEN
         ocoderror := num_err;
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error;
      END IF;

      -- Garantia Fallecimiento Asegurado 2
      num_err := pac_val_aho.f_valida_garantia_adicional(v_sproduc, v_sperson2, v_cfallaseg2,
                                                         6, 2, v_fefecto);

      IF num_err <> 0 THEN
         ocoderror := num_err;
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error;
      END IF;

      -- Garantia Accidente Asegurado 1
      num_err := pac_val_aho.f_valida_garantia_adicional(v_sproduc, v_sperson1, v_caccaseg1, 7,
                                                         1, v_fefecto);

      IF num_err <> 0 THEN
         ocoderror := num_err;
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error;
      END IF;

      -- Garantia Accidente Asegurado 2
      num_err := pac_val_aho.f_valida_garantia_adicional(v_sproduc, v_sperson2, v_caccaseg2, 7,
                                                         2, v_fefecto);

      IF num_err <> 0 THEN
         ocoderror := num_err;
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error;
      END IF;

-------------------------------------------------------------------------------------------
-- Se traspasan los datos a las tablas EST y se dejan preparadas para hacer el suplemento
-------------------------------------------------------------------------------------------
-- Todas las funciones a partir de esta deben tener RAISE error_fin_supl
      num_err := pk_suplementos.f_inicializar_suplemento(psseguro, 'SUPLEMENTO', v_fefecto,
                                                         'BBDD', '*', vcmotmov, v_est_sseguro,
                                                         v_nmovimi);

      IF num_err <> 0 THEN
         ocoderror := num_err;
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error_fin_supl;
      END IF;

-------------------------------------------------------------------------------------------
-- Se realiza la modificación de la forma de pago de la prestación en las tablas EST
-------------------------------------------------------------------------------------------
      num_err := pac_prod_aho.f_cambio_modif_gar(v_est_sseguro, v_cfallaseg1, v_cfallaseg2,
                                                 v_caccaseg1, v_caccaseg2, v_nmovimi,
                                                 v_fefecto);

      IF num_err <> 0 THEN
         ocoderror := num_err;
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error_fin_supl;
      END IF;

      -------------------------------------------------------------------------------------------
      -- Se valida que se haya realizado algún cambio
      -------------------------------------------------------------------------------------------
/*
      Select sproduc
      into v_sproduc
      From seguros
      Where sseguro = psseguro;
*/
      num_err := pk_suplementos.f_validar_cambios(f_user, v_est_sseguro, v_nmovimi, v_sproduc,
                                                  'BBDD', 'SUPLEMENTO');

      IF num_err <> 0 THEN
         ocoderror := num_err;
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error_fin_supl;
      END IF;

      BEGIN
         -- primero hay que validar que hay regisros en detmovseguro
         SELECT COUNT(*)
           INTO v_cont
           FROM estdetmovseguro
          WHERE sseguro = v_est_sseguro;
      EXCEPTION
         WHEN OTHERS THEN
            ocoderror := 180264;   -- Error al leer de la tabla ESTDETMOVSEGURO
            omsgerror := f_axis_literales(ocoderror, pcidioma_user);
            RAISE error_fin_supl;
      END;

      IF v_cont = 0 THEN   -- No ha habido ningún cambio
         ocoderror := 107804;   -- No se ha realizado ningún cambio
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error_fin_supl;
      END IF;

-------------------------------------------------------------------------------------------
-- Se graba el suplemento en las tablas reales
-------------------------------------------------------------------------------------------
      num_err := pk_suplementos.f_grabar_suplemento_poliza(v_est_sseguro, v_nmovimi);

      IF num_err <> 0 THEN
         ocoderror := num_err;
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error_fin_supl;
      END IF;

-------------------------------------------------------------------------------------------
-- Se emite el suplemento
-------------------------------------------------------------------------------------------
      num_err := pac_prod_comu.f_emite_propuesta(psseguro, v_npoliza, v_ncertif, v_nrecibo,
                                                 v_nsolici);

      IF num_err <> 0 THEN
         ocoderror := num_err;
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error_fin_supl;
      END IF;

-------------------------------------------------------------------------------------------
-- Se envia correo a la oficina de gestión si corresponde
-------------------------------------------------------------------------------------------
      num_err := pac_avisos.f_accion(1, psseguro, 1, pcidioma_user, 'REAL', vcmotmov, 5,
                                     poficina, pterminal, v_nmovimi);

      IF num_err <> 0 THEN
         ocoderror := num_err;
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error_fin_supl;
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN error THEN
         ROLLBACK;
         RETURN NULL;
      WHEN error_fin_supl THEN
         ROLLBACK;
         num_err := pk_suplementos.f_final_suplemento(v_est_sseguro, v_nmovimi, psseguro);
         COMMIT;
         RETURN NULL;
      WHEN OTHERS THEN
         ocoderror := -999;
         omsgerror :=
                    'Pac_Ref_Contrata_Aho.f_suplemento_modif_gar: Error general en la función';
         ROLLBACK;
         p_tab_error(f_sysdate, getuser, 'Pac_Ref_Contrata_Aho.f_suplemento_modif_gar', NULL,
                     'parametros: psseguro = ' || psseguro || ' pfefecto =' || pfefecto
                     || ' pcfallaseg1 = ' || pcfallaseg1 || ' pcfallaseg2 = ' || pcfallaseg2
                     || ' pcaccaseg1 = ' || pcaccaseg1 || ' pcaccaseg2 = ' || pcaccaseg2
                     || ' poficina =' || poficina || ' pterminal =' || pterminal
                     || ' pcidioma_user =' || pcidioma_user,
                     SQLERRM);
         num_err := pk_suplementos.f_final_suplemento(v_est_sseguro, v_nmovimi, psseguro);
         COMMIT;
         RETURN NULL;
   END f_suplemento_modif_gar;

   FUNCTION f_suplemento_fvencimiento(
      psseguro IN NUMBER,
      pfefecto IN DATE,
      pfvencim IN DATE,
      poficina IN VARCHAR2,
      pterminal IN VARCHAR2,
      pcidioma_user IN NUMBER DEFAULT f_idiomauser,
      ocoderror OUT NUMBER,
      omsgerror OUT VARCHAR2)
      RETURN NUMBER IS
      /********************************************************************************************************************************
         Función que graba el suplemento de cambio de vencimiento
         Parámetros de entrada: . pfvencim = Valor de la nueva fecha de vencimiento de la póliza

         La función retornará:
            0.- Si todo es correcto
            NULL -- si hay error o no se cumple alguan de las validaciones. El código de error y el texto se informarán
                            en los parámetros oCODERROR y oMSGERROR
      *****************************************************************************************************************************/
      num_err        NUMBER;
--       v_sseguro          NUMBER;
      v_nmovimi      NUMBER;
      v_est_sseguro  NUMBER;
      v_npoliza      NUMBER;
      v_ncertif      NUMBER;
      v_nrecibo      NUMBER;
      v_nsolici      NUMBER;
      v_sproduc      NUMBER;
      v_cont         NUMBER;
      vcmotmov       NUMBER;
      v_fefecto      DATE;
      v_icapital     NUMBER;
      v_fvencim_act  DATE;
      error          EXCEPTION;
      error_fin_supl EXCEPTION;
   BEGIN
      -- Código del motivo de movimiento (suplemento)
      vcmotmov := 219;
      -- La fecha de efecto debe estar truncada
      v_fefecto := TRUNC(pfefecto);
--------------------------------------------------------------------------
-- Validar que la póliza permite el suplemento
--------------------------------------------------------------------------
      num_err := f_buscapoliza(psseguro, v_npoliza, v_ncertif);

      IF num_err <> 0 THEN
         ocoderror := num_err;
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error;
      END IF;

      num_err := pac_ref_contrata_comu.f_valida_poliza_permite_supl(v_npoliza, v_ncertif,
                                                                    v_fefecto, vcmotmov,
                                                                    pcidioma_user, ocoderror,
                                                                    omsgerror);

      IF num_err IS NULL THEN
         RAISE error;
      END IF;

--------------------------------------------------------------------------
-- Validamos que estén informados los datos del suplemento
--------------------------------------------------------------------------
      IF psseguro IS NULL THEN
         ocoderror := 111995;   -- Es obligatorio informar el número de seguro
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error;
      END IF;

      IF v_fefecto IS NULL THEN
         ocoderror := 120077;   -- Falta informar la fecha efecto
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error;
      END IF;

      IF pfvencim IS NULL THEN
         ocoderror := 101430;   -- Falta fecha de vencimiento
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error;
      END IF;

      IF poficina IS NULL THEN
         ocoderror := 180252;   -- Es obligatorio introducir la oficina
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error;
      END IF;

/*
      IF pterminal IS NULL THEN
         oCODERROR := 180253;  -- Es obligatorio introducir el terminal
         oMSGERROR := f_axis_literales(oCODERROR, pcidioma_user);
         RAISE error;
      END IF;
*/

      -------------------------------------------------------------------------------------------
-- Se valida que la fecha de vencimiento nueva sea mayor que la fecha de vencimiento actual
-------------------------------------------------------------------------------------------
      BEGIN
         SELECT fvencim
           INTO v_fvencim_act
           FROM seguros
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN OTHERS THEN
            ocoderror := 101919;   -- Error al leer datos de la tabla SEGUROS
            omsgerror := f_axis_literales(ocoderror, pcidioma_user);
            RAISE error;
      END;

      IF v_fvencim_act >= pfvencim THEN
         ocoderror := 180662;
         -- La nueva fecha de vencimiento debe ser mayor a la fecha de vencimiento actual de la póliza
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error;
      END IF;

-- Se crea un Saldo en Cuenta Libreta
-------------------------------------------------------------------------------------------
      num_err := pac_ctaseguro.f_inscta_prov_cap(psseguro, v_fefecto, 'R', NULL);

      IF num_err <> 0 THEN
         ocoderror := num_err;
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error_fin_supl;
      END IF;

      IF pac_ctaseguro.f_tiene_ctashadow(psseguro, NULL) = 1 THEN
         num_err := pac_ctaseguro.f_inscta_prov_cap_shw(psseguro, v_fefecto, 'R', NULL);

         IF num_err <> 0 THEN
            ocoderror := num_err;
            omsgerror := f_axis_literales(ocoderror, pcidioma_user);
            RAISE error_fin_supl;
         END IF;
      END IF;

-------------------------------------------------------------------------------------------
-- Se traspasan los datos a las tablas EST y se dejan preparadas para hacer el suplemento
-------------------------------------------------------------------------------------------
-- Todas las funciones a partir de esta deben tener RAISE error_fin_supl
      num_err := pk_suplementos.f_inicializar_suplemento(psseguro, 'SUPLEMENTO', v_fefecto,
                                                         'BBDD', '*', vcmotmov, v_est_sseguro,
                                                         v_nmovimi);

      IF num_err <> 0 THEN
         ocoderror := num_err;
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error_fin_supl;
      END IF;

-------------------------------------------------------------------------------------------
-- Se realiza la modificación del cambio de la fecha de vencimiento en las tablas EST
-------------------------------------------------------------------------------------------
      num_err := pac_prod_aho.f_cambio_fvencimiento(v_est_sseguro, pfvencim, v_nmovimi,
                                                    v_fefecto);

      IF num_err <> 0 THEN
         ocoderror := num_err;
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error_fin_supl;
      END IF;

-------------------------------------------------------------------------------------------
-- Se valida que se haya realizado algún cambio
-------------------------------------------------------------------------------------------
      SELECT sproduc
        INTO v_sproduc
        FROM seguros
       WHERE sseguro = psseguro;

      num_err := pk_suplementos.f_validar_cambios(f_user, v_est_sseguro, v_nmovimi, v_sproduc,
                                                  'BBDD', 'SUPLEMENTO');

      IF num_err <> 0 THEN
         ocoderror := num_err;
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error_fin_supl;
      END IF;

      BEGIN
         -- primero hay que validar que hay regisros en detmovseguro
         SELECT COUNT(*)
           INTO v_cont
           FROM estdetmovseguro
          WHERE sseguro = v_est_sseguro;
      EXCEPTION
         WHEN OTHERS THEN
            ocoderror := 180264;   -- Error al leer de la tabla ESTDETMOVSEGURO
            omsgerror := f_axis_literales(ocoderror, pcidioma_user);
            RAISE error_fin_supl;
      END;

      IF v_cont = 0 THEN   -- No ha habido ningún cambio
         ocoderror := 107804;   -- No se ha realizado ningún cambio
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error_fin_supl;
      END IF;

-------------------------------------------------------------------------------------------
-- Se graba el suplemento en las tablas reales
-------------------------------------------------------------------------------------------
      num_err := pk_suplementos.f_grabar_suplemento_poliza(v_est_sseguro, v_nmovimi);

      IF num_err <> 0 THEN
         ocoderror := num_err;
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error_fin_supl;
      END IF;

-------------------------------------------------------------------------------------------
-- Se emite el suplemento
-------------------------------------------------------------------------------------------
      num_err := pac_prod_comu.f_emite_propuesta(psseguro, v_npoliza, v_ncertif, v_nrecibo,
                                                 v_nsolici);

      IF num_err <> 0 THEN
         ocoderror := num_err;
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error_fin_supl;
      END IF;

      -- Se actualiza el Capital Garantizado de la línea de Cuenta Libreta que se ha creado con el valor actual
      -- del capital garantizado en garanseg
      BEGIN
         SELECT icapital
           INTO v_icapital
           FROM garanseg
          WHERE sseguro = psseguro
            AND cgarant = 283
            AND ffinefe IS NULL;
      EXCEPTION
         WHEN OTHERS THEN
            ocoderror := 103500;   -- Error al leer de la tabla GARANSEG
            omsgerror := f_axis_literales(ocoderror, pcidioma_user);
            RAISE error_fin_supl;
      END;

      BEGIN
         UPDATE ctaseguro_libreta
            SET ccapgar = v_icapital
          WHERE sseguro = psseguro
            AND nnumlin = (SELECT MAX(nnumlin)
                             FROM ctaseguro_libreta
                            WHERE sseguro = psseguro);

         UPDATE ctaseguro_libreta_shw
            SET ccapgar = v_icapital
          WHERE sseguro = psseguro
            AND nnumlin = (SELECT MAX(nnumlin)
                             FROM ctaseguro_libreta
                            WHERE sseguro = psseguro);
      EXCEPTION
         WHEN OTHERS THEN
            ocoderror := 180650;
            -- Error al modificar la tabla CTASEGURO_LIBRETA
            omsgerror := f_axis_literales(ocoderror, pcidioma_user);
            RAISE error_fin_supl;
      END;

-------------------------------------------------------------------------------------------
-- Se envia correo a la oficina de gestión si corresponde
-------------------------------------------------------------------------------------------
      num_err := pac_avisos.f_accion(1, psseguro, 1, pcidioma_user, 'REAL', vcmotmov, 5,
                                     poficina, pterminal, v_nmovimi);

      IF num_err <> 0 THEN
         ocoderror := num_err;
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error_fin_supl;
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN error THEN
         ROLLBACK;
         RETURN NULL;
      WHEN error_fin_supl THEN
         ROLLBACK;
         num_err := pk_suplementos.f_final_suplemento(v_est_sseguro, v_nmovimi, psseguro);
         COMMIT;
         RETURN NULL;
      WHEN OTHERS THEN
         ocoderror := -999;
         omsgerror :=
                 'Pac_Ref_Contrata_Aho.f_suplemento_fvencimiento: Error general en la función';
         ROLLBACK;
         p_tab_error(f_sysdate, getuser, 'Pac_Ref_Contrata_Aho.f_suplemento_fvencimiento',
                     NULL,
                     'parametros: psseguro = ' || psseguro || ' pfefecto =' || pfefecto
                     || ' pfvencim = ' || pfvencim || ' poficina =' || poficina
                     || ' pterminal =' || pterminal || ' pcidioma_user =' || pcidioma_user,
                     SQLERRM);
         num_err := pk_suplementos.f_final_suplemento(v_est_sseguro, v_nmovimi, psseguro);
         COMMIT;
         RETURN NULL;
   END f_suplemento_fvencimiento;

   FUNCTION f_aportacion_extraordinaria(
      psseguro IN NUMBER,
      pfefecto IN DATE,
      pprima IN NUMBER,
      pcbancar_recibo IN VARCHAR2,
      poficina IN VARCHAR2,
      pterminal IN VARCHAR2,
      pcidioma_user IN NUMBER DEFAULT f_idiomauser,
      ocoderror OUT NUMBER,
      omsgerror OUT VARCHAR2)
      RETURN NUMBER IS
      /********************************************************************************************************************************
         Función que graba una aportación extraordinaria y realiza el cobro del recibo si corresponde.
         Parámetros de entrada: . pprima = Importe de la prima extraordinaria
                                . pcbancar_recibo = CCC de cargo

         La función retornará:
            0.- Si todo es correcto
            NULL -- si hay error o no se cumple alguan de las validaciones. El código de error y el texto se informarán
                            en los parámetros oCODERROR y oMSGERROR
      *****************************************************************************************************************************/
      num_err        NUMBER;
--       v_sseguro          NUMBER;
      v_nmovimi      NUMBER;
      v_est_sseguro  NUMBER;
      v_npoliza      NUMBER;
      v_ncertif      NUMBER;
      v_nrecibo      NUMBER;
      v_nsolici      NUMBER;
      v_sproduc      NUMBER;
      v_cont         NUMBER;
      vcmotmov       NUMBER;
      v_fefecto      DATE;
      v_sperson      NUMBER;
      v_cforpag      NUMBER;
      v_recibo_cobrado BOOLEAN;
      v_descsproduc  VARCHAR2(30);
      v_importe      NUMBER;
      v_nnumnif      VARCHAR2(20);
      v_nnifdup      NUMBER;
      v_nnifrep      NUMBER;
      v_cnifrep      NUMBER;
      v_tnumnif      VARCHAR2(100);
      v_npoliza_ncertif NUMBER;
      v_ccobban      NUMBER;
      v_cramo        NUMBER;
      v_cmodali      NUMBER;
      v_ctipseg      NUMBER;
      v_ccolect      NUMBER;
      v_cagente      NUMBER;
      v_ncuenta      NUMBER;
      v_cdelega      recibos.cdelega%TYPE;
      error          EXCEPTION;
      error_fin_supl EXCEPTION;
   BEGIN
      -- Código del motivo de movimiento (suplemento)
      vcmotmov := 500;   -- Aportación Extraordinaria
      -- La fecha de efecto debe estar truncada
      v_fefecto := TRUNC(pfefecto);
--------------------------------------------------------------------------
-- Validar que la póliza permite la aportación extraordinaria
--------------------------------------------------------------------------
      num_err := f_buscapoliza(psseguro, v_npoliza, v_ncertif);

      IF num_err <> 0 THEN
         ocoderror := num_err;
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error;
      END IF;

      num_err := pac_ref_contrata_comu.f_valida_poliza_permite_supl(v_npoliza, v_ncertif,
                                                                    v_fefecto, vcmotmov,
                                                                    pcidioma_user, ocoderror,
                                                                    omsgerror);

      IF num_err IS NULL THEN
         RAISE error;
      END IF;

--------------------------------------------------------------------------
-- Validamos que estén informados los datos del suplemento
--------------------------------------------------------------------------
      IF psseguro IS NULL THEN
         ocoderror := 111995;   -- Es obligatorio informar el número de seguro
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error;
      END IF;

      IF v_fefecto IS NULL THEN
         ocoderror := 120077;   -- Falta informar la fecha efecto
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error;
      END IF;

      IF pprima IS NULL THEN
         ocoderror := 151359;   -- Falta informar la prima
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error;
      END IF;

      IF pcbancar_recibo IS NULL THEN
         ocoderror := 151033;   -- Es obligatorio introducir la cuenta bancaria
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error;
      END IF;

      IF poficina IS NULL THEN
         ocoderror := 180252;   -- Es obligatorio introducir la oficina
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error;
      END IF;

      IF pterminal IS NULL THEN
         ocoderror := 180253;   -- Es obligatorio introducir el terminal
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error;
      END IF;

--------------------------------------------------------------------------
-- Validar que la cuenta está permitida
--------------------------------------------------------------------------
      num_err := pac_val_comu.f_valida_ccc(pcbancar_recibo, 1);

      IF num_err <> 0 THEN
         ocoderror := num_err;
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error;
      END IF;

--------------------------------------------------------------------------
-- Validar el importe de la prima (si pprima <> 0)
--------------------------------------------------------------------------
      SELECT sproduc, cforpag
        INTO v_sproduc, v_cforpag
        FROM seguros
       WHERE sseguro = psseguro;

      SELECT sperson
        INTO v_sperson
        FROM asegurados
       WHERE sseguro = psseguro
         AND norden = 1;

      num_err := pac_val_aho.f_valida_prima_aho(2, v_sproduc, v_sperson, 4, pprima, v_cforpag);

      IF num_err <> 0 THEN
         ocoderror := num_err;
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error;
      END IF;

-------------------------------------------------------------------------------------------
-- Se traspasan los datos a las tablas EST y se dejan preparadas para hacer el suplemento
-------------------------------------------------------------------------------------------
-- Todas las funciones a partir de esta deben tener RAISE error_fin_supl
      num_err := pk_suplementos.f_inicializar_suplemento(psseguro, 'SUPLEMENTO', v_fefecto,
                                                         'BBDD', '*', vcmotmov, v_est_sseguro,
                                                         v_nmovimi);

      IF num_err <> 0 THEN
         ocoderror := num_err;
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error_fin_supl;
      END IF;

-------------------------------------------------------------------------------------------
-- Se registra la aportación extraordinaria en las tablas EST
-------------------------------------------------------------------------------------------
      num_err := pac_prod_aho.f_cambio_aport_extr(v_est_sseguro, v_fefecto, pprima, v_nmovimi);

      IF num_err <> 0 THEN
         ocoderror := num_err;
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error_fin_supl;
      END IF;

-------------------------------------------------------------------------------------------
-- Se valida que se haya realizado algún cambio
-------------------------------------------------------------------------------------------
      num_err := pk_suplementos.f_validar_cambios(f_user, v_est_sseguro, v_nmovimi, v_sproduc,
                                                  'BBDD', 'SUPLEMENTO');

      IF num_err <> 0 THEN
         ocoderror := num_err;
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error_fin_supl;
      END IF;

      BEGIN
         -- primero hay que validar que hay regisros en detmovseguro
         SELECT COUNT(*)
           INTO v_cont
           FROM estdetmovseguro
          WHERE sseguro = v_est_sseguro;
      EXCEPTION
         WHEN OTHERS THEN
            ocoderror := 180264;   -- Error al leer de la tabla ESTDETMOVSEGURO
            omsgerror := f_axis_literales(ocoderror, pcidioma_user);
            RAISE error_fin_supl;
      END;

      IF v_cont = 0 THEN   -- No ha habido ningún cambio
         ocoderror := 107804;   -- No se ha realizado ningún cambio
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error_fin_supl;
      END IF;

-------------------------------------------------------------------------------------------
-- Se graba el suplemento en las tablas reales
-------------------------------------------------------------------------------------------
      num_err := pk_suplementos.f_grabar_suplemento_poliza(v_est_sseguro, v_nmovimi);

      IF num_err <> 0 THEN
         ocoderror := num_err;
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error_fin_supl;
      END IF;

-------------------------------------------------------------------------------------------
-- Se emite el suplemento
-------------------------------------------------------------------------------------------
      num_err := pac_prod_comu.f_emite_propuesta(psseguro, v_npoliza, v_ncertif, v_nrecibo,
                                                 v_nsolici);

      IF num_err <> 0 THEN
         ocoderror := num_err;
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error_fin_supl;
      END IF;

-----------------------------------------------------------------------------
-- Comprobar si se puede realizar el cobro del recibo on-line
-- Si se puede, entonces : . se cobra el recibo en HOST
--                            Si todo OK Entonces
--                               . se cobra el recibo en SIS
--                               Si todo Ok Entonces
--                                 . Se envia correo a la oficina de gestión si corresponde
--                               Sino
--                                 . Salir y mostrar mensaje de error
--                            Sino
--                               . Salir y mostrar mensaje error
-- Si no se puede, entonces :
--                         . El recibo se quedará pendiente de domiciliar (recibos.cestimp = 4)
----------------------------------------------------------------------------
      --IF f_usuario_cobro(poficina, v_sproduc) = 1 THEN   -- Sí se puede realizar el cobro On_Line
---------------------------------
-- Se cobra el recibo en HOST
---------------------------------
      num_err := f_dessproduc(v_sproduc, 2, pcidioma_user, v_descsproduc);

      IF num_err <> 0 THEN
         ocoderror := num_err;
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error_fin_supl;
      END IF;

      BEGIN
         SELECT itotalr
           INTO v_importe
           FROM vdetrecibos
          WHERE nrecibo = v_nrecibo;
      EXCEPTION
         WHEN OTHERS THEN
            ocoderror := 103936;
            -- Recibo no encontrado en la tabla VDETRECIBOS
            omsgerror := f_axis_literales(ocoderror, pcidioma_user);
            RAISE error_fin_supl;
      END;

      -- Bug 7854 y 8745 - 12/02/2009 - RSC - Adaptación iAxis a productos colectivos con certificados
      -- Bug 7854 y 8745 - 'ADMITE_CERTIFICADOS'
      BEGIN
         SELECT DECODE(productos.csubpro,
                       3, seguros.ncertif,
                       DECODE(NVL(f_parproductos_v(productos.sproduc, 'ADMITE_CERTIFICADOS'),
                                  0),
                              1, seguros.ncertif,
                              seguros.npoliza))
           INTO v_npoliza_ncertif
           FROM seguros, productos
          WHERE seguros.sproduc = productos.sproduc
            AND seguros.sseguro = psseguro;
      EXCEPTION
         WHEN OTHERS THEN
            ocoderror := 140897;   -- Error al buscar la poliza
            omsgerror := f_axis_literales(ocoderror, pcidioma_user);
            RAISE error_fin_supl;
      END;

      -- Se busca la cuenta donde se realizará el abono
      BEGIN
         SELECT cramo, cmodali, ctipseg, ccolect, cagente
           INTO v_cramo, v_cmodali, v_ctipseg, v_ccolect, v_cagente
           FROM seguros
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN OTHERS THEN
            ocoderror := 101919;
            -- Error al leer datos de la tabla SEGUROS
            omsgerror := f_axis_literales(ocoderror, pcidioma_user);
            RAISE error_fin_supl;
      END;

      v_ccobban := f_buscacobban(v_cramo, v_cmodali, v_ctipseg, v_ccolect, v_cagente,
                                 pcbancar_recibo, 1, num_err);

      IF v_ccobban IS NULL THEN
         ocoderror := num_err;
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error_fin_supl;
      END IF;

      num_err := f_descuentacob(v_ccobban, v_ncuenta);

      IF num_err <> 0 THEN
         ocoderror := num_err;
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error_fin_supl;
      END IF;

      v_recibo_cobrado := f_sg0carg(getuser, pterminal, LPAD(producto(1, v_sproduc), 8, '0'),
                                    f_empseguro(psseguro),   -- Codi empresa
                                    v_descsproduc, v_importe * 100, pfefecto, pcbancar_recibo,
                                    ff_buscanif(v_sperson), LPAD(v_ncuenta, 20, 0), 1,   -- Tipus d'operació: 1.Alta
                                    f_nombre(v_sperson, 1, v_cagente), v_npoliza_ncertif, NULL,
                                    ocoderror, omsgerror);

      -- Se ha podido cobrar el recibo en HOST
      IF v_recibo_cobrado THEN
--------------------------------------------------------------------
-- RSC 8-05-2008 Tarea 5645 Incidencia Documento INC_DOC53.4
-- (Error en cobro aportación extraordinaria)
-- Añadimos un commit aqui (Ya que si se ha realizado el cobro en HOST
-- este recibo ya se le ha cobrado al cliente y por tanto debe quedar
-- constancia en SIS al menos del movimiento de aportación. Luego
-- haremos el tratamiento del cobro en SIS, pero por lo menos poner
-- un COMMIT aqui para grabar parte del suplemento.
--------------------------------------------------------------------
         COMMIT;

---------------------------------
-- Se cobra el recibo en SIS
---------------------------------
--BUG 10069 - 15/06/2009 - JTS
         SELECT cdelega
           INTO v_cdelega
           FROM recibos
          WHERE nrecibo = v_nrecibo;

         num_err := pac_gestion_rec.f_cobro_recibo(f_empseguro(psseguro), v_nrecibo, v_fefecto,
                                                   NULL, NULL, v_ccobban, v_cdelega);

           -- num_err := pac_prod_comu.f_cobro_recibo(v_nrecibo, pcbancar_recibo);
--Fi BUG 10069 - 15/06/2009 - JTS
         IF num_err <> 0 THEN
            ocoderror := num_err;
            omsgerror := f_axis_literales(num_err, pcidioma_user);
            p_tab_error
               (f_sysdate, getuser,
                f_axis_literales(180848, pcidioma_user)
                || ' (Pac_Ref_Contrata_Aho.f_aportacion_extraordinaria - Pac_Prod_Comu.f_cobro_recibo)',
                NULL,
                'Sseguro=' || psseguro || ', Error: '
                || f_axis_literales(num_err, pcidioma_user),
                'Sseguro=' || psseguro || ', pfefecto=' || pfefecto || ', pprima=' || pprima
                || ', pcbancar_recibo=' || pcbancar_recibo || ', poficina=' || poficina
                || ', pterminal=' || pterminal || ', pcidioma_user=' || pcidioma_user);
            RAISE error_fin_supl;
         END IF;
      ELSE   -- No se ha podido cobrar el recibo en HOST
         RAISE error_fin_supl;
      END IF;

-------------------------------------------------------------------------------------------
-- Se envia correo a la oficina de gestión si corresponde
-------------------------------------------------------------------------------------------
      num_err := pac_avisos.f_accion(1, psseguro, 1, pcidioma_user, 'REAL', vcmotmov, 5,
                                     poficina, pterminal, v_nmovimi);

      IF num_err <> 0 THEN
         ocoderror := num_err;
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error_fin_supl;
      END IF;

            /*ELSE   -- Sí NO se puede realizar el cobro On_Line
      -------------------------------------------------------------------------------------------
      -- Se envia correo a la oficina de gestión si corresponde
      -------------------------------------------------------------------------------------------
               num_err := pac_avisos.f_accion(1, psseguro, 1, pcidioma_user, 'REAL', vcmotmov, 5,
                                              poficina, pterminal, v_nmovimi);

               IF num_err <> 0 THEN
                  ocoderror := num_err;
                  omsgerror := f_axis_literales(ocoderror, pcidioma_user);
                  RAISE error_fin_supl;
               END IF;
            END IF;*/
      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN error THEN
         ROLLBACK;
         RETURN NULL;
      WHEN error_fin_supl THEN
         ROLLBACK;
         num_err := pk_suplementos.f_final_suplemento(v_est_sseguro, v_nmovimi, psseguro);
         COMMIT;
         RETURN NULL;
      WHEN OTHERS THEN
         ocoderror := -999;
         omsgerror :=
               'Pac_Ref_Contrata_Aho.f_aportacion_extraordinaria: Error general en la función';
         ROLLBACK;
         p_tab_error(f_sysdate, getuser, 'Pac_Ref_Contrata_Aho.f_aportacion_extraordinaria',
                     NULL,
                     'parametros: psseguro = ' || psseguro || ' pfefecto =' || pfefecto
                     || ' pprima = ' || pprima || ' pcbancar_recibo = ' || pcbancar_recibo
                     || ' poficina =' || poficina || ' pterminal =' || pterminal
                     || ' pcidioma_user =' || pcidioma_user,
                     SQLERRM);
         num_err := pk_suplementos.f_final_suplemento(v_est_sseguro, v_nmovimi, psseguro);
         COMMIT;
         RETURN NULL;
   END f_aportacion_extraordinaria;

   FUNCTION f_revision_renovacion(
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      pndurper IN NUMBER,
      ppinttec IN NUMBER,
      pcidioma_user IN NUMBER DEFAULT f_idiomauser,
      ocoderror OUT NUMBER,
      omsgerror OUT VARCHAR2)
      RETURN NUMBER IS
      /********************************************************************************************************************************
         Función que lanzará (marcará) una póliza para su renovación/revisión con los nuevos valores a aplicar: duración
         y % de interés garantizado.

         Parámetros de entrada:
              . pnpoliza = Número de póliza
              . pncertif = Número de certificado
              . pndurper = Duración período
              . ppinttec = % Interés Técnico
         Parámetros de salida:
              . ocoderror = Código de Error
              . omsgerror = Descripción del error

            La función retorna:
               0 - si ha ido bien
              Null - si no cumple alguna validación o hay un error.
      *********************************************************************************************************************************/
      num_err        NUMBER;
      v_sseguro      NUMBER;
      v_sproduc      NUMBER;
      error          EXCEPTION;
   BEGIN
      -- Se busca el sseguro de la póliza
      v_sseguro := ff_buscasseguro(pnpoliza, pncertif);

      IF v_sseguro IS NULL THEN
         num_err := 111995;   -- Es obligatorio informar el número de seguro
         RAISE error;
      END IF;

      -- Se valida que la póliza esté en periodo de renovación
      num_err := pac_val_comu.f_valida_poliza_renova(v_sseguro, 2);

      -- 2 = Renovación/Revisión
      IF num_err <> 0 THEN
         RAISE error;
      END IF;

      -- Se valida la nueva duración seleccionada
      -- RSC 28/11/2007 ------------------------------------------------------
      SELECT sproduc
        INTO v_sproduc
        FROM seguros
       WHERE sseguro = v_sseguro;

      IF pndurper IS NOT NULL THEN
         num_err := pac_val_comu.f_valida_duracion_renova(v_sseguro, pndurper);

         IF num_err <> 0 THEN
            RAISE error;
         END IF;
      END IF;

-----------------------------------------------------------------------

      -- Se registran los nuevos valores de duración e interés a aplicar en la revisión/renovación
      --JRH 11/2007 Llamamos al Pac_Prod_Comu ahora.
      num_err := pac_prod_comu.f_programa_revision_renovacion(v_sseguro, pndurper, ppinttec,
                                                              NULL);

      IF num_err <> 0 THEN
         RAISE error;
      END IF;

      -- Todo OK
      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN error THEN
         ocoderror := num_err;
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         ROLLBACK;
         RETURN NULL;
      WHEN OTHERS THEN
         ocoderror := 108190;   -- Error General
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         ROLLBACK;
         p_tab_error(f_sysdate, getuser, 'Pac_Ref_Contrata_Aho.f_revision_renovacion', NULL,
                     'parametros: pnpoliza=' || pnpoliza || ' pncertif=' || pncertif
                     || ' pndurper=' || pndurper || ' ppinttec=' || ppinttec,
                     SQLERRM);
         RETURN NULL;
   END f_revision_renovacion;

   FUNCTION f_genera_poliza_aho(
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
      prima_inicial IN NUMBER,
      prima_per IN NUMBER,
      prevali IN NUMBER,
      pcfallaseg1 IN NUMBER,
      pcfallaseg2 IN NUMBER,
      pcaccaseg1 IN NUMBER,
      pcaccaseg2 IN NUMBER,
      pcbancar_recibo IN VARCHAR2,
      pterminal IN NUMBER,
      pcidioma_user IN NUMBER DEFAULT f_idiomauser,
      psseguro IN OUT NUMBER,
      pnpoliza OUT NUMBER,
      pncertif OUT NUMBER,
      pnsolici OUT NUMBER,
      pcsituac OUT NUMBER,
      ocoderror OUT NUMBER,
      omsgerror OUT VARCHAR2)
      RETURN NUMBER IS
/*****************************************************************************************************************************************
  En esta función se grabará una póliza de ahorro en las tablas EST con todos los datos y se tarifará. (previamente valdiamos
  todos los datos introducidos)
  Si todo es correcto hará el traspaso de las tablas EST a las definitivas y emitirá la póliza generando el recibo
  correspondiente.

  Si el parámetro psseguro NO viene infomado será una propuesta nueva, por lo tanto se inserta en las tablas EST
  Si el parámetro psseguro SI llega informado será una modificación de los datos de la propuesta.

      La función retorna:
         -- npoliza y ncertif: si todo es correcto
          -- NULL: si hay error. El código de error y el texto se informarán  en los parámetros oCODERROR y oMSGERROR
************************************************************************************************************************************/
      num_err        NUMBER;
      vnpoliza       NUMBER;
      vncertif       NUMBER;
      vnsolici       NUMBER;
      vcsituac       NUMBER;
      vcapgar        NUMBER;
      vcapfall       NUMBER;
      vcapgar_per    NUMBER;
      error          EXCEPTION;
      v_fnacimi1     DATE;
      v_csexo1       NUMBER;
      v_cestado1     NUMBER;
      v_csujeto1     NUMBER;
      v_cpais1       NUMBER;
      v_fnacimi2     DATE;
      v_csexo2       NUMBER;
      v_cestado2     NUMBER;
      v_csujeto2     NUMBER;
      v_cpais2       NUMBER;
      v_cfallaseg1   NUMBER;
      v_cfallaseg2   NUMBER;
      v_caccaseg1    NUMBER;
      v_caccaseg2    NUMBER;
      v_sseguro_est  NUMBER;
      v_nrecibo      NUMBER;
      v_fefecto      DATE;
      v_recibo_cobrado BOOLEAN;
      v_descsproduc  VARCHAR2(30);
      v_importe      NUMBER;
      v_nnumnif      VARCHAR2(20);
      v_nnifdup      NUMBER;
      v_nnifrep      NUMBER;
      v_cnifrep      NUMBER;
      v_tnumnif      VARCHAR2(100);
      v_npoliza_ncertif NUMBER;
      v_ccobban      NUMBER;
      v_cramo        NUMBER;
      v_cmodali      NUMBER;
      v_ctipseg      NUMBER;
      v_ccolect      NUMBER;
      v_cagente      NUMBER;
      v_ncuenta      NUMBER;
      v_cdelega      NUMBER;
   BEGIN
      -- La fecha de efecto debe estar truncada
      v_fefecto := TRUNC(pfefecto);

------------------------------------------------------------------------
-- Validamos el código del producto
------------------------------------------------------------------------
      IF psproduc IS NULL THEN
         ocoderror := 120149;   -- Es obligatorio introducir un producte
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error;
      END IF;

------------------------------------------------------------------------
-- Validamos el Terminal
------------------------------------------------------------------------
      IF pterminal IS NULL THEN
         ocoderror := 180253;   -- Es obligatorio introducir el terminal
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error;
      END IF;

------------------------------------------------------------------------
-- Validamos el código del agente
------------------------------------------------------------------------
      num_err := pac_val_comu.f_valida_agente(pcagente);

      IF num_err <> 0 THEN
         ocoderror := num_err;
         omsgerror := f_axis_literales(num_err, pcidioma_user);
         RAISE error;
      END IF;

------------------------------------------------------------------------
-- Validamos la fecha de efecto
------------------------------------------------------------------------
      IF v_fefecto IS NULL THEN
         ocoderror := 104532;   -- Fecha efecto obligatoria
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error;
      END IF;

------------------------------------------------------------------------
-- Validamos las garantias adicionales
------------------------------------------------------------------------
-- Los valores de los parámetros de las garantías adicionales deben ser 0 o 1 ya que su valor viene de un check box
-- que indicará 0.No contratada o 1.Contratada
-- Si el parámetro no viene informado se considera que la garantía no está contratada.
      v_cfallaseg1 := NVL(pcfallaseg1, 0);
      v_cfallaseg2 := NVL(pcfallaseg2, 0);
      v_caccaseg1 := NVL(pcaccaseg1, 0);
      v_caccaseg2 := NVL(pcaccaseg2, 0);

      IF v_cfallaseg1 NOT IN(0, 1)
         OR v_cfallaseg2 NOT IN(0, 1)
         OR v_caccaseg1 NOT IN(0, 1)
         OR v_caccaseg2 NOT IN(0, 1) THEN
         ocoderror := 107839;   -- Error en los parámetros de entrada
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error;
      END IF;

------------------------------------------------------------------------
-- Validamos las cláusulas de beneficiario
------------------------------------------------------------------------
      num_err := pac_val_comu.f_valida_beneficiario(psproduc, psclaben, ptclaben);

      IF num_err <> 0 THEN
         ocoderror := num_err;
         omsgerror := f_axis_literales(num_err, pcidioma_user);
         RAISE error;
      END IF;

------------------------------------------------------------------------
-- Validamos los asegurados
------------------------------------------------------------------------
      num_err := pac_ref_contrata_comu.f_valida_asegurados(psproduc, psperson1, v_fnacimi1,
                                                           v_csexo1, v_cpais1, psperson2,
                                                           v_fnacimi2, v_csexo2, v_cpais2,
                                                           v_fefecto, pcdomici1, pcdomici2, 1,
                                                           pcidioma_user, ocoderror, omsgerror);

      IF num_err IS NULL THEN
         RAISE error;
      END IF;

--------------------------------------------------------------------------
-- Validamos la cuenta bancaria del recibo
--------------------------------------------------------------------------
      num_err := pac_val_comu.f_valida_ccc(pcbancar_recibo, 1);

      IF num_err <> 0 THEN
         ocoderror := num_err;
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error;
      END IF;

--------------------------------------------------------------------------
-- Validamos los datos de gestión
--------------------------------------------------------------------------
-- Se busca la fecha de nacimiento del sperson1
      num_err := f_persodat2(psperson1, v_csexo1, v_fnacimi1, v_cestado1, v_csujeto1, v_cpais1);

      IF num_err <> 0 THEN
         ocoderror := num_err;
         omsgerror := f_axis_literales(num_err, pcidioma_user);
         RAISE error;
      END IF;

      num_err := pac_ref_contrata_comu.f_valida_gestion(psproduc, 1, v_fefecto, v_fnacimi1,
                                                        pcidioma, pcforpag, pnduraci, pfvencim,
                                                        pcbancar, pcidioma_user, ocoderror,
                                                        omsgerror);

      IF num_err IS NULL THEN
         RAISE error;
      END IF;

   --------------------------------------------------------------------------
   -- Validamos las primas y las garantias adicionales
   --------------------------------------------------------------------------
--   num_err := f_valida_primas_aho(psproduc, psperson1, v_fefecto, prima_inicial, prima_per, prevali, pcforpag, v_cfallaseg1, v_cfallaseg2,
--                v_caccaseg1, v_caccaseg2, pcagente, pcidioma_user, ocoderror, omsgerror);
      num_err := f_valida_garantias_aho(psproduc, psperson1, psperson2, v_fefecto,
                                        prima_inicial, prima_per, prevali, pcforpag,
                                        v_cfallaseg1, v_cfallaseg2, v_caccaseg1, v_caccaseg2,
                                        pcagente, pcidioma_user, ocoderror, omsgerror);

      IF num_err IS NULL THEN
         RAISE error;
      END IF;

-----------------------------------------------------------------------------
-- Comprobar si se puede realizar el cobro del recibo on-line
-- Si se puede, entonces : 1. se genera (graba) la poliza
--                         2. se emite la poliza
--                         3. se cobra el recibo en HOST
--                            Si todo OK Entonces
--                               . se cobra el recibo en SIS
--                            Sino
--                               . Salir y mostrar mensaje error
-- Si no se puede, entonces :
--   . Si la forma de pago es única, entonces : 1. se genera (graba) la poliza
--                                              2. se retiene la poliza
--   . Si la forma de pago es periodica, entonces : 1. se genera (graba) la poliza
--                                                  2. se emite la poliza
----------------------------------------------------------------------------
      --IF f_usuario_cobro(pcagente, psproduc) = 1 THEN   -- Sí se puede realizar el cobro On_Line
-----------------------------------------------------------------------------
-- Grabamos la propuesta y tarifamos
----------------------------------------------------------------------------
      num_err := pac_prod_aho.f_graba_propuesta_aho(psproduc, psperson1, pcdomici1, psperson2,
                                                    pcdomici2, pcagente, pcidioma, v_fefecto,
                                                    pnduraci, pfvencim, pcforpag, pcbancar,
                                                    psclaben, ptclaben, prima_inicial,
                                                    prima_per, prevali, v_cfallaseg1,
                                                    v_cfallaseg2, v_caccaseg1, v_caccaseg2,
                                                    v_sseguro_est, vcapgar, vcapfall,
                                                    vcapgar_per);

      IF num_err <> 0 THEN
         ocoderror := num_err;
         omsgerror := f_axis_literales(num_err, pcidioma_user);
         RAISE error;
      END IF;

-----------------------------------------------------------------------------
-- Se graba la poliza
-----------------------------------------------------------------------------
      num_err := pac_prod_comu.f_grabar_alta_poliza(v_sseguro_est, psseguro);

      IF num_err <> 0 THEN
         ocoderror := num_err;
         omsgerror := f_axis_literales(num_err, pcidioma_user);
         RAISE error;
      END IF;

-----------------------------------------------------------------------------
 -- Emitimos la propuesta
----------------------------------------------------------------------------
      num_err := pac_prod_comu.f_emite_propuesta(psseguro, vnpoliza, vncertif, v_nrecibo,
                                                 vnsolici);

      IF num_err <> 0 THEN
         ocoderror := num_err;
         omsgerror := f_axis_literales(num_err, pcidioma_user);
         RAISE error;
      END IF;

---------------------------------
-- Se cobra el recibo en HOST
---------------------------------
      num_err := f_dessproduc(psproduc, 2, pcidioma_user, v_descsproduc);

      IF num_err <> 0 THEN
         ocoderror := num_err;
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error;
      END IF;

      BEGIN
         SELECT itotalr
           INTO v_importe
           FROM vdetrecibos
          WHERE nrecibo = v_nrecibo;
      EXCEPTION
         WHEN OTHERS THEN
            ocoderror := 103936;
            -- Recibo no encontrado en la tabla VDETRECIBOS
            omsgerror := f_axis_literales(ocoderror, pcidioma_user);
            RAISE error;
      END;

      -- Bug 7854 y 8745 - 12/02/2009 - RSC - Adaptación iAxis a productos colectivos con certificados
      -- Bug 7854 y 8745 - 'ADMITE_CERTIFICADOS'
      BEGIN
         SELECT DECODE(productos.csubpro,
                       3, seguros.ncertif,
                       DECODE(NVL(f_parproductos_v(productos.sproduc, 'ADMITE_CERTIFICADOS'),
                                  0),
                              1, seguros.ncertif,
                              seguros.npoliza))
           INTO v_npoliza_ncertif
           FROM seguros, productos
          WHERE seguros.sproduc = productos.sproduc
            AND seguros.sseguro = psseguro;
      EXCEPTION
         WHEN OTHERS THEN
            ocoderror := 140897;   -- Error al buscar la poliza
            omsgerror := f_axis_literales(ocoderror, pcidioma_user);
            RAISE error;
      END;

      -- Se busca la cuenta donde se realizará el abono
      BEGIN
         SELECT cramo, cmodali, ctipseg, ccolect, cagente
           INTO v_cramo, v_cmodali, v_ctipseg, v_ccolect, v_cagente
           FROM seguros
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN OTHERS THEN
            ocoderror := 101919;
            -- Error al leer datos de la tabla SEGUROS
            omsgerror := f_axis_literales(ocoderror, pcidioma_user);
            RAISE error;
      END;

      v_ccobban := f_buscacobban(v_cramo, v_cmodali, v_ctipseg, v_ccolect, v_cagente,
                                 pcbancar_recibo, 1, num_err);

      IF v_ccobban IS NULL THEN
         ocoderror := num_err;
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error;
      END IF;

      num_err := f_descuentacob(v_ccobban, v_ncuenta);

      IF num_err <> 0 THEN
         ocoderror := num_err;
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error;
      END IF;

      v_recibo_cobrado := f_sg0carg(getuser, pterminal, LPAD(producto(1, psproduc), 8, '0'),
                                    f_empseguro(psseguro),   -- Codi empresa
                                    v_descsproduc, v_importe * 100, pfefecto, pcbancar_recibo,
                                    ff_buscanif(psperson1), LPAD(v_ncuenta, 20, 0), 1,   -- Tipus d'operació: 1.Alta
                                    f_nombre(psperson1, 1, v_cagente), v_npoliza_ncertif, NULL,
                                    ocoderror, omsgerror);

      -- Se ha podido cobrar el recibo en HOST
      IF v_recibo_cobrado THEN
---------------------------------
-- Se cobra el recibo en SIS
---------------------------------
--BUG 10069 - 15/06/2009 - JTS
         SELECT cdelega
           INTO v_cdelega
           FROM recibos
          WHERE nrecibo = v_nrecibo;

         num_err := pac_gestion_rec.f_cobro_recibo(f_empseguro(psseguro), v_nrecibo, v_fefecto,
                                                   NULL, NULL, v_ccobban, v_cdelega);

            --num_err := pac_prod_comu.f_cobro_recibo(v_nrecibo, pcbancar_recibo);
--Fi BUG 10069 - 15/06/2009 - JTS
         IF num_err <> 0 THEN
            ocoderror := num_err;
            omsgerror := f_axis_literales(num_err, pcidioma_user);
            p_tab_error
                (f_sysdate, getuser,
                 f_axis_literales(180848, pcidioma_user)
                 || ' (Pac_Ref_Contrata_Aho.f_genera_poliza_aho - Pac_Prod_Comu.f_cobro_recibo)',
                 NULL,
                 'Sseguro=' || psseguro || ', Error: '
                 || f_axis_literales(num_err, pcidioma_user),
                 'psproduc=' || psproduc || ', psperson1=' || psperson1 || ', pcdomici1='
                 || pcdomici1 || ', psperson2=' || psperson2 || ', pcdomici2=' || pcdomici2
                 || ', pcagente=' || pcagente || ', pcidioma=' || pcidioma || ', pfefecto='
                 || pfefecto || ', pnduraci=' || pnduraci || ', pfvencim=' || pfvencim
                 || ', pcforpag=' || pcforpag || ', pcbancar=' || pcbancar || ', psclaben='
                 || psclaben || ', ptclaben=' || ptclaben || ', prima_inicial='
                 || prima_inicial || ', prima_per=' || prima_per || ', prevali=' || prevali
                 || ', pcfallaseg1=' || pcfallaseg1 || ', pcfallaseg2=' || pcfallaseg2
                 || ', pcaccaseg1=' || pcaccaseg1 || ', pcaccaseg2=' || pcaccaseg2
                 || ', pcbancar_recibo=' || pcbancar_recibo || ', pterminal=' || pterminal
                 || ', pcidioma_user=' || pcidioma_user);
            RAISE error;
         END IF;

         vcsituac := 0;   -- Vigente
      ELSE   -- No se ha podido cobrar el recibo en HOST
         RAISE error;
      END IF;

           /* ELSE   -- No se puede realizar el cobro On_Line
               -- Si la forma de pago es única
               IF pcforpag = 0 THEN
      -----------------------------------------------------------------------------
      -- Grabamos la propuesta y tarifamos
      ----------------------------------------------------------------------------
                  num_err := pac_prod_aho.f_graba_propuesta_aho(psproduc, psperson1, pcdomici1,
                                                                psperson2, pcdomici2, pcagente,
                                                                pcidioma, v_fefecto, pnduraci,
                                                                pfvencim, pcforpag, pcbancar,
                                                                psclaben, ptclaben, prima_inicial,
                                                                prima_per, prevali, v_cfallaseg1,
                                                                v_cfallaseg2, v_caccaseg1,
                                                                v_caccaseg2, v_sseguro_est, vcapgar,
                                                                vcapfall, vcapgar_per);

                  IF num_err <> 0 THEN
                     ocoderror := num_err;
                     omsgerror := f_axis_literales(num_err, pcidioma_user);
                     RAISE error;
                  END IF;

      -----------------------------------------------------------------------------
      -- Se graba la poliza
      -----------------------------------------------------------------------------
                  num_err := pac_prod_comu.f_grabar_alta_poliza(v_sseguro_est, psseguro);

                  IF num_err <> 0 THEN
                     ocoderror := num_err;
                     omsgerror := f_axis_literales(num_err, pcidioma_user);
                     RAISE error;
                  END IF;

      -----------------------------------------------------------------------------
      -- Se retiene la póliza
      -----------------------------------------------------------------------------
                  num_err := pac_emision_mv.f_retener_poliza('SEG', psseguro, 1, 1, 4, 2, v_fefecto);

                  IF num_err <> 0 THEN
                     ocoderror := num_err;
                     omsgerror := f_axis_literales(num_err, pcidioma_user);
                     RAISE error;
                  END IF;

      --------------------------------------------------------------
      -- Se busca el nsolici de la poliza para devolver su valor
      -- El valor de pnpoliza y pncertif que se devuelve será Null
      --------------------------------------------------------------
                  SELECT nsolici
                    INTO vnsolici
                    FROM seguros
                   WHERE sseguro = psseguro;

                  vnpoliza := NULL;
                  vncertif := NULL;
                  vcsituac := 4;   -- Propuesta de Alta
               ELSE   -- Si la forma de pago es periódica
      -----------------------------------------------------------------------------
      -- Grabamos la propuesta y tarifamos
      ----------------------------------------------------------------------------
                  num_err := pac_prod_aho.f_graba_propuesta_aho(psproduc, psperson1, pcdomici1,
                                                                psperson2, pcdomici2, pcagente,
                                                                pcidioma, v_fefecto, pnduraci,
                                                                pfvencim, pcforpag, pcbancar,
                                                                psclaben, ptclaben, prima_inicial,
                                                                prima_per, prevali, v_cfallaseg1,
                                                                v_cfallaseg2, v_caccaseg1,
                                                                v_caccaseg2, v_sseguro_est, vcapgar,
                                                                vcapfall, vcapgar_per);

                  IF num_err <> 0 THEN
                     ocoderror := num_err;
                     omsgerror := f_axis_literales(num_err, pcidioma_user);
                     RAISE error;
                  END IF;

      -----------------------------------------------------------------------------
      -- Se graba la poliza
      -----------------------------------------------------------------------------
                  num_err := pac_prod_comu.f_grabar_alta_poliza(v_sseguro_est, psseguro);

                  IF num_err <> 0 THEN
                     ocoderror := num_err;
                     omsgerror := f_axis_literales(num_err, pcidioma_user);
                     RAISE error;
                  END IF;

      -----------------------------------------------------------------------------
      -- Emitimos la propuesta
       ----------------------------------------------------------------------------
                  num_err := pac_prod_comu.f_emite_propuesta(psseguro, vnpoliza, vncertif, v_nrecibo,
                                                             vnsolici);

                  IF num_err <> 0 THEN
                     ocoderror := num_err;
                     omsgerror := f_axis_literales(num_err, pcidioma_user);
                     RAISE error;
                  END IF;

                  vcsituac := 0;   -- Vigente
               END IF;
            END IF;*/

      -- Se guardan en los parámetros de salida pnpoliza y pncertif el nº de póliza y su nº de certificado
      pnpoliza := vnpoliza;
      pncertif := vncertif;
      pnsolici := vnsolici;
      pcsituac := vcsituac;
      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN error THEN
         ROLLBACK;
         -- Se borran las tablas EST
         pac_alctr126.borrar_tablas_est(v_sseguro_est);
         COMMIT;
         RETURN ocoderror;
      WHEN OTHERS THEN
         ocoderror := -999;
         omsgerror :=
                    'Pac_Ref_Contrata_Aho.f_genera_propuesta_aho: Error general en la función';
         ROLLBACK;
         -- Se borran las tablas EST
         pac_alctr126.borrar_tablas_est(v_sseguro_est);
         COMMIT;
         RETURN -999;
   END f_genera_poliza_aho;

   FUNCTION f_solicitud_traspaso(
      pcinout IN NUMBER,   -- 1.-Entrada 2.-Salida
      pcodpla_o IN NUMBER,
      pcodpla_d IN NUMBER,
      pcodaseg_o IN VARCHAR2,
      pcodaseg_d IN VARCHAR2,
      psseguro_o IN NUMBER,
      psseguro_d IN NUMBER,
      pnumppa IN VARCHAR2,   -- Número PPA traspasos externos
      pctiptras IN NUMBER,
      pctiptrassol IN NUMBER,   -- 1.-Import 2.-Percentatge 3.-Participacions
      pimport IN NUMBER,
      pnporcen IN NUMBER,
      pnparpla IN NUMBER,
      pctipcom IN NUMBER,
      poficina IN NUMBER,
      pterminal IN NUMBER,
      pcidioma_user IN NUMBER DEFAULT f_idiomauser,
      pobservaciones IN VARCHAR2,
      ostras OUT NUMBER,
      ocoderror OUT NUMBER,
      omsgerror OUT VARCHAR2)
      RETURN NUMBER IS
      err            EXCEPTION;
      v_count        NUMBER;
      v_intern       BOOLEAN := FALSE;
      amplerror      VARCHAR2(50);
   BEGIN
      IF NVL(pcinout, 0) NOT IN(1, 2) THEN
         ocoderror := 140039;
         RAISE err;
      END IF;

      IF pctiptras NOT IN(1, 2) THEN
         ocoderror := 140039;
         amplerror := ' TIP.TRAS';
         RAISE err;
      END IF;

      IF pctiptras = 2 THEN
         IF NVL(pctiptrassol, 0) NOT IN(1, 2, 3) THEN
            ocoderror := 140039;
            amplerror := ' TIP.TRAS.SOL';
            RAISE err;
         END IF;

         IF NVL(pctipcom, 0) NOT IN(1, 2, 3) THEN
            ocoderror := 140039;
            amplerror := ' COMPART.';
            RAISE err;
         END IF;

         IF pctiptrassol = 1
            AND NVL(pimport, 0) <= 0 THEN
            ocoderror := 140039;
            amplerror := ' IMPORT.';
            RAISE err;
         END IF;

         IF pctiptrassol = 2
            AND(NVL(pnporcen, 0) NOT BETWEEN 0 AND 100)
            AND NVL(pnporcen, 0) = 0 THEN
            ocoderror := 140039;
            amplerror := ' PORCEN.';
            RAISE err;
         END IF;

         IF pctiptrassol = 3
            AND NVL(pnparpla, 0) <= 0 THEN
            ocoderror := 140039;
            amplerror := ' PART.';
            RAISE err;
         END IF;
      END IF;

      IF poficina IS NULL THEN
         ocoderror := 180252;   -- Es obligatorio introducir la oficina
         RAISE err;
      END IF;

      IF pcinout = 1
         AND NVL(psseguro_d, 0) = 0 THEN
         ocoderror := 140039;
         amplerror := ' CONTR.DEST.';
         RAISE err;
      END IF;

      IF pcinout = 2
         AND NVL(psseguro_o, 0) = 0 THEN
         ocoderror := 140039;
         amplerror := ' CONTR.ORIG.';
         RAISE err;
      END IF;

      IF psseguro_o IS NOT NULL
         AND psseguro_d IS NOT NULL THEN
         v_intern := TRUE;

         IF pnumppa IS NOT NULL THEN
            ocoderror := 140039;
            amplerror := ' NUM.PPA';
            RAISE err;
         END IF;

         IF psseguro_o = psseguro_d THEN
            ocoderror := 140039;
            amplerror := ' CONT.ORIG. = CONT.DEST.';
            RAISE err;
         END IF;
      END IF;

      IF pcinout = 1 THEN
         IF (v_intern
             AND(psseguro_o IS NULL
                 OR psseguro_d IS NULL)) THEN
            ocoderror := 140039;
            amplerror := ' ORIG.';
            RAISE err;
         END IF;

         IF NOT v_intern THEN
            IF (pcodpla_o IS NULL
                AND(pcodaseg_o IS NULL
                    OR pnumppa IS NULL)) THEN
               ocoderror := 140039;
               amplerror := ' ORIG.';
               RAISE err;
            END IF;

            IF (pcodpla_o IS NOT NULL
                AND(pcodaseg_o IS NOT NULL
                    OR pnumppa IS NOT NULL)) THEN
               ocoderror := 140039;
               amplerror := ' ORIG.';
               RAISE err;
            END IF;

            IF (pcodpla_o IS NULL
                AND((pcodaseg_o IS NOT NULL
                     AND pnumppa IS NULL)
                    OR(pcodaseg_o IS NULL
                       AND pnumppa IS NOT NULL))) THEN
               ocoderror := 140039;
               amplerror := ' ORIG.';
               RAISE err;
            END IF;
         END IF;
      ELSE
         IF (v_intern
             AND(psseguro_o IS NULL
                 OR psseguro_d IS NULL)) THEN
            ocoderror := 140039;
            amplerror := ' DEST.';
            RAISE err;
         END IF;

         IF NOT v_intern THEN
            IF (pcodpla_d IS NULL
                AND(pcodaseg_d IS NULL
                    OR pnumppa IS NULL)) THEN
               ocoderror := 140039;
               amplerror := ' DEST.';
               RAISE err;
            END IF;

            IF (pcodpla_d IS NOT NULL
                AND(pcodaseg_d IS NOT NULL
                    OR pnumppa IS NOT NULL)) THEN
               ocoderror := 140039;
               amplerror := ' DEST.';
               RAISE err;
            END IF;

            IF (pcodpla_d IS NULL
                AND((pcodaseg_d IS NOT NULL
                     AND pnumppa IS NULL)
                    OR(pcodaseg_d IS NULL
                       AND pnumppa IS NOT NULL))) THEN
               ocoderror := 140039;
               amplerror := ' DEST.';
               RAISE err;
            END IF;
         END IF;
      END IF;

      IF v_intern THEN
         IF pac_val_aho.f_solicitud_traspaso(1, psseguro_d, ocoderror) IS NULL THEN
            RAISE err;
         END IF;

         IF pac_val_aho.f_solicitud_traspaso(2, psseguro_o, ocoderror) IS NULL THEN
            RAISE err;
         END IF;
      ELSE
         /*
            Només es poden fer sol·lictud d'entrada, les sol·licitud de sortida externes
            venen per fitxer 234.
         */
         IF pac_val_aho.f_solicitud_traspaso(pcinout, psseguro_d, ocoderror) IS NULL THEN
            RAISE err;
         END IF;
      END IF;

      IF pac_prod_aho.f_solicitud_traspaso
                                    (pcinout,   -- 1.-Entrada 2.-Salida
                                     pcodpla_o, pcodpla_d, pcodaseg_o, pcodaseg_d, psseguro_o,
                                     psseguro_d, pnumppa,   -- Número PPA traspasos externos
                                     pctiptras, pctiptrassol,   -- 1.-Import 2.-Percentatge 3.-Participacions
                                     pimport, pnporcen, pnparpla, pctipcom, v_intern,
                                     pobservaciones, ostras, ocoderror) IS NULL THEN
         RAISE err;
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN err THEN
         ROLLBACK;

         IF omsgerror IS NULL THEN
            omsgerror := f_axis_literales(ocoderror, pcidioma_user);

            IF amplerror IS NOT NULL THEN
               omsgerror := omsgerror || amplerror;
            END IF;
         END IF;

         RETURN NULL;
   END f_solicitud_traspaso;
END pac_ref_contrata_aho;

/

  GRANT EXECUTE ON "AXIS"."PAC_REF_CONTRATA_AHO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_REF_CONTRATA_AHO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_REF_CONTRATA_AHO" TO "PROGRAMADORESCSI";
