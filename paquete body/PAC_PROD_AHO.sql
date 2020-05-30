--------------------------------------------------------
--  DDL for Package Body PAC_PROD_AHO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_PROD_AHO" 
AS
/****************************************************************************

   NOMBRE:       PAC_PROD_AHO
   PROPÓSITO:  Funciones para productos de ahorro

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ----------------------------------
   1.0           -          -               Creació del package
   2.0        20/04/2009   APD              Bug 9685 - en lugar de coger la acticad de la tabla seguros, llamar a la función pac_seguros.ff_get_actividad
   3.0        07/07/2009   DCT              BUG 0010612: CRE - Error en la generació de pagaments automàtics.
                                            Canviar vista personas por tablas personas y añadir filtro de visión de agente
   4.0        23/11/2010   SRA              1.0016790 - CRT - Modificació package per 11gR2: se substituye el uso
                                            de JOIN...USING por JOIN...ON en la unión de tablas para adaptar el código a la versión de bbdd 11gR2
   5.0        23/01/2013  MMS               5. 0025584: (f_calcula_fvencim_nduraci) Agregamos el parametro de nedamar
   6.0        20/05/2015   YDA              6. 0034636 se incluye en los insert a evoluprovmatseg el campo nscenario
****************************************************************************/
   FUNCTION f_cambio_forpag_prest (psseguro IN NUMBER, pcfprest IN NUMBER)
      RETURN NUMBER
   IS
   /********************************************************************************************************************************
      Función que modifica la forma de pago de la prestación
      Parámetros de entrada: . pcfprest = Código de la nueva forma de pago de la prestación (0.Capital; 1. Renta Mensual Vitalicia)
   *****************************************************************************************************************************/
   BEGIN
      UPDATE estseguros_aho
         SET cfprest = pcfprest
       WHERE sseguro = psseguro;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'Pac_Prod_Aho.f_cambio_forpag_prest',
                      NULL,
                         'parametros: psseguro ='
                      || psseguro
                      || '  pcfprest ='
                      || pcfprest,
                      SQLERRM
                     );
         RETURN 108190;                                       -- Error General
   END f_cambio_forpag_prest;

   FUNCTION f_cambio_aportacion_revali (
      psseguro   IN   NUMBER,
      pcforpag   IN   NUMBER,
      pprima     IN   NUMBER,
      pprevali   IN   NUMBER,
      pnmovimi   IN   NUMBER,
      pfecha     IN   DATE
   )
      RETURN NUMBER
   IS
      /********************************************************************************************************************************
         Función que modifica el porcentaje de revalorización y la aportación periódica
         Parámetros de entrada: . pcforpag = Código de la nueva forma de pago
                                . pprima = Importe prima periódica
                                . prevali = Porcentaje de revalorización
      *****************************************************************************************************************************/
      v_sproduc   NUMBER;
      v_cgarant   NUMBER;
      v_ctipgar   NUMBER;
      v_fcarpro   DATE;
      v_fcaranu   DATE;
      v_nrenova   NUMBER;
      num_err     NUMBER;
      -- RSC 26/05/2008 Tarea: 5468
      -- JRH: Tarea 6966
      vcramo      NUMBER;
      vcmodali    NUMBER;
      vctipseg    NUMBER;
      vccolect    NUMBER;
      vcactivi    NUMBER;
   BEGIN
      SELECT sproduc
        INTO v_sproduc
        FROM estseguros
       WHERE sseguro = psseguro;

      -- Se busca el código de garantía de la prima periódica
      v_cgarant :=
                  pac_calc_comu.f_cod_garantia (v_sproduc, 3, NULL, v_ctipgar);

      -- Se modifica el capital de la garantía de la prima periódica
      UPDATE estgaranseg
         SET icapital = pprima
       WHERE sseguro = psseguro AND cgarant = v_cgarant;

      -- Se modifica el porcentaje de revalorizacion de las garantías que tienen prevali > 0
      UPDATE estgaranseg
         SET prevali = pprevali
       WHERE sseguro = psseguro AND cgarant = v_cgarant AND prevali > 0;

      -- Se modifica el porcentaje de revalorizacion y forma de pago en SEGUROS
      UPDATE estseguros
         SET prevali = pprevali,
             cforpag = pcforpag
       WHERE sseguro = psseguro;

      -- Se calculan y modifican los nuevos valores de Fecha cartera próxima, Fecha cartera anualidad y Día y mes renovación
      IF pcforpag = 0
      THEN
         v_fcarpro := NULL;
         v_fcaranu := NULL;
      ELSE
         v_fcarpro :=
            ADD_MONTHS (TO_DATE ('01' || TO_CHAR (f_sysdate, 'mmyyyy'),
                                 'ddmmyyyy'
                                ),
                        1
                       );
         v_fcaranu :=
            ADD_MONTHS (TO_DATE ('01' || TO_CHAR (f_sysdate, 'mmyyyy'),
                                 'ddmmyyyy'
                                ),
                        13
                       );
      END IF;

--  v_nrenova := DECODE(v_fcaranu, Null, Null, To_Char(v_fcaranu,'mm') || '01');
      SELECT DECODE (v_fcaranu, NULL, NULL, TO_CHAR (v_fcaranu, 'mm') || '01')
        INTO v_nrenova
        FROM DUAL;

      UPDATE estseguros
         SET fcarpro = v_fcarpro,
             fcaranu = v_fcaranu,
             nrenova = v_nrenova
       WHERE sseguro = psseguro;

      -- RSC 26/05/2008 Tarea: 5468
      IF pcforpag = 0 AND pprima = 0
      THEN                                              -- Reducción de póliza
         SELECT cramo, cmodali, ctipseg, ccolect
           INTO vcramo, vcmodali, vctipseg, vccolect
           FROM estseguros
          WHERE sseguro = psseguro;

         -- Anulación de las garantias de riesgo vigentes en la póliza
         -- Bug 9685 - APD - 21/04/2009 - en lugar de coger la actividad de la tabla seguros, llamar a la función pac_seguros.ff_get_actividad
         UPDATE estgaranseg
            SET cobliga = 0
          WHERE sseguro = psseguro
            AND f_pargaranpro_v
                          (vcramo,
                           vcmodali,
                           vctipseg,
                           vccolect,
                           pac_seguros.ff_get_actividad (psseguro,
                                                         estgaranseg.nriesgo,
                                                         'EST'
                                                        ),
                           cgarant,
                           'TIPO'
                          ) IN (6, 7)
            AND nmovimi = pnmovimi;
      -- Bug 9685 - APD - 21/04/2009 - Fin
      END IF;

