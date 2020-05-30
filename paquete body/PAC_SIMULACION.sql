--------------------------------------------------------
--  DDL for Package Body PAC_SIMULACION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_SIMULACION" IS


  FUNCTION F_SIMULACION_APOR_PP ( PFNACIMI1 IN DATE,
                             PFNACIMI2 IN DATE,
                             PSEXO1 IN NUMBER,
                             PSEXO2 IN NUMBER,
						     PFJUBILA IN DATE,
						     PEDADJUBILA IN NUMBER,
						     PNOMBRE1 IN VARCHAR2,
						     PNOMBRE2 IN VARCHAR2,
                             PPERIODICA IN NUMBER DEFAULT 0,
                             PEXTRA IN NUMBER DEFAULT 0,
                             PINTERES IN NUMBER DEFAULT 0,
                             PREVALI IN NUMBER DEFAULT 0,
                             PINTERRENI IN NUMBER DEFAULT 0,
                             PREVALREN IN NUMBER DEFAULT 0,
                             PREVERSION IN NUMBER DEFAULT 0,
                             PPERCIERTO IN NUMBER DEFAULT 0,
                             PHASTA OUT NUMBER ) RETURN NUMBER IS

  -- JAMR - Feb 03 - Cálculo de los periodos de simulación.
  -- Estos cálculos han sido elaborados en función de la hoja
  -- excel entregada por Sa Nostra INTINTERNET2003.XLS
  -- por lo que los nombres de las variables han sido tomados
  -- como las casillas dentro de la hoja.

  B2 NUMBER := NVL(PINTERES,0)  / 100; -- > Hipótesis interés capital / Renta
  A3 NUMBER := 1 / ( 1 + B2 );        -- > v
  B4 NUMBER := 1 + B2;								-- > ( 1 + i )
  K1 NUMBER := POWER(B4,(1/12))-1;    -- > Interés mes
  K2 NUMBER := 1 /(1 + K1);						-- > v MES
  K3 NUMBER;													-- > V.A.rta MES
  J6 NUMBER;                          -- > Cálculo del valor final
  AC14 NUMBER := (TRUNC(F_Sysdate) - TRUNC(PFJUBILA))/365.247*-1 ;   -- > Diferimiento
  AC17 NUMBER := PREVALI / 100;         -- > % Revalorización
  V1 NUMBER   := 0;                   -- > Calculo valor final aportaciones realizadas
  W1 NUMBER   := 0;                   -- > Calculo valor final aportaciones realizadas
  X1 NUMBER   := 0;                   -- > Calculo valor final aportaciones realizadas
  X2 NUMBER   := 0;                   -- > Calculo valor final aportaciones realizadas
  X3 NUMBER   := 0;                   -- > Calculo valor final aportaciones realizadas
  X4 NUMBER   := 0;                   -- > Calculo valor final aportaciones realizadas
  X5 NUMBER   := 0;                   -- > Calculo valor final aportaciones realizadas
  X6 NUMBER   := 0;                   -- > Calculo valor final aportaciones realizadas
  X7 NUMBER   := 0;                   -- > Calculo valor final aportaciones realizadas
  AK1 NUMBER   := 0;                   -- > Calculo valor final aportaciones realizadas
  AK2 NUMBER   := 0;                   -- > Calculo valor final aportaciones realizadas
  AK3 NUMBER   := 0;                   -- > Calculo valor final aportaciones realizadas
  V9  NUMBER   := 0;                   -- > Calculo valor final aportaciones realizadas
  AI8 NUMBER   := 0;                   -- > Aportaciones reales
  V17 NUMBER   := 0;                   -- > Aportaciones reales
  V18 NUMBER   := 0;                   -- > Aportaciones reales
  V19 NUMBER   := 0;                   -- > Aportaciones reales
  W18 NUMBER   := 0;                   -- > Aportaciones reales
  W19 NUMBER   := 0;                   -- > Aportaciones reales
  BI33 NUMBER  := 0;									 -- > Renta mensual Vitalicia
  AM9  NUMBER := ROUND(( PFJUBILA - PFNACIMI1) / 365.247,0); --> Edad jubilación primer titular
  AM10 NUMBER := ROUND(( PFJUBILA - PFNACIMI2) / 365.247,0); --> Edad jubilación segundo titular
  TRAMO1 NUMBER; --> Tramo para el titular 1
  TRAMO2 NUMBER; --> Tramo para el titualr 2
  AQ4 NUMBER   := 0;                   -- > VALOR RTA S/X(1):
  AR4 NUMBER   := 0;									 -- > VALOR RTA S/X(1):
  AQ5 NUMBER   := 0;                   -- > VALOR RTA S/X(2):
  AR5 NUMBER   := 0;									 -- > VALOR RTA S/X(2):
  AQ6 NUMBER   := 0;                   -- > VALOR RTA S/XX):
  AR6 NUMBER   := 0;									 -- > VALOR RTA S/XX:
  AQ9 NUMBER   := 0;									 -- > VALOR RENTA 1ER TITULAR
  AR9 NUMBER   := 0;									 -- > VALOR RENTA 1ER TITULAR
  AS9 NUMBER   := 0;									 -- > VALOR RENTA 1ER TITULAR
  AT9 NUMBER   := 0;									 -- > VALOR RENTA 1ER TITULAR
  AQ7 NUMBER   := 0;									 -- > VALOR RENTA DESEADA
  AR7 NUMBER   := 0;									 -- > VALOR RENTA DESEADA
  AS7 NUMBER   := 0;									 -- > VALOR RENTA DESEADA
  AT7 NUMBER   := 0;									 -- > VALOR RENTA DESEADA
  AI71 NUMBER  := 0; --> RENTA INC. MES.

  PORCENINTER NUMBER;



