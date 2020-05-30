--------------------------------------------------------
--  DDL for Package PAC_REF_CONTRATA_AHO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_REF_CONTRATA_AHO" AUTHID CURRENT_USER IS
/******************************************************************************
  Package público para contratación de pólizas de ahorro

******************************************************************************/
   FUNCTION f_valida_garantias_aho(
      psproduc IN NUMBER,
      psperson1 IN NUMBER,
      psperson2 IN NUMBER,
      pfefecto IN DATE,
      prima_inicial IN NUMBER,
      prima_per IN NUMBER,
      prevali IN NUMBER,
      pcforpag IN NUMBER,
      pcfallaseg1 IN NUMBER,
      pcfallaseg2 IN NUMBER,
      pcaccaseg1 IN NUMBER,
      pcaccaseg2 IN NUMBER,
      pcagente IN NUMBER,
      pcidioma_user IN NUMBER DEFAULT f_idiomauser,
      ocoderror OUT NUMBER,
      omsgerror OUT VARCHAR2)
      RETURN NUMBER;

/*
LA FUNCION f_valida_primas_aho QUEDA SUSTITUIDA POR LA FUNCIO f_valida_garantias_aho
 FUNCTION f_valida_primas_aho(psproduc IN NUMBER, psperson IN NUMBER, pfefecto IN DATE, prima_inicial IN NUMBER, prima_per IN NUMBER,
           prevali IN NUMBER,  pcforpag IN NUMBER, pcfallaseg1 IN NUMBER, pcfallaseg2 IN NUMBER, pcaccaseg1 IN NUMBER,
           pcaccaseg2 IN NUMBER, pcagente IN NUMBER, pcidioma_user IN NUMBER DEFAULT F_IdiomaUser, oCODERROR OUT NUMBER, oMSGERROR OUT VARCHAR2) RETURN NUMBER ;
*/
   FUNCTION f_suplemento_interes(
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      pndurper IN NUMBER,
      ppinttec IN NUMBER,
      poficina IN VARCHAR2,
      pterminal IN VARCHAR2,
      pcidioma_user IN NUMBER DEFAULT f_idiomauser,
      ocoderror OUT NUMBER,
      omsgerror OUT VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_suplemento_forpag_prestacion(
      psseguro IN NUMBER,
      pfefecto IN DATE,
      pcfprest IN NUMBER,
      poficina IN VARCHAR2,
      pterminal IN VARCHAR2,
      pcidioma_user IN NUMBER DEFAULT f_idiomauser,
      ocoderror OUT NUMBER,
      omsgerror OUT VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_suplemento_aportacion_revali(
      psseguro IN NUMBER,
      pfefecto IN DATE,
      pcforpag IN NUMBER,
      pprima IN NUMBER,
      prevali IN NUMBER,
      poficina IN VARCHAR2,
      pterminal IN VARCHAR2,
      pcidioma_user IN NUMBER DEFAULT f_idiomauser,
      ocoderror OUT NUMBER,
      omsgerror OUT VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_suplemento_modif_gar(
      psseguro IN NUMBER,
      pfefecto IN DATE,
      pcfallaseg1 IN NUMBER,
      pcfallaseg2 IN NUMBER,
      pcaccaseg1 IN NUMBER,
      pcaccaseg2 IN NUMBER,
      poficina IN VARCHAR2,
      pterminal IN VARCHAR2,
      pcidioma_user IN NUMBER DEFAULT f_idiomauser,
      ocoderror OUT NUMBER,
      omsgerror OUT VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_suplemento_fvencimiento(
      psseguro IN NUMBER,
      pfefecto IN DATE,
      pfvencim IN DATE,
      poficina IN VARCHAR2,
      pterminal IN VARCHAR2,
      pcidioma_user IN NUMBER DEFAULT f_idiomauser,
      ocoderror OUT NUMBER,
      omsgerror OUT VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_aportacion_extraordinaria(
      psseguro IN NUMBER,
      pfefecto IN DATE,
      pprima IN NUMBER,
      pcbancar_recibo IN VARCHAR2,
      poficina IN VARCHAR2,
      pterminal IN VARCHAR2,
      pcidioma_user IN NUMBER DEFAULT f_idiomauser,
      ocoderror OUT NUMBER,
      omsgerror OUT VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_revision_renovacion(
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      pndurper IN NUMBER,
      ppinttec IN NUMBER,
      pcidioma_user IN NUMBER DEFAULT f_idiomauser,
      ocoderror OUT NUMBER,
      omsgerror OUT VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_genera_poliza_aho(
      psproduc IN NUMBER,
      psperson1 IN NUMBER,
      pcdomici1 IN NUMBER,
      psperson2 IN NUMBER,
      pcdomici2 IN NUMBER,
      pcagente IN NUMBER,
      pcidioma IN NUMBER,
      pfefecto IN DATE,
      pnduraci IN NUMBER,
      pfvencim IN DATE,
      pcforpag IN NUMBER,
      pcbancar IN VARCHAR2,
      psclaben IN NUMBER,
      ptclaben IN VARCHAR2,
      prima_inicial IN NUMBER,
      prima_per IN NUMBER,
      prevali IN NUMBER,
      pcfallaseg1 IN NUMBER,
      pcfallaseg2 IN NUMBER,
      pcaccaseg1 IN NUMBER,
      pcaccaseg2 IN NUMBER,
      pcbancar_recibo IN VARCHAR2,
      pterminal IN NUMBER,
      pcidioma_user IN NUMBER DEFAULT f_idiomauser,
      psseguro IN OUT NUMBER,
      pnpoliza OUT NUMBER,
      pncertif OUT NUMBER,
      pnsolici OUT NUMBER,
      pcsituac OUT NUMBER,
      ocoderror OUT NUMBER,
      omsgerror OUT VARCHAR2)
      RETURN NUMBER;
END pac_ref_contrata_aho;

/

  GRANT EXECUTE ON "AXIS"."PAC_REF_CONTRATA_AHO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_REF_CONTRATA_AHO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_REF_CONTRATA_AHO" TO "PROGRAMADORESCSI";
