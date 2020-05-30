--------------------------------------------------------
--  DDL for Function F_TARLLAR1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_TARLLAR1" (pctarifa IN NUMBER, pccolum IN NUMBER, pcfila IN NUMBER,
	pctipatr IN NUMBER, picapital IN  NUMBER,
	piextrap IN NUMBER, ppreg20 IN NUMBER, ppreg21 IN NUMBER,
	ppreg22 IN NUMBER,
	ppreg24 IN NUMBER, ppreg25 IN NUMBER, ppreg26 IN NUMBER,
	ppreg29 IN NUMBER, ppreg30 IN NUMBER, ppreg31 IN NUMBER,
	ppreg32 IN NUMBER, ppreg33 IN NUMBER, ppreg34 IN NUMBER,
	ppreg35 IN NUMBER, ppreg36 IN NUMBER, ppreg37 IN NUMBER,
	ppreg113 IN NUMBER, ppreg114 IN NUMBER,
	cte_cto IN NUMBER, pctecnic IN NUMBER,
	pmodali IN NUMBER, pprimer_cap IN NUMBER, ptarifar IN NUMBER,
	pipritar IN OUT NUMBER,	atribu IN OUT NUMBER, piprima IN OUT NUMBER,
	moneda IN NUMBER)
RETURN NUMBER authid current_user IS
/***********************************************************************
	F_TARLLAR: Calcula la prima anual de una garantía de la llar
	ALLIBCTR
	Modificació: Afegim nous parametres d'entrada
	Modificació: Afegim més paràmetres (PDTOCOM, IPRITAR, IRECARG, IDTOCOM)
	Modificació: Els descomptes i els recàrrecs es faràn fora d'aquesta funció
	Modificació: Afegim la moneda
	Modificació: Afegim la característica cte_cto (Continent o contin)
		per les tarifes 76 i 77 (columna 12)(1 ctte, 2 ctdo 3 tots 2)
	Modificació: Tenemos en cuenta la modalidad 0 i 6
		Añadimos la pregunta 20 para el producto 6.2.1
	Modificació: Miramos si a la garantia se le aplican descuentos o
		descargos.
	Modificació: Tenemos en cuenta el exceso de propietarios
	Modificació: Se hacen los descuentos de las preguntas 113 y 114.
		     Antes se hacían en f_tarllar2.
	Modificació: Si ptarifar = 0, no se utiliza la función f_tarifas,
		     La pipritar vendrá como parámetro (será la ipritar anterior
		     revalorizada)
   Modificació: Se añade la tarificación para el producto 6-10.
   Modificació: Se añade la tarificación para el producto 13-1-0-0 de Prosperity.
***********************************************************************/
	pvcolum	NUMBER;
	pvfila	NUMBER;
	error		NUMBER:=0;
	porcen21	NUMBER;
	porcen22	NUMBER;
	porcen24	NUMBER;
	porcen25	NUMBER;
	porcen26	NUMBER;
	porcen32	NUMBER;
	porcen33	NUMBER;
	porcen34	NUMBER;
	porcen113	NUMBER;
	porcen114	NUMBER;
        porcen600       NUMBER;
        porcen601       NUMBER;
        porcen602       NUMBER;
        porcen603       NUMBER;
        porcen604       NUMBER;
        porcen605       NUMBER;
        porcen606       NUMBER;
        porcen607       NUMBER;
        porcen610       NUMBER;
        porcen609       NUMBER;
        porcen612       NUMBER;
        porcen1301      NUMBER;
        porcen1302      NUMBER;
        porcen1303      NUMBER;
        porcen1304      NUMBER;
        porcen1305      NUMBER;
        porcen1306      NUMBER;
        porcen1307      NUMBER;
        ppreg600        NUMBER := ppreg20;
        ppreg601        NUMBER := ppreg21;
        ppreg602        NUMBER := ppreg22;
        ppreg603        NUMBER := ppreg24;
        ppreg604        NUMBER := ppreg25;
        ppreg605        NUMBER := ppreg26;
        ppreg606        NUMBER := ppreg36;
        ppreg607        NUMBER := ppreg114;
        ppreg610        NUMBER := ppreg29;
        ppreg609        NUMBER := ppreg113;
        ppreg612	NUMBER := ppreg37;
        ppreg1301       NUMBER := ppreg20;
        ppreg1302       NUMBER := ppreg21;
        ppreg1303       NUMBER := ppreg22;
        ppreg1304       NUMBER := ppreg24;
        ppreg1305       NUMBER := ppreg25;
        ppreg1306       NUMBER := ppreg26;
        ppreg1307       NUMBER := ppreg36;
        porcen_total    NUMBER;