BEGIN

	--**************************************************************
  --**************************************************************
  -- ****************** aportaciones *****************************
  --**************************************************************
  --**************************************************************

	DELETE DETSIMULAPP WHERE SESION = USERENV('SESSIONID');
	DELETE SIMULAPP WHERE SESION = USERENV('SESSIONID');

	INSERT INTO SIMULAPP ( SESION, NOMBRE1, FNACIMI1, NOMBRE2, FNACIMI2  )
	VALUES ( USERENV('SESSIONID') , PNOMBRE1 , PFNACIMI1,PNOMBRE2, PFNACIMI2 ) ;

	Pac_Simulacion.Tabla.DELETE;

	IF PINTERES = 0 THEN
	 PORCENINTER := 0.000001;
	   B2  := NVL(PORCENINTER,0)  / 100; -- > Hipótesis interés capital / Renta
	ELSE
	PORCENINTER := PINTERES;
	END IF;

  -- Inicializamos mas variables
  -- K3 --> V.A.rta MES
--  SELECT DECODE(K1,0,12,(1-POWER(K2,12)) / K1 * ( 1 + K1 ) )

  SELECT DECODE(K1,0,12,(1-POWER(K2,12)) / K1 * ( 1 + K1 ) )
  INTO K3 FROM DUAL;



  -- J6 --> Cálculo del valor final
  J6 := ( 1 + AC17 );

  -- Iniciamos el bucle para calcular los importes anuales.


  FOR EJER IN 1.. CEIL(months_between (TRUNC(PFJUBILA), TRUNC(F_Sysdate)) / 12) LOOP
