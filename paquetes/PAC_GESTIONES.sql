--------------------------------------------------------
--  DDL for Package PAC_GESTIONES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_GESTIONES" AS
/******************************************************************************
   NOMBRE:    PAC_GESTIONES
   PROPÓSITO: Funciones para gestiones en siniestros

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
    1.0       24/08/2011   ASN             Creacion
******************************************************************************/
   FUNCTION f_gestiones(
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pntramit IN sin_tramitacion.ntramit%TYPE,
      pcidioma IN idiomas.cidioma%TYPE,
      pquery OUT VARCHAR2)
      RETURN NUMBER;

   /*************************************************************************
      Devuelve query para la lista de gestiones del bloque en tramitacion
      param in  pnsinies : numero de siniestro
      param in  pntramit : numero de tramitacion
      param in  pcidioma : codigo idioma
      param out pquery   : select de sin_tramita_gestion
      return             : number
   *************************************************************************/
   FUNCTION f_servicios(
      psgestio IN sin_tramita_gestion.sgestio%TYPE,
      pcidioma IN idiomas.cidioma%TYPE,
      pquery OUT VARCHAR2)
      RETURN NUMBER;

   /*************************************************************************
      Devuelve query de sin_tramita_detgestion
      param in  psgestio : clave de gestion
      param in  pcidioma : codigo de idioma
      param out pquery   : select de sin_tramita_localiza
      return             : number
   *************************************************************************/
   FUNCTION f_movimientos(
      psgestio IN sin_tramita_gestion.sgestio%TYPE,
      pcidioma IN idiomas.cidioma%TYPE,
      pquery OUT VARCHAR2)
      RETURN NUMBER;

   /*************************************************************************
      Devuelve query para sin_tramita_movgestion
      param in  psgestio : clave de gestion
      param in  pcidioma : codigo de idioma
      param out pquery   : select de sin_tramita_localiza
      return             : number
   *************************************************************************/
   FUNCTION f_lstlocalizacion(
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pntramit IN sin_tramitacion.ntramit%TYPE,
      pquery OUT VARCHAR2)
      RETURN NUMBER;

   /*************************************************************************
      Devuelve la lista de localizaciones
      param in  pnsinies : numero de siniestro
      param in  pctramit : numero de tramitacion
      param out mensajes : mesajes de error
      return             : number
   *************************************************************************/
   FUNCTION f_lsttipgestion(
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pntramit IN sin_tramitacion.ntramit%TYPE,
      pcidioma IN idiomas.cidioma%TYPE,
      pquery OUT VARCHAR2)
      RETURN NUMBER;

/*************************************************************************
  Devuelve query para carga lista de tipos de gestion
  param in  pnsinies  : numero de siniestro
  param in  pctramit  : tipo de tramitacion
  param in  pcidioma  : codigo idioma
  param out pquery    : select de listvalores
  return              : NUMBER 0 / 1
*************************************************************************/
   FUNCTION f_lsttipprof(
      pctipges IN sin_tramita_gestion.ctipges%TYPE,
      pcidioma IN idiomas.cidioma%TYPE,
      pquery OUT VARCHAR2)
      RETURN NUMBER;

/*************************************************************************
  Devuelve query para carga lista de tipos de profesional
  param in  pctipges  : tipo de gestion
  param in  pcidioma  : codigo idioma
  param out pquery    : select de listvalores
  return              : NUMBER 0 / 1
*************************************************************************/
   FUNCTION f_lstsubprof(
      pctipges IN sin_tramita_gestion.ctipges%TYPE,
      pctippro IN sin_tramita_gestion.ctippro%TYPE,
      pcidioma IN idiomas.cidioma%TYPE,
      pquery OUT VARCHAR2)
      RETURN NUMBER;

