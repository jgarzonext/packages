--------------------------------------------------------
--  DDL for Function F_PARPRODUCTOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_PARPRODUCTOS" (
   p_sproduc IN NUMBER,
   p_cparpro IN VARCHAR2,
   p_cvalpar OUT NUMBER)
   RETURN NUMBER IS
/*************************************************************************
FUNCTION F_PARPRODUCTOS
Obtiene el valor de un parámetro de PARPRODUCTOS de tipo numérico
  param in p_sproduc  : código del producto
  param in p_cparpro  : código del parámetro
  param out p_cvalpar : valor numérico del parámetro
  return              : 0 si todo es correcto
                       109913 en caso de error
*************************************************************************/
BEGIN
   -- BUG 8999 - 29/11/2010 - JMP - Se llama al PAC_PARAMETROS
   p_cvalpar := pac_parametros.f_parproducto_n(p_sproduc, p_cparpro);
   RETURN 0;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      p_cvalpar := NULL;
      RETURN 0;
   WHEN OTHERS THEN
      RETURN 109913;
END f_parproductos;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_PARPRODUCTOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_PARPRODUCTOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_PARPRODUCTOS" TO "PROGRAMADORESCSI";
