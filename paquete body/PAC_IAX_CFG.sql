--------------------------------------------------------
--  DDL for Package Body PAC_IAX_CFG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IAX_CFG" AS
/******************************************************************************
   NOMBRE:      PAC_IAX_CFG
   PROPÓSITO:

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        15/05/2008   JAS               1. Creación del package.
   2.0        23/03/2009   DCT               2. Creación función f_get_lst_cfgdoc
   3.0        05/05/2009   DRA               3. 0009981: IAX - Baixar l'empresa a totes les taules del model CFG

   4.0        26/01/2010   DRA               4. 0011583: CRE - Incidencia en modificación de datos de Suplemento
   5.0        13/10/2010   XPL               5. 16064: CRT101 - Boton enviar correo avisando de nueva solicitud
   6.0        14/10/2010   XPL/AMC           6. Bug 15743
   7.0        26/10/2010   DRA               7. 0016471: CRT - Configuracion de visibilidad/contratacion de productos a nivel de perfil
   8.0        07/01/2011   XPL               8. 17179: AGA003 - Modificación de listados de administración (filtro por fmovdia)
   9.0        07/03/2012   JMP               9. 21569: CRE998 - Configurar llençador d'Informes per perfil
******************************************************************************/
   e_param_error  EXCEPTION;
   e_object_error EXCEPTION;

/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    Autor: Jordi Azorín (04/12/2007)
    Descripción: Recupera la configuración (propiedades) de pantalla por defecto de la aplicación.
    Parámetros entrada: -
    Parámetros salida:  - mensajes  -> Mensajes de error
    Retorno:            - refcursor -> Refcursor con la configuración (propiedades de los campos)
                                        por defecto de la aplicación.
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
   FUNCTION f_get_def_form_property(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vobjectname    VARCHAR2(500) := 'pac_iax_cfg.f_get_def_form_propery';
      vparam         VARCHAR2(500) := 'parámetros - null';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vcuser         VARCHAR2(50);
      vccfgform      VARCHAR2(50);
      vrefcursor     sys_refcursor;
   BEGIN
      --Retorn de les propietats de configuració per defecte dels camps de pantalla (formularis).
      RETURN pac_md_cfg.f_get_def_form_property(mensajes);
   EXCEPTION
      WHEN OTHERS THEN
         IF vrefcursor%ISOPEN THEN
            CLOSE vrefcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN vrefcursor;
   END f_get_def_form_property;

/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    Autor: Jordi Azorín (21/11/2007)
    Descripción: Recupera la configuración (propiedades) de pantalla para un modo concreto y producto determinado.
    Parámetros entrada: - pcform    -> Pantalla
                        - pcmodo    -> Modo de la pantalla
                        - psproduc  -> Código de producto
    Parámetros salida:  - mensajes  -> Mensajes de error
    Retorno:            - refcursor -> Refcursor con la configuración (propiedades de los campos) de la pantalla.
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
   FUNCTION f_get_form_property(
      pcform IN VARCHAR2,
      pcmodo IN VARCHAR2,
      psproduc IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vobjectname    VARCHAR2(500) := 'pac_iax_cfg.f_get_form_property';
      vparam         VARCHAR2(500)
         := 'parámetros - pcform:' || pcform || ' - pmodo: ' || pcmodo || ' - psproduc: '
            || psproduc;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vcuser         VARCHAR2(50);
      vccfgform      VARCHAR2(50);
      vrefcursor     sys_refcursor;
      vcempres       NUMBER(2);   -- BUG9981:DRA:15/05/2009
   BEGIN
      --Comprovació de paràmetres d'entrada
      IF pcform IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      vcuser := pac_md_common.f_get_cxtusuario;
      vcempres := pac_md_common.f_get_cxtempresa;   -- BUG9981:DRA:15/05/2009

      IF vcuser IS NULL THEN
         RAISE e_object_error;
      END IF;

      vpasexec := 5;
      --Recupero la configuració de pantalla associada a l'usuari en la pantalla sol·licitada
      vccfgform := pac_md_cfg.f_get_user_cfgform(vcuser, vcempres, pcform, mensajes);

      IF vccfgform IS NULL THEN
         RAISE e_object_error;
      END IF;

      vpasexec := 7;
      --Retorn de la configuració de pantalla sol·licitada.
      vrefcursor := pac_md_cfg.f_get_form_property(pcform, pcmodo, vccfgform, psproduc,
                                                   pac_md_common.f_get_cxtempresa, mensajes);
      RETURN vrefcursor;
   EXCEPTION
      WHEN e_param_error THEN
         IF vrefcursor%ISOPEN THEN
            CLOSE vrefcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN vrefcursor;
      WHEN e_object_error THEN
         IF vrefcursor%ISOPEN THEN
            CLOSE vrefcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN vrefcursor;
      WHEN OTHERS THEN
         IF vrefcursor%ISOPEN THEN
            CLOSE vrefcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN vrefcursor;
   END f_get_form_property;

/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    Autor: Jordi Azorín (21/11/2007)
    Descripción: Recupera las propiedades de dependencia de una pantalla para un modo concreto y producto determinado.
    Parámetros entrada: - pcform    -> Pantalla
                        - pcmodo    -> Modo de la pantalla
                        - psproduc  -> Código de producto
    Parámetros salida:  - mensajes  -> Mensajes de error
    Retorno:            - refcursor -> Refcursor con las dependencias entre los valores de los campos de la pantalla.
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
   FUNCTION f_get_dep_form_property(
      pcform IN VARCHAR2,
      pcmodo IN VARCHAR2,
      psproduc IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vobjectname    tab_error.tdescrip%TYPE := 'pac_iax_cfg.f_get_form_property';
      vparam         tab_error.tobjeto%TYPE
         := 'parámetros - pcform:' || pcform || ' - pmodo: ' || pcmodo || ' - psproduc: '
            || psproduc;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vcuser         cfg_user.cuser%TYPE;
      vccfgform      cfg_user.ccfgform%TYPE;
      vrefcursor     sys_refcursor;
      vcempres       NUMBER(2);   -- BUG9981:DRA:15/05/2009
   BEGIN
      --Comprovació de paràmetres d'entrada
      IF pcform IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      vcuser := pac_md_common.f_get_cxtusuario;
      vcempres := pac_md_common.f_get_cxtempresa;   -- BUG9981:DRA:15/05/2009

      IF vcuser IS NULL THEN
         RAISE e_object_error;
      END IF;

      vpasexec := 5;
      --Recupero la configuració de pantalla associada a l'usuari en la pantalla sol·licitada
      vccfgform := pac_md_cfg.f_get_user_cfgform(vcuser, vcempres, pcform, mensajes);

      IF vccfgform IS NULL THEN
         RAISE e_object_error;
      END IF;

      vpasexec := 7;
      --Retorn de la configuració de pantalla sol·licitada.
      vrefcursor := pac_md_cfg.f_get_dep_form_property(pcform, pcmodo, vccfgform, psproduc,
                                                       pac_md_common.f_get_cxtempresa,
                                                       mensajes);
      RETURN vrefcursor;
   EXCEPTION
      WHEN e_param_error THEN
         IF vrefcursor%ISOPEN THEN
            CLOSE vrefcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN vrefcursor;
      WHEN e_object_error THEN
         IF vrefcursor%ISOPEN THEN
            CLOSE vrefcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN vrefcursor;
      WHEN OTHERS THEN
         IF vrefcursor%ISOPEN THEN
            CLOSE vrefcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN vrefcursor;
   END f_get_dep_form_property;

/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    Autor: Jordi Azorín (21/11/2007)
    Descripción: Dado un flujo de navegació i una pantalla, retorna la anterior o siguiente pantalla
                que se debe mostrar dentro del flujo. El parámetro "pctinvg" indica si se desea obtener
                la pantalla anterior o siguiente. Si no se informa la pantalla desde la qual se desea
                navegar, retorna la primera pantalla del flujo.
    Parámetros entrada: - pmodo     ->  Flujo de navegación.
                        - psproduc  ->  Código de producto.
                        - pcform    ->  Código de la pantalla actual.
                                        Si se informa a NULL, se retorna la primera pantalla del flujo.
                        - pccampo   ->  Campo desde el que se navega.
                                        Si se informa a NULL, se retorna la navegación por defecto desde la pantalla
                        - pctipnvg  ->  Código de la navegación: 1 -> Anterior / 2 -> Siguiente
    Parámetros salida:  - mensajes  ->  Mensajes de error.
    Retorno:            - VARCHAR2  ->  Código de la pantalla que se debe mostrar.
                                        pcform -> Si desde la pantalla origen se intenta navegar a la anterior.
                                        pcform -> Si desde la pantalla final se intenta navegar a la siguiente.
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
   FUNCTION f_get_form_wizard(
      pcmodo IN VARCHAR2,
      psproduc IN NUMBER,
      pcform IN VARCHAR2,
      pccampo IN VARCHAR2,
      pctipnvg IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN VARCHAR2 IS
      vobjectname    VARCHAR2(500) := 'pac_iax_cfg.f_get_form_wizard';
      vparam         VARCHAR2(500)
         := 'parámetros - pmodo: ' || pcmodo || ' - psproduc: ' || psproduc || ' - pcform: '
            || pcform || ' - pccampo: ' || pccampo || ' - pctipnvg: ' || pctipnvg;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vcuser         VARCHAR2(50);
      vccfgwiz       VARCHAR2(50);
      vcidcfg        NUMBER;
      vcform         VARCHAR2(50);
      vccampo        VARCHAR2(50);
      vcform_sig     VARCHAR2(50);
      vcform_ant     VARCHAR2(50);
      vcsituac       VARCHAR2(2);   -- Bug 16800 - 13/12/2010 - AMC
      vskipform      NUMBER(5);
      vcempres       NUMBER(2);   -- BUG9981:DRA:06/05/2009
   BEGIN
      --Comprovació de paràmetres d'entrada
      IF pcmodo IS NULL
         OR psproduc IS NULL
         OR NVL(pctipnvg, 0) NOT IN(1, 2) THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      vcuser := pac_md_common.f_get_cxtusuario;
      vcempres := pac_md_common.f_get_cxtempresa;   -- BUG9981:DRA:15/05/2009

      IF vcuser IS NULL THEN
         RAISE e_object_error;
      END IF;

      --Recupero la configuració d'usuari associada a l'usuari en el mode sol·licitat
      vccfgwiz := pac_md_cfg.f_get_user_cfgwiz(vcuser, vcempres, pcmodo, mensajes);

      IF vccfgwiz IS NULL THEN
         vpasexec := 5;
         RAISE e_object_error;
      END IF;

      --Si no s'informa el camp des del que es navega, es recuperarà la navegació
      --per defecte des de la pantalla pasada com a paràmetre d'entrada.
      vccampo := NVL(pccampo, '*');
      vpasexec := 7;
      vnumerr := pac_md_cfg.f_get_form_wizard(pcmodo, vccfgwiz, psproduc, pcform, vccampo,
                                              vcempres, vcidcfg, vcform, vcform_sig,
                                              vcform_ant, vcsituac, mensajes);

      --Comprovem si s'han trobat dades.
      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      IF vcform IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9000799);   --Error al recuperar la configuración del usuario.
         RAISE e_object_error;
      END IF;

      vpasexec := 11;

      -- BUG11583:DRA:19/01/2010:Inici: Passem la validació del pcform si NULL al ELSE
      IF (vcsituac = 'O'
          AND pctipnvg = 1)
         OR(vcsituac = 'F'
            AND pctipnvg = 2) THEN
         --Si voliem recuperar la primera pantalla del formulari.
         --Si des de la pantalla origen s'intenta navegar a la anterior.
         --Si des de la pantalla final s'intenta navegar a la següent.
         RETURN vcform;
      ELSE
         IF pcform IS NULL THEN
            -- Es una tonteria pero es para representar que mantenemos el valor
            vcform := vcform;
         ELSIF pctipnvg = 1 THEN
            --Es vol navegar a la pantalla anterior.
            vcform := vcform_ant;
         ELSIF pctipnvg = 2 THEN
            --Es vol navegar a la pantalla següent.
            vcform := vcform_sig;
         ELSE
            --Error en el paràmetre de navegació.
            RAISE e_param_error;
         END IF;

         --Comprovem si s'ha de saltar la pantalla a la es navega.
         vskipform := pac_md_cfg.f_skip_form_wizard(vcidcfg, vcform, vcempres, mensajes);

         IF vskipform IS NULL THEN
            vpasexec := 13;
            RAISE e_object_error;
         ELSIF vskipform = 0 THEN
            --Si no s'ha de saltar la pantalla, retornem la pantalla a la que s'ha de nevegar.
            RETURN vcform;
         ELSE
            --Si s'ha de saltar la pantalla, comprovem quina és l'anterior/següent pantalla que caldria mostrar.
            RETURN f_get_form_wizard(pcmodo, psproduc, vcform, '*', pctipnvg, mensajes);
         END IF;
      END IF;
   -- BUG11583:DRA:19/01/2010:Fi
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN NULL;
   END f_get_form_wizard;

/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    Autor: Jordi Azorín (21/11/2007)
    Descripción: Recupera el flujo de navegación de un modo concreto, para un producto determinado.
    Parámetros entrada: - pcmodo    -> Flujo de navegación
                        - psproduc  -> Código de producto
    Parámetros salida:  - mensajes  -> Mensajes de error
    Retorno:            - refcursor -> Refcursor con el flujo de navegación solicitado.
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
   FUNCTION f_get_wizard(pcmodo IN VARCHAR2, psproduc IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vobjectname    VARCHAR2(500) := 'pac_iax_cfg.f_get_wizard';
      vparam         VARCHAR2(500)
                            := 'parámetros - pmodo: ' || pcmodo || ' - psproduc: ' || psproduc;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vcuser         VARCHAR2(50);
      vccfgwiz       VARCHAR2(50);
      vrefcursor     sys_refcursor;
      vcempres       NUMBER(2);   -- BUG9981:DRA:15/05/2009
   BEGIN
      --Comprovació de paràmetres d'entrada
      IF pcmodo IS NULL
         OR psproduc IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      vcuser := pac_md_common.f_get_cxtusuario;
      vcempres := pac_md_common.f_get_cxtempresa;   -- BUG9981:DRA:06/05/2009

      IF vcuser IS NULL THEN
         RAISE e_object_error;
      END IF;

      vpasexec := 5;
      --Recupero la configuració d'usuari associada a l'usuari en el mode sol·licitat
      vccfgwiz := pac_md_cfg.f_get_user_cfgwiz(vcuser, vcempres, pcmodo, mensajes);

      IF vccfgwiz IS NULL THEN
         RAISE e_object_error;
      END IF;

      vpasexec := 7;
      --Retorn del fluxe de navegació sol·licitat.
      vrefcursor := pac_md_cfg.f_get_wizard(pcmodo, psproduc, vccfgwiz,
                                            pac_md_common.f_get_cxtempresa, mensajes);
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
   END f_get_wizard;

   /******************************************************************************************
     Autor: CPM (07/11/2008)
     Descripción: Recupera la configuración de la navegación.
     Parámetros entrada: -
     Parámetros salida:  - mensajes  -> Mensajes de error
     Retorno:            - refcursor -> Refcursor con la lista de navegación.
   ******************************************************************************************/
   FUNCTION f_get_lst_cfgwizard(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vobjectname    VARCHAR2(500) := 'pac_iax_cfg.f_get_lst_cfgwizard';
      vparam         VARCHAR2(500) := 'parámetros - null';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vcuser         VARCHAR2(50);
      vccfgform      VARCHAR2(50);
   BEGIN
      RETURN pac_md_cfg.f_get_lst_cfgwizard(mensajes);
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN NULL;
   END f_get_lst_cfgwizard;

   /******************************************************************************************
     Autor: CPM (07/11/2008)
     Descripción: Recupera la configuración de la pantalla.
     Parámetros entrada: -
     Parámetros salida:  - mensajes  -> Mensajes de error
     Retorno:            - refcursor -> Refcursor con la lista de pantalla.
   ******************************************************************************************/
   FUNCTION f_get_lst_cfgform(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vobjectname    VARCHAR2(500) := 'pac_iax_cfg.f_get_lst_cfgform';
      vparam         VARCHAR2(500) := 'parámetros - null';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vcuser         VARCHAR2(50);
      vccfgform      VARCHAR2(50);
   BEGIN
      RETURN pac_md_cfg.f_get_lst_cfgform(mensajes);
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN NULL;
   END f_get_lst_cfgform;

   /******************************************************************************************
     Autor: CPM (07/11/2008)
     Descripción: Recupera la configuración de las acciones.
     Parámetros entrada: -
     Parámetros salida:  - mensajes  -> Mensajes de error
     Retorno:            - refcursor -> Refcursor con la lista de acciones.
   ******************************************************************************************/
   FUNCTION f_get_lst_cfgaccion(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vobjectname    VARCHAR2(500) := 'pac_md_iax.f_get_lst_cfgaccion';
      vparam         VARCHAR2(500) := 'parámetros - null';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vcuser         VARCHAR2(50);
      vccfgform      VARCHAR2(50);
   BEGIN
      RETURN pac_md_cfg.f_get_lst_cfgaccion(mensajes);
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN NULL;
   END f_get_lst_cfgaccion;

   /******************************************************************************************
     Autor: CPM (07/11/2008)
     Descripción: Recupera la configuración del menu.
     Parámetros entrada: -
     Parámetros salida:  - mensajes  -> Mensajes de error
     Retorno:            - refcursor -> Refcursor con la lista de configuración del menu.
   ******************************************************************************************/
   FUNCTION f_get_lst_rolmenu(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vobjectname    VARCHAR2(500) := 'pac_iax_cfg.f_get_lst_rolmenu';
      vparam         VARCHAR2(500) := 'parámetros - null';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vcuser         VARCHAR2(50);
      vccfgform      VARCHAR2(50);
   BEGIN
      RETURN pac_md_cfg.f_get_lst_rolmenu(mensajes);
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN NULL;
   END f_get_lst_rolmenu;

   /******************************************************************************************
     Autor: XVILA (04/13/2008)
     Descripció: Retorna la llista dels perfils de suplements
     Paràmetres entrada: -
     Paràmetres sortida: - mensajes -> Missatges d'error
     Return:             refcursor -> Refcursor amb la llista dels perfils de sumplement.
   ******************************************************************************************/
   FUNCTION f_get_lst_codsuplem(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vobjectname    VARCHAR2(500) := 'pac_iax_cfg.f_get_lst_codsuplem';
      vparam         VARCHAR2(500) := 'parámetros - null';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      RETURN pac_md_cfg.f_get_lst_codsuplem(mensajes);
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN NULL;
   END f_get_lst_codsuplem;

    /******************************************************************************************
     Autor: DCT(23/03/2009)
     Descripción: Recupera la configuración de la documentación.
     Parámetros entrada: -
     Parámetros salida:  - mensajes  -> Mensajes de error
     Retorno:            - refcursor -> Refcursor con la lista de documentación.
   ******************************************************************************************/
   FUNCTION f_get_lst_cfgdoc(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vobjectname    VARCHAR2(500) := 'pac_iax_cfg.f_get_lst_cfgdoc';
      vparam         VARCHAR2(500) := 'parámetros - null';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vcuser         VARCHAR2(50);
      vccfgform      VARCHAR2(50);
   BEGIN
      RETURN pac_md_cfg.f_get_lst_cfgdoc(mensajes);
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN NULL;
   END f_get_lst_cfgdoc;

   /******************************************************************************************
     Autor: JTS (01/10/2012)
     Descripción: Recupera los roles existentes
     Parámetros entrada: -
     Parámetros salida:  - mensajes  -> Mensajes de error
     Retorno:            - refcursor -> Refcursor con la lista de roles
   ******************************************************************************************/
   FUNCTION f_get_lst_cfgrol(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vobjectname    VARCHAR2(500) := 'pac_iax_cfg.f_get_lst_cfgrol';
      vparam         VARCHAR2(500) := 'parámetros - null';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vcuser         VARCHAR2(50);
      vccfgform      VARCHAR2(50);
   BEGIN
      RETURN pac_md_cfg.f_get_lst_cfgrol(mensajes);
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN NULL;
   END f_get_lst_cfgrol;

   /******************************************************************************************
     Autor: JTS (01/10/2012)
     Descripción: Recupera las politicas de subscripcion
     Parámetros entrada: -
     Parámetros salida:  - mensajes  -> Mensajes de error
     Retorno:            - refcursor -> Refcursor con la lista de roles
   ******************************************************************************************/
   FUNCTION f_get_lst_usuagru(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vobjectname    VARCHAR2(500) := 'pac_iax_cfg.f_get_lst_usuagru';
      vparam         VARCHAR2(500) := 'parámetros - null';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vcuser         VARCHAR2(50);
      vccfgform      VARCHAR2(50);
   BEGIN
      RETURN pac_md_cfg.f_get_lst_usuagru(mensajes);
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN NULL;
   END f_get_lst_usuagru;

   /************************************************************************************************
           Bug 16064: CRT101 - Boton enviar correo avisando de nueva solicitud #XPL#13/10/2010
           Descripción: Envia mail segons la taula de configuració
           Parámetros entrada: - pcempres --> Empresa
                                 pmodo    --> Mode
                                 ptevento --> Event del qual s'accedeix
                                 psproduc --> Producte
                                 psseguro --> Seguro si existia per pantalla
                                 pnriesgo --> Risc del seguro
                                 pnsinies --> Sinistre
                                 pcmotmov --> Motiu moviment
           Parámetros salida:  - mensajes
           Retorno:            - error -> 1 KO, 0 OK
       ************************************************************************************************/
   FUNCTION f_enviar_notificacion(
      pcempres IN NUMBER,
      pmodo IN VARCHAR2,
      ptevento IN VARCHAR2,
      psproduc IN NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnsinies IN NUMBER,
      pcmotmov IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAX_cfg.f_enviar_notificacion';
      vnumerr        NUMBER;
      vcempres       NUMBER;
   BEGIN
      vcempres := pcempres;

      IF pcempres IS NULL THEN
         vcempres := pac_md_common.f_get_cxtempresa;
      END IF;

      vnumerr := pac_md_cfg.f_enviar_notificacion(vcempres, pmodo, ptevento, psproduc,
                                                  psseguro, pnriesgo, pnsinies, pcmotmov,
                                                  mensajes);
      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, NULL,
                                           SQLCODE, SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_enviar_notificacion;

   /******************************************************************************************
     Descripción: Recupera la lista de informes que se pueden lanzar des de una pantalla
     Param in pcempres :    código de empresa
     Param in pcform :      código de pantalla
     Param in ptevento :    código de evento
     Param in psproduc :    código de producto
     Param out pcurconfigsinf : lista de listados
     Param out mensajes       : Mensajes de error
     Retorno 0 -> Ok
             1 -> Ko

     Bug 15743 - 14/10/2010 - XPL/AMC
   ******************************************************************************************/
   FUNCTION f_get_informes(
      pcempres IN NUMBER,
      pcform IN VARCHAR2,
      ptevento IN VARCHAR2,
      psproduc IN NUMBER,
      pcurconfigsinf OUT sys_refcursor,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'pcempres=' || pcempres || ' pcform:' || pcform || ' ptevento:' || ptevento
            || ' psproduc:' || psproduc;
      vobject        VARCHAR2(200) := 'PAC_iax_cfg.f_get_informes';
      num_err        NUMBER;
   BEGIN
      vpasexec := 2;
      num_err := pac_md_cfg.f_get_informes(pcempres, pcform, ptevento, psproduc,
                                           pcurconfigsinf, mensajes);

      IF num_err <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_get_informes;

   /******************************************************************************************
     Descripción: Ejecuta los listados que se le indican
     Param in pcempres :    código de empresa
     Param in pcform :      código de pantalla
     Param in ptevento :    código de evento
     Param in psproduc :    código de producto
     Param in pcmap :       listado de maps a ejecutar
     Param in pparans :     Listado de parametros de los maps
     Param out vtimp :      lista de listados generados
     Param out mensajes       : Mensajes de error
     Retorno 0 -> Ok
             1 -> Ko

     Bug 15743 - 14/10/2010 - XPL/AMC
   ******************************************************************************************/
   FUNCTION f_ejecutar_informe(
      pcempres IN NUMBER,
      pcform IN VARCHAR2,
      ptevento IN VARCHAR2,
      psproduc IN NUMBER,
      pcmap IN VARCHAR2,
      pparams IN VARCHAR2,
      vtimp OUT t_iax_impresion,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         CLOB
         := 'pcempres=' || pcempres || ' pcform:' || pcform || ' ptevento:' || ptevento
            || ' psproduc:' || psproduc || ' pcmap:' || pcmap;
-- Bug 17179#07/01/2011#XPL, es treu el pparams ja que pot ser molt gran
      vobject        VARCHAR2(200) := 'PAC_iax_cfg.f_ejecutar_informe';
      num_err        NUMBER;
   BEGIN
      vpasexec := 2;
      num_err := pac_md_cfg.f_ejecutar_informe(pcempres, pcform, ptevento, psproduc, pcmap,
                                               pparams, vtimp, mensajes);

      IF num_err <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_ejecutar_informe;

   /******************************************************************************************
     Descripción: Ejecuta los listados que se le indican en modo BATCH
     Param in pcempres :    código de empresa
     Param in pcform :      código de pantalla
     Param in ptevento :    código de evento
     Param in psproduc :    código de producto
     Param in pcmap :       listado de maps a ejecutar
     Param in pparans :     Listado de parametros de los maps
     Param in psproces:     Numero de proces
     Param out vtimp :      lista de listados generados
     Param out mensajes       : Mensajes de error
     Retorno 0 -> Ok
             1 -> Ko

     Bug 27699 - 30/07/2013 - RCL
   ******************************************************************************************/
   FUNCTION f_ejecutar_informe_batch(
      pcempres IN NUMBER,
      pcform IN VARCHAR2,
      ptevento IN VARCHAR2,
      psproduc IN NUMBER,
      pcmap IN VARCHAR2,
      pparams IN VARCHAR2,
      psproces IN NUMBER,
      vtimp OUT t_iax_impresion,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 10;
      vparam         CLOB
         := 'pcempres=' || pcempres || ' pcform:' || pcform || ' ptevento:' || ptevento
            || ' psproduc:' || psproduc || ' pcmap:' || pcmap;
      vobject        VARCHAR2(200) := 'PAC_iax_cfg.f_ejecutar_informe_batch';
      num_err        NUMBER;
   BEGIN
      vpasexec := 20;
      num_err := pac_md_cfg.f_ejecutar_informe_batch(pcempres, pcform, ptevento, psproduc,
                                                     pcmap, pparams, psproces, vtimp,
                                                     mensajes);

      IF num_err <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_ejecutar_informe_batch;

   -- BUG16471:DRA:26/10/2010:Inici
   /******************************************************************************************
     Descripción: Recupera la configuración del acceso de productos
     Parámetros entrada: -
     Parámetros salida:  - mensajes  -> Mensajes de error
     Retorno:            - refcursor -> Refcursor con la lista de pantalla.
   ******************************************************************************************/
   FUNCTION f_get_lst_caccprod(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vobjectname    VARCHAR2(500) := 'pac_iax_cfg.f_get_lst_caccprod';
      vparam         VARCHAR2(500) := 'parámetros - null';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vcuser         VARCHAR2(50);
      vccfgform      VARCHAR2(50);
   BEGIN
      RETURN pac_md_cfg.f_get_lst_caccprod(mensajes);
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN NULL;
   END f_get_lst_caccprod;

-- BUG16471:DRA:26/10/2010:Fi
   FUNCTION f_get_patron_valores_numericos(
      pcform IN VARCHAR2,
      pcmodo IN VARCHAR2,
      psproduc IN NUMBER,
      pcmoneda IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vobjectname    VARCHAR2(500) := 'pac_iax_cfg.f_get_patron_valores_numericos';
      vparam         VARCHAR2(500)
         := 'parámetros - pcform:' || pcform || ' - pmodo: ' || pcmodo || ' - psproduc: '
            || psproduc || ' - cmoneda: ' || pcmoneda;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vcuser         VARCHAR2(50);
      vccfgform      VARCHAR2(50);
      vrefcursor     sys_refcursor;
      vcempres       NUMBER(2);
   BEGIN
      vpasexec := 3;
      vcuser := pac_md_common.f_get_cxtusuario;
      vcempres := pac_md_common.f_get_cxtempresa;

      IF vcuser IS NULL THEN
         RAISE e_object_error;
      END IF;

      vpasexec := 5;
      --Recupero la configuració de pantalla associada a l'usuari en la pantalla sol·licitada
      vccfgform := pac_md_cfg.f_get_user_cfgform(vcuser, vcempres, pcform, mensajes);

      IF vccfgform IS NULL THEN
         RAISE e_object_error;
      END IF;

      vpasexec := 7;
       --Retorn de la configuració de pantalla sol·licitada.
      /* vrefcursor := pac_md_cfg.f_get_patron_valores_numericos(pac_md_common.f_get_cxtempresa,
                                                               pcform, pcmodo, vccfgform,
                                                               psproduc, pcmoneda, mensajes);
       */
      RETURN vrefcursor;
   EXCEPTION
      WHEN e_param_error THEN
         IF vrefcursor%ISOPEN THEN
            CLOSE vrefcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN vrefcursor;
      WHEN e_object_error THEN
         IF vrefcursor%ISOPEN THEN
            CLOSE vrefcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN vrefcursor;
      WHEN OTHERS THEN
         IF vrefcursor%ISOPEN THEN
            CLOSE vrefcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN vrefcursor;
   END f_get_patron_valores_numericos;

   -- BUG 21569 - 07/03/2012 - JMP - Se añade la función
   /******************************************************************************************
     Descripción: Recupera la configuración de informes.
     Parámetros entrada: -
     Parámetros salida:  - mensajes  -> Mensajes de error
     Retorno:            - refcursor -> Refcursor con la lista de documentación.
   ******************************************************************************************/
   FUNCTION f_get_lst_cfgmap(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vobjectname    VARCHAR2(500) := 'pac_md_cfg.f_get_lst_cfgmap';
      vparam         VARCHAR2(500) := 'parámetros - null';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vcuser         VARCHAR2(50);
   BEGIN
      RETURN pac_md_cfg.f_get_lst_cfgmap(mensajes);
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN NULL;
   END f_get_lst_cfgmap;

-- FIN BUG 21569 - 07/03/2012 - JMP - Se añade la función

   /***********************************************************************
      F_NEW ROL Crea un nuevo rol
      return: devuelve 0 si todo bien, sino el código del error
    ***********************************************************************/
   FUNCTION f_new_rol(
      pcrol IN VARCHAR2,
      ptrol IN VARCHAR2,
      pcidioma IN NUMBER,
      pcempres IN NUMBER,
      pcwizard IN VARCHAR2,
      pcform IN VARCHAR2,
      pcaccion IN VARCHAR2,
      pcmenu IN VARCHAR2,
      pcconsupl IN VARCHAR2,
      pcdocumentacio IN VARCHAR2,
      pcaccprod IN VARCHAR2,
      pcmap IN VARCHAR2,
      pcusuagru IN VARCHAR2,
      pcilimite IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'pac_iax_cfg.f_new_rol';
      vparam         VARCHAR2(500) := 'parámetros - null';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vcuser         VARCHAR2(50);
   BEGIN
      vnumerr := pac_md_cfg.f_new_rol(pcrol, ptrol, pcidioma, pcempres, pcwizard, pcform,
                                      pcaccion, pcmenu, pcconsupl, pcdocumentacio, pcaccprod,
                                      pcmap, pcusuagru, pcilimite, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_new_rol;

   /***********************************************************************
     F_SET_ROL Updatea un rol
     return: devuelve 0 si todo bien, sino el código del error
   ***********************************************************************/
   FUNCTION f_set_rol(
      pcrol IN VARCHAR2,
      ptrol IN VARCHAR2,
      pcidioma IN NUMBER,
      pcempres IN NUMBER,
      pcwizard IN VARCHAR2,
      pcform IN VARCHAR2,
      pcaccion IN VARCHAR2,
      pcmenu IN VARCHAR2,
      pcconsupl IN VARCHAR2,
      pcdocumentacio IN VARCHAR2,
      pcaccprod IN VARCHAR2,
      pcmap IN VARCHAR2,
      pcusuagru IN VARCHAR2,
      pcilimite IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'pac_iax_cfg.f_set_rol';
      vparam         VARCHAR2(500) := 'parámetros - null';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vcuser         VARCHAR2(50);
   BEGIN
      vnumerr := pac_md_cfg.f_set_rol(pcrol, ptrol, pcidioma, pcempres, pcwizard, pcform,
                                      pcaccion, pcmenu, pcconsupl, pcdocumentacio, pcaccprod,
                                      pcmap, pcusuagru, pcilimite, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_set_rol;

    /***********************************************************************
  f_get_roles
  return:
***********************************************************************/
   FUNCTION f_get_roles(pcrol IN VARCHAR2, ptrol IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vobjectname    VARCHAR2(500) := 'pac_iax_cfg.f_get_roles';
      vparam         VARCHAR2(500) := 'parámetros - null';
      vpasexec       NUMBER(5) := 1;
      vcur           sys_refcursor;
   BEGIN
      vcur := pac_md_cfg.f_get_roles(pcrol, ptrol, mensajes);

      IF vcur IS NULL THEN
         RAISE e_object_error;
      END IF;

      RETURN vcur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN NULL;
   END f_get_roles;

   /***********************************************************************
  f_get_rol
  return:
***********************************************************************/
   FUNCTION f_get_rol(
      pcrol IN VARCHAR2,
      pcempres IN NUMBER,
      ptrol OUT VARCHAR2,
      pcwizard OUT VARCHAR2,
      pcform OUT VARCHAR2,
      pcaccion OUT VARCHAR2,
      pcmenu OUT VARCHAR2,
      pcconsupl OUT VARCHAR2,
      pcdocumentacio OUT VARCHAR2,
      pcaccprod OUT VARCHAR2,
      pcmap OUT VARCHAR2,
      pcusuagru OUT VARCHAR2,
      pcilimite OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'pac_iax_cfg.f_get_rol';
      vparam         VARCHAR2(500) := 'parámetros - null';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_md_cfg.f_get_rol(pcrol, pcempres, ptrol, pcwizard, pcform, pcaccion,
                                      pcmenu, pcconsupl, pcdocumentacio, pcaccprod, pcmap,
                                      pcusuagru, pcilimite, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_get_rol;
END pac_iax_cfg;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_CFG" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_CFG" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_CFG" TO "PROGRAMADORESCSI";
