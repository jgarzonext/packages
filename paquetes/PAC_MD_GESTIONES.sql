--------------------------------------------------------
--  DDL for Package PAC_MD_GESTIONES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_MD_GESTIONES" AS
/******************************************************************************
   NOMBRE:    PAC_MD_GESTIONES
   PROPÓSITO: Funciones para gestiones en siniestros

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
    1.0       24/08/2011   ASN             Creacion
******************************************************************************/
   FUNCTION f_opencursor(squery IN VARCHAR2, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Abre un cursor con la sentencia suministrada
      param in squery    : consulta a executar
      param out mensajes : mesajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_gestiones(
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pntramit IN sin_tramitacion.ntramit%TYPE,
      t_gestiones OUT t_iax_sin_tramita_gestion,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Devuelve la lista de gestiones para carga del bloque en tramitacion
      param in  pnsinies : numero de siniestro
      param in  pntramit : numero de tramitacion
      param out mensajes : mesajes de error
      return             : number
   *************************************************************************/
   FUNCTION f_get_detgestiones(
      psgestio IN NUMBER,
      t_detgestiones OUT t_iax_sin_tramita_detgestion,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Llena objeto servicios de una gestion para carga en el objeto gestion
      param in  psgestio       : numero de gestion
      param out t_detgestiones : t_iax_sin_tramita_detgestion
      param out mensajes       : mesajes de error
      return                   : number
   *************************************************************************/
   FUNCTION f_get_movgestiones(
      psgestio IN NUMBER,
      t_movgestiones OUT t_iax_sin_tramita_movgestion,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Llena objeto movimientos de una gestion para carga en el objeto gestion
      param in  psgestio       : numero de gestion
      param out t_movgestiones : t_iax_sin_tramita_movgestion
      param out mensajes       : mesajes de error
      return                   : number
   *************************************************************************/
   FUNCTION f_get_lstlocalizacion(
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pntramit IN sin_tramitacion.ntramit%TYPE,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Devuelve la lista de localizaciones
      param in  pnsinies : numero de siniestro
      param in  pntramit : numero de tramitacion
      param out mensajes : mesajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_lsttipgestion(
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pctramit IN sin_tramitacion.ctramit%TYPE,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Crea cursor para el valor fijo 722 - Tipo de Gestion
      param in  pnsinies : numero de siniestro
      param in  pctramit : tipo de tramitacion
      param out mensajes : mesajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_lsttipprof(
      pctipges IN sin_tramita_gestion.ctipges%TYPE,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Crea cursor para el valor fijo 724 - Tipo Profesional
      param in  pctipges : tipo de gestion
      param out mensajes : mesajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstsubprof(
      pctipges IN sin_tramita_gestion.ctipges%TYPE,
      pctippro IN sin_prof_tipoprof.ctippro%TYPE,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Crea cursor para el valor fijo 725 - Subtipo Profesional
      param in  pctipges : tipo de gestion
      param in  pctippro : tipo profesional
      param out mensajes : mesajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstprofesional(
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pntramit IN sin_tramitacion.ntramit%TYPE,
      pnlocali IN NUMBER,
      pctippro IN NUMBER,
      pcsubpro IN NUMBER,
      psgestio IN NUMBER DEFAULT NULL,   --26630
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
       Devuelve query para carga lista de profesionales
       param in  pnsinies  : numero de siniestro
       param in  pntramit  : numero de tramitacion
       param in  pnlocali  : numero de localizacion
       param in  pctippro  : tipo de profesional
       param in  pcsubpro  : subtipo de profesional
    *************************************************************************/
   FUNCTION f_get_lstsedes(psprofes IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Crea cursor para la lista de sedes del Profesional
      param in  psprofes : codigo profesional
      param out mensajes : mesajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_lsttarifas(
      psprofes IN NUMBER,
      pspersed IN NUMBER,
      pfecha IN DATE,
      pcconven IN NUMBER,   --26630
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Crea cursor para la lista de convenios/baremos de un profesional
      param in  psprofes : codigo profesional
      param in  pspersed : clave sede (personas)
      param in  pfecha   : fecha de vigencia del convenio/baremo
      param out mensajes : mesajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstgarantias(
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pctipges IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Crea cursor para la lista de garantias contratadas
      param in  nsinies  : numero de siniestro
      param in  ctipges  : tipo de gestion
      param out mensajes : mesajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstestados(
      pctipges IN NUMBER,
      pctipmov IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Crea cursor para la lista de estados posibles para un tipo de gestion y movimiento
      param in  ctipges  : tipo de gestion
      param in  ctipmov  : movimiento
      param out mensajes : mesajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstsubestados(
      pctipges IN NUMBER,
      pcestges IN NUMBER,
      pctipmov IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Crea cursor para la lista de subestados posibles para un tipo de gestion, estado y movimiento
      param in  ctipges  : tipo de gestion
      param in  cestges  : estado gestion
      param in  ctipmov  : movimiento
      param out mensajes : mesajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstmovimientos(
      pctipges IN NUMBER,
      pcestges IN NUMBER,
      pcsubges IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Crea cursor de movimientos permitidos para una gestion en funcion del estado
      param in  ctipges  : tipo de gestion
      param in  cestges  : estado gestion
      param in  csubges  : subestado gestion
      param out mensajes : mesajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstservicios(
      psservic IN NUMBER,
      ptdescri IN VARCHAR2,
      psconven IN NUMBER,
      pfecha IN DATE,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Crea cursor de servicios
      param in  sservic  : codigo de servicio
      param in  tdescri  : descripcion de servicio
      param in  sconven  : numero de convenio/baremo
      param in  fecha    : fecha de vigencia
      param out mensajes : mesajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_precio_servicio(
      psconven IN NUMBER,
      pnvalser IN NUMBER,
      pccodmon IN VARCHAR2,
      pctipcal IN NUMBER,
      piprecio OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Devuelve el precio de un servicio
      param in  sconven  : clave de convenio/baremo
      param in  nvalser  : valor unitario
      param in  ccodmon  : codigo moneda
      param in  ctipcal  : tipo de calculo cambio
      param in  itotal   : total
      param out mensajes : mesajes de error
      return             : number 0/1
   *************************************************************************/
   FUNCTION f_get_imp_servicio(
      psconven IN NUMBER,
      pnvalser IN NUMBER,
      pccodmon IN VARCHAR2,
      pctipcal IN NUMBER,
      pncantid IN NUMBER,
      pcnocarg IN NUMBER,
      pitotal OUT NUMBER,
      piminimo OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Devuelve el precio TOTAL de un servicio
      param in  sconven  : clave de convenio/baremo
      param in  nvalser  : valor unitario
      param in  ccodmon  : codigo moneda
      param in  ctipcal  : tipo de calculo cambio
      param in  ncantid  : cantidad
      param in  cnocarg  : 0 = sin cargo
      param in  itotal   : total
      param out mensajes : mesajes de error
      return             : number 0/1
   *************************************************************************/
   FUNCTION f_set_obj_gestion(
      psseguro NUMBER,
      pnsinies VARCHAR2,
      pntramit NUMBER,
      pnlocali NUMBER,
      pcgarant NUMBER,
      psgestio NUMBER,
      pctipreg NUMBER,
      pctipges NUMBER,
      psprofes NUMBER,
      pctippro NUMBER,
      pcsubpro NUMBER,
      pspersed NUMBER,
      psconven NUMBER,
--      PCESTGES NUMBER,
--      PCSUBGES NUMBER,
      pccancom NUMBER,
      pccomdef NUMBER,
      ptrefext VARCHAR2,
      ptobserv VARCHAR2,
      pobjeto OUT ob_iax_sin_tramita_gestion,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

      /*************************************************************************
       Graba en una variable global de la capa IAX los valores del objeto ob_iax_gestion
         param in SSEGURO NUMBER 'Clave de la tabla SEGUROS',
         param in NSINIES VARCHAR2 'Numero de siniestro',
         param in NTRAMIT NUMBER 'Numero tramitacion',
         param in NLOCALI NUMBER 'Numero de localizacion',
         param in CGARANT NUMBER 'Codigo de garantia',
         param in SGESTIO NUMBER 'Secuencial. Codigo unico de gestion (PK)',
         param in CTIPREG NUMBER 'Tipo Registro: Varios, Peritaje, Gasto Sanitario, Mesa Repuestos.',
         param in CTIPGES NUMBER 'Tipo Gestion.',
         param in SPROFES NUMBER 'Clave de la tabla Profesionales',
         param in CTIPPRO NUMBER 'Tipo de profesional'
         param in CSUBPRO NUMBER 'Subtipo profesional'
         param in SPERSED NUMBER 'Clave de la sede (sperson)',
         param in SCONVEN NUMBER 'Numero de Convenio',
   --      param in CESTGES NUMBER 'Estado de la gestion',
   --      param in CSUBGES NUMBER 'Subestado de la gestion.',
         param in CCANCOM NUMBER 'Canal de comunicacion,
         param in CCOMDEF NUMBER 'Comunicacion por defecto (Mant. Proveedores) 0-No 1-Si',
         param in TREFEXT VARCHAR2 'Referencia externa',
         param in TOBSERV VARCHAR2 'Observaciones'
         param out mensajes : mesajes de error
         return             : 0/1
       *************************************************************************/
   FUNCTION f_set_gestion(
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
      pfgestio IN sin_tramita_gestion.fgestio%TYPE,   -- 26630:NSS:04/07/2013
      psgestio OUT sin_tramita_gestion.sgestio%TYPE,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

/*************************************************************************
  Graba una gestion
      param in SSEGURO NUMBER 'Clave de la tabla SEGUROS',
      param in NSINIES VARCHAR2 'Numero de siniestro',
      param in NTRAMIT NUMBER 'Numero tramitacion',
      param in NLOCALI NUMBER 'Numero de localizacion',
      param in CGARANT NUMBER 'Codigo de garantia',
      param in CTIPREG NUMBER 'Tipo Registro: Varios, Peritaje, Gasto Sanitario, Mesa Repuestos.',
      param in CTIPGES NUMBER 'Tipo Gestion.',
      param in SPROFES NUMBER 'Clave de la tabla Profesionales',
      param in SPERSED NUMBER 'Clave de la sede (sperson)',
      param in SCONVEN NUMBER 'Numero de Convenio',
      param in CESTGES NUMBER 'Estado de la gestion',
      param in CSUBGES NUMBER 'Subestado de la gestion.',
      param in CCANCOM NUMBER 'Canal de comunicacion,
      param in CCOMDEF NUMBER 'Comunicacion por defecto (Mant. Proveedores) 0-No 1-Si',
      param in TREFEXT VARCHAR2 'Referencia externa',
      param out SGESTIO NUMBER 'Secuencial. Codigo unico de gestion (PK)',
      param out mensajes : mesajes de error
      return             : 0/1
*************************************************************************/
   FUNCTION f_set_detgestion(
      psgestio IN sin_tramita_detgestion.sgestio%TYPE,
      psservic IN sin_tramita_detgestion.sservic%TYPE,
      pncantid IN sin_tramita_detgestion.ncantid%TYPE,
      pcunimed IN sin_tramita_detgestion.cunimed%TYPE,
      pnvalser IN sin_tramita_detgestion.nvalser%TYPE,
      pcnocarg IN sin_tramita_detgestion.cnocarg%TYPE,
      pitotal IN sin_tramita_detgestion.itotal%TYPE,
      pccodmon IN sin_tramita_detgestion.ccodmon%TYPE,
      pfcambio IN sin_tramita_detgestion.fcambio%TYPE,
      pfalta IN sin_tramita_detgestion.falta%TYPE,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

/*************************************************************************
  Graba una linea de detalle de gestion
  return              : NUMBER 0 / 1
*************************************************************************/
   FUNCTION f_set_movgestion(
      psgestio IN sin_tramita_movgestion.sgestio%TYPE,
      pctipmov IN sin_tramita_movgestion.ctipmov%TYPE,
      pctipges IN sin_tramita_gestion.ctipges%TYPE,
      ptcoment IN sin_tramita_movgestion.tcoment%TYPE,
      pcestges IN sin_tramita_movgestion.cestges%TYPE,
      pcsubges IN sin_tramita_movgestion.csubges%TYPE,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

/*************************************************************************
  Graba un movimiento de gestion
  param in  psgestio  : clave de sin_tramita_gestion
  param in  pctipmov  : moviento
  param in  pctipges  : tipo de gestion
  return              : NUMBER 0 / 1
*************************************************************************/
   FUNCTION f_get_servicio(
      psconven IN NUMBER,
      psservic IN NUMBER,
      pncantid IN NUMBER,
      ptservic OUT VARCHAR2,
      pcunimed OUT NUMBER,
      ptunimed OUT VARCHAR2,
      pnvalser OUT NUMBER,
      pccodmon OUT VARCHAR2,
      ptmoneda OUT VARCHAR2,
      piminimo OUT NUMBER,
      pctipcal OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_gestion_modificable(
      psgestio IN NUMBER,
      psi_o_no OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

/*************************************************************************
   Decide si una gestion esta en un estado modificable
*************************************************************************/
   FUNCTION f_impacto_reserva(
      psgestio IN NUMBER,
      pctipges IN NUMBER,
      psi_o_no OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

/*************************************************************************
   Devuelve 1 si la gestion ha tenido impacto sobre la reserva
*************************************************************************/
   FUNCTION f_ajusta_reserva(
      psgestio IN NUMBER,
      psigno IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

/*************************************************************************
   Aumenta o disminuye la reserva para una gestion
*************************************************************************/
   FUNCTION f_borra_detalle(psgestio IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_gestion_permitida(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      pctipges IN NUMBER,
      ptlitera OUT VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

/*************************************************************************
   Decide si una gestion se puede dar de alta
*************************************************************************/
   FUNCTION f_estado_valoracion(
      psgestio IN NUMBER,
      pcsubges OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

/*************************************************************************
   Decide el estado de la gestion de repuestos
*************************************************************************/
   FUNCTION f_get_servicios(
      psconven IN NUMBER,
      pstarifa IN NUMBER,
      pnlinea IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

/*************************************************************************
    Devuelve el servicio seleccionado o la lista, si es un servicio empaquetado
*************************************************************************/
--INI bug 26630
   FUNCTION f_get_cfecha(pctipges IN NUMBER, pcfecha OUT NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

/*************************************************************************
   Devuelve si se debe mostrar la fecha o no
*************************************************************************/
   FUNCTION f_usuario_permitido(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      psgestio IN NUMBER,
      pctipmov IN NUMBER,
      pcpermit OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

/*************************************************************************
   Devuelve si ese usuario puede realizar ese movimiento
*************************************************************************/
   FUNCTION f_cancela_pantalla(
      psconven IN NUMBER,
      psprofes IN NUMBER,
      pnsinies IN NUMBER,
      pntramit IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

/*************************************************************************
   Si se ha dado de alta algun convio temporal, se eliminan esos datos.
*************************************************************************/
   FUNCTION f_get_acceso_tramitador(
      pnsinies IN NUMBER,
      pntramit IN NUMBER,
      pcconven OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;
/*************************************************************************
   Devuelve si el tramitador tiene acceso a convenios inactivos y temporales (0-No, 1-Si)
*************************************************************************/
--FIN bug 26630
END pac_md_gestiones;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_GESTIONES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_GESTIONES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_GESTIONES" TO "PROGRAMADORESCSI";
