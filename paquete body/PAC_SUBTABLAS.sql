--------------------------------------------------------
--  DDL for Package Body PAC_SUBTABLAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_SUBTABLAS" IS
       /******************************************************************************
       NOMBRE:     PAC_SINIESTROS
       PROPÓSITO:  Cuerpo del paquete de las funciones para los módulos de las subtablas SGT

       REVISIONES:
       Ver        Fecha        Autor             Descripción
       ---------  ----------  ---------------  ------------------------------------
       1.0        07/07/2011   FPG / SRA         1. Creación del package.
       2.0        05/11/2011   JRH               2. 0018966: LCOL_T002 - Tramos con más de 2 dimensiones
       3.0        07/12/2011   JRH               2. 0019612: Provisiones
       4.0        19/03/2012   JMF               0021655 MDP - TEC - Cálculo del Consorcio
       5.0        07/01/2013   NMM               24926: (POSRA200)-Vida Individual
       6.0        16/12/2015   FAL               0038779: Errores en el cálculo al actualizar los convenios (bug hermano interno)

   /* Función f_montar_consultav
      Monta la consulta de la tabla sgt_subtabs_det. Devuelve un VARCHAR2 con la
      consulta construida.
      Parámetro de entrada: p_in_cquery es una cadena con una posición para
      establecer la condición en cada una de las claves que queramos usar (de las
      8 que tiene la tabla sgt_subtabs_det)
      Cada una de las posiciones contiene un número para expresar la condición sobre
      la clave correspondiente:
      Valor    Condición            Ejemplo
      ------   ---------            -------
      1        menor (<)            D.CCLA1 < :CCLA1
      2        menor o igual (<=)   D.CCLA1 <= :CCLA1
      3        igual (=)            D.CCLA1 = :CCLA1
      4        mayor o igual (>=)   D.CCLA1 >= :CCLA1
      5        mayor (>)            D.CCLA1 > :CCLA1
      Las posiciones se examinande izquierda a derecha.
      Ejemplos:
      1) p_in_cquery = '3'
         se transformará en D.CCLA1 = :CCLA1
      2) p_in_cquery = '34'
         se transformará en D.CCLA1 = :CCLA1 AND D.CCLA2 >= :CCLA2
      3) p_in_cquery = '304'
         se transformará en D.CCLA1 = :CCLA1 AND D.CCLA3 >= :CCLA3
   */
   FUNCTION f_montar_consulta(p_in_cquery IN VARCHAR2)
      RETURN VARCHAR2 IS
      v_query        VARCHAR2(1000);
      v_orden        VARCHAR2(200) := ' ORDER BY';
      v_lon_cquery   NUMBER;
      pos            NUMBER;
      v_numclave     NUMBER;
      v_condnum      VARCHAR(1);
      v_condchar     VARCHAR(2);
      vobject        VARCHAR2(100) := 'PAC_SUBTABLAS.F_MONTAR_CONSULTA';
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1000) := 'Parametros: p_in_cquery= ' || p_in_cquery;
   BEGIN
      v_lon_cquery := LENGTH(p_in_cquery);

      IF v_lon_cquery < 1 THEN
         RETURN NULL;
      END IF;

      v_query :=
         'SELECT * FROM sgt_subtabs_DET D WHERE D.CEMPRES = :CEMPRES AND D.CSUBTABLA = :CSUBTABLA';
      v_query := v_query || ' AND D.CVERSUBT = :CVERSUBT';
      vpasexec := 10;
      pos := 1;
      v_numclave := 0;

      FOR pos IN 1 .. v_lon_cquery LOOP
         v_condnum := SUBSTR(p_in_cquery, pos, 1);

         IF NVL(v_condnum, -1) > -1 THEN
            v_numclave := v_numclave + 1;

            IF TO_NUMBER(v_condnum) > 0
               AND TO_NUMBER(v_condnum) < 6 THEN
               v_condchar := v_conds(v_condnum);
            ELSE
               v_condchar := NULL;
            END IF;
         ELSE
            v_condchar := NULL;
         END IF;

         IF v_condchar IS NOT NULL THEN
            IF v_numclave = 1 THEN
               v_query := v_query || ' AND D.CCLA1 ' || v_condchar || ' :CCLA1';

               --v_orden := v_orden || ',D.CCLA1';
               IF v_condnum IN(1, 2) THEN
                  v_orden := v_orden || ' D.CCLA1 DESC';
               ELSE
                  v_orden := v_orden || ' D.CCLA1';
               END IF;
            END IF;

            IF v_numclave = 2 THEN
               v_query := v_query || ' AND D.CCLA2 ' || v_condchar || ' :CCLA2';

               --v_orden := v_orden || ',D.CCLA2';
               IF v_condnum IN(1, 2) THEN
                  v_orden := v_orden || ',D.CCLA2 DESC';
               ELSE
                  v_orden := v_orden || ',D.CCLA2';
               END IF;
            END IF;

            IF v_numclave = 3 THEN
               v_query := v_query || ' AND D.CCLA3 ' || v_condchar || ' :CCLA3';

               --v_orden := v_orden || ',D.CCLA3';
               IF v_condnum IN(1, 2) THEN
                  v_orden := v_orden || ',D.CCLA3 DESC';
               ELSE
                  v_orden := v_orden || ',D.CCLA3';
               END IF;
            END IF;

            IF v_numclave = 4 THEN
               v_query := v_query || ' AND D.CCLA4 ' || v_condchar || ' :CCLA4';

               --v_orden := v_orden || ',D.CCLA4';
               IF v_condnum IN(1, 2) THEN
                  v_orden := v_orden || ',D.CCLA4 DESC';
               ELSE
                  v_orden := v_orden || ',D.CCLA4';
               END IF;
            END IF;

            IF v_numclave = 5 THEN
               v_query := v_query || ' AND D.CCLA5 ' || v_condchar || ' :CCLA5';

               --v_orden := v_orden || ',D.CCLA5';
               IF v_condnum IN(1, 2) THEN
                  v_orden := v_orden || ',D.CCLA5 DESC';
               ELSE
                  v_orden := v_orden || ',D.CCLA5';
               END IF;
            END IF;

            IF v_numclave = 6 THEN
               v_query := v_query || ' AND D.CCLA6 ' || v_condchar || ' :CCLA6';

               --v_orden := v_orden || ',D.CCLA6';
               IF v_condnum IN(1, 2) THEN
                  v_orden := v_orden || ',D.CCLA6 DESC';
               ELSE
                  v_orden := v_orden || ',D.CCLA6';
               END IF;
            END IF;

            IF v_numclave = 7 THEN
               v_query := v_query || ' AND D.CCLA7 ' || v_condchar || ' :CCLA7';

               --v_orden := v_orden || ',D.CCLA7';
               IF v_condnum IN(1, 2) THEN
                  v_orden := v_orden || ',D.CCLA7 DESC';
               ELSE
                  v_orden := v_orden || ',D.CCLA7';
               END IF;
            END IF;

            IF v_numclave = 8 THEN
               v_query := v_query || ' AND D.CCLA8 ' || v_condchar || ' :CCLA8';

               --v_orden := v_orden || ',D.CCLA8';
               IF v_condnum IN(1, 2) THEN
                  v_orden := v_orden || ',D.CCLA8 DESC';
               ELSE
                  v_orden := v_orden || ',D.CCLA8';
               END IF;
            END IF;

            -- BUG 16217 - 11/2011 - JRH  -  0018966: LCOL_T002 - Tramos con más de 2 dimensiones . Añadimos 2 claves
            IF v_numclave = 9 THEN
               v_query := v_query || ' AND D.CCLA9 ' || v_condchar || ' :CCLA9';

               --v_orden := v_orden || ',D.CCLA9';
               IF v_condnum IN(1, 2) THEN
                  v_orden := v_orden || ',D.CCLA9 DESC';
               ELSE
                  v_orden := v_orden || ',D.CCLA9';
               END IF;
            END IF;

            IF v_numclave = 10 THEN
               v_query := v_query || ' AND D.CCLA10 ' || v_condchar || ' :CCLA10';

               --v_orden := v_orden || ',D.CCLA10';
               IF v_condnum IN(1, 2) THEN
                  v_orden := v_orden || ',D.CCLA10 DESC';
               ELSE
                  v_orden := v_orden || ',D.CCLA10';
               END IF;
            END IF;
         -- Fi BUG 16217 - 11/2011 - JRH  -  0018966: LCOL_T002 - Tramos con más de 2 dimensiones . Añadimos 2 claves
         END IF;
      END LOOP;

      vpasexec := 20;
      v_query := v_query || v_orden;
      RETURN v_query;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN NULL;
   END f_montar_consulta;

   FUNCTION f_rec_cons(
      pcempres IN sgt_subtabs_det.cempres%TYPE,
      pcsubtabla IN sgt_subtabs_det.csubtabla%TYPE,
      pfefecto IN sgt_subtabs_ver.fefecto%TYPE,
      pccla1 IN sgt_subtabs_det.ccla1%TYPE,
      pccla2 IN sgt_subtabs_det.ccla2%TYPE,
      pccla3 IN sgt_subtabs_det.ccla3%TYPE,
      pccla4 IN sgt_subtabs_det.ccla4%TYPE,
      pccla5 IN sgt_subtabs_det.ccla5%TYPE,
      pccla6 IN sgt_subtabs_det.ccla6%TYPE,
      pccla7 IN sgt_subtabs_det.ccla7%TYPE,
      pccla8 IN sgt_subtabs_det.ccla8%TYPE,
      --JRH
      pccla9 IN sgt_subtabs_det.ccla9%TYPE,
      pccla10 IN sgt_subtabs_det.ccla10%TYPE
                                            --JRH
   )
      RETURN rec_cons_subt IS
      v_rec          rec_cons_subt;
      vobject        VARCHAR2(100) := 'PAC_SUBTABLAS.F_REC_CONS';
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1000)
         := 'Parametros: pcempres= ' || pcempres || ' pcsubtabla= ' || pcsubtabla
            || ' pfefecto= ' || pfefecto || ' pccla1= ' || pccla1 || ' pccla2= ' || pccla2
            || ' pccla3= ' || pccla3 || ' pccla4= ' || pccla4 || ' pccla5= ' || pccla5
            || ' pccla6= ' || pccla6 || ' pccla7= ' || pccla7 || ' pccla8= ' || pccla8
            || ' pccla9= ' || pccla9 || ' pccla10= ' || pccla10;
   BEGIN
      v_rec.cempres := pcempres;
      v_rec.csubtabla := pcsubtabla;
      v_rec.fefecto := pfefecto;
      v_rec.ccla1 := pccla1;
      v_rec.ccla2 := pccla2;
      v_rec.ccla3 := pccla3;
      v_rec.ccla4 := pccla4;
      v_rec.ccla5 := pccla5;
      v_rec.ccla6 := pccla6;
      v_rec.ccla7 := pccla7;
      v_rec.ccla8 := pccla8;
      --JRH
      v_rec.ccla9 := pccla9;
      v_rec.ccla10 := pccla10;
      --JRH
      RETURN v_rec;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN NULL;
   END f_rec_cons;

