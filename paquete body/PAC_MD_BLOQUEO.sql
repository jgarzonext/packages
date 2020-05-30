--------------------------------------------------------
--  DDL for Package Body PAC_MD_BLOQUEO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MD_BLOQUEO" AS
/******************************************************************************
   NOMBRE:    PAC_BLOQUEO
   PROPÓSITO: Funciones para el bloqueo/desbloqueo/pignoracion/despignoarcion de
              pólizas

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        12/05/2009   APD                1. Creación del package (Bug 9390)
   2.0        29/03/2010   DRA                2. 0013888: CEM800 - Augmentar precisió dels camps TVALORA i TVALORD (DETMOVSEGURO, ESTDETMOVSEGURO)
******************************************************************************/

   /*************************************************************************
      Funcion que realiza la insercion de los movimientos bloqueo, desbloqueo,
      pignoracion y despignoracion de polizas
      param in psseguro : id. de la poliza
      param in pcmotmov : codigo motivo movimiento
      param in pfmovini : fecha inicio movimiento
      param in pfmovfin : fecha fin movimiento
      param in pttexto  : descripcion del movimiento de bloqueo/pignoracion
      param in pttexto2 : descripcion del movimiento de debloqueo/despignoarcion
      param in pimporte : importe de pignoracion
      param in pcausa   : tipo de la causa
      return            : Error
   *************************************************************************/
   FUNCTION f_set_mov(
      psseguro IN NUMBER,
      pcmotmov IN NUMBER,
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
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(2000)
         := 'psseguro=' || psseguro || ' pcmotmov=' || pcmotmov || 'pfmovini=' || pfmovini
            || ' pfmovfin=' || pfmovfin || 'pttexto=' || SUBSTR(pttexto, 1, 400)
            || ' pttexto2=' || SUBSTR(pttexto2, 1, 400) || 'pimporte=' || pimporte
            || ' psperson=' || psperson || ' pcopcional=' || pcopcional || ' pnrango='
            || pnrango || ' pncolater=' || pncolater || ' pnmovimi=' || pnmovimi || ' pmodo='
            || pmodo || ' pcausa=' || pcausa;
      vobject        VARCHAR2(2000) := 'PAC_MD_BLOQUEO.F_SET_MOV';
      squery         VARCHAR2(5000);
      vnumerr        NUMBER := 0;
      v_benefi       NUMBER;
      vbeneficiariodesig NUMBER;
      vbeneficiarioacept NUMBER;
   BEGIN
      -- Control parametros entrada
      IF psseguro IS NULL
         OR pcmotmov IS NULL
         OR pfmovini IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 40202);   -- Hay campos obligatorios por entrar
         RAISE e_param_error;
      END IF;

      vpasexec := 2;

      -- BUG: 27766
      IF pnrango IS NOT NULL
         AND pcmotmov IN(261, 262) THEN
         -- Verifica bloqueo/pignoracion vigente para el nzmero de rango
         IF pac_bloqueo.f_valida_bloqueo_vigente(psseguro, pnrango, pcmotmov) != 0 THEN
            RAISE e_object_existe_bloqueo;   -- Existe una Pignoracisn/Bloqueo con el mismo nzmero de rango
         END IF;
      END IF;

      vpasexec := 3;

      --
      IF psperson IS NOT NULL THEN
         -- verifica que la persona esta parametrizada
         IF pac_bloqueo.f_valida_dest_pignoracion(psperson) != 0 THEN
            RAISE e_object_sperson_informado;   -- La persona no es destinataria de pignoracisn
         END IF;
      END IF;

      vpasexec := 4;
      vnumerr := pac_bloqueo.f_set_mov(psseguro, pcmotmov, pfmovini, pfmovfin, pttexto,
                                       pttexto2, pimporte, psperson, pcopcional, pnrango,
                                       pncolater, pnmovimi, pmodo, pcausa, v_benefi);
      vpasexec := 5;

      IF vnumerr = 0 THEN
         IF pcmotmov = 263 THEN
            -- INFO : PÓLIZA DESPIGNORADA
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 109219);
         ELSIF pcmotmov = 264 THEN
            -- INFO : PÓLIZA DESBLOQUEADA
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 109220);
         ELSIF pcmotmov = 261 THEN
            -- INFO : PÓLIZA PIGNORADA
            -- Antes de 29822/202593 habia esta linea
            -- pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 152211);

            -- Hay que detectar si el beneficairio es aceptado o designado
            BEGIN
               SELECT COUNT(*)   --29822/213785
                 INTO vbeneficiarioacept
                 FROM benespseg
                WHERE sseguro = psseguro
                  AND ctipben = 4
                  AND ffinben IS NULL;
            EXCEPTION
               WHEN OTHERS THEN
                  vbeneficiarioacept := 0;   -- Póliza no tiene beneficiarios
            END;

            BEGIN
               SELECT COUNT(*)   --29822/213785
                 INTO vbeneficiariodesig
                 FROM benespseg
                WHERE sseguro = psseguro
                  AND ctipben = 1
                  AND ffinben IS NULL;
            EXCEPTION
               WHEN OTHERS THEN
                  vbeneficiariodesig := 0;   -- Póliza no tiene beneficiarios
            END;

            --JRH Hay que detectar si el beneficairio es aceptado o designado
            IF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa,
                                                 'FORZAR_BENEF_PIGNO'),
                   0) = 1
               AND vbeneficiarioacept > 0 THEN
               -- Si el beneficairio es aceptado
               pac_iobj_mensajes.crea_nuevo_mensaje
                                            (mensajes, 2, NULL,
                                             f_axis_literales(152211,
                                                              pac_md_common.f_get_cxtidioma)
                                             || '. '
                                             || f_axis_literales
                                                                (9909024,
                                                                 pac_md_common.f_get_cxtidioma));
            ELSIF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa,
                                                 'FORZAR_BENEF_PIGNO'),
                   0) = 1
               AND vbeneficiariodesig > 0 THEN
               -- Si el beneficairio es designado
               pac_iobj_mensajes.crea_nuevo_mensaje
                                            (mensajes, 2, NULL,
                                             f_axis_literales(152211,
                                                              pac_md_common.f_get_cxtidioma)
                                             || '. '
                                             || f_axis_literales
                                                                (9907900,
                                                                 pac_md_common.f_get_cxtidioma));

            ELSIF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa,
                                                 'FORZAR_BENEF_PIGNO'),
                   0) = 1
               AND v_benefi > 0 THEN
               --
               pac_iobj_mensajes.crea_nuevo_mensaje
                                            (mensajes, 2, NULL,
                                             f_axis_literales(152211,
                                                              pac_md_common.f_get_cxtidioma)
                                             || '. '
                                             || f_axis_literales
                                                                (9907900,
                                                                 pac_md_common.f_get_cxtidioma));
            ELSE
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 152211);
            END IF;
         ELSIF pcmotmov = 262 THEN
            -- INFO : PÓLIZA BLOQUEADA
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 152212);
         ELSIF pcmotmov = 261
               AND pmodo IS NOT NULL THEN
            -- INFO : ALTA DE BENEFICIARIO
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 9905937);
         ELSIF pcmotmov = 263
               AND pmodo IS NOT NULL THEN
            -- INFO : BAJA DE BENEFICIARIO
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 9905936);
         END IF;
      ELSE
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
      WHEN e_object_existe_bloqueo THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 9906363);
         RETURN 1;
      WHEN e_object_sperson_informado THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 9906362);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_set_mov;

   /*************************************************************************
      Funcion que sirve para recuperar la descripcion del movimiento de
      desbloqueo o despignoracion
      param in psseguro  : id. de la poliza
      param in pcmotmov  : codigo motivo movimiento
      param in pnbloqueo : fecha inicio movimiento
      return            : Error
   *************************************************************************/
   FUNCTION f_get_textdesbloq(
      psseguro IN NUMBER,
      pcmotmov IN NUMBER,
      pnbloqueo IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN VARCHAR2 IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(2000)
           := 'psseguro=' || psseguro || ' pcmotmov=' || pcmotmov || 'pnbloqueo=' || pnbloqueo;
      vobject        VARCHAR2(2000) := 'PAC_MD_BLOQUEO.F_GET_TEXTDESBLOQ';
      squery         VARCHAR2(5000);
      vnumerr        NUMBER := 0;
      v_textdesbloq  VARCHAR2(2000);
   BEGIN
      -- Control parametros entrada
      IF psseguro IS NULL
         OR pcmotmov IS NULL
         OR pnbloqueo IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;

      -- 263 = Despignoracion
      -- 264 = Desbloquear
      IF pcmotmov IN(263, 264) THEN
         v_textdesbloq := pac_bloqueo.f_get_textdesbloq(psseguro, pcmotmov, pnbloqueo);
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
   END f_get_textdesbloq;

   /*************************************************************************
      Funcion que valida la situacion de una poliza para realizar un
      bloqueo/desbloqueo o pignoracion/despignoracion
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
      vobject        VARCHAR2(2000) := 'PAC_MD_BLOQUEO.F_VALIDA_CREA_MOV';
      squery         VARCHAR2(5000);
      vnumerr        NUMBER := 0;
   BEGIN
      -- Control parametros entrada
      IF psseguro IS NULL
         OR pcmotmov IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      vnumerr := pac_bloqueo.f_valida_crea_mov(psseguro, pcmotmov);

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
      param in pnmovimi : Nzmero de movimiento  -- BUG 27766
      param out pquery  : consulta a realizar construida en funcion de los
                          parametros
      return            : Error
   *************************************************************************/
   FUNCTION f_get_mov(
      psseguro IN NUMBER,
      pcmotmov IN NUMBER,
      pnmovimi IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(2000)
            := 'psseguro=' || psseguro || ' pcmotmov=' || pcmotmov || ' pnmovimi=' || pnmovimi;
      vobject        VARCHAR2(2000) := 'PAC_MD_BLOQUEO.F_GET_MOV';
      squery         VARCHAR2(5000);
      vnumerr        NUMBER := 0;
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
      vnumerr := pac_bloqueo.f_get_mov(psseguro, pcmotmov, pnmovimi, squery);

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

   /*************************************************************************
      f_get_pignoradores
        Funcion que retornara la lista de personas que contienen el parametro en PER_PARPERSONAS
        con valor 0, mas los que ya existan en los bloqueos asociados a la poliza
        param in psperson : id. de persona
        param in pcmotmov : Motivo del movimiento
        param in pmodo    : Modo ALTA_BENEF / ELIMINAR_BENEF
        param in pnmovimi : Nzmero de movimiento
        return            : Error
      BUG - 27766
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
         := 'psseguro=' || psseguro || ' pcmotmov=' || pcmotmov || ' pmodo=' || pmodo
            || ' pnmovimi=' || pnmovimi;
      vobject        VARCHAR2(2000) := 'PAC_MD_BLOQUEO.F_GET_PIGNORADORES';
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
      vnumerr := pac_bloqueo.f_get_pignoradores(psseguro, pcmotmov, pmodo, pnmovimi, squery);

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
   END f_get_pignoradores;

   /*************************************************************************
      Funcion que retorna los registros de la tabla bloqueo que no se encuentran finalizados
      en el tiempo.
      param in psseguro : Codigo del seguro
      return            : Error
      bug 27766
   *************************************************************************/
   FUNCTION f_get_bloqueos(psseguro IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(2000) := 'psseguro=' || psseguro;
      vobject        VARCHAR2(2000) := 'PAC_MD_BLOQUEO.F_GET_BLOQUEOS';
      squery         VARCHAR2(5000);
      vnumerr        NUMBER := 0;
      cur            sys_refcursor;
   BEGIN
      -- Control parametros entrada
      IF psseguro IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      vnumerr := pac_bloqueo.f_get_bloqueos(psseguro, squery);

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
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER;
      vobject        VARCHAR(50) := 'PAC_MD_BLOQUEO.f_update_pledged';
      vparam         VARCHAR(4000)
         := 'psseguro=' || psseguro || ' pcmotmov=' || pcmotmov || ' pnmovimi=' || pnmovimi
            || ' pttexto_ant=' || pttexto_ant || ' psperson_ant=' || psperson_ant
            || ' pnrango_ant=' || pnrango_ant || ' pncolater_ant=' || pncolater_ant
            || ' pfmovini_ant=' || pfmovini_ant || ' pttexto_upd=' || pttexto_upd
            || ' psperson_upd=' || psperson_upd || ' pnrango_upd=' || pnrango_upd
            || ' pncolater_upd=' || pncolater_upd || ' pfmovini_upd=' || pfmovini_upd;
      vpasexec       NUMBER := 1;
   BEGIN
      IF pnrango_ant <> pnrango_upd THEN
         IF pac_bloqueo.f_valida_bloqueo_vigente(psseguro, pnrango_upd, pcmotmov) != 0 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 9906363);
            RETURN 1;
         END IF;
      END IF;

      RETURN pac_bloqueo.f_update_pledged(psseguro, pcmotmov, pnmovimi, pttexto_ant,
                                          psperson_ant, pnrango_ant, pncolater_ant,
                                          pfmovini_ant, pttexto_upd, psperson_upd, pnrango_upd,
                                          pncolater_upd, pfmovini_upd);
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_update_pledged;
END pac_md_bloqueo;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_BLOQUEO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_BLOQUEO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_BLOQUEO" TO "PROGRAMADORESCSI";
