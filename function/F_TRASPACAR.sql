--------------------------------------------------------
--  DDL for Function F_TRASPACAR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_TRASPACAR" ( psproces IN NUMBER , pcempres IN NUMBER,
	pcageini IN NUMBER, pcramo IN NUMBER, pcmodali IN NUMBER,
	pctipseg IN NUMBER, pccolect IN NUMBER, pcagefin NUMBER,
	psseguro NUMBER)
RETURN NUMBER authid current_user IS
/***********************************************************************
	F_TRASPACAR			Traspaso de la cartera de un agente
					Retorna 0 si todo va bien
	ALLIBADM
***********************************************************************/
	ageini	NUMBER;
BEGIN
	IF psseguro IS NULL THEN
		BEGIN
			UPDATE seguros SET
			cagente=pcagefin
			WHERE cramo=pcramo
			  AND cmodali=pcmodali
			  AND ctipseg=pctipseg
			  AND ccolect=pccolect
			  AND cagente=pcageini;
		EXCEPTION
			WHEN NO_DATA_FOUND THEN
				RETURN 103133;	--No agente con el producto
			WHEN OTHERS THEN
				RETURN 101916;	--Error en Base de Datos
		END;
	ELSE
		IF (psproces IS NOT NULL AND pcempres IS NOT NULL
			AND pcageini IS NOT NULL AND pcagefin IS NOT NULL) THEN
			BEGIN
				SELECT cagente
				INTO ageini
				FROM seguros
				WHERE sseguro=psseguro;
			EXCEPTION
				WHEN NO_DATA_FOUND THEN
					RETURN 101903;		--El seguro no existe
			END;
			IF ageini<>pcageini THEN
				RETURN 103134;	--No agente con el seguro
			END IF;
			BEGIN
				INSERT INTO traspacar
					(sproces,sseguro,cempres,cageini,cagefin)
				VALUES
					(psproces,psseguro,pcempres,pcageini,pcagefin);
			EXCEPTION
				WHEN OTHERS THEN
					RETURN 101916;	--Error en Base de Datos
			END;
		ELSE
			RETURN 103135;	--No puede haber parametros nulos
		END IF;
	END IF;
	RETURN 0;
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_TRASPACAR" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_TRASPACAR" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_TRASPACAR" TO "PROGRAMADORESCSI";
