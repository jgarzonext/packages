--------------------------------------------------------
--  DDL for Package PAC_IAX_ECO_MONEDAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_IAX_ECO_MONEDAS" AS
/******************************************************************************
   NOMBRE:    pac_iax_eco_monedas
   PROPÓSITO: Contiene las funciones para manejo de monedas

   REVISIONES:

   Ver        Fecha        Autor  Descripción
   ---------  ----------  ------  ------------------------------------
     1        04/04/2013   MLR    1. 0025803: RSA001 - Ampliar los decimales que utiliza iAXIS
******************************************************************************//*************************************************************************
      FUNCTION f_obtener_moneda_seguro2
       Retorna la moneda delproducto en el seguro
       psseguro IN        : código de seguro
       return             : código de la moneda internacional
   *************************************************************************/
   FUNCTION f_obtener_moneda_seguro2(
      psseguro IN seguros.sseguro%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN eco_codmonedas.cmoneda%TYPE;

   /*************************************************************************
       FUNCTION f_obtener_moneda_producto2
        Retorna la moneda delproducto en el seguro
        psproduc IN        : código de producto
        return             : código de la moneda internacional
    *************************************************************************/
   FUNCTION f_obtener_moneda_producto2(
      psproduc IN productos.sproduc%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN eco_codmonedas.cmoneda%TYPE;

   /*************************************************************************
      FUNCTION f_obtener_cmonint
       Obtiene el codigo internacional de la moneda
       param pmoneda IN monedas.cmoneda%TYPE: Codigo de la moneda en la tabla monedas
       return                : Codigo de la moneda internacional
   *************************************************************************/
   FUNCTION f_obtener_cmonint(pmoneda IN monedas.cmoneda%TYPE, mensajes OUT t_iax_mensajes)
      RETURN monedas.cmonint%TYPE;

   /*************************************************************************
      FUNCTION f_obtener_cmoneda
       Obtiene el codigo moneda
       param monedas.cmonint%TYPE: Codigo de la moneda internacional
       return                : Codigo de la moneda en la tabla de monedas
   *************************************************************************/
   FUNCTION f_obtener_cmoneda(pmoneda IN monedas.cmonint%TYPE, mensajes OUT t_iax_mensajes)
      RETURN monedas.cmoneda%TYPE;
END pac_iax_eco_monedas;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_ECO_MONEDAS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_ECO_MONEDAS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_ECO_MONEDAS" TO "PROGRAMADORESCSI";
