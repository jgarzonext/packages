--------------------------------------------------------
--  DDL for Function F_LIQUIDALIQCIA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_LIQUIDALIQCIA" (PCCOMPANI IN NUMBER, PCEMPRES IN NUMBER, PNLIQMEN IN
	NUMBER, IDIOMA IN NUMBER, PFMOVINI IN DATE, pfdata1 IN DATE, pfdata31 IN DATE)

RETURN NUMBER authid current_user IS
/***********************************************************************
	F_LIQUIDALIQCIA: Se realiza la liquidación de la compañía indicada
	y se graba en ctactescia el resultado de la liquidación.
***********************************************************************/
	-- Cursor que recupera todas las líneas correspondientes a la cabecera pasada.
	CURSOR C_LIQUID IS
		SELECT NLIQLIN, ICOMLIQ, NNUMLIN, NRECIBO
		FROM	LIQUIDALINCIA
		WHERE	NLIQMEN = PNLIQMEN
		  AND CCOMPANI = PCCOMPANI
		  AND CEMPRES = PCEMPRES
		ORDER BY NLIQLIN ASC;

	-- Cursor que recupera las líneas pendientes de liquidar.
	CURSOR C_LIQLIN_PDTE IS
		SELECT *
		FROM	LIQUIDALINCIA
		WHERE	NLIQMEN = PNLIQMEN
		AND CCOMPANI = PCCOMPANI
		AND CEMPRES = PCEMPRES
		AND	CESTLIN IS NULL
		ORDER BY NLIQLIN;

       	-- Cursor que recupera las liquidaciones retenidas.
	CURSOR C_LIQLIN_RET IS
		SELECT *
		FROM LIQUIDALINCIA
		WHERE NLIQMEN = PNLIQMEN
		  AND CCOMPANI = PCCOMPANI
		  AND CEMPRES = PCEMPRES
		  AND NVL(CESTLIN,0) = 1
		ORDER BY NLIQLIN;


	-- Cursor que recupera las liquidaciones pendientes en
	-- ctactescia y que no dependen de liquidalincia.
	CURSOR C_LIQCTA_PDTE IS
		SELECT *
		FROM CTACTESCIA
		WHERE CCOMPANI = PCCOMPANI
		AND   CEMPRES = PCEMPRES
		AND   CESTADO = 1
                AND   NLIQMEN IS NULL
                AND   TRUNC(FFECMOV) BETWEEN pfdata1 AND pfdata31;

	XFLIQUID	DATE;
	XFMOVIMI	DATE;
	XFINGTAL	DATE;

	XCTIPLIQ	NUMBER;
	XIMINLIQ	NUMBER;
	XNCARENC	NUMBER;
	XTOTCOML    	NUMBER;
	XTOTCOMCTA	NUMBER;
	XTOTAL		NUMBER;
	XCDEBHAB    	NUMBER;
	XIIMPORT    	NUMBER;
	NEWCTALIN   	NUMBER := 0;
	NEWLIQMEN	NUMBER := 0;
	NEWLIQLIN	NUMBER := 1;
	NEWLIQLINOLD 	NUMBER := 1;
	NUM_ERR		NUMBER := 0;
	XCVALIDA_LIQ 	NUMBER;
	XCVALIDA_IMP 	NUMBER;
	concepto    	NUMBER;
	docume      	VARCHAR2(10);
	sinies      	NUMBER(8);
	descrip     	VARCHAR2(30);

--
-- FUNCIÓN PARA CREAR UNA CABECERA DE LIQUIDACIÓN EN LA TABLA LIQUIDACABCIA
--
FUNCTION F_CREAR_LIQCABCIA RETURN NUMBER  IS
  XFMOVIMI	DATE;
  XFCONTAB	DATE;
  XNTALON		NUMBER;
  XCCTATAL	VARCHAR2(20);
  XFINGTAL	DATE;
