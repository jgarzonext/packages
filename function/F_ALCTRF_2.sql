--------------------------------------------------------
--  DDL for Function F_ALCTRF_2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_ALCTRF_2" (pedad IN NUMBER, pduracion IN NUMBER, paños IN NUMBER,
ppago IN NUMBER, preval IN NUMBER, pprovi IN OUT NUMBER)
RETURN NUMBER authid current_user IS
/**************************************************************************
	ALCTRF_2	Calculo de la fórmula PI, resultado intermedio,
			para el producto de vida Temporal
			creciente linealmente al 5 o 10% (9921)
			Retorna 0 si todo va bien, sino 1.
	ALLIBCTR	Biblioteca de contratos
**************************************************************************/
	prod		NUMBER;
	a		NUMBER;
	mxxn		NUMBER(15,10);
	mxxk		NUMBER(15,10);
	dxxk		NUMBER(15,10);
	dxx		NUMBER(15,10);
	nxxk		NUMBER(15,10);
	nxxt		NUMBER(15,10);
	rxxk1		NUMBER(15,10);
	rxxn1		NUMBER(15,10);
BEGIN
	BEGIN
		SELECT mx INTO mxxn
		FROM formulas
		WHERE x=(pedad+pduracion);   --  x+n
		SELECT rx INTO rxxn1
		FROM formulas
		WHERE x=(pedad+pduracion+1);   -- x+n+1
		SELECT mx,dx,nx INTO mxxk,dxxk,nxxk
		FROM formulas
		WHERE x=(pedad+paños);    -- x+k
		SELECT rx INTO rxxk1
		FROM formulas
		WHERE  x=(pedad+paños+1);    -- x+k+1
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
--message('m40='||mxxk||'   m44='||mxxn||'   r41='||rxxk1||'   r45='||rxxn1||'   d40='||dxxk);pause;
	prod:=(mxxk-mxxn-(   (nvl(preval,0))*(rxxk1-rxxn1-
		( (pduracion-paños)*mxxn ))    ))/dxxk;
	pprovi:=prod;
	RETURN 0;
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_ALCTRF_2" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_ALCTRF_2" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_ALCTRF_2" TO "PROGRAMADORESCSI";
