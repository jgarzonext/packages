--------------------------------------------------------
--  DDL for Package Body PAC_REF_CONTRATA_ULK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_REF_CONTRATA_ULK" AS
   /****************************************************************************
      NOMBRE:       pac_ref_contrata_ulk
      PROPÓSITO:  Funciones para la gestión de productos de ULK.

      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ----------------------------------
      2.0        12/02/2009   RSC             Adaptacion a colectivos multiples
                                              con certificados
      3.0        15/06/2009   JTS             Se modifica la llamada de cobro de recibo
   ****************************************************************************/
   FUNCTION f_valida_primas_ulk(
      psproduc IN NUMBER,
      psperson IN NUMBER,
      pfefecto IN DATE,
      prima_inicial IN NUMBER,
      prima_per IN NUMBER,
      prevali IN NUMBER,
      pcforpag IN NUMBER,
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

      -- Definimos funciones propias dentro de la función para averiguar el tipo de garantía y validar las garantias
      FUNCTION f_valida(
         ptipo IN NUMBER,
         psproduc IN NUMBER,
         pcactivi IN NUMBER,
         pcgarant IN NUMBER,
         picapital IN NUMBER,
         pcforpag IN NUMBER,
         psperson IN NUMBER,
         pcidioma_user IN NUMBER DEFAULT f_idiomauser,
         coderror OUT NUMBER,
         msgerror OUT VARCHAR2)
         RETURN NUMBER IS
         num_err        NUMBER;
         v_capmin       NUMBER;
         v_capmax       NUMBER;
      BEGIN
         num_err := pac_val_comu.f_valida_capital(ptipo, psproduc, pcactivi, pcgarant,
                                                  picapital, pcforpag, v_capmin, v_capmax);

         IF num_err = 151289 THEN   -- la prima no supera la prima mínima
            coderror := num_err;
            msgerror := F_AXIS_LITERALES(coderror, pcidioma_user) || ' ' || v_capmin;
            RETURN NULL;
         ELSIF num_err = 140601 THEN   -- Prima max:
            coderror := num_err;
            msgerror := F_AXIS_LITERALES(coderror, pcidioma_user) || ' ' || v_capmax;
            RETURN NULL;
         ELSIF num_err <> 0 THEN
            coderror := num_err;
            msgerror := F_AXIS_LITERALES(coderror, pcidioma_user);
            RETURN NULL;
         END IF;

         num_err := pac_val_comu.f_valida_capital_persona(ptipo, psproduc, pcactivi, pcgarant,
                                                          picapital, psperson, NULL);

         IF num_err <> 0 THEN
            coderror := num_err;
            msgerror := F_AXIS_LITERALES(coderror, pcidioma_user);
            RETURN NULL;
         END IF;

         RETURN 0;
      END f_valida;
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
         omsgerror := F_AXIS_LITERALES(ocoderror, pcidioma_user);
         RAISE error;
      ELSE
         v_capital := prima_per;
         num_err := f_valida(1, psproduc, 0, v_garant, v_capital, pcforpag, psperson,
                             pcidioma_user, ocoderror, omsgerror);

         IF num_err IS NULL THEN
            RAISE error;
         END IF;
      END IF;

-------------------------------------------------------------------------------------------------------
-- Validamos las prima inicial
-------------------------------------------------------------------------------------------------------
      v_garant := pac_calc_comu.f_cod_garantia(psproduc, 4, NULL, v_ctipgar);

      IF v_garant IS NOT NULL THEN   -- en el producto hay prima inicial
         IF prima_inicial IS NULL THEN   -- si la garantía es obligatoria y no viene informado el capital
            ocoderror := 180189;   -- Prima inicial obligatoria
            omsgerror := F_AXIS_LITERALES(ocoderror, pcidioma_user);
            RAISE error;
         ELSE
            --IF f_usuario_cobro(pcagente, psproduc) = 1 THEN   -- Sí se puede realizar el cobro On_Line
            v_capital := prima_inicial;
            num_err := f_valida(1, psproduc, 0, v_garant, v_capital, pcforpag, psperson,
                                pcidioma_user, ocoderror, omsgerror);

            IF num_err IS NULL THEN
               RAISE error;
            END IF;
         /*ELSE
            IF prima_inicial <> 0 THEN
               ocoderror := 180389;   -- El usuario no permite cobro On-Line. La prima inicial debe ser 0.
               omsgerror := F_AXIS_LITERALES(ocoderror, pcidioma_user);
               RAISE error;
            END IF;
         END IF;*/
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
         ocoderror := -999;
         omsgerror :=
                     'Pac_Ref_Contrata_Ulk.f_valida_primas_index: Error general en la función';
         p_tab_error(f_sysdate, getuser, 'Pac_Ref_Contrata_Ulk.f_valida_primas_index', NULL,
                     'parametros: psproduc = ' || psproduc || '  psperson = ' || psperson
                     || '  pfefecto = ' || pfefecto,
                     SQLERRM);
         RETURN NULL;
   END f_valida_primas_ulk;

   FUNCTION f_valida_garantias_ulk(
      psproduc IN NUMBER,
      psperson1 IN NUMBER,
      psperson2 IN NUMBER,
      pfefecto IN DATE,
      prima_inicial IN NUMBER,
      prima_per IN NUMBER,
      prevali IN NUMBER,
      pcforpag IN NUMBER,
      pcagente IN NUMBER,
      pcidioma_user IN NUMBER DEFAULT f_idiomauser,
      ocoderror OUT NUMBER,
      omsgerror OUT VARCHAR2)
      RETURN NUMBER IS
      /************************************************************************************************************************************
         Función que valida los importes de primas y la revalorización
      *************************************************************************************************************************************/
      num_err        NUMBER;
   BEGIN
      num_err := pac_ref_contrata_aho.f_valida_garantias_aho(psproduc, psperson1, psperson2,
                                                             pfefecto, prima_inicial,
                                                             prima_per, prevali, pcforpag, 0,
                                                             0, 0, 0, pcagente, pcidioma_user,
                                                             ocoderror, omsgerror);
      RETURN num_err;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_valida_garantias_ulk;

   FUNCTION f_genera_poliza_ulk(
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
      ppcmodinv IN NUMBER,
      ppmodinv IN pac_ref_contrata_ulk.cartera,
      psclaben IN NUMBER,
      ptclaben IN VARCHAR2,
      prima_inicial IN NUMBER,
      prima_per IN NUMBER,
      prevali IN NUMBER,
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
        En esta función se grabará una póliza de indexados en las tablas EST con todos los datos y se tarifará. (previamente validamos
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
      v_estado_fondos VARCHAR2(1);
      v_ccobban      NUMBER;
      v_cramo        NUMBER;
      v_cmodali      NUMBER;
      v_ctipseg      NUMBER;
      v_ccolect      NUMBER;
      v_cagente      NUMBER;
      v_ncuenta      NUMBER;
      -- RSC 27/12/2007 -- Incidencia en emision pólizas Ibex 35 y Ibex 35 Garantizado
      vccodfon       NUMBER;
      vpinvers       NUMBER;
      vcmodinv       NUMBER;
      pcmodinv       NUMBER;
      v_cdelega      recibos.cdelega%TYPE;
      pmodinv        pac_ref_contrata_ulk.cartera;
   BEGIN
      -- 27/12/2007 (para no tocar demasiado código hago esta reasignación)
      pcmodinv := ppcmodinv;
      pmodinv := ppmodinv;
      -- La fecha de efecto debe estar truncada
      v_fefecto := TRUNC(pfefecto);

------------------------------------------------------------------------
-- Validamos el código del producto
------------------------------------------------------------------------
      IF psproduc IS NULL THEN
         ocoderror := 120149;   -- Es obligatorio introducir un producte
         omsgerror := F_AXIS_LITERALES(ocoderror, pcidioma_user);
         RAISE error;
      END IF;

------------------------------------------------------------------------
-- Validamos el Terminal
------------------------------------------------------------------------
      IF pterminal IS NULL THEN
         ocoderror := 180253;   -- Es obligatorio introducir el terminal
         omsgerror := F_AXIS_LITERALES(ocoderror, pcidioma_user);
         RAISE error;
      END IF;

------------------------------------------------------------------------
-- Validamos el código del agente
------------------------------------------------------------------------
      num_err := pac_val_comu.f_valida_agente(pcagente);

      IF num_err <> 0 THEN
         ocoderror := num_err;
         omsgerror := F_AXIS_LITERALES(num_err, pcidioma_user);
         RAISE error;
      END IF;

------------------------------------------------------------------------
-- Validamos la fecha de efecto
------------------------------------------------------------------------
      IF v_fefecto IS NULL THEN
         ocoderror := 104532;   -- Fecha efecto obligatoria
         omsgerror := F_AXIS_LITERALES(ocoderror, pcidioma_user);
         RAISE error;
      END IF;

------------------------------------------------------------------------
-- Validamos las cláusulas de beneficiario
------------------------------------------------------------------------
      num_err := pac_val_comu.f_valida_beneficiario(psproduc, psclaben, ptclaben);

      IF num_err <> 0 THEN
         ocoderror := num_err;
         omsgerror := F_AXIS_LITERALES(num_err, pcidioma_user);
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
         omsgerror := F_AXIS_LITERALES(ocoderror, pcidioma_user);
         RAISE error;
      END IF;

--------------------------------------------------------------------------
-- Validamos los datos de gestión
--------------------------------------------------------------------------
-- Se busca la fecha de nacimiento del sperson1
      num_err := f_persodat2(psperson1, v_csexo1, v_fnacimi1, v_cestado1, v_csujeto1, v_cpais1);

      IF num_err <> 0 THEN
         ocoderror := num_err;
         omsgerror := F_AXIS_LITERALES(num_err, pcidioma_user);
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
-- Validamos las primas
--------------------------------------------------------------------------
--num_err := Pac_Ref_Contrata_Ulk.f_valida_primas_index(psproduc, psperson1, v_fefecto, prima_inicial, prima_per, prevali, pcforpag,
--                               pcagente, pcidioma_user, ocoderror, omsgerror);
      num_err := pac_ref_contrata_ulk.f_valida_garantias_ulk(psproduc, psperson1, psperson2,
                                                             v_fefecto, prima_inicial,
                                                             prima_per, prevali, pcforpag,
                                                             pcagente, pcidioma_user,
                                                             ocoderror, omsgerror);

      IF num_err IS NULL THEN
         RAISE error;
      END IF;

------------------------------------------------------------------------
-- Validamos estado de todos los fondos del producto Unit Linked
------------------------------------------------------------------------
      num_err := pac_val_ulk.f_valida_ulk_abierto(NULL, psproduc, v_fefecto, pcidioma_user,
                                                  ocoderror, omsgerror);

      IF num_err IS NULL THEN
         RAISE error;
      END IF;

------------------------------------------------------------------------
-- Validamos el Modelo de inversión
------------------------------------------------------------------------
      IF NVL(f_parproductos_v(psproduc, 'USA_EDAD_CFALLAC'), 0) = 1 THEN   -- Ibex 35 y Ibex 35 Garantizado
         -- PARPRODUCTO : USA_EDAD_CFALLAC
         SELECT cramo, cmodali, ctipseg, ccolect
           INTO v_cramo, v_cmodali, v_ctipseg, v_ccolect
           FROM productos
          WHERE sproduc = psproduc;

         SELECT m.ccodfon, m.pinvers, m.cmodinv
           INTO vccodfon, vpinvers, vcmodinv
           FROM modinvfondo m, modelosinversion mo
          WHERE m.cramo = mo.cramo
            AND m.cmodali = mo.cmodali
            AND m.ctipseg = mo.ctipseg
            AND m.ccolect = mo.ccolect
            AND m.cramo = v_cramo
            AND m.cmodali = v_cmodali
            AND m.ctipseg = v_ctipseg
            AND m.ccolect = v_ccolect
            AND mo.ffin IS NULL;

         pcmodinv := vcmodinv;
         pmodinv(1) := vccodfon || '|' || vpinvers;   --'99|100';
      ELSE
         IF pcmodinv IS NULL THEN
            ocoderror := 180429;   -- Es obligatorio introducir el model de inversió associat
            omsgerror := F_AXIS_LITERALES(ocoderror, pcidioma_user);
            RAISE error;
         END IF;

         num_err := pac_val_ulk.f_valida_cartera(psproduc, pcmodinv, pmodinv, pcidioma_user,
                                                 ocoderror, omsgerror);

         IF num_err IS NULL THEN
            RAISE error;
         END IF;
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
      num_err := pac_prod_ulk.f_graba_propuesta_index(psproduc, psperson1, pcdomici1,
                                                      psperson2, pcdomici2, pcagente, pcidioma,
                                                      v_fefecto, pnduraci, pfvencim, pcforpag,
                                                      pcbancar, pcmodinv, pmodinv, psclaben,
                                                      ptclaben, prima_inicial, prima_per,
                                                      prevali, v_sseguro_est);

      IF num_err <> 0 THEN
         ocoderror := num_err;
         omsgerror := F_AXIS_LITERALES(num_err, pcidioma_user);
         RAISE error;
      END IF;

-----------------------------------------------------------------------------
-- Se graba que clausula de No Penalización No
-----------------------------------------------------------------------------
      num_err := pac_prod_comu.f_grabar_penalizacion(1, psproduc, v_sseguro_est, v_fefecto, 1,
                                                     'EST');

      IF num_err <> 0 THEN
         ocoderror := num_err;
         omsgerror := F_AXIS_LITERALES(num_err, pcidioma_user);
         RAISE error;
      END IF;

-----------------------------------------------------------------------------
-- Se graba la poliza
-----------------------------------------------------------------------------
      num_err := pac_prod_comu.f_grabar_alta_poliza(v_sseguro_est, psseguro);

      IF num_err <> 0 THEN
         ocoderror := num_err;
         omsgerror := F_AXIS_LITERALES(num_err, pcidioma_user);
         RAISE error;
      END IF;

-----------------------------------------------------------------------------
 -- Emitimos la propuesta
 ----------------------------------------------------------------------------
      num_err := pac_prod_comu.f_emite_propuesta(psseguro, vnpoliza, vncertif, v_nrecibo,
                                                 vnsolici);

      IF num_err <> 0 THEN
         ocoderror := num_err;
         omsgerror := F_AXIS_LITERALES(num_err, pcidioma_user);
         RAISE error;
      END IF;

---------------------------------
-- Se cobra el recibo en HOST
---------------------------------
      num_err := f_dessproduc(psproduc, 2, pcidioma_user, v_descsproduc);

      IF num_err <> 0 THEN
         ocoderror := num_err;
         omsgerror := F_AXIS_LITERALES(ocoderror, pcidioma_user);
         RAISE error;
      END IF;

      BEGIN
         SELECT itotalr
           INTO v_importe
           FROM vdetrecibos
          WHERE nrecibo = v_nrecibo;
      EXCEPTION
         WHEN OTHERS THEN
            ocoderror := 103936;   -- Recibo no encontrado en la tabla VDETRECIBOS
            omsgerror := F_AXIS_LITERALES(ocoderror, pcidioma_user);
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
            omsgerror := F_AXIS_LITERALES(ocoderror, pcidioma_user);
            RAISE error;
      END;

-------------------------------------------------------------------------
-- Se busca la cuenta donde se realizará el abono
      BEGIN
         SELECT cramo, cmodali, ctipseg, ccolect, cagente
           INTO v_cramo, v_cmodali, v_ctipseg, v_ccolect, v_cagente
           FROM seguros
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN OTHERS THEN
            ocoderror := 101919;   -- Error al leer datos de la tabla SEGUROS
            omsgerror := F_AXIS_LITERALES(ocoderror, pcidioma_user);
            RAISE error;
      END;

      v_ccobban := f_buscacobban(v_cramo, v_cmodali, v_ctipseg, v_ccolect, v_cagente,
                                 pcbancar_recibo, 1, num_err);

      IF v_ccobban IS NULL THEN
         ocoderror := num_err;
         omsgerror := F_AXIS_LITERALES(ocoderror, pcidioma_user);
         RAISE error;
      END IF;

      num_err := f_descuentacob(v_ccobban, v_ncuenta);

      IF num_err <> 0 THEN
         ocoderror := num_err;
         omsgerror := F_AXIS_LITERALES(ocoderror, pcidioma_user);
         RAISE error;
      END IF;

--------------------------------------------------------------------------
      v_recibo_cobrado := f_sg0carg(getuser, pterminal, LPAD(producto(1, psproduc), 8, '0'),
                                    f_empseguro(psseguro),   -- Codi empresa
                                    v_descsproduc, v_importe * 100, pfefecto, pcbancar_recibo,
                                    ff_buscanif(psperson1), LPAD(v_ncuenta, 20, 0),   --pcbancar_recibo
                                    1,   -- Tipus d'operació: 1.Alta
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
            omsgerror := F_AXIS_LITERALES(num_err, pcidioma_user);
            p_tab_error
                (f_sysdate, getuser,
                 F_AXIS_LITERALES(180848, pcidioma_user)
                 || ' (Pac_Ref_Contrata_Ulk.f_genera_poliza_ulk - Pac_Prod_Comu.f_cobro_recibo)',
                 NULL,
                 'Sseguro=' || psseguro || ', Error: ' || F_AXIS_LITERALES(num_err, pcidioma_user),
                 'psproduc=' || psproduc || ', psperson1=' || psperson1 || ', pcdomici1='
                 || pcdomici1 || ', psperson2=' || psperson2 || ', pcdomici2=' || pcdomici2
                 || ', pcagente=' || pcagente || ', pcidioma=' || pcidioma || ', pfefecto='
                 || pfefecto || ', pnduraci=' || pnduraci || ', pfvencim=' || pfvencim
                 || ', pcforpag=' || pcforpag || ', pcbancar=' || pcbancar || ', psclaben='
                 || psclaben || ', ptclaben=' || ptclaben || ', prima_inicial='
                 || prima_inicial || ', prima_per=' || prima_per || ', prevali=' || prevali
                 || ', pcbancar_recibo=' || pcbancar_recibo || ', pterminal=' || pterminal
                 || ', pcidioma_user=' || pcidioma_user);
            RAISE error;
         END IF;

         vcsituac := 0;   -- Vigente
      ELSE   -- No se ha podido cobrar el recibo en HOST
         RAISE error;
      END IF;

            /*ELSE   -- No se puede realizar el cobro On_Line
               -- Si la forma de pago es única
               IF pcforpag = 0 THEN
      -----------------------------------------------------------------------------
      -- Grabamos la propuesta y tarifamos
      ----------------------------------------------------------------------------
                  num_err := pac_prod_ulk.f_graba_propuesta_index(psproduc, psperson1, pcdomici1,
                                                                  psperson2, pcdomici2, pcagente,
                                                                  pcidioma, v_fefecto, pnduraci,
                                                                  pfvencim, pcforpag, pcbancar,
                                                                  pcmodinv, pmodinv, psclaben,
                                                                  ptclaben, prima_inicial,
                                                                  prima_per, prevali, v_sseguro_est);

                  IF num_err <> 0 THEN
                     ocoderror := num_err;
                     omsgerror := F_AXIS_LITERALES(num_err, pcidioma_user);
                     RAISE error;
                  END IF;

      -----------------------------------------------------------------------------
      -- Se graba la poliza
      -----------------------------------------------------------------------------
                  num_err := pac_prod_comu.f_grabar_alta_poliza(v_sseguro_est, psseguro);

                  IF num_err <> 0 THEN
                     ocoderror := num_err;
                     omsgerror := F_AXIS_LITERALES(num_err, pcidioma_user);
                     RAISE error;
                  END IF;

      -----------------------------------------------------------------------------
      -- Se retiene la póliza
      -----------------------------------------------------------------------------
                  num_err := pac_emision_mv.f_retener_poliza('SEG', psseguro, 1, 1, 4, 2, v_fefecto);

                  IF num_err <> 0 THEN
                     ocoderror := num_err;
                     omsgerror := F_AXIS_LITERALES(num_err, pcidioma_user);
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
                  num_err := pac_prod_ulk.f_graba_propuesta_index(psproduc, psperson1, pcdomici1,
                                                                  psperson2, pcdomici2, pcagente,
                                                                  pcidioma, v_fefecto, pnduraci,
                                                                  pfvencim, pcforpag, pcbancar,
                                                                  pcmodinv, pmodinv, psclaben,
                                                                  ptclaben, prima_inicial,
                                                                  prima_per, prevali, v_sseguro_est);

                  IF num_err <> 0 THEN
                     ocoderror := num_err;
                     omsgerror := F_AXIS_LITERALES(num_err, pcidioma_user);
                     RAISE error;
                  END IF;

      -----------------------------------------------------------------------------
      -- Se graba la poliza
      -----------------------------------------------------------------------------
                  num_err := pac_prod_comu.f_grabar_alta_poliza(v_sseguro_est, psseguro);

                  IF num_err <> 0 THEN
                     ocoderror := num_err;
                     omsgerror := F_AXIS_LITERALES(num_err, pcidioma_user);
                     RAISE error;
                  END IF;

      -----------------------------------------------------------------------------
      -- Emitimos la propuesta
        ----------------------------------------------------------------------------
                  num_err := pac_prod_comu.f_emite_propuesta(psseguro, vnpoliza, vncertif, v_nrecibo,
                                                             vnsolici);

                  IF num_err <> 0 THEN
                     ocoderror := num_err;
                     omsgerror := F_AXIS_LITERALES(num_err, pcidioma_user);
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
                  'Pac_Ref_Contrata_Ulk.f_genera_propuesta_index: Error general en la función';
         ROLLBACK;
         -- Se borran las tablas EST
         pac_alctr126.borrar_tablas_est(v_sseguro_est);
         COMMIT;
         RETURN -999;
   END f_genera_poliza_ulk;

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
   BEGIN
      num_err := pac_ref_contrata_aho.f_aportacion_extraordinaria(psseguro, pfefecto, pprima,
                                                                  pcbancar_recibo, poficina,
                                                                  pterminal, pcidioma_user,
                                                                  ocoderror, omsgerror);
      RETURN num_err;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_aportacion_extraordinaria;

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
   BEGIN
      num_err := pac_ref_contrata_aho.f_suplemento_aportacion_revali(psseguro, pfefecto,
                                                                     pcforpag, pprima,
                                                                     prevali, poficina,
                                                                     pterminal, pcidioma_user,
                                                                     ocoderror, omsgerror);

      IF num_err IS NULL THEN
         RETURN NULL;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_suplemento_aportacion_revali;

   FUNCTION f_suplemento_gastos(
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      pfefecto IN DATE,
      pcgasges IN NUMBER,
      pcgasred IN NUMBER,
      poficina IN VARCHAR2,
      pterminal IN VARCHAR2,
      pcidioma_user IN NUMBER DEFAULT f_idiomauser,
      ocoderror OUT NUMBER,
      omsgerror OUT VARCHAR2)
      RETURN NUMBER IS
      /********************************************************************************************************************************
         Función que graba el suplemento de cambio de gastos asociados a una póliza Unit Linked.

         La función retornará:
            0.- Si todo es correcto
            NULL -- si hay error o no se cumple alguan de las validaciones.
                    El código de error y el texto se informarán en los parámetros oCODERROR y oMSGERROR
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
      vcmotmov := 525;
      -- La fecha de efecto debe estar truncada
      v_fefecto := TRUNC(pfefecto);
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

--------------------------------------------------------------------------
-- Validamos que estén informados los datos del suplemento
--------------------------------------------------------------------------
      IF pnpoliza IS NULL
         OR pncertif IS NULL THEN
         ocoderror := 140896;   -- Se tiene que informar la poliza
         omsgerror := F_AXIS_LITERALES(ocoderror, pcidioma_user);
         RAISE error;
      END IF;

      IF v_fefecto IS NULL THEN
         ocoderror := 120077;   -- Falta informar la fecha efecto
         omsgerror := F_AXIS_LITERALES(ocoderror, pcidioma_user);
         RAISE error;
      END IF;

      IF pcgasges IS NULL
         AND pcgasred IS NULL THEN   -- si los dos son nulos
         ocoderror := 180481;   -- Es obligatorio introducir el domicilio
         omsgerror := F_AXIS_LITERALES(ocoderror, pcidioma_user);
         RAISE error;
      END IF;

      IF poficina IS NULL THEN
         ocoderror := 180252;   -- Es obligatorio introducir la oficina
         omsgerror := F_AXIS_LITERALES(ocoderror, pcidioma_user);
         RAISE error;
      END IF;

      IF pterminal IS NULL THEN
         ocoderror := 180253;   -- Es obligatorio introducir el terminal
         omsgerror := F_AXIS_LITERALES(ocoderror, pcidioma_user);
         RAISE error;
      END IF;

-------------------------------------------------------------------------------------------
-- Se traspasan los datos a las tablas EST y se dejan preparadas para hacer el suplemento
-------------------------------------------------------------------------------------------
      v_sseguro := ff_buscasseguro(pnpoliza, pncertif);
      num_err := pk_suplementos.f_inicializar_suplemento(v_sseguro, 'SUPLEMENTO', v_fefecto,
                                                         'BBDD', '*', vcmotmov, v_est_sseguro,
                                                         v_nmovimi);

      IF num_err <> 0 THEN
         ocoderror := num_err;
         omsgerror := F_AXIS_LITERALES(ocoderror, pcidioma_user);
         RAISE error_fin_supl;
      END IF;

-------------------------------------------------------------------------------------------
-- Se realiza la modificación del domicilio en las tablas EST
-------------------------------------------------------------------------------------------
      num_err := pac_prod_ulk.f_cambio_gastos(v_est_sseguro, pcgasges, pcgasred);

      IF num_err <> 0 THEN
         ocoderror := num_err;
         omsgerror := F_AXIS_LITERALES(ocoderror, pcidioma_user);
         RAISE error_fin_supl;
      END IF;

-------------------------------------------------------------------------------------------
-- Se valida que se haya realizado algún cambio
-------------------------------------------------------------------------------------------
      SELECT sproduc
        INTO v_sproduc
        FROM seguros
       WHERE sseguro = v_sseguro;

      num_err := pk_suplementos.f_validar_cambios(f_user, v_est_sseguro, v_nmovimi, v_sproduc,
                                                  'BBDD', 'SUPLEMENTO');

      IF num_err <> 0 THEN
         ocoderror := num_err;
         omsgerror := F_AXIS_LITERALES(ocoderror, pcidioma_user);
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
            omsgerror := F_AXIS_LITERALES(ocoderror, pcidioma_user);
            RAISE error_fin_supl;
      END;

      IF v_cont = 0 THEN   -- No ha habido ningún cambio
         ocoderror := 107804;   -- No se ha realizado ningún cambio
         omsgerror := F_AXIS_LITERALES(ocoderror, pcidioma_user);
         RAISE error_fin_supl;
      END IF;

-------------------------------------------------------------------------------------------
-- Se graba el suplemento en las tablas reales
-------------------------------------------------------------------------------------------
      num_err := pk_suplementos.f_grabar_suplemento_poliza(v_est_sseguro, v_nmovimi);

      IF num_err <> 0 THEN
         ocoderror := num_err;
         omsgerror := F_AXIS_LITERALES(ocoderror, pcidioma_user);
         RAISE error_fin_supl;
      END IF;

-------------------------------------------------------------------------------------------
-- Se emite el suplemento
-------------------------------------------------------------------------------------------
      num_err := pac_prod_comu.f_emite_propuesta(v_sseguro, v_npoliza, v_ncertif, v_nrecibo,
                                                 v_nsolici);

      IF num_err <> 0 THEN
         ocoderror := num_err;
         omsgerror := F_AXIS_LITERALES(ocoderror, pcidioma_user);
         RAISE error_fin_supl;
      END IF;

-------------------------------------------------------------------------------------------
-- Se envia correo a la oficina de gestión si corresponde
-------------------------------------------------------------------------------------------
      num_err := pac_avisos.f_accion(1, v_sseguro, 1, pcidioma_user, 'REAL', vcmotmov, 5,
                                     poficina, pterminal, v_nmovimi);

      IF num_err <> 0 THEN
         ocoderror := num_err;
         omsgerror := F_AXIS_LITERALES(ocoderror, pcidioma_user);
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
         omsgerror := 'Pac_Ref_Contrata_Ulk.f_suplemento_gastos: Error general en la función';
         ROLLBACK;
         p_tab_error(f_sysdate, getuser, 'Pac_Ref_Contrata_Ulk.f_suplemento_gastos', NULL,
                     'parametros: pnpoliza = ' || pnpoliza || ' pncertif =' || pncertif
                     || ' pcgasges = ' || pcgasges || ' pcgasred = ' || pcgasred
                     || ' poficina =' || poficina || ' pterminal =' || pterminal,
                     SQLERRM);
         num_err := pk_suplementos.f_final_suplemento(v_est_sseguro, v_nmovimi, v_sseguro);
         COMMIT;
         RETURN NULL;
   END f_suplemento_gastos;

   FUNCTION f_suplemento_minversion(
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      pfefecto IN DATE,
      pcmodinv IN NUMBER,
      pmodinv IN pac_ref_contrata_ulk.cartera,
      poficina IN VARCHAR2,
      pterminal IN VARCHAR2,
      pcidioma_user IN NUMBER DEFAULT f_idiomauser,
      ocoderror OUT NUMBER,
      omsgerror OUT VARCHAR2)
      RETURN NUMBER IS
      /********************************************************************************************************************************
         Función que graba el suplemento de cambio de gastos asociados a una póliza Unit Linked.

         La función retornará:
            0.- Si todo es correcto
            NULL -- si hay error o no se cumple alguan de las validaciones.
                    El código de error y el texto se informarán en los parámetros oCODERROR y oMSGERROR
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
      vcmotmov := 526;
      -- La fecha de efecto debe estar truncada
      v_fefecto := TRUNC(pfefecto);
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

--------------------------------------------------------------------------
-- Validamos que estén informados los datos del suplemento
--------------------------------------------------------------------------
      IF pnpoliza IS NULL
         OR pncertif IS NULL THEN
         ocoderror := 140896;   -- Se tiene que informar la poliza
         omsgerror := F_AXIS_LITERALES(ocoderror, pcidioma_user);
         RAISE error;
      END IF;

      IF v_fefecto IS NULL THEN
         ocoderror := 120077;   -- Falta informar la fecha efecto
         omsgerror := F_AXIS_LITERALES(ocoderror, pcidioma_user);
         RAISE error;
      END IF;

      IF pcmodinv IS NULL THEN   -- si los dos son nulos
         ocoderror := 180429;   -- Es obligatorio introducir el domicilio
         omsgerror := F_AXIS_LITERALES(ocoderror, pcidioma_user);
         RAISE error;
      END IF;

      v_sseguro := ff_buscasseguro(pnpoliza, pncertif);

      SELECT sproduc
        INTO v_sproduc
        FROM seguros
       WHERE sseguro = v_sseguro;

      IF pac_val_ulk.f_valida_cartera(v_sproduc, pcmodinv, pmodinv, pcidioma_user, ocoderror,
                                      omsgerror) IS NULL THEN
         RAISE error;
      END IF;

      IF poficina IS NULL THEN
         ocoderror := 180252;   -- Es obligatorio introducir la oficina
         omsgerror := F_AXIS_LITERALES(ocoderror, pcidioma_user);
         RAISE error;
      END IF;

      IF pterminal IS NULL THEN
         ocoderror := 180253;   -- Es obligatorio introducir el terminal
         omsgerror := F_AXIS_LITERALES(ocoderror, pcidioma_user);
         RAISE error;
      END IF;

-------------------------------------------------------------------------------------------
-- Se traspasan los datos a las tablas EST y se dejan preparadas para hacer el suplemento
-------------------------------------------------------------------------------------------
      num_err := pk_suplementos.f_inicializar_suplemento(v_sseguro, 'SUPLEMENTO', v_fefecto,
                                                         'BBDD', '*', vcmotmov, v_est_sseguro,
                                                         v_nmovimi);

      IF num_err <> 0 THEN
         ocoderror := num_err;
         omsgerror := F_AXIS_LITERALES(ocoderror, pcidioma_user);
         RAISE error_fin_supl;
      END IF;

-------------------------------------------------------------------------------------------
-- Se realiza la modificación del domicilio en las tablas EST
-------------------------------------------------------------------------------------------
      num_err := pac_prod_ulk.f_cambio_minversion(v_est_sseguro, pcmodinv, pmodinv);

      IF num_err <> 0 THEN
         ocoderror := num_err;
         omsgerror := F_AXIS_LITERALES(ocoderror, pcidioma_user);
         RAISE error_fin_supl;
      END IF;

-------------------------------------------------------------------------------------------
-- Se valida que se haya realizado algún cambio
-------------------------------------------------------------------------------------------
      num_err := pk_suplementos.f_validar_cambios(f_user, v_est_sseguro, v_nmovimi, v_sproduc,
                                                  'BBDD', 'SUPLEMENTO');

      IF num_err <> 0 THEN
         ocoderror := num_err;
         omsgerror := F_AXIS_LITERALES(ocoderror, pcidioma_user);
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
            omsgerror := F_AXIS_LITERALES(ocoderror, pcidioma_user);
            RAISE error_fin_supl;
      END;

      IF v_cont = 0 THEN   -- No ha habido ningún cambio
         ocoderror := 107804;   -- No se ha realizado ningún cambio
         omsgerror := F_AXIS_LITERALES(ocoderror, pcidioma_user);
         RAISE error_fin_supl;
      END IF;

-------------------------------------------------------------------------------------------
-- Se graba el suplemento en las tablas reales
-------------------------------------------------------------------------------------------
      num_err := pk_suplementos.f_grabar_suplemento_poliza(v_est_sseguro, v_nmovimi);

      IF num_err <> 0 THEN
         ocoderror := num_err;
         omsgerror := F_AXIS_LITERALES(ocoderror, pcidioma_user);
         RAISE error_fin_supl;
      END IF;

-------------------------------------------------------------------------------------------
-- Se genera las linea de redistribución en CTASEGURO
-------------------------------------------------------------------------------------------
--num_err := Pac_Prod_Ulk.f_generar_redistribucion(v_sseguro, pfefecto);
--IF num_err <> 0 THEN
--   oCODERROR := num_err;
   --   oMSGERROR := F_AXIS_LITERALES(oCODERROR, pcidioma_user);
--      RAISE error_fin_supl;
--   END IF;

      -------------------------------------------------------------------------------------------
-- Se emite el suplemento
-------------------------------------------------------------------------------------------
      num_err := pac_prod_comu.f_emite_propuesta(v_sseguro, v_npoliza, v_ncertif, v_nrecibo,
                                                 v_nsolici);

      IF num_err <> 0 THEN
         ocoderror := num_err;
         omsgerror := F_AXIS_LITERALES(ocoderror, pcidioma_user);
         RAISE error_fin_supl;
      END IF;

-------------------------------------------------------------------------------------------
-- Se envia correo a la oficina de gestión si corresponde
-------------------------------------------------------------------------------------------
      num_err := pac_avisos.f_accion(1, v_sseguro, 1, pcidioma_user, 'REAL', vcmotmov, 5,
                                     poficina, pterminal, v_nmovimi);

      IF num_err <> 0 THEN
         ocoderror := num_err;
         omsgerror := F_AXIS_LITERALES(ocoderror, pcidioma_user);
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
                   'Pac_Ref_Contrata_Ulk.f_suplemento_minversion: Error general en la función';
         ROLLBACK;
         p_tab_error(f_sysdate, getuser, 'Pac_Ref_Contrata_Ulk.f_suplemento_gastos', NULL,
                     'parametros: pnpoliza = ' || pnpoliza || ' pncertif =' || pncertif
                     || ' pcmodinv = ' || pcmodinv || ' poficina =' || poficina
                     || ' pterminal =' || pterminal,
                     SQLERRM);
         num_err := pk_suplementos.f_final_suplemento(v_est_sseguro, v_nmovimi, v_sseguro);
         COMMIT;
         RETURN NULL;
   END f_suplemento_minversion;
END pac_ref_contrata_ulk;

/

  GRANT EXECUTE ON "AXIS"."PAC_REF_CONTRATA_ULK" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_REF_CONTRATA_ULK" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_REF_CONTRATA_ULK" TO "PROGRAMADORESCSI";
