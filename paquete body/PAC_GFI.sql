--------------------------------------------------------
--  DDL for Package Body PAC_GFI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_GFI" IS
/******************************************************************************
   NOMBRE:      PAC_GFI
   PROPÓSITO:   Funciones para el mantenimiento de las Formulas

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0                                       1. Creación del package.
   2.0        18/06/2009   DCT               2. Añadir nuevos métodos y nuevas funciones
                                                para gestionar las formulas.
   3.0        17/07/2009   AMC               3. Bug 10716 - Añadir nuevos métodos y nuevas funciones
                                                para gestionar los terminos.
******************************************************************************/

   -- --------------------------------------------------------------------
-- Mira si el terme comença per un numeric. Retorna una 'v' si es numeric
-- --------------------------------------------------------------------
   FUNCTION f_numeric(pterm IN VARCHAR2)
      RETURN VARCHAR2 IS
      num            NUMBER;
      vnum           VARCHAR2(200);
   BEGIN
      -- CPM 3/10/05: Mirem si el terme comença per un numeric
      BEGIN
         num := TO_NUMBER(SUBSTR(pterm, 1, 1));   --(ctermino);
         vnum := 'v' || pterm;
      EXCEPTION
         WHEN OTHERS THEN
            num := -99;
            vnum := pterm;
      END;

--dbms_output.put_line ('F_numeric:'||vnum);
      RETURN vnum;
   END f_numeric;

   -- --------------------------------------------------------------------
-- Analiza la función detectada
-- --------------------------------------------------------------------
   FUNCTION monta_funcio(
      pterm IN VARCHAR2,
      ptermout OUT VARCHAR2,
      ptermdeclare IN OUT VARCHAR2,
      ptermselec IN OUT VARCHAR2)
      RETURN NUMBER IS
      xformula       VARCHAR2(4000);
      xtipo          NUMBER;
      xcrastro       NUMBER;
   BEGIN
      BEGIN
         SELECT UPPER(formula), NVL(crastro, 0)
           INTO xformula, xcrastro
           FROM sgt_formulas
          WHERE codigo = pterm;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            xformula := pterm;
      END;

      -- Busquem la traducció d'aquest token
      xtipo := busca_token(xformula, ptermdeclare, ptermselec);

