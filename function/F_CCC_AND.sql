--------------------------------------------------------
--  DDL for Function F_CCC_AND
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_CCC_AND" (pncuenta IN VARCHAR2,
                    pnsalida IN OUT VARCHAR2)
RETURN NUMBER authid current_user IS
/**************************************************************************
    F_CCC        Valida una cuenta bancaria y devuelve como parámetros
            el número incluyendo los dígitos de control.
            Devuelve como valor el código del error. 0 si está bien.
    ALLIBMFM
    	    	- adaptación cuentas bancarias andorra
                - Se elimina parámetro dígito de control y su fórmula
                - Se valida formato exclusivo de cada banco
                - Los parámetros de cuenta se cambia por varchar2
                  ya que una entidad incluye letras en la cuenta

                    BANCO MASCTA        LONGITUD
                --------- -------------------
                        1 BB001ZZZZZZ        11
                        2 BBXXXXYYZZZZZZZAA    17
                        3 BB00ZZZZZZ        10
                        3 BB00ZZZZZL        10
                        3 BB00ZZZZLL        10
                        4 BBXXZZZZZZAAA        13
                        5 BB
                        6 BB11ZZZZZZZZ        12
                        6 BB12ZZZZZZZZ        12
                        7 BBXXZZZZZZAAA        13
                        8 BBXXXYYZZZZZZZZ    15

                CPARAME = FORMATBANC
                ------------------------------
                X=Oficina,
                Y=Tipo cta,
                Z=Número cta(num),
                A=Cód.interno(Alfanum),
                L=Letra, (hasta dos letras)
                Otros valores=Valor fijo(hasta 3 valores fijos)

   JFD - 28/09/2007 - Se renombra la función f_ccc de Global Risk por f_ccc_and
**************************************************************************/
  codigo    VARCHAR2(20);
  mascara    VARCHAR2(20);
  w_haY_masc    number;
  w_banco    VARCHAR2(2);
  ofici_d    number;
  ofici_lon    number;
  ofici        VARCHAR2(4);
  tipcta_d    number;
  tipcta_lon    number;
  tipcta    VARCHAR2(2);
  numcta_d    number;
  numcta_lon    number;
  numcta    VARCHAR2(20);
  codint_d    number;
  codint_lon    number;
  codint    VARCHAR2(3);
  letra_1_pos    number;
  letra_1    VARCHAR2(1);
  letra_2_pos    number;
  letra_2    VARCHAR2(1);
  fijo_1_pos    number;
  fijo_1    VARCHAR2(1);
  fijo_2_pos    number;
  fijo_2    VARCHAR2(1);
  fijo_3_pos    number;
  fijo_3    VARCHAR2(1);
  --
  long_codigo    NUMBER;
  long_mascara    NUMBER;
  w_cod_error    NUMBER;
  caracter    VARCHAR2(1);
  var        VARCHAR2(1);
  var_number    NUMBER;
  var_caracter    CHAR(1);
  --
  CURSOR masc IS
  SELECT f.mascta
  FROM formascbancos f
  WHERE f.banco = w_banco;

  BEGIN

