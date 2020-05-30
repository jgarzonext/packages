--------------------------------------------------------
--  DDL for Package Body PAC_MD_SUSPENSION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MD_SUSPENSION" AS
/******************************************************************************
   NOMBRE:    PAC_MD_SUSPENSION
   PROP¿SITO: Funciones para la suspensi¿n/reinicio de p¿lizas

   REVISIONES:
   Ver        Fecha        Autor             Descripci¿n
   ---------  ----------  ---------------  ------------------------------------
   1.0        14/11/2012   FAL                1. Creaci¿¿n del package (Bug 0024450)
   2.0        02/12/2013   DCT                2. 0029229: LCOL_T010-LCOL - Revision incidencias qtracker (VIII)
******************************************************************************/

   /*************************************************************************
      Funcion que realiza la insercion de los movimientos suspensi¿n/reinicio de polizas
      param in psseguro : id. de la poliza
      param in pcmotmov : codigo motivo movimiento
      param in pfmovini : fecha inicio movimiento
      param in pfcaranu : fecha nueva vigencia en reinicios
      param in pttexto  : descripcion del movimiento de suspensi¿n/reinicio
      param in pttexto2 : descripcion del movimiento de debloqueo/despignoarcion
      return            : Error
   *************************************************************************/
   FUNCTION f_set_mov(
      psseguro IN NUMBER,
      pcmotmov IN NUMBER,
      pfmovini IN DATE,
      pfrenova IN DATE,
      pttexto IN VARCHAR2,
      pttexto2 IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(2000)
         := 'psseguro=' || psseguro || ' pcmotmov=' || pcmotmov || 'pfmovini=' || pfmovini
            || ' pfrenova=' || pfrenova || 'pttexto=' || SUBSTR(pttexto, 1, 400)
            || ' pttexto2=' || SUBSTR(pttexto2, 1, 400);
      vobject        VARCHAR2(2000) := 'PAC_MD_SUSPENSION.F_SET_MOV';
      squery         VARCHAR2(5000);
      vnumerr        NUMBER := 0;
      v_sproduc      seguros.sproduc%TYPE;
   BEGIN
      -- Control parametros entrada
      IF psseguro IS NULL
         OR pcmotmov IS NULL
         OR pfmovini IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 40202);   -- Hay campos obligatorios por entrar
         RAISE e_param_error;
      END IF;

      vpasexec := 2;

      --BUG29229 - INICIO - DCT - 02/12/2013
      BEGIN
         SELECT sproduc
           INTO v_sproduc
           FROM seguros
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN(100500);   -- P¿liza inexistente
      END;

      vpasexec := 3;

      IF NVL(f_parproductos_v(v_sproduc, 'ADMITE_CERTIFICADOS'), 0) = 1
         AND pac_seguros.f_es_col_agrup(psseguro) = 1 THEN
         IF pac_seguros.f_get_escertifcero(NULL, psseguro) = 1 THEN
            RETURN(9905997);   -- La suspensi¿n/reinicio en colectivos agrupados no aplica sobre la car¿tula.
         END IF;
      END IF;

      vpasexec := 4;

      IF NVL(f_parproductos_v(v_sproduc, 'ADMITE_CERTIFICADOS'), 0) = 1
         AND pac_seguros.f_es_col_admin(psseguro) = 1 THEN
         IF pac_seguros.f_get_escertifcero(NULL, psseguro) <> 1 THEN
            RETURN(9906000);   -- La suspensi¿n/reinicio en colectivos administrados no aplica en los certificados.
         END IF;
      END IF;

      --BUG29229 - FIN - DCT - 02/12/2013
      vpasexec := 5;
      vnumerr := pac_suspension.f_call_set_mov(psseguro, pcmotmov, pfmovini, pfrenova, pttexto,
                                               pttexto2);
      vpasexec := 6;

      IF vnumerr = 0 THEN
         IF pcmotmov = 391 THEN
            -- INFO : P¿LIZA SUSPENDIDA
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 9904518);
         ELSIF pcmotmov = pac_suspension.vcod_reinicio THEN -- CONF-274-25/11/2016-JLTS- Se cambia 392 por la variable vcod_reinicio
            -- INFO : P¿LIZA REINICIADA
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 9904519);
         END IF;
      else
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      --Se debe realizar el control de errores mediante  el PAC_IOBJ_MENSAJES.P_TRATARMENSAJE.
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
      Funcion que sirve para recuperar la descripcion del movimiento de suspensi¿n/reinicio
      param in psseguro  : id. de la poliza
      param in pcmotmov  : codigo motivo movimiento
      param in pnsuspens : fecha inicio movimiento
      return            : descripcion del movimiento
   *************************************************************************/
/*
   FUNCTION f_get_textdescsusp(
      psseguro IN NUMBER,
      pcmotmov IN NUMBER,
      pnsuspens IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN VARCHAR2 IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(2000)
           := 'psseguro=' || psseguro || ' pcmotmov=' || pcmotmov || 'pnsuspens=' || pnsuspens;
      vobject        VARCHAR2(2000) := 'PAC_MD_SUSPENSION.F_GET_textdescsusp';
      squery         VARCHAR2(5000);
      vnumerr        NUMBER := 0;
      v_textdesbloq  VARCHAR2(2000);
   BEGIN
      -- Control parametros entrada
      IF psseguro IS NULL
         OR pcmotmov IS NULL
         OR pnsuspens IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;

      -- 263 = Despignoracion
      -- 264 = Desbloquear
      IF pcmotmov IN(263, 264) THEN
         v_textdesbloq := pac_bloqueo.f_get_textdescsusp(psseguro, pcmotmov, pnsuspens);
      ELSE
         v_textdesbloq := NULL;
      END IF;

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
      pcmotmov IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(2000) := 'psseguro=' || psseguro || ' pcmotmov=' || pcmotmov;
      vobject        VARCHAR2(2000) := 'PAC_MD_SUSPENSION.F_VALIDA_CREA_MOV';
      squery         VARCHAR2(5000);
      vnumerr        NUMBER := 0;
   BEGIN
      -- Control parametros entrada
      IF psseguro IS NULL
         OR pcmotmov IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      vnumerr := pac_suspension.f_valida_crea_mov(psseguro, pcmotmov);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, vnumerr);
         RAISE e_object_error;
      END IF;

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
   FUNCTION f_get_mov(psseguro IN NUMBER, pcmotmov IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(2000) := 'psseguro=' || psseguro || ' pcmotmov=' || pcmotmov;
      vobject        VARCHAR2(2000) := 'PAC_MD_SUSPENSION.F_GET_MOV';
      squery         VARCHAR2(5000);
      vnumerr        NUMBER := 0;
      cur            sys_refcursor;
   BEGIN
      -- Control parametros entrada
      IF psseguro IS NULL
         OR pcmotmov IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      vnumerr := pac_suspension.f_get_mov(psseguro, pcmotmov, squery);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      vpasexec := 3;

      IF squery IS NOT NULL THEN
         cur := pac_iax_listvalores.f_opencursor(squery, mensajes);
      END IF;

      RETURN cur;   -- Todo Ok
   EXCEPTION
      --Se debe realizar el control de errores mediante  el PAC_IOBJ_MENSAJES.P_TRATARMENSAJE.
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

   -- funcion para recuperar que boton ense¿ar
   FUNCTION f_get_prox_mov(psseguro IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
   BEGIN
      RETURN pac_suspension.f_get_prox_mov(psseguro);
   END f_get_prox_mov;
END pac_md_suspension;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_SUSPENSION" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_SUSPENSION" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_SUSPENSION" TO "PROGRAMADORESCSI";