--dbms_output.put_line(SUBSTR('Monta_funcio=> '||xformula||', xtipo:'||xtipo||', xcrastro:'||xcrastro,1,250));
      IF xtipo = -1 THEN   -- Tenim una select
         IF comprobar_token(f_numeric(pterm), ptermdeclare) = 0 THEN
            ptermdeclare := ptermdeclare || f_numeric(pterm) || ' NUMBER;' || CHR(10);
         END IF;

         ptermout := 'SELECT ' || xformula || ' INTO ' || f_numeric(pterm) || ' FROM DUAL;'
                     || CHR(10) || comenta || 'Pac_Gfi.p_grabar_rastro (sesion, ''' || pterm
                     || ''', ' || f_numeric(pterm) || ', ' || xcrastro || ');' || CHR(10);
         xtipo := 4;
      -- Hem montat una select. S'ha d'afegir, no substituir
      ELSIF xcrastro <> 0 THEN   -- Deixem rastre
         IF comprobar_token(f_numeric(pterm), ptermdeclare) = 0 THEN
            ptermdeclare := ptermdeclare || f_numeric(pterm) || ' NUMBER;' || CHR(10);
         END IF;

         ptermout := f_numeric(pterm) || ' := ' || xformula || ';' || CHR(10) || comenta
                     || 'Pac_Gfi.p_grabar_rastro (sesion, ''' || pterm || ''', '
                     || f_numeric(pterm) || ', ' || xcrastro || ');' || CHR(10);
         xtipo := 4;
      ELSE
         ptermout := xformula;
      END IF;

      RETURN xtipo;
   END monta_funcio;

   -- --------------------------------------------------------------------
-- Analiza el ultimo token detectado
-- --------------------------------------------------------------------
   FUNCTION monta_token(
      token IN VARCHAR2,
      ptokenout OUT VARCHAR2,
      ptokendeclare IN OUT VARCHAR2,
      ptokenselec IN OUT VARCHAR2)
      RETURN NUMBER IS
      origen         NUMBER;
      ctermino       VARCHAR2(40);
      tipo           VARCHAR2(1);
      tipotoken      NUMBER := 0;
      num            NUMBER;
      aux_opera      NUMBER;
      xopera         VARCHAR2(1);
      aux_vinici     VARCHAR2(1);
      itera_formula  VARCHAR2(200);
      xcrastro       NUMBER;
   BEGIN
      ctermino := token;
      num := NULL;

      --DBMS_OUTPUT.put_line ('CTERMINO =' || ctermino);
      BEGIN
         num := TO_NUMBER(REPLACE(ctermino, '.', ','));   --(ctermino);
      EXCEPTION
         WHEN OTHERS THEN
            num := -999999999;
      END;

      -- Tenim un token per tratar
      IF num = -999999999
         AND SUBSTR(ctermino, 1, 1) != '"' THEN
         -- Mirem que tipo de token tenim
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

         --DBMS_OUTPUT.put_line ('TIPO =' || tipo || ' ORIGEN =' || origen);
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
            ptokenout := NULL;   --get_val_tabla (numsesion, tabla, ctermino);
         ELSIF tipo = 'P' THEN   -- Es un Parametro
            IF origen = 11 THEN   -- 'SGT_PARM_FORMULAS'
               ptokendeclare := ptokendeclare || f_numeric(ctermino) || ' NUMBER;' || CHR(10);
               ptokenout :=
                  'BEGIN ' || CHR(10) || ' SELECT valor INTO ' || f_numeric(ctermino)
                  || '   FROM SGT_PARM_FORMULAS ' || CHR(10) || '  WHERE prm_r_agc = 0 '
                  || '    AND codigo =  ''' || ctermino || CHR(39) || CHR(10)
                  || '    AND fecha_efecto = '
                  || '      (SELECT MAX (fecha_efecto) FROM SGT_PARM_FORMULAS ' || CHR(10)
                  || '       WHERE prm_r_agc = 0 AND codigo = ''' || ctermino || CHR(39)
                  || CHR(10)
                  || '         AND fecha_efecto <= TO_DATE (FECEFE, ''yyyymmdd'')); '
                  || CHR(10) || 'EXCEPTION ' || CHR(10) || ' WHEN NO_DATA_FOUND THEN '
                  || CHR(10) || f_numeric(ctermino) || '     := NULL; ' || CHR(10) || 'END;'
                  || CHR(10) || comenta || 'Pac_Gfi.p_grabar_rastro (sesion, ''' || ctermino
                  || ''', ' || f_numeric(ctermino) || ', 0 );' || CHR(10);
               tipotoken := 5;
            ELSIF ctermino = 'SESION' THEN
               ptokenout := 'SESION';
            END IF;
         ELSIF tipo = 'F' THEN   -- Es una Función
            BEGIN
               SELECT s.clave, NVL(s.crastro, 0)
                 INTO ptokenout, xcrastro
                 FROM gfi_funciones g, sgt_formulas s
                WHERE s.codigo = g.cformula
                  AND g.cformula = ctermino
                  AND g.refresca = 0;   -- Si no està actualitzada, no la cridem
            EXCEPTION
               WHEN OTHERS THEN
                  ptokenout := NULL;
            END;

            IF ptokenout IS NULL THEN   -- No es una funció de SGT
               IF origen = 5 THEN   -- 'Sumatorios
                  BEGIN
                     --DBMS_OUTPUT.put_line ('Entra sumatorio ' || ctermino);
                     SELECT UPPER(niterac), operacion, DECODE(operacion, '+', '0', '1')
                       INTO itera_formula, xopera, aux_vinici
                       FROM sgt_bucles
                      WHERE termino = ctermino;

                     --DBMS_OUTPUT.put_line ('Suma ' || itera_formula);

                     -- Definim el parámetro NBUCLE que guardarà el nombre d'iteracions
                     IF INSTR(ptokendeclare, 'NBUCLE') = 0 THEN
                        ptokendeclare := ptokendeclare || 'NBUCLE NUMBER;' || CHR(10);
                     END IF;

                     tipotoken := monta_funcio(itera_formula, ptokenout, ptokendeclare,
                                               ptokenselec);

                     IF tipotoken = 4 THEN
                        ptokenselec := ptokenselec || ptokenout || CHR(10) || 'NBUCLE := '
                                       || itera_formula || ';' || CHR(10);
                     ELSE
                        ptokenselec := ptokenselec || 'NBUCLE := ' || ptokenout || ';'
                                       || CHR(10);
                     END IF;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        itera_formula := NULL;
                  END;

                  IF itera_formula IS NOT NULL THEN
                     ptokenselec := ptokenselec || ctermino || ' := ' || aux_vinici || ';'
                                    || CHR(10);
                     ptokenselec := ptokenselec || 'FOR NITERAC IN 1 .. NBUCLE LOOP'
                                    || CHR(10);
--DBMS_OUTPUT.put_line ('Loop ' || itera_formula);
                     tipotoken := monta_funcio(ctermino, ptokenout, ptokendeclare,
                                               ptokenselec);
                     ptokendeclare := ptokendeclare || f_numeric(ctermino) || ' NUMBER := '
                                      || aux_vinici || ';' || CHR(10);
                     ptokenselec := ptokenselec || f_numeric(ctermino) || ':= '
                                    || f_numeric(ctermino) || xopera || ptokenout || ';'
                                    || CHR(10) || comenta
                                    || 'Pac_Gfi.p_grabar_rastro (sesion, ''' || ctermino
                                    || '''||''_''||NITERAC, ' || f_numeric(ctermino)
                                    || ', 0);' || CHR(10) || 'END LOOP;' || CHR(10);
                     tipotoken := 9;
                  END IF;
               ELSIF origen = 6
                     AND INSTR(ptokenselec, 'recursivitat') <> 0 THEN   -- Funció recursiva
                  --DBMS_OUTPUT.put_line ('Entra recursivitat 2ona' || ctermino);

                  --            ptokenout := ctermino;
                  -- Comprobamos que la longitud de la función no sea mayor a 30 ('fgfi_' + 25)
                  IF LENGTH(ctermino) > 25 THEN
                     ptokenout := 'fgfi_' || ptokenout || '(sesion, ';
                  ELSE
                     ptokenout := 'fgfi_' || ctermino || '(sesion, ';
                  END IF;

                  tipotoken := 6;
               ELSIF(origen = 6
                     AND INSTR(ptokenselec, 'recursivitat') = 0) THEN   -- Funció recursiva
                  BEGIN
                     --DBMS_OUTPUT.put_line ('Entra recursivitat 1a vegada' || ctermino);
                     SELECT UPPER(niterac)
                       INTO itera_formula
                       FROM sgt_bucles
                      WHERE termino = ctermino;

                     -- Definim el parámetro NVOLTES que guardarà el nombre d'iteracions
                     IF INSTR(ptokendeclare, 'NVOLTES') = 0 THEN
                        ptokendeclare := ptokendeclare || 'NVOLTES NUMBER;' || CHR(10);
                     END IF;

                     tipotoken := monta_funcio(itera_formula, ptokenout, ptokendeclare,
                                               ptokenselec);

                     IF tipotoken <> 4 THEN
                        ptokenselec := ptokenselec || 'NVOLTES := ' || ptokenout || ';'
                                       || CHR(10);
                     ELSE
                        ptokenselec := ptokenselec || ptokenout || CHR(10) || 'NVOLTES := '
                                       || itera_formula || ';' || CHR(10);
                     END IF;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        itera_formula := NULL;
                  END;

                  IF itera_formula IS NOT NULL THEN
                     ptokenselec := '-- recursivitat' || CHR(10) || ptokenselec || ctermino
                                    || ' := XINICI;' || CHR(10);
                     ptokenselec := ptokenselec || 'FOR NRECURS IN 1 .. NVOLTES LOOP'
                                    || CHR(10);
                     tipotoken := monta_funcio(ctermino, ptokenout, ptokendeclare,
                                               ptokenselec);
                     ptokendeclare := ptokendeclare || f_numeric(ctermino) || ' NUMBER ;'
                                      || CHR(10);
                     ptokenselec := ptokenselec || f_numeric(ctermino) || ':= ' || ptokenout
                                    || ';' || CHR(10) || comenta
                                    || 'Pac_Gfi.p_grabar_rastro (sesion, ''' || ctermino
                                    || '''||''_''||XINICI, ' || f_numeric(ctermino) || ', 0);'
                                    || CHR(10) || 'END LOOP;' || CHR(10);
                     tipotoken := 9;
                  END IF;
               ELSIF origen = 1 THEN   --tabla = 'SGT_FORMULAS' THEN
                  tipotoken := monta_funcio(ctermino, ptokenout, ptokendeclare, ptokenselec);

                  IF tipotoken <> 4 THEN
                     -- Protegim les funcions amb parèntesis
                     ptokenout := '(' || ptokenout || ')';
                  END IF;
               ELSIF origen = 2 THEN   -- Argumento Predefinido
                  ptokenout := ctermino;
               ELSE
                  BEGIN
                     SELECT termino, operador
                       INTO ptokenout, aux_opera
                       FROM sgt_term_form
                      WHERE termino = ctermino;

                     IF NVL(aux_opera, 1) = 0 THEN
                        tipotoken := 3;   -- Montarem una select
                     ELSE
                        tipotoken := 9;
                     -- No tenim que fer res doncs és un operador
                     END IF;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        ptokenout := NULL;
                  END;
               END IF;
            ELSIF origen = 6 THEN
               -- Comprobamos que la longitud de la función no sea mayor a 30 ('fgfi_' + 25)
               IF LENGTH(ctermino) > 25 THEN
                  ptokenout := 'fgfi_' || ptokenout || '(sesion, ';
               ELSE
                  ptokenout := 'fgfi_' || ctermino || '(sesion, ';
               END IF;

               tipotoken := 6;
            ELSE
               ptokendeclare := ptokendeclare || f_numeric(ctermino) || ' NUMBER;' || CHR(10);

               -- Comprobamos que la longitud de la función no sea mayor a 30 ('fgfi_' + 25)
               IF LENGTH(f_numeric(ctermino)) > 25 THEN
                  ptokenout := '-- ' || ctermino || ' con clave ' || ptokenout || CHR(10)
                               || f_numeric(ctermino) || ' := fgfi_' || ptokenout
                               || '(SESION);' || CHR(10) || comenta
                               || 'Pac_Gfi.p_grabar_rastro (sesion, ''' || ctermino || ''', '
                               || f_numeric(ctermino) || ', ' || xcrastro || ');' || CHR(10);
               ELSE
                  ptokenout := f_numeric(ctermino) || ' := fgfi_' || ctermino || '(SESION);'
                               || CHR(10) || comenta || 'Pac_Gfi.p_grabar_rastro (sesion, '''
                               || ctermino || ''', ' || f_numeric(ctermino) || ', '
                               || xcrastro || ');' || CHR(10);
               END IF;

               tipotoken := 4;
            -- Hem trobat una funció. S'ha d'afegir, no substituir
            END IF;
         ELSE   -- No hem trobat tipo.
            ptokenout := ctermino;
            tipotoken := 9;   -- Es un numéric
         END IF;
      ELSE   -- Tenim un token numéric
         ptokenout := ctermino;
         tipotoken := 9;   -- Es un numéric
      END IF;

      IF tipo = 'F'
         AND origen = 3 THEN   --Función de usuario
         tipotoken := 1;
      END IF;

      RETURN tipotoken;
   END monta_token;

-- --------------------------------------------------------------------
-- Detecta tokens en una cadena
-- --------------------------------------------------------------------
   FUNCTION busca_token(s IN OUT VARCHAR2, pdeclare IN OUT VARCHAR2, pselec IN OUT VARCHAR2)
      RETURN NUMBER IS
      car            VARCHAR2(1);
      r              VARCHAR2(32000);
      ts             VARCHAR2(32000);
      pder           NUMBER := 0;
      pizq           NUMBER := 0;
      i              INTEGER;
      ii             INTEGER;
      ind            INTEGER := 0;
      token          VARCHAR2(40);
      aux_cadena     VARCHAR2(5000);
      aux_selec      NUMBER := 0;
      aux_repe       NUMBER;
      aux_decla      VARCHAR2(5000);   -- Utilitzades per controlar els bucles
      aux_text       VARCHAR2(5000);
   BEGIN
      ts := RTRIM(s);
      s := ts;
      ts := UPPER(ts) || ';;';

--DBMS_OUTPUT.put_line ('Entro en busca: ' || SUBSTR (ts, 1, 230));
--dbms_output.put_line('longitud '||LENGTH(pdeclare)||', '||LENGTH(pselec));
      FOR i IN 1 .. errs LOOP
         terrs(i) := NULL;
      END LOOP;

      errs := 0;
      i := 1;
      ii := 1;
      token := NULL;

      WHILE i < LENGTH(ts) LOOP
         car := SUBSTR(ts, i, 1);

         IF car IN(' ', '+', '-', '*', '/', '(', ')', ',', ';', '|', CHR(9), CHR(10)) THEN
            ind := 0;

            IF car = '(' THEN
               pder := pder + 1;
            END IF;

            IF car = ')' THEN
               pizq := pizq + 1;
            END IF;

            IF comprobar_token(f_numeric(token), pdeclare) = 0 THEN
               r := monta_token(token, aux_cadena, pdeclare, pselec);

--dbms_output.put_line(SUBSTR('BUSCA token:'||token||',tipo:'||r||',pos:'||ii||',i:'||i||'->'||SUBSTR(s,1,ii) , 1,250));
               IF r = 1 THEN   -- Función usuario
                  s := SUBSTR(s, 1, ii) || 'sesion' || ', ' || SUBSTR(s, ii + 1);
                  ii := ii + 2 + LENGTH('sesion');
--dbms_output.put_line (SUBSTR('replaco sesio:'||s,1,125));
                  s := REPLACE(s, token, aux_cadena);
               ELSIF r = 2 THEN   -- Sinonimo
                  s := SUBSTR(s, 1, ii - LENGTH(token) - 1) || sinonim || SUBSTR(s, ii);
                  ii := ii + LENGTH(sinonim) - LENGTH(token);
                  s := REPLACE(s, token, aux_cadena);
               ELSIF r = 3 THEN   -- Tenim una select
                  aux_selec := 1;
               ELSIF r = 4 THEN   -- Afegim la select o la funció
                  pselec := pselec || aux_cadena;

                  -- Mirem si hem d'afegir una 'v'
                  IF INSTR(s, f_numeric(token)) = 0 THEN
--dbms_output.put_line('canvi:'||token||'-'||f_numeric(token));
                     s := REPLACE(s, token, f_numeric(token));
                     ii := ii + 1;
                  END IF;
               ELSIF r = 5 THEN   -- Afegim arguments calculats
                  pselec := aux_cadena || pselec;

                  -- Mirem si hem d'afegir una 'v'
                  IF INSTR(s, f_numeric(token)) = 0 THEN
--dbms_output.put_line('canvi2:'||token||'-'||f_numeric(token));
                     s := REPLACE(s, token, f_numeric(token));
                     ii := ii + 1;
                  END IF;
               ELSIF r = 6 THEN
                  s := REPLACE(s, token || '(', aux_cadena);
                  ii := ii + LENGTH(aux_cadena) - LENGTH(token) - 1;
               ELSIF r = 9 THEN   -- Es un numeric o un operador o un sumatorio
                  s := REPLACE(s, '"', CHR(39));
               ELSE
                  -- Mirem si el token apareix més d'una vegada.
                  SELECT INSTR(s, token, 1, 2)
                    INTO aux_repe
                    FROM DUAL;

--dbms_output.put_line ('r='||r||', Repe='||aux_repe);
                  IF aux_repe <> 0
                     AND token <> aux_cadena THEN   -- Tenim el token més d'una vegada
                     pdeclare := pdeclare || f_numeric(token) || ' NUMBER;' || CHR(10);
                     pselec := pselec || f_numeric(token) || ' := ' || aux_cadena || ';'
                               || CHR(10) || comenta || 'Pac_Gfi.p_grabar_rastro (sesion, '''
                               || token || ''', ' || f_numeric(token) || ', 0);' || CHR(10);
                  ELSE
--dbms_output.put_line ('entro replace');
                     s := REPLACE(s, token, aux_cadena);
                     ii := ii + LENGTH(aux_cadena) - LENGTH(token);
                  END IF;
               END IF;
            ELSE
           -- Ja tenim declarada la varible
--dbms_output.put_line ('entro en v');
               IF INSTR(s, f_numeric(token)) = 0 THEN
                  -- Tenim el token definit però falta substituir-lo
                  s := REPLACE(s, token, f_numeric(token));
                  ii := ii + 1;
               ELSIF f_numeric(token) <> token THEN
                  -- Tenim el token substituit per lo que tenim que contar una 'v' més
                  ii := ii + 1;
               END IF;
            END IF;

--dbms_output.put_line(SUBSTR('FI BUSCA token '||token||' pos '||ii||' -> '||SUBSTR(s,ii) , 1,250));
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
                     token := token || CHR(39);
                  ELSE
                     token := token || car;
                  END IF;

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
         RETURN errs;
      ELSE
         IF aux_selec = 1 THEN
            RETURN(-1);   -- Tenim una select, no una funció
         ELSE
            RETURN(0);
         END IF;
      END IF;
   END busca_token;

-- --------------------------------------------------------------------
-- Funcion que monta los parámetros
-- --------------------------------------------------------------------
   FUNCTION busca_parametros(
      pformula IN VARCHAR2,
      pdeclare IN OUT VARCHAR2,
      pselec IN OUT VARCHAR2)
      RETURN NUMBER IS
      retorno        NUMBER := 0;

      CURSOR c_decla IS
         SELECT parametro
           FROM sgt_trans_formula
          WHERE clave IN(SELECT clave
                           FROM sgt_formulas
                          WHERE codigo = UPPER(pformula));
   BEGIN
      --DBMS_OUTPUT.put_line ('Entra busca_parametros con: ' || SUBSTR(pformula,1,200));
      FOR reg_decla IN c_decla LOOP
         pdeclare := pdeclare || reg_decla.parametro || ' NUMBER;' || CHR(10);
         pselec := pselec || reg_decla.parametro || ':= pac_GFI.f_sgt_parms ('''
                   || reg_decla.parametro || ''', sesion);' || CHR(10);
         retorno := 1;
      END LOOP;

      RETURN retorno;
   END busca_parametros;

-- --------------------------------------------------------------------
-- Funcion que evalua la formula
-- --------------------------------------------------------------------
   FUNCTION f_crea_func(pformula IN VARCHAR2, pcomenta IN NUMBER DEFAULT 1)
      RETURN NUMBER IS
      s              VARCHAR2(32000) := UPPER(pformula);
      retorno        NUMBER;
      xdeclare       VARCHAR2(32767) := ' ' || CHR(10);
      xselec         VARCHAR2(32767) := ' ' || CHR(10);
      xselec2        VARCHAR2(32767) := ' ' || CHR(10);
      xtfunc         VARCHAR2(32767);
      aux_form       VARCHAR2(25);
      xuser          VARCHAR2(100);
      xparam         VARCHAR2(500);
   BEGIN
      --DBMS_OUTPUT.put_line ('Entra con: ' || SUBSTR(pformula,1,200));

      --13/3/07 CPM: Afegim el comentari al rastro
      IF pcomenta = 1 THEN
         comenta := NULL;
      ELSE
         comenta := '--';
      END IF;

      -- Actualitzem el registre, doncs anem a modificar la funció
      UPDATE gfi_funciones
         SET refresca = 1
       WHERE cformula = pformula;

      SELECT clave
        INTO aux_form
        FROM sgt_formulas
       WHERE codigo = pformula;

      BEGIN
         SELECT origen
           INTO xparam
           FROM sgt_term_form
          WHERE termino = pformula;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            xparam := '9';
      END;

      retorno := busca_parametros(pformula, xdeclare, xselec);
      retorno := busca_token(s, xdeclare, xselec2);
-- Crear un nuevo parinstalacion para saber el usuario donde crear la función
      xuser := f_parinstalacion_t('USER_GFI');

      IF xuser IS NOT NULL THEN
         xuser := xuser || '.';
      END IF;

      IF xparam = 6 THEN   -- Funció recursiva
         xparam := ' (sesion IN NUMBER, XINICI IN NUMBER)';
--     xselec := xselec || CHR (10) || 'Pac_Gfi.p_grabar_rastro (sesion, '''
--                     || pformula || '_''||nrecurs, ' || pformula
--              || ', 0);' || CHR (10);
      ELSE
         xparam := ' (sesion IN NUMBER)';
      END IF;

      IF LENGTH(pformula) > 25 THEN
         -- No se pueden crear funciones con nombres de más de 30 caracteres
         xtfunc := 'Create or replace function ' || xuser || 'fgfi_' || aux_form || xparam
                   || ' RETURN NUMBER AUTHID current_user IS' || CHR(10);
         xtfunc := xtfunc || '-- ' || pformula || ' con clave ' || aux_form || CHR(10);
      ELSE
         xtfunc := 'Create or replace function ' || xuser || 'fgfi_' || pformula || xparam
                   || ' RETURN NUMBER AUTHID current_user IS' || CHR(10);
      END IF;

      xtfunc := xtfunc || xdeclare || 'RETORNO NUMBER;' || CHR(10) || CHR(10) || 'BEGIN'
                || CHR(10) || CHR(10);
      xtfunc := xtfunc || xselec || xselec2 || 'Retorno := ' || s || ';' || CHR(10)
                || 'RETURN Retorno;' || CHR(10) || CHR(10) || 'END;';

