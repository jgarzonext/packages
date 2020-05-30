--------------------------------------------------------
--  DDL for Package PAC_IAX_DESCVALORES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_IAX_DESCVALORES" AS
/******************************************************************************
   NOMBRE:      PAC_IAX_DESCVALORES
   PROP真SITO:   Funciones para recuperar descripciones de valores

   REVISIONES:
   Ver        Fecha        Autor             Descripci真n
   ---------  ----------  ---------------  ------------------------------------
   1.0        07/05/2008   JAS                1. Creaci真n del package.
   2.0        05/05/2010   AMC                2. Bug 14284. Se a真aden nuevas funciones.
   3.0        24/01/2011   DRA                3. 0016576: AGA602 - Parametritzaci真 de reemborsaments per veterinaris
   4.0        06/06/2012   ETM                4. 0021404: MDP - PER - Validaci真n de documentos en funci真n del tipo de sociedad
   5.0        05/07/2013   FAL                5. 0026968: RSAG101 - Producto RC Argentina. Incidencias (14/5)
******************************************************************************/
   FUNCTION f_get_descpais(pcpais IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN VARCHAR2;

   FUNCTION f_get_descprovincia(
      pcprovin IN NUMBER,
      pcpais IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN VARCHAR2;

   FUNCTION f_get_descproblacion(
      pcprovin IN NUMBER,
      pcpoblac IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN VARCHAR2;

   /*************************************************************************
        Recupera la descripci真n del acto
        param in pcacto     : codigo del acto
        param in pcgarant   : codigo de la garantia
        param in pagr_salud : codigo de la agrupacion
        param out mensajes  : mesajes de error
        return              : descripci真n del acto
     *************************************************************************/
   FUNCTION f_descreembactos(
      pcacto IN VARCHAR2,
      pcgarant IN NUMBER,   -- BUG16576:DRA:24/01/2011
      pagr_salud IN VARCHAR2,   -- BUG16576:DRA:24/01/2011
      mensajes OUT t_iax_mensajes)
      RETURN VARCHAR2;

   /*************************************************************************
        Recupera la descripci真n del evento
        param in pcacto     : codigo del evento
        param out mensajes  : mesajes de error
        return              : descripci真n del devento
     *************************************************************************/
   FUNCTION f_get_descevento(pcevento IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN VARCHAR2;

   /*******************************************************
      Funci真n que devuelve la descripci真n de una garant真a
      PARAM IN pcgarant : codigo de la garant真a
      PARAM IN pcidioma : c真digo de idioma
      PARAM OUT ptgarant : descripci真n de la garant真a
      PARAM OUT mensajes : mensajes de error
      RETURN NUMBER

      Bug 14284 - 27/04/2010 - AMC
   *******************************************************/
   FUNCTION f_descgarant(
      pcgarant IN NUMBER,
      pcidioma IN NUMBER,
      ptgarant OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
       Recupera la descripci真n del idioma
       param in pcidioma     : codigo del idioma
       param out mensajes  : mesajes de error
       return              : descripci真n del idioma
    *************************************************************************/
   FUNCTION f_get_descidioma(pcidioma IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN VARCHAR2;

   --bug 21404--ETM-- 06/06/2012
    /*************************************************************************
        Recupera la descripci真n del tipo de sociedad
        param in pnnumide     : nubero de nif/cif
        param out mensajes  : mesajes de error
        return              : descripci真n del tipo de sociedad
     *************************************************************************/
   FUNCTION f_get_descsociedad(pnnumide IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN VARCHAR2;

    -- BUG 26968 - FAL - 05/07/2013
   /*************************************************************************
      Recupera el nombre de la nacionalidad
      param in pcnacion       : codigo nacionalidad
      param out mensajes    : mesajes de error
      return                : nombre de la nacionalidad
   *************************************************************************/
   FUNCTION f_get_descnacion(pcnacion IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN VARCHAR2;

   /*************************************************************************
      Recupera el nombre de la poblacion
      param in pcpoblacion  : codigo poblacion
      param out mensajes    : mesajes de error
      return                : nombre de la poblacion
   *************************************************************************/
   FUNCTION f_get_descpoblacionsinprov(
      pcpoblacion IN NUMBER,
      pcprovin OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN VARCHAR2;
-- FI BUG 26968

   /*************************************************************************
      Recupera el nombre del ciiu
      param in ciiu       : codigo del ciiu
      param out mensajes    : mesajes de error
      return                : nombre del ciiu
   *************************************************************************/
   FUNCTION f_get_ciiu(ciiu IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN VARCHAR2;

   FUNCTION f_get_tipoVia(pcsiglas IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN VARCHAR2;

END pac_iax_descvalores;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_DESCVALORES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_DESCVALORES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_DESCVALORES" TO "PROGRAMADORESCSI";
