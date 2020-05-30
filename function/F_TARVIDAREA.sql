--------------------------------------------------------
--  DDL for Function F_TARVIDAREA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_TARVIDAREA" (pctarifa IN NUMBER, pccolum IN NUMBER,
	pcfila IN NUMBER, pctipatr IN NUMBER, picapital IN NUMBER,
	piextrap IN NUMBER, pedat IN NUMBER, psexe IN NUMBER,
      preg1 IN NUMBER, preg5 IN NUMBER, preg109 IN NUMBER,
      pprecarg IN NUMBER, ppaplica IN NUMBER,
      pipritar IN OUT NUMBER,	atribu IN OUT NUMBER, piprima IN OUT NUMBER,
      moneda IN NUMBER)
RETURN NUMBER authid current_user IS
/*************************************************************************
	F_TARVIDAREA  Calcula la prima anual a reasegurar de una garantía de
                    vida.
	ALLIBREA
*************************************************************************/
      error   NUMBER;
      pvcolum NUMBER;
      pvfila  NUMBER;
      respue  NUMBER;
      porcen  NUMBER;
BEGIN
--    Busquem columna i fila, segons edat, sexe i repostes 1/5/109...
      IF pccolum IS NULL THEN
         pvcolum := 0;
      ELSIF pccolum = 1 THEN
         pvcolum := psexe;
      ELSIF pccolum = 2 THEN
         pvcolum := preg5;
      ELSIF pccolum = 10 THEN
         pvcolum := preg109;
      ELSE
         error := 101950;
      END IF;
      IF pcfila IS NULL THEN
         pvfila := 0;
      ELSIF pcfila = 1 THEN
         pvfila := pedat;
      ELSIF pcfila = 2 THEN
         IF pedat BETWEEN 15 AND 44 THEN
            pvfila := 1;
         ELSIF pedat BETWEEN 45 AND 54 THEN
            pvfila := 2;
         ELSIF pedat BETWEEN 55 AND 65 THEN
            pvfila := 3;
         END IF;
      ELSE
         error := 101950;
      END IF;
--    Busquem la tassa, apliquem el PAPLICA, l'extraprima, la sobreprima...
	BEGIN
		SELECT iatribu
		INTO 	 atribu
		FROM 	 tarifas
		WHERE  ctarifa = pctarifa
		  AND  nfila = pvfila
		  AND  ncolumn = pvcolum;
	EXCEPTION
		WHEN OTHERS THEN
			RETURN 104255;
	END;
                                 -- Apliquen % de reducció sobre prima o taxa
                                 -- bàsica...
      IF nvl(ppaplica,0) <> 0 THEN
         atribu := (atribu * ppaplica) / 100;
      END IF;
                                 -- Calculem la prima + el 80% de l'extraprima...
	IF pctipatr = 1 THEN                 -- Son imports...
         piprima := atribu + (nvl(piextrap,0) * 0.8);
	ELSIF pctipatr = 2 THEN              -- Son taxes...
         piprima := (atribu + (nvl(piextrap,0) * 0.8)) * picapital;
	END IF;
                                 -- Si existeix sobreprima, apliquem
                                 -- el % de la sobreprima sobre la prima...
      IF nvl(pprecarg,0) <> 0 THEN
         piprima := piprima + ((piprima* pprecarg) / 100 );
      END IF;
                                 -- Recàrrec per 'moto'...
      IF preg1 = 1 THEN
         IF pedat < 25 THEN
            respue := 1;
         ELSIF pedat >= 25 AND pedat <= 35 THEN
            respue := 2;
         ELSIF pedat > 35 THEN
            respue := 3;
         END IF;
         porcen := f_prespuesta(1,respue,pctarifa);
         IF porcen IS NOT NULL THEN
            piprima := piprima + ((piprima* porcen) / 100 );
         END IF;
      END IF;
	                           -- Redondejem a partir de la moneda...
	IF moneda <> 0 THEN
		piprima := f_round(piprima, moneda);
	END IF;
                                 -- El pipritar serà el valor de la prima
                                 -- que retorna aquesta funció...
	pipritar := piprima;
	RETURN 0;
END;

 
 

/

  GRANT EXECUTE ON "AXIS"."F_TARVIDAREA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_TARVIDAREA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_TARVIDAREA" TO "PROGRAMADORESCSI";
