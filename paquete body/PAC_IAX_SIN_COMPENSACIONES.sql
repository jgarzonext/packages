--------------------------------------------------------
--  DDL for Package Body PAC_IAX_SIN_COMPENSACIONES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IAX_SIN_COMPENSACIONES" AS
/******************************************************************************
   NOMBRE    : PAC_IAX_SIN_COMPENSACIONES
   ARCHIVO   : PAC_IAX_SIN_COMPENSACIONES.pkb
   PROP¿SITO : Package con funciones propias de la funcionalidad de Compensaciones en siniestros

REVISIONES:
   Ver    Fecha       Autor     Descripci¿n
   ------ ----------  --------- ------------------------------------------------
   1.0    22-01-2014  JTT       Creaci¿n del package.
******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;
   e_error        EXCEPTION;

   FUNCTION f_valida_compensacion_reserva(
      psseguro IN seguros.sseguro%TYPE,
      pnriesgo IN sin_siniestro.nriesgo%TYPE,
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pidres IN sin_tramita_reserva.idres%TYPE,
      ptlitera OUT axis_literales.tlitera%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500)
                                 := 'PAC_IAX_SIN_COMPENSACIONES.f_valida_compensacion_reserva';
      vparam         VARCHAR2(500)
         := ' psseguro = ' || psseguro || ' priesgo = ' || pnriesgo || ' pnsinies = '
            || pnsinies || ' pidres = ' || pidres;
      vpasexec       NUMBER := 1;
      vnumerr        NUMBER := 0;
      vexisten       NUMBER;
      vtotal_cartera NUMBER;
   BEGIN
      IF psseguro IS NULL
         OR pnriesgo IS NULL
         OR pnsinies IS NULL
         OR pidres IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_sin_compensaciones.f_valida_siniestro_muerte(pnsinies, vexisten,
                                                                     mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_error;
      END IF;

      IF NVL(vexisten, 0) > 0 THEN
         vnumerr := pac_md_sin_compensaciones.f_valida_reserva_noindem(pnsinies, vexisten,
                                                                       mensajes);

         IF vnumerr <> 0 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
            RAISE e_error;
         END IF;

         IF NVL(vexisten, 0) = 0 THEN
            vnumerr := pac_md_siniestros.f_valida_exist_recib_remesados(psseguro, vexisten,
                                                                        mensajes);

            IF vnumerr <> 0 THEN
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
               RAISE e_error;
            END IF;

            IF NVL(vexisten, 0) = 0 THEN
               vnumerr := pac_md_sin_compensaciones.f_get_cartera_pendiente(psseguro,
                                                                            pnriesgo,
                                                                            vtotal_cartera,
                                                                            mensajes);

               IF vnumerr <> 0 THEN
                  RAISE e_error;
               END IF;
            END IF;
         END IF;

         IF vtotal_cartera > 0 THEN
            ptlitera := f_axis_literales(9906504, pac_md_common.f_get_cxtidioma());
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN e_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, vnumerr, vpasexec, vparam,
                                           ' Error = ' || vnumerr);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_valida_compensacion_reserva;

   FUNCTION f_compensa_reserva_pagosaut(
      psseguro IN seguros.sseguro%TYPE,
      pnriesgo IN sin_siniestro.nriesgo%TYPE,
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pntramit IN sin_tramitacion.ntramit%TYPE,
      pidres IN sin_tramita_reserva.idres%TYPE,
      ptlitera OUT axis_literales.tlitera%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_IAX_SIN_COMPENSACIONES.f_compensa_reserva_pagosaut';
      vparam         VARCHAR2(500)
         := ' psseguro = ' || psseguro || ' priesgo = ' || pnriesgo || ' pnsinies = '
            || pnsinies || ' pidres = ' || pidres;
      vpasexec       NUMBER := 1;
      vnumerr        NUMBER := 0;
   BEGIN
      IF psseguro IS NULL
         OR pnriesgo IS NULL
         OR pnsinies IS NULL
         OR pntramit IS NULL
         OR pidres IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF pac_iax_siniestros.vgobsiniestro IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_sin_compensaciones.f_compensa_reserva_pagosaut(psseguro, pnriesgo,
                                                                       pnsinies, pntramit,
                                                                       pidres, ptlitera,
                                                                       mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_error;
      END IF;

      COMMIT;
      vnumerr :=
         pac_md_siniestros.f_get_tramitaciones(pnsinies,
                                               pac_iax_siniestros.vgobsiniestro.tramitaciones,
                                               mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, vnumerr, vpasexec, vparam,
                                           ' Error = ' || vnumerr);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_compensa_reserva_pagosaut;
END pac_iax_sin_compensaciones;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_SIN_COMPENSACIONES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_SIN_COMPENSACIONES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_SIN_COMPENSACIONES" TO "PROGRAMADORESCSI";
