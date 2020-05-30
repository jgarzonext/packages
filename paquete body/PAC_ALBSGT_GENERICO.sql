--------------------------------------------------------
--  DDL for Package Body PAC_ALBSGT_GENERICO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_ALBSGT_GENERICO" IS
/******************************************************************************
   NOMBRE:       PAC_ALBSGT_snv
   PROPÓSITO:  Cuerpo del paquete de las funciones para
                el cáculo de las preguntas relacionadas con
                productos de SNV

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        ??/??/????   ???               1. Creación del package.
   1.1        27/04/2009   JRH               2. 0009907: CRE069 - Inclusión de preguntas de comisión y gastos en Productos de baja .
   2.0        25/02/2009   JGR               3. Añadir función f_gastos_lista
   3.0        15/05/2009   JRH               3. 0010035: CRE - Inclusión de preguntas de gastos en producto Crèdit Vida Capital
   4.0        25/06/2009   RSC               4. 0010539: CRE - Pólizas con error en el cálculo de la edad
   5.0        09/07/2009   DCT               5. BUG 0010612: CRE - Error en la generació de pagaments automàtics.
                                                Canviar vista personas por tablas personas y añadir filtro de visión de agente.
   6.0        10/08/2009   JRH               6. 0010891: CRE - CREDIT BAIXA: Càlcul de les comissions
   7.0        01/09/2009   JRB               7. Añadir funcion f_sobreprima_descuento_80
 2010.1       10/02/2010   MRB             2010.1 Funció f_tipus_subscripció
 2010.1       16/02/2010   MRB             2010.1 Funcio f_renovaciones_fetes
   8.0        20/04/2010   JGR               8. 0014186: CRE998 - Modificaciones y resolución de incidencia en CV Privats
   9.0        14/06/2010   JGR               9. 0014186: CRE998 - Modificaciones ... (quitar control edad 0-55 años)
******************************************************************************/
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
      num_err        NUMBER;
      -- Bug 10539 - RSC - 25/06/2009 - Pólizas con error en el cálculo de la edad
      n_retafrac     NUMBER(1);
      v_cursor       NUMBER;
      ss             VARCHAR2(3000);
      funcion        VARCHAR2(40);
      v_filas        NUMBER;
      p_sproduc      seguros.sproduc%TYPE;
   -- Fin Bug 10539
   BEGIN
      IF ptablas = 'EST' THEN
         -- Estamos en nueva produccion o suplementos
         -- Es la fecha efecto del riesgo, tanto para nueva producción como para suplementos
         BEGIN
            -- Bug 11664 - 29/10/2009 - RSC - 0011664: CRE - CV FAMILIAR 10 (10.2) Diferències entre la tarificació del suplement a data de renovació i la renovació.
            -- Añadimos: , s.fcaranu
            SELECT fnacimi, ssegpol, r.fefecto, s.fcaranu
              INTO v_fnacimi, v_ssegpol, v_fefecto, v_fcaranu
              FROM estriesgos r, estper_personas p, estseguros s
             WHERE r.sseguro = psseguro
               AND s.sseguro = r.sseguro
               AND r.sperson = p.sperson
               AND r.nriesgo = pnriesgo;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN NULL;
         END;

         -- Bug 11664 - 29/10/2009 - RSC - 0011664: CRE - CV FAMILIAR 10 (10.2) Diferències entre la tarificació del suplement a data de renovació i la renovació.
         IF pfefecto = v_fcaranu THEN
            v_fecha := pfefecto;
         ELSE
            -- Fin Bug 11664
            BEGIN
               SELECT MAX(fefecto)
                 INTO v_fecha
                 FROM movseguro
                WHERE sseguro = v_ssegpol
                  AND cmovseg = 2;

               IF (v_fecha IS NULL)
                  OR(v_fecha < v_fefecto) THEN
                  v_fecha := v_fefecto;
               END IF;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  v_fecha := v_fefecto;
            END;
         -- Bug 11664
         END IF;

         -- Fin Bug 11664
         num_err := f_difdata(v_fnacimi, v_fecha, 2, 1, v_edad);
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

         num_err := f_difdata(v_fnacimi, v_fefecto, 2, 1, v_edad);
      ELSE
         -- Bug 10539 - RSC - 25/06/2009 - Pólizas con error en el cálculo de la edad
         SELECT sproduc
           INTO p_sproduc
           FROM seguros
          WHERE sseguro = psseguro;

         -- Fin Bug 10539

         -- Estamos cartera
         BEGIN
            --Bug10612 - 08/07/2009 - DCT (canviar vista personas)
            SELECT p.fnacimi, r.fefecto, s.fcaranu
              INTO v_fnacimi, v_fefecto, v_fcaranu
              FROM riesgos r, per_personas p, seguros s
             WHERE r.sseguro = psseguro
               AND s.sseguro = r.sseguro
               AND r.sperson = p.sperson
               AND r.nriesgo = pnriesgo;
         /*SELECT fnacimi, r.fefecto, s.fcaranu
           INTO v_fnacimi, v_fefecto, v_fcaranu
           FROM riesgos r, personas p, seguros s
          WHERE r.sseguro = psseguro
            AND s.sseguro = r.sseguro
            AND r.sperson = p.sperson
            AND r.nriesgo = pnriesgo;*/

         --Bug10612 - 08/07/2009 - DCT (canviar vista personas)
         EXCEPTION
            WHEN OTHERS THEN
               RETURN NULL;
         END;

         -- Bug 10539 - RSC - 25/06/2009 - Pólizas con error en el cálculo de la edad
         IF NVL(f_parproductos_v(p_sproduc, 'FRACCIONARIO'), 0) = 1 THEN
            SELECT MAX(tvalpar)
              INTO funcion
              FROM detparpro
             WHERE cparpro = 'F_PRFRACCIONARIAS'
               AND cidioma = 2
               AND cvalpar = (SELECT cvalpar
                                FROM parproductos
                               WHERE sproduc = p_sproduc
                                 AND cparpro = 'F_PRFRACCIONARIAS');

            IF funcion IS NOT NULL THEN
               ss := 'begin :n_retafrac := ' || funcion || '; end;';

               IF DBMS_SQL.is_open(v_cursor) THEN
                  DBMS_SQL.close_cursor(v_cursor);
               END IF;

               v_cursor := DBMS_SQL.open_cursor;
               DBMS_SQL.parse(v_cursor, ss, DBMS_SQL.native);

               IF INSTR(ss, ':psseguro') > 0 THEN
                  DBMS_SQL.bind_variable(v_cursor, ':psseguro', psseguro);
               END IF;

               IF INSTR(ss, ':pfecha') > 0 THEN
                  DBMS_SQL.bind_variable(v_cursor, ':pfecha', pfefecto);
               END IF;

               IF INSTR(ss, ':n_retafrac') > 0 THEN
                  DBMS_SQL.bind_variable(v_cursor, ':n_retafrac', num_err);
               END IF;

               v_filas := DBMS_SQL.EXECUTE(v_cursor);
               DBMS_SQL.variable_value(v_cursor, 'n_retafrac', n_retafrac);

               IF DBMS_SQL.is_open(v_cursor) THEN
                  DBMS_SQL.close_cursor(v_cursor);
               END IF;
            END IF;
         END IF;

         -- Fin Bug 10539

         -- Bug 10539 - RSC - 25/06/2009 - Pólizas con error en el cálculo de la edad
         -- Añadimos: AND n_retafrac IS NULL) OR n_retafrac = 1
         IF (pfefecto = v_fcaranu
             AND n_retafrac IS NULL)
            OR n_retafrac = 1 THEN
            -- si es cartera utilizamos la fecha de efecto (que será la fcaranu de la póliza)
            v_fecha := pfefecto;
         ELSE
            BEGIN
               SELECT MAX(fefecto)
                 INTO v_fecha
                 FROM movseguro
                WHERE sseguro = psseguro
                  AND cmovseg = 2;

               IF (v_fecha IS NULL)
                  OR(v_fecha < v_fefecto) THEN
                  v_fecha := v_fefecto;
               END IF;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  v_fecha := v_fefecto;
            END;
         END IF;

         num_err := f_difdata(v_fnacimi, v_fecha, 2, 1, v_edad);
      --v_edad := TRUNC(MONTHS_BETWEEN(v_fecha, (ADD_MONTHS(v_fnacimi, -6) + 1)) / 12);
      END IF;

      RETURN v_edad;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 22222;
   END f_edad_riesgo;

   FUNCTION f_edad_alta(
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
      v_falta        DATE;
      v_edad         NUMBER;
      num_err        NUMBER;
   BEGIN
      IF ptablas = 'EST' THEN
         -- Estamos en nueva produccion o suplementos
         BEGIN
            SELECT fnacimi, ssegpol, s.fefecto, r.fefecto
              INTO v_fnacimi, v_ssegpol, v_fefecto, v_falta
              FROM estriesgos r, estper_personas p, estseguros s
             WHERE r.sseguro = psseguro
               AND s.sseguro = r.sseguro
               AND r.sperson = p.sperson
               AND r.nriesgo = pnriesgo;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN NULL;
         END;

         num_err := f_difdata(v_fnacimi, v_falta, 2, 1, v_edad);
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

         num_err := f_difdata(v_fnacimi, v_fefecto, 2, 1, v_edad);
      ELSE
         -- Estamos cartera
         BEGIN
            --Bug10612 - 08/07/2009 - DCT (canviar vista personas)
            SELECT p.fnacimi, s.fefecto, r.fefecto
              INTO v_fnacimi, v_fefecto, v_falta
              FROM riesgos r, per_personas p, seguros s
             WHERE r.sseguro = psseguro
               AND s.sseguro = r.sseguro
               AND r.sperson = p.sperson
               AND r.nriesgo = pnriesgo;
         /*SELECT fnacimi, s.fefecto, r.fefecto
          INTO v_fnacimi, v_fefecto, v_falta
          FROM riesgos r, personas p, seguros s
         WHERE r.sseguro = psseguro
           AND s.sseguro = r.sseguro
           AND r.sperson = p.sperson
           AND r.nriesgo = pnriesgo;*/

         --FI Bug10612 - 08/07/2009 - DCT (canviar vista personas)
         EXCEPTION
            WHEN OTHERS THEN
               RETURN NULL;
         END;

         num_err := f_difdata(v_fnacimi, v_falta, 2, 1, v_edad);
      --  v_edad := TRUNC(MONTHS_BETWEEN(v_falta, (ADD_MONTHS(v_fnacimi, -6) + 1)) / 12);
      END IF;

      RETURN v_edad;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 22222;
   END f_edad_alta;

   FUNCTION f_tiene_prestamo(
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
      v_crespue      NUMBER;
   BEGIN
      IF ptablas = 'EST' THEN
         -- Estamos en nueva produccion o suplementos
         BEGIN
            SELECT crespue
              INTO v_crespue
              FROM estpregunseg e, estseguros s
             WHERE e.sseguro = psseguro
               AND s.sseguro = e.sseguro
               AND e.nriesgo = pnriesgo
               AND e.nmovimi = pnmovimi
               AND cpregun = 4;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 0;
         END;

         IF v_crespue IS NOT NULL
            AND v_crespue <> 0 THEN
            RETURN 1;
         ELSE
            RETURN 0;
         END IF;
      ELSIF ptablas = 'SOL' THEN
         -- Estamos en SIMULACION
         BEGIN
            SELECT crespue
              INTO v_crespue
              FROM solpregunseg e, solseguros s
             WHERE e.ssolicit = psseguro
               AND s.ssolicit = e.ssolicit
               AND e.nriesgo = pnriesgo
               AND e.nmovimi = pnmovimi
               AND cpregun = 4;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 0;
         END;

         IF v_crespue IS NOT NULL
            AND v_crespue <> 0 THEN
            RETURN 1;
         ELSE
            RETURN 0;
         END IF;
      ELSE
         -- Estamos cartera
         BEGIN
            SELECT crespue
              INTO v_crespue
              FROM pregunseg e, seguros s
             WHERE e.sseguro = psseguro
               AND s.sseguro = e.sseguro
               AND e.nriesgo = pnriesgo
               AND e.nmovimi = pnmovimi
               AND cpregun = 4;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 0;
         END;

         IF v_crespue IS NOT NULL
            AND v_crespue <> 0 THEN
            RETURN 1;
         ELSE
            RETURN 0;
         END IF;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 22222;
   END f_tiene_prestamo;

   FUNCTION f_prueba_medica(
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
      v_crespue      NUMBER;
   BEGIN
      IF ptablas = 'EST' THEN
         -- Estamos en nueva produccion o suplementos
         BEGIN
            SELECT crespue
              INTO v_crespue
              FROM estpregunseg e, estseguros s
             WHERE e.sseguro = psseguro
               AND s.sseguro = e.sseguro
               AND e.nriesgo = pnriesgo
               AND e.nmovimi = pnmovimi
               AND cpregun = 2
               AND crespue <> 0;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 0;
         END;

         IF v_crespue IS NOT NULL
            AND v_crespue <> 0 THEN
            RETURN v_crespue;
         ELSE
            RETURN NULL;
         END IF;
      ELSIF ptablas = 'SOL' THEN
         -- Estamos en SIMULACION
         BEGIN
            SELECT crespue
              INTO v_crespue
              FROM solpregunseg e, solseguros s
             WHERE e.ssolicit = psseguro
               AND s.ssolicit = e.ssolicit
               AND e.nriesgo = pnriesgo
               AND e.nmovimi = pnmovimi
               AND cpregun = 2
               AND crespue <> 0;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 0;
         END;

         IF v_crespue IS NOT NULL
            AND v_crespue <> 0 THEN
            RETURN v_crespue;
         ELSE
            RETURN NULL;
         END IF;
      ELSE
         -- Estamos cartera
         BEGIN
            SELECT crespue
              INTO v_crespue
              FROM pregunseg e, seguros s
             WHERE e.sseguro = psseguro
               AND s.sseguro = e.sseguro
               AND e.nriesgo = pnriesgo
               AND e.nmovimi = pnmovimi
               AND cpregun = 2
               AND crespue <> 0;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 0;
         END;

         IF v_crespue IS NOT NULL
            AND v_crespue <> 0 THEN
            RETURN v_crespue;
         ELSE
            RETURN NULL;
         END IF;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 22222;
   END f_prueba_medica;

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
   BEGIN
      IF ptablas = 'EST' THEN
         SELECT NVL(icapital, 0)
           INTO v_capital
           FROM tmp_garancar t, estseguros e
          WHERE t.sseguro = psseguro
            AND e.sseguro = t.sseguro
            AND sproces = psproces
            AND t.nriesgo = pnriesgo
            AND t.nmovi_ant = pnmovimi
            AND f_pargaranpro_v(e.cramo, e.cmodali, e.ctipseg, e.ccolect, e.cactivi, t.cgarant,
                                'TIPO') = 3;   -- PRIMA AHORRO
      ELSIF ptablas = 'SOL' THEN
         SELECT NVL(icapital, 0)
           INTO v_capital
           FROM tmp_garancar t, solseguros e
          WHERE t.sseguro = psseguro
            AND e.ssolicit = t.sseguro
            AND sproces = psproces
            AND t.nriesgo = pnriesgo
            AND t.nmovi_ant = pnmovimi
            AND f_pargaranpro_v(e.cramo, e.cmodali, e.ctipseg, e.ccolect, e.cactivi, t.cgarant,
                                'TIPO') = 3;   -- PRIMA AHORRO
      ELSE
         BEGIN
            SELECT pipc
              INTO v_pipc
              FROM ipc
             WHERE nmes = 0
               AND nanyo = TO_CHAR(pfefecto, 'yyyy');
         EXCEPTION
            WHEN OTHERS THEN
               v_pipc := NULL;
         END;

         SELECT NVL(icapital, 0),
                DECODE(s.crevali,
                       2, s.prevali,
                       5, DECODE(ptablas, 'CAR', v_pipc, 0),   --v_pipc,
                       0)
           INTO v_capital,
                v_prevali
           FROM garanseg g, seguros s
          WHERE g.sseguro = psseguro
            AND s.sseguro = g.sseguro
            AND g.nriesgo = pnriesgo
            AND g.nmovimi = pnmovimi
            AND f_pargaranpro_v(s.cramo, s.cmodali, s.ctipseg, s.ccolect, s.cactivi, g.cgarant,
                                'TIPO') = 3;   -- PRIMA AHORRO

         IF ptablas = 'CAR'
            AND v_prevali IS NOT NULL
            AND v_prevali <> 0 THEN
            v_capital := f_round(v_capital *(1 + v_prevali / 100), 1);
         END IF;
      END IF;

      RETURN v_capital;
   EXCEPTION
      WHEN OTHERS THEN
         --DBMS_OUTPUT.put_line('error aportacion ' || SQLERRM);
         RETURN 0;
   END f_aportacion;

   FUNCTION f_primaeuroplazo(
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
      e              NUMBER;   -- Error Retorno funciones
      xxsesion       NUMBER;
      xsproduc       NUMBER;
      xcactivi       NUMBER;
      xporigen       NUMBER := 2;   -- 2 = tabla seguros (quan o passem --> 1 = EST)
      xxformula      VARCHAR2(2000);
      xxcodigo       VARCHAR2(30);
      xnduraci       NUMBER;
      xndurper       NUMBER;
      xsexo1         NUMBER;
      xfnacimi1      DATE;
      xsexo2         NUMBER;
      xfnacimi2      DATE;
      xinttec        NUMBER;
      xpgastos       NUMBER;
      val            NUMBER;
      csupervivencia NUMBER;   -- Capital de supervivencia sobre prima inicial
      ratioprima     NUMBER;
      prima_eur      NUMBER;
      prima_ibex35   NUMBER;
      ntraza         NUMBER := 0;
      xefectopol     DATE;
   BEGIN
      -- Capital de la prima inicial
      v_capital := f_aportacion(ptablas, psseguro, pnriesgo, pfefecto, pnmovimi, cgarant,
                                psproces, pnmovima, picapital);
      -- . Aqui llamar a FF_CAPGARAN_EUROPLAZO_16 con este capital
      ntraza := 2;

      SELECT sgt_sesiones.NEXTVAL
        INTO xxsesion
        FROM DUAL;

      IF ptablas = 'EST' THEN
         SELECT sproduc, cactivi, nduraci, fefecto
           INTO xsproduc, xcactivi, xnduraci, xefectopol
           FROM estseguros
          WHERE sseguro = psseguro;

         -- Buscar en ESTASEGURADOS
         BEGIN
            SELECT p.csexper, p.fnacimi
              INTO xsexo1, xfnacimi1
              FROM estassegurats a, estper_personas p
             WHERE a.sseguro = psseguro
               AND a.sperson = p.sperson
               AND a.norden = 1;
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;

         -- Buscar en ESTASEGURADOS (no join con PERSONAS)
         BEGIN
            SELECT p.csexper, p.fnacimi
              INTO xsexo2, xfnacimi2
              FROM estassegurats a, estper_personas p
             WHERE a.sseguro = psseguro
               AND a.sperson = p.sperson
               AND a.norden = 2;
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;

         -- Buscar en EST
         SELECT pinttec
           INTO xinttec
           FROM estintertecseg
          WHERE sseguro = psseguro;
      ELSIF ptablas = 'SOL' THEN
         ntraza := 3;

         SELECT sproduc, cactivi, nduraci, falta
           INTO xsproduc, xcactivi, xnduraci, xefectopol
           FROM solseguros
          WHERE ssolicit = psseguro;

         BEGIN
            ntraza := 4;

            SELECT a.csexper, a.fnacimi
              INTO xsexo1, xfnacimi1
              FROM solseguros s, solasegurados a
             WHERE s.ssolicit = psseguro
               AND s.ssolicit = a.ssolicit
               AND a.norden = 1;
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;

         BEGIN
            ntraza := 5;

            SELECT a.csexper, a.fnacimi
              INTO xsexo2, xfnacimi2
              FROM solseguros s, solasegurados a
             WHERE s.ssolicit = psseguro
               AND s.ssolicit = a.ssolicit
               AND a.norden = 2;
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;

         ntraza := 6;

         -- Buscar en EST
         SELECT pinttec
           INTO xinttec
           FROM solintertecseg
          WHERE ssolicit = psseguro;
      ELSE
         SELECT sproduc, cactivi, nduraci, fefecto
           INTO xsproduc, xcactivi, xnduraci, xefectopol
           FROM seguros
          WHERE sseguro = psseguro;

         -- Buscar en ESTASEGURADOS (no join con PERSONAS)
         BEGIN
            --Bug10612 - 08/07/2009 - DCT (canviar vista personas)
            SELECT p.csexper, p.fnacimi
              INTO xsexo1, xfnacimi1
              FROM asegurados a, per_personas p
             WHERE a.sseguro = psseguro
               AND a.sperson = p.sperson
               AND a.norden = 1;
         /*SELECT p.csexper, p.fnacimi
           INTO xsexo1, xfnacimi1
           FROM seguros s, asegurados a, personas p
          WHERE s.sseguro = psseguro
            AND s.sseguro = a.sseguro
            AND a.sperson = p.sperson
            AND a.norden = 1;*/
         --FI Bug10612 - 08/07/2009 - DCT (canviar vista personas)
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;

         -- Buscar en ESTASEGURADOS (no join con PERSONAS)
         BEGIN
            --Bug10612 - 08/07/2009 - DCT (canviar vista personas)
            SELECT p.csexper, p.fnacimi
              INTO xsexo2, xfnacimi2
              FROM asegurados a, per_personas p
             WHERE a.sseguro = psseguro
               AND a.sperson = p.sperson
               AND a.norden = 2;
         /*SELECT p.csexper, p.fnacimi
           INTO xsexo2, xfnacimi2
           FROM seguros s, asegurados a, personas p
          WHERE s.sseguro = psseguro
            AND s.sseguro = a.sseguro
            AND a.sperson = p.sperson
            AND a.norden = 2;*/
         --FI Bug10612 - 08/07/2009 - DCT (canviar vista personas)
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;

         -- Buscar en EST
         SELECT pinttec
           INTO xinttec
           FROM intertecseg
          WHERE sseguro = psseguro;
      END IF;

      xndurper := xnduraci;

      SELECT pgastos
        INTO xpgastos
        FROM gastosprod
       WHERE sproduc = xsproduc;

      csupervivencia := ff_capgaran_europlazo16_calc(xxsesion, xnduraci,
                                                     TO_NUMBER(TO_CHAR(pfefecto, 'YYYYMMDD')),
                                                     TO_NUMBER(TO_CHAR(xefectopol, 'YYYYMMDD')),
                                                     psseguro, xsproduc, cgarant, pnriesgo,
                                                     xporigen, pnmovimi, xnduraci, xndurper,
                                                     TO_NUMBER(TO_CHAR(xfnacimi1, 'YYYYMMDD')),
                                                     TO_NUMBER(TO_CHAR(xfnacimi2, 'YYYYMMDD')),
                                                     xsexo1, xsexo2, xinttec, 0, xpgastos,
                                                     v_capital);
      --DBMS_OUTPUT.put_line
      --   ('----------------------------------------------- CAPITAL SUPERVIVENCIA SOBRE PRIMA INICIAL '
      --    || csupervivencia);
      ratioprima := v_capital / csupervivencia;
      prima_eur := ratioprima * v_capital;
      --DBMS_OUTPUT.put_line
      --   ('----------------------------------------------- PRIMA PARA INVERTIR EN EUROPLAZO '
      --    || prima_eur);
      --prima_IBEX35 := v_capital - prima_EUR;
      RETURN prima_eur;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Pac_albsgt_snv.f_primaeuroplazo', ntraza,
                     'ptablas = ' || ptablas || ' psseguro =' || psseguro || ' pnriesgo ='
                     || ' pfefecto =' || pfefecto,
                     SQLERRM);
         RETURN 0;
   END f_primaeuroplazo;

   FUNCTION f_aportacion_menoseuroplazo(
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
      prima_eur      NUMBER;
      prima_ibex35   NUMBER;
      v_capital      NUMBER;
      v_pipc         NUMBER;
      v_prevali      NUMBER;
      ntraza         NUMBER;
   BEGIN
      -- Capital de la prima inicial
      v_capital := f_aportacion(ptablas, psseguro, pnriesgo, pfefecto, pnmovimi, cgarant,
                                psproces, pnmovima, picapital);
      prima_eur := f_primaeuroplazo(ptablas, psseguro, pnriesgo, pfefecto, pnmovimi, cgarant,
                                    psproces, pnmovima, picapital);
      prima_ibex35 := v_capital - prima_eur;
      --DBMS_OUTPUT.put_line
      --      ('----------------------------------------------- PRIMA PARA INVERTIR IBEX 35 '
      --       || prima_ibex35);
      RETURN prima_ibex35;
   EXCEPTION
      WHEN OTHERS THEN
         ntraza := 1;
         p_tab_error(f_sysdate, f_user, 'Pac_albsgt_snv.f_primaeuroplazo', ntraza,
                     'ptablas = ' || ptablas || ' psseguro =' || psseguro || ' pnriesgo ='
                     || ' pfefecto =' || pfefecto,
                     SQLERRM);
         RETURN 0;
   END f_aportacion_menoseuroplazo;

   FUNCTION f_aportextr(
      ptablas IN VARCHAR2,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pfefecto IN DATE,   -- No s'utilitza
      pnmovimi IN NUMBER,
      cgarant IN NUMBER,
      psproces IN NUMBER,
      pnmovima IN NUMBER,   -- No s'utilitza
      picapital IN NUMBER   -- No s'utilitza
                         )
      RETURN NUMBER IS
      v_capital      NUMBER;
   BEGIN
      IF ptablas = 'EST' THEN
         BEGIN
            SELECT NVL(icapital, 0)
              INTO v_capital
              FROM tmp_garancar t, estseguros e
             WHERE t.sseguro = psseguro
               AND e.sseguro = t.sseguro
               AND sproces = psproces
               AND t.nriesgo = pnriesgo
               AND t.nmovi_ant = pnmovimi
               AND f_pargaranpro_v(e.cramo, e.cmodali, e.ctipseg, e.ccolect, e.cactivi,
                                   t.cgarant, 'TIPO') = 4;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               v_capital := 0;
         /*SELECT nvl(icapital,0)
          INTO v_capital
          FROM TMP_GARANCAR t, estseguros e
          WHERE t.sseguro = psseguro
           and e.sseguro = t.sseguro
            AND sproces = psproces
            AND t.nriesgo = pnriesgo
            AND t.nmovi_ant = pnmovimi
            AND f_pargaranpro_v(e.cramo, e.cmodali, e.ctipseg, e.ccolect, e.cactivi,
                                t.cgarant, 'TIPO') = 3; -- PRIMA EXTRAORDINARIA*/
         END;
      ELSIF ptablas = 'SOL' THEN
         BEGIN
            SELECT NVL(icapital, 0)
              INTO v_capital
              FROM tmp_garancar t, solseguros e
             WHERE t.sseguro = psseguro
               AND e.ssolicit = t.sseguro
               AND sproces = psproces
               AND t.nriesgo = pnriesgo
               AND t.nmovi_ant = pnmovimi
               AND f_pargaranpro_v(e.cramo, e.cmodali, e.ctipseg, e.ccolect, e.cactivi,
                                   t.cgarant, 'TIPO') = 4;   -- PRIMA EXTRAORDINARIA
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               v_capital := 0;   --JRH 08/2008 Aquí lo hacemos así
         /* SELECT nvl(icapital,0)
            INTO v_capital
            FROM TMP_GARANCAR t, solseguros e
            WHERE t.sseguro = psseguro
             and e.ssolicit = t.sseguro
              AND sproces = psproces
              AND t.nriesgo = pnriesgo
              AND t.nmovi_ant = pnmovimi
              AND f_pargaranpro_v(e.cramo, e.cmodali, e.ctipseg, e.ccolect, e.cactivi,
                                  t.cgarant, 'TIPO') = 3; -- PRIMA AHORRO*/
         END;
      ELSE
         BEGIN
            SELECT NVL(icapital, 0)
              INTO v_capital
              FROM garanseg g, seguros s
             WHERE g.sseguro = psseguro
               AND s.sseguro = g.sseguro
               AND g.nriesgo = pnriesgo
               AND g.nmovimi = pnmovimi   --JRH IMP 1
               AND f_pargaranpro_v(s.cramo, s.cmodali, s.ctipseg, s.ccolect, s.cactivi,
                                   g.cgarant, 'TIPO') = 4;   -- PRIMA EXTRAORDINARIA
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               v_capital := 0;   --JRH 08/2008 Aquí lo hacemos así
         /*SELECT nvl(icapital,0)
           INTO v_capital
           FROM GARANSEG G, SEGUROS s
           WHERE g.sseguro = psseguro
            AND s.sseguro = g.sseguro
             AND g.nriesgo = pnriesgo
             AND g.nmovimi = pnmovimi
             AND f_pargaranpro_v(s.cramo, s.cmodali, s.ctipseg, s.ccolect, s.cactivi,
                                 g.cgarant, 'TIPO') = 3; -- PRIMA AHORRO*/
         END;
      END IF;

      RETURN v_capital;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 0;
   END f_aportextr;

   FUNCTION f_primasriesgo(
      ptablas IN VARCHAR2,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pfefecto IN DATE,   -- No s'utilitza
      pnmovimi IN NUMBER,
      cgarant IN NUMBER,
      psproces IN NUMBER,
      pnmovima IN NUMBER,   -- No s'utilitza
      picapital IN NUMBER   -- No s'utilitza
                         )
      RETURN NUMBER IS
      /********************
         Suma de las primas de las coberturas adicionales de fallecimiento y accidentes
           para los productos de ahorro
      **********************/
      v_prima        NUMBER;
   BEGIN
      IF ptablas = 'EST' THEN
         SELECT NVL(SUM(f_prima_forpag(ptablas, 1, 3, psseguro, pnriesgo, cgarant,
                                       NVL(t.ipritar, 0), pnmovimi)),
                    0)
           INTO v_prima
           FROM tmp_garancar t, estseguros e
          WHERE t.sseguro = psseguro
            AND e.sseguro = t.sseguro
            AND sproces = psproces
            AND t.nriesgo = pnriesgo
            AND t.nmovi_ant = pnmovimi
            AND f_pargaranpro_v(e.cramo, e.cmodali, e.ctipseg, e.ccolect, e.cactivi, t.cgarant,
                                'TIPO') IN(6, 7);   -- fallecimiento y accidentes
      ELSIF ptablas = 'SOL' THEN
         SELECT NVL(SUM(f_prima_forpag(ptablas, 1, 3, psseguro, pnriesgo, cgarant,
                                       NVL(t.ipritar, 0), pnmovimi)),
                    0)
           INTO v_prima
           FROM tmp_garancar t, solseguros e
          WHERE t.sseguro = psseguro
            AND e.ssolicit = t.sseguro
            AND sproces = psproces
            AND t.nriesgo = pnriesgo
            AND t.nmovi_ant = pnmovimi
            AND f_pargaranpro_v(e.cramo, e.cmodali, e.ctipseg, e.ccolect, e.cactivi, t.cgarant,
                                'TIPO') IN(6, 7);   -- fallecimiento y accidentes
      ELSE
         SELECT NVL(SUM(f_prima_forpag(ptablas, 1, 3, psseguro, pnriesgo, cgarant,
                                       NVL(t.ipritar, 0), pnmovimi)),
                    0)
           INTO v_prima
           FROM tmp_garancar t, seguros e
          WHERE t.sseguro = psseguro
            AND e.sseguro = t.sseguro
            AND sproces = psproces
            AND t.nriesgo = pnriesgo
            AND t.nmovi_ant = pnmovimi
            AND f_pargaranpro_v(e.cramo, e.cmodali, e.ctipseg, e.ccolect, e.cactivi, t.cgarant,
                                'TIPO') IN(6, 7);   -- fallecimiento y accidentes
      END IF;

      RETURN v_prima;
   EXCEPTION
      WHEN OTHERS THEN
         --DBMS_OUTPUT.put_line('error primas riesgo ' || SQLERRM);
         RETURN 0;
   END f_primasriesgo;

   FUNCTION f_intprom(
      ptablas IN VARCHAR2,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pfefecto IN DATE,   -- No s'utilitza
      pnmovimi IN NUMBER,
      cgarant IN NUMBER,
      psproces IN NUMBER,
      pnmovima IN NUMBER,   -- No s'utilitza
      picapital IN NUMBER   -- No s'utilitza
                         )
      RETURN NUMBER IS
      /********************
         Busca el interés promocional definido en el producto (si lo hay).
         Sólo lo busca si es el movimiento 1, si no buscará el del movimiento anterior
      **********************/
      v_sseguro      seguros.sseguro%TYPE;
      v_icapital     garanseg.icapital%TYPE;
      v_sproduc      seguros.sproduc%TYPE;
      v_inttec       NUMBER;
      num_err        NUMBER;
   BEGIN
      IF pnmovimi = 1 THEN
         v_icapital := f_aportextr(ptablas, psseguro, pnriesgo, pfefecto, pnmovimi, cgarant,
                                   psproces, pnmovima, picapital);

         IF ptablas = 'EST' THEN
            SELECT sproduc
              INTO v_sproduc
              FROM estseguros
             WHERE sseguro = psseguro;
         ELSIF ptablas = 'SOL' THEN
            SELECT sproduc
              INTO v_sproduc
              FROM solseguros
             WHERE ssolicit = psseguro;
         ELSE
            SELECT sproduc
              INTO v_sproduc
              FROM seguros
             WHERE sseguro = psseguro;
         END IF;

         num_err := pac_inttec.f_int_producto(v_sproduc, 5, pfefecto, v_icapital, v_inttec);
      ELSE
         -- buscamos el último de esta pregunta en el movimiento anterior
         IF ptablas = 'EST' THEN
            SELECT ssegpol
              INTO v_sseguro
              FROM estseguros
             WHERE sseguro = psseguro;
         ELSE
            v_sseguro := psseguro;
         END IF;

         SELECT crespue
           INTO v_inttec
           FROM pregunseg
          WHERE cpregun = 6
            AND sseguro = v_sseguro
            AND nmovimi = (SELECT MAX(nmovimi)
                             FROM pregunseg
                            WHERE cpregun = 6
                              AND sseguro = v_sseguro);
      END IF;

      RETURN NVL(v_inttec, 0);
   EXCEPTION
      WHEN OTHERS THEN
         --DBMS_OUTPUT.put_line('when others then sqlerr =' || SQLERRM);
         RETURN 0;
   END f_intprom;

   FUNCTION f_obtvalor_preg_riesg(
      ptablas IN VARCHAR2,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      ppregun IN NUMBER)
      RETURN NUMBER IS
      valor          NUMBER;
      ntraza         NUMBER;
   BEGIN
      IF ptablas = 'EST' THEN
         SELECT NVL(crespue, 0)
           INTO valor
           FROM estpregunseg
          WHERE sseguro = psseguro
            AND nriesgo = pnriesgo
            AND nmovimi = pnmovimi
            AND cpregun = ppregun;   -- 1012 = Respuest del calculo del valor de tasación HI
      ELSIF ptablas = 'SOL' THEN
         SELECT NVL(crespue, 0)
           INTO valor
           FROM solpregunseg
          WHERE ssolicit = psseguro
            AND nriesgo = pnriesgo
            AND nmovimi = pnmovimi
            AND cpregun = ppregun;   -- 1012 = Respuest del calculo del valor de tasación HI
      ELSE
         SELECT NVL(crespue, 0)
           INTO valor
           FROM pregunseg
          WHERE sseguro = psseguro
            AND nriesgo = pnriesgo
            AND nmovimi = pnmovimi
            AND cpregun = ppregun;   -- 1012 = Respuest del calculo del valor de tasación HI
      END IF;

      RETURN valor;
   EXCEPTION
      WHEN OTHERS THEN
         ntraza := 1;
         p_tab_error(f_sysdate, f_user, 'Pac_albsgt_snv.f_obtvalor_preg_riesg', ntraza,
                     'ptablas = ' || ptablas || ' psseguro =' || psseguro || ' pnriesgo ='
                     || pnriesgo,
                     SQLERRM);
         RETURN NULL;
   END f_obtvalor_preg_riesg;

   FUNCTION buscatramo(pfecha IN DATE, ntramo IN NUMBER, vbuscar IN NUMBER)
      RETURN NUMBER IS
/************************************************************
  BUSCATRAMO: Captura el valor de un tramo en la fecha
              que se lanza.
*************************************************************/
      valor          NUMBER;
      ftope          DATE;
   BEGIN
      ftope := pfecha;
      valor := NULL;

      FOR r IN (SELECT   orden, desde, NVL(hasta, desde) hasta, valor
                    FROM sgt_det_tramos
                   WHERE tramo = (SELECT detalle_tramo
                                    FROM sgt_vigencias_tramos
                                   WHERE tramo = ntramo
                                     AND fecha_efecto =
                                               (SELECT MAX(fecha_efecto)
                                                  FROM sgt_vigencias_tramos
                                                 WHERE tramo = ntramo
                                                   AND fecha_efecto <= ftope))
                ORDER BY orden) LOOP
         IF vbuscar BETWEEN r.desde AND r.hasta THEN
            RETURN r.valor;
         END IF;
      END LOOP;

      RETURN NULL;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN NULL;
      WHEN OTHERS THEN
         RETURN NULL;
   END buscatramo;

   FUNCTION datosasegs(
      ptablas IN VARCHAR2,
      psseguro IN NUMBER,
      sexo1 OUT NUMBER,
      fecnac1 OUT DATE,
      sexo2 OUT NUMBER,
      fecnac2 OUT DATE)
      RETURN NUMBER IS
      CURSOR titularesseg(psseguro NUMBER, porder NUMBER) IS
         SELECT p.csexper, p.fnacimi
           FROM asegurados a, per_personas p
          WHERE a.sseguro = psseguro
            AND a.sperson = p.sperson
            AND a.norden = porder
            AND a.ffecfin IS NULL
            AND a.ffecmue IS NULL;

      /*SELECT p.csexper, p.fnacimi
        FROM asegurados a, personas p
       WHERE a.sseguro = psseguro
         AND a.sperson = p.sperson
         AND norden = porder
         AND a.ffecfin IS NULL
         AND a.ffecmue IS NULL;*/
      --FI Bug10612 - 08/07/2009 - DCT (canviar vista personas)
      CURSOR titularesest(psseguro NUMBER, porder NUMBER) IS
         SELECT p.csexper, p.fnacimi   --a.CSEXPER,a.FNACIMI,
           FROM estassegurats a, estper_personas p
          WHERE a.sseguro = psseguro
            AND a.norden = porder
            AND a.sperson = p.sperson;

      CURSOR titularessol(psseguro NUMBER, porder NUMBER) IS
         SELECT a.csexper, a.fnacimi
           FROM solasegurados a
          WHERE a.ssolicit = psseguro
            AND a.norden = porder;

      ntraza         NUMBER := 0;
      vagente_poliza seguros.cagente%TYPE;
      vcempres       seguros.cempres%TYPE;
   BEGIN
      IF ptablas = 'SOL' THEN
         ntraza := 1;

         OPEN titularessol(psseguro, 1);   --1er titular

         FETCH titularessol
          INTO sexo1, fecnac1;

         CLOSE titularessol;

         OPEN titularessol(psseguro, 2);   --2o titular

         FETCH titularessol
          INTO sexo2, fecnac2;

         CLOSE titularessol;
      ELSIF ptablas = 'EST' THEN
         ntraza := 2;

         OPEN titularesest(psseguro, 1);   --1er titular

         FETCH titularesest
          INTO sexo1, fecnac1;

         CLOSE titularesest;

         OPEN titularesest(psseguro, 2);   --2o titular

         FETCH titularesest
          INTO sexo2, fecnac2;

         CLOSE titularesest;
      ELSE
         ntraza := 3;

         OPEN titularesseg(psseguro, 1);   --1er titular

         FETCH titularesseg
          INTO sexo1, fecnac1;

         CLOSE titularesseg;

         OPEN titularesseg(psseguro, 2);   --2o titular

         FETCH titularesseg
          INTO sexo2, fecnac2;

         CLOSE titularesseg;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Pac_albsgt_snv.datosAsegs', ntraza,
                     'ptablas = ' || ptablas || ' psseguro =' || psseguro, SQLERRM);
         RETURN(120308);
   END datosasegs;

   FUNCTION f_gastos_hi(
      ptablas IN VARCHAR2,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pfefecto IN DATE,
      pnmovimi IN NUMBER,
      cgarant IN NUMBER,
      psproces IN NUMBER,
      pnmovima IN NUMBER,
      picapital IN NUMBER,
      ptramo IN NUMBER)
      RETURN NUMBER IS
      valortasacion  NUMBER;
      errparams      EXCEPTION;
      w_error        NUMBER;
      w_sesion       NUMBER;
      ntraza         NUMBER;
      v_agente       NUMBER;
      valoriva       NUMBER;
      sexo1          NUMBER := NULL;
      fecnac1        DATE := NULL;
      sexo2          NUMBER := NULL;
      fecnac2        DATE := NULL;
      sw_2cabezas    BOOLEAN := FALSE;
      fecopern       NUMBER;
      fecoper        DATE;
      x              NUMBER := 0;
      y              NUMBER := 0;
   BEGIN
      --pTramo es el valor en la tabla de tramos para buscar a partir del valor de la pregunta 100 (el valor de tasación)
      ntraza := 2;
      --Respuest del calculo del valor de tasación HI
      valortasacion := f_obtvalor_preg_riesg(ptablas, psseguro, NVL(pnriesgo, 1),
                                             NVL(pnmovimi, 1), 100);

      IF valortasacion IS NULL THEN
         RAISE errparams;
      END IF;

      IF ptramo = 0 THEN
         RETURN 0;
      ELSIF ptramo = 1 THEN   --Caso especial de tramo para calcula la tasación (no se puede ir directo a la tabla de tramos)
         IF ptablas = 'EST' THEN
            SELECT NVL(cagente, 0)
              INTO v_agente
              FROM estseguros
             WHERE sseguro = psseguro;   -- Agente para el iva
         ELSIF ptablas = 'SOL' THEN
            SELECT NVL(cagente, 0)
              INTO v_agente
              FROM solseguros
             WHERE ssolicit = psseguro;   -- Agente para el iva
         ELSE
            SELECT NVL(cagente, 0)
              INTO v_agente
              FROM seguros
             WHERE sseguro = psseguro;   -- Agente para el iva
         END IF;

         IF v_agente = 208 THEN
            valoriva := 1.05;
         ELSE
            valoriva := 1.16;
         END IF;

         IF 0.01 < valortasacion
            AND valortasacion < 29999.99 THEN
            RETURN valoriva * 93;
         ELSIF 30000 < valortasacion
               AND valortasacion < 59999.99 THEN
            RETURN valoriva * 120;
         ELSIF 60000 < valortasacion
               AND valortasacion < 119999.99 THEN
            RETURN valoriva * 150;
         ELSIF 120000 < valortasacion
               AND valortasacion < 299999.99 THEN
            RETURN valoriva *(150 + 0.00075 *(valortasacion - 120000));
         ELSIF 300000 < valortasacion
               AND valortasacion < 1199999.99 THEN
            RETURN valoriva *(285 + 0.00062 *(valortasacion - 300000));
         ELSIF 1200000 < valortasacion
               AND valortasacion < 2999999.99 THEN
            RETURN valoriva *(843 + 0.00039 *(valortasacion - 1200000));
         ELSIF 3000000 < valortasacion
               AND valortasacion < 5999999.99 THEN
            RETURN valoriva *(1545 + 0.00020 *(valortasacion - 3000000));
         ELSIF 6000000 < valortasacion
               AND valortasacion < 1000000000 THEN
            RETURN valoriva *(2145 + 0.00010 *(valortasacion - 6000000));
         ELSE
            RETURN(NULL);
         END IF;
      ELSIF ptramo = 2 THEN   --Caso especial de tramo para calcula la duración de la CC (no se puede ir directo a la tabla de tramos)
         ntraza := 10;
         w_error := datosasegs(ptablas, psseguro, sexo1, fecnac1, sexo2, fecnac2);

         IF w_error <> 0
            OR sexo1 IS NULL THEN
            RAISE errparams;
         END IF;

         ntraza := 11;

         IF sexo2 IS NOT NULL THEN
            sw_2cabezas := TRUE;
         END IF;

         ntraza := 12;
         fecopern := f_obtvalor_preg_riesg(ptablas, psseguro, NVL(pnriesgo, 1),
                                           NVL(pnmovimi, 1), 103);

         IF fecopern IS NULL THEN
            RAISE errparams;
         END IF;

         fecoper := TO_DATE(LPAD(fecopern, 8, '0'), 'DDMMYYYY');
         ntraza := 14;
         w_error := f_difdata(fecnac1, fecoper, 2, 1, x);

         IF w_error <> 0 THEN
            RAISE errparams;
         END IF;

         ntraza := 15;

         IF sw_2cabezas THEN
            w_error := f_difdata(fecnac2, fecoper, 2, 1, y);

            IF w_error <> 0 THEN
               RAISE errparams;
            END IF;
         END IF;

         ntraza := 16;

         IF sw_2cabezas
            AND x > y THEN   --Buscamos en los tramos la duración de la CC
            RETURN(buscatramo(fecoper, 390, y));
         ELSE
            RETURN(buscatramo(fecoper, 390, x));
         END IF;
      ELSE   --Vamos a la tabla de tramos
         ntraza := 6;
         RETURN(buscatramo(pfefecto, ptramo, valortasacion));   --Obtenemos el valor a partir del tramo
      END IF;
   EXCEPTION
      WHEN errparams THEN
         p_tab_error(f_sysdate, f_user, 'Pac_albsgt_snv.f_gastos_HI', ntraza,
                     'ptablas = ' || ptablas || ' psseguro =' || psseguro || ' pnriesgo ='
                     || pnriesgo || ' pfefecto =' || pfefecto || ' Valortasacion = '
                     || valortasacion,
                     'errParams');
         RETURN NULL;
      WHEN OTHERS THEN
         ntraza := 1;
         p_tab_error(f_sysdate, f_user, 'Pac_albsgt_snv.f_gastos_HI', ntraza,
                     'ptablas = ' || ptablas || ' psseguro =' || psseguro || ' pnriesgo ='
                     || pnriesgo || ' pfefecto =' || pfefecto,
                     SQLERRM);
         RETURN NULL;
   END f_gastos_hi;

   FUNCTION f_imc(
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
      -- Calculamos el Índice de masa corporal --
      --VIMC NUMBER := RESP(psproces, 8)/POWER(RESP(psproces,7)/100,2);
      vimc           NUMBER;
      vresp7         NUMBER;
      vresp8         NUMBER;
   BEGIN
      IF ptablas = 'EST' THEN
         -- Buscamos la preguna de ALTURA (en centímetros)
         BEGIN
            SELECT e.crespue
              INTO vresp7
              FROM estpregunseg e
             WHERE e.sseguro = psseguro
               AND e.nmovimi = pnmovimi
               AND e.cpregun = 7
               AND e.nriesgo = pnriesgo;
         EXCEPTION
            WHEN OTHERS THEN
               vresp7 := 0;
         END;

         -- Buscamos la pregunta del peso (en kilos)
         BEGIN
            SELECT e.crespue
              INTO vresp8
              FROM estpregunseg e
             WHERE e.sseguro = psseguro
               AND e.nmovimi = pnmovimi
               AND e.cpregun = 8
               AND e.nriesgo = pnriesgo;
         EXCEPTION
            WHEN OTHERS THEN
               vresp8 := 0;
         END;
      ELSE
         -- Bug 9907 - 27/04/2009 - JRH - Inclusión de preguntas de comisión y gastos en Productos de baja
         BEGIN
            SELECT e.crespue
              INTO vresp7
              FROM pregunseg e
             WHERE e.sseguro = psseguro
               AND e.nmovimi = pnmovimi
               AND e.cpregun = 7
               AND e.nriesgo = pnriesgo;
         EXCEPTION
            WHEN OTHERS THEN
               vresp7 := 0;
         END;

         -- Buscamos la pregunta del peso (en kilos)
         BEGIN
            SELECT e.crespue
              INTO vresp8
              FROM pregunseg e
             WHERE e.sseguro = psseguro
               AND e.nmovimi = pnmovimi
               AND e.cpregun = 8
               AND e.nriesgo = pnriesgo;
         EXCEPTION
            WHEN OTHERS THEN
               vresp8 := 0;
         END;
      END IF;

      vimc := ROUND(vresp8 / POWER((vresp7 / 100), 2), 2);
      RETURN vimc;
   EXCEPTION
      WHEN OTHERS THEN
         --DBMS_OUTPUT.put_line('error primas riesgo ' || SQLERRM);
         RETURN 0;
   END;

   FUNCTION f_partbenef(
      ptablas IN VARCHAR2,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pfefecto IN DATE,   -- No s'utilitza
      pnmovimi IN NUMBER,
      cgarant IN NUMBER,
      psproces IN NUMBER,
      pnmovima IN NUMBER,   -- No s'utilitza
      picapital IN NUMBER   -- No s'utilitza
                         )
      RETURN NUMBER IS
      v_capital      NUMBER;
   BEGIN
      IF ptablas = 'EST' THEN
         BEGIN
            SELECT NVL(icapital, 0)
              INTO v_capital
              FROM garanseg t, estseguros e
             WHERE t.sseguro = e.ssegpol
               AND e.sseguro = psseguro
               -- AND sproces = psproces
               AND t.nriesgo = pnriesgo
               AND t.nmovimi = 1
               AND f_pargaranpro_v(e.cramo, e.cmodali, e.ctipseg, e.ccolect, e.cactivi,
                                   t.cgarant, 'TIPO') = 12;   -- P Benef.
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               BEGIN
                  SELECT NVL(icapital, 0)
                    INTO v_capital
                    FROM tmp_garancar t, estseguros e
                   WHERE t.sseguro = psseguro
                     AND e.sseguro = t.sseguro
                     AND sproces = psproces
                     AND t.nriesgo = pnriesgo
                     AND t.nmovi_ant = pnmovimi
                     AND f_pargaranpro_v(e.cramo, e.cmodali, e.ctipseg, e.ccolect, e.cactivi,
                                         t.cgarant, 'TIPO') = 12;   -- P Benef.
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     SELECT NVL(icapital, 0)
                       INTO v_capital
                       FROM tmp_garancar t, estseguros e
                      WHERE t.sseguro = psseguro
                        AND e.sseguro = t.sseguro
                        AND sproces = psproces
                        AND t.nriesgo = pnriesgo
                        AND t.nmovi_ant = pnmovimi
                        AND f_pargaranpro_v(e.cramo, e.cmodali, e.ctipseg, e.ccolect,
                                            e.cactivi, t.cgarant, 'TIPO') = 12;   -- P Benef.
               END;
         END;
      ELSIF ptablas = 'SOL' THEN
         BEGIN
            SELECT NVL(icapital, 0)
              INTO v_capital
              FROM tmp_garancar t, solseguros e
             WHERE t.sseguro = psseguro
               AND e.ssolicit = t.sseguro
               AND sproces = psproces
               AND t.nriesgo = pnriesgo
               AND t.nmovi_ant = pnmovimi
               AND f_pargaranpro_v(e.cramo, e.cmodali, e.ctipseg, e.ccolect, e.cactivi,
                                   t.cgarant, 'TIPO') = 12;   -- P Benef.
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               SELECT NVL(icapital, 0)
                 INTO v_capital
                 FROM tmp_garancar t, solseguros e
                WHERE t.sseguro = psseguro
                  AND e.ssolicit = t.sseguro
                  AND sproces = psproces
                  AND t.nriesgo = pnriesgo
                  AND t.nmovi_ant = pnmovimi
                  AND f_pargaranpro_v(e.cramo, e.cmodali, e.ctipseg, e.ccolect, e.cactivi,
                                      t.cgarant, 'TIPO') = 12;   -- P Benef.
         END;
      ELSE
         BEGIN
            SELECT NVL(icapital, 0)
              INTO v_capital
              FROM garanseg g, seguros s
             WHERE g.sseguro = psseguro
               AND s.sseguro = g.sseguro
               AND g.nriesgo = pnriesgo
               AND g.nmovimi = pnmovimi   --JRH Ahora con pnmovimi 1
               AND f_pargaranpro_v(s.cramo, s.cmodali, s.ctipseg, s.ccolect, s.cactivi,
                                   g.cgarant, 'TIPO') = 12;   -- P Benef.
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               v_capital := 0;                /*
                                 SELECT nvl(icapital,0)
                                   INTO v_capital
                                   FROM GARANSEG G, SEGUROS s
                                   WHERE g.sseguro = psseguro
                                    AND s.sseguro = g.sseguro
                                     AND g.nriesgo = pnriesgo
                                     AND g.nmovimi = pnmovimi
                                     AND f_pargaranpro_v(s.cramo, s.cmodali, s.ctipseg, s.ccolect, s.cactivi,
                                                         g.cgarant, 'TIPO') = 12; -- P Benef.*/
         END;
      END IF;

      RETURN v_capital;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 0;
   END f_partbenef;

   FUNCTION f_gastos_e(
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
      v_resp531      NUMBER;
      -- Bug 7854 - 16/04/2009 - RSC - Creación de producto CREDIT SALUT Colectivo
      v_sproduc      NUMBER;
      -- Finb Bug 7854
       -- Bug 9907 - 27/04/2009 - JRH - Inclusión de preguntas de comisión y gastos en Productos de baja
      vnpoliza       seguros.npoliza%TYPE;
      vcrespue       estpregunpolseg.crespue%TYPE;
      -- Fi Bug 9907

      -- Bug 10891 - 10/08/2009 - JRH - CRE - CREDIT BAIXA: Càlcul de les comissions
      vtramoacceso   NUMBER;
      vcagente       estseguros.cagente%TYPE;
      vccomisi       agentes.ccomisi%TYPE;
   -- Fi Bug 10891 - 10/08/2009 - JRH
   BEGIN
      vtramoacceso := 1506;

      IF ptablas = 'EST' THEN
         -- Bug 7854 - 16/04/2009 - RSC - Creación de producto CREDIT SALUT Colectivo
         SELECT sproduc
           INTO v_sproduc
           FROM estseguros
          WHERE sseguro = psseguro;

         SELECT estseguros.npoliza, agentes.cagente, agentes.ccomisi
           INTO vnpoliza, vcagente, vccomisi
           FROM estseguros, agentes
          WHERE estseguros.sseguro = psseguro
            AND agentes.cagente = estseguros.cagente;

         -- Bug 10891 - 10/08/2009 - JRH - CRE - CREDIT BAIXA: Càlcul de les comissions
         IF NVL(vccomisi, 0) = 1 THEN   --Vamos a otro tramo en el caso del cuadro=1
            vtramoacceso := 2001;
         END IF;

         -- Fi Bug 10891 - 10/08/2009 - JRH

         -- Finb Bug 7854
          -- Bug 9907 - 27/04/2009 - JRH - Inclusión de preguntas de comisión y gastos en Productos de baja
         -- Buscamos si están informadas las comisiones directamente en la pregunta 570. Si es así se coge el valor de
         -- estas productos.
         IF NVL(f_parproductos_v(v_sproduc, 'ADMITE_CERTIFICADOS'), 0) = 1 THEN
            BEGIN
               SELECT crespue
                 INTO vcrespue
                 FROM estpregunpolseg p, estseguros s
                WHERE p.sseguro = s.sseguro
                  AND s.npoliza = vnpoliza
                  AND s.ncertif = 0
                  AND p.cpregun = 570;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  SELECT NVL(pgasext, 0)
                    INTO vcrespue
                    FROM productos
                   WHERE sproduc = v_sproduc;
            END;

            RETURN NVL(vcrespue, 0);
         ELSE
            -- Bug 9907 - 27/04/2009 - JRH - Inclusión de preguntas de comisión y gastos en Productos de baja
            -- Tratamiento de colectivos
            BEGIN
               SELECT e.crespue
                 INTO v_resp531
                 FROM estpregunseg e
                WHERE e.sseguro = psseguro
                  AND e.nmovimi = pnmovimi
                  AND e.cpregun = 570
                  AND e.nriesgo = pnriesgo;
            EXCEPTION
               WHEN OTHERS THEN
                  BEGIN
                     SELECT e.crespue
                       INTO v_resp531
                       FROM estpregunpolseg e
                      WHERE e.sseguro = psseguro
                        AND e.nmovimi = pnmovimi
                        AND e.cpregun = 570;
                  EXCEPTION
                     WHEN OTHERS THEN
                        v_resp531 := NULL;
                  END;
            END;

            -- Fin Bug 9907
            IF v_resp531 IS NULL THEN
               -- Buscamos la pregunta si tiene contratada
               -- la promoción "NÓMINA DOMICILIADA'
               -- para saber el gasto externo
               BEGIN
                  -- Bug 7854 - 16/04/2009 - RSC - Creación de producto CREDIT SALUT Colectivo
                  -- Utilizamos tramo 1506
                  SELECT vtramo(0, vtramo(0, vtramoacceso, v_sproduc), e.crespue)
                    INTO v_resp531
                    FROM estpregunseg e
                   WHERE e.sseguro = psseguro
                     AND e.nmovimi = pnmovimi
                     AND e.cpregun = 531
                     AND e.nriesgo = pnriesgo;
               -- Finb Bug 7854
               EXCEPTION
                  WHEN OTHERS THEN
                     BEGIN
                        -- Bug 7854 - 16/04/2009 - RSC - Creación de producto CREDIT SALUT Colectivo
                        -- Utilizamos tramo 1506
                        SELECT vtramo(0, vtramo(0, vtramoacceso, v_sproduc), e.crespue)
                          INTO v_resp531
                          FROM estpregunpolseg e
                         WHERE e.sseguro = psseguro
                           AND e.nmovimi = pnmovimi
                           AND e.cpregun = 531;
                     -- Finb Bug 7854
                     EXCEPTION
                        WHEN OTHERS THEN
                           -- Bug 10035 - 15/05/2009 - JRH - CRE - Inclusión de preguntas de gastos en producto Crèdit Vida Capital
                           SELECT NVL(pgasext, 0)
                             INTO v_resp531
                             FROM productos
                            WHERE sproduc = v_sproduc;
                     -- fi bug
                     END;
               END;
            END IF;
         END IF;
      ELSIF ptablas IS NULL THEN
         -- Bug 7854 - 16/04/2009 - RSC - Creación de producto CREDIT SALUT Colectivo
         SELECT sproduc
           INTO v_sproduc
           FROM seguros
          WHERE sseguro = psseguro;

         -- Finb Bug 7854
         SELECT seguros.npoliza, agentes.cagente, agentes.ccomisi
           INTO vnpoliza, vcagente, vccomisi
           FROM seguros, agentes
          WHERE seguros.sseguro = psseguro
            AND agentes.cagente = seguros.cagente;

         -- Bug 10891 - 10/08/2009 - JRH - CRE - CREDIT BAIXA: Càlcul de les comissions
         IF NVL(vccomisi, 0) = 1 THEN   --Vamos a otro tramo en el caso del cuadro=1
            vtramoacceso := 2001;
         END IF;

         -- Fi Bug 10891 - 10/08/2009 - JRH

         -- Bug 9907 - 27/04/2009 - JRH - Inclusión de preguntas de comisión y gastos en Productos de baja
         -- Tratamiento de colectivos
         IF NVL(f_parproductos_v(v_sproduc, 'ADMITE_CERTIFICADOS'), 0) = 1 THEN
            BEGIN
               SELECT crespue
                 INTO vcrespue
                 FROM pregunpolseg p, seguros s
                WHERE p.sseguro = s.sseguro
                  AND s.npoliza = vnpoliza
                  AND s.ncertif = 0
                  AND p.cpregun = 570;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  SELECT NVL(pgasext, 0)
                    INTO vcrespue
                    FROM productos
                   WHERE sproduc = v_sproduc;
            END;

            RETURN NVL(vcrespue, 0);
         ELSE
            -- Bug 9907 - 27/04/2009 - JRH - Inclusión de preguntas de comisión y gastos en Productos de baja
            -- Buscamos si están informadas las comisiones directamente en la pregunta 570. Si es así se coge el valor de
            -- estas productos.
            BEGIN
               SELECT e.crespue
                 INTO v_resp531
                 FROM pregunseg e
                WHERE e.sseguro = psseguro
                  AND e.nmovimi = pnmovimi
                  AND e.cpregun = 570
                  AND e.nriesgo = pnriesgo;
            EXCEPTION
               WHEN OTHERS THEN
                  BEGIN
                     SELECT e.crespue
                       INTO v_resp531
                       FROM pregunpolseg e
                      WHERE e.sseguro = psseguro
                        AND e.nmovimi = pnmovimi
                        AND e.cpregun = 570;
                  EXCEPTION
                     WHEN OTHERS THEN
                        v_resp531 := NULL;
                  END;
            END;

            -- Fin Bug 9907
            IF v_resp531 IS NULL THEN
               BEGIN
                  -- Bug 7854 - 16/04/2009 - RSC - Creación de producto CREDIT SALUT Colectivo
                  -- Utilizamos tramo 1506
                  SELECT vtramo(0, vtramo(0, vtramoacceso, v_sproduc), e.crespue)
                    INTO v_resp531
                    FROM pregunseg e
                   WHERE e.sseguro = psseguro
                     AND e.nmovimi = pnmovimi
                     AND e.cpregun = 531
                     AND e.nriesgo = pnriesgo;
               -- Finb Bug 7854
               EXCEPTION
                  WHEN OTHERS THEN
                     BEGIN
                        -- Bug 7854 - 16/04/2009 - RSC - Creación de producto CREDIT SALUT Colectivo
                        -- Utilizamos tramo 1506
                        SELECT vtramo(0, vtramo(0, vtramoacceso, v_sproduc), e.crespue)
                          INTO v_resp531
                          FROM pregunpolseg e
                         WHERE e.sseguro = psseguro
                           AND e.nmovimi = pnmovimi
                           AND e.cpregun = 531;
                     -- Finb Bug 7854
                     EXCEPTION
                        WHEN OTHERS THEN
                           SELECT NVL(pgasext, 0)
                             INTO v_resp531
                             FROM productos
                            WHERE sproduc = v_sproduc;
                     END;
               END;
            END IF;
         END IF;
      END IF;

      RETURN v_resp531;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Pac_albsgt_snv.f_gastos_e', 0,
                     'ptablas = ' || ptablas || ' psseguro =' || psseguro || ' pnriesgo ='
                     || pnriesgo || ' pfefecto =' || pfefecto || 'nmovimi = ' || pnmovimi
                     || ' (pregunta 531)',
                     SQLERRM);
         RETURN 0;
   END f_gastos_e;

   FUNCTION f_gastos_i(
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
      v_resp531      NUMBER;
      -- Bug 7854 - 16/04/2009 - RSC - Creación de producto CREDIT SALUT Colectivo
      v_sproduc      NUMBER;
      -- Finb Bug 7854
      -- Bug 9907 - 27/04/2009 - JRH - Inclusión de preguntas de comisión y gastos en Productos de baja
      vnpoliza       seguros.npoliza%TYPE;
      vcrespue       estpregunpolseg.crespue%TYPE;
      -- Finb Bug 9907

      -- Bug 10891 - 10/08/2009 - JRH - CRE - CREDIT BAIXA: Càlcul de les comissions
      vtramoacceso   NUMBER;
      vcagente       estseguros.cagente%TYPE;
      vccomisi       agentes.ccomisi%TYPE;
   -- Fi Bug 10891 - 10/08/2009 - JRH
   BEGIN
      vtramoacceso := 1504;

      IF ptablas = 'EST' THEN
         -- Bug 7854 - 16/04/2009 - RSC - Creación de producto CREDIT SALUT Colectivo
         SELECT sproduc
           INTO v_sproduc
           FROM estseguros
          WHERE sseguro = psseguro;

         -- Finb Bug 7854
         SELECT estseguros.npoliza, agentes.cagente, agentes.ccomisi
           INTO vnpoliza, vcagente, vccomisi
           FROM estseguros, agentes
          WHERE estseguros.sseguro = psseguro
            AND agentes.cagente = estseguros.cagente;

         -- Bug 10891 - 10/08/2009 - JRH - CRE - CREDIT BAIXA: Càlcul de les comissions
         IF NVL(vccomisi, 0) = 1 THEN   --Vamos a otro tramo en el caso del cuadro=1
            vtramoacceso := 2000;
         END IF;

         -- Fi Bug 10891 - 10/08/2009 - JRH

         -- Bug 9907 - 27/04/2009 - JRH - Inclusión de preguntas de comisión y gastos en Productos de baja
         -- Tratamiento colectivos.
         IF NVL(f_parproductos_v(v_sproduc, 'ADMITE_CERTIFICADOS'), 0) = 1 THEN
            BEGIN
               SELECT crespue
                 INTO vcrespue
                 FROM estpregunpolseg p, estseguros s
                WHERE p.sseguro = s.sseguro
                  AND s.npoliza = vnpoliza
                  AND s.ncertif = 0
                  AND p.cpregun = 571;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  SELECT NVL(pgasint, 0)
                    INTO vcrespue
                    FROM productos
                   WHERE sproduc = v_sproduc;
            END;

            RETURN vcrespue;
         ELSE
            -- Bug 9907 - 27/04/2009 - JRH - Inclusión de preguntas de comisión y gastos en Productos de baja
            -- Buscamos si están informadas los gastos internos directamente en la pregunta 571. Si es así se coge el valor de
            -- aquí.
            BEGIN
               SELECT e.crespue
                 INTO v_resp531
                 FROM estpregunseg e
                WHERE e.sseguro = psseguro
                  AND e.nmovimi = pnmovimi
                  AND e.cpregun = 571
                  AND e.nriesgo = pnriesgo;
            EXCEPTION
               WHEN OTHERS THEN
                  BEGIN
                     SELECT e.crespue
                       INTO v_resp531
                       FROM estpregunpolseg e
                      WHERE e.sseguro = psseguro
                        AND e.nmovimi = pnmovimi
                        AND e.cpregun = 571;
                  EXCEPTION
                     WHEN OTHERS THEN
                        v_resp531 := NULL;
                  END;
            END;

            -- Fin Bug 9907
            IF v_resp531 IS NULL THEN
               -- Buscamos la pregunta si tiene contratada
               -- la promoción "NÓMINA DOMICILIADA'
               -- para saber el gasto interno
               BEGIN
                  -- Bug 7854 - 16/04/2009 - RSC - Creación de producto CREDIT SALUT Colectivo
                  -- Utilizamos tramo 1504
                  SELECT vtramo(0, vtramo(0, vtramoacceso, v_sproduc), e.crespue)
                    INTO v_resp531
                    FROM estpregunseg e
                   WHERE e.sseguro = psseguro
                     AND e.nmovimi = pnmovimi
                     AND e.cpregun = 531
                     AND e.nriesgo = pnriesgo;
               -- Fin Bug 7854
               EXCEPTION
                  WHEN OTHERS THEN
                     BEGIN
                        -- Bug 7854 - 16/04/2009 - RSC - Creación de producto CREDIT SALUT Colectivo
                        -- Utilizamos tramo 1504
                        SELECT vtramo(0, vtramo(0, vtramoacceso, v_sproduc), e.crespue)
                          INTO v_resp531
                          FROM estpregunpolseg e
                         WHERE e.sseguro = psseguro
                           AND e.nmovimi = pnmovimi
                           AND e.cpregun = 531;
                     -- Fin Bug 7854
                     EXCEPTION
                        WHEN OTHERS THEN
                           SELECT NVL(pgasint, 0)
                             INTO v_resp531
                             FROM productos
                            WHERE sproduc = v_sproduc;
                     END;
               END;
            END IF;
         END IF;
      ELSIF ptablas IS NULL THEN
         -- Bug 7854 - 16/04/2009 - RSC - Creación de producto CREDIT SALUT Colectivo
         SELECT sproduc
           INTO v_sproduc
           FROM seguros
          WHERE sseguro = psseguro;

         -- Finb Bug 7854

         -- Bug 9907 - 27/04/2009 - JRH - Inclusión de preguntas de comisión y gastos en Productos de baja
         --Tratamiento colectivos
         SELECT seguros.npoliza, agentes.cagente, agentes.ccomisi
           INTO vnpoliza, vcagente, vccomisi
           FROM seguros, agentes
          WHERE seguros.sseguro = psseguro
            AND agentes.cagente = seguros.cagente;

         -- Bug 10891 - 10/08/2009 - JRH - CRE - CREDIT BAIXA: Càlcul de les comissions
         IF NVL(vccomisi, 0) = 1 THEN   --Vamos a otro tramo en el caso del cuadro=1
            vtramoacceso := 2000;
         END IF;

         -- Fi Bug 10891 - 10/08/2009 - JRH
         IF NVL(f_parproductos_v(v_sproduc, 'ADMITE_CERTIFICADOS'), 0) = 1 THEN
            BEGIN
               SELECT crespue
                 INTO vcrespue
                 FROM pregunpolseg p, seguros s
                WHERE p.sseguro = s.sseguro
                  AND s.npoliza = vnpoliza
                  AND s.ncertif = 0
                  AND p.cpregun = 571;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  SELECT NVL(pgasint, 0)
                    INTO vcrespue
                    FROM productos
                   WHERE sproduc = v_sproduc;
            END;

            RETURN vcrespue;
         ELSE
            BEGIN
               SELECT e.crespue
                 INTO v_resp531
                 FROM pregunseg e
                WHERE e.sseguro = psseguro
                  AND e.nmovimi = pnmovimi
                  AND e.cpregun = 571
                  AND e.nriesgo = pnriesgo;
            EXCEPTION
               WHEN OTHERS THEN
                  BEGIN
                     SELECT e.crespue
                       INTO v_resp531
                       FROM pregunpolseg e
                      WHERE e.sseguro = psseguro
                        AND e.nmovimi = pnmovimi
                        AND e.cpregun = 571;
                  EXCEPTION
                     WHEN OTHERS THEN
                        v_resp531 := NULL;
                  END;
            END;

            -- Fin Bug 9907
            IF v_resp531 IS NULL THEN
               BEGIN
                  -- Bug 7854 - 16/04/2009 - RSC - Creación de producto CREDIT SALUT Colectivo
                  -- Utilizamos tramo 1504
                  SELECT vtramo(0, vtramo(0, vtramoacceso, v_sproduc), e.crespue)
                    INTO v_resp531
                    FROM pregunseg e
                   WHERE e.sseguro = psseguro
                     AND e.nmovimi = pnmovimi
                     AND e.cpregun = 531
                     AND e.nriesgo = pnriesgo;
               -- Fin Bug 7854
               EXCEPTION
                  WHEN OTHERS THEN
                     BEGIN
                        -- Bug 7854 - 16/04/2009 - RSC - Creación de producto CREDIT SALUT Colectivo
                        -- Utilizamos tramo 1504
                        SELECT vtramo(0, vtramo(0, vtramoacceso, v_sproduc), e.crespue)
                          INTO v_resp531
                          FROM pregunpolseg e
                         WHERE e.sseguro = psseguro
                           AND e.nmovimi = pnmovimi
                           AND e.cpregun = 531;
                     -- Fin Bug 7854
                     EXCEPTION
                        WHEN OTHERS THEN
                           SELECT NVL(pgasint, 0)
                             INTO v_resp531
                             FROM productos
                            WHERE sproduc = v_sproduc;
                     END;
               END;
            END IF;
         END IF;
      END IF;

      RETURN v_resp531;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Pac_albsgt_snv.f_gastos_i', 0,
                     'ptablas = ' || ptablas || ' psseguro =' || psseguro || ' pnriesgo ='
                     || pnriesgo || ' pfefecto =' || pfefecto || 'nmovimi = ' || pnmovimi
                     || ' (pregunta 531)',
                     SQLERRM);
         RETURN 0;
   END f_gastos_i;

   FUNCTION f_coef_ppj(
      ptablas IN VARCHAR2,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pfefecto IN DATE,
      pnmovimi IN NUMBER,
      cgarant IN NUMBER,
      psproces IN NUMBER,
      pnmovima IN NUMBER,
      picapital IN NUMBER,
      pclave IN NUMBER)
      RETURN NUMBER IS
      resultado      NUMBER;
      verror         NUMBER;
      psproduc       NUMBER;
      porigen        NUMBER;
      pfecha         DATE;
      pcactivi       NUMBER;
   BEGIN
      IF ptablas = 'EST' THEN
         SELECT sproduc, cactivi, fefecto
           INTO psproduc, pcactivi, pfecha
           FROM estseguros
          WHERE sseguro = psseguro;

         porigen := 1;
      ELSIF ptablas = 'SOL' THEN
         SELECT sproduc, cactivi, falta
           INTO psproduc, pcactivi, pfecha
           FROM solseguros
          WHERE ssolicit = psseguro;

         porigen := 0;
      ELSE
         SELECT sproduc, cactivi, fefecto
           INTO psproduc, pcactivi, pfecha
           FROM seguros
          WHERE sseguro = psseguro;

         porigen := 2;
      END IF;

      verror := pac_calculo_formulas.calc_formul(pfecha, psproduc, pcactivi, cgarant, pnriesgo,
                                                 psseguro, pclave, resultado, pnmovimi, NULL,
                                                 porigen, NULL, 'R');
      RETURN resultado;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Pac_albsgt_snv.F_COEF_PPJ', 0,
                     'ptablas = ' || ptablas || ' psseguro =' || psseguro || ' pnriesgo ='
                     || pnriesgo || ' pfefecto =' || pfefecto || 'nmovimi = ' || pnmovimi
                     || ' (pregunta 531)',
                     SQLERRM);
         RETURN 0;
   END f_coef_ppj;

   FUNCTION f_nomina_domi(
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
      v_resp531      NUMBER;
      v_resp552      NUMBER;
   -- Saber si tiene  contratada la promoción "NÓMINA DOMICILIADA" y hasta cuando
   BEGIN
      IF ptablas = 'EST' THEN
         -- Buscamos la pregunta si tiene contratada
         -- la promoción "NÓMINA DOMICILIADA"
         BEGIN
            SELECT e.crespue
              INTO v_resp531
              FROM estpregunseg e
             WHERE e.sseguro = psseguro
               AND e.nmovimi = pnmovimi
               AND e.cpregun = 531
               AND e.nriesgo = pnriesgo;
         EXCEPTION
            WHEN OTHERS THEN
               BEGIN
                  SELECT e.crespue
                    INTO v_resp531
                    FROM estpregunpolseg e
                   WHERE e.sseguro = psseguro
                     AND e.nmovimi = pnmovimi
                     AND e.cpregun = 531;
               EXCEPTION
                  WHEN OTHERS THEN
                     v_resp531 := 0;
               END;
         END;

         IF v_resp531 = 1 THEN
            -- Buscamos la fecha fin de la promoción "NÓMINA DOMICILIADA"
            BEGIN
               SELECT e.crespue
                 INTO v_resp552
                 FROM estpregunseg e
                WHERE e.sseguro = psseguro
                  AND e.nmovimi = pnmovimi
                  AND e.cpregun = 552
                  AND e.nriesgo = pnriesgo;
            EXCEPTION
               WHEN OTHERS THEN
                  BEGIN
                     SELECT e.crespue
                       INTO v_resp552
                       FROM estpregunpolseg e
                      WHERE e.sseguro = psseguro
                        AND e.nmovimi = pnmovimi
                        AND e.cpregun = 552;
                  EXCEPTION
                     WHEN OTHERS THEN
                        -- Si no tiene informada fecha fin periodo y
                        -- Si tiene nómina domiciliada informamos
                        -- la fecha fin del periodo (+6 meses)
                        v_resp552 := TO_NUMBER(TO_CHAR(ADD_MONTHS(pfefecto, 6), 'YYYYMMDD'));
                  END;
            END;
         ELSE
            v_resp552 := NULL;
         END IF;
      ELSIF ptablas IS NULL THEN
         -- Buscamos la pregunta si tiene contratada
         -- la promoción "NÓMINA DOMICILIADA"
         BEGIN
            SELECT e.crespue
              INTO v_resp531
              FROM pregunseg e
             WHERE e.sseguro = psseguro
               AND e.nmovimi = pnmovimi
               AND e.cpregun = 531
               AND e.nriesgo = pnriesgo;
         EXCEPTION
            WHEN OTHERS THEN
               BEGIN
                  SELECT e.crespue
                    INTO v_resp531
                    FROM pregunpolseg e
                   WHERE e.sseguro = psseguro
                     AND e.nmovimi = pnmovimi
                     AND e.cpregun = 531;
               EXCEPTION
                  WHEN OTHERS THEN
                     v_resp531 := 0;
               END;
         END;

         IF v_resp531 = 1 THEN
            -- Buscamos la fecha fin de la promoción "NÓMINA DOMICILIADA"
            BEGIN
               SELECT e.crespue
                 INTO v_resp552
                 FROM pregunseg e
                WHERE e.sseguro = psseguro
                  AND e.nmovimi = pnmovimi
                  AND e.cpregun = 552
                  AND e.nriesgo = pnriesgo;
            EXCEPTION
               WHEN OTHERS THEN
                  BEGIN
                     SELECT e.crespue
                       INTO v_resp552
                       FROM pregunpolseg e
                      WHERE e.sseguro = psseguro
                        AND e.nmovimi = pnmovimi
                        AND e.cpregun = 552;
                  EXCEPTION
                     WHEN OTHERS THEN
                        -- Si no tiene informada fecha fin periodo y
                        -- Si tiene nómina domiciliada informamos
                        -- la fecha fin del periodo (+6 meses)
                        v_resp552 := TO_NUMBER(TO_CHAR(ADD_MONTHS(pfefecto, 6), 'YYYYMMDD'));
                  END;
            END;
         ELSE
            v_resp552 := NULL;
         END IF;
      END IF;

      RETURN v_resp552;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Pac_albsgt_snv.f_nomina_domi', 0,
                     'ptablas = ' || ptablas || ' psseguro =' || psseguro || ' pnriesgo ='
                     || pnriesgo || ' pfefecto =' || pfefecto || 'nmovimi = ' || pnmovimi
                     || ' (pregunta 552)',
                     SQLERRM);
         RETURN NULL;
   END f_nomina_domi;

   --Bug 5467 - 20/02/2009 - RSC - Desarrollo de sistema de copago
   FUNCTION f_tramo_tarifa(
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
      vcrespue       NUMBER;
      vnpoliza       NUMBER;
   BEGIN
      IF ptablas = 'EST' THEN
         SELECT npoliza
           INTO vnpoliza
           FROM estseguros
          WHERE sseguro = psseguro;
      ELSIF ptablas = 'SOL' THEN
         SELECT npoliza
           INTO vnpoliza
           FROM estseguros
          WHERE sseguro = psseguro;
      ELSE
         SELECT npoliza
           INTO vnpoliza
           FROM seguros
          WHERE sseguro = psseguro;
      END IF;

      BEGIN
         SELECT crespue   -- Tipo de copago (1-Porcentaje; 2-Importe)
           INTO vcrespue
           FROM pregunpolseg p, seguros s
          WHERE p.sseguro = s.sseguro
            AND s.npoliza = vnpoliza   -- El valor del psseguro es el npoliza para este caso
            AND s.ncertif = 0
            AND p.cpregun = 538;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN   --- Para provar
            vcrespue := 1400;   -- Tarifa estandard
      END;

      RETURN vcrespue;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Pac_Albsgt_Snv.f_tramo_tarifa', 1,
                     'ptablas=' || ptablas || ';psseguro=' || psseguro || ';pnriesgo='
                     || pnriesgo,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN NULL;
   END f_tramo_tarifa;

   -- RSC 25/02/2009 Pruebas de Tarifa arrastrada del certificado 0
   FUNCTION f_tramo_tarifavida(
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
      vcrespue       NUMBER;
      vnpoliza       NUMBER;
   BEGIN
      IF ptablas = 'EST' THEN
         SELECT npoliza
           INTO vnpoliza
           FROM estseguros
          WHERE sseguro = psseguro;
      ELSIF ptablas = 'SOL' THEN
         SELECT npoliza
           INTO vnpoliza
           FROM estseguros
          WHERE sseguro = psseguro;
      ELSE
         SELECT npoliza
           INTO vnpoliza
           FROM seguros
          WHERE sseguro = psseguro;
      END IF;

      BEGIN
         SELECT crespue   -- Tipo de copago (1-Porcentaje; 2-Importe)
           INTO vcrespue
           FROM pregunpolseg p, seguros s
          WHERE p.sseguro = s.sseguro
            AND s.npoliza = vnpoliza   -- El valor del psseguro es el npoliza para este caso
            AND s.ncertif = 0
            AND p.cpregun = 541;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN   --- Para provar
            vcrespue := 852;   -- Tarifa estandard
      END;

      RETURN vcrespue;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Pac_Albsgt_Snv.f_tramo_tarifavida', 1,
                     'ptablas=' || ptablas || ';psseguro=' || psseguro || ';pnriesgo='
                     || pnriesgo,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN NULL;
   END f_tramo_tarifavida;

   -- RSC 25/02/2009 Pruebas de Tarifa arrastrada del certificado 0
   FUNCTION f_descuento_sobreprima(
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
      vcrespue       NUMBER;
      vnpoliza       NUMBER;
   BEGIN
      IF ptablas = 'EST' THEN
         SELECT npoliza
           INTO vnpoliza
           FROM estseguros
          WHERE sseguro = psseguro;
      ELSIF ptablas = 'SOL' THEN
         SELECT npoliza
           INTO vnpoliza
           FROM estseguros
          WHERE sseguro = psseguro;
      ELSE
         SELECT npoliza
           INTO vnpoliza
           FROM seguros
          WHERE sseguro = psseguro;
      END IF;

      BEGIN
         SELECT crespue   -- Tipo de copago (1-Porcentaje; 2-Importe)
           INTO vcrespue
           FROM pregunpolseg p, seguros s
          WHERE p.sseguro = s.sseguro
            AND s.npoliza = vnpoliza   -- El valor del psseguro es el npoliza para este caso
            AND s.ncertif = 0
            AND p.cpregun = 542;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN   --- Para provar
            vcrespue := 100;   -- Tarifa estandard
      END;

      RETURN vcrespue;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Pac_Albsgt_Snv.f_descuento_sobreprima', 1,
                     'ptablas=' || ptablas || ';psseguro=' || psseguro || ';pnriesgo='
                     || pnriesgo,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN NULL;
   END f_descuento_sobreprima;

   --Bug 5467 - 15/02/2009 - RSC - Desarrollo de sistema de copago
   FUNCTION f_tipocopago_riesgo(
      ptablas IN VARCHAR2,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pfefecto IN DATE,   -- No s'utilitza
      pnmovimi IN NUMBER,   -- No s'utilitza
      cgarant IN NUMBER,   -- No s'utilitza
      psproces IN NUMBER,   -- No s'utilitza
      pnmovima IN NUMBER,   -- No s'utilitza
      picapital IN NUMBER   -- No s'utilitza
                         )
      RETURN NUMBER IS
      vctipimp       NUMBER := NULL;
      v_npoliza      seguros.npoliza%TYPE;
   BEGIN
      IF ptablas = 'EST' THEN
         SELECT npoliza
           INTO v_npoliza
           FROM estseguros
          WHERE sseguro = psseguro;
      ELSIF ptablas = 'SOL' THEN
         SELECT npoliza
           INTO v_npoliza
           FROM estseguros
          WHERE sseguro = psseguro;
      ELSE
         SELECT npoliza
           INTO v_npoliza
           FROM seguros
          WHERE sseguro = psseguro;
      END IF;

      IF pnriesgo < 2 THEN
         SELECT ctipimp   -- Tipo de copago (1-Porcentaje; 2-Importe)
           INTO vctipimp
           FROM aportaseg a, seguros s
          WHERE a.sseguro = s.sseguro
            AND s.npoliza = v_npoliza   -- El valor del psseguro es el npoliza para este caso
            AND s.ncertif = 0
            AND norden = pnriesgo;
      ELSE
         SELECT ctipimp   -- Tipo de copago (1-Porcentaje; 2-Importe)
           INTO vctipimp
           FROM aportaseg a, seguros s
          WHERE a.sseguro = s.sseguro
            AND s.npoliza = v_npoliza   -- El valor del psseguro es el npoliza para este caso
            AND s.ncertif = 0
            AND norden = 2;
      END IF;

      RETURN vctipimp;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Pac_Albsgt_Snv.f_tipocopago_riesgo', 1,
                     'ptablas=' || ptablas || ';psseguro=' || psseguro || ';pnriesgo='
                     || pnriesgo,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN NULL;
   END f_tipocopago_riesgo;

    --Bug 5467 - 15/02/2009 - RSC - Desarrollo de sistema de copago
   /*************************************************************************
      Función para obtener el valor de copago por defecto
      param in ptablas  : variable que indica si se está en la tablas reales o no
      param in sseguro  : código de seguro del certificado cero
      param in pnriesgo : número de riesgo
      return              : number (tipo del copago)
   *************************************************************************/
   FUNCTION f_valorcopago_riesgo(
      ptablas IN VARCHAR2,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pfefecto IN DATE,   -- No s'utilitza
      pnmovimi IN NUMBER,   -- No s'utilitza
      cgarant IN NUMBER,   -- No s'utilitza
      psproces IN NUMBER,   -- No s'utilitza
      pnmovima IN NUMBER,   -- No s'utilitza
      picapital IN NUMBER   -- No s'utilitza
                         )
      RETURN NUMBER IS
      vctipimp       NUMBER;
      vpimport       NUMBER;
      viimport       NUMBER;
      vvalorcopago   NUMBER;
      v_npoliza      seguros.npoliza%TYPE;
   BEGIN
--       vctipimp := f_tipocopago_riesgo (ptablas, psseguro, pnriesgo , pfefecto, pnmovimi,
--                                        cgarant, psproces, pnmovima, picapital);
      IF ptablas = 'EST' THEN
         SELECT npoliza
           INTO v_npoliza
           FROM estseguros
          WHERE sseguro = psseguro;
      ELSIF ptablas = 'SOL' THEN
         SELECT npoliza
           INTO v_npoliza
           FROM estseguros
          WHERE sseguro = psseguro;
      ELSE
         SELECT npoliza
           INTO v_npoliza
           FROM seguros
          WHERE sseguro = psseguro;
      END IF;

      IF pnriesgo < 2 THEN
         SELECT DECODE(ctipimp,
                       1, pimport,
                       2, iimport,
                       NULL)   -- Tipo de copago (1-Porcentaje; 2-Importe)
           INTO vvalorcopago
           FROM aportaseg a, seguros s
          WHERE a.sseguro = s.sseguro
            AND s.npoliza = v_npoliza   -- El valor del psseguro es el npoliza para este caso
            AND s.ncertif = 0
            AND norden = pnriesgo;
      ELSE
         SELECT DECODE(ctipimp,
                       1, pimport,
                       2, iimport,
                       NULL)   -- Tipo de copago (1-Porcentaje; 2-Importe)
           INTO vvalorcopago
           FROM aportaseg a, seguros s
          WHERE a.sseguro = s.sseguro
            AND s.npoliza = v_npoliza   -- El valor del psseguro es el npoliza para este caso
            AND s.ncertif = 0
            AND norden = 2;
      END IF;

      RETURN vvalorcopago;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Pac_Albsgt_Snv.f_valorcopago_riesgo', 1,
                     'ptablas=' || ptablas || ';psseguro=' || psseguro || ';pnriesgo='
                     || pnriesgo,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN NULL;
   END f_valorcopago_riesgo;

   FUNCTION f_gastos_lista(
      ptablas IN VARCHAR2,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pfefecto IN DATE,   -- No s'utilitza
      pnmovimi IN NUMBER,
      cgarant IN NUMBER,   -- No s'utilitza
      psproces IN NUMBER,   -- No s'utilitza
      pnmovima IN NUMBER,   -- No s'utilitza
      picapital IN NUMBER)   -- No s'utilitza
      RETURN NUMBER IS
      vresp553       NUMBER;
      vtrespue       NUMBER;
   BEGIN
      -- En la propuesta se ha de poder introducir la comisión por
      -- una pregunta con lista desplegable, y la pregunta de gastos
      -- externos se ha de rellenar automáticamente con ese valor.
      IF ptablas = 'EST' THEN
         BEGIN
            SELECT e.crespue
              INTO vresp553
              FROM estpregunseg e
             WHERE e.sseguro = psseguro
               AND e.nmovimi = pnmovimi
               AND e.cpregun = 553
               AND e.nriesgo = pnriesgo;
         EXCEPTION
            WHEN OTHERS THEN
               BEGIN
                  SELECT e.crespue
                    INTO vresp553
                    FROM estpregunpolseg e
                   WHERE e.sseguro = psseguro
                     AND e.nmovimi = pnmovimi
                     AND e.cpregun = 553;
               EXCEPTION
                  WHEN OTHERS THEN
                     vresp553 := 0;
               END;
         END;
      ELSE
         BEGIN
            SELECT e.crespue
              INTO vresp553
              FROM pregunseg e
             WHERE e.sseguro = psseguro
               AND e.nmovimi = pnmovimi
               AND e.cpregun = 553
               AND e.nriesgo = pnriesgo;
         EXCEPTION
            WHEN OTHERS THEN
               BEGIN
                  SELECT e.crespue
                    INTO vresp553
                    FROM pregunpolseg e
                   WHERE e.sseguro = psseguro
                     AND e.nmovimi = pnmovimi
                     AND e.cpregun = 553;
               EXCEPTION
                  WHEN OTHERS THEN
                     vresp553 := 0;
               END;
         END;
      END IF;

      BEGIN
         SELECT TO_NUMBER(trespue)
           INTO vtrespue
           FROM respuestas
          WHERE cpregun = 553
            AND crespue = vresp553
            AND ROWNUM = 1;   -- para que solo devuelva 1 idioma
      EXCEPTION
         WHEN OTHERS THEN
            vtrespue := 0;
      END;

      RETURN vtrespue;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Pac_albsgt_snv.f_gastos_lista', 0,
                     'ptablas = ' || ptablas || ' psseguro =' || psseguro || ' pnriesgo ='
                     || pnriesgo || ' pfefecto =' || pfefecto || 'nmovimi = ' || pnmovimi
                     || ' (pregunta 553)',
                     SQLERRM);
         RETURN 0;
   END f_gastos_lista;

   /***********************************************************************
      Función que nos retornará la edad del riesgo a la fecha de última
      cartera. Esta edad será la que se grabrá tanto en suplementos, como en
      una tarificación a una fecha. En cuanto a la tarificación por cartera,
      en caso de entrarnos una fecha que sea la fecha de renovación o bien
      la fecha de cumplimiento de años del riesgo se calculará la edad a esa
      fecha.

      param in ptablas   : Identificador fijo de tablas
      param in psseguro  : Identificador fijo de contrato
      param in pnriesgo  : Identificador fijo de riesgo
      param in pfefecto  : Identificador fijo de fecha efecto
      param in pnmovimi  : Identificador fijo de movimiento
      param in cgarant   : Identificador fijo de garantía
      param in psproces  : Identificador fijo de proceso
      param in pnmovima  : Identificador fijo de nmovima
      param in picapital : Identificador fijo de capital
      return             : Number (edad).
   ***********************************************************************/
   -- Bug 10539 - RSC - 29/06/2009 - Pólizas con error en el cálculo de la edad
   -- Los productos fraccionarios deberán calcular la edad del riesgo en todo
   -- caso a la fecha de cartera anterior.
   FUNCTION f_edad_riesgo_frac(
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
      num_err        NUMBER;
      -- Bug 10539 - RSC - 25/06/2009 - Pólizas con error en el cálculo de la edad
      n_retafrac     NUMBER(1);
      v_cursor       NUMBER;
      ss             VARCHAR2(3000);
      funcion        VARCHAR2(40);
      v_filas        NUMBER;
      p_sproduc      seguros.sproduc%TYPE;
      v_fcarpro      seguros.fcarpro%TYPE;
   -- Fin Bug 10539
   BEGIN
      IF ptablas = 'EST' THEN
         -- Estamos en nueva produccion o suplementos
         -- Es la fecha efecto del riesgo, tanto para nueva producción como para suplementos
         BEGIN
            SELECT fnacimi, ssegpol, r.fefecto, s.fcaranu, s.fcarpro, s.fcarant
              INTO v_fnacimi, v_ssegpol, v_fefecto, v_fcaranu, v_fcarpro, v_fecha
              FROM estriesgos r, estper_personas p, estseguros s
             WHERE r.sseguro = psseguro
               AND s.sseguro = r.sseguro
               AND r.sperson = p.sperson
               AND r.nriesgo = pnriesgo;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN NULL;
         END;

         -- Bug 10539 - RSC - 25/06/2009 - Pólizas con error en el cálculo de la edad
         --IF (pfefecto = v_fcaranu AND n_retafrac IS NULL) OR n_retafrac = 1 THEN
         IF pfefecto = v_fcarpro THEN
            v_fecha := v_fcarpro;
         ELSE
            -- Si el riesgo se ha dado de alta posteriormente a la fcarant
            IF (v_fecha IS NULL)
               OR(v_fecha < v_fefecto) THEN
               v_fecha := v_fefecto;
            END IF;
         END IF;

         -- la edad siempre a la fecha de última cartera
         num_err := f_difdata(v_fnacimi, v_fecha, 2, 1, v_edad);
      ELSE
         -- Estamos cartera
         BEGIN
            --Bug10612 - 08/07/2009 - DCT (canviar vista personas)
            SELECT p.fnacimi, r.fefecto, s.fcaranu, s.fcarpro, s.fcarant
              INTO v_fnacimi, v_fefecto, v_fcaranu, v_fcarpro, v_fecha
              FROM riesgos r, per_personas p, seguros s
             WHERE r.sseguro = psseguro
               AND s.sseguro = r.sseguro
               AND r.sperson = p.sperson
               AND r.nriesgo = pnriesgo;
         /*SELECT fnacimi, r.fefecto, s.fcaranu, s.fcarpro, s.fcarant
           INTO v_fnacimi, v_fefecto, v_fcaranu, v_fcarpro, v_fecha
           FROM riesgos r, personas p, seguros s
          WHERE r.sseguro = psseguro
            AND s.sseguro = r.sseguro
            AND r.sperson = p.sperson
            AND r.nriesgo = pnriesgo;*/
         --FI Bug10612 - 08/07/2009 - DCT (canviar vista personas)
         EXCEPTION
            WHEN OTHERS THEN
               RETURN NULL;
         END;

         -- Bug 10539 - RSC - 25/06/2009 - Pólizas con error en el cálculo de la edad
         IF pfefecto = v_fcarpro THEN
            --IF (pfefecto = v_fcaranu AND n_retafrac IS NULL) OR n_retafrac = 1 THEN
               -- si es cartera utilizamos la fecha de efecto
               -- (que será la fcaranu de la póliza)
            v_fecha := pfefecto;
         ELSE
            -- Si el riesgo se ha dado de alta posteriormente a la fcarant
            IF (v_fecha IS NULL)
               OR(v_fecha < v_fefecto) THEN
               v_fecha := v_fefecto;
            END IF;
         END IF;

         num_err := f_difdata(v_fnacimi, v_fecha, 2, 1, v_edad);
      END IF;

      RETURN v_edad;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 22222;
   END f_edad_riesgo_frac;

-- Fin Bug 10539
   /***********************************************************************
      Función que nos retornará los gastor internos para el producto de saldo deutors

      param in ptablas   : Identificador fijo de tablas
      param in psseguro  : Identificador fijo de contrato
      param in pnriesgo  : Identificador fijo de riesgo
      param in pfefecto  : Identificador fijo de fecha efecto
      param in pnmovimi  : Identificador fijo de movimiento
      param in cgarant   : Identificador fijo de garantía
      param in psproces  : Identificador fijo de proceso
      param in pnmovima  : Identificador fijo de nmovima
      param in picapital : Identificador fijo de capital
      return             : Number (edad).
   ***********************************************************************/
   FUNCTION f_gastos_i_saldodeutors_b(
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
      vquery         VARCHAR2(4000);
      vtab           VARCHAR2(10);
      vntraza        NUMBER := 0;
      vcrespue_gi    NUMBER := 0;
   BEGIN
      IF ptablas = 'EST' THEN
         vtab := 'EST';
      ELSE
         vtab := ' ';
      END IF;

      -- Buscamos a nivel de pregunta sobre riesgo
      vquery :=
         'begin   select crespue into :vcrespue_gi from ' || vtab
         || 'pregunseg WHERE sseguro = :psseguro  AND nriesgo = :pnriesgo  AND nmovimi = :pnmovimi  AND cpregun = 550;  end;';

      BEGIN
         EXECUTE IMMEDIATE vquery
                     USING OUT vcrespue_gi, IN psseguro, IN pnriesgo, IN pnmovimi;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            BEGIN
               vquery :=
                  'begin   select crespue into :vcrespue_gi from ' || vtab
                  || 'pregunpolseg WHERE sseguro = :psseguro AND nmovimi = :pnmovimi  AND cpregun = 550;  end;';

               EXECUTE IMMEDIATE vquery
                           USING OUT vcrespue_gi, IN psseguro, IN pnmovimi;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  vcrespue_gi := NVL(vtramo(0, 1550, 0), 0);
            END;
      END;

      RETURN NVL(vcrespue_gi, 0);
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'f_gastos_i_saldodeutors_b', vntraza,
                     ' - ptablas  ' || ptablas || ' - psseguro ' || psseguro || ' - pnriesgo '
                     || pnriesgo || ' - pfefecto ' || pfefecto || ' - pnmovimi ' || pnmovimi
                     || ' - cgarant ' || cgarant || ' - psproces ' || psproces
                     || ' - pnmovima ' || pnmovima || ' - picapital ' || picapital,
                     SQLERRM);
         RETURN NULL;
   END f_gastos_i_saldodeutors_b;

   /***********************************************************************
      Función que nos retornará los gastor internos para el producto de saldo deutors

      param in ptablas   : Identificador fijo de tablas
      param in psseguro  : Identificador fijo de contrato
      param in pnriesgo  : Identificador fijo de riesgo
      param in pfefecto  : Identificador fijo de fecha efecto
      param in pnmovimi  : Identificador fijo de movimiento
      param in cgarant   : Identificador fijo de garantía
      param in psproces  : Identificador fijo de proceso
      param in pnmovima  : Identificador fijo de nmovima
      param in picapital : Identificador fijo de capital
      return             : Number (edad).
   ***********************************************************************/
   FUNCTION f_gastos_e_saldodeutors_b(
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
      vquery         VARCHAR2(4000);
      vtab           VARCHAR2(10);
      vntraza        NUMBER := 0;
      vcrespue_ge    NUMBER := 0;
   BEGIN
      IF ptablas = 'EST' THEN
         vtab := 'EST';
      ELSE
         vtab := ' ';
      END IF;

      -- Buscamos a nivel de pregunta sobre riesgo
      vquery :=
         'begin   select crespue into :vcrespue_ge from ' || vtab
         || 'pregunseg WHERE sseguro = :psseguro  AND nriesgo = :pnriesgo  AND nmovimi = :pnmovimi  AND cpregun = 551;  end;';

      BEGIN
         EXECUTE IMMEDIATE vquery
                     USING OUT vcrespue_ge, IN psseguro, IN pnriesgo, IN pnmovimi;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            BEGIN
               vquery :=
                  'begin   select crespue into :vcrespue_ge from ' || vtab
                  || 'pregunpolseg WHERE sseguro = :psseguro AND nmovimi = :pnmovimi  AND cpregun = 551;  end;';

               EXECUTE IMMEDIATE vquery
                           USING OUT vcrespue_ge, IN psseguro, IN pnmovimi;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  vcrespue_ge := NVL(vtramo(0, 1570, 0), 0);
            END;
      END;

      RETURN NVL(vcrespue_ge, 0);
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'f_gastos_e_saldodeutors_b', vntraza,
                     ' - ptablas  ' || ptablas || ' - psseguro ' || psseguro || ' - pnriesgo '
                     || pnriesgo || ' - pfefecto ' || pfefecto || ' - pnmovimi ' || pnmovimi
                     || ' - cgarant ' || cgarant || ' - psproces ' || psproces
                     || ' - pnmovima ' || pnmovima || ' - picapital ' || picapital,
                     SQLERRM);
         RETURN NULL;
   END f_gastos_e_saldodeutors_b;

   /***********************************************************************
       Función que nos retornará los gastor internos para el producto de saldo deutors

       param in ptablas   : Identificador fijo de tablas
       param in psseguro  : Identificador fijo de contrato
       param in pnriesgo  : Identificador fijo de riesgo
       param in pfefecto  : Identificador fijo de fecha efecto
       param in pnmovimi  : Identificador fijo de movimiento
       param in cgarant   : Identificador fijo de garantía
       param in psproces  : Identificador fijo de proceso
       param in pnmovima  : Identificador fijo de nmovima
       param in picapital : Identificador fijo de capital
       return             : Number (edad).
    ***********************************************************************/
   FUNCTION f_gastos_i_saldodeutors_a(
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
      vquery         VARCHAR2(4000);
      vtab           VARCHAR2(10);
      vntraza        NUMBER := 0;
      vcrespue_gi    NUMBER := 0;
   BEGIN
      IF ptablas = 'EST' THEN
         vtab := 'EST';
      ELSE
         vtab := ' ';
      END IF;

      -- Buscamos a nivel de pregunta sobre riesgo
      vquery :=
         'begin   select crespue into :vcrespue_gi from ' || vtab
         || 'pregunseg WHERE sseguro = :psseguro  AND nriesgo = :pnriesgo  AND nmovimi = :pnmovimi  AND cpregun = 550;  end;';

      BEGIN
         EXECUTE IMMEDIATE vquery
                     USING OUT vcrespue_gi, IN psseguro, IN pnriesgo, IN pnmovimi;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            BEGIN
               vquery :=
                  'begin   select crespue into :vcrespue_gi from ' || vtab
                  || 'pregunpolseg WHERE sseguro = :psseguro AND nmovimi = :pnmovimi  AND cpregun = 550;  end;';

               EXECUTE IMMEDIATE vquery
                           USING OUT vcrespue_gi, IN psseguro, IN pnmovimi;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  vcrespue_gi := NVL(vtramo(0, 1551, 0), 0);
            END;
      END;

      RETURN NVL(vcrespue_gi, 0);
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'f_gastos_i_saldodeutors_a', vntraza,
                     ' - ptablas  ' || ptablas || ' - psseguro ' || psseguro || ' - pnriesgo '
                     || pnriesgo || ' - pfefecto ' || pfefecto || ' - pnmovimi ' || pnmovimi
                     || ' - cgarant ' || cgarant || ' - psproces ' || psproces
                     || ' - pnmovima ' || pnmovima || ' - picapital ' || picapital,
                     SQLERRM);
         RETURN NULL;
   END f_gastos_i_saldodeutors_a;

   /***********************************************************************
      Función que nos retornará los gastor internos para el producto de saldo deutors

      param in ptablas   : Identificador fijo de tablas
      param in psseguro  : Identificador fijo de contrato
      param in pnriesgo  : Identificador fijo de riesgo
      param in pfefecto  : Identificador fijo de fecha efecto
      param in pnmovimi  : Identificador fijo de movimiento
      param in cgarant   : Identificador fijo de garantía
      param in psproces  : Identificador fijo de proceso
      param in pnmovima  : Identificador fijo de nmovima
      param in picapital : Identificador fijo de capital
      return             : Number (edad).
   ***********************************************************************/
   FUNCTION f_gastos_e_saldodeutors_a(
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
      vquery         VARCHAR2(4000);
      vtab           VARCHAR2(10);
      vntraza        NUMBER := 0;
      vcrespue_ge    NUMBER := 0;
   BEGIN
      IF ptablas = 'EST' THEN
         vtab := 'EST';
      ELSE
         vtab := ' ';
      END IF;

      -- Buscamos a nivel de pregunta sobre riesgo
      vquery :=
         'begin   select crespue into :vcrespue_ge from ' || vtab
         || 'pregunseg WHERE sseguro = :psseguro  AND nriesgo = :pnriesgo  AND nmovimi = :pnmovimi  AND cpregun = 551;  end;';

      BEGIN
         EXECUTE IMMEDIATE vquery
                     USING OUT vcrespue_ge, IN psseguro, IN pnriesgo, IN pnmovimi;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            BEGIN
               vquery :=
                  'begin   select crespue into :vcrespue_ge from ' || vtab
                  || 'pregunpolseg WHERE sseguro = :psseguro AND nmovimi = :pnmovimi  AND cpregun = 551;  end;';

               EXECUTE IMMEDIATE vquery
                           USING OUT vcrespue_ge, IN psseguro, IN pnmovimi;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  vcrespue_ge := NVL(vtramo(0, 1571, 0), 0);
            END;
      END;

      RETURN NVL(vcrespue_ge, 0);
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'f_gastos_e_saldodeutors_a', vntraza,
                     ' - ptablas  ' || ptablas || ' - psseguro ' || psseguro || ' - pnriesgo '
                     || pnriesgo || ' - pfefecto ' || pfefecto || ' - pnmovimi ' || pnmovimi
                     || ' - cgarant ' || cgarant || ' - psproces ' || psproces
                     || ' - pnmovima ' || pnmovima || ' - picapital ' || picapital,
                     SQLERRM);
         RETURN NULL;
   END f_gastos_e_saldodeutors_a;

   /***********************************************************************
      Función que actualizará la sobreprima o el descuento de las pólizas
      de los productos colectivos del ramo de SALUD de CREDIT

      param in ptablas   : Identificador fijo de tablas
      param in psseguro  : Identificador fijo de contrato
      param in pnriesgo  : Identificador fijo de riesgo
      param in pfefecto  : Identificador fijo de fecha efecto
      param in pnmovimi  : Identificador fijo de movimiento
      param in cgarant   : Identificador fijo de garantía
      param in psproces  : Identificador fijo de proceso
      param in pnmovima  : Identificador fijo de nmovima
      param in picapital : Identificador fijo de capital
      return             : Number (porcentaje sobreprima o descuento).
   ***********************************************************************/
   FUNCTION f_sobreprima_descuento_80(
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
      v_respue       NUMBER;
      v_nmovimi_ini  NUMBER;
      vquery         VARCHAR2(4000);
      vtab           VARCHAR2(10);
      v_valor        NUMBER := 0;
      v_pdto         NUMBER := 0;
      vntraza        NUMBER := 0;
      existe         NUMBER;
   BEGIN
      IF ptablas = 'EST' THEN
         vtab := 'EST';
      ELSE
         vtab := ' ';
      END IF;

      vntraza := 1;

      --recupera el porcentaje del certificado 0 de la póliza
      IF ptablas = 'EST' THEN
         SELECT crespue
           INTO v_respue
           FROM pregunpolseg
          WHERE sseguro IN(SELECT sseguro
                             FROM seguros
                            WHERE npoliza IN(SELECT npoliza
                                               FROM estseguros
                                              WHERE sseguro = psseguro)
                              AND ncertif = 0)
            AND cpregun = 542;

         --Comprovem si estem en Nova producció o Suplements o Cartera.
         BEGIN
            SELECT NVL(MIN(m1.nmovimi), 0)
              INTO v_nmovimi_ini
              FROM movseguro m1
             WHERE m1.sseguro IN(SELECT ssegpol
                                   FROM estseguros
                                  WHERE sseguro = psseguro);
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               v_nmovimi_ini := 0;
         END;
      ELSE
         SELECT crespue
           INTO v_respue
           FROM pregunpolseg
          WHERE sseguro IN(SELECT sseguro
                             FROM seguros
                            WHERE npoliza IN(SELECT npoliza
                                               FROM seguros
                                              WHERE sseguro = psseguro)
                              AND ncertif = 0)
            AND cpregun = 542;

         --Comprovem si estem en Nova producció o Suplements o Cartera.
         BEGIN
            SELECT NVL(MIN(m1.nmovimi), 0)
              INTO v_nmovimi_ini
              FROM movseguro m1
             WHERE m1.sseguro = psseguro;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               v_nmovimi_ini := 0;
         END;
      END IF;

      IF v_respue >= 0 THEN
         vntraza := 2;
         vquery :=
            'begin   select precarg into :v_valor from tmp_garancar WHERE sseguro = :psseguro  AND nriesgo = :pnriesgo
            AND sproces = :psproces  AND cgarant = 80;  end;';

         BEGIN
            EXECUTE IMMEDIATE vquery
                        USING OUT v_valor, IN psseguro, IN pnriesgo, IN psproces;
         END;

         --Nonés modifiquem automàticament la sobreprima en cas de Nova Producció
         IF v_nmovimi_ini = 0
            AND NVL(v_valor, 0) = 0 THEN
            vntraza := 3;
            vquery :=
               'begin   update tmp_garancar SET precarg = :v_respue
         WHERE sseguro = :psseguro  AND nriesgo = :pnriesgo AND cgarant = 80 and sproces = :psproces;  end;';

            BEGIN
               EXECUTE IMMEDIATE vquery
                           USING IN v_respue, IN psseguro, IN pnriesgo, IN psproces;
            END;
         END IF;
      ELSE
         vntraza := 4;
         v_pdto := v_respue *(-1);
         vquery :=
            'begin   select pdtocom into :v_valor from tmp_garancar WHERE sseguro = :psseguro  AND nriesgo = :pnriesgo
            AND sproces = :psproces  AND cgarant = 80;  end;';

         BEGIN
            EXECUTE IMMEDIATE vquery
                        USING OUT v_valor, IN psseguro, IN pnriesgo, IN psproces;
         END;

         --Nonés modifiquem automàticament el descompte en cas de Nova Producció
         IF v_nmovimi_ini = 0
            AND NVL(v_valor, 0) = 0 THEN
            vntraza := 5;
            vquery :=
               'begin   update tmp_garancar SET pdtocom = :v_pdto
         WHERE sseguro = :psseguro  AND nriesgo = :pnriesgo AND cgarant = 80 and sproces = :psproces;  end;';

            BEGIN
               EXECUTE IMMEDIATE vquery
                           USING IN v_pdto, IN psseguro, IN pnriesgo, IN psproces;
            END;
         END IF;
      END IF;

      COMMIT;
      RETURN NVL(v_respue, 0);
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'f_sobreprima_descuento_80', vntraza,
                     ' - ptablas  ' || ptablas || ' - psseguro ' || psseguro || ' - pnriesgo '
                     || pnriesgo || ' - pfefecto ' || pfefecto || ' - pnmovimi ' || pnmovimi
                     || ' - cgarant ' || cgarant || ' - psproces ' || psproces
                     || ' - pnmovima ' || pnmovima || ' - picapital ' || picapital,
                     SQLERRM);
         RETURN 0;
   END f_sobreprima_descuento_80;

   --Bug 5467 - 13/10/2009 - RSC - CRE - Modificación de capital en producto PIAM Colectivo.
   /*************************************************************************
      Función para obtener el capital de muerte arrastrado del certificado 0
      param in ptablas  : variable que indica si se está en la tablas reales o no
      param in sseguro  : código de seguro del certificado cero
      param in pnriesgo : número de riesgo
      return            : number (Capital arrastrado)
   *************************************************************************/
   FUNCTION f_capital_muerte(
      ptablas IN VARCHAR2,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pfefecto IN DATE,   -- No s'utilitza
      pnmovimi IN NUMBER,   -- No s'utilitza
      cgarant IN NUMBER,   -- No s'utilitza
      psproces IN NUMBER,   -- No s'utilitza
      pnmovima IN NUMBER,   -- No s'utilitza
      picapital IN NUMBER   -- No s'utilitza
                         )
      RETURN NUMBER IS
      vcapital       NUMBER;
      v_capital_prod NUMBER;
      v_npoliza      seguros.npoliza%TYPE;
   BEGIN
      IF ptablas = 'EST' THEN
         SELECT npoliza
           INTO v_npoliza
           FROM estseguros
          WHERE sseguro = psseguro;
      ELSIF ptablas = 'SOL' THEN
         SELECT npoliza
           INTO v_npoliza
           FROM estseguros
          WHERE sseguro = psseguro;
      ELSE
         SELECT npoliza
           INTO v_npoliza
           FROM seguros
          WHERE sseguro = psseguro;
      END IF;

      SELECT valor
        INTO v_capital_prod
        FROM sgt_parm_formulas
       WHERE codigo = 'CAP_SALUT';

      BEGIN
         IF pnriesgo < 2 THEN
            SELECT crespue
              INTO vcapital
              FROM pregunseg a, seguros s
             WHERE a.sseguro = s.sseguro
               AND s.npoliza = v_npoliza
               AND s.ncertif = 0
               AND a.cpregun = 584
               AND a.nmovimi = (SELECT MAX(nmovimi)
                                  FROM pregunseg p2
                                 WHERE p2.sseguro = a.sseguro
                                   AND p2.cpregun = a.cpregun
                                   AND p2.nriesgo = a.nriesgo)
               AND nriesgo = pnriesgo;
         ELSE
            SELECT crespue
              INTO vcapital
              FROM pregunseg a, seguros s
             WHERE a.sseguro = s.sseguro
               AND s.npoliza = v_npoliza
               AND s.ncertif = 0
               AND a.cpregun = 584
               AND a.nmovimi = (SELECT MAX(nmovimi)
                                  FROM pregunseg p2
                                 WHERE p2.sseguro = a.sseguro
                                   AND p2.cpregun = a.cpregun
                                   AND p2.nriesgo = a.nriesgo)
               AND nriesgo = 2;
         END IF;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            vcapital := v_capital_prod;
      END;

      RETURN vcapital;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Pac_Albsgt_Snv.f_capital_muerte', 1,
                     'ptablas=' || ptablas || ';psseguro=' || psseguro || ';pnriesgo='
                     || pnriesgo,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN NULL;
   END f_capital_muerte;

   --Bug 5467 - 13/10/2009 - RSC - CRE - Modificación de capital en producto PIAM Colectivo.
   /*************************************************************************
      Función para obtener el capital de enfermedad grave arrastrado del certificado 0
      param in ptablas  : variable que indica si se está en la tablas reales o no
      param in sseguro  : código de seguro del certificado cero
      param in pnriesgo : número de riesgo
      return            : number (Capital arrastrado)
   *************************************************************************/
   FUNCTION f_capital_enfermedad(
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
      vcapital       NUMBER;
      v_capital_prod NUMBER;
      v_npoliza      seguros.npoliza%TYPE;
   BEGIN
      IF ptablas = 'EST' THEN
         SELECT npoliza
           INTO v_npoliza
           FROM estseguros
          WHERE sseguro = psseguro;
      ELSIF ptablas = 'SOL' THEN
         SELECT npoliza
           INTO v_npoliza
           FROM estseguros
          WHERE sseguro = psseguro;
      ELSE
         SELECT npoliza
           INTO v_npoliza
           FROM seguros
          WHERE sseguro = psseguro;
      END IF;

      SELECT valor
        INTO v_capital_prod
        FROM sgt_parm_formulas
       WHERE codigo = 'CAP_SALUT';

      BEGIN
         IF pnriesgo < 2 THEN
            SELECT crespue
              INTO vcapital
              FROM pregunseg a, seguros s
             WHERE a.sseguro = s.sseguro
               AND s.npoliza = v_npoliza
               AND s.ncertif = 0
               AND a.cpregun = 585
               AND a.nmovimi = (SELECT MAX(nmovimi)
                                  FROM pregunseg p2
                                 WHERE p2.sseguro = a.sseguro
                                   AND p2.cpregun = a.cpregun
                                   AND p2.nriesgo = a.nriesgo)
               AND nriesgo = pnriesgo;
         ELSE
            SELECT crespue
              INTO vcapital
              FROM pregunseg a, seguros s
             WHERE a.sseguro = s.sseguro
               AND s.npoliza = v_npoliza
               AND s.ncertif = 0
               AND a.cpregun = 585
               AND a.nmovimi = (SELECT MAX(nmovimi)
                                  FROM pregunseg p2
                                 WHERE p2.sseguro = a.sseguro
                                   AND p2.cpregun = a.cpregun
                                   AND p2.nriesgo = a.nriesgo)
               AND nriesgo = 2;
         END IF;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            vcapital := v_capital_prod;
      END;

      RETURN vcapital;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Pac_Albsgt_Snv.f_capital_enfermedad', 1,
                     'ptablas=' || ptablas || ';psseguro=' || psseguro || ';pnriesgo='
                     || pnriesgo,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN NULL;
   END f_capital_enfermedad;

   --Bug 12682 - 10/02/2010 - MRB - CRE - CVC-PRIVATS
   /*************************************************************************

      Busca el tipus de subscripció, en base al capital de la garantia de mort
      i de si hi han preguntes a null o contestades afirmativament en el
      questionari de salut.

      param in ptablas   : Identificador fijo de tablas
      param in psseguro  : Identificador fijo de contrato
      param in pnriesgo  : Identificador fijo de riesgo
      param in pfefecto  : Identificador fijo de fecha efecto
      param in pnmovimi  : Identificador fijo de movimiento
      param in cgarant   : Identificador fijo de garantía
      param in psproces  : Identificador fijo de proceso
      param in pnmovima  : Identificador fijo de nmovima
      param in picapital : Identificador fijo de capital
      return             : Number (Torna el valor del Tipo de Subscripció
                                  ( 0 => Proposta sense retenció,
                                    1 => Proposta amb telesubscripció,
                                    2 => Proposat amb telesubscripció i
                                         proves mèdiques adicionals.)
   *************************************************************************
   --Bug 14186 - 20/04/2010 - JGR - CRE998 - Modificaciones y resolución de incidencia en CV Privats
   *************************************************************************/
   FUNCTION f_tipus_subscripcio(
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
      v_imc          pregunseg.crespue%TYPE;
      v_salut        pregunseg.crespue%TYPE;
      v_edad         pregunseg.crespue%TYPE;
      -- Bug 14186 - 20/04/2010 - JGR - 8. 0014186: CRE998 - Modificaciones y resolución de incidencia en CV Privats
      v_tramo        sgt_tramos.tramo%TYPE;
      v_capital      garanseg.icapital%TYPE := 0;
      v_sperson      riesgos.sperson%TYPE;
      v_error        NUMBER;
   BEGIN
      IF ptablas = 'EST' THEN
         BEGIN
            SELECT NVL(sperson, 0)
              INTO v_sperson
              FROM estriesgos
             WHERE sseguro = psseguro
               AND nriesgo = pnriesgo;
         EXCEPTION
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, 'Pac_Albsgt_Snv.f_tipus_subscripcio SPERSON', 1,
                           'ptablas=' || ptablas || ';psseguro=' || psseguro || ';pnriesgo='
                           || pnriesgo,
                           'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
               RETURN NULL;
         END;

         BEGIN   -- Capital del riesgo
            SELECT SUM(NVL(icapital, 0))
              INTO v_capital
              FROM estgaranseg
             WHERE sseguro = psseguro
               AND nriesgo = pnriesgo
               AND cgarant = 1;
         EXCEPTION
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, 'Pac_Albsgt_Snv.f_tipus_subscripcio SUMCAPI', 1,
                           'ptablas=' || ptablas || ';psseguro=' || psseguro || ';pnriesgo='
                           || pnriesgo,
                           'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
               RETURN NULL;
         END;

         BEGIN   -- Índex masa corporal
-- Bug 14186 : v_imc := pac_albsgt_snv.f_imc(ptablas, psseguro, pnriesgo, pfefecto, pnmovimi,
-- Bug 14186 :                               cgarant, psproces, pnmovima, picapital);
-- Bug 14186 : Hacer que el IMC se recupere de la pregunta (sino desaprovechamos la funcion
--             dinámica que supone que se rellene según lo que ponga en PREGUNPRO.
            SELECT NVL(crespue, 0)
              INTO v_imc
              FROM preguncar
             WHERE sseguro = psseguro
               AND nriesgo = pnriesgo
               AND nmovimi = pnmovimi
               AND cpregun = 9;
         EXCEPTION
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, 'Pac_Albsgt_Snv.f_tipus_subscripcio IMC', 1,
                           'ptablas=' || ptablas || ';psseguro=' || psseguro || ';pnriesgo='
                           || pnriesgo || ';PNMOVIMI = ' || pnmovimi,
                           'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
               RETURN NULL;
         END;

         BEGIN   -- Respostes afirmatives a declaracio de salut.
            SELECT NVL(crespue, 0)
              INTO v_salut
              FROM estpregunseg
             WHERE sseguro = psseguro
               AND nriesgo = pnriesgo
               AND nmovimi = pnmovimi
               AND cpregun = 10;
         EXCEPTION
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, 'Pac_Albsgt_Snv.f_tipus_subscripcio SALUT', 1,
                           'ptablas=' || ptablas || ';psseguro=' || psseguro || ';pnriesgo='
                           || pnriesgo,
                           'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
               RETURN NULL;
         END;

         -- Buscamos la edad pero al ser una pregunta automática no
         -- encontraremos la última situación en ESTPREGUNSEG sino en
         -- PREGUNCAR, aún no se ha hecho el traspaso de una a la otra.
         BEGIN   -- Edad
            SELECT NVL(crespue, 0)
              INTO v_edad
              FROM preguncar
             WHERE sseguro = psseguro
               AND nriesgo = pnriesgo
               AND nmovimi = pnmovimi
               AND cpregun = 1;
         EXCEPTION
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, 'Pac_Albsgt_Snv.f_tipus_subscripcio EDAD', 1,
                           'ptablas=' || ptablas || ';psseguro=' || psseguro || ';pnriesgo='
                           || pnriesgo,
                           'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
               RETURN NULL;
         END;
      ELSE
         BEGIN
            SELECT NVL(sperson, 0)
              INTO v_sperson
              FROM riesgos
             WHERE sseguro = psseguro
               AND nriesgo = pnriesgo
               AND nmovimb IS NULL;
         EXCEPTION
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, 'Pac_Albsgt_Snv.f_tipus_subscripcio SPERSON', 1,
                           'ptablas=' || ptablas || ';psseguro=' || psseguro || ';pnriesgo='
                           || pnriesgo,
                           'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
               RETURN NULL;
         END;

         BEGIN   -- Índex masa corporal
-- Bug 14186 : v_imc := pac_albsgt_snv.f_imc(ptablas, psseguro, pnriesgo, pfefecto, pnmovimi,
-- Bug 14186 :                               cgarant, psproces, pnmovima, picapital);
-- Bug 14186 : Hacer que el IMC se recupere de la pregunta (sino desaprovechamos la funcion
--             dinámica que supone que se rellene según lo que ponga en PREGUNPRO.
            SELECT NVL(crespue, 0)
              INTO v_imc
              FROM preguncar
             WHERE sseguro = psseguro
               AND nriesgo = pnriesgo
               AND nmovimi = pnmovimi
               AND cpregun = 9;
         EXCEPTION
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, 'Pac_Albsgt_Snv.f_tipus_subscripcio IMC', 1,
                           'ptablas=' || ptablas || ';psseguro=' || psseguro || ';pnriesgo='
                           || pnriesgo,
                           'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
               RETURN NULL;
         END;

         BEGIN   -- Respostes afirmatives a declaracio de salut.
            SELECT NVL(crespue, 0)
              INTO v_salut
              FROM pregunseg
             WHERE sseguro = psseguro
               AND nriesgo = pnriesgo
               AND nmovimi = pnmovimi
               AND cpregun = 10;
         EXCEPTION
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, 'Pac_Albsgt_Snv.f_tipus_subscripcio SALUT', 1,
                           'ptablas=' || ptablas || ';psseguro=' || psseguro || ';pnriesgo='
                           || pnriesgo,
                           'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
               RETURN NULL;
         END;

         -- Buscamos la edad pero al ser una pregunta automática no
         -- encontraremos la última situación en ESTPREGUNSEG sino en
         -- PREGUNCAR, aún no se ha hecho el traspaso de una a la otra.
         BEGIN   -- Edad.
            SELECT NVL(crespue, 0)
              INTO v_edad
              FROM preguncar
             WHERE sseguro = psseguro
               AND nriesgo = pnriesgo
               AND nmovimi = pnmovimi
               AND cpregun = 1;
         EXCEPTION
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, 'Pac_Albsgt_Snv.f_tipus_subscripcio EDAD ', 1,
                           'ptablas=' || ptablas || ';psseguro=' || psseguro || ';pnriesgo='
                           || pnriesgo,
                           'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
               RETURN NULL;
         END;
      END IF;

      v_capital := fcumsumacap(psproces, v_sperson, 0, 5, NVL(v_capital, 0));
      -- Bug 14186 - 20/04/2010 - JGR - 8. 0014186: CRE998 - Modificaciones y resolución de incidencia en CV Privats - INI

      -- Tramos capital
      -- [1]       0 a < 120.000
      -- [2] 120.000 a < 300.000
      -- [3] 300.000 a < 500.000
      -- [4]          >= 500.000
      v_tramo := vtramo(0, 2106, v_capital);

      -- Bug 14186 - 20/04/2010 - JGR - 8. 0014186: CRE998 - Modificaciones y resolución de incidencia en CV Privats - FIN
      IF v_tramo = 4 THEN   -- v_capital >= 500000 -- Bug 14186 - 20/04/2010 - JGR
         RETURN 2;   -- Proposta Retinguda AMB Telesubscripció i proves adicionals.
      ELSIF v_tramo = 1 THEN   -- v_capital < 120000 -- Bug 14186 - 20/04/2010 - JGR
         IF v_salut = 0
            -- 9.0  14/06/2010 JGR - 0014186: CRE998 - Modificaciones ... (quitar control edad 0-55 años)
            --   AND v_edad <= 55
            AND v_imc >= pac_parametros.f_parempresa_n(1, 'IMC_MIN')
            AND v_imc <= pac_parametros.f_parempresa_n(1, 'IMC_MAX') THEN
            RETURN 0;   -- Proposta NO Retinguda
         ELSE
            RETURN 1;   -- Proposta AMB Telesubscripció
         END IF;
      ELSIF v_tramo = 2 THEN   -- v_capital >= 120000 AND v_capital < 300000 -- Bug 14186 - 20/04/2010 - JGR
         RETURN 1;   -- Proposta AMB Telesubscripció
      ELSE
         IF v_imc >= pac_parametros.f_parempresa_n(1, 'IMC_MIN')
            AND v_imc <= pac_parametros.f_parempresa_n(1, 'IMC_MAX') THEN
            RETURN 1;   -- Proposta AMB Telesubscripció
         ELSE
            RETURN 2;   -- Proposta Retinguda AMB Telesubscripció i proves adicionals.
         END IF;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Pac_Albsgt_Snv.f_tipus_subscripcio', 1,
                     'ptablas=' || ptablas || ';psseguro=' || psseguro || ';pnriesgo='
                     || pnriesgo,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN NULL;
   END f_tipus_subscripcio;

   --Bug 12682 - 16/02/2010 - MRB - CRE - CVC-PRIVATS
   /*************************************************************************

      Busca les renovacions que s'han fet per poder saber l'anulaitat en la
      que estem.
      Si per exemple torna un 5, indica que s'han fet 3 carteres a més de la
      nova producció, cosa que vol dir que estem dins de la cinquena anualitat.


      param in ptablas   : Identificador fijo de tablas
      param in psseguro  : Identificador fijo de contrato
      param in pnriesgo  : Identificador fijo de riesgo
      param in pfefecto  : Identificador fijo de fecha efecto
      param in pnmovimi  : Identificador fijo de movimiento
      param in cgarant   : Identificador fijo de garantía
      param in psproces  : Identificador fijo de proceso
      param in pnmovima  : Identificador fijo de nmovima
      param in picapital : Identificador fijo de capital
      return             : Number (Torna el nombre de renovacions que s'han fet
   *************************************************************************/
   FUNCTION f_renovacions_fetes(
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
      v_anualitat    NUMBER;
   BEGIN
      SELECT COUNT(*)
        INTO v_anualitat
        FROM movseguro
       WHERE sseguro = psseguro
         AND cmotmov IN(100, 404);

      v_anualitat := v_anualitat + 1;   -- Li sumo 1 per que faci bé, si
                                        -- estic fent una nova cartera.
      RETURN v_anualitat;
   END f_renovacions_fetes;

   FUNCTION f_ageband(
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
      v_edad         NUMBER;
      ntraza         NUMBER := 0;
      nerror         NUMBER := 0;
   BEGIN
      ntraza := 1;
      v_edad := f_edad_riesgo(ptablas, psseguro, pnriesgo, pfefecto, pnmovimi, cgarant,
                              psproces, pnmovima, picapital);

      IF v_edad <= 29 THEN
         RETURN 1;
      ELSIF v_edad <= 39 THEN
         RETURN 2;
      ELSIF v_edad <= 49 THEN
         RETURN 3;
      ELSE
         RETURN 0;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_propio_albsgt_msv', ntraza, 'f_ageband',
                     'psseguro: ' || psseguro);
         RETURN 140999;
   END f_ageband;

   FUNCTION f_edad_aseg(
      ptablas IN VARCHAR2,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pfefecto IN DATE,
      pnmovimi IN NUMBER,
      cgarant IN NUMBER,
      psproces IN NUMBER,
      pnmovima IN NUMBER,
      picapital IN NUMBER,
      plife IN NUMBER DEFAULT 1)
      RETURN NUMBER IS
      v_fnacimi      DATE;
      v_ssegpol      NUMBER;
      v_fefecto      DATE;
      v_fecha        DATE;
      v_edad         NUMBER;
      v_fcaranu      DATE;
      num_err        NUMBER;
      -- Bug 10539 - RSC - 25/06/2009 - Pólizas con error en el cálculo de la edad
      n_retafrac     NUMBER(1);
      v_cursor       NUMBER;
      ss             VARCHAR2(3000);
      funcion        VARCHAR2(40);
      v_filas        NUMBER;
      p_sproduc      seguros.sproduc%TYPE;
   -- Fin Bug 10539
   BEGIN
      IF ptablas = 'EST' THEN
         -- Estamos en nueva produccion o suplementos
         -- Es la fecha efecto del riesgo, tanto para nueva producción como para suplementos
         BEGIN
            -- Añadimos: , s.fcaranu
            SELECT fnacimi, ssegpol, r.ffecini, s.fcaranu
              INTO v_fnacimi, v_ssegpol, v_fefecto, v_fcaranu
              FROM estassegurats r, estper_personas p, estseguros s
             WHERE r.sseguro = psseguro
               AND s.sseguro = r.sseguro
               AND r.sperson = p.sperson
               AND r.nriesgo = pnriesgo
               AND r.norden = plife;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN NULL;
         END;

         IF pfefecto = v_fcaranu THEN
            v_fecha := pfefecto;
         ELSE
            -- Fin Bug 11664
            BEGIN
               SELECT MAX(fefecto)
                 INTO v_fecha
                 FROM movseguro
                WHERE sseguro = v_ssegpol
                  AND cmovseg = 2;

               IF (v_fecha IS NULL)
                  OR(v_fecha < v_fefecto) THEN
                  v_fecha := v_fefecto;
               END IF;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  v_fecha := v_fefecto;
            END;
         END IF;

         num_err := f_difdata(v_fnacimi, v_fecha, 1, 1, v_edad);
      ELSE
         -- Bug 10539 - RSC - 25/06/2009 - Pólizas con error en el cálculo de la edad
         SELECT sproduc
           INTO p_sproduc
           FROM seguros
          WHERE sseguro = psseguro;

         -- Estamos cartera
         BEGIN
            --Bug10612 - 08/07/2009 - DCT (canviar vista personas)
            SELECT p.fnacimi, r.ffecini, s.fcaranu
              INTO v_fnacimi, v_fefecto, v_fcaranu
              FROM asegurados r, per_personas p, seguros s
             WHERE r.sseguro = psseguro
               AND s.sseguro = r.sseguro
               AND r.sperson = p.sperson
               AND r.nriesgo = pnriesgo
               AND r.norden = plife;
         --Bug10612 - 08/07/2009 - DCT (canviar vista personas)
         EXCEPTION
            WHEN OTHERS THEN
               RETURN NULL;
         END;

         -- Bug 10539 - RSC - 25/06/2009 - Pólizas con error en el cálculo de la edad
         IF NVL(f_parproductos_v(p_sproduc, 'FRACCIONARIO'), 0) = 1 THEN
            SELECT MAX(tvalpar)
              INTO funcion
              FROM detparpro
             WHERE cparpro = 'F_PRFRACCIONARIAS'
               AND cidioma = 2
               AND cvalpar = (SELECT cvalpar
                                FROM parproductos
                               WHERE sproduc = p_sproduc
                                 AND cparpro = 'F_PRFRACCIONARIAS');

            IF funcion IS NOT NULL THEN
               ss := 'begin :n_retafrac := ' || funcion || '; end;';

               IF DBMS_SQL.is_open(v_cursor) THEN
                  DBMS_SQL.close_cursor(v_cursor);
               END IF;

               v_cursor := DBMS_SQL.open_cursor;
               DBMS_SQL.parse(v_cursor, ss, DBMS_SQL.native);

               IF INSTR(ss, ':psseguro') > 0 THEN
                  DBMS_SQL.bind_variable(v_cursor, ':psseguro', psseguro);
               END IF;

               IF INSTR(ss, ':pfecha') > 0 THEN
                  DBMS_SQL.bind_variable(v_cursor, ':pfecha', pfefecto);
               END IF;

               IF INSTR(ss, ':n_retafrac') > 0 THEN
                  DBMS_SQL.bind_variable(v_cursor, ':n_retafrac', num_err);
               END IF;

               v_filas := DBMS_SQL.EXECUTE(v_cursor);
               DBMS_SQL.variable_value(v_cursor, 'n_retafrac', n_retafrac);

               IF DBMS_SQL.is_open(v_cursor) THEN
                  DBMS_SQL.close_cursor(v_cursor);
               END IF;
            END IF;
         END IF;

         IF (pfefecto = v_fcaranu
             AND n_retafrac IS NULL)
            OR n_retafrac = 1 THEN
            -- si es cartera utilizamos la fecha de efecto (que será la fcaranu de la póliza)
            v_fecha := pfefecto;
         ELSE
            BEGIN
               SELECT MAX(fefecto)
                 INTO v_fecha
                 FROM movseguro
                WHERE sseguro = psseguro
                  AND cmovseg = 2;

               IF (v_fecha IS NULL)
                  OR(v_fecha < v_fefecto) THEN
                  v_fecha := v_fefecto;
               END IF;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  v_fecha := v_fefecto;
            END;
         END IF;

         num_err := f_difdata(v_fnacimi, v_fecha, 1, 1, v_edad);
      END IF;

      RETURN v_edad;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_edad_aseg;

   FUNCTION f_imc2(
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
      -- Calculamos el Índice de masa corporal --
      vimc           NUMBER;
      vresp7         NUMBER;
      vresp8         NUMBER;
   BEGIN
      IF ptablas = 'EST' THEN
         -- Buscamos la preguna de ALTURA (en centímetros)
         BEGIN
            SELECT e.crespue
              INTO vresp7
              FROM estpregunseg e
             WHERE e.sseguro = psseguro
               AND e.nmovimi = pnmovimi
               AND e.cpregun = 77
               AND e.nriesgo = pnriesgo;
         EXCEPTION
            WHEN OTHERS THEN
               vresp7 := 0;
         END;

         -- Buscamos la pregunta del peso (en kilos)
         BEGIN
            SELECT e.crespue
              INTO vresp8
              FROM estpregunseg e
             WHERE e.sseguro = psseguro
               AND e.nmovimi = pnmovimi
               AND e.cpregun = 88
               AND e.nriesgo = pnriesgo;
         EXCEPTION
            WHEN OTHERS THEN
               vresp8 := 0;
         END;
      ELSE
         -- Bug 9907 - 27/04/2009 - JRH - Inclusión de preguntas de comisión y gastos en Productos de baja
         BEGIN
            SELECT e.crespue
              INTO vresp7
              FROM pregunseg e
             WHERE e.sseguro = psseguro
               AND e.nmovimi = pnmovimi
               AND e.cpregun = 77
               AND e.nriesgo = pnriesgo;
         EXCEPTION
            WHEN OTHERS THEN
               vresp7 := 0;
         END;

         -- Buscamos la pregunta del peso (en kilos)
         BEGIN
            SELECT e.crespue
              INTO vresp8
              FROM pregunseg e
             WHERE e.sseguro = psseguro
               AND e.nmovimi = pnmovimi
               AND e.cpregun = 88
               AND e.nriesgo = pnriesgo;
         EXCEPTION
            WHEN OTHERS THEN
               vresp8 := 0;
         END;
      END IF;

      vimc := ROUND(vresp8 / POWER((vresp7 / 100), 2), 2);
      RETURN vimc;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 0;
   END f_imc2;
END pac_albsgt_generico;

/

  GRANT EXECUTE ON "AXIS"."PAC_ALBSGT_GENERICO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_ALBSGT_GENERICO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_ALBSGT_GENERICO" TO "PROGRAMADORESCSI";