BEGIN
	-- Miramos si calculamos la tarifa o lo hacemos más tarde
	IF pctecnic <> 0 THEN
		-- Miramos si la tarifa es automática para tarifar o no.
		-- Si no tarifamos cogeremos el pipritar y la piprima que nos pasan como parámetro
		IF ptarifar = 1 THEN
			IF pccolum IS NULL THEN
				pvcolum := 0;
			ELSIF pccolum = 3 THEN
				pvcolum := ppreg20;
			ELSIF pccolum = 4 THEN
				pvcolum := ppreg30;
			ELSIF pccolum = 12 THEN
				pvcolum := cte_cto;
			ELSE
				error := 101950;
			END IF;
			IF pcfila IS NULL THEN
				pvfila := 0;
			ELSIF pcfila = 6 THEN
				pvfila := ppreg29;
			ELSIF pcfila = 7 THEN
				pvfila := ppreg31;
			ELSE
				error := 101950;
			END IF;
			IF error = 0 THEN
				error := f_tarifas (pctarifa, pvcolum, pvfila, pctipatr,
					picapital, piextrap, pipritar, atribu, piprima, moneda);
			END IF;
		END IF;  -- de tarifar
		IF pmodali = 1 THEN
                        -- Descuentos/Recargos de Comunidades Prosperity
                        IF pctarifa IN (1301, 1302, 1303) THEN
 			   porcen1301 := f_prespuesta (1301, ppreg1301, null);
			   porcen1302:= f_prespuesta (1302, ppreg1302, null);
			   porcen1303 := f_prespuesta (1303, ppreg1303, null);
                           porcen1304 := f_prespuesta (1304, ppreg1304, null);
			   porcen1305:= f_prespuesta (1305, ppreg1305, null);
			   porcen1306 := f_prespuesta (1306, ppreg1306, null);
                           porcen1307 := f_prespuesta (1307, ppreg1307, null);
                           porcen_total := nvl(porcen1301,0) + nvl(porcen1302,0)
                                         + nvl(porcen1303,0) + nvl(porcen1304,0)
                                         + nvl(porcen1305,0) + nvl(porcen1306,0)
                                         + nvl(porcen1307,0);
                           piprima := piprima + piprima * porcen_total/100;
                        ELSE
			   -- Afegim el càlcul següent per la tarifa 47
			   IF pctarifa = 47 THEN
				piprima := piprima * ppreg37;
			   END IF;
			   -- Protegim el valor NULL
			   porcen21 := f_prespuesta (21, ppreg21, null);
			   porcen22 := f_prespuesta (22, ppreg22, null);
			   piprima := piprima + piprima * NVL(porcen21/100,0)
				      - piprima * NVL(porcen22/100,0);
                        END IF;
		ELSIF pmodali in (0,2,4,6) THEN
			-- Protegim el valor NULL
			porcen24 := f_prespuesta (24, ppreg24, null);
			porcen25 := f_prespuesta (25, ppreg25, null);
			porcen26 := f_prespuesta (26, ppreg26, null);
			piprima := piprima + piprima * NVL(porcen24/100,0) +
			   piprima*NVL(porcen25/100,0) + piprima*NVL(porcen26/100,0);
			-- Se calculan los descuentos de la preg113 y preg114.
			-- (antes se hacían en tarllar2, después del descuento por volumen)
			porcen113 := f_prespuesta (113, ppreg113, pctarifa);
			porcen114 := f_prespuesta (114, ppreg114, pctarifa);
			piprima := piprima - piprima * NVL(porcen113,0)/100
				   - piprima*NVL(porcen114,0)/100;
		ELSIF pmodali in (3,11) THEN
			IF pctarifa = 67 THEN
				piprima := piprima * ppreg36;
			END IF;
			IF pctarifa = 70 THEN
				piprima := piprima * ppreg37;
			END IF;
		-- Tenemos en cuenta el exceso de propietarios en la pregunta correspondiente
		/*	IF pctarifa = 71 THEN
				IF ppreg35 > 10 THEN
					piprima := piprima + (620 * (ppreg35 -10));
				END IF;
		*/	IF pctarifa = 293 THEN
				IF ppreg35 > 10 THEN
					piprima := piprima * (ppreg35 -10);
				ELSE
					piprima := 0;
				END IF;
			ELSE
			   porcen33 := f_prespuesta (33, ppreg33, null);
			   porcen34 := f_prespuesta (34, ppreg34, null);
			   IF pctarifa = 66 THEN
				porcen32 := f_prespuesta (32, ppreg32, null);
				piprima := piprima + piprima * NVL(porcen32/100,0)
				   + piprima*NVL(porcen33/100,0)
				   - piprima*NVL(porcen34/100,0);
			   ELSE
				piprima := piprima + piprima*NVL(porcen33/100,0)
				   - piprima*NVL(porcen34/100,0);
			   END IF;
			   IF pprimer_cap >=100000000 AND pprimer_cap <250000000 THEN
				piprima := piprima - piprima*0.05;
			   ELSIF pprimer_cap >=250000000 AND pprimer_cap <500000000 THEN
				piprima := piprima - piprima*0.1;
			   ELSIF pprimer_cap >= 500000000 THEN
				piprima := piprima - piprima*0.15;
			   END IF;
			END IF;
                ELSIF pmodali = 10 THEN  -- Hogar de Prosperity
                        IF pctarifa IN (650,651, 652, 653, 654, 655, 656) THEN
 			   porcen600 := f_prespuesta (600, ppreg600, null);
			   porcen601:= f_prespuesta (601, ppreg601, null);
			   porcen602 := f_prespuesta (602, ppreg602, null);
                           porcen603 := f_prespuesta (603, ppreg603, null);
			   porcen604:= f_prespuesta (604, ppreg604, null);
			   porcen605 := f_prespuesta (605, ppreg605, null);
                           porcen606 := f_prespuesta (606, ppreg606, null);
			   porcen607:= f_prespuesta (607, ppreg607, null);
                           porcen612:= f_prespuesta (612, ppreg612, null);
                           porcen_total := nvl(porcen600,0) + nvl(porcen601,0) + nvl(porcen602,0)
                                         + nvl(porcen603,0) + nvl(porcen604,0) + nvl(porcen605,0)
                                         + nvl(porcen606,0) + nvl(porcen607,0) + nvl(porcen612,0);
                           piprima := piprima + piprima * porcen_total/100;
                        ELSIF pctarifa IN (657, 658, 659) THEN
                           porcen610 := f_prespuesta (610, ppreg610, null);
                           porcen609 := f_prespuesta (609, ppreg609, null);
                           porcen_total := nvl(porcen610,0) + nvl(porcen609,0);
                           piprima := piprima + piprima * porcen_total/100;
                        END IF;
		END IF;
        ELSIF pctecnic = 0 AND pmodali = 10 THEN -- garantías de Prosperity que no calculan desc/rec
                IF ptarifar = 1 THEN
			IF pccolum IS NULL THEN
				pvcolum := 0;
                        ELSE
				error := 101950;
			END IF;
			IF pcfila IS NULL THEN
				pvfila := 0;
			ELSE
				error := 101950;
			END IF;
			IF error = 0 THEN
				error := f_tarifas (pctarifa, pvcolum, pvfila, pctipatr,
					picapital, piextrap, pipritar, atribu, piprima, moneda);
			END IF;
		END IF;  -- de tarifar
	ELSE  -- de pctecnic <> 0
		--IF ptarifar = 1 THEN
			piprima := 0;
			error := 0;
		--END IF;
	END IF;
	-- Arrodonim a partir de la moneda
	piprima := f_round (piprima, moneda);
	RETURN error;
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_TARLLAR1" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_TARLLAR1" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_TARLLAR1" TO "PROGRAMADORESCSI";
