--------------------------------------------------------
--  DDL for Package PAC_MD_AVISOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_MD_AVISOS" AS
/******************************************************************************
   NOMBRE:      pac_md_avisos
   PROPÃ“SITO:

   REVISIONES:
   Ver        Fecha        Autor             DescripciÃ³n
   ---------  ----------  ---------------  ------------------------------------
   1.0        09/06/2011   XPL               1. CreaciÃ³n del package.18712: LCOL000 - Analisis de bloque de avisos en siniestros

******************************************************************************/
/*
      Funció que retornarà tots els avisos a mostrar per pantalla
      pcform IN VARCHAR2                pantalla
      pcmodo IN VARCHAR2                mode
      pcramo IN NUMBER                  ram
      psproduc IN NUMBER                codi producte
      pparams IN t_iax_info             parametres que enviem desde la pantalla
      plstavisos OUT t_iax_aviso        missatges de sortida
      mensajes IN OUT t_iax_mensajes    Mensajes
      XPL#16072011#18712: LCOL000 - Analisis de bloque de avisos en siniestros
*/
   FUNCTION f_get_avisos(
      pcform IN VARCHAR2,
      pcmodo IN VARCHAR2,
      pcramo IN NUMBER,
      psproduc IN NUMBER,
      pparams IN t_iax_info,
      plstavisos OUT t_iax_aviso,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;
END pac_md_avisos;
 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_AVISOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_AVISOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_AVISOS" TO "PROGRAMADORESCSI";
