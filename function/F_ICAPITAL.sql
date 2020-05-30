--------------------------------------------------------
--  DDL for Function F_ICAPITAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_ICAPITAL" (psseguro IN NUMBER, tot_capital IN OUT NUMBER)
   RETURN NUMBER AUTHID CURRENT_USER IS
/***********************************************************************
   F_ICAPITAL : Calcula el capital de un seguro, tanto en colectivos
         como en individuales
   ALLIBCTR - Gestión de datos referentes a los seguros

     Se diferencia el cálculo para productos de
          de vida y otros
***********************************************************************/
   pnriesgo       NUMBER;
   picapital      NUMBER;
   pnorden        NUMBER;
   tipo           NUMBER;

   CURSOR c_capital IS
      SELECT   nriesgo, MIN(norden)
          FROM garanseg
         WHERE sseguro = psseguro
           AND ffinefe IS NULL
      GROUP BY nriesgo;

   CURSOR c_capital2 IS
      SELECT   nriesgo, SUM(icapital) total
          FROM garanseg
         WHERE sseguro = psseguro
           AND ffinefe IS NULL
      GROUP BY nriesgo;
BEGIN
   BEGIN
      SELECT cagrpro
        INTO tipo
        FROM seguros
       WHERE seguros.sseguro = psseguro;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 105134;   -- Error en la función
   END;

   IF tipo = 1 THEN   -- si es vida
      tot_capital := 0;

      OPEN c_capital;

      LOOP
         FETCH c_capital
          INTO pnriesgo, pnorden;

         EXIT WHEN c_capital%NOTFOUND;

         SELECT icapital
           INTO picapital
           FROM garanseg
          WHERE sseguro = psseguro
            AND nriesgo = pnriesgo
            AND norden = pnorden
            AND ffinefe IS NULL;

         tot_capital := tot_capital + picapital;
      END LOOP;

      CLOSE c_capital;

      RETURN 0;
   ELSE   -- si son otros productos
      tot_capital := 0;

      FOR v2 IN c_capital2 LOOP
         tot_capital := tot_capital + v2.total;
      END LOOP;

      RETURN 0;
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      -- BUG 21546_108724 - 08/02/2012 - JLTS - Cierre de posibles cursores abiertos
      IF c_capital%ISOPEN THEN
         CLOSE c_capital;
      END IF;

      RETURN 105134;   -- Error en la función
END f_icapital;

/

  GRANT EXECUTE ON "AXIS"."F_ICAPITAL" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_ICAPITAL" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_ICAPITAL" TO "PROGRAMADORESCSI";
