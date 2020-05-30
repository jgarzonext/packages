--------------------------------------------------------
--  DDL for Package Body PAC_IAX_PENSIONES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IAX_PENSIONES" AS
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   FUNCTION f_get_planpensiones(
      coddgs IN VARCHAR2,
      fon_coddgs IN VARCHAR2,
      ctipide IN NUMBER,
      nnumide IN VARCHAR2,
      nnompla IN VARCHAR2,
      ccodpla IN NUMBER,
      planpensiones OUT t_iax_planpensiones,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_IAX_PENSIONES.f_get_planpensiones';
      vparam         VARCHAR2(2000)
         := 'parámetros - coddgs: ' || coddgs || ' fon_coddgs: ' || fon_coddgs || ' ctipide: '
            || ctipide || ' nnumide: ' || nnumide || ' nnompla:' || nnompla;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER;
   BEGIN
      vnumerr := pac_md_pensiones.f_get_planpensiones(coddgs, fon_coddgs, ctipide, nnumide,
                                                      nnompla, ccodpla, planpensiones,
                                                      mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
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
   END f_get_planpensiones;

   FUNCTION f_get_fonpensiones(
      ccodfon IN NUMBER,
      ccodges IN NUMBER,
      ccoddep IN NUMBER,
      ctipide IN NUMBER,
      nnumide IN VARCHAR2,
      nnomfon IN VARCHAR2,
      fonpensiones OUT t_iax_fonpensiones,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_IAX_PENSIONES.f_get_fonpensiones';
      vparam         VARCHAR2(2000)
         := 'parámetros -  ccodfon: ' || ccodfon || ' ccodges: ' || ccodges || ' ctipide: '
            || ctipide || ' nnumide: ' || nnumide;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER;
   BEGIN
      vnumerr := pac_md_pensiones.f_get_fonpensiones(ccodfon, ccodges, ccoddep, ctipide,
                                                     nnumide, nnomfon, fonpensiones, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
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
   END f_get_fonpensiones;

   FUNCTION f_get_codgestoras(
      ccodges IN NUMBER,
      --ccoddep IN NUMBER,   --JGM:Comentar este campoFET!
      ctipide IN NUMBER,
      nnumide IN VARCHAR2,
      nnomges IN VARCHAR2,
      codgestoras OUT t_iax_gestoras,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_IAX_PENSIONES.f_get_codgestoras';
      vparam         VARCHAR2(2000)
         := 'parámetros -  ccodges: ' || ccodges || ' ctipide: ' || ctipide || ' nnumide: '
            || nnumide;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER;
   BEGIN
      vnumerr := pac_md_pensiones.f_get_codgestoras(ccodges, ctipide, nnumide, nnomges,
                                                    codgestoras, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
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
   END f_get_codgestoras;

   FUNCTION f_get_pdepositarias(
      ccodfon IN NUMBER,
      ccodaseg IN NUMBER,
      ccoddep IN NUMBER,
      ctipide IN NUMBER,
      nnumide IN VARCHAR2,
      nnomdep IN VARCHAR2,
      pdepositarias OUT t_iax_pdepositarias,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_IAX_PENSIONES.f_get_pdepositarias';
      vparam         VARCHAR2(2000)
         := 'parámetros -  ccoddep: ' || ccoddep || ' ctipide: ' || ctipide || ' nnumide: '
            || nnumide;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER;
   BEGIN
      vnumerr := pac_md_pensiones.f_get_pdepositarias(ccodfon, ccodaseg, ccoddep, ctipide,
                                                      nnumide, nnomdep, pdepositarias,
                                                      mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
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
   END f_get_pdepositarias;

   FUNCTION f_get_promotores(
      cramo IN NUMBER,
      sproduc IN NUMBER,
      npoliza IN NUMBER,
      ccodpla IN NUMBER,
      ctipide IN NUMBER,
      nnumide IN VARCHAR2,
      sperson IN NUMBER,
      promotores OUT t_iax_promotores,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_IAX_PENSIONES.f_get_promotores';
      vparam         VARCHAR2(2000)
         := 'parámetros - ccodpla: ' || ccodpla || ' cramo: ' || cramo || ' sproduc: '
            || sproduc || ' npoliza: ' || npoliza || ' ctipide: ' || ctipide || ' nnumide: '
            || nnumide || ' sperson: ' || sperson;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER;
   BEGIN
      vnumerr := pac_md_pensiones.f_get_promotores(cramo, sproduc, npoliza, ccodpla, ctipide,
                                                   nnumide, sperson, promotores, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
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
   END f_get_promotores;

   FUNCTION f_get_ob_pdepositarias(
      ccoddep IN NUMBER,
      pdepositarias OUT ob_iax_pdepositarias,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_IAX_PENSIONES.f_get_ob_pdepositarias';
      vparam         VARCHAR2(2000) := 'parámetros -  ccoddep: ' || ccoddep;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER;
   BEGIN
      IF ccoddep IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_pensiones.f_get_ob_pdepositarias(ccoddep, pdepositarias, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
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
   END f_get_ob_pdepositarias;

   FUNCTION f_get_ob_codgestoras(
      ccodges IN NUMBER,
      codgestoras OUT ob_iax_gestoras,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_IAX_PENSIONES.f_get_ob_codgestoras';
      vparam         VARCHAR2(2000) := 'parámetros -  ccodges: ' || ccodges;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER;
   BEGIN
      vnumerr := pac_md_pensiones.f_get_ob_codgestoras(ccodges, codgestoras, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
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
   END f_get_ob_codgestoras;

   FUNCTION f_get_ob_fonpensiones(
      ccodfon IN NUMBER,
      fonpensiones OUT ob_iax_fonpensiones,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_IAX_PENSIONES.f_get_ob_fonpensiones';
      vparam         VARCHAR2(2000) := 'parámetros -  ccodfon: ' || ccodfon;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER;
   BEGIN
      vnumerr := pac_md_pensiones.f_get_ob_fonpensiones(ccodfon, fonpensiones, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
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
   END f_get_ob_fonpensiones;

   FUNCTION f_get_ob_planpensiones(
      ccodpla IN NUMBER,
      planpensiones OUT ob_iax_planpensiones,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_PENSIONES.f_get_ob_planpensiones';
      vparam         VARCHAR2(2000) := 'parámetros - ccodpla: ' || ccodpla;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER;
   BEGIN
      vnumerr := pac_md_pensiones.f_get_ob_planpensiones(ccodpla, planpensiones, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
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
   END f_get_ob_planpensiones;

   FUNCTION f_get_ob_promotores(
      ccodpla IN NUMBER,
      sperson IN NUMBER,
      promotores OUT ob_iax_promotores,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_IAX_PENSIONES.f_get_ob_promotores';
      vparam         VARCHAR2(2000)
                             := 'parámetros - ccodpla: ' || ccodpla || ' sperson: ' || sperson;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER;
   BEGIN
      vnumerr := pac_md_pensiones.f_get_ob_promotores(ccodpla, sperson, promotores, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
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
   END f_get_ob_promotores;

   FUNCTION f_del_promotores(ccodpla IN NUMBER, sperson IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_IAX_PENSIONES.f_del_promotores';
      vparam         VARCHAR2(2000)
                             := 'parámetros - ccodpla: ' || ccodpla || ' sperson: ' || sperson;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER;
   BEGIN
      IF ccodpla IS NULL
         OR sperson IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_pensiones.f_del_promotores(ccodpla, sperson, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_del_promotores;

   FUNCTION f_del_planpensiones(ccodpla IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_IAX_PENSIONES.f_del_planpensiones';
      vparam         VARCHAR2(2000) := 'parámetros - ccodpla: ' || ccodpla;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER;
   BEGIN
      IF ccodpla IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_pensiones.f_del_planpensiones(ccodpla, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_del_planpensiones;

   FUNCTION f_del_fonpensiones(ccodfon IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_IAX_PENSIONES.f_del_fonpensiones';
      vparam         VARCHAR2(500) := 'parámetros - ccodfon:' || ccodfon;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      IF ccodfon IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_pensiones.f_del_fonpensiones(ccodfon, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam,
                                           vnumerr);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_del_fonpensiones;

   FUNCTION f_del_codgestoras(ccodges IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_IAX_PENSIONES.f_del_codgestoras';
      vparam         VARCHAR2(500) := 'parámetros - ccodges:' || ccodges;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      IF ccodges IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_pensiones.f_del_codgestoras(ccodges, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam,
                                           vnumerr);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_del_codgestoras;

   FUNCTION f_del_pdepositarias(
      pccodaseg NUMBER,
      pccodfon NUMBER,
      pccoddep NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_IAX_PENSIONES.f_del_pdepositarias';
      vparam         VARCHAR2(500) := 'parámetros - ccoddep:' || pccoddep;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      IF pccoddep IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_pensiones.f_del_pdepositarias(pccodaseg, pccodfon, pccoddep, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam,
                                           vnumerr);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_del_pdepositarias;

   /***********************************************************************
      Eliminar de la taula una conf. del producte
      param  in  pscaumot :  código de la causa
      param  in  psproduc  : código del producto
      param  in  pcactivi  : código de la actividad
      param  in  pcgarant  : código de la garantia
      param  in  pctramit  : código de la tramitación
      param out mensajes  : mensajes de error
      return              : NUMBER

      26/05/2009   XPL                 Sinistres.  Bug: 8816
   ***********************************************************************/
   FUNCTION f_set_pdepositarias(
      pccodaseg NUMBER,
      pccodfon NUMBER,
      pccoddep NUMBER,
      pfalta DATE,
      pfbaja DATE,
      psperson NUMBER,
      pcctipban NUMBER,
      pccbancar VARCHAR2,
      pcctrasp NUMBER,
      pcbanco NUMBER,
      modo VARCHAR2 DEFAULT 'alta',
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_IAX_PENSIONES.f_set_pdepositarias';
      vparam         VARCHAR2(500)
         := 'parámetros - ccoddep:' || pccoddep || ' falta:' || pfalta || ' fbaja:' || pfbaja
            || ' sperson:' || psperson || ' cbanco:' || pcbanco;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_md_pensiones.f_set_pdepositarias(pccodaseg, pccodfon, pccoddep, pfalta,
                                                      pfbaja, psperson, pcctipban, pccbancar,
                                                      pcctrasp, pcbanco, modo, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam,
                                           vnumerr);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_set_pdepositarias;

   FUNCTION f_set_codgestoras(
      pccodges NUMBER,
      pfalta DATE,
      pfbaja DATE,
      pcbanco NUMBER,
      pcoficin NUMBER,
      pcdc NUMBER,
      pncuenta VARCHAR2,
      psperson NUMBER,
      pspertit NUMBER,
      pcoddgs VARCHAR2,
      ptimeclose VARCHAR2,
      pccodges_out OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vparam         VARCHAR2(3000)
         := 'parámetros- ccodges : ' || pccodges || ' falta : ' || pfalta || ' fbaja : '
            || pfbaja || ' cbanco : ' || pcbanco || ' coficin : ' || pcoficin || ' cdc : '
            || pcdc || ' ncuenta : ' || pncuenta || ' sperson : ' || psperson || ' spertit : '
            || pspertit;
      vobject        VARCHAR2(200) := 'pac_iax_pensiones.f_set_codgestoras NORMAN';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vobject := 'pac_iax_pensiones.f_set_codgestoras';
      vnumerr := pac_md_pensiones.f_set_codgestoras(pccodges, pfalta, pfbaja, pcbanco,
                                                    pcoficin, pcdc, pncuenta, psperson,
                                                    pspertit, pcoddgs, ptimeclose,
                                                    pccodges_out, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
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
   END f_set_codgestoras;

   FUNCTION f_set_fonpensiones(
      pccodfon NUMBER,
      pfaltare DATE,
      psperson NUMBER,
      pspertit NUMBER,
      pfbajare DATE,
      pccomerc VARCHAR2,
      pccodges NUMBER,
      pclafon NUMBER,
      pcdivisa NUMBER,
      pcoddgs VARCHAR2,
      pcbancar VARCHAR2,
      pctipban NUMBER,
      pccodfon_out OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(800)
         := 'parámetros- faltare : ' || pfaltare || ' sperson : ' || psperson || ' spertit : '
            || pspertit || ' fbajare : ' || pfbajare || ' ccomerc : ' || pccomerc
            || ' ccodges : ' || pccodges || ' clafon : ' || pclafon || ' cdivisa : '
            || pcdivisa   --JGM:Añadir este campoFET!
                       ;
      vobject        VARCHAR2(50) := 'pac_iax_pensiones.f_set_fonpensiones';
      vnumerr        NUMBER := 0;
   BEGIN
      vnumerr := pac_md_pensiones.f_set_fonpensiones(pccodfon, pfaltare, psperson, pspertit,
                                                     pfbajare, pccomerc, pccodges, pclafon,
                                                     pcdivisa, pcoddgs, pcbancar, pctipban,
                                                     pccodfon_out, mensajes);

      IF vnumerr <> 0 THEN
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
   END f_set_fonpensiones;

   FUNCTION f_set_planpensiones(
      pccodpla NUMBER,
      ptnompla VARCHAR2,
      pfaltare DATE,
      pfadmisi DATE,
      pcmodali NUMBER,
      pcsistem NUMBER,
      pccodfon NUMBER,
      pccomerc VARCHAR2,
      picomdep NUMBER,
      picomges NUMBER,
      pcmespag NUMBER,
      pctipren NUMBER,
      pcperiod NUMBER,
      pivalorl NUMBER,
      pclapla NUMBER,
      pnpartot NUMBER,
      pcoddgs VARCHAR2,
      pfbajare DATE,
      pclistblanc NUMBER,
      pccodpla_out OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(800)
         := 'parámetros- ccodpla : ' || pccodpla || ' tnompla : ' || ptnompla || ' faltare : '
            || pfaltare || ' fadmisi : ' || pfadmisi || ' cmodali : ' || pcmodali
            || ' csistem : ' || pcsistem || ' ccodfon : ' || pccodfon || ' ccomerc : '
            || pccomerc || ' icomdep : ' || picomdep || ' icomges : ' || picomges
            || ' cmespag : ' || pcmespag || ' ctipren : ' || pctipren;
      vobject        VARCHAR2(50) := 'pac_md_pensiones.f_set_planpensiones';
      vnumerr        NUMBER := 0;
   BEGIN
      vnumerr := pac_md_pensiones.f_set_planpensiones(pccodpla, ptnompla, pfaltare, pfadmisi,
                                                      pcmodali, pcsistem, pccodfon, pccomerc,
                                                      picomdep, picomges, pcmespag, pctipren,
                                                      pcperiod, pivalorl, pclapla, pnpartot,
                                                      pcoddgs, pfbajare, pclistblanc,
                                                      pccodpla_out, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, vnumerr, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_set_planpensiones;

   /**************************************************************
        Funcion para insertar o actualizar los promotores
        param in pccodpla : codigo del plan
        param in psperson : código de la persona
        param in pnpoliza : código de la poliza
        param in pcbancar : código de cuenta bancaria
        param in pnvalparsp : Importe valor participación Servicios Pasados
        param in pctipban : tipo de cuenta
        param out mensajes : mensajes de error

       bug 12362 - 24/12/2009 - AMC
   **************************************************************/
   FUNCTION f_set_promotores(
      pccodpla IN NUMBER,
      psperson IN NUMBER,
      pnpoliza IN NUMBER,
      pcbancar IN VARCHAR2,
      pnvalparsp IN NUMBER,
      pctipban IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(800)
         := 'parámetros- pccodpla : ' || pccodpla || ' psperson : ' || psperson
            || ' pnpoliza : ' || pnpoliza || ' pcbancar : ' || pcbancar || ' pnvalparsp : '
            || pnvalparsp || ' pctipban : ' || pctipban;
      vobject        VARCHAR2(50) := 'pac_iax_pensiones.f_set_promotores';
      vnumerr        NUMBER := 0;
   BEGIN
      IF pccodpla IS NULL
         OR psperson IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_pensiones.f_set_promotores(pccodpla, psperson, pnpoliza, pcbancar,
                                                   pnvalparsp, pctipban, mensajes);

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
   END f_set_promotores;

   FUNCTION f_get_ccodfon(
      pccodfon_dgs IN VARCHAR2,
      pccodfon OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_result       NUMBER := 1;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'parámetros - pccodfon_DGS= ' || pccodfon_dgs;   -- solo obligatorios
      vobject        VARCHAR2(200) := 'PAC_IAX_pensiones.f_get_ccodfon';
      v_fich         VARCHAR2(400);
   BEGIN
      vpasexec := 1;

      --Comprovem els parametres d'entrada.
      IF pccodfon_dgs IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      v_result := pac_md_pensiones.f_get_ccodfon(pccodfon_dgs, pccodfon, mensajes);
      RETURN v_result;
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
   END f_get_ccodfon;

   FUNCTION f_get_ccodges(
      pccodges_dgs IN VARCHAR2,
      pccodges OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_result       NUMBER := 1;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'parámetros - pccodges_DGS= ' || pccodges_dgs;   -- solo obligatorios
      vobject        VARCHAR2(200) := 'PAC_IAX_pensiones.f_get_ccodges';
      v_fich         VARCHAR2(400);
   BEGIN
      vpasexec := 1;

      --Comprovem els parametres d'entrada.
      IF pccodges_dgs IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      v_result := pac_md_pensiones.f_get_ccodges(pccodges_dgs, pccodges, mensajes);
      RETURN v_result;
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
   END f_get_ccodges;

   FUNCTION f_get_fonpension(
      ccodfon IN NUMBER,
      fonpension OUT ob_iax_fonpensiones,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_IAX_PENSIONES.f_get_planpension';
      vparam         VARCHAR2(2000) := 'parámetros - ccodfon: ' || ccodfon;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER;
      vcont          NUMBER := 0;
      planpen        ob_iax_planpensiones := ob_iax_planpensiones();
   BEGIN
      RETURN pac_md_pensiones.f_get_fonpension(ccodfon, fonpension, mensajes);
   END f_get_fonpension;
END pac_iax_pensiones;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_PENSIONES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_PENSIONES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_PENSIONES" TO "PROGRAMADORESCSI";
