--------------------------------------------------------
--  DDL for Function FPRTARIFASSP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."FPRTARIFASSP" (nsesion  IN NUMBER,
	   	  		  		   				pseguro  IN NUMBER,
										pcgarant IN NUMBER,
										porigen  IN NUMBER)
  RETURN NUMBER authid current_user IS
/******************************************************************************
   NOMBRE:
   DESCRIPCION:  Prima Tarifa ASSP. Es la misma que viene por cargas.

   PARAMETROS:
   INPUT: NSESION(number) --> Nro. de sesión del evaluador de fórmulas
   RETORNA VALUE:
          NUMBER------------>
******************************************************************************/
valor     number;
BEGIN
   valor := NULL;
   IF PORIGEN = 2 then
      BEGIN
   	    SELECT ipritar
      	 INTO valor
       	 FROM garanseg
      	 WHERE cgarant = pcgarant
	     AND sseguro = pseguro
		 AND ffinefe is null;
   	   EXCEPTION
       	 WHEN OTHERS THEN  RETURN 0;
   	   END;
   ELSIF PORIGEN = 0 THEN
      BEGIN
   	    SELECT ipritar
      	 INTO valor
       	 FROM solgaranseg
      	 WHERE cgarant = pcgarant
	     AND ssolicit = pseguro;
   	   EXCEPTION
       	 WHEN OTHERS THEN  RETURN 0;
   	   END;
   ELSIF PORIGEN = 1 THEN
      BEGIN
   	    SELECT ipritar
      	 INTO valor
       	 FROM estgaranseg
      	 WHERE cgarant = pcgarant
	     AND sseguro = pseguro
		 AND ffinefe is null;
   	   EXCEPTION
       	 WHEN OTHERS THEN  RETURN 0;
   	   END;
   END IF;
   RETURN VALOR;
END FPRTARIFASSP;
 
 

/

  GRANT EXECUTE ON "AXIS"."FPRTARIFASSP" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."FPRTARIFASSP" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."FPRTARIFASSP" TO "PROGRAMADORESCSI";
