--------------------------------------------------------
--  DDL for Function F_DESDIREC_CP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_DESDIREC_CP" 
(PCPOSTAL 
codpostal.cpostal%TYPE --3606 jdomingo 29/11/2007  canvi format codi postal
,PCPAIS IN OUT NUMBER,PCPROVIN OUT NUMBER,PCPOBLAC OUT NUMBER)
RETURN NUMBER IS
tmpVar NUMBER;
/******************************************************************************
 Dado un C.Postal retornamos el país,provincia y población si es única,
 si existe más de una población retornamos población  a NULL
******************************************************************************/
BEGIN
 BEGIN
  SELECT PR.CPAIS, PR.CPROVIN, PO.CPOBLAC
  INTO PCPAIS, PCPROVIN, PCPOBLAC
  FROM POBLACIONES PO, PROVINCIAS PR, CODPOSTAL CP
  WHERE PO.CPROVIN = PR.CPROVIN
  AND CP.CPOBLAC = PO.CPOBLAC
  AND CP.CPROVIN = PR.CPROVIN
  AND CP.CPOSTAL = PCPOSTAL;

 EXCEPTION
  WHEN TOO_MANY_ROWS THEN
    SELECT DISTINCT PR.CPAIS, PR.CPROVIN,0
    INTO PCPAIS, PCPROVIN,PCPOBLAC
    FROM PROVINCIAS PR, CODPOSTAL CP
    WHERE CP.CPROVIN = PR.CPROVIN
    AND CP.CPOSTAL = PCPOSTAL;

 END;
RETURN 0;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
     RETURN 102330;
  WHEN OTHERS THEN
     RETURN 140999;
END F_DESDIREC_CP; 
 
 

/

  GRANT EXECUTE ON "AXIS"."F_DESDIREC_CP" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_DESDIREC_CP" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_DESDIREC_CP" TO "PROGRAMADORESCSI";
