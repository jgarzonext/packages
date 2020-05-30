--------------------------------------------------------
--  DDL for Package Body PAC_MD_MNTDTOSESPECIALES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MD_MNTDTOSESPECIALES" AS
/******************************************************************************
    NOMBRE:      PAC_MD_MNTDTOSESPECIALES
    PROPÓSITO:   Funciones para la gestión de descuentos especiales

    REVISIONES:
    Ver        Fecha        Autor             Descripción
    ---------  ----------  ---------  ------------------------------------
    1.0        15/05/2013   AMC       1. Creación del package. Bug 26615/143210
******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   /**********************************************************************************************
      Función para recuperar campañas
      param out mensajes:        mensajes informativos

      Bug 26615/143210 - 16/05/2013 - AMC
   ************************************************************************************************/
   FUNCTION f_get_campanyas(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1000);
      vobject        VARCHAR2(200) := 'pac_md_mntdtosespeciales.f_get_campanyas';
      vnumerr        NUMBER;
      vselect        VARCHAR2(1000);
      cur            sys_refcursor;
   BEGIN
      vselect := pac_mntdtosespeciales.f_get_campanyas(pac_md_common.f_get_cxtidioma);

      IF vselect IS NULL THEN
         RAISE e_object_error;
      END IF;

      vpasexec := 2;
      cur := pac_md_listvalores.f_opencursor(vselect, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN NULL;
   END f_get_campanyas;

   /**********************************************************************************************
      Función para recuperar campañas
       param in pccampanya:   campaña
       param in pfecini:   fecha inicio campaña
       param in pcfecfin:  fecha fin campaña
       param out dtosespe: t_iax_dtosespeciales
       param out mensajes: mensajes informativos


      Bug 26615/143210 - 16/05/2013 - AMC
   ************************************************************************************************/
   FUNCTION f_get_dtosespeciales(
      pccampanya IN NUMBER,
      pfecini IN DATE,
      pfecfin IN DATE,
      pdtosespe IN OUT t_iax_dtosespeciales,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1000)
            := 'pccampanya:' || pccampanya || ' pfecini:' || pfecini || ' pfecfin:' || pfecfin;
      vobject        VARCHAR2(200) := 'pac_md_mntdtosespeciales.f_get_dtosespeciales';
      vnumerr        NUMBER;
      descuento      ob_iax_dtosespeciales;
      desc_det       ob_iax_dtosespeciales_det;
      pdtosespedet   t_iax_dtosespeciales_det;
      vselect        VARCHAR2(500);
      reg            sys_refcursor;
   BEGIN
      pdtosespe := t_iax_dtosespeciales();
      vselect := 'select c.ccampanya,c.finicio,c.ffin, d.tcampanya'
                 || ' from coddtosespeciales c, descampanyas d'
                 || ' where c.ccampanya = d.ccampanya' || ' and c.cempres ='
                 || pac_md_common.f_get_cxtempresa || ' and d.cidioma ='
                 || pac_md_common.f_get_cxtidioma;

      IF pccampanya IS NOT NULL THEN
         vselect := vselect || ' and c.ccampanya = ' || pccampanya;
      END IF;

      IF pfecini IS NOT NULL THEN
         vselect := vselect || ' and c.finicio >= ' || CHR(39) || pfecini || CHR(39);
      END IF;

      IF pfecfin IS NOT NULL THEN
         vselect := vselect || ' and c.ffin <= ' || CHR(39) || pfecfin || CHR(39);
      END IF;

      vselect := vselect || ' order by c.ccampanya';
      descuento := ob_iax_dtosespeciales();
      -- p_control_error('AMC','f_get_dtosespeciales',vselect);
      reg := pac_md_listvalores.f_opencursor(vselect, mensajes);
      vpasexec := 2;

      LOOP
         FETCH reg
          INTO descuento.ccampanya, descuento.finicio, descuento.ffin, descuento.tcampanya;

         EXIT WHEN reg%NOTFOUND;
         pdtosespedet := t_iax_dtosespeciales_det();
         vpasexec := 3;

         FOR cur IN (SELECT *
                       FROM detdtosespeciales
                      WHERE ccampanya = descuento.ccampanya) LOOP
            desc_det := ob_iax_dtosespeciales_det();
            desc_det.sproduc := cur.sproduc;
            vpasexec := 4;
            vnumerr := f_dessproduc(cur.sproduc, 2, pac_md_common.f_get_cxtidioma,
                                    desc_det.tproduc);
            vpasexec := 5;
            desc_det.cpais := cur.cpais;
            desc_det.tpais := ff_despais(cur.cpais);
            desc_det.cdpto := cur.cdpto;
            desc_det.tdpto := f_desprovin2(cur.cdpto, NULL);
            vpasexec := 6;
            desc_det.cciudad := cur.cciudad;
            desc_det.tciudad := f_despoblac2(cur.cciudad, cur.cdpto);
            vpasexec := 7;
            desc_det.cagrupacion := cur.cagrupacion;
            desc_det.csucursal := cur.csucursal;
            vnumerr := f_desagente(cur.csucursal, desc_det.tsucursal);
            vpasexec := 8;
            desc_det.cintermediario := cur.cintermediario;
            vnumerr := f_desagente(cur.cintermediario, desc_det.tintermediario);
            vpasexec := 9;
            desc_det.pdto := cur.pdto;
            pdtosespedet.EXTEND;
            pdtosespedet(pdtosespedet.LAST) := desc_det;
         END LOOP;

         vpasexec := 10;
         descuento.detdtos := pdtosespedet;
         pdtosespe.EXTEND;
         pdtosespe(pdtosespe.LAST) := descuento;
         descuento := ob_iax_dtosespeciales();
      END LOOP;

      vpasexec := 11;
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
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_get_dtosespeciales;

    /**********************************************************************************************
      Función para insertar un descuento
      param in pccampanya:

      Bug 26615/143210 - 22/05/2013 - AMC
   ************************************************************************************************/
   FUNCTION f_set_dtosespeciales(
      pccampanya IN NUMBER,
      pfecini IN DATE,
      pfecfin IN DATE,
      pmodo IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(500) := 'pac_md_mntdtosespeciales.f_set_dtosespeciales';
      vparam         VARCHAR2(550)
         := 'parámetros - pccampanya:' || pccampanya || ' pfecini:' || pfecini || ' pfecfin:'
            || pfecfin;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER;
   BEGIN
      IF pccampanya IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_mntdtosespeciales.f_set_dtosespeciales(pac_md_common.f_get_cxtempresa,
                                                            pccampanya, pfecini, pfecfin,
                                                            pmodo);

      IF vnumerr = 1 THEN
         RAISE e_object_error;
      END IF;

      IF vnumerr > 1 THEN
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
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_set_dtosespeciales;

   /**********************************************************************************************
      Función para insertar el detalle de un descuento
      param in pccampanya:

      Bug 26615/143210 - 22/05/2013 - AMC
   ************************************************************************************************/
   FUNCTION f_set_dtosespeciales_lin(
      pccampanya IN NUMBER,
      psproduc IN NUMBER,
      pcpais IN NUMBER,
      pcdpto IN NUMBER,
      pcciudad IN NUMBER,
      pcagrupa IN VARCHAR2,
      pcsucursal IN NUMBER,
      pcintermed IN NUMBER,
      ppdto IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(500) := 'pac_md_mntdtosespeciales.f_set_dtosespeciales';
      vparam         VARCHAR2(550)
         := 'parámetros - pccampanya:' || pccampanya || ' psproduc:' || psproduc || ' pcpais:'
            || pcpais || ' pcdpto:' || pcdpto || ' pcciudad:' || pcciudad || ' pcagrupa:'
            || pcagrupa || ' pcsucursal:' || pcsucursal || ' pcintermed:' || pcintermed
            || ' ppdto:' || ppdto;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER;
      vvalor         NUMBER;
   BEGIN
      IF pccampanya IS NULL
         OR psproduc IS NULL
         OR pcdpto IS NULL
         OR pcpais IS NULL
         OR pcciudad IS NULL
         OR pcagrupa IS NULL
         OR pcsucursal IS NULL
         OR pcintermed IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF NVL(pac_parametros.f_parempresa_t(pac_md_common.f_get_cxtempresa(),
                                           'SISTEMA_NUMERICO_BD'),
             ',.') = '.,' THEN
         vvalor := TO_NUMBER(REPLACE(ppdto, ',', '.'));
      ELSE
         vvalor := TO_NUMBER(ppdto);
      END IF;

      vnumerr :=
         pac_mntdtosespeciales.f_set_dtosespeciales_lin(pac_md_common.f_get_cxtempresa,
                                                        pccampanya, psproduc, pcpais, pcdpto,
                                                        pcciudad, pcagrupa, pcsucursal,
                                                        pcintermed, vvalor);

      IF vnumerr = 1 THEN
         RAISE e_object_error;
      ELSIF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      ELSE
         RETURN 0;
      END IF;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_set_dtosespeciales_lin;

    /**********************************************************************************************
      Función para recuperar descuento especial
       param in pccampanya:   campaña
       param out dtosespe: ob_iax_dtosespeciales
       param out mensajes: mensajes informativos


      Bug 26615/143210 - 16/05/2013 - AMC
   ************************************************************************************************/
   FUNCTION f_get_dtosespecial(
      pccampanya IN NUMBER,
      pdtosespe IN OUT ob_iax_dtosespeciales,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1000) := 'pccampanya:' || pccampanya;
      vobject        VARCHAR2(200) := 'pac_md_mntdtosespecial.f_get_dtosespecial';
      vnumerr        NUMBER;
      desc_det       ob_iax_dtosespeciales_det;
      pdtosespedet   t_iax_dtosespeciales_det;
   BEGIN
      IF pccampanya IS NULL THEN
         RAISE e_param_error;
      END IF;

      pdtosespe := ob_iax_dtosespeciales();

      SELECT c.ccampanya, c.finicio, c.ffin, d.tcampanya
        INTO pdtosespe.ccampanya, pdtosespe.finicio, pdtosespe.ffin, pdtosespe.tcampanya
        FROM coddtosespeciales c, descampanyas d
       WHERE c.ccampanya = pccampanya
         AND c.ccampanya = d.ccampanya
         AND c.cempres = pac_md_common.f_get_cxtempresa
         AND d.cidioma = pac_md_common.f_get_cxtidioma;

      pdtosespedet := t_iax_dtosespeciales_det();
      vpasexec := 3;

      FOR cur IN (SELECT *
                    FROM detdtosespeciales
                   WHERE ccampanya = pccampanya) LOOP
         desc_det := ob_iax_dtosespeciales_det();
         desc_det.sproduc := cur.sproduc;
         vpasexec := 4;
         vnumerr := f_dessproduc(cur.sproduc, 2, pac_md_common.f_get_cxtidioma,
                                 desc_det.tproduc);
         vpasexec := 5;
         desc_det.cpais := cur.cpais;
         desc_det.tpais := ff_despais(cur.cpais);
         desc_det.cdpto := cur.cdpto;
         desc_det.tdpto := f_desprovin2(cur.cdpto, NULL);
         vpasexec := 6;
         desc_det.cciudad := cur.cciudad;
         desc_det.tciudad := f_despoblac2(cur.cciudad, cur.cdpto);
         vpasexec := 7;
         desc_det.cagrupacion := cur.cagrupacion;
         desc_det.csucursal := cur.csucursal;
         vnumerr := f_desagente(cur.csucursal, desc_det.tsucursal);
         vpasexec := 8;
         desc_det.cintermediario := cur.cintermediario;
         vnumerr := f_desagente(cur.cintermediario, desc_det.tintermediario);
         vpasexec := 9;
         desc_det.pdto := cur.pdto;
         pdtosespedet.EXTEND;
         pdtosespedet(pdtosespedet.LAST) := desc_det;
      END LOOP;

      vpasexec := 10;
      pdtosespe.detdtos := pdtosespedet;
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
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_get_dtosespecial;

    /**********************************************************************************************
      Función para borrar un descuento
      param in pccampanya:

      Bug 26615/143210 - 22/05/2013 - AMC
   ************************************************************************************************/
   FUNCTION f_del_dtosespeciales(pccampanya IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(500) := 'pac_md_mntdtosespeciales.f_del_dtosespeciales';
      vparam         VARCHAR2(550) := 'parámetros - pccampanya:' || pccampanya;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER;
   BEGIN
      IF pccampanya IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_mntdtosespeciales.f_del_dtosespeciales(pac_md_common.f_get_cxtempresa,
                                                            pccampanya);

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
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_del_dtosespeciales;

   /**********************************************************************************************
      Función para borrar el detalle de un descuento
      param in pccampanya:

      Bug 26615/143210 - 22/05/2013 - AMC
   ************************************************************************************************/
   FUNCTION f_del_dtosespeciales_lin(
      pccampanya IN NUMBER,
      psproduc IN NUMBER,
      pcpais IN NUMBER,
      pcdpto IN NUMBER,
      pcciudad IN NUMBER,
      pcagrupa IN VARCHAR2,
      pcsucursal IN NUMBER,
      pcintermed IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(500) := 'pac_md_mntdtosespeciales.f_del_dtosespeciales';
      vparam         VARCHAR2(550)
         := 'parámetros - pccampanya:' || pccampanya || ' psproduc:' || psproduc || ' pcpais:'
            || pcpais || ' pcdpto:' || pcdpto || ' pcciudad:' || pcciudad || ' pcagrupa:'
            || pcagrupa || ' pcsucursal:' || pcsucursal || ' pcintermed:' || pcintermed;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER;
   BEGIN
      IF pccampanya IS NULL
         OR psproduc IS NULL
         OR pcdpto IS NULL
         OR pcpais IS NULL
         OR pcciudad IS NULL
         OR pcagrupa IS NULL
         OR pcsucursal IS NULL
         OR pcintermed IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr :=
         pac_mntdtosespeciales.f_del_dtosespeciales_lin(pac_md_common.f_get_cxtempresa,
                                                        pccampanya, psproduc, pcpais, pcdpto,
                                                        pcciudad, pcagrupa, pcsucursal,
                                                        pcintermed);

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
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_del_dtosespeciales_lin;

   /**********************************************************************************************
      Función para recuperar las agrupaciones tipo
      param IN OUT mensajes
      return cursor con los valores

      Bug 26615/143210 - 23/05/2013 - AMC
   ************************************************************************************************/
   FUNCTION f_get_cagrtipo(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'pac_md_mntdtosespeciales.f_get_cagrtipo';
      terror         VARCHAR2(200) := 'Error recuperar las agrupaciones tipo';
      vtexto         VARCHAR2(500);
   BEGIN
      vtexto := pac_mntdtosespeciales.f_get_cagrtipo();
      cur := pac_md_listvalores.f_opencursor(vtexto, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_cagrtipo;
END pac_md_mntdtosespeciales;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_MNTDTOSESPECIALES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_MNTDTOSESPECIALES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_MNTDTOSESPECIALES" TO "PROGRAMADORESCSI";
