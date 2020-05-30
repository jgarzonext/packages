--------------------------------------------------------
--  DDL for Package Body PAC_IAX_MNTCAMPANYAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IAX_MNTCAMPANYAS" IS
/******************************************************************************
    NOMBRE:      PAC_MD_MNTCAMPANYAS
    PROPÓSITO:   Funciones para la gestión de campañas

    REVISIONES:
    Ver        Fecha        Autor             Descripción
    ---------  ----------  ---------  ------------------------------------
    1.0        08/05/2013   AMC       1. Creación del package. Bug 26615/143210
******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

    /**********************************************************************************************
      Función para recuperar campañas
      param in pccampanya:    codigo campaña
      param in ptcampanya:    descripción de campaña
      param out campanyas:     t_iax_ campanyas,
      param out mensajes:        mensajes informativos


      Bug 26615/143210 - 08/05/2013 - AMC
   ************************************************************************************************/
   FUNCTION f_get_campanyas(
      pccampanya IN NUMBER,   -- codigo campaña
      ptcampanya IN VARCHAR2,   -- Deripción de la campaña
      pcampanyas OUT t_iax_campanyas,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1000)
                                := 'pccampanya:' || pccampanya || ' ptcampanya:' || ptcampanya;
      vobject        VARCHAR2(200) := 'pac_iax_mntcampanyas.f_get_campanyas';
      vnumerr        NUMBER;
   BEGIN
      vnumerr := pac_md_mntcampanyas.f_get_campanyas(pccampanya, ptcampanya, pcampanyas,
                                                     mensajes);

      IF vnumerr <> 0 THEN
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
   END f_get_campanyas;

    /**********************************************************************************************
      Función para recuperar una campanya
      param in pccampanya:    codigo campaña
      param in ptodo:         Recupera todos los idiomas o solo los informados
      param out campanyas:     t_iax_ campanyas,
      param out mensajes:        mensajes informativos


      Bug 26615/143210 - 08/05/2013 - AMC
   ************************************************************************************************/
   FUNCTION f_get_campanya(
      pccampanya IN NUMBER,   -- codigo campaña
      ptodo IN NUMBER,
      pcampanya OUT t_iax_campanyas,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1000) := 'pccampanya:' || pccampanya;
      vobject        VARCHAR2(200) := 'pac_iax_mntcampanyas.f_get_campanya';
      vnumerr        NUMBER;
   BEGIN
      vnumerr := pac_md_mntcampanyas.f_get_campanya(pccampanya, ptodo, pcampanya, mensajes);

      IF vnumerr <> 0 THEN
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
   END f_get_campanya;

    /**********************************************************************************************
      Función para recuperar campañas
      param in pccampanya:    codigo campaña
      param in ptcampanya:    descripción de campaña
      param in pcidioma: código de idioma
      param out mensajes:        mensajes informativos


      Bug 26615/143210 - 08/05/2013 - AMC
   ************************************************************************************************/
   FUNCTION f_set_campanyas(
      pccampanya IN NUMBER,   -- codigo campaña
      ptcampanya IN VARCHAR2,   -- Deripción de la campaña
      pcidioma IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vobject        VARCHAR2(500) := 'pac_iax_mntcampanyas.f_set_campanya';
      vparam         VARCHAR2(550)
         := 'parámetros - pccampanya:' || pccampanya || ' ptcampanya:' || ptcampanya
            || ' pcidioma:' || pcidioma;
      vnumerr        NUMBER;
   BEGIN
      IF pccampanya IS NULL
         OR pcidioma IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_mntcampanyas.f_set_campanyas(pccampanya, ptcampanya, pcidioma,
                                                     mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

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
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_set_campanyas;

    /*************************************************************************
      Comprueba si existe la campanya
      param in pccampanya  : codigo de la campanya
      param out mensajes      : mesajes de error

      return : codigo de error
   *************************************************************************/
   FUNCTION f_act_ccampanya(pccampanya IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'pac_iax_mntcampanyas.f_act_ccampanya';
      vparam         VARCHAR2(500) := 'parámetros - pccampanya:' || pccampanya;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vcampanya      t_iax_campanyas;
   BEGIN
      IF pccampanya IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF pccampanya > 9999 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9001891);
         RAISE e_param_error;
      END IF;

      vnumerr := f_get_campanya(pccampanya, 0, vcampanya, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      IF vcampanya IS NOT NULL
         AND vcampanya.COUNT > 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9901365);
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam,
                                           vnumerr);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_act_ccampanya;

/**********************************************************************************************
      Función para borrar campanyas
      param in pccampanya:   codigo campaña
      param out mensajes:    mensajes informativos

      Bug 26615/143210 - 08/05/2013 - AMC
   ************************************************************************************************/
   FUNCTION f_del_campanya(pccampanya IN NUMBER,   -- codigo campaña
                                                mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vobject        VARCHAR2(500) := 'pac_iax_mntcampanyas.f_del_campanya';
      vparam         VARCHAR2(550) := 'parámetros - pccampanya:' || pccampanya;
      vnumerr        NUMBER;
   BEGIN
      IF pccampanya IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_mntcampanyas.f_del_campanya(pccampanya, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

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
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_del_campanya;

    /**********************************************************************************************
      Función para borrar una descriccion de la campanya
      param in pccampanya:   codigo campaña
      param in pcidioma: código de idioma
      param out mensajes:    mensajes informativos

      Bug 26615/143210 - 08/05/2013 - AMC
   ************************************************************************************************/
   FUNCTION f_del_campanya_lin(
      pccampanya IN NUMBER,   -- codigo campaña
      pcidioma IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vobject        VARCHAR2(500) := 'pac_iax_mntcampanyas.f_del_campanya_lin';
      vparam         VARCHAR2(550)
                       := 'parámetros - pccampanya:' || pccampanya || ' pcidioma:' || pcidioma;
      vnumerr        NUMBER;
   BEGIN
      IF pccampanya IS NULL
         OR pcidioma IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_mntcampanyas.f_del_campanya_lin(pccampanya, pcidioma, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

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
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_del_campanya_lin;
END pac_iax_mntcampanyas;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_MNTCAMPANYAS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_MNTCAMPANYAS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_MNTCAMPANYAS" TO "PROGRAMADORESCSI";
