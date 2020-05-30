--------------------------------------------------------
--  DDL for Package Body PAC_IAX_GESTIONES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IAX_GESTIONES" AS
/******************************************************************************
   NOMBRE:    PAC_IAX_GESTIONES
   PROPÓSITO: Funciones para gestiones en siniestros

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
    1.0       24/08/2011   ASN             Creacion
******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   FUNCTION f_get_gestiones(
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pntramit IN sin_tramitacion.ntramit%TYPE,
      gestiones OUT t_iax_sin_tramita_gestion,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      /*************************************************************************
         Devuelve la lista de gestiones para carga del bloque en tramitacion
         param in  pnsinies : numero de siniestro
         param in  pntramit : numero de tramitacion
         param out mensajes : mesajes de error
         return             : ref cursor
      *************************************************************************/
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100) := '';
      vobject        VARCHAR2(200) := 'PAC_IAX_GESTIONES. f_get_gestiones ';
      verror         NUMBER;
   BEGIN
      verror := pac_md_gestiones.f_get_gestiones(pnsinies, pntramit, gestiones, mensajes);

      IF verror <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN verror;
   EXCEPTION
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam,
                                           verror);
         RETURN verror;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN verror;
   END f_get_gestiones;

   FUNCTION f_get_detgestiones(
      psgestio IN NUMBER,
      t_detgestiones OUT t_iax_sin_tramita_detgestion,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      /*************************************************************************
         Devuelve la lista de servicios para carga del bloque en tramitacion
         param in  psgestio : clave de gestiones
         param out mensajes : mesajes de error
         return             : ref cursor
      *************************************************************************/
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100) := '';
      vobject        VARCHAR2(200) := 'PAC_IAX_GESTIONES. f_get_detgestiones ';
      verror         NUMBER;
   BEGIN
      verror := pac_md_gestiones.f_get_detgestiones(psgestio, t_detgestiones, mensajes);

      IF verror <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN cur;
   EXCEPTION
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam,
                                           verror);
         RETURN cur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_detgestiones;

   FUNCTION f_get_movgestiones(
      psgestio IN NUMBER,
      t_movgestiones OUT t_iax_sin_tramita_movgestion,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      /*************************************************************************
         Devuelve la lista de movimientos de gestion para carga del bloque en tramitacion
         param in  psgestio : clave de gestiones
         param out mensajes : mesajes de error
         return             : ref cursor
      *************************************************************************/
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100) := '';
      vobject        VARCHAR2(200) := 'PAC_IAX_GESTIONES. f_get_movgestiones ';
      verror         NUMBER;
   BEGIN
      verror := pac_md_gestiones.f_get_movgestiones(psgestio, t_movgestiones, mensajes);

      IF verror <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN cur;
   EXCEPTION
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam,
                                           verror);
         RETURN cur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_movgestiones;

   FUNCTION f_get_lstlocalizacion(
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pntramit IN sin_tramitacion.ntramit%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      /*************************************************************************
         Devuelve la lista de localizaciones
         param in  pnsinies : numero de siniestro
         param in  pntramit : numero de tramitacion
         param out mensajes : mesajes de error
         return             : ref cursor
      *************************************************************************/
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100) := '';
      vobject        VARCHAR2(200) := 'PAC_IAX_GESTIONES. f_get_lstlocalizacion ';
   BEGIN
      cur := pac_md_gestiones.f_get_lstlocalizacion(pnsinies, pntramit, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstlocalizacion;

   FUNCTION f_get_lsttipgestion(
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pctramit IN sin_tramitacion.ctramit%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      /*************************************************************************
         Devuelve la lista de tipos de gestion
         param in  pnsinies : numero de siniestro
         param in  pctramit : tipo de tramitacion
         param out mensajes : mesajes de error
         return             : ref cursor
      *************************************************************************/
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100) := '';
      vobject        VARCHAR2(200) := 'PAC_IAX_GESTIONES. f_get_lsttipgestion ';
   BEGIN
      cur := pac_md_gestiones.f_get_lsttipgestion(pnsinies, pctramit, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lsttipgestion;

   FUNCTION f_get_lsttipprof(pctipges IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      /*************************************************************************
         Devuelve la lista de tipos de profesional para un tipo de gestion
         param in  ctipges  : tipo de gestion
         param out mensajes : mesajes de error
         return             : ref cursor
      *************************************************************************/
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100) := '';
      vobject        VARCHAR2(200) := 'PAC_IAX_GESTIONES. f_get_lsttipprof ';
   BEGIN
      cur := pac_md_gestiones.f_get_lsttipprof(pctipges, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lsttipprof;

   FUNCTION f_get_lstsubprof(
      pctipges IN NUMBER,
      pctippro IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      /*************************************************************************
         Devuelve la lista de subtipos de profesional para un tipo
         param in  ctippro  : tipo de profesional
         param out mensajes : mesajes de error
         return             : ref cursor
      *************************************************************************/
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100) := '';
      vobject        VARCHAR2(200) := 'PAC_IAX_GESTIONES. f_get_lstsubprof ';
   BEGIN
      cur := pac_md_gestiones.f_get_lstsubprof(pctipges, pctippro, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstsubprof;

   FUNCTION f_get_lstprofesional(
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pntramit IN sin_tramitacion.ntramit%TYPE,
      pnlocali IN NUMBER,
      pctippro IN NUMBER,
      pcsubpro IN NUMBER,
      psgestio IN NUMBER DEFAULT NULL,   --26630
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      /*************************************************************************
          Devuelve lista de profesionales
          param in  pnsinies  : numero de siniestro
          param in  pntramit  : numero de tramitacion
          param in  pnlocali  : numero de localizacion
          param in  pctippro  : tipo de profesional
          param in  pcsubpro  : subtipo de profesional
          return              : ref cursor
       *************************************************************************/
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100) := '';
      vobject        VARCHAR2(200) := 'PAC_IAX_GESTIONES. f_get_lstprofesional ';
   BEGIN
      cur := pac_md_gestiones.f_get_lstprofesional(pnsinies, pntramit, pnlocali, pctippro,
                                                   pcsubpro, psgestio,   --26630
                                                   mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstprofesional;

   FUNCTION f_get_lstsedes(psprofes IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      /*************************************************************************
         Devuelve la lista de sedes de un profesional
         param in  csprofes : codigo profesional
         param out mensajes : mesajes de error
         return             : ref cursor
      *************************************************************************/
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100) := '';
      vobject        VARCHAR2(200) := 'PAC_IAX_GESTIONES. f_get_lstsedes ';
   BEGIN
      cur := pac_md_gestiones.f_get_lstsedes(psprofes, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstsedes;

   FUNCTION f_get_lsttarifas(
      psprofes IN NUMBER,
      pspersed IN NUMBER,
      pfecha IN DATE,
      pcconven IN NUMBER,   --26630
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      /*************************************************************************
         Devuelve los convenios/baremos de un profesional
         param in  psprofes : codigo profesional
         param in  pspersed : clave sede (personas)
         param out mensajes : mesajes de error
         return             : ref cursor
      *************************************************************************/
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100) := '';
      vobject        VARCHAR2(200) := 'PAC_IAX_GESTIONES. f_get_lsttarifas ';
      vpfecha        DATE;
   BEGIN
      IF pfecha IS NULL THEN
         vpfecha := f_sysdate();
      ELSE
         vpfecha := pfecha;
      END IF;

      cur := pac_md_gestiones.f_get_lsttarifas(psprofes, pspersed, vpfecha, pcconven,   --26630
                                               mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lsttarifas;

   FUNCTION f_get_lstgarantias(
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pctipges IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      /*************************************************************************
         Devuelve las garantias contratadas
         param in  nsinies  : numero de siniestro
         param in  ctipges  : tipo de gestion
         param out mensajes : mesajes de error
         return             : ref cursor
      *************************************************************************/
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100) := '';
      vobject        VARCHAR2(200) := 'PAC_IAX_GESTIONES. f_get_lstgarantias ';
   BEGIN
      cur := pac_md_gestiones.f_get_lstgarantias(pnsinies, pctipges, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstgarantias;

   FUNCTION f_get_lstestados(
      pctipges IN NUMBER,
      pctipmov IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      /*************************************************************************
         Devuelve la lista de estados posibles para un tipo de gestion y movimiento
         param in  ctipges  : tipo de gestion
         param in  ctipmov  : movimiento
         param out mensajes : mesajes de error
         return             : ref cursor
      *************************************************************************/
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100) := '';
      vobject        VARCHAR2(200) := 'PAC_IAX_GESTIONES. f_get_lstestados ';
   BEGIN
      cur := pac_md_gestiones.f_get_lstestados(pctipges, pctipmov, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstestados;

   FUNCTION f_get_lstsubestados(
      pctipges IN NUMBER,
      pcestges IN NUMBER,
      pctipmov IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      /*************************************************************************
         Devuelve la lista de subestados posibles para un tipo de gestion, estado y movimiento
         param in  ctipges  : tipo de gestion
         param in  cestges  : estado gestion
         param in  ctipmov  : movimiento
         param out mensajes : mesajes de error
         return             : ref cursor
      *************************************************************************/
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100) := '';
      vobject        VARCHAR2(200) := 'PAC_IAX_GESTIONES. f_get_lstsubestados ';
   BEGIN
      cur := pac_md_gestiones.f_get_lstsubestados(pctipges, pcestges, pctipmov, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstsubestados;

   FUNCTION f_get_lstmovimientos(
      pctipges IN NUMBER,
      pcestges IN NUMBER,
      pcsubges IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      /*************************************************************************
         Devuelve la lista de movimientos permitidos para una gestion en funcion del estado
         param in  ctipges  : tipo de gestion
         param in  cestges  : estado gestion
         param in  csubges  : subestado gestion
         param out mensajes : mesajes de error
         return             : ref cursor
      *************************************************************************/
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100) := '';
      vobject        VARCHAR2(200) := 'PAC_IAX_GESTIONES. f_set_lstmovimientos ';
   BEGIN
      cur := pac_md_gestiones.f_get_lstmovimientos(pctipges, pcestges, pcsubges, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstmovimientos;

   FUNCTION f_get_lstservicios(
      psservic IN NUMBER,
      ptdescri IN VARCHAR2,
      psconven IN NUMBER,
      pfecha IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      /*************************************************************************
         Devuelve la lista de servicios
         param in  sservic  : codigo de servicio
         param in  tdescri  : descripcion de servicio
         param in  sconven  : clave convenio
         param in  fecha    : fecha de vigencia
         param out mensajes : mesajes de error
         return             : ref cursor
      *************************************************************************/
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100) := '';
      vobject        VARCHAR2(200) := 'PAC_IAX_GESTIONES. f_get_listservicios ';
      vfecha         DATE;
   BEGIN
      IF pfecha IS NULL THEN
         vfecha := f_sysdate();
      ELSE
         vfecha := pfecha;
      END IF;

      cur := pac_md_gestiones.f_get_lstservicios(psservic, ptdescri, psconven, vfecha,
                                                 mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstservicios;

   FUNCTION f_ini_servicios(mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      /*************************************************************************
      Inicializa la tabla de servicios en el objeto gestiones
      *************************************************************************/
      vobjectname    VARCHAR2(500) := 'PAC_IAX_GESTIONES.F_Ini_Servicios';
      vparam         VARCHAR2(500) := 'parámetros - NULL';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vgobgestion.servicios := t_iax_sin_tramita_detgestion();
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_ini_servicios;

   FUNCTION f_sel_servicio(
      psconven IN NUMBER,
      pnvalser IN NUMBER,
      pccodmon IN VARCHAR2,
      pctipcal IN NUMBER,
      piprecio OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      /*************************************************************************
         Devuelve el precio unitario de un servicio
         return             : number
      *************************************************************************/
      cur            sys_refcursor;
      vquery         VARCHAR2(100);
      vobjectname    VARCHAR2(500) := 'PAC_IAX_GESTIONES.F_Sel_Servicio';
      vparam         VARCHAR2(500) := 'parámetros - ';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vnerror        NUMBER;
--      vobjservicio   ob_iax_sin_tramita_detgestion;
   BEGIN
      vnerror := pac_md_gestiones.f_get_precio_servicio(psconven, pnvalser, pccodmon,
                                                        pctipcal, piprecio, mensajes);

      IF vnumerr != 0 THEN
         RETURN NULL;
      END IF;

      SELECT 'SELECT REPLACE(''' || piprecio || ''', '','', ''.'') AS piprecio FROM dual'
        INTO vquery
        FROM DUAL;

      cur := pac_md_gestiones.f_opencursor(vquery, mensajes);
      RETURN cur;
   /*
   vgobgestion.servicios.EXTEND;
   vobjservicio := ob_iax_sin_tramita_detgestion();
   vobjservicio.sgestio := psgestio;
   vobjservicio.ndetges := vgobgestion.servicios.LAST;
   vobjservicio.sservic := psservic;
   vobjservicio.tservic := ptservic;
   vobjservicio.nvalser := pnvalser;
   vobjservicio.ncantid := pncantid;
   vobjservicio.cunimed := pcunimed;
   vobjservicio.tunimed := ptunimed;
   vobjservicio.itotal := pitotal;
   vobjservicio.ccodmon := pccodmon;
   vobjservicio.tmoneda := ptmoneda;
   vobjservicio.fcambio := f_sysdate;
   vgobgestion.servicios(vgobgestion.servicios.LAST) := vobjservicio;
   */
   END f_sel_servicio;

   FUNCTION f_desel_servicio(psservic IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      /*************************************************************************
         Elimina el servicio de la coleccion de servicios del objeto gestion
         param in  sservic  : codigo de servicio
         param out mensajes : mesajes de error
         return             : number
      *************************************************************************/
      vobjectname    VARCHAR2(500) := 'PAC_IAX_GESTIONES.F_Desel_Servicio';
      vparam         VARCHAR2(500) := 'parámetros - psservic:' || psservic;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      verror         NUMBER;
   BEGIN
      IF vgobgestion.servicios IS NOT NULL THEN
         IF vgobgestion.servicios.COUNT > 0 THEN
            FOR i IN vgobgestion.servicios.FIRST .. vgobgestion.servicios.LAST LOOP
               IF vgobgestion.servicios.EXISTS(i) THEN
                  IF vgobgestion.servicios(i).sservic = psservic THEN
                     vgobgestion.servicios.DELETE(i);
                     RETURN 0;
                  END IF;
               END IF;
            END LOOP;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam,
                                           vnumerr);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_desel_servicio;

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
      RETURN NUMBER IS
      /*************************************************************************
       Recupera de una variable global de la capa IAX los valores del objeto ob_iax_gestion
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
      vobjectname    VARCHAR2(500) := 'PAC_IAX_GESTION.f_set_obj_gestion';
      vparam         VARCHAR2(500) := 'parámetros - ';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER;
   BEGIN
      psseguro := vgobgestion.sseguro;
      pnsinies := vgobgestion.nsinies;
      pntramit := vgobgestion.ntramit;
      pnlocali := vgobgestion.nlocali;
      pcgarant := vgobgestion.cgarant;
      psgestio := vgobgestion.sgestio;
      pctipreg := vgobgestion.ctipreg;
      pctipges := vgobgestion.ctipges;
      psprofes := vgobgestion.sprofes;
      pctippro := vgobgestion.ctippro;
      pcsubpro := vgobgestion.csubpro;
      pspersed := vgobgestion.spersed;
      psconven := vgobgestion.sconven;
      pccancom := vgobgestion.ccancom;
      pccomdef := vgobgestion.ccomdef;
      ptrefext := vgobgestion.trefext;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam,
                                           vnumerr);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_get_obj_gestion;

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
      RETURN NUMBER IS
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
      vobjectname    VARCHAR2(500) := 'PAC_IAX_GESTION.f_set_obj_gestion';
      vparam         VARCHAR2(500) := 'parámetros - ';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER;
   BEGIN
      vnumerr := pac_md_gestiones.f_set_obj_gestion(psseguro, pnsinies, pntramit, pnlocali,
                                                    pcgarant, psgestio, pctipreg, pctipges,
                                                    psprofes, pctippro, pcsubpro, pspersed,
                                                    psconven, pccancom, pccomdef, ptrefext,
                                                    ptobserv, vgobgestion, mensajes);

      IF vnumerr != 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam,
                                           vnumerr);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_set_obj_gestion;

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
      RETURN NUMBER IS
      /*************************************************************************
         Graba la gestion, el movimiento de alta y su detalle
         param out mensajes : mesajes de error
         return             : number
      *************************************************************************/
      vobjectname    VARCHAR2(500) := 'PAC_IAX_GESTION.f_set_gestion';
      vparam         VARCHAR2(500)
         := 'parámetros - psgestio=' || psgestio || ' pseseguro=' || psseguro || ' pnsinies='
            || pnsinies || ' pntramit=' || pntramit || ' pcgarant=' || pcgarant
            || ' pctipreg=' || pctipreg || ' pctipges=' || pctipges || ' psprofes='
            || psprofes || ' pctippro=' || pctippro || ' pcsubpro=' || pcsubpro
            || ' pspersed=' || pspersed || ' psconven=' || psconven || ' pccancom='
            || pccancom || ' pccomdef=' || pccomdef || ' ptrefext=' || ptrefext
            || ' pcestges=' || pcestges || ' pcsubges=' || pcsubges || 'pnlocali= '
            || pnlocali || ' pfgestio=' || pfgestio || ' pservicios='
            || SUBSTR(pservicios, 1, 200);
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vsgestio       NUMBER;
      vcsubges       NUMBER;
      lv_appendstring VARCHAR2(4000);
      lv_resultstring VARCHAR2(4000);
      lv_count       NUMBER;
      vsservic       NUMBER;
      vncantid       NUMBER;
      vcnocarg       NUMBER;
      vnvalser       NUMBER;
      vitotal        NUMBER;
      vfalta         DATE;
      vresto         VARCHAR2(4000);
      vsi_o_no       NUMBER := 0;
      vobjservicio   ob_iax_sin_tramita_detgestion := ob_iax_sin_tramita_detgestion();
      pp             VARCHAR2(50);
   BEGIN
      IF NVL(pmodo, '*') <> 'MODIFICAR' THEN   -- 25913:ASN:11/02/13
         vpasexec := 1;
         vnumerr := pac_md_gestiones.f_set_gestion(psseguro, pnsinies, pntramit, pcgarant,
                                                   pctipreg, pctipges, psprofes, pctippro,
                                                   pcsubpro, pspersed, psconven, pccancom,
                                                   pccomdef, ptrefext, pnlocali,   -- 27276
                                                   pfgestio,   --26630
                                                   vsgestio, mensajes);

         IF vnumerr != 0 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
            RAISE e_object_error;
         END IF;
      ELSE
         vpasexec := 20;
         vsgestio := psgestio;
         vnumerr := pac_md_gestiones.f_impacto_reserva(vsgestio, pctipges, vsi_o_no, mensajes);

         IF vnumerr <> 0 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
            RAISE e_object_error;
         END IF;

         IF vsi_o_no = 1 THEN   -- llama a f_ajusta_reserva por el total de detgestion antes de modificar
            vpasexec := 21;
            vnumerr := pac_md_gestiones.f_ajusta_reserva(vsgestio, -1, mensajes);

            IF vnumerr <> 0 THEN
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
               RAISE e_object_error;
            END IF;
         END IF;

         vpasexec := 22;
         vnumerr := pac_md_gestiones.f_borra_detalle(vsgestio, mensajes);

         IF vnumerr <> 0 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
            RAISE e_object_error;
         END IF;
      END IF;

      IF pservicios IS NOT NULL THEN
         lv_appendstring := pservicios;

         BEGIN
            LOOP
               EXIT WHEN NVL(INSTR(lv_appendstring, ';'), -99) < 0;
               lv_resultstring := SUBSTR(lv_appendstring, 1,(INSTR(lv_appendstring, ';') - 1));
               lv_count := INSTR(lv_appendstring, ';') + 1;
               lv_appendstring := SUBSTR(lv_appendstring, lv_count, LENGTH(lv_appendstring));
               -- 25913:ASN:11/02/13 ini
               vpasexec := 2;

               SELECT SUBSTR(lv_resultstring, 1, INSTR(lv_resultstring, '#') - 1)
                 INTO vsservic
                 FROM DUAL;

               vpasexec := 3;

               SELECT SUBSTR(lv_resultstring, INSTR(lv_resultstring, '#') + 1)
                 INTO vresto
                 FROM DUAL;

               vpasexec := 4;

               SELECT SUBSTR(vresto, 1, INSTR(vresto, '#') - 1)
                 INTO vncantid
                 FROM DUAL;

               vpasexec := 5;

               SELECT SUBSTR(vresto, INSTR(vresto, '#') + 1)
                 INTO vresto
                 FROM DUAL;

               vpasexec := 6;

               SELECT SUBSTR(vresto, 1, INSTR(vresto, '#') - 1)
                 INTO vcnocarg
                 FROM DUAL;

               vpasexec := 7;

               SELECT SUBSTR(vresto, INSTR(vresto, '#') + 1)
                 INTO vresto
                 FROM DUAL;

               vpasexec := 8;

               SELECT TO_DATE(SUBSTR(vresto, 1, INSTR(vresto, '#') - 1), 'dd/mm/yyyy')
                 INTO vfalta
                 FROM DUAL;

               vpasexec := 9;

               SELECT SUBSTR(vresto, INSTR(vresto, '#') + 1)
                 INTO vresto
                 FROM DUAL;

               vpasexec := 10;

               BEGIN
                  SELECT TO_NUMBER(REPLACE(SUBSTR(vresto, 1, INSTR(vresto, '#') - 1), '.', ','))
                    INTO vnvalser
                    FROM DUAL;
               EXCEPTION
                  WHEN INVALID_NUMBER THEN
                     BEGIN
                        SELECT TO_NUMBER(REPLACE(SUBSTR(vresto, 1, INSTR(vresto, '#') - 1),
                                                 ',', '0'))
                          INTO vnvalser
                          FROM DUAL;
                     EXCEPTION
                        WHEN INVALID_NUMBER THEN
                           SELECT TO_NUMBER(SUBSTR(vresto, 1, INSTR(vresto, '#') - 1))
                             INTO vnvalser
                             FROM DUAL;
                     END;
               END;

               vpasexec := 11;

               BEGIN
                  SELECT TO_NUMBER(REPLACE(SUBSTR(vresto, INSTR(vresto, '#') + 1), '.', ','))
                    INTO vitotal
                    FROM DUAL;
               EXCEPTION
                  WHEN INVALID_NUMBER THEN
                     BEGIN
                        SELECT TO_NUMBER(REPLACE(SUBSTR(vresto, INSTR(vresto, '#') + 1), ',',
                                                 '.'))
                          INTO vitotal
                          FROM DUAL;
                     EXCEPTION
                        WHEN INVALID_NUMBER THEN
                           SELECT TO_NUMBER(SUBSTR(vresto, INSTR(vresto, '#') + 1))
                             INTO vitotal
                             FROM DUAL;
                     END;
               END;

               -- 25913:ASN:11/02/13 fin
               vpasexec := 12;
               vnumerr := f_set_obj_servicio(vsgestio, psconven, vsservic, vncantid, vnvalser,
                                             vitotal, vcnocarg, vfalta, vobjservicio, mensajes);

               IF vnumerr <> 0 THEN
                  pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
                  RAISE e_object_error;
               END IF;

               vpasexec := 13;
               vnumerr := pac_md_gestiones.f_set_detgestion(vsgestio, vobjservicio.sservic,
                                                            vobjservicio.ncantid,
                                                            vobjservicio.cunimed,
                                                            vobjservicio.nvalser,
                                                            vobjservicio.cnocarg,
                                                            vobjservicio.itotal,
                                                            vobjservicio.ccodmon,
                                                            vobjservicio.fcambio,
                                                            vobjservicio.falta, mensajes);

               IF vnumerr <> 0 THEN
                  pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
                  RAISE e_object_error;
               END IF;
            END LOOP;
         END;
      END IF;

      vcsubges := pcsubges;

      IF NVL(pmodo, '*') = 'MODIFICAR' THEN   -- 25913:ASN:11/02/13
         -- 17/04/2013 ini
         IF pcsubges IN(8, 9) THEN   -- Para el estado 'valorado' comprobamos si ha de quedar 'pendiente de valorar'.
            vnumerr := pac_md_gestiones.f_estado_valoracion(vsgestio, vcsubges, mensajes);

            IF vnumerr <> 0 THEN
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
               RAISE e_object_error;
            END IF;
         END IF;

         -- 17/04/2013 fin
         vpasexec := 14;
         vnumerr := pac_md_gestiones.f_set_movgestion(vsgestio, 0,   -- ctipmov = 'modificacion'
                                                      pctipges, ptrefext, pcestges, vcsubges,   -- pcsubges, 17/04/2013
                                                      mensajes);

         IF vsi_o_no = 1 THEN
            vnumerr := pac_md_gestiones.f_ajusta_reserva(vsgestio, 1, mensajes);

            IF vnumerr <> 0 THEN
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
               RAISE e_object_error;
            END IF;
         END IF;
      ELSE
         vpasexec := 15;
         vnumerr := pac_md_gestiones.f_set_movgestion(vsgestio, 1,   -- ctipmov = 'alta'
                                                      pctipges, ptrefext, pcestges, pcsubges,
                                                      mensajes);

         IF vnumerr IN
               (9905253,   -- No se encontro el correo del profesional
                        9904380)   -- Error al enviar correo
                                THEN
            ptlitera := pac_iobj_mensajes.f_get_descmensaje(vnumerr,
                                                            pac_md_common.f_get_cxtidioma());
            vnumerr := 0;
         END IF;
      END IF;

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      ELSE
         COMMIT;
      END IF;

      psgestio_out := vsgestio;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam,
                                           vnumerr);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_set_gestion;

   FUNCTION f_set_movgestion(
      psgestio IN NUMBER,
      pctipmov IN NUMBER,
      pctipges IN NUMBER,
      pcestges IN NUMBER,
      pcsubges IN NUMBER,
      ptcoment IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      /*************************************************************************
         Graba un movimiento de gestion
         param out mensajes : mesajes de error
         return             : number
      *************************************************************************/
      vobjectname    VARCHAR2(500) := 'PAC_IAX_GESTION.f_set_movgestion';
      vparam         VARCHAR2(4500)
         := 'parámetros - psgestio=' || psgestio || ' pctipmov=' || pctipmov || ' pctipges='
            || pctipges || ' ptcoment=' || ptcoment;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_md_gestiones.f_set_movgestion(psgestio, pctipmov, pctipges, ptcoment,
                                                   pcestges, pcsubges, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam,
                                           vnumerr);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_set_movgestion;

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
      RETURN NUMBER IS
      /*************************************************************************
         Copia el servicio seleccionado en la coleccion de servicios del objeto gestion
         param in  sgestio
         param in  sconven  : codigo convenio
         param in  sservic  : codigo de servicio
         param in  ncantid  : cantidad
         param in  cnocarg  : 0 = sin cargo
         param in  falta    : fecha de alta
         param out mensajes : mesajes de error
         return             : number
      *************************************************************************/
      vnvalser       NUMBER;
      vccodmon       VARCHAR2(3);
      vctipcal       NUMBER;
      vitotal        NUMBER;
      vcunimed       NUMBER;
      vtservic       VARCHAR2(100);
      vtmoneda       VARCHAR2(100);
      vtunimed       VARCHAR2(100);
      vobjectname    VARCHAR2(500) := 'PAC_IAX_GESTIONES.F_set_obj_servicio';
      vparam         VARCHAR2(500) := 'parámetros - ';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vnerror        NUMBER;
      viminimo       NUMBER;
      vsservic       NUMBER;
      vncantid       NUMBER;
--
      e_object_error EXCEPTION;
      e_param_error  EXCEPTION;
--
   BEGIN
      vobjservicio := ob_iax_sin_tramita_detgestion();
      vpasexec := 2;
      vnerror := pac_md_gestiones.f_get_servicio(psconven, psservic, pncantid, vtservic,
                                                 vcunimed, vtunimed, vnvalser, vccodmon,
                                                 vtmoneda, viminimo, vctipcal, mensajes);
      vpasexec := 3;

      IF vnumerr != 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      /*
      -- el precio se recibe de la pantalla
      vpasexec := 4;
      vnerror := pac_md_gestiones.f_get_imp_servicio(psconven, vnvalser, vccodmon, vctipcal,
                                                     pncantid, pcnocarg, vitotal, viminimo,
                                                     mensajes);

      IF vnumerr != 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;
      */
      vpasexec := 5;
      vobjservicio := ob_iax_sin_tramita_detgestion();
      vobjservicio.sgestio := psgestio;
      --vobjservicio.ndetges := vgobgestion.servicios.LAST;
      vobjservicio.sservic := psservic;
      vobjservicio.tservic := vtservic;
      vobjservicio.nvalser := pnvalser;
      vobjservicio.ncantid := pncantid;
      vobjservicio.cunimed := vcunimed;
      vobjservicio.tunimed := vtunimed;
      vobjservicio.cnocarg := pcnocarg;
      vobjservicio.itotal := pitotal;
      vobjservicio.ccodmon := vccodmon;
      vobjservicio.tmoneda := vtmoneda;
      vobjservicio.fcambio := f_sysdate;
      vobjservicio.fcambio := pfalta;
      RETURN 0;
   EXCEPTION
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam,
                                           vnumerr);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_set_obj_servicio;

   FUNCTION f_gestion_modificable(
      psgestio IN NUMBER,
      psi_o_no OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
/*************************************************************************
   Decide si una gestion esta en un estado modificable
*************************************************************************/
      vobjectname    VARCHAR2(500) := 'PAC_IAX_GESTIONES.F_gestion_modificable';
      vparam         VARCHAR2(500) := 'parámetros - ';
      vpasexec       NUMBER(2) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_md_gestiones.f_gestion_modificable(psgestio, psi_o_no, mensajes);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam,
                                           vnumerr);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_gestion_modificable;

   FUNCTION f_gestion_permitida(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      pctipges IN NUMBER,
      ptlitera OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
/*************************************************************************
   Decide si una gestion se puede dar de alta
*************************************************************************/
      vobjectname    VARCHAR2(500) := 'PAC_IAX_GESTIONES.F_gestion_permitida';
      vparam         VARCHAR2(500) := 'parámetros - ';
      vpasexec       NUMBER(2) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_md_gestiones.f_gestion_permitida(pnsinies, pntramit, pctipges, ptlitera,
                                                      mensajes);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam,
                                           vnumerr);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_gestion_permitida;

   FUNCTION f_get_servicios(
      psconven IN NUMBER,
      pstarifa IN NUMBER,
      pnlinea IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
        /*************************************************************************
          Devuelve el servicio seleccionado o la lista, si es un servicio empaquetado
      *************************************************************************/
      cur            sys_refcursor;
      vquery         VARCHAR2(100);
      vobjectname    VARCHAR2(500) := 'PAC_IAX_GESTIONES.F_get_servicios';
      vparam         VARCHAR2(500) := 'parámetros - ';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vnerror        NUMBER;
   BEGIN
      cur := pac_md_gestiones.f_get_servicios(psconven, pstarifa, pnlinea, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_servicios;

   --INI bug 26630
   FUNCTION f_get_cfecha(pctipges IN NUMBER, pcfecha OUT NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
/*************************************************************************
   Decide si una gestion se puede dar de alta
*************************************************************************/
      vobjectname    VARCHAR2(500) := 'PAC_IAX_GESTIONES.f_get_cfecha';
      vparam         VARCHAR2(500) := 'parámetros - ';
      vpasexec       NUMBER(2) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_md_gestiones.f_get_cfecha(pctipges, pcfecha, mensajes);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam,
                                           vnumerr);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_get_cfecha;

   FUNCTION f_usuario_permitido(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      psgestio IN NUMBER,
      pctipmov IN NUMBER,
      pcpermit OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
/*************************************************************************
   Decide si una gestion se puede dar de alta
*************************************************************************/
      vobjectname    VARCHAR2(500) := 'PAC_IAX_GESTIONES.f_usuario_permitido';
      vparam         VARCHAR2(500) := 'parámetros - ';
      vpasexec       NUMBER(2) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_md_gestiones.f_usuario_permitido(pnsinies, pntramit, psgestio, pctipmov,
                                                      pcpermit, mensajes);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam,
                                           vnumerr);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_usuario_permitido;

   FUNCTION f_cancela_pantalla(
      psconven IN NUMBER,
      psprofes IN NUMBER,
      pnsinies IN NUMBER,
      pntramit IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
/*************************************************************************
   Si se ha dado de alta algun convio temporal, se eliminan esos datos.
*************************************************************************/
      vobjectname    VARCHAR2(500) := 'PAC_IAX_GESTIONES.f_cancela_pantalla';
      vparam         VARCHAR2(500) := 'parámetros - ';
      vpasexec       NUMBER(2) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_md_gestiones.f_cancela_pantalla(psconven, psprofes, pnsinies, pntramit,
                                                     mensajes);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam,
                                           vnumerr);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_cancela_pantalla;

   FUNCTION f_get_acceso_tramitador(
      pnsinies IN NUMBER,
      pntramit IN NUMBER,
      pcconven OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
/*************************************************************************
   Decide si una gestion se puede dar de alta
*************************************************************************/
      vobjectname    VARCHAR2(500) := 'PAC_IAX_GESTIONES.f_get_acceso_tramitador';
      vparam         VARCHAR2(500) := 'parámetros - ';
      vpasexec       NUMBER(2) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_md_gestiones.f_get_acceso_tramitador(pnsinies, pntramit, pcconven,
                                                          mensajes);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam,
                                           vnumerr);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_get_acceso_tramitador;
/*************************************************************************
   Devuelve si el tramitador tiene acceso a convenios inactivos y temporales (0-No, 1-Si)
*************************************************************************/
--FIN bug 26630
END pac_iax_gestiones;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_GESTIONES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_GESTIONES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_GESTIONES" TO "PROGRAMADORESCSI";