/*************************************************************************
  Devuelve query para carga lista de subtipos de profesional
  param in  pctipges  : tipo de gestion
  param in  pctippro  : tipo de profesional
  param in  pcidioma  : codigo idioma
  param out pquery    : select de listvalores
  return              : NUMBER 0 / 1
*************************************************************************/
   FUNCTION f_lstprofesional(
      pnsinies IN NUMBER,
      pntramit IN NUMBER,
      pnlocali IN NUMBER,
      pctippro IN NUMBER,
      pcsubpro IN NUMBER,
      psgestio IN NUMBER DEFAULT NULL,   --BUG 26630
      pquery OUT VARCHAR2)
      RETURN NUMBER;

/*************************************************************************
  Devuelve query para carga lista de profesionales
  param in  pnsinies  : numero de siniestro
  param in  pntramit  : numero de tramitacion
  param in  pnlocali  : numero de localizacion
  param in  pctippro  : tipo de profesional
  param in  pcsubpro  : subtipo de profesional
  param out pquery    : select
  return              : NUMBER 0 / 1
*************************************************************************/
   FUNCTION f_coef_pro(psprofes IN NUMBER)
      RETURN NUMBER;

/*************************************************************************
  Devuelve  total_gestiones_abiertas / carga_diaria
  param in  psprofes  : codigo de profesional
  return              : NUMBER
 *************************************************************************/
   FUNCTION f_lstsedes(psprofes IN sin_prof_profesionales.sprofes%TYPE, pquery OUT VARCHAR2)
      RETURN NUMBER;

/*************************************************************************
  Devuelve query para carga lista de sedes de un profesional
  param in  psprofes  : codigo profesional
  param out pquery    : select
  return              : NUMBER 0 / 1
*************************************************************************/
   FUNCTION f_lsttarifas(
      psprofes IN sin_prof_tarifa.sprofes%TYPE,
      pspersed IN sin_prof_tarifa.spersed%TYPE,
      pfecha IN sin_prof_tarifa.festado%TYPE,
      pcconven IN sin_codtramitador.cconven%TYPE,   --26630
      pcidioma IN idiomas.cidioma%TYPE,   --26630
      pquery OUT VARCHAR2)
      RETURN NUMBER;

/*************************************************************************
  Devuelve query para carga lista de los convenios/baremos de un profesional
  param in  psprofes  : codigo profesional
  param in  pspersed  : sede (sperson)
  param in  pfecha    : fecha de vigencia
  param out pquery    : select
  return              : NUMBER 0 / 1
*************************************************************************/
   FUNCTION f_lstgarantias(
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pctipges IN sin_tramita_gestion.ctipges%TYPE,
      pcidioma IN idiomas.cidioma%TYPE,
      pquery OUT VARCHAR2)
      RETURN NUMBER;

/*************************************************************************
  Devuelve query para carga lista de garantias contratadas
  param in  pnsinies  : numero de siniestro
  param in  pctipges  : tipo de gestion
  param in  pcidioma  : codigo idioma
  param out pquery    : select de listvalores
  return              : NUMBER 0 / 1
*************************************************************************/
   FUNCTION f_lstestados(
      pctipges IN sin_parges_movimientos.ctipges%TYPE,
      pctipmov IN sin_parges_movimientos.ctipmov%TYPE,
      pcidioma IN idiomas.cidioma%TYPE,
      pquery OUT VARCHAR2)
      RETURN NUMBER;

/*************************************************************************
  Devuelve query para carga lista de estados
  param in  pctipges  : tipo de gestion
  param in  pctipmov  : moviento
  param in  pcidioma  : codigo idioma
  param out pquery    : select de listvalores
  return              : NUMBER 0 / 1
*************************************************************************/
   FUNCTION f_lstsubestados(
      pctipges IN sin_parges_movimientos.ctipges%TYPE,
      pcestges IN sin_parges_movimientos.cestges%TYPE,
      pctipmov IN sin_parges_movimientos.ctipmov%TYPE,
      pcidioma IN idiomas.cidioma%TYPE,
      pquery OUT VARCHAR2)
      RETURN NUMBER;

