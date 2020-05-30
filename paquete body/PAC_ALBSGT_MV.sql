--------------------------------------------------------
--  DDL for Package Body PAC_ALBSGT_MV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_ALBSGT_MV" IS
/***************************************************************
   PAC_ALBSGT_cs: Cuerpo del paquete de las funciones para
      el cáculo de las preguntas relacionadas con
      productos
   REVISIONES:

   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ----------------------------------
   1.0           -          -               Creació del package
   2.0        17/04/2009   APD              Bug 9685 - en lugar de coger la acticad de la tabla seguros, llamar a la función pac_seguros.ff_get_actividad
   3.0        07/07/2009   DCT              BUG 0010612: CRE - Error en la generació de pagaments automàtics.
                                            Canviar vista personas por tablas personas y añadir filtro de visión de agente
   4.0        12/03/2012   JMF              0021638 MdP - TEC - Indices de revalorización nuevos (IPCV, BEC, ...)
***************************************************************/
   FUNCTION f_aportacion(
      ptablas IN VARCHAR2,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pfefecto IN DATE,
      pnmovimi IN NUMBER,
      cgarant IN NUMBER,
      psproces IN NUMBER,
      pnmovima IN NUMBER,
      picapital IN NUMBER)
      RETURN NUMBER IS
      v_capital      NUMBER;
      v_pipc         NUMBER;
      v_prevali      NUMBER;
-- JLB - I - BUG 18423 COjo la moneda del producto
      vmoneda        monedas.cmoneda%TYPE;
-- JLB -F - BUG 18423 COjo la moneda del producto
   BEGIN
      IF ptablas = 'EST' THEN
         -- Bug 9685 - APD - 17/04/2009 - en lugar de coger la acticad de la tabla seguros, llamar a la función pac_seguros.ff_get_actividad
         SELECT NVL(icapital, 0)
           INTO v_capital
           FROM tmp_garancar t, estseguros e
          WHERE t.sseguro = psseguro
            AND e.sseguro = t.sseguro
            AND sproces = psproces
            AND t.nriesgo = pnriesgo
            AND t.nmovi_ant = pnmovimi
            AND f_pargaranpro_v(e.cramo, e.cmodali, e.ctipseg, e.ccolect,
                                pac_seguros.ff_get_actividad(psseguro, pnriesgo, 'EST'),
                                t.cgarant, 'TIPO') = 3;   -- PRIMA AHORRO
         -- Bug 9685 - APD - 17/04/2009 - Fin
--         DBMS_OUTPUT.put_line('aportaciones bien');
      ELSIF ptablas = 'SOL' THEN
         -- Bug 9685 - APD - 17/04/2009 - en lugar de coger la acticad de la tabla seguros, llamar a la función pac_seguros.ff_get_actividad
         SELECT NVL(icapital, 0)
           INTO v_capital
           FROM tmp_garancar t, solseguros e
          WHERE t.sseguro = psseguro
            AND e.ssolicit = t.sseguro
            AND sproces = psproces
            AND t.nriesgo = pnriesgo
            AND t.nmovi_ant = pnmovimi
            AND f_pargaranpro_v(e.cramo, e.cmodali, e.ctipseg, e.ccolect,
                                pac_seguros.ff_get_actividad(psseguro, pnriesgo, 'SOL'),
                                t.cgarant, 'TIPO') = 3;   -- PRIMA AHORRO
      -- Bug 9685 - APD - 17/04/2009 - Fin
      ELSE
         -- BUG 0021638 - 08/03/2012 - JMF
         v_pipc := f_ipc(0, TO_CHAR(pfefecto, 'yyyy'), 1, 1);

--P_CONTROL_ERROR(NULL, 'APOR', 'V_PIPC ='||V_PIPC);
     -- Bug 9685 - APD - 17/04/2009 - en lugar de coger la acticad de la tabla seguros, llamar a la función pac_seguros.ff_get_actividad
         SELECT NVL(icapital, 0),
                DECODE(s.crevali,
                       2, s.prevali,
                       5, DECODE(ptablas, 'CAR', v_pipc, 0),   --v_pipc,
                       0)
