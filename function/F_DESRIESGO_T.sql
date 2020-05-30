--------------------------------------------------------
--  DDL for Function F_DESRIESGO_T
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_DESRIESGO_T" (
   psseguro IN NUMBER,
   pnriesgo IN NUMBER,
   pfriesgo IN DATE,
   pcidioma IN NUMBER,
   pnmovimi IN NUMBER DEFAULT NULL   -- Bug 26923/148935 - 11/07/2013 - AMC
                                  )
   RETURN VARCHAR2 AUTHID CURRENT_USER IS
/***********************************************************************
   Retorna el nombre de un tomador dado un SSEGURO y NORDTOM
***********************************************************************/
   w_triesgo1     VARCHAR2(200);
   w_triesgo2     VARCHAR2(200);
   w_triesgo3     VARCHAR2(200);
   w_nerror       NUMBER;
BEGIN
   w_nerror := f_desriesgo(psseguro, pnriesgo, pfriesgo, pcidioma, w_triesgo1, w_triesgo2,
                           w_triesgo3, pnmovimi   -- Bug 26923/148935 - 11/07/2013 - AMC
                                               );

   IF w_nerror = 0 THEN
      RETURN(w_triesgo1 || ' ' || w_triesgo2 || ' ' || w_triesgo3);
   ELSE
      RETURN('Error : ' || TO_CHAR(w_nerror));
   END IF;
END f_desriesgo_t;

/

  GRANT EXECUTE ON "AXIS"."F_DESRIESGO_T" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_DESRIESGO_T" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_DESRIESGO_T" TO "PROGRAMADORESCSI";
