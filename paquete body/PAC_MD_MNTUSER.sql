--------------------------------------------------------
--  DDL for Package Body PAC_MD_MNTUSER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MD_MNTUSER" AS
/******************************************************************************
   NOMBRE:       pac_md_mntuser
   PROPÓSITO: Mantenimiento usuarios. gestión

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        30/08/2012   JTS                1. Creación del package.
******************************************************************************/

   /**************************************************************************
     Inserta un nuevo registro en la tabla cfg_form. Si existe, lo actualiza
     param in pcempres : Codigo de la empresa
     param in pcform   : Nombre de la pantalla
     param in pcmodo   : Modo
     param in pccfgform: Perfil
     param in psproduc : Producto
     param in pcidcfg  : ID de la cfg
   **************************************************************************/
   FUNCTION f_set_cfgform(
      pcempres IN NUMBER,
      pcform IN VARCHAR2,
      pcmodo IN VARCHAR2,
      pccfgform IN VARCHAR2,
      psproduc IN NUMBER,
      pcidcfg IN NUMBER,
      ocidcfg OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
         := 'parámetros - pcempres:' || pcempres || ' pcform=' || pcform || ' pcmodo='
            || pcmodo || ' pccfgform=' || pccfgform || ' psproduc=' || psproduc || ' pcidcfg='
            || pcidcfg;
      vobject        VARCHAR2(200) := 'PAC_MD_mntuser.f_set_cfgform';
   BEGIN
      IF pcidcfg IS NULL THEN
         vnumerr := pac_mntuser.f_get_cidcfg(pcempres, pcform, pcmodo, pccfgform, psproduc,
                                             ocidcfg);

         IF vnumerr <> 0 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
            RAISE e_object_error;
         END IF;

         RETURN 0;
      ELSE
         ocidcfg := pcidcfg;
      END IF;

      vnumerr := pac_mntuser.f_set_cfgform(pcempres, pcform, pcmodo, pccfgform, psproduc,
                                           ocidcfg);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
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
   END f_set_cfgform;

   /**************************************************************************
     Inserta un nuevo registro en la tabla cfg_form_property. Si existe, lo actualiza
     param in pcempres : Codigo de la empresa
     param in pcidcfg  : ID de la cfg
     param in pcform   : Nombre de la pantalla
     param in pcitem   : Item
     param in pcprpty  : Codigo de la propiedad
     param in pcvalue  : Valor de la propiedad
   **************************************************************************/
   FUNCTION f_set_cfgformproperty(
      pcempres IN NUMBER,
      pcidcfg IN NUMBER,
      pcform IN VARCHAR2,
      pcitem IN VARCHAR2,
      pcprpty IN NUMBER,
      pcvalue IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(1) := 1;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
         := 'parámetros - pcempres:' || pcempres || ' pcidcfg=' || pcidcfg || ' pcform='
            || pcform || ' pcitem=' || pcitem || ' pcprpty=' || pcprpty || ' pcvalue='
            || pcvalue;
      vobject        VARCHAR2(200) := 'PAC_MD_mntuser.f_set_cfgformproperty';
   BEGIN
      vnumerr := pac_mntuser.f_set_cfgformproperty(pcempres, pcidcfg, pcform, pcitem, pcprpty,
                                                   pcvalue);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
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
   END f_set_cfgformproperty;

   /**************************************************************************
     Borra un registro en la tabla cfg_form_property.
     param in pcempres : Codigo de la empresa
     param in pcidcfg  : ID de la cfg
     param in pcform   : Nombre de la pantalla
     param in pcitem   : Item
     param in pcprpty  : Codigo de la propiedad
   **************************************************************************/
   FUNCTION f_del_cfgformproperty(
      pcempres IN NUMBER,
      pcidcfg IN NUMBER,
      pcform IN VARCHAR2,
      pcitem IN VARCHAR2,
      pcprpty IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(1) := 1;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
         := 'parámetros - pcempres:' || pcempres || ' pcidcfg=' || pcidcfg || ' pcform='
            || pcform || ' pcitem=' || pcitem || ' pcprpty=' || pcprpty;
      vobject        VARCHAR2(200) := 'PAC_MD_mntuser.f_del_cfgformproperty';
   BEGIN
      vnumerr := pac_mntuser.f_del_cfgformproperty(pcempres, pcidcfg, pcform, pcitem, pcprpty);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
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
   END f_del_cfgformproperty;

   /**************************************************************************
     Recupera los registros de configuracion de cfg_form_property
     param in pcempres : Codigo de la empresa
     param in pcform   : Nombre de la pantalla
     param in pcmodo   : Modo
     param in pccfgform: Perfil
     param in psproduc : Producto
   **************************************************************************/
   FUNCTION f_get_cfgformproperty(
      pcempres IN NUMBER,
      pcform IN VARCHAR2,
      pcmodo IN VARCHAR2,
      pccfgform IN VARCHAR2,
      psproduc IN NUMBER,
      pcidcfg OUT NUMBER,
      pcursor OUT sys_refcursor,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vret           VARCHAR2(4000);
      vnumerr        NUMBER := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
         := 'parámetros - pcempres:' || pcempres || ' pcform=' || pcform || ' pcmodo='
            || pcmodo || ' pccfgform=' || pccfgform || ' psproduc=' || psproduc;
      vobject        VARCHAR2(200) := 'PAC_MD_mntuser.f_get_cfgformproperty';
   BEGIN
      vret := pac_mntuser.f_get_cfgformproperty(pcempres, pcform, pcmodo, pccfgform, psproduc);

      IF vret IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9904148);
         RAISE e_object_error;
      END IF;

      pcursor := pac_md_listvalores.f_opencursor(vret, mensajes);

      BEGIN
         SELECT cidcfg
           INTO pcidcfg
           FROM cfg_form
          WHERE cempres = pcempres
            AND cform = pcform
            AND cmodo = pcmodo
            AND ccfgform = pccfgform
            AND sproduc = psproduc;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            NULL;
      END;

      RETURN vnumerr;
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
   END f_get_cfgformproperty;

   /**************************************************************************
     Recupera los perfiles
     param in pcempres : Codigo de la empresa
   **************************************************************************/
   FUNCTION f_get_ccfgform(
      pcempres IN NUMBER,
      pcursor OUT sys_refcursor,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vret           VARCHAR2(4000);
      vnumerr        NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'parámetros - pcempres:' || pcempres;
      vobject        VARCHAR2(200) := 'PAC_MD_mntuser.f_get_ccfgform';
   BEGIN
      vret := pac_mntuser.f_get_ccfgform(pcempres);

      IF vret IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9904148);
         RAISE e_object_error;
      END IF;

      pcursor := pac_md_listvalores.f_opencursor(vret, mensajes);
      RETURN vnumerr;
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
   END f_get_ccfgform;

   /**************************************************************************
     Recupera los modos
     param in pcempres : Codigo de la empresa
     param in psproduc : Producto
   **************************************************************************/
   FUNCTION f_get_codmodo(
      pcempres IN NUMBER,
      psproduc IN NUMBER,
      pcursor OUT sys_refcursor,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vret           VARCHAR2(4000);
      vnumerr        NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
                           := 'parámetros - pcempres:' || pcempres || ' psproduc=' || psproduc;
      vobject        VARCHAR2(200) := 'PAC_MD_mntuser.f_get_codmodo';
   BEGIN
      vret := pac_mntuser.f_get_codmodo(pcempres, psproduc);

      IF vret IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9904148);
         RAISE e_object_error;
      END IF;

      pcursor := pac_md_listvalores.f_opencursor(vret, mensajes);
      RETURN vnumerr;
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
   END f_get_codmodo;

   /**************************************************************************
     Recupera los formularios
     param in pcempres : Codigo de la empresa
     param in psproduc : Producto
     param in pcmodo   : Modo
   **************************************************************************/
   FUNCTION f_get_codform(
      pcempres IN NUMBER,
      psproduc IN NUMBER,
      pcmodo IN VARCHAR2,
      pcursor OUT sys_refcursor,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vret           VARCHAR2(4000);
      vnumerr        NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
         := 'parámetros - pcempres:' || pcempres || ' psproduc=' || psproduc || ' pcmodo='
            || pcmodo;
      vobject        VARCHAR2(200) := 'PAC_MD_mntuser.f_get_codform';
   BEGIN
      vret := pac_mntuser.f_get_codform(pcempres, psproduc, pcmodo);

      IF vret IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9904148);
         RAISE e_object_error;
      END IF;

      pcursor := pac_md_listvalores.f_opencursor(vret, mensajes);
      RETURN vnumerr;
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
   END f_get_codform;

/**************************************************************************
  Recupera los modos
**************************************************************************/
   FUNCTION f_get_codmodo_n(pcursor OUT sys_refcursor, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vret           VARCHAR2(4000);
      vnumerr        NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000);
      vobject        VARCHAR2(200) := 'PAC_MD_mntuser.f_get_codmodo_n';
   BEGIN
      vret := pac_mntuser.f_get_codmodo_n;

      IF vret IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9904148);
         RAISE e_object_error;
      END IF;

      pcursor := pac_md_listvalores.f_opencursor(vret, mensajes);
      RETURN vnumerr;
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
   END f_get_codmodo_n;

/**************************************************************************
  Recupera los formularios
**************************************************************************/
   FUNCTION f_get_codform_n(pcursor OUT sys_refcursor, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vret           VARCHAR2(4000);
      vnumerr        NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000);
      vobject        VARCHAR2(200) := 'PAC_MD_mntuser.f_get_codform_n';
   BEGIN
      vret := pac_mntuser.f_get_codform_n;

      IF vret IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9904148);
         RAISE e_object_error;
      END IF;

      pcursor := pac_md_listvalores.f_opencursor(vret, mensajes);
      RETURN vnumerr;
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
   END f_get_codform_n;

   /**************************************************************************
     Recupera los productos
     param in pcempres : Codigo de la empresa
     param in pcmodo   : Modo
   **************************************************************************/
   FUNCTION f_get_productos(
      pcempres IN NUMBER,
      pcursor OUT sys_refcursor,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vret           VARCHAR2(4000);
      vnumerr        NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'parámetros - pcempres:' || pcempres;
      vobject        VARCHAR2(200) := 'PAC_MD_mntuser.f_get_productos';
   BEGIN
      vret := pac_mntuser.f_get_productos(pcempres);

      IF vret IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9904148);
         RAISE e_object_error;
      END IF;

      pcursor := pac_md_listvalores.f_opencursor(vret, mensajes);
      RETURN vnumerr;
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
   END f_get_productos;

   /**************************************************************************
     Recupera la cebecera de la CFG
     param in pcidcfg : Codigo de la configuracion
   **************************************************************************/
   FUNCTION f_get_cabcfgform(
      pcidcfg IN NUMBER,
      pcempres IN NUMBER,
      pcform IN VARCHAR2,
      pcmodo IN VARCHAR2,
      pccfgform IN VARCHAR2,
      psproduc IN NUMBER,
      pcursor OUT sys_refcursor,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vret           VARCHAR2(4000);
      vnumerr        NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'parámetros - pcidcfg:' || pcidcfg;
      vobject        VARCHAR2(200) := 'PAC_MD_mntuser.f_get_cabcfgform';
   BEGIN
      vret := pac_mntuser.f_get_cabcfgform(pcidcfg, pcempres, pcform, pcmodo, pccfgform,
                                           psproduc);

      IF vret IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9904148);
         RAISE e_object_error;
      END IF;

      pcursor := pac_md_listvalores.f_opencursor(vret, mensajes);
      RETURN vnumerr;
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
   END f_get_cabcfgform;
END pac_md_mntuser;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_MNTUSER" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_MNTUSER" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_MNTUSER" TO "PROGRAMADORESCSI";
