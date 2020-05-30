--------------------------------------------------------
--  DDL for Package PAC_MD_LISTADO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_MD_LISTADO" AS
/******************************************************************************
   NOMBRE:       pac_md_listado
   PROPÓSITO:    Contiene las funciones para el lanzamiento de listados a través de AXISCONNECT.

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        06/05/2009   JGM              1. Creación del package.
   2.0        06/05/2010   ICV              2. 0012746: APRB95 - lista de movimientos de saldo por cliente
   3.0        03/06/2011   JTS              3. 18734: CRT003 - Modificación de los listados de Administración y Producción
   4.0        28/01/2013   MDS              4. 0024743: (POSDE600)-Desarrollo-GAPS Tecnico-Id 146 - Modif listados para regional sucursal
   5.0        02/05/2013   JMF              5. 0025623 (POSDE200)-Desarrollo-GAPS - Comercial - Id 56
******************************************************************************/

   /******************************************************************************
   F_GENERAR_LISTADO - Lanza el listado de comisiones de APRA
         p_cempres IN NUMBER,
         p_sproces IN NUMBER,
         p_cagente IN NUMBER,
         mensajes OUT t_iax_mensajes)
   Retorna 0 si OK 1 si KO
   ********************************************************************************/
   FUNCTION f_generar_listado(
      p_cempres IN NUMBER,
      p_sproces IN NUMBER,
      p_cagente IN NUMBER,
      p_fitxer1 IN OUT VARCHAR2,
      p_fitxer2 IN OUT VARCHAR2,
      p_fitxer3 IN OUT VARCHAR2,
      p_fitxer4 IN OUT VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Impresió
      param in out  psinterf
      param in      pcempres:  codi d'empresa
      param in      pdatasource
      param in      pcidioma
      param in      pcmapead
      param out     perror
      param out     mensajes    missatges d'error

      return                    0/1 -> Tot OK/error

      Bug 14067 - 13/04/2010 - AMC
   *************************************************************************/
   FUNCTION f_genera_report(
      psinterf IN NUMBER,
      pcempres IN NUMBER,
      pdatasource IN VARCHAR2,
      pcidioma IN NUMBER,
      pcmapead IN VARCHAR2,   --Bug.: 12746 - 06/05/2010 - ICV
      perror OUT VARCHAR2,
      preport OUT VARCHAR2,
      mensajes OUT t_iax_mensajes,
      genera_report IN NUMBER DEFAULT 1)
      RETURN NUMBER;

    /******************************************************************************
      f_crida_llistats - Función que hace la llamada a los Jasper Reports
   ********************************************************************************/
   -- bug 0028554 - 13/03/2014 - JMF: parametro opcional pdestcopia
   FUNCTION f_crida_llistats(
      psinterf IN OUT NUMBER,
      pcempres IN NUMBER,
      pterminal IN VARCHAR2,
      pusuario IN VARCHAR2,
      ptpwd IN VARCHAR2,
      pid IN VARCHAR2,
      ptipodestino IN VARCHAR2,
      pplantillaorigen IN VARCHAR2,
      pdestino IN VARCHAR2,
      pdatasource IN VARCHAR2,
      perror OUT VARCHAR2,
      mensajes IN OUT t_iax_mensajes,
      pdestcopia IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;

   /******************************************************************************
   f_importes_339
   --BUG18734 - JTS - 03/06/2011
   ********************************************************************************/
   FUNCTION f_importes_339(
      pcidioma VARCHAR2,
      pfinicial VARCHAR2,
      pffinal VARCHAR2,
      pcempres VARCHAR2,
      psproduc VARCHAR2,
      pcramo VARCHAR2,
      pcagrpro VARCHAR2,
      pcagente VARCHAR2)
      RETURN VARCHAR2;

      /******************************************************************************
      f_importes_645
   -- BUG 24743 - MDS - 28/01/2013
   -- BUG 0025623 - 02/05/2013 - JMF: afegir pperage
   -- versión ampliada de f_importes_339, que incluye los campos Regional y Sucursal para el map 645 de POS
      ********************************************************************************/
   FUNCTION f_importes_645(
      pcidioma VARCHAR2,
      pfinicial VARCHAR2,
      pffinal VARCHAR2,
      pcempres VARCHAR2,
      psproduc VARCHAR2,
      pcramo VARCHAR2,
      pcagrpro VARCHAR2,
      pcagente VARCHAR2,
      pperage IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2;
END pac_md_listado;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_LISTADO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_LISTADO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_LISTADO" TO "PROGRAMADORESCSI";
