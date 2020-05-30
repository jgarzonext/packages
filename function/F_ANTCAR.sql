--------------------------------------------------------
--  DDL for Function F_ANTCAR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_ANTCAR" (pcempres IN NUMBER, pfcarant OUT DATE)
RETURN NUMBER authid current_user IS
/***************************************************************
F_ANTCAR: Retorna la data de la última cartera per una
empresa determinada.
***************************************************************/
CODI_ERROR NUMBER := 0;
BEGIN
BEGIN
SELECT FCARANT INTO PFCARANT
FROM EMPRESAS
WHERE CEMPRES = PCEMPRES;
EXCEPTION
WHEN NO_DATA_FOUND THEN
CODI_ERROR := 100;
END;
RETURN(CODI_ERROR);
END;

 
 

/

  GRANT EXECUTE ON "AXIS"."F_ANTCAR" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_ANTCAR" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_ANTCAR" TO "PROGRAMADORESCSI";
