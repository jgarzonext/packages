--------------------------------------------------------
--  DDL for Function F_DESPAIS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_DESPAIS" (PCPAIS NUMBER,
                                      PTPAIS OUT VARCHAR2,
                                      PCIDIOMA IN NUMBER DEFAULT F_USU_IDIOMA
                                      ) RETURN NUMBER IS
/***********************************************************************
	F_DESPAIS Retorna la descripción del pais.
    7-5-08 AMC
***********************************************************************/
BEGIN

  SELECT TPAIS
  INTO PTPAIS
  FROM DESPAISES
  WHERE CPAIS = PCPAIS
  AND CIDIOMA = PCIDIOMA;

  RETURN 0;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
      RETURN 151009;
END F_DESPAIS;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_DESPAIS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_DESPAIS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_DESPAIS" TO "PROGRAMADORESCSI";
