--------------------------------------------------------
--  DDL for Function F_SPRODUC_RET
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_SPRODUC_RET" (
         pcramo   IN NUMBER,
         pcmodali IN NUMBER,
         pctipseg IN NUMBER,
         pccolect IN NUMBER
) RETURN NUMBER
  authid current_user IS
/*************************************************************
        F_Sproduc_Ret: Obtener SPRODUC a partir de cramo, cmodali,
                   ctipseg y ccolect
    24/11/2008 RSC
**************************************************************/
     psproduc NUMBER;
BEGIN
--
     SELECT sproduc
     INTO   psproduc
     FROM   productos
     WHERE  cramo   = pcramo
     AND    cmodali = pcmodali
     AND    ctipseg = pctipseg
     AND    ccolect = pccolect;
     RETURN psproduc;
EXCEPTION
     WHEN NO_DATA_FOUND THEN
       RETURN null;
     WHEN TOO_MANY_ROWS THEN
       RETURN null;
     WHEN OTHERS THEN
       RETURN null;
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_SPRODUC_RET" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_SPRODUC_RET" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_SPRODUC_RET" TO "PROGRAMADORESCSI";