-- USA SQL DINAMICO
   PROCEDURE p_detalle_fila_din(
      p_in_claves IN rec_cons_subt,
      p_in_cquery IN VARCHAR2,
      p_out_detalle OUT sgt_subtabs_det%ROWTYPE,
      p_out_error OUT NUMBER) IS
      v_consulta     VARCHAR2(1000);
      cursor_det     INTEGER;
      v_cversubt     sgt_subtabs_det.cversubt%TYPE;
      v_cempres      NUMBER;
      v_retorno      NUMBER := 0;
      v_retexec      NUMBER := 0;
      vobject        VARCHAR2(100) := 'PAC_SUBTABLAS.P_DETALLE_FILA_DIN';
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1000);
      cur            sys_refcursor;

      -- Macro que valida que el contingut de p_in_claves siguin digits de 1 a 5
      FUNCTION fvalidaquery(ptquery IN VARCHAR2)
         RETURN NUMBER IS
         vlong          NUMBER := LENGTH(ptquery);
         i              NUMBER := 0;
      BEGIN
         IF vlong IS NULL
            -- BUG 19612 - 12/2011 - JRH  -  0019612: Provisiones (clave 10)
            OR vlong > 10 THEN
            -- Fi BUG 19612 - 12/2011 - JRH
            RETURN 9902173;   -- "La longitud de la cadena que codifica les condicions de filtrat no és correcta"
         END IF;

         FOR i IN 1 .. vlong LOOP
            DECLARE
               vcaracter      VARCHAR2(1);
            BEGIN
               vcaracter := SUBSTR(ptquery, i, 1);

               IF vcaracter NOT IN('1', '2', '3', '4', '5') THEN
                  RETURN 9902169;   -- "La cadena de texto que compone la consulta de SGT_SUBTABS_DET contiene carácteres incorrectos"
               END IF;
            END;
         END LOOP;

         RETURN 0;
      END fvalidaquery;

      FUNCTION f_valida_claves(p_rclaves IN rec_cons_subt, p_tquery IN VARCHAR2)
         RETURN NUMBER IS
         v_nlong        NUMBER := NVL(LENGTH(p_tquery), 0);
      BEGIN
         IF p_rclaves.csubtabla IS NULL THEN
            RETURN 9902176;   -- "Es necesario informar el código de subtabla"
         END IF;

         IF p_rclaves.fefecto IS NULL THEN
            RETURN 120077;   -- "Falta informar la fecha de efecto"
         END IF;

