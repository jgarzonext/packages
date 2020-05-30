--------------------------------------------------------
--  DDL for Function FRECMANUAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."FRECMANUAL" (psesion  IN NUMBER,
       	  		                       porigen  IN NUMBER,
       	  		                       pseguro  IN NUMBER)
  RETURN NUMBER authid current_user IS
/******************************************************************************
   NOMBRE:       FRECMANUAL
   DESCRIPCION:  Retorna el % de recargo manual.

   PARAMETROS:
   INPUT: PSESION(number) --> Nro. de sesión del evaluador de fórmulas
          PSEGURO(number) --> Clave del SEGURO a validar
   RETORNA VALUE:
          VALOR(NUMBER)-----> #-Porcentaje
******************************************************************************/
valor    number;
xsseguro number;
xnpoliza number;
xprecman number;
BEGIN
   valor := NULL;
   xsseguro := 0;
   xnpoliza := 0;
   IF PORIGEN = 0 THEN
      RETURN 0;
   ELSIF PORIGEN = 1 THEN
      BEGIN
       SELECT npoliza INTO xnpoliza FROM ESTSEGUROS WHERE sseguro = pseguro;
	  EXCEPTION
	    WHEN NO_DATA_FOUND THEN RETURN 0;
		WHEN OTHERS        THEN RETURN NULL;
	  END;
	  BEGIN
	    SELECT sseguro INTO xsseguro FROM SEGUROS WHERE npoliza=xnpoliza;
	  EXCEPTION
	    WHEN NO_DATA_FOUND THEN RETURN 0;
		WHEN OTHERS        THEN RETURN NULL;
	  END;
   ELSE
      xsseguro := pseguro;
   END IF;
--
   BEGIN
    SELECT precman
      INTO xprecman
      FROM CUESTIONARIOS
     WHERE sseguro = xsseguro
	   and nriesgo = 1;

    IF xprecman IS NULL THEN
       xprecman := 0;
    END IF;
	valor := xprecman;
    RETURN VALOR;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN  RETURN 0;
     WHEN OTHERS        THEN  RETURN NULL;
   END;
END FRECMANUAL;
 
 

/

  GRANT EXECUTE ON "AXIS"."FRECMANUAL" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."FRECMANUAL" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."FRECMANUAL" TO "PROGRAMADORESCSI";