---------------
-- Se tarifa --
---------------
      num_err :=
         pac_tarifas.f_tarifar_riesgo_tot
                                    ('EST',
                                     psseguro,
                                     1,
                                     pnmovimi,
-- BUG 18423 - I - 27/12/2011 - JLB - LCOL000 - Multimoneda
                                                  --f_parinstalacion_n('MONEDAINST'),
                                     pac_monedas.f_moneda_producto (v_sproduc),
-- BUG 18423 - I - 27/12/2011 - JLB - LCOL000 - Multimoneda
                                     pfecha
                                    );

      IF num_err <> 0
      THEN
         RETURN num_err;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'Pac_Prod_Aho.f_cambio_aportacion_revali',
                      NULL,
                         'parametros: psseguro ='
                      || psseguro
                      || '  pcforpag ='
                      || pcforpag
                      || '  pprima = '
                      || pprima
                      || '  pprevali = '
                      || pprevali
                      || ' pnmovimi = '
                      || pnmovimi,
                      SQLERRM
                     );
         RETURN 108190;                                       -- Error General
   END f_cambio_aportacion_revali;

   FUNCTION f_cambio_modif_gar (
      psseguro      IN   NUMBER,
      pcfallaseg1   IN   NUMBER,
      pcfallaseg2   IN   NUMBER,
      pcaccaseg1    IN   NUMBER,
      pcaccaseg2    IN   NUMBER,
      pnmovimi      IN   NUMBER,
      pfecha        IN   DATE
   )
      RETURN NUMBER
   IS
      /********************************************************************************************************************************
         Función que modifica las garantías adicionales contratadas (alta/baja)
         Parámetros de entrada: . pcfallaseg1 = Indicador garantía fallecimiento asegurado 1 contratada
                                . pcfallaseg2 = Indicador garantía fallecimiento asegurado 2 contratada
                                . pcaccaseg1 = Indicador garantía accidentes asegurado 1 contratada
                                . pcaccaseg2 = Indicador garantía accidentes asegurado 2 contratada
      *****************************************************************************************************************************/
      v_fecha    DATE;
      num_err    NUMBER;
      error      EXCEPTION;
      vsproduc   NUMBER;

      FUNCTION f_modif_garantia (
         psseguro       IN   NUMBER,
         ptipo          IN   NUMBER,
         ppropietario   IN   NUMBER,
         pcobliga       IN   NUMBER
      )
         RETURN NUMBER
      IS
         v_sproduc   NUMBER;
         v_cramo     NUMBER;
         v_cmodali   NUMBER;
         v_ctipseg   NUMBER;
         v_ccolect   NUMBER;
         v_cactivi   NUMBER;
         v_cgarant   NUMBER;
         v_ctipgar   NUMBER;
         v_accion    VARCHAR2 (5);
         v_mensa     VARCHAR2 (1000);
         v_nmovimi   NUMBER;
         v_nmovima   NUMBER;
         v_nriesgo   NUMBER;
         num_err     NUMBER;
      BEGIN
         SELECT sproduc, cramo, cmodali, ctipseg, ccolect
           INTO v_sproduc, v_cramo, v_cmodali, v_ctipseg, v_ccolect
           FROM estseguros
          WHERE sseguro = psseguro;

         -- Se busca el código de garantía
         v_cgarant :=
            pac_calc_comu.f_cod_garantia (v_sproduc,
                                          ptipo,
                                          ppropietario,
                                          v_ctipgar
                                         );

         IF v_cgarant IS NOT NULL
         THEN
            -- el producto puede contratar la garantia que se quiere modificar
            SELECT nriesgo, nmovimi, nmovima
              INTO v_nriesgo, v_nmovimi, v_nmovima
              FROM estgaranseg
             WHERE sseguro = psseguro AND cgarant = v_cgarant;

            v_cactivi :=
                     pac_seguros.ff_get_actividad (psseguro, v_nriesgo, 'EST');

            UPDATE estgaranseg
               SET cobliga = pcobliga
             WHERE sseguro = psseguro
               AND cgarant = v_cgarant
               AND nriesgo = v_nriesgo;

            IF pcobliga = 0
            THEN
               v_accion := 'DESEL';
            ELSIF pcobliga = 1
            THEN
               v_accion := 'SEL';
            END IF;

            num_err :=
               pk_nueva_produccion.f_validacion_cobliga (psseguro,
                                                         v_nriesgo,
                                                         v_nmovimi,
                                                         v_cgarant,
                                                         v_accion,
                                                         v_sproduc,
                                                         v_cactivi,
                                                         v_mensa,
                                                         v_nmovima
                                                        );

            IF num_err <> 0
            THEN
               RETURN num_err;
            END IF;
         END IF;

         RETURN 0;
      EXCEPTION
         WHEN OTHERS
         THEN
            p_tab_error (f_sysdate,
                         f_user,
                         'Pac_Prod_Aho.f_cambio_modif_gar.f_modif_garantia',
                         NULL,
                            'parametros: psseguro ='
                         || psseguro
                         || '  ptipo ='
                         || ptipo
                         || '  ppropietario = '
                         || ppropietario
                         || '  pcobliga = '
                         || pcobliga,
                         SQLERRM
                        );
            RETURN 105577;                 -- Error al modificar las garantías
      END f_modif_garantia;
   BEGIN
      -- Se modifica la garantia de Fallecimiento del asegurado 1
      num_err := f_modif_garantia (psseguro, 6, 1, pcfallaseg1);

      IF num_err <> 0
      THEN
         RAISE error;
      END IF;

      -- Se modifica la garantia de Fallecimiento del asegurado 2
      num_err := f_modif_garantia (psseguro, 6, 2, pcfallaseg2);

      IF num_err <> 0
      THEN
         RAISE error;
      END IF;

      -- Se modifica la garantia de Accidente del asegurado 1
      num_err := f_modif_garantia (psseguro, 7, 1, pcaccaseg1);

      IF num_err <> 0
      THEN
         RAISE error;
      END IF;

      -- Se modifica la garantia de Accidente del asegurado 2
      num_err := f_modif_garantia (psseguro, 7, 2, pcaccaseg2);

      IF num_err <> 0
      THEN
         RAISE error;
      END IF;

      -- BUG 18423 - I - 27/12/2011 - JLB - LCOL000 - Multimoneda
      SELECT sproduc
        INTO vsproduc
        FROM estseguros
       WHERE sseguro = psseguro;

-- BUG 18423 - F - 27/12/2011 - JLB - LCOL000 - Multimoneda
---------------
-- Se tarifa --
---------------
      num_err :=
         pac_tarifas.f_tarifar_riesgo_tot
                                     ('EST',
                                      psseguro,
                                      1,
                                      pnmovimi,
-- BUG 18423 - I - 27/12/2011 - JLB - LCOL000 - Multimoneda
                                                --  f_parinstalacion_n('MONEDAINST'),
                                      pac_monedas.f_moneda_producto (vsproduc),
-- BUG 18423 - F - 27/12/2011 - JLB - LCOL000 - Multimoneda
                                      pfecha
                                     );

      IF num_err <> 0
      THEN
         RETURN num_err;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN error
      THEN
         RETURN num_err;
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'Pac_Prod_Aho.f_cambio_modif_gar',
                      NULL,
                         'parametros: psseguro ='
                      || psseguro
                      || '  pcfallaseg1 ='
                      || pcfallaseg1
                      || '  pcfallaseg2 = '
                      || pcfallaseg2
                      || '  pcaccaseg1 = '
                      || pcaccaseg1
                      || ' pcaccaseg2 = '
                      || pcaccaseg2
                      || ' pnmovimi = '
                      || pnmovimi,
                      SQLERRM
                     );
         RETURN 108190;                                       -- Error General
   END f_cambio_modif_gar;

   FUNCTION f_cambio_aport_extr (
      psseguro   IN   NUMBER,
      pfefecto   IN   DATE,
      pprima     IN   NUMBER,
      pnmovimi   IN   NUMBER
   )
      RETURN NUMBER
   IS
      v_cgarant   NUMBER;
      v_norden    NUMBER;
      v_ctarifa   NUMBER;
      v_cformul   NUMBER;
      num_err     NUMBER;
      error       EXCEPTION;
      vsproduc    NUMBER;
   BEGIN
      -- Se buscan valores definidos en el producto (Garanpro) necesarios para realizar insertar la garantía de
      -- aportación extraordinaria
      BEGIN
         -- Bug 9685 - APD - 20/04/2009 - en lugar de coger la acticad de la tabla seguros, llamar a la función pac_seguros.ff_get_actividad
         SELECT g.cgarant, g.norden, g.ctarifa, g.cformul, s.sproduc
           INTO v_cgarant, v_norden, v_ctarifa, v_cformul, vsproduc
           FROM garanpro g, estseguros s
          WHERE g.sproduc = s.sproduc
            AND g.cramo = s.cramo
            AND g.cmodali = s.cmodali
            AND g.ctipseg = s.ctipseg
            AND g.ccolect = s.ccolect
            --and g.cactivi = s.cactivi
            AND g.cactivi = pac_seguros.ff_get_actividad (psseguro, 1, 'EST')
            AND f_pargaranpro_v (g.cramo,
                                 g.cmodali,
                                 g.ctipseg,
                                 g.ccolect,
                                 g.cactivi,
                                 g.cgarant,
                                 'TIPO'
                                ) = 4
            AND s.sseguro = psseguro;
      -- Bug 9685 - APD - 20/04/2009 - Fin
      EXCEPTION
         WHEN OTHERS
         THEN
            num_err := 101959;
        -- Error al modificar o insertar en la tabla GARANSEG para el seguro:
            RAISE error;
      END;

      -- Se inserta la garantía de aportación extraordinaria/inicial (282) con el importe de la aportación extraordinaria
      BEGIN
         INSERT INTO estgaranseg
                     (cgarant, sseguro, nriesgo, finiefe, norden, crevali,
                      ctarifa, icapital, precarg, iprianu, iextrap, ffinefe,
                      cformul, ctipfra, ifranqu, irecarg, ipritar, pdtocom,
                      idtocom, prevali, irevali, itarifa, nmovimi, itarrea,
                      ipritot, icaptot, nmovima, cobliga
                     )
              VALUES (v_cgarant, psseguro, 1, TRUNC (pfefecto), v_norden, 0,
                      v_ctarifa, pprima, NULL, 0, NULL, NULL,
                      v_cformul, NULL, NULL, 0, 0, NULL,
                      0, NULL, NULL, NULL, pnmovimi, NULL,
                      0, pprima, pnmovimi, 1
                     );
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX
         THEN
            BEGIN
               UPDATE estgaranseg
                  SET icapital = pprima,
                      icaptot = pprima,
                      nmovima = pnmovimi,
                      cobliga = 1
                WHERE cgarant = v_cgarant
                  AND nriesgo = 1
                  AND nmovimi = pnmovimi
                  AND sseguro = psseguro
                  AND finiefe = TRUNC (pfefecto);
            EXCEPTION
               WHEN OTHERS
               THEN
                  num_err := 101959;
        -- Error al modificar o insertar en la tabla GARANSEG para el seguro:
                  RAISE error;
            END;
         WHEN OTHERS
         THEN
            num_err := 101959;
        -- Error al modificar o insertar en la tabla GARANSEG para el seguro:
            RAISE error;
      END;