-- JLB - I - BUG 18423 COjo la moneda del producto
         ,
                pac_monedas.f_moneda_producto(s.sproduc)
-- JLB - F - BUG 18423 COjo la moneda del producto
         INTO   v_capital,
                v_prevali,
-- JLB - I - BUG 18423 COjo la moneda del producto
                vmoneda
-- JLB - F - BUG 18423 COjo la moneda del producto
         FROM   garanseg g, seguros s
          WHERE g.sseguro = psseguro
            AND s.sseguro = g.sseguro
            AND g.nriesgo = pnriesgo
            AND g.nmovimi = pnmovimi
            AND f_pargaranpro_v(s.cramo, s.cmodali, s.ctipseg, s.ccolect,
                                pac_seguros.ff_get_actividad(psseguro, pnriesgo), g.cgarant,
                                'TIPO') = 3;   -- PRIMA AHORRO

         -- Bug 9685 - APD - 17/04/2009 - Fin
         IF ptablas = 'CAR'
            AND v_prevali IS NOT NULL
            AND v_prevali <> 0 THEN
            v_capital := f_round(v_capital *(1 + v_prevali / 100),
-- JLB - I - BUG 18423 COjo la moneda del producto
            --1
                                 vmoneda
-- JLB - F - BUG 18423 COjo la moneda del producto
                        );
         END IF;
      END IF;

      RETURN v_capital;
   EXCEPTION
      WHEN OTHERS THEN
