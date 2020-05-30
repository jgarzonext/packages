--------------------------------------------------------
--  DDL for Function F_PROD_VINC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_PROD_VINC" ( psproduc IN NUMBER)RETURN NUMBER IS
/******************************************************************************
Función que nos indica, es un producto es de ahorro,
 1.- indica que si,
 0.- indica que no
******************************************************************************/
XCVINPRE NUMBER;
BEGIN
 BEGIN
  SELECT NVL(CVINPRE,0)
	INTO XCVINPRE
	FROM PRODUCTOS
	WHERE SPRODUC = PSPRODUC;
  EXCEPTION
	WHEN NO_DATA_FOUND THEN
	  RETURN NULL;
	WHEN OTHERS THEN
	  RETURN NULL;
  END;
  IF XCVINPRE =1 THEN
	RETURN 1;	-- ÉS PROD. VINCULADO
  ELSE
	RETURN 0;	-- NO HO ÉS
  END IF;
END f_prod_vinc;

 
 

/

  GRANT EXECUTE ON "AXIS"."F_PROD_VINC" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_PROD_VINC" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_PROD_VINC" TO "PROGRAMADORESCSI";
