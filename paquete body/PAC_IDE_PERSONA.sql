--------------------------------------------------------
--  DDL for Package Body PAC_IDE_PERSONA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IDE_PERSONA" IS
   /******************************************************************************
      NOMBRE:    PAC_IDE_PERSONAS
      PROPÓSITO: Funciones para gestionar validaciones de identificación de personas
      REVISIONES:
      Ver        Fecha        Autor       Descripción
      ---------  ----------  ---------  ------------------------------------
      1.0        13-05-2010  AVT         1. Creación del package. BUG: 14467
      2.0        07-06-2010  JMC         2. Se añade NIF Individual (25)
      3.0        16-06-2010  JMC         3. Se añade Menor (26)
      4.0        13-09-2011  JMF         4. 0019426: Definir producto Transportes Individual para GIP
      5.0        21-11-2011  APD         5. 0019587: LCOL_P001 - PER - Validaciones dependiendo del tipo de documento
      6.0        06-09-2012  MDS         6. 0023499: LCOL_P001-Passaport ha de permetre valors alfanum?rics
      7.0        11/12/2012  ETM         7. 0024780: RSA 701 - Preparar personas para Chile
      8.0        15/10/2013  FAL         8. 0026968: RSAG101 - Producto RC Argentina. Incidencias (14/5)
      9.0        27/11/2015  YDA         9. 0038922: Se crea la función f_validar_nif_malta
	  10.0       15/12/2017  ACL         10. CONF-564: Se añade condición en f_validar_nif_col.
	  11.0       27/11/2018  ACL         11. CP0013M_SYS_PERS - Se modifica la función f_validar_nif_col, y valide números de identificación con longitud mayor a seis dígitos.
	  12.0       30/11/2018  ACL         12. CP0036M_SYS_PERS - Se modifica la función f_validar_nif_col, para agregar condición para el tipo de identificación 93.
	  13.0       25/01/2019  CES         13. TCS_1570 - Se modifica la función f_digito_nif_col para agregar tipo identificación 33 Cedula Extranjería
      14.0       01/03/2019  CES         14. TCS_1570 - Se modifica la longitud de los documentos TI(acepta 10 y 11), pasaporte (acepta alfanumerico), registro civil (acepta 10 y 11)
   ******************************************************************************/
   FUNCTION f_validar_nif_ang(tipodoc IN VARCHAR, nnumnif IN VARCHAR)
      RETURN NUMBER IS
      RESULT         NUMBER;
      primer_carac   VARCHAR2(1);
      ultim_carac    VARCHAR2(1);
      tamanho        NUMBER;
   BEGIN
      /***************************************************************************
            Func?o: Criada para validar o nif Angolano
      Tipo de Documento - Regra de validac?o - Tamanho - Tipo   Digito  Digito
                                                                Inicial Fim
      NIF EMPRESA M?E                        - 10 Numerico     - 5        - n.a
      NIF EMPRESA FILIAL                     - 11 Alfanumerico - 5        - Letra
      NIF P.S.T. CONTA PROPRIA / ACTIVIDADES - 10 Numerico     - 2     - n.a
      NIF P.S.T. CONTA OUTREM                - 15 Alfanumerico - 1        - n.a.
      NIF INSTITUCIONAIS                     - 10 Numerico     - 7        - n.a.
      NIF ANTIGO                             - 15 alfanumericos - n.a.  - n.a.
      CART?O DE RESIDENCIA                   - 15 alfanumericos - n.a.  - n.a.
      BI                                     - 15 alfanumericos - n.a.  - n.a.
      BI ANTIGO                              - 15 alfanumericos - n.a.  - n.a.
      <Nenhum documento>                     - Z999999
      *****************************************************************************/
      RESULT := 0;
      primer_carac := SUBSTR(nnumnif, 1, 1);
      tamanho := LENGTH(nnumnif);
      ultim_carac := SUBSTR(nnumnif, tamanho, 1);

      /* Deve possuir pelo menos um caracter */
      IF tamanho = 0 THEN
         RESULT := 50000;
      END IF;

      IF tipodoc = 16 THEN
         --NIF EMPRESA
         IF tamanho > 10 THEN
            RESULT := 50000;
         ELSIF primer_carac != '5' THEN
            RESULT := 50000;
         END IF;
      /*
                        ELSIF tipodoc = 17 THEN
         --NIF EMPRESA FILIAL
         IF tamanho > 11 THEN
            RESULT := 50000;
         ELSIF primer_carac != '5' THEN
            RESULT := 50000;
         ELSIF ASCII(ultim_carac) < 64
               OR ASCII(ultim_carac) > 91 THEN   --N?o e letra
            RESULT := 50000;
         END IF;
      ELSIF tipodoc = 18 THEN
         --NIF P.S.T. CONTA PROPRIA / ACTIVIDADES
         IF tamanho > 10 THEN
            RESULT := 50000;
         ELSIF primer_carac != '2' THEN
            RESULT := 50000;
         END IF;
      ELSIF tipodoc = 19 THEN
         --NIF P.S.T. CONTA OUTREM
         IF tamanho > 15 THEN
            RESULT := 50000;
         ELSIF primer_carac != '1' THEN
            RESULT := 50000;
         END IF;
      ELSIF tipodoc = 20 THEN
         --NIF INSTITUCIONAIS
         IF tamanho > 10 THEN
            RESULT := 50000;
         ELSIF primer_carac != '7' THEN
            RESULT := 50000;
         END IF;
      ELSIF tipodoc = 21 THEN
         --NIF ANTIGO
         IF tamanho > 15 THEN
            RESULT := 50000;
         END IF;
         */
      ELSIF tipodoc = 22 THEN
         --CART?O DE RESIDENCIA
         IF tamanho > 15 THEN
            RESULT := 50000;
         END IF;
      ELSIF tipodoc = 23 THEN
         --BI
         IF tamanho > 15 THEN
            RESULT := 50000;
         END IF;
      ELSIF tipodoc = 24 THEN   -- PASAPORTE
         --PASAPORTE
         IF tamanho > 15 THEN
            RESULT := 50000;
         END IF;
      ELSIF tipodoc = 25 THEN
         --NIF Individual
         IF tamanho != 16 THEN
            RESULT := 50000;
         ELSIF primer_carac != '1' THEN
            RESULT := 50000;
         END IF;
      -- 15039 16-06-2010 JMC Se añade    Validació Menor Angola (26)
      ELSIF tipodoc = 26 THEN
         --Menor
         IF tamanho > 12 THEN   --Máx 14 el nif del menor
            RESULT := 50000;
         -- ELSIF primer_carac != '1' THEN
         --   RESULT := 50000;
         END IF;
      ELSIF tipodoc IS NULL THEN
         IF primer_carac = 'Z' THEN
            RESULT := 0;
         ELSE
            RESULT := 50000;
         END IF;
      END IF;

      RETURN(RESULT);
   END f_validar_nif_ang;

   -- BUG 0019426 - 13-09-2011 - JMF : Validación nif Portugal
   FUNCTION f_validar_nif_por(pctipide IN NUMBER, pnnumide IN VARCHAR)
      RETURN NUMBER IS
      v_obj          VARCHAR2(100) := 'pac_ide_persona.f_validar_nif_por';
      v_param        VARCHAR2(500) := 't=' || pctipide || ' n=' || pnnumide;
      n_pas          NUMBER;
      n_err          NUMBER := 0;
      v_aux          VARCHAR2(1);
      xcheckdigit    NUMBER := 0;
      n_suma         NUMBER := 0;
      e_salida       EXCEPTION;
   BEGIN
      n_pas := 100;

      IF pnnumide IS NULL THEN
         n_err := 101249;   -- nif null
         RAISE e_salida;
      END IF;

      n_pas := 110;

      DECLARE
         v_numero       NUMBER;
      BEGIN
         v_numero := TO_NUMBER(pnnumide);
      EXCEPTION
         WHEN OTHERS THEN
            n_err := 101506;   -- No són números els que haurien de ser-ho
            RAISE e_salida;
      END;

      n_pas := 120;

      IF TO_NUMBER(pnnumide) < 10000000
         OR TO_NUMBER(pnnumide) > 999999999 THEN
         n_err := 101250;   -- longitud nif incorrecta
         RAISE e_salida;
      END IF;

      n_pas := 130;
      v_aux := SUBSTR(pnnumide, 1, 1);

      IF v_aux NOT IN('1', '2', '5', '6', '7', '9') THEN
         n_err := 111650;   -- nif incorrecto
         RAISE e_salida;
      END IF;

      n_pas := 140;
      n_suma := 0;

      FOR i IN 1 .. 8 LOOP
         v_aux := SUBSTR(pnnumide, i, 1);
         n_suma := n_suma +(TO_NUMBER(v_aux) *(10 - i));
      END LOOP;

      n_pas := 150;
      v_aux := SUBSTR(pnnumide, 9, 1);

      IF v_aux = 0 THEN
         n_pas := 160;
         xcheckdigit := MOD((n_suma + TO_NUMBER(v_aux)), 11);

         IF xcheckdigit <> 0 THEN
            n_pas := 170;
            xcheckdigit := MOD(n_suma + 10, 11);
         END IF;
      ELSE
         n_pas := 180;
         n_suma := n_suma + TO_NUMBER(SUBSTR(pnnumide, 9, 1));
         n_pas := 190;
         xcheckdigit := MOD(n_suma, 11);
      END IF;

      n_pas := 200;

      IF xcheckdigit = 0 THEN
         n_err := 0;
      ELSE
         n_err := 111650;   -- nif incorrecto
      END IF;

      RETURN n_err;
   EXCEPTION
      WHEN e_salida THEN
         RETURN n_err;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_obj, n_pas, v_param, SQLCODE || ' ' || SQLERRM);
         RETURN 111650;   -- nif incorrecto
   END f_validar_nif_por;

   FUNCTION f_validar_nif_col(pctipide IN NUMBER, pnnumide IN VARCHAR, pcsexper IN NUMBER)
      RETURN NUMBER IS
      /***************************************************************************
                                                    Función para validar el documento de identidad de Colombia
      Tipo de Documento ------------------- Tipo -------- Regla de validación - Tamaño -----
      33 - Cédula extranjería               Alfanumérico  Letras y números      Entre 5 y 6
      34 - Tarjeta de identidad             Numérico      Números               Entre 10 y 11
      35 - Registro civil de nacimiento     Alfanumérico  Letras y números      Entre 8 y 11
      36 - Cédula ciudadanía                Numérico      Números               Entre 3 y 10
      37 - NIT persona jurídica             Numérico      Números               9+1
               valor entre 800.000.000 y 999.999.999
      38 - Número único de identificación   Numérico      Números               10
           personal (NUIP)
               Valor >= 1.000.000.000
      39 - NIT persona natural              Numérico                            Entre 3 y 12
      40 - Pasaporte                        Alfanumérico  Letras y números      Entre 3 y 16
      *****************************************************************************/
      v_obj          VARCHAR2(100) := 'pac_ide_persona.f_validar_nif_col';
      v_param        VARCHAR2(500) := 't=' || pctipide || ' n=' || pnnumide;
      n_pas          NUMBER;
      n_err          NUMBER := 0;
      v_numero       NUMBER;
      v_lon          NUMBER;
      v_lon_esp      NUMBER;
      v_auxnum       NUMBER;
      vnum           NUMBER := 0;
      vcontrol       NUMBER;
      vcontrolcal    NUMBER;
   BEGIN
      n_pas := 100;
      v_lon := LENGTH(pnnumide);

      IF pnnumide IS NULL THEN
         n_err := 101249;   -- nif null
         RETURN n_err;
      END IF;

      -- Bug 20736 - APD - 30/12/2011 - en colombia tienen el formato ingles
      -- asi que el TO_NUMBER no detecta valores erroneos si han introducido
      -- un punto (.) ya que en español lo detecta como el separador de miles
      -- Por lo tanto, se valida que si se ha introducido un punto (.) o una
      -- coma (,) en el campo muestre mensaje de error, además de seguir
      -- haciendo la validación del TO_NUMBER
      n_pas := 351;

      -- Bug 21319/106998 - 13/02/2012 - AMC

       -- VALIDACIONES SEGÚN EL TIPO DE DOCUMENTO.
      CASE pctipide
         WHEN 33 THEN   -- 33 CEDULA DE EXTRANJERIA (campo numérico)
            IF v_lon <> 6 THEN   -- Ajuste al 42% de personas ACL 30/10/2018
               n_err := 9902747;
               --INI 06/11/2018 CP0028M_SYS_PERS_Val AP
            ELSIF pnnumide = '000000' THEN
               n_err := 9902749;
               --FIN 06/11/2018 CP0028M_SYS_PERS_Val AP
            ELSE
               SELECT LENGTH(TRIM(TRANSLATE(pnnumide, '0123456789', ' ')))
                 INTO v_lon_esp
                 FROM DUAL;

               IF NVL(v_lon_esp, 0) > 0 THEN
                  n_err := 1000172;   -- El documento debe ser numérico.
                  RETURN n_err;
               END IF;
            END IF;
         WHEN 34 THEN   -- 34 TARJETA DE IDENTIDAD
          --  IF v_lon <> 10 THEN   -- Ajuste al 42% de personas ACL 30/10/2018
          -- INI TCS1570 CES
            IF v_lon < 10 OR v_lon > 11 THEN
    -- END TCS1570 CES
               n_err := 9902747;
               --INI 06/11/2018 CP0028M_SYS_PERS_Val AP
            ELSIF pnnumide = '0000000000' THEN
               n_err := 9902749;
               --FIN 06/11/2018 CP0028M_SYS_PERS_Val AP
            ELSE
               SELECT LENGTH(TRIM(TRANSLATE(pnnumide, '0123456789', ' ')))
                 INTO v_lon_esp
                 FROM DUAL;

               IF NVL(v_lon_esp, 0) > 0 THEN
                  n_err := 1000172;   -- El documento debe ser numérico.
                  RETURN n_err;
               END IF;
            END IF;
         --  END IF;
      WHEN 35 THEN   -- 35 REGISTRO CIVIL
      -- INI TCS1570 CES
            IF v_lon < 10 OR v_lon > 11 THEN
    -- END TCS1570 CES
               n_err := 9902747;
               --INI 06/11/2018 CP0028M_SYS_PERS_Val AP
            ELSIF pnnumide = '0000000000' THEN
               n_err := 9902749;
               --FIN 06/11/2018 CP0028M_SYS_PERS_Val AP
            ELSE
               SELECT LENGTH
                         (TRIM
                             (TRANSLATE
                                 (pnnumide,
                                  'abcdefghijklmnñopqrstuvwxyzABCDEFGHIJKLMNÑOPQRSTUVWXYZ0123456789',
                                  ' ')))
                 INTO v_lon_esp
                 FROM DUAL;

               IF NVL(v_lon_esp, 0) > 0 THEN
                  n_err := 9902749;   -- El documento debe ser altanumérico.
                  RETURN n_err;
               END IF;
            END IF;
         WHEN 36 THEN   -- 36 CÉDULA DE CIUDADANIA
            IF v_lon < 6    -- CP0013M_SYS_PERS - ACL- 27/11/2018
               OR v_lon > 10 THEN
               n_err := 9902747;
               --INI 06/11/2018 CP0028M_SYS_PERS_Val AP
            ELSIF pnnumide in (000000, 0000000, 00000000, 000000000, 0000000000) THEN
               n_err := 9902749;
               --FIN 06/11/2018 CP0028M_SYS_PERS_Val AP
            ELSE
               SELECT LENGTH(TRIM(TRANSLATE(pnnumide, '0123456789', ' ')))
                 INTO v_lon_esp
                 FROM DUAL;

               IF NVL(v_lon_esp, 0) > 0 THEN
                  n_err := 1000172;   -- El documento debe ser numérico.
                  RETURN n_err;
               END IF;
            END IF;

            vnum := pnnumide;
         WHEN 37 THEN   -- 37 NIT
            vnum := SUBSTR(pnnumide, 1,(LENGTH(pnnumide) - 1));

            IF vnum < 800000000
               OR vnum > 999999999 THEN
               n_err := 9902749;   -- Documento incorrecto
               RETURN n_err;
            ELSE
               SELECT LENGTH(TRIM(TRANSLATE(pnnumide, '0123456789', ' ')))
                 INTO v_lon_esp
                 FROM DUAL;

               IF NVL(v_lon_esp, 0) > 0 THEN
                  n_err := 1000172;   -- El documento debe ser numérico.
                  RETURN n_err;
               ELSE
                  v_numero := pnnumide;
                  vnum := SUBSTR(v_numero, 1,(LENGTH(v_numero) - 1));
                  vcontrol := SUBSTR(v_numero, LENGTH(v_numero), 1);
                  vcontrolcal := f_digito_nif_col(pctipide, vnum);

                  IF vcontrol <> vcontrolcal THEN
                     n_err := 9903141;   -- Digito de verificación incorrecto
                  END IF;
               END IF;
            END IF;
         WHEN 38 THEN   -- 38 NÚMERO ÚNICO DE IDENTIFICACION PERSONAL
            IF v_lon <> 10 THEN
               n_err := 9902747;
            ELSE
               SELECT LENGTH(TRIM(TRANSLATE(pnnumide, '0123456789', ' ')))
                 INTO v_lon_esp
                 FROM DUAL;

               IF NVL(v_lon_esp, 0) > 0 THEN
                  n_err := 1000172;   -- El documento debe ser numérico.
                  RETURN n_err;
               ELSE
                  IF pnnumide < 1000000000 THEN
                     n_err := 9902749;   -- Documento incorrecto
                     RETURN n_err;
                  END IF;
               END IF;
            END IF;
         WHEN 40 THEN   --  40 PASAPORTE
            IF v_lon < 6     -- CP0013M_SYS_PERS - ACL- 27/11/2018
               OR v_lon > 15 THEN
               n_err := 9902747;   -- Longitud del documento incorrecta.
               --INI 06/11/2018 CP0028M_SYS_PERS_Val AP
            ELSIF pnnumide in ('000000', '0000000', '00000000', '000000000', '0000000000', '00000000000', '000000000000', '0000000000000', '00000000000000', '000000000000000') THEN
               n_err := 9902749; -- Documento incorrecto
               --FIN 06/11/2018 CP0028M_SYS_PERS_Val AP
            ELSE
            -- INI TCS1570 CES
               SELECT LENGTH(TRIM(TRANSLATE(pnnumide, '0123456789', ' ')))
                 INTO v_lon_esp
                 FROM DUAL;

               IF NVL(v_lon_esp, 0) = 0 THEN
                  n_err := 9902749;   -- El documento debe ser numérico.
                  RETURN n_err;
                END IF;
              -- END TCS1570 CES
               SELECT LENGTH
                         (TRIM
                             (TRANSLATE
                                 (pnnumide,
                                  'abcdefghijklmnñopqrstuvwxyzABCDEFGHIJKLMNÑOPQRSTUVWXYZ0123456789',
                                  ' ')))
                 INTO v_lon_esp
                 FROM DUAL;

               IF NVL(v_lon_esp, 0) > 0 THEN
                  n_err := 9902749;   -- El documento debe ser altanumérico.
                  RETURN n_err;
               END IF;
            END IF;
         WHEN 44 THEN   --  44 CARNET DIPLOM�?TICO
            IF v_lon < 6    -- CP0013M_SYS_PERS - ACL- 27/11/2018
               OR v_lon > 15 THEN
               n_err := 9902747;
               --INI 06/11/2018 CP0028M_SYS_PERS_Val AP
               ELSIF pnnumide in (000000, 0000000, 00000000, 000000000, 0000000000, 00000000000, 000000000000, 0000000000000, 00000000000000, 000000000000000) THEN
               n_err := 9902749; -- Documento incorrecto
               --FIN 06/11/2018 CP0028M_SYS_PERS_Val AP
            ELSE   -- El documento debe ser altanumérico.
               SELECT LENGTH
                         (TRIM
                             (TRANSLATE
                                 (pnnumide,
                                  'abcdefghijklmnñopqrstuvwxyzABCDEFGHIJKLMNÑOPQRSTUVWXYZ0123456789',
                                  ' ')))
                 INTO v_lon_esp
                 FROM DUAL;

               IF NVL(v_lon_esp, 0) > 0 THEN
                  n_err := 9902749;   -- El documento debe ser altanumérico.
                  RETURN n_err;
               END IF;
            END IF;
		-- INI CONF-564 Se agrega validación ctipide = 96 -- ACL - 15/12/2017
		 WHEN 96 THEN   -- 96 CODIGO PERSONA EXTRANJERA
            IF v_lon < 6     -- CP0013M_SYS_PERS - ACL- 27/11/2018
               OR v_lon > 10 THEN
               n_err := 9902747;
               --INI 06/11/2018 CP0028M_SYS_PERS_Val AP
               ELSIF pnnumide in (000000, 0000000, 00000000, 000000000, 0000000000, 00000000000, 000000000000, 0000000000000, 00000000000000, 000000000000000) THEN
               n_err := 9902749; -- Documento incorrecto
               --FIN 06/11/2018 CP0028M_SYS_PERS_Val AP
            ELSE
               SELECT LENGTH(TRIM(TRANSLATE(pnnumide, '0123456789', ' ')))
                 INTO v_lon_esp
                 FROM DUAL;

               IF NVL(v_lon_esp, 0) > 0 THEN
                  n_err := 1000172;   -- El documento debe ser numérico.
                  RETURN n_err;
               END IF;
            END IF;
		-- FIN CONF-564 Se agrega validación ctipide = 96 -- ACL - 15/12/2017
		-- INI CP0036M_SYS_PERS - ACL- 30/11/2018
		WHEN 93 THEN   -- 93 (PEP) PERMISO ESPECIAL DE PERMANENCIA
            IF v_lon <> 12 THEN
               n_err := 9902747;
               --INI 06/11/2018 CP0028M_SYS_PERS_Val AP
               ELSIF pnnumide = 000000000000 THEN
               n_err := 9902749; -- Documento incorrecto
               --FIN 06/11/2018 CP0028M_SYS_PERS_Val AP
            ELSE
               SELECT LENGTH(TRIM(TRANSLATE(pnnumide, '0123456789', ' ')))
                 INTO v_lon_esp
                 FROM DUAL;

               IF NVL(v_lon_esp, 0) > 0 THEN
                  n_err := 1000172;   -- El documento debe ser numérico.
                  RETURN n_err;
               END IF;
            END IF;
		-- FIN CP0036M_SYS_PERS - ACL- 30/11/2018
         WHEN 45 THEN   -- 45 NIT PERSONAL
            v_lon := LENGTH(SUBSTR(pnnumide, 1,(LENGTH(pnnumide) - 1)));

            IF v_lon < 6    -- CP0013M_SYS_PERS - ACL- 27/11/2018
               OR v_lon > 12 THEN
               n_err := 9902747;
               --INI 06/11/2018 CP0028M_SYS_PERS_Val AP
               ELSIF pnnumide in (000000, 0000000, 00000000, 000000000, 0000000000, 00000000000, 000000000000) THEN
               n_err := 9902749; -- Documento incorrecto
               --FIN 06/11/2018 CP0028M_SYS_PERS_Val AP
            ELSE
               SELECT LENGTH(TRIM(TRANSLATE(pnnumide, '0123456789', ' ')))
                 INTO v_lon_esp
                 FROM DUAL;

               IF NVL(v_lon_esp, 0) > 0 THEN
                  n_err := 1000172;   -- El documento debe ser numérico.
                  RETURN n_err;
               ELSE
                  v_numero := pnnumide;
                  vnum := SUBSTR(v_numero, 1,(LENGTH(v_numero) - 1));
                  vcontrol := SUBSTR(v_numero, LENGTH(v_numero), 1);
                  vcontrolcal := f_digito_nif_col(pctipide, vnum);

                  IF vcontrol <> vcontrolcal THEN
                     n_err := 9903141;   -- Digito de verificación incorrecto
                  END IF;
               END IF;
            END IF;
         ELSE
            n_err := 111650;   -- nif incorrecto
      END CASE;

      n_pas := 400;
      RETURN n_err;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_obj, n_pas, v_param, SQLCODE || ' ' || SQLERRM);
         RETURN 9902749;   -- Documento incorrecto
   END f_validar_nif_col;

   /***************************************************************************
                                                      Función para obtener el dígito de control del documento de identidad de Colombia
      Tipos de documento a los que puede aplicar calcular el dígito de control
      Tipo de Documento ------------------- Tipo -------- Regla de validación - Tamaño -----
      36 - Cédula ciudadanía                Numérico      Números               Entre 3 y 10
      *****************************************************************************/
   FUNCTION f_digito_nif_col(pctipide IN NUMBER, pnnumide IN VARCHAR)
      RETURN NUMBER IS
      v_obj          VARCHAR2(100) := 'pac_ide_persona.f_digito_nif_col';
      v_param        VARCHAR2(500) := 't=' || pctipide || ' n=' || pnnumide;
      n_pas          NUMBER;
      v_numero       VARCHAR2(20);
      v_suma         NUMBER;
      v_modulo11     NUMBER;
      v_digito       NUMBER(1);
   BEGIN
      n_pas := 100;

      IF pctipide <> 36
         AND pctipide <> 37
         -- INI RLLF BUG-34911 Dígito de control para personas con NIT físicas.
         AND pctipide <> 45
         -- FIN RLLF BUG-34911 Dígito de control para personas con NIT físicas.
		 -- INI CES TCS_1570 Dígito de verificación para personas con Cédula de Extranjería.
         AND pctipide <> 33 THEN
         -- FIN CES TCS_1570 Dígito de verificación personas con Cédula de Extranjería.
         RETURN NULL;
      END IF;

      n_pas := 101;
      v_numero := LPAD(pnnumide, 15, '0');
      v_suma := SUBSTR(v_numero, 1, 1) * 71 + SUBSTR(v_numero, 2, 1) * 67
                + SUBSTR(v_numero, 3, 1) * 59 + SUBSTR(v_numero, 4, 1) * 53
                + SUBSTR(v_numero, 5, 1) * 47 + SUBSTR(v_numero, 6, 1) * 43
                + SUBSTR(v_numero, 7, 1) * 41 + SUBSTR(v_numero, 8, 1) * 37
                + SUBSTR(v_numero, 9, 1) * 29 + SUBSTR(v_numero, 10, 1) * 23
                + SUBSTR(v_numero, 11, 1) * 19 + SUBSTR(v_numero, 12, 1) * 17
                + SUBSTR(v_numero, 13, 1) * 13 + SUBSTR(v_numero, 14, 1) * 7
                + SUBSTR(v_numero, 15, 1) * 3;
      n_pas := 110;
      v_modulo11 := MOD(v_suma, 11);
      n_pas := 111;

      IF v_modulo11 < 2 THEN
         v_digito := v_modulo11;
      ELSE
         v_digito := 11 - v_modulo11;
      END IF;

      RETURN v_digito;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_obj, n_pas, v_param, SQLCODE || ' ' || SQLERRM);
         RETURN NULL;
   END f_digito_nif_col;

