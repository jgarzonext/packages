--------------------------------------------------------
--  DDL for Package Body PAC_MD_FACTURAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MD_FACTURAS" IS
   /******************************************************************************
      NOMBRE:       PAC_MD_FACTURAS
      PROPÓSITO:    Funciones de la capa MD para realizar acciones sobre la tabla FACTURAS

      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.0        23/05/2012   APD             1. Creación del package. 0022321: MDP_F001-MDP_A001-Facturas
      2.0        04/09/2012   APD             2. 0023595: MDP_F001- Modificaciones modulo de facturas
   ******************************************************************************/
   e_param_error  EXCEPTION;
   e_object_error EXCEPTION;

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
    param in out ptfacturas  : colección de objetos ob_iax_facturas
    param out mensajes    : colección de objetos ob_iax_mensajes
         return             : 0 busqueda correcta
                           <> 0 busqueda incorrecta   *************************************************************************/
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
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      pobfacturas    ob_iax_facturas;
      vnumerr        NUMBER;
      vquery         VARCHAR2(3000);
      cur            sys_refcursor;
      vobjectname    VARCHAR2(500) := 'PAC_MD_FACTURAS.f_get_facturas';
      vpasexec       NUMBER(5) := 1;
      vparam         VARCHAR2(2000)
         := 'parámetros - pcempres = ' || pcempres || '; pcagente = ' || pcagente
            || '; pnnumide = ' || pnnumide || '; pnfact = ' || pnfact || '; pffact_ini = '
            || pffact_ini || '; pffact_fin = ' || pffact_fin || '; pcestado = ' || pcestado
            || '; pctipfact = ' || pctipfact || ' aut=' || pcautorizada;
   BEGIN
      vnumerr := pac_facturas.f_get_facturas(pcempres, pcagente, pnnumide, pnfact, pffact_ini,
                                             pffact_fin, pcestado, pctipfact,
                                             pac_md_common.f_get_cxtidioma(), pcautorizada,
                                             vquery);

      IF vnumerr != 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      pobfacturas := ob_iax_facturas();
      ptfacturas := t_iax_facturas();
      cur := pac_iax_listvalores.f_opencursor(vquery, mensajes);

      LOOP
         FETCH cur
          INTO pobfacturas.nfact, pobfacturas.cempres, pobfacturas.ffact,
               pobfacturas.ctipfact, pobfacturas.ttipfact, pobfacturas.ctipiva,
               pobfacturas.ttipiva, pobfacturas.cestado, pobfacturas.testado,
               pobfacturas.cagente, pobfacturas.tnombre, pobfacturas.sperson,
               pobfacturas.nnumide, pobfacturas.iimporte_total, pobfacturas.iirpf_total,
               pobfacturas.iimpneto_total, pobfacturas.iimpcta_total, pobfacturas.ctipdoc,
               pobfacturas.nfolio, pobfacturas.ccarpeta, pobfacturas.iddocgedox,
               pobfacturas.ttipdoc, pobfacturas.nliqmen, pobfacturas.cautorizada,
               pobfacturas.tautorizada;

         EXIT WHEN cur%NOTFOUND;
         ptfacturas.EXTEND;
         ptfacturas(ptfacturas.LAST) := pobfacturas;
         pobfacturas := ob_iax_facturas();
      END LOOP;

      CLOSE cur;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN 1;
   END f_get_facturas;

   /*************************************************************************
    Función que devuelve la informacion de una factura (ob_iax_facturas)
    param in pnfact     : Nº factura
    param out pofacturas  : objeto ob_iax_facturas
    param in out mensajes    : colección de objetos ob_iax_mensajes
         return             : 0 busqueda correcta
                           <> 0 busqueda incorrecta
   *************************************************************************/
   FUNCTION f_get_factura(
      pnfact IN VARCHAR2,
      pcagente IN NUMBER,
      pofacturas IN OUT ob_iax_facturas,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vtdetfactura   t_iax_detfactura;
      vobdetfactura  ob_iax_detfactura;
      vnumerr        NUMBER;
      vquery         VARCHAR2(3000);
      cur            sys_refcursor;
      vobjectname    VARCHAR2(500) := 'PAC_MD_FACTURAS.f_get_factura';
      vpasexec       NUMBER(5) := 1;
      vparam         VARCHAR2(2000) := 'parámetros - pnfact = ' || pnfact;
   BEGIN
      IF pnfact IS NOT NULL THEN
         vpasexec := 2;
         vnumerr := pac_facturas.f_get_factura(pnfact, pcagente,
                                               pac_md_common.f_get_cxtidioma(), vquery);

         IF vnumerr != 0 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
            RAISE e_object_error;
         END IF;

         vpasexec := 3;
         cur := pac_iax_listvalores.f_opencursor(vquery, mensajes);

         LOOP
            vpasexec := 4;

            IF pofacturas IS NULL THEN
               pofacturas := ob_iax_facturas();
            END IF;

            vpasexec := 5;

            FETCH cur
             INTO pofacturas.nfact, pofacturas.cempres, pofacturas.ffact, pofacturas.ctipfact,
                  pofacturas.ttipfact, pofacturas.ctipiva, pofacturas.ttipiva,
                  pofacturas.cestado, pofacturas.testado, pofacturas.cagente,
                  pofacturas.tnombre, pofacturas.sperson, pofacturas.nnumide,
                  pofacturas.iimporte_total, pofacturas.iirpf_total, pofacturas.iimpneto_total,
                  pofacturas.iimpcta_total, pofacturas.ctipdoc, pofacturas.nfolio,
                  pofacturas.ccarpeta, pofacturas.iddocgedox, pofacturas.ttipdoc,
                  pofacturas.nliqmen, pofacturas.cautorizada, pofacturas.tautorizada;

            vpasexec := 6;
            EXIT WHEN cur%NOTFOUND;
            vnumerr := pac_md_facturas.f_get_detfactura(pnfact, pcagente, vtdetfactura,
                                                        mensajes);

            IF vnumerr != 0 THEN
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
               RAISE e_object_error;
            END IF;

            vpasexec := 8;
            pofacturas.detfactura := vtdetfactura;
         END LOOP;

         CLOSE cur;
      ELSE
         vpasexec := 9;

         IF pofacturas IS NULL THEN
            pofacturas := ob_iax_facturas();
            pofacturas.detfactura := t_iax_detfactura();
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN 1;
   END f_get_factura;

   /*************************************************************************
    Función que devuelve la informacion de una factura (ob_iax_facturas)
    param in pnfact     : Nº factura
    param out pofacturas  : objeto ob_iax_facturas
    param in out mensajes    : colección de objetos ob_iax_mensajes
         return             : 0 busqueda correcta
                           <> 0 busqueda incorrecta
   *************************************************************************/
   FUNCTION f_get_detfactura(
      pnfact IN VARCHAR2,
      pcagente IN NUMBER,
      ptdetfactura OUT t_iax_detfactura,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobdetfactura  ob_iax_detfactura;
      vnumerr        NUMBER;
      vquery         VARCHAR2(3000);
      cur            sys_refcursor;
      vobjectname    VARCHAR2(500) := 'PAC_MD_FACTURAS.f_get_detfactura';
      vpasexec       NUMBER(5) := 1;
      vparam         VARCHAR2(2000) := 'parámetros - pnfact = ' || pnfact;
   BEGIN
      vnumerr := pac_facturas.f_get_detfactura(pnfact, pcagente,
                                               pac_md_common.f_get_cxtidioma(), vquery);

      IF vnumerr != 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      cur := pac_iax_listvalores.f_opencursor(vquery, mensajes);
      ptdetfactura := t_iax_detfactura();

      LOOP
         vobdetfactura := ob_iax_detfactura();

         FETCH cur
          INTO vobdetfactura.norden, vobdetfactura.cconcepto, vobdetfactura.tconcepto,
               vobdetfactura.iimporte, vobdetfactura.iirpf, vobdetfactura.iimpneto,
               vobdetfactura.iimpcta;

         EXIT WHEN cur%NOTFOUND;
         ptdetfactura.EXTEND;
         ptdetfactura(ptdetfactura.LAST) := vobdetfactura;
      END LOOP;

      CLOSE cur;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN 1;
   END f_get_detfactura;

   /*************************************************************************
      Funcion que inicializa el objeto de OB_IAX_DETFACTURA
      param in pobfact  : objeto OB_IAX_FACTURAS
      param out mensajes : mensajes de error
      return             : number
   *************************************************************************/
   FUNCTION f_insert_obj_detfactura(
      pobfact IN ob_iax_facturas,
      pnorden IN OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_detfactura IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1000);
      vobject        VARCHAR2(200) := 'PAC_MD_FACTURAS.f_insert_obj_detfactura';
      num_err        NUMBER := 0;
      v_norden       NUMBER := 0;
      vobfact        ob_iax_facturas;
   BEGIN
      vobfact := pobfact;
      vpasexec := 2;

      IF vobfact.detfactura IS NULL THEN
         vobfact.detfactura := t_iax_detfactura();
      END IF;

      vpasexec := 3;
      vobfact.detfactura.EXTEND;
      vobfact.detfactura(vobfact.detfactura.LAST) := ob_iax_detfactura();
      vpasexec := 4;

      FOR i IN vobfact.detfactura.FIRST .. vobfact.detfactura.LAST LOOP
         IF vobfact.detfactura.EXISTS(i) THEN
            IF v_norden < vobfact.detfactura(i).norden THEN
               v_norden := vobfact.detfactura(i).norden;
            END IF;
         END IF;
      END LOOP;

      IF v_norden = 0 THEN
         v_norden := 1;
      ELSE
         v_norden := v_norden + 1;
      END IF;

      vpasexec := 5;
      vobfact.detfactura(vobfact.detfactura.LAST).norden := v_norden;
      pnorden := v_norden;
      RETURN vobfact.detfactura;
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
   END f_insert_obj_detfactura;

   /*************************************************************************
      Funcion para actualizar el objeto OB_IAX_DETFACTURA
      param in pnfact  : numero de factura
      param in pnorden  : orden dentro del objeto
      param in pcconcepto :
      param in piimporte :
      param in out piirpf:
      param in out piimpcta :
      param out piimpneto : se calculta (piimporte - piirpf)
      param out piimpneto_total : se calculta (suma de los importes netos de todos los conceptos)
      param out mensajes : mensajes de error
      return             : number
   *************************************************************************/
   FUNCTION f_set_obj_detfactura(
      pobfact IN ob_iax_facturas,
      pnfact IN VARCHAR2,
      pnorden IN NUMBER,
      pcconcepto IN NUMBER,
      piimporte IN NUMBER,
      piirpf IN OUT NUMBER,   -- Bug 23595 - APD - 04/09/2012 - irpf campo calculado
      piimpcta IN OUT NUMBER,   -- Bug 23595 - APD - 04/09/2012 - ingreso a cuenta campo calculado
      piimpneto IN OUT NUMBER,
      piimpneto_total IN OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_detfactura IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1000)
         := 'pnfact : ' || pnfact || ' pnorden : ' || pnorden || ' pcconcepto : '
            || pcconcepto || ' piimporte : ' || piimporte;
      vobject        VARCHAR2(200) := 'PAC_MD_FACTURAS.f_set_obj_detfactura';
      num_err        NUMBER := 0;
      vobfact        ob_iax_facturas := ob_iax_facturas();
      viirpf         NUMBER := 0;
      viimpneto      NUMBER := 0;
      viimpneto_total NUMBER := 0;
      vpretenc       NUMBER;   -- Bug 23595 - APD - 04/09/2012
   BEGIN
      IF pnfact IS NULL
         OR pnorden IS NULL
         OR pcconcepto IS NULL
         OR piimporte IS NULL THEN
         --OR piirpf IS NULL -- Bug 23595 - APD - 04/09/2012 - irpf campo calculado
         --OR piimpcta IS NULL THEN -- Bug 23595 - APD - 04/09/2012 - ingreso a cuenta campo calculado
         RAISE e_param_error;
      END IF;

      vobfact := pobfact;

      --Recuperamos el ob_iax_detfactura deseado
      IF vobfact IS NOT NULL THEN
         vpasexec := 4;

         IF vobfact.detfactura.COUNT > 0 THEN
            FOR i IN vobfact.detfactura.FIRST .. vobfact.detfactura.LAST LOOP
               vpasexec := 5;

               IF vobfact.detfactura.EXISTS(i) THEN
                  vpasexec := 6;

                  IF vobfact.detfactura(i).norden = pnorden THEN
                     vobfact.detfactura(i).cconcepto := pcconcepto;
                     vobfact.detfactura(i).tconcepto :=
                        ff_desvalorfijo(1100, pac_md_common.f_get_cxtidioma,
                                        vobfact.detfactura(i).cconcepto);
                     vobfact.detfactura(i).iimporte := piimporte;
                     -- Bug 23595 - APD - 04/09/2012 - irpf campo calculado e ingreso a cuenta campo calculado
                     -- Rappels: RETRIB. DINERARIA (IRPF)
                     -- Premios: RETRIB. NO DINERARIA (ING. A CUENTA)
                     -- Viajes: RETRIB NO DINERARIA (ING. A CUENTA)
                     -- Otras retribuciones: RETRIB DINERARIA (IRPF)
                     vpretenc := pac_agentes.f_get_reteniva(vobfact.cagente, vobfact.ffact);
                     viirpf := vobfact.detfactura(i).iimporte *(NVL(vpretenc, 0) / 100);
                     vobfact.detfactura(i).iirpf := 0;
                     vobfact.detfactura(i).iimpcta := 0;

                     IF vobfact.detfactura(i).cconcepto IN(1, 4, 5) THEN
                        vobfact.detfactura(i).iirpf := viirpf;
                        piirpf := vobfact.detfactura(i).iirpf;
                        piimpcta := 0;
                        viimpneto := vobfact.detfactura(i).iimporte
                                     - vobfact.detfactura(i).iirpf;
                     ELSIF vobfact.detfactura(i).cconcepto IN(2, 3) THEN
                        vobfact.detfactura(i).iimpcta := viirpf;
                        piimpcta := vobfact.detfactura(i).iimpcta;
                        piirpf := 0;
                        viimpneto := vobfact.detfactura(i).iimporte
                                     - vobfact.detfactura(i).iimpcta;
                     END IF;

                     -- fin Bug 23595 - APD - 04/09/2012
                     vobfact.detfactura(i).iimpneto := viimpneto;
                  END IF;

                  viimpneto_total := viimpneto_total + vobfact.detfactura(i).iimpneto;
               END IF;
            END LOOP;

            vpasexec := 7;
         END IF;
      END IF;

      piimpneto := viimpneto;
      piimpneto_total := viimpneto_total;
      vpasexec := 8;
      RETURN vobfact.detfactura;
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
   END f_set_obj_detfactura;

   /*************************************************************************
    Función que graba en BBDD la coleccion T_IAX_DETFACTURA
    param in pnfact     : Nº factura
    param out mensajes    : colección de objetos ob_iax_mensajes
         return             : 0 Todo Ok
                           <> 0 num_err
   *************************************************************************/
   FUNCTION f_set_detfactura(
      pobfact IN ob_iax_facturas,
      pnfact IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vobjectname    VARCHAR2(500) := 'PAC_MD_FACTURAS.f_set_detfactura';
      vpasexec       NUMBER(5) := 1;
      vparam         VARCHAR2(2000) := 'parámetros - ';
      vobfact        ob_iax_facturas;
      vnorden        NUMBER := 0;
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

      --Recuperamos el ob_iax_detfactura deseado
      IF vobfact IS NOT NULL THEN
         vpasexec := 4;

         DELETE FROM detfactura
               WHERE nfact = vobfact.nfact
                 AND cagente = vobfact.cagente;

         IF vobfact.detfactura.COUNT > 0 THEN
            FOR i IN vobfact.detfactura.FIRST .. vobfact.detfactura.LAST LOOP
               vpasexec := 5;

               IF vobfact.detfactura.EXISTS(i) THEN
                  vpasexec := 6;
                  vnorden := vnorden + 1;

                  INSERT INTO detfactura
                              (nfact, norden, cconcepto,
                               iimporte, iirpf,
                               iimpneto, iimpcta,
                               cagente)
                       VALUES (vobfact.nfact, vnorden, vobfact.detfactura(i).cconcepto,
                               vobfact.detfactura(i).iimporte, vobfact.detfactura(i).iirpf,
                               vobfact.detfactura(i).iimpneto, vobfact.detfactura(i).iimpcta,
                               vobfact.cagente);
               END IF;
            END LOOP;

            vpasexec := 7;
         END IF;
      END IF;

      vpasexec := 5;
      RETURN vnumerr;
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
      mensajes IN OUT t_iax_mensajes,
      pctipdoc IN NUMBER DEFAULT NULL,
      piddocgedox IN NUMBER DEFAULT NULL,
      pnliqmen IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vobjectname    VARCHAR2(500) := 'PAC_MD_FACTURAS.f_set_factura';
      vpasexec       NUMBER(5) := 1;
      vparam         VARCHAR2(2000)
         := 'parámetros - pcempres = ' || pcempres || '; pcagente = ' || pcagente
            || '; pffact = ' || TO_CHAR(pffact, 'DD/MM/YYYY') || '; pcestado = ' || pcestado
            || '; pctipfact = ' || pctipfact || '; pctipiva = ' || pctipiva || '; pnfact = '
            || pnfact || ' t=' || pctipdoc || ' i=' || piddocgedox;
      v_text         VARCHAR(4000);
   BEGIN
      vpasexec := 2;
      vnumerr := pac_facturas.f_set_factura(pcempres, pcagente, pffact, pcestado, pctipfact,
                                            pctipiva, pnfact, onfact, pctipdoc, piddocgedox,
                                            pnliqmen);

      IF vnumerr <> 0 THEN
         v_text := f_axis_literales(vnumerr, pac_md_common.f_get_cxtidioma());
         v_text := v_text || ': ' || pnfact;
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, NULL, v_text);
         RAISE e_object_error;
      END IF;

      vpasexec := 3;
      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 9903729);   -- Factura creada correctamente.
      vpasexec := 6;
      RETURN vnumerr;
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
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vobjectname    VARCHAR2(500) := 'PAC_MD_FACTURAS.f_emitir_factura';
      vpasexec       NUMBER(5) := 1;
      vparam         VARCHAR2(2000)
                         := 'parámetros - pcempres = ' || pcempres || ' - pnfact = ' || pnfact;
   BEGIN
      vpasexec := 2;
      vnumerr := pac_facturas.f_emitir_factura(pcempres, pnfact, pcagente);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 9903728);   --Factura emitida correctamente.
      vpasexec := 3;
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
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vobjectname    VARCHAR2(500) := 'PAC_MD_FACTURAS.f_anular_factura';
      vpasexec       NUMBER(5) := 1;
      vparam         VARCHAR2(2000)
                         := 'parámetros - pcempres = ' || pcempres || ' - pnfact = ' || pnfact;
   BEGIN
      vpasexec := 2;
      vnumerr := pac_facturas.f_anular_factura(pcempres, pnfact, pcagente);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 9903730);   -- Factura anulada correctamente.
      vpasexec := 3;
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
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      --
      cur            sys_refcursor;
      vsquery        CLOB;
      vobjectname    VARCHAR2(500) := 'PAC_MD_FACTURAS.f_sel_carpeta';
      vparam         VARCHAR2(1000) := 'pCCARPETA: ' || pccarpeta;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vquery         CLOB;
   BEGIN
      vnumerr := pac_facturas.f_query_factura_carpeta(pccarpeta,
                                                      pac_md_common.f_get_cxtempresa,
                                                      pac_md_common.f_get_cxtidioma, vquery);

      IF vnumerr != 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      vpasexec := 4;
      pobfacturacarpeta := ob_iax_facturacarpeta();

      IF pccarpeta IS NOT NULL THEN
         cur := pac_iax_listvalores.f_opencursor(vquery, mensajes);

         LOOP
            FETCH cur
             INTO pobfacturacarpeta.destipdoc, pobfacturacarpeta.ninicio,
                  pobfacturacarpeta.nfinal, pobfacturacarpeta.total,
                  pobfacturacarpeta.asignadas;

            EXIT WHEN cur%NOTFOUND;
         END LOOP;

         CLOSE cur;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

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
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      --
      vobjectname    VARCHAR2(500) := 'PAC_MD_FACTURAS.f_asigna_carpeta';
      vparam         VARCHAR2(1000) := NULL;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_facturas.f_asigna_carpeta(pac_md_common.f_get_cxtempresa,
                                               pobfacturacarpeta);

      IF vnumerr != 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
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
   END f_asigna_carpeta;

   /*************************************************************************
    Función que genera impresos de una carpeta
    param in pCCARPETA   : Codigo carpeta
    param out mensajes    : colección de objetos ob_iax_mensajes
         return             : 0 Todo Ok
                           <> 0 num_err
   -- bug 0028554 - 06/02/2014 - JMF
   *************************************************************************/
   FUNCTION f_genera_carpeta(pccarpeta IN VARCHAR2, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      --
      vobjectname    VARCHAR2(500) := 'PAC_MD_FACTURAS.f_genera_carpeta';
      vparam         VARCHAR2(1000) := 'c=' || pccarpeta;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vmap           cfg_lanzar_informes.cmap%TYPE;
      vemp           cfg_lanzar_informes.cempres%TYPE;
      vidi           det_lanzar_informes.cidioma%TYPE;
      onomfichero    VARCHAR2(1000);
      ofichero       VARCHAR2(1000);
      vtinfo         t_iax_info;
      vinfo          ob_iax_info;
      b_error        BOOLEAN;

      CURSOR c1 IS
         SELECT   *
             FROM facturas
            WHERE cempres = vemp
              AND ccarpeta = pccarpeta
              AND cestado = 0
              AND nfolio IS NULL
         ORDER BY ctipdoc;
   BEGIN
      vemp := pac_md_common.f_get_cxtempresa;
      vidi := pac_md_common.f_get_cxtidioma;
      vtinfo := t_iax_info();
      vinfo := ob_iax_info();
      b_error := FALSE;

      --
      FOR f1 IN c1 LOOP
         IF f1.ctipdoc = 1 THEN
            -- FA - Factura afecta
            vmap := 'FacturaAfecta';
         ELSIF f1.ctipdoc = 3 THEN
            -- EX - Factura exenta
            vmap := 'FacturaExenta';
         ELSIF f1.ctipdoc = 5 THEN
            -- NC - Nota de crédito
            vmap := 'FacturaNotaCredito';
         ELSE
            vmap := NULL;
         END IF;

         IF vmap IS NOT NULL THEN
            -- Los tres listados tienen los mismos parametros
            vtinfo.DELETE;
            vtinfo.EXTEND;
            vinfo.nombre_columna := 'NFACT';
            vinfo.valor_columna := f1.nfact;
            vinfo.tipo_columna := '1';
            vtinfo(vtinfo.LAST) := vinfo;
            vtinfo.EXTEND;
            vinfo.nombre_columna := 'CAGENTE';
            vinfo.valor_columna := f1.cagente;
            vinfo.tipo_columna := '2';
            vtinfo(vtinfo.LAST) := vinfo;
            vtinfo.EXTEND;
            vinfo.nombre_columna := 'GENERA_CARPETA';
            vinfo.valor_columna := f1.ccarpeta;
            vinfo.tipo_columna := '1';
            vtinfo(vtinfo.LAST) := vinfo;
            -- proceso impresion
            vnumerr := pac_md_informes.f_ejecuta_informe(vmap, vemp, 'PDF', vtinfo, vidi, 1,
                                                         NULL, onomfichero, ofichero,
                                                         mensajes);

            IF vnumerr != 0 THEN
               b_error := TRUE;
            END IF;
         END IF;
      END LOOP;

      IF b_error THEN
         -- Documento incorrecto.
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9902749);
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
    Proceso emite facturas (emision y cobro) y despues imprime
   -- bug 0028554 - 06/02/2014 - JMF
   *************************************************************************/
   FUNCTION f_emiteimprime_batch(pdesde IN DATE, phasta IN DATE, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      --
      vobjectname    VARCHAR2(500) := 'PAC_MD_FACTURAS.f_emiteimprime_batch';
      vparam         VARCHAR2(1000) := 'd=' || pdesde || ' h=' || phasta;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      --
      vmap           cfg_lanzar_informes.cmap%TYPE;
      vemp           cfg_lanzar_informes.cempres%TYPE;
      vidi           det_lanzar_informes.cidioma%TYPE;
      onomfichero    VARCHAR2(1000);
      ofichero       VARCHAR2(1000);
      vtinfo         t_iax_info;
      vinfo          ob_iax_info;
      v_sproces      procesoscab.sproces%TYPE;
      v_numlin       NUMBER;

      -- Emisiones, FA - Factura afecta, pendientes
      CURSOR c1 IS
         SELECT nfact, cagente, ccarpeta
           FROM facturas
          WHERE ctipfact = 1
            AND ctipdoc = 1
            AND nfolio IS NULL
            AND cestado = 0
            AND(pdesde IS NULL
                OR ffact >= pdesde)
            AND(phasta IS NULL
                OR ffact <= phasta);

      -- Emisiones, EX - Factura exenta, pendientes
      CURSOR c3 IS
         SELECT nfact, cagente, ccarpeta
           FROM facturas
          WHERE ctipfact = 3
            AND ctipdoc = 1
            AND nfolio IS NULL
            AND cestado = 0
            AND(pdesde IS NULL
                OR ffact >= pdesde)
            AND(phasta IS NULL
                OR ffact <= phasta);

      -- Emisiones, NC - Nota de crédito, pendientes
      CURSOR c5 IS
         SELECT nfact, cagente, ccarpeta
           FROM facturas
          WHERE ctipfact = 5
            AND ctipdoc = 1
            AND nfolio IS NULL
            AND cestado = 0
            AND(pdesde IS NULL
                OR ffact >= pdesde)
            AND(phasta IS NULL
                OR ffact <= phasta);
   BEGIN
      vemp := f_parinstalacion_n('EMPRESADEF');

      SELECT MAX(nvalpar)
        INTO vidi
        FROM parinstalacion
       WHERE cparame = 'IDIOMARTF';

      pac_facturas.p_emite_facturas;
      vnumerr := f_procesini(f_user, vemp, 'FACTURAS_IMPRESION',
                             f_axis_literales(9000442, vidi), v_sproces);
----------------------------------------------
      vmap := 'FacturaAfecta';
      vtinfo := t_iax_info();

      FOR f1 IN c1 LOOP
         vtinfo.DELETE;
         vinfo := ob_iax_info();
         vtinfo.EXTEND;
         vinfo.nombre_columna := 'NFACT';
         vinfo.valor_columna := f1.nfact;
         vinfo.tipo_columna := '1';
         vtinfo(vtinfo.LAST) := vinfo;
         vtinfo.EXTEND;
         vinfo.nombre_columna := 'CAGENTE';
         vinfo.valor_columna := f1.cagente;
         vinfo.tipo_columna := '2';
         vtinfo(vtinfo.LAST) := vinfo;
         vtinfo.EXTEND;
         vinfo.nombre_columna := 'GENERA_CARPETA';
         vinfo.valor_columna := f1.ccarpeta;
         vinfo.tipo_columna := '1';
         vtinfo(vtinfo.LAST) := vinfo;
         vnumerr := pac_md_informes.f_ejecuta_informe(vmap, vemp, 'PDF', vtinfo, vidi, 1,
                                                      NULL, onomfichero, ofichero, mensajes);
         v_numlin := NULL;
         vnumerr := f_proceslin(v_sproces,
                                SUBSTR('(1) ' || f1.nfact || '-' || f1.cagente || '-'
                                       || vnumerr || ' ' || onomfichero,
                                       1, 120),
                                0, v_numlin, 2);
      END LOOP;

      vmap := 'FacturaExenta';
      vtinfo := t_iax_info();

      FOR f3 IN c3 LOOP
         vtinfo.DELETE;
         vinfo := ob_iax_info();
         vtinfo.EXTEND;
         vinfo.nombre_columna := 'NFACT';
         vinfo.valor_columna := f3.nfact;
         vinfo.tipo_columna := '1';
         vtinfo(vtinfo.LAST) := vinfo;
         vtinfo.EXTEND;
         vinfo.nombre_columna := 'CAGENTE';
         vinfo.valor_columna := f3.cagente;
         vinfo.tipo_columna := '2';
         vtinfo(vtinfo.LAST) := vinfo;
         vtinfo.EXTEND;
         vinfo.nombre_columna := 'GENERA_CARPETA';
         vinfo.valor_columna := f3.ccarpeta;
         vinfo.tipo_columna := '1';
         vtinfo(vtinfo.LAST) := vinfo;
         vnumerr := pac_md_informes.f_ejecuta_informe(vmap, vemp, 'PDF', vtinfo, vidi, 1,
                                                      NULL, onomfichero, ofichero, mensajes);
         v_numlin := NULL;
         vnumerr := f_proceslin(v_sproces,
                                SUBSTR('(3) ' || f3.nfact || '-' || f3.cagente || '-'
                                       || vnumerr || ' ' || onomfichero,
                                       1, 120),
                                0, v_numlin, 2);
      END LOOP;

      vmap := 'FacturaNotaCredito';
      vtinfo := t_iax_info();

      FOR f5 IN c5 LOOP
         vtinfo.DELETE;
         vinfo := ob_iax_info();
         vtinfo.EXTEND;
         vinfo.nombre_columna := 'NFACT';
         vinfo.valor_columna := f5.nfact;
         vinfo.tipo_columna := '1';
         vtinfo(vtinfo.LAST) := vinfo;
         vtinfo.EXTEND;
         vinfo.nombre_columna := 'CAGENTE';
         vinfo.valor_columna := f5.cagente;
         vinfo.tipo_columna := '2';
         vtinfo(vtinfo.LAST) := vinfo;
         vtinfo.EXTEND;
         vinfo.nombre_columna := 'GENERA_CARPETA';
         vinfo.valor_columna := f5.ccarpeta;
         vinfo.tipo_columna := '1';
         vtinfo(vtinfo.LAST) := vinfo;
         vnumerr := pac_md_informes.f_ejecuta_informe(vmap, vemp, 'PDF', vtinfo, vidi, 1,
                                                      NULL, onomfichero, ofichero, mensajes);
         v_numlin := NULL;
         vnumerr := f_proceslin(v_sproces,
                                SUBSTR('(5) ' || f5.nfact || '-' || f5.cagente || '-'
                                       || vnumerr || ' ' || onomfichero,
                                       1, 120),
                                0, v_numlin, 2);
      END LOOP;

      vnumerr := f_procesfin(v_sproces, 0);
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
   END f_emiteimprime_batch;

   FUNCTION f_get_listnliqmen(pcagente IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100) := 'pcagente: ' || pcagente;
      vobject        VARCHAR2(200) := 'PAC_MD_LISTVALORES.f_get_listnliqmen';
      squery         VARCHAR2(500);
   BEGIN
      IF pcagente IS NULL THEN
         RAISE e_param_error;
      END IF;

      squery := 'SELECT   a.nliqmen, MAX(a.fliquid) fliquid ' || 'FROM liquidacab a '
                || ' WHERE a.cestado = 1 ' || ' AND a.cagente =  ' || pcagente
                || ' AND a.cempres = ' || pac_md_common.f_get_cxtempresa()
                || ' GROUP BY a.nliqmen' || ' ORDER BY 2 DESC';
      cur := pac_md_listvalores.f_opencursor(squery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
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
   END f_get_listnliqmen;

   /*************************************************************************
    Función que autoriza una factura
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
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vobjectname    VARCHAR2(500) := 'PAC_MD_FACTURAS.f_autoriza_factura';
      vpasexec       NUMBER(5) := 1;
      vparam         VARCHAR2(2000)
                         := 'parámetros - pcempres = ' || pcempres || ' - pnfact = ' || pnfact;
   BEGIN
      vpasexec := 2;
      vnumerr := pac_facturas.f_autoriza_factura(pcempres, pnfact, pcagente);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 9906562);   -- Factura autorizada
      vpasexec := 3;
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
END pac_md_facturas;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_FACTURAS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_FACTURAS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_FACTURAS" TO "PROGRAMADORESCSI";
