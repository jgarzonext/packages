--------------------------------------------------------
--  DDL for Function F_NPOLIZA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_NPOLIZA" (pnpoliza IN NUMBER, psseguro IN NUMBER)
   RETURN VARCHAR2 IS
/******************************************************************************
   NOMBRE:      F_NPOLIZA
   PROPÓSITO:   Retorna polissa_ini (nº polissa del client) de la taula CNVPOLIZAS (Conversió de polisses Client-->Axis)

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        07/05/2009   DCT             1. Es treu el to_number sobre xnpoliza
******************************************************************************/
   xnpoliza       VARCHAR2(15);
BEGIN
   SELECT polissa_ini
     INTO xnpoliza
     FROM cnvpolizas
    WHERE sseguro = psseguro;

   RETURN xnpoliza;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      RETURN pnpoliza;
   WHEN OTHERS THEN
      RETURN -1;
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_NPOLIZA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_NPOLIZA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_NPOLIZA" TO "PROGRAMADORESCSI";
