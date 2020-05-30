--------------------------------------------------------
--  DDL for Package Body PAC_MD_PENSIONES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MD_PENSIONES" AS
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   FUNCTION f_get_planpensiones(
      coddgs IN VARCHAR2,
      fon_coddgs IN VARCHAR2,
      ctipide IN NUMBER,
      nnumide IN VARCHAR2,
      nnompla IN VARCHAR2,
      ccodpla IN NUMBER,
      planpensiones IN OUT t_iax_planpensiones,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_PENSIONES.f_get_planpensiones';
      vparam         VARCHAR2(2000)
         := 'parámetros - coddgs: ' || coddgs || ' fon_coddgs: ' || fon_coddgs || ' ctipide: '
            || ctipide || ' nnumide: ' || nnumide || ' nnompla:' || nnompla;
      vpasexec       NUMBER(5) := 1;
      vcur           sys_refcursor;
      vnumerr        NUMBER;
      vcont          NUMBER := 0;
      planpen        ob_iax_planpensiones := ob_iax_planpensiones();
   BEGIN
      vnumerr := pac_pensiones.f_get_planpensiones(coddgs, fon_coddgs, ctipide, nnumide,
                                                   nnompla, pac_md_common.f_get_cxtagente,
                                                   ccodpla, vcur);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      planpensiones := t_iax_planpensiones();

      LOOP
         FETCH vcur
          INTO planpen.tbanco, planpen.icomges, planpen.icomdep, planpen.ccodpla,
               planpen.ccodgs, planpen.ccodfon, planpen.tnompla, planpen.faltare,
               planpen.fadmisi, planpen.tmodali, planpen.tsistem, planpen.tfondo,
               planpen.cbancar, planpen.ccodges, planpen.cgesdgs, planpen.ccoddep,
               planpen.tnomges, planpen.tnomdep, planpen.tnomges, planpen.cmodali,
               planpen.csistem, planpen.ccomerc, planpen.cmespag, planpen.ctipren,
               planpen.cperiod, planpen.ivalorl, planpen.clapla, planpen.npartot,
               planpen.coddgs, planpen.fbajare, planpen.ctipban, planpen.cfondgs,
               planpen.clistblanc;

         vcont := vcont + 1;
         EXIT WHEN vcur%NOTFOUND;
         planpensiones.EXTEND;
         planpensiones(planpensiones.LAST) := planpen;
         planpen := ob_iax_planpensiones();
      END LOOP;

      CLOSE vcur;

      IF vcont > 200 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 1000055);
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
      fonpensiones IN OUT t_iax_fonpensiones,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_PENSIONES.f_get_fonpensiones';
      vparam         VARCHAR2(2000)
         := 'parámetros -  ccodfon: ' || ccodfon || ' ccodges: ' || ccodges || ' ctipide: '
            || ctipide || ' nnumide: ' || nnumide;
      vpasexec       NUMBER(5) := 1;
      vcur           sys_refcursor;
      vnumerr        NUMBER;
      vcont          NUMBER := 0;
      v_ctipide      NUMBER;
      fonpen         ob_iax_fonpensiones := ob_iax_fonpensiones();
   BEGIN
      vnumerr := pac_pensiones.f_get_fonpensiones(ccodfon, ccodges, ccoddep, ctipide, nnumide,
                                                  nnomfon, pac_md_common.f_get_cxtagente,
                                                  vcur);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      fonpensiones := t_iax_fonpensiones();

      LOOP
         FETCH vcur
          INTO fonpen.ccodfon, fonpen.coddgs, fonpen.faltare, fonpen.fbajare, fonpen.tbanco,
               fonpen.ccomerc, fonpen.ccodges, fonpen.tnomges, fonpen.clafon,
               fonpen.persona.sperson, fonpen.persona.tnombre, fonpen.persona.tapelli1,
               fonpen.persona.tapelli2, fonpen.personatit.sperson, fonpen.personatit.tnombre,
               fonpen.personatit.tapelli1, fonpen.personatit.tapelli2, fonpen.cdivisa,
               fonpen.cgesdgs, fonpen.cbancar, fonpen.ntomo, fonpen.nfolio, fonpen.nhoja;

         IF fonpen.coddgs IS NOT NULL THEN
            vnumerr := f_get_planpensiones(NULL, fonpen.coddgs, NULL, NULL, NULL, NULL,
                                           fonpen.planpensiones, mensajes);
         END IF;

         IF vnumerr <> 0 THEN
            RAISE e_object_error;
         END IF;

         vcont := vcont + 1;
         EXIT WHEN vcur%NOTFOUND;
         fonpensiones.EXTEND;
         fonpensiones(fonpensiones.LAST) := fonpen;
         fonpen := ob_iax_fonpensiones();
      END LOOP;

      CLOSE vcur;

      IF vcont > 200 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 1000055);
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
      ctipide IN NUMBER,
      nnumide IN VARCHAR2,
      nnomges IN VARCHAR2,
      codgestoras IN OUT t_iax_gestoras,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_PENSIONES.f_get_codgestoras';
      vparam         VARCHAR2(2000)
         := 'parámetros -  ccodges: ' || ccodges || ' ctipide: ' || ctipide || ' nnumide: '
            || nnumide;
      vpasexec       NUMBER(5) := 1;
      vcur           sys_refcursor;
      vnumerr        NUMBER;
      vcont          NUMBER := 0;
      codges         ob_iax_gestoras := ob_iax_gestoras();
      v_ctipide      NUMBER;
      v_nnumide      VARCHAR2(30);
   BEGIN
      vnumerr :=
         pac_pensiones.f_get_codgestoras(ccodges,   --ccoddep,   --JGM:Quitar este campoFET!
                                         ctipide, nnumide, nnomges,
                                         pac_md_common.f_get_cxtagente(), vcur);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      codgestoras := t_iax_gestoras();

      LOOP
         FETCH vcur
          INTO codges.ccodges, codges.coddgs, codges.persona.sperson, codges.persona.tnombre,
               codges.persona.tapelli1, codges.persona.tapelli2, codges.falta, codges.fbaja,
               codges.cbanco, codges.coficin, codges.cdc, codges.ncuenta,
               codges.titular.sperson, codges.titular.tnombre, codges.titular.tapelli1,
               codges.titular.tapelli2, v_ctipide, v_nnumide, codges.timeclose;

         IF codges.ccodges IS NOT NULL THEN
            vnumerr := f_get_fonpensiones(NULL, codges.ccodges, NULL, NULL, NULL, NULL,
                                          codges.fonpensiones, mensajes);
         END IF;

         IF vnumerr <> 0 THEN
            RAISE e_object_error;
         END IF;

         EXIT WHEN vcur%NOTFOUND;
         codgestoras.EXTEND;
         codgestoras(codgestoras.LAST) := codges;
         codges := ob_iax_gestoras();
      END LOOP;

      CLOSE vcur;

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
      pdepositarias IN OUT t_iax_pdepositarias,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_PENSIONES.f_get_pdepositarias';
      vparam         VARCHAR2(2000)
         := 'parámetros -  ccoddep: ' || ccoddep || ' ctipide: ' || ctipide || ' nnumide: '
            || nnumide;
      vpasexec       NUMBER(5) := 1;
      vcur           sys_refcursor;
      vnumerr        NUMBER;
      vcont          NUMBER := 0;
      pdepos         ob_iax_pdepositarias := ob_iax_pdepositarias();
      v_ctipide      NUMBER;
      v_nombrecompleto VARCHAR2(2000);
   BEGIN
      vnumerr := pac_pensiones.f_get_pdepositarias(ccodfon, ccodaseg, ccoddep, ctipide,
                                                   nnumide, nnomdep,
                                                   pac_md_common.f_get_cxtagente, vcur);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      pdepositarias := t_iax_pdepositarias();

      LOOP
         FETCH vcur
          INTO pdepos.ccoddep, pdepos.falta, pdepos.fbaja, pdepos.persona.sperson,
               pdepos.persona.nnumide, v_nombrecompleto, pdepos.cbanco,
               pdepos.persona.ctipide, pdepos.persona.tnombre, pdepos.persona.tapelli1,
               pdepos.persona.tapelli2, pdepos.ctipban, pdepos.cbancar, pdepos.ctrasp;

         IF vnumerr <> 0 THEN
            RAISE e_object_error;
         END IF;

         EXIT WHEN vcur%NOTFOUND;
         pdepositarias.EXTEND;
         pdepositarias(pdepositarias.LAST) := pdepos;
         pdepos := ob_iax_pdepositarias();
      END LOOP;

      CLOSE vcur;

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
      promotores IN OUT t_iax_promotores,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_PENSIONES.f_get_promotores';
      vparam         VARCHAR2(2000)
         := 'parámetros - ccodpla: ' || ccodpla || ' cramo: ' || cramo || ' sproduc: '
            || sproduc || ' npoliza: ' || npoliza || ' ctipide: ' || ctipide || ' nnumide: '
            || nnumide || ' sperson: ' || sperson;
      vpasexec       NUMBER(5) := 1;
      vcur           sys_refcursor;
      vnumerr        NUMBER;
      vcont          NUMBER := 0;
      promotor       ob_iax_promotores := ob_iax_promotores();
   BEGIN
      vnumerr := pac_pensiones.f_get_promotores(cramo, sproduc, npoliza, ccodpla, ctipide,
                                                nnumide, sperson,
                                                pac_md_common.f_get_cxtagente, vcur);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      promotores := t_iax_promotores();

      -- Bug 12362 - 04/01/2010 - AMC - Sustituimos las variables de persona por el objeto ob_iax_persona
      LOOP
         FETCH vcur
          INTO promotor.ccodpla, promotor.tnompla, promotor.persona.nnumide,
               promotor.persona.tnombre, promotor.nvalparsp, promotor.npoliza,
               promotor.persona.sperson, promotor.cbancar, promotor.ctipban;

         EXIT WHEN vcur%NOTFOUND;
         promotores.EXTEND;
         promotores(promotores.LAST) := promotor;
         promotor := ob_iax_promotores();
      END LOOP;

      --Fi Bug 12362 - 04/01/2010 - AMC
      CLOSE vcur;

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
      pdepositarias IN OUT ob_iax_pdepositarias,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_PENSIONES.f_get_ob_pdepositarias';
      vparam         VARCHAR2(2000) := 'parámetros -  ccoddep: ' || ccoddep;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER;
      pdepos         t_iax_pdepositarias;
   BEGIN
      vnumerr := pac_md_pensiones.f_get_pdepositarias(NULL, NULL, ccoddep, NULL, NULL, NULL,
                                                      pdepos, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      IF pdepos.COUNT = 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 9900958);
         RETURN 1;
      END IF;

      pdepositarias := pdepos(1);
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
      codgestoras IN OUT ob_iax_gestoras,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_PENSIONES.f_get_ob_codgestoras';
      vparam         VARCHAR2(2000) := 'parámetros -  ccodges: ' || ccodges;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER;
      codges         t_iax_gestoras;
   BEGIN
      vnumerr := pac_md_pensiones.f_get_codgestoras(ccodges, NULL, NULL, NULL, codges,
                                                    mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      codgestoras := codges(1);
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
      fonpensiones IN OUT ob_iax_fonpensiones,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_PENSIONES.f_get_ob_fonpensiones';
      vparam         VARCHAR2(2000) := 'parámetros -  ccodfon: ' || ccodfon;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER;
      fonpen         t_iax_fonpensiones;
   BEGIN
      vnumerr := pac_md_pensiones.f_get_fonpensiones(ccodfon, NULL, NULL, NULL, NULL, NULL,
                                                     fonpen, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      fonpensiones := fonpen(1);
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
      planpensiones IN OUT ob_iax_planpensiones,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_PENSIONES.f_get_ob_planpensiones';
      vparam         VARCHAR2(2000) := 'parámetros - ccodpla: ' || ccodpla;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER;
      planpen        t_iax_planpensiones;
   BEGIN
      vnumerr := pac_md_pensiones.f_get_planpensiones(NULL, NULL, NULL, NULL, NULL, ccodpla,
                                                      planpen, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      planpensiones := planpen(1);
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
      promotores IN OUT ob_iax_promotores,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_PENSIONES.f_get_ob_promotores';
      vparam         VARCHAR2(2000)
                             := 'parámetros - ccodpla: ' || ccodpla || ' sperson: ' || sperson;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER;
      promotor       t_iax_promotores;
   BEGIN
      vnumerr := pac_md_pensiones.f_get_promotores(NULL, NULL, NULL, ccodpla, NULL, NULL,
                                                   sperson, promotor, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      promotores := promotor(1);
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

   FUNCTION f_del_promotores(
      ccodpla IN NUMBER,
      sperson IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_PENSIONES.f_del_promotores';
      vparam         VARCHAR2(2000)
                             := 'parámetros - ccodpla: ' || ccodpla || ' sperson: ' || sperson;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER;
   BEGIN
      IF ccodpla IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_param_error;
      END IF;

      vnumerr := pac_pensiones.f_del_promotores(ccodpla, sperson);

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
   END f_del_promotores;

   FUNCTION f_del_planpensiones(ccodpla IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_PENSIONES.f_del_planpensiones';
      vparam         VARCHAR2(2000) := 'parámetros - ccodpla: ' || ccodpla;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER;
   BEGIN
      IF ccodpla IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_param_error;
      END IF;

      vnumerr := pac_pensiones.f_del_planpensiones(ccodpla);

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
   END f_del_planpensiones;

   FUNCTION f_del_fonpensiones(ccodfon IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_PENSIONES.f_del_fonpensiones';
      vparam         VARCHAR2(500) := 'parámetros - ccodfon:' || ccodfon;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      IF ccodfon IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_param_error;
      END IF;

      vnumerr := pac_pensiones.f_del_fonpensiones(ccodfon);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
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
   END f_del_fonpensiones;

   FUNCTION f_del_codgestoras(ccodges IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_PENSIONES.f_del_codgestoras';
      vparam         VARCHAR2(500) := 'parámetros - ccodges:' || ccodges;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      IF ccodges IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_param_error;
      END IF;

      vnumerr := pac_pensiones.f_del_codgestoras(ccodges);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
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
   END f_del_codgestoras;

   FUNCTION f_del_pdepositarias(
      pccodaseg NUMBER,
      pccodfon NUMBER,
      pccoddep NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_PENSIONES.f_del_pdepositarias';
      vparam         VARCHAR2(500) := 'parámetros - ccoddep:' || pccoddep;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      IF pccoddep IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_param_error;
      END IF;

      vnumerr := pac_pensiones.f_del_pdepositarias(pccodaseg, pccodfon, pccoddep);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
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
   END f_del_pdepositarias;

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
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(800)
         := 'parámetros- ccoddep : ' || pccoddep || ' falta : ' || pfalta || ' fbaja : '
            || pfbaja || ' sperson : ' || psperson || ' cbanco : ' || pcbanco;
      vobject        VARCHAR2(50) := 'pac_md_pensiones.f_set_pdepositarias';
      vnumerr        NUMBER := 0;
   BEGIN
      vnumerr := pac_pensiones.f_set_pdepositarias(pccodaseg, pccodfon, pccoddep, pfalta,
                                                   pfbaja, psperson, pcctipban, pccbancar,
                                                   pcctrasp, pcbanco, modo);

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
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vcount         NUMBER := 0;
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(800)
         := 'parámetros- codges: ' || pccodges || ' falta : ' || pfalta || ' fbaja : '
            || pfbaja || ' cbanco : ' || pcbanco || ' coficin : ' || pcoficin || ' cdc : '
            || pcdc || ' ncuenta : ' || pncuenta || ' sperson : ' || psperson || ' spertit : '
            || pspertit;
      vobject        VARCHAR2(50) := 'pac_md_pensiones.f_set_codgestoras';
      vnumerr        NUMBER := 0;
   BEGIN
      -- Busquem nom de duplicats  de fons
      SELECT COUNT(1)
        INTO vcount
        FROM gestoras
       WHERE coddgs = pcoddgs
         AND NVL(pccodges, -9999) <> ccodges;

      -- Si  CODDGS ja existeix error, Duplicat el nom del fons
      IF vcount <> 0 THEN
         vnumerr := 9905737;
      ELSE
         vnumerr := pac_pensiones.f_set_codgestoras(pccodges, pfalta, pfbaja, pcbanco,
                                                    pcoficin, pcdc, pncuenta, psperson,
                                                    pspertit, UPPER(pcoddgs), ptimeclose,
                                                    pccodges_out);
      END IF;

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
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(800)
         := 'parámetros- faltare : ' || pfaltare || ' sperson : ' || psperson || ' spertit : '
            || pspertit || ' fbajare : ' || pfbajare || ' ccomerc : ' || pccomerc
            || ' ccodges : ' || pccodges || ' clafon : ' || pclafon || ' cdivisa : '
            || pcdivisa;
      vobject        VARCHAR2(50) := 'pac_md_pensiones.f_set_fonpensiones';
      vnumerr        NUMBER := 0;
      vcount         NUMBER := 1;
   BEGIN
      -- Busquem nom de duplicats  de fons
      SELECT COUNT(1)
        INTO vcount
        FROM fonpensiones
       WHERE coddgs = pcoddgs
         AND NVL(pccodfon, -9999) <> ccodfon;

      -- Si  CODDGS ja existeix error, Duplicat el nom del fons
      IF vcount <> 0 THEN
         vnumerr := 9905715;
      ELSE
         vnumerr := pac_pensiones.f_set_fonpensiones(pccodfon, pfaltare, psperson, pspertit,
                                                     pfbajare, pccomerc, pccodges, pclafon,
                                                     pcdivisa, UPPER(pcoddgs), pcbancar,
                                                     pctipban, pccodfon_out);
      END IF;

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
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vcount         NUMBER := 0;
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
      -- Busquem nom de duplicats  de fons
      SELECT COUNT(1)
        INTO vcount
        FROM planpensiones
       WHERE coddgs = pcoddgs
         AND NVL(pccodpla, -9999) <> ccodpla;

      -- Si  CODDGS ja existeix error, Duplicat el nom del fons
      IF vcount <> 0 THEN
         vnumerr := 9905736;
      ELSE
         vnumerr := pac_pensiones.f_set_planpensiones(pccodpla, ptnompla, pfaltare, pfadmisi,
                                                      pcmodali, pcsistem, pccodfon, pccomerc,
                                                      picomdep, picomges, pcmespag, pctipren,
                                                      pcperiod, pivalorl, pclapla, pnpartot,
                                                      UPPER(pcoddgs), pfbajare, pclistblanc,
                                                      pccodpla_out);
      END IF;

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
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, vnumerr, vpasexec, vparam);
         RETURN vnumerr;
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
      vobject        VARCHAR2(50) := 'pac_md_pensiones.f_set_promotores';
      vnumerr        NUMBER := 0;
   BEGIN
      IF pccodpla IS NULL
         OR psperson IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_pensiones.f_set_promotores(pccodpla, psperson, pnpoliza, pcbancar,
                                                pnvalparsp, pctipban);

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
   END f_set_promotores;

   FUNCTION f_get_ccodfon(
      pccodfon_dgs IN VARCHAR2,
      pccodfon IN OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_result       NUMBER := 1;
      vpasexec       NUMBER(8) := 1;
      vsperson       NUMBER(10);
      vparam         VARCHAR2(2000) := 'parámetros - pccodfon= ' || pccodfon;   -- solo obligatorios
      vobject        VARCHAR2(200) := 'PAC_MD_pensiones. f_get_ccodfon_dgs';
   BEGIN
      vpasexec := 1;

      --Comprovem els parametres d'entrada.
      IF pccodfon_dgs IS NULL THEN
         RAISE e_param_error;
      END IF;

      SELECT ccodfon
        INTO pccodfon
        FROM fonpensiones
       WHERE coddgs = pccodfon_dgs;

      vpasexec := 2;
      RETURN 0;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9900958);   -- el producto no permite rescates
         RETURN 1;
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
      pccodges IN OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_result       NUMBER := 1;
      vpasexec       NUMBER(8) := 1;
      vsperson       NUMBER(10);
      vparam         VARCHAR2(2000) := 'parámetros - pccodges= ' || pccodges;   -- solo obligatorios
      vobject        VARCHAR2(200) := 'PAC_MD_pensiones. f_get_ccodges_dgs';
   BEGIN
      vpasexec := 1;

      --Comprovem els parametres d'entrada.
      IF pccodges_dgs IS NULL THEN
         RAISE e_param_error;
      END IF;

      SELECT ccodges
        INTO pccodges
        FROM gestoras
       WHERE coddgs = pccodges_dgs;

      vpasexec := 2;
      RETURN 0;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9900958);   -- el producto no permite rescates
         RETURN 1;
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
      fonpension IN OUT ob_iax_fonpensiones,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_PENSIONES.f_get_planpension';
      vparam         VARCHAR2(2000) := 'parámetros - ccodfon: ' || ccodfon;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER;
      vcont          NUMBER := 0;
      planpen        ob_iax_planpensiones := ob_iax_planpensiones();
   BEGIN
      RETURN pac_pensiones.f_get_fonpension(ccodfon, fonpension);
   END f_get_fonpension;
END pac_md_pensiones;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_PENSIONES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_PENSIONES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_PENSIONES" TO "PROGRAMADORESCSI";
