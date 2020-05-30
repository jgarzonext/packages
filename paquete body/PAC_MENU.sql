--------------------------------------------------------
--  DDL for Package Body PAC_MENU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MENU" AS
/******************************************************************************
   NOMBRE:      PAC_MENU
   PROPÓSITO: Funciones para la gestión del menú de la aplicación.

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        12/06/2008   XPL            1. Creación del package.
******************************************************************************/
   e_param_error  EXCEPTION;
   e_object_error EXCEPTION;

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
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'pac_menu.f_get_forms_link';
      vparam         VARCHAR2(500)
                             := 'parámetros - PCMENU: ' || pcmenu || ' PCEMPRES :' || pcempres;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vtsql          VARCHAR2(1100);
   BEGIN
      --Comprovació de paràmetres d'entrada
      IF pcmenu IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF pcempres IS NULL THEN
         RAISE e_param_error;
      END IF;

      SELECT turl, cvista
        INTO plink, pvista
        FROM menu_url
       WHERE cempres = pcempres
         AND cmenu = pcmenu;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'Objeto invocado con parámetros erroneos');
         RETURN 120135;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 120135;
   END f_get_url;

   -- dramon 17-10-2008: bug mantis 3609
   FUNCTION f_get_menu(
      pcuser IN VARCHAR2,
      pcidioma IN NUMBER,
      psqlstmt OUT VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'pac_menu.f_get_menu';
      vparam         VARCHAR2(500)
                           := 'parámetros - pcuser: ' || pcuser || ' - pcidioma: ' || pcidioma;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      ncambiapwd     NUMBER;
   BEGIN
      --Comprovació de paràmetres d'entrada
      IF pcidioma IS NULL
         OR pcuser IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_user.f_get_cambia_pass(pcuser, ncambiapwd);

      IF ncambiapwd = 0 THEN
         psqlstmt := 'SELECT nivel,copcion,literal,form,cmodo,cmenpad,norden'
                     || ' FROM (SELECT LEVEL+1 nivel,' || 'o.copcion,'
                     || 'f_axis_literales(o.slitera,' || pcidioma || ') literal,'
                     || 'o.cinvcod form,' || 'o.cmodo,' || 'o.cmenpad,' || 'o.norden'
                     || ' FROM menu_opciones o' || ' WHERE o.copcion IN (SELECT rol.copcion'
                     || ' FROM menu_usercodirol u,' || 'menu_opcionrol rol'
                     || ' WHERE u.cuser = ''' || pcuser || CHR(39)
                     || ' AND rol.crolmen = u.crolmen)'
                     || ' CONNECT BY PRIOR o.copcion = o.cmenpad'
                     || ' START WITH o.cmenpad = 0' || ' UNION' || ' SELECT LEVEL+1 nivel,'
                     || 'o.copcion,' || 'f_axis_literales(o.slitera, ' || pcidioma
                     || ') literal,' || 'o.cinvcod form,' || 'u.cmodo,' || 'o.cmenpad,'
                     || 'o.norden' || ' FROM menu_opciones o,' || 'menu_useropciones u'
                     || ' WHERE u.cuser = ''' || pcuser || CHR(39)
                     || ' AND o.copcion = u.copcion'
                     || ' CONNECT BY o.cmenpad = PRIOR o.copcion'
                     || ' START WITH 0 = o.cmenpad)' || ' ORDER BY norden';
      ELSE
         psqlstmt :=
            '   SELECT   nivel, copcion, literal, form, cmodo, cmenpad, norden'
            || '  FROM (SELECT 3 nivel, o.copcion, f_axis_literales(o.slitera, 1) literal, o.cinvcod form,'
            || '               o.cmodo, cmenpad, o.norden' || '          FROM menu_opciones o'
            || '         WHERE UPPER(o.cinvcod) = ''AXISUSU001'''
            || '           and rownum=1)' || '         union'
            || '        SELECT 2 nivel, o.copcion, f_axis_literales(o.slitera, 1) literal, o.cinvcod form,'
            || '               o.cmodo, cmenpad, o.norden' || '          FROM menu_opciones o'
            || '         WHERE norden = (select cmenpad' || '          from menu_opciones b'
            || '         where UPPER(b.cinvcod) = ''AXISUSU001'''
            || '           and rownum=1)' || 'ORDER BY norden';
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 9000553;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 9000553;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 9000553;
   END f_get_menu;

   /*************************************************************************
      Generacion de token para aplicacion externa
      param out mensajes   : mensajes de error
      return               : token Externo (codigo ALFANUMERICO)
   *************************************************************************/
   FUNCTION f_get_token(mensajes IN OUT t_iax_mensajes)
      RETURN VARCHAR2 IS
      --
      vobjectname    VARCHAR2(50) := 'pac_menu.F_GET_TOKEN';
      vparam         VARCHAR2(500) := 'parámetros - ';
      vpasexec       NUMBER(5) := 1;
      vtoken         llamadas_externas.token%TYPE;
   --
   BEGIN
      --
      LOOP
         --
         SELECT DBMS_RANDOM.STRING('X', 10)
           INTO vtoken
           FROM DUAL;

         --
         BEGIN
            --
            INSERT INTO llamadas_externas
                        (token, cusuari, falta)
                 VALUES (vtoken, f_user, f_sysdate);

            --
            EXIT;
         --
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               NULL;
         END;
      --
      END LOOP;

      --
      RETURN vtoken;
   --
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN NULL;
   END f_get_token;
END pac_menu;

/

  GRANT EXECUTE ON "AXIS"."PAC_MENU" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MENU" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MENU" TO "PROGRAMADORESCSI";