--  FOR EJER IN 1.. ( TO_NUMBER(TO_CHAR(PFJUBILA,'YYYY')) - TO_NUMBER(TO_CHAR(F_Sysdate,'YYYY')) )  LOOP

		      Pac_Simulacion.Tabla(Ejer).EJERCICIO := EJER;

		      IF EJER  < AC14 THEN

		      	-- Vamos a calcular I8_(1...N) --> VFINAL

		      	IF B4 = J6 THEN


		      			Pac_Simulacion.Tabla(Ejer).VFINAL := EJER * K3 * ( POWER( B4, EJER)) ;

		      	ELSE


		      		  Pac_Simulacion.Tabla(Ejer).VFINAL :=

		      		         ( ( (
		      		               (
		      		                   (
		      		                     POWER(B4,EJER) - POWER(J6,EJER )
		      		                    )
		      		                    / ( 1 + B2 - J6 )
		      		               )    		               /		      		               POWER(B4, EJER)
		      		             )
		      		             *
		      		             B4
		      		            )
		      		            *
		      		            POWER ( B4, EJER  )
		      		          )
		      		          *
		      		          K3  ;



		      	END IF;

				insert into informes_err values (ejer || ' - ' || Pac_Simulacion.Tabla(Ejer).VFINAL);

		      	Pac_Simulacion.Tabla(Ejer).PERIODICA := Pac_Simulacion.Tabla(Ejer).VFINAL * PPERIODICA - PPERIODICA;


		      ELSE
		      	Pac_Simulacion.Tabla(Ejer).VFINAL := 0;
		      END IF;

		      -- Calculo de las aportaciones mensuales
		      Pac_Simulacion.Tabla(Ejer).FECHA := ADD_MONTHS(F_Sysdate,(EJER*12)); -- -12);
 	          Pac_Simulacion.Tabla(Ejer).MENSUAL := ( PPERIODICA * 12 * POWER( J6 , ( EJER - 1 ) ) / 12 );

          --	IF EJER = 1 THEN
		      --	   MESSAGE ( Pac_Simulacion.Tabla(Ejer).FECHA );pause;
		      --	END IF;

		      -- Esto siempre tiene que ir después de la sentencia anterior
		      IF NVL(PEXTRA,0) > 0  THEN --> Solo periódicas recalculamos los datos ya que cambian.
		      	Pac_Simulacion.Tabla(Ejer).PERIODICA := PEXTRA * POWER( 1 + B2, EJER )
		      	                                        + Pac_Simulacion.Tabla(Ejer).PERIODICA;
		      END IF;

			--  IF NVL(Pac_Simulacion.TABLA(Ejer).Periodica,0) <> 0 THEN
				      INSERT INTO DETSIMULAPP ( SESION, EJERCICIO, FFINEJER, APORMES, CAPITAL )
				      VALUES ( USERENV('SESSIONID')
				              ,Pac_Simulacion.Tabla(Ejer).EJERCICIO
				              ,Pac_Simulacion.Tabla(Ejer).FECHA
				              ,Pac_Simulacion.Tabla(Ejer).MENSUAL
				              ,Pac_Simulacion.Tabla(Ejer).PERIODICA );
			--END IF;






  PHASTA := EJER;
  END LOOP;



    dbms_output.put_line ( 'entramos C');
  -- Calculos finales

  V1 := ROUND(PPERIODICA *	Pac_Simulacion.Tabla( TRUNC(AC14) ).VFINAL * POWER( 1 + B2, AC14 - TRUNC(AC14) )
  	 	-PPERIODICA ,2) ;

    dbms_output.put_line ( 'entramos F');
  W1 := ROUND(PEXTRA * POWER( (1 + B2) ,AC14),2) ;

  X1 := 1 + B2;

  X2 := POWER( ( 1 + B2),(1/12) ) ;

  X3 := POWER( X2, -1 );

  AK1 := -1 * (TRUNC(F_Sysdate) - TRUNC(PFJUBILA)) / 30.43725;

  AK2 := AK1 / 12;

  AK3 := TRUNC(AK1) - TRUNC(AK2) * 12 + 1 ;

  IF X1 = 1 THEN
  	 X4 := 12;
  ELSE
  	 X4 := X2 * (  ( 1 - POWER( X3, AK3 ) )  / ( X2 - 1 ) );
  END IF ;

  X5 := X4 *POWER( X1 ,( AC14 - TRUNC(AC14)) ) ;

  X6 := PPERIODICA * POWER(  1 + ( PREVALI / 100 ), TRUNC(AC14) );

  X7 := X5 * X6;

  V9 := V1 + W1 + X7;

  Pac_Simulacion.Tabla(PHASTA).PERIODICA := V9;
  Pac_Simulacion.Tabla(PHASTA).FECHA := PFJUBILA;

  UPDATE DETSIMULAPP
 SET CAPITAL = V9
     ,FFINEJER = PFJUBILA
  WHERE SESION = USERENV('SESSIONID')
  AND EJERCICIO = PHASTA;


  -- Borramos los movimiento que se han generado a 0;

  DELETE DETSIMULAPP
  WHERE SESION = USERENV('SESSIONID')
  AND NVL(CAPITAL,0) = 0 ;



  -- Calculo aportaciones periodicas totales.

  IF AC17 > 0 THEN

  	 V17 := PPERIODICA * 12;

     V18 := PPERIODICA * 12 * POWER( 1 + AC17, TRUNC(AC14)-1)  ;

     V19 := ( V18 * ( 1+ AC17 )- V17) / (AC17);

  	 W18 := V18 /12 * (1 + AC17 );

     W19 := AK3 * W18;

  	 AI8 := ROUND(  V19 + W19 + PEXTRA,2 ) ;

  ELSE

  	 AI8 := ROUND( ( TRUNC( AK1 )+1 ) * PPERIODICA + PEXTRA ,2 ) ;

  END IF;

  -- Aportaciones realizadas
  Pac_Simulacion.Tabla(-1).TEXTO := 'APORTACIONES_REALES';
  Pac_Simulacion.Tabla(-1).VALOR := AI8;
  -- Duracion de las aportaciones
  -- Años
  Pac_Simulacion.Tabla(-2).TEXTO := 'DURACION_AÑOS_APORTACIONES';
  Pac_Simulacion.Tabla(-2).VALOR := TRUNC(AC14);
  -- Mes
  Pac_Simulacion.Tabla(-3).TEXTO := 'DURACION_MESES_APORTACIONES';
  Pac_Simulacion.Tabla(-3).VALOR := AK3;

  --**************************************************************
  --**************************************************************
  --****************** rentas presta******************************
  --**************************************************************
  --**************************************************************

  -- Rellenamos las calculos actuariales Tablas GRM/f95 Tramos 8 y 9
  Pac_Simulacion.Actu.DELETE;

  dbms_output.put_line ( 'entramos' );
  SELECT DECODE(PSEXO1,1,8,9), DECODE(PSEXO2,1,8,9)
  INTO TRAMO1, TRAMO2
  FROM DUAL;
    dbms_output.put_line ( 'salimos');

  FOR c IN 1..81 LOOP

  	Pac_Simulacion.Actu(c).T := c;

  	IF PPERCIERTO < C THEN
  	 	Pac_Simulacion.Actu(c).Px := ROUND( NVL(Buscatramo(1, TRAMO1,AM9 + C) / Buscatramo(1,TRAMO1,AM9),0), 6) ;
  	  Pac_Simulacion.Actu(c).Py := ROUND( NVL(Buscatramo(1, TRAMO2,AM10 + C) / Buscatramo(1,TRAMO2,AM10),0) , 6);
    ELSE
  		Pac_Simulacion.Actu(c).Px := 1;
  		Pac_Simulacion.Actu(c).Py := 1;
  	END IF;

  	Pac_Simulacion.Actu(c).PxPy := NVL(Pac_Simulacion.Actu(c).Px * Pac_Simulacion.Actu(c).Py,0);
  	Pac_Simulacion.Actu(c).Vt := ROUND(NVL(POWER ( ( 1 + (PINTERRENI/100) ) ,-C ),0),6);
  	Pac_Simulacion.Actu(c).Rev := ROUND(NVL(POWER ( ( 1 + PREVALREN/100 ), C-1 ),0),6);
  	Pac_Simulacion.Actu(c).ax := ROUND(NVL(Pac_Simulacion.Actu(c).px * Pac_Simulacion.Actu(c).vt * Pac_Simulacion.Actu(c).rev,0),6);
  	Pac_Simulacion.Actu(c).ay := ROUND(NVL(Pac_Simulacion.Actu(c).py * Pac_Simulacion.Actu(c).vt * Pac_Simulacion.Actu(c).rev,0),6);
  	Pac_Simulacion.Actu(c).axx := ROUND(NVL(Pac_Simulacion.Actu(c).pxpy * Pac_Simulacion.Actu(c).vt * Pac_Simulacion.Actu(c).rev,0),6);



  	AQ4 := AQ4 + Pac_Simulacion.Actu(c).ax;
  	AQ5 := AQ5 + Pac_Simulacion.Actu(c).ay;
  	AQ6 := AQ6 + Pac_Simulacion.Actu(c).axx;

  END LOOP;

  AR4 := AQ4 * ( 1 + ( PREVALREN / 100 ) )+1;
  AR5 := AQ5 * ( 1 + ( PREVALREN / 100 ) )+1;
  AR6 := AQ6 * ( 1 + ( PREVALREN / 100 ) )+1;
  -- Valor Renta 1er titular
  AQ9 := ROUND( ( AQ4 + 0.458333 ) * 1.02 * 12000);
  AR9 := ROUND( ( AR4 + 0) * 1.02 * 12000 );
  AS9 := ROUND( ( AQ4 + 0) * 1.02 * 12000 );
  AT9 := ROUND( 11 / 24 * AR9 + 13 / 24 * AS9 ) ;
  -- Valor Renta deseada

  AQ7 := ROUND( 12000 * ( AQ4 + 0.458333 + ( PREVERSION / 100) * ( AQ5 - AQ6 ) ) * 1.02);
  AR7 := ROUND( 12000 * ( AR4 + 0 + ( PREVERSION / 100 ) * ( AR5 - AR6 ) ) * 1.02 );
  AS7 := ROUND( 12000 * ( AQ4 + 0 + ( PREVERSION / 100 ) * ( AQ5 - AQ6 ) ) * 1.02 );
  AT7 := ROUND( 11 / 24 * AR7 + 13 / 24 * AS7 );

  -- Cálculo de la renta mensual vitalicia primer titular .

  IF NVL(PREVALREN,0) = 0 THEN

  		IF PFNACIMI2 IS NULL THEN
  		     AI71 := V9 / AQ9 * 1000;
  		ELSE
  			   AI71 := V9 / AQ7 * 1000;

  		END IF;

 	ELSE

  		IF PFNACIMI2 IS NULL THEN
  		     AI71 := V9 / AT9 * 1000;
  		ELSE
  			   AI71 := V9 / AT7 * 1000;

  		END IF;

 	END IF;

 	AI71 := ROUND(AI71,2);

 	-- Renta
  Pac_Simulacion.Tabla(-4).TEXTO := 'RENTA VITALICIA';
  Pac_Simulacion.Tabla(-4).VALOR := AI71;





  -- Grabamos los datos genericos de la simulacion en SIMULAPP

  UPDATE SIMULAPP
  SET   NOMBRE1    = PNOMBRE1
       ,NOMBRE2    = PNOMBRE2
       ,FNACIMI1   = PFNACIMI1
       ,FNACIMI2   = PFNACIMI2
       ,SEXO1      = PSEXO1
       ,SEXO2      = DECODE(PFNACIMI2,NULL,NULL,PSEXO2)
       ,FJUBILA    = PFJUBILA
       ,EDADJUBILA = PEDADJUBILA
       ,PINTERCAP  = NVL(PINTERES,0)
       ,PINTERREN  = NVL(PINTERRENI,0)
       ,PREVAL     = NVL(PREVALI,0)
       ,DURANOS    = Pac_Simulacion.Tabla(-2).VALOR
       ,DURMESES   = Pac_Simulacion.Tabla(-3).VALOR
       ,PERIODICA  = NVL(PPERIODICA,0)
       ,EXTRA      = NVL(PEXTRA,0)
       ,CAPESTIMA  = Pac_Simulacion.Tabla(PHASTA).PERIODICA
       ,APORREA    = Pac_Simulacion.Tabla(-1).VALOR
       ,RENTAVIT   = Pac_Simulacion.Tabla(-4).VALOR
       ,PREVER     = NVL(PREVERSION,0)
       ,RENTAREV   = NVL(PREVALREN,0)
       ,PERCIERTO  = NVL(PPERCIERTO,0)
  WHERE SESION = USERENV ( 'SESSIONID');


  COMMIT;

  RETURN 0;

  EXCEPTION
  	WHEN OTHERS THEN
  	  DBMS_OUTPUT.PUT_LINE ( 'SQLERRM ' || SQLERRM );
  	  RETURN - 99;

