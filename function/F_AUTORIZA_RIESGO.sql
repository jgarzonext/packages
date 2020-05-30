--------------------------------------------------------
--  DDL for Function F_AUTORIZA_RIESGO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_AUTORIZA_RIESGO" ( PSSEGURO IN NUMBER, PUSUARIO IN VARCHAR2, COMPROVACION IN NUMBER default 0)RETURN NUMBER IS
  --*********************************************************************************
  --*********************************************************************************
  --***																			  ***
  --***  Función :  F_AUTORIZA_RIESGO											  ***
  --***  Parámetros:  			  	   											  ***
  --***                 Psseguro:  Id de la póliza								  ***
  --***				 PsUsuario: Usuario	 										  ***
  --***				 Comprovacion: Si enviamos un (1) indicamos que aunque el
  --*** 					       perfil sea superior, queremos que comprueba las
  --***							   preguntas
  --***  Valor de retorno:														  ***
  --***            (100)  - Permiso total de perfil. Autorización ok.
  --***  		      (0)  - Autorización OK.								      ***
  --***              (-1) - Se ha producido un error NO tratado. 			      ***
  --***              (-2) - No se ha encontrado ninguna regla.                    ***
  --***		         (-4) - Ningún paquete ha sido aceptado.  					  ***
  --***				 	  		   		   	  	   								  ***
  --*********************************************************************************
  --*********************************************************************************
  RAMO        NUMBER;
  MODALI      NUMBER;
  TIPSEG      NUMBER;
  COLECT      NUMBER;
  PERFIL      NUMBER;
  PADRE       NUMBER;
  RESPUESTA   NUMBER;
  CORRECTO    VARCHAR2(1);
  ERROR       NUMBER;
  EMPRE       NUMBER;
  SPROCES     NUMBER;
  NPROLIN     NUMBER;
  ACEPTADA    EXCEPTION;
  PERFIL_AUT  NUMBER;
  FUNCION     VARCHAR2(200);
  TIPO_PREGUNTA NUMBER;
  VALOR_P     NUMBER;
  SINREGLAS   NUMBER;
  PRODUCTO    NUMBER;
  PERFILPRO   NUMBER;
BEGIN
  -- ***** Buscamos los datos de la solicitud
  SELECT S.CRAMO, S.CMODALI, S.CTIPSEG, S.CCOLECT, S.CEMPRES, P.SPRODUC
  INTO RAMO, MODALI, TIPSEG, COLECT, EMPRE, PRODUCTO
  FROM SEGUROS S, PRODUCTOS P WHERE S.SSEGURO = PSSEGURO
  AND S.CRAMO = P.CRAMO
  AND S.CMODALI = P.CMODALI
  AND S.CTIPSEG = P.CTIPSEG
  AND S.CCOLECT = P.CCOLECT;
--  MESSAGE ( RAMO || ' - ' || MODALI || ' - ' || TIPSEG || ' -'  || COLECT );PAUSE;
  error := f_procesini(F_USER,empre,'F_AUTORIZA_RIESGO','Autoriza riesgo',sproces);
  -- Si existen reglas para el producto, se intentara validar, y si no existen reglas
  -- no se valida nada.
  BEGIN
    SELECT NVL(MIN(CR.CPERFAUT),9999)
	INTO PERFIL_AUT
    FROM PAR_REGLAS_APLICABLES PAC
        ,CODIREGLA CR
    WHERE PAC.CRAMO = RAMO
      AND ( PAC.CMODALI = MODALI OR PAC.CMODALI IS NULL )
      AND ( PAC.CTIPSEG = TIPSEG OR PAC.CTIPSEG IS NULL )
      AND ( PAC.CCOLECT = COLECT OR PAC.CCOLECT IS NULL )
      AND CR.CREGLA = PAC.CREGLA;
  EXCEPTION
	WHEN OTHERS THEN
	  error := f_proceslin(sproces, 'Err. desconocido: ' || SQLERRM , psseguro, nprolin);
      error := f_procesfin(sproces,error);
      RETURN ( -1 );
  END;
  -- ***** Ahora buscamos su perfil
  BEGIN
    SELECT P.CPERFIL, CP.CPERFPAD
    INTO PERFIL, PADRE
    FROM PAR_PERFILES_USUARIO P, CODIPERFIL CP
    WHERE P.CRAMO = RAMO
      AND ( P.CMODALI = MODALI OR P.CMODALI IS NULL )
      AND ( P.CTIPSEG = TIPSEG OR P.CTIPSEG IS NULL )
      AND ( P.CCOLECT = COLECT OR P.CCOLECT IS NULL )
      AND CUSUARI = PUSUARIO
      AND CP.CPERFIL = P.CPERFIL;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      Perfil := 9999;
    WHEN OTHERS THEN
      error := f_proceslin(sproces, 'Err. desconocido: ' || SQLERRM , psseguro, nprolin);
      error := f_procesfin(sproces,error);
      RETURN ( -1 );
  END;
