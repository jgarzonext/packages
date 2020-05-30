--------------------------------------------------------
--  DDL for Package PAC_RETORNO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_RETORNO" AS
   /******************************************************************************
     NOMBRE:     pac_retorno
     PROPÓSITO:  Package para gestionar los retornos de convenios beneficiarios

     REVISIONES:
     Ver        Fecha        Autor             Descripción
     ---------  ----------  ---------------  ------------------------------------
     1.0        03/09/2012   JMF             0022701: LCOL: Implementación de Retorno
     2.0        25/10/2012   DRA             0023853: LCOL - PRIMAS MÍNIMAS PACTADAS POR PÓLIZA Y POR COBRO
     3.0        28/11/2012   JMF             0024892 LCOL_C003-LCOL Q-trackers de Retornos
     4.0        08/01/2013   JMF             0025580: LCOL_C003-LCOL: Parametrizar tomador en el convenio de retorno
     5.0        22/01/2013   JMF             0025815: LCOL: Cambios para Retorno seg?n reuni?n con Comercial
    11.0        08/02/2013   MAL             0025942: LCOL: Ajuste de q-trackers retorno
    13.0        20/02/2013   FAL             0025691: LCOL: Validaciones m?dulo de retornos
   ******************************************************************************/

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
      psucursal IN NUMBER,
      padnsuc IN NUMBER)
      RETURN VARCHAR2;

   -- Esta función nos devuelve un VARCHAR2 con los datos del convenio que se ha seleccionado en pantalla
   FUNCTION f_get_datconvenio(pidconvenio IN NUMBER)
      RETURN VARCHAR2;

   -- Esta función nos devuelve un VARCHAR2 con los datos del producto del convenio que se ha seleccionado en pantalla
   FUNCTION f_get_prodconvenio(pidconvenio IN NUMBER, pcramo OUT NUMBER, ptramo OUT VARCHAR2)
      RETURN VARCHAR2;

   -- Esta función nos devuelve un VARCHAR2 con los datos del agente del convenio que se ha seleccionado en pantalla
   FUNCTION f_get_ageconvenio(pidconvenio IN NUMBER)
      RETURN VARCHAR2;

   -- Esta función nos devuelve un VARCHAR2 con los datos del beneficiario del convenio que se ha seleccionado en pantalla
   FUNCTION f_get_benefconvenio(pidconvenio IN NUMBER)
      RETURN VARCHAR2;

   -- Esta función borra datos del agente del convenio
   FUNCTION f_del_ageconvenio(pidconvenio IN NUMBER, pcagente IN NUMBER)
      RETURN NUMBER;

   -- Esta función borra datos del beneficiario del convenio
   FUNCTION f_del_benefconvenio(pidconvenio IN NUMBER, psperson IN NUMBER)
      RETURN NUMBER;

   -- Esta función actualiza datos convenio
   -- BUG 0025815 - 22/01/2013 - JMF: afegir sperson
   FUNCTION f_set_datconvenio(
      pidconvenio IN NUMBER,
      pccodconv IN VARCHAR2,
      ptdesconv IN VARCHAR2,
      pfinivig IN DATE,
      pffinvig IN DATE,
      pcuseraut IN VARCHAR2,
      psperson IN NUMBER,
      pidconvenio_out IN OUT NUMBER,
      pdirecpol IN NUMBER DEFAULT 0)   -- BUG 0025691/0138159 - FAL - 20/02/2013
      RETURN NUMBER;

   -- Esta función actualiza datos producto convenio
   FUNCTION f_set_prodconvenio(pidconvenio IN NUMBER, psproduc IN NUMBER)
      RETURN NUMBER;

   -- Esta función actualiza datos agente convenio
   FUNCTION f_set_ageconvenio(pidconvenio IN NUMBER, pcagente IN NUMBER)
      RETURN NUMBER;

   -- Esta función actualiza datos beneficiario convenio
   -- BUG 0025580 - 08/01/2013 - JMF
   FUNCTION f_set_benefconvenio(pidconvenio IN NUMBER, psperson IN NUMBER, ppretorno IN NUMBER)
      RETURN NUMBER;

   -- Esta función nos devolverá 0 ó 1 en función de si el seguro que se pasa por parámetro
   -- tiene información de beneficiarios de retorno grabada.
   FUNCTION f_tiene_retorno(
      pnsesion IN NUMBER,
      psseguro IN NUMBER,
      pnmovimi IN NUMBER DEFAULT NULL,
      ptablas IN VARCHAR2 DEFAULT 'SEG')
      RETURN NUMBER;

   -- Esta función realizará la generación de los recibos de retorno según el porcentaje
   -- de los diferentes beneficiarios grabados en la tabla RTN_CONVENIO, y en función del
   -- porcentaje asignado a cada uno.
   FUNCTION f_generar_retorno(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pnrecibo IN NUMBER,
      psproces IN NUMBER,
      pmodo IN VARCHAR2 DEFAULT 'R',
      ptipo IN VARCHAR2 DEFAULT 'NO')
      RETURN NUMBER;

   -- Buscar convenio del retorno
   -- BUG 0025815 - 22/01/2013 - JMF
   FUNCTION f_busca_convenioretorno(
      psseguro IN NUMBER,
      psproduc IN NUMBER,
      pfefecto IN DATE,
      pcagente IN NUMBER,
      pidconvenio IN OUT NUMBER,
      ptomador IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

   -- Inicializará la información del retorno
   FUNCTION f_inicializa_retorno(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      psproduc IN NUMBER,
      pfefecto IN DATE,
      pcagente IN NUMBER,
      psquery IN OUT VARCHAR2)
      RETURN NUMBER;

   -- Inicializará la información del retorno
   FUNCTION f_get_rtnconvenios(
      psseguro IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'EST',
      psquery IN OUT VARCHAR2)
      RETURN NUMBER;

   -- BUG 0024892 - 28/11/2012 - JMF
   -- Esta función realiza acciones sobre los campos obligatorios
   -- accion 0 = Validar si falta informacion obligatoria
   -- accion 1 = Borrar estructura del convenio.
   FUNCTION f_oblig_convenio(pidconvenio IN NUMBER, paccion IN NUMBER, presult IN OUT VARCHAR2)
      RETURN NUMBER;

   -- Esta función valida el producto del convenio
   FUNCTION f_valida_prodconvenio(pidconvenio IN NUMBER, psproduc IN NUMBER)
      RETURN NUMBER;

   -- Esta función  valida el agente del convenio
   FUNCTION f_valida_agenconvenio(pidconvenio IN NUMBER, pcagente IN NUMBER)
      RETURN NUMBER;

   -- Esta función  valida el que no existan convenios de caracteristicas parecidas
   FUNCTION f_hay_convenios_iguales(
      pidconvenio IN NUMBER,
      pfinivig IN DATE DEFAULT NULL,
      pffinvig IN DATE DEFAULT NULL,
      psproduc IN NUMBER DEFAULT NULL,
      pcagente IN NUMBER DEFAULT NULL,
      pcpersona IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

   --Bug 29324/166247 - 18/02/2014 - AMC
   FUNCTION f_busca_convenioretorno_pol(
      psseguro IN NUMBER,
      psproduc IN NUMBER,
      pfefecto IN DATE,
      pcagente IN NUMBER,
      pidconvenio IN OUT NUMBER,
      pdonde OUT NUMBER,
      ptomador IN NUMBER DEFAULT NULL)
      RETURN NUMBER;
END pac_retorno;

/

  GRANT EXECUTE ON "AXIS"."PAC_RETORNO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_RETORNO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_RETORNO" TO "PROGRAMADORESCSI";
