--------------------------------------------------------
--  DDL for Package Body PAC_IAX_SUSPENSION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IAX_SUSPENSION" AS
/******************************************************************************
   NOMBRE:    PAC_IAX_SUSPENSION
   PROP¿¿SITO: Funciones para la suspensi¿n/reinicio de p¿lizas

   REVISIONES:
   Ver        Fecha        Autor             Descripci¿¿n
   ---------  ----------  ---------------  ------------------------------------
   1.0        14/11/2012   FAL                1. Creaci¿¿n del package (Bug 0024450)
   2.0        10/12/2013   DCT                2. 0029229 LCOL_T010-LCOL - Revision incidencias Suspensi¿n / Reinicio (VIII).
******************************************************************************/

   /*************************************************************************
      Funcion que realiza la insercion de los movimientos suspensi¿n/reinicio de polizas
      param in psseguro : id. de la poliza
      param in pcmotmov : codigo motivo movimiento
      param in pfmovini : fecha inicio movimiento
      param in pfrenova : fecha nueva vigencia en reinicios
      param in pttexto  : descripcion del movimiento de suspensi¿n/reinicio
      param in pttexto2 : descripcion del movimiento de debloqueo/despignoarcion
      return            : Error
   *************************************************************************/
   FUNCTION f_set_mov(
      psseguro IN NUMBER,
      ptmotmov IN VARCHAR2,
      pfmovini IN DATE,
      pfrenova IN DATE,
      pttexto IN VARCHAR2,
      pttexto2 IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(2000)
         := 'psseguro=' || psseguro || ' ptmotmov=' || ptmotmov || 'pfmovini=' || pfmovini
            || ' pfrenova=' || pfrenova || 'pttexto=' || SUBSTR(pttexto, 1, 400)
            || ' pttexto2=' || SUBSTR(pttexto2, 1, 400);
      vobject        VARCHAR2(2000) := 'PAC_IAX_SUSPENSION.F_SET_MOV';
      squery         VARCHAR2(5000);
      vnumerr        NUMBER := 0;
      vcmotmov       NUMBER;
      v_haypendiente NUMBER;
      v_produce_req  NUMBER;
      v_emitir       NUMBER := 0;
      v_nmovimi      NUMBER;
   BEGIN
      -- Validem si hi ha documentacio requerida pendent
      v_haypendiente :=
         pac_md_docrequerida.f_aviso_docreq_pendiente
                                        (pac_iax_produccion.poliza.det_poliza.sseguro,
                                         pac_iax_produccion.poliza.det_poliza.nmovimi,
                                         pac_iax_produccion.poliza.det_poliza.sproduc,
                                         pac_iax_produccion.poliza.det_poliza.gestion.cactivi,
                                         mensajes);
      v_produce_req := NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa,
                                                         'PRODUCE_REQUERIDA'),
                           0);

      IF v_haypendiente <> 0
         AND v_produce_req <> 0 THEN
         IF v_produce_req IN(1, 2) THEN
            -- Error
            v_emitir := 2;
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9902065);
            RAISE e_object_error;
         END IF;
      END IF;

      IF v_emitir = 0 THEN
         vcmotmov := pac_iax_suspension.f_get_cmotmov(ptmotmov, mensajes);

         IF vcmotmov IS NULL THEN
            RAISE e_object_error;
         END IF;

         vpasexec := 2;
         -- se valida si se puede realizar la insercion en suspensionseg
         vnumerr := pac_md_suspension.f_valida_crea_mov(psseguro, vcmotmov, mensajes);

         IF vnumerr <> 0 THEN
            RETURN 1;   -- no se llama a RAISE e_object_error para que no grabe en tab_error
                        -- se muestra el mensaje de error de validacion por pantalla
         END IF;

         vnumerr := pac_md_suspension.f_set_mov(psseguro, vcmotmov, pfmovini, pfrenova,
                                                pttexto, pttexto2, mensajes);

         IF vnumerr <> 0 THEN
            RAISE e_object_error;
         END IF;

         SELECT MAX(nmovimi)
           INTO v_nmovimi
           FROM movseguro
          WHERE sseguro = psseguro;

         -- De momento solo documentaci¿n a nivel de p¿liza.
         FOR regs IN (SELECT seqdocu, cdocume, sproduc, cactivi, norden, ctipdoc, cclase,
                             tfilename, tdescrip, adjuntado, iddocgedox
                        FROM estdocrequerida
                       WHERE sseguro = pac_iax_produccion.poliza.det_poliza.sseguro
                         AND nmovimi = NVL(pac_iax_produccion.poliza.det_poliza.nmovimi,
                                           nmovimi)) LOOP
            BEGIN
               INSERT INTO docrequerida
                           (seqdocu, cdocume, sproduc, cactivi,
                            norden, ctipdoc, cclase, sseguro, nmovimi,
                            tfilename, tdescrip, adjuntado, iddocgedox)
                    VALUES (regs.seqdocu, regs.cdocume, regs.sproduc, regs.cactivi,
                            regs.norden, regs.ctipdoc, regs.cclase, psseguro, v_nmovimi,
                            regs.tfilename, regs.tdescrip, regs.adjuntado, regs.iddocgedox);
            EXCEPTION
               WHEN DUP_VAL_ON_INDEX THEN
                  UPDATE docrequerida
                     SET adjuntado = regs.adjuntado
                   WHERE sseguro = psseguro
                     AND nmovimi = v_nmovimi
                     AND seqdocu = regs.seqdocu;
            END;
         END LOOP;

         -- se borran las tablas EST
         pac_alctr126.borrar_tablas_est(pac_iax_produccion.poliza.det_poliza.sseguro);
         vpasexec := 13;
         vnumerr := pac_md_docrequerida.f_subir_docsgedox(psseguro, v_nmovimi, mensajes);

         IF vnumerr > 0 THEN
            vpasexec := 14;
            RAISE e_object_error;
         END IF;
      END IF;

      IF vnumerr = 0 THEN
         pac_iax_produccion.ismodifprop := FALSE;
         pac_iax_produccion.vsseguro := NULL;
         pac_iax_produccion.vnmovimi := NULL;
         pac_iax_produccion.vpmode := NULL;
      END IF;

      vpasexec := 3;
      --BUG 29229 - INICIO - DCT - 10/12/2013 - LCOL_T010-LCOL - Revision incidencias Suspensi¿n / Reinicio (VIII)
      COMMIT;
      --BUG 29229 - FIN - DCT - 10/12/2013 - LCOL_T010-LCOL - Revision incidencias Suspensi¿n / Reinicio (VIII)
      RETURN vnumerr;
   EXCEPTION
      --Se debe realizar el control de errores mediante  el PAC_IOBJ_MENSAJES.P_TRATARMENSAJE.
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         --BUG 29229 - INICIO - DCT - 10/12/2013 - LCOL_T010-LCOL - Revision incidencias Suspensi¿n / Reinicio (VIII)
         ROLLBACK;
         --BUG 29229 - FIN - DCT - 10/12/2013 - LCOL_T010-LCOL - Revision incidencias Suspensi¿n / Reinicio (VIII)
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         --BUG 29229 - INICIO - DCT - 10/12/2013 - LCOL_T010-LCOL - Revision incidencias Suspensi¿n / Reinicio (VIII)
         ROLLBACK;
         --BUG 29229 - FIN - DCT - 10/12/2013 - LCOL_T010-LCOL - Revision incidencias Suspensi¿n / Reinicio (VIII)
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         --BUG 29229 - INICIO - DCT - 10/12/2013 - LCOL_T010-LCOL - Revision incidencias Suspensi¿n / Reinicio (VIII)
         ROLLBACK;
         --BUG 29229 - FIN - DCT - 10/12/2013 - LCOL_T010-LCOL - Revision incidencias Suspensi¿n / Reinicio (VIII)
         RETURN 1;
   END f_set_mov;

   /*************************************************************************
      Funcion que sirve para recuperar la descripcion del movimiento de suspensi¿n/reinicio
      param in psseguro  : id. de la poliza
      param in pcmotmov  : codigo motivo movimiento
      param in pnsuspens : fecha inicio movimiento
      return            : descripcion del movimiento
   *************************************************************************/
