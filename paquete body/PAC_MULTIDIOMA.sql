--------------------------------------------------------
--  DDL for Package Body PAC_MULTIDIOMA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MULTIDIOMA" IS
   /******************************************************************************
      NOMBRE:    PAC_MULTIDIOMA
      PROPÓSITO: Funciones para idiomas

      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.0        13/09/2010  DRA              1. 0014712: ENSA101- Certificat de pertanyença
                 27/01/2016  IPH                  39732  :Poder generar número decimales (si el número no tiene parte entera
                                                          :COnectivos '"E' en portugues en todos los números

   ******************************************************************************/
   FUNCTION f_numlet(
      nidioma IN NUMBER,   -- El texto retornado dependerá del idioma.
      np_nume IN NUMBER,   -- Número que se quiere traducir.
      moneda IN VARCHAR2,   -- Sería conveniente leer de tabla datos referentes a la moneda (decimales, etc.)
      ctexto IN OUT VARCHAR2)
      RETURN NUMBER IS
      cnumero        VARCHAR2(12);
      nlongitud      NUMBER := 0;
      contador       NUMBER := 0;   -- contador para bucles.
      contador_n     NUMBER := 0;   -- contador para las cifras del número.
      termasc        VARCHAR2(3);   -- terminación de palabra masculina.
      termfem        VARCHAR2(3);   -- terminación de palabra femenina.
      num_sep        VARCHAR2(3);   -- separador.
      num_masc       VARCHAR2(5);
      num_fem        VARCHAR2(5);
      num_decimal    NUMBER;   -- número de decimales dependiendo de moneda.
      num_cero       VARCHAR2(15);   -- número cero.
      num_millon     VARCHAR2(15);
      num_millones   VARCHAR2(15);
      numero1        NUMBER;   -- primera cifra.
      numero2        NUMBER;   -- segunda cifra.
      numero3        NUMBER;   -- tercera cifra.
      osas           VARCHAR2(2);   -- terminación plural.
      tipo           VARCHAR2(15);
      ini            NUMBER;
      numero_char    VARCHAR2(20);
      decimales_char VARCHAR2(2);
      salir          EXCEPTION;

      -- CURSOR QUE LEE DE LA TABLA NUMEROS LAS DESCRIPCIONES DE LAS UNIDADES.
      CURSOR unidades_c IS
         SELECT   tdescri
             FROM numeros
            WHERE cidioma = nidioma
              AND cnumero BETWEEN 1 AND 9
         ORDER BY cnumero;

      -- Pseudotabla que sirve como si fuera un vector, aunque más potente (no tiene límites).
      TYPE unidadestyp IS TABLE OF unidades_c%ROWTYPE
         INDEX BY BINARY_INTEGER;

      unidad         unidadestyp;

      -- CURSOR QUE LEE DE LA TABLA NUMEROS LAS DESCRIPCIONES DE LOS NUMEROS 11-19.
      CURSOR num_dec_c IS
         SELECT   tdescri
             FROM numeros
            WHERE cidioma = nidioma
              AND cnumero BETWEEN 11 AND 19
         ORDER BY cnumero;

      -- Pseudotabla que sirve como si fuera un vector, aunque más potente (no tiene límites).
      TYPE num_dectyp IS TABLE OF num_dec_c%ROWTYPE
         INDEX BY BINARY_INTEGER;

      num_dec        num_dectyp;

      -- CURSOR QUE LEE DE LA TABLA NUMEROS LAS DESCRIPCIONES DE LAS DECENAS.
      CURSOR decenas_c IS
         SELECT   tdescri
             FROM numeros
            WHERE cidioma = nidioma
              AND((cnumero BETWEEN 20 AND 90)
                  OR cnumero = 10)
         ORDER BY cnumero;

      -- Pseudotabla que sirve como si fuera un vector, aunque más potente (no tiene límites).
      TYPE decenastyp IS TABLE OF decenas_c%ROWTYPE
         INDEX BY BINARY_INTEGER;

      decena         decenastyp;

      -- CURSOR QUE LEE DE LA TABLA NUMEROS.
      CURSOR centenas_c IS
         SELECT   tdescri
             FROM numeros
            WHERE cidioma = nidioma
              AND cnumero BETWEEN 100 AND 1000
         ORDER BY cnumero;

      -- Pseudotabla que sirve como si fuera un vector, aunque más potente (no tiene límites).
      TYPE centenastyp IS TABLE OF centenas_c%ROWTYPE
         INDEX BY BINARY_INTEGER;

      centena        centenastyp;

      -- CURSOR QUE LEE DE LA TABLA NUMEROS.
      CURSOR numeros_c IS
         SELECT cnumero
           FROM numeros
          WHERE cidioma = nidioma
            AND ROWNUM = 12;

      -- Pseudotabla que sirve como si fuera un vector, aunque más potente (no tiene límites).
      TYPE numerostyp IS TABLE OF numeros_c%ROWTYPE
         INDEX BY BINARY_INTEGER;

      numero         numerostyp;

      PROCEDURE centenas IS
      BEGIN
         IF numero1 = 1 THEN
            IF numero2 = 0
               AND numero3 = 0 THEN
               ctexto := ctexto || centena(numero1).tdescri || ' ';
            ELSIF nidioma = 2 THEN
               ctexto := ctexto || centena(numero1).tdescri || 'TO ';
            -- BUG14712:DRA:14/06/2010:Inici
            ELSIF nidioma = 4 THEN
               ctexto := ctexto || centena(numero1).tdescri || 'TO E ';
            -- BUG14712:DRA:14/06/2010:Fi
            ELSE
               ctexto := ctexto || centena(numero1).tdescri || ' ';
            END IF;
         ELSIF numero1 = 2
               AND nidioma = 1
               AND contador > 6
               AND osas = 'ES' THEN
            ctexto := ctexto || 'DUES-CENT' || osas || ' ';
         ELSE
            IF nidioma = 4 THEN
               ctexto := ctexto || ' ' || centena(numero1).tdescri || ' E' || ' ';
            ELSE
               ctexto := ctexto || ' ' || centena(numero1).tdescri || osas || ' ';
            END IF;
         END IF;

         IF numero2 = 0
            AND numero3 = 0 THEN
            ctexto := ctexto || ' ' || tipo;

            IF contador = 1
               AND NVL(numero(4).cnumero, 0) = 0
               AND NVL(numero(5).cnumero, 0) = 0
               AND NVL(numero(6).cnumero, 0) = 0 THEN
               ctexto := ctexto || num_millones || ' ';
            END IF;
         END IF;
      END centenas;

      PROCEDURE decenas IS
      BEGIN
         IF numero3 = 0 THEN
            ctexto := ctexto || decena(numero2).tdescri || ' ';
         ELSE
            IF numero2 = 1 THEN
               ctexto := ctexto || num_dec(numero3).tdescri || ' ';
            ELSIF numero2 = 2 THEN
               IF nidioma = 2 THEN
                  ctexto := ctexto || 'VEINTI' || unidad(numero3).tdescri || ' ';
               ELSIF nidioma = 1 THEN
                  ctexto := ctexto || decena(numero2).tdescri || '-I-'
                            || unidad(numero3).tdescri || ' ';
               -- BUG14712:DRA:14/06/2010:Inici
               ELSIF nidioma = 4 THEN
                  ctexto := ctexto || decena(numero2).tdescri || ' E '
                            || unidad(numero3).tdescri || ' ';
               -- BUG14712:DRA:14/06/2010:Fi
               ELSE
                  IF nidioma = 4 THEN
                     ctexto := ctexto || decena(numero2).tdescri || NVL(num_sep, ' E ')
                               || unidad(numero3).tdescri || ' ';
                  ELSE
                     ctexto := ctexto || decena(numero2).tdescri || NVL(num_sep, '-')
                               || unidad(numero3).tdescri || ' ';
                  END IF;
               END IF;
            ELSE
               IF nidioma = 4 THEN
                  ctexto := ctexto || decena(numero2).tdescri || NVL(num_sep, ' E ')
                            || unidad(numero3).tdescri || ' ';
               ELSE
                  ctexto := ctexto || decena(numero2).tdescri || NVL(num_sep, '-')
                            || unidad(numero3).tdescri || ' ';
               END IF;
            END IF;
         END IF;

         IF tipo IS NOT NULL THEN
            ctexto := ctexto || tipo;
         END IF;

         IF contador = 1
            AND NVL(numero(4).cnumero, 0) = 0
            AND NVL(numero(5).cnumero, 0) = 0
            AND NVL(numero(6).cnumero, 0) = 0 THEN
            ctexto := ctexto || num_millones || ' ';
         END IF;
      END decenas;

      PROCEDURE unidades IS
      BEGIN
         IF numero3 = 1 THEN
            IF contador = 1 THEN
               IF numero2 IS NULL THEN
                  ctexto := ctexto || centena(10).tdescri || ' ';
               ELSE
                  ctexto := ctexto || num_masc || ' ' || centena(10).tdescri || ' ';
               END IF;
            ELSIF contador = 4 THEN
               IF numero2 IS NULL THEN
                  IF nidioma = 4 THEN
                     ctexto := ctexto || num_millon || ' E ';
                  ELSE
                     ctexto := ctexto || num_masc || ' ' || num_millon || ' ';
                  END IF;
               ELSE
                  IF nidioma = 4 THEN
                     ctexto := ctexto || num_masc || ' ' || num_millones || ' E ';
                  ELSE
                     ctexto := ctexto || num_masc || ' ' || num_millones || ' ';
                  END IF;
               END IF;
            ELSIF contador = 7 THEN
               IF numero2 IS NULL
                  OR numero1 = 0 THEN
                  ctexto := ctexto || centena(10).tdescri || ' ';
               ELSE
                  ctexto := ctexto || num_fem || ' ' || centena(10).tdescri || ' ';
               END IF;
            ELSE
               ctexto := ctexto || num_fem || ' ';
            END IF;
         ELSE
            ctexto := ctexto || ' ' || unidad(numero3).tdescri || ' ' || tipo;
         END IF;

         IF contador = 1
            AND NVL(numero(4).cnumero, 0) = 0
            AND NVL(numero(5).cnumero, 0) = 0
            AND NVL(numero(6).cnumero, 0) = 0 THEN
            ctexto := ctexto || num_millones || ' ';
         END IF;
      END unidades;

      PROCEDURE validar_numero IS
      BEGIN
         --  numero_char := REPLACE(TO_CHAR(np_nume), '.', ',');
         --IPH 27/01/2016 modificación para poder generar texto de números dscimales ya que solo se
         --podía generar enteros con decimales.
         numero_char := LPAD(REPLACE(TO_CHAR(np_nume), '.', ','), LENGTH(np_nume) + 1, '0');
         ini := 1;

         WHILE ini < LENGTH(numero_char) LOOP
            ini := ini + 1;
            EXIT WHEN SUBSTR(numero_char, ini, 1) = ',';
         END LOOP;

         IF SUBSTR(numero_char, ini, 1) = ',' THEN
            decimales_char := SUBSTR(numero_char, ini + 1, num_decimal);
            cnumero := TO_NUMBER(SUBSTR(numero_char, 1, ini - 1));
         END IF;
      END validar_numero;