--         DBMS_OUTPUT.put_line('error aportacion ' || SQLERRM);
         RETURN 0;
   END f_aportacion;

   FUNCTION f_aportextr(
      ptablas IN VARCHAR2,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pfefecto IN DATE,
      pnmovimi IN NUMBER,
      cgarant IN NUMBER,
      psproces IN NUMBER,
      pnmovima IN NUMBER,
      picapital IN NUMBER)
      RETURN NUMBER IS
      v_capital      NUMBER;
   BEGIN
      IF ptablas = 'EST' THEN
         BEGIN
            -- Bug 9685 - APD - 17/04/2009 - en lugar de coger la acticad de la tabla seguros, llamar a la función pac_seguros.ff_get_actividad
            SELECT NVL(icapital, 0)
              INTO v_capital
              FROM tmp_garancar t, estseguros e
             WHERE t.sseguro = psseguro
               AND e.sseguro = t.sseguro
               AND sproces = psproces
               AND t.nriesgo = pnriesgo
               AND t.nmovi_ant = pnmovimi
               AND f_pargaranpro_v(e.cramo, e.cmodali, e.ctipseg, e.ccolect,
                                   pac_seguros.ff_get_actividad(psseguro, pnriesgo, 'EST'),
                                   t.cgarant, 'TIPO') = 4;   -- PRIMA EXTRAORDINARIA
         -- Bug 9685 - APD - 17/04/2009 - Fin
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               -- Bug 9685 - APD - 17/04/2009 - en lugar de coger la acticad de la tabla seguros, llamar a la función pac_seguros.ff_get_actividad
               SELECT NVL(icapital, 0)
                 INTO v_capital
                 FROM tmp_garancar t, estseguros e
                WHERE t.sseguro = psseguro
                  AND e.sseguro = t.sseguro
                  AND sproces = psproces
                  AND t.nriesgo = pnriesgo
                  AND t.nmovi_ant = pnmovimi
                  AND f_pargaranpro_v(e.cramo, e.cmodali, e.ctipseg, e.ccolect,
                                      pac_seguros.ff_get_actividad(psseguro, pnriesgo, 'EST'),
                                      t.cgarant, 'TIPO') = 3;   -- PRIMA EXTRAORDINARIA
         -- Bug 9685 - APD - 17/04/2009 - Fin
         END;
      ELSIF ptablas = 'SOL' THEN
         BEGIN
            -- Bug 9685 - APD - 17/04/2009 - en lugar de coger la acticad de la tabla seguros, llamar a la función pac_seguros.ff_get_actividad
            SELECT NVL(icapital, 0)
              INTO v_capital
              FROM tmp_garancar t, solseguros e
             WHERE t.sseguro = psseguro
               AND e.ssolicit = t.sseguro
               AND sproces = psproces
               AND t.nriesgo = pnriesgo
               AND t.nmovi_ant = pnmovimi
               AND f_pargaranpro_v(e.cramo, e.cmodali, e.ctipseg, e.ccolect,
                                   pac_seguros.ff_get_actividad(psseguro, pnriesgo, 'SOL'),
                                   t.cgarant, 'TIPO') = 4;   -- PRIMA EXTRAORDINARIA
         -- Bug 9685 - APD - 17/04/2009 - Fin
         EXCEPTION
            WHEN OTHERS THEN
               -- Bug 9685 - APD - 17/04/2009 - en lugar de coger la acticad de la tabla seguros, llamar a la función pac_seguros.ff_get_actividad
               SELECT NVL(icapital, 0)
                 INTO v_capital
                 FROM tmp_garancar t, solseguros e
                WHERE t.sseguro = psseguro
                  AND e.ssolicit = t.sseguro
                  AND sproces = psproces
                  AND t.nriesgo = pnriesgo
                  AND t.nmovi_ant = pnmovimi
                  AND f_pargaranpro_v(e.cramo, e.cmodali, e.ctipseg, e.ccolect,
                                      pac_seguros.ff_get_actividad(psseguro, pnriesgo, 'SOL'),
                                      t.cgarant, 'TIPO') = 3;   -- PRIMA AHORRO
         -- Bug 9685 - APD - 17/04/2009 - Fin
         END;
      ELSE
         BEGIN
            -- Bug 9685 - APD - 17/04/2009 - en lugar de coger la acticad de la tabla seguros, llamar a la función pac_seguros.ff_get_actividad
            SELECT NVL(icapital, 0)
              INTO v_capital
              FROM garanseg g, seguros s
             WHERE g.sseguro = psseguro
               AND s.sseguro = g.sseguro
               AND g.nriesgo = pnriesgo
               AND g.nmovimi = pnmovimi
               AND f_pargaranpro_v(s.cramo, s.cmodali, s.ctipseg, s.ccolect,
                                   pac_seguros.ff_get_actividad(psseguro, pnriesgo), g.cgarant,
                                   'TIPO') = 4;   -- PRIMA EXTRAORDINARIA
         -- Bug 9685 - APD - 17/04/2009 - Fin
         EXCEPTION
            WHEN OTHERS THEN
               -- Bug 9685 - APD - 17/04/2009 - en lugar de coger la acticad de la tabla seguros, llamar a la función pac_seguros.ff_get_actividad
               SELECT NVL(icapital, 0)
                 INTO v_capital
                 FROM garanseg g, seguros s
                WHERE g.sseguro = psseguro
                  AND s.sseguro = g.sseguro
                  AND g.nriesgo = pnriesgo
                  AND g.nmovimi = pnmovimi
                  AND f_pargaranpro_v(s.cramo, s.cmodali, s.ctipseg, s.ccolect,
                                      pac_seguros.ff_get_actividad(psseguro, pnriesgo),
                                      g.cgarant, 'TIPO') = 3;   -- PRIMA AHORRO
         -- Bug 9685 - APD - 17/04/2009 - Fin
         END;
      END IF;

      RETURN v_capital;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 0;
   END f_aportextr;

   FUNCTION f_irevali(
      ptablas IN VARCHAR2,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pfefecto IN DATE,
      pnmovimi IN NUMBER,
      cgarant IN NUMBER,
      psproces IN NUMBER,
      pnmovima IN NUMBER,
      picapital IN NUMBER)
      RETURN NUMBER IS
      v_irevali      NUMBER;
      pgarant        NUMBER;
   BEGIN
      pgarant := cgarant;

      BEGIN
         IF cgarant IS NOT NULL THEN
            IF ptablas = 'EST' THEN
               SELECT DECODE(crevali, 1, DECODE(prevali, NULL, irevali, 0, irevali, 0), 0)
                 INTO v_irevali
                 FROM estgaranseg
                WHERE sseguro = psseguro
                  AND nmovimi = pnmovimi
                  AND nriesgo = pnriesgo
                  AND cgarant = pgarant;
            ELSIF ptablas = 'SOL' THEN
               SELECT DECODE(crevali, 1, DECODE(prevali, NULL, irevali, 0, irevali, 0), 0)
                 INTO v_irevali
                 FROM solgaranseg
                WHERE ssolicit = psseguro
                  AND nriesgo = pnriesgo
                  AND cgarant = pgarant;
            ELSE
               SELECT DECODE(crevali, 1, DECODE(prevali, NULL, irevali, 0, irevali, 0), 0)
                 INTO v_irevali
                 FROM garanseg
                WHERE sseguro = psseguro
                  AND nmovimi = pnmovimi
                  AND nriesgo = pnriesgo
                  AND cgarant = pgarant;
            END IF;
         END IF;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            NULL;   -- Si no se encuentran, buscamos a nivel de producto
      END;

      IF v_irevali IS NOT NULL THEN
         RETURN v_irevali;
      END IF;

      IF ptablas = 'EST' THEN
         SELECT DECODE(crevali,
                       1, DECODE(prevali,
                                 NULL, irevali,
                                 0, irevali,
                                 e.iprianu * prevali / 100),
                       0)
           INTO v_irevali
           FROM estseguros e
          WHERE e.sseguro = psseguro;
      ELSIF ptablas = 'SOL' THEN
         SELECT DECODE(crevali, 1, DECODE(prevali, NULL, irevali, 0, irevali, 0),
                       -- IPRIANU*PREVALI/100),
                       0)
           INTO v_irevali
           FROM solseguros e
          WHERE e.ssolicit = psseguro;
      ELSE
         SELECT DECODE(g.crevali,
                       1, DECODE(g.prevali,
                                 NULL, g.irevali,
                                 0, g.irevali,
                                 g.iprianu * g.prevali / 100),
                       0)
           INTO v_irevali
           FROM seguros g
          WHERE g.sseguro = psseguro;
      END IF;

      RETURN v_irevali;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN 1;   -- No hay contratada garantía de RC
      WHEN TOO_MANY_ROWS THEN
         RETURN 0;   -- Están cotratadas las dos garantías de RC
      WHEN OTHERS THEN
         RETURN -1;
   END f_irevali;

   FUNCTION f_prevali(
      ptablas IN VARCHAR2,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pfefecto IN DATE,
      pnmovimi IN NUMBER,
      cgarant IN NUMBER,
      psproces IN NUMBER,
      pnmovima IN NUMBER,
      picapital IN NUMBER)
      RETURN NUMBER IS
      v_prevali      NUMBER;
      v_pipc         NUMBER;
      pgarant        NUMBER;
   BEGIN
      -- BUG 0021638 - 08/03/2012 - JMF
      v_pipc := f_ipc(0, TO_CHAR(pfefecto, 'yyyy'), 1, 1);
      pgarant := cgarant;

      BEGIN
         IF cgarant IS NOT NULL THEN   -- buscamos a nivel de garantía
            IF ptablas = 'EST' THEN
               SELECT DECODE(crevali, 2, prevali, 5, 0,   --v_pipc,
                             0)
                 INTO v_prevali
                 FROM estgaranseg
                WHERE sseguro = psseguro
                  AND nmovimi = pnmovimi
                  AND nriesgo = pnriesgo
                  AND cgarant = pgarant;
            ELSIF ptablas = 'SOL' THEN
               SELECT DECODE(crevali, 2, prevali, 5, 0,   --v_pipc,
                             0)
                 INTO v_prevali
                 FROM solgaranseg
                WHERE ssolicit = psseguro
                  AND nriesgo = pnriesgo
                  AND cgarant = pgarant;
            ELSE
               SELECT DECODE(crevali, 2, prevali, 5, 0,   --v_pipc,
                             0)
                 INTO v_prevali
                 FROM garanseg
                WHERE sseguro = psseguro
                  AND nmovimi = pnmovimi
                  AND nriesgo = pnriesgo
                  AND cgarant = pgarant;
            END IF;
         END IF;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            NULL;   -- Si no se encuentran, buscamos a nivel de producto
      END;

      IF v_prevali IS NOT NULL THEN
         RETURN v_prevali;
      END IF;

      IF ptablas = 'EST' THEN
         SELECT DECODE(t.crevali, 2, t.prevali, 5, 0,   --v_pipc,
                       0)
           INTO v_prevali
           FROM estseguros t
          WHERE t.sseguro = psseguro;
      ELSIF ptablas = 'SOL' THEN
         SELECT DECODE(t.crevali, 2, t.prevali, 5, 0,   --v_pipc,
                       0)
           INTO v_prevali
           FROM solseguros t
          WHERE t.ssolicit = psseguro;
      ELSE
         SELECT DECODE(g.crevali, 2, g.prevali, 5, 0,   --v_pipc,
                       0)
           INTO v_prevali
           FROM seguros g
          WHERE g.sseguro = psseguro;
      END IF;

      RETURN v_prevali;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN 1;   -- No hay contratada garantía de RC
      WHEN TOO_MANY_ROWS THEN
         RETURN 0;   -- Están cotratadas las dos garantías de RC
      WHEN OTHERS THEN
         RETURN -1;
   END f_prevali;

   FUNCTION f_frenova(
      ptablas IN VARCHAR2,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pfefecto IN DATE,
      pnmovimi IN NUMBER,
      cgarant IN NUMBER,
      psproces IN NUMBER,
      pnmovima IN NUMBER,
      picapital IN NUMBER)
      RETURN NUMBER IS
      v_frenova      NUMBER;
      v_ctipefe      NUMBER;
      fecha_aux      DATE;
      v_nrenova      NUMBER;
      v_fefecto      DATE;
      v_fcaranu      DATE;
      dd             VARCHAR2(2);
      ddmm           VARCHAR2(4);
      v_fecha        DATE;
   BEGIN
      IF ptablas = 'EST' THEN
         BEGIN
            SELECT ctipefe, e.nrenova, e.fefecto, e.fcaranu
              INTO v_ctipefe, v_nrenova, v_fefecto, v_fcaranu
              FROM productos p, estseguros e
             WHERE e.sseguro = psseguro
               AND p.sproduc = e.sproduc;
         EXCEPTION
            WHEN OTHERS THEN
               v_ctipefe := NULL;
         END;
      ELSIF ptablas = 'SOL' THEN
         BEGIN
            SELECT ctipefe, e.falta, e.fcaranu
              INTO v_ctipefe, v_fefecto, v_fcaranu
              FROM productos p, solseguros e
             WHERE e.ssolicit = psseguro
               AND p.cramo = e.cramo
               AND p.cmodali = e.cmodali
               AND p.ctipseg = e.ctipseg
               AND p.ccolect = e.ccolect;
         EXCEPTION
            WHEN OTHERS THEN
               v_ctipefe := NULL;
         END;

         IF v_ctipefe = 2 THEN
            IF TO_CHAR(v_fefecto, 'dd') = 1 THEN
               v_fecha := v_fefecto;
            ELSE
               v_fecha := ADD_MONTHS(v_fefecto, 1);
            END IF;

            v_nrenova := TO_CHAR(v_fecha, 'mm') || '01';
         ELSIF v_ctipefe = 3 THEN
            v_nrenova := TO_CHAR(v_fefecto, 'mm') || '01';
         ELSE
            v_nrenova := TO_CHAR(v_fefecto, 'mmdd');
         END IF;
      ELSE
         BEGIN
            SELECT ctipefe, e.nrenova, e.fefecto, e.fcaranu
              INTO v_ctipefe, v_nrenova, v_fefecto, v_fcaranu
              FROM productos p, seguros e
             WHERE e.sseguro = psseguro
               AND p.sproduc = e.sproduc;
         EXCEPTION
            WHEN OTHERS THEN
               v_ctipefe := NULL;
         END;
      END IF;

      IF v_fcaranu IS NOT NULL THEN
