--------------------------------------------------------
--  DDL for Function F_FECHCIERRE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_FECHCIERRE" (pcempres IN NUMBER, pfecha IN DATE,
				pfcierre OUT DATE)
RETURN NUMBER authid current_user IS
/***************************************************************************
	F_FECHCIERRE : Retorna la fecha de cierre de la empresa para un
			   ejercicio determinado
	ALLIBADM.
****************************************************************************/
BEGIN
	SELECT fcierre INTO pfcierre
	FROM CIERRES
	WHERE cempres = pcempres
	AND fperini <= pfecha
	AND fperfin >= pfecha;
	RETURN 0;
EXCEPTION
	WHEN NO_DATA_FOUND THEN
		RETURN  0;
	WHEN OTHERS THEN
		RETURN 105025;  -- Fecha cierre no encontrada
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_FECHCIERRE" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_FECHCIERRE" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_FECHCIERRE" TO "PROGRAMADORESCSI";
