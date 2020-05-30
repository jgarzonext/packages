--------------------------------------------------------
--  DDL for Package Body PAC_IAX_GETCONSULT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IAX_GETCONSULT" AS
/******************************************************************************
   NOMBRE:       PAC_IAX_GETCONSULT
   PROPÓSITO:  Package que dada un SQL devuelve el objecto de la SQL y
               su definción

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        25/07/2007   ACC                1. Creación del package.
******************************************************************************/

   -- Establece sentenia Sql
   PROCEDURE setquery(sq VARCHAR2) IS
   BEGIN
      squery := sq;
   END;

   -- Recupera las columnas definidas en la sentencia Sql
   PROCEDURE describe_columns IS
      idcur          INTEGER;
   BEGIN
      idcur := DBMS_SQL.open_cursor;
      DBMS_SQL.parse(idcur, squery, DBMS_SQL.native);
      DBMS_SQL.describe_columns2(idcur, ncount, desc_tab);
      DBMS_SQL.close_cursor(idcur);
   EXCEPTION
      WHEN OTHERS THEN
         IF DBMS_SQL.is_open(idcur) THEN
            DBMS_SQL.close_cursor(idcur);
         END IF;

         RAISE;
   END;

   -- Devuelve la definición de los campos de la consulta
   -- para poder crear un type record dynamic
   -- return: la definición de la tabla como a SQL
   FUNCTION f_record_def
      RETURN VARCHAR2 IS
      srecord_def    VARCHAR2(32000);
      ntype          VARCHAR2(100);
      col_type       PLS_INTEGER;
      col_max_len    PLS_INTEGER;
      col_precision  PLS_INTEGER;
      col_scale      PLS_INTEGER;
      col_name       VARCHAR2(255);
   BEGIN
      FOR i IN 1 .. ncount LOOP
         col_type := desc_tab(i).col_type;
         col_max_len := desc_tab(i).col_max_len;
         col_precision := desc_tab(i).col_precision;
         col_scale := desc_tab(i).col_scale;
         col_name := desc_tab(i).col_name;

         IF col_type = varchar2_type THEN
            ntype := 'VARCHAR2(' || col_max_len || ')';
         ELSIF col_type = number_type THEN
            ntype := 'NUMBER(' || col_precision || ',' || col_scale || ')';
         ELSIF col_type = date_type THEN
            ntype := 'DATE';
         ELSIF col_type = rowid_type THEN
            ntype := 'ROWID';
         ELSIF col_type = char_type THEN
            ntype := 'CHAR(' || col_max_len || ')';
         END IF;

         srecord_def := srecord_def || col_name || ' ' || ntype || ',';
      END LOOP;

      srecord_def := RTRIM(srecord_def, ',');
      RETURN srecord_def;
   END;

   -- Devuelve los nombres de los campos definidos en Sql
   -- return: el nombre de los campos de la tabla como  SQL
   FUNCTION f_columns_names
      RETURN VARCHAR2 IS
      scolumns       VARCHAR2(32000);
   BEGIN
      FOR i IN 1 .. ncount LOOP
         scolumns := scolumns || desc_tab(i).col_name || ',';
      END LOOP;

      scolumns := RTRIM(scolumns, ',');
      RETURN scolumns;
   END;

   -- Devuelve el nombre del campo definido en Sql
   FUNCTION f_column_name(col NUMBER)
      RETURN VARCHAR2 IS
   BEGIN
      RETURN NVL(desc_tab(col).col_name, '');
   EXCEPTION
      WHEN OTHERS THEN
         RETURN '';
   END;

   -- Devuelve un cursor con la Sql
   -- return: un cursor como referencia de la SQL
   FUNCTION f_ref_cur
      RETURN ref_cur_t IS
      refcur         ref_cur_t;
   BEGIN
      IF squery = ''
         OR squery = NULL THEN
         RETURN refcur;
      END IF;

      OPEN refcur FOR squery;

      RETURN refcur;
   -- BUG -21546_108724- 08/02/2012 - JLTS - Cierre de posibles cursores abiertos, se adiciona EXCEPTION
   EXCEPTION
      WHEN OTHERS THEN
         IF refcur%ISOPEN THEN
            CLOSE refcur;
         END IF;

         RETURN refcur;
   END f_ref_cur;

   -- Devuelve el tipo y tamaño de una columna
   -- param col: indica la posición de la columna a recuperar
   -- param typ: devuelve el tipo de valor
   -- param siz: devuelve la longitud del campo
   PROCEDURE gettypesizecol(col IN NUMBER, typ OUT PLS_INTEGER, siz OUT VARCHAR2) IS
      col_type       PLS_INTEGER;
      col_max_len    PLS_INTEGER;
      col_precision  PLS_INTEGER;
      col_scale      PLS_INTEGER;
   BEGIN
      col_type := desc_tab(col).col_type;
      col_max_len := desc_tab(col).col_max_len;
      col_precision := desc_tab(col).col_precision;
      col_scale := desc_tab(col).col_scale;

      IF col_type = varchar2_type
         OR col_type = char_type THEN
         siz := col_max_len;
      ELSE
         siz := col_precision || ',' || col_scale;
      END IF;

      typ := col_type;
   EXCEPTION
      WHEN OTHERS THEN
         typ := varchar2_type;
         siz := 0;
   END;

   -- Devuelve la tabla con los datos definidos en el SQL
   -- return: la definición como objeto de la SQL
   FUNCTION f_gettableobj
      RETURN t_iax_getconsult IS
      idcur          INTEGER;
      nnumber        NUMBER;
      svarchar       VARCHAR2(32000);
      ddate          DATE;
      schar          CHAR;
      rrowid         ROWID;
      col_type       PLS_INTEGER;
      ntype          VARCHAR2(32000);
      siz            VARCHAR2(32000);
      nrow           PLS_INTEGER;
      n              NUMBER;
      ts             NUMBER := 0;
      tl             NUMBER := 0;
      tn             NUMBER := 0;
      tt             NUMBER := 0;
      td             NUMBER := 0;
      topcols        NUMBER := 10;
      valstring      VARCHAR2(255);
      vallstring     VARCHAR2(4000);
      valnumber      NUMBER;
      valdate        DATE;
      tgetconsult    t_iax_getconsult := t_iax_getconsult();
      v_getconsult   ob_iax_getconsult;
      vname          VARCHAR2(500);
      nfields        NUMBER := 0;
   BEGIN
      idcur := DBMS_SQL.open_cursor;
      DBMS_SQL.parse(idcur, squery, DBMS_SQL.native);

      IF desc_tab.COUNT = 0 THEN
         describe_columns;
      END IF;

      FOR col IN 1 .. ncount LOOP
         gettypesizecol(col, col_type, siz);

         IF col_type = varchar2_type THEN
            DBMS_SQL.define_column(idcur, col, svarchar, siz);
         ELSIF col_type = number_type THEN
            DBMS_SQL.define_column(idcur, col, nnumber);
         ELSIF col_type = date_type THEN
            DBMS_SQL.define_column(idcur, col, ddate);
         ELSIF col_type = rowid_type THEN
            DBMS_SQL.define_column(idcur, col, rrowid);
         ELSIF col_type = char_type THEN
            DBMS_SQL.define_column(idcur, col, schar, siz);
         ELSE
            DBMS_SQL.define_column(idcur, col, svarchar, 4000);
         END IF;
      END LOOP;

      nrow := DBMS_SQL.EXECUTE(idcur);

      LOOP
         EXIT WHEN DBMS_SQL.fetch_rows(idcur) = 0;
         tgetconsult.EXTEND;
         tgetconsult(tgetconsult.LAST) := ob_iax_getconsult();
         ts := 0;
         tl := 0;
         tn := 0;
         tt := 0;
         td := 0;
         nfields := nfields + 1;

         FOR col IN 1 .. ncount LOOP
            gettypesizecol(col, col_type, siz);
            vname := '';

            IF col_type = varchar2_type THEN
               IF ts < topcols THEN
                  IF TO_NUMBER(siz) <= 255 THEN
                     DBMS_SQL.COLUMN_VALUE(idcur, col, valstring);
                     --IF TO_CHAR(valString)<>' ' then
                     ts := ts + 1;

                     IF ts = 1 THEN
                        tgetconsult(tgetconsult.LAST).t1 := valstring;
                     ELSIF ts = 2 THEN
                        tgetconsult(tgetconsult.LAST).t2 := valstring;
                     ELSIF ts = 3 THEN
                        tgetconsult(tgetconsult.LAST).t3 := valstring;
                     ELSIF ts = 4 THEN
                        tgetconsult(tgetconsult.LAST).t4 := valstring;
                     ELSIF ts = 5 THEN
                        tgetconsult(tgetconsult.LAST).t5 := valstring;
                     ELSIF ts = 6 THEN
                        tgetconsult(tgetconsult.LAST).t6 := valstring;
                     ELSIF ts = 7 THEN
                        tgetconsult(tgetconsult.LAST).t7 := valstring;
                     ELSIF ts = 8 THEN
                        tgetconsult(tgetconsult.LAST).t8 := valstring;
                     ELSIF ts = 9 THEN
                        tgetconsult(tgetconsult.LAST).t9 := valstring;
                     ELSIF ts = 10 THEN
                        tgetconsult(tgetconsult.LAST).t10 := valstring;
                     END IF;

                     IF ts <= 10 THEN
                        vname := '#' || f_column_name(col) || '%t' || TO_CHAR(ts);
                     END IF;
                  --END IF;
                  ELSE
                     IF tl < 2 THEN
                        DBMS_SQL.COLUMN_VALUE(idcur, col, vallstring);
                        --IF TO_CHAR(valString)<>' '  then
                        tl := tl + 1;

                        IF tl = 1 THEN
                           tgetconsult(tgetconsult.LAST).tl1 := vallstring;
                        ELSIF tl = 2 THEN
                           tgetconsult(tgetconsult.LAST).tl2 := vallstring;
                        END IF;

                        IF tl <= 2 THEN
                           vname := '#' || f_column_name(col) || '%tl' || TO_CHAR(tl);
                        END IF;
                     --END IF;
                     END IF;
                  END IF;
               END IF;
            ELSIF col_type = number_type THEN
               IF tn < 15 THEN
                  DBMS_SQL.COLUMN_VALUE(idcur, col, valnumber);
                  --if to_number(valNumber)<>0 then
                  tn := tn + 1;

                  IF tn = 1 THEN
                     tgetconsult(tgetconsult.LAST).n1 := valnumber;
                  ELSIF tn = 2 THEN
                     tgetconsult(tgetconsult.LAST).n2 := valnumber;
                  ELSIF tn = 3 THEN
                     tgetconsult(tgetconsult.LAST).n3 := valnumber;
                  ELSIF tn = 4 THEN
                     tgetconsult(tgetconsult.LAST).n4 := valnumber;
                  ELSIF tn = 5 THEN
                     tgetconsult(tgetconsult.LAST).n5 := valnumber;
                  ELSIF tn = 6 THEN
                     tgetconsult(tgetconsult.LAST).n6 := valnumber;
                  ELSIF tn = 7 THEN
                     tgetconsult(tgetconsult.LAST).n7 := valnumber;
                  ELSIF tn = 8 THEN
                     tgetconsult(tgetconsult.LAST).n8 := valnumber;
                  ELSIF tn = 9 THEN
                     tgetconsult(tgetconsult.LAST).n9 := valnumber;
                  ELSIF tn = 10 THEN
                     tgetconsult(tgetconsult.LAST).n10 := valnumber;
                  ELSIF tn = 11 THEN
                     tgetconsult(tgetconsult.LAST).n11 := valnumber;
                  ELSIF tn = 12 THEN
                     tgetconsult(tgetconsult.LAST).n12 := valnumber;
                  ELSIF tn = 13 THEN
                     tgetconsult(tgetconsult.LAST).n13 := valnumber;
                  ELSIF tn = 14 THEN
                     tgetconsult(tgetconsult.LAST).n14 := valnumber;
                  ELSIF tn = 15 THEN
                     tgetconsult(tgetconsult.LAST).n15 := valnumber;
                  END IF;

                  IF tn <= 15 THEN
                     vname := '#' || f_column_name(col) || '%n' || TO_CHAR(tn);
                  END IF;
               --END IF;
               END IF;
            ELSIF col_type = date_type THEN
               IF td < topcols THEN
                  DBMS_SQL.COLUMN_VALUE(idcur, col, valdate);
                  --IF valDate<>NULL THEN
                  td := td + 1;

                  IF td = 1 THEN
                     tgetconsult(tgetconsult.LAST).d1 := valdate;
                  ELSIF td = 2 THEN
                     tgetconsult(tgetconsult.LAST).d2 := valdate;
                  ELSIF td = 3 THEN
                     tgetconsult(tgetconsult.LAST).d3 := valdate;
                  ELSIF td = 4 THEN
                     tgetconsult(tgetconsult.LAST).d4 := valdate;
                  ELSIF td = 5 THEN
                     tgetconsult(tgetconsult.LAST).d5 := valdate;
                  ELSIF td = 6 THEN
                     tgetconsult(tgetconsult.LAST).d6 := valdate;
                  ELSIF td = 7 THEN
                     tgetconsult(tgetconsult.LAST).d7 := valdate;
                  ELSIF td = 8 THEN
                     tgetconsult(tgetconsult.LAST).d8 := valdate;
                  ELSIF td = 9 THEN
                     tgetconsult(tgetconsult.LAST).d9 := valdate;
                  ELSIF td = 10 THEN
                     tgetconsult(tgetconsult.LAST).d10 := valdate;
                  END IF;

                  IF td <= 10 THEN
                     vname := '#' || f_column_name(col) || '%d' || TO_CHAR(td);
                  END IF;
               --END IF;
               END IF;
            ELSIF col_type = rowid_type THEN
               DBMS_SQL.COLUMN_VALUE(idcur, col, tgetconsult(tgetconsult.LAST).rrowid);
            ELSIF col_type = char_type THEN
               IF ts < topcols THEN
                  DBMS_SQL.COLUMN_VALUE(idcur, col, valstring);
                  --IF TO_CHAR(valString)<>' ' then
                  ts := ts + 1;

                  IF ts = 1 THEN
                     tgetconsult(tgetconsult.LAST).t1 := valstring;
                  ELSIF ts = 2 THEN
                     tgetconsult(tgetconsult.LAST).t2 := valstring;
                  ELSIF ts = 3 THEN
                     tgetconsult(tgetconsult.LAST).t3 := valstring;
                  ELSIF ts = 4 THEN
                     tgetconsult(tgetconsult.LAST).t4 := valstring;
                  ELSIF ts = 5 THEN
                     tgetconsult(tgetconsult.LAST).t5 := valstring;
                  ELSIF ts = 6 THEN
                     tgetconsult(tgetconsult.LAST).t6 := valstring;
                  ELSIF ts = 7 THEN
                     tgetconsult(tgetconsult.LAST).t7 := valstring;
                  ELSIF ts = 8 THEN
                     tgetconsult(tgetconsult.LAST).t8 := valstring;
                  ELSIF ts = 9 THEN
                     tgetconsult(tgetconsult.LAST).t9 := valstring;
                  ELSIF ts = 10 THEN
                     tgetconsult(tgetconsult.LAST).t10 := valstring;
                  END IF;

                  IF ts <= 10 THEN
                     vname := '#' || f_column_name(col) || '%t' || TO_CHAR(ts);
                  END IF;
               --END IF;
               END IF;
            ELSE
               IF ts < topcols THEN
                  IF TO_NUMBER(siz) <= 255 THEN
                     DBMS_SQL.COLUMN_VALUE(idcur, col, valstring);
                     --IF TO_CHAR(valString)<>' ' THEN
                     ts := ts + 1;

                     IF ts = 1 THEN
                        tgetconsult(tgetconsult.LAST).t1 := valstring;
                     ELSIF ts = 2 THEN
                        tgetconsult(tgetconsult.LAST).t2 := valstring;
                     ELSIF ts = 3 THEN
                        tgetconsult(tgetconsult.LAST).t3 := valstring;
                     ELSIF ts = 4 THEN
                        tgetconsult(tgetconsult.LAST).t4 := valstring;
                     ELSIF ts = 5 THEN
                        tgetconsult(tgetconsult.LAST).t5 := valstring;
                     ELSIF ts = 6 THEN
                        tgetconsult(tgetconsult.LAST).t6 := valstring;
                     ELSIF ts = 7 THEN
                        tgetconsult(tgetconsult.LAST).t7 := valstring;
                     ELSIF ts = 8 THEN
                        tgetconsult(tgetconsult.LAST).t8 := valstring;
                     ELSIF ts = 9 THEN
                        tgetconsult(tgetconsult.LAST).t9 := valstring;
                     ELSIF ts = 10 THEN
                        tgetconsult(tgetconsult.LAST).t10 := valstring;
                     END IF;

                     IF ts <= 10 THEN
                        vname := '#' || f_column_name(col) || '%t' || TO_CHAR(ts);
                     END IF;
                  --END IF;
                  ELSE
                     IF tl < 2 THEN
                        DBMS_SQL.COLUMN_VALUE(idcur, col, vallstring);
                        --if TO_CHAR(valString)<>' ' then
                        tl := tl + 1;

                        IF tl = 1 THEN
                           tgetconsult(tgetconsult.LAST).tl1 := vallstring;
                        ELSIF tl = 2 THEN
                           tgetconsult(tgetconsult.LAST).tl2 := vallstring;
                        END IF;

                        IF tl <= 2 THEN
                           vname := '#' || f_column_name(col) || 'tl' || TO_CHAR(tl);
                        END IF;
                     --END IF;
                     END IF;
                  END IF;
               END IF;
            END IF;

            tgetconsult(tgetconsult.LAST).nvar := ts;
            tgetconsult(tgetconsult.LAST).nlva := tl;
            tgetconsult(tgetconsult.LAST).nnum := tn;
            tgetconsult(tgetconsult.LAST).ndat := td;

            IF nfields = 1 THEN
               IF NVL(tgetconsult(tgetconsult.LAST).relfield, ' ') = ' ' THEN
                  IF LENGTH(vname) > 0 THEN
                     vname := SUBSTR(vname, 2);
                  END IF;
               END IF;

               tgetconsult(tgetconsult.LAST).relfield :=
                                                tgetconsult(tgetconsult.LAST).relfield || vname;
            ELSE
               tgetconsult(tgetconsult.LAST).relfield :=
                                                    tgetconsult(tgetconsult.LAST - 1).relfield;
            END IF;
         END LOOP;
      END LOOP;

      RETURN tgetconsult;
   END;

   -- Devuelve la tabla con los datos definidos en el SQL como parámetro
   -- param: establece la SQL a procesar
   -- param out: devuelve la colección de mensajes
   -- return: devuelve la tabla de la consulta
   FUNCTION f_gettable(squery VARCHAR2, mensaje OUT t_iax_mensajes)
      RETURN t_iax_getconsult IS
   BEGIN
      setquery(squery);
      describe_columns;
      RETURN f_gettableobj();
   EXCEPTION
      WHEN OTHERS THEN
         mensaje.EXTEND;
         mensaje(mensaje.LAST) := ob_iax_mensajes();
         mensaje(mensaje.LAST).set_mensaje(1, SQLCODE, SQLERRM);
   END;
END;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_GETCONSULT" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_GETCONSULT" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_GETCONSULT" TO "PROGRAMADORESCSI";