-- Bug 24780 - ETM - 11/12/2012
   FUNCTION f_validar_nif_chile(pctipide IN NUMBER, pnnumide IN VARCHAR)
      RETURN NUMBER IS
      v_obj          VARCHAR2(100) := 'pac_ide_persona.f_validar_nif_chile';
      v_param        VARCHAR2(500) := 't=' || pctipide || ' n=' || pnnumide;
      n_pas          NUMBER;
      n_err          NUMBER := 0;
      v_numero       NUMBER;
      v_lon          NUMBER;
      v_lon_esp      NUMBER;
      v_auxnum       NUMBER;
      vnum           NUMBER;
      vcontrol       NUMBER;
      vcontrolcal    NUMBER;
      wnnumide       per_personas.nnumide%TYPE;
   -- BUG 26968/0155105 - FAL - 15/10/2013
   BEGIN
      wnnumide := pac_persona.f_desformat_nif(pnnumide, pctipide);

      -- BUG 26968/0155105 - FAL - 15/10/2013
      IF wnnumide IS NULL THEN
         n_err := 101249;   -- nif null
         RETURN n_err;
      END IF;

      n_pas := 200;
      v_lon := LENGTH(wnnumide);
      n_pas := 300;

      IF pctipide NOT IN(41) THEN
         n_err := 9902749;   -- Documento incorrecto
         RETURN n_err;
      END IF;

      IF v_lon > 8 THEN
         RETURN 9905738;   -- Longitud del RUT incorrecta (máx. 8 dígitos)
      END IF;

      -- BUG 0026968/0147424 - FAL - 27/06/2013
      IF TO_NUMBER(wnnumide) > 49999999
         OR TO_NUMBER(wnnumide) < 1000000 THEN
         RETURN 9905739;
      -- RUT de persona natural incorrecto (1000000...49999999)
      END IF;

      -- FI BUG 0026968/0147424
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_obj, n_pas, v_param, SQLCODE || ' ' || SQLERRM);
         RETURN 9902749;   -- Documento incorrecto
   END f_validar_nif_chile;

   -- BUG 0026968/0147424 - FAL - 27/06/2013
   FUNCTION f_validar_nif_chile_jurid(pctipide IN NUMBER, pnnumide IN VARCHAR)
      RETURN NUMBER IS
      v_obj          VARCHAR2(100) := 'pac_ide_persona.f_validar_nif_chile_jurid';
      v_param        VARCHAR2(500) := 't=' || pctipide || ' n=' || pnnumide;
      n_pas          NUMBER;
      n_err          NUMBER := 0;
      v_numero       NUMBER;
      v_lon          NUMBER;
      v_lon_esp      NUMBER;
      v_auxnum       NUMBER;
      vnum           NUMBER;
      vcontrol       NUMBER;
      vcontrolcal    NUMBER;
      wnnumide       per_personas.nnumide%TYPE;
   -- BUG 26968/0155105 - FAL - 15/10/2013
   BEGIN
      wnnumide := pac_persona.f_desformat_nif(pnnumide, pctipide);

      -- BUG 26968/0155105 - FAL - 15/10/2013
      IF wnnumide IS NULL THEN
         n_err := 101249;   -- nif null
         RETURN n_err;
      END IF;

      n_pas := 200;
      v_lon := LENGTH(wnnumide);
      n_pas := 300;

      IF pctipide NOT IN(42) THEN
         n_err := 9902749;   -- Documento incorrecto
         RETURN n_err;
      END IF;

      IF v_lon > 8 THEN
         RETURN 9905738;   -- Longitud del RUT incorrecta (máx. 8 dígitos)
      END IF;

      -- BUG 0026968/0147424 - FAL - 27/06/2013
      IF TO_NUMBER(wnnumide) < 50000000 THEN
         RETURN 9905740;
      -- RUT de persona jurídica incorrecto (50000000...99999999)
      END IF;

      -- FI BUG 0026968/0147424
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_obj, n_pas, v_param, SQLCODE || ' ' || SQLERRM);
         RETURN 9902749;   -- Documento incorrecto
   END f_validar_nif_chile_jurid;

   -- FI BUG 0026968/0147424
   FUNCTION f_digito_nif_chile(pctipide IN NUMBER, pnnumide IN VARCHAR)
      RETURN VARCHAR2 IS
      v_obj          VARCHAR2(1000) := 'pac_ide_persona.f_digito_nif_chile';
      v_param        VARCHAR2(1000) := 't=' || pctipide || ' n=' || pnnumide;
      n_pas          NUMBER := 0;
      v_suma         NUMBER := 0;
      v_modulo11     NUMBER := 0;
      v_digito       NUMBER := 0;
   BEGIN
      n_pas := 100;

      IF pctipide NOT IN(41, 42) THEN
         RETURN NULL;
      END IF;

      n_pas := 101;
      v_suma := SUBSTR(LPAD(pnnumide, 8, 0), 1, 1) * 3 + SUBSTR(LPAD(pnnumide, 8, 0), 2, 1) * 2
                + SUBSTR(LPAD(pnnumide, 8, 0), 3, 1) * 7
                + SUBSTR(LPAD(pnnumide, 8, 0), 4, 1) * 6
                + SUBSTR(LPAD(pnnumide, 8, 0), 5, 1) * 5
                + SUBSTR(LPAD(pnnumide, 8, 0), 6, 1) * 4
                + SUBSTR(LPAD(pnnumide, 8, 0), 7, 1) * 3
                + SUBSTR(LPAD(pnnumide, 8, 0), 8, 1) * 2;
      n_pas := 110;
      v_modulo11 := MOD(v_suma, 11);
      n_pas := 111;

