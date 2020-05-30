--------------------------------------------------------
--  DDL for Package Body PAC_REF_SINIES_ULK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_REF_SINIES_ULK" AS
   /******************************************************************************
      NOMBRE:       PAC_REF_SINIES_ULK
      PROPÓSITO:
      REVISIONES:

      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
       1.0       -            -               1. Creación de package
       2.0       31/03/2009  RSC              2. Análisis adaptación productos indexados
       3.0       27/04/2009  APD              3. Bug 9685 - en lugar de coger la actividad de la tabla seguros, llamar a la
                                                 función pac_seguros.ff_get_actividad
       4.0       17/09/2009  RSC              4. Bug 0010828: CRE - Revisión de los productos PPJ dinámico y Pla Estudiant (ajustes)
   ******************************************************************************/
   FUNCTION f_aperturar_siniestro(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pfsinies IN DATE,
      pfnotifi IN DATE,
      ptsinies IN VARCHAR2,
      pcmotsin IN NUMBER,
      pcidioma IN NUMBER,
      pcidioma_user IN NUMBER DEFAULT f_idiomauser,
      ocoderror OUT NUMBER,
      omsgerror OUT VARCHAR2)
      RETURN NUMBER IS
      /************************************************************************************************************************************
         Función que inicializa el siniestro y mira qué tipo de siniestro debe abrir
         Parámetros de entrada: psseguro = Identificador de la póliza
                                pnriesgo =  Riesgo o asegurado al que se imputa el siniestro.
                                            Si la póliza es de un producto a 2 cabezas se indicará el asegurado (asegurados.norden),
                                            sino el riesgo (riesgo.nriesgo)
                                pfsinies = Fecha de ocurrencia del siniestro
                                pfnotifi = Fecha de notificación (Por defecto debe valer Trunc(F_Sysdate))
                                ptsinies = Observaciones
                                pcmotsin = Motivo del siniestro
                                pcidioma = Idioma de la documentación
                                pcidioma_user = Idioma del usuario
         Parámetros de salida: ocoderror =  Si hay error: código de error. Si no hay error: Null
                               omsgerror = Si hay error: texto de error. Si no hay error: Null
       ******************************************************************************************************************************************/
      vnsinies       NUMBER;
      vsproduc       NUMBER;
      vcramo         NUMBER;
      vcmodali       NUMBER;
      vctipseg       NUMBER;
      vccolect       NUMBER;
      vcactivi       NUMBER;
      vcgarant       NUMBER;
      vcbancar       VARCHAR2(20);
      vivalora       NUMBER;
      vipenali       NUMBER;
      vicapris       NUMBER;
      v_est_sseguro  NUMBER;
      num_err        NUMBER;
      error          EXCEPTION;
      -- Bug 10828 - RSC - 10/09/2009 - CRE - Revisión de los productos PPJ dinámico y Pla Estudiant (ajustes)
      v_cempres      seguros.cempres%TYPE;
   -- Fin Bug 10828
   BEGIN
      -- Se valida que los parémetros de entrada vienen informados
      IF psseguro IS NULL THEN
         ocoderror := 111995;   -- Es obligatorio informar el número de seguro
         omsgerror := f_literal(ocoderror, pcidioma_user);
         RAISE error;
      END IF;

      IF pfsinies IS NULL THEN
         ocoderror := 110740;   -- Es necesario informar la fecha del siniestro.
         omsgerror := f_literal(ocoderror, pcidioma_user);
         RAISE error;
      END IF;

      IF pfnotifi IS NULL THEN
         ocoderror := 152207;   -- Hay que informar la fecha de notificación
         omsgerror := f_literal(ocoderror, pcidioma_user);
         RAISE error;
      END IF;

      IF pcmotsin IS NULL THEN
         ocoderror := 152208;   -- Hay que informar el motivo de siniestro
         omsgerror := f_literal(ocoderror, pcidioma_user);
         RAISE error;
      END IF;

      IF pnriesgo IS NULL THEN
         ocoderror := 180531;   -- Es obligatorio informar un riesgo o asegurado
         omsgerror := f_literal(ocoderror, pcidioma_user);
         RAISE error;
      END IF;

      IF ptsinies IS NULL THEN
         ocoderror := 180521;   -- Es obligatorio informar las observaciones del siniestro
         omsgerror := f_literal(ocoderror, pcidioma_user);
         RAISE error;
      END IF;

      IF pcidioma IS NULL THEN
         ocoderror := 102242;   -- Idioma obligatorio
         omsgerror := f_literal(ocoderror, pcidioma_user);
         RAISE error;
      END IF;

      IF pcidioma_user IS NULL THEN
         ocoderror := 180522;   -- Es obligatorio informar el idioma del usuario
         omsgerror := f_literal(ocoderror, pcidioma_user);
         RAISE error;
      END IF;

      BEGIN
         -- Bug 9685 - APD - 27/04/2009 - en lugar de coger la actividad de la tabla seguros, llamar a la función pac_seguros.ff_get_actividad
         SELECT cramo, cmodali, ctipseg, ccolect,
                pac_seguros.ff_get_actividad(sseguro, pnriesgo) cactivi, sproduc
           INTO vcramo, vcmodali, vctipseg, vccolect,
                vcactivi, vsproduc
           FROM seguros
          WHERE sseguro = psseguro;
      -- Bug 9685 - APD - 27/04/2009 - Fin
      EXCEPTION
         WHEN OTHERS THEN
            ocoderror := 101919;   -- Error al leer datos de la tabla SEGUROS
            omsgerror := f_literal(ocoderror, pcidioma_user);
            RAISE error;
      END;

      -- Bug 10828 - RSC - 10/09/2009 - CRE - Revisión de los productos PPJ dinámico y Pla Estudiant (ajustes)
      BEGIN
         SELECT cempres
           INTO v_cempres
           FROM seguros
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 101903;
      END;

      -- Fin Bug 10828

      -- Si el motivo de siniestro es 0.- Fallecimiento (quiere decir que sólo hay un titular vigente) se inicializará el siniestro
      -- y se ejecutarán las valoraciones
      IF pcmotsin = 0 THEN
         -- Se Inicializa el siniestro
         num_err := pac_sin.f_inicializar_siniestro(psseguro, pnriesgo, pfsinies, pfnotifi,
                                                    ptsinies, 1, pcmotsin, 20, vnsinies, NULL);

         IF num_err <> 0 THEN
            ocoderror := num_err;
            omsgerror := f_literal(ocoderror, pcidioma_user);
            RAISE error;
         END IF;

         -- Se ejecutan las valoraciones contra la garantía 1 (Fallecimiento)
         -- Bug 9031 - 31/03/2009 - RSC - Análisis adaptación productos indexados
         IF pac_mantenimiento_fondos_finv.f_cestas_valoradas(pfsinies, v_cempres) = 0 THEN
            -- Fin Bug 9031
            num_err := pk_cal_sini.valo_pagos_sini(pfsinies, psseguro, vnsinies, vsproduc,
                                                   vcactivi, 1, 1, pcmotsin, pfnotifi,
                                                   vivalora, vipenali, vicapris);

            IF num_err <> 0 THEN
               ocoderror := num_err;
               omsgerror := f_literal(ocoderror, pcidioma_user);
               RAISE error;
            END IF;

            num_err := pac_sin_insert.f_insert_valoraciones(vnsinies, 1, pfnotifi, vivalora,
                                                            vipenali, vicapris);

            IF num_err <> 0 THEN
               ocoderror := num_err;
               omsgerror := f_literal(ocoderror, pcidioma_user);
               RAISE error;
            END IF;
         END IF;
      ELSIF pcmotsin = 4 THEN
         -- Se Inicializa el siniestro
         num_err := pac_sin.f_inicializar_siniestro(psseguro, pnriesgo, pfsinies, pfnotifi,
                                                    ptsinies, 1, pcmotsin, 20, vnsinies, NULL);

         IF num_err <> 0 THEN
            ocoderror := num_err;
            omsgerror := f_literal(ocoderror, pcidioma_user);
            RAISE error;
         END IF;

         -- Se insertan las valoraciones -- No hace falta valorar aqui.
         -- En el momento de generar el Rescate activado por el siniestro se realizará la
         -- valoración del siniestro (y se generarán los pagos, etc). --> Ver: PAC_RESCATES.f_tratar_sinies_fallec
         IF (NVL(f_parproductos_v(vsproduc, 'PRODUCTO_MIXTO'), 0) = 1
             OR NVL(f_parproductos_v(vsproduc, 'USA_EDAD_CFALLAC'), 0) = 1) THEN   -- Ibex 35 y Ibex 35 Garantizado
            -- Bug 9031 - 31/03/2009 - RSC - Análisis adaptación productos indexados
            IF pac_mantenimiento_fondos_finv.f_cestas_valoradas(pfsinies, v_cempres) = 0 THEN
               -- Fin Bug 9031
               num_err := pk_cal_sini.valo_pagos_sini(pfsinies, psseguro, vnsinies, vsproduc,
                                                      vcactivi, 1, 1, pcmotsin, pfnotifi,
                                                      vivalora, vipenali, vicapris);

               IF num_err <> 0 THEN
                  ocoderror := num_err;
                  omsgerror := f_literal(ocoderror, pcidioma_user);
                  RAISE error;
               END IF;

               num_err := pac_sin_insert.f_insert_valoraciones(vnsinies, 1, pfnotifi, vivalora,
                                                               vipenali, vicapris);

               IF num_err <> 0 THEN
                  ocoderror := num_err;
                  omsgerror := f_literal(ocoderror, pcidioma_user);
                  RAISE error;
               END IF;
            END IF;
         END IF;

         -- Cerrar el siniestro (esto no se seguro si lo debemos hacer para Unit Linked)
         -- Multilink --> No finalizamos el siniestro ya que la propia acción al abrir el siniestro
         -- nos genera el rescate que a su vez su acción al abrir es retener la póliza
         IF (NVL(f_parproductos_v(vsproduc, 'PRODUCTO_MIXTO'), 0) = 1
             OR NVL(f_parproductos_v(vsproduc, 'USA_EDAD_CFALLAC'), 0) = 1) THEN   -- Ibex 35 y Ibex 35 Garantizado
