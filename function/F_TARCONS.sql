--------------------------------------------------------
--  DDL for Function F_TARCONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_TARCONS" (pctarifa IN NUMBER, pccolum IN NUMBER, pcfila IN NUMBER,
	pctipatr IN NUMBER, picapital IN  NUMBER,
	piextrap IN NUMBER, ppreg81 IN NUMBER, ppreg82 IN NUMBER,
	ppreg83 IN NUMBER, ppreg84 IN NUMBER, ppreg87 IN NUMBER,
	ppreg88 IN NUMBER, ppreg89 IN NUMBER,ptarifar IN NUMBER,
	pipritar IN OUT NUMBER, atribu IN OUT NUMBER, piprima IN OUT NUMBER,
	moneda IN NUMBER)
RETURN NUMBER authid current_user IS
/***********************************************************************
	F_TARCONS: Calcula la prima anual d'una garantía de construcció
	ALLIBCTR
	Modificació: Els descomptes i els recàrrecs es faràn fora d'aquesta funció
	Modificació: Afegim la moneda
	Modificació: Se añade el parámetro ptarifar, que nos indica si se tarifa o no
***********************************************************************/
	pvcolum	NUMBER;
	pvfila	NUMBER;
	error		NUMBER:=0;
	porcen83	NUMBER;
	porcen87	NUMBER;
	porcen88	NUMBER;
	porcen89	NUMBER;
BEGIN
	IF ptarifar = 1 THEN -- si se tarifa
		IF pccolum IS NULL THEN
			pvcolum := 0;
		ELSIF pccolum = 8 THEN
			pvcolum := ppreg82;
		ELSE
			error := 101950;
		END IF;
		IF pcfila IS NULL THEN
			pvfila := 0;
		ELSIF pcfila = 12 THEN
			pvfila := ppreg81;
		ELSE
			error := 101950;
		END IF;
		IF error = 0 THEN
			error := f_tarifas (pctarifa, pvcolum, pvfila, pctipatr,
			picapital, piextrap, pipritar, atribu, piprima,moneda);
		END IF;
	END IF;
-----------	RECÀRRECS
	porcen83 := f_prespuesta (83, ppreg83, null);
	porcen87 := f_prespuesta (87, ppreg87, null);
	porcen88 := f_prespuesta (88, ppreg88, null);
	porcen89 := f_prespuesta (89, ppreg89, null);
	piprima := piprima + picapital * NVL(porcen83/100,0) * nvl(ppreg84,0)
		+ piprima * NVL(porcen87/100,0) + piprima * NVL(porcen88/100,0);
	-- Arrodonim a partir de la moneda
	piprima := f_round (piprima, moneda);
	RETURN error;
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_TARCONS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_TARCONS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_TARCONS" TO "PROGRAMADORESCSI";
