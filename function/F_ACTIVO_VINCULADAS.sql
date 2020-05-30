--------------------------------------------------------
--  DDL for Function F_ACTIVO_VINCULADAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_ACTIVO_VINCULADAS" 
   RETURN NUMBER
IS
---- Si el resultado es igual a 1. Esta activo el paquete
----, cualquier otro, no esta activo
   w_ret   NUMBER;
BEGIN
   SELECT COUNT (1)
     INTO w_ret
     FROM productos
    WHERE sproduc IN (4, 5, 6) AND ctermfin = 0;

   IF w_ret >= 1
   THEN
      w_ret := 1;
   END IF;

   RETURN w_ret;
EXCEPTION
   WHEN OTHERS
   THEN
      RETURN 0;
END f_activo_vinculadas;

 
 

/

  GRANT EXECUTE ON "AXIS"."F_ACTIVO_VINCULADAS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_ACTIVO_VINCULADAS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_ACTIVO_VINCULADAS" TO "PROGRAMADORESCSI";
