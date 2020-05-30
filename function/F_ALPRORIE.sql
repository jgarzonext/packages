--------------------------------------------------------
--  DDL for Function F_ALPRORIE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_ALPRORIE" (psseguro IN NUMBER, pfprovis IN DATE, pgasext IN NUMBER,
pprovisi IN OUT NUMBER)
RETURN NUMBER authid current_user IS
/****************************************************************************
	F_ALPRORIE		Función que calcula la provisión de un seguro
				Parámetros  entrada:
					 sseguro, fecha de provisión, y gastos
	ALLIBCTR		Biblioteca de contratos
****************************************************************************/
	dias		NUMBER;
	fecha		DATE;
	fecha2	DATE;
	prima		NUMBER;
	error		NUMBER;
BEGIN
	BEGIN
		SELECT fcaranu,fvencim,iprianu
		INTO fecha,fecha2,prima
		FROM seguros
		WHERE sseguro=psseguro;
	EXCEPTION
		WHEN OTHERS THEN
			RETURN 1;
	END;
	IF fecha IS NULL THEN
		fecha:=fecha2;
		IF fecha IS NULL THEN
			RETURN 1;
		END IF;
	END IF;
	error:=f_difdata(fecha,pfprovis,3,3,dias);
	IF error<>0 THEN
		RETURN error;
	END IF;
	pprovisi:=( (prima-(prima*pgasext))*dias )/360;
	RETURN 0;
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_ALPRORIE" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_ALPRORIE" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_ALPRORIE" TO "PROGRAMADORESCSI";
