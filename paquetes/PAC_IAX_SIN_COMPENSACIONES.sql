--------------------------------------------------------
--  DDL for Package PAC_IAX_SIN_COMPENSACIONES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_IAX_SIN_COMPENSACIONES" IS
/******************************************************************************
   NOMBRE    : PAC_IAX_SIN_COMPENSACIONES
   ARCHIVO   : PAC_IAX_SIN_COMPENSACIONES.pks
   PROP¿SITO : Package con funciones propias de la funcionalidad de Comensaciones en siniestros

REVISIONES:
   Ver    Fecha       Autor     Descripci¿n
   ------ ----------  --------- ------------------------------------------------
   1.0    22-01-2014  JTT       Creaci¿n del package.
******************************************************************************/
   FUNCTION f_valida_compensacion_reserva(
      psseguro IN seguros.sseguro%TYPE,
      pnriesgo IN sin_siniestro.nriesgo%TYPE,
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pidres IN sin_tramita_reserva.idres%TYPE,
      ptlitera OUT axis_literales.tlitera%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_compensa_reserva_pagosaut(
      psseguro IN seguros.sseguro%TYPE,
      pnriesgo IN sin_siniestro.nriesgo%TYPE,
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pntramit IN sin_tramitacion.ntramit%TYPE,
      pidres IN sin_tramita_reserva.idres%TYPE,
      ptlitera OUT axis_literales.tlitera%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;
END pac_iax_sin_compensaciones;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_SIN_COMPENSACIONES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_SIN_COMPENSACIONES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_SIN_COMPENSACIONES" TO "PROGRAMADORESCSI";
