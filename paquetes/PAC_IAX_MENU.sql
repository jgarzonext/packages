--------------------------------------------------------
--  DDL for Package PAC_IAX_MENU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_IAX_MENU" AS
/******************************************************************************
   NOMBRE:      PAC_IAX_MENU
   PROPÓSITO: Funciones para la gestión del menú de la aplicación.

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        15/05/2008   JAS                1. Creación del package.
******************************************************************************/

   /*************************************************************************
      Obtención del menú de la aplicación
      param in pcidioma    : Idioma del menú.
      param out mensajes   : mensajes de error
      return               : Cursor con el menú de la aplicación.
   *************************************************************************/
   FUNCTION f_get_menu(pcidioma IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Obtención de los posibles módulos accesible desde un menú
      param out mensajes   : mensajes de error
      return               : Cursor con la lista de módulos.
   *************************************************************************/
   FUNCTION f_get_modulos_menu(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Obtención d'un link (URL)  FORMS extern
      param in pcform    : Form a buscar
      param out mensajes   : mensajes de error
      return               : link extern (URL)
   *************************************************************************/
   FUNCTION f_get_urlforms(pcform IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN VARCHAR2;

   /*************************************************************************
      Obtención d'un link (URL)   extern
      param in pcmenu    : pcmenu a buscar
      param out mensajes   : mensajes de error
      return               : link extern (URL)
   *************************************************************************/
   FUNCTION f_get_url(pcmenu IN NUMBER, pnvista OUT NUMBER, mensajes OUT t_iax_mensajes)
      RETURN VARCHAR2;

   /*************************************************************************
      Obtencion de URL externa
      param in pcform : Nombre de pantalla a abrir
      param out mensajes   : mensajes de error
      return               : Link Externo (URL)
   *************************************************************************/
   FUNCTION f_get_urladf(pcform IN menu_opciones.cinvcod%TYPE, mensajes OUT t_iax_mensajes)
      RETURN VARCHAR2;

   /*************************************************************************
      Generacion de token para aplicacion externa
      param out mensajes   : mensajes de error
      return               : token Externo (codigo ALFANUMERICO)
   *************************************************************************/
   FUNCTION f_get_token(mensajes OUT t_iax_mensajes)
      RETURN VARCHAR2;
END pac_iax_menu;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_MENU" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_MENU" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_MENU" TO "PROGRAMADORESCSI";