END F_SIMULACION_APOR_PP;


--********************************************* prestaciones

  FUNCTION F_SIMULACION_PRESTA_PP (
  		   						  	PSSEGURO IN NUMBER,
									PFNACIMI1 IN DATE,
                             PSEXO1 IN NUMBER,
							 PFJUBILA IN DATE,
							 PEDADJUBILA IN NUMBER,
							 PNOMBRE1 IN VARCHAR2,
                             PPERIODICA IN NUMBER DEFAULT 0,
                             PEXTRA IN NUMBER DEFAULT 0,
                             PINTERES IN NUMBER DEFAULT 0,
							 PFCONTIN IN DATE DEFAULT NULL,
							 PFINICIOFIS IN DATE DEFAULT NULL,
							 PCONTIN IN NUMBER DEFAULT NULL,
							 PFVALORA IN DATE DEFAULT NULL,
							 PDERECHOS IN NUMBER DEFAULT NULL,
                             PHASTA OUT NUMBER ) RETURN NUMBER IS

   EJER        NUMBER   := 1;   -->  Número de Ejercicio
   AÑO          NUMBER := pedadjubila; --> Edad
   CAPITAL  NUMBER := PEXTRA;
   RENTA    NUMBER := PPERIODICA;
   DERECHOS NUMBER := PDERECHOS;
   NACIMIENTO DATE := PFNACIMI1;
   SALDO     NUMBER;
   PAGO_ANUAL NUMBER;
   RETCAP NUMBER;
   RETREN NUMBER;
   PERSONA NUMBER;
   ERROR NUMBER;
   REDUCCION NUMBER;
   BASE NUMBER;
   EFECTO DATE;
   anos NUMBER;
   NUMMESES NUMBER;
   RENTASAVE NUMBER;

