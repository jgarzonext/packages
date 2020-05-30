--------------------------------------------------------
--  DDL for Package PAC_SIN_IMPUESTOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_SIN_IMPUESTOS" AS
/******************************************************************************
   NOMBRE:    pac_sin_impuestos
   PROPÓSITO: Funciones para calculo de impuestos en siniestros

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
    1.0       13/08/2013   NSS             Creacion
******************************************************************************/
   FUNCTION f_get_impuestos(
      pcconcep IN NUMBER,
      pccodimp IN NUMBER,
      pcempres IN NUMBER,
      pcidioma IN NUMBER,
      ptselect OUT VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_set_impuesto(
      pcconcep IN NUMBER,
      pccodimp IN NUMBER,
      pfdesde IN DATE,
      pctipper IN NUMBER,
      pcregfiscal IN NUMBER,
      pctipcal IN NUMBER,
      pifijo IN NUMBER,
      pcbasecal IN NUMBER,
      pcbasemin IN NUMBER,
      pcbasemax IN NUMBER,
      pnporcent IN NUMBER,
      pimin IN NUMBER,
      pimax IN NUMBER,
      pcempres IN NUMBER,
      pnordimp IN NUMBER,
      pcsubtab IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_del_impuesto(
      pcconcep IN NUMBER,
      pccodimp IN NUMBER,
      pnordimp IN NUMBER,
      pcempres IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_get_impuesto(
      pcconcep IN NUMBER,
      pccodimp IN NUMBER,
      pnordimp IN NUMBER,
      pcempres IN NUMBER,
      pcidioma IN NUMBER,
      ptselect OUT VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_get_lstimpuestos(pcempres IN NUMBER, pcidioma IN NUMBER, ptselect OUT VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_get_tdescri_subtab(
      pcsubtab IN NUMBER,
      pcidioma IN NUMBER,
      pcempres IN NUMBER,
      ptselect OUT VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_copia_impuesto(pcconcep IN NUMBER, pcconcep_ant IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_destinatario(
      psperson IN per_personas.sperson%TYPE,
      pcagente IN agentes.cagente%TYPE,
      pfecha IN DATE,
      psgestio IN sin_tramita_gestion.sgestio%TYPE,
      pctipper OUT per_personas.ctipper%TYPE,
      pcregfiscal OUT per_regimenfiscal.cregfiscal%TYPE,
      pcprofes OUT per_detper.cprofes%TYPE,
      pcpais OUT paises.cpais%TYPE,
      pcprovin OUT provincias.cprovin%TYPE,
      pcpoblac OUT poblaciones.cpoblac%TYPE)
      RETURN NUMBER;

   /*************************************************************************
     Devuelve los datos fiscales del destinatario para calculo de retenciones
    *************************************************************************/
   FUNCTION f_calc_tot_imp(
      pfecha IN DATE,
      psidepag IN sin_tramita_pago.sidepag%TYPE,
      psgestio IN sin_tramita_gestion.sgestio%TYPE,
      pctipgas IN sin_tramita_reserva.ctipgas%TYPE,
      pcconcep IN NUMBER,
      pisinret IN NUMBER,
      pctipper IN per_personas.ctipper%TYPE,
      pcregfiscal IN per_regimenfiscal.cregfiscal%TYPE,
      pcprofes IN per_detper.cprofes%TYPE,
      pcpais IN paises.cpais%TYPE,
      pcprovin IN provincias.cprovin%TYPE,
      pcpoblac IN poblaciones.cpoblac%TYPE,
      psimplog IN OUT sin_imp_calculo_log.simplog%TYPE,
      ptot_imp OUT NUMBER)
      RETURN NUMBER;

   /*************************************************************************
     Calcula todos los impuestos aplicables a un pago
    *************************************************************************/
   FUNCTION f_calc_impuesto(
      psimplog IN sin_imp_calculo_log.simplog%TYPE,
      pfecha IN DATE,
      pccodimp IN sin_imp_codimpuesto.ccodimp%TYPE,
      pcsumres IN sin_imp_codimpuesto.csumres%TYPE,
      pcconcep IN NUMBER,
      pctipgas IN sin_tramita_reserva.ctipgas%TYPE,
      pisinret IN NUMBER,
      pctipper IN per_personas.ctipper%TYPE,
      pcregfiscal IN per_regimenfiscal.cregfiscal%TYPE,
      pcprofes IN per_detper.cprofes%TYPE,
      pcpais IN paises.cpais%TYPE,
      pcprovin IN provincias.cprovin%TYPE,
      pcpoblac IN poblaciones.cpoblac%TYPE,
      ptotal OUT NUMBER)
      RETURN NUMBER;

/*************************************************************************
  Calcula un impuesto
 *************************************************************************/
   FUNCTION f_get_impuestos_calculados(psimplog IN NUMBER, pquery IN OUT VARCHAR2)
      RETURN NUMBER;

/*************************************************************************
  Devuelve todos los impuestos calculados en un log
 *************************************************************************/
   FUNCTION f_get_lstconceptos(pcidioma IN NUMBER, ptselect OUT VARCHAR2)
      RETURN NUMBER;

/*************************************************************************
  Devuelve la agrupacion para impuestos a partir del concepto del pago
 *************************************************************************/
   FUNCTION f_get_cconcep(pcconpag IN NUMBER, pcconcep OUT NUMBER)
      RETURN NUMBER;

/*************************************************************************
  Devuelve la definición del reteica para los tipos de profesional de una localización en concreto
 *************************************************************************/
   FUNCTION f_get_definiciones_reteica(
      pcpais IN NUMBER,
      pcprovin IN NUMBER,
      pcpoblac IN NUMBER,
      pcidioma IN NUMBER,
      ptselect OUT VARCHAR2)
      RETURN NUMBER;

   /*************************************************************************
    Actualiza la definición del reteica para los tipos de profesional de una localización en concreto
   *************************************************************************/
   FUNCTION f_set_valores_reteica(
      pcpais IN NUMBER,
      pcprovin IN NUMBER,
      pcpoblac IN NUMBER,
      pfdesde IN DATE,
      pvalores_reteica IN VARCHAR2)
      RETURN NUMBER;
END pac_sin_impuestos;

/

  GRANT EXECUTE ON "AXIS"."PAC_SIN_IMPUESTOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_SIN_IMPUESTOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_SIN_IMPUESTOS" TO "PROGRAMADORESCSI";
