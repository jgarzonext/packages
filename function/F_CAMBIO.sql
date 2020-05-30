--------------------------------------------------------
--  DDL for Function F_CAMBIO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_CAMBIO" (
   pcmonedaent IN NUMBER,
   pcmonedasal IN NUMBER,
   pientrada IN NUMBER,
   pisalida OUT NUMBER)
   RETURN NUMBER AUTHID CURRENT_USER IS
/*****************************************************************
F_CAMBIO:
- Transformación d'un import d'entrada d'una moneda a un
altre en fiunció del codi de moneda d'entrada i del codi
de moneda de sortida.
*****************************************************************/
   codi_error     NUMBER := 0;
   wpisalida      NUMBER(13, 2);
BEGIN
   IF pcmonedaent IS NULL
      OR pcmonedasal IS NULL THEN
      codi_error := 102781;
      RETURN(codi_error);
   END IF;

   IF pcmonedaent = 2
      AND pcmonedasal = 1 THEN
      wpisalida := ROUND((pientrada / 166.386), 2);
   ELSE
      wpisalida := NULL;
   END IF;

   pisalida := wpisalida;
   RETURN(codi_error);
END;

/

  GRANT EXECUTE ON "AXIS"."F_CAMBIO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_CAMBIO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_CAMBIO" TO "PROGRAMADORESCSI";
