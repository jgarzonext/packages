--------------------------------------------------------
--  DDL for Package Body PAC_CALCULO_FORMULAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_CALCULO_FORMULAS" IS
   /******************************************************************************
      NOMBRE:     pac_calculo_formulas
      PROPÓSITO:  Funciones para el cálculo de formulas

      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.0        XX/XX/XXXX   XXX                1. Creación del package.
      1.2        01/03/2009   JRH                1.2 Bug 7959
      2.0        22/12/2009   RSC                2. 0010690: APR - Provisiones en productos de cartera (PORTFOLIO)
      3.0        02/06/2010   RSC                3. 0014741: APR703 - Baja de garantías básicas
      4.0        19/03/2012   JMF                4. 0021655 MDP - TEC - Cálculo del Consorcio
      5.0        06/06/2012   DRA                5. 0022279: MDP - TEC - Parametrización producto de Comercio - Nueva producción
      6.0        16/11/2012   RSC                6. 0024656: MDP_T001-Ajustes finalies en implataci?n de Suplementos
      7.0        13/03/2013   ECP                7. 0026092: LCOL_T031-LCOL - Fase 3 - (176-11) - Parametrizaci?n PSU's. Nota 140055
      8.0        18/12/2013   APD                8. 0027048/155371: LCOL_T010-Revision incidencias qtracker (V)
   ******************************************************************************/
   exgrabaparam   EXCEPTION;

-- ****************************************************************
-- Estas variables sirven para acceder a los capitales/primas de garantías que no sean la que se están tarificando en ese momento
-- Retorno 0=ok, numero=codigo error.
-- ini Bug 0021655 - 19/03/2012 - JMF
-- ****************************************************************
   FUNCTION f_val_gar(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pcgarant IN NUMBER,
      pnmovimi IN NUMBER,
      porigen IN NUMBER,
      psesion IN NUMBER)
      RETURN NUMBER IS
      vobj           VARCHAR2(200) := 'pac_calculo_formulas.f_val_gar';
      vpas           NUMBER := 1;
      vpar           VARCHAR2(200)
         := 's=' || psseguro || ' r=' || pnriesgo || ' g=' || pcgarant || ' m=' || pnmovimi
            || ' o=' || porigen || ' s=' || psesion;
      num_err        NUMBER;
   BEGIN
      vpas := 100;

      -- Variables tarificacion
      FOR reg IN (SELECT g.nriesgo, g.cgarant, g.icapital, g.ipritar, g.iprianu, g.itarifa
                    FROM garanseg g
                   WHERE sseguro = psseguro
                     AND nriesgo = NVL(pnriesgo, nriesgo)
                     -- AND cgarant = NVL(pcgarant, cgarant)  -- BUG22279:DRA:06/06/2012: Hacemos que grabe todas las garantias
                     AND nmovimi = pnmovimi
                     AND porigen = 2
                  UNION
                  SELECT g.nriesgo, g.cgarant, g.icapital, g.ipritar, g.iprianu, g.itarifa
                    FROM estgaranseg g
                   WHERE sseguro = psseguro
                     AND nriesgo = NVL(pnriesgo, nriesgo)
                     -- AND cgarant = NVL(pcgarant, cgarant)  -- BUG22279:DRA:06/06/2012: Hacemos que grabe todas las garantias
                     AND nmovimi = pnmovimi
                     AND cobliga = 1
                     AND porigen = 1) LOOP
         vpas := 110;
         num_err := graba_param(psesion, 'CAP-' || NVL(reg.nriesgo, 1) || '-' || reg.cgarant,
                                reg.icapital);

         IF num_err <> 0 THEN
            RETURN 108425;
         END IF;

         vpas := 120;
         num_err := graba_param(psesion,
                                'IPRITAR-' || NVL(reg.nriesgo, 1) || '-' || reg.cgarant,
                                reg.ipritar);

         IF num_err <> 0 THEN
            RETURN 108426;
         END IF;

         vpas := 130;
         num_err := graba_param(psesion,
                                'IPRIANU-' || NVL(reg.nriesgo, 1) || '-' || reg.cgarant,
                                reg.iprianu);

         IF num_err <> 0 THEN
            RETURN 108427;
         END IF;

         vpas := 140;
         num_err := graba_param(psesion,
                                'IPRIPUR-' || NVL(reg.nriesgo, 1) || '-' || reg.cgarant,
                                NVL(reg.icapital * reg.itarifa, 0));

         IF num_err <> 0 THEN
            RETURN 9903349;
         END IF;

         vpas := 150;
         num_err := graba_param(psesion,
                                'GAR_CONTRATADA-' || NVL(reg.nriesgo, 1) || '-' || reg.cgarant,
                                1);

         IF num_err <> 0 THEN
            RETURN 108427;
         END IF;
      END LOOP;

      vpas := 160;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobj, vpas, 'others ' || vpar,
                     SQLCODE || '-' || SQLERRM);
         RETURN 9000787;
   -- fin Bug 0021655 - 19/03/2012 - JMF
   END f_val_gar;

