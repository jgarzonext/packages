--------------------------------------------------------
--  DDL for Function CONTRACTADA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."CONTRACTADA" (psesion  IN NUMBER, pcgarant IN NUMBER,
                                        psseguro IN NUMBER,
										pnmovimi IN NUMBER DEFAULT NULL,
										pfecha   IN NUMBER DEFAULT NULL)
RETURN NUMBER AUTHID current_user IS
   lc NUMBER;
   lfecha NUMBER;
   -- Versión actualizada para MV - 2004-04-01
BEGIN

   IF PNMOVIMI is not null THEN
     SELECT COUNT(*) INTO lc
       FROM garanseg
      WHERE sseguro = psseguro
        AND nmovimi = pnmovimi
        AND cgarant = pcgarant;
   ELSE
     lfecha := NVL(pfecha, TO_NUMBER(TO_CHAR(SYSDATE,'yyyymmdd')));

     SELECT COUNT(*) INTO lc
       FROM garanseg
      WHERE sseguro = psseguro
        AND finiefe <= TO_DATE(lfecha,'yyyymmdd')
        AND (ffinefe > TO_DATE(lfecha,'yyyymmdd') OR ffinefe IS NULL)
        AND cgarant = pcgarant;
   END IF;

   IF lc = 0 THEN
      RETURN 0;
   ELSE
      RETURN 1;
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      RETURN 0;
END;

 
 

/

  GRANT EXECUTE ON "AXIS"."CONTRACTADA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."CONTRACTADA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."CONTRACTADA" TO "PROGRAMADORESCSI";
