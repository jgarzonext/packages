--------------------------------------------------------
--  DDL for Package PAC_RESCATES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_RESCATES" AUTHID CURRENT_USER AS
/*****************************************************************************
   NAME:       PAC_RESCATES
   PURPOSE:    Funciones de rescates para productos financieros

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   4.0       09/07/2008   ICV             1. Modificació Bug.: 10615 - Revisió de la parametrització d'accions
   5.0       22/01/2010   RSC             5. 0012822 - CEM: RT - Tratamiento fiscal rentas a 2 cabezas
******************************************************************************/

   -- RSC 12/12/2007
   FUNCTION f_tratar_sinies_fallec(psseguro IN NUMBER, pfrescat IN DATE)
      RETURN NUMBER;

   FUNCTION f_vivo_o_muerto(psseguro IN NUMBER, pcestado IN NUMBER, pfecha IN DATE)
      RETURN NUMBER;

   FUNCTION f_simulacion_rescate(
      psseguro IN NUMBER,
      pcagente IN NUMBER,
      pccausin IN NUMBER,
      pimport IN NUMBER,
      pfecha IN DATE,
      res OUT pk_cal_sini.t_val)
      RETURN NUMBER;

   FUNCTION f_sol_rescate(
      psseguro IN NUMBER,
      psproduc IN NUMBER,
      pcmoneda IN NUMBER,
      pcagente IN NUMBER,
      pcidioma IN NUMBER,
      pccausin IN NUMBER,
      pimport IN NUMBER,
      pfecha IN DATE,
      pipenali IN NUMBER,
      pireduc IN NUMBER,
      pireten IN NUMBER,
      pirendi IN NUMBER,
      pnivel IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_es_rescatable(
      psseguro IN NUMBER,
      pfmovimi IN DATE,
      pccausin IN NUMBER,
      pirescate IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_sit_rescate(psseguro IN NUMBER, pnmovimi IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_rescate_total_abierto(psseguro IN NUMBER, pabierto IN OUT NUMBER)
      RETURN NUMBER;

   FUNCTION f_retencion_simulada(
      psesion IN NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pcgarant IN NUMBER,
      pfefecto IN DATE,
      pfrescat IN DATE,
      pctipres IN NUMBER,
      pirescate IN NUMBER,
      pipenali IN NUMBER,
      pmoneda IN NUMBER,
      pireten OUT NUMBER,
      pireduc OUT NUMBER,
      pirendi OUT NUMBER)
      RETURN NUMBER;

   FUNCTION f_finaliza_rescate(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnsinies IN NUMBER,
      pmoneda IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_distribuye_ctaseguro(
      psseguro IN NUMBER,
      xnnumlin IN OUT NUMBER,
      fcuenta IN DATE,
      pxcmovimi IN NUMBER,
      pivalora IN NUMBER,
      seqgrupo IN NUMBER,
      pnsinies IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_distribuye_ctaseguro_shw(
      psseguro IN NUMBER,
      xnnumlin IN OUT NUMBER,
      fcuenta IN DATE,
      pxcmovimi IN NUMBER,
      pivalora IN NUMBER,
      seqgrupo IN NUMBER,
      pnsinies IN NUMBER)
      RETURN NUMBER;

   --Bug.: 10615 - 09/07/2009 - ICV - Revisió de la parametrització d'accions (Se añade el paso del importe)
   FUNCTION f_valida_permite_rescate(
      psseguro IN NUMBER,
      pcagente IN NUMBER,
      pfrescate IN DATE,
      pccausin IN NUMBER,
      pimporte IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

   FUNCTION f_avisos_rescates(
      psseguro IN NUMBER,
      pfrescate IN DATE,
      pirescate IN NUMBER,
      cavis OUT NUMBER,
      pdatos OUT NUMBER)
      RETURN NUMBER;

   -- Bug 12822 - RSC - 22/01/2010 - CEM - RT - Tratamiento fiscal rentas a 2 cabezas
   FUNCTION f_quien_muerto(psseguro IN NUMBER, pfecha IN DATE)
      RETURN NUMBER;
-- Fin Bug 12822
END pac_rescates;

/

  GRANT EXECUTE ON "AXIS"."PAC_RESCATES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_RESCATES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_RESCATES" TO "PROGRAMADORESCSI";
