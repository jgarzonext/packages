--------------------------------------------------------
--  DDL for Package PAC_MENU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_MENU" AS
/******************************************************************************
   NOMBRE:    PAC_MENU
   PROPÓSITO: Funciones para la gestión del menú de la aplicación.

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        12/06/2008   XPL                1. Creación del package.
******************************************************************************/

   /*************************************************************************
      Obtención d'un link (URL)  extern
      param in pcmenu    : pcmenu a buscar
      param in PCEMPRES    : PCEMPRES a consultar
      param out plink   : link a mostrar
      return               : Error
   *************************************************************************/
   FUNCTION f_get_url(
      pcmenu IN NUMBER,
      pcempres IN NUMBER,
      plink OUT VARCHAR2,
      pvista OUT NUMBER)
      RETURN NUMBER;

   -- dramon 17-10-2008: bug mantis 3609
   FUNCTION f_get_menu(
      pcuser IN VARCHAR2,
      pcidioma IN NUMBER,
      psqlstmt OUT VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Generacion de token para aplicacion externa
      param out mensajes   : mensajes de error
      return               : token Externo (codigo ALFANUMERICO)
   *************************************************************************/
   FUNCTION f_get_token(mensajes IN OUT t_iax_mensajes)
      RETURN VARCHAR2;
END pac_menu;

/

  GRANT EXECUTE ON "AXIS"."PAC_MENU" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MENU" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MENU" TO "PROGRAMADORESCSI";