/************************
  BEGIN
    SELECT CVALPAR INTO PERFILPRO
    FROM PARPRODUCTOS
    WHERE PARPRODUCTOS.SPRODUC = PRODUCTO
	AND PARPRODUCTOS.CPARPRO = 'PERFILRIESGO';
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      perfilpro := -1;
	WHEN OTHERS THEN
	  error := f_proceslin(sproces, 'Err. desconocido: ' || SQLERRM , psseguro, nprolin);
      error := f_procesfin(sproces,error);
      RETURN ( -1 );
  END;
  IF PERFILPRO = 0 AND NVL(COMPROVACION,0) = 0 THEN
    RETURN 100;
************************/
--  IF (PERFIL_AUT > PERFIL) AND PERFIL_AUT != 9999 THEN
--    ERROR := f_procesfin(sproces,error);
--    RETURN 100;
  IF PERFIL_AUT < PERFIL THEN
    error:=f_proceslin(sproces, 'Perfil de usuario inferior al definido en selección de riesgos.', psseguro, nprolin);
    ERROR := f_procesfin(sproces,error);
	RETURN -4;
  -- No hay definida ninguna regla para el producto
  ELSIF PERFIL_AUT = 9999 THEN
    ERROR := f_procesfin(sproces,error);
	RETURN 0;
  ELSE
    --MESSAGE ( 'ANTES DE VER LAS REGLAS EL PERFIL ES : ' || PERFIL );PAUSE;
    SINREGLAS := 0;
    FOR REGLAS IN ( SELECT SREGLA, PAC.CREGLA ,CR.CPERFAUT
                  FROM PAR_REGLAS_APLICABLES PAC
                      ,CODIREGLA CR
                  WHERE PAC.CRAMO = RAMO
                      AND ( PAC.CMODALI = MODALI OR PAC.CMODALI IS NULL )
                      AND ( PAC.CTIPSEG = TIPSEG OR PAC.CTIPSEG IS NULL )
                      AND ( PAC.CCOLECT = COLECT OR PAC.CCOLECT IS NULL )
                      AND CR.CREGLA = PAC.CREGLA
                 ) LOOP
      -- ***** Si el perfil del usuario es SUPERIOR al solicitado dar por buena.
      -- ***** la regla automáticamente.
      --MESSAGE ( 'PERFIL: ' || REGLAS.CPERFAUT || ' < ' || PERFIL );PAUSE;
--      IF REGLAS.CPERFAUT > PERFIL THEN
--        SINREGLAS := 1;
--      ELSE
        -- ***** Ahora comprovamos lOs PAQUETES de la regla QUE SON ( <<<OR>>> ).
        --MESSAGE ( 'REGLA: ' || REGLAS.CREGLA );
        FOR PAQUETE IN ( SELECT SASOCIA, CREGLA, CPERFEXG
                         FROM CODIASOCCOND
                         WHERE CREGLA = REGLAS.CREGLA ) LOOP
           --MESSAGE ( 'PERFIL paquete ' || PAQUETE.CPERFEXG || ' PERFIL ' || PERFIL );
           --**** Si la el perfil de la asociación es inferior al perfil del usuario
	       --**** damos por buena la solicitud ya que una asociacion se ha cumplido.
--          IF NVL(PAQUETE.CPERFEXG,9999) > PERFIL THEN
--            RAISE ACEPTADA;
--	      END IF;
          CORRECTO := 'X';
           -- ***** Control de las preguntas
          FOR PREGUNTAS IN ( SELECT DET.SASOCIA, DET.SCONDREG , PAR.CPERFEXG, PAR.CPREGUN
                                    ,PAR.CRESPUE, PAR.NVALINF, PAR.NVALSUP
                              FROM DETASOCCOND DET, PAR_CONDIC_REGLAS PAR
                              WHERE DET.SASOCIA = PAQUETE.SASOCIA
                              AND DET.SCONDREG = PAR.SCONDREG) LOOP
                 -- *** Si el perfil de la pregunta es de un nivel inferior al del usuario
				 -- *** damos por buena la pregunta.