----------------------------
-- Preguntar pa confirmar
----------------------------
            num_err := pac_sin.f_finalizar_sini(vnsinies, 1, vcramo || '01', TRUNC(f_sysdate),
                                                100832, pcidioma_user);

            IF num_err <> 0 THEN
               ocoderror := num_err;
               omsgerror := f_literal(ocoderror, pcidioma_user);
               RAISE error;
            END IF;
         END IF;
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN error THEN
         ROLLBACK;

         BEGIN
            SELECT sseguro
              INTO v_est_sseguro
              FROM estseguros
             WHERE ssegpol = psseguro;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               RETURN NULL;
            WHEN OTHERS THEN
               ocoderror := 180529;   -- Error al leer de la tabla ESTSEGUROS
               omsgerror := f_literal(ocoderror, pcidioma_user);
               RETURN NULL;
         END;

         num_err := pk_suplementos.f_final_suplemento(v_est_sseguro, NULL, psseguro);

         IF num_err <> 0 THEN
            ocoderror := num_err;
            omsgerror := f_literal(ocoderror, pcidioma_user);
            ROLLBACK;
         END IF;

         COMMIT;
         RETURN NULL;
      WHEN OTHERS THEN
         ocoderror := -999;
         omsgerror := 'pac_ref_sinies_ulk.f_aperturar_siniestro: Error general en la función';
         p_tab_error(f_sysdate, f_user, 'pac_ref_sinies_ulk.f_aperturar_siniestro', NULL,
                     'parametros: psseguro = ' || psseguro || '  pnriesgo = ' || pnriesgo
                     || ' pfsinies = ' || pfsinies || '  ptsinies = ' || ptsinies
                     || ' pfnotifi = ' || pfnotifi || ' pcmotsin = ' || pcmotsin
                     || ' pcidioma = ' || pcidioma || ' pcidioma_user = ' || pcidioma_user,
                     SQLERRM);
         ROLLBACK;

         BEGIN
            SELECT sseguro
              INTO v_est_sseguro
              FROM estseguros
             WHERE ssegpol = psseguro;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               RETURN NULL;
            WHEN OTHERS THEN
               ocoderror := 180529;   -- Error al leer de la tabla ESTSEGUROS
               omsgerror := f_literal(ocoderror, pcidioma_user);
               RETURN NULL;
         END;

         num_err := pk_suplementos.f_final_suplemento(v_est_sseguro, NULL, psseguro);

         IF num_err <> 0 THEN
            ocoderror := num_err;
            omsgerror := f_literal(ocoderror, pcidioma_user);
            ROLLBACK;
         END IF;

         COMMIT;
         RETURN NULL;
   END f_aperturar_siniestro;

   FUNCTION f_valida_permite_rescate_total(
      psseguro IN NUMBER,
      pcagente IN NUMBER,
      pfrescate IN DATE,
      pcidioma_user IN NUMBER DEFAULT f_idiomauser,
      ocoderror OUT NUMBER,
      omsgerror OUT VARCHAR2)
      RETURN NUMBER IS
      num_err        NUMBER;
      v_sproduc      NUMBER;
      v_norden       NUMBER;
   BEGIN
      -- Mirar si está permitido el rescate según la parametrización del producto
      num_err := pac_rescates.f_valida_permite_rescate(psseguro, pcagente, pfrescate, 4);

      IF num_err <> 0 THEN
         ocoderror := num_err;
         omsgerror := f_literal(ocoderror, pcidioma_user);
         RETURN NULL;
      END IF;

      -- Mirar si tiene descuadres
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         ocoderror := 108190;   -- Error General
         omsgerror := f_literal(ocoderror, pcidioma_user);
         p_tab_error(f_sysdate, f_user, 'pac_ref_sinies_ulk.f_valida_permite_rescate_total',
                     NULL,
                     'parametros: psseguro=' || psseguro || ' pcagente=' || pcagente
                     || ' pfrescate =' || pfrescate,
                     SQLERRM);
         RETURN NULL;
   END f_valida_permite_rescate_total;

   FUNCTION f_sim_rescate_total(
      psseguro IN NUMBER,
      pcagente IN NUMBER,
      pfrescate IN DATE,
      pcidioma IN NUMBER,
      pcidioma_user IN NUMBER,
      cavis OUT NUMBER,
      lavis OUT VARCHAR2,
      ocoderror OUT NUMBER,
      omsgerror OUT VARCHAR2)
      RETURN cursor_type IS
