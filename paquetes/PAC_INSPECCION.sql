--------------------------------------------------------
--  DDL for Package PAC_INSPECCION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_INSPECCION" AS
/******************************************************************************
 NOMBRE: pac_INSPECCION
 PROPÓSITO: Funciones para la inspeccion

 REVISIONES:
 Ver Fecha Autor Descripción
 --------- ---------- --------------- ------------------------------------
 1.0 05/04/2013 XPL 1. Creación del package.
******************************************************************************/
   FUNCTION f_insert_orden_insp(
      ptablas IN VARCHAR2,
      pcempres IN NUMBER,
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pnriesgo IN NUMBER,
      psorden OUT NUMBER)
      RETURN NUMBER;

   FUNCTION f_set_nordenext(
      ptablas IN VARCHAR2,
      pcempres IN NUMBER,
      psorden IN NUMBER,
      pnordenext IN VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_act_orden(
      ptablas IN VARCHAR2,
      pcempres IN NUMBER,
      psorden IN OUT NUMBER,
      pnordenext IN VARCHAR2,
      pcestado IN NUMBER,
      pctipmat IN NUMBER,
      pcmatric IN VARCHAR2,
      pcmotor IN VARCHAR2,
      pcchasis IN VARCHAR2,
      pnbastid IN VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_set_inspeccion(
      ptablas IN VARCHAR2,
      pcempres IN NUMBER,
      psorden IN NUMBER,
      pninspeccion IN OUT NUMBER,
      pfinspeccion IN DATE,
      pcestado IN NUMBER,
      pcresultado IN NUMBER,
      pcreinspeccion IN NUMBER,
      phllegada IN VARCHAR2,
      phsalida IN VARCHAR2,
      pccentroinsp IN NUMBER,
      pcinspdomi IN NUMBER,
      pcpista IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_set_inspeccion_dveh(
      ptablas IN VARCHAR2,
      pcempres IN NUMBER,
      psorden IN NUMBER,
      pninspeccion IN NUMBER,
      pcversion IN VARCHAR2,
      pcpaisorigen IN VARCHAR2,
      pnpma IN NUMBER,
      pccilindraje IN VARCHAR2,
      panyo IN NUMBER,
      pnplazas IN NUMBER,
      pcservicio IN NUMBER,
      pcblindado IN NUMBER,
      pccampero IN NUMBER,
      pcgama IN NUMBER,
      pcmatcabina IN VARCHAR2,
      pivehinue IN NUMBER,
      pcuso IN VARCHAR2,
      pccolor IN NUMBER,
      pnkilometraje IN NUMBER,
      pctipmotor IN VARCHAR2,
      pntara IN NUMBER,
      pcpintura IN NUMBER,
      pccaja IN NUMBER,
      pctransporte IN NUMBER,
      pctipcarroceria IN NUMBER,
      pesactualizacion IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_set_inspeccion_acc(
      ptablas IN VARCHAR2,
      pcempres IN NUMBER,
      psorden IN NUMBER,
      pninspeccion IN NUMBER,
      pcaccesorio IN NUMBER,
      pctipacc IN NUMBER,
      ptdesacc IN VARCHAR2,
      pivalacc IN NUMBER,
      pcasegurable IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_set_inspeccion_doc(
      pcempres IN NUMBER,
      psorden IN NUMBER,
      pninspeccion IN NUMBER,
      pcdocume IN NUMBER,
      pcgenerado IN NUMBER,
      pcobliga IN NUMBER,
      pcadjuntado IN NUMBER,
      piddocgedox IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_act_seguro(
      ptablas IN VARCHAR2,
      pcempres IN NUMBER,
      psorden IN NUMBER,
      pninspeccion IN NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_permiteinspeccion(
      pcempres IN NUMBER,
      pcagente IN NUMBER,
      psseguro IN NUMBER,
      ptablas IN VARCHAR2,
      ppermiteinspec OUT NUMBER)
      RETURN NUMBER;

   FUNCTION f_retener_poliza(
      ptablas IN VARCHAR2,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      pcmotret IN NUMBER,
      pcreteni IN NUMBER,
      pfecha IN DATE)
      RETURN NUMBER;

   FUNCTION f_act_accesorios(
      ptablas IN VARCHAR2,
      pcempres IN NUMBER,
      psorden IN NUMBER,
      pninspeccion IN NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER)
      RETURN NUMBER;
END pac_inspeccion;

/

  GRANT EXECUTE ON "AXIS"."PAC_INSPECCION" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_INSPECCION" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_INSPECCION" TO "PROGRAMADORESCSI";