/*
   FUNCTION f_get_textdescsusp(
      psseguro IN NUMBER,
      ptmotmov IN VARCHAR2,
      pnsuspens IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN VARCHAR2 IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(2000)
           := 'psseguro=' || psseguro || ' ptmotmov=' || ptmotmov || 'pnsuspens=' || pnsuspens;
      vobject        VARCHAR2(2000) := 'PAC_IAX_SUSPENSION.F_GET_textdescsusp';
      squery         VARCHAR2(5000);
      vnumerr        NUMBER := 0;
      v_textdesbloq  VARCHAR2(2000);
      vcmotmov       NUMBER;
   BEGIN
      vcmotmov := pac_iax_suspension.f_get_cmotmov(ptmotmov, mensajes);

      IF vcmotmov IS NULL THEN
         RAISE e_object_error;
      END IF;

      vpasexec := 2;
      v_textdesbloq := pac_md_suspension.f_get_textdescsusp(psseguro, vcmotmov, pnsuspens,
                                                        mensajes);
      vpasexec := 3;
      RETURN v_textdesbloq;
   EXCEPTION
      --Se debe realizar el control de errores mediante  el PAC_IOBJ_MENSAJES.P_TRATARMENSAJE.
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_textdescsusp;
*/

   /*************************************************************************
      Funcion que valida la situacion de una poliza para realizar una suspensi¿n/reinicio
      param in psseguro : id. de la poliza
      param in pcmotmov : codigo motivo movimiento
      return            : Error
   *************************************************************************/
   FUNCTION f_valida_crea_mov(
      psseguro IN NUMBER,
      ptmotmov IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(2000) := 'psseguro=' || psseguro || ' ptmotmov=' || ptmotmov;
      vobject        VARCHAR2(2000) := 'PAC_IAX_SUSPENSION.F_VALIDA_CREA_MOV';
      squery         VARCHAR2(5000);
      vnumerr        NUMBER := 0;
      vcmotmov       NUMBER;
   BEGIN
      vcmotmov := pac_iax_suspension.f_get_cmotmov(ptmotmov, mensajes);

      IF vcmotmov IS NULL THEN
         RAISE e_object_error;
      END IF;

      vpasexec := 2;
      vnumerr := pac_md_suspension.f_valida_crea_mov(psseguro, vcmotmov, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      vpasexec := 3;
      RETURN vnumerr;
   EXCEPTION
      --Se debe realizar el control de errores mediante  el PAC_IOBJ_MENSAJES.P_TRATARMENSAJE.
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         --pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_valida_crea_mov;

   /*************************************************************************
      Funcion que inicializa los campos de pantalla en funcion de los
      parametros de entrada
      param in psseguro : id. de la poliza
      param in pcmotmov : codigo motivo movimiento
      param out pquery  : consulta a realizar construida en funcion de los
                          parametros
      return            : Error
   *************************************************************************/
   FUNCTION f_get_mov(psseguro IN NUMBER, ptmotmov IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(2000) := 'psseguro=' || psseguro || ' ptmotmov=' || ptmotmov;
      vobject        VARCHAR2(2000) := 'PAC_IAX_SUSPENSION.F_GET_MOV';
      squery         VARCHAR2(5000);
      vnumerr        NUMBER := 0;
      cur            sys_refcursor;
      vcmotmov       NUMBER;
   BEGIN
      vcmotmov := pac_iax_suspension.f_get_cmotmov(ptmotmov, mensajes);

      IF vcmotmov IS NULL THEN
         RAISE e_object_error;
      END IF;

      vpasexec := 2;
      cur := pac_md_suspension.f_get_mov(psseguro, vcmotmov, mensajes);
      vpasexec := 3;
      RETURN cur;   -- Todo Ok
   EXCEPTION
      --Se debe realizar el control de errores mediante el PAC_IOBJ_MENSAJES.P_TRATARMENSAJE.
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_mov;

   /*************************************************************************
      Funcion que devuelve el codigo del motivo de movimiento (suspensi¿n/reinicio)
      param in tmotmov : descripcion del codigo de movimiento
      return            : Error
   *************************************************************************/
   FUNCTION f_get_cmotmov(tmotmov IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(2000) := 'tmotmov=' || tmotmov;
      vobject        VARCHAR2(2000) := 'PAC_IAX_SUSPENSION.F_GET_CMOTMOV';
      squery         VARCHAR2(5000);
      vnumerr        NUMBER := 0;
      -- CONF-274-25/11/2016-JLTS- Ini
      vcod_reinicio   NUMBER := 0;
      v_contexto      NUMBER := 0;
      -- CONF-274-25/11/2016-JLTS- Fin
   BEGIN
      -- CONF-274-25/11/2016-JLTS- Ini
      v_contexto := pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(pac_md_common.f_get_cxtempresa,'USER_BBDD'));
      vcod_reinicio := NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa, 'COD_REINICIO'), 392);
      -- CONF-274-25/11/2016-JLTS- Fin
      IF tmotmov = 'BOT_SUSPENDER' THEN
         RETURN 391;
      -- CONF-274-25/11/2016-JLTS- Se incluye el BOT_REINICIAR_141
      ELSIF tmotmov in ('BOT_REINICIAR','BOT_REINICIAR_141') THEN
         RETURN vcod_reinicio; -- CONF-274-25/11/2016-JLTS- Se ajusta el 392 por la variable v_codreinicio
      ELSE
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 103311);   -- Falta el motivo del movimiento del seguro
         RETURN NULL;
      END IF;
   EXCEPTION
      --Se debe realizar el control de errores mediante  el PAC_IOBJ_MENSAJES.P_TRATARMENSAJE.
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_cmotmov;

   -- funcion para recuperar que boton ense¿ar
   FUNCTION f_get_prox_mov(psseguro IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
   BEGIN
      RETURN pac_md_suspension.f_get_prox_mov(psseguro, mensajes);
   END f_get_prox_mov;
END pac_iax_suspension;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_SUSPENSION" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_SUSPENSION" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_SUSPENSION" TO "PROGRAMADORESCSI";
