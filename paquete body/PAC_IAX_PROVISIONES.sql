--------------------------------------------------------
--  DDL for Package Body PAC_IAX_PROVISIONES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IAX_PROVISIONES" AS
/******************************************************************************
   NOMBRE:       PAC_IAX_PROVISIONES
   PROP¿SITO:  Funciones para gestionar las provisiones

   REVISIONES:
   Ver        Fecha        Autor             Descripci¿n
   ---------  ----------  ---------------  ------------------------------------
   1.0        18/09/2008   APD                1. Creaci¿n del package body.
******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   /*************************************************************************
      Recupera todas las provisiones existentes seg¿n la empresa seleccionada
      param in pempresa  : c¿digo de empresa
      param out mensajes : mesajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_provisiones_emp(pempresa IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'pempresa: ' || pempresa;
      vobject        VARCHAR2(200) := 'PAC_IAX_PROVISIONES.F_Get_Provisiones_Emp';
      cur            sys_refcursor;
      squery         VARCHAR2(1000);
   BEGIN
      IF pempresa IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      squery := pac_md_provisiones.f_get_provisiones_emp(pempresa, mensajes);
      cur := pac_iax_listvalores.f_opencursor(squery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, NULL,
                                           SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_provisiones_emp;

   /*************************************************************************
      Recupera todas las provisiones existentes
      param out mensajes : mesajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_provisiones(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAX_PROVISIONES.F_Get_Provisiones';
      cur            sys_refcursor;
      squery         VARCHAR2(1000);
   BEGIN
      squery := pac_md_provisiones.f_get_provisiones(mensajes);
      cur := pac_iax_listvalores.f_opencursor(squery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, NULL,
                                           SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_provisiones;

   /*************************************************************************
      Recupera todas las provisiones existentes y muestra el c¿digo de la nueva provisi¿n
      param out mensajes : mesajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_provisiones_nueva(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAX_PROVISIONES.F_Get_Provisiones_Nueva';
      cur            sys_refcursor;
      squery         VARCHAR2(1000);
   BEGIN
      squery := pac_md_provisiones.f_get_provisiones_nueva(mensajes);
      cur := pac_iax_listvalores.f_opencursor(squery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, NULL,
                                           SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_provisiones_nueva;

   /*************************************************************************
      Recupera todos los tipos de provisiones
      param in pprovis   : c¿digo de la provision
      param out mensajes : mesajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_provisiones_tipo(pprovis IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAX_PROVISIONES.F_Get_Provisiones_Tipo';
      cur            sys_refcursor;
   BEGIN
      cur := pac_iax_listvalores.f_detvalores(158, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, NULL,
                                           SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_provisiones_tipo;

   /*************************************************************************
      Recupera todas las descripciones de una provisi¿n en los diferentes idiomas que exista
      param in pprovis   : c¿digo de la provision
      param out mensajes : mesajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_desprovisiones(pprovis IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'pprovis: ' || pprovis;
      vobject        VARCHAR2(200) := 'PAC_IAX_PROVISIONES.F_Get_DesProvisiones';
      cur            sys_refcursor;
      squery         VARCHAR2(1000);
   BEGIN
      IF pprovis IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      squery := pac_md_provisiones.f_get_desprovisiones(pprovis, mensajes);
      cur := pac_iax_listvalores.f_opencursor(squery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, NULL,
                                           SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_desprovisiones;

   /*************************************************************************
      Actualiza o inserta una provisi¿n
      param in pempresa  : c¿digo de empresa
      param in pprovis   : c¿digo de la provision
      param in pfbaja    : fecha de baja de la provisi¿n
      param in ptipoprov : c¿digo del tipo de provisi¿n
      param in pcreport  : Nombre del listado de la provisi¿n
      param out mensajes : mesajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_grabar_provisiones(
      pempresa IN NUMBER,
      pprovis IN NUMBER,
      pfbaja IN DATE,
      ptipoprov IN NUMBER,
      pcreport IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'pempresa: ' || pempresa || ';pprovis: ' || pprovis || ';pfbaja: ' || pfbaja
            || ';ptipoprov: ' || ptipoprov || ';pcreport: ' || pcreport;
      vobject        VARCHAR2(200) := 'PAC_IAX_PROVISIONES.F_Grabar_Provisiones';
      num_err        NUMBER;
   BEGIN
      IF pempresa IS NULL
         OR pprovis IS NULL
         OR ptipoprov IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      num_err := pac_md_provisiones.f_grabar_provisiones(pempresa, pprovis, pfbaja, ptipoprov,
                                                         pcreport, mensajes);
      RETURN num_err;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, NULL,
                                           SQLCODE, SQLERRM);
         RETURN 1;
   END f_grabar_provisiones;

   /*************************************************************************
      Actualiza o inserta una descripci¿n de provisi¿n
      param in pprovis   : c¿digo de la provision
      param in pcidioma  : idioma de la descripci¿n de la provisi¿n
      param in ptcprovis : descripci¿n corta de la provisi¿n
      param in ptlprovis : descripci¿n larga de la provisi¿n
      param out mensajes : mesajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_grabar_desprovisiones(
      pprovis IN NUMBER,
      pcidioma IN NUMBER,
      ptcprovis IN VARCHAR2,
      ptlprovis IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'pprovis: ' || pprovis;
      vobject        VARCHAR2(200) := 'PAC_IAX_PROVISIONES.F_Grabar_DesProvisiones';
      num_err        NUMBER;
   BEGIN
      IF pprovis IS NULL
         OR pcidioma IS NULL
         OR ptcprovis IS NULL
         OR ptlprovis IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      num_err := pac_md_provisiones.f_grabar_desprovisiones(pprovis, pcidioma, ptcprovis,
                                                            ptlprovis, mensajes);
      RETURN num_err;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, NULL,
                                           SQLCODE, SQLERRM);
         RETURN 1;
   END f_grabar_desprovisiones;

   /*************************************************************************
      Valida si una provisi¿n ya existe
      param in pprovis   : c¿digo de la provision
      param out mensajes : mesajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_validar_provision(pprovis IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'pprovis: ' || pprovis;
      vobject        VARCHAR2(200) := 'PAC_IAX_PROVISIONES.F_Validar_Provision';
      num_err        NUMBER;
   BEGIN
      IF pprovis IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      num_err := pac_md_provisiones.f_validar_provision(pprovis, mensajes);
      RETURN num_err;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, NULL,
                                           SQLCODE, SQLERRM);
         RETURN 1;
   END f_validar_provision;

   /*************************************************************************
      Recupera la cadena para poder ejecutar el report con los par¿metros correspondientes
      param in pempresa  : c¿digo de la empresa
      param in pprevio   : radio button previo/real
      param in pprovis   : c¿digo de la provisi¿n
      param in pfecha    : ¿ltimo d¿a del mes y a¿o informados
      param in pcagente  : c¿digo de agente si est¿ informado
      param in psubagente : check de incluir subagentes en el report
      param out mensajes : mensajes de error
      return             : cadena para poder ejecutar el report
   *************************************************************************/
   FUNCTION f_get_report_provision(
      pempresa IN NUMBER,
      pprevio IN NUMBER,
      pprovis IN NUMBER,
      pmes IN NUMBER,
      panyo IN NUMBER,
      pcagente IN NUMBER,
      psubagente IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN VARCHAR2 IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'pempresa: ' || pempresa || ' - pprevio: ' || pprevio || ' - pprovis: ' || pprovis
            || ' - pmes: ' || pmes || ' - panyo: ' || panyo || ' - pcagente: ' || pcagente
            || ' - psubagente: ' || psubagente;
      vobject        VARCHAR2(200) := 'PAC_IAX_PROVISIONES.F_Get_Report_Provision';
      RESULT         VARCHAR2(4000);
   BEGIN
      IF pempresa IS NULL
         OR pprovis IS NULL
         OR pmes IS NULL
         OR panyo IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      RESULT := pac_md_provisiones.f_get_report_provision(pempresa, pprevio, pprovis, pmes,
                                                          panyo, pcagente, psubagente,
                                                          mensajes);

      IF RESULT IS NULL THEN
         RAISE e_object_error;
      END IF;

      RETURN RESULT;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, NULL,
                                           SQLCODE, SQLERRM);
         RETURN 1;
   END f_get_report_provision;

   /*************************************************************************
      Llama al PAC_MAP para ejecutar N maps que pasasmos en pprovis separados por @
        param in cmaps: Tipo car¿cter. Ids. de los maps. separados por '@'
        param in Pfecha: Tipo car¿cter. fecha de calculo en formato ddmmyyyy
        param in Pcempres: Tipo car¿cter. CEMPRESA
        param out MENSAJES: Tipo t_iax_mensajes. Par¿metro de Salida. Mensaje de error
        return             : Retorna un NUMERICO 0 ok / 1 KO
   *************************************************************************/
   FUNCTION f_llama_multimap_provis(
      cmaps IN VARCHAR2,
      pfecha IN VARCHAR2,
      pcempres IN NUMBER,
      fichero OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
                      := 'cmaps:' || cmaps || ' pfecha:' || pfecha || ' pcempres:' || pcempres;
      vobject        VARCHAR2(200) := 'PAC_IAX_PROVISIONES.f_llama_multimap_provis';
      RESULT         VARCHAR2(4000);
   BEGIN
      IF cmaps IS NULL
         OR pfecha IS NULL THEN
         RAISE e_param_error;
      END IF;

      -- Si est¿ activo el par¿metro, ejecutamos en batch
      IF NVL(pac_parametros.f_parempresa_n(pcempres, 'LISTPROV_BATCH'), 0) = 1 THEN
         vpasexec := 3;
         RESULT := pac_md_provisiones.f_llama_multimap_provis_batch(cmaps, pfecha, pcempres,
                                                                    mensajes);
         fichero := '@';

         IF RESULT <> 0 THEN
            RAISE e_object_error;
         END IF;

         RETURN 1;
      ELSE
         vpasexec := 4;
         RESULT := pac_md_provisiones.f_llama_multimap_provis(cmaps, pfecha, pcempres,
                                                              fichero, mensajes);

         IF RESULT <> 0 THEN
            RAISE e_object_error;
         END IF;
      END IF;

      RETURN RESULT;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, NULL,
                                           SQLCODE, SQLERRM);
         RETURN 1;
   END f_llama_multimap_provis;

   /*************************************************************************
      Recupera los datos para una una provision por garantia
      param in sseguro   : c¿digo de seguro
      param in nriesgo   : c¿digo del riesgo
      param in cgarant   : c¿digo de garantia
      param in nmovimi   : c¿digo de movimiento
      param in fecha     : fecha de provision
      param out mensajes : mesajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_detalle_pu(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pcgarant IN NUMBER,
      pnmovimi IN NUMBER,
      pfecha IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'psseguro: ' || psseguro || ' pnriesgo: ' || pnriesgo || ' pcgarant: ' || pcgarant
            || ' pnmovimi: ' || pnmovimi || ' pfecha: ' || pfecha;
      vobject        VARCHAR2(200) := 'PAC_IAX_PROVISIONES.f_detalle_PU';
      cur            sys_refcursor;
      squery         VARCHAR2(1000);
   BEGIN
      IF psseguro IS NULL
         OR pcgarant IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      squery := pac_md_provisiones.f_detalle_pu(psseguro, pnriesgo, pcgarant, pnmovimi, pfecha,
                                                mensajes);
      cur := pac_iax_listvalores.f_opencursor(squery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, NULL,
                                           SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_detalle_pu;


      /**********************************************************************
      FUNCTION F_GRABAR_EXCLUSIONES
      Funci¿n que almacena los datos de la exclusion.
      Firma (Specification)
      Param IN pnpoliza    : npoliza
      Param IN pnrecibo    : nrecibo
	    Param IN pcobservexc : cobservexc
	    Param IN pcprovisi   : cprovisi
	    Param IN pcobservp   : pcobservp
	    Param IN pcnprovisi  : pcnprovisi
	    Param IN pcobservnp  : pcobservnp
	    Param IN pfalta      : pfalta
	    Param IN pfbaja      : pfbaja
      Param OUT mensajes : mesajes de error
      return             : 0 todo ha sido correcto
                           1 ha habido un error
    **********************************************************************/
    FUNCTION f_grabar_exclusiones(
         pnpoliza IN NUMBER,
         pnrecibo IN NUMBER,
	    pcobservexc IN VARCHAR2,
	      pcprovisi IN NUMBER,
	      pcobservp IN VARCHAR2,
	     pcnprovisi IN NUMBER,
	     pcobservnp IN VARCHAR2,
	         pfalta IN DATE,
	         pfbaja IN DATE,
         mensajes IN OUT T_IAX_MENSAJES )
         RETURN NUMBER IS
      vnumerr        NUMBER;
      vobjectname    VARCHAR2(500) := 'PAC_IAX_PROVISIONES.f_grabar_exclusiones';
      vpasexec       NUMBER(5) := 1;
      vparam         VARCHAR2(1000) := 'par¿metros - ' || 'pnpoliza: ' || pnpoliza || ' pnrecibo: ' || pnrecibo || ' pcobservexc: ' || pcobservexc
                                        || ' pcprovisi: ' || pcprovisi || ' pcobservp: ' || pcobservp || ' pcnprovisi: ' || pcnprovisi
                                        || ' pcobservnp: ' || pcobservnp || ' pfalta: ' || pfalta || ' pfbaja: ' || pfbaja;

       BEGIN

          vnumerr := pac_md_provisiones.f_grabar_exclusiones(pnpoliza, pnrecibo, pcobservexc, pcprovisi, pcobservp,
	                                                           pcnprovisi, pcobservnp, pfalta, pfbaja, mensajes);

          IF vnumerr = 1 THEN
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
       END f_grabar_exclusiones;


   /**********************************************************************
      FUNCTION F_DEL_EXCLUSIONES
      Funci¿n que elimina de la exclusion por numero de poliza
      Param IN pnpoliza : npoliza
      Param IN pnrecibo : nrecibo
      Param OUT PRETCURSOR : SYS_REF_CURSOR
     **********************************************************************/
      FUNCTION f_del_exclusiones(
        pnpoliza IN exclus_provisiones.npoliza%TYPE,
        pnrecibo IN exclus_provisiones.nrecibo%TYPE,
        mensajes IN OUT T_IAX_MENSAJES)
        RETURN NUMBER IS
          vnumerr        NUMBER(8) := 0;
          vpasexec       NUMBER(8) := 1;
          vparam         VARCHAR2(500) := 'parametros  - ';
          vobject        VARCHAR2(200) := 'PAC_IAX_FINANCIERA.f_del_renta';
       BEGIN

          vnumerr := pac_md_provisiones.f_del_exclusiones(pnpoliza, pnrecibo, mensajes);

          IF vnumerr = 1 THEN
             RAISE e_object_error;
          END IF;
          COMMIT;
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
       END f_del_exclusiones;


   /**********************************************************************
      FUNCTION F_GET_EXCLUSIONES
      Funci¿n que retorna todas las exclusiones existentes de acuerdo a la
      consulta.
      Param IN  pcsucursal  : csucursal
      Param IN  pfdesde     : fdesde
      Param IN  pfhasta     : fhasta
      Param IN  pnpoliza    : npoliza
      Param IN  pnrecibo    : nrecibo
      Param IN  pnit        : nit
      Param IN  pnnumide    : nnumide
      Param IN  pcagente    : cagente
      Param OUT PRETCURSOR  : SYS_REF_CURSOR
     **********************************************************************/
     FUNCTION f_get_exclusiones(
        pcsucursal IN NUMBER,
           pfdesde IN DATE,
           pfhasta IN DATE,
          pnpoliza IN NUMBER,
          pnrecibo IN NUMBER,
              pnit IN NUMBER,
          pnnumide IN VARCHAR2,
          pcagente IN NUMBER,
          mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'pcsucursal: ' || pcsucursal || ' pfdesde: ' || pfdesde || ' pfhasta: ' || pfhasta
          || ' pnpoliza: ' || pnpoliza || ' pnrecibo: ' || pnrecibo || ' pnit: ' || pnit
          || ' pnnumide: ' || pnnumide || ' pcagente: ' || pcagente;
      vobject        VARCHAR2(200) := 'PAC_IAX_PROVISIONES.f_get_exclusiones';
      cur            sys_refcursor;
      squery         VARCHAR2(1000);
   BEGIN
      --ML 3951 filtro recibo no depende de las fechas
      /*IF pfdesde IS NULL
         OR pfhasta IS NULL THEN
         RAISE e_param_error;
      END IF;*/
      --ML 3951 filtro recibo no depende de las fechas      

      vpasexec := 3;
      squery := pac_md_provisiones.f_get_exclusiones(pcsucursal, pfdesde, pfhasta, pnpoliza, pnrecibo,
                                                pnit, pnnumide, pcagente, mensajes);
      cur := pac_iax_listvalores.f_opencursor(squery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, NULL,
                                           SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_exclusiones;


    /**********************************************************************
      FUNCTION F_GET_EXCLUSIONES
      Funci¿n que retorna todas las exclusiones existentes de acuerdo a la
      consulta.
      Param IN  pnpoliza    : npoliza
      Param IN  pnrecibo    : nrecibo
      Param OUT PRETCURSOR  : SYS_REF_CURSOR
     **********************************************************************/
     FUNCTION f_get_exclusionesbypk(
          pnpoliza IN NUMBER,
          pnrecibo IN NUMBER,
          mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'pnpoliza: ' || pnpoliza || ' pnrecibo: ' || pnrecibo;
      vobject        VARCHAR2(200) := 'PAC_IAX_PROVISIONES.f_get_exclusionesbypk';
      cur            sys_refcursor;
      squery         VARCHAR2(1000);
   BEGIN
      IF pnpoliza IS NULL
         OR pnrecibo IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      squery := pac_md_provisiones.f_get_exclusionesbypk(pnpoliza, pnrecibo, mensajes);
      cur := pac_iax_listvalores.f_opencursor(squery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, NULL,
                                           SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_exclusionesbypk;


   /**********************************************************************
      FUNCTION F_GET_EXISTEPOLIZARECIBO
      Funci¿n que retorna si existe o no poliza y recibo
      Param IN  pnpoliza    : npoliza
      Param IN  pnrecibo    : nrecibo
      Param OUT PRETCURSOR  : SYS_REF_CURSOR
     **********************************************************************/
      FUNCTION f_get_existepolizarecibo(
          pnpoliza IN NUMBER,
          pnrecibo IN NUMBER,
          mensajes IN OUT T_IAX_MENSAJES)
       RETURN sys_refcursor IS
        vpasexec       NUMBER(8) := 1;
        vparam         VARCHAR2(200) := 'pnpoliza: ' || pnpoliza || ' pnrecibo: ' || pnrecibo;
        vobject        VARCHAR2(200) := 'PAC_IAX_PROVISIONES.f_get_existepolizarecibo';
        cur            sys_refcursor;
        squery         VARCHAR2(1000);
     BEGIN
        IF pnpoliza IS NULL
           OR pnrecibo IS NULL THEN
           RAISE e_param_error;
        END IF;

        vpasexec := 3;
        squery := pac_md_provisiones.f_get_existepolizarecibo(pnpoliza, pnrecibo, mensajes);
        cur := pac_iax_listvalores.f_opencursor(squery, mensajes);
        RETURN cur;
     EXCEPTION
        WHEN e_param_error THEN
           pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

           IF cur%ISOPEN THEN
              CLOSE cur;
           END IF;

           RETURN cur;
        WHEN OTHERS THEN
           pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, NULL,
                                             SQLCODE, SQLERRM);

           IF cur%ISOPEN THEN
              CLOSE cur;
           END IF;

           RETURN cur;
     END f_get_existepolizarecibo;
END pac_iax_provisiones;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_PROVISIONES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_PROVISIONES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_PROVISIONES" TO "PROGRAMADORESCSI";
