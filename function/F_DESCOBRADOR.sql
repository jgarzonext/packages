--------------------------------------------------------
--  DDL for Function F_DESCOBRADOR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_DESCOBRADOR" (
   p_ccobban IN NUMBER,
   p_tdescrip OUT VARCHAR2,
   p_tcobban OUT VARCHAR2)
   RETURN NUMBER IS
BEGIN
   SELECT descripcion, tcobban
     INTO p_tdescrip, p_tcobban
     FROM cobbancario
    WHERE ccobban = p_ccobban;

   RETURN 0;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      RETURN 120135;
   WHEN OTHERS THEN
      RETURN SQLCODE;
END f_descobrador;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_DESCOBRADOR" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_DESCOBRADOR" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_DESCOBRADOR" TO "PROGRAMADORESCSI";
