--------------------------------------------------------
--  DDL for Package Body PAC_REF_CONTRATA_COMU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_REF_CONTRATA_COMU" AS
/******************************************************************************
 NAME:       PAC_REF_CONTRATA_COMU
 PURPOSE:    Package público para contratación de pólizas. Tiene funciones comunes.

 REVISIONS:
 Ver        Date        Author           Description
 ---------  ----------  ---------------  ------------------------------------
 1.0        XX/XX/XXXX     XXX              1. Creación del package.
 6.0        23/02/2010     ICV              6. 0013069: CRE200 - Detalle de movimiento de pólizas en idioma incorrecto
 7.0        24/02/2010     JMF              7. 0012822 CEM - RT - Tratamiento fiscal rentas a 2 cabezas
******************************************************************************/
   FUNCTION f_valida_poliza_permite_supl(
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      pfefecto IN DATE,
      pcmotmov IN NUMBER,
      pcidioma_user IN NUMBER DEFAULT f_idiomauser,
      ocoderror OUT NUMBER,
      omsgerror OUT VARCHAR2)
      RETURN NUMBER IS
/********************************************************************************************************************************
   Función que valida si una póliza permite realizar un suplemento a una fecha determinada

   La función retornará:
      0.- Si todo es correcto
      NULL -- si hay error o no se cumple alguan de las validaciones. El código de error y el texto se informarán
                      en los parámetros oCODERROR y oMSGERROR
*****************************************************************************************************************************/
      num_err        NUMBER;
      error          EXCEPTION;
      v_sseguro      NUMBER;
      v_fefecto      DATE;
      -- RSC 19/05/2008
      xcmotmov       NUMBER;
   BEGIN
      -- La fecha de efecto debe estar truncada
      v_fefecto := TRUNC(pfefecto);

      IF pnpoliza IS NULL
         OR pncertif IS NULL THEN
         ocoderror := 140896;   -- Se tiene que informar la poliza
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error;
      ELSE
         v_sseguro := ff_buscasseguro(pnpoliza, pncertif);

         IF v_sseguro IS NULL THEN
            ocoderror := 101903;   -- Seguro no encontrado en la tabla SEGUROS
            omsgerror := f_axis_literales(ocoderror, pcidioma_user);
            RAISE error;
         END IF;
      END IF;

       -- RSC 19/05/2008 Tarea: 5844
      -- Se concluye que cuando se le pase a la función un 252 y la póliza esté
      -- reducida se llamará al suplemento con el cmotmov = 267
      IF (pcmotmov = 252
          AND pac_ctaseguro.f_esta_reducida(v_sseguro) = 1) THEN
         xcmotmov := 267;
      ELSE
         xcmotmov := pcmotmov;
      END IF;

      --BUG11376-XVM-13102009
      num_err := pk_suplementos.f_permite_suplementos(v_sseguro, v_fefecto, pcmotmov);

      IF num_err <> 0 THEN
         ocoderror := num_err;
         omsgerror := f_axis_literales(num_err, pcidioma_user);
         RAISE error;
      END IF;

      IF xcmotmov IS NOT NULL THEN
         num_err := pk_suplementos.f_permite_este_suplemento(v_sseguro, v_fefecto, xcmotmov);

         IF num_err <> 0 THEN
            ocoderror := num_err;
            omsgerror := f_axis_literales(num_err, pcidioma_user);
            RAISE error;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN error THEN
         RETURN NULL;
      WHEN OTHERS THEN
         ocoderror := -999;
         omsgerror :=
             'Pac_Ref_Contrata_Comu.f_valida_poliza_permite_supl: Error general en la función';
         p_tab_error(f_sysdate, f_user, 'Pac_Ref_Contrata_Comu.f_valida_poliza_permite_supl',
                     NULL,
                     'parametros: pnpoliza = ' || pnpoliza || ' pncertif =' || pncertif
                     || ' pfefecto = ' || pfefecto,
                     SQLERRM);
         RETURN NULL;
   END f_valida_poliza_permite_supl;

   FUNCTION f_valida_asegurados(
      psproduc IN NUMBER,
      psperson1 IN NUMBER,
      pfnacimi1 IN DATE,
      pcsexo1 IN NUMBER,
      pcpais1 IN NUMBER,
      psperson2 IN NUMBER,
      pfnacimi2 IN DATE,
      pcsexo2 IN NUMBER,
      pcpais2 IN NUMBER,
      pfefecto IN DATE,
      pcdomici1 IN NUMBER,
      pcdomici2 IN NUMBER,
      pvaldomici IN NUMBER,
      pcidioma_user IN NUMBER DEFAULT f_idiomauser,
      ocoderror OUT NUMBER,
      omsgerror OUT VARCHAR2)
      RETURN NUMBER IS
/********************************************************************************************************************************
   Función que valida si una persona cumple con las normes de subscripción definidas en el producto.
   Se llamará desde la pantalla de asegurados una vez introducidos todos los datos. En este caso se validarán más
   datos que en la lista: por ejmplo, que la direccióne sté informada
   Si se quiere validar sólo el primer asegurado los parámetros del segundo asegurado llegarán a null.
   Si se quiere validar sólo el segundo asegurado también se deben informar los parámetros del primer aseguroado,
    puesto  que hay normas de suscripción que son conjuntas y dependen de la 'combinación' de los dos
      asegurados (por ejemplo, la suma de edades, mezclar residentes y no residentes).

   El parámetro pvaldomici indicará si se debe validar (1) o no (0) el domicilio.

   La función retornará:
      0.- Si todo es correcto
      NULL -- si hay error o no se cumple alguan de las validaciones. El código de error y el texto se informarán
                      en los parámetros oCODERROR y oMSGERROR
*****************************************************************************************************************************/
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
      v_fefecto      DATE;
      num_err        NUMBER;
      error          EXCEPTION;
   BEGIN
      -- La fecha de efecto debe estar truncada
      v_fefecto := TRUNC(pfefecto);

