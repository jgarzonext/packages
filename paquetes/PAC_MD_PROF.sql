--------------------------------------------------------
--  DDL for Package PAC_MD_PROF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_MD_PROF" AS
/******************************************************************************
   NOMBRE:    PAC_MD_PROF
   PROP¿SITO: Funciones para profesionales

   REVISIONES:
   Ver        Fecha        Autor             Descripci¿n
   ---------  ----------  ---------------  ------------------------------------
    1.0       24/08/2011   JDS             Creacion
******************************************************************************/
   FUNCTION f_opencursor(squery IN VARCHAR2, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Abre un cursor con la sentencia suministrada
      param in squery    : consulta a executar
      param out mensajes : mesajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstccc(psprofes IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_set_ccc(
      psprofes IN NUMBER,
      pcramo IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcnordban IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_dades_profesional(psprofes IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_profesional;

   FUNCTION f_get_ccc(
      sprofes IN NUMBER,
      t_ccc OUT t_iax_prof_ccc,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_estados(
      sprofes IN NUMBER,
      t_estados OUT t_iax_prof_estados,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_set_estado(
      sprofes IN NUMBER,
      cestprf IN NUMBER,
      festado IN DATE,
      cmotbaja IN NUMBER,
      tobservaciones IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_del_estado(sprofes IN NUMBER, festado IN DATE, mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_del_ccc(sprofes IN NUMBER, cnorden IN NUMBER, mensajes OUT t_iax_mensajes)
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
      pfhasta IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_zonas(
      psprofes IN NUMBER,
      t_zonas OUT t_iax_prof_zonas,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
         Modifica la fecha hasta la cual est¿ asignada esa zona
         param in  psprofes : codigo profesional
         param in  pCNORDZN : secuencial de la zona
         param in  pfhasta : Fecha hasta la que est¿ asignada la zona
         param out mensajes : mesajes de error
         return             : ref cursor
   *************************************************************************/
   FUNCTION f_mod_zona(
      psprofes IN NUMBER,
      pcnordzn IN NUMBER,
      pfhasta IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_set_contacto_per(
      sprofes IN NUMBER,
      ctipdoc IN NUMBER,
      nnumnif IN VARCHAR2,
      tnombre IN VARCHAR2,
      tmovil IN VARCHAR2,
      temail IN VARCHAR2,
      tcargo IN VARCHAR2,
      tdirecc IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_contactos_per(
      sprofes IN NUMBER,
      t_contactos_per OUT t_iax_prof_contactos_per,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_ctipprof(psprofes IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_get_csubprof(
      psprofes IN NUMBER,
      pctipprof IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_set_carga(
      sprofes IN NUMBER,
      ctippro IN NUMBER,
      csubpro IN NUMBER,
      ncardia IN NUMBER,
      ncarsem IN NUMBER,
      fdesde IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_carga(
      sprofes IN NUMBER,
      t_carga OUT t_iax_prof_carga_permitida,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_del_carga(
      sprofes IN NUMBER,
      ctippro IN NUMBER,
      csubpro IN NUMBER,
      fdesde IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_del_contacto_per(
      sprofes IN NUMBER,
      nordcto IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_mod_contacto_per(
      sprofes IN NUMBER,
      cnordcto IN NUMBER,
      ctipdoc IN NUMBER,
      nnumnif IN VARCHAR2,
      tnombre IN VARCHAR2,
      tmovil IN VARCHAR2,
      temail IN VARCHAR2,
      tcargo IN VARCHAR2,
      tdirecc IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_calc_carga(
      sprofes IN NUMBER,
      ctippro IN NUMBER,
      csubpro IN NUMBER,
      ncapaci IN NUMBER,
      fdesde IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_set_carga_real(
      sprofes IN NUMBER,
      ctippro IN NUMBER,
      csubpro IN NUMBER,
      ncapaci IN NUMBER,
      ncardia IN NUMBER,
      ncarsem IN NUMBER,
      fdesde IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_carga_real(
      sprofes IN NUMBER,
      t_carga_real OUT t_iax_prof_carga_real,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_del_carga_real(
      sprofes IN NUMBER,
      ctippro IN NUMBER,
      csubpro IN NUMBER,
      fdesde IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_set_descartado(
      sprofes IN NUMBER,
      ctippro IN NUMBER,
      csubpro IN NUMBER,
      sproduc IN NUMBER,
      ccausin IN NUMBER,
      fdesde IN DATE,
      fhasta IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_descartados(
      sprofes IN NUMBER,
      t_descartados OUT t_iax_prof_descartados,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_mod_descartados(
      sprofes IN NUMBER,
      ctippro IN NUMBER,
      csubpro IN NUMBER,
      sproduc IN NUMBER,
      ccausin IN NUMBER,
      fdesde IN DATE,
      fhasta IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_set_observaciones(
      sprofes IN NUMBER,
      tobserv IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_observaciones(
      sprofes IN NUMBER,
      t_observaciones OUT t_iax_prof_observaciones,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_set_rol(
      sprofes IN NUMBER,
      ctippro IN NUMBER,
      csubpro IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_roles(
      sprofes IN NUMBER,
      t_roles OUT t_iax_prof_roles,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_set_seguimiento(
      sprofes IN NUMBER,
      tobserv IN VARCHAR2,
      ccalific IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_seguimiento(
      sprofes IN NUMBER,
      t_seguimiento OUT t_iax_prof_seguimiento,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_sprofes(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_get_lsttelefonos(sperson IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_get_lstemail(sperson IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_set_profesional(
      sprofes IN NUMBER,
      vobprofesional IN ob_iax_profesional,
      pcmodo IN NUMBER,
      ptexto OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_profesionales(
      pctipide IN NUMBER,
      pnnumide IN VARCHAR2,
      ptnombre IN VARCHAR2,
      pctippro IN NUMBER,
      pcsubpro IN NUMBER,
      psprofes IN NUMBER,
      pcprovin IN NUMBER DEFAULT NULL,
      pcpoblac IN NUMBER DEFAULT NULL,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_get_profesional(
      psprofes IN NUMBER,
      obprof OUT ob_iax_profesional,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_ctipprof_carga_real(sprofes IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_get_csubprof_carga_real(
      sprofes IN NUMBER,
      ctipprof IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_del_rol(
      sprofes IN NUMBER,
      ctippro IN NUMBER,
      csubpro IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_contactos(
      sprofes IN NUMBER,
      t_contactos OUT t_iax_prof_contactos,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_set_contacto_pref(
      sprofes IN NUMBER,
      cmodcon IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_documentos(
      sprofes IN NUMBER,
      t_docs OUT t_iax_prof_documentacion,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_set_documentacion(
      psprofes IN NUMBER,
      pfcaduca IN DATE,
      ptobserva IN VARCHAR2,
      piddocgedox IN NUMBER,
      ptdesc IN VARCHAR2 DEFAULT NULL,
      ptfilename IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_sedes(
      sprofes IN NUMBER,
      t_sedes OUT t_iax_prof_sedes,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_set_sede(
      sprofes IN NUMBER,
      spersed IN NUMBER,
      thorari IN VARCHAR2,
      tpercto IN VARCHAR2,
      cdomici IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_representantes(
      sprofes IN NUMBER,
      t_representantes OUT t_iax_prof_repre,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_set_representante(
      sprofes IN NUMBER,
      sperson IN NUMBER,
      nmovil IN NUMBER,
      temail IN NUMBER,
      tcargo IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_sservic(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_get_lstcups(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_set_servicio(
      starifa IN NUMBER,
      sservic IN NUMBER,
      ccodcup IN VARCHAR2,
      tdescri IN VARCHAR2,
      cunimed IN NUMBER,
      iprecio IN NUMBER,
      ctipcal IN NUMBER,
      cmagnit IN NUMBER,
      iminimo IN NUMBER,
      cselecc IN NUMBER,
      ctipser IN NUMBER,
      finivig IN DATE,
      ffinvig IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_servicios(
      starifa IN NUMBER,
      sservic IN NUMBER,
      tdescri IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_get_servicio(
      starifa IN NUMBER,
      sservic IN NUMBER,
      servicio OUT ob_iax_prof_servi,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_tarifas(
      pstarifa IN NUMBER,
      ptdescri IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_get_starifa(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_set_tarifa(starifa IN NUMBER, tdescri IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_convenios(
      sprofes IN NUMBER,
      t_convenios OUT t_iax_prof_conve,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_estados_convenio(psconven IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_set_estado_convenio(
      sconven IN NUMBER,
      cestado IN NUMBER,
      festado IN DATE,
      tobservaciones IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_del_estado_convenio(
      sconven IN NUMBER,
      cestado IN NUMBER,
      festado IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_set_convenio(
      sconven IN NUMBER,
      sprofes IN NUMBER,
      starifa IN NUMBER,
      spersed IN NUMBER,
      ncomple IN NUMBER,
      npriorm IN NUMBER,
      tdescri IN VARCHAR2,
      pcvalor IN NUMBER,
      pctipo IN NUMBER,
      pnimporte IN NUMBER,
      pnporcent IN NUMBER,
      ptermino IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_tarifa(
      starifa IN NUMBER,
      tarifa OUT ob_iax_prof_tarifa,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_convenio(
      sconven IN NUMBER,
      convenio OUT ob_iax_prof_conve,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_actualiza_servicio(
      starifa IN NUMBER,
      sservic IN NUMBER,
      iprecio IN NUMBER,
      iminimo IN NUMBER,
      finivig IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_copiar_tarifa(
      starifa_new IN NUMBER,
      starifa_sel IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_actualiza_servicios(
      starifa IN NUMBER,
      servicios IN VARCHAR2,
      cvalor IN NUMBER,
      ctipo IN NUMBER,
      nimporte IN NUMBER,
      nporcent IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_tipos_profesional(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_get_subtipos_profesional(pctipprof IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_get_tdescri_tarifa(pstarifa IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_get_tarifa_profesional(
      psprofes IN NUMBER,
      psconven IN NUMBER,
      pstarifa OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_lstmagnitud(pctipcal IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_lstterminos(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   --26630:NSS:09/07/2013
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
      psconven OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   --0024637/0147756: (POSAN500-AN-Sin) Analisis Desarrollo: Siniestros:NSS;25/02/2014
   FUNCTION f_get_impuestos(
      sprofes IN NUMBER,
      t_impuestos OUT t_iax_prof_impuestos,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;
END pac_md_prof;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_PROF" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_PROF" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_PROF" TO "PROGRAMADORESCSI";
