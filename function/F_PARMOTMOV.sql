--------------------------------------------------------
--  DDL for Function F_PARMOTMOV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_PARMOTMOV" (
   pcmotmov IN NUMBER,
   pcparmot IN VARCHAR2,
   psproduc IN NUMBER DEFAULT 0)
   RETURN NUMBER AUTHID CURRENT_USER IS
   /*********************************************************************************
       FUNCTION F_PARMOTMOV
       Obtiene el valor numérico de un parámetro de PARMOTMOV. Si no lo encuetra para
       el producto informado, lo busca para el producto 0.
         param in pcmotmov : código del motivo de movimiento
         param in pcparmot : código del parámetro
         param in psproduc : código del producto
         return            : el valor numérico del parámetro
    ********************************************************************************/
   v_resultado    parmotmov.cvalpar%TYPE;
BEGIN
   -- BUG 8999 - 29/11/2010 - JMP - Se llama al PAC_PARAMETROS
   v_resultado := pac_parametros.f_parmotmov_n(pcmotmov, pcparmot, psproduc);

   IF v_resultado IS NULL THEN
      v_resultado := pac_parametros.f_parmotmov_n(pcmotmov, pcparmot, 0);
   END IF;

   RETURN v_resultado;
END f_parmotmov;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_PARMOTMOV" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_PARMOTMOV" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_PARMOTMOV" TO "PROGRAMADORESCSI";
