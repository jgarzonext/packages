--------------------------------------------------------
--  DDL for Package PAC_IAX_CONTABILIDAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_IAX_CONTABILIDAD" AS
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
      RETURN NUMBER;

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
      RETURN NUMBER;

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
      RETURN sys_refcursor;

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
      RETURN sys_refcursor;

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
      RETURN sys_refcursor;

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
      RETURN t_iax_modconta;

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
      RETURN ob_iax_modconta;

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
      RETURN t_iax_detmodconta;

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
      RETURN NUMBER;

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
      RETURN ob_iax_detmodconta;

   /*************************************************************************
      Función que carga el objeto OB_IAX_MODCONTA
      param in  P_SMODCON : cod.de plantilla contable
      param out MENSAJES  : mensajes de error
   *************************************************************************/
   FUNCTION f_recupera_plantilla(p_smodcon IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN ob_iax_modconta;

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
      RETURN ob_iax_detmodconta;

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
      RETURN NUMBER;

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
      RETURN NUMBER;

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
      RETURN NUMBER;

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
      RETURN NUMBER;

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
      RETURN NUMBER;

--Bug.: 0014782  - JMF - 09/09/2010
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
      RETURN NUMBER;

--Bug.: 0014782  - ICV - 09/09/2010
  /*************************************************************************
        Función que devuelve un sys_refcursor con los registros detallados de la contabilidad diaria filtrado por los parametros
        del modelo del parámetro
        param in  pcempres : código empresa
        param in  pfcontab : fecha de contabilidad
        param in  pccuenta : Cuenta
        param out  pdetcontab : Cursor con los resultados
        pnlinea in : linea
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
      RETURN NUMBER;

--Fin Bug.:    0014782

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
      RETURN sys_refcursor;

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
      RETURN NUMBER;

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
      RETURN sys_refcursor;

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
      RETURN NUMBER;

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
      RETURN NUMBER;
END pac_iax_contabilidad;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_CONTABILIDAD" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_CONTABILIDAD" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_CONTABILIDAD" TO "PROGRAMADORESCSI";