---------------------------------------------------------------------------------------------------------
-- Validamos que si se le está pasando 2 asegurados y el producto NO es a 2_CABEZAS, muestre un mensaje
-- de error informando que el producto sólo puede tener 1 asegurado
---------------------------------------------------------------------------------------------------------
      IF psperson2 IS NOT NULL
         AND   -- segundo titular informado
            NVL(f_parproductos_v(psproduc, '2_CABEZAS'), 0) = 0 THEN   -- el producto NO es a 2_CABEZAS
         -- Mostrar mensaje de error (sólo puede haber 1 asegurado)
         ocoderror := 180748;   -- Este producto no puede tener más de un asegurado.
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error;
      END IF;

---------------------------------------------------------------------------------------------------------
-- Validamos que la persona no esté fallecida
---------------------------------------------------------------------------------------------------------
      IF psperson1 IS NOT NULL THEN
         num_err := pac_val_comu.f_valida_persona_fallecida(psperson1);

         IF num_err <> 0 THEN
            ocoderror := num_err;
            omsgerror := f_axis_literales(num_err, pcidioma_user);
            RAISE error;
         END IF;
      END IF;

      IF psperson2 IS NOT NULL THEN
         num_err := pac_val_comu.f_valida_persona_fallecida(psperson2);

         IF num_err <> 0 THEN
            ocoderror := num_err;
            omsgerror := f_axis_literales(num_err, pcidioma_user);
            RAISE error;
         END IF;
      END IF;

---------------------------------------------------------------------------------------------------------
-- Validamos que tengan el sperson informado
---------------------------------------------------------------------------------------------------------
      num_err := f_persodat2(psperson1, v_csexo1, v_fnacimi1, v_cestado1, v_csujeto1, v_cpais1);

      IF num_err <> 0 THEN
         ocoderror := num_err;
         omsgerror := f_axis_literales(num_err, pcidioma_user);
         RAISE error;
      END IF;

      IF psperson2 IS NOT NULL THEN
         num_err := f_persodat2(psperson2, v_csexo2, v_fnacimi2, v_cestado2, v_csujeto2,
                                v_cpais2);

         IF num_err <> 0 THEN
            ocoderror := num_err;
            omsgerror := f_axis_literales(num_err, pcidioma_user);
            RAISE error;
         END IF;
      END IF;

---------------------------------------------------------------------------------------------------------
-- Validamos que tengan la dirección informada
---------------------------------------------------------------------------------------------------------
      IF pvaldomici = 1 THEN   -- Sí que se debe validar el domicilio
         IF pcdomici1 IS NULL
            OR(v_fnacimi2 IS NOT NULL
               AND pcdomici2 IS NULL) THEN
            ocoderror := 101331;   -- falta la dirección del asegurado
            omsgerror := f_axis_literales(ocoderror, pcidioma_user);
            RAISE error;
         END IF;
      END IF;

---------------------------------------------------------------------------------------------------------------------------------------------
-- Validaremos que la persona tiene informada la fecha de nacimiento, el sexo y el pais de residencia
---------------------------------------------------------------------------------------------------------------------------------------------
      IF v_fnacimi1 IS NULL
         OR v_csexo1 IS NULL
         OR v_cpais1 IS NULL THEN
         ocoderror := 120308;   -- faltan datos del asegurado
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error;
      END IF;

      IF (v_fnacimi2 IS NOT NULL
          OR v_csexo2 IS NOT NULL
          OR v_cpais2 IS NOT NULL)
         AND(v_fnacimi2 IS NULL
             OR v_csexo2 IS NULL
             OR v_cpais2 IS NULL) THEN
         ocoderror := 120308;   -- faltan datos del asegurado
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error;
      END IF;

-------------------------------------------------------------------------------------------
-- Validaremos la edad
-------------------------------------------------------------------------------------------
      num_err := pac_val_comu.f_valida_edad_prod(psproduc, v_fefecto, v_fnacimi1, v_fnacimi2);

      IF num_err <> 0 THEN
         ocoderror := num_err;
         omsgerror := f_axis_literales(num_err, pcidioma_user);
         RAISE error;
      END IF;

--------------------------------------------------------------------------------------------
-- Validamos resientes - no residentes
---------------------------------------------------------------------------------------------
      num_err := pac_val_comu.f_valida_residentes(psproduc, v_cpais1, v_cpais2, NULL);

      IF num_err <> 0 THEN
         ocoderror := num_err;
         omsgerror := f_axis_literales(num_err, pcidioma_user);
         RAISE error;
      END IF;

--------------------------------------------------------------------------------------------
-- Validamos el tipo de documento de la persona
---------------------------------------------------------------------------------------------
      IF psperson1 IS NOT NULL THEN
         num_err := pac_personas.f_valida_tipo_sujeto(psperson1);

         IF num_err <> 0 THEN
            ocoderror := num_err;
            omsgerror := f_axis_literales(num_err, pcidioma_user);
            RAISE error;
         END IF;
      END IF;

      IF psperson2 IS NOT NULL THEN
         num_err := pac_personas.f_valida_tipo_sujeto(psperson2);

         IF num_err <> 0 THEN
            ocoderror := num_err;
            omsgerror := f_axis_literales(num_err, pcidioma_user);
            RAISE error;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN error THEN
         RETURN NULL;
      WHEN OTHERS THEN
         ocoderror := -999;
         omsgerror := 'Pac_Ref_Contrata_Comu.f_valida_asegurados: Error general en la función';
         p_tab_error(f_sysdate, f_user, 'Pac_Ref_Contrata_Comu.f_valida_asegurados', NULL,
                     'parametros: psproduc = ' || psproduc, SQLERRM);
         RETURN NULL;
   END f_valida_asegurados;

   FUNCTION f_valida_gestion(
      psproduc IN NUMBER,
      pctipban IN NUMBER,
      pfefecto IN DATE,
      pfnacimi IN DATE,
      pcidioma IN NUMBER,
      pcforpag IN NUMBER,
      pnduraci IN NUMBER,
      pfvencim IN DATE,
      pcbancar IN VARCHAR2,
      pcidioma_user IN NUMBER DEFAULT f_idiomauser,
      ocoderror OUT NUMBER,
      omsgerror OUT VARCHAR2)
      RETURN NUMBER IS
      /**********************************************************************************************************************************
         Función que valida los datos de gestión.

         La función retornará:
         0.- Si todo es correcto
         NULL -- si hay error o no se cumple alguan de las validaciones. El código de error y el texto se informarán
                         en los parámetros oCODERROR y oMSGERROR
      ********************************************************************************************************************************/
      vdias_a        NUMBER;
      vdias_d        NUMBER;
      num_err        NUMBER;
      error          EXCEPTION;
      v_cduraci      NUMBER;
      v_nduraci      NUMBER;
      v_fvencim      DATE;
      dummy          NUMBER;
      v_fefecto      DATE;
   BEGIN
      -- La fecha de efecto debe estar truncada
      v_fefecto := TRUNC(pfefecto);