-----------------------------------
-------- PROGRAMA PRINCIPAL -------
-----------------------------------
   BEGIN
      -- Inicialitzem la cadena que retornarem per no concatenar-la amb possibles valors anteriors
      ctexto := NULL;

      -- Lectura de datos de la tabla MONEDAS.
      BEGIN
         SELECT ctermas, cterfem, cnumsep, cnummas, cnumfem, ndecima
           INTO termasc, termfem, num_sep, num_masc, num_fem, num_decimal
           FROM monedas
          WHERE cidioma = nidioma
            AND cmoneda = moneda;
      EXCEPTION
         WHEN OTHERS THEN
            -- EL MENSAJE DEBERÍA HACERSE CON LITERALES. DE MOMENTO HECHO PARA PRUEBAS.
            NULL;
      END;

      -- Validar el número.
      validar_numero;

      BEGIN
         SELECT tdescri, tdescpl
           INTO num_millon, num_millones
           FROM numeros
          WHERE cidioma = nidioma
            AND cnumero = 1000000;
      EXCEPTION
         WHEN OTHERS THEN
            -- EL MENSAJE DEBERÍA HACERSE CON LITERALES. DE MOMENTO HECHO PARA PRUEBAS.
            NULL;
      END;

      BEGIN
         SELECT tdescri
           INTO num_cero
           FROM numeros
          WHERE cidioma = nidioma
            AND cnumero = 0;
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      contador := 1;

      OPEN centenas_c;

      FETCH centenas_c
       INTO centena(contador);

      WHILE contador < 10 LOOP
         contador := contador + 1;

         FETCH centenas_c
          INTO centena(contador);
      END LOOP;

      CLOSE centenas_c;

      contador := 1;

      OPEN decenas_c;

      FETCH decenas_c
       INTO decena(contador);

      WHILE contador < 9 LOOP
         contador := contador + 1;

         FETCH decenas_c
          INTO decena(contador);
      END LOOP;

      CLOSE decenas_c;

      contador := 1;

      OPEN num_dec_c;

      FETCH num_dec_c
       INTO num_dec(contador);

      WHILE contador < 9 LOOP
         contador := contador + 1;

         FETCH num_dec_c
          INTO num_dec(contador);
      END LOOP;

      CLOSE num_dec_c;

      contador := 1;

      OPEN unidades_c;

      FETCH unidades_c
       INTO unidad(contador);

      WHILE contador < 9 LOOP
         contador := contador + 1;

         FETCH unidades_c
          INTO unidad(contador);
      END LOOP;

      CLOSE unidades_c;

      IF np_nume IS NULL
         OR np_nume < 0
         OR np_nume > 999999999999 THEN
         ctexto := NULL;
         RAISE salir;
      END IF;

      IF np_nume = 0 THEN
         ctexto := num_cero;
      END IF;

      IF cnumero IS NULL THEN
         cnumero := TO_CHAR(np_nume);
      END IF;

      nlongitud := LENGTH(cnumero);

      FOR i IN 1 ..(12 - nlongitud) LOOP
         numero(i).cnumero := NULL;
      END LOOP;

      contador := 0;

      FOR i IN(13 - nlongitud) .. 12 LOOP
         contador_n := contador_n + 1;
         numero(i).cnumero := SUBSTR(cnumero, contador_n, 1);
      END LOOP;

      -- PROCESO QUE TRATA GRUPOS DE 3 DÍGITOS.
      FOR i IN 1 .. 12 LOOP   -- INCREMENTAR DE 3 EN 3.
         IF i IN(1, 4, 7, 10) THEN
            IF i < 7 THEN
               osas := termasc;
               unidad(1).tdescri := num_masc;   --
            ELSE
               osas := termfem;
               unidad(1).tdescri := num_fem;   --
            END IF;

            IF i = 1
               OR i = 7 THEN
               tipo := centena(10).tdescri;
            ELSE
               IF i = 4 THEN
                  IF nidioma = 4 THEN
                     tipo := num_millones || ' E ';
                  ELSE
                     tipo := num_millones || ' ';
                  END IF;
               ELSE
                  tipo := NULL;
               END IF;
            END IF;

            contador := i;
            -- ASIGNAR A numero1,numero2,numero3 LOS ELEMENTOS DE LA LISTA.
            numero1 := numero(contador).cnumero;
            numero2 := numero(contador + 1).cnumero;
            numero3 := numero(contador + 2).cnumero;

            IF numero1 IS NOT NULL
               AND numero1 > 0 THEN
               centenas;
            END IF;

            IF numero2 IS NOT NULL
               AND numero2 > 0 THEN
               decenas;
            ELSE
               IF numero3 IS NOT NULL
                  AND numero3 > 0 THEN
                  unidades;
               END IF;
            END IF;
         END IF;
      END LOOP;

      -- AQUI VIENE LA PARTE PARA LOS DECIMALES, SI HAY.
      IF decimales_char IS NOT NULL THEN
         osas := termfem;
         unidad(1).tdescri := num_fem;   --
         numero2 := NVL(SUBSTR(decimales_char, 1, 1), 0);
         numero3 := NVL(SUBSTR(decimales_char, 2, 1), 0);

         -- BUG14712:DRA:14/06/2010:Inici
         IF TRUNC(np_nume) > 0 THEN
            IF nidioma = 4 THEN
               ctexto := ctexto || ' E ';
            ELSE
               ctexto := ctexto || ' ' || f_axis_literales(9901240, nidioma) || ' ';
            END IF;
         END IF;

         -- BUG14712:DRA:14/06/2010:Fi
         IF numero2 IS NOT NULL
            AND numero2 > 0 THEN
            decenas;
         ELSE
            IF numero3 IS NOT NULL
               AND numero3 > 0 THEN
               unidades;
            END IF;
         END IF;

         -- BUG14712:DRA:14/06/2010:Inici
         ctexto := ctexto || f_axis_literales(9901241, nidioma) || ' ';
      -- BUG14712:DRA:14/06/2010:Fi
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN salir THEN
         -- BUG -21546_108724- 09/02/2012 - JLTS - Cierre de posibles cursores abiertos
         IF centenas_c%ISOPEN THEN
            CLOSE centenas_c;
         END IF;

         IF decenas_c%ISOPEN THEN
            CLOSE decenas_c;
         END IF;

         IF num_dec_c%ISOPEN THEN
            CLOSE num_dec_c;
         END IF;

         IF unidades_c%ISOPEN THEN
            CLOSE unidades_c;
         END IF;

         RETURN 0;
      WHEN OTHERS THEN
         -- BUG -21546_108724- 09/02/2012 - JLTS - Cierre de posibles cursores abiertos
         IF centenas_c%ISOPEN THEN
            CLOSE centenas_c;
         END IF;

         IF decenas_c%ISOPEN THEN
            CLOSE decenas_c;
         END IF;

         IF num_dec_c%ISOPEN THEN
            CLOSE num_dec_c;
         END IF;

         IF unidades_c%ISOPEN THEN
            CLOSE unidades_c;
         END IF;

         p_tab_error(f_sysdate, f_user, 'pac_multidioma.f_numlet', 2,
                     'nidioma: ' || nidioma || ', np_nume: ' || np_nume || ', moneda: '
                     || moneda,
                     'SQLERROR: ' || SQLERRM);
         RETURN -1;   -- AQUI DEBE IR EL LITERAL DEL ERROR.
   END f_numlet;

   FUNCTION ff_numlet(
      nidioma IN NUMBER,   -- El texto retornado dependerá del idioma.
      np_nume IN NUMBER,   -- Número que se quiere traducir.
      moneda IN VARCHAR2)   -- Sería conveniente leer de tabla datos referentes a la moneda (decimales, etc.)
      RETURN VARCHAR2 IS
      v_err          NUMBER;
      salir          EXCEPTION;
      v_texto        VARCHAR2(2000);
   BEGIN
      -- Inicialitzem la cadena que retornarem per no concatenar-la amb possibles valors anteriors
      v_texto := NULL;
      v_err := pac_multidioma.f_numlet(nidioma, np_nume, moneda, v_texto);

      IF v_err <> 0 THEN
         RAISE salir;
      END IF;

      RETURN UPPER(v_texto);
   EXCEPTION
      WHEN salir THEN
         p_tab_error(f_sysdate, f_user, 'pac_multidioma.ff_numlet', 1,
                     'nidioma: ' || nidioma || ', np_nume: ' || np_nume || ', moneda: '
                     || moneda,
                     'ERROR-SALIR: ' || f_axis_literales(v_err, nidioma));
         RETURN NULL;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_multidioma.ff_numlet', 2,
                     'nidioma: ' || nidioma || ', np_nume: ' || np_nume || ', moneda: '
                     || moneda,
                     'SQLERROR: ' || SQLERRM);
         RETURN NULL;
   END ff_numlet;
END pac_multidioma;

/

  GRANT EXECUTE ON "AXIS"."PAC_MULTIDIOMA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MULTIDIOMA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MULTIDIOMA" TO "PROGRAMADORESCSI";
