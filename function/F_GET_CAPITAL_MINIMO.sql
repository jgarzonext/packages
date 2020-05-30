--------------------------------------------------------
--  DDL for Function F_GET_CAPITAL_MINIMO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_GET_CAPITAL_MINIMO" (
   p_sseguro   NUMBER
)
   RETURN NUMBER
IS
   retval   NUMBER;
BEGIN
   SELECT g.icapmin
     INTO retval
     FROM garanpro g, seguros s
    WHERE g.sproduc = s.sproduc
      AND g.cgarant = 48
      AND g.cactivi = s.cactivi
	  AND s.sseguro = p_sseguro;

   RETURN NVL (retval, 0);
EXCEPTION
   WHEN OTHERS
   THEN
      RETURN 0;
END f_get_capital_minimo;

 
 

/

  GRANT EXECUTE ON "AXIS"."F_GET_CAPITAL_MINIMO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_GET_CAPITAL_MINIMO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_GET_CAPITAL_MINIMO" TO "PROGRAMADORESCSI";