---------------
-- Se tarifa --
---------------
      num_err :=
         pac_tarifas.f_tarifar_riesgo_tot
                                     ('EST',
                                      psseguro,
                                      1,
                                      pnmovimi,
-- BUG 18423 - I - 27/12/2011 - JLB - LCOL000 - Multimoneda
                                             --     f_parinstalacion_n('MONEDAINST'),
                                      pac_monedas.f_moneda_producto (vsproduc),
-- BUG 18423 - F - 27/12/2011 - JLB - LCOL000 - Multimoneda
                                      pfefecto
                                     );

      IF num_err <> 0
      THEN
         RAISE error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN error
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'Pac_Prod_Aho.f_cambio_aport_extr',
                      NULL,
                         'parametros: psseguro ='
                      || psseguro
                      || '  pfefecto ='
                      || pfefecto
                      || '  pprima = '
                      || pprima
                      || ' pnmovimi = '
                      || pnmovimi,
                      SQLERRM
                     );
         RETURN num_err;
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'Pac_Prod_Aho.f_cambio_aport_extr',
                      NULL,
                         'parametros: psseguro ='
                      || psseguro
                      || '  pfefecto ='
                      || pfefecto
                      || '  pprima = '
                      || pprima
                      || ' pnmovimi = '
                      || pnmovimi,
                      SQLERRM
                     );
         RETURN 108190;                                       -- Error General
   END f_cambio_aport_extr;

   FUNCTION f_cambio_fvencimiento (
      psseguro   IN   NUMBER,
      pfvencim   IN   DATE,
      pnmovimi   IN   NUMBER,
      pfefecto   IN   DATE
   )
      RETURN NUMBER
   IS
      v_sproduc       NUMBER;
      v_sproduc_tar   NUMBER;
      v_cgarant       NUMBER;
      v_norden        NUMBER;
      v_ctarifa       NUMBER;
      v_cformul       NUMBER;
      num_err         NUMBER;
      error           EXCEPTION;
      v_cduraci       NUMBER;
      v_fefecto       DATE;
      v_fnacimi       DATE;
      v_fvencim       DATE;
      v_nduraci       NUMBER;
      v_nedamar       estseguros.nedamar%TYPE;
                                            -- Bug 0025584 - MMS - 23/01/2013
   BEGIN
      BEGIN
         SELECT sproduc, cduraci, fefecto,
                nedamar                      -- Bug 0025584 - MMS - 23/01/2013
           INTO v_sproduc, v_cduraci, v_fefecto,
                v_nedamar
           FROM estseguros
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN OTHERS
         THEN
            num_err := 180529;        -- Error al leer de la tabla ESTSEGUROS
            RAISE error;
      END;

      -- Se mira si el producto puede cambiar de producto en la tarificacion
      -- De momento, sólo pueden cambiar de producto en la tarificación los Ahorro Seguros, Pla d'Estalvi y PPA
      IF NVL (f_parproductos_v (v_sproduc, 'CAMB_PROD_TARIFI'), 0) = 1
      THEN                  -- Sí puede cambiar de producto en la Tarificación
         v_sproduc_tar := f_parproductos_v (v_sproduc, 'SPRODUC_TAR');

         IF v_sproduc_tar IS NULL
         THEN
            num_err := 180649;
              -- Falta parametrizar el producto de tarificación (SPRODUC_TAR)
            RAISE error;
         ELSE
            BEGIN
               UPDATE estseguros
                  SET sprodtar = v_sproduc_tar
                WHERE sseguro = psseguro;
            EXCEPTION
               WHEN OTHERS
               THEN
                  num_err := 104566;
                                    -- Error al modificar la taula ESTSEGUROS
                  RAISE error;
            END;
         END IF;
      END IF;

      -- Tanto si el producto puede como sino cambiar de producto en la tarificacion se realizará el cambio de la
      -- fecha de vencimiento y nduraci
      BEGIN
         --Bug10612 - 07/07/2009 - DCT (canviar vista personas)
         SELECT MIN (p.fnacimi)
           INTO v_fnacimi
           FROM estriesgos e, estper_personas p
          WHERE e.sseguro = psseguro AND p.sperson = e.sperson;

         /*SELECT MIN(fnacimi)
           INTO v_fnacimi
           FROM estriesgos e, personas p
          WHERE e.sseguro = psseguro
            AND p.sperson = e.sperson;*/

         --FI Bug10612 - 07/07/2009 - DCT (canviar vista personas)
         v_fvencim := TRUNC (pfvencim);
         num_err :=
            pac_calc_comu.f_calcula_fvencim_nduraci (v_sproduc,
                                                     v_fnacimi,
                                                     v_fefecto,
                                                     v_cduraci,
                                                     v_nduraci,
                                                     v_fvencim,
                                                     NULL,
                                                     NULL,
                                                     v_nedamar
                                                    );
                                             -- Bug 0025584 - MMS - 23/01/2013

         IF num_err <> 0
         THEN
            RAISE error;
         END IF;

         -- Se modifica la Fecha de Vencimiento de la póliza
         UPDATE estseguros
            SET fvencim = TRUNC (pfvencim),
                nduraci = v_nduraci
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN OTHERS
         THEN
            num_err := 104566;      -- Error al modificar la taula ESTSEGUROS
            RAISE error;
      END;