--------------------------------------------------------------------------------------------------
-- Validamos la forma de pago
--------------------------------------------------------------------------------------------------
      num_err := pac_val_comu.f_valida_forpag(psproduc, pcforpag);

      IF num_err <> 0 THEN
         ocoderror := num_err;
         RAISE error;
      END IF;

--------------------------------------------------------------------------------------------------
--  Validamos la fecha de efecto de la póliza
--------------------------------------------------------------------------------------------------
      num_err := pac_val_comu.f_valida_fefecto(psproduc, v_fefecto);

      IF num_err <> 0 THEN
         ocoderror := num_err;
         RAISE error;
      END IF;

--------------------------------------------------------------------------------------------------
--  Validamos la fecha de vencimiento y la duración de la póliza
--------------------------------------------------------------------------------------------------
      num_err := pac_val_comu.f_valida_duracion(psproduc, pfnacimi, v_fefecto, pnduraci,
                                                pfvencim);

      IF num_err <> 0 THEN
         ocoderror := num_err;
         RAISE error;
      END IF;

--------------------------------------------------------------------------------------------------
--  Validamos el idioma
--------------------------------------------------------------------------------------------------
      num_err := pac_val_comu.f_valida_idioma(pcidioma);

      IF num_err <> 0 THEN
         ocoderror := num_err;
         RAISE error;
      END IF;

