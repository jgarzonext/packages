--------------------------------------------------------
--  DDL for Function F_IMPORTECOA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_IMPORTECOA" (psseguro IN NUMBER, pncuacoa IN NUMBER,
	pimptotal IN NUMBER, pcompan IN NUMBER, ppcescoa IN NUMBER,
	pmoneda IN NUMBER, pimpcomp IN OUT NUMBER)
RETURN NUMBER authid current_user IS
/***************************************************************************
	F_IMPORTECOA: Función que retorna el importe correspondiente a
		la cesión de la compañía (pcompan) del importe total (pimptotal)
		para el cuadro (pncuacoa). Si el parámetro pcompan és nulo
		retornará el importe correspondiente a nuestra parte.
	ALLIBCOA
***************************************************************************/
	xpcescoa	NUMBER;
	xsum		NUMBER;
	CURSOR particip IS
	  SELECT ccompan, pcescoa
	  FROM coacedido
	  WHERE sseguro = psseguro
	  AND ncuacoa = pncuacoa;
BEGIN
	IF pcompan is null THEN
	-- queremos el importe correspondiente a nuestra parte
		xsum := 0;
		FOR par IN particip LOOP
			pimpcomp := pimptotal * par.pcescoa / 100;
			pimpcomp := f_round(pimpcomp,pmoneda);
			xsum := xsum + pimpcomp;
		END LOOP;
		pimpcomp := pimptotal - xsum;
	ELSE
	-- queremos el importe de una de las compañias contrarias coaseguradoras
	  IF ppcescoa IS NULL THEN
		BEGIN
			SELECT pcescoa
			INTO xpcescoa
			FROM coacedido
			WHERE sseguro = psseguro
			AND ncuacoa = pncuacoa
			AND ccompan = pcompan;
		EXCEPTION
			WHEN OTHERS THEN
				RETURN 105714;
		END;
	  ELSE
		xpcescoa := ppcescoa;
	  END IF;
	  pimpcomp := pimptotal * xpcescoa / 100;
	  pimpcomp := f_round(pimpcomp,pmoneda);
	END IF;
	RETURN 0;
EXCEPTION
	WHEN OTHERS THEN
		RETURN 105715;
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_IMPORTECOA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_IMPORTECOA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_IMPORTECOA" TO "PROGRAMADORESCSI";