---------------
-- Se tarifa --
---------------
-- Si el producto no puede realizar el cambio de producto, la tarificacion se realizará con el producto de la poliza (SPRODUC)
-- Si el producto sí puede realizar el cambio de producto, la tarificacion se realizará con el producto informado para la tarificación (SPRODTAR)
      num_err :=
         pac_tarifas.f_tarifar_riesgo_tot
                                    ('EST',
                                     psseguro,
                                     1,
                                     pnmovimi,
-- BUG 18423 - I - 27/12/2011 - JLB - LCOL000 - Multimoneda
                                             --     f_parinstalacion_n('MONEDAINST'),
                                     pac_monedas.f_moneda_producto (v_sproduc),
-- BUG 18423 - F - 27/12/2011 - JLB - LCOL000 - Multimoneda
                                     pfefecto
                                    );

      IF num_err <> 0
      THEN
         RAISE error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN error
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'Pac_Prod_Aho.f_cambio_fvencimiento',
                      NULL,
                         'parametros: psseguro ='
                      || psseguro
                      || '  pfvencim = '
                      || pfvencim,
                      SQLERRM
                     );
         RETURN num_err;
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'Pac_Prod_Aho.f_cambio_fvencimiento',
                      NULL,
                         'parametros: psseguro ='
                      || psseguro
                      || '  pfvencim = '
                      || pfvencim,
                      SQLERRM
                     );
         RETURN 108190;                                       -- Error General
   END f_cambio_fvencimiento;

   FUNCTION f_post_penalizacion (psseguro IN NUMBER)
      RETURN NUMBER
   IS
      v_nmovimi   NUMBER;
      v_nanyo     NUMBER;

      CURSOR cur_penaliseg
      IS
         SELECT   (100 - ppenali) rescate
             FROM penaliseg p1
            WHERE p1.sseguro = psseguro
              AND p1.nmovimi = (SELECT MAX (p2.nmovimi)
                                  FROM penaliseg p2
                                 WHERE p2.sseguro = p1.sseguro)
         ORDER BY niniran, nfinran;
   BEGIN
      -- Se busca el valor del movimiento de penalización
      SELECT MAX (nmovimi)
        INTO v_nmovimi
        FROM penaliseg
       WHERE sseguro = psseguro;

      -- Se insertan los mismos registros que en el último movimiento, pero con nmovimi = al movimiento de penalización
      INSERT INTO evoluprovmatseg
                  (sseguro, nmovimi, nanyo, fprovmat, iprovmat, icapfall,
                   prescate, pinttec, iprovest, crevisio, nscenario)
         SELECT   evo.sseguro, v_nmovimi, evo.nanyo, evo.fprovmat,
                  evo.iprovmat, evo.icapfall, evo.prescate, evo.pinttec,
                  evo.iprovest, evo.crevisio, nscenario       --JRH Tarea 6966
             FROM evoluprovmatseg evo
            WHERE evo.sseguro = psseguro
              AND evo.nmovimi = (SELECT MAX (evo2.nmovimi)
                                   FROM evoluprovmatseg evo2
                                  WHERE evo2.sseguro = evo.sseguro)
         ORDER BY evo.nanyo, evo.fprovmat;

      -- Se busca el valor mínimo del año para saber a partir de qué año se deben actualizar los rescates
      SELECT   MIN (nanyo)
          INTO v_nanyo
          FROM evoluprovmatseg evo
         WHERE evo.sseguro = psseguro
           AND evo.nmovimi = (SELECT MAX (evo2.nmovimi)
                                FROM evoluprovmatseg evo2
                               WHERE evo2.sseguro = evo.sseguro)
      ORDER BY evo.nanyo, evo.fprovmat;

      FOR reg IN cur_penaliseg
      LOOP
         -- Se actualiza la tabla evoluprovmatseg con los rescates obtenidos a partir de la tabla de penalizacion
         UPDATE evoluprovmatseg evo
            SET prescate = reg.rescate
          WHERE evo.sseguro = psseguro
            AND evo.nmovimi = (SELECT MAX (evo2.nmovimi)
                                 FROM evoluprovmatseg evo2
                                WHERE evo2.sseguro = evo.sseguro)
            AND evo.nanyo = v_nanyo;

         v_nanyo := v_nanyo + 1;
      END LOOP;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'produccion_aho==> f_post_penalizacion',
                      NULL,
                      'parámetros : SSEGURO =' || psseguro,
                      SQLERRM
                     );
         RETURN 107405;            -- ERROR AL CALCULAR LOS VALORES DE RESCATE
   END f_post_penalizacion;

   FUNCTION f_grabar_garantias_aho (
      pmodo           IN   NUMBER,
      psseguro        IN   NUMBER,
      pnriesgo        IN   NUMBER,
      pnmovimi        IN   NUMBER,
      pfefecto        IN   DATE,
      prima_inicial   IN   NUMBER,
      prima_per       IN   NUMBER,
      pprevali        IN   NUMBER,
      pcfallaseg1     IN   NUMBER,
      pcfallaseg2     IN   NUMBER,
      pcaccaseg1      IN   NUMBER,
      pcaccaseg2      IN   NUMBER
   )
      RETURN NUMBER
   IS
         /***********************************************************************************************************************************
            Función que inserta las garantías en la tabla ESTGARANSEG actualizando el capital

            pmodo: 1 -- alta de la propuesta
                   2 -- actualización de capital
      **************************************************************************************************************************************/
      v_accion     VARCHAR2 (5);
      vmensa       VARCHAR2 (1000);
      vnmovima     NUMBER;
      num_err      NUMBER;
      v_icapital   NUMBER;
      traza        NUMBER;
      v_sproduc    NUMBER;
      v_cramo      NUMBER;
      v_cmodali    NUMBER;
      v_ctipseg    NUMBER;
      v_ccolect    NUMBER;
      v_cactivi    NUMBER;
      v_cobliga    NUMBER;

      CURSOR c_gar (c_sseguro IN NUMBER)
      IS
         SELECT   *
             FROM estgaranseg
            WHERE sseguro = c_sseguro
         ORDER BY cgarant;
   BEGIN
      traza := 1;

      -- Bug 9685 - APD - 21/04/2009 - en lugar de coger la actividad de la tabla seguros, llamar a la función pac_seguros.ff_get_actividad
      SELECT sproduc, cramo, cmodali, ctipseg, ccolect,
             pac_seguros.ff_get_actividad (psseguro, pnriesgo, 'EST') cactivi
        INTO v_sproduc, v_cramo, v_cmodali, v_ctipseg, v_ccolect,
             v_cactivi
        FROM estseguros
       WHERE sseguro = psseguro;

      -- Bug 9685 - APD - 21/04/2009 - Fin
      IF pmodo = 1
      THEN                              -- si es alta insertamos las garantías
         traza := 2;
         num_err :=
            pk_nueva_produccion.f_garanpro_estgaranseg (psseguro,
                                                        pnriesgo,
                                                        pnmovimi,
                                                        v_sproduc,
                                                        pfefecto,
                                                        0
                                                       );

         IF num_err <> 0
         THEN
            RETURN num_err;
         END IF;
      ELSE                       -- si es modificación actualizamos las fechas
         UPDATE estgaranseg
            SET ftarifa = pfefecto,
                finiefe = pfefecto
          WHERE sseguro = psseguro;
      END IF;

      -- Actualizamos la revalorización
      UPDATE estseguros
         SET prevali = pprevali
       WHERE sseguro = psseguro;

      UPDATE estgaranseg
         SET prevali = pprevali
       WHERE sseguro = psseguro
         AND cgarant IN (SELECT cgarant
                           FROM garanpro
                          WHERE sproduc = v_sproduc AND crevali <> 0);

      -- Actualizamos el capital
      FOR gar IN c_gar (psseguro)
      LOOP
         v_cobliga := gar.cobliga;
         v_icapital := gar.icapital;

         -- PRIMA AHORRO
         IF NVL (f_pargaranpro_v (v_cramo,
                                  v_cmodali,
                                  v_ctipseg,
                                  v_ccolect,
                                  v_cactivi,
                                  gar.cgarant,
                                  'TIPO'
                                 ),
                 0
                ) = 3
         THEN
            v_cobliga := 1;
            v_icapital := prima_per;
         -- PRIMA EXTRAORDINARIA/INICIAL
         ELSIF NVL (f_pargaranpro_v (v_cramo,
                                     v_cmodali,
                                     v_ctipseg,
                                     v_ccolect,
                                     v_cactivi,
                                     gar.cgarant,
                                     'TIPO'
                                    ),
                    0
                   ) = 4
         THEN
            v_cobliga := 1;
            v_icapital := prima_inicial;
         -- PRIMA FALLECIMIENTO PRIMER ASEGURADO
         ELSIF     NVL (f_pargaranpro_v (v_cramo,
                                         v_cmodali,
                                         v_ctipseg,
                                         v_ccolect,
                                         v_cactivi,
                                         gar.cgarant,
                                         'TIPO'
                                        ),
                        0
                       ) = 6
               AND NVL (f_pargaranpro_v (v_cramo,
                                         v_cmodali,
                                         v_ctipseg,
                                         v_ccolect,
                                         v_cactivi,
                                         gar.cgarant,
                                         'PROPIETARIO'
                                        ),
                        0
                       ) = 1
         THEN
            IF pcfallaseg1 = 1
            THEN
               v_cobliga := 1;
            ELSIF pcfallaseg1 = 0
            THEN
               v_cobliga := 0;
            END IF;
         -- PRIMA FALLECIMIENTO SEGUNDO ASEGURADO
         ELSIF     NVL (f_pargaranpro_v (v_cramo,
                                         v_cmodali,
                                         v_ctipseg,
                                         v_ccolect,
                                         v_cactivi,
                                         gar.cgarant,
                                         'TIPO'
                                        ),
                        0
                       ) = 6
               AND NVL (f_pargaranpro_v (v_cramo,
                                         v_cmodali,
                                         v_ctipseg,
                                         v_ccolect,
                                         v_cactivi,
                                         gar.cgarant,
                                         'PROPIETARIO'
                                        ),
                        0
                       ) = 2
         THEN
            IF pcfallaseg2 = 1
            THEN
               v_cobliga := 1;
            ELSIF pcfallaseg2 = 0
            THEN
               v_cobliga := 0;
            END IF;
         -- PRIMA ACCIDENTES PRIMER ASEGURADO
         ELSIF     NVL (f_pargaranpro_v (v_cramo,
                                         v_cmodali,
                                         v_ctipseg,
                                         v_ccolect,
                                         v_cactivi,
                                         gar.cgarant,
                                         'TIPO'
                                        ),
                        0
                       ) = 7
               AND NVL (f_pargaranpro_v (v_cramo,
                                         v_cmodali,
                                         v_ctipseg,
                                         v_ccolect,
                                         v_cactivi,
                                         gar.cgarant,
                                         'PROPIETARIO'
                                        ),
                        0
                       ) = 1
         THEN
            IF pcaccaseg1 = 1
            THEN
               v_cobliga := 1;
            ELSIF pcaccaseg1 = 0
            THEN
               v_cobliga := 0;
            END IF;
         -- PRIMA ACCIDENTES SEGUNDO ASEGURADO
         ELSIF     NVL (f_pargaranpro_v (v_cramo,
                                         v_cmodali,
                                         v_ctipseg,
                                         v_ccolect,
                                         v_cactivi,
                                         gar.cgarant,
                                         'TIPO'
                                        ),
                        0
                       ) = 7
               AND NVL (f_pargaranpro_v (v_cramo,
                                         v_cmodali,
                                         v_ctipseg,
                                         v_ccolect,
                                         v_cactivi,
                                         gar.cgarant,
                                         'PROPIETARIO'
                                        ),
                        0
                       ) = 2
         THEN
            IF pcaccaseg2 = 1
            THEN
               v_cobliga := 1;
            ELSIF pcaccaseg2 = 0
            THEN
               v_cobliga := 0;
            END IF;
         END IF;

         -- actualizamos el capital de las diferentes garantías
         UPDATE estgaranseg
            SET icapital = v_icapital,
                cobliga = v_cobliga
          WHERE sseguro = psseguro
            AND nriesgo = pnriesgo
            AND nmovimi = pnmovimi
            AND cgarant = gar.cgarant;

         IF v_cobliga = 0
         THEN
            v_accion := 'DESEL';
         ELSIF v_cobliga = 1
         THEN
            v_accion := 'SEL';
         END IF;

         num_err :=
            pk_nueva_produccion.f_validacion_cobliga (psseguro,
                                                      pnriesgo,
                                                      pnmovimi,
                                                      gar.cgarant,
                                                      v_accion,
                                                      v_sproduc,
                                                      v_cactivi,
                                                      vmensa,
                                                      gar.nmovima
                                                     );
      END LOOP;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pk_nueva_produccion2.f_grabar_garantias_aho',
                      traza,
                         'parametros: pmodo ='
                      || pmodo
                      || ' psseguro ='
                      || psseguro
                      || ' pnriesgo ='
                      || pnriesgo
                      || ' pnmovimi ='
                      || pnmovimi
                      || ' pfefecto ='
                      || pfefecto
                      || ' prima_inicial = '
                      || prima_inicial
                      || ' prima_per ='
                      || prima_per
                      || ' pprevali='
                      || pprevali
                      || ' pcfallaseg1 ='
                      || pcfallaseg1
                      || ' pcfallaseg2 ='
                      || pcfallaseg2
                      || ' pcaccaseg1='
                      || pcaccaseg1
                      || ' pcaccaseg2 ='
                      || pcaccaseg2,
                      SQLERRM
                     );
         RETURN 108190;                                       -- Error General
   END f_grabar_garantias_aho;

   FUNCTION f_graba_propuesta_aho (
      psproduc        IN       NUMBER,
      psperson1       IN       NUMBER,
      pcdomici1       IN       NUMBER,
      psperson2       IN       NUMBER,
      pcdomici2       IN       NUMBER,
      pcagente        IN       NUMBER,
      pcidioma        IN       NUMBER,
      pfefecto        IN       DATE,
      pnduraci        IN       NUMBER,
      pfvencim        IN       DATE,
      pcforpag        IN       NUMBER,
      pcbancar        IN       VARCHAR2,
      psclaben        IN       NUMBER,
      ptclaben        IN       VARCHAR2,
      prima_inicial   IN       NUMBER,
      prima_per       IN       NUMBER,
      prevali         IN       NUMBER,
      pcfallaseg1     IN       NUMBER,
      pcfallaseg2     IN       NUMBER,
      pcaccaseg1      IN       NUMBER,
      pcaccaseg2      IN       NUMBER,
      psseguro        IN OUT   NUMBER,
      pcapgar         OUT      NUMBER,
      pcapfall        OUT      NUMBER,
      pcapgar_per     OUT      NUMBER
   )
      RETURN NUMBER
   IS
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
      error        EXCEPTION;
      num_err      NUMBER;
      --JRH Nuevo parametro para insertar preguntas a nivel de póliza. En el caso de AHO no tenemos.
      tab_pregun   pac_prod_comu.t_preguntas;
   BEGIN
      -- Primero inicializamos la propuesta, es decir, grabamos todos los datos y tarifamos
      num_err :=
         pac_prod_comu.f_inicializa_propuesta (psproduc,
                                               psperson1,
                                               pcdomici1,
                                               psperson2,
                                               pcdomici2,
                                               pcagente,
                                               pcidioma,
                                               pfefecto,
                                               pnduraci,
                                               pfvencim,
                                               pcforpag,
                                               pcbancar,
                                               psclaben,
                                               ptclaben,
                                               prima_inicial,
                                               prima_per,
                                               prevali,
                                               pcfallaseg1,
                                               pcfallaseg2,
                                               pcaccaseg1,
                                               pcaccaseg2,
                                               psseguro,
                                               tab_pregun
                                              );

      IF num_err <> 0
      THEN
         RAISE error;
      ELSE
         -- Recuperamos los datos que mostraremos por pantalla
         num_err :=
            pac_calc_aho.f_get_capitales_aho (psproduc,
                                              psseguro,
                                              pcapgar,
                                              pcapfall,
                                              pcapgar_per
                                             );

         IF num_err <> 0
         THEN
            RAISE error;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN error
      THEN
         RETURN num_err;
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'Pac_Prod_Aho.f_graba_propuesta_aho',
                      NULL,
                         'parametros: psproduc ='
                      || psproduc
                      || ' psperson1 ='
                      || psperson1
                      || ' pcdomici1 ='
                      || pcdomici1
                      || ' psperson2 ='
                      || psperson2
                      || ' pcdomici2 ='
                      || pcdomici2
                      || ' pcagente='
                      || pcagente
                      || ' pcidioma='
                      || pcidioma
                      || ' pfefecto='
                      || pfefecto
                      || ' pnduraci='
                      || pnduraci
                      || ' pfvencim='
                      || pfvencim
                      || ' pcforpag='
                      || pcforpag
                      || ' pcbancar='
                      || pcbancar
                      || ' psclaben='
                      || psclaben
                      || ' ptclaben='
                      || ptclaben
                      || ' prima_inicial = '
                      || prima_inicial
                      || ' prima_per ='
                      || prima_per
                      || ' prevali='
                      || prevali
                      || ' pcfallaseg1 ='
                      || pcfallaseg1
                      || ' pcfallaseg2 ='
                      || pcfallaseg2
                      || ' pcaccaseg1='
                      || pcaccaseg1
                      || ' pcaccaseg2 ='
                      || pcaccaseg2
                      || ' psseguro='
                      || psseguro,
                      SQLERRM
                     );
         RETURN (108190);                                     -- Error general
   END f_graba_propuesta_aho;

       -- JRH 11/2007 Lo hemos puesto en el comu
       /*
      FUNCTION f_programa_revision_renovacion(psseguro IN NUMBER, pndurper IN NUMBER, ppinttec IN NUMBER)
      RETURN NUMBER IS*/
      /********************************************************************************************************************************
         Función que marca una póliza para su renovación/revisión con los nuevos valores a aplicar: duración y
         % de interés garantizado.

         Parámetros de entrada:
              . psseguro = Identificador de la póliza
              . pndurper = Duración Período
              . ppinttec = % de interés técnico

              La función retorna:
                 0 - si ha ido bien
                 codigo error - si hay algún error.
     *********************************************************************************************************************************/
       /* num_err   NUMBER;
        v_movimi  NUMBER;
        Error EXCEPTION;
      BEGIN


        num_err:=PAC_PROD_COMU.f_programa_revision_renovacion(psseguro, pndurper, ppinttec, NULL); --Llamamos a la del comu con el capital a null
            IF num_err <> 0 THEN
           Raise Error;
        END IF;

        RETURN 0;

      EXCEPTION
        WHEN Error THEN
                  p_tab_error(f_sysdate,  F_USER,  'Pac_Prod_Aho.f_graba_propuesta_aho', null, 'parametros: psseguro ='||psseguro||
                ' pndurper ='||pndurper||' ppinttec ='||ppinttec, SQLERRM );
                RETURN (108190);  -- Error general
        WHEN OTHERS THEN
                  p_tab_error(f_sysdate,  F_USER,  'Pac_Prod_Aho.f_graba_propuesta_aho', null, 'parametros: psseguro ='||psseguro||
                ' pndurper ='||pndurper||' ppinttec ='||ppinttec, SQLERRM );
                RETURN (108190);  -- Error general
      END f_programa_revision_renovacion;
   */

   /*   PROCEDURE p_revision_renovacion(pfecha IN DATE, psproduc IN NUMBER, psproces IN NUMBER) IS
         Proceso que realizará la revisión o renovación de la póliza según corresponda.

         Parámetros de entrada:
              . pfecha = Fecha de revisión
              . psproduc = Identificador del producto
              . psproces = Identificador del proceso

      -- Este proceso de revisión/renovación debe seleccionar todas las pólizas que:
      --  . tengan la fecha de revisión igual a la fecha del proceso (pfecha)
      --  . y (tengan el parámetro 'RENOVA_REVISA' = 1 y el campo SEGUROS_AHO.NDURREV not null)
      --  . o tengan el parámetro 'RENOVA_REVISA' = 2
      Cursor c_poliza_rev_renova IS
        Select seg1.sseguro, seg1.sproduc, seg2.frevisio, seg2.ndurper
        From seguros seg1, seguros_aho seg2
        Where seg1.sseguro = seg2.sseguro
          and seg2.FREVISIO <= pfecha
          and (
               (
                NVL(f_parproductos_v(seg1.sproduc, 'RENOVA_REVISA'),0) = 1
                and
                seg2.NDURREV IS NOT NULL
               )
              or NVL(f_parproductos_v(seg1.sproduc, 'RENOVA_REVISA'),0) = 2
              )
           and (seg1.sproduc = psproduc or psproduc IS NULL)
           and seg1.csituac = 0 and seg1.creteni = 0
           and (seg1.FVENCIM > pfecha or seg1.FVENCIM IS NULL);

        num_err       NUMBER;
        v_ndurrev     NUMBER;
        v_pintrev     NUMBER;
        v_movimi      NUMBER;
        error         NUMBER;
        nprolin       NUMBER;
        v_sproces     NUMBER;
        v_icapital    NUMBER;
        v_cramo       NUMBER;
        v_cmodali     NUMBER;
        v_ctipseg     NUMBER;
        v_ccolect     NUMBER;
        v_cactivi     NUMBER;
        v_fecha       DATE;

        n_cont_pol_correctas          NUMBER;
        n_cont_pol_incorrectas        NUMBER;
        n_cont_total_pol_procesadas   NUMBER;

        Error_Poliza  EXCEPTION;

      BEGIN

      -- Si el psproces no está informado, se creará la cabecera del proceso
        IF psproces IS NULL THEN
           error := f_procesini(F_USER,1,'Revision/Renovacion','Revision/Renovacion',v_sproces);
        ELSE
           error := f_proceslin(v_sproces, 'Inicio proceso Revision/Renovacion '|| TO_CHAR (f_sysdate, 'DD-MM-YYYY  HH24:MI'), 1, nprolin, 4);
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

        -- Para cada una de ellas
        -- Mirar si tiene informados los campos seguros_aho.ndurrev y seguros_aho.pinttec
           BEGIN
             Select ndurrev, pintrev
             into v_ndurrev, v_pintrev
             From seguros_aho
             Where sseguro = reg.sseguro;

           EXCEPTION
             WHEN OTHERS THEN
                  num_err := 120445;
                  Raise Error_Poliza;
           END;

           -- Si la duración no está informada, se debe informar con la duración por defecto
           IF v_ndurrev IS NULL AND reg.ndurper IS NOT NULL THEN
              num_err := pac_calc_aho.F_GET_DURACION_RENOVA(null, null, reg.sseguro, v_ndurrev);
              IF num_err <> 0 THEN
                 Raise Error_Poliza;
              END IF;

               BEGIN
                 UPDATE SEGUROS_AHO
                 Set ndurrev = v_ndurrev,
                 frevant = reg.frevisio,
                 frevisio = add_months(reg.frevisio, 12*v_ndurrev)
                 Where sseguro = reg.sseguro;

               EXCEPTION
                 WHEN OTHERS THEN
                      num_err := 180228;  -- Error al actualizar la tabla SEGUROS_AHO
                      Raise Error_Poliza;
               END;

           END IF;

           -- Si el interés no está informado, se debe informar con el % de interés parametrizado por producto
           IF v_pintrev IS NULL THEN
              num_err := pac_inttec.F_INT_SEGURO_ALTA_RENOVA('SEG', reg.sseguro, 2, REG.FREVISIO, v_pintrev);
              IF num_err <> 0 THEN
                 Raise Error_Poliza;
              END IF;
           END IF;

           -- Calculamos la provisión matemática a la fecha de revisión para actualizar después la garatnía de prima
            v_icapital := Pac_Provmat_Formul.F_CALCUL_FORMULAS_PROVI(reg.sseguro, reg.frevisio, 'IPROVAC');

           -- Se graba un movimiento de revisión de intereses
           num_err := f_movseguro(reg.sseguro, null, 410, 2, reg.frevisio, null, null, null, null, v_movimi, f_sysdate);
           IF num_err <> 0 THEN
              Raise Error_Poliza;
           END IF;

           -- Se graba el registro de historicoseguros
           num_err := f_act_hisseg(reg.sseguro, v_movimi - 1);
           IF num_err <> 0 THEN
              Raise Error_Poliza;
           END IF;

           -- Se graba la nueva duración en SEGUROS_AHO.NDURPER
           -- Las pólizas que no tienen seguros_aho.ndurper informado también deben poder revisar interés
           -- (Ahorro Seguro, Pla d'Estalvi y PPA)
           BEGIN
             UPDATE SEGUROS_AHO
             Set ndurper = v_ndurrev,
             frevant = reg.frevisio,
             frevisio = add_months(reg.frevisio, 12*NVL(v_ndurrev,1))
             Where sseguro = reg.sseguro;

           EXCEPTION
             WHEN OTHERS THEN
                  num_err := 180228;  -- Error al actualizar la tabla SEGUROS_AHO
                  Raise Error_Poliza;
           END;

           -- Se graba el nuevo interés técnico en INTERTECSEG
           num_err := pac_prod_comu.F_GRABAR_INTTEC(reg.sproduc, reg.sseguro, reg.frevisio, V_MOVIMI, v_pintrev, 'SEG');
           IF num_err <> 0 THEN
              Raise Error_Poliza;
           END IF;

           -- Se graban los nuevos % de penalización
           num_err := pac_prod_comu.F_GRABAR_PENALIZACION(2, reg.sproduc, reg.sseguro, reg.frevisio, V_MOVIMI, 'SEG');
           IF num_err <> 0 THEN
              Raise Error_Poliza;
           END IF;


           -- Se duplican las garantias
           num_err := f_dupgaran(reg.sseguro, reg.frevisio, v_movimi);
           IF num_err <> 0 THEN
              Raise Error_Poliza;
           END IF;

           -- Se duplica pregunseg
           num_err := f_duppregunseg(reg.sseguro, v_movimi);
           IF num_err <> 0 THEN
              Raise Error_Poliza;
           END IF;

           -- Se duplica pregungaranseg
           num_err := f_duppregungaranseg(reg.sseguro, reg.frevisio, v_movimi);
           IF num_err <> 0 THEN
              Raise Error_Poliza;
           END IF;

           -- aCTUALIZAMOS LA FTARIFA DE LAS GARANTÍAS
           update garanseg set
           ftarifa = reg.frevisio
           where sseguro = reg.sseguro
           and nmovimi = v_movimi;

           -- Modificar la prima de la garantia de prima período (pargarantia 'TIPO' = 3) con la provisión actual de la póliza
           Select cramo, cmodali, ctipseg, ccolect, cactivi
           into v_cramo, v_cmodali, v_ctipseg, v_ccolect, v_cactivi
           From seguros
           Where sseguro = reg.sseguro;

           -- Si el producto tiene Evolución de Provisión Matemática, se debe actualizar su prima
           IF NVL(f_parproductos_v(reg.sproduc,'EVOLUPROVMATSEG' ),0) = 1 THEN
              UPDATE garanseg
              Set icapital = v_icapital
              Where sseguro = reg.sseguro
                and nriesgo = 1
                and nmovimi = v_movimi
                and F_Pargaranpro_V(v_cramo, v_cmodali, v_ctipseg, v_ccolect, v_cactivi,
                                    cgarant, 'TIPO') = 3;
           END IF;

           -- Tarifar
           num_err := pac_tarifas.F_TARIFAR_RIESGO_TOT(NULL, reg.sseguro, 1, v_movimi, 1, reg.frevisio, 'CAR');
           IF num_err <> 0 THEN
              Raise Error_Poliza;
           END IF;


   --        num_err := pac_ctaseguro.F_INSCTA_PROV_CAP(reg.sseguro, v_fecha, 'R', psproces);
           num_err := pac_ctaseguro.F_INSCTA_PROV_CAP(reg.sseguro, reg.frevisio, 'R', psproces);
           IF num_err <> 0 THEN
              Raise Error_Poliza;
           END IF;

           BEGIN
             -- Se inicializan los valores
             UPDATE seguros_aho
             Set ndurrev = null, pintrev = null
             Where sseguro = reg.sseguro;

           EXCEPTION
             WHEN OTHERS THEN
                  num_err := 180228;  -- Error al actualizar la tabla SEGUROS_AHO
           END;

           -- Todo OK
           Commit;
           -- Número de pólizas revisadas/renovadas correctamente
           n_cont_pol_correctas := n_cont_pol_correctas + 1;

        EXCEPTION
          WHEN Error_Poliza THEN
               Rollback;
               -- Número de pólizas revisadas/renovadas incorrectamente
               n_cont_pol_incorrectas := n_cont_pol_incorrectas + 1;
               error := f_proceslin(v_sproces, num_err ||' - '||F_AXIS_LITERALES(num_err, F_IDIOMAUSER), reg.sseguro, nprolin, 1);
        END;

      END LOOP;

        error := f_proceslin(v_sproces, 'Nº Total de pólizas procesadas = '||n_cont_total_pol_procesadas||' ; Nº Pólizas Correctas = '||n_cont_pol_correctas||' , Nº Pólizas Incorrectas = '||n_cont_pol_incorrectas, 1, nprolin, 4);
        error := f_proceslin(v_sproces, 'Fin proceso Revision/Renovacion '|| TO_CHAR (f_sysdate, 'DD-MM-YYYY  HH24:MI'), 1, nprolin, 4);

        IF psproces IS NULL THEN
           error := f_procesfin(v_sproces,error);
        END IF;

      END p_revision_renovacion;
   */
   FUNCTION f_solicitud_traspaso (
      pcinout          IN       NUMBER,                -- 1.-Entrada 2.-Salida
      pcodpla_o        IN       NUMBER,
      pcodpla_d        IN       NUMBER,
      pcodaseg_o       IN       VARCHAR2,
      pcodaseg_d       IN       VARCHAR2,
      psseguro_o       IN       NUMBER,
      psseguro_d       IN       NUMBER,
      pnumppa          IN       VARCHAR2,     -- Número PPA traspasos externos
      pctiptras        IN       NUMBER,
      pctiptrassol     IN       NUMBER,
                                 -- 1.-Import 2.-Percentatge 3.-Participacions
      pimport          IN       NUMBER,
      pnporcen         IN       NUMBER,
      pnparpla         IN       NUMBER,
      pctipcom         IN       NUMBER,
      pintern          IN       BOOLEAN,
      pobservaciones   IN       VARCHAR2,
      ostras           OUT      NUMBER,
      ocoderror        OUT      NUMBER
   )
      RETURN NUMBER
   IS
      v_tcodpla        trasplainout.tcodpla%TYPE;
      v_cbancar        trasplainout.cbancar%TYPE;
      v_npoliza        seguros.npoliza%TYPE;
      v_ncertif        seguros.ncertif%TYPE;
      v_stras          trasplainout.stras%TYPE;
      v_cagrpro        productos.cagrpro%TYPE;
      v_ccodpla        planpensiones.ccodpla%TYPE;
      v_ccodaseg       aseguradoras.ccodaseg%TYPE;
      err              EXCEPTION;
      v_ctiptrassol    trasplainout.ctiptrassol%TYPE;
      v_ctipcom        trasplainout.ctipcom%TYPE;
      v_import         trasplainout.iimptemp%TYPE;
      v_nporcen        trasplainout.nporcen%TYPE;
      v_nparpla        trasplainout.nparpla%TYPE;
      v_cexterno       NUMBER (1);
      vagente_poliza   seguros.cagente%TYPE;
      vcempres         seguros.cempres%TYPE;
   BEGIN
      IF pctiptras = 1
      THEN
         v_ctiptrassol := 1;
         v_ctipcom := 3;
         v_import := NULL;
         v_nporcen := NULL;
         v_nparpla := NULL;
      ELSE
         v_ctiptrassol := pctiptrassol;
         v_ctipcom := pctipcom;
         v_import := pimport;
         v_nporcen := pnporcen;
         v_nparpla := pnparpla;
      END IF;

      /* Si es un traspàs intern sempre es dona d'alta un traspas de sortida */
      IF pintern = TRUE
      THEN
         SELECT cagrpro
           INTO v_cagrpro
           FROM seguros
          WHERE sseguro = psseguro_d;

         IF v_cagrpro = 11
         THEN
            -- Ini Bug 16790 - SRA - 02/02/2011
            SELECT tnompla, f.cbancar, pr.ccodpla
              INTO v_tcodpla, v_cbancar, v_ccodpla
              FROM seguros s INNER JOIN proplapen pr ON s.sproduc = pr.sproduc
                   INNER JOIN planpensiones pl ON pr.ccodpla = pl.ccodpla
                   INNER JOIN fonpensiones f ON pl.ccodfon = f.ccodfon
             -- Fin Bug 16790 - SRA - 02/02/2011
            WHERE  sseguro = psseguro_d;
         ELSE
            --Bug10612 - 07/07/2009 - DCT (canviar vista personas)
            --Conseguimos el vagente_poliza y la empresa de la póliza a partir del psseguro
            SELECT cagente, cempres
              INTO vagente_poliza, vcempres
              FROM seguros
             WHERE sseguro = psseguro_d;

            SELECT    SUBSTR (d.tapelli1, 0, 40)
                   || ' '
                   || SUBSTR (d.tapelli2, 0, 20),
                   aseguradoras.cbancar, aseguradoras.ccodaseg
              INTO v_tcodpla,
                   v_cbancar, v_ccodaseg
              FROM per_personas p, per_detper d, aseguradoras
             WHERE aseguradoras.sperson = p.sperson
               AND d.sperson = p.sperson
               AND ROWNUM = 1
               -- son personas públicas, pero por seguridad solo seleccionamos un registro
               --AND d.cagente = ff_agente_cpervisio(vagente_poliza, f_sysdate, vcempres)
               AND aseguradoras.cempres = vcempres;
         END IF;

         ocoderror := f_buscapoliza (psseguro_d, v_npoliza, v_ncertif);

         IF ocoderror != 0
         THEN
            RAISE err;
         END IF;

         INSERT INTO trasplainout
                     (stras, cinout, sseguro, fsolici, ccodpla,
                      tpolext, cbancar, cestado, ctiptras, iimptemp,
                      ncertext, nporcen, nparpla, ctiptrassol,
                      ctipcom, ccodaseg, tcodpla, tmemo
                     )
