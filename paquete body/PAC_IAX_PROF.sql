--------------------------------------------------------
--  DDL for Package Body PAC_IAX_PROF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IAX_PROF" AS
/******************************************************************************
   NOMBRE:    PAC_IAX_PROF
   PROP풱ITO: Funciones para profesionales

   REVISIONES:
   Ver        Fecha        Autor             Descripci퓆
   ---------  ----------  ---------------  ------------------------------------
    1.0       24/08/2011   JDS             Creacion
*/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

/*****************************************************************************/
                                                                               /*************************************************************************

    Devuelve la lista de sedes de un profesional
         param in  csprofes : codigo profesional
         param out mensajes : mesajes de error
         return             : ref cursor
      *************************************************************************/
   FUNCTION f_get_lstccc(psprofes IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100) := '';
      vobject        VARCHAR2(200) := 'PAC_IAX_PROF. f_get_lstccc ';
   BEGIN
      cur := pac_md_prof.f_get_lstccc(psprofes, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstccc;

   FUNCTION f_set_ccc(
      psprofes IN NUMBER,
      pcramo IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcnordban IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      /*************************************************************************
         Graba la ccc del profesional
         param out mensajes : mesajes de error
         return             : number
      *************************************************************************/
      vobjectname    VARCHAR2(500) := 'PAC_IAX_PROF.f_set_ccc';
      vparam         VARCHAR2(500) := 'par퓅etros - ';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   --vobjservicio   ob_iax_sin_tramita_detgestion := ob_iax_sin_tramita_detgestion();
   BEGIN
      vnumerr := pac_md_prof.f_set_ccc(psprofes, pcramo, psproduc, pcactivi, pcnordban,
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
   END f_set_ccc;

   FUNCTION f_get_dades_profesional(psprofes IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN ob_iax_profesional IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(3000) := 'psprofes=' || psprofes;
      vobject        VARCHAR2(200) := 'PAC_IAX_PROF.F_get_profesional';
      v_result       ob_iax_profesional;
   BEGIN
      --Crida a la capa MD
      v_result := pac_md_prof.f_get_dades_profesional(psprofes, mensajes);
      RETURN v_result;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_dades_profesional;

   FUNCTION f_get_ccc(sprofes IN NUMBER, t_ccc OUT t_iax_prof_ccc, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(500) := 'PAC_IAX_PROF.f_get_ccc';
      vparam         VARCHAR2(500) := 'par퓅etros - ';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_md_prof.f_get_ccc(sprofes, t_ccc, mensajes);
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_ccc;

   FUNCTION f_set_estado(
      sprofes IN NUMBER,
      cestprf IN NUMBER,
      festado IN DATE,
      cmotbaja IN NUMBER,
      tobservaciones IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      /*************************************************************************
         Graba el estado del profesional
         param out mensajes : mesajes de error
         return             : number
      *************************************************************************/
      vobjectname    VARCHAR2(500) := 'PAC_IAX_PROF.f_set_estado';
      vparam         VARCHAR2(500) := 'par퓅etros - ';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   --vobjservicio   ob_iax_sin_tramita_detgestion := ob_iax_sin_tramita_detgestion();
   BEGIN
      vnumerr := pac_md_prof.f_set_estado(sprofes, cestprf, festado, cmotbaja, tobservaciones,
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
   END f_set_estado;

   FUNCTION f_get_estados(
      sprofes IN NUMBER,
      t_estados OUT t_iax_prof_estados,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(500) := 'PAC_IAX_PROF.f_get_estados';
      vparam         VARCHAR2(500) := 'par퓅etros - sprofes=' || sprofes;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_md_prof.f_get_estados(sprofes, t_estados, mensajes);
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_estados;

   FUNCTION f_del_estado(sprofes IN NUMBER, festado IN DATE, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(500) := 'PAC_IAX_PROF.f_del_estado';
      vparam         VARCHAR2(500)
                              := 'par퓅etros - sprofes=' || sprofes || ' festado: ' || festado;
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(5) := 1;
   BEGIN
      vnumerr := pac_md_prof.f_del_estado(sprofes, festado, mensajes);

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
   END f_del_estado;

   FUNCTION f_del_ccc(sprofes IN NUMBER, cnorden IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(500) := 'PAC_IAX_PROF.f_del_ccc';
      vparam         VARCHAR2(500)
                              := 'par퓅etros - sprofes=' || sprofes || ' cnorden: ' || cnorden;
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(5) := 1;
   BEGIN
      vnumerr := pac_md_prof.f_del_ccc(sprofes, cnorden, mensajes);

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
   END f_del_ccc;

   FUNCTION f_set_zona(
      psprofes IN NUMBER,
      pctpzona IN NUMBER,
      pcpais IN NUMBER,
      pcprovin IN NUMBER,
      pcpoblac IN NUMBER,
      pcposini IN VARCHAR2,
      pcposfin IN VARCHAR2,
      pfdesde IN DATE,
      pfhasta IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      /*************************************************************************
         Graba la zona del profesional
         param out mensajes : mesajes de error
         return             : number
      *************************************************************************/
      vobjectname    VARCHAR2(500) := 'PAC_IAX_PROF.f_set_zona';
      vparam         VARCHAR2(500) := 'par퓅etros - ';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   --vobjservicio   ob_iax_sin_tramita_detgestion := ob_iax_sin_tramita_detgestion();
   BEGIN
      vnumerr := pac_md_prof.f_set_zona(psprofes, pctpzona, pcpais, pcprovin, pcpoblac,
                                        pcposini, pcposfin, pfdesde, pfhasta, mensajes);

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
   END f_set_zona;

   FUNCTION f_get_zonas(
      sprofes IN NUMBER,
      t_zonas OUT t_iax_prof_zonas,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(500) := 'PAC_IAX_PROF.f_get_zonas';
      vparam         VARCHAR2(500) := 'par퓅etros - sprofes=' || sprofes;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_md_prof.f_get_zonas(sprofes, t_zonas, mensajes);
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_zonas;

   FUNCTION f_mod_zona(
      psprofes IN NUMBER,
      pcnordzn IN NUMBER,
      pfhasta IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      /*************************************************************************
         Modifica la fecha hasta la cual est� asignada esa zona
         param out mensajes : mesajes de error
         return             : number
      *************************************************************************/
      vobjectname    VARCHAR2(500) := 'PAC_IAX_PROF.f_mod_zona';
      vparam         VARCHAR2(500) := 'par퓅etros - ';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_md_prof.f_mod_zona(psprofes, pcnordzn, pfhasta, mensajes);

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
   END f_mod_zona;

   FUNCTION f_set_contacto_per(
      sprofes IN NUMBER,
      ctipdoc IN NUMBER,
      nnumnif IN VARCHAR2,
      tnombre IN VARCHAR2,
      tmovil IN VARCHAR2,
      temail IN VARCHAR2,
      tcargo IN VARCHAR2,
      tdirecc IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      /*************************************************************************
            Graba la persona de contacto del profesional
            param out mensajes : mesajes de error
            return             : number
         *************************************************************************/
      vobjectname    VARCHAR2(500) := 'PAC_IAX_PROF.f_set_contacto_per';
      vparam         VARCHAR2(500) := 'par퓅etros - ';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_md_prof.f_set_contacto_per(sprofes, ctipdoc, nnumnif, tnombre, tmovil,
                                                temail, tcargo, tdirecc, mensajes);

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
   END f_set_contacto_per;

   FUNCTION f_get_contactos_per(
      sprofes IN NUMBER,
      t_contactos_per OUT t_iax_prof_contactos_per,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(500) := 'PAC_IAX_PROF.f_get_contactos_per';
      vparam         VARCHAR2(500) := 'par퓅etros - sprofes=' || sprofes;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_md_prof.f_get_contactos_per(sprofes, t_contactos_per, mensajes);
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_contactos_per;

   FUNCTION f_get_ctipprof(sprofes IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100) := '';
      vobject        VARCHAR2(200) := 'PAC_IAX_PROF. f_get_ctipprof ';
   BEGIN
      cur := pac_md_prof.f_get_ctipprof(sprofes, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_ctipprof;

   FUNCTION f_get_csubprof(sprofes IN NUMBER, ctipprof IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100) := '';
      vobject        VARCHAR2(200) := 'PAC_IAX_PROF. f_get_csubprof ';
   BEGIN
      cur := pac_md_prof.f_get_csubprof(sprofes, ctipprof, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_csubprof;

   FUNCTION f_set_carga(
      sprofes IN NUMBER,
      ctippro IN NUMBER,
      csubpro IN NUMBER,
      ncardia IN NUMBER,
      ncarsem IN NUMBER,
      fdesde IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      /*************************************************************************
            Graba la carga permitida del profesional
            param out mensajes : mesajes de error
            return             : number
         *************************************************************************/
      vobjectname    VARCHAR2(500) := 'PAC_IAX_PROF.f_set_carga';
      vparam         VARCHAR2(500) := 'par퓅etros - ';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_md_prof.f_set_carga(sprofes, ctippro, csubpro, ncardia, ncarsem, fdesde,
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
   END f_set_carga;

   FUNCTION f_get_carga(
      sprofes IN NUMBER,
      t_carga OUT t_iax_prof_carga_permitida,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(500) := 'PAC_IAX_PROF.f_get_carga';
      vparam         VARCHAR2(500) := 'par퓅etros - sprofes=' || sprofes;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_md_prof.f_get_carga(sprofes, t_carga, mensajes);
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_carga;

   FUNCTION f_del_carga(
      sprofes IN NUMBER,
      ctippro IN NUMBER,
      csubpro IN NUMBER,
      fdesde IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(500) := 'PAC_IAX_PROF.f_del_carga';
      vparam         VARCHAR2(500)
         := 'par퓅etros - sprofes=' || sprofes || ' ctippro: ' || ctippro || ' csubpro: '
            || csubpro || ' fdesde: ' || fdesde;
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(5) := 1;
   BEGIN
      vnumerr := pac_md_prof.f_del_carga(sprofes, ctippro, csubpro, fdesde, mensajes);

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
   END f_del_carga;

   FUNCTION f_del_contacto_per(
      sprofes IN NUMBER,
      nordcto IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(500) := 'PAC_IAX_PROF.f_del_contacto_per';
      vparam         VARCHAR2(500)
                              := 'par퓅etros - sprofes=' || sprofes || ' nordcto: ' || nordcto;
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(5) := 1;
   BEGIN
      vnumerr := pac_md_prof.f_del_contacto_per(sprofes, nordcto, mensajes);

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
   END f_del_contacto_per;

   FUNCTION f_mod_contacto_per(
      sprofes IN NUMBER,
      cnordcto IN NUMBER,
      ctipdoc IN NUMBER,
      nnumnif IN VARCHAR2,
      tnombre IN VARCHAR2,
      tmovil IN VARCHAR2,
      temail IN VARCHAR2,
      tcargo IN VARCHAR2,
      tdirecc IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      /*************************************************************************
           Modifica la persona de contacto del profesional
           param out mensajes : mesajes de error
           return             : number
        *************************************************************************/
      vobjectname    VARCHAR2(500) := 'PAC_IAX_PROF.f_mod_contacto_per';
      vparam         VARCHAR2(500) := 'par퓅etros - ';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_md_prof.f_mod_contacto_per(sprofes, cnordcto, ctipdoc, nnumnif, tnombre,
                                                tmovil, temail, tcargo, tdirecc, mensajes);

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
   END f_mod_contacto_per;

   FUNCTION f_calc_carga(
      sprofes IN NUMBER,
      ctippro IN NUMBER,
      csubpro IN NUMBER,
      ncapaci IN NUMBER,
      fdesde IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vobject        VARCHAR2(500) := 'PAC_IAX_PROF.f_calc_carga';
      vparam         VARCHAR2(500)
         := 'par퓅etros - sprofes=' || sprofes || ' ctippro: ' || ctippro || ' csubpro: '
            || csubpro || ' ncapaci: ' || ncapaci;
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(5) := 1;
   BEGIN
      cur := pac_md_prof.f_calc_carga(sprofes, ctippro, csubpro, ncapaci, fdesde, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, NULL,
                                           SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_calc_carga;

   FUNCTION f_set_carga_real(
      sprofes IN NUMBER,
      ctippro IN NUMBER,
      csubpro IN NUMBER,
      ncapaci IN NUMBER,
      ncardia IN NUMBER,
      ncarsem IN NUMBER,
      fdesde IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      /*************************************************************************
            Graba la carga real del profesional
            param out mensajes : mesajes de error
            return             : number
       *************************************************************************/
      vobjectname    VARCHAR2(500) := 'PAC_IAX_PROF.f_set_carga_real';
      vparam         VARCHAR2(500) := 'par퓅etros - ';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_md_prof.f_set_carga_real(sprofes, ctippro, csubpro, ncapaci, ncardia,
                                              ncarsem, fdesde, mensajes);

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
   END f_set_carga_real;

   FUNCTION f_get_carga_real(
      sprofes IN NUMBER,
      t_carga_real OUT t_iax_prof_carga_real,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(500) := 'PAC_IAX_PROF.f_get_carga_real';
      vparam         VARCHAR2(500) := 'par퓅etros - sprofes=' || sprofes;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_md_prof.f_get_carga_real(sprofes, t_carga_real, mensajes);
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_carga_real;

   FUNCTION f_del_carga_real(
      sprofes IN NUMBER,
      ctippro IN NUMBER,
      csubpro IN NUMBER,
      fdesde IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(500) := 'PAC_IAX_PROF.f_del_carga_real';
      vparam         VARCHAR2(500)
         := 'par퓅etros - sprofes=' || sprofes || ' ctippro: ' || ctippro || ' csubpro: '
            || csubpro || ' fdesde: ' || fdesde;
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(5) := 1;
   BEGIN
      vnumerr := pac_md_prof.f_del_carga_real(sprofes, ctippro, csubpro, fdesde, mensajes);

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
   END f_del_carga_real;

   FUNCTION f_set_descartado(
      sprofes IN NUMBER,
      ctippro IN NUMBER,
      csubpro IN NUMBER,
      sproduc IN NUMBER,
      ccausin IN NUMBER,
      fdesde IN DATE,
      fhasta IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      /*************************************************************************
            Graba el producto/causa descartada del profesional
            param out mensajes : mesajes de error
            return             : number
       *************************************************************************/
      vobjectname    VARCHAR2(500) := 'PAC_IAX_PROF.f_set_descartado';
      vparam         VARCHAR2(500) := 'par퓅etros - ';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_md_prof.f_set_descartado(sprofes, ctippro, csubpro, sproduc, ccausin,
                                              fdesde, fhasta, mensajes);

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
   END f_set_descartado;

   FUNCTION f_get_descartados(
      sprofes IN NUMBER,
      t_descartados OUT t_iax_prof_descartados,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(500) := 'PAC_IAX_PROF.f_get_descartados';
      vparam         VARCHAR2(500) := 'par퓅etros - sprofes=' || sprofes;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_md_prof.f_get_descartados(sprofes, t_descartados, mensajes);
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_descartados;

   FUNCTION f_mod_descartados(
      sprofes IN NUMBER,
      ctippro IN NUMBER,
      csubpro IN NUMBER,
      sproduc IN NUMBER,
      ccausin IN NUMBER,
      fdesde IN DATE,
      fhasta IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      /*************************************************************************
         Modifica el producto o causa descartada del profesional
         param out mensajes : mesajes de error
         return             : number
      *************************************************************************/
      vobjectname    VARCHAR2(500) := 'PAC_IAX_PROF.f_mod_descartados';
      vparam         VARCHAR2(500) := 'par퓅etros - ';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_md_prof.f_mod_descartados(sprofes, ctippro, csubpro, sproduc, ccausin,
                                               fdesde, fhasta, mensajes);

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
   END f_mod_descartados;

   FUNCTION f_set_observaciones(
      sprofes IN NUMBER,
      tobserv IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      /*************************************************************************
            Graba la observaci퓆 del profesional
            param out mensajes : mesajes de error
            return             : number
       *************************************************************************/
      vobjectname    VARCHAR2(500) := 'PAC_IAX_PROF.f_set_observaciones';
      vparam         VARCHAR2(500) := 'par퓅etros - ';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_md_prof.f_set_observaciones(sprofes, tobserv, mensajes);

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
   END f_set_observaciones;

   FUNCTION f_get_observaciones(
      sprofes IN NUMBER,
      t_observaciones OUT t_iax_prof_observaciones,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(500) := 'PAC_IAX_PROF.f_get_observaciones';
      vparam         VARCHAR2(500) := 'par퓅etros - sprofes=' || sprofes;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_md_prof.f_get_observaciones(sprofes, t_observaciones, mensajes);
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_observaciones;

   FUNCTION f_set_rol(
      sprofes IN NUMBER,
      ctippro IN NUMBER,
      csubpro IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      /*************************************************************************
            Graba el rol del profesional
            param out mensajes : mesajes de error
            return             : number
       *************************************************************************/
      vobjectname    VARCHAR2(500) := 'PAC_IAX_PROF.f_set_rol';
      vparam         VARCHAR2(500) := 'par퓅etros - ';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_md_prof.f_set_rol(sprofes, ctippro, csubpro, mensajes);

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
   END f_set_rol;

   FUNCTION f_get_roles(
      sprofes IN NUMBER,
      t_roles OUT t_iax_prof_roles,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(500) := 'PAC_IAX_PROF.f_get_roles';
      vparam         VARCHAR2(500) := 'par퓅etros - sprofes=' || sprofes;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_md_prof.f_get_roles(sprofes, t_roles, mensajes);
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_roles;

   FUNCTION f_set_seguimiento(
      sprofes IN NUMBER,
      tobserv IN VARCHAR2,
      ccalific IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      /*************************************************************************
            Graba el seguimiento del profesional
            param out mensajes : mesajes de error
            return             : number
       *************************************************************************/
      vobjectname    VARCHAR2(500) := 'PAC_IAX_PROF.f_set_seguimiento';
      vparam         VARCHAR2(500) := 'par퓅etros - ';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_md_prof.f_set_seguimiento(sprofes, tobserv, ccalific, mensajes);

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
   END f_set_seguimiento;

   FUNCTION f_get_seguimiento(
      sprofes IN NUMBER,
      t_seguimiento OUT t_iax_prof_seguimiento,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(500) := 'PAC_IAX_PROF.f_get_seguimiento';
      vparam         VARCHAR2(500) := 'par퓅etros - sprofes=' || sprofes;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_md_prof.f_get_seguimiento(sprofes, t_seguimiento, mensajes);
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_seguimiento;

   FUNCTION f_get_sprofes(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vobject        VARCHAR2(500) := 'PAC_IAX_PROF.f_get_sprofes';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vparam         VARCHAR2(500) := '';
   BEGIN
      cur := pac_md_prof.f_get_sprofes(mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_sprofes;

   FUNCTION f_get_lsttelefonos(sperson IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vobject        VARCHAR2(500) := 'PAC_IAX_PROF.f_get_lsttelefonos';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vparam         VARCHAR2(500) := '';
   BEGIN
      cur := pac_md_prof.f_get_lsttelefonos(sperson, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lsttelefonos;

   FUNCTION f_get_lstemail(sperson IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vobject        VARCHAR2(500) := 'PAC_IAX_PROF.f_get_lstemail';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vparam         VARCHAR2(500) := '';
   BEGIN
      cur := pac_md_prof.f_get_lstemail(sperson, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstemail;

   FUNCTION f_set_obj_profesional(
      sprofes IN NUMBER,
      sperson IN NUMBER,
      tnombre IN VARCHAR2,
      nregmer IN VARCHAR2,
      fregmer IN DATE,
      cdomici IN NUMBER,
      cmodcon IN NUMBER,
      ctelcli IN NUMBER,
      nlimite IN NUMBER,
      cnoasis IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'sprofes=' || sprofes || 'sperson=' || sperson || ' nregmer=' || nregmer
            || 'fregmer=' || fregmer || ' cdomici=' || cdomici || 'cmodcon=' || cmodcon
            || ' ctelcli=' || ctelcli || ' nlimite=' || nlimite || ' cnoasis=' || cnoasis;
      vobject        VARCHAR2(200) := 'PAC_IAX_prof.f_set_obj_profesional';
   BEGIN
      --Comprovaci� de par퓅etres
      IF sprofes IS NULL
         OR sperson IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      profesional := ob_iax_profesional();
      profesional.sprofes := sprofes;
      profesional.sperson := sperson;
      profesional.tnombre := tnombre;
      profesional.nregmer := nregmer;
      profesional.fregmer := fregmer;
      profesional.cdomici := cdomici;
      profesional.cmodcon := cmodcon;
      profesional.ttelcli := ctelcli;
      profesional.nlimite := nlimite;
      profesional.cnoasis := cnoasis;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_set_obj_profesional;

   FUNCTION f_set_profesional(
      sprofes IN NUMBER,
      sperson IN NUMBER,
      tnombre IN VARCHAR2,
      nregmer IN VARCHAR2,
      fregmer IN DATE,
      cdomici IN NUMBER,
      cmodcon IN NUMBER,
      ctelcli IN NUMBER,
      nlimite IN NUMBER,
      cnoasis IN NUMBER,
      pcmodo IN NUMBER,
      ptexto OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'sprofes=' || sprofes || 'sperson=' || sperson || ' nregmer=' || nregmer
            || 'fregmer=' || fregmer || ' cdomici=' || cdomici || 'cmodcon=' || cmodcon
            || ' ctelcli=' || ctelcli || ' nlimite=' || nlimite || ' cnoasis=' || cnoasis;
      vobject        VARCHAR2(200) := 'PAC_IAX_prof.f_set_profesional';
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := f_set_obj_profesional(sprofes, sperson, tnombre, nregmer, fregmer, cdomici,
                                       cmodcon, ctelcli, nlimite, cnoasis, mensajes);

      IF vnumerr != 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      ELSE
         vnumerr := pac_md_prof.f_set_profesional(sprofes, profesional, pcmodo, ptexto,
                                                  mensajes);
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_set_profesional;

   FUNCTION f_get_profesionales(
      pctipide IN NUMBER,
      pnnumide IN VARCHAR2,
      ptnombre IN VARCHAR2,
      pctippro IN NUMBER,
      pcsubpro IN NUMBER,
      psprofes IN NUMBER,
      pcprovin IN NUMBER DEFAULT NULL,
      pcpoblac IN NUMBER DEFAULT NULL,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vobject        VARCHAR2(500) := 'PAC_IAX_PROF.f_get_profesionales';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vparam         VARCHAR2(500)
         := ' pctipide= ' || pctipide || ' pnnumide= ' || pnnumide || ' ptnombre=' || ptnombre
            || ' pctippro=' || pctippro || ' pcsubpro= ' || pcsubpro || ' psprofes= '
            || psprofes || ' pcprovin=' || pcprovin || ' pcpoblac=' || pcpoblac;
   BEGIN
      cur := pac_md_prof.f_get_profesionales(pctipide, pnnumide, ptnombre, pctippro, pcsubpro,
                                             psprofes, pcprovin, pcpoblac, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_profesionales;

   FUNCTION f_get_profesional(
      psprofes IN NUMBER,
      obprofesional OUT ob_iax_profesional,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(500) := 'PAC_IAX_PROF.f_get_profesional';
      vparam         VARCHAR2(500) := 'par퓅etros - psprofes=' || psprofes;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      t_contactos    t_iax_prof_contactos;
      t_roles        t_iax_prof_roles;
      t_contactos_per t_iax_prof_contactos_per;
      t_ccc          t_iax_prof_ccc;
      t_estados      t_iax_prof_estados;
      t_zonas        t_iax_prof_zonas;
      t_observaciones t_iax_prof_observaciones;
      t_carga        t_iax_prof_carga_permitida;
      t_carga_real   t_iax_prof_carga_real;
      t_descartados  t_iax_prof_descartados;
      t_seguimiento  t_iax_prof_seguimiento;
      t_docs         t_iax_prof_documentacion;
      t_sedes        t_iax_prof_sedes;
      t_representantes t_iax_prof_repre;
      t_convenios    t_iax_prof_conve;
      t_impuestos    t_iax_prof_impuestos;   --0024637/0147756: (POSAN500-AN-Sin) Analisis Desarrollo: Siniestros : NSS : 25/02/2014
   BEGIN
      vnumerr := pac_md_prof.f_get_profesional(psprofes, obprofesional, mensajes);

      IF vnumerr = 0 THEN
         vnumerr := f_get_roles(psprofes, t_roles, mensajes);
      END IF;

      IF vnumerr = 0 THEN
         obprofesional.ROLES := t_roles;
         vnumerr := f_get_contactos(psprofes, t_contactos, mensajes);
      END IF;

      IF vnumerr = 0 THEN
         obprofesional.contactos := t_contactos;
         vnumerr := f_get_convenios(psprofes, t_convenios, mensajes);
      END IF;

      IF vnumerr = 0 THEN
         obprofesional.convenios := t_convenios;
         vnumerr := f_get_contactos_per(psprofes, t_contactos_per, mensajes);
      END IF;

      IF vnumerr = 0 THEN
         obprofesional.contactos_per := t_contactos_per;
         vnumerr := f_get_ccc(psprofes, t_ccc, mensajes);
      END IF;

      IF vnumerr = 0 THEN
         obprofesional.cuentas := t_ccc;
         vnumerr := f_get_estados(psprofes, t_estados, mensajes);
      END IF;

      --0024637/0147756: (POSAN500-AN-Sin) Analisis Desarrollo: Siniestros : NSS : 25/02/2014
      IF vnumerr = 0 THEN
         obprofesional.estados := t_estados;
         vnumerr := pac_md_prof.f_get_impuestos(psprofes, t_impuestos, mensajes);
      END IF;

      --FIN 0024637/0147756: (POSAN500-AN-Sin) Analisis Desarrollo: Siniestros : NSS : 25/02/2014
      IF vnumerr = 0 THEN
         obprofesional.impuestos := t_impuestos;   --0024637/0147756: (POSAN500-AN-Sin) Analisis Desarrollo: Siniestros : NSS : 25/02/2014
         vnumerr := f_get_zonas(psprofes, t_zonas, mensajes);
      END IF;

      IF vnumerr = 0 THEN
         obprofesional.zonas := t_zonas;
         vnumerr := f_get_sedes(psprofes, t_sedes, mensajes);
      END IF;

      IF vnumerr = 0 THEN
         obprofesional.sedes := t_sedes;
         vnumerr := f_get_representantes(psprofes, t_representantes, mensajes);
      END IF;

      IF vnumerr = 0 THEN
         obprofesional.representantes := t_representantes;
         vnumerr := f_get_observaciones(psprofes, t_observaciones, mensajes);
      END IF;

      IF vnumerr = 0 THEN
         obprofesional.observaciones := t_observaciones;
         vnumerr := f_get_carga(psprofes, t_carga, mensajes);
      END IF;

      IF vnumerr = 0 THEN
         obprofesional.carga := t_carga;
         vnumerr := f_get_carga_real(psprofes, t_carga_real, mensajes);
      END IF;

      IF vnumerr = 0 THEN
         obprofesional.carga_real := t_carga_real;
         vnumerr := f_get_descartados(psprofes, t_descartados, mensajes);
      END IF;

      IF vnumerr = 0 THEN
         obprofesional.descartados := t_descartados;
         vnumerr := f_get_seguimiento(psprofes, t_seguimiento, mensajes);
      END IF;

      IF vnumerr = 0 THEN
         obprofesional.seguimiento := t_seguimiento;
         vnumerr := f_get_documentos(psprofes, t_docs, mensajes);
      END IF;

      IF vnumerr = 0 THEN
         obprofesional.documentacion := t_docs;
      END IF;

      /*F_GET_CONTRATOS*/
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_profesional;

   FUNCTION f_get_ctipprof_carga_real(sprofes IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100) := '';
      vobject        VARCHAR2(200) := 'PAC_IAX_PROF. f_get_ctipprof_carga_real';
   BEGIN
      cur := pac_md_prof.f_get_ctipprof_carga_real(sprofes, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_ctipprof_carga_real;

   FUNCTION f_get_csubprof_carga_real(
      sprofes IN NUMBER,
      ctipprof IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100) := '';
      vobject        VARCHAR2(200) := 'PAC_IAX_PROF. f_get_csubprof_carga_real';
   BEGIN
      cur := pac_md_prof.f_get_csubprof_carga_real(sprofes, ctipprof, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_csubprof_carga_real;

   FUNCTION f_del_rol(
      sprofes IN NUMBER,
      ctippro IN NUMBER,
      csubpro IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(500) := 'PAC_IAX_PROF.f_del_rol';
      vparam         VARCHAR2(500)
         := 'par퓅etros - sprofes=' || sprofes || ' ctippro: ' || ctippro || ' csubpro: '
            || csubpro;
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(5) := 1;
   BEGIN
      vnumerr := pac_md_prof.f_del_rol(sprofes, ctippro, csubpro, mensajes);

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
   END f_del_rol;

   FUNCTION f_get_contactos(
      sprofes IN NUMBER,
      t_contactos OUT t_iax_prof_contactos,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(500) := 'PAC_IAX_PROF.f_get_contactos';
      vparam         VARCHAR2(500) := 'par퓅etros - sprofes=' || sprofes;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_md_prof.f_get_contactos(sprofes, t_contactos, mensajes);
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_contactos;

   FUNCTION f_set_contacto_pref(
      sprofes IN NUMBER,
      cmodcon IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'sprofes=' || sprofes || 'cmodcon=' || cmodcon;
      vobject        VARCHAR2(200) := 'PAC_IAX_prof.f_set_contacto_pref';
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_md_prof.f_set_contacto_pref(sprofes, cmodcon, mensajes);

      IF vnumerr != 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_set_contacto_pref;

   FUNCTION f_get_documentos(
      sprofes IN NUMBER,
      t_docs OUT t_iax_prof_documentacion,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(500) := 'PAC_IAX_PROF.f_get_documentos';
      vparam         VARCHAR2(500) := 'par퓅etros - sprofes=' || sprofes;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_md_prof.f_get_documentos(sprofes, t_docs, mensajes);
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_documentos;

   /*************************************************************************
     Funcion que inserta o actualiza los datos de un documento asociado a la persona/profesional
   *************************************************************************/
   FUNCTION f_set_documentacion(
      psprofes IN NUMBER,
      psperson IN NUMBER,
      pcagente IN NUMBER,
      pfcaduca IN DATE,
      ptobserva IN VARCHAR2,
      ptfilename IN VARCHAR2,
      piddocgedox IN NUMBER,
      ptdesc IN VARCHAR2 DEFAULT NULL,
      pidcat IN NUMBER DEFAULT NULL,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'parametros - psprofes: ' || psprofes || ' - psperson: ' || psperson
            || ' - pcagente: ' || pcagente || ' - pfcaduca: '
            || TO_CHAR(pfcaduca, 'DD/MM/YYYY') || ' - ptobserva: ' || ptobserva
            || ' - ptfilename: ' || ptfilename || ' - piddocgedox: ' || piddocgedox
            || ' - ptdesc: ' || ptdesc || ' - pidcat: ' || pidcat;
      vobject        VARCHAR2(200) := 'PAC_IAX_PROF.f_set_documentacion';
      viddocgedox    NUMBER;
   BEGIN
      IF psprofes IS NULL THEN
         RAISE e_param_error;
      END IF;

      viddocgedox := piddocgedox;

      IF viddocgedox IS NOT NULL THEN
         vnumerr := pac_md_prof.f_set_documentacion(psprofes, pfcaduca, ptobserva,
                                                    viddocgedox, ptdesc, ptfilename, mensajes);
      ELSE
         vnumerr := pac_md_gedox.f_set_documprofgedox(psprofes,
                                                      pac_md_common.f_get_cxtusuario(),
                                                      pfcaduca, ptobserva, ptfilename,
                                                      viddocgedox, ptdesc, pidcat, mensajes);
      END IF;

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_set_documentacion;

   FUNCTION f_get_sedes(
      sprofes IN NUMBER,
      t_sedes OUT t_iax_prof_sedes,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(500) := 'PAC_IAX_PROF.f_get_sedes';
      vparam         VARCHAR2(500) := 'par퓅etros - sprofes=' || sprofes;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_md_prof.f_get_sedes(sprofes, t_sedes, mensajes);
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_sedes;

   FUNCTION f_set_sede(
      sprofes IN NUMBER,
      spersed IN NUMBER,
      thorari IN VARCHAR2,
      tpercto IN VARCHAR2,
      cdomici IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(500) := 'PAC_IAX_PROF.f_set_sede';
      vparam         VARCHAR2(500) := 'par퓅etros - sprofes=' || sprofes;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_md_prof.f_set_sede(sprofes, spersed, thorari, tpercto, cdomici, mensajes);

      IF vnumerr != 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_set_sede;

   FUNCTION f_get_representantes(
      sprofes IN NUMBER,
      t_representantes OUT t_iax_prof_repre,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(500) := 'PAC_IAX_PROF.f_get_representantes';
      vparam         VARCHAR2(500) := 'par퓅etros - sprofes=' || sprofes;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_md_prof.f_get_representantes(sprofes, t_representantes, mensajes);
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_representantes;

   FUNCTION f_set_representante(
      sprofes IN NUMBER,
      sperson IN NUMBER,
      nmovil IN NUMBER,
      temail IN NUMBER,
      tcargo IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(500) := 'PAC_IAX_PROF.f_set_representante';
      vparam         VARCHAR2(500) := 'par퓅etros - sprofes=' || sprofes;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_md_prof.f_set_representante(sprofes, sperson, nmovil, temail, tcargo,
                                                 mensajes);

      IF vnumerr != 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_set_representante;

   FUNCTION f_get_sservic(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100) := '';
      vobject        VARCHAR2(200) := 'PAC_IAX_PROF.f_get_sservic';
   BEGIN
      cur := pac_md_prof.f_get_sservic(mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_sservic;

   FUNCTION f_get_lstcups(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100) := '';
      vobject        VARCHAR2(200) := 'PAC_IAX_PROF.f_get_lstcups';
   BEGIN
      cur := pac_md_prof.f_get_lstcups(mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstcups;

   FUNCTION f_set_servicio(
      starifa IN NUMBER,
      sservic IN NUMBER,
      ccodcup IN VARCHAR2,
      tdescri IN VARCHAR2,
      cunimed IN NUMBER,
      iprecio IN NUMBER,
      ctipcal IN NUMBER,
      cmagnit IN NUMBER,
      iminimo IN NUMBER,
      cselecc IN NUMBER,
      ctipser IN NUMBER,
      finivig IN DATE,
      ffinvig IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(500) := 'PAC_IAX_PROF.f_set_servicio';
      vparam         VARCHAR2(500)
         := 'par퓅etros - starifa=' || starifa || ' sservic: ' || sservic || ' ccodcup: '
            || ccodcup || ' tdescri: ' || tdescri || ' cunimed: ' || cunimed || ' iprecio: '
            || iprecio || ' ctipcal: ' || ctipcal || ' cmagnit: ' || cmagnit || ' iminimo: '
            || iminimo || ' cselecc: ' || cselecc || ' ctipser: ' || ctipser || ' finivig: '
            || finivig;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_md_prof.f_set_servicio(starifa, sservic, ccodcup, tdescri, cunimed,
                                            iprecio, ctipcal, cmagnit, iminimo, cselecc,
                                            ctipser, finivig, ffinvig, mensajes);

      IF vnumerr != 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_set_servicio;

   FUNCTION f_get_servicios(
      starifa IN NUMBER,
      sservic IN NUMBER,
      tdescri IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vobject        VARCHAR2(500) := 'PAC_IAX_PROF.f_get_servicios';
      vparam         VARCHAR2(500) := 'par퓅etros - starifa=' || starifa;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      cur            sys_refcursor;
   BEGIN
      cur := pac_md_prof.f_get_servicios(starifa, sservic, tdescri, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_servicios;

   FUNCTION f_get_servicio(
      starifa IN NUMBER,
      sservic IN NUMBER,
      servicio OUT ob_iax_prof_servi,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(500) := 'PAC_IAX_PROF.f_get_servicio';
      vparam         VARCHAR2(500)
                                := 'par퓅etros - starifa=' || starifa || 'sservic=' || sservic;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_md_prof.f_get_servicio(starifa, sservic, servicio, mensajes);
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_servicio;

   FUNCTION f_get_tarifas(pstarifa IN NUMBER, ptdescri IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vobject        VARCHAR2(500) := 'PAC_IAX_PROF.f_get_tarifas';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vparam         VARCHAR2(500) := ' pstarifa= ' || pstarifa || ' ptdescri= ' || ptdescri;
   BEGIN
      cur := pac_md_prof.f_get_tarifas(pstarifa, ptdescri, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_tarifas;

   FUNCTION f_get_starifa(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100) := '';
      vobject        VARCHAR2(200) := 'PAC_IAX_PROF.f_get_starifa';
   BEGIN
      cur := pac_md_prof.f_get_starifa(mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_starifa;

   FUNCTION f_set_tarifa(starifa IN NUMBER, tdescri IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(500) := 'PAC_IAX_PROF.f_set_servicio';
      vparam         VARCHAR2(500)
                              := 'par퓅etros - starifa=' || starifa || ' tdescri: ' || tdescri;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_md_prof.f_set_tarifa(starifa, tdescri, mensajes);

      IF vnumerr != 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_set_tarifa;

   FUNCTION f_get_convenios(
      sprofes IN NUMBER,
      t_convenios OUT t_iax_prof_conve,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(500) := 'PAC_IAX_PROF.f_get_convenios';
      vparam         VARCHAR2(500) := 'par퓅etros - sprofes=' || sprofes;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_md_prof.f_get_convenios(sprofes, t_convenios, mensajes);
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_convenios;

   FUNCTION f_get_estados_convenio(psconven IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vobject        VARCHAR2(500) := 'PAC_IAX_PROF.f_get_estados_convenio';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vparam         VARCHAR2(500) := ' psconven= ' || psconven;
   BEGIN
      cur := pac_md_prof.f_get_estados_convenio(psconven, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_estados_convenio;

   FUNCTION f_set_estado_convenio(
      sconven IN NUMBER,
      cestado IN NUMBER,
      festado IN DATE,
      tobservaciones IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      /*************************************************************************
         Graba el estado del convenio del profesional
         param out mensajes : mesajes de error
         return             : number
      *************************************************************************/
      vobjectname    VARCHAR2(500) := 'PAC_IAX_PROF.f_set_estado_convenio';
      vparam         VARCHAR2(500) := 'par퓅etros - ';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_md_prof.f_set_estado_convenio(sconven, cestado, festado, tobservaciones,
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
   END f_set_estado_convenio;

   FUNCTION f_del_estado_convenio(
      sconven IN NUMBER,
      cestado IN NUMBER,
      festado IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(500) := 'PAC_IAX_PROF.f_del_estado_convenio';
      vparam         VARCHAR2(500)
         := 'par퓅etros - sconven=' || sconven || ' cestado: ' || cestado || ' festado: '
            || festado;
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(5) := 1;
   BEGIN
      vnumerr := pac_md_prof.f_del_estado_convenio(sconven, cestado, festado, mensajes);

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
   END f_del_estado_convenio;

   FUNCTION f_set_convenio(
      sconven IN NUMBER,
      sprofes IN NUMBER,
      starifa IN NUMBER,
      spersed IN NUMBER,
      ncomple IN NUMBER,
      npriorm IN NUMBER,
      tdescri IN VARCHAR2,
      pcvalor IN NUMBER,
      pctipo IN NUMBER,
      pnimporte IN NUMBER,
      pnporcent IN NUMBER,
      ptermino IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      /*************************************************************************
         Graba el convenio del profesional
         param out mensajes : mesajes de error
         return             : number
      *************************************************************************/
      vobjectname    VARCHAR2(500) := 'PAC_IAX_PROF.f_set_convenio';
      vparam         VARCHAR2(500)
         := 'par퓅etros - sconven: ' || sconven || 'sprofes: ' || sprofes || ' starifa: '
            || starifa || ' spersed: ' || spersed || ' ncomple: ' || ncomple || ' npriorm: '
            || npriorm || ' tdescri: ' || tdescri || ' pcvalor: ' || pcvalor || ' pctipo: '
            || pctipo || ' pnimporte: ' || pnimporte || ' pnporcert: ' || pnporcent
            || ' ptermino: ' || ptermino;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_md_prof.f_set_convenio(sconven, sprofes, starifa, spersed, ncomple,
                                            npriorm, tdescri, pcvalor, pctipo, pnimporte,
                                            pnporcent, ptermino, mensajes);

      IF vnumerr != 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         ROLLBACK;
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
   END f_set_convenio;

   FUNCTION f_get_tarifa(
      starifa IN NUMBER,
      tarifa OUT ob_iax_prof_tarifa,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(500) := 'PAC_IAX_PROF.f_get_tarifa';
      vparam         VARCHAR2(500) := 'par퓅etros - starifa=' || starifa;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_md_prof.f_get_tarifa(starifa, tarifa, mensajes);
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_tarifa;

   FUNCTION f_get_convenio(
      sconven IN NUMBER,
      convenio OUT ob_iax_prof_conve,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(500) := 'PAC_IAX_PROF.f_get_convenio';
      vparam         VARCHAR2(500) := 'par퓅etros - sconven=' || sconven;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_md_prof.f_get_convenio(sconven, convenio, mensajes);
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_convenio;

   FUNCTION f_actualiza_servicio(
      starifa IN NUMBER,
      sservic IN NUMBER,
      iprecio IN NUMBER,
      iminimo IN NUMBER,
      finivig IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(500) := 'PAC_IAX_PROF.f_actualiza_servicio';
      vparam         VARCHAR2(500)
         := 'par퓅etros - starifa=' || starifa || ' sservic: ' || sservic || ' iprecio: '
            || iprecio || ' iminimo: ' || iminimo || ' finivig: ' || finivig;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_md_prof.f_actualiza_servicio(starifa, sservic, iprecio, iminimo, finivig,
                                                  mensajes);

      IF vnumerr != 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_actualiza_servicio;

   FUNCTION f_copiar_tarifa(
      starifa_new IN NUMBER,
      starifa_sel IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(500) := 'PAC_IAX_PROF.f_copiar_tarifa';
      vparam         VARCHAR2(500)
               := 'par퓅etros - starifa_new=' || starifa_new || ' starifa_sel=' || starifa_sel;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_md_prof.f_copiar_tarifa(starifa_new, starifa_sel, mensajes);

      IF vnumerr != 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_copiar_tarifa;

   FUNCTION f_actualiza_servicios(
      starifa IN NUMBER,
      servicios IN VARCHAR2,
      cvalor IN NUMBER,
      ctipo IN NUMBER,
      nimporte IN NUMBER,
      nporcent IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(500) := 'PAC_IAX_PROF.f_actualiza_servicios';
      vparam         VARCHAR2(500)
         := 'par퓅etros - starifa=' || starifa || ' servicios=' || servicios || ' cvalor='
            || cvalor || ' ctipo=' || ctipo || ' nimporte=' || nimporte || ' nporcent='
            || nporcent;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_md_prof.f_actualiza_servicios(starifa, servicios, cvalor, ctipo,
                                                   nimporte, nporcent, mensajes);

      IF vnumerr != 0 THEN
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
   END f_actualiza_servicios;

   FUNCTION f_get_tipos_profesional(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100) := '';
      vobject        VARCHAR2(200) := 'PAC_IAX_PROF.f_get_tipos_profesional';
   BEGIN
      cur := pac_md_prof.f_get_tipos_profesional(mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_tipos_profesional;

   FUNCTION f_get_subtipos_profesional(pctipprof IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100) := '';
      vobject        VARCHAR2(200) := 'PAC_IAX_PROF.f_get_subtipos_profesional';
   BEGIN
      cur := pac_md_prof.f_get_subtipos_profesional(pctipprof, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_subtipos_profesional;

   FUNCTION f_get_tdescri_tarifa(pstarifa IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vobject        VARCHAR2(500) := 'PAC_IAX_PROF.f_get_tarifas';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vparam         VARCHAR2(500) := ' pstarifa= ' || pstarifa;
   BEGIN
      cur := pac_md_prof.f_get_tdescri_tarifa(pstarifa, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_tdescri_tarifa;

   FUNCTION f_get_tarifa_profesional(
      psprofes IN NUMBER,
      psconven IN NUMBER,
      pstarifa OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
/*************************************************************************
   Decide si una gestion se puede dar de alta
*************************************************************************/
      vobjectname    VARCHAR2(500) := 'PAC_IAX_PROF.f_get_tarifa_profesional';
      vparam         VARCHAR2(500) := 'par퓅etros - ';
      vpasexec       NUMBER(2) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_md_prof.f_get_tarifa_profesional(psprofes, psconven, pstarifa, mensajes);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam,
                                           vnumerr);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_get_tarifa_profesional;

   FUNCTION f_lstmagnitud(pctipcal IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
/*************************************************************************
   Devuelve el listado de calculos de precio
*************************************************************************/
      vobjectname    VARCHAR2(500) := 'PAC_IAX_PROF.f_lstmagnitud';
      vparam         VARCHAR2(500) := 'par퓅etros - pctipcal: ' || pctipcal;
      vpasexec       NUMBER(2) := 1;
      cur            sys_refcursor;
   BEGIN
      cur := pac_md_prof.f_lstmagnitud(pctipcal, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_lstmagnitud;

   FUNCTION f_lstterminos(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
/*************************************************************************
   Devuelve el listado de terminos
*************************************************************************/
      vobjectname    VARCHAR2(500) := 'PAC_IAX_PROF.f_lstterminos';
      vparam         VARCHAR2(500) := 'par퓅etros - ';
      vpasexec       NUMBER(2) := 1;
      cur            sys_refcursor;
   BEGIN
      cur := pac_md_prof.f_lstterminos(mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_lstterminos;

   --26630:NSS:09/07/2013
   FUNCTION f_set_convenio_temporal(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      psperson IN NUMBER,
      pnlocali IN NUMBER,
      pctippro IN NUMBER,
      pcsubpro IN NUMBER,
      pstarifa IN NUMBER,
      pnnumide IN VARCHAR2,
      ptnombre IN VARCHAR2,
      pcvalor IN NUMBER,
      pctipo IN NUMBER,
      pnimporte IN NUMBER,
      pnporcent IN NUMBER,
      ptermino IN VARCHAR2,
      ptemail IN VARCHAR2,
      pcagente IN NUMBER,
      psprofes OUT NUMBER,
      psconven OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      /*************************************************************************
         Graba el convenio temporal del profesional
         param out mensajes : mesajes de error
         return             : number
      *************************************************************************/
      vobjectname    VARCHAR2(500) := 'PAC_IAX_PROF.f_set_convenio_temporal';
      vparam         VARCHAR2(500)
         := 'par퓅etros - pnsinies: ' || pnsinies || 'pntramit: ' || pntramit || 'psperson: '
            || psperson || 'pnlocali: ' || pnlocali || 'pctippro: ' || pctippro
            || ' pcsubpro: ' || pcsubpro || ' pstarifa: ' || pstarifa || ' pnnumide: '
            || pnnumide || ' pnnumide: ' || pnnumide || ' ptnombre: ' || ptnombre
            || ' pcvalor: ' || pcvalor || ' pctipo: ' || pctipo || ' pnimporte: ' || pnimporte
            || ' pnporcert: ' || pnporcent || ' ptermino: ' || ptermino || ' ptemail: '
            || ptemail || ' pcagente: ' || pcagente;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_md_prof.f_set_convenio_temporal(pnsinies, pntramit, psperson, pnlocali,
                                                     pctippro, pcsubpro, pstarifa, pnnumide,
                                                     ptnombre, pcvalor, pctipo, pnimporte,
                                                     pnporcent, ptermino, ptemail, pcagente,
                                                     psprofes, psconven, mensajes);

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
   END f_set_convenio_temporal;
END pac_iax_prof;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_PROF" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_PROF" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_PROF" TO "PROGRAMADORESCSI";
