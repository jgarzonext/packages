--------------------------------------------------------
--  DDL for Function FCUSUCTO2A2C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."FCUSUCTO2A2C" (nsesion  IN NUMBER,
                                          persona2 IN NUMBER,
                                          cumulo   IN NUMBER,
                                          ncontra  IN NUMBER)
RETURN NUMBER authid current_user IS
/******************************************************************************
   NOMBRE:       FCUSUCTO2A2C
   DESCRIPCION:  Productos a 2 cabezas.
                 Realiza la suma de todas las pólizas que ha contratado el 2º
                 asegurado, de aquellos productos que tienen asignado el mismo
                 cúmulo.

   PARAMETROS:
   INPUT: NSESION(number) --> Nro. de sesión del evaluador de fórmulas
          PERSONA2(number) --> Clave del 2on. asegurado
          CUMULO(number)  --> Clave del cúmulo
          NCONTRA(number) --> Numeros de polizas a contratar. (casi siempre será 1)
   RETORNA VALUE:
          NUMBER------------> #-Nro. de contratos acumulados
******************************************************************************/
valor    NUMBER;
BEGIN
   valor := NULL;
   BEGIN
       BEGIN
        SELECT COUNT(a.sseguro)
          INTO valor
          FROM ASEGURADOS A, SEGUROS S, PRODUCTOS P, CUM_CUMPROD C
         WHERE a.sseguro = s.sseguro
           AND s.csituac IN (8,7,0)
           AND p.cramo   = s.cramo
           AND p.cmodali  = s.cmodali
           AND p.ccolect  = s.ccolect
           AND p.ctipseg  = s.ctipseg
           AND a.ffecfin IS NULL
           AND p.sproduc = c.cproduc
           AND sperson = persona2
           AND ccumulo = cumulo;
       IF VALOR IS NULL THEN
          VALOR := ncontra;
       ELSE
          valor := valor + ncontra;
       END IF;
       RETURN VALOR;
       EXCEPTION
         WHEN NO_DATA_FOUND THEN  RETURN ncontra;
         WHEN OTHERS THEN         RETURN -8;
       END;
   END;
END Fcusucto2a2c;
 
 

/

  GRANT EXECUTE ON "AXIS"."FCUSUCTO2A2C" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."FCUSUCTO2A2C" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."FCUSUCTO2A2C" TO "PROGRAMADORESCSI";
