--------------------------------------------------------
--  DDL for Function FPOLIZAASOC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."FPOLIZAASOC" (psesion  IN NUMBER,
       	  		                        pseguro  IN NUMBER)
  RETURN NUMBER authid current_user IS
/******************************************************************************
   NOMBRE:       FPOLIZAASOC
   DESCRIPCION:  Mira si tiene póliza asociada.
   PARAMETROS:
   INPUT: PSESION(number) --> Nro. de sesión del evaluador de fórmulas
          PSEGURO(number) --> Clave del SEGURO a validar
   RETORNA VALUE:
          VALOR(NUMBER)-----> 0-No tiene
		                      1-Si tiene
******************************************************************************/
valor    number;
xssegvin number;
BEGIN
   valor := NULL;
   xssegvin := NULL;
   BEGIN
    SELECT ssegvin
      INTO xssegvin
      FROM SEGUROS_ASSP
     WHERE sseguro = pseguro;

    IF xssegvin IS NULL THEN
       VALOR := 0;
    ELSE
       VALOR := 1;
    END IF;
   RETURN VALOR;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN  RETURN 0;
     WHEN OTHERS THEN         RETURN NULL;
   END;
END FPOLIZAASOC;
 
 

/

  GRANT EXECUTE ON "AXIS"."FPOLIZAASOC" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."FPOLIZAASOC" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."FPOLIZAASOC" TO "PROGRAMADORESCSI";
