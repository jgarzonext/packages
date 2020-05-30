--------------------------------------------------------
--  DDL for Function F_INTDIARI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_INTDIARI" (pcramo IN NUMBER, pcmodali IN NUMBER, pctipseg IN NUMBER,
			  pccolect IN NUMBER,pdifdata in number,pimport IN NUMBER,
			  pintere IN OUT NUMBER)
RETURN NUMBER authid current_user IS
/****************************************************************************
	F_INTDIARI: Calcula los intereses que se obtienen por un determinado
			importe(pimport) un determinado número de días(pdifdata),
	ALLIBCTR : Módulo de contratos - cierre de mes - cierre mes prod. ahorro
	- Añadir Unit Linked. Los gastos están en otra tabla
*****************************************************************************/
	int_tec_produc	number;
	int_tot		number;
	pintdiar	number;
        xcagrpro        number;
BEGIN
        select cagrpro into xcagrpro
        from PRODUCTOS
	WHERE cramo = pcramo
	AND cmodali = pcmodali
	AND ctipseg = pctipseg
	AND ccolect = pccolect;
-----Miramos que tipo de interes anual tiene que aplicarse, si es el
------marcado por el tipo garantizado o el anual de ahorro------------
        IF xcagrpro = 21 then --Unit Linked
		BEGIN
			SELECT iintgar INTO int_tot
			FROM PARPROGARINT
			WHERE cramo = pcramo
			AND cmodali = pcmodali
			AND ctipseg = pctipseg
			AND ccolect = pccolect
			AND ((finicio < sysdate and ffin > sysdate)
			OR (finicio < sysdate and ffin is null));
		EXCEPTION
			WHEN NO_DATA_FOUND THEN
				RETURN 104743;  -- No hay definido interés en INTERESPROD
		END;
	ELSE
		BEGIN
			SELECT pinttec INTO int_tec_produc
			FROM PRODUCTOS
			WHERE cramo = pcramo
			AND cmodali = pcmodali
			AND ctipseg = pctipseg
			AND ccolect = pccolect;
		EXCEPTION
			WHEN NO_DATA_FOUND THEN
				RETURN 104742;  -- Error al buscar el interés técnico del producto
		END;
		BEGIN
			SELECT pinttot INTO int_tot
			FROM INTERESPROD
			WHERE cramo = pcramo
			AND cmodali = pcmodali
			AND ctipseg = pctipseg
			AND ccolect = pccolect
			AND finivig < sysdate
			AND ffinvig is null;
		EXCEPTION
			WHEN NO_DATA_FOUND THEN
				RETURN 104743;  -- No hay definido interés en INTERESPROD
		END;
	END IF;
-------Fórmula de interes diario-------------------------------------------
        IF xcagrpro = 21 THEN
		pintdiar := POWER((1 + int_tot/100),(1/365));
        ELSE
	 	IF NVL(int_tec_produc,0) > NVL(int_tot,0) THEN
			pintdiar := POWER((1 + int_tec_produc/100),(1/365));
		ELSE
			pintdiar := POWER((1 + int_tot/100),(1/365));
		END IF;
	END IF;
	-------Cálculo del interes---------------------------------------
	pintere := pimport * ((power(pintdiar,pdifdata)- 1));
	RETURN 0;
EXCEPTION
	WHEN OTHERS THEN
		RETURN 102536;   		---Error al calcular los intereses
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_INTDIARI" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_INTDIARI" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_INTDIARI" TO "PROGRAMADORESCSI";
