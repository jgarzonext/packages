--------------------------------------------------------
--  DDL for Package Body PAC_IAX_BPM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IAX_BPM" IS
/******************************************************************************
   NOMBRE:       PAC_IAX_BPM
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
      vobject        VARCHAR2(500) := 'PAC_IAX_BPM.f_crear_proceso';
      vparam         VARCHAR2(500) := 'parámetros - pproceso:' || pproceso;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_md_bpm.f_crear_proceso(pempresa, pusuario, ppassword, pproceso,
                                            pparametros, psinterf, perror, mensajes);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
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
      vobject        VARCHAR2(500) := 'PAC_IAX_BPM.f_envio_evento';
      vparam         VARCHAR2(500)
                            := 'parámetros - pproceso:' || pproceso || ' - Evento:' || pevento;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_md_bpm.f_envio_evento(pempresa, pusuario, ppassword, pproceso, pevento,
                                           pparametros, psinterf, perror, mensajes);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
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
   */
   FUNCTION f_lanzar_proceso(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pnsinies IN VARCHAR2,
      pcperfil IN VARCHAR2,
      pcmodo IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(500) := 'PAC_IAX_BPM.f_lanzar_proceso';
      vparam         VARCHAR2(500)
                         := 'parámetros - psseguro:' || psseguro || ' - pnsinies:' || pnsinies;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_md_bpm.f_lanzar_proceso(psseguro, pnmovimi, pnsinies, pcperfil, pcmodo,
                                             mensajes);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
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
   FUNCTION f_aceptarpropuesta(psseguro IN seguros.sseguro%TYPE   --,
                                                               --mensajes   out t_iax_mensajes
   )
      RETURN NUMBER IS
      vobject        VARCHAR2(500) := 'PAC_IAX_BPM.F_ACEPTARPROPUESTA';
      vparam         VARCHAR2(500) := 'parámetros - psseguro:' || psseguro;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      mensajes       t_iax_mensajes;   -- !!!!!! Cuando se ponga como parámetro quitar esta variable.
   BEGIN
      pac_iax_login.p_iax_iniconnect('AXIS_CSI');
      vnumerr := pac_md_bpm.f_aceptarpropuesta(psseguro, 1, 1, f_sysdate, mensajes);

      IF vnumerr != 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      COMMIT;
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

   FUNCTION f_emitirpropuesta(psseguro IN seguros.sseguro%TYPE, ppoliza OUT VARCHAR2   --,
                                                                                    --mensajes   out t_iax_mensajes
   )
      RETURN NUMBER IS
      vobject        VARCHAR2(500) := 'PAC_IAX_BPM.F_EMITITPROPUESTA';
      vparam         VARCHAR2(500) := 'parámetros - psseguro:' || psseguro;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      mensajes       t_iax_mensajes;   -- !!!!!! Cuando se ponga como parámetro quitar esta variable.
      vcreteni       NUMBER(8);
      vcidioma       seguros.cidioma%TYPE;
      vt_obj         t_iax_impresion := t_iax_impresion();
   BEGIN
      pac_iax_login.p_iax_iniconnect('AXIS_CSI');

      SELECT creteni, cidioma
        INTO vcreteni, vcidioma
        FROM seguros s
       WHERE s.sseguro = psseguro;

      IF vcreteni != 0 THEN
         vnumerr := f_aceptarpropuesta(psseguro);

         IF vnumerr != 0 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
            RAISE e_object_error;
         END IF;
      END IF;

      vnumerr := pac_md_bpm.f_emitirpropuesta(psseguro, 1, ppoliza, mensajes);

      IF vnumerr != 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      vt_obj := pac_iax_impresion.f_get_documprod(psseguro, vcidioma, mensajes);
      COMMIT;
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

   FUNCTION f_rechazarpropuesta(psseguro IN seguros.sseguro%TYPE   --,
                                                                --mensajes   out t_iax_mensajes
   )
      RETURN NUMBER IS
      vobject        VARCHAR2(500) := 'PAC_IAX_BPM.F_RECHAZARPROPUESTA';
      vparam         VARCHAR2(500) := 'parámetros - psseguro:' || psseguro;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      mensajes       t_iax_mensajes;   -- !!!!!! Cuando se ponga como parámetro quitar esta variable.
   BEGIN
      pac_iax_login.p_iax_iniconnect('AXIS_CSI');
      vnumerr := pac_md_bpm.f_rechazarpropuesta(psseguro, 1, 1, 320, 0, 'Propuesta Rechazada',
                                                mensajes);

      IF vnumerr != 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      COMMIT;
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

   -- JLB - OJO: se pasa la prima multiplida por 100 desde el BPM, ya que no he conseguido que coja decimales, los trunca
   FUNCTION f_aceptarsobreprima(psseguro IN NUMBER, pprecarg IN NUMBER   --,
                                                                      --mensajes in OUT T_IAX_MENSAJES
   )
      RETURN NUMBER IS
      vobject        VARCHAR2(500) := 'PAC_IAX_BPM.F_ACEPTARSOBREPRIMA';
      vparam         VARCHAR2(500)
                         := 'parámetros - psseguro:' || psseguro || ' - pprecarg:' || pprecarg;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      mensajes       t_iax_mensajes;   -- !!!!!! Cuando se ponga como parámetro quitar esta variable.
   BEGIN
      pac_iax_login.p_iax_iniconnect('AXIS_CSI');
      -- /100 porque no he conseguido pasar decimales desde el BPM de oracle
      vnumerr := pac_md_bpm.f_aceptarsobreprima(psseguro, 1, 1, f_sysdate, pprecarg / 100,
                                                mensajes);

      IF vnumerr != 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      vnumerr := f_aceptarpropuesta(psseguro);

      IF vnumerr != 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      COMMIT;
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

   FUNCTION f_getpoblacionasegurado(
      psseguro IN NUMBER,
      ppoblac OUT NUMBER,
      pdescprovin OUT VARCHAR2)
      RETURN NUMBER IS
      vobject        VARCHAR2(500) := 'PAC_IAX_BPM.F_getPoblacionAsegurado';
      vparam         VARCHAR2(500) := 'parámetros - psseguro:' || psseguro;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      mensajes       t_iax_mensajes;   -- !!!!!! Cuando se ponga como parámetro quitar esta variable.
   BEGIN
      SELECT p.cprovin, prov.tprovin
        INTO ppoblac, pdescprovin
        FROM tomadores t, per_direcciones p, provincias prov
       WHERE t.sseguro = psseguro
         AND t.nordtom = 1
         AND t.sperson = p.sperson
         AND t.cdomici = p.cdomici
         AND p.cprovin = prov.cprovin;

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
   END f_getpoblacionasegurado;

   FUNCTION f_getcontactotomador(
      psseguro IN NUMBER,
      pemail OUT VARCHAR2,
      ptelfmovil OUT VARCHAR2)
      RETURN NUMBER IS
      vobject        VARCHAR2(500) := 'PAC_IAX_BPM.F_getContactoTomador';
      vparam         VARCHAR2(500) := 'parámetros - psseguro:' || psseguro;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      mensajes       t_iax_mensajes;   -- !!!!!! Cuando se ponga como parámetro quitar esta variable
   BEGIN
      BEGIN
         SELECT tvalcon
           INTO pemail
           FROM tomadores t, per_contactos pc
          WHERE t.sseguro = psseguro
            AND t.nordtom = 1
            AND t.sperson = pc.sperson
            AND pc.ctipcon = 3   -- mail
            AND pc.cmodcon = (SELECT MAX(cmodcon)
                                FROM per_contactos pc2
                               WHERE pc2.sperson = pc.sperson
                                 AND pc2.ctipcon = 3);
      EXCEPTION
         WHEN OTHERS THEN
            pemail := NULL;
      END;

      BEGIN
         SELECT tvalcon
           INTO ptelfmovil
           FROM tomadores t, per_contactos pc
          WHERE t.sseguro = psseguro
            AND t.nordtom = 1
            AND t.sperson = pc.sperson
            AND pc.ctipcon = 6   -- telf movil
            AND pc.cmodcon = (SELECT MAX(cmodcon)
                                FROM per_contactos pc2
                               WHERE pc2.sperson = pc.sperson
                                 AND pc2.ctipcon = 6);
      EXCEPTION
         WHEN OTHERS THEN
            ptelfmovil := NULL;
      END;

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
   END f_getcontactotomador;

   FUNCTION f_informacion_poliza(
      psseguro IN NUMBER,
      pproducto OUT VARCHAR2,
      ptomador OUT VARCHAR2,
      ptelefono OUT VARCHAR2,
      pprima OUT VARCHAR2,
      priesgo OUT VARCHAR2,
      pfefecto OUT VARCHAR2,
      ptipomov OUT VARCHAR2,
      pgarantias OUT VARCHAR2)
      RETURN NUMBER IS
      vobject        VARCHAR2(500) := 'PAC_IAX_BPM.f_informacion_poliza';
      vparam         VARCHAR2(500) := 'parámetros - psseguro:' || psseguro;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      mensajes       t_iax_mensajes;   -- !!!!!! Cuando se ponga como parámetro quitar esta variable
   BEGIN
      pac_iax_login.p_iax_iniconnect('AXIS_CSI');

      SELECT
             /*
             'Propuesta:'||s.npoliza||'.'||CHR(10)||
             --'Solicitud: ||s.nsolici||'.'||CHR(10)||
             'Producto: '|| f_desproducto_t(s.cramo, s.cmodali, s.ctipseg, s.ccolect, 1, 1)||'.'||CHR(10)||
             'Desc. Riesgo: '||f_desriesgo_t(s.sseguro, 1, f_SYSDATE, 1)||'.'||CHR(10)||
             'Fecha efecto: ' || TO_CHAR(s.fefecto, 'DD/MM/YYYY')||'.'||CHR(10)||
             'Fecha vencimiento: '||NVL(TO_CHAR(s.fvencim, 'DD/MM/YYYY'),' ** ')||'.'||CHR(10)||
             'Forma de pago: '||DECODE(s.cforpag,
                    0, 'UNICA',
                    1, 'ANUAL',
                    2, 'SEMESTRAL',
                    3, 'QUATRIMESTRAL',
                    4, 'TRIMESTRAL',
                    12, 'MENSUAL')||'.'||CHR(10)||
             'Prima : '|| to_char(s.iprianu,'FM999G999G999D00')||' € .'||CHR(10)||
             --'Duracion: '||ff_desvalorfijo(20, 1, s.cduraci)||'.'||CHR(10)||
             'Tomador: '|| pac_isqlfor.f_nompersona(t.sperson)||' ' ||pac_isqlfor.f_cognompersona(t.sperson)||' (telf: '||
              pac_isqlfor.f_telefono(t.sperson)||').' --||CHR(10)||
             --'Agente: '||LPAD(s.cagente, 4, '0') || ' - '||pac_isqlfor.f_agente(s.cagente) texto,
             */
             f_desproducto_t(s.cramo, s.cmodali, s.ctipseg, s.ccolect, 1, 1) producto,
             pac_isqlfor.f_nompersona(t.sperson) || ' '
             || pac_isqlfor.f_cognompersona(t.sperson) tomador,
             pac_isqlfor.f_telefono(t.sperson) telefono,
             TO_CHAR(s.iprianu, 'FM999G999G999D00') || '€' prima,
             f_desriesgo_t(s.sseguro, 1, f_sysdate, 1) riesgo,
             TO_CHAR(s.fefecto, 'DD/MM/YYYY') fefecto
        INTO /*ptexto,*/ pproducto,
             ptomador,
             ptelefono,
             pprima,
             priesgo,
             pfefecto
        FROM seguros s, tomadores t
       WHERE s.sseguro = psseguro
         AND s.sseguro = t.sseguro;

      pgarantias := NULL;

      FOR reg IN (SELECT   tgarant || ': '
                           || DECODE(NVL(icapital, 0),
                                     0, f_axis_literales(104619, s.cidioma),
                                     TO_CHAR(icapital, 'FM999G999G999G990D00') || '€')
                                                                                     dgarantia
                      FROM garanseg g, garangen gg, seguros s
                     WHERE g.sseguro = psseguro
                       AND g.sseguro = s.sseguro
                       AND g.cgarant = gg.cgarant
                       AND gg.cidioma = s.cidioma
                       AND g.ffinefe IS NULL
                       AND nriesgo = 1
                  ORDER BY g.cgarant) LOOP
         IF pgarantias IS NOT NULL THEN
            pgarantias := pgarantias || CHR(10);
         END IF;

         pgarantias := pgarantias || reg.dgarantia;
      END LOOP;

      SELECT tmotmov
        INTO ptipomov
        FROM motmovseg mot, movseguro mov, seguros s
       WHERE mot.cmotmov = mov.cmotmov
         AND mot.cidioma = s.cidioma
         AND s.sseguro = psseguro
         AND mov.sseguro = s.sseguro
         AND mov.nmovimi = (SELECT MAX(nmovimi)
                              FROM movseguro
                             WHERE sseguro = psseguro);

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         /*ptexto := 'Información poliza no disponible.';*/
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_informacion_poliza;

   FUNCTION f_ins_reserva(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      pctipres IN NUMBER,
      pcgarant IN NUMBER,
      pccalres IN NUMBER,
      pfmovres IN DATE,
      pcmonres IN VARCHAR2,
      pireserva IN NUMBER,
      pipago IN NUMBER,
      picaprie IN NUMBER,
      pipenali IN NUMBER,
      piingreso IN NUMBER,
      pirecobro IN NUMBER,
      pfresini IN DATE,
      pfresfin IN DATE,
      psidepag IN NUMBER,
      pnmovres IN OUT NUMBER)
      RETURN NUMBER IS
      vobject        VARCHAR2(500) := 'PAC_IAX_BPM.F_ins_reserva';
      vparam         VARCHAR2(500) := 'parámetros - pnsinies:' || pnsinies;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      mensajes       t_iax_mensajes;   -- !!!!!! Cuando se ponga como parámetro quitar esta variable
   BEGIN
      pac_iax_login.p_iax_iniconnect('AXIS_CSI');

      FOR reg IN (SELECT   *
                      FROM sin_tramita_reserva
                     WHERE nsinies = pnsinies
                       AND ntramit = pntramit
                       AND ctipres = pctipres
                  ORDER BY ctipres DESC) LOOP
         vnumerr := pac_siniestros.f_ins_reserva(pnsinies, pntramit, pctipres, reg.cgarant,
                                                 reg.ccalres, reg.fmovres, reg.cmonres,
                                                 pireserva, reg.ipago, reg.icaprie,
                                                 reg.ipenali, reg.iingreso, reg.irecobro,
                                                 reg.fresini, reg.fresfin, reg.fultpag,
                                                 reg.sidepag, reg.iprerec, NULL, pnmovres,
                                                 1   --Bug 31294/174788:NSS:22/05/2014
                                                  );
         EXIT;   -- solo hago uno
      END LOOP;

      COMMIT;
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
   END;

   FUNCTION f_set_citamedica(
      psseguro IN seguros.sseguro%TYPE,
      p_fecha_hora_visita IN VARCHAR2   --,
                                     --mensajes              out t_iax_mensajes
   )
      RETURN NUMBER IS
      vobject        VARCHAR2(500) := 'PAC_IAX_BPM.F_SET_CITAMEDICA';
      vparam         VARCHAR2(500)
         := 'parámetros - psseguro:' || psseguro || ' - p_fecha_hora_visita:'
            || p_fecha_hora_visita;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      mensajes       t_iax_mensajes;   -- !!!!!! Cuando se ponga como parámetro quitar esta variable.
   BEGIN
      pac_iax_login.p_iax_iniconnect('AXIS_CSI');
      vnumerr := pac_md_bpm.f_set_citamedica(psseguro,
                                             TO_DATE(p_fecha_hora_visita,
                                                     'dd/mm/yyyy hh24:mi'),
                                             mensajes);

      IF vnumerr != 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      COMMIT;
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

   FUNCTION f_getdocs(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pfichero1 OUT BLOB,
      pnomfichero1 OUT VARCHAR2,
      pfichero2 OUT BLOB,
      pnomfichero2 OUT VARCHAR2)
      RETURN NUMBER IS
      --vcur           sys_refcursor;
      CURSOR documentos IS
         SELECT   d.sseguro, d.nmovimi, d.iddocgedox
             FROM docummovseg d
            WHERE d.sseguro = psseguro
              AND d.nmovimi = pnmovimi
         ORDER BY d.iddocgedox DESC;

      mensajes       t_iax_mensajes;
      vdoc           VARCHAR2(250);
      vsseguro       NUMBER;
      vnmovimi       NUMBER;
      viddocgedox    NUMBER;
      vfile          BFILE;
      vcount         NUMBER := 0;
      vcpath         VARCHAR2(250);
      vpasexec       NUMBER := 0;
      vsinterf       NUMBER;
      vnumerr        NUMBER;
   BEGIN
      -- vcur := pac_md_produccion.f_get_docmvtpoliza(psseguro, pnmovimi, mensajes);
      vpasexec := 1;
      vcpath := f_parinstalacion_t('GEDOX_DIR');

      OPEN documentos;

      FETCH documentos
       INTO vsseguro, vnmovimi, viddocgedox;

      WHILE documentos%FOUND
       AND vcount < 2 LOOP
         vpasexec := 2;
         vcount := vcount + 1;
         --vdoc := pac_axisgedox.f_get_filedoc(viddocgedox);
         pac_axisgedox.verdoc(viddocgedox, vdoc, vnumerr);
         vpasexec := 3;
         --fichdestino := SUBSTR(vfilename, 1, LENGTH(vfilename) - 3) || 'pdf';
         -- Bug 21458/108087 - 23/02/2012 - AMC
         vnumerr :=
            pac_md_con.f_convertir_documento
                                     ('RTF', 'PDF',
                                      pac_md_common.f_get_parinstalacion_t('INFORMES_SERV')
                                      || '\' || vdoc,
                                      pac_md_common.f_get_parinstalacion_t('INFORMES_SERV')
                                      || '\' || SUBSTR(vdoc, 1, LENGTH(vdoc) - 3) || 'pdf',
                                      NULL, vsinterf, NULL, NULL, NULL, NULL, mensajes);
         -- Fi Bug 21458/108087 - 23/02/2012 - AMC
         vfile := BFILENAME(vcpath, SUBSTR(vdoc, 1, LENGTH(vdoc) - 3) || 'pdf');

         IF vcount = 1 THEN
            pnomfichero1 := pac_axisgedox.f_get_descdoc(viddocgedox);
            DBMS_LOB.createtemporary(pfichero1, TRUE, DBMS_LOB.CALL);
            DBMS_LOB.OPEN(vfile, DBMS_LOB.lob_readonly);
            DBMS_LOB.loadfromfile(pfichero1, vfile, DBMS_LOB.lobmaxsize);
         ELSE
            pnomfichero2 := pac_axisgedox.f_get_descdoc(viddocgedox);
            DBMS_LOB.createtemporary(pfichero2, TRUE, DBMS_LOB.CALL);
            DBMS_LOB.OPEN(vfile, DBMS_LOB.lob_readonly);
            DBMS_LOB.loadfromfile(pfichero2, vfile, DBMS_LOB.lobmaxsize);
         END IF;

         DBMS_LOB.fileclose(vfile);

         FETCH documentos
          INTO vsseguro, vnmovimi, viddocgedox;
      END LOOP;

      vpasexec := 4;

      CLOSE documentos;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         -- BUG -21546_108724- 07/02/2012 - JLTS - Cierre de posibles cursores abiertos
         IF documentos%ISOPEN THEN
            CLOSE documentos;
         END IF;

         p_tab_error(f_sysdate, f_user, 'f_getdocs', 1, SQLCODE, SQLERRM);
         RETURN 1;
   END f_getdocs;
END pac_iax_bpm;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_BPM" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_BPM" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_BPM" TO "PROGRAMADORESCSI";
