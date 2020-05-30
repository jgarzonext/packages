--------------------------------------------------------
--  DDL for Function F_TARVIDA_ULK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_TARVIDA_ULK" (pctarifa IN NUMBER, pccolum IN NUMBER, pcfila IN NUMBER,
	pctipatr IN NUMBER, picapital IN  NUMBER,
	piextrap IN NUMBER, edat IN NUMBER, sexper IN NUMBER,
	edat2 IN NUMBER, sexper2 IN NUMBER,
	preg1 IN NUMBER, preg5 IN NUMBER, preg109 IN NUMBER,
	pipritar IN OUT NUMBER, atribu IN OUT NUMBER,
	piprima IN OUT NUMBER, moneda IN NUMBER)
	RETURN NUMBER IS
/***********************************************************************
	F_TARVIDA: Calcula la prima anual de una garantía
	ALLIBCTR

	LLamamos a la función f_tarifa
		Passarem l'edat i el sexe com a paràmetre doncs ja
		s'ha calculat dintre del programa
	El grup de la pregunta 1 serà el codi de la tarifa
	Afegim més paràmetres (PDTOCOM, IPRITAR, IRECARG, IDTOCOM)
	Els descomptes i els recàrrecs es faràn fora d'aquesta
		funció
	Afegim la moneda
	Afegim la pregunta 5
	Afegim la pregunta 109
	Modifiquem la funció per que calculi la tarifa per
        assegurances a dos caps. Es multipliquen les tases.
***********************************************************************/
	pvcolum	NUMBER;
	pvfila	NUMBER;
	pvcolum2 NUMBER;
	pvfila2	NUMBER;
	error		NUMBER:=0;
	porcen	NUMBER;
	respue	NUMBER;
BEGIN
        --PRIMER ASEGURADO
	IF pccolum IS NULL THEN
		pvcolum := 0;
	ELSIF pccolum = 1 THEN
		pvcolum := sexper;
	ELSIF pccolum = 2 THEN
		pvcolum := preg5;
	ELSIF pccolum = 10 THEN
		pvcolum := preg109;
	ELSE
		error := 101950;
	END IF;
	IF pcfila IS NULL THEN
		pvfila := 0;
	ELSE
		IF pcfila = 1 THEN
			pvfila := edat;
		ELSIF pcfila = 2 THEN
			IF edat BETWEEN 15 AND 44 THEN
				pvfila := 1;
			ELSIF edat BETWEEN 45 AND 54 THEN
				pvfila := 2;
			ELSIF edat BETWEEN 55 AND 65 THEN
				pvfila := 3;
			END IF;
		ELSE
			error := 101950;
		END IF;
	END IF;
        --SEGUNDO ASEGURADO
	IF pccolum IS NULL THEN
		pvcolum2 := 0;
	ELSIF pccolum = 1 THEN
		pvcolum2 := sexper2;
	ELSIF pccolum = 2 THEN
		pvcolum2 := preg5;
	ELSIF pccolum = 10 THEN
		pvcolum2 := preg109;
	ELSE
		error := 101950;
	END IF;
	IF pcfila IS NULL THEN
		pvfila2 := 0;
	ELSE
		IF pcfila = 1 THEN
			pvfila2 := edat2;
		ELSIF pcfila = 2 THEN
			IF edat2 BETWEEN 15 AND 44 THEN
				pvfila2 := 1;
			ELSIF edat2 BETWEEN 45 AND 54 THEN
				pvfila2 := 2;
			ELSIF edat2 BETWEEN 55 AND 65 THEN
				pvfila2 := 3;
			END IF;
		ELSE
			error := 101950;
		END IF;
	END IF;
	IF error = 0 THEN
		error := f_tarifas_ulk (pctarifa, pvcolum, pvfila, pvcolum2, pvfila2,
			pctipatr,picapital, piextrap,pipritar, atribu,
			piprima, moneda);
	END IF;
	-- Controlem la edat per la resposta de la 'moto'
	IF preg1 = 1 THEN
		IF edat < 25 THEN
			respue := 1;
		ELSIF edat >= 25 AND edat <= 35 THEN
			respue := 2;
		ELSIF edat > 35 THEN
			respue := 3;
		END IF;
	ELSE
		respue := 0;
	END IF;
	-- Protegim el valor NULL
	porcen := f_prespuesta (1, respue, pctarifa);
	IF porcen IS NOT NULL THEN
		piprima := piprima + piprima * porcen/100;
	END IF;
	-- Redondejem a partir de la moneda
	piprima := f_round (piprima, moneda);
	RETURN error;
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_TARVIDA_ULK" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_TARVIDA_ULK" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_TARVIDA_ULK" TO "PROGRAMADORESCSI";
