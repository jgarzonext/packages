--------------------------------------------------------
--  DDL for Package PAC_FACTURAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_FACTURAS" IS
   /******************************************************************************
      NOMBRE:       PAC_FACTURAS
      PROPÓSITO:    Funciones de la capa lógica para realizar acciones sobre la tabla FACTURAS

      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.0        23/05/2012   APD             1. Creación del package. 0022321: MDP_F001-MDP_A001-Facturas
      2.0        04/09/2012   APD             2. 0023595: MDP_F001- Modificaciones modulo de facturas
   ******************************************************************************/

   /**************************************************************************************/
   TYPE longitud IS TABLE OF NUMBER(3, 0);   -- INDEX BY BINARY_INTEGER;

   TYPE vector IS TABLE OF VARCHAR2(1)
      INDEX BY BINARY_INTEGER;

   TYPE t_campos IS TABLE OF VARCHAR2(70);   -- INDEX BY BINARY_INTEGER;

   v_descartados  vector;
   cabecera       longitud := longitud(1, 2, 8, 10, 1, 4, 50);
   detaller2      longitud := longitud(1, 7, 7, 50, 11, 14, 2, 30, 10);
   detaller3      longitud := longitud(1, 2, 3, 50, 8, 7, 11, 5, 11, 1, 3);
   os             VARCHAR2(10) := 'Windows';

   PROCEDURE init_vector;   -- (descartados IN OUT vector);

   PROCEDURE activar_elm( /*descartados IN OUT vector,*/i NUMBER);

   PROCEDURE desactivar_elm( /*descartados IN OUT vector,*/i NUMBER);

   FUNCTION leer_elm(i NUMBER)
      RETURN VARCHAR2;

   FUNCTION abrir(filename IN VARCHAR2, modo IN VARCHAR2)
      RETURN UTL_FILE.file_type;

   PROCEDURE desplegar_fijo(linea IN VARCHAR2, l IN longitud, campos IN OUT t_campos);

   PROCEDURE desplegar(
      p_linea IN VARCHAR2,
      delimitador IN VARCHAR2 DEFAULT '|',
      campos IN OUT t_campos);

/**************************************************************************************/

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
    param in pcidioma     : codigo idioma
    param in pcautorica : codigo autorizacion
    param out pquery      : select a ejcutar
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
      pcidioma IN NUMBER,
      pcautorizada IN NUMBER,
      pquery OUT VARCHAR2)
      RETURN NUMBER;

   /*************************************************************************
    Función que devuelve la cabecera de una factura
    param in pnfact     : Nº factura
    param in pcidioma     : codigo idioma
    param out pquery      : select a ejcutar
         return             : 0 busqueda correcta
                           <> 0 busqueda incorrecta
   *************************************************************************/
   FUNCTION f_get_factura(
      pnfact IN VARCHAR2,
      pcagente IN NUMBER,
      pcidioma IN NUMBER,
      pquery OUT VARCHAR2)
      RETURN NUMBER;

   /*************************************************************************
    Función que devuelve el detalle de una factura
    param in pnfact     : Nº factura
    param out pquery      : select a ejcutar
         return             : 0 busqueda correcta
                           <> 0 busqueda incorrecta
   *************************************************************************/
   FUNCTION f_get_detfactura(
      pnfact IN VARCHAR2,
      pcagente IN NUMBER,
      pcidioma IN NUMBER,
      pquery OUT VARCHAR2)
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
    param in out pnfact     : Nº factura
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
      pctipdoc IN NUMBER DEFAULT NULL,
      piddocgedox IN NUMBER DEFAULT NULL,
      pnliqmen IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

   /*************************************************************************
    Función que devuelve el número de la factura
    param in pcempres     : codigo empresa
    param in pcagente     : codigo de agente
    param in pffact     : fecha emision factura
    param in out pnfact     : Nº factura
         return             : 0 busqueda correcta
                           <> 0 busqueda incorrecta
   *************************************************************************/
   FUNCTION f_get_nfact(
      pcempres IN NUMBER,
      pcagente IN NUMBER,
      pffact IN DATE,
      pnfact IN OUT VARCHAR2)
      RETURN VARCHAR2;

   /*************************************************************************
    Función que emite una factura
    param in pcempres   : Codigo empresa
    param in pnfact     : Nº factura
         return             : 0 Todo Ok
                           <> 0 num_err
   *************************************************************************/
   FUNCTION f_emitir_factura(pcempres IN NUMBER, pnfact IN VARCHAR2, pcagente IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
    Función que anula una factura
    param in pcempres   : Codigo empresa
    param in pnfact     : Nº factura
         return             : 0 Todo Ok
                           <> 0 num_err
   *************************************************************************/
   FUNCTION f_anular_factura(pcempres IN NUMBER, pnfact IN VARCHAR2, pcagente IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
    Función que genera query factura para una carpeta
    param in pCCARPETA   : Codigo carpeta
    param in pcempres   : Codigo empresa
    param in pcidioma   : Codigo idioma
    param out pquery    : texto con la query resultante
         return             : 0 Todo Ok
                           <> 0 num_err
   -- bug 0028554 - 06/02/2014 - JMF
   *************************************************************************/
   FUNCTION f_query_factura_carpeta(
      pccarpeta IN VARCHAR2,
      pcempres IN NUMBER,
      pcidioma IN NUMBER,
      pquery OUT CLOB)
      RETURN NUMBER;

   /*************************************************************************
    Función que asigna numero de folio a partir de un numero interno de factura, tambien trata folios erroneos
    param in pcempres   : Codigo empresa
    param in pobfacturacarpeta   : Objeto con toda la informacion
         return             : 0 Todo Ok
                           <> 0 num_err
   -- bug 0028554 - 06/02/2014 - JMF
   *************************************************************************/
   FUNCTION f_asigna_carpeta(pcempres IN NUMBER, pobfacturacarpeta IN ob_iax_asigfactura)
      RETURN NUMBER;

   /*************************************************************************
    Proceso emite facturas
   -- bug 0028554 - 06/02/2014 - JMF
   *************************************************************************/
   PROCEDURE p_emite_facturas;

   /*************************************************************************
    Función que autoriza una factura
    param in pcempres   : Codigo empresa
    param in pnfact     : Nº factura
         return             : 0 Todo Ok
                           <> 0 num_err
   *************************************************************************/
   FUNCTION f_autoriza_factura(pcempres IN NUMBER, pnfact IN VARCHAR2, pcagente IN NUMBER)
      RETURN NUMBER;
END pac_facturas;

/

  GRANT EXECUTE ON "AXIS"."PAC_FACTURAS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_FACTURAS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_FACTURAS" TO "PROGRAMADORESCSI";
