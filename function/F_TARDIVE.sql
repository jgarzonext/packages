--------------------------------------------------------
--  DDL for Function F_TARDIVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_TARDIVE" (pctarifa IN NUMBER, pccolum IN NUMBER, pcfila IN NUMBER,
	pctipatr IN NUMBER, picapital IN  NUMBER,
	piextrap IN NUMBER, preg1 IN NUMBER, preg2 IN NUMBER, preg97 IN NUMBER,
	pactivi IN NUMBER, ptarifar IN NUMBER, pipritar IN OUT NUMBER, atribu IN OUT NUMBER,
	piprima IN OUT NUMBER, moneda IN NUMBER)
RETURN NUMBER authid current_user IS
/***********************************************************************
	F_TARDIVE: Calcula la prima anual de una garantía
	ALLIBCTR
	Modificació: Afegim la moneda
	Modificació: Afegim la pregunta 97
	Modificació: Afegim l'activitat de l'assegurança (com si fos una resposta més)
	Modificació: Se añade el parámetro ptarifar.
***********************************************************************/
	pvcolum	NUMBER;
	pvfila	NUMBER;
	error		NUMBER:=0;
BEGIN
	IF ptarifar = 1 THEN  -- si se tarifa
		IF pccolum IS NULL THEN
			pvcolum := 0;
		ELSIF pccolum = 9 THEN
			pvcolum := preg2;
		ELSIF pccolum = 11 THEN
			pvcolum := pactivi;
		ELSE
			error := 101950;
		END IF;
		IF pcfila IS NULL THEN
			pvfila := 0;
		ELSIF pcfila = 13 THEN
			pvfila := preg1;
		ELSIF pcfila = 11 THEN
			pvfila := preg97;
		END IF;
		IF error = 0 THEN
			error := f_tarifas (pctarifa, pvcolum, pvfila, pctipatr,
				picapital, piextrap,pipritar, atribu, piprima, moneda);
		END IF;
	END IF;
	-- Arrodonim a partir de la moneda
	piprima := f_round (piprima, moneda);
	RETURN error;
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_TARDIVE" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_TARDIVE" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_TARDIVE" TO "PROGRAMADORESCSI";
