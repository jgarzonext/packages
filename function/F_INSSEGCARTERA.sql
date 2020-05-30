--------------------------------------------------------
--  DDL for Function F_INSSEGCARTERA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_INSSEGCARTERA" (
   psproces IN NUMBER,
   psseguro IN NUMBER,
   pfcarpro IN DATE,
   pfcaranu IN DATE,
   pfcarant IN DATE,
   pnanuali IN NUMBER,
   pnfracci IN NUMBER)
   RETURN NUMBER AUTHID CURRENT_USER IS
/****************************************************************************
   F_INSSEGCARTERA: Inserta un registro en la tabla SEGCARTERA.
****************************************************************************/
BEGIN
   INSERT INTO segcartera
               (sproces, sseguro, fcarpro, fcaranu, fcarant, nanuali, nfracci)
        VALUES (psproces, psseguro, pfcarpro, pfcaranu, pfcarant, pnanuali, pnfracci);

   RETURN 0;
EXCEPTION
   WHEN OTHERS THEN
      RETURN 105167;
END;

/

  GRANT EXECUTE ON "AXIS"."F_INSSEGCARTERA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_INSSEGCARTERA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_INSSEGCARTERA" TO "PROGRAMADORESCSI";
