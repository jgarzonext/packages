--------------------------------------------------------
--  DDL for Package PAC_REF_SIMULA_COMU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_REF_SIMULA_COMU" AUTHID CURRENT_USER IS

/******************************************************************************
  Package público para contratación de pólizas. Tiene funciones comunes.

******************************************************************************/

    FUNCTION f_valida_asegurados(psproduc IN NUMBER,  psperson1 IN NUMBER, pfnacimi1 IN DATE, pcsexo1 IN NUMBER, pcpais1 IN NUMBER,
                                 psperson2 IN NUMBER, pfnacimi2 IN DATE, pcsexo2 IN NUMBER, pcpais2 IN NUMBER,
                                 pfefecto IN DATE, pcdomici1 IN NUMBER, pcdomici2 IN NUMBER, pvaldomici IN NUMBER, pcidioma_user IN NUMBER DEFAULT F_IdiomaUser,
                                 oCODERROR OUT NUMBER, oMSGERROR OUT VARCHAR2)
    RETURN NUMBER;

    FUNCTION f_valida_duracion(psproduc IN NUMBER, pfnacimi IN DATE, pfefecto IN DATE, pnduraci IN NUMBER, pfvencim IN DATE, pcidioma_user IN NUMBER DEFAULT F_IdiomaUser,
                               oCODERROR OUT NUMBER, oMSGERROR OUT VARCHAR2)
    RETURN NUMBER;

END Pac_Ref_Simula_Comu;
 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_REF_SIMULA_COMU" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_REF_SIMULA_COMU" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_REF_SIMULA_COMU" TO "PROGRAMADORESCSI";
