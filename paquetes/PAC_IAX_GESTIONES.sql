--------------------------------------------------------
--  DDL for Package PAC_IAX_GESTIONES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_IAX_GESTIONES" AS
/******************************************************************************
   NOMBRE:    PAC_IAX_GESTIONES
   PROPÓSITO: Funciones para gestiones en siniestros

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
    1.0       24/08/2011   ASN             Creacion
******************************************************************************/
   vgobgestion    ob_iax_sin_tramita_gestion;

   FUNCTION f_get_gestiones(
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pntramit IN sin_tramitacion.ntramit%TYPE,
      gestiones OUT t_iax_sin_tramita_gestion,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Devuelve la lista de gestiones para carga del bloque en tramitacion
      param in  pnsinies : numero de siniestro
      param in  pntramit : numero de tramitacion
      param out mensajes : mesajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_detgestiones(
      psgestio IN NUMBER,
      t_detgestiones OUT t_iax_sin_tramita_detgestion,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Devuelve la lista de servicios para carga del bloque en tramitacion
      param in  psgestio : clave de gestiones
      param out mensajes : mesajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_movgestiones(
      psgestio IN NUMBER,
      t_movgestiones OUT t_iax_sin_tramita_movgestion,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Devuelve la lista de movimientos de gestion para carga del bloque en tramitacion
      param in  psgestio : clave de gestiones
      param out mensajes : mesajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstlocalizacion(
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pntramit IN sin_tramitacion.ntramit%TYPE,
      mensajes OUT t_iax_mensajes)
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
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Devuelve la lista de tipos de gestion
      param in  pnsinies : numero de siniestro
      param in  pctramit : tipo de tramitacion
      param out mensajes : mesajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_lsttipprof(pctipges IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Devuelve la lista de tipos de profesional para un tipo de gestion
      param in  ctipges  : tipo de gestion
      param out mensajes : mesajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstsubprof(
      pctipges IN NUMBER,
      pctippro IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Devuelve la lista de subtipos de profesional para un tipo
      param in  ctippro  : tipo de profesional
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
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
       Devuelve lista de profesionales
       param in  pnsinies  : numero de siniestro
       param in  pntramit  : numero de tramitacion
       param in  pnlocali  : numero de localizacion
       param in  pctippro  : tipo de profesional
       param in  pcsubpro  : subtipo de profesional
       return              : ref cursor
    *************************************************************************/
   FUNCTION f_get_lstsedes(psprofes IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Devuelve la lista de sedes de un profesional
      param in  csprofes : codigo profesional
      param out mensajes : mesajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_lsttarifas(
      psprofes IN NUMBER,
      pspersed IN NUMBER,
      pfecha IN DATE,
      pcconven IN NUMBER,   --26630
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Devuelve los convenios/baremos de un profesional
      param in  csprofes : codigo profesional
      param out mensajes : mesajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstgarantias(
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pctipges IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Devuelve las garantias contratadas
      param in  nsinies  : numero de siniestro
      param in  ctipges  : tipo de gestion
      param out mensajes : mesajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstestados(
      pctipges IN NUMBER,
      pctipmov IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Devuelve la lista de estados posibles para un tipo de gestion y movimiento
      param in  ctipges  : tipo de gestion
      param in  ctipmov  : movimiento
      param out mensajes : mesajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstsubestados(
      pctipges IN NUMBER,
      pcestges IN NUMBER,
      pctipmov IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Devuelve la lista de subestados posibles para un tipo de gestion, estado y movimiento
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
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Devuelve la lista de movimientos permitidos para una gestion en funcion del estado
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
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Devuelve la lista de servicios
      param in  sservic  : codigo de servicio
      param in  tdescri  : descripcion de servicio
      param in  sconven  : clave convenio
      param in  fecha    : fecha de vigencia
      param out mensajes : mesajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_ini_servicios(mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   Inicializa la tabla de servicios en el objeto gestiones
   *************************************************************************/
   FUNCTION f_sel_servicio(
      psconven IN NUMBER,
      pnvalser IN NUMBER,
      pccodmon IN VARCHAR2,
      pctipcal IN NUMBER,
      piprecio OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Devuelve el precio unitario de un servicio
   *************************************************************************/
   FUNCTION f_desel_servicio(psservic IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Elimina el servicio de la coleccion de servicios del objeto gestion
      param in  sservic  : codigo de servicio
      param out mensajes : mesajes de error
      return             : number
   *************************************************************************/
   FUNCTION f_get_obj_gestion(
      psseguro OUT NUMBER,
      pnsinies OUT sin_siniestro.nsinies%TYPE,
      pntramit OUT sin_tramitacion.ntramit%TYPE,
      pnlocali OUT NUMBER,
      pcgarant OUT NUMBER,
      psgestio OUT NUMBER,
      pctipreg OUT NUMBER,
      pctipges OUT NUMBER,
      psprofes OUT NUMBER,
      pctippro OUT NUMBER,
      pcsubpro OUT NUMBER,
      pspersed OUT NUMBER,
      psconven OUT NUMBER,
      pccancom OUT NUMBER,
      pccomdef OUT NUMBER,
      ptrefext OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_set_obj_gestion(
      psseguro IN NUMBER,
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      pnlocali IN NUMBER,
      pcgarant IN NUMBER,
      psgestio IN NUMBER,
      pctipreg IN NUMBER,
      pctipges IN NUMBER,
      psprofes IN NUMBER,
      pctippro IN NUMBER,
      pcsubpro IN NUMBER,
      pspersed IN NUMBER,
      psconven IN NUMBER,
      pccancom IN NUMBER,
      pccomdef IN NUMBER,
      ptrefext IN VARCHAR2,
      ptobserv IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
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
      param in CCANCOM NUMBER 'Canal de comunicacion,
      param in CCOMDEF NUMBER 'Comunicacion por defecto (Mant. Proveedores) 0-No 1-Si',
      param in TREFEXT VARCHAR2 'Referencia externa',
      param in TOBSERV VARCHAR2 'Observaciones'
      param out mensajes : mesajes de error
      return             : 0/1
    *************************************************************************/
   FUNCTION f_set_gestion(
      pmodo IN VARCHAR2,   -- 25913:ASN:11/02/13
      psgestio IN sin_tramita_gestion.sgestio%TYPE,   -- 25913:ASN:11/02/13
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
      pcestges IN sin_tramita_movgestion.cestges%TYPE,
      pcsubges IN sin_tramita_movgestion.csubges%TYPE,
      pnlocali IN sin_tramita_gestion.nlocali%TYPE,   -- 27276
      pfgestio IN sin_tramita_gestion.fgestio%TYPE,   -- 26630:NSS:04/07/2013
      pservicios IN VARCHAR2,
      psgestio_out OUT sin_tramita_gestion.sgestio%TYPE,
      ptlitera OUT axis_literales.tlitera%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Graba la gestion, el movimiento de alta y su detalle
      param out mensajes : mesajes de error
      return             : number
   *************************************************************************/
   FUNCTION f_set_movgestion(
      psgestio IN NUMBER,
      pctipmov IN NUMBER,
      pctipges IN NUMBER,
      pcestges IN NUMBER,
      pcsubges IN NUMBER,
      ptcoment IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

/*************************************************************************
   Graba un movimiento de gestion
   param out mensajes : mesajes de error
   return             : number
*************************************************************************/
   FUNCTION f_set_obj_servicio(
      psgestio IN NUMBER,
      psconven IN NUMBER,
      psservic IN NUMBER,
      pncantid IN NUMBER,
      pnvalser IN NUMBER,
      pitotal IN NUMBER,
      pcnocarg IN NUMBER,
      pfalta IN DATE,
      vobjservicio OUT ob_iax_sin_tramita_detgestion,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

/*************************************************************************
   Copia el servicio seleccionado en la coleccion de servicios del objeto gestion
   param in  sgestio
   param in  sconven  : codigo convenio
   param in  sservic  : codigo de servicio
   param in  ncantid  : cantidad
   param in  cnocarg  : 0 = sin cargo
   param out mensajes : mesajes de error
   return             : number
*************************************************************************/
   FUNCTION f_gestion_modificable(
      psgestio IN NUMBER,
      psi_o_no OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

/*************************************************************************
   Decide si una gestion esta en un estado modificable
*************************************************************************/
   FUNCTION f_gestion_permitida(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      pctipges IN NUMBER,
      ptlitera OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

/*************************************************************************
   Decide si una gestion se puede dar de alta
*************************************************************************/
   FUNCTION f_get_servicios(
      psconven IN NUMBER,
      pstarifa IN NUMBER,
      pnlinea IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

/*************************************************************************
    Devuelve el servicio seleccionado o la lista, si es un servicio empaquetado
*************************************************************************/--INI bug 26630
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
END pac_iax_gestiones;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_GESTIONES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_GESTIONES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_GESTIONES" TO "PROGRAMADORESCSI";