BEGIN
   BEGIN
	-- Recupera los datos de la cabecera actual para crear una nueva.
	SELECT FMOVIMI, FCONTAB, NTALON, CCTATAL, FINGTAL
	INTO XFMOVIMI, XFCONTAB, XNTALON, XCCTATAL, XFINGTAL
	FROM LIQUIDACABCIA
	WHERE CCOMPANI = PCCOMPANI
	AND	CEMPRES = PCEMPRES
	AND	NLIQMEN = PNLIQMEN;
   EXCEPTION
	WHEN OTHERS THEN
	  RETURN 110175;		-- Error al llegir de la taula LIQUIDACABCIA
   END;
   BEGIN
      -- Se recupera el siguiente número de liquidación para la cabecera.
      SELECT NVL(MAX(NLIQMEN),0) + 1
	   INTO NEWLIQMEN
      FROM LIQUIDACABCIA
      WHERE CCOMPANI = PCCOMPANI
        AND CEMPRES = PCEMPRES;
   EXCEPTION
      WHEN OTHERS THEN
	  RETURN 110175;		-- Error al llegir de la taula LIQUIDACABCIA
   END;
   BEGIN
	-- Se inserta la nueva cabecera sin proceso y de tipo retenida.
	INSERT INTO LIQUIDACABCIA(CCOMPANI, NLIQMEN, FLIQUID, FMOVIMI, FCONTAB,
		   	           CEMPRES, SPROLIQ, NTALON , CCTATAL, FINGTAL, CTIPLIQ)
	VALUES(PCCOMPANI, NEWLIQMEN, NULL, XFMOVIMI, XFCONTAB,
		 PCEMPRES, NULL, XNTALON, XCCTATAL, XFINGTAL, 3);
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
        RETURN 110177;		-- Registres duplicats a la taula LIQUIDACABCIA
      WHEN OTHERS THEN
        RETURN 110176;		-- Error a l' inserir a la taula LIQUIDACABCIA
   END;
RETURN 0;
END;
--
-- FUNCIÓN PARA CREAR NUEVA LIQUIDACIÓN EN TABLA LIQUIDALINCIA, Y BORRAR
-- ANTIGUA. Si se trata de una línea de ctactescia que se ha liquidado,
-- se crea una línea en liquidalincia con el nnumlin de ctactescia, para
-- que se pueda mostrar en el listado.
--
FUNCTION F_CREAR_LIQLINCIA(POLD_NLIQMEN IN NUMBER,
				  PNEW_NLIQMEN IN NUMBER,
				  POLD_NLIQLIN IN NUMBER,
				  PNEW_NLIQLIN IN NUMBER,
				  PNRECIBO IN NUMBER,
				  PNNUMLIN IN NUMBER,
				  PICOMLIQ IN NUMBER,
				  PIRETENC IN NUMBER,
				  PSMOVREC IN NUMBER)
RETURN NUMBER  IS
BEGIN
   BEGIN
	-- Inserta una nueva línea en liquidalincia para la nueva cabecera.
	INSERT INTO LIQUIDALINCIA(CCOMPANI, NLIQMEN, NLIQLIN, ICOMLIQ,
		IRETENC, NNUMLIN, NRECIBO, CEMPRES, SMOVREC, CESTLIN)
	VALUES(PCCOMPANI, PNEW_NLIQMEN, PNEW_NLIQLIN, PICOMLIQ,
		 PIRETENC, PNNUMLIN, PNRECIBO, PCEMPRES,
		 PSMOVREC, NULL);
   EXCEPTION
	WHEN DUP_VAL_ON_INDEX THEN
	  RETURN 110182;		-- Registres duplicats a la taula LIQUIDALINCIA
	WHEN OTHERS THEN
	  RETURN 110181;		-- Error a l' inserir a la taula LIQUIDALINCIA
   END;
   BEGIN
	-- Elimina la línea perteneciente a la anterior cabecera.
	DELETE LIQUIDALINCIA
	WHERE CCOMPANI = PCCOMPANI
	AND CEMPRES = PCEMPRES
	AND NLIQMEN = POLD_NLIQMEN
	AND NLIQLIN = POLD_NLIQLIN;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 110183;  -- Error a l' esborrar de la taula LIQUIDALINCIA
   END;
   BEGIN
	-- Se modifica el registro de ctactescia para asignarle la nueva cabecera y
	-- cambiarle el estado a pendiente.
	UPDATE CTACTESCIA
	SET NLIQMEN = PNEW_NLIQMEN,
	    NLIQLIN = PNEW_NLIQLIN,
	    CESTADO = DECODE(CESTADO,2,1,CESTADO) -- SI LO ESTAN, LAS PASA DE RETEN. A PEND.
	WHERE CCOMPANI = PCCOMPANI
          AND	CEMPRES = PCEMPRES
          AND	NLIQMEN = POLD_NLIQMEN
          AND	NLIQLIN = POLD_NLIQLIN;
   EXCEPTION
	WHEN OTHERS THEN
	  RETURN 110184;  -- Error al modificar la taula CTACTESCIA
   END;
