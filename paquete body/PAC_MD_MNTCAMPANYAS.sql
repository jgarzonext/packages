--------------------------------------------------------
--  DDL for Package Body PAC_MD_MNTCAMPANYAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MD_MNTCAMPANYAS" IS
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
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1000)
                                := 'pccampanya:' || pccampanya || ' ptcampanya:' || ptcampanya;
      vobject        VARCHAR2(200) := 'pac_md_mntcampanyas.f_get_campanyas';
      vnumerr        NUMBER;
      vselect        VARCHAR2(1000);
      campanya       ob_iax_campanyas := ob_iax_campanyas();
      cur            sys_refcursor;
   BEGIN
      vselect := pac_mntcampanyas.f_get_campanyas(pccampanya, ptcampanya,
                                                  pac_md_common.f_get_cxtidioma);

      IF vselect IS NULL THEN
         RAISE e_object_error;
      END IF;

      vpasexec := 2;
      cur := pac_md_listvalores.f_opencursor(vselect, mensajes);
      vpasexec := 3;
      pcampanyas := t_iax_campanyas();
      campanya := ob_iax_campanyas();
      vpasexec := 4;

      LOOP
         FETCH cur
          INTO campanya.ccampanya, campanya.tcampanya, campanya.cidioma;

         EXIT WHEN cur%NOTFOUND;
         pcampanyas.EXTEND;
         pcampanyas(pcampanyas.LAST) := campanya;
         campanya := ob_iax_campanyas();
      END LOOP;

      vpasexec := 5;
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
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1000) := 'pccampanya:' || pccampanya;
      vobject        VARCHAR2(200) := 'pac_md_mntcampanyas.f_get_campanya';
      vnumerr        NUMBER;
      vselect        VARCHAR2(1000);
      campanya       ob_iax_campanyas := ob_iax_campanyas();
      cur            sys_refcursor;
   BEGIN
      vselect := pac_mntcampanyas.f_get_campanya(pccampanya, ptodo);

      IF vselect IS NULL THEN
         RAISE e_object_error;
      END IF;

      vpasexec := 2;
      cur := pac_md_listvalores.f_opencursor(vselect, mensajes);
      vpasexec := 3;
      pcampanya := t_iax_campanyas();
      campanya := ob_iax_campanyas();
      vpasexec := 4;

      LOOP
         FETCH cur
          INTO campanya.ccampanya, campanya.tcampanya, campanya.cidioma, campanya.tidioma;

         EXIT WHEN cur%NOTFOUND;
         pcampanya.EXTEND;
         pcampanya(pcampanya.LAST) := campanya;
         campanya := ob_iax_campanyas();
      END LOOP;

      vpasexec := 5;
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
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vobject        VARCHAR2(500) := 'pac_md_mntcampanyas.f_set_campanya';
      vparam         VARCHAR2(550)
         := 'parámetros - pccampanya:' || pccampanya || ' ptcampanya:' || ptcampanya
            || ' pcidioma:' || pcidioma;
      vnumerr        NUMBER;
   BEGIN
      IF pccampanya IS NULL
         OR pcidioma IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_mntcampanyas.f_set_campanya(pccampanya, ptcampanya, pcidioma);

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
   END f_set_campanyas;

    /**********************************************************************************************
      Función para borrar campanyas
      param in pccampanya:   codigo campaña
      param out mensajes:    mensajes informativos

      Bug 26615/143210 - 08/05/2013 - AMC
   ************************************************************************************************/
   FUNCTION f_del_campanya(
      pccampanya IN NUMBER,   -- codigo campaña
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vobject        VARCHAR2(500) := 'pac_md_mntcampanyas.f_del_campanya';
      vparam         VARCHAR2(550) := 'parámetros - pccampanya:' || pccampanya;
      vnumerr        NUMBER;
   BEGIN
      IF pccampanya IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_mntcampanyas.f_del_campanya(pccampanya);

      IF vnumerr = 1 THEN
         RAISE e_object_error;
      END IF;

      IF vnumerr > 1 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
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
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vobject        VARCHAR2(500) := 'pac_md_mntcampanyas.f_del_campanya_lin';
      vparam         VARCHAR2(550)
                       := 'parámetros - pccampanya:' || pccampanya || ' pcidioma:' || pcidioma;
      vnumerr        NUMBER;
   BEGIN
      IF pccampanya IS NULL
         OR pcidioma IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_mntcampanyas.f_del_campanya_lin(pccampanya, pcidioma);

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
   END f_del_campanya_lin;
END pac_md_mntcampanyas;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_MNTCAMPANYAS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_MNTCAMPANYAS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_MNTCAMPANYAS" TO "PROGRAMADORESCSI";