BEGIN


	DELETE DETSIMULAPP WHERE SESION = USERENV('SESSIONID');
	DELETE SIMULAPP WHERE SESION = USERENV('SESSIONID');

	INSERT INTO SIMULAPP ( SESION, NOMBRE1, FNACIMI1, SSEGURO,PINTERREN
	,PERIODICA, EXTRA, FCONTIN, FINICIOFIS, NCONTIN, FVALORA, DERECHOS  )
	VALUES ( USERENV('SESSIONID') , PNOMBRE1 , PFNACIMI1 ,PSSEGURO, PINTERES
	,PPERIODICA, PEXTRA, PFCONTIN, PFINICIOFIS, PCONTIN, PFVALORA, PDERECHOS) ;



	Pac_Simulacion.Tabla.DELETE;


    NACIMIENTO := ADD_MONTHS(PFNACIMI1,PEDADJUBILA*12);

	INSERT INTO INFORMES_ERR VALUES ( 'LA EXTRA ES ' || PEXTRA );
	COMMIT;

	IF PEXTRA > 0 THEN --> CAPITAL
	       INSERT INTO DETSIMULAPP ( SESION,EJERCICIO,FFINEJER, APORMES, CAPITAL )
	   VALUES ( USERENV('SESSIONID')
	                       ,0
	                       ,NACIMIENTO
						   ,DERECHOS
						   ,ROUND(NVL(PEXTRA,0),2));

       DERECHOS := DERECHOS - CAPITAL;
	END IF;



	SALDO := DERECHOS;


	IF RENTA > 0 THEN

	                RENTA := RENTA * 12;
					RENTASAVE := RENTA;

					LOOP
					  EXIT WHEN NVL(SALDO,0) = 0 ;

					  IF RENTA >= SALDO THEN
					     RENTA := SALDO * ( PINTERES / 100 ) + SALDO;

					 END IF;

                      IF RENTASAVE = RENTA THEN
					      NUMMESES := NVL(NUMMESES,0) + 12;
					  END IF;

					       INSERT INTO DETSIMULAPP ( SESION,EJERCICIO,FFINEJER, APORMES, CAPITAL )
						   VALUES ( USERENV('SESSIONID')
						                       ,EJER
						                       ,NACIMIENTO
											   ,SALDO
											   ,ROUND(NVL(RENTA,0) ,2)    );


					--  IF SALDO <= RENTA  THEN
					--   	 NUMMESES :=  NUMMESES + ( ( SALDO  * 12 ) / RENTA ) *-1;
					--  END IF;

					  SALDO := SALDO * ( PINTERES / 100  ) + SALDO - RENTA;



				      EXIT WHEN SALDO < 0;


					  	dbms_output.put_line ( 'entramos' || saldo || 'renta ' || renta  );
					  NACIMIENTO :=  ADD_MONTHS(NACIMIENTO,12);


					  AÑO := AÑO +1;
					  EJER := EJER +1;

					END LOOP;

    IF EJER <= 2 THEN
	     NUMMESES := 0;
	END IF;
    NUMMESES :=  NVL(NUMMESES,0) + ( ( RENTA  * 12 ) / RENTASAVE ) ;

	END IF;



		dbms_output.put_line ( 'entramos2');
	-- Calculamos la retención

	SELECT SPERSON INTO PERSONA
	FROM RIESGOS
	WHERE RIESGOS.SSEGURO = PSSEGURO;

    ERROR := Pac_Irpf.F_Simula_Irpf_renta( PSSEGURO, PERSONA, USERENV('SESSIONID') , RETREN);
    ERROR := Pac_Irpf.F_Simula_Irpf_Cap( PSSEGURO, PERSONA, USERENV('SESSIONID') , RETCAP, REDUCCION,BASE);


	-- Si el contrato tiene más de dos años calculamos la reducción.


	error := F_Difdata ( pfiniciofis, F_Sysdate, 1, 1 , anos );

	-- Si el contrato es inferior a 2 años no calculamos reduccib
	UPDATE SIMULAPP SET IRETEN = NVL(PERIODICA,0) * ( NVL(RETREN ,0) / 100)
	                                                   ,IRETENCAP = NVL(EXTRA,0) * ( NVL(RETCAP,0) / 100 )
													   ,PRETEN = NVL(RETREN,0)
													   ,PRETENCAP = NVL(RETCAP,0)
													   ,IREDUC = DECODE(GREATEST(anos,1),1,0,REDUCCION)
													   ,IBASE = NVL(BASE,0)
													   ,MESES = NUMMESES
	WHERE SESION = USERENV('SESSIONID');

	COMMIT;
    RETURN 0;
 EXCEPTION
   WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE ( 'SQLERRM ' || SQLERRM );
	RETURN -1;
