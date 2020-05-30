--------------------------------------------------------
--  DDL for Function F_TARVIDA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_TARVIDA" (pctarifa IN NUMBER, pccolum IN NUMBER, pcfila IN NUMBER,
	pctipatr IN NUMBER, picapital IN  NUMBER,
	piextrap IN NUMBER, edat IN NUMBER, sexper IN NUMBER,
	preg1 IN NUMBER, preg5 IN NUMBER, preg109 IN NUMBER,
	ptarifar IN NUMBER, pipritar IN OUT NUMBER, atribu IN OUT NUMBER,
	piprima IN OUT NUMBER, moneda IN NUMBER)
RETURN NUMBER authid current_user IS
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
Se añade el parámetro ptarifar
***********************************************************************/
	pvcolum	NUMBER;
	pvfila	NUMBER;
--	sexper	NUMBER;
	nacimi	DATE;
--	edat		NUMBER;
	error		NUMBER:=0;
	porcen	NUMBER;
	respue	NUMBER;
BEGIN
/*	BEGIN
		SELECT csexper, fnacimi
		INTO 	sexper, nacimi
		FROM 	personas
		WHERE sperson = psperson;
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			RETURN 101950;
	END;
*/
	IF ptarifar = 1 THEN  -- si se tarifa
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
/*		error := f_difdata(nacimi, pfiniefe, 2, 1, edat);
		IF error<>0 THEN RETURN error;
		END IF;
*/
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
		IF error = 0 THEN
			error := f_tarifas (pctarifa, pvcolum, pvfila, pctipatr,
			picapital, piextrap,pipritar, atribu, piprima, moneda);
		END IF;
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

  GRANT EXECUTE ON "AXIS"."F_TARVIDA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_TARVIDA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_TARVIDA" TO "PROGRAMADORESCSI";
