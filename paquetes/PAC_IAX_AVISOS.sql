--------------------------------------------------------
--  DDL for Package PAC_IAX_AVISOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_IAX_AVISOS" AS
/******************************************************************************
   NOMBRE:      pac_iax_avisos
   PROP¿¿SITO:

   REVISIONES:
   Ver        Fecha        Autor             Descripci¿¿n
   ---------  ----------  ---------------  ------------------------------------
   1.0        09/06/2011   XPL               1. Creaci¿¿n del package.18712: LCOL000 - Analisis de bloque de avisos en siniestros

******************************************************************************/
/*
      Funci¿ que retornar¿ tots els avisos a mostrar per pantalla
      pcform IN VARCHAR2                pantalla
      pcmodo IN VARCHAR2                mode
      pcramo IN NUMBER                  ram
      psproduc IN NUMBER                codi producte
      pparams IN clob                   par¿metres que enviem desde la pantalla,
                                        format : SSEGURO#123123;NRIESGO#1;
      plstavisos OUT t_iax_aviso        missatges de sortida
      mensajes OUT  t_iax_mensajes       Mensajes
      return 1/0
      XPL#16072011#18712: LCOL000 - Analisis de bloque de avisos en siniestros
*/
   FUNCTION f_get_avisos(
      pcform IN VARCHAR2,
      pcmodo IN VARCHAR2,
      pcramo IN NUMBER,
      psproduc IN NUMBER,
      pparams IN CLOB,
      plstavisos OUT t_iax_aviso,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;
     	/*************************************************************************
    Funci¿n que permite validar la existencia de otro pago para el destinatario en el siniestro
    param in pnsinies     : N¿mero de siniestro
         return             : 0 grabaci¿n correcta
                           <> 0 grabaci¿n incorrecta
   *************************************************************************/
   FUNCTION f_aviso_pago_tercero(pnsinies  IN VARCHAR2,
                              pctipdes  IN NUMBER,
                              psperson  IN NUMBER,
                              pcconpag  IN NUMBER,
                              pcidioma  in number,
                              ptmensaje out varchar2)
                              RETURN NUMBER;
END pac_iax_avisos;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_AVISOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_AVISOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_AVISOS" TO "PROGRAMADORESCSI";