/*****************************************************************************************
      Función que simula un rescate.  Se establecerán controles para asegurar que el cálculo
      es correcto. Si se detecta algún error entonces se dará el siguiente mensaje
       'No se puede realizar simulación sobre esta póliza. ¿Proceder al rescate?'.
       De esta forma evitaremos mostrar la pantalla con importes que pueden ser incorrectos.

      Si hay un error en la función se devolverá en ocoderror y omsgerror

      La información del rescates se devuelve en un cursor.

******************************************************************************************/
      res            pk_cal_sini.valores%TYPE;
      num_err        NUMBER;
      v_cursor       cursor_type;
      v_sproduc      NUMBER;
      mostrar_datos  NUMBER;
      v_frescate     DATE;
   BEGIN
      -- Se valida que los parémetros de entrada vienen informados
      IF psseguro IS NULL THEN
         ocoderror := 111995;   -- Es obligatorio informar el número de seguro
         omsgerror := f_literal(ocoderror, pcidioma_user);
         RETURN v_cursor;
      END IF;

      IF pfrescate IS NULL THEN
         ocoderror := 110740;   -- Es necesario informar la fecha del siniestro.
         omsgerror := f_literal(ocoderror, pcidioma_user);
         RETURN v_cursor;
      END IF;

      IF pcidioma_user IS NULL THEN
         ocoderror := 180522;   -- Es obligatorio informar el idioma del usuario
         omsgerror := f_literal(ocoderror, pcidioma_user);
         RETURN v_cursor;
      END IF;

      v_frescate := TRUNC(pfrescate);
      mostrar_datos := 1;
      cavis := NULL;
      lavis := NULL;
      num_err := f_valida_permite_rescate_total(psseguro, pcagente, v_frescate, pcidioma_user,
                                                ocoderror, omsgerror);

      IF num_err IS NULL THEN
         RETURN v_cursor;
      END IF;

      num_err := pac_rescates.f_simulacion_rescate(psseguro, pcagente, 4, NULL, v_frescate,
                                                   res);

      IF num_err <> 0 THEN
         ocoderror := num_err;
         omsgerror := f_literal(ocoderror, pcidioma_user);
         ROLLBACK;
         RETURN v_cursor;
      END IF;

      num_err := pac_rescates.f_avisos_rescates(psseguro, v_frescate, res(1).isinret, cavis,
                                                mostrar_datos);

      IF cavis IS NOT NULL THEN
         lavis := f_literal(cavis, pcidioma_user);
      END IF;

      -- Grabamos un registro en simulaestadist
      SELECT sproduc
        INTO v_sproduc
        FROM seguros
       WHERE sseguro = psseguro;

      num_err := pac_simul_comu.f_ins_simulaestadist(pcagente, v_sproduc, 3);

      IF num_err <> 0 THEN
         ocoderror := num_err;
         omsgerror := f_literal(ocoderror, pcidioma_user);
         ROLLBACK;
         RETURN v_cursor;
      END IF;

      -- La función debe devolver la siguiente información:
      -- SPRODUC, CRAMO, CMODALI, CTIPSEG, CCOLECT, NPOLIZA, NCERTIF, CIDIOMA, FEFECTO, SPERSON1,
      -- SPERSON2, CSITUAC, TSITUAC, FVENCIM, CAPITAL_GARANTIZADO, CAPITAL COBERTURAS ADICIONALES,
      -- INTERÉS TÉCNICO, VALOR PROVISIÓN, IMPORTE PENALIZACIÓN, VALOR BRUTO RESCATE, PRIMAS SATISFECHAS,
      -- PLUSVALÍA, REDUCCIÓN, RED. DISP. TRANS, RCM, % RETENCIÓN, IMPORTE RETNECIÓN, VALOR RESATE NETO
      COMMIT;

      OPEN v_cursor FOR
         SELECT s.sproduc, s.cramo, s.cmodali, s.ctipseg, s.ccolect, s.npoliza, s.ncertif,
                s.cidioma, s.fefecto, a.sperson sperson1, a.ffecfin ffecfin1,
                DECODE(a.ffecfin,
                       NULL, NULL,
                       DECODE(pcidioma_user, 1, 'Baja', 2, 'Baixa')) csit_aseg1,
                a2.sperson sperson2, a2.ffecfin ffecfin2,
                DECODE(a2.ffecfin,
                       NULL, NULL,
                       DECODE(pcidioma_user, 1, 'Baja', 2, 'Baixa')) csit_aseg2,
                s.csituac, d.tatribu, s.fvencim,
                DECODE(mostrar_datos,
                       1, NVL(f_capgar_ult_act(s.sseguro, TRUNC(f_sysdate)), 0),
                       NULL) cap_gar,
                DECODE(mostrar_datos,
                       1, NVL(pac_calc_comu.ff_capital_gar_tipo('SEG', s.sseguro, 1, 6,
                                                                m.nmovimi, 1),
                              0),
                       NULL) cap_fallec,
                DECODE(mostrar_datos,
                       1, NVL(pac_calc_comu.ff_capital_gar_tipo('SEG', s.sseguro, 1, 7,
                                                                m.nmovimi, 1),
                              0),
                       NULL) cap_accid,
                DECODE(mostrar_datos,
                       1, pac_inttec.ff_int_seguro('SEG', s.sseguro),
                       NULL) inttec,
                DECODE(mostrar_datos, 1, res(1).icapris, NULL) capris,
                DECODE(mostrar_datos, 1, res(1).ipenali, NULL) penali,
                DECODE(mostrar_datos, 1, res(1).isinret, NULL) irescate,
                DECODE(mostrar_datos, 1, res(1).iprimas, NULL) primas_cons,
                DECODE(mostrar_datos,
                       1, GREATEST((res(1).isinret - res(1).iprimas), 0),
                       NULL) rend_bruto,
                DECODE(mostrar_datos, 1, res(1).iresred, NULL) reduccion,
                DECODE(mostrar_datos, 1, (SELECT SUM(ireg_trans)
                                            FROM tmp_primas_consumidas
                                           WHERE sseguro = psseguro), NULL) reg_trans,
                DECODE(mostrar_datos, 1, res(1).iresrcm, NULL) rcm,
                DECODE(mostrar_datos, 1, res(1).iretenc, NULL) retencion,
                DECODE(mostrar_datos, 1, res(1).iimpsin, NULL) iresneto
           FROM seguros s, asegurados a, detvalores d, movseguro m, asegurados a2
          WHERE s.sseguro = a.sseguro
            AND a.norden = 1
            AND a2.sseguro(+) = s.sseguro
            AND a2.norden(+) = 2
            -- LEFT JOIN asegurados a2 ON ( s.sseguro = a2.sseguro AND a2.norden = 2)
            AND d.cvalor = 61   -- indicador situación póliza
            AND d.cidioma = pcidioma_user
            AND d.catribu = s.csituac
            AND m.sseguro = s.sseguro
            AND m.nmovimi = (SELECT MAX(nmovimi)
                               FROM movseguro
                              WHERE sseguro = s.sseguro)
            AND s.sseguro = psseguro;

      RETURN v_cursor;
   EXCEPTION
      WHEN OTHERS THEN
         ocoderror := 180561;   -- Error General
         omsgerror := f_literal(ocoderror, pcidioma_user);
         p_tab_error(f_sysdate, f_user, 'pac_ref_sinies_ulk.f_sim_rescate_total', NULL,
                     'parametros: psseguro=' || psseguro || ' pcagente=' || pcagente
                     || ' pfrescate =' || pfrescate,
                     SQLERRM);

         CLOSE v_cursor;

         ROLLBACK;
         RETURN v_cursor;
   END f_sim_rescate_total;

   FUNCTION f_sol_rescate_total(
      psseguro IN NUMBER,
      pcagente IN NUMBER,
      pfrescate IN DATE,
      pcidioma IN NUMBER,
      pcidioma_user IN NUMBER,
      pirescate IN NUMBER,
      ocoderror OUT NUMBER,
      omsgerror OUT VARCHAR2,
      pccausin NUMBER DEFAULT 4)
      RETURN NUMBER IS
