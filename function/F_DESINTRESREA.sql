--------------------------------------------------------
--  DDL for Function F_DESINTRESREA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_DESINTRESREA" (pcintres IN NUMBER, tcintres OUT VARCHAR2)
RETURN NUMBER AUTHID current_user IS
/***************************************************************
F_COMISREA: Retorna la descripció del codi de interés dels
contractes de reassegurança vigents en el moment
present.
Llibrería : ALLIBREA
***************************************************************/
CODI_ERROR NUMBER := 0;
BEGIN
  SELECT tintres
  INTO   tcintres
  FROM   DESINTERESREA
  WHERE  cintres = pcintres ;
  RETURN(CODI_ERROR);
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    CODI_ERROR := 100;
    RETURN(CODI_ERROR);
END;

 
 

/

  GRANT EXECUTE ON "AXIS"."F_DESINTRESREA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_DESINTRESREA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_DESINTRESREA" TO "PROGRAMADORESCSI";
