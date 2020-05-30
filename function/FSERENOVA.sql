--------------------------------------------------------
--  DDL for Function FSERENOVA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."FSERENOVA" (psesion  IN NUMBER,
       	  		                      pseguro  IN NUMBER)
  RETURN NUMBER authid current_user IS
/******************************************************************************
   NOMBRE:       FSERENOVA
   DESCRIPCION:  Mira si es renovación o no.

   PARAMETROS:
   INPUT: PSESION(number) --> Nro. de sesión del evaluador de fórmulas
          PSEGURO(number) --> Clave del SEGURO a validar
   RETORNA VALUE:
          VALOR(NUMBER)-----> 0-No es renovación
		                      1-Si es renovación
******************************************************************************/
valor    number;
xfcarpro date;
xfcaranu date;
BEGIN
   valor := NULL;
   BEGIN
    SELECT fcarpro, fcaranu
      INTO xfcarpro, xfcaranu
      FROM SEGUROS
     WHERE sseguro = pseguro;

    IF xfcarpro = xfcaranu THEN
       VALOR := 1;
    ELSE
       VALOR := 0;
    END IF;
   RETURN VALOR;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN  RETURN 0;
     WHEN OTHERS THEN         RETURN NULL;
   END;
END FSERENOVA;
 
 

/

  GRANT EXECUTE ON "AXIS"."FSERENOVA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."FSERENOVA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."FSERENOVA" TO "PROGRAMADORESCSI";
