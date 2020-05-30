--------------------------------------------------------
--  DDL for Function F_PARGARANPRO_V
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_PARGARANPRO_V" (
   pcramo IN NUMBER,
   pcmodali IN NUMBER,
   pctipseg IN NUMBER,
   pccolect IN NUMBER,
   pcactivi IN NUMBER,
   pcgarant IN NUMBER,
   pcpargar IN VARCHAR2)
   RETURN NUMBER AUTHID CURRENT_USER IS
   /*************************************************************************
      FUNCTION F_PARGARANPRO_V
      Retorna el valor numérico del parámetro PCPARGAR para una garantía.
        param in pcramo    : código del ramo
        param in pcmodali  : código de la modalidad
        param in pctipseg  : código del tipo de seguro
        param in pccolect  : código de la colectividad
        param in pcactivi  : código de la actividad
        param in pcgarant  : código de la garantía
        param in pcpargar  : código del parámetro
        return             : el valor numérico del parámetro
   *************************************************************************/
   psproduc       productos.sproduc%TYPE;
BEGIN
   SELECT sproduc
     INTO psproduc
     FROM productos
    WHERE cramo = pcramo
      AND cmodali = pcmodali
      AND ctipseg = pctipseg
      AND ccolect = pccolect;

   -- BUG 8999 - 29/11/2010 - JMP - Se llama al PAC_PARAMETROS
   RETURN pac_parametros.f_pargaranpro_n(psproduc, pcactivi, pcgarant, pcpargar);
END f_pargaranpro_v;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_PARGARANPRO_V" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_PARGARANPRO_V" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_PARGARANPRO_V" TO "PROGRAMADORESCSI";