/*      FOR i IN 0 .. ROUND (LENGTH (xtfunc) / 240, 0) LOOP
         --DBMS_OUTPUT.put_line (i || 'Funcio: '
                               || SUBSTR (xtfunc, i * 240 + 1, 240));
      END LOOP;
*/
      EXECUTE IMMEDIATE xtfunc;

      INSERT INTO gfi_funciones
                  (cformula, cclave, refresca)
           VALUES (pformula, aux_form, 0);

      RETURN retorno;
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         UPDATE gfi_funciones
            SET refresca = 0
          WHERE cformula = pformula;

         RETURN retorno;
      WHEN OTHERS THEN
--         DBMS_OUTPUT.put_line (SQLERRM);
         p_tab_error(f_sysdate, f_user, 'pac_GFI.f_crea_func', 1, 'Error incontrolado',
                     SQLERRM);
         RETURN(151541);
   END f_crea_func;

-- --------------------------------------------------------------------
-- Funció que recupera els parámetres indicats per una sessió
-- --------------------------------------------------------------------
   FUNCTION f_sgt_parms(pnom VARCHAR2, psesio NUMBER)
      RETURN NUMBER IS
--      pvalor         NUMBER;
   BEGIN
      -- I  - JLB
         --SELECT valor
          -- INTO pvalor
          -- FROM sgt_parms_transitorios
          --WHERE sesion = psesio
          --  AND parametro = pnom;
         --RETURN(pvalor);
      RETURN(pac_sgt.get(psesio, pnom));
   -- F - JLB
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_sgt_parms;

-- --------------------------------------------------------------------
-- Comprobar si existe el token en una cadena
-- --------------------------------------------------------------------
   FUNCTION comprobar_token(ptoken IN VARCHAR2, pformula IN VARCHAR2)
      RETURN NUMBER IS
      poscarini      NUMBER := 0;   -- Posicio del caràcter inicial
      poscarfin      NUMBER := 0;   -- Posicio del caràcter final
      car            VARCHAR2(1);
      i              NUMBER := 1;
      vorigen        NUMBER;
   BEGIN
      -- CPM 5/10/06: Si se trata de una función recursiva, no se desplega
      BEGIN
         SELECT origen
           INTO vorigen
           FROM sgt_term_form
          WHERE termino = ptoken;
      EXCEPTION
         WHEN OTHERS THEN
            vorigen := 0;
      END;

      IF vorigen = 6 THEN
         RETURN 0;
      END IF;

      -- Fi CPM

      --dbms_output.put_line (SUBSTR('Comparem '||ptoken||'=='||pformula,1,250));
      WHILE poscarfin < LENGTH(pformula) LOOP
         poscarini := INSTR(pformula, ptoken, 1, i);

         IF poscarini = 0 THEN   -- Si no existeix retornem 0
            RETURN 0;
         ELSE
            poscarfin := poscarini + LENGTH(ptoken);
            -- Mirem el caràcter anterior
            car := SUBSTR(pformula, poscarini - 1, 1);

            IF poscarini = 1   -- Estem a l'inici de la cadena
               OR car IN(' ', '+', '-', '*', '/', '(', ')', ',', ';', '|', CHR(9), CHR(10)) THEN
               --Mirem el caràcter posterior
               car := SUBSTR(pformula, poscarfin, 1);

               IF poscarfin > LENGTH(pformula)
                  -- Estem al final de la cadena
                  OR car IN(' ', '+', '-', '*', '/', '(', ')', ',', ';', '|', CHR(9), CHR(10)) THEN
                  -- Trobem la cadena exacta
                  RETURN 1;
               END IF;
            END IF;
         END IF;

         i := i + 1;
      END LOOP;

      RETURN 0;   -- Hem arribat al final i no hem trobat res
   END;