RETURN 0;
END;
--
-- FUNCIÓN PARA VALIDAR SI SE HA DE LIQUIDAR O NO (PCVALIDA = 1,0),
-- DEPENDIENDO DE LA FECHA O BIEN DE LA CANTIDAD MÍNIMA FIJADAS EN LA
-- TABLA EMPRESAS PARA LAS LIQUIDACIONES MENSUALES.
--
FUNCTION F_VALIDA_LIQLINCIA(PSMOVREC IN NUMBER,
                            PFDATA1 IN DATE, PFDATA31 IN DATE,
                            PCVALIDA OUT NUMBER)
RETURN NUMBER  IS
XFMOVINI	DATE;
XFMOVDIA	DATE;
BEGIN
	BEGIN
	  SELECT FMOVINI, FMOVDIA
	  INTO XFMOVINI, XFMOVDIA
	  FROM MOVRECIBO
	  WHERE SMOVREC = PSMOVREC;
	EXCEPTION
	  WHEN NO_DATA_FOUND THEN
	    RETURN 104939;  -- REBUT NO TROBAR A MOVRECIBO
	  WHEN OTHERS THEN
	    RETURN 104043;  -- ERROR AL LLEGIR DE LA TAULA MOVRECIBO
	END;
	--IF xfmovini <= pfdata31 AND xfmovdia BETWEEN  pfdata1 AND pfdata31 THEN
        IF xfmovini <= pfdata31 THEN
	  PCVALIDA := 1;
        ELSE
	  PCVALIDA := 0;
        END IF;

