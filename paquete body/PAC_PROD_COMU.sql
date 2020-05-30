--------------------------------------------------------
--  DDL for Package Body PAC_PROD_COMU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_PROD_COMU" AS
   /****************************************************************************
      NOMBRE:       pac_prod_comu
      PROPÓSITO:  Funciones para la gestión común.
      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ----------------------------------
      2.0        10/02/2009   RSC             Desarrollo de sistema de copago
      2.1        12/02/2009   RSC             Adaptacion a colectivos multiples
                                              con certificados
      3.0        06/03/2009   RSC             Unificación de recibos
      14.0       22/04/2009   APD             Bug 9803 - no se inserta el saldo en la renovación para los productos con parproducto SALDO_AE = 0
      15.0       28/04/2009   DCT             1-Modificar f_pargaranpro. Bug:0009783
      16.0       29/04/2009   APD             Bug 9803 - se añade a la funcion f_grabar_inttec el parametro pninttec
      17.0       01/07/2009   JRH             Bug 10692: CEM - Revisar el proceso de revisión de interés
      18.0       15/06/2009   JTS             BUG 10069
      19.0       15/12/2009   APD             BUG 12277 - se le añade el valor 2 en el parametro pmodo al llamar a la funcion
                                              pac_calc_comu.f_calcula_frevisio para indicar que se está en la revision
      20.0       22/01/2010   RSC             20. 0012822 - CEM: RT - Tratamiento fiscal rentas a 2 cabezas
      21.0       20/01/2010   RSC             0012629: APR - error in the nocturnal process
      22.0       10/03/2010   JRH             0012136: CEM - RVI - Verificación productos RVI
      23.0       24/02/2010   JMF             0012822 CEM - RT - Tratamiento fiscal rentas a 2 cabezas
      24.0       16/06/2010   JRH             0015072: Renovació de tipus d'interès en renovació de rendes ( bug 14806)
      25.0       16/06/2010   JRH             0015072: Renovació de tipus d'interès en renovació de rendes ( bug 14806)
      26.0       05/09/2010   JRH             5. BUG 0016217: Mostrar cuadro de capitales para la pólizas de rentas
      27.0       10/12/2010   JMP             0016903: CEM - Proceso revisión interés: Comprobación movimientos posteriores a fecha revisión interés
      28.0       21/06/2011   JMF             0018812: ENSA102-Proceso de alta de prestación en forma de renta actuarial
      29.0       23/01/2013   MMS              29. 0025584: (f_calcula_fvencim_nduraci) Agregamos el parámetro nedamar
      30.0       11/03/2013   AEG             30. 0024685: (POSDE600)-Desarrollo-GAPS Tecnico-Id 5 -- N?mero de p?liza manual
      31.0       30/04/2014   FAL             31. 0027642: RSA102 - Producto Tradicional
     32.0       24/07/2015   CJM             32. 34915/210493: Se agrega update al campo ultpoliza_rango de la tabla RESERVA_RANGOS

   ****************************************************************************/
   FUNCTION f_grabar_alta_poliza(psseguro_est IN NUMBER, psseguro OUT NUMBER)
      RETURN NUMBER IS
      /******************************************************************************************************************************************
                    Esta función traspasa los datos de las tablas 'EST' a las tablas definitivas.
           Si todo va bien retorna 0.
           Si hay error retorna el código de error
      *************************************************************************************************************************************/
      num_err        NUMBER;
      v_ssegpol      NUMBER;
      error          EXCEPTION;
   BEGIN
      SELECT ssegpol
        INTO v_ssegpol
        FROM estseguros
       WHERE sseguro = psseguro_est;

      -- Graba la póliza
      num_err := pk_nueva_produccion.f_grabar_alta_poliza(psseguro_est);

      IF num_err <> 0 THEN
         RAISE error;
      END IF;

      psseguro := v_ssegpol;
      RETURN 0;
   EXCEPTION
      WHEN error THEN
         RETURN num_err;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Pac_Prod_Comu.f_grabar_alta_poliza', NULL,
                     'parametros: psseguro =' || psseguro, SQLERRM);
         RETURN 108190;   -- Error general
   END f_grabar_alta_poliza;

   -- Esta función estaba antes en el producción AHO, la psamos al comu con el nuevo parametro capital para rentas.
   FUNCTION f_programa_revision_renovacion(
      psseguro IN NUMBER,
      pndurper IN NUMBER,
      ppinttec IN NUMBER,
      pcapital IN NUMBER)
      RETURN NUMBER IS
      /********************************************************************************************************************************
                  Función que marca una póliza para su renovación/revisión con los nuevos valores a aplicar: duración ,
         % de interés garantizado y capital fallecimiento.
         Parámetros de entrada:
              . psseguro = Identificador de la póliza
              . pndurper = Duración Período
              . ppinttec = % de interés técnico
              . pcapital = nuevo capital de fallecimiento para rentas
            La función retorna:
               0 - si ha ido bien
              codigo error - si hay algún error.
      *********************************************************************************************************************************/
      num_err        NUMBER;
      v_movimi       NUMBER;
      v_sproduc      NUMBER;
   BEGIN
      SELECT sproduc
        INTO v_sproduc
        FROM seguros
       WHERE sseguro = psseguro;

      --     IF NVL(f_parproductos_v(v_sproduc, 'DURPER'),0) = 1 THEN
      IF pndurper IS NOT NULL THEN
         -- Valida la duración
         num_err := pac_val_comu.f_valida_duracion_renova(psseguro, pndurper);

         IF num_err <> 0 THEN
            RETURN num_err;
         END IF;
      END IF;

      -- Se graba un movimiento de seguro
      num_err := f_movseguro(psseguro, NULL, 520, 1, TRUNC(f_sysdate), NULL, NULL, NULL, NULL,
                             v_movimi, f_sysdate);

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      -- Se graba el registro de historicoseguros
      num_err := f_act_hisseg(psseguro, v_movimi - 1);

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      -- Se actualizan los campos seguros_aho.ndurrev con la nueva duración y seguros_aho.pintrev con el nuevo % de interés técnico
      UPDATE seguros_aho
         SET ndurrev = pndurper,
             pintrev = ppinttec
       WHERE sseguro = psseguro;

      -- Suplemento de cambio de capital
      UPDATE seguros_ren
         SET pcaprev = pcapital
       WHERE sseguro = psseguro;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Pac_Prod_Comu.f_graba_propuesta_aho', NULL,
                     'parametros: psseguro =' || psseguro || ' pndurper =' || pndurper
                     || ' ppinttec =' || ppinttec,
                     SQLERRM);
         RETURN(108190);   -- Error general
   END f_programa_revision_renovacion;

   -- Especial para preguntas tipo texto
   FUNCTION f_ins_estpregunsegtexto(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      pcpregun IN NUMBER,
      pcrespue IN VARCHAR2)
      RETURN NUMBER IS
   BEGIN
      INSERT INTO estpregunseg
                  (sseguro, nriesgo, nmovimi, cpregun, trespue, crespue)
           VALUES (psseguro, pnriesgo, pnmovimi, pcpregun, pcrespue, 1);

      RETURN 0;
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         UPDATE estpregunseg
            SET trespue = pcrespue
          WHERE sseguro = psseguro
            AND nriesgo = pnriesgo
            AND nmovimi = pnmovimi
            AND cpregun = pcpregun;

         RETURN 0;
      WHEN OTHERS THEN
         RETURN 108426;   --error en al insertar preguntas
   END f_ins_estpregunsegtexto;

   FUNCTION f_grabar_preguntas(
      psproduc IN NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pfefecto IN DATE,
      tab_pregun t_preguntas,
      pcidioma_user IN NUMBER,
      pnmovimi IN NUMBER DEFAULT 1)
      RETURN NUMBER IS
      /*********************************************************************************************************************************
                                                                             Función que inserta las preguntas de una poliza a partir de un array que las contiene:
      *******************************************************************************************************************************/
      traza          NUMBER;   -- se utilizará para saber en qué lugar se produce un error al grabar en tab_error

      CURSOR datpregun(pregun IN NUMBER) IS
         SELECT c.ctippre   --Buscamos el tipo
           FROM codipregun c, pregunpro p
          WHERE p.sproduc = psproduc
            AND c.cpregun = p.cpregun
            AND p.cpregun = pregun;

      err            EXCEPTION;
      ocoderror      NUMBER;
      omsgerror      VARCHAR2(250);
      num_err        NUMBER;
      respuesta      NUMBER;
      respuestat     VARCHAR2(2000);
      tipo           codipregun.ctippre%TYPE;
      dummy          NUMBER;
   BEGIN
      IF tab_pregun.COUNT() > 0 THEN
         --Recorremos la tabla con las parejas preguntas-respuestas
         FOR i IN tab_pregun.FIRST .. tab_pregun.LAST LOOP
            IF tab_pregun.EXISTS(i) THEN
               IF tab_pregun(i).codigo IS NULL THEN
                  ocoderror := 102741;
                  omsgerror := f_axis_literales(num_err, pcidioma_user);
                  RAISE err;
               END IF;

               IF datpregun%ISOPEN THEN
                  CLOSE datpregun;
               END IF;

               OPEN datpregun(tab_pregun(i).codigo);   --Miramos si existe la pregunta para el producto.

               FETCH datpregun
                INTO tipo;

               IF datpregun%NOTFOUND THEN
                  traza := 10;

                  CLOSE datpregun;

                  ocoderror := 102741;
                  omsgerror := f_axis_literales(num_err, pcidioma_user);
                  RAISE err;
               END IF;

               CLOSE datpregun;

               --Validamos las respuestas
               IF tipo = 1 THEN   --Si/No  la respuesta ha de ser 0 o 1
                  IF tab_pregun(i).respuesta NOT IN(0, 1) THEN
                     traza := 11;
                     ocoderror := 112061;
                     omsgerror := f_axis_literales(num_err, pcidioma_user);
                     RAISE err;
                  END IF;

                  respuesta := TO_NUMBER(tab_pregun(i).respuesta);
               ELSIF tipo = 2 THEN   --Lista de valores
                  BEGIN   --Buscamos si existe la respuesta en la tabla de respuestas para la pregunta
                     SELECT 1
                       INTO dummy
                       FROM codirespuestas
                      WHERE cpregun = tab_pregun(i).codigo
                        AND crespue = tab_pregun(i).respuesta;

                     respuesta := TO_NUMBER(tab_pregun(i).respuesta);
                  EXCEPTION
                     WHEN OTHERS THEN
                        traza := 12;
                        ocoderror := 112061;
                        omsgerror := f_axis_literales(num_err, pcidioma_user);
                        RAISE err;
                  END;
               ELSE   --Si es un valor y nos informan el tipo validamos el tipo de la respuesta y lo convertimos a numérico
                  --para poder insertarlo en pregunseg.
                  IF tab_pregun(i).tipo = 'N' THEN   --Es un número
                     BEGIN
                        respuesta := TO_NUMBER(tab_pregun(i).respuesta);
                     EXCEPTION
                        WHEN OTHERS THEN
                           traza := 14;
                           ocoderror := 112061;
                           omsgerror := f_axis_literales(num_err, pcidioma_user);
                           RAISE err;
                     END;
                  ELSIF tab_pregun(i).tipo = 'F' THEN   --Es una fecha
                     BEGIN
                        respuesta := TO_NUMBER(TO_CHAR(TO_DATE(tab_pregun(i).respuesta,
                                                               'DD/MM/YYYY'),
                                                       'DDMMYYYY'));
                     EXCEPTION
                        WHEN OTHERS THEN
                           traza := 15;
                           ocoderror := 112061;
                           omsgerror := f_axis_literales(num_err, pcidioma_user);
                           RAISE err;
                     END;
                  ELSE
                     BEGIN
                        respuestat :=(tab_pregun(i).respuesta);   -- De momento intentaremos insertar textos
                     EXCEPTION
                        WHEN OTHERS THEN
                           traza := 14;
                           ocoderror := 112061;
                           omsgerror := f_axis_literales(num_err, pcidioma_user);
                           RAISE err;
                     END;
                  END IF;
               END IF;

               IF tab_pregun(i).tipo = 'T' THEN   --Solución temporal para la cuenta HI que es un texto.
                  num_err := f_ins_estpregunsegtexto(psseguro, pnriesgo, pnmovimi,
                                                     tab_pregun(i).codigo, respuestat);

                  IF num_err <> 0 THEN
                     ocoderror := num_err;
                     omsgerror := f_axis_literales(num_err, pcidioma_user);
                     RAISE err;
                  END IF;
               ELSE
                  --Si pasa todas las validaciones, la pregunta la grabamos en pregunseg para la póliza. De momento sólo numéricos.
                  num_err := pk_nueva_produccion.f_ins_estpregunseg(psseguro, pnriesgo,
                                                                    pnmovimi,
                                                                    tab_pregun(i).codigo,
                                                                    respuesta);

                  IF num_err <> 0 THEN
                     ocoderror := num_err;
                     omsgerror := f_axis_literales(num_err, pcidioma_user);
                     RAISE err;
                  END IF;
               END IF;
            END IF;
         END LOOP;
      END IF;

      --validamos preguntas obligatorias.
      DECLARE
         tipo           NUMBER;
         campo          VARCHAR2(100);
      BEGIN
         num_err := pk_nueva_produccion.f_valida_estpregunseg(psseguro, pnriesgo, psproduc,
                                                              tipo, campo);

         IF num_err <> 0 THEN
            ocoderror := num_err;
            omsgerror := f_axis_literales(num_err, pcidioma_user);
            RAISE err;
         END IF;
      END;

      RETURN 0;
   EXCEPTION
      WHEN err THEN
         -- BUG -21546_108724- 10/02/2012 - JLTS - Cierre de posibles cursores abiertos
         IF datpregun%ISOPEN THEN
            CLOSE datpregun;
         END IF;

         p_tab_error(f_sysdate, f_user, 'Pac_Prod_Comu.f_grabar_preguntas', traza,
                     'parametros: psseguro =' || psseguro || ' pfefecto =' || pfefecto
                     || ' pnmovimi =' || pnmovimi || ' pnrisgo =' || pnriesgo,
                     omsgerror);
         RETURN 108190;   -- Error General
      WHEN OTHERS THEN
         -- BUG -21546_108724- 10/02/2012 - JLTS - Cierre de posibles cursores abiertos
         IF datpregun%ISOPEN THEN
            CLOSE datpregun;
         END IF;

         p_tab_error(f_sysdate, f_user, 'Pac_Prod_Comu.f_grabar_preguntas', traza,
                     'parametros: psseguro =' || psseguro || ' pfefecto =' || pfefecto
                     || ' pnmovimi =' || pnmovimi || ' pnrisgo =' || pnriesgo,
                     SQLERRM);
         RETURN 108190;   -- Error General
   END f_grabar_preguntas;

   FUNCTION f_grabar_esttomador(
      psseguro IN NUMBER,
      psperson IN NUMBER,
      pcdomici IN NUMBER,
      pnordtom IN NUMBER)
      RETURN NUMBER IS
      /**************************************************************************************************
                                                                            Función que inserta o modifica los datos del tomador en ESTTOMADORES
      **************************************************************************************************/
      cont           NUMBER;
   BEGIN
      BEGIN
         INSERT INTO esttomadores
                     (sperson, sseguro, cdomici, nordtom)
              VALUES (psperson, psseguro, pcdomici, pnordtom);
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            UPDATE esttomadores
               SET sperson = psperson,
                   cdomici = pcdomici
             WHERE sseguro = psseguro
               AND nordtom = pnordtom;
      END;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Pac_Prod_Comu.f_grabar_esttomador', NULL,
                     'insert o update con psseguro =' || psseguro || 'nordtom =' || pnordtom
                     || ' psperson =' || psperson || ' cdomici =' || pcdomici,
                     SQLERRM);
         RETURN 108190;   -- Error General
   END f_grabar_esttomador;

   FUNCTION f_grabar_estriesgos_persona(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovima IN NUMBER,
      pfefecto IN DATE,
      psperson IN NUMBER,
      pcdomici IN NUMBER,
      pspermin IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
   /**************************************************************************************************
                                                                         Función que inserta o modifica los datos del riesgo en la tabla ESTRIESGOS
   **************************************************************************************************/
   BEGIN
      INSERT INTO estriesgos
                  (sseguro, nriesgo, nmovima, fefecto, sperson, cdomici, spermin)
           VALUES (psseguro, pnriesgo, pnmovima, pfefecto, psperson, pcdomici, pspermin);

      RETURN 0;
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         UPDATE estriesgos
            SET nmovima = pnmovima,
                fefecto = pfefecto,
                cdomici = pcdomici,
                sperson = psperson,
                spermin = pspermin
          WHERE sseguro = psseguro
            AND nriesgo = pnriesgo;

         RETURN 0;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Pac_Prod_Comu.f_grabar_estriesgos_persona', NULL,
                     'insert o update con psseguro =' || psseguro || ' pnriesgo =' || pnriesgo
                     || ' pnmovima =' || pnmovima || ' psperson =' || psperson || ' cdomici ='
                     || pcdomici || ' pfefecto =' || pfefecto || ' pspermin =' || pspermin,
                     SQLERRM);
         RETURN 108190;   -- Error General
   END f_grabar_estriesgos_persona;

   FUNCTION f_grabar_estassegurats(
      psseguro IN NUMBER,
      pnorden IN NUMBER,
      pfefecto IN DATE,
      psperson IN NUMBER,
      pcdomici IN NUMBER)
      RETURN NUMBER IS
   /**************************************************************************************************
                                                                         Función que inserta los datos del asegurado en la tabla ESTASSEGURATS
   **************************************************************************************************/
   BEGIN
      INSERT INTO estassegurats
                  (sseguro, sperson, norden, cdomici, ffecini)
           VALUES (psseguro, psperson, pnorden, pcdomici, pfefecto);

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Pac_Prod_Comu.f_grabar_estassegurats', NULL,
                     'insert o update con psseguro =' || psseguro || ' pnorden =' || pnorden
                     || ' psperson =' || psperson || ' cdomici =' || pcdomici || ' pfefecto ='
                     || pfefecto,
                     SQLERRM);
         RETURN 108190;   -- Error General
   END f_grabar_estassegurats;

   FUNCTION f_borrar_estassegurats(psseguro IN NUMBER)
      RETURN NUMBER IS
   /**************************************************************************************************
                                                                         Función que borra todos los asegurados de una póliza  en la tabla ESTASSEGURATS
   **************************************************************************************************/
   BEGIN
      DELETE FROM estassegurats
            WHERE sseguro = psseguro;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Pac_Prod_Comu.f_borrar_estassegurats', NULL,
                     'delete con psseguro =' || psseguro, SQLERRM);
         RETURN 108190;   -- Error General
   END f_borrar_estassegurats;

   -- Bug 0018812 - 21/06/2011 - JMF: afegir pctipban
   FUNCTION f_actualiza_datos_gestion(
      psseguro IN NUMBER,
      pcidioma IN NUMBER,
      pcagente IN NUMBER,
      pfefecto IN DATE,
      pnduraci IN NUMBER,
      pfvencim IN DATE,
      pndurper IN NUMBER,
      pcforpag IN NUMBER,
      pcbancar IN VARCHAR2,
      pctipban IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      /********************************************************************************************
                                                                            Función que actualiza los datos de gestión de la póliza que se pueden modificar por pantalla
       **************************************************************************************************/
      v_obj          VARCHAR2(200) := 'PAC_PROD_COMU.f_actualiza_datos_gestion';
      v_pas          NUMBER := 100;
      v_par          VARCHAR2(500)
         := 's=' || psseguro || ' i =' || pcidioma || ' a =' || pcagente || ' e =' || pfefecto
            || ' n =' || pnduraci || ' v =' || pfvencim || ' d =' || pndurper || ' p ='
            || pcforpag || ' b =' || pcbancar || ' t =' || pctipban;
      v_nrenova      NUMBER;
      v_sproduc      NUMBER;
      v_cramo        NUMBER;
      v_cmodali      NUMBER;
      v_ctipseg      NUMBER;
      v_ccolect      NUMBER;
      v_cduraci      NUMBER;
      v_cagrpro      NUMBER;
      v_nduraci      NUMBER;
      v_fvencim      DATE;
      num_err        NUMBER;
      v_ccobban      NUMBER;
      v_fnacimi      DATE;
      v_frevisio     DATE;
      v_cprprod      NUMBER;
      v_cfprest      NUMBER;
      v_nedamar      estseguros.nedamar%TYPE;
   BEGIN
      v_pas := 100;

      -- Como se puede cambiar la fecha de efecto de la póliza hay que calcular el nrenova
      SELECT sproduc, cramo, cmodali, ctipseg, ccolect, cduraci, cagrpro,
             nedamar   -- Bug 0025584 - MMS - 23/01/2013
        INTO v_sproduc, v_cramo, v_cmodali, v_ctipseg, v_ccolect, v_cduraci, v_cagrpro,
             v_nedamar
        FROM estseguros
       WHERE sseguro = psseguro;

      v_pas := 105;
      num_err := pac_calc_comu.f_calcula_nrenova(v_sproduc, pfefecto, v_nrenova);

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      -- ini Bug 0018812 - 21/06/2011 - JMF: afegir pctipban --JRH
      v_pas := 110;

      IF pcbancar IS NOT NULL THEN
         -- Como se puede cambiar la cuenta bancaria se debe calcular el cobrador bancario
         v_pas := 115;
         v_ccobban := f_buscacobban(v_cramo, v_cmodali, v_ctipseg, v_ccolect, pcagente,
                                    pcbancar, pctipban, num_err);
      END IF;

      -- fin Bug 0018812 - 21/06/2011 - JMF: afegir pctipban
      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      -- Calculamos la fecha de vencimiento y nduraci
      v_pas := 120;
      v_nduraci := pnduraci;
      v_fvencim := pfvencim;
      v_pas := 125;

      SELECT MIN(fnacimi)
        INTO v_fnacimi
        FROM estriesgos e, personas p
       WHERE e.sseguro = psseguro
         AND p.sperson = e.sperson;

      v_pas := 130;
      --       num_err := Pk_Nueva_Produccion.f_obtener_fvencim_nduraci (psseguro, pfefecto, v_cduraci, v_nduraci, v_fvencim);
      num_err := pac_calc_comu.f_calcula_fvencim_nduraci(v_sproduc, v_fnacimi, pfefecto,
                                                         v_cduraci, v_nduraci, v_fvencim, NULL,
                                                         NULL, v_nedamar);   -- Bug 0025584 - MMS - 23/01/2013

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      v_pas := 135;

      IF pndurper IS NOT NULL THEN
         BEGIN
            v_pas := 140;

            UPDATE estseguros_aho
               SET ndurper = pndurper
             WHERE sseguro = psseguro;
         EXCEPTION
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, v_obj, v_pas, 's=' || psseguro || ' ' || v_par,
                           SQLCODE || ' ' || SQLERRM);
               RETURN 108190;   -- Error General
         END;
      END IF;

      BEGIN
         v_pas := 145;

         UPDATE estseguros
            SET cidioma = pcidioma,
                cagente = pcagente,
                fefecto = pfefecto,
                nduraci = v_nduraci,
                fvencim = v_fvencim,
                cforpag = pcforpag,
                cbancar = pcbancar,
                ccobban = v_ccobban,
                nrenova = v_nrenova
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, v_obj, v_pas, 's=' || psseguro || ' ' || v_par,
                        SQLCODE || ' ' || SQLERRM);
            RETURN 108190;   -- Error General
      END;

      v_pas := 150;

      -- Se informa la fecha de revisión de la póliza
      IF NVL(f_parproductos_v(v_sproduc, 'FECHAREV'), 0) = 0 THEN
         v_frevisio := NULL;
      ELSIF NVL(f_parproductos_v(v_sproduc, 'FECHAREV'), 0) = 1 THEN
         v_pas := 155;
         v_frevisio := ADD_MONTHS(pfefecto, NVL(pnduraci, 0) * 12);
      ELSIF NVL(f_parproductos_v(v_sproduc, 'FECHAREV'), 0) = 2 THEN
         v_pas := 160;
         v_frevisio := ADD_MONTHS(pfefecto, NVL(pndurper, 0) * 12);
      ELSIF NVL(f_parproductos_v(v_sproduc, 'FECHAREV'), 0) = 3 THEN
         v_pas := 165;
         v_frevisio := ADD_MONTHS(pfefecto, 12);
      END IF;

      BEGIN
         v_pas := 170;

         UPDATE estseguros_aho
            SET frevisio = v_frevisio
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, v_obj, v_pas, 's=' || psseguro || ' ' || v_par,
                        SQLCODE || ' ' || SQLERRM);
            RETURN 108190;   -- Error General
      END;

      -- Si la poliza es de Ahorro
      -- Se debe guardar en el campo CFPREST la forma de pago de la prestación parametrizada en el producto (productos.cprprod)
      IF v_cagrpro = 2 THEN
         BEGIN
            v_pas := 175;

            SELECT cprprod
              INTO v_cprprod
              FROM productos
             WHERE sproduc = v_sproduc;
         EXCEPTION
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, v_obj, v_pas, 'p=' || v_sproduc || ' ' || v_par,
                           SQLCODE || ' ' || SQLERRM);
               RETURN 102705;   -- Error al leer la tabla PRODUCTOS
         END;

         v_pas := 180;

         IF v_cprprod = 3 THEN   -- 3 = Cualquiera de las anteriores
            --v_cfprest := 0; -- por defecto 0.Capital
            -- 1.Renta Mensual Vitalicia para el producto Pias, 0.Capital para el resto de productos
            v_pas := 185;
            v_cfprest := NVL(f_parproductos_v(v_sproduc, 'FORPAGPREST_DEFECTO'), 0);
         ELSE
            v_cfprest := v_cprprod;
         END IF;

         BEGIN
            v_pas := 190;

            UPDATE estseguros_aho
               SET cfprest = v_cfprest
             WHERE sseguro = psseguro;
         EXCEPTION
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, v_obj, v_pas, 's=' || psseguro || ' ' || v_par,
                           SQLCODE || ' ' || SQLERRM);
               RETURN 108190;   -- Error General
         END;
      END IF;

      v_pas := 195;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_obj, v_pas, v_par, SQLCODE || ' ' || SQLERRM);
         RETURN 108190;   -- Error General
   END f_actualiza_datos_gestion;

   FUNCTION f_grabar_beneficiarios(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pfefecto IN DATE,
      psclaben IN NUMBER,
      ptclaben IN VARCHAR2,
      pnmovimi IN NUMBER DEFAULT 1)
      RETURN NUMBER IS
      /*********************************************************************************************************************************
                                                                                               Función que inserta los beneficiarios de una póliza:
           -- Si psclaben is not null: insertará en la tabla ESTCLAUBENSEG
          -- Si ptclaben is not null: insertará en la tabla ESTCLAUSUESP con CCLAESP = 1
      *******************************************************************************************************************************/
      traza          NUMBER;   -- se utilizará para saber en qué lugar se produce un error al grabar en tab_error
   BEGIN
      IF psclaben IS NOT NULL THEN
         traza := 1;

         -- como hay clausula genérica borramos la clausula especial (por si había)
         DELETE      estclausuesp
               WHERE sseguro = psseguro
                 AND nriesgo = pnriesgo
                 AND cclaesp = 1;

         -- desseleccionamos la clausula genérica que hay hasta ahora
         traza := 2;

         UPDATE estclaubenseg
            SET cobliga = 0
          WHERE sseguro = psseguro
            AND nriesgo = pnriesgo
            AND nmovimi = pnmovimi
            AND sclaben <> psclaben;

         -- insertamos la clausula generica. Si ya existe se modifica
         BEGIN
            traza := 3;

            INSERT INTO estclaubenseg
                        (nmovimi, sclaben, sseguro, nriesgo, finiclau, ffinclau, cobliga)
                 VALUES (pnmovimi, psclaben, psseguro, pnriesgo, TRUNC(pfefecto), NULL, 1);
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               traza := 4;

               UPDATE estclaubenseg
                  SET finiclau = TRUNC(pfefecto),
                      cobliga = 1
                WHERE sseguro = psseguro
                  AND nmovimi = pnmovimi
                  AND sclaben = psclaben
                  AND nriesgo = pnriesgo;
         END;
      ELSE   --psclabe is null y por lo tanto se graba una clausula especial
         traza := 5;

         UPDATE estclaubenseg
            SET cobliga = 0
          WHERE sseguro = psseguro
            AND nriesgo = pnriesgo
            AND nmovimi = pnmovimi;

         BEGIN
            traza := 6;

            INSERT INTO estclausuesp
                        (sseguro, nordcla, nmovimi, cclaesp, nriesgo, finiclau, tclaesp)
                 VALUES (psseguro, 1, pnmovimi, 1, pnriesgo, TRUNC(pfefecto), ptclaben);
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               UPDATE estclausuesp
                  SET tclaesp = ptclaben
                WHERE sseguro = psseguro
                  AND nordcla = 1
                  AND nmovimi = pnmovimi
                  AND cclaesp = 1
                  AND nriesgo = pnriesgo
                  AND finiclau = TRUNC(pfefecto);
         END;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Pac_Prod_Comu.f_grabar_beneficiarios', traza,
                     'parametros: psseguro =' || psseguro || 'psclaben =' || psclaben
                     || ' pfefecto =' || pfefecto || ' pnmovimi =' || pnmovimi || ' pnrisgo ='
                     || pnriesgo || 'ptclaben =' || ptclaben,
                     SQLERRM);
         RETURN 108190;   -- Error General
   END f_grabar_beneficiarios;

   -- Tarea 2674: En intereses para LRC.Añadimos el tramo del que queremos insertar el interés (perido anualidad).
   -- Graba un tramo de interes en cuestion. Si el valor del interes no se informa, se busca según la parametrización del producto.
   FUNCTION f_grabar_inttec2(
      psproduc IN NUMBER,
      psseguro IN NUMBER,
      pfefecto IN DATE,
      pnmovimi IN NUMBER,
      pinttec IN NUMBER DEFAULT NULL,
      ptablas IN VARCHAR2 DEFAULT 'EST',
      pvtramoini IN NUMBER DEFAULT NULL,
      pvtramofin IN NUMBER DEFAULT NULL,   -- Tarea 2674: Intereses para LRC.Añadimos el tramo que queremos insertar este interés.
      pninttec IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      /********************************************************************************************************************
                                                                                                                                                                                                                Función que graba el interés técnico de la póliza en ESTINTERTECSEG siempre y cuando haya interés técnico
         definido a nivel de producto.
         Si el parámetro PINTTEC es NULO, entonces se busca el interés parametrizado en el producto
      ********************************************************************************************************************/
      v_pinttec      NUMBER;
      v_pninttec     NUMBER;
      v_codint       NUMBER;
      num_err        NUMBER;
      v_tipo         NUMBER;
      errores        EXCEPTION;
   BEGIN
      -- Miramos si el producto tienen definido un cuadro de interés técnico
      num_err := pac_inttec.f_existe_intertecprod(psproduc);

      IF num_err = 1 THEN   -- el producto sí que tiene definido intereses técnico
         IF pinttec IS NULL THEN   --Si no informamos el interés lo buscamos según la parametrización del producto.
            -- Si el pinttec es NULO miramos buscamos el interés parametrizado en el producto
            -- le pasamos el modo..
            v_tipo := f_es_renova(psseguro, pfefecto);   /*   0 SI ES CARTERA // 1 SI ES NUEVA PRODUCCIÓN)*/

            --Bug 9803 - APD - 22/04/2009 -- el valor del v_tipo debe ser 1 (Alta); 2 (Renovacion)
            IF v_tipo = 0 THEN   -- es renovacion
               v_tipo := 2;   -- 2 = modo renovacion
            ELSE
               v_tipo := 1;   -- 1 = modo alta
            END IF;

            --Bug 9803 - APD - 22/04/2009 -- Fin
            num_err := pac_inttec.f_int_seguro_alta_renova(ptablas, psseguro, v_tipo, pfefecto,
                                                           v_pinttec, v_pninttec, pvtramoini);   -- Tarea 2674: Intereses para LRC.Añadimos el año (informado en el parámetro tramo) del que queremos buscar el interés en los productos LRC.

            IF num_err <> 0 THEN
               RETURN num_err;
            END IF;
         ELSE
            v_pinttec := pinttec;
            -- Bug 9803 - APD - 29/04/2009 - se debe devolver también el valor de pninttec
            -- INTERTECSEG.PINTTEC = valor del interes a nivel de póliza
            -- INTERTECSEG.NINNTEC = valor del interes a nivel de producto
            v_pninttec := pninttec;
         -- Bug 9803 - APD - 29/04/2009 - Fin
         END IF;

         -- Insertamos en ESTINTERTECSEG todo el tramo con el interés que tenemos.
         num_err := pk_nueva_produccion.f_ins_intertecseg(ptablas, psseguro, pnmovimi,
                                                          pfefecto, v_pinttec, v_pninttec,
                                                          pvtramoini, pvtramofin);   -- Tarea 2674: En esta función henmos insertado también los tramos ndesde nhasta.

         IF num_err <> 0 THEN
            RETURN num_err;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN errores THEN
         p_tab_error(f_sysdate, f_user, 'Pac_Prod_Comu.f_grabar_inttec2', NULL,
                     'parametros: psseguro =' || psseguro || 'pfefecto =' || pfefecto
                     || ' psproduc =' || psproduc || ' pinttec=' || pinttec,
                     'Parámetros incorrectos');
         RETURN 108190;   -- Error General
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Pac_Prod_Comu.f_grabar_inttec2', NULL,
                     'parametros: psseguro =' || psseguro || 'pfefecto =' || pfefecto
                     || ' psproduc =' || psproduc || ' pinttec=' || pinttec,
                     SQLERRM);
         RETURN 108190;   -- Error General
   END f_grabar_inttec2;

   FUNCTION f_grabar_inttec(
      psproduc IN NUMBER,
      psseguro IN NUMBER,
      pfefecto IN DATE,
      pnmovimi IN NUMBER,
      pinttec IN NUMBER DEFAULT NULL,
      ptablas IN VARCHAR2 DEFAULT 'EST',
      pvtramoini IN NUMBER DEFAULT NULL,
      pvtramofin IN NUMBER DEFAULT NULL,   -- Tarea 2674: Intereses para LRC.Añadimos el tramo que queremos insertar este interés.
      pninttec IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      /********************************************************************************************************************
                                                                                                                                                                                                             Función que graba el interés técnico de la póliza en ESTINTERTECSEG siempre y cuando haya interés técnico
         definido a nivel de producto.
         En el caso de que se informe el importe se han añadido los tramos para el caso de LRC (periodo anualidad) a los que se refiere el importe.
          Para ramos tipo LRC en el caso de que no se informe el importe se daran de alta en las tablas de intereses a nivel de póliza
          los intereses correspondientes a todas las anualidades del periodo seleccionado (parametrizados a nivel de producto).
         En el resto de casos si el parámetro PINTTEC es NULO, entonces se busca el interés parametrizado en el producto
      ********************************************************************************************************************/
      v_pinttec      NUMBER;
      v_codint       NUMBER;
      num_err        NUMBER;
      v_tipo         NUMBER;
      errores        EXCEPTION;
      anyopol        NUMBER := 0;

       --Buscamos los tramos correspondientes al producto tipo LRC con su interés para el período contratado y los
       --insertamos en la tabla de intereses por póliza.
       /*CURSOR TramosLRC (psproduc IN Number,pctipo IN NUMBER,pfecha IN Date,durac in Number)  IS
                         select id.ndesde,id.nhasta,id.ninttec
      from   intertecprod ip, intertecmov im, intertecmovdet id
      where  ip.sproduc = psproduc
      and    ip.ncodint = im.ncodint
      and    im.ctipo = pctipo
      and    im.finicio <= pfecha
      and    (im.ffin >= pfecha or im.ffin is null)
      and    im.ncodint = id.ncodint
      and    im.finicio = id.finicio
      --and    substr(TO_CHAR(id.ndesde),1,1)=durac
      and    substr(TO_CHAR(id.ndesde),1,length(id.ndesde)-3)=durac --formato dur+ 000(anual.)
      and    im.ctipo = id.ctipo;*/

      --Hasta ahora en LRC se insertaban todos los registros para una duración. Por el momento ahora sólo
      --grabaremos un registro del tipo TIR. Sólo obtendremos un registro, con lo que queda todo el tratamiento de interés a
      --nivel de póliza igual que hasta antes del tratamiento incial del producto LRC.  Como sólo obtenemos
      --un registro grabaremos 0 en los tramos.
      CURSOR tramoslrc(psproduc IN NUMBER, pctipo IN NUMBER, pfecha IN DATE, tramo IN NUMBER) IS
         SELECT 0 ndesde, 0 nhasta, ID.ninttec
           FROM intertecprod ip, intertecmov im, intertecmovdet ID
          WHERE ip.sproduc = psproduc
            AND ip.ncodint = im.ncodint
            AND im.ctipo = pctipo
            AND im.finicio <= pfecha
            AND(im.ffin >= pfecha
                OR im.ffin IS NULL)
            AND im.ncodint = ID.ncodint
            AND im.finicio = ID.finicio
            --and    substr(TO_CHAR(id.ndesde),1,1)=durac
            AND ID.ndesde = tramo   --formato dur+ 000(anual.)
            AND im.ctipo = ID.ctipo;

      pnduraci       NUMBER;
      ptipo          VARCHAR2(5);
      formpagren     NUMBER;
      num            NUMBER := 0;
      vctramtip      NUMBER;
   BEGIN
      /*   if PNMOVIMI=1 Then
                                                                                                                                   ptipo:=3; --Altas
         elsif PNMOVIMI=2 Then
              ptipo:=4;
         else --Renovaciones
              ptipo:=4;-- Otros valores se consideran Renovaciones
         end if;*/
      IF pinttec IS NOT NULL THEN   --Si el importe está informado grabamos el valor de ese tramo directamente
         num_err := f_grabar_inttec2(psproduc, psseguro, pfefecto, pnmovimi, pinttec, ptablas,
                                     pvtramoini, pvtramofin, pninttec);

         IF num_err <> 0 THEN
            RAISE errores;
         END IF;
      ELSE
         BEGIN
            ptipo := f_es_renova(psseguro, pfefecto);   /* 0: si es cartera// 1:Nueva producción */

            IF ptipo = 0 THEN
               ptipo := 4;   -- Interés Garatizado en el periodod de Renovación
            ELSE
               ptipo := 3;   --Interés Garatizado en el periodod de Alta
            END IF;

            -- Recuperamos el tipo de calculo
            SELECT ctramtip
              INTO vctramtip
              FROM intertecmov i, intertecprod p
             WHERE p.sproduc = psproduc
               AND p.ncodint = i.ncodint
               AND i.ctipo = ptipo   -- para el interes que estemos calculando
               AND i.finicio <= pfefecto
               AND(i.ffin >= pfefecto
                   OR i.ffin IS NULL);
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               RETURN 0;   -- Si no hay interes... pues nos vamos !!
         END;

         IF vctramtip = 3 THEN   -- Tarea 2674: Tipo LRC Duración-Anualidad
            pnduraci := pac_calc_comu.ff_get_duracion(ptablas, psseguro);
            formpagren := pac_calc_rentas.ff_get_formapagoren(ptablas, psseguro);

            IF formpagren IS NULL THEN
               num_err := 180602;
               RAISE errores;
            END IF;

            --Hasta ahora en LRC se insertaban todos los registros para una duración. Por el momento ahora sólo
            --grabaremos un registro del tipo TIR. Sólo obtendremos un registro, con lo que queda todo el tratamiento de interés a
            --nivel de póliza igual que hasta antes del tratamiento incial del producto LRC.  Como sólo obtenemos
            --un registro grabaremos 0 en los tramos.

            --El formato del tramo es duración + anualidad + forma pago renta (formato: daaaff)
            --En formpagren tenemos la forma de pago de la renta
            --De momento para el TIR siempre tenemos la anualidad 1 y las demás valen igual
            pnduraci := pnduraci || '001' || LPAD(formpagren, 2, '0');

            --Para este caso buscamos el TIR (tipo 6)
            FOR reg IN tramoslrc(psproduc, 6, pfefecto, pnduraci) LOOP   -- Grabamos todos los tramos periodo / anualidad (con el cambio del LRC a 01/11/2007 solo obtenemos un registro con el valor del TIR).
               num := num + 1;   -- Pasamos ya interés, pero preferimos que lo vuelva a hacer la función f_grabar_inttec2 y comprobar que lo hace bien.
               num_err := f_grabar_inttec2(psproduc, psseguro, pfefecto, pnmovimi,
                                           reg.ninttec, ptablas, reg.ndesde, reg.nhasta,
                                           pninttec);

               IF num_err <> 0 THEN
                  RAISE errores;
               END IF;
            END LOOP;

            IF num = 0 THEN
               num_err := 104742;
               RAISE errores;
            END IF;
         ELSE
-- Si no hacemos lo de siempre (un sólo valor de interés)
------------------------------------------------------------------------------------------------------------
-- Grabamos el interés técnico en INTERTECSEG
--------------------------------------------------------------------------------------------------------------
            num_err := f_grabar_inttec2(psproduc, psseguro, pfefecto, pnmovimi, NULL, ptablas);   --sss

            IF num_err <> 0 THEN
               RAISE errores;
            END IF;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN errores THEN
         p_tab_error(f_sysdate, f_user, 'Pac_Prod_Comu.f_grabar_inttec', NULL,
                     'parametros: psseguro =' || psseguro || 'pfefecto =' || pfefecto
                     || ' psproduc =' || psproduc || ' pinttec=' || pinttec || ' pnduraci:'
                     || pnduraci,
                     'Error grabando intereses');
         RETURN 108190;   -- Error General
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Pac_Prod_Comu.f_grabar_inttec', NULL,
                     'parametros: psseguro =' || psseguro || 'pfefecto =' || pfefecto
                     || ' psproduc =' || psproduc || ' pinttec=' || pinttec,
                     SQLERRM);
         RETURN 108190;   -- Error General
   END f_grabar_inttec;

   FUNCTION f_grabar_penalizacion(
      pmodo IN NUMBER,
      psproduc IN NUMBER,
      psseguro IN NUMBER,
      pfefecto IN DATE,
      pnmovimi IN NUMBER DEFAULT 1,
      ptablas IN VARCHAR2 DEFAULT 'EST')
      RETURN NUMBER IS
      /********************************************************************************************************************
                                                                              Función que graba la penalización para cada anualidad de la póliza en ESTPENALISEG,
         siempre y cuando haya penalización definida a nivel de producto
         pmodo = 1   modo alta
                 2  modo renovación
       ********************************************************************************************************************/
      CURSOR c_tipmov(psproduc IN NUMBER, pfecha IN DATE) IS
         SELECT ctipmov, niniran, nfinran
           FROM detprodtraresc d, prodtraresc p
          WHERE d.sidresc = p.sidresc
            AND p.sproduc = psproduc
            AND p.finicio <= pfecha
            AND(p.ffin > pfecha
                OR p.ffin IS NULL);

      num_err        NUMBER;
      duracion       NUMBER;
      xpenali        NUMBER;
      xtippenali     NUMBER;
      xipenali       NUMBER;
      xppenali       NUMBER;
      error          EXCEPTION;
   BEGIN
      -- Miramos si el producto tienen definido por parámetro que grabará en la tabla PENALISEG
      IF NVL(f_parproductos_v(psproduc, 'CONS_PENALI'), 0) = 1 THEN
         --- Primero borramos los registros que ya pudieran estar grabados proque siempre se recalculan
         IF ptablas = 'EST' THEN
            DELETE FROM estpenaliseg
                  WHERE sseguro = psseguro;
         END IF;

         -- Para cada anualidad hasta la duración de la póliza grabamos la penalización parametrizada en el producto
         -- Averiguamos entonces la duración de la póliza o del periodo de interés garantizado
         duracion := pac_calc_comu.ff_get_duracion(ptablas, psseguro);

         IF duracion IS NULL THEN
            RAISE error;
         END IF;

         /*
                                         IF NVL(f_parproductos_v(psproduc, 'DURPER'),0) = 1 THEN
                 -- Buscamos en ESTSEGUROS_AHO la duración periodo
                  IF ptablas = 'EST' THEN
                    BEGIN
                       SELECT ndurper
                      INTO duracion
                      FROM ESTSEGUROS_AHO
                      WHERE sseguro = psseguro;
                    EXCEPTION
                       WHEN OTHERS THEN
                         RAISE error;
                    END;
                  ELSE
                    BEGIN
                       SELECT ndurper
                      INTO duracion
                      FROM SEGUROS_AHO
                      WHERE sseguro = psseguro;
                    EXCEPTION
                       WHEN OTHERS THEN
                         RAISE error;
                    END;
                  END IF;
               ELSE
                  -- buscamos la duración de la póliza
                   IF ptablas = 'EST' THEN
                     BEGIN
                        SELECT nduraci
                       INTO duracion
                          FROM ESTSEGUROS
                       WHERE sseguro = psseguro;
                     EXCEPTION
                        WHEN OTHERS THEN
                          RAISE error;
                     END;
                   ELSE
                     BEGIN
                        SELECT nduraci
                       INTO duracion
                          FROM SEGUROS
                       WHERE sseguro = psseguro;
                     EXCEPTION
                        WHEN OTHERS THEN
                          RAISE error;
                     END;
                   END IF;
              END IF;
         */
         -- Para cada anualidad hasta la duración miramos la penalización parametrizada en el producto
         FOR reg IN c_tipmov(psproduc, pfefecto) LOOP
            IF reg.niniran < duracion THEN
               num_err := f_penalizacion(reg.ctipmov, reg.nfinran, psproduc, psseguro,
                                         pfefecto, xpenali, xtippenali, ptablas, 2);

               IF xtippenali = 1 THEN   -- importe
                  xipenali := xpenali;
                  xppenali := NULL;
               ELSIF xtippenali = 2 THEN   -- porcentaje
                  xppenali := xpenali;
                  xipenali := NULL;
               END IF;

               -- Se graba la penalización
               IF ptablas = 'EST' THEN
                  BEGIN
                     INSERT INTO estpenaliseg
                                 (sseguro, nmovimi, ctipmov, niniran, nfinran,
                                  ipenali, ppenali, clave)
                          VALUES (psseguro, pnmovimi, reg.ctipmov, reg.niniran, reg.nfinran,
                                  xipenali, xppenali, NULL);
                  EXCEPTION
                     WHEN DUP_VAL_ON_INDEX THEN
                        UPDATE estpenaliseg
                           SET ipenali = xipenali,
                               ppenali = xppenali
                         WHERE sseguro = psseguro
                           AND nmovimi = pnmovimi
                           AND ctipmov = reg.ctipmov
                           AND niniran = reg.niniran;
                  END;
               ELSE
                  BEGIN
                     INSERT INTO penaliseg
                                 (sseguro, nmovimi, ctipmov, niniran, nfinran,
                                  ipenali, ppenali, clave)
                          VALUES (psseguro, pnmovimi, reg.ctipmov, reg.niniran, reg.nfinran,
                                  xipenali, xppenali, NULL);
                  EXCEPTION
                     WHEN DUP_VAL_ON_INDEX THEN
                        UPDATE penaliseg
                           SET ipenali = xipenali,
                               ppenali = xppenali
                         WHERE sseguro = psseguro
                           AND nmovimi = pnmovimi
                           AND ctipmov = reg.ctipmov
                           AND niniran = reg.niniran;
                  END;
               END IF;
            END IF;
         END LOOP;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN error THEN
         p_tab_error(f_sysdate, f_user, 'Pac_Prod_Comu.f_grabar_penalizacion', NULL,
                     'parametros: psseguro =' || psseguro || 'pfefecto =' || pfefecto
                     || ' psproduc =' || psproduc || ' pmodo =' || pmodo || ' pnmovimi ='
                     || pnmovimi,
                     SQLERRM);
         RETURN 104506;   -- Error al obtener la duración del seguro.
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Pac_Prod_Comu.f_grabar_penalizacion', NULL,
                     'parametros: psseguro =' || psseguro || 'pfefecto =' || pfefecto
                     || ' psproduc =' || psproduc || ' pmodo =' || pmodo || ' pnmovimi ='
                     || pnmovimi,
                     SQLERRM);
         RETURN 108190;   -- Error General
   END f_grabar_penalizacion;

   FUNCTION f_emite_propuesta(
      psseguro IN NUMBER,
      pnpoliza OUT NUMBER,
      pncertif OUT NUMBER,
      pnrecibo OUT NUMBER,
      pnsolici OUT NUMBER)
      RETURN NUMBER IS
      /******************************************************************************************************************************************
                                                                               Esta función emite la propuesta generando el recibo.
          Si todo va bien retorna la póliza||certificado
          Si hay error retorna el código de error
      *************************************************************************************************************************************/
      error          EXCEPTION;
      --    v_ssegpol         NUMBER;
      num_err        NUMBER;
      v_cempres      NUMBER;
      v_cramo        NUMBER;
      v_cmodali      NUMBER;
      v_ctipseg      NUMBER;
      v_ccolect      NUMBER;
      indice         NUMBER;
      indice_e       NUMBER;
      indice_t       NUMBER;
      traza          NUMBER := 0;
      v_npoliza      NUMBER;
      v_ncertif      NUMBER;
      v_nsolici      NUMBER;
      v_nrecibo      NUMBER;
      v_cidioma      NUMBER;
      -- JLB - I - BUG 18423 COjo la moneda del producto
      vsproduc       seguros.sproduc%TYPE;
      -- JLB - f - BUG 18423 COjo la moneda del producto
      pmensaje       VARCHAR2(500);   -- BUG 27642 - FAL - 30/04/2014
   BEGIN
      traza := 1;

      SELECT cempres, cramo, cmodali, ctipseg, ccolect, npoliza, ncertif
                                                                        -- JLB - I - BUG 18423 COjo la moneda del producto
      ,
             sproduc
        -- JLB - f - BUG 18423 COjo la moneda del producto
      INTO   v_cempres, v_cramo, v_cmodali, v_ctipseg, v_ccolect, v_npoliza, v_ncertif
                                                                                      -- JLB - I - BUG 18423 COjo la moneda del producto
      ,
             vsproduc
        -- JLB - f - BUG 18423 COjo la moneda del producto
      FROM   seguros
       WHERE sseguro = psseguro;

      traza := 2;
      -- Emite la póliza
      p_emitir_propuesta(v_cempres, v_npoliza, v_ncertif, v_cramo, v_cmodali, v_ctipseg,
                         v_ccolect, NULL,
                                 -- JLB - I - BUG 18423 COjo la moneda del producto
                         --             1,
                         pac_monedas.f_moneda_producto(vsproduc),
                         -- JLB - f - BUG 18423 COjo la moneda del producto
                         f_idiomauser, indice, indice_e, indice_t, pmensaje,   -- BUG 27642 - FAL - 30/04/2014
                         NULL, NULL, 1);

      IF indice_e = 0
         AND indice >= 1 THEN
         traza := 3;

         SELECT seg.npoliza, seg.ncertif, seg.nsolici
           INTO v_npoliza, v_ncertif, v_nsolici
           FROM seguros seg
          WHERE seg.sseguro = psseguro;

         BEGIN
            SELECT MAX
                      (nrecibo)   --JRH Los suplementos de regularización pueden generar más de un recibo
              INTO v_nrecibo
              FROM recibos rec
             WHERE rec.nmovimi = (SELECT MAX(nmovimi)
                                    FROM movseguro
                                   WHERE sseguro = psseguro)
               AND rec.sseguro = psseguro;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               v_nrecibo := NULL;
            WHEN DUP_VAL_ON_INDEX THEN
               v_nrecibo := NULL;   --JRH Los suplementos de regularización pueden generar más de un recibo
            WHEN OTHERS THEN
               num_err := 102367;   -- Error al leer datos de la tabla RECIBOS
               RAISE error;
         END;
      ELSE
         num_err := 151840;   -- Error en la emisión de la póliza
         RAISE error;
      END IF;

