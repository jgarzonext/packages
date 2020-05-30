--------------------------------------------------------
--  DDL for Function F_ULTIMA_CARTERA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_ULTIMA_CARTERA" (psseguro IN NUMBER, pfcarpro IN DATE)
               RETURN DATE authid current_user IS

/*******************************************************************
Busquem la data que indica quina és la última cartera per la pòlissa
********************************************************************/
l_fultcar DATE;
BEGIN

   BEGIN
      SELECT fcarult INTO l_fultcar
      FROM  seguros_assp
      WHERE sseguro = psseguro;
   EXCEPTION
      WHEN OTHERS THEN
          l_fultcar := null ;
   END;

   RETURN l_fultcar;
END;

 
 

/

  GRANT EXECUTE ON "AXIS"."F_ULTIMA_CARTERA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_ULTIMA_CARTERA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_ULTIMA_CARTERA" TO "PROGRAMADORESCSI";
