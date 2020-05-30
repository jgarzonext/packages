--------------------------------------------------------
--  DDL for Function F_TARTRAN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_TARTRAN" (pctarifa IN NUMBER, pccolum IN NUMBER, pcfila IN NUMBER,
	pctipatr IN NUMBER, picapital IN  NUMBER,
	piextrap IN NUMBER, ppreg60 IN NUMBER, ppreg61 IN NUMBER,
	ppreg62 IN NUMBER, ppreg63 IN NUMBER, ppreg64 IN NUMBER,
	ppreg65 IN NUMBER, ppreg66 IN NUMBER, ppreg78 IN NUMBER,
	ppreg79 IN NUMBER, ptarifar IN NUMBER, pipritar IN OUT NUMBER,
	atribu IN OUT NUMBER, piprima IN OUT NUMBER, moneda IN NUMBER)
RETURN NUMBER authid current_user IS
/***********************************************************************
	F_TARTRAN: Calcula la prima anual d'una garantía de transports
	ALLIBCTR
	Afegim la moneda
	Se añade el parámetro ptarifar
***********************************************************************/
	pvcolum	NUMBER;
	pvfila	NUMBER;
	error		NUMBER:=0;
	porcen60	NUMBER;
	porcen61	NUMBER;
	porcen62	NUMBER;
	porcen63	NUMBER;
	porcen64	NUMBER;
	porcen65	NUMBER;
	porcen66	NUMBER;
BEGIN
	IF ptarifar = 1 THEN  -- si se tarifa
		IF pccolum IS NULL THEN
			pvcolum := 0;
		ELSIF pccolum = 7 THEN
			pvcolum := ppreg78;
		ELSE
			error := 101950;
		END IF;
		IF pcfila IS NULL THEN
			pvfila := 0;
		ELSIF pcfila = 11 THEN
			pvfila := ppreg79;
		ELSE
			error := 101950;
		END IF;
		IF error = 0 THEN
			error := f_tarifas (pctarifa, pvcolum, pvfila, pctipatr,
			picapital, piextrap, pipritar, atribu, piprima,moneda);
		END IF;
	END IF;
-----------	RECÀRRECS
	porcen60 := f_prespuesta (60, ppreg60, null);
	porcen61 := f_prespuesta (61, ppreg61, null);
	porcen62 := f_prespuesta (62, ppreg62, null);
	porcen63 := f_prespuesta (63, ppreg63, null);
	porcen64 := f_prespuesta (64, ppreg64, null);
	porcen65 := f_prespuesta (65, ppreg65, null);
	porcen66 := f_prespuesta (66, ppreg66, null);
	IF porcen65 > 0 AND porcen66 > 0 THEN
		porcen66 := 15;
	END IF;
	piprima := piprima + piprima * NVL(porcen60/100,0)
		- piprima * NVL(porcen61/100,0) - piprima * NVL(porcen62/100,0)
		- piprima * NVL(porcen63/100,0) + piprima * NVL(porcen64/100,0)
		+ piprima * NVL(porcen65/100,0) + piprima * NVL(porcen66/100,0);
	-- Redondejem a partir de la moneda
	piprima := f_round (piprima, moneda);
	RETURN error;
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_TARTRAN" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_TARTRAN" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_TARTRAN" TO "PROGRAMADORESCSI";
