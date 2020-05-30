--------------------------------------------------------
--  DDL for Package PAC_MD_VALIDACIONES_AUT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_MD_VALIDACIONES_AUT" AS
/******************************************************************************
   NOMBRE:       PAC_MD_VALIDACIONES_AUTS
   PROPÓSITO:  Funciones para validar autos

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        24/02/2009   XVM               1. Creación del package.
   2.0        07/01/2013   MDS               2. 0025458: LCOL_T031-LCOL - AUT - (ID 279) Tipos de placa (matr?cula)
   3.0        14/02/2013   JDS               3. 0025964: LCOL - AUT - Experiencia
   BUG 9247-24022009-XVM
******************************************************************************/
   gidioma        NUMBER := pac_md_common.f_get_cxtidioma();   --Código idioma

   /*************************************************************************
   FUNCTION F_valida_RieAuto
      Funció que valida una série d'aspectes d'un risc.
      param in pauto        : objecte d'autos
      param in out mensajes : missatges d'error
      return                : 1 -> Tot correcte
                              0 -> S'ha produit un error
   *************************************************************************/
   FUNCTION f_valida_rieauto(pauto IN ob_iax_autriesgos, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   FUNCTION f_validaconductores
      Funció que valida un conductor.
      param in pauto        : objecte d'autos
      param in out mensajes : missatges d'error
      return                : 1 -> Tot correcte
                              0 -> S'ha produit un error
   *************************************************************************/
   FUNCTION f_validaconductores(pautos IN ob_iax_autriesgos, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   FUNCTION f_validaConductorInnominado
      Funció que valida els camps perque sigui un conductor innominat correcte
      param in pnriesgo : número risc
      param in pnorden  : número ordre
      param in pnedad   : edat
      param in pfcarnet : data carnet
      param in pcsexo   : sexe
      param in pnpuntos : número de punts
      param in pexper_manual : Numero de años de experiencia del conductor.
      param in pexper_cexper : Numero de años de experiencia que viene por interfaz.
      param in out mensajes : missatges d'error
      return                : 1 -> Tot correcte
                              0 -> S'ha produit un error
   *************************************************************************/
   FUNCTION f_validaconductorinnominado(
      pnriesgo IN NUMBER,
      pnorden IN NUMBER,
      pfnacimi IN DATE,
      pfcarnet IN DATE,
      pcsexo IN NUMBER,
      pnpuntos IN NUMBER,
      pexper_manual IN NUMBER,
      pexper_cexper IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   FUNCTION f_validaConductorNominado
      Funció que valida els camps perque sigui un conductor nominat correcte
      param in pnriesgo : número risc
      param in pnorden  : número ordre
      param in pnedad   : edat
      param in pfcarnet : data carnet
      param in pcsexo   : sexe
      param in pnpuntos : número de punts
      param in pexper_manual : Numero de años de experiencia del conductor.
      param in pexper_cexper : Numero de años de experiencia que viene por interfaz.
      param in pcond        : objecte d'conductor
      return                : 1 -> Tot correcte
                              0 -> S'ha produit un error
   *************************************************************************/
   FUNCTION f_validaconductornominado(
      pnriesgo IN NUMBER,
      pnorden IN NUMBER,
      pctipper IN NUMBER,
      pfnacimi IN DATE,
      pfcarnet IN DATE,
      pcsexo IN NUMBER,
      pnpuntos IN NUMBER,
      pexper_manual IN NUMBER,
      pexper_cexper IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;
END pac_md_validaciones_aut;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_VALIDACIONES_AUT" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_VALIDACIONES_AUT" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_VALIDACIONES_AUT" TO "PROGRAMADORESCSI";
