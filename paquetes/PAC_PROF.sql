--------------------------------------------------------
--  DDL for Package PAC_PROF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_PROF" AS
/******************************************************************************
   NOMBRE:    PAC_PROF
   PROPÓSITO: Funciones para profesionales

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
    1.0       08/11/2012   JDS             Creacion
******************************************************************************/
   FUNCTION f_get_lstccc(psprofes IN NUMBER, ptselect OUT VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_ins_ccc(
      psprofes IN NUMBER,
      pcramo IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcnordban IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_get_dades_profesional(psprofes IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_profesional;

   FUNCTION f_get_ccc(psprofes IN NUMBER, pcidioma IN NUMBER, ptselect OUT VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_set_estado(
      sprofes IN NUMBER,
      cestprf IN NUMBER,
      festado IN DATE,
      cmotbaja IN NUMBER,
      tobservaciones IN VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_get_estados(psprofes IN NUMBER, pcidioma IN NUMBER, ptselect OUT VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_del_estado(psprofes IN NUMBER, pfestado IN DATE)
      RETURN NUMBER;

   FUNCTION f_del_ccc(psprofes IN NUMBER, pcnorden IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_set_zona(
      psprofes IN NUMBER,
      pctpzona IN NUMBER,
      pcpais IN NUMBER,
      pcprovin IN NUMBER,
      pcpoblac IN NUMBER,
      pcposini IN VARCHAR2,
      pcposfin IN VARCHAR2,
      pfdesde IN DATE,
      pfhasta IN DATE)
      RETURN NUMBER;

   FUNCTION f_get_zonas(psprofes IN NUMBER, pcidioma IN NUMBER, ptselect OUT VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_mod_zona(psprofes IN NUMBER, pcnordzn IN NUMBER, pfhasta IN DATE)
      RETURN NUMBER;

   FUNCTION f_set_contacto_per(
      psprofes IN NUMBER,
      pctipdoc IN NUMBER,
      pnnumnif IN VARCHAR2,
      ptnombre IN VARCHAR2,
      ptmovil IN VARCHAR2,
      ptemail IN VARCHAR2,
      ptcargo IN VARCHAR2,
      ptdirecc IN VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_get_contactos_per(psprofes IN NUMBER, ptselect OUT VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_del_contacto_per(psprofes IN NUMBER, pnordcto IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_get_ctipprof(psprofes IN NUMBER, pcidioma IN NUMBER, pquery IN OUT VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_get_csubprof(
      psprofes IN NUMBER,
      pctippro IN NUMBER,
      pcidioma IN NUMBER,
      pquery IN OUT VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_set_carga(
      psprofes IN NUMBER,
      pctippro IN NUMBER,
      pcsubpro IN NUMBER,
      pncardia IN NUMBER,
      pncarsem IN NUMBER,
      pfdesde IN DATE)
      RETURN NUMBER;

   FUNCTION f_valida_carga(
      psprofes IN NUMBER,
      pctippro IN NUMBER,
      pcsubpro IN NUMBER,
      pfdesde IN DATE,
      ptipo IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_get_carga(psprofes IN NUMBER, pcidioma IN NUMBER, ptselect OUT VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_del_carga(
      psprofes IN NUMBER,
      pctippro IN NUMBER,
      pcsubpro IN NUMBER,
      pfdesde IN DATE)
      RETURN NUMBER;

   FUNCTION f_mod_contacto_per(
      psprofes IN NUMBER,
      pcnordcto IN NUMBER,
      pctipdoc IN NUMBER,
      pnnumnif IN VARCHAR2,
      ptnombre IN VARCHAR2,
      ptmovil IN VARCHAR2,
      ptemail IN VARCHAR2,
      ptcargo IN VARCHAR2,
      ptdirecc IN VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_calc_carga(
      psprofes IN NUMBER,
      pctippro IN NUMBER,
      pcsubpro IN NUMBER,
      pncapaci IN NUMBER,
      pfdesde IN DATE,
      pquery IN OUT VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_set_carga_real(
      psprofes IN NUMBER,
      pctippro IN NUMBER,
      pcsubpro IN NUMBER,
      pncapaci IN NUMBER,
      pncardia IN NUMBER,
      pncarsem IN NUMBER,
      pfdesde IN DATE)
      RETURN NUMBER;

   FUNCTION f_get_carga_real(psprofes IN NUMBER, pcidioma IN NUMBER, ptselect OUT VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_del_carga_real(
      psprofes IN NUMBER,
      pctippro IN NUMBER,
      pcsubpro IN NUMBER,
      pfdesde IN DATE)
      RETURN NUMBER;

   FUNCTION f_set_descartado(
      psprofes IN NUMBER,
      pctippro IN NUMBER,
      pcsubpro IN NUMBER,
      psproduc IN NUMBER,
      pccausin IN NUMBER,
      pfdesde IN DATE,
      pfhasta IN DATE)
      RETURN NUMBER;

   FUNCTION f_valida_descartado(
      psprofes IN NUMBER,
      pctippro IN NUMBER,
      pcsubpro IN NUMBER,
      psproduc IN NUMBER,
      pccausin IN NUMBER,
      pfdesde IN DATE,
      pfhasta IN DATE)
      RETURN NUMBER;

   FUNCTION f_get_descartados(psprofes IN NUMBER, pcidioma IN NUMBER, ptselect OUT VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_mod_descartados(
      psprofes IN NUMBER,
      pctippro IN NUMBER,
      pcsubpro IN NUMBER,
      psproduc IN NUMBER,
      pccausin IN NUMBER,
      pfdesde IN DATE,
      pfhasta IN DATE)
      RETURN NUMBER;

   FUNCTION f_set_observaciones(psprofes IN NUMBER, ptobserv IN VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_get_observaciones(psprofes IN NUMBER, ptselect OUT VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_set_rol(psprofes IN NUMBER, pctippro IN NUMBER, pcsubpro IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_get_roles(psprofes IN NUMBER, pcidioma IN NUMBER, ptselect OUT VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_set_seguimiento(psprofes IN NUMBER, ptobserv IN VARCHAR2, pccalific IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_get_seguimiento(psprofes IN NUMBER, pcidioma IN NUMBER, ptselect OUT VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_get_sprofes(pquery IN OUT VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_get_lsttelefonos(psperson IN NUMBER, ptselect OUT VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_get_lstemail(psperson IN NUMBER, ptselect OUT VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_set_profesional(
      psprofes IN NUMBER,
      psperson IN NUMBER,
      pnregmer IN VARCHAR2,
      pfregmer IN DATE,
      pcdomici IN NUMBER,
      pcmodcon IN NUMBER,
      pctelcli IN NUMBER,
      pnlimite IN NUMBER,
      pcnoasis IN NUMBER,
      pcmodo IN NUMBER,
      psgestio IN NUMBER DEFAULT NULL,
      ptexto OUT VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_get_profesionales(
      pctipide IN NUMBER,
      pnnumide IN VARCHAR2,
      ptnombre IN VARCHAR2,
      pctippro IN NUMBER,
      pcsubpro IN NUMBER,
      psprofes IN NUMBER,
      pcidioma IN NUMBER,
      pcprovin IN NUMBER DEFAULT NULL,
      pcpoblac IN NUMBER DEFAULT NULL,
      ptselect OUT VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_get_profesional(psprofes IN NUMBER, pcidioma IN NUMBER, ptselect OUT VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_get_ctipprof_carga_real(
      psprofes IN NUMBER,
      pcidioma IN NUMBER,
      pquery IN OUT VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_get_csubprof_carga_real(
      psprofes IN NUMBER,
      pctippro IN NUMBER,
      pcidioma IN NUMBER,
      pquery IN OUT VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_del_rol(psprofes IN NUMBER, pctippro IN NUMBER, pcsubpro IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_get_contactos(psprofes IN NUMBER, pcidioma IN NUMBER, ptselect OUT VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_set_contacto_pref(psprofes IN NUMBER, pcmodcon IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_get_documentos(psprofes IN NUMBER, pcidioma IN NUMBER, ptselect OUT VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_set_documentacion(
      psprofes IN NUMBER,
      pfcaduca IN DATE,
      ptobserva IN VARCHAR2,
      piddocgedox IN NUMBER,
      ptdesc IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;

   FUNCTION f_get_sedes(psprofes IN NUMBER, pcidioma IN NUMBER, ptselect OUT VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_set_sede(
      psprofes IN NUMBER,
      pspersed IN NUMBER,
      pthorari IN VARCHAR2,
      ptpercto IN VARCHAR2,
      pcdomici IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_get_representantes(psprofes IN NUMBER, pcidioma IN NUMBER, ptselect OUT VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_set_representante(
      psprofes IN NUMBER,
      psperson IN NUMBER,
      pnmovil IN NUMBER,
      ptemail IN NUMBER,
      ptcargo IN VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_get_sservic(ptselect OUT VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_get_lstcups(ptselect OUT VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_set_servicio(
      pstarifa IN NUMBER,
      psservic IN NUMBER,
      pccodcup IN VARCHAR2,
      ptdescri IN VARCHAR2,
      pcunimed IN NUMBER,
      piprecio IN NUMBER,
      pctipcal IN NUMBER,
      pcmagnit IN NUMBER,
      piminimo IN NUMBER,
      pcselecc IN NUMBER,
      pctipser IN NUMBER,
      pfinivig IN DATE,
      pffinvig IN DATE)
      RETURN NUMBER;

   FUNCTION f_get_servicios(
      pstarifa IN NUMBER,
      psservic IN NUMBER,
      ptdescri IN VARCHAR2,
      pcidioma IN NUMBER,
      ptselect OUT VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_get_servicio(
      pstarifa IN NUMBER,
      psservic IN NUMBER,
      pcidioma IN NUMBER,
      ptselect OUT VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_get_tarifas(pstarifa IN NUMBER, ptdescri IN VARCHAR2, ptselect OUT VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_get_starifa(ptselect OUT VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_set_tarifa(pstarifa IN NUMBER, ptdescri IN VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_get_convenios(psprofes IN NUMBER, pcidioma IN NUMBER, ptselect OUT VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_get_estados_convenio(
      psconven IN NUMBER,
      pcidioma IN NUMBER,
      ptselect OUT VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_set_estado_convenio(
      sconven IN NUMBER,
      cestado IN NUMBER,
      festado IN DATE,
      tobservaciones IN VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_del_estado_convenio(psconven IN NUMBER, pcestado IN NUMBER, pfestado IN DATE)
      RETURN NUMBER;

   FUNCTION f_set_convenio(
      psconven IN NUMBER,
      psprofes IN NUMBER,
      pstarifa IN NUMBER,
      pspersed IN NUMBER,
      pncomple IN NUMBER,
      pnpriorm IN NUMBER,
      ptdescri IN VARCHAR2,
      pcvalor IN NUMBER,
      pctipo IN NUMBER,
      pnimporte IN NUMBER,
      pnporcent IN NUMBER,
      ptermino IN VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_get_tarifa(pstarifa IN NUMBER, pcidioma IN NUMBER, ptselect OUT VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_get_convenio(psconven IN NUMBER, pcidioma IN NUMBER, ptselect OUT VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_actualiza_servicio(
      pstarifa IN NUMBER,
      psservic IN NUMBER,
      piprecio IN NUMBER,
      piminimo IN NUMBER,
      pfinivig IN DATE)
      RETURN NUMBER;

   FUNCTION f_copiar_tarifa(
      pstarifa_new IN NUMBER,
      ptdescri IN VARCHAR2,
      pcunimed IN NUMBER,
      piprecio IN NUMBER,
      pcmagnit IN NUMBER,
      piminimo IN NUMBER,
      pfinivig IN DATE,
      pffinvig IN DATE,
      pctipser IN NUMBER,
      pccodcup IN VARCHAR2,
      pcselecc IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_get_tarifa_a_copiar(pstarifa_sel IN NUMBER, ptselect OUT VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_actualiza_servicios(
      pstarifa IN NUMBER,
      pservicios IN VARCHAR2,
      pcvalor IN NUMBER,
      pctipo IN NUMBER,
      pnimporte IN NUMBER,
      pnporcent IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_tipos_profesional(pcidioma IN NUMBER, ptselect OUT VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_get_subtipos_profesional(
      pctipprof IN NUMBER,
      pcidioma IN NUMBER,
      ptselect OUT VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_get_tdescri_tarifa(pstarifa IN NUMBER, pcidioma IN NUMBER, ptselect OUT VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_get_tarifa_profesional(
      psprofes IN NUMBER,
      psconven IN NUMBER,
      pstarifa OUT NUMBER)
      RETURN NUMBER;

   FUNCTION f_lstmagnitud(pctipcal IN NUMBER, pcidioma IN NUMBER, ptselect OUT VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_get_moneda(pcmagnit IN NUMBER, pccodmon OUT VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_set_dettarifas_rel(psservic IN NUMBER, pctipser IN NUMBER)
      RETURN NUMBER;

-- 26929:ASN:07/06/2013
   FUNCTION f_lstterminos(ptselect OUT VARCHAR2)
      RETURN NUMBER;

   --26630
   FUNCTION f_set_convenio_temporal(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      psperson IN NUMBER,
      pnlocali IN NUMBER,
      pctippro IN NUMBER,
      pcsubpro IN NUMBER,
      pstarifa IN NUMBER,
      pnnumide IN VARCHAR2,
      ptnombre IN VARCHAR2,
      pcvalor IN NUMBER,
      pctipo IN NUMBER,
      pnimporte IN NUMBER,
      pnporcent IN NUMBER,
      ptermino IN VARCHAR2,
      ptemail IN VARCHAR2,
      pcagente IN NUMBER,
      psprofes OUT NUMBER,
      psconven OUT NUMBER)
      RETURN NUMBER;

   --0024637/0147756: (POSAN500-AN-Sin) Analisis Desarrollo: Siniestros:NSS;25/02/2014
   FUNCTION f_get_impuestos(psprofes IN NUMBER, pcidioma IN NUMBER, ptselect OUT VARCHAR2)
      RETURN NUMBER;
END pac_prof;

/

  GRANT EXECUTE ON "AXIS"."PAC_PROF" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_PROF" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_PROF" TO "PROGRAMADORESCSI";