/**************************************************************************
   Función para solicitar un rescate total.
   Pnivel: 1.- Se generan todos los datos posibles: valoraciones, destinatarios y pagos
           2.- No se generarán pagos
   Pccausin: default 4 (rescate total) pero al tener el parámetro podemos utilizar
      la función para solicitar un vencimiento (pccausin = 3)
********************************************************************************/
      v_sproduc      NUMBER;
      num_err        NUMBER;
      xnivel         NUMBER;
      cavis          NUMBER;
      pdatos         NUMBER;
      v_frescate     DATE;
   BEGIN
      -- Se valida que los parémetros de entrada vienen informados
      IF psseguro IS NULL THEN
         ocoderror := 111995;   -- Es obligatorio informar el número de seguro
         omsgerror := f_literal(ocoderror, pcidioma_user);
         RETURN NULL;
      END IF;

      IF pfrescate IS NULL THEN
         ocoderror := 110740;   -- Es necesario informar la fecha del siniestro.
         omsgerror := f_literal(ocoderror, pcidioma_user);
         RETURN NULL;
      END IF;

      IF pcidioma_user IS NULL THEN
         ocoderror := 180522;   -- Es obligatorio informar el idioma del usuario
         omsgerror := f_literal(ocoderror, pcidioma_user);
         RETURN NULL;
      END IF;

      v_frescate := TRUNC(pfrescate);

      SELECT sproduc
        INTO v_sproduc
        FROM seguros
       WHERE sseguro = psseguro;

      num_err := f_valida_permite_rescate_total(psseguro, pcagente, v_frescate, pcidioma_user,
                                                ocoderror, omsgerror);

      IF num_err IS NULL THEN
         RETURN NULL;
      END IF;

      num_err := pac_rescates.f_avisos_rescates(psseguro, v_frescate, pirescate, cavis, pdatos);

      IF cavis IS NOT NULL THEN
         xnivel := 2;   -- no se generan datos
      ELSE
         xnivel := 1;   -- se generarán también los pagos
      END IF;

      num_err := pac_rescates.f_sol_rescate(psseguro, v_sproduc, 1, pcagente, pcidioma_user, 4,
                                            NULL, v_frescate, NULL, NULL, NULL, NULL, xnivel);

      IF num_err <> 0 THEN
         ocoderror := num_err;
         omsgerror := f_literal(ocoderror, pcidioma_user);
         ROLLBACK;
         RETURN NULL;
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         ocoderror := -999;
         omsgerror := 'Pac_Ref_Sinies_Uls.f_sol_rescate_total: Error general en la función';
         p_tab_error(f_sysdate, f_user, 'Pac_Ref_Sinies_Ulk.f_sim_rescate_total', NULL,
                     'parametros: psseguro = ' || psseguro || '  pcagente = ' || pcagente
                     || 'pfrescate = ' || pfrescate,
                     SQLERRM);
         ROLLBACK;
         RETURN NULL;
   END f_sol_rescate_total;
END pac_ref_sinies_ulk;

/

  GRANT EXECUTE ON "AXIS"."PAC_REF_SINIES_ULK" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_REF_SINIES_ULK" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_REF_SINIES_ULK" TO "PROGRAMADORESCSI";
