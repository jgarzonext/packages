--------------------------------------------------------
--  DDL for Function FCAPTARDECR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."FCAPTARDECR" (psesion  IN NUMBER,
       	  		                	    pseguro  IN NUMBER,
                                        pfecha   IN NUMBER,
										pcapital IN NUMBER)
  RETURN NUMBER authid current_user IS
/******************************************************************************
   NOMBRE:       FCAPTARDECR
   DESCRIPCION:  Devuelve el capital en un Tar Decreciente.
   PARAMETROS:
   INPUT: PSESION(number) --> Nro. de sesión del evaluador de fórmulas
          PSEGURO(number) --> Clave del SEGURO a validar
		  PFECHA (number) --> Fecha de calculo
		  PCAPITAL(number)--> Capital actual
   RETORNA VALUE:
          VALOR(NUMBER)-----> #-Capital a asegurar
******************************************************************************/
valor    NUMBER;
valor1   NUMBER;
valor2   NUMBER;
xssegvin NUMBER;
xpfecha  DATE;
BEGIN
-- Busco el sseguro de la póliza asociada
   BEGIN
    SELECT ssegvin
      INTO xssegvin
      FROM SEGUROS_ASSP
     WHERE sseguro = pseguro;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN  RETURN 0;
     WHEN OTHERS THEN         RETURN NULL;
   END;
-- Busco el ultimo saldo.
   valor  := NULL;
   valor1 := NULL;
   XPFECHA := TO_DATE(pfecha,'yyyymmdd');
   BEGIN
   SELECT imovimi
     INTO VALOR1
     FROM ctaseguro
    WHERE sseguro = xssegvin
      AND cmovimi = 0
      AND fvalmov = (SELECT max(fvalmov)
                       FROM ctaseguro
                      WHERE sseguro = xssegvin
                        AND cmovimi = 0
                        AND fvalmov<= XPFECHA);
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
	       VALOR1 := 0;
     WHEN OTHERS THEN
	       RETURN NULL;
   END;
-- Busco el ultimo saldo a fecha del año anterior.
   valor2  := NULL;
   XPFECHA := ADD_MONTHS(TO_DATE(pfecha,'yyyymmdd'),-12);
   BEGIN
   SELECT imovimi
     INTO VALOR2
     FROM ctaseguro
    WHERE sseguro = xssegvin
      AND cmovimi = 0
      AND fvalmov = (SELECT max(fvalmov)
                       FROM ctaseguro
                      WHERE sseguro = xssegvin
                        AND cmovimi = 0
                        AND fvalmov<= XPFECHA);
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
	       VALOR2:= 0;
     WHEN OTHERS THEN
	       RETURN NULL;
   END;
   VALOR := PCAPITAL - (VALOR1 - VALOR2);
   RETURN VALOR;
END FCAPTARDECR;
 
 

/

  GRANT EXECUTE ON "AXIS"."FCAPTARDECR" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."FCAPTARDECR" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."FCAPTARDECR" TO "PROGRAMADORESCSI";
