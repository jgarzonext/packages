--------------------------------------------------------
--  DDL for Function FCUMSUMACAP_SNV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."FCUMSUMACAP_SNV" (
   nsesion IN NUMBER,
   persona1 IN NUMBER,
   persona2 IN NUMBER,
   cumulo IN NUMBER,
   ncontra IN NUMBER,
   psseguro IN NUMBER)
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
   valor_est      NUMBER;
   v_ssegpol      NUMBER;
BEGIN
   SELECT ssegpol
     INTO v_ssegpol
     FROM estseguros
    WHERE sseguro = psseguro;

   valor := NULL;

   IF persona2 = 0 THEN
      BEGIN
         BEGIN
            --DBMS_OUTPUT.put_line('primera select');
            SELECT SUM(g.icapital)
              INTO valor
              FROM seguros s, garanseg g, riesgos r, cum_cumgaran c
             WHERE s.sseguro = g.sseguro
               AND s.sseguro = r.sseguro
               AND s.csituac IN(4, 0, 5)
               AND s.creteni NOT IN(2, 3, 4)
               AND c.cramo = s.cramo
               AND c.cmodali = s.cmodali
               AND c.ctipseg = s.ctipseg
               AND c.ccolect = s.ccolect
               AND c.cactivi = pac_seguros.ff_get_actividad(s.sseguro, r.nriesgo)
               AND c.cgarant = g.cgarant
               AND g.ffinefe IS NULL
               AND r.sperson = pac_persona.f_sperson_spereal(persona1)   -- persona1
               AND c.ccumulo = cumulo
               AND s.sseguro <> v_ssegpol;

--dbms_output.put_line('valor ='||valor);
            SELECT SUM(g.icapital)
              INTO valor_est
              FROM estseguros s, estgaranseg g, estriesgos r, cum_cumgaran c
             WHERE s.sseguro = g.sseguro
               AND s.sseguro = r.sseguro
               AND s.csituac IN(4, 0, 5)
               AND s.creteni NOT IN(3, 4)
               AND c.cramo = s.cramo
               AND c.cmodali = s.cmodali
               AND c.ctipseg = s.ctipseg
               AND c.ccolect = s.ccolect
               AND c.cactivi = pac_seguros.ff_get_actividad(s.sseguro, r.nriesgo, 'EST')
               AND c.cgarant = g.cgarant
               AND g.ffinefe IS NULL
               AND r.sperson = persona1
               AND r.sseguro = psseguro
               AND c.ccumulo = cumulo;

--dbms_output.put_line('valor_est ='||valor_est);
            valor := NVL(valor, 0) + NVL(valor_est, 0) + ncontra;
            RETURN valor;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               RETURN ncontra;
            WHEN OTHERS THEN
               --DBMS_OUTPUT.put_line(SQLERRM);
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
               AND s.csituac IN(4, 0, 5)
               AND s.creteni NOT IN(2, 3, 4)
               AND c.cramo = s.cramo
               AND c.cmodali = s.cmodali
               AND c.ctipseg = s.ctipseg
               AND c.ccolect = s.ccolect
               AND c.cactivi = pac_seguros.ff_get_actividad(s.sseguro, g.nriesgo)
               AND c.cgarant = g.cgarant
               AND g.ffinefe IS NULL
               AND a.sperson = pac_persona.f_sperson_spereal(persona1)
               AND a.sseguro IN(SELECT sseguro
                                  FROM asegurados
                                 WHERE sperson = pac_persona.f_sperson_spereal(persona2))   -- persona2
               AND c.ccumulo = cumulo
               AND s.sseguro <> v_ssegpol;

            SELECT SUM(g.icapital)
              INTO valor_est
              FROM estseguros s, estgaranseg g, estassegurats a, cum_cumgaran c
             WHERE s.sseguro = g.sseguro
               AND a.ffecfin IS NULL
               AND s.sseguro = a.sseguro
               AND s.csituac IN(4, 0, 5)
               AND s.creteni NOT IN(3, 4)
               AND c.cramo = s.cramo
               AND c.cmodali = s.cmodali
               AND c.ctipseg = s.ctipseg
               AND c.ccolect = s.ccolect
               AND c.cactivi = pac_seguros.ff_get_actividad(s.sseguro, g.nriesgo, 'EST')
               AND c.cgarant = g.cgarant
               AND g.ffinefe IS NULL
               AND a.sperson = persona1
               AND s.sseguro = psseguro
               --AND  a.sseguro in (select sseguro from ESTasegurados where sperson=persona2)
               AND c.ccumulo = cumulo;

            valor := NVL(valor, 0) + NVL(valor_est, 0) + ncontra;
            RETURN valor;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               RETURN ncontra;
            WHEN OTHERS THEN
               RETURN -9;
         END;
      END;
   END IF;
END fcumsumacap_snv;
 
 

/

  GRANT EXECUTE ON "AXIS"."FCUMSUMACAP_SNV" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."FCUMSUMACAP_SNV" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."FCUMSUMACAP_SNV" TO "PROGRAMADORESCSI";