-- ****************************************************************
-- Calcula una formula
    --  28-3-2007. Se añaden los parámetros pfecefe y pmodo (para porder hacer previos de cierres).
    --      Además se corrigen los cursores de preguntas para tener en cuenta el pnmovimi y se añade el
    -- cálculo de más parámetros: fecha vencimiento, fecha de efecto, forma de pago, accion, aportación ext.
    --  6-7-2007. Inclure taules per SOL i EST
-- ****************************************************************
    -- Bug 10690 - RSC - 22/12/2009 - APR - Provisiones en productos de cartera (PORTFOLIO)
    -- Añadimos pndetgar
   --BUG 24656-XVM-16/11/2012.Añadir paccion
   --paccion       IN NUMBER DEFAULT NULL  Indica si estamos en suplemento o no. 0-Nueva Prod. 2-Suplemento
   FUNCTION calc_formul(
      pfecha IN DATE,   -- Fecha
      psproduc IN NUMBER,   -- SPRODUC
      pcactivi IN NUMBER,   -- Actividad
      pcgarant IN NUMBER,   -- Garantía
      pnriesgo IN NUMBER,   -- Riesgo
      psseguro IN NUMBER,   -- SSEGURO
      pclave IN NUMBER,   -- Clave de la Formula
      resultado OUT NUMBER,   -- Valor provisión
      pnmovimi IN NUMBER DEFAULT NULL,   -- Movimiento
      psesion IN NUMBER DEFAULT NULL,   -- Sesion
      porigen IN NUMBER DEFAULT 2,   -- 0.- SOL, 1.- EST, 2.- SEG
      pfecefe IN DATE DEFAULT NULL,   -- fecha de tarifa
      pmodo IN VARCHAR2 DEFAULT 'R',
      pndetgar IN NUMBER DEFAULT NULL,
      paccion IN NUMBER DEFAULT 1,   --'R'REAL, 'P' PREVIO
      -- Ini Bug 26092 --ECP-- 13/03/2013
      origenpsu IN NUMBER DEFAULT NULL,
      -- Fin Bug 26092 --ECP-- 13/03/2013
      pnrecibo IN NUMBER DEFAULT NULL,   -- BUG31548:DRA:23/09/2014
      pnsinies IN NUMBER DEFAULT NULL)   -- BUG31548:DRA:23/09/2014
      RETURN NUMBER IS
-- ***************************************************************************
-- FALTA CONTROLAR LAS PREGUNTAS AUTOMATICAS PARA PODER TARIFAR CON ESTE METODO
--******************************************************************************
      val            NUMBER;   -- Valor que retorna la formula
      xxformula      VARCHAR2(20000);   -- contiene la Formula a calcular
      xxsesion       NUMBER;   -- Nro de sesion que ejecuta la formula
      e              NUMBER;   -- Error Retorno funciones
      --  xiprovmat  NUMBER; -- Valoración del siniestro
      xxcodigo       VARCHAR2(30);
      xfecefe        NUMBER;
      xs             VARCHAR2(20000);
      retorno        NUMBER;
      xnmovimi       NUMBER;
      x_cllamada     VARCHAR2(100);
      xfecha         NUMBER;
      xfefecto       NUMBER;
      xfvencim       NUMBER;
      xcforpag       NUMBER;
      ntraza         NUMBER := 0;
      v_cursor       INTEGER;
      v_filas        NUMBER;
      -- RSC 04/08/2008
      xfrevant       NUMBER;
      -- Bug 0021655 - 19/03/2012 - JMF
      num_err        NUMBER;
      vparams        VARCHAR2(2000)
         := ' - params:' || ' pfecha=' || pfecha || ' psproduc=' || psproduc || ' pcactivi='
            || pcactivi || ' pcgarant=' || pcgarant || ' pnriesgo=' || pnriesgo
            || ' psseguro=' || psseguro || ' pclave=' || pclave || ' pnmovimi=' || pnmovimi
            || ' psesion=' || psesion || ' porigen=' || porigen || ' pfecefe=' || pfecefe
            || ' pmodo=' || pmodo || ' pndetgar=' || pndetgar || ' paccion=' || paccion
            || ' origenpsu=' || origenpsu || ' pnrecibo=' || pnrecibo || ' pnsinies='
            || pnsinies;

      CURSOR cur_termino(wclave NUMBER) IS
         SELECT   parametro
             FROM sgt_trans_formula
            WHERE clave = wclave
         ORDER BY 1;

