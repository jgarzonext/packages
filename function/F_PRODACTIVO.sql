--------------------------------------------------------
--  DDL for Function F_PRODACTIVO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_PRODACTIVO" (psproduc IN NUMBER)
  RETURN NUMBER IS
/*********************************************************************************
    F_prodactivo: Et retorna si el producte està actiu
     17/01/2005  MCA
 ********************************************************************************/

 vactivo   number;
BEGIN
 select cactivo
 into vactivo
 from productos
 where sproduc = psproduc;

 return vactivo;

EXCEPTION
    WHEN OTHERS THEN
       return null;
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_PRODACTIVO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_PRODACTIVO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_PRODACTIVO" TO "PROGRAMADORESCSI";
