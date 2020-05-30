--------------------------------------------------------
--  DDL for Function F_TARIFAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_TARIFAS" (pctarifa IN NUMBER, pvcolum IN NUMBER,
	pvfila IN NUMBER, pctipatr IN NUMBER, picapital IN NUMBER,
	piextrap IN NUMBER, pipritar IN OUT NUMBER,
	atribu IN OUT NUMBER, piprima IN OUT NUMBER, moneda IN NUMBER)
RETURN NUMBER authid current_user IS
/*************************************************************************
	F_TARIFA		Calcula la prima anual de una garantía de una póliza de accidentes
				Retorna 0 si todo va bien, 1 sino
	ALLIBCTR
	Modificació: Afegim més paràmetres (PDTOCOM, IPRITAR, IRECARG, IDTOCOM)
	Modificació: Els descomptes i els recàrrecs es faràn fora d'aquesta funció
	Modificació: Afegim la moneda
	Modificació: Si venim de salut no arrodonim
*************************************************************************/
BEGIN
	BEGIN
		SELECT iatribu
		INTO 	atribu
		FROM 	tarifas
		WHERE ctarifa = pctarifa
			AND nfila = pvfila
			AND ncolumn = pvcolum;
-- No tenim en compte els valors NULL pq. sempre asignem
--			AND (nfila = pvfila OR pvfila = 0)
--			AND (ncolumn = pvcolum OR pvcolum = 0);
	EXCEPTION
		WHEN OTHERS THEN
			RETURN 104255;
	END;
	IF pctipatr = 1 THEN
--		pipritar := atribu;
		piprima := atribu + nvl(piextrap,0);
	ELSIF pctipatr = 2 THEN
--		pipritar := atribu * picapital;
		piprima := (atribu + nvl(piextrap,0)) * picapital;
	END IF;
	-- Arrodonim a partir de la moneda
	IF moneda <> 0 THEN
		piprima := f_round(piprima, moneda);
	END IF;
	-- El pipritar serà el valor de la prima que retorna aquesta funció
	pipritar := piprima;
	RETURN 0;
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_TARIFAS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_TARIFAS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_TARIFAS" TO "PROGRAMADORESCSI";
