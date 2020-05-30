--------------------------------------------------------
--  DDL for Package PAC_IAX_INSPECCION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_IAX_INSPECCION" AS
/******************************************************************************
 NOMBRE: pac_iax_INSPECCION
   PROPÓSITO:  Funciones para la inspeccion

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        05/04/2013   XPL              1. Creación del package.
   2.0        11/07/2013   JDS              2. 0025221: LCOL_T031-LCOL - Fase 3 - Desarrollo Inspección de Riesgo
******************************************************************************/
   FUNCTION f_set_documentacion_inspeccion(
      pcempres IN NUMBER,
      ptfichero IN VARCHAR2,
      pidinspeccion IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_set_accesorios_inspeccion(
      pcempres IN NUMBER,
      pidinspeccion IN VARCHAR2,
      pasegurableinspeccion IN NUMBER,
      pactualizaciondatos IN NUMBER,
      ptipo IN VARCHAR2,
      ptmarca IN VARCHAR2,
      ptreferencia IN VARCHAR2,
      pvalorunitario IN NUMBER,
      pcantidad IN NUMBER,
      poriginal IN NUMBER,
      pasegurable IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_set_vehiculo_inspeccion(
      pcempres IN NUMBER,
      pidinspeccion IN VARCHAR2,
      pasegurableinspeccion IN NUMBER,
      pactualizaciondatos IN NUMBER,
      pcapacidad IN NUMBER,
      pcchasis IN VARCHAR2,
      pclase IN VARCHAR2,
      pclindraje IN VARCHAR2,
      pcmarca IN VARCHAR2,
      pmodelo IN NUMBER,
      pmotor IN VARCHAR2,
      ppaismatricula IN VARCHAR2,
      ppassajeros IN VARCHAR2,
      pservicio IN VARCHAR2,
      ptipo IN VARCHAR2,
      ptipoplaca IN VARCHAR2,
      pplaca IN VARCHAR2,
      pvin IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_carga_inspeccion_auto_seguro(
      pcempres IN NUMBER,
      psorden IN NUMBER,
      pninspeccion IN NUMBER,
      mensajes OUT t_iax_mensajes)
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
      mensajes OUT t_iax_mensajes)
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
      mensajes OUT t_iax_mensajes)
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
      mensajes OUT t_iax_mensajes)
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
      ptablas IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_desretener(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pnriesgo IN NUMBER,
      ptablas IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_permite_emitirinspeccion(
      psseguro IN NUMBER,
      ptablas IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_permite_emitirinspec_pend(
      psseguro IN NUMBER,
      ptablas IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_autorizar_todo_menos_inspec(
      ptablas IN VARCHAR2,
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pnriesgo IN NUMBER,
      pcautrec IN NUMBER,
      pnocurre IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_lanza_solicitud_insp(
      ptablas IN VARCHAR2,
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pnriesgo IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_revisar_inspeccion(
      ptablas IN VARCHAR2,
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pnriesgo IN NUMBER,
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
END pac_iax_inspeccion;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_INSPECCION" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_INSPECCION" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_INSPECCION" TO "PROGRAMADORESCSI";
