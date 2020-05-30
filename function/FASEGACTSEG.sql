--------------------------------------------------------
--  DDL for Function FASEGACTSEG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."FASEGACTSEG" (nsesion  IN NUMBER,
       	  		                  pperson  IN NUMBER,
                                          pssegur  IN NUMBER,
                                          pffecha  IN NUMBER)
  RETURN NUMBER authid current_user IS
/******************************************************************************
   NOMBRE:       FASEGACTSEG
   DESCRIPCION:  Valida si un asegurado esta activo en el seguro en una fecha
                 determinada.

   PARAMETROS:
   INPUT: NSESION(number) --> Nro. de sesión del evaluador de fórmulas
          PPERSON(number) --> Clave del asegurado
          PSSEGUR(number) --> Clave del seguro
          PFECHA(DATE)    --> Fecha
   RETORNA VALUE:
          VALOR(NUMBER)-----> 0-Si que esta activo
                              1-No esta activo
******************************************************************************/
valor    number;
xfecini  date;
xfecfin  date;
pfecha   date;
BEGIN
   valor := NULL;
   pfecha := to_date(pffecha,'yyyymmdd');
   BEGIN
    SELECT ffecini, ffecfin
      INTO xfecini, xfecfin
      FROM ASEGURADOS
     WHERE SSEGURO = pssegur
       AND SPERSON = pperson;
   IF xfecini <= pfecha and xfecfin IS NULL THEN
      RETURN 0;
   ELSIF xfecini > pfecha THEN
      RETURN 1;
   ELSIF xfecfin <= pfecha THEN
      RETURN 1;
   ELSE
      RETURN 0;
   END IF;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN  RETURN NULL;
     WHEN OTHERS THEN         RETURN NULL;
   END;
END FASEGACTSEG;
 
 

/

  GRANT EXECUTE ON "AXIS"."FASEGACTSEG" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."FASEGACTSEG" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."FASEGACTSEG" TO "PROGRAMADORESCSI";
