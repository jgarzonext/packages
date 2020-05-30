--------------------------------------------------------
--  DDL for Package Body PAC_IAX_AUTOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IAX_AUTOS" AS
/******************************************************************************
   NOMBRE:       pac_iax_autos
   PROPÓSITO:  Funciones para realizar una conexión
               a base de datos de la capa de negocio

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        02/03/2009   XVM               1. Creación del package.
******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   --pmode          VARCHAR2(20);

   -- Bug 9247 - APD - 12/03/2009 -- Se crea la funcion f_desversion
   /*************************************************************************
      FUNCTION f_desversion
         Funcion que busca la descripcion de la version de un vehiculo
         param in pcversion : Codi de la versió
         return             : descripcion de la version
   *************************************************************************/
   FUNCTION f_desversion(pcversion IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN VARCHAR2 IS
      vnumerr        NUMBER := 0;
      vparam         VARCHAR2(500) := ' --';
      vpasexec       NUMBER(5) := 1;
      vobject        VARCHAR2(500) := 'pac_iax_autos.f_desversion';
   BEGIN
      vnumerr := pac_md_autos.f_desversion(pcversion, mensajes);
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
   END f_desversion;

-- Bug 9247 - APD - 12/03/2009 -- Se crea la funcion f_desversion

   -- Bug 9247 - APD - 12/03/2009 -- Se crea la funcion f_desmodelo
   /*************************************************************************
      FUNCTION f_desmodelo
         Funcion que busca la descripcion del modelo de un vehiculo
         param in pcmodelo : Codigo del modelo
         param in pcmarca : Codigo de la marca
         return            : descripcion del modelo
   *************************************************************************/
   FUNCTION f_desmodelo(pcmodelo IN VARCHAR2, pcmarca IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN VARCHAR2 IS
      vnumerr        NUMBER := 0;
      vparam         VARCHAR2(500) := ' --';
      vpasexec       NUMBER(5) := 1;
      vobject        VARCHAR2(500) := 'pac_iax_autos.f_desmodelo';
   BEGIN
      vnumerr := pac_md_autos.f_desmodelo(pcmodelo, pcmarca, mensajes);
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
   END f_desmodelo;

-- Bug 9247 - APD - 12/03/2009 -- Se crea la funcion f_desmodelo

   -- Bug 9247 - APD - 12/03/2009 -- Se crea la funcion f_desmarca
   /*************************************************************************
      FUNCTION f_desmarca
         Funcion que busca la descripcion de la marca de un vehiculo
         param in pcmarca : Codigo de la marca
         return            : descripcion de la marca
   *************************************************************************/
   FUNCTION f_desmarca(pcmarca IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN VARCHAR2 IS
      vnumerr        NUMBER := 0;
      vparam         VARCHAR2(500) := ' --';
      vpasexec       NUMBER(5) := 1;
      vobject        VARCHAR2(500) := 'pac_iax_autos.f_desmarca';
   BEGIN
      vnumerr := pac_md_autos.f_desmarca(pcmarca, mensajes);
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
   END f_desmarca;

-- Bug 9247 - APD - 12/03/2009 -- Se crea la funcion f_desmarca

   -- Bug 9247 - APD - 12/03/2009 -- Se crea la funcion f_destipveh
   /*************************************************************************
      FUNCTION f_destipveh
         Funcion que busca la descripcion del tipo de un vehiculo
         param in pctipveh : Codigo del tipo de vehiculo
         param in v_idioma : Idioma de la descripcion
         return            : descripcion del tipo
   *************************************************************************/
   FUNCTION f_destipveh(pctipveh IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN VARCHAR2 IS
      vnumerr        NUMBER := 0;
      vparam         VARCHAR2(500) := ' --';
      vpasexec       NUMBER(5) := 1;
      vobject        VARCHAR2(500) := 'pac_iax_autos.f_destipveh';
   BEGIN
      vnumerr := pac_md_autos.f_destipveh(pctipveh, mensajes);
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
   END f_destipveh;

-- Bug 9247 - APD - 12/03/2009 -- Se crea la funcion f_destipveh

   -- Bug 9247 - APD - 12/03/2009 -- Se crea la funcion f_desclaveh
   /*************************************************************************
      FUNCTION f_desclaveh
         Funcion que busca la descripcion de la clase de un vehiculo
         param in pcclaveh : Codigo de la clase de vehiculo
         param in v_idioma : Idioma de la descripcion
         return            : descripcion del tipo
   *************************************************************************/
   FUNCTION f_desclaveh(pcclaveh IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN VARCHAR2 IS
      vnumerr        NUMBER := 0;
      vparam         VARCHAR2(500) := ' --';
      vpasexec       NUMBER(5) := 1;
      vobject        VARCHAR2(500) := 'pac_iax_autos.f_desclaveh';
   BEGIN
      vnumerr := pac_md_autos.f_desclaveh(pcclaveh, mensajes);
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
   END f_desclaveh;

-- Bug 9247 - APD - 12/03/2009 -- Se crea la funcion f_desclaveh

   -- Bug 9247 - APD - 12/03/2009 -- Se crea la funcion f_desuso
   /*************************************************************************
      FUNCTION f_desuso
         Funcion que busca la descripcion del uso de un vehiculo
         param in pcuso : Codigo del uso de vehiculo
         param in v_idioma : Idioma de la descripcion
         return            : descripcion del uso
   *************************************************************************/
   FUNCTION f_desuso(pcuso IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN VARCHAR2 IS
      vnumerr        NUMBER := 0;
      vparam         VARCHAR2(500) := ' --';
      vpasexec       NUMBER(5) := 1;
      vobject        VARCHAR2(500) := 'pac_iax_autos.f_desuso';
   BEGIN
      vnumerr := pac_md_autos.f_desuso(pcuso, mensajes);
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
   END f_desuso;

-- Bug 9247 - APD - 12/03/2009 -- Se crea la funcion f_desuso

   -- Bug 9247 - APD - 12/03/2009 -- Se crea la funcion f_dessubuso
   /*************************************************************************
      FUNCTION f_dessubuso
         Funcion que busca la descripcion del subuso de un vehiculo
         param in pcuso : Codigo del subuso de vehiculo
         param in v_idioma : Idioma de la descripcion
         return            : descripcion del subuso
   *************************************************************************/
   FUNCTION f_dessubuso(pcsubuso IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN VARCHAR2 IS
      vnumerr        NUMBER := 0;
      vparam         VARCHAR2(500) := ' --';
      vpasexec       NUMBER(5) := 1;
      vobject        VARCHAR2(500) := 'pac_iax_autos.f_dessubuso';
   BEGIN
      vnumerr := pac_md_autos.f_dessubuso(pcsubuso, mensajes);
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
   END f_dessubuso;
-- Bug 9247 - APD - 12/03/2009 -- Se crea la funcion f_dessubuso
END pac_iax_autos;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_AUTOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_AUTOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_AUTOS" TO "PROGRAMADORESCSI";
