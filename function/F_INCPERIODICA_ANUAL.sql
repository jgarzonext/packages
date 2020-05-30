--------------------------------------------------------
--  DDL for Function F_INCPERIODICA_ANUAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_INCPERIODICA_ANUAL" (psseguro IN NUMBER, pdatafi IN DATE, pdataini IN DATE,
                             pincrement OUT NUMBER )
      RETURN NUMBER authid CURRENT_USEr IS
---------------------------------------------------------------------
-- Increment d'Aportació periòdica anual entre dues dates no suspesa
---------------------------------------------------------------------
   l_fsusapo DATE;
   l_per_fi  NUMBER;
   l_per_ini NUMBER;

BEGIN
   pincrement := 0;
   -- comprovar si està suspesa
   BEGIN
      SELECT fsusapo INTO l_fsusapo
      FROM seguros_aho
      WHERE sseguro = psseguro;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         l_fsusapo := NULL;
      WHEN OTHERS THEN
         RETURN 120445;
   END;
   IF l_fsusapo IS NULL THEN
      -- Calcular la  periodica, i comprovar que la data de propera cartera
      -- és dins de la campanya
      BEGIN
         SELECT iprianu INTO l_per_fi
         FROM garanseg
         WHERE sseguro = psseguro
           AND finiefe <= pdatafi
           AND (ffinefe > pdatafi OR ffinefe IS NULL)
           AND cgarant = 48;

      EXCEPTION
         WHEN NO_DATA_FOUND THEN
              l_per_fi := 0;
         WHEN OTHERS THEN
            RETURN 103500;
      END;
      -- Import a l'inici de campanya
      BEGIN
         SELECT iprianu INTO l_per_ini
         FROM garanseg
         WHERE sseguro = psseguro
           AND finiefe < pdataini
           AND (ffinefe >= pdataini OR ffinefe IS NULL)
           AND cgarant = 48;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            l_per_ini := 0;
         WHEN OTHERS THEN
            RETURN 103500;
      END;
      pincrement := l_per_fi - l_per_ini;
   END IF;
   RETURN 0;
END;

 
 

/

  GRANT EXECUTE ON "AXIS"."F_INCPERIODICA_ANUAL" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_INCPERIODICA_ANUAL" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_INCPERIODICA_ANUAL" TO "PROGRAMADORESCSI";