--------------------------------------------------------------------------------------------------
--  Validamos la cuenta
--------------------------------------------------------------------------------------------------
      num_err := pac_val_comu.f_valida_ccc(pcbancar, pctipban);

      IF num_err <> 0 THEN
         ocoderror := num_err;
         RAISE error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN error THEN
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RETURN NULL;
      WHEN OTHERS THEN
         ocoderror := -999;
         omsgerror := 'Pac_Ref_Contrata_Comu.f_valida_gestion: Error general en la función';
         p_tab_error(f_sysdate, f_user, 'Pac_Ref_Contrata_Comu.f_valida_gestion', NULL,
                     'parametros: psproduc = ' || psproduc || '  pfefecto = ' || pfefecto,
                     SQLERRM);
         RETURN NULL;
   END f_valida_gestion;

   FUNCTION f_suplemento_ccc(
      pnpoliza IN NUMBER,
      pctipban IN NUMBER,
      pncertif IN NUMBER,
      pfefecto IN DATE,
      pcbancar IN VARCHAR2,
      poficina IN VARCHAR2,
      pterminal IN VARCHAR2,
      pcidioma_user IN NUMBER DEFAULT f_idiomauser,
      ocoderror OUT NUMBER,
      omsgerror OUT VARCHAR2)
      RETURN NUMBER IS
      /********************************************************************************************************************************
         Función que graba el suplemento de cambio de cuenta bancaria.

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
      v_cont         NUMBER;
      vcmotmov       NUMBER;
      v_fefecto      DATE;
      error          EXCEPTION;
      error_fin_supl EXCEPTION;
   BEGIN
      -- Código del motivo de movimiento (suplemento)
      vcmotmov := 286;
      -- La fecha de efecto debe estar truncada
      v_fefecto := TRUNC(pfefecto);
--------------------------------------------------------------------------
-- Validar que la póliza permite el suplemento
--------------------------------------------------------------------------
      num_err := f_valida_poliza_permite_supl(pnpoliza, pncertif, v_fefecto, vcmotmov,
                                              pcidioma_user, ocoderror, omsgerror);

      IF num_err IS NULL THEN
         RAISE error;
      END IF;

--------------------------------------------------------------------------
-- Validamos que estén informados los datos del suplemento
--------------------------------------------------------------------------
      IF pnpoliza IS NULL
         OR pncertif IS NULL THEN
         ocoderror := 140896;   -- Se tiene que informar la poliza
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error;
      END IF;

      IF v_fefecto IS NULL THEN
         ocoderror := 120077;   -- Falta informar la fecha efecto
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error;
      END IF;

      IF pcbancar IS NULL THEN
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
      num_err := pac_val_comu.f_valida_ccc(pcbancar, pctipban);

      IF num_err <> 0 THEN
         ocoderror := num_err;
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error;
      END IF;

-------------------------------------------------------------------------------------------
-- Se traspasan los datos a las tablas EST y se dejan preparadas para hacer el suplemento
-------------------------------------------------------------------------------------------
-- Todas las funciones a partir de esta deben tener RAISE error_fin_supl
      v_sseguro := ff_buscasseguro(pnpoliza, pncertif);
      num_err := pk_suplementos.f_inicializar_suplemento(v_sseguro, 'SUPLEMENTO', v_fefecto,
                                                         'BBDD', '*', vcmotmov, v_est_sseguro,
                                                         v_nmovimi);

      IF num_err <> 0 THEN
         ocoderror := num_err;
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error_fin_supl;
      END IF;

-------------------------------------------------------------------------------------------
-- Se realiza la modificación de la cuenta bancaria en las tablas EST
-------------------------------------------------------------------------------------------
      num_err := pac_prod_comu.f_cambio_ccc(v_est_sseguro, pcbancar);

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
       WHERE sseguro = v_sseguro;

      --Ini Bug.: 13069 - 23/02/2010 - ICV
      num_err := pk_suplementos.f_validar_cambios(f_user, v_est_sseguro, v_nmovimi, v_sproduc,
                                                  'BBDD', 'SUPLEMENTO',
                                                  pac_md_common.f_get_cxtidioma);

      --Fin Bug.: 13069
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
         omsgerror := 'Pac_Ref_Contrata_Comu.f_suplemento_ccc: Error general en la función';
         ROLLBACK;
         p_tab_error(f_sysdate, f_user, 'Pac_Ref_Contrata_Comu.f_suplemento_ccc', NULL,
                     'parametros: pnpoliza = ' || pnpoliza || ' pncertif =' || pncertif
                     || ' pcbancar = ' || pcbancar || ' poficina =' || poficina
                     || ' pterminal =' || pterminal,
                     SQLERRM);
         num_err := pk_suplementos.f_final_suplemento(v_est_sseguro, v_nmovimi, v_sseguro);
         COMMIT;
         RETURN NULL;
   END f_suplemento_ccc;

   FUNCTION f_suplemento_beneficiario(
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      pfefecto IN DATE,
      psclaben IN NUMBER,
      ptclaben IN VARCHAR2,
      poficina IN VARCHAR2,
      pterminal IN VARCHAR2,
      pcidioma_user IN NUMBER DEFAULT f_idiomauser,
      ocoderror OUT NUMBER,
      omsgerror OUT VARCHAR2)
      RETURN NUMBER IS
      /********************************************************************************************************************************
         Función que graba el suplemento de cambio de beneficiario.

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
      v_cont         NUMBER;
      vcmotmov       NUMBER;
      v_fefecto      DATE;
      error          EXCEPTION;
      error_fin_supl EXCEPTION;
   BEGIN
      -- Código del motivo de movimiento (suplemento)
      vcmotmov := 213;
      -- La fecha de efecto debe estar truncada
      v_fefecto := TRUNC(pfefecto);
--------------------------------------------------------------------------
-- Validar que la póliza permite el suplemento
--------------------------------------------------------------------------
      num_err := f_valida_poliza_permite_supl(pnpoliza, pncertif, v_fefecto, vcmotmov,
                                              pcidioma_user, ocoderror, omsgerror);

      IF num_err IS NULL THEN
         RAISE error;
      END IF;

--------------------------------------------------------------------------
-- Validamos que estén informados los datos del suplemento
--------------------------------------------------------------------------
      IF pnpoliza IS NULL
         OR pncertif IS NULL THEN
         ocoderror := 140896;   -- Se tiene que informar la poliza
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error;
      END IF;

      IF v_fefecto IS NULL THEN
         ocoderror := 120077;   -- Falta informar la fecha efecto
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error;
      END IF;

      IF psclaben IS NULL
         AND ptclaben IS NULL THEN
         ocoderror := 101817;   -- Quedan cláusulas de beneficiarios por informar.
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
      v_sseguro := ff_buscasseguro(pnpoliza, pncertif);
      num_err := pk_suplementos.f_inicializar_suplemento(v_sseguro, 'SUPLEMENTO', v_fefecto,
                                                         'BBDD', '*', vcmotmov, v_est_sseguro,
                                                         v_nmovimi);

      IF num_err <> 0 THEN
         ocoderror := num_err;
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error_fin_supl;
      END IF;

-------------------------------------------------------------------------------------------
-- Se realiza la modificación de la clausula de beneficiario en las tablas EST
-------------------------------------------------------------------------------------------
      num_err := pac_prod_comu.f_cambio_beneficiario(v_est_sseguro, v_nmovimi, 1, psclaben,
                                                     ptclaben);

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
       WHERE sseguro = v_sseguro;

      --Ini Bug.: 13069 - 23/02/2010 - ICV
      num_err := pk_suplementos.f_validar_cambios(f_user, v_est_sseguro, v_nmovimi, v_sproduc,
                                                  'BBDD', 'SUPLEMENTO',
                                                  pac_md_common.f_get_cxtidioma);

      --Fin Bug.: 13069
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
                'Pac_Ref_Contrata_Comu.f_suplemento_beneficiario: Error general en la función';
         ROLLBACK;
         p_tab_error(f_sysdate, f_user, 'Pac_Ref_Contrata_Comu.f_suplemento_beneficiario',
                     NULL,
                     'parametros: pnpoliza = ' || pnpoliza || ' pncertif =' || pncertif
                     || ' psclaben = ' || psclaben || ' ptclaben =' || ptclaben
                     || ' poficina =' || poficina || ' pterminal =' || pterminal,
                     SQLERRM);
         num_err := pk_suplementos.f_final_suplemento(v_est_sseguro, v_nmovimi, v_sseguro);
         COMMIT;
         RETURN NULL;
   END f_suplemento_beneficiario;

   FUNCTION f_suplemento_oficina(
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      pfefecto IN DATE,
      pcagente IN NUMBER,
      poficina IN VARCHAR2,
      pterminal IN VARCHAR2,
      pcidioma_user IN NUMBER DEFAULT f_idiomauser,
      ocoderror OUT NUMBER,
      omsgerror OUT VARCHAR2)
      RETURN NUMBER IS
      /********************************************************************************************************************************
         Función que graba el suplemento de cambio de oficina.

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
      v_cont         NUMBER;
      vcmotmov       NUMBER;
      v_fefecto      DATE;
      error          EXCEPTION;
      error_fin_supl EXCEPTION;
   BEGIN
      -- Código del motivo de movimiento (suplemento)
      vcmotmov := 225;
      -- La fecha de efecto debe estar truncada
      v_fefecto := TRUNC(pfefecto);
--------------------------------------------------------------------------
-- Validar que la póliza permite el suplemento
--------------------------------------------------------------------------
      num_err := f_valida_poliza_permite_supl(pnpoliza, pncertif, v_fefecto, vcmotmov,
                                              pcidioma_user, ocoderror, omsgerror);

      IF num_err IS NULL THEN
         RAISE error;
      END IF;

--------------------------------------------------------------------------
-- Validamos que estén informados los datos del suplemento
--------------------------------------------------------------------------
      IF pnpoliza IS NULL
         OR pncertif IS NULL THEN
         ocoderror := 140896;   -- Se tiene que informar la poliza
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error;
      END IF;

      IF v_fefecto IS NULL THEN
         ocoderror := 120077;   -- Falta informar la fecha efecto
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error;
      END IF;

      IF pcagente IS NULL THEN
         ocoderror := 101076;   -- Es obligatorio introducir el código del agente.
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
      v_sseguro := ff_buscasseguro(pnpoliza, pncertif);
      num_err := pk_suplementos.f_inicializar_suplemento(v_sseguro, 'SUPLEMENTO', v_fefecto,
                                                         'BBDD', '*', vcmotmov, v_est_sseguro,
                                                         v_nmovimi);

      IF num_err <> 0 THEN
         ocoderror := num_err;
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error_fin_supl;
      END IF;

-------------------------------------------------------------------------------------------
-- Se realiza la modificación del código del agente (oficina) en las tablas EST
-------------------------------------------------------------------------------------------
      num_err := pac_prod_comu.f_cambio_oficina(v_est_sseguro, pcagente);

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
       WHERE sseguro = v_sseguro;

      --Ini Bug.: 13069 - 23/02/2010 - ICV
      num_err := pk_suplementos.f_validar_cambios(f_user, v_est_sseguro, v_nmovimi, v_sproduc,
                                                  'BBDD', 'SUPLEMENTO',
                                                  pac_md_common.f_get_cxtidioma);

      --Fin Bug.: 13069
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
                     'Pac_Ref_Contrata_Comu.f_suplemento_oficina: Error general en la función';
         p_tab_error(f_sysdate, f_user, 'Pac_Ref_Contrata_Comu.f_suplemento_oficina', NULL,
                     'parametros: pnpoliza = ' || pnpoliza || ' pncertif =' || pncertif
                     || ' pcagente = ' || pcagente || ' poficina =' || poficina
                     || ' pterminal =' || pterminal,
                     SQLERRM);
         num_err := pk_suplementos.f_final_suplemento(v_est_sseguro, v_nmovimi, v_sseguro);
         COMMIT;
         RETURN NULL;
   END f_suplemento_oficina;

   FUNCTION f_suplemento_domicilio(
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      pfefecto IN DATE,
      pcdomici IN NUMBER,
      poficina IN VARCHAR2,
      pterminal IN VARCHAR2,
      pcidioma_user IN NUMBER DEFAULT f_idiomauser,
      ocoderror OUT NUMBER,
      omsgerror OUT VARCHAR2)
      RETURN NUMBER IS
      /********************************************************************************************************************************
         Función que graba el suplemento de cambio de domicilio.

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
      v_cont         NUMBER;
      vcmotmov       NUMBER;
      v_fefecto      DATE;
      error          EXCEPTION;
      error_fin_supl EXCEPTION;
   BEGIN
      -- Código del motivo de movimiento (suplemento)
      vcmotmov := 672;
      -- La fecha de efecto debe estar truncada
      v_fefecto := TRUNC(pfefecto);
--------------------------------------------------------------------------
-- Validar que la póliza permite el suplemento
--------------------------------------------------------------------------
      num_err := f_valida_poliza_permite_supl(pnpoliza, pncertif, v_fefecto, vcmotmov,
                                              pcidioma_user, ocoderror, omsgerror);

      IF num_err IS NULL THEN
         RAISE error;
      END IF;

--------------------------------------------------------------------------
-- Validamos que estén informados los datos del suplemento
--------------------------------------------------------------------------
      IF pnpoliza IS NULL
         OR pncertif IS NULL THEN
         ocoderror := 140896;   -- Se tiene que informar la poliza
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error;
      END IF;

      IF v_fefecto IS NULL THEN
         ocoderror := 120077;   -- Falta informar la fecha efecto
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error;
      END IF;

      IF pcdomici IS NULL THEN
         ocoderror := 140083;   -- Es obligatorio introducir el domicilio
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
      v_sseguro := ff_buscasseguro(pnpoliza, pncertif);
      num_err := pk_suplementos.f_inicializar_suplemento(v_sseguro, 'SUPLEMENTO', v_fefecto,
                                                         'BBDD', '*', vcmotmov, v_est_sseguro,
                                                         v_nmovimi);

      IF num_err <> 0 THEN
         ocoderror := num_err;
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error_fin_supl;
      END IF;

-------------------------------------------------------------------------------------------
-- Se realiza la modificación del domicilio en las tablas EST
-------------------------------------------------------------------------------------------
      num_err := pac_prod_comu.f_cambio_domicilio(v_est_sseguro, 1, pcdomici);

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
       WHERE sseguro = v_sseguro;

      --Ini Bug.: 13069 - 23/02/2010 - ICV
      num_err := pk_suplementos.f_validar_cambios(f_user, v_est_sseguro, v_nmovimi, v_sproduc,
                                                  'BBDD', 'SUPLEMENTO',
                                                  pac_md_common.f_get_cxtidioma);

      --Fin Bug.: 13069
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
                   'Pac_Ref_Contrata_Comu.f_suplemento_domicilio: Error general en la función';
         ROLLBACK;
         p_tab_error(f_sysdate, f_user, 'Pac_Ref_Contrata_Comu.f_suplemento_domicilio', NULL,
                     'parametros: pnpoliza = ' || pnpoliza || ' pncertif =' || pncertif
                     || ' pcdomici = ' || pcdomici || ' poficina =' || poficina
                     || ' pterminal =' || pterminal,
                     SQLERRM);
         num_err := pk_suplementos.f_final_suplemento(v_est_sseguro, v_nmovimi, v_sseguro);
         COMMIT;
         RETURN NULL;
   END f_suplemento_domicilio;

   FUNCTION f_suplemento_idioma(
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      pfefecto IN DATE,
      pcidioma IN NUMBER,
      poficina IN VARCHAR2,
      pterminal IN VARCHAR2,
      pcidioma_user IN NUMBER DEFAULT f_idiomauser,
      ocoderror OUT NUMBER,
      omsgerror OUT VARCHAR2)
      RETURN NUMBER IS
      /********************************************************************************************************************************
         Función que graba el suplemento de cambio de idioma.

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
      v_cont         NUMBER;
      vcmotmov       NUMBER;
      v_fefecto      DATE;
      error          EXCEPTION;
      error_fin_supl EXCEPTION;
   BEGIN
      -- Código del motivo de movimiento (suplemento)
      vcmotmov := 667;
      -- La fecha de efecto debe estar truncada
      v_fefecto := TRUNC(pfefecto);
--------------------------------------------------------------------------
-- Validar que la póliza permite el suplemento
--------------------------------------------------------------------------
      num_err := f_valida_poliza_permite_supl(pnpoliza, pncertif, v_fefecto, vcmotmov,
                                              pcidioma_user, ocoderror, omsgerror);

      IF num_err IS NULL THEN
         RAISE error;
      END IF;

--------------------------------------------------------------------------
-- Validamos que estén informados los datos del suplemento
--------------------------------------------------------------------------
      IF pnpoliza IS NULL
         OR pncertif IS NULL THEN
         ocoderror := 140896;   -- Se tiene que informar la poliza
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error;
      END IF;

      IF v_fefecto IS NULL THEN
         ocoderror := 120077;   -- Falta informar la fecha efecto
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error;
      END IF;

      IF pcidioma IS NULL THEN
         ocoderror := 102242;   -- Idioma obligatorio
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
      v_sseguro := ff_buscasseguro(pnpoliza, pncertif);
      num_err := pk_suplementos.f_inicializar_suplemento(v_sseguro, 'SUPLEMENTO', v_fefecto,
                                                         'BBDD', '*', vcmotmov, v_est_sseguro,
                                                         v_nmovimi);

      IF num_err <> 0 THEN
         ocoderror := num_err;
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error_fin_supl;
      END IF;

-------------------------------------------------------------------------------------------
-- Se realiza la modificación del domicilio en las tablas EST
-------------------------------------------------------------------------------------------
      num_err := pac_prod_comu.f_cambio_idioma(v_est_sseguro, pcidioma);

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
       WHERE sseguro = v_sseguro;

      --Ini Bug.: 13069 - 23/02/2010 - ICV
      num_err := pk_suplementos.f_validar_cambios(f_user, v_est_sseguro, v_nmovimi, v_sproduc,
                                                  'BBDD', 'SUPLEMENTO',
                                                  pac_md_common.f_get_cxtidioma);

      --Fin Bug.: 13069
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
         omsgerror := 'Pac_Ref_Contrata_Comu.f_suplemento_idioma: Error general en la función';
         ROLLBACK;
         p_tab_error(f_sysdate, f_user, 'Pac_Ref_Contrata_Comu.f_suplemento_idioma', NULL,
                     'parametros: pnpoliza = ' || pnpoliza || ' pncertif =' || pncertif
                     || ' pcidioma = ' || pcidioma || ' poficina =' || poficina
                     || ' pterminal =' || pterminal,
                     SQLERRM);
         num_err := pk_suplementos.f_final_suplemento(v_est_sseguro, v_nmovimi, v_sseguro);
         COMMIT;
         RETURN NULL;
   END f_suplemento_idioma;

   FUNCTION f_suplemento_fall_asegurado(
      psseguro IN NUMBER,
      pfefecto IN DATE,
      psperson IN NUMBER,
      pffallec IN DATE,
      poficina IN VARCHAR2,
      pterminal IN VARCHAR2,
      pcidioma_user IN NUMBER DEFAULT f_idiomauser,
      pcommit IN NUMBER DEFAULT 1,
      ocoderror OUT NUMBER,
      omsgerror OUT VARCHAR2)
      RETURN NUMBER IS
      /********************************************************************************************************************************
         Función que graba el suplemento de Fallecimiento del 1er titular en productos a 2 cabezas
         Parámetros de entrada: . psperson = Código de la persona fallecida
                                . pffallec = Fecha de fallecimiento
                                . pcommit = Indica si se debe lanzar o no el commit y el rollback
                                            Si pcommit = 0 --> No se debe lanzar ni el commit ni el rollback
                                            Si pcommit = 1 --> Sí se debe lanzar el commit y el rollback;

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
      -- Bug 0012822 - 24/02/2010 - JMF
      n_pas          NUMBER(4) := 0;
      v_obj          VARCHAR2(500) := 'Pac_Ref_Contrata_Comu.f_suplemento_fall_asegurado';
      v_par          VARCHAR2(500)
         := 'parametros: psseguro = ' || psseguro || ' pfefecto =' || pfefecto
            || ' psperson = ' || psperson || ' pffallec = ' || pffallec || ' poficina ='
            || poficina || ' pterminal =' || pterminal || ' pcidioma_user =' || pcidioma_user
            || '  pcommit = ' || pcommit;
   BEGIN
      n_pas := 1;
      -- Código del motivo de movimiento (suplemento)
      vcmotmov := 265;
      -- La fecha de efecto debe estar truncada
      v_fefecto := TRUNC(pfefecto);
--------------------------------------------------------------------------
-- Validar que la póliza permite el suplemento
--------------------------------------------------------------------------
      n_pas := 2;
      num_err := f_buscapoliza(psseguro, v_npoliza, v_ncertif);

      IF num_err <> 0 THEN
         ocoderror := num_err;
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error;
      END IF;

      n_pas := 3;
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

      IF psperson IS NULL THEN
         ocoderror := 111066;   -- Es obligatorio informar la persona
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error;
      END IF;

      IF pffallec IS NULL THEN
         ocoderror := 180472;   -- Es obligatorio informar la fecha de fallecimiento
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
*/    -------------------------------------------------------------------------------------------
      -- Se traspasan los datos a las tablas EST y se dejan preparadas para hacer el suplemento
      -------------------------------------------------------------------------------------------
      -- Todas las funciones a partir de esta deben tener RAISE error_fin_supl
      n_pas := 10;
      num_err := pk_suplementos.f_inicializar_suplemento(psseguro, 'SUPLEMENTO', v_fefecto,
                                                         'BBDD', '*', vcmotmov, v_est_sseguro,
                                                         v_nmovimi);

      IF num_err <> 0 THEN
         ocoderror := num_err;
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error_fin_supl;
      END IF;

      -- Bug 0012822 - 24/02/2010 - JMF
      n_pas := 11;

      SELECT sperson
        INTO v_sperson
        FROM estassegurats
       WHERE sseguro = v_est_sseguro
         AND norden = (SELECT norden
                         FROM asegurados b
                        WHERE sseguro = psseguro
                          AND sperson = psperson);