--------------------
-- Todo ha ido OK --
--------------------
      pnpoliza := v_npoliza;
      pncertif := v_ncertif;
      pnrecibo := v_nrecibo;
      pnsolici := v_nsolici;
      RETURN 0;
   EXCEPTION
      WHEN error THEN
         RETURN num_err;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Pac_Prod_Comu.f_emite_propuesta', NULL,
                     'parametros: psseguro =' || psseguro, SQLERRM);
         RETURN 108190;   -- Error general
   END f_emite_propuesta;

-- Bug 0018812 - 21/06/2011 - JMF: afegir pctipban i exception
   FUNCTION f_inicializa_propuesta(
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
      psseguro IN OUT NUMBER,
      tab_pregun t_preguntas,
      pformpagorent NUMBER DEFAULT NULL,
      pctipban NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      /******************************************************************************************************************************************
                                                                                En esta función se grabará una póliza en las tablas EST con todos los datos y se tarifará.
            Si el parámetro psseguro NO viene infomado será una propuesta nueva, por lo tanto se inserta en las tablas EST
            Si el parámetro psseguro SI llega informado será una modificación de los datos de la propuesta.
            La función retorna:
               -- 0: si todo es correcto
                -- codigo error: si hay error.
      *************************************************************************************************************************************/
      v_obj          VARCHAR2(200) := 'PAC_PROD_COMU.f_inicializa_propuesta';
      v_pas          NUMBER := 100;
      v_par          VARCHAR2(500)
         := 'pro=' || psproduc || ' p1=' || psperson1 || ' d1=' || pcdomici1 || ' p2='
            || psperson2 || ' d2=' || pcdomici2 || ' a=' || pcagente || ' i=' || pcidioma
            || ' e=' || pfefecto || ' n=' || pnduraci || ' v=' || pfvencim || ' f='
            || pcforpag || ' b=' || pcbancar || ' c=' || psclaben || ' t=' || ptclaben
            || ' i=' || prima_inicial || ' p=' || prima_per || ' r=' || prevali || ' a1='
            || pcfallaseg1 || ' a2=' || pcfallaseg2 || ' c1=' || pcaccaseg1 || ' c2='
            || pcaccaseg2 || ' s=' || psseguro || ' r=' || pformpagorent || ' t=' || pctipban;
      v_sseguro      NUMBER;
      num_err        NUMBER;
      v_nduraci      NUMBER;
      v_ndurper      NUMBER;
      v_nmovimi      NUMBER;
      v_nriesgo      NUMBER;
      v_cactivi      NUMBER;
      v_cramo        NUMBER;
      v_cmodali      NUMBER;
      v_ctipseg      NUMBER;
      v_ccolect      NUMBER;
      v_cobliga      NUMBER;
      v_icapital     NUMBER;
      v_codint       NUMBER;
      v_pinttec      NUMBER;
      v_cempres      NUMBER;
      v_ssegpol      NUMBER;
      v_modo         NUMBER;
      v_npoliza      NUMBER;
      v_errores      ob_errores;
      -- Bug 0018812 - 21/06/2011 - JMF
      e_error        EXCEPTION;
   BEGIN
--------------------------------------------------------------------------------------------
-- Inicializamos variables a utilizar después
--------------------------------------------------------------------------------------------
      v_pas := 100;

      BEGIN
         -- Bug 0018812 - 21/06/2011 - JMF: empresa
         v_pas := 105;

         SELECT a.cramo, a.cmodali, a.ctipseg, a.ccolect, b.cempres
           INTO v_cramo, v_cmodali, v_ctipseg, v_ccolect, v_cempres
           FROM productos a, codiram b
          WHERE a.sproduc = psproduc
            AND b.cramo = a.cramo;
      EXCEPTION
         WHEN OTHERS THEN
            num_err := 104347;   -- Producto no encontrado en la tabla PRODUCTOS
            RAISE e_error;
      END;

      v_pas := 110;

      IF psseguro IS NULL THEN
         v_modo := 1;   --alta
      ELSE
         v_modo := 2;   -- modificación
      END IF;

      v_pas := 115;
      v_nmovimi := 1;
      v_nriesgo := 1;
      v_cactivi := 0;

      --     pg_cidioma := pcidioma;

      -----------------------------------------------------------------------------------------------------
-- se crea el registro de ESTSEGUROS (sólo si es modo = 1 (alta))--
------------------------------------------------------------------------------------------------------
      IF v_modo = 1 THEN
         v_pas := 120;

         IF NVL(f_parproductos_v(psproduc, 'NPOLIZA_COLECTIVO'), 0) <> 0 THEN
            v_pas := 125;
            v_npoliza := f_parproductos_v(psproduc, 'NPOLIZA_COLECTIVO');
         ELSE
            v_npoliza := NULL;
         END IF;

         -- Bug 0018812 - 21/06/2011 - JMF: empresa
         v_pas := 130;
         num_err := pk_nueva_produccion.f_ins_estseguros(psproduc, v_cempres, v_sseguro,
                                                         pcidioma, pcagente, v_npoliza);

         IF num_err <> 0 THEN
            RAISE e_error;
         END IF;
      ELSE
         v_sseguro := psseguro;
      END IF;

-----------------------------------------------------------------------
--  Insertamos el TOMADOR
-----------------------------------------------------------------------
      v_pas := 135;
      num_err := f_grabar_esttomador(v_sseguro, psperson1, pcdomici1, 1);

      IF num_err <> 0 THEN
         RAISE e_error;
      END IF;

-----------------------------------------------------------------------
-- Insertamos los ASEGURADOS
-----------------------------------------------------------------------
-- Primero borraros los que ya puedieran existir (modificación)
      v_pas := 140;
      num_err := f_borrar_estassegurats(v_sseguro);

      IF num_err <> 0 THEN
         RAISE e_error;
      END IF;

      v_pas := 145;
      num_err := f_grabar_estassegurats(v_sseguro, 1, pfefecto, psperson1, pcdomici1);

      IF num_err <> 0 THEN
         RAISE e_error;
      END IF;

      IF psperson2 IS NOT NULL THEN
         v_pas := 150;
         num_err := f_grabar_estassegurats(v_sseguro, 2, pfefecto, psperson2, pcdomici2);

         IF num_err <> 0 THEN
            RAISE e_error;
         END IF;
      END IF;

---------------------------------------------------------------------------
-- Insertamos los datos del RIESGO --
--------------------------------------------------------------------------
      v_pas := 155;
      num_err := f_grabar_estriesgos_persona(v_sseguro, 1, v_nmovimi, pfefecto, psperson1,
                                             pcdomici1);

      IF num_err <> 0 THEN
         RAISE e_error;
      END IF;

-----------------------------------------------------------------------
-- Actualizamos los datos de GESTION
-----------------------------------------------------------------------
-- Primero tenemos que saber si el parámetro nduraci viene informado con la duración de la póliza o con la duración
-- del periodo
      v_pas := 160;

      IF NVL(f_parproductos_v(psproduc, 'DURPER'), 0) = 1 THEN   -- el producto utiliza duración periodo
         v_ndurper := pnduraci;
         v_nduraci := NULL;
      ELSE
         v_ndurper := NULL;
         v_nduraci := pnduraci;
      END IF;

      v_pas := 165;
      num_err := f_actualiza_datos_gestion(v_sseguro, pcidioma, pcagente, pfefecto, v_nduraci,
                                           pfvencim, v_ndurper, pcforpag, pcbancar);

      IF num_err <> 0 THEN
         RAISE e_error;
      END IF;

----------------------------------------------------------------------------------------------------
-- Insertamos los BENEFICIARIOS
----------------------------------------------------------------------------------------------------
      v_pas := 170;
      num_err := f_grabar_beneficiarios(v_sseguro, v_nriesgo, pfefecto, psclaben, ptclaben);

      IF num_err <> 0 THEN
         RAISE e_error;
      END IF;

-----------------------------------------------------------------------------------------------------------
-- Grabamos las garantías
-----------------------------------------------------------------------------------------------------------
      v_pas := 175;

      IF NVL(f_prod_ahorro(psproduc), 0) = 1 THEN
         v_pas := 180;
         num_err := pac_prod_aho.f_grabar_garantias_aho(v_modo, v_sseguro, v_nriesgo,
                                                        v_nmovimi, pfefecto, prima_inicial,
                                                        prima_per, prevali, pcfallaseg1,
                                                        pcfallaseg2, pcaccaseg1, pcaccaseg2);

         IF num_err <> 0 THEN
            RAISE e_error;
         END IF;
      END IF;

      -- IMP Ponerlo en el caso de rentas
      v_pas := 185;

      IF NVL(f_parproductos_v(psproduc, 'ES_PRODUCTO_RENTAS'), 0) = 1 THEN
         v_pas := 190;
         num_err := pac_prod_rentas.f_grabar_garantias_rentas(v_modo, v_sseguro, v_nriesgo,
                                                              v_nmovimi, pfefecto, prima_per,
                                                              pcfallaseg1);

         IF num_err <> 0 THEN
            RAISE e_error;
         END IF;

         v_pas := 195;

         UPDATE estseguros_ren
            SET icapren = prima_per,
                pcapfall = pcfallaseg1,
                cforpag = pformpagorent
          WHERE sseguro = v_sseguro;

         -- ini Bug 0018812 - 21/06/2011 - JMF
         num_err := SQL%ROWCOUNT;

         IF num_err <> 1 THEN
            RAISE e_error;
         END IF;

         num_err := 0;
      -- fin Bug 0018812 - 21/06/2011 - JMF
      END IF;

------------------------------------------------------------------------------------------------------------
-- Grabamos el interés técnico en INTERTECSEG
--------------------------------------------------------------------------------------------------------------
      v_pas := 200;
      num_err := f_grabar_inttec(psproduc, v_sseguro, pfefecto, 1);

      IF num_err <> 0 THEN
         RAISE e_error;
      END IF;

-----------------------------------------------------------------------------------------------------------
-- Grabamos la penalización en PENALISEG
-----------------------------------------------------------------------------------------------------------
      v_pas := 205;
      num_err := f_grabar_penalizacion(1, psproduc, v_sseguro, pfefecto);

      IF num_err <> 0 THEN
         RAISE e_error;
      END IF;

      -- Rentas Grabamos y validamos preguntas a nivel de producto
      v_pas := 210;
      num_err := f_grabar_preguntas(psproduc, v_sseguro, v_nriesgo, pfefecto, tab_pregun,
                                    pcidioma);

      IF num_err <> 0 THEN
         RAISE e_error;
      END IF;

/*
                        -----------------------------------------------------------------------------------------------------------
     -- Grabamos las garantías
      -----------------------------------------------------------------------------------------------------------
      IF NVL(f_prod_ahorro(psproduc),0) = 1 THEN
        num_err := Pac_Prod_Aho.f_grabar_garantias_aho(v_modo, v_sseguro, v_nriesgo, v_nmovimi, pfefecto, prima_inicial,
           prima_per, prevali, pcfallaseg1, pcfallaseg2, pcaccaseg1, pcaccaseg2);
        IF num_err <> 0 THEN
            RAISE e_error;
        END IF;
     END IF;
*/
-----------------------------------------------------------------------------------------------------------
-- Tarifamos-----------------------------------------------------------------------------------------------------------

      -- ini Bug 0018812 - 21/06/2011 - JMF
      v_pas := 220;

      UPDATE estgaranseg
         SET cobliga = 1
       WHERE sseguro = v_sseguro;

      -- fin Bug 0018812 - 21/06/2011 - JMF
      v_pas := 225;
      num_err := pac_tarifas.f_tarifar_riesgo_tot('EST', v_sseguro, v_nriesgo, v_nmovimi,

                                                  -- JLB - I - BUG 18423 COjo la moneda del producto
                                                                   --  f_parinstalacion_n('MONEDAINST'),
                                                  pac_monedas.f_moneda_producto(psproduc),

                                                  -- JLB - f - BUG 18423 COjo la moneda del producto
                                                  pfefecto);

      IF num_err <> 0 THEN
         RAISE e_error;
      END IF;

      v_pas := 230;
      psseguro := v_sseguro;
      RETURN 0;   -- Todo OK
   EXCEPTION
      WHEN e_error THEN
         p_tab_error(f_sysdate, f_user, v_obj, v_pas, 'err=' || num_err || ' ' || v_par,
                     SQLCODE || ' ' || SQLERRM);
         RETURN num_err;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_obj, v_pas, 'err=' || num_err || ' ' || v_par,
                     SQLCODE || ' ' || SQLERRM);
         RETURN 108190;   -- Error general
   END f_inicializa_propuesta;

   FUNCTION f_cambio_ccc(psseguro IN NUMBER, pcbancar IN VARCHAR2)
      RETURN NUMBER IS
      v_ccobban      NUMBER;
      v_cramo        NUMBER;
      v_cmodali      NUMBER;
      v_ctipseg      NUMBER;
      v_ccolect      NUMBER;
      v_cagente      NUMBER;
      num_err        NUMBER;
   BEGIN
