--------------------------------------------------------
--  DDL for Package PAC_REF_CONTRATA_COMU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_REF_CONTRATA_COMU" authid current_user IS

/******************************************************************************
  Package público para contratación de pólizas. Tiene funciones comunes.

******************************************************************************/
FUNCTION f_valida_poliza_permite_supl(pnpoliza IN NUMBER, pncertif IN NUMBER, pfefecto IN DATE, pcmotmov IN NUMBER, pcidioma_user IN NUMBER DEFAULT F_IdiomaUser,
                                      oCODERROR OUT NUMBER, oMSGERROR OUT VARCHAR2)
RETURN NUMBER;

FUNCTION f_valida_asegurados(psproduc IN NUMBER,  psperson1 IN NUMBER, pfnacimi1 IN DATE, pcsexo1 IN NUMBER, pcpais1 IN NUMBER,
    psperson2 IN NUMBER, pfnacimi2 IN DATE, pcsexo2 IN NUMBER, pcpais2 IN NUMBER, pfefecto IN DATE,
    pcdomici1 IN NUMBER, pcdomici2 IN NUMBER, pvaldomici IN NUMBER, pcidioma_user IN NUMBER DEFAULT F_IdiomaUser, oCODERROR OUT NUMBER, oMSGERROR OUT VARCHAR2)
RETURN NUMBER;

FUNCTION f_valida_gestion(psproduc IN NUMBER, pctipban in number, pfefecto IN DATE, pfnacimi IN DATE, pcidioma IN NUMBER,
   pcforpag IN NUMBER,  pnduraci IN NUMBER, pfvencim IN DATE, pcbancar IN VARCHAR2, pcidioma_user IN NUMBER DEFAULT F_IdiomaUser,
   oCODERROR OUT NUMBER, oMSGERROR OUT VARCHAR2)
   RETURN NUMBER;

FUNCTION f_suplemento_ccc(pnpoliza IN NUMBER, pctipban in number, pncertif IN NUMBER, pfefecto IN DATE, pcbancar IN VARCHAR2, poficina IN VARCHAR2, pterminal IN VARCHAR2, pcidioma_user IN NUMBER DEFAULT F_IdiomaUser, oCODERROR OUT NUMBER, oMSGERROR OUT VARCHAR2)
RETURN NUMBER;

FUNCTION f_suplemento_beneficiario(pnpoliza IN NUMBER, pncertif IN NUMBER, pfefecto IN DATE, psclaben IN NUMBER, ptclaben IN VARCHAR2, poficina IN VARCHAR2, pterminal IN VARCHAR2, pcidioma_user IN NUMBER DEFAULT F_IdiomaUser, oCODERROR OUT NUMBER, oMSGERROR OUT VARCHAR2)
RETURN NUMBER;

FUNCTION f_suplemento_oficina(pnpoliza IN NUMBER, pncertif IN NUMBER, pfefecto IN DATE, pcagente IN NUMBER, poficina IN VARCHAR2, pterminal IN VARCHAR2, pcidioma_user IN NUMBER DEFAULT F_IdiomaUser, oCODERROR OUT NUMBER, oMSGERROR OUT VARCHAR2)
RETURN NUMBER;

FUNCTION f_suplemento_domicilio(pnpoliza IN NUMBER, pncertif IN NUMBER, pfefecto IN DATE, pcdomici IN NUMBER, poficina IN VARCHAR2, pterminal IN VARCHAR2, pcidioma_user IN NUMBER DEFAULT F_IdiomaUser, oCODERROR OUT NUMBER, oMSGERROR OUT VARCHAR2)
RETURN NUMBER;

FUNCTION f_suplemento_idioma(pnpoliza IN NUMBER, pncertif IN NUMBER, pfefecto IN DATE, pcidioma IN NUMBER, poficina IN VARCHAR2, pterminal IN VARCHAR2, pcidioma_user IN NUMBER DEFAULT F_IdiomaUser, oCODERROR OUT NUMBER, oMSGERROR OUT VARCHAR2)
RETURN NUMBER;

FUNCTION f_suplemento_fall_asegurado(psseguro IN NUMBER,pfefecto IN DATE, psperson IN NUMBER, pffallec IN DATE, poficina IN VARCHAR2, pterminal IN VARCHAR2, pcidioma_user IN NUMBER DEFAULT F_IdiomaUser, pcommit IN NUMBER DEFAULT 1, oCODERROR OUT NUMBER, oMSGERROR OUT VARCHAR2)
RETURN NUMBER;

/**********************************************************************************************
 Anul·la una pòlissa a l'efecte des de TF
 Paràmetres entrada:
    psSeguro : Identificador de l'assegurança   (obligatori)
    pcIdioma : Idioma de l'usuari               (obligatori)
    pOficina : Oficina                          (obligatori)
    pTerminal: Terminal                         (obligatori)
    Pcidioma_user : Idioma de l'usuari
 Torna :
    0 si tot és correcte,
    altrament NULL i informa els camps OCodeError i OMsgError
**********************************************************************************************/
FUNCTION f_anula_poliza_al_efecto
            ( psseguro IN SEGUROS.SSEGURO%TYPE,
              pcidioma IN IDIOMAS.CIDIOMA%TYPE,
              poficina IN LOG_CORREO.COFICINA%TYPE,
              pterminal IN LOG_CORREO.CTERM%TYPE,
              pcidioma_user IN NUMBER DEFAULT F_IdiomaUser,
              oCODERROR OUT LITERALES.SLITERA%TYPE,
              oMSGERROR OUT LITERALES.TLITERA%TYPE)
    RETURN NUMBER;

FUNCTION f_suplemento_rescate_parcial(pnpoliza IN NUMBER, pncertif IN NUMBER, pfefecto IN DATE, pirescatep IN NUMBER, poficina IN VARCHAR2, pterminal IN VARCHAR2, pcidioma_user IN NUMBER DEFAULT F_IdiomaUser, pcommit IN NUMBER DEFAULT 1, oCODERROR OUT NUMBER, oMSGERROR OUT VARCHAR2)
    RETURN NUMBER ;
END Pac_Ref_Contrata_Comu;
 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_REF_CONTRATA_COMU" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_REF_CONTRATA_COMU" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_REF_CONTRATA_COMU" TO "PROGRAMADORESCSI";
