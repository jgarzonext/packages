--------------------------------------------------------
--  DDL for Package PAC_REF_CONTRATA_RENTAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_REF_CONTRATA_RENTAS" AUTHID CURRENT_USER IS
/******************************************************************************
      NOMBRE:      Pac_Ref_Contrata_Rentas
      PROPÓSITO: Funciones para contración

      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.0       27/04/2010   JRH                1. 0014285: CEM Se añade interes y fppren
   ******************************************************************************/
/******************************************************************************
  Package público para contratación de pólizas de ahorro

******************************************************************************/
   FUNCTION f_valida_garantias_rentas(
      psproduc IN NUMBER,
      psperson1 IN NUMBER,
      psperson2 IN NUMBER,
      pfefecto IN DATE,
      prima_per IN NUMBER,
      pcforpag IN NUMBER,
      pfallaseg IN NUMBER,
      pcagente IN NUMBER,
      pcidioma_user IN NUMBER DEFAULT f_idiomauser,
      fecoperhi IN DATE,   --JRH IMP Que hago con estas dos
      ccrnhi IN VARCHAR2,
      tasinmuebhi IN NUMBER,
      pcttasinmuebhi IN NUMBER,
      capitaldisphi IN NUMBER,
      pctrevrt IN NUMBER,
      ocoderror OUT NUMBER,
      omsgerror OUT VARCHAR2)
      RETURN NUMBER;

/*
LA FUNCION f_valida_primas_rentas QUEDA SUSTITUIDA POR LA FUNCIO f_valida_garantias_rentas
 FUNCTION f_valida_primas_rentas(psproduc IN NUMBER, psperson IN NUMBER, pfefecto IN DATE, prima_inicial IN NUMBER, prima_per IN NUMBER,
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

--JRH IMP Este no existe
-- FUNCTION f_suplemento_forpag_prestacion(psseguro IN NUMBER,pfefecto IN DATE, pcfprest IN NUMBER, poficina IN VARCHAR2, pterminal IN VARCHAR2, pcidioma_user IN NUMBER DEFAULT F_IdiomaUser, oCODERROR OUT NUMBER, oMSGERROR OUT VARCHAR2)
--    RETURN NUMBER;

   -- FUNCTION f_suplemento_aportacion_revali(psseguro IN NUMBER,pfefecto IN DATE, pcforpag IN NUMBER, pprima IN NUMBER, prevali IN NUMBER, poficina IN VARCHAR2, pterminal IN VARCHAR2, pcidioma_user IN NUMBER DEFAULT F_IdiomaUser, oCODERROR OUT NUMBER, oMSGERROR OUT VARCHAR2)
--    RETURN NUMBER;

   /* FUNCTION f_suplemento_modif_gar(psseguro IN NUMBER,pfefecto IN DATE, pcfallaseg1 IN NUMBER, pcfallaseg2 IN NUMBER, pcaccaseg1 IN NUMBER, pcaccaseg2 IN NUMBER, poficina IN VARCHAR2, pterminal IN VARCHAR2, pcidioma_user IN NUMBER DEFAULT F_IdiomaUser, oCODERROR OUT NUMBER, oMSGERROR OUT VARCHAR2)
    RETURN NUMBER;*/

   --JRH IMP Este no existe FUNCTION f_aportacion_extraordinaria(psseguro IN NUMBER, pfefecto IN DATE, pprima IN NUMBER, pcbancar_recibo IN VARCHAR2, poficina IN VARCHAR2, pterminal IN VARCHAR2, pcidioma_user IN NUMBER DEFAULT F_IdiomaUser, oCODERROR OUT NUMBER, oMSGERROR OUT VARCHAR2)
--    RETURN NUMBER;
   FUNCTION f_revision_renovacion(
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      pndurper IN NUMBER,
      ppinttec IN NUMBER,
      pcapital IN NUMBER,
      pcidioma_user IN NUMBER DEFAULT f_idiomauser,
      ocoderror OUT NUMBER,
      omsgerror OUT VARCHAR2)
      RETURN NUMBER;

