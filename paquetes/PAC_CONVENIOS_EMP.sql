--------------------------------------------------------
--  DDL for Package PAC_CONVENIOS_EMP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_CONVENIOS_EMP" AUTHID CURRENT_USER IS
   /******************************************************************
       F_GET_DATOSCONVEMPVERS: Obtener datos cnvenio/versión
       Devuelve:  0 - ok
               nnnn - Error
   *******************************************************************/
   FUNCTION f_get_datosconvempvers(
      psseguro IN NUMBER,
      pidversion IN NUMBER,
      pmodo IN VARCHAR2,
      pidconv OUT NUMBER,
      ptcodconv OUT VARCHAR2,
      ptdescri OUT VARCHAR2,
      pcestado OUT NUMBER,
      pcperfil OUT NUMBER,
      pcvida OUT NUMBER,
      pcorganismo OUT NUMBER,
      pnversion OUT NUMBER,
      pcestadovers OUT NUMBER,
      pnversion_ant OUT NUMBER,
      pobserv OUT VARCHAR2)
      RETURN NUMBER;

   /******************************************************************
       F_GET_DATOSCONVEMPVERS: Obtener la Versión activa del convenio
   *******************************************************************/
   FUNCTION f_get_versactivaconv(
      pidconv IN NUMBER,
      pidversion OUT NUMBER,
      pfefecto OUT DATE,
      pnversion OUT NUMBER)
      RETURN NUMBER;

   /******************************************************************
       F_ES_POLIZACONVENIOS: Obtener si la póliza es de convenios
       Devuelve:  1 - SI es convenios
                  0 - NO es convenios
   *******************************************************************/
   FUNCTION f_es_polizaconvenios(psseguro IN NUMBER, pmodo IN VARCHAR2)
      RETURN NUMBER;

   /******************************************************************
       F_ES_PRODUCTOCONVENIOS: Obtener si el producto es de convenios
       Devuelve:  1 - SI es convenios
                  0 - NO es convenios
   *******************************************************************/
   FUNCTION f_es_productoconvenios(psproduc IN NUMBER)
      RETURN NUMBER;

   /******************************************************************
       F_CONV_POLIZA: Obtiene el convenio de la póliza
   *******************************************************************/
   FUNCTION f_conv_poliza(psseguro IN NUMBER, pmodo IN VARCHAR2)
      RETURN NUMBER;

   /******************************************************************
       F_ULTVERSCNV_POLIZA: Obtiene la versión actual de la póliza
       Devuelve:  null - No se ha encontrado la versión de la póliza
                  nnnn - Versión de la póliza
                  -1   - Error when others
   *******************************************************************/
   FUNCTION f_ultverscnv_poliza(psseguro IN NUMBER, pmodo IN VARCHAR2)
      RETURN NUMBER;

   /******************************************************************
       F_GET_CONVCONTRATABLE: Indica si un convenio es contratable
       Devuelve:
   *******************************************************************/
   FUNCTION f_get_convcontratable(
      pvers IN ob_iax_convempvers,
      pcempres IN NUMBER,
      pesaviso OUT NUMBER)
      RETURN NUMBER;

   /******************************************************************
       F_PROCESO_CAMB_VERSCON: Proceso Masivo de cambio de version
       Devuelve:     0 - O.K.
                  nnnn - Error (literal)
                  -1   - Error when others
   *******************************************************************/
   FUNCTION f_proceso_camb_verscon(
      ptcodconv IN VARCHAR2,
      pcidioma IN NUMBER,
      psproces OUT NUMBER)
      RETURN NUMBER;

   /******************************************************************
       F_VERSION_A_ANULAR: Indica que versión podemos cancelar en el
                  proceso de cancelación de versión para un Convenio
       Devuelve:     0 - O.K.
                  nnnn - Error (literal)
                  -1   - Error when others
   *******************************************************************/
   FUNCTION f_version_a_anular(ptcodconv IN VARCHAR2, pcoderror OUT NUMBER)
      RETURN NUMBER;

   /******************************************************************
        F_PROCESO_ANUL_VERSCON: Proceso Masivo masivo de anulación
                de cambio de versión de un convenio en particular.
        Devuelve:     0 - O.K.
                   nnnn - Error (literal)
                   -1   - Error when others
    *******************************************************************/
   FUNCTION f_proceso_anul_verscon(
      ptcodconv IN VARCHAR2,
      pcidioma IN NUMBER,
      psproces OUT NUMBER)
      RETURN NUMBER;

   /******************************************************************************
       f_get_versactivaconv_selet: Obtener la Versión/fecha efecto activa del convenio POR SEPARADO
       PARA pdata = 1 RETORNA  idversion Versión
       PARA pdata = 2 RETORNA  idversion Fecha
   ******************************************************************************/
   FUNCTION f_get_versactivaconv_selet(pidconv IN NUMBER, pdata IN NUMBER)
      RETURN VARCHAR2;

   PROCEDURE p_inicia;

   PROCEDURE p_inserta_version(
      pidconvenio IN cnv_conv_emp_vers.idconv%TYPE,
      pidversion IN cnv_conv_emp_vers.idversion%TYPE);

   PROCEDURE p_valida_trigger(pinserta IN NUMBER);
END pac_convenios_emp;

/

  GRANT EXECUTE ON "AXIS"."PAC_CONVENIOS_EMP" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_CONVENIOS_EMP" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_CONVENIOS_EMP" TO "PROGRAMADORESCSI";
