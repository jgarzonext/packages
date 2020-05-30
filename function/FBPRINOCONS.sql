--------------------------------------------------------
--  DDL for Function FBPRINOCONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."FBPRINOCONS" (nsesion  IN NUMBER,
                                            pssegur  IN NUMBER,
                                            pffecha  IN NUMBER)
  RETURN NUMBER authid current_user IS
/******************************************************************************
   NOMBRE:       FBPRINOCONS
   DESCRIPCION:  .
   PARAMETROS:
   INPUT: NSESION(number) --> Nro. de sesión del evaluador de fórmulas
          PSSEGUR(number) --> Clave del seguro
          PFECHA(DATE)    --> Fecha
   RETORNA VALUE:
          VALOR(NUMBER)-----> Importe
******************************************************************************/
xprimaporta number;
xprimconsum number;
pfecha      date;

BEGIN

   xprimaporta := 0;
   xprimconsum := 0;
   pfecha := to_date(pffecha,'yyyymmdd');
-- Averigüo todas las primas aportadas.
   BEGIN
     SELECT sum(iprima)
       INTO xprimaporta
       FROM PRIMAS_APORTADAS
      WHERE sseguro = pssegur
        AND fvalmov <= pfecha;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN RETURN NULL;
     WHEN OTHERS THEN RETURN NULL;
   END;

-- Averigüo todas las primas consumidas.
   BEGIN
     SELECT sum(ipricons)
       INTO xprimconsum
       FROM PRIMAS_CONSUMIDAS
      WHERE sseguro = pssegur
        AND fecha <= pfecha;
     IF xprimconsum IS NULL THEN
	    xprimconsum := 0;
	 END IF;

     RETURN xprimaporta - xprimconsum;  -- Calculo de las primas no consumidas

   EXCEPTION
     WHEN NO_DATA_FOUND THEN
          xprimconsum:=0;
          RETURN xprimaporta - xprimconsum;  -- Calculo de las primas no consumidas
     WHEN OTHERS THEN xprimconsum:=0;
          RETURN xprimaporta - xprimconsum;  -- Calculo de las primas no consumidas
   END;

END FBPRINOCONS;
 
 

/

  GRANT EXECUTE ON "AXIS"."FBPRINOCONS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."FBPRINOCONS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."FBPRINOCONS" TO "PROGRAMADORESCSI";
