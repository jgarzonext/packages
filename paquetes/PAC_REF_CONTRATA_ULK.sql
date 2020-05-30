--------------------------------------------------------
--  DDL for Package PAC_REF_CONTRATA_ULK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_REF_CONTRATA_ULK" AUTHID CURRENT_USER IS

   -- Definicion del tipo que define un perfil o cartera de inversión
   TYPE cartera IS TABLE OF VARCHAR2(255) INDEX BY BINARY_INTEGER;

    /******************************************************************************
        Package público para contratación de pólizas de vida indexados
    ******************************************************************************/
   FUNCTION f_valida_primas_ulk(psproduc IN NUMBER, psperson IN NUMBER, pfefecto IN DATE, prima_inicial IN NUMBER, prima_per IN NUMBER,
           prevali IN NUMBER,  pcforpag IN NUMBER, pcagente IN NUMBER, pcidioma_user IN NUMBER DEFAULT F_IdiomaUser, oCODERROR OUT NUMBER, oMSGERROR OUT VARCHAR2)
   RETURN NUMBER;

   FUNCTION f_valida_garantias_ulk(psproduc IN NUMBER, psperson1 IN NUMBER, psperson2 IN NUMBER, pfefecto IN DATE, prima_inicial IN NUMBER, prima_per IN NUMBER,
           prevali IN NUMBER,  pcforpag IN NUMBER, pcagente IN NUMBER, pcidioma_user IN NUMBER DEFAULT F_IdiomaUser, oCODERROR OUT NUMBER, oMSGERROR OUT VARCHAR2)
   RETURN NUMBER;

   FUNCTION f_genera_poliza_ulk(psproduc IN NUMBER, psperson1 IN NUMBER,  pcdomici1 IN NUMBER,
            psperson2 IN NUMBER, pcdomici2 IN NUMBER, pcagente IN NUMBER, pcidioma IN NUMBER, pfefecto IN DATE,
            pnduraci IN NUMBER,    pfvencim IN DATE, pcforpag IN NUMBER, pcbancar IN VARCHAR2, ppcmodinv IN NUMBER,
            ppmodinv IN Pac_Ref_CONTRATA_ULK.cartera, psclaben IN NUMBER, ptclaben IN VARCHAR2, prima_inicial IN NUMBER, prima_per IN NUMBER,
            prevali IN NUMBER, pcbancar_recibo IN VARCHAR2, pterminal IN NUMBER, pcidioma_user IN NUMBER DEFAULT F_IdiomaUser,
            psseguro IN OUT NUMBER,    pnpoliza OUT NUMBER, pncertif OUT NUMBER, pnsolici OUT NUMBER, pcsituac OUT NUMBER,
            oCODERROR OUT NUMBER, oMSGERROR OUT VARCHAR2)
    RETURN NUMBER;

    FUNCTION f_aportacion_extraordinaria(psseguro IN NUMBER, pfefecto IN DATE, pprima IN NUMBER, pcbancar_recibo IN VARCHAR2, poficina IN VARCHAR2, pterminal IN VARCHAR2, pcidioma_user IN NUMBER DEFAULT F_IdiomaUser, oCODERROR OUT NUMBER, oMSGERROR OUT VARCHAR2)
    RETURN NUMBER;

    FUNCTION f_suplemento_aportacion_revali(psseguro IN NUMBER,pfefecto IN DATE, pcforpag IN NUMBER, pprima IN NUMBER, prevali IN NUMBER, poficina IN VARCHAR2, pterminal IN VARCHAR2, pcidioma_user IN NUMBER DEFAULT F_IdiomaUser, oCODERROR OUT NUMBER, oMSGERROR OUT VARCHAR2)
    RETURN NUMBER;

    FUNCTION f_suplemento_gastos(pnpoliza IN NUMBER, pncertif IN NUMBER, pfefecto IN DATE, pcgasges IN NUMBER, pcgasred IN NUMBER, poficina IN VARCHAR2, pterminal IN VARCHAR2, pcidioma_user IN NUMBER DEFAULT F_IdiomaUser, oCODERROR OUT NUMBER, oMSGERROR OUT VARCHAR2)
    RETURN NUMBER;

    FUNCTION f_suplemento_minversion(pnpoliza IN NUMBER, pncertif IN NUMBER, pfefecto IN DATE, pcmodinv IN NUMBER, pmodinv IN Pac_Ref_CONTRATA_ULK.cartera, poficina IN VARCHAR2, pterminal IN VARCHAR2, pcidioma_user IN NUMBER DEFAULT F_IdiomaUser, oCODERROR OUT NUMBER, oMSGERROR OUT VARCHAR2)
    RETURN NUMBER;
END Pac_Ref_Contrata_Ulk;
 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_REF_CONTRATA_ULK" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_REF_CONTRATA_ULK" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_REF_CONTRATA_ULK" TO "PROGRAMADORESCSI";
