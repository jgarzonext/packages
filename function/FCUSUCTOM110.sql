--------------------------------------------------------
--  DDL for Function FCUSUCTOM110
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."FCUSUCTOM110" (nsesion  IN NUMBER,
       	  		                  persona1 IN NUMBER,
                                          persona2 IN NUMBER,
                                          cumulo   IN NUMBER,
                                          ncontra  IN NUMBER)
  RETURN NUMBER authid current_user IS
/******************************************************************************
   NOMBRE:       FCUSUCTOM110
   DESCRIPCION:  Realiza la suma de todas las pólizas que ha contratado una
                 determinada persona o dos, de aquellos productos que tienen
                 asignado el mismo cúmulo y además de la modalidad = 110.

   PARAMETROS:
   INPUT: NSESION(number) --> Nro. de sesión del evaluador de fórmulas
          PERSONA1(number) --> Clave del 1er. asegurado
          PERSONA2(number) --> Clave del 2on. asegurado
          CUMULO(number)  --> Clave del cúmulo
          NCONTRA(number) --> Numeros de polizas a contratar. (casi siempre será 1)
   RETORNA VALUE:
          NUMBER------------> #-Nro. de contratos acumulados
******************************************************************************/
valor    NUMBER;
BEGIN
   valor := NULL;
   IF persona2 = 0 THEN
     BEGIN
       BEGIN
        SELECT COUNT(r.sseguro)
          INTO valor
          FROM RIESGOS R, SEGUROS S, SEGUROS_REN SR, PRODUCTOS P, CUM_CUMPROD C
         WHERE r.sseguro = s.sseguro
           AND sr.sseguro = s.sseguro
           AND sr.cmodali = 110
           AND s.csituac IN (8,0,7)
           AND p.cramo   = s.cramo
           AND p.cmodali  = s.cmodali
           AND p.ccolect  = s.ccolect
           AND p.ctipseg  = s.ctipseg
           AND p.sproduc = c.cproduc
           AND sperson = persona1
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
   ELSE
     BEGIN
      BEGIN
       SELECT COUNT(r.sseguro)
         INTO valor
         FROM ASEGURADOS R, SEGUROS S, SEGUROS_REN SR, PRODUCTOS P, CUM_CUMPROD C
        WHERE r.sseguro = s.sseguro
          AND sr.sseguro = s.sseguro
          AND sr.cmodali = 110
          AND s.csituac IN (8,7,0)
          AND r.ffecfin IS NULL
          AND p.cramo   = s.cramo
          AND p.cmodali  = s.cmodali
          AND p.ccolect  = s.ccolect
          AND p.ctipseg  = s.ctipseg
          AND p.sproduc = c.cproduc
          AND r.sperson = persona1
          AND r.sseguro IN (SELECT sseguro FROM ASEGURADOS WHERE sperson=persona2)
          AND ccumulo = cumulo;
      IF VALOR IS NULL THEN
         valor := ncontra;
      ELSE
         valor := valor + ncontra;
      END IF;
      RETURN VALOR;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN  RETURN ncontra;
        WHEN OTHERS THEN         RETURN -9;
      END;
     END;
   END IF;
END Fcusuctom110;
 
 

/

  GRANT EXECUTE ON "AXIS"."FCUSUCTOM110" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."FCUSUCTOM110" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."FCUSUCTOM110" TO "PROGRAMADORESCSI";
