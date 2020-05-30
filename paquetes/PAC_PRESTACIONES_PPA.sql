--------------------------------------------------------
--  DDL for Package PAC_PRESTACIONES_PPA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_PRESTACIONES_PPA" AUTHID CURRENT_USER IS
   fecha_ini_fisc DATE := TO_DATE('20070101', 'YYYYMMDD');

   -- RSC 02/04/2008
   FUNCTION frtprest(
      psesion IN NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pcgarant IN NUMBER,
      pccausin IN NUMBER,
      pcmotsin IN NUMBER,
      pprestacion IN NUMBER,
      ptipo IN NUMBER)
      RETURN NUMBER;

   -- RSC 01/04/2008
   FUNCTION f_rt(
      psseguro IN NUMBER,
      pfecha IN DATE,   --Fecha del pago
      psperson IN NUMBER,
      pcgarant IN NUMBER,
      pccausin IN NUMBER,
      pcmotsin IN NUMBER,
      pcapital IN NUMBER,   -- prestaciones pendientes de cobro
      paportsant2007 IN NUMBER,
      pretencion OUT NUMBER,
      preduccion OUT NUMBER,
      pbase OUT NUMBER)
      RETURN NUMBER;

   /*
     RSC 03/04/2008: Función para la obtención del importe de las aportaciones anteriores
     y posteriores al 2006 (< 01/01/2007 y > 31/12/2006). Tiene en cuenta los traspasos
     de salida y los traspasos de entrada, ademas de los movimientos registrados en CTASEGURO
     de la póliza.
   */
   FUNCTION f_pres_ppa(psseguro IN NUMBER, pnparant2007 OUT NUMBER, pnparpos2006 OUT NUMBER)
      RETURN NUMBER;

   FUNCTION f_vivo_o_muerto(psseguro IN NUMBER, pcestado IN NUMBER, pfecha IN DATE)
      RETURN NUMBER;

   FUNCTION frtsialp(
      psesion IN NUMBER,
      psperdes IN NUMBER,
      psproduc IN NUMBER,
      pfsinies IN NUMBER,
      pnsinies IN NUMBER,
      psseguro IN NUMBER)
      RETURN NUMBER;
END;

/

  GRANT EXECUTE ON "AXIS"."PAC_PRESTACIONES_PPA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_PRESTACIONES_PPA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_PRESTACIONES_PPA" TO "PROGRAMADORESCSI";
