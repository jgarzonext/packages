--------------------------------------------------------
--  DDL for Package PAC_VAL_AHO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_VAL_AHO" 
    AUTHID CURRENT_USER
IS

FUNCTION f_valida_prima_aho(ptipo IN NUMBER, psproduc IN NUMBER, psperson IN NUMBER, ptipo_prima IN NUMBER, pprima IN NUMBER, pcforpag IN NUMBER, pfefecto IN DATE DEFAULT F_Sysdate)
RETURN NUMBER;

FUNCTION f_valida_garantia_adicional(psproduc IN NUMBER, psperson IN NUMBER, pcobliga IN NUMBER, ptipo_garant IN NUMBER, ppropietario_garant IN NUMBER, pfefecto IN DATE)
RETURN NUMBER;

FUNCTION f_solicitud_traspaso (pcinout IN NUMBER, psseguro IN NUMBER, ocoderror OUT NUMBER)
      RETURN NUMBER;

END Pac_Val_Aho;
 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_VAL_AHO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_VAL_AHO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_VAL_AHO" TO "PROGRAMADORESCSI";
