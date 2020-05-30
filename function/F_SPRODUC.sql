--------------------------------------------------------
--  DDL for Function F_SPRODUC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_SPRODUC" (
         pcramo   IN NUMBER,
         pcmodali IN NUMBER,
         pctipseg IN NUMBER,
         pccolect IN NUMBER,
         psproduc IN OUT NUMBER
) RETURN NUMBER
  authid current_user IS
/*************************************************************
   F_SPRODUC: Obtener SPRODUC a partir de cramo, cmodali, ctipseg y ccolect
**************************************************************/
BEGIN
     psproduc := NULL;
--
     SELECT sproduc
     INTO   psproduc
     FROM   productos
     WHERE  cramo   = pcramo
     AND    cmodali = pcmodali
     AND    ctipseg = pctipseg
     AND    ccolect = pccolect;
     RETURN 0;
EXCEPTION
     WHEN NO_DATA_FOUND THEN
       RETURN 100001;
     WHEN TOO_MANY_ROWS THEN
       RETURN 100002;
     WHEN OTHERS THEN
       RETURN 100003;
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_SPRODUC" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_SPRODUC" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_SPRODUC" TO "PROGRAMADORESCSI";
