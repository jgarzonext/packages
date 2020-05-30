--------------------------------------------------------
--  DDL for Package Body PAC_PROCESOS_FICHEROS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_PROCESOS_FICHEROS" IS
   /*************************************************************************
      PROCEDURE p_tip_docum
      Permite obtener el tipo de documento con la codificacion de la
      Superfinanciera.
      param out p_tip_docum      : Tipo de documento que saldra en el fichero
      return                   :
   *************************************************************************/
   PROCEDURE p_tip_docum(p_tip_docum OUT VARCHAR2) IS
      --
      l_tip_docum    VARCHAR2(10);
   --
   BEGIN
      --
      l_tip_docum := pac_globales.f_obtiene_global('PRE_TIP_DOCUMEN');

      --
      IF (l_tip_docum = '1') THEN
         --
         p_tip_docum := 0;
      --
      ELSIF(l_tip_docum = 8) THEN
         --
         p_tip_docum := 9;
      --
      END IF;
   END p_tip_docum;

   /*************************************************************************
      PROCEDURE p_obtiene_signo
      Permite obtener el signo de los valores numericos que se procesen
      param out p_signo      : Signo + o -, dependiendo del valor que
                               se este procesando
      return                 :
   *************************************************************************/
   PROCEDURE p_obtiene_signo(p_signo OUT VARCHAR2) IS
      v_valor        VARCHAR2(100);
      v_valorn       NUMBER;
      v_signo        VARCHAR2(1);
   BEGIN
      v_valor := pac_globales.f_obtiene_global('PRE_SIGNO');

      IF (NVL(v_valor, 'X') = 'X') THEN
         v_signo := '+';
      ELSE
         BEGIN
            v_valorn := TO_NUMBER(v_valor);

            IF (v_valorn >= 0) THEN
               v_signo := '+';
            ELSE
               v_signo := '-';
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               v_signo := '+';
         END;
      END IF;

      p_signo := v_signo;
   END p_obtiene_signo;

   /*************************************************************************
      PROCEDURE p_obtiene_valor
      Permite obtener el valor que saldra en el fichero, cuando es numerico
      se obtiene el valor absoluto y se formatea con una longitud de 17 y
      rellenado con ceros; si es texto, se formatea con longitud de 50 y
      rellenado con espacios.
      param out p_valor      : valor formateado que sale en el fichero
      return                   :
   *************************************************************************/
   PROCEDURE p_obtiene_valor(p_valor OUT VARCHAR2) IS
      v_valor        VARCHAR2(100);
      v_valorn       NUMBER;
      v_valorf       DATE;
      flag_texto     EXCEPTION;
   BEGIN
      v_valor := pac_globales.f_obtiene_global('PRE_VALOR');

      IF (NVL(v_valor, 'X') = 'X') THEN
         v_valor := RPAD(v_valor, 50, ' ');
      ELSE
         BEGIN   --valida si es numerico
            IF SUBSTR(v_valor, LENGTH(v_valor) - 1, LENGTH(v_valor)) = '  ' THEN
               RAISE flag_texto;
            END IF;

            v_valorn := TO_NUMBER(REPLACE(v_valor, '.', ','));
            v_valor := LPAD(TO_CHAR(ABS(REPLACE(v_valor, '.', ',')), 'FM99999999999999.00'),
                            17, '0');
         EXCEPTION
            WHEN OTHERS THEN
               BEGIN   --valida si es fecha
                  v_valorf := TO_DATE(v_valor);
                  v_valor := LPAD(TO_CHAR(v_valorf, 'ddmmyyyy'), 17, '0');
               EXCEPTION
                  WHEN OTHERS THEN
                     v_valor := RPAD(v_valor, 50, ' ');
               END;
         END;
      END IF;

      p_valor := v_valor;
      pac_globales.p_asigna_global('excluye_formato_columna', 'S');
   END p_obtiene_valor;

   /*************************************************************************
      PROCEDURE p_obtiene_valor
      Permite obtener el valor que saldra en el fichero, cuando es numerico
      se obtiene el valor absoluto y se formatea con una longitud de 17 y
      rellenado con ceros; si es texto, se formatea con longitud de 50 y
      rellenado con espacios.
      param out p_valor      : valor formateado que sale en el fichero
      return                   :
   *************************************************************************/
   PROCEDURE p_obtiene_valor_x_tipo(p_valor OUT VARCHAR2) IS
      v_valor        VARCHAR2(100);
      v_tipo         VARCHAR2(100);
      v_valorn       NUMBER;
      v_valorf       DATE;
      flag_texto     EXCEPTION;
   BEGIN
      v_valor := pac_globales.f_obtiene_global('PRE_VALOR');
      v_tipo := pac_globales.f_obtiene_global('PRE_TIPO');
      p_control_error('funcion plano', 'test', v_tipo);

      IF (NVL(v_valor, 'X') = 'X') THEN
         v_valor := RPAD(v_valor, 50, ' ');
      ELSE
         BEGIN
            IF v_tipo = 'N' THEN
               v_valorn := TO_NUMBER(REPLACE(v_valor, '.', ','));
               v_valor := LPAD(TO_CHAR(ABS(REPLACE(v_valor, '.', ',')), 'FM99999999999999.00'),
                               17, '0');
            ELSIF v_tipo = 'F' THEN
               v_valorf := TO_DATE(v_valor);
               v_valor := LPAD(TO_CHAR(v_valorf, 'ddmmyyyy'), 17, '0');
            ELSIF v_tipo = 'C' THEN
               v_valor := RPAD(v_valor, 50, ' ');
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               BEGIN   --valida si es numerico
                  IF SUBSTR(v_valor, LENGTH(v_valor) - 1, LENGTH(v_valor)) = '  ' THEN
                     RAISE flag_texto;
                  END IF;

                  v_valorn := TO_NUMBER(REPLACE(v_valor, '.', ','));
                  v_valor := LPAD(TO_CHAR(ABS(REPLACE(v_valor, '.', ',')),
                                          'FM99999999999999.00'),
                                  17, '0');
               EXCEPTION
                  WHEN OTHERS THEN
                     BEGIN   --valida si es fecha
                        v_valorf := TO_DATE(v_valor);
                        v_valor := LPAD(TO_CHAR(v_valorf, 'ddmmyyyy'), 17, '0');
                     EXCEPTION
                        WHEN OTHERS THEN
                           v_valor := RPAD(v_valor, 50, ' ');
                     END;
               END;
         END;
      END IF;

      p_valor := v_valor;
      pac_globales.p_asigna_global('excluye_formato_columna', 'S');
   END p_obtiene_valor_x_tipo;

   /*************************************************************************
       PROCEDURE p_obtiene_valor003
       Permite obtener el valor que saldra en el fichero, cuando es numerico
       se obtiene el valor absoluto y se formatea con una longitud de 20 y
       rellenado con ceros; si es texto, se formatea con longitud de 20 y
       rellenado con espacios.
       param out p_valor      : valor formateado que sale en el fichero
       return                   :
    *************************************************************************/
   PROCEDURE p_obtiene_valor003(p_valor OUT VARCHAR2) IS
      v_valor        VARCHAR2(100);
      v_valorn       NUMBER;
      v_valorf       DATE;
   BEGIN
      v_valor := pac_globales.f_obtiene_global('PRE_VALOR');

      IF (NVL(v_valor, 'X') = 'X') THEN
         v_valor := RPAD(v_valor, 20, ' ');
      ELSE
         BEGIN   --valida si es numerico
            v_valorn := TO_NUMBER(v_valor);
            v_valor := REPLACE(LPAD(ABS(TO_NUMBER(v_valor)), 20, '0'), ',', '.');
         EXCEPTION
            WHEN OTHERS THEN
               BEGIN   --valida si es fecha
                  v_valorf := TO_DATE(v_valor);
                  v_valor := LPAD(TO_CHAR(v_valorf, 'ddmmyyyy'), 20, '0');
               EXCEPTION
                  WHEN OTHERS THEN
                     v_valor := RPAD(v_valor, 20, ' ');
               END;
         END;
      END IF;

      p_valor := v_valor;
      pac_globales.p_asigna_global('excluye_formato_columna', 'S');
   END p_obtiene_valor003;

