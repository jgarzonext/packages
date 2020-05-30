--------------------------------------------------------
--  DDL for Package Body PAC_REF_SIMULA_RENTAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_REF_SIMULA_RENTAS" AS
   FUNCTION f_valida_prima_rentas(
      ptipo IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      picapital IN NUMBER,
      pcforpag IN NUMBER,
      psperson IN NUMBER,
      pcpais IN NUMBER,
      pcidioma_user IN NUMBER DEFAULT f_idiomauser,
      pfallaseg IN NUMBER,
      tasinmuebhi IN NUMBER,
      pcttasinmuebhi IN NUMBER,
      capitaldisphi IN NUMBER,
      pctrevrt IN NUMBER,
      fecoperhi IN DATE,
      pforpagorenta IN NUMBER,
      coderror OUT NUMBER,
      msgerror OUT VARCHAR2)
      RETURN NUMBER IS
      num_err        NUMBER;
      v_capmin       NUMBER;
      v_capmax       NUMBER;
      formapagorenta NUMBER;
      forpagorenta   NUMBER;
   BEGIN
      IF ptipo <> 2 THEN   --No validamos la prima
         IF NVL(f_parproductos_v(psproduc, 'HIPOTECA_INVERSA'), 0) <> 1 THEN   --En el cas de hipoteca inversa no es valida la prima
            num_err := pac_val_comu.f_valida_capital(ptipo, psproduc, pcactivi, pcgarant,
                                                     picapital, pcforpag, v_capmin, v_capmax);

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

            num_err := pac_val_comu.f_valida_capital_persona(ptipo, psproduc, pcactivi,
                                                             pcgarant, picapital, psperson,
                                                             pcpais);

            IF num_err <> 0 THEN
               coderror := num_err;
               msgerror := f_axis_literales(coderror, pcidioma_user);
               RETURN NULL;
            END IF;
         END IF;
      END IF;

      num_err := pac_val_rentas.f_valida_percreservcap(psproduc, pfallaseg);

      IF num_err <> 0 THEN
         coderror := num_err;
         msgerror := f_axis_literales(coderror, pcidioma_user);
         RETURN NULL;
      END IF;

      num_err := pac_val_rentas.f_valida_pct_revers(psproduc, pctrevrt);

      IF num_err <> 0 THEN
         coderror := num_err;
         msgerror := f_axis_literales(coderror, pcidioma_user);
         RETURN NULL;
      END IF;

      num_err := pac_val_rentas.f_valida_perctasacio(psproduc, pcttasinmuebhi);

      IF num_err <> 0 THEN
         coderror := num_err;
         msgerror := f_axis_literales(coderror, pcidioma_user);
         RETURN NULL;
      END IF;

      num_err := pac_val_rentas.f_valida_capitaldisp(psproduc, tasinmuebhi, capitaldisphi);

      IF num_err <> 0 THEN
         coderror := num_err;
         msgerror := f_axis_literales(coderror, pcidioma_user);
         RETURN NULL;
      END IF;

      IF pforpagorenta IS NULL THEN
         SELECT cforpag
           INTO forpagorenta
           FROM forpagren
          WHERE sproduc = psproduc;
      ELSE
         forpagorenta := pforpagorenta;
      END IF;

      num_err := pac_val_rentas.f_valida_forma_pago_renta(psproduc, forpagorenta);

      IF num_err <> 0 THEN
         coderror := num_err;
         msgerror := f_axis_literales(coderror, pcidioma_user);
         RETURN NULL;
      END IF;

      IF NVL(f_parproductos_v(psproduc, 'HIPOTECA_INVERSA'), 0) = 1 THEN
         IF (fecoperhi IS NULL) THEN
            coderror := 500087;   --JRH IMP Falta mensajes
            msgerror := f_axis_literales(coderror, pcidioma_user);
            RETURN NULL;
         END IF;

         IF TRUNC(fecoperhi) < TRUNC(f_sysdate) THEN
            coderror := 110759;   --JRH IMP Falta mensajes
            msgerror := f_axis_literales(coderror, pcidioma_user);
            RETURN NULL;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         coderror := -999;
         msgerror := 'Pac_Ref_Simula_Rentas.f_valida_prima_rentas: Error General';
         p_tab_error(f_sysdate, f_user, 'Pac_Ref_Simula_Rentas.f_valida_prima_rentas', NULL,
                     'parametros: ptipo=' || ptipo || ' psproduc=' || psproduc || ' pcactivi='
                     || pcactivi || ' pcgarant=' || pcgarant || ' picapital=' || picapital
                     || ' pcforpag=' || pcforpag || ' psperson=' || psperson || ' pcpais='
                     || pcpais,
                     SQLERRM);
         RETURN NULL;
   END f_valida_prima_rentas;

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
         p_tab_error(f_sysdate, f_user, 'Pac_Ref_Simula_Rentas.f_valida_poliza_renova', NULL,
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
         p_tab_error(f_sysdate, f_user, 'Pac_Ref_Simula_Rentas.f_valida_duracion_renova',
                     NULL,
                     'parametros: pnpoliza=' || pnpoliza || ' pncertif=' || pncertif
                     || ' pndurper=' || pndurper,
                     SQLERRM);
         RETURN NULL;
   END f_valida_duracion_renova;

   FUNCTION f_get_datos_revision(
      psseguro IN NUMBER,
      cidioma IN NUMBER,
      ocoderror OUT NUMBER,
      omsgerror OUT VARCHAR2)
      RETURN cursor_type IS
      /******************************************************************************************
       Lista con los datos basicos de la póliza
       . Parámetro de entrada:  psseguro = Identificador de la póliza
                                cidioma = idioma
      ******************************************************************************************/
      CURSOR cur_aseg IS
         SELECT ROWNUM, sperson, cdomici
           FROM asegurados
          WHERE sseguro = psseguro;

      CURSOR interes IS   --JRH IMP Falta el tema del LRC y el capital
         SELECT pinttec
           FROM intertecseg a
          WHERE a.sseguro = psseguro
            AND a.nmovimi = (SELECT MAX(b.nmovimi)
                               FROM intertecseg b
                              WHERE b.sseguro = a.sseguro);

      sperson1       NUMBER;
      cdomici1       NUMBER;
      sperson2       NUMBER;
      cdomici2       NUMBER;
      pinttec        NUMBER;
      capital_vto_actual NUMBER := 0;
      --Retorno
      v_cursor       cursor_type;
   BEGIN
      FOR regs IN cur_aseg LOOP
         IF regs.ROWNUM = 1 THEN
            sperson1 := regs.sperson;
            cdomici1 := regs.cdomici;
         ELSIF regs.ROWNUM = 2 THEN
            sperson2 := regs.sperson;
            cdomici2 := regs.cdomici;
         END IF;
      END LOOP;

      OPEN interes;

      FETCH interes
       INTO pinttec;

      CLOSE interes;

      OPEN v_cursor FOR
         SELECT sproduc, cramo, cmodali, ctipseg, ccolect, npoliza, ncertif, cidioma, csituac,
                fefecto, sperson1, sperson2, capital_vto_actual, pinttec
           FROM seguros
          WHERE sseguro = psseguro;

      RETURN v_cursor;
   EXCEPTION
      WHEN OTHERS THEN
         -- BUG -21546_108724- 06/02/2012 - JLTS - Cierre de posibles cursores abiertos
         IF interes%ISOPEN THEN
            CLOSE interes;
         END IF;

         p_tab_error(f_sysdate, f_user, 'Pac_Ref_Simula_Rentas.f_get_datos_revision', NULL,
                     'parametros: psseguro=' || psseguro || ' cidioma=' || cidioma, SQLERRM);
         ocoderror := 108190;   -- Error General
         omsgerror := f_axis_literales(ocoderror, cidioma);

         IF v_cursor%ISOPEN THEN
            CLOSE v_cursor;
         END IF;

         RETURN v_cursor;
   END f_get_datos_revision;

   FUNCTION f_simulacion_rentas(
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
      pfoper IN DATE,
      pctrcap IN NUMBER,
      pcagente IN NUMBER,
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      valtashi IN NUMBER,
      pcttashi IN NUMBER,
      capdisphi IN NUMBER,
      fecoperhi IN DATE,
      pctreversrtrvd IN NUMBER,
      rentpercrt IN NUMBER,
      forpagorenta IN NUMBER,
      pintec IN NUMBER DEFAULT NULL)
      RETURN ob_resp_simula_rentas IS
      /**********************************************************************************************************************************
         F_SIMULACION_rentas: función para simular la contratación de pólizas de prima única (EUROPLAZO16, EUROTERM16,
                                                       y AHORRO SEGURO
        2-1-2007. CSI
        Vida Ahorro

        La función retornará  un objeto de tipo ob_resp_simula_rentas con los datos de los valores garantizados y el error
        (si se ha producido)
        ptipo: 1 .- Alta
               2.- Revisión
        Si ptipo =2 (revisión) los parámetros pnpoliza y pncertif deben venir informados
      **********************************************************************************************************************************/
      v_ob_resp_simula_rentas ob_resp_simula_rentas;
      v_t_det_simula_rentas t_det_simula_rentas := t_det_simula_rentas();
      v_ob_det_simula_rentas ob_det_simula_rentas;
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
      fvencim        DATE;
      v_traza        tab_error.ntraza%TYPE;
      error          EXCEPTION;
      ocoderror      NUMBER;
      omsgerror      VARCHAR2(1000);
      regprren       producto_ren%ROWTYPE;
      v_garant       NUMBER;
      v_ctipgar      NUMBER;

      CURSOR durprod(prod IN NUMBER, fecefec IN DATE) IS   --Duracions/Períodes permesos per un producte
         SELECT ndurper
           FROM durperiodoprod
          WHERE sproduc = prod
            AND finicio <= fecefec
            AND(ffin >= fecefec
                OR ffin IS NULL);

      pforpagorenta  NUMBER;
      existedur      BOOLEAN := FALSE;
      dur            NUMBER;
   BEGIN
      v_traza := 1;

 -- --------------------------------------------------------------
-- Validamos que los parámetros obligatorios vengan informados --
-- --------------------------------------------------------------
      IF (ptipo IS NULL) THEN
         v_errores := ob_errores(-999, 'f_simulacion_rentas: Param PTIPO is null');
         RAISE error;
      END IF;

      IF (psproduc IS NULL) THEN
         v_errores := ob_errores(-999, 'f_simulacion_rentas: Param PSPRODUC is null');
         RAISE error;
      END IF;

      IF (ptapelli1 IS NULL
          OR pnombre1 IS NULL) THEN
         v_errores := ob_errores(-999, 'f_simulacion_rentas: Param PNOMBRE1 is null');
         RAISE error;
      END IF;

      IF pfnacimi1 IS NULL THEN
         v_errores := ob_errores(-999, 'f_simulacion_rentas: Param PFNACIMI1 is null');
         RAISE error;
      END IF;

      IF psexo1 IS NULL THEN
         v_errores := ob_errores(-999, 'f_simulacion_rentas: Param PSEXO1 is null');
         RAISE error;
      END IF;

      IF pcpais1 IS NULL THEN
         v_errores := ob_errores(-999, 'f_simulacion_rentas: Param PCPAIS1 is null');
         RAISE error;
      END IF;

      IF (pnombre2 IS NOT NULL
          OR ptapelli2 IS NOT NULL)
         AND(pfnacimi2 IS NULL
             OR psexo2 IS NULL
             OR pcpais2 IS NULL) THEN
         v_errores :=
              ob_errores(-999, 'f_simulacion_rentas: Faltan parametros del segundo asegurado');
         RAISE error;
      END IF;

      IF NVL(f_parproductos_v(psproduc, 'HIPOTECA_INVERSA'), 0) <> 1 THEN   --En el cas de hipoteca inversa no es valida la prima
         IF rentpercrt IS NULL THEN
            IF ptipo <> 2 THEN
               IF piprima IS NULL THEN
                  v_errores := ob_errores(-999, 'f_simulacion_rentas: Param PPRIMA is null');
                  RAISE error;
               END IF;
            END IF;
         END IF;
      END IF;

      IF ptipo = 2
         AND(pnpoliza IS NULL
             OR pncertif IS NULL) THEN
         v_errores := ob_errores(-999, 'f_simulacion_rentas: Param PNPOLIZA-PNCERTIF is null');
         RAISE error;
      END IF;

      /*IF  pfvencim is null THEN
         v_errores := ob_errores(-999, 'f_simulacion_rentas: Param fecoper is null');
         RAISE ERROR;
      END IF;*/

      /*IF NVL(f_parproductos_v(psproduc, 'DURPER'),0) <> 1  AND pfvencim is null THEN
             v_errores := ob_errores(-999, 'f_simulacion_rentas: Param PFVENCIM is null');
           RAISE ERROR;
        END IF;
      */
      IF TRUNC(pfoper) < TRUNC(f_sysdate) THEN
         v_errores :=
               ob_errores(-999, 'f_simulacion_rentas: Fecha operación inferior al día actual');
         RAISE error;
      END IF;

      IF forpagorenta IS NULL THEN
         SELECT cforpag
           INTO pforpagorenta
           FROM forpagren
          WHERE sproduc = psproduc;
      ELSE
         pforpagorenta := forpagorenta;
      END IF;

      BEGIN
         SELECT *
           INTO regprren
           FROM producto_ren
          WHERE sproduc = psproduc;
      EXCEPTION
         WHEN OTHERS THEN
            v_errores := ob_errores(180585, f_axis_literales(180585, pcidioma_user));   -- Error al leer de SEGUROS_AHO
            RAISE error;
      END;

      IF ptipo = 2 THEN   --JRH 0372008 Validamos si la póliza puede simular la revisión
         num_err := pac_ref_simula_aho.f_valida_poliza_renova(pnpoliza, pncertif,
                                                              pcidioma_user, ocoderror,
                                                              omsgerror);

         IF num_err IS NULL THEN
            v_errores := ob_errores(ocoderror, omsgerror);
            RAISE error;
         END IF;
      END IF;

      /*if nvl(regPrRen.cligact,0) = 1 then ---Renta HI
         if ((valTasHI IS NULL) OR (pctTasHI IS NULL) OR (capDispHI IS NULL)) then
                     v_errores := ob_errores(-999, 'f_simulacion_rentas: Param pctTasHI o capDispHI o valTasHI is null');
                     RAISE ERROR;
         end if;
      end if;*/

      /*IF NVL(f_parproductos_v(psproduc,'ES_PRODUCTO_AHO'),0) = 1 THEN -- es un producto de ahorro RVD
        if ((pctReversRTRVD IS NULL) OR (pctRevaliRVD IS NULL) OR (ppinttec IS NULL)) then
                     v_errores := ob_errores(-999, 'f_simulacion_rentas: Param pctReversRTRVD o pctRevaliRVD o ppinttec is null');
                     RAISE ERROR;
         end if;
      END IF;*/

      --v_garant := pac_calc_comu.f_cod_garantia(psproduc, 3, NULL,v_ctipgar);

      /*if v_garant is not null then --Si hay garantía de fallecimiento se debe informar el pct
  if (pctrcap IS NULL) then
               v_errores := ob_errores(-999, 'f_simulacion_rentas: Param pctrcap is null');
               RAISE ERROR;
   end if;
end if;*/
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
-- Si ptipo = 1 (Alta), la fecha de efecto es F_SYSDATE, si ptipo = 2 (Renovacion), la fecha de efecto es la fecha --
-- de revisión
-------------------------------------------------------------------------------------------------------------------
      v_traza := 5;

      IF ptipo = 1 THEN
         v_fefecto := pfoper;
      ELSE   -- ptipo = 2 THEN
         v_fefecto := v_frevisio;
      END IF;

      OPEN durprod(psproduc, v_fefecto);

      FETCH durprod
       INTO dur;

      IF durprod%FOUND THEN
         existedur := TRUE;
      END IF;

      CLOSE durprod;

----------------------------------------
-- Validamos los datos: edad, etc...  --
----------------------------------------
      IF NVL(regprren.cclaren, 0) <> 0 THEN   ---Rentas temporales, periodo informado, reversion
         IF NVL(f_parproductos_v(psproduc, 'FECHAREV'), 0) <> 3 THEN   --Si no renueva al año se ha de informar renovación.
            IF (pndurper IS NULL) THEN
               IF NOT(existedur) THEN   -- Si no existen varias duraciones
                  v_errores := ob_errores(180586, f_axis_literales(180586, pcidioma_user));
                  RAISE error;
               END IF;
            END IF;
         END IF;

         IF (pctreversrtrvd IS NULL) THEN
            v_errores := ob_errores(180587, f_axis_literales(180587, pcidioma_user));
            RAISE error;
         END IF;
      END IF;

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
      v_garant := pac_calc_comu.f_cod_garantia(psproduc, 3, NULL, v_ctipgar);

      IF (v_garant IS NULL) THEN
         v_errores := ob_errores(180588, f_axis_literales(180588, pcidioma_user));
         RAISE error;
      END IF;

      num_err := f_valida_prima_rentas(ptipo, psproduc, 0, v_garant, piprima, 0, psperson1,
                                       pcpais1, pcidioma_user, pctrcap, valtashi, pcttashi,
                                       capdisphi, pctreversrtrvd, fecoperhi, pforpagorenta,
                                       ocoderror, omsgerror);

      IF num_err IS NULL THEN
         v_errores := ob_errores(ocoderror, omsgerror);
         RAISE error;
      END IF;

----------------------------------------
-- Validamos la duración              --
----------------------------------------
  -- MSR 3/7/2007. Incluore Ahorro Seguro / PE / PPA
      IF NVL(f_parproductos_v(psproduc, 'DURPER'), 0) = 1 THEN   -- Producto Europlazo 16 o Euroterm 16
         IF NOT(existedur)
            OR NVL(pndurper, 0) <> 0 THEN   --Si existen duraciones no hemos de hacer nada porque se simulan para todas ellas, a no ser que escojamos una.
            IF ptipo = 1 THEN   -- Alta
               v_traza := 8;
               num_err := pac_val_comu.f_valida_duracion(psproduc, pfnacimi1, v_fefecto,
                                                         pndurper, fvencim);

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
         END IF;
      ELSE   -- Ahorro Seguro, PE, PPA
         v_traza := 10;
         v_nduraci := pndurper;
         --v_fvencim := pfvencim;
         num_err := pac_calc_comu.f_calcula_fvencim_nduraci(psproduc, pfnacimi1, v_fefecto,
                                                            NULL, v_nduraci, fvencim);

         IF num_err <> 0 THEN
            v_errores := ob_errores(num_err, f_axis_literales(num_err, pcidioma_user));
            RAISE error;
         END IF;
      END IF;

 -----------
-------------------------------------------------
-- Si todo es correcto generamos la solicitud y tarifamos --
------------------------------------------------------------
      v_traza := 11;
      num_err := pac_simul_rentas.f_genera_sim_rentas(ptipo, psproduc, pnombre1, ptapelli1,
                                                      pfnacimi1, psexo1, pnombre2, ptapelli2,
                                                      pfnacimi2, psexo2, piprima, pndurper,
                                                      pfoper,
                                                      /*ppinttec*/
                                                      pctrcap, valtashi, pcttashi, capdisphi,
                                                      pctreversrtrvd, fecoperhi, rentpercrt,
                                                      v_sseguro, v_fefecto, fvencim,
                                                      pforpagorenta, v_ssolicit, pintec);

      IF num_err <> 0 THEN
         v_errores := ob_errores(num_err, f_axis_literales(num_err, pcidioma_user));
         RAISE error;
      END IF;

 ---------------------------
-- Devolvemos los datos  --
---------------------------
      v_traza := 12;
      /*IF NVL(f_parproductos_v(psproduc, 'EVOLUPROVMATSEG'),0) = 1  THEN
        -- Agafa dels que han desat les dades a SOLEVOLUPROVMATSEG
            v_t_det_simula_rentas := pac_simul_rentas.f_get_evoluprovmat(v_ssolicit, pndurper, v_nanyos_transcurridos, num_err);
            IF num_err <> 0 THEN
             v_errores := ob_errores(num_err, f_axis_literales(num_err, pcidioma_user));
             RAISE ERROR;
         END IF;

        v_traza := 13;
           ncontador := 0;
         vcapvenci := NULL;
       prendimiento := NULL;

            ncontador := v_t_det_simula_rentas.COUNT;

            IF ncontador <> 0 THEN
            IF ptipo = 1 THEN -- Alta
            vcapndurper := v_t_det_simula_rentas(ncontador).rentamensual; --JRH ?
                prendimiento := Round(((POWER ((vcapndurper/piprima), (1/pndurper)) - 1) * 100),2);
            ELSE
                null; -- Falta añadir la función del rendimiento en la Renovación
            END IF;
            END IF;

        v_traza := 14;
         --JRH  vcapvenci := pac_calc_comu.ff_Capital_Gar_Tipo('SOL', v_ssolicit, 1, 5, 1);

            vcapvenci := pac_calc_rentas.ff_Capital_Gar_Tipo_Renta('SOL', v_ssolicit, 1, null, 1);

            IF vcapvenci IS NULL THEN
            v_errores := ob_errores(153052, f_axis_literales(153052, pcidioma_user));  -- Error al buscar el capital de la garantía
            RAISE ERROR;
            END IF;


      ELSE
         */-- va aariba del excel !! JRH  v_ob_resp_simula_rentas := ob_resp_simula_rentas(v_ssolicit, v_t_det_simula_rentas, piprima, 0 /*retIRPF*/,0 /*pctretIRPF*/,0 /*rentaneta*/,0 /*durCCRHI*/,0 /*primrentHI*/,0 /*comisapertHI*/,0 /*gastnotHI*/,0 /*gastgestionHI*/,0 /*impuajdHI*/,v_errores);
        -- Agafa dels que NO han desat les dades a SOLEVOLUPROVMATSEG
      v_ob_resp_simula_rentas := pac_simul_rentas.f_get_dades_calculades(ptipo, psproduc,
                                                                         v_ssolicit, v_fefecto,
                                                                         piprima,
                                                                         pcidioma_user,
                                                                         fvencim, pfnacimi1,
                                                                         pndurper, pcpais1,
                                                                         num_err, pintec);

      IF num_err <> 0 THEN
         v_errores := ob_errores(num_err, f_axis_literales(num_err, pcidioma_user));
         RAISE error;
      END IF;

-- END IF;
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
      RETURN v_ob_resp_simula_rentas;
   EXCEPTION
      WHEN error THEN
         v_ob_det_simula_rentas := NULL;
         v_t_det_simula_rentas.DELETE;
         v_ob_resp_simula_rentas := ob_resp_simula_rentas(v_ssolicit, v_t_det_simula_rentas,
                                                          NULL, NULL /*pctretIRPF*/,
                                                          NULL /*durCCRHI*/,
                                                          NULL /*primrentHI*/,
                                                          NULL /*comisapertHI*/,
                                                          NULL /*gastnotHI*/,
                                                          NULL /*gastgestionHI*/,
                                                          NULL /*impuajdHI*/,
                                                          NULL /*gatostasacionHI*/,
                                                          NULL /*gatosgestHI*/,
                                                          NULL /*deudacumHI*/, NULL /*TAE*/,
                                                          NULL /*tramoA*/, NULL /*tramoB*/,
                                                          NULL /*tramoC*/,
                                                          NULL /*fechaulttrasp*/,
                                                          NULL /*fechaInicioRenta*/,
                                                          v_errores);
         ROLLBACK;
         RETURN v_ob_resp_simula_rentas;
      WHEN OTHERS THEN
         -- BUG -21546_108724- 06/02/2012 - JLTS - Cierre de posibles cursores abiertos
         IF durprod%ISOPEN THEN
            CLOSE durprod;
         END IF;

         v_ob_det_simula_rentas := NULL;
         v_t_det_simula_rentas.DELETE;
         v_errores := ob_errores(-999,
                                 'Pac_Ref_Simula_Rentas.f_simulacion_rentas: '
                                 || f_axis_literales(108190, pcidioma));   -- Error General
         v_ob_resp_simula_rentas := ob_resp_simula_rentas(v_ssolicit, v_t_det_simula_rentas,
                                                          NULL, NULL /*pctretIRPF*/,
                                                          NULL /*durCCRHI*/,
                                                          NULL /*primrentHI*/,
                                                          NULL /*comisapertHI*/,
                                                          NULL /*gastnotHI*/,
                                                          NULL /*gastgestionHI*/,
                                                          NULL /*impuajdHI*/,
                                                          NULL /*gatostasacionHI*/,
                                                          NULL /*gatosgestnHI*/,
                                                          NULL /*deudacumHI*/, NULL /*TAE*/,
                                                          NULL /*tramoA*/, NULL /*tramoB*/,
                                                          NULL /*tramoC*/,
                                                          NULL /*fechaulttrasp*/,
                                                          NULL /*fechaInicioRenta*/, v_errores);
         ROLLBACK;
         p_tab_error(f_sysdate, f_user, 'Pac_Ref_Simula_Rentas.f_simulacion_rentas', v_traza,
                     'f_simulacion_rentas', SQLERRM);
         RETURN v_ob_resp_simula_rentas;
   END f_simulacion_rentas;
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
--    piPrima                 Import de la prima inicial. Mínim 30¿.
--    piPeriodico             Aportació periòdica. Mínim 30¿.
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
  /*
  FUNCTION f_simulacion_PP( psproduc IN NUMBER,
                            pcagente IN NUMBER, pcidioma_user IN NUMBER DEFAULT 1,
                            -- Persona 1
                            psPerson1      IN PERSONAS.SPERSON%TYPE,
                            ptNombre1      IN PERSONAS.TNOMBRE%TYPE,
                            ptApellido1    IN PERSONAS.TAPELLI%TYPE,
                            pfNacimiento1  IN PERSONAS.FNACIMI%TYPE,
                            pcSexo1        IN PERSONAS.CSEXPER%TYPE,
                            pcPais1        IN PERSONAS.CPAIS%TYPE,
                            pcIdioma       IN PERSONAS.CIDIOMA%TYPE,
                            -- Persona 2
                            psPerson2      IN PERSONAS.SPERSON%TYPE,
                            ptNombre2      IN PERSONAS.TNOMBRE%TYPE,
                            ptApellido2    IN PERSONAS.TAPELLI%TYPE,
                            pfNacimiento2  IN PERSONAS.FNACIMI%TYPE,
                            pcSexo2        IN PERSONAS.CSEXPER%TYPE,
                            pcPais2        IN PERSONAS.CPAIS%TYPE,
                            -- Otros
                            pfvencim IN DATE,
                            -- Aportaciones
                            piprima IN NUMBER, piperiodico IN NUMBER,
                            ppinteres IN NUMBER, pprevalorizacion IN NUMBER,
                            -- Prestaciones
                            ppinteres_pres IN NUMBER, pprevalorizacion_pres IN NUMBER DEFAULT NULL,
                            ppreversion_pres IN NUMBER DEFAULT NULL, panosrenta_pres IN NUMBER DEFAULT NULL
                            )
    RETURN ob_resp_simula_pp IS
     v_ob_resp_simula_pp ob_resp_simula_pp;
     v_t_det_simula_pp   t_det_simula_pp := t_det_simula_pp();
     v_ob_det_simula_pp  ob_det_simula_pp;
     v_errores           ob_errores;

     num_err       NUMBER;
     v_sseguro     NUMBER;
     v_fefecto     DATE;
     v_traza        TAB_ERROR.NTRAZA%TYPE;
     v_cidioma_user PERSONAS.CIDIOMA%TYPE;
     v_anys      NUMBER;

     exError   EXCEPTION;
     ocoderror           NUMBER;
     omsgerror           VARCHAR2(1000);

     vPlaPensions   BOOLEAN;    -- A TRUE quan som dins el procés d'un Pla de Pensions

    -- Cridar per comprobacions que els paràmetres són passats correctament
    PROCEDURE Assegura(pCondicio IN BOOLEAN, pTextError IN VARCHAR2) IS
    BEGIN
      IF NOT pCondicio THEN
        v_errores := ob_errores(-999,  pTextError);
        RAISE exError;
      END IF;
    END;
  BEGIN
    v_traza := 1;

    -- --------------------------------------------------------------
    -- Detectem si el producte es un Pla de Pensions o un PE / PPA
    -- --------------------------------------------------------------
    FOR rProducto IN (SELECT cagrpro FROM productos WHERE sproduc = psProduc) LOOP
      -- Els plans de pensions tenen cagrpro = 11
      vPlaPensions := ( rProducto.cagrpro = 11 );
    END LOOP;

    -- --------------------------------------------------------------
    -- Validamos que los parámetros obligatorios vengan informados --
    -- --------------------------------------------------------------
    Assegura ( psproduc IS NOT NULL, 'Pac_Ref_Simula_Rentas.f_simulacion_pp: Param PSPRODUC is null');
    Assegura( ptapellido1 IS NOT NULL AND ptnombre1 IS NOT NULL, 'Pac_Ref_Simula_Rentas.f_simulacion_pp: Persona 1 Param NOMBRE / APELLIDO is null');
    Assegura( pfnacimiento1 IS NOT NULL, 'Pac_Ref_Simula_Rentas.f_simulacion_pp: Persona 1 Param FNACIMIENTO is null');
    Assegura( pcsexo1 IS NOT NULL, 'Pac_Ref_Simula_Rentas.f_simulacion_pp: Persona 1 Param CSEXO is null');
    Assegura( pcpais1 IS NOT NULL, 'Pac_Ref_Simula_Rentas.f_simulacion_pp: Persona 1 Param CPAIS is null');

    IF (ptnombre2 IS NOT NULL OR ptapellido2 IS NOT NULL OR pfnacimiento2 IS NOT NULL OR pcsexo2 IS NOT NULL OR pcpais2 IS NOT NULL) THEN
      Assegura( ptapellido2 IS NOT NULL AND ptnombre2 IS NOT NULL, 'Pac_Ref_Simula_Rentas.f_simulacion_pp: Persona 2 Param NOMBRE / APELLIDO is null');
      Assegura( pfnacimiento2 IS NOT NULL, 'Pac_Ref_Simula_Rentas.f_simulacion_pp: Persona 2 Param FNACIMIENTO is null');
      Assegura( pcsexo2 IS NOT NULL, 'Pac_Ref_Simula_Rentas.f_simulacion_pp: Persona 2 Param CSEXO is null');
      Assegura( pcpais2 IS NOT NULL, 'Pac_Ref_Simula_Rentas.f_simulacion_pp: Persona 2 Param CPAIS is null');
    END IF;

    Assegura( piprima IS NOT NULL, 'Pac_Ref_Simula_Rentas.f_simulacion_pp: Param PPRIMA is null');
    Assegura( pfvencim is NOT null , 'Pac_Ref_Simula_Rentas.f_simulacion_pp: Param PFVENCIM is null');
    Assegura( ppinteres IS NOT NULL, 'Pac_Ref_Simula_Rentas.f_simulacion_pp: Param PPINTERES is null');
    Assegura( piperiodico IS NOT NULL, 'Pac_Ref_Simula_Rentas.f_simulacion_pp: Param PIPERIODICO is null');
    Assegura( pprevalorizacion IS NOT NULL, 'Pac_Ref_Simula_Rentas.f_simulacion_pp: Param PPREVALORIZACION is null');
    Assegura( ppinteres_pres IS NOT NULL, 'Pac_Ref_Simula_Rentas.f_simulacion_pp: Param PPINTERES_PRES is null');

    IF vPlaPensions THEN
        Assegura( pprevalorizacion_pres IS NOT NULL, 'Pac_Ref_Simula_Rentas.f_simulacion_pp: Param PPREVALORIZACION_PRES is null');
        Assegura( ppreversion_pres IS NOT NULL, 'Pac_Ref_Simula_Rentas.f_simulacion_pp: Param PPREVERSION_PRES is null');
        Assegura( panosrenta_pres IS NOT NULL, 'Pac_Ref_Simula_Rentas.f_simulacion_pp: Param PANOSRENTA_PRES is null');
    END IF;

    -- Inicializamos la variable v_cidioma_user
    v_cidioma_user := NVL(pcidioma_user, pcidioma);

    -- Se valida que el idioma esté informado
    v_traza := 2;
    num_err := Pac_Val_Comu.F_VALIDA_IDIOMA(v_cidioma_user);
    IF num_err <> 0 THEN
       v_errores := ob_errores(num_err, f_axis_literales(num_err, pcidioma));
       RAISE exError;
    END IF;

    -------------------------------------------------------------------------------------------------------------------
    -- Data d'efecte
    -------------------------------------------------------------------------------------------------------------------
    v_traza := 5;
    v_fefecto := trunc(f_sysdate);

    ----------------------------------------
    -- Validamos los datos: edad, etc...  --
    ----------------------------------------
    v_traza := 6;
     num_err := pac_ref_simula_comu.f_valida_asegurados(psproduc,
                                                    psperson1, pfnacimiento1, pcsexo1, pcpais1,
                                                    psperson2, pfnacimiento2, pcsexo2, pcpais2,
                                                    v_fefecto, null, null, 0, pcidioma,
                                                    oCODERROR, oMSGERROR);
     IF num_err IS NULL THEN
        v_errores := ob_errores(oCODERROR, oMSGERROR);
        RAISE exError;
     END IF;

     ----------------------------------------
     -- Validamos la prima inicial       --
     ----------------------------------------
     v_traza := 8;
     num_err := f_valida_prima_rentas(1, psproduc, 0, 282, piprima, 0, psperson1, pcpais1, pcidioma,
                                   oCODERROR, oMSGERROR);
     IF num_err IS NULL THEN
        v_errores := ob_errores(oCODERROR, oMSGERROR);
        RAISE exError;
     END IF;

     ----------------------------------------
     -- Validamos la prima periodica       --
     ----------------------------------------
     v_traza := 9;
     num_err := f_valida_prima_rentas(1, psproduc, 0, 48, piperiodico, 0, psperson1, pcpais1, pcidioma,
                                   oCODERROR, oMSGERROR);
     IF num_err IS NULL THEN
        v_errores := ob_errores(oCODERROR, oMSGERROR);
        RAISE exError;
     END IF;

     ---------------------------------------------------
     -- Validamos la prima inicial vs. periodica      --
     ---------------------------------------------------
     v_traza := 7;
     IF piprima < piperiodico THEN
        v_errores := ob_errores(180432, f_axis_literales(180432, pcidioma));
        RAISE exError;
     END IF;

     ----------------------------------------
     -- Validamos la edad                  --
     ----------------------------------------
     v_traza := 10;
     num_err := pac_val_comu.f_valida_edad_prod( psproduc, v_fefecto, pfnacimiento1, pfnacimiento2);
     IF num_err <> 0 THEN
       v_errores := ob_errores(num_err, f_axis_literales(180430, pcidioma));
       RAISE exError;
      END IF;

-- Originalment al Forms hi havia això
--      num_err := F_DIFDATA ( pPersona1.fNacimiento, F_SYSDATE, 1, 1, v_anys );
--      IF num_err <> 0 THEN
--        v_errores := ob_errores(num_err, f_axis_literales(num_err, pcidioma));
--        RAISE exError;
--      END IF;
--      IF ( v_anys < 18 or (v_anys > 65 AND vPlaPensions)  ) THEN
--          v_errores := ob_errores(num_err, f_axis_literales(180430, pcidioma));
--          RAISE exError;
--      END IF;

     ------------------------------------------------------------
     -- Si todo es correcto generamos la solicitud y tarifamos --
     ------------------------------------------------------------
     v_traza := 11;
     num_err :=  pac_simul_rentas.f_genera_sim_pp(psproduc, v_sseguro,
                                                ptNombre1,
                                                ptApellido1,
                                                pfNacimiento1,
                                                pcSexo1,
                                                ptNombre2,
                                                ptApellido2,
                                                pfNacimiento2,
                                                pcSexo2,
                                                v_fefecto, pfvencim,
                                                piprima, piperiodico,
                                                ppinteres, pprevalorizacion,
                                                ppinteres_pres, pprevalorizacion_pres, ppreversion_pres, panosrenta_pres);
     IF num_err <> 0 THEN
        v_errores := ob_errores(num_err, f_axis_literales(num_err, pcidioma));
        RAISE exERROR;
     END IF;

      --------------------------------------------------------------------------------------------------------
      -- Agafa les dades de les taules SIMULAPP i DETSIMULAPP
      --------------------------------------------------------------------------------------------------------
      v_traza := 12;
      v_ob_resp_simula_pp := pac_simul_rentas.f_get_dades_pp(v_cidioma_user);
      IF v_ob_resp_simula_pp.errores IS NOT NULL THEN
        IF NVL(v_ob_resp_simula_pp.errores.cerror,0) <> 0 THEN
          v_errores := v_ob_resp_simula_pp.errores;
          RAISE exError;
        END IF;
      END IF;

      --------------------------------------------------------------------------------------------------------
      -- Se inserta un registro en SIMULAESTADIST para realizar estadísticas de las simulaciones realizadas --
      --------------------------------------------------------------------------------------------------------
      v_traza := 15;
      num_err := pac_simul_comu.f_ins_simulaestadist(pcagente, psproduc, 1);
      IF num_err <> 0 THEN
         v_errores := ob_errores(num_err, f_axis_literales(num_err, pcidioma));
         RAISE exError;
      END IF;

      --------------------
      -- Todo ha ido OK --
      --------------------
      Commit;
      RETURN v_ob_resp_simula_pp;

 EXCEPTION
    WHEN exError THEN
        v_t_det_simula_pp.DELETE;
        Rollback;
        RETURN OB_RESP_SIMULA_PP(v_t_det_simula_pp, NULL, NULL, NULL, NULL, NULL, v_errores );
     WHEN OTHERS THEN
        v_t_det_simula_pp.DELETE;
        v_errores := ob_errores(-999, 'Pac_Ref_Simula_Rentas.f_simulacion_pp: '||f_axis_literales(108190,pcidioma));  -- Error General
        Rollback;
        p_tab_error(f_sysdate,  F_USER,  'Pac_Ref_Simula_Rentas.f_simulacion_pp', v_traza, 'f_simulacion_pp',
                      SQLERRM
                     );
        RETURN OB_RESP_SIMULA_PP(v_t_det_simula_pp, NULL, NULL, NULL, NULL, NULL, v_errores );
  END;
  */
END pac_ref_simula_rentas;

/

  GRANT EXECUTE ON "AXIS"."PAC_REF_SIMULA_RENTAS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_REF_SIMULA_RENTAS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_REF_SIMULA_RENTAS" TO "PROGRAMADORESCSI";
