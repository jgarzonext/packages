--------------------------------------------------------
--  DDL for Package Body PAC_MD_PSU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MD_PSU" IS
    /******************************************************************************
       NOMBRE    : PAC_IAX_PSU
       ARCHIVO   : PAC_IAX_PSU.PKS
       PROPÓSITO : Package con funciones propias de la funcionalidad de
                   Política de Subscripción, per gestionar els controls.

       REVISIONES:
       Ver    Fecha      Autor     Descripción
       ------ ---------- ------ ------------------------------------------------
       1.0    01/07/2009 NMM    Creació del package.
       2.0    19/07/2010 PFA    15459: MDP003 - PSU-MDP Controls rebutjables i visibilitat
       3.0    14/08/2013 RCL    3. 0027262: LCOL - Fase Mejoras - Autorización masiva de propuestas retenidas
       4.0    21/02/2014 JDS    4. 0027416: POSRA300 - Configuracion Ramo Accidentes - Accidentes Corto Plazo
       5.0    06/05/2015  VCG    0035288-0203030-INT033-Controlar longitud de observaciones al autorizar o rechazar una propuesta
       5.1    08/02/20158 HAG    AXIS13781-Controlar longitud de observaciones migradas
   ******************************************************************************/
   FUNCTION f_inicia_psu(
      p_tablas IN VARCHAR2,
      p_sseguro IN NUMBER,
      p_accion IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_psu.f_inicia_psu';
      vparam         VARCHAR2(500)
         := 'parámetros -  p_sseguro: ' || p_sseguro || ', p_tablas: ' || p_tablas
            || ',p_accion: ' || p_accion;
      w_cidioma      idiomas.cidioma%TYPE := pac_md_common.f_get_cxtidioma();
      vcreteni       NUMBER;
      vnumerr        NUMBER;
      vcont          NUMBER;
   --
   BEGIN
      IF p_tablas = 'EST' THEN
         SELECT COUNT(1)
           INTO vcont
           FROM estseguros
          WHERE sseguro = p_sseguro;
      ELSE
         SELECT COUNT(1)
           INTO vcont
           FROM seguros
          WHERE sseguro = p_sseguro;
      END IF;

      IF vcont > 0 THEN
         vnumerr := pac_psu.f_inicia_psu(p_tablas, p_sseguro, p_accion, w_cidioma, vcreteni);

         IF vnumerr != 0 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
            vcreteni := 1;
         END IF;

         IF vcreteni != 0 THEN
            IF p_tablas = 'EST' THEN
               UPDATE estseguros
                  SET creteni = 2
                WHERE sseguro = p_sseguro;
            ELSE
               UPDATE seguros
                  SET creteni = 2
                WHERE sseguro = p_sseguro;
            END IF;

            RETURN 1;
         END IF;
      END IF;

      RETURN(0);
   EXCEPTION
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, 1, vparam);
         RETURN(1);
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, 1, vparam, NULL,
                                           SQLCODE, SQLERRM);
         RETURN(1);
-----------------------------------------------------------------------------
   END f_inicia_psu;

