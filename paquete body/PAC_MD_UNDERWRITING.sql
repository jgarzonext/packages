--------------------------------------------------------
--  DDL for Package Body PAC_MD_UNDERWRITING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MD_UNDERWRITING" IS
   /******************************************************************************
      NOMBRE:       PAC_MD_UNDERWRITING
      PROPÃ“SITO: Recupera la informaciÃ³n de la poliza guardada en la base de datos
                     a un nivel independiente.

      REVISIONES:
      Ver        Fecha        Autor             DescripciÃ³n
      ---------  ----------  ---------------  ------------------------------------
      1.0        10/06/2015   RSC             1. Creación del package.
      1.1        29/07/2015    IGIL           2. Creacion funciones para insertar , editar , eliminar
                                                  citas medicas y traer las evidencias medicas
   ******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   FUNCTION f_connect_undw_if01(
      pcaseid IN NUMBER,
      pcempres IN NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      pfefecto IN DATE,
      ptablas IN VARCHAR2 DEFAULT 'EST',
      mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_underwrt_if01 IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100)
              := 'psseguro=' || psseguro || ' pnriesgo=' || pnriesgo || ' ptablas=' || ptablas;
      vobject        VARCHAR2(200) := 'PAC_MD_UNDERWRITING.f_connect_undw_if01';
      vurl           ob_iax_underwrt_if01;
   BEGIN
      vurl := pac_underwriting.f_connect_undw_if01(pcaseid, pcempres, psseguro, pnriesgo,
                                                   pnmovimi, pfefecto, ptablas);
      RETURN vurl;
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
   END f_connect_undw_if01;

   FUNCTION f_connect_undw_if02(
      pcaseid IN NUMBER,
      pcempres IN NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      pfefecto IN DATE,
      ptablas IN VARCHAR2 DEFAULT 'EST',
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100)
              := 'psseguro=' || psseguro || ' pnriesgo=' || pnriesgo || ' ptablas=' || ptablas;
      vobject        VARCHAR2(200) := 'PAC_MD_UNDERWRITING.f_connect_undw_if02';
      vres           NUMBER;
   BEGIN
      vres := pac_underwriting.f_connect_undw_if02(pcaseid, pcempres, psseguro, pnriesgo,
                                                   pnmovimi, pfefecto, ptablas);
      RETURN vres;
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
   END f_connect_undw_if02;

   FUNCTION f_activo_undw_if01(
      psproduc IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'EST',
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100) := 'psproduc=' || psproduc;
      vobject        VARCHAR2(200) := 'PAC_MD_UNDERWRITING.f_connect_undw_if01';
      vsproduc       NUMBER;
      v_crespue_1956 pregunpolseg.crespue%TYPE;
      v_res          NUMBER;
      vmodifprop     BOOLEAN;
      vcuenta        NUMBER;
   BEGIN
      v_res := pac_preguntas.f_get_pregunpolseg(pac_iax_produccion.vsolicit, 1956, 'EST',
                                                v_crespue_1956);
      /*Comentado por CChaverra : Bug: 40538 226408*/
      /*
      IF     NVL (f_parproductos_v (psproduc, 'WS_UNDERWRITING'), 0) = 1
         AND NOT pac_iax_produccion.issimul
         AND v_crespue_1956 = 0
         AND NOT pac_iax_produccion.ismodifprop THEN
         RETURN 1;
      END IF;
      */
      vmodifprop := pac_iax_produccion.ismodifprop;

      SELECT COUNT(*)
        INTO vcuenta
        FROM pds_estsegurosupl
       WHERE sseguro = pac_iax_produccion.vsolicit;

      IF vmodifprop THEN
         IF vcuenta = 0 THEN
            vmodifprop := FALSE;
         END IF;
      END IF;

      IF NVL(f_parproductos_v(psproduc, 'WS_UNDERWRITING'), 0) = 1
         AND NOT pac_iax_produccion.issimul
         AND NVL(v_crespue_1956, 0) = 0
         AND NOT vmodifprop
         AND NOT pac_iax_produccion.issuplem THEN
         RETURN 1;
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
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_activo_undw_if01;

   /*************************************************************************
     funcion que retorna la lista de enfermedades relacionadas de Allfinanz
   *************************************************************************/
   FUNCTION f_get_icd10codes(
      psseguro IN seguros.sseguro%TYPE,
      pnmovimi IN movseguro.nmovimi%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      --
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(100)
                       := 'parametros - psseguro = ' || psseguro || ' pnmovimi = ' || pnmovimi;
      vobject        VARCHAR2(50) := 'PAC_MD_UNDERWRITING.f_get_icd10codes';
      v_cur          sys_refcursor;
      vsquery        VARCHAR2(4000);
      vnumerr        NUMBER := 0;
   --
   BEGIN
      --
      vsquery := 'SELECT d.cindex, d.codenf, d.desenf, 1 origen '
                 || 'FROM enfermedades_undw d ' || 'WHERE d.sseguro = ' || psseguro
                 || ' AND d.nmovimi  = ' || pnmovimi || ' AND d.nriesgo  = 1'
                 || ' AND d.cempres =  pac_md_common.f_get_cxtempresa() ' || ' UNION '
                 || 'SELECT e.cindex, e.codenf, e.desenf, 2 origen '
                 || 'FROM enfermedades_base e ' || 'ORDER BY origen ASC';
      --
      vnumerr := pac_md_log.f_log_consultas(vsquery, 'PAC_MD_UNDERWRITING.f_get_icd10codes',
                                            1, 1, mensajes);
      --
      v_cur := pac_md_listvalores.f_opencursor(vsquery, mensajes);
      --
      RETURN v_cur;
   EXCEPTION
      --
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         --
         IF v_cur%ISOPEN THEN
            CLOSE v_cur;
         END IF;

         --
         RETURN NULL;
   END f_get_icd10codes;

   /*************************************************************************
     funcion que guarda las enfermedades relacionadas al rechazar un seguro
   *************************************************************************/
   FUNCTION f_setrechazo_icd10codes(
      psseguro IN seguros.sseguro%TYPE,
      pnmovimi IN movseguro.nmovimi%TYPE,
      pcindex IN t_iax_info,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      --
      vpasexec       NUMBER(5) := 1;
      vobjectname    VARCHAR2(500) := 'PAC_MD_UNDERWRITING.f_setrechazo_icd10codes';
      vparam         VARCHAR2(1000)
                         := 'parámetros - psseguro : ' || psseguro || ' pnmovimi ' || pnmovimi;
      verror         NUMBER := 0;
   --
   BEGIN
      --
      verror := pac_underwriting.f_setrechazo_icd10codes(psseguro, pnmovimi, pcindex,
                                                         mensajes);

      --
      IF verror <> 0 THEN
         RAISE e_object_error;
      END IF;

      --
      RETURN verror;
   EXCEPTION
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_setrechazo_icd10codes;

   /*************************************************************************
       Recupera la lista de evidencias medicas
       param out mensajes  : mensajes de error
       return              : cursor
    *************************************************************************/
   FUNCTION f_get_evidences(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := ' ';
      vobject        VARCHAR2(200) := 'PAC_UNDERWRITING.f_get_evidences';
      vquery         VARCHAR2(2000);
   BEGIN
      RETURN pac_underwriting.f_get_evidences(mensajes);
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
   END f_get_evidences;

   FUNCTION f_insert_citasmedicas(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      psperaseg IN NUMBER,
      pspermed IN NUMBER,
      pceviden IN NUMBER,
      pfeviden IN DATE,
      pcestado IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'EST',
      pieviden IN NUMBER,
      pcpago IN NUMBER,
      pnorden_r OUT NUMBER,
      pcais IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := ' psseguro=' || psseguro || ' pnriesgo=' || pnriesgo || ' pnmovimi=' || pnmovimi
            || ' psperaseg=' || psperaseg || ' pspermed=' || pspermed || ' pceviden='
            || pceviden || ' pfeviden=' || pfeviden || ' pcestado=' || pcestado || ' ptablas='
            || ptablas || ' pieviden=' || pieviden || ' pcpago=' || pcpago;
      vobject        VARCHAR2(200) := 'PAC_MD_UNDERWRITING.f_insert_citasmedicas';
   BEGIN
      RETURN pac_underwriting.f_insert_citasmedicas(psseguro, pnriesgo, pnmovimi, psperaseg,
                                                    pspermed, pceviden, pfeviden, pcestado,
                                                    ptablas, pieviden, pcpago, pnorden_r,
                                                    pcais, mensajes);
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_insert_citasmedicas;

   FUNCTION f_edit_citasmedicas(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      psperaseg IN NUMBER,
      pspermed IN NUMBER,
      pceviden IN NUMBER,
      pfeviden IN DATE,
      pcestado IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'EST',
      pieviden IN NUMBER,
      pcpago IN NUMBER,
      pnorden_r IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := ' psseguro=' || psseguro || ' pnriesgo=' || pnriesgo || ' pnmovimi=' || pnmovimi
            || ' psperaseg=' || psperaseg || ' pspermed=' || pspermed || ' pceviden='
            || pceviden || ' pfeviden=' || pfeviden || ' pcestado=' || pcestado || ' ptablas='
            || ptablas || ' pieviden=' || pieviden || ' pcpago=' || pcpago || ' pnorden_r='
            || pnorden_r;
      vobject        VARCHAR2(200) := 'PAC_MD_UNDERWRITING.f_edit_citasmedicas';
   BEGIN
      RETURN pac_underwriting.f_edit_citasmedicas(psseguro, pnriesgo, pnmovimi, psperaseg,
                                                  pspermed, pceviden, pfeviden, pcestado,
                                                  ptablas, pieviden, pcpago, pnorden_r,
                                                  mensajes);
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_edit_citasmedicas;

   FUNCTION f_delete_citasmedicas(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      psperaseg IN NUMBER,
      pceviden IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'EST',
      pnorden_r IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := ' psseguro=' || psseguro || ' pnriesgo=' || pnriesgo || ' pnmovimi=' || pnmovimi
            || ' psperaseg=' || psperaseg || ' pceviden=' || pceviden || ' ptablas='
            || ptablas || ' pnorden_r=' || pnorden_r;
      vobject        VARCHAR2(200) := 'PAC_MD_UNDERWRITING.f_delete_citasmedicas';
   BEGIN
      RETURN pac_underwriting.f_delete_citasmedicas(psseguro, pnriesgo, pnmovimi, psperaseg,
                                                    pceviden, ptablas, pnorden_r, mensajes);
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_delete_citasmedicas;
END pac_md_underwriting;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_UNDERWRITING" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_UNDERWRITING" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_UNDERWRITING" TO "PROGRAMADORESCSI";
