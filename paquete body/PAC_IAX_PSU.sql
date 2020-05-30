--------------------------------------------------------
--  DDL for Package Body PAC_IAX_PSU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IAX_PSU" IS
    /******************************************************************************
       NOMBRE    : PAC_IAX_PSU
       ARCHIVO   : PAC_IAX_PSU.PKS
       PROP真SITO : Package con funciones propias de la funcionalidad de
                   Pol真tica de Subscripci真n, per gestionar els controls.

       REVISIONES:
       Ver    Fecha      Autor     Descripci真n
       ------ ---------- ------ ------------------------------------------------
       1.0    01/07/2009 NMM    Creaci真 del package.
       2.0    19/07/2010 PFA    15459: MDP003 - PSU-MDP Controls rebutjables i visibilitat
       3.0    12/02/2014 JDS    0029991: LCOL_T010-Revision incidencias qtracker (2014/02)
       4.0    06/05/2015  VCG   0035288-0203030-INT033-Controlar longitud de observaciones al autorizar o rechazar una propuesta
   ******************************************************************************/
   FUNCTION f_inicia_psu(
      p_tablas IN VARCHAR2,
      p_sseguro IN NUMBER,
      p_accion IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_IAX_psu.f_inicia_psu';
      vparam         VARCHAR2(500)
         := 'par真metros -  p_sseguro: ' || p_sseguro || ', p_tablas: ' || p_tablas
            || ',p_accion: ' || p_accion;
      w_cidioma      idiomas.cidioma%TYPE := pac_md_common.f_get_cxtidioma();
      vcreteni       NUMBER;
      vnumerr        NUMBER;
   --
   BEGIN
      vnumerr := pac_md_psu.f_inicia_psu(p_tablas, p_sseguro, p_accion, mensajes);
      COMMIT;
      RETURN(vnumerr);
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, 1, vparam);
         RETURN(1);
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, 1, vparam);
         RETURN(1);
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, 1, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN(1);
-----------------------------------------------------------------------------
   END f_inicia_psu;

   /*****************************************************************************
        Recupera la llista de p真lisses amb controls de PSU, cridar真 la funci真 de
        la capa intermitja PAC_MD_PSU.F_GET_CONSULTA.

        param in      : P_SPRODUC  Codi producte.
        param in      : P_NPOLIZA  Nombre de p真lissa.
        param in      : P_NSOLICI  Nombre de sol真licitud.
        param in      : P_CAUTREC  Codi estat del control.
        param in out  : P_MENSAJES Missatges de sortida.
   *****************************************************************************/
   FUNCTION f_get_consulta(
      p_sproduc IN NUMBER,
      p_npoliza IN NUMBER,
      p_nsolici IN NUMBER,
      p_cautrec IN NUMBER,
      p_mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vobjectname    VARCHAR2(500) := 'PAC_iax_psu.f_get_consulta';
      vparam         VARCHAR2(500)
         := 'par真metros - p_sproduc: ' || p_sproduc || ', p_npoliza: ' || p_npoliza
            || ', p_nsolici: ' || p_nsolici || ' ,p_cautrec: ' || p_cautrec;
      w_refcursor    sys_refcursor;
      w_pas          PLS_INTEGER := 1;
-----------------------------------------------------------------------------
   BEGIN
      -- Comprova pas de par真metres
      IF p_sproduc IS NULL
         OR p_npoliza IS NULL
         OR p_nsolici IS NULL
         OR p_cautrec IS NULL THEN
         RAISE e_param_error;
      END IF;

      w_pas := 2;
      w_refcursor := pac_md_psu.f_get_consulta(p_sproduc, p_npoliza, p_nsolici, p_cautrec,
                                               p_mensajes);
      w_pas := 3;
      RETURN(w_refcursor);
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(p_mensajes, vobjectname, 1000005, w_pas, vparam);

         IF w_refcursor%ISOPEN THEN
            CLOSE w_refcursor;
         END IF;

         RETURN(w_refcursor);
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(p_mensajes, vobjectname, 1000006, w_pas, vparam);

         IF w_refcursor%ISOPEN THEN
            CLOSE w_refcursor;
         END IF;

         RETURN(w_refcursor);
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(p_mensajes, vobjectname, 1000001, w_pas, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF w_refcursor%ISOPEN THEN
            CLOSE w_refcursor;
         END IF;

         RETURN(w_refcursor);
-----------------------------------------------------------------------------
   END f_get_consulta;

   /*****************************************************************************
      Recupera la llista de p真lisses amb controls de PSU, cridar真 la funci真 de
      la capa intermitja PAC_MD_PSU.F_LEE_CONTROLES.

      param in      : P_SSEGURO  Codi asseguran真a.
      param in out  : P_MENSAJES Missatges de sortida.
   *****************************************************************************/
   FUNCTION f_lee_controles(p_sseguro IN NUMBER, p_mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vobjectname    VARCHAR2(500) := 'PAC_iax_psu.f_lee_controles';
      vparam         VARCHAR2(500) := 'par真metros - p_sseguro: ' || p_sseguro;
      w_refcursor    sys_refcursor;
      w_pas          PLS_INTEGER := 1;
-----------------------------------------------------------------------------
   BEGIN
      -- Comprova pas de par真metres
      IF p_sseguro IS NULL THEN
         RAISE e_param_error;
      END IF;

      w_pas := 2;
      w_refcursor := pac_md_psu.f_lee_controles(p_sseguro, p_mensajes);
      w_pas := 3;
      RETURN(w_refcursor);
   --
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(p_mensajes, vobjectname, 1000005, w_pas, vparam);

         IF w_refcursor%ISOPEN THEN
            CLOSE w_refcursor;
         END IF;

         RETURN(w_refcursor);
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(p_mensajes, vobjectname, 1000006, w_pas, vparam);

         IF w_refcursor%ISOPEN THEN
            CLOSE w_refcursor;
         END IF;

         RETURN(w_refcursor);
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(p_mensajes, vobjectname, 1000001, w_pas, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF w_refcursor%ISOPEN THEN
            CLOSE w_refcursor;
         END IF;

         RETURN(w_refcursor);
-----------------------------------------------------------------------------
   END f_lee_controles;

   /*****************************************************************************
     Graba les observacions del control sel真leccionat, cridar真 la funci真 de
     la capa intermitja PAC_MD_PSU.F_GRABAOBSERVACIONES.

     param in      : P_SSEGURO  Codi asseguran真a.
     param in      : P_NRIESGO  Nombre risc.
     param in      : P_CGARANT  Codi de la garantia.
     param in      : P_CCONTROL Codi de control.
     param in      : P_TOBSERV  Observacions.
     param in      : P_TOBSERV  Missatges de sortida.

     Retorna 0 -> OK o b真 1 -> NOTOK.
    *****************************************************************************/
   FUNCTION f_grabaobservaciones(
      p_sseguro IN NUMBER,
      p_nriesgo IN NUMBER,
      p_cgarant IN NUMBER,
      p_ccontrol IN NUMBER,
      p_tobserv IN VARCHAR2,
      p_mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_iax_psu.f_grabaobservaciones';
      vparam         VARCHAR2(500)
         := 'par真metros - p_sseguro: ' || p_sseguro || ', p_nriesgo: ' || p_nriesgo
            || ', p_cgarant: ' || p_cgarant || ' ,p_ccontrol: ' || p_ccontrol;
      -----|| ', p_tobserv: ' || p_tobserv;
      w_retorn       NUMBER;
      w_pas          PLS_INTEGER := 1;
-----------------------------------------------------------------------------
   BEGIN
      -- Comprova pas de par真metres
      IF p_sseguro IS NULL
         OR p_nriesgo IS NULL
         OR p_cgarant IS NULL
         OR p_ccontrol IS NULL
         OR p_tobserv IS NULL THEN
         RAISE e_param_error;
      END IF;

      w_pas := 2;
      w_retorn := pac_md_psu.f_grabaobservaciones(p_sseguro, p_nriesgo, p_cgarant, p_ccontrol,
                                                  p_tobserv, p_mensajes);
      RETURN(0);
   --
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(p_mensajes, vobjectname, 1000005, w_pas, vparam);
         RETURN(1);
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(p_mensajes, vobjectname, 1000006, w_pas, vparam);
         RETURN(1);
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(p_mensajes, vobjectname, 1000001, w_pas, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN(1);
-----------------------------------------------------------------------------
   END f_grabaobservaciones;

-----------------------------------------------------------------------------
   FUNCTION f_get_colec_psu(
      p_sseguro IN seguros.sseguro%TYPE,
      p_nmovimi IN movseguro.nmovimi%TYPE,
      p_nriesgo IN riesgos.nriesgo%TYPE,
      p_tablas IN VARCHAR2 DEFAULT NULL,
      p_testpol OUT VARCHAR2,
      p_cestpol OUT NUMBER,
      p_cnivelbpm OUT NUMBER,
      p_tnivelbpm OUT VARCHAR2,
      pobpsu_retenidas OUT ob_iax_psu_retenidas,
      p_tpsus OUT t_iax_psu,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      --
      w_retorn       NUMBER;
      cursor_psu     sys_refcursor;
      w_pas          NUMBER;
      w_tpsus        ob_iax_psu := ob_iax_psu();
      vobjectname    VARCHAR2(500) := 'pac_iax_psu.f_get_colec_psu';
      vparam         VARCHAR2(500)
         := 'parms - p_sseguro: ' || p_sseguro || ', p_nriesgo: ' || p_nriesgo
            || ', p_nmovimi: ' || p_nmovimi || ', p_tablas: ' || p_tablas;
   --
   BEGIN
      -- Comprova pas de par真metres
      IF p_sseguro IS NULL THEN
         RAISE e_param_error;
      END IF;

      w_retorn := pac_md_psu.f_get_colec_psu(p_sseguro, p_nmovimi, p_nriesgo,
                                             pac_iax_common.f_get_cxtidioma, p_tablas,
                                             p_testpol, p_cestpol, p_cnivelbpm, p_tnivelbpm,
                                             pobpsu_retenidas, p_tpsus, mensajes);

      IF w_retorn <> 0 THEN
         RAISE e_object_error;
      END IF;

      wg_t_psus := p_tpsus;
      --
      RETURN(0);
   --
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, w_pas, vparam);
         RETURN(1);
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, 1, vparam,
                                           w_retorn);
         RETURN(1);
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, 1, vparam, NULL,
                                           SQLCODE, SQLERRM);
         RETURN(1);
   END f_get_colec_psu;

--pac_iax_siniestros
-----------------------------------------------------------------------------
   FUNCTION f_get_det_psu(
      p_sseguro IN seguros.sseguro%TYPE,
      p_nmovimi IN movseguro.nmovimi%TYPE,
      p_nriesgo IN riesgos.nriesgo%TYPE,
      p_cgarant IN NUMBER,
      p_ccontrol IN NUMBER,
      p_tablas IN VARCHAR2,
      p_tpsus OUT ob_iax_psu,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      --
      w_retorn       NUMBER;
      cursor_psu     sys_refcursor;
      w_pas          NUMBER;
      w_tpsus        ob_iax_psu := ob_iax_psu();
      pobpsu_retenidas ob_iax_psu_retenidas := ob_iax_psu_retenidas();
      p_testpol      VARCHAR2(4000);
      p_cestpol      NUMBER;
      p_cnivelbpm    NUMBER;
      p_tnivelbpm    VARCHAR2(4000);
      trobat         BOOLEAN;
      vobjectname    VARCHAR2(500) := 'pac_iax_psu.f_get_det_psu';
      vparam         VARCHAR2(500)
         := 'parms - p_sseguro: ' || p_sseguro || ', p_nriesgo: ' || p_nriesgo
            || ', p_nmovimi: ' || p_nmovimi || ', control : ' || p_ccontrol;
   --
   BEGIN
      -- Comprova pas de par真metres
      IF p_sseguro IS NULL
         OR p_nmovimi IS NULL
         OR p_nriesgo IS NULL
         OR p_ccontrol IS NULL THEN
         RAISE e_param_error;
      END IF;

      trobat := FALSE;

/*
      IF wg_t_psus IS NOT NULL
         AND wg_t_psus.COUNT > 0 THEN
         FOR i IN wg_t_psus.FIRST .. wg_t_psus.LAST LOOP
            IF wg_t_psus(i).sseguro = p_sseguro
               AND wg_t_psus(i).nmovimi = p_nmovimi
               AND wg_t_psus(i).nriesgo = p_nriesgo
               AND wg_t_psus(i).ccontrol = p_ccontrol THEN
               p_tpsus := wg_t_psus(i);
               trobat := TRUE;
            END IF;
         END LOOP;
      END IF;
*/
      IF NOT trobat THEN
         --Estem a Consulta de p真lisses, ja que es fan m真s crides per obtenir els hist真rics.
         w_retorn := pac_md_psu.f_get_colec_psu(p_sseguro, p_nmovimi, p_nriesgo,
                                                pac_iax_common.f_get_cxtidioma,

                                                -- JLB I 20759#c105389
                                                -- 'POL',
                                                NVL(p_tablas, pac_iax_produccion.vpmode),

                                                -- JLB F  20759#c105389
                                                p_testpol, p_cestpol, p_cnivelbpm,
                                                p_tnivelbpm, pobpsu_retenidas, wg_t_psus,
                                                mensajes);

         FOR i IN wg_t_psus.FIRST .. wg_t_psus.LAST LOOP
            IF wg_t_psus(i).sseguro = p_sseguro
               AND wg_t_psus(i).nmovimi = p_nmovimi
               AND wg_t_psus(i).nriesgo = p_nriesgo
               AND wg_t_psus(i).ccontrol = p_ccontrol
               AND wg_t_psus(i).cgarant = NVL(p_cgarant, 0) THEN
               p_tpsus := wg_t_psus(i);
            END IF;
         END LOOP;
      END IF;

      RETURN(0);
   --
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, w_pas, vparam);
         RETURN(1);
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, 1, vparam,
                                           w_retorn);
         RETURN(1);
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, 1, vparam, NULL,
                                           SQLCODE, SQLERRM);
         RETURN(1);
   END f_get_det_psu;

-----------------------------------------------------------------------------
--
   /*****************************************************************************
     Gestiona el control sel真leccionat, cridar真 la funci真 de
     la capa intermitja PAC_MD_PSU.F_AUTORIZA.

     param in      : P_SSEGURO  Codi asseguran真a.
     param in      : P_NRIESGO  Nombre risc.
     param in      : P_CGARANT  Codi de la garantia.
     param in      : P_CCONTROL Codi de control.
     param in      : P_TOBSERV  Observacions.
     param in      : P_TOBSERV  Missatges de sortida.

     Retorna 0 -> OK o b真 1 -> NOTOK.
    *****************************************************************************/
   FUNCTION f_gestion_control(
      p_sseguro IN NUMBER,
      p_nriesgo IN NUMBER,
      p_nmovimi IN NUMBER,
      p_cgarant IN NUMBER,
      p_ccontrol IN NUMBER,
      p_tobserv IN VARCHAR2,
      p_cautrec IN NUMBER,
      p_nvalortope IN NUMBER,
      p_nocurre IN NUMBER,
      p_nvalor IN NUMBER,
      p_nvalorinf IN NUMBER,
      p_nvalorsuper IN NUMBER,
      p_nivelr IN NUMBER,
      p_establoquea IN NUMBER,
      p_autmanual IN NUMBER,
      p_tablas IN VARCHAR2,
      p_modo IN NUMBER,
      p_numriesgo IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_iax_psu.f_gestion_control';
      -- BUG 0035288-0203030 - 06/05/2015-VCG- No debe contemplar la variable p_tobserv
      vparam         VARCHAR2(500)
         := 'par真metros - p_sseguro: ' || p_sseguro || ', p_nriesgo: ' || p_nriesgo
            || ', p_cgarant: ' || p_cgarant || ' ,p_ccontrol: ' || p_ccontrol
            ----|| p_tobserv
            || ', p_cautrec: ' || p_cautrec;
      w_retorn       NUMBER;
      w_pas          PLS_INTEGER;
-----------------------------------------------------------------------------
   BEGIN
      w_pas := 1;

      -- Comprova pas de par真metres
      IF p_sseguro IS NULL
--         OR p_nriesgo IS NULL
--         OR p_cgarant IS NULL
--         OR p_ccontrol IS NULL
         OR p_cautrec IS NULL THEN
         RAISE e_param_error;
      END IF;

      w_pas := 2;
      w_retorn := pac_md_psu.f_gestion_control(p_sseguro, p_nriesgo, p_nmovimi, p_cgarant,
                                               p_ccontrol, p_tobserv, p_cautrec, p_nvalortope,
                                               p_nocurre, p_nvalor, p_nvalorinf, p_nvalorsuper,
                                               p_nivelr, p_establoquea, p_autmanual, p_tablas,
                                               p_modo, p_numriesgo, mensajes);

      IF w_retorn <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN(0);
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, w_pas, vparam);
         ROLLBACK;
         RETURN(1);
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, w_pas, vparam);
         ROLLBACK;
         RETURN(1);
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, w_pas, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN(1);
-----------------------------------------------------------------------------
   END f_gestion_control;

   FUNCTION f_get_lstniveles(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vobjectname    VARCHAR2(500) := 'PAC_iax_psu.f_get_lstniveles';
      vparam         VARCHAR2(500) := 'par真metros -  ';
      w_refcursor    sys_refcursor;
      w_pas          PLS_INTEGER := 1;
      vnerror        NUMBER;
-----------------------------------------------------------------------------
   BEGIN
      w_pas := 2;
      vnerror := pac_md_psu.f_get_lstniveles(w_refcursor, mensajes);
      w_pas := 3;
      RETURN(w_refcursor);
   --
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, w_pas, vparam);

         IF w_refcursor%ISOPEN THEN
            CLOSE w_refcursor;
         END IF;

         RETURN(w_refcursor);
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, w_pas, vparam);

         IF w_refcursor%ISOPEN THEN
            CLOSE w_refcursor;
         END IF;

         RETURN(w_refcursor);
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, w_pas, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF w_refcursor%ISOPEN THEN
            CLOSE w_refcursor;
         END IF;

         RETURN(w_refcursor);
