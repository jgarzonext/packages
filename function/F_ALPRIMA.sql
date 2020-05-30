--------------------------------------------------------
--  DDL for Function F_ALPRIMA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_ALPRIMA" (pedad IN NUMBER, pduracion IN NUMBER, paños IN NUMBER,
ppago IN NUMBER, pcapital IN NUMBER, pprima IN OUT NUMBER)
RETURN NUMBER authid current_user IS
/**************************************************************************
	ALPRIMA	Calculo de la fórmula para el producto de vida Temporal
			decreciente a primas periódicas.
			Retorna 0 si todo va bien, sino 1.
	ALLIBCTR	Biblioteca de contratos
**************************************************************************/
	prod		NUMBER;
	a		NUMBER;
	dxx		NUMBER(15,10);
	nxxk		NUMBER(15,10);
	nxxt		NUMBER(15,10);
	error		NUMBER;
	prima		NUMBER;
BEGIN
	BEGIN
		SELECT nx INTO nxxk
		FROM formulas
		WHERE x=(pedad+paños);    -- x+k
		SELECT nx INTO nxxt
		FROM formulas
		WHERE x=(pedad+ppago);       -- x+t
		SELECT dx INTO dxx
		FROM formulas
		WHERE x=pedad;			-- x
	EXCEPTION
		WHEN OTHERS THEN
			RETURN 1;
	END;
	error:=f_alctrf_1(pedad,pduracion,paños,ppago,prod);
	IF error<>0 THEN
		RETURN 1;
	END IF;
	a:=(nxxk-nxxt)/dxx;
	prima:=prod/(a*0.76);
-- Multiplicación del resultado por el capital
	pprima:=prima*pcapital;
	RETURN 0;
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_ALPRIMA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_ALPRIMA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_ALPRIMA" TO "PROGRAMADORESCSI";