RETURN 0;
END;
--**************************************************************************
--************************ FUNCIÓN PRINCIPAL *******************************
--**************************************************************************
BEGIN
  BEGIN
    -- Recupera datos de la cabecera tratada.
    SELECT  FLIQUID, FMOVIMI, FINGTAL, CTIPLIQ
      INTO  XFLIQUID, XFMOVIMI, XFINGTAL, XCTIPLIQ
    FROM    LIQUIDACABCIA
    WHERE   CCOMPANI = PCCOMPANI
      AND   CEMPRES = PCEMPRES
      AND   NLIQMEN = PNLIQMEN;
  EXCEPTION
     WHEN NO_DATA_FOUND THEN
	RETURN 101952;    		-- Nº DE LIQUIDACIÓN NO EXISTE
     WHEN OTHERS THEN
	RETURN 110175;		-- Error al llegir de la taula LIQUIDACABCIA
  END;

  -- Si la cabecera de liquidación está pendiente, se le asigna la fecha
  -- en la que es liquidada.
  IF XFLIQUID IS NULL THEN
     BEGIN
	UPDATE LIQUIDACABCIA
	SET FLIQUID = SYSDATE
	WHERE CCOMPANI = PCCOMPANI
	AND CEMPRES = PCEMPRES
	AND NLIQMEN = PNLIQMEN;
     EXCEPTION
	WHEN OTHERS THEN
	  RETURN 110178;		-- Error al modificar la taula LIQUIDACABCIA
     END;
  ELSE
    RETURN 101954;		-- LIQUIDACIÓN YA EFECTUADA ANTERIORMENTE
  END IF;

  BEGIN
    -- Recupera el siguiente número de línea en ctactescia para la empresa
    -- y compañía tratadas.
    SELECT NVL(MAX(NNUMLIN),0) + 1
	INTO NEWCTALIN
    FROM CTACTESCIA
    WHERE CCOMPANI = PCCOMPANI
      AND CEMPRES = PCEMPRES;
  EXCEPTION
     WHEN OTHERS THEN
	 RETURN 110185;			-- Error al llegir de la taula CTACTESCIA
  END;
  -- **********************************************
		-- LIQUIDACIÓN MENSUAL (LLAMADA POR F_LIQEMPRESACIA)
  -- **********************************************
  -- SE LEE EL IMPORTE MÍNIMO Y EL Nº DE DÍAS QUE HAN DE PASAR PARA LIQUIDAR

  BEGIN
	SELECT NVL(IMINLIQ,0), NVL(NCARENC,0)
	  INTO XIMINLIQ, XNCARENC
	  FROM EMPRESAS
	 WHERE CEMPRES = PCEMPRES;
  EXCEPTION
	WHEN NO_DATA_FOUND THEN
	  RETURN 100501;  -- EMPRESA INEXISTENT
	WHEN OTHERS THEN
	  RETURN 103290;  -- ERROR AL LLEGIR A LA TAULA EMPRESAS
  END;
  -- SE MIRAN LAS LIQUIDACIONES EN ESTADO PENDIENTE (CESTLIN = NULL).
  FOR R_LIQLIN_PDTE IN C_LIQLIN_PDTE LOOP
     IF R_LIQLIN_PDTE.NRECIBO IS NOT NULL THEN   -- ES UN RECIBO
        -- COMPROBAMOS QUE EL IMPORTE DE LA COMISION NO SEA 0

        IF R_LIQLIN_PDTE.ICOMLIQ <> 0 THEN
           -- COMPROBAMOS SI CUMPLE LA RESTRICCION DE FECHAS
	   NUM_ERR := F_VALIDA_LIQLINCIA(R_LIQLIN_PDTE.SMOVREC,
                                         PFDATA1, PFDATA31,XCVALIDA_LIQ);
           IF NUM_ERR != 0 THEN
              RETURN NUM_ERR;
           END IF;
           IF XCVALIDA_LIQ = 1 THEN  -- CUMPLE CONDICIÓN DE FECHA
	      -- Se suma el importe de la liquidación.
	      XTOTCOML := NVL(XTOTCOML, 0) + NVL(R_LIQLIN_PDTE.ICOMLIQ, 0);
           END IF;
        END IF;

     ELSIF R_LIQLIN_PDTE.NNUMLIN IS NOT NULL THEN  -- ES UNA LINEA DE CTACTESCIA
	  BEGIN
	    -- Recupera los datos de ctactescia para la línea pendiente.
	    SELECT CDEBHAB, IIMPORT
	      INTO XCDEBHAB, XIIMPORT
	      FROM CTACTESCIA
	     WHERE CCOMPANI = PCCOMPANI
		AND CEMPRES = PCEMPRES
		AND NNUMLIN = R_LIQLIN_PDTE.NNUMLIN;
	  EXCEPTION
	    WHEN NO_DATA_FOUND THEN
	      RETURN 110188;	-- Línia de compte corrent de la companyía no trobada
	    WHEN OTHERS THEN
	      RETURN 110185;			-- Error al llegir de la taula CTACTESCIA
	  END;
	  -- No pueden haber valores negativos. Esto se informa diciendo que es de haber.
	  IF XIIMPORT < 0 THEN
	    RETURN 101947;  --ERROR EN LA CONSISTENCIA DE LA BD
	  ELSE
	    -- Si es una línea de haber, se invierte el signo.
	    IF XCDEBHAB = 2 THEN -- HABER
		XIIMPORT := 0 - XIIMPORT;
	    END IF;
	  END IF;
	  -- Se suma el importe procedente de ctactescia.
	  XTOTCOMCTA := NVL(XTOTCOMCTA,0) + NVL(XIIMPORT,0);
      END IF;
   END LOOP;
   --
   -- SE CALCULA LA SUMA DEL IMPORTE DE LAS LIQUIDACIONES RESTANTES EN CTACTESCIA
   -- (LAS QUE NO TIENEN UNA LINEA EN LIQUIDALINCIA).
   --
   FOR R_LIQCTA_PDTE IN C_LIQCTA_PDTE LOOP
	BEGIN
	  -- Recupera el importe y debe/haber de la línea tratada.
	  SELECT IIMPORT, CDEBHAB
	    INTO XIIMPORT, XCDEBHAB
	    FROM CTACTESCIA
	   WHERE CCOMPANI = PCCOMPANI
		AND CEMPRES = PCEMPRES
		AND NNUMLIN = R_LIQCTA_PDTE.NNUMLIN;
	EXCEPTION
	  WHEN OTHERS THEN
	    RETURN 110185;			-- Error al llegir de la taula CTACTESCIA
	END;
	-- El importe no puede ser negativo.
	IF XIIMPORT < 0 THEN
	  RETURN 101947;  --ERROR EN LA CONSISTENCIA DE LA BD
	ELSE
	  -- Si es una línea de haber, se invierte el signo.
	  IF XCDEBHAB = 2 THEN -- HABER
	    XIIMPORT := 0 - XIIMPORT;
	  END IF;
	END IF;
	  -- Se suma la comisión procedente de ctactescia.
	XTOTCOMCTA := NVL(XTOTCOMCTA,0) + NVL(XIIMPORT,0);
   END LOOP;

   -- Se calcula el total de importes, tanto las de liquidación como las de ctactescia.
   XTOTAL := NVL(XTOTCOML,0) + NVL(XTOTCOMCTA,0);
