--------------------------------------------------------
--  DDL for Function FFALLASEG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."FFALLASEG" (psesion  IN NUMBER,
       	  		                  pperson  IN NUMBER,
                                          pperson2 IN NUMBER,
                                          pssegur  IN NUMBER,
                                          pffecha  IN NUMBER)
  RETURN NUMBER authid current_user IS
/******************************************************************************
   NOMBRE:       FFALLASEG
   DESCRIPCION:  Retorna un valor en función de los asegurados que estan activos
                 en el seguro en una fecha determinada.
   PARAMETROS:
   INPUT: PSESION(number) --> Nro. de sesión del evaluador de fórmulas
          PPERSON(number) --> Clave del 1 asegurado
          PPERSON2(number)--> Clave del 2 asegurado
          PSSEGUR(number) --> Clave del seguro
          PFFECHA(number) --> Fecha
   RETORNA VALUE:
          VALOR(NUMBER)-----> 0-Estan activos los 2
                              1-Esta activo el 1er asegurado
                              2-Esta activo el 2on. asegurado
******************************************************************************/
valor    number;
esta1    number;
esta2    number;
xfecini  date;
xfecfin  date;
BEGIN
   valor := NULL;
   esta1 := FASEGACTSEG(psesion,pperson,pssegur,pffecha);
   esta2 := FASEGACTSEG(psesion,pperson2,pssegur,pffecha);
   IF esta1 = 0 AND esta2 = 0 THEN
      RETURN 0;
   ELSIF esta1 = 0 AND esta2 = 1 THEN
      RETURN 1;
   ELSIF esta1 = 1 AND esta2 = 0 THEN
      RETURN 2;
   ELSE
      RETURN 3;
   END IF;
END FFALLASEG;
 
 

/

  GRANT EXECUTE ON "AXIS"."FFALLASEG" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."FFALLASEG" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."FFALLASEG" TO "PROGRAMADORESCSI";