--DBMS_OUTPUT.PUT_LINE('Entra en F_CCC');

    codigo := UPPER(pncuenta);
    long_codigo :=LENGTH(codigo);
    w_banco:=SUBSTR(codigo,1,2);
    w_hay_masc := 0;
    w_cod_error := 0;

    BEGIN
          <<L_MASC>>
      FOR m IN masc LOOP
        w_hay_masc := 1;
        mascara := UPPER(m.mascta);
        long_mascara := LENGTH(mascara);
        ofici_d := null;
        ofici_lon := 0;
        ofici := null;
        numcta_d := null;
        numcta_lon := 0;
        numcta := null;
        codint_d := null;
        codint_lon := 0;
        codint := null;
        letra_1_pos := null;
        letra_1 := null;
        letra_2_pos := null;
        letra_2 := null;
        fijo_1_pos := null;
        fijo_1 := null;
        fijo_2_pos := null;
        fijo_2 := null;
        fijo_3_pos := null;
        fijo_3 := null;


        IF long_codigo > long_mascara AND w_banco <> '05' THEN  -- Valida la longitud de la cuenta en base a la máscara
          w_cod_error := 102463;
          GOTO tag_error;
        END IF;

            <<L_CARACTERES>>
        FOR n IN 1..long_mascara LOOP  -- Examina las posiciones de los componentes de la cuenta en base a su máscara
          caracter := SUBSTR(mascara,n,1);
          IF    caracter = 'B' THEN
            null;
          ELSIF caracter = 'X' THEN
            IF ofici_d IS NULL THEN
          ofici_d := n;
          ofici_lon := 1;
        ELSE
          ofici_lon := ofici_lon + 1;
        END IF;
          ELSIF caracter = 'Y' THEN
            IF tipcta_d IS NULL THEN
          tipcta_d := n;
          tipcta_lon := 1;
        ELSE
          tipcta_lon := tipcta_lon + 1;
        END IF;
          ELSIF caracter = 'Z' THEN
            IF numcta_d IS NULL THEN
          numcta_d := n;
          numcta_lon := 1;
        ELSE
          numcta_lon := numcta_lon + 1;
        END IF;
          ELSIF caracter = 'A' THEN
            IF codint_d IS NULL THEN
          codint_d := n;
          codint_lon := 1;
        ELSE
          codint_lon := codint_lon + 1;
        END IF;
          ELSIF caracter = 'L' THEN
            IF letra_1_pos IS NULL THEN
          letra_1_pos := n;
        ELSE
          letra_2_pos := n;
        END IF;
          ELSE
            IF fijo_1_pos IS NULL THEN
          fijo_1_pos := n;
        ELSIF fijo_2_pos IS NULL THEN
          fijo_2_pos := n;
        ELSE
          fijo_3_pos := n;
        END IF;
          END IF;
        END LOOP L_CARACTERES;


        IF ofici_d IS NOT NULL THEN  -- Extrae el contenido de cada componente de la cuenta
          ofici := SUBSTR(codigo, ofici_d, ofici_lon);
          BEGIN
            SELECT 'x' INTO var
            FROM oficinas o
            WHERE o.cbanco = w_banco AND o.coficin = ofici;
          EXCEPTION
            WHEN OTHERS THEN
            w_cod_error := 102445;
            GOTO tag_error;
          END;
        END IF;



        IF tipcta_d IS NOT NULL THEN
           tipcta := SUBSTR(codigo, tipcta_d, tipcta_lon);
           var_number := tipcta;
        END IF;


        IF numcta_d IS NOT NULL THEN
           numcta := SUBSTR(codigo, numcta_d, numcta_lon);
           var_number := numcta;
        END IF;


        IF codint_d IS NOT NULL THEN
           codint := SUBSTR(codigo, codint_d, codint_lon);
        END IF;


        IF letra_1_pos IS NOT NULL THEN
           letra_1 := SUBSTR(codigo, letra_1_pos, 1);
           var_caracter := letra_1;
        END IF;


        IF letra_2_pos IS NOT NULL THEN
           letra_2 := SUBSTR(codigo, letra_2_pos, 1);
           var_caracter := letra_2;
        END IF;


        IF fijo_1_pos IS NOT NULL THEN
           fijo_1 := SUBSTR(codigo, fijo_1_pos, 1);
           IF fijo_1 <> SUBSTR(mascara, fijo_1_pos, 1) THEN
             w_cod_error := 102494;
             GOTO tag_error;
           END IF;
        END IF;


        IF fijo_2_pos IS NOT NULL THEN
           fijo_2 := SUBSTR(codigo, fijo_2_pos, 1);
           IF fijo_2 <> SUBSTR(mascara, fijo_2_pos, 1) THEN
             w_cod_error := 102494;
             GOTO tag_error;
           END IF;
        END IF;


        IF fijo_3_pos IS NOT NULL THEN
           fijo_3 := SUBSTR(codigo, fijo_3_pos, 1);
           IF fijo_3 <> SUBSTR(mascara, fijo_3_pos, 1) THEN
             w_cod_error := 102494;
             GOTO tag_error;
           END IF;
        END IF;
            w_cod_error := 0;
        EXIT;
        <<tag_error>>
        null;
      END LOOP L_MASC;


    EXCEPTION
      WHEN OTHERS THEN
      RETURN 102494;
    END;

    IF w_hay_masc = 0 THEN

      pnsalida := null;
      RETURN 102704;
    ELSE

      IF w_cod_error = 0 THEN

--DBMS_OUTPUT.PUT_LINE('F_CCC 330 pncuenta='||pncuenta);

        pnsalida:=pncuenta;

--DBMS_OUTPUT.PUT_LINE('Sale de F_CCC');

        RETURN 0;
      ELSE

        RETURN w_cod_error;
      END IF;
    END IF;

END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_CCC_AND" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_CCC_AND" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_CCC_AND" TO "PROGRAMADORESCSI";