/*
   -- SE VALIDA EL IMPORTE MÍNIMO A LIQUIDAR
   IF NVL(XTOTAL,0) >= NVL(XIMINLIQ,0) THEN
	XCVALIDA_IMP := 1; -- SE LIQUIDA
   ELSE
	XCVALIDA_IMP := 0; -- NO SE LIQUIDA
   END IF;
*/
   -- No mirem import mínim

   XCVALIDA_IMP := 1; -- SE LIQUIDA

   -- SI NO SE LIQUIDA, SE PASAN TODAS LAS LIQUIDACIONES A LA NUEVA MENOS LAS QUE TENGAN
   -- COMISIÓN = 0. Las entradas de ctactescia que no tengan relación con liquidalincia,
   -- se dejan tal como están hasta la próxima liquidación.
   IF XCVALIDA_IMP = 0 THEN   -- NO ES VÁLIDA (NO SE LIQUIDA).
      -- Para todas las liquidaciones pendientes:
      FOR R_LIQLIN_PDTE IN C_LIQLIN_PDTE LOOP

	  IF R_LIQLIN_PDTE.NRECIBO IS NOT NULL OR
	     R_LIQLIN_PDTE.NNUMLIN IS NOT NULL THEN

	    -- Si la comisión de la liquidación es diferente de cero, se crea una cabecera
	    -- (si no ha sido creada) y una nueva línea para la nueva cabecera.
	    IF (R_LIQLIN_PDTE.ICOMLIQ <> 0) THEN
	      IF NEWLIQMEN = 0 THEN
		-- Se crea una nueva cabecera.
	        NUM_ERR := F_CREAR_LIQCABCIA;
	      END IF;
	      IF NUM_ERR != 0 THEN
	        RETURN NUM_ERR;
	      END IF;
	      -- Se crea una nueva línea.
	      NUM_ERR := F_CREAR_LIQLINCIA(PNLIQMEN,NEWLIQMEN,R_LIQLIN_PDTE.NLIQLIN,NEWLIQLIN,
					    R_LIQLIN_PDTE.NRECIBO,R_LIQLIN_PDTE.NNUMLIN,R_LIQLIN_PDTE.ICOMLIQ,
					    R_LIQLIN_PDTE.IRETENC,R_LIQLIN_PDTE.SMOVREC);
	      IF NUM_ERR != 0 THEN
	        RETURN NUM_ERR;
	      END IF;
	      -- Se incrementa el contador de las líneas.
	      NEWLIQLIN := NEWLIQLIN + 1;
	   END IF;
         END IF;
      END LOOP;
   ELSIF XCVALIDA_IMP = 1 THEN     -- SÍ ES VALIDA (SE LIQUIDA).
      -- Para todas las liquidaciones pendientes:
      FOR R_LIQLIN_PDTE IN C_LIQLIN_PDTE LOOP
	  -- Se trata de un recibo.
         IF R_LIQLIN_PDTE.NRECIBO IS NOT NULL THEN

		-- COMPROBAMOS SI CUMPLE LA RESTRICCION DE FECHAS
                NUM_ERR := F_VALIDA_LIQLINCIA(R_LIQLIN_PDTE.SMOVREC,
                                              PFDATA1, PFDATA31,XCVALIDA_LIQ);

	        IF NUM_ERR != 0 THEN
	          RETURN NUM_ERR;
	        END IF;
                -- No cumple la restricción de fechas, el recibo no debe liquidarse.
	        -- Se crea una nueva cabecera si no existe, se crea una nueva línea y
	        -- se borra la actual. Así queda pendiente para la próxima liquidación.
	        IF XCVALIDA_LIQ = 0 THEN
	           IF NEWLIQMEN = 0 THEN
                      -- Se crea una nueva cabecera.
	             NUM_ERR := F_CREAR_LIQCABCIA;
	           END IF;
	           IF NUM_ERR != 0 THEN
	              RETURN NUM_ERR;
	           END IF;
		   -- Se crea una nueva línea.
	           NUM_ERR := F_CREAR_LIQLINCIA(PNLIQMEN,NEWLIQMEN,R_LIQLIN_PDTE.NLIQLIN,NEWLIQLIN,
					    R_LIQLIN_PDTE.NRECIBO,NULL,R_LIQLIN_PDTE.ICOMLIQ,
					    R_LIQLIN_PDTE.IRETENC,R_LIQLIN_PDTE.SMOVREC);
	           IF NUM_ERR != 0 THEN
	              RETURN NUM_ERR;
	           END IF;
		   -- Se incrementa el contador de las líneas.
	           NEWLIQLIN := NEWLIQLIN + 1;
                END IF;

         ELSIF R_LIQLIN_PDTE.NNUMLIN IS NOT NULL THEN -- ES UNA LINEA DE CTACTESCIA
	    BEGIN
	      SELECT CDEBHAB, IIMPORT
	        INTO XCDEBHAB, XIIMPORT
	        FROM CTACTESCIA
	       WHERE CCOMPANI = PCCOMPANI
		AND CEMPRES = PCEMPRES
		AND NNUMLIN = R_LIQLIN_PDTE.NNUMLIN;
	    EXCEPTION
	      WHEN NO_DATA_FOUND THEN
	        RETURN 110188;	-- Línia de compte corrent de la companyía no trobada
	      WHEN OTHERS THEN
	        RETURN 110185;			-- Error al llegir de la taula CTACTESCIA
	    END;
	    -- El importe no puede ser negativo.
	    IF XIIMPORT < 0 THEN
	      RETURN 101947;  --ERROR EN LA CONSISTENCIA DE LA BD
	    ELSE
	      -- Si la línea existente es de debe, se inserta una de haber.
	      IF XCDEBHAB = 1 THEN    -- DEBE
	        XCDEBHAB := 2;
	      -- Si la línea existente es de haber, se inserta una de debe.
	      ELSIF XCDEBHAB = 2 THEN
	        XCDEBHAB := 1;
	      ELSE
	        RETURN 101947;        -- ERROR EN LA CONSISTENCIA DE LA BD
	      END IF;
	    END IF;
	    BEGIN
	      -- Se cambia el estado de la línea a liquidada.
	      UPDATE CTACTESCIA
	         SET CESTADO = 0
	       WHERE CCOMPANI = PCCOMPANI
		AND CEMPRES = PCEMPRES
		AND NNUMLIN = R_LIQLIN_PDTE.NNUMLIN;
	    EXCEPTION
	      WHEN OTHERS THEN
		  RETURN 110184;  -- Error al modificar la taula CTACTESCIA
	    END;
	    BEGIN
              SELECT cconcta,ndocume,nsinies,tdescrip
              INTO   concepto,docume,sinies,descrip
              FROM   ctactescia
              WHERE CCOMPANI = PCCOMPANI
              AND CEMPRES = PCEMPRES
              AND NNUMLIN = R_LIQLIN_PDTE.NNUMLIN;
            EXCEPTION
              WHEN others THEN
                  concepto := 7;
                  docume := null;
                  sinies := null;
                  descrip := null;
            END;
	    -- Cambio de conceptos.
	    -- 1: Devengo comisiones.
	    -- 2: Liquidación de comisiones.
	    -- 3: Diferencia de comisiones.
	    -- 4: Anticipo comisiones (a cta.).
	    -- 5: Pago siniestro.
	    -- 6: Diferencia siniestros.
	    -- 7: Diferencia de recibos.
	    -- 8: Liquidación de un siniestro.
	    -- 9: Anulación de pago de siniestro.
            IF concepto = 1 THEN
              concepto := 2;
            ELSIF concepto = 7 THEN
              concepto := 3;
            ELSIF concepto = 4 THEN
              concepto := 2;
            ELSIF concepto = 6 THEN
              concepto := 8;
            ELSIF concepto IN (5,9) THEN
              concepto := 8;
              begin
                  UPDATE PAGOSINI
                  SET    CESTPAG = 2, FEFEPAG = PFMOVINI
                  WHERE  SIDEPAG = TO_NUMBER(DOCUME);
              exception
                  WHEN others THEN
                       NULL;
              end;
            END IF;
	    BEGIN
	      INSERT INTO CTACTESCIA(CCOMPANI, CEMPRES, NNUMLIN, CCONCTA, CDEBHAB,
	  	                    FFECMOV, CESTADO, IIMPORT, CMANUAL,
                                NDOCUME, NLIQMEN, NLIQLIN,NSINIES,TDESCRIP)
		VALUES (PCCOMPANI, PCEMPRES, NEWCTALIN, CONCEPTO, XCDEBHAB, SYSDATE,
			  0, XIIMPORT, 0,
                    DOCUME,LPAD(PNLIQMEN, 4, '0'),LPAD(R_LIQLIN_PDTE.NLIQLIN,4,'0'),SINIES,DESCRIP);
              NEWCTALIN := NEWCTALIN + 1;
	    EXCEPTION
	  	WHEN DUP_VAL_ON_INDEX THEN
	    	 RETURN 110186;		-- Registres duplicats a la taula CTACTESCIA
	  	WHEN OTHERS THEN
	    	 RETURN 110187;		-- Error a l' inserir a la taula CTACTESCIA
	    END;
         END IF;
      END LOOP;
	-- SE GRABA LA LIQUIDACIÓN DE LOS RECIBOS EN CTACTESCIA
      IF NVL(XTOTCOML,0) != 0 THEN
         XCDEBHAB := 1;               -- MOVIMIENTO INICIAL: DEBE
         IF XTOTCOML < 0 THEN
	    XTOTCOML := 0 - XTOTCOML;
            XCDEBHAB := 2;             -- SI ES NEGATIVO LO PONEMOS EN EL HABER
         END IF;
         BEGIN
	    -- Se inserta en ctactescia con concepto 2 (Liquidación comisiones) y
	    -- estado 0 (liquidado). Se inserta para el total calculado.
	    INSERT INTO CTACTESCIA(CCOMPANI, CEMPRES, NNUMLIN, CCONCTA, CDEBHAB,
		 FFECMOV, CESTADO, TDESCRIP, IIMPORT, CMANUAL, NDOCUME)
	    VALUES (PCCOMPANI, PCEMPRES, NEWCTALIN, 2, XCDEBHAB, SYSDATE, 0, ' ', XTOTCOML,
		  0,NULL);
            NEWCTALIN := NEWCTALIN + 1;
         EXCEPTION
	  	WHEN DUP_VAL_ON_INDEX THEN
	    	 RETURN 110186;		-- Registres duplicats a la taula CTACTESCIA
	  	WHEN OTHERS THEN
	    	 RETURN 110187;		-- Error a l' inserir a la taula CTACTESCIA
         END;
         BEGIN
	    -- Se inserta en ctactescia con concepto 1 (Devengo de comisiones) y
	    -- estado 0 (liquidado). Se inserta para el total calculado.
	    -- Si la anterior inserción ha sido de haber, se inserta de debe y
	    -- al contrario.
	    INSERT INTO CTACTESCIA(CCOMPANI, CEMPRES, NNUMLIN, CCONCTA, CDEBHAB,
		FFECMOV, CESTADO, TDESCRIP, IIMPORT, CMANUAL, NDOCUME)
	    VALUES (PCCOMPANI, PCEMPRES, NEWCTALIN, 1, DECODE(XCDEBHAB,1,2,2,1),
                    SYSDATE, 0, ' ', XTOTCOML, 0, NULL);
                   NEWCTALIN := NEWCTALIN + 1;
         EXCEPTION
	  	WHEN DUP_VAL_ON_INDEX THEN
	    	 RETURN 110186;		-- Registres duplicats a la taula CTACTESCIA
	  	WHEN OTHERS THEN
	    	 RETURN 110187;		-- Error a l' inserir a la taula CTACTESCIA
         END;
   END IF;
   -- SE LIQUIDA CTACTESCIA QUE QUEDE PENDIENTE.(SI LLEGA AQUÍ ES PORQUE HAY ALGO QUE LIQUIDAR)
   -- CUANDO UNA CTACTESCIA SE LIQUIDA SE DEBE AÑADIR EN LIQUIDALINCIA
   -- PARA QUE SE MUESTRE EN EL LISTADO.
   BEGIN
      SELECT NVL(MAX(NLIQLIN),0) + 1
        INTO NEWLIQLINOLD
      FROM LIQUIDALINCIA
      WHERE CEMPRES = PCEMPRES
       AND CCOMPANI = PCCOMPANI
       AND NLIQMEN = PNLIQMEN;
   EXCEPTION
    WHEN OTHERS THEN
       RETURN 110179;  -- Error al llegir de la taula LIQUIDALINCIA
   END;

   -- Para las líneas pendientes de ctactescia y que no dependen de liquidalincia:
   FOR R_LIQCTA_PDTE IN C_LIQCTA_PDTE LOOP
      BEGIN
       -- Modifica la línea de ctactescia para asignarle estado liquidado.
       UPDATE CTACTESCIA
       SET CESTADO = 0
       WHERE CCOMPANI = PCCOMPANI
          AND CEMPRES = PCEMPRES
          AND NNUMLIN = R_LIQCTA_PDTE.NNUMLIN;
      EXCEPTION
	    WHEN OTHERS THEN
	      RETURN 110184;  -- Error al modificar la taula CTACTESCIA
      END;
	  -- SE INSERTA LIQUIDACIÓN DE SIGNO CONTRARIO Y ESTADO LIQUIDADO.
	  BEGIN
	    INSERT INTO CTACTESCIA(CCOMPANI, CEMPRES, NNUMLIN, CCONCTA, CDEBHAB,
		 FFECMOV, CESTADO, TDESCRIP, IIMPORT, CMANUAL, NDOCUME
		 ,NSINIES, SIDEPAG) -- Si no se graba el siniestro, no se encontrará con la referencia de liquidalincia.
	    VALUES (PCCOMPANI, PCEMPRES, NEWCTALIN, R_LIQCTA_PDTE.CCONCTA,
                    DECODE(R_LIQCTA_PDTE.CDEBHAB,1,2,2,1), SYSDATE,
                    0, R_LIQCTA_PDTE.TDESCRIP, R_LIQCTA_PDTE.IIMPORT, 0, R_LIQCTA_PDTE.NDOCUME,
                    R_LIQCTA_PDTE.NSINIES, R_LIQCTA_PDTE.SIDEPAG);

           -- Se crea una línea en liquidalincia para que pueda mostrarse esta liquidación en
           -- el listado.
           NUM_ERR:= F_CREAR_LIQLINCIA(NULL,PNLIQMEN,NULL,NEWLIQLINOLD,NULL,
                             NEWCTALIN,NULL,NULL,NULL);
           IF NUM_ERR != 0 THEN
              RETURN NUM_ERR;
           END IF;
	    NEWLIQLINOLD := NEWLIQLINOLD + 1;
	    NEWCTALIN    := NEWCTALIN + 1;
	  EXCEPTION
	  	WHEN DUP_VAL_ON_INDEX THEN
	    	 RETURN 110186;		-- Registres duplicats a la taula CTACTESCIA
	  	WHEN OTHERS THEN
	    	 RETURN 110187;		-- Error a l' inserir a la taula CTACTESCIA
	  END;
   END LOOP;
