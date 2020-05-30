--------------------------------------------------------
--  DDL for Function FF_DESRAMO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."FF_DESRAMO" (pccodram IN NUMBER, pcidioma IN NUMBER)
   RETURN VARCHAR2 AUTHID CURRENT_USER IS
/***********************************************************************
   F_DESRAMO: Descripción del Ramo.
   ALLIBMFM
***********************************************************************/
-- Bug 10786 - 15/09/2009 - AMC Aunque no este relacionado con el bug se detecta que el retorno de la función era incorrecto y se modifica.
   vtdescri       ramos.tramo%TYPE;
BEGIN
   SELECT tramo
     INTO vtdescri
     FROM ramos
    WHERE cidioma = pcidioma
      AND cramo = pccodram;

   RETURN vtdescri;
EXCEPTION
   WHEN OTHERS THEN
      RETURN NULL;
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."FF_DESRAMO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."FF_DESRAMO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."FF_DESRAMO" TO "PROGRAMADORESCSI";