------------------------------------------------------------------
-- Funció per grabar el valor de cada funció
------------------------------------------------------------------
   PROCEDURE p_grabar_rastro(
      psesion IN NUMBER,
      pparametro IN VARCHAR2,
      pvalor IN NUMBER,
      prastro IN NUMBER) IS
      -- I - JLB
      vnerror        NUMBER;
   -- F - JLB
   BEGIN
      IF NVL(f_sgt_parms('DEBUG', psesion), 0) > 0 THEN
           -- jlb -- I
         -- BEGIN
          --    INSERT INTO sgt_parms_transitorios
           --               (sesion, parametro, valor)
           --        VALUES (psesion, 'D_' || pparametro, pvalor);
           --EXCEPTION
          --    WHEN DUP_VAL_ON_INDEX THEN
          --       UPDATE sgt_parms_transitorios
          --          SET valor = pvalor
          --        WHERE sesion = psesion
          --          AND parametro = 'D_' || pparametro;
          --    WHEN OTHERS THEN
          --       NULL;
          -- END;
         vnerror := pac_sgt.put(psesion, 'D_' || pparametro, pvalor);
      -- JLB - F
      ELSIF prastro = 1 THEN
       -- JLB - I
     --    BEGIN
      --      INSERT INTO sgt_parms_transitorios
     --                   (sesion, parametro, valor)
     --          SELECT psesion, TO_CHAR(clave), pvalor
     --            FROM sgt_formulas
    --            WHERE codigo = pparametro
    --              AND crastro = 1;
    --     EXCEPTION
    --        WHEN DUP_VAL_ON_INDEX THEN
    --           UPDATE sgt_parms_transitorios
    --              SET valor = pvalor
    --            WHERE sesion = psesion
    --              AND parametro = (SELECT TO_CHAR(clave)
    --                                 FROM sgt_formulas
    --                                WHERE codigo = pparametro
    --                                  AND crastro = 1);
   --         WHEN OTHERS THEN
--          P_Tab_Error (F_Sysdate, F_User, 'pac_GFI.graba_rastro', 1,
--                      'OTHERS'||pparametro, SQLERRM);
    --           NULL;
    --     END;
         FOR v_formula IN (SELECT psesion sesion, TO_CHAR(clave) param, pvalor valor
                             FROM sgt_formulas
                            WHERE codigo = pparametro
                              AND crastro = 1) LOOP
            vnerror := pac_sgt.put(v_formula.sesion, v_formula.param, v_formula.valor);
         END LOOP;
      -- JLB - F
      END IF;
   END p_grabar_rastro;