--         DBMS_OUTPUT.put_line(' v_fcaranu is not null');
--         DBMS_OUTPUT.put_line(' tablas =' || ptablas);
         IF ptablas = 'CAR' THEN
--            DBMS_OUTPUT.put_line(' tablas =' || ptablas);
            v_frenova := TO_CHAR(ADD_MONTHS(v_fcaranu, 12), 'yyyymmdd');
         ELSE
            v_frenova := TO_CHAR(v_fcaranu, 'yyyymmdd');
         END IF;
--         DBMS_OUTPUT.put_line('v_frenova =' || v_frenova);
      ELSE
         dd := SUBSTR(LPAD(v_nrenova, 4, 0), 3, 2);
         ddmm := dd || SUBSTR(LPAD(v_nrenova, 4, 0), 1, 2);

         IF v_ctipefe = 2 THEN   -- a día 1/mes por exceso
            fecha_aux := ADD_MONTHS(v_fefecto, 13);
            v_frenova := TO_CHAR(TO_DATE(ddmm || TO_CHAR(fecha_aux, 'YYYY'), 'DDMMYYYY'),
                                 'yyyymmdd');
         ELSIF v_ctipefe = 3 THEN   -- A DIA 1/MES EFECTO
            fecha_aux := ADD_MONTHS(v_fefecto, 12);
            v_frenova := TO_CHAR(TO_DATE(ddmm || TO_CHAR(fecha_aux, 'YYYY'), 'DDMMYYYY'),
                                 'yyyymmdd');
         ELSE
            v_frenova := TO_CHAR(ADD_MONTHS(v_fefecto, 12), 'yyyymmdd');
         END IF;
