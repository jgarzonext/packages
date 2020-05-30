--------------------------------------------------------
--  DDL for Function F_DESIDIOMA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_DESIDIOMA" (pcidioma IN NUMBER, ptidioma OUT VARCHAR2)
RETURN NUMBER authid current_user IS
/***********************************************************************
	F_DESIDIOMA: Retorna la descripción del idioma.
	ALLIBMFM
CANVI EN EL CODI D'ERROR.
***********************************************************************/
codi_error NUMBER :=0;
BEGIN
BEGIN
SELECT TIDIOMA
INTO PTIDIOMA
FROM IDIOMAS
WHERE CIDIOMA = PCIDIOMA;
EXCEPTION
WHEN NO_DATA_FOUND THEN
codi_error := 100638;     -- idioma no existente
END;
return (codi_error);
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_DESIDIOMA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_DESIDIOMA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_DESIDIOMA" TO "PROGRAMADORESCSI";