-----------------------------------------------------------------------------
   END f_get_lstniveles;

   FUNCTION f_nivel_usuario(
      psseguro IN NUMBER,
      ptablas IN VARCHAR2,
      p_nivel OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_iax_psu.f_nivel_usuario';
      vparam         VARCHAR2(500) := 'par真metros -  ';
      w_pas          PLS_INTEGER := 1;
      w_nivel        NUMBER;
-----------------------------------------------------------------------------
   BEGIN
      w_pas := 2;
      p_nivel := pac_md_psu.f_nivel_usuario(psseguro, ptablas, mensajes);
      w_pas := 3;
      RETURN(0);
   --
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, w_pas, vparam);
         RETURN(1);
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, w_pas, vparam);
         RETURN(1);
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, w_pas, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN(1);
-----------------------------------------------------------------------------
   END f_nivel_usuario;

      /*Miraremos si hay controles manuales pendientes de autorizar,
   en caso de que hay devolveremos mensaje diciendo que no podemos autorizar/rechazar y se deberan
   tratar individualmente manualmente*/
   FUNCTION f_hay_controles_manuales(
      psseguro IN NUMBER,
      ptablas IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_iax_psu.f_hay_controles_manuales';
      vparam         VARCHAR2(500) := 'par真metros -  ';
      w_pas          PLS_INTEGER := 1;
      vnumerr        NUMBER;
-----------------------------------------------------------------------------
   BEGIN
      w_pas := 2;
      vnumerr := pac_md_psu.f_hay_controles_manuales(psseguro, ptablas, mensajes);
      w_pas := 3;
      RETURN(vnumerr);
   --
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, w_pas, vparam);
         RETURN(1);
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, w_pas, vparam);
         RETURN(1);
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, w_pas, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN(1);
-----------------------------------------------------------------------------
   END f_hay_controles_manuales;

   /*****************************************************************************
        Recupera la llista de p真lisses amb controls de PSU, cridar真 la funci真 de
        la capa intermitja PAC_MD_PSU.F_GET_CONSULTA.

        param in      : P_SPRODUC  Codi producte.
        param in      : P_NPOLIZA  Nombre de p真lissa.
        param in      : P_NSOLICI  Nombre de sol真licitud.
        param in      : P_CAUTREC  Codi estat del control.
        param in out  : P_MENSAJES Missatges de sortida.
   *****************************************************************************/
   FUNCTION F_LEE_HIS_PSU_RETENIDAS ( --ramiro
    p_sseguro IN NUMBER,
		p_nversion IN NUMBER,
		p_nriesgo IN NUMBER,
		p_nmovimi IN NUMBER,
		p_this_psu_retenidas OUT T_IAX_PSU_RETENIDAS,
		mensajes OUT t_iax_mensajes)
    Return	NUMBER IS
    e_param_error EXCEPTION;
    e_object_error EXCEPTION;
    w_retorn NUMBER;
    vparam VARCHAR2(2000) := p_sseguro||p_nversion||p_nriesgo||p_nmovimi;
    w_cidioma      idiomas.cidioma%TYPE := pac_md_common.f_get_cxtidioma();
    BEGIN

     IF p_sseguro IS NULL THEN
         RAISE e_param_error;
      END IF;

     w_retorn := PAC_MD_PSU.F_LEE_HIS_PSU_RETENIDAS(p_sseguro,p_nversion,p_nriesgo,p_nmovimi,w_cidioma,p_this_psu_retenidas,mensajes);

      IF w_retorn <> 0 THEN
         RAISE e_object_error;
      END IF;



      RETURN 0;

   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, 'PAC_IAX_PSU.F_LEE_HIS_PSU_RETENIDAS.e_param_error', 1000005, 1, vparam);
         RETURN(1);
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, 'PAC_IAX_PSU.F_LEE_HIS_PSU_RETENIDAS.e_object_error', 1000006, 1, vparam,
                                           w_retorn);
         RETURN(1);
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, 'PAC_IAX_PSU.F_LEE_HIS_PSU_RETENIDAS.OTHERS', 1000001, 1, vparam, NULL,
                                           SQLCODE, SQLERRM);
         RETURN(1);

    END F_LEE_HIS_PSU_RETENIDAS; --ramiro


    /*****************************************************************************
        Recupera la llista de p真lisses amb controls de PSU, cridar真 la funci真 de
        la capa intermitja PAC_MD_PSU.F_GET_CONSULTA.

        param in      : P_SPRODUC  Codi producte.
        param in      : P_NPOLIZA  Nombre de p真lissa.
        param in      : P_NSOLICI  Nombre de sol真licitud.
        param in      : P_CAUTREC  Codi estat del control.
        param in out  : P_MENSAJES Missatges de sortida.
   *****************************************************************************/
