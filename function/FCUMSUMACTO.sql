--------------------------------------------------------
--  DDL for Function FCUMSUMACTO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."FCUMSUMACTO" (nsesion  IN NUMBER,
       	  		                  persona1 IN NUMBER,
                                          persona2 IN NUMBER,
                                          cumulo   IN NUMBER,
                                          ncontra  IN NUMBER)
  RETURN NUMBER authid current_user IS
/******************************************************************************
   NOMBRE:       FCUMSUMACTO
   DESCRIPCION:  Realiza la suma de todas las pólizas que ha contratado una
                 determinada persona o dos, de aquellos productos que tienen
                 asignado el mismo cúmulo.
   PARAMETROS:
   INPUT: NSESION(number) --> Nro. de sesión del evaluador de fórmulas
          PERSONA1(number) --> Clave del 1er. asegurado
          PERSONA2(number) --> Clave del 2on. asegurado
          CUMULO(number)  --> Clave del cúmulo
          NCONTRA(number) --> Numeros de polizas a contratar. (casi siempre será 1)
   RETORNA VALUE:
          NUMBER------------> #-Nro. de contratos acumulados
******************************************************************************/
valor    number;
BEGIN
   valor := NULL;
   IF persona2 = 0 THEN
     BEGIN
       BEGIN
        SELECT count(r.sseguro)
          INTO valor
          FROM RIESGOS R, SEGUROS S, PRODUCTOS P, CUM_CUMPROD C
         WHERE r.sseguro = s.sseguro
           AND s.csituac in (8,0,7)
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
       SELECT count(r.sseguro)
         INTO valor
         FROM ASEGURADOS R, SEGUROS S, PRODUCTOS P, CUM_CUMPROD C
        WHERE r.sseguro = s.sseguro
          AND s.csituac in (8,0,7)
          AND r.ffecfin is null
          AND p.cramo   = s.cramo
          AND p.cmodali  = s.cmodali
          AND p.ccolect  = s.ccolect
          AND p.ctipseg  = s.ctipseg
          AND p.sproduc = c.cproduc
          AND r.sperson = persona1
          AND r.sseguro in (select sseguro from asegurados where sperson=persona2)
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
END FCUMSUMACTO;
 
 

/

  GRANT EXECUTE ON "AXIS"."FCUMSUMACTO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."FCUMSUMACTO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."FCUMSUMACTO" TO "PROGRAMADORESCSI";
