--------------------------------------------------------
--  DDL for Function F_CAMPANYA_ASSP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_CAMPANYA_ASSP" (psesion IN NUMBER,
                          pcpromoc IN NUMBER, psperemple IN NUMBER, psperaseg IN NUMBER,
                          psseguro IN NUMBER, pnmovimi IN NUMBER , pcgarant IN NUMBER) RETURN NUMBER
                          authid current_user IS
   lexistent NUMBER;
   lpunts    NUMBER := 0;
   licapital NUMBER;
BEGIN
   -- Aquesta campanya només és per el moviment de nova producció
   IF pnmovimi <> 1 THEN
      -- Tornem 0 punts.
      RETURN 0;
   END IF;
   --Obte asseg
   -- Mirar si ja ha entrat en campanya sseguro diferent del mateix assegurat
   BEGIN
      SELECT COUNT(*) INTO lexistent
      FROM detctaempleados
      WHERE cpromoc = pcpromoc
        AND spertit = psperaseg
        AND NVL(cinvalid,0)=0;

      -- Si no ha entrat en aquesta campanya mirem si per aquesta pòlissa es compleix.
      IF lexistent = 0 THEN
         BEGIN
            SELECT icapital INTO licapital
            FROM garanseg
            WHERE sseguro = psseguro
              AND nmovimi = pnmovimi
              AND cgarant = pcgarant ;
            IF licapital >= 30000 THEN
               lpunts := 1;
            ELSE
               lpunts := 0;
            END IF;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               lpunts := 0;
            WHEN OTHERS THEN
               lpunts := NULL;
         END;
      ELSE
         lpunts := 0;
         DBMS_OUTPUT.put_line(' Ja existeix assegurat '||psperaseg);
      END IF;
      RETURN lpunts;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END;
   -- Comprovar acumpleix imports
END ;

 
 

/

  GRANT EXECUTE ON "AXIS"."F_CAMPANYA_ASSP" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_CAMPANYA_ASSP" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_CAMPANYA_ASSP" TO "PROGRAMADORESCSI";
