create or replace PACKAGE BODY pk_formulas IS
-- --------------------------------------------------------------------
-- Detecta tokens en una cadena
 /******************************************************************************
      NOMBRE:     PAC_PARM_TARIFAS
      PROPÓSITO:  Funciones de parámetros de tarificación

      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.0        XX/XX/XXXX   XXX                1. Creación del package.
      2.0        22/02/2012    APD               2. 0021121: MDP701 - TEC - DETALLE DE PRIMAS DE GARANTIAS
   ******************************************************************************/
-- --------------------------------------------------------------------
   FUNCTION search_string(
      s IN OUT VARCHAR2,
      modo IN VARCHAR2,
      numsesion IN NUMBER,
      numsesion_1 IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      car            VARCHAR2(1);
      r              NUMBER;
      ts             VARCHAR2(2000);
      pder           NUMBER := 0;
      pizq           NUMBER := 0;
      i              INTEGER;
      ii             INTEGER;
      k              INTEGER;
      ind            INTEGER := 0;
      token          VARCHAR2(40);
      sust           VARCHAR2(20);
   BEGIN
      ts := RTRIM(s);
      s := ts;
      ts := UPPER(ts) || ';;';

      FOR i IN 1 .. errs LOOP
         terrs(i) := NULL;
      END LOOP;

      errs := 0;
      i := 1;
      ii := 1;
      token := NULL;

      WHILE i < LENGTH(ts) LOOP
         car := SUBSTR(ts, i, 1);

         IF car IN(' ', '+', '-', '*', '/', '(', ')', ',', ';', CHR(9), CHR(10)) THEN
            ind := 0;

            IF car = '(' THEN
               pder := pder + 1;
            END IF;

            IF car = ')' THEN
               pizq := pizq + 1;
            END IF;

            IF modo = 'E' THEN
               r := analiz_token(token, numsesion, numsesion_1);

               IF r = 1 THEN   -- Funci?n usuario
                  s := SUBSTR(s, 1, ii) || ':NSESSION' || ', ' || SUBSTR(s, ii + 1);
                  ii := ii + 2 + LENGTH(':NSESSION');
               ELSIF r = 2 THEN   -- Sinonimo
                  -- Bug 21121 - APD - 22/02/2012 - han de funcionar los sinónimos
                  s := SUBSTR(s, 1, ii - LENGTH(token) - 1) || sinonim || SUBSTR(s, ii);
                  ii := ii + LENGTH(sinonim) - LENGTH(token);
                  s := SUBSTR(s, 1, ii) || ':NSESSION' || ', ' || SUBSTR(s, ii + 1);
                  ii := ii + 2 + LENGTH(':NSESSION');
               -- Fi Bug 21121 - APD - 22/02/2012
               END IF;
            ELSE
               verifica_token(token);
            END IF;

            token := NULL;
         ELSE
            IF ind = 0 THEN
               NULL;
            END IF;

            ind := 1;
            token := token || car;

            IF car = '"' THEN
               FOR j IN i + 1 .. LENGTH(ts) LOOP
                  car := SUBSTR(ts, i, 1);

                  IF car = '"' THEN
                     token := token || '''';
                  ELSE
                     token := token || car;
                  END IF;

                  --ltoken := ltoken + 1;
                  IF car = '"' THEN
                     EXIT;
                  END IF;
               END LOOP;
            END IF;
         END IF;

         i := i + 1;
         ii := ii + 1;
      END LOOP;

      IF pder != pizq THEN
         errs := errs + 1;
         terrs(errs) := TO_CHAR(ABS(pder - pizq)) || ' () no emparejados';
      END IF;

      RETURN errs;
   END search_string;

-- --------------------------------------------------------------------
-- Analiza el ultimo token detectado
-- --------------------------------------------------------------------
   FUNCTION analiz_token(
      token IN VARCHAR2,
      numsesion IN NUMBER,
      numsesion_1 IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      valtok         NUMBER;
      origen         NUMBER;
      ctermino       VARCHAR2(40);
      term2          VARCHAR2(40);
      tipo           VARCHAR2(1);
      tipotoken      NUMBER := 0;
      tabla          VARCHAR2(30);
      valor          NUMBER;
      num            NUMBER;
      ftope          DATE;
      v_valor        VARCHAR2(4000);
      v_valor_i      NUMBER;
      valor_i        NUMBER;
      niterac        NUMBER;
      v_operacion    VARCHAR2(2);
      x              VARCHAR2(1000);
      retorno        NUMBER;
      vcrastro       sgt_formulas.crastro%TYPE := 0;
      v_cursor       INTEGER;
      v_filas        NUMBER;
      -- JLB - I
      vnerror        NUMBER;
   -- JLB - F
   BEGIN
      ctermino := token;
      term2 := NULL;
      num := NULL;

      BEGIN
         --  SELECT TO_DATE(valor, 'yyyymmdd')
         --    INTO ftope
         --    FROM sgt_parms_transitorios
         --   WHERE sesion = numsesion
         --     AND parametro = 'FECEFE';
         ftope := TO_DATE(pac_sgt.get(numsesion, 'FECEFE'), 'yyyymmdd');
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            ftope := f_sysdate;
      END;

      -- JLB -F
      BEGIN
         num := TO_NUMBER(ctermino);
      EXCEPTION
         WHEN OTHERS THEN
            num := -999999999;
      END;

      IF num = -999999999
         AND SUBSTR(ctermino, 1, 1) != '"' THEN
         BEGIN
            SELECT tipo, origen
              INTO tipo, origen
              FROM sgt_term_form
             WHERE termino = ctermino;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               tipo := NULL;
               origen := -999999999;
         END;

         BEGIN
            SELECT UPPER(nomtab)
              INTO tabla
              FROM sgt_tablas
             WHERE numtab = origen;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               tabla := NULL;
         END;

         IF tipo = 'S' THEN   -- Es un sinonimo
            BEGIN
               SELECT sinonimo
                 INTO sinonim
                 FROM sgt_sinonimos
                WHERE termino = ctermino;

               ctermino := sinonim;
               tipo := 'F';
               tipotoken := 2;
            EXCEPTION
               WHEN OTHERS THEN
                  NULL;
            END;
         END IF;

         IF tipo = 'T' THEN   -- Es una Tabla
            valor := get_val_tabla(numsesion, tabla, ctermino);
         ELSIF tipo = 'P' THEN   -- Es un Parametro
            IF tabla = 'SGT_PARM_FORMULAS' THEN
               BEGIN
                  SELECT valor
                    INTO valor
                    FROM sgt_parm_formulas
                   WHERE prm_r_agc = 0
                     AND codigo = ctermino
                     AND fecha_efecto = (SELECT MAX(fecha_efecto)
                                           FROM sgt_parm_formulas
                                          WHERE prm_r_agc = 0
                                            AND codigo = ctermino
                                            AND fecha_efecto <= ftope);
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     valor := NULL;
               END;
            ELSIF ctermino = 'SESION' THEN
               valor := numsesion;
            END IF;
         ELSIF tipo = 'F' THEN   -- Es una Funci?n
            IF origen = 5 THEN   -- tipo bucle
               DECLARE
                  formula        VARCHAR2(2000);
                  sesion_i       NUMBER;
               BEGIN
                  SELECT niterac, operacion
                    INTO formula, v_operacion
                    FROM sgt_bucles
                   WHERE termino = ctermino;

                  term2 := ctermino;
                  niterac := eval(formula, numsesion, -1, 0);
                  term2 := NULL;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     formula := NULL;
                     niterac := NULL;
               END;

               IF v_operacion = '+' THEN
                  valor := 0;
               ELSE
                  valor := 1;
               END IF;

               FOR i IN 1 .. niterac LOOP
                  DECLARE
                     formula        VARCHAR2(2000);
                     sesion_i       NUMBER;
                  BEGIN
                     SELECT formula, NVL(crastro, 0)
                       INTO formula, vcrastro
                       FROM sgt_formulas
                      WHERE codigo = ctermino;

                     term2 := ctermino;

                     SELECT sgt_sesiones.NEXTVAL
                       INTO sesion_i
                       FROM DUAL;

                      -- JLB - I - OPTIMI
                     -- INSERT INTO sgt_parms_transitorios
                      --            (sesion, parametro, valor)
                      --   SELECT sesion_i, parametro, valor
                      --     FROM sgt_parms_transitorios
                      --    WHERE sesion = numsesion;
                     pac_sgt.v_parms_transitorios(sesion_i) :=
                                                        pac_sgt.v_parms_transitorios(numsesion);
                     -- JLB - F    - OPTIMI
                       -- JLB - I   - OPTIMI
                     --BEGIN
                     --   INSERT INTO sgt_parms_transitorios
                      --              (sesion, parametro, valor)
                      --       VALUES (sesion_i, 'NITERAC', i);
                     vnerror := pac_sgt.put(sesion_i, 'NITERAC', i);
                      --  EXCEPTION
                      --     WHEN DUP_VAL_ON_INDEX THEN
                      --        UPDATE sgt_parms_transitorios
                      --           SET valor = i
                      --         WHERE sesion = sesion_i
                      --           AND parametro = 'NITERAC';
                      --     WHEN OTHERS THEN
                      --        NULL;
                      --  END;
                     -- JLB - F   - OPTIMI
                        --  DBMS_OUTPUT.put_line('EVALUAMOS   ');
                     valor_i := eval(formula, sesion_i, NULL, 0);
                       --, nvl(numsesion_1,numsesion));
                     --  DBMS_OUTPUT.put_line('DESPUES EVAL');
                     pac_gfi.p_grabar_rastro(numsesion, ctermino || '_' || i, valor_i,
                                             vcrastro);
                     term2 := NULL;
                     -- JLB - I
                      --DELETE FROM sgt_parms_transitorios
                      --      WHERE sesion = sesion_i;
                     vnerror := pac_sgt.del(sesion_i);
                  -- JLB - F
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        formula := NULL;
                        valor := NULL;
                  END;

                  x := 'begin select :valor' || v_operacion
                       || ':valor_i into :retorno from dual; end;';

                  IF DBMS_SQL.is_open(v_cursor) THEN
                     DBMS_SQL.close_cursor(v_cursor);
                  END IF;

                  v_cursor := DBMS_SQL.open_cursor;
                  DBMS_SQL.parse(v_cursor, x, DBMS_SQL.native);
                  DBMS_SQL.bind_variable(v_cursor, ':valor', valor);
                  DBMS_SQL.bind_variable(v_cursor, ':valor_i', valor_i);
                  DBMS_SQL.bind_variable(v_cursor, ':retorno', retorno);
                  v_filas := DBMS_SQL.EXECUTE(v_cursor);
                  DBMS_SQL.variable_value(v_cursor, 'retorno', retorno);

                  IF DBMS_SQL.is_open(v_cursor) THEN
                     DBMS_SQL.close_cursor(v_cursor);
                  END IF;

                  valor := retorno;
               END LOOP;
            ELSIF tabla = 'SGT_FORMULAS' THEN
               --BEGIN
               --   SELECT valor
               --     INTO v_valor
               --     FROM sgt_tokens
               --    WHERE sesion = numsesion
               --      AND token = ctermino;
               --EXCEPTION
               --   WHEN OTHERS THEN
               --      v_valor := NULL;
               --END;
               BEGIN
                  v_valor := v_tokens(numsesion)(ctermino);
               EXCEPTION
                  WHEN OTHERS THEN
                     v_valor := NULL;
               END;

               IF v_valor IS NULL THEN
                  DECLARE
                     formula        VARCHAR2(2000);
                     sesion_i       NUMBER;
                  BEGIN
                     SELECT formula, NVL(crastro, 0)
                       INTO formula, vcrastro
                       FROM sgt_formulas
                      WHERE codigo = ctermino;

                     term2 := ctermino;
                     -- DBMS_OUTPUT.put_line('CTERMINO = ' || ctermino);
                     valor := eval(formula, numsesion, -1, 0);
                     term2 := NULL;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        formula := NULL;
                        valor := NULL;
                  END;
               ELSE
                  valor := v_valor;
               END IF;
            ELSIF origen = 2 THEN   -- Argumento Predefinido
               term2 := NULL;

               -- jlb - I - OPTIMI
               BEGIN
                  --     SELECT valor
                  --       INTO valor
                  --       FROM sgt_parms_transitorios
                   --     WHERE sesion = numsesion
                   --       AND parametro = ctermino;
                  valor := pac_sgt.get(numsesion, ctermino);
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     valor := NULL;
               END;
            -- JLB - F  - OPTIMI
            ELSE
               BEGIN
                  SELECT termino
                    INTO term2
                    FROM sgt_term_form
                   WHERE termino = ctermino;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     term2 := NULL;
               END;
            END IF;
         END IF;

         valtok := valor;

         IF term2 = ctermino THEN
            valtok := -999999999;
         END IF;

         --BEGIN
            --  DBMS_OUTPUT.put_line('Trata token ' || ctermino || ' valor =' || valtok);
         IF valtok <> -999999999 THEN
            pac_gfi.p_grabar_rastro(numsesion, ctermino, valtok, vcrastro);
            --INSERT INTO sgt_tokens
            --            (sesion, token, valor)
            --    VALUES (numsesion, ctermino, valtok);
            v_tokens(numsesion)(ctermino) := valtok;

            IF numsesion_1 IS NOT NULL THEN
               --INSERT INTO sgt_tokens
               --            (sesion, token, valor)
               --     VALUES (numsesion_1, ctermino, valtok);
               v_tokens(numsesion_1)(ctermino) := valtok;
            END IF;
         END IF;
      /*EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               UPDATE sgt_tokens
                  SET token = ctermino,
                      valor = valtok
                WHERE sesion = numsesion
                  AND token = ctermino;
            WHEN OTHERS THEN
               NULL;
      END;*/
      END IF;

      IF tipo = 'F'
         AND origen = 3
         -- Bug 21121 - APD - 22/02/2012 - han de funcionar los sinónimos
         AND tipotoken <> 2
                           -- Fi Bug 21121 - APD - 22/02/2012
      THEN   --Funci?n de usuario
         tipotoken := 1;
      END IF;

      RETURN tipotoken;
   END analiz_token;

-- --------------------------------------------------------------------
-- Procedimiento para validar cada token
-- --------------------------------------------------------------------
   PROCEDURE verifica_token(token IN VARCHAR2) IS
      origen         NUMBER;
      ctermino       VARCHAR2(40);
      tipo           VARCHAR2(1);
      num            NUMBER;
   BEGIN
      ctermino := token;
      num := NULL;

      BEGIN
         num := TO_NUMBER(ctermino);
      EXCEPTION
         WHEN VALUE_ERROR THEN
            num := -999999999;
      END;

      IF num = -999999999
         AND SUBSTR(ctermino, 1, 1) != '"' THEN
         BEGIN
            SELECT tipo, origen
              INTO tipo, origen
              FROM sgt_term_form
             WHERE termino = ctermino;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               tipo := NULL;
               origen := -1;
         END;

         IF origen = -1 THEN
            errs := errs + 1;
            terrs(errs) := 'Elemento desconocido: ' || ctermino;
         END IF;
      END IF;
   END verifica_token;

-- --------------------------------------------------------------------
-- Procedimiento que vuelca en el buffer de salida la tabla de tokens
-- --------------------------------------------------------------------
   PROCEDURE print_toks(numsesion IN NUMBER) IS
      --CURSOR toks IS
      --   SELECT   token, valor
      --       FROM sgt_tokens
      --      WHERE sesion = numsesion
      --   ORDER BY LENGTH(token) DESC;
      vtoken         VARCHAR2(40);
   BEGIN
      FOR i IN 1 .. errs LOOP
         NULL;
      END LOOP;

      --FOR tok IN toks LOOP
      --   IF tok.token IS NOT NULL THEN
      --      IF tok.valor != -999999999 THEN
      --         NULL;
      --      END IF;
      --   END IF;
      --END LOOP;
      vtoken := v_tokens(numsesion).FIRST;

      LOOP
         EXIT WHEN vtoken IS NULL;

         IF v_tokens(numsesion)(vtoken) != -999999999 THEN
            NULL;
         END IF;

         vtoken := v_tokens(numsesion).NEXT(vtoken);
      END LOOP;
   END print_toks;

-- --------------------------------------------------------------------
-- Funcion que evalua la formula
-- --------------------------------------------------------------------
   FUNCTION eval(
      formula IN OUT VARCHAR2,
      numsesion IN NUMBER,
      numsesion_1 IN NUMBER DEFAULT NULL,
      praiz IN NUMBER DEFAULT 1)
      RETURN NUMBER IS
      s              VARCHAR2(2000) := UPPER(formula);
      xfunc          VARCHAR2(2000);
      xclave         NUMBER;
      ncursor        INTEGER;
      filas          INTEGER;
      retorno        NUMBER;
      e              NUMBER;
      xuser          VARCHAR2(100);
      v_cursor       INTEGER;
      v_filas        NUMBER;
      v_nulo         VARCHAR2(1);
      v_posicion     NUMBER;
      v_replace      BOOLEAN;
      vtoken         VARCHAR2(40);
      vtraza         NUMBER;
   --CURSOR toks IS
   --   SELECT   token, valor, sesion
   --       FROM sgt_tokens
   --      WHERE sesion = numsesion
   --   ORDER BY LENGTH(token) DESC;
   BEGIN
      p_control_error('JAMF', 'PK_FORMULAS.eval',
                      'Entra con parámetros formula=' || formula || ' numsesion=' || numsesion);
      vtraza := 0;

      -- DBMS_SESSION.set_nls ('nls_numeric_characters', '''.,''');
      --DBMS_OUTPUT.put_line(SUBSTR('Entra Eval con: ' || formula, 1, 255));
      BEGIN
         IF pac_gfi.f_sgt_parms('DEBUG', numsesion) = 2 THEN
            RAISE NO_DATA_FOUND;
         END IF;

         SELECT cformula, cclave
           INTO xfunc, xclave
           FROM gfi_funciones
          WHERE cformula IN(SELECT codigo
                              FROM sgt_formulas
                             WHERE UPPER(formula) = s)
            AND refresca = 0;

         p_control_error('JAMF', 'PK_FORMULAS.eval',
                         'Tras selects gfi_funciones xfunc=' || xfunc || ' xclave=' || xclave);
         -- No est? desactualizada
         xuser := f_parinstalacion_t('USER_GFI');

         IF xuser IS NOT NULL THEN
            xuser := xuser || '.';
         END IF;

         vtraza := 10;

         IF LENGTH(xfunc) > 25 THEN
            -- No se pueden crear funciones con nombres de m?s de 30 caracteres
            s := xuser || 'fgfi_' || xclave || '(' || numsesion || ')';
         ELSE
            s := xuser || 'fgfi_' || xfunc || '(' || numsesion || ')';
         END IF;

         vtraza := 15;
      EXCEPTION
         WHEN NO_DATA_FOUND OR TOO_MANY_ROWS THEN
            p_control_error('JAMF', 'PK_FORMULAS.eval',
                            'Tras selects NO_DATA_FOUND OR TOO_MANY_ROWS e=' || e);
            e := search_string(s, 'E', numsesion, numsesion_1);
            s := REPLACE(s, '"', '''');

            IF v_tokens.EXISTS(numsesion) THEN
               IF v_tokens(numsesion).COUNT > 0 THEN
                  vtoken := v_tokens(numsesion).FIRST;

                  LOOP
                     EXIT WHEN vtoken IS NULL;
                     p_control_error('JAMF', 'PK_FORMULAS.eval',
                                     SUBSTR('Dentro bucle tokens s_1= ' || s, 1, 200));
                     p_control_error('JAMF', 'PK_FORMULAS.eval',
                                     SUBSTR('Dentro bucle tokens s_2= ' || s, 200, 200));
                     --FOR tok IN toks LOOP
                     v_posicion := NULL;
                     v_replace := NULL;

                     IF INSTR(s, vtoken) > 0 THEN
                        LOOP
                           v_posicion := NVL(v_posicion - 1, 0)
                                         + INSTR(SUBSTR(s, NVL(v_posicion, 0)), vtoken);
                           vtraza := 100;

                           IF v_posicion = 1 THEN
                              v_replace := TRUE;
                           ELSE
                              IF SUBSTR(s, v_posicion - 1, 1) IN
                                    (' ',
                                     '+',
                                     '-',
                                     '*',
                                     '/',
                                     '(',
                                     ')',
                                     ',',
                                     ';',
                                     CHR(9),
                                     CHR(10)) THEN
                                 v_replace := TRUE;
                              ELSE
                                 v_replace := FALSE;
                              END IF;
                           END IF;

                           vtraza := 105;

                           IF v_replace THEN
                              IF v_posicion + LENGTH(vtoken) - 1 = LENGTH(s) THEN
                                 v_replace := TRUE;
                              ELSE
                                 IF SUBSTR(s, v_posicion + LENGTH(vtoken), 1) IN
                                       (' ',
                                        '+',
                                        '-',
                                        '*',
                                        '/',
                                        '(',
                                        ')',
                                        ',',
                                        ';',
                                        CHR(9),
                                        CHR(10)) THEN
                                    v_replace := TRUE;
                                 ELSE
                                    v_replace := FALSE;
                                 END IF;
                              END IF;
                           END IF;

                           vtraza := 110;

                           IF v_replace THEN
                              s := SUBSTR(s, 1, v_posicion - 1) || ':' || vtoken
                                   || SUBSTR(s, v_posicion + LENGTH(vtoken));
                           END IF;

                           IF NOT(NVL(INSTR(SUBSTR(s, v_posicion + LENGTH(vtoken)), vtoken), 0) >
                                                                                              0) THEN
                              p_control_error('JAMF', 'PK_FORMULAS.eval',
                                              'Sale de forma natural del segudo LOOP s=' || s);
                              EXIT;
                           END IF;

                           v_posicion := v_posicion + LENGTH(vtoken);
                        END LOOP;
                     END IF;

                     --END LOOP;
                     vtoken := v_tokens(numsesion).NEXT(vtoken);
                  END LOOP;
               END IF;
            END IF;

            vtraza := 115;
            formula := s;
            p_control_error('JAMF', 'PK_FORMULAS.eval',
                            'Termina los LOOP y formula=' || formula);

            BEGIN
               s := 'begin :RETORNO := ' || formula || ' ; end;';

               IF DBMS_SQL.is_open(v_cursor) THEN
                  DBMS_SQL.close_cursor(v_cursor);
               END IF;

               v_cursor := DBMS_SQL.open_cursor;
               DBMS_SQL.parse(v_cursor, s, DBMS_SQL.native);

               IF INSTR(s, ':NSESSION') > 0 THEN
                  DBMS_SQL.bind_variable(v_cursor, ':NSESSION', numsesion);
               END IF;

               IF INSTR(s, ':RETORNO') > 0 THEN
                  DBMS_SQL.bind_variable(v_cursor, ':RETORNO', numsesion);
               END IF;

               vtraza := 120;
               p_control_error('JAMF', 'PK_FORMULAS.eval', 'Antes de IF de tokens');

               IF v_tokens.EXISTS(numsesion) THEN
                  IF v_tokens(numsesion).COUNT > 0 THEN
                     vtoken := v_tokens(numsesion).FIRST;

                     LOOP
                        EXIT WHEN vtoken IS NULL;
                        p_control_error('JAMF', 'PK_FORMULAS.eval',
                                        'Dentro del LOOP tokens s=' || s || ' token='
                                        || vtoken || ' v_tokens(numsesion)(vtoken)='
                                        || v_tokens(numsesion)(vtoken));

                        --FOR tok IN toks LOOP
                           -- DBMS_OUTPUT.put_line ('tok.token: ' || tok.token || ' valor: ' || tok.valor);
                        IF v_tokens(numsesion)(vtoken) IS NOT NULL THEN
                           IF v_tokens(numsesion)(vtoken) = -999999999
                              OR pac_gfi.comprobar_token(vtoken,
                                                         REPLACE(s, ':' || vtoken, vtoken)) <>
                                                                                              1
                                                                                               -- Comprobem que el token sigui sencer
                           THEN
                              p_control_error('JAMF', 'PK_FORMULAS.eval',
                                              'Comprobación de token <> 1');
                              NULL;
                           ELSE
                              p_control_error('JAMF', 'PK_FORMULAS.eval',
                                              'Comprobación de token = 1');
                              DBMS_SQL.bind_variable(v_cursor, ':' || vtoken,
                                                     TO_NUMBER(v_tokens(numsesion)(vtoken)));
                           END IF;
                        ELSE
                           DBMS_SQL.bind_variable(v_cursor, ':' || vtoken, v_nulo);
                        END IF;

                        --END LOOP;
                        vtoken := v_tokens(numsesion).NEXT(vtoken);
                     END LOOP;
                  END IF;
               END IF;

               vtraza := 125;
               p_control_error('JAMF', 'PK_FORMULAS.eval', 'Termina LOOP tokens');
               p_control_error('JAMF', 'PK_FORMULAS.eval',
                               'FVECVEN='
                               || TO_DATE(pac_gfi.f_sgt_parms('FECVEN', numsesion), 'YYYYMMDD'));
               p_control_error('JAMF', 'PK_FORMULAS.eval',
                               'FEFEPOL='
                               || TO_DATE(pac_gfi.f_sgt_parms('FEFEPOL', numsesion),
                                          'YYYYMMDD'));
               p_control_error('JAMF', 'PK_FORMULAS.eval',
                               'FNACIMI='
                               || TO_DATE(pac_gfi.f_sgt_parms('FNACIMI', numsesion),
                                          'YYYYMMDD'));
               p_control_error('JAMF', 'PK_FORMULAS.eval',
                               'SEXO=' || pac_gfi.f_sgt_parms('SEXO', numsesion));
               p_control_error('JAMF', 'PK_FORMULAS.eval',
                               'SPRODUC=' || pac_gfi.f_sgt_parms('SPRODUC', numsesion));
               p_control_error('JAMF', 'PK_FORMULAS.eval',
                               'GASTOS=' || pac_gfi.f_sgt_parms('GASTOS', numsesion));
               p_control_error('JAMF', 'PK_FORMULAS.eval',
                               'Termina LOOP tokens y ejecuta cursor');
               v_filas := DBMS_SQL.EXECUTE(v_cursor);
               DBMS_SQL.variable_value(v_cursor, 'RETORNO', retorno);

               IF DBMS_SQL.is_open(v_cursor) THEN
                  DBMS_SQL.close_cursor(v_cursor);
               END IF;

               IF numsesion_1 IS NULL THEN
                  --Hemos entrado desde fuera o es un sumatorio
                  --DELETE FROM sgt_tokens
                  --      WHERE sesion = numsesion;
                  v_tokens(numsesion).DELETE;
               END IF;
            EXCEPTION
               WHEN OTHERS THEN
                  p_control_error('JAMF', 'PK_FORMULAS.eval', 'Others=' || SQLERRM);
                  vtraza := 140;

                  BEGIN
                     IF DBMS_SQL.is_open(v_cursor) THEN
                        DBMS_SQL.close_cursor(v_cursor);
                     END IF;

                     v_cursor := DBMS_SQL.open_cursor;
                     s := 'BEGIN SELECT ' || formula || ' INTO :RETORNO FROM DUAL; END;';
                     p_control_error('JAMF', 'PK_FORMULAS.eval',
                                     '140 - Antes del parse s=' || s);
                     DBMS_SQL.parse(v_cursor, s, DBMS_SQL.native);

                     IF INSTR(s, ':NSESSION') > 0 THEN
                        DBMS_SQL.bind_variable(v_cursor, ':NSESSION', numsesion);
                     END IF;

                     IF INSTR(s, ':RETORNO') > 0 THEN
                        DBMS_SQL.bind_variable(v_cursor, ':RETORNO', numsesion);
                     END IF;

                     vtraza := 145;

                     IF v_tokens.EXISTS(numsesion) THEN
                        IF v_tokens(numsesion).COUNT > 0 THEN
                           vtoken := v_tokens(numsesion).FIRST;

                           LOOP
                              EXIT WHEN vtoken IS NULL;

                              --FOR tok IN toks LOOP
                              IF v_tokens(numsesion)(vtoken) IS NOT NULL THEN
                                 IF v_tokens(numsesion)(vtoken) = -999999999
                                    OR pac_gfi.comprobar_token(vtoken,
                                                               REPLACE(s, ':' || vtoken,
                                                                       vtoken)) <> 1
                                                                                    -- Comprobem que el token sigui sencer
                                 THEN
                                    NULL;
                                 ELSE
                                    DBMS_SQL.bind_variable
                                                        (v_cursor, ':' || vtoken,
                                                         TO_NUMBER(v_tokens(numsesion)(vtoken)));
                                 END IF;
                              ELSE
                                 DBMS_SQL.bind_variable(v_cursor, ':' || vtoken, v_nulo);
                              END IF;

                              --END LOOP;
                              vtoken := v_tokens(numsesion).NEXT(vtoken);
                           END LOOP;
                        END IF;
                     END IF;

                     vtraza := 150;
                     p_control_error('JAMF', 'PK_FORMULAS.eval',
                                     'Se ejecuta el último cursor s=' || s);
                     v_filas := DBMS_SQL.EXECUTE(v_cursor);
                     DBMS_SQL.variable_value(v_cursor, 'RETORNO', retorno);

                     -- DBMS_OUTPUT.put_line('EXECUTE retorno ' || s || ' = ' || retorno);
                     IF DBMS_SQL.is_open(v_cursor) THEN
                        DBMS_SQL.close_cursor(v_cursor);
                     END IF;

                     IF numsesion_1 IS NULL THEN
                        --Hemos entrado desde fuera o es un sumatorio
                        --DELETE FROM sgt_tokens
                        --      WHERE sesion = numsesion;
                        v_tokens(numsesion).DELETE;
                     END IF;

                     p_control_error('JAMF', 'PK_FORMULAS.eval', 'Sale BIEN del eval');
                  EXCEPTION
                     WHEN OTHERS THEN
                        --p_tab_error(f_sysdate, getuser, 'PK_FORMULAS', vtraza,
                          --          'Error al evaluar la formula', SQLERRM);
                        --p_tab_error(f_sysdate, getuser, 'PK_FORMULAS', NULL, 'formula',
                          --          formula);
                        --p_control_error('JAMF', 'PK_FORMULAS.eval', 'Sale con ERROR del eval');

                        IF DBMS_SQL.is_open(v_cursor) THEN
                           DBMS_SQL.close_cursor(v_cursor);
                        END IF;
                  END;
            END;
         WHEN OTHERS THEN
            p_control_error('JAMF', 'PK_FORMULAS.eval', 'Sale OTHERS NULL');
            NULL;
      --DBMS_OUTPUT.put_line('EVAL error ' || SUBSTR(SQLERRM, 1, 255));
      END;

      IF praiz = 1 THEN
         v_tokens.DELETE;
      END IF;

      IF retorno IS NULL THEN
         NULL;
      --DBMS_OUTPUT.put_line(s);
      END IF;

      RETURN retorno;
   END eval;

-- --------------------------------------------------------------------
-- Funcion que ense?a los errores detectados
-- --------------------------------------------------------------------
   FUNCTION get_terrs(nerr IN NUMBER)
      RETURN VARCHAR2 IS
   BEGIN
      RETURN terrs(nerr);
   END get_terrs;
END pk_formulas;
/