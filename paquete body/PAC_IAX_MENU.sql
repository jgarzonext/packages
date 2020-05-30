--------------------------------------------------------
--  DDL for Package Body PAC_IAX_MENU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IAX_MENU" AS
/******************************************************************************
   NOMBRE:      PAC_IAX_MENU
   PROPÓSITO: Funciones para la gestión del menú de la aplicación.

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        15/05/2008   JAS                1. Creación del package.
******************************************************************************/
   e_param_error  EXCEPTION;
   e_object_error EXCEPTION;

   /*************************************************************************
      Obtención del menú de la aplicación
      param in pcidioma    : Idioma del menú.
      param out mensajes   : mensajes de error
      return               : Cursor con el menú de la aplicación.
   *************************************************************************/
   FUNCTION f_get_menu(pcidioma IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vobjectname    VARCHAR2(500) := 'pac_iax_menu.f_get_menu';
      vparam         VARCHAR2(500) := 'parámetros - pcidioma: ' || pcidioma;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vrefcursor     sys_refcursor;
   BEGIN
      --Comprovació de paràmetres d'entrada
      IF pcidioma IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      vrefcursor := pac_md_menu.f_get_menu(pcidioma, mensajes);
      RETURN vrefcursor;
   EXCEPTION
      WHEN e_param_error THEN
         IF vrefcursor%ISOPEN THEN
            CLOSE vrefcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN vrefcursor;
      WHEN OTHERS THEN
         IF vrefcursor%ISOPEN THEN
            CLOSE vrefcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN vrefcursor;
   END;

   /*************************************************************************
      Obtención de los posibles módulos accesible desde un menú
      param out mensajes   : mensajes de error
      return               : Cursor con el menú de la aplicación.
   *************************************************************************/
   FUNCTION f_get_modulos_menu(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vobjectname    VARCHAR2(500) := 'pac_iax_menu.f_get_modulos_menu';
      vparam         VARCHAR2(500) := 'parámetros -';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vrefcursor     sys_refcursor;
   BEGIN
      vpasexec := 3;

      OPEN vrefcursor FOR
         SELECT DISTINCT cinvcod
                    FROM menu_opciones
                   WHERE cinvcod IS NOT NULL;

      RETURN vrefcursor;
   EXCEPTION
      WHEN OTHERS THEN
         IF vrefcursor%ISOPEN THEN
            CLOSE vrefcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN vrefcursor;
   END f_get_modulos_menu;

   /*************************************************************************
      Obtención d'un link (URL)  FORMS extern
      param in pcform    : Form a buscar
      param out mensajes   : mensajes de error
      return               : link extern (URL)
   *************************************************************************/
   FUNCTION f_get_urlforms(pcform IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN VARCHAR2 IS
      vobjectname    VARCHAR2(500) := 'pac_iax_menu.f_get_URLFORMS';
      vparam         VARCHAR2(500) := 'parámetros - pcform: ' || pcform;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vtlink         VARCHAR2(1000);
   BEGIN
      --Comprovació de paràmetres d'entrada
      IF pcform IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      vtlink := pac_md_menu.f_get_urlforms(pcform, pac_md_common.f_get_cxtempresa(), mensajes);
      RETURN vtlink;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN NULL;
   END;

   /*************************************************************************
      Obtención d'un link (URL)   extern
      param in pcmenu    : pcmenu a buscar
      param out mensajes   : mensajes de error
      return               : link extern (URL)
   *************************************************************************/
   FUNCTION f_get_url(pcmenu IN NUMBER, pnvista OUT NUMBER, mensajes OUT t_iax_mensajes)
      RETURN VARCHAR2 IS
      vobjectname    VARCHAR2(500) := 'pac_iax_menu.f_get_URL';
      vparam         VARCHAR2(500) := 'parámetros - pcmenu: ' || pcmenu;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vtlink         VARCHAR2(1000);
   BEGIN
      --Comprovació de paràmetres d'entrada
      IF pcmenu IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      vtlink := pac_md_menu.f_get_url(pcmenu, pac_md_common.f_get_cxtempresa(), pnvista,
                                      mensajes);
      RETURN vtlink;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN NULL;
   END;

   /*************************************************************************
      Obtencion de URL externa
      param in pcform : Nombre de pantalla a abrir
      param out mensajes   : mensajes de error
      return               : Link Externo (URL)
   *************************************************************************/
   FUNCTION f_get_urladf(pcform IN menu_opciones.cinvcod%TYPE, mensajes OUT t_iax_mensajes)
      RETURN VARCHAR2 IS
      --
      vobjectname    VARCHAR2(50) := 'pac_iax_menu.F_GET_URLADF';
      vparam         VARCHAR2(500) := 'parámetros - pcform: ' || pcform;
      vpasexec       NUMBER(5) := 1;
      vtlink         VARCHAR2(1000);
   --
   BEGIN
      --
      vpasexec := 1;

      --
      IF pcform IS NULL THEN
         RAISE e_param_error;
      END IF;

      --
      vpasexec := 2;
      vtlink := pac_md_menu.f_get_urladf(pcform, mensajes);
      vpasexec := 3;
      --
      RETURN vtlink;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN NULL;
   END f_get_urladf;

   /*************************************************************************
      Generacion de token para aplicacion externa
      param out mensajes   : mensajes de error
      return               : token Externo (codigo ALFANUMERICO)
   *************************************************************************/
   FUNCTION f_get_token(mensajes OUT t_iax_mensajes)
      RETURN VARCHAR2 IS
      --
      vobjectname    VARCHAR2(50) := 'pac_iax_menu.F_GET_TOKEN';
      vparam         VARCHAR2(500) := 'parámetros ';
      vpasexec       NUMBER(5) := 1;
      vtoken         llamadas_externas.token%TYPE;
   --
   BEGIN
      --
      vtoken := pac_md_menu.f_get_token(mensajes);
      --
      COMMIT;
      --
      RETURN vtoken;
   --
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN NULL;
   END f_get_token;
END pac_iax_menu;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_MENU" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_MENU" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_MENU" TO "PROGRAMADORESCSI";
