--------------------------------------------------------
--  DDL for Package PAC_MD_PROD_GENERICOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_MD_PROD_GENERICOS" IS
/******************************************************************************
   NOMBRE:       pac_md_prod_genericos
   PROPÓSITO: Funciones para gestionar productos genericos

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        19/08/2010    XPL              1. Creación del package.
******************************************************************************/

   /*************************************************************************
   Obtiene las companias asociadas al seguro especificado
   param in psseguro   : Codigo sseguro
   param out ptcompanias   : Companias
   param out mensajes    : Codi idioma
   return              : 0.- OK, 1.- KO
   *************************************************************************/
   FUNCTION f_obtener_companias(
      psseguro IN NUMBER,
      ptcompanias OUT t_iax_companiprod,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_traspasar_especifico(
      det_poliza IN OUT ob_iax_detpoliza,
      mensajes IN OUT t_iax_mensajes)
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
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;
END pac_md_prod_genericos;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_PROD_GENERICOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_PROD_GENERICOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_PROD_GENERICOS" TO "PROGRAMADORESCSI";
