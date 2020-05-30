--------------------------------------------------------
--  DDL for Function FF_DESCOMPANIA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."FF_DESCOMPANIA" (p_ccompani IN NUMBER)
   RETURN VARCHAR2 AUTHID CURRENT_USER IS
   /***********************************************************************
   ff_descompania: Descripción de la compania.
   ***********************************************************************/
   v_des          companias.tcompani%TYPE;
BEGIN
   SELECT tcompani
     INTO v_des
     FROM companias
    WHERE ccompani = p_ccompani;

   RETURN v_des;
EXCEPTION
   WHEN OTHERS THEN
      RETURN NULL;
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."FF_DESCOMPANIA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."FF_DESCOMPANIA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."FF_DESCOMPANIA" TO "PROGRAMADORESCSI";