/* ====================== INICIO Incidencia # 25880  MGM  06/02/2013 ==================*/
      IF v_modulo11 = 0 THEN
         RETURN '0';
      ELSIF v_modulo11 = 1 THEN
         RETURN 'K';
      ELSE
         v_digito := 11 - v_modulo11;
         RETURN v_digito;
      END IF;
/* ====================== FIN Incidencia # 25880  MGM 06/02/2013==================*/
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_obj, n_pas, v_param, SQLCODE || ' ' || SQLERRM);
         RETURN NULL;
   END f_digito_nif_chile;

--FIN  Bug 24780 - ETM - 11/12/2012
   FUNCTION f_validar_nif_malta(
      pctipide IN per_personas.ctipide%TYPE,
      pnnumide IN per_personas.nnumide%TYPE)
      RETURN NUMBER IS
      v_obj          VARCHAR2(1000) := 'pac_ide_persona.f_validar_nif_malta';
      v_param        VARCHAR2(1000) := 'pctipide = ' || pctipide || ' pnnumide = ' || pnnumide;
      v_traza        NUMBER;
      n_err          NUMBER;
      v_lon          NUMBER;
      v_lon_esp_1    NUMBER;
      v_lon_esp_2    NUMBER;
      e_salida       EXCEPTION;
   BEGIN
      IF pnnumide IS NULL THEN
         n_err := 101249;
         RAISE e_salida;
      END IF;

      v_lon := LENGTH(pnnumide);

      IF pctipide = 51 THEN
         IF (v_lon != 8) THEN
            n_err := 9902747;
            RAISE e_salida;
         END IF;

         SELECT LENGTH(TRIM(TRANSLATE(SUBSTR(pnnumide, 1,(LENGTH(pnnumide) - 1)), '0123456789',
                                      ' ')))
           INTO v_lon_esp_1
           FROM DUAL;

         SELECT LENGTH
                    (TRIM(TRANSLATE(SUBSTR(pnnumide, -1),
                                    'abcdefghijklmnñopqrstuvwxyzABCDEFGHIJKLMNÑOPQRSTUVWXYZ',
                                    ' ')))
           INTO v_lon_esp_2
           FROM DUAL;

         IF (NVL(v_lon_esp_1, 0) > 0
             OR NVL(v_lon_esp_2, 0) > 0) THEN
            n_err := 9902749;
            RAISE e_salida;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_salida THEN
         RETURN n_err;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_obj, v_traza, v_param, SQLCODE || ' ' || SQLERRM);
         RETURN 9908593;
   END f_validar_nif_malta;

   FUNCTION f_validar_nif_ecu(pctipide IN NUMBER, pnnumide IN VARCHAR)
      RETURN NUMBER IS
      /***************************************************************************
      Función para validar el documento de identidad de Ecuador
      Tipo de Documento ------------------- Tipo -------- Regla de validación - Tamaño -----

      36 - Cédula ciudadanía                Numérico      Números               10 o 13
      40 - Pasaporte                        Alfanumérico  Letras y números      Entre 3 y 15
      34 - RUC                              Numérico      Numeros               13
      35 - RUC Público                      Numérico      Numeros               13
      *****************************************************************************/
      v_obj          VARCHAR2(100) := 'pac_ide_persona.f_validar_nif_ecu';
      v_param        VARCHAR2(500) := 't=' || pctipide || ' n=' || pnnumide;
      n_pas          NUMBER;
      n_err          NUMBER := 0;
      v_numero       NUMBER;
      v_lon          NUMBER;
      v_lon_esp      NUMBER;
      v_auxnum       NUMBER;
      vnum           NUMBER;
      v_numero_formato VARCHAR2(20);
      v_suma         NUMBER;
      v_modulo11     NUMBER;
      v_modulo10     NUMBER;
      v_digito       NUMBER(20);

      FUNCTION f_mult_coeficiente(pnumero NUMBER, pmult NUMBER)
         RETURN NUMBER IS
         vtotal         NUMBER;
      BEGIN
         vtotal := pnumero * pmult;

         WHILE vtotal > 9 LOOP
            vtotal := SUBSTR(vtotal, 1, 1) + SUBSTR(vtotal, 2, 1);
         END LOOP;

         RETURN vtotal;
      END f_mult_coeficiente;
   BEGIN
      n_pas := 100;

      IF pnnumide IS NULL THEN
         n_err := 101249;   -- nif null
         RETURN n_err;
      END IF;

      n_pas := 200;
      v_lon := LENGTH(pnnumide);
      n_pas := 300;

      BEGIN
         -- Bug 20736 - APD - 30/12/2011 - en colombia tienen el formato ingles
         -- asi que el TO_NUMBER no detecta valores erroneos si han introducido
         -- un punto (.) ya que en español lo detecta como el separador de miles
         -- Por lo tanto, se valida que si se ha introducido un punto (.) o una
         -- coma (,) en el campo muestre mensaje de error, además de seguir
         -- haciendo la validación del TO_NUMBER
         n_pas := 351;
         v_auxnum := INSTR(pnnumide, ',');

         IF v_auxnum <> 0 THEN
            -- ini BUG 23499 - MDS - 06/09/2012
            -- para los alfanuméricos cambiar el mensaje de error
            IF pctipide = 40 THEN
               n_err := 9902749;   -- Documento incorrecto
               RETURN n_err;
            ELSE
               -- fin BUG 23499 - MDS - 06/09/2012
               n_err := 1000172;   -- El campo Documento debe ser numérico
               RETURN n_err;
            END IF;
         END IF;

         n_pas := 352;
         v_auxnum := INSTR(pnnumide, '.');

         IF v_auxnum <> 0 THEN
            -- BUG 23499 - MDS - 06/09/2012
            -- para los alfanuméricos cambiar el mensaje de error
            IF pctipide = 40 THEN
               n_err := 9902749;   -- Documento incorrecto
               RETURN n_err;
            ELSE
               -- fin BUG 23499 - MDS - 06/09/2012
               n_err := 1000172;   -- El campo Documento debe ser numérico
               RETURN n_err;
            END IF;
         END IF;

         -- fin Bug 20736 - APD - 30/12/2011

         -- ini BUG 23499 - MDS - 06/09/2012
         -- para los alfanuméricos, permitir alfanuméricos controladamente
         n_pas := 353;

         IF pctipide = 40 THEN
            SELECT LENGTH
                      (TRIM
                          (TRANSLATE
                              (pnnumide,
                               'abcdefghijklmnñopqrstuvwxyzABCDEFGHIJKLMNÑOPQRSTUVWXYZ0123456789',
                               ' ')))
              INTO v_lon_esp
              FROM DUAL;

            IF NVL(v_lon_esp, 0) > 0 THEN
               n_err := 9902748;   -- El documento contiene caracteres no permitidos
               RETURN n_err;
            END IF;
         ELSE
            -- fin BUG 23499 - MDS - 06/09/2012
            v_numero := TO_NUMBER(pnnumide);
         END IF;
      EXCEPTION
         WHEN OTHERS THEN
            n_err := 1000172;   -- El campo Documento debe ser numérico
            RETURN n_err;
      END;

      n_pas := 360;

