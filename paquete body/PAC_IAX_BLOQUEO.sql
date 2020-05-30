--------------------------------------------------------
--  DDL for Package Body PAC_IAX_BLOQUEO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IAX_BLOQUEO" AS
/******************************************************************************
 NOMBRE: PAC_BLOQUEO
 PROPOSITO: Funciones para el bloqueo/desbloqueo/pignoracion/despignoarcion de
 polizas

 REVISIONES:
 Ver Fecha Autor Descripcion
 --------- ---------- --------------- ------------------------------------
 1.0 12/05/2009 APD 1. Creacion del package (Bug 9390)
 2.0 29/03/2010 DRA 2. 0013888: CEM800 - Augmentar precisio dels camps TVALORA i TVALORD (DETMOVSEGURO, ESTDETMOVSEGURO)
******************************************************************************/

   /*************************************************************************
   Funcion que realiza la insercion de los movimientos bloqueo, desbloqueo,
   pignoracion y despignoracion de polizas
   param in psseguro : id. de la poliza
   param in pcmotmov : codigo motivo movimiento
   param in pfmovini : fecha inicio movimiento
   param in pfmovfin : fecha fin movimiento
   param in pttexto : descripcion del movimiento de bloqueo/pignoracion
   param in pttexto2 : descripcion del movimiento de debloqueo/despignoarcion
   param in pimporte : importe de pignoracion
   param in pcausa : tipo de la causa
   return : Error
   *************************************************************************/
   FUNCTION f_set_mov(
      psseguro IN NUMBER,
      ptmotmov IN VARCHAR2,
      pfmovini IN DATE,
      pfmovfin IN DATE,
      pttexto IN VARCHAR2,
      pttexto2 IN VARCHAR2,
      pimporte IN NUMBER,
      psperson IN NUMBER,
      pcopcional IN NUMBER,
      pnrango IN NUMBER,
      pncolater IN NUMBER,
      pnmovimi IN NUMBER,
      pmodo IN VARCHAR2,
      pcausa IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(2000)
         := 'psseguro=' || psseguro || ' ptmotmov=' || ptmotmov || 'pfmovini=' || pfmovini
            || ' pfmovfin=' || pfmovfin || 'pttexto=' || SUBSTR(pttexto, 1, 400)
            || ' pttexto2=' || SUBSTR(pttexto2, 1, 400) || 'pimporte=' || ' psperson='
            || psperson || ' pcopcional=' || pcopcional || ' pnrango=' || pnrango
            || ' pncolater=' || pncolater || ' pnmovimi=' || pnmovimi || ' pmodo=' || pmodo
            || ' pcausa=' || pcausa;
      vobject        VARCHAR2(2000) := 'PAC_IAX_BLOQUEO.F_SET_MOV';
      vnumerr        NUMBER := 0;
      vcmotmov       NUMBER;
      v_nrango       NUMBER;   -- BUG 27766
   BEGIN
      vcmotmov := pac_iax_bloqueo.f_get_cmotmov(ptmotmov, mensajes);

      IF vcmotmov IS NULL THEN
         RAISE e_object_error;
      END IF;

      vpasexec := 2;

      IF pmodo IS NULL THEN   -- BUG 27766
         -- se valida si se puede realizar la insercion en bloqueoseg
         vnumerr := pac_md_bloqueo.f_valida_crea_mov(psseguro, vcmotmov, mensajes);
      END IF;

      IF vcmotmov IN(263, 264) THEN   -- BUG 27766
         v_nrango := NULL;
      ELSE
         v_nrango := pnrango;
      END IF;

      IF vnumerr <> 0 THEN
         RETURN 1;   -- no se llama a RAISE e_object_error para que no grabe en tab_error
      -- se muestra el mensaje de error de validacion por pantalla
      END IF;

      vpasexec := 3;
      vnumerr := pac_md_bloqueo.f_set_mov(psseguro, vcmotmov, pfmovini, pfmovfin, pttexto,
                                          pttexto2, pimporte, psperson, pcopcional, v_nrango,
                                          pncolater, pnmovimi, pmodo, pcausa, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      vpasexec := 4;
      RETURN vnumerr;
   EXCEPTION
      --Se debe realizar el control de errores mediante el PAC_IOBJ_MENSAJES.P_TRATARMENSAJE.
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
   END f_set_mov;

   /*************************************************************************
   Funcion que sirve para recuperar la descripcion del movimiento de
   desbloqueo o despignoracion
   param in psseguro : id. de la poliza
   param in pcmotmov : codigo motivo movimiento
   param in pnbloqueo : fecha inicio movimiento
   return : Error
   *************************************************************************/
   FUNCTION f_get_textdesbloq(
      psseguro IN NUMBER,
      ptmotmov IN VARCHAR2,
      pnbloqueo IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN VARCHAR2 IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(2000)
           := 'psseguro=' || psseguro || ' ptmotmov=' || ptmotmov || 'pnbloqueo=' || pnbloqueo;
      vobject        VARCHAR2(2000) := 'PAC_IAX_BLOQUEO.F_GET_TEXTDESBLOQ';
      squery         VARCHAR2(5000);
      vnumerr        NUMBER := 0;
      v_textdesbloq  VARCHAR2(2000);
      vcmotmov       NUMBER;
   BEGIN
      vcmotmov := pac_iax_bloqueo.f_get_cmotmov(ptmotmov, mensajes);

      IF vcmotmov IS NULL THEN
         RAISE e_object_error;
      END IF;

      vpasexec := 2;
      v_textdesbloq := pac_md_bloqueo.f_get_textdesbloq(psseguro, vcmotmov, pnbloqueo,
                                                        mensajes);
      vpasexec := 3;
      RETURN v_textdesbloq;
   EXCEPTION
      --Se debe realizar el control de errores mediante el PAC_IOBJ_MENSAJES.P_TRATARMENSAJE.
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
   END f_get_textdesbloq;

   /*************************************************************************
   Funcion que valida la situacion de una poliza para realizar un
   bloqueo/desbloqueo o pignoracion/despignoracion
   param in psseguro : id. de la poliza
   param in pcmotmov : codigo motivo movimiento
   return : Error
   *************************************************************************/
   FUNCTION f_valida_crea_mov(
      psseguro IN NUMBER,
      ptmotmov IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(2000) := 'psseguro=' || psseguro || ' ptmotmov=' || ptmotmov;
      vobject        VARCHAR2(2000) := 'PAC_IAX_BLOQUEO.F_VALIDA_CREA_MOV';
      squery         VARCHAR2(5000);
      vnumerr        NUMBER := 0;
      vcmotmov       NUMBER;
   BEGIN
      vcmotmov := pac_iax_bloqueo.f_get_cmotmov(ptmotmov, mensajes);

      IF vcmotmov IS NULL THEN
         RAISE e_object_error;
      END IF;

      vpasexec := 2;
      vnumerr := pac_md_bloqueo.f_valida_crea_mov(psseguro, vcmotmov, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      vpasexec := 3;
      RETURN vnumerr;
   EXCEPTION
      --Se debe realizar el control de errores mediante el PAC_IOBJ_MENSAJES.P_TRATARMENSAJE.
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
   param in pnmovimi : Nzmero de movimiento -- BUG 27766
   param out pquery : consulta a realizar construida en funcion de los
   parametros
   return : Error
   *************************************************************************/
   FUNCTION f_get_mov(
      psseguro IN NUMBER,
      ptmotmov IN VARCHAR2,
      pnmovimi IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(2000)
            := 'psseguro=' || psseguro || ' ptmotmov=' || ptmotmov || ' pnmovimi=' || pnmovimi;
      vobject        VARCHAR2(2000) := 'PAC_IAX_BLOQUEO.F_GET_MOV';
      squery         VARCHAR2(5000);
      vnumerr        NUMBER := 0;
      cur            sys_refcursor;
      vcmotmov       NUMBER;
   BEGIN
      vcmotmov := pac_iax_bloqueo.f_get_cmotmov(ptmotmov, mensajes);

      IF vcmotmov IS NULL THEN
         RAISE e_object_error;
      END IF;

      vpasexec := 2;
      cur := pac_md_bloqueo.f_get_mov(psseguro, vcmotmov, pnmovimi, mensajes);
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
   Funcion que devuelve el codigo del motivo de movimiento (bloqueo, desbloqueo,
   pignoracion, despignoracion)
   param in tmotmov : descripcion del codigo de movimiento
   return : Error
   *************************************************************************/
   FUNCTION f_get_cmotmov(tmotmov IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(2000) := 'tmotmov=' || tmotmov;
      vobject        VARCHAR2(2000) := 'PAC_IAX_BLOQUEO.F_GET_CMOTMOV';
      squery         VARCHAR2(5000);
      vnumerr        NUMBER := 0;
   BEGIN
      IF tmotmov = 'BOT_PIGNORAR' THEN
         RETURN 261;
      ELSIF tmotmov = 'BOT_DESPIGNORAR' THEN
         RETURN 263;
      ELSIF tmotmov = 'BOT_BLOQUEAR' THEN
         RETURN 262;
      ELSIF tmotmov = 'BOT_DESBLOQUEAR' THEN
         RETURN 264;
      -- CONF-274-25/11/2016-JLTS- Ini
      ELSIF tmotmov = 'BOT_REINICIAR' THEN
         RETURN 141;
      ELSIF tmotmov = 'BOT_SUSPENDER' THEN
         RETURN 391;
      -- CONF-274-25/11/2016-JLTS- Fin
      ELSE
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 103311);   -- Falta el motivo del movimiento del seguro
         RETURN NULL;
      END IF;
   EXCEPTION
      --Se debe realizar el control de errores mediante el PAC_IOBJ_MENSAJES.P_TRATARMENSAJE.
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

   /*************************************************************************
   Funcion que retorna la lista de personas que contienen el parametro en PER_PARPERSONAS
   con el valor igual a 0, mas los existentes en los bloqueos asociados a la poliza
   param in psseguro : Codigo del seguro
   param in pcmotmov : Motivo del movimiento
   param in pmodo : Modo ALTA_BENEF / ELIMINAR_BENEF
   param in pnmovimi : Nzmero de movimiento
   return : Error
   bug 27766
   *************************************************************************/
   FUNCTION f_get_pignoradores(
      psseguro IN NUMBER,
      pcmotmov IN NUMBER,
      pmodo IN VARCHAR2,
      pnmovimi IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(2000)
            := 'psseguro=' || psseguro || ' pcmotmov=' || pcmotmov || ' pnmovimi=' || pnmovimi;
      vobject        VARCHAR2(2000) := 'PAC_IAX_BLOQUEO.F_GET_PIGNORADORES';
      cur            sys_refcursor;
   BEGIN
      -- Control parametros entrada
      IF psseguro IS NULL
         OR pcmotmov IS NULL
                            --OR pnmovimi IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      cur := pac_md_bloqueo.f_get_pignoradores(psseguro, pcmotmov, pmodo, pnmovimi, mensajes);
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
   END f_get_pignoradores;

   /*************************************************************************
   Funcion que retorna los registros de la tabla bloqueo que no se encuentran finalizados
   en el tiempo.
   param in psseguro : Codigo del seguro
   return : Error
   bug 27766
   *************************************************************************/
   FUNCTION f_get_bloqueos(psseguro IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(2000) := 'psseguro=' || psseguro;
      vobject        VARCHAR2(2000) := 'PAC_MD_BLOQUEO.F_GET_BLOQUEO';
      cur            sys_refcursor;
   BEGIN
      -- Control parametros entrada
      IF psseguro IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      cur := pac_md_bloqueo.f_get_bloqueos(psseguro, mensajes);
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
   END f_get_bloqueos;

   FUNCTION f_update_pledged(
      psseguro IN NUMBER,
      pcmotmov IN VARCHAR2,
      pnmovimi IN NUMBER,
      pttexto_ant IN VARCHAR2,
      psperson_ant IN NUMBER,
      pnrango_ant IN NUMBER,
      pncolater_ant IN NUMBER,
      pfmovini_ant IN DATE,
      pttexto_upd IN VARCHAR2,
      psperson_upd IN NUMBER,
      pnrango_upd IN NUMBER,
      pncolater_upd IN NUMBER,
      pfmovini_upd IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER := 0;
      vobject        VARCHAR(50) := 'PAC_IAX_BLOQUEO.f_update_pledged';
      vparam         VARCHAR(4000)
         := 'psseguro=' || psseguro || ' pcmotmov=' || pcmotmov || ' pnmovimi=' || pnmovimi
            || ' pttexto_ant=' || pttexto_ant || ' psperson_ant=' || psperson_ant
            || ' pnrango_ant=' || pnrango_ant || ' pncolater_ant=' || pncolater_ant
            || ' pfmovini_ant=' || pfmovini_ant || ' pttexto_upd=' || pttexto_upd
            || ' psperson_upd=' || psperson_upd || ' pnrango_upd=' || pnrango_upd
            || ' pncolater_upd=' || pncolater_upd || ' pfmovini_upd=' || pfmovini_upd;
      vpasexec       NUMBER := 1;
   BEGIN
      vnumerr := pac_md_bloqueo.f_update_pledged(psseguro, pcmotmov, pnmovimi, pttexto_ant,
                                                 psperson_ant, pnrango_ant, pncolater_ant,
                                                 pfmovini_ant, pttexto_upd, psperson_upd,
                                                 pnrango_upd, pncolater_upd, pfmovini_upd,
                                                 mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      --
      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 9908446);
      --
      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_update_pledged;
END pac_iax_bloqueo;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_BLOQUEO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_BLOQUEO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_BLOQUEO" TO "PROGRAMADORESCSI";
