--------------------------------------------------------
--  DDL for Function F_PARPRODUCTOS_V
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_PARPRODUCTOS_V" (p_sproduc IN NUMBER, p_cparpro IN VARCHAR2)
   RETURN NUMBER IS
/*************************************************************************
   FUNCTION F_PARPRODUCTOS_V
   Retorna el valor numérico del parámetro P_CPARPRO para un producto.
     param in p_sproduc : código del producto
     param in p_cparpro : código del parámetro
     return             : el valor numérico del parámetro
*************************************************************************/
BEGIN
   -- BUG 8999 - 29/11/2010 - JMP - Se llama al PAC_PARAMETROS
   RETURN pac_parametros.f_parproducto_n(p_sproduc, p_cparpro);
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      RETURN NULL;
   WHEN OTHERS THEN
      RETURN NULL;
END f_parproductos_v;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_PARPRODUCTOS_V" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_PARPRODUCTOS_V" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_PARPRODUCTOS_V" TO "PROGRAMADORESCSI";
