--------------------------------------------------------
--  DDL for Package PAC_SIN_COMPENSACIONES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_SIN_COMPENSACIONES" IS
/******************************************************************************
   NOMBRE    : PAC_SIN_COMPENSACIONES
   ARCHIVO   : PAC_SIN_COMPENSACIONES.pks
   PROPÓSITO : Package con funciones propias de la funcionalidad de Comensaciones en siniestros

REVISIONES:
   Ver    Fecha       Autor     Descripción
   ------ ----------  --------- ------------------------------------------------
   1.0    22-01-2014  JTT       Creación del package.
******************************************************************************/
   FUNCTION f_valida_siniestro_muerte(
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pexisten IN OUT NUMBER)
      RETURN NUMBER;

   FUNCTION f_valida_reserva_noindem(
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pexisten IN OUT NUMBER)
      RETURN NUMBER;

   FUNCTION f_crear_pago_compensatorio_cia(
      pnsinies IN sin_tramita_reserva.nsinies%TYPE,
      pidres IN sin_tramita_reserva.idres%TYPE,
      pipago IN NUMBER,
      psperson IN sin_tramita_destinatario.sperson%TYPE,
      psidepag_nou OUT sin_tramita_pago.sidepag%TYPE,
      psseguro IN seguros.sseguro%TYPE,
      pnrecibo IN recibos.nrecibo%TYPE,
      pcestcomp IN sin_recibos_compensados.cestcomp%TYPE)
      RETURN NUMBER;

   FUNCTION f_recibos_no_emitidos(
      psseguro IN seguros.sseguro%TYPE,
      pnrecfut OUT NUMBER,
      pirecfut OUT NUMBER)
      RETURN NUMBER;

   FUNCTION f_reducir_reserva(
      pnsinies IN sin_tramita_reserva.nsinies%TYPE,
      pidres IN sin_tramita_reserva.idres%TYPE,
      pimporte IN NUMBER,
      pcmovres IN sin_tramita_reserva.cmovres%TYPE DEFAULT 3)
      RETURN NUMBER;
END pac_sin_compensaciones;

/

  GRANT EXECUTE ON "AXIS"."PAC_SIN_COMPENSACIONES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_SIN_COMPENSACIONES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_SIN_COMPENSACIONES" TO "PROGRAMADORESCSI";
