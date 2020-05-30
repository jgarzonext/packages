CREATE OR REPLACE PACKAGE BODY pac_md_sin_imp_sap AS
   /******************************************************************************
      NOMBRE:    PAC_MD_SIN_IMP_SAP
      PROP¿SITO: Funciones para calculo de impuestos

      REVISIONES:
      Ver        Fecha        Autor             Descripci¿n
      ---------  ----------  ---------------  ------------------------------------
       1.0       13/08/2013   NSS             Creacion
       2.0       18/01/2019   WAJ            Insertar codigo impuesto segun tipo de vinculacion
   ******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   /*************************************************************************
      Abre un cursor con la sentencia suministrada
      param in squery    : consulta a executar
      param out mensajes : mesajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_opencursor(squery   IN VARCHAR2,
                         mensajes IN OUT t_iax_mensajes) RETURN SYS_REFCURSOR IS
      cur      SYS_REFCURSOR;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(4000) := SUBSTR(squery, 1, 1900);
      vobject  VARCHAR2(200) := 'pac_md_sin_imp_sap.F_OpenCursor';
      terror   VARCHAR2(200) := 'No se puede recuperar la informaci¿n';
   BEGIN
      OPEN cur FOR squery;

      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           terror,
                                           SQLCODE,
                                           SQLERRM);

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_opencursor;

   FUNCTION f_get_lstimpuestos(mensajes IN OUT t_iax_mensajes)
      RETURN SYS_REFCURSOR IS
      /************************************************************************************
               Recupera los conceptos de recibo dados de alta para una empresa
      ************************************************************************************/
      vobjectname VARCHAR2(500) := 'pac_md_sin_imp_sap.f_get_lstimpuestos';
      vparam      VARCHAR2(500) := '  ';
      vpasexec    NUMBER(5) := 1;
      vnumerr     NUMBER(8) := 0;
      cur         SYS_REFCURSOR;
      vquery      VARCHAR2(5000);
   BEGIN
      vnumerr := pac_sin_imp_sap.f_get_lstimpuestos(pac_md_common.f_get_cxtempresa(),
                                                    pac_md_common.f_get_cxtidioma(),
                                                    vquery);

      IF vnumerr <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      cur := f_opencursor(vquery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobjectname,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           vnumerr,
                                           SQLCODE,
                                           SQLERRM);

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstimpuestos;

   FUNCTION f_get_tipos_indicador(pccodimp IN NUMBER, pcarea IN NUMBER,
                                  mensajes IN OUT t_iax_mensajes)
      RETURN SYS_REFCURSOR IS
      /************************************************************************************
               Devuelve los tipos de indicador para el impuesto indicado
      ************************************************************************************/
      vobjectname VARCHAR2(500) := 'pac_md_sin_imp_sap.f_get_tipos_indicador';
      vparam      VARCHAR2(500) := 'pccodimp: ' || pccodimp;
      vpasexec    NUMBER(5) := 1;
      vnumerr     NUMBER(8) := 0;
      cur         SYS_REFCURSOR;
      vquery      VARCHAR2(5000);
   BEGIN
      vnumerr := pac_sin_imp_sap.f_get_tipos_indicador(pccodimp, pcarea,
                                                       pac_md_common.f_get_cxtidioma(),
                                                       vquery);

      IF vnumerr <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      cur := f_opencursor(vquery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobjectname,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           vnumerr,
                                           SQLCODE,
                                           SQLERRM);

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_tipos_indicador;
   --IAXIS 7655 AABC CONCEPTOS PAGO DE TIQUETES AEREOS
   FUNCTION f_get_concep_pago(mensajes IN OUT t_iax_mensajes)
      RETURN SYS_REFCURSOR IS
      /************************************************************************************
               Devuelve los tipos de indicador de pagos de tiquetes aereos
      ************************************************************************************/
      vobjectname VARCHAR2(500) := 'pac_md_sin_imp_sap.f_get_concep_pago';
      vparam      VARCHAR2(500) := 'pccodimp: ' || NULL;
      vpasexec    NUMBER(5) := 1;
      vnumerr     NUMBER(8) := 0;
      cur         SYS_REFCURSOR;
      vquery      VARCHAR2(5000);
   BEGIN
      vnumerr := pac_sin_imp_sap.f_get_concep_pago(pac_md_common.f_get_cxtidioma(),vquery);

      IF vnumerr <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;
      cur := f_opencursor(vquery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobjectname,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           vnumerr,
                                           SQLCODE,
                                           SQLERRM);
         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;
         RETURN cur;
   END f_get_concep_pago;
   --IAXIS 7655 AABC CONCEPTOS PAGO DE TIQUETES AEREOS
   FUNCTION f_set_impuesto_prof(psprofes IN NUMBER,
                                pccodimp IN NUMBER,
                                pctipind IN NUMBER,
                                mensajes IN OUT t_iax_mensajes) RETURN NUMBER IS
      /*************************************************************************
               Relaciona al profesional con el impuesto indicado
               param out mensajes : mesajes de error
               return             : number
      *************************************************************************/
      vobjectname VARCHAR2(500) := 'pac_md_sin_imp_sap.f_set_valores_reteica';
      vparam      VARCHAR2(500) := 'psprofes=' || psprofes || ' pccodimp=' ||
                                   pccodimp || ' pctipind=' || pctipind;
      vpasexec    NUMBER(5) := 1;
      vnumerr     NUMBER(8) := 0;
      --
      vquery    VARCHAR2(5000);
      v_funcion VARCHAR2(5000) := pac_parametros.f_parempresa_t(pcempres => f_empres,
                                                                pcparam  => 'PAC_SIN_IMP_SAP');
      --
   BEGIN
      --
      v_funcion := TRIM(NVL(v_funcion, 'PAC_SIN_IMP_SAP'));
      --
      vquery := 'begin :v_param := ' || v_funcion || '.f_set_impuesto_prof' || '(';
      vquery := vquery || psprofes;
      vquery := vquery || ', ' || pccodimp;
      vquery := vquery || ', ' || pctipind;
      vquery := vquery || '); end;';
      --
      EXECUTE IMMEDIATE vquery
         USING OUT vnumerr;
      --
      RETURN vnumerr;
      --
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobjectname,
                                           1000005,
                                           vpasexec,
                                           vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobjectname,
                                           1000006,
                                           vpasexec,
                                           vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobjectname,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           NULL,
                                           SQLCODE,
                                           SQLERRM);
         RETURN 1;
   END f_set_impuesto_prof;

   FUNCTION f_del_impuesto_prof(psprofes IN NUMBER,
                                pctipind IN NUMBER,
                                mensajes IN OUT t_iax_mensajes) RETURN NUMBER IS
      /*************************************************************************
               Anula el rol del profesional
               param out mensajes : mesajes de error
               return             : number
      *************************************************************************/
      vobjectname VARCHAR2(500) := 'pac_md_sin_imp_sap.f_del_impuesto_prof';
      vparam      VARCHAR2(500) := 'par¿metros - ';
      vpasexec    NUMBER(5) := 1;
      vnumerr     NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_sin_imp_sap.f_del_impuesto_prof(psprofes, pctipind);
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobjectname,
                                           1000005,
                                           vpasexec,
                                           vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobjectname,
                                           1000006,
                                           vpasexec,
                                           vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobjectname,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           NULL,
                                           SQLCODE,
                                           SQLERRM);
         RETURN 1;
   END f_del_impuesto_prof;

   FUNCTION f_get_indicador_prof(pcconpag IN NUMBER,
                                 psprofes IN NUMBER,
                                 pccodimp IN NUMBER,
                                 pfordpag IN DATE,
                                 pnsinies IN sin_tramita_localiza.nsinies%TYPE,
                                 pntramit IN sin_tramita_localiza.ntramit%TYPE,
                                 pnlocali IN sin_tramita_localiza.nlocali%TYPE,
                                 mensajes IN OUT t_iax_mensajes)
      RETURN SYS_REFCURSOR IS
      /*************************************************************************
               Recupera los impuestos/retenciones para un profesional dado
      *************************************************************************/
      vobjectname VARCHAR2(500) := 'pac_md_sin_imp_sap.f_get_indicador_prof';
      vparam      VARCHAR2(500) := 'par¿metros - pcconpag=' || pcconpag ||
                                   ' psprofes=' || psprofes || ' pfordpag=' ||
                                   pfordpag || ' pccodimp=' || pccodimp ||
                                   ' pnlocali=' || pnlocali;
      vpasexec    NUMBER(5) := 1;
      vnumerr     NUMBER(8) := 0;
      cur         SYS_REFCURSOR;
      vquery      VARCHAR2(5000);
      vqueryout   VARCHAR2(5000);
      v_funcion   VARCHAR2(5000) := pac_parametros.f_parempresa_t(pcempres => f_empres,
                                                                  pcparam  => 'PAC_SIN_IMP_SAP');
   BEGIN
      --
      v_funcion := TRIM(NVL(v_funcion, 'PAC_SIN_IMP_SAP'));
      --
      vquery := 'begin :v_param := ' || v_funcion ||
                '.f_get_indicador_prof' || '(';
      vquery := vquery || NVL(pcconpag, 0);
      vquery := vquery || ', ' || NVL(psprofes, 0);
      vquery := vquery || ', ' || NVL(pccodimp, 0);
      vquery := vquery || ', TO_DATE(''' ||
                TO_CHAR(NVL(pfordpag, f_sysdate), 'DD/MM/YYYY') || '''' ||
                ',''DD/MM/YYYY'')';
      vquery := vquery || ', ' || pnsinies;
      vquery := vquery || ', ' || pntramit;
      vquery := vquery || ', ' || NVL(pnlocali, 0);
      vquery := vquery || ', :ptselect); end;';
      --
      EXECUTE IMMEDIATE vquery
         USING OUT vnumerr, OUT vqueryout;
      --
      IF vnumerr <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      cur := f_opencursor(vqueryout, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobjectname,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           vnumerr,
                                           SQLCODE,
                                           SQLERRM);

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_indicador_prof;
 --INI--WAJ
      FUNCTION f_set_impuesto_per(pccodvin IN NUMBER,
                                pccatribu IN NUMBER,
                                pctipind IN NUMBER,
                                psperson IN NUMBER,
                                mensajes IN OUT t_iax_mensajes) RETURN NUMBER IS
      /*************************************************************************
               Relaciona el tipo de vinculo con el impuesto indicado
               param out mensajes : mesajes de error
               return             : number
      *************************************************************************/
      vobjectname VARCHAR2(500) := 'pac_sin_imp_sap.f_set_impuesto_per';
      vpasexec    NUMBER(5) := 1;
      vnumerr     NUMBER(8) := 0;

   BEGIN
      vnumerr := pac_sin_imp_sap.f_set_impuesto_per(pccodvin, pccatribu, pctipind, psperson);

        IF vnumerr != 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN 0;
end f_set_impuesto_per;
--FIN--WAJ
END pac_md_sin_imp_sap;

/

