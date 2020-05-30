--------------------------------------------------------
--  DDL for Package Body PAC_MD_SIN_TRAMITE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MD_SIN_TRAMITE" AS
   /******************************************************************************
      NOMBRE:       PAC_MD_SIN_TRAMITE
      PROPÓSITO:  Funciones para el alta de trámites

      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  --------  ------------------------------------
      1.0        27/04/2011   JMP      Creación del package.
      2.0        16/05/2012   JMF      0022099: MDP_S001-SIN - Trámite de asistencia
      3.0        14/06/2012   JMF      0022108 MDP_S001-SIN - Movimiento de trámites
      4.0        09/07/2012   JMF      0022490: LCOL_S001-SIN - Poder indicar que se generen los pagos como el último (Id=4604)
      5.0        05/09/2012   ASN      0023615: MDP_S001-SIN - Tramite de Asistencia automatico
      6.0        22/10/2012   JMF      0023643: MDP_S001-SIN - Ocultar tramite global
      7.0        24/04/2019   ABC      IAXIS3595: se realizan cambios de consulta de proceso judicial.  
   ******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;
   judicial OB_IAX_SIN_TRAMITA_JUDICIAL;
   fiscal OB_IAX_SIN_TRAMITA_FISCAL;
   /*************************************************************************
         F_SET_OBJ_SINTRAMITE
      Traspasa los valores de los parámetros a los atributos del objeto OB_IAX_SIN_TRAMITE.
      param in pnsinies                : número de siniestro
      param in pntramte                : número de trámite
      param in pctramte                : código de trámite
      param in out ptramite            : objeto ob_iax_sin_tramite
      param in out t_iax_mensajes      : mensajes de error
      return                           : 0 todo correcto
                                         1 ha habido un error
   *************************************************************************/
   FUNCTION f_set_obj_sintramite(
      pnsinies IN VARCHAR2,
      pntramte IN NUMBER,
      pctramte IN NUMBER,
      ptramite IN OUT ob_iax_sin_tramite,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_error        NUMBER := 0;
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(500)
         := 'pnsinies: ' || pnsinies || ' - pntramte: ' || pntramte || ' - pctramte: '
            || pctramte;
      v_object       VARCHAR2(200) := 'PAC_MD_SIN_TRAMITE.f_set_obj_sintramite';
      v_ttramite     sin_destramite.ttramite%TYPE;
   BEGIN
      IF pntramte IS NULL THEN
         RAISE e_param_error;
      END IF;

      v_pasexec := 2;
      ptramite.nsinies := pnsinies;
      ptramite.ntramte := pntramte;
      ptramite.ctramte := pctramte;

      IF pctramte IS NOT NULL THEN
         BEGIN
            SELECT ttramite
              INTO v_ttramite
              FROM sin_destramite
             WHERE ctramte = pctramte
               AND cidioma = pac_md_common.f_get_cxtidioma;
         EXCEPTION
            WHEN OTHERS THEN
               v_ttramite := '';
         END;
      END IF;

      ptramite.ttramte := v_ttramite;
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
         F_SET_OBJ_SINTRAMITE_MOV
      Traspasa los valores de los parámetros a los atributos del objeto OB_IAX_SIN_TRAMITE_MOV.
      param in pnsinies                : número de siniestro
      param in pntramte                : número de trámite
      param in pnmovtte                : número de movimiento trámite
      param in pcesttte                : código de estado trámite (VF.6)
      param in CCAUEST                 :  Causa cambio de estado
      param in CUNITRA                 : Código de unidad de tramitación
      param in CTRAMITAD               : Código de tramitador
      param in FESTTRA                 : Fecha estado trámite
      param in CUSUALT                 : Usuario de alta
      param in FALTA                   : Fecha de alta
      param in out ptmovstramite       : objeto ob_iax_sin_tramite_mov
      param in out t_iax_mensajes      : mensajes de error
      return                           : 0 todo correcto
                                         1 ha habido un error
      -- Bug 0022108 - 14/06/2012 - JMF
   *************************************************************************/
   FUNCTION f_set_obj_sintramite_mov(
      pnsinies IN VARCHAR2,
      pntramte IN NUMBER,
      pnmovtte IN NUMBER,
      pcesttte IN NUMBER,
      pccauest IN NUMBER,
      pcunitra IN VARCHAR2,
      pctramitad IN VARCHAR2,
      pfesttra IN DATE,
      pcusualt IN VARCHAR2,
      pfalta IN DATE,
      ptmovstramite IN OUT ob_iax_sin_tramite_mov,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_error        NUMBER := 0;
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(500)
         := ' pnsinies=' || pnsinies || ' pntramte=' || pntramte || ' pnmovtte=' || pnmovtte
            || ' pcesttte=' || pcesttte || ' pCCAUEST=' || pccauest || ' pCUNITRA='
            || pcunitra || ' pCTRAMITAD=' || pctramitad || ' pFESTTRA=' || pfesttra
            || ' pCUSUALT=' || pcusualt || ' pFALTA=' || pfalta;
      v_object       VARCHAR2(200) := 'PAC_MD_SIN_TRAMITE.f_set_obj_sintramite_mov';
      vtunitra       VARCHAR2(1000) := '';
      vttramitad     VARCHAR2(1000) := '';
   BEGIN
      IF pntramte IS NULL THEN
         RAISE e_param_error;
      END IF;

      v_pasexec := 2;
      ptmovstramite.nsinies := pnsinies;
      ptmovstramite.ntramte := pntramte;
      ptmovstramite.nmovtte := pnmovtte;
      ptmovstramite.cesttte := pcesttte;

      IF pcesttte IS NOT NULL THEN
         ptmovstramite.testtte := ff_desvalorfijo(6, pac_md_common.f_get_cxtidioma, pcesttte);
      END IF;

      ptmovstramite.ccauest := pccauest;
      ptmovstramite.cunitra := pcunitra;
      ptmovstramite.ctramitad := pctramitad;
      ptmovstramite.festtra := pfesttra;
      ptmovstramite.cusualt := pcusualt;
      ptmovstramite.falta := pfalta;

      IF pccauest IS NOT NULL THEN
         ptmovstramite.tcauest := ff_desvalorfijo(739, pac_md_common.f_get_cxtidioma,
                                                  pccauest);
      END IF;

      BEGIN
         SELECT ttramitad
           INTO vtunitra
           FROM sin_codtramitador tram
          WHERE tram.ctramitad = pcunitra;

         SELECT ttramitad
           INTO vttramitad
           FROM sin_codtramitador tram
          WHERE tram.ctramitad = pctramitad;
      EXCEPTION
         WHEN OTHERS THEN
            vtunitra := '';
            vttramitad := '';
      END;

      ptmovstramite.tunitra := vtunitra;
      ptmovstramite.ttramitad := vttramitad;
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
   END f_set_obj_sintramite_mov;

   /*************************************************************************
         F_INICIALIZA_TRAMITES
      Inicializa el objeto T_IAX_SIN_TRAMITES.
      param in psproduc                : código de producto
      param in pcactivi                : código de actividad
      param in pnsinies                : número de siniestro
      param in pctramte                : tramite especifico a crear (si esta informado)
      param in out pttramites          : objeto t_iax_sin_tramites
      param in out t_iax_mensajes      : mensajes de error
      return                           : 0 todo correcto
                                         1 ha habido un error
   *************************************************************************/
   FUNCTION f_inicializa_tramites(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pnsinies IN VARCHAR2,
      pctramte IN NUMBER,
      pttramites IN OUT t_iax_sin_tramite,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_error        NUMBER := 0;
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(500)
         := 'p: ' || psproduc || ' a: ' || pcactivi || ' s: ' || pnsinies || ' t=' || pctramte;
      v_object       VARCHAR2(200) := 'PAC_MD_SIN_TRAMITE.f_inicializa_tramites';
      v_index        NUMBER(5) := 0;
      v_cont         NUMBER(5);
      j              NUMBER(5);
      vcunitra       sin_tramite_mov.cunitra%TYPE;
      vctramitad     sin_tramite_mov.ctramitad%TYPE;
      v_cempres      codiram.cempres%TYPE;

      CURSOR cur_protramite IS
         SELECT DISTINCT t.ctramte
                    FROM sin_pro_tramitacion t, sin_prod_tramite tr
                   WHERE t.sproduc = psproduc
                     AND t.cactivi = pcactivi
                     AND((pctramte IS NULL
                          AND cgenaut = 1)
                         OR(pctramte IS NOT NULL
                            AND t.ctramte = pctramte))
                     AND tr.sproduc = t.sproduc
                     AND tr.cactivi = t.cactivi
                     AND tr.ctramte = t.ctramte;
   BEGIN
      IF psproduc IS NULL THEN
         RAISE e_param_error;
      END IF;

      v_pasexec := 2;

      IF pttramites IS NULL THEN
         pttramites := t_iax_sin_tramite();
      END IF;

      FOR reg IN cur_protramite LOOP
         v_pasexec := 3;

         -- ini Bug 0022099 - 16/05/2012 - JMF: index
         IF pttramites.COUNT > 0 THEN
            v_index := pttramites(pttramites.LAST).ntramte + 1;
         ELSE
            v_index := 1;
         END IF;

         -- fin Bug 0022099 - 16/05/2012 - JMF: index
         pttramites.EXTEND;
         -- Bug 0022099 - 16/05/2012 - JMF:  v_index := pttramites.LAST;
         pttramites(pttramites.LAST) := ob_iax_sin_tramite();
         v_pasexec := 4;
         -- Bug 0022099 - 16/05/2012 - JMF: index
         v_error := f_set_obj_sintramite(pnsinies, v_index, reg.ctramte,
                                         pttramites(pttramites.LAST), mensajes);

         IF v_error <> 0 THEN
            RETURN 1;
         END IF;

         pttramites(pttramites.LAST).movimientos := t_iax_sin_tramite_mov();
         pttramites(pttramites.LAST).movimientos.EXTEND;
         j := pttramites(pttramites.LAST).movimientos.LAST;
         v_pasexec := 5;
         pttramites(pttramites.LAST).movimientos(j) := ob_iax_sin_tramite_mov();
         v_pasexec := 6;

         -- Bug 0022099 - 16/05/2012 - JMF: index

         -- ini Bug 0022108 - 14/06/2012 - JMF
         -- 23615:ASN:05/09/2012 ini
--         IF pnsinies IS NULL THEN
         IF NVL(pnsinies, -1) = -1 THEN
            -- 23615:ASN:05/09/2012 fin

            -- 23101:ASN:28/008/2012 ini
            /*
            SELECT MAX(b.cempres)
              INTO v_cempres
              FROM productos a, codiram b
             WHERE a.sproduc = psproduc
               AND b.cramo = a.cramo;

            v_error := pac_siniestros.f_get_tramitador_defecto(v_cempres, f_user, NULL, NULL,
                                                               NULL, pnsinies, reg.ctramte,
                                                               NULL, vcunitra, vctramitad);

            IF NVL(v_error, 99999) > 1 THEN
               RAISE e_object_error;
            END IF;
            */
            vcunitra := 'U000';
            vctramitad := 'T000';
         -- 23101:ASN:28/008/2012 fin
         ELSE
            v_error := pac_siniestros.f_get_tramitador(pnsinies,
--                                                     reg.ctramte, -- 23615:ASN:07/09/2012
                                                       v_index, NULL, vcunitra, vctramitad);

            IF NVL(v_error, 99999) > 1 THEN
               RAISE e_object_error;
            END IF;
         END IF;

         v_error := 0;
         -- fin Bug 0022108 - 14/06/2012 - JMF
         v_error := f_set_obj_sintramite_mov(pnsinies, v_index, j, 0, 0, vcunitra, vctramitad,
                                             f_sysdate, NULL, NULL,
                                             pttramites(pttramites.LAST).movimientos(j),
                                             mensajes);

         IF v_error <> 0 THEN
            RAISE e_object_error;
         END IF;

         v_pasexec := 7;
         -- Bug 0022099 - 16/05/2012 - JMF: index
         v_error := f_set_obj_sintramite_recobro(pnsinies, v_index,
                                                 pttramites(pttramites.LAST).recobro, mensajes);

         IF v_error <> 0 THEN
            RAISE e_object_error;
         END IF;

         v_pasexec := 8;
         -- Bug 0022099 - 16/05/2012 - JMF: index
         v_error := f_set_obj_sintramite_lesiones(pnsinies, v_index,
                                                  pttramites(pttramites.LAST).lesiones,
                                                  mensajes);

         IF v_error <> 0 THEN
            RAISE e_object_error;
         END IF;

         -- ini Bug 0022099 - 16/05/2012 - JMF
         v_pasexec := 9;
         -- Bug 0022099 - 16/05/2012 - JMF: index
         v_error := f_set_obj_sintramite_asist(pnsinies, v_index,
                                               pttramites(pttramites.LAST).asistencia,
                                               mensajes);

         IF v_error <> 0 THEN
            RAISE e_object_error;
         END IF;
      -- fin Bug 0022099 - 16/05/2012 - JMF
      END LOOP;

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
   END f_inicializa_tramites;

   /*************************************************************************
         F_GET_CODTRAMITE
      Obtiene un cursor con los diferentes códigos de trámites definidos.
      param in psproduc                : código de producto
      param in pcactivi                : código de actividad
      param in out t_iax_mensajes      : mensajes de error
      return                           : el cursor
   *************************************************************************/
   FUNCTION f_get_codtramite(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      v_error        NUMBER := 0;
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(500) := 'psproduc: ' || psproduc || ' - pcactivi: ' || pcactivi;
      v_object       VARCHAR2(200) := 'PAC_MD_SIN_TRAMITE.f_get_codtramite';
      v_query        VARCHAR2(1000)
         := 'SELECT p.ctramte, d.ttramite FROM sin_prod_tramite p, sin_destramite d'
            || ' WHERE d.ctramte = p.ctramte AND d.cidioma = '
            || pac_md_common.f_get_cxtidioma || ' AND p.sproduc = ' || psproduc
            || ' AND p.cactivi = ' || pcactivi || ' AND p.ctramte <> 9999';   -- 21620:ASN:06/08/2012
      v_cursor       sys_refcursor;
   BEGIN
      IF psproduc IS NULL
         OR pcactivi IS NULL THEN
         RAISE e_param_error;
      END IF;

      v_pasexec := 2;
      v_cursor := pac_iax_listvalores.f_opencursor(v_query, mensajes);
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
      FUNCTION f_get_tramites
         Devuelve una colección de objetos OB_IAX_SIN_TRAMITE de un siniestro
         determinado
         param in pnsinies         : numero del sinistre
         param out pttramites      : t_iax_sin_tramite
         param in out mensajes     : mensajes de error
         return                    : 0 -> Tot correcte
                                     1 -> S'ha produit un error
   *************************************************************************/
   FUNCTION f_get_tramites(
      pnsinies IN sin_siniestro.nsinies%TYPE,
      ptramites OUT t_iax_sin_tramite,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      cur            sys_refcursor;
      vsquery        VARCHAR2(5000);
      vobjectname    VARCHAR2(500) := 'PAC_MD_SIN_TRAMITE.f_get_tramites';
      vparam         VARCHAR2(500) := 'parámetros - pnsinies: ' || pnsinies;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;

      -- BUG 0023643 - 05/11/2012 - JMF
      CURSOR cur_tra IS
         SELECT nsinies, ntramte
           FROM sin_tramite
          WHERE nsinies = pnsinies;
   --  AND ctramte <> 9999;
   BEGIN
      --Comprovació dels parámetres d'entrada
      IF pnsinies IS NULL THEN
         RAISE e_param_error;
      END IF;

      ptramites := t_iax_sin_tramite();

      FOR reg IN cur_tra LOOP
         ptramites.EXTEND;
         ptramites(ptramites.LAST) := ob_iax_sin_tramite();
         vnumerr := f_get_tramite(pnsinies, reg.ntramte, ptramites(ptramites.LAST), mensajes);

         IF mensajes IS NOT NULL THEN
            IF mensajes.COUNT > 0 THEN
               RETURN 1;
            END IF;
         END IF;
      END LOOP;

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
   END f_get_tramites;

    /*************************************************************************
      FUNCTION f_get_tramite
         Asigna valores a los atributos de un objeto OB_IAX_SIN_TRAMITE
         param in pnsinies       : numero del sinistre
         param in pntramte       : número de trámite
         param out ptramite      : ob_iax_sin_tramite
         param in out mensajes   : mensajes de error
         return                  : 0 -> Tot correcte
                                   1 -> S'ha produit un error
   *************************************************************************/
   FUNCTION f_get_tramite(
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pntramte IN NUMBER,
      ptramite OUT ob_iax_sin_tramite,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_SIN_TRAMITE.f_get_tramite';
      vparam         VARCHAR2(500)
                            := 'parámetros - pnsinies: ' || pnsinies || 'ntramte ' || pntramte;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vsquery        VARCHAR2(4000);
      cur            sys_refcursor;
   BEGIN
      ptramite := ob_iax_sin_tramite();
      vnumerr := pac_sin_tramite.f_get_tramite(pnsinies, pntramte,
                                               pac_md_common.f_get_cxtidioma, vsquery);
      cur := pac_iax_listvalores.f_opencursor(vsquery, mensajes);
      vpasexec := 2;

-- tram.nsinies, tram.ntramte, tram.ctramte, dt.TTRAMITE
      LOOP
         FETCH cur
          INTO ptramite.nsinies, ptramite.ntramte, ptramite.ctramte, ptramite.ttramte;

         EXIT WHEN cur%NOTFOUND;
         vpasexec := 5;
         vnumerr := f_get_tramite_movs(pnsinies, ptramite.ntramte, ptramite.movimientos,
                                       mensajes);

         IF vnumerr <> 0 THEN
            RAISE e_object_error;
         END IF;
      END LOOP;

      CLOSE cur;

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
   END f_get_tramite;

   /*************************************************************************
      FUNCTION f_get_tramite_mov
         Asigna valores a los atributos de un objeto OB_IAX_SIN_TRAMITE_MOV
         param in pnsinies       : numero del sinistre
         param in pntramte       : número de trámite
         param in pnmovtte       : número movimiento trámite
         param out ptramitemov   : ob_iax_sin_tramite_mov
         param in out mensajes   : mensajes de error
         return                  : 0 -> Tot correcte
                                   1 -> S'ha produit un error
   *************************************************************************/
   FUNCTION f_get_tramite_mov(
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pntramte IN NUMBER,
      pnmovtte IN NUMBER,
      ptramitemov OUT ob_iax_sin_tramite_mov,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_SIN_TRAMITE.f_get_tramite_mov';
      vparam         VARCHAR2(500)
         := 'parámetros - pnsinies: ' || pnsinies || 'ntramte ' || pntramte || ' pnmovtte '
            || pnmovtte;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vsquery        VARCHAR2(5000);
      cur            sys_refcursor;
   BEGIN
      ptramitemov := ob_iax_sin_tramite_mov();
      vnumerr := pac_sin_tramite.f_get_tramite_mov(pnsinies, pntramte, pnmovtte,
                                                   pac_md_common.f_get_cxtidioma, vsquery);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      cur := pac_iax_listvalores.f_opencursor(vsquery, mensajes);
      vpasexec := 4;

      LOOP
         -- Bug 0022108 - 14/06/2012 - JMF: añadir campos
         FETCH cur
          INTO ptramitemov.nsinies, ptramitemov.ntramte, ptramitemov.nmovtte,
               ptramitemov.cesttte, ptramitemov.testtte, ptramitemov.ccauest,
               ptramitemov.cunitra, ptramitemov.ctramitad, ptramitemov.festtra,
               ptramitemov.tunitra, ptramitemov.ttramitad, ptramitemov.tcauest;

         EXIT WHEN cur%NOTFOUND;
      END LOOP;

      CLOSE cur;

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
   END f_get_tramite_mov;

   /*************************************************************************
      FUNCTION f_get_tramite_movs
         Devuelve una colección de objetos OB_IAX_SIN_TRAMITE_MOV de un trámite
         determinado
         param in pnsinies         : numero del sinistre
         param in pntramte         : número de trámite
         param out ptramitemovs   : t_iax_sin_tramite_mov
         param in out mensajes     : mensajes de error
         return                    : 0 -> Tot correcte
                                     1 -> S'ha produit un error
   *************************************************************************/
   FUNCTION f_get_tramite_movs(
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pntramte IN NUMBER,
      ptramitemovs OUT t_iax_sin_tramite_mov,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_SIN_TRAMITE.f_get_tramite_movs';
      vparam         VARCHAR2(500)
                           := 'parámetros - pnsinies: ' || pnsinies || ' pntramte' || pntramte;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;

      CURSOR cur_tra IS
         SELECT   nsinies, ntramte, nmovtte
             FROM sin_tramite_mov
            WHERE nsinies = pnsinies
              AND ntramte = pntramte
         ORDER BY nmovtte ASC;
   BEGIN
      --Comprovació dels parámetres d'entrada
      IF pnsinies IS NULL
         OR pntramte IS NULL THEN
         RAISE e_param_error;
      END IF;

      ptramitemovs := t_iax_sin_tramite_mov();

      FOR reg IN cur_tra LOOP
         ptramitemovs.EXTEND;
         ptramitemovs(ptramitemovs.LAST) := ob_iax_sin_tramite_mov();
         vnumerr := f_get_tramite_mov(pnsinies, reg.ntramte, reg.nmovtte,
                                      ptramitemovs(ptramitemovs.LAST), mensajes);

         IF mensajes IS NOT NULL THEN
            IF mensajes.COUNT > 0 THEN
               RETURN 1;
            END IF;
         END IF;
      END LOOP;

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
   END f_get_tramite_movs;

/*************************************************************************
      FUNCTION f_set_tramite_mov
         Función puente para grabar los movimientos de los trámites.
         param in ptramitemov   : objeto movimiento trámite
         param in pnsinies   : numero del sinistre
         param in out mensajes   : mensajes de error
         return              : 0 -> Tot correcte
                               1 -> S'ha produit un error
   *************************************************************************/
   FUNCTION f_set_tramite_mov(
      ptramitemov IN ob_iax_sin_tramite_mov,
      pnsinies IN sin_siniestro.nsinies%TYPE,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_SIN_TRAMITE.f_set_tramite_mov';
      vparam         VARCHAR2(500) := 'parámetros - pnsinies: ' || pnsinies;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 1;
      vnmovtte       NUMBER;
   BEGIN
      vnmovtte := ptramitemov.nmovtte;
      -- Bug 0022108 - 14/06/2012 - JMF: añadir campos
      vnumerr := pac_sin_tramite.f_ins_tramite_mov(pnsinies, ptramitemov.ntramte,
                                                   ptramitemov.cesttte, ptramitemov.ccauest,
                                                   ptramitemov.cunitra, ptramitemov.ctramitad,
                                                   ptramitemov.festtra, vnmovtte);
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN vnumerr;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN vnumerr;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN vnumerr;
   END f_set_tramite_mov;

   /*************************************************************************
      FUNCTION f_set_tramite_movs
         Función que por cada movimiento de un objeto trámite llama la función que grabe estos movimientos.
         param in pnsinies   : numero del sinistre
         param in ptramitemov   : coleccion de objeto movimiento trámite
         param in out mensajes   : mensajes de error
         return              : 0 -> Tot correcte
                               1 -> S'ha produit un error
   *************************************************************************/
   FUNCTION f_set_tramite_movs(
      pnsinies IN sin_siniestro.nsinies%TYPE,
      ptramitemov IN t_iax_sin_tramite_mov,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_SIN_TRAMITE.f_set_tramite_movs';
      vparam         VARCHAR2(500) := 'parámetros - pnsinies: ' || pnsinies;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      IF ptramitemov IS NOT NULL THEN
         IF ptramitemov.COUNT > 0 THEN
            FOR i IN ptramitemov.FIRST .. ptramitemov.LAST LOOP
               IF ptramitemov.EXISTS(i) THEN   -- 22702:ASN:26/07/2012
                  vnumerr := f_set_tramite_mov(ptramitemov(i), pnsinies, mensajes);

                  IF mensajes IS NOT NULL THEN
                     IF mensajes.COUNT > 0 THEN
                        RETURN vnumerr;
                     END IF;
                  END IF;
               END IF;
            END LOOP;
         END IF;
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
   END f_set_tramite_movs;

   /*************************************************************************
      FUNCTION f_set_tramite
         Función puente para grabar un trámite y lanza la funcion puente para
         grabar los movimientos de éste.
         param in ptramite   : objeto trámite
         param in pnsinies   : numero del sinistre
         param in out mensajes   : mensajes de error
         return              : 0 -> Tot correcte
                               1 -> S'ha produit un error
   *************************************************************************/
   FUNCTION f_set_tramite(
      ptramite IN ob_iax_sin_tramite,
      pnsinies IN sin_siniestro.nsinies%TYPE,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_SIN_TRAMITE.f_set_tramite';
      vparam         VARCHAR2(500) := 'parámetros - pnsinies: ' || pnsinies;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 1;
      vntramte       NUMBER;
   BEGIN
      vpasexec := 10;
      vntramte := ptramite.ntramte;
      vpasexec := 20;
      vnumerr := pac_sin_tramite.f_ins_tramite(pnsinies, ptramite.ctramte, vntramte);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      vpasexec := 30;
      vnumerr := f_set_tramite_movs(pnsinies, ptramite.movimientos, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      vpasexec := 40;

      --vnumerr := f_ins_tramite_recobro(pnsinies, ptramite.recobro, mensajes);
      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN vnumerr;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN vnumerr;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN vnumerr;
   END f_set_tramite;

   /*************************************************************************
      FUNCTION f_set_tramites
         Función que por cada objeto trámite de la colección trámites lanza
         la función puente para grabar estos trámites.
         param in ptramites   : colección objetos trámite
         param in pnsinies   : numero del sinistre
         param in out mensajes   : mensajes de error
         return              : 0 -> Tot correcte
                               1 -> S'ha produit un error
   *************************************************************************/
   FUNCTION f_set_tramites(
      ptramites IN t_iax_sin_tramite,
      pnsinies IN sin_siniestro.nsinies%TYPE,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_SIN_TRAMITES.F_set_tramites';
      vparam         VARCHAR2(500) := 'parámetros - pnsinies: ' || pnsinies;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      -- Bug 0022490 - 09/07/2012 - JMF: modificar condicion
      vpasexec := 10;

      IF ptramites IS NOT NULL THEN
         vpasexec := 12;

         IF ptramites.COUNT > 0 THEN
            vpasexec := 14;

            FOR i IN ptramites.FIRST .. ptramites.LAST LOOP
               vpasexec := 16;

               IF ptramites.EXISTS(i) THEN   -- 22702:ASN:26/07/2012
                  vnumerr := f_set_tramite(ptramites(i), pnsinies, mensajes);

                  IF mensajes IS NOT NULL THEN
                     IF mensajes.COUNT > 0 THEN
                        RETURN vnumerr;
                     END IF;
                  END IF;
               END IF;
            END LOOP;
         END IF;
      END IF;

      vpasexec := 18;
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
   END f_set_tramites;

   /*************************************************************************
         F_SET_OBJ_SINTRAMITE_recobro
      Traspasa los valores de los parámetros a los atributos del objeto OB_IAX_SIN_TRAMITE_MOV.
      param in pnsinies                : número de siniestro
      param in pntramte                : número de trámite
      param in pnmovtte                : número de movimiento trámite
      param in pcesttte                : código de estado trámite (VF.6)
      param in out ptmovstramite       : objeto ob_iax_sin_tramite_mov
      param in out t_iax_mensajes      : mensajes de error
      return                           : 0 todo correcto
                                         1 ha habido un error
   *************************************************************************/
   FUNCTION f_set_obj_sintramite_recobro(
      pnsinies IN VARCHAR2,
      pntramte IN NUMBER,
      ptrecstramite IN OUT ob_iax_sin_tramite_recobro,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_error        NUMBER := 0;
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(500) := 'pnsinies: ' || pnsinies || ' - pntramte: ' || pntramte;
      v_object       VARCHAR2(200) := 'PAC_MD_SIN_TRAMITE.f_set_obj_sintramite_recobro';
   BEGIN
      IF pntramte IS NULL
         OR pntramte IS NULL THEN
         RAISE e_param_error;
      END IF;

      v_pasexec := 2;
      ptrecstramite.nsinies := pnsinies;
      ptrecstramite.ntramte := pntramte;

      BEGIN
         FOR cur IN (SELECT cusualt, falta, cusumod, fusumod, fprescrip, ireclamt, irecobt,
                            iconcurr, ircivil, iassegur, cresrecob, cdestim, nrefges, ctiprec
                       FROM sin_tramite_recobro
                      WHERE nsinies = pnsinies
                        AND ntramte = pntramte) LOOP
            ptrecstramite.cusualt := cur.cusualt;
            ptrecstramite.falta := cur.falta;
            ptrecstramite.cusumod := cur.cusumod;
            ptrecstramite.fusumod := cur.fusumod;
            ptrecstramite.fprescrip := cur.fprescrip;
            ptrecstramite.ireclamt := cur.ireclamt;
            ptrecstramite.iconcurr := cur.iconcurr;
            ptrecstramite.ircivil := cur.ircivil;
            ptrecstramite.iassegur := cur.iassegur;
            ptrecstramite.cresrecob := cur.cresrecob;
            ptrecstramite.cdestim := cur.cdestim;
            ptrecstramite.nrefges := cur.nrefges;
            ptrecstramite.ctiprec := cur.ctiprec;
            ptrecstramite.irecobt := cur.irecobt;
         END LOOP;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            NULL;
      END;

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
   END f_set_obj_sintramite_recobro;

   /*************************************************************************
      FUNCTION f_set_tramite_mov
         Función puente para grabar los movimientos de los trámites.
         param in ptramitemov   : objeto movimiento trámite
         param in pnsinies   : numero del sinistre
         param in out mensajes   : mensajes de error
         return              : 0 -> Tot correcte
                               1 -> S'ha produit un error
   *************************************************************************/
   FUNCTION f_ins_tramite_recobro(
      pnsinies IN sin_siniestro.nsinies%TYPE,
      ptramiterec IN ob_iax_sin_tramite_recobro,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_SIN_TRAMITE.f_set_tramite_recobro';
      vparam         VARCHAR2(500) := 'parámetros - pnsinies: ' || pnsinies;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 1;
      vnmovtte       NUMBER;
   BEGIN
      -- BUG 21546_108727- 04/02/2012 - JLTS - Se cambia la utilizacion del objeto por parametros simples
      vnumerr := pac_sin_tramite.f_ins_tramite_recob(pnsinies, ptramiterec.ntramte,
                                                     ptramiterec.fprescrip,
                                                     ptramiterec.ireclamt,
                                                     ptramiterec.irecobt,
                                                     ptramiterec.iconcurr,
                                                     ptramiterec.ircivil,
                                                     ptramiterec.iassegur,
                                                     ptramiterec.cresrecob,
                                                     ptramiterec.cdestim, ptramiterec.nrefges,
                                                     ptramiterec.ctiprec);
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN vnumerr;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN vnumerr;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN vnumerr;
   END f_ins_tramite_recobro;

   FUNCTION f_set_obj_sintramite_lesiones(
      pnsinies IN VARCHAR2,
      pntramte IN NUMBER,
      ptlestramite IN OUT ob_iax_sin_tramite_lesiones,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_error        NUMBER := 0;
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(500) := 'pnsinies: ' || pnsinies || ' - pntramte: ' || pntramte;
      v_object       VARCHAR2(200) := 'PAC_MD_SIN_TRAMITE.f_set_obj_sintramite_lesiones';
   BEGIN
      IF pntramte IS NULL
         OR pntramte IS NULL THEN
         RAISE e_param_error;
      END IF;

      v_pasexec := 2;
      ptlestramite.nsinies := pnsinies;
      ptlestramite.ntramte := pntramte;

      BEGIN
         FOR cur IN (SELECT cusualt, falta, cusumod, fusumod, nlesiones, nmuertos, agravantes,
                            cgradoresp, ctiplesiones, ctiphos
                       FROM sin_tramite_lesiones
                      WHERE nsinies = pnsinies
                        AND ntramte = pntramte) LOOP
            ptlestramite.cusualt := cur.cusualt;
            ptlestramite.falta := cur.falta;
            ptlestramite.cusumod := cur.cusumod;
            ptlestramite.fusumod := cur.fusumod;
            ptlestramite.nlesiones := cur.nlesiones;
            ptlestramite.nmuertos := cur.nmuertos;
            ptlestramite.agravantes := cur.agravantes;
            ptlestramite.cgradoresp := cur.cgradoresp;
            ptlestramite.ctiplesiones := cur.ctiplesiones;
            ptlestramite.ctiphos := cur.ctiphos;
         END LOOP;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            NULL;
      END;

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
   END f_set_obj_sintramite_lesiones;

   /*************************************************************************
      FUNCTION f_set_tramite_mov
         Función puente para grabar los movimientos de los trámites.
         param in ptramitemov   : objeto movimiento trámite
         param in pnsinies   : numero del sinistre
         param in out mensajes   : mensajes de error
         return              : 0 -> Tot correcte
                               1 -> S'ha produit un error
   *************************************************************************/
   FUNCTION f_ins_tramite_lesiones(
      pnsinies IN sin_siniestro.nsinies%TYPE,
      ptramiteles IN ob_iax_sin_tramite_lesiones,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_SIN_TRAMITE.f_set_tramite_lesiones';
      vparam         VARCHAR2(500) := 'parámetros - pnsinies: ' || pnsinies;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 1;
      vnmovtte       NUMBER;
   BEGIN
      vnumerr := pac_sin_tramite.f_ins_tramite_lesiones(pnsinies, ptramiteles.ntramte,
                                                        ptramiteles.nlesiones,
                                                        ptramiteles.nmuertos,
                                                        ptramiteles.agravantes,
                                                        ptramiteles.cgradoresp,
                                                        ptramiteles.ctiplesiones,
                                                        ptramiteles.ctiphos);
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN vnumerr;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN vnumerr;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN vnumerr;
   END f_ins_tramite_lesiones;

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
      vobjectname    VARCHAR2(500) := 'PAC_MD_SIN_TRAMITE.f_hay_tramites';
      vparam         VARCHAR2(500) := 'parámetros - pnsinies: ' || pnsinies;
      vpasexec       NUMBER(5) := 1;
   BEGIN
      IF pnsinies IS NULL THEN
         RAISE e_param_error;
      END IF;

      phay_tramites := pac_sin_tramite.ff_hay_tramites(pnsinies);
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
      Traspasa los valores de la BBDD al objeto
      param in pnsinies                : número de siniestro
      param in pntramte                : número de trámite
      param in ptasitramite            : objeto
      param in out t_iax_mensajes      : mensajes de error
      return                           : 0 todo correcto
                                         1 ha habido un error
    -- Bug 0022099 - 16/05/2012 - JMF
   *************************************************************************/
   FUNCTION f_set_obj_sintramite_asist(
      pnsinies IN VARCHAR2,
      pntramte IN NUMBER,
      ptasitramite IN OUT ob_iax_sin_tramite_asistencia,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_error        NUMBER := 0;
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(500) := 'pnsinies: ' || pnsinies || ' - pntramte: ' || pntramte;
      v_object       VARCHAR2(200) := 'PAC_MD_SIN_TRAMITE.f_set_obj_sintramite_asist';
   BEGIN
      IF pntramte IS NULL THEN
         RAISE e_param_error;
      END IF;

      v_pasexec := 2;
      ptasitramite.nsinies := pnsinies;
      ptasitramite.ntramte := pntramte;

      BEGIN
         v_pasexec := 3;

         FOR cur IN (SELECT cusualt, falta, cusumod, fusumod, trefext, cciaasis
                       FROM sin_tramite_asistencia
                      WHERE nsinies = pnsinies
                        AND ntramte = pntramte) LOOP
            v_pasexec := 4;
            ptasitramite.cusualt := cur.cusualt;
            ptasitramite.falta := cur.falta;
            ptasitramite.cusumod := cur.cusumod;
            ptasitramite.fusumod := cur.fusumod;
            ptasitramite.trefext := cur.trefext;
            ptasitramite.cciaasis := cur.cciaasis;
         END LOOP;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            NULL;
      END;

      v_pasexec := 5;
      RETURN v_error;
   EXCEPTION
      WHEN e_param_error THEN
         p_tab_error(f_sysdate, f_user, v_object, v_pasexec, 'e_param_error', v_param);
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005, v_pasexec, v_param);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000006, v_pasexec, v_param);
         RETURN 1;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param,
                     SQLCODE || ' - ' || SQLERRM);
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_set_obj_sintramite_asist;

   /*************************************************************************
      FUNCION
      Traspasa los valores del objeto a la bbdd
      param in pnsinies                : número de siniestro
      param in ptramiteasi             : objeto
      param in out t_iax_mensajes      : mensajes de error
      return                           : 0 todo correcto
                                         1 ha habido un error
    -- Bug 0022099 - 16/05/2012 - JMF
   *************************************************************************/
   FUNCTION f_ins_tramite_asist(
      pnsinies IN VARCHAR2,
      ptramiteasi IN ob_iax_sin_tramite_asistencia,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_SIN_TRAMITE.f_ins_tramite_asist';
      vparam         VARCHAR2(500) := 'parámetros - pnsinies: ' || pnsinies;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 1;
      v_sin          sin_tramite_asistencia.nsinies%TYPE;
   BEGIN
      vnumerr := pac_sin_tramite.f_ins_tramite_asistencia(pnsinies, ptramiteasi.ntramte,
                                                          ptramiteasi.trefext,
                                                          ptramiteasi.cciaasis, v_sin);

      IF vnumerr = 9903714 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje_var(mensajes, 1, 9903714, v_sin, 1);
         vnumerr := 9000919;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN vnumerr;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN vnumerr;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     SQLCODE || ' - ' || SQLERRM);
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN vnumerr;
   END f_ins_tramite_asist;

   /***********************************************************************
      Cambia el estado de una tramite
      param in pnsinies : Número siniestro
      param in pntramit : Número tramitación
      param in pcesttra : Código estado
      return            : 0 -> Tot correcte
                          1 -> S'ha produit un error
   ***********************************************************************/
   FUNCTION f_estado_tramite(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      pcesttra IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'parámetros - pnsinies:' || pnsinies || ' - pntramit:' || pntramit
            || ' - pcesttra:' || pcesttra;
      vobjectname    VARCHAR2(50) := 'PAC_MD_SIN_TRAMITE.f_estado_tramite';
      vnumerr        NUMBER(10) := 0;
   BEGIN
      vnumerr := pac_siniestros.f_estado_tramitacion(pnsinies, pntramit, pcesttra);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
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
   END f_estado_tramite;

    /*************************************************************************
      FUNCTION
         Crea o actualiza en bbdd, información del tramite asistencia.
         param in  pnsinies  : codi del sinistre
         param out pntramit  : Numero de tramitaci
         param in out t_iax_mensajes      : mensajes de error
         return              : Error (0 -> Tot correcte, codi error)

      Bug 22325/115249- 07/06/2012 - AMC
   *************************************************************************/
   FUNCTION f_get_tramite9999(
      pnsinies IN NUMBER,
      pntramit OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_SIN_TRAMITE.f_get_ntramitglobal';
      vparam         VARCHAR2(500) := 'parámetros - pnsinies: ' || pnsinies;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 1;
   BEGIN
      IF pnsinies IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_sin_tramite.f_get_tramite9999(pnsinies, pntramit);

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
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     SQLCODE || ' - ' || SQLERRM);
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_get_tramite9999;

  FUNCTION f_ini_obj_judicial(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      pnorden  IN NUMBER,
      proceso  OUT OB_IAX_SIN_TRAMITA_JUDICIAL,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
        vparam      VARCHAR2(500) := 'pnsinies: ' || pnsinies || ' - pntramit: ' || pntramit || ' - pnorden: ' ||pnorden ;
        vpasexec    NUMBER(5) := 1;
        vobjectname VARCHAR2(100):= 'PAC_MD_SIN_TRAMITE.f_ini_obj_judicial';
        vnumerr        NUMBER(8) := 1;
    BEGIN
      judicial := OB_IAX_SIN_TRAMITA_JUDICIAL();
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

      END f_ini_obj_judicial;

  FUNCTION f_get_procesos_judiciales(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN SYS_REFCURSOR IS
        vparam      VARCHAR2(500) := 'pnsinies: ' || pnsinies || ' - pntramit: ' || pntramit;
        vpasexec    NUMBER(5) := 1;
        vobjectname VARCHAR2(100):= 'PAC_MD_SIN_TRAMITE.f_get_procesos_judiciales';
        vnumerr        NUMBER(8) := 1;
        vquery VARCHAR2(10000) := '';
        cur sys_refcursor;
    BEGIN

      IF pnsinies IS NULL OR
         pntramit IS NULL THEN
         RAISE e_param_error;
      END IF;
      --Inicio IAXIS 3595 AABC Insert automatico del detalle tramitacion Judicial.
      vquery := 'SELECT t.norden, m.nradica, t.fnotifi, t.cproceso  ' ||
                '  FROM sin_tramita_judicial    t,   ' ||
                '       sin_tramitacion m  ' ||
                -- '       poblaciones p ' ||
                ' WHERE t.nsinies = m.nsinies ' ||
                '   AND t.ntramit = m.ntramit ' ||
                -- '   AND p.cprovin = t.cprovin ' ||
                -- '   AND p.cpoblac = t.cpoblac ' ||
                '   AND t.nsinies = ''' || pnsinies || '''' ||
                '   AND t.ntramit = ' || pntramit;
      --Fin IAXIS 3595 AABC Insert automatico del detalle tramitacion Judicial.          
      cur := pac_iax_listvalores.f_opencursor(vquery, mensajes);
      RETURN cur;
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
         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;

      END f_get_procesos_judiciales;

  FUNCTION f_get_obj_judicial(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      pnorden IN NUMBER,
      objudicial OUT OB_IAX_SIN_TRAMITA_JUDICIAL,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
        vparam      VARCHAR2(500) := 'pnsinies: ' || pnsinies || ' - pntramit: ' || pntramit|| ' - pnorden: '|| pnorden;
        vpasexec    NUMBER(5) := 1;
        vobjectname VARCHAR2(100):= 'PAC_MD_SIN_TRAMITE.f_get_obj_judicial';
        vnumerr        NUMBER(8) := 1;
        detper t_iax_sin_t_judicial_detper;
        obdetper ob_iax_sin_t_judicial_detper;
        listGarantias t_iax_sin_t_valpretension;
        garantia ob_iax_sin_t_valpretension;
        listAudiencia t_iax_sin_t_judicial_audien;
        audiencia ob_iax_sin_t_judicial_audien;

        vsquery VARCHAR2(2000):='SELECT p.nsinies ,p.ntramit ,p.norden  ,p.cproceso,p.tproceso,p.cpostal ,p.cpoblac ,p.cprovin , p.TIEXTERNO, p.sprofes ,p.frecep  ,p.fnotifi ,p.fvencimi,p.frespues,p.fconcil ,p.fdesvin ,p.tpreten , '||
                  '  p.texcep1 ,p.texcep2 ,p.cconti ,p.cdespa, p.cdescf, p.cprovinf, p.cpoblacf ,p.cdespao, p.cdesco, p.cprovino, p.cpoblaco ,p.cposici ,p.cdemand ,p.sapodera,p.idemand ,p.ftdeman ,p.iconden ,p.csenten ,p.fsente1 ,p.csenten2 ,p.fsente2 ,p.casacion, p.fcasaci ,p.ctsente ,p.ftsente ,p.vtsente ,p.tfallo,p.coralproc,p.unicainst,p.funicainst, p.fmodifi, p.CUSUALT, ' ||
                  ' pac_isqlfor.f_dni(null, null, (select sperson from sin_prof_profesionales where sprofes = p.sprofes) ) NNUMIDEPROFES , ' ||
                  ' f_nombre((select sperson from sin_prof_profesionales where sprofes = p.sprofes),3) NOMBREPROFES, ' ||
                  ' pac_isqlfor.f_dni(null, null, p.SAPODERA) NNUMIDEAPO ,f_nombre(p.SAPODERA,3) NOMBREAPO ' ||
                  '  FROM sin_tramita_judicial p ' ||
                  ' WHERE p.nsinies = ' || pnsinies   ||
                  '   AND p.ntramit = ' || pntramit  ||
                  '   AND p.norden = ' || pnorden ||
                  ' ORDER BY p.norden ';

         vsquery1 VARCHAR2(2000):='SELECT p.nrol ,p.npersona ,p.ntipper  ,p.nnumide,p.tnombre,p.iimporte,  ' ||
                  '  DECODE(p.nrol,1, ff_desvalorfijo(800067,pac_md_common.f_get_cxtidioma() , p.ntipper),ff_desvalorfijo(8001099, pac_md_common.f_get_cxtidioma() , p.ntipper))  ttipper ' ||
                  ' FROM sin_tramita_judicial_detper p ' ||
                  ' WHERE p.nsinies = ' || pnsinies   ||
                  '   AND p.ntramit = ' || pntramit  ||
                  '   AND p.norden = ' || pnorden ||
                  ' ORDER BY p.npersona ';
         -- IAXIS 3597 AABC 06/05/2019 PROCESO JUDICIAL		  
         vsquery2 VARCHAR2(2000):=' SELECT DISTINCT(p.cgarant) , gg.tgarant, ' ||
                                          '  (SELECT pac_monedas.f_cmoneda_t(p.cdivisa)  FROM productos p, seguros s ' ||
                                     ' WHERE  s.sseguro = seg.sseguro   AND p.sproduc = s.sproduc ) CMONEDA,  ' ||
                                            'g.icaptot  ,p.ipreten, p.cusualt , p.fmodifi   ' ||
                                  ' FROM sin_tramita_valpretension p, sin_siniestro sin, seguros seg, garanseg g , garangen gg  ' ||
                                  ' WHERE p.nsinies = ' || pnsinies   ||
                                  '   AND p.ntramit = ' || pntramit  ||
                                  '   AND p.norden = ' || pnorden ||
                                  '   AND sin.nsinies = p.nsinies  ' ||
                                  '   AND sin.sseguro = seg.sseguro  ' ||
                                  '   AND g.cgarant = p.cgarant  ' ||
                                  '  AND gg.cgarant = p.cgarant ' ||
                                  '  AND gg.cidioma = pac_md_common.f_get_cxtidioma  ' ||
                                  '  AND g.sseguro = sin.sseguro  ' ||
								  ' AND g.NMOVIMI = (select max(NMOVIMI) from garanseg where sseguro=seg.sseguro  and cgarant =p.cgarant )' ||
                                  ' ORDER BY p.cgarant ';

        vsquery3 VARCHAR2(2000):='SELECT p.naudien ,p.faudien ,p.haudien ,p.taudien  ,p.cdespa  ,p.tlaudie ,p.caudien ,p.cdespao ,p.tlaudieo,p.caudieno,p.sabogau , ' ||
                  ' p.coral   ,p.cestado ,p.cresolu ,p.finsta1 ,p.finsta2 ,p.fnueva  ,p.tresult, pac_isqlfor.f_dni(null, null, p.SABOGAU) NNUMIDEAUDEN, f_nombre(p.SABOGAU,3) NOMBREAUDEN ' ||
                  '  FROM sin_tramita_judicial_audien p ' ||
                  ' WHERE p.nsinies = ' || pnsinies   ||
                  '   AND p.ntramit = ' || pntramit  ||
                  '   AND p.norden = ' || pnorden ||
                  ' ORDER BY p.naudien ';


       cur              sys_refcursor;
       cur_personas     sys_refcursor;
       cur_garantias    sys_refcursor;
       cur_audiencias   sys_refcursor;
       v_itotaseg NUMBER(19,2) := 0;
       v_itotpret NUMBER(19,2) := 0;
    BEGIN
        objudicial := ob_iax_sin_tramita_judicial();
        vpasexec := 2;
        cur := pac_iax_listvalores.f_opencursor(vsquery, mensajes);
        vpasexec := 3;
        LOOP
         FETCH cur
            INTO objudicial.nsinies ,objudicial.ntramit ,objudicial.norden  ,objudicial.cproceso,objudicial.tproceso,objudicial.cpostal ,objudicial.cpoblac ,objudicial.cprovin , objudicial.TIEXTERNO, objudicial.sprofes ,objudicial.frecep  ,objudicial.fnotifi ,objudicial.fvencimi,objudicial.frespues,objudicial.fconcil ,objudicial.fdesvin ,objudicial.tpreten ,objudicial.texcep1 ,objudicial.texcep2 ,objudicial.cconti ,objudicial.cdespa, objudicial.cdescf, objudicial.cprovinf, objudicial.cpoblacf, objudicial.cdespao, objudicial.cdesco, objudicial.cprovino, objudicial.cpoblaco ,objudicial.cposici ,objudicial.cdemand ,objudicial.sapodera,objudicial.idemand ,objudicial.ftdeman ,objudicial.iconden ,objudicial.csenten ,objudicial.fsente1 ,objudicial.csenten2 ,objudicial.fsente2 ,objudicial.casacion ,objudicial.fcasaci ,objudicial.ctsente ,objudicial.ftsente ,objudicial.vtsente ,objudicial.tfallo,objudicial.coralproc,objudicial.unicainst,objudicial.funicainst, objudicial.fmodifi, objudicial.CUSUALT, objudicial.nnumideprofes,objudicial.nombreprofes,objudicial.nnumideapo,objudicial.nombreapo;

         EXIT WHEN cur%NOTFOUND;
        END LOOP;

        CLOSE cur;

        judicial := objudicial;
        detper := t_iax_sin_t_judicial_detper();
        obdetper := ob_iax_sin_t_judicial_detper();
        cur_personas := pac_iax_listvalores.f_opencursor(vsquery1, mensajes);
        vpasexec := 4;
        LOOP
         FETCH cur_personas
          INTO obdetper.nrol ,obdetper.npersona ,obdetper.ntipper  ,obdetper.nnumide,obdetper.tnombre,obdetper.iimporte, obdetper.ttipper;
            IF cur_personas%FOUND THEN
              detper.EXTEND;
              detper(detper.LAST) := obdetper;
            END IF;
         EXIT WHEN cur_personas%NOTFOUND;
        END LOOP;

        CLOSE cur_personas;
        judicial.personas := detper;

        vpasexec := 5;
        listGarantias := t_iax_sin_t_valpretension();
        garantia := ob_iax_sin_t_valpretension();
        cur_garantias := pac_iax_listvalores.f_opencursor(vsquery2, mensajes);
        vpasexec := 6;
        LOOP
         FETCH cur_garantias
	 -- IAXIS 3597 AABC 06/05/2019 Proceso Judicial
          INTO garantia.cgarant , garantia.tgarant,garantia.cmoneda ,garantia.icapital  ,garantia.ipreten,garantia.cusualt,garantia.fmodifi;
            IF cur_garantias%FOUND THEN
            vpasexec := 7;
              listGarantias.EXTEND;
              listGarantias(listGarantias.LAST) := garantia;
              v_itotaseg := v_itotaseg + garantia.icapital;
              v_itotpret := v_itotpret + garantia.ipreten;
              vpasexec := 8;
            END IF;
         EXIT WHEN cur_garantias%NOTFOUND;
        END LOOP;

        CLOSE cur_garantias;
        judicial.garantias := listGarantias;
        judicial.itotaseg := v_itotaseg;
        judicial.itotpret := v_itotpret;


        listAudiencia := t_iax_sin_t_judicial_audien();
        audiencia := ob_iax_sin_t_judicial_audien();
        cur_audiencias := pac_iax_listvalores.f_opencursor(vsquery3, mensajes);
        LOOP
         FETCH cur_audiencias
            INTO audiencia.naudien ,audiencia.faudien ,audiencia.haudien ,audiencia.taudien ,audiencia.cdespa ,audiencia.tlaudie ,audiencia.caudien ,audiencia.cdespao ,audiencia.tlaudieo ,audiencia.caudieno ,audiencia.sabogau ,audiencia.coral ,audiencia.cestado ,audiencia.cresolu ,audiencia.finsta1 ,audiencia.finsta2 ,audiencia.fnueva ,audiencia.tresult ,audiencia.nnumideauden ,audiencia.nombreauden;
            IF cur_audiencias%FOUND THEN
              listAudiencia.EXTEND;
              listAudiencia(listAudiencia.LAST) := audiencia;
            END IF;
         EXIT WHEN cur_audiencias%NOTFOUND;
        END LOOP;

        CLOSE cur_audiencias;
        judicial.audiencias := listAudiencia;


        objudicial := judicial;

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
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
        vparam      VARCHAR2(2000) := ' - pnsinies   :'||  pnsinies    ||' - pntramit   :'||  pntramit    ||' - pnorden    :'||  pnorden     ||' - pcproceso  :'||  pcproceso   ||' - ptproceso  :'||  ptproceso   ||' - pcpostal   :'||  pcpostal    ||' - pcpoblac   :'||  pcpoblac    ||' - pcprovin   :'||  pcprovin    ||' - ptiexterno :'||  ptiexterno  ||' - psprofes   :'||  psprofes    ||' - pfrecep    :'||  pfrecep     ||' - pfnotifi   :'||  pfnotifi    ||' - pfvencimi  :'||  pfvencimi   ||' - pfrespues  :'||  pfrespues   ||' - pfconcil   :'||  pfconcil    ||' - pfdesvin   :'||  pfdesvin         ||' - pcconti   :'||  pcconti     ||' - pcdespa    :'||  pcdespa     ||' - pcdespao    :'||  pcdespao    ||
                                      ' - pcdescf   :'||  pcdescf    ||' - pcprovinf   :'||  pcprovinf    ||' - pcpoblacf   :'||  pcpoblacf    ||' - pcdesco   :'||  pcdesco    ||' - pcprovino   :'||  pcprovino    ||' - pcpoblaco   :'||  pcpoblaco    ||' - pcposici   :'||  pcposici    ||' - pcdemand   :'||  pcdemand    ||' - psapodera  :'||  psapodera   ||' - pidemand   :'||  pidemand    ||' - pftdeman   :'||  pftdeman    ||' - piconden   :'||  piconden    ||' - pcsenten   :'||  pcsenten    ||' - pfsente1   :'||  pfsente1    ||' - pcsenten2   :'||  pcsenten2    ||' - pfsente2   :'||  pfsente2    ||' - pcasacion   :'||  pcasacion    ||' - pfcasaci   :'||  pfcasaci    ||' - pctsente   :'||  pctsente    ||' - pftsente   :'||  pftsente    ||' - pvtsente   :'||  pvtsente   || ' coralproc:' || pcoralproc || ' unicainst:' || punicainst || ' funicainst:' || pfunicainst ;
        vpasexec    NUMBER(5) := 1;
        vobjectname VARCHAR2(100):= 'PAC_MD_SIN_TRAMITE.f_set_obj_judicial';
        vnumerr        NUMBER(8) := 1;
    BEGIN
    judicial  := OB_IAX_SIN_TRAMITA_JUDICIAL();
      judicial.nsinies     := pnsinies ;
      judicial.ntramit     := pntramit ;
      judicial.norden      := pnorden ;
      judicial.cproceso    := pcproceso;
      judicial.tproceso    := ptproceso;
      judicial.cpostal     := pcpostal ;
      judicial.cpoblac     := pcpoblac ;
      judicial.cprovin     := pcprovin ;
      judicial.tiexterno   := ptiexterno ;
      judicial.sprofes     := psprofes ;
      judicial.frecep      := pfrecep ;
      judicial.fnotifi     := pfnotifi ;
      judicial.fvencimi    := pfvencimi;
      judicial.frespues    := pfrespues;
      judicial.fconcil     := pfconcil ;
      judicial.fdesvin     := pfdesvin ;
      judicial.tpreten     := ptpreten ;
      judicial.texcep1     := ptexcep1 ;
      judicial.texcep2     := ptexcep2 ;
      judicial.cconti      := pcconti ;
      judicial.cdespa      := pcdespa ;
      judicial.cdescf      := pcdescf ;
      judicial.cprovinf    := pcprovinf ;
      judicial.cpoblacf    := pcpoblacf ;
      judicial.cdespao     := pcdespao ;
      judicial.cdesco      := pcdesco ;
      judicial.cprovino    := pcprovino ;
      judicial.cpoblaco    := pcpoblaco ;
      judicial.cposici     := pcposici ;
      judicial.cdemand     := pcdemand ;
      judicial.sapodera    := psapodera;
      judicial.idemand     := pidemand ;
      judicial.ftdeman     := pftdeman ;
      judicial.iconden     := piconden ;
      judicial.csenten     := pcsenten ;
      judicial.fsente1     := pfsente1 ;
      judicial.csenten2    := pcsenten2 ;
      judicial.fsente2     := pfsente2 ;
      judicial.casacion    := pcasacion ;
      judicial.fcasaci     := pfcasaci ;
      judicial.ctsente     := pctsente ;
      judicial.ftsente     := pftsente ;
      judicial.vtsente     := pvtsente ;
      judicial.tfallo      := ptfallo ;      
      judicial.coralproc     := pcoralproc ;
      judicial.unicainst     := punicainst ;
      judicial.funicainst      := pfunicainst ;

        vnumerr := pac_siniestros.f_ins_judicial(pnsinies  , pntramit  , pnorden  , pcproceso  , ptproceso  , pcpostal  , pcpoblac  , pcprovin  , ptiexterno  , psprofes  , pfrecep  , pfnotifi  , pfvencimi  , pfrespues  , pfconcil  , pfdesvin  , ptpreten  , ptexcep1  , ptexcep2 , pcconti , pcdespa, pcdescf, pcprovinf, pcpoblacf , pcdespao, pcdesco, pcprovino, pcpoblaco ,  pcposici  , pcdemand  , psapodera  , pidemand  , pftdeman  , piconden  , pcsenten  , pfsente1  , pcsenten2 , pfsente2  , pcasacion , pfcasaci , pctsente , pftsente , pvtsente , ptfallo,pcoralproc,punicainst,pfunicainst);
        IF vnumerr = 0 THEN
          COMMIT;
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
      END f_set_obj_judicial;

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
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
        vparam      VARCHAR2(2000) := ' - pnsinies   :'||  pnsinies    ||' - pntramit   :'||  pntramit    ||' - pnorden    :'||  pnorden    ||' - pnaudien    :'||  pnaudien    ||' - pfaudien   :'||  pfaudien    ||' - phaudien   :'||  phaudien    ||' - ptaudien   :'||  ptaudien     ||' - pcdespa    :'||  pcdespa     ||' - ptlaudie   :'||  ptlaudie    ||' - pcaudien   :'||  pcaudien    ||' - pcdespao   :'||  pcdespao    ||' - ptlaudieo  :'||  ptlaudieo   ||' - pcaudieno  :'||  pcaudieno   ||' - psabogau   :'||  psabogau    ||' - pcoral     :'||  pcoral||' - pcestado   :'||  pcestado    ||' - pcresolu   :'||  pcresolu    ||' - pfinsta1   :'||  pfinsta1    ||' - pfinsta2   :'||  pfinsta2    ||' - pfnueva    :'||  pfnueva     ||' - ptresult   :'||  ptresult;
        vpasexec    NUMBER(5) := 1;
        vobjectname VARCHAR2(100):= 'PAC_MD_TRAMITE.f_set_obj_judicial_audien';
        vnumerr        NUMBER(8) := 1;
        vhaudien_d DATE;
        vhaudien VARCHAR2(5);
        audiencia OB_IAX_SIN_T_JUDICIAL_AUDIEN;
    BEGIN
	  judicial  := OB_IAX_SIN_TRAMITA_JUDICIAL();
      audiencia  := OB_IAX_SIN_T_JUDICIAL_AUDIEN();
      audiencia.naudien      := pnaudien ;
      audiencia.faudien     := pfaudien ;
      audiencia.haudien     := phaudien ;
      audiencia.taudien     := ptaudien ;
      audiencia.cdespa      := pcdespa ;
      audiencia.tlaudie     := ptlaudie ;
      audiencia.caudien     := pcaudien ;
      audiencia.cdespao     := pcdespao ;
      audiencia.tlaudieo    := ptlaudieo ;
      audiencia.caudieno    := pcaudieno;
      audiencia.sabogau     := psabogau ;
      audiencia.coral       := pcoral ;
      audiencia.cestado     := pcestado ;
      audiencia.cresolu     := pcresolu ;
      audiencia.finsta1     := pfinsta1 ;
      audiencia.finsta2     := pfinsta2 ;
      audiencia.fnueva      := pfnueva ;
      audiencia.tresult     := ptresult ;
      judicial.audiencias.EXTEND;
      judicial.audiencias(judicial.audiencias.LAST) := audiencia;
      vhaudien := phaudien;
      IF phaudien is not null THEN
        BEGIN
         SELECT TO_DATE(phaudien, 'HH24:MI') into vhaudien_d from dual;
         vhaudien := TO_CHAR(vhaudien_d, 'HH24:MI');

        EXCEPTION
          WHEN OTHERS THEN
           pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000243 , vpasexec, vparam, NULL, 0, '');
           RETURN 1;
        END;
      END IF;

      vnumerr := pac_md_sin_tramite.f_valida_proceso_judicial(judicial, audiencia,pctramitad, mensajes );
      IF vnumerr = 0 THEN
        vnumerr := pac_siniestros.f_ins_judicial_audien(pnsinies ,pntramit ,pnorden, pnaudien, pfaudien ,phaudien ,ptaudien ,pcdespa ,ptlaudie ,pcaudien , pcdespao ,ptlaudieo, pcaudieno, psabogau ,pcoral ,pcestado ,pcresolu ,pfinsta1 ,pfinsta2 ,pfnueva ,ptresult);
        IF vnumerr = 0 THEN
          vnumerr := pac_md_sin_tramite.f_procesar_agenda_audiencia(pnsinies ,  pntramit,  pnorden ,  2 , pcaudien , PFAUDIEN  ,  PHAUDIEN, pctramitad ,   mensajes);
          COMMIT;
        END IF;
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
      END f_set_obj_judicial_audien;

  FUNCTION f_set_obj_judicial_valpret(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      pnorden IN NUMBER,
      pcgarant IN NUMBER,
      pipreten IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
        vparam      VARCHAR2(500) := 'pnsinies: ' || pnsinies || ' - pntramit: ' || pntramit|| ' - norden: '|| pnorden || ' - pcgarant:' || pcgarant|| ' - pipreten '|| pipreten;
        vpasexec    NUMBER(5) := 1;
        vobjectname VARCHAR2(100):= 'PAC_MD_SIN_TRAMITE.f_set_obj_judicial_valpret';
        vnumerr        NUMBER(8) := 1;
        vpretension ob_iax_sin_t_valpretension;

    BEGIN
      IF pnsinies IS NULL OR
         pntramit IS NULL OR
         pnorden IS NULL OR
         pcgarant IS NULL
         THEN
         RAISE e_param_error;
      END IF;
      vpasexec := 2;

        vnumerr := pac_siniestros.f_ins_obj_judicial_valpret(pnsinies, pntramit, pnorden, pcgarant, pipreten);
              vpasexec := 3;
        IF vnumerr = 0 THEN
              vpasexec := 4;
          COMMIT;
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
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
        vparam      VARCHAR2(2000) := 'pnsinies: ' || pnsinies || ' - pntramit: ' || pntramit|| ' - pnorden:'||pnorden||' - pnrol'||pnrol||' - pnpersona:'||pnpersona ||' - pntipper:'||pntipper ||' - pnnumide:'||pnnumide||' - ptnombre:'||ptnombre;
        vpasexec    NUMBER(5) := 1;
        vobjectname VARCHAR2(100):= 'PAC_MD_SIN_TRAMITE.f_set_obj_judicial_detper';
        vnumerr        NUMBER(8) := 1;
        vpersonas ob_iax_sin_t_judicial_detper;
    BEGIN

        judicial  := OB_IAX_SIN_TRAMITA_JUDICIAL();
        vpersonas := ob_iax_sin_t_judicial_detper();
        vpersonas.nrol := pnrol;
        vpersonas.npersona := pnpersona;
        vpersonas.ntipper  := pntipper ;
        vpersonas.nnumide := pnnumide;
        --vpersonas.tnombre := ptnombre;
        judicial.personas.EXTEND;
        judicial.personas(judicial.personas.LAST) := vpersonas;
        vnumerr := pac_siniestros.f_ins_judicial_detper(pnsinies , pntramit , pnorden , pnrol  , pnpersona, pntipper , pnnumide , ptnombre, piimporte);
        IF vnumerr = 0 THEN
          COMMIT;
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
      END f_set_obj_judicial_detper;

  FUNCTION f_traspasar_judicial(
      proceso  IN OB_IAX_SIN_TRAMITA_JUDICIAL,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
        vparam      VARCHAR2(500) := ' ';
        vpasexec    NUMBER(5) := 1;
        vobjectname VARCHAR2(100):= 'PAC_MD_SIN_TRAMITE.f_traspasar_judicial';
        vnumerr        NUMBER(8) := 1;
    BEGIN
    NULL;
      --numerr := pac_siniestrs.f_set_obj_judicial(pnsinies ,pntramit ,pnorden ,pcproceso,ptproceso,pcpostal ,pcpoblac ,pcprovin ,ptiexterno,psprofes ,pfrecep ,pfnotifi ,pfvencimi,pfrespues,pfconcil ,pfdesvin ,ptpreten ,ptexcep1 ,ptexcep2 ,pfaudien ,phaudien ,ptaudien ,pcconti ,pcdespa ,ptlaudie ,pcaudien ,pcdespao ,ptlaudieo,pcaudieno,psabogau ,pcoral ,pcestado ,pcresolu ,pfinsta1 ,pfinsta2 ,pfnueva ,ptresult ,pcposici ,pcdemand ,psapodera,pidemand ,pftdeman ,piconden ,pcsenten ,pfsente1 ,pfsente2 ,pctsente ,ptfallo ,mensajes);      RETURN 0;
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
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
        vparam      VARCHAR2(500) := ' ';
        vpasexec    NUMBER(5) := 1;
        vobjectname VARCHAR2(100):= 'PAC_MD_SIN_TRAMITE.f_validar_judicial';
        vnumerr        NUMBER(8) := 1;
      BEGIN
      NULL;
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
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
        vparam      VARCHAR2(500) := ' ';
        vpasexec    NUMBER(5) := 1;
        vobjectname VARCHAR2(100):= 'PAC_MD_SIN_TRAMITE.f_elimina_dato_judicial';
        vnumerr        NUMBER(8) := 1;
      BEGIN
     IF pnsinies IS NULL OR
         pntramit IS NULL  OR
         pnorden IS NULL OR
         pctipo IS NULL THEN
         RAISE e_param_error;
      END IF;
      vnumerr := pac_siniestros.f_elimina_dato_judicial(pctipo, pnsinies, pntramit, pnorden, pnvalor);
      IF vnumerr = 0 THEN
        COMMIT;
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
      END f_elimina_dato_judicial;
 FUNCTION f_get_procesos_fiscales(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN SYS_REFCURSOR IS
        vparam      VARCHAR2(500) := 'pnsinies: ' || pnsinies || ' - pntramit: ' || pntramit;
        vpasexec    NUMBER(5) := 1;
        vobjectname VARCHAR2(100):= 'PAC_MD_SIN_TRAMITE.f_get_procesos_fiscales';
        vnumerr        NUMBER(8) := 1;
        vquery VARCHAR2(10000) := '';
        cur sys_refcursor;
    BEGIN

      IF pnsinies IS NULL OR
         pntramit IS NULL THEN
         RAISE e_param_error;
      END IF;
      vquery := 'SELECT UNIQUE t.norden, m.nradica, t.fnotifi, t.faudien, t.haudien, t.FAPERTU, ' ||
                ' ( SELECT p.tpoblac FROM poblaciones p, codpostal c WHERE p.cprovin = c.cprovin AND p.cpoblac = c.cpoblac AND c.cpostal = t.caudien ) tpoblac ' ||
                '  FROM sin_tramita_fiscal   t,   ' ||
                '       sin_tramitacion m  ' ||
                ' WHERE t.nsinies = m.nsinies ' ||
                '   AND t.ntramit = m.ntramit ' ||
                '   AND t.nsinies = ''' || pnsinies || '''' ||
                '   AND t.ntramit = ' || pntramit;
      cur := pac_iax_listvalores.f_opencursor(vquery, mensajes);
      RETURN cur;
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
         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      END f_get_procesos_fiscales;
  FUNCTION f_get_obj_fiscal(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      pnorden IN NUMBER,
      objfiscal OUT OB_IAX_SIN_TRAMITA_FISCAL,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
        vparam      VARCHAR2(500) := 'pnsinies: ' || pnsinies || ' - pntramit: ' || pntramit|| ' - pnorden: '|| pnorden;
        vpasexec    NUMBER(5) := 1;
        vobjectname VARCHAR2(100):= 'PAC_MD_SIN_TRAMITE.f_get_obj_fiscal';
        vnumerr        NUMBER(8) := 1;
        listGarantias t_iax_sin_t_valpretension;
        garantia ob_iax_sin_t_valpretension;
        vsquery VARCHAR2(2000):='SELECT p.nsinies ,p.ntramit, p.norden ,p.fapertu  ,p.fimputa  ,p.fnotifi  ,p.faudien  ,p.haudien  ,p.caudien  ,p.sprofes  ,p.coterri  ,p.cprovin  ,p.ccontra  ,p.cuespec  ,p.tcontra  ,p.ctiptra  ,p.testado  ,p.cmedio   ,p.fdescar  ,p.ffallo   ,p.cfallo   ,p.tfallo   ,p.crecurso, ' ||
                  ' pac_isqlfor.f_dni(null, null, (select sperson from sin_prof_profesionales where sprofes = p.sprofes) ) NNUMIDEPROFES , ' ||
                  ' f_nombre((select sperson from sin_prof_profesionales where sprofes = p.sprofes),3) NOMBREPROFES ' ||
                  '  FROM sin_tramita_fiscal p ' ||
                  ' WHERE p.nsinies = ' || pnsinies   ||
                  '   AND p.ntramit = ' || pntramit  ||
                  '   AND p.norden = ' || pnorden ||
                  ' ORDER BY p.norden ';
        cur            sys_refcursor;

         vsquery2 VARCHAR2(2000):=' SELECT p.cgarant , gg.tgarant, ' ||
                                        ' (SELECT pac_monedas.f_cmoneda_t(p.cdivisa)  FROM productos p, seguros s ' ||
                                        ' WHERE  s.sseguro = seg.sseguro   AND p.sproduc = s.sproduc ) CMONEDA , ' ||
                                            'g.icaptot  ,p.ipreten    ' ||
                                  ' FROM sin_tramita_valpretfiscal p, sin_siniestro sin, seguros seg, garanseg g, garangen gg  ' ||
                                  ' WHERE p.nsinies = ' || pnsinies   ||
                                  '   AND p.ntramit = ' || pntramit  ||
                                  '   AND p.norden = ' || pnorden ||
                                  '   AND sin.nsinies = p.nsinies  ' ||
                                  '   AND sin.sseguro = seg.sseguro  ' ||
                                  '   AND g.cgarant = p.cgarant  ' ||
                                  '  AND g.sseguro = sin.sseguro  ' ||
                                  '  AND gg.cgarant = p.cgarant ' ||
								  '  AND g.ffinefe IS NULL ' ||
                                  '  AND gg.cidioma = pac_md_common.f_get_cxtidioma  ' ||
                                  ' ORDER BY p.cgarant ';

       cur_garantias         sys_refcursor;
       v_itotaseg NUMBER(19,2) := 0;
       v_itotpret NUMBER(19,2) := 0;
    BEGIN
        objfiscal := ob_iax_sin_tramita_fiscal();
        vpasexec := 2;
        cur := pac_iax_listvalores.f_opencursor(vsquery, mensajes);
        vpasexec := 3;
        LOOP
         FETCH cur
          INTO objfiscal.nsinies ,objfiscal.ntramit, objfiscal.norden ,objfiscal.fapertu  ,objfiscal.fimputa  ,objfiscal.fnotifi  ,objfiscal.faudien  ,objfiscal.haudien  ,objfiscal.caudien  ,objfiscal.sprofes  ,objfiscal.coterri  ,objfiscal.cprovin  ,objfiscal.ccontra  ,objfiscal.cuespec  ,objfiscal.tcontra  ,objfiscal.ctiptra  ,objfiscal.testado  ,objfiscal.cmedio   ,objfiscal.fdescar  ,objfiscal.ffallo   ,objfiscal.cfallo   ,objfiscal.tfallo   ,objfiscal.crecurso,objfiscal.nnumideprofes,objfiscal.nombreprofes ;

         EXIT WHEN cur%NOTFOUND;
        END LOOP;

        CLOSE cur;

        fiscal := objfiscal;
        vpasexec := 5;
        listGarantias := t_iax_sin_t_valpretension();
        garantia := ob_iax_sin_t_valpretension();
        cur_garantias := pac_iax_listvalores.f_opencursor(vsquery2, mensajes);
        vpasexec := 6;
        LOOP
         FETCH cur_garantias
          INTO garantia.cgarant, garantia.tgarant, garantia.cmoneda ,garantia.icapital  ,garantia.ipreten;
            IF cur_garantias%FOUND THEN
            vpasexec := 7;
              listGarantias.EXTEND;
              listGarantias(listGarantias.LAST) := garantia;
              v_itotaseg := v_itotaseg + garantia.icapital;
              v_itotpret := v_itotpret + garantia.ipreten;
              vpasexec := 8;
            END IF;
         EXIT WHEN cur_garantias%NOTFOUND;
        END LOOP;

        CLOSE cur_garantias;
        fiscal.garantias := listGarantias;
        fiscal.itotaseg := v_itotaseg;
        fiscal.itotpret := v_itotpret;

      objfiscal := fiscal;

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
      mensajes IN   OUT t_iax_mensajes)
      RETURN NUMBER IS
        vparam      VARCHAR2(2000) :=     '  pnsinies   =' || pnsinies  ||    '  pntramit   =' || pntramit  ||    '  pnorden    =' || pnorden   ||    '  pfapertu   =' || pfapertu  ||    '  pfimputa   =' || pfimputa  ||    '  pfnotifi   =' || pfnotifi  ||    '  pfaudien   =' || pfaudien  ||    '  phaudien   =' || phaudien  ||    '  pcaudien   =' || pcaudien  ||    '  psprofes   =' || psprofes  ||    '  pcoterri   =' || pcoterri  ||    '  pccontra   =' || pccontra  ||
                                          '  pcprovin   =' || pcprovin  ||    '  pcuespec   =' || pcuespec  ||    '  ptcontra   =' || ptcontra  ||    '  pctiptra   =' || pctiptra  ||    '  ptestado   =' || ptestado  ||    '  pcmedio    =' || pcmedio   ||    '  pfdescar   =' || pfdescar  ||    '  pffallo    =' || pffallo   ||    '  pcfallo    =' || pcfallo   ||        '  pcrecurso  =' || pcrecurso;        vpasexec    NUMBER(5) := 1;
        vobjectname VARCHAR2(100):= 'PAC_MD_SIN_TRAMITE.f_set_obj_fiscal';
        vnumerr        NUMBER(8) := 0;
        vhaudien_d DATE;
        vhaudien VARCHAR2(5);
    BEGIN
      fiscal  := OB_IAX_SIN_TRAMITA_FISCAL();
      fiscal.nsinies   := pnsinies ;
      fiscal.ntramit   := pntramit ;
      fiscal.norden    := pnorden  ;
      fiscal.fapertu   := pfapertu ;
      fiscal.fimputa   := pfimputa ;
      fiscal.fnotifi   := pfnotifi ;
      fiscal.faudien   := pfaudien ;
      fiscal.haudien   := phaudien ;
      fiscal.caudien   := pcaudien ;
      fiscal.sprofes   := psprofes ;
      fiscal.coterri   := pcoterri ;
      fiscal.cprovin   := pcprovin ;
      fiscal.ccontra   := pccontra ;
      fiscal.cuespec   := pcuespec ;
      fiscal.tcontra   := ptcontra ;
      fiscal.ctiptra   := pctiptra ;
      fiscal.testado   := ptestado ;
      fiscal.cmedio    := pcmedio  ;
      fiscal.fdescar   := pfdescar ;
      fiscal.ffallo    := pffallo  ;
      fiscal.cfallo    := pcfallo  ;
      fiscal.tfallo    := ptfallo  ;
      fiscal.crecurso  := pcrecurso;
      vhaudien := phaudien;
      IF phaudien is not null THEN
      BEGIN
       SELECT TO_DATE(phaudien, 'HH24:MI') into vhaudien_d from dual;
       vhaudien := TO_CHAR(vhaudien_d, 'HH24:MI');

      EXCEPTION
        WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000243 , vpasexec, vparam,
                                           NULL, 0, '');
         RETURN 1;

      END;

      END IF;

      vnumerr := pac_md_sin_tramite.f_valida_proceso_fiscal(fiscal,pctramitad, mensajes );


      IF vnumerr = 0 THEN
        vnumerr := pac_siniestros.f_ins_fiscal(pnsinies ,pntramit ,pnorden  ,pfapertu ,pfimputa ,pfnotifi ,pfaudien ,vhaudien ,pcaudien ,psprofes ,pcoterri ,pcprovin, pccontra ,pcuespec ,ptcontra ,pctiptra ,ptestado ,pcmedio  ,pfdescar ,pffallo  ,pcfallo  ,ptfallo  ,pcrecurso);
        IF vnumerr = 0 THEN
          vnumerr := pac_md_sin_tramite.f_procesar_agenda_audiencia(pnsinies ,  pntramit,  pnorden ,  1 , PCAUDIEN , PFAUDIEN  ,  PHAUDIEN, pctramitad ,   mensajes);
          COMMIT;
        END IF;
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
      END f_set_obj_fiscal;
  FUNCTION f_set_obj_fiscal_valpret(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      pnorden IN NUMBER,
      pcgarant IN NUMBER,
      pipreten IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
        vparam      VARCHAR2(500) := 'pnsinies: ' || pnsinies || ' - pntramit: ' || pntramit|| ' - norden: '|| pnorden || ' - pcgarant:' || pcgarant|| ' - pipreten '|| pipreten;
        vpasexec    NUMBER(5) := 1;
        vobjectname VARCHAR2(100):= 'PAC_MD_SIN_TRAMITE.f_set_obj_fiscal_valpret';
        vnumerr        NUMBER(8) := 1;
        vpretension ob_iax_sin_t_valpretension;

    BEGIN
      IF pnsinies IS NULL OR
         pntramit IS NULL OR
         pnorden IS NULL OR
         pcgarant IS NULL
         THEN
         RAISE e_param_error;
      END IF;
      vpasexec := 2;

        vnumerr := pac_siniestros.f_ins_fiscal_valpret(pnsinies, pntramit, pnorden, pcgarant, pipreten);
              vpasexec := 3;
        IF vnumerr = 0 THEN
              vpasexec := 4;
          COMMIT;
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
      END f_set_obj_fiscal_valpret;
  FUNCTION f_elimina_dato_fiscal(
      pctipo IN NUMBER,
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      pnorden IN NUMBER,
      pnvalor IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
        vparam      VARCHAR2(500) := ' ';
        vpasexec    NUMBER(5) := 1;
        vobjectname VARCHAR2(100):= 'PAC_MD_SIN_TRAMITE.f_elimina_dato_fiscal';
        vnumerr        NUMBER(8) := 1;
      BEGIN
     IF pnsinies IS NULL OR
         pntramit IS NULL  OR
         pnorden IS NULL OR
         pctipo IS NULL THEN
         RAISE e_param_error;
      END IF;
      vnumerr := pac_siniestros.f_elimina_dato_fiscal(pctipo, pnsinies, pntramit, pnorden, pnvalor);
      IF vnumerr = 0 THEN
        COMMIT;
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
      END f_elimina_dato_fiscal;


 FUNCTION f_get_tramite_judicial_audien(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      pnorden IN NUMBER,
      pnaudien IN NUMBER,
      audiencia OUT OB_IAX_SIN_T_JUDICIAL_AUDIEN,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
        vparam      VARCHAR2(500) := 'pnsinies: ' || pnsinies || ' - pntramit: ' || pntramit || ' - pnorden: ' || pnorden || ' - pnaudien: ' || pnaudien;
        vpasexec    NUMBER(5) := 1;
        vobjectname VARCHAR2(100):= 'PAC_MD_SIN_TRAMITE.f_get_tramite_judicial_audien';
        vnumerr        NUMBER(8) := 1;

        vsquery VARCHAR2(2000):='SELECT p.faudien ,p.haudien ,p.taudien  ,p.cdespa  ,p.tlaudie ,p.caudien ,p.cdespao ,p.tlaudieo,p.caudieno,p.sabogau , ' ||
                  ' p.coral   ,p.cestado ,p.cresolu ,p.finsta1 ,p.finsta2 ,p.fnueva  ,p.tresult, pac_isqlfor.f_dni(null, null, p.SABOGAU) NNUMIDEAUDEN, f_nombre(p.SABOGAU,3) NOMBREAUDEN ' ||
                  '  FROM sin_tramita_judicial_audien p ' ||
                  ' WHERE p.nsinies = ' || pnsinies   ||
                  '   AND p.ntramit = ' || pntramit  ||
                  '   AND p.norden = ' || pnorden ||
                  '   AND p.naudien = ' || pnaudien ||
                  ' ORDER BY p.naudien ';



        cur sys_refcursor;
      BEGIN
        audiencia := ob_iax_sin_t_judicial_audien();
        vpasexec := 2;
        cur := pac_iax_listvalores.f_opencursor(vsquery, mensajes);
        vpasexec := 3;
        LOOP
         FETCH cur
          INTO audiencia.faudien ,audiencia.haudien ,audiencia.taudien ,audiencia.cdespa ,audiencia.tlaudie ,audiencia.caudien ,audiencia.cdespao ,audiencia.tlaudieo ,audiencia.caudieno ,audiencia.sabogau ,audiencia.coral ,audiencia.cestado ,audiencia.cresolu ,audiencia.finsta1 ,audiencia.finsta2 ,audiencia.fnueva ,audiencia.tresult ,audiencia.nnumideauden ,audiencia.nombreauden;

         EXIT WHEN cur%NOTFOUND;
        END LOOP;

        CLOSE cur;

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

  END f_get_tramite_judicial_audien;

  FUNCTION f_procesar_agenda_audiencia(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      pnorden IN NUMBER,
      pctipo IN NUMBER,
      PCAUDIEN IN NUMBER,
      PFAUDIEN  IN	DATE,
      PHAUDIEN  IN	VARCHAR2,
      pctramitad IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
        vpasexec    NUMBER(5) := 1;
        vobjectname VARCHAR2(100):= 'PAC_MD_SIN_TRAMITE.f_procesar_agenda_audiencia';
        vnumerr        NUMBER(8) := 0;
        vidapunte NUMBER;
        vpoblacion VARCHAR2(1000) := '';
        vradicado varchar2(2000) := '';
        vusuario VARCHAR2(100) := '';
        v_ttipo VARCHAR2(2000) := '';
        vparam VARCHAR(1000) := ' pnsinies =' || pnsinies || ' pntramit =' || pntramit || ' pnorden = '||pnorden || ' pctipo = ' || pctipo || ' PCAUDIEN = '|| PCAUDIEN || ' PFAUDIEN = ' || PFAUDIEN || ' PHAUDIEN = '|| PHAUDIEN || ' pctramitad = ' ||pctramitad;
      BEGIN
      IF PCAUDIEN IS NOT NULL OR
         PFAUDIEN IS NOT NULL  OR
         PHAUDIEN IS NULL THEN

         IF PCAUDIEN IS NOT NULL THEN
           SELECT p.tpoblac
             INTO vpoblacion
           FROM poblaciones p, codpostal c
           WHERE p.cprovin = c.cprovin
             AND p.cpoblac = c.cpoblac
             AND c.cpostal = pcaudien
             AND rownum = 1;
         END IF;

         SELECT nradica
           INTO vradicado
           FROM sin_tramitacion
          WHERE nsinies = pnsinies
            AND ntramit = pntramit;

         SELECT cusuari
           INTO vusuario
           FROM sin_codtramitador
          WHERE ctramitad = pctramitad;
          IF pctipo = 1 THEN
            v_ttipo := f_axis_literales(9909648, pac_md_common.f_get_cxtidioma );
          ELSIF pctipo = 2 THEN

            v_ttipo := f_axis_literales(9909218, pac_md_common.f_get_cxtidioma );
          END IF;
           vnumerr :=
               pac_agenda.f_set_apunte(NULL, NULL, 0, pnsinies, 0, 0, 0, NULL,
                                       f_axis_literales(9909637, pac_md_common.f_get_cxtidioma) ||  ' ' || PFAUDIEN || ' - ' || PHAUDIEN || ' - ' || vpoblacion,
                                       f_axis_literales(101298, pac_md_common.f_get_cxtidioma )
                                       || ' : '
                                       || pnsinies || ' ' || f_axis_literales(9001028, pac_md_common.f_get_cxtidioma )  || ' '
                                       || v_ttipo
                                       || ' - ' || vradicado || '  '
                                       || f_axis_literales(9909639, pac_md_common.f_get_cxtidioma) || ' ' || PFAUDIEN || ' - ' || PHAUDIEN || ' - ' || vpoblacion,
                                       0, 0, NULL, NULL, f_user, NULL, f_sysdate, f_sysdate,
                                       NULL, vidapunte);
            vnumerr :=
               pac_agenda.f_set_agenda(vidapunte, NULL, vusuario, 0,
                                       NULL,
                                       0, pnsinies, NULL);




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
      END f_procesar_agenda_audiencia;

  FUNCTION f_valida_proceso_fiscal(
      pproceso ob_iax_sin_tramita_fiscal,
      pctramitad IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
   vobjectname VARCHAR2(500) := 'PAC_MD_SIN_TRAMITE.f_valida_proceso_fiscal';
   vparam      VARCHAR2(500) := '';
   vpasexec    NUMBER(5) := 1;
   vnumerr     NUMBER;
   v_count     NUMBER;
   v_coount    NUMBER;
   v_error     VARCHAR2(2000);
   v_hlimit NUMBER := 2;
   v_haudien VARCHAR2(5);
   v_tpoblac VARCHAR2(2000);
   vsproduc NUMBER;
   --
BEGIN
   --
   IF pctramitad IS NOT NULL AND
      pproceso.faudien IS NOT NULL AND
      pproceso.caudien IS NOT NULL
   THEN


      SELECT s.sproduc
        INTO vsproduc
        FROM sin_siniestro sin, seguros s
       WHERE nsinies = '20168010000'
         AND sin.sseguro = s.sseguro
         AND rownum = 1;

      v_hlimit := NVL(pac_parametros.f_parproducto_n(vsproduc, 'SIN_HORAS_FISCAL'), 1);
      --
      --Abogado con audiencias en otras ciudades en la misma fecha
       SELECT COUNT(*)
        INTO v_count
        FROM SIN_TRAMITA_FISCAL f, sin_tramita_movimiento t
       WHERE f.caudien != pproceso.caudien
         AND trunc(f.faudien) = trunc(pproceso.faudien)
         AND t.ctramitad = pctramitad
         AND f.nsinies = t.nsinies
         AND f.ntramit = t.ntramit
         AND f.nsinies || f.ntramit || f.norden != pproceso.nsinies || pproceso.ntramit || pproceso.norden
         AND t.nmovtra = (select max(nmovtra) from sin_tramita_movimiento where nsinies = f.nsinies AND ntramit = f.ntramit);
      IF v_count != 0
         THEN
            --9909652
      SELECT ( SELECT p.tpoblac FROM poblaciones p, codpostal c WHERE p.cprovin = c.cprovin AND p.cpoblac = c.cpoblac AND c.cpostal = f.caudien ) tpoblac
        INTO v_tpoblac
        FROM SIN_TRAMITA_FISCAL f, sin_tramita_movimiento t
       WHERE f.caudien != pproceso.caudien
         AND trunc(f.faudien) = trunc(pproceso.faudien)
         AND t.ctramitad = pctramitad
         AND f.nsinies = t.nsinies
         AND f.ntramit = t.ntramit
         AND f.nsinies || f.ntramit || f.norden != pproceso.nsinies || pproceso.ntramit || pproceso.norden
         AND t.nmovtra = (select max(nmovtra) from sin_tramita_movimiento where nsinies = f.nsinies AND ntramit = f.ntramit)
         AND rownum = 1;
            v_error:= f_axis_literales(9909652, pac_md_common.f_get_cxtidioma ) || ' ' || pproceso.FAUDIEN || ' en ' || v_tpoblac;
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, NULL, v_error);
            RETURN 1;
            --
      END IF;
      --
      --Abogado con audiencias en misma ciudades en la misma fecha con diferencia de menos de dos horas
      IF pproceso.haudien IS NOT NULL
      THEN
       SELECT COUNT(*)
        INTO v_coount
        FROM SIN_TRAMITA_FISCAL f, sin_tramita_movimiento t
       WHERE f.caudien = pproceso.caudien
         AND trunc(f.faudien) = trunc(pproceso.faudien)
         AND t.ctramitad = pctramitad
         AND f.nsinies = t.nsinies
         AND f.ntramit = t.ntramit
         AND f.nsinies || f.ntramit || f.norden != pproceso.nsinies || pproceso.ntramit || pproceso.norden
         AND t.nmovtra = (select max(nmovtra) from sin_tramita_movimiento where nsinies = f.nsinies AND ntramit = f.ntramit)
         AND (TO_DATE(haudien, 'HH24:MI')) between  (TO_DATE(pproceso.haudien, 'HH24:MI')- NVL(v_hlimit,1)/24) and (TO_DATE(pproceso.haudien, 'HH24:MI')+ NVL(v_hlimit,1)/24);
         --
         IF v_coount != 0
            THEN
              SELECT haudien
              INTO v_haudien
              FROM SIN_TRAMITA_FISCAL f, sin_tramita_movimiento t
             WHERE f.caudien = pproceso.caudien
               AND trunc(f.faudien) = trunc(pproceso.faudien)
               AND t.ctramitad = pctramitad
               AND f.nsinies = t.nsinies
               AND f.ntramit = t.ntramit
               AND f.nsinies || f.ntramit || f.norden != pproceso.nsinies || pproceso.ntramit || pproceso.norden
               AND t.nmovtra = (select max(nmovtra) from sin_tramita_movimiento where nsinies = f.nsinies AND ntramit = f.ntramit)
               AND rownum =1;

               v_error:= f_axis_literales(9909652, pac_md_common.f_get_cxtidioma ) || ' ' || pproceso.FAUDIEN || ' a las ' || v_haudien;
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, NULL, v_error);
               RETURN 1;
               --
         END IF;
      END IF;
   END IF;

   RETURN 0;
  END f_valida_proceso_fiscal;
  FUNCTION f_valida_proceso_judicial(
      pproceso ob_iax_sin_tramita_judicial,
      paudiencia ob_iax_sin_t_judicial_audien,
      pctramitad IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
   vobjectname VARCHAR2(500) := 'PAC_MD_SIN_TRAMITE.f_valida_proceso_judicial';
   vparam      VARCHAR2(500) := 'pctramitad = '|| pctramitad || ' paudiencia.faudien= ' || paudiencia.faudien || ' paudiencia.caudien= ' ||paudiencia.caudien;
   vpasexec    NUMBER(5) := 1;
   vnumerr     NUMBER;
   v_count     NUMBER;
   v_coount    NUMBER;
   v_error     VARCHAR2(2000);
   v_hlimit NUMBER := 2;
   v_haudien VARCHAR2(5);
   v_tpoblac VARCHAR2(2000);
   vsproduc NUMBER;
   --
BEGIN
   --
   IF pctramitad IS NOT NULL AND
      paudiencia.faudien IS NOT NULL AND
      paudiencia.caudien IS NOT NULL
   THEN
       p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     SQLCODE || ' - ' || SQLERRM);

      SELECT s.sproduc
        INTO vsproduc
        FROM sin_siniestro sin, seguros s
       WHERE nsinies = '20168010000'
         AND sin.sseguro = s.sseguro
         AND rownum = 1;

      v_hlimit := NVL(pac_parametros.f_parproducto_n(vsproduc, 'SIN_HORAS_JUDICIAL'), 1);
      --
      --Abogado con audiencias en otras ciudades en la misma fecha
       SELECT COUNT(*)
        INTO v_count
        FROM SIN_TRAMITA_JUDICIAL f, sin_tramita_movimiento t
       WHERE
         EXISTS (SELECT NULL FROM SIN_TRAMITA_JUDICIAL_AUDIEN a
                 WHERE f.nsinies = a.nsinies AND f.ntramit = a.ntramit AND f.norden = a.norden AND trunc(a.faudien) = trunc(paudiencia.faudien) AND a.caudien != paudiencia.caudien
                )
         AND t.ctramitad = pctramitad
         AND f.nsinies = t.nsinies
         AND f.ntramit = t.ntramit
         AND f.nsinies || f.ntramit || f.norden != pproceso.nsinies || pproceso.ntramit || pproceso.norden
         AND t.nmovtra = (select max(nmovtra) from sin_tramita_movimiento where nsinies = f.nsinies AND ntramit = f.ntramit);
      IF v_count != 0
         THEN
            --9909652
            SELECT ( SELECT p.tpoblac FROM poblaciones p, codpostal c WHERE p.cprovin = c.cprovin AND p.cpoblac = c.cpoblac AND c.cpostal = a.caudien ) tpoblac
            INTO v_tpoblac
            FROM SIN_TRAMITA_JUDICIAL f, sin_tramita_movimiento t, SIN_TRAMITA_JUDICIAL_AUDIEN a
            WHERE trunc(a.faudien) = trunc(paudiencia.faudien)
              AND a.caudien != paudiencia.caudien
              AND f.nsinies = a.nsinies
              AND f.ntramit = a.ntramit
              AND f.norden = a.norden
              AND t.ctramitad = pctramitad
              AND f.nsinies = t.nsinies
              AND f.ntramit = t.ntramit
              AND f.nsinies || f.ntramit || f.norden != pproceso.nsinies || pproceso.ntramit || pproceso.norden
              AND t.nmovtra = (select max(nmovtra) from sin_tramita_movimiento where nsinies = f.nsinies AND ntramit = f.ntramit)
              AND rownum = 1;

            v_error:= f_axis_literales(9909652, pac_md_common.f_get_cxtidioma ) || ' ' || paudiencia.FAUDIEN || ' en ' || v_tpoblac;
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, NULL, v_error);
            RETURN 1;
            --
      END IF;
      --
      --Abogado con audiencias en misma ciudades en la misma fecha con diferencia de menos de dos horas
      IF paudiencia.haudien IS NOT NULL THEN

        SELECT COUNT(*)
        INTO v_coount
        FROM SIN_TRAMITA_JUDICIAL f, sin_tramita_movimiento t
        WHERE
          EXISTS (SELECT NULL FROM SIN_TRAMITA_JUDICIAL_AUDIEN a
                  WHERE f.nsinies = a.nsinies AND f.ntramit = a.ntramit AND f.norden = a.norden AND trunc(a.faudien) = trunc(paudiencia.faudien) AND a.caudien = paudiencia.caudien
                    AND (TO_DATE(a.haudien, 'HH24:MI')) between  (TO_DATE(paudiencia.haudien, 'HH24:MI')- NVL(v_hlimit,1)/24) and (TO_DATE(paudiencia.haudien, 'HH24:MI')+ NVL(v_hlimit,1)/24)
                 )
          AND t.ctramitad = pctramitad
          AND f.nsinies = t.nsinies
          AND f.ntramit = t.ntramit
          AND f.nsinies || f.ntramit || f.norden != pproceso.nsinies || pproceso.ntramit || pproceso.norden
          AND t.nmovtra = (select max(nmovtra) from sin_tramita_movimiento where nsinies = f.nsinies AND ntramit = f.ntramit);

        IF v_coount != 0 THEN
           SELECT a.haudien
           INTO v_haudien
           FROM SIN_TRAMITA_JUDICIAL f, sin_tramita_movimiento t, SIN_TRAMITA_JUDICIAL_AUDIEN a
           WHERE trunc(a.faudien) = trunc(paudiencia.faudien)
             AND a.caudien = paudiencia.caudien
             AND f.ntramit = a.ntramit
             AND f.norden = a.norden
             AND f.nsinies = a.nsinies
             AND t.ctramitad = pctramitad
             AND f.nsinies = t.nsinies
             AND f.ntramit = t.ntramit
             AND f.nsinies || f.ntramit || f.norden != pproceso.nsinies || pproceso.ntramit || pproceso.norden
             AND t.nmovtra = (select max(nmovtra) from sin_tramita_movimiento where nsinies = f.nsinies AND ntramit = f.ntramit)
             AND rownum =1;

             v_error:= f_axis_literales(9909652, pac_md_common.f_get_cxtidioma ) || ' ' || paudiencia.FAUDIEN || ' a las ' || v_haudien;
             pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, NULL, v_error);

             RETURN 1;

         END IF;
      END IF;
   END IF;

   RETURN 0;
  END f_valida_proceso_judicial;
END pac_md_sin_tramite;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_SIN_TRAMITE" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_SIN_TRAMITE" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_SIN_TRAMITE" TO "PROGRAMADORESCSI";
