--------------------------------------------------------
--  DDL for Function F_TARCOM1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_TARCOM1" (pctarifa IN NUMBER, pccolum IN NUMBER, pcfila IN NUMBER,
	pctipatr IN NUMBER, picapital IN  NUMBER,
	piextrap IN NUMBER, ppreg37 IN NUMBER, ppreg38 IN NUMBER,
	ppreg39 IN NUMBER, ppreg40 IN NUMBER, ppreg41 IN NUMBER,
	ppreg42 IN NUMBER, ppreg43 IN NUMBER, ppreg44 IN NUMBER,
	ppreg45 IN NUMBER, ppreg46 IN NUMBER, ppreg47 IN NUMBER,
	ppreg48 IN NUMBER, ppreg49 IN NUMBER, cte_cto IN NUMBER,
	pmodali IN NUMBER, pctecnic IN NUMBER, ptarifar IN NUMBER,
	pipritar IN OUT NUMBER, atribu IN OUT NUMBER,
	piprima IN OUT NUMBER,	moneda IN NUMBER)
RETURN NUMBER authid current_user IS
/***************************************************************************
--	ALLIBCTR
	Modificació: Protegim els porcentatges dels valors NULL's
	Modificació: Afegim la tarificació a la modalitat 2
	Modificació: Afegim més paràmetres (PDTOCOM, IPRITAR, IRECARG, IDTOCOM)
	Modificació: Els descomptes i els recàrrecs es faràn fora d'aquesta funció
	Modificació: Afegim la moneda
	Modificació: Afegim la característica cte_cto (Continent o contin)
	             per les tarifes 76 i 77 (columna 12)
	Modificació: La tarifa 99 es calcula a TARCOM2
	Modificació: Tenim en comptes altres modalitats a part de la 1 i la 2
	Modificació: Miramos si a la garantia se le aplican descuentos o descargos.
	Modificació: Añadimos la tarifa 273 (producto de comercio CSA)
	Modificació: Añadimos las nuevas tarifas para CSA
	Modificació: El descuento para robos funciona diferente para CSA
	Modificació: Se añade el parámetro pctarifa, que nos indica si calculamos
	             la tarifa o no.
****************************************************************************/
	error		NUMBER:=0;
	major		NUMBER;
	pvcolum	NUMBER;
	pvfila	NUMBER;
	percen39	NUMBER;
	percen40	NUMBER;
	percen42	NUMBER;
	percen43	NUMBER;
	percen44	NUMBER;
	percen46	NUMBER;
	percen47	NUMBER;
	percen48	NUMBER;
	percen49	NUMBER;
	piprima39	NUMBER;
	piprima40	NUMBER;
	piprima42	NUMBER;
	piprima43	NUMBER;
	piprima44	NUMBER;
BEGIN
    IF pctecnic <> 0 THEN -- Si se tarifa ahora o después en f_tarcom2
	IF pccolum IS NULL THEN
		pvcolum := 0;
	ELSIF pccolum = 12 THEN
		pvcolum := cte_cto;
	ELSE
		RETURN 101950;
	END IF;
	IF pcfila IS NULL THEN
		pvfila := 0;
	ELSIF pcfila = 8 THEN
		pvfila := ppreg38;
	ELSE
		RETURN 101950;
	END IF;
	-- Tenim en compte la modalitat
	IF pmodali <> 2 THEN
		-- Miramos si se le puede aplicar aquí la tarifa o lo haremos más tarde
		--  IF pctarifa <> 91 AND pctarifa <> 92 AND pctarifa <> 93 AND pctarifa <> 99 THEN
 		IF ptarifar = 1 THEN -- si hay que tarifar
			    error := f_tarifas (pctarifa, pvcolum, pvfila, pctipatr,
				picapital,piextrap,pipritar,atribu,piprima,moneda);
		END IF;
    		IF error = 0 THEN
			IF pctarifa = 75 THEN
				  percen39 := nvl(f_prespuesta (39, ppreg39, null),0);
				  percen40 := nvl(f_prespuesta (40, ppreg40, null),0);
				  percen42 := nvl(f_prespuesta (42, ppreg42, null),0);
				  percen43 := nvl(f_prespuesta (43, ppreg43, null),0);
				  percen44 := nvl(f_prespuesta (44, ppreg44, null),0);
				  piprima39 := piprima * percen39/100;
				  piprima40 := piprima * (percen40 * nvl(ppreg41,0)/100);
				  IF percen42 >= percen43 THEN
				    IF percen42 >= percen44 THEN
					major := 42;
				    ELSE
					major := 44;
				    END IF;
				  ELSE
				    IF percen43 >= percen44 THEN
					major := 43;
				    ELSE
					major := 44;
				    END IF;
				  END IF;
				  IF major = 42 THEN
				    percen43 := percen43 * 0.6;
				    percen44 := percen44 * 0.6;
				  ELSIF major =43 THEN
				    percen42 := percen42 * 0.6;
				    percen44 := percen44 * 0.6;
				  ELSE
				    percen42 := percen42 * 0.6;
				    percen43 := percen43 * 0.6;
				  END IF;
				  piprima42 := piprima * percen42/100;
				  piprima43 := piprima * percen43/100;
				  piprima44 := piprima * percen44/100;
				  piprima := piprima + piprima39 + piprima40 - piprima42
					- piprima43	- piprima44;
				  percen47 := nvl(f_prespuesta (47, ppreg47, null),0);
				  piprima := piprima - (piprima * percen47/100);
			ELSIF pctarifa = 273 THEN
				  percen39 := nvl(f_prespuesta (39, ppreg39, null),0);
				  percen40 := nvl(f_prespuesta (40, ppreg40, null),0);
				  percen42 := nvl(f_prespuesta (42, ppreg42, null),0);
				  percen43 := nvl(f_prespuesta (43, ppreg43, null),0);
				  percen44 := nvl(f_prespuesta (44, ppreg44, null),0);
				  piprima39 := piprima * percen39/100;
				  piprima40 := piprima * (percen40 * nvl(ppreg41,0)/100);
				-- Para CSA hacemos otro tratamiento
				  IF percen42 + percen43 + percen44 > 45 THEN
				    percen42 := 45;
				    percen43 := 0;
				    percen44 := 0;
				  END IF;
				  piprima42 := piprima * percen42/100;
				  piprima43 := piprima * percen43/100;
				  piprima44 := piprima * percen44/100;
				  piprima := piprima + piprima39 + piprima40 - piprima42
					- piprima43	- piprima44;
				  percen47 := nvl(f_prespuesta (47, ppreg47, null),0);
				  piprima := piprima - (piprima * percen47/100);
				-- Afegim les noves tarifes pel CSA
			ELSIF pctarifa = 90 OR pctarifa = 288 THEN
				  piprima := piprima * nvl(ppreg37,1);
			ELSIF pctarifa = 73 OR pctarifa = 74 OR
				  pctarifa = 271 OR pctarifa = 272 THEN
				  percen46 := nvl(f_prespuesta (46, ppreg46, null),0);
				  piprima := piprima - (piprima * percen46/100);
			ELSIF pctarifa = 99 OR pctarifa = 292 THEN
				  piprima := piprima * nvl(ppreg45,1);
			END IF;
			RETURN 0;
		ELSE
			RETURN error;
		END IF;
	ELSIF pmodali = 2 THEN
		IF ptarifar = 1 THEN
			error := f_tarifas (pctarifa, pvcolum, pvfila, pctipatr, picapital,
				piextrap, pipritar, atribu, piprima, moneda);
		END IF;
		IF pctarifa NOT IN (102,92,93,99) AND error = 0 THEN
			percen48 := nvl(f_prespuesta (48, ppreg48, null),0);
			IF pctarifa = 106 THEN
				percen49 := nvl(f_prespuesta (49, ppreg49, null),0);
			ELSE
				percen49 := 0;
			END IF;
			piprima := piprima + piprima * percen48/100
				- piprima * percen49/100;
		ELSIF pctarifa = 99 THEN
			piprima := piprima * nvl(ppreg45,1);
		END IF;
		--   IF pctarifa = 111 THEN
		--	piprima := piprima * nvl(ppreg37,1);
		--   END IF;
	END IF;
   ELSE  -- de ctecnic <> 0
	--IF ptarifar = 1 THEN
		piprima := 0;
		error := 0;
	--END IF;
   END IF; -- de pctecnic <> 0
   -- Arrodonim a partir de la moneda
   piprima := f_round (piprima, moneda);
   RETURN error;
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_TARCOM1" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_TARCOM1" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_TARCOM1" TO "PROGRAMADORESCSI";