--------------------------------------------------------------------------
-- Se busca el cobrador bancario de la nueva cuenta
--------------------------------------------------------------------------
      SELECT cramo, cmodali, ctipseg, ccolect, cagente
        INTO v_cramo, v_cmodali, v_ctipseg, v_ccolect, v_cagente
        FROM estseguros
       WHERE sseguro = psseguro;

      v_ccobban := f_buscacobban(v_cramo, v_cmodali, v_ctipseg, v_ccolect, v_cagente, pcbancar,
                                 NULL, num_err);

      IF v_ccobban IS NULL THEN
         RETURN num_err;
      END IF;

--------------------------------------------------------------------------
-- Se modifican los campos estseguros.cbancar y estseguros.ccobban
--------------------------------------------------------------------------
      UPDATE estseguros
         SET cbancar = pcbancar,
             ccobban = v_ccobban
       WHERE sseguro = psseguro;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Pac_Prod_Comu.f_cambio_ccc', NULL,
                     'parametros: psseguro =' || psseguro || '  pcbancar =' || pcbancar,
                     SQLERRM);
         RETURN 108190;   -- Error General
   END f_cambio_ccc;

   FUNCTION f_cambio_beneficiario(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pnriesgo IN NUMBER,
      psclaben IN NUMBER,
      ptclaben IN VARCHAR2)
      RETURN NUMBER IS
      num_err        NUMBER;
   BEGIN
      num_err := pac_prod_comu.f_grabar_beneficiarios(psseguro, pnriesgo, f_sysdate, psclaben,
                                                      ptclaben, pnmovimi);

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Pac_Prod_Comu.f_cambio_beneficiario', NULL,
                     'parametros: psseguro =' || psseguro || '  pnmovimi =' || pnmovimi
                     || '  pnriesgo =' || pnriesgo || '  psclaben=' || psclaben
                     || '  ptclaben=' || ptclaben,
                     SQLERRM);
         RETURN 108190;   -- Error General
   END f_cambio_beneficiario;

   FUNCTION f_cambio_oficina(psseguro IN NUMBER, pcagente IN NUMBER)
      RETURN NUMBER IS
   BEGIN