------------------------------
------------------------------
      IF pctipide = 40 THEN   -- 40
         IF v_lon < 3
            OR v_lon > 15 THEN
            n_err := 9902747;   -- 'Longitud del documento incorrecta'
            RETURN n_err;
         ELSE
            RETURN 0;   --Correcto, sólo comprobamos longitud
         END IF;
      ELSIF pctipide = 66 THEN   --Cédula y RUC persona natural
         IF v_lon != 10 THEN
            n_err := 9902747;   -- 'Longitud del documento incorrecta'
            RETURN n_err;
         END IF;
      ELSIF pctipide = 63 THEN   --Cédula y RUC persona natural
         IF v_lon != 13 THEN
            n_err := 9902747;   -- 'Longitud del documento incorrecta'
            RETURN n_err;
         END IF;
      ELSIF pctipide = 64 THEN   --RUC Jurídico
         IF v_lon != 13 THEN
            n_err := 9902747;   -- 'Longitud del documento incorrecta'
            RETURN n_err;
         END IF;
      ELSIF pctipide = 65 THEN   --RUC Público
         IF v_lon != 13 THEN
            n_err := 9902747;   -- 'Longitud del documento incorrecta'
            RETURN n_err;
         END IF;
      END IF;

      n_pas := 400;
      --v_numero_formato := LPAD(pnnumide, 13, '0');
      v_numero_formato := pnnumide;
      n_pas := 401;

      --Cedula y RUC persona natural
      IF pctipide IN(63, 66) THEN
         IF SUBSTR(v_numero_formato, 3, 1) < 6 THEN
            --RUC corresponde a Persona Natural
            IF SUBSTR(v_numero_formato, 1, 2) < 1
               OR SUBSTR(v_numero_formato, 1, 2) > 22 THEN
               --Las 2 primeras posiciones no podrán ser menor a 1 o mayor a 22
               --'RUC de Persona Natural incorrecto'
               n_err := 9902749;   --9907253;
               RETURN n_err;
            END IF;

            IF v_lon = 13 THEN
               IF SUBSTR(v_numero_formato, 11, 3) = '000' THEN
                  --Los tres últimos dígitos no podrán ser 000
                  --'RUC de Persona Natural incorrecto'
                  n_err := 9907253;
                  RETURN n_err;
               END IF;
            END IF;

            n_pas := 402;
            v_suma := f_mult_coeficiente(SUBSTR(v_numero_formato, 1, 1), 2)
                      + f_mult_coeficiente(SUBSTR(v_numero_formato, 2, 1), 1)
                      + f_mult_coeficiente(SUBSTR(v_numero_formato, 3, 1), 2)
                      + f_mult_coeficiente(SUBSTR(v_numero_formato, 4, 1), 1)
                      + f_mult_coeficiente(SUBSTR(v_numero_formato, 5, 1), 2)
                      + f_mult_coeficiente(SUBSTR(v_numero_formato, 6, 1), 1)
                      + f_mult_coeficiente(SUBSTR(v_numero_formato, 7, 1), 2)
                      + f_mult_coeficiente(SUBSTR(v_numero_formato, 8, 1), 1)
                      + f_mult_coeficiente(SUBSTR(v_numero_formato, 9, 1), 2);
            n_pas := 410;
            v_modulo10 := MOD(v_suma, 10);
            n_pas := 411;

            IF v_modulo10 = 0 THEN
               v_digito := 0;
            ELSE
               v_digito := 10 - v_modulo10;
            END IF;

            n_pas := 412;

            IF v_digito = SUBSTR(v_numero_formato, 10, 1) THEN
               n_err := 0;
            ELSE
               RETURN 9902749;
            END IF;
         ELSE
            n_err := 9902749;   --Documento incorrecto
            RETURN n_err;
         END IF;
      --RUC Juridica
      ELSIF pctipide = 64 THEN
         IF SUBSTR(v_numero_formato, 3, 1) = 9 THEN
            --RUC corresponde a Persona Jurídica
            IF SUBSTR(v_numero_formato, 1, 2) < 1
               OR SUBSTR(v_numero_formato, 1, 2) > 22 THEN
               --Las 2 primeras posiciones no podrán ser menor a 1 o mayor a 22
               --'RUC de Persona Jurídica incorrecto'
               n_err := 9907255;
               RETURN n_err;
            END IF;

            IF SUBSTR(v_numero_formato, 11, 3) = '000' THEN
               --Los tres últimos dígitos no podrán ser 000
               --'RUC de Persona Jurídica incorrecto'
               n_err := 9907255;
               RETURN n_err;
            END IF;

            v_suma := SUBSTR(v_numero_formato, 1, 1) * 4 + SUBSTR(v_numero_formato, 2, 1) * 3
                      + SUBSTR(v_numero_formato, 3, 1) * 2 + SUBSTR(v_numero_formato, 4, 1) * 7
                      + SUBSTR(v_numero_formato, 5, 1) * 6 + SUBSTR(v_numero_formato, 6, 1) * 5
                      + SUBSTR(v_numero_formato, 7, 1) * 4 + SUBSTR(v_numero_formato, 8, 1) * 3
                      + SUBSTR(v_numero_formato, 9, 1) * 2;
            n_pas := 510;
            v_modulo11 := MOD(v_suma, 11);
            n_pas := 511;

            IF v_modulo11 = 0 THEN
               v_digito := 0;
            ELSIF v_modulo11 = 1 THEN
               n_err := 9907255;
               RETURN n_err;
            ELSE
               v_digito := 11 - v_modulo11;
            END IF;

            IF v_digito = SUBSTR(v_numero_formato, 10, 1) THEN
               n_err := 0;
            ELSE
               RETURN 9907255;
            END IF;
         ELSE
            n_err := 9907255;   --Documento incorrecto
            RETURN n_err;
         END IF;
      --RUC Público
      ELSIF pctipide = 65 THEN
         IF SUBSTR(v_numero_formato, 3, 1) = 6 THEN
            --RUC corresponde a Empresas del Sector Público
            IF SUBSTR(v_numero_formato, 1, 2) < 1
               OR SUBSTR(v_numero_formato, 1, 2) > 22 THEN
               --Las 2 primeras posiciones no podrán ser menor a 1 o mayor a 22
               --'RUC de Institución Pública incorrecto'
               n_err := 9907256;
               RETURN n_err;
            END IF;

            IF SUBSTR(v_numero_formato, 10, 4) = '0000' THEN
               --Los tres últimos dígitos no podrán ser 000
               --'RUC de Institución Pública incorrecto'
               n_err := 9907256;
               RETURN n_err;
            END IF;

            v_suma := SUBSTR(v_numero_formato, 1, 1) * 3 + SUBSTR(v_numero_formato, 2, 1) * 2
                      + SUBSTR(v_numero_formato, 3, 1) * 7 + SUBSTR(v_numero_formato, 4, 1) * 6
                      + SUBSTR(v_numero_formato, 5, 1) * 5 + SUBSTR(v_numero_formato, 6, 1) * 4
                      + SUBSTR(v_numero_formato, 7, 1) * 3 + SUBSTR(v_numero_formato, 8, 1) * 2;
            n_pas := 610;
            v_modulo11 := MOD(v_suma, 11);
            n_pas := 611;

            IF v_modulo11 = 0 THEN
               v_digito := 0;
            ELSIF v_modulo11 = 1 THEN
               n_err := 9907256;
               RETURN n_err;
            ELSE
               v_digito := 11 - v_modulo11;
            END IF;

            IF v_digito = SUBSTR(v_numero_formato, 9, 1) THEN
               n_err := 0;
            ELSE
               RETURN 9907256;
            END IF;
         ELSE
            n_err := 9907256;   --Documento incorrecto
            RETURN n_err;
         END IF;
      END IF;

      RETURN n_err;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_obj, n_pas, v_param, SQLCODE || ' ' || SQLERRM);
         RETURN 9902749;   -- Documento incorrecto
   END f_validar_nif_ecu;
END pac_ide_persona;

/

  GRANT EXECUTE ON "AXIS"."PAC_IDE_PERSONA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IDE_PERSONA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IDE_PERSONA" TO "PROGRAMADORESCSI";
