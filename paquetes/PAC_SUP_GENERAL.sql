--------------------------------------------------------
--  DDL for Package PAC_SUP_GENERAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_SUP_GENERAL" AUTHID CURRENT_USER IS
/******************************************************************************
 NAME:       PAC_SUP_GENERAL
 PURPOSE:    Contiene las funciones necesarias para realizar un suplemento

 REVISIONS:
 Ver        Date        Author           Description
 ---------  ----------  ---------------  ------------------------------------
 1.0        29/05/2009  RSC              1. Created this package body.
 2.0        04/11/20010 APD              2. 16095: Implementacion y parametrizacion producto GROUPLIFE
 3.0        28/05/2013  NSS              3. 0026962: LCOL_S010-SIN - Autos - Acciones iniciar/terminar siniestro
 4.0        09/07/2013  JRH              4. 0027279: Cargas ARL
 5.0        18/02/2014  ETM              5.0029943: POSRA200 - Gaps 27,28 Anexos de PU en VI
 6.0        14/07/2014  JTT              6. 0026472: Nueva funcion f_marcar_excluir_garantia
 7.0        30/06/2015  AFM              7. 0034462/208987: Se incorpora nueva función
******************************************************************************/
   FUNCTION iniciarsuple
      RETURN NUMBER;

   FUNCTION f_supl_generico(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pfecha IN DATE,
      pcmotmov IN NUMBER,
      pcgarant IN NUMBER,
      pnmovimi OUT NUMBER,
      psproces IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_supl_vto_garantia(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pfecha IN DATE,
      pcmotmov IN NUMBER,
      pcgarant IN NUMBER,
      pnmovimi OUT NUMBER,
      psproces IN NUMBER,
      ptarifa IN NUMBER DEFAULT 0)
      RETURN NUMBER;

   -- Bug 16095 - APD - 04/11/2010
   -- se crea la funcion f_supl_renova_garantia
   FUNCTION f_supl_renova_garantia(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pfecha IN DATE,
      pcmotmov IN NUMBER,
      pcgarant IN NUMBER,
      pnmovimi OUT NUMBER,
      psproces IN NUMBER)
      RETURN NUMBER;

-- Fin Bug 16095 - APD - 04/11/2010
   FUNCTION f_supl_exonera(   -- creacion bug 19416:ASN:28/10/2011
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pfecha IN DATE,
      pcmotmov IN NUMBER,
      pnmovimi OUT NUMBER,
      psproces IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_reduce_capital(   -- creacion bug 21131:ASN:09/02/2012
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pfecha IN DATE,
      pcmotmov IN NUMBER,
      pcgarant IN NUMBER,
      pivalora IN NUMBER,
      pnmovimi OUT NUMBER,
      psproces IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_revalorizacion_poliza(   -- creacion bug 26962:NSS:22/05/2013
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pfecha IN DATE,
      pcmotmov IN NUMBER,
      pcgarant IN NUMBER,
      pivalora IN NUMBER,
      pnmovimi OUT NUMBER,
      psproces IN NUMBER)
      RETURN NUMBER;

   --Bug 0021686 - JRH - 10/07/2013 - 0027279: POS  - Carga ARL
   FUNCTION f_suplemento_factuacion(   -- creacion bug 27279:JRH:09/02/2012
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pfecha IN DATE,
      pcmotmov IN NUMBER,
      pcgarant IN NUMBER,
      pibruto IN NUMBER,
      pineto IN NUMBER,
      pnmovimi OUT NUMBER,
      pnrecibo OUT NUMBER,
      psproces IN NUMBER)
      RETURN NUMBER;

--Fin Bug 0021686 - JRH - 10/07/2013
   FUNCTION f_baja_asegurado(   --  bug 26472/165729:NSS:11/02/2014
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pfecha IN DATE,
      pssegpol IN NUMBER,
      pcnotibaja IN NUMBER DEFAULT NULL,
      pcmotmov IN NUMBER DEFAULT NULL,
      psproces IN NUMBER)
      RETURN NUMBER;

--Bug 29943/0166559 -ETM- 18/02/2014--INI
   FUNCTION f_suplemento_pu(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pfecha IN DATE,
      pcmotmov IN NUMBER,
      pcgarant IN NUMBER,
      pibruto IN NUMBER,
      pdetalle IN BOOLEAN,
      pnmovimi OUT NUMBER,
      psproces IN NUMBER)
      RETURN NUMBER;

--FIN -29943/0166559 -ETM- 18/02/2014--
   FUNCTION f_marcar_excluir_garantia(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pcgarant IN NUMBER,
      pnmovimi IN NUMBER)
      RETURN NUMBER;

   --JRH 02/2015 Convenios
   FUNCTION f_cambio_verscon(
      psseguro IN NUMBER,
      pfecha IN DATE,
      pcmotmov IN NUMBER,
      pnmovimi OUT NUMBER,
      psproces IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_borrar_garantia(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      pcgarant IN NUMBER)
      RETURN NUMBER;

   -- 0034462/208987. AFM
   FUNCTION f_cambio_aut_numaseg(
      psseguro IN NUMBER)
      RETURN NUMBER;

END pac_sup_general;

/

  GRANT EXECUTE ON "AXIS"."PAC_SUP_GENERAL" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_SUP_GENERAL" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_SUP_GENERAL" TO "PROGRAMADORESCSI";