--------------------------------------------------------------------------
-- Se modifican el campo estseguros.cagente
--------------------------------------------------------------------------
      UPDATE estseguros
         SET cagente = pcagente
       WHERE sseguro = psseguro;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Pac_Prod_Comu.f_cambio_oficina', NULL,
                     'parametros: psseguro =' || psseguro || '  pcagente =' || pcagente,
                     SQLERRM);
         RETURN 108190;   -- Error General
   END f_cambio_oficina;

   FUNCTION f_cambio_domicilio(psseguro IN NUMBER, pnordtom IN NUMBER, pcdomici IN NUMBER)
      RETURN NUMBER IS
      num_err        NUMBER;
      v_sperson      NUMBER;
   BEGIN
--------------------------------------------------------------------------
-- Se busca el sperson de TOMADORES para psseguro y pnordtom
--------------------------------------------------------------------------
      SELECT sperson
        INTO v_sperson
        FROM esttomadores
       WHERE sseguro = psseguro
         AND nordtom = pnordtom;

--------------------------------------------------------------------------
-- Se modifica cdomici de la tabla ESTTOMADORES
--------------------------------------------------------------------------
      num_err := pac_prod_comu.f_grabar_esttomador(psseguro, v_sperson, pcdomici, pnordtom);

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

--------------------------------------------------------------------------
-- Se modifica cdomici de la tabla ESTRIESGOS
--------------------------------------------------------------------------
      UPDATE estriesgos
         SET cdomici = pcdomici
       WHERE sseguro = psseguro
         AND sperson = v_sperson;

      UPDATE estassegurats   --JRH Tarea 6966
         SET cdomici = pcdomici
       WHERE sseguro = psseguro
         AND sperson = v_sperson;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Pac_Prod_Comu.f_cambio_domicilio', NULL,
                     'parametros: psseguro =' || psseguro || '  pnordtom =' || pnordtom
                     || '  pcdomici=' || pcdomici,
                     SQLERRM);
         RETURN 108190;   -- Error General
   END f_cambio_domicilio;

   FUNCTION f_cambio_idioma(psseguro IN NUMBER, pcidioma IN NUMBER)
      RETURN NUMBER IS
   BEGIN
