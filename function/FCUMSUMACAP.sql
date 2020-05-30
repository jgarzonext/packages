--------------------------------------------------------
--  DDL for Function FCUMSUMACAP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."FCUMSUMACAP" (
   nsesion IN NUMBER,
   persona1 IN NUMBER,
   persona2 IN NUMBER,
   cumulo IN NUMBER,
   ncontra IN NUMBER)
   RETURN NUMBER AUTHID CURRENT_USER IS
/******************************************************************************
   NOMBRE:       FCUMSUMACAP
   DESCRIPCION:  Realiza la suma de capitales de las pólizas que ha contratado,
                 o solicitado que ha sido aprovada de una determinada persona
                 o dos, de aquellos productos que tienen en común el mismo
                 cúmulo.
   PARAMETROS:
   INPUT: NSESION(number) --> Nro. de sesión del evaluador de fórmulas
          PERSONA1(number) --> Clave del 1er. asegurado
          PERSONA2(number) --> Clave del 2on. asegurado
          CUMULO(number)  --> Clave del cúmulo
          NCONTRA(number) --> Capital a contratar.
   RETORNA VALUE:
          VALOR(NUMBER)-----> #-Capital acumulado
******************************************************************************/
   valor          NUMBER;
BEGIN
   valor := NULL;

   IF persona2 = 0 THEN
      BEGIN
         BEGIN
            SELECT SUM(g.icapital)
              INTO valor
              FROM seguros s, garanseg g, riesgos r, cum_cumgaran c
             WHERE s.sseguro = g.sseguro
               AND s.sseguro = r.sseguro
               AND s.csituac IN(8, 0, 7)
               AND c.cramo = s.cramo
               AND c.cmodali = s.cmodali
               AND c.ctipseg = s.ctipseg
               AND c.ccolect = s.ccolect
               AND c.cactivi = pac_seguros.ff_get_actividad(s.sseguro, r.nriesgo)
               AND c.cgarant = g.cgarant
               AND g.ffinefe IS NULL
               AND r.sperson = persona1
               AND c.ccumulo = cumulo;

            IF valor IS NULL THEN
               valor := ncontra;
            ELSE
               valor := valor + ncontra;
            END IF;

            RETURN valor;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               RETURN ncontra;
            WHEN OTHERS THEN
               RETURN -8;
         END;
      END;
   ELSE
      BEGIN
         BEGIN
            SELECT SUM(g.icapital)
              INTO valor
              FROM seguros s, garanseg g, asegurados a, cum_cumgaran c
             WHERE s.sseguro = g.sseguro
               AND a.ffecfin IS NULL
               AND s.sseguro = a.sseguro
               AND s.csituac IN(8, 0, 7)
               AND c.cramo = s.cramo
               AND c.cmodali = s.cmodali
               AND c.ctipseg = s.ctipseg
               AND c.ccolect = s.ccolect
               AND c.cactivi = pac_seguros.ff_get_actividad(s.sseguro, g.nriesgo)
               AND c.cgarant = g.cgarant
               AND g.ffinefe IS NULL
               AND a.sperson = persona1
               AND a.sseguro IN(SELECT sseguro
                                  FROM asegurados
                                 WHERE sperson = persona2)
               AND c.ccumulo = cumulo;

            IF valor IS NULL THEN
               valor := ncontra;
            ELSE
               valor := valor + ncontra;
            END IF;

            RETURN valor;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               RETURN ncontra;
            WHEN OTHERS THEN
               RETURN -9;
         END;
      END;
   END IF;
END fcumsumacap;
 
 

/

  GRANT EXECUTE ON "AXIS"."FCUMSUMACAP" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."FCUMSUMACAP" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."FCUMSUMACAP" TO "PROGRAMADORESCSI";
