--------------------------------------------------------
--  DDL for Package PAC_AXIS_RENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_AXIS_RENT" IS
   /******************************************************************************
      NOMBRE:     PAC_AXIS_RENT
      PROPÓSITO:  Package que contiene las funciones propias de tarificaición de rentas.

      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.0        22/10/2009   JRH             1.0 Creación del package.
   ******************************************************************************/

   /*************************************************************************
      FUNCTION AXY_M
        Calcula el valor AXY_M
        param in psesion   : Sesión.
        param in psseguro   : Seguro.
        return             : Valor del símbolo
   *************************************************************************/
   FUNCTION axy_m(psesion IN NUMBER, psseguro IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
        FUNCTION AXY
          Calcula el valor AXY
          param in psesion   : Sesión.
          param in psseguro   : Seguro.
          return             : Valor del símbolo
     *************************************************************************/
   FUNCTION axy(psesion IN NUMBER, psseguro IN NUMBER)
      RETURN NUMBER;
END pac_axis_rent;
 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_AXIS_RENT" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_AXIS_RENT" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_AXIS_RENT" TO "PROGRAMADORESCSI";
