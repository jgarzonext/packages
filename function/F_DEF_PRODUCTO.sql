--------------------------------------------------------
--  DDL for Function F_DEF_PRODUCTO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_DEF_PRODUCTO" (PSPRODUC IN     NUMBER,
                                          PCRAMO   IN OUT NUMBER,
                                          PCMODALI IN OUT NUMBER,
                                          PCTIPSEG IN OUT NUMBER,
                                          PCCOLECT IN OUT NUMBER) RETURN NUMBER AUTHID CURRENT_USER IS
/*************************************************************
    DEF_PRODUCTO: Obtener CRAMO, CMODALI, CTIPSEG y CCOLECT
                  a partir de SPRODUC
**************************************************************/
BEGIN
    PCRAMO   := NULL;
    PCMODALI := NULL;
    PCTIPSEG := NULL;
    PCCOLECT := NULL;
--
    SELECT CRAMO, CMODALI, CTIPSEG, CCOLECT
    INTO   PCRAMO, PCMODALI, PCTIPSEG, PCCOLECT
    FROM   PRODUCTOS
    WHERE  SPRODUC = PSPRODUC;

    RETURN 0;
EXCEPTION
     WHEN NO_DATA_FOUND THEN
       RETURN 180387;
     WHEN TOO_MANY_ROWS THEN
       RETURN 140720;
     WHEN OTHERS THEN
       RETURN 102705;
END F_DEF_PRODUCTO;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_DEF_PRODUCTO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_DEF_PRODUCTO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_DEF_PRODUCTO" TO "PROGRAMADORESCSI";