/*************************************************************************
  Devuelve query para carga lista de subestados
  param in  pctipges  : tipo de gestion
  param in  pcestges  : estado gestion
  param in  pctipmov  : moviento
  param in  pcidioma  : codigo idioma
  param out pquery    : select de listvalores
  return              : NUMBER 0 / 1
*************************************************************************/
   FUNCTION f_lstmovimientos(
      pctipges IN sin_parges_mov_permitidos.ctipges%TYPE,
      pcestges IN sin_parges_mov_permitidos.cestges%TYPE,
      pcsubges IN sin_parges_mov_permitidos.csubges%TYPE,
      pcidioma IN idiomas.cidioma%TYPE,
      pquery OUT VARCHAR2)
      RETURN NUMBER;

/*************************************************************************
  Devuelve query para carga lista de movimientos permitidos
  param in  pctipges  : tipo de gestion
  param in  pcestges  : estado gestion
  param in  pctipmov  : moviento
  param in  pcidioma  : codigo idioma
  param out pquery    : select de listvalores
  return              : NUMBER 0 / 1
*************************************************************************/
   FUNCTION f_lstservicios(
      psservic IN NUMBER,
      ptdescri IN VARCHAR2,
      psconven IN NUMBER,
      pfecha IN DATE,
      pquery OUT VARCHAR2)
      RETURN NUMBER;

/*************************************************************************
   Devuelve query de servicios que cumplen una condicion
   param in  sservic  : codigo de servicio
   param in  tdescri  : descripcion de servicio
   param in  sconven  : numero de convenio/baremo
   param in  fecha    : fecha de vigencia
   param out pquery   : select de sin_dettarifas
   return             : NUMBER 0/1
 *************************************************************************/
   FUNCTION f_ins_gestion(
      psseguro IN sin_tramita_gestion.sseguro%TYPE,
      pnsinies IN sin_tramita_gestion.nsinies%TYPE,
      pntramit IN sin_tramita_gestion.ntramit%TYPE,
      pcgarant IN sin_tramita_gestion.cgarant%TYPE,
      pctipreg IN sin_tramita_gestion.ctipreg%TYPE,
      pctipges IN sin_tramita_gestion.ctipges%TYPE,
      psprofes IN sin_tramita_gestion.sprofes%TYPE,
      pctippro IN sin_tramita_gestion.ctippro%TYPE,
      pcsubpro IN sin_tramita_gestion.csubpro%TYPE,
      pspersed IN sin_tramita_gestion.spersed%TYPE,
      psconven IN sin_tramita_gestion.sconven%TYPE,
      pccancom IN sin_tramita_gestion.ccancom%TYPE,
      pccomdef IN sin_tramita_gestion.ccomdef%TYPE,
      ptrefext IN sin_tramita_gestion.trefext%TYPE,
      pnlocali IN sin_tramita_gestion.nlocali%TYPE,   -- 27276
      pfgestio IN sin_tramita_gestion.fgestio%TYPE,   -- 26630
      psgestio OUT sin_tramita_gestion.sgestio%TYPE)
      RETURN NUMBER;

/*************************************************************************
  Graba una fila en SIN_TRAMITA_GESTION
  return              : NUMBER 0 / 1
*************************************************************************/
   FUNCTION f_ins_detgestion(
      psgestio IN sin_tramita_detgestion.sgestio%TYPE,
      psservic IN sin_tramita_detgestion.sservic%TYPE,
      pncantid IN sin_tramita_detgestion.ncantid%TYPE,
      pcunimed IN sin_tramita_detgestion.cunimed%TYPE,
      pnvalser IN sin_tramita_detgestion.nvalser%TYPE,
      pcnocarg IN sin_tramita_detgestion.cnocarg%TYPE,
      pitotal IN sin_tramita_detgestion.itotal%TYPE,
      pccodmon IN sin_tramita_detgestion.ccodmon%TYPE,
      pfcambio IN sin_tramita_detgestion.fcambio%TYPE,
      pfalta IN sin_tramita_detgestion.falta%TYPE)
      RETURN NUMBER;