END;

  FUNCTION F_MAX_FVALORA ( PSPRODUC IN NUMBER ) RETURN DATE IS
    FECHA DATE;
  BEGIN
			SELECT MAX(fvalora) INTO fecha
			FROM VALPARPLA, PROPLAPEN
			WHERE VALPARPLA.CCODPLA = PROPLAPEN.CCODPLA
			AND PROPLAPEN.SPRODUC = PSPRODUC;

			RETURN FECHA;
  EXCEPTION
  WHEN OTHERS THEN
   RETURN NULL;
  END;

  FUNCTION F_MIN_FANTIGI ( PSSEGURO IN NUMBER ) RETURN DATE IS
     FANTIGI DATE;
	 EFECTO DATE;
  BEGIN
        SELECT FEFECTO INTO EFECTO
		FROM SEGUROS
		WHERE SEGUROS.SSEGURO = PSSEGURO;

		 SELECT MIN(FANTIGI) INTO FANTIGI
		FROM TRASPLAINOUT
		WHERE TRASPLAINOUT.CINOUT = 1
		AND TRASPLAINOUT.SSEGURO = PSSEGURO;

		IF NVL(FANTIGI,F_Sysdate) > EFECTO THEN
			 FANTIGI := EFECTO;
		END IF;

        RETURN FANTIGI;
EXCEPTION
WHEN OTHERS THEN
 RETURN NULL;
 END;

END;

/

  GRANT EXECUTE ON "AXIS"."PAC_SIMULACION" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_SIMULACION" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_SIMULACION" TO "PROGRAMADORESCSI";
