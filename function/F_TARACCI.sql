--------------------------------------------------------
--  DDL for Function F_TARACCI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_TARACCI" (pctarifa IN NUMBER, pccolum IN NUMBER, pcfila IN NUMBER,
	pctipatr IN NUMBER, picapital IN  NUMBER,
	piextrap IN NUMBER, edat IN NUMBER,	ppreg2 IN NUMBER,
	ppreg3 IN NUMBER, ppreg4 IN NUMBER, ppreg5 IN NUMBER,
	ppreg118 IN NUMBER, ppreg14 IN NUMBER, ppreg29 IN NUMBER,
	pctecnic IN NUMBER, ptarifar IN NUMBER, pipritar IN OUT NUMBER, atribu IN OUT NUMBER,
	piprima IN OUT NUMBER, moneda IN NUMBER)
RETURN NUMBER authid current_user IS
/*************************************************************************
	F_TARACCI		Calcula la prima anual de una garantía de una
				póliza de accidentes
				Retorna 0 si todo va bien, 1 sino
	ALLIBCTR
	Modificació: LLamamos a la función f_tarifa
	Modificació: Afegim nous parametres
	Modificació: Modifiquem els parametres
	Modificació: Passarem l'edat com a paràmetre doncs ja s'ha calculat dintre del programa
	Modificació: Afegim més paràmetres (PDTOCOM, IPRITAR, IRECARG, IDTOCOM)
	Modificació: Els descomptes i els recàrrecs es faràn fora d'aquesta funció
	Modificació: Afegim la moneda
	Modificació: Añadimos el parámetro PCTECNIC
	Modificació: Añadimos el parámetro ptarifar, que nos indica si pasamos por tarifar o no
	Modificació: Añadimos la pregunta 118 en preg5
*************************************************************************/
	pvcolum	NUMBER;
	pvfila	NUMBER;
	error		NUMBER:=0;
	nacimi	DATE;
	porcen	NUMBER;
BEGIN
	IF ptarifar = 1 THEN
		IF pccolum IS NULL THEN
			pvcolum := 0;
		ELSIF pccolum = 2 THEN
			pvcolum := ppreg5;
		ELSIF pccolum = 16 THEN
			pvcolum := ppreg118;
		ELSE
			error := 101950;
		END IF;
		IF pcfila IS NULL THEN
			pvfila := 0;
		ELSIF pcfila = 2 THEN
			IF pctarifa = 26 THEN
				IF edat <= 34 THEN
					pvfila := 1;
				ELSIF edat > 34 AND edat <= 44 THEN
					pvfila := 2;
				ELSIF edat > 44 AND edat < 55 THEN
					pvfila := 3;
				END IF;
			END IF;
			IF pctarifa = 37 OR pctarifa = 38 THEN
				IF edat < 39 THEN
					pvfila := 1;
				ELSIF edat >= 39 AND edat < 45 THEN
					pvfila := 2;
				ELSIF edat >= 45 AND edat < 52 THEN
					pvfila := 3;
				ELSIF edat >= 52 AND edat < 57 THEN
					pvfila := 4;
				ELSIF edat >= 57 AND edat < 60 THEN
					pvfila := 5;
				ELSIF edat >= 60 AND edat < 63 THEN
					pvfila := 6;
				ELSIF edat >= 63 THEN
					pvfila := 7;
				END IF;
			END IF;
		ELSIF pcfila = 3 THEN
			pvfila := ppreg2;
		ELSIF pcfila = 5 THEN
			pvfila := ppreg14;
		ELSE
			error := 101950;
		END IF;
		IF error = 0 THEN
			error := f_tarifas (pctarifa, pvcolum, pvfila, pctipatr,
				picapital, piextrap, pipritar, atribu, piprima, moneda);
		END IF;
	END IF;
	IF pctecnic = 1 THEN
		porcen := f_prespuesta (4, ppreg4, null);
		IF porcen IS NOT NULL THEN
			piprima := piprima * porcen/100;
		END IF;
		porcen := f_prespuesta (3, ppreg3, null);
		IF porcen IS NOT NULL THEN
			piprima := piprima - (piprima* porcen/100);
		END IF;
		porcen := f_prespuesta (29, ppreg29, null);
		IF porcen IS NOT NULL THEN
			piprima := piprima - piprima * porcen/100;
		END IF;
	END IF;
	-- Arrodonim a partir de la moneda
	piprima := f_round (piprima, moneda);
 	RETURN error;
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_TARACCI" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_TARACCI" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_TARACCI" TO "PROGRAMADORESCSI";
