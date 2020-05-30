create or replace PACKAGE BODY "PAC_ALBSGT" IS
   /****************************************************************************
      NOMBRE:     PAC_ALBSGT
      PROPÓSITO:  Cuerpo del paquete de las funciones utilizadas para la generación
      de preguntas que posteriormente se utilizaran en el SGT
      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ----------------------------------
      1.0                                     Creación del package.
      2.0        06/2009     NMM              Revisió màscara format.
      3.0        15/11/2010  JMC              Tuning función f_tprefor (bug:16551)
      4.0        02/05/2011  SRA              4. 0018345: LCOL003 - Validación de garantías dependientes de respuestas u otros factores
      5.0        20/05/2011  APD              5. 0018362: LCOL003 - Parámetros en cláusulas y visualización cláusulas automáticas
      6.0        15/10/2012  JLB              6. 0023823: LCOL_T005 - PER - Auto-alimentación de listas restringidas
      7.0        22/11/2012  MDS              7. 0024657: MDP_T001-Pruebas de Suplementos
      8.0        21/06/2019  RABQ             8. Ajuste función f_tprefor (Ajuste por errores en SIT)
   ****************************************************************************/
   /*  FUNCTION f_tprefor (
                    ptprefor    IN       VARCHAR2,
        ptablas     IN       VARCHAR2,
        psseguro    IN       NUMBER,
        pnriesgo    IN       NUMBER,
        pfefecto    IN       DATE,
        pnmovimi    IN       NUMBER,
        pcgarant    IN       NUMBER,
        resultat    OUT      NUMBER,
        psproces    IN       NUMBER,
        pnmovima    IN       NUMBER DEFAULT 1,
        picapital   IN       NUMBER DEFAULT 0
     )
        RETURN NUMBER
     IS
        s         VARCHAR2 (200);
        ncursor   NUMBER;
        filas     NUMBER;
        i         NUMBER;
     BEGIN
        i          := 1;
        WHILE i < LENGTH (ptprefor)
         AND SUBSTR (ptprefor, i, 1) <> '('
        LOOP
           i    := i + 1;
        END LOOP;
        s          :=
              'select '
           || SUBSTR (ptprefor, 1, i)
           || ' '''
           || ptablas
           || ''', '
           || TO_CHAR (psseguro)
           || ', '
           || TO_CHAR (pnriesgo)
           || ', TO_DATE('''
           || TO_CHAR (pfefecto)
           || '''), '
           || TO_CHAR (pnmovimi)
           || ', '
           || TO_CHAR (pcgarant)
           || ','
           || TO_CHAR (psproces)
           || ','
           || TO_CHAR (pnmovima)
           || ','
           || TO_CHAR (0);
        IF SUBSTR (ptprefor, i + 1, 1) <> ')' THEN
           s    :=
                s || ', ' || SUBSTR (ptprefor, i + 1, LENGTH (ptprefor) - i - 1);
        END IF;
        s          := s || ' ) from dual';
            --DBMS_OUTPUT.put_line ('*** ' || s);
        cerror     := 0;
        ncursor    := DBMS_SQL.open_cursor;
        DBMS_SQL.parse (ncursor, s, DBMS_SQL.native);
        DBMS_SQL.define_column (ncursor, 1, resultat);
        filas      := DBMS_SQL.EXECUTE (ncursor);
        IF DBMS_SQL.fetch_rows (ncursor) > 0 THEN
           DBMS_SQL.column_value (ncursor, 1, resultat);
        END IF;
        DBMS_SQL.close_cursor (ncursor);
        RETURN cerror;
     EXCEPTION
        WHEN OTHERS THEN
           --p_control_error('PAC_ALBSGT','f_tprefor',SUBSTR('s='||s||' '||SQLERRM,1,2000)); --> BORRAR JGR
           DBMS_SQL.close_cursor (ncursor);
           resultat    := NULL;
           RETURN -1;
     END f_tprefor;
     */

   /***************************************************************
                  PAC_ALBSGT: Cuerpo del paquete de las funciones
      de la interficie entre axis y SGT
           07/02/2001 JDC
   ***************************************************************/
   -- ini Bug 0016551 - JMC - 15-11-2010
   FUNCTION f_tprefor(
      ptprefor IN VARCHAR2,
      ptablas IN VARCHAR2,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pfefecto IN DATE,
      pnmovimi IN NUMBER,
      pcgarant IN NUMBER,
      resultat OUT NUMBER,
      psproces IN NUMBER,
      pnmovima IN NUMBER DEFAULT 1,
      picapital IN NUMBER DEFAULT 0,
      pnpoliza IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      /***************************************************************
                   F_TPREFOR: Evalua la funció de BBDD que se li pasa
          amb els parametres rebuts
            07/02/2001 JDC
      ***************************************************************/
      s              VARCHAR2(200);
   BEGIN
      s := SUBSTR(ptprefor, 1, INSTR(ptprefor, '('));

      -- Bug 22839 - RSC - 18/07/2012
      IF pnpoliza IS NOT NULL THEN
         s := 'begin :1 := ' || s
              || ':2, :3, :4, :5, :6, :7, :8, nvl(:9,1), nvl(:10,0), nvl(:11,0) ';   --); end;';
      ELSE
         -- Fin bug 22839
         s := 'begin :1 := ' || s || ':2, :3, :4, :5, :6, :7, :8, nvl(:9,1), nvl(:10,0) ';   --); end;';
      END IF;

      IF SUBSTR(ptprefor, INSTR(ptprefor, '(') + 1, 1) <> ')' THEN
         s := s || ', '
              || SUBSTR(ptprefor, INSTR(ptprefor, '(') + 1,
                        LENGTH(ptprefor) - INSTR(ptprefor, '(') - 1);
    ELSE
    
     s := s || ', '
              || SUBSTR(ptprefor, INSTR(ptprefor, '(') + 1,
                        LENGTH(ptprefor) - INSTR(ptprefor, '(') - 1);
        
    END IF;     
      

    s := s || ' ); end;';

      BEGIN
         cerror := 0;

         -- Bug 22839 - RSC - 18/07/2012
         IF pnpoliza IS NOT NULL THEN
            EXECUTE IMMEDIATE s
                        USING OUT resultat, ptablas, psseguro, pnriesgo, pfefecto, pnmovimi,
                              pcgarant, psproces, pnmovima, picapital, pnpoliza;
         ELSE
            -- FIn bugh 22839
            EXECUTE IMMEDIATE s
                        USING OUT resultat, ptablas, psseguro, pnriesgo, pfefecto, pnmovimi,
                              pcgarant, psproces, pnmovima, picapital;
         END IF;
      EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate(), f_user(), 'PAC_ALBSGT', 1, 'f_tprefor',
                        'cerror:<' || cerror || '>:sqlerrm:' || SQLERRM);
      END;

      IF cerror = 100 THEN
         cerror := 0;
      END IF;

      RETURN cerror;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate(), f_user(), 'PAC_ALBSGT', 2, 'f_tprefor',
                     'cerror:<' || cerror || '>:sqlerrm:' || SQLERRM);
         resultat := NULL;
         RETURN(-1);
   END f_tprefor;