/*************************************************************************
  Graba una linea de detalle en SIN_TRAMITA_DETGESTION
  return              : NUMBER 0 / 1
*************************************************************************/
   FUNCTION f_ins_movgestion(
      psgestio IN sin_tramita_movgestion.sgestio%TYPE,
      pctipmov IN sin_tramita_movgestion.ctipmov%TYPE,
      pctipges IN sin_tramita_gestion.ctipges%TYPE,
      ptcoment IN sin_tramita_movgestion.tcoment%TYPE,
      pcestges IN sin_tramita_movgestion.cestges%TYPE,
      pcsubges IN sin_tramita_movgestion.csubges%TYPE)
      RETURN NUMBER;

/*************************************************************************
  Graba un movimiento de gestion en SIN_TRAMITA_MOVGESTION
  param in  psgestio  : clave de sin_tramita_gestion
  param in  pctipmov  : moviento
  param in  pctipges  : tipo de gestion
  return              : NUMBER 0 / 1
*************************************************************************/
   FUNCTION f_nom_prof(psprofes IN NUMBER)
      RETURN VARCHAR2;

/*************************************************************************
  Devuelve el nombre de un profesional
  return              : VARCHAR2
*************************************************************************/
   FUNCTION f_ajusta_reserva(
      psgestio IN NUMBER,
      pitotal IN NUMBER,
      pccodmon IN VARCHAR2,
      pmodo IN NUMBER)
      RETURN NUMBER;

/*************************************************************************
  Graba un movimiento de reserva
  param in sgestio    : clave de gestion
  param in itotal     : importe del movimiento
  param in ccodmon    : codigo de moneda
  param in modo       : 0-disminuye 1-aumenta
  return              : Number
*************************************************************************/
   FUNCTION f_val_gestiones_abiertas(
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pntramit IN sin_tramitacion.ntramit%TYPE)
      RETURN NUMBER;

/*************************************************************************
    Comprueba si hay gestiones pendientes en una tramitacion
    param in  pnsinies : numero de siniestro
    param in  pntramit : numero de tramitacion
    return             : number (total tramitaciones abiertas)
 *************************************************************************/
   FUNCTION f_profesional_destinatario(
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pntramit IN sin_tramitacion.ntramit%TYPE,
      psprofes IN sin_prof_profesionales.sprofes%TYPE)
      RETURN NUMBER;

/*************************************************************************
    Da de alta como destinatario al profesional asignado
    param in  pnsinies : numero de siniestro
    param in  pntramit : numero de tramitacion
    param in  psprofes : clave de proveedor
    return             : number
 *************************************************************************/
   FUNCTION f_apunte_agenda(
      psgestio IN sin_tramita_gestion.sgestio%TYPE,
      pcevento IN sin_prof_apuntes.cevento%TYPE,
      ptcoment IN sin_tramita_movgestion.tcoment%TYPE)
      RETURN NUMBER;

/*************************************************************************
    Da de alta apuntes predefinidos en agenda
    param in  psgestio : clave de gestiones
    param in  pcevento : clave de evento SIN_PROF_APUNTES
    return             : number
 *************************************************************************/
   FUNCTION f_crea_gestion(
      psseguro IN sin_tramita_gestion.sseguro%TYPE,
      pnsinies IN sin_tramita_gestion.nsinies%TYPE,
      pntramit IN sin_tramita_gestion.ntramit%TYPE,
      pnlocali IN sin_tramita_localiza.nlocali%TYPE,
      pcgarant IN sin_tramita_gestion.cgarant%TYPE,
      pctipges IN sin_tramita_gestion.ctipges%TYPE,
      pctippro IN sin_tramita_gestion.ctippro%TYPE,
      pcsubpro IN sin_tramita_gestion.csubpro%TYPE,
      psservic IN sin_dettarifas.sservic%TYPE,
      psgestio OUT sin_tramita_gestion.sgestio%TYPE)
      RETURN NUMBER;

