--------------------------------------------------------
--  DDL for Package PAC_CBANCAR_SEG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_CBANCAR_SEG" AS
/******************************************************************************
   NOMBRE:    PAC_CBANCAR_SEG
   PROPÓSITO: Retornará las Cuentas bancarias

   REVISIONES:
   Ver        Fecha       Autor            Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        15/01/2009  MCC              1. Creación del package.
******************************************************************************/

   /*************************************************************************
      Retorna un cursor con el histirico de cuentas asociadas a una póliza
      param in PSSEGURO : código seguro
      param out PRESULT  : cursor de resultados
      param out MENSAJES : mensajes de error
   *************************************************************************/
   FUNCTION f_get_cbancar_seghis(psseguro IN NUMBER, presult OUT sys_refcursor)
      RETURN NUMBER;

   /*************************************************************************
        Retorna la última cuenta de cargo asociada a la póliza
        param in PSSEGURO  : código seguro
        param in DATE      : fecha
        param out PCBANCAR : cuenta bancaria
        param out PCBANCOB : cuenta de cobro
     *************************************************************************/
   FUNCTION f_get_cbancar_seg(psseguro IN NUMBER, pfecha IN DATE, pcbancar OUT VARCHAR2,
   pcbancob OUT VARCHAR2)
      RETURN NUMBER;

   /*************************************************************************
       La función se encarga de grabar los datos de la cuenta de cargo
       param in PSSEGURO : código seguro
       param in PCBANCOB : cuenta de cobro
    *************************************************************************/
   FUNCTION f_set_cbancar_seg(psseguro IN NUMBER, pcbancob IN VARCHAR2)
      RETURN NUMBER;

/***********************************************************************
       Formatea la cuenta bancaria
       param in ctipban : tipo cuenta
       param in cbancar : cuenta bancaria
       return           : cuenta formateada si ha podido aplicar el formato
                          sino devuelve la cuenta
    ***********************************************************************/
   FUNCTION ff_formatccc(ctipban IN NUMBER, cbancar IN VARCHAR2)
      RETURN VARCHAR2;
END pac_cbancar_seg;
 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_CBANCAR_SEG" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_CBANCAR_SEG" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_CBANCAR_SEG" TO "PROGRAMADORESCSI";
