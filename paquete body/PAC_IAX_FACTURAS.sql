--------------------------------------------------------
--  DDL for Package Body PAC_IAX_FACTURAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IAX_FACTURAS" IS
   /******************************************************************************
      NOMBRE:       PAC_IAX_FACTURAS
      PROPÓSITO:    Funciones de la capa IAX para realizar acciones sobre la tabla FACTURAS

      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.0        23/05/2012   APD             1. Creación del package. 0022321: MDP_F001-MDP_A001-Facturas
      2.0        04/09/2012   APD             2. 0023595: MDP_F001- Modificaciones modulo de facturas
   ******************************************************************************/
   e_param_error  EXCEPTION;
   e_object_error EXCEPTION;

   /***********************************************************************
      Recupera los datos de una determinada factura de tablas a objeto
      param in  pnfact  : numero de factura
      param out mensajes  : mensajes de error
      return              : OB_IAX_FACTURAS con la informacion de la factura
                            NULL -> Se ha producido un error
   ***********************************************************************/
   FUNCTION f_inicializafactura(
      pnfact IN VARCHAR2,
      pcagente IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_IAX_FACTURAS.f_inicializafactura';
      vparam         VARCHAR2(500) := 'parámetros - pnfact = ' || pnfact;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vobfact        ob_iax_facturas := ob_iax_facturas();
      vcempres       NUMBER;
   BEGIN
      vpasexec := 3;
      --RecuperaciÃ³ de les dades de la factura
      vnumerr := pac_md_facturas.f_get_factura(pnfact, pcagente, vobfact, mensajes);

      IF vnumerr != 0 THEN
         RAISE e_object_error;
      END IF;

      pac_iax_facturas.vgobfactura := ob_iax_facturas();
      pac_iax_facturas.vgobfactura := vobfact;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam,
                                           vnumerr);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_inicializafactura;

   /*************************************************************************
    Función que realiza la búsqueda de facturas a partir de los criterios de consulta entrados
    param in pcempres     : codigo empresa
    param in pcagente     : codigo de agente
    param in pnnumide     : Nif
    param in pnfact     : Nº factura
    param in pffact_ini     : fecha inicio emision factura
    param in pffact_fin     : fecha fin emision factura
    param in pcestado     : estado de la factura
    param in pctipfact     : tipo de la factura
    param in pcautorizada : autorizada
    param out ptfacturas  : colección de objetos ob_iax_facturas
    param out mensajes    : colección de objetos ob_iax_mensajes
         return             : 0 busqueda correcta
                           <> 0 busqueda incorrecta
   *************************************************************************/
   FUNCTION f_get_facturas(
      pcempres IN NUMBER,
      pcagente IN NUMBER,
      pnnumide IN VARCHAR2,
      pnfact IN VARCHAR2,
      pffact_ini IN DATE,
      pffact_fin IN DATE,
      pcestado IN NUMBER,
      pctipfact IN NUMBER,
      pcautorizada IN NUMBER,
      ptfacturas OUT t_iax_facturas,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vobjectname    VARCHAR2(500) := 'PAC_IAX_FACTURAS.f_get_facturas';
      vpasexec       NUMBER(5) := 1;
      vparam         VARCHAR2(2000)
         := 'parámetros - pcempres = ' || pcempres || '; pcagente = ' || pcagente
            || '; pnnumide = ' || pnnumide || '; pnfact = ' || pnfact || '; pffact_ini = '
            || pffact_ini || '; pffact_fin = ' || pffact_fin || '; pcestado = ' || pcestado
            || '; pctipfact = ' || pctipfact || ' aut=' || pcautorizada;
   BEGIN
      vnumerr := pac_md_facturas.f_get_facturas(pcempres, pcagente, pnnumide, pnfact,
                                                pffact_ini, pffact_fin, pcestado, pctipfact,
                                                pcautorizada, ptfacturas, mensajes);

      IF vnumerr != 0 THEN
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
   END f_get_facturas;

   /*************************************************************************
    Función que devuelve la informacion de una factura (ob_iax_facturas)
    param in pnfact     : Nº factura
    param out pofacturas  : objeto ob_iax_facturas
    param out mensajes    : colección de objetos ob_iax_mensajes
         return             : 0 busqueda correcta
                           <> 0 busqueda incorrecta
   *************************************************************************/
   FUNCTION f_get_factura(
      pnfact IN VARCHAR2,
      pofacturas OUT ob_iax_facturas,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vobjectname    VARCHAR2(500) := 'PAC_IAX_FACTURAS.f_get_factura';
      vpasexec       NUMBER(5) := 1;
      vparam         VARCHAR2(2000) := 'parámetros - pnfact = ' || pnfact;
      vnorden        NUMBER;
   BEGIN
      IF pac_iax_facturas.vgobfactura.detfactura IS NOT NULL THEN
         IF pac_iax_facturas.vgobfactura.detfactura.COUNT = 0 THEN
            vnumerr := f_insert_obj_detfactura(pnfact, vnorden, mensajes);
         END IF;
      END IF;

      pofacturas := pac_iax_facturas.vgobfactura;
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
   END f_get_factura;

   --Ini Bug.: 19152
   /*************************************************************************
      Funcion que inicializa el objeto de OB_IAX_DETFACTURA
      param in pnfact  : numero de factura
      param out mensajes : mensajes de error
      return             : number
   *************************************************************************/
   FUNCTION f_insert_obj_detfactura(
      pnfact IN VARCHAR2,
      pnorden OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1000) := 'pnfact : ' || pnfact;
      vobject        VARCHAR2(200) := 'PAC_IAX_FACTURAS.f_insert_obj_detfactura';
      num_err        NUMBER := 0;
      vobfact        ob_iax_facturas;
      v_norden       NUMBER := 0;
   BEGIN
      IF pnfact IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      vobfact := pac_iax_facturas.vgobfactura;

      IF vobfact IS NULL THEN
         RETURN NULL;
      END IF;

      vpasexec := 3;
      vobfact.detfactura := pac_md_facturas.f_insert_obj_detfactura(vobfact, pnorden, mensajes);
      vpasexec := 5;
      pac_iax_facturas.vgobfactura := vobfact;
      vpasexec := 6;
      RETURN num_err;
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
   END f_insert_obj_detfactura;

   /*************************************************************************
      Funcion que para actualizar el objeto OB_IAX_DETFACTURA
      param in pnfact  : numero de factura
      param in pnorden  : orden dentro del objeto
      param in pcconcepto :
      param in piimporte :
      param out piirpf:
      param out piimpcta :
      param out piimpneto : se calculta (piimporte - piirpf)
      param out piimpneto_total : se calculta (suma de los importes netos de todos los conceptos)
      param out mensajes : mensajes de error
      return             : number
   *************************************************************************/
   FUNCTION f_set_obj_detfactura(
      pnfact IN VARCHAR2,
      pnorden IN NUMBER,
      pcconcepto IN NUMBER,
      piimporte IN NUMBER,
      piirpf OUT NUMBER,   -- Bug 23595 - APD - 04/09/2012 - irpf campo calculado
      piimpcta OUT NUMBER,   -- Bug 23595 - APD - 04/09/2012 - ingreso a cuenta campo calculado
      piimpneto OUT NUMBER,
      piimpneto_total OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1000)
         := 'pnfact : ' || pnfact || ' pnorden : ' || pnorden || ' pcconcepto : '
            || pcconcepto || ' piimporte : ' || piimporte;
      vobject        VARCHAR2(200) := 'PAC_IAX_FACTURAS.f_set_obj_detfactura';
      num_err        NUMBER := 0;
      vobfact        ob_iax_facturas;
   BEGIN
      IF pnfact IS NULL
         OR pnorden IS NULL
         OR pcconcepto IS NULL
         OR piimporte IS NULL THEN
         --OR piirpf IS NULL -- Bug 23595 - APD - 04/09/2012 - irpf campo calculado
         --OR piimpcta IS NULL THEN -- Bug 23595 - APD - 04/09/2012 - ingreso a cuenta campo calculado
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      vobfact := pac_iax_facturas.vgobfactura;

      IF vobfact IS NULL THEN
         RETURN NULL;
      END IF;

      vpasexec := 3;

      --Recuperamos el ob_iax_detfactura deaseado
      IF vobfact.detfactura IS NOT NULL THEN
         vpasexec := 4;
         vobfact.detfactura := pac_md_facturas.f_set_obj_detfactura(vobfact, pnfact, pnorden,
                                                                    pcconcepto, piimporte,
                                                                    piirpf, piimpcta,
                                                                    piimpneto,
                                                                    piimpneto_total, mensajes);
      END IF;

      vpasexec := 5;
      vobfact.iimpneto_total := piimpneto_total;
      vpasexec := 6;
      pac_iax_facturas.vgobfactura := vobfact;
      RETURN num_err;
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
   END f_set_obj_detfactura;

   /*************************************************************************
      Funcion que elimina un objeto de la coleccion
      param in pnriesgo  : numero de riesgo
      param in pnorden  :
      param out mensajes : mensajes de error
      return             : number
   *************************************************************************/
   FUNCTION f_del_obj_detfactura(
      pnfact IN VARCHAR2,
      pnorden IN NUMBER,
      piimpneto_total OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1000) := 'pnfact : ' || pnfact || ' pnorden : ' || pnorden;
      vobject        VARCHAR2(200) := 'PAC_IAX_FACTURAS.f_del_obj_detfactura';
      num_err        NUMBER := 0;
      vobfact        ob_iax_facturas;
      viimpneto_total NUMBER := 0;
   BEGIN
      IF pnfact IS NULL
         OR pnorden IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      vobfact := pac_iax_facturas.vgobfactura;
      viimpneto_total := vobfact.iimpneto_total;

      IF vobfact IS NULL THEN
         RETURN NULL;
      END IF;

      vpasexec := 3;

      -- Si la factura no está en estado Pendiente, no se debe permitir eliminar un concepto
      IF vobfact.cestado <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9903718);   -- No se puede eliminar el concepto.
         RETURN 1;
      END IF;

      --Recuperamos el ob_iax_detfactura deseado
      IF vobfact.detfactura IS NOT NULL THEN
         vpasexec := 4;

         IF vobfact.detfactura.COUNT > 0 THEN
            FOR i IN vobfact.detfactura.FIRST .. vobfact.detfactura.LAST LOOP
               vpasexec := 5;

               IF vobfact.detfactura.EXISTS(i) THEN
                  vpasexec := 6;

                  IF vobfact.detfactura(i).norden = pnorden THEN
                     viimpneto_total := viimpneto_total - vobfact.detfactura(i).iimpneto;
                     vobfact.detfactura.DELETE(i);
                  /*ELSE
                     viimpneto_total := viimpneto_total + vobfact.detfactura(i).iimpneto;*/
                  END IF;
               END IF;
            END LOOP;

            vpasexec := 7;
         END IF;
      END IF;

      vpasexec := 8;
      vobfact.iimpneto_total := viimpneto_total;
      piimpneto_total := viimpneto_total;
      vpasexec := 9;
      pac_iax_facturas.vgobfactura := vobfact;
      RETURN num_err;
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
   END f_del_obj_detfactura;

   /*************************************************************************
    Función que graba en BBDD la coleccion T_IAX_DETFACTURA
    param in pnfact     : Nº factura
    param out mensajes    : colección de objetos ob_iax_mensajes
         return             : 0 Todo Ok
                           <> 0 num_err
   *************************************************************************/
   FUNCTION f_set_detfactura(pnfact IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vobjectname    VARCHAR2(500) := 'PAC_IAX_FACTURAS.f_set_detfactura';
      vpasexec       NUMBER(5) := 1;
      vparam         VARCHAR2(2000) := 'parámetros - pnfact = ' || pnfact;
      vobfact        ob_iax_facturas;
   BEGIN
      IF pnfact IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      vobfact := pac_iax_facturas.vgobfactura;

      IF vobfact IS NULL THEN
         RETURN NULL;
      END IF;

      vpasexec := 3;
      vnumerr := pac_md_facturas.f_set_detfactura(vobfact, pnfact, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      vpasexec := 5;
      pac_iax_facturas.vgobfactura := vobfact;
      vpasexec := 6;
      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_set_detfactura;

   /*************************************************************************
    Función que graba en BBDD una factura
    param in pcempres     : codigo empresa
    param in pcagente     : codigo de agente
    param in pnnumide     : Nif
    param in pffact     : fecha emision factura
    param in pcestado     : estado de la factura
    param in pctipfact     : tipo de la factura
    param in pctipiva     : tipo de iva la factura
    param out pnfact     : Nº factura
    param out mensajes    : colección de objetos ob_iax_mensajes
         return             : 0 busqueda correcta
                           <> 0 busqueda incorrecta
   *************************************************************************/
   FUNCTION f_set_factura(
      pcempres IN NUMBER,
      pcagente IN NUMBER,
      pffact IN DATE,
      pcestado IN NUMBER,
      pctipfact IN NUMBER,
      pctipiva IN NUMBER,
      pnfact IN VARCHAR2,
      onfact OUT VARCHAR2,
      mensajes OUT t_iax_mensajes,
      pctipdoc IN NUMBER DEFAULT NULL,
      piddocgedox IN NUMBER DEFAULT NULL,
      pnliqmen IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vobjectname    VARCHAR2(500) := 'PAC_IAX_FACTURAS.f_set_factura';
      vpasexec       NUMBER(5) := 1;
      vparam         VARCHAR2(2000)
         := 'parámetros - pcempres = ' || pcempres || '; pcagente = ' || pcagente
            || '; pffact = ' || TO_CHAR(pffact, 'DD/MM/YYYY') || '; pcestado = ' || pcestado
            || '; pctipfact = ' || pctipfact || '; pctipiva = ' || pctipiva || '; pnfact = '
            || pnfact;
   BEGIN
      vpasexec := 2;
      vnumerr := pac_md_facturas.f_set_factura(pcempres, pcagente, pffact, pcestado,
                                               pctipfact, pctipiva, pnfact, onfact, mensajes,
                                               pctipdoc, piddocgedox, pnliqmen);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      vpasexec := 3;
      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_set_factura;

   /*************************************************************************
    Función que emite una factura
    param in pcempres   : Codigo empresa
    param in pnfact     : Nº factura
    param out mensajes    : colección de objetos ob_iax_mensajes
         return             : 0 Todo Ok
                           <> 0 num_err
   *************************************************************************/
   FUNCTION f_emitir_factura(
      pcempres IN NUMBER,
      pnfact IN VARCHAR2,
      pcagente IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vobjectname    VARCHAR2(500) := 'PAC_IAX_FACTURAS.f_emitir_factura';
      vpasexec       NUMBER(5) := 1;
      vparam         VARCHAR2(2000)
                         := 'parámetros - pcempres = ' || pcempres || ' - pnfact = ' || pnfact;
   BEGIN
      vpasexec := 2;
      -- si se está dando de alta o modificando un detalle de factura al pulsar emitir
      -- se debe grabar
      vnumerr := pac_iax_facturas.f_set_detfactura(pnfact, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      vpasexec := 3;
      vnumerr := pac_md_facturas.f_emitir_factura(pcempres, pnfact, pcagente, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      vpasexec := 4;
      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_emitir_factura;

   /*************************************************************************
    Función que anula una factura
    param in pcempres   : Codigo empresa
    param in pnfact     : Nº factura
    param out mensajes    : colección de objetos ob_iax_mensajes
         return             : 0 Todo Ok
                           <> 0 num_err
   *************************************************************************/
   FUNCTION f_anular_factura(
      pcempres IN NUMBER,
      pnfact IN VARCHAR2,
      pcagente IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vobjectname    VARCHAR2(500) := 'PAC_IAX_FACTURAS.f_anular_factura';
      vpasexec       NUMBER(5) := 1;
      vparam         VARCHAR2(2000)
                         := 'parámetros - pcempres = ' || pcempres || ' - pnfact = ' || pnfact;
   BEGIN
      vpasexec := 2;
      -- si se está dando de alta o modificando un detalle de factura al pulsar emitir
      -- se debe grabar
      vnumerr := pac_iax_facturas.f_set_detfactura(pnfact, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      vpasexec := 3;
      vnumerr := pac_md_facturas.f_anular_factura(pcempres, pnfact, pcagente, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      vpasexec := 4;
      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_anular_factura;

   /*************************************************************************
    Función que selecciona datos factura a partir de una carpeta
    param in pCCARPETA   : Codigo carpeta
    param out pobfacturacarpeta    : colección de ob_iax_facturacarpeta
    param out mensajes    : colección de objetos ob_iax_mensajes
         return             : 0 Todo Ok
                           <> 0 num_err
   -- bug 0028554 - 06/02/2014 - JMF
   *************************************************************************/
   FUNCTION f_sel_carpeta(
      pccarpeta IN VARCHAR2,
      pobfacturacarpeta OUT ob_iax_facturacarpeta,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      cur            sys_refcursor;
      vsquery        VARCHAR2(5000);
      vobjectname    VARCHAR2(500) := 'PAC_IAX_FACTURAS.f_sel_carpeta';
      vparam         VARCHAR2(1000) := 'pCCARPETA: ' || pccarpeta;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vquery         VARCHAR2(3000);
   BEGIN
      vnumerr := pac_md_facturas.f_sel_carpeta(pccarpeta, pobfacturacarpeta, mensajes);

      IF vnumerr != 0 THEN
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
   END f_sel_carpeta;

   /*************************************************************************
    Función que asigna numero de folio a partir de un numero interno de factura, tambien trata folios erroneos
    param in pobfacturacarpeta   : Objeto con toda la informacion
    param out mensajes    : colección de objetos ob_iax_mensajes
         return             : 0 Todo Ok
                           <> 0 num_err
   -- bug 0028554 - 06/02/2014 - JMF
   *************************************************************************/
   FUNCTION f_asigna_carpeta(
      pobfacturacarpeta IN ob_iax_asigfactura,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_IAX_FACTURAS.f_asigna_carpeta';
      vparam         VARCHAR2(1000) := NULL;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_md_facturas.f_asigna_carpeta(pobfacturacarpeta, mensajes);

      IF vnumerr != 0 THEN
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
   END f_asigna_carpeta;

   /*************************************************************************
    Función que genera impresos de una carpeta
    param in pCCARPETA   : Codigo carpeta
    param out mensajes    : colección de objetos ob_iax_mensajes
         return             : 0 Todo Ok
                           <> 0 num_err
   -- bug 0028554 - 06/02/2014 - JMF
   *************************************************************************/
   FUNCTION f_genera_carpeta(pccarpeta IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      cur            sys_refcursor;
      vsquery        VARCHAR2(5000);
      vobjectname    VARCHAR2(500) := 'PAC_IAX_FACTURAS.f_genera_carpeta';
      vparam         VARCHAR2(1000) := 'pCCARPETA: ' || pccarpeta;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_md_facturas.f_genera_carpeta(pccarpeta, mensajes);

      IF vnumerr != 0 THEN
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
   END f_genera_carpeta;

   /*************************************************************************
      Recupera las causas de anulacion
      param in pcmotmov  : código de causa
      param out mensajes : mesajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_listnliqmen(pcagente IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100) := 'pcagente: ' || pcagente;
      vobject        VARCHAR2(200) := 'PAC_IAX_FACTURAS.f_get_listnliqmen';
   BEGIN
      cur := pac_md_facturas.f_get_listnliqmen(pcagente, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_listnliqmen;

   /*************************************************************************
    Función que anula una factura
    param in pcempres   : Codigo empresa
    param in pnfact     : Nº factura
    param out mensajes    : colección de objetos ob_iax_mensajes
         return             : 0 Todo Ok
                           <> 0 num_err
   *************************************************************************/
   FUNCTION f_autoriza_factura(
      pcempres IN NUMBER,
      pnfact IN VARCHAR2,
      pcagente IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vobjectname    VARCHAR2(500) := 'PAC_IAX_FACTURAS.f_autoriza_factura';
      vpasexec       NUMBER(5) := 1;
      vparam         VARCHAR2(2000)
                         := 'parámetros - pcempres = ' || pcempres || ' - pnfact = ' || pnfact;
   BEGIN
      vpasexec := 2;
      vnumerr := pac_md_facturas.f_autoriza_factura(pcempres, pnfact, pcagente, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      vpasexec := 4;
      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_autoriza_factura;
END pac_iax_facturas;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_FACTURAS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_FACTURAS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_FACTURAS" TO "PROGRAMADORESCSI";
