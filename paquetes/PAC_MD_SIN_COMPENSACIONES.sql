--------------------------------------------------------
--  DDL for Package PAC_MD_SIN_COMPENSACIONES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_MD_SIN_COMPENSACIONES" IS
/******************************************************************************
   NOMBRE    : PAC_MD_SIN_COMPENSACIONES
   ARCHIVO   : PAC_MD_SIN_COMPENSACIONES.pks
   PROP¿SITO : Package con funciones propias de la funcionalidad de Compensaciones en siniestros

REVISIONES:
   Ver    Fecha       Autor     Descripci¿n
   ------ ----------  --------- ------------------------------------------------
   1.0    22-01-2014  JTT       Creaci¿n del package.
******************************************************************************/
--   FUNCTION f_valida_compensacion_reserva(
--      psseguro IN seguros.sseguro%TYPE,
--      pnriesgo IN sin_siniestro.nriesgo%TYPE,
--      pnsinies IN sin_siniestro.nsinies%TYPE,
--      pidres IN sin_tramita_reserva.idres%TYPE,
--      ptlitera OUT axis_literales.tlitera%TYPE,
--      mensajes IN OUT t_iax_mensajes)
--      RETURN NUMBER;

   FUNCTION f_compensa_reserva_pagosaut(
      psseguro IN seguros.sseguro%TYPE,
      pnriesgo IN sin_siniestro.nriesgo%TYPE,
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pntramit IN sin_tramitacion.ntramit%TYPE,
      pidres IN sin_tramita_reserva.idres%TYPE,
      ptlitera OUT axis_literales.tlitera%TYPE,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_valida_siniestro_muerte(
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pexisten OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_valida_reserva_noindem(
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pexisten OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_cartera_pendiente(
      psseguro IN seguros.sseguro%TYPE,
      pnriesgo IN sin_siniestro.nriesgo%TYPE,
      ptotal OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;
END pac_md_sin_compensaciones;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_SIN_COMPENSACIONES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_SIN_COMPENSACIONES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_SIN_COMPENSACIONES" TO "PROGRAMADORESCSI";
