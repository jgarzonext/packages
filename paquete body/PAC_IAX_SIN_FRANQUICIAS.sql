--------------------------------------------------------
--  DDL for Package Body PAC_IAX_SIN_FRANQUICIAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IAX_SIN_FRANQUICIAS" AS
/******************************************************************************
   NOMBRE    : PAC_IAX_SIN_FRANQUICIAS
   ARCHIVO   : PAC_IAX_SIN_FRANQUICIAS.sql
   PROPÓSITO : Package con funciones propias de la funcionalidad de Franquicias en siniestros

   REVISIONES:
   Ver    Fecha      Autor     Descripción
   ------ ---------- --------- ------------------------------------------------
   1.0    22-01-2014  NSS      Creación del package.
******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   FUNCTION f_fran_tot(
      p_sseguro IN NUMBER,
      p_nmovimi IN NUMBER,
      p_nriesgo IN NUMBER,
      p_cgarant IN NUMBER,
      p_importe IN NUMBER,
      p_fecha IN DATE,
      p_ifranq OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(100) := '';
      vnumerr        NUMBER(8) := 0;
      vobjectname    VARCHAR2(200) := 'PAC_IAX_SINIESTROS.f_fran_tot';
   BEGIN
      vnumerr := pac_md_sin_franquicias.f_fran_tot(p_sseguro, p_nmovimi, p_nriesgo, p_cgarant,
                                                   p_importe, p_fecha, p_ifranq, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      vpasexec := 6;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_fran_tot;
END pac_iax_sin_franquicias;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_SIN_FRANQUICIAS" TO "PROGRAMADORESCSI";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_SIN_FRANQUICIAS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_SIN_FRANQUICIAS" TO "CONF_DWH";