-- "Es necesario informar el código de subtabla"
         IF v_nlong = 0
            -- BUG 19612 - 12/2011 - JRH  -  0019612: Provisiones (clave 10)
            OR v_nlong > 10 THEN
            -- Fi BUG 19612 - 12/2011 - JRH
            RETURN 9902173;   -- "La longitud de la cadena que codifica les condicions de filtrat no és correcta"
         END IF;

         FOR i IN 1 .. v_nlong LOOP
            DECLARE
               v_tclave       sgt_subtabs_det.ccla1%TYPE;
            BEGIN
               CASE i
                  WHEN 1 THEN
                     v_tclave := p_rclaves.ccla1;
                  WHEN 2 THEN
                     v_tclave := p_rclaves.ccla2;
                  WHEN 3 THEN
                     v_tclave := p_rclaves.ccla3;
                  WHEN 4 THEN
                     v_tclave := p_rclaves.ccla4;
                  WHEN 5 THEN
                     v_tclave := p_rclaves.ccla5;
                  WHEN 6 THEN
                     v_tclave := p_rclaves.ccla6;
                  WHEN 7 THEN
                     v_tclave := p_rclaves.ccla7;
                  WHEN 8 THEN
                     v_tclave := p_rclaves.ccla8;
                  --JRH
               WHEN 9 THEN
                     v_tclave := p_rclaves.ccla9;
                  WHEN 10 THEN
                     v_tclave := p_rclaves.ccla10;
               --JRH
               END CASE;

               IF v_tclave IS NULL THEN
                  RETURN 9902174;   -- "La longitud de la cadena con las condiciones de filtrado y el número de claves con valor informado no coinciden"
               END IF;
            END;
         END LOOP;

         RETURN 0;
      END f_valida_claves;

      PROCEDURE graba_excepcion(p_nerror IN NUMBER, p_tdescrip IN VARCHAR2) IS
         v_tdescerror   tab_error.terror%TYPE;
      BEGIN
         v_tdescerror := pac_iobj_mensajes.f_get_descmensaje(p_nerror, f_usu_idioma);
         v_tdescerror := p_nerror || ': ' || v_tdescerror;
         -- Bug 0021655 - 19/03/2012 - JMF
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, SUBSTR(v_tdescerror, 1, 500),
                     SUBSTR(p_tdescrip, 1, 2500));
      END graba_excepcion;
   BEGIN
      vpasexec := 10;

      IF p_in_claves.cempres IS NOT NULL THEN
         v_cempres := p_in_claves.cempres;
      ELSE
         v_cempres := pac_md_common.f_get_cxtempresa();
      END IF;

      vpasexec := 20;
      -- Bug 0021655 - 19/03/2012 - JMF
      vparam := SUBSTR('e= ' || p_in_claves.cempres || ' t= ' || p_in_claves.csubtabla
                       || ' q= ' || p_in_cquery || ' e= ' || p_in_claves.fefecto || ' c1= '
                       || p_in_claves.ccla1 || ' c2= ' || p_in_claves.ccla2 || ' c3= '
                       || p_in_claves.ccla3 || ' c4= ' || p_in_claves.ccla4 || ' c5= '
                       || p_in_claves.ccla5 || ' c6= ' || p_in_claves.ccla6 || ' c7= '
                       || p_in_claves.ccla7 || ' c8= ' || p_in_claves.ccla8 || ' c9= '
                       || p_in_claves.ccla9 || ' c10= ' || p_in_claves.ccla10,
                       1, 1000);
      vpasexec := 30;
      v_retorno := fvalidaquery(p_in_cquery);

      IF v_retorno != 0 THEN
         p_out_error := v_retorno;
         -- Bug 0021655 - 19/03/2012 - JMF
         graba_excepcion(p_out_error, vparam);
         RETURN;
      END IF;

      vpasexec := 40;
      v_retorno := f_valida_claves(p_in_claves, p_in_cquery);

      IF v_retorno != 0 THEN
         p_out_error := v_retorno;
         -- Bug 0021655 - 19/03/2012 - JMF
         graba_excepcion(p_out_error, vparam);
         RETURN;
      END IF;

      vpasexec := 42;

      -- Comprobamos que la subtabla existe y está vigente en la fecha de efecto especificada
      DECLARE
         v_csubtabla    sgt_subtabs.csubtabla%TYPE;
      BEGIN
         SELECT csubtabla
           INTO v_csubtabla
           FROM sgt_subtabs s
          WHERE s.cempres = v_cempres
            AND s.csubtabla = p_in_claves.csubtabla
            AND(s.fbaja >= p_in_claves.fefecto
                OR s.fbaja IS NULL);
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            p_out_error := 9902175;   -- "Subtabla no existente o no vigente en la fecha de efecto indicada"
            graba_excepcion(p_out_error, vparam);
            RETURN;
      END;

      vpasexec := 45;

      BEGIN
         SELECT v1.cversubt
           INTO v_cversubt
           FROM sgt_subtabs_ver v1
          WHERE v1.csubtabla = p_in_claves.csubtabla
            AND v1.cempres = v_cempres
            AND v1.fefecto = (SELECT MAX(v2.fefecto)
                                FROM sgt_subtabs_ver v2
                               WHERE v2.csubtabla = v1.csubtabla
                                 AND v2.cempres = v1.cempres
                                 -- AND v2.fefecto < p_in_claves.fefecto); -- BUG 0038779 - FAL - 16/12/2015 - Filtrar por fecha menor o igual, en lugar de estricto menor, para cuando busca por el mismo dia de efecto de la versión
                                 AND v2.fefecto <= p_in_claves.fefecto);
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            v_cversubt := -1;
      END;

      vpasexec := 50;

      IF v_cversubt = -1 THEN
         p_out_error := 9902165;   -- "No se ha encontrado la versión de la subtabla"
         graba_excepcion(p_out_error, vparam);
         RETURN;
      END IF;

      vpasexec := 60;
      v_consulta := f_montar_consulta(p_in_cquery);
      vpasexec := 70;

      IF v_consulta IS NULL THEN
         p_out_error := 9902166;   -- "No se ha podido generar la consulta dinámica"
         graba_excepcion(p_out_error, vparam);
         RETURN;
      END IF;

      v_retorno := 1;
      vpasexec := 80;

