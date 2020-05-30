--------------------------------------------------------
--  DDL for Package Body PK_FORMULAS_ALB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PK_FORMULAS_ALB" IS
-- --------------------------------------------------------------------
-- Detecta tokens en una cadena
-- --------------------------------------------------------------------
   FUNCTION search_string(s IN OUT VARCHAR2, modo IN VARCHAR2, numsesion IN NUMBER)
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
               r := analiz_token(token, numsesion);

               IF r = 1 THEN   -- Función usuario
                  s := SUBSTR(s, 1, ii) || TO_CHAR(numsesion) || ', ' || SUBSTR(s, ii + 1);
                  ii := ii + 2 + LENGTH(TO_CHAR(numsesion));
               ELSIF r = 2 THEN   -- Sinonimo
                  s := SUBSTR(s, 1, ii - LENGTH(token) - 1) || sinonim || SUBSTR(s, ii);
                  ii := ii + LENGTH(sinonim) - LENGTH(token);
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
   FUNCTION analiz_token(token IN VARCHAR2, numsesion IN NUMBER)
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
      vnerror        NUMBER;
   BEGIN
      ctermino := token;
      term2 := NULL;
      num := NULL;

      BEGIN
         -- i - JLB - OPTIMI
          -- SELECT to_date(valor, 'yyyymmdd')
          --   INTO ftope
          --   FROM sgt_parms_transitorios
          --  WHERE sesion = numsesion
          --    AND parametro = 'FECEFE';
         ftope := TO_DATE(pac_sgt.get(numsesion, 'FECEFE'), 'yyyymmdd');
      -- F - JLB - OPTIMI
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            ftope := f_sysdate;
      END;

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
         ELSIF tipo = 'F' THEN   -- Es una Función
            IF tabla = 'SGT_FORMULAS' THEN
               DECLARE
                  formula        VARCHAR2(2000);
                  sesion_i       NUMBER;
               BEGIN
                  SELECT formula
                    INTO formula
                    FROM sgt_formulas
                   WHERE codigo = ctermino;

                  term2 := ctermino;

                  SELECT sgt_sesiones.NEXTVAL
                    INTO sesion_i
                    FROM DUAL;

                    -- JLB - I - OPTIMI
                  -- INSERT INTO sgt_parms_transitorios(sesion, parametro, valor)
                   --                          SELECT sesion_i, parametro, valor
                    --                           FROM sgt_parms_transitorios
                     --                         WHERE sesion = numsesion;
                  pac_sgt.v_parms_transitorios(sesion_i) :=
                                                        pac_sgt.v_parms_transitorios(numsesion);
                  -- JLB - F    - OPTIMI
                  valor := eval(formula, sesion_i);
                  term2 := NULL;
                  -- i - JLB - OPTIMI
                     --DELETE FROM sgt_parms_transitorios
                   --    WHERE sesion = sesion_i;
                  vnerror := pac_sgt.del(sesion_i);
               -- F - JLB - OPTIMI
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     formula := NULL;
                     valor := NULL;
               END;
            ELSIF origen = 2 THEN   -- Argumento Predefinido
               term2 := NULL;

               -- jlb - I - OPTIMI
               BEGIN
                  --  SELECT valor
                  --    INTO valor
                  --    FROM sgt_parms_transitorios
                  --   WHERE sesion = numsesion
                  --     AND parametro = ctermino;
                  valor := pac_sgt.get(numsesion, ctermino);
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     valor := NULL;
               END;
            -- jlb - I - OPTIMI
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

         BEGIN
--   dbms_output.put_line('Trata token '||ctermino);
            IF valtok <> -999999999 THEN
               INSERT INTO sgt_tokens
                           (sesion, token, valor)
                    VALUES (numsesion, ctermino, valtok);
            END IF;
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               UPDATE sgt_tokens
                  SET token = ctermino,
                      valor = valtok
                WHERE sesion = numsesion
                  AND token = ctermino;
            WHEN OTHERS THEN
               --DBMS_OUTPUT.put_line(SQLERRM);
               NULL;
         END;
      END IF;

      IF tipo = 'F'
         AND origen = 3 THEN   --Función de usuario
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
      CURSOR toks IS
         SELECT   token, valor
             FROM sgt_tokens
            WHERE sesion = numsesion
         ORDER BY LENGTH(token) DESC;
   BEGIN