FUNCTION F_LEE_HIS_PSUCONTROLSEG(
    p_sseguro IN NUMBER,
		p_nversion IN NUMBER,
		p_nriesgo IN NUMBER,
		p_nmovimi IN NUMBER,
		p_ccontrol IN NUMBER,
		p_this_psucontrolseg OUT T_IAX_PSU,
		mensajes OUT t_iax_mensajes
)
    return number IS
    e_param_error EXCEPTION;
    e_object_error EXCEPTION;
    w_retorn NUMBER;
    vparam VARCHAR2(2000) := p_sseguro||p_nversion||p_nriesgo||p_nmovimi;
    w_cidioma      idiomas.cidioma%TYPE := pac_md_common.f_get_cxtidioma();
    BEGIN

   -- p_tab_error(f_sysdate, f_user, 'ramiro iax', NULL, 'ramiro PAC_PSU.F_LEE_HIS_PSU_RETENIDAS = ' || vparam, '** Codi Error = ' || SQLERRM);

     IF p_sseguro IS NULL THEN
         RAISE e_param_error;
      END IF;

     w_retorn := PAC_MD_PSU.F_LEE_HIS_PSUCONTROLSEG(p_sseguro,p_nversion,p_nriesgo,
                                                    p_nmovimi,p_ccontrol,w_cidioma,p_this_psucontrolseg,
                                                  mensajes);

      IF w_retorn <> 0 THEN
         RAISE e_object_error;
      END IF;


      RETURN 0;

   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, 'PAC_IAX_PSU.F_LEE_HIS_PSU_RETENIDAS', 1000005, 1, vparam);
         RETURN(1);
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, 'PAC_IAX_PSU.F_LEE_HIS_PSU_RETENIDAS', 1000006, 1, vparam,
                                           w_retorn);
         RETURN(1);
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, 'PAC_IAX_PSU.F_LEE_HIS_PSU_RETENIDAS', 1000001, 1, vparam, NULL,
                                           SQLCODE, SQLERRM);
         RETURN(1);

    END F_LEE_HIS_PSUCONTROLSEG;







   /*****************************************************************************
        Recupera la llista de p真lisses amb controls de PSU, cridar真 la funci真 de
        la capa intermitja PAC_MD_PSU.F_GET_CONSULTA.

        param in      : P_SPRODUC  Codi producte.
        param in      : P_NPOLIZA  Nombre de p真lissa.
        param in      : P_NSOLICI  Nombre de sol真licitud.
        param in      : P_CAUTREC  Codi estat del control.
        param in out  : P_MENSAJES Missatges de sortida.
   *****************************************************************************/

