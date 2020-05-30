--------------------------------------------------------
--  DDL for Package PAC_COMISIONEGOCIO
--------------------------------------------------------

  CREATE OR REPLACE  PACKAGE "AXIS"."PAC_COMISIONEGOCIO" AS
   /******************************************************************************
     NOMBRE:     pac_comisionegocio
     PROPÓSITO:  Package para gestionar los convenios de comisión especial

     REVISIONES:
     Ver        Fecha        Autor             Descripción
     ---------  ----------  ---------------  ------------------------------------
     1.0        19/12/2012   FAL             0025214: LCOL_C004-LCOL: Realizar desarrollo Comisiones Especiales negocio
    ******************************************************************************/

   /*************************************************************************
      Recupera la lista de los convenios de comisión especial en función de los parámetros recibidos
      param in pccodconv : identificador del convenio
      param in ptdesconv : descripción del convenio
      param in pfinivig  : fecha de inicio de vigencia del convenio
      param in pffinvig  : fecha de fin de vigencia del convenio
      param in psproduc  : código de producto
      param in pcagente  : código de agente
      param in ptnomtom  : nombre de tomador
      param in pcramo    : código de ramo
      return             : texto de la consulta
   *************************************************************************/
   FUNCTION f_get_lstconvcomesp(
      pccodconv IN NUMBER,
      ptdesconv IN VARCHAR2,
      pfinivig IN DATE,
      pffinvig IN DATE,
      psproduc IN NUMBER,
      pcagente IN NUMBER,
      ptnomtom IN VARCHAR2,
      pcramo IN NUMBER)
      RETURN VARCHAR2;

   /*************************************************************************
      Recupera los datos del convenio de comisión especial
      param in pccodconv : identificador del convenio
      return             : texto de la consulta
   *************************************************************************/
   FUNCTION f_get_datconvcomesp(pccodconv IN NUMBER)
      RETURN VARCHAR2;

   /*************************************************************************
      Recupera los datos del producto del convenio de comisión especial
      param in pccodconv : identificador del convenio
      return             : texto de la consulta
   *************************************************************************/
   FUNCTION f_get_prodconvcomesp(pccodconv IN NUMBER)
      RETURN VARCHAR2;

   /*************************************************************************
      Recupera los datos del agente del convenio de comisión especial
      param in pccodconv : identificador del convenio
      return             : texto de la consulta
   *************************************************************************/
   FUNCTION f_get_ageconvcomesp(pccodconv IN NUMBER)
      RETURN VARCHAR2;

   /*************************************************************************
      Recupera los datos del tomador del convenio de comisión especial
      param in pccodconv : identificador del convenio
      return             : texto de la consulta
   *************************************************************************/
   FUNCTION f_get_tomconvcomesp(pccodconv IN NUMBER)
      RETURN VARCHAR2;

   /*************************************************************************
      Borra los el agente de un convenio de comisión especial
      param in pccodconv : identificador del convenio
      param in pcagente  : código de agente
      return             : 0 si está todo Ok y 1 si existe algún tipo de error
   *************************************************************************/
   FUNCTION f_del_ageconvcomesp(pccodconv IN NUMBER, pcagente IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
      Borra el tomador de un convenio de comisión especial
      param in pccodconv : identificador del convenio
      param in psperson  : código del tomador
      return             : 0 si está todo Ok y 1 si existe algún tipo de error
   *************************************************************************/
   FUNCTION f_del_tomconvcomesp(pccodconv IN NUMBER, psperson IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
      Actualiza/inserta los datos de un convenio de comisión especial
      param in pccodconv : identificador del convenio
      param in ptdesconv : descripción del convenio
      param in pfinivig  : fecha de inicio de vigencia del convenio
      param in pffinvig  : fecha de fin de vigencia del convenio
      param in pccomisi  : % de comisión especial del convenio
      param in pcusualt  : usuario de alta
      param out pccodconv_out  : identificador del nuevo convenio creado
      return             : 0 si está todo Ok y 1 si existe algún tipo de error
   *************************************************************************/
   FUNCTION f_set_datconvcomesp(
      pccodconv IN NUMBER,
      ptdesconv IN VARCHAR2,
      pfinivig IN DATE,
      pffinvig IN DATE,
      pccomisi IN FLOAT,
      pcmodcom IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
      Parametriza un producto como afectado por un convenio de comisión especial
      param in pccodconv : identificador del convenio
      param in psproduc  : código de producto
      return             : 0 si está todo Ok y 1 si existe algún tipo de error
   *************************************************************************/
   FUNCTION f_set_prodconvcomesp(pccodconv IN NUMBER, psproduc IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
      Parametriza un agente como afectado por un convenio de comisión especial
      param in pccodconv : identificador del convenio
      param in pcagente  : código de agente
      return             : 0 si está todo Ok y 1 si existe algún tipo de error
   *************************************************************************/
   FUNCTION f_set_ageconvcomesp(pccodconv IN NUMBER, pcagente IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
      Parametriza un tomador como afectado por un convenio de comisión especial
      param in pccodconv : identificador del convenio
      param in psperson  : código del tomador
      return             : 0 si está todo Ok y 1 si existe algún tipo de error
   *************************************************************************/
   FUNCTION f_set_tomconvcomesp(pccodconv IN NUMBER, psperson IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
      Valida la creación/modificación de un convenio
      param in pccodconv : identificador del convenio
      param in pfinivig  : fecha de inicio de vigencia del convenio
      param in pffinvig  : fecha de fin de vigencia del convenio
      param in plistaprods : colección de productos que intervienen en el convenio
      param in pcagente  : % de comisión especial del convenio
      param in psperson  : sperson del tomador que interviene en el convenio
      param in pprimausd  : prima en USD
      param in pprimaeur  : prima en EUR
      return            : 0 si está todo Ok y 1 si existe algún tipo de error
   *************************************************************************/
   FUNCTION f_valida_creaconv(
      pccodconv IN NUMBER,
      pfinivig IN DATE,
      pffinvig IN DATE,
      plistaprods IN t_iax_info,
      pcagente IN NUMBER,
      psperson IN NUMBER,
      pprimausd IN NUMBER,
      pprimaeur IN NUMBER)
      RETURN NUMBER;

/*
   FUNCTION f_set_porcenconvcomesp(
      pccodconv IN NUMBER,
      pcmodcom IN NUMBER,
      ppcomisi IN FLOAT)
      RETURN NUMBER;
*/
   FUNCTION f_get_next_conv
      RETURN NUMBER;

   /*************************************************************************
      Nos devuelve si un tomador o agente tiene parametrizado un convenio
      param in pspersonton : identificador del tomador
      param in pcagente    : identificador del agente
      param in pfefecto    : fecha de efecto de la poliza
      param out pconvenio  : 0 - no tiene conveno parametrizado 1 - Si
      return             : Codigo de error

      Bug 27327/146916 - 27/06/2013 - AMC
   *************************************************************************/
   FUNCTION f_get_tieneconvcomesp(
      pspersonton IN NUMBER,
      pcagente IN NUMBER,
      psproduc IN NUMBER,
      pfefecto IN DATE,
      pconvenio OUT NUMBER)
      RETURN NUMBER;
	  
	  
  /*************************************************************************
      Parametriza un tomador como afectado por un convenio de comisión especial en la tabla SGT
      param in psproduc : identificador del producto
      param in pnnumide  : Numero identificacion del tomador
      return             : 0 si está todo Ok y 1 si existe algún tipo de error
   *************************************************************************/
   FUNCTION f_set_subtabsdet(psproduc IN NUMBER, pnnumide IN NUMBER, ptasa IN NUMBER, pprima IN NUMBER, pcodconv IN NUMBER, pcodgarantia IN NUMBER)
      RETURN NUMBER; 

/*************************************************************************
      Obtiene la tasa o prima de un producto para un asegurado
      param in pccodconv : identificador del convenio
      param in pcnnumide  : numero identificacion asegurado
      param in pccodproducto : identificador del producto
      param in pcopcion  : opcion a consultar (1-> Tasa, 2-> Prima)
      return             : 0 si está todo Ok y 1 si existe algún tipo de error
   *************************************************************************/
   FUNCTION f_get_tasa_prima(pccodconv IN NUMBER, pcnnumide IN NUMBER, pccodproducto IN NUMBER, pcopcion IN NUMBER, pccodgarantia IN NUMBER)
      RETURN NUMBER;	

/*************************************************************************
      Funcion para gurdar la prima normal, en USD y EUR de un convenio
      param in pccodconv : identificador del convenio
      param in pprima  : prima del convenio
      param in pprimausd : prima del convenio en moneda USD
      param in pprimaeur  : prima del convenio en moneda EUR
      return             : 0 si está todo Ok y 1 si existe algún tipo de error
   *************************************************************************/
   FUNCTION f_set_convprima(pccodconv IN NUMBER, pprima IN NUMBER, pprimausd IN NUMBER, pprimaeur IN NUMBER)
      RETURN NUMBER; 	  
	  
END pac_comisionegocio;

/
