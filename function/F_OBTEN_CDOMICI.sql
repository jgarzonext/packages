--------------------------------------------------------
--  DDL for Function F_OBTEN_CDOMICI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_OBTEN_CDOMICI" (psperson NUMBER)
   RETURN NUMBER IS

/******************************************************************************
 Función que calcula el cdomici dado un sperson
******************************************************************************/
   codi_domici    NUMBER := 0;
BEGIN
   IF psperson IS NOT NULL THEN
      SELECT MAX (cdomici)
        INTO codi_domici
        FROM (SELECT cdomici
                FROM direcciones
               WHERE sperson = psperson
              UNION
              SELECT cdomici
                FROM hisdirecciones
               WHERE sperson = psperson);
     IF codi_domici IS NULL THEN
	   codi_domici := 0;
	 END IF;
   END IF;

   RETURN codi_domici + 1;
END;

 
 

/

  GRANT EXECUTE ON "AXIS"."F_OBTEN_CDOMICI" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_OBTEN_CDOMICI" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_OBTEN_CDOMICI" TO "PROGRAMADORESCSI";