-- fin Bug 0016551 - JMC - 15-11-2010
--**************************************************************************************
--Función para la validación de la formula para preguntas
-- BUG 7643
--**************************************************************************************
   FUNCTION f_tvalfor(
      pcrespue IN NUMBER,
      ptrespue IN VARCHAR2,
      ptvalfor IN VARCHAR2,
      ptablas IN VARCHAR2,
      psseguro IN NUMBER,
      pcactivi IN NUMBER,
      pnriesgo IN NUMBER,
      pfefecto IN DATE,
      pnmovimi IN NUMBER,
      pcgarant IN NUMBER,
      resultat OUT NUMBER,
      psproces IN NUMBER,
      pnmovima IN NUMBER DEFAULT 1,
      picapital IN NUMBER DEFAULT 0)
      RETURN NUMBER IS
      s              VARCHAR2(200);
      s2             VARCHAR2(2000);
      ncursor        NUMBER;
      filas          NUMBER;
      i              NUMBER;
   BEGIN
      i := 1;

      WHILE i < LENGTH(ptvalfor)
       AND SUBSTR(ptvalfor, i, 1) <> '(' LOOP
         i := i + 1;
      END LOOP;

      s := SUBSTR(ptvalfor, 1, i) || ' ' || CHR(39) || ptablas || CHR(39) || ', '
           || TO_CHAR(psseguro) || ', ' || NVL(TO_CHAR(pnriesgo), 'NULL') || ', TO_DATE('
           || CHR(39) || TO_CHAR(pfefecto, 'DDMMYYYY') || CHR(39) || ',' || CHR(39)
           || 'DDMMYYYY' || CHR(39) || '), ' || NVL(TO_CHAR(pnmovimi), 'NULL') || ', '
           || NVL(TO_CHAR(pcgarant), 'NULL') || ',' || NVL(TO_CHAR(psproces), 'NULL') || ','
           || NVL(TO_CHAR(pnmovima), 1) || ','
           || NVL(TO_CHAR(picapital, '9999999999999.99'), 0)
           || ','   --|| TO_CHAR (0); --LCL Mantis 2019
           || NVL(TO_CHAR(pcrespue, '9999999999999.99'), 0) || ','
           || CHR(39)   -- Mantis 10227.#6.06/2009.NMM.
           || NVL(ptrespue, 'NULL')   -- BUG 5388 se añaden comillas para evaluarlo bien
           || CHR(39);   --ptrespue;

      IF SUBSTR(ptvalfor, i + 1, 1) <> ')' THEN
         s := s || ', ' || SUBSTR(ptvalfor, i + 1, LENGTH(ptvalfor) - i - 1);
      END IF;

      s := s || ' )';

      BEGIN
         -- MRB, CPM 10/06/08: Primer fem l'execute i si no va, farem la select
         cerror := 0;
         s2 := ' begin :retorno := ' || s || ' ; end;';

         EXECUTE IMMEDIATE s2
                     USING OUT resultat;
      EXCEPTION
         WHEN OTHERS THEN
            BEGIN
               s := 'select ' || s || ' from dual';
               --cerror := 0;!!!!!!!!!el problema de que no muestre el mensaje por pantalla!!!!!!!!!!!!!!!
               cerror := 9000758;
               ncursor := DBMS_SQL.open_cursor;
               DBMS_SQL.parse(ncursor, s, DBMS_SQL.native);
               DBMS_SQL.define_column(ncursor, 1, resultat);
               filas := DBMS_SQL.EXECUTE(ncursor);

               IF DBMS_SQL.fetch_rows(ncursor) > 0 THEN
                  DBMS_SQL.COLUMN_VALUE(ncursor, 1, resultat);
               END IF;

               DBMS_SQL.close_cursor(ncursor);
            EXCEPTION
               WHEN OTHERS THEN
                  -- Mantis 10227.#6.06/2009.NMM.Format decimals.
                  p_tab_error(f_sysdate(), f_user(), 'PAC_ALBSGT', 1, 'f_tvalfor',
                              'cerror:<' || cerror || '>:sqlerrm:' || SQLERRM);
                  -- fi.Mantis 10227.#6.06/2009.NMM.Format decimals.
                  DBMS_SQL.close_cursor(ncursor);
            END;
      END;

      IF cerror = 100 THEN
         cerror := 0;
      END IF;

      RETURN cerror;
   EXCEPTION
      WHEN OTHERS THEN
         -- Mantis 10227.#6.06/2009.NMM.Format decimals.
         p_tab_error(f_sysdate(), f_user(), 'PAC_ALBSGT', 2, 'f_tvalfor',
                     'cerror:<' || cerror || '>:sqlerrm:' || SQLERRM);
         -- fi.Mantis 10227.#6.06/2009.NMM.Format decimals.
         DBMS_SQL.close_cursor(ncursor);
         resultat := NULL;
         RETURN(-1);
   END f_tvalfor;

   --FIN BUG 7643
   -- Ini bug 18345 - SRA - 02/05/2011
   FUNCTION f_tvalgar(
      ptvalfor IN VARCHAR2,
      ptablas IN VARCHAR2,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      pcgarant IN NUMBER,
      pcactivi IN NUMBER,
      resultat OUT NUMBER)
      RETURN NUMBER IS
      vnposini       NUMBER;
      vnposfin       NUMBER;
      vtsentencia    VARCHAR2(2000);
      vpasexec       NUMBER := 0;
      vobject        tab_error.tobjeto%TYPE := 'pac_albsgt.f_tvalfor';
      vtparam        tab_error.tdescrip%TYPE;
   BEGIN
      vtparam := 'ptvalfor: ' || ptvalfor || ' - ' || 'ptablas: ' || ptablas || ' - '
                 || 'psseguro: ' || psseguro || ' - ' || 'pnriesgo: ' || pnriesgo || ' - '
                 || 'pnmovimi: ' || pnmovimi || ' - ' || 'pcgarant: ' || pcgarant || ' - '
                 || 'pcactivi: ' || pcactivi;
      vpasexec := 1;
      vnposini := INSTR(ptvalfor, '(');
      vnposfin := INSTR(ptvalfor, ')');
      vpasexec := 2;

      IF vnposini > 0
         AND vnposfin = 0
         OR vnposini = 0
            AND vnposfin > 0
         OR vnposfin < vnposini THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vtparam, SQLERRM);
         RETURN 9901995;
      END IF;

      vpasexec := 3;

      IF vnposini > 0 THEN
         vtsentencia := SUBSTR(ptvalfor, 1, vnposini);
         vtsentencia := vtsentencia || ':2, :3, :4, :5, :6, :7';
         vpasexec := 4;

         IF vnposfin > 0 THEN
            IF TRIM(SUBSTR(ptvalfor, vnposini + 1, vnposfin - vnposini - 1)) IS NOT NULL THEN
               vtsentencia := vtsentencia || ', ';
            END IF;

            vpasexec := 5;
            vtsentencia := vtsentencia || SUBSTR(ptvalfor, vnposini + 1);
         END IF;
      ELSE
         vtsentencia := ptvalfor;
      END IF;

      vpasexec := 6;

      BEGIN
         -- si ptvalfor es una función
         EXECUTE IMMEDIATE 'BEGIN :1 := ' || vtsentencia || '; END;'
                     USING OUT resultat, ptablas, psseguro, pnriesgo, pnmovimi, pcgarant,
                           pcactivi;
      EXCEPTION
         WHEN OTHERS THEN
            -- si ptvalfor es una expresión SELECT
            BEGIN
               vpasexec := 7;

               EXECUTE IMMEDIATE vtsentencia
                            INTO resultat;
            EXCEPTION
               WHEN OTHERS THEN
                  -- si ptvalfor es una constante
                  vtsentencia := 'SELECT ' || vtsentencia || ' FROM DUAL';
                  vpasexec := 8;

                  EXECUTE IMMEDIATE vtsentencia
                               INTO resultat;
            END;
      END;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vtparam, SQLERRM);
         RETURN 9901995;
   END f_tvalgar;

   -- Fi bug 18345 - SRA - 02/05/2011

   --**************************************************************************************
