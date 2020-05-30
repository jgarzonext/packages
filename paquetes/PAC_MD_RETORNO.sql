--------------------------------------------------------
--  DDL for Package PAC_MD_RETORNO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_MD_RETORNO" AS
   /******************************************************************************
     NOMBRE:     PAC_MD_RETORNO
     PROPÓSITO:  Package para gestionar los retornos de convenios beneficiarios

     REVISIONES:
     Ver        Fecha        Autor             Descripción
     ---------  ----------  ---------------  ------------------------------------
     1.0        03/09/2012   JMF             0022701: LCOL: Implementación de Retorno
     2.0        28/11/2012   JMF             0024892 LCOL_C003-LCOL Q-trackers de Retornos
     3.0        08/01/2013   JMF             0025580: LCOL_C003-LCOL: Parametrizar tomador en el convenio de retorno
     4.0        22/01/2013   JMF             0025815: LCOL: Cambios para Retorno seg?n reuni?n con Comercial
    5.0        29/01/2013   JMF             0025862: LCOL: Suplemento Retorno
   ******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   -- Esta función nos devuelve un VARCHAR2 con la lista de los convenios en función de una série de valores que recibe por parámetros.
   -- BUG 0025691 - 15/01/2013 - JMF: afegir sucursal i adn
   FUNCTION f_get_lstconvenios(
      pccodconv IN VARCHAR2,
      ptdesconv IN VARCHAR2,
      pfinivig IN DATE,
      pffinvig IN DATE,
      pcramo IN NUMBER,
      psproduc IN NUMBER,
      pcagente IN NUMBER,
      ptnombnf IN VARCHAR2,
      psucursal IN NUMBER DEFAULT NULL,
      padnsuc IN NUMBER DEFAULT NULL,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   -- Esta función nos devuelve un VARCHAR2 con los datos del convenio que se ha seleccionado en pantalla
   FUNCTION f_get_datconvenio(pidconvenio IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   -- Esta función nos devuelve un VARCHAR2 con los datos del producto del convenio que se ha seleccionado en pantalla
   FUNCTION f_get_prodconvenio(
      pidconvenio IN NUMBER,
      pcramo OUT NUMBER,
      ptramo OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   -- Esta función nos devuelve un VARCHAR2 con los datos del agente del convenio que se ha seleccionado en pantalla
   FUNCTION f_get_ageconvenio(pidconvenio IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   -- Esta función nos devuelve un VARCHAR2 con los datos del beneficiario del convenio que se ha seleccionado en pantalla
   FUNCTION f_get_benefconvenio(pidconvenio IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   -- Esta función borra datos del agente del convenio
   FUNCTION f_del_ageconvenio(
      pidconvenio IN NUMBER,
      pcagente IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   -- Esta función borra datos del beneficiario del convenio
   FUNCTION f_del_benefconvenio(
      pidconvenio IN NUMBER,
      psperson IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   -- Esta función actualiza datos convenio
   -- BUG 0025815 - 22/01/2013 - JMF: afegir sperson
   FUNCTION f_set_datconvenio(
      pidconvenio IN NUMBER,
      pccodconv IN VARCHAR2,
      ptdesconv IN VARCHAR2,
      pfinivig IN DATE,
      pffinvig IN DATE,
      psperson IN NUMBER,
      pidconvenio_out IN OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   -- Borra la lista actual de productos asociados a un convenio,
   -- y añade los productos de la lista que le llegan de la pantalla.
   FUNCTION f_set_prodconvenio(
      pidconvenio IN NUMBER,
      plistaconve IN t_iax_info,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   -- Esta función actualiza datos agente convenio
   FUNCTION f_set_ageconvenio(
      pidconvenio IN NUMBER,
      pcagente IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   -- Esta función actualiza datos beneficiario convenio
   -- BUG 0025580 - 08/01/2013 - JMF
   FUNCTION f_set_benefconvenio(
      pidconvenio IN NUMBER,
      psperson IN NUMBER,
      ppretorno IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   -- Inicializará la información del retorno
   FUNCTION f_inicializa_retorno(dtpoliza IN ob_iax_detpoliza, mensajes OUT t_iax_mensajes)
      RETURN t_iax_retorno;

   -- BUG 0025862 - 29/01/2013 - JMF
   -- Inicializará la información del retorno para suplementos
   FUNCTION f_suple_retorno(dtpoliza IN ob_iax_detpoliza, mensajes OUT t_iax_mensajes)
      RETURN t_iax_retorno;

   -- Esta función nos devuelve cursor con los convenios
   FUNCTION f_get_rtnconvenios(
      psseguro IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'EST',
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   -- ini BUG 0024892 - 28/11/2012 - JMF
   -- Esta función realiza acciones sobre los campos obligatorios
   -- accion 0 = Validar si falta informacion obligatoria
   -- accion 1 = Borrar estructura del convenio.
   FUNCTION f_oblig_convenio(
      pidconvenio IN NUMBER,
      paccion IN NUMBER,
      presult IN OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   -- Bug 29324/161283 - 12/12/2013 - AMC
   FUNCTION f_busca_convenioretorno(
      psseguro IN NUMBER,
      psproduc IN NUMBER,
      pfefecto IN DATE,
      pcagente IN NUMBER,
      pidconvenio IN OUT NUMBER,
      ptomador IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   --Bug 29324/166247 - 18/02/2014 - AMC
   FUNCTION f_busca_convenioretorno_pol(
      psseguro IN NUMBER,
      psproduc IN NUMBER,
      pfefecto IN DATE,
      pcagente IN NUMBER,
      pidconvenio IN OUT NUMBER,
      ptomador IN NUMBER,
      pdonde OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;
END pac_md_retorno;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_RETORNO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_RETORNO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_RETORNO" TO "PROGRAMADORESCSI";
