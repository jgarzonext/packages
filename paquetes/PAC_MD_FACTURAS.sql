--------------------------------------------------------
--  DDL for Package PAC_MD_FACTURAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_MD_FACTURAS" IS
   /******************************************************************************
      NOMBRE:       PAC_MD_FACTURAS
      PROPÓSITO:    Funciones de la capa MD para realizar acciones sobre la tabla FACTURAS

      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.0        23/05/2012   APD             1. Creación del package. 0022321: MDP_F001-MDP_A001-Facturas
      2.0        04/09/2012   APD             2. 0023595: MDP_F001- Modificaciones modulo de facturas
   ******************************************************************************/

   /*************************************************************************
    Función que realiza la búsqueda de facturas a partir de los criterios de consulta entrados
    param in pcempres     : codigo empresa
    param in pcagente     : codigo de agente
    param in pnnumide     : Nif
    param in pnfact     : Nº factura
    param in pffact_ini     : fecha inicio emision factura
    param in pffact_fin     : fecha fin emision factura
    param in pcestado     : estado de la factura
    param in pctipfact     : tipo de la factura
    param in out ptfacturas  : colección de objetos ob_iax_facturas
    param out mensajes    : colección de objetos ob_iax_mensajes
         return             : 0 busqueda correcta
                           <> 0 busqueda incorrecta
   *************************************************************************/
   FUNCTION f_get_facturas(
      pcempres IN NUMBER,
      pcagente IN NUMBER,
      pnnumide IN VARCHAR2,
      pnfact IN VARCHAR2,
      pffact_ini IN DATE,
      pffact_fin IN DATE,
      pcestado IN NUMBER,
      pctipfact IN NUMBER,
      pcautorizada IN NUMBER,
      ptfacturas OUT t_iax_facturas,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
    Función que devuelve la informacion de una factura (ob_iax_facturas)
    param in pnfact     : Nº factura
    param out pofacturas  : objeto ob_iax_facturas
    param in out mensajes    : colección de objetos ob_iax_mensajes
         return             : 0 busqueda correcta
                           <> 0 busqueda incorrecta
   *************************************************************************/
   FUNCTION f_get_factura(
      pnfact IN VARCHAR2,
      pcagente IN NUMBER,
      pofacturas IN OUT ob_iax_facturas,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
    Función que devuelve la informacion del detalle de una factura (t_iax_detfactura)
    param in pnfact     : Nº factura
    param out pofacturas  : objeto ob_iax_facturas
    param in out mensajes    : colección de objetos ob_iax_mensajes
         return             : 0 busqueda correcta
                           <> 0 busqueda incorrecta
   *************************************************************************/
   FUNCTION f_get_detfactura(
      pnfact IN VARCHAR2,
      pcagente IN NUMBER,
      ptdetfactura OUT t_iax_detfactura,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Funcion que inicializa el objeto de OB_IAX_DETFACTURA
      param in pobfact  : objeto OB_IAX_FACTURAS
      param out mensajes : mensajes de error
      return             : number
   *************************************************************************/
   FUNCTION f_insert_obj_detfactura(
      pobfact IN ob_iax_facturas,
      pnorden IN OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_detfactura;

   /*************************************************************************
      Funcion que para actualizar el objeto OB_IAX_DETFACTURA
      param in pnfact  : numero de factura
      param in pnorden  : orden dentro del objeto
      param in pcconcepto :
      param in piimporte :
      param in out piirpf:
      param in out piimpcta :
      param out piimpneto : se calculta (piimporte - piirpf)
      param out piimpneto_total : se calculta (suma de los importes netos de todos los conceptos)
      param out mensajes : mensajes de error
      return             : number
   *************************************************************************/
   FUNCTION f_set_obj_detfactura(
      pobfact IN ob_iax_facturas,
      pnfact IN VARCHAR2,
      pnorden IN NUMBER,
      pcconcepto IN NUMBER,
      piimporte IN NUMBER,
      piirpf IN OUT NUMBER,   -- Bug 23595 - APD - 04/09/2012 - irpf campo calculado
      piimpcta IN OUT NUMBER,   -- Bug 23595 - APD - 04/09/2012 - ingreso a cuenta campo calculado
      piimpneto IN OUT NUMBER,
      piimpneto_total IN OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_detfactura;

   /*************************************************************************
    Función que graba en BBDD la coleccion T_IAX_DETFACTURA
    param in pnfact     : Nº factura
    param out mensajes    : colección de objetos ob_iax_mensajes
         return             : 0 Todo Ok
                           <> 0 num_err
   *************************************************************************/
   FUNCTION f_set_detfactura(
      pobfact IN ob_iax_facturas,
      pnfact IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
    Función que graba en BBDD una factura
    param in pcempres     : codigo empresa
    param in pcagente     : codigo de agente
    param in pnnumide     : Nif
    param in pffact     : fecha emision factura
    param in pcestado     : estado de la factura
    param in pctipfact     : tipo de la factura
    param in pctipiva     : tipo de iva la factura
    param out pnfact     : Nº factura
    param in out mensajes    : colección de objetos ob_iax_mensajes
         return             : 0 busqueda correcta
                           <> 0 busqueda incorrecta
   *************************************************************************/
   FUNCTION f_set_factura(
      pcempres IN NUMBER,
      pcagente IN NUMBER,
      pffact IN DATE,
      pcestado IN NUMBER,
      pctipfact IN NUMBER,
      pctipiva IN NUMBER,
      pnfact IN VARCHAR2,
      onfact OUT VARCHAR2,
      mensajes IN OUT t_iax_mensajes,
      pctipdoc IN NUMBER DEFAULT NULL,
      piddocgedox IN NUMBER DEFAULT NULL,
      pnliqmen IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

   /*************************************************************************
    Función que emite una factura
    param in pcempres   : Codigo empresa
    param in pnfact     : Nº factura
    param in out mensajes    : colección de objetos ob_iax_mensajes
         return             : 0 Todo Ok
                           <> 0 num_err
   *************************************************************************/
   FUNCTION f_emitir_factura(
      pcempres IN NUMBER,
      pnfact IN VARCHAR2,
      pcagente IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
    Función que anula una factura
    param in pcempres   : Codigo empresa
    param in pnfact     : Nº factura
    param in out mensajes    : colección de objetos ob_iax_mensajes
         return             : 0 Todo Ok
                           <> 0 num_err
   *************************************************************************/
   FUNCTION f_anular_factura(
      pcempres IN NUMBER,
      pnfact IN VARCHAR2,
      pcagente IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
    Función que selecciona datos factura a partir de una carpeta
    param in pCCARPETA   : Codigo carpeta
    param out pobfacturacarpeta    : colección de ob_iax_facturacarpeta
    param out mensajes    : colección de objetos ob_iax_mensajes
         return             : 0 Todo Ok
                           <> 0 num_err
   -- bug 0028554 - 06/02/2014 - JMF
   *************************************************************************/
   FUNCTION f_sel_carpeta(
      pccarpeta IN VARCHAR2,
      pobfacturacarpeta OUT ob_iax_facturacarpeta,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
    Función que asigna numero de folio a partir de un numero interno de factura, tambien trata folios erroneos
    param in pobfacturacarpeta   : Objeto con toda la informacion
    param out mensajes    : colección de objetos ob_iax_mensajes
         return             : 0 Todo Ok
                           <> 0 num_err
   -- bug 0028554 - 06/02/2014 - JMF
   *************************************************************************/
   FUNCTION f_asigna_carpeta(
      pobfacturacarpeta IN ob_iax_asigfactura,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
    Función que genera impresos de una carpeta
    param in pCCARPETA   : Codigo carpeta
    param in pcempres   : Codigo empresa
    param in pcidioma   : Codigo idioma
         return             : 0 Todo Ok
                           <> 0 num_err
   -- bug 0028554 - 06/02/2014 - JMF
   *************************************************************************/
   FUNCTION f_genera_carpeta(pccarpeta IN VARCHAR2, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
    Proceso emite facturas (emision y cobro) y despues imprime
   -- bug 0028554 - 06/02/2014 - JMF
   *************************************************************************/
   FUNCTION f_emiteimprime_batch(
      pdesde IN DATE,
      phasta IN DATE,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Funcion que retorna la lista de valores de numeros de liquidacion disponibles por agente
      param in f_get_listnliqmen   : codigo de agente
           return             : Cursor con el listado de vlores posibles

     *************************************************************************/
   FUNCTION f_get_listnliqmen(pcagente IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
    Función que autoriza una factura
    param in pcempres   : Codigo empresa
    param in pnfact     : Nº factura
    param out mensajes    : colección de objetos ob_iax_mensajes
         return             : 0 Todo Ok
                           <> 0 num_err
   *************************************************************************/
   FUNCTION f_autoriza_factura(
      pcempres IN NUMBER,
      pnfact IN VARCHAR2,
      pcagente IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;
END pac_md_facturas;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_FACTURAS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_FACTURAS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_FACTURAS" TO "PROGRAMADORESCSI";
