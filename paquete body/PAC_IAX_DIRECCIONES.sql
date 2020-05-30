--------------------------------------------------------
--  DDL for Package Body PAC_IAX_DIRECCIONES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IAX_DIRECCIONES" AS
   /******************************************************************************
      NOMBRE:       PAC_IAX_DIRECCIONES
      PROPÓSITO:  Funciones para recuperar valores

      REVISIONES:
      Ver        Fecha        Autor   Descripción
     ---------  ----------  ------   ------------------------------------
      1.0        19/03/2012   JMB     1. Creación del package.

   ******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   --JMB 02/2012 Tipos Vias
   /*************************************************************************
      Recupera la lista de tipos de vias
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_tiposvias(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAX_DIRECCIONES.F_Get_Tiposvias';
      vterror        VARCHAR2(200) := 'Error en los tipos de vias';
   BEGIN
      cur := pac_md_direcciones.f_get_tiposvias(mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           vterror, psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_tiposvias;

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
      mensajes OUT t_iax_mensajes)
      RETURN t_iax_dir_fincas IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAX_DIRECCIONES.F_Get_Busquedadirdirecciones';
      vterror        VARCHAR2(200) := 'Error';
      fincas         t_iax_dir_fincas := t_iax_dir_fincas();
   BEGIN
      fincas := pac_md_direcciones.f_get_busquedadirdirecciones(ptbusqueda, pcpostal,
                                                                pctipvia, ptnomvia, pndesde,
                                                                pnhasta, pcdesde, pchasta,
                                                                ptipfinca, pcpais, pcprovin,
                                                                pcmunicipi, pclocalidad,
                                                                paliasfinca, pine, pescalera,
                                                                ppiso, ppuerta, preferencia,
                                                                pidfinca, mensajes);
      pac_iax_direcciones.vfincas := fincas;
      RETURN pac_iax_direcciones.vfincas;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           vterror, psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_busquedadirdirecciones;

   FUNCTION f_get_portales(pidfinca IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN t_iax_dir_portales IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAX_DIRECCIONES.F_Get_Busquedaportales';
      vterror        VARCHAR2(200) := 'Error';
      portales       t_iax_dir_portales := t_iax_dir_portales();
   BEGIN
      IF pidfinca IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF pac_iax_direcciones.vfincas IS NOT NULL
         AND pac_iax_direcciones.vfincas.COUNT > 0 THEN
         FOR i IN pac_iax_direcciones.vfincas.FIRST .. pac_iax_direcciones.vfincas.LAST LOOP
            IF pac_iax_direcciones.vfincas(i).idfinca = pidfinca THEN
               portales := pac_iax_direcciones.vfincas(i).portales;
               EXIT;
            END IF;
         END LOOP;
      END IF;

      IF portales IS NOT NULL
         AND portales.COUNT > 0 THEN
         FOR j IN portales.FIRST .. portales.LAST LOOP
            portales(j).portalesdir := NULL;
         END LOOP;
      END IF;

      RETURN portales;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           vterror, psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_portales;

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
      mensajes OUT t_iax_mensajes)
      RETURN t_iax_dir_domicilios IS
      vtraza         NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_DIRECCIONES.F_Get_Busquedaportales';
      vquery         VARCHAR2(2000);
      terror         VARCHAR2(200) := 'No se puede recuperar la informacion';
      domicilios     t_iax_dir_domicilios := t_iax_dir_domicilios();
      portalesdir    t_iax_dir_portalesdirecciones := t_iax_dir_portalesdirecciones();
   BEGIN
      vtraza := 1;

      IF pidfinca IS NULL
         OR pidportal IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF pac_iax_direcciones.vfincas IS NOT NULL
         AND pac_iax_direcciones.vfincas.COUNT > 0 THEN
         FOR i IN pac_iax_direcciones.vfincas.FIRST .. pac_iax_direcciones.vfincas.LAST LOOP
            IF pac_iax_direcciones.vfincas(i).idfinca = pidfinca THEN
               IF pac_iax_direcciones.vfincas(i).portales IS NOT NULL
                  AND pac_iax_direcciones.vfincas(i).portales.COUNT > 0 THEN
                  FOR j IN
                     pac_iax_direcciones.vfincas(i).portales.FIRST .. pac_iax_direcciones.vfincas
                                                                                            (i).portales.LAST LOOP
                     IF pac_iax_direcciones.vfincas(i).portales(j).idportal = pidportal THEN
                        portalesdir := pac_iax_direcciones.vfincas(i).portales(j).portalesdir;
                        domicilios := portalesdir(1).domicilios;
                        EXIT;
                     END IF;
                  END LOOP;
               END IF;
            END IF;
         END LOOP;
      END IF;

      RETURN domicilios;
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
   END f_get_departamentos;

    /*************************************************************************
     Retorna una finca
     param in pidfinca   : Codi de la finca
     param in mensajes   : Mensajes de error
     return              : Consulta a ejecutar

     Bug 20893/111636 - 05/04/2012 - AMC
   *************************************************************************/
   FUNCTION f_get_finca(pidfinca IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vtraza         NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAX_DIRECCIONES.f_get_finca';
      vquery         VARCHAR2(2000);
      terror         VARCHAR2(200) := 'No se puede recuperar la informacion';
      cur            sys_refcursor;
   BEGIN
      vtraza := 1;

      IF pidfinca IS NULL THEN
         RAISE e_param_error;
      END IF;

      vtraza := 2;
      cur := pac_md_direcciones.f_get_finca(pidfinca, mensajes);
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
      vexiste OUT NUMBER,
      viddomici OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER;
      vparam         VARCHAR2(100)
         := 'pidfinca:' || pidfinca || ' pidportal:' || pidportal || ' piddomici:'
            || piddomici;
      vobject        VARCHAR2(200) := 'PAC_IAX_DIRECCIONES.f_existe_domi';
      vcount         NUMBER;
      terror         VARCHAR2(200) := 'Error no controlado';
      verror         NUMBER := 0;
   BEGIN
      vpasexec := 1;
      vexiste := 0;

      IF pac_iax_direcciones.vfincas IS NOT NULL
         AND pac_iax_direcciones.vfincas.COUNT > 0 THEN
         FOR i IN pac_iax_direcciones.vfincas.FIRST .. pac_iax_direcciones.vfincas.LAST LOOP
            IF pac_iax_direcciones.vfincas(i).idfinca = pidfinca THEN
               FOR c IN
                  pac_iax_direcciones.vfincas(i).portales.FIRST .. pac_iax_direcciones.vfincas
                                                                                            (i).portales.LAST LOOP
                  IF pac_iax_direcciones.vfincas(i).portales(c).idportal = pidportal THEN
                     FOR j IN
                        pac_iax_direcciones.vfincas(i).portales(c).portalesdir.FIRST .. pac_iax_direcciones.vfincas
                                                                                            (i).portales
                                                                                            (c).portalesdir.LAST LOOP
                        IF pac_iax_direcciones.vfincas(i).portales(c).portalesdir(j).idfinca =
                                                                                      pidfinca
                           AND pac_iax_direcciones.vfincas(i).portales(c).portalesdir(j).idportal =
                                                                                      pidportal
                           AND piddomici IS NOT NULL THEN
                           FOR z IN
                              pac_iax_direcciones.vfincas(i).portales(c).portalesdir(j).domicilios.FIRST .. pac_iax_direcciones.vfincas
                                                                                                              (i).portales
                                                                                                              (c).portalesdir
                                                                                                              (j).domicilios.LAST LOOP
                              IF pac_iax_direcciones.vfincas(i).portales(c).portalesdir(j).domicilios
                                                                                            (z).idfinca =
                                                                                      pidfinca
                                 AND pac_iax_direcciones.vfincas(i).portales(c).portalesdir(j).domicilios
                                                                                             (z).idportal =
                                                                                      pidportal
                                 AND pac_iax_direcciones.vfincas(i).portales(c).portalesdir(j).domicilios
                                                                                             (z).iddomici =
                                                                                      piddomici THEN
                                 vexiste := 1;
                                 viddomici := piddomici;
                                 EXIT;
                              END IF;
                           END LOOP;
                        ELSE
                           vexiste := 1;
                        END IF;
                     END LOOP;
                  END IF;
               END LOOP;
            END IF;
         END LOOP;
      END IF;

      IF vexiste = 0 THEN
         verror := pac_md_direcciones.f_existe_domi(pidfinca, pidportal, piddomici, pidgeodir,
                                                    pcescale, pcplanta, pcpuerta, vexiste,
                                                    viddomici, mensajes);

         IF verror <> 0 THEN
            RAISE e_object_error;
         END IF;
      END IF;

      RETURN verror;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN verror;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN verror;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           terror, psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN verror;
   END f_existe_domi;

     /*************************************************************************
     Guarda un domicilio
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
      piddomiciout OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER;
      vparam         VARCHAR2(100)
         := 'pidfinca:' || pidfinca || ' pidportal:' || pidportal || ' pidgeodir:'
            || pidgeodir;
      vobject        VARCHAR2(200) := 'PAC_IAX_DIRECCIONES.f_set_domici';
      vnumerr        NUMBER;
      terror         VARCHAR2(200) := 'Error no controlado';
      vportal        ob_iax_dir_portales;
      vdomici        ob_iax_dir_domicilios;
      vportalesdirecc t_iax_dir_portalesdirecciones;
      vportaldirecc  ob_iax_dir_portalesdirecciones;
   BEGIN
      vpasexec := 1;
      vportal := f_get_portal(pidfinca, pidportal, mensajes);
      vpasexec := 2;

      FOR i IN vportal.portalesdir.FIRST .. vportal.portalesdir.LAST LOOP
         IF vportal.portalesdir(i).idfinca = pidfinca
            AND vportal.portalesdir(i).idportal = pidportal THEN
            vportaldirecc := vportal.portalesdir(i);
            EXIT;
         END IF;
      END LOOP;

      vpasexec := 3;
      vdomici := ob_iax_dir_domicilios();
      vnumerr := pac_md_direcciones.f_set_domici(NULL, vportaldirecc.idfinca,
                                                 vportaldirecc.idportal,
                                                 vportaldirecc.idgeodir, pcescale, pcplanta,
                                                 pcpuerta, pccatast, pnm2cons, pctipdpt,
                                                 ptalias, pcnoaseg, ptnoaseg, vdomici,
                                                 mensajes);
      vpasexec := 4;

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      piddomiciout := vdomici.iddomici;
      vpasexec := 5;

      IF pac_iax_direcciones.vfincas IS NOT NULL
         AND pac_iax_direcciones.vfincas.COUNT > 0 THEN
         FOR i IN pac_iax_direcciones.vfincas.FIRST .. pac_iax_direcciones.vfincas.LAST LOOP
            IF pac_iax_direcciones.vfincas(i).idfinca = pidfinca THEN
               FOR c IN
                  pac_iax_direcciones.vfincas(i).portales.FIRST .. pac_iax_direcciones.vfincas
                                                                                            (i).portales.LAST LOOP
                  IF pac_iax_direcciones.vfincas(i).portales(c).idportal = pidportal THEN
                     vpasexec := 6;

                     FOR j IN
                        pac_iax_direcciones.vfincas(i).portales(c).portalesdir.FIRST .. pac_iax_direcciones.vfincas
                                                                                            (i).portales
                                                                                            (c).portalesdir.LAST LOOP
                        IF pac_iax_direcciones.vfincas(i).portales(c).portalesdir(j).idfinca =
                                                                                      pidfinca
                           AND pac_iax_direcciones.vfincas(i).portales(c).portalesdir(j).idportal =
                                                                                      pidportal THEN
                           IF pac_iax_direcciones.vfincas(i).portales(c).portalesdir(j).domicilios IS NULL THEN
                              pac_iax_direcciones.vfincas(i).portales(c).portalesdir(j).domicilios :=
                                                                        t_iax_dir_domicilios
                                                                                            ();
                           END IF;

                           pac_iax_direcciones.vfincas(i).portales(c).portalesdir(j).domicilios.EXTEND;
                           pac_iax_direcciones.vfincas(i).portales(c).portalesdir(j).domicilios
                              (pac_iax_direcciones.vfincas(i).portales(c).portalesdir(j).domicilios.LAST) :=
                                                                                        vdomici;
                           EXIT;
                        END IF;
                     END LOOP;
                  END IF;
               END LOOP;
            END IF;
         END LOOP;

         vpasexec := 7;
      END IF;

      --   commit;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           terror, psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
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
      pdomici OUT ob_iax_dir_domicilios,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vtraza         NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100) := 'piddomici:' || piddomici;
      vobject        VARCHAR2(200) := 'PAC_IAX_DIRECCIONES.f_get_departamento';
      terror         VARCHAR2(200) := 'No se puede recuperar la informacion';
      vnumerr        NUMBER;
   BEGIN
      vtraza := 1;

      IF piddomici IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_direcciones.f_get_departamento(piddomici, pdomici, mensajes);

      IF vnumerr <> 0 THEN
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
   END f_get_departamento;

    /*************************************************************************
     Devuelve un portal
     param in pidfinca
     param in pidportal
     return  portal

     Bug 20893/111636 - 16/04/2012 - AMC
   *************************************************************************/
   FUNCTION f_get_portal(pidfinca IN NUMBER, pidportal IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN ob_iax_dir_portales IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAX_DIRECCIONES.f_get_portal';
      vterror        VARCHAR2(200) := 'Error';
      portales       t_iax_dir_portales := t_iax_dir_portales();
      portal         ob_iax_dir_portales;
   BEGIN
      IF pidfinca IS NULL
         AND pidportal IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF pac_iax_direcciones.vfincas IS NOT NULL
         AND pac_iax_direcciones.vfincas.COUNT > 0 THEN
         FOR i IN pac_iax_direcciones.vfincas.FIRST .. pac_iax_direcciones.vfincas.LAST LOOP
            IF pac_iax_direcciones.vfincas(i).idfinca = pidfinca THEN
               portales := pac_iax_direcciones.vfincas(i).portales;
               EXIT;
            END IF;
         END LOOP;
      END IF;

      IF portales IS NOT NULL
         AND portales.COUNT > 0 THEN
         FOR j IN portales.FIRST .. portales.LAST LOOP
            IF portales(j).idfinca = pidfinca
               AND portales(j).idportal = pidportal THEN
               portal := portales(j);
               EXIT;
            END IF;
         END LOOP;
      END IF;

      RETURN portal;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           vterror, psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_portal;

    /*************************************************************************
     Guarda en BBDD las fincas
     param in pidfinca
     param in pidportal
     return  0 - OK , 1 - KO

     Bug 20893/111636 - 16/04/2012 - AMC
   *************************************************************************/
   FUNCTION f_set_fincasbd(mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAX_DIRECCIONES.f_set_fincasbd';
      vterror        VARCHAR2(200) := 'Error';
      fincas         t_iax_dir_fincas := t_iax_dir_fincas();
      vnumerr        NUMBER;
   BEGIN
      fincas := pac_iax_direcciones.vfincas;

      IF fincas IS NOT NULL
         AND fincas.COUNT > 0 THEN
         FOR i IN fincas.FIRST .. fincas.LAST LOOP
            vnumerr := pac_md_direcciones.f_set_finca(fincas(i), mensajes);

            IF vnumerr <> 0 THEN
               RAISE e_object_error;
            END IF;
         END LOOP;
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           vterror, psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_set_fincasbd;

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
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vtraza         NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAX_DIRECCIONES.f_get_localidades';
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
      cur := pac_md_direcciones.f_get_localidades(pcprovin, pcpoblac, mensajes);

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
      ptlocali OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER;
      vparam         VARCHAR2(100) := 'pidlocal:' || pidlocal;
      vobject        VARCHAR2(200) := 'PAC_IAX_DIRECCIONES.f_get_localidad';
      vcount         NUMBER;
      terror         VARCHAR2(200) := 'Error no controlado';
      vnumerr        NUMBER;
   BEGIN
      vpasexec := 1;

      IF pidlocal IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_direcciones.f_get_localidad(pidlocal, ptlocali, mensajes);

      IF vnumerr <> 0 THEN
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
      Recupera un portal
      param in pidfinca : identificador de la finca
      param in pidportal : identificador del portal
      param out portal
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_busquedaportal(
      pidfinca IN NUMBER,
      pidportal IN NUMBER,
      pportal OUT ob_iax_dir_portales,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAX_DIRECCIONES.F_Get_Busquedaportal';
      terror         VARCHAR2(200) := 'No se puede recuperar la informacion';
      vnumerr        NUMBER := 0;
      vquery         VARCHAR2(2000);
   BEGIN
      IF pidfinca IS NULL
         OR pidportal IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_direcciones.f_get_busquedaportal(pidfinca, pidportal, pportal,
                                                         mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN 0;
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
   END f_get_busquedaportal;

   /*************************************************************************
       Recupera un portal de memoria
       param in pidfinca : identificador de la finca
       param out mensajes : mensajes de error
       return             : finca
    *************************************************************************/
   FUNCTION f_get_fincamen(pidfinca IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN ob_iax_dir_fincas IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAX_DIRECCIONES.f_get_fincamen';
      vterror        VARCHAR2(200) := 'Error';
      finca          ob_iax_dir_fincas := ob_iax_dir_fincas();
   BEGIN
      IF pidfinca IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF pac_iax_direcciones.vfincas IS NOT NULL
         AND pac_iax_direcciones.vfincas.COUNT > 0 THEN
         FOR i IN pac_iax_direcciones.vfincas.FIRST .. pac_iax_direcciones.vfincas.LAST LOOP
            IF pac_iax_direcciones.vfincas(i).idfinca = pidfinca THEN
               finca := pac_iax_direcciones.vfincas(i);
               EXIT;
            END IF;
         END LOOP;
      END IF;

      RETURN finca;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           vterror, psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_fincamen;

   /*************************************************************************
       Asignamos un nuevo portal a la finca
       param in pidfinca : identificador de la finca
       param out mensajes : mensajes de error
       return             : finca
    *************************************************************************/
   FUNCTION f_set_nuevoportal(
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
      mensajes OUT t_iax_mensajes)
      RETURN t_iax_dir_fincas IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAX_DIRECCIONES.f_set_nuevoportal';
      vterror        VARCHAR2(200) := 'Error';
      portal         ob_iax_dir_portales := ob_iax_dir_portales();
   BEGIN
      IF pidfinca IS NULL THEN
         RAISE e_param_error;
      END IF;

      portal := pac_md_direcciones.f_get_portal(pidfinca, ptbusqueda, pcpostal, pctipvia,
                                                ptnomvia, pndesde, pnhasta, pcdesde, pchasta,
                                                ptipfinca, pcpais, pcprovin, pcmunicipi,
                                                pclocalidad, paliasfinca, pine, pescalera,
                                                ppiso, ppuerta, preferencia, mensajes);

      IF pac_iax_direcciones.vfincas IS NOT NULL
         AND pac_iax_direcciones.vfincas.COUNT > 0 THEN
         FOR i IN pac_iax_direcciones.vfincas.FIRST .. pac_iax_direcciones.vfincas.LAST LOOP
            IF pac_iax_direcciones.vfincas(i).idfinca = pidfinca THEN
               IF pac_iax_direcciones.vfincas(i).portales IS NULL THEN
                  pac_iax_direcciones.vfincas(i).portales := t_iax_dir_portales();
               END IF;

               IF portal.idportal IS NULL THEN
                  portal.idportal := pac_iax_direcciones.vfincas(i).portales.COUNT + 1;
                  portal.portalesdir(1).idportal := portal.idportal;
               END IF;

               pac_iax_direcciones.vfincas(i).portales.EXTEND;
               pac_iax_direcciones.vfincas(i).portales
                                                   (pac_iax_direcciones.vfincas(i).portales.LAST) :=
                                                                                         portal;
               EXIT;
            END IF;
         END LOOP;
      END IF;

      RETURN pac_iax_direcciones.vfincas;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           vterror, psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_set_nuevoportal;

   /*************************************************************************
       Recupera les fincas de memoria
       param out mensajes : mensajes de error
       return             : finca
    *************************************************************************/
   FUNCTION f_get_fincasmen(mensajes OUT t_iax_mensajes)
      RETURN t_iax_dir_fincas IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAX_DIRECCIONES.f_get_fincasmen';
      vterror        VARCHAR2(200) := 'Error';
   BEGIN
      RETURN pac_iax_direcciones.vfincas;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           vterror, psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_fincasmen;
END pac_iax_direcciones;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_DIRECCIONES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_DIRECCIONES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_DIRECCIONES" TO "PROGRAMADORESCSI";
