--------------------------------------------------------
--  DDL for Package Body PAC_REF_CONTRATA_RENTAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_REF_CONTRATA_RENTAS" AS
/******************************************************************************
      NOMBRE:     Pac_Ref_Contrata_Rentas
      PROPÓSITO:  Funciones contratación rentas

      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.0        XX/XX/XXXX   XXX                1. Creación del package.
      1.1        30/01/2009   JRH                2. Bug-9173 Rentas Enea
      3.0        01/02/2010   DRA                3. BUG12881. Es comenta tota la part referent al f_usuario_cobro
      4.0       27/04/2010   JRH                4. 0014285: CEM Se añade interes y fppren
   ******************************************************************************/
   FUNCTION f_valida_garantias_rentas(
      psproduc IN NUMBER,
      psperson1 IN NUMBER,
      psperson2 IN NUMBER,
      pfefecto IN DATE,
      prima_per IN NUMBER,
      pcforpag IN NUMBER,
      pfallaseg IN NUMBER,
      pcagente IN NUMBER,
      pcidioma_user IN NUMBER DEFAULT f_idiomauser,
      fecoperhi IN DATE,   --JRH IMP Que hago con estas dos
      ccrnhi IN VARCHAR2,
      tasinmuebhi IN NUMBER,
      pcttasinmuebhi IN NUMBER,
      capitaldisphi IN NUMBER,
      pctrevrt IN NUMBER,
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

      IF NVL(f_parproductos_v(psproduc, 'HIPOTECA_INVERSA'), 0) <> 1 THEN   --En el cas de hipoteca inversa no es valida la prima
         IF prima_per IS NULL
            AND v_ctipgar = 2 THEN   -- si la garantía es obligatoria y no viene informado el capital
            ocoderror := 180181;   -- Prima obligatoria
            omsgerror := f_literal(ocoderror, pcidioma_user);
            RAISE error;
         ELSE
            v_capital := prima_per;
            num_err := pac_val_rentas.f_valida_prima_rentas(1, psproduc, psperson1, 3,
                                                            v_capital, pcforpag);

            IF num_err <> 0 THEN
               ocoderror := num_err;
               omsgerror := f_literal(ocoderror, pcidioma_user);
               RAISE error;
            END IF;
         END IF;
      END IF;

-------------------------------------------------------------------------------------------------------
-- Validamos las garantias de fallecimiento y accidente del asegurado 1 y asegurado 2
-------------------------------------------------------------------------------------------------------
-- Garantia Fallecimiento Asegurado 1
/*num_err := Pac_Val_Rentas.f_valida_garantia_adicional(psproduc, psperson1, pfallaseg, 6, 1, v_fefecto);
IF num_err <> 0 THEN
   oCODERROR := num_err;
   oMSGERROR := f_literal(oCODERROR, pcidioma_user);
   RAISE error;
END IF;*/

      /*num_err := Pac_Val_Rentas.f_valida_forma_pago_renta(psproduc, forpagorenta);
      IF num_err <> 0 THEN
         oCODERROR := num_err;
         oMSGERROR := f_literal(oCODERROR, pcidioma_user);
         RAISE error;
      END IF;*/
      num_err := pac_val_rentas.f_valida_percreservcap(psproduc, pfallaseg);

      IF num_err <> 0 THEN
         ocoderror := num_err;
         omsgerror := f_literal(ocoderror, pcidioma_user);
         RAISE error;
      END IF;

      num_err := pac_val_rentas.f_valida_pct_revers(psproduc, pctrevrt);

      IF num_err <> 0 THEN
         ocoderror := num_err;
         omsgerror := f_literal(ocoderror, pcidioma_user);
         RAISE error;
      END IF;

      num_err := pac_val_rentas.f_valida_perctasacio(psproduc, pcttasinmuebhi);

      IF num_err <> 0 THEN
         ocoderror := num_err;
         omsgerror := f_literal(ocoderror, pcidioma_user);
         RAISE error;
      END IF;

      num_err := pac_val_rentas.f_valida_capitaldisp(psproduc, tasinmuebhi, capitaldisphi);

      IF num_err <> 0 THEN
         ocoderror := num_err;
         omsgerror := f_literal(ocoderror, pcidioma_user);
         RAISE error;
      END IF;

      IF NVL(f_parproductos_v(psproduc, 'HIPOTECA_INVERSA'), 0) = 1 THEN
         IF (fecoperhi IS NULL) THEN
            ocoderror := 180581;
            omsgerror := f_literal(ocoderror, pcidioma_user);
            RAISE error;
         END IF;

         IF TRUNC(fecoperhi) < TRUNC(SYSDATE) THEN
            ocoderror := 180582;
            omsgerror := f_literal(ocoderror, pcidioma_user);
            RAISE error;
         END IF;
      END IF;

      --JRH IMP Falta valida la cuenta
      RETURN 0;
   EXCEPTION
      WHEN error THEN
         RETURN NULL;
      WHEN OTHERS THEN
         ocoderror := -999;
         omsgerror :=
              'Pac_Ref_Contrata_Rentas.f_valida_garantias_rentas: Error general en la función';
         p_tab_error(f_sysdate, getuser, 'Pac_Ref_Contrata_Rentas.f_valida_garantias_rentas',
                     NULL,
                     'parametros: psproduc = ' || psproduc || '  psperson1 = ' || psperson1
                     || ' psperson2 = ' || psperson2 || '  pfefecto = ' || pfefecto
                     || ' prima_inicial = ' || '' || ' prima_per = ' || prima_per
                     || ' prevali = ' || '' || ' pcforpag = ' || pcforpag || ' pfallaseg1 = '
                     || pfallaseg || ' pcfallaseg2 = ' || '' || ' pcaccaseg1 = ' || ''
                     || ' pcaccaseg2 = ' || '' || ' pcagente = ' || pcagente
                     || ' pcidioma_user = ' || pcidioma_user,
                     SQLERRM);
         RETURN NULL;
   END f_valida_garantias_rentas;

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
   BEGIN
      -- Código del motivo de movimiento (suplemento)
      vcmotmov := 522;

--------------------------------------------------------------------------
-- Validamos que estén informados los datos del suplemento
--------------------------------------------------------------------------
      IF pnpoliza IS NULL
         OR pncertif IS NULL THEN
         ocoderror := 140896;   -- Se tiene que informar la poliza
         omsgerror := f_literal(ocoderror, pcidioma_user);
         RAISE error;
      END IF;

/*
    IF v_fefecto IS NULL THEN
       oCODERROR := 120077;  -- Falta informar la fecha efecto
          oMSGERROR := f_literal(oCODERROR, pcidioma_user);
       RAISE error;
    END IF;
*/
      IF NVL(f_parproductos_v(v_sproduc, 'DURPER'), 0) = 1 THEN
         IF pndurper IS NULL THEN
            ocoderror := 151288;   -- La duración es obligatoria
            omsgerror := f_literal(ocoderror, pcidioma_user);
            RAISE error;
         END IF;
      END IF;

      IF ppinttec IS NULL THEN
         ocoderror := 112139;   -- El importe del interés es obligatorio
         omsgerror := f_literal(ocoderror, pcidioma_user);
         RAISE error;
      END IF;

      IF poficina IS NULL THEN
         ocoderror := 180252;   -- Es obligatorio introducir la oficina
         omsgerror := f_literal(ocoderror, pcidioma_user);
         RAISE error;
      END IF;

/*
    IF pterminal IS NULL THEN
       oCODERROR := 180253;  -- Es obligatorio introducir el terminal
          oMSGERROR := f_literal(oCODERROR, pcidioma_user);
       RAISE error;
    END IF;
*/  -------------------------------------------------
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
               ocoderror := 120445;   -- Error al leer de SEGUROS_rentas
               omsgerror := f_literal(ocoderror, pcidioma_user);
               RAISE error;
         END;

         IF v_frevant IS NULL THEN
            num_err := pac_val_comu.f_valida_durper(v_sproduc, pndurper, v_fefecto);

            IF num_err <> 0 THEN
               ocoderror := num_err;
               omsgerror := f_literal(ocoderror, pcidioma_user);
               RAISE error;
            END IF;
         ELSE
            num_err := pac_val_comu.f_valida_duracion_renova(v_sseguro, pndurper);

            IF num_err <> 0 THEN
               ocoderror := num_err;
               omsgerror := f_literal(ocoderror, pcidioma_user);
               RAISE error;
            END IF;
         END IF;
      END IF;

-------------------------------------------------------------------------------------------
-- Se traspasan los datos a las tablas EST y se dejan preparadas para hacer el suplemento
-------------------------------------------------------------------------------------------
      num_err := pk_suplementos.f_inicializar_suplemento(v_sseguro, 'SUPLEMENTO', v_fefecto,
                                                         'BBDD', '*', vcmotmov, v_est_sseguro,
                                                         v_nmovimi);

      IF num_err <> 0 THEN
         ocoderror := num_err;
         omsgerror := f_literal(ocoderror, pcidioma_user);
         RAISE error;
      END IF;

-------------------------------------------------------------------------------------------
-- Se realiza la modificación del interés en las tablas EST
-------------------------------------------------------------------------------------------
      num_err := pac_prod_comu.f_cambio_interes(v_est_sseguro, pndurper, ppinttec, v_nmovimi);

      IF num_err <> 0 THEN
         ocoderror := num_err;
         omsgerror := f_literal(ocoderror, pcidioma_user);
         RAISE error_fin_supl;
      END IF;

-------------------------------------------------------------------------------------------
-- Se valida que se haya realizado algún cambio
-------------------------------------------------------------------------------------------
      num_err := pk_suplementos.f_validar_cambios(f_user, v_est_sseguro, v_nmovimi, v_sproduc,
                                                  'BBDD', 'SUPLEMENTO');

      IF num_err <> 0 THEN
         ocoderror := num_err;
         omsgerror := f_literal(ocoderror, pcidioma_user);
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
            omsgerror := f_literal(ocoderror, pcidioma_user);
            RAISE error_fin_supl;
      END;

      IF v_cont = 0 THEN   -- No ha habido ningún cambio
         ocoderror := 107804;   -- No se ha realizado ningún cambio
         omsgerror := f_literal(ocoderror, pcidioma_user);
         RAISE error_fin_supl;
      END IF;

-------------------------------------------------------------------------------------------
-- Se graba el suplemento en las tablas reales
-------------------------------------------------------------------------------------------
      num_err := pk_suplementos.f_grabar_suplemento_poliza(v_est_sseguro, v_nmovimi);

      IF num_err <> 0 THEN
         ocoderror := num_err;
         omsgerror := f_literal(ocoderror, pcidioma_user);
         RAISE error_fin_supl;
      END IF;

-------------------------------------------------------------------------------------------
-- Se emite el suplemento
-------------------------------------------------------------------------------------------
      num_err := pac_prod_comu.f_emite_propuesta(v_sseguro, v_npoliza, v_ncertif, v_nrecibo,
                                                 v_nsolici);

      IF num_err <> 0 THEN
         ocoderror := num_err;
         omsgerror := f_literal(ocoderror, pcidioma_user);
         RAISE error;
      END IF;

-------------------------------------------------------------------------------------------
-- Se envia correo a la oficina de gestión si corresponde
-------------------------------------------------------------------------------------------
      num_err := pac_avisos.f_accion(1, v_sseguro, 1, pcidioma_user, 'REAL', vcmotmov, 5,
                                     poficina, pterminal, v_nmovimi);

      IF num_err <> 0 THEN
         ocoderror := num_err;
         omsgerror := f_literal(ocoderror, pcidioma_user);
         RAISE error;
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

         IF num_err <> 0 THEN
            ocoderror := num_err;
            omsgerror := f_literal(ocoderror, pcidioma_user);
            ROLLBACK;
         END IF;

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
         RETURN NULL;
   END f_suplemento_interes;

   FUNCTION f_revision_renovacion(
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      pndurper IN NUMBER,
      ppinttec IN NUMBER,
      pcapital IN NUMBER,
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
              . pcapital = %Capital fallecimiento
         Parámetros de salida:
              . ocoderror = Código de Error
              . omsgerror = Descripción del error

           La función retorna:
              0 - si ha ido bien
             Null - si no cumple alguna validación o hay un error.
      *********************************************************************************************************************************/
      num_err        NUMBER;
      v_sseguro      NUMBER;
      capfallant     NUMBER;
      v_producto     NUMBER;
      error          EXCEPTION;
   BEGIN
      -- Se busca el sseguro de la póliza
      v_sseguro := ff_buscasseguro(pnpoliza, pncertif);

      IF v_sseguro IS NULL THEN
         num_err := 111995;   -- Es obligatorio informar el número de seguro
         RAISE error;
      END IF;

      SELECT sproduc
        INTO v_producto
        FROM seguros
       WHERE sseguro = v_sseguro;

      -- Se valida que la póliza esté en periodo de renovación
      num_err := pac_val_comu.f_valida_poliza_renova(v_sseguro, 2);   -- 2 = Renovación/Revisión

      IF num_err <> 0 THEN
         RAISE error;
      END IF;

      -- Se valida la nueva duración seleccionada
      num_err := pac_val_comu.f_valida_duracion_renova(v_sseguro, pndurper);

      IF num_err <> 0 THEN
         RAISE error;
      END IF;

      -- Se valida la nueva duración seleccionada
      num_err := pac_val_rentas.f_valida_percreservcap(v_producto, pcapital);

      IF num_err <> 0 THEN
         RAISE error;
      END IF;

      -- Se valida el cambio de capital
      num_err := pac_val_rentas.f_valida_cambreservcap(v_sseguro, pcapital);

      IF num_err <> 0 THEN
         RAISE error;
      END IF;

      -- Se registran los nuevos valores de duración e interés a aplicar en la revisión/renovación
      num_err := pac_prod_comu.f_programa_revision_renovacion(v_sseguro, pndurper, ppinttec,
                                                              pcapital);

      IF num_err <> 0 THEN
         RAISE error;
      END IF;

      -- Todo OK
      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN error THEN
         ocoderror := num_err;
         omsgerror := f_literal(ocoderror, pcidioma_user);
         ROLLBACK;
         RETURN NULL;
      WHEN OTHERS THEN
         ocoderror := 108190;   -- Error General
         omsgerror := f_literal(ocoderror, pcidioma_user);
         ROLLBACK;
         p_tab_error(f_sysdate, getuser, 'Pac_Ref_Contrata_Rentas.f_revision_renovacion',
                     NULL,
                     'parametros: pnpoliza=' || pnpoliza || ' pncertif=' || pncertif
                     || ' pndurper=' || pndurper || ' ppinttec=' || ppinttec,
                     SQLERRM);
         RETURN NULL;
   END f_revision_renovacion;

/*************************************************************************
   Actualiza SEGUROS_REN después de la tarificación
   Param IN psproduc : Producto
   Param IN    pfefecto : fecha efec
   Param IN    pnduraci : duración
   Param IN    pfvencim : Fecha vencimiento
   Param IN    pcforpag : forma de pago
   Param IN    prima_per : prima periodica
   Param IN    pfallaseg: % sobre capital fallecimiento
   Param IN    ptasinmuebHI: % Sobre inmueble
   Param IN    ppcttasinmuebHI: % tase sobre inmueble
   Param IN    pcapitaldispHI : Capital inmueble
   Param IN    pctrevRT : % reversión
   Param IN    forpagorenta : Forma pago de la renta
   Param IN    psseguro : seguro
   Param IN   tablas : Tablas
   Param OUT   Coderror : Tablas
****************************************************************************************/
   PROCEDURE f_actualizar_segurosren(
      psproduc IN NUMBER,
      pfefecto IN DATE,
      pnduraci IN NUMBER,
      pfvencim IN DATE,
      pcforpag IN NUMBER,
      prima_per IN NUMBER,
      pfallaseg IN NUMBER,
      ptasinmuebhi IN NUMBER,
      ppcttasinmuebhi IN NUMBER,
      pcapitaldisphi IN NUMBER,
      pctrevrt IN NUMBER,
      forpagorenta IN NUMBER,
      psseguro IN NUMBER,
      ocoderror OUT NUMBER,
      tablas VARCHAR2 DEFAULT 'EST',
      -- Bug 14285 - 26/04/2010 - JRH - 0014285: CEM303 - Informar fecha de primer pago de renta en la contratación e interés
      ppfpren IN DATE DEFAULT NULL
                                  -- Fi Bug 14285 - 26/04/2010 - JRH
   ) IS
      fecultpago     DATE;
      fecprimpago    DATE;
      importebruto   estseguros_ren.ibruren%TYPE;
      fecfinrenta    DATE;
      fechaproxpago  DATE;
      fechainteres   DATE;
      estadopago     estseguros_ren.cestmre%TYPE;
      estadopagos    estseguros_ren.cblopag%TYPE;
      durtramo       estseguros_ren.nduraint%TYPE;
      capinirent     estseguros_ren.icapren%TYPE;
      tipoint        estseguros_ren.ptipoint%TYPE;
      doscab         estseguros_ren.pdoscab%TYPE := pctrevrt;   --JRH IMP
      capfallec      estseguros_ren.pcapfall%TYPE;
      reserv         estseguros_ren.ireserva%TYPE;
      fecrevi        DATE;
      num_err        NUMBER;
      error          EXCEPTION;
      error2         EXCEPTION;
   BEGIN
      ocoderror := 0;
      capfallec := pfallaseg;
      num_err := pac_calc_rentas.f_obtener_datos_rentas_ini(psseguro, psproduc, pfefecto,
                                                            pfvencim, pnduraci, fecultpago,
                                                            fecprimpago, importebruto,
                                                            fecfinrenta, fechaproxpago,
                                                            fechainteres, estadopago,
                                                            estadopagos, durtramo, capinirent,
                                                            tipoint, doscab,   --JRH IMP
                                                            capfallec, reserv, fecrevi,
                                                            tablas);

      IF num_err <> 0 THEN
         ocoderror := num_err;
         --oMSGERROR := f_literal(num_err, pcidioma_user);
         RAISE error;
      END IF;

      doscab := pctrevrt;

      IF tablas = 'EST' THEN
         UPDATE estseguros_ren
            SET f1paren = NVL(ppfpren, NVL(fecprimpago, pfefecto)),   --JRH IMP Se tendrá que cambiar por fec oper en HI
                fuparen = fecultpago,
                cforpag = forpagorenta,
                ibruren = importebruto,
                ffinren = fecfinrenta,
                cmotivo = NULL,
                cmodali = NULL,
                fppren = NVL(ppfpren, fechaproxpago),
                ibrure2 = NULL,
                fintgar = fechainteres,
                cestmre = estadopago,
                cblopag = estadopagos,
                nduraint = NULL,   -- BUG 0009173 - 03/2009 - JRH  - 0009173: CRE - Rentas Enea. La duración viene en SEGUROS_AHO
                icapren = capinirent,
                ptipoint = tipoint,
                pdoscab = doscab,
                pcapfall = NVL(pfallaseg, 0)   -- ,
          --IRESERVA = Reserv  ,

         --FREVANT = NULL --,
                         --FREVISIO  = FecRevi
         WHERE  sseguro = psseguro;

         IF SQL%ROWCOUNT <> 1 THEN
            RAISE error2;
         END IF;

         BEGIN   -- JRH  pero que MUY IMP Guardaremos también en esta tabla  las duraciones. Nos guiamos por la agrupció del ramo , para insertar en esta tabla y que se modif. la fecha de revisión.
            INSERT INTO estseguros_aho
                        (sseguro, ndurper, frevisio, ndurrev, pintrev)
                 VALUES (psseguro, durtramo, fecrevi, NULL, NULL);
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               UPDATE estseguros_aho
                  SET ndurper = durtramo,
                      frevisio = fecrevi,
                      ndurrev = NULL,
                      pintrev = NULL,
                      frevant = NULL
                WHERE sseguro = psseguro;
         END;
      ELSIF tablas = 'SOL' THEN
         UPDATE solseguros_ren
            SET f1paren = NVL(ppfpren, NVL(fecprimpago, pfefecto)),
                fuparen = fecultpago,
                cforpag = forpagorenta,
                ibruren = importebruto,
                ffinren = fecfinrenta,
                cmotivo = NULL,
                cmodali = NULL,
                fppren = NVL(ppfpren, fechaproxpago),
                ibrure2 = NULL,
                fintgar = fechainteres,
                cestmre = estadopago,
                cblopag = estadopagos,
                nduraint = NULL,   -- BUG 0009173 - 03/2009 - JRH  - 0009173: CRE - Rentas Enea. La duración viene en SEGUROS_AHO
                icapren = capinirent,
                ptipoint = tipoint,
                pdoscab = doscab,
                pcapfall = NVL(pfallaseg, 0)   --,
          --IRESERVA = Reserv  ,

         --FREVANT = NULL --,
                         --  FREVISIO  = FecRevi
         WHERE  ssolicit = psseguro;

         IF SQL%ROWCOUNT <> 1 THEN
            RAISE error2;
         END IF;

         BEGIN   -- JRH  pero que MUY IMP Guardaremos también en esta tabla  las duraciones. Nos guiamos por la agrupció del ramo , para insertar en esta tabla y que se modif. la fecha de revisión.
            INSERT INTO solseguros_aho
                        (ssolicit, ndurper, frevisio, ndurrev, pintrev)
                 VALUES (psseguro, durtramo, fecrevi, NULL, NULL);
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               UPDATE solseguros_aho
                  SET ndurper = durtramo,
                      frevisio = fecrevi,
                      ndurrev = NULL,
                      pintrev = NULL,
                      frevant = NULL
                WHERE ssolicit = psseguro;
         END;
      ELSE
         UPDATE seguros_ren
            SET f1paren = NVL(ppfpren, NVL(fecprimpago, pfefecto)),
                fuparen = fecultpago,
                cforpag = forpagorenta,
                ibruren = importebruto,
                ffinren = fecfinrenta,
                cmotivo = NULL,
                cmodali = NULL,
                fppren = NVL(ppfpren, fechaproxpago),
                ibrure2 = NULL,
                fintgar = fechainteres,
                cestmre = estadopago,
                cblopag = estadopagos,
                nduraint = NULL,   -- BUG 0009173 - 03/2009 - JRH  - 0009173: CRE - Rentas Enea. La duración viene en SEGUROS_AHO
                icapren = capinirent,
                ptipoint = tipoint,
                pdoscab = doscab,
                pcapfall = NVL(pfallaseg, 0)   --,
          --IRESERVA = Reserv  ,

         --FREVANT = NULL-- ,
                         --FREVISIO  = FecRevi
         WHERE  sseguro = psseguro;

         IF SQL%ROWCOUNT <> 1 THEN
            RAISE error2;
         END IF;

         BEGIN   -- JRH  pero que MUY IMP Guardaremos también en esta tabla  las duraciones. Nos guiamos por la agrupció del ramo , para insertar en esta tabla y que se modif. la fecha de revisión.
            INSERT INTO seguros_aho
                        (sseguro, ndurper, frevisio, ndurrev, pintrev)
                 VALUES (psseguro, durtramo, fecrevi, NULL, NULL);
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               UPDATE seguros_aho
                  SET ndurper = durtramo,
                      frevisio = fecrevi,
                      ndurrev = NULL,
                      pintrev = NULL,
                      frevant = NULL
                WHERE sseguro = psseguro;
         END;
      END IF;
   EXCEPTION
      WHEN error THEN
         ocoderror := 180583;
         p_tab_error(f_sysdate, getuser, 'Pac_Ref_contrata_entas.f_actualizar_segurosren', 1,
                     'parametros: sproduc =' || psproduc || ' psseguro=' || psseguro
                     || ' fecEfecto=' || pfefecto || ' fecVto=' || pfvencim || ' nduraci='
                     || pnduraci,
                     'Error buscando datos inciales de la renta');
      WHEN error2 THEN
         ocoderror := 180584;
         p_tab_error(f_sysdate, getuser, 'Pac_Ref_contrata_entas.f_actualizar_segurosren', 1,
                     'parametros: sproduc =' || psproduc || ' psseguro=' || psseguro
                     || ' fecEfecto=' || pfefecto || ' fecVto=' || pfvencim || ' nduraci='
                     || pnduraci,
                     'Póliza antes no generada');
      WHEN OTHERS THEN
         ocoderror := 180342;
         p_tab_error(f_sysdate, getuser, 'Pac_Ref_contrata_entas.f_actualizar_segurosren', 1,
                     'parametros: sproduc =' || psproduc || ' psseguro=' || psseguro
                     || ' fecEfecto=' || pfefecto || ' fecVto=' || pfvencim || ' nduraci='
                     || pnduraci,
                     SQLERRM);
   END;

   FUNCTION f_genera_poliza_rentas(
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
      tasinmuebhi IN NUMBER,
      pcttasinmuebhi IN NUMBER,
      capitaldisphi IN NUMBER,
      pctrevrt IN NUMBER,
      fecoperhi IN DATE,
      ccrnhi IN VARCHAR2,
      pcbancar_recibo IN VARCHAR2,
      pforpagorenta IN NUMBER,
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
      -- JRH  Variables Producto
      xcramo         NUMBER;
      xcmodali       NUMBER;
      xctipseg       NUMBER;
      xccolect       NUMBER;
      forpagorenta   NUMBER;
      tab_pregun     pac_prod_comu.t_preguntas;
      indpregun      NUMBER := 1;
   BEGIN
      v_sseguro_est := psseguro;
      -- La fecha de efecto debe estar truncada
      v_fefecto := TRUNC(pfefecto);

------------------------------------------------------------------------
-- Validamos el código del producto
------------------------------------------------------------------------
      IF psproduc IS NULL THEN
         ocoderror := 120149;   -- Es obligatorio introducir un producte
         omsgerror := f_literal(ocoderror, pcidioma_user);
         RAISE error;
      END IF;

------------------------------------------------------------------------
-- Validamos el Terminal
------------------------------------------------------------------------
      IF pterminal IS NULL THEN
         ocoderror := 180253;   -- Es obligatorio introducir el terminal
         omsgerror := f_literal(ocoderror, pcidioma_user);
         RAISE error;
      END IF;

------------------------------------------------------------------------
-- Validamos el código del agente
------------------------------------------------------------------------
      num_err := pac_val_comu.f_valida_agente(pcagente);

      IF num_err <> 0 THEN
         ocoderror := num_err;
         omsgerror := f_literal(num_err, pcidioma_user);
         RAISE error;
      END IF;

------------------------------------------------------------------------
-- Validamos la fecha de efecto
------------------------------------------------------------------------
      IF v_fefecto IS NULL THEN
         ocoderror := 104532;   -- Fecha efecto obligatoria
         omsgerror := f_literal(ocoderror, pcidioma_user);
         RAISE error;
      END IF;

      IF pforpagorenta IS NULL THEN
         SELECT cforpag
           INTO forpagorenta
           FROM forpagren
          WHERE sproduc = psproduc;
      ELSE
         forpagorenta := pforpagorenta;
      END IF;

      /*IF NVL(f_parproductos_v(psproduc,'ES_PRODUCTO_AHO'),0) = 1 THEN -- es un producto de ahorro RVD
             if ((pctrevRT IS NULL) OR (pctRevaliRVD IS NULL) OR (ppinttec IS NULL)) then
                                             oCODERROR := 102751;  -- Fecha efecto obligatoria
                                     oMSGERROR := f_literal(oCODERROR, pcidioma_user);
                                     RAISE error;
             end if;
      END IF;*/
      v_cfallaseg1 := NVL(pfallaseg, 0);

      SELECT cramo, cmodali, ctipseg, ccolect
        INTO xcramo, xcmodali, xctipseg, xccolect
        FROM productos
       WHERE sproduc = psproduc;

------------------------------------------------------------------------
-- Validamos las cláusulas de beneficiario
-- Mira que no sea nulo y que el producto las tenga
------------------------------------------------------------------------
      num_err := pac_val_comu.f_valida_beneficiario(psproduc, psclaben, ptclaben);

      IF num_err <> 0 THEN
         ocoderror := num_err;
         omsgerror := f_literal(num_err, pcidioma_user);
         RAISE error;
      END IF;

-----------------------------------------------------------------------
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
         omsgerror := f_literal(ocoderror, pcidioma_user);
         RAISE error;
      END IF;

--------------------------------------------------------------------------
-- Validamos los datos de gestión
--------------------------------------------------------------------------
-- Se busca la fecha de nacimiento del sperson1
      num_err := f_persodat2(psperson1, v_csexo1, v_fnacimi1, v_cestado1, v_csujeto1, v_cpais1);

      IF num_err <> 0 THEN
         ocoderror := num_err;
         omsgerror := f_literal(num_err, pcidioma_user);
         RAISE error;
      END IF;

      num_err := pac_val_rentas.f_valida_gestion_rentas(psproduc, 1, v_fefecto, v_fnacimi1,
                                                        pcidioma, pcforpag, pnduraci, pfvencim,
                                                        pcbancar, pcidioma_user, forpagorenta,
                                                        ocoderror, omsgerror);

      IF num_err IS NULL THEN
         RAISE error;
      END IF;

 --------------------------------------------------------------------------
 -- Validamos las primas y las garantias adicionales
 --------------------------------------------------------------------------
--   num_err := f_valida_primas_rentas(psproduc, psperson1, v_fefecto, prima_inicial, prima_per, prevali, pcforpag, v_cfallaseg1, v_cfallaseg2,
--                v_caccaseg1, v_caccaseg2, pcagente, pcidioma_user, ocoderror, omsgerror);
      num_err := f_valida_garantias_rentas(psproduc, psperson1, psperson2, v_fefecto,
                                           prima_per, pcforpag, v_cfallaseg1, pcagente,
                                           pcidioma_user, fecoperhi, ccrnhi, tasinmuebhi,
                                           pcttasinmuebhi, capitaldisphi, pctrevrt, ocoderror,
                                           omsgerror);

      IF num_err IS NULL THEN
         RAISE error;
      END IF;

      --Grabamos preguntas de HI
      IF NVL(f_parproductos_v(psproduc, 'HIPOTECA_INVERSA'), 0) = 1 THEN
         IF (tasinmuebhi IS NOT NULL) THEN
            tab_pregun(indpregun).codigo := 100;
            tab_pregun(indpregun).respuesta := TO_CHAR(tasinmuebhi);
            tab_pregun(indpregun).tipo := 'N';
            indpregun := indpregun + 1;
         END IF;

         IF (pcttasinmuebhi IS NOT NULL) THEN
            tab_pregun(indpregun).codigo := 101;
            tab_pregun(indpregun).respuesta := TO_CHAR(pcttasinmuebhi);
            tab_pregun(indpregun).tipo := 'N';
            indpregun := indpregun + 1;
         END IF;

         IF (capitaldisphi IS NOT NULL) THEN
            tab_pregun(indpregun).codigo := 102;
            tab_pregun(indpregun).respuesta := TO_CHAR(capitaldisphi);
            tab_pregun(indpregun).tipo := 'N';
            indpregun := indpregun + 1;
         END IF;

         IF (fecoperhi IS NOT NULL) THEN
            tab_pregun(indpregun).codigo := 103;
            tab_pregun(indpregun).respuesta := TO_CHAR(fecoperhi, 'DD/MM/YYYY');
            tab_pregun(indpregun).tipo := 'F';
            indpregun := indpregun + 1;
         END IF;

         IF (ccrnhi IS NOT NULL) THEN
            tab_pregun(indpregun).codigo := 104;
            tab_pregun(indpregun).respuesta := ccrnhi;
            tab_pregun(indpregun).tipo := 'N';
            indpregun := indpregun + 1;
         END IF;
      END IF;

-----------------------------------------------------------------------------
 -- Grabamos la propuesta y tarifamos
 ----------------------------------------------------------------------------
      num_err := pac_prod_rentas.f_graba_propuesta_rentas(psproduc, psperson1, pcdomici1,
                                                          psperson2, pcdomici2, pcagente,
                                                          pcidioma, v_fefecto, pnduraci,
                                                          pfvencim, pcforpag, pcbancar,
                                                          psclaben, ptclaben, prima_per,
                                                          v_cfallaseg1, tab_pregun,
                                                          forpagorenta, v_sseguro_est);

      IF num_err <> 0 THEN
         ocoderror := num_err;
         omsgerror := f_literal(num_err, pcidioma_user);
         RAISE error;
      END IF;

      --JRH  Actualizamos resto de atos de seguros_ren que no entran en tarificación.
      f_actualizar_segurosren(psproduc, pfefecto, pnduraci, pfvencim, pcforpag, prima_per,
                              pfallaseg,   --pcfallaseg2,
                              tasinmuebhi, pcttasinmuebhi, capitaldisphi, pctrevrt,
                              forpagorenta, v_sseguro_est, num_err);

      IF num_err <> 0 THEN
         ocoderror := num_err;
         omsgerror := f_literal(num_err, pcidioma_user);
         RAISE error;
      END IF;

-----------------------------------------------------------------------------
 -- Se graba la poliza
 -----------------------------------------------------------------------------
      num_err := pac_prod_comu.f_grabar_alta_poliza(v_sseguro_est, psseguro);

      IF num_err <> 0 THEN
         ocoderror := num_err;
         omsgerror := f_literal(num_err, pcidioma_user);
         RAISE error;
      END IF;

-----------------------------------------------------------------------------
-- Comprobar si se puede realizar el cobro del recibo on-line
-- Si se puede, entonces : 1. se genera (graba) la poliza (hecho antes)
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
      -- BUG12881:DRA:01/02/2010:Inici: Es comenta tota la part referent al f_usuario_cobro
--      IF f_usuario_cobro(pcagente, psproduc) = 1
--         AND NVL(f_parproductos_v(psproduc, 'HIPOTECA_INVERSA'), 0) = 0 THEN   -- Sí se puede realizar el cobro On_Line
--         --BUG 11777 - 25/11/2009 - JRB - Se elimina la llamada, esta función no debería usarse, se tendrá que llamar
--         --todo desde el pac_md_gestion_rec.f_cobro_recibo
--         /*num_err := pac_prod_comu.f_emision_cobro_recibo(psseguro, pcbancar_recibo,
--                                                         pcidioma_user, pterminal, vnpoliza,
--                                                         vncertif, vnsolici, vcsituac,
--                                                         v_nrecibo);                  */
--         IF num_err <> 0 THEN
--            ocoderror := num_err;
--            omsgerror := f_literal(num_err, pcidioma_user);
--            RAISE error;
--         END IF;
--      ELSE   -- No se puede realizar el cobro On_Line
         -- Si la forma de pago es única
      IF pcforpag = 0 THEN
-----------------------------------------------------------------------------
-- Se retiene la póliza
-----------------------------------------------------------------------------
         num_err := pac_emision_mv.f_retener_poliza('SEG', psseguro, 1, 1, 4, 2, v_fefecto);

         IF num_err <> 0 THEN
            ocoderror := num_err;
            omsgerror := f_literal(num_err, pcidioma_user);
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
-- Emitimos la propuesta
  ----------------------------------------------------------------------------
         num_err := pac_prod_comu.f_emite_propuesta(psseguro, vnpoliza, vncertif, v_nrecibo,
                                                    vnsolici);

         IF num_err <> 0 THEN
            ocoderror := num_err;
            omsgerror := f_literal(num_err, pcidioma_user);
            RAISE error;
         END IF;

         vcsituac := 0;   -- Vigente
      END IF;

--      END IF;
      -- BUG12881:DRA:01/02/2010:Fi

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
         pac_alctr126.borrar_tablas_est(v_sseguro_est);
         COMMIT;
         RETURN ocoderror;
      WHEN OTHERS THEN
         ocoderror := -999;
         omsgerror :=
              'Pac_Ref_Contrata_Rentas.f_genera_propuesta_rentas: Error general en la función';
         ROLLBACK;
         pac_alctr126.borrar_tablas_est(v_sseguro_est);
         COMMIT;
         RETURN -999;
   END f_genera_poliza_rentas;

   FUNCTION f_emite_poliza_hi(
      psseguro IN NUMBER,
      pcbancar_recibo IN VARCHAR2,
      pcidioma_user IN NUMBER,
      pterminal IN VARCHAR2,
      vnpoliza OUT NUMBER,
      vncertif OUT NUMBER,
      vnsolici OUT NUMBER,
      vcsituac OUT NUMBER,
      v_nrecibo OUT NUMBER,
      ocoderror OUT NUMBER,
      omsgerror OUT VARCHAR2)
      RETURN NUMBER IS
      error          EXCEPTION;
      num_err        NUMBER;
   BEGIN
--------------------------------------------------------------------------
-- Validamos la cuenta bancaria del recibo
--------------------------------------------------------------------------
      num_err := pac_val_comu.f_valida_ccc(pcbancar_recibo, 1);

      IF num_err <> 0 THEN
         RAISE error;
      END IF;

      --BUG 11777 - 25/11/2009 - JRB - Se elimina la llamada, esta función no debería usarse, se tendrá que llamar
      --todo desde el pac_md_gestion_rec.f_cobro_recibo
      /*num_err := pac_prod_comu.f_emision_cobro_recibo(psseguro, pcbancar_recibo, pcidioma_user,
                                                      pterminal, vnpoliza, vncertif, vnsolici,
                                                      vcsituac, v_nrecibo);*/
      IF num_err <> 0 THEN
         RAISE error;
      END IF;

      COMMIT;   -- Realizmos commit de todo el proceso de emisión
      RETURN 0;
   EXCEPTION
      WHEN error THEN
         ocoderror := num_err;
         omsgerror := f_literal(ocoderror, pcidioma_user);
         ROLLBACK;
         p_tab_error(f_sysdate, getuser, 'Pac_Ref_Contrata_Rentas.f_emite_poliza_HI', NULL,
                     'parametros: psseguro=' || psseguro || ' pcbancar_recibo='
                     || pcbancar_recibo || ' pcidioma_user=' || pcidioma_user || ' pterminal='
                     || pterminal,
                     omsgerror);
         RETURN NULL;
      WHEN OTHERS THEN
         ocoderror := num_err;
         omsgerror := f_literal(ocoderror, pcidioma_user);
         ROLLBACK;
         p_tab_error(f_sysdate, getuser, 'Pac_Ref_Contrata_Rentas.f_emite_poliza_HI', NULL,
                     'parametros: psseguro=' || psseguro || ' pcbancar_recibo='
                     || pcbancar_recibo || ' pcidioma_user=' || pcidioma_user || ' pterminal='
                     || pterminal,
                     omsgerror);
         RETURN NULL;
   END f_emite_poliza_hi;
END pac_ref_contrata_rentas;

/

  GRANT EXECUTE ON "AXIS"."PAC_REF_CONTRATA_RENTAS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_REF_CONTRATA_RENTAS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_REF_CONTRATA_RENTAS" TO "PROGRAMADORESCSI";