-- Ini Bug 16790 - SRA - 02/11/2010: se hace corrección para cumplir los estándares, norma 6.2.d
         VALUES      (stras.NEXTVAL, 2, psseguro_o, f_sysdate, v_ccodpla,
                      v_npoliza, v_cbancar,
-- Fin Bug 16790 - SRA - 02/11/2010
                      1, pctiptras, v_import,
                      v_ncertif, v_nporcen, v_nparpla, v_ctiptrassol,
                      v_ctipcom, v_ccodaseg, v_tcodpla, pobservaciones
                     )
           RETURNING stras
                INTO v_stras;
      ELSE
         IF pcinout = 1
         THEN
            IF pcodpla_o IS NOT NULL
            THEN
               -- Ini bug 16790 - SRA - 02/02/2011
               SELECT p.tnompla, f.cbancar
                 INTO v_tcodpla, v_cbancar
                 FROM planpensiones p INNER JOIN fonpensiones f
                      ON p.ccodfon = f.ccodfon
                WHERE p.ccodpla = pcodpla_o;
            ELSE
               SELECT personas.tapelli, aseguradoras.cbancar
                 INTO v_tcodpla, v_cbancar
                 FROM aseguradoras INNER JOIN personas
                      ON aseguradoras.sperson = personas.sperson
                WHERE aseguradoras.ccodaseg = pcodaseg_o;
            -- Fin bug 16790 - SRA - 02/02/2011
            END IF;

            INSERT INTO trasplainout
                        (stras, cinout, sseguro, fsolici, ccodpla,
                         tcodpla, cbancar, cestado, ctiptras, iimptemp,
                         nporcen, nparpla, ctiptrassol, ctipcom,
                         ccodaseg, tpolext, cexterno, tmemo
                        )
