--------------------------------------------------------
--  DDL for Package PAC_IAX_SIN_FRANQUICIAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_IAX_SIN_FRANQUICIAS" IS
/******************************************************************************
   NOMBRE    : PAC_IAX_SIN_FRANQUICIAS
   ARCHIVO   : PAC_IAX_SIN_FRANQUICIAS.sql
   PROPÓSITO : Package con funciones propias de la funcionalidad de Franquicias en siniestros

   REVISIONES:
   Ver    Fecha      Autor     Descripción
   ------ ---------- --------- ------------------------------------------------
   1.0    22-01-2014  NSS      Creación del package.
******************************************************************************/
   FUNCTION f_fran_tot(
      p_sseguro IN NUMBER,
      p_nmovimi IN NUMBER,
      p_nriesgo IN NUMBER,
      p_cgarant IN NUMBER,
      p_importe IN NUMBER,
      p_fecha IN DATE,
      p_ifranq OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;
END pac_iax_sin_franquicias;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_SIN_FRANQUICIAS" TO "PROGRAMADORESCSI";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_SIN_FRANQUICIAS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_SIN_FRANQUICIAS" TO "CONF_DWH";