------------------------------------------------------------------------------------------------------------
-- Se realiza la baja en asegurados en las tablas EST
------------------------------------------------------------------------------------------------------------
      n_pas := 12;
      num_err := pac_prod_comu.f_cambio_fall_asegurado(v_est_sseguro, v_sperson, pffallec);

      IF num_err <> 0 THEN
         ocoderror := num_err;
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error_fin_supl;
      END IF;

-------------------------------------------------------------------------------------------
-- Se valida que se haya realizado algún cambio
-------------------------------------------------------------------------------------------
      n_pas := 13;

      SELECT sproduc
        INTO v_sproduc
        FROM seguros
       WHERE sseguro = psseguro;

      --Ini Bug.: 13069 - 23/02/2010 - ICV
      n_pas := 14;
      num_err := pk_suplementos.f_validar_cambios(f_user, v_est_sseguro, v_nmovimi, v_sproduc,
                                                  'BBDD', 'SUPLEMENTO',
                                                  pac_md_common.f_get_cxtidioma);

      --Fin Bug.: 13069
      IF num_err <> 0 THEN
         ocoderror := num_err;
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error_fin_supl;
      END IF;

      BEGIN
         -- primero hay que validar que hay regisros en detmovseguro
         n_pas := 15;

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
      n_pas := 16;
      num_err := pk_suplementos.f_grabar_suplemento_poliza(v_est_sseguro, v_nmovimi);

      IF num_err <> 0 THEN
         ocoderror := num_err;
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error_fin_supl;
      END IF;