-- Ini Bug 16790 - SRA - 02/11/2010: se hace corrección para cumplir los estándares, norma 6.2.d
            VALUES      (stras.NEXTVAL, 1, psseguro_d, f_sysdate, pcodpla_o,
                         v_tcodpla,
-- Fin Bug 16790 - SRA - 02/11/2010
                                   v_cbancar, 1, pctiptras, v_import,
                         v_nporcen, v_nparpla, v_ctiptrassol, v_ctipcom,
                         pcodaseg_o, pnumppa, 1, pobservaciones
                        )              -- jgm - BUG 10124 - CEXTERNO PONÍA 'E'
              RETURNING stras
                   INTO v_stras;
         ELSE
            IF pcodpla_d IS NOT NULL
            THEN
               -- Ini bug 16790 - SRA - 02/02/2011
               SELECT p.tnompla, f.cbancar
                 INTO v_tcodpla, v_cbancar
                 FROM planpensiones p INNER JOIN fonpensiones f
                      ON p.ccodfon = f.ccodfon
                WHERE p.ccodpla = pcodpla_o;
            ELSE
               SELECT personas.tapelli, aseguradoras.cbancar
                 INTO v_tcodpla, v_cbancar
                 FROM aseguradoras INNER JOIN personas
                      ON aseguradoras.sperson = personas.sperson
                WHERE aseguradoras.ccodaseg = pcodaseg_d;
            -- Fin bug 16790 - SRA - 02/02/2011
            END IF;

            INSERT INTO trasplainout
                        (stras, cinout, sseguro, fsolici, ccodpla,
                         tcodpla, cbancar, cestado, ctiptras, iimptemp,
                         nporcen, nparpla, ctiptrassol, ctipcom,
                         ccodaseg, tpolext, cexterno, tmemo
                        )
