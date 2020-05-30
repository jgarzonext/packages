--------------------------------------------------------
--  DDL for Function F_PROXCAR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_PROXCAR" (pcempres IN NUMBER, pfcarpro OUT DATE)
RETURN NUMBER authid current_user IS
/***************************************************************
F_PROXCAR: Retorna la data de la pròxima cartera per una
empresa determinada.
***************************************************************/
CODI_ERROR NUMBER := 0;
BEGIN
BEGIN
SELECT FCARPRO INTO PFCARPRO
FROM EMPRESAS
WHERE CEMPRES = PCEMPRES;
EXCEPTION
WHEN NO_DATA_FOUND THEN
CODI_ERROR := 100;
END;
RETURN(CODI_ERROR);
END;

 
 

/

  GRANT EXECUTE ON "AXIS"."F_PROXCAR" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_PROXCAR" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_PROXCAR" TO "PROGRAMADORESCSI";
