--------------------------------------------------------
--  DDL for Package Body PAC_MD_DIRECCIONES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MD_DIRECCIONES" AS
   /******************************************************************************
      NOMBRE:       PAC_MD_DIRECCIONES
      PROPÃ“SITO:  Funciones para recuperar valores

      REVISIONES:
      Ver        Fecha        Autor             DescripciÃ³n
      ---------  ----------  ---------------  ------------------------------------
      1.0        19/03/2012   JMB                1. CreaciÃ³n del package.

   ******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   --JMB 02/2012 Tarea Tipos Vias
   /*************************************************************************
       Recupera los tipos de via
       param out mensajes : mensajes de error
       return             : ref cursor
    *************************************************************************/
   FUNCTION f_get_tiposvias(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_DIRECCIONES.F_Get_Tiposvias';
      terror         VARCHAR2(200) := 'Error recuperar los tipos vias';
   BEGIN
      cur :=
         pac_md_listvalores.f_opencursor
                                 ('select ctipvia, ttipovia from tiposvias order by ttipovia',
                                  mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           terror, psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_tiposvias;

   --JMB 03/2012 Buequeda de Direcciones
   /*************************************************************************
       Recupera los datos de direcciones de acuerdo a los parametros
      de busqueda dados
       param out mensajes : mensajes de error
       return             : ref cursor
    *************************************************************************/
   FUNCTION f_get_busquedadirdirecciones(
      ptbusqueda IN NUMBER,
      pcpostal IN VARCHAR2,
      pctipvia IN NUMBER,
      ptnomvia IN VARCHAR2,
      pndesde IN NUMBER,
      pnhasta IN NUMBER,
      pcdesde IN VARCHAR2,
      pchasta IN VARCHAR2,
      ptipfinca IN NUMBER,
      pcpais IN NUMBER,
      pcprovin IN NUMBER,
      pcmunicipi IN NUMBER,
      pclocalidad IN NUMBER,
      paliasfinca IN VARCHAR2,
      pine IN VARCHAR2,
      pescalera IN NUMBER,
      ppiso IN NUMBER,
      ppuerta IN VARCHAR2,
      preferencia IN VARCHAR2,
      pidfinca IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_dir_fincas IS
      cur            sys_refcursor;
      cur2           sys_refcursor;
      cur3           sys_refcursor;
      cur4           sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_DIRECCIONES.F_Get_Busquedadirdirecciones';
      terror         VARCHAR2(200) := 'No se puede recuperar la informacion';
      vnumerr        NUMBER := 0;
      vquerybody     VARCHAR2(2000);
      finca          ob_iax_dir_fincas;
      portal         ob_iax_dir_portales;
      portaldir      ob_iax_dir_portalesdirecciones;
      domicilio      ob_iax_dir_domicilios;
      fincas         t_iax_dir_fincas := t_iax_dir_fincas();
      portaldirec    ob_iax_dir_portalesdirecciones;
      calle          ob_iax_dir_calles;
      geodireccion   ob_iax_dir_geodirecciones;
      vhaydatos      NUMBER := 0;
   --domicilio  ob_iax_dir_domicilios;
   BEGIN
      vquerybody := pac_direcciones.f_get_busquedadirdirecciones(ptbusqueda, pcpostal,
                                                                 pctipvia, ptnomvia, pndesde,
                                                                 pnhasta, pcdesde, pchasta,
                                                                 ptipfinca, pcpais, pcprovin,
                                                                 pcmunicipi, pclocalidad,
                                                                 paliasfinca, pine, pescalera,
                                                                 ppiso, ppuerta, preferencia,
                                                                 pidfinca);
      vpasexec := 2;

      IF vquerybody IS NULL THEN
         RAISE e_object_error;
      END IF;

      cur := pac_md_listvalores.f_opencursor(vquerybody, mensajes);
      vpasexec := 3;
      finca := ob_iax_dir_fincas();

      --domi.calle := ob_iax_dir_calles();
      LOOP
         FETCH cur
          INTO finca.idfinca, finca.ctipviafin, finca.csiglasfin, finca.tcallefin,
               finca.ndesdefin, finca.tdesdefin, finca.cpostalfin, finca.clocalifin,
               finca.tlocalifin, finca.cpoblacfin, finca.tpoblacfin, finca.cprovinfin,
               finca.tprovinfin, finca.cpaisfin, finca.tpaisfin, finca.cfuentefin,
               finca.idlocal, finca.ccatast, finca.ctipfin, finca.nanycon, finca.tfinca,
               finca.cnoaseg, finca.tnoaseg;

         EXIT WHEN cur%NOTFOUND;
         vpasexec := 4;
         vnumerr := f_desvalorfijo(800081, pac_md_common.f_get_cxtidioma(), 1,
                                   finca.tfuentefin);
         vquerybody := pac_direcciones.f_get_busquedaportales(finca.idfinca, NULL);

         IF vquerybody IS NULL THEN
            RAISE e_object_error;
         END IF;

         cur2 := pac_md_listvalores.f_opencursor(vquerybody, mensajes);

         IF finca.portales IS NULL THEN
            finca.portales := t_iax_dir_portales();
         END IF;

         portal := ob_iax_dir_portales();

         IF cur2 IS NOT NULL THEN
            LOOP
               FETCH cur2
                INTO portal.idfinca, portal.idportal, portal.cprincip, portal.cnoaseg,
                     portal.tnoaseg, portal.nanycon, portal.ndepart, portal.nplsota,
                     portal.nplalto, portal.nascens, portal.nescale, portal.nm2vivi,
                     portal.nm2come, portal.nm2gara, portal.nm2jard, portal.nm2cons,
                     portal.nm2suel, portal.csiglaspor, portal.tcallepor, portal.ndesdepor,
                     portal.nhastapor, portal.tdesdepor, portal.thastapor;

               vpasexec := 5;
               EXIT WHEN cur2%NOTFOUND;
               portaldir := ob_iax_dir_portalesdirecciones();

               IF portal.portalesdir IS NULL THEN
                  portal.portalesdir := t_iax_dir_portalesdirecciones();
               END IF;

               FOR cur3 IN (SELECT *
                              FROM dir_portalesdirecciones
                             WHERE idfinca = portal.idfinca
                               AND idportal = portal.idportal) LOOP
                  vpasexec := 6;
                  portaldir.idfinca := cur3.idfinca;
                  portaldir.idportal := cur3.idportal;
                  portaldir.idgeodir := cur3.idgeodir;
                  portaldir.cprincip := cur3.cprincip;
                  domicilio := ob_iax_dir_domicilios();

                  IF portaldir.domicilios IS NULL THEN
                     portaldir.domicilios := t_iax_dir_domicilios();
                  END IF;

                  FOR cur4 IN (SELECT *
                                 FROM dir_domicilios
                                WHERE idfinca = portaldir.idfinca
                                  AND idportal = portaldir.idportal
                                  AND idgeodir = portaldir.idgeodir
                                  AND cplanta IS NOT NULL
                                  AND cpuerta IS NOT NULL) LOOP
                     vpasexec := 7;
                     domicilio.iddomici := cur4.iddomici;
                     domicilio.idfinca := cur4.idfinca;
                     domicilio.idportal := cur4.idportal;
                     domicilio.idgeodir := cur4.idgeodir;
                     domicilio.cescale := cur4.cescale;
                     domicilio.cplanta := cur4.cplanta;
                     domicilio.cpuerta := cur4.cpuerta;
                     domicilio.ccatast := cur4.ccatast;
                     domicilio.nm2cons := cur4.nm2cons;
                     domicilio.ctipdpt := cur4.ctipdpt;
                     domicilio.talias := cur4.talias;
                     domicilio.cnoaseg := cur4.cnoaseg;
                     domicilio.tnoaseg := cur4.tnoaseg;
                     portaldir.domicilios.EXTEND;
                     portaldir.domicilios(portaldir.domicilios.LAST) := domicilio;
                     domicilio := ob_iax_dir_domicilios();
                  END LOOP;

                  portal.portalesdir.EXTEND;
                  portal.portalesdir(portal.portalesdir.LAST) := portaldir;
                  portaldir := ob_iax_dir_portalesdirecciones();
               END LOOP;

               finca.portales.EXTEND;
               finca.portales(finca.portales.LAST) := portal;
               portal := ob_iax_dir_portales();
            END LOOP;
         END IF;

         vhaydatos := 1;
         fincas.EXTEND;
         fincas(fincas.LAST) := finca;
         finca := ob_iax_dir_fincas();
      END LOOP;

      IF vhaydatos = 0
         AND ptbusqueda = 1 THEN
         finca := ob_iax_dir_fincas();

         SELECT seqdir_fincas.NEXTVAL
           INTO finca.idfinca
           FROM DUAL;

         finca.idlocal := pclocalidad;
         finca.ctipfin := ptipfinca;
         finca.cnoaseg := 1;
         finca.cfuentefin := 1;
         vnumerr := f_desvalorfijo(800081, pac_md_common.f_get_cxtidioma(), 1,
                                   finca.tfuentefin);
         finca.cpostalfin := pcpostal;
         finca.ctipviafin := pctipvia;
         finca.tcallefin := ptnomvia;
         finca.ndesdefin := pndesde;
         finca.tdesdefin := pcdesde;
         finca.cpaisfin := pcpais;
         finca.cprovinfin := pcprovin;
         finca.ctipviafin := pctipvia;
         vnumerr := pac_direcciones.f_get_siglas(pctipvia, finca.csiglasfin);
         vnumerr := f_desprovin(pcprovin, finca.tprovinfin, finca.cpaisfin, finca.tpaisfin,
                                pac_md_common.f_get_cxtidioma());
         finca.cpoblacfin := pcmunicipi;
         vnumerr := f_despoblac(pcmunicipi, pcprovin, finca.tpoblacfin);
         finca.clocalifin := pclocalidad;
         vnumerr := pac_direcciones.f_get_localidad(pclocalidad, finca.tlocalifin);
         finca.portales := t_iax_dir_portales();
         finca.portales.EXTEND;
         --finca.portales(finca.poratales.last) := ob_iax_dir_portales();
         portaldirec := ob_iax_dir_portalesdirecciones();
         calle := ob_iax_dir_calles();

         SELECT seqdir_calles.NEXTVAL
           INTO calle.idcalle
           FROM DUAL;

         calle.idlocal := pclocalidad;
         calle.tcalle := ptnomvia;
         calle.ctipvia := pctipvia;
         calle.cvalcal := 0;
         vnumerr := pac_direcciones.f_get_siglas(pctipvia, calle.csiglas);
         geodireccion := ob_iax_dir_geodirecciones();

         SELECT seqdir_geodirecciones.NEXTVAL
           INTO geodireccion.idgeodir
           FROM DUAL;

         geodireccion.idcalle := calle.idcalle;
         geodireccion.ndesde := pndesde;
         geodireccion.nhasta := pnhasta;
         geodireccion.tdesde := pcdesde;
         geodireccion.thasta := pchasta;
         geodireccion.cpostal := pcpostal;
         geodireccion.cvaldir := 0;
         geodireccion.calle := calle;
         portaldirec.geodireccion := ob_iax_dir_geodirecciones();
         portaldirec.geodireccion := geodireccion;
         portaldirec.idgeodir := geodireccion.idgeodir;
         portaldirec.idfinca := finca.idfinca;
         portal := ob_iax_dir_portales();
         portal.portalesdir := t_iax_dir_portalesdirecciones();
         portal.portalesdir.EXTEND;
         portal.idfinca := finca.idfinca;
         portal.idportal := finca.portales.COUNT;

         IF portal.idportal = 1 THEN
            portal.cprincip := 1;
         ELSE
            portal.cprincip := 0;
         END IF;

         portaldirec.idportal := portal.idportal;
         portaldirec.cprincip := portal.cprincip;
         portal.cnoaseg := 0;
         vnumerr := pac_direcciones.f_get_siglas(pctipvia, portal.csiglaspor);
         portal.tcallepor := ptnomvia;
         portal.ndesdepor := pndesde;
         portal.nhastapor := pnhasta;
         portal.tdesdepor := pcdesde;
         portal.thastapor := pchasta;
         domicilio := ob_iax_dir_domicilios();
         vnumerr := f_set_domici(NULL, finca.idfinca, portal.idportal, geodireccion.idgeodir,
                                 pescalera, ppiso, ppuerta, preferencia, NULL, NULL,
                                 paliasfinca, NULL, NULL, domicilio, mensajes);
         portaldirec.domicilios := t_iax_dir_domicilios();
         portaldirec.domicilios.EXTEND;
         portaldirec.domicilios(portaldirec.domicilios.LAST) := domicilio;
         portal.portalesdir(portal.portalesdir.LAST) := portaldirec;
         finca.portales(finca.portales.LAST) := portal;
         fincas.EXTEND;
         fincas(fincas.LAST) := finca;
      END IF;

      IF vhaydatos = 0
         AND ptbusqueda = 2 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9903651);
         RAISE e_object_error;
      END IF;

      RETURN fincas;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           terror, psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_busquedadirdirecciones;

   --JMB 03/2012 Buequeda de Portales
   /*************************************************************************
       Recupera el listado de portales de acuerdo a la direccion
       param out mensajes : mensajes de error
       return             : ref cursor
    *************************************************************************/
   FUNCTION f_get_busquedaportales(pidfinca IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_DIRECCIONES.F_Get_Busquedaportales';
      terror         VARCHAR2(200) := 'No se puede recuperar la informacion';
      vnumerr        NUMBER := 0;
      vquery         VARCHAR2(2000);
   BEGIN
      vquery := pac_direcciones.f_get_busquedaportales(pidfinca, NULL);

      IF vquery IS NULL THEN
         RAISE e_object_error;
      END IF;

      cur := pac_md_listvalores.f_opencursor(vquery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           terror, psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_busquedaportales;

     /*************************************************************************
      Recupera un portal
      param in pidfinca : identificador de la finca
      param in pidportal : identificador del portal
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_busquedaportal(
      pidfinca IN NUMBER,
      pidportal IN NUMBER,
      pportal OUT ob_iax_dir_portales,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_DIRECCIONES.F_Get_Busquedaportal';
      terror         VARCHAR2(200) := 'No se puede recuperar la informacion';
      vnumerr        NUMBER := 0;
      vquery         VARCHAR2(2000);
      portal         ob_iax_dir_portales;
   BEGIN
      IF pidfinca IS NULL
         OR pidportal IS NULL THEN
         RAISE e_param_error;
      END IF;

      vquery := pac_direcciones.f_get_busquedaportales(pidfinca, pidportal);

      IF vquery IS NULL THEN
         RAISE e_object_error;
      END IF;

      cur := pac_md_listvalores.f_opencursor(vquery, mensajes);
      portal := ob_iax_dir_portales();

      LOOP
         FETCH cur
          INTO portal.idfinca, portal.idportal, portal.cprincip, portal.cnoaseg,
               portal.tnoaseg, portal.nanycon, portal.ndepart, portal.nplsota, portal.nplalto,
               portal.nascens, portal.nescale, portal.nm2vivi, portal.nm2come, portal.nm2gara,
               portal.nm2jard, portal.nm2cons, portal.nm2suel, portal.csiglaspor,
               portal.tcallepor, portal.ndesdepor, portal.nhastapor, portal.tdesdepor,
               portal.thastapor;

         EXIT WHEN cur%NOTFOUND;
      END LOOP;

      pportal := portal;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           terror, psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_get_busquedaportal;

    /*************************************************************************
     Retorna los domicilios de un portal
     param in pidfinca   : Codi de la finca
     param in pidportal  : Codi del portal
     param in mensajes   : Mensajes de error
     return              : Consulta a ejecutar

     Bug 20893/111636 - 05/04/2012 - AMC
   *************************************************************************/
   FUNCTION f_get_departamentos(
      pidfinca IN NUMBER,
      pidportal IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vtraza         NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_DIRECCIONES.f_get_departamentos';
      vquery         VARCHAR2(2000);
      terror         VARCHAR2(200) := 'No se puede recuperar la informacion';
      cur            sys_refcursor;
   BEGIN
      vtraza := 1;

      IF pidfinca IS NULL
         OR pidportal IS NULL THEN
         RAISE e_param_error;
      END IF;

      vtraza := 2;
      vquery := pac_direcciones.f_get_departamentos(pidfinca, pidportal, NULL);

      IF vquery IS NULL THEN
         RAISE e_object_error;
      END IF;

      vtraza := 3;
      cur := pac_md_listvalores.f_opencursor(vquery, mensajes);

      IF mensajes IS NOT NULL THEN
         IF mensajes.COUNT > 0 THEN
            RAISE e_object_error;
         END IF;
      END IF;

      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           terror, psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;
   END f_get_departamentos;

   /*************************************************************************
     Retorna una finca
     param in pidfinca   : Codi de la finca
     param in mensajes   : Mensajes de error
     return              : Consulta a ejecutar

     Bug 20893/111636 - 05/04/2012 - AMC
   *************************************************************************/
   FUNCTION f_get_finca(pidfinca IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vtraza         NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_DIRECCIONES.f_get_finca';
      vquery         VARCHAR2(2000);
      terror         VARCHAR2(200) := 'No se puede recuperar la informacion';
      cur            sys_refcursor;
   BEGIN
      vtraza := 1;

      IF pidfinca IS NULL THEN
         RAISE e_param_error;
      END IF;

      vtraza := 2;
      vquery := pac_direcciones.f_get_finca(pidfinca);

      IF vquery IS NULL THEN
         RAISE e_object_error;
      END IF;

      vtraza := 3;
      cur := pac_md_listvalores.f_opencursor(vquery, mensajes);

      IF mensajes IS NOT NULL THEN
         IF mensajes.COUNT > 0 THEN
            RAISE e_object_error;
         END IF;
      END IF;

      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           terror, psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_finca;

   /*************************************************************************
    Retorna si existe un domicilio
    param in pidfinca   : Codi de finca
    param in pidportal  : Codi del portal
    param in piddomici  : Codi del domicilio
    param in pidgeodir  : Codi geodireccion
    param in pcescale   : Codi escalera
    param in pcplanta   : Codi de planta
    param in pcpuerta   : Codi puerta
    param in mensajes   : Mensajes de error
    return              :  0 - No existe , 1 - Existe

    Bug 20893/111636 - 16/04/2012 - AMC
   *************************************************************************/
   FUNCTION f_existe_domi(
      pidfinca IN NUMBER,
      pidportal IN NUMBER,
      piddomici IN NUMBER,
      pidgeodir IN NUMBER,
      pcescale IN VARCHAR2,
      pcplanta IN VARCHAR2,
      pcpuerta IN VARCHAR2,
      vexiste IN OUT NUMBER,
      viddomici IN OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER;
      vparam         VARCHAR2(100)
         := 'pidfinca:' || pidfinca || ' pidportal:' || pidportal || ' piddomici:'
            || piddomici;
      vobject        VARCHAR2(200) := 'PAC_MD_DIRECCIONES.f_existe_domi';
      vcount         NUMBER;
      terror         VARCHAR2(200) := 'Error no controlado';
      vnumerr        NUMBER;
   BEGIN
      vpasexec := 1;
      vexiste := 0;

      IF pidfinca IS NULL
         AND piddomici IS NULL
         AND pidportal IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_direcciones.f_existe_domi(pidfinca, pidportal, piddomici, pidgeodir,
                                               pcescale, pcplanta, pcpuerta, vexiste,
                                               viddomici);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           terror, psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_existe_domi;

    /*************************************************************************
     Guarda una finca
     param in finca
     return  0 - Ok,1 - KO

     Bug 20893/111636 - 16/04/2012 - AMC
   *************************************************************************/
   FUNCTION f_set_finca(pfinca IN ob_iax_dir_fincas, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER;
      vparam         VARCHAR2(100);
      vobject        VARCHAR2(200) := 'PAC_MD_DIRECCIONES.f_set_finca';
      vnumerr        NUMBER;
      terror         VARCHAR2(200) := 'Error no controlado';
      vportal        ob_iax_dir_portales;
      vportaldir     ob_iax_dir_portalesdirecciones;
      vdomici        ob_iax_dir_domicilios;
      vcalle         ob_iax_dir_calles;
   BEGIN
      vnumerr := pac_direcciones.f_set_finca(pfinca.idfinca, pfinca.idlocal, pfinca.ccatast,
                                             pfinca.ctipfin, pfinca.nanycon, pfinca.tfinca,
                                             pfinca.cnoaseg, pfinca.tnoaseg);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      IF pfinca.portales IS NOT NULL
         AND pfinca.portales.COUNT > 0 THEN
         FOR i IN pfinca.portales.FIRST .. pfinca.portales.LAST LOOP
            vportal := pfinca.portales(i);
            vnumerr := pac_direcciones.f_set_portal(vportal.idfinca, vportal.idportal,
                                                    vportal.cprincip, vportal.cnoaseg,
                                                    vportal.tnoaseg, vportal.nanycon,
                                                    vportal.ndepart, vportal.nplsota,
                                                    vportal.nplalto, vportal.nascens,
                                                    vportal.nescale, vportal.nm2vivi,
                                                    vportal.nm2come, vportal.nm2gara,
                                                    vportal.nm2jard, vportal.nm2cons,
                                                    vportal.nm2suel);

            IF vnumerr <> 0 THEN
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
               RAISE e_object_error;
            END IF;

            IF vportal.portalesdir IS NOT NULL
               AND vportal.portalesdir.COUNT > 0 THEN
               FOR j IN vportal.portalesdir.FIRST .. vportal.portalesdir.LAST LOOP
                  vportaldir := vportal.portalesdir(j);

                  IF vportaldir.geodireccion IS NOT NULL THEN
                     IF vportaldir.geodireccion.calle IS NOT NULL THEN
                        vcalle := vportaldir.geodireccion.calle;
                        vnumerr := pac_direcciones.f_set_dircalles(vcalle.idcalle,
                                                                   vcalle.idlocal,
                                                                   vcalle.tcalle,
                                                                   vcalle.ctipvia,
                                                                   vcalle.cfuente,
                                                                   vcalle.tcalbus,
                                                                   vcalle.cvalcal);

                        IF vnumerr <> 0 THEN
                           pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
                           RAISE e_object_error;
                        END IF;
                     END IF;

                     vnumerr :=
                        pac_direcciones.f_set_dirgeodirecciones
                                                             (vportaldir.geodireccion.idgeodir,
                                                              vportaldir.geodireccion.idcalle,
                                                              vportaldir.geodireccion.ctipnum,
                                                              vportaldir.geodireccion.ndesde,
                                                              vportaldir.geodireccion.tdesde,
                                                              vportaldir.geodireccion.nhasta,
                                                              vportaldir.geodireccion.thasta,
                                                              vportaldir.geodireccion.cpostal,
                                                              vportaldir.geodireccion.cgeox,
                                                              vportaldir.geodireccion.cgeoy,
                                                              vportaldir.geodireccion.cgeonum,
                                                              vportaldir.geodireccion.cgeoid,
                                                              vportaldir.geodireccion.cvaldir);

                     IF vnumerr <> 0 THEN
                        pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
                        RAISE e_object_error;
                     END IF;
                  END IF;

                  vnumerr := pac_direcciones.f_set_portalesdirecciones(vportaldir.idfinca,
                                                                       vportaldir.idportal,
                                                                       vportaldir.idgeodir,
                                                                       vportaldir.cprincip);

                  IF vnumerr <> 0 THEN
                     pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
                     RAISE e_object_error;
                  END IF;

                  IF vportaldir.domicilios IS NOT NULL
                     AND vportaldir.domicilios.COUNT > 0 THEN
                     FOR c IN vportaldir.domicilios.FIRST .. vportaldir.domicilios.LAST LOOP
                        vdomici := vportaldir.domicilios(c);
                        vnumerr := pac_direcciones.f_set_domici(vdomici.iddomici,
                                                                vdomici.idfinca,
                                                                vdomici.idportal,
                                                                vdomici.idgeodir,
                                                                vdomici.cescale,
                                                                vdomici.cplanta,
                                                                vdomici.cpuerta,
                                                                vdomici.ccatast,
                                                                vdomici.nm2cons,
                                                                vdomici.ctipdpt,
                                                                vdomici.talias,
                                                                vdomici.cnoaseg,
                                                                vdomici.tnoaseg);

                        IF vnumerr <> 0 THEN
                           pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
                           RAISE e_object_error;
                        END IF;
                     END LOOP;
                  END IF;
               END LOOP;
            END IF;
         END LOOP;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           terror, psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_set_finca;

      /*************************************************************************
     Guarda un domicilio
     param in piddomici
     param in pidfinca
     param in pidportal
     param in pidgeodir
     param in pcescale
     param in pcplanta
     param in pcpuerta
     param in pccatast
     param in pnm2cons
     param in pctipdpt
     param in ptalias
     param in pcnoaseg
     param in ptnoaseg
     return  0 - Ok,1 - KO

     Bug 20893/111636 - 16/04/2012 - AMC
   *************************************************************************/
   FUNCTION f_set_domici(
      piddomici IN NUMBER,
      pidfinca IN NUMBER,
      pidportal IN NUMBER,
      pidgeodir IN NUMBER,
      pcescale IN VARCHAR2,
      pcplanta IN VARCHAR2,
      pcpuerta IN VARCHAR2,
      pccatast IN VARCHAR2,
      pnm2cons IN NUMBER,
      pctipdpt IN NUMBER,
      ptalias IN VARCHAR2,
      pcnoaseg IN NUMBER,
      ptnoaseg IN NUMBER,
      pvdomici IN OUT ob_iax_dir_domicilios,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER;
      vparam         VARCHAR2(100)
         := 'pidfinca:' || pidfinca || ' pidportal:' || pidportal || ' pidgeodir:'
            || pidgeodir;
      vobject        VARCHAR2(200) := 'PAC_MD_DIRECCIONES.f_set_domici';
      vnumerr        NUMBER;
      terror         VARCHAR2(200) := 'Error no controlado';
   BEGIN
      IF piddomici IS NOT NULL THEN
         pvdomici.iddomici := piddomici;
      ELSE
         SELECT seqdir_domicilios.NEXTVAL
           INTO pvdomici.iddomici
           FROM DUAL;
      END IF;

      pvdomici.idfinca := pidfinca;
      pvdomici.idportal := pidportal;
      pvdomici.idgeodir := pidgeodir;
      pvdomici.cescale := pcescale;
      pvdomici.cplanta := pcplanta;
      pvdomici.cpuerta := pcpuerta;
      pvdomici.ccatast := pccatast;
      pvdomici.nm2cons := pnm2cons;
      pvdomici.ctipdpt := pctipdpt;
      pvdomici.talias := ptalias;
      pvdomici.cnoaseg := NVL(pcnoaseg, 0);
      pvdomici.tnoaseg := ptnoaseg;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           terror, psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_set_domici;

    /*************************************************************************
     Retorna el domicilio solicitado
     param in piddomici: Codi del domicilio
     param in mensajes   : Mensajes de error
     return              : Domicilio

     Bug 20893/111636 - 18/04/2012 - AMC
   *************************************************************************/
   FUNCTION f_get_departamento(
      piddomici IN NUMBER,
      pdomici IN OUT ob_iax_dir_domicilios,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vtraza         NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_DIRECCIONES.f_get_departamento';
      vquery         VARCHAR2(2000);
      terror         VARCHAR2(200) := 'No se puede recuperar la informacion';
      cur            sys_refcursor;
      vdomici        ob_iax_dir_domicilios := ob_iax_dir_domicilios();
      vcsiglas       NUMBER;
      vtnomvia       VARCHAR2(100);
      vnumvia        NUMBER;
   BEGIN
      vtraza := 1;

      IF piddomici IS NULL THEN
         RAISE e_param_error;
      END IF;

      vtraza := 2;
      vquery := pac_direcciones.f_get_departamentos(NULL, NULL, piddomici);

      IF vquery IS NULL THEN
         RAISE e_object_error;
      END IF;

      vtraza := 3;
      cur := pac_md_listvalores.f_opencursor(vquery, mensajes);

      IF mensajes IS NOT NULL THEN
         IF mensajes.COUNT > 0 THEN
            RAISE e_object_error;
         END IF;
      END IF;

      LOOP
         FETCH cur
          INTO vdomici.iddomici, vdomici.idfinca, vdomici.idportal, vdomici.idgeodir,
               vdomici.cescale, vdomici.cplanta, vdomici.cpuerta, vdomici.ctipdpt,
               vdomici.talias, vdomici.cnoaseg, vdomici.tnoaseg, vnumvia, vtnomvia, vcsiglas;

         vdomici.tdomici := pac_persona.f_tdomici(vcsiglas, vtnomvia, vnumvia, vdomici.talias,
                                                  NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                                                  NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                                                  NULL);
         EXIT WHEN cur%NOTFOUND;
      END LOOP;

      pdomici := vdomici;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           terror, psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_get_departamento;

    /*************************************************************************
     Retorna las localidades
     param in pcprovin   : Codi de la provincia
     param in pcpoblac  : Codi de la poblaci�n
     return              : Listado de localidades

     Bug 20893/111636 - 26/04/2012 - AMC
   *************************************************************************/
   FUNCTION f_get_localidades(
      pcprovin IN NUMBER,
      pcpoblac IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vtraza         NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_DIRECCIONES.f_get_localidades';
      vquery         VARCHAR2(2000);
      terror         VARCHAR2(200) := 'No se puede recuperar la informacion';
      cur            sys_refcursor;
   BEGIN
      vtraza := 1;

      IF pcprovin IS NULL
         AND pcpoblac IS NULL THEN
         RAISE e_param_error;
      END IF;

      vtraza := 2;
      vquery := pac_direcciones.f_get_localidades(pcprovin, pcpoblac);

      IF vquery IS NULL THEN
         RAISE e_object_error;
      END IF;

      vtraza := 3;
      cur := pac_md_listvalores.f_opencursor(vquery, mensajes);

      IF mensajes IS NOT NULL THEN
         IF mensajes.COUNT > 0 THEN
            RAISE e_object_error;
         END IF;
      END IF;

      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           terror, psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_localidades;

    /*************************************************************************
    Retorna si existe un domicilio
    param in pidlocal  : Codi de localidad
    param out ptlocali  : Descripcion de la localidad
    return              :  0 - OK,  Codi error - KO

    Bug 20893/111636 - 26/04/2012 - AMC
   *************************************************************************/
   FUNCTION f_get_localidad(
      pidlocal IN NUMBER,
      ptlocali IN OUT VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER;
      vparam         VARCHAR2(100) := 'pidlocal:' || pidlocal;
      vobject        VARCHAR2(200) := 'PAC_DIRECCIONES.f_get_localidad';
      vcount         NUMBER;
      terror         VARCHAR2(200) := 'Error no controlado';
      vnumerr        NUMBER;
   BEGIN
      vpasexec := 1;

      IF pidlocal IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_direcciones.f_get_localidad(pidlocal, ptlocali);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           terror, psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_get_localidad;

    /*************************************************************************
     Retorna un portal
     return              : Consulta a ejecutar

     Bug 20893/111636 - 17/05/2012 - AMC
   *************************************************************************/
   FUNCTION f_get_portal(
      pidfinca IN NUMBER,
      ptbusqueda IN NUMBER,
      pcpostal IN VARCHAR2,
      pctipvia IN NUMBER,
      ptnomvia IN VARCHAR2,
      pndesde IN NUMBER,
      pnhasta IN NUMBER,
      pcdesde IN VARCHAR2,
      pchasta IN VARCHAR2,
      ptipfinca IN NUMBER,
      pcpais IN NUMBER,
      pcprovin IN NUMBER,
      pcmunicipi IN NUMBER,
      pclocalidad IN NUMBER,
      paliasfinca IN VARCHAR2,
      pine IN VARCHAR2,
      pescalera IN NUMBER,
      ppiso IN NUMBER,
      ppuerta IN VARCHAR2,
      preferencia IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_dir_portales IS
      --  cur            sys_refcursor;
      cur2           sys_refcursor;
      cur3           sys_refcursor;
      --   cur4           sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_DIRECCIONES.f_get_portal';
      terror         VARCHAR2(200) := 'No se puede recuperar la informacion';
      vnumerr        NUMBER := 0;
      vquerybody     VARCHAR2(2000);
      --   finca     ob_iax_dir_fincas;
      portal         ob_iax_dir_portales;
      portaldir      ob_iax_dir_portalesdirecciones;
      domicilio      ob_iax_dir_domicilios;
      -- fincas    t_iax_dir_fincas := t_iax_dir_fincas();
      portaldirec    ob_iax_dir_portalesdirecciones;
      calle          ob_iax_dir_calles;
      geodireccion   ob_iax_dir_geodirecciones;
      vhaydatos      NUMBER := 0;
      vidgeodir      NUMBER;
   --domicilio  ob_iax_dir_domicilios;
   BEGIN
      vquerybody := pac_direcciones.f_get_busquedaportal(ptbusqueda, pcpostal, pctipvia,
                                                         ptnomvia, pndesde, pnhasta, pcdesde,
                                                         pchasta, ptipfinca, pcpais, pcprovin,
                                                         pcmunicipi, pclocalidad, paliasfinca,
                                                         pine, pescalera, ppiso, ppuerta,
                                                         preferencia);

      IF vquerybody IS NULL THEN
         RAISE e_object_error;
      END IF;

      vpasexec := 2;
      cur2 := pac_md_listvalores.f_opencursor(vquerybody, mensajes);
      portal := ob_iax_dir_portales();
      vpasexec := 3;

      LOOP
         FETCH cur2
          INTO vidgeodir, portal.idfinca, portal.idportal, portal.cprincip, portal.cnoaseg,
               portal.tnoaseg, portal.nanycon, portal.ndepart, portal.nplsota, portal.nplalto,
               portal.nascens, portal.nescale, portal.nm2vivi, portal.nm2come, portal.nm2gara,
               portal.nm2jard, portal.nm2cons, portal.nm2suel, portal.csiglaspor,
               portal.tcallepor, portal.ndesdepor, portal.nhastapor, portal.tdesdepor,
               portal.thastapor;

         vpasexec := 5;
         EXIT WHEN cur2%NOTFOUND;
         portal.idfinca := pidfinca;
         portaldir := ob_iax_dir_portalesdirecciones();

         IF portal.portalesdir IS NULL THEN
            portal.portalesdir := t_iax_dir_portalesdirecciones();
         END IF;

         FOR cur3 IN (SELECT *
                        FROM dir_portalesdirecciones
                       WHERE idfinca = pidfinca
                         AND idportal = portal.idportal) LOOP
            vpasexec := 6;
            portaldir.idfinca := cur3.idfinca;
            portaldir.idportal := cur3.idportal;
            portaldir.idgeodir := cur3.idgeodir;
            portaldir.cprincip := cur3.cprincip;
            domicilio := ob_iax_dir_domicilios();

            IF portaldir.domicilios IS NULL THEN
               portaldir.domicilios := t_iax_dir_domicilios();
            END IF;

            portal.portalesdir.EXTEND;
            portal.portalesdir(portal.portalesdir.LAST) := portaldir;
            portaldir := ob_iax_dir_portalesdirecciones();
         END LOOP;

         vhaydatos := 1;
      END LOOP;

      IF vhaydatos = 0
         AND ptbusqueda = 1 THEN
         portaldirec := ob_iax_dir_portalesdirecciones();
         calle := ob_iax_dir_calles();

         SELECT seqdir_calles.NEXTVAL
           INTO calle.idcalle
           FROM DUAL;

         calle.idlocal := pclocalidad;
         calle.tcalle := ptnomvia;
         calle.ctipvia := pctipvia;
         calle.cvalcal := 0;
         vnumerr := pac_direcciones.f_get_siglas(pctipvia, calle.csiglas);
         geodireccion := ob_iax_dir_geodirecciones();

         SELECT seqdir_geodirecciones.NEXTVAL
           INTO geodireccion.idgeodir
           FROM DUAL;

         geodireccion.idcalle := calle.idcalle;
         geodireccion.ndesde := pndesde;
         geodireccion.nhasta := pnhasta;
         geodireccion.tdesde := pcdesde;
         geodireccion.thasta := pchasta;
         geodireccion.cpostal := pcpostal;
         geodireccion.cvaldir := 0;
         geodireccion.calle := calle;
         portaldirec.geodireccion := ob_iax_dir_geodirecciones();
         portaldirec.geodireccion := geodireccion;
         portaldirec.idgeodir := geodireccion.idgeodir;
         portaldirec.idfinca := pidfinca;
         portal := ob_iax_dir_portales();
         portal.portalesdir := t_iax_dir_portalesdirecciones();
         portal.portalesdir.EXTEND;
         portal.idfinca := pidfinca;

         IF portal.idportal = 1 THEN
            portal.cprincip := 1;
         ELSE
            portal.cprincip := 0;
         END IF;

         portaldirec.idportal := portal.idportal;
         portaldirec.cprincip := portal.cprincip;
         portal.cnoaseg := 0;
         vnumerr := pac_direcciones.f_get_siglas(pctipvia, portal.csiglaspor);
         portal.tcallepor := ptnomvia;
         portal.ndesdepor := pndesde;
         portal.nhastapor := pnhasta;
         portal.tdesdepor := pcdesde;
         portal.thastapor := pchasta;
         portal.portalesdir(portal.portalesdir.LAST) := portaldirec;
      END IF;

      IF vhaydatos = 0
         AND ptbusqueda = 2 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9903651);
         RAISE e_object_error;
      END IF;

      RETURN portal;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           terror, psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_portal;
END pac_md_direcciones;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_DIRECCIONES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_DIRECCIONES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_DIRECCIONES" TO "PROGRAMADORESCSI";
