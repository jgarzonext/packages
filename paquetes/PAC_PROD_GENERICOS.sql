--------------------------------------------------------
--  DDL for Package PAC_PROD_GENERICOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_PROD_GENERICOS" IS
/******************************************************************************
   NOMBRE:       pac_prod_genericos
   PROPÓSITO: Funciones para gestionar productos genericos

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        19/08/2010    XPL              1. Creación del package.
   2.0        03/01/2011    LCF              2. Modificacion prescompanias
******************************************************************************/

   /*************************************************************************
   Obtiene las companias asociadas al seguro especificado
   param in psseguro   : Codigo sseguro
   param out psquery   : Select
   param in pidioma    : Codi idioma
   return              : 0.- OK, 1.- KO
   *************************************************************************/
   FUNCTION f_obtener_companias(psseguro IN NUMBER, pquery OUT VARCHAR2, pidioma IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
   Obtiene las companias asociadas al seguro especificado haciendo join con presseguros(presupuestos pedidos)
   param in psseguro   : Codigo sseguro
   param out psquery   : Select
   param in pidioma    : Codi idioma
   return              : 0.- OK, 1.- KO
   *************************************************************************/
   FUNCTION f_obtener_prescompanias(psseguro IN NUMBER, pquery OUT VARCHAR2, pidioma IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_traspasar_especifico(
      psproduc IN NUMBER,
      psseguro IN NUMBER,
      pssegpol OUT NUMBER,
      pcramo OUT NUMBER,
      pcmodali OUT NUMBER,
      pctipseg OUT NUMBER,
      pccolect OUT NUMBER,
      pcactivi OUT NUMBER)
      RETURN NUMBER;

   /*************************************************************************
   Marca el producto correspondiente al seguro especificado
   param in psseguro   : Codigo sseguro
   param in pccompani  : Codigo compania
   param in pmarcar    : Marca
   param in pmodo      : Modo

   return              : 0.- OK, 1.- KO
   *************************************************************************/
   FUNCTION f_marcar_compania(
      psseguro IN NUMBER,
      pccompani IN NUMBER,
      psproduc IN NUMBER,
      pmarcar IN NUMBER,
      piddoc IN NUMBER)
      RETURN NUMBER;
END pac_prod_genericos;
 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_PROD_GENERICOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_PROD_GENERICOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_PROD_GENERICOS" TO "PROGRAMADORESCSI";