-- --------------------------------------------------------------------
-- Funció que executa una formula per una sessió
-- --------------------------------------------------------------------
   FUNCTION f_eval_clave(pclave NUMBER, psesio NUMBER)
      RETURN NUMBER IS
      pvalor         NUMBER;
      xxformula      VARCHAR2(4000);
   BEGIN
      SELECT formula
        INTO xxformula
        FROM sgt_formulas
       WHERE clave = pclave;

      pvalor := pk_formulas.eval(xxformula, psesio);
      RETURN(pvalor);
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_eval_clave;

   /***********************************************************************
       Recupera la lista de tipos para los términos.
       param in pcidioma : Código idioma
       return             : ref cursor

       Bug 10716 - 16/07/2009 - AMC
    ***********************************************************************/
   FUNCTION f_get_lsttipoterm(pcidioma IN NUMBER)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      squery         VARCHAR2(400);
   BEGIN
      squery := 'SELECT *' || ' FROM ( SELECT ''T'' codigo, F_AXIS_LITERALES(1000504,'
                || pcidioma || ') descrip' || ' FROM DUAL' || ' UNION ALL'
                || ' SELECT ''F'' codigo, F_AXIS_LITERALES(1000505,' || pcidioma
                || ') descrip' || ' FROM DUAL' || ' UNION ALL'
                || ' SELECT ''P'' codigo, F_AXIS_LITERALES(1000506,' || pcidioma
                || ') descrip' || ' FROM DUAL) tabdrv';

      OPEN cur FOR squery;

      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_gfi.f_get_lsttipoterm', 1, 'error no controlado',
                     SQLERRM);
         RETURN NULL;
   END f_get_lsttipoterm;

   /***********************************************************************
      Recupera la lista del origen del término.
      return             : ref cursor

      Bug 10716 - 16/07/2009 - AMC
   ***********************************************************************/
   FUNCTION f_get_lstorigen
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      squery         VARCHAR2(400);
   BEGIN
      squery := 'SELECT * FROM SGT_TABLAS ORDER BY NUMTAB';

      OPEN cur FOR squery;

      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_gfi.F_GET_LSTORIGEN', 1, 'error no controlado',
                     SQLERRM);
         RETURN NULL;
   END f_get_lstorigen;

   /***********************************************************************
      Recupera la lista de operadores.
      param in pcidioma : Código idioma
      return             : ref cursor

      Bug 10716 - 16/07/2009 - AMC
   ***********************************************************************/
   FUNCTION f_get_lstoperador(pcidioma IN NUMBER)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      squery         VARCHAR2(400);
   BEGIN
      squery := 'SELECT catribu, tatribu' || ' FROM detvalores' || ' WHERE cidioma ='
                || pcidioma || ' AND cvalor = 108 ';

      OPEN cur FOR squery;

      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_gfi.F_GET_LSTOPERADOR', 1, 'error no controlado',
                     SQLERRM);
         RETURN NULL;
   END f_get_lstoperador;

   /***********************************************************************
      Recupera la información de los términos.
      param in ptermino : Código identificativo del término
      param in ptipo : Tipo de término (T=Tabla, P=Parámetro, F=Fórmula)
      param in porigen : Origen del término
      param in ptdesc : Descripción del término
      param in poperador : Indica si el termino es un operador o función (0= No, 1= Sí)
      param in pcidioma : Código idioma
      return             : ref cursor

      Bug 10716 - 16/07/2009 - AMC
   ***********************************************************************/
   FUNCTION f_get_terminos(
      ptermino IN VARCHAR2,
      ptipo IN VARCHAR2,
      porigen IN NUMBER,
      ptdesc IN VARCHAR2,
      poperador IN NUMBER,
      pcidioma IN NUMBER)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      squery         VARCHAR2(1000);
   BEGIN
      squery := 'SELECT termino, tipo,' || ' DECODE (tipo,''T'', F_AXIS_LITERALES(1000504,'
                || pcidioma || '),' || '''P'', F_AXIS_LITERALES(1000506,' || pcidioma || '),'
                || '''F'', F_AXIS_LITERALES(1000505,' || pcidioma || ')) ttipo,'
                || ' origen, (SELECT nomtab' || ' FROM sgt_tablas'
                || ' WHERE numtab = origen) torigen, tdesc, operador,' || ' (SELECT tatribu '
                || ' FROM detvalores ' || ' WHERE cvalor = 108' || ' AND catribu = operador'
                || ' AND cidioma =' || pcidioma || ') toperador' || ' FROM sgt_term_form '
                || ' WHERE ';

      IF ptermino IS NOT NULL THEN
         squery := squery || ' termino=''' || ptermino || ''' and ';
      END IF;

      IF ptipo IS NOT NULL THEN
         squery := squery || ' tipo =''' || ptipo || ''' and ';
      END IF;

      IF porigen IS NOT NULL THEN
         squery := squery || ' origen =' || porigen || ' and ';
      END IF;

      IF ptdesc IS NOT NULL THEN
         squery := squery || ' upper(tdesc) like ''%' || UPPER(ptdesc) || '%'' and ';
      END IF;

      IF poperador IS NOT NULL THEN
         squery := squery || ' operador =' || poperador || ' and ';
      END IF;

      squery := SUBSTR(squery, 1, LENGTH(squery) - 4);

      OPEN cur FOR squery;

      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_gfi.F_GET_TERMINOS', 1, 'error no controlado',
                     'squery:' || squery || ' ' || SQLERRM);
         RETURN NULL;
   END f_get_terminos;

   /***********************************************************************
      Recupera la información del término.
      param in ptermino : Código identificativo del término
      return             : ref cursor

      Bug 10716 - 16/07/2009 - AMC
   ***********************************************************************/
   FUNCTION f_get_termino(ptermino IN VARCHAR2)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      squery         VARCHAR2(400);
   BEGIN
      squery := 'SELECT *' || ' FROM sgt_term_form' || ' WHERE termino =' || CHR(39)
                || ptermino || CHR(39);

      OPEN cur FOR squery;

      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_gfi.F_GET_TERMINO', 1, 'error no controlado',
                     SQLERRM);
         RETURN NULL;
   END f_get_termino;

   /***********************************************************************
      Grava la información de los términos.
      param in ptermino : Código identificativo del término
      param in ptipo    : Tipo de término (T=Tabla, P=Parámetro, F=Fórmula)
      param in porigen  : Origen del término
      param in ptdesc   : Descripción del término
      param in poperador : Indica si el termino es un operador o función (0= No, 1= Sí)
      param in pisnew   : 1 es un nuevo termino 0 ja existía
      return            : 0 ha ido correctamente o bien el código de literal

      Bug 10716 - 16/07/2009 - AMC
   ***********************************************************************/
   FUNCTION f_grabartermino(
      ptermino IN VARCHAR2,
      ptipo IN VARCHAR2,
      porigen IN NUMBER,
      ptdesc IN VARCHAR2,
      poperador IN NUMBER,
      pisnew IN NUMBER)
      RETURN NUMBER IS
      numero_iguales NUMBER(2);
      var_tipo       sgt_term_form.tipo%TYPE;
   BEGIN
      IF ptermino IS NULL THEN
         RETURN 9001988;
      END IF;

      IF pisnew = 1 THEN
         SELECT COUNT(*)
           INTO numero_iguales
           FROM sgt_term_form
          WHERE termino = ptermino;

         IF numero_iguales > 0 THEN
            RETURN 9001988;
         ELSE
            BEGIN
               INSERT INTO sgt_term_form
                           (termino, tipo, origen, tdesc, operador)
                    VALUES (ptermino, ptipo, porigen, ptdesc, poperador);

               COMMIT;
            EXCEPTION
               WHEN DUP_VAL_ON_INDEX THEN
                  RETURN 9001988;
            END;
         END IF;
      ELSIF pisnew = 0 THEN
         UPDATE sgt_term_form
            SET termino = ptermino,
                tipo = ptipo,
                origen = porigen,
                tdesc = ptdesc,
                operador = poperador
          WHERE termino = ptermino;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_gfi.F_GRABARTERMINO', 1, 'error no controlado',
                     SQLERRM);
         RETURN 140999;
   END f_grabartermino;

   /***********************************************************************
      Elimina el término.
      param in ptermino : Código identificativo del término
      return            : 0 ha ido correctamente o bien el código de literal

      Bug 10716 - 16/07/2009 - AMC
   ***********************************************************************/
   FUNCTION f_eliminartermino(ptermino IN VARCHAR2)
      RETURN NUMBER IS
      numero_hijos   NUMBER;
      borrar         BOOLEAN := TRUE;
      trobat         NUMBER;   -- 0 si no trobat, 1 si trobat
      numero_param   NUMBER;
      aux            NUMBER;
      num_err        NUMBER;
   BEGIN
      trobat := trobar_terme(ptermino);

      IF trobat = 0 THEN
         SELECT COUNT(*)
           INTO numero_param
           FROM sgt_trans_formula
          WHERE parametro = ptermino;

         IF numero_param > 0 THEN
            RETURN 9001989;
         END IF;

         borrar_parametros(ptermino);
         num_err := borrar_sinonimos(ptermino);
         borrar_vigencias(ptermino);

         DELETE FROM sgt_term_form
               WHERE termino = ptermino;
      ELSE
         RETURN 108591;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_gfi.F_ELIMINARTERMINO', 1, 'error no controlado',
                     SQLERRM);
         RETURN 140999;
   END f_eliminartermino;

   /***********************************************************************
      Comprueba que el termino indicado no se este usando en alguna formula.
      param in ptermino : Código identificativo del término
      return            : 0 ha ido correctamente o bien el código de literal

      Bug 10716 - 16/07/2009 - AMC
   ***********************************************************************/
   FUNCTION trobar_terme(ptermino IN VARCHAR)
      RETURN NUMBER IS
      resultat       NUMBER;
      formula        VARCHAR2(2000);
      posicio        NUMBER;
      terme          VARCHAR2(50);
   BEGIN
      resultat := 0;
      terme := UPPER(ptermino);

      FOR a IN (SELECT DISTINCT formula
                           FROM sgt_formulas) LOOP
         a.formula := UPPER(a.formula);

         SELECT INSTR(a.formula, terme, 1, 1)
           INTO posicio
           FROM DUAL;

         IF posicio > 0 THEN
            resultat := 1;
         END IF;
      END LOOP;

      RETURN resultat;
   END trobar_terme;

   /***********************************************************************
      Elimina el parámetro pasado por parámetro.
      param in ptermino : Código identificativo del término

      Bug 10716 - 16/07/2009 - AMC
   ***********************************************************************/
   PROCEDURE borrar_parametros(ptermino IN VARCHAR2) IS
      numero_hijos   NUMBER;
   BEGIN
      SELECT COUNT(*)
        INTO numero_hijos
        FROM sgt_trans_formula
       WHERE parametro = ptermino;

      IF numero_hijos > 0 THEN
         DELETE      sgt_trans_formula
               WHERE parametro = ptermino;
      END IF;
   END borrar_parametros;

   /***********************************************************************
      Elimina el sinónimo .
      param in ptermino : Código identificativo del término
      return            : 0 ha ido correctamente o bien el código de literal
      Bug 10716 - 16/07/2009 - AMC
   ***********************************************************************/
   FUNCTION borrar_sinonimos(ptermino IN VARCHAR2)
      RETURN NUMBER IS
      numero_hijos   NUMBER;
   BEGIN
      SELECT COUNT(*)
        INTO numero_hijos
        FROM sgt_sinonimos
       WHERE sinonimo = ptermino;

      IF numero_hijos > 0 THEN
         RETURN 108544;
      ELSE
         DELETE      sgt_sinonimos
               WHERE termino = ptermino;
      END IF;

      RETURN 0;
   END borrar_sinonimos;

   /***********************************************************************
      Elimina las vigencias.
      param in ptermino : Código identificativo del término

      Bug 10716 - 16/07/2009 - AMC
   ***********************************************************************/
   PROCEDURE borrar_vigencias(ptermino IN VARCHAR2) IS
      numero_hijos   NUMBER;
      vorigen        NUMBER;
   BEGIN
      BEGIN
         SELECT origen
           INTO vorigen
           FROM sgt_term_form
          WHERE termino = ptermino;
      EXCEPTION
         WHEN OTHERS THEN
            vorigen := 0;
      END;

      IF vorigen = 11 THEN
         SELECT COUNT(*)
           INTO numero_hijos
           FROM sgt_parm_formulas
          WHERE codigo = ptermino;

         IF numero_hijos > 0 THEN
            DELETE      sgt_parm_formulas
                  WHERE codigo = ptermino;
         END IF;
      END IF;
   END borrar_vigencias;

   /***********************************************************************
      Recupera la información de las vigencias del término.
      param in ptermino : Código identificativo del término
      return            : sys_refcursor

      Bug 10716 - 16/07/2009 - AMC
   ***********************************************************************/
   FUNCTION f_get_termvigencias(ptermino IN VARCHAR2)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      squery         VARCHAR2(400);
   BEGIN
      squery := 'SELECT *' || ' FROM sgt_parm_formulas' || ' WHERE codigo =' || CHR(39)
                || ptermino || CHR(39);

      OPEN cur FOR squery;

      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_gfi.F_GET_TERMVIGENCIAS', 1,
                     'error no controlado', SQLERRM);
         RETURN NULL;
   END f_get_termvigencias;

   /***********************************************************************
      Elimina la vigencia del término.
      param in ptermino : Código identificativo del término
      param in pclave   : Código de la vigencia
      return            : 0 ha ido correctamente o bien el código de literal

      Bug 10716 - 16/07/2009 - AMC
   ***********************************************************************/
   FUNCTION f_eliminartermvigen(ptermino IN VARCHAR2, pclave IN NUMBER)
      RETURN NUMBER IS
   BEGIN
      DELETE FROM sgt_parm_formulas
            WHERE codigo = ptermino
              AND clave = pclave;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_gfi.F_ELIMINARTERMVIGEN', 1,
                     'error no controlado', SQLERRM);
         RETURN -1;
   END f_eliminartermvigen;

   /***********************************************************************
      Recupera la información de la vigencia del término.
      param in ptermino : Código identificativo del término
      param in pclave   : Código de la vigencia
      return            : sys_refcursor

      Bug 10716 - 16/07/2009 - AMC
   ***********************************************************************/
   FUNCTION f_get_termvigencia(ptermino IN VARCHAR2, pclave IN NUMBER)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      squery         VARCHAR2(400);
   BEGIN
      squery := 'SELECT *' || ' FROM sgt_parm_formulas' || ' WHERE codigo =' || CHR(39)
                || ptermino || CHR(39) || ' AND clave =' || CHR(39) || pclave || CHR(39);

      OPEN cur FOR squery;

      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_gfi.F_GET_TERMVIGENCIA', 1,
                     'error no controlado', SQLERRM);
         RETURN NULL;
   END f_get_termvigencia;

   /***********************************************************************
      Grabar la vigencia del término.
      param in ptermino : Código identificativo del término
      param in pclave   : Código de la vigencia
      param in pfechaefe : Fecha efecto
      param in pcvalor : Valor de la vigencia
      param in isNew : Indica si Nuevo 1 o 0 edición
      return            : 0 ha ido correctamente o bien el código de literal

      Bug 10716 - 16/07/2009 - AMC
   ***********************************************************************/
   FUNCTION f_grabartermvig(
      ptermino IN VARCHAR2,
      pclave IN NUMBER,
      pfechaefe IN DATE,
      pcvalor IN FLOAT,
      isnew IN NUMBER)
      RETURN NUMBER IS
      vclave         NUMBER;
      numero_iguales NUMBER;
   BEGIN
      IF isnew = 1 THEN
         IF pclave IS NULL THEN
            SELECT NVL(MAX(clave), 0) + 1
              INTO vclave
              FROM sgt_parm_formulas;
         END IF;

         -- crida a funció interna per contar quants cops es repeteix un terme data efecte
         numero_iguales := countsameefect(pfechaefe, ptermino);

         IF numero_iguales > 0 THEN
            RETURN 108534;
         ELSE
            BEGIN
               INSERT INTO sgt_parm_formulas
                           (clave, prm_r_agc, codigo, fecha_efecto, valor)
                    VALUES (vclave, 0, ptermino, pfechaefe, pcvalor);
            EXCEPTION
               WHEN OTHERS THEN
                  RETURN 140999;
            END;
         END IF;
      END IF;

      IF isnew = 0 THEN
         BEGIN
            UPDATE sgt_parm_formulas
               SET codigo = ptermino,
                   fecha_efecto = pfechaefe,
                   valor = pcvalor,
                   prm_r_agc = 0
             WHERE clave = pclave;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 140999;
         END;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_gfi.F_GRABARTERMVIG', 1, 'error no controlado',
                     SQLERRM);
         RETURN 140999;
   END f_grabartermvig;

   /***********************************************************************
      Comprueba que no exista ja una vigencia de término con esta fecha efecto.
      param in pfecha_efecto : Fecha efecto
      param in pcodigo  : Código identificativo del término
      return            : numero re registros encontrados

      Bug 10716 - 16/07/2009 - AMC
   ***********************************************************************/
   FUNCTION countsameefect(pfecha_efecto DATE, pcodigo VARCHAR2)
      RETURN NUMBER IS
      numreg         NUMBER := 0;
   BEGIN
      SELECT COUNT(*)
        INTO numreg
        FROM sgt_parm_formulas
       WHERE fecha_efecto = pfecha_efecto
         AND codigo = pcodigo;

      RETURN numreg;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_gfi.countsameefect', 1, 'error no controlado',
                     SQLERRM);
         RETURN -1;
   END countsameefect;

   /*************************************************************************
      Función que recupera la lista de los tramos
        param in ptramo: Código de tramo
                 pconcepto: Concepto al que se aplica el tramo
        param out:  mensajes de salida
        return:  ref cursor
   *************************************************************************/
   FUNCTION f_consultram(ptramo IN NUMBER, pconcepto IN VARCHAR2)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vcondicion     VARCHAR2(2000) := '';
   BEGIN
      vcondicion := 'SELECT TRAMO, CONCEPTO, CONCEPTO_FRANJA, CONCEPTO_VALOR FROM SGT_TRAMOS';

      IF ptramo IS NOT NULL THEN
         vcondicion := vcondicion || ' WHERE TRAMO=' || ptramo || ' and ';
      END IF;

      IF pconcepto IS NOT NULL THEN
         IF ptramo IS NOT NULL THEN
            vcondicion := vcondicion || '  UPPER(CONCEPTO) LIKE UPPER(''%' || pconcepto
                          || '%'') ' || ' and ';
         ELSE
            vcondicion := vcondicion || ' WHERE UPPER(CONCEPTO) LIKE UPPER(''%' || pconcepto
                          || '%'') ' || ' and ';
         END IF;
      END IF;

      IF ptramo IS NOT NULL
         OR pconcepto IS NOT NULL THEN
         vcondicion := SUBSTR(vcondicion, 1, LENGTH(vcondicion) - 4);
      END IF;

      OPEN cur FOR vcondicion;

      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_consultram;

   /* Función que elimna un tramo.
      param in ptramo: código de tramo
      param out:  mensajes de error
      return              : NUMBER   :  1 indicando se ha producido un error
                                        0 ha ido correctamente  */
   FUNCTION f_eliminartramo(ptramo IN NUMBER)
      RETURN NUMBER IS
      con            NUMBER;
   BEGIN
      SELECT COUNT(*)
        INTO con
        FROM sgt_vigencias_tramos s
       WHERE s.tramo = ptramo;

      IF con <> 0 THEN
         DELETE      sgt_det_tramos
               WHERE tramo IN(SELECT detalle_tramo
                                FROM sgt_vigencias_tramos
                               WHERE tramo = ptramo);

         DELETE      sgt_vigencias_tramos
               WHERE tramo = ptramo;
      END IF;

      DELETE      sgt_tramos
            WHERE tramo = ptramo;

      COMMIT;
      --Todo ok
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_GFI.F_GRABARTRAMO', 1, NULL,
                     SQLCODE || ' - ' || SQLERRM);
         RETURN 103869;
   END f_eliminartramo;

   /* Función que recupera la información de los tramos
       param in ptramo: código de tramo
      param out:  mensajes de error
      return:  ref cursor  */
   FUNCTION f_get_tramo(ptramo IN NUMBER)
      RETURN sys_refcursor IS
      vcursor        sys_refcursor;
      vcondicion     VARCHAR2(2000) := '';
   BEGIN
      vcondicion :=
         'SELECT TRAMO, CONCEPTO, CONCEPTO_FRANJA, CONCEPTO_VALOR FROM SGT_TRAMOS WHERE TRAMO = '
         || ptramo;

      OPEN vcursor FOR vcondicion;

      --Todo ok
      RETURN vcursor;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN vcursor;
   END f_get_tramo;

   /* Función que grava la información de los tramos.
      param in ptramo: código de tramo
               pconcepto: Concepto al que se aplica el tramo
               pcptfranja: Concepto Franja
               pcptvalor: Concepto Valor
      return : NUMBER   :  Error Código del literal
                           0 ha ido correctamente  */
   FUNCTION f_grabartramo(
      ptramo IN NUMBER,
      pconcepto IN VARCHAR2,
      pcptfranja IN VARCHAR2,
      pcptvalor IN VARCHAR2,
      pisnuevo IN NUMBER)
      RETURN NUMBER IS
      vcont          NUMBER;
   BEGIN
      IF ptramo IS NULL THEN
         RETURN 108396;   --Falta entrar el código del Tramo
      END IF;

      IF pconcepto IS NULL THEN
         RETURN 108397;   --Falta entrar el Concepto del Tramo
      END IF;

      IF pisnuevo IS NOT NULL
         AND pisnuevo = 1 THEN
         SELECT COUNT(1)
           INTO vcont
           FROM sgt_tramos
          WHERE tramo = ptramo;

         IF vcont > 0 THEN
            RETURN 108959;
         END IF;
      END IF;

      BEGIN
         INSERT INTO sgt_tramos
                     (tramo, concepto, concepto_franja, concepto_valor)
              VALUES (ptramo, pconcepto, pcptfranja, pcptvalor);
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            UPDATE sgt_tramos
               SET concepto = pconcepto,
                   concepto_franja = pcptfranja,
                   concepto_valor = pcptvalor
             WHERE tramo = ptramo;
      END;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_GFI.F_GRABARTRAMO', 1, NULL,
                     SQLCODE || ' - ' || SQLERRM);
         RETURN 103869;
   END f_grabartramo;

   /* Función que recupera la información de los tramos
       param in ptramo: código de tramo
       return:  ref cursor  */
   FUNCTION f_get_vigtramos(ptramo IN NUMBER)
      RETURN sys_refcursor IS
      vcursor        sys_refcursor;
      vcondicion     VARCHAR2(2000) := '';
   BEGIN
      vcondicion :=
         'SELECT TRAMO, FECHA_EFECTO, DETALLE_TRAMO FROM SGT_VIGENCIAS_TRAMOS WHERE TRAMO = '
         || ptramo || ' ORDER BY FECHA_EFECTO DESC';

      OPEN vcursor FOR vcondicion;

      --Todo ok
      RETURN vcursor;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN vcursor;
   END f_get_vigtramos;

   /* Función que recupera la información del detalle del tramo
         param in pdetalletramo: código detalle tramo
         return:  ref cursor  */
   FUNCTION f_get_detvigtramos(pdetalletramo IN NUMBER)
      RETURN sys_refcursor IS
      vcursor        sys_refcursor;
      vcondicion     VARCHAR2(2000) := '';
   BEGIN
      vcondicion :=
         'SELECT TRAMO, ORDEN, DESDE, HASTA, VALOR FROM SGT_DET_TRAMOS WHERE TRAMO = '
         || pdetalletramo;

      OPEN vcursor FOR vcondicion;

      --Todo ok
      RETURN vcursor;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN vcursor;
   END f_get_detvigtramos;

/* Función que grava la información de los tramos.
       param in ptramo: código de tramo
                pfechaefecto: Fecha efecto tramo
                pdetalletramo: Detalle tramo
       return : NUMBER   :  Error Código del literal
                            0 ha ido correctamente  */
   FUNCTION f_grabarvigtram(ptramo IN NUMBER, pfechaefecto IN DATE, pdetalletramo IN NUMBER)
      RETURN NUMBER IS
      vdetalle_tramo NUMBER;
   BEGIN
      vdetalle_tramo := pdetalletramo;

      IF ptramo IS NULL THEN
         RETURN 103866;   --Código de tramo obligatorio
      END IF;

      IF pfechaefecto IS NULL THEN
         RETURN 104532;   --Fecha efecto obligatoria
      END IF;

      IF pdetalletramo IS NULL THEN
         SELECT sdet_tramos.NEXTVAL
           INTO vdetalle_tramo
           FROM DUAL;
      END IF;

      INSERT INTO sgt_vigencias_tramos
                  (tramo, fecha_efecto, detalle_tramo)
           VALUES (ptramo, pfechaefecto, vdetalle_tramo);

      COMMIT;
      --Todo OK
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_GFI.F_grabarvigtram', 1, NULL,
                     SQLCODE || ' - ' || SQLERRM);
         RETURN 103869;
   END f_grabarvigtram;

   /* Función que graba la información de la vigencia de los tramos
      param in pdetalletramo: Código detalle tramo
               porden:        Número de orden
               pdesde:        Fecha desde
               phasta:        Fecha hasta
               pvalor:        Valor
      return   : NUMBER   :  1 indicando se ha producido un error
                             0 ha ido correctamente  */
   FUNCTION f_grabardetvigtram(
      pdetalletramo IN NUMBER,
      porden IN NUMBER,
      pdesde IN NUMBER,
      phasta IN NUMBER,
      pvalor IN NUMBER)
      RETURN NUMBER IS
      vdetalle_tramo NUMBER;
      vsolapado      NUMBER;
      vorden         NUMBER;
   BEGIN
      vorden := porden;

      IF pdesde IS NULL THEN
         RETURN 9001826;   --Valor desde obligatorio
      END IF;

      IF phasta IS NULL THEN
         RETURN 9001827;   --Valor hasta obligatorio
      END IF;

      IF NOT pdesde <= phasta THEN
         RETURN 108487;   --El campo 'Desde' no puede ser mayor que 'Hasta'.
      END IF;

      IF porden IS NULL THEN
         SELECT NVL(MAX(orden), 0) + 1
           INTO vorden
           FROM sgt_det_tramos
          WHERE tramo = pdetalletramo;
      END IF;

      vsolapado := f_tramo_solapado(pdetalletramo, vorden, pdesde, phasta);

      IF vsolapado <> 0 THEN
         RETURN 108486;   --El Tramo introducido se SOLAPA con otro tramo.
      END IF;

      BEGIN
         INSERT INTO sgt_det_tramos
                     (tramo, orden, desde, hasta, valor)
              VALUES (pdetalletramo, NVL(porden, vorden), pdesde, phasta, pvalor);
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            UPDATE sgt_det_tramos
               SET desde = pdesde,
                   hasta = phasta,
                   valor = pvalor
             WHERE tramo = pdetalletramo
               AND orden = NVL(porden, vorden);
      END;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_GFI.F_grabardetvigtram', 1, NULL,
                     SQLCODE || ' - ' || SQLERRM);
         RETURN 103869;
   END f_grabardetvigtram;

   /* Función que elimna la vigencia de un tramo.
      param in ptramo: Código de tramo
               pdetalletramo: Código del detalle tramo
      param out:  mensajes de salida
      return              : NUMBER   :  1 indicando se ha producido un error
                                        0 ha ido correctamente  */
   FUNCTION f_eliminarvigencia(ptramo IN NUMBER, pdetalletramo IN NUMBER)
      RETURN NUMBER IS
      con            NUMBER;
   BEGIN
      SELECT COUNT(*)
        INTO con
        FROM sgt_det_tramos s
       WHERE s.tramo = pdetalletramo;

      IF con <> 0 THEN
         DELETE      sgt_det_tramos
               WHERE tramo = pdetalletramo;
      END IF;

      DELETE      sgt_vigencias_tramos
            WHERE detalle_tramo = pdetalletramo;

      COMMIT;
      --Todo ok
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 1;
   END f_eliminarvigencia;

   /* Función que elimna la vigencia de un tramo.
      param in pdetalletramo: Código del detalle tramo
               porden: Número de orden de secuencia
      return              : NUMBER   :  Error código literal
                                        0 ha ido correctamente  */
   FUNCTION f_eliminardetvigencia(pdetalletramo IN NUMBER, porden IN NUMBER)
      RETURN NUMBER IS
   BEGIN
      DELETE      sgt_det_tramos
            WHERE tramo = pdetalletramo
              AND orden = porden;

      COMMIT;
      --Todo ok
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 1;
   END f_eliminardetvigencia;

   ----------
   --BUCLES--
   ----------
   /* Función que recupera la lista de bucles
      param in ptermino: Nombre del término
            in pniterac: Fórmula que nos dirá el número de iteraciones
            in poperacion: Tipo de operación (+, *)
      return:  ref cursor  */
   FUNCTION f_consultbucle(ptermino IN VARCHAR2, pniterac IN VARCHAR2, poperacion IN VARCHAR2)
      RETURN sys_refcursor IS
      vcursor        sys_refcursor;
      vcondicion     VARCHAR2(2000) := '';
   BEGIN
      vcondicion := 'SELECT TERMINO, NITERAC, OPERACION FROM SGT_BUCLES';

      IF ptermino IS NOT NULL THEN
         vcondicion := vcondicion || ' WHERE TERMINO=' || '''' || ptermino || '''' || ' and ';
      END IF;

      IF pniterac IS NOT NULL THEN
         IF ptermino IS NOT NULL THEN
            vcondicion := vcondicion || ' NITERAC=' || '''' || pniterac || '''' || ' and ';
         ELSE
            vcondicion := vcondicion || ' WHERE NITERAC=' || '''' || pniterac || ''''
                          || ' and ';
         END IF;
      END IF;

      IF poperacion IS NOT NULL THEN
         IF pniterac IS NOT NULL
            OR ptermino IS NOT NULL THEN
            vcondicion := vcondicion || ' OPERACION=' || '''' || poperacion || '''' || ' and ';
         ELSE
            vcondicion := vcondicion || ' WHERE OPERACION=' || '''' || poperacion || ''''
                          || ' and ';
         END IF;
      END IF;

      IF ptermino IS NOT NULL
         OR pniterac IS NOT NULL
         OR poperacion IS NOT NULL THEN
         vcondicion := SUBSTR(vcondicion, 1, LENGTH(vcondicion) - 4);
      END IF;

      OPEN vcursor FOR vcondicion;

      --Todo ok
      RETURN vcursor;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN vcursor;
   END f_consultbucle;

   /* Función que elimina un bucle
      param in ptermino: Nombre del término
      return              : NUMBER   :  1 indicando se ha producido un error
                                        0 ha ido correctamente  */
   FUNCTION f_eliminarbucle(ptermino IN VARCHAR2)
      RETURN NUMBER IS
      vnumerr        NUMBER;
   BEGIN
      --Comprovació pas de paràmetres
      IF ptermino IS NULL THEN
         RETURN 1;
      END IF;

      DELETE      sgt_bucles
            WHERE termino = ptermino;

      COMMIT;
      --Todo ok
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 1;
   END f_eliminarbucle;

   /* Función que recupera la lista de operación para el bucle
      param out:  mensajes de error
      return:  ref cursor  */
   FUNCTION f_get_lstoperacion
      RETURN sys_refcursor IS
      vcursor        sys_refcursor;
      vcondicion     VARCHAR2(2000) := '';
   BEGIN
      vcondicion :=
         'SELECT ''+'' CATRIBU , ''+'' TATRIBU FROM DUAL UNION ALL SELECT ''*'' CATRIBU , ''*'' TATRIBU FROM DUAL';

      OPEN vcursor FOR vcondicion;

      --Todo ok
      RETURN vcursor;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN vcursor;
   END f_get_lstoperacion;

   /* Función que grava la información del bucle.
      param in ptermino: Nombre del término
               pniterac: Fórmula que nos dirá el número de iteraciones
               poperacion: Tipo de operación (+, *)
               isnew: 1 Indica que es nuevo y 0 Modificación
      param out:  mensajes de salida
      return              : NUMBER   :  1 indicando se ha producido un error
                                        0 ha ido correctamente  */
   FUNCTION f_grabarbucle(
      ptermino IN VARCHAR2,
      pniterac IN VARCHAR2,
      poperacion IN VARCHAR2,
      isnew IN NUMBER)
      RETURN NUMBER IS
      vcursor        sys_refcursor;
      numero_iguales NUMBER;
      vnumerr        NUMBER;
   BEGIN
      --Comprovació pas de paràmetres
      IF ptermino IS NULL THEN
         RETURN 101001;   --Campo obligatorio
      END IF;

      IF pniterac IS NULL THEN
         RETURN 101001;   --Campo obligatorio
      END IF;

      IF poperacion IS NULL THEN
         RETURN 101001;   --Campo obligatorio
      END IF;

      IF isnew IS NULL THEN
         RETURN 101001;   --Campo obligatorio
      END IF;

      --Graba la información del bucle
      IF isnew IN(0, 1) THEN
         --1 Indica que es nuevo (insert). Debemos comprobar que no exista ya.
         --0 Indica que es modificacion (update). Debemos comprobar que exista.
         SELECT COUNT(*)
           INTO numero_iguales
           FROM sgt_bucles
          WHERE termino = ptermino;
      END IF;

      IF numero_iguales = 0
         AND isnew = 1 THEN
         INSERT INTO sgt_bucles
                     (termino, niterac, operacion)
              VALUES (ptermino, pniterac, poperacion);

         COMMIT;
         --Todo ok
         RETURN 0;
      ELSIF numero_iguales = 1
            AND isnew = 1 THEN
         --Este registro ya existe
         RETURN 108959;
      ELSIF numero_iguales = 1
            AND isnew = 0 THEN
         UPDATE sgt_bucles
            SET niterac = pniterac,
                operacion = poperacion
          WHERE termino = ptermino;

         COMMIT;
         --Todo ok
         RETURN 0;
      ELSIF numero_iguales = 0
            AND isnew = 0 THEN
         --Este registro ha sido borrado
         RETURN 103922;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 1;
   END f_grabarbucle;

   /* Función que recupera los parámetros para poder evaluar una fórmula.
      param in pclave: Clave fórmula
      param out:  psession: Código único de sesión
      return:  ref cursor  */
   FUNCTION f_get_paramtrans(pclave IN NUMBER, psession OUT NUMBER)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
   BEGIN
      -- recuperar la siguiente sesion
      SELECT sgt_sesiones.NEXTVAL
        INTO psession
        FROM DUAL;

      OPEN cur FOR
         SELECT parametro
           FROM sgt_trans_formula
          WHERE clave = pclave;

      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN cur;
   END f_get_paramtrans;

   /* Función que grava la información de los parámetros
     param in psession: Número de sesión
              pparamact: Nombre parámetro actual
              pparampos: Nombre parámetro nuevo
              pvalor: Valor del parámetro

     return              : NUMBER   :  1 indicando se ha producido un error
                                       0 ha ido correctamente  */
   FUNCTION f_grabarparamtrans(
      psession IN NUMBER,
      pparamact IN VARCHAR2,
      pparampos IN VARCHAR2,
      pvalor IN NUMBER)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MDI_GFI.F_GrabarParamtrans';
      vnumerr        NUMBER;
   BEGIN
      -- I - JLB
        /*
         IF pparamact IS NULL THEN
            INSERT INTO sgt_parms_transitorios
                        (sesion, parametro, valor)
                 VALUES (psession, pparampos, pvalor);

            COMMIT;
         ELSE
            UPDATE sgt_parms_transitorios
               SET valor = pvalor
             WHERE sesion = psession
               AND parametro = pparamact;

            COMMIT;
         END IF;
        */
        -- JLB - F
      vnumerr := pac_sgt.put(psession, NVL(pparamact, pparampos), pvalor);
      --Todo ok
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN SQLCODE;
   END f_grabarparamtrans;

   /* Función que elimina la información de los parámetros
     param in psession: Número de sesión
              pparam: Nombre parámetro
     param out: mensajes:  mensajes de salida
     return              : NUMBER   :  1 indicando se ha producido un error
                                       0 ha ido correctamente  */
   FUNCTION f_eliminarparamtrans(psession IN NUMBER, pparam IN VARCHAR2)
      RETURN NUMBER IS
      vnumerr        NUMBER;
   BEGIN
      --Comprovació pas de paràmetres
      IF psession IS NULL
         OR pparam IS NULL THEN
         RETURN 1;
      END IF;

      -- I - JLB
       --DELETE      sgt_parms_transitorios
       --      WHERE sesion = psession
       --        AND parametro = pparam;

      --COMMIT;
      vnumerr := pac_sgt.del(psession, pparam);
      -- JLB - F
      --Todo ok
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN SQLCODE;
   END f_eliminarparamtrans;

   /* Función que Evalúa el resultado de la fórmula.
      param in psession: Código único de sesión
               pclave: Clave fórmula.
               pdebug: Modo de debug
      param out:  pformula: Código de la fórmula
      return              : NUMBER   :  Valor devuelto por la fórmula  */
   FUNCTION f_evaluar(
      psession IN NUMBER,
      pclave IN NUMBER,
      pdebug IN NUMBER,
      pformula OUT VARCHAR2)
      RETURN NUMBER IS
      nerr           NUMBER;
      codigo         VARCHAR2(30);
      valor          NUMBER;
   BEGIN
      IF pdebug <> 0
         AND f_sgt_parms('DEBUG', psession) IS NULL THEN
         nerr := pac_gfi.f_grabarparamtrans(psession, NULL, 'DEBUG', pdebug);

         IF nerr <> 0 THEN
            ROLLBACK;
            RETURN nerr;
         --tabla SGT_PARMS_TRANSITARIOS --> Valores temporales de los parámetros para fórmulas
         --Return ??12343??; -- Crear literal
         END IF;

         COMMIT;
      ELSIF pdebug <> f_sgt_parms('DEBUG', psession) THEN
         nerr := pac_gfi.f_grabarparamtrans(psession, 'DEBUG', 'DEBUG', pdebug);

         IF nerr <> 0 THEN
            ROLLBACK;
            RETURN nerr;
         --tabla SGT_PARMS_TRANSITARIOS --> Valores temporales de los parámetros para fórmulas
         --Return ??3234??; -- Crear literal
         END IF;

         COMMIT;
      END IF;

      BEGIN
         SELECT formula, codigo
           INTO pformula, codigo
           FROM sgt_formulas
          WHERE clave = pclave;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 8484785;   --'No se ha encontrado la formula'
      END;

      valor := pk_formulas.eval(pformula, psession);
      RETURN valor;
   END f_evaluar;

------------------
--CÓDIGO FUNCIÓN--
------------------
/* Función que recupera el código de una fórmula.
  param in pclave: Clave fórmula
  return:  ref cursor  */
   FUNCTION f_get_source(pclave IN NUMBER)
      RETURN sys_refcursor IS
      vcodigo        NUMBER;
      cur            sys_refcursor;
   BEGIN
      SELECT codigo
        INTO vcodigo
        FROM sgt_formulas
       WHERE clave = pclave;

      OPEN cur FOR
         SELECT owner, text
           FROM all_source
          WHERE NAME = 'FGFI_' || vcodigo
             OR NAME = 'FGFI_' || pclave;

      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN cur;
   END f_get_source;

-------------
--FUNCIONES--
-------------
/* Función que recupera la lista de procesos
  param in:  pcidioma: Número de idioma
  return:  ref cursor  */
   FUNCTION f_get_lstfprocesos(pcidioma IN NUMBER)
      RETURN sys_refcursor IS
      vcodigo        NUMBER;
      cur            sys_refcursor;
   BEGIN
      OPEN cur FOR
         SELECT catribu, tatribu
           FROM detvalores
          WHERE cidioma = pcidioma
            AND cvalor = 203;

      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN cur;
   END f_get_lstfprocesos;

   /* Función que recupera la lista de refresco
     param in:  pcidioma: Número de idioma
     return:  ref cursor  */
   FUNCTION f_get_lstfrefrescar(pcidioma IN NUMBER)
      RETURN sys_refcursor IS
      vcodigo        NUMBER;
      cur            sys_refcursor;
   BEGIN
      OPEN cur FOR
         SELECT catribu, tatribu
           FROM detvalores
          WHERE cidioma = pcidioma
            AND cvalor = 828;

      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN cur;
   END f_get_lstfrefrescar;

   /* Función que recupera la información de las funciones
     param in pclave: Clave fórmula
              pformula: Código fórmula
              ptproceso: Proceso que utiliza esta fórmula
              prefresca: Indica que la fórmula se tendría que refrescar
     param out:  mensajes: mensajes de error
     return:  ref cursor  */
   FUNCTION f_get_funciones(
      pclave IN NUMBER,
      pformula IN VARCHAR2,
      ptproceso IN VARCHAR2,
      prefresca IN NUMBER)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vcondicion     VARCHAR2(2000) := '';
   BEGIN
      vcondicion :=
         'SELECT cformula, cclave, tproceso,
                          (SELECT tatribu
                             FROM detvalores
                             WHERE cvalor = 203
                                AND catribu = tproceso
                                AND cidioma = pac_iax_common.f_get_cxtidioma) ttproceso,
                              refresca,
                          (SELECT tatribu
                             FROM detvalores
                             WHERE cvalor = 828
                                AND catribu = tproceso
                                AND cidioma = pac_iax_common.f_get_cxtidioma) trefresca
                          FROM gfi_funciones';

      IF pclave IS NOT NULL THEN
         vcondicion := vcondicion || ' WHERE CCLAVE=' || pclave || ' and ';
      END IF;

      IF pformula IS NOT NULL THEN
         IF pclave IS NOT NULL THEN
            vcondicion := vcondicion || ' CFORMULA=' || ''' || pformula || ''' || ' and ';
         ELSE
            vcondicion := vcondicion || ' WHERE CFORMULA=' || ''' || pformula || '''
                          || ' and ';
         END IF;
      END IF;

      IF ptproceso IS NOT NULL THEN
         IF pclave IS NOT NULL
            OR pformula IS NOT NULL THEN
            vcondicion := vcondicion || ' TPROCESO=' || ''' || ptproceso || ''' || ' and ';
         ELSE
            vcondicion := vcondicion || ' WHERE TPROCESO=' || ''' || ptproceso || '''
                          || ' and ';
         END IF;
      END IF;

      IF prefresca IS NOT NULL THEN
         IF pclave IS NOT NULL
            OR pformula IS NOT NULL
            OR ptproceso IS NOT NULL THEN
            vcondicion := vcondicion || ' REFRESCA=' || ''' || prefresca || ''' || ' and ';
         ELSE
            vcondicion := vcondicion || ' WHERE REFRESCA=' || ''' || prefresca || '''
                          || ' and ';
         END IF;
      END IF;

      IF pclave IS NOT NULL
         OR pformula IS NOT NULL
         OR ptproceso IS NOT NULL
         OR prefresca IS NOT NULL THEN
         vcondicion := SUBSTR(vcondicion, 1, LENGTH(vcondicion) - 4);
      END IF;

      OPEN cur FOR vcondicion;

      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_funciones;

   /* Función que grava la información de la función
       param in pclave: Clave de la fórmula
                pcformula: Código de la fórmula
                ptproceso: Proceso que utiliza esta fórmula
                prefrescar: Indica que la fórmula se tendría que refrescar
       return              : NUMBER   :  X Error Código de literal
                                         0 ha ido correctamente  */
   FUNCTION f_grabarfuncion(
      pcclave IN NUMBER,
      pcformula IN VARCHAR2,
      ptproceso IN VARCHAR2,
      prefrescar IN NUMBER)
      RETURN NUMBER IS
      CURSOR c_formpare IS
         SELECT     LEVEL, x.codigo
               FROM sgt_formulas x
         START WITH x.codigo = pcformula
         CONNECT BY pac_gfi.comprobar_token(PRIOR UPPER(x.codigo), UPPER(x.formula)) = 1;
   BEGIN
      IF pcclave IS NULL THEN
         RETURN 101001;   --Campo obligatorio
      END IF;

      IF pcformula IS NULL THEN
         RETURN 101001;   --Campo obligatorio
      END IF;

      IF prefrescar IS NULL THEN
         RETURN 101001;   --Campo obligatorio
      END IF;

      IF prefrescar = 0 THEN
         RETURN 151764;
      --no se puede grabar el valor
      ELSE
         FOR reg IN c_formpare LOOP
            UPDATE gfi_funciones
               SET refresca = 1
             WHERE cformula = reg.codigo;
         END LOOP;
      END IF;

      COMMIT;
      --Todo OK
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN SQLCODE;
   END f_grabarfuncion;

   /*************************************************************************
     FUNCTION f_tramo
         Funció que retorna valor tram
         param in pnsesion  : Sesio
         param in pfecha  : Data
         param in pntramo  : Tram
         param in pbuscar : Valor a trobar

         return             : 0 -> Tot correcte
   *************************************************************************/
   FUNCTION f_tramo(pnsesion IN NUMBER, pfecha IN NUMBER, pntramo IN NUMBER, pbuscar IN NUMBER)
      RETURN NUMBER IS
      valor          NUMBER;
      ftope          DATE;
   BEGIN
      IF pfecha IS NULL THEN
         ftope := f_sysdate;
      ELSE
         ftope := TO_DATE(pfecha, 'yyyymmdd');
      END IF;

      valor := NULL;

      FOR r IN (SELECT   orden, desde, NVL(hasta, desde) hasta, valor
                    FROM sgt_det_tramos
                   WHERE tramo = (SELECT detalle_tramo
                                    FROM sgt_vigencias_tramos
                                   WHERE tramo = pntramo
                                     AND fecha_efecto =
                                              (SELECT MAX(fecha_efecto)
                                                 FROM sgt_vigencias_tramos
                                                WHERE tramo = pntramo
                                                  AND fecha_efecto <= ftope))
                ORDER BY orden) LOOP
         IF pbuscar BETWEEN r.desde AND r.hasta THEN
            RETURN r.valor;
         END IF;
      END LOOP;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN -1;
   END f_tramo;
END pac_gfi;

/

  GRANT EXECUTE ON "AXIS"."PAC_GFI" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_GFI" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_GFI" TO "PROGRAMADORESCSI";