-------------------------------------------------------------------------------------------
-- Se emite el suplemento
-------------------------------------------------------------------------------------------
      n_pas := 17;
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
      n_pas := 18;
      num_err := pac_avisos.f_accion(1, psseguro, 1, pcidioma_user, 'REAL', vcmotmov, 5,
                                     poficina, pterminal, v_nmovimi);

      IF num_err <> 0 THEN
         ocoderror := num_err;
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error_fin_supl;
      END IF;

      IF pcommit = 1 THEN
         n_pas := 19;
         COMMIT;
      END IF;

      n_pas := 20;
      RETURN 0;
   EXCEPTION
      WHEN error THEN
         IF pcommit = 1 THEN
            ROLLBACK;
         END IF;

         RETURN NULL;
      WHEN error_fin_supl THEN
         IF pcommit = 1 THEN
            ROLLBACK;
         END IF;

         num_err := pk_suplementos.f_final_suplemento(v_est_sseguro, v_nmovimi, psseguro);
         --Commit;
         RETURN NULL;
      WHEN OTHERS THEN
         ocoderror := -999;
         omsgerror :=
              'Pac_Ref_Contrata_Comu.f_suplemento_fall_asegurado: Error general en la función';

         IF pcommit = 1 THEN
            ROLLBACK;
         END IF;

         p_tab_error(f_sysdate, f_user, v_obj, n_pas, v_par, SQLERRM);
         num_err := pk_suplementos.f_final_suplemento(v_est_sseguro, v_nmovimi, psseguro);
         --Commit;
         RETURN NULL;
   END f_suplemento_fall_asegurado;

    /**********************************************************************************************
    Anul·la una pòlissa a l'efecte des de TF
    Paràmetres entrada:
       psSeguro : Identificador de l'assegurança   (obligatori)
       pcIdioma : Idioma de l'usuari               (obligatori)
       pOficina : Oficina                          (obligatori)
       pTerminal: Terminal                         (obligatori)
       Pcidioma_user : Idioma de l'usuari
    Torna :
       0 si tot és correcte,
       altrament NULL i informa els camps OCodeError i OMsgError
   **********************************************************************************************/
   FUNCTION f_anula_poliza_al_efecto(
      psseguro IN seguros.sseguro%TYPE,
      pcidioma IN idiomas.cidioma%TYPE,
      poficina IN log_correo.coficina%TYPE,
      pterminal IN log_correo.cterm%TYPE,
      pcidioma_user IN NUMBER DEFAULT f_idiomauser,
      ocoderror OUT literales.slitera%TYPE,
      omsgerror OUT literales.tlitera%TYPE)
      RETURN NUMBER IS
      v_existe       BOOLEAN;
   BEGIN
      ocoderror := 0;
      omsgerror := NULL;

      -- Validar que els camps obligatoris estan informats
      IF pac_util.validar(psseguro IS NOT NULL, 111995, pcidioma_user, ocoderror, omsgerror) THEN   -- Se tiene que informar la poliza
         IF pac_util.validar(poficina IS NOT NULL, 180252, pcidioma_user, ocoderror,
                             omsgerror) THEN   -- Es obligatorio introducir la oficina
            IF pac_util.validar(pterminal IS NOT NULL, 180253, pcidioma_user, ocoderror,
                                omsgerror) THEN   -- Es obligatorio introducir el terminal
               -- Recuperem dades de la pòlissa
               v_existe := FALSE;

               FOR rseguros IN (SELECT sseguro, sproduc, fefecto
                                  FROM seguros
                                 WHERE sseguro = psseguro) LOOP
                  v_existe := TRUE;

                  -- Validar que la pòlissa està en situació de poder ser anulada (retorni un 0), enviant com data d'anul·lació la data d'efecte
                  IF pac_util.validar
                              (pac_anulacion.f_valida_permite_anular_poliza(psseguro,
                                                                            rseguros.fefecto),
                               pcidioma_user, ocoderror, omsgerror) THEN   -- Utilitzem com error el que hagi retornat la funció
                     --  Anular la pòlissa. Si torna un valor diferent de 0 és un error
                     IF pac_util.validar
                           (pac_anulacion.f_anulacion_poliza
                                             (rseguros.sseguro, 306,   -- cmotmov

                                               -- BUG 18423 - I - 27/12/2011 - JLB - LCOL000 - Multimoneda
                                              --f_parinstalacion_n('MONEDAINST'),   -- pcmoneda,
                                              pac_monedas.f_moneda_producto(rseguros.sproduc),

                                              -- BUG 18423 - F - 27/12/2011 - JLB - LCOL000 - Multimoneda
                                              rseguros.fefecto,   -- pfanulac
                                              1,   -- pcextorn
                                              1,   -- pcanular_rec : Anular rebuts pendents
                                              poficina,   -- pcagente
                                              NULL,   -- rpend
                                              NULL,   -- rcob
                                              rseguros.sproduc, NULL   -- pcnotibaja
                                                                    ),
                            pcidioma_user, ocoderror, omsgerror) THEN
                        -- Enviar un correu a l'oficina
                        IF pac_util.validar
                              (pac_avisos.f_accion
                                                 (1,   -- pscorreo
                                                  rseguros.sseguro, 1,   -- pnriesgo (només n'hi hauria d'haver un)
                                                  pcidioma, 'REAL',   -- paccion
                                                  306,   -- pcmotmov
                                                  5,   -- pcpregun
                                                  poficina, pterminal,
                                                  0   -- pnmovimi => agafar el darrer NMovimi
                                                   ),
                               pcidioma_user, ocoderror, omsgerror) THEN
                           NULL;
                        END IF;
                     END IF;
                  END IF;

                  EXIT;   -- Només un registre
               END LOOP;

               -- Si no existeix la pòlissa també dóna un error
               IF ocoderror = 0 THEN
                  IF pac_util.validar(v_existe, 100500, pcidioma_user, ocoderror, omsgerror) THEN   -- Pòlissa inexistent
                     NULL;
                  END IF;
               END IF;
            END IF;
         END IF;
      END IF;

      IF ocoderror <> 0 THEN
         ROLLBACK;
         RETURN NULL;
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_contrata_comu.f_anula_poliza_al_efecto', 1,
                     'psseguro:' || psseguro || 'pcidioma:' || pcidioma || ' poficina:'
                     || poficina || ' pterminal:' || pterminal || ' pcidioma_user:'
                     || pcidioma_user,
                     SQLERRM);
         ocoderror := 140999;
         omsgerror := f_axis_literales(ocoderror, f_idiomauser);
         ROLLBACK;
         RETURN NULL;
   END;

   -- RSC 25/03/2008 RESCATE PARCIAL -------------------------------------------
   FUNCTION f_suplemento_rescate_parcial(
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      pfefecto IN DATE,
      pirescatep IN NUMBER,
      poficina IN VARCHAR2,
      pterminal IN VARCHAR2,
      pcidioma_user IN NUMBER DEFAULT f_idiomauser,
      pcommit IN NUMBER DEFAULT 1,
      ocoderror OUT NUMBER,
      omsgerror OUT VARCHAR2)
      RETURN NUMBER IS
      /********************************************************************************************************************************
         Función que graba el suplemento de cambio de idioma.

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
      v_cont         NUMBER;
      vcmotmov       NUMBER;
      v_fefecto      DATE;
      error          EXCEPTION;
      error_fin_supl EXCEPTION;
   BEGIN
      -- Código del motivo de movimiento (suplemento)
      vcmotmov := 550;
      -- La fecha de efecto debe estar truncada
      v_fefecto := TRUNC(pfefecto);
--------------------------------------------------------------------------
-- Validar que la póliza permite el suplemento
--------------------------------------------------------------------------
      num_err := f_valida_poliza_permite_supl(pnpoliza, pncertif, v_fefecto, vcmotmov,
                                              pcidioma_user, ocoderror, omsgerror);

      IF num_err IS NULL THEN
         RAISE error;
      END IF;

--------------------------------------------------------------------------
-- Validamos que estén informados los datos del suplemento
--------------------------------------------------------------------------
      IF pnpoliza IS NULL
         OR pncertif IS NULL THEN
         ocoderror := 140896;   -- Se tiene que informar la poliza
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error;
      END IF;

      IF v_fefecto IS NULL THEN
         ocoderror := 120077;   -- Falta informar la fecha efecto
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error;
      END IF;

      IF pirescatep IS NULL THEN
         ocoderror := 180815;   -- Importe de rescate parcial obligatorio
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
*/    -------------------------------------------------------------------------------------------
      -- Se traspasan los datos a las tablas EST y se dejan preparadas para hacer el suplemento
      -------------------------------------------------------------------------------------------
      -- Todas las funciones a partir de esta deben tener RAISE error_fin_supl
      v_sseguro := ff_buscasseguro(pnpoliza, pncertif);
      num_err := pk_suplementos.f_inicializar_suplemento(v_sseguro, 'SUPLEMENTO', v_fefecto,
                                                         'BBDD', '*', vcmotmov, v_est_sseguro,
                                                         v_nmovimi);

      IF num_err <> 0 THEN
         ocoderror := num_err;
         omsgerror := f_axis_literales(ocoderror, pcidioma_user);
         RAISE error_fin_supl;
      END IF;

