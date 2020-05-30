--------------------------------------------------------
--  DDL for Package Body PAC_SUBTABLAS_SEG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_SUBTABLAS_SEG" IS
       /******************************************************************************
       NOMBRE:     pac_subtablas_seg
       PROPÓSITO:

       REVISIONES:
       Ver        Fecha        Autor             Descripción
       ---------  ----------  ---------------  ------------------------------------
       1           25/10/2013  DCT              Creación funciones f_cero_seg y f_ftarifaseg BUG 27923/156553

   /* Función f_montar_consultav
      Monta la consulta de la tabla subtabs_seg_det. Devuelve un VARCHAR2 con la
      consulta construida.
      Parámetro de entrada: p_in_cquery es una cadena con una posición para
      establecer la condición en cada una de las claves que queramos usar (de las
      8 que tiene la tabla subtabs_seg_det)
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
   FUNCTION f_montar_consulta(
      p_in_cquery IN VARCHAR2,
      psseguro IN subtabs_seg_det.sseguro%TYPE,
      pnriesgo IN subtabs_seg_det.nriesgo%TYPE,
      pcgarant IN subtabs_seg_det.cgarant%TYPE,
      pnmovimi IN subtabs_seg_det.nmovimi%TYPE,
      pcpregun IN subtabs_seg_det.cpregun%TYPE,
      p_in_ptablas IN VARCHAR2)
      RETURN VARCHAR2 IS
      v_query        VARCHAR2(1000);
      v_orden        VARCHAR2(200) := ' ORDER BY';
      v_lon_cquery   NUMBER;
      pos            NUMBER;
      v_numclave     NUMBER;
      v_condnum      VARCHAR(1);
      v_condchar     VARCHAR(2);
      vobject        VARCHAR2(100) := 'pac_subtablas_seg.F_MONTAR_CONSULTA';
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1000)
         := 'Parametros: psseguro= ' || psseguro || ' pnriesgo= ' || pnriesgo || ' pcgarant= '
            || pcgarant || ' pnmovimi= ' || pnmovimi || ' pcpregun= ' || pcpregun;
   BEGIN
      v_lon_cquery := LENGTH(p_in_cquery);

      IF v_lon_cquery < 1 THEN
         RETURN NULL;
      END IF;

      IF p_in_ptablas = 'EST' THEN
         v_query :=
            'SELECT * FROM estsubtabs_seg_det D WHERE D.SSEGURO = :SSEGURO AND D.NRIESGO = :NRIESGO AND D.CGARANT = :CGARANT AND D.NMOVIMI = :NMOVIMI AND D.CPREGUN = :CPREGUN';
      ELSE
         v_query :=
            'SELECT * FROM subtabs_seg_det D WHERE D.SSEGURO = :SSEGURO AND D.NRIESGO = :NRIESGO AND D.CGARANT = :CGARANT AND D.NMOVIMI = :NMOVIMI AND D.CPREGUN = :CPREGUN';
      END IF;

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
               v_query := v_query || ' AND (D.CCLA1 ' || v_condchar || ' :CCLA1 OR D.CCLA1 = '
                          || v_comodin || ')';

               IF v_condnum IN(1, 2) THEN
                  v_orden := v_orden || ' D.CCLA1 DESC';
               ELSE
                  v_orden := v_orden || ' D.CCLA1';
               END IF;
            END IF;

            IF v_numclave = 2 THEN
               v_query := v_query || ' AND (D.CCLA2 ' || v_condchar || ' :CCLA2 OR D.CCLA2 = '
                          || v_comodin || ')';

               IF v_condnum IN(1, 2) THEN
                  v_orden := v_orden || ',D.CCLA2 DESC';
               ELSE
                  v_orden := v_orden || ',D.CCLA2';
               END IF;
            END IF;

            IF v_numclave = 3 THEN
               v_query := v_query || ' AND (D.CCLA3 ' || v_condchar || ' :CCLA3 OR D.CCLA3 = '
                          || v_comodin || ')';

               IF v_condnum IN(1, 2) THEN
                  v_orden := v_orden || ',D.CCLA3 DESC';
               ELSE
                  v_orden := v_orden || ',D.CCLA3';
               END IF;
            END IF;

            IF v_numclave = 4 THEN
               v_query := v_query || ' AND (D.CCLA4 ' || v_condchar || ' :CCLA4 OR D.CCLA4 = '
                          || v_comodin || ')';

               IF v_condnum IN(1, 2) THEN
                  v_orden := v_orden || ',D.CCLA4 DESC';
               ELSE
                  v_orden := v_orden || ',D.CCLA4';
               END IF;
            END IF;

            IF v_numclave = 5 THEN
               v_query := v_query || ' AND (D.CCLA5 ' || v_condchar || ' :CCLA5 OR D.CCLA5 = '
                          || v_comodin || ')';

               IF v_condnum IN(1, 2) THEN
                  v_orden := v_orden || ',D.CCLA5 DESC';
               ELSE
                  v_orden := v_orden || ',D.CCLA5';
               END IF;
            END IF;

            IF v_numclave = 6 THEN
               v_query := v_query || ' AND (D.CCLA6 ' || v_condchar || ' :CCLA6 OR D.CCLA6 = '
                          || v_comodin || ')';

               IF v_condnum IN(1, 2) THEN
                  v_orden := v_orden || ',D.CCLA6 DESC';
               ELSE
                  v_orden := v_orden || ',D.CCLA6';
               END IF;
            END IF;

            IF v_numclave = 7 THEN
               v_query := v_query || ' AND (D.CCLA7 ' || v_condchar || ' :CCLA7 OR D.CCLA7 = '
                          || v_comodin || ')';

               IF v_condnum IN(1, 2) THEN
                  v_orden := v_orden || ',D.CCLA7 DESC';
               ELSE
                  v_orden := v_orden || ',D.CCLA7';
               END IF;
            END IF;

            IF v_numclave = 8 THEN
               v_query := v_query || ' AND (D.CCLA8 ' || v_condchar || ' :CCLA8 OR D.CCLA8 = '
                          || v_comodin || ')';

               IF v_condnum IN(1, 2) THEN
                  v_orden := v_orden || ',D.CCLA8 DESC';
               ELSE
                  v_orden := v_orden || ',D.CCLA8';
               END IF;
            END IF;

            IF v_numclave = 9 THEN
               v_query := v_query || ' AND (D.CCLA9 ' || v_condchar || ' :CCLA9 OR D.CCLA9 = '
                          || v_comodin || ')';

               IF v_condnum IN(1, 2) THEN
                  v_orden := v_orden || ',D.CCLA9 DESC';
               ELSE
                  v_orden := v_orden || ',D.CCLA9';
               END IF;
            END IF;

            IF v_numclave = 10 THEN
               v_query := v_query || ' AND (D.CCLA10 ' || v_condchar
                          || ' :CCLA10 OR D.CCLA10 = ' || v_comodin || ')';

               IF v_condnum IN(1, 2) THEN
                  v_orden := v_orden || ',D.CCLA10 DESC';
               ELSE
                  v_orden := v_orden || ',D.CCLA10';
               END IF;
            END IF;
         END IF;
      END LOOP;

      vpasexec := 20;
      v_query := v_query || v_orden;   -- Bug 34967/199918 - 06/03/2015 - AMC
      RETURN v_query;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN NULL;
   END f_montar_consulta;

   FUNCTION f_rec_cons_seg(
      psseguro IN subtabs_seg_det.sseguro%TYPE,
      pnriesgo IN subtabs_seg_det.nriesgo%TYPE,
      pcgarant IN subtabs_seg_det.cgarant%TYPE,
      pnmovimi IN subtabs_seg_det.nmovimi%TYPE,
      pcpregun IN subtabs_seg_det.cpregun%TYPE,
      pccla1 IN subtabs_seg_det.ccla1%TYPE,
      pccla2 IN subtabs_seg_det.ccla2%TYPE,
      pccla3 IN subtabs_seg_det.ccla3%TYPE,
      pccla4 IN subtabs_seg_det.ccla4%TYPE,
      pccla5 IN subtabs_seg_det.ccla5%TYPE,
      pccla6 IN subtabs_seg_det.ccla6%TYPE,
      pccla7 IN subtabs_seg_det.ccla7%TYPE,
      pccla8 IN subtabs_seg_det.ccla8%TYPE,
      pccla9 IN subtabs_seg_det.ccla9%TYPE,
      pccla10 IN subtabs_seg_det.ccla10%TYPE)
      RETURN rec_cons_subt_det IS
      v_rec          rec_cons_subt_det;
      vobject        VARCHAR2(100) := 'pac_subtablas_seg.f_rec_cons_seg';
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1000)
         := 'Parametros: psseguro= ' || psseguro || ' pnriesgo= ' || pnriesgo || ' pcgarant= '
            || pcgarant || ' pnmovimi= ' || pnmovimi || ' pcpregun= ' || pcpregun
            || ' pccla1= ' || pccla1 || ' pccla2= ' || pccla2 || ' pccla3= ' || pccla3
            || ' pccla4= ' || pccla4 || ' pccla5= ' || pccla5 || ' pccla6= ' || pccla6
            || ' pccla7= ' || pccla7 || ' pccla8= ' || pccla8 || ' pccla9= ' || pccla9
            || ' pccla10= ' || pccla10;
   BEGIN
      v_rec.sseguro := psseguro;
      v_rec.nriesgo := pnriesgo;
      v_rec.cgarant := pcgarant;
      v_rec.nmovimi := pnmovimi;
      v_rec.cpregun := pcpregun;
      v_rec.ccla1 := pccla1;
      v_rec.ccla2 := pccla2;
      v_rec.ccla3 := pccla3;
      v_rec.ccla4 := pccla4;
      v_rec.ccla5 := pccla5;
      v_rec.ccla6 := pccla6;
      v_rec.ccla7 := pccla7;
      v_rec.ccla8 := pccla8;
      v_rec.ccla9 := pccla9;
      v_rec.ccla10 := pccla10;
      RETURN v_rec;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN NULL;
   END f_rec_cons_seg;

   PROCEDURE p_detalle_fila_din_seg(
      p_in_claves IN rec_cons_subt_det,
      p_in_cquery IN VARCHAR2,
      p_in_ptablas IN VARCHAR2,
      p_out_detalle OUT subtabs_seg_det%ROWTYPE,
      p_out_error OUT NUMBER) IS
      v_consulta     VARCHAR2(1000);
      cursor_det     INTEGER;
      v_cempres      NUMBER;
      v_retorno      NUMBER := 0;
      v_retexec      NUMBER := 0;
      vobject        VARCHAR2(100) := 'pac_subtablas_seg.P_DETALLE_FILA_DIN_SEG';
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
            OR vlong > 10 THEN
            RETURN 9902173;   -- "La longitud de la cadena que codifica les condicions de filtrat no és correcta"
         END IF;

         FOR i IN 1 .. vlong LOOP
            DECLARE
               vcaracter      VARCHAR2(1);
            BEGIN
               vcaracter := SUBSTR(ptquery, i, 1);

               IF vcaracter NOT IN('1', '2', '3', '4', '5') THEN
                  RETURN 9902169;   -- "La cadena de texto que compone la consulta de subtabs_seg_det contiene carácteres incorrectos"
               END IF;
            END;
         END LOOP;

         RETURN 0;
      END fvalidaquery;

      FUNCTION f_valida_claves(p_rclaves IN rec_cons_subt_det, p_tquery IN VARCHAR2)
         RETURN NUMBER IS
         v_nlong        NUMBER := NVL(LENGTH(p_tquery), 0);
      BEGIN
-- "Es necesario informar el código de subtabla"
         IF v_nlong = 0
            OR v_nlong > 10 THEN
            RETURN 9902173;   -- "La longitud de la cadena que codifica les condicions de filtrat no és correcta"
         END IF;

         FOR i IN 1 .. v_nlong LOOP
            DECLARE
               v_tclave       subtabs_seg_det.ccla1%TYPE;
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
                  WHEN 9 THEN
                     v_tclave := p_rclaves.ccla9;
                  WHEN 10 THEN
                     v_tclave := p_rclaves.ccla10;
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
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, SUBSTR(v_tdescerror, 1, 500),
                     SUBSTR(p_tdescrip, 1, 2500));
      END graba_excepcion;
   BEGIN
      vpasexec := 10;
      vpasexec := 20;
      vparam := SUBSTR('sseguro= ' || p_in_claves.sseguro || ' nriesgo= '
                       || p_in_claves.nriesgo || ' cgarant= ' || p_in_claves.cgarant
                       || ' nmovimi= ' || p_in_claves.nmovimi || ' cpregun= '
                       || p_in_claves.cpregun || ' q= ' || p_in_cquery || ' c1= '
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
         graba_excepcion(p_out_error, vparam);
         RETURN;
      END IF;

      vpasexec := 40;
      v_retorno := f_valida_claves(p_in_claves, p_in_cquery);

      IF v_retorno != 0 THEN
         p_out_error := v_retorno;
         graba_excepcion(p_out_error, vparam);
         RETURN;
      END IF;

      vpasexec := 60;
      v_consulta := f_montar_consulta(p_in_cquery, p_in_claves.sseguro, p_in_claves.nriesgo,
                                      p_in_claves.cgarant, p_in_claves.nmovimi,
                                      p_in_claves.cpregun, p_in_ptablas);
      vpasexec := 70;

      IF v_consulta IS NULL THEN
         p_out_error := 9902166;   -- "No se ha podido generar la consulta dinámica"
         graba_excepcion(p_out_error, vparam);
         RETURN;
      END IF;

      v_retorno := 1;
      vpasexec := 80;

      IF INSTR(v_consulta, ':CCLA10', 1, 1) > 0 THEN
         OPEN cur FOR v_consulta
         USING p_in_claves.sseguro, p_in_claves.nriesgo, p_in_claves.cgarant,
               p_in_claves.nmovimi, p_in_claves.cpregun, p_in_claves.ccla1, p_in_claves.ccla2,
               p_in_claves.ccla3, p_in_claves.ccla4, p_in_claves.ccla5, p_in_claves.ccla6,
               p_in_claves.ccla7, p_in_claves.ccla8, p_in_claves.ccla9, p_in_claves.ccla10;
      ELSIF INSTR(v_consulta, ':CCLA9', 1, 1) > 0 THEN
         OPEN cur FOR v_consulta
         USING p_in_claves.sseguro, p_in_claves.nriesgo, p_in_claves.cgarant,
               p_in_claves.nmovimi, p_in_claves.cpregun, p_in_claves.ccla1, p_in_claves.ccla2,
               p_in_claves.ccla3, p_in_claves.ccla4, p_in_claves.ccla5, p_in_claves.ccla6,
               p_in_claves.ccla7, p_in_claves.ccla8, p_in_claves.ccla9;
      ELSIF INSTR(v_consulta, ':CCLA8', 1, 1) > 0 THEN
         OPEN cur FOR v_consulta
         USING p_in_claves.sseguro, p_in_claves.nriesgo, p_in_claves.cgarant,
               p_in_claves.nmovimi, p_in_claves.cpregun, p_in_claves.ccla1, p_in_claves.ccla2,
               p_in_claves.ccla3, p_in_claves.ccla4, p_in_claves.ccla5, p_in_claves.ccla6,
               p_in_claves.ccla7, p_in_claves.ccla8;
      ELSIF INSTR(v_consulta, ':CCLA7', 1, 1) > 0 THEN
         OPEN cur FOR v_consulta
         USING p_in_claves.sseguro, p_in_claves.nriesgo, p_in_claves.cgarant,
               p_in_claves.nmovimi, p_in_claves.cpregun, p_in_claves.ccla1, p_in_claves.ccla2,
               p_in_claves.ccla3, p_in_claves.ccla4, p_in_claves.ccla5, p_in_claves.ccla6,
               p_in_claves.ccla7;
      ELSIF INSTR(v_consulta, ':CCLA6', 1, 1) > 0 THEN
         OPEN cur FOR v_consulta
         USING p_in_claves.sseguro, p_in_claves.nriesgo, p_in_claves.cgarant,
               p_in_claves.nmovimi, p_in_claves.cpregun, p_in_claves.ccla1, p_in_claves.ccla2,
               p_in_claves.ccla3, p_in_claves.ccla4, p_in_claves.ccla5, p_in_claves.ccla6;
      ELSIF INSTR(v_consulta, ':CCLA5', 1, 1) > 0 THEN
         OPEN cur FOR v_consulta
         USING p_in_claves.sseguro, p_in_claves.nriesgo, p_in_claves.cgarant,
               p_in_claves.nmovimi, p_in_claves.cpregun, p_in_claves.ccla1, p_in_claves.ccla2,
               p_in_claves.ccla3, p_in_claves.ccla4, p_in_claves.ccla5;
      ELSIF INSTR(v_consulta, ':CCLA4', 1, 1) > 0 THEN
         OPEN cur FOR v_consulta
         USING p_in_claves.sseguro, p_in_claves.nriesgo, p_in_claves.cgarant,
               p_in_claves.nmovimi, p_in_claves.cpregun, p_in_claves.ccla1, p_in_claves.ccla2,
               p_in_claves.ccla3, p_in_claves.ccla4;
      ELSIF INSTR(v_consulta, ':CCLA3', 1, 1) > 0 THEN
         OPEN cur FOR v_consulta
         USING p_in_claves.sseguro, p_in_claves.nriesgo, p_in_claves.cgarant,
               p_in_claves.nmovimi, p_in_claves.cpregun, p_in_claves.ccla1, p_in_claves.ccla2,
               p_in_claves.ccla3;
      ELSIF INSTR(v_consulta, ':CCLA2', 1, 1) > 0 THEN
         OPEN cur FOR v_consulta
         USING p_in_claves.sseguro, p_in_claves.nriesgo, p_in_claves.cgarant,
               p_in_claves.nmovimi, p_in_claves.cpregun, p_in_claves.ccla1, p_in_claves.ccla2;
      ELSE
         OPEN cur FOR v_consulta
         USING p_in_claves.sseguro, p_in_claves.nriesgo, p_in_claves.cgarant,
               p_in_claves.nmovimi, p_in_claves.cpregun, p_in_claves.ccla1;
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
   END p_detalle_fila_din_seg;

   PROCEDURE p_detalle_valor_din_seg(
      p_in_claves IN rec_cons_subt_det,
      p_in_cquery IN VARCHAR2,
      p_in_cval IN NUMBER,
      p_in_ptablas IN VARCHAR2,
      p_out_nval OUT NUMBER,
      p_out_error OUT NUMBER) IS
      v_detalle      subtabs_seg_det%ROWTYPE;
      v_error        NUMBER;
      vobject        VARCHAR2(100) := 'pac_subtablas_seg.P_DETALLE_VALOR_DIN_SEG';
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1000);
   BEGIN
      p_detalle_fila_din_seg(p_in_claves, p_in_cquery, p_in_ptablas, v_detalle, v_error);
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
            WHEN 7 THEN
               p_out_nval := v_detalle.nval7;
            WHEN 8 THEN
               p_out_nval := v_detalle.nval8;
            WHEN 9 THEN
               p_out_nval := v_detalle.nval9;
            WHEN 10 THEN
               p_out_nval := v_detalle.nval10;
            ELSE
               p_out_nval := NULL;
         END CASE;
      ELSE
         vpasexec := 40;
         p_out_error := v_error;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         vparam := 'Parametros p_in_claves: sseguro= ' || p_in_claves.sseguro || ' nriesgo= '
                   || p_in_claves.nriesgo || ' cgarant= ' || p_in_claves.cgarant
                   || ' nmovimi= ' || p_in_claves.nmovimi || ' cpregun= '
                   || p_in_claves.cpregun || ' pccla1= ' || p_in_claves.ccla1 || ' pccla2= '
                   || p_in_claves.ccla2 || ' pccla3= ' || p_in_claves.ccla3 || ' pccla4= '
                   || p_in_claves.ccla4 || ' pccla5= ' || p_in_claves.ccla5 || ' pccla6= '
                   || p_in_claves.ccla6 || ' pccla7= ' || p_in_claves.ccla7 || ' pccla8= '
                   || p_in_claves.ccla8 || ' pccla9= ' || p_in_claves.ccla9 || ' pccla10= '
                   || p_in_claves.ccla10 || ' p_in_cquery= ' || p_in_cquery;
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         p_out_error := 1;
   END p_detalle_valor_din_seg;

   FUNCTION f_detalle_valor_din(
      p_in_sseguro IN subtabs_seg_det.sseguro%TYPE,
      p_in_nriesgo IN subtabs_seg_det.nriesgo%TYPE,
      p_in_cgarant IN subtabs_seg_det.cgarant%TYPE,
      p_in_nmovimi IN subtabs_seg_det.nmovimi%TYPE,
      p_in_cpregun IN subtabs_seg_det.cpregun%TYPE,
      p_in_cquery IN VARCHAR2,
      p_in_cval IN NUMBER,
      p_in_ptablas IN VARCHAR2,
      p_in_ccla1 IN subtabs_seg_det.ccla1%TYPE,
      p_in_ccla2 IN subtabs_seg_det.ccla2%TYPE DEFAULT NULL,
      p_in_ccla3 IN subtabs_seg_det.ccla3%TYPE DEFAULT NULL,
      p_in_ccla4 IN subtabs_seg_det.ccla4%TYPE DEFAULT NULL,
      p_in_ccla5 IN subtabs_seg_det.ccla5%TYPE DEFAULT NULL,
      p_in_ccla6 IN subtabs_seg_det.ccla6%TYPE DEFAULT NULL,
      p_in_ccla7 IN subtabs_seg_det.ccla7%TYPE DEFAULT NULL,
      p_in_ccla8 IN subtabs_seg_det.ccla8%TYPE DEFAULT NULL,
      p_in_ccla9 IN subtabs_seg_det.ccla9%TYPE DEFAULT NULL,
      p_in_ccla10 IN subtabs_seg_det.ccla10%TYPE DEFAULT NULL)
      RETURN NUMBER IS
      v_out_nval     NUMBER;
      v_out_error    NUMBER;
      vobject        VARCHAR2(100) := 'pac_subtablas_seg.F_DETALLE_VALOR_DIN';
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1000);
   BEGIN
      p_detalle_valor_din_seg(f_rec_cons_seg(p_in_sseguro, p_in_nriesgo, p_in_cgarant,
                                             p_in_nmovimi, p_in_cpregun, p_in_ccla1,
                                             p_in_ccla2, p_in_ccla3, p_in_ccla4, p_in_ccla5,
                                             p_in_ccla6, p_in_ccla7, p_in_ccla8, p_in_ccla9,
                                             p_in_ccla10),
                              p_in_cquery, p_in_cval, p_in_ptablas, v_out_nval, v_out_error);

      IF v_out_error <> 0 THEN
         v_out_nval := NULL;
      END IF;

      RETURN v_out_nval;
   EXCEPTION
      WHEN OTHERS THEN
         vparam := 'Parametros p_in_claves: psseguro= ' || p_in_sseguro || ' pnriesgo= '
                   || p_in_nriesgo || ' pcgarant= ' || p_in_cgarant || ' pnmovimi= '
                   || p_in_nmovimi || ' pcpregun= ' || p_in_cpregun || ' pccla1= '
                   || p_in_ccla1 || ' pccla2= ' || p_in_ccla2 || ' pccla3= ' || p_in_ccla3
                   || ' pccla4= ' || p_in_ccla4 || ' pccla5= ' || p_in_ccla5 || ' pccla6= '
                   || p_in_ccla6 || ' pccla7= ' || p_in_ccla7 || ' pccla8= ' || p_in_ccla8
                   || ' pccla9= ' || p_in_ccla9 || ' pccla10= ' || p_in_ccla10
                   || ' p_in_cquery= ' || p_in_cquery;
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN NULL;
   END f_detalle_valor_din;

/****************************************************************************
   FUNCTION  f_vsubtabla_seg
   Recupera el valor de una subtabla.
   La empresa la obtiene del usuario.
   La fecha de efecto para obtener la versión de la subtabla se obtiene de los
   parámetros de la sesión
****************************************************************************/
   FUNCTION f_vsubtabla_seg(
      p_in_nsesion IN NUMBER,
      p_in_sseguro IN subtabs_seg_det.sseguro%TYPE,
      p_in_nriesgo IN subtabs_seg_det.nriesgo%TYPE,
      p_in_cgarant IN subtabs_seg_det.cgarant%TYPE,
      p_in_nmovimi IN subtabs_seg_det.nmovimi%TYPE,
      p_in_cpregun IN subtabs_seg_det.cpregun%TYPE,
      p_in_cquery IN VARCHAR2,
      p_in_cval IN NUMBER,
      p_in_ptablas IN VARCHAR2,
      p_in_ccla1 IN subtabs_seg_det.ccla1%TYPE,
      p_in_ccla2 IN subtabs_seg_det.ccla2%TYPE DEFAULT NULL,
      p_in_ccla3 IN subtabs_seg_det.ccla3%TYPE DEFAULT NULL,
      p_in_ccla4 IN subtabs_seg_det.ccla4%TYPE DEFAULT NULL,
      p_in_ccla5 IN subtabs_seg_det.ccla5%TYPE DEFAULT NULL,
      p_in_ccla6 IN subtabs_seg_det.ccla6%TYPE DEFAULT NULL,
      p_in_ccla7 IN subtabs_seg_det.ccla7%TYPE DEFAULT NULL,
      p_in_ccla8 IN subtabs_seg_det.ccla8%TYPE DEFAULT NULL,
      p_in_ccla9 IN subtabs_seg_det.ccla9%TYPE DEFAULT NULL,
      p_in_ccla10 IN subtabs_seg_det.ccla10%TYPE DEFAULT NULL)
      RETURN NUMBER IS
      v_fecha        DATE;
      v_out_nval     NUMBER;
      v_out_error    NUMBER;
      vobject        VARCHAR2(100) := 'pac_subtablas_seg.F_VSUBTABLA_SEG';
      vparam         tab_error.tdescrip%TYPE;
      vpasexec       NUMBER(8) := 1;
   BEGIN
      vpasexec := 3;
      pac_subtablas_seg.p_detalle_valor_din_seg
                                             (pac_subtablas_seg.f_rec_cons_seg(p_in_sseguro,
                                                                               p_in_nriesgo,
                                                                               p_in_cgarant,
                                                                               p_in_nmovimi,
                                                                               p_in_cpregun,
                                                                               p_in_ccla1,
                                                                               p_in_ccla2,
                                                                               p_in_ccla3,
                                                                               p_in_ccla4,
                                                                               p_in_ccla5,
                                                                               p_in_ccla6,
                                                                               p_in_ccla7,
                                                                               p_in_ccla8,
                                                                               p_in_ccla9,
                                                                               p_in_ccla10),
                                              p_in_cquery, p_in_cval, p_in_ptablas,
                                              v_out_nval, v_out_error);

      IF v_out_error <> 0 THEN
         v_out_nval := NULL;
      END IF;

      vpasexec := 5;
      RETURN v_out_nval;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN NULL;
      WHEN OTHERS THEN
         vparam := SUBSTR('p_in_nsesion: ' || p_in_nsesion || ' p_in_sseguro: '
                          || p_in_sseguro || ' p_in_nriesgo: ' || p_in_nriesgo
                          || ' p_in_cgarant: ' || p_in_cgarant || ' p_in_nmovimi: '
                          || p_in_nmovimi || 'p_in_cpregun: ' || p_in_cpregun
                          || 'p_in_cquery: ' || p_in_cquery || 'p_in_cval: ' || p_in_cval
                          || 'p_in_ptablas: ' || p_in_ptablas || 'p_in_ccla1: ' || p_in_ccla1
                          || 'p_in_ccla2: ' || p_in_ccla2 || 'p_in_ccla3: ' || p_in_ccla3
                          || 'p_in_ccla4: ' || p_in_ccla4 || 'p_in_ccla5: ' || p_in_ccla5
                          || 'p_in_ccla5: ' || p_in_ccla5 || 'p_in_ccla7: ' || p_in_ccla7
                          || 'p_in_ccla6: ' || p_in_ccla6 || 'p_in_ccla7: ' || p_in_ccla7
                          || 'p_in_ccla8: ' || p_in_ccla8 || 'p_in_ccla9: ' || p_in_ccla9
                          || 'p_in_ccla10: ' || p_in_ccla10,
                          1, 500);
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN NULL;
   END f_vsubtabla_seg;

      /****************************************************************************
      FUNCTION  f_cero_seg
      Recupera el valor de una subtabla.
      La empresa la obtiene del usuario.
      La fecha de efecto para obtener la versión de la subtabla se obtiene de los
      parámetros de la sesión
   ****************************************************************************/
   FUNCTION f_cero_seg(
      p_in_nsesion IN NUMBER,
      p_in_sseguro IN subtabs_seg_det.sseguro%TYPE,
      p_in_nriesgo IN subtabs_seg_det.nriesgo%TYPE,
      p_in_cgarant IN subtabs_seg_det.cgarant%TYPE,
      p_in_nmovimi IN subtabs_seg_det.nmovimi%TYPE,
      p_in_cpregun IN subtabs_seg_det.cpregun%TYPE,
      p_in_cquery IN VARCHAR2,
      p_in_cval IN NUMBER,
      p_in_ptablas IN VARCHAR2,
      p_in_ccla1 IN subtabs_seg_det.ccla1%TYPE,
      p_in_ccla2 IN subtabs_seg_det.ccla2%TYPE DEFAULT NULL,
      p_in_ccla3 IN subtabs_seg_det.ccla3%TYPE DEFAULT NULL,
      p_in_ccla4 IN subtabs_seg_det.ccla4%TYPE DEFAULT NULL,
      p_in_ccla5 IN subtabs_seg_det.ccla5%TYPE DEFAULT NULL,
      p_in_ccla6 IN subtabs_seg_det.ccla6%TYPE DEFAULT NULL,
      p_in_ccla7 IN subtabs_seg_det.ccla7%TYPE DEFAULT NULL,
      p_in_ccla8 IN subtabs_seg_det.ccla8%TYPE DEFAULT NULL,
      p_in_ccla9 IN subtabs_seg_det.ccla9%TYPE DEFAULT NULL,
      p_in_ccla10 IN subtabs_seg_det.ccla10%TYPE DEFAULT NULL)
      RETURN NUMBER IS
      v_fecha        DATE;
      v_out_nval     NUMBER;
      v_out_error    NUMBER;
      vobject        VARCHAR2(100) := 'pac_subtablas_seg.F_CERO_SEG';
      vparam         tab_error.tdescrip%TYPE;
      vpasexec       NUMBER(8) := 1;
      --BUG 0027923 - INICIO - DCT - 22/10/2013
      v_sseguro_0    seguros.sseguro%TYPE;
      v_nmovimi_0    garanseg.nmovimi%TYPE;
      v_sproduc      seguros.sproduc%TYPE;
      v_cplan        pregunpolseg.crespue%TYPE;
      nerr           NUMBER;
   --BUG 0027923 - FIN - DCT - 22/10/2013
   BEGIN
      IF p_in_nsesion = -1 THEN
         v_fecha := TRUNC(f_sysdate);
      ELSE
         DECLARE
            vnfecha        NUMBER;
         BEGIN
            vpasexec := 2;
            vnfecha := pac_sgt.get(p_in_nsesion, 'FECEFE');
            v_fecha := TO_DATE(vnfecha, 'yyyymmdd');
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               v_fecha := TRUNC(f_sysdate);
         END;
      END IF;

      --BUG 0027923 - INICIO - DCT - 22/10/2013
      -- Obtener el SSEGURO del certificado 0:
      IF p_in_ptablas = 'EST' THEN
         SELECT sseguro
           INTO v_sseguro_0
           FROM seguros
          WHERE npoliza = (SELECT npoliza
                             FROM estseguros
                            WHERE sseguro = p_in_sseguro)
            AND ncertif = 0;
      ELSE
         SELECT sseguro
           INTO v_sseguro_0
           FROM seguros
          WHERE npoliza = (SELECT npoliza
                             FROM seguros
                            WHERE sseguro = p_in_sseguro)
            AND ncertif = 0;
      END IF;

      -- Obtener el nmovimi del certificado 0 a la fecha de llamada.
        -- Se cambia el distinct por el max, puede ser que a la misma fecha enconctremos dos movimiento y peta.
      SELECT MAX(nmovimi)
        INTO v_nmovimi_0
        FROM garanseg
       WHERE sseguro = v_sseguro_0
         AND finiefe <= v_fecha
         AND(ffinefe IS NULL
             OR ffinefe > v_fecha);

      -- Puede pasar cuando la cartula está introducida a fecha efecto futuro como se va a buscar las preguntas tipo tabla por ftarifa del hijo, ya es correcto
      IF v_nmovimi_0 IS NULL THEN
         v_nmovimi_0 := 1;
      END IF;

      v_cplan := 1;

      IF p_in_ptablas = 'EST' THEN
         nerr := pac_preguntas.f_get_pregunpolseg(p_in_sseguro, 4089, 'EST', v_cplan);

         IF nerr = 120135 THEN
            v_cplan := 1;
         END IF;
      ELSE
         nerr := pac_preguntas.f_get_pregunpolseg(p_in_sseguro, 4089, 'POL', v_cplan);

         IF nerr = 120135 THEN
            v_cplan := 1;
         END IF;
      END IF;

      vpasexec := 3;
      pac_subtablas_seg.p_detalle_valor_din_seg
                                              (pac_subtablas_seg.f_rec_cons_seg(v_sseguro_0,
                                                                                v_cplan,
                                                                                p_in_cgarant,
                                                                                v_nmovimi_0,
                                                                                p_in_cpregun,
                                                                                p_in_ccla1,
                                                                                p_in_ccla2,
                                                                                p_in_ccla3,
                                                                                p_in_ccla4,
                                                                                p_in_ccla5,
                                                                                p_in_ccla6,
                                                                                p_in_ccla7,
                                                                                p_in_ccla8,
                                                                                p_in_ccla9,
                                                                                p_in_ccla10),
                                               p_in_cquery, p_in_cval, 'POL', v_out_nval,
                                               v_out_error);

      IF v_out_error <> 0 THEN
         v_out_nval := NULL;
      END IF;

      vpasexec := 5;

      IF v_out_nval IS NULL THEN
         vparam := SUBSTR('p_in_nsesion: ' || p_in_nsesion || ' p_in_sseguro: '
                          || p_in_sseguro || ' p_in_nriesgo: ' || p_in_nriesgo
                          || ' p_in_cgarant: ' || p_in_cgarant || ' p_in_nmovimi: '
                          || p_in_nmovimi || 'p_in_cpregun: ' || p_in_cpregun
                          || 'p_in_cquery: ' || p_in_cquery || 'p_in_cval: ' || p_in_cval
                          || 'p_in_ptablas: ' || p_in_ptablas || 'p_in_ccla1: ' || p_in_ccla1
                          || 'p_in_ccla2: ' || p_in_ccla2 || 'p_in_ccla3: ' || p_in_ccla3
                          || 'p_in_ccla4: ' || p_in_ccla4 || 'p_in_ccla5: ' || p_in_ccla5
                          || 'p_in_ccla5: ' || p_in_ccla5 || 'p_in_ccla7: ' || p_in_ccla7
                          || 'p_in_ccla6: ' || p_in_ccla6 || 'p_in_ccla7: ' || p_in_ccla7
                          || 'p_in_ccla8: ' || p_in_ccla8 || 'p_in_ccla9: ' || p_in_ccla9
                          || 'p_in_ccla10: ' || p_in_ccla10,
                          1, 500);
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, v_out_error);
      END IF;

      RETURN v_out_nval;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN NULL;
      WHEN OTHERS THEN
         vparam := SUBSTR('p_in_nsesion: ' || p_in_nsesion || ' p_in_sseguro: '
                          || p_in_sseguro || ' p_in_nriesgo: ' || p_in_nriesgo
                          || ' p_in_cgarant: ' || p_in_cgarant || ' p_in_nmovimi: '
                          || p_in_nmovimi || 'p_in_cpregun: ' || p_in_cpregun
                          || 'p_in_cquery: ' || p_in_cquery || 'p_in_cval: ' || p_in_cval
                          || 'p_in_ptablas: ' || p_in_ptablas || 'p_in_ccla1: ' || p_in_ccla1
                          || 'p_in_ccla2: ' || p_in_ccla2 || 'p_in_ccla3: ' || p_in_ccla3
                          || 'p_in_ccla4: ' || p_in_ccla4 || 'p_in_ccla5: ' || p_in_ccla5
                          || 'p_in_ccla5: ' || p_in_ccla5 || 'p_in_ccla7: ' || p_in_ccla7
                          || 'p_in_ccla6: ' || p_in_ccla6 || 'p_in_ccla7: ' || p_in_ccla7
                          || 'p_in_ccla8: ' || p_in_ccla8 || 'p_in_ccla9: ' || p_in_ccla9
                          || 'p_in_ccla10: ' || p_in_ccla10,
                          1, 500);
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN NULL;
   END f_cero_seg;

       /****************************************************************************
      FUNCTION  f_ftarifaseg
      Recupera el valor de una subtabla.
      La empresa la obtiene del usuario.
      La fecha de efecto para obtener la versión de la subtabla se obtiene de los
      parámetros de la sesión
   ****************************************************************************/
   FUNCTION f_ftarifaseg(
      p_in_nsesion IN NUMBER,
      p_in_sseguro IN subtabs_seg_det.sseguro%TYPE,
      p_in_nriesgo IN subtabs_seg_det.nriesgo%TYPE,
      p_in_cgarant IN subtabs_seg_det.cgarant%TYPE,
      p_in_nmovimi IN subtabs_seg_det.nmovimi%TYPE,
      p_in_cpregun IN subtabs_seg_det.cpregun%TYPE,
      p_in_cquery IN VARCHAR2,
      p_in_cval IN NUMBER,
      p_in_ptablas IN VARCHAR2,
      p_in_ccla1 IN subtabs_seg_det.ccla1%TYPE,
      p_in_ccla2 IN subtabs_seg_det.ccla2%TYPE DEFAULT NULL,
      p_in_ccla3 IN subtabs_seg_det.ccla3%TYPE DEFAULT NULL,
      p_in_ccla4 IN subtabs_seg_det.ccla4%TYPE DEFAULT NULL,
      p_in_ccla5 IN subtabs_seg_det.ccla5%TYPE DEFAULT NULL,
      p_in_ccla6 IN subtabs_seg_det.ccla6%TYPE DEFAULT NULL,
      p_in_ccla7 IN subtabs_seg_det.ccla7%TYPE DEFAULT NULL,
      p_in_ccla8 IN subtabs_seg_det.ccla8%TYPE DEFAULT NULL,
      p_in_ccla9 IN subtabs_seg_det.ccla9%TYPE DEFAULT NULL,
      p_in_ccla10 IN subtabs_seg_det.ccla10%TYPE DEFAULT NULL)
      RETURN NUMBER IS
      v_fecha        DATE;
      v_out_nval     NUMBER;
      v_out_error    NUMBER;
      vobject        VARCHAR2(100) := 'pac_subtablas_seg.F_FTARIFASEG';
      vparam         tab_error.tdescrip%TYPE;
      vpasexec       NUMBER(8) := 1;
      v_nmovimi      NUMBER;
   BEGIN
      IF p_in_nsesion = -1 THEN
         v_fecha := TRUNC(f_sysdate);
      ELSE
         DECLARE
            vnfecha        NUMBER;
         BEGIN
            vpasexec := 2;
            vnfecha := pac_sgt.get(p_in_nsesion, 'FECEFE');
            v_fecha := TO_DATE(vnfecha, 'yyyymmdd');
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               v_fecha := TRUNC(f_sysdate);
         END;
      END IF;

      -- Obtener el nmovimi del la póliza a la fecha
      BEGIN
         -- Se cambia el distinct por el max, puede ser que a la misma fecha enconctremos dos movimiento y peta.
         SELECT MAX(nmovimi)
           INTO v_nmovimi
           FROM garanseg
          WHERE sseguro = p_in_sseguro
            AND finiefe <= v_fecha
            AND(ffinefe IS NULL
                OR ffinefe > v_fecha);
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            v_nmovimi := p_in_nmovimi;
      END;

      vpasexec := 3;
      pac_subtablas_seg.p_detalle_valor_din_seg
                                              (pac_subtablas_seg.f_rec_cons_seg(p_in_sseguro,
                                                                                p_in_nriesgo,
                                                                                p_in_cgarant,
                                                                                v_nmovimi,
                                                                                p_in_cpregun,
                                                                                p_in_ccla1,
                                                                                p_in_ccla2,
                                                                                p_in_ccla3,
                                                                                p_in_ccla4,
                                                                                p_in_ccla5,
                                                                                p_in_ccla6,
                                                                                p_in_ccla7,
                                                                                p_in_ccla8,
                                                                                p_in_ccla9,
                                                                                p_in_ccla10),
                                               p_in_cquery, p_in_cval, p_in_ptablas,
                                               v_out_nval, v_out_error);

      IF v_out_error <> 0 THEN
         v_out_nval := NULL;
      END IF;

      vpasexec := 5;
      RETURN v_out_nval;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN NULL;
      WHEN OTHERS THEN
         vparam := SUBSTR('p_in_nsesion: ' || p_in_nsesion || ' p_in_sseguro: '
                          || p_in_sseguro || ' p_in_nriesgo: ' || p_in_nriesgo
                          || ' p_in_cgarant: ' || p_in_cgarant || ' p_in_nmovimi: '
                          || p_in_nmovimi || 'p_in_cpregun: ' || p_in_cpregun
                          || 'p_in_cquery: ' || p_in_cquery || 'p_in_cval: ' || p_in_cval
                          || 'p_in_ptablas: ' || p_in_ptablas || 'p_in_ccla1: ' || p_in_ccla1
                          || 'p_in_ccla2: ' || p_in_ccla2 || 'p_in_ccla3: ' || p_in_ccla3
                          || 'p_in_ccla4: ' || p_in_ccla4 || 'p_in_ccla5: ' || p_in_ccla5
                          || 'p_in_ccla5: ' || p_in_ccla5 || 'p_in_ccla7: ' || p_in_ccla7
                          || 'p_in_ccla6: ' || p_in_ccla6 || 'p_in_ccla7: ' || p_in_ccla7
                          || 'p_in_ccla8: ' || p_in_ccla8 || 'p_in_ccla9: ' || p_in_ccla9
                          || 'p_in_ccla10: ' || p_in_ccla10,
                          1, 500);
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN NULL;
   END f_ftarifaseg;
END pac_subtablas_seg;

/

  GRANT EXECUTE ON "AXIS"."PAC_SUBTABLAS_SEG" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_SUBTABLAS_SEG" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_SUBTABLAS_SEG" TO "PROGRAMADORESCSI";