/*************************************************************************
      PROCEDURE p_obtiene_orden_ben
      Permite obtener el orden de los beneficiarios segun su importancia segun su posible permanencia en la renta
      param in p_sseguro      : sequencia del seguro
      param in p_sproduc      : sequencia del producto
      param in p_nriesgo      : numero de riesgo
      param in p_nmovimi      : numero de movimiento
      param in p_ffin         : fecha fin
      param in p_numben       : numero del beneficiario a segun prioridad
      return  sequencia de la persona seun la prioridad solicitada                 :
   *************************************************************************/
   FUNCTION f_obtiene_orden_ben(
      p_sseguro NUMBER,
      p_sproduc NUMBER,
      p_nriesgo NUMBER,
      p_nmovimi NUMBER,
      p_ffin DATE,
      p_numben NUMBER)
      RETURN NUMBER IS
      v_sperson      NUMBER;
   BEGIN
      SELECT persona
        INTO v_sperson
        FROM (SELECT persona, edad, ROW_NUMBER() OVER(ORDER BY edad DESC) prioridad
                FROM (SELECT b2.cparen, b2.sperson persona,
                             CASE
                                WHEN b2.cparen = 9
                                AND b2.cestado = 1 THEN(CEIL((25 * 12)
                                                             - MONTHS_BETWEEN(p_ffin,
                                                                              pe2.fnacimi)))
                                WHEN b2.cparen IN(29, 31, 5)
                                AND(CEIL((30 * 12) - MONTHS_BETWEEN(p_ffin, pe2.fnacimi))) > 0 THEN(CASE (SELECT pre.crespue
                                                                                                            FROM pregunseg pre
                                                                                                           WHERE p_sseguro =
                                                                                                                    pre.sseguro
                                                                                                             AND pre.cpregun =
                                                                                                                   201
                                                                                                             AND p_sproduc IN
                                                                                                                   (7001,
                                                                                                                    7004)
                                                                                                             AND pre.nmovimi =
                                                                                                                   (SELECT MAX
                                                                                                                              (preg.nmovimi)
                                                                                                                      FROM pregunseg preg INNER JOIN movseguro movs
                                                                                                                           ON preg.sseguro =
                                                                                                                                movs.sseguro
                                                                                                                     WHERE movs.sseguro =
                                                                                                                              p_sseguro
                                                                                                                       AND pre.cpregun =
                                                                                                                             201
                                                                                                                       AND p_sproduc IN
                                                                                                                             (7001,
                                                                                                                              7004)
                                                                                                                       AND movs.fmovimi <=
                                                                                                                             p_ffin))
                                                                                                       WHEN 3 THEN CEIL
                                                                                                                     (MONTHS_BETWEEN
                                                                                                                         (p_ffin,
                                                                                                                          ADD_MONTHS
                                                                                                                             (TO_DATE
                                                                                                                                 ((SELECT pre.crespue
                                                                                                                                     FROM pregunseg pre
                                                                                                                                    WHERE p_sseguro =
                                                                                                                                             pre.sseguro
                                                                                                                                      AND pre.cpregun =
                                                                                                                                            626
                                                                                                                                      AND p_sproduc IN
                                                                                                                                            (7001,
                                                                                                                                             7004)
                                                                                                                                      AND pre.nmovimi =
                                                                                                                                            (SELECT MAX
                                                                                                                                                       (preg.nmovimi)
                                                                                                                                               FROM pregunseg preg INNER JOIN movseguro movs
                                                                                                                                                    ON preg.sseguro =
                                                                                                                                                         movs.sseguro
                                                                                                                                              WHERE movs.sseguro =
                                                                                                                                                       p_sseguro
                                                                                                                                                AND pre.cpregun =
                                                                                                                                                      626
                                                                                                                                                AND p_sproduc IN
                                                                                                                                                      (7001,
                                                                                                                                                       7004)
                                                                                                                                                AND movs.fmovimi <=
                                                                                                                                                      p_ffin)),
                                                                                                                                  'ddmmyyyy'),
                                                                                                                              20
                                                                                                                              * 12)))
                                                                                                    END)
                                ELSE(CEIL((110 * 12) - MONTHS_BETWEEN(p_ffin, pe2.fnacimi)))
                             END edad
                        FROM benespseg b2, per_personas pe2
                       WHERE b2.sperson = pe2.sperson
                         AND b2.sseguro = p_sseguro
                         AND b2.cgarant = 0
                         AND b2.cestado <> 3
                         AND b2.ctipben <> 3
                         AND b2.nriesgo = p_nriesgo
                         AND b2.nmovimi = (SELECT MAX(preg.nmovimi)
                                             FROM benespseg preg INNER JOIN movseguro movs
                                                  ON preg.sseguro = movs.sseguro
                                            WHERE movs.sseguro = p_sseguro
                                              AND movs.fefecto <= p_ffin)
                         AND b2.sperson NOT IN(SELECT b3.sperson
                                                 FROM benespseg b3, per_personas pe3
                                                WHERE b3.sperson = pe3.sperson
                                                  AND b3.sseguro = p_sseguro
                                                  AND b3.cgarant = 0
                                                  AND b3.ctipben <> 3
                                                  AND b2.cestado <> 3
                                                  AND b3.nriesgo = p_nriesgo
                                                  AND b3.nmovimi =
                                                        (SELECT MAX(preg.nmovimi)
                                                           FROM benespseg preg INNER JOIN movseguro movs
                                                                ON preg.sseguro = movs.sseguro
                                                          WHERE movs.sseguro = p_sseguro
                                                            AND movs.fefecto <= p_ffin)
                                                  AND(CEIL((25 * 12)
                                                           - MONTHS_BETWEEN(p_ffin,
                                                                            pe2.fnacimi))) <= 0
                                                  AND b3.cparen = 9)))
       WHERE prioridad = p_numben;

      RETURN v_sperson;
   END f_obtiene_orden_ben;

   FUNCTION f_obtiene_numero_meses(p_nmesextra IN VARCHAR, p_imesextra IN VARCHAR)
      RETURN NUMBER IS
      v_nmes         NUMBER;
   BEGIN
      SELECT COUNT(*)
        INTO v_nmes
        FROM (SELECT     REGEXP_SUBSTR
                            (REPLACE(NVL(p_nmesextra, '||||||||||||'), '|', ' |'),   --voltea las filas para que sean columnas
                             '[^|]+', 1, LEVEL) AS columna,
                         REGEXP_SUBSTR
                            (REPLACE(p_imesextra, '|', ' |'),   --voltea las filas para que sean columnas
                             '[^|]+', 1, LEVEL) AS columna2
                    FROM DUAL
              CONNECT BY REGEXP_SUBSTR(REPLACE(NVL(p_nmesextra, '||||||||||||'), '|', ' |'),
                                       '[^|]+', 1, LEVEL) IS NOT NULL)
       WHERE (columna2 <> ' '
              AND columna = ' ');

      RETURN v_nmes;
   END f_obtiene_numero_meses;

    /*************************************************************************
      PROCEDURE f_obtiene_numero_hijos
      Obtienen el numero de hijos validos o invalidos segun el orden de los beneficiarios segun su importancia segun su posible permanencia en la renta
      param in p_sseguro      : sequencia del seguro
      param in p_sproduc      : sequencia del producto
      param in p_nriesgo      : numero de riesgo
      param in p_nmovimi      : numero de movimiento
      param in p_ffin         : fecha fin
      param in p_valido       : 1 hijos validos, 2 hijos invalidos
      return  numero de hijos segun la prioridad solicitada                 :
   *************************************************************************/
   FUNCTION f_obtiene_numero_hijos(
      p_sseguro NUMBER,
      p_sproduc NUMBER,
      p_nriesgo NUMBER,
      p_nmovimi NUMBER,
      p_ffin DATE,
      p_valido NUMBER)
      RETURN NUMBER IS
      v_sperson      NUMBER;
   BEGIN
      SELECT COUNT(1)
        INTO v_sperson
        FROM (SELECT persona, edad, paren, tipoben, estado,
                     ROW_NUMBER() OVER(ORDER BY edad DESC) prioridad
                FROM (SELECT b2.cparen paren, b2.ctipben tipoben, b2.cestado estado, b2.cparen,
                             b2.sperson persona,
                             CASE
                                WHEN b2.cparen = 9 THEN(CEIL((25 * 12)
                                                             - MONTHS_BETWEEN(p_ffin,
                                                                              pe2.fnacimi)))
                                WHEN b2.cparen IN(29, 31, 5)
                                AND(CEIL((30 * 12) - MONTHS_BETWEEN(p_ffin, pe2.fnacimi))) > 0 THEN(CASE (SELECT pre.crespue
                                                                                                            FROM pregunseg pre
                                                                                                           WHERE p_sseguro =
                                                                                                                    pre.sseguro
                                                                                                             AND pre.cpregun =
                                                                                                                   201
                                                                                                             AND p_sproduc IN
                                                                                                                   (7001,
                                                                                                                    7004)
                                                                                                             AND pre.nmovimi =
                                                                                                                   (SELECT MAX
                                                                                                                              (preg.nmovimi)
                                                                                                                      FROM pregunseg preg INNER JOIN movseguro movs
                                                                                                                           ON preg.sseguro =
                                                                                                                                movs.sseguro
                                                                                                                     WHERE movs.sseguro =
                                                                                                                              p_sseguro
                                                                                                                       AND pre.cpregun =
                                                                                                                             201
                                                                                                                       AND p_sproduc IN
                                                                                                                             (7001,
                                                                                                                              7004)
                                                                                                                       AND movs.fmovimi <=
                                                                                                                             p_ffin))
                                                                                                       WHEN 3 THEN CEIL
                                                                                                                     (MONTHS_BETWEEN
                                                                                                                         (p_ffin,
                                                                                                                          ADD_MONTHS
                                                                                                                             (TO_DATE
                                                                                                                                 ((SELECT pre.crespue
                                                                                                                                     FROM pregunseg pre
                                                                                                                                    WHERE p_sseguro =
                                                                                                                                             pre.sseguro
                                                                                                                                      AND pre.cpregun =
                                                                                                                                            626
                                                                                                                                      AND p_sproduc IN
                                                                                                                                            (7001,
                                                                                                                                             7004)
                                                                                                                                      AND pre.nmovimi =
                                                                                                                                            (SELECT MAX
                                                                                                                                                       (preg.nmovimi)
                                                                                                                                               FROM pregunseg preg INNER JOIN movseguro movs
                                                                                                                                                    ON preg.sseguro =
                                                                                                                                                         movs.sseguro
                                                                                                                                              WHERE movs.sseguro =
                                                                                                                                                       p_sseguro
                                                                                                                                                AND pre.cpregun =
                                                                                                                                                      626
                                                                                                                                                AND p_sproduc IN
                                                                                                                                                      (7001,
                                                                                                                                                       7004)
                                                                                                                                                AND movs.fmovimi <=
                                                                                                                                                      p_ffin)),
                                                                                                                                  'ddmmyyyy'),
                                                                                                                              20
                                                                                                                              * 12)))
                                                                                                    END)
                                ELSE(CEIL((110 * 12) - MONTHS_BETWEEN(p_ffin, pe2.fnacimi)))
                             END edad
                        FROM benespseg b2, per_personas pe2
                       WHERE b2.sperson = pe2.sperson
                         AND b2.sseguro = p_sseguro
                         AND b2.cgarant = 0
                         AND b2.cestado <> 3
                         AND b2.ctipben <> 3
                         AND b2.nriesgo = p_nriesgo
                         AND b2.nmovimi = (SELECT MAX(preg.nmovimi)
                                             FROM benespseg preg INNER JOIN movseguro movs
                                                  ON preg.sseguro = movs.sseguro
                                            WHERE movs.sseguro = p_sseguro
                                              AND movs.fefecto <= p_ffin)
                         AND b2.sperson NOT IN(SELECT b3.sperson
                                                 FROM benespseg b3, per_personas pe3
                                                WHERE b3.sperson = pe3.sperson
                                                  AND b3.sseguro = p_sseguro
                                                  AND b3.cgarant = 0
                                                  AND b2.cestado <> 3
                                                  AND b3.ctipben <> 3
                                                  AND b3.nriesgo = p_nriesgo
                                                  AND b3.nmovimi =
                                                        (SELECT MAX(preg.nmovimi)
                                                           FROM benespseg preg INNER JOIN movseguro movs
                                                                ON preg.sseguro = movs.sseguro
                                                          WHERE movs.sseguro = p_sseguro
                                                            AND movs.fefecto <= p_ffin)
                                                  AND(CEIL((25 * 12)
                                                           - MONTHS_BETWEEN(p_ffin,
                                                                            pe2.fnacimi))) <= 0
                                                  AND b3.cparen = 9)))
       WHERE prioridad <= 3
         AND tipoben IN(1, 2)
         AND estado IN(2, DECODE(p_valido, 1, 1, -1))
         AND paren = 9;

      RETURN v_sperson;
   END f_obtiene_numero_hijos;
END pac_procesos_ficheros;

/

  GRANT EXECUTE ON "AXIS"."PAC_PROCESOS_FICHEROS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_PROCESOS_FICHEROS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_PROCESOS_FICHEROS" TO "PROGRAMADORESCSI";
