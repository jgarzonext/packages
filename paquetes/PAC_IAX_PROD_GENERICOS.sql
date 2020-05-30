--------------------------------------------------------
--  DDL for Package PAC_IAX_PROD_GENERICOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_IAX_PROD_GENERICOS" IS
/******************************************************************************
   NOMBRE:       pac_md_prod_genericos
   PROPÓSITO: Funciones para gestionar productos genericos

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        19/08/2010    XPL              1. Creación del package.
******************************************************************************/
   tcompanias     t_iax_companiprod;   -- objeto companias
   vsseguro       NUMBER;

   /*************************************************************************
   Obtiene las companias asociadas al seguro especificado
   param in psseguro   : Codigo sseguro
   param out ptcompanias   : Companias
   param out mensajes  : Mensajes
   return              : 0.- OK, 1.- KO
   *************************************************************************/
   FUNCTION f_obtener_companias(
      psseguro IN NUMBER,
      ptcompanias OUT t_iax_companiprod,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   Marca el producto correspondiente al seguro especificado
   param in psseguro   : Codigo sseguro
   param in pccompani  : Codigo compania
   param in pmarcar    : Marca
   param in pmodo      : Modo
   param out mensajes  : Mensajes
   return              : 0.- OK, 1.- KO
   *************************************************************************/
   FUNCTION f_marcar_compania(
      psseguro IN NUMBER,
      pccompani IN NUMBER,
      psproduc IN NUMBER,
      pmarcar IN NUMBER,
      piddoc IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   Pide un presupuesto
   param out mensajes  : Mensajes
   return              : 0.- OK, 1.- KO
   *************************************************************************/
   FUNCTION f_pedir_presupuesto(mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   Contrata un producto específico
   param out psseguro  : Codigo sseguro
   param out pnpoliza  : Num. poliza
   param out mensajes  : Mensajes
   return              : 0.- OK, 1.- KO
   *************************************************************************/
   FUNCTION f_contratar_especifico(
      psseguro IN NUMBER,
      pccompani IN NUMBER,
      psproduc IN NUMBER,
      psproducesp OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

      /*******************************************************************************
   FUNCION Ppac_iax_prod_genericos.f_notifica_deposito
   Registra en la genda de la propuesta cuando existe un deposito en la poliza

   Parámetros:
     param in pnrecibo  : Número de recibo
     param in pctipcob  : Tipo de cobro (V.F.: 552)
     param in piparcial : Importe del cobro parcial
     param in pcmoneda  : Código de moneda (inicialmente no se tiene en cuenta)
     psolicitud
     return: number un número con el id del error, en caso de que todo vaya OK, retornará un cero.
   ********************************************************************************/
   FUNCTION f_notifica_deposito(
      pnrecibo IN NUMBER,
      pctipcob IN NUMBER,
      piparcial IN NUMBER,
      pcmoneda IN NUMBER,
      psolicitud IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;
END pac_iax_prod_genericos;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_PROD_GENERICOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_PROD_GENERICOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_PROD_GENERICOS" TO "PROGRAMADORESCSI";
