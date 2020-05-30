--------------------------------------------------------
--  DDL for Package PAC_CALC_PROV_RF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_CALC_PROV_RF" AUTHID CURRENT_USER IS
    /******************************************************************************
      NOMBRE:     PAC_CALC_PROV_RF
      PROPÓSITO:  Funciones calculo rentas y sus provisiones

      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.0        XX/XX/XXXX   XXX                1. Creación del package.
      1.1        30/01/2009   JRH                2. Bug-8782 Revisión cálculo capital garantizado en productos de Ahorro
      1.2        01/05/2009   JRH                7. Bug 0009172: CRE055 - Rentas regulares e irregulares con cálculos a partir de renta

   ******************************************************************************/

   /*************************************************************************
      f_calculo_renta: Calcula renta parcial a una fecha
      Param IN psesion: sesion
      Param IN psseguro: Seguro
      Param IN pfecha : fecha
      Param IN rentamax : Defecto o
      return : El valor si todo ha ido bien, si no nulo
   ****************************************************************************************/

   -- Bug 0009172 - JRH - 01/05/2009 - Nueva Función : Bug 0009172: CRE055 - Rentas regulares e irregulares con cálculos a partir de renta
   FUNCTION f_calculo_renta(
      psesion IN NUMBER,
      psseguro IN NUMBER,
      pfecha IN DATE,
      rentamax IN NUMBER DEFAULT 0)
      RETURN NUMBER;

/*************************************************************************
   f_cal_rent: Calcula renta total a una fecha
   Param IN psesion: sesion
   Param IN psseguro: Seguro
   Param IN pfecha : fecha
   Param IN rentamax : Defecto o
   return : El valor si todo ha ido bien, si no nulo
****************************************************************************************/

   -- Bug 0009172 - JRH - 01/05/2009 - Nueva Función : Bug 0009172: CRE055 - Rentas regulares e irregulares con cálculos a partir de renta
   FUNCTION f_cal_rent(
      psesion IN NUMBER,
      psseguro IN NUMBER,
      pfecha IN DATE,
      rentamax IN NUMBER DEFAULT 0)
      RETURN NUMBER;

/*************************************************************************
   f_cal_prov: Calcula provision y capiales
   Param IN psesion: sesion
   Param IN psseguro: Seguro
   Param IN pfecha : fecha
   Param IN pfonprov : Devuelve --> 0 prov x,1 prov y, 2 prov xy, 3 prov riesg, 4 prov total, 5 capital fall, 6 capital garant
   return : El valor si todo ha ido bien, si no nulo
****************************************************************************************/

   -- Bug 0009172 - JRH - 01/05/2009 - Nueva Función : Bug 0009172: CRE055 - Rentas regulares e irregulares con cálculos a partir de renta
   FUNCTION f_cal_prov(
      psesion IN NUMBER,
      psseguro IN NUMBER,
      pfecha IN DATE,
      pfonprov IN NUMBER DEFAULT 0   -- 0 = Capital Garantizado
                                     -- 1 = Provisión matemàtica
                                  )
      RETURN NUMBER;
END pac_calc_prov_rf;
 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_CALC_PROV_RF" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_CALC_PROV_RF" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_CALC_PROV_RF" TO "PROGRAMADORESCSI";
