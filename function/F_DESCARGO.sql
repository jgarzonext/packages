--------------------------------------------------------
--  DDL for Function F_DESCARGO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_DESCARGO" (
   pcempres   IN       NUMBER,
   pcdelega   IN       NUMBER,
   pccargo    IN       NUMBER,
   pfsituac   IN       DATE,
   pnom       IN OUT   VARCHAR2
)
   RETURN NUMBER AUTHID CURRENT_USER
IS
/***********************************************************************
    F_DESCARGO: Busca el nombre del cargo asociado a la empresa-delegación.
    ALLIBMFM
***********************************************************************/
BEGIN
   BEGIN
      SELECT f_nombre (sperson, 1, null)
        INTO pnom
        FROM cargosemp
       WHERE cempres = pcempres
         AND cdelega = pcdelega
         AND ccargo = pccargo
         AND (pfsituac BETWEEN finicar AND ffincar OR ffincar IS NULL);
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN 107738;
   END;
   RETURN 0;
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_DESCARGO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_DESCARGO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_DESCARGO" TO "PROGRAMADORESCSI";