--            IF NVL(PREGUNTAS.CPERFEXG,9999) > PERFIL THEN
--              CORRECTO :='S';
--            ELSE
              -- *** Buscamos la información de la pregunta
              -- *** Si no la encuntra se asume que es MANUAL
              BEGIN
                SELECT TPREFOR,CPRETIP INTO FUNCION, TIPO_PREGUNTA
                FROM PREGUNPRO
                WHERE CPREGUN = PREGUNTAS.CPREGUN
                  AND CRAMO = RAMO AND CMODALI = MODALI
                  AND CTIPSEG = TIPSEG AND CCOLECT = COLECT;
              EXCEPTION
                WHEN OTHERS THEN
                  TIPO_PREGUNTA := 1;
              END;
              --MESSAGE( 'PREGUNTA ' || PREGUNTAS.CPREGUN || 'TIPO ' || TIPO_PREGUNTA);PAUSE;
              --*** Para cada pregunta comprovamos su respuesta
              --*** en función de si es MANUAL o AUTOMÁTICA
              IF TIPO_PREGUNTA = 1 THEN -- *** Manual
                BEGIN
                  SELECT CRESPUE INTO RESPUESTA
                  FROM PREGUNSEG
                  WHERE CPREGUN = PREGUNTAS.CPREGUN
                    AND PREGUNSEG.SSEGURO = PSSEGURO;
                  --MESSAGE ( 'RESPUESTA MANUAL: ' || CORRECTO );PAUSE;
                EXCEPTION
                  WHEN OTHERS THEN -- No encontrada la respuesta o más de una encontrada
                    CORRECTO := 'N';
                    EXIT;
                END;
              ELSIF TIPO_PREGUNTA = 2 THEN --**** Automática
                ERROR := PAC_ALBSGT.F_TPREFOR(FUNCION,null,psseguro,1,f_sysdate,0,3,RESPUESTA,NULL);

                --MESSAGE ( 'RESPUESTA AUTOMÁTICO: ' || RESPUESTA );PAUSE;
              END IF;
              --*** Ahora miramos si es un valor o esta en un rango
              IF PREGUNTAS.CRESPUE IS NULL THEN
                IF RESPUESTA >= PREGUNTAS.NVALINF AND RESPUESTA <= PREGUNTAS.NVALSUP
                    AND CORRECTO <> 'N' THEN
                  CORRECTO := 'S';
                ELSE
                  CORRECTO := 'N';
                END IF;
              ELSIF PREGUNTAS.CRESPUE IS NOT NULL AND CORRECTO <> 'N' THEN
                IF RESPUESTA = PREGUNTAS.CRESPUE THEN
                  CORRECTO := 'S';
                ELSE
                  CORRECTO := 'N';
                END IF;
              END IF;
--            END IF; -- Final del condicional de perfiles de preguntas.
          END LOOP;   -- Final de todas las preguntas
          -- ***** Si un paquete devulve <S> aceptamos la solicitud
          -- ***** Claro que si devuelve <X> quiere decir que no había preguntas
          -- ***** en el paquete. De momento lo damos como bueno, pero habrá que mirarlo.
          IF CORRECTO = 'S' THEN
            RAISE ACEPTADA;
          END IF;
        END LOOP;  -- Final de todos los paquetes
        -- ***** Si hemos llegado aquí es que ningún paquete ha sido aceptado
        -- ***** por lo tanto devolvemos <N> indicando que no aceptamos la solicitud.
        IF (PERFIL_AUT > PERFIL) AND PERFIL_AUT != 9999 THEN
          ERROR := f_procesfin(sproces,error);
          RETURN 100;
        END IF;
        error:=f_proceslin(sproces, 'Ningún paquete de preguntas ha sido aceptado.', psseguro, nprolin);
        RETURN ( -4 );
--      END IF;  -- Este fin de condición es del de las reglas
    END LOOP; -- Fin reglas
    -- **** Hemos llegado aquí porque todas las reglas son de un nivel inferior
    -- **** por lo tanto se acepta el seguro.
    -- **** o porque no ha encontrado ninguna regla
    IF SINREGLAS = 0 THEN
      error:=f_proceslin(sproces, 'No se ha encontrado ninguna regla.', psseguro, nprolin);
	  ERROR := f_procesfin(sproces,error);
      RETURN ( -2 );
    END IF;
    RETURN ( 0 );
  END IF;
EXCEPTION
  WHEN ACEPTADA THEN
    IF f_procesfin(sproces,error)=0 THEN
      return ( 0 );
    END IF;
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE ( 'HEMOS ACABADO CON ERRORES : ' || SQLERRM );
    error:=f_proceslin(sproces, 'Err. desconocido: ' || SQLERRM , psseguro, nprolin);
	ERROR := f_procesfin(sproces,error);
    RETURN ( -1 );
END F_AUTORIZA_RIESGO;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_AUTORIZA_RIESGO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_AUTORIZA_RIESGO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_AUTORIZA_RIESGO" TO "PROGRAMADORESCSI";
