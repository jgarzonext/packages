--------------------------------------------------------
--  DDL for Package PAC_MD_MNTUSER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_MD_MNTUSER" AS
/******************************************************************************
   NOMBRE:       pac_md_mntuser
   PROPÓSITO: Mantenimiento usuarios. gestión

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        30/08/2012   JTS                1. Creación del package.
******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

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
      RETURN NUMBER;

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
      RETURN NUMBER;

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
      RETURN NUMBER;

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
      RETURN NUMBER;

   /**************************************************************************
     Recupera los perfiles
     param in pcempres : Codigo de la empresa
   **************************************************************************/
   FUNCTION f_get_ccfgform(
      pcempres IN NUMBER,
      pcursor OUT sys_refcursor,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

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
      RETURN NUMBER;

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
      RETURN NUMBER;

/**************************************************************************
  Recupera los modos
**************************************************************************/
   FUNCTION f_get_codmodo_n(pcursor OUT sys_refcursor, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

/**************************************************************************
  Recupera los formularios
**************************************************************************/
   FUNCTION f_get_codform_n(pcursor OUT sys_refcursor, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /**************************************************************************
     Recupera los productos
     param in pcempres : Codigo de la empresa
     param in pcmodo   : Modo
   **************************************************************************/
   FUNCTION f_get_productos(
      pcempres IN NUMBER,
      pcursor OUT sys_refcursor,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

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
      RETURN NUMBER;
END pac_md_mntuser;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_MNTUSER" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_MNTUSER" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_MNTUSER" TO "PROGRAMADORESCSI";
