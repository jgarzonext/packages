--------------------------------------------------------
--  DDL for Function F_TARCOM2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_TARCOM2" (pctarifa IN NUMBER, pticapital IN  NUMBER,
	ppreg45 IN NUMBER, pctecnic IN NUMBER,
	pCmodali IN NUMBER, pctipseg IN NUMBER, ptarifar IN NUMBER,pipritar IN OUT NUMBER,
	atribu IN OUT NUMBER, piprima IN OUT NUMBER, moneda IN NUMBER,
	pcextrap IN NUMBER DEFAULT 0, iextrap IN NUMBER DEFAULT 0)
RETURN NUMBER authid current_user IS
/***************************************************************************
-- ALLIBCTR
	Modificació: Afegim més paràmetres a la funció f_tarifas
	             (el descompte comercial valdrà 0)
	Modificació: Els descomptes i els recàrrecs es faràn fora d'aquesta funció
	Modificació: Afegim la moneda
	Modificació: La tarifa 94 s'ha canviat per la 99
	Modificació: Miramos si a la garantia se le aplican descuentos o descargos.
	Modificació: Afegim la modalitat
	Modificació: Modificamos el segundo intervalo cuando la modalidad es
	             diferente de 1 o el colectivo diferente de 2, a 75000
	Modificació: Añadimos la posibilidad del paso de parametro del valor de la
	             extraprima al calculo de la tarifa.
	Modificació: A partir de ahora está función recibirá cualquier modalidad,
	             debemos hacer que los descuentos solo se los realice a las modalidades adecuadas.
	Modificació: El parametro que recibiamos hasta ahora pccolect debe ser en
	             realidad pctipseg (sólo es un cambio de nombre del parámetro)
	Modificació: Se añade el parámetro ptarifar
***************************************************************************/
	error	NUMBER := 0;
	porcen	NUMBER;
	valextrap	NUMBER;
BEGIN
-- Tenemos en cuenta si ya tenemos calculada la tarifa o no
--   IF pctarifa = 91 THEN
   IF pctecnic = 0 THEN
      IF pctarifa IS NOT NULL THEN
	IF ptarifar = 1 THEN
		-- Cogemos el valor de la extraprima
		IF pcextrap = 0 THEN
			valextrap := 0;
		ELSE
			valextrap := iextrap;
		END IF;
		error := f_tarifas (pctarifa, 0, 0, 1, 0, valextrap, pipritar,
			atribu, piprima, moneda);
	ELSE
		piprima := pipritar;
	END IF;
	IF error = 0 AND (pctarifa = 99 OR pctarifa = 292) THEN
		piprima := piprima * nvl(ppreg45,1);
	END IF;
      END IF;
   ELSIF pcmodali = 1 AND pctipseg = 2 THEN
	IF pticapital > 30000 AND pticapital <= 50000 THEN
		piprima := piprima - piprima * 0.025;
	ELSIF pticapital >= 50001 AND pticapital <= 75000 THEN
		piprima := piprima - piprima * 0.05;
	ELSIF pticapital >= 75001 AND pticapital <= 100000 THEN
		piprima := piprima - piprima * 0.08;
	ELSIF pticapital >= 100001 THEN
		piprima := piprima - piprima * 0.10;
	END IF;
   ELSIF pcmodali = 0 OR (pcmodali = 1 and pctipseg = 0) THEN
	IF pticapital > 35000 AND pticapital <= 50000 THEN
		piprima := piprima - piprima * 0.05;
	ELSIF pticapital >= 50001 AND pticapital <= 75000 THEN
		piprima := piprima - piprima * 0.08;
	ELSIF pticapital >= 75001 AND pticapital <= 100000 THEN
		piprima := piprima - piprima * 0.1;
	ELSIF pticapital >= 100001 THEN
		piprima := piprima - piprima * 0.12;
	END IF;
   END IF;
-- Arrodonim a partir de la moneda
   piprima := f_round (piprima, moneda);
   RETURN error;
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_TARCOM2" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_TARCOM2" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_TARCOM2" TO "PROGRAMADORESCSI";