--  dbms_output.put_line('Num. errores='||to_char(errs));
      FOR i IN 1 .. errs LOOP
         --DBMS_OUTPUT.put_line(terrs(i));
         NULL;
      END LOOP;

      FOR tok IN toks LOOP
         IF tok.token IS NOT NULL THEN
            IF tok.valor != -999999999 THEN
               --DBMS_OUTPUT.put_line(RPAD(tok.token, 11) || '= ' || TO_CHAR(tok.valor));
               NULL;
            END IF;
         END IF;
      END LOOP;
   END print_toks;

-- --------------------------------------------------------------------
-- Funcion que evalua la formula
-- --------------------------------------------------------------------
   FUNCTION eval(formula IN OUT VARCHAR2, numsesion IN NUMBER)
      RETURN NUMBER IS
      s              VARCHAR2(2000) := UPPER(formula);
      ncursor        INTEGER;
      filas          INTEGER;
      retorno        NUMBER;
      e              NUMBER;

      CURSOR toks IS
         SELECT   token, valor
             FROM sgt_tokens
            WHERE sesion = numsesion
         ORDER BY LENGTH(token) DESC;
   BEGIN
--  dbms_session.set_nls('nls_numeric_characters', '''.,''');
-- dbms_output.put_line('Entra con: '||formula);
      e := search_string(s, 'E', numsesion);
      s := REPLACE(s, '"', '''');

      FOR tok IN toks LOOP
         IF tok.valor IS NOT NULL THEN
            IF tok.valor = -999999999 THEN
               NULL;
            ELSE
               s := REPLACE(s, tok.token, REPLACE(TO_CHAR(tok.valor), ',', '.'));
            END IF;
         ELSE
            s := REPLACE(s, tok.token, 'NULL');
         END IF;
--p_control_error(null, 'eval', 'LOOP TOKEN: '||TOK.TOKEN || ' VALOR: ' || to_char(tok.valor));
-- dbms_output.put_line('LOOP TOKEN: '||TOK.TOKEN || ' VALOR: ' || to_char(tok.valor));
      END LOOP;

      formula := s;

      BEGIN
         s := 'SELECT ' || s || ' FROM DUAL';
--p_control_error(null, 'eval', 's='||s);
-- dbms_output.put_line(s);
         ncursor := DBMS_SQL.open_cursor;
         DBMS_SQL.parse(ncursor, s, DBMS_SQL.native);
         DBMS_SQL.define_column(ncursor, 1, retorno);
         filas := DBMS_SQL.EXECUTE(ncursor);

         IF DBMS_SQL.fetch_rows(ncursor) > 0 THEN
            -- Obtiene el valor final de toda la epresión
            DBMS_SQL.COLUMN_VALUE(ncursor, 1, retorno);
         END IF;

         DBMS_SQL.close_cursor(ncursor);
      EXCEPTION
         WHEN OTHERS THEN
            DBMS_SQL.close_cursor(ncursor);
      --DBMS_OUTPUT.put_line(SQLERRM);
      END;

      IF retorno IS NULL THEN
         --DBMS_OUTPUT.put_line(s);
         NULL;
      END IF;

--  DELETE FROM sgt_parms_transitorios
--   WHERE sesion = numsesion;
      DELETE FROM sgt_tokens
            WHERE sesion = numsesion;

      RETURN retorno;
   END eval;

-- --------------------------------------------------------------------
-- Funcion que enseña los errores detectados
-- --------------------------------------------------------------------
   FUNCTION get_terrs(nerr IN NUMBER)
      RETURN VARCHAR2 IS
   BEGIN
      RETURN terrs(nerr);
   END get_terrs;
END pk_formulas_alb;

/

  GRANT EXECUTE ON "AXIS"."PK_FORMULAS_ALB" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PK_FORMULAS_ALB" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PK_FORMULAS_ALB" TO "PROGRAMADORESCSI";
