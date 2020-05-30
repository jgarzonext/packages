--------------------------------------------------------
--  DDL for Function F_OBTENER_CP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_OBTENER_CP" (PCPROVIN NUMBER, PCPOBLAC NUMBER) RETURN 
codpostal.cpostal%TYPE --3606 jdomingo 29/11/2007  canvi format codi postal
IS
/******************************************************************************
******************************************************************************/
V_CPOSTAL codpostal.cpostal%TYPE; --3606 jdomingo 29/11/2007  canvi format codi postal

BEGIN
   SELECT CPOSTAL
     INTO V_CPOSTAL
     FROM CODPOSTAL
    WHERE CPROVIN = PCPROVIN
      AND CPOBLAC = PCPOBLAC;
  RETURN (V_CPOSTAL);
EXCEPTION
  WHEN OTHERS THEN
    RETURN ''; --3606 jdomingo 29/11/2007  canvi format codi postal
END F_OBTENER_CP; 
 
 

/

  GRANT EXECUTE ON "AXIS"."F_OBTENER_CP" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_OBTENER_CP" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_OBTENER_CP" TO "PROGRAMADORESCSI";