--         DBMS_OUTPUT.put_line(' primer lfcanua =' || v_frenova);
      END IF;

      RETURN v_frenova;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN 1;   -- No hay contratada garantía de RC
      WHEN TOO_MANY_ROWS THEN
         RETURN 0;   -- Están cotratadas las dos garantías de RC
      WHEN OTHERS THEN
         RETURN -1;
   END f_frenova;

   FUNCTION f_ndiaspro(
      ptablas IN VARCHAR2,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pfefecto IN DATE,
      pnmovimi IN NUMBER,
      cgarant IN NUMBER,
      psproces IN NUMBER,
      pnmovima IN NUMBER,
      picapital IN NUMBER)
      RETURN NUMBER IS
      v_ndiaspro     NUMBER;
   BEGIN
      IF ptablas = 'EST' THEN
         BEGIN
            SELECT ndiaspro
              INTO v_ndiaspro
              FROM productos p, estseguros e
             WHERE e.sseguro = psseguro
               AND p.sproduc = e.sproduc;
         EXCEPTION
            WHEN OTHERS THEN
               v_ndiaspro := NULL;
         END;
      ELSIF ptablas = 'SOL' THEN
         BEGIN
            SELECT ndiaspro
              INTO v_ndiaspro
              FROM productos p, solseguros e
             WHERE e.ssolicit = psseguro
               AND p.cramo = e.cramo
               AND p.cmodali = e.cmodali
               AND p.ctipseg = e.ctipseg
               AND p.ccolect = e.ccolect;
         EXCEPTION
            WHEN OTHERS THEN
               v_ndiaspro := NULL;
         END;
      ELSE
         BEGIN
            SELECT ndiaspro
              INTO v_ndiaspro
              FROM productos p, seguros e
             WHERE e.sseguro = psseguro
               AND p.sproduc = e.sproduc;
         EXCEPTION
            WHEN OTHERS THEN
               v_ndiaspro := NULL;
         END;
      END IF;

      RETURN v_ndiaspro;
   END f_ndiaspro;

   FUNCTION f_psuplem(
      ptablas IN VARCHAR2,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pfefecto IN DATE,
      pnmovimi IN NUMBER,
      cgarant IN NUMBER,
      psproces IN NUMBER,
      pnmovima IN NUMBER,
      picapital IN NUMBER)
      RETURN NUMBER IS
      v_nmovimi      NUMBER;
      psuplem        NUMBER;
   BEGIN
      IF ptablas = 'EST' THEN
         BEGIN
            SELECT NVL(MAX(nmovimi), 1)
              INTO v_nmovimi
              FROM estseguros e, movseguro m
             WHERE e.sseguro = psseguro
               AND e.ssegpol = m.sseguro;
         EXCEPTION
            WHEN OTHERS THEN
               v_nmovimi := NULL;
         END;

         IF v_nmovimi = 1 THEN
            psuplem := 0;   -- nueva producción
         ELSE
            psuplem := 2;   --suplemento (no movimiento de ctaseguro)
         END IF;
      ELSIF ptablas = 'SOL' THEN
         psuplem := 0;
      ELSE
         psuplem := 2;
      END IF;

      RETURN psuplem;
   END;

   FUNCTION f_prevali_estimat(
      ptablas IN VARCHAR2,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pfefecto IN DATE,
      pnmovimi IN NUMBER,
      cgarant IN NUMBER,
      psproces IN NUMBER,
      pnmovima IN NUMBER,
      picapital IN NUMBER)
      RETURN NUMBER IS
      v_prevali      NUMBER;
      v_pipc         NUMBER;
   BEGIN
      -- BUG 0021638 - 08/03/2012 - JMF
      v_pipc := f_ipc(0, TO_CHAR(pfefecto, 'yyyy'), 1, 1);

      IF ptablas = 'EST' THEN
         SELECT DECODE(t.crevali, 2, t.prevali, 5, 0,   --v_pipc,
                       0)
           INTO v_prevali
           FROM estseguros t
          WHERE t.sseguro = psseguro;
      ELSIF ptablas = 'SOL' THEN
         SELECT DECODE(t.crevali, 2, t.prevali, 5, v_pipc, 0)
           INTO v_prevali
           FROM solseguros t
          WHERE t.ssolicit = psseguro;
      ELSE
         SELECT DECODE(g.crevali, 2, g.prevali, 5, v_pipc, 0)
           INTO v_prevali
           FROM seguros g
          WHERE g.sseguro = psseguro;
      END IF;

      RETURN v_prevali;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN 1;   -- No hay contratada garantía de RC
      WHEN TOO_MANY_ROWS THEN
         RETURN 0;   -- Están cotratadas las dos garantías de RC
      WHEN OTHERS THEN
         RETURN -1;
   END f_prevali_estimat;

   FUNCTION f_edad_riesgo(
      ptablas IN VARCHAR2,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pfefecto IN DATE,
      pnmovimi IN NUMBER,
      cgarant IN NUMBER,
      psproces IN NUMBER,
      pnmovima IN NUMBER,
      picapital IN NUMBER)
      RETURN NUMBER IS
      v_fnacimi      DATE;
      v_ssegpol      NUMBER;
      v_fefecto      DATE;
      v_fecha        DATE;
      v_edad         NUMBER;
      v_fcaranu      DATE;
   BEGIN
      IF ptablas = 'EST' THEN
         -- Estamos en nueva produccion o suplementos
         BEGIN
            --Bug10612 - 07/07/2009 - DCT (canviar vista personas)
            SELECT p.fnacimi, s.ssegpol, s.fefecto
              INTO v_fnacimi, v_ssegpol, v_fefecto
              FROM estriesgos r, estper_personas p, estseguros s
             WHERE r.sseguro = psseguro
               AND s.sseguro = r.sseguro
               AND r.sperson = p.sperson
               AND r.nriesgo = pnriesgo;
         /*SELECT fnacimi, ssegpol, s.fefecto
          INTO v_fnacimi, v_ssegpol, v_fefecto
          FROM estriesgos r, personas p, estseguros s
         WHERE r.sseguro = psseguro
           AND s.sseguro = r.sseguro
           AND r.sperson = p.sperson
           AND r.nriesgo = pnriesgo;*/

         --FI Bug10612 - 07/07/2009 - DCT (canviar vista personas)
         EXCEPTION
            WHEN OTHERS THEN
               RETURN NULL;
         END;

         BEGIN
            SELECT MAX(fefecto)
              INTO v_fecha
              FROM movseguro
             WHERE sseguro = v_ssegpol
               AND cmovseg IN(0, 2);

            IF v_fecha IS NULL THEN
               v_fecha := v_fefecto;
            END IF;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               v_fecha := v_fefecto;
         END;

         v_edad := TRUNC(MONTHS_BETWEEN(v_fecha,(ADD_MONTHS(v_fnacimi, -6) + 1)) / 12);
      ELSIF ptablas = 'SOL' THEN
         -- Estamos en nueva produccion o suplementos
         BEGIN
            SELECT fnacimi, s.falta
              INTO v_fnacimi, v_fefecto
              FROM solriesgos r, solseguros s
             WHERE r.ssolicit = psseguro
               AND s.ssolicit = r.ssolicit
               AND r.nriesgo = pnriesgo;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN NULL;
         END;

         v_edad := TRUNC(MONTHS_BETWEEN(v_fefecto,(ADD_MONTHS(v_fnacimi, -6) + 1)) / 12);
      ELSE
         -- Estamos cartera
         BEGIN
            --Bug10612 - 07/07/2009 - DCT (canviar vista personas)
            SELECT p.fnacimi, s.fefecto, s.fcaranu
              INTO v_fnacimi, v_fefecto, v_fcaranu
              FROM riesgos r, per_personas p, seguros s
             WHERE r.sseguro = psseguro
               AND s.sseguro = r.sseguro
               AND r.sperson = p.sperson
               AND r.nriesgo = pnriesgo;
         /*SELECT fnacimi, s.fefecto, s.fcaranu
          INTO v_fnacimi, v_fefecto, v_fcaranu
          FROM riesgos r, personas p, seguros s
         WHERE r.sseguro = psseguro
           AND s.sseguro = r.sseguro
           AND r.sperson = p.sperson
           AND r.nriesgo = pnriesgo;*/

         --FI Bug10612 - 07/07/2009 - DCT (canviar vista personas)
         EXCEPTION
            WHEN OTHERS THEN
               RETURN NULL;
         END;

         IF pfefecto = v_fcaranu THEN
            -- si es cartera utilizamos la fecha de efecto (que será la fcaranu de la póliza)
            v_fecha := pfefecto;
         ELSE
            BEGIN
               SELECT MAX(fefecto)
                 INTO v_fecha
                 FROM movseguro
                WHERE sseguro = psseguro
                  AND cmovseg IN(0, 2);

               IF v_fecha IS NULL THEN
                  v_fecha := v_fefecto;
               END IF;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  v_fecha := v_fefecto;
            END;
         END IF;

         v_edad := TRUNC(MONTHS_BETWEEN(v_fecha,(ADD_MONTHS(v_fnacimi, -6) + 1)) / 12);
      END IF;

      RETURN v_edad;
   EXCEPTION
      WHEN OTHERS THEN
--  p_control_error(null, 'preg', 'error');
         RETURN 22222;
   END f_edad_riesgo;
END pac_albsgt_mv;

/

  GRANT EXECUTE ON "AXIS"."PAC_ALBSGT_MV" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_ALBSGT_MV" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_ALBSGT_MV" TO "PROGRAMADORESCSI";
