--------------------------------------------------------
--  DDL for Package Body PAC_MD_PROVISIONES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MD_PROVISIONES" AS
/******************************************************************************
   NOMBRE: PAC_MD_PROVISIONES
   PROP¿SITO:  Funciones para gestionar las provisiones

   REVISIONES:
   Ver        Fecha        Autor             Descripci¿n
   ---------  ----------  ---------------  ------------------------------------
   1.0        18/09/2008   APD                1. Creaci¿n del package body.
   2.0        13/03/2014   MMM                2. 0028929: LCOL_F003-0009973: Error al descargar archivo AMOCOM
   3.0        02/05/2014   MMM                3. 0028929: LCOL_F003-0009973: Error al descargar archivo AMOCOM
******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   /*************************************************************************
      Recupera el par¿metro de proceso
      param in pempresa  : c¿digo de empresa
      param in pprevio   : radio button previo/real
      param in pprovis   : c¿digo de la provisi¿n
      param in ptcprovis : descripci¿n corta de la provisi¿n
      param in pfecha    : ¿ltimo d¿a del mes y a¿o informados
      param out psproces : c¿digo del proceso
      param out mensajes : mesajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_sproces(
      pempresa IN NUMBER,
      pprevio IN NUMBER,
      pprovis IN NUMBER,
      ptprovis IN VARCHAR2,
      pfecha IN DATE,
      mensajes IN OUT t_iax_mensajes,
      psproces OUT NUMBER)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'pempresa: ' || pempresa || ' - pprevio: ' || pprevio || ' - pprovis: ' || pprovis
            || ' - ptprovis: ' || ptprovis || ' - pfecha: ' || TO_CHAR(pfecha, 'dd/mm/yyyy');
      vobject        VARCHAR2(200) := 'PAC_MD_PROVISIONES.F_Get_Sproces';
      RESULT         VARCHAR2(4000);
   BEGIN
      RESULT := pac_provisiones.f_sproces(pempresa, pprevio, pprovis, ptprovis, pfecha,
                                          pac_md_common.f_get_cxtidioma, psproces);

      IF RESULT IS NOT NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, NULL, RESULT);
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, NULL,
                                           SQLCODE, SQLERRM);
         RETURN 1;
   END f_get_sproces;

   /*************************************************************************
      Recupera todas las provisiones existentes seg¿n la empresa seleccionada
      param in pempresa  : c¿digo de empresa
      param out mensajes : mesajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_provisiones_emp(pempresa IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN VARCHAR2 IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'pempresa: ' || pempresa;
      vobject        VARCHAR2(200) := 'PAC_MD_PROVISIONES.F_Get_Provisiones_Emp';
      squery         VARCHAR2(1000);
   BEGIN
      squery := pac_provisiones.f_get_provisiones_emp(pempresa, pac_md_common.f_get_cxtidioma);
      RETURN squery;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, NULL,
                                           SQLCODE, SQLERRM);
         RETURN NULL;
   END f_get_provisiones_emp;

   /*************************************************************************
      Recupera todas las provisiones existentes
      param out mensajes : mesajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_provisiones(mensajes IN OUT t_iax_mensajes)
      RETURN VARCHAR2 IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_PROVISIONES.F_Get_Provisiones';
      squery         VARCHAR2(1000);
   BEGIN
      squery := pac_provisiones.f_get_provisiones(pac_md_common.f_get_cxtidioma);
      RETURN squery;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, NULL,
                                           SQLCODE, SQLERRM);
         RETURN NULL;
   END f_get_provisiones;

   /*************************************************************************
      Recupera todas las provisiones existentes y muestra el c¿digo de la nueva provisi¿n
      param out mensajes : mesajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_provisiones_nueva(mensajes IN OUT t_iax_mensajes)
      RETURN VARCHAR2 IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_PROVISIONES.F_Get_Provisiones_Nueva';
      squery         VARCHAR2(1000);
   BEGIN
      squery := pac_provisiones.f_get_provisiones_nueva(pac_md_common.f_get_cxtidioma);
      RETURN squery;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, NULL,
                                           SQLCODE, SQLERRM);
         RETURN NULL;
   END f_get_provisiones_nueva;

   /*************************************************************************
      Recupera todas las descripciones de una provisi¿n en los diferentes idiomas que exista
      param in pprovis   : c¿digo de la provision
      param out mensajes : mesajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_desprovisiones(pprovis IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN VARCHAR2 IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'pprovis: ' || pprovis;
      vobject        VARCHAR2(200) := 'PAC_MD_PROVISIONES.F_Get_DesProvisiones';
      squery         VARCHAR2(1000);
   BEGIN
      squery := pac_provisiones.f_get_desprovisiones(pprovis);
      RETURN squery;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, NULL,
                                           SQLCODE, SQLERRM);
         RETURN NULL;
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
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'pempresa: ' || pempresa || ';pprovis: ' || pprovis || ';pfbaja: ' || pfbaja
            || ';ptipoprov: ' || ptipoprov || ';pcreport: ' || pcreport;
      vobject        VARCHAR2(200) := 'PAC_MD_PROVISIONES.F_Grabar_Provisiones';
      vcount         NUMBER;
   BEGIN
      vcount := pac_provisiones.f_grabar_provisiones(pempresa, pprovis, pfbaja, ptipoprov,
                                                     pcreport);
      RETURN vcount;
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
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'pprovis: ' || pprovis || ';pcidioma: ' || pcidioma || ';ptcprovis: ' || ptcprovis
            || ';ptlprovis: ' || ptlprovis;
      vobject        VARCHAR2(200) := 'PAC_MD_PROVISIONES.F_Grabar_DesProvisiones';
      vcount         NUMBER;
   BEGIN
      vcount := pac_provisiones.f_grabar_desprovisiones(pprovis, pcidioma, ptcprovis,
                                                        ptlprovis);
      RETURN vcount;
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
      param in pempresa  : c¿digo de la empresa
      param in pprovis   : c¿digo de la provision
      param out mensajes : mesajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_validar_provision(pprovis IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'pprovis: ' || pprovis;
      vobject        VARCHAR2(200) := 'PAC_MD_PROVISIONES.F_Validar_Provision';
      vcount         NUMBER;
   BEGIN
      vcount := pac_provisiones.f_validar_provision(pprovis);

      IF vcount <> 0 THEN   -- existe la provisi¿n para la empresa seleccionada
         RETURN 1;
      ELSE   -- no existe la provisi¿n para la empresa seleccionada
         RETURN 0;
      END IF;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1000005;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, NULL,
                                           SQLCODE, SQLERRM);
         RETURN SQLCODE;
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
      mensajes IN OUT t_iax_mensajes)
      RETURN VARCHAR2 IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'pempresa: ' || pempresa || ' - pprevio: ' || pprevio || ' - pprovis: ' || pprovis
            || ' - pmes: ' || pmes || ' - panyo: ' || panyo || ' - pcagente: ' || pcagente
            || ' - psubagente: ' || psubagente;
      vobject        VARCHAR2(200) := 'PAC_MD_PROVISIONES.F_Get_Report_Provision';
      vfecha         DATE;
      vcadena        VARCHAR2(4000);
      vnomreport     VARCHAR2(100);
      vtcprovis      VARCHAR2(200);
      vsproces       NUMBER;
      verror         NUMBER;
   BEGIN
      -- Se valida que los par¿metros siguientes est¿n informados
      IF pempresa IS NULL
         OR pprovis IS NULL
         OR pmes IS NULL
         OR panyo IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;

      -- Se busca la descripci¿n de la provisi¿n
      BEGIN
         -- Si la provisi¿n es 99 (PM), la descripci¿n no se busca de la tabla DESPROVISIONES, sino de la tabla LITERALES
         IF pprovis = 99 THEN
            vtcprovis := pac_iobj_mensajes.f_get_descmensaje(107120);   -- Provisi¿n matem¿tica
         ELSE
            SELECT tcprovis
              INTO vtcprovis
              FROM desprovisiones
             WHERE cprovis = pprovis
               AND cidioma = pac_md_common.f_get_cxtidioma;
         END IF;
      EXCEPTION
         WHEN OTHERS THEN
            RAISE e_object_error;
      END;

      vpasexec := 5;
      vfecha := LAST_DAY(TO_DATE('01-' || pmes || '-' || panyo, 'dd-mm-yyyy'));
      -- Se busca el sproces de la provisi¿n
      verror := pac_md_provisiones.f_get_sproces(pempresa, pprevio, pprovis, vtcprovis, vfecha,
                                                 mensajes, vsproces);

      IF verror <> 0 THEN
         RAISE e_object_error;
      END IF;

      vpasexec := 7;

        -- Se busca el nombre del report a lanzar en funci¿n de la provisi¿n
/*
        IF pprovis = 1 THEN -- PPNC
           vnomreport := 'alctr650';
        ELSIF pprovis = 99 THEN -- PM
           vnomreport := 'alctr651';
        ELSIF pprovis = 8 THEN -- PTPPLP
           vnomreport := 'alctr652';
        ELSIF pprovis = 9 THEN -- PTIBNR
           vnomreport := 'alctr653';
        ELSIF pprovis = 10 THEN -- PESTAB
           vnomreport := 'alctr654';
        ELSIF pprovis = 11 THEN -- PTPBEX
           vnomreport := 'alctr656';
        ELSIF pprovis = 12 THEN -- PPPC
           vnomreport := 'alctr655';
        ELSIF pprovis = 13 THEN -- LDG
           vnomreport := 'alctr657';
        END IF;
*/
      BEGIN
         SELECT creport
           INTO vnomreport
           FROM codprovisiones
          WHERE cprovis = pprovis;
      EXCEPTION
         WHEN OTHERS THEN
            vnomreport := NULL;
      END;

      vpasexec := 9;
      -- Se busca la parte com¿n de la cadena para lanzar el report
      vcadena := pac_md_menu.f_get_urlreports(vnomreport, mensajes);

      IF vcadena IS NULL THEN
         RAISE e_object_error;
      END IF;

      -- Se completa la cadena para lanzar el report
      vcadena := vcadena || '&' || 'REPORT=' || vnomreport || '&' || 'DESTYPE=CACHE' || '&'
                 || 'DESFORMAT=PDF' || '&' || 'P_USU_IDIOMA=' || pac_md_common.f_get_cxtidioma
                 || '&' || 'P_MESANYO=' || vfecha || '&' || 'P_CEMPRES=' || pempresa || '&'
                 || 'P_EMPRESA=' || pempresa || '&' || 'P_MONEDA='
                 || pac_md_common.f_get_parinstalacion_n('MONEDAINST') || '&' || 'P_AGENTE='
                 || pcagente || '&' || 'P_SUBAGENTE=' || psubagente || '&' || 'P_SPROCES='
                 || vsproces || '&' || 'P_USER=' || f_user;

      -- Para el listado de provisiones PM, se necesita un par¿metro m¿s, si se solicita un previo
      IF pprovis = 99
         AND NVL(pprevio, 1) = 1 THEN
         vcadena := vcadena || '&' || 'P_PREVIO=1';
      END IF;

      RETURN vcadena;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, NULL,
                                           SQLCODE, SQLERRM);
         RETURN NULL;
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
      fichero IN OUT VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
                   := 'cmaps: ' || cmaps || ' pfecha: ' || pfecha || ' pcempres: ' || pcempres;
      vobject        VARCHAR2(200) := 'PAC_MD_PROVISIONES.f_llama_multimap_provis';
      RESULT         NUMBER := 0;
      param_map      VARCHAR2(100);
      v_sproces      NUMBER;
   BEGIN
      IF cmaps IS NULL
         OR pfecha IS NULL THEN
         RAISE e_param_error;
      END IF;

      SELECT MAX(sproces)
        INTO v_sproces
        FROM cierres
       WHERE cempres = pcempres
         AND ctipo = 3
         AND fperfin = TO_DATE(pfecha, 'ddmmyyyy');

      IF v_sproces IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9900946);
         RAISE e_object_error;
      END IF;

      param_map := pfecha || '|' || TO_CHAR(v_sproces) || '|' || pcempres || '|||||';
      fichero := pac_md_map.f_ejecuta_multimap(cmaps, param_map, mensajes);

      IF fichero IS NULL THEN
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
      mensajes IN OUT t_iax_mensajes)
      RETURN VARCHAR2 IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'psseguro: ' || psseguro || ' pnriesgo: ' || pnriesgo || ' pcgarant: ' || pcgarant
            || ' pnmovimi: ' || pnmovimi || ' pfecha: ' || pfecha;
      vobject        VARCHAR2(200) := 'PAC_MD_PROVISIONES.f_detalle_PU';
      cur            sys_refcursor;
      squery         VARCHAR2(1000);
      vnmovimi       NUMBER;
      vnriesgo       NUMBER := 1;
      vfecha         DATE;
   BEGIN
      IF psseguro IS NULL
         OR pcgarant IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;

      SELECT   MAX(nmovimi), fefecto
          INTO vnmovimi, vfecha
          FROM movseguro
         WHERE sseguro = psseguro
           AND ROWNUM = 1
      GROUP BY fefecto;

      SELECT MAX(nriesgo)
        INTO vnriesgo
        FROM riesgos
       WHERE sseguro = psseguro;

      squery :=
         'select g.tgarant tgarant, d.finiefe finiefe, d.ndetgar ndetgar, d.icapital icapital, d.iprianu iprianu,
         pac_isqlfor.f_provisio_actual(d.sseguro, ''IPROVRES'', to_date('''
         || NVL(pfecha, vfecha)
         || ''',''dd/mm/rr''), d.cgarant,d.ndetgar) iprovres
         from detgaranseg d, garangen g where
         d.sseguro='
         || psseguro || ' and d.nriesgo=' || NVL(pnriesgo, vnriesgo) || ' and d.cgarant='
         || pcgarant
         || '
         and d.nmovimi = (select max (d2.nmovimi) from detgaranseg d2 where d2.sseguro=d.sseguro and d2.nriesgo=d.nriesgo and d2.cgarant=d.cgarant
         and d2.ndetgar=d.ndetgar) and g.cgarant=d.cgarant  and g.cidioma='
         || pac_md_common.f_get_cxtidioma || ' order by ndetgar';
      RETURN squery;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, NULL,
                                           SQLCODE, SQLERRM);
         RETURN NULL;
   END f_detalle_pu;

   -- 2.0 - 13/03/2014 - MMM - 0028929: LCOL_F003-0009973: Error al descargar archivo AMOCOM - Inicio
   /*************************************************************************
      Llama al PAC_MAP para ejecutar N maps que pasasmos en pprovis separados por @
        param in cmaps: Tipo car¿cter. Ids. de los maps. separados por '@'
        param in Pfecha: Tipo car¿cter. fecha de calculo en formato ddmmyyyy
        param in Pcempres: Tipo car¿cter. CEMPRESA
        param out MENSAJES: Tipo t_iax_mensajes. Par¿metro de Salida. Mensaje de error
        return             : Retorna un NUMERICO 0 ok / 1 KO
   *************************************************************************/
   FUNCTION f_llama_multimap_provis_batch(
      cmaps IN VARCHAR2,
      pfecha IN VARCHAR2,
      pcempres IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
                   := 'cmaps: ' || cmaps || ' pfecha: ' || pfecha || ' pcempres: ' || pcempres;
      vobject        VARCHAR2(200) := 'PAC_MD_PROVISIONES.f_llama_multimap_provis_batch';
      RESULT         NUMBER := 0;
      param_map      VARCHAR2(100);
      v_sproces      NUMBER;
      num_err        NUMBER;
      v_titulo       VARCHAR2(200);
      vidioma        NUMBER;
      v_spoces       NUMBER;
      vsproces       NUMBER;
      v_plsql        VARCHAR2(4000);
      v_cestado      cierres.cestado%TYPE;   -- 3.0 - 02/05/2014 - MMM - 0028929: LCOL_F003-0009973: Error al descargar archivo AMOCOM
      v_text         VARCHAR2(100);   -- 3.0 - 02/05/2014 - MMM - 0028929: LCOL_F003-0009973: Error al descargar archivo AMOCOM
   BEGIN
      IF cmaps IS NULL
         OR pfecha IS NULL THEN
         RAISE e_param_error;
      END IF;

      -- 3.0 - 02/05/2014 - MMM - 0028929: LCOL_F003-0009973: Error al descargar archivo AMOCOM - Inicio

      --SELECT MAX(sproces)
      --  INTO v_sproces
      SELECT MAX(sproces), MAX(cestado)
        INTO v_sproces, v_cestado
        -- 3.0 - 02/05/2014 - MMM - 0028929: LCOL_F003-0009973: Error al descargar archivo AMOCOM - Final
      FROM   cierres
       WHERE cempres = pcempres
         AND ctipo = 3
         AND fperfin = TO_DATE(pfecha, 'ddmmyyyy');

      IF v_sproces IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9900946);
         RAISE e_object_error;
      END IF;

      param_map := pfecha || '|' || TO_CHAR(v_sproces) || '|' || pcempres || '|||||';
      vpasexec := 30;
      vidioma := pac_md_common.f_get_cxtidioma;
      v_titulo := f_axis_literales(9001551, vidioma);
      vpasexec := 40;
      v_titulo := v_titulo || ' ' || f_axis_literales(101619, vidioma) || ' ' || pcempres;
      vpasexec := 50;
      num_err := f_procesini(f_user, pcempres, 'PROVISIONES', v_titulo, vsproces);

      DECLARE
         FUNCTION f_nulos(p_camp IN VARCHAR2, p_tip IN NUMBER DEFAULT 1)
            RETURN VARCHAR2 IS
         BEGIN
            vpasexec := 60;

            IF p_camp IS NULL THEN
               RETURN ' null';
            ELSE
               IF p_tip = 2 THEN
                  RETURN ' to_date(' || CHR(39) || p_camp || CHR(39) || ',''ddmmyyyy'')';
               ELSE
                  RETURN ' ' || CHR(39) || p_camp || CHR(39);
               END IF;
            END IF;
         END;
      BEGIN
         vpasexec := 70;

         -- 3.0 - 02/05/2014 - MMM - 0028929: LCOL_F003-0009973: Error al descargar archivo AMOCOM - Inicio
         IF v_cestado = 1 THEN
            v_text := '/*real*/';
         ELSE
            v_text := '/*previo*/';
         END IF;

         -- 3.0 - 02/05/2014 - MMM - 0028929: LCOL_F003-0009973: Error al descargar archivo AMOCOM - Final
         -- Con la comparaci¿n "what LIKE v_text" controlamos que no se ejecute un listado cuando ya se est¿
         -- haciendo uno del mismo tipo. Pero s¿ permitir¿a lanzar un previo, cuando hay un real y viceversa.
         SELECT COUNT(1)
           INTO num_err
           -- 3.0 - 02/05/2014 - MMM - 0028929: LCOL_F003-0009973: Error al descargar archivo AMOCOM - Inicio
           -- FROM user_jobs
         FROM   dba_jobs
          --WHERE UPPER(what) LIKE 'PAC_MD_PROVISIONES.P_LISTAR_PROVISIONES%';
         WHERE  UPPER(what) LIKE '%PAC_MD_PROVISIONES.P_LISTAR_PROVISIONES%'
            AND what LIKE '%' || v_text || '%';

         -- 3.0 - 02/05/2014 - MMM - 0028929: LCOL_F003-0009973: Error al descargar archivo AMOCOM - Fin
         IF num_err > 0 THEN
            -- Ya existe un proceso de informe activo
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9905979);
            RAISE e_object_error;
         END IF;

         --v_plsql := 'DECLARE num_err NUMBER; begin ' || CHR(10)
         v_plsql := 'DECLARE num_err NUMBER; begin ' || v_text || CHR(10)
                    || 'num_err:= pac_contexto.f_inicializarctx(' || CHR(39) || f_user
                    || CHR(39) || ');' || CHR(10) || 'PAC_MD_PROVISIONES.P_LISTAR_PROVISIONES('
                    || f_nulos(cmaps) || ', ' || f_nulos(param_map) || ', '
                    || f_nulos(pcempres) || ',' || vsproces || ');' || CHR(10) || ' end;';
         vpasexec := 80;
         num_err := pac_jobs.f_ejecuta_job(NULL, v_plsql, NULL);

         IF num_err > 0 THEN
            p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, ' men=' || num_err);
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 6, num_err);
            RETURN 1;
         ELSE
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 0,
                                                 f_axis_literales(9904687, vidioma) || ' '
                                                 || vsproces);
            RETURN 0;
         END IF;
      EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam || ' men=' || num_err,
                        SQLCODE || ' ' || SQLERRM);
            pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                              psqcode => SQLCODE, psqerrm => SQLERRM);
            RETURN 1;
      END;

      RETURN 0;
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
   END f_llama_multimap_provis_batch;

   PROCEDURE p_listar_provisiones(
      pcmaps IN VARCHAR2,
      pparam_map IN VARCHAR2,
      pcempres IN VARCHAR2,
      psproces IN NUMBER) IS
      pficheros      VARCHAR2(4000);
      mensajes       t_iax_mensajes;
      vpasexec       NUMBER := 1;
      vobj           VARCHAR2(200) := 'P_LISTAR_PROVISIONES';
      verror         NUMBER;
      v_numlin       NUMBER;
      num_err        NUMBER;
      v_ttexto       VARCHAR2(1000);
      vidioma        NUMBER;
      v_llinia       NUMBER;
      --  INICIO - Variables para el envio de correo
      v_subject      desmensaje_correo.asunto%TYPE;
      v_from         mensajes_correo.remitente%TYPE;
      v_texto        desmensaje_correo.cuerpo%TYPE;
      pscorreo       mensajes_correo.scorreo%TYPE;
      v_to           VARCHAR2(250);
      v_to2          VARCHAR2(250);
      v_errcor       log_correo.error%TYPE;
      v_plsql        VARCHAR2(4000);
      vconn          UTL_SMTP.connection;
      v_lob          BLOB;
      v_buffer_size  INTEGER := 57;
      v_offset       NUMBER := 1;
      v_raw          RAW(32767);
      v_length       NUMBER := 0;
      fichero        BFILE;
      v_path         VARCHAR2(2000);
      v_filename     VARCHAR2(2000);
      vcempres       NUMBER;
      vtimp          t_iax_impresion;
      vobimp         ob_iax_impresion := ob_iax_impresion();
      v_pos_map      NUMBER;
      v_tmp_ficheros VARCHAR2(4000);
      v_fichero      VARCHAR2(1000);
      vparam         VARCHAR2(4000);
   -- FIN - Variables para el envio de correo
   BEGIN
      vparam := 'cmaps: ' || pcmaps || ' pparam_map: ' || pparam_map || ' pcempres: '
                || pcempres;
      vidioma := pac_md_common.f_get_cxtidioma;
      vcempres := pcempres;

      IF vcempres IS NULL THEN
         vcempres := pac_md_common.f_get_cxtempresa;
      END IF;

      pficheros := pac_md_map.f_ejecuta_multimap(pcmaps, pparam_map, mensajes);
      vpasexec := 1;

      IF pficheros IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);   -- error interno.
         v_ttexto := f_axis_literales(num_err, vidioma);
         num_err := f_proceslin(psproces, v_ttexto, 0, v_llinia);
         RAISE e_object_error;
      ELSE
         vtimp := t_iax_impresion();
         v_tmp_ficheros := pficheros;
         v_pos_map := INSTR(v_tmp_ficheros, '@', 1);

         WHILE v_pos_map > 1 LOOP
            v_fichero := SUBSTR(v_tmp_ficheros, 1, v_pos_map - 1);   -- extraigo el primero
            v_tmp_ficheros := SUBSTR(v_tmp_ficheros, v_pos_map + 1);   -- reduzco el string
            vtimp.EXTEND;
            vobimp.fichero := v_fichero;
            vobimp.descripcion := v_fichero;
            vtimp(vtimp.LAST) := vobimp;
            v_pos_map := INSTR(v_tmp_ficheros, '@', 1);
         END LOOP;
      END IF;

      /* ************************** *
      * Inici - Enviament del mail *
      * ************************** */

      -- Obtenemos el scorreo
      vpasexec := 10;

      BEGIN
         SELECT MAX(scorreo)
           INTO pscorreo
           FROM mensajes_correo
          WHERE ctipo = 16;
      EXCEPTION
         WHEN OTHERS THEN
            v_ttexto := f_axis_literales('151425', vidioma);   --No existe ningun correo de este tipo
            num_err := f_proceslin(psproces, v_ttexto, 0, v_llinia);
            RAISE e_object_error;
      END;

      -- Obtenemos el asunto
      vpasexec := 20;
      num_err := pac_correo.f_asunto(pscorreo, vidioma, v_subject, NULL, NULL, NULL);

      IF v_subject IS NULL
         OR num_err <> 0 THEN
         v_ttexto := f_axis_literales('151422', vidioma);   --No esixte ning¿n Subject para este tipo de correo.
         num_err := f_proceslin(psproces, v_ttexto, 0, v_llinia);
         RAISE e_object_error;
      END IF;

      --Obtenemos el origen
      vpasexec := 30;
      num_err := pac_correo.f_origen(pscorreo, v_from);

      IF num_err <> 0 THEN
         v_ttexto := f_axis_literales(num_err, vidioma);   --No esixte ning¿n correo de este tipo.
         num_err := f_proceslin(psproces, v_ttexto, 0, v_llinia);
         RAISE e_object_error;
      END IF;

      --Obtenemos el destinatario (usuario guardado en procesoscab en el momento de lanzar el BATCH)
      vpasexec := 40;

      SELECT cusuari
        INTO v_to
        FROM procesoscab
       WHERE sproces = psproces;

      IF v_to IS NOT NULL THEN
         v_to2 := v_to;
         v_to := v_to || NVL(pac_parametros.f_parempresa_t(vcempres, 'DOM_MAIL'), '');
      ELSE
         v_to := f_user || NVL(pac_parametros.f_parempresa_t(vcempres, 'DOM_MAIL'), '');
         v_to2 := f_user;
      END IF;

      -- Obtenemos el cuerpo del correo
      vpasexec := 50;
      num_err := pac_correo.f_cuerpo(pscorreo, vidioma, v_texto, NULL, NULL);

      IF v_texto IS NULL
         OR num_err <> 0 THEN
         v_ttexto := f_axis_literales('152556', vidioma);   --Error en el cuerpo del mensaje
         num_err := f_proceslin(psproces, v_ttexto, 0, v_llinia);
         RAISE e_object_error;
      END IF;

      -- A¿ADIMOS TODOS LOS DOCUMENTOS
      vpasexec := 60;
      v_texto := v_texto || CHR(10);

      FOR i IN vtimp.FIRST .. vtimp.LAST LOOP
         v_texto := v_texto || CHR(10) || vtimp(i).fichero;
      END LOOP;

      BEGIN
         --Inici bug 27699 - 07/10/2013 - RCL
         vpasexec := 80;
         vconn := pac_send_mail.begin_mail(sender => v_from, recipients => v_to,
                                           subject => v_subject,
                                           mime_type => pac_send_mail.multipart_mime_type);
         vpasexec := 90;
         pac_send_mail.attach_text(conn => vconn, DATA => v_texto, mime_type => 'text/html');
         vpasexec := 100;

         FOR i IN vtimp.FIRST .. vtimp.LAST LOOP
            BEGIN
               v_path := f_parinstalacion_t('INFORMES_C');
               v_filename := REPLACE(vtimp(i).fichero, v_path || '\');
               pac_send_mail.begin_attachment(conn => vconn, mime_type => 'text/html',
                                              inline => TRUE, filename => v_filename,
                                              transfer_enc => 'base64');
               fichero := BFILENAME('UTLDIR', v_filename);
               DBMS_LOB.createtemporary(v_lob, FALSE);
               DBMS_LOB.fileopen(fichero, DBMS_LOB.file_readonly);
               DBMS_LOB.loadfromfile(v_lob, fichero, DBMS_LOB.getlength(fichero));
               v_length := DBMS_LOB.getlength(v_lob);

               WHILE v_offset < v_length LOOP
                  DBMS_LOB.READ(v_lob, v_buffer_size, v_offset, v_raw);

                  IF v_offset + v_buffer_size > v_length THEN
                     UTL_SMTP.write_raw_data
                                       (vconn,
                                        UTL_ENCODE.base64_encode(UTL_RAW.SUBSTR(v_raw, 1,
                                                                                (v_length
                                                                                 -(v_offset - 1)))));
                  ELSE
                     UTL_SMTP.write_raw_data(vconn, UTL_ENCODE.base64_encode(v_raw));
                  END IF;

                  UTL_SMTP.write_data(vconn, UTL_TCP.crlf);
                  v_offset := v_offset + v_buffer_size;
               END LOOP while_loop;

               v_offset := 1;
               v_length := 0;
               v_buffer_size := 57;
               v_raw := NULL;
               pac_send_mail.end_attachment(vconn);
               DBMS_LOB.CLOSE(fichero);
            EXCEPTION
               WHEN OTHERS THEN
                  v_ttexto := f_axis_literales('103187', vidioma);   --Error al leer el fichero
                  num_err := f_proceslin(psproces,
                                         SUBSTR(v_ttexto || ' SQLCODE=' || SQLCODE, 1, 120),
                                         0, v_llinia);
                  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000001, vpasexec, vparam,
                                                    psqcode => SQLCODE, psqerrm => SQLERRM);
            END;
         END LOOP;

         vpasexec := 110;
         pac_send_mail.end_mail(conn => vconn);
         vpasexec := 120;
         v_errcor := '0';
      EXCEPTION
         WHEN OTHERS THEN
            v_ttexto := f_axis_literales('1000610', vidioma);   --Error al enviar el fichero
            num_err := f_proceslin(psproces,
                                   SUBSTR(v_ttexto || ' SQLCODE=' || SQLCODE, 1, 120), 0,
                                   v_llinia);
            RAISE e_object_error;
      END;

      vpasexec := 130;
      pac_correo.p_log_correo(f_sysdate, v_to, f_user, v_subject, v_errcor, NULL, NULL);
      /* *********************** *
       * Fi - Enviament del mail *
       * *********************** */
      num_err := f_procesfin(psproces, 0);
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobj, vpasexec, vparam || ' emp=' || vcempres,
                     SQLCODE || ' ' || SQLERRM);

         IF psproces IS NOT NULL THEN
            verror := f_proceslin(psproces,
                                  SUBSTR('ERROR ' || vobj || ' ' || SQLCODE || '-' || verror
                                         || '-' || vpasexec,
                                         1, 120),
                                  0, v_numlin, 2);
         END IF;

         COMMIT;
   END p_listar_provisiones;