--------------------------------------------------------------------------
-- CRE_145 - 23/07/2008 - Añade las preguntas por póliza
-- PREGUNPOLSEG
-- ESTPREGUNPOLSEG
-- SOLPREGUNPOLSEG --> Esta tabla no existe y no la vamos a usar
--------------------------------------------------------------------------
      CURSOR c_preg_pol_seg IS
         SELECT cpregun, crespue
           FROM pregunpolseg
          WHERE sseguro = psseguro
            AND nmovimi = (SELECT MAX(nmovimi)
                             FROM pregunpolseg
                            WHERE sseguro = psseguro
                              AND nmovimi <= NVL(pnmovimi,
                                                 (SELECT MAX(nmovimi)
                                                    FROM movseguro
                                                   WHERE sseguro = psseguro
                                                     AND fefecto <= pfecha)));

      CURSOR c_preg_pol_est IS
         SELECT cpregun, crespue
           FROM estpregunpolseg
          WHERE sseguro = psseguro
            AND nmovimi = (SELECT MAX(nmovimi)
                             FROM estpregunpolseg
                            WHERE sseguro = psseguro
                              AND nmovimi = NVL(pnmovimi, nmovimi));

      CURSOR c_preg_risc_seg IS
         SELECT cpregun, crespue
           FROM pregunseg
          WHERE sseguro = psseguro
            AND nriesgo = pnriesgo
            AND nmovimi = (SELECT MAX(nmovimi)
                             FROM pregunseg
                            WHERE sseguro = psseguro
                              AND nriesgo = pnriesgo
                              AND nmovimi <= NVL(pnmovimi,
                                                 (SELECT MAX(nmovimi)
                                                    FROM movseguro
                                                   WHERE sseguro = psseguro
                                                     AND fefecto <= pfecha)));

      CURSOR c_preg_risc_est IS
         SELECT cpregun, crespue
           FROM estpregunseg
          WHERE sseguro = psseguro
            AND nriesgo = pnriesgo
            AND nmovimi = (SELECT MAX(nmovimi)
                             FROM estpregunseg
                            WHERE sseguro = psseguro
                              AND nriesgo = pnriesgo
                              AND nmovimi = NVL(pnmovimi, nmovimi));

      CURSOR c_preg_risc_sol IS
         SELECT cpregun, crespue
           FROM solpregunseg
          WHERE ssolicit = psseguro
            AND nriesgo = pnriesgo
            AND nmovimi = 1;

      CURSOR c_preg_gar_seg IS
         SELECT cpregun, crespue
           FROM pregungaranseg
          WHERE sseguro = psseguro
            AND nriesgo = pnriesgo
            AND cgarant = pcgarant
            AND nmovimi =
                  (SELECT MAX(nmovimi)
                     FROM pregungaranseg
                    WHERE sseguro = psseguro
                      AND nriesgo = pnriesgo
                      AND cgarant =
                            pcgarant   -- Bug 14741 - 31/05/2010 - APR703 - Baja de garantías básicas
                      AND nmovimi <= NVL(pnmovimi,
                                         (SELECT MAX(nmovimi)
                                            FROM movseguro
                                           WHERE sseguro = psseguro
                                             AND fefecto <= pfecha)));

      CURSOR c_preg_gar_est IS
         SELECT cpregun, crespue
           FROM estpregungaranseg
          WHERE sseguro = psseguro
            AND nriesgo = pnriesgo
            AND cgarant = pcgarant
            AND nmovimi = (SELECT MAX(nmovimi)
                             FROM estpregungaranseg
                            WHERE sseguro = psseguro
                              AND nriesgo = pnriesgo
                              AND cgarant = pcgarant);

      CURSOR c_preg_gar_sol IS
         SELECT cpregun, crespue
           FROM solpregungaranseg
          WHERE ssolicit = psseguro
            AND nriesgo = pnriesgo
            AND cgarant = pcgarant;

      no_encuentra   EXCEPTION;
   BEGIN
      p_control_error('JAMF', 'PAC_CALCULO_FORMULAS.calc_formul',
                      'Entra con pfecefe=' || pfecefe || ' pfecha=' || pfecha);
      xfecefe := TO_NUMBER(TO_CHAR(NVL(pfecefe, pfecha), 'YYYYMMDD'));
      xfecha := TO_NUMBER(TO_CHAR(pfecha, 'YYYYMMDD'));
      ntraza := 1;
      p_control_error('JAMF', 'PAC_CALCULO_FORMULAS.calc_formul',
                      'Pasa creación fechas xfecefe=' || xfecefe || ' xfecha=' || xfecha);

      IF psesion IS NULL THEN
         SELECT sgt_sesiones.NEXTVAL
           INTO xxsesion
           FROM DUAL;
      ELSE
         xxsesion := psesion;
      END IF;

      IF xxsesion IS NULL THEN
         ROLLBACK;
         RETURN 108418;
      END IF;

      ntraza := 2;

      IF pnmovimi IS NULL THEN
         CASE porigen
            WHEN 2 THEN
               SELECT MAX(nmovimi)
                 INTO xnmovimi
                 FROM garanseg
                WHERE sseguro = psseguro
                  AND nriesgo = NVL(pnriesgo, nriesgo)
                  AND cgarant = NVL(pcgarant, cgarant)
                  AND finiefe <= pfecha
                  AND(ffinefe > pfecha
                      OR ffinefe IS NULL);
            WHEN 1 THEN
               SELECT MAX(nmovimi)
                 INTO xnmovimi
                 FROM estgaranseg
                WHERE sseguro = psseguro
                  AND nriesgo = NVL(pnriesgo, nriesgo)
                  AND cgarant = NVL(pcgarant, cgarant)
                  AND finiefe <= pfecha
                  AND(ffinefe > pfecha
                      OR ffinefe IS NULL);
            WHEN 0 THEN
               SELECT MAX(1)   --JRAH Tarea 6966
                 INTO xnmovimi
                 FROM solgaranseg
                WHERE ssolicit = psseguro
                  AND nriesgo = NVL(pnriesgo, nriesgo)
                  AND cgarant = NVL(pcgarant, cgarant)
                  AND finiefe <= pfecha;
         END CASE;
      ELSE
         xnmovimi := pnmovimi;
      END IF;

      -- ini Bug 0021655 - 19/03/2012 - JMF
      num_err := pac_calculo_formulas.f_val_gar(psseguro, pnriesgo, pcgarant, xnmovimi,
                                                porigen, xxsesion);

      IF NVL(num_err, 0) <> 0 THEN
         RETURN num_err;
      END IF;

      -- fin Bug 0021655 - 19/03/2012 - JMF
      IF porigen = 0 THEN
         x_cllamada := 'SOLICITUDES';
      ELSIF porigen = 1 THEN
         x_cllamada := 'ESTUDIOS';
      ELSE
         IF pmodo = 'P' THEN
            x_cllamada := 'PREVIO';
         ELSE
            x_cllamada := 'GENERICO';
         END IF;
      END IF;

      ntraza := 3;
      -- Quan hi ha error graba_param fa un RAISE exGrabaParam
      e := graba_param(xxsesion, 'SESION', xxsesion);
      -- Insertamos parametros genericos para el calculo de las provisiones
      e := graba_param(xxsesion, 'FECEFE', xfecefe);
      e := graba_param(xxsesion, 'FECHA', xfecha);
      e := graba_param(xxsesion, 'SSEGURO', psseguro);
      e := graba_param(xxsesion, 'SPRODUC', psproduc);
      e := graba_param(xxsesion, 'CACTIVI', pcactivi);
      e := graba_param(xxsesion, 'CGARANT', pcgarant);
      e := graba_param(xxsesion, 'GARANTIA', pcgarant);
      e := graba_param(xxsesion, 'NRIESGO', pnriesgo);
      e := graba_param(xxsesion, 'ORIGEN', porigen);
      e := graba_param(xxsesion, 'NMOVIMI', xnmovimi);
      --Bug 27048/155371 - APD - 17/12/2013
      e := graba_param(xxsesion, 'ORIGENPSU', origenpsu);

      --fin Bug 27048/155371 - APD - 17/12/2013

      -- Bug 10690 - RSC - 22/12/2009 - APR - Provisiones en productos de cartera (PORTFOLIO)
      IF pndetgar IS NOT NULL THEN
         e := graba_param(xxsesion, 'NDETGAR', pndetgar);
      ELSE
         e := graba_param(xxsesion, 'NDETGAR', -1);
      END IF;

      -- Fin Bug 10690

      -- Bug 31548 - DRA - 23/09/2014 - Grabamos el numero de recibo
      IF pnrecibo IS NOT NULL THEN
         e := graba_param(xxsesion, 'NRECIBO', pnrecibo);
      END IF;

      IF pnsinies IS NOT NULL THEN
         e := graba_param(xxsesion, 'NSINIES', pnsinies);
      END IF;

      -- Fin Bug 31548

      -- CPM 19/10/06: Se añade la fecha efecto de la póliza y la fecha de vencimiento
      BEGIN
         CASE porigen
            WHEN 2 THEN
               SELECT TO_NUMBER(TO_CHAR(fefecto, 'YYYYMMDD')),
                      TO_NUMBER(TO_CHAR(fvencim, 'YYYYMMDD')), cforpag
                 INTO xfefecto,
                      xfvencim, xcforpag
                 FROM seguros
                WHERE sseguro = psseguro;
            WHEN 1 THEN
               SELECT TO_NUMBER(TO_CHAR(fefecto, 'YYYYMMDD')),
                      TO_NUMBER(TO_CHAR(fvencim, 'YYYYMMDD')), cforpag
                 INTO xfefecto,
                      xfvencim, xcforpag
                 FROM estseguros
                WHERE sseguro = psseguro;
            WHEN 0 THEN
               SELECT TO_NUMBER(TO_CHAR(falta, 'YYYYMMDD')),
                      TO_NUMBER(TO_CHAR(fvencim, 'YYYYMMDD')), cforpag
                 INTO xfefecto,
                      xfvencim, xcforpag
                 FROM solseguros
                WHERE ssolicit = psseguro;
         END CASE;

         -- RSC 04/08/2008 Añadimos la FREVANT
         BEGIN   -- BUG 7959 - 03/2009 - JRH  - Decesos. NO_DATA_FOUND necesario para riesgo.
            CASE porigen
               WHEN 2 THEN
                  SELECT TO_NUMBER(TO_CHAR(frevant, 'YYYYMMDD'))
                    INTO xfrevant
                    FROM seguros_aho
                   WHERE sseguro = psseguro;
               WHEN 1 THEN
                  SELECT TO_NUMBER(TO_CHAR(frevant, 'YYYYMMDD'))
                    INTO xfrevant
                    FROM estseguros_aho
                   WHERE sseguro = psseguro;
               WHEN 0 THEN
                  SELECT TO_NUMBER(TO_CHAR(frevant, 'YYYYMMDD'))
                    INTO xfrevant
                    FROM solseguros_aho
                   WHERE ssolicit = psseguro;
            END CASE;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               NULL;
         END;

         -- Quan hi ha error graba_param fa un RAISE exGrabaParam
         p_control_error('JAMF', 'PAC_CALCULO_FORMULAS.calc_formul',
                         'Graba parámetros xfefecto=' || xfefecto || ' xfvencim=' || xfvencim
                         || ' xfrevant=' || xfrevant);
         e := graba_param(xxsesion, 'FEFECTO', xfefecto);
         e := graba_param(xxsesion, 'FEFEPOL', xfefecto);
         e := graba_param(xxsesion, 'FECVEN', xfvencim);
         e := graba_param(xxsesion, 'FPAGPRIMA', xcforpag);
         e := graba_param(xxsesion, 'ACCION', NVL(paccion, 1));
         e := graba_param(xxsesion, 'APORTEXT', 0);
         e := graba_param(xxsesion, 'FREVANT', xfrevant);   -- RSC 04/08/2008
      EXCEPTION
         WHEN exgrabaparam THEN
            RETURN 109843;
         WHEN OTHERS THEN
            NULL;
      END;

      ntraza := 4;

      BEGIN
         SELECT formula, codigo
           INTO xxformula, xxcodigo
           FROM sgt_formulas
          WHERE clave = pclave;
      EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, 'Calculo fórmulas', ntraza,
                        SUBSTR('error al buscar en SGT_FORMULAS SSEGURO =' || psseguro
                               || ' PFECHA=' || pfecha || ' clave =' || pclave || vparams,
                               1, 500),
                        SUBSTR(SQLERRM, 1, 2500));
            RETURN 108423;
      END;

      -- Cargo parametros predefinidos
      ntraza := 5;
      p_control_error('JAMF', 'PAC_CALCULO_FORMULAS.calc_formul',
                      'Traza 5    pclave=' || pclave);

      FOR term IN cur_termino(pclave) LOOP
         BEGIN
            BEGIN
               SELECT 'BEGIN SELECT ' || tcampo || ' INTO :RETORNO  FROM ' || ttable
                      || ' WHERE ' || twhere || ' ; END;'
                 INTO xs
                 FROM sgt_carga_arg_prede
                WHERE termino = term.parametro
                  AND ttable IS NOT NULL
                  AND cllamada = x_cllamada;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  IF x_cllamada = 'PREVIO' THEN
                     BEGIN
                        SELECT 'BEGIN SELECT ' || tcampo || ' INTO :RETORNO  FROM ' || ttable
                               || ' WHERE ' || twhere || ' ; END;'
                          INTO xs
                          FROM sgt_carga_arg_prede
                         WHERE termino = term.parametro
                           AND ttable IS NOT NULL
                           AND cllamada = 'GENERICO';
                     EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                           RAISE no_encuentra;
                     END;
                  ELSE
                     RAISE no_encuentra;
                  END IF;
            END;

            p_control_error('JAMF', 'PAC_CALCULO_FORMULAS.calc_formul', 'xs=' || xs);

            IF DBMS_SQL.is_open(v_cursor) THEN
               DBMS_SQL.close_cursor(v_cursor);
            END IF;

            v_cursor := DBMS_SQL.open_cursor;
            DBMS_SQL.parse(v_cursor, xs, DBMS_SQL.native);
            DBMS_SQL.bind_variable(v_cursor, ':RETORNO', retorno);

            IF INSTR(xs, ':FECHA') > 0 THEN
               DBMS_SQL.bind_variable(v_cursor, ':FECHA', xfecha);
            END IF;

            IF INSTR(xs, ':FECEFE') > 0 THEN
               DBMS_SQL.bind_variable(v_cursor, ':FECEFE', xfecefe);
            END IF;

            IF INSTR(xs, ':SSEGURO') > 0 THEN
               DBMS_SQL.bind_variable(v_cursor, ':SSEGURO', psseguro);
            END IF;

            IF INSTR(xs, ':SPRODUC') > 0 THEN
               DBMS_SQL.bind_variable(v_cursor, ':SPRODUC', psproduc);
            END IF;

            IF INSTR(xs, ':CACTIVI') > 0 THEN
               DBMS_SQL.bind_variable(v_cursor, ':CACTIVI', pcactivi);
            END IF;

            IF INSTR(xs, ':CGARANT') > 0 THEN
               DBMS_SQL.bind_variable(v_cursor, ':CGARANT', pcgarant);
            END IF;

            IF INSTR(xs, ':NRIESGO') > 0 THEN
               DBMS_SQL.bind_variable(v_cursor, ':NRIESGO', pnriesgo);
            END IF;

            IF INSTR(xs, ':NMOVIMI') > 0 THEN
               DBMS_SQL.bind_variable(v_cursor, ':NMOVIMI', xnmovimi);
            END IF;

            -- Bug 10690 - RSC - 22/12/2009 - APR - Provisiones en productos de cartera (PORTFOLIO)
            IF pndetgar IS NOT NULL THEN
               IF INSTR(xs, ':NDETGAR') > 0 THEN
                  DBMS_SQL.bind_variable(v_cursor, ':NDETGAR', pndetgar);
               END IF;
            ELSE
               IF INSTR(xs, ':NDETGAR') > 0 THEN
                  DBMS_SQL.bind_variable(v_cursor, ':NDETGAR', -1);
               END IF;
            END IF;

            -- BUG31548:DRA:23/09/2014:Inici
            IF INSTR(xs, ':NRECIBO') > 0 THEN
               DBMS_SQL.bind_variable(v_cursor, ':NRECIBO', pnrecibo);
            END IF;

            IF INSTR(xs, ':NSINIES') > 0 THEN
               DBMS_SQL.bind_variable(v_cursor, ':NSINIES', pnsinies);
            END IF;

            -- BUG31548:DRA:23/09/2014:Fi
            ntraza := 6;

            -- Fin Bug 10690
            BEGIN
               v_filas := DBMS_SQL.EXECUTE(v_cursor);
               DBMS_SQL.variable_value(v_cursor, 'RETORNO', retorno);

               IF DBMS_SQL.is_open(v_cursor) THEN
                  DBMS_SQL.close_cursor(v_cursor);
               END IF;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  -- 14/09/05 CPM: Mirem que no estiguem llançant sobre un tancament
                  --  d'estalvi Real
                  IF x_cllamada = 'PREVIO' THEN
                     ntraza := 7;

                     SELECT 'BEGIN SELECT ' || tcampo || ' INTO :RETORNO  FROM ' || ttable
                            || ' WHERE ' || twhere || ' ; END;'
                       INTO xs
                       FROM sgt_carga_arg_prede
                      WHERE termino = term.parametro
                        AND ttable IS NOT NULL
                        AND cllamada = 'GENERICO';

                     IF DBMS_SQL.is_open(v_cursor) THEN
                        DBMS_SQL.close_cursor(v_cursor);
                     END IF;

                     v_cursor := DBMS_SQL.open_cursor;
                     DBMS_SQL.parse(v_cursor, xs, DBMS_SQL.native);
                     DBMS_SQL.bind_variable(v_cursor, ':RETORNO', retorno);

                     --
                     IF INSTR(xs, ':FECHA') > 0 THEN
                        DBMS_SQL.bind_variable(v_cursor, ':FECHA', xfecha);
                     END IF;

                     IF INSTR(xs, ':FECEFE') > 0 THEN
                        DBMS_SQL.bind_variable(v_cursor, ':FECEFE', xfecefe);
                     END IF;

                     IF INSTR(xs, ':SSEGURO') > 0 THEN
                        p_control_error('JAMF', 'PAC_CALCULO_FORMULAS.calc_formul',
                                        'Bind variable :SSEGURO');
                        DBMS_SQL.bind_variable(v_cursor, ':SSEGURO', psseguro);
                     END IF;

                     IF INSTR(xs, ':SPRODUC') > 0 THEN
                        DBMS_SQL.bind_variable(v_cursor, ':SPRODUC', psproduc);
                     END IF;

                     IF INSTR(xs, ':CACTIVI') > 0 THEN
                        DBMS_SQL.bind_variable(v_cursor, ':CACTIVI', pcactivi);
                     END IF;

                     IF INSTR(xs, ':CGARANT') > 0 THEN
                        DBMS_SQL.bind_variable(v_cursor, ':CGARANT', pcgarant);
                     END IF;

                     IF INSTR(xs, ':NRIESGO') > 0 THEN
                        DBMS_SQL.bind_variable(v_cursor, ':NRIESGO', pnriesgo);
                     END IF;

                     IF INSTR(xs, ':NMOVIMI') > 0 THEN
                        DBMS_SQL.bind_variable(v_cursor, ':NMOVIMI', xnmovimi);
                     END IF;

                     -- Bug 10690 - RSC - 22/12/2009 - APR - Provisiones en productos de cartera (PORTFOLIO)
                     IF pndetgar IS NOT NULL THEN
                        IF INSTR(xs, ':NDETGAR') > 0 THEN
                           DBMS_SQL.bind_variable(v_cursor, ':NDETGAR', pndetgar);
                        END IF;
                     ELSE
                        IF INSTR(xs, ':NDETGAR') > 0 THEN
                           DBMS_SQL.bind_variable(v_cursor, ':NDETGAR', -1);
                        END IF;
                     END IF;

                     -- BUG31548:DRA:23/09/2014:Inici
                     IF INSTR(xs, ':NRECIBO') > 0 THEN
                        DBMS_SQL.bind_variable(v_cursor, ':NRECIBO', pnrecibo);
                     END IF;

                     IF INSTR(xs, ':NSINIES') > 0 THEN
                        DBMS_SQL.bind_variable(v_cursor, ':NSINIES', pnsinies);
                     END IF;

                     -- BUG31548:DRA:23/09/2014:Fi
                     ntraza := 8;
                     -- Fin Bug 10690
                     v_filas := DBMS_SQL.EXECUTE(v_cursor);
                     DBMS_SQL.variable_value(v_cursor, 'RETORNO', retorno);

                     IF DBMS_SQL.is_open(v_cursor) THEN
                        DBMS_SQL.close_cursor(v_cursor);
                     END IF;
                  ELSE   -- del PREVIO
                     IF DBMS_SQL.is_open(v_cursor) THEN
                        DBMS_SQL.close_cursor(v_cursor);
                     END IF;

                     p_tab_error(f_sysdate, f_user, 'Pac_Calculo_Formulas.calc_formul', ntraza,
                                 SUBSTR('error al ejecutar con ' || x_cllamada
                                        || ' la select dinámica SSEGURO =' || psseguro
                                        || ' PFECHA=' || pfecha || ' pclave=' || pclave
                                        || ' select =' || xs || vparams,
                                        1, 500),
                                 SQLERRM);
                     retorno := 0;
                  END IF;
               WHEN OTHERS THEN
                  p_control_error('JAMF', 'PAC_CALCULO_FORMULAS.calc_formul',
                                  'Others=' || SQLERRM);

                  IF DBMS_SQL.is_open(v_cursor) THEN
                     DBMS_SQL.close_cursor(v_cursor);
                  END IF;

                  p_tab_error(f_sysdate, f_user, 'Pac_Calculo_Formulas.calc_formul', ntraza,
                              SUBSTR('error al ejecutar la select dinámica SSEGURO ='
                                     || psseguro || ' PFECHA=' || pfecha || ' porigen='
                                     || porigen || ' select =' || xs || vparams,
                                     1, 500),
                              SQLERRM);
                  retorno := 0;
            END;

            IF retorno IS NULL THEN
               RETURN 103135;
            ELSE
               -- Quan hi ha error graba_param fa un RAISE exGrabaParam
               e := graba_param(xxsesion, term.parametro, retorno);
            END IF;
         --
         EXCEPTION
            WHEN no_encuentra THEN
               xs := NULL;
            WHEN exgrabaparam THEN
               RETURN 109843;
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, 'Cálculo de Fórmulas', ntraza,
                           SUBSTR('error al buscar la select dinámica SSEGURO =' || psseguro
                                  || ' PFECHA=' || pfecha || ' para el termino ='
                                  || term.parametro || vparams,
                                  1, 500),
                           SQLERRM);
               xs := NULL;
         END;
      END LOOP;

      ntraza := 9;
      p_control_error('JAMF', 'PAC_CALCULO_FORMULAS.calc_formul', 'Traza 9    Respuestas');

      -- INSERTAMOS LAS PREGUNTAS
      CASE porigen
         WHEN 2 THEN
            FOR preg_pol IN c_preg_pol_seg LOOP
               e := graba_param(xxsesion, 'RESP' || preg_pol.cpregun, preg_pol.crespue);
            END LOOP;
         WHEN 1 THEN
            FOR preg_pol IN c_preg_pol_est LOOP
               e := graba_param(xxsesion, 'RESP' || preg_pol.cpregun, preg_pol.crespue);
            END LOOP;
      END CASE;

      ntraza := 10;

      -- INSERTAMOS LAS PREGUNTAS
      CASE porigen
         WHEN 2 THEN
            FOR preg_risc IN c_preg_risc_seg LOOP
               e := graba_param(xxsesion, 'RESP' || preg_risc.cpregun, preg_risc.crespue);
            END LOOP;
         WHEN 1 THEN
            FOR preg_risc IN c_preg_risc_est LOOP
               e := graba_param(xxsesion, 'RESP' || preg_risc.cpregun, preg_risc.crespue);
            END LOOP;
         WHEN 0 THEN
            FOR preg_risc IN c_preg_risc_sol LOOP
               e := graba_param(xxsesion, 'RESP' || preg_risc.cpregun, preg_risc.crespue);
            END LOOP;
      END CASE;

      ntraza := 11;

      CASE porigen
         WHEN 2 THEN
            FOR preg_gar IN c_preg_gar_seg LOOP
               e := graba_param(xxsesion, 'RESP' || preg_gar.cpregun, preg_gar.crespue);
            END LOOP;
         WHEN 1 THEN
            FOR preg_gar IN c_preg_gar_est LOOP
               e := graba_param(xxsesion, 'RESP' || preg_gar.cpregun, preg_gar.crespue);
            END LOOP;
         WHEN 0 THEN
            FOR preg_gar IN c_preg_gar_sol LOOP
               e := graba_param(xxsesion, 'RESP' || preg_gar.cpregun, preg_gar.crespue);
            END LOOP;
      END CASE;

      ntraza := 12;

      BEGIN
         --JRH Bug 29920
         IF NVL(pac_parametros.f_pargaranpro_n(psproduc, pcactivi, pcgarant, 'SGT_CONMU'), 0) =
                                                                                             1 THEN
            num_err := pac_formul_tarificador.iniciarparametros(psesion);
         END IF;

         p_control_error('JAMF', 'PAC_CALCULO_FORMULAS.calc_formul',
                         'Traza 12    SGT_CONMU ='
                         || NVL(pac_parametros.f_pargaranpro_n(psproduc, pcactivi, pcgarant,
                                                               'SGT_CONMU'),
                                0));
         ntraza := 13;
         --Fin JRH Bug 29920
         p_control_error('JAMF', 'PAC_CALCULO_FORMULAS.calc_formul',
                         'Antes de evaluar fórmula xxformula=' || xxformula || ' xxsesion='
                         || xxsesion);
         val := pk_formulas.eval(xxformula, xxsesion);
         p_control_error('JAMF', 'PAC_CALCULO_FORMULAS.calc_formul',
                         'Después de evaluar fórmula val=' || val);

         -- Borro sgt_parms_transitorios
         -- CPM 20/12/05: Se descomenta el borrar parámetros y se hace antes de detectar
         --   si tenemos valor o no.

         --JAMF