FUNCTION F_LEE_PSU_SUBESTADOSPROP( --ramiro
    p_sseguro IN NUMBER,
		p_nversion IN NUMBER,
		p_nversionsubest IN NUMBER,
		p_nmovimi IN NUMBER,
		P_TPSU_SUBESTADOSPROP OUT T_IAX_PSU_SUBESTADOSPROP,
		mensajes  OUT t_iax_mensajes

)
    return number   is
    e_param_error EXCEPTION;
    e_object_error EXCEPTION;
    w_retorn NUMBER;
    vparam VARCHAR2(2000) := p_sseguro||p_nversion||p_nmovimi;
    w_cidioma      idiomas.cidioma%TYPE := pac_md_common.f_get_cxtidioma();
begin

IF p_sseguro IS NULL THEN
         RAISE e_param_error;
      END IF;


     w_retorn := PAC_MD_PSU.F_LEE_PSU_SUBESTADOSPROP(p_sseguro,p_nversion,p_nversionsubest,
                                                    p_nmovimi,w_cidioma,p_tpsu_subestadosprop,mensajes);

      IF w_retorn <> 0 THEN
         RAISE e_object_error;
      END IF;

p_tab_error(f_sysdate, f_user, 'PAC_PSU IAX', NULL, 'PAC_PSU.F_LEE_HIS_PSUCONTROLSEG = ' || vparam, '** Codi Error = ' || SQLERRM);
return 0;

   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, 'PAC_IAX_PSU.F_LEE_HIS_PSU_RETENIDAS', 1000005, 1, vparam);
         RETURN(1);
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, 'PAC_IAX_PSU.F_LEE_HIS_PSU_RETENIDAS', 1000006, 1, vparam,
                                           w_retorn);
         RETURN(1);
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, 'PAC_IAX_PSU.F_LEE_HIS_PSU_RETENIDAS', 1000001, 1, vparam, NULL,
                                           SQLCODE, SQLERRM);
         RETURN(1);

    END F_LEE_PSU_SUBESTADOSPROP; --ramiro