/*

JRH 10/2007
f_genera_poliza_rentas : Crea la póliza a partir de los datos entrados por el usuario.

Parámetros:

psproduc : Producto
psperson1 : Código Persona 1er titular
pcdomici1 : Código Dirección 1er titular
psperson2 : Código Persona 2o titular
pcdomici2: Código Dirección 2o titular
pcagente : Agente
pcidioma : Idioma 1er titular
pfefecto : Fecha efeto de la póliza
pnduraci : Duración de la póliza (si es renta temporal) o duración del periodo (caso de rentas que usen período de revisión)
pfvencim : Fecha de vencimiento si existiese. (Opcional)
pcforpag : Forma de pago de la prima.
pcbancar : Cuenta bancaria cobro de la prima
psclaben : Cláusulas del beneficiario
ptclaben : Cláusulas del beneficiario
prima_inicial : Prima primera aportación (No se usa de momento).
prima_per : Prima del periodo.
prevali : Revalorización (No se usa de momento).
pcfallaseg1 : Pct capital de fallecimiento titular 1.
pcfallaseg2 : Pct capital de fallecimiento titular 2 (No se usa de momento).
tasinmuebHI : Tasación inmueble (Hipoteca Inversa)
pcttasinmuebHI : % sobre Tasación inmueble (Hipoteca Inversa)
capitaldispHI : % Capital disponible inmueble (Hipoteca Inversa)
pctrevRT : Pct reversión (LRC y RVD)
pctRevaliRVD : Pct revalor. (RVD)
ppinttec : Interés (RVD)
pcbancar_recibo : Cuenta del recibo (ingreso de la renta)
forpagorenta : Forma de pago de la renta.
pterminal : terminal
pcidioma_user : Idioma usuario
psseguro : Código seguro obtenido.
pnpoliza : Número de póliza obtenido.
pncertif : Número de certificado obtenido.
pnsolici : Número de solicitud obtenido.
pcsituac : Situación de la póliza.
rentabruta : Renta bruta inicial.
rentamin : Renta mínima inicial.
capfall : Capital de fallecimiento inicial.
intgarant : Interés garantizado inicial.
oCODERROR : Código de error.
oMSGERROR : Mensaje código de error.)



*/
   FUNCTION f_genera_poliza_rentas(
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
      prima_per IN NUMBER,
      pfallaseg IN NUMBER,
      tasinmuebhi IN NUMBER,
      pcttasinmuebhi IN NUMBER,
      capitaldisphi IN NUMBER,
      pctrevrt IN NUMBER,
      fecoperhi IN DATE,
      ccrnhi IN VARCHAR2,
      pcbancar_recibo IN VARCHAR2,
      pforpagorenta IN NUMBER,
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

   PROCEDURE f_actualizar_segurosren(
      psproduc IN NUMBER,
      pfefecto IN DATE,
      pnduraci IN NUMBER,
      pfvencim IN DATE,
      pcforpag IN NUMBER,
      prima_per IN NUMBER,
      pfallaseg IN NUMBER,
      ptasinmuebhi IN NUMBER,
      ppcttasinmuebhi IN NUMBER,
      pcapitaldisphi IN NUMBER,
      pctrevrt IN NUMBER,
      forpagorenta IN NUMBER,
      psseguro IN NUMBER,
      ocoderror OUT NUMBER,
      tablas VARCHAR2 DEFAULT 'EST',
      -- Bug 14285 - 26/04/2010 - JRH - 0014285: CEM303 - Informar fecha de primer pago de renta en la contratación e interés
      ppfpren IN DATE DEFAULT NULL
                                  -- Fi Bug 14285 - 26/04/2010 - JRH
   );
END pac_ref_contrata_rentas;
 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_REF_CONTRATA_RENTAS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_REF_CONTRATA_RENTAS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_REF_CONTRATA_RENTAS" TO "PROGRAMADORESCSI";
