--------------------------------------------------------
--  DDL for Package Body PAC_IAX_SIN_TRAMITE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IAX_SIN_TRAMITE" AS
   /******************************************************************************
      NOMBRE:       PAC_IAX_SIN_TRAMITE
      PROPÓSITO: Funciones para el alta de trámites

      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  --------  ------------------------------------
      1.0        27/04/2011   JMP      1. Creación del package.
      2.0        16/05/2012   JMF      0022099: MDP_S001-SIN - Trámite de asistencia
      3.0        04/02/2014   FAL      3. 0025537: RSA000 - Gestión de incidencias
      4.0        22/04/2014   NSS      4. 0029989/165377: LCOL_S001-SIN - Rechazo de tramitación única
   ******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   /*************************************************************************
         F_SET_OBJ_SINTRAMITE
      Traspasa los valores de los parámetros a los atributos del objeto global
      PAC_IAX_SINIESTROS.VGOBSINIESTRO.TRAMITES.
      param in pnsinies                : número de siniestro
      param in pntramte                : número de trámite
      param in pctramte                : código de trámite
      param out t_iax_mensajes         : mensajes de error
      return                           : 0 todo correcto
                                         1 ha habido un error
   *************************************************************************/
   FUNCTION f_set_obj_sintramite(
      pnsinies IN VARCHAR2,
      pntramte IN NUMBER,
      pctramte IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_error        NUMBER := 0;
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(500)
         := 'pnsinies: ' || pnsinies || ' - pntramte: ' || pntramte || ' - pctramte: '
            || pctramte;
      v_object       VARCHAR2(200) := 'PAC_IAX_SIN_TRAMITE.f_set_obj_sintramite';
      v_index        NUMBER(5);
      v_ttramite     sin_destramite.ttramite%TYPE;
      v_ntramite     NUMBER;
      v_sproduc      seguros.sproduc%TYPE;
      v_cactivi      seguros.cactivi%TYPE;
      v_cempres      seguros.cempres%TYPE;
      v_cunitra      sin_tramita_movimiento.cunitra%TYPE;
      v_ctramitad    sin_tramita_movimiento.ctramitad%TYPE;
   BEGIN
      IF pntramte IS NOT NULL THEN
         IF pac_iax_siniestros.vgobsiniestro.tramites IS NOT NULL
            AND pac_iax_siniestros.vgobsiniestro.tramites.COUNT > 0 THEN
            FOR i IN
               pac_iax_siniestros.vgobsiniestro.tramites.FIRST .. pac_iax_siniestros.vgobsiniestro.tramites.LAST LOOP
               IF pac_iax_siniestros.vgobsiniestro.tramites.EXISTS(i) THEN   -- 22702:ASN:26/07/2012
                  IF pac_iax_siniestros.vgobsiniestro.tramites(i).ntramte = pntramte THEN
                     v_error :=
                        pac_md_sin_tramite.f_set_obj_sintramite
                                         (pac_iax_siniestros.vgobsiniestro.tramites(i).nsinies,
                                          pac_iax_siniestros.vgobsiniestro.tramites(i).ntramte,
                                          pctramte,
                                          pac_iax_siniestros.vgobsiniestro.tramites(i),
                                          mensajes);
                     EXIT;
                  END IF;
               END IF;
            END LOOP;
         END IF;
      ELSE
         v_ntramite := 0;

         IF pac_iax_siniestros.vgobsiniestro.tramites IS NOT NULL
            AND pac_iax_siniestros.vgobsiniestro.tramites.COUNT > 0 THEN
            v_ntramite :=
               pac_iax_siniestros.vgobsiniestro.tramites
                                               (pac_iax_siniestros.vgobsiniestro.tramites.LAST).ntramte
               + 1;
         END IF;

         SELECT MAX(sproduc), MAX(cactivi), MAX(cempres)
           INTO v_sproduc, v_cactivi, v_cempres
           FROM seguros
          WHERE sseguro = pac_iax_siniestros.vgobsiniestro.sseguro;

         v_error :=
            pac_md_sin_tramite.f_inicializa_tramites
                                                    (v_sproduc, v_cactivi, pnsinies, pctramte,
                                                     pac_iax_siniestros.vgobsiniestro.tramites,
                                                     mensajes);

         IF v_error <> 0 THEN
            RAISE e_object_error;
         END IF;

         -- Bug 0022099 - 16/05/2012 - JMF
         v_index :=
            pac_iax_siniestros.vgobsiniestro.tramites
                                                (pac_iax_siniestros.vgobsiniestro.tramites.LAST).ntramte;
         v_error :=
            pac_md_siniestros.f_get_tramitador_defecto
                                                     (v_cempres, f_user, NULL,
                                                      pac_iax_siniestros.vgobsiniestro.ccausin,
                                                      pac_iax_siniestros.vgobsiniestro.cmotsin,
                                                      pnsinies, NULL,   -- 22108:ASN:04/06/2012
                                                      NULL, v_cunitra, v_ctramitad, mensajes);
         -- BUG 18336 - 04/05/2011 - JMP - Si el producto tiene trámites, le pasamos el número de trámite por defecto
         -- Bug 0022099 - 16/05/2012 - JMF: v_index
         v_error :=
            pac_md_siniestros.f_inicializa_tramitaciones
                                   (v_sproduc, v_cactivi, pnsinies, v_cunitra, v_ctramitad,
                                    pctramte, 0,   -- bug21196:ASN:26/03/2012 'valor = tramitacion apertura'
                                    v_index, pac_iax_siniestros.vgobsiniestro.tramitaciones,
                                    mensajes);

         IF v_error <> 0 THEN
            RAISE e_object_error;
         END IF;

         -- Fin BUG:0018379 - JMC - 02/05/2011
         IF pac_iax_siniestros.vgobsiniestro.tramitaciones IS NOT NULL
            AND pac_iax_siniestros.vgobsiniestro.tramitaciones.COUNT > 0 THEN   --ASN -- 20/01/2012
            FOR i IN
               pac_iax_siniestros.vgobsiniestro.tramitaciones.FIRST .. pac_iax_siniestros.vgobsiniestro.tramitaciones.LAST LOOP
               IF pac_iax_siniestros.vgobsiniestro.tramitaciones.EXISTS(i) THEN   -- 22702:ASN:26/07/2012
                  -- bug : 0018379 - JMC - 02/05/2011
                  v_error :=
                     pac_md_siniestros.f_set_objeto_sintramitacion
                                   (pnsinies,
                                    pac_iax_siniestros.vgobsiniestro.tramitaciones(i).ntramit,
                                    pac_iax_siniestros.vgobsiniestro.tramitaciones(i).ctramit,
                                    pac_iax_siniestros.vgobsiniestro.tramitaciones(i).ctcausin,
                                    pac_iax_siniestros.vgobsiniestro.tramitaciones(i).cinform,
                                    pac_iax_siniestros.vgobsiniestro.tramitaciones(i).ctiptra,
                                    NULL, NULL, NULL, NULL, NULL,
                                    pac_iax_siniestros.vgobsiniestro.tramitaciones(i),
                                    mensajes,
                                    pac_iax_siniestros.vgobsiniestro.tramitaciones(i).ntramte);

                  IF v_error <> 0 THEN
                     RAISE e_object_error;
                  END IF;
               END IF;
            END LOOP;
         END IF;

         v_index := pac_iax_siniestros.vgobsiniestro.tramites.LAST;
         v_error :=
            pac_md_sin_tramite.f_set_obj_sintramite
                                           (pnsinies, v_ntramite, pctramte,
                                            pac_iax_siniestros.vgobsiniestro.tramites(v_index),
                                            mensajes);
      END IF;

      IF v_error <> 0 THEN
         RAISE e_object_error;
      END IF;

      v_error := pac_md_sin_tramite.f_set_tramites(pac_iax_siniestros.vgobsiniestro.tramites,
                                                   pnsinies, mensajes);
      -- ini Bug 0022099 - 16/05/2012 - JMF
      v_error :=
         pac_md_siniestros.f_set_tramitaciones
                           (pac_iax_siniestros.vgobsiniestro.tramitaciones, pnsinies, NULL,
                            mensajes,   -- BUG 25537 - FAL - 04/02/2014. Se pasa NULL como sidepag
                            NULL);   --bug 29989/165377:NSS:13/02/2014

      IF v_error <> 0 THEN
         RAISE e_object_error;
      END IF;

      -- fin Bug 0022099 - 16/05/2012 - JMF
      IF v_error <> 0 THEN
         ROLLBACK;
         RAISE e_object_error;
      ELSE
         COMMIT;
      END IF;

      RETURN v_error;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005, v_pasexec, v_param);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000006, v_pasexec, v_param);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_set_obj_sintramite;

   /*************************************************************************
         F_GET_CODTRAMITE
      Obtiene un cursor con los diferentes códigos de trámites definidos.
      param in psproduc                : código de producto
      param in pcactivi                : código de actividad
      param out t_iax_mensajes         : mensajes de error
      return                           : el cursor
   *************************************************************************/
   FUNCTION f_get_codtramite(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      v_error        NUMBER := 0;
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(500) := 'psproduc: ' || psproduc || ' - pcactivi: ' || pcactivi;
      v_object       VARCHAR2(200) := 'PAC_IAX_SIN_TRAMITE.f_get_codtramite';
      v_cursor       sys_refcursor;
   BEGIN
      v_cursor := pac_md_sin_tramite.f_get_codtramite(psproduc, pcactivi, mensajes);
      RETURN v_cursor;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005, v_pasexec, v_param);
         RETURN v_cursor;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000006, v_pasexec, v_param);
         RETURN v_cursor;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN v_cursor;
   END f_get_codtramite;

   /*************************************************************************
         F_GET_OBJ_TRAMITE
      Dado un número de trámite, obtiene la información correspondiente a ese
      trámite del objeto global PAC_IAX_SINIESTROS.VGOBSINIESTRO y la devuelve
      en un objeto OB_IAX_SIN_TRAMITE.
      Además, obtiene todas las tramitaciones correspondientes al trámite y las
      devuelve en un objeto T_IAX_SIN_TRAMITACION.
      param in pntramte                : número de trámite
      param out t_iax_sin_tramitacion  : colección de tramitaciones
      param out t_iax_mensajes         : mensajes de error
      return                           : el objeto OB_IAX_SIN_TRAMITE
   *************************************************************************/
   FUNCTION f_get_obj_tramite(
      pntramte IN NUMBER,
      ptramitaciones OUT t_iax_sin_tramitacion,
      mensajes OUT t_iax_mensajes)
      RETURN ob_iax_sin_tramite IS
      v_error        NUMBER := 0;
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(500) := 'pntramte: ' || pntramte;
      v_object       VARCHAR2(200) := 'PAC_IAX_SIN_TRAMITE.f_get_obj_tramite';
      v_index        NUMBER(5) := 0;
      v_cont         NUMBER(5);
      j              NUMBER(5);
      v_ob_tramite   ob_iax_sin_tramite := ob_iax_sin_tramite();
      vgobtramtnes   t_iax_sin_tramitacion;
   BEGIN
      IF pac_iax_siniestros.vgobsiniestro.tramites IS NOT NULL
         AND pac_iax_siniestros.vgobsiniestro.tramites.COUNT > 0 THEN
         FOR i IN
            pac_iax_siniestros.vgobsiniestro.tramites.FIRST .. pac_iax_siniestros.vgobsiniestro.tramites.LAST LOOP
            IF pac_iax_siniestros.vgobsiniestro.tramites.EXISTS(i) THEN   -- 22702:ASN:26/07/2012
               IF pac_iax_siniestros.vgobsiniestro.tramites(i).ntramte = pntramte THEN
                  v_ob_tramite := pac_iax_siniestros.vgobsiniestro.tramites(i);
                  EXIT;
               END IF;
            END IF;
         END LOOP;

         vgobtramtnes := pac_iax_siniestros.vgobsiniestro.tramitaciones;

         IF vgobtramtnes IS NOT NULL
            AND vgobtramtnes.COUNT > 0 THEN
            FOR i IN vgobtramtnes.FIRST .. vgobtramtnes.LAST LOOP
               IF vgobtramtnes.EXISTS(i) THEN   -- 22702:ASN:26/07/2012
                  IF vgobtramtnes(i).ntramte = pntramte THEN
                     IF ptramitaciones IS NULL THEN
                        ptramitaciones := t_iax_sin_tramitacion();
                     END IF;

                     ptramitaciones.EXTEND;
                     ptramitaciones(ptramitaciones.LAST) := vgobtramtnes(i);
                  END IF;
               END IF;
            END LOOP;
         END IF;
      END IF;

      IF v_ob_tramite.ctramte = 3 THEN
         v_error := pac_md_sin_tramite.f_set_obj_sintramite_recobro(v_ob_tramite.nsinies,
                                                                    v_ob_tramite.ntramte,
                                                                    v_ob_tramite.recobro,
                                                                    mensajes);
      ELSIF v_ob_tramite.ctramte = 2 THEN
         v_error := pac_md_sin_tramite.f_set_obj_sintramite_lesiones(v_ob_tramite.nsinies,
                                                                     v_ob_tramite.ntramte,
                                                                     v_ob_tramite.lesiones,
                                                                     mensajes);
      ELSIF v_ob_tramite.ctramte = 5 THEN
         -- Bug 0022099 - 16/05/2012 - JMF
         v_error := pac_md_sin_tramite.f_set_obj_sintramite_asist(v_ob_tramite.nsinies,
                                                                  v_ob_tramite.ntramte,
                                                                  v_ob_tramite.asistencia,
                                                                  mensajes);
      END IF;

      RETURN v_ob_tramite;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005, v_pasexec, v_param);
         RETURN v_ob_tramite;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000006, v_pasexec, v_param);
         RETURN v_ob_tramite;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN v_ob_tramite;
   END f_get_obj_tramite;

   FUNCTION f_set_obj_iax_sin_recobro(
      pnsinies IN VARCHAR2,
      pntramte IN NUMBER,
      pfprescrip IN DATE,
      pireclamt IN NUMBER,
      pirecobt IN NUMBER,
      piconcurr IN NUMBER,
      pircivil IN NUMBER,
      piassegur IN NUMBER,
      pcresrecob IN NUMBER,
      pcdestim IN NUMBER,
      pnrefges IN NUMBER,
      pctiprec IN NUMBER,
      pmensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_error        NUMBER := 0;
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(500)
         := 'pnsinies: ' || pnsinies || ' - pntramte: ' || pntramte || ' - pfprescrip: '
            || pfprescrip || ' - pireclamt: ' || pireclamt || ' - pirecobt: ' || pirecobt
            || ' - piconcurr: ' || piconcurr || ' - pircivil: ' || pircivil
            || ' - piassegur: ' || piassegur || ' - pcresrecob: ' || pcresrecob
            || ' - pcdestim: ' || pcdestim || ' - pnrefges: ' || pnrefges || ' - pctiprec: '
            || pctiprec;
      v_object       VARCHAR2(200) := 'PAC_IAX_SIN_TRAMITE.f_set_obj_iax_sin_recobro';
      v_index        NUMBER(5);
      v_ttramite     sin_destramite.ttramite%TYPE;
      v_ntramite     NUMBER;
      v_pntramte     NUMBER;
   BEGIN
      IF pntramte IS NULL THEN
         SELECT MAX(ntramte)
           INTO v_pntramte
           FROM sin_tramite
          WHERE nsinies = pnsinies;
      ELSE
         v_pntramte := pntramte;
      END IF;

      v_index := pac_iax_siniestros.vgobsiniestro.tramites.LAST;
      pac_iax_siniestros.vgobsiniestro.tramites(v_index).recobro.nsinies := pnsinies;
      pac_iax_siniestros.vgobsiniestro.tramites(v_index).recobro.ntramte := v_pntramte;
      pac_iax_siniestros.vgobsiniestro.tramites(v_index).recobro.fprescrip := pfprescrip;
      pac_iax_siniestros.vgobsiniestro.tramites(v_index).recobro.ireclamt := pireclamt;
      pac_iax_siniestros.vgobsiniestro.tramites(v_index).recobro.irecobt := pirecobt;
      pac_iax_siniestros.vgobsiniestro.tramites(v_index).recobro.iconcurr := piconcurr;
      pac_iax_siniestros.vgobsiniestro.tramites(v_index).recobro.ircivil := pircivil;
      pac_iax_siniestros.vgobsiniestro.tramites(v_index).recobro.iassegur := piassegur;
      pac_iax_siniestros.vgobsiniestro.tramites(v_index).recobro.cresrecob := pcresrecob;
      pac_iax_siniestros.vgobsiniestro.tramites(v_index).recobro.cdestim := pcdestim;
      pac_iax_siniestros.vgobsiniestro.tramites(v_index).recobro.nrefges := pnrefges;
      pac_iax_siniestros.vgobsiniestro.tramites(v_index).recobro.ctiprec := pctiprec;
      v_error :=
         pac_md_sin_tramite.f_ins_tramite_recobro
                                   (pnsinies,
                                    pac_iax_siniestros.vgobsiniestro.tramites(v_index).recobro,
                                    pmensajes);

      IF v_error <> 0 THEN
         RAISE e_object_error;
      END IF;

      IF v_error <> 0 THEN
         ROLLBACK;
         RAISE e_object_error;
      ELSE
         COMMIT;
      END IF;

      RETURN v_error;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(pmensajes, v_object, 1000005, v_pasexec, v_param);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(pmensajes, v_object, 1000006, v_pasexec, v_param);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(pmensajes, v_object, 1000001, v_pasexec, v_param,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_set_obj_iax_sin_recobro;

   FUNCTION f_set_obj_iax_sin_lesiones(
      pnsinies IN VARCHAR2,
      pntramte IN NUMBER,
      pnlesiones NUMBER,
      pnmuertos NUMBER,
      pagravantes VARCHAR2,
      pcgradoresp NUMBER,
      pctiplesiones NUMBER,
      pctiphos NUMBER,
      pmensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_error        NUMBER := 0;
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(500)
         := 'pnsinies: ' || pnsinies || ' - pntramte: ' || pntramte || ' - nlesiones: '
            || pnlesiones || ' - nmuertos: ' || pnmuertos || ' - agravantes: ' || pagravantes
            || ' - cgradoresp: ' || pcgradoresp || ' - ctiplesiones: ' || pctiplesiones
            || ' - ctiphos: ' || pctiphos;
      v_object       VARCHAR2(200) := 'PAC_IAX_SIN_TRAMITE.f_set_obj_iax_sin_lesiones';
      v_index        NUMBER(5);
      v_ttramite     sin_destramite.ttramite%TYPE;
      v_ntramite     NUMBER;
      v_pntramte     NUMBER;
   BEGIN
      IF pntramte IS NULL THEN
         SELECT MAX(ntramte)
           INTO v_pntramte
           FROM sin_tramite
          WHERE nsinies = pnsinies;
      ELSE
         v_pntramte := pntramte;
      END IF;

      v_index := pac_iax_siniestros.vgobsiniestro.tramites.LAST;
      pac_iax_siniestros.vgobsiniestro.tramites(v_index).lesiones.nsinies := pnsinies;
      pac_iax_siniestros.vgobsiniestro.tramites(v_index).lesiones.ntramte := v_pntramte;
      pac_iax_siniestros.vgobsiniestro.tramites(v_index).lesiones.nlesiones := pnlesiones;
      pac_iax_siniestros.vgobsiniestro.tramites(v_index).lesiones.nmuertos := pnmuertos;
      pac_iax_siniestros.vgobsiniestro.tramites(v_index).lesiones.agravantes := pagravantes;
      pac_iax_siniestros.vgobsiniestro.tramites(v_index).lesiones.cgradoresp := pcgradoresp;
      pac_iax_siniestros.vgobsiniestro.tramites(v_index).lesiones.ctiplesiones := pctiplesiones;
      pac_iax_siniestros.vgobsiniestro.tramites(v_index).lesiones.ctiphos := pctiphos;
      v_error :=
         pac_md_sin_tramite.f_ins_tramite_lesiones
                                  (pnsinies,
                                   pac_iax_siniestros.vgobsiniestro.tramites(v_index).lesiones,
                                   pmensajes);

      IF v_error <> 0 THEN
         RAISE e_object_error;
      END IF;

      IF v_error <> 0 THEN
         ROLLBACK;
         RAISE e_object_error;
      ELSE
         COMMIT;
      END IF;

      RETURN v_error;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(pmensajes, v_object, 1000005, v_pasexec, v_param);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(pmensajes, v_object, 1000006, v_pasexec, v_param);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(pmensajes, v_object, 1000001, v_pasexec, v_param,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_set_obj_iax_sin_lesiones;

   /*************************************************************************
      FUNCTION f_hay_tramites
         Comprueba si se han parametrizado los tramites para el producto del siniestro
         param in pnsinies       : numero del siniestro
         param out phay_tramites : 0 --> No
                                   1 --> Si
         param in out mensajes   : mensajes de error
         return                  : 0 -> correcto
                                   1 -> error
   *************************************************************************/
   FUNCTION f_hay_tramites(
      pnsinies IN sin_siniestro.nsinies%TYPE,
      phay_tramites OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_IAX_SIN_TRAMITE.f_hay_tramites';
      vparam         VARCHAR2(500) := 'parámetros - pnsinies: ' || pnsinies;
      vpasexec       NUMBER := 1;
      verror         NUMBER;
   BEGIN
      IF pnsinies IS NULL THEN
         RAISE e_param_error;
      END IF;

      verror := pac_md_sin_tramite.f_hay_tramites(pnsinies, phay_tramites, mensajes);
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_hay_tramites;

   /*************************************************************************
      FUNCION
      Traspasa los valores de sin_tramite_asistencia
      param in pnsinies                : número de siniestro
      param in pntramte                : número de trámite
      param in trefext                 : Referencia Externa
      param in cciaasis                : Compañía de asistencia VF=XXX
      param in out t_iax_mensajes      : mensajes de error
      return                           : 0 todo correcto
                                         1 ha habido un error
    -- Bug 0022099 - 16/05/2012 - JMF
   *************************************************************************/
   FUNCTION f_set_obj_sintramite_asist(
      pnsinies IN VARCHAR2,
      pntramte IN NUMBER,
      ptrefext IN VARCHAR2,
      pcciaasis IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_error        NUMBER := 0;
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(500)
         := 'pnsinies: ' || pnsinies || ' - pntramte: ' || pntramte || ' - ptrefext: '
            || ptrefext || ' - pcciaasis: ' || pcciaasis;
      v_object       VARCHAR2(200) := 'PAC_IAX_SIN_TRAMITE.f_set_obj_sintramite_asist';
      v_index        NUMBER(5);
      v_ttramite     sin_destramite.ttramite%TYPE;
      v_ntramite     NUMBER;
      v_pntramte     NUMBER;
   BEGIN
      v_pasexec := 10;

      IF pntramte IS NULL THEN
         SELECT MAX(ntramte)
           INTO v_pntramte
           FROM sin_tramite
          WHERE nsinies = pnsinies;
      ELSE
         v_pntramte := pntramte;
      END IF;

      v_pasexec := 15;
      v_index := pac_iax_siniestros.vgobsiniestro.tramites.LAST;
      v_pasexec := 20;
      pac_iax_siniestros.vgobsiniestro.tramites(v_index).asistencia.nsinies := pnsinies;
      pac_iax_siniestros.vgobsiniestro.tramites(v_index).asistencia.ntramte := v_pntramte;
      pac_iax_siniestros.vgobsiniestro.tramites(v_index).asistencia.trefext := ptrefext;
      pac_iax_siniestros.vgobsiniestro.tramites(v_index).asistencia.cciaasis := pcciaasis;
      v_pasexec := 25;
      v_error :=
         pac_md_sin_tramite.f_ins_tramite_asist
                                (pnsinies,
                                 pac_iax_siniestros.vgobsiniestro.tramites(v_index).asistencia,
                                 mensajes);

      IF v_error <> 0 THEN
         RAISE e_object_error;
      END IF;

      IF v_error <> 0 THEN
         ROLLBACK;
         RAISE e_object_error;
      ELSE
         COMMIT;
      END IF;

      RETURN v_error;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005, v_pasexec, v_param);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000006, v_pasexec, v_param);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_set_obj_sintramite_asist;

   /***********************************************************************
      FUNCTION f_estado_tramite:
       Cambia el estado de un tramite
       param in pnsinies : Número siniestro
       param in pntramit : Número tramitación
       param in pcesttra : Código estado
       param  out  mensajes : Mensajes de error
       return            : 0 -> Tot correcte
                           1 -> S'ha produit un error
       -- Bug 0022108 - 19/06/2012 - JMF
    ***********************************************************************/
   FUNCTION f_estado_tramite(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      pcesttra IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'parámetros - pnsinies:' || pnsinies || ' - pntramit:' || pntramit
            || ' - pcesttra:' || pcesttra;
      vobjectname    VARCHAR2(50) := 'PAC_IAX_SINIESTROS.f_estado_tramite';
      vnumerr        NUMBER(10) := 0;
   BEGIN
      vnumerr := pac_md_sin_tramite.f_estado_tramite(pnsinies, pntramit, pcesttra, mensajes);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
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
   END f_estado_tramite;

     /*************************************************************************
      FUNCTION
         Crea o actualiza en bbdd, información del tramite asistencia.
         param in  pnsinies  : codi del sinistre
         param out pntramit  : Numero de tramitaci
         param out t_iax_mensajes      : mensajes de error
         return              : Error (0 -> Tot correcte, codi error)

      Bug 22325/115249- 07/06/2012 - AMC
   *************************************************************************/
   FUNCTION f_get_tramite9999(
      pnsinies IN NUMBER,
      pntramit OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_IAX_SIN_TRAMITE.f_get_ntramitglobal';
      vparam         VARCHAR2(500) := 'parámetros - pnsinies: ' || pnsinies;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 1;
   BEGIN
      IF pnsinies IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_sin_tramite.f_get_tramite9999(pnsinies, pntramit, mensajes);

      IF vnumerr <> 0 THEN
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
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     SQLCODE || ' - ' || SQLERRM);
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_get_tramite9999;

   /***********************************************************************
      Recupera los datos de un determinado personas relacionadas
      param in  pnsinies  : número de siniestro
      param in  pntramit  : número de tramitación
      param in  pnpersrel  : número de linea de spersrel
      param out  ob_iax_sin_trami_personarel :  ob_iax_sin_trami_personarel
      param out mensajes  : mensajes de error
      return              : 0 OK
                            1 Error

   ***********************************************************************/
   FUNCTION f_get_lista_personasrel(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      plistapersrel OUT t_iax_sin_trami_personarel,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_IAX_SIN_TRAMITE.f_get_lista_personasrel';
      vparam         VARCHAR2(500)
                          := 'parámetros - pnsinies: ' || pnsinies || ' pntramit:' || pntramit;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      --Comprovació dels parámetres d'entrada
      IF pnsinies IS NULL
         AND pntramit IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_siniestros.f_get_lista_personasrel(pnsinies, pntramit, plistapersrel,
                                                           mensajes);

      IF vnumerr <> 0 THEN
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
   END f_get_lista_personasrel;

     FUNCTION f_ini_obj_judicial(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      pnorden  IN NUMBER,
      proceso  OUT OB_IAX_SIN_TRAMITA_JUDICIAL,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
        vparam      VARCHAR2(500) := 'pnsinies: ' || pnsinies || ' - pntramit: ' || pntramit || ' - pnorden: ' ||pnorden ;
        vpasexec    NUMBER(5) := 1;
        vobjectname VARCHAR2(100):= 'PAC_IAX_SIN_TRAMITE.f_ini_obj_judicial';
        numerr NUMBER;
    BEGIN
      IF pnsinies IS NULL OR
        pntramit IS NULL
      THEN
        RAISE e_param_error;
      END IF;
      numerr := pac_md_sin_tramite.f_ini_obj_judicial(pnsinies, pntramit, pnorden, proceso, mensajes);

      RETURN numerr;
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
      END f_ini_obj_judicial;

  FUNCTION f_get_procesos_judiciales(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN SYS_REFCURSOR IS
        vparam      VARCHAR2(500) := 'pnsinies: ' || pnsinies || ' - pntramit: ' || pntramit;
        vpasexec    NUMBER(5) := 1;
        vobjectname VARCHAR2(100):= 'PAC_IAX_SIN_TRAMITE.f_get_procesos_judiciales';
        numerr NUMBER;
    BEGIN
      IF pnsinies IS NULL OR
        pntramit IS NULL
      THEN
        RAISE e_param_error;
      END IF;
      RETURN pac_md_sin_tramite.f_get_procesos_judiciales(pnsinies, pntramit, mensajes);

   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN NULL;
      END f_get_procesos_judiciales;

  FUNCTION f_get_obj_judicial(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      pnorden IN NUMBER,
      objudicial OUT OB_IAX_SIN_TRAMITA_JUDICIAL,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
        vparam      VARCHAR2(500) := 'pnsinies: ' || pnsinies || ' - pntramit: ' || pntramit|| ' - pnorden: '|| pnorden;
        vpasexec    NUMBER(5) := 1;
        vobjectname VARCHAR2(100):= 'PAC_IAX_SIN_TRAMITE.f_get_obj_judicial';
        numerr NUMBER;
    BEGIN
      IF pnsinies IS NULL OR
        pntramit IS NULL
      THEN
        RAISE e_param_error;
      END IF;
      numerr := pac_md_sin_tramite.f_get_obj_judicial(pnsinies, pntramit, pnorden, objudicial, mensajes);

      RETURN numerr;
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
  END f_get_obj_judicial;

  FUNCTION f_set_obj_judicial(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      pnorden IN NUMBER,
      pcproceso IN NUMBER,
      ptproceso IN NUMBER,
      pcpostal IN VARCHAR2,
      pcpoblac IN NUMBER,
      pcprovin IN NUMBER,
      ptiexterno IN VARCHAR2,
      psprofes IN NUMBER,
      pfrecep IN DATE,
      pfnotifi IN DATE,
      pfvencimi IN DATE,
      pfrespues IN DATE,
      pfconcil IN DATE,
      pfdesvin IN DATE,
      ptpreten IN VARCHAR2,
      ptexcep1 IN VARCHAR2,
      ptexcep2 IN VARCHAR2,
      pcconti IN NUMBER,
      pcdespa IN NUMBER,
      pcdescf IN VARCHAR2,
      pcprovinf IN NUMBER,
      pcpoblacf IN NUMBER,
      pcdespao IN NUMBER,
      pcdesco IN VARCHAR2,
      pcprovino IN NUMBER,
      pcpoblaco IN NUMBER,
      pcposici IN NUMBER,
      pcdemand IN NUMBER,
      psapodera IN NUMBER,
      pidemand IN NUMBER,
      pftdeman IN DATE,
      piconden IN NUMBER,
      pcsenten IN NUMBER,
      pfsente1 IN DATE,
      pcsenten2 IN NUMBER,
      pfsente2 IN DATE,
      pcasacion IN NUMBER,
      pfcasaci IN DATE,
      pctsente IN NUMBER,
      pftsente IN DATE,
      pvtsente IN VARCHAR2,
      ptfallo IN VARCHAR2
    ,pcoralproc IN NUMBER
    ,punicainst IN NUMBER
    ,pfunicainst IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
        vparam      VARCHAR2(2000) := ' - pnsinies   :'||  pnsinies    ||' - pntramit   :'||  pntramit    ||' - pnorden    :'||  pnorden     ||' - pcproceso  :'||  pcproceso   ||' - ptproceso  :'||  ptproceso   ||' - pcpostal   :'||  pcpostal    ||' - pcpoblac   :'||  pcpoblac    ||' - pcprovin   :'||  pcprovin    ||' - ptiexterno :'||  ptiexterno  ||' - psprofes   :'||  psprofes    ||' - pfrecep    :'||  pfrecep     ||' - pfnotifi   :'||  pfnotifi    ||' - pfvencimi  :'||  pfvencimi   ||' - pfrespues  :'||  pfrespues   ||' - pfconcil   :'||  pfconcil    ||' - pfdesvin   :'||  pfdesvin              ||' - pcconti   :'||  pcconti     ||' - pcdespa    :'||  pcdespa     ||' - pcdespao    :'||  pcdespao    ||
                                      ' - pcdescf   :'||  pcdescf    ||' - pcprovinf   :'||  pcprovinf    ||' - pcpoblacf   :'||  pcpoblacf    ||' - pcdesco   :'||  pcdesco    ||' - pcprovino   :'||  pcprovino    ||' - pcpoblaco   :'||  pcpoblaco    ||' - pcposici   :'||  pcposici    ||' - pcdemand   :'||  pcdemand    ||' - psapodera  :'||  psapodera   ||' - pidemand   :'||  pidemand    ||' - pftdeman   :'||  pftdeman    ||' - piconden   :'||  piconden    ||' - pcsenten   :'||  pcsenten    ||' - pfsente1   :'||  pfsente1    ||' - pcsenten2   :'||  pcsenten2    ||' - pfsente2   :'||  pfsente2    ||' - pcasacion   :'||  pcasacion    ||' - pfcasaci   :'||  pfcasaci    ||' - pctsente   :'||  pctsente    ||' - pftsente   :'||  pftsente    ||' - pvtsente   :'||  pvtsente  || ' coralproc:' || pcoralproc || ' unicainst:' || punicainst || ' funicainst:' || pfunicainst ;
        vpasexec    NUMBER(5) := 1;
        vobjectname VARCHAR2(100):= 'PAC_IAX_SIN_TRAMITE.f_set_obj_judicial';
        numerr NUMBER;
    BEGIN
      IF pnsinies IS NULL OR
        pntramit IS NULL
      THEN
        RAISE e_param_error;
      END IF;
      numerr := pac_md_sin_tramite.f_set_obj_judicial(pnsinies ,pntramit ,pnorden ,pcproceso,ptproceso,pcpostal ,pcpoblac ,pcprovin ,ptiexterno,psprofes ,pfrecep ,pfnotifi ,pfvencimi,pfrespues,pfconcil ,pfdesvin ,ptpreten ,ptexcep1 ,ptexcep2 ,pcconti, pcdespa, pcdescf, pcprovinf, pcpoblacf, pcdespao, pcdesco, pcprovino, pcpoblaco, pcposici ,pcdemand ,psapodera,pidemand ,pftdeman ,piconden ,pcsenten ,pfsente1 ,pcsenten2 ,pfsente2 ,pcasacion ,pfcasaci ,pctsente ,pftsente ,pvtsente ,ptfallo,pcoralproc,punicainst,pfunicainst ,mensajes);      RETURN 0;
      RETURN numerr;
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
      END f_set_obj_judicial;

  FUNCTION f_set_obj_judicial_valpret(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      pnorden IN NUMBER,
      pcgarant IN NUMBER,
      pipreten IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
        vparam      VARCHAR2(500) := 'pnsinies: ' || pnsinies || ' - pntramit: ' || pntramit|| ' - norden: '|| pnorden || ' - pcgarant:' || pcgarant|| ' - pipreten '|| pipreten;
        vpasexec    NUMBER(5) := 1;
        vobjectname VARCHAR2(100):= 'PAC_IAX_SIN_TRAMITE.f_set_obj_judicial_valpret';
        numerr NUMBER;
    BEGIN
      IF pnsinies IS NULL OR
        pntramit IS NULL
      THEN
        RAISE e_param_error;
      END IF;
      numerr := pac_md_sin_tramite.f_set_obj_judicial_valpret(pnsinies, pntramit, pnorden, pcgarant, pipreten, mensajes);

      RETURN numerr;
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
      END f_set_obj_judicial_valpret;

  FUNCTION f_set_obj_judicial_detper(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      pnorden IN NUMBER,
      pnrol IN NUMBER,
      pnpersona IN NUMBER,
      pntipper IN NUMBER,
      pnnumide IN VARCHAR2,
      ptnombre IN VARCHAR2,
      piimporte IN NUMBER DEFAULT NULL,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
        vparam      VARCHAR2(500) := 'pnsinies: ' || pnsinies || ' - pntramit: ' || pntramit|| ' - pnorden:'||pnorden||' - pnrol'||pnrol||' - pnpersona:'||pnpersona ||' - pntipper:'||pntipper ||' - pnnumide:'||pnnumide||' - ptnombre:'||ptnombre;
        vpasexec    NUMBER(5) := 1;
        vobjectname VARCHAR2(100):= 'PAC_IAX_SIN_TRAMITE.f_set_obj_judicial_detper';
        numerr NUMBER;
    BEGIN
      IF pnsinies IS NULL OR
        pntramit IS NULL OR
        pnorden IS NULL OR
        pnrol IS NULL

      THEN
        RAISE e_param_error;
      END IF;
      numerr := pac_md_sin_tramite.f_set_obj_judicial_detper(pnsinies, pntramit, pnorden, pnrol, pnpersona, pntipper, pnnumide, ptnombre, piimporte ,mensajes);
      RETURN numerr;
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
      END f_set_obj_judicial_detper;

  FUNCTION f_traspasar_judicial(
      proceso  IN OB_IAX_SIN_TRAMITA_JUDICIAL,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
        vparam      VARCHAR2(500) := ' ';
        vpasexec    NUMBER(5) := 1;
        vobjectname VARCHAR2(100):= 'PAC_IAX_SIN_TRAMITE.f_traspasar_judicial';
        numerr NUMBER;
    BEGIN
      IF proceso IS NULL
      THEN
        RAISE e_param_error;
      END IF;
      numerr := pac_md_sin_tramite.f_traspasar_judicial(proceso, mensajes);

      RETURN numerr;
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
      END f_traspasar_judicial;

  FUNCTION f_validar_judicial(
      proceso  IN OB_IAX_SIN_TRAMITA_JUDICIAL,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
        vparam      VARCHAR2(500) := ' ';
        vpasexec    NUMBER(5) := 1;
        vobjectname VARCHAR2(100):= 'PAC_IAX_SIN_TRAMITE.f_validar_judicial';
        numerr NUMBER;
    BEGIN
      IF proceso IS NULL
      THEN
        RAISE e_param_error;
      END IF;
      numerr := pac_md_sin_tramite.f_validar_judicial(proceso, mensajes);

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
      END f_validar_judicial;
  FUNCTION f_elimina_dato_judicial(
      pctipo IN NUMBER,
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      pnorden IN NUMBER,
      pnvalor IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
        vparam      VARCHAR2(500) := ' ';
        vpasexec    NUMBER(5) := 1;
        vobjectname VARCHAR2(100):= 'PAC_IAX_SIN_TRAMITE.f_elimina_dato_judicial';
        numerr NUMBER;
    BEGIN

      numerr := pac_md_sin_tramite.f_elimina_dato_judicial(pctipo,pnsinies,pntramit,pnorden,pnvalor,  mensajes);

      RETURN numerr;
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
      END f_elimina_dato_judicial;


  FUNCTION f_get_tramite_judicial_audien(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      pnorden IN NUMBER,
      pnaudien IN NUMBER,
      audiencia OUT OB_IAX_SIN_T_JUDICIAL_AUDIEN,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
        vparam      VARCHAR2(500) := 'pnsinies: ' || pnsinies || ' - pntramit: ' || pntramit || ' - pnorden: ' || pnorden || ' - pnaudien: ' || pnaudien;
        vpasexec    NUMBER(5) := 1;
        vobjectname VARCHAR2(100):= 'PAC_MD_SIN_TRAMITE.f_get_tramite_judicial_audien';
        numerr NUMBER;
    BEGIN
      IF pnsinies IS NULL OR
         pntramit IS NULL OR
         pnorden  IS NULL OR
         pnaudien IS NULL
      THEN
        RAISE e_param_error;
      END IF;

      numerr := pac_md_sin_tramite.f_get_tramite_judicial_audien(pnsinies, pntramit, pnorden, pnaudien, audiencia, mensajes);
      RETURN numerr;

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
  END f_get_tramite_judicial_audien;

  FUNCTION f_set_obj_judicial_audien(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      pnorden IN NUMBER,
      pnaudien IN NUMBER,
      pfaudien IN DATE,
      phaudien IN VARCHAR2,
      ptaudien IN VARCHAR2,
      pcdespa IN NUMBER,
      ptlaudie IN VARCHAR2,
      pcaudien IN VARCHAR2,
      pcdespao IN NUMBER,
      ptlaudieo IN VARCHAR2,
      pcaudieno IN VARCHAR2,
      psabogau IN NUMBER,
      pcoral IN NUMBER,
      pcestado IN NUMBER,
      pcresolu IN NUMBER,
      pfinsta1 IN DATE,
      pfinsta2 IN DATE,
      pfnueva IN DATE,
      ptresult IN VARCHAR2,
      pctramitad IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
        vparam      VARCHAR2(2000) := ' - pnsinies   :'||  pnsinies    ||' - pntramit   :'||  pntramit    ||' - pnorden    :'||  pnorden    ||' - pnaudien    :'||  pnaudien     ||' - pfaudien   :'||  pfaudien    ||' - phaudien   :'||  phaudien    ||' - ptaudien   :'||  ptaudien     ||' - pcdespa    :'||  pcdespa     ||' - ptlaudie   :'||  ptlaudie    ||' - pcaudien   :'||  pcaudien    ||' - pcdespao   :'||  pcdespao    ||' - ptlaudieo  :'||  ptlaudieo   ||' - pcaudieno  :'||  pcaudieno   ||' - psabogau   :'||  psabogau    ||' - pcoral     :'||  pcoral||' - pcestado   :'||  pcestado    ||' - pcresolu   :'||  pcresolu    ||' - pfinsta1   :'||  pfinsta1    ||' - pfinsta2   :'||  pfinsta2    ||' - pfnueva    :'||  pfnueva     ||' - ptresult   :'||  ptresult || '  pctramitad  :' || pctramitad;
        vpasexec    NUMBER(5) := 1;
        vobjectname VARCHAR2(100):= 'PAC_IAX_SIN_TRAMITE.f_set_obj_judicial_audien';
        numerr NUMBER;
    BEGIN
      IF pnsinies IS NULL OR
        pntramit IS NULL OR
        pnorden IS NULL
      THEN
        RAISE e_param_error;
      END IF;

      numerr := pac_md_sin_tramite.f_set_obj_judicial_audien(pnsinies ,pntramit ,pnorden ,pnaudien ,pfaudien ,phaudien ,ptaudien ,pcdespa ,ptlaudie ,pcaudien ,pcdespao ,ptlaudieo,pcaudieno,psabogau ,pcoral ,pcestado ,pcresolu ,pfinsta1 ,pfinsta2 ,pfnueva ,ptresult ,pctramitad ,mensajes);
      RETURN numerr;

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
  END f_set_obj_judicial_audien;

 FUNCTION f_get_procesos_fiscales(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN SYS_REFCURSOR IS
        vparam      VARCHAR2(500) := 'pnsinies: ' || pnsinies || ' - pntramit: ' || pntramit;
        vpasexec    NUMBER(5) := 1;
        vobjectname VARCHAR2(100):= 'PAC_IAX_SIN_TRAMITE.f_get_procesos_fiscales';
        numerr NUMBER;
    BEGIN
      IF pnsinies IS NULL OR
        pntramit IS NULL
      THEN
        RAISE e_param_error;
      END IF;
      RETURN pac_md_sin_tramite.f_get_procesos_fiscales(pnsinies, pntramit, mensajes);

   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN NULL;
      END f_get_procesos_fiscales;

  FUNCTION f_get_obj_fiscal(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      pnorden IN NUMBER,
      objfiscal OUT OB_IAX_SIN_TRAMITA_FISCAL,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
        vparam      VARCHAR2(500) := ' ';
        vpasexec    NUMBER(5) := 1;
        vobjectname VARCHAR2(100):= 'PAC_IAX_SIN_TRAMITE.f_get_obj_fiscal';
        numerr NUMBER;
    BEGIN

      numerr := pac_md_sin_tramite.f_get_obj_fiscal(pnsinies,pntramit,pnorden,objfiscal,  mensajes);

      RETURN numerr;
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
      END f_get_obj_fiscal;
  FUNCTION f_set_obj_fiscal(
      PNSINIES  IN   VARCHAR2,
      PNTRAMIT  IN   NUMBER,
      PNORDEN   IN   NUMBER,
      PFAPERTU  IN	DATE,
      PFIMPUTA  IN	DATE,
      PFNOTIFI  IN	DATE,
      PFAUDIEN  IN	DATE,
      PHAUDIEN  IN	VARCHAR2,
      PCAUDIEN  IN	NUMBER,
      PSPROFES  IN	NUMBER,
      PCOTERRI  IN	NUMBER,
      PCPROVIN  IN	NUMBER,
      PCCONTRA  IN	NUMBER,
      PCUESPEC  IN	NUMBER,
      PTCONTRA  IN	VARCHAR2,
      PCTIPTRA  IN	NUMBER,
      PTESTADO  IN	VARCHAR2,
      PCMEDIO   IN	NUMBER,
      PFDESCAR  IN	DATE,
      PFFALLO   IN   DATE,
      PCFALLO   IN   NUMBER,
      PTFALLO   IN   VARCHAR2,
      PCRECURSO IN   NUMBER,
      pctramitad IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER  IS
        vparam      VARCHAR2(500) :=    '  pnsinies   =' || pnsinies  ||    '  pntramit   =' || pntramit  ||    '  pnorden    =' || pnorden   ||    '  pfapertu   =' || pfapertu  ||    '  pfimputa   =' || pfimputa  ||    '  pfnotifi   =' || pfnotifi  ||    '  pfaudien   =' || pfaudien  ||    '  phaudien   =' || phaudien  ||    '  pcaudien   =' || pcaudien  ||    '  psprofes   =' || psprofes  ||    '  pcoterri   =' || pcoterri  ||    '  pccontra   =' || pccontra  ||
                                        '  pcprovin   =' || pcprovin  ||    '  pcuespec   =' || pcuespec  ||    '  ptcontra   =' || ptcontra  ||    '  pctiptra   =' || pctiptra  ||    '  ptestado   =' || ptestado  ||    '  pcmedio    =' || pcmedio   ||    '  pfdescar   =' || pfdescar  ||    '  pffallo    =' || pffallo   ||    '  pcfallo    =' || pcfallo     ||    '  pcrecurso  =' || pcrecurso || ' pctramitad =' || pctramitad;        vpasexec    NUMBER(5) := 1;
        vpasexec    NUMBER(5) := 1;
        vobjectname VARCHAR2(100):= 'PAC_IAX_SIN_TRAMITE.f_set_obj_fiscal';
        numerr NUMBER;
    BEGIN

      numerr := pac_md_sin_tramite.f_set_obj_fiscal(pnsinies ,pntramit ,pnorden  ,pfapertu ,pfimputa ,pfnotifi ,pfaudien ,phaudien ,pcaudien ,psprofes ,pcoterri ,pcprovin, pccontra ,pcuespec ,ptcontra ,pctiptra ,ptestado ,pcmedio  ,pfdescar ,pffallo  ,pcfallo  ,ptfallo  ,pcrecurso,pctramitad,  mensajes);

      RETURN numerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, 1, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, 1, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, 1, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
      END f_set_obj_fiscal;

  FUNCTION f_set_obj_fiscal_valpret(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      pnorden IN NUMBER,
      pcgarant IN NUMBER,
      pipreten IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
        vparam      VARCHAR2(500) := 'pnsinies: ' || pnsinies || ' - pntramit: ' || pntramit|| ' - norden: '|| pnorden || ' - pcgarant:' || pcgarant|| ' - pipreten '|| pipreten;
        vpasexec    NUMBER(5) := 1;
        vobjectname VARCHAR2(100):= 'PAC_IAX_SIN_TRAMITE.f_set_obj_fiscal_valpret';
        numerr NUMBER;
    BEGIN
      IF pnsinies IS NULL OR
        pntramit IS NULL
      THEN
        RAISE e_param_error;
      END IF;
      numerr := pac_md_sin_tramite.f_set_obj_fiscal_valpret(pnsinies, pntramit, pnorden, pcgarant, pipreten, mensajes);

      RETURN numerr;
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
      END f_set_obj_fiscal_valpret;
  FUNCTION f_elimina_dato_fiscal(
      pctipo IN NUMBER,
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      pnorden IN NUMBER,
      pnvalor IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
        vparam      VARCHAR2(500) := ' ';
        vpasexec    NUMBER(5) := 1;
        vobjectname VARCHAR2(100):= 'PAC_IAX_SIN_TRAMITE.f_elimina_dato_fiscal';
        numerr NUMBER;
    BEGIN

      numerr := pac_md_sin_tramite.f_elimina_dato_fiscal(pctipo,pnsinies,pntramit,pnorden,pnvalor,  mensajes);

      RETURN numerr;
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
      END f_elimina_dato_fiscal;
END pac_iax_sin_tramite;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_SIN_TRAMITE" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_SIN_TRAMITE" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_SIN_TRAMITE" TO "PROGRAMADORESCSI";
