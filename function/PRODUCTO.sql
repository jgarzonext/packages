--------------------------------------------------------
--  DDL for Function PRODUCTO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."PRODUCTO" (psesion IN NUMBER, psproduc IN NUMBER) RETURN NUMBER
AUTHID CURRENT_user IS
   lprod NUMBER;
BEGIN
   SELECT cramo||LPAD(cmodali,2,'0')||LPAD(ctipseg,2,'0')||LPAD(ccolect,2,'0')
         INTO lprod
   FROM productos
   WHERE sproduc = psproduc;
   RETURN lprod;
EXCEPTION
   WHEN OTHERS THEN
      RETURN 0;
END;

 
 

/

  GRANT EXECUTE ON "AXIS"."PRODUCTO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PRODUCTO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PRODUCTO" TO "PROGRAMADORESCSI";
