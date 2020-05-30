--------------------------------------------------------
--  DDL for Package Body PAC_IAX_MNTPROD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IAX_MNTPROD" AS
/******************************************************************************
   NOMBRE:       PAC_IAX_MNTPROD
   PROPÓSITO: Funciones para mantenimiento productos

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        02/04/2008   ACC                1. Creación del package.
   2.0        13/01/2009   XCG                2. Modificació del package (s'han afegit més funcions)
   3.0        29/06/2009   AMC                3. Se añaden nuevas funciones bug 10557
   4.0        05/05/2010   AMC                4. Bug 14284. Se añaden nuevas funciones.
   5.0        27/05/2010   AMC                5. Se añade la función f_del_garantia bug 14723
   6.0        07/06/2010   PFA                6. 14588: CRT001 - Añadir campo compañia productos
   7.0        16/06/2010   AMC                7. Se añaden nuevas funciones bug 15023
   8.0        18/06/2010   AMC                8. Bug 15148 - Se añaden nuevas funciones
   9.0        21/06/2010   AMC                9. Bug 15149 - Se añaden nuevas funciones
  10.0        23/07/2010   PFA               10. 15513: MDP - Alta de productos
  11.0        15/12/2010   LCF               11. 16684: Anyadir ccompani para productos especiales
  12.0        17/05/2012   MDS               12. 0022253: LCOL - Duración del cobro como campo desplegable
  13.0        23/01/2014   AGG               13. 0027306: POSS518 (POSSF200)- Resolucion de Incidencias FASE 1-2: Tecnico - VI - Temporales anuales renovables
  14.0        18/02/2014   DEV               14. 0029920: POSFC100-Taller de Productos
  15.0        25/09/2014   JTT               15. 0032620: Añadimos el parametro pcprovis a la funcion F_set_datostec
                                                 0032367: Añadimos el parametro cnv_spr a la funcion F_set_admprod
******************************************************************************/

   -- Bug 14588 - 07/06/2010 - PFA
   /**************************************************************************
     Inserta un nuevo registro en la tabla companipro. Si existe, lo actualiza
     param in psproduc     : Codigo del producto
     param in pccompani    : Codigo de la compania
     param in pcagencorr   : Codigo del agente en la compania/producto
     param in psproducesp  : Codigo del producto especifico
   **************************************************************************/
   FUNCTION f_insert_companipro(
      psproduc IN NUMBER,
      pccompani IN NUMBER,
      pcagencorr IN VARCHAR2,
      psproducesp IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(1) := 1;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
         := 'parámetros - psproduc:' || psproduc || ' pccompani=' || pccompani
            || ' pcagencorr=' || pcagencorr || ' psproducesp=' || psproducesp;
      vobject        VARCHAR2(200) := 'PAC_IAX_MNTPROD.f_insert_companipro';
      v_fich         VARCHAR2(400);
   BEGIN
      vnumerr := pac_md_mntprod.f_insert_companipro(psproduc, pccompani, pcagencorr,
                                                    psproducesp, mensajes);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      --   ELSE
       --     pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 109904);
      END IF;

      COMMIT;
      RETURN vnumerr;
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
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_insert_companipro;

   /**************************************************************************
     Borra un registro de la tabla companipro.
     param in psproduc     : Codigo del producto
     param in pccompani    : Codigo de la compania
   **************************************************************************/
   FUNCTION f_delete_companipro(
      psproduc IN NUMBER,
      pccompani IN NUMBER,
      psproducesp IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_result       NUMBER := 1;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
                        := 'parámetros - psproduc= ' || psproduc || ' pccompani=' || pccompani;
      vobject        VARCHAR2(200) := 'PAC_IAX_MNTPROD.f_delete_companipro';
   BEGIN
      vpasexec := 1;

      --Comprovem els parametres d'entrada.
      IF psproduc IS NULL
         OR pccompani IS NULL
         OR psproducesp IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      v_result := pac_md_mntprod.f_delete_companipro(psproduc, pccompani, psproducesp,
                                                     mensajes);
      COMMIT;
      RETURN v_result;
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
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_delete_companipro;

   --Fi Bug 14588 - 07/06/2010 - PFA

   /*************************************************************************
      Recupera el objeto con la información del producto
      param in pcempresa   : código empresa
      param in pcramo      : código ramo
      param in pcagrpro    : código agrupación producto
      param in pcactivo    : activo
      param out mensajes   : mensajes de error
   *************************************************************************/
   FUNCTION f_get_consulta(
      pcempresa IN NUMBER,
      pcramo IN NUMBER,
      pcagrpro IN NUMBER,
      pcactivo IN NUMBER,
      ccompani IN NUMBER,   --BUG 14588 - PFA -  CRT001 - Añadir campo compañia productos
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'pcempresa=' || pcempresa || ' pcramo=' || pcramo || ' pcagrpro=' || pcagrpro
            || ' pcactivo=' || pcactivo || ' ccompani=' || ccompani;
      vobject        VARCHAR2(200) := 'PAC_IAX_MNTPROD.F_Get_Consulta';
   BEGIN
      cur := pac_md_mntprod.f_get_consulta(pcempresa, pcramo, pcagrpro, pcactivo, ccompani,
                                           mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_consulta;

   /*************************************************************************
        Recupera el objeto con la información del producto filtrado
        param in pcempresa   : código empresa
        param in pcramo      : código ramo
        param in pcagrpro    : código agrupación producto
        param in pcactivo    : activo
        param out mensajes   : mensajes de error
     *************************************************************************/
   FUNCTION f_get_consulta_filtrado(
      pcempresa IN NUMBER,
      pcramo IN NUMBER,
      pcagrpro IN NUMBER,
      pcactivo IN NUMBER,
      ccompani IN NUMBER,   --BUG 14588 - PFA -  CRT001 - Añadir campo compañia productos
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'pcempresa=' || pcempresa || ' pcramo=' || pcramo || ' pcagrpro=' || pcagrpro
            || ' pcactivo=' || pcactivo || ' ccompani=' || ccompani;
      vobject        VARCHAR2(200) := 'PAC_IAX_MNTPROD.F_Get_Consulta';
   BEGIN
      cur := pac_md_mntprod.f_get_consulta_filtrado(pcempresa, pcramo, pcagrpro, pcactivo,
                                                    ccompani, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_consulta_filtrado;

   /*************************************************************************
      Duplica el productos especificado como "origen", en un nuevo producto
      identificado como "destino". La salida del duplicado (script o ejecución
      directa en base de datos se puede especificar mediante el parámetro de
      entrada "psalida".
      param in  pramorig    : Ramo origen
      param in  pmodaliorig : Modalidad origen
      param in  ptipsegorig : Tipo seguro origen
      param in  pcolectorig : Colectividad origen
      param in  pramdest    : Ramo destino
      param in  pmodalidest : Modalidad destino
      param in  ptipsegdest : Tipo seguro destino
      param in  pcolectdest : Colectividad destino
      param in  psalida     : Tipo de salida 1/0 ' Script / BD
      param out mensajes    : mensajes de error
      retorno: 0 -> Todo ha ido bien
               <>0 -> Error al duplicar producto.
   *************************************************************************/
   FUNCTION f_duplicarprod(
      pramorig IN NUMBER,
      pmodaliorig IN NUMBER,
      ptipsegorig IN NUMBER,
      pcolectorig IN NUMBER,
      pramdest IN NUMBER,
      pmodalidest IN NUMBER,
      ptipsegdest IN NUMBER,
      pcolectdest IN NUMBER,
      psalida IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vnumerr        NUMBER(8) := 0;
      vparam         VARCHAR2(200)
         := 'parámetros - pramorig: ' || pramorig || 'pmodaliorig: ' || pmodaliorig
            || 'ptipsegorig: ' || ptipsegorig || 'pcolectorig: ' || pcolectorig
            || 'pramdest: ' || pramdest || 'pmodalidest: ' || pmodalidest || 'ptipsegdest: '
            || ptipsegdest || 'pcolectdest: ' || pcolectdest || 'psalida: ' || psalida;
      vobject        VARCHAR2(200) := 'PAC_IAX_MNTPROD.F_DuplicarProd';
   BEGIN
      IF pramorig IS NULL
         OR pmodaliorig IS NULL
         OR ptipsegorig IS NULL
         OR pcolectorig IS NULL
         OR pramdest IS NULL
         OR pmodalidest IS NULL
         OR ptipsegdest IS NULL
         OR pcolectdest IS NULL
         OR psalida IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      vnumerr := pac_md_mntprod.f_duplicarprod(pramorig, pmodaliorig, ptipsegorig, pcolectorig,
                                               pramdest, pmodalidest, ptipsegdest, pcolectdest,
                                               psalida, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      --Producte duplicat correctament.
      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 152708);
      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_duplicarprod;

   /*************************************************************************
      Recupera el objeto con la información del producto
      param in psproduc  : código producto
      param out mensajes : mensajes de error
   *************************************************************************/
   FUNCTION f_get_producto(psproduc IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN ob_iax_producto IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'psproduc=' || psproduc;
      vobject        VARCHAR2(200) := 'PAC_IAX_MNTPROD.F_Get_Producto';
      mntproducto    ob_iax_producto := ob_iax_producto();
   BEGIN
      IF psproduc IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      mntproducto := pac_md_mntprod.f_get_producto(psproduc, mensajes);
      vtitulos := pac_md_mntprod.f_get_prodtitulo(psproduc, mensajes);
      RETURN mntproducto;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_producto;

   /*************************************************************************
      Recupera los datos generales del producto
      param in psproduc  : código producto
      param out mensajes : mensajes de error
   *************************************************************************/
   FUNCTION f_get_datosgenerales(psproduc IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN ob_iax_producto IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'psproduc=' || psproduc;
      vobject        VARCHAR2(200) := 'PAC_IAX_MNTPROD.F_Get_DatosGenerales';
      mntproducto    ob_iax_producto;
   BEGIN
      IF psproduc IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      mntproducto := pac_md_mntprod.f_get_datosgenerales(psproduc, mensajes);
      RETURN mntproducto;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_datosgenerales;

   /*************************************************************************
      Recupera el objeto con la información del producto datos de gestión
      param in psproduc  : código producto
      param out mensajes : mensajes de error
   *************************************************************************/
   FUNCTION f_get_gestion(psproduc IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN ob_iax_prodgestion IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'psproduc=' || psproduc;
      vobject        VARCHAR2(200) := 'PAC_IAX_MNTPROD.F_Get_Gestion';
      mntprodgestion ob_iax_prodgestion := ob_iax_prodgestion();
   BEGIN
      IF psproduc IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      mntprodgestion := pac_md_mntprod.f_get_gestion(psproduc, mensajes);
      RETURN mntprodgestion;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_gestion;

   /*************************************************************************
      Recupera el objeto con la información del producto datos de gestión
      param in psproduc  : código producto
      param out mensajes : mensajes de error
   *************************************************************************/
   FUNCTION f_get_durperiod(psproduc IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN t_iax_proddurperiodo IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'psproduc=' || psproduc;
      vobject        VARCHAR2(200) := 'PAC_IAX_MNTPROD.F_Get_Durperiod';
      mntdurperiod   t_iax_proddurperiodo := t_iax_proddurperiodo();
   BEGIN
      IF psproduc IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      mntdurperiod := pac_md_mntprod.f_get_durperiod(psproduc, mensajes);
      RETURN mntdurperiod;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_durperiod;

   /*************************************************************************
      Recupera el objeto con la información del producto
      datos administración
      param in psproduc  : código producto
      param out mensajes : mensajes de error
   *************************************************************************/
   FUNCTION f_get_admprod(psproduc IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN ob_iax_prodadministracion IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'psproduc=' || psproduc;
      vobject        VARCHAR2(200) := 'PAC_IAX_MNTPROD.F_Get_Admprod';
      mntamdprod     ob_iax_prodadministracion := ob_iax_prodadministracion();
   BEGIN
      IF psproduc IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      mntamdprod := pac_md_mntprod.f_get_admprod(psproduc, mensajes);
      RETURN mntamdprod;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_admprod;

   /*************************************************************************
      Permite recuperar las formas de pago que tiene definidas el producto.
      param in psproduc  : código producto
      param out mensajes : mensajes de error
   *************************************************************************/
   FUNCTION f_get_forpago(psproduc IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN t_iax_prodformapago IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'psproduc=' || psproduc;
      vobject        VARCHAR2(200) := 'PAC_IAX_MNTPROD.F_Get_ForPago';
   BEGIN
      --Comprovació de paràmetres
      IF psproduc IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      vforpagprod := pac_md_mntprod.f_get_forpago(psproduc, mensajes);

      IF vforpagprod IS NULL THEN
         RAISE e_object_error;
      END IF;

      RETURN vforpagprod;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_forpago;

   /*************************************************************************
      Recupera las garantias del producto y actividad
      param in psproduc  : código del producto
      param in pcactivi  : código actividad
      param out mensajes : mensajes de error
      return             : objecto garantias
   *************************************************************************/
   FUNCTION f_get_garantias(psproduc IN NUMBER, pcactivi IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN t_iax_prodgarantias IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'psproduc=' || psproduc || ' pcactivi=' || pcactivi;
      vobject        VARCHAR2(200) := 'PAC_IAX_MNTPROD.F_Set_Garantias';
      garan          t_iax_prodgarantias := t_iax_prodgarantias();
   BEGIN
      garan := pac_md_mntprod.f_get_garantias(psproduc, pcactivi, mensajes);
      RETURN garan;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_garantias;

    /*************************************************************************
      Recupera el objeto con la información de la actividad
      param in psproduc  : código producto
      param in pcactivi  : código actividad
      param out mensajes : mensajes de error
   *************************************************************************/
   FUNCTION f_get_detailactivid(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN ob_iax_prodactividades IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'psproduc=' || psproduc || ' pcactivi=' || pcactivi;
      vobject        VARCHAR2(200) := 'PAC_IAX_MNTPROD.F_Get_DetailActivid';
      mntactivid     ob_iax_prodactividades := ob_iax_prodactividades();
   BEGIN
      IF psproduc IS NULL THEN
         -- OR pcactivi IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF pcactivi IS NULL THEN
         RETURN NULL;
      END IF;

      vpasexec := 3;
      mntactivid.paractividad := pac_md_mntprod.f_get_paractividad(psproduc, pcactivi,
                                                                   mensajes);
      mntactivid.pregunacti := pac_md_mntprod.f_get_pregunacti(psproduc, pcactivi, mensajes);
      mntactivid.recfraccacti := pac_md_mntprod.f_get_recfraccacti(psproduc, pcactivi,
                                                                   mensajes);
      RETURN mntactivid;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_detailactivid;

   /*************************************************************************
      Recupera el objeto con la información de la garantia
      param in psproduc  : código producto
      param in pcactivi  : código actividad
      param in pcgarant  : código garantia
      param out mensajes : mensajes de error
   *************************************************************************/
   FUNCTION f_get_detailgaran(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN ob_iax_prodgarantias IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
            := 'psproduc=' || psproduc || ' pcactivi=' || pcactivi || ' pcgarant=' || pcgarant;
      vobject        VARCHAR2(200) := 'PAC_IAX_MNTPROD.F_Get_DetailGaran';
      mntgaran       ob_iax_prodgarantias := ob_iax_prodgarantias();
   BEGIN
      IF psproduc IS NULL
         --OR pcactivi IS NULL
         OR pcgarant IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF pcactivi IS NULL THEN
         RETURN NULL;
      END IF;

      vpasexec := 3;
      mntgaran := pac_md_mntprod.f_get_datosgeneralesgaran(psproduc, pcactivi, pcgarant,
                                                           mensajes);   --JOSE
      mntgaran.datgestion := pac_md_mntprod.f_get_gestiongaran(psproduc, pcactivi, pcgarant,
                                                               mensajes);   --JAVIER
      mntgaran.impuestos := pac_md_mntprod.f_get_impuestosgaran(psproduc, pcactivi, pcgarant,
                                                                mensajes);   --SHEILA
      mntgaran.incompgaran := pac_md_mntprod.f_get_incompatigaran(psproduc, pcactivi, pcgarant,
                                                                  mensajes);   --SHEILA
      mntgaran.dattecnicos := pac_md_mntprod.f_get_datostecngaran(psproduc, pcactivi, pcgarant,
                                                                  mensajes);   --JOSE MARIA
      mntgaran.formulas := pac_md_mntprod.f_get_formulasgaran(psproduc, pcactivi, pcgarant,
                                                              mensajes);   --JESUS
      mntgaran.preguntas := pac_md_mntprod.f_get_pregungaran(psproduc, pcactivi, pcgarant,
                                                             mensajes);   --JOSE
      mntgaran.cumulos := pac_md_mntprod.f_get_cumulosgaran(psproduc, pcactivi, pcgarant,
                                                            mensajes);   --ALBERT
      mntgaran.parametros := pac_md_mntprod.f_get_paramgaran(psproduc, pcactivi, pcgarant,
                                                             mensajes);   --JOSE MARIA
      RETURN mntgaran;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_detailgaran;

   /*************************************************************************
      Recupera el cursor con la información de la tabla GARANPRO
      param in psproduc  : código producto
      param in pcactivi  : código actividad
      param out mensajes : mensajes de error
   *************************************************************************/
   FUNCTION f_get_datosgeneralesgaran(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN ob_iax_prodgarantias IS
      vobjectname    VARCHAR2(500) := 'PAC_IAX_MNTPROD.F_Get_DatosGeneralesGaran';
      vparam         VARCHAR2(500)
         := 'parámetros - psproduc :' || psproduc || ' - pcactivi' || pcactivi
            || ' - pcgarant: ' || pcgarant;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vobj           ob_iax_prodgarantias := ob_iax_prodgarantias();
   BEGIN
      IF psproduc IS NULL
         OR pcactivi IS NULL
         OR pcgarant IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      vobj := pac_md_mntprod.f_get_datosgeneralesgaran(psproduc, pcactivi, pcgarant, mensajes);
      RETURN vobj;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN NULL;
   END f_get_datosgeneralesgaran;

   /*************************************************************************
      Recupera el objeto con la información de la garantia
      datos de gestión
      param in psproduc  : código producto
      param in pcactivi  : código de la actividad
      param in pcgarant  : código de la garantia
      param out mensajes : mensajes de error
   *************************************************************************/
   FUNCTION f_get_gestiongaran(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN ob_iax_prodgardatgestion IS
      mntgestion     ob_iax_prodgardatgestion := ob_iax_prodgardatgestion();
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'parámetros - psproduc :' || psproduc || ' - pcactivi' || pcactivi
            || ' - pcgarant: ' || pcgarant;
      vobject        VARCHAR2(200) := 'PAC_IAX_MNTPROD.F_Get_GestionGaran';
      vobj           ob_iax_prodgardatgestion := ob_iax_prodgardatgestion();

      CURSOR cur_ges IS
         SELECT g.*
           FROM garanpro g
          WHERE g.sproduc = psproduc
            AND g.cgarant = pcgarant
            AND g.cactivi = pcactivi;
   BEGIN
      IF psproduc IS NULL
         OR pcactivi IS NULL
         OR pcgarant IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      vobj := pac_md_mntprod.f_get_gestiongaran(psproduc, pcactivi, pcgarant, mensajes);
      RETURN vobj;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_gestiongaran;

   /*************************************************************************
       Recupera el objeto con la información de las formulas de una garantia
       param in psproduc  : código producto
       param in pcactivi  : código actividad
       param in pgarant  : código garantía
       param out mensajes : mensajes de error
    *************************************************************************/
   FUNCTION f_get_impuestosgaran(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN ob_iax_prodgarimpuestos IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'parámetros - psproduc :' || psproduc || ' - pcactivi' || pcactivi
            || ' - pcgarant: ' || pcgarant;
      vobject        VARCHAR2(200) := 'PAC_IAX_MNTPROD.F_Get_ImpuestosGaran';
      vobj           ob_iax_prodgarimpuestos := ob_iax_prodgarimpuestos();
   BEGIN
      --Comprovació de paràmetres correctes
      IF psproduc IS NULL
         OR pcactivi IS NULL
         OR pcgarant IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      vobj := pac_md_mntprod.f_get_impuestosgaran(psproduc, pcactivi, pcgarant, mensajes);
      RETURN vobj;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_impuestosgaran;

   /*************************************************************************
       Recupera el objeto con la información de las formulas de una garantia
       param in psproduc  : código producto
       param in pcactivi  : código actividad
       param in pgarant  : código garantía
       param out mensajes : mensajes de error
    *************************************************************************/
   FUNCTION f_get_formulasgaran(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN t_iax_prodgarformulas IS
      mntgaranformula t_iax_prodgarformulas := t_iax_prodgarformulas();
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(400)
              := 'psproduc=' || psproduc || 'pcactivi=' || pcactivi || 'pcgarant:' || pcgarant;
      vobject        VARCHAR2(200) := 'PAC_IAX_MNTPROD.F_Get_FormulasGaran';
   BEGIN
      --Comprovació de paràmetres correctes
      IF psproduc IS NULL
         OR pcactivi IS NULL
         OR pcgarant IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      mntgaranformula := pac_md_mntprod.f_get_formulasgaran(psproduc, pcactivi, pcgarant,
                                                            mensajes);
      RETURN mntgaranformula;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_formulasgaran;

   /*************************************************************************
      Actualiza la variable persistente "vtitulos"
      param in psproduc  : código del producto
      param in pcidioma  : código idioma
      param in pttitulo  : Título
      param in ptrotulo  : Rótulo
      param out mensajes : mensajes de error
      Return 0 si es correcto 1 si falla
   *************************************************************************/
   FUNCTION f_set_prodtitulo(
      pcidioma IN NUMBER,
      pttitulo IN VARCHAR2,
      ptrotulo IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
             := 'pttiulo=' || pttitulo || ' ptrotulo=' || ptrotulo || ' pcidioma=' || pcidioma;
      vobject        VARCHAR2(200) := 'PAC_IAX_MNTPROD.F_Set_Prodtitulo';
      vmodif         BOOLEAN := FALSE;
   BEGIN
      --Comprovació de paràmetres correctes
      IF pcidioma IS NULL
         OR pttitulo IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;

      IF vtitulos IS NOT NULL THEN
         --Mirem d'actualitzar el títol/ròtul del producte.
         FOR titu IN vtitulos.FIRST .. vtitulos.LAST LOOP
            IF vtitulos.EXISTS(titu) THEN
               IF vtitulos(titu).cidioma = pcidioma THEN
                  vtitulos(titu).ttitulo := pttitulo;
                  vtitulos(titu).trotulo := ptrotulo;
                  vmodif := TRUE;
               END IF;
            END IF;
         END LOOP;
      END IF;

      vpasexec := 5;

      --Si no existia el títol/ròtul passat per paràmetre, el donem d'alta.
      IF vtitulos IS NULL
         OR NOT(vmodif) THEN
         IF vtitulos IS NULL THEN
            vtitulos := t_iax_prodtitulo();
         END IF;

         vtitulos.EXTEND;
         vtitulos(vtitulos.LAST) := ob_iax_prodtitulo();
         vtitulos(vtitulos.LAST).cidioma := pcidioma;
         vtitulos(vtitulos.LAST).ttitulo := pttitulo;
         vtitulos(vtitulos.LAST).trotulo := ptrotulo;
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
   END f_set_prodtitulo;

   /*************************************************************************
      Realiza las validaciones, inserciones o modificaciones
      param in psproduc    : código del producto
      param in pcramo      : código del ramo
      param in pcmodali    : código de la modalidad
      param in pctipseg    : código del tipo de seguro
      param in pccolect    : código de colectividad
      param in pcactivo    : indica si el producto está activo
      param in pctermfin   : contratable desde el terminal financiero, 0.-Si, 1.-No
      param in pctiprie    : tipo de riesgo
      param in pcobjase    : Tipo de objeto asegurado
      param in pcsubpro    : Código de subtipo de producto
      param in pnmaxrie    : maximo riesgo
      param in pc2cabezas  : c2cabezas
      param in pcagrpro    : Codigo agrupación de producto
      param in pcdivisa    : Clave de Divisa
      param out mensajes   : mensajes de error
      return               : 0 si ha ido bien
                            1 si ha ido mal
   *************************************************************************/
   FUNCTION f_set_datosgenerales(
      psproduc IN NUMBER,
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      pcactivo IN NUMBER,
      pctermfin IN NUMBER,
      pctiprie IN NUMBER,
      pcobjase IN NUMBER,
      pcsubpro IN NUMBER,
      pnmaxrie IN NUMBER,
      pc2cabezas IN NUMBER,
      pcagrpro IN NUMBER,
      pcdivisa IN NUMBER,
      pcprprod IN NUMBER,
      pcompani IN NUMBER,
      psproduc_nou OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'psproduc=' || psproduc;
      vobject        VARCHAR2(200) := 'PAC_IAX_MNTPROD.F_Set_DatosGenerales';
      vpsproduc      NUMBER;
      nerror         NUMBER := 0;
      mntproducto    ob_iax_producto;
   BEGIN
      /*    --Comprovació de paràmetres
          IF psproduc IS NULL THEN
              RAISE e_param_error;
          END IF;*/
      vpasexec := 3;
      nerror := pac_md_mntprod.f_validadatosgenerales(psproduc, pcramo, pcmodali, pctipseg,
                                                      pccolect, pcactivo, pctermfin, pctiprie,
                                                      pcobjase, pcsubpro, pnmaxrie,
                                                      pc2cabezas, pcagrpro, pcdivisa,
                                                      pcompani, vtitulos, mensajes);

      IF nerror <> 0 THEN
         RAISE e_object_error;
      END IF;

      vpasexec := 5;
      vpsproduc := psproduc;
      nerror := pac_md_mntprod.f_set_datosgenerales(vpsproduc, pcramo, pcmodali, pctipseg,
                                                    pccolect, pcactivo, pctermfin, pctiprie,
                                                    pcobjase, pcsubpro, pnmaxrie, pc2cabezas,
                                                    pcagrpro, pcdivisa, vtitulos, pcprprod,
                                                    pcompani, mensajes);

      IF nerror <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;   --Si tot ha anat bé -> gravació de les dades.

      IF psproduc IS NULL THEN
         nerror := f_sproduc(pcramo, pcmodali, pctipseg, pccolect, psproduc_nou);
      END IF;

      RETURN nerror;
   EXCEPTION
      WHEN e_param_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_set_datosgenerales;

   /*************************************************************************
      Valida los datos de gestión de un producto
      param in psproduc   : código del producto
      param in cduraci    : código de la duración
      param in ctempor    : Permite temporal
      param in ndurcob    : Duración pagos
      param in cdurmin    : Duración mínima
      param in nvtomin    : Tipo
      param in cdurmax    : duración máxima póliza
      param in nvtomax    : Número años máximo para el vto.
      param in ctipefe    : Tipo de efecto
      param in nrenova    : renovación
      param in cmodnre    : Fecha de renovación
      param in cprodcar   : Si ha pasado cartera
      param in crevali    : Código de revalorización
      param in prevali    : Porcentaje revalorización
      param in irevali    : Importe revalorización
      param in ctarman    : tarificación puede ser manual
      param in creaseg    : creaseg
      param in creteni    : Indicador de propuesta
      param in cprorra    : tipo prorrateo
      param in cprimin    : tipo de prima minima
      param in iprimin    : importe mínimo prima de recibo en emisión
      param in cclapri    : Fórmula prima mínima
      param in ipminfra   : Prima mínima fraccionada
      param in nedamic    : Edad mín ctr
      param in ciedmic    : Edad real
      param in nedamac    : Edad máx. ctr
      param in ciedmac    : Edad Real. Check por defecto = 0 ( sino es actuarial)
      param in nedamar    : Edad máx. ren
      param in ciedmar    : Edad Real
      param in nedmi2c    : Edad mín ctr 2º aseg.
      param in ciemi2c    : Edad real
      param in nedma2c    : Edad máx. ctr 2º aseg.
      param in ciema2c    : Edad Real
      param in nedma2r    : Edad máx. ren 2º aseg.
      param in ciema2r    : Real o Actuarial
      param in nsedmac    : Suma Máx. Edades
      param in cisemac    : Real
      param in cvinpol    : Póliza vinculada
      param in cvinpre    : Préstamo vinculado
      param in ccuesti    : Cuestionario Salud
      param in cctacor    : Libreta
      return              : 0 si ha ido bien
                           error si ha ido mal
   *************************************************************************/
   FUNCTION f_set_gestion(
      psproduc IN NUMBER,
      pcduraci IN NUMBER,
      pctempor IN NUMBER,
      pndurcob IN NUMBER,
      pcdurmin IN NUMBER,
      pnvtomin IN NUMBER,
      pcdurmax IN NUMBER,
      pnvtomax IN NUMBER,
      pctipefe IN NUMBER,
      pnrenova IN NUMBER,
      pcmodnre IN NUMBER,
      pcprodcar IN NUMBER,
      pcrevali IN NUMBER,
      pprevali IN NUMBER,
      pirevali IN NUMBER,
      pctarman IN NUMBER,
      pcreaseg IN NUMBER,
      pcreteni IN NUMBER,
      pcprorra IN NUMBER,
      pcprimin IN NUMBER,
      piprimin IN NUMBER,
      pcclapri IN NUMBER,
      pipminfra IN NUMBER,
      pnedamic IN NUMBER,
      pciedmic IN NUMBER,
      pnedamac IN NUMBER,
      pciedmac IN NUMBER,
      pnedamar IN NUMBER,
      pciedmar IN NUMBER,
      pnedmi2c IN NUMBER,
      pciemi2c IN NUMBER,
      pnedma2c IN NUMBER,
      pciema2c IN NUMBER,
      pnedma2r IN NUMBER,
      pciema2r IN NUMBER,
      pnsedmac IN NUMBER,
      pcisemac IN NUMBER,
      pcvinpol IN NUMBER,
      pcvinpre IN NUMBER,
      pccuesti IN NUMBER,
      pcctacor IN NUMBER,
      pcpreaviso IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'psproduc=' || psproduc;
      vobject        VARCHAR2(200) := 'PAC_IAX_MNTPROD.F_Set_Gestion';
      nerror         NUMBER := 0;
   BEGIN
      --Comprovació de paràmetres
      IF psproduc IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;

      IF pac_md_mntprod.f_validagestion(psproduc, pcduraci, pctempor, pndurcob, pcdurmin,
                                        pnvtomin, pcdurmax, pnvtomax, pctipefe, pnrenova,
                                        pcmodnre, pcprodcar, pcrevali, pprevali, pirevali,
                                        pctarman, pcreaseg, pcreteni, pcprorra, pcprimin,
                                        piprimin, pcclapri, pipminfra, pnedamic, pciedmic,
                                        pnedamac, pciedmac, pnedamar, pciedmar, pnedmi2c,
                                        pciemi2c, pnedma2c, pciema2c, pnedma2r, pciema2r,
                                        pnsedmac, pcisemac, pcvinpol, pcvinpre, pccuesti,
                                        pcctacor, mensajes) = 0 THEN
         vpasexec := 5;

         IF pac_md_mntprod.f_set_gestion(psproduc, pcduraci, pctempor, pndurcob, pcdurmin,
                                         pnvtomin, pcdurmax, pnvtomax, pctipefe, pnrenova,
                                         pcmodnre, pcprodcar, pcrevali, pprevali, pirevali,
                                         pctarman, pcreaseg, pcreteni, pcprorra, pcprimin,
                                         piprimin, pcclapri, pipminfra, pnedamic, pciedmic,
                                         pnedamac, pciedmac, pnedamar, pciedmar, pnedmi2c,
                                         pciemi2c, pnedma2c, pciema2c, pnedma2r, pciema2r,
                                         pnsedmac, pcisemac, pcvinpol, pcvinpre, pccuesti,
                                         pcctacor, pcpreaviso, mensajes) <> 0 THEN
            RAISE e_object_error;
         END IF;
      ELSE
         RAISE e_object_error;
      END IF;

      COMMIT;   --Si tot ha anat bé -> gravació de les dades.
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_set_gestion;

   /*************************************************************************
       Borra las duraciones permitidas para un producto
       param in psproduc   : código del producto
       param in Pfinicio   : fecha inicio
       param in pndurper   : duracion
       param out mensajes  : mensajes de error
       return              : 0 si ha ido bien
                             1 si ha ido mal
   *************************************************************************/
   FUNCTION f_del_durperiod(
      psproduc IN NUMBER,
      pfinicio IN DATE,
      pndurper IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'psproduc=' || psproduc || ' - pfinicio=' || pfinicio || ' - pndurper='
            || pndurper;
      vobject        VARCHAR2(200) := 'PAC_IAX_MNTPROD.F_Del_Duperiod';
      nerror         NUMBER := 0;
   BEGIN
      --Comprovació de paràmetres
      IF psproduc IS NULL
         OR pfinicio IS NULL
         OR pndurper IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;

      IF pac_md_mntprod.f_del_durperiod(psproduc, pfinicio, pndurper, mensajes) <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;   --Si tot ha anat bé -> gravació de les dades.
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_del_durperiod;

   /*************************************************************************
       Modifica o inserta un periodo
       param in psproduc   : código del producto
       param in pfinicio   : fecha inicio
       param in pndurper   : duracion
       param in pndurperOld: duracion anterior
       param out mensajes  : mensajes de error
       return              : 0 si ha ido bien
                             1 si ha ido mal
    *************************************************************************/
   FUNCTION f_set_durperiod(
      psproduc IN NUMBER,
      pfinicio IN DATE,
      pndurper IN NUMBER,
      pndurperold IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'psproduc=' || psproduc || ' - pfinicio=' || pfinicio || ' - pndurper='
            || pndurper || ' - pndurperold=' || pndurperold;
      vobject        VARCHAR2(200) := 'PAC_IAX_MNTPROD.F_Set_Duperiod';
      nerror         NUMBER := 0;
   BEGIN
      -- ini 0007085
      --Comprovació de paràmetres
      IF psproduc IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF pfinicio IS NULL
         OR pndurper IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 40202);
         RAISE e_object_error;
      END IF;

      -- fin 0007085
      vpasexec := 3;

      IF pac_md_mntprod.f_set_durperiod(psproduc, pfinicio, pndurper, pndurperold, mensajes) <>
                                                                                              0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;   --Si tot ha anat bé -> gravació de les dades.
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_set_durperiod;

   /*************************************************************************
      Realiza las  modificaciones y validaciones de los datos de admnistración del producto
      param in psproduc    : código del producto
      param in Pctipges    : Gestión del seguro.
      param in pcreccob    : 1er recibo
      param in pctipreb    : Recibo por.
      param in pccalcom    : Cálculo comisión
      param in pctippag    : Cobro
      param in pcmovdom    : Domiciliar el primer recibo
      param in pcfeccob    : Acepta fecha de cobro
      param in pcrecfra    : Recargo Fraccionamiento
      param in piminext    : Prima mínima extorno
      param in pndiaspro   : Días acumulables
      param in pcnv_spr    : Identificador del cliente para el producto en contabilidad
      param out mensajes   : mensajes de error
      retorna un cero si todo va bien  y un uno en caso contrario
   *************************************************************************/
   FUNCTION f_set_admprod(
      psproduc IN NUMBER,
      pctipges IN NUMBER,
      pcreccob IN NUMBER,
      pctipreb IN NUMBER,
      pccalcom IN NUMBER,
      pctippag IN NUMBER,
      pcmovdom IN NUMBER,
      pcfeccob IN NUMBER,
      pcrecfra IN NUMBER,
      piminext IN NUMBER,
      pndiaspro IN NUMBER,
      pcnv_spr IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := ' sproduc:' || psproduc || ' ,ctipges:' || pctipges || ' ,creccob:' || pcreccob
            || ' ,ctipreb:' || pctipreb || ' ,ccalcom:' || pccalcom || ' ,ctippag:'
            || pctippag || ' ,cmovdom:' || pcmovdom || ' ,cfeccob:' || pcfeccob
            || ' ,crecfra:' || pcrecfra || ' ,iminext:' || piminext || ' ,ndiaspro:'
            || pndiaspro || ' ,cnv_spr:' || pcnv_spr;
      vobject        VARCHAR2(200) := 'PAC_IAX_MNTPROD.F_Set_AdmProd';
      nerror         NUMBER := 0;
   BEGIN
      --Comprovació de paràmetres
      IF psproduc IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      nerror := pac_md_mntprod.f_set_admprod(psproduc, pctipges, pcreccob, pctipreb, pccalcom,
                                             pctippag, pcmovdom, pcfeccob, pcrecfra, piminext,
                                             pndiaspro, pcnv_spr, mensajes);

      IF nerror <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;   --Si tot ha anat bé -> gravació de les dades.
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_set_admprod;

   /*************************************************************************
      Modifica las formas de pago del producto.
      param in psproduc  : código producto
      param out mensajes : mensajes de error
   *************************************************************************/
   FUNCTION f_set_forpago(
      psproduc IN NUMBER,
      pcforpag IN NUMBER,
      ptforpag IN VARCHAR2,
      pcobliga IN NUMBER,
      pprecarg IN NUMBER,
      pcpagdef IN NUMBER,
      pcrevfpg IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8);
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'psproduc=' || psproduc;
      vobject        VARCHAR2(200) := 'PAC_IAX_MNTPROD.F_SetForPago';
   BEGIN
      --Comprovació de paràmetres
      IF psproduc IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      --Inserció de les dades de formes de pagament emmagatzemades en memòria.
      --vnumerr := pac_md_mntprod.f_set_forpago(psproduc, vforpagprod, mensajes);
      --
      vnumerr := pac_md_mntprod.f_set_forpago(psproduc, pcforpag, ptforpag, pcobliga, pprecarg,
                                              pcpagdef, pcrevfpg, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      --COMMIT; --Si tot ha anat bé -> gravació de les dades.
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_set_forpago;

   /*************************************************************************
      Inserta o modifica los impuestos de una garantia
      param in psproduc    : código del producto
      param in pcactivi    : código de la actividad
      param in pcgarant    : código de la garantía
      param in pcimpcon    : aplica consorcio 0/1
      param in pcimpdgs    : aplica la DGS 0/1
      param in pcimpips    : aplica IPS 0/1
      param in pcimparb    : se calcula arbitrios 0/1
      param in pcimpfng    :
      param out mensajes   : mensajes de error
      return               : 0 si ha ido bien
                            numero error si ha ido mal
   *************************************************************************/
   FUNCTION f_set_impuestosgaran(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pcimpcon IN NUMBER,
      pcimpdgs IN NUMBER,
      pcimpips IN NUMBER,
      pcimparb IN NUMBER,
      pcimpfng IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(400)
         := 'psproduc=' || psproduc || ' pcactivi=' || pcactivi || ' pcgarant=' || pcgarant
            || ' pcimpcon=' || pcimpcon || ' pcimpdgs=' || pcimpdgs || ' pcimpips='
            || pcimpips || ' pcimparb=' || pcimparb || 'pcimpfng=' || pcimpfng;
      vobject        VARCHAR2(200) := 'PAC_IAX_MNTPROD.F_Set_ImpuestosGaran';
      vpsproduc      NUMBER;
      nerror         NUMBER := 0;
      mntgarant      ob_iax_prodgarantias;
   BEGIN
      --Comprovació de paràmetres
      IF psproduc IS NULL
         OR pcactivi IS NULL
         OR pcgarant IS NULL
         OR pcimpcon IS NULL
         OR pcimpdgs IS NULL
         OR pcimpips IS NULL
         OR pcimparb IS NULL
         OR pcimpfng IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      nerror := pac_md_mntprod.f_set_impuestosgaran(psproduc, pcactivi, pcgarant, pcimpcon,
                                                    pcimpdgs, pcimpips, pcimparb, pcimpfng,
                                                    mensajes);

      IF nerror <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;   --Si tot ha anat bé -> gravació de les dades.
      RETURN nerror;
   EXCEPTION
      WHEN e_param_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_set_impuestosgaran;

   /*************************************************************************
      Inserta o modifica la formula de una garantia
      param in psproduc    : código del producto
      param in pcactivi    : código de la actividad
      param in pcgarant    : código de la garantía
      param in pccampo     : código del campo
      param in pclave      : clave fórmula
      param out mensajes   : mensajes de error
      return               : 0 si ha ido bien
                            numero error si ha ido mal
   *************************************************************************/
   FUNCTION f_set_prodgarformulas(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pccampo IN VARCHAR2,
      pclave IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(400)
         := 'Psproduc=' || psproduc || ' Pcactivi=' || pcactivi || ' Pcgarant=' || pcgarant
            || ' Pccampo=' || pccampo || ' Pclave=' || pclave;
      vobject        VARCHAR2(200) := 'PAC_IAX_MNTPROD.F_Set_ProdGarFormulas';
      vpsproduc      NUMBER;
      nerror         NUMBER := 0;
      mntproducto    ob_iax_producto;
   BEGIN
      --Comprovació de paràmetres
      IF psproduc IS NULL
         OR pcactivi IS NULL
         OR pcgarant IS NULL
         OR pccampo IS NULL
         OR pclave IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      nerror := pac_md_mntprod.f_set_prodgarformulas(psproduc, pcactivi, pcgarant, pccampo,
                                                     pclave, mensajes);

      IF nerror <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;   --Si tot ha anat bé -> gravació de les dades.
      RETURN nerror;
   EXCEPTION
      WHEN e_param_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_set_prodgarformulas;

   /*************************************************************************
       función que nos devuelve la descripción de un cuadro de interés
       param in pncodint    : Código del cuadro
       param out mensajes   : mensajes de error
   *************************************************************************/
   FUNCTION f_get_descripncodint(pncodint IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN VARCHAR2 IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(400) := 'pncodint=' || pncodint;
      vobject        VARCHAR2(200) := 'PAC_IAX_MNTPROD.F_GET_DescripNcodint';
      texto          VARCHAR2(100);
   BEGIN
      texto := pac_md_mntprod.f_get_descripncodint(pncodint, mensajes);
      RETURN texto;
   EXCEPTION
      WHEN e_param_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_descripncodint;

   /*************************************************************************
       función que nos devuelve la descripción de un cuadro de interés
       param in pncodint    : Código del cuadro
       param in ctipo       : Código del tipo de interés
       param out mensajes   : mensajes de error
   *************************************************************************/
   FUNCTION f_get_intertecmov(pncodint IN NUMBER, ctipo IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN t_iax_intertecprod IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(400) := 'pncodint=' || pncodint || ' ctipo=' || ctipo;
      vobject        VARCHAR2(200) := 'PAC_IAX_MNTPROD.F_GET_INTERTECMOV';
      tiaxintertecprod t_iax_intertecprod := t_iax_intertecprod();
   BEGIN
      tiaxintertecprod := pac_md_mntprod.f_get_intertecmov(pncodint, ctipo, mensajes);
      RETURN tiaxintertecprod;
   EXCEPTION
      WHEN e_param_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_intertecmov;

   /*************************************************************************
       función que nos devuelve los tramos que tiene para un cuadro y un tipo de interés en concreto
       param in pncodint    : Código del cuadro
       param in pctipo       : Código del tipo de interés
       param in pfinicio     : Fecha de inicio
       param out mensajes   : mensajes de error
   *************************************************************************/
   FUNCTION f_get_intertecmovdet(
      pncodint IN NUMBER,
      pctipo IN NUMBER,
      pfinicio IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN t_iax_intertecmovdetprod IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(400)
                := 'pncodint=' || pncodint || ' pctipo=' || pctipo || ' pfinicio=' || pfinicio;
      vobject        VARCHAR2(200) := 'PAC_IAX_MNTPROD.F_GET_INTERTECMOVDET';
      iaxintertecmovdetprod t_iax_intertecmovdetprod := t_iax_intertecmovdetprod();
   BEGIN
      iaxintertecmovdetprod := pac_md_mntprod.f_get_intertecmovdet(pncodint, pctipo, pfinicio,
                                                                   mensajes);
      RETURN iaxintertecmovdetprod;
   EXCEPTION
      WHEN e_param_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_intertecmovdet;

   /*************************************************************************
       función que nos devolverá los datos técnicos de un producto
       param in psproduc    : código del producto
       param out mensajes   : mensajes de error
   *************************************************************************/
   FUNCTION f_get_dattecn(psproduc IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN ob_iax_proddatostecnicos IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(400) := 'PSPRODUC=' || psproduc;
      vobject        VARCHAR2(200) := 'PAC_IAX_MNTPROD.F_GET_DatTecn';
      mntdattecn     ob_iax_proddatostecnicos := ob_iax_proddatostecnicos();
   BEGIN
      mntdattecn := pac_md_mntprod.f_get_dattecn(psproduc, mensajes);
      RETURN mntdattecn;
   EXCEPTION
      WHEN e_param_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_dattecn;

   /*************************************************************************
       función que nos devolverá los datos técnicos de un producto
       param in pncodint    : Código del cuadro
       param out mensajes   : mensajes de error
   *************************************************************************/
   FUNCTION f_get_cuadrointeresprod(pncodint IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN t_iax_intertecprod IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(400) := 'PNCODINT=' || pncodint;
      vobject        VARCHAR2(200) := 'PAC_IAX_MNTPROD.F_Get_CuadroInteresProd';
      cur            sys_refcursor;
      mntintertecprod t_iax_intertecprod := t_iax_intertecprod();
   BEGIN
      mntintertecprod := pac_md_mntprod.f_get_cuadrointeresprod(pncodint, mensajes);
      RETURN mntintertecprod;
   EXCEPTION
      WHEN e_param_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_cuadrointeresprod;

   /*************************************************************************
       función que modificará los datos técnicos de un producto en concreto
       param in Psproduc  : Código del producto.
       PARAM IN pnniggar  : Indica si los gastos están a nivel de garantía Parámetro de entrada
       PARAM IN pnniigar  : Indicador de si el interés técnico está a nivel de garantía. Parámetro de entrada
       PARAM IN pcmodint  : Intereses tecnicos modificables en póliza.
       PARAM IN pcintrev  : Por defecto en renovación aplicar el interés del producto
       PARAM IN pncodint  : Código del cuadro de interés que se ha escogido para el producto
       param out mensajes : mensajes de error
   *************************************************************************/
   FUNCTION f_set_dattecn(
      psproduc IN NUMBER,
      pnniggar IN NUMBER,
      pnniigar IN NUMBER,
      pcmodint IN NUMBER,
      pcintrev IN NUMBER,
      pncodint IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(400)
         := 'PSPRODUC=' || psproduc || ' PNNIGGAR=' || pnniggar || ' PNNIIGAR=' || pnniigar
            || ' PCMODINT=' || pcmodint || ' PCINTREV=' || ' PNCODINT=' || pncodint;
      vobject        VARCHAR2(200) := 'PAC_IAX_MNTPROD.F_Set_DatTecn';
      num_err        NUMBER;
   BEGIN
      num_err := pac_md_mntprod.f_set_dattecn(psproduc, pnniggar, pnniigar, pcmodint,
                                              pcintrev, pncodint, mensajes);

      IF num_err <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_set_dattecn;

   /*************************************************************************
         función que recupera la descripción de un cuadro de interés
         PARAM IN PNCODINT  : Código del cuadro de interés que se ha escogido para el producto
         PARAM IN PCIDIOMA  : Código del Idioma
         PARAM IN TNCODINT  : Descripción del cuadro de interés
         param out mensajes : mensajes de error
    *************************************************************************/
   FUNCTION f_get_ncodint(
      pncodint IN NUMBER,
      pcidioma IN NUMBER,
      ptncodint IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(400)
          := ' PCMODINT=' || pncodint || ' PCIDIOMA=' || pcidioma || ' TNCODINT=' || ptncodint;
      vobject        VARCHAR2(200) := 'PAC_IAX_MNTPROD.F_GET_NCODINT';
      cur            sys_refcursor;
   BEGIN
      cur := pac_md_mntprod.f_get_ncodint(pncodint, pcidioma, ptncodint, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN e_object_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN OTHERS THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_ncodint;

   /*************************************************************************
       función que se encargará de borrar un cuadro de interés técnico
       PARAM IN PNCODINT  : Código del cuadro de interés que se ha escogido para el producto
       param out mensajes : mensajes de error
     *************************************************************************/
   FUNCTION f_del_intertec(pncodint IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(400) := ' PCMODINT=' || pncodint;
      vobject        VARCHAR2(200) := 'PAC_IAX_MNTPROD.F_DEL_INTERTEC';
      num_err        NUMBER;
   BEGIN
      num_err := pac_md_mntprod.f_del_intertec(pncodint, mensajes);

      IF num_err <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_del_intertec;

     /*************************************************************************
    función que se encargará de borrar una vigencia de un cuadro de interés técnico
    PARAM IN PNCODINT   : Código del cuadro de interés que se ha escogido para el producto
    PARAM IN PCTIPO     : Código del tipo de interés.
    PARAM IN PFINICIO   : Fecha inicio vigencia del tramo.
   *************************************************************************/
   FUNCTION f_del_intertecmov(
      pncodint IN NUMBER,
      pctipo IN NUMBER,
      pfinicio IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(400)
               := ' PCMODINT=' || pncodint || ' PCTIPO=' || pctipo || ' PFINICIO=' || pfinicio;
      vobject        VARCHAR2(200) := 'PAC_IAX_MNTPROD.F_DEL_INTERTECMOV';
      num_err        NUMBER;
   BEGIN
      num_err := pac_md_mntprod.f_del_intertecmov(pncodint, pctipo, pfinicio, mensajes);

      IF num_err <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_del_intertecmov;

    /*************************************************************************
        Función que se encargará de borrar una vigencia de un cuadro de interés técnico
        PARAM IN PNCODINT  : Código del cuadro de interés
        PARAM IN PCTIPO    : Código del tipo de interés.
        PARAM IN PFINICIO  : Fecha inicio vigencia del tramo.
        PARAM IN PNDESDE   : importe/edad desde
        PARAM OUT mensajes : mensajes de error
   *************************************************************************/
   FUNCTION f_del_intertecmovdet(
      pncodint IN NUMBER,
      pctipo IN NUMBER,
      pfinicio IN DATE,
      pndesde IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(400)
         := ' PCMODINT=' || pncodint || ' PCTIPO=' || pctipo || ' PFINICIO=' || pfinicio
            || ' PNDESDE=' || pndesde;
      vobject        VARCHAR2(200) := 'PAC_IAX_MNTPROD.F_DEL_INTERTECMOVDET';
      num_err        NUMBER;
   BEGIN
      num_err := pac_md_mntprod.f_del_intertecmovdet(pncodint, pctipo, pfinicio, pndesde,
                                                     mensajes);

      IF num_err <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_del_intertecmovdet;

    /*************************************************************************
    función que se encargará de recuperar la información de una vigencia en concreto para un cuadro de interés.
    PARAM IN PNCODINT   : Código del cuadro de interés que se ha escogido para el producto
    PARAM IN PCTIPO     : Código del tipo de interés.
    PARAM IN PFINICIO   : Fecha inicio vigencia del tramo.
    PARAM OUT PFFIN
    PARAM OUT PCTRAMTIP
    param out mensajes  : mensajes de error
   *************************************************************************/
   FUNCTION f_getreg_intertecmov(
      pncodint IN NUMBER,
      pctipo IN NUMBER,
      pfinicio IN DATE,
      pffin OUT DATE,
      pctramtip OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(400)
               := ' PCMODINT=' || pncodint || ' PCTIPO=' || pctipo || ' PFINICIO=' || pfinicio;
      vobject        VARCHAR2(200) := 'PAC_IAX_MNTPROD.F_GETREG_INTERTECMOV';
      num_err        NUMBER;
   BEGIN
      num_err := pac_md_mntprod.f_getreg_intertecmov(pncodint, pctipo, pfinicio, pffin,
                                                     pctramtip, mensajes);

      IF num_err <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_getreg_intertecmov;

    /*************************************************************************
    función que se encarga de validar y grabar una nueva vigencia para un cuadro de interés.
    PARAM IN PNCODINT   : Código del cuadro de interés que se ha escogido para el producto
    PARAM IN PCTIPO     : Código del tipo de interés.
    PARAM IN PFINICIO   : Fecha inicio vigencia del tramo.
    PARAM IN PFFIN      : Fecha fin
    PARAM IN PCTRAMTIP  : Código del concepto del tramo
    param out mensajes  : mensajes de error
   *************************************************************************/
   FUNCTION f_set_intertecmov(
      pncodint IN NUMBER,
      pctipo IN NUMBER,
      pfinicio IN DATE,
      pffin IN DATE,
      pctramtip IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(400)
         := ' PCMODINT=' || pncodint || ' PCTIPO=' || pctipo || ' PFINICIO=' || pfinicio
            || ' PFFIN=' || pffin || ' PCTRAMTIP=' || pctramtip;
      vobject        VARCHAR2(200) := 'PAC_IAX_MNTPROD.F_GETREG_INTERTECMOV';
      num_err        NUMBER;
   BEGIN
      num_err := pac_md_mntprod.f_set_intertecmov(pncodint, pctipo, pfinicio, pffin,
                                                  pctramtip, mensajes);

      IF num_err <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_set_intertecmov;

   /*************************************************************************
   función que nos sirve para recuperar un registro de un tramo en concreto
   PARAM IN PNCODINT    : Código del cuadro de interés que se ha escogido para el producto
   PARAM IN PCTIPO      : Código del tipo de interés.
   PARAM IN PFINICIO    : Fecha inicio vigencia del tramo.
   PARAM IN NDESDE      : Inicio deL tramo
   PARAM OUT NHASTA     : Fin del tramo
   PARAM OUT PNINTTEC   : Porcentaje de interes
   PARAM OUT MENSAJES   : mensajes de error
   *************************************************************************/
   FUNCTION f_getreg_intertecmovdet(
      pncodint IN NUMBER,
      pctipo IN NUMBER,
      pfinicio IN DATE,
      pndesde IN NUMBER,
      pnhasta OUT NUMBER,
      pninttec OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(400)
         := ' PCMODINT=' || pncodint || ' PCTIPO=' || pctipo || ' PFINICIO=' || pfinicio
            || ' PNDESDE=' || pndesde;
      vobject        VARCHAR2(200) := 'PAC_IAX_MNTPROD.F_GETREG_INTERTECMOV';
      num_err        NUMBER;
   BEGIN
      num_err := pac_md_mntprod.f_getreg_intertecmovdet(pncodint, pctipo, pfinicio, pndesde,
                                                        pnhasta, pninttec, mensajes);

      IF num_err <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_getreg_intertecmovdet;

   /*************************************************************************
   función que modifica o da de alta un nuevo tramo
   PARAM IN PNCODINT    : Código del cuadro de interés que se ha escogido para el producto
   PARAM IN PCTIPO      : Código del tipo de interés.
   PARAM IN PFINICIO    : Fecha inicio vigencia del tramo.
   PARAM IN NDESDE      : Inicio deL tramo
   PARAM OUT NHASTA     : Fin del tramo
   PARAM OUT PNINTTEC   : Porcentaje de interes
   PARAM OUT MENSAJES   : mensajes de error
   *************************************************************************/
   FUNCTION f_set_intertecmovdet(
      pncodint IN NUMBER,
      pctipo IN NUMBER,
      pfinicio IN DATE,
      pndesde IN NUMBER,
      pnhasta IN NUMBER,
      pninttec IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(400)
         := ' PCMODINT=' || pncodint || ' PCTIPO=' || pctipo || ' PFINICIO=' || pfinicio
            || ' PNDESDE=' || pndesde || ' PNHASTA=' || pnhasta || ' PNINTTEC=' || pninttec;
      vobject        VARCHAR2(200) := 'PAC_IAX_MNTPROD.F_SET_INTERTECMOVDET';
      num_err        NUMBER;
   BEGIN
      num_err := pac_md_mntprod.f_set_intertecmovdet(pncodint, pctipo, pfinicio, pndesde,
                                                     pnhasta, pninttec, mensajes);

      IF num_err <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_set_intertecmovdet;

/*******BUG8510-13/01/2008-XCG Afegir funcions************************/
/*************************************************************************
        Función que INSERTA las actividades seleccionadas previamente.
        PARAM IN PCRAMO   : Código del Ramo del producto
        PARAM IN PCMODALI : Código de la Modalidad del producto
        PARAM IN PCTIPSEG : Código del tipo de Seguro del producto
        PARAM IN PCCOLECT : Código del la Colectividad del producto
        PARAM IN PSPRODUC : Código del Identificador del producto
        PARAM IN PCACTIVI : Código de la Actividad
        PARAM IN OUT MENSAJE : mensajes de error
        RETURN NUMBER(0: operación correcta sino num error)
   *************************************************************************/
   FUNCTION f_set_actividades(
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER := 0;
   BEGIN
      mensajes := t_iax_mensajes();
      --LLAMADA A LA FUNCIÓN
      vnumerr := pac_md_mntprod.f_set_actividades(pcramo, pcmodali, pctipseg, pccolect,
                                                  psproduc, pcactivi, mensajes);

      IF vnumerr = 0 THEN
         COMMIT;
      ELSE
         ROLLBACK;
      END IF;

      RETURN vnumerr;
   END f_set_actividades;

/*************************************************************************
       Recupera el objeto con la información del producto
       parámetros actividades
       param in psproduc  : código producto
       param in pcactivi  : código acticividad
       param out mensajes : mensajes de error
    *************************************************************************/
   FUNCTION f_get_paractividad(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN t_iax_prodparactividad IS
      vprodparactividad t_iax_prodparactividad;
   BEGIN
      mensajes := t_iax_mensajes();
      --LLAMADA A LA FUNCIÓN
      vprodparactividad := pac_md_mntprod.f_get_paractividad(psproduc, pcactivi, mensajes);
      RETURN vprodparactividad;
   END;

/*************************************************************************
        Función que retorna un objeto con el recargo del fraccionamiento asignado a una actividad de producto.
        PARAM IN PCRAMO        : Código del Ramo del producto
        PARAM IN PCMODALI      : Código de la Modalidad del producto
        PARAM IN PCTIPSEG      : Código del tipo de Seguro del producto
        PARAM IN PCCOLECT      : Código del la Colectividad del producto
        PARAM IN PSPRODUC      : Código del Identificador del producto
        PARAM IN PCACTIVI      : Código de la Actividad
        PARAM IN OUT PREACTIVI : Tipo T_IAX_PRODRECFRACCACTI, recargo de fraccionamiento, según forma de pago,
                                 de una actividad
        PARAM IN OUT MENSAJE : TIPO T_IAX_MENSAJES mensajes de error
        RETURN T_IAX_PRODRECFRACCACTI
   *************************************************************************/
   FUNCTION f_get_recactividad(
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN t_iax_prodrecfraccacti IS
      vnumerr        NUMBER := 0;
      vpreactivi     t_iax_prodrecfraccacti;
   BEGIN
      mensajes := t_iax_mensajes();
      --LLAMADA A LA FUNCIÓN
      vnumerr := pac_md_mntprod.f_get_recactividad(pcramo, pcmodali, pctipseg, pccolect,
                                                   psproduc, pcactivi, vpreactivi, mensajes);
      RETURN vpreactivi;
   END f_get_recactividad;

/*************************************************************************
        Función que retorna un objeto con las preguntas definidas a nivel de una actividad de producto.
        PARAM IN PCRAMO      : Código del Ramo del producto
        PARAM IN PCMODALI    : Código de la Modalidad del producto
        PARAM IN PCTIPSEG    : Código del tipo de Seguro del producto
        PARAM IN PCCOLECT    : Código del la Colectividad del producto
        PARAM IN PSPRODUC    : Código del Identificador del producto
        PARAM IN PCACTIVI    : Código de la Actividad
        PARAM IN  PPREGACTIVI  : Tipo T_IAX_PRODPREGUNACTI, Preuntas definidas a nivel de actividad
        PARAM IN OUT MENSAJE : TIPO T_IAX_MENSAJES mensajes de error
        RETURN T_IAX_PRODPREGUNACTI
   *************************************************************************/
   FUNCTION f_get_pregactividad(
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN t_iax_prodpregunacti IS
      vnumerr        NUMBER := 0;
      vppregactivi   t_iax_prodpregunacti;
   BEGIN
      mensajes := t_iax_mensajes();
      --LLAMADA A LA FUNCIÓN
      vnumerr := pac_md_mntprod.f_get_pregactividad(pcramo, pcmodali, pctipseg, pccolect,
                                                    psproduc, pcactivi, vppregactivi,
                                                    mensajes);
      RETURN vppregactivi;
   END f_get_pregactividad;

/*************************************************************************
        Función que retorna un objeto con las actividades de un producto.
        PARAM IN PCRAMO      : Código del Ramo del producto
        PARAM IN PCMODALI    : Código de la Modalidad del producto
        PARAM IN PCTIPSEG    : Código del tipo de Seguro del producto
        PARAM IN PCCOLECT    : Código del la Colectividad del producto
        PARAM IN PSPRODUC    : Código del Identificador del producto
        PARAM IN PCACTIVI    : Código de la Actividad
        PARAM IN PPRODACTIVI : Tipo T_IAX_PRODACTIVIDADES
        PARAM IN OUT MENSAJE : TIPO T_IAX_MENSAJES mensajes de error
        RETURN T_IAX_PRODPREGUNACTI
   *************************************************************************/
   FUNCTION f_get_actividades(
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN t_iax_prodactividades IS
      vnumerr        NUMBER := 0;
      vpprodacivi    t_iax_prodactividades;
   BEGIN
      mensajes := t_iax_mensajes();
      --LLAMADA A LA FUNCIÓN
      vnumerr := pac_md_mntprod.f_get_actividades(pcramo, pcmodali, pctipseg, pccolect,
                                                  psproduc, pcactivi, vpprodacivi, mensajes);
      RETURN vpprodacivi;
   END f_get_actividades;

/*************************************************************************
        Función que inserta datos de la forma de pago y recargo por actividad.
        PARAM IN PCRAMO      : Código del Ramo del producto
        PARAM IN PCMODALI    : Código de la Modalidad del producto
        PARAM IN PCTIPSEG    : Código del tipo de Seguro del producto
        PARAM IN PCCOLECT    : Código del la Colectividad del producto
        PARAM IN PSPRODUC    : Código del Identificador del producto
        PARAM IN PCACTIVI    : Código de la Actividad
        PARAM IN PCFORPAG    : Código de la forma de pago
        PARAM IN PPRECARG    : Porcentage del recargo
        PARAM IN OUT MENSAJE : TIPO T_IAX_MENSAJES mensajes de error
        RETURN NUMBER(0: operación correcta sino num error)
   *************************************************************************/
   FUNCTION f_set_recactividad(
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcforpag IN NUMBER,
      pprecarg IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER := 0;
   BEGIN
      mensajes := t_iax_mensajes();
      --LLAMADA A LA FUNCIÓN
      vnumerr := pac_md_mntprod.f_set_recactividad(pcramo, pcmodali, pctipseg, pccolect,
                                                   psproduc, pcactivi, pcforpag, pprecarg,
                                                   mensajes);

      IF vnumerr = 0 THEN
         COMMIT;
      ELSE
         ROLLBACK;
      END IF;

      RETURN vnumerr;
   END f_set_recactividad;

/*************************************************************************
        Función que se utiliza para comprobar si existen pólizas de una actividad definida en un producto
        PARAM IN PSPRODUC    : Código del Identificador del producto
        PARAM IN PCACTIVI    : Código de la Actividad
        PARAM OUT NERROR     : Código de error
        PARAM IN OUT MENSAJES : TIPO T_IAX_MENSAJES mensajes de error
        RETURN NUMBER(0: operación correcta sino num error)
   *************************************************************************/
   FUNCTION f_exist_actpol(psproduc IN NUMBER, pcactivi IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER := 0;
   BEGIN
      mensajes := t_iax_mensajes();
      --LLAMADA A LA FUNCIÓN
      vnumerr := pac_md_mntprod.f_exist_actpol(psproduc, pcactivi, mensajes);
      RETURN vnumerr;
   END f_exist_actpol;

/*************************************************************************
        Función que inserta preguntas por producto y actividad.
        PARAM IN PCRAMO      : Código del Ramo del producto
        PARAM IN PCMODALI    : Código de la Modalidad del producto
        PARAM IN PCTIPSEG    : Código del tipo de Seguro del producto
        PARAM IN PCCOLECT    : Código del la Colectividad del producto
        PARAM IN PSPRODUC    : Código del Identificador del producto
        PARAM IN PCACTIVI    : Código de la Actividad
        PARAM IN PCPREGUN    : Código de pregunta
        PARAM IN PCPRETIP    : Código tipo de respuesta (manual,automática) valor fijo: 787
        PARAM IN PNPREORD    : Número de orden en el que se pregunta
        PARAM IN PTPREFOR    : Fórmula para plantear la pregunta
        PARAM IN PCPREOBL    : Obligatorio (Sí-1,No-0)
        PARAM IN PNPREIMP    : Orden de impresión
        PARAM IN PCRESDEF    : Respuesta por defecto
        PARAM IN PCOFERSN    : Código: Aparece en ofertas? (Sí-1,No-0)
        PARAM IN PTVALOR     : Fórmula para validar la respuesta
        PARAM IN OUT MENSAJES : TIPO T_IAX_MENSAJES mensajes de error
        RETURN NUMBER(0: operación correcta sino num error)
 *************************************************************************/
   FUNCTION f_set_pregactividad(
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcpregun IN NUMBER,
      pcpretip IN NUMBER,
      pnpreord IN NUMBER,
      ptprefor IN VARCHAR2,
      pcpreobl IN NUMBER,
      pnpreimp IN NUMBER,
      pcresdef IN NUMBER,
      pcofersn IN NUMBER,
      ptvalfor IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER := 0;
   BEGIN
      --LLAMADA A LA FUNCIÓN
      mensajes := t_iax_mensajes();
      vnumerr := pac_md_mntprod.f_set_pregactividad(pcramo, pcmodali, pctipseg, pccolect,
                                                    psproduc, pcactivi, pcpregun, pcpretip,
                                                    pnpreord, ptprefor, pcpreobl, pnpreimp,
                                                    pcresdef, pcofersn, ptvalfor, mensajes);

      IF vnumerr = 0 THEN
         COMMIT;
      ELSE
         ROLLBACK;
      END IF;

      RETURN vnumerr;
   END f_set_pregactividad;

/*************************************************************************
        Función que se utiliza para borrar la actividad definida en un producto
        PARAM IN PSPRODUC    : Código del Identificador del producto
        PARAM IN PCACTIVI    : Código de la Actividad
        PARAM OUT NERROR     : Código de error
        PARAM IN OUT MENSAJES : TIPO T_IAX_MENSAJES mensajes de error
        RETURN NUMBER(0: operación correcta sino num error)
   *************************************************************************/
   FUNCTION f_borrar_actividades(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER := 0;
   BEGIN
      --LLAMADA A LA FUNCIÓN
      mensajes := t_iax_mensajes();
      vnumerr := pac_md_mntprod.f_borrar_actividades(psproduc, pcactivi, mensajes);

      IF vnumerr = 0 THEN
         COMMIT;
      ELSE
         ROLLBACK;
      END IF;

      RETURN vnumerr;
   END f_borrar_actividades;

   /**********************************************************************
           Función que duplica actividad.
           PARAM IN PCRAMO      : Código del Ramo del producto
           PARAM IN PCMODALI    : Código de la Modalidad del producto
           PARAM IN PCTIPSEG    : Código del tipo de Seguro del producto
           PARAM IN PCCOLECT    : Código del la Colectividad del producto
           PARAM IN PSPRODUC    : Código del Identificador del producto
           PARAM IN PCACTIVI    : Código de la Actividad
           PARAM IN PCACTIVIC   : Código de la Actividad destino
           PARAM IN OUT MENSAJES : TIPO T_IAX_MENSAJES mensajes de error
           RETURN NUMBER        : Código de error (0: operación correcta sino 1)
     **********************************************************************/
   FUNCTION f_duplicar_actividades(
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcactivic IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER := 0;
   BEGIN
      --LLAMADA A LA FUNCIÓN
      mensajes := t_iax_mensajes();
      vnumerr := pac_md_mntprod.f_duplicar_actividades(pcramo, pcmodali, pctipseg, pccolect,
                                                       psproduc, pcactivi, pcactivic,
                                                       mensajes);

      IF vnumerr = 0 THEN
         COMMIT;
      ELSE
         ROLLBACK;
      END IF;

      RETURN vnumerr;
   END f_duplicar_actividades;

/**FI BUG8510************************/

   /*************************************************************************
         Función para asignar cláusulas de beneficiario al producto
         PARAM IN PSPRODUC    : Código del Identificador del producto
         PARAM IN PSCLABEN    : Código de la clausula
         PARAM OUT MENSAJES   : Mensajes de error
         RETURN NUMBER        : Código de error (0: operación correcta sino 1)

         Bug 10557   29/06/2009  AMC
   **********************************************************************/
   FUNCTION f_set_benefpro(psproduc IN NUMBER, psclaben IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(100) := 'PAC_IAX:MNTPROD.f_set_benefpro';
      vparam         VARCHAR2(400) := ' psproduc:' || psproduc || ' psclaben:' || psclaben;
      vpasexec       NUMBER := 1;
      vnumerr        NUMBER := 0;
      vnorden        NUMBER;
   BEGIN
      IF psproduc IS NULL
         OR psclaben IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_mntprod.f_set_benefpro(psproduc, psclaben, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_set_benefpro;

   /*************************************************************************
          Función para asignar una cláusula de beneficiario por defecto al producto
          PARAM IN PSPRODUC    : Código del Identificador del producto
          PARAM IN PSCLABEN    : Código de la clausula
          PARAM OUT MENSAJES   : Mensajes de error
          RETURN NUMBER        : Código de error (0: operación correcta sino 1)

          Bug 10557   29/06/2009  AMC
    **********************************************************************/
   FUNCTION f_set_benefdefecto(
      psproduc IN NUMBER,
      psclaben IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(100) := 'PAC_IAX_MNTPROD.F_SET_BENEFDEFECTO';
      vparam         VARCHAR2(400) := ' psproduc:' || psproduc || ' psclaben:' || psclaben;
      vpasexec       NUMBER := 1;
      vnumerr        NUMBER := 0;
      vnorden        NUMBER;
   BEGIN
      IF psproduc IS NULL
         OR psclaben IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_mntprod.f_set_benefdefecto(psproduc, psclaben, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_set_benefdefecto;

   /*************************************************************************
         Función que retorna las cláusulas de beneficirio no asignadas a un producto
         PARAM IN PSPRODUC    : Código del Identificador del producto
         PARAM OUT MENSAJES   : Mensajes de error
         RETURN NUMBER        : Código de error (0: operación correcta sino 1)

         Bug 10557   29/06/2009  AMC
   **********************************************************************/
   FUNCTION f_get_benef_noasig(psproduc IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vobjectname    VARCHAR2(100) := 'PAC_IAX_MNTPROD.F_GET_BENEF_NOASIG';
      vparam         VARCHAR2(400) := ' psproduc:' || psproduc;
      vpasexec       NUMBER := 1;
      vnumerr        NUMBER := 0;
      cur            sys_refcursor;
      squery         VARCHAR2(400);
   BEGIN
      IF psproduc IS NULL THEN
         RAISE e_param_error;
      END IF;

      cur := pac_md_mntprod.f_get_benef_noasig(psproduc, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_benef_noasig;

   /*************************************************************************
         Función que se utiliza para desasignar una cláusula del producto
         PARAM IN PSPRODUC    : Código del Identificador del producto
         PARAM IN PSCLABEN    : Código de la clausula
         PARAM OUT PNERROR    : Código del error
         PARAM OUT MENSAJES   : Mensajes de error
         RETURN NUMBER        : Código de error (0: operación correcta sino 1)

         Bug 10557   29/06/2009  AMC
   **********************************************************************/
   FUNCTION f_del_benefpro(
      psproduc IN NUMBER,
      psclaben IN NUMBER,
      pnerror OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(100) := 'PAC_IAX_MNTPROD.F_DEL_BENEFPRO';
      vparam         VARCHAR2(400) := ' psproduc:' || psproduc || ' psclaben:' || psclaben;
      vpasexec       NUMBER := 1;
      vnumerr        NUMBER;
   BEGIN
      IF psproduc IS NULL
         OR psclaben IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_mntprod.f_del_benefpro(psproduc, psclaben, pnerror, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_del_benefpro;

   /*************************************************************************
         Función que retorna las cláusulas asignadas a un producto
         PARAM IN PSPRODUC    : Código del Identificador del producto
         PARAM OUT MENSAJES   : Mensajes de error
         RETURN T_IAX_PRODBENEFICIARIOS

         Bug 10557   29/06/2009  AMC
   **********************************************************************/
   FUNCTION f_get_benefpro(psproduc IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN t_iax_prodbeneficiarios IS
      vobjectname    VARCHAR2(100) := 'PAC_IAX_MNTPROD.F_GET_BENEFPRO';
      vparam         VARCHAR2(400) := ' psproduc:' || psproduc;
      vpasexec       NUMBER := 1;
      vnumerr        NUMBER := 0;
      clausulas      t_iax_prodbeneficiarios;
   BEGIN
      IF psproduc IS NULL THEN
         RAISE e_param_error;
      END IF;

      clausulas := pac_md_mntprod.f_get_benefpro(psproduc, mensajes);
      RETURN clausulas;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN NULL;
   END f_get_benefpro;

   /*************************************************************************
         Función que asigna una garantia a un producto
         PARAM IN PSPRODUC    : Código del Identificador del producto
         PARAM IN PCGARANT    : Código de la garantia
         PARAM IN PCACTIVI    : Código de la actividad
         PARAM IN PNORDEN     : Numero de orden
         PARAM IN PCTIPGAR    : Código de tipo de garantia
         PARAM IN PCTIPCAR    : Código de tipo de capital
         PARAM IN OUT MENSAJES   : Mensajes de error
         RETURN NUMBER

         Bug 14284   26/04/2010  AMC
   **********************************************************************/
   FUNCTION f_set_garantiaprod(
      psproduc IN NUMBER,
      pcgarant IN NUMBER,
      pcactivi IN NUMBER,
      pnorden IN NUMBER,
      pctipgar IN NUMBER,
      pctipcap IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(100) := 'PAC_IAX_MNTPROD.F_SET_GARANTIAPROD';
      vparam         VARCHAR2(400)
           := ' psproduc:' || psproduc || ' pcgarant:' || pcgarant || ' pcactivi:' || pcactivi;
      vpasexec       NUMBER := 1;
      vnumerr        NUMBER := 0;
   BEGIN
      IF pcactivi IS NULL THEN
         RAISE e_param_act_error;
      END IF;

      IF psproduc IS NULL
         OR pcgarant IS NULL
         OR pnorden IS NULL
         OR pctipgar IS NULL
         OR pctipcap IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_mntprod.f_set_garantiaprod(psproduc, pcgarant, pcactivi, pnorden,
                                                   pctipgar, pctipcap, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN e_param_act_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 9904805, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_set_garantiaprod;

   /*************************************************************************
         Función que devuelve la lista de parametro por garantia
         PARAM IN PCIDIOMA    : Código de idioma
         PARAM OUT MENSAJES   : Mensajes de error
         RETURN sys_refcursor

         Bug 14284   29/04/2010  AMC
   **********************************************************************/
   FUNCTION f_get_pargarantia(pcidioma IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vobjectname    VARCHAR2(100) := 'PAC_IAX_MNTPROD.f_get_pargarantia';
      vparam         VARCHAR2(400) := ' pcidioma:' || pcidioma;
      vpasexec       NUMBER := 1;
      vnumerr        NUMBER := 0;
      cur            sys_refcursor;
      squery         VARCHAR2(400);
   BEGIN
      cur := pac_md_mntprod.f_get_pargarantia(pcidioma, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_pargarantia;

   /*************************************************************************
         Función que retorna el tipo de respuesta y la lista de valores de un parametro
         PARAM IN PCPARGAR    : codigo del parametro
         PARAM IN PCIDIOMA    : Código del idioma
         PARAM OUT PCTIPO     : tipo de respuesta
         PARAM OUT PLISTRESP  : lista de posibles respuestas
         PARAM IN OUT MENSAJES   : Mensajes de error
         RETURN sys_refcursor

         Bug 14284   29/04/2010  AMC
   **********************************************************************/
   FUNCTION f_get_valpargarantia(
      pcpargar IN VARCHAR2,
      pcidioma IN NUMBER,
      pctipo OUT NUMBER,
      plistresp OUT sys_refcursor,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(100) := 'PAC_IAX_MNTPROD.f_get_valpargarantia';
      vparam         VARCHAR2(400) := 'pcpargar:' || pcpargar || ' pcidioma:' || pcidioma;
      vpasexec       NUMBER := 1;
      vnumerr        NUMBER := 0;
   BEGIN
      vnumerr := pac_md_mntprod.f_get_valpargarantia(pcpargar, pcidioma, pctipo, plistresp,
                                                     mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_get_valpargarantia;

   /*************************************************************************
      Inicializa los capitales
      param out          : mensajes de error
      return             : 0 todo ha sido correcto
                           1 ha habido un error

     Bug 14284 - 05/05/2010 - AMC
   *************************************************************************/
   FUNCTION f_inicializa_capitales(mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_IAX_MNTPROD.F_Inicializa_capitales';
      vparam         VARCHAR2(500) := 'parámetros - NULL';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vlistcapitales := t_iax_prodgaranprocap();
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_inicializa_capitales;

   /*************************************************************************
      Inicializa las listas de capitales de una garantia
      param in psproduc  : codigo del producto
      param in pcgarant  : codigo de la garantia
      param in pcactivi  : codigo de la actividad
      param out          : mensajes de error
      return             : 0 todo ha sido correcto
                           1 ha habido un error

     Bug 14284 - 05/05/2010 - AMC
   *************************************************************************/
   FUNCTION f_inicializa_capital(
      psproduc IN NUMBER,
      pcgarant IN NUMBER,
      pcactivi IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_IAX_MNTPROD.F_Inicializa_capital';
      vparam         VARCHAR2(500)
         := 'parámetros - psproduc:' || psproduc || ' pcgarant:' || pcgarant || ' pcactivi:'
            || pcactivi;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      capitales      t_iax_prodgaranprocap;
   BEGIN
      IF psproduc IS NULL
         OR pcgarant IS NULL
         OR pcactivi IS NULL THEN
         RAISE e_param_error;
      END IF;

      --if capitales is null then
      vnumerr := f_inicializa_capitales(mensajes);
      --end if;
      vnumerr := pac_md_mntprod.f_inicializa_capital(psproduc, pcgarant, pcactivi, capitales,
                                                     mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      pac_iax_mntprod.vlistcapitales := capitales;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_inicializa_capital;

   /*************************************************************************
      Devuelve los capitales
      param out          : mensajes de error
      return             : 0 todo ha sido correcto
                           1 ha habido un error

     Bug 14284 - 05/05/2010 - AMC
   *************************************************************************/
   FUNCTION f_get_obj_capitales(mensajes OUT t_iax_mensajes)
      RETURN t_iax_prodgaranprocap IS
      vobjectname    VARCHAR2(500) := 'PAC_IAX_MNTPROD.F_Inicializa_capitales';
      vparam         VARCHAR2(500) := 'parámetros - NULL';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      RETURN pac_iax_mntprod.vlistcapitales;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN NULL;
   END f_get_obj_capitales;

   /*************************************************************************
      Inserta un nuevo capital
      param in picapital  : importe del capital
      param in pcdefecto  : importe por defecto 0-No/1-Si
      param out          : mensajes de error
      return             : 0 todo ha sido correcto
                           1 ha habido un error

     Bug 14284 - 05/05/2010 - AMC
   *************************************************************************/
   FUNCTION f_set_obj_capital(picapital NUMBER, pcdefecto NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_IAX_MNTPROD.f_set_obj_capital';
      vparam         VARCHAR2(500)
                       := 'parámetros - picapital:' || picapital || ' pcdefecto:' || pcdefecto;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      -- Solo puede haber un capital por defecto
      IF pcdefecto = 1
         AND vlistcapitales.COUNT > 0 THEN
         FOR i IN vlistcapitales.FIRST .. vlistcapitales.LAST LOOP
            vlistcapitales(i).cdefecto := 0;
         END LOOP;
      END IF;

      vlistcapitales.EXTEND;
      vlistcapitales(vlistcapitales.LAST) := ob_iax_prodgaranprocap();
      vlistcapitales(vlistcapitales.LAST).norden := vlistcapitales.COUNT;
      vlistcapitales(vlistcapitales.LAST).icapital := picapital;
      vlistcapitales(vlistcapitales.LAST).cdefecto := NVL(pcdefecto, 0);
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_set_obj_capital;

   /*************************************************************************
      Baja la lista de capitales a BB.DD
      param in psproduc  : codigo del producto
      param in pcgarant  : codigo de la garantia
      param in pcactivi  : codigo de la actividad
      param out          : mensajes de error
      return             : 0 todo ha sido correcto
                           1 ha habido un error

     Bug 14284 - 05/05/2010 - AMC
   *************************************************************************/
   FUNCTION f_set_capitales(
      psproduc IN NUMBER,
      pcgarant IN NUMBER,
      pcactivi IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_IAX_MNTPROD.f_set_obj_capital';
      vparam         VARCHAR2(500)
         := 'parámetros - psproduc:' || psproduc || ' pcgarant:' || pcgarant || ' pcactivi:'
            || pcactivi;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      IF psproduc IS NULL
         OR pcgarant IS NULL
         OR pcactivi IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_mntprod.f_set_capitales(psproduc, pcgarant, pcactivi, vlistcapitales,
                                                mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_set_capitales;

    /*************************************************************************
     Elimina un capital
     param in pnorden : orden del capital
     param out          : mensajes de error
     return             : 0 todo ha sido correcto
                          1 ha habido un error

    Bug 14284 - 06/05/2010 - AMC
   *************************************************************************/
   FUNCTION f_del_obj_capital(pnorden NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_IAX_MNTPROD.f_del_obj_capital';
      vparam         VARCHAR2(500) := 'parámetros - pnorden:' || pnorden;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vorden         NUMBER := 0;
   BEGIN
      IF pnorden IS NULL THEN
         RAISE e_param_error;
      END IF;

      -- Borramos
      vlistcapitales.DELETE(pnorden);

      -- Reordenamos
      IF vlistcapitales.COUNT > 0 THEN
         FOR i IN vlistcapitales.FIRST .. vlistcapitales.LAST LOOP
            vlistcapitales(i).norden := i;
         END LOOP;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_del_obj_capital;

   /*************************************************************************
      Sube o baja un posición un capital
      param in pnorden : orden del capital
      param in pmodo   : modo de ordenacion
      param out        : mensajes de error
      return           : 0 todo ha sido correcto
                         1 ha habido un error

     Bug 14284 - 06/05/2010 - AMC
    *************************************************************************/
   FUNCTION f_ordenar_obj_capital(pnorden NUMBER, pmodo VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_IAX_MNTPROD.f_ordenar_obj_capital';
      vparam         VARCHAR2(500) := 'parámetros - pnorden:' || pnorden || ' pmodo:' || pmodo;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vicapital      NUMBER;
      vcdefecto      NUMBER;
   BEGIN
      IF pnorden IS NULL
         OR pmodo IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF pmodo = 'SUBIR' THEN
         IF pnorden > 1 THEN
            vicapital := vlistcapitales(pnorden - 1).icapital;
            vcdefecto := vlistcapitales(pnorden - 1).cdefecto;
            vlistcapitales(pnorden - 1).icapital := vlistcapitales(pnorden).icapital;
            vlistcapitales(pnorden - 1).cdefecto := vlistcapitales(pnorden).cdefecto;
            vlistcapitales(pnorden).icapital := vicapital;
            vlistcapitales(pnorden).cdefecto := vcdefecto;
         END IF;
      ELSIF pmodo = 'BAJAR' THEN
         IF pnorden < vlistcapitales(vlistcapitales.LAST).norden THEN
            vicapital := vlistcapitales(pnorden + 1).icapital;
            vcdefecto := vlistcapitales(pnorden + 1).cdefecto;
            vlistcapitales(pnorden + 1).icapital := vlistcapitales(pnorden).icapital;
            vlistcapitales(pnorden + 1).cdefecto := vlistcapitales(pnorden).cdefecto;
            vlistcapitales(pnorden).icapital := vicapital;
            vlistcapitales(pnorden).cdefecto := vcdefecto;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_ordenar_obj_capital;

   /*************************************************************************
         Función que actualiza los datos generales de la garantia
         param in psproduc  : codigo del producto
         param in pcgarant  : codigo de la garantia
         param in pcactivi  : codigo de la actividad
         param in pnorden   : numero de orden
         param in pctipgar  : codigo tipo de garantia
         param in pctipcap  : codigo tipo de capital
         param in pcgardep  : codigo garantia dependiente
         param in pcpardep  : codigo parametro dependiente
         param in pcvalpar  : valor parametro dependiente
         param in pctarjet
         param in pcbasica
         param in picapmax  : importe capital maximo
         param in pccapmax  : codigo capital maximo
         param in pcformul  : codigo de formula
         param in pcclacap  :
         param in picaprev  : capital de revision
         param in ppcapdep  :
         param in piprimin  : prima minima
         param in piprimax  : capital maximo
         param in picapmin  : capital minimo
         param in out mensajes : mensajes de error
         RETURN number

         Bug 14284   07/05/2010  AMC
   **********************************************************************/
   FUNCTION f_set_datosgen(
      psproduc IN NUMBER,
      pcgarant IN NUMBER,
      pcactivi IN NUMBER,
      pnorden IN NUMBER,
      pctipgar IN NUMBER,
      pctipcap IN NUMBER,
      pcgardep IN NUMBER,
      pcpardep IN VARCHAR2,
      pcvalpar IN NUMBER,
      pctarjet IN NUMBER,
      pcbasica IN NUMBER,
      picapmax IN NUMBER,
      pccapmax IN NUMBER,
      pcformul IN NUMBER,
      pcclacap IN NUMBER,
      picaprev IN NUMBER,
      ppcapdep IN NUMBER,
      piprimin IN NUMBER,
      piprimax IN NUMBER,
      pccapmin IN NUMBER,
      picapmin IN NUMBER,
      pcclamin IN NUMBER,
      pcmoncap IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(100) := 'PAC_MD_MNTPROD.f_set_datosgen';
      vparam         VARCHAR2(1000)
         := 'psproduc:' || psproduc || ' pcgarant:' || pcgarant || ' pcactivi:' || pcactivi
            || ' pnorden:' || pnorden || ' pctipgar:' || pctipgar || ' pctipcap:' || pctipcap
            || ' pcgardep:' || pcgardep || ' pcpardep:' || pcpardep || ' pcvalpar:'
            || pcvalpar || ' pctarjet:' || pctarjet || ' pcbasica:' || pcbasica
            || ' picapmax:' || picapmax || ' pccapmax:' || pccapmax || ' pcformul:'
            || pcformul || ' pcclacap:' || pcclacap || ' picaprev:' || picaprev
            || ' ppcapdep:' || ppcapdep || ' piprimin:' || piprimin || ' piprimax:'
            || piprimax || ' pccapmin:' || pccapmin || ' picapmin:' || picapmin
            || ' pcclamin:' || pcclamin || ' pcmoncap:' || pcmoncap;
      vpasexec       NUMBER := 1;
      verror         NUMBER;
   BEGIN
      IF psproduc IS NULL
         OR pcgarant IS NULL
         OR pcactivi IS NULL THEN
         RAISE e_param_error;
      END IF;

      verror := pac_md_mntprod.f_set_datosgen(psproduc, pcgarant, pcactivi, pnorden, pctipgar,
                                              pctipcap, pcgardep, pcpardep, pcvalpar, pctarjet,
                                              pcbasica, picapmax, pccapmax, pcformul, pcclacap,
                                              picaprev, ppcapdep, piprimin, piprimax, pccapmin,
                                              picapmin, pcclamin, pcmoncap, mensajes);

      IF verror <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, verror);
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_set_datosgen;

   /**********************************************************************
          Función que borrar una garantia asignada a un producto
          param in psproduc  : codigo del producto
          param in pcgarant  : codigo de la garantia
          param in pcactivi  : código de la actividad
          param in mensajes  : mensajes de error
          RETURN number

          Bug 14723 - 25/05/2010 - AMC
    **********************************************************************/
   FUNCTION f_del_garantia(
      psproduc IN NUMBER,
      pcgarant IN NUMBER,
      pcactivi IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(100) := 'PAC_IAX_MNTPROD.f_del_garantia';
      vparam         VARCHAR2(1000)
            := 'psproduc:' || psproduc || ' pcgarant:' || pcgarant || ' pcactivi:' || pcactivi;
      vpasexec       NUMBER := 1;
      verror         NUMBER;
   BEGIN
      IF psproduc IS NULL
         OR pcgarant IS NULL THEN
         RAISE e_param_error;
      END IF;

      verror := pac_md_mntprod.f_del_garantia(psproduc, pcgarant, pcactivi, mensajes);

      IF verror <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_del_garantia;

      /*************************************************************************
         Función que actualiza los datos generales de la garantia
         param in psproduc  : codigo del producto
         param in pcgarant  : codigo de la garantia
         param in pcactivi  : codigo de la actividad
         param in pciedmic  : Ind. si se valida la 0-edad actuarial 1-edad real. Edad Min. Ctnr.
         param in pnedamic  : Edad mínima de contratación
         param in pciedmac  : Ind. si se valida la 0-edad actuarial 1-edad real. Edad Max. Ctnr.
         param in pnedamac, : Edad máxima de contratación
         param in pciedmar  : Ind. si se valida la 0-edad actuarial 1-edad real. Edad Max. Renov.
         param in pnedamar  : Edad máxima de renovación
         param in pciemi2c  : Ind. si se valida la 0-edad actuarial 1-edad real. Cuando se informa Edad Min. Ctnr. 2ºAsegurado
         param in pnedmi2c, : Edad Min. Ctnr. 2ºAsegurado
         param in pciema2c, : Ind. si se valida la 0-edad actuarial 1-edad real. Cuando se informa Edad Max. Ctnr. 2ºAsegurado
         param in pnedma2c  : Edad Max. Ctnr. 2ºAsegurado
         param in pciema2r  : Ind. si se valida la 0-edad actuarial 1-edad real. Cuando se informa Edad Max. Renov. 2ºAsegurado
         param in pnedma2r  : Edad Max. Renov. 2ºAsegurado
         param in pcreaseg
         param in pcrevali  : Tipo de revalorización
         param in pctiptar  : Tipo de tarifa (lista de valores)
         param in pcmodrev  : Se puede modificar la revalorización
         param in pcrecarg  : Se puede añadir un recargo
         param in pcdtocom  : Admite descuento comercial
         param in pctecnic
         param in pcofersn
         param in pcextrap  : Se puede modificar la extraprima
         param in pcderreg
         param in pprevali  : Porcentaje de revalorización
         param in pirevali  : Importe de revalorización
         param in pcrecfra
         param in pnedamrv : Edad máxima de revalorización
         param in pciedmrv : Ind. si se valida la 0-edad actuarial 1-edad real. Edad Max. Revalorización
         param out mensajes : mensajes de error
         RETURN number

         Bug 14748   04/06/2010  AMC
   **********************************************************************/
   FUNCTION f_set_datosges(
      psproduc IN NUMBER,
      pcgarant IN NUMBER,
      pcactivi IN NUMBER,
      pciedmic IN NUMBER,
      pnedamic IN NUMBER,
      pciedmac IN NUMBER,
      pnedamac IN NUMBER,
      pciedmar IN NUMBER,
      pnedamar IN NUMBER,
      pciemi2c IN NUMBER,
      pnedmi2c IN NUMBER,
      pciema2c IN NUMBER,
      pnedma2c IN NUMBER,
      pciema2r IN NUMBER,
      pnedma2r IN NUMBER,
      pcreaseg IN NUMBER,
      pcrevali IN NUMBER,
      pctiptar IN NUMBER,
      pcmodrev IN NUMBER,
      pcrecarg IN NUMBER,
      pcdtocom IN NUMBER,
      pctecnic IN NUMBER,
      pcofersn IN NUMBER,
      pcextrap IN NUMBER,
      pcderreg IN NUMBER,
      pprevali IN NUMBER,
      pirevali IN NUMBER,
      pcrecfra IN NUMBER,
      pctarman IN NUMBER,
      pnedamrv IN NUMBER,
      pciedmrv IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(100) := 'PAC_MNTPROD.f_set_datosges';
      vparam         VARCHAR2(1000)
         := ' psproduc:' || psproduc || ' pcgarant:' || pcgarant || ' pcactivi:' || pcactivi
            || ' ciedmic:' || pciedmic || ' nedamic:' || pnedamic || ' ciedmac:' || pciedmac
            || ' nedamac:' || pnedamac || ' ciedmar:' || pciedmar || ' nedamar:' || pnedamar
            || ' ciemi2c:' || pciemi2c || ' nedmi2c:' || pnedmi2c || ' ciema2c:' || pciema2c
            || ' nedma2c:' || pnedma2c || ' ciema2r:' || pciema2r || ' nedma2r:' || pnedma2r
            || ' creaseg:' || pcreaseg || ' crevali:' || pcrevali || ' ctiptar:' || pctiptar
            || ' cmodrev:' || pcmodrev || ' crecarg:' || pcrecarg || ' cdtocom:' || pcdtocom
            || ' ctecnic:' || pctecnic || ' cofersn:' || pcofersn || ' cextrap:' || pcextrap
            || ' cderreg:' || pcderreg || ' prevali:' || pprevali || ' irevali:' || pirevali
            || ' crecfra:' || pcrecfra || ' pctarman:' || pctarman || ' pnedamrv:' || pnedamrv
            || ' pciedmrv:' || pciedmrv;
      vpasexec       NUMBER := 1;
      verror         NUMBER;
   BEGIN
      IF psproduc IS NULL
         OR pcgarant IS NULL
         OR pcactivi IS NULL THEN
         RAISE e_param_error;
      END IF;

      verror := pac_md_mntprod.f_set_datosges(psproduc, pcgarant, pcactivi, pciedmic, pnedamic,
                                              pciedmac, pnedamac, pciedmar, pnedamar, pciemi2c,
                                              pnedmi2c, pciema2c, pnedma2c, pciema2r, pnedma2r,
                                              pcreaseg, pcrevali, pctiptar, pcmodrev, pcrecarg,
                                              pcdtocom, pctecnic, pcofersn, pcextrap, pcderreg,
                                              pprevali, pirevali, pcrecfra, pctarman, pnedamrv,
                                              pciedmrv, mensajes);

      IF verror <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_set_datosges;

   /*************************************************************************
      Recupera las garantias que peden ser incompatibles
      param in psproduc     : código del producto
      param in pcactivi     : código de la actividad
      param in pcgarant     : código de la garantia
      param out mensajes   : mensajes de error
      RETURN sys_refcursor

      -- Bug 15023 - 16/06/2010 - AMC
   *************************************************************************/
   FUNCTION f_get_lstgarincompatibles(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
            := 'psproduc=' || psproduc || ' pcactivi=' || pcactivi || ' pcgarant=' || pcgarant;
      vobject        VARCHAR2(200) := 'PAC_IAX_MNTPROD.f_get_lstgarincompatibles';
      squery         VARCHAR2(1000);
   BEGIN
      IF psproduc IS NULL
         OR pcactivi IS NULL
         OR pcgarant IS NULL THEN
         RAISE e_param_error;
      END IF;

      cur := pac_md_mntprod.f_get_lstgarincompatibles(psproduc, pcactivi, pcgarant, mensajes);
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
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstgarincompatibles;

   /*************************************************************************
         Función que inserta en incompgaran
         PARAM IN PSPRODUC     : codigo del producto
         PARAM IN PCGARANT    : codigo de la garantia
         PARAM IN PCGARANT    : codigo de la garantia incompatible
         PARAM IN PCACTIVI    : codigo de la actividad
         PARAM OUT MENSAJES   : mensajes de error

         RETURN NUMBER

         Bug 15023   16/06/2010  AMC
   **********************************************************************/
   FUNCTION f_set_incompagar(
      psproduc IN NUMBER,
      pcgarant IN NUMBER,
      pcgarinc IN NUMBER,
      pcactivi IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(100) := 'PAC_IAX_MNTPROD.f_set_incompagar';
      vparam         VARCHAR2(400)
         := 'psproduc:' || psproduc || ' pcgarant:' || pcgarant || ' pcactivi:' || pcactivi
            || ' pcgarinc:' || pcgarinc;
      vpasexec       NUMBER := 1;
      vcramo         NUMBER;
      vcmodali       NUMBER;
      vctipseg       NUMBER;
      vccolect       NUMBER;
      verror         NUMBER;
   BEGIN
      IF psproduc IS NULL
         OR pcgarant IS NULL
         OR pcgarinc IS NULL
         OR pcactivi IS NULL THEN
         RAISE e_param_error;
      END IF;

      verror := pac_md_mntprod.f_set_incompagar(psproduc, pcgarant, pcgarinc, pcactivi,
                                                mensajes);

      IF verror <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_set_incompagar;

   /*************************************************************************
         Función que borra de incompgaran
         PARAM IN PSPRODUC     : codigo del producto
         PARAM IN PCGARANT    : codigo de la garantia
         PARAM IN PCGARANT    : codigo de la garantia incompatible
         PARAM IN PCACTIVI    : codigo de la actividad
         PARAM OUT MENSAJES   : mensajes de error

         RETURN NUMBER

         Bug 15023   16/06/2010  AMC
   **********************************************************************/
   FUNCTION f_del_incompagar(
      psproduc IN NUMBER,
      pcgarant IN NUMBER,
      pcgarinc IN NUMBER,
      pcactivi IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(100) := 'PAC_IAX_MNTPROD.f_del_incompagar';
      vparam         VARCHAR2(400)
         := 'psproduc:' || psproduc || ' pcgarant:' || pcgarant || ' pcactivi:' || pcactivi
            || ' pcgarinc:' || pcgarinc;
      vpasexec       NUMBER := 1;
      vcramo         NUMBER;
      vcmodali       NUMBER;
      vctipseg       NUMBER;
      vccolect       NUMBER;
      verror         NUMBER;
   BEGIN
      IF psproduc IS NULL
         OR pcgarant IS NULL
         OR pcgarinc IS NULL
         OR pcactivi IS NULL THEN
         RAISE e_param_error;
      END IF;

      verror := pac_md_mntprod.f_del_incompagar(psproduc, pcgarant, pcgarinc, pcactivi,
                                                mensajes);

      IF verror <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_del_incompagar;

   /*************************************************************************
         Función que actualiza los datos tecnicos de la garantia
         param in psproduc  : codigo del producto
         param in pcgarant  : codigo de la garantia
         param in pcactivi  : codigo de la actividad
         param in pcramdgs  : código del ramo de la dgs
         param in pctabla   : código de la tabla de mortalidad
         param in precseg   : % recargo de seguridad
         param in nparben   : participación en beneficios
         param in cprovis   : Tipo de provision
         param out mensajes   : mensajes de error

         RETURN number

         Bug 15148 - 21/06/2010 - AMC
   **********************************************************************/
   FUNCTION f_set_datostec(
      psproduc IN NUMBER,
      pcgarant IN NUMBER,
      pcactivi IN NUMBER,
      pcramdgs IN NUMBER,
      pctabla IN NUMBER,
      pprecseg IN NUMBER,
      pnparben IN NUMBER,
      pcprovis IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(100) := 'PAC_IAX_MNTPROD.f_set_datostec';
      vparam         VARCHAR2(1000)
         := ' psproduc:' || psproduc || ' pcgarant:' || pcgarant || ' pcactivi:' || pcactivi
            || ' cramdgs:' || pcramdgs || ' ctabla:' || pctabla || ' precseg:' || pprecseg
            || ' nparben:' || pnparben || ' cprovis:' || pcprovis;
      vpasexec       NUMBER := 1;
      verror         NUMBER;
   BEGIN
      IF psproduc IS NULL
         OR pcgarant IS NULL
         OR pcactivi IS NULL THEN
         RAISE e_param_error;
      END IF;

      verror := pac_md_mntprod.f_set_datostec(psproduc, pcgarant, pcactivi, pcramdgs, pctabla,
                                              pprecseg, pnparben, pcprovis, mensajes);

      IF verror <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, verror);
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_set_datostec;

   /*************************************************************************
      Borra la formula de una garantia
      param in psproduc    : código del producto
      param in pcactivi    : código de la actividad
      param in pcgarant    : código de la garantía
      param in pccampo     : código del campo
      param in pclave      : clave fórmula
      param out mensajes   : mensajes de error
      return               : 0 si ha ido bien
                            numero error si ha ido mal

      Bug 15149 - 29/06/2010 - AMC
   *************************************************************************/
   FUNCTION f_del_prodgarformulas(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pccampo IN VARCHAR2,
      pclave IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(400)
         := 'Psproduc=' || psproduc || ' Pcactivi=' || pcactivi || ' Pcgarant=' || pcgarant
            || ' Pccampo=' || pccampo || ' Pclave=' || pclave;
      vobject        VARCHAR2(200) := 'PAC_IAX_MNTPROD.f_del_prodgarformulas';
      vpsproduc      NUMBER;
      nerror         NUMBER := 0;
   BEGIN
      --Comprovació de paràmetres
      IF psproduc IS NULL
         OR pcactivi IS NULL
         OR pcgarant IS NULL
         OR pccampo IS NULL
         OR pclave IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      nerror := pac_md_mntprod.f_del_prodgarformulas(psproduc, pcactivi, pcgarant, pccampo,
                                                     pclave, mensajes);

      IF nerror <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;   --Si tot ha anat bé -> gravació de les dades.
      RETURN nerror;
   EXCEPTION
      WHEN e_param_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_del_prodgarformulas;

   /*************************************************************************
         Inserta un nuevo producto en la tabla PRODUCTOS
         param in pcramo    : codigo del ramo
         param in pcmodali  : codigo de la modalidad
         param in pctipseg  : codigo del tipo de seguro
         param in pccolect  : codigo de colectividad
         param in pcagrpro  : codigo agrupacion de producto
         param in pttitulo  : titulo del producto
         param in ptrotulo  : abreviacion del titulo
         param in pcsubpro  : codigo de subtipo de producto
         param in pctipreb  : recibo por.
         param in pctipges  : gestion del seguro
         param in pctippag  : cobro
         param in pcduraci  : codigo de la duración
         param in pctarman  : tarificacion puede ser manual
         param in pctipefe  : tipo de efecto
         param out psproduct_out  : codigo del producto insertado
         param out mensajes  : mensajes de error

         Bug 15513 - 23/07/2010 - PFA
   *************************************************************************/
   FUNCTION f_alta_producto(
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      pcagrpro IN NUMBER,
      pttitulo IN VARCHAR2,
      ptrotulo IN VARCHAR2,
      pcsubpro IN NUMBER,
      pctipreb IN NUMBER,
      pctipges IN NUMBER,
      pctippag IN NUMBER,
      pcduraci IN NUMBER,
      pctarman IN NUMBER,
      pctipefe IN NUMBER,
      psproduc_copy IN NUMBER,
      pparproductos IN NUMBER,
      psproduc_out OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(100) := 'PAC_MD_MNTPROD.f_alta_producto';
      vparam         VARCHAR2(1000)
         := 'pcramo: ' || pcramo || ' pcmodali: ' || pcmodali || ' pctipseg: ' || pctipseg
            || ' pccolect: ' || pccolect || ' pcagrpro: ' || pcagrpro || ' pttitulo: '
            || pttitulo || ' ptrotulo: ' || ptrotulo || ' pcsubpro: ' || pcsubpro
            || ' pctipreb: ' || pctipreb || ' pctipges: ' || pctipges || ' pctippag: '
            || pctippag || ' pcduraci: ' || pcduraci || ' pctarman: ' || pctarman
            || ' pctipefe: ' || pctipefe;
      vpasexec       NUMBER := 1;
      verror         NUMBER;
      vcidioma       NUMBER;
   BEGIN
      vcidioma := pac_md_common.f_get_cxtidioma;

      IF pcramo IS NULL
         OR pcmodali IS NULL
         OR pctipseg IS NULL
         OR pccolect IS NULL
         OR pcagrpro IS NULL
         OR pttitulo IS NULL
         OR ptrotulo IS NULL
         OR pcsubpro IS NULL
         OR pctipreb IS NULL
         OR pctipges IS NULL
         OR pctippag IS NULL
         OR pcduraci IS NULL
         OR pctarman IS NULL
         OR pctipefe IS NULL THEN
         RAISE e_param_error;
      END IF;

      verror := pac_md_mntprod.f_alta_producto(pcramo, pcmodali, pctipseg, pccolect, pcagrpro,
                                               pttitulo, ptrotulo, pcsubpro, pctipreb,
                                               pctipges, pctippag, pcduraci, pctarman,
                                               pctipefe, psproduc_copy, pparproductos,
                                               psproduc_out, mensajes);

      IF verror <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN verror;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_alta_producto;

/*************************************************************************
      Recupera el objeto con la información del producto
      actividades
      param in psproduc  : código producto
      param out mensajes : mensajes de error
   *************************************************************************/
   FUNCTION f_get_activid(psproduc IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN t_iax_prodactividades IS
      mntactivid     t_iax_prodactividades := t_iax_prodactividades();
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'psproduc=' || psproduc;
      vobject        VARCHAR2(200) := 'PAC_MD_MNTPROD.F_GET_ACTIVID';
   BEGIN
      RETURN pac_md_mntprod.f_get_activid(psproduc, mensajes);
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_activid;

   /*************************************************************************
         Función que retorna els documentos d'un producte
         param in psproduc  : codigo del producto

         RETURN sys_refcursor


   **********************************************************************/
   FUNCTION f_get_documentos(psproduc IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vobjectname    VARCHAR2(100) := 'PAC_IAX_MNTPROD.f_get_documentos';
      vparam         VARCHAR2(1000) := 'pcramo: ' || psproduc;
      vpasexec       NUMBER := 1;
      verror         NUMBER;
      vcidioma       NUMBER;
      cur            sys_refcursor;
   BEGIN
      IF psproduc IS NULL THEN
         RAISE e_param_error;
      END IF;

      cur := pac_md_mntprod.f_get_documentos(psproduc, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_documentos;

   /*************************************************************************
            Función que retorna las duraciones de cobro de un producto
            param in psproduc  : codigo del producto

            RETURN t_iax_durcobroprod

            Bug 22253   17/05/2012   MDS
      **********************************************************************/
   FUNCTION f_get_durcobroprod(psproduc IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN t_iax_durcobroprod IS
      vobjectname    VARCHAR2(100) := 'PAC_IAX_MNTPROD.f_get_durcobroprod';
      vparam         VARCHAR2(1000) := 'psproduc: ' || psproduc;
      vpasexec       NUMBER := 1;
   BEGIN
      IF psproduc IS NULL THEN
         RAISE e_param_error;
      END IF;

      RETURN pac_md_mntprod.f_get_durcobroprod(psproduc, mensajes);
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_durcobroprod;

   /**************************************************************************
     Assigna un pla de pensió per un producte. Si existe, lo actualiza
     param in psproduc     : Codigo del producto
     param in pccodpla    : Codigo del plan de pensión
   **************************************************************************/
   FUNCTION f_set_planpension(
      psproduc IN NUMBER,
      pccodpla IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(1) := 1;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
                          := 'parámetros - psproduc:' || psproduc || ' pccompani=' || pccodpla;
      vobject        VARCHAR2(200) := 'PAC_IAX_MNTPROD.f_set_planpension';
      v_fich         VARCHAR2(400);
   BEGIN
      vnumerr := pac_md_mntprod.f_set_planpension(psproduc, pccodpla, mensajes);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN vnumerr;
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
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_set_planpension;

   /*************************************************************************
         Función que mantiene la tabla int_codigos_emp
         PARAM IN CCODIGO     : codigo de la interfaz
         PARAM IN CVALAXIS    : valor del campo en axis
         PARAM IN CVALEMP    : valor del campo en la empresa
         PARAM OUT MENSAJES   : mensajes de error

         RETURN NUMBER

         Bug 15023   01/11/2013  LPP
   **********************************************************************/
   FUNCTION f_get_interficie(
      pccodigo IN VARCHAR2,
      pcvalaxis IN VARCHAR2,
      pcvalemp IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_interficies IS
      vnumerr        NUMBER(1) := 1;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
         := 'parámetros - pccodigo:' || pccodigo || ' pcvalemp=' || pcvalemp || ' pcvalaxis='
            || pcvalaxis;
      vobject        VARCHAR2(200) := 'PAC_IAX_MNTPROD.f_get_interficie';
   BEGIN
      vpasexec := 1;
      RETURN pac_md_mntprod.f_get_interficie(pccodigo, pcvalaxis, pcvalemp, mensajes);
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
   END f_get_interficie;

   /*************************************************************************
         Función que mantiene la tabla int_codigos_emp
         PARAM IN CCODIGO     : codigo de la interfaz
         PARAM IN CVALAXIS    : valor del campo en axis
         PARAM IN CVALEMP    : valor del campo en la empresa
         PARAM IN CVALDEF    : valor del campo en axis, por si cvalaxis tiene mas de un valor
         PARAM IN CVALAXISDEF : valor del campo en la empresa, por si cvalaxisdef tiene mas de un valor
         PARAM OUT MENSAJES   : mensajes de error

         RETURN NUMBER

         Bug 15023   01/11/2013  LPP
   **********************************************************************/
   FUNCTION f_set_interficie(
      pccodigo IN VARCHAR2,
      pcvalaxis IN VARCHAR2,
      pcvalemp IN VARCHAR2,
      pcvaldef IN VARCHAR2,
      pcvalaxisdef IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(1) := 1;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
         := 'parámetros - pccodigo:' || pccodigo || ' pcvalemp=' || pcvalemp || ' pcvalaxis='
            || pcvalaxis || ' pcvaldef=' || pcvaldef || ' pcvalaxisdef=' || pcvalaxisdef;
      vobject        VARCHAR2(200) := 'PAC_IAX_MNTPROD.f_set_interficie';
      v_fich         VARCHAR2(400);
   BEGIN
      vnumerr := pac_md_mntprod.f_set_interficie(pccodigo, pcvalaxis, pcvalemp, pcvaldef,
                                                 pcvalaxisdef, mensajes);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN vnumerr;
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
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_set_interficie;

   /*************************************************************************
         Función que borra de la tabla int_codigos_emp
         PARAM IN CCODIGO     : codigo de la interfaz
         PARAM IN CVALAXIS    : valor del campo en axis
         PARAM OUT MENSAJES   : mensajes de error

         RETURN NUMBER

         Bug 15023   01/11/2013  LPP
   **********************************************************************/
   FUNCTION f_del_interficie(
      pccodigo IN VARCHAR2,
      pcvalaxis IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(1) := 1;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
                         := 'parámetros - pccodigo:' || pccodigo || ' pcvalaxis=' || pcvalaxis;
      vobject        VARCHAR2(200) := 'PAC_IAX_MNTPROD.f_del_interficie';
      v_fich         VARCHAR2(400);
   BEGIN
      vnumerr := pac_md_mntprod.f_del_interficie(pccodigo, pcvalaxis, mensajes);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN vnumerr;
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
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_del_interficie;
END pac_iax_mntprod;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_MNTPROD" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_MNTPROD" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_MNTPROD" TO "PROGRAMADORESCSI";
