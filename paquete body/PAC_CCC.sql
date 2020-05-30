--------------------------------------------------------
--  DDL for Package Body PAC_CCC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_CCC" AS

/******************************************************************************
   NOMBRE:       PAC_CCC
   PROPÓSITO:  Funciones para realizar la validación de las cuentas bancarias

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        13/05/2010   AVT             1. Creación del package.
   2.0        27/10/2011   JGR             2. 0019793: LCOL_A001-Formato de cuentas bancarias y tarjetas de credito
   3.0        27/10/2011   JGR             0019793: LCOL_A001-Formato de cuentas bancarias y tarjetas de credito
   4.0        14/01/2012   JMF             0020761 LCOL_A001- Quotes targetes
   5.0        19/08/2014   XBA             Añadimos el ctipban = 215. Validación de 31 para IBAN de Malta
   6.0        06/11/2015   JCP	   Se cambio la funcion f_estarjeta
******************************************************************************/

	FUNCTION f_ccc_esp(
			pncuenta	IN	NUMBER,
			pncontrol	IN	OUT NUMBER,
			pnsalida	IN	OUT NUMBER
	) RETURN NUMBER
	IS
	  /**************************************************************************
	      F_CCC        Valida una cuenta bancaria y devuelve como parámetros
	              el número incluyendo los dígitos de control.
	              Devuelve como valor el código del error. 0 si está bien.
	      ALLIBMFM
	      f_ccc pasa a ser f_ccc_esp validación de cuentas españolas
	      está función será llamada por f_ccc.
	  **************************************************************************/
	  codigo VARCHAR2(30);
	  banco  VARCHAR2(4);
	  ofici  VARCHAR2(4);
	  contr  VARCHAR2(2);
	  cuent  VARCHAR2(10);
	  longi  NUMBER;
	  total  NUMBER;
	  resto  NUMBER;
	  digi1  NUMBER;
	  digi2  NUMBER;
	BEGIN
	    codigo:=to_char(pncuenta);

	    longi:=length(codigo);

	    IF longi>20 THEN
	      RETURN 102492; /* Error número demasiado largo*/
	    ELSIF pncuenta IS NULL THEN
	      RETURN 1000011; /* La longitud de la cuenta no coincide con la de su tipo.*/
	    ELSE
	      codigo:=lpad(codigo, 20, '0'); -- Rellena de 0's hasta 20

	      /* Troceamos el código de cuenta*/
	      banco:=substr(codigo, 1, 4);

	      ofici:=substr(codigo, 5, 4);

	      contr:=substr(codigo, 9, 2);

	      cuent:=substr(codigo, 11, 10);

	      /* Cálculo del primer dígito de control*/
	      total:=to_number(substr(banco, 1, 1))*4+to_number(substr(banco, 2, 1))*8+to_number(substr(banco, 3, 1))*5+to_number(substr(banco, 4, 1))*10+to_number(substr(ofici, 1, 1))*9+to_number(substr(ofici, 2, 1))*7+to_number(substr(ofici, 3, 1))*3+to_number(substr(ofici, 4, 1))*6;

	      resto:=MOD(total, 11);

	      digi1:=11;

	      LOOP
	          EXIT WHEN digi1<10;

	          digi1:=11-resto;

	          resto:=digi1;
	      END LOOP;

	      /* Cálculo del segundo dígito de control*/
	      total:=to_number(substr(cuent, 1, 1))*1+to_number(substr(cuent, 2, 1))*2+to_number(substr(cuent, 3, 1))*4+to_number(substr(cuent, 4, 1))*8+to_number(substr(cuent, 5, 1))*5+to_number(substr(cuent, 6, 1))*10+to_number(substr(cuent, 7, 1))*9+to_number(substr(cuent, 8, 1))*7+to_number(substr(cuent, 9, 1))*3+to_number(substr(cuent, 10, 1))*6;

	      resto:=MOD(total, 11);

	      digi2:=11;

	      LOOP
	          EXIT WHEN digi2<10;

	          digi2:=11-resto;

	          resto:=digi2;
	      END LOOP;

	      /* Código de control*/
	      pncontrol:=to_number(digi1
	                           || digi2);

	      /* Concatenamos la cadena completa de dígitos*/
	      pnsalida:=to_number(banco
	                          || ofici
	                          || digi1
	                          || digi2
	                          || cuent);

	      IF contr<>pncontrol THEN
	        IF contr=0 THEN
	          RETURN 102493; /* Error suave (Introduza los dígitos)*/
	        ELSE
	          RETURN 102494; /* Error grave (Código cta. erróneo)*/
	        END IF;
	      ELSE
	        RETURN 0;
	      END IF;
	    END IF;
	END;
	FUNCTION f_valida_iban(
			pcodigo	IN	VARCHAR2
	) RETURN NUMBER
	IS
	  /***********************************************************************
	      02/2007  MCA
	      F_VALIDA_IBAN: Valida el código IBAN entrado por parámetro
	      Devuelve 1 si es correcto.

	      JFD 27/09/2007 para igualar salida de datos con f_ccc si no hay error
	      devuelve 0 en caso contrario devuelve un literal.

	      JFD 08/10/2007  Mofificamos la función para que valide la procedencia
	      del código y la longitud.
	  ***********************************************************************/
	  vresto     NUMBER;
	  vpos       VARCHAR2(2);
	  vcodigo    VARCHAR2(100);
	  vcodi      NUMBER;
	  vinicio    VARCHAR2(4);
	  vresultado VARCHAR2(100);
	  vlong      NUMBER;
	  vfinal     VARCHAR2(30);
	  v_detccc   NUMBER;
	BEGIN
	    SELECT length(pcodigo)
	      INTO vlong
	      FROM dual;

	    SELECT substr(pcodigo, 1, 4)
	      INTO vinicio
	      FROM dual;

	    SELECT substr(pcodigo, 5)
	      INTO vfinal
	      FROM dual;

	    vcodigo:=trim(vfinal)
	             || trim(vinicio);

	    /* JFD 08/10/2007 -------------------------------------------------------*/
	    /*XVILA: Bug 5553*/
	    /*
	    if vlong <> f_parinstalacion_n('IBAN') then
	         RETURN 180755; -- no coincideixen les longituds
	    end if;

	    SELECT SUBSTR(pcodigo,1,2) INTO vpos FROM DUAL;

	    if vpos <> f_parinstalacion_t('IBAN') then
	        RETURN 102494; -- El código de cuenta es erróneo
	    end if;

	    vpos := null;
	    */
	    SELECT longitud
	      INTO v_detccc
	      FROM dettipos_cuenta
	     WHERE idpais=upper(substr(pcodigo, 1, 2)) AND
	           ctipban IN(2, 215);

	    IF vlong<>v_detccc THEN
	      RETURN 180755; /* no coincideixen les longituds*/
	    END IF;

	    /*XVILA: Bug 5553*/
	    /*-----------------------------------------------------------------------*/
	    FOR i IN 1 .. vlong LOOP
	        vpos:=rtrim(upper(substr(vcodigo, i, 1)));

	        IF vpos IS NOT NULL THEN
	          IF ascii(vpos)>=65 AND
	             ascii(vpos)<=90 THEN /*LETRA*/
	            SELECT ascii(upper(vpos))-55
	              INTO vpos
	              FROM dual;
	          END IF;

	          vresultado:=vresultado
	                      || vpos;
	        END IF;
	    END LOOP;

	    SELECT MOD(vresultado, 97)
	      INTO vresto
	      FROM dual;

	    IF vresto=1 THEN
	      RETURN 0;
	    ELSE
	      RETURN 102494; /* El código de cuenta es erróneo*/
	    END IF;
	EXCEPTION
	  WHEN OTHERS THEN
	             RETURN 102494; /* El código de cuenta es erróneo*/
	END;
	FUNCTION f_ccc_and(
			pncuenta	IN	VARCHAR2,
			pnsalida	IN	OUT VARCHAR2
	) RETURN NUMBER
	IS
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
	  codigo       VARCHAR2(20);
	  mascara      VARCHAR2(20);
	  w_hay_masc   NUMBER;
	  w_banco      VARCHAR2(2);
	  ofici_d      NUMBER;
	  ofici_lon    NUMBER;
	  ofici        VARCHAR2(4);
	  tipcta_d     NUMBER;
	  tipcta_lon   NUMBER;
	  tipcta       VARCHAR2(2);
	  numcta_d     NUMBER;
	  numcta_lon   NUMBER;
	  numcta       VARCHAR2(20);
	  codint_d     NUMBER;
	  codint_lon   NUMBER;
	  codint       VARCHAR2(3);
	  letra_1_pos  NUMBER;
	  letra_1      VARCHAR2(1);
	  letra_2_pos  NUMBER;
	  letra_2      VARCHAR2(1);
	  fijo_1_pos   NUMBER;
	  fijo_1       VARCHAR2(1);
	  fijo_2_pos   NUMBER;
	  fijo_2       VARCHAR2(1);
	  fijo_3_pos   NUMBER;
	  fijo_3       VARCHAR2(1);
	  /**/
	  long_codigo  NUMBER;
	  long_mascara NUMBER;
	  w_cod_error  NUMBER;
	  caracter     VARCHAR2(1);
	  var          VARCHAR2(1);
	  var_number   NUMBER;
	  var_caracter CHAR(1);

	  /**/
	  CURSOR masc IS
	    SELECT f.mascta
	      FROM formascbancos f
	     WHERE f.banco=w_banco;
	BEGIN
	    codigo:=upper(pncuenta);

	    long_codigo:=length(codigo);

	    w_banco:=substr(codigo, 1, 2);

	    w_hay_masc:=0;

	    w_cod_error:=0;

	    BEGIN
	        <<l_masc>>
	        FOR m IN masc LOOP
	            w_hay_masc:=1;

	            mascara:=upper(m.mascta);

	            long_mascara:=length(mascara);

	            ofici_d:=NULL;

	            ofici_lon:=0;

	            ofici:=NULL;

	            numcta_d:=NULL;

	            numcta_lon:=0;

	            numcta:=NULL;

	            codint_d:=NULL;

	            codint_lon:=0;

	            codint:=NULL;

	            letra_1_pos:=NULL;

	            letra_1:=NULL;

	            letra_2_pos:=NULL;

	            letra_2:=NULL;

	            fijo_1_pos:=NULL;

	            fijo_1:=NULL;

	            fijo_2_pos:=NULL;

	            fijo_2:=NULL;

	            fijo_3_pos:=NULL;

	            fijo_3:=NULL;

	            IF long_codigo>long_mascara AND
	               w_banco<>'05' THEN -- Valida la longitud de la cuenta en base a la máscara
	              w_cod_error:=102463;
	            END IF;

	            IF w_cod_error=0 THEN
	              FOR n IN 1 .. long_mascara LOOP /* Examina las posiciones de los componentes de la cuenta en base a su máscara*/
	                  caracter:=substr(mascara, n, 1);

	                  IF caracter='B' THEN
	                    NULL;
	                  ELSIF caracter='X' THEN
	                    IF ofici_d IS NULL THEN
	                      ofici_d:=n;

	                      ofici_lon:=1;
	                    ELSE
	                      ofici_lon:=ofici_lon+1;
	                    END IF;
	                  ELSIF caracter='Y' THEN
	                    IF tipcta_d IS NULL THEN
	                      tipcta_d:=n;

	                      tipcta_lon:=1;
	                    ELSE
	                      tipcta_lon:=tipcta_lon+1;
	                    END IF;
	                  ELSIF caracter='Z' THEN
	                    IF numcta_d IS NULL THEN
	                      numcta_d:=n;

	                      numcta_lon:=1;
	                    ELSE
	                      numcta_lon:=numcta_lon+1;
	                    END IF;
	                  ELSIF caracter='A' THEN
	                    IF codint_d IS NULL THEN
	                      codint_d:=n;

	                      codint_lon:=1;
	                    ELSE
	                      codint_lon:=codint_lon+1;
	                    END IF;
	                  ELSIF caracter='L' THEN
	                    IF letra_1_pos IS NULL THEN
	                      letra_1_pos:=n;
	                    ELSE
	                      letra_2_pos:=n;
	                    END IF;
	                  ELSE
	                    IF fijo_1_pos IS NULL THEN
	                      fijo_1_pos:=n;
	                    ELSIF fijo_2_pos IS NULL THEN
	                      fijo_2_pos:=n;
	                    ELSE
	                      fijo_3_pos:=n;
	                    END IF;
	                  END IF;
	              END LOOP;

	              IF ofici_d IS NOT NULL THEN /* Extrae el contenido de cada componente de la cuenta*/
	                ofici:=substr(codigo, ofici_d, ofici_lon);

	                BEGIN
	                    SELECT 'x'
	                      INTO var
	                      FROM oficinas o
	                     WHERE o.cbanco=w_banco AND
	                           o.coficin=ofici;
	                EXCEPTION
	                    WHEN OTHERS THEN
	                      w_cod_error:=102445;
	                END;
	              END IF;

	              IF w_cod_error=0 THEN
	                IF tipcta_d IS NOT NULL THEN
	                  tipcta:=substr(codigo, tipcta_d, tipcta_lon);

	                  var_number:=tipcta;
	                END IF;

	                IF numcta_d IS NOT NULL THEN
	                  numcta:=substr(codigo, numcta_d, numcta_lon);

	                  var_number:=numcta;
	                END IF;

	                IF codint_d IS NOT NULL THEN
	                  codint:=substr(codigo, codint_d, codint_lon);
	                END IF;

	                IF letra_1_pos IS NOT NULL THEN
	                  letra_1:=substr(codigo, letra_1_pos, 1);

	                  var_caracter:=letra_1;
	                END IF;

	                IF letra_2_pos IS NOT NULL THEN
	                  letra_2:=substr(codigo, letra_2_pos, 1);

	                  var_caracter:=letra_2;
	                END IF;

	                IF fijo_1_pos IS NOT NULL THEN
	                  fijo_1:=substr(codigo, fijo_1_pos, 1);

	                  IF fijo_1<>substr(mascara, fijo_1_pos, 1) THEN
	                    w_cod_error:=102494;
	                  END IF;
	                END IF;

	                IF w_cod_error=0 THEN
	                  IF fijo_2_pos IS NOT NULL THEN
	                    fijo_2:=substr(codigo, fijo_2_pos, 1);

	                    IF fijo_2<>substr(mascara, fijo_2_pos, 1) THEN
	                      w_cod_error:=102494;
	                    END IF;
	                  END IF;

	                  IF w_cod_error=0 THEN
	                    IF fijo_3_pos IS NOT NULL THEN
	                      fijo_3:=substr(codigo, fijo_3_pos, 1);

	                      IF fijo_3<>substr(mascara, fijo_3_pos, 1) THEN
	                        w_cod_error:=102494;
	                      END IF;
	                    END IF;

	                    /*w_cod_error := 0;*/
	                    IF w_cod_error=0 THEN
	                      EXIT;
	                    END IF;
	                  END IF;
	                END IF;
	              END IF;
	            END IF;

	            /*<<tag_error>>*/
	            NULL;
	        END LOOP l_masc;
	    EXCEPTION
	        WHEN OTHERS THEN
	          RETURN 102494;
	    END;

	    IF w_hay_masc=0 THEN
	      pnsalida:=NULL;

	      RETURN 102704;
	    ELSE
	      IF w_cod_error=0 THEN
	        pnsalida:=pncuenta;

	        RETURN 0;
	      ELSE
	        RETURN w_cod_error;
	      END IF;
	    END IF;
	END;
	FUNCTION f_ccc_bel(
			pncuenta	IN	VARCHAR2,
			pnsalida	IN	OUT VARCHAR2
	) RETURN NUMBER
	IS
	  codigo VARCHAR2(30);
	  cuent  VARCHAR2(10);
	  contr  VARCHAR2(2);
	  longi  NUMBER;
	  result NUMBER;
	BEGIN
	    longi:=length(pncuenta);

	    /*BUG 5553-12/02/2009-JTS-Se canvia el >12 por !=12*/
	    IF longi!=12 THEN
	      pnsalida:=NULL; /* Longitud incorrecta*/

	      RETURN 800513;
	    ELSE
	      codigo:=lpad(pncuenta, 12, '0'); -- Rellena de 0's hasta 12

	      cuent:=substr(codigo, 1, 10);

	      contr:=substr(codigo, 11, 2);

	      result:=trunc(to_number(cuent)/97)*97;

	      result:=to_number(cuent)-result;

	      /*BUG11234-XVM-22092009 Inici*/
	      IF result=0 THEN
	        result:=97;
	      END IF;

	      /*BUG11234-XVM-22092009 Fi*/
	      IF result<>contr THEN
	        pnsalida:=NULL;

	        RETURN 102494;
	      END IF;

	      pnsalida:=0;

	      RETURN 0;
	    END IF;
	END f_ccc_bel;
	FUNCTION f_ccc_ang(
			pncuenta	IN	VARCHAR2,
			pnsalida	IN	OUT VARCHAR2
	) RETURN NUMBER
	IS
	  /**************************************************************************
	     F_CCC    Valida una cuenta bancaria y devuelve como parametros
	           el numero incluyendo los digitos de control.
	           Devuelve como valor el codigo del error. 0 si esta bien.

	     14502 12-05-2010 AVT - adaptación cuentas bancarias Angola basada en la
	                            f_ccc de Asphales
	  **************************************************************************/
	  codigo VARCHAR2(30);
	  pais   VARCHAR2(4);
	  banco  VARCHAR2(4);
	  ofici  VARCHAR2(4);
	  ncli   VARCHAR2(8);
	  nconta VARCHAR2(2);
	  nseq   VARCHAR2(1);
	  checkd VARCHAR2(2);
	  longi  NUMBER;
	  total  NUMBER;
	  resto  NUMBER;
	  digi1  NUMBER;
	  digi2  NUMBER;
	BEGIN
	    codigo:=to_char(pncuenta);

	    longi:=length(codigo);

	    /*BUG 18312 - 27/04/2011 - JRB - Se permite cualquier número y letra mientras no supere la longitud de 20*/
	    IF longi>20 THEN
	      RETURN 102492; /* Error numero demasiado largo*/
	    ELSE
	      /*codigo := LPAD(codigo, 25, '0');   -- Rellena de 0's hasta 25
	      -- Troceamos el codigo de cuenta
	      pais := SUBSTR(codigo, 1, 4);
	      banco := SUBSTR(codigo, 5, 4);
	      ofici := SUBSTR(codigo, 9, 4);
	      ncli := SUBSTR(codigo, 13, 8);
	      nconta := SUBSTR(codigo, 22, 2);
	      nseq := SUBSTR(codigo, 24, 1);
	      checkd := SUBSTR(codigo, 25, 2);
	      -- Calculo del primer digito de control
	      --pncontrol := checkd;
	      -- Concatenamos la cadena completa de digitos
	      pnsalida := pais || banco || ofici || ncli || nconta || nseq || checkd;*/
	      pnsalida:=pncuenta;

	      RETURN 0;
	    END IF;
	END f_ccc_ang;
	FUNCTION f_ccc_col_bco(
			pctipban	IN	VARCHAR2,
			pncuenta	IN	VARCHAR2,
			pnsalida	IN	OUT VARCHAR2
	) RETURN NUMBER
	IS
	  /**************************************************************************
	      F_CCC_COL_BCO  Valida una cuenta bancaria Colombiana y devuelve como parámetros el número

	      2.0  27/10/2011  JGR  2. 0019793: LCOL_A001-Formato de cuentas bancarias y tarjetas de credito

	      Devuelve como valor el código del error. 0 si está bien.
	  **************************************************************************/
	  longi     NUMBER;
	  ventidad  NUMBER;
	  vposenti  NUMBER;
	  vlongenti NUMBER;
	  vlongitud NUMBER;
	BEGIN
	    longi:=length(pncuenta);

	    BEGIN
	        SELECT pos_entidad,long_entidad,longitud
	          INTO vposenti, vlongenti, vlongitud
	          FROM tipos_cuenta
	         WHERE ctipban=pctipban;
	    EXCEPTION
	        WHEN no_data_found THEN
	          RETURN 180756; /* La longitud o la máscara del tipo de cuenta no está informado.*/
	        WHEN OTHERS THEN
	          RETURN 180928; /* Error al buscar la descripción de tipo o formato de cuenta ccc.*/
	    END;

	    IF vposenti IS NOT NULL THEN BEGIN
	          ventidad:=to_number(substr(pncuenta, vposenti, vlongenti));
	      EXCEPTION
	          WHEN OTHERS THEN
	            RETURN 102494; /* El código de cuenta es erróneo*/
	      END;
	    END IF;

	    IF ventidad IS NOT NULL THEN BEGIN
	          SELECT cbanco
	            INTO ventidad
	            FROM bancos
	           WHERE cbanco=ventidad;
	      EXCEPTION
	          WHEN OTHERS THEN
	            RETURN 102704; /* Banco no encontrado en la tabla BANCOS*/
	      END;
	    END IF;

	    /*BUG 18312 - 27/04/2011 - JRB - Se permite cualquier número y letra mientras no supere la longitud de 20*/
	    IF longi!=vlongitud THEN
	      RETURN 180755; /* La longitud de la cuenta no coincide con la de su tipo.*/
	    ELSE
	      pnsalida:=pncuenta;

	      RETURN 0;
	    END IF;
	END f_ccc_col_bco;
	FUNCTION f_ccc_col_tar(
			pctipban	IN	VARCHAR2,
			pncuenta	IN	VARCHAR2,
			pnsalida	IN	OUT VARCHAR2
	) RETURN NUMBER
	IS
	  /**************************************************************************
	      F_CCC_COL_TAR  Valida una tarjetas bancaria Colombiana y devuelve como parámetros el número

	      2.0  27/10/2011  JGR  2. 0019793: LCOL_A001-Formato de cuentas bancarias y tarjetas de credito

	      Devuelve como valor el código del error. 0 si está bien.
	  **************************************************************************/
	  vpeso         NUMBER;
	  vdigito       NUMBER;
	  vsuma         NUMBER;
	  vcontador     NUMBER;
	  longi         NUMBER;
	  vlongitud     NUMBER;
	  vnuevatarjeta VARCHAR2(100);
	  vcaracter     VARCHAR2(1);
	BEGIN
	    /* PENDIENTE DE INCOPORAR CÓDIGOS CUANDO LIBERTY NOS FACILITE LOS ALGORITMOS DE VALIDACIÓN.*/
	    longi:=length(pncuenta);

	    BEGIN
	        SELECT longitud
	          INTO vlongitud
	          FROM tipos_cuenta
	         WHERE ctipban=pctipban;
	    EXCEPTION
	        WHEN no_data_found THEN
	          RETURN 180756; /* La longitud o la máscara del tipo de cuenta no está informado.*/
	        WHEN OTHERS THEN
	          RETURN 180928; /* Error al buscar la descripción de tipo o formato de cuenta ccc.*/
	    END;

	    IF longi!=vlongitud AND
	       vlongitud IS NOT NULL THEN
	      RETURN 180755; /* La longitud de la cuenta no coincide con la de su tipo.*/
	    ELSIF pctipban=73 THEN
	      RETURN 0; /*> Devolver 0 para desactivar el control.*/

	    /* Se ha desactivado este control de números de tarjeta porque es el se hace servir aquí.*/
	      /* No sabemos si es el mismo que se hace servir en Colombia.*/
	      vpeso:=0;

	      vdigito:=0;

	      vsuma:=0;

	      /* Reemplazar cualquier no digito por una cadena vacía*/
	      FOR vcontador IN 1 .. length(pncuenta) LOOP
	          vcaracter:=substr(pncuenta, vcontador, 1);

	          BEGIN
	              vcaracter:=to_number(vcaracter);

	              vnuevatarjeta:=vnuevatarjeta
	                             || vcaracter;
	          EXCEPTION
	              WHEN OTHERS THEN
	                NULL;
	          END;
	      END LOOP;

	      /* Si el número de dígitos es par el primer peso es 2, de lo contrario es 1*/
	      IF MOD(length(vnuevatarjeta), 2)=0 THEN
	        vpeso:=2;
	      ELSE
	        vpeso:=1;
	      END IF;

	      FOR vcontador IN 1 .. length(vnuevatarjeta) LOOP
	          vdigito:=substr(vnuevatarjeta, vcontador, 1)*vpeso;

	          IF vdigito>9 THEN
	            vdigito:=vdigito-9;
	          END IF;

	          vsuma:=vsuma+vdigito;

	          /* Cambiar peso para el siguiente dígito*/
	          IF vpeso=2 THEN
	            vpeso:=1;
	          ELSE
	            vpeso:=2;
	          END IF;
	      END LOOP;

	      pnsalida:=pncuenta;

	      /* Devolver verdadero si la suma es divisible por 10*/
	      IF MOD(vsuma, 10)=0 THEN
	        RETURN 0;
	      ELSE
	        RETURN 102494; /* El código de cuenta es erróneo*/
	      END IF;
	    ELSE
	      RETURN 0;
	    END IF;
	END f_ccc_col_tar;

	/**************************************************************************
	    f_esTarjeta  Nos dice si el tipo de cuenta es tarjeta de credito o no.
	    Devuelve como valor 1=Tarjeta o 0=Cuenta o resto de casos.
	-- BUG 0020761 - 14/01/2012 - JMF
	**************************************************************************/
	FUNCTION f_estarjeta(
			p_ctipcc	IN	NUMBER,
			p_ctipban	IN	NUMBER
	) RETURN NUMBER
	IS
	  n_ret    NUMBER;
	  v_ctipcc NUMBER; /*BUG  35712/c217540*/
	BEGIN
	    IF p_ctipcc IS NOT NULL THEN
	      v_ctipcc:=p_ctipcc;
	    ELSIF p_ctipban IS NOT NULL THEN
	      SELECT max(ctipcc)
	        INTO v_ctipcc
	        FROM tipos_cuenta
	       WHERE ctipban=p_ctipban;
	    END IF;

	    IF v_ctipcc IN(4, 5, 6, 7, 9) THEN
	      n_ret:=1;
	    ELSE
	      n_ret:=0;
	    END IF;

	    RETURN n_ret;
	END f_estarjeta;

END pac_ccc;

/

  GRANT EXECUTE ON "AXIS"."PAC_CCC" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_CCC" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_CCC" TO "PROGRAMADORESCSI";
