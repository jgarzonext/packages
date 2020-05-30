--------------------------------------------------------
--  DDL for Function F_EUROSPESETAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_EUROSPESETAS" (pvalor IN NUMBER, pcdivisa IN NUMBER) RETURN NUMBER  IS
/***********************************************************************
 pvalor --> Valor en pesetas o euros, que se quiere transformar
 pcdivisa --> Codigo de la divisa en el que esta el pvalor

 Siempre transforma  a la divisa contraria a la introducida.

***********************************************************************/
BEGIN
  IF (pcdivisa = 2 ) THEN
    /* Transformamos el pvalor a euros*/
	return( pvalor/166.386);

  ELSIF( pcdivisa = 3)  THEN
    /* Transformamos el pvalor a pesetas*/
	return( 166.386*pvalor );
  ELSE
    return (0);
  END IF;
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_EUROSPESETAS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_EUROSPESETAS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_EUROSPESETAS" TO "PROGRAMADORESCSI";
