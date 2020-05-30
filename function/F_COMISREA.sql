--------------------------------------------------------
--  DDL for Function F_COMISREA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_COMISREA" (pccomrea IN NUMBER, pcidioma IN NUMBER,
ccomrea OUT VARCHAR2)
RETURN NUMBER authid current_user IS
/***************************************************************
F_COMISREA: Retorna la descripció de la comissió dels
contractes de reassegurança vigents en el moment
present.
Llibrería : ALLIBREA
***************************************************************/
CODI_ERROR NUMBER := 0;
BEGIN
SELECT TDESCRI
INTO   CCOMREA
FROM   DESCOMISIONCONTRA
WHERE  CCOMREA = PCCOMREA AND CIDIOMA = PCIDIOMA;
RETURN(CODI_ERROR);
EXCEPTION
WHEN NO_DATA_FOUND THEN
CODI_ERROR := 100;
RETURN(CODI_ERROR);
END;

 
 

/

  GRANT EXECUTE ON "AXIS"."F_COMISREA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_COMISREA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_COMISREA" TO "PROGRAMADORESCSI";
