--------------------------------------------------------
--  DDL for Function FBUSCACAPGARAN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."FBUSCACAPGARAN" (nsesion  IN NUMBER,
                                            psseguro IN NUMBER,
											pnriesgo IN NUMBER,
                                            pcgarant IN NUMBER)
  RETURN NUMBER authid current_user IS
/******************************************************************************
   NOMBRE:       FBUSCACAPGARAN
   DESCRIPCION:  Busca el capital de una poliza/garantía determinada a fecha fin=NULL.
   PARAMETROS:
   INPUT: NSESION(number) --> Nro. de sesión del evaluador de fórmulas
          PSSEGUR(number) --> Clave del seguro
		  PNRIESGO(number)--> Numero de Riesgo
          PFECHA(date)    --> Clave de la garantía
   RETORNA VALUE:
          VALOR(NUMBER)-----> Capital
******************************************************************************/
valor    number;
BEGIN
   valor := NULL;
   BEGIN
     SELECT icapital
	   INTO valor
	   FROM ESTGARANSEG
	  WHERE sseguro = psseguro
	    AND cgarant = pcgarant
		AND nriesgo = pnriesgo
		AND FFINEFE IS NULL;
     RETURN VALOR;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN RETURN NULL;
	 WHEN OTHERS        THEN RETURN NULL;
   END;
END FBUSCACAPGARAN;
 
 

/

  GRANT EXECUTE ON "AXIS"."FBUSCACAPGARAN" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."FBUSCACAPGARAN" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."FBUSCACAPGARAN" TO "PROGRAMADORESCSI";