/*****************************************************************************
    Recupera la llista de p真lisses amb controls de PSU, cridar真 la funci真 de
    la capa intermitja PAC_MD_PSU.F_GET_CONSULTA.

    param in      : P_SPRODUC  Codi producte.
    param in      : P_NPOLIZA  Nombre de p真lissa.
    param in      : P_NSOLICI  Nombre de sol真licitud.
    param in      : P_CAUTREC  Codi estat del control.
    param in out  : P_MENSAJES Missatges de sortida.
*****************************************************************************/
FUNCTION F_INS_PSU_SUBESTADOSPROP( --ramiro
    p_sseguro IN NUMBER,
		p_nversion IN NUMBER,
		p_nmovimi IN NUMBER,
		P_CSUBESTADO IN NUMBER,
		P_COBSERVACIONES IN VARCHAR2,
    mensajes OUT t_iax_mensajes
)
    return number is

    e_param_error EXCEPTION;
    e_object_error EXCEPTION;
    w_retorn NUMBER;
    vparam VARCHAR2(2000) := p_sseguro||p_nversion||p_nmovimi;
    w_cidioma      idiomas.cidioma%TYPE := pac_md_common.f_get_cxtidioma();

begin

IF p_sseguro IS NULL THEN
         RAISE e_param_error;
      END IF;

     W_RETORN := PAC_MD_PSU.F_INS_PSU_SUBESTADOSPROP(P_SSEGURO,P_NVERSION,
                                                    p_nmovimi,p_csubestado,p_cobservaciones,mensajes);

      IF w_retorn <> 0 THEN
         RAISE e_object_error;
      END IF;

commit;
return 0;

EXCEPTION
  WHEN e_param_error THEN
     pac_iobj_mensajes.p_tratarmensaje(mensajes, 'PAC_IAX_PSU.F_LEE_HIS_PSU_RETENIDAS', 1000005, 1, vparam);
     RETURN(1);
  WHEN e_object_error THEN
     pac_iobj_mensajes.p_tratarmensaje(mensajes, 'PAC_IAX_PSU.F_LEE_HIS_PSU_RETENIDAS', 1000006, 1, vparam,
                                       w_retorn);
     RETURN(1);
  WHEN OTHERS THEN
     pac_iobj_mensajes.p_tratarmensaje(mensajes, 'PAC_IAX_PSU.F_LEE_HIS_PSU_RETENIDAS', 1000001, 1, vparam, NULL,
                                       SQLCODE, SQLERRM);
     RETURN(1);

END F_INS_PSU_SUBESTADOSPROP;    --ramiro
END pac_iax_psu;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_PSU" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_PSU" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_PSU" TO "PROGRAMADORESCSI";
