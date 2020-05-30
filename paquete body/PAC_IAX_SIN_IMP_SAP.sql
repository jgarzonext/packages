CREATE OR REPLACE PACKAGE BODY pac_iax_sin_imp_sap AS
/******************************************************************************
   NOMBRE:    pac_iax_sin_imp_sap
   PROPÓSITO: Funciones para calculo de impuestos

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
    1.0       13/08/2013   NSS             Creacion
	2.0       17/01/2019   WAJ             Insert a la tabla per_indicadores para guardar los indicadores por personas
*/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   FUNCTION f_get_lstimpuestos(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vobject        VARCHAR2(500) := 'pac_iax_sin_imp_sap.f_get_lstimpuestos';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vparam         VARCHAR2(500) := ' ';
   BEGIN
      cur := pac_md_sin_imp_sap.f_get_lstimpuestos(mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstimpuestos;

   FUNCTION f_get_tipos_indicador(pccodimp IN NUMBER, pcarea IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vobject        VARCHAR2(500) := 'pac_iax_sin_imp_sap.f_get_tipos_indicador';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vparam         VARCHAR2(500) := 'parámetros - pccodimp=' || pccodimp;
   BEGIN
      cur := pac_md_sin_imp_sap.f_get_tipos_indicador(pccodimp, pcarea, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_tipos_indicador;
   --IAXIS 7655 AABC Conceptos de indicador pagos de tiquetes aereos
   FUNCTION f_get_concep_pago(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vobject        VARCHAR2(500) := 'pac_iax_sin_imp_sap.f_get_concep_pago';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vparam         VARCHAR2(500) := 'parámetros - pccodimp=' || NULL;
   BEGIN
      cur := pac_md_sin_imp_sap.f_get_concep_pago(mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;
         RETURN cur;
   END f_get_concep_pago;
   --IAXIS 7655 AABC Conceptos de indicador pagos de tiquetes aereos
   FUNCTION f_set_impuesto_prof(
      psprofes IN NUMBER,
      pccodimp IN NUMBER,
      pctipind IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'pac_iax_sin_imp_sap.f_set_impuesto_prof';
      vparam         VARCHAR2(4000)
            := 'psprofes=' || psprofes || ' pccodimp=' || pccodimp || ' pctipind=' || pctipind;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_md_sin_imp_sap.f_set_impuesto_prof(psprofes, pccodimp, pctipind,
                                                        mensajes);

      IF vnumerr != 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_set_impuesto_prof;

   FUNCTION f_del_impuesto_prof(
      psprofes IN NUMBER,
      pctipind IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(500) := 'pac_iax_sin_imp_sap.f_del_impuesto_prof';
      vparam         VARCHAR2(500)
                           := 'parámetros - sprofes=' || psprofes || ' pctipind: ' || pctipind;
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(5) := 1;
   BEGIN
      vnumerr := pac_md_sin_imp_sap.f_del_impuesto_prof(psprofes, pctipind, mensajes);

      IF vnumerr != 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, NULL,
                                           SQLCODE, SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_del_impuesto_prof;

   FUNCTION f_get_indicador_prof(
      pcconpag IN NUMBER,
      psprofes IN NUMBER,
      pccodimp IN NUMBER,
      pfordpag IN DATE,
      pnsinies IN sin_tramita_localiza.nsinies%TYPE,
      pntramit IN sin_tramita_localiza.ntramit%TYPE,
      pnlocali IN sin_tramita_localiza.nlocali%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vobject        VARCHAR2(500) := 'pac_iax_sin_imp_sap.f_get_indicador_prof';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vparam         VARCHAR2(500)
         := 'parámetros - pcconpag=' || pcconpag || ' psprofes=' || psprofes || ' pfordpag='
            || pfordpag || ' pccodimp=' || pccodimp;
   BEGIN
      cur := pac_md_sin_imp_sap.f_get_indicador_prof(pcconpag, psprofes, pccodimp, pfordpag,
                                                     pnsinies, pntramit, pnlocali, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_indicador_prof;
   --INI--WAJ
    FUNCTION f_set_impuesto_per(
      pccodvin IN NUMBER,
      pccatribu IN NUMBER,
      pctipind IN NUMBER,
      psperson IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'pac_iax_sin_imp_sap.f_set_impuesto_per';
      vparam         VARCHAR2(4000)
            := 'pccodvin' || pccodvin;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN

      vnumerr := pac_md_sin_imp_sap.f_set_impuesto_per(pccodvin, pccatribu, pctipind, psperson,
                                                        mensajes);

      IF vnumerr != 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN 0;

   END f_set_impuesto_per;
    --FIN--WAJ
END pac_iax_sin_imp_sap;

/

