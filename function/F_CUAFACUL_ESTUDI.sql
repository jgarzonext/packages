--------------------------------------------------------
--  DDL for Function F_CUAFACUL_ESTUDI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_CUAFACUL_ESTUDI" (psseguro IN NUMBER, psproces IN NUMBER, pmoneda  IN NUMBER)
   RETURN NUMBER AUTHID current_user IS
---------------------------------------------------------------------------------------
-- El sseguro HA DE SER UN ESTUDI
-- Calcula la capçalera del quadre de facultatiu d'un estudi, per tal
-- de que es pugui completar i quan vingui la pòlissa contractada ja
-- tingui un quadre assignat
-----------------------------------------------------------------------
   num_err NUMBER := 0;
   lscumulo NUMBER;
   lc NUMBER;
BEGIN
   num_err    := F_Buscactrrea(psseguro, 1, psproces,3, pmoneda);
   IF  num_err <> 0 AND num_Err <> 99 THEN
      ROLLBACK;
   ELSIF num_err = 99 THEN
      -- s'atura per facultatiu
      num_Err    := 0;
   ELSE
      num_err    := F_Cessio(psproces, 3, pmoneda);

      IF num_Err <>99  THEN
         -- Si va be esborrem pq com és un estudi, no volem cessions
         BEGIN
            DELETE FROM cesionesrea
            WHERE sseguro = psseguro
              AND nmovimi = 1
              AND sproces = psproces;
         EXCEPTION
            WHEN OTHERS THEN
               num_Err := 104708;
         END;
         -- Esborrem si ha fet cumul
         BEGIN
            DELETE
            FROM reariesgos
            WHERE sseguro = psseguro;
         EXCEPTION
            WHEN OTHERS THEN
               num_Err := 104708;
         END;
      ELSIF num_err = 99 THEN
         -- Si és 99, aleshores no ha fet cessions, però si
         -- que ha generat la capçalera del quadre de facultatiu
         -- que és el que voliem
         -- Cal esborrar els cumuls
         BEGIN
            SELECT scumulo INTO lscumulo
            FROM reariesgos
            WHERE sseguro = psseguro;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               lscumulo := NULL;
         END;
         IF lscumulo IS NOT NULL THEN
            SELECT COUNT(DISTINCT sseguro ) INTO lc
            FROM reariesgos
            WHERE scumulo = lscumulo;
            IF lc <= 2 THEN
               UPDATE cuafacul SET sseguro = psseguro, scumulo = NULL
               WHERE scumulo = lscumulo;
               UPDATE cesionesrea SET scumulo=NULL
               WHERE scumulo=lscumulo;
               DELETE FROM reariesgos
               WHERE scumulo = lscumulo;
               DELETE FROM descumulos
               WHERE scumulo = lscumulo;
               DELETE FROM cumulos
               WHERE scumulo = lscumulo;
            ELSE
               -- només esborrem el registre de l'estudi
               DELETE FROM reariesgos
               WHERE sseguro = psseguro;
            END IF;
         END IF;
         num_err := 0;
      END IF;
   END IF;
RETURN num_err;
END F_Cuafacul_Estudi;

 
 

/

  GRANT EXECUTE ON "AXIS"."F_CUAFACUL_ESTUDI" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_CUAFACUL_ESTUDI" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_CUAFACUL_ESTUDI" TO "PROGRAMADORESCSI";
