--------------------------------------------------------
--  DDL for Package Body PAC_MD_SIN_COMPENSACIONES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MD_SIN_COMPENSACIONES" AS
/******************************************************************************
   NOMBRE    : PAC_MD_SIN_COMPENSACIONES
   ARCHIVO   : PAC_MD_SIN_COMPENSACIONES.pkb
   PROP¿SITO : Package con funciones propias de la funcionalidad de Compensaciones en siniestros

REVISIONES:
   Ver    Fecha       Autor     Descripci¿n
   ------ ----------  --------- ------------------------------------------------
   1.0    22-01-2014  JTT       Creaci¿n del package.
   2.0    20/03/2015  JTT       0033798/0200603: Compensaci¿n de pagos vs cartera
   3.0    19/05/2015  JTT       0033798/0201888: Compensacion de pagos vs cartera - Recibos agrupados
******************************************************************************/
   e_param_error  EXCEPTION;
   e_error        EXCEPTION;

   /*
      El proceso de compensaci¿n de cartera con los pagos consta de dos pasos

      1.- Compensamos los recibos emitidos generando pagos a la CIA por el importe de los recibos
      pendientes de cobrar

      2.- Compensamos los recibos NO emtidos con la reserva, disminuyendo la reserva.
   */
   FUNCTION f_compensa_reserva_pagosaut(
      psseguro IN seguros.sseguro%TYPE,
      pnriesgo IN sin_siniestro.nriesgo%TYPE,
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pntramit IN sin_tramitacion.ntramit%TYPE,
      pidres IN sin_tramita_reserva.idres%TYPE,
      ptlitera OUT axis_literales.tlitera%TYPE,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_SIN_COMPENSACIONES.f_compensa_reserva_pagosaut';
      vparam         VARCHAR2(500)
         := ' psseguro = ' || psseguro || ' pnriesgo = ' || pnriesgo || ' pnsinies = '
            || pnsinies || ' pntramit = ' || pntramit || ' pidres = ' || pidres;
      vpasexec       NUMBER := 1;
      vnumerr        NUMBER := 0;
      cur            sys_refcursor;
      vquery         VARCHAR2(5000);
      vreserva       sin_tramita_reserva%ROWTYPE;
      vnrecibo       recibos.nrecibo%TYPE;
      vfefecto       recibos.fefecto%TYPE;
      vccobban       recibos.ccobban%TYPE;
      vcdelega       recibos.cdelega%TYPE;
      vcestaux       recibos.cestaux%TYPE;
      vitotrec       NUMBER;
      virestorec     sin_recibos_compensados.irestorec%TYPE;
      vcestcomp      sin_recibos_compensados.cestcomp%TYPE;
      vsperson       per_personas.sperson%TYPE;
      vsidepag       sin_tramita_pago.sidepag%TYPE;
      vnrecfut       NUMBER;
      virecfut       NUMBER;
      vtimport       VARCHAR(50);
      vcontinue      BOOLEAN;
   BEGIN
      IF psseguro IS NULL
         OR pnriesgo IS NULL
         OR pnsinies IS NULL
         OR pntramit IS NULL
         OR pidres IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      -- Obtenemos todos los recibos pendientes
      vnumerr := pac_siniestros.f_get_cartera_pendiente(psseguro, pnriesgo, vquery);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_error;
      END IF;

      cur := pac_iax_listvalores.f_opencursor(vquery, mensajes);
      vpasexec := 3;

      -- Para cada uno de los recibos pendientes
      LOOP
         FETCH cur
          INTO vnrecibo, vfefecto, vccobban, vcdelega, vitotrec, virestorec, vcestcomp,
               vcestaux;

         EXIT WHEN cur%NOTFOUND;
         vpasexec := 4;
         vnumerr := pac_siniestros.f_getrow_reserva(pnsinies, pidres, vreserva);

         IF vnumerr <> 0 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
            RAISE e_error;
         END IF;

         vcontinue := FALSE;

         -- Bug 33798 - JTT - 19/05/2015: El campo RECIBOS.cestaux indica si el estado de envio del recibo.
         -- Si RECIBOS.cestaux = 0 --> Recibo enviado, se puede compensar
         -- Si RECIBOS.cestaux = 2 --> Recibo agrupado, consultamos si el recibo 'padre' que los agrupa ha sido enviado.
         -- Recibos con otros valores no se gestionan, no han sido enviados.
         IF vcestaux = 0 THEN   -- Recibos enviados
            vcontinue := TRUE;
         ELSIF vcestaux = 2 THEN   -- Recibos agrupados
            BEGIN
               -- Recuperamos el n¿mero de recibo 'padre'  y actualizamos el num recibo a tratar (vnrecibo)
               SELECT r.nrecibo
                 INTO vnrecibo
                 FROM adm_recunif u, recibos r
                WHERE r.nrecibo = u.nrecunif
                  AND r.cestaux = 0
                  AND u.nrecibo = vnrecibo;

               vcontinue := TRUE;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  NULL;
            END;
         END IF;

         IF vcontinue THEN
            IF vreserva.ireserva >= vitotrec THEN
               -- Creamos el destinatario del pago (Compa¿ia)
               vpasexec := 5;
               vnumerr :=
                  pac_siniestros.f_destinatario_empresa(pnsinies, pntramit,
                                                        pac_md_common.f_get_cxtempresa(),
                                                        vsperson);

               IF vnumerr <> 0 THEN
                  RAISE e_error;
               END IF;

               vpasexec := 6;
               vnumerr := pac_sin_compensaciones.f_crear_pago_compensatorio_cia(pnsinies,
                                                                                pidres,
                                                                                vitotrec,
                                                                                vsperson,
                                                                                vsidepag,
                                                                                psseguro,
                                                                                vnrecibo, 'C');

               IF vnumerr <> 0 THEN
                  RAISE e_error;
               END IF;
            END IF;
         END IF;
      END LOOP;

      ptlitera := f_axis_literales(9907546);
      vpasexec := 7;
      vnumerr := pac_sin_compensaciones.f_recibos_no_emitidos(psseguro, vnrecfut, virecfut);

      IF vnumerr <> 0 THEN
         RAISE e_error;
      END IF;

      IF virecfut > 0 THEN
         vpasexec := 8;
         vnumerr := pac_siniestros.f_getrow_reserva(pnsinies, pidres, vreserva);

         IF vnumerr <> 0 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
            RAISE e_error;
         END IF;

         IF vreserva.ireserva > virecfut THEN
            vpasexec := 9;
            vnumerr := pac_sin_compensaciones.f_reducir_reserva(pnsinies, pidres, virecfut,
                                                                25);

            IF vnumerr <> 0 THEN
               IF vnumerr = 9907545 THEN
                  ptlitera := ptlitera || '\n' || f_axis_literales(9907545);
               ELSE
                  RAISE e_error;
               END IF;
            END IF;
         END IF;

         IF virecfut > 0 THEN
            SELECT REPLACE(TO_CHAR(virecfut, '999G999G999G990D99'),
                           'nls_numeric_characters=,.')
              INTO vtimport
              FROM DUAL;

            ptlitera := ptlitera || '\n' || f_axis_literales(9907547) || ' ' || LTRIM(vtimport);
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, vnumerr, vpasexec, vparam,
                                           ' Error = ' || vnumerr);
         ptlitera := NULL;
         RETURN vnumerr;
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 9000505, vpasexec, vparam);
         ptlitera := NULL;
         RETURN 9000505;   -- Error faltan parametros
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000455, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         ptlitera := NULL;
         RETURN 1000455;   -- Error no controlado
   END f_compensa_reserva_pagosaut;

   FUNCTION f_valida_siniestro_muerte(
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pexisten OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_SIN_COMPENSACIONES.f_valida_siniestro_muerte';
      vparam         VARCHAR2(500) := ' pnsinies = ' || pnsinies;
      vpasexec       NUMBER := 1;
      vnumerr        NUMBER := 0;
   BEGIN
      IF pnsinies IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_sin_compensaciones.f_valida_siniestro_muerte(pnsinies, pexisten);

      IF vnumerr > 0 THEN
         RAISE e_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_error THEN
         --pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, vnumerr, vpasexec, vparam,
                                           ' Error = ' || vnumerr);
         RETURN vnumerr;
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 9000505, vpasexec, vparam);
         RETURN 9000505;   -- Error faltan parametros
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000455, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1000455;   -- Error no controlado
   END f_valida_siniestro_muerte;

   FUNCTION f_valida_reserva_noindem(
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pexisten OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_SIN_COMPENSACIONES.f_valida_reserva_noindem';
      vparam         VARCHAR2(500) := ' pnsinies = ' || pnsinies;
      vpasexec       NUMBER := 1;
      vnumerr        NUMBER := 0;
   BEGIN
      IF pnsinies IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_sin_compensaciones.f_valida_reserva_noindem(pnsinies, pexisten);

      IF vnumerr > 0 THEN
         RAISE e_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, vnumerr, vpasexec, vparam,
                                           ' Error = ' || vnumerr);
         RETURN vnumerr;
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 9000505, vpasexec, vparam);
         RETURN 9000505;   -- Error faltan parametros
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000455, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1000455;   -- Error no controlado
   END f_valida_reserva_noindem;

   FUNCTION f_get_cartera_pendiente(
      psseguro IN seguros.sseguro%TYPE,
      pnriesgo IN sin_siniestro.nriesgo%TYPE,
      ptotal OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_SIN_COMPENSACIONES.f_get_cartera_pendiente';
      vparam         VARCHAR2(500) := ' psseguro = ' || psseguro || ' pnriesgo = ' || pnriesgo;
      vpasexec       NUMBER := 1;
      vnumerr        NUMBER := 0;
      cur            sys_refcursor;
      vquery         VARCHAR2(5000);
      vdias_gracia   NUMBER;
      vnrecibo       recibos.nrecibo%TYPE;
      vfefecto       recibos.fefecto%TYPE;
      vccobban       recibos.ccobban%TYPE;
      vcdelega       recibos.cdelega%TYPE;
      vitotrec       vdetrecibos.itotalr%TYPE;
      virestorec     sin_recibos_compensados.irestorec%TYPE;
      vcestcomp      sin_recibos_compensados.cestcomp%TYPE;
      vcestaux       recibos.cestaux%TYPE;
      v_recunif_nrecibo recibos.nrecibo%TYPE;
      v_recunif_cestaux recibos.cestaux%TYPE;
      vcontinue      BOOLEAN;
   BEGIN
      IF psseguro IS NULL
         OR pnriesgo IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_siniestros.f_get_cartera_pendiente(psseguro, pnriesgo, vquery);

      IF vnumerr <> 0 THEN
         RAISE e_error;
      END IF;

      vpasexec := 2;
      cur := pac_iax_listvalores.f_opencursor(vquery, mensajes);
      vpasexec := 3;
      ptotal := 0;

      LOOP
         FETCH cur
          INTO vnrecibo, vfefecto, vccobban, vcdelega, vitotrec, virestorec, vcestcomp,
               vcestaux;

         EXIT WHEN cur%NOTFOUND;
         -- Bug 33798 - JTT - 20/03/2015: Eliminamos la validaci¿n de los dias de gracia de los recibos
         vcontinue := FALSE;

         -- Bug 33798 - JTT - 19/05/2015: El campo RECIBOS.cestaux indica si el estado de envio del recibo.
         -- Si RECIBOS.cestaux = 0 --> Recibo enviado, se puede compensar
         -- Si RECIBOS.cestaux = 2 --> Recibo agrupado, consultamos si el recibo 'padre' que los agrupa ha sido enviado.
         -- Recibos con otros valores no se gestionan, no han sido enviados.
         IF vcestaux = 0 THEN   -- Recibos enviados
            vcontinue := TRUE;
         ELSIF vcestaux = 2 THEN   -- Recibos agrupados
            BEGIN
               -- Recuperamos el n¿mero de recibo 'padre' y actualizamos el num recibo a tratar (vnrecibo)
               SELECT r.nrecibo, r.cestaux
                 INTO v_recunif_nrecibo, v_recunif_cestaux
                 FROM adm_recunif u, recibos r
                WHERE r.nrecibo = u.nrecunif
                  AND r.cestaux = 0
                  AND u.nrecibo = vnrecibo;

               vcontinue := TRUE;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  NULL;
            END;
         END IF;

         IF vcontinue THEN
            -- Acumulamos para obtener el total de los recibos
            ptotal := ptotal + vitotrec;
         END IF;
      END LOOP;

      RETURN 0;
   EXCEPTION
      WHEN e_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, vnumerr, vpasexec, vparam,
                                           ' Error = ' || vnumerr);
         RETURN vnumerr;
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 9000505, vpasexec, vparam);
         RETURN 9000505;   -- Error faltan parametros
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000455, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1000455;   -- Error no controlado
   END f_get_cartera_pendiente;
END pac_md_sin_compensaciones;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_SIN_COMPENSACIONES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_SIN_COMPENSACIONES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_SIN_COMPENSACIONES" TO "PROGRAMADORESCSI";
