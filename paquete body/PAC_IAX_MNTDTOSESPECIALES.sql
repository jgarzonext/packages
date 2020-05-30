--------------------------------------------------------
--  DDL for Package Body PAC_IAX_MNTDTOSESPECIALES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IAX_MNTDTOSESPECIALES" AS
/******************************************************************************
    NOMBRE:      PAC_IAX_MNTDTOSESPECIALES
    PROPÓSITO:   Funciones para la gestión de descuentos especiales

    REVISIONES:
    Ver        Fecha        Autor             Descripción
    ---------  ----------  ---------  ------------------------------------
    1.0        16/05/2013   AMC       1. Creación del package. Bug 26615/143210
******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   /**********************************************************************************************
      Función para recuperar campañas
      param out mensajes:        mensajes informativos

      Bug 26615/143210 - 16/05/2013 - AMC
   ************************************************************************************************/
   FUNCTION f_get_campanyas(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1000);
      vobject        VARCHAR2(200) := 'pac_iax_mntdtosespeciales.f_get_campanyas';
      vnumerr        NUMBER;
      vselect        VARCHAR2(1000);
      cur            sys_refcursor;
   BEGIN
      cur := pac_md_mntdtosespeciales.f_get_campanyas(mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN NULL;
   END f_get_campanyas;

      /**********************************************************************************************
      Función para recuperar campañas
       param in pccampanya:    campaña
       param in pfecini:   fecha inicio campaña
       param in pcfecfin:    fecha fin campaña
       param out dtosespe:    t_iax_dtosespeciales
       param out mensajes:    mensajes informativos


      Bug 26615/143210 - 16/05/2013 - AMC
   ************************************************************************************************/
   FUNCTION f_get_dtosespeciales(
      pccampanya IN NUMBER,
      pfecini IN DATE,
      pfecfin IN DATE,
      pdtosespe OUT t_iax_dtosespeciales,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1000)
            := 'pccampanya:' || pccampanya || ' pfecini:' || pfecini || ' pfecfin:' || pfecfin;
      vobject        VARCHAR2(200) := 'pac_iax_mntdtosespeciales.f_get_dtosespeciales';
      vnumerr        NUMBER;
   BEGIN
      vnumerr := pac_md_mntdtosespeciales.f_get_dtosespeciales(pccampanya, pfecini, pfecfin,
                                                               pdtosespe, mensajes);

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
   END f_get_dtosespeciales;

   /**********************************************************************************************
      Función para insertar un descuento
      param in pccampanya:

      Bug 26615/143210 - 22/05/2013 - AMC
   ************************************************************************************************/
   FUNCTION f_set_dtosespeciales(
      pccampanya IN NUMBER,
      pfecini IN DATE,
      pfecfin IN DATE,
      pmodo IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(500) := 'pac_iax_mntdtosespeciales.f_set_dtosespeciales';
      vparam         VARCHAR2(550)
         := 'parámetros - pccampanya:' || pccampanya || ' pfecini:' || pfecini || ' pfecfin:'
            || pfecfin;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER;
   BEGIN
      IF pccampanya IS NULL THEN
         RAISE e_param_error;
      END IF;

      p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, pmodo);
      vnumerr := pac_md_mntdtosespeciales.f_set_dtosespeciales(pccampanya, pfecini, pfecfin,
                                                               pmodo, mensajes);

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
   END f_set_dtosespeciales;

   /**********************************************************************************************
      Función para insertar el detalle de un descuento
      param in pccampanya:

      Bug 26615/143210 - 22/05/2013 - AMC
   ************************************************************************************************/
   FUNCTION f_set_dtosespeciales_lin(
      pccampanya IN NUMBER,
      psproduc IN NUMBER,
      pcpais IN NUMBER,
      pcdpto IN NUMBER,
      pcciudad IN NUMBER,
      pcagrupa IN VARCHAR2,
      pcsucursal IN NUMBER,
      pcintermed IN NUMBER,
      ppdto IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(500) := 'pac_iax_mntdtosespeciales.f_set_dtosespeciales';
      vparam         VARCHAR2(550)
         := 'parámetros - pccampanya:' || pccampanya || ' psproduc:' || psproduc || ' pcdpto:'
            || pcdpto || ' pcciudad:' || pcciudad || ' pcagrupa:' || pcagrupa
            || ' pcsucursal:' || pcsucursal || ' pcintermed:' || pcintermed || ' ppdto:'
            || ppdto;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER;
   BEGIN
      IF pccampanya IS NULL
         OR psproduc IS NULL
         OR pcdpto IS NULL
         OR pcciudad IS NULL
         OR pcagrupa IS NULL
         OR pcsucursal IS NULL
         OR pcintermed IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_mntdtosespeciales.f_set_dtosespeciales_lin(pccampanya, psproduc,
                                                                   pcpais, pcdpto, pcciudad,
                                                                   pcagrupa, pcsucursal,
                                                                   pcintermed, ppdto, mensajes);

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
   END f_set_dtosespeciales_lin;

    /**********************************************************************************************
      Función para recuperar campañas
       param in pccampanya:   campaña
       param out dtosespe: ob_iax_dtosespeciales
       param out mensajes: mensajes informativos


      Bug 26615/143210 - 16/05/2013 - AMC
   ************************************************************************************************/
   FUNCTION f_get_dtosespecial(
      pccampanya IN NUMBER,
      pdtosespe OUT ob_iax_dtosespeciales,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1000) := 'pccampanya:' || pccampanya;
      vobject        VARCHAR2(200) := 'pac_iax_mntdtosespecial.f_get_dtosespecial';
      vnumerr        NUMBER;
   BEGIN
      IF pccampanya IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_mntdtosespeciales.f_get_dtosespecial(pccampanya, pdtosespe, mensajes);

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
   END f_get_dtosespecial;

    /**********************************************************************************************
      Función para borrar un descuento
      param in pccampanya:

      Bug 26615/143210 - 22/05/2013 - AMC
   ************************************************************************************************/
   FUNCTION f_del_dtosespeciales(pccampanya IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(500) := 'pac_iax_mntdtosespeciales.f_del_dtosespeciales';
      vparam         VARCHAR2(550) := 'parámetros - pccampanya:' || pccampanya;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER;
   BEGIN
      IF pccampanya IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_mntdtosespeciales.f_del_dtosespeciales(pccampanya, mensajes);

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
   END f_del_dtosespeciales;

   /**********************************************************************************************
      Función para borrar el detalle de un descuento
      param in pccampanya:

      Bug 26615/143210 - 22/05/2013 - AMC
   ************************************************************************************************/
   FUNCTION f_del_dtosespeciales_lin(
      pccampanya IN NUMBER,
      psproduc IN NUMBER,
      pcpais IN NUMBER,
      pcdpto IN NUMBER,
      pcciudad IN NUMBER,
      pcagrupa IN VARCHAR2,
      pcsucursal IN NUMBER,
      pcintermed IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(500) := 'pac_md_mntdtosespeciales.f_del_dtosespeciales';
      vparam         VARCHAR2(550)
         := 'parámetros - pccampanya:' || pccampanya || ' psproduc:' || psproduc || ' pcpais:'
            || pcpais || ' pcdpto:' || pcdpto || ' pcciudad:' || pcciudad || ' pcagrupa:'
            || pcagrupa || ' pcsucursal:' || pcsucursal || ' pcintermed:' || pcintermed;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER;
   BEGIN
      IF pccampanya IS NULL
         OR psproduc IS NULL
         OR pcdpto IS NULL
         OR pcpais IS NULL
         OR pcciudad IS NULL
         OR pcagrupa IS NULL
         OR pcsucursal IS NULL
         OR pcintermed IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_mntdtosespeciales.f_del_dtosespeciales_lin(pccampanya, psproduc,
                                                                   pcpais, pcdpto, pcciudad,
                                                                   pcagrupa, pcsucursal,
                                                                   pcintermed, mensajes);

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
   END f_del_dtosespeciales_lin;

    /**********************************************************************************************
      Función para recuperar las agrupaciones tipo
      param OUT mensajes
      return cursor con los valores

      Bug 26615/143210 - 23/05/2013 - AMC
   ************************************************************************************************/
   FUNCTION f_get_cagrtipo(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'pac_iax_mntdtosespeciales.f_get_cagrtipo';
      terror         VARCHAR2(200) := 'Error recuperar las agrupaciones tipo';
   BEGIN
      cur := pac_md_mntdtosespeciales.f_get_cagrtipo(mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_cagrtipo;
END pac_iax_mntdtosespeciales;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_MNTDTOSESPECIALES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_MNTDTOSESPECIALES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_MNTDTOSESPECIALES" TO "PROGRAMADORESCSI";
