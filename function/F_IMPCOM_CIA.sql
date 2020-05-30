--------------------------------------------------------
--  DDL for Function F_IMPCOM_CIA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_IMPCOM_CIA" (PNPROCES IN NUMBER, PNRECIBO IN NUMBER,
		PMODO IN VARCHAR2, PNRIESGO IN NUMBER, PCOMISI IN NUMBER) RETURN NUMBER
authid current_user IS

/* ******************************************************************
 Inserta en Detrecibos las comisiones
 de la compañía.

*************************************************************************/

	conceptopn	NUMBER := 0;  -- Concepto de Prima Neta.
	conceptocc	NUMBER := 30; -- Concepto de Comisión de Compañía.
	decimals	NUMBER := 0;  -- Número de decimales utilizados en las operaciones.
	importe		NUMBER := 0;  -- Importe de la comisión.

	-- Recupera de Detrecibos la suma de los importes para un recibo y riesgo pasados
	-- por parámetro y concepto=0.
	CURSOR CUR_DETRECIBOS IS
		SELECT SUM(iconcep) ICONCEP,
			 cgarant,
			 nriesgo
		FROM detrecibos
		WHERE nrecibo = pnrecibo AND
--			nriesgo = pnriesgo AND
			cconcep = conceptopn
		GROUP BY nriesgo, cgarant;

	-- Recupera de Detreciboscar la suma de los importes para un proceso, recibo y
	-- riesgo pasados por parámetro y concepto=0.
	CURSOR CUR_DETRECIBOSCAR IS
		SELECT SUM(iconcep) ICONCEP,
			 cgarant,
			 nriesgo
		FROM detreciboscar
		WHERE sproces = pnproces AND
			nrecibo = pnrecibo AND
--			nriesgo = pnriesgo AND
			cconcep = conceptopn
		GROUP BY nriesgo, cgarant;

BEGIN

   IF PCOMISI IS NOT NULL THEN

	IF PMODO = 'R' THEN -- (MODE REAL PRODUCCIÓ I CARTERA)

		FOR CurDetRec IN CUR_DETRECIBOS LOOP

			-- Calculamos la comision de la compañia.
			importe := F_ROUND(((CurDetRec.iconcep * PCOMISI) / 100));

			BEGIN
				INSERT INTO DETRECIBOS (nrecibo, cconcep, iconcep, cgarant, nriesgo)
				VALUES (PNRECIBO, conceptocc, importe, CurDetRec.cgarant, CurDetRec.nriesgo);
			EXCEPTION
				WHEN dup_val_on_index THEN
					-- Registro ya existe. Le sumamos el nuevo importe.
					BEGIN
						UPDATE DETRECIBOS
						SET iconcep = iconcep + importe
						WHERE nrecibo = PNRECIBO
						AND cconcep = conceptocc
						AND cgarant = CurDetRec.cgarant
						AND nriesgo = CurDetRec.nriesgo;
					EXCEPTION
						WHEN OTHERS THEN
							RETURN 104377;	-- Error al actualizar DETRECIBOS
					END;
				WHEN others THEN
					RETURN 103513;	-- Error al insertar en DETRECIBOS
			END;
		END LOOP;


	ELSIF PMODO IN ('P') THEN	-- PROVES(AVANÇ CARTERA)

		FOR CurDetRecCar IN CUR_DETRECIBOSCAR LOOP

			-- Calculamos la comision de la compañia.
			importe := F_ROUND(((CurDetRecCar.iconcep * PCOMISI) / 100));

			BEGIN
				INSERT INTO DETRECIBOSCAR (SPROCES, NRECIBO, CCONCEP, ICONCEP, CGARANT, NRIESGO)
				VALUES (PNPROCES, PNRECIBO, conceptocc, importe, CurDetRecCar.cgarant, CurDetRecCar.nriesgo);
			EXCEPTION
				WHEN DUP_VAL_ON_INDEX THEN
					-- Registro ya existe. Le sumamos el nuevo importe.
					BEGIN
						UPDATE DETRECIBOSCAR
						SET ICONCEP = iconcep + importe
						WHERE SPROCES = PNPROCES
						AND NRECIBO = PNRECIBO
						AND CCONCEP = conceptocc
						AND CGARANT = CurDetRecCar.cgarant
						AND NRIESGO = CurDetRecCar.nriesgo;
					EXCEPTION
						WHEN OTHERS THEN
							RETURN 104378;	-- Error al actualizar DETRECIBOSCAR
					END;
				WHEN OTHERS THEN
				      RETURN 103517;	-- Error al insertar en DETRECIBOSCAR
			END;
		END LOOP;
	END IF;
   END IF;

   RETURN 0;

END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_IMPCOM_CIA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_IMPCOM_CIA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_IMPCOM_CIA" TO "PROGRAMADORESCSI";
