--------------------------------------------------------
--  DDL for Package PAC_IAX_OPERATIVA_FINV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_IAX_OPERATIVA_FINV" AS
/******************************************************************************
   NOMBRE:      PAC_IAX_OPERATIVA_FINV
   PROPÓSITO:   Funciones para la parte referente a productos financieros
                       de inversión.

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        13/03/2009   RSC                1. Creación del package.
   2.0        13/07/2009   AMC                2. Nueva función f_leedistribucionfinv bug 10385
   3.0        17/09/2009   RSC                3. Bug 0010828: CRE - Revisión de los productos PPJ dinámico y Pla Estudiant (ajustes)
   4.0        25/09/2009   JGM                4. Bug 0011175
   6.0        12/03/2010   JTS                6. 13510: CRE - Ajustes en la pantalla de entrada de valores liquidativos - AXISFINV002
   7.0        17/02/2011   APD                7. 17243: ENSA101 - Rebuts de comissió
   8.0        06/04/2011   JTS                8. 18136: ENSA101 - Mantenimiento cotizaciones
   9.0        21/10/2011   JGR                9. 19852: CRE998 - Impressió de compte assegurança  (nota 0095567)
******************************************************************************/

   /*************************************************************************
      Recupera la los fondos de inversión a cargar valores liquidativos
      param in pcacto     : codigo del acto
      param out mensajes  : mesajes de error
      return              : descripción del acto
   *************************************************************************/
   -- Bug 9031 - 13/03/2009 - RSC -  iAxis: Análisis adaptación productos indexados
   FUNCTION f_getfondosoperafinv(
      pcempres IN NUMBER,
      pccodfon IN NUMBER,
      pfvalor IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Realiza la grabación de la operación liquidativa Financiera inversión
      param in pcempres     : codigo de empresa
      param in pccodfon     : codigo de fondo de inversión
      param in pfvalor      : Fecha de valoración
      param in piimpcmp     : Importe de compras
      param in pnunicmp     : Partipaciones o Unidades de compra
      param in piimpvnt     : Importe de ventas
      param in pnunivnt     : Participaciones o Unidades de venta
      param in piuniact     : Valor liquidativo a fecha de valoración
      param in pivalact     : Valor de la operación
      param in ppatrimonio  : Valor del patrimonio
      param out mensajes    : mesajes de error
      return                : numérico
   *************************************************************************/
   -- Bug 9031 - 13/03/2009 - RSC -  iAxis: Análisis adaptación productos indexados
   -- Bug 17243 - 17/02/2011 - APD -  se añade el parametro ppatrimonio a la funcion
   FUNCTION f_grabaroperacionfinv(
      pcempres IN NUMBER,
      pccodfon IN NUMBER,
      pfvalor IN DATE,
      piimpcmp IN NUMBER,
      pnunicmp IN NUMBER,
      piimpvnt IN NUMBER,
      pnunivnt IN NUMBER,
      piuniact IN NUMBER,
      pivalact IN NUMBER,
      ppatrimonio IN NUMBER,
      piuniactcmp IN NUMBER,
      piuniactvtashw IN NUMBER,
      piuniactcmpshw IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Sincroniza los valores de la operación (Introducción de valore liquidativos
      + operaciones)
      param in picompra_in     : Importe de compra
      param in pncompra_in     : Unidades de compra
      param in piventa_in      : Importe de venta
      param in pnventa_in      : Unidades de venta
      param in piuniact_in     : Valor liquidativo
      param out picompra_out   : Importe de compra
      param out pncompra_out   : Unidades de compra
      param out piventa_out    : Importe de venta
      param out pnventa_out    : Unidades de venta
      param out pivalact_out   : Valor de operación
      param out mensajes       : mesajes de error
      return                   : numerico
   *************************************************************************/
   -- Bug 9031 - 13/03/2009 - RSC -  iAxis: Análisis adaptación productos indexados
   FUNCTION f_sinccalcularoperacionfinv(
      picompra_in IN NUMBER,
      pncompra_in IN NUMBER,
      piventa_in IN NUMBER,
      pnventa_in IN NUMBER,
      piuniact_in IN NUMBER,
      picompra_out OUT NUMBER,
      pncompra_out OUT NUMBER,
      piventa_out OUT NUMBER,
      pnventa_out OUT NUMBER,
      pivalact_out OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   -- Bug 9031 - 13/03/2009 - RSC -  iAxis: Análisis adaptación productos indexados
      Realiza la carga mediante fichero de valores liquidativos y operaciones.
      param in pruta      : ruta del fichero
      param in pfvalor    : Fecha de valoración
      param out mensajes  : mesajes de error
      return              : descripción del acto
   *************************************************************************/
   -- Bug 9031 - 13/03/2009 - RSC -  iAxis: Análisis adaptación productos indexados
   FUNCTION f_grabaroperacionfilefinv(
      pruta IN VARCHAR2,
      pcempres IN NUMBER,
      pfvalor IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Realiza la valoración de fondos de inversión.
      param in pcacto     : codigo del acto
      param out mensajes  : mesajes de error
      return              : descripción del acto
   *************************************************************************/
   -- Bug 9031 - 16/03/2009 - RSC -  iAxis: Análisis adaptación productos indexados
   FUNCTION f_valorarfinv(pfvalor IN DATE, pcempres IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Realiza la asignación de participaciones de fondos de inversión en
      contratos.
      param in pcacto     : codigo del acto
      param out mensajes  : mesajes de error
      return              : descripción del acto
   *************************************************************************/
   -- Bug 9031 - 16/03/2009 - RSC -  iAxis: Análisis adaptación productos indexados
   FUNCTION f_asignarfinv(pfvalor IN DATE, pcempres IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Función que nos retorna un literal con el estado a modificar los fondos
      de inversión.
      param in pfvalor     : codigo de fecha de valoración
      param out mensajes  : mesajes de error
      return              : descripción del acto
   *************************************************************************/
   -- Bug 9031 - 16/03/2009 - RSC -  iAxis: Análisis adaptación productos indexados
   FUNCTION f_estado_a_modificar(
      pcempres IN NUMBER,
      pfvalor IN DATE,
      paestado OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN VARCHAR2;

   /*************************************************************************
      Función que realiza la modificaión del estado de los fondos de inversión.
      param in pfvalor     : codigo de fecha de valoración
      param out mensajes  : mesajes de error
      return              : descripción del acto
   *************************************************************************/
   -- Bug 9031 - 16/03/2009 - RSC -  iAxis: Análisis adaptación productos indexados
   FUNCTION f_cambio_estado(
      pcempres IN NUMBER,
      pfvalor IN DATE,
      paestado IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

     /*************************************************************************
      Retorna el estado de los fondos de inversión.
      param in pcempres    : código de empresa
      param in pfvalor     : codigo de fecha de valoración
      param out mensajes  : mesajes de error
      return              : descripción del acto
   *************************************************************************/
   -- Bug 9031 - 16/03/2009 - RSC -  iAxis: Análisis adaptación productos indexados
   FUNCTION f_getestadofondosfinv(
      pcempres IN NUMBER,
      pfvalor IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN VARCHAR2;

   /*************************************************************************
      Recupera las entradas y salidas sin consolidar producidas a un fecha de
      valoración.
      param in pcempres     : codigo de empresa
      param in pfvalor      : codigo de valoración
      param out mensajes    : mesajes de error
      return                : descripción del acto
   *************************************************************************/
   -- Bug 9031 - 17/03/2009 - RSC -  iAxis: Análisis adaptación productos indexados
   FUNCTION f_getentradassalidasfinv(
      pcempres IN NUMBER,
      pfvalor IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN t_iax_entradasalida;

   /*************************************************************************
      Generación de un fichero con las entradas y salidas sin consolidar producidas
      a un fecha de valoración.
      param in pcempres      : codigo de empresa
      param in pfvalor       : codigo de valoración
      param out pfichero_out : fichero de salida generado
      param out mensajes     : mesajes de error
      return                 : descripción del acto
   *************************************************************************/
   -- Bug 9031 - 17/03/2009 - RSC -  iAxis: Análisis adaptación productos indexados
   FUNCTION f_execfileentradassalidasfinv(
      pcempres IN NUMBER,
      pfvalor IN DATE,
      pfichero_out OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
       Recupera un path de directori
       param out ppath    : pàrametre carga valores
       param out mensajes : missatge d'error
       return             : 0/1 -> Tot OK/Error
   ***********************************************************************/
   FUNCTION f_get_directorio(ppath OUT VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
      Recupera la informació del perfil d'inversió
      param in  psseguro : Cod. del seguro
      param out mensajes : missatge d'error
      return             : ob_iax_produlkmodelosinv

      Bug 10385 - 13/07/2009 - AMC
   ***********************************************************************/
   FUNCTION f_leedistribucionfinv(psseguro IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN ob_iax_produlkmodelosinv;

   /***********************************************************************
        JGM 22-09-2009.
        Devolverá una colección de objetos T_IAX_TABVALCES, rsultado de buscar en la tabla tabvalces
        para el ccesta igual al parámetro pccesta.

      param in  pcempres : Cod. Empresa
      param in  pccesta : Cod. de la cesta
      param in  pcidioma: idioma
      param out mensajes : missatge d'error
      return             : t_iax_TABVALCES

      Bug 0011175:
   ***********************************************************************/
   FUNCTION f_get_tabvalces(
      pcempres IN NUMBER,
      pccesta IN NUMBER,
      pcidioma IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN t_iax_tabvalces;

   /*************************************************************************
      Recupera las entradas y salidas sin consolidar producidas a un fecha de
      valoración (nueva versión CRE).
      param in pcempres     : codigo de empresa
      param in pccodfon     : codigo de fondo
      param in pfvalor      : codigo de valoración
      param out mensajes    : mesajes de error
      return                : descripción del acto
   *************************************************************************/
   -- Bug 10828 - 14/10/2009 - RSC - CRE - Revisión de los productos PPJ dinámico y Pla Estudiant (ajustes)
   FUNCTION f_getentsal_ampliado(
      pcempres IN NUMBER,
      pfvalor IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN t_iax_entradasalida;

   /*************************************************************************
      FUNCTION f_control_valorpart
      param in pcempres     : codigo de empresa
      param in pccodfon     : codigo de fondo
      param in pfvalor      : codigo de valoración
      param in piuniact     : iuniact
      param out mensajes    : mesajes de error
      return                : literal
      --BUG 13510 - JTS - 12/03/2010
   *************************************************************************/
   FUNCTION f_control_valorpart(
      pcempres IN NUMBER,
      pccodfon IN NUMBER,
      pfvalor IN DATE,
      piuniact IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      FUNCTION f_filecotizaciones
      param in pruta        : ruta del fichero
      param in pcempres     : codigo de empresa
      param in pfvalor      : codigo de valoración
      param in out mensajes : mesajes de error
      return                : 0 ok
                              1 ko
      --BUG 18136 - JTS - 06/04/2011
   *************************************************************************/
   FUNCTION f_filecotizaciones(
      pruta IN VARCHAR2,
      pcempres IN NUMBER,
      pfvalor IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Recupera las cotizaciones de monedas
      param in pcmonori   :  moneda origen
      param in pcmondes   :  moneda destino
      param out mensajes  :  mesajes de error
      return              :  sys_refcursor
   *************************************************************************/
   -- Bug 18136 - JTS - 07/04/2011
   FUNCTION f_getcotizaciones(
      pcmonori IN VARCHAR2,
      pcmondes IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera las monedas
      param out mensajes  :  mesajes de error
      return              :  sys_refcursor
   *************************************************************************/
   -- Bug 18136 - JTS - 07/04/2011
   FUNCTION f_monedas(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera el histórico de cotizaciones de monedas
      param in pcmonori   :  moneda origen
      param in pcmondes   :  moneda destino
      param out mensajes  :  mesajes de error
      return              :  sys_refcursor
   *************************************************************************/
   -- Bug 18136 - JTS - 07/04/2011
   FUNCTION f_gethistcotizaciones(
      pcmonori IN VARCHAR2,
      pcmondes IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera nueva cotizacion de monedas
      param in pcmonori   :  moneda origen
      param in pcmondes   :  moneda destino
      param out mensajes  :  mesajes de error
      return              :  sys_refcursor
   *************************************************************************/
   -- Bug 18136 - JTS - 07/04/2011
   FUNCTION f_newcotizacion(
      pcmonori IN VARCHAR2,
      pcmondes IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Crea nueva cotizacion de monedas
      param in pcmonori   :  moneda origen
      param in pcmondes   :  moneda destino
      param out mensajes  :  mesajes de error
      return              :  error
   *************************************************************************/
   -- Bug 18136 - JTS - 07/04/2011
   FUNCTION f_creacotizacion(
      pcmonori IN VARCHAR2,
      pcmondes IN VARCHAR2,
      pfvalor IN DATE,
      ptasa IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Recupera los gastos de los fondos
      param in pcempres   :
      param in pccodfon   :
      param out mensajes  :  mesajes de error
      return              :  sys_refcursor
   *************************************************************************/
   --BUG18799 - JTS - 16/06/2011
   FUNCTION f_get_fongastos(
      pcempres IN NUMBER,
      pccodfon IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera los gastos de los fondos
      param in pcempres   :
      param in pccodfon   :
      param out mensajes  :  mesajes de error
      return              :  sys_refcursor
   *************************************************************************/
   --BUG18799 - JTS - 16/06/2011
   FUNCTION f_get_fongastos_hist(pccodfon IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      FUNCTION f_set_reggastos
      param out mensajes  :  mesajes de error
      return              :  error
   *************************************************************************/
   --BUG18799 - JTS - 16/06/2011
   FUNCTION f_set_reggastos(
      pccodfon IN NUMBER,
      pfinicio IN DATE,
      pffin IN DATE,
      piimpmin IN NUMBER,
      piimpmax IN NUMBER,
      pcdivisa IN NUMBER,
      ppgastos IN NUMBER,
      piimpfij IN NUMBER,
      pcolumn9 IN NUMBER,
      pctipcom IN NUMBER,
      pcconcep IN NUMBER,
      pctipocalcul IN NUMBER,
      pclave IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Retorna si ha de mostrar o no la icone de impresora.
      També retorna el literal que es comenta en el bug "Pòlissa amb operacions pedents de valorar"
      param in pcempres   :
      param in psseguro   :
      param in pcidioma   :
      param out mensajes  :  mesajes de error
      return              :  sys_refcursor
   *************************************************************************/
   FUNCTION f_op_pdtes_valorar(
      pcempres IN NUMBER,
      psseguro IN NUMBER,
      pcidioma IN NUMBER,
      pliteral OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /******************************************************************************
    función que graba o actualiza el estado de un fondo.

    param in:       pccodfon
    param in :      pfecha
    param in:       ptfonabv
    param in out:   mensajes

   ******************************************************************************/
   FUNCTION f_set_estado_fondo(
      pccodfon IN NUMBER,
      pfecha IN DATE,
      pcestado IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /******************************************************************************
    función que recupera fondos para un rescate

    param in:       pccodfon
    param in:       pctipcal
    param out:      ptfonabv
    param out:      mensajes

   ******************************************************************************/
   FUNCTION f_get_datos_rescate(
      psseguro IN NUMBER,
      pctipcal IN NUMBER,
      pfondos OUT t_iax_datos_fnd,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /******************************************************************************
    función que reañiza un switch por miporte

    param in:       psseguro
    param in:       pfecha
    param in:       plstfondos
    param out:      mensajes

   ******************************************************************************/
   FUNCTION f_switch_importe(
      psseguro IN NUMBER,
      pfecha IN DATE,
      plstfondos IN t_iax_info,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_getctipfonfinv(
      pcempres IN NUMBER,
      pccodfon IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

-- Bug 36746/0211309 - APD - 17/09/2015 - se crea la funcion
   FUNCTION f_get_lstfondosseg(
      pcempres IN NUMBER,
      psseguro IN NUMBER,
      pfecha IN DATE,
      plstfondos OUT sys_refcursor,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

-- Bug 36746/0211309 - APD - 17/09/2015 - se crea la funcion
   FUNCTION f_switch_fondos(
      pccodfonori IN NUMBER,
      pccodfondtn IN NUMBER,
      psseguro IN NUMBER,
      pfecha IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;
END pac_iax_operativa_finv;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_OPERATIVA_FINV" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_OPERATIVA_FINV" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_OPERATIVA_FINV" TO "PROGRAMADORESCSI";