-------------------------------------------------------------------------------------------
-- Se realiza la modificación del domicilio en las tablas EST
-------------------------------------------------------------------------------------------
      num_err := pac_prod_comu.f_cambio_rescate_parcial(v_sseguro, v_est_sseguro, v_fefecto,
                                                        v_nmovimi, pirescatep);

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
       WHERE sseguro = v_sseguro;

      --Ini Bug.: 13069 - 23/02/2010 - ICV
      num_err := pk_suplementos.f_validar_cambios(f_user, v_est_sseguro, v_nmovimi, v_sproduc,
                                                  'BBDD', 'SUPLEMENTO',
                                                  pac_md_common.f_get_cxtidioma);

      --Fin Bug.: 13069
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

      IF pcommit = 1 THEN
         COMMIT;
      END IF;

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
         omsgerror := 'Pub_Contrata_Comu.f_suplemento_idioma: Error general en la función';
         ROLLBACK;
         p_tab_error(f_sysdate, getuser, 'Pub_Contrata_Comu.f_suplemento_rescate_parcial',
                     NULL,
                     'parametros: pnpoliza = ' || pnpoliza || ' pncertif =' || pncertif
                     || ' pirescatep = ' || pirescatep || ' poficina =' || poficina
                     || ' pterminal =' || pterminal,
                     SQLERRM);
         num_err := pk_suplementos.f_final_suplemento(v_est_sseguro, v_nmovimi, v_sseguro);
         COMMIT;
         RETURN NULL;
   END f_suplemento_rescate_parcial;
END pac_ref_contrata_comu;

/

  GRANT EXECUTE ON "AXIS"."PAC_REF_CONTRATA_COMU" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_REF_CONTRATA_COMU" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_REF_CONTRATA_COMU" TO "PROGRAMADORESCSI";
