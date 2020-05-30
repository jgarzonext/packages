--------------------------------------------------------
--  DDL for Function F_PAREMPRESA_T
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_PAREMPRESA_T" (
   pcparame IN VARCHAR2,
   pcempres IN NUMBER DEFAULT f_empres)
   RETURN VARCHAR2 AUTHID CURRENT_USER IS
   /*************************************************************************
      FUNCTION F_PAREMPRESA_T
      Obtiene el valor de un parámetro de PAREMPRESAS de tipo Texto
        param in pcparame : código del parámetro
        param in pcempres : código de la empresa
        return            : el valor del parámetro
   *************************************************************************/
   vtvalpar       VARCHAR2(100);
BEGIN
   -- BUG 8999 - 29/11/2010 - JMP - Se llama al PAC_PARAMETROS
   RETURN pac_parametros.f_parempresa_t(pcempres, UPPER(pcparame));
EXCEPTION
   WHEN OTHERS THEN
      vtvalpar := NULL;
      RETURN vtvalpar;
END f_parempresa_t;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_PAREMPRESA_T" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_PAREMPRESA_T" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_PAREMPRESA_T" TO "PROGRAMADORESCSI";