/*************************************************************************
  Crea una gestion y la asigna automaticamente a un profesional
  return              : NUMBER 0 / 1
*************************************************************************/
   FUNCTION f_gestion_modificable(psgestio IN NUMBER, psi_o_no OUT NUMBER)
      RETURN NUMBER;

/*************************************************************************
   Decide si una gestion esta en un estado modificable
*************************************************************************/
   FUNCTION f_lstprofesional1(
      pnsinies IN NUMBER,
      pntramit IN NUMBER,
      pnlocali IN NUMBER,
      pctippro IN NUMBER,
      pcsubpro IN NUMBER,
      pquery OUT VARCHAR2)
      RETURN NUMBER;

/*************************************************************************
  Devuelve query para carga lista de profesionales (cquery = 1)
  (solo filtra por zona)
  param in  pnsinies  : numero de siniestro
  param in  pntramit  : numero de tramitacion
  param in  pnlocali  : numero de localizacion
  param in  pctippro  : tipo de profesional
  param in  pcsubpro  : subtipo de profesional
  param out pquery    : select
  return              : NUMBER 0 / 1
*************************************************************************/
   FUNCTION f_borra_detalle(psgestio IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_gestion_permitida(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      pctipges IN NUMBER,
      pcidioma IN NUMBER,
      ptlitera OUT VARCHAR2)
      RETURN NUMBER;

/*************************************************************************
   Decide si una gestion se puede dar de alta
*************************************************************************/
   FUNCTION f_estado_valoracion(psgestio IN NUMBER, pcsubges OUT NUMBER)
      RETURN NUMBER;

/*************************************************************************
   Decide el subestado de gestion de repuestos de autos
*************************************************************************/
--Bug 26630:NSS:10/07/2013
   FUNCTION f_get_servicios(
      psconven IN NUMBER,
      pstarifa IN NUMBER,
      pnlinea IN NUMBER,
      pquery OUT VARCHAR2)
      RETURN NUMBER;

/*************************************************************************
    Devuelve el servicio seleccionado o la lista, si es un servicio empaquetado
*************************************************************************/

   --INI bug 26630
   FUNCTION f_get_cfecha(pctipges IN NUMBER, pcfecha OUT NUMBER)
      RETURN NUMBER;

/*************************************************************************
   Devuelve si se debe mostrar la fecha o no
*************************************************************************/
   FUNCTION f_usuario_permitido(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      psgestio IN NUMBER,
      pctipmov IN NUMBER,
      pcpermit OUT NUMBER)
      RETURN NUMBER;

/*************************************************************************
   Devuelve si ese usuario puede realizar ese movimiento
*************************************************************************/
   FUNCTION f_cancela_pantalla(
      psconven IN NUMBER,
      psprofes IN NUMBER,
      pnsinies IN NUMBER,
      pntramit IN NUMBER)
      RETURN NUMBER;

/*************************************************************************
   Si se ha dado de alta algun convio temporal, se eliminan esos datos.
*************************************************************************/
   FUNCTION f_get_acceso_tramitador(
      pnsinies IN NUMBER,
      pntramit IN NUMBER,
      pcconven OUT NUMBER)
      RETURN NUMBER;

/*************************************************************************
   Devuelve si el tramitador tiene acceso a convenios inactivos y temporales (0-No, 1-Si)
*************************************************************************/
--FIN bug 26630
   FUNCTION f_reserva_autos(psgestio IN NUMBER)
      RETURN NUMBER;
/*************************************************************************
   Anula la reserva inicial
*************************************************************************/
   FUNCTION f_agenda_asignacion(
      psgestio IN NUMBER,
      pcevento IN VARCHAR2)
      RETURN NUMBER;
END pac_gestiones;

/

  GRANT EXECUTE ON "AXIS"."PAC_GESTIONES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_GESTIONES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_GESTIONES" TO "PROGRAMADORESCSI";
