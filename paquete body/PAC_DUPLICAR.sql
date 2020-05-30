--------------------------------------------------------
--  DDL for Package Body PAC_DUPLICAR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_DUPLICAR" IS
   /***********************************************************************************
    23-12-2006. CSI
    Package que contiene todas las funciones necesarias para duplicar productos. Se basa en la parametrizacion
    de la tabla PDS_DUPLICAR.
     REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
       2.0        04/03/2009   XCG                1. Modificació package. (8510) afegir i/o modificar funcio f_duplica
       3.0        30/04/2009   ICV                2. Modificació package. (8510) Es corregeix la funció f_duplica per a la duplicació d'activitats.
       4.0        18/05/2009   ICV                3. 0009938: IAX - Dupl. producte: taula IMPREC
       5.0        09/02/2010   ICV                4. 0011173: CEM - Añadir la tabla CUMULPROD en el duplicador de productos
       6.0        03/08/2010   PFA                5. 15402: CRT101 - Duplicar la taula COMPANIPRO al duplicador de productes
       7.0        12/01/2012   JMB                6. 20822: 0020822: GIP003-Fechas Duplicador de productos
       8.0        16/07/2012   MDS                7. 0022824: LCOL_T010-Duplicado de propuestas
       9.0        10/06/2013   APD                8. 0027147: LCOL - TEC - Al duplicar una propuesta de autos, realizar un apunte
       10.0       12/06/2013   DCT                9. 0026923: LCOL - TEC - Revisión Q-Trackers Fase 3A
       11.0       17/06/2013   RCL                10.026923: Revisión Q-Trackers Fase 3A
       12.0       23/10/2013   JSV                12. 0028455: LCOL_T031- TEC - Revisión Q-Trackers Fase 3A II
       13.0       14/11/2013   SHA                13. 0028455: LCOL_T031- TEC - Revisión Q-Trackers Fase 3A II
       14.0       18/02/2014   FAL                14. 0029965: RSA702 - GAPS renovación
       15.0       24/03/2014   RCL                15. 0029665: LCOL_PROD-Qtrackers Fase 2 - iAXIS Produccion
       16.0       05/05/2014   ECP                16. 0012459: Error en beneficiarios al duplicar Solicitudes
       17.0       11/07/2014   DCT                17. 0032009: LCOL_PROD-LCOL_T031-Revisión Fase 3A Producción
       18.0       11/07/2014   JRV                18. 0032137: IAX998-Error al duplicar producto: tablas CLAUSUGAR y CLAUSUPREG
       19.0       25/08/2016   VCG                19. CONF-210-GAP-GTEC10- Duplicar Pólizas
    *******************************************************************************************/
   --
   FUNCTION consultar(consulta IN VARCHAR2, verror OUT VARCHAR2, filas OUT NUMBER)
      RETURN vector IS
      l_thecursor    INTEGER DEFAULT DBMS_SQL.open_cursor;
      l_columnvalue  VARCHAR2(32000);
      l_status       INTEGER;
      l_desctbl      DBMS_SQL.desc_tab;
      l_colcnt       NUMBER;
      lista          vector;
      ini_consulta   NUMBER := 0;
      ini_otros      NUMBER;
      vcolumnas      NUMBER;

      PROCEDURE execute_immediate(p_sql IN VARCHAR2) IS
      BEGIN
         DBMS_SQL.parse(l_thecursor, p_sql, DBMS_SQL.v7);
         l_status := DBMS_SQL.EXECUTE(l_thecursor);
      END execute_immediate;
   BEGIN
      verror := NULL;
      resultado.DELETE;
      ini_consulta := 0;

      IF INSTR(UPPER(LTRIM(consulta)), 'SELECT', 1, 1) = 1 THEN
         ini_consulta := 1;
      END IF;

      DBMS_SQL.parse(l_thecursor, consulta, DBMS_SQL.v7);

      IF ini_consulta = 1 THEN
         DBMS_SQL.describe_columns(l_thecursor, l_colcnt, l_desctbl);
         vcolumnas := l_colcnt;

         FOR i IN 1 .. l_colcnt LOOP
            DBMS_SQL.define_column(l_thecursor, i, l_columnvalue, 32000);
         END LOOP;
      END IF;

      filas := DBMS_SQL.EXECUTE(l_thecursor);

      IF ini_consulta = 0 THEN
         DBMS_SQL.close_cursor(l_thecursor);
         RETURN resultado;
      END IF;

      -- Para sentencias select, dbms_sql.execute su valor devuelto no esta definido
      filas := 0;

      WHILE(DBMS_SQL.fetch_rows(l_thecursor) > 0) LOOP
         FOR i IN 1 .. l_colcnt LOOP
            DBMS_SQL.COLUMN_VALUE(l_thecursor, i, l_columnvalue);
            resultado(filas + 1)(i) := l_columnvalue;
            resultado(0)(i) := l_desctbl(i).col_name;
         END LOOP;

         filas := filas + 1;
      END LOOP;

      DBMS_SQL.close_cursor(l_thecursor);
      RETURN resultado;
   EXCEPTION
      WHEN OTHERS THEN
         IF DBMS_SQL.is_open(l_thecursor) THEN
            DBMS_SQL.close_cursor(l_thecursor);
         END IF;

         verror := SQLCODE || ' - ' || SQLERRM || ' (consultar)';
         RETURN resultado;
   END consultar;

   FUNCTION f_borra(
      ptablas IN NUMBER,
      pnomsalida IN VARCHAR2,
      pmodulo IN NUMBER,
      ramo IN NUMBER,
      modali IN NUMBER,
      tipseg IN NUMBER,
      colect IN NUMBER,
      nsproduc IN NUMBER,
      contra IN NUMBER,
      versio IN NUMBER,
      activi IN NUMBER)
      RETURN NUMBER IS
      /*------------------------------------------------------------------------------------
              Función que borra un producto.
        Se podrá generar un fichero o ejecutar directamente el borrado
      -------------------------------------------------------------------------------------*/
      CURSOR modtablas IS
         SELECT   ttabla nomtabla
             FROM pds_duplicar
            WHERE cagrupa = ptablas
               OR ptablas IS NULL
                  AND cmodulo = pmodulo
         ORDER BY norden DESC;

      CURSOR coltablas(ctabla VARCHAR2) IS
         SELECT column_name, data_type
           FROM all_tab_columns
          WHERE table_name = ctabla
            AND owner = NVL(f_parinstalacion_t('USER_OWNER'), f_user);

      sentencia      VARCHAR2(30000);
      sentwhere      VARCHAR2(1000);
      ficherosalida  UTL_FILE.file_type;

      TYPE t_cursor IS REF CURSOR;

      c_select       t_cursor;
      vlinia         VARCHAR2(4000);
      v_nomtabla     VARCHAR2(100);
   BEGIN
      -- Abrimos el fichero si lo tenemos que generar
      IF pnomsalida IS NOT NULL THEN
         ficherosalida := UTL_FILE.fopen(f_parinstalacion_t('INFORMES'), pnomsalida, 'w',
                                         32767);
      END IF;

      FOR mt IN modtablas LOOP
         v_nomtabla := mt.nomtabla;
         sentencia := 'DELETE FROM ' || mt.nomtabla;
         sentwhere := ' WHERE ';

         FOR ct IN coltablas(mt.nomtabla) LOOP
            IF ct.column_name = 'CRAMO' THEN
               sentwhere := sentwhere || 'CRAMO = ' || ramo || ' AND ';
            ELSIF ct.column_name = 'CMODALI' THEN
               sentwhere := sentwhere || 'CMODALI = ' || modali || ' AND ';
            ELSIF ct.column_name = 'CTIPSEG' THEN
               sentwhere := sentwhere || 'CTIPSEG = ' || tipseg || ' AND ';
            ELSIF ct.column_name = 'CCOLECT' THEN
               sentwhere := sentwhere || 'CCOLECT = ' || colect || ' AND ';
            ELSIF ct.column_name = 'SPRODUC' THEN
               sentwhere := sentwhere || 'SPRODUC = ' || nsproduc || ' AND ';
            ELSIF ct.column_name = 'SCONTRA' THEN
               sentwhere := sentwhere || 'SCONTRA = ' || contra || ' AND ';
            ELSIF ct.column_name = 'NVERSIO' THEN
               sentwhere := sentwhere || 'NVERSIO = ' || versio || ' AND ';
            ELSIF ct.column_name = 'ACTIVI' THEN
               sentwhere := sentwhere || 'ACTIVI = ' || activi || ' AND ';
            END IF;
         END LOOP;

         sentwhere := RTRIM(sentwhere, 'AND ');
         sentencia := sentencia || sentwhere;

         IF pnomsalida IS NOT NULL THEN   -- Grabamos en fichero
            UTL_FILE.put_line(ficherosalida, 'PROMPT ' || mt.nomtabla);
            UTL_FILE.put_line(ficherosalida, sentencia || ';');
         ELSE   -- ejecutamos
            EXECUTE IMMEDIATE sentencia;
         END IF;
      END LOOP;

      IF UTL_FILE.is_open(ficherosalida) THEN
         UTL_FILE.fclose(ficherosalida);
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_duplicar.f_borra', 2,
                     'Error borrando tabla: ' || v_nomtabla, SQLERRM);

         IF UTL_FILE.is_open(ficherosalida) THEN
            UTL_FILE.fclose(ficherosalida);
         END IF;

         RETURN 152715;
   END f_borra;

   FUNCTION f_duplica(
      ptablas IN NUMBER,
      pnomsalida IN VARCHAR2,
      pmodulo IN NUMBER,
      ramorig IN NUMBER,
      modaliorig IN NUMBER,
      tipsegorig IN NUMBER,
      colectorig IN NUMBER,
      ramdest IN NUMBER,
      modalidest IN NUMBER,
      tipsegdest IN NUMBER,
      colectdest IN NUMBER,
      producorig IN NUMBER,
      producdest IN NUMBER,
      contraorig IN NUMBER,
      versioorig IN NUMBER,
      contradest IN NUMBER,
      versiodest IN NUMBER,
      activiorig IN NUMBER,
      actividest IN NUMBER)
      RETURN NUMBER IS
      /*------------------------------------------------------------------------------------
                     Función que duplica según la especificación de la tabla PDS_DUPLICAR.
        Se podrá generar un fichero o ejecutar directamente la duplicación
      -------------------------------------------------------------------------------------*/
      valorconcat    VARCHAR2(500);
      sentencia      VARCHAR2(30000);
      sentselect     VARCHAR2(30000);
      sentencia2     VARCHAR2(30000);
      sentselect2    VARCHAR2(30000);
      sentvalues     VARCHAR2(30000);
      sentwhere      VARCHAR2(1000);
      ficherosalida  UTL_FILE.file_type;
      v_nomtabla     VARCHAR2(100);
      v_seq          VARCHAR2(100);
      v_config       VARCHAR2(1000);
      v_codigo       VARCHAR2(100);
      v_codigo2      VARCHAR2(100);

      TYPE t_cursor IS REF CURSOR;

      c_select       t_cursor;
      c_select2      t_cursor;
      vlinia         VARCHAR2(4000);
      vlinia2        VARCHAR2(4000);

      CURSOR modtablas IS
         SELECT   ttabla nomtabla
             FROM pds_duplicar
            WHERE (cagrupa = ptablas
                   OR ptablas IS NULL)
              AND cmodulo = pmodulo
              AND((NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa(),
                                                     'MODULO_SINI'),
                       0)) = 1
                  OR UPPER(ttabla) NOT LIKE 'SIN_%')
         ORDER BY norden;

      /* Bug.: 11500 - JMT - 09/05/2016 - se añade order by*/
      CURSOR coltablas(ctabla VARCHAR2) IS
         SELECT   column_name, data_type, data_length
             FROM all_tab_columns
            WHERE table_name = ctabla
              AND owner = NVL(f_parinstalacion_t('USER_OWNER'), f_user)
              AND table_name NOT IN(SELECT t2.table_name
                                      FROM all_tab_columns t2
                                     WHERE t2.owner = f_user)
         ORDER BY column_id;

      FUNCTION devuelve_conf(
         cadena IN VARCHAR2,
         texto IN VARCHAR2,
         producto IN VARCHAR2,
         codigo OUT VARCHAR2,
         columna IN NUMBER DEFAULT 3)
         RETURN VARCHAR2 IS
         inicial        NUMBER := 1;
         cadenatratar   VARCHAR2(1000) := NULL;
         antresultado   VARCHAR2(1000) := NULL;
         posresultado   VARCHAR2(1000) := NULL;
         global_ant     VARCHAR2(1000) := NULL;
      BEGIN
         cadenatratar := cadena;

         WHILE inicial <= columna LOOP
            SELECT SUBSTR(cadenatratar, 1, INSTR(cadenatratar, texto) - 1),
                   SUBSTR(cadenatratar, INSTR(cadenatratar, texto) + 1)
              INTO antresultado,
                   posresultado
              FROM DUAL;

            IF inicial = 1 THEN
               global_ant := global_ant || antresultado;
            ELSIF inicial <> columna THEN
               global_ant := global_ant || texto || antresultado;
            END IF;

            cadenatratar := posresultado;
            inicial := inicial + 1;
         END LOOP;

         codigo := antresultado;
         global_ant := global_ant || texto || producto || texto || posresultado;
         RETURN global_ant;
      END;
   BEGIN
      -- Abrimos el fichero si lo tenemos que generar
      IF pnomsalida IS NOT NULL THEN
         ficherosalida := UTL_FILE.fopen(f_parinstalacion_t('INFORMES'), pnomsalida, 'w',
                                         32767);
         /*Ini Bug.: 11173 - ICV - 09/02/2010 - Campo norden*/
         UTL_FILE.put_line(ficherosalida,
                           'exec pac_iax_login.p_iax_iniconnect(' || CHR(39) || CHR(39)
                           || NVL(f_parinstalacion_t('USER_OWNER'), f_user) || CHR(39)
                           || CHR(39) || ');');
      /* Fin Bug.: 11173*/
      END IF;

      FOR mt IN modtablas LOOP
         v_nomtabla := mt.nomtabla;
         sentencia := 'INSERT INTO ' || mt.nomtabla || ' (';
         sentselect := 'SELECT ';
         sentwhere := ' WHERE ';

         FOR ct IN coltablas(mt.nomtabla) LOOP
            sentencia := sentencia || ct.column_name || ', ';

            IF ct.data_type = 'VARCHAR2'
               OR ct.data_type = 'DATE'
               OR ct.data_type = 'CHAR' THEN
               IF mt.nomtabla = 'TITULOPRO'
                  AND UPPER(ct.column_name) = 'TTITULO' THEN
                  valorconcat := CHR(39) || CHR(39) || CHR(39) || CHR(39)
                                 || '||SUBSTR(TTITULO||''_DUPL'',1,' || ct.data_length
                                 || ')||' || CHR(39) || CHR(39) || CHR(39) || CHR(39);
               ELSE
                  IF ct.data_type = 'DATE' THEN
                     --IF mt.nomtabla <> 'IMPREC' THEN   --Trato especial para esta tabla al cargarse apartir de una select
                        -- Bug 20822 GIP003 - Fechas Duplicador de productos
                        -- Author: JMB
                        -- Modification Date: 10/01/2012
                     valorconcat := CHR(39) || 'to_date(' || CHR(39) || CHR(39) || CHR(39)
                                    || '||' || 'to_char(' || ct.column_name || ',' || CHR(39)
                                    || 'DD/MM/YYYY' || CHR(39) || ')' || '||' || CHR(39)
                                    || CHR(39) || CHR(39) || ',' || CHR(39) || CHR(39)
                                    || 'DD/MM/YYYY' || CHR(39) || CHR(39) || ')' || CHR(39);
                  /*ELSE
                     --BUG 20822 - 24/02/2011 - JRB - Había problemas interpretando el año como YYYY.
                                    || ',''DD/MM/RRRR'')';
                  END IF;*/
                  ELSE
                     -- BUG 32137. No trataba bien los campos de caracteres con valores dentro.
                     valorconcat := CHR(39) || CHR(39) || CHR(39) || CHR(39) || '||'
                                    || 'replace(' || ct.column_name || ',' || CHR(39)
                                    || CHR(39) || CHR(39) || CHR(39) || ',' || CHR(39)
                                    || CHR(39) || CHR(39) || CHR(39) || CHR(39) || CHR(39)
                                    || ')' || '||' || CHR(39) || CHR(39) || CHR(39) || CHR(39);
                  ----valorconcat := CHR(39) || CHR(39) || CHR(39) || CHR(39) || '||'
                  ----              || ct.column_name || '||' || CHR(39) || CHR(39) || CHR(39)
                  ----               || CHR(39);
                  END IF;
               END IF;
            ELSE
               --IF mt.nomtabla <> 'IMPREC' THEN
               valorconcat := 'NVL(replace(to_char(' || ct.column_name
                              || '),'','',''.''),''null'')';   --Bug.: 15402 - PFA - 03/08/2010 - Se corrige el replace
                                                               --(comas por puntos para luego hacer correctamente el insert)
            /*ELSE
               valorconcat := ct.column_name;
            END IF;*/
            END IF;

            IF ct.column_name = 'CRAMO' THEN
               IF ramdest IS NOT NULL THEN
                  valorconcat := TO_CHAR(ramdest);
               END IF;

               IF ramorig IS NOT NULL THEN
                  sentwhere := sentwhere || 'CRAMO = ' || ramorig || ' AND ';
               END IF;
            ELSIF ct.column_name = 'CMODALI' THEN
               IF modalidest IS NOT NULL THEN
                  valorconcat := TO_CHAR(modalidest);
               END IF;

               IF modaliorig IS NOT NULL THEN
                  sentwhere := sentwhere || 'CMODALI = ' || modaliorig || ' AND ';
               END IF;
            ELSIF ct.column_name = 'CTIPSEG' THEN
               IF tipsegdest IS NOT NULL THEN
                  valorconcat := TO_CHAR(tipsegdest);
               END IF;

               IF tipsegorig IS NOT NULL THEN
                  sentwhere := sentwhere || 'CTIPSEG = ' || tipsegorig || ' AND ';
               END IF;
            ELSIF ct.column_name = 'CCOLECT' THEN
               IF colectdest IS NOT NULL THEN
                  valorconcat := TO_CHAR(colectdest);
               END IF;

               IF colectorig IS NOT NULL THEN
                  sentwhere := sentwhere || 'CCOLECT = ' || colectorig || ' AND ';
               END IF;
            ELSIF ct.column_name = 'SPRODUC' THEN
               IF producdest IS NOT NULL THEN
                  valorconcat := TO_CHAR(producdest);
               END IF;

               IF producorig IS NOT NULL THEN
                  sentwhere := sentwhere || 'SPRODUC = ' || producorig || ' AND ';
               END IF;
            ELSIF ct.column_name = 'SCONTRA' THEN
               IF contradest IS NOT NULL THEN
                  valorconcat := TO_CHAR(contradest);
               END IF;

               IF contraorig IS NOT NULL THEN
                  sentwhere := sentwhere || 'SCONTRA = ' || contraorig || ' AND ';
               END IF;
            ELSIF ct.column_name = 'NVERSIO' THEN
               IF versiodest IS NOT NULL THEN
                  valorconcat := TO_CHAR(versiodest);
               END IF;

               IF versioorig IS NOT NULL THEN
                  sentwhere := sentwhere || 'NVERSIO = ' || versioorig || ' AND ';
               END IF;
            /*Ini Bug.: 8510 - ICV - 30/04/2009 Duplicación de actividades*/
            ELSIF ct.column_name = 'CACTIVI' THEN
               IF actividest IS NOT NULL THEN
                  valorconcat := TO_CHAR(actividest);
               END IF;

               IF activiorig IS NOT NULL THEN
                  sentwhere := sentwhere || 'CACTIVI = ' || activiorig || ' AND ';
               END IF;
            /*Fin bug.: 8510*/
            ELSIF ct.column_name = 'CVALAXIS' THEN
               IF producdest IS NOT NULL THEN
                  valorconcat := TO_CHAR(producdest);
               END IF;

               IF producorig IS NOT NULL THEN
                  sentwhere := sentwhere || 'CVALAXIS = ''' || producorig || ''' AND ';
               END IF;
            ELSIF ct.column_name = 'SFPRESTA' THEN
               valorconcat := '((SELECT MAX(sfpresta) FROM fprestaprod)+ROWNUM)';
            /*Ini Bug.: 9938 - ICV - 15/05/2009 Duplicación de productos tabla imprec*/
            ELSIF ct.column_name = 'NCONCEP'
                  AND mt.nomtabla = 'IMPREC' THEN
               valorconcat := '''((SELECT nvl(max(nconcep),1) from IMPREC)+1)''';
            ELSIF ct.column_name = 'CCONFIG'
                  AND mt.nomtabla = 'PDS_SUPL_CONFIG' THEN   -- PDS_SUPL_CONFIG
               valorconcat := 'chr(39)||substr(cconfig,1,9)||' || producdest
                              /*Ini bug 24857*/
                                  --     || '||substr(cconfig,13,length(cconfig))||chr(39)';
                              || '||substr(cconfig,decode(length(' || producorig
                              || '),3,13,4,14,5,15,6,16),length(cconfig))||chr(39)';
               /*Fin bug 24857*/
            /*Fin bug.: 9938*/

            /*Ini Bug.: 11173 - ICV - 09/02/2010 - Campo norden*/
            ELSIF ct.column_name = 'NORDEN'
                  AND mt.nomtabla = 'COBBANCARIOSEL' THEN
               valorconcat :=
                  '((SELECT max(norden) from COBBANCARIOSEL cb where cb.ccobban = '
                  || mt.nomtabla || '.ccobban)+rownum)';
            /*Fin Bug.: 11173*/
            ELSIF ct.column_name LIKE 'S%'
                  AND ct.column_name NOT IN('SCLABEN', 'SBONUS') THEN
               -- camps PK d'origen sequence.next_val
               BEGIN
                  SELECT DISTINCT b.sequence_name
                             INTO v_seq
                             FROM all_constraints a, all_sequences b, all_ind_columns c
                            WHERE a.constraint_type = 'P'
                              AND a.owner = NVL(f_parinstalacion_t('USER_OWNER'), f_user)
                              AND c.column_name = ct.column_name
                              AND c.index_owner = a.owner
                              AND b.sequence_name = c.column_name
                              AND b.sequence_owner = c.index_owner
                              AND a.table_name = c.table_name
                              AND a.constraint_name = c.index_name
                              AND c.table_name = mt.nomtabla;

                  v_seq := v_seq || '.NEXTVAL';

                  SELECT v_seq
                    INTO valorconcat
                    FROM DUAL;
               EXCEPTION
                  WHEN OTHERS THEN
                     NULL;
               END;
            END IF;

            IF sentselect = 'SELECT ' THEN
               sentselect := sentselect || valorconcat;
            ELSE
               sentselect := sentselect || '||'',''||' || valorconcat;
            END IF;
         END LOOP;

         --Ini Bug.: 9938 - ICV - 15/06/2009 - Se controla la creación del script para la tabla IMPREC (Pedido exclusivamente paraa esta tabla)
         /*IF mt.nomtabla = 'IMPREC'
                     AND pnomsalida IS NOT NULL THEN
            sentencia := RTRIM(sentencia, ', ') || ') (';
         ELSE*/
         sentencia := RTRIM(sentencia, ', ') || ') VALUES (';
         --END IF;
         sentwhere := RTRIM(sentwhere, 'AND ');
         sentselect := sentselect || ' FROM ' || mt.nomtabla || sentwhere;

         IF pnomsalida IS NOT NULL THEN   -- Grabamos en fichero
            UTL_FILE.put_line(ficherosalida, 'PROMPT ' || mt.nomtabla);
         END IF;

         /*IF mt.nomtabla = 'COBBANCARIOSEL' THEN
                                                   p_tab_error(f_sysdate, F_USER, 'pac_duplicar.f_duplica', 3, 'COBBANCARIOSEL: ',
                        sentselect);
         END IF;*/
         OPEN c_select FOR sentselect;

         LOOP
            FETCH c_select
             INTO vlinia;

            /*if mt.nomtabla = 'IMPREC' then
                      p_tab_error(f_sysdate, F_USER, 'pac_duplicar.f_duplica', 3,
                    'vlinia: ' ,vlinia);
            end if;*/
            IF c_select%NOTFOUND THEN
               /*Ini Bug.: 9938 - ICV - 15/05/2009 Si la ultima tabla esta a nulo no tiene que insertar el insert*/
               vlinia := NULL;
               sentencia := NULL;
               /*Fin bug.: 9938*/
               EXIT;
            ELSE
               IF pnomsalida IS NOT NULL THEN   -- Grabamos en fichero
                  --Ini Bug.: 9938 - ICV - 15/06/2009 - Se controla la creación del script para la tabla IMPREC (Pedido exclusivamente paraa esta tabla)
                  /*IF mt.nomtabla = 'IMPREC' THEN
                                       sentselect := REPLACE(sentselect, '||'',''||', ',');
                     sentselect := REPLACE(sentselect, 'null', NULL);
                     sentselect := REPLACE(sentselect, CHR(39) || CHR(39) || CHR(39)
                                            || CHR(39), CHR(39) || CHR(39));   --Se reemplazan las comillas de fechas y char al recuperarlos de la  select para que no los recupere "'asi'", sino "asi" sin las comillas.
                     UTL_FILE.put_line(ficherosalida, sentencia || sentselect || ');');
                     EXIT;
                  ELSE*/
                  -- Bug 20822 GIP003 - Fechas Duplicador de productos
                  -- Author: JMB
                  -- Modification Date: 10/01/2012
                  UTL_FILE.put_line(ficherosalida,
                                    sentencia
                                    || REPLACE(vlinia,
                                               'to_date(' || CHR(39) || CHR(39) || ','
                                               || CHR(39) || 'DD/MM/YYYY' || CHR(39) || ')',
                                               'null')
                                    || ');');
               --END IF;
               ELSE   -- ejecutamos
                  EXECUTE IMMEDIATE sentencia || vlinia || ')';
               END IF;

               IF mt.nomtabla = 'PRODTRARESC' THEN
                  --DETPRODTRARESC
                  --BUG 20822 - 23/02/2011 - JRB - Añadir las tablas de DETPRODTRARESC.
                  vlinia2 := devuelve_conf(vlinia, ',', producdest, v_codigo);
                  v_codigo2 := v_codigo;
                  -- BUG 41704 - 20/04/2016 - JMT - Error al duplicar productos, se cambia el valor 4 por un 3
                  vlinia2 := devuelve_conf(vlinia, ',', producdest, v_codigo, 3);
                  v_config := v_codigo;
                  vlinia2 := devuelve_conf(vlinia, ',', producdest, v_codigo, 5);
                  v_config := v_config || ',' || v_codigo;
                  sentselect2 :=
                     'select sidresc.currval||'',''||NVL(to_char(niniran),''null'')||'',''||nvl(to_char(nfinran),''null'')||'',''||nvl(to_char(ngraano),''null'')||'',''||nvl(to_char(nmaxano),''null'')||'',''||nvl(REPLACE(TO_CHAR(IPENALI),'','',''.''),''null'')||'',''
                     ||nvl(REPLACE(TO_CHAR(PPENALI),'','',''.''),''null'')||'',''||nvl(REPLACE(TO_CHAR(imaximo),'','',''.''),''null'')||'',''||nvl(to_char(clave),''null'')||'',''||nvl(REPLACE(TO_CHAR(iminimo),'','',''.''),''null'')||'',''
                     ||nvl(REPLACE(TO_CHAR(imimino),'','',''.''),''null'')||'',''||nvl(to_char(tmaxano),''null'')||'',''||nvl(to_char(claveimaximo),''null'')
                     from DETPRODTRARESC where sidresc in (select sidresc from prodtraresc where sproduc = '
                     || producorig || ' and  ctipmov = '
                     || v_codigo2   --|| ' and trunc(finicio)=' || v_config
                                 || ')';

                  OPEN c_select2 FOR sentselect2;

                  LOOP
                     FETCH c_select2
                      INTO vlinia2;

                     IF c_select2%NOTFOUND THEN
                        vlinia2 := NULL;
                        sentencia2 := NULL;
                        EXIT;
                     ELSE
                        sentencia2 :=
                           'INSERT INTO DETPRODTRARESC (SIDRESC,NINIRAN,NFINRAN,NGRAANO,NMAXANO,IPENALI,PPENALI,IMAXIMO,CLAVE,IMINIMO,IMIMINO,TMAXANO,CLAVEIMAXIMO) VALUES ('
                           || vlinia2 || ')';

                        IF pnomsalida IS NOT NULL THEN   -- Grabamos en fichero
                           UTL_FILE.put_line(ficherosalida,
                                             REPLACE(sentencia2,
                                                     'to_date(' || CHR(39) || CHR(39) || ','
                                                     || CHR(39) || 'DD/MM/YYYY' || CHR(39)
                                                     || ')',
                                                     'null')
                                             || ';');
                        ELSE   -- ejecutamos
                           EXECUTE IMMEDIATE sentencia2;
                        END IF;
                     END IF;
                  END LOOP;
               END IF;

               IF mt.nomtabla = 'PRODREPREC' THEN
                  --DETPRODREPREC
                  --BUG 20822 - 23/02/2011 - JRB - Añadir las tablas de DETPRODREPREC.
                  vlinia2 := devuelve_conf(vlinia, ',', producdest, v_codigo);
                  v_codigo2 := v_codigo;
                  -- BUG 41704 - 27/04/2016 - JMT - Error al duplicar productos, se cambia el valor 4 por un 3
                  vlinia2 := devuelve_conf(vlinia, ',', producdest, v_codigo, 3);
                  v_config := v_codigo;
                  v_codigo2 := v_codigo;   -- jlb
                  vlinia2 := devuelve_conf(vlinia, ',', producdest, v_codigo, 5);
                  v_config := v_config || ',' || v_codigo;
                  sentselect2 :=
                     'select sidprodp.currval||'',''||nvl(to_char(nimpagad),''null'')||'',''||nvl(to_char(cmotivo),''null'')||'',''||nvl(to_char(ndiaavis),''null'')||'',''||nvl(to_char(cmodelo),''null'')||'',''||nvl(to_char(cactimp),''null'')||'',''
                     ||nvl(to_char(cmodimm),''null'')||'',''||nvl(to_char(cactimm),''null'')||'',''||nvl(to_char(cdiaavis),''null'')
                     from DETPRODREPREC where sidprodp in (select sidprodp from PRODREPREC where sproduc = '
                     || producorig || ' and  ctipoimp = '
                     || v_codigo2   --|| ' and trunc(finiefe)=' || v_config
                                 || ')';

                  OPEN c_select2 FOR sentselect2;

                  LOOP
                     FETCH c_select2
                      INTO vlinia2;

                     IF c_select2%NOTFOUND THEN
                        vlinia2 := NULL;
                        sentencia2 := NULL;
                        EXIT;
                     ELSE
                        sentencia2 :=
                           'INSERT INTO DETPRODREPREC (SIDPRODP,NIMPAGAD,CMOTIVO,NDIAAVIS,CMODELO,CACTIMP,CMODIMM,CACTIMM,CDIAAVIS) VALUES ('
                           || vlinia2 || ')';

                        IF pnomsalida IS NOT NULL THEN   -- Grabamos en fichero
                           UTL_FILE.put_line(ficherosalida,
                                             REPLACE(sentencia2,
                                                     'to_date(' || CHR(39) || CHR(39) || ','
                                                     || CHR(39) || 'DD/MM/YYYY' || CHR(39)
                                                     || ')',
                                                     'null')
                                             || ';');
                        ELSE   -- ejecutamos
                           EXECUTE IMMEDIATE sentencia2;
                        END IF;
                     END IF;
                  END LOOP;
               END IF;
            END IF;
         END LOOP;

         --BUG 20822 - 23/02/2011 - JRB - Añadir las tablas de suplementos.
         IF mt.nomtabla = 'PDS_SUPL_CONFIG' THEN
            --PDS_SUPL_PERMITE
            sentselect :=
               'select cconfig,cconfig||' || CHR(39) || CHR(39) || CHR(39) || CHR(39)
               || '||'',''||nselect||'',''||' || CHR(39) || CHR(39) || CHR(39) || CHR(39)
               || '||replace(tselect, ' || CHR(39) || CHR(39) || CHR(39) || CHR(39) || ', '
               || CHR(39) || CHR(39) || CHR(39) || CHR(39) || CHR(39) || CHR(39)
               || ') from PDS_SUPL_PERMITE where cconfig in (select cconfig from pds_supl_config where sproduc = '
               || producorig || ')';

            OPEN c_select FOR sentselect;

            LOOP
               FETCH c_select
                INTO v_config, vlinia;

               /*if mt.nomtabla = 'IMPREC' then
                            p_tab_error(f_sysdate, F_USER, 'pac_duplicar.f_duplica', 3,
                       'vlinia: ' ,vlinia);
               end if;*/
               IF c_select%NOTFOUND THEN
                  /*Ini Bug.: 9938 - ICV - 15/05/2009 Si la ultima tabla esta a nulo no tiene que insertar el insert*/
                  vlinia := NULL;
                  sentencia := NULL;
                  /*Fin bug.: 9938*/
                  EXIT;
               ELSE
                  vlinia := REPLACE(vlinia, v_config,
                                    devuelve_conf(v_config, '_', producdest, v_codigo));
                  sentencia :=
                     'INSERT INTO PDS_SUPL_PERMITE (CCONFIG,NSELECT,TSELECT) VALUES ('
                     || CHR(39) || vlinia || CHR(39) || ')';

                  IF pnomsalida IS NOT NULL THEN   -- Grabamos en fichero
                     UTL_FILE.put_line(ficherosalida,
                                       REPLACE(sentencia,
                                               'to_date(' || CHR(39) || CHR(39) || ','
                                               || CHR(39) || 'DD/MM/YYYY' || CHR(39) || ')',
                                               'null')
                                       || ';');
                  ELSE   -- ejecutamos
                     EXECUTE IMMEDIATE sentencia;
                  END IF;
               END IF;
            END LOOP;

            --PDS_SUPL_COD_CONFIG
            sentselect :=
               'select cconfig,cconfig||' || CHR(39) || CHR(39) || CHR(39) || CHR(39)
               || '||'',''||' || CHR(39) || CHR(39) || CHR(39) || CHR(39)
               || '||cconsupl from PDS_SUPL_COD_CONFIG where cconfig in (select cconfig from pds_supl_config where sproduc = '
               || producorig || ')';

            OPEN c_select FOR sentselect;

            LOOP
               FETCH c_select
                INTO v_config, vlinia;

               IF c_select%NOTFOUND THEN
                  /*Ini Bug.: 9938 - ICV - 15/05/2009 Si la ultima tabla esta a nulo no tiene que insertar el insert*/
                  vlinia := NULL;
                  sentencia := NULL;
                  /*Fin bug.: 9938*/
                  EXIT;
               ELSE
                  vlinia := REPLACE(vlinia, v_config,
                                    devuelve_conf(v_config, '_', producdest, v_codigo));
                  sentencia :=
                     'INSERT INTO PDS_SUPL_COD_CONFIG (CCONFIG,CCONSUPL) VALUES (' || CHR(39)
                     || vlinia || CHR(39) || ')';

                  IF pnomsalida IS NOT NULL THEN   -- Grabamos en fichero
                     UTL_FILE.put_line(ficherosalida,
                                       REPLACE(sentencia,
                                               'to_date(' || CHR(39) || CHR(39) || ','
                                               || CHR(39) || 'DD/MM/YYYY' || CHR(39) || ')',
                                               'null')
                                       || ';');
                  ELSE   -- ejecutamos
                     EXECUTE IMMEDIATE sentencia;
                  END IF;
               END IF;
            END LOOP;

            --PDS_SUPL_FORM
            sentselect :=
               'select cconfig,cconfig||' || CHR(39) || CHR(39) || CHR(39) || CHR(39)
               || '||'',''||' || CHR(39) || CHR(39) || CHR(39) || CHR(39)
               || '||tform from PDS_SUPL_FORM where cconfig in (select cconfig from pds_supl_config where sproduc = '
               || producorig || ')';

            OPEN c_select FOR sentselect;

            LOOP
               FETCH c_select
                INTO v_config, vlinia;

               IF c_select%NOTFOUND THEN
                  /*Ini Bug.: 9938 - ICV - 15/05/2009 Si la ultima tabla esta a nulo no tiene que insertar el insert*/
                  vlinia := NULL;
                  sentencia := NULL;
                  /*Fin bug.: 9938*/
                  EXIT;
               ELSE
                  vlinia := REPLACE(vlinia, v_config,
                                    devuelve_conf(v_config, '_', producdest, v_codigo));
                  sentencia := 'INSERT INTO PDS_SUPL_FORM (CCONFIG,TFORM) VALUES (' || CHR(39)
                               || vlinia || CHR(39) || ')';

                  IF pnomsalida IS NOT NULL THEN   -- Grabamos en fichero
                     UTL_FILE.put_line(ficherosalida,
                                       REPLACE(sentencia,
                                               'to_date(' || CHR(39) || CHR(39) || ','
                                               || CHR(39) || 'DD/MM/YYYY' || CHR(39) || ')',
                                               'null')
                                       || ';');
                  ELSE   -- ejecutamos
                     EXECUTE IMMEDIATE sentencia;
                  END IF;
               END IF;
            END LOOP;

            --PDS_SUPL_VALIDACIO
            sentselect :=
               'select cconfig,cconfig||' || CHR(39) || CHR(39) || CHR(39) || CHR(39)
               || '||'',''||NSELECT||'',''||' || CHR(39) || CHR(39) || CHR(39) || CHR(39)
               || '||replace(tselect, ' || CHR(39) || CHR(39) || CHR(39) || CHR(39) || ', '
               || CHR(39) || CHR(39) || CHR(39) || CHR(39) || CHR(39) || CHR(39)
               || ') from PDS_SUPL_VALIDACIO where cconfig in (select cconfig from pds_supl_config where sproduc = '
               || producorig || ')';

            OPEN c_select FOR sentselect;

            LOOP
               FETCH c_select
                INTO v_config, vlinia;

               IF c_select%NOTFOUND THEN
                  /*Ini Bug.: 9938 - ICV - 15/05/2009 Si la ultima tabla esta a nulo no tiene que insertar el insert*/
                  vlinia := NULL;
                  sentencia := NULL;
                  /*Fin bug.: 9938*/
                  EXIT;
               ELSE
                  vlinia := REPLACE(vlinia, v_config,
                                    devuelve_conf(v_config, '_', producdest, v_codigo));
                  sentencia :=
                     'INSERT INTO PDS_SUPL_VALIDACIO (CCONFIG,NSELECT,TSELECT) VALUES ('
                     || CHR(39) || vlinia || CHR(39) || ')';

                  IF pnomsalida IS NOT NULL THEN   -- Grabamos en fichero
                     UTL_FILE.put_line(ficherosalida,
                                       REPLACE(sentencia,
                                               'to_date(' || CHR(39) || CHR(39) || ','
                                               || CHR(39) || 'DD/MM/YYYY' || CHR(39) || ')',
                                               'null')
                                       || ';');
                  ELSE   -- ejecutamos
                     EXECUTE IMMEDIATE sentencia;
                  END IF;
               END IF;
            END LOOP;

            --PDS_POST_SUPL
            sentselect :=
               'select cconfig,cconfig||' || CHR(39) || CHR(39) || CHR(39) || CHR(39)
               || '||'',''||norden||'',''||' || CHR(39) || CHR(39) || CHR(39) || CHR(39)
               || '||replace(tfuncion, ' || CHR(39) || CHR(39) || CHR(39) || CHR(39) || ', '
               || CHR(39) || CHR(39) || CHR(39) || CHR(39) || CHR(39) || CHR(39)
               || ') from PDS_POST_SUPL where cconfig in (select cconfig from pds_supl_config where sproduc = '
               || producorig || ')';

            OPEN c_select FOR sentselect;

            LOOP
               FETCH c_select
                INTO v_config, vlinia;

               IF c_select%NOTFOUND THEN
                  /*Ini Bug.: 9938 - ICV - 15/05/2009 Si la ultima tabla esta a nulo no tiene que insertar el insert*/
                  vlinia := NULL;
                  sentencia := NULL;
                  /*Fin bug.: 9938*/
                  EXIT;
               ELSE
                  vlinia := REPLACE(vlinia, v_config,
                                    devuelve_conf(v_config, '_', producdest, v_codigo));
                  sentencia :=
                     'INSERT INTO PDS_POST_SUPL (CCONFIG,NORDEN,TFUNCION) VALUES (' || CHR(39)
                     || vlinia || CHR(39) || ')';

                  IF pnomsalida IS NOT NULL THEN   -- Grabamos en fichero
                     UTL_FILE.put_line(ficherosalida,
                                       REPLACE(sentencia,
                                               'to_date(' || CHR(39) || CHR(39) || ','
                                               || CHR(39) || 'DD/MM/YYYY' || CHR(39) || ')',
                                               'null')
                                       || ';');
                  ELSE   -- ejecutamos
                     EXECUTE IMMEDIATE sentencia;
                  END IF;
               END IF;
            END LOOP;
         END IF;
      END LOOP;

      IF pmodulo <> 1 THEN   --8956 04/02/2009 XCG
         -- Inactivem el producte
         sentencia := 'UPDATE PRODUCTOS SET CACTIVO = 0 WHERE SPRODUC = '
                      || TO_CHAR(producdest);
      END IF;

      IF sentencia IS NOT NULL THEN
         IF pnomsalida IS NOT NULL THEN
            UTL_FILE.put_line(ficherosalida, sentencia || ';');
         ELSE
            EXECUTE IMMEDIATE sentencia;
         END IF;
      END IF;

      IF UTL_FILE.is_open(ficherosalida) THEN
         UTL_FILE.fclose(ficherosalida);
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_duplicar.f_duplica', 2,
                     'Error duplicando tabla: ' || v_nomtabla,
                     'Sentencia : ' || sentencia || ' - ' || SQLERRM);

         IF UTL_FILE.is_open(ficherosalida) THEN
            UTL_FILE.fclose(ficherosalida);
         END IF;

         RETURN 152715;
   END f_duplica;

/************************************************************************************/
   FUNCTION f_compara(
      ptablas IN NUMBER,
      pnomsalida IN VARCHAR2,
      pmodulo IN NUMBER,
      ramorig IN NUMBER,
      modaliorig IN NUMBER,
      tipsegorig IN NUMBER,
      colectorig IN NUMBER,
      ramdest IN NUMBER,
      modalidest IN NUMBER,
      tipsegdest IN NUMBER,
      colectdest IN NUMBER,
      producorig IN NUMBER,
      producdest IN NUMBER,
      contraorig IN NUMBER,
      versioorig IN NUMBER,
      contradest IN NUMBER,
      versiodest IN NUMBER,
      activiorig IN NUMBER,
      actividest IN NUMBER)
      RETURN NUMBER IS
      /*------------------------------------------------------------------------------------
           Función que compara según la especificación de la tabla PDS_DUPLICAR.
        Se genera un fichero con las diferencias
      -------------------------------------------------------------------------------------*/
      valorconcat    VARCHAR2(500);
      sentencia      VARCHAR2(30000);
      sentselect     VARCHAR2(30000);
      sentselect_invert VARCHAR2(30000);
      sentvalues     VARCHAR2(30000);
      sentwhere1     VARCHAR2(1000);
      sentwhere2     VARCHAR2(1000);
      s2             VARCHAR2(1000);
      s3             VARCHAR2(1000);
      s1             VARCHAR2(3000);
      ficherosalida  UTL_FILE.file_type;
      v_nomtabla     VARCHAR2(100);
      v_seq          VARCHAR2(100);

      TYPE t_cursor IS REF CURSOR;

      c_select       t_cursor;
      vlinia         VARCHAR2(4000);
      vvalor         vector;
      vvalor_invert  vector;
      verror         VARCHAR2(2000);
      verror_invert  VARCHAR2(2000);
      vfilas         NUMBER;
      vfilas_invert  NUMBER;
      vcols          NUMBER;
      j              NUMBER;
      vsalir         BOOLEAN;
      v_exist_dif    BOOLEAN;
      v_dif_matr     BOOLEAN;
      v_no_nulo      BOOLEAN;
      max_col_def    NUMBER := 600;   -- Max cols que evalua

      CURSOR modtablas IS
         SELECT   ttabla nomtabla
             FROM pds_duplicar
            WHERE cagrupa = ptablas
               OR ptablas IS NULL
                  AND cmodulo = pmodulo
         ORDER BY norden;

      CURSOR coltablas(ctabla VARCHAR2) IS
         SELECT column_name, data_type
           FROM all_tab_columns
          WHERE table_name = ctabla
            AND owner = NVL(f_parinstalacion_t('USER_OWNER'), f_user);

      CURSOR primaris(ctabla VARCHAR2) IS
         SELECT d.column_name col
           FROM all_constraints c, all_cons_columns d
          WHERE c.owner = NVL(f_parinstalacion_t('USER_OWNER'), f_user)
            AND c.constraint_type = 'P'
            AND c.constraint_name = d.constraint_name
            AND c.table_name = ctabla
            AND c.table_name = d.table_name
            AND c.owner = d.owner
            AND d.column_name NOT IN('CRAMO', 'CMODALI', 'CTIPSEG', 'CCOLECT', 'SCONTRA',
                                     'NVERSIO');
   BEGIN
      -- Abrimos el fichero si lo tenemos que generar
      IF pnomsalida IS NOT NULL THEN
         ficherosalida := UTL_FILE.fopen(f_parinstalacion_t('INFORMES'), pnomsalida, 'w',
                                         32767);
      END IF;

      FOR mt IN modtablas LOOP
         v_nomtabla := mt.nomtabla;
         sentselect := 'SELECT ';
         -- Parte SELECT sentselect (igual para ambas sentencias)
         sentwhere1 := ' WHERE ';   -- FROM nomtabla WHERE sentwhere1 MINUS ...
         sentwhere2 := ' WHERE ';
         s2 := ') C, ' || mt.nomtabla || ' T WHERE ';
         -- ... SELECT sentselect FROM nomtabla WHERE sentwhere2
         s3 := s2;
         valorconcat := NULL;
         v_dif_matr := FALSE;

         FOR ct IN coltablas(mt.nomtabla) LOOP
            IF ct.column_name = 'CRAMO' THEN
               valorconcat := NULL;

               IF ramorig IS NOT NULL THEN
                  sentwhere1 := sentwhere1 || 'CRAMO = ' || ramorig || ' AND ';
                  s3 := s3 || 'T.' || 'CRAMO (+) = ' || ramorig || ' AND ';
               END IF;

               IF ramdest IS NOT NULL THEN
                  sentwhere2 := sentwhere2 || 'CRAMO = ' || ramdest || ' AND ';
                  s2 := s2 || 'T.' || 'CRAMO (+) = ' || ramdest || ' AND ';
               END IF;
            ELSIF ct.column_name = 'CMODALI' THEN
               valorconcat := NULL;

               IF modaliorig IS NOT NULL THEN
                  sentwhere1 := sentwhere1 || 'CMODALI = ' || modaliorig || ' AND ';
                  s3 := s3 || 'T.' || 'CMODALI (+) = ' || modaliorig || ' AND ';
               END IF;

               IF modalidest IS NOT NULL THEN
                  sentwhere2 := sentwhere2 || 'CMODALI = ' || modalidest || ' AND ';
                  s2 := s2 || 'T.' || 'CMODALI (+) = ' || modalidest || ' AND ';
               END IF;
            ELSIF ct.column_name = 'CTIPSEG' THEN
               valorconcat := NULL;

               IF tipsegorig IS NOT NULL THEN
                  sentwhere1 := sentwhere1 || 'CTIPSEG = ' || tipsegorig || ' AND ';
                  s3 := s3 || 'T.' || 'CTIPSEG (+) = ' || tipsegorig || ' AND ';
               END IF;

               IF tipsegdest IS NOT NULL THEN
                  sentwhere2 := sentwhere2 || 'CTIPSEG = ' || tipsegdest || ' AND ';
                  s2 := s2 || 'T.' || 'CTIPSEG (+) = ' || tipsegdest || ' AND ';
               END IF;
            ELSIF ct.column_name = 'CCOLECT' THEN
               valorconcat := NULL;

               IF colectorig IS NOT NULL THEN
                  sentwhere1 := sentwhere1 || 'CCOLECT = ' || colectorig || ' AND ';
                  s3 := s3 || 'T.' || 'CCOLECT (+) = ' || colectorig || ' AND ';
               END IF;

               IF colectdest IS NOT NULL THEN
                  sentwhere2 := sentwhere2 || 'CCOLECT = ' || colectdest || ' AND ';
                  s2 := s2 || 'T.' || 'CCOLECT (+) = ' || colectdest || ' AND ';
               END IF;
            ELSIF ct.column_name = 'SPRODUC' THEN
               valorconcat := NULL;

               IF producorig IS NOT NULL THEN
                  sentwhere1 := sentwhere1 || 'SPRODUC = ' || producorig || ' AND ';
                  s3 := s3 || 'T.' || 'SPRODUC (+) = ' || producorig || ' AND ';
               END IF;

               IF producdest IS NOT NULL THEN
                  sentwhere2 := sentwhere2 || 'SPRODUC = ' || producdest || ' AND ';
                  s2 := s2 || 'T.' || 'SPRODUC (+) = ' || producdest || ' AND ';
               END IF;
            ELSIF ct.column_name = 'SCONTRA' THEN
               valorconcat := NULL;

               IF contraorig IS NOT NULL THEN
                  sentwhere1 := sentwhere1 || 'SCONTRA = ' || contraorig || ' AND ';
                  s3 := s3 || 'T.' || 'SCONTRA (+) = ' || contraorig || ' AND ';
               END IF;

               IF contradest IS NOT NULL THEN
                  sentwhere2 := sentwhere2 || 'SCONTRA = ' || contradest || ' AND ';
                  s2 := s2 || 'T.' || 'SCONTRA (+) = ' || contradest || ' AND ';
               END IF;
            ELSIF ct.column_name = 'NVERSIO' THEN
               valorconcat := NULL;

               IF versioorig IS NOT NULL THEN
                  sentwhere1 := sentwhere1 || 'NVERSIO = ' || versioorig || ' AND ';
                  s3 := s3 || 'T.' || 'NVERSIO (+) = ' || versioorig || ' AND ';
               END IF;

               IF versiodest IS NOT NULL THEN
                  sentwhere2 := sentwhere2 || 'NVERSIO = ' || versiodest || ' AND ';
                  s2 := s2 || 'T.' || 'NVERSIO (+) = ' || versiodest || ' AND ';
               END IF;
--            ELSIF ct.column_name = 'CACTIVI' THEN
--          valorconcat:= NULL;
--               IF activiorig IS NOT NULL THEN
--                  sentwhere1 :=
--                           sentwhere1 || 'CACTIVI = ' || activiorig || ' AND ';
--               END IF;
--               IF actividest IS NOT NULL THEN
--                  sentwhere2 :=
--                           sentwhere2 || 'CACTIVI = ' || actividest || ' AND ';
--               END IF;
            ELSIF ct.column_name LIKE 'S%'
                  AND ct.column_name <> 'SCLABEN' THEN
               v_seq := NULL;

               BEGIN
                  SELECT DISTINCT b.sequence_name
                             INTO v_seq
                             FROM all_constraints a, all_sequences b, all_ind_columns c
                            WHERE a.constraint_type = 'P'
                              AND a.owner = NVL(f_parinstalacion_t('USER_OWNER'), f_user)
                              AND c.column_name = ct.column_name
                              AND c.index_owner = a.owner
                              AND b.sequence_name = c.column_name
                              AND b.sequence_owner = c.index_owner
                              AND a.table_name = c.table_name
                              AND a.constraint_name = c.index_name
                              AND c.table_name = mt.nomtabla;
               EXCEPTION
                  WHEN OTHERS THEN
                     v_seq := NULL;
               END;

               IF v_seq IS NULL THEN
                  valorconcat := ct.column_name;
               ELSE   -- No se comparan campos de origen secuence
                  valorconcat := NULL;
               END IF;
            ELSE   -- resto de campos
               valorconcat := ct.column_name;
            END IF;

            IF valorconcat IS NOT NULL THEN
               -- si es pk y no es cramo,cmodali,... -> añadir "T."||valorconcat
               FOR pk IN primaris(mt.nomtabla) LOOP
                  v_dif_matr := TRUE;

                  -- existen pk's y no son ramo,modali,...
                  IF valorconcat = pk.col THEN
                     valorconcat := 'T.' || valorconcat;
                  END IF;
               END LOOP;

               IF sentselect = 'SELECT ' THEN
                  sentselect := sentselect || valorconcat;
               ELSE
                  sentselect := sentselect || ',' || valorconcat;
               END IF;
            END IF;
         END LOOP;   -- Fin coltablas

         s1 := 'SELECT ';

         -- constrir select...union...select con columnas pk que no son ramo,modali,...
         FOR pk IN primaris(mt.nomtabla) LOOP
            IF s1 = 'SELECT ' THEN
               s1 := s1 || pk.col;
            ELSE
               s1 := s1 || ',' || pk.col;
            END IF;
         END LOOP;

         IF sentselect = 'SELECT ' THEN   -- No se han recuperado campos
            EXIT;
         END IF;

         sentwhere1 := RTRIM(sentwhere1, 'AND ');
         sentwhere2 := RTRIM(sentwhere2, 'AND ');
         s2 := RTRIM(s2, 'AND ');
         s3 := RTRIM(s3, 'AND ');

         FOR pk IN primaris(mt.nomtabla) LOOP
            IF s2 = ') C, ' || mt.nomtabla || ' T WHERE ' THEN
               s2 := s2 || ' T.' || pk.col || ' (+) = C.' || pk.col;
            ELSE
               s2 := s2 || ' AND T.' || pk.col || ' (+) = C.' || pk.col;
            END IF;

            IF s3 = ') C, ' || mt.nomtabla || ' T WHERE ' THEN
               s3 := s3 || ' T.' || pk.col || ' (+) = C.' || pk.col;
            ELSE
               s3 := s3 || ' AND T.' || pk.col || ' (+) = C.' || pk.col;
            END IF;
         END LOOP;

         IF v_dif_matr THEN   -- regs en 1 sentido y no en el otro
            sentselect_invert := sentselect || ' FROM ( ' || s1 || ' FROM ' || mt.nomtabla
                                 || ' ' || sentwhere1 || ' UNION ' || s1 || ' FROM '
                                 || mt.nomtabla || ' ' || sentwhere2 || s3;
            sentselect := sentselect || ' FROM ( ' || s1 || ' FROM ' || mt.nomtabla || ' '
                          || sentwhere1 || ' UNION ' || s1 || ' FROM ' || mt.nomtabla || ' '
                          || sentwhere2 || s2;
         ELSE   -- mismo nº regs
            sentselect_invert := sentselect || ' FROM ' || mt.nomtabla || sentwhere2
                                 || ' MINUS ' || sentselect || ' FROM ' || mt.nomtabla
                                 || sentwhere1;
            sentselect := sentselect || ' FROM ' || mt.nomtabla || sentwhere1 || ' MINUS '
                          || sentselect || ' FROM ' || mt.nomtabla || sentwhere2;
         END IF;

         --UTL_FILE.put_line (ficherosalida, 's1: ' || s1);
         --UTL_FILE.put_line (ficherosalida, 'sentwhere1: ' || sentwhere1);
         --UTL_FILE.put_line (ficherosalida, 'UNION');
         --UTL_FILE.put_line (ficherosalida, 's1: ' || s1);
         --UTL_FILE.put_line (ficherosalida, 'sentwhere2: ' || sentwhere2);
         --UTL_FILE.put_line (ficherosalida, 's2: ' || s2);
         --UTL_FILE.put_line (ficherosalida, 'sentselect: ' || sentselect);
         --UTL_FILE.put_line (ficherosalida, 'sentselect_invert: ' || sentselect_invert);
         IF pnomsalida IS NOT NULL THEN   -- Grabamos en fichero
            vvalor := consultar(sentselect, verror, vfilas);
            vvalor_invert := consultar(sentselect_invert, verror_invert, vfilas_invert);

            --UTL_FILE.put_line (ficherosalida,'verror:'||verror||',vfilas:'||vfilas||',vfilas_invert:'||vfilas_invert);
            IF NVL(verror, 0) = 0 THEN
               /*              IF     vfilas > 0
                                            AND vfilas_invert > 0
                                AND vfilas = vfilas_invert THEN    */
               IF vfilas > 0 THEN   -- hay diferencias
                  UTL_FILE.put_line(ficherosalida,
                                    'Diferencias en Tabla: ' || mt.nomtabla
                                    || ' entre producto ' || producorig || ' y ' || producdest);
                  v_no_nulo := FALSE;

                  FOR i IN 1 .. vfilas LOOP
                     vcols := max_col_def;
                     j := 1;
                     vsalir := FALSE;

                     IF v_dif_matr THEN
                        UTL_FILE.put_line(ficherosalida,
                                          'Clave: ' || vvalor(0)(j) || '-- '
                                          || NVL(vvalor(i)(j), vvalor_invert(i)(j)));
                        v_no_nulo := TRUE;
                     END IF;

                     WHILE j < vcols
                      AND NOT vsalir LOOP
                        BEGIN
                           IF NVL(vvalor(i)(j), 'NULO') <> NVL(vvalor_invert(i)(j), 'NULO') THEN
                              UTL_FILE.put_line(ficherosalida,
                                                'Producto: ' || producorig || ' - '
                                                || vvalor(0)(j) || ': ' || vvalor(i)(j)
                                                || '  ' || 'Producto: ' || producdest || ' - '
                                                || vvalor_invert(0)(j) || ': '
                                                || vvalor_invert(i)(j));
                           END IF;

                           j := j + 1;
                        EXCEPTION
                           WHEN OTHERS THEN
                              --
                              BEGIN
                                 IF vvalor(0)(j) <> vvalor(i)(j) THEN
-- casos en q recupera 1 sola columna e incluye el nombre de columna en j=1. "vvalor (0) (j=1)"
                                    UTL_FILE.put_line(ficherosalida,
                                                      'Esta en Producto: ' || producorig
                                                      || ' - ' || vvalor(0)(j) || ': '
                                                      || vvalor(i)(j));
                                 END IF;

                                 j := j + 1;
                              EXCEPTION
                                 WHEN OTHERS THEN
                                    j := 1;
                                    vsalir := TRUE;

                                    IF NOT v_dif_matr
                                       OR(v_dif_matr
                                          AND v_no_nulo) THEN
                                       UTL_FILE.put_line(ficherosalida, '');
                                       v_no_nulo := FALSE;
                                    END IF;
                              END;
                        END;
                     END LOOP;
                  END LOOP;

                  UTL_FILE.put_line(ficherosalida, '');
                  UTL_FILE.put_line(ficherosalida, '');
                  v_exist_dif := TRUE;
               END IF;
            -- parte nueva para filas_invert
            /*
                                          IF vfilas_invert > 0 THEN                       -- hay diferencias
                                 UTL_FILE.put_line (ficherosalida,
                                                    'Diferencias en Tabla: '
                                                    || mt.nomtabla||' entre producto '||producdest||' y '||producorig);
                                 v_no_nulo:= FALSE;
                            FOR i IN 0 .. vfilas_invert LOOP
                                    vcols := max_col_def;
                                    j := 1;
                                    vsalir := FALSE;
                                    WHILE j < vcols
                                     AND NOT vsalir LOOP
                                       BEGIN
                                          IF vvalor (i) (j) <> vvalor_invert (i) (j) THEN
                                             UTL_FILE.put_line (ficherosalida,
                                                                'Producto: '
                                                                || producdest || ' - '
                                                                || vvalor_invert (0) (j) || ': '
                                                                || vvalor_invert (i) (j) || '      '
                                                                || 'Producto: '
                                                                || producorig || ' - '
                                                                || vvalor (0) (j)
                                                                || ': '
                                                                || vvalor (i) (j));
                                   ELSE
                                     IF v_dif_matr AND i <> 0 AND vvalor_invert (i) (j) IS NOT NULL THEN -- solo cuando existe en 1 sentido y no en otro. Y omitimos titulo cols y nulos
                                        UTL_FILE.put_line (ficherosalida, 'Producto: '
                                                                || producdest || ' - '
                                                                || vvalor_invert (0) (j) || ': '
                                                                || vvalor_invert (i) (j));
                                      END IF;
                                          END IF;
                                          j := j + 1;
                                       EXCEPTION
                                          WHEN OTHERS THEN
                                      --
                                     BEGIN
                                         IF vvalor_invert (0) (j) <> vvalor_invert (i) (j) THEN -- casos en q recupera 1 sola columna e incluye el nombre de columna en j=1. "vvalor_invert (0) (j=1)"
                                                    UTL_FILE.put_line (ficherosalida,
                                                                'Esta en Producto: '
                                                                || producdest || ' - '
                                                                || vvalor_invert (0) (j) || ': '
                                                                || vvalor_invert (i) (j));
                                         END IF;
                                         j := j + 1;
                                     EXCEPTION
                                            WHEN OTHERS THEN
                                                j := 1;
                                                vsalir := TRUE;
                                                IF NOT v_dif_matr OR (v_dif_matr AND v_no_nulo) THEN
                                                     UTL_FILE.put_line (ficherosalida, '');
                                                  v_no_nulo:= FALSE;
                                                END IF;
                                     END;
                                       END;
                                    END LOOP;
                                 END LOOP;
                                 UTL_FILE.put_line (ficherosalida, '');
                                 UTL_FILE.put_line (ficherosalida, '');
                                 v_exist_dif := TRUE;
                              END IF;
            */
            --END IF;
            END IF;
         END IF;
      END LOOP;   -- fin modtablas

      IF NOT v_exist_dif THEN
         UTL_FILE.put_line(ficherosalida,
                           'No existen diferencias entre los productos ' || producorig
                           || ' y ' || producdest || '.');
      END IF;

      IF UTL_FILE.is_open(ficherosalida) THEN
         UTL_FILE.fclose(ficherosalida);
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_duplicar.f_compara', 2,
                     'Error comparando tabla: ' || v_nomtabla, SQLERRM);

         IF UTL_FILE.is_open(ficherosalida) THEN
            UTL_FILE.fclose(ficherosalida);
         END IF;

         RETURN 152715;
   END f_compara;

/************************************************************************************/
   FUNCTION f_dup_producto(
      ramorig IN NUMBER,
      modaliorig IN NUMBER,
      tipsegorig IN NUMBER,
      colectorig IN NUMBER,
      ramdest IN NUMBER,
      modalidest IN NUMBER,
      tipsegdest IN NUMBER,
      colectdest IN NUMBER,
      tipotablas IN NUMBER DEFAULT NULL,
      psalida IN NUMBER DEFAULT NULL,
      producdest IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      /*------------------------------------------------------------------------------------
           Función que permite duplicar todas las tablas relacionadas a productos.
        Estas tablas estarán definidas en PDS_DUPLICAR.
        Se podrá generar un fichero o ejecutar directamente la duplicación
        Si el sproducDest es nulo i no existe el nuevo producto, se crea un nuevo
        producto con el siguiente sproduc, si viene informado, se cogerá ese valor
        como nuevo.
      -------------------------------------------------------------------------------------*/
      nexistprodorig NUMBER;
      nexistramorig  NUMBER(6);
      nsproddest     NUMBER(6);
      nomfit         VARCHAR2(100);
   BEGIN
      BEGIN
         SELECT sproduc
           INTO nexistprodorig
           FROM productos
          WHERE cramo = ramorig
            AND cmodali = modaliorig
            AND ctipseg = tipsegorig
            AND ccolect = colectorig;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN 104347;   -- Producto Origen no encontrado
      END;

      BEGIN
         SELECT cramo
           INTO nexistramorig
           FROM ramos
          WHERE cramo = ramdest;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN 101904;   -- Ramo Destino no encontrado
         WHEN TOO_MANY_ROWS THEN
            NULL;
      END;

      BEGIN
         SELECT sproduc
           INTO nsproddest
           FROM productos
          WHERE cramo = ramdest
            AND cmodali = modalidest
            AND ctipseg = tipsegdest
            AND ccolect = colectdest;

         --(JAS)21.04.2008 - Retorno error si vull executar la duplicació directe a base de dades d'un producte ja existent.
         --Si el vol generar l'script de duplicació (psalida=1), no donem error, ja que el que s'està fent en realitat
         --no es duplicar el producte, sinó generar un script de creació per replicar el producte en altres entorns.
         IF psalida <> 1 THEN
            RETURN 100734;   --Producto ya existe
         END IF;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            IF producdest IS NULL THEN
               SELECT sproduc.NEXTVAL
                 INTO nsproddest
                 FROM DUAL;
            ELSE
               nsproddest := producdest;
            END IF;
      END;

      SELECT DECODE(psalida,
                    1, 'Duplicar_prod_' || nexistprodorig || 'a' || nsproddest || '.sql',
                    NULL)
        INTO nomfit
        FROM DUAL;

      RETURN f_duplica(tipotablas, nomfit, 1,   --producto
                       ramorig, modaliorig, tipsegorig, colectorig, ramdest, modalidest,
                       tipsegdest, colectdest, nexistprodorig, nsproddest, NULL, NULL, NULL,
                       NULL, NULL, NULL);
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_duplicar.f_dup_producto', 2,
                     'Error en la duplicación', SQLERRM);
         RETURN 152715;
   END f_dup_producto;

   FUNCTION f_dup_contrato(
      pscontra IN NUMBER,
      pnversio IN NUMBER,
      tipotablas IN NUMBER DEFAULT NULL,
      psalida IN NUMBER DEFAULT NULL,
      ramdest IN NUMBER DEFAULT NULL,
      modalidest IN NUMBER DEFAULT NULL,
      tipsegdest IN NUMBER DEFAULT NULL,
      colectdest IN NUMBER DEFAULT NULL,
      pactividest IN NUMBER DEFAULT NULL,
      pgarantdest IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      /*------------------------------------------------------------------------------------
        Función que permite duplicar todas las tablas relacionadas con un contrato de
        reaseguro.
        Estas tablas estarán definidas en PDS_DUPLICAR.
        Se podrá generar un fichero o ejecutar directamente la duplicación
      -------------------------------------------------------------------------------------*/
      contradest     NUMBER;
      nomfit         VARCHAR2(100);
   BEGIN
      SELECT scontra.NEXTVAL
        INTO contradest
        FROM DUAL;

      SELECT DECODE(psalida,
                    1, 'Duplicar_contra_' || pscontra || 'a' || contradest || '.sql',
                    NULL)
        INTO nomfit
        FROM DUAL;

      RETURN f_duplica(tipotablas, nomfit, 2,   --contrato
                       NULL, NULL, NULL, NULL, ramdest, modalidest, tipsegdest, colectdest,
                       NULL, NULL, pscontra, pnversio, contradest, 1, NULL, NULL);
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_duplicar.f_dup_producto', 2,
                     'Error incontrolado', SQLERRM);
         RETURN 140999;
   END f_dup_contrato;

   FUNCTION f_dup_actividad(
      ramorig IN NUMBER,
      modaliorig IN NUMBER,
      tipsegorig IN NUMBER,
      colectorig IN NUMBER,
      activiorig IN NUMBER,
      actividest IN NUMBER,
      tipotablas IN NUMBER DEFAULT NULL,
      psalida IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      /*------------------------------------------------------------------------------------
        Función que permite duplicar todas las tablas relacionadas a productos.
        Estas tablas estarán definidas en PDS_DUPLICAR.
        Se podrá generar un fichero o ejecutar directamente la duplicación
        Si el sproducDest es nulo i no existe el nuevo producto, se crea un nuevo
        producto con el siguiente sproduc, si viene informado, se cogerá ese valor
        como nuevo.
      -------------------------------------------------------------------------------------*/
      nexistprodorig NUMBER;
      nexistramorig  NUMBER(6);
      naux           NUMBER;
      nomfit         VARCHAR2(100);
   BEGIN
      BEGIN
         SELECT sproduc
           INTO nexistprodorig
           FROM productos
          WHERE cramo = ramorig
            AND cmodali = modaliorig
            AND ctipseg = tipsegorig
            AND ccolect = colectorig;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN 104347;   -- Producto Origen no encontrado
      END;

      SELECT DECODE(psalida,
                    1, 'Duplicar_actividad_' || activiorig || 'a' || actividest || '.sql',
                    NULL)
        INTO nomfit
        FROM DUAL;

      RETURN f_duplica(tipotablas, nomfit, 3,   --actividad
                       ramorig, modaliorig, tipsegorig, colectorig, ramorig, modaliorig,
                       tipsegorig, colectorig, nexistprodorig, nexistprodorig, NULL, NULL,
                       NULL, NULL, activiorig, actividest);
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_duplicar.f_dup_actividad', 2,
                     'Error incontrolado', SQLERRM);
         RETURN 140999;
   END f_dup_actividad;

   FUNCTION f_borra_producto(
      ramo IN NUMBER,
      modali IN NUMBER,
      tipseg IN NUMBER,
      colect IN NUMBER,
      tipotablas IN NUMBER DEFAULT NULL,
      psalida IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
/*------------------------------------------------------------------------------------
  Función que permite borrar productos.
-------------------------------------------------------------------------------------*/
      nsprod         NUMBER(6);
      nomfit         VARCHAR2(100);
   BEGIN
      nsprod := 0;

      SELECT COUNT(*)
        INTO nsprod
        FROM seguros
       WHERE cramo = ramo
         AND cmodali = modali
         AND ctipseg = tipseg
         AND ccolect = colect;

      IF nsprod > 0 THEN
         RETURN 152713;   -- Producto amb pòlisses, no es pot esborrar
      END IF;

      BEGIN
         SELECT sproduc
           INTO nsprod
           FROM productos
          WHERE cramo = ramo
            AND cmodali = modali
            AND ctipseg = tipseg
            AND ccolect = colect;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN 104347;   -- Producto a borrar no encontrado
      END;

      SELECT DECODE(psalida, 1, 'Borrar_prod_' || nsprod || '.sql', NULL)
        INTO nomfit
        FROM DUAL;

      RETURN f_borra(tipotablas, nomfit, 1,   --producto
                     ramo, modali, tipseg, colect, nsprod, NULL, NULL, NULL);
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_duplicar.f_borra_producto', 2,
                     'Error en el borrado', SQLERRM);
         RETURN 152715;
   END f_borra_producto;

/*************************************************/
   FUNCTION f_comp_productos(
      ramorig IN NUMBER,
      modaliorig IN NUMBER,
      tipsegorig IN NUMBER,
      colectorig IN NUMBER,
      ramdest IN NUMBER,
      modalidest IN NUMBER,
      tipsegdest IN NUMBER,
      colectdest IN NUMBER,
      tipotablas IN NUMBER DEFAULT NULL,
      psalida IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
/*------------------------------------------------------------------------------------
     Función que compara productos.
-------------------------------------------------------------------------------------*/
      nexistprodorig NUMBER;
      nexistramorig  NUMBER(6);
      nsproddest     NUMBER(6);
      nomfit         VARCHAR2(100);
   BEGIN
      BEGIN
         SELECT sproduc
           INTO nexistprodorig
           FROM productos
          WHERE cramo = ramorig
            AND cmodali = modaliorig
            AND ctipseg = tipsegorig
            AND ccolect = colectorig;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN 104347;   -- Producto Origen no encontrado
      END;

      BEGIN
         SELECT cramo
           INTO nexistramorig
           FROM ramos
          WHERE cramo = ramdest;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN 101904;   -- Ramo Destino no encontrado
         WHEN TOO_MANY_ROWS THEN
            NULL;
      END;

      BEGIN
         SELECT sproduc
           INTO nsproddest
           FROM productos
          WHERE cramo = ramdest
            AND cmodali = modalidest
            AND ctipseg = tipsegdest
            AND ccolect = colectdest;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN 101904;   -- Ramo Destino no encontrado
      END;

      SELECT DECODE(psalida,
                    1, 'Compara_prod_' || nexistprodorig || '_con_' || nsproddest || '.sql',
                    NULL)
        INTO nomfit
        FROM DUAL;

      RETURN f_compara(tipotablas, nomfit, 1,   --producto
                       ramorig, modaliorig, tipsegorig, colectorig, ramdest, modalidest,
                       tipsegdest, colectdest, nexistprodorig, nsproddest, NULL, NULL, NULL,
                       NULL, NULL, NULL);
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_duplicar.f_comp_productos', 2,
                     'Error en la comparación', SQLERRM);
         RETURN 152715;
   END f_comp_productos;

-- 16/07/2012 - MDS - 0022824: LCOL_T010-Duplicado de propuestas
/************************************************/
   FUNCTION f_duplica_seguro(
      sseguroorig IN NUMBER,
      ssegurodest IN NUMBER,
      nsolicidest IN NUMBER,
      npolizadest IN NUMBER,
      ncertifdest IN NUMBER,
      tipotablas IN NUMBER,
      pmodulo IN NUMBER,
      pcsituacorig IN NUMBER)   -- BUG 29965 - FAL - 05/02/2014
      RETURN NUMBER IS
      valorconcat    VARCHAR2(500);
      sentencia      VARCHAR2(30000);
      sentselect     VARCHAR2(30000);
      sentwhere      VARCHAR2(1000);
      v_nomtabla     VARCHAR2(100);
      v_seq          VARCHAR2(100);
      vlinia         VARCHAR2(4000);
      vntraza        NUMBER;

      TYPE t_cursor IS REF CURSOR;

      c_select       t_cursor;

      CURSOR modtablas IS
         SELECT   ttabla nomtabla
             FROM pds_duplicar
            WHERE (cagrupa = tipotablas
                   OR tipotablas IS NULL)
              AND cmodulo = pmodulo
              AND((NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa(),
                                                     'MODULO_SINI'),
                       0)) = 1
                  OR UPPER(ttabla) NOT LIKE 'SIN_%')
         ORDER BY norden;

      CURSOR coltablas(ctabla VARCHAR2) IS
         SELECT column_name, data_type, data_length
           FROM all_tab_columns
          WHERE table_name = ctabla
            AND owner = NVL(f_parinstalacion_t('USER_OWNER'), f_user)
            AND table_name NOT IN(SELECT t2.table_name
                                    FROM all_tab_columns t2
                                   WHERE t2.owner = f_user);
   BEGIN
      /*------------------------------------------------------------------------------------
           Función que duplica según la especificación de la tabla PDS_DUPLICAR.
        Se ejecuta directamente la duplicación.
        Está basada en la función f_duplica.
      -------------------------------------------------------------------------------------*/

      -- recorrido de las tablas a duplicar
      FOR mt IN modtablas LOOP
         vntraza := 1;
         v_nomtabla := mt.nomtabla;
         sentencia := 'INSERT INTO ' || mt.nomtabla || ' (';
         sentselect := 'SELECT ';
         sentwhere := ' WHERE ';

         -- recorrido de los campos de la tabla a duplicar
         FOR ct IN coltablas(mt.nomtabla) LOOP
            vntraza := 2;
            sentencia := sentencia || ct.column_name || ', ';

            -- valorconcat : campo de la tabla
            IF ct.data_type = 'DATE' THEN
               valorconcat := CHR(39) || 'to_date(' || CHR(39) || CHR(39) || CHR(39) || '||'
                              || 'to_char(' || ct.column_name || ',' || CHR(39)
                              || 'DD/MM/YYYY' || CHR(39) || ')' || '||' || CHR(39) || CHR(39)
                              || CHR(39) || ',' || CHR(39) || CHR(39) || 'DD/MM/YYYY'
                              || CHR(39) || CHR(39) || ')' || CHR(39);
            ELSIF ct.data_type IN('VARCHAR2', 'CHAR', 'CLOB') THEN
               valorconcat := CHR(39) || CHR(39) || CHR(39) || CHR(39) || '||'
                              || ct.column_name || '||' || CHR(39) || CHR(39) || CHR(39)
                              || CHR(39);
            ELSE
               valorconcat := 'NVL(replace(to_char(' || ct.column_name
                              || '),'','',''.''),''null'')';
            END IF;

            vntraza := 3;

            -- valorconcat : un valor fijo, para el caso de campos con valor destino informado
            IF ct.column_name = 'SSEGURO' THEN
               IF ssegurodest IS NOT NULL THEN
                  valorconcat := TO_CHAR(ssegurodest);
               END IF;

               IF sseguroorig IS NOT NULL THEN
                  sentwhere := sentwhere || 'SSEGURO = ' || sseguroorig || ' AND ';
               END IF;
            ELSIF ct.column_name = 'NSOLICI' THEN
               IF nsolicidest IS NOT NULL THEN
                  valorconcat := TO_CHAR(nsolicidest);
               END IF;
            ELSIF ct.column_name = 'NPOLIZA' THEN
               IF npolizadest IS NOT NULL THEN
                  valorconcat := TO_CHAR(npolizadest);
               END IF;
            ELSIF ct.column_name = 'NCERTIF' THEN
               IF ncertifdest IS NOT NULL THEN
                  valorconcat := TO_CHAR(ncertifdest);
               END IF;
            ELSIF ct.column_name LIKE 'S%'
                  -- Bug 0028455/0156611 - JSV - 23/10/2013
                  --AND ct.column_name NOT IN('SCLABEN', 'SBONUS', 'SSEGURO', 'SPERSON') THEN
                  AND ct.column_name NOT IN('SCLAGEN', 'SCLABEN', 'SBONUS', 'SSEGURO',
                                            'SPERSON') THEN
               BEGIN
                  SELECT DISTINCT b.sequence_name
                             INTO v_seq
                             FROM all_constraints a, all_sequences b, all_ind_columns c
                            WHERE a.constraint_type = 'P'
                              AND a.owner = NVL(f_parinstalacion_t('USER_OWNER'), f_user)
                              AND c.column_name = ct.column_name
                              AND c.index_owner = a.owner
                              AND b.sequence_name = c.column_name
                              AND b.sequence_owner = c.index_owner
                              AND a.table_name = c.table_name
                              AND a.constraint_name = c.index_name
                              AND c.table_name = mt.nomtabla;

                  v_seq := v_seq || '.NEXTVAL';

                  SELECT v_seq
                    INTO valorconcat
                    FROM DUAL;
               EXCEPTION
                  WHEN OTHERS THEN
                     NULL;
               END;
            -- BUG 29965 - FAL - 05/02/2014. Duplica pólizas en cualquier situación distinta a Prop. alta
            ELSIF ct.column_name = 'NMOVIMI'
                  AND pcsituacorig <> 4
                  AND mt.nomtabla <> 'MOVSEGURO' THEN
               sentwhere := sentwhere || 'NMOVIMI = (select max(nmovimi) from ' || mt.nomtabla
                            || ' where sseguro = ' || sseguroorig || ') AND ';
               valorconcat := '1';
            ELSIF ct.column_name = 'NMOVIMI'
                  AND pcsituacorig <> 4
                  AND mt.nomtabla = 'MOVSEGURO' THEN
               sentwhere := sentwhere || 'NMOVIMI = 1 AND ';
            -- FI BUG 29965 - FAL - 05/02/2014
            END IF;

            vntraza := 4;

            IF sentselect = 'SELECT ' THEN
               sentselect := sentselect || valorconcat;
            ELSE
               sentselect := sentselect || '||'',''||' || valorconcat;
            END IF;
         END LOOP;

         vntraza := 5;
         sentencia := RTRIM(sentencia, ', ') || ') VALUES (';
         sentwhere := RTRIM(sentwhere, 'AND ');
         sentselect := sentselect || ' FROM ' || mt.nomtabla || sentwhere;

         -- ejecución de las sentencias
         OPEN c_select FOR sentselect;

         vntraza := 6;

         LOOP
            FETCH c_select
             INTO vlinia;

            IF c_select%NOTFOUND THEN
               vlinia := NULL;
               sentencia := NULL;
               EXIT;
            ELSE
               -- ejecutar la sentencia
               EXECUTE IMMEDIATE sentencia || vlinia || ')';
            --DBMS_OUTPUT.put_line(sentencia || vlinia || ');');
            END IF;
         END LOOP;
      END LOOP;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_duplicar.f_duplica_seguro', vntraza,
                     'Error duplicando tabla: ' || v_nomtabla,
                     'Sentencia : ' || sentencia || ' - ' || SQLERRM);
         RETURN 152715;
   END f_duplica_seguro;

   -- 16/07/2012 - MDS - 0022824: LCOL_T010-Duplicado de propuestas
   FUNCTION f_dup_seguro(
      sseguroorig IN NUMBER,
      pfefecto IN DATE,
      pobservaciones IN VARCHAR2,
      ssegurodest IN OUT NUMBER,
      nsolicidest OUT NUMBER,
      npolizadest OUT NUMBER,
      ncertifdest OUT NUMBER,
      tipotablas IN NUMBER DEFAULT NULL,
      pcagente IN NUMBER DEFAULT NULL)   --RAMIRO
      RETURN NUMBER IS
      v_npoliza      seguros.npoliza%TYPE;
      v_fvencim      seguros.fvencim%TYPE;
      v_cduraci      seguros.cduraci%TYPE;
      v_fefecto      seguros.fefecto%TYPE;
      v_fcancel      seguros.fcancel%TYPE;
      v_sproduc      productos.sproduc%TYPE;
      v_cramo        productos.cramo%TYPE;
      v_sproces      NUMBER;
      vntraza        NUMBER;
      v_cont         NUMBER;
      verror         NUMBER;
      v_nsoliciorig  seguros.nsolici%TYPE;   -- Bug 27147/0146044 - APD - 11/06/2013
      v_csituac      seguros.csituac%TYPE;   -- Bug 26923/146526 - DCT - 12/06/2013
      v_nrenova      NUMBER;
      v_numaddpoliza NUMBER;
      v_calemp       NUMBER := pac_md_common.f_get_cxtempresa;
      v_max_nmovimi  movseguro.nmovimi%TYPE;
      v_sestudi      NUMBER;
      v_prodagente   NUMBER;   --ramiro
      v_agente       NUMBER;   --ramiro
   BEGIN
      /*------------------------------------------------------------------------------------
           Función que permite duplicar todas las tablas relacionadas a seguros. Se ejecuta directamente la duplicación.
        Estas tablas estarán definidas en PDS_DUPLICAR.
        Si el sseguroorig es nulo, error.
        Si el ssegurodest es nulo, se crea un nuevo seguro con el siguiente sseguro.
        Si el ssegurodest viene informado, se cogerá ese valor como nuevo.
      -------------------------------------------------------------------------------------*/
      IF sseguroorig IS NULL
         OR pfefecto IS NULL THEN
         RETURN 101919;
      END IF;

      vntraza := 1;

      -- obtiene información del seguro origen
      -- Bug 27147/0146044 - APD - 11/06/2013 - se añade el campo nsolici
      SELECT se.npoliza, se.fvencim, se.cduraci, se.fefecto, se.fcancel, pr.sproduc, pr.cramo,
             se.nsolici, se.csituac, se.cagente   --RAMIRO
        INTO v_npoliza, v_fvencim, v_cduraci, v_fefecto, v_fcancel, v_sproduc, v_cramo,
             v_nsoliciorig, v_csituac, v_agente   --RAMIRO
        FROM seguros se, productos pr
       WHERE se.sproduc = pr.sproduc
         AND se.sseguro = sseguroorig;

      IF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa, 'DUPLICA_POLIZA'),
             0) = 0 THEN   -- BUG 29965 - FAL - 05/02/2014
         --Bug 26923/146526 - INICIO - DCT - 12/06/2013
         IF pcagente IS NOT NULL
            AND pcagente != v_agente THEN   --RAMIRO
            v_prodagente := pac_productos.f_prodagente(v_sproduc, pcagente, 2);   --ramiro

            IF v_prodagente = 0 THEN   --ramiro
               RETURN 9909211;   --ramiro
            END IF;   --ramiro
         END IF;   --RAMIRO

         IF v_csituac <> 4 THEN
            p_tab_error(f_sysdate, f_user, 'pac_duplicar.f_dup_seguro', vntraza,
                        'No se permite duplicar. La propuesta No es una propuesta de alta',
                        NULL);
            RETURN 9905690;
         END IF;
      END IF;

      --Bug 26923/146526 - FIN - DCT - 12/06/2013
      vntraza := 2;
      -- valida la fecha de efecto introducida
      verror := pac_seguros.f_valida_fefecto(v_sproduc, pfefecto, v_fvencim, v_cduraci);

      IF verror <> 0 THEN
         p_tab_error(f_sysdate, f_user, 'pac_duplicar.f_dup_seguro', vntraza,
                     'verror = ' || verror, SQLERRM);
         RETURN verror;
      END IF;

      vntraza := 3;

      -- obtiene el nuevo seguro
      IF ssegurodest IS NULL THEN
         SELECT sseguro.NEXTVAL
           INTO ssegurodest
           FROM DUAL;
      END IF;

      -- BUG 26390/141413 - JLTS - 26/03/2013 Se adiciona condición IF..THEN..ELSE..END IF;
      --Admite certificados y no soy certificado 0
      IF NVL(pac_mdpar_productos.f_get_parproducto('ADMITE_CERTIFICADOS', v_sproduc), 0) = 1
         AND(NVL(pac_seguros.f_get_escertifcero(NULL, sseguroorig), 0) <> 1) THEN
         BEGIN
            SELECT COUNT(*)
              INTO v_cont
              FROM seguros
             WHERE npoliza = v_npoliza
               AND ncertif = 0;
         EXCEPTION
            WHEN OTHERS THEN
               v_cont := 0;
         END;
      ELSE
         v_cont := 0;
      END IF;

      vntraza := 4;
      -- obtiene la nueva solicitud
      nsolicidest := pac_propio.f_numero_solici(pac_md_common.f_get_cxtempresa, v_cramo);
      vntraza := 5;

      -- obtiene la nueva póliza
      -- INICIO 0025583: SE AGREGA UN IF PARA DETERMINAR SI LO QUE ESTAMOS DUPLICANCO ES UN CERTIFICADO  HPM
      IF ssegurodest <> v_npoliza
         AND(v_cont > 0) THEN
         npolizadest := v_npoliza;
      -- FIN 0025583:
      ELSIF NVL(f_parproductos_v(v_sproduc, 'NPOLIZA_EN_EMISION'), 0) = 1 THEN
         --SHA: 0028455: LCOL_T031- TEC - Revisión Q-Trackers Fase 3A II
         v_numaddpoliza := pac_parametros.f_parempresa_n(v_calemp, 'NUMADDPOLIZA');
         npolizadest := ssegurodest + NVL(v_numaddpoliza, 0);
      ELSE
         --
         IF NVL(f_parproductos_v(v_sproduc, 'RESPETA_NPOLIZA'), 0) = 1 THEN
            --
            SELECT sestudi.NEXTVAL
              INTO v_sestudi
              FROM DUAL;

            --
            v_numaddpoliza := pac_parametros.f_parempresa_n(v_calemp, 'NUMADDPOLIZA');
            npolizadest := v_sestudi + NVL(v_numaddpoliza, 0);
         --
         ELSE
            --
            verror := pac_seguros.f_calcula_npoliza(v_sproduc, sseguroorig, v_cramo,
                                                    pac_md_common.f_get_cxtempresa,
                                                    npolizadest);

            --
            IF verror <> 0 THEN
               p_tab_error(f_sysdate, f_user, 'pac_duplicar.f_dup_seguro', vntraza,
                           'verror = ' || verror, SQLERRM);
               RETURN verror;
            END IF;
         --
         END IF;
      --
      END IF;

      vntraza := 6;

      -- obtiene el nuevo certificado
      IF NVL(pac_mdpar_productos.f_get_parproducto('ADMITE_CERTIFICADOS', v_sproduc), 0) = 1 THEN
         IF NVL(f_parproductos_v(v_sproduc, 'NPOLIZA_EN_EMISION'), 0) = 1 THEN
            SELECT ssolicit_certif.NEXTVAL
              INTO ncertifdest
              FROM DUAL;
         ELSE
            IF NVL(f_parproductos_v(v_sproduc, 'CERTIFICADO_GLOBAL'), 0) = 1 THEN
               SELECT NVL(MAX(ncertif), 0) + 1
                 INTO ncertifdest
                 FROM seguros
                WHERE sproduc = v_sproduc
                  AND sseguro <> sseguroorig
                  AND csituac <> 4;
            ELSE
               SELECT NVL(MAX(ncertif), 0) + 1
                 INTO ncertifdest
                 FROM seguros
                WHERE npoliza = v_npoliza
                  AND sseguro <> sseguroorig
                  AND csituac <> 4;
            END IF;
         END IF;
      ELSE
         ncertifdest := 0;
      END IF;

      vntraza := 7;
      -- duplica el seguro, agrupación=tipotablas, módulo=5
      verror := f_duplica_seguro(sseguroorig, ssegurodest, nsolicidest, npolizadest,
                                 ncertifdest, tipotablas, 5, v_csituac);   -- BUG 29965 - FAL - 05/02/2014. Se añade v_csituac

      IF verror <> 0 THEN
         p_tab_error(f_sysdate, f_user, 'pac_duplicar.f_dup_seguro', vntraza,
                     'verror = ' || verror, SQLERRM);
         RETURN verror;
      END IF;

      vntraza := 71;

      --Ini Bug 31204/ 12459 -ECP -05/05/2014
      UPDATE benespseg
         SET ffinben = f_sysdate
       WHERE sseguro = sseguroorig;

      --Fin Bug 31204/ 12459 -ECP -05/05/2014
      vntraza := 8;

      -- actualizaciones del nuevo seguro
      UPDATE seguros
         SET creteni = 1,   -- propuesta retenida
             csituac = 4,   -- propuesta alta
             fefecto = pfefecto   -- nueva fecha efecto
       WHERE sseguro = ssegurodest;

      vntraza := 9;

      -- actualizaciones en las tablas del nuevo seguro
      IF pfefecto <> v_fefecto THEN
         pk_nueva_produccion.p_modificar_fefecto_seg(ssegurodest, pfefecto, 1, 'SEG');
         vntraza := 100;
      /*
      -- Esto ya no es necesario. Lo hace todo dentro de la p_modificar _fefecto_seg
      verror := pac_calc_comu.f_calcula_nrenova(v_sproduc, pfefecto, v_nrenova);

      IF verror <> 0 THEN
         p_tab_error(f_sysdate, f_user, 'pac_duplicar.f_dup_seguro', vntraza,
                     'verror = ' || verror, SQLERRM);
         RETURN verror;
      END IF;
      vntraza := 101;

      UPDATE seguros
         SET nrenova = v_nrenova
       WHERE sseguro = ssegurodest;

      vntraza := 102;*/
      END IF;

      -- Si estamos duplicando: Nrenova a NULL. Al volver a pasar por la pantalla de datos
      -- de gestión ya lo volveremos a calcular correctamente!!!
      UPDATE seguros
         SET nrenova = NULL
       WHERE sseguro = ssegurodest;

      vntraza := 10;

      UPDATE seguros   --ramiro
         SET cagente = pcagente   -- ramiro
       WHERE sseguro = ssegurodest   --ramiro
         AND cagente <> pcagente;   --ramiro

      UPDATE age_corretaje   --ramiro
         SET cagente = pcagente   -- ramiro
       WHERE sseguro = ssegurodest   --ramiro
         AND islider = 1;   --ramiro
-- 29665/0165743 - JSV - 10/02/2014 - INI
      SELECT MAX(nmovimi)
        INTO v_max_nmovimi
        FROM movseguro
       WHERE sseguro = ssegurodest;

      FOR reg IN (SELECT nmovimi
                    FROM movseguro
                   WHERE sseguro = ssegurodest) LOOP
         IF (reg.nmovimi < v_max_nmovimi) THEN
            pac_alctr126.borrar_movimiento(ssegurodest, reg.nmovimi);
         END IF;
      END LOOP;

-- 29665/0165743 - JSV - 10/02/2014 - FIN

      -- insertar en la tabla psu_retenidas del nuevo seguro
      BEGIN
         INSERT INTO psu_retenidas
                     (sseguro, nmovimi, fmovimi, cmotret, cnivelbpm, cusuret, ffecret,
                      cusuaut, ffecaut, observ,
                      cdetmotrec)
              VALUES (ssegurodest,
                                  -- 29665/0165743 - JSV - 10/02/2014
                                  --1,
                                  v_max_nmovimi, f_sysdate, 1, 0, f_user, f_sysdate,
                      NULL, NULL, f_axis_literales(9904007, pac_md_common.f_get_cxtidioma),
                      NULL);
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            NULL;
      END;

      vntraza := 11;

      --Bug 26923/146526 - INICIO - DCT - 12/06/2013
      UPDATE movseguro
         SET fmovimi = f_sysdate,
             cusumov = f_user,
             cestadocol = NULL
                              -- 29665/0165743 - JSV - 10/02/2014
      ,
             cmotmov = 100,
			 femisio = null

       WHERE sseguro = ssegurodest;

      --Bug 26923/146526 - FIN - DCT - 12/06/2013
      vntraza := 12;

      -- anulación del seguro origen
      IF NVL(f_parproductos_v(v_sproduc, 'ANULAR_PROP_ORIGEN'), 0) = 1 THEN
         --INICIO 32009 - DCT - 11/07/2014
         pac_anulacion.p_baja_automatico_solicitudes(v_sproduc, sseguroorig,
                                                     NVL(v_fcancel, v_fefecto), v_sproces, 1);
      --FIN 32009 - DCT - 11/07/2014
      END IF;

      -- Bug 27147/0146044 - APD - 10/06/2013 - realizar apunte en la agenda
      verror := pac_agensegu.f_set_datosapunte(NULL, ssegurodest, NULL,
                                               f_axis_literales(9903993),
                                               f_axis_literales(9905681) || ': '
                                               || f_axis_literales(9000875) || ' '
                                               || v_nsoliciorig,
                                               6, 1, f_sysdate, f_sysdate, pmodo => 0,
                                               pcmanual => 0);

      IF verror <> 0 THEN
         p_tab_error(f_sysdate, f_user, 'pac_duplicar.f_dup_seguro', vntraza,
                     'verror = ' || verror, SQLERRM);
         RETURN verror;
      END IF;

      verror := pac_agensegu.f_set_datosapunte(NULL, sseguroorig, NULL,
                                               f_axis_literales(9903993),
                                               f_axis_literales(9905682) || ': '
                                               || f_axis_literales(9000875) || ' '
                                               || nsolicidest,
                                               6, 1, f_sysdate, f_sysdate, pmodo => 0,
                                               pcmanual => 0);

      IF verror <> 0 THEN
         p_tab_error(f_sysdate, f_user, 'pac_duplicar.f_dup_seguro', vntraza,
                     'verror = ' || verror, SQLERRM);
         RETURN verror;
      END IF;

      -- fin Bug 27147/0146044 - APD - 10/06/2013

      -- Bug 29665 - RSC - 06/03/2014 - RSC
      -- La duplicación de propuestas debe dejar el cbloqueacol
      -- correcto.
      verror := pac_propio.f_act_cbloqueocol(ssegurodest);
      -- Fin bug 29665
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_duplicar.f_dup_seguro', vntraza,
                     'Error en la duplicación', SQLERRM);
         RETURN 152715;
   END f_dup_seguro;

   -- 17/06/2013 - RCL - 26923: Revisión Q-Trackers Fase 3A
   FUNCTION f_valida_dup_seguro(sseguroorig IN NUMBER)
      RETURN NUMBER IS
      vntraza        NUMBER;
      v_csituac      seguros.csituac%TYPE;
      v_sproduc      seguros.sproduc%TYPE;
      v_npoliza      seguros.npoliza%TYPE;
      v_existe       NUMBER;
      v_escertif0    NUMBER;
      isaltacol      BOOLEAN;
      v_result       NUMBER;
   BEGIN
      /*------------------------------------------------------------------------------------
         Función que valida si se puede duplicar
            Si el sseguroorig es nulo, error.
            Si v_csituac <> 4 --> 9905690
            Si v_csituac == 4 --> 0
      -------------------------------------------------------------------------------------*/
      IF sseguroorig IS NULL THEN
         RETURN 101919;
      END IF;

      vntraza := 1;

      SELECT se.csituac, se.sproduc, se.npoliza
        INTO v_csituac, v_sproduc, v_npoliza
        FROM seguros se, productos pr
       WHERE se.sproduc = pr.sproduc
         AND se.sseguro = sseguroorig;

      IF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa, 'DUPLICA_POLIZA'),
             0) = 0 THEN   -- BUG 29965 - FAL - 05/02/2014
         IF v_csituac <> 4 THEN
            p_tab_error(f_sysdate, f_user, 'pac_duplicar.f_valida_dup_seguro', vntraza,
                        'No se permite duplicar. La propuesta No es una propuesta de alta',
                        NULL);
            RETURN 9905690;
         END IF;
      END IF;

      --Inici BUG 29665/168292 - RCL - 04/03/2014 - No duplicar una propuesta si el certificado 0 no se esta "Abierto para Suplementos"
      IF NVL(f_parproductos_v(v_sproduc, 'ADMITE_CERTIFICADOS'), 0) = 1 THEN
         --Si no soy colectivo administrado continuar con la duplicación de propuesta normal.
         IF pac_seguros.f_es_col_admin(sseguroorig) = 1 THEN
            --Inici ¿soy un certificado?
            isaltacol := FALSE;
            v_existe := pac_seguros.f_get_escertifcero(v_npoliza);
            v_escertif0 := pac_seguros.f_get_escertifcero(NULL, sseguroorig);

            IF v_escertif0 > 0 THEN
               isaltacol := TRUE;
            ELSE
               IF v_existe <= 0 THEN
                  isaltacol := TRUE;
               END IF;
            END IF;

            --Fi ¿soy un certificado?

            --Si soy certificado 0 --> está abierto para suplementos?
            IF NOT isaltacol THEN
               SELECT pac_seguros.f_suplem_obert(sseguroorig)
                 INTO v_result
                 FROM seguros s
                WHERE s.sseguro = sseguroorig;

               RETURN v_result;   --RETURN [0|9904265]
            END IF;
         END IF;
      END IF;

      --Fi BUG 29665/168292 - RCL - 04/03/2014 - No duplicar una propuesta si el certificado 0 no se esta "Abierto para Suplementos"
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_duplicar.f_valida_dup_seguro', vntraza,
                     'Error en la validación de la duplicación', SQLERRM);
         RETURN 152715;
   END f_valida_dup_seguro;
END;

/

  GRANT EXECUTE ON "AXIS"."PAC_DUPLICAR" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_DUPLICAR" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_DUPLICAR" TO "PROGRAMADORESCSI";