--         e := borra_param(xxsesion);
         IF val IS NULL THEN
            p_tab_error(f_sysdate, f_user, 'Pac_Calculo_Formulas.calc_formul', ntraza,
                        SUBSTR('error al evaluar la formula =' || xxformula || ' sesion ='
                               || xxsesion || vparams,
                               1, 500),
                        NULL);
            RETURN 103135;
         ELSE
            resultado := val;
         END IF;
      EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, 'Pac_Calculo_Formulas.calc_formu', ntraza,
                        SUBSTR('error Oracle al evaluar la formula =' || xxformula
                               || ' sesion =' || xxsesion || vparams,
                               1, 500),
                        SQLERRM);
      END;

      IF DBMS_SQL.is_open(v_cursor) THEN
         DBMS_SQL.close_cursor(v_cursor);
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN exgrabaparam THEN
         RETURN 109843;
   END calc_formul;

-- ****************************************************************
-- Graba en la tabla de parametros transitorios parametros calculo
-- ****************************************************************
   FUNCTION graba_param(wnsesion IN NUMBER, wparam IN VARCHAR2, wvalor IN NUMBER)
      RETURN NUMBER IS
      PRAGMA AUTONOMOUS_TRANSACTION;
      -- I - JLB
      nerror         NUMBER;
   -- F - JLB
   BEGIN
      -- I - JLB
      --INSERT INTO sgt_parms_transitorios
      --            (sesion, parametro, valor)
      --     VALUES (wnsesion, wparam, wvalor);
       --COMMIT;
      nerror := pac_sgt.put(wnsesion, wparam, wvalor);
      RETURN nerror;
   -- F -- JLB
   EXCEPTION