/*****************************************************************************
     Recupera la llista de pòlisses amb controls de PSU, cridarà la funció de
     la capa intermitja PAC_MD_PSU.F_GET_CONSULTA.

     param in      : P_SPRODUC  Codi producte.
     param in      : P_NPOLIZA  Nombre de pòlissa.
     param in      : P_NSOLICI  Nombre de sol·licitud.
     param in      : P_CAUTREC  Codi estat del control.
     param in out  : P_MENSAJES Missatges de sortida.
*****************************************************************************/
-----------------------------------------------------------------------------
   FUNCTION f_get_consulta(
      p_sproduc IN NUMBER,
      p_npoliza IN NUMBER,
      p_nsolici IN NUMBER,
      p_cautrec IN NUMBER,
      p_mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_psu.f_get_consulta';
      vparam         VARCHAR2(500)
         := 'parámetros - p_sproduc: ' || p_sproduc || ', p_npoliza: ' || p_npoliza
            || ', p_nsolici: ' || p_nsolici || ' ,p_cautrec: ' || p_cautrec;
      w_cidioma      idiomas.cidioma%TYPE := pac_md_common.f_get_cxtidioma();
      w_refcursor    sys_refcursor;
   --
   BEGIN
      w_refcursor := pac_psu.f_polizas_con_control(p_sproduc, p_nsolici, p_npoliza, p_cautrec,
                                                   w_cidioma);
      /*IF w_refcursor IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(p_mensajes, 1, 1);
         RAISE e_object_error;
      END IF;*/
      RETURN(w_refcursor);
   EXCEPTION
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(p_mensajes, vobjectname, 1000006, 1, vparam);
         RETURN(w_refcursor);
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(p_mensajes, vobjectname, 1000001, 1, vparam, NULL,
                                           SQLCODE, SQLERRM);
         RETURN(w_refcursor);
-----------------------------------------------------------------------------
   END f_get_consulta;

/*****************************************************************************
   Recupera la llista de pòlisses amb controls de PSU, cridarà la funció de
   la capa intermitja PAC_MD_PSU.F_LEE_CONTROLES.

   param in      : P_SSEGURO  Codi assegurança.
   param in out  : P_MENSAJES Missatges de sortida.
*****************************************************************************/
-----------------------------------------------------------------------------
   FUNCTION f_lee_controles(p_sseguro IN NUMBER, p_mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_psu.f_lee_controles';
      vparam         VARCHAR2(500) := 'parámetros - p_sseguro: ' || p_sseguro;
      w_cidioma      idiomas.cidioma%TYPE := pac_md_common.f_get_cxtidioma();
      w_cusuari      usuarios.cusuari%TYPE := pac_md_common.f_get_cxtusuario();
      w_refcursor    sys_refcursor;
      w_tablas       VARCHAR2(1) := 'POL';
      w_nriesgo      riesgos.nriesgo%TYPE := NULL;
      w_nmovimi      movseguro.nmovimi%TYPE := NULL;
   --
   BEGIN
      --W_TABLAS := PAC_IAX_PRODUCCION.DEFINE_MODE(PMODE, P_MENSAJES);
      w_refcursor := pac_psu.f_lee_controles(w_tablas, p_sseguro, w_nriesgo, w_nmovimi,
                                             w_cusuari, w_cidioma);
      /*IF w_refcursor IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(p_mensajes, 1, 1);
         RAISE e_object_error;
      END IF;*/
      RETURN(w_refcursor);
   EXCEPTION
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(p_mensajes, vobjectname, 1000006, 1, vparam);
         RETURN(w_refcursor);
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(p_mensajes, vobjectname, 1000001, 1, vparam, NULL,
                                           SQLCODE, SQLERRM);
         RETURN(w_refcursor);
-----------------------------------------------------------------------------
   END f_lee_controles;

/*****************************************************************************
  Graba les observacions del control sel·leccionat, cridarà la funció de
  la capa intermitja PAC_MD_PSU.F_GRABAOBSERVACIONES.

  param in      : P_SSEGURO  Codi assegurança.
  param in      : P_NRIESGO  Nombre risc.
  param in      : P_CGARANT  Codi de la garantia.
  param in      : P_CCONTROL Codi de control.
  param in      : P_TOBSERV  Observacions.
  param in      : P_TOBSERV  Missatges de sortida.

  Retorna 0 -> OK o bé 1 -> NOTOK.
*****************************************************************************/
-----------------------------------------------------------------------------
   FUNCTION f_grabaobservaciones(
      p_sseguro IN NUMBER,
      p_nriesgo IN NUMBER,
      p_cgarant IN NUMBER,
      p_ccontrol IN NUMBER,
      p_tobserv IN VARCHAR2,
      p_mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_psu.f_grabaobservaciones';
      vparam         VARCHAR2(500)
         := 'parámetros - p_sseguro: ' || p_sseguro || ', p_nriesgo: ' || p_nriesgo
            || ', p_cgarant: ' || p_cgarant || ' ,p_ccontrol: ' || p_ccontrol
            || ', p_tobserv: ' || p_tobserv;
      w_retorn       NUMBER;
   --
   BEGIN
      w_retorn := pac_psu.f_grabaobservaciones(p_sseguro, p_nriesgo, p_cgarant, p_ccontrol,
                                               p_tobserv);

      IF w_retorn <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(p_mensajes, 1, w_retorn);
         RAISE e_object_error;
      END IF;

      RETURN(0);
   EXCEPTION
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(p_mensajes, vobjectname, 1000006, 1, vparam,
                                           w_retorn);
         RETURN(1);
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(p_mensajes, vobjectname, 1000001, 1, vparam, NULL,
                                           SQLCODE, SQLERRM);
         RETURN(1);
-----------------------------------------------------------------------------
   END f_grabaobservaciones;

-----------------------------------------------------------------------------
   FUNCTION f_get_colec_psu(
      p_sseguro IN seguros.sseguro%TYPE,
      p_nmovimi IN movseguro.nmovimi%TYPE,
      p_nriesgo IN riesgos.nriesgo%TYPE,
      p_idioma IN idiomas.cidioma%TYPE,
      p_tablas IN VARCHAR2 DEFAULT NULL,
      p_testpol OUT VARCHAR2,
      p_cestpol OUT NUMBER,
      p_cnivelbpm OUT NUMBER,
      p_tnivelbpm OUT VARCHAR2,
      pobpsu_retenidas OUT ob_iax_psu_retenidas,
      p_tpsus OUT t_iax_psu,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      --
      w_retorn       NUMBER;
      cursor_psu     sys_refcursor;
      w_tpsus        ob_iax_psu := ob_iax_psu();
      vobjectname    VARCHAR2(500) := 'pac_md_psu.f_get_colec_psu';
      vparam         VARCHAR2(500)
         := 'parms - p_sseguro: ' || p_sseguro || ', p_nriesgo: ' || p_nriesgo
            || ', p_nmovimi: ' || p_nmovimi || ' ,p_idioma: ' || p_idioma || ', p_tablas: '
            || p_tablas;
      vquery         VARCHAR2(2000);
      vnriesgo       NUMBER;
      vsseguro       NUMBER;
      vnmovimi       NUMBER;
      vidioma        NUMBER := pac_md_common.f_get_cxtidioma;
      v_aut          NUMBER;
      v_total        NUMBER;
      v_nocurremax   NUMBER;
      vsproduc       NUMBER;
      verr           NUMBER := 1;
      w_total        NUMBER;
   --
   BEGIN
      IF mensajes IS NOT NULL THEN
         IF mensajes.COUNT > 0 THEN
            RAISE e_object_error;
         END IF;
      END IF;

      verr := 2;

      IF p_tablas = 'EST' THEN
         SELECT COUNT(*)
           INTO w_total
           FROM estpsucontrolseg
          WHERE sseguro = p_sseguro;
      ELSE
         SELECT COUNT(*)
           INTO w_total
           FROM psucontrolseg
          WHERE sseguro = p_sseguro;
      END IF;

      verr := 2;

      IF w_total > 0 THEN
         w_retorn := pac_psu.f_get_colec_psu(p_sseguro, p_nmovimi, p_nriesgo, p_idioma,
                                             p_tablas, vquery, p_testpol, p_cestpol,
                                             p_cnivelbpm, p_tnivelbpm);
         verr := 3;
         cursor_psu := pac_md_listvalores.f_opencursor(vquery, mensajes);
         p_tpsus := t_iax_psu();
         verr := 4;

         LOOP   --ob_iax_psu
            FETCH cursor_psu
             INTO w_tpsus.sseguro, w_tpsus.npoliza, w_tpsus.observ, w_tpsus.cusuaur,
                  w_tpsus.tusuaur, w_tpsus.nriesgo, w_tpsus.cnivelr, w_tpsus.tnivelr,
                  w_tpsus.nvalor, w_tpsus.cusumov, w_tpsus.tusumov, w_tpsus.cnivelu,
                  w_tpsus.tnivelu, w_tpsus.tomador, w_tpsus.ccontrol, w_tpsus.tcontrol,
                  w_tpsus.tdesniv, w_tpsus.cgarant, w_tpsus.tgarant, w_tpsus.cautrec,
                  w_tpsus.tautrec, w_tpsus.fautrec, w_tpsus.editar, w_tpsus.fmovimi,
                  w_tpsus.nmovimi, w_tpsus.nocurre, w_tpsus.establoquea, w_tpsus.ordenbloquea,
                  w_tpsus.nvalorinf, w_tpsus.nvalorsuper, w_tpsus.nvalortope,
                  w_tpsus.autmanual, w_tpsus.numrisk;

            EXIT WHEN cursor_psu%NOTFOUND;
            verr := 5;
            vsseguro := w_tpsus.sseguro;
            vnmovimi := w_tpsus.nmovimi;

            IF p_tablas = 'EST' THEN
               SELECT sproduc
                 INTO vsproduc
                 FROM estseguros
                WHERE sseguro = vsseguro;
            ELSE
               SELECT sproduc
                 INTO vsproduc
                 FROM seguros
                WHERE sseguro = vsseguro;
            END IF;

            IF w_tpsus.nriesgo IS NOT NULL THEN
               SELECT COUNT(*)
                 INTO w_total
                 FROM psu_controlpro
                WHERE cgarant = w_tpsus.cgarant
                  AND sproduc = vsproduc
                  AND ccontrol = w_tpsus.ccontrol
                  AND ctratar IN(3, 6);   --Evaluar si la PSU que se trata es a nivel de póliza

               IF (w_total = 0) THEN
                  --A nivel de riesgo o garantia
                  w_tpsus.triesgo := pac_md_obtenerdatos.f_desriesgos(p_tablas, p_sseguro,
                                                                      w_tpsus.nriesgo,
                                                                      mensajes);
               ELSE
                  --A nivel de poliza: cuando la PSU es a nivel de póliza (psu_controlpro.ctratar in (3,6)) en la consulta de pólizas y
                  --en el resumen de la contratación saldria como descripción del riesgo el riesgo numero 1 porque siempre se está grabando en PSUCONTROLSEG.NRIESGO el valor 1.
                  w_tpsus.triesgo := NULL;
               END IF;
            END IF;

            verr := 6;

            BEGIN
               SELECT ccritico
                 INTO w_tpsus.ccritico
                 FROM psu_controlpro
                WHERE ccontrol = w_tpsus.ccontrol
                  AND sproduc = vsproduc;
            EXCEPTION
               WHEN OTHERS THEN
                  w_tpsus.ccritico := 0;
            END;

            verr := 7;
            p_tpsus.EXTEND;
            p_tpsus(p_tpsus.LAST) := w_tpsus;
            w_tpsus := ob_iax_psu();
         END LOOP;

         IF cursor_psu%ISOPEN THEN
            CLOSE cursor_psu;
         END IF;

         pobpsu_retenidas := ob_iax_psu_retenidas();
         verr := 8;

         IF p_tablas = 'POL' THEN
            BEGIN
               SELECT sseguro, nmovimi,
                      fmovimi, cmotret,
                      cnivelbpm, cusuret,
                      ffecret, cusuaut,
                      ffecaut, SUBSTR(observ,1,2000), --hag modificar el objeto
                      ff_desvalorfijo(800069, vidioma, cmotret) tmotret,
                      pac_psu.f_tcnivel(cnivelbpm, vidioma) tnivelbpm,
                      (SELECT tusunom
                         FROM usuarios
                        WHERE cusuari = cusuret) tusuret, (SELECT tusunom
                                                             FROM usuarios
                                                            WHERE cusuari = cusuaut) tusuaut
                 INTO pobpsu_retenidas.sseguro, pobpsu_retenidas.nmovimi,
                      pobpsu_retenidas.fmovimi, pobpsu_retenidas.cmotret,
                      pobpsu_retenidas.cnivelbpm, pobpsu_retenidas.cusuret,
                      pobpsu_retenidas.ffecret, pobpsu_retenidas.cusuaut,
                      pobpsu_retenidas.ffecaut, pobpsu_retenidas.observ,
                      pobpsu_retenidas.tmotret,
                      pobpsu_retenidas.tnivelbpm,
                      pobpsu_retenidas.tusuret, pobpsu_retenidas.tusuaut
                 FROM psu_retenidas
                WHERE sseguro = vsseguro
                  AND nmovimi = vnmovimi;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  pobpsu_retenidas := ob_iax_psu_retenidas();
            END;

            verr := 9;

            SELECT COUNT(1)
              INTO v_aut
              FROM psucontrolseg
             WHERE sseguro = vsseguro
               AND nmovimi = vnmovimi
               AND cautrec = 1
               AND nocurre = 1;   --primera ocurrència

            SELECT MAX(nocurre)
              INTO v_nocurremax
              FROM psucontrolseg
             WHERE sseguro = vsseguro
               AND nmovimi = vnmovimi;

            verr := 10;

            BEGIN
               SELECT COUNT(1)
                 INTO pobpsu_retenidas.ccritico
                 FROM psu_controlpro pc, psucontrolseg ps
                WHERE pc.ccontrol = ps.ccontrol
                  AND sproduc = vsproduc
                  AND pc.ccritico = 1
                  --   AND ps.cautrec = 1
                  AND ps.nocurre = v_nocurremax
                  AND ps.nmovimi = vnmovimi
                  AND p_cestpol = 1
                  AND ps.sseguro = vsseguro;
            EXCEPTION
               WHEN OTHERS THEN
                  pobpsu_retenidas.ccritico := NULL;
            END;

            IF v_nocurremax != 1 THEN
               /* SELECT MAX(nocurre)
                  INTO v_total
                  FROM psucontrolseg
                 WHERE sseguro = vsseguro
                   AND nmovimi = vnmovimi
                   AND nocurre = 1;

                IF v_total = v_aut THEN*/
               pobpsu_retenidas.nocontinua := 1;
            --END IF;
            END IF;
         ELSE
            verr := 11;

            BEGIN
               SELECT sseguro, nmovimi,
                      fmovimi, cmotret,
                      cnivelbpm, cusuret,
                      ffecret, cusuaut,
                      ffecaut, observ,
                      ff_desvalorfijo(800069, vidioma, cmotret) tmotret,
                      pac_psu.f_tcnivel(cnivelbpm, vidioma) tnivelbpm,
                      (SELECT tusunom
                         FROM usuarios
                        WHERE cusuari = cusuret) tusuret, (SELECT tusunom
                                                             FROM usuarios
                                                            WHERE cusuari = cusuaut) tusuaut
                 INTO pobpsu_retenidas.sseguro, pobpsu_retenidas.nmovimi,
                      pobpsu_retenidas.fmovimi, pobpsu_retenidas.cmotret,
                      pobpsu_retenidas.cnivelbpm, pobpsu_retenidas.cusuret,
                      pobpsu_retenidas.ffecret, pobpsu_retenidas.cusuaut,
                      pobpsu_retenidas.ffecaut, pobpsu_retenidas.observ,
                      pobpsu_retenidas.tmotret,
                      pobpsu_retenidas.tnivelbpm,
                      pobpsu_retenidas.tusuret, pobpsu_retenidas.tusuaut
                 FROM estpsu_retenidas
                WHERE sseguro = vsseguro
                  AND nmovimi = vnmovimi;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  pobpsu_retenidas := ob_iax_psu_retenidas();
            END;

            verr := 12;

            SELECT COUNT(1)
              INTO v_aut
              FROM estpsucontrolseg
             WHERE sseguro = vsseguro
               AND nmovimi = vnmovimi
               AND cautrec = 1
               AND nocurre = 1;   --primera ocurrència

            SELECT MAX(nocurre)
              INTO v_nocurremax
              FROM estpsucontrolseg
             WHERE sseguro = vsseguro
               AND nmovimi = vnmovimi;

            verr := 13;

            BEGIN
               SELECT sproduc
                 INTO vsproduc
                 FROM estseguros
                WHERE sseguro = vsseguro;

               SELECT COUNT(1)
                 INTO pobpsu_retenidas.ccritico
                 FROM psu_controlpro pc, estpsucontrolseg ps
                WHERE pc.ccontrol = ps.ccontrol
                  AND pc.sproduc = vsproduc
                  AND p_cestpol = 1
                  AND pc.ccritico = 1
                  AND ps.cautrec <> 1   -- Bug 26923/148711 - APD - 09/07/2013
                  AND ps.nocurre = v_nocurremax
                  AND ps.nmovimi = vnmovimi
                  AND ps.sseguro = vsseguro;
            EXCEPTION
               WHEN OTHERS THEN
                  pobpsu_retenidas.ccritico := NULL;
            END;

            IF v_nocurremax != 1 THEN
               /* SELECT MAX(nocurre)
                  INTO v_total
                  FROM estpsucontrolseg
                 WHERE sseguro = vsseguro
                   AND nmovimi = vnmovimi
                   AND nocurre = 1;

                IF v_total = v_aut THEN*/
               pobpsu_retenidas.nocontinua := 1;
            --  END IF;
            END IF;
         END IF;
      END IF;

      verr := 14;
      --
      RETURN(0);
   --
   EXCEPTION
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, verr, vparam,
                                           w_retorn);

         IF cursor_psu%ISOPEN THEN
            CLOSE cursor_psu;
         END IF;

         RETURN(1);
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, verr, vparam, NULL,
                                           SQLCODE, SQLERRM);

         IF cursor_psu%ISOPEN THEN
            CLOSE cursor_psu;
         END IF;

         RETURN(1);
   END f_get_colec_psu;

-----------------------------------------------------------------------------
   FUNCTION f_get_visible_pol_subscripcio(p_sproduc IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'p_sproduc:' || p_sproduc;
      vobject        VARCHAR2(200) := 'PAC_MD_PSU.f_get_visible_pol_subscripcio';
      verror         NUMBER;
   BEGIN
      IF p_sproduc IS NULL THEN
         RAISE e_param_error;
      END IF;

      RETURN(NVL(pac_parametros.f_parproducto_n(p_sproduc, 'PSU'), 0));
   --
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN(1);
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN(1);
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN(1);
   END f_get_visible_pol_subscripcio;

   /*****************************************************************************
      Gestiona el control sel·leccionat, cridarà la funció de
      la capa intermitja PAC_MD_PSU.F_AUTORIZA.

      param in      : P_SSEGURO  Codi assegurança.
      param in      : P_NRIESGO  Nombre risc.
      param in      : P_CGARANT  Codi de la garantia.
      param in      : P_CCONTROL Codi de control.
      param in      : P_TOBSERV  Observacions.
      param in      : P_TOBSERV  Missatges de sortida.

      Retorna 0 -> OK o bé 1 -> NOTOK.
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
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_psu.f_autoriza';
      -- BUG 0035288-0203030 - 06/05/2015-VCG- No debe contemplar la variable p_tobserv
      vparam         VARCHAR2(500)
         := 'parámetros - p_sseguro: ' || p_sseguro || ', p_nriesgo: ' || p_nriesgo
            || ', p_cgarant: ' || p_cgarant || ' ,p_ccontrol: ' || p_ccontrol;
      w_retorn       NUMBER;
      w_nivell       NUMBER;
      w_usuari       usuarios.cusuari%TYPE := pac_md_common.f_get_cxtusuario();
      w_sproduc      productos.sproduc%TYPE;
      w_pas          PLS_INTEGER;
      v_tabla        VARCHAR2(15);
   --
   BEGIN
      w_pas := 1;

      IF p_tablas = 'EST' THEN
         SELECT sproduc
           INTO w_sproduc
           FROM estseguros
          WHERE sseguro = p_sseguro;
      ELSE
         SELECT sproduc
           INTO w_sproduc
           FROM seguros
          WHERE sseguro = p_sseguro;
      END IF;

      w_pas := 2;
      w_nivell := pac_psu.f_nivel_usuari_psu(w_usuari, w_sproduc);
      w_pas := 3;
      w_retorn := pac_psu.f_actualiza(p_sseguro, p_nriesgo, p_nmovimi, p_cgarant, p_ccontrol,
                                      w_nivell, p_cautrec, p_tobserv, p_nvalortope, p_nocurre,
                                      p_nvalor, p_nvalorinf, p_nvalorsuper, p_nivelr,
                                      p_establoquea, p_autmanual, p_tablas, p_modo,
                                      p_numriesgo, pac_md_common.f_get_cxtidioma);

      IF w_retorn <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, w_retorn);
         RAISE e_object_error;
      END IF;

      RETURN(0);
   EXCEPTION
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, w_pas, vparam,
                                           w_retorn);
         RETURN(1);
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, w_pas, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN(1);
-----------------------------------------------------------------------------
   END f_gestion_control;

   FUNCTION f_get_lstniveles(p_refcursor OUT sys_refcursor, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_md_psu.f_get_lstniveles';
      vparam         VARCHAR2(500) := 'parámetros -  ';
      --w_refcursor    sys_refcursor;
      w_pas          PLS_INTEGER := 1;
      vquery         VARCHAR2(2000);
      nerror         NUMBER;
-----------------------------------------------------------------------------
   BEGIN
      w_pas := 2;
      nerror := pac_psu.f_get_lstniveles(pac_md_common.f_get_cxtidioma, vquery);
      w_pas := 3;

      IF nerror <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, nerror);
         RAISE e_object_error;
      END IF;

      p_refcursor := pac_iax_listvalores.f_opencursor(vquery, mensajes);
      RETURN(0);
   --
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, w_pas, vparam);

         IF p_refcursor%ISOPEN THEN
            CLOSE p_refcursor;
         END IF;

         RETURN(1);
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, w_pas, vparam);

         IF p_refcursor%ISOPEN THEN
            CLOSE p_refcursor;
         END IF;

         RETURN(1);
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, w_pas, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF p_refcursor%ISOPEN THEN
            CLOSE p_refcursor;
         END IF;

         RETURN(1);
-----------------------------------------------------------------------------
   END f_get_lstniveles;

   FUNCTION f_nivel_usuario(
      p_sseguro IN NUMBER,
      p_tablas IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_psu.f_nivel_usuario';
      vparam         VARCHAR2(500)
                      := 'parámetros - p_sseguro: ' || p_sseguro || ', p_tablas: ' || p_tablas;
      w_retorn       NUMBER;
      w_nivell       NUMBER;
      w_usuari       usuarios.cusuari%TYPE := pac_md_common.f_get_cxtusuario();
      w_sproduc      productos.sproduc%TYPE;
      w_pas          PLS_INTEGER;
      v_tabla        VARCHAR2(15);
   --
   BEGIN
      w_pas := 1;

      IF p_tablas = 'EST' THEN
         SELECT sproduc
           INTO w_sproduc
           FROM estseguros
          WHERE sseguro = p_sseguro;
      ELSE
         SELECT sproduc
           INTO w_sproduc
           FROM seguros
          WHERE sseguro = p_sseguro;
      END IF;

      w_pas := 2;
      w_nivell := pac_psu.f_nivel_usuari_psu(w_usuari, w_sproduc);
      RETURN w_nivell;
   EXCEPTION
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, w_pas, vparam,
                                           w_retorn);
         RETURN(1);
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, w_pas, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN(1);
   END f_nivel_usuario;

--

   /*Miraremos si hay controles manuales pendientes de autorizar,
   en caso de que hay devolveremos mensaje diciendo que no podemos autorizar/rechazar y se deberan
   tratar individualmente manualmente*/
   FUNCTION f_hay_controles_manuales(
      psseguro IN NUMBER,
      ptablas IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_iax_psu.f_hay_controles_manuales';
      vparam         VARCHAR2(500) := 'parámetros - psseguro : ' || psseguro;
      w_pas          PLS_INTEGER := 1;
      vnumerr        NUMBER;
-----------------------------------------------------------------------------
   BEGIN
      w_pas := 2;
      vnumerr := pac_psu.f_hay_controles_manuales(psseguro, ptablas);
      w_pas := 3;

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

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
   END f_hay_controles_manuales;

   FUNCTION f_hay_controles_pendientes(
      psseguro IN NUMBER,
      ptablas IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_PSU.f_hay_controles_pendientes';
      vparam         VARCHAR2(500) := 'parámetros - psseguro : ' || psseguro;
      w_pas          PLS_INTEGER := 1;
      vnumerr        NUMBER;
   BEGIN
      w_pas := 2;
      vnumerr := pac_psu.f_hay_controles_pendientes(psseguro, ptablas);
      w_pas := 3;

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN(0);
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
   END f_hay_controles_pendientes;

----------------------------------------------------------------------------------------------
FUNCTION F_LEE_HIS_PSU_RETENIDAS( -- ramiro
    p_sseguro IN NUMBER,
		p_nversion IN NUMBER,
		p_nriesgo IN NUMBER,
		p_nmovimi IN NUMBER,
		p_cidioma IN NUMBER,
		p_this_psu_retenidas OUT T_IAX_PSU_RETENIDAS,
		mensajes IN OUT t_iax_mensajes)
    return number is
    vobjectname    VARCHAR2(500) := 'PAC_MD_PSU.F_LEE_HIS_PSU_RETENIDAS';
    vparam         VARCHAR2(500) := 'parámetros - psseguro : ' || p_sseguro||' p_nversion='||p_nversion||
    ' p_nriesgo='||p_nriesgo||' p_nmovimi='||p_nmovimi;
    w_pas          PLS_INTEGER := 1;
    vnumerr        NUMBER := 0;

begin


 w_pas := 2;
      vnumerr := PAC_PSU.F_LEE_HIS_PSU_RETENIDAS(p_sseguro,p_nversion,p_nriesgo,p_nmovimi,p_cidioma,p_this_psu_retenidas,mensajes);
 w_pas := 3;

 IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
 END IF;

return 0;

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

end F_LEE_HIS_PSU_RETENIDAS; --ramiro
/*****************************************************************************
 Graba les observacions del control sel·leccionat, cridarà la funció de
 la capa intermitja PAC_MD_PSU.F_GRABAOBSERVACIONES.

*****************************************************************************/
FUNCTION F_LEE_HIS_PSUCONTROLSEG(
    p_sseguro IN NUMBER,
		p_nversion IN NUMBER,
		p_nriesgo IN NUMBER,
		p_nmovimi IN NUMBER,
		p_ccontrol IN NUMBER,
		p_cidioma IN NUMBER,
		p_this_psucontrolseg OUT T_IAX_PSU,
		mensajes IN OUT t_iax_mensajes
)
    return number is
    vobjectname    VARCHAR2(500) := 'PAC_MD_PSU.f_hay_controles_pendientes';
    vparam         VARCHAR2(500) := 'parámetros - psseguro : ' || p_sseguro;
    w_pas          PLS_INTEGER := 1;
    vnumerr        NUMBER;

begin

--p_tab_error(f_sysdate, f_user, 'ramiro md', NULL, 'ramiro PAC_PSU.F_LEE_HIS_PSU_RETENIDAS = ' || vparam, '** Codi Error = ' || SQLERRM);

 w_pas := 2;
      vnumerr := PAC_PSU.F_LEE_HIS_PSUCONTROLSEG(p_sseguro, p_nversion, p_nriesgo,
                                                 p_nmovimi, p_ccontrol,	p_cidioma,
                                                  p_this_psucontrolseg,	mensajes);
 w_pas := 3;

 IF vnumerr <> 0 THEN

         RAISE e_object_error;
 END IF;

return 0;

EXCEPTION
  WHEN e_param_error THEN
     pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, vnumerr, w_pas, vparam);
     RETURN(1);
  WHEN e_object_error THEN
     pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, w_pas, vparam);
     RETURN(1);
  WHEN OTHERS THEN
     pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, w_pas, vparam,
                                       psqcode => SQLCODE, psqerrm => SQLERRM);
     RETURN(1);

end F_LEE_HIS_PSUCONTROLSEG;







/*****************************************************************************
 Graba les observacions del control sel·leccionat, cridarà la funció de
 la capa intermitja PAC_MD_PSU.F_GRABAOBSERVACIONES.

*****************************************************************************/
   FUNCTION F_LEE_PSU_SUBESTADOSPROP( --ramiro
    p_sseguro IN NUMBER,
		p_nversion IN NUMBER,
		p_nversionsubest IN NUMBER,
		p_nmovimi IN NUMBER,
		p_cidioma IN NUMBER,
		p_tpsu_subestadosprop OUT T_IAX_PSU_SUBESTADOSPROP,
		mensajes IN OUT t_iax_mensajes

)
    return number is

    vobjectname    VARCHAR2(500) := 'PAC_MD_PSU.f_hay_controles_pendientes';
    vparam         VARCHAR2(500) := 'parámetros - psseguro : ' || p_sseguro;
    w_pas          PLS_INTEGER := 1;
    vnumerr        NUMBER;

begin


w_pas := 2;
      vnumerr := PAC_PSU.F_LEE_PSU_SUBESTADOSPROP(p_sseguro, p_nversion, p_nversionsubest,
                                                 p_nmovimi,	p_cidioma,  p_tpsu_subestadosprop,	mensajes);
 w_pas := 3;

 IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
 END IF;

return 0;

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

end F_LEE_PSU_SUBESTADOSPROP; --ramiro

/*****************************************************************************
 Graba les observacions del control sel·leccionat, cridarà la funció de
 la capa intermitja PAC_MD_PSU.F_GRABAOBSERVACIONES.

*****************************************************************************/
   FUNCTION F_INS_PSU_SUBESTADOSPROP( --ramiro
    p_sseguro IN NUMBER,
		p_nversion IN NUMBER,
		p_nmovimi IN NUMBER,
		P_CSUBESTADO IN NUMBER,
		P_COBSERVACIONES IN VARCHAR2,
    mensajes IN OUT t_iax_mensajes
)
    return number is
    vobjectname    VARCHAR2(500) := 'PAC_MD_PSU.f_hay_controles_pendientes';
    vparam         VARCHAR2(500) := 'parámetros - psseguro : ' || p_sseguro;
    w_pas          PLS_INTEGER := 1;
    vnumerr        NUMBER;


begin


    vnumerr := PAC_PSU.F_INS_PSU_SUBESTADOSPROP(p_sseguro,p_nversion,p_nmovimi,p_csubestado,p_cobservaciones);

 IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
 END IF;

PAC_IOBJ_MENSAJES.CREA_NUEVO_MENSAJE(MENSAJES, 2, 9903202);
--pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 9903202, w_pas, vparam);
return 0;

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

end F_INS_PSU_SUBESTADOSPROP; --ramiro


END pac_md_psu;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_PSU" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_PSU" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_PSU" TO "PROGRAMADORESCSI";
