--------------------------------------------------------
--  DDL for Package Body PAC_IAX_CONTABILIDAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IAX_CONTABILIDAD" AS
/******************************************************************************
   NOMBRE:    PAC_IAX_CONTABILIDAD
   PROPÓSITO: Contiene el módulo de contabilidad de la capa IAX

   REVISIONES:
   Ver        Fecha       Autor            Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        25/07/2008  SBG              1. Creación del package.
   2.0        09/09/2010  JMF              2. 0014782: APR708 - Llistat detall de la comptabilitat diaria
   3.0        14/12/2010  ICV              3. 0016908: APRM - Contabilidad diaria
   4.0        29/06/2011  ICV              4. 0018917: MSGV003 - Comptabilitat: El detall de la comptabilitat diaria no funciona.
******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   /*************************************************************************
      Función que genera la contabilidad. Retorna 0 si todo OK, 1 en caso contrario.
      param in  P_EMPRESA : código empresa
      param in  P_ANY     : año
      parma in  P_MES     : mes
      parma in  P_NMESES  : nº de meses para generar la contabilidad
      param out MENSAJES  : mensajes de error
   *************************************************************************/
   FUNCTION f_genera_contabilidad(
      p_empresa IN NUMBER,
      p_any IN NUMBER,
      p_mes IN NUMBER,
      p_nmeses IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'P_EMPRESA=' || p_empresa || ', P_ANY=' || p_any || ', P_MES=' || p_mes
            || ', P_NMESES=' || p_nmeses;
      vobject        VARCHAR2(200) := 'PAC_IAX_CONTABILIDAD.f_genera_contabilidad';
      v_res          NUMBER;
   BEGIN
      --Comprovació pas de paràmetres
      IF p_empresa IS NULL
         OR p_any IS NULL
         OR p_mes IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      v_res := pac_md_contabilidad.f_genera_contabilidad(p_empresa, p_any, p_mes, p_nmeses,
                                                         mensajes);
      RETURN v_res;
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
   END f_genera_contabilidad;

   /*************************************************************************
      Función que genera el cierre definitivo de la contabilidad. Retorna 0 si todo OK, 1 en caso contrario.
      param in  P_EMPRESA : código empresa
      param in  P_FECHA   : Último día del mes
      param out MENSAJES  : mensajes de error
   *************************************************************************/
   FUNCTION f_cierra_contabilidad(
      p_empresa IN NUMBER,
      p_fecha IN DATE,
      p_nmeses IN NUMBER DEFAULT NULL,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
                := 'P_EMPRESA=' || p_empresa || ', P_FECHA=' || TO_CHAR(p_fecha, 'DD/MM/YYYY');
      vobject        VARCHAR2(200) := 'PAC_IAX_CONTABILIDAD.f_cierra_contabilidad';
   BEGIN
      --Comprovació pas de paràmetres
      IF p_empresa IS NULL
         OR p_fecha IS NULL THEN
         RAISE e_param_error;
      END IF;

      --Traspaso de las tablas de simulación a las históricas.
      vpasexec := 2;
      pac_md_contabilidad.p_cierra_contabilidad(p_empresa, p_fecha, p_nmeses, mensajes);
      vpasexec := 3;

      IF mensajes IS NOT NULL THEN
         RETURN 1;
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
   END f_cierra_contabilidad;

   /*************************************************************************
      Función que selecciona info sobre la simulación de la contabilidad según parám.
      param in  P_EMPRESA : código empresa
      param in  P_ANY     : año
      parma in  P_MES     : mes
      param in  P_PAIS    : código país. Si se informa, la etiqueta será su descripción, sino será "TODOS"
      param out MENSAJES  : mensajes de error
   *************************************************************************/
   FUNCTION f_get_consultasimulacion(
      p_empresa IN NUMBER,
      p_any IN NUMBER,
      p_mes IN NUMBER,
      p_pais IN NUMBER,
      p_nmeses IN NUMBER DEFAULT NULL,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'P_EMPRESA=' || p_empresa || ', P_ANY=' || p_any || ', P_MES=' || p_mes
            || ', P_PAIS=' || p_pais;
      vobject        VARCHAR2(200) := 'PAC_IAX_CONTABILIDAD.f_get_ConsultaSimulacion';
      cur            sys_refcursor;
   BEGIN
      --Comprovació pas de paràmetres
      IF p_empresa IS NULL
         OR p_any IS NULL
         OR p_mes IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      --Crida a la capa MD
      cur := pac_md_contabilidad.f_get_consultasimulacion(p_empresa, p_any, p_mes, p_pais,
                                                          p_nmeses, mensajes);
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
   END f_get_consultasimulacion;

   /*************************************************************************
      Función que selecciona info sobre el histórico de la contabilidad según parám.
      param in  P_EMPRESA : código empresa
      param in  P_ANY     : año
      parma in  P_MES     : mes
      param in  P_PAIS    : código país. Si se informa, la etiqueta será su descripción, sino será "TODOS"
      param out MENSAJES  : mensajes de error
   *************************************************************************/
   FUNCTION f_get_consultahistorico(
      p_empresa IN NUMBER,
      p_any IN NUMBER,
      p_mes IN NUMBER,
      p_pais IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'P_EMPRESA=' || p_empresa || ', P_ANY=' || p_any || ', P_MES=' || p_mes
            || ', P_PAIS=' || p_pais;
      vobject        VARCHAR2(200) := 'PAC_IAX_CONTABILIDAD.f_get_ConsultaHistorico';
      cur            sys_refcursor;
   BEGIN
      --Comprovació pas de paràmetres
      IF p_empresa IS NULL
         OR p_any IS NULL
         OR p_mes IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      --Crida a la capa MD
      cur := pac_md_contabilidad.f_get_consultahistorico(p_empresa, p_any, p_mes, p_pais,
                                                         mensajes);
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
   END f_get_consultahistorico;

   /*************************************************************************
      Función que selecciona info sobre el desglose de la contabilidad según parám.
      param in  P_CUENTA   : código cuenta contable
      param in  P_CONCEPTO : tipo de concepto (Debe o Haber)
      param in  P_EMPRESA  : código empresa
      param in  P_FECHA    : fecha contable
      param in  P_PAIS     : código país. Si se informa, la etiqueta será su descripción, sino será "TODOS"
      parma in  P_LINEA    : código línea contable
      parma in  P_ASIENTO  : código asiento contable
      parma in  P_ACTUAL   : 0=Histórico / 1=Cuadre
      param out MENSAJES   : mensajes de error
   *************************************************************************/
   FUNCTION f_get_consultadesglose(
      p_cuenta IN VARCHAR2,
      p_concepto IN VARCHAR2,
      p_empresa IN NUMBER,
      p_fecha IN DATE,
      p_pais IN NUMBER,
      p_linea IN NUMBER,
      p_asiento IN NUMBER,
      p_actual IN NUMBER,
      pmes IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(300)
         := 'P_CUENTA=' || p_cuenta || ', P_CONCEPTO=' || p_concepto || ', P_EMPRESA='
            || p_empresa || ', P_FECHA=' || TO_CHAR(p_fecha, 'DD/MM/YYYY') || ', P_PAIS='
            || p_pais || ', P_LINEA=' || p_linea || ', P_ASIENTO=' || p_asiento
            || ', P_ACTUAL=' || p_actual;
      vobject        VARCHAR2(200) := 'PAC_IAX_CONTABILIDAD.f_get_ConsultaDesglose';
      cur            sys_refcursor;
   BEGIN
      --Comprovació pas de paràmetres
      IF p_cuenta IS NULL
         OR p_concepto IS NULL
         OR p_empresa IS NULL
         OR p_fecha IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      --Crida a la capa MD
      cur := pac_md_contabilidad.f_get_consultadesglose(p_cuenta, p_concepto, p_empresa,
                                                        p_fecha, p_pais, p_linea, p_asiento,
                                                        p_actual, pmes, mensajes);
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
   END f_get_consultadesglose;

   /*************************************************************************
      Función que recupera plantillas contables según parámetros de entrada
      param in  P_EMPRESA : código empresa
      param in  P_TIPO_AS : tipo asiento
      param out MENSAJES  : mensajes de error
   *************************************************************************/
   FUNCTION f_get_consultaplantilla(
      p_empresa IN NUMBER,
      p_tipo_as IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN t_iax_modconta IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'P_EMPRESA=' || p_empresa || ', P_TIPO_AS=' || p_tipo_as;
      vobject        VARCHAR2(200) := 'PAC_IAX_CONTABILIDAD.F_Get_ConsultaPlantilla';
      v_result       t_iax_modconta;
   BEGIN
      --Comprovació pas de paràmetres
      IF p_empresa IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      --Crida a la capa MD
      v_result := pac_md_contabilidad.f_get_consultaplantilla(p_empresa, p_tipo_as, mensajes);
      RETURN v_result;
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
   END f_get_consultaplantilla;

   /*************************************************************************
      Función que inserta/modifica las plantillas contables
      param in  P_EMPRESA : código empresa
      param in  P_TIPO_AS : tipo asiento
      param in  P_FFIN    : fecha final
      param out MENSAJES  : mensajes de error
   *************************************************************************/
   FUNCTION f_grabar_plantilla(
      p_empresa IN NUMBER,
      p_tipo_as IN NUMBER,
      p_ffin IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN ob_iax_modconta IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'P_EMPRESA=' || p_empresa || ', P_TIPO_AS=' || p_tipo_as || ', P_FFIN='
            || TO_CHAR(p_ffin, 'DD/MM/YYYY');
      vobject        VARCHAR2(200) := 'PAC_IAX_CONTABILIDAD.F_Grabar_Plantilla';
      v_error        NUMBER;
      v_modcon       NUMBER(6);
      v_result       ob_iax_modconta;
   BEGIN
      --Comprovació pas de paràmetres
      IF p_empresa IS NULL
         OR p_tipo_as IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      --Crida a la capa MD
      v_result := pac_md_contabilidad.f_grabar_plantilla(p_empresa, p_tipo_as, p_ffin,
                                                         mensajes);
      RETURN v_result;
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
   END f_grabar_plantilla;

   /*************************************************************************
      Función que recupera los detalles de una plantilla contable
      param in  P_EMPRESA : código empresa
      param in  P_SMODCON : cod.de plantilla contable
      param out MENSAJES  : mensajes de error
   *************************************************************************/
   FUNCTION f_get_consultadetalleplantilla(
      p_empresa IN NUMBER,
      p_smodcon IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN t_iax_detmodconta IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'P_EMPRESA=' || p_empresa || ', P_SMODCON=' || p_smodcon;
      vobject        VARCHAR2(200) := 'PAC_IAX_CONTABILIDAD.F_Get_ConsultaDetallePlantilla';
      v_result       t_iax_detmodconta;
   BEGIN
      --Crida a la capa MD
      v_result := pac_md_contabilidad.f_get_consultadetalleplantilla(p_empresa, p_smodcon,
                                                                     mensajes);
      RETURN v_result;
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
   END f_get_consultadetalleplantilla;

   /*************************************************************************
      Función que borra un detalle de una plantilla contable
      param in  P_EMPRESA : código empresa
      param in  P_SMODCON : cod.de plantilla contable
      param in  P_NLINEA  : número de línea
      param out MENSAJES  : mensajes de error
   *************************************************************************/
   FUNCTION f_del_detalleplantilla(
      p_empresa IN NUMBER,
      p_smodcon IN NUMBER,
      p_nlinea IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'P_EMPRESA=' || p_empresa || ', P_SMODCON=' || p_smodcon || ', P_NLINEA='
            || p_nlinea;
      vobject        VARCHAR2(200) := 'PAC_IAX_CONTABILIDAD.F_Del_DetallePlantilla';
      v_error        NUMBER;
   BEGIN
      --Crida a la capa MD
      v_error := pac_md_contabilidad.f_del_detalleplantilla(p_empresa, p_smodcon, p_nlinea,
                                                            mensajes);
      RETURN v_error;
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
   END f_del_detalleplantilla;

   /*************************************************************************
      Función que inserta/modifica las plantillas contables
      param in  P_EMPRESA : código empresa
      param in  P_SMODCON : cod.de plantilla contable
      param in  P_NLINEA  : núm. línia
      param in  P_TDESCRI : descripción
      param in  P_CUENTAC : cuenta contable
      param in  P_TIPOLIN : tipo línea
      param in  P_TSELECT : select
      param out MENSAJES  : mensajes de error
   *************************************************************************/
   FUNCTION f_grabar_detalleplantilla(
      p_empresa IN NUMBER,
      p_smodcon IN NUMBER,
      p_nlinea IN NUMBER,
      p_tdescri IN VARCHAR2,
      p_cuentac IN VARCHAR2,
      p_tipolin IN NUMBER,
      p_tselect IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN ob_iax_detmodconta IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(3000)
         := 'P_EMPRESA=' || p_empresa || ', P_SMODCON=' || p_smodcon || ', P_TDESCRI='
            || p_tdescri || ', P_CUENTAC=' || p_cuentac || ', P_TIPOLIN=' || p_tipolin
            || ', P_TSELECT=' || p_tselect;
      vobject        VARCHAR2(200) := 'PAC_IAX_CONTABILIDAD.F_Grabar_DetallePlantilla';
      v_result       ob_iax_detmodconta;
   BEGIN
      --Comprovació pas de paràmetres
      IF p_empresa IS NULL
         OR p_tdescri IS NULL
         OR p_cuentac IS NULL
         OR p_tipolin IS NULL
         OR p_tselect IS NULL THEN
         RAISE e_param_error;
      END IF;

      --Crida a la capa MD
      v_result := pac_md_contabilidad.f_grabar_detalleplantilla(p_empresa, p_smodcon, p_nlinea,
                                                                p_tdescri, p_cuentac,
                                                                p_tipolin, p_tselect, mensajes);
      RETURN v_result;
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
   END f_grabar_detalleplantilla;

   /*************************************************************************
      Función que carga el objeto OB_IAX_MODCONTA
      param in  P_SMODCON : cod.de plantilla contable
      param out MENSAJES  : mensajes de error
   *************************************************************************/
   FUNCTION f_recupera_plantilla(p_smodcon IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN ob_iax_modconta IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(3000) := 'P_SMODCON=' || p_smodcon;
      vobject        VARCHAR2(200) := 'PAC_IAX_CONTABILIDAD.F_Recupera_Plantilla';
      v_error        NUMBER;
      v_result       ob_iax_modconta;
   BEGIN
      --Crida a la capa MD
      v_result := pac_md_contabilidad.f_recupera_plantilla(p_smodcon, mensajes);
      RETURN v_result;
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
   END f_recupera_plantilla;

   /*************************************************************************
      Función que carga el objeto OB_IAX_DETMODCONTA
      param in  P_EMPRESA : código empresa
      param in  P_SMODCON : cod.de plantilla contable
      param in  P_NLINEA  : número de línea
      param out MENSAJES  : mensajes de error
   *************************************************************************/
   FUNCTION f_recupera_detalleplantilla(
      p_empresa IN NUMBER,
      p_smodcon IN NUMBER,
      p_nlinea IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN ob_iax_detmodconta IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(3000)
         := 'P_EMPRESA=' || p_empresa || ', P_SMODCON=' || p_smodcon || ', P_NLINEA='
            || p_nlinea;
      vobject        VARCHAR2(200) := 'PAC_IAX_CONTABILIDAD.F_Recupera_DetallePlantilla';
      v_result       ob_iax_detmodconta;
   BEGIN
      --Crida a la capa MD
      v_result := pac_md_contabilidad.f_recupera_detalleplantilla(p_empresa, p_smodcon,
                                                                  p_nlinea, mensajes);
      RETURN v_result;
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
   END f_recupera_detalleplantilla;

   /*************************************************************************
      Función que duplica un modelo contable e informa la fecha de fin
      del modelo del parámetro
      param in  P_EMPRESA : código empresa
      param in  P_SMODCON : cod. de plantilla contable
      param out P_NEWSMOD : Nuevo cod. de plantilla contable
      param out MENSAJES  : mensajes de error
   *************************************************************************/
   FUNCTION f_duplicarmodelo(
      p_empresa IN NUMBER,
      p_smodcon IN NUMBER,
      p_newsmod OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(3000) := 'P_SMODCON=' || p_smodcon;
      vobject        VARCHAR2(200) := 'PAC_IAX_CONTABILIDAD.f_DuplicarModelo';
      v_result       NUMBER(1);
   BEGIN
      --Crida a la capa MD
      v_result := pac_md_contabilidad.f_duplicarmodelo(p_empresa, p_smodcon, p_newsmod,
                                                       mensajes);
      RETURN v_result;
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
   END f_duplicarmodelo;

   /*************************************************************************
      Función que devuelve un sys_refcursor con los registros de la contabilidad diaria filtrado por los parametros
      del modelo del parámetro
      param in  pcempres : código empresa
      param in  pfcontabini : fecha de contabilidad inicial
      param in  pfcontabfin : fecha de contabilidad final
      param in  pftraspasini : fecha de traspaso inicial
      param in  pftraspasfin : fecha de traspaso inicial
      param in  pchecktraspas : traspasados o no
      param out  pcontdiarias : Cursor con los resultados
      param out MENSAJES  : mensajes de error
   *************************************************************************/
   FUNCTION f_get_contabilidad_diaria(
      pcempres IN NUMBER,
      pfcontabini IN DATE,
      pfcontabfin IN DATE,
      pftraspasini IN DATE,
      pftraspasfin IN DATE,
      pfadminini IN DATE,
      pfadminfin IN DATE,
      pchecktraspas IN NUMBER,
      pcontdiarias OUT sys_refcursor,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(3000)
         := 'pcempres=' || pcempres || ', pfcontabini=' || pfcontabini || ', pfcontabfin='
            || pfcontabfin || ', pftraspasini=' || pftraspasini || ', pftraspasfin='
            || pftraspasfin || ', pfadminini=' || pfadminini || ', pfadminfin=' || pfadminfin
            || ', pchecktraspas=' || pchecktraspas;
      vobject        VARCHAR2(200) := 'PAC_IAX_CONTABILIDAD.f_get_contabilidad_diaria';
      vnum_err       NUMBER(1) := 0;
   BEGIN
      --Crida a la capa MD
      vnum_err := pac_md_contabilidad.f_get_contabilidad_diaria(pcempres, pfcontabini,
                                                                pfcontabfin, pftraspasini,
                                                                pftraspasfin, pfadminini,
                                                                pfadminfin, pchecktraspas,
                                                                pcontdiarias, mensajes);
      RETURN vnum_err;
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
   END f_get_contabilidad_diaria;

   /*************************************************************************
      Función que acaba ejecutando la contabilidad diaria (por una fecha contable)
      del modelo del parámetro
      param in  pcempres : código empresa
      param in  pfcontabilidad : fecha de contabilidad inicial
      param out MENSAJES  : mensajes de error
   *************************************************************************/
   FUNCTION f_contabiliza_diario(
      pcempres IN NUMBER,
      pfcontabilidad IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(3000)
                           := 'pcempres=' || pcempres || ', pfcontabilidad=' || pfcontabilidad;
      vobject        VARCHAR2(200) := 'PAC_IAX_CONTABILIDAD.f_contabiliza_diario';
      vnum_err       NUMBER(1) := 0;
   BEGIN
      --Crida a la capa MD
      vnum_err := pac_md_contabilidad.f_contabiliza_diario(pcempres, pfcontabilidad, mensajes);

      IF vnum_err <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN vnum_err;
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
   END f_contabiliza_diario;

   /*************************************************************************
      Función que ejecuta el map 321
      param in  pcempres : código empresa
      param out  pnomfichero : Nombre fichero
   *************************************************************************/
   FUNCTION f_traspasar(
      pcempres IN NUMBER,
      pfecini IN DATE,
      pfecfin IN DATE,
      pfadminini IN DATE,
      pfadminfin IN DATE,
      pnomfichero OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(3000)
                := 'pcempres=' || pcempres || ' pfecini=' || pfecini || ' pfecfin=' || pfecfin;
      vobject        VARCHAR2(200) := 'PAC_IAX_CONTABILIDAD.f_traspasar';
      vnum_err       NUMBER(1) := 0;
      vcempres       NUMBER;
   BEGIN
      vnum_err := pac_md_contabilidad.f_traspasar(pcempres, pfecini, pfecfin, pfadminini,
                                                  pfadminfin, pnomfichero, mensajes);

      IF vnum_err <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN vnum_err;
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
   END f_traspasar;

   /*************************************************************************
       Función que monta el fichero con los filtros de busqueda y devuelve el fichero mostrado
      param in  pcempres : código empresa
      param in  pfcontabini : fecha de contabilidad inicial
      param in  pfcontabfin : fecha de contabilidad final
      param in  pftraspasini : fecha de traspaso inicial
      param in  pftraspasfin : fecha de traspaso inicial
      param in  pchecktraspas : traspasados o no
      param out  pnomfichero : Nombre fichero
    *************************************************************************/
   FUNCTION f_montar_fichero(
      pcempres IN NUMBER,
      pfcontabini IN DATE,
      pfcontabfin IN DATE,
      pftraspasini IN DATE,
      pftraspasfin IN DATE,
      pfadminini IN DATE,
      pfadminfin IN DATE,
      pchecktraspas IN NUMBER,
      pnomfichero OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(3000)
         := 'pcempres=' || pcempres || ', pfcontabini=' || pfcontabini || ', pfcontabfin='
            || pfcontabfin || ', pftraspasini=' || pftraspasini || ', pftraspasfin='
            || pftraspasfin || ', pfadminini=' || pfadminini || ', pfadminfin=' || pfadminfin
            || ', pchecktraspas=' || pchecktraspas;
      vobject        VARCHAR2(200) := 'PAC_iax_CONTABILIDAD.p_montar_fichero';
      vnum_err       NUMBER(1) := 0;
      vcempres       NUMBER;
   BEGIN
      vcempres := pcempres;

      IF pcempres IS NULL THEN
         vcempres := pac_md_common.f_get_cxtempresa;
      END IF;

      vnum_err := pac_md_contabilidad.f_montar_fichero(vcempres, pfcontabini, pfcontabfin,
                                                       pftraspasini, pftraspasfin, pfadminini,
                                                       pfadminfin, pchecktraspas, pnomfichero,
                                                       mensajes);
      RETURN vnum_err;
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
   END f_montar_fichero;

--Bug.: 0014782 - JMF -
   FUNCTION f_montarfichero_detalle(
      p_cempres IN NUMBER,
      p_fcontabini IN DATE,
      p_fcontabfin IN DATE,
      p_ccuenta IN VARCHAR2,
      p_nlinea IN NUMBER,
      p_smodcon IN NUMBER,
      p_cpais IN NUMBER,
      p_fefeadm IN DATE,
      p_cproces IN NUMBER,
      p_nomfichero OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_npasexec     NUMBER(8) := 1;
      v_tparam       VARCHAR2(3000)
         := 'p_cempres=' || p_cempres || ', p_fcontabini=' || p_fcontabini
            || ', p_fcontabfin=' || p_fcontabfin || ', p_ccuenta=' || p_ccuenta;
      v_tobject      VARCHAR2(200) := 'PAC_IAX_CONTABILIDAD.F_MONTARFICHERO_DETALLE';
      v_nerr         NUMBER(1) := 0;
      v_cempres      NUMBER;
      v_nrep         NUMBER;
      v_cmap         map_cabecera.cmapead%TYPE := '404';
   BEGIN
      v_npasexec := 100;
      v_cempres := p_cempres;

      IF p_cempres IS NULL THEN
         v_npasexec := 110;
         v_cempres := pac_md_common.f_get_cxtempresa;
      END IF;

      IF p_fcontabini IS NULL
         OR p_ccuenta IS NULL
         OR p_nlinea IS NULL
         OR p_smodcon IS NULL
         OR p_cpais IS NULL
         OR p_fefeadm IS NULL
         OR p_cproces IS NULL THEN
         RAISE e_param_error;
      END IF;

      v_npasexec := 120;
      p_nomfichero := pac_iax_map.f_ejecuta(v_cmap,
                                            v_cempres || '|'
                                            || TO_CHAR(p_fcontabini, 'ddmmyyyy') || '|'
                                            || p_ccuenta || '|' || p_nlinea || '|' || p_smodcon
                                            || '|' || p_cpais || '|'
                                            || TO_CHAR(p_fefeadm, 'ddmmyyyy') || '|'
                                            || p_cproces,
                                            v_nrep, mensajes);

      IF p_nomfichero IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 107914);
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_tobject, 1000005, v_npasexec, v_tparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_tobject, 1000006, v_npasexec, v_tparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_tobject, 1000001, v_npasexec, v_tparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_montarfichero_detalle;

   --Bug.: 0014782  - ICV - 09/09/2010
   /*************************************************************************
         Función que devuelve un sys_refcursor con los registros detallados de la contabilidad diaria filtrado por los parametros
         del modelo del parámetro
         param in  pcempres : código empresa
         param in  pfcontab : fecha de contabilidad
         param in  pccuenta : Cuenta
           psmodcon in : smodcon
      pcpais in : Código País
      pfefeadm : Fefeadm
      pcproces : Código Proceso
        param in out MENSAJES  : mensajes de error
     *************************************************************************/
   FUNCTION f_get_detcontabilidad_diaria(
      pcempres IN NUMBER,
      pfcontab IN DATE,
      pccuenta IN VARCHAR2,
      pnlinea IN NUMBER,
      psmodcon IN NUMBER,
      pcpais IN NUMBER,
      pfefeadm IN DATE,
      pcproces IN NUMBER,
      pdetcontab OUT sys_refcursor,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(3000)
         := 'pcempres=' || pcempres || ', pfcontab=' || pfcontab || ', pccuenta=' || pccuenta
            || ', pnlinea =' || pnlinea || ', psmodcon = ' || psmodcon || ', pcpais = '
            || pcpais || ', pfefeadm = ' || pfefeadm || ', pcproces = ' || pcproces;
      vobject        VARCHAR2(200) := 'PAC_IAX_CONTABILIDAD.f_get_detcontabilidad_diaria';
      vnum_err       NUMBER(1) := 0;
   BEGIN
      vnum_err := pac_md_contabilidad.f_get_detcontabilidad_diaria(pcempres, pfcontab,
                                                                   pccuenta, pnlinea,
                                                                   psmodcon, pcpais, pfefeadm,
                                                                   pcproces, pdetcontab,
                                                                   mensajes);
      RETURN vnum_err;
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
   END f_get_detcontabilidad_diaria;

--Fin Bug.: 0014782
/*************************************************************************
         Función que selecciona info sobre el desglose de los apuntes manuales.
         param in PCEMPRES    : código empresa
         param in PFCONTA_INI      : fecha contable inicial
         param in PFCONTA_FIN      : fecha contable final
         param in PFEFEADM_INI     : fecha adm inicial
         param in PFEFEADM_FIN     : fecha adm final
         param in out MENSAJES : mensajes de error
      *************************************************************************/
   FUNCTION f_get_apuntesmanuales(
      pcempres IN NUMBER,
      pfconta_ini IN DATE,
      pfconta_fin IN DATE,
      pfefeadm_ini IN DATE,
      pfefeadm_fin IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(300)
         := 'pcempres=' || pcempres || ', pfconta_ini=' || TO_CHAR(pfconta_ini, 'DD/MM/YYYY')
            || ', pfconta_fin=' || TO_CHAR(pfconta_fin, 'DD/MM/YYYY') || ', pfefeadm_ini='
            || TO_CHAR(pfefeadm_ini, 'DD/MM/YYYY') || ', pfefeadm_fin='
            || TO_CHAR(pfefeadm_fin, 'DD/MM/YYYY');
      vobject        VARCHAR2(200) := 'PAC_IAX_CONTABILIDAD.f_get_apuntesmanuales';
      vnum_err       NUMBER(1) := 0;
      cur            sys_refcursor;
   BEGIN
      cur := pac_md_contabilidad.f_get_apuntesmanuales(pcempres, pfconta_ini, pfconta_fin,
                                                       pfefeadm_ini, pfefeadm_fin, mensajes);
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
   END f_get_apuntesmanuales;

   /*************************************************************************
        Función que borra un apunte manual
        CPAIS, FEFEADM, CPROCES, CCUENTA, NLINEA, NASIENT, CEMPRES, FCONTA, TDESCRI, SINTERF, TTIPPAG, IDPAGO, CCOLETILLA, OTROS
        param in P_EMPRESA    : código empresa
        param in P_SMODCON    : cod.de plantilla contable
        param in P_NLINEA     : número de línea
        param in out MENSAJES : mensajes de error
     *************************************************************************/
   FUNCTION f_del_apuntemanual(
      pcpais IN NUMBER,
      pfefeadm IN DATE,
      pcproces IN NUMBER,
      pccuenta IN VARCHAR2,
      pnlinea IN NUMBER,
      pnasient IN NUMBER,
      pcempres IN NUMBER,
      pfconta IN DATE,
      ptdescri IN VARCHAR2,
      psinterf IN NUMBER,
      pttippag IN NUMBER,
      pidpago IN NUMBER,
      pccoletilla IN VARCHAR2,
      potros IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
         := 'pcpais=' || pcpais || ', pfefeadm=' || pfefeadm || ',pcproces=' || pcproces
            || ',pccuenta=' || pccuenta || ',pnlinea=' || pnlinea || ',pnasient=' || pnasient
            || ',PCEMPRES=' || pcempres || ',PFCONTA=' || pfconta || ',PTDESCRI=' || ptdescri
            || ',PSINTERF=' || psinterf || ',PTTIPPAG=' || pttippag || ',PIDPAGO=' || pidpago
            || ',PCCOLETILLA=' || pccoletilla || ',POTROS=' || potros;
      vobject        VARCHAR2(200) := 'PAC_IAX_CONTABILIDAD.f_del_apuntemanual';
      v_error        NUMBER;
   BEGIN
      v_error := pac_md_contabilidad.f_del_apuntemanual(pcpais, pfefeadm, pcproces, pccuenta,
                                                        pnlinea, pnasient, pcempres, pfconta,
                                                        ptdescri, psinterf, pttippag, pidpago,
                                                        pccoletilla, potros, mensajes);

      IF v_error = 0 THEN
         COMMIT;
      ELSE
         ROLLBACK;
      END IF;

      RETURN v_error;
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
   END f_del_apuntemanual;

/*************************************************************************
         Función que selecciona info sobre el desglose de los apuntes.
         param in PCEMPRES    : código empresa
         param in PFCONTA_INI      : fecha contable inicial
         param in PFCONTA_FIN      : fecha contable final
         param in PFEFEADM_INI     : fecha adm inicial
         param in PFEFEADM_FIN     : fecha adm final
         param in out MENSAJES : mensajes de error
      *************************************************************************/
   FUNCTION f_get_apuntes(
      pcempres IN VARCHAR2,
      pfconta_ini IN DATE,
      pfconta_fin IN DATE,
      pfefeadm_ini IN DATE,
      pfefeadm_fin IN DATE,
      pidpago IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(300)
         := 'pcempres=' || pcempres || ', pfconta_ini=' || TO_CHAR(pfconta_ini, 'DD/MM/YYYY')
            || ', pfconta_fin=' || TO_CHAR(pfconta_fin, 'DD/MM/YYYY') || ', pfefeadm_ini='
            || TO_CHAR(pfefeadm_ini, 'DD/MM/YYYY') || ', pfefeadm_fin='
            || TO_CHAR(pfefeadm_fin, 'DD/MM/YYYY');
      vobject        VARCHAR2(200) := 'PAC_IAX_CONTABILIDAD.f_get_apuntes';
      vnum_err       NUMBER(1) := 0;
      cur            sys_refcursor;
   BEGIN
      cur := pac_md_contabilidad.f_get_apuntes(pcempres, pfconta_ini, pfconta_fin,
                                               pfefeadm_ini, pfefeadm_fin, pidpago, mensajes);
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
   END f_get_apuntes;

/*************************************************************************
      Función que inserta un apunte manual
      CPAIS, FEFEADM, CPROCES, CCUENTA, NLINEA, NASIENT, CEMPRES, FCONTA, TDESCRI, SINTERF, TTIPPAG, IDPAGO, CCOLETILLA, OTROS
      param in P_EMPRESA    : código empresa
      param in P_SMODCON    : cod.de plantilla contable
      param in P_NLINEA     : número de línea
      param in out MENSAJES : mensajes de error
   *************************************************************************/
   FUNCTION f_set_apuntemanual(
      psinterf IN NUMBER,
      pttippag IN NUMBER,
      pidpago IN NUMBER,
      pfconta IN DATE,
      pnasient IN NUMBER,
      pnlinea IN NUMBER,
      pccuenta IN VARCHAR2,
      pccoletilla IN VARCHAR2,
      ptapunte IN VARCHAR2,
      piapunte IN NUMBER,
      ptdescri IN VARCHAR2,
      pfefeadm IN DATE,
      potros IN VARCHAR2,
      pcenlace IN VARCHAR2,
      pcempres IN NUMBER,
      pcproces IN NUMBER,
      pcpais IN NUMBER,
      pftraspaso IN DATE,
      pclaveasi IN VARCHAR2,
      ptipodiario IN VARCHAR2,
      pfasiento IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
         := 'psinterf=' || psinterf || ', pttippag=' || pttippag || ',pidpago=' || pidpago
            || ',pfconta=' || pfconta || ',pnlinea=' || pnlinea || ',pnasient=' || pnasient
            || ',pccuenta=' || pccuenta || ',pccoletilla=' || pccoletilla || ',ptapunte='
            || ptapunte || ',piapunte=' || piapunte || ',ptdescri=' || ptdescri
            || ',pfefeadm=' || pfefeadm || ',pcpais=' || pcpais || ',pftraspaso='
            || pftraspaso || ',pclaveasi=' || pclaveasi || ',ptipodiario=' || ptipodiario
            || ',pfasiento=' || pfasiento;
      vobject        VARCHAR2(200) := 'PAC_IAX_CONTABILIDAD.f_set_apuntemanual';
      v_error        NUMBER;
   BEGIN
      v_error := pac_md_contabilidad.f_set_apuntemanual(psinterf, pttippag, pidpago, pfconta,
                                                        pnasient, pnlinea, pccuenta,
                                                        pccoletilla, ptapunte, piapunte,
                                                        ptdescri, pfefeadm, potros, pcenlace,
                                                        pcempres, pcproces, pcpais,
                                                        pftraspaso, pclaveasi, ptipodiario,
                                                        pfasiento, mensajes);

      IF v_error = 0 THEN
         COMMIT;
      ELSE
         ROLLBACK;
      END IF;

      RETURN v_error;
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
   END f_set_apuntemanual;

   /*************************************************************************
         Función que traspasa un apunte manual a las tablas de apuntes reales.
         param in PCEMPRES    : código empresa
         param in PFCONTA_INI      : fecha contable inicial
         param in PFCONTA_FIN      : fecha contable final
         param in PFEFEADM_INI     : fecha adm inicial
         param in PFEFEADM_FIN     : fecha adm final
         param in out MENSAJES : mensajes de error
      *************************************************************************/
   FUNCTION f_traspasa_apuntemanual(mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAX_CONTABILIDAD.f_traspasa_apuntemanual';
      v_error        NUMBER;
   BEGIN
      v_error := pac_md_contabilidad.f_traspasa_apuntemanual(mensajes);

      IF v_error = 0 THEN
         COMMIT;
      ELSE
         ROLLBACK;
      END IF;

      RETURN v_error;
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
   END f_traspasa_apuntemanual;
END pac_iax_contabilidad;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_CONTABILIDAD" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_CONTABILIDAD" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_CONTABILIDAD" TO "PROGRAMADORESCSI";