--JRH   IMP
      IF INSTR(v_consulta, ':CCLA10', 1, 1) > 0 THEN
         OPEN cur FOR v_consulta
         USING v_cempres, p_in_claves.csubtabla, v_cversubt, p_in_claves.ccla1,
               p_in_claves.ccla2, p_in_claves.ccla3, p_in_claves.ccla4, p_in_claves.ccla5,
               p_in_claves.ccla6, p_in_claves.ccla7, p_in_claves.ccla8, p_in_claves.ccla9,
               p_in_claves.ccla10;
      ELSIF INSTR(v_consulta, ':CCLA9', 1, 1) > 0 THEN
         OPEN cur FOR v_consulta
         USING v_cempres, p_in_claves.csubtabla, v_cversubt, p_in_claves.ccla1,
               p_in_claves.ccla2, p_in_claves.ccla3, p_in_claves.ccla4, p_in_claves.ccla5,
               p_in_claves.ccla6, p_in_claves.ccla7, p_in_claves.ccla8, p_in_claves.ccla9;
      --JRH
      ELSIF INSTR(v_consulta, ':CCLA8', 1, 1) > 0 THEN
         OPEN cur FOR v_consulta
         USING v_cempres, p_in_claves.csubtabla, v_cversubt, p_in_claves.ccla1,
               p_in_claves.ccla2, p_in_claves.ccla3, p_in_claves.ccla4, p_in_claves.ccla5,
               p_in_claves.ccla6, p_in_claves.ccla7, p_in_claves.ccla8;
      ELSIF INSTR(v_consulta, ':CCLA7', 1, 1) > 0 THEN
         OPEN cur FOR v_consulta
         USING v_cempres, p_in_claves.csubtabla, v_cversubt, p_in_claves.ccla1,
               p_in_claves.ccla2, p_in_claves.ccla3, p_in_claves.ccla4, p_in_claves.ccla5,
               p_in_claves.ccla6, p_in_claves.ccla7;
      ELSIF INSTR(v_consulta, ':CCLA6', 1, 1) > 0 THEN
         OPEN cur FOR v_consulta
         USING v_cempres, p_in_claves.csubtabla, v_cversubt, p_in_claves.ccla1,
               p_in_claves.ccla2, p_in_claves.ccla3, p_in_claves.ccla4, p_in_claves.ccla5,
               p_in_claves.ccla6;
      ELSIF INSTR(v_consulta, ':CCLA5', 1, 1) > 0 THEN
         OPEN cur FOR v_consulta
         USING v_cempres, p_in_claves.csubtabla, v_cversubt, p_in_claves.ccla1,
               p_in_claves.ccla2, p_in_claves.ccla3, p_in_claves.ccla4, p_in_claves.ccla5;
      ELSIF INSTR(v_consulta, ':CCLA4', 1, 1) > 0 THEN
         OPEN cur FOR v_consulta
         USING v_cempres, p_in_claves.csubtabla, v_cversubt, p_in_claves.ccla1,
               p_in_claves.ccla2, p_in_claves.ccla3, p_in_claves.ccla4;
      ELSIF INSTR(v_consulta, ':CCLA3', 1, 1) > 0 THEN
         OPEN cur FOR v_consulta
         USING v_cempres, p_in_claves.csubtabla, v_cversubt, p_in_claves.ccla1,
               p_in_claves.ccla2, p_in_claves.ccla3;
      ELSIF INSTR(v_consulta, ':CCLA2', 1, 1) > 0 THEN
         OPEN cur FOR v_consulta
         USING v_cempres, p_in_claves.csubtabla, v_cversubt, p_in_claves.ccla1,
               p_in_claves.ccla2;
      ELSE
         OPEN cur FOR v_consulta
         USING v_cempres, p_in_claves.csubtabla, v_cversubt, p_in_claves.ccla1;
      END IF;

      FETCH cur
       INTO p_out_detalle;

      IF cur%FOUND THEN
         p_out_error := 0;
      ELSE
         p_out_error := 9902167;   -- "No se han encontrado registros en las subtablas SGT que cumplan los criterios de filtrado"
         graba_excepcion(p_out_error, vparam);
      END IF;

      CLOSE cur;

      RETURN;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         p_out_error := 1;
   END p_detalle_fila_din;

   PROCEDURE p_detalle_valor_din(
      p_in_claves IN rec_cons_subt,
      p_in_cquery IN VARCHAR2,
      p_in_cval IN NUMBER,
      p_out_nval OUT NUMBER,
      p_out_error OUT NUMBER) IS
      v_detalle      sgt_subtabs_det%ROWTYPE;
      v_error        NUMBER;
      vobject        VARCHAR2(100) := 'PAC_SUBTABLAS.P_DETALLE_VALOR_DIN';
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1000);
   BEGIN
      p_detalle_fila_din(p_in_claves, p_in_cquery, v_detalle, v_error);
      vpasexec := 20;

      IF p_in_cval IS NULL THEN
         p_out_error := 9902177;   -- "Falta informar el código de valor que se quiere consultar"
         vparam := 'p_in_cval: ' || p_in_cval;
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam,
                     p_out_error || ': '
                     || pac_iobj_mensajes.f_get_descmensaje(p_out_error, f_usu_idioma));
         RETURN;
      END IF;

      IF v_error = 0 THEN
         vpasexec := 30;

         CASE p_in_cval
            WHEN 1 THEN
               p_out_nval := v_detalle.nval1;
            WHEN 2 THEN
               p_out_nval := v_detalle.nval2;
            WHEN 3 THEN
               p_out_nval := v_detalle.nval3;
            WHEN 4 THEN
               p_out_nval := v_detalle.nval4;
            WHEN 5 THEN
               p_out_nval := v_detalle.nval5;
            WHEN 6 THEN
               p_out_nval := v_detalle.nval6;
            WHEN 7 THEN   -- 2013.01.07.NMM.24926: (POSRA200)-Vida Individual.i.
              BEGIN
                p_out_nval := v_detalle.nval7;
              EXCEPTION WHEN OTHERS THEN
                p_out_nval:=to_number(v_detalle.nval7,'fm999999.99999999','nls_numeric_characters = ''.,''');
              END;
            WHEN 8 THEN
              BEGIN
                p_out_nval := v_detalle.nval8;
              EXCEPTION WHEN OTHERS THEN
                p_out_nval:=to_number(v_detalle.nval8,'fm999999.99999999','nls_numeric_characters = ''.,''');
              END;
            WHEN 9 THEN
              BEGIN
                p_out_nval := v_detalle.nval9;
              EXCEPTION WHEN OTHERS THEN
                p_out_nval:=to_number(v_detalle.nval9,'fm999999.99999999','nls_numeric_characters = ''.,''');
              END;
            WHEN 10 THEN
              BEGIN
                p_out_nval := v_detalle.nval10;
              EXCEPTION WHEN OTHERS THEN
                p_out_nval:=to_number(v_detalle.nval10,'fm999999.99999999','nls_numeric_characters = ''.,''');
              END;
            ELSE
               p_out_nval := NULL;
         END CASE;
      ELSE
         vpasexec := 40;
         p_out_error := v_error;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         vparam := 'Parametros p_in_claves: pcempres= ' || p_in_claves.cempres
                   || ' pcsubtabla= ' || p_in_claves.csubtabla || ' pfefecto= '
                   || p_in_claves.fefecto || ' pccla1= ' || p_in_claves.ccla1 || ' pccla2= '
                   || p_in_claves.ccla2 || ' pccla3= ' || p_in_claves.ccla3 || ' pccla4= '
                   || p_in_claves.ccla4 || ' pccla5= ' || p_in_claves.ccla5 || ' pccla6= '
                   || p_in_claves.ccla6 || ' pccla7= ' || p_in_claves.ccla7 || ' pccla8= '
                   || p_in_claves.ccla8 || ' pccla9= ' || p_in_claves.ccla9 || ' pccla10= '
                   || p_in_claves.ccla10 || ' p_in_cquery= ' || p_in_cquery;
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         p_out_error := 1;
   END p_detalle_valor_din;

   FUNCTION f_detalle_valor_din(
      p_in_cempres IN sgt_subtabs_det.cempres%TYPE,
      p_in_csubtabla IN sgt_subtabs_det.csubtabla%TYPE,
      p_in_fefecto IN sgt_subtabs_ver.fefecto%TYPE,
      p_in_cquery IN VARCHAR2,
      p_in_cval IN NUMBER,
      p_in_ccla1 IN sgt_subtabs_det.ccla1%TYPE,
      p_in_ccla2 IN sgt_subtabs_det.ccla2%TYPE DEFAULT NULL,
      p_in_ccla3 IN sgt_subtabs_det.ccla3%TYPE DEFAULT NULL,
      p_in_ccla4 IN sgt_subtabs_det.ccla4%TYPE DEFAULT NULL,
      p_in_ccla5 IN sgt_subtabs_det.ccla5%TYPE DEFAULT NULL,
      p_in_ccla6 IN sgt_subtabs_det.ccla6%TYPE DEFAULT NULL,
      p_in_ccla7 IN sgt_subtabs_det.ccla7%TYPE DEFAULT NULL,
      p_in_ccla8 IN sgt_subtabs_det.ccla8%TYPE DEFAULT NULL,
      --JRH
      p_in_ccla9 IN sgt_subtabs_det.ccla9%TYPE DEFAULT NULL,
      p_in_ccla10 IN sgt_subtabs_det.ccla10%TYPE DEFAULT NULL
                                                             --JRH
   )
      RETURN NUMBER IS
      v_out_nval     NUMBER;
      v_out_error    NUMBER;
      vobject        VARCHAR2(100) := 'PAC_SUBTABLAS.F_DETALLE_VALOR_DIN';
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1000);
   BEGIN
      p_detalle_valor_din(f_rec_cons(p_in_cempres, p_in_csubtabla, p_in_fefecto, p_in_ccla1,
                                     p_in_ccla2, p_in_ccla3, p_in_ccla4, p_in_ccla5,
                                     p_in_ccla6, p_in_ccla7, p_in_ccla8, p_in_ccla9,
                                     p_in_ccla10),
                          p_in_cquery, p_in_cval, v_out_nval, v_out_error);

      IF v_out_error <> 0 THEN
         v_out_nval := NULL;
      END IF;

      RETURN v_out_nval;
   EXCEPTION
      WHEN OTHERS THEN
         vparam := 'Parametros p_in_claves: pcempres= ' || p_in_cempres || ' pcsubtabla= '
                   || p_in_csubtabla || ' pfefecto= ' || p_in_fefecto || ' pccla1= '
                   || p_in_ccla1 || ' pccla2= ' || p_in_ccla2 || ' pccla3= ' || p_in_ccla3
                   || ' pccla4= ' || p_in_ccla4 || ' pccla5= ' || p_in_ccla5 || ' pccla6= '
                   || p_in_ccla6 || ' pccla7= ' || p_in_ccla7 || ' pccla8= ' || p_in_ccla8
                   || ' pccla9= ' || p_in_ccla9 || ' pccla10= ' || p_in_ccla10
                   || ' p_in_cquery= ' || p_in_cquery;
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN NULL;
   END f_detalle_valor_din;

