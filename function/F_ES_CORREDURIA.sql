--------------------------------------------------------
--  DDL for Function F_ES_CORREDURIA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_ES_CORREDURIA" (pcempres IN NUMBER, pescorreduria OUT NUMBER) RETURN NUMBER IS
/*************************************************************
Retorna 0 No és corredoria
        1 Si és corredoria
**************************************************************/
BEGIN
   SELECT nvl(ctipemp,0) INTO pescorreduria
   FROM empresas
   WHERE cempres = pcempres;

   RETURN 0;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      pescorreduria := null;
      RETURN 105541;

   WHEN OTHERS THEN
      pescorreduria := null;
      RETURN 103290;
END;

 
 

/

  GRANT EXECUTE ON "AXIS"."F_ES_CORREDURIA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_ES_CORREDURIA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_ES_CORREDURIA" TO "PROGRAMADORESCSI";
