--------------------------------------------------------
--  DDL for Package PAC_MD_SIN_FRANQUICIAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_MD_SIN_FRANQUICIAS" IS
/******************************************************************************
   NOMBRE    : PAC_MD_SIN_FRANQUICIAS
   ARCHIVO   : PAC_MD_SIN_FRANQUICIAS.sql
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
	  
	  /*calcular deducible IFRANQ  para realizar un pago
      f_calcular_deducible 
      ANB: 30/07/2019
      */
        FUNCTION f_calcular_deducible(
        psseguro IN NUMBER,
		pnriesgo IN  NUMBER,
		pcgarant IN NUMBER,
		isinret IN NUMBER,
        p_nmovimi IN NUMBER,
		ifranqui OUT NUMBER,
        mensajes OUT t_iax_mensajes)
        RETURN NUMBER;
END pac_md_sin_franquicias;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_SIN_FRANQUICIAS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_SIN_FRANQUICIAS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_SIN_FRANQUICIAS" TO "PROGRAMADORESCSI";
