--------------------------------------------------------
--  DDL for Function F_NOMRECIBO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_NOMRECIBO" (
   psseguro   IN       NUMBER,
   ptnombre   IN OUT   VARCHAR2,
   pcidioma   IN OUT   NUMBER,
   psperson   IN OUT   NUMBER,
   pcdomici   IN OUT   NUMBER
)
   RETURN NUMBER AUTHID CURRENT_USER
IS
/***********************************************************************
    F_NOMRECIBO        Datos de la persona a quien se dirige el recibo
***********************************************************************/
   wnordtom   NUMBER;
BEGIN
   SELECT MIN(nordtom)
     INTO wnordtom
     FROM TOMADORES
    WHERE sseguro = psseguro;

   IF f_tomador2 (psseguro, wnordtom, ptnombre, pcidioma, psperson, pcdomici) <> 0
   THEN
      RETURN 1;
   END IF;

   RETURN 0;
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_NOMRECIBO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_NOMRECIBO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_NOMRECIBO" TO "PROGRAMADORESCSI";
