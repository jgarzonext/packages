--------------------------------------------------------
--  DDL for Function F_PROD_AHORRO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_PROD_AHORRO" (psproduc IN NUMBER)RETURN NUMBER IS
/******************************************************************************
Función que nos indica, es un producto es de ahorro,
 1.- indica que si,
 0.- indica que no
******************************************************************************/
XCAGRPRO NUMBER;
BEGIN
 BEGIN
  SELECT CAGRPRO
	INTO XCAGRPRO
	FROM PRODUCTOS
	WHERE SPRODUC = PSPRODUC;
  EXCEPTION
	WHEN NO_DATA_FOUND THEN
	  RETURN NULL;
	WHEN OTHERS THEN
	  RETURN NULL;
  END;
  IF XCAGRPRO = 2 OR XCAGRPRO = 21 OR XCAGRPRO = 11 OR XCAGRPRO = 10 THEN
	RETURN 1;	-- ES D' ESTALVI
  ELSE
	RETURN 0;	-- NO HO ÉS
  END IF;

END F_PROD_AHORRO;

 
 

/

  GRANT EXECUTE ON "AXIS"."F_PROD_AHORRO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_PROD_AHORRO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_PROD_AHORRO" TO "PROGRAMADORESCSI";
