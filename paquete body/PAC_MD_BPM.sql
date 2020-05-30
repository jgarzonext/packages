--------------------------------------------------------
--  DDL for Package Body PAC_MD_BPM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MD_BPM" IS
/******************************************************************************
   NOMBRE:       PAC_MD_BPM
   PROPÓSITO: Funciones para integracion de BPM con AXIS

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        20/06/2009   JLB                1. Creación del package.
******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   /*********************************************************************************************************************
   * Funcion f_crear_proceso
   * Funcion que crea un proceso (pproceso) BPM, llama al axisconnectBPM
   * Parametros: pempresa: empresa a la que pertence el proceso
   *             pusuario: usuario con que se abre el proceso
   *             password: paswrod usuario
   *             pparametros: array de parametros que necesita el proceso
   * Return: 0 OK, otro valor error.
   *********************************************************************************************************************/
   FUNCTION f_crear_proceso(
      pempresa IN NUMBER,
      pusuario IN VARCHAR2,
      ppassword IN VARCHAR2,
      pproceso IN VARCHAR2,
      pparametros IN tparametros,
      psinterf IN OUT NUMBER,
      perror OUT VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(500) := 'PAC_MD_BPM.f_crear_proceso';
      vparam         VARCHAR2(500) := 'parámetros - pproceso:' || pproceso;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_bpm.f_crear_proceso(pempresa, pusuario, ppassword, pproceso, pparametros,
                                         psinterf, perror);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 9002012, vpasexec, vparam);
         RETURN vnumerr;
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
   END;

   /*********************************************************************************************************************
   * Funcion f_envio_evento
   * Funcion que envia un evento (pevento) a un proceso (pproceso) BPM, llama al axisconnectBPM
   * Parametros: pempresa: empresa a la que pertence el proceso
   *             pusuario: usuario con que se abre el proceso
   *             password: paswrod usuario
   *             pparametros: array de parametros que necesita el proceso
   * Return: 0 OK, otro valor error.
   *********************************************************************************************************************/
   FUNCTION f_envio_evento(
      pempresa IN NUMBER,
      pusuario IN VARCHAR2,
      ppassword IN VARCHAR2,
      pproceso IN VARCHAR2,
      pevento IN VARCHAR2,
      pparametros IN tparametros,
      psinterf IN OUT NUMBER,
      perror OUT VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(500) := 'PAC_MD_BPM.f_envio_evento';
      vparam         VARCHAR2(500)
                            := 'parámetros - pproceso:' || pproceso || ' - Evento:' || pevento;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_bpm.f_envio_evento(pempresa, pusuario, ppassword, pproceso, pevento,
                                        pparametros, psinterf, perror);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 9002012, vpasexec, vparam);
         RETURN vnumerr;
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
   END;

   /*********************************************************************************************************************
   * Funcion f_lanzar_proceso
   * Funcion que dado un sseguro, nmovimi y/o nsinies, perfil del usuario y modo  mira si se tiene que lanzar un proceso
   * BPM.
   * Parametros: psseguro: sseguro de la poliza
   *             pnmovimi: número de movimiento de la poliza
   *             pnsinies: número de siniestro
   *             pcperfil: perfil del usuario
   *             pcmodo  : operación que se está realizando (EMISION,SUPLEMENTO,SINIESTRO,etc)
   *             mensajes out: mensajes de error
   * Return: 0 OK, otro valor error.
   **********************************************************************************************************************/
   FUNCTION f_lanzar_proceso(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pnsinies IN VARCHAR2,
      pcperfil IN VARCHAR2,
      pcmodo IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(500) := 'PAC_MD_BPM.f_lanzar_proceso';
      vparam         VARCHAR2(500)
                         := 'parámetros - psseguro:' || psseguro || ' - pnsinies:' || pnsinies;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vterror        VARCHAR2(4000);
   BEGIN
      vnumerr := pac_bpm.f_lanzar_proceso(psseguro, pnmovimi, pnsinies, pcperfil, pcmodo,
                                          vterror);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 9002012, vpasexec,
                                           vparam || '-' || vterror);
         RETURN vnumerr;
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
   END;

   /*********************************************************************************************************************
   * FUNCIONES que deberian estar OBSOLETAS!!! No usar
   * Funciones propias de pilotos y demos, deben subsituirse en los procesos por funciones iaxis.
   *
   *
   **********************************************************************************************************************/
   FUNCTION f_aceptarpropuesta(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pnriesgo IN NUMBER,
      pfefecto IN DATE,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(500) := 'PAC_MD_BPM.F_ACEPTARPROPUESTA';
      vparam         VARCHAR2(500)
         := 'parámetros - psseguro:' || psseguro || '- pnmovimi:' || pnmovimi || '- pnriesgo:'
            || pnriesgo || '- pfefecto:' || pfefecto;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_bpm.f_aceptarpropuesta(psseguro, pnmovimi, pnriesgo, f_sysdate, mensajes);

      IF vnumerr != 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
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
   END f_aceptarpropuesta;

   FUNCTION f_emitirpropuesta(
      psseguro IN seguros.sseguro%TYPE,
      pnmovimi IN NUMBER,
      ppoliza OUT VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(500) := 'PAC_MD_BPM.F_EMITITPROPUESTA';
      vparam         VARCHAR2(500)
                          := 'parámetros - psseguro:' || psseguro || '- pnmovimi:' || pnmovimi;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_bpm.f_emitirpropuesta(psseguro, pnmovimi, ppoliza, mensajes);

      IF vnumerr != 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
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
   END f_emitirpropuesta;

   FUNCTION f_rechazarpropuesta(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pnriesgo IN NUMBER,
      pcmotmov IN NUMBER,
      pnsuplem IN NUMBER,
      ptobserva IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(500) := 'PAC_MD_BPM.F_RECHAZARPROPUESTA';
      vparam         VARCHAR2(500)
         := 'parámetros - psseguro:' || psseguro || '- pnmovimi:' || pnmovimi || '- pnriesgo:'
            || pnriesgo || '- pcmotmov:' || pcmotmov || '- pnsuplem:' || pnsuplem
            || '- ptobserva:' || ptobserva;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_bpm.f_rechazarpropuesta(psseguro, pnmovimi, pnriesgo, pcmotmov, pnsuplem,
                                             ptobserva, mensajes);

      IF vnumerr != 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
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
   END f_rechazarpropuesta;

   FUNCTION f_aceptarsobreprima(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pnriesgo IN NUMBER,
      pfefecto IN DATE,
      pprecarg IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(500) := 'PAC_MD_BPM.F_ACEPTARSOBREPRIMA';
      vparam         VARCHAR2(500)
         := 'parámetros - psseguro:' || psseguro || '- pnmovimi:' || pnmovimi || '- pnriesgo:'
            || pnriesgo || '- pfefecto:' || pfefecto || '- pprecarg:' || pprecarg;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_bpm.f_aceptarsobreprima(psseguro, pnmovimi, pnriesgo, pfefecto, pprecarg,
                                             mensajes);

      IF vnumerr != 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
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
   END f_aceptarsobreprima;

   FUNCTION f_set_citamedica(
      psseguro IN seguros.sseguro%TYPE,
      p_fecha_hora_visita IN DATE,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(500) := 'PAC_MD_BPM.F_SET_CITAMEDICA';
      vparam         VARCHAR2(500)
         := 'parámetros - psseguro:' || psseguro || ' - p_fecha_hora_visita:'
            || TO_CHAR(p_fecha_hora_visita, 'dd/mm/yyyy hh24:mi');
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_bpm.f_set_citamedica(psseguro, p_fecha_hora_visita, mensajes);

      IF vnumerr != 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
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
   END f_set_citamedica;
END pac_md_bpm;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_BPM" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_BPM" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_BPM" TO "PROGRAMADORESCSI";