END IF;
-- ***************************************************************
-- TRATAMIENTO DE LAS LIQUIDACIONES DE RECIBOS EN ESTADO RETENIDO.
-- ***************************************************************
-- SE CUELGAN DE LA NUEVA Y SE DEJAN DES-RETENIDAS.
FOR R_LIQLIN_RET IN C_LIQLIN_RET LOOP
-- SE INSERTA REGISTRO SÓLO SI EXISTE ALGÚN REGISTRO EN ESTADO RETENIDO
-- EN LA TABLA LIQUIDALINCIA Y NO SE HA INSERTADO PREVIAMENTE.
	IF NEWLIQMEN = 0 THEN
	  NUM_ERR := F_CREAR_LIQCABCIA;
	  IF NUM_ERR != 0 THEN
	    RETURN NUM_ERR;
	  END IF;
	END IF;
	IF R_LIQLIN_RET.NRECIBO IS NOT NULL OR
	   R_LIQLIN_RET.NNUMLIN IS NOT NULL THEN -- LIQUIDACIÓN DE RECIBO O CTACTESCIA RETENIDA
	  NUM_ERR := F_CREAR_LIQLINCIA(PNLIQMEN,NEWLIQMEN,R_LIQLIN_RET.NLIQLIN,NEWLIQLIN,
				          R_LIQLIN_RET.NRECIBO,R_LIQLIN_RET.NNUMLIN,
R_LIQLIN_RET.ICOMLIQ,R_LIQLIN_RET.IRETENC,
R_LIQLIN_RET.SMOVREC);
	  IF NUM_ERR != 0 THEN
	    RETURN NUM_ERR;
	  END IF;
	  NEWLIQLIN := NEWLIQLIN + 1;
	END IF;
END LOOP;
--END IF;
RETURN 0;
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_LIQUIDALIQCIA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_LIQUIDALIQCIA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_LIQUIDALIQCIA" TO "PROGRAMADORESCSI";