--Función para la validación de la formula para parametros de clausulas
-- BUG 18362
--**************************************************************************************
   FUNCTION f_tvalclau(
      ptvalclau IN VARCHAR2,
      psclagen IN NUMBER,
      pnparame IN NUMBER,
      ptvalor IN VARCHAR2,
      ptablas IN VARCHAR2,
      psseguro IN NUMBER,
      pcactivi IN NUMBER,
      pnriesgo IN NUMBER,
      pfefecto IN DATE,
      pnmovimi IN NUMBER,
      resultat OUT NUMBER)
      RETURN NUMBER IS
      s              VARCHAR2(200);
      s2             VARCHAR2(2000);
      ncursor        NUMBER;
      filas          NUMBER;
      i              NUMBER;
   BEGIN
      i := 1;

      WHILE i < LENGTH(ptvalclau)
       AND SUBSTR(ptvalclau, i, 1) <> '(' LOOP
         i := i + 1;
      END LOOP;

      s := SUBSTR(ptvalclau, 1, i) || ' ''' || ptablas || ''', ' || TO_CHAR(psseguro) || ', '
           || NVL(TO_CHAR(pcactivi), 'NULL') || ', ' || NVL(TO_CHAR(pnriesgo), 'NULL')
           || ', TO_DATE(''' || TO_CHAR(pfefecto, 'DDMMYYYY') || ''',''DDMMYYYY' || '''), '
           || NVL(TO_CHAR(pnmovimi), 'NULL') || ', ' || NVL(TO_CHAR(psclagen), 'NULL') || ','
           || NVL(TO_CHAR(pnparame), 'NULL') || ','''
           || NVL(ptvalor, 'NULL')   -- se añaden comillas para evaluarlo bien
                                  || ''' ';   --ptvalor;

      IF SUBSTR(ptvalclau, i + 1, 1) <> ')' THEN
         s := s || ', ' || SUBSTR(ptvalclau, i + 1, LENGTH(ptvalclau) - i - 1);
      END IF;

      s := s || ' )';

      BEGIN
         -- MRB, CPM 10/06/08: Primer fem l'execute i si no va, farem la select
         cerror := 0;
         s2 := ' begin :retorno := ' || s || ' ; end;';

         EXECUTE IMMEDIATE s2
                     USING OUT resultat;
      EXCEPTION
         WHEN OTHERS THEN
            BEGIN
               s := 'select ' || s || ' from dual';
               cerror := 0;   --!!!!!!!!!el problema de que no muestre el mensaje por pantalla!!!!!!!!!!!!!!!
               --cerror := 9000758;
               ncursor := DBMS_SQL.open_cursor;
               DBMS_SQL.parse(ncursor, s, DBMS_SQL.native);
               DBMS_SQL.define_column(ncursor, 1, resultat);
               filas := DBMS_SQL.EXECUTE(ncursor);

               IF DBMS_SQL.fetch_rows(ncursor) > 0 THEN
                  DBMS_SQL.COLUMN_VALUE(ncursor, 1, resultat);
               END IF;

               DBMS_SQL.close_cursor(ncursor);
            EXCEPTION
               WHEN OTHERS THEN
                  -- Mantis 10227.#6.06/2009.NMM.Format decimals.
                  p_tab_error(f_sysdate(), f_user(), 'PAC_ALBSGT', 1, 'f_tvalclau',
                              'cerror:<' || cerror || '>:sqlerrm:' || SQLERRM);
                  -- fi.Mantis 10227.#6.06/2009.NMM.Format decimals.
                  DBMS_SQL.close_cursor(ncursor);
            END;
      END;

      IF cerror = 100 THEN
         cerror := 0;
      END IF;

      RETURN cerror;
   EXCEPTION
      WHEN OTHERS THEN
         -- Mantis 10227.#6.06/2009.NMM.Format decimals.
         p_tab_error(f_sysdate(), f_user(), 'PAC_ALBSGT', 2, 'f_tvalclau',
                     'cerror:<' || cerror || '>:sqlerrm:' || SQLERRM);
         -- fi.Mantis 10227.#6.06/2009.NMM.Format decimals.
         DBMS_SQL.close_cursor(ncursor);
         resultat := NULL;
         RETURN(-1);
   END f_tvalclau;

   --FIN BUG 18362

   /*************************************************************************
                     F_TVAL_DOCUREQ
      Devuelve el resultado de la ejecución dinámica de una función relacionada
      con la documentación requerida.
      param in ptfuncio                : función a ejecutar
      param in ptablas                 : tablas a consultar (temporales o definitivas)
      param in pcactivi                : código de actividad
      param in psseguro                : número secuencial de seguro
      param in pnmovimi                : número de movimiento
      param out presult                : resultado de la ejecución
      return                           : 0 todo correcto
                                         1 ha habido un error
      BUG 18351 - 11/05/2011 - JMP - Se añade la función
   *************************************************************************/
   FUNCTION f_tval_docureq(
      ptfuncio IN VARCHAR2,
      ptablas IN VARCHAR2,
      pcactivi IN NUMBER,
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      -- Ini Bug 24657 - MDS - 22/11/2012
      -- añadir dos parámetros más a las funciones : riesgo y persona
      pnriesgo IN NUMBER,
      psperson IN NUMBER,
      -- Fin Bug 24657 - MDS - 22/11/2012
      presult OUT NUMBER)
      RETURN NUMBER IS
      v_pasexec      NUMBER(3) := 1;
      v_param        VARCHAR2(200)
         := 'ptfuncio: ' || ptfuncio || ' - ptablas: ' || ptablas || ' - pcactivi: '
            || pcactivi || ' - psseguro: ' || psseguro || ' - pnmovimi: ' || pnmovimi;
      v_object       VARCHAR2(100) := 'PAC_ALBSGT.f_tval_docureq';
      v_nposini      NUMBER(4);
      v_nposfin      NUMBER(4);
      v_tsentencia   VARCHAR2(2000);
   BEGIN
      v_nposini := INSTR(ptfuncio, '(');
      v_nposfin := INSTR(ptfuncio, ')');
      v_pasexec := 2;

      IF v_nposini > 0
         AND v_nposfin = 0
         OR v_nposini = 0
            AND v_nposfin > 0
         OR v_nposfin < v_nposini THEN
         p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, 'Error de sintaxis');
         RETURN 1;
      END IF;

      v_pasexec := 3;

      IF v_nposini > 0 THEN
         v_tsentencia := SUBSTR(ptfuncio, 1, v_nposini);
         -- Ini Bug 24657 - MDS - 22/11/2012
         -- añadir dos parámetros más a las funciones : 6 y 7
         v_tsentencia := v_tsentencia || ':2, :3, :4, :5, :6, :7';
         -- Fin Bug 24657 - MDS - 22/11/2012
         v_pasexec := 4;

         IF v_nposfin > 0 THEN
            IF TRIM(SUBSTR(ptfuncio, v_nposini + 1, v_nposfin - v_nposini - 1)) IS NOT NULL THEN
               v_tsentencia := v_tsentencia || ', ';
            END IF;

            v_pasexec := 5;
            v_tsentencia := v_tsentencia || SUBSTR(ptfuncio, v_nposini + 1);
         END IF;
      ELSE
         v_tsentencia := ptfuncio;
      END IF;

      v_pasexec := 6;

      BEGIN
            -- si ptfuncio es una función
         -- Bug 24657 - MDS - 22/11/2012
         -- añadir dos parámetros más a las funciones : pnriesgo y psperson
         EXECUTE IMMEDIATE 'BEGIN :1 := ' || v_tsentencia || '; END;'
                     USING OUT presult, ptablas, pcactivi, psseguro, pnmovimi, pnriesgo,
                           psperson;
      EXCEPTION
         WHEN OTHERS THEN
            -- si ptfuncio es una expresión SELECT
            BEGIN
               v_pasexec := 7;

               EXECUTE IMMEDIATE v_tsentencia
                            INTO presult;
            EXCEPTION
               WHEN OTHERS THEN
                  -- si ptfuncio es una constante
                  v_tsentencia := 'SELECT ' || v_tsentencia || ' FROM DUAL';
                  v_pasexec := 8;

                  EXECUTE IMMEDIATE v_tsentencia
                               INTO presult;
            END;
      END;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, SQLERRM);
         RETURN 1;
   END f_tval_docureq;

--**************************************************************************************
-- Función para la validación de la formula para listas restringidas
-- BUG 23823
--**************************************************************************************
   FUNCTION f_tvallre(
      ptvalfor IN VARCHAR2,
      ptablas IN VARCHAR2,
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pnriesgo IN NUMBER,
      psperson IN NUMBER,
      pnsinies IN NUMBER,
      resultat OUT VARCHAR2)
      RETURN NUMBER IS
      vnposini       NUMBER;
      vnposfin       NUMBER;
      vtsentencia    VARCHAR2(2000);
      vpasexec       NUMBER := 0;
      vobject        tab_error.tobjeto%TYPE := 'pac_albsgt.f_tvallre';
      vtparam        tab_error.tdescrip%TYPE;
   BEGIN
      vtparam := ' ptvalfor: ' || ptvalfor || ' ptablas: ' || ptablas || ' psseguro: '
                 || psseguro || ' pnmovimi: ' || pnmovimi || ' pnriesgo: ' || pnriesgo
                 || '  psperson: ' || psperson || ' pnsinies: ' || pnsinies;
      vpasexec := 1;
      vnposini := INSTR(ptvalfor, '(');
      vnposfin := INSTR(ptvalfor, ')');
      vpasexec := 2;

      IF vnposini > 0
         AND vnposfin = 0
         OR vnposini = 0
            AND vnposfin > 0
         OR vnposfin < vnposini THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vtparam, SQLERRM);
         RETURN 9901995;
      END IF;

      vpasexec := 3;

      IF vnposini > 0 THEN
         vtsentencia := SUBSTR(ptvalfor, 1, vnposini);
         vtsentencia := vtsentencia || ':2, :3, :4, :5, :6, :7';
         vpasexec := 4;

         IF vnposfin > 0 THEN
            IF TRIM(SUBSTR(ptvalfor, vnposini + 1, vnposfin - vnposini - 1)) IS NOT NULL THEN
               vtsentencia := vtsentencia || ', ';
            END IF;

            vpasexec := 5;
            vtsentencia := vtsentencia || SUBSTR(ptvalfor, vnposini + 1);
         END IF;
      ELSE
         vtsentencia := ptvalfor;
      END IF;

      vpasexec := 6;

      BEGIN
         -- si ptvalfor es una función
         EXECUTE IMMEDIATE 'BEGIN :1 := ' || vtsentencia || '; END;'
                     USING OUT resultat, ptablas, psseguro, pnmovimi, pnriesgo, psperson,
                           pnsinies;
      EXCEPTION
         WHEN OTHERS THEN
            -- si ptvalfor es una expresión SELECT
            BEGIN
               vpasexec := 7;

               EXECUTE IMMEDIATE vtsentencia
                            INTO resultat;
            EXCEPTION
               WHEN OTHERS THEN
                  vtsentencia := 'SELECT ' || vtsentencia || ' FROM DUAL';
                  vpasexec := 8;

                  EXECUTE IMMEDIATE vtsentencia
                               INTO resultat;
            END;
      END;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vtparam, SQLERRM);
         RETURN 9901995;
   END f_tvallre;
END pac_albsgt;
/