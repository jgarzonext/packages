--------------------------------------------------------
--  DDL for Package PAC_CALC_AHO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_CALC_AHO" AUTHID CURRENT_USER IS

/******************************************************************************
  Package público para calculos de pólizas de ahorro

******************************************************************************/

   FUNCTION f_get_capitales_aho(psproduc IN NUMBER, psseguro IN NUMBER, pcapgar OUT NUMBER,
      pcapfall OUT NUMBER, pcapgar_per OUT NUMBER)
   RETURN NUMBER;

   FUNCTION f_get_duracion_renova(pnpoliza IN NUMBER, pncertif IN NUMBER, psseguro IN NUMBER,
      pndurper OUT NUMBER)
   RETURN NUMBER;

   FUNCTION f_get_datos_poliza_renova(pnpoliza IN NUMBER, pncertif IN NUMBER, psseguro IN NUMBER,
      psperson1 OUT NUMBER, psperson2 OUT NUMBER, picapgar OUT NUMBER, pndurper OUT NUMBER, pcidioma OUT NUMBER)
   RETURN NUMBER;

   FUNCTION f_get_forpagprest_poliza(ptablas IN VARCHAR2 DEFAULT 'SEG', psseguro IN NUMBER, pcidioma_user IN NUMBER, ptfprest OUT VARCHAR2)
   RETURN NUMBER;

   FUNCTION Ff_get_aportacion_per(ptablas IN VARCHAR2 DEFAULT 'SEG', psseguro IN NUMBER, pfecha IN DATE DEFAULT F_Sysdate)
   RETURN NUMBER;

END Pac_Calc_Aho;
 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_CALC_AHO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_CALC_AHO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_CALC_AHO" TO "PROGRAMADORESCSI";
