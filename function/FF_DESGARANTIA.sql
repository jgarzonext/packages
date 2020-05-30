--------------------------------------------------------
--  DDL for Function FF_DESGARANTIA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."FF_DESGARANTIA" (pcgarant IN NUMBER, pcidioma IN NUMBER)
RETURN VARCHAR2 authid current_user IS
/***********************************************************************
    FF_DESGARANTIA: Retorna la descripción de la garantia como valor.
    ALLIBMFM
***********************************************************************/
    vttexto garangen.tgarant%TYPE;
BEGIN
    SELECT  tgarant
    INTO    vttexto
    FROM    GARANGEN
    WHERE cidioma = pcidioma
      AND cgarant = pcgarant;
    RETURN vttexto;
EXCEPTION
    WHEN others THEN
        RETURN NULL;
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."FF_DESGARANTIA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."FF_DESGARANTIA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."FF_DESGARANTIA" TO "PROGRAMADORESCSI";
