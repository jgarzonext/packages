--------------------------------------------------------
--  DDL for Package PAC_MD_TERMINALES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_MD_TERMINALES" AS
/******************************************************************************
   NOMBRE:      PAC_MD_TERMINALES
   PROPÓSITO:   Funciones para la gestión de los terminales

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        06/11/2008   AMC                1. Creación del package.
******************************************************************************/

   /*************************************************************************
       Inserta o Modifica un terminal.
       param in pcempres   : código de la empresa
       param in pcmaqfisi  : Máquina física
       param in pcterminal : Terminal Axis
       param out mensajes: mensajes de error
       return           : 0 indica cambio realizado correctamente
                          <> 0 indica error
    *************************************************************************/
    FUNCTION F_SET_TERMINAL ( pcempres	    NUMBER,
                              pcmaqfisi	    VARCHAR2,
                              pcterminal    VARCHAR2,
                              mensajes IN OUT T_IAX_MENSAJES ) return number;

       /*************************************************************************
       Borra un terminal.
       param in pcempres   : código de la empresa
       param in pcmaqfisi  : Máquina física
       param in pcterminal : Terminal Axis
       param out mensajes: mensajes de error
       return           : 0 indica cambio realizado correctamente
                          <> 0 indica error
    *************************************************************************/
    FUNCTION F_DEL_TERMINAL ( pcempres	    NUMBER,
                              pcmaqfisi	    VARCHAR2,
                              pcterminal    VARCHAR2,
                              mensajes IN OUT T_IAX_MENSAJES ) return number;


   /*************************************************************************
       Modifica un terminal.
       param in pcempres   : código de la empresa
       param in pcmaqfisi  : Máquina física
       param in pcterminal : Terminal Axis
       param in pnewcmaqfisi  : Nueva Máquina física
       param in pnewcterminal : Nuevo Terminal Axis
       param out mensajes: mensajes de error
       return           : 0 indica cambio realizado correctamente
                          <> 0 indica error
    *************************************************************************/
    FUNCTION F_UPDATE_TERMINAL ( pcempres	    NUMBER,
                                 pcmaqfisi	    VARCHAR2,
                                 pcterminal     VARCHAR2,
                                 pnewcmaqfisi   VARCHAR2,
                                 pnewcterminal  VARCHAR2,
                                 mensajes IN OUT T_IAX_MENSAJES ) return number;

    /*************************************************************************
       Devuelve los terminales que cumplan con el criterio de selección
       param in pcempres   : código de la empresa
       param in pcmaqfisi  : Máquina física
       param in pcterminal : Terminal Axis
       param out mensajes    : mensajes de error
       return                : ref cursor
    *************************************************************************/
    FUNCTION F_CONSULTA_TERMINALES(pcempres	    NUMBER,
                              pcmaqfisi	    VARCHAR2,
                              pcterminal    VARCHAR2,
                              mensajes IN OUT T_IAX_MENSAJES) RETURN SYS_REFCURSOR;

END PAC_MD_TERMINALES;
 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_TERMINALES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_TERMINALES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_TERMINALES" TO "PROGRAMADORESCSI";
