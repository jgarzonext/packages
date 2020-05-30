--------------------------------------------------------
--  DDL for Package PAC_CONTABILIDAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_CONTABILIDAD" AS
/******************************************************************************
   NOMBRE:    PAC_CONTABILIDAD
   PROPÓSITO: Contiene el módulo de contabilidad de la capa de negocio

   REVISIONES:
   Ver        Fecha       Autor            Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        27/08/2008  SBG              1. Creación del package.
   2.0        14/12/2010  ICV              3. 0016908: APRM - Contabilidad diaria
******************************************************************************/

   /*************************************************************************
      Procedimiento que graba en MODCONTA y DETMODIF
   *************************************************************************/
   PROCEDURE p_grabar_plantilla(
      p_cempres IN NUMBER,
      p_smodcon IN NUMBER,
      p_casient IN NUMBER,
      p_cprogra IN NUMBER,
      p_ffin IN DATE,
      p_newsmod OUT NUMBER,
      p_error OUT NUMBER);

   /*************************************************************************
      Procedimiento que elimina de DETMODCONTA según parámetros de entrada
   *************************************************************************/
   PROCEDURE p_del_detalleplantilla(
      p_smodcon IN NUMBER,
      p_cempres IN NUMBER,
      p_nlinea IN NUMBER,
      p_error OUT NUMBER);

   /*************************************************************************
      Procedimiento que graba en DETMODCONTA
   *************************************************************************/
   PROCEDURE p_grabar_detalleplantilla(
      p_smodcon IN NUMBER,
      p_cempres IN NUMBER,
      p_nlinea IN NUMBER,
      p_tdescri IN VARCHAR2,
      p_ccuenta IN VARCHAR2,
      p_tcuenta IN VARCHAR2,
      p_tselect IN VARCHAR2,
      p_newnlin OUT NUMBER,
      p_error OUT NUMBER);

   /*************************************************************************
      Procedimiento que duplica un modelo contable e informa la fecha de fin
      del modelo del parámetro
   *************************************************************************/
   PROCEDURE p_duplicarmodelo(
      p_cempres IN NUMBER,
      p_smodcon IN NUMBER,
      p_newsmod OUT NUMBER,
      p_error OUT NUMBER);

   /****************************************************************************
      Función que devuelve un sys_refcursor con los registros de la contabilidad diaria filtrado por los parametros
      del modelo del parámetro
      param in  pcempres : código empresa
      param in  pfcontabini : fecha de contabilidad inicial
      param in  pfcontabfin : fecha de contabilidad final
      param in  pftraspasini : fecha de traspaso inicial
      param in  pftraspasfin : fecha de traspaso inicial
      param in  pchecktraspas : traspasados o no
      param out  vquery : Cursor con los resultados
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
      vquery OUT VARCHAR2)
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
      pnomfichero OUT VARCHAR2,
      pfadminini IN DATE DEFAULT NULL,
      pfadminfin IN DATE DEFAULT NULL)
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
   PROCEDURE p_montar_fichero(
      pcempres IN NUMBER,
      pfcontabini IN DATE,
      pfcontabfin IN DATE,
      pftraspasini IN DATE,
      pftraspasfin IN DATE,
      pfadminini IN DATE,
      pfadminfin IN DATE,
      pchecktraspas IN NUMBER,
      pcidioma IN NUMBER,
      pnomfichero OUT VARCHAR2);

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
      potros IN VARCHAR2)
      RETURN NUMBER;

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
      pfasiento IN DATE)
      RETURN NUMBER;
END pac_contabilidad;

/

  GRANT EXECUTE ON "AXIS"."PAC_CONTABILIDAD" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_CONTABILIDAD" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_CONTABILIDAD" TO "PROGRAMADORESCSI";