-- Ini Bug 16790 - SRA - 02/11/2010: se hace corrección para cumplir los estándares, norma 6.2.d
            VALUES      (stras.NEXTVAL, 2, psseguro_o, f_sysdate, pcodpla_d,
                         v_tcodpla,
-- Fin Bug 16790 - SRA - 02/11/2010
                                   v_cbancar, 1, pctiptras, v_import,
                         v_nporcen, v_nparpla, v_ctiptrassol, v_ctipcom,
                         pcodaseg_d, pnumppa, 1, pobservaciones
                        )              -- jgm - BUG 10124 - CEXTERNO PONÍA 'E'
              RETURNING stras
                   INTO v_stras;
         END IF;
      END IF;

      ostras := v_stras;
      RETURN 0;
   EXCEPTION
      WHEN err
      THEN
         RETURN NULL;
      WHEN OTHERS
      THEN
         IF pintern
         THEN
            v_cexterno := 1;          -- jgm - BUG 10124 - CEXTERNO PONÍA 'E'
         ELSE
            v_cexterno := 0;          -- jgm - BUG 10124 - CEXTERNO PONÍA 'I'
         END IF;

-- Ini Bug 16790 - SRA - 02/11/2010: se hace corrección para cumplir los estándares, norma 6.2.d
         p_tab_error (f_sysdate,
                      getuser,
                      'PODUCCION_AHO.f_solicita_traspaso',
                      NULL,

-- Fin Bug 16790 - SRA - 02/11/2010
                         'psseguro_o  = '
                      || psseguro_o
                      || 'psseguro_d  = '
                      || psseguro_d
                      || ' pcexterno = '
                      || v_cexterno
                      || ' pccodpla_o  = '
                      || pcodpla_o
                      || ' pccodpla_d  = '
                      || pcodpla_d
                      || ' pccodaseg_o = '
                      || pcodaseg_o
                      || ' pccodaseg_d = '
                      || pcodaseg_d
                      || ' pctipsol  = '
                      || pctiptrassol
                      || ' pctiptras = '
                      || pctiptras
                      || ' pctipcom  = '
                      || pctipcom
                      || ' pimporte  = '
                      || pimport
                      || ' pporcen   = '
                      || pnporcen
                      || ' ppartis   = '
                      || pnparpla
                      || ' numppa  = '
                      || pnumppa,
                      SQLERRM
                     );
         ocoderror := 500187;
         RETURN NULL;
   END f_solicitud_traspaso;
END pac_prod_aho;

/

  GRANT EXECUTE ON "AXIS"."PAC_PROD_AHO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_PROD_AHO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_PROD_AHO" TO "PROGRAMADORESCSI";
