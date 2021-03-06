--------------------------------------------------------
--  DDL for Package PAC_IAX_FACTURAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_IAX_FACTURAS" IS
   /******************************************************************************
      NOMBRE:       PAC_IAX_FACTURAS
      PROP�SITO:    Funciones de la capa IAX para realizar acciones sobre la tabla FACTURAS

      REVISIONES:
      Ver        Fecha        Autor             Descripci�n
      ---------  ----------  ---------------  ------------------------------------
      1.0        23/05/2012   APD             1. Creaci�n del package. 0022321: MDP_F001-MDP_A001-Facturas
      2.0        04/09/2012   APD             2. 0023595: MDP_F001- Modificaciones modulo de facturas
   ******************************************************************************/
   vgobfactura    ob_iax_facturas;   --Objeto facturas

   /***********************************************************************
      Recupera los datos de una determinada factura de tablas a objeto
      param in  pnfact  : numero de factura
      param out mensajes  : mensajes de error
      return              : OB_IAX_FACTURAS con la informacion de la factura
                            NULL -> Se ha producido un error
   ***********************************************************************/
   FUNCTION f_inicializafactura(
      pnfact IN VARCHAR2,
      pcagente IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
    Funci�n que realiza la b�squeda de facturas a partir de los criterios de consulta entrados
    param in pcempres     : codigo empresa
    param in pcagente     : codigo de agente
    param in pnnif     : Nif
    param in pnfact     : N� factura
    param in pffact_ini     : fecha inicio emision factura
    param in pffact_fin     : fecha fin emision factura
    param in pcestado     : estado de la factura
    param in pctipfact     : tipo de la factura
    param out ptfacturas  : colecci�n de objetos ob_iax_facturas
    param out mensajes    : colecci�n de objetos ob_iax_mensajes
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
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
    Funci�n que devuelve la informacion de una factura (ob_iax_facturas)
    param in pnfact     : N� factura
    param out pofacturas  : objeto ob_iax_facturas
    param out mensajes    : colecci�n de objetos ob_iax_mensajes
         return             : 0 busqueda correcta
                           <> 0 busqueda incorrecta
   *************************************************************************/
   FUNCTION f_get_factura(
      pnfact IN VARCHAR2,
      pofacturas OUT ob_iax_facturas,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Funcion que inicializa el objeto de OB_IAX_DETFACTURA
      param in pnfact  : numero de factura
      param out mensajes : mensajes de error
      return             : number
   *************************************************************************/
   FUNCTION f_insert_obj_detfactura(
      pnfact IN VARCHAR2,
      pnorden OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Funcion que para actualizar el objeto OB_IAX_DETFACTURA
      param in pnfact  : numero de factura
      param in pnorden  : orden dentro del objeto
      param in pcconcepto :
      param in piimporte :
      param out piirpf:
      param out piimpcta :
      param out piimpneto : se calculta (piimporte - piirpf)
      param out piimpneto_total : se calculta (suma de los importes netos de todos los conceptos)
      param out mensajes : mensajes de error
      return             : number
   *************************************************************************/
   FUNCTION f_set_obj_detfactura(
      pnfact IN VARCHAR2,
      pnorden IN NUMBER,
      pcconcepto IN NUMBER,
      piimporte IN NUMBER,
      piirpf OUT NUMBER,   -- Bug 23595 - APD - 04/09/2012 - irpf campo calculado
      piimpcta OUT NUMBER,   -- Bug 23595 - APD - 04/09/2012 - ingreso a cuenta campo calculado
      piimpneto OUT NUMBER,
      piimpneto_total OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Funcion que elimina un objeto de la coleccion
      param in pnriesgo  : numero de riesgo
      param in pnorden  :
      param out mensajes : mensajes de error
      return             : number
   *************************************************************************/
   FUNCTION f_del_obj_detfactura(
      pnfact IN VARCHAR2,
      pnorden IN NUMBER,
      piimpneto_total OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
    Funci�n que graba en BBDD la coleccion T_IAX_DETFACTURA
    param in pnfact     : N� factura
    param out mensajes    : colecci�n de objetos ob_iax_mensajes
         return             : 0 Todo Ok
                           <> 0 num_err
   *************************************************************************/
   FUNCTION f_set_detfactura(pnfact IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
    Funci�n que graba en BBDD una factura
    param in pcempres     : codigo empresa
    param in pcagente     : codigo de agente
    param in pnnumide     : Nif
    param in pffact     : fecha emision factura
    param in pcestado     : estado de la factura
    param in pctipfact     : tipo de la factura
    param in pctipiva     : tipo de iva la factura
    param out pnfact     : N� factura
    param out mensajes    : colecci�n de objetos ob_iax_mensajes
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
      mensajes OUT t_iax_mensajes,
      pctipdoc IN NUMBER DEFAULT NULL,
      piddocgedox IN NUMBER DEFAULT NULL,
      pnliqmen IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

   /*************************************************************************
    Funci�n que emite una factura
    param in pcempres   : Codigo empresa
    param in pnfact     : N� factura
    param out mensajes    : colecci�n de objetos ob_iax_mensajes
         return             : 0 Todo Ok
                           <> 0 num_err
   *************************************************************************/
   FUNCTION f_emitir_factura(
      pcempres IN NUMBER,
      pnfact IN VARCHAR2,
      pcagente IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
    Funci�n que anula una factura
    param in pcempres   : Codigo empresa
    param in pnfact     : N� factura
    param out mensajes    : colecci�n de objetos ob_iax_mensajes
         return             : 0 Todo Ok
                           <> 0 num_err
   *************************************************************************/
   FUNCTION f_anular_factura(
      pcempres IN NUMBER,
      pnfact IN VARCHAR2,
      pcagente IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
    Funci�n que selecciona datos factura a partir de una carpeta
    param in pCCARPETA   : Codigo carpeta
    param out pobfacturacarpeta    : colecci�n de ob_iax_facturacarpeta
    param out mensajes    : colecci�n de objetos ob_iax_mensajes
         return             : 0 Todo Ok
                           <> 0 num_err
   -- bug 0028554 - 06/02/2014 - JMF
   *************************************************************************/
   FUNCTION f_sel_carpeta(
      pccarpeta IN VARCHAR2,
      pobfacturacarpeta OUT ob_iax_facturacarpeta,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
    Funci�n que asigna numero de folio a partir de un numero interno de factura, tambien trata folios erroneos
    param in pobfacturacarpeta   : Objeto con toda la informacion
    param out mensajes    : colecci�n de objetos ob_iax_mensajes
         return             : 0 Todo Ok
                           <> 0 num_err
   -- bug 0028554 - 06/02/2014 - JMF
   *************************************************************************/
   FUNCTION f_asigna_carpeta(
      pobfacturacarpeta IN ob_iax_asigfactura,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
    Funci�n que genera impresos de una carpeta
    param in pCCARPETA   : Codigo carpeta
    param out mensajes    : colecci�n de objetos ob_iax_mensajes
         return             : 0 Todo Ok
                           <> 0 num_err
   -- bug 0028554 - 06/02/2014 - JMF
   *************************************************************************/
   FUNCTION f_genera_carpeta(pccarpeta IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

      /*************************************************************************
    Funcion que retorna la lista de valores de numeros de liquidacion disponibles por agente
    param in f_get_listnliqmen   : codigo de agente
         return             : Cursor con el listado de vlores posibles

   *************************************************************************/
   FUNCTION f_get_listnliqmen(pcagente IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_autoriza_factura(
      pcempres IN NUMBER,
      pnfact IN VARCHAR2,
      pcagente IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;
END pac_iax_facturas;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_FACTURAS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_FACTURAS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_FACTURAS" TO "PROGRAMADORESCSI";