-- USA DBMS_SQL
/*
   PROCEDURE p_detalle_fila_sql(
      p_in_claves IN rec_cons_subt,
      p_in_cquery IN VARCHAR2,
      p_out_detalle OUT sgt_subtabs_det%ROWTYPE,
      p_out_error OUT NUMBER) IS
      v_consulta     VARCHAR2(1000);
      cursor_det     INTEGER;
      v_cversubt     sgt_subtabs_det.cversubt%TYPE;
      v_cempres      NUMBER;
      v_retorno      NUMBER := 0;
      v_retexec      NUMBER := 0;
      vobject        VARCHAR2(100) := 'PAC_SUBTABLAS.P_DETALLE_FILA_SQL';
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1000);
   BEGIN
      vpasexec := 10;

      IF p_in_claves.cempres IS NOT NULL THEN
         v_cempres := p_in_claves.cempres;
      ELSE
         v_cempres := pac_md_common.f_get_cxtempresa();
      END IF;

      BEGIN
         SELECT v1.cversubt
           INTO v_cversubt
           FROM sgt_subtabs_ver v1
          WHERE v1.csubtabla = p_in_claves.csubtabla
            AND v1.cempres = v_cempres
            AND v1.fefecto = (SELECT MAX(v2.fefecto)
                                FROM sgt_subtabs_ver v2
                               WHERE v2.csubtabla = v1.csubtabla
                                 AND v2.fefecto < p_in_claves.fefecto);
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            v_cversubt := -1;
      END;

      IF v_cversubt = -1 THEN
         p_out_error := 2000001;
         RETURN;
      END IF;

      vpasexec := 20;
      v_consulta := f_montar_consulta(p_in_cquery);

      --DBMS_OUTPUT.PUT_LINE(v_consulta);
      IF v_consulta IS NULL THEN
         p_out_error := 2000002;
         RETURN;
      END IF;

      v_retorno := 1;
      vpasexec := 30;
      cursor_det := DBMS_SQL.open_cursor;
      DBMS_SQL.parse(cursor_det, v_consulta, DBMS_SQL.native);
      DBMS_SQL.bind_variable(cursor_det, ':CEMPRES', v_cempres);
      DBMS_SQL.bind_variable(cursor_det, ':CSUBTABLA', p_in_claves.csubtabla);
      DBMS_SQL.bind_variable(cursor_det, ':CVERSUBT', v_cversubt);

      IF INSTR(v_consulta, ':CCLA1', 1, 1) > 0 THEN
         DBMS_SQL.bind_variable(cursor_det, ':CCLA1', p_in_claves.ccla1);
      END IF;

      IF INSTR(v_consulta, ':CCLA2', 1, 1) > 0 THEN
         DBMS_SQL.bind_variable(cursor_det, ':CCLA2', p_in_claves.ccla2);
      END IF;

      IF INSTR(v_consulta, ':CCLA3', 1, 1) > 0 THEN
         DBMS_SQL.bind_variable(cursor_det, ':CCLA3', p_in_claves.ccla3);
      END IF;

      IF INSTR(v_consulta, ':CCLA4', 1, 1) > 0 THEN
         DBMS_SQL.bind_variable(cursor_det, ':CCLA4', p_in_claves.ccla4);
      END IF;

      IF INSTR(v_consulta, ':CCLA5', 1, 1) > 0 THEN
         DBMS_SQL.bind_variable(cursor_det, ':CCLA5', p_in_claves.ccla5);
      END IF;

      IF INSTR(v_consulta, ':CCLA6', 1, 1) > 0 THEN
         DBMS_SQL.bind_variable(cursor_det, ':CCLA6', p_in_claves.ccla6);
      END IF;

      IF INSTR(v_consulta, ':CCLA7', 1, 1) > 0 THEN
         DBMS_SQL.bind_variable(cursor_det, ':CCLA7', p_in_claves.ccla7);
      END IF;

      IF INSTR(v_consulta, ':CCLA8', 1, 1) > 0 THEN
         DBMS_SQL.bind_variable(cursor_det, ':CCLA8', p_in_claves.ccla8);
      END IF;

      DBMS_SQL.define_column(cursor_det, 1, p_out_detalle.sdetalle);
      DBMS_SQL.define_column(cursor_det, 2, p_out_detalle.cempres);
      DBMS_SQL.define_column(cursor_det, 3, p_out_detalle.csubtabla);
      DBMS_SQL.define_column(cursor_det, 4, p_out_detalle.cversubt);
      DBMS_SQL.define_column(cursor_det, 5, p_out_detalle.ccla1);
      DBMS_SQL.define_column(cursor_det, 6, p_out_detalle.ccla2);
      DBMS_SQL.define_column(cursor_det, 7, p_out_detalle.ccla3);
      DBMS_SQL.define_column(cursor_det, 8, p_out_detalle.ccla4);
      DBMS_SQL.define_column(cursor_det, 9, p_out_detalle.ccla5);
      DBMS_SQL.define_column(cursor_det, 10, p_out_detalle.ccla6);
      DBMS_SQL.define_column(cursor_det, 11, p_out_detalle.ccla7);
      DBMS_SQL.define_column(cursor_det, 12, p_out_detalle.ccla8);
      DBMS_SQL.define_column(cursor_det, 13, p_out_detalle.nval1);
      DBMS_SQL.define_column(cursor_det, 14, p_out_detalle.nval2);
      DBMS_SQL.define_column(cursor_det, 15, p_out_detalle.nval3);
      DBMS_SQL.define_column(cursor_det, 16, p_out_detalle.nval4);
      DBMS_SQL.define_column(cursor_det, 17, p_out_detalle.nval5);
      DBMS_SQL.define_column(cursor_det, 18, p_out_detalle.nval6);
      DBMS_SQL.define_column(cursor_det, 19, p_out_detalle.falta);
      DBMS_SQL.define_column(cursor_det, 20, p_out_detalle.cusualt, 32);
      DBMS_SQL.define_column(cursor_det, 21, p_out_detalle.fmodifi);
      DBMS_SQL.define_column(cursor_det, 22, p_out_detalle.cusumod, 32);
      v_retexec := DBMS_SQL.EXECUTE(cursor_det);

      IF DBMS_SQL.fetch_rows(cursor_det) > 0 THEN
         DBMS_SQL.COLUMN_VALUE(cursor_det, 1, p_out_detalle.sdetalle);
         DBMS_SQL.COLUMN_VALUE(cursor_det, 2, p_out_detalle.cempres);
         DBMS_SQL.COLUMN_VALUE(cursor_det, 3, p_out_detalle.csubtabla);
         DBMS_SQL.COLUMN_VALUE(cursor_det, 4, p_out_detalle.cversubt);
         DBMS_SQL.COLUMN_VALUE(cursor_det, 5, p_out_detalle.ccla1);
         DBMS_SQL.COLUMN_VALUE(cursor_det, 6, p_out_detalle.ccla2);
         DBMS_SQL.COLUMN_VALUE(cursor_det, 7, p_out_detalle.ccla3);
         DBMS_SQL.COLUMN_VALUE(cursor_det, 8, p_out_detalle.ccla4);
         DBMS_SQL.COLUMN_VALUE(cursor_det, 9, p_out_detalle.ccla5);
         DBMS_SQL.COLUMN_VALUE(cursor_det, 10, p_out_detalle.ccla6);
         DBMS_SQL.COLUMN_VALUE(cursor_det, 11, p_out_detalle.ccla7);
         DBMS_SQL.COLUMN_VALUE(cursor_det, 12, p_out_detalle.ccla8);
         DBMS_SQL.COLUMN_VALUE(cursor_det, 13, p_out_detalle.nval1);
         DBMS_SQL.COLUMN_VALUE(cursor_det, 14, p_out_detalle.nval2);
         DBMS_SQL.COLUMN_VALUE(cursor_det, 15, p_out_detalle.nval3);
         DBMS_SQL.COLUMN_VALUE(cursor_det, 16, p_out_detalle.nval4);
         DBMS_SQL.COLUMN_VALUE(cursor_det, 17, p_out_detalle.nval5);
         DBMS_SQL.COLUMN_VALUE(cursor_det, 18, p_out_detalle.nval6);
         DBMS_SQL.COLUMN_VALUE(cursor_det, 19, p_out_detalle.falta);
         DBMS_SQL.COLUMN_VALUE(cursor_det, 20, p_out_detalle.cusualt);
         DBMS_SQL.COLUMN_VALUE(cursor_det, 21, p_out_detalle.fmodifi);
         DBMS_SQL.COLUMN_VALUE(cursor_det, 22, p_out_detalle.cusumod);
         p_out_error := 0;
      ELSE
         p_out_error := 2000003;
      END IF;

      DBMS_SQL.close_cursor(cursor_det);
      RETURN;
   EXCEPTION
      WHEN OTHERS THEN
         vparam := 'Parametros p_in_claves: pcempres= ' || p_in_claves.cempres
                   || ' pcsubtabla= ' || p_in_claves.csubtabla || ' pfefecto= '
                   || p_in_claves.fefecto || ' pccla1= ' || p_in_claves.ccla1 || ' pccla2= '
                   || p_in_claves.ccla2 || ' pccla3= ' || p_in_claves.ccla3 || ' pccla4= '
                   || p_in_claves.ccla4 || ' pccla5= ' || p_in_claves.ccla5 || ' pccla6= '
                   || p_in_claves.ccla6 || ' pccla7= ' || p_in_claves.ccla7 || ' pccla8= '
                   || p_in_claves.ccla8 || ' p_in_cquery= ' || p_in_cquery;
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN;
   END p_detalle_fila_sql;


   PROCEDURE p_detalle_valor_sql(
      p_in_claves IN rec_cons_subt,
      p_in_cquery IN VARCHAR2,
      p_in_cval IN NUMBER,
      p_out_nval OUT NUMBER,
      p_out_error OUT NUMBER) IS
      v_detalle      sgt_subtabs_det%ROWTYPE;
      v_error        NUMBER;
      vobject        VARCHAR2(100) := 'PAC_SUBTABLAS.P_DETALLE_VALOR_SQL';
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1000);
   BEGIN
      p_detalle_fila_sql(p_in_claves, p_in_cquery, v_detalle, v_error);

      IF v_error = 0 THEN
         CASE p_in_cval
            WHEN 1 THEN
               p_out_nval := v_detalle.nval1;
            WHEN 2 THEN
               p_out_nval := v_detalle.nval2;
            WHEN 3 THEN
               p_out_nval := v_detalle.nval3;
            WHEN 4 THEN
               p_out_nval := v_detalle.nval4;
            WHEN 5 THEN
               p_out_nval := v_detalle.nval5;
            WHEN 6 THEN
               p_out_nval := v_detalle.nval6;
            ELSE
               p_out_nval := NULL;
         END CASE;
      ELSE
         p_out_error := v_error;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         vparam := 'Parametros p_in_claves: pcempres= ' || p_in_claves.cempres
                   || ' pcsubtabla= ' || p_in_claves.csubtabla || ' pfefecto= '
                   || p_in_claves.fefecto || ' pccla1= ' || p_in_claves.ccla1 || ' pccla2= '
                   || p_in_claves.ccla2 || ' pccla3= ' || p_in_claves.ccla3 || ' pccla4= '
                   || p_in_claves.ccla4 || ' pccla5= ' || p_in_claves.ccla5 || ' pccla6= '
                   || p_in_claves.ccla6 || ' pccla7= ' || p_in_claves.ccla7 || ' pccla8= '
                   || p_in_claves.ccla8 || ' p_in_cquery= ' || p_in_cquery;
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN;
   END p_detalle_valor_sql;

   FUNCTION f_detalle_valor_sql(
      p_in_cempres IN sgt_subtabs_det.cempres%TYPE,
      p_in_csubtabla IN sgt_subtabs_det.csubtabla%TYPE,
      p_in_fefecto IN sgt_subtabs_ver.fefecto%TYPE,
      p_in_cquery IN VARCHAR2,
      p_in_cval IN NUMBER,
      p_in_ccla1 IN sgt_subtabs_det.ccla1%TYPE,
      p_in_ccla2 IN sgt_subtabs_det.ccla2%TYPE DEFAULT NULL,
      p_in_ccla3 IN sgt_subtabs_det.ccla3%TYPE DEFAULT NULL,
      p_in_ccla4 IN sgt_subtabs_det.ccla4%TYPE DEFAULT NULL,
      p_in_ccla5 IN sgt_subtabs_det.ccla5%TYPE DEFAULT NULL,
      p_in_ccla6 IN sgt_subtabs_det.ccla6%TYPE DEFAULT NULL,
      p_in_ccla7 IN sgt_subtabs_det.ccla7%TYPE DEFAULT NULL,
      p_in_ccla8 IN sgt_subtabs_det.ccla8%TYPE DEFAULT NULL)
      RETURN NUMBER IS
      v_out_nval     NUMBER;
      v_out_error    NUMBER;
      vobject        VARCHAR2(100) := 'PAC_SUBTABLAS.F_DETALLE_VALOR_SQL';
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1000);
   BEGIN
      p_detalle_valor_sql(f_rec_cons(p_in_cempres, p_in_csubtabla, p_in_fefecto, p_in_ccla1,
                                     p_in_ccla2, p_in_ccla3, p_in_ccla4, p_in_ccla5,
                                     p_in_ccla6, p_in_ccla7, p_in_ccla8),
                          p_in_cquery, p_in_cval, v_out_nval, v_out_error);

      IF v_out_error <> 0 THEN
         v_out_nval := NULL;
      END IF;

      RETURN v_out_nval;
   EXCEPTION
      WHEN OTHERS THEN
         vparam := 'Parametros p_in_claves: pcempres= ' || p_in_cempres || ' pcsubtabla= '
                   || p_in_csubtabla || ' pfefecto= ' || p_in_fefecto || ' pccla1= '
                   || p_in_ccla1 || ' pccla2= ' || p_in_ccla2 || ' pccla3= ' || p_in_ccla3
                   || ' pccla4= ' || p_in_ccla4 || ' pccla5= ' || p_in_ccla5 || ' pccla6= '
                   || p_in_ccla6 || ' pccla7= ' || p_in_ccla7 || ' pccla8= ' || p_in_ccla8
                   || ' p_in_cquery= ' || p_in_cquery;
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN NULL;
   END f_detalle_valor_sql;
*/
   FUNCTION f_vsubtabla(
      p_in_nsesion IN NUMBER,
      p_in_csubtabla IN sgt_subtabs_det.csubtabla%TYPE,
      p_in_cquery IN VARCHAR2,
      p_in_cval IN NUMBER,
      p_in_ccla1 IN sgt_subtabs_det.ccla1%TYPE,
      p_in_ccla2 IN sgt_subtabs_det.ccla2%TYPE DEFAULT NULL,
      p_in_ccla3 IN sgt_subtabs_det.ccla3%TYPE DEFAULT NULL,
      p_in_ccla4 IN sgt_subtabs_det.ccla4%TYPE DEFAULT NULL,
      p_in_ccla5 IN sgt_subtabs_det.ccla5%TYPE DEFAULT NULL,
      p_in_ccla6 IN sgt_subtabs_det.ccla6%TYPE DEFAULT NULL,
      p_in_ccla7 IN sgt_subtabs_det.ccla7%TYPE DEFAULT NULL,
      p_in_ccla8 IN sgt_subtabs_det.ccla8%TYPE DEFAULT NULL,
      --JRH
      p_in_ccla9 IN sgt_subtabs_det.ccla9%TYPE DEFAULT NULL,
      p_in_ccla10 IN sgt_subtabs_det.ccla10%TYPE DEFAULT NULL,
      --JRH
      p_in_v_fecha IN DATE DEFAULT NULL   -- Bug 26638/161275 - 15/04/2014 - AMC
                                       )
      RETURN NUMBER IS