--------------------------------------------------------------------------
-- Se modifican el campo estseguros.cidioma
--------------------------------------------------------------------------
      UPDATE estseguros
         SET cidioma = pcidioma
       WHERE sseguro = psseguro;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Pac_Prod_Comu.f_cambio_idioma', NULL,
                     'parametros: psseguro =' || psseguro || '  pcidioma =' || pcidioma,
                     SQLERRM);
         RETURN 108190;   -- Error General
   END f_cambio_idioma;

   -- Tarea 2674: Tipo LRC Duración-Anualidad   . Se añaden los tramos LRC si se cambia su importe.
   FUNCTION f_cambio_interes(
      psseguro IN NUMBER,
      pndurper IN NUMBER,
      ppinttec IN NUMBER,
      pnmovimi IN NUMBER,
      pvtramoini IN NUMBER DEFAULT NULL,
      pvtramofin IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      v_sproduc      NUMBER;
      v_fecha        DATE;
      v_fefecto      DATE;
      v_frevant      DATE;
      v_frevisio     DATE;
      num_err        NUMBER;
      v              VARCHAR2(100);
      errores        EXCEPTION;
   BEGIN
      SELECT sproduc, fefecto
        INTO v_sproduc, v_fefecto
        FROM estseguros
       WHERE sseguro = psseguro;

--------------------------------------------------------------------------
-- Se busca la fecha en la cual se debe recalcular los valores, es decir,
-- la fecha de alta o última renovación
--------------------------------------------------------------------------
      v_fecha := TO_DATE(frenovacion(NULL, psseguro, 1), 'yyyy/mm/dd');

-----------------------------------------
-- Se modifica la duración del periódo --
-----------------------------------------
-- sólo para los productos que su duración es por años (no por fecha de vencimiento)
      IF pndurper IS NOT NULL THEN
         -- Se actualiza el campo nduraci y fvencim sólo para aquellos productos que su duración es por años
         -- (los productos que no pueden renovar más de los años permitidos no actualizan este campo (de momento son
         -- los productos Europlazo 16 y Euroterm 16 que sólo se les permite una duración máxima de 16 años))
         IF NVL(f_parproductos_v(v_sproduc, 'DURACI'), 0) = 1 THEN   -- sólo para el Europlazo y Ibex 35 Garantizado
            BEGIN
               SELECT frevant
                 INTO v_frevant
                 FROM estseguros_aho
                WHERE sseguro = psseguro;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  v_frevant := NULL;
               WHEN OTHERS THEN
                  RETURN 180708;   -- Error al leer de ESTSEGUROS_AHO
            END;

            IF v_frevant IS NULL THEN   -- se está modificando el % interés y aún no se ha realizado ninguna renovación/revisión
               UPDATE estseguros
                  SET nduraci = pndurper,
                      fvencim = TRUNC(ADD_MONTHS(v_fefecto, pndurper * 12))
                WHERE sseguro = psseguro;
            ELSE
               UPDATE estseguros
                  SET nduraci = pndurper,
                      fvencim = TRUNC(ADD_MONTHS(v_frevant, pndurper * 12))
                WHERE sseguro = psseguro;
            END IF;
         END IF;

         -- Se actualiza el campo ndurper sólo para aquellos productos que su duración es por años pero no pueden renovar
         -- más sus años permitidos
         IF NVL(f_parproductos_v(v_sproduc, 'DURPER'), 0) = 1 THEN
            UPDATE estseguros_aho
               SET ndurper = pndurper
             WHERE sseguro = psseguro;
         END IF;

         -- Se informa la fecha de revisión de la póliza
         num_err := pac_calc_comu.f_calcula_frevisio(v_sproduc, pndurper, pndurper, v_fecha,
                                                     v_frevisio);

         IF num_err <> 0 THEN
            RETURN num_err;
         END IF;

         /*
                                          IF NVL(f_parproductos_v(v_sproduc, 'FECHAREV'),0) = 0 THEN
                  v_frevisio := null;
               ELSIF NVL(f_parproductos_v(v_sproduc, 'FECHAREV'),0) = 1 THEN
                  v_frevisio := ADD_MONTHS(v_fecha, nvl(pndurper,0) * 12);
               ELSIF NVL(f_parproductos_v(v_sproduc, 'FECHAREV'),0) = 2 THEN
                  v_frevisio := ADD_MONTHS(v_fecha, nvl(pndurper,0) * 12);
               ELSIF NVL(f_parproductos_v(v_sproduc, 'FECHAREV'),0) = 3 THEN
                  v_frevisio := ADD_MONTHS(v_fecha, 12);
               END IF;
         */
         UPDATE estseguros_aho
            SET frevisio = v_frevisio
          WHERE sseguro = psseguro;
      ELSE
         -- JRH Tarea 6966
         -- Ahorro Seguro, Pla d'estalvi, PPA, PIAS
         -- Si la fecha de última renovación <> fecha de efecto de la póliza quieres
         -- decir que ya ha renovado (ponemos la fecha de revision anterior)-
         -- Despues de tarifar ya podremos volver a dejar
         -- la fecha de revision como estaba antes de tarifar. (Este cambio ha sido
         -- necesario ya que si la póliza ya habia pasado por el proceso de renovación
         -- entonces dejaba de funcionar el suplemento de cambio de % de interés.
         -- El error se producia en la tarificación.
         IF v_fecha <> v_fefecto THEN   -- estamos en un cambio de interés en renovación
            UPDATE estseguros_aho
               SET frevisio = frevant
             WHERE sseguro = psseguro;
         END IF;
      END IF;

      num_err := f_grabar_inttec(v_sproduc, psseguro, v_fecha, pnmovimi, ppinttec, 'EST',
                                 pvtramoini, pvtramofin);

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

-------------------------------------------
-- Se graban los nuevos % de penalización
-------------------------------------------
      num_err := pac_prod_comu.f_grabar_penalizacion(2, v_sproduc, psseguro, v_fecha, pnmovimi,
                                                     'EST');

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

---------------
-- Se tarifa --
---------------
      num_err := pac_tarifas.f_tarifar_riesgo_tot('EST', psseguro, 1, pnmovimi,

-- JLB - I - BUG 18423 COjo la moneda del producto
                                          --        f_parinstalacion_n('MONEDAINST'),
                                                  pac_monedas.f_moneda_producto(v_sproduc),

-- JLB - I - BUG 18423 COjo la moneda del producto
                                                  v_fecha, 'SUP');

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      IF pndurper IS NULL
         AND v_fecha <> v_fefecto THEN   --JRH Tarea 6966
         UPDATE estseguros_aho
            SET frevisio = ADD_MONTHS(frevisio, 12)
          WHERE sseguro = psseguro;
      END IF;

      IF NVL(f_parproductos_v(v_sproduc, 'ES_PRODUCTO_RENTAS'), 0) = 1 THEN
         DECLARE
            rentabruta     NUMBER;
            rentamin       NUMBER;
            capfall        NUMBER;
            intgarant      NUMBER;
         BEGIN   -- IMP La fecha revisión ?
            num_err := pac_calc_rentas.f_get_capitales_rentas(v_sproduc, psseguro, v_fecha, 0,
                                                              1, pnmovimi, rentabruta,
                                                              rentamin, capfall, intgarant,
                                                              'EST');

            IF num_err <> 0 THEN
               RETURN num_err;
            END IF;

            UPDATE estseguros_ren   -- Actualizamos el importe de la Renta en SEGUROS_REN
               SET ibruren = rentabruta
             WHERE sseguro = psseguro;
         END;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Pac_Prod_Comu.f_cambio_interes', NULL,
                     'parametros: psseguro =' || psseguro || '  pndurper =' || pndurper
                     || '  ppinttec =' || ppinttec || '  pnmovimi = ' || pnmovimi,
                     SQLERRM);
         RETURN 108190;   -- Error General
   END f_cambio_interes;

   FUNCTION f_cambio_fall_asegurado(psseguro IN NUMBER, psperson IN NUMBER, pffallec IN DATE)
      RETURN NUMBER IS
      /***********************************************************************
                                                                               f_cambio_fall_asegurado: Funció que da de baja al asegurado fallecido.
              Parámetros de entrada: psseguro = Identificador de la póliza
                                     psperson = Identificador de la persona fallecida
                                     pffallec = Fecha de fallecimiento
              Retorna 0 => Si no hi ha error, <>0 => número d'error.
      ***********************************************************************/
      vnorden        NUMBER;
      vcramo         NUMBER;
      vcmodali       NUMBER;
      vctipseg       NUMBER;
      vccolect       NUMBER;
      vsperson2      NUMBER;
      vcdomici_aseg2 NUMBER;
      vcdomici_tom1  NUMBER;
      num_err        NUMBER;
      -- Bug 0012822 - 24/02/2010 - JMF
      n_pas          NUMBER(4) := 0;
      v_obj          VARCHAR2(500) := 'Pac_Prod_Comu.f_cambio_fall_asegurado';
      v_par          VARCHAR2(500)
         := 'parametros: psseguro =' || psseguro || ' psperson =' || psperson || ' pffallec ='
            || pffallec;
   BEGIN
      -- Modificar los campos ESTASSEGURATS.FFECFIN y ESTASSEGURATS.FFECMUE con la fecha de fallecimiento
      n_pas := 1;

      UPDATE estassegurats
         SET ffecfin = pffallec,
             ffecmue = pffallec
       WHERE sseguro = psseguro
         AND sperson = psperson;

      -- Se marca la persona como Fallecida
      -- Bug 12822 - RSC - 21/01/2010 - CEM: RT - Tratamiento fiscal rentas a 2 cabezas (personas --> per_personas8)
      -- Bug 0012822 - 24/02/2010 - JMF
      n_pas := 2;

      UPDATE estper_personas
         SET cestper = 2   -- Fallecida
                        ,
             fdefunc = NVL(pffallec, fdefunc)
       WHERE sperson = psperson;

      -- Fin Bug 12822

      -- Se da de baja la garantía de cobertura adicional de fallecimiento o accidentes si la tuviera contratada
      n_pas := 3;

      SELECT norden
        INTO vnorden
        FROM estassegurats
       WHERE sseguro = psseguro
         AND sperson = psperson;

      n_pas := 4;

      SELECT cramo, cmodali, ctipseg, ccolect
        INTO vcramo, vcmodali, vctipseg, vccolect
        FROM estseguros
       WHERE sseguro = psseguro;

      n_pas := 5;

      UPDATE estgaranseg
         SET cobliga = 0
       WHERE NVL(f_pargaranpro_v(vcramo, vcmodali, vctipseg, vccolect,
                                 pac_seguros.ff_get_actividad(psseguro, nriesgo, 'EST'),
                                 cgarant, 'TIPO'),
                 0) IN(6, 7)
         AND NVL(f_pargaranpro_v(vcramo, vcmodali, vctipseg, vccolect,
                                 pac_seguros.ff_get_actividad(psseguro, nriesgo, 'EST'),
                                 cgarant, 'PROPIETARIO'),
                 0) = vnorden
         AND sseguro = psseguro;

      -- Modificar el tomador del seguro si el asegurado fallecido es el primer titular y
      -- es el tomador del seguro
      BEGIN
         n_pas := 6;

         SELECT cdomici
           INTO vcdomici_tom1
           FROM esttomadores
          WHERE sseguro = psseguro
            AND sperson = psperson;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            vcdomici_tom1 := NULL;
      END;

      IF vnorden = 1
         AND vcdomici_tom1 IS NOT NULL THEN   -- la persona fallecida es el primer titular
         -- Se busca el sperson del segundo asegurado
         n_pas := 7;

         SELECT sperson
           INTO vsperson2
           FROM estassegurats
          WHERE sseguro = psseguro
            AND norden = 2;

         -- Se comprueba si la dirección del contrato (dirección del tomador) ya existe en las direcciones del asegurado 2
         n_pas := 8;

         -- ini Bug 0012822 - 24/02/2010 - JMF

         -- num_err := pac_personas.f_valida_misma_direccion(psperson, vcdomici_tom1, vsperson2, vcdomici_aseg2);
         -- IF num_err <> 0 THEN
         --    RETURN num_err;
         -- END IF;

         -- Si no existe la dirección, entonces pcdomici2 valdrá null
         -- Si sí existe la dirección, entonces pcdomici2 valdrá el código del cdomici del aseguro 2
         -- para la misma dirección que el asegurado 1
         SELECT MIN(dir2.cdomici)
           INTO vcdomici_aseg2
           FROM per_direcciones dir1, per_direcciones dir2
          WHERE dir1.tdomici = dir2.tdomici
            AND dir1.cpostal = dir2.cpostal
            AND dir1.cprovin = dir2.cprovin
            AND dir1.cpoblac = dir2.cpoblac
            AND dir1.csiglas = dir2.csiglas
            AND dir1.tnomvia = dir2.tnomvia
            AND dir1.nnumvia = dir2.nnumvia
            AND dir1.tcomple = dir2.tcomple
            AND dir1.sperson = psperson
            AND dir1.cdomici = vcdomici_tom1
            AND dir2.sperson = vsperson2
            AND dir2.cagente = dir1.cagente;

         -- fin Bug 0012822 - 24/02/2010 - JMF
         IF vcdomici_aseg2 IS NULL THEN   -- No existe la dirección del contrato entre las direcciones del asegurado 2
            -- Se busca la dirección del asegurado vigente (en este caso es el segundo titular)
            BEGIN
               n_pas := 9;

               SELECT NVL(MAX(cdomici), 0) + 1
                 INTO vcdomici_aseg2
                 FROM estper_direcciones   -- Bug 0012822 - 24/02/2010 - JMF
                WHERE sperson = vsperson2;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  vcdomici_aseg2 := 1;
               WHEN OTHERS THEN
                  RETURN 104474;   -- Error al leer de la tabla DIRECCIONES
            END;

            -- Se inserta la dirección del titular fallecido en las direcciones del segundo titular
            n_pas := 10;

            -- ini Bug 0012822 - 24/02/2010 - JMF
            -- INSERT INTO per_direcciones
            --    (SELECT vsperson2, cagente, vcdomici_aseg2, ctipdir, csiglas, tnomvia, nnumvia,
            --            tcomple, tdomici, cpostal, cpoblac, cprovin, f_user, f_sysdate
            --       FROM per_direcciones
            --      WHERE sperson = psperson
            --        AND cdomici = vcdomici_tom1);

            -- Bug 18940/92686 - 28/09/2011 - AMC
            INSERT INTO estper_direcciones
                        (sperson, cagente, cdomici, ctipdir, csiglas, tnomvia, nnumvia,
                         tcomple, tdomici, cpostal, cpoblac, cprovin, cusuari, fmovimi, cviavp,
                         clitvp, cbisvp, corvp, nviaadco, clitco, corco, nplacaco, cor2co,
                         cdet1ia, tnum1ia, cdet2ia, tnum2ia, cdet3ia, tnum3ia)
               SELECT vsperson2, cagente, vcdomici_aseg2, ctipdir, csiglas, tnomvia, nnumvia,
                      tcomple, tdomici, cpostal, cpoblac, cprovin, f_user, f_sysdate, cviavp,
                      clitvp, cbisvp, corvp, nviaadco, clitco, corco, nplacaco, cor2co,
                      cdet1ia, tnum1ia, cdet2ia, tnum2ia, cdet3ia, tnum3ia
                 FROM estper_direcciones
                WHERE sperson = psperson
                  AND cdomici = vcdomici_tom1;
         -- Fi Bug 18940/92686 - 28/09/2011 - AMC

         -- fin Bug 0012822 - 24/02/2010 - JMF
         END IF;

         -- Se modifica el tomador y riesgo del seguro
         n_pas := 11;

         UPDATE esttomadores
            SET sperson = vsperson2,
                cdomici = vcdomici_aseg2
          WHERE sseguro = psseguro;

         n_pas := 12;

         UPDATE estriesgos
            SET sperson = vsperson2,
                cdomici = vcdomici_aseg2
          WHERE sseguro = psseguro;
      END IF;

      n_pas := 13;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_obj, n_pas, v_par, SQLERRM);
         RETURN 108190;   -- Error General
   END f_cambio_fall_asegurado;

   /************************************************************************
                                                                            p_revision_renovacion
          realiza la revisión de interés
        pfecha : Fecha revisión
        psproduc : Producto
        psproces : IN OUT Número de proceso
       pseguro : Seguro
    *************************************************************************/
   PROCEDURE p_revision_renovacion(
      pfecha IN DATE,
      psproduc IN NUMBER,
      psproces IN OUT NUMBER,
      psseguro IN NUMBER DEFAULT NULL) IS
      /********************************************************************************************************************************
                  Proceso que realizará la revisión o renovación de la póliza según corresponda.
         Parámetros de entrada:
              . pfecha = Fecha de revisión
              . psproduc = Identificador del producto
              . psproces = Identificador del proceso
      *********************************************************************************************************************************/
      -- Este proceso de revisión/renovación debe seleccionar todas las pólizas que:
      --  . tengan la fecha de revisión igual a la fecha del proceso (pfecha)
      --  . y (tengan el parámetro 'RENOVA_REVISA' = 1 y el campo SEGUROS_AHO.NDURREV not null)
      --  . o tengan el parámetro 'RENOVA_REVISA' = 2
      -- RSC 03/07/2008 Se modifica la query del cursor. Se incluye nueva casuistica para ls pólizas
      -- de rentas.
      -- La situación es como sigue: Se ha detectado que no se puede hacer el proceso de revisión antes
      -- que el de pago de renta por que si no, nos encontramos con casos en que al realizar la revisión,
      -- el 12ª pago de renta se hace con el nuevo interés. Por eso, no se debe permitir realizar la
      -- revisión de interés si la FPPREN (SEGUROS_REN) <= FECHA_REVISION (SEGUROS_AHO)
      --
      -- Por otra parte, se debe proteger el pago de la renta para que NO se realice si la fecha del pago
      -- de renta es mayor que la fecha de revisión de interés del periodo. Esta protección se debe añadir
      -- ya que el proceso de revisión podría fallar durante algun periodo largo (llámese X), y durante
      -- todo ese periodo (hasta que funcione) no se debe generar el pago de la renta, ya que no tendría el
      -- interés que le toca.
      -- En otras palabras, la fecha de pago de la renta siempre debe ser menor a la fecha de revisión
      -- de interés ademas de ser menor de la fecha que se pasa por parámetro.
      --
      -- Nótese además, que este razonamiento solo es válido en el supuesto que el proceso de genración de
      -- pagos sea anterior al proceso de renovación de interés.
      --
      CURSOR c_poliza_rev_renova IS
         SELECT   seg1.sseguro, seg1.sproduc, seg1.npoliza, seg1.ncertif, seg2.frevisio,
                  seg2.ndurper, seg3.sseguro sseguro_ren, seg3.fppren
             FROM seguros seg1, seguros_aho seg2, seguros_ren seg3
            WHERE seg1.sseguro = seg2.sseguro
              AND seg2.sseguro = seg3.sseguro(+)   -- left join con seguros_ren
              AND seg2.frevisio <= TRUNC(pfecha)
              AND((NVL(f_parproductos_v(seg1.sproduc, 'RENOVA_REVISA'), 0) = 1
                   AND seg2.ndurrev IS NOT NULL
                   AND(seg1.fvencim = seg2.frevisio
                       OR seg1.fvencim IS NULL))
                  OR(NVL(f_parproductos_v(seg1.sproduc, 'RENOVA_REVISA'), 0) = 2
                     AND(seg1.fvencim > seg2.frevisio
                         OR seg1.fvencim IS NULL)))
              AND(seg1.sproduc = psproduc
                  OR psproduc IS NULL)
              --Bug 15072 - JRH - 16/06/2010 -- 0015072: Renovació de tipus d'interès en renovació de rendes ( bug 14806)
              AND(seg3.sseguro IS NULL
                  OR(seg3.sseguro IS NOT NULL
                     AND seg3.fppren > seg2.frevisio
                     AND NVL(f_parproductos_v(seg1.sproduc, 'REVISAR_ANTES_RENTA'), 0) = 0)
                  OR(seg3.sseguro IS NOT NULL
                     AND seg3.fppren >= seg2.frevisio
                     AND NVL(f_parproductos_v(seg1.sproduc, 'REVISAR_ANTES_RENTA'), 0) = 1))
              --Fi Bug 15072 - JRH - 16/06/2010
              AND seg1.csituac = 0
              AND seg1.creteni = 0
              AND(seg1.sseguro = psseguro
                  OR psseguro IS NULL)
         ORDER BY sproduc, npoliza, ncertif;

      /*
                                                                  Select seg1.sseguro, seg1.sproduc, seg1.npoliza, seg1.ncertif, seg2.frevisio, seg2.ndurper
       From seguros seg1, seguros_aho seg2
       Where seg1.sseguro = seg2.sseguro
         and seg2.FREVISIO <= trunc(pfecha)
         and (
              (
               NVL(f_parproductos_v(seg1.sproduc, 'RENOVA_REVISA'),0) = 1
               and
               seg2.NDURREV IS NOT NULL
               and
               (seg1.FVENCIM = seg2.FREVISIO or seg1.FVENCIM IS NULL)
              )
             or
               (
               NVL(f_parproductos_v(seg1.sproduc, 'RENOVA_REVISA'),0) = 2
               and
               (seg1.FVENCIM > seg2.FREVISIO or seg1.FVENCIM IS NULL)
               )
             )
          and (seg1.sproduc = psproduc or psproduc IS NULL)
          and seg1.csituac = 0 and seg1.creteni = 0
          order by sproduc, npoliza, ncertif;
       */
      num_err        NUMBER;
      v_ndurrev      NUMBER;
      v_pintrev      NUMBER;
      v_pnintrev     NUMBER;
      v_movimi       NUMBER;
      error          NUMBER;
      nprolin        NUMBER;
      v_sproces      NUMBER;
      v_icapital     NUMBER;
      v_cramo        NUMBER;
      v_cmodali      NUMBER;
      v_ctipseg      NUMBER;
      v_ccolect      NUMBER;
      v_cactivi      NUMBER;
      v_fecha        DATE;
      v_frevisio     DATE;
      n_cont_pol_correctas NUMBER;
      n_cont_pol_incorrectas NUMBER;
      n_cont_total_pol_procesadas NUMBER;
      error_poliza   EXCEPTION;
      v_pcaprev      NUMBER;
      -- RSC 01/10/2008
      vclavex        NUMBER;
      -- Bug 9803 - APD - 29/04/2009 -- variable que guardará el interes a nivel de poliza
      v_pintrev_pol  NUMBER;
      v_hay_movs     NUMBER(1);
   -- Bug 9803 - APD - 29/04/2009 -- Fin
   BEGIN
      -- Si el psproces no está informado, se creará la cabecera del proceso
      IF psproces IS NULL THEN
         error := f_procesini(f_user, f_parinstalacion_n('EMPRESADEF'), 'Revision/Renovacion',
                              'Revision/Renovacion:' || TO_CHAR(pfecha, 'dd/mm/yyyy'),
                              v_sproces);
      ELSE
         error :=
            f_proceslin
               (psproces,   -- Bug 12629 - RSC - 20/01/2010 - APR - error in the nocturnal process
                'Inicio proceso Revision/Renovacion '
                || TO_CHAR(f_sysdate, 'DD-MM-YYYY  HH24:MI'),
                0, nprolin, 4);
         v_sproces := psproces;
      END IF;

      -- Si el parámetro psproduc está informado, sólo se lanzará para el producto indicado.
      -- Este proceso de revisión/renovación debe seleccionar todas las pólizas que:
      --  . tengan la fecha de revisión igual a la fecha del proceso (pfecha)
      --  . y (tengan el parámetro 'RENOVA_REVISA' = 1 y el campo SEGUROS_AHO.NDURREV not null)
      --  . o tengan el parámetro 'RENOVA_REVISA' = 2
      n_cont_pol_correctas := 0;
      n_cont_pol_incorrectas := 0;
      n_cont_total_pol_procesadas := 0;

      FOR reg IN c_poliza_rev_renova LOOP
         BEGIN
            -- Contador de pólizas procesadas
            n_cont_total_pol_procesadas := n_cont_total_pol_procesadas + 1;
            v_pcaprev := NULL;   --Inicializamos la variable

            -- Para cada una de ellas
            -- Mirar si tiene informados los campos seguros_aho.ndurrev y seguros_aho.pinttec
            BEGIN
               SELECT ndurrev, pintrev
                 INTO v_ndurrev, v_pintrev_pol
                 FROM seguros_aho
                WHERE sseguro = reg.sseguro;

               IF NVL(f_parproductos_v(reg.sproduc, 'ES_PRODUCTO_RENTAS'), 0) = 1 THEN
                  SELECT pcaprev
                    INTO v_pcaprev
                    FROM seguros_ren
                   WHERE sseguro = reg.sseguro;
               END IF;
            EXCEPTION
               WHEN OTHERS THEN
                  num_err := 120445;
                  RAISE error_poliza;
            END;

            -- Si la duración no está informada, se debe informar con la duración por defecto
            IF v_ndurrev IS NULL
               AND reg.ndurper IS NOT NULL THEN
               num_err := pac_calc_aho.f_get_duracion_renova(NULL, NULL, reg.sseguro,
                                                             v_ndurrev);

               IF num_err <> 0 THEN
                  RAISE error_poliza;
               END IF;
            END IF;

            IF v_pcaprev IS NOT NULL THEN   -- % Fallec. rentas
               UPDATE seguros_ren
                  SET pcapfall = v_pcaprev
                WHERE sseguro = reg.sseguro;
            END IF;

            -- Calculamos la provisión matemática a la fecha de revisión para actualizar después la garatnía de prima
            -- v_icapital := Pac_Provmat_Formul.F_CALCUL_FORMULAS_PROVI(reg.sseguro, reg.frevisio, 'IPROVAC');
            IF NVL(f_parproductos_v(reg.sproduc, 'DURACI'), 0) = 1 THEN   -- de momento es sólo el Europlazo y Ibex 35 Garantizado
               -- aunque sólo lo hará para Europlazo ya que, de momento, el Ibex 35 Garantizado no renueva ni revisa
               -- ('RENOVA_REVISA' = 0 para el Ibex 35 Garantizado, por lo que no será seleccionado nunca en la select principal)
               UPDATE seguros
                  SET nduraci = v_ndurrev,
                      fvencim = TRUNC(ADD_MONTHS(fvencim, v_ndurrev * 12))
                WHERE sseguro = reg.sseguro;
            END IF;

            -- Bug 9803 - APD - 29/04/2009
            -- La variable v_pintrev guarda el valor del interes a nivel de poliza
            -- La variable v_pnintrev guarda el valor del interes a nivel de producto
            -- Si v_pintrev = v_pnintrev es porque NO hay un interes especifico para la poliza
            -- en la renovacion
            -- Si v_pintrev <> v_pnintrev es porque SI hay un interes especifico para la poliza
            -- en la renovacion
            -- La tabla INTERTECSEG guarda la siguiente informacion en los campos:
            -- INTERTECSEG.PINTTEC = valor del interes a nivel de póliza
            -- INTERTECSEG.NINNTEC = valor del interes a nivel de producto

            -- Se busca el interés parametrizado para el producto en la renovación
            num_err := pac_inttec.f_int_seguro_alta_renova('SEG', reg.sseguro, 2, reg.frevisio,
                                                           v_pintrev, v_pnintrev);

            IF num_err <> 0 THEN
               RAISE error_poliza;
            END IF;

            -- Si hay un interes especificado a nivel de poliza, debe coger éste en la renovación
            -- sino cogerá el interes del producto en la renovacion
            IF v_pintrev_pol IS NOT NULL THEN
               v_pintrev := v_pintrev_pol;   -- Interes a nivel de poliza
            END IF;

            -- Bug 9803 - APD - 29/04/2009 - Fin

            -- BUG 16903 - 10/12/2010 - JMP - Devolver error si existen movimientos con fecha posterior a la de revisión.
            -- BUG 26560-XVM-16/09/2013. Se añade que no tenga en cuenta los movimientos de anulación y aceptación de rescate.
            SELECT DECODE(COUNT(*), 0, 0, 1)
              INTO v_hay_movs
              FROM movseguro
             WHERE sseguro = reg.sseguro
               AND fefecto > reg.frevisio
               AND cmovseg NOT IN(10, 11);

            IF v_hay_movs = 1 THEN
               num_err := 9901727;   -- Existen movimientos con fecha de efecto posterior a la fecha de revisión
               RAISE error_poliza;
            END IF;

            -- Se graba un movimiento de revisión de intereses
            num_err := f_movseguro(reg.sseguro, NULL, 410, 2, reg.frevisio, NULL, NULL, NULL,
                                   NULL, v_movimi, f_sysdate);

            IF num_err <> 0 THEN
               RAISE error_poliza;
            END IF;

            -- Se graba el registro de historicoseguros
            num_err := f_act_hisseg(reg.sseguro, v_movimi - 1);

            IF num_err <> 0 THEN
               RAISE error_poliza;
            END IF;

            -- Se graba la nueva duración en SEGUROS_AHO.NDURPER
            -- Las pólizas que no tienen seguros_aho.ndurper informado también deben poder revisar interés
            -- (Ahorro Seguro, Pla d'Estalvi y PPA)
            IF NVL(f_parproductos_v(reg.sproduc, 'DURPER'), 0) = 1 THEN
               BEGIN
                  UPDATE seguros_aho
                     SET ndurper = v_ndurrev
                   WHERE sseguro = reg.sseguro;
               EXCEPTION
                  WHEN OTHERS THEN
                     num_err := 180228;   -- Error al actualizar la tabla SEGUROS_AHO
                     RAISE error_poliza;
               END;
            END IF;

            -- Se informa la fecha de revisión de la póliza
            -- Bug 12277 - APD - 15/12/2009 - se le añade el valor 2 en el parametro pmodo
            -- al llamar a la funcion pac_calc_comu.f_calcula_frevisio para indicar que
            -- se está en la revision
            num_err := pac_calc_comu.f_calcula_frevisio(reg.sproduc, v_ndurrev, v_ndurrev,
                                                        reg.frevisio, v_frevisio, 2);

            IF num_err <> 0 THEN
               RAISE error_poliza;
            END IF;

            /*
                                                      IF NVL(f_parproductos_v(reg.sproduc, 'FECHAREV'),0) = 0 THEN
                     v_frevisio := null;
                  ELSIF NVL(f_parproductos_v(reg.sproduc, 'FECHAREV'),0) = 1 THEN
                     v_frevisio := ADD_MONTHS(reg.frevisio, nvl(v_ndurrev,0) * 12);
                  ELSIF NVL(f_parproductos_v(reg.sproduc, 'FECHAREV'),0) = 2 THEN
                     v_frevisio := ADD_MONTHS(reg.frevisio, nvl(v_ndurrev,0) * 12);
                  ELSIF NVL(f_parproductos_v(reg.sproduc, 'FECHAREV'),0) = 3 THEN
                     v_frevisio := ADD_MONTHS(reg.frevisio, 12);
                  END IF;
            */

            -- Se graba el nuevo interés técnico en INTERTECSEG
            num_err := pac_prod_comu.f_grabar_inttec(reg.sproduc, reg.sseguro, reg.frevisio,
                                                     v_movimi, v_pintrev, 'SEG', NULL, NULL,
                                                     v_pnintrev);

            IF num_err <> 0 THEN
               RAISE error_poliza;
            END IF;

            -- Se duplican las garantias
            num_err := f_dupgaran(reg.sseguro, reg.frevisio, v_movimi);

            IF num_err <> 0 THEN
               RAISE error_poliza;
            END IF;

            -- Se duplica pregunseg
            num_err := f_duppregunseg(reg.sseguro, v_movimi);

            IF num_err <> 0 THEN
               RAISE error_poliza;
            END IF;

            -- Se duplica pregungaranseg
            num_err := f_duppregungaranseg(reg.sseguro, reg.frevisio, v_movimi);

            IF num_err <> 0 THEN
               RAISE error_poliza;
            END IF;

            -- aCTUALIZAMOS LA FTARIFA DE LAS GARANTÍAS
            UPDATE garanseg
               SET ftarifa = reg.frevisio
             WHERE sseguro = reg.sseguro
               AND nmovimi = v_movimi;

            -- La penalización se debe grabar después de grabar las garantías, ya que para calcular la penalización
            -- utiliza los datos insertados en garantías
            -- Se graban los nuevos % de penalización
            num_err := pac_prod_comu.f_grabar_penalizacion(2, reg.sproduc, reg.sseguro,
                                                           reg.frevisio, v_movimi, 'SEG');

            IF num_err <> 0 THEN
               RAISE error_poliza;
            END IF;

            -- Modificar la prima de la garantia de prima período (pargarantia 'TIPO' = 3) con la provisión actual de la póliza
            SELECT cramo, cmodali, ctipseg, ccolect
              INTO v_cramo, v_cmodali, v_ctipseg, v_ccolect
              FROM seguros
             WHERE sseguro = reg.sseguro;

            -- Si el producto tiene Evolución de Provisión Matemática, se debe actualizar su prima
            IF NVL(f_parproductos_v(reg.sproduc, 'EVOLUPROVMATSEG'), 0) = 1
               OR NVL(f_parproductos_v(reg.sproduc, 'ES_PRODUCTO_RENTAS'), 0) = 1 THEN
               -- Calculamos la provisión matemática a la fecha de revisión para actualizar después la garantía de prima
               v_icapital := pac_provmat_formul.f_calcul_formulas_provi(reg.sseguro,
                                                                        reg.frevisio,
                                                                        'IPROVAC');

               UPDATE garanseg
                  SET icapital = v_icapital
                WHERE sseguro = reg.sseguro
                  AND nriesgo = 1
                  AND nmovimi = v_movimi
                  AND f_pargaranpro_v(v_cramo, v_cmodali, v_ctipseg, v_ccolect,
                                      pac_seguros.ff_get_actividad(reg.sseguro, nriesgo),
                                      cgarant, 'TIPO') = 3;
            /*
                                                              UPDATE seguros_ren
                 Set icapren=v_icapital
                 Where sseguro = reg.sseguro;
            */
            -- Lo hacemos aquí porque para las fórmulas de capital garantizado necesita tener ya las
            -- fechas correctas de renovación, en cambio para AH, PE y PPA no.
            -- Para Rentas no se debe hacer hasta despues de tarifar
            END IF;

            --BUG 10069 - JRH - 01/07/2009 Actualizamos seguros_aho antes de tarif
            IF NVL(f_parproductos_v(reg.sproduc, 'ACTFECHASPREVTARIF'), 0) = 1 THEN
               UPDATE seguros_aho
                  SET frevant = reg.frevisio,
                      frevisio = v_frevisio
                WHERE sseguro = reg.sseguro;
            END IF;

            --Fi BUG 10069 - JRH - 01/07/2009
            -- Tarifar
            num_err :=
               pac_tarifas.f_tarifar_riesgo_tot(NULL, reg.sseguro, 1, v_movimi,

-- JLB - I - BUG 18423 COjo la moneda del producto
                                          --         1,
                                                pac_monedas.f_moneda_producto(reg.sproduc),

-- JLB - I - BUG 18423 COjo la moneda del producto
                                                reg.frevisio, 'CAR');

            IF num_err <> 0 THEN
               RAISE error_poliza;
            END IF;

            /*
                                                IF NVL(f_parproductos_v(reg.sproduc,'ES_PRODUCTO_RENTAS'),0) = 1 THEN
               declare
                rentabruta number;
                rentamin number;
                 capfall number;
                intgarant number;
              begin -- IMP La fecha revisión ?
                num_err := pac_calc_rentas.f_get_capitales_rentas(reg.sproduc, reg.sseguro, reg.frevisio,0,1,v_movimi,rentabruta, rentamin, capfall,intgarant,'SEG');
                IF num_err <> 0 THEN
                    RAISE Error_Poliza;
                 END IF;
                 UPDATE seguros_ren
                  Set ibruren=rentabruta
                  Where sseguro = reg.sseguro;
               end;
            END IF;
            */

            /*
                                                      -- Se insertan en CTASEGURO los nuevos valores calculados
                  IF trunc(f_sysdate) < reg.frevisio THEN
                     v_fecha := to_date((to_char(reg.frevisio,'dd/mm/yyyy') || ' 00:00:01'), 'dd/mm/yyyy hh24:mi:ss');
                  ELSIF trunc(f_sysdate) > reg.frevisio THEN
                     v_fecha := to_date((to_char(reg.frevisio,'dd/mm/yyyy') || ' 23:59:59'), 'dd/mm/yyyy hh24:mi:ss');
                  ELSIF trunc(f_sysdate) = reg.frevisio THEN
                     v_fecha := f_sysdate;
                  END IF;
            */
            --dbms_output.put_line('antes de saldo====================================================');
            --num_err := pac_ctaseguro.F_INSCTA_PROV_CAP(reg.sseguro, v_fecha, 'R', psproces);
            -- Bug 9803 - APD - 22/04/2009 - se añade la condición del parproducto SALDO_AE para que no
            -- inserte en ctaseguro el saldo en la renovación
            IF NVL(f_parproductos_v(reg.sproduc, 'ES_PRODUCTO_RENTAS'), 0) <> 1
               AND NVL(f_parproductos_v(reg.sproduc, 'SALDO_AE'), 0) = 1 THEN
               num_err := pac_ctaseguro.f_inscta_prov_cap(reg.sseguro, reg.frevisio, 'R',
                                                          v_sproces);   -- Bug 12629 - RSC - 20/01/2010 - APR - error in the nocturnal process

               IF num_err <> 0 THEN
                  RAISE error_poliza;
               END IF;

               IF pac_ctaseguro.f_tiene_ctashadow(reg.sseguro, NULL) = 1 THEN
                  num_err := pac_ctaseguro.f_inscta_prov_cap_shw(reg.sseguro, reg.frevisio,
                                                                 'R', v_sproces);   -- Bug 12629 - RSC - 20/01/2010 - APR - error in the nocturnal process

                  IF num_err <> 0 THEN
                     RAISE error_poliza;
                  END IF;
               END IF;

               -- recalculamos las líneas de saldo que pueda haber posteriores a la fecha de renovación
               -- (puede ser si en algún momento da error la renovación y mientras se arregla la póliza se cobra
               -- alguna aportación.
               num_err := pac_ctaseguro.f_recalcular_lineas_saldo(reg.sseguro,
                                                                  reg.frevisio + 1);

               IF num_err <> 0 THEN
                  RAISE error_poliza;
               END IF;

               IF pac_ctaseguro.f_tiene_ctashadow(reg.sseguro, NULL) = 1 THEN
                  num_err := pac_ctaseguro.f_recalcular_lineas_saldo_shw(reg.sseguro,
                                                                         reg.frevisio + 1);

                  IF num_err <> 0 THEN
                     RAISE error_poliza;
                  END IF;
               END IF;
            END IF;

            -- Bug 9803 - APD - 22/04/2009 - Fin

            -- Acutlizamos el campo IRESERVA  de seguros_ren --------
            IF NVL(f_parproductos_v(reg.sproduc, 'ES_PRODUCTO_RENTAS'), 0) = 1 THEN
               UPDATE seguros_ren   --JRH Rentas
                  SET ireserva = v_icapital
                WHERE sseguro = reg.sseguro;
            END IF;

            BEGIN
               UPDATE seguros_aho
                  SET frevant = reg.frevisio,
                      frevisio = v_frevisio
                WHERE sseguro = reg.sseguro;
            EXCEPTION
               WHEN OTHERS THEN
                  num_err := 180228;   -- Error al actualizar la tabla SEGUROS_AHO
                  RAISE error_poliza;
            END;

            BEGIN
               -- Se inicializan los valores
               UPDATE seguros_aho
                  SET ndurrev = NULL,
                      pintrev = NULL
                WHERE sseguro = reg.sseguro;

               UPDATE seguros_ren
                  SET pcaprev = NULL
                WHERE sseguro = reg.sseguro;
            EXCEPTION
               WHEN OTHERS THEN
                  num_err := 180228;   -- Error al actualizar la tabla SEGUROS_AHO
            END;

            IF NVL(f_parproductos_v(reg.sproduc, 'ES_PRODUCTO_RENTAS'), 0) = 1 THEN
               num_err := pac_ctaseguro.f_inscta_prov_cap(reg.sseguro, reg.frevisio, 'R',
                                                          v_sproces);   -- Bug 12629 - RSC - 20/01/2010 - APR - error in the nocturnal process

               IF num_err <> 0 THEN
                  RAISE error_poliza;
               END IF;

               IF pac_ctaseguro.f_tiene_ctashadow(reg.sseguro, NULL) = 1 THEN
                  num_err := pac_ctaseguro.f_inscta_prov_cap_shw(reg.sseguro, reg.frevisio,
                                                                 'R', v_sproces);   -- Bug 12629 - RSC - 20/01/2010 - APR - error in the nocturnal process

                  IF num_err <> 0 THEN
                     RAISE error_poliza;
                  END IF;
               END IF;

               -- recalculamos las líneas de saldo que pueda haber posteriores a la fecha de renovación
               -- (puede ser si en algún momento da error la renovación y mientras se arregla la póliza se cobra
               -- alguna aportación.
               num_err := pac_ctaseguro.f_recalcular_lineas_saldo(reg.sseguro,
                                                                  reg.frevisio + 1);

               IF num_err <> 0 THEN
                  RAISE error_poliza;
               END IF;

               IF pac_ctaseguro.f_tiene_ctashadow(reg.sseguro, NULL) = 1 THEN
                  num_err := pac_ctaseguro.f_recalcular_lineas_saldo_shw(reg.sseguro,
                                                                         reg.frevisio + 1);

                  IF num_err <> 0 THEN
                     RAISE error_poliza;
                  END IF;
               END IF;
            END IF;

            -- Renovación Rentas
            IF NVL(f_parproductos_v(reg.sproduc, 'ES_PRODUCTO_RENTAS'), 0) = 1 THEN
               -- RSC 01/10/2008
               BEGIN
                  SELECT g.clave
                    INTO vclavex
                    FROM garanformula g
                   WHERE f_pargaranpro_v(v_cramo, v_cmodali, v_ctipseg, v_ccolect,
                                         pac_seguros.ff_get_actividad(reg.sseguro, 1),
                                         g.cgarant, 'TIPO') = 8
                     AND g.cramo = v_cramo
                     AND g.cmodali = v_cmodali
                     AND g.ctipseg = v_ctipseg
                     AND g.ccolect = v_ccolect
                     AND g.cactivi = pac_seguros.ff_get_actividad(reg.sseguro, 1)
                     AND g.ccampo = 'ICAPCAL';
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     BEGIN
                        SELECT g.clave
                          INTO vclavex
                          FROM garanformula g
                         WHERE f_pargaranpro_v(v_cramo, v_cmodali, v_ctipseg, v_ccolect,
                                               pac_seguros.ff_get_actividad(reg.sseguro, 1),
                                               g.cgarant, 'TIPO') = 8
                           AND g.cramo = v_cramo
                           AND g.cmodali = v_cmodali
                           AND g.ctipseg = v_ctipseg
                           AND g.ccolect = v_ccolect
                           AND g.cactivi = 0
                           AND g.ccampo = 'ICAPCAL';
                     EXCEPTION
                        WHEN OTHERS THEN
                           vclavex := NULL;
                     END;
                  WHEN OTHERS THEN
                     vclavex := NULL;
               END;

               --v_icapital := Pac_Provmat_Formul.F_CALCUL_FORMULAS_PROVI(reg.sseguro, reg.frevisio, 'ICAPCAL');
               error := pac_calculo_formulas.calc_formul(reg.frevisio, reg.sproduc, 0, 52, 1,
                                                         reg.sseguro, vclavex, v_icapital,
                                                         v_movimi, NULL, 2, reg.frevisio, 'R');

               UPDATE garanseg g
                  SET g.icapital = v_icapital,
                      g.icaptot = v_icapital
                WHERE g.sseguro = reg.sseguro
                  AND nmovimi = v_movimi
                  AND nriesgo = 1
                  AND f_pargaranpro_v(v_cramo, v_cmodali, v_ctipseg, v_ccolect,
                                      pac_seguros.ff_get_actividad(reg.sseguro, nriesgo),
                                      g.cgarant, 'TIPO') = 8;

               UPDATE seguros_ren   -- JRH Rentas
                  SET ibruren = v_icapital
                WHERE sseguro = reg.sseguro;

               -- BUG 16217 - 09/2010 - JRH  -  Cuadro de provisiones
               IF NVL(f_parproductos_v(reg.sproduc, 'CUADROEVOLUPROV'), 0) = 1 THEN
                  num_err := pk_rentas.f_gen_evoluprovmatseg(reg.sseguro, v_movimi);

                  IF num_err <> 0 THEN
                     p_tab_error(f_sysdate, f_user, 'Pac_Prod_Comu.p_revision_renovacion',
                                 NULL, 'parametros: psseguro =' || reg.sseguro,
                                 num_err || ' ' || 'En cuadro de provision');
                     RAISE error_poliza;
                  END IF;
               END IF;
            -- Fi BUG 16217 - 09/2010 - JRH
            END IF;

            -- Todo OK
            COMMIT;
            -- Número de pólizas revisadas/renovadas correctamente
            n_cont_pol_correctas := n_cont_pol_correctas + 1;
            error := f_proceslin(v_sproces,
                                 f_axis_literales(180724, f_idiomauser) || ': ' || reg.npoliza
                                 || '/' || reg.ncertif,
                                 reg.sseguro, nprolin, 4);
         EXCEPTION
            WHEN error_poliza THEN
               ROLLBACK;
               p_tab_error(f_sysdate, f_user, 'Pac_Prod_Comu.p_revision_renovacion', NULL,
                           'parametros: psseguro =' || reg.sseguro, SQLERRM);
               -- Número de pólizas revisadas/renovadas incorrectamente
               n_cont_pol_incorrectas := n_cont_pol_incorrectas + 1;
               error := f_proceslin(v_sproces,
                                    num_err || ' - '
                                    || f_axis_literales(num_err, f_idiomauser),
                                    reg.sseguro, nprolin, 1);
         END;
      END LOOP;

      error := f_proceslin(v_sproces,
                           'Nº Total de pólizas procesadas = ' || n_cont_total_pol_procesadas
                           || ' ; Nº Pólizas Correctas = ' || n_cont_pol_correctas
                           || ' , Nº Pólizas Incorrectas = ' || n_cont_pol_incorrectas,
                           0, nprolin, 4);
      error := f_proceslin(v_sproces,
                           'Fin proceso Revision/Renovacion '
                           || TO_CHAR(f_sysdate, 'DD-MM-YYYY  HH24:MI'),
                           0, nprolin, 4);

      IF psproces IS NULL THEN
         error := f_procesfin(v_sproces, error);
         -- Bug 12629 - RSC - 20/01/2010 - APR - error in the nocturnal process
         psproces := v_sproces;
      -- Fin Bug 12629
      END IF;
   -- Bug 12629 - RSC - 20/01/2010 - APR - error in the nocturnal process
   --psproces := v_sproces;
   -- Fin Bug 12629
   END p_revision_renovacion;

   --BUG 11777 - 25/11/2009 - JRB - Se elimina la funcion f_emision_cobro_recibo

   --BUG 11777 - 25/11/2009 - JRB - Se elimina la funcion f_cobro_rimpagados

   --BUG 11777 - 25/11/2009 - JRB - Se elimina la funcion f_cobro_recibo_online
   FUNCTION f_cambio_rescate_parcial(
      psseguroreal IN NUMBER,
      psseguro IN NUMBER,
      pfecha IN DATE,
      v_movimi IN NUMBER,
      pirescatep IN NUMBER)
      RETURN NUMBER IS
      vcmovseg       NUMBER;
      --v_movimi  NUMBER;
      v_sproduc      NUMBER;
      v_cramo        NUMBER;
      v_cmodali      NUMBER;
      v_ctipseg      NUMBER;
      v_ccolect      NUMBER;
      num_err        NUMBER;
      error_poliza   EXCEPTION;
      v_icapital     NUMBER;
      v_pintrev      NUMBER;
      ntraza         NUMBER := 0;
      v_fefecto      DATE;
      v_cagrpro      seguros.cagrpro%TYPE;
      v_factor       NUMBER;
      v_moneda       NUMBER;
   BEGIN
      ntraza := 1;

      UPDATE estseguros
         SET creteni = 0
       WHERE sseguro = psseguro;   -- Es necesario porque el iniciar suplemento tiene un pragma y no ve que antes le hemos hecho un creteni=0 en seguros

      SELECT cmovseg
        INTO vcmovseg
        FROM codimotmov
       WHERE cmotmov = 550;

      -- Obtenemos datos del seguro
      ntraza := 2;

      SELECT cramo, cmodali, ctipseg, ccolect, sproduc, fefecto, cagrpro
        INTO v_cramo, v_cmodali, v_ctipseg, v_ccolect, v_sproduc, v_fefecto, v_cagrpro
        FROM estseguros
       WHERE sseguro = psseguro;

      UPDATE estgaranseg
         SET finiefe = pfecha
       WHERE sseguro = psseguro
         AND ffinefe IS NULL
         AND nmovimi = v_movimi;

      UPDATE estpregungaranseg
         SET finiefe = pfecha
       WHERE sseguro = psseguro
         AND nmovimi = v_movimi;

      -- aCTUALIZAMOS LA FTARIFA DE LAS GARANTÍAS
      ntraza := 8;

      UPDATE estgaranseg
         SET ftarifa = pfecha
       WHERE sseguro = psseguro
         AND nmovimi = v_movimi;

      -- La penalización se debe grabar después de grabar las garantías, ya que para calcular la penalización
      -- utiliza los datos insertados en garantías
      -- Se graban los nuevos % de penalización
      /*
                        ntraza := 9;
      num_err := produccion_comu.F_GRABAR_PENALIZACION(2, v_sproduc, psseguro, pfecha, V_MOVIMI, 'EST');
      IF num_err <> 0 THEN
         Raise Error_Poliza;
      END IF;
      */

      -- Bug 12136 - JRH - 10/03/2010 - JRH - tratamiento rescate parcial rentas
      IF v_cagrpro <> 10 THEN
         -- Si el producto tiene Evolución de Provisión Matemática, se debe actualizar su prima
         IF NVL(f_parproductos_v(v_sproduc, 'EVOLUPROVMATSEG'), 0) = 1 THEN
            ntraza := 10;
            v_icapital := pac_provmat_formul.f_calcul_formulas_provi(psseguroreal, pfecha,
                                                                     'IPROVAC');
            -- Provision actual - Importe de rescate parcial = Provision despues del rescates
            v_icapital := v_icapital - pirescatep;
            ntraza := 11;

            UPDATE estgaranseg
               SET icapital = v_icapital
             WHERE sseguro = psseguro
               AND nriesgo = 1
               AND nmovimi = v_movimi
               AND f_pargaranpro_v(v_cramo, v_cmodali, v_ctipseg, v_ccolect,
                                   pac_seguros.ff_get_actividad(psseguro, nriesgo, 'EST'),
                                   cgarant, 'TIPO') = 3;

            -- Tarifar
            ntraza := 12;
            num_err :=
               pac_tarifas.f_tarifar_riesgo_tot('EST', psseguro, 1, v_movimi,

-- JLB - I - BUG 18423 COjo la moneda del producto
                                          --         1,
                                                pac_monedas.f_moneda_producto(v_sproduc),

-- JLB - I - BUG 18423 COjo la moneda del producto
                                                pfecha, 'CAR');

            IF num_err <> 0 THEN
               RAISE error_poliza;
            END IF;
         ELSE   -- Ahorro Seguro
            ntraza := 10;
            v_icapital := pac_provmat_formul.f_calcul_formulas_provi(psseguroreal, pfecha,
                                                                     'IPROVAC');
            ntraza := 11;

            UPDATE estgaranseg
               SET icapital = v_icapital
             WHERE sseguro = psseguro
               AND nriesgo = 1
               AND nmovimi = v_movimi
               AND f_pargaranpro_v(v_cramo, v_cmodali, v_ctipseg, v_ccolect,
                                   pac_seguros.ff_get_actividad(psseguro, nriesgo, 'EST'),
                                   cgarant, 'TIPO') = 3;

            -- Tarifar
            ntraza := 12;
            num_err :=
               pac_tarifas.f_tarifar_riesgo_tot('EST', psseguro, 1, v_movimi,

                                                -- JLB - I - BUG 18423 COjo la moneda del producto
                                                                              --         1,
                                                pac_monedas.f_moneda_producto(v_sproduc),

                                                -- JLB - I - BUG 18423 COjo la moneda del producto
                                                pfecha, 'CAR');

            IF num_err <> 0 THEN
               RAISE error_poliza;
            END IF;
         END IF;
      ELSE
         ntraza := 20;
         -- JLB - I - BUG 18423 COjo la moneda del producto
           -- v_moneda := f_parinstalacion_n('MONEDAINST');
         v_moneda := pac_monedas.f_moneda_producto(v_sproduc);
         -- JLB - f - BUG 18423 COjo la moneda del producto
         ntraza := 21;
         v_icapital := pac_provmat_formul.f_calcul_formulas_provi(psseguroreal, pfecha,
                                                                  'IPROVAC');
         ntraza := 22;
         v_factor := (v_icapital - pirescatep) / v_icapital;

         IF v_factor < 0
            OR v_factor IS NULL THEN
            RAISE error_poliza;
         END IF;

         ntraza := 23;

         UPDATE estgaranseg
            SET icapital = f_round(icapital * v_factor, v_moneda)
          WHERE sseguro = psseguro
            AND nriesgo = 1
            AND nmovimi = v_movimi
            AND f_pargaranpro_v(v_cramo, v_cmodali, v_ctipseg, v_ccolect,
                                pac_seguros.ff_get_actividad(psseguro, nriesgo, 'EST'),
                                cgarant, 'TIPO') = 9;

         ntraza := 24;

         UPDATE estgaranseg
            SET icapital = f_round(icapital * v_factor, v_moneda)
          WHERE sseguro = psseguro
            AND nriesgo = 1
            AND nmovimi = v_movimi
            AND f_pargaranpro_v(v_cramo, v_cmodali, v_ctipseg, v_ccolect,
                                pac_seguros.ff_get_actividad(psseguro, nriesgo, 'EST'),
                                cgarant, 'TIPO') = 8;

         ntraza := 25;

         UPDATE estgaranseg
            SET icapital = f_round(icapital * v_factor, v_moneda)
          WHERE sseguro = psseguro
            AND nriesgo = 1
            AND nmovimi = v_movimi
            AND f_pargaranpro_v(v_cramo, v_cmodali, v_ctipseg, v_ccolect,
                                pac_seguros.ff_get_actividad(psseguro, nriesgo, 'EST'),
                                cgarant, 'TIPO') = 3;

         ntraza := 26;

         UPDATE estseguros_ren
            SET icapren = f_round(icapren * v_factor, v_moneda),
                ireserva = f_round(ireserva * v_factor, v_moneda),
                ibruren = f_round(ibruren * v_factor, v_moneda)
          WHERE sseguro = psseguro;

         ntraza := 27;
      END IF;

      -- Fi Bug 12136 - JRH - 10/03/2010

      /*
                        -- EN POST SUPLEMENTO:
      ntraza := 13;
      num_err := pac_ctaseguro.F_INSCTA_PROV_CAP(psseguro, pfecha, 'R', NULL);
      IF num_err <> 0 THEN
         Raise Error_Poliza;
      END IF;
      -- recalculamos las líneas de saldo que pueda haber posteriores a la fecha de renovación
      -- (puede ser si en algún momento da error la renovación y mientras se arregla la póliza se cobra
      -- alguna aportación.
      ntraza := 14;
      num_err := pac_ctaseguro.f_recalcular_lineas_saldo(psseguro, pfecha+1);
      IF num_err <> 0 THEN
         Raise Error_Poliza;
      END IF;
      */
      RETURN 0;
   EXCEPTION
      WHEN error_poliza THEN
         p_tab_error(f_sysdate, f_user,
                     'Produccion_Comu.f_cambio_rescate_parcial. Error = ' || num_err, ntraza,
                     'parametros: psseguro =' || psseguro || ' pfecha =' || pfecha
                     || ' pirescatep =' || pirescatep,
                     SQLERRM);
         RETURN 108190;   -- Error General
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Produccion_Comu.f_cambio_rescate_parcial', NULL,
                     'parametros: psseguro =' || psseguro || ' pfecha =' || pfecha
                     || ' pirescatep =' || pirescatep,
                     SQLERRM);
         RETURN 108190;   -- Error General
   END f_cambio_rescate_parcial;

   -- Bug 5467 - 10/02/2009 - RSC - CRE - Desarrollo de sistema de copago
   FUNCTION f_grabar_copago(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      porden IN NUMBER,
      ppersona IN NUMBER,
      pfinicio IN DATE,
      pffinal IN DATE,
      pbancar IN NUMBER,
      pforpag IN NUMBER,
      ptipo IN NUMBER,
      pporcen IN NUMBER,
      pimporte IN NUMBER,
      ptipban IN NUMBER)
      RETURN NUMBER IS
      /**************************************************************************************************
                Función que inserta o modifica los datos del tomador en ESTTOMADORES
      **************************************************************************************************/
      cont           NUMBER;
   BEGIN
      BEGIN
         INSERT INTO aportaseg
                     (sseguro, nmovimi, norden, sperson, finiefe, ffinefe, cbancar,
                      cforpag, ctipimp, pimport, iimport, ctipban)
              VALUES (psseguro, pnmovimi, porden, ppersona, pfinicio, pffinal, pbancar,
                      pforpag, ptipo, pporcen, pimporte, ptipban);
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            UPDATE aportaseg
               SET sperson = ppersona,
                   finiefe = pfinicio,
                   ffinefe = pffinal,
                   cbancar = pbancar,
                   cforpag = pforpag,
                   ctipimp = ptipo,
                   pimport = pporcen,
                   iimport = pimporte,
                   ctipban = ptipban,
                   nmovimi = pnmovimi
             WHERE sseguro = psseguro
               AND norden = porden;
      END;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Pac_Prod_Comu.f_grabar_copago', NULL,
                     'insert o update con psseguro =' || psseguro || 'pnmovimi =' || pnmovimi
                     || ' porden =' || porden,
                     SQLERRM);
         RETURN 108190;   -- Error General
   END f_grabar_copago;

-- Fin Bug 5467
   /***************************************************************************
      -- BUG 24685 - 2013-02-14 - AEG
      Formatea numero de poliza real
      param in  psseguro:  numero del seguro para traer el ramo
      param in  pnpolizamanual:  numero de la póliza digitada por el usuario.
      return: NUMBER (numero de poliza real, null si hay errores.
   ***************************************************************************/
   FUNCTION f_obtener_polizamanual(psproduc IN NUMBER, pnpolizamanual IN NUMBER)
      RETURN NUMBER IS
      v_numpol       NUMBER(10);
      vparam         VARCHAR2(500)
                  := 'Param: psproduc= ' || psproduc || ' ,pnpolizamanual= ' || pnpolizamanual;
      vpasexec       NUMBER(8) := 1;
      vobject        VARCHAR2(200) := 'Pac_Prod_Comu.f_obtener_polizamanual';
   BEGIN
      SELECT SUBSTR(cramo, -2, 2)
        INTO v_numpol
        FROM productos
       WHERE sproduc = psproduc;

      v_numpol := v_numpol * 1000000 + pnpolizamanual;
      vpasexec := 2;

      IF LENGTH(TO_CHAR(v_numpol)) != 8 THEN
         RETURN NULL;
      END IF;

      RETURN v_numpol;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Pac_Prod_Comu.f_obtener_polizamanual', NULL,
                     'vparam =' || vparam, SQLERRM);
         --  RETURN 108190;   -- Error General
         RETURN NULL;
   END f_obtener_polizamanual;

   /***************************************************************************
      -- BUG 24685 - 2013-02-14 - AEG
      Actualiza estado de reserva rangos
      param in  ptipo  :  tipo del rango a actualizar
      param in  pcramo :  pcramo del rango a actualizar
      param in  pnpolizamanual:  numero de la póliza digitada por el usuario.
      return: NUMBER (1 error 0 no error).
   ***************************************************************************/
   FUNCTION f_asignarango(ptipo IN NUMBER, pcramo IN NUMBER, npolizamanual IN NUMBER)
      RETURN NUMBER IS
   BEGIN
      UPDATE reserva_rangos
         SET asignado = 1,
             ultpoliza_rango = npolizamanual   --BUG: 34915/210493: 24/07/2015: CJM
       WHERE ctipo = ptipo
         AND csucursal = pac_redcomercial.f_busca_padre(pac_md_common.f_get_cxtempresa,
                                                        pac_md_common.f_get_cxtagente, NULL,
                                                        f_sysdate)
         AND cramo = pcramo
         AND npolizamanual BETWEEN inirango AND finrango;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Pac_Prod_Comu.f_asignarango', NULL,
                     ' update en reserva_rango, ptipo=' || ptipo || 'pcramo =' || pcramo
                     || ' npolizamanual =' || npolizamanual,
                     SQLERRM);
         RETURN 1;
   END f_asignarango;
END pac_prod_comu;

/

  GRANT EXECUTE ON "AXIS"."PAC_PROD_COMU" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_PROD_COMU" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_PROD_COMU" TO "PROGRAMADORESCSI";
