--------------------------------------------------------
--  DDL for Function FF_ES_CORREDURIA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."FF_ES_CORREDURIA" (pcempres IN NUMBER)
   RETURN NUMBER IS
/*********************************************************************************
    F_ES_CORREDURIA: devuelve 1 si la empresa es correduria o un 0 si es compañia
     11-04-2008 JRB.
 ********************************************************************************/
   pescorreduria  NUMBER;
   nerr           NUMBER;
BEGIN
   nerr := f_es_correduria(pcempres, pescorreduria);

   IF nerr <> 0 THEN
      -- RETURN pescorreduria;
      RETURN NULL;
   ELSE
      --RETURN NULL;
      RETURN pescorreduria;
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      RETURN NULL;
END ff_es_correduria;
 
 

/

  GRANT EXECUTE ON "AXIS"."FF_ES_CORREDURIA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."FF_ES_CORREDURIA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."FF_ES_CORREDURIA" TO "PROGRAMADORESCSI";
