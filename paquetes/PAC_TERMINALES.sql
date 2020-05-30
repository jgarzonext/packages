--------------------------------------------------------
--  DDL for Package PAC_TERMINALES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_TERMINALES" AS
/******************************************************************************
   NOMBRE:      PAC_TERMINALES
   PROPÓSITO:   Funciones para la gestión de los terminales

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        05/11/2008   AMC                1. Creación del package.
******************************************************************************/


   /*************************************************************************
       Inserta o Modifica un terminal.
       param in pcempres   : código de la empresa
       param in pcmaqfisi  : Máquina física
       param in pcterminal : Terminal Axis
       return           : 0 indica cambio realizado correctamente
                          <> 0 indica error
    *************************************************************************/
    FUNCTION F_SET_TERMINAL ( pcempres	    NUMBER,
                              pcmaqfisi	    VARCHAR2,
                              pcterminal    VARCHAR2 ) return number;


   /*************************************************************************
       Borra un terminal.
       param in pcempres   : código de la empresa
       param in pcmaqfisi  : Máquina física
       param in pcterminal : Terminal Axis
       return           : 0 indica cambio realizado correctamente
                          <> 0 indica error
    *************************************************************************/
    FUNCTION F_DEL_TERMINAL ( pcempres	    NUMBER,
                              pcmaqfisi	    VARCHAR2,
                              pcterminal    VARCHAR2 ) return number;

   /*************************************************************************
       Modifica un terminal.
       param in pcempres   : código de la empresa
       param in pcmaqfisi  : Máquina física
       param in pcterminal : Terminal Axis
       param in pnewcmaqfisi  : Nueva Máquina física
       param in pnewcterminal : Nuevo Terminal Axis
       return           : 0 indica cambio realizado correctamente
                          <> 0 indica error
    *************************************************************************/
    FUNCTION F_UPDATE_TERMINAL ( pcempres	    NUMBER,
                                 pcmaqfisi	    VARCHAR2,
                                 pcterminal     VARCHAR2,
                                 pnewcmaqfisi   VARCHAR2,
                                 pnewcterminal  VARCHAR2 ) return number;

   /*************************************************************************
       Consulta terminales.
       param in pcempres   : código de la empresa
       param in pcmaqfisi  : Máquina física
       param in pcterminal : Terminal Axis
       return           : retorna la cadena con la búsqueda
    *************************************************************************/
    FUNCTION FF_CONSULTA_TERMINALES ( pcempres	    NUMBER,
                              pcmaqfisi	    VARCHAR2,
                              pcterminal    VARCHAR2 ) return VARCHAR2;


END PAC_TERMINALES;
 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_TERMINALES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_TERMINALES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_TERMINALES" TO "PROGRAMADORESCSI";
