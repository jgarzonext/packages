--------------------------------------------------------
--  DDL for Package PAC_IAX_COMISIONEGOCIO
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE "AXIS"."PAC_IAX_COMISIONEGOCIO" AS
   /******************************************************************************
     NOMBRE:     pac_iax_comisionegocio
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
      param out mensajes : colección mensajes error
      return             : sys_refcursor
   *************************************************************************/
   FUNCTION f_get_lstconvcomesp(
      pccodconv IN NUMBER,
      ptdesconv IN VARCHAR2,
      pfinivig IN DATE,
      pffinvig IN DATE,
      psproduc IN NUMBER,
      pcagente IN NUMBER,
      ptnomtom IN VARCHAR2,
      pcramo IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera los datos del convenio de comisión especial
      param in pccodconv : identificador del convenio
      param out mensajes : colección mensajes error
      return             : sys_refcursor
   *************************************************************************/
   FUNCTION f_get_datconvcomesp(pccodconv IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN ob_iax_convcomesp;

   /*************************************************************************
      Recupera los datos del producto del convenio de comisión especial
      param in pccodconv : identificador del convenio
      param out mensajes : colección mensajes error
      return             : sys_refcursor
   *************************************************************************/
   FUNCTION f_get_prodconvcomesp(pccodconv IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera los datos del agente del convenio de comisión especial
      param in pccodconv : identificador del convenio
      param out mensajes : colección mensajes error
      return             : sys_refcursor
   *************************************************************************/
   FUNCTION f_get_ageconvcomesp(pccodconv IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera los datos del tomador del convenio de comisión especial
      param in pccodconv : identificador del convenio
      param out mensajes : colección mensajes error
      return             : sys_refcursor
   *************************************************************************/
   FUNCTION f_get_tomconvcomesp(pccodconv IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Borra los el agente de un convenio de comisión especial
      param in pccodconv : identificador del convenio
      param in pcagente  : código de agente
      param out mensajes : colección mensajes error
      return             : 0 si está todo Ok y 1 si existe algún tipo de error
   *************************************************************************/
   FUNCTION f_del_ageconvcomesp(
      pccodconv IN NUMBER,
      pcagente IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Borra el tomador de un convenio de comisión especial
      param in pccodconv : identificador del convenio
      param in psperson  : código del tomador
      param out mensajes : colección mensajes error
      return             : 0 si está todo Ok y 1 si existe algún tipo de error
   *************************************************************************/
   FUNCTION f_del_tomconvcomesp(
      pccodconv IN NUMBER,
      psperson IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

  /*************************************************************************
      Actualiza/inserta los datos de un convenio de comisión especial
      param in pccodconv : identificador del convenio
      param in ptdesconv : descripción del convenio
      param in pfinivig  : fecha de inicio de vigencia del convenio
      param in pffinvig  : fecha de fin de vigencia del convenio
      param in plistaprods : colección de productos que intervienen en el convenio
      param in plistacomis : colección de comisiones que intervienen en el convenio (según cmodcom con su %)
      param in pcagente  : % de comisión especial del convenio
      param in psperson  : sperson del tomador que interviene en el convenio
      param in pprimausd  : prima en USD
      param in pprimaeur  : prima en EUR
      param out pccodconv_out  : identificador del nuevo convenio creado
      param out mensajes : colección mensajes error
      return             : 0 si está todo Ok y 1 si existe algún tipo de error
   *************************************************************************/
   --INI IAXIS 4081 AABG: Se realiza insercion en nueva tabla y con los nuevos parametros
   FUNCTION f_set_datconvcomesp(
      pccodconv IN NUMBER,
      ptdesconv IN VARCHAR2,
      pfinivig IN DATE,
      pffinvig IN DATE,
      plistaprods IN t_iax_info,
      plistacomis IN t_iax_info,
      pcagente IN NUMBER,
      psperson IN VARCHAR2,
      pnnumide IN VARCHAR2,
      ptasa IN  NUMBER,
      pprima IN NUMBER,
      pprimausd IN NUMBER,
      pprimaeur IN NUMBER,
      pccodconv_out OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;
 --FIN IAXIS 4081 AABG: Se realiza insercion en nueva tabla y con los nuevos parametros 

/*************************************************************************
   Parametriza un producto como afectado por un convenio de comisión especial
   param in pccodconv : identificador del convenio
   param in plistaprods  : colección de ids de producto
   param out mensajes : colección mensajes error
   return             : 0 si está todo Ok y 1 si existe algún tipo de error
*************************************************************************/

   /*
      FUNCTION f_set_prodconvcomesp(
         pccodconv IN NUMBER,
         plistaprods IN t_iax_info,
         mensajes OUT t_iax_mensajes)
         RETURN NUMBER;
   */

   /*************************************************************************
      Parametriza un agente como afectado por un convenio de comisión especial
      param in pccodconv : identificador del convenio
      param in pcagente  : código de agente
      param out mensajes : colección mensajes error
      return             : 0 si está todo Ok y 1 si existe algún tipo de error
   *************************************************************************/

   /*
      FUNCTION f_set_ageconvcomesp(
         pccodconv IN NUMBER,
         pcagente IN NUMBER,
         mensajes OUT t_iax_mensajes)
         RETURN NUMBER;
   */

   /*************************************************************************
      Parametriza un tomador como afectado por un convenio de comisión especial
      param in pccodconv : identificador del convenio
      param in psperson  : código del tomador
      param out mensajes : colección mensajes error
      return             : 0 si está todo Ok y 1 si existe algún tipo de error
   *************************************************************************/

   /*
      FUNCTION f_set_tomconvcomesp(
         pccodconv IN NUMBER,
         psperson IN NUMBER,
         mensajes OUT t_iax_mensajes)
         RETURN NUMBER;
   */

   /*************************************************************************
      Recuperar la modalidad y % de comisión especial de un convenio
      param in psproduc : código del producto
      param in pcagente : código de agente
      param in psperson : código del tomador
      param in pfemisio : fecha emisión de la póliza
      param out mensajes : colección mensajes error
      return            : t_iax_gstcomision
   *************************************************************************/
   FUNCTION f_get_porcenconvcomesp(
      psproduc IN NUMBER,
      pcagente IN NUMBER,
      psperson IN NUMBER,
      pfemisio IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN t_iax_gstcomision;

   /*************************************************************************
      Recuperar el siguiene código de convenio

      return  : id del convenio
   *************************************************************************/
   FUNCTION f_get_next_conv(pccodconv_out OUT NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Nos devuelve si un tomador o agente tiene parametrizado un convenio
      param in pspersonton : identificador del tomador
      param in pcagente    : identificador del agente
      param out pconvenio  : 0 - no tiene conveno parametrizado 1 - Si
      return             : Codigo de error

      Bug 27327/146916 - 27/06/2013 - AMC
   *************************************************************************/
   FUNCTION f_get_tieneconvcomesp(
      pspersonton IN NUMBER,
      pcagente IN NUMBER,
      psproduc IN NUMBER,
      pfefecto IN DATE,
      pconvenio OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;
	  
    /*************************************************************************
      Obtiene la tasa o prima de un producto para un asegurado
      param in pccodconv : identificador del convenio
      param in pcnnumide  : numero identificacion asegurado
      param in pccodproducto : identificador del producto
      param in pcopcion  : opcion a consultar (1-> Tasa, 2-> Prima)
      return             : 0 si está todo Ok y 1 si existe algún tipo de error
   *************************************************************************/
   FUNCTION f_get_tasa_prima(
      pccodconv IN NUMBER, 
      pcnnumide IN NUMBER, 
      pccodproducto IN NUMBER, 
      pcopcion IN NUMBER,
      pccodgarantia IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER; 	  
	  
END pac_iax_comisionegocio;

/