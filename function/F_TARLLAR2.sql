--------------------------------------------------------
--  DDL for Function F_TARLLAR2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_TARLLAR2" (pctarifa IN NUMBER, pticapital IN  NUMBER,
	ppreg20 IN NUMBER, ppreg27 IN NUMBER, ppreg28 IN NUMBER,
	pctecnic IN NUMBER, pmodali IN NUMBER,ptarifar IN NUMBER, pipritar IN OUT NUMBER,
	atribu IN OUT NUMBER, piprima IN OUT NUMBER, moneda IN NUMBER,
	pcextrap IN NUMBER DEFAULT 0, iextrap IN NUMBER DEFAULT 0)
RETURN NUMBER authid current_user IS
/***********************************************************************
	F_TGARLLAR: Calcula la prima anual de una garantía de la llar
	ALLIBCTR
	Modificació: Afegim més paràmetres a la funció f_tarifas
		(el descompte comercial valdrà 0)
	Modificació: Els descomptes i els recàrrecs es faràn fora d'aquesta funció
	Modificació: Afegim la moneda
	Modificació: Tenemos en cuenta la modalidad 0, 6
	Modificació: Miramos si a la garantia se le aplican descuentos o
		descargos.
	Modificació: Añadimos las preguntas 113, 114
	Modificació: Añadimos la posibilidad del paso de parametro del
		valor de la extraprima al calculo de la tarifa.
	Modificació: Suprimimos el descuento para la modalidad 6
	Modificació: No se hacen los descuentos de preg113 y preg114, ahora se hacen
		  en f_tarllar1
	Modificació: Se añade el parámetro ptarifar
   Modificació: Se añaden las tarifas del producto Comunidades Prosperity.
                El parámetro pticapital tendrá la suma de capitales (en vez de primas,
                como tienen los demás casos).
***********************************************************************/
	error		NUMBER:=0;
	porcen	NUMBER;
	porcen113	NUMBER;
	porcen114	NUMBER;
	valextrap	NUMBER;
BEGIN
	-- Calculamos las tarifas de las garantias que faltan
	IF pctecnic = 0 THEN
	   IF pctarifa is not null THEN
		IF ptarifar = 1 THEN
			-- Cogemos el valor de la extraprima
			  IF pcextrap = 0 THEN
				valextrap := 0;
			  ELSE
				valextrap := iextrap;
			  END IF;
		 	  IF pctarifa in (49,189) THEN
				error := f_tarifas (pctarifa, nvl(ppreg20,1), 0, 1, 0, valextrap,
					pipritar, atribu, piprima, moneda);
                          ELSE
				error := f_tarifas (pctarifa, 0, 0, 1, 0, valextrap, pipritar,
					atribu, piprima, moneda);
			  END IF;
		ELSE
			piprima := pipritar;
		END IF;
	   END IF;
	ELSE
	   -- No hacemos el descuento si la modalidad es 6
	   --	 IF pmodali IN (0, 2, 6) THEN
	   IF pmodali IN (0,2,4) THEN
		IF pticapital > 35000 AND pticapital <= 50000 THEN
			piprima := piprima - piprima * 0.05;
		ELSIF pticapital >= 50001 AND pticapital <= 70000 THEN
			piprima := piprima - piprima * 0.08;
		ELSIF pticapital >= 70001 AND pticapital <= 100000 THEN
			piprima := piprima - piprima * 0.1;
		ELSIF pticapital >= 100001 THEN
			piprima := piprima - piprima * 0.12;
		END IF;
		porcen := f_prespuesta (27, ppreg27, null);
		-- Estos descuentos ahora se harán en f_tarllar1
		--porcen113 := f_prespuesta (113, ppreg113, pctarifa);
		--porcen114 := f_prespuesta (114, ppreg114, pctarifa);
		piprima := piprima - piprima * nvl(porcen,0)/100;
		porcen:=f_prespuesta(28,ppreg28,null);
		piprima := piprima + piprima * nvl(porcen,0)/100;
           -- Se añade el descuento por capitales elevados para Comunidades Prosperity
           ELSIF pctarifa BETWEEN 1301 AND 1328 THEN
                --
                -- De 150 a 200 millones, 10% de descuento
                --
                IF pticapital BETWEEN 150000000 AND 200000000 THEN
	           piprima := piprima - piprima * 0.1;
                --
                -- De 200 a 500 millones, 15% de descuento
                --
                ELSIF pticapital BETWEEN 200000001 AND 500000000 THEN
	           piprima := piprima - piprima * 0.15;
                --
                -- Más de 500 millones, 20% de descuento
                --
                ELSIF pticapital >= 500000001 THEN
	           piprima := piprima - piprima * 0.2;
                END IF;
	   END IF;
	END IF;
-- No hacemos el descuento si la modalidad es 6
--  IF pmodali IN (0, 2, 6) THEN
	-- No se hace este recargo, ahora es una garantía
	/* IF pmodali in (0, 2) THEN
		porcen := f_prespuesta (28, ppreg28, null);
		IF porcen IS NOT NULL THEN
			piprima := piprima + piprima * porcen/100;
		END IF;
	END IF;
	*/
	-- Arrodonim a partir de la moneda
	piprima := f_round (piprima, moneda);
	RETURN error;
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_TARLLAR2" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_TARLLAR2" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_TARLLAR2" TO "PROGRAMADORESCSI";