-- 2.0 - 13/03/2014 - MMM - 0028929: LCOL_F003-0009973: Error al descargar archivo AMOCOM - Fin

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
      vobjectname    VARCHAR2(500) := 'PAC_MD_PROVISIONES.f_grabar_exclusiones';
      vpasexec       NUMBER(5) := 1;
      vparam         VARCHAR2(1000) := 'par¿metros - ' || 'pnpoliza: ' || pnpoliza || ' pnrecibo: ' || pnrecibo || ' pcobservexc: ' || pcobservexc
                                        || ' pcprovisi: ' || pcprovisi || ' pcobservp: ' || pcobservp || ' pcnprovisi: ' || pcnprovisi
                                        || ' pcobservnp: ' || pcobservnp || ' pfalta: ' || pfalta || ' pfbaja: ' || pfbaja;
      verrores       t_ob_error;

       BEGIN
          IF pnpoliza IS NULL THEN
             vparam := vparam || ' pnpoliza =' || pnpoliza;
             RAISE e_param_error;
          END IF;

          vnumerr := pac_provisiones.f_grabar_exclusiones(pnpoliza, pnrecibo, pcobservexc, pcprovisi, pcobservp,
                                                         pcnprovisi, pcobservnp, pfalta, pfbaja, mensajes);

          IF vnumerr = 1 THEN
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
       END f_grabar_exclusiones;


   /**********************************************************************
      FUNCTION F_DEL_EXCLUSIONES
      Funci¿n que elimina de la exclusion por numero de poliza
      Param IN pnpoliza: npoliza
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
          vobject        VARCHAR2(200) := 'PAC_MD_PROVISIONES.f_del_exclusiones';
       BEGIN

          IF pnpoliza IS NULL THEN
             vparam := vparam || ' pnpoliza =' || pnpoliza;
             RAISE e_param_error;
          END IF;

          vnumerr := pac_provisiones.f_del_exclusiones(pnpoliza, pnrecibo);

          IF vnumerr = 1 THEN
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
          mensajes IN OUT T_IAX_MENSAJES)
         RETURN VARCHAR2 IS
        vpasexec       NUMBER(8) := 1;
        vparam         VARCHAR2(200) := 'pcsucursal: ' || pcsucursal || ' pfdesde: ' || pfdesde || ' pfhasta: ' || pfhasta
          || ' pnpoliza: ' || pnpoliza || ' pnrecibo: ' || pnrecibo || ' pnit: ' || pnit
          || ' pnnumide: ' || pnnumide || ' pcagente: ' || pcagente;
        vobject        VARCHAR2(200) := 'PAC_MD_PROVISIONES.f_get_exclusiones';
        squery         VARCHAR2(1000);
       BEGIN
          squery := pac_provisiones.f_get_exclusiones(pcsucursal, pfdesde, pfhasta, pnpoliza, pnrecibo,
                                                pnit, pnnumide, pcagente);
          RETURN squery;
       EXCEPTION
          WHEN OTHERS THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, NULL,
                                               SQLCODE, SQLERRM);
             RETURN NULL;
      END f_get_exclusiones;


   /**********************************************************************
      FUNCTION F_GET_EXCLUSIONESBYPK
      Funci¿n que retorna todas las exclusiones existentes de acuerdo a la
      consulta.
      Param IN  pnpoliza    : npoliza
      Param IN  pnrecibo    : nrecibo
      Param OUT PRETCURSOR  : SYS_REF_CURSOR
     **********************************************************************/
      FUNCTION f_get_exclusionesbypk(
          pnpoliza IN NUMBER,
          pnrecibo IN NUMBER,
          mensajes IN OUT T_IAX_MENSAJES)
         RETURN VARCHAR2 IS
        vpasexec       NUMBER(8) := 1;
        vparam         VARCHAR2(200) := 'pnpoliza: ' || pnpoliza || ' pnrecibo: ' || pnrecibo;
        vobject        VARCHAR2(200) := 'PAC_MD_PROVISIONES.f_get_exclusionesbypk';
        squery         VARCHAR2(1000);
       BEGIN
          squery := pac_provisiones.f_get_exclusionesbypk(pnpoliza, pnrecibo);
          RETURN squery;
       EXCEPTION
          WHEN OTHERS THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, NULL,
                                               SQLCODE, SQLERRM);
             RETURN NULL;
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
         RETURN VARCHAR2 IS
        vpasexec       NUMBER(8) := 1;
        vparam         VARCHAR2(200) := 'pnpoliza: ' || pnpoliza || ' pnrecibo: ' || pnrecibo;
        vobject        VARCHAR2(200) := 'PAC_MD_PROVISIONES.f_get_existepolizarecibo';
        squery         VARCHAR2(1000);
       BEGIN
          squery := pac_provisiones.f_get_existepolizarecibo(pnpoliza, pnrecibo);
          RETURN squery;
       EXCEPTION
          WHEN OTHERS THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, NULL,
                                               SQLCODE, SQLERRM);
             RETURN NULL;
      END f_get_existepolizarecibo;
END pac_md_provisiones;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_PROVISIONES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_PROVISIONES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_PROVISIONES" TO "PROGRAMADORESCSI";