/****************************************************************************
   FUNCTION  F_VSUBTABLA
   Recupera el valor de una subtabla.
   La empresa la obtiene del usuario.
   La fecha de efecto para obtener la versión de la subtabla se obtiene de los
   parámetros de la sesión
****************************************************************************/
      v_fecha        DATE;
      v_cempres      NUMBER;
      v_out_nval     NUMBER;
      v_out_error    NUMBER;
      vobject        VARCHAR2(100) := 'PAC_SUBTABLAS.F_VSUBTABLA';
      vparam         tab_error.tdescrip%TYPE;
      vpasexec       NUMBER(8) := 1;
   BEGIN
      IF p_in_nsesion = -1
         AND p_in_v_fecha IS NULL THEN
         v_fecha := TRUNC(f_sysdate);
      -- Bug 26638/161275 - 15/04/2014 - AMC
      ELSIF p_in_nsesion = -1
            AND p_in_v_fecha IS NOT NULL THEN
         v_fecha := p_in_v_fecha;
      ELSE
         DECLARE
            vnfecha        NUMBER;
         BEGIN
            vpasexec := 2;
            --  JLB - I
             -- SELECT valor
              --  INTO vnfecha
              --  FROM sgt_parms_transitorios
              -- WHERE sesion = p_in_nsesion
              --   AND parametro = 'FECEFE';
            vnfecha := pac_sgt.get(p_in_nsesion, 'FECEFE');
            v_fecha := TO_DATE(vnfecha, 'yyyymmdd');
         -- JLB - F
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               v_fecha := TRUNC(f_sysdate);
         END;
      END IF;

      vpasexec := 3;
      v_cempres := pac_md_common.f_get_cxtempresa();
      vpasexec := 4;
      pac_subtablas.p_detalle_valor_din(pac_subtablas.f_rec_cons(v_cempres, p_in_csubtabla,
                                                                 v_fecha, p_in_ccla1,
                                                                 p_in_ccla2, p_in_ccla3,
                                                                 p_in_ccla4, p_in_ccla5,
                                                                 p_in_ccla6, p_in_ccla7,
                                                                 p_in_ccla8, p_in_ccla9,
                                                                 p_in_ccla10),
                                        p_in_cquery, p_in_cval, v_out_nval, v_out_error);

      IF v_out_error <> 0 THEN
         v_out_nval := NULL;
      END IF;

      vpasexec := 5;
      RETURN v_out_nval;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN NULL;
      WHEN OTHERS THEN
         vparam := SUBSTR('p_in_nsesion: ' || p_in_nsesion || 'p_in_csubtabla: '
                          || p_in_csubtabla || 'p_in_cquery: ' || p_in_cquery || 'p_in_cval: '
                          || p_in_cval || 'p_in_ccla1: ' || p_in_ccla1 || 'p_in_ccla2: '
                          || p_in_ccla2 || 'p_in_ccla3: ' || p_in_ccla3 || 'p_in_ccla4: '
                          || p_in_ccla4 || 'p_in_ccla5: ' || p_in_ccla5 || 'p_in_ccla5: '
                          || p_in_ccla5 || 'p_in_ccla7: ' || p_in_ccla7 || 'p_in_ccla6: '
                          || p_in_ccla6 || 'p_in_ccla7: ' || p_in_ccla7 || 'p_in_ccla8: '
                          || p_in_ccla8 || 'p_in_ccla9: ' || p_in_ccla9 || 'p_in_ccla10: '
                          || p_in_ccla10,
                          1, 500);
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN NULL;
   END f_vsubtabla;
END pac_subtablas;

/

  GRANT EXECUTE ON "AXIS"."PAC_SUBTABLAS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_SUBTABLAS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_SUBTABLAS" TO "PROGRAMADORESCSI";