-- I - JLB
 --     WHEN DUP_VAL_ON_INDEX THEN
--         UPDATE sgt_parms_transitorios
  --          SET valor = wvalor
    --      WHERE sesion = wnsesion
      --      AND parametro = wparam;
--
  --       COMMIT;
    --     RETURN 0;
-- F - JLB
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_calculo_formulas.graba_param', NULL,
                     'error al grabar  sesion =' || wnsesion || ' parametro =' || wparam
                     || 'valor =' || wvalor,
                     SQLERRM);
         RAISE exgrabaparam;
   -- RETURN 109843;
   END graba_param;

-- ****************************************************************
-- Borra parametros grabados en la sesion
-- ****************************************************************
   FUNCTION borra_param(wnsesion IN NUMBER)
      RETURN NUMBER IS
      -- I - JLB
      numerror       NUMBER;
   -- F - JLB
   BEGIN
      -- I - JLB
      --   DELETE FROM sgt_parms_transitorios
       --        WHERE sesion = wnsesion;
      numerror := pac_sgt.del(wnsesion);
      RETURN numerror;
   -- F - JLB
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_calculo_formulas.borra_param', NULL,
                     'error al borrar sesion =' || wnsesion, SQLERRM);
         RETURN -9;
   END borra_param;
END pac_calculo_formulas;

/

  GRANT EXECUTE ON "AXIS"."PAC_CALCULO_FORMULAS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_CALCULO_FORMULAS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_CALCULO_FORMULAS" TO "PROGRAMADORESCSI";
