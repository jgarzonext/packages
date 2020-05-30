--------------------------------------------------------
--  DDL for Package Body PAC_MD_PROF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MD_PROF" AS
/******************************************************************************
   NOMBRE:    PAC_MD_PROF
   PROP풱ITO: Funciones para profesionales

   REVISIONES:
   Ver        Fecha        Autor             Descripci퓆
   ---------  ----------  ---------------  ------------------------------------
    1.0       08/11/2012   JDS             Creacion
******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   /*************************************************************************
      Abre un cursor con la sentencia suministrada
      param in squery    : consulta a executar
      param out mensajes : mesajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_opencursor(squery IN VARCHAR2, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(4000) := SUBSTR(squery, 1, 1900);
      vobject        VARCHAR2(200) := 'PAC_MD_PROF.F_OpenCursor';
      terror         VARCHAR2(200) := 'No se puede recuperar la informaci퓆';
   BEGIN
      OPEN cur FOR squery;

      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           terror, SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_opencursor;

    /*************************************************************************
      Devuelve cursos con las ccc de un profesional
      param in squery    : consulta a executar
      param out mensajes : mesajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstccc(psprofes IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'param psprofes=' || psprofes;
      vobject        VARCHAR2(200) := 'PAC_MD_PROF.F_GET_LSTCCC';
      terror         VARCHAR2(200) := ' Error a recuperar ccc de profesional';
      vquery         VARCHAR2(1000);
      vnerror        NUMBER;
   BEGIN
      vnerror := pac_prof.f_get_lstccc(psprofes, vquery);

      IF vnerror <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnerror);
         RAISE e_object_error;
      END IF;

      cur := f_opencursor(vquery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           terror, SQLCODE, SQLERRM);

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
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
/*************************************************************************
      Graba una cuenta cc para un profesional
      param out mensajes : mesajes de error
      return             : 0/1
*************************************************************************/
      vobjectname    VARCHAR2(500) := 'PAC_MD_PROF.F_SET_CCC';
      vparam         VARCHAR2(500) := 'par퓅etros - ';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_prof.f_ins_ccc(psprofes, pcramo, psproduc, pcactivi, pcnordban);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_set_ccc;

   FUNCTION f_get_dades_profesional(psprofes IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_profesional IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(3000) := 'PSPROFES=' || psprofes;
      vobject        VARCHAR2(200) := 'PAC_MD_PROF.f_get_dades_profesional';
      v_error        NUMBER;
      v_result       ob_iax_profesional;
   BEGIN
      vpasexec := 2;
      v_result := pac_prof.f_get_dades_profesional(psprofes, mensajes);
      vpasexec := 3;
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

   FUNCTION f_get_ccc(
      sprofes IN NUMBER,
      t_ccc OUT t_iax_prof_ccc,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(500) := 'PAC_MD_PROF.f_get_ccc';
      vparam         VARCHAR2(500) := 'par퓅etros - ';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      v_prof_ccc     ob_iax_prof_ccc := ob_iax_prof_ccc();
      cur            sys_refcursor;
      ptselect       VARCHAR2(5000);
   BEGIN
      vnumerr := pac_prof.f_get_ccc(sprofes, pac_md_common.f_get_cxtidioma(), ptselect);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      t_ccc := t_iax_prof_ccc();
      cur := pac_iax_listvalores.f_opencursor(ptselect, mensajes);
      v_prof_ccc.tactivi := 'tactivi';

      LOOP
         FETCH cur
          INTO v_prof_ccc.cnorden, v_prof_ccc.cramo, v_prof_ccc.tramo, v_prof_ccc.sproduc,
               v_prof_ccc.tproduc, v_prof_ccc.cactivi, v_prof_ccc.tactivi,
               v_prof_ccc.cnordban, v_prof_ccc.cbancar;

         EXIT WHEN cur%NOTFOUND;
         t_ccc.EXTEND;
         t_ccc(t_ccc.LAST) := v_prof_ccc;
         v_prof_ccc := ob_iax_prof_ccc();
         v_prof_ccc.tactivi := NULL;
      END LOOP;

      CLOSE cur;

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

   FUNCTION f_get_estados(
      sprofes IN NUMBER,
      t_estados OUT t_iax_prof_estados,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(500) := 'PAC_MD_PROF.f_get_estados';
      vparam         VARCHAR2(500) := 'par퓅etros - sprofes=' || sprofes;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      v_prof_estados ob_iax_prof_estados := ob_iax_prof_estados();
      cur            sys_refcursor;
      ptselect       VARCHAR2(5000);
      t_ccc          t_iax_prof_ccc;
   BEGIN
      vnumerr := pac_prof.f_get_estados(sprofes, pac_md_common.f_get_cxtidioma(), ptselect);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      t_estados := t_iax_prof_estados();
      cur := pac_iax_listvalores.f_opencursor(ptselect, mensajes);

      LOOP
         FETCH cur
          INTO v_prof_estados.cestado, v_prof_estados.testado, v_prof_estados.festado,
               v_prof_estados.cmotbaj, v_prof_estados.tmotbaj, v_prof_estados.tobserv,
               v_prof_estados.canulad, v_prof_estados.cusuari;

         EXIT WHEN cur%NOTFOUND;
         t_estados.EXTEND;
         t_estados(t_estados.LAST) := v_prof_estados;
         v_prof_estados := ob_iax_prof_estados();
      END LOOP;

      CLOSE cur;

      RETURN vnumerr;
   END f_get_estados;

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
      vobjectname    VARCHAR2(500) := 'PAC_MD_PROF.F_SET_ESTADO';
      vparam         VARCHAR2(500) := 'par퓅etros - ';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_prof.f_set_estado(sprofes, cestprf, festado, cmotbaja, tobservaciones);
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_set_estado;

   FUNCTION f_del_estado(sprofes IN NUMBER, festado IN DATE, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
/*************************************************************************
         Anula el estado del profesional
         param out mensajes : mesajes de error
         return             : number
*************************************************************************/
      vobjectname    VARCHAR2(500) := 'PAC_MD_PROF.F_DEL_ESTADO';
      vparam         VARCHAR2(500) := 'par퓅etros - ';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_prof.f_del_estado(sprofes, festado);
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_del_estado;

   FUNCTION f_del_ccc(sprofes IN NUMBER, cnorden IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
/*************************************************************************
         Elimina la cuenta del profesional
         param out mensajes : mesajes de error
         return             : number
*************************************************************************/
      vobjectname    VARCHAR2(500) := 'PAC_MD_PROF.F_DEL_CCC';
      vparam         VARCHAR2(500)
                              := 'par퓅etros - sprofes=' || sprofes || ' cnorden: ' || cnorden;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_prof.f_del_ccc(sprofes, cnorden);
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
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
      vobjectname    VARCHAR2(500) := 'PAC_MD_PROF.F_SET_ZONA';
      vparam         VARCHAR2(500) := 'par퓅etros - ';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_prof.f_set_zona(psprofes, pctpzona, pcpais, pcprovin, pcpoblac, pcposini,
                                     pcposfin, pfdesde, pfhasta);
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_set_zona;

   FUNCTION f_get_zonas(
      psprofes IN NUMBER,
      t_zonas OUT t_iax_prof_zonas,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(500) := 'PAC_MD_PROF.f_get_zonas';
      vparam         VARCHAR2(500) := 'par퓅etros - sprofes=' || psprofes;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      v_prof_zonas   ob_iax_prof_zonas := ob_iax_prof_zonas();
      cur            sys_refcursor;
      ptselect       VARCHAR2(5000);
   BEGIN
      vnumerr := pac_prof.f_get_zonas(psprofes, pac_md_common.f_get_cxtidioma(), ptselect);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      t_zonas := t_iax_prof_zonas();
      cur := pac_iax_listvalores.f_opencursor(ptselect, mensajes);

      LOOP
         FETCH cur
          INTO v_prof_zonas.cnordzn, v_prof_zonas.ctpzona, v_prof_zonas.ttpzona,
               v_prof_zonas.cpais, v_prof_zonas.tpais, v_prof_zonas.cprovin,
               v_prof_zonas.tprovin, v_prof_zonas.cpoblac, v_prof_zonas.tpoblac,
               v_prof_zonas.cposini, v_prof_zonas.cposfin, v_prof_zonas.fdesde,
               v_prof_zonas.fhasta;

         EXIT WHEN cur%NOTFOUND;
         t_zonas.EXTEND;
         t_zonas(t_zonas.LAST) := v_prof_zonas;
         v_prof_zonas := ob_iax_prof_zonas();
      END LOOP;

      CLOSE cur;

      RETURN vnumerr;
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
      vobjectname    VARCHAR2(500) := 'PAC_MD_PROF.F_MOD_ZONA';
      vparam         VARCHAR2(500) := 'par퓅etros - ';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_prof.f_mod_zona(psprofes, pcnordzn, pfhasta);
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
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
      vobjectname    VARCHAR2(500) := 'PAC_MD_PROF.F_SET_CONTACTO_PER';
      vparam         VARCHAR2(500) := 'par퓅etros - ';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_persona.f_validanif(nnumnif, ctipdoc, NULL, NULL);

      IF vnumerr = 0 THEN
         vnumerr := pac_prof.f_set_contacto_per(sprofes, ctipdoc, nnumnif, tnombre, tmovil,
                                                temail, tcargo, tdirecc);
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_set_contacto_per;

   FUNCTION f_get_contactos_per(
      sprofes IN NUMBER,
      t_contactos_per OUT t_iax_prof_contactos_per,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(500) := 'PAC_MD_PROF.f_get_contactos_per';
      vparam         VARCHAR2(500) := 'par퓅etros - sprofes=' || sprofes;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      v_prof_contactos_per ob_iax_prof_contactos_per := ob_iax_prof_contactos_per();
      cur            sys_refcursor;
      ptselect       VARCHAR2(5000);
   BEGIN
      vnumerr := pac_prof.f_get_contactos_per(sprofes, ptselect);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      t_contactos_per := t_iax_prof_contactos_per();
      cur := pac_iax_listvalores.f_opencursor(ptselect, mensajes);

      LOOP
         FETCH cur
          INTO v_prof_contactos_per.nordcto, v_prof_contactos_per.ctipide,
               v_prof_contactos_per.cnumide, v_prof_contactos_per.tnombre,
               v_prof_contactos_per.tmovil, v_prof_contactos_per.temail,
               v_prof_contactos_per.tcargo, v_prof_contactos_per.tdirec,
               v_prof_contactos_per.fbaja, v_prof_contactos_per.tusubaj;

         EXIT WHEN cur%NOTFOUND;
         t_contactos_per.EXTEND;
         t_contactos_per(t_contactos_per.LAST) := v_prof_contactos_per;
         v_prof_contactos_per := ob_iax_prof_contactos_per();
      END LOOP;

      CLOSE cur;

      RETURN vnumerr;
   END f_get_contactos_per;

   /*************************************************************************
      Devuelve cursor con los tipos de profesional
      param in squery    : consulta a executar
      param out mensajes : mesajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_ctipprof(psprofes IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'param psprofes=' || psprofes;
      vobject        VARCHAR2(200) := 'PAC_MD_PROF.F_GET_CTIPPROF';
      terror         VARCHAR2(200) := ' Error a recuperar tipos de profesional';
      vnerror        NUMBER;
      vquery         VARCHAR2(5000);
   BEGIN
      vnerror := pac_prof.f_get_ctipprof(psprofes, pac_md_common.f_get_cxtidioma(), vquery);

      IF vnerror <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnerror);
         RAISE e_object_error;
      END IF;

      cur := f_opencursor(vquery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           terror, SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_ctipprof;

   /*************************************************************************
      Devuelve cursor con los subtipos de profesional
      param in squery    : consulta a executar
      param out mensajes : mesajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_csubprof(psprofes IN NUMBER, pctipprof IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'param psprofes=' || psprofes;
      vobject        VARCHAR2(200) := 'PAC_MD_PROF.F_GET_CSUBPROF';
      terror         VARCHAR2(200) := ' Error a recuperar subtipos de profesional';
      vnerror        NUMBER;
      vquery         VARCHAR2(5000);
   BEGIN
      vnerror := pac_prof.f_get_csubprof(psprofes, pctipprof, pac_md_common.f_get_cxtidioma(),
                                         vquery);

      IF vnerror <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnerror);
         RAISE e_object_error;
      END IF;

      cur := f_opencursor(vquery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           terror, SQLCODE, SQLERRM);

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
      vobjectname    VARCHAR2(500) := 'PAC_MD_PROF.F_SET_CARGA';
      vparam         VARCHAR2(500) := 'par퓅etros - ';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_prof.f_valida_carga(sprofes, ctippro, csubpro, fdesde, 1);

      IF vnumerr = 0 THEN
         vnumerr := pac_prof.f_set_carga(sprofes, ctippro, csubpro, ncardia, ncarsem, fdesde);
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_set_carga;

   FUNCTION f_get_carga(
      sprofes IN NUMBER,
      t_carga OUT t_iax_prof_carga_permitida,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(500) := 'PAC_MD_PROF.f_get_carga';
      vparam         VARCHAR2(500) := 'par퓅etros - sprofes=' || sprofes;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      v_prof_carga_permitida ob_iax_prof_carga_permitida := ob_iax_prof_carga_permitida();
      cur            sys_refcursor;
      vtselect       VARCHAR2(5000);
   BEGIN
      vnumerr := pac_prof.f_get_carga(sprofes, pac_md_common.f_get_cxtidioma(), vtselect);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      t_carga := t_iax_prof_carga_permitida();
      cur := pac_iax_listvalores.f_opencursor(vtselect, mensajes);

      LOOP
         FETCH cur
          INTO v_prof_carga_permitida.ctippro, v_prof_carga_permitida.ttippro,
               v_prof_carga_permitida.csubpro, v_prof_carga_permitida.tsubpro,
               v_prof_carga_permitida.ncardia, v_prof_carga_permitida.ncarsem,
               v_prof_carga_permitida.ncarmes, v_prof_carga_permitida.fdesde;

         EXIT WHEN cur%NOTFOUND;
         t_carga.EXTEND;
         t_carga(t_carga.LAST) := v_prof_carga_permitida;
         v_prof_carga_permitida := ob_iax_prof_carga_permitida();
      END LOOP;

      CLOSE cur;

      RETURN vnumerr;
   END f_get_carga;

   FUNCTION f_del_carga(
      sprofes IN NUMBER,
      ctippro IN NUMBER,
      csubpro IN NUMBER,
      fdesde IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
/*************************************************************************
         Elimina la carga permitida del profesional
         param out mensajes : mesajes de error
         return             : number
*************************************************************************/
      vobjectname    VARCHAR2(500) := 'PAC_MD_PROF.F_DEL_CARGA';
      vparam         VARCHAR2(500)
         := 'par퓅etros - sprofes=' || sprofes || ' ctippro: ' || ctippro || ' csubpro: '
            || csubpro || ' fdesde: ' || fdesde;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_prof.f_del_carga(sprofes, ctippro, csubpro, fdesde);
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_del_carga;

   FUNCTION f_del_contacto_per(
      sprofes IN NUMBER,
      nordcto IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
/*************************************************************************
         Elimina la persona de contacto del profesional
         param out mensajes : mesajes de error
         return             : number
*************************************************************************/
      vobjectname    VARCHAR2(500) := 'PAC_MD_PROF.F_DEL_CONTACTO_PER';
      vparam         VARCHAR2(500)
                              := 'par퓅etros - sprofes=' || sprofes || ' nordcto: ' || nordcto;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_prof.f_del_contacto_per(sprofes, nordcto);
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
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
      vobjectname    VARCHAR2(500) := 'PAC_MD_PROF.F_MOD_CONTACTO_PER';
      vparam         VARCHAR2(500) := 'par퓅etros - ';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_prof.f_mod_contacto_per(sprofes, cnordcto, ctipdoc, nnumnif, tnombre,
                                             tmovil, temail, tcargo, tdirecc);
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
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
          /*************************************************************************
               Calcula la carga diaria y la semanal del profesional seg퓆 su capacidad
               param out mensajes : mesajes de error
               return             : number
      *************************************************************************/
      vobjectname    VARCHAR2(500) := 'PAC_MD_PROF.F_CALC_CARGA';
      vparam         VARCHAR2(500)
         := 'par퓅etros - sprofes=' || sprofes || ' ctippro: ' || ctippro || ' csubpro: '
            || csubpro || ' ncapaci: ' || ncapaci;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      cur            sys_refcursor;
      vquery         VARCHAR2(5000);
   BEGIN
      vnumerr := pac_prof.f_calc_carga(sprofes, ctippro, csubpro, ncapaci, fdesde, vquery);
      cur := f_opencursor(vquery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           vnumerr, SQLCODE, SQLERRM);

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
      vobjectname    VARCHAR2(500) := 'PAC_MD_PROF.F_SET_CARGA_REAL';
      vparam         VARCHAR2(500) := 'par퓅etros - ';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_prof.f_valida_carga(sprofes, ctippro, csubpro, fdesde, 2);

      IF vnumerr = 0 THEN
         vnumerr := pac_prof.f_set_carga_real(sprofes, ctippro, csubpro, ncapaci, ncardia,
                                              ncarsem, fdesde);
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_set_carga_real;

   FUNCTION f_get_carga_real(
      sprofes IN NUMBER,
      t_carga_real OUT t_iax_prof_carga_real,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(500) := 'PAC_MD_PROF.f_get_carga_real';
      vparam         VARCHAR2(500) := 'par퓅etros - sprofes=' || sprofes;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      v_prof_carga_real ob_iax_prof_carga_real := ob_iax_prof_carga_real();
      cur            sys_refcursor;
      vtselect       VARCHAR2(5000);
   BEGIN
      vnumerr := pac_prof.f_get_carga_real(sprofes, pac_md_common.f_get_cxtidioma(), vtselect);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      t_carga_real := t_iax_prof_carga_real();
      cur := pac_iax_listvalores.f_opencursor(vtselect, mensajes);

      LOOP
         FETCH cur
          INTO v_prof_carga_real.ctippro, v_prof_carga_real.ttippro,
               v_prof_carga_real.csubpro, v_prof_carga_real.tsubpro,
               v_prof_carga_real.ncapaci, v_prof_carga_real.ncardia,
               v_prof_carga_real.ncarsem, v_prof_carga_real.ncarmes, v_prof_carga_real.fdesde,
               v_prof_carga_real.cusuari;

         EXIT WHEN cur%NOTFOUND;
         t_carga_real.EXTEND;
         t_carga_real(t_carga_real.LAST) := v_prof_carga_real;
         v_prof_carga_real := ob_iax_prof_carga_real();
      END LOOP;

      CLOSE cur;

      RETURN vnumerr;
   END f_get_carga_real;

   FUNCTION f_del_carga_real(
      sprofes IN NUMBER,
      ctippro IN NUMBER,
      csubpro IN NUMBER,
      fdesde IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
/*************************************************************************
         Elimina la carga real del profesional
         param out mensajes : mesajes de error
         return             : number
*************************************************************************/
      vobjectname    VARCHAR2(500) := 'PAC_MD_PROF.F_DEL_CARGA_REAL';
      vparam         VARCHAR2(500)
         := 'par퓅etros - sprofes=' || sprofes || ' ctippro: ' || ctippro || ' csubpro: '
            || csubpro || ' fdesde: ' || fdesde;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_prof.f_del_carga_real(sprofes, ctippro, csubpro, fdesde);
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
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
      vobjectname    VARCHAR2(500) := 'PAC_MD_PROF.F_SET_DESCARTADO';
      vparam         VARCHAR2(500) := 'par퓅etros - ';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_prof.f_valida_descartado(sprofes, ctippro, csubpro, sproduc, ccausin,
                                              fdesde, fhasta);

      IF vnumerr = 0 THEN
         vnumerr := pac_prof.f_set_descartado(sprofes, ctippro, csubpro, sproduc, ccausin,
                                              fdesde, fhasta);
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_set_descartado;

   FUNCTION f_get_descartados(
      sprofes IN NUMBER,
      t_descartados OUT t_iax_prof_descartados,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(500) := 'PAC_MD_PROF.f_get_descartados';
      vparam         VARCHAR2(500) := 'par퓅etros - sprofes=' || sprofes;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      v_prof_descartados ob_iax_prof_descartados := ob_iax_prof_descartados();
      cur            sys_refcursor;
      vtexto         VARCHAR2(40);
      vtselect       VARCHAR2(5000);
   BEGIN
      vnumerr := pac_prof.f_get_descartados(sprofes, pac_md_common.f_get_cxtidioma(),
                                            vtselect);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      t_descartados := t_iax_prof_descartados();
      cur := pac_iax_listvalores.f_opencursor(vtselect, mensajes);

      LOOP
         FETCH cur
          INTO v_prof_descartados.ctippro, v_prof_descartados.ttippro,
               v_prof_descartados.csubpro, v_prof_descartados.tsubpro,
               v_prof_descartados.sproduc, v_prof_descartados.ccausin,
               v_prof_descartados.tcausin, v_prof_descartados.fdesde,
               v_prof_descartados.fhasta;

         EXIT WHEN cur%NOTFOUND;
         vnumerr := f_dessproduc(v_prof_descartados.sproduc, 1,
                                 pac_md_common.f_get_cxtidioma(), vtexto);
         v_prof_descartados.tproduc := vtexto;
         t_descartados.EXTEND;
         t_descartados(t_descartados.LAST) := v_prof_descartados;
         v_prof_descartados := ob_iax_prof_descartados();
      END LOOP;

      CLOSE cur;

      RETURN vnumerr;
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
      vobjectname    VARCHAR2(500) := 'PAC_MD_PROF.F_MOD_DESCARTADOS';
      vparam         VARCHAR2(500) := 'par퓅etros - ';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_prof.f_valida_descartado(sprofes, ctippro, csubpro, sproduc, ccausin,
                                              fdesde, fhasta);

      IF vnumerr = 0 THEN
         vnumerr := pac_prof.f_mod_descartados(sprofes, ctippro, csubpro, sproduc, ccausin,
                                               fdesde, fhasta);
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
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
      vobjectname    VARCHAR2(500) := 'PAC_MD_PROF.F_SET_OBSERVACIONES  ';
      vparam         VARCHAR2(500) := 'par퓅etros - ';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_prof.f_set_observaciones(sprofes, tobserv);
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_set_observaciones;

   FUNCTION f_get_observaciones(
      sprofes IN NUMBER,
      t_observaciones OUT t_iax_prof_observaciones,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(500) := 'PAC_MD_PROF.f_get_observaciones';
      vparam         VARCHAR2(500) := 'par퓅etros - sprofes=' || sprofes;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      v_prof_observaciones ob_iax_prof_observaciones := ob_iax_prof_observaciones();
      cur            sys_refcursor;
      vtselect       VARCHAR2(5000);
   BEGIN
      vnumerr := pac_prof.f_get_observaciones(sprofes, vtselect);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      t_observaciones := t_iax_prof_observaciones();
      cur := pac_iax_listvalores.f_opencursor(vtselect, mensajes);

      LOOP
         FETCH cur
          INTO v_prof_observaciones.cnordcm, v_prof_observaciones.tcoment,
               v_prof_observaciones.cusuari, v_prof_observaciones.falta;

         EXIT WHEN cur%NOTFOUND;
         t_observaciones.EXTEND;
         t_observaciones(t_observaciones.LAST) := v_prof_observaciones;
         v_prof_observaciones := ob_iax_prof_observaciones();
      END LOOP;

      CLOSE cur;

      RETURN vnumerr;
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
      vobjectname    VARCHAR2(500) := 'PAC_MD_PROF.F_SET_ROL  ';
      vparam         VARCHAR2(500) := 'par퓅etros - ';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_prof.f_set_rol(sprofes, ctippro, csubpro);
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_set_rol;

   FUNCTION f_get_roles(
      sprofes IN NUMBER,
      t_roles OUT t_iax_prof_roles,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(500) := 'PAC_MD_PROF.f_get_roles';
      vparam         VARCHAR2(500) := 'par퓅etros - sprofes=' || sprofes;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      v_prof_roles   ob_iax_prof_roles := ob_iax_prof_roles();
      cur            sys_refcursor;
      vtselect       VARCHAR2(5000);
   BEGIN
      vnumerr := pac_prof.f_get_roles(sprofes, pac_md_common.f_get_cxtidioma(), vtselect);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      t_roles := t_iax_prof_roles();
      cur := pac_iax_listvalores.f_opencursor(vtselect, mensajes);

      LOOP
         FETCH cur
          INTO v_prof_roles.ctippro, v_prof_roles.ttippro, v_prof_roles.csubpro,
               v_prof_roles.tsubpro;

         EXIT WHEN cur%NOTFOUND;
         t_roles.EXTEND;
         t_roles(t_roles.LAST) := v_prof_roles;
         v_prof_roles := ob_iax_prof_roles();
      END LOOP;

      CLOSE cur;

      RETURN vnumerr;
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
      vobjectname    VARCHAR2(500) := 'PAC_MD_PROF.F_SET_SEGUIMIENTO  ';
      vparam         VARCHAR2(500) := 'par퓅etros - ';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_prof.f_set_seguimiento(sprofes, tobserv, ccalific);
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_set_seguimiento;

   FUNCTION f_get_seguimiento(
      sprofes IN NUMBER,
      t_seguimiento OUT t_iax_prof_seguimiento,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(500) := 'PAC_MD_PROF.f_get_seguimiento';
      vparam         VARCHAR2(500) := 'par퓅etros - sprofes=' || sprofes;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      v_prof_seguimiento ob_iax_prof_seguimiento := ob_iax_prof_seguimiento();
      cur            sys_refcursor;
      vtselect       VARCHAR2(5000);
   BEGIN
      vnumerr := pac_prof.f_get_seguimiento(sprofes, pac_md_common.f_get_cxtidioma(),
                                            vtselect);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      t_seguimiento := t_iax_prof_seguimiento();
      cur := pac_iax_listvalores.f_opencursor(vtselect, mensajes);

      LOOP
         FETCH cur
          INTO v_prof_seguimiento.cnsegui, v_prof_seguimiento.cvalora,
               v_prof_seguimiento.tvalora, v_prof_seguimiento.tobserv,
               v_prof_seguimiento.cusuari, v_prof_seguimiento.falta;

         EXIT WHEN cur%NOTFOUND;
         t_seguimiento.EXTEND;
         t_seguimiento(t_seguimiento.LAST) := v_prof_seguimiento;
         v_prof_seguimiento := ob_iax_prof_seguimiento();
      END LOOP;

      CLOSE cur;

      RETURN vnumerr;
   END f_get_seguimiento;

   FUNCTION f_get_sprofes(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
/*************************************************************************
         Calcula el identificador del nuevo profesional
         param out mensajes : mesajes de error
         return             : number
*************************************************************************/
      vobjectname    VARCHAR2(500) := 'PAC_MD_PROF.F_GET_SPROFES';
      vparam         VARCHAR2(500) := 'par퓅etros - =';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      cur            sys_refcursor;
      vquery         VARCHAR2(5000);
   BEGIN
      vnumerr := pac_prof.f_get_sprofes(vquery);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      cur := f_opencursor(vquery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           vnumerr, SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_sprofes;

   FUNCTION f_get_lsttelefonos(sperson IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
/*************************************************************************
         Devuelve la lista de telefonos que pueden ser contacto del profesional
*************************************************************************/
      vobjectname    VARCHAR2(500) := 'PAC_MD_PROF.F_GET_LSTTELEFONOS';
      vparam         VARCHAR2(500) := 'par퓅etros - =';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      cur            sys_refcursor;
      vquery         VARCHAR2(5000);
   BEGIN
      vnumerr := pac_prof.f_get_lsttelefonos(sperson, vquery);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      cur := f_opencursor(vquery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           vnumerr, SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lsttelefonos;

   FUNCTION f_get_lstemail(sperson IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
/*************************************************************************
         Devuelve la lista de emails que pueden ser contacto del profesional
*************************************************************************/
      vobjectname    VARCHAR2(500) := 'PAC_MD_PROF.F_GET_LSTEMAIL';
      vparam         VARCHAR2(500) := 'par퓅etros - =';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      cur            sys_refcursor;
      vquery         VARCHAR2(5000);
   BEGIN
      vnumerr := pac_prof.f_get_lstemail(sperson, vquery);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      cur := f_opencursor(vquery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           vnumerr, SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstemail;

   FUNCTION f_set_profesional(
      sprofes IN NUMBER,
      vobprofesional IN ob_iax_profesional,
      pcmodo IN NUMBER,
      ptexto OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
/*************************************************************************
         Graba el profesional
         param out mensajes : mesajes de error
         return             : number
*************************************************************************/
      vobjectname    VARCHAR2(500) := 'PAC_MD_PROF.F_SET_PROFESIONAL  ';
      vparam         VARCHAR2(500) := 'par퓅etros - ';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_prof.f_set_profesional(sprofes, vobprofesional.sperson,
                                            vobprofesional.nregmer, vobprofesional.fregmer,
                                            vobprofesional.cdomici, vobprofesional.cmodcon,
                                            vobprofesional.ttelcli, vobprofesional.nlimite,
                                            vobprofesional.cnoasis, pcmodo, NULL,   --26630
                                            ptexto);
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
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
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
/************************************************************************************
         Devuelve la lista de profesionales que coinciden con los parametro indicados
************************************************************************************/
      vobjectname    VARCHAR2(500) := 'PAC_MD_PROF.F_GET_PROFESIONALES';
      vparam         VARCHAR2(500)
         := ' pctipide= ' || pctipide || ' pnnumide= ' || pnnumide || ' ptnombre=' || ptnombre
            || ' pctippro=' || pctippro || ' pcsubpro= ' || pcsubpro || ' psprofes= '
            || psprofes|| ' pcprovin=' || pcprovin || ' pcpoblac=' || pcpoblac;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      cur            sys_refcursor;
      vquery         VARCHAR2(5000);
   BEGIN
      vnumerr := pac_prof.f_get_profesionales(pctipide, pnnumide, ptnombre, pctippro,
                                              pcsubpro, psprofes,
                                              pac_md_common.f_get_cxtidioma(),
                                              pcprovin, pcpoblac, vquery);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      cur := f_opencursor(vquery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           vnumerr, SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_profesionales;

   FUNCTION f_get_profesional(
      psprofes IN NUMBER,
      obprof OUT ob_iax_profesional,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(500) := 'PAC_MD_PROF.f_get_profesional';
      vparam         VARCHAR2(500) := 'par퓅etros - sprofes=' || psprofes;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      cur            sys_refcursor;
      vtselect       VARCHAR2(5000);
   BEGIN
      vnumerr := pac_prof.f_get_profesional(psprofes, pac_md_common.f_get_cxtidioma(),
                                            vtselect);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      cur := pac_iax_listvalores.f_opencursor(vtselect, mensajes);
      obprof := ob_iax_profesional();

      LOOP
         FETCH cur
          INTO obprof.sprofes, obprof.sperson, obprof.ctipide, obprof.nnumide, obprof.tnombre,
               obprof.nregmer, obprof.fregmer, obprof.cdomici, obprof.tdomici, obprof.cmodcon,
               obprof.ttelcli, obprof.nlimite, obprof.cnoasis, obprof.ctipper, obprof.ttipide;

         EXIT WHEN cur%NOTFOUND;
      END LOOP;

      CLOSE cur;

      RETURN vnumerr;
   END f_get_profesional;

   FUNCTION f_get_ctipprof_carga_real(sprofes IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'param psprofes=' || sprofes;
      vobject        VARCHAR2(200) := 'PAC_MD_PROF.F_GET_CTIPPROf_carga_real';
      terror         VARCHAR2(200) := ' Error a recuperar tipos de profesional';
      vnerror        NUMBER;
      vquery         VARCHAR2(5000);
   BEGIN
      vnerror := pac_prof.f_get_ctipprof_carga_real(sprofes, pac_md_common.f_get_cxtidioma(),
                                                    vquery);

      IF vnerror <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnerror);
         RAISE e_object_error;
      END IF;

      cur := f_opencursor(vquery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           terror, SQLCODE, SQLERRM);

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
      vparam         VARCHAR2(500) := 'param psprofes=' || sprofes;
      vobject        VARCHAR2(200) := 'PAC_MD_PROF.F_GET_CSUBPROF_CARGA_REAL';
      terror         VARCHAR2(200) := ' Error a recuperar subtipos de profesional';
      vnerror        NUMBER;
      vquery         VARCHAR2(5000);
   BEGIN
      vnerror := pac_prof.f_get_csubprof_carga_real(sprofes, ctipprof,
                                                    pac_md_common.f_get_cxtidioma(), vquery);

      IF vnerror <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnerror);
         RAISE e_object_error;
      END IF;

      cur := f_opencursor(vquery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           terror, SQLCODE, SQLERRM);

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
/*************************************************************************
         Anula el rol del profesional
         param out mensajes : mesajes de error
         return             : number
*************************************************************************/
      vobjectname    VARCHAR2(500) := 'PAC_MD_PROF.F_DEL_ROL';
      vparam         VARCHAR2(500) := 'par퓅etros - ';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_prof.f_del_rol(sprofes, ctippro, csubpro);
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_del_rol;

   FUNCTION f_get_contactos(
      sprofes IN NUMBER,
      t_contactos OUT t_iax_prof_contactos,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(500) := 'PAC_MD_PROF.f_get_contactos';
      vparam         VARCHAR2(500) := 'par퓅etros - sprofes=' || sprofes;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      v_prof_contactos ob_iax_prof_contactos := ob_iax_prof_contactos();
      cur            sys_refcursor;
      vtselect       VARCHAR2(5000);
   BEGIN
      vnumerr := pac_prof.f_get_contactos(sprofes, pac_md_common.f_get_cxtidioma(), vtselect);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      t_contactos := t_iax_prof_contactos();
      cur := pac_iax_listvalores.f_opencursor(vtselect, mensajes);

      LOOP
         FETCH cur
          INTO v_prof_contactos.cprefer, v_prof_contactos.cmodcon, v_prof_contactos.ctipcon,
               v_prof_contactos.ttipcon, v_prof_contactos.tvalcon;

         EXIT WHEN cur%NOTFOUND;
         t_contactos.EXTEND;
         t_contactos(t_contactos.LAST) := v_prof_contactos;
         v_prof_contactos := ob_iax_prof_contactos();
      END LOOP;

      CLOSE cur;

      RETURN vnumerr;
   END f_get_contactos;

   FUNCTION f_set_contacto_pref(
      sprofes IN NUMBER,
      cmodcon IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
/*************************************************************************
         Graba el contacto preferente del profesional
         param out mensajes : mesajes de error
         return             : number
*************************************************************************/
      vobjectname    VARCHAR2(500) := 'PAC_MD_PROF.F_SET_CONTACTO_PREF  ';
      vparam         VARCHAR2(500) := 'par퓅etros - ';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_prof.f_set_contacto_pref(sprofes, cmodcon);
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_set_contacto_pref;

   FUNCTION f_get_documentos(
      sprofes IN NUMBER,
      t_docs OUT t_iax_prof_documentacion,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(500) := 'PAC_MD_PROF.f_get_documentos';
      vparam         VARCHAR2(500) := 'par퓅etros - sprofes=' || sprofes;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      v_prof_documentacion ob_iax_prof_documentacion := ob_iax_prof_documentacion();
      cur            sys_refcursor;
      vtselect       VARCHAR2(5000);
   BEGIN
      vnumerr := pac_prof.f_get_documentos(sprofes, pac_md_common.f_get_cxtidioma(), vtselect);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      t_docs := t_iax_prof_documentacion();
      cur := pac_iax_listvalores.f_opencursor(vtselect, mensajes);

      LOOP
         FETCH cur
          INTO v_prof_documentacion.norddoc, v_prof_documentacion.iddocgx,
               v_prof_documentacion.tdescri, v_prof_documentacion.cusualt,
               v_prof_documentacion.falta, v_prof_documentacion.fcaduca,
               v_prof_documentacion.tobserva;

         EXIT WHEN cur%NOTFOUND;
         v_prof_documentacion.idcat :=
                                      pac_axisgedox.f_get_catdoc(v_prof_documentacion.iddocgx);
         v_prof_documentacion.ttitdoc :=
                                     pac_axisgedox.f_get_filedoc(v_prof_documentacion.iddocgx);
         t_docs.EXTEND;
         t_docs(t_docs.LAST) := v_prof_documentacion;
         v_prof_documentacion := ob_iax_prof_documentacion();
      END LOOP;

      CLOSE cur;

      RETURN vnumerr;
   END f_get_documentos;

   /*************************************************************************
     Funcion que inserta o actualiza los datos de un documento asociado a la persona
    *************************************************************************/
   FUNCTION f_set_documentacion(
      psprofes IN NUMBER,
      pfcaduca IN DATE,
      ptobserva IN VARCHAR2,
      piddocgedox IN NUMBER,
      ptdesc IN VARCHAR2 DEFAULT NULL,
      ptfilename IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'parametros - psprofes: ' || psprofes || ' - pfcaduca: '
            || TO_CHAR(pfcaduca, 'DD/MM/YYYY') || ' - ptobserva: ' || ptobserva
            || ' - piddocgedox: ' || piddocgedox || ' - ptdesc: ' || ptdesc
            || ' - ptfilename: ' || ptfilename;
      vobject        VARCHAR2(200) := 'PAC_MD_PROF.f_set_documentacion';
   BEGIN
      IF psprofes IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_prof.f_set_documentacion(psprofes, pfcaduca, ptobserva, piddocgedox,
                                              ptdesc);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_set_documentacion;

   FUNCTION f_get_sedes(
      sprofes IN NUMBER,
      t_sedes OUT t_iax_prof_sedes,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(500) := 'PAC_MD_PROF.f_get_sedes';
      vparam         VARCHAR2(500) := 'par퓅etros - sprofes=' || sprofes;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      v_prof_sedes   ob_iax_prof_sedes := ob_iax_prof_sedes();
      cur            sys_refcursor;
      vtselect       VARCHAR2(5000);
   BEGIN
      vnumerr := pac_prof.f_get_sedes(sprofes, pac_md_common.f_get_cxtidioma(), vtselect);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      t_sedes := t_iax_prof_sedes();
      cur := pac_iax_listvalores.f_opencursor(vtselect, mensajes);

      LOOP
         FETCH cur
          INTO v_prof_sedes.spersed, v_prof_sedes.tnombre, v_prof_sedes.cdomici,
               v_prof_sedes.tdomici, v_prof_sedes.tpercto, v_prof_sedes.thorari;

         EXIT WHEN cur%NOTFOUND;
         t_sedes.EXTEND;
         t_sedes(t_sedes.LAST) := v_prof_sedes;
         v_prof_sedes := ob_iax_prof_sedes();
      END LOOP;

      CLOSE cur;

      RETURN vnumerr;
   END f_get_sedes;

   FUNCTION f_set_sede(
      sprofes IN NUMBER,
      spersed IN NUMBER,
      thorari IN VARCHAR2,
      tpercto IN VARCHAR2,
      cdomici IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
/*************************************************************************
         Graba los datos de la sede del profesional
         param out mensajes : mesajes de error
         return             : number
*************************************************************************/
      vobjectname    VARCHAR2(500) := 'PAC_MD_PROF.F_SET_SEDE  ';
      vparam         VARCHAR2(500) := 'par퓅etros - ';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_prof.f_set_sede(sprofes, spersed, thorari, tpercto, cdomici);
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_set_sede;

   FUNCTION f_get_representantes(
      sprofes IN NUMBER,
      t_representantes OUT t_iax_prof_repre,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(500) := 'PAC_MD_PROF.f_get_representantes';
      vparam         VARCHAR2(500) := 'par퓅etros - sprofes=' || sprofes;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      v_prof_repre   ob_iax_prof_repre := ob_iax_prof_repre();
      cur            sys_refcursor;
      vtselect       VARCHAR2(5000);
   BEGIN
      vnumerr := pac_prof.f_get_representantes(sprofes, pac_md_common.f_get_cxtidioma(),
                                               vtselect);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      t_representantes := t_iax_prof_repre();
      cur := pac_iax_listvalores.f_opencursor(vtselect, mensajes);

      LOOP
         FETCH cur
          INTO v_prof_repre.tnif, v_prof_repre.sperson, v_prof_repre.tnombre,
               v_prof_repre.cmailcon, v_prof_repre.tmailcon, v_prof_repre.ctelcon,
               v_prof_repre.ttelcon, v_prof_repre.tcargo;

         EXIT WHEN cur%NOTFOUND;
         t_representantes.EXTEND;
         t_representantes(t_representantes.LAST) := v_prof_repre;
         v_prof_repre := ob_iax_prof_repre();
      END LOOP;

      CLOSE cur;

      RETURN vnumerr;
   END f_get_representantes;

   FUNCTION f_set_representante(
      sprofes IN NUMBER,
      sperson IN NUMBER,
      nmovil IN NUMBER,
      temail IN NUMBER,
      tcargo IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
/*************************************************************************
         Graba los datos del representante legal del profesional
         param out mensajes : mesajes de error
         return             : number
*************************************************************************/
      vobjectname    VARCHAR2(500) := 'PAC_MD_PROF.F_SET_REPRESENTANTE';
      vparam         VARCHAR2(500) := 'par퓅etros - ';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_prof.f_set_representante(sprofes, sperson, nmovil, temail, tcargo);
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_set_representante;

   FUNCTION f_get_sservic(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'param =';
      vobject        VARCHAR2(200) := 'PAC_MD_PROF.F_GET_SSERVIC';
      terror         VARCHAR2(200) := ' Error a recuperar codigo servicio';
      vnerror        NUMBER;
      vquery         VARCHAR2(5000);
   BEGIN
      vnerror := pac_prof.f_get_sservic(vquery);

      IF vnerror <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnerror);
         RAISE e_object_error;
      END IF;

      cur := f_opencursor(vquery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           terror, SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_sservic;

   FUNCTION f_get_lstcups(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'param =';
      vobject        VARCHAR2(200) := 'PAC_MD_PROF.F_GET_LSTCUPS';
      terror         VARCHAR2(200) := ' Error a recuperar cups';
      vnerror        NUMBER;
      vquery         VARCHAR2(5000);
   BEGIN
      vnerror := pac_prof.f_get_lstcups(vquery);

      IF vnerror <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnerror);
         RAISE e_object_error;
      END IF;

      cur := f_opencursor(vquery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           terror, SQLCODE, SQLERRM);

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
/*************************************************************************
         Graba los datos del servicio
         param out mensajes : mesajes de error
         return             : number
*************************************************************************/
      vobjectname    VARCHAR2(500) := 'PAC_MD_PROF.F_SET_SERVICIO';
      vparam         VARCHAR2(500) := 'par퓅etros - ';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_prof.f_set_servicio(starifa, sservic, ccodcup, tdescri, cunimed, iprecio,
                                         ctipcal, cmagnit, iminimo, cselecc, ctipser, finivig,
                                         ffinvig);
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_set_servicio;

   FUNCTION f_get_servicios(
      starifa IN NUMBER,
      sservic IN NUMBER,
      tdescri IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vobject        VARCHAR2(500) := 'PAC_MD_PROF.f_get_servicios';
      vparam         VARCHAR2(500) := 'par퓅etros - starifa=' || starifa;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      cur            sys_refcursor;
      vtselect       VARCHAR2(5000);
   BEGIN
      vnumerr := pac_prof.f_get_servicios(starifa, sservic, tdescri,
                                          pac_md_common.f_get_cxtidioma(), vtselect);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      cur := f_opencursor(vtselect, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           vnumerr, SQLCODE, SQLERRM);

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
      vobject        VARCHAR2(500) := 'PAC_MD_PROF.f_get_servicio';
      vparam         VARCHAR2(500) := 'par퓅etros - starifa=' || starifa;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      cur            sys_refcursor;
      vtselect       VARCHAR2(5000);
   BEGIN
      vnumerr := pac_prof.f_get_servicio(starifa, sservic, pac_md_common.f_get_cxtidioma(),
                                         vtselect);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      servicio := ob_iax_prof_servi();
      cur := pac_iax_listvalores.f_opencursor(vtselect, mensajes);

      LOOP
         FETCH cur
          INTO servicio.sservic, servicio.ccodcup, servicio.tdescri, servicio.cunimed,
               servicio.iprecio, servicio.cmagnit, servicio.iminimo, servicio.cselecc,
               servicio.ctipser, servicio.finivig, servicio.ffinvig, servicio.ctipcal;

         EXIT WHEN cur%NOTFOUND;
      END LOOP;

      CLOSE cur;

      RETURN vnumerr;
   END f_get_servicio;

   FUNCTION f_get_tarifas(
      pstarifa IN NUMBER,
      ptdescri IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
/************************************************************************************
         Devuelve la lista de tarifas que coinciden con los parametro indicados
************************************************************************************/
      vobjectname    VARCHAR2(500) := 'PAC_MD_PROF.F_GET_TARIFAS';
      vparam         VARCHAR2(500) := ' pstarifa= ' || pstarifa || ' ptdescri= ' || ptdescri;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      cur            sys_refcursor;
      vquery         VARCHAR2(5000);
   BEGIN
      vnumerr := pac_prof.f_get_tarifas(pstarifa, ptdescri, vquery);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      cur := f_opencursor(vquery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           vnumerr, SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_tarifas;

   FUNCTION f_get_starifa(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'param =';
      vobject        VARCHAR2(200) := 'PAC_MD_PROF.F_GET_STARIFA';
      terror         VARCHAR2(200) := ' Error a recuperar codigo tarifa';
      vnerror        NUMBER;
      vquery         VARCHAR2(5000);
   BEGIN
      vnerror := pac_prof.f_get_starifa(vquery);

      IF vnerror <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnerror);
         RAISE e_object_error;
      END IF;

      cur := f_opencursor(vquery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           terror, SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_starifa;

   FUNCTION f_set_tarifa(starifa IN NUMBER, tdescri IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
/*************************************************************************
         Graba los datos de la tarifa
         param out mensajes : mesajes de error
         return             : number
*************************************************************************/
      vobjectname    VARCHAR2(500) := 'PAC_MD_PROF.F_SET_TARIFA';
      vparam         VARCHAR2(500) := 'par퓅etros - ';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_prof.f_set_tarifa(starifa, tdescri);
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_set_tarifa;

   FUNCTION f_get_convenios(
      sprofes IN NUMBER,
      t_convenios OUT t_iax_prof_conve,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(500) := 'PAC_MD_PROF.f_get_convenios';
      vparam         VARCHAR2(500) := 'par퓅etros - sprofes=' || sprofes;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      v_prof_conve   ob_iax_prof_conve := ob_iax_prof_conve();
      cur            sys_refcursor;
      vtselect       VARCHAR2(5000);
   BEGIN
      vnumerr := pac_prof.f_get_convenios(sprofes, pac_md_common.f_get_cxtidioma(), vtselect);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      t_convenios := t_iax_prof_conve();
      cur := pac_iax_listvalores.f_opencursor(vtselect, mensajes);

      LOOP
         FETCH cur
          INTO v_prof_conve.sconven, v_prof_conve.tdescri, v_prof_conve.starifa,
               v_prof_conve.ttarifa, v_prof_conve.spersed, v_prof_conve.tpersed,
               v_prof_conve.ncomple, v_prof_conve.npriorm, v_prof_conve.cestado,
               v_prof_conve.testado, v_prof_conve.festado;

         EXIT WHEN cur%NOTFOUND;
         t_convenios.EXTEND;
         t_convenios(t_convenios.LAST) := v_prof_conve;
         v_prof_conve := ob_iax_prof_conve();
      END LOOP;

      CLOSE cur;

      RETURN vnumerr;
   END f_get_convenios;

   FUNCTION f_get_estados_convenio(psconven IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
/************************************************************************************
         Devuelve los estados del convenio
************************************************************************************/
      vobjectname    VARCHAR2(500) := 'PAC_MD_PROF.F_GET_ESTADOS_CONVENIO';
      vparam         VARCHAR2(500) := ' psconven= ' || psconven;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      cur            sys_refcursor;
      vquery         VARCHAR2(5000);
   BEGIN
      vnumerr := pac_prof.f_get_estados_convenio(psconven, pac_md_common.f_get_cxtidioma(),
                                                 vquery);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      cur := f_opencursor(vquery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           vnumerr, SQLCODE, SQLERRM);

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
      vobjectname    VARCHAR2(500) := 'PAC_MD_PROF.F_SET_ESTADO_CONVENIO';
      vparam         VARCHAR2(500) := 'par퓅etros - ';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_prof.f_set_estado_convenio(sconven, cestado, festado, tobservaciones);
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_set_estado_convenio;

   FUNCTION f_del_estado_convenio(
      sconven IN NUMBER,
      cestado IN NUMBER,
      festado IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
/*************************************************************************
         Anula el estado del convenio del profesional
         param out mensajes : mesajes de error
         return             : number
*************************************************************************/
      vobjectname    VARCHAR2(500) := 'PAC_MD_PROF.F_DEL_ESTADO_CONVENIO';
      vparam         VARCHAR2(500) := 'par퓅etros - ';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_prof.f_del_estado_convenio(sconven, cestado, festado);
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
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
      vobjectname    VARCHAR2(500) := 'PAC_MD_PROF.F_SET_CONVENIO';
      vparam         VARCHAR2(500) := 'par퓅etros - ';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_prof.f_set_convenio(sconven, sprofes, starifa, spersed, ncomple, npriorm,
                                         tdescri, pcvalor, pctipo, pnimporte, pnporcent,
                                         ptermino);
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_set_convenio;

   FUNCTION f_get_tarifa(
      starifa IN NUMBER,
      tarifa OUT ob_iax_prof_tarifa,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(500) := 'PAC_MD_PROF.f_get_tarifa';
      vparam         VARCHAR2(500) := 'par퓅etros - starifa=' || starifa;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      cur            sys_refcursor;
      vtselect       VARCHAR2(5000);
   BEGIN
      vnumerr := pac_prof.f_get_tarifa(starifa, pac_md_common.f_get_cxtidioma(), vtselect);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      tarifa := ob_iax_prof_tarifa();
      cur := pac_iax_listvalores.f_opencursor(vtselect, mensajes);

      LOOP
         FETCH cur
          INTO tarifa.starifa, tarifa.tdescri;

         EXIT WHEN cur%NOTFOUND;
      END LOOP;

      CLOSE cur;

      RETURN vnumerr;
   END f_get_tarifa;

   FUNCTION f_get_convenio(
      sconven IN NUMBER,
      convenio OUT ob_iax_prof_conve,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(500) := 'PAC_MD_PROF.f_get_convenio';
      vparam         VARCHAR2(500) := 'par퓅etros - sconven=' || sconven;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      cur            sys_refcursor;
      vtselect       VARCHAR2(5000);
   BEGIN
      vnumerr := pac_prof.f_get_convenio(sconven, pac_md_common.f_get_cxtidioma(), vtselect);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      convenio := ob_iax_prof_conve();
      cur := pac_iax_listvalores.f_opencursor(vtselect, mensajes);

      LOOP
         FETCH cur
          INTO convenio.sconven, convenio.tdescri, convenio.starifa, convenio.ttarifa,
               convenio.spersed, convenio.ncomple, convenio.npriorm, convenio.cvalor,
               convenio.ctipo, convenio.nimporte, convenio.nporcent, convenio.termino;

         EXIT WHEN cur%NOTFOUND;
      END LOOP;

      CLOSE cur;

      RETURN vnumerr;
   END f_get_convenio;

   FUNCTION f_actualiza_servicio(
      starifa IN NUMBER,
      sservic IN NUMBER,
      iprecio IN NUMBER,
      iminimo IN NUMBER,
      finivig IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
/*************************************************************************
         Actualiza el servicio cerrando el registro que hab풹 con la fecha inicial marcada como nueva
         y genera un nuevo registro copiando datos y con los indicados
         param out mensajes : mesajes de error
         return             : number
*************************************************************************/
      vobjectname    VARCHAR2(500) := 'PAC_MD_PROF.F_ACTUALIZA_SERVICIO';
      vparam         VARCHAR2(500) := 'par퓅etros - ';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_prof.f_actualiza_servicio(starifa, sservic, iprecio, iminimo, finivig);
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_actualiza_servicio;

   FUNCTION f_copiar_tarifa(
      starifa_new IN NUMBER,
      starifa_sel IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
/*************************************************************************
         Copia los servicios de la tarifa seleccionada a la nueva tarifa
         param out mensajes : mesajes de error
         return             : number
*************************************************************************/
      vobjectname    VARCHAR2(500) := 'PAC_MD_PROF.F_COPIAR_TARIFA';
      vparam         VARCHAR2(500) := 'par퓅etros - ';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vservicio      ob_iax_prof_servi;
      vtselect       VARCHAR2(5000);
      cur            sys_refcursor;
   BEGIN
      vnumerr := pac_prof.f_get_tarifa_a_copiar(starifa_sel, vtselect);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      vservicio := ob_iax_prof_servi();
      cur := pac_iax_listvalores.f_opencursor(vtselect, mensajes);

      LOOP
         FETCH cur
          INTO vservicio.tdescri, vservicio.cunimed, vservicio.iprecio, vservicio.cmagnit,
               vservicio.iminimo, vservicio.finivig, vservicio.ffinvig, vservicio.ctipser,
               vservicio.ccodcup, vservicio.cselecc;

         vnumerr := pac_prof.f_copiar_tarifa(starifa_new, vservicio.tdescri,
                                             vservicio.cunimed, vservicio.iprecio,
                                             vservicio.cmagnit, vservicio.iminimo,
                                             vservicio.finivig, vservicio.ffinvig,
                                             vservicio.ctipser, vservicio.ccodcup,
                                             vservicio.cselecc);
         vservicio := ob_iax_prof_servi();
         EXIT WHEN cur%NOTFOUND;
      END LOOP;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
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
/**************************************************************************************
         Actualiza masivamente los servicios seleccionados incrementando o disminuyendo
         su precio en el porcentaje o importe indicando
         param out mensajes : mesajes de error
         return             : number
***************************************************************************************/
      vobjectname    VARCHAR2(500) := 'PAC_MD_PROF.F_ACTUALIZA_SERVICIOS';
      vparam         VARCHAR2(500) := 'par퓅etros - ';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_prof.f_actualiza_servicios(starifa, servicios, cvalor, ctipo, nimporte,
                                                nporcent, mensajes);
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_actualiza_servicios;

   FUNCTION f_get_tipos_profesional(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
/************************************************************************************
         Devuelve los tipos de profesional
************************************************************************************/
      vobjectname    VARCHAR2(500) := 'PAC_MD_PROF.f_get_tipos_profesional';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vparam         NUMBER(5) := 1;
      cur            sys_refcursor;
      vquery         VARCHAR2(5000);
   BEGIN
      vnumerr := pac_prof.f_get_tipos_profesional(pac_md_common.f_get_cxtidioma(), vquery);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      cur := f_opencursor(vquery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           vnumerr, SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_tipos_profesional;

   FUNCTION f_get_subtipos_profesional(pctipprof IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
/************************************************************************************
         Devuelve los subtipos de profesional
************************************************************************************/
      vobjectname    VARCHAR2(500) := 'PAC_MD_PROF.f_get_subtipos_profesional';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vparam         NUMBER(5) := 1;
      cur            sys_refcursor;
      vquery         VARCHAR2(5000);
   BEGIN
      vnumerr := pac_prof.f_get_subtipos_profesional(pctipprof,
                                                     pac_md_common.f_get_cxtidioma(), vquery);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      cur := f_opencursor(vquery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           vnumerr, SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_subtipos_profesional;

   FUNCTION f_get_tdescri_tarifa(pstarifa IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
/************************************************************************************
         Devuelve el nombre de la tarifa
************************************************************************************/
      vobjectname    VARCHAR2(500) := 'PAC_MD_PROF.f_get_tdescri_tarifa';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vparam         NUMBER(5) := 1;
      cur            sys_refcursor;
      vquery         VARCHAR2(5000);
   BEGIN
      vnumerr := pac_prof.f_get_tdescri_tarifa(pstarifa, pac_md_common.f_get_cxtidioma(),
                                               vquery);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      cur := f_opencursor(vquery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           vnumerr, SQLCODE, SQLERRM);

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
      vobjectname    VARCHAR2(500) := 'PAC_MD_PROF.f_get_tarifa_profesional';
      vparam         VARCHAR2(500) := ' par퓅etros - ';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vcidioma       NUMBER;
   BEGIN
      vnumerr := pac_prof.f_get_tarifa_profesional(psprofes, psconven, pstarifa);

      IF vnumerr <> 0 THEN
         RETURN vnumerr;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_get_tarifa_profesional;

   FUNCTION f_lstmagnitud(pctipcal IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
/************************************************************************************
         Devuelve el nombre de la tarifa
************************************************************************************/
      vobjectname    VARCHAR2(500) := 'PAC_MD_PROF.f_lstmagnitud';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vparam         NUMBER(5) := 1;
      cur            sys_refcursor;
      vquery         VARCHAR2(5000);
   BEGIN
      vnumerr := pac_prof.f_lstmagnitud(pctipcal, pac_md_common.f_get_cxtidioma(), vquery);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      cur := f_opencursor(vquery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           vnumerr, SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_lstmagnitud;

   FUNCTION f_lstterminos(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
/************************************************************************************
         Devuelve la lista de terminos
************************************************************************************/
      vobjectname    VARCHAR2(500) := 'PAC_MD_PROF.f_lstterminos';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vparam         NUMBER(5) := 1;
      cur            sys_refcursor;
      vquery         VARCHAR2(5000);
   BEGIN
      vnumerr := pac_prof.f_lstterminos(vquery);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      cur := f_opencursor(vquery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           vnumerr, SQLCODE, SQLERRM);

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
      vobjectname    VARCHAR2(500) := 'PAC_MD_PROF.F_SET_CONVENIO_TEMPORAL';
      vparam         VARCHAR2(500) := 'par퓅etros - ';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_prof.f_set_convenio_temporal(pnsinies, pntramit, psperson, pnlocali,
                                                  pctippro, pcsubpro, pstarifa, pnnumide,
                                                  ptnombre, pcvalor, pctipo, pnimporte,
                                                  pnporcent, ptermino, ptemail, pcagente,
                                                  psprofes, psconven);
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_set_convenio_temporal;

   --0024637/0147756: (POSAN500-AN-Sin) Analisis Desarrollo: Siniestros:NSS;25/02/2014
   FUNCTION f_get_impuestos(
      sprofes IN NUMBER,
      t_impuestos OUT t_iax_prof_impuestos,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(500) := 'PAC_MD_PROF.f_get_impuestos';
      vparam         VARCHAR2(500) := 'par퓅etros - sprofes=' || sprofes;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      v_prof_impuestos ob_iax_prof_impuestos := ob_iax_prof_impuestos();
      cur            sys_refcursor;
      vtselect       VARCHAR2(5000);
   BEGIN
      vnumerr := pac_prof.f_get_impuestos(sprofes, pac_md_common.f_get_cxtidioma(), vtselect);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      t_impuestos := t_iax_prof_impuestos();
      cur := pac_iax_listvalores.f_opencursor(vtselect, mensajes);

      LOOP
         FETCH cur
          INTO v_prof_impuestos.ccodimp, v_prof_impuestos.tdesimp, v_prof_impuestos.ctipind,
               v_prof_impuestos.tindica, v_prof_impuestos.cusuari, v_prof_impuestos.falta;

         EXIT WHEN cur%NOTFOUND;
         t_impuestos.EXTEND;
         t_impuestos(t_impuestos.LAST) := v_prof_impuestos;
         v_prof_impuestos := ob_iax_prof_impuestos();
      END LOOP;

      CLOSE cur;

      RETURN vnumerr;
   END f_get_impuestos;
END pac_md_prof;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_PROF" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_PROF" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_PROF" TO "PROGRAMADORESCSI";
