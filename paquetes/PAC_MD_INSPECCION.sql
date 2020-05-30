--------------------------------------------------------
--  DDL for Package PAC_MD_INSPECCION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_MD_INSPECCION" AS
/******************************************************************************
 NOMBRE: pac_md_INSPECCION
 PROPÓSITO: Funciones para la inspeccion

 REVISIONES:
 Ver Fecha Autor Descripción
 --------- ---------- --------------- ------------------------------------
 1.0 05/04/2013 XPL 1. Creación del package.
 2.0 11/07/2013 JDS 2. 0025221: LCOL_T031-LCOL - Fase 3 - Desarrollo Inspección de Riesgo
******************************************************************************/
   FUNCTION f_set_documentacion_inspeccion(
      pcempres IN NUMBER,
      ptfichero IN VARCHAR2,
      psorden IN NUMBER,
      pidinspeccion IN VARCHAR2,
      pninspeccion IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_crear_orden_insp(
      ptablas IN VARCHAR2,
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pnriesgo IN NUMBER,
      psorden OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_act_orden_ext(
      pcempres IN NUMBER,
      psorden IN OUT NUMBER,
      pnordenext IN VARCHAR2,
      pcestado IN NUMBER,
      pctipmat IN NUMBER,
      pcmatric IN VARCHAR2,
      pcmotor IN VARCHAR2,
      pcchasis IN VARCHAR2,
      pnbastid IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_buscar_inspeccion(
      pcempres IN NUMBER,
      psorden_in IN NUMBER,
      psordenext_in IN NUMBER,
      psorden_out OUT NUMBER,
      psordenext_out OUT NUMBER,
      pninspeccion_out OUT VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_set_inspeccion(
      pcempres IN NUMBER,
      psorden IN NUMBER,
      pninspeccion_in IN NUMBER,
      pfinspeccion IN DATE,
      pcestado IN NUMBER,
      pcresultado IN NUMBER,
      pcreinspeccion IN NUMBER,
      phllegada IN VARCHAR2,
      phsalida IN VARCHAR2,
      pccentroinsp IN NUMBER,
      pcinspdomi IN NUMBER,
      pcpista IN NUMBER,
      pninspeccion_out OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_set_inspeccion_dveh(
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
      pesactualizacion IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_set_inspeccion_acc(
      pcempres IN NUMBER,
      psorden IN NUMBER,
      pninspeccion IN NUMBER,
      pcaccesorio IN NUMBER,
      pctipacc IN NUMBER,
      ptdesacc IN VARCHAR2,
      pivalacc IN NUMBER,
      pcasegurable IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_set_inspeccion_doc(
      pcempres IN NUMBER,
      psorden IN NUMBER,
      pninspeccion IN NUMBER,
      pcdocume IN NUMBER,
      pcgenerado IN NUMBER,
      pcobliga IN NUMBER,
      pcadjuntado IN NUMBER,
      piddocgedox IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_act_seguros(
      pcempres IN NUMBER,
      psorden IN NUMBER,
      pninspeccion IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_ord_inspec_mod_consulta(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pnriesgo IN NUMBER,
      pnecesitainspeccion OUT NUMBER,
      presultadoinspeccion OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_get_ordenes_inspeccion(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pnriesgo IN NUMBER,
      ptablas IN VARCHAR2,
      pnecesitainspeccion OUT NUMBER,
      presultadoinspeccion OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_gestion_inspeccion(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pnriesgo IN NUMBER,
      ptablas IN VARCHAR2,
      pnecesitainspeccion OUT NUMBER,
      presultadoinspeccion OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_necesita_inspeccion(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      ptablas IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   f_retencion
   Crear retención por inspeccion
   param in psseguro : sseguro
   param in pnmovimi : Numero de movimiento de la poliza
   param out t_iax_mensajes : mensajes de error
   return : 0 todo correcto
   1 aviso
   2 error
   ****************************************************************************/
   FUNCTION f_retencion(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pfecha IN DATE,
      mensajes IN OUT t_iax_mensajes,
      pmotretencion IN NUMBER DEFAULT 16)
      RETURN NUMBER;

   FUNCTION f_resultado_inspeccion(
      ptablas IN VARCHAR2,
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pnriesgo IN NUMBER,
      presultadoinspeccion OUT NUMBER,
      pnecesitainspeccion OUT NUMBER,
      mensajes IN OUT t_iax_mensajes,
      pgestretinsp IN NUMBER DEFAULT 0)
      RETURN NUMBER;

   FUNCTION f_gest_retener_porinspeccion(
      ptablas IN VARCHAR2,
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pnriesgo IN NUMBER,
      pnecesitainspeccion_in IN NUMBER,
      presultadoinspeccion_in IN NUMBER,
      psorden OUT NUMBER,
      pcreteni OUT NUMBER,
      mensajes IN OUT t_iax_mensajes,
      pgestretinsp IN NUMBER DEFAULT 0)
      RETURN NUMBER;

   FUNCTION f_permite_emitirinspeccion(
      psseguro IN NUMBER,
      ptablas IN VARCHAR,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_permite_emitirinspec_pend(
      psseguro IN NUMBER,
      ptablas IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_irordenes(
      ptablas IN VARCHAR2,
      pctipmat IN NUMBER,
      pcmatric IN VARCHAR2,
      psorden IN NUMBER,
      pninspeccion IN NUMBER,
      pmensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_get_irinspecciones(
      psorden IN NUMBER,
      pninspeccion IN NUMBER,
      pmensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_get_irinspeccionesdveh(
      psorden IN NUMBER,
      pninspeccion IN NUMBER,
      pmensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_get_irinspeccionesacc(
      psorden IN NUMBER,
      pninspeccion IN NUMBER,
      pmensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_get_irinspeccionesdoc(
      psorden IN NUMBER,
      pninspeccion IN NUMBER,
      pmensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_tiene_inspec_vigente(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pnriesgo IN NUMBER,
      pctipmat IN VARCHAR2,
      pcmatric IN VARCHAR2,
      psproduc IN NUMBER,
      ptablas IN VARCHAR2,
      pmodo IN VARCHAR2,
      pinspeccion_vigente OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_act_accesorios(
      pcempres IN NUMBER,
      psorden IN NUMBER,
      pninspeccion IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;
END pac_md_inspeccion;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_INSPECCION" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_INSPECCION" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_INSPECCION" TO "PROGRAMADORESCSI";
