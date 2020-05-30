--------------------------------------------------------
--  DDL for Package PAC_IAX_CAMPANAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_IAX_CAMPANAS" IS
  /******************************************************************************
     NOMBRE:       PAC_IAX_CAMPANAS
     PROPÓSITO:    Funciones de la capa IAX para realizar acciones sobre la tabla CAMPANAS

     REVISIONES:
     Ver        Fecha        Autor             Descripción
     ---------  ----------  ---------------  ------------------------------------
     1.0        30/08/2011   FAL                1. Creación del package.0019298: LCOL_C001 - Desarrollo de campañas
  ******************************************************************************/

  /*************************************************************************
   Función que realiza la búsqueda de campañas a partir de los criterios de consulta entrados
   param in pccodigo     : codigo campaña
   param in pcestado     : estado campaña
   param in pfinicam     : fecha inicio campaña
   param in pffincam     : fecha fin campaña
   param out ptcampanas  : colección de objetos ob_iax_campana
   param out mensajes    : colección de objetos ob_iax_mensajes
        return             : 0 busqueda correcta
                          <> 0 busqueda incorrecta
  *************************************************************************/
  FUNCTION f_buscar(pccodigo   IN NUMBER,
                    pcestado   IN VARCHAR2,
                    pfinicam   IN DATE,
                    pffincam   IN DATE,
                    ptcampanas OUT t_iax_campanas,
                    mensajes   OUT t_iax_mensajes) RETURN NUMBER;

  /*************************************************************************
   Función que permite ver/editar el detalle de la campaña
   param in pccodigo     : codigo campaña
   param out pobcampana  : objeto ob_iax_campana
   param out mensajes    : colección de objetos ob_iax_mensajes
        return             : 0 edición correcta
                          <> 0 edición incorrecta
  *************************************************************************/
  FUNCTION f_editar(pccodigo   IN NUMBER,
                    pobcampana OUT ob_iax_campanas,
                    mensajes   OUT t_iax_mensajes) RETURN NUMBER;

  /*************************************************************************
   Función que permite guardar los cambios realizados en  el detalle de la campaña
   param in pccodigo     : codigo campaña
   param in ptdescrip    : descripciÃ³n de la campaÃ±a
   param in pcestado    : estado de la campaÃ±a. Por defecto 'PE'
   param in pfinicam    : fecha inicio de la campaÃ±a
   param in pffincam    : fecha fin de la campaÃ±a
   param in pivalini    : Coste de lanzamiento de la campaÃ±a
   param in pipremio    : Coste del premio de la campaÃ±a
   param in pivtaprv    : Importe Previsto de las ventas de la campaÃ±a
   param in pivtarea    : Importe Real de las ventas de la campaÃ±a
   param in pcmedios    : Medios de comunicaciÃ³n de la campaÃ±a (max.8 medios diferentes)
   param in pnagecam    : Num. de agentes  participantes en la campaÃ±a
   param in pnagegan    : Num. de agentes  ganadores en la campaÃ±a
   param in ptobserv    : Observaciones de la campaÃ±a
   param out mensajes    : colección de objetos ob_iax_mensajes
        return             : 0 grabación correcta
                          <> 0 grabación incorrecta
  *************************************************************************/
  FUNCTION f_grabar(pccodigo  IN VARCHAR2,
                    ptdescrip IN VARCHAR2,
                    pcestado  IN VARCHAR2,
                    pfinicam  IN DATE,
                    pffincam  IN DATE,
                    pivalini  IN NUMBER,
                    pipremio  IN NUMBER,
                    pivtaprv  IN NUMBER,
                    pivtarea  IN NUMBER,
                    pcmedios  IN VARCHAR2,
                    pnagecam  IN NUMBER,
                    pnagegan  IN NUMBER,
                    ptobserv  IN VARCHAR2,
                    pcexccrr  IN NUMBER,
                    pcexcnewp IN NUMBER,
                    pfinirec  IN DATE,
                    pffinrec  IN DATE,
                    pcconven  IN VARCHAR2,
                    mensajes  OUT t_iax_mensajes) RETURN NUMBER;

  /*************************************************************************
   Función que permite generar las cartas de alta/anulación de la campaña a los agentes asociados
   param in pccodigo     : codigo campaña
   param out mensajes    : colección de objetos ob_iax_mensajes
        return             : 0 generación cartas correcta
                          <> 0 generación cartas incorrecta
  *************************************************************************/
  FUNCTION f_cartear(pctipocarta IN VARCHAR2, mensajes OUT t_iax_mensajes)
    RETURN NUMBER;

  -- 31/08/2011. FAL. 0019298: LCOL_C001 - Desarrollo de campañas
  /*************************************************************************
   FUNCTION f_get_agentes_campa
   Funcion que permite buscar agentes que pueden participar en las campañas
   param in pcmodo     : modo acceso (ASIGNAR'|'DESASIGNAR')
   param in pccodigo   : código campaña
   param in pfinicam   : fecha inicio campaña
   param in pctipage   : tipo agente
   param in pcagente   : código agente
   param out plistage  : colección de objetos campaage
   param out mensajes  : colección de objetos ob_iax_mensajes
   return              : number
  *************************************************************************/
  FUNCTION f_get_agentes_campa(pcmodo   IN VARCHAR2,
                               pccodigo IN NUMBER,
                               pfinicam IN DATE,
                               pctipage IN NUMBER,
                               pcagente IN NUMBER,
                               plistage OUT t_iax_campaage,
                               mensajes OUT t_iax_mensajes) RETURN NUMBER;

  /*************************************************************************
   FUNCTION f_set_agentes_campa
   Funcion que permite asignar/eliminar agentes a las campaña
   param in plistage  : colección de objetos campaage
   param out mensajes  : colección de objetos ob_iax_mensajes
   return              : number
  *************************************************************************/
  FUNCTION f_set_agentes_campa(pcmodo   IN VARCHAR2,
                               pccodigo IN NUMBER,
                               pcagente IN NUMBER,
                               pctipage IN NUMBER,
                               pfinicam IN DATE,
                               pffincam IN DATE,
                               pimeta   IN NUMBER,
                               mensajes OUT t_iax_mensajes) RETURN NUMBER;

  -- Fi Bug 0019298

  -- 31/08/2011. FAL. 0019298: LCOL_C001 - Desarrollo de campañas
  /*************************************************************************
   FUNCTION f_get_productos_campa
   Funcion que perminte buscar productos/actividades/garantias de una EMPRESA a partir de los criterios de consulta entrados
   param in pcramo     : codigo del ramo
   param in psproduc   : código del producto
   param in pcactivi   : codigo de la actividad
   param in pcgarant   : codigo de la garantia
   param out plistprod  : lista de productos (sys_refcursor)
   param out mensajes  : colección de objetos ob_iax_mensajes
   return              : number
  *************************************************************************/
  FUNCTION f_get_productos_campa(pcramo    IN NUMBER,
                                 psproduc  IN NUMBER,
                                 pcactivi  IN NUMBER,
                                 pcgarant  IN NUMBER,
                                 plistprod OUT sys_refcursor,
                                 mensajes  OUT t_iax_mensajes) RETURN NUMBER;

  /*************************************************************************
   FUNCTION f_set_productos_campa
   Funcion que permite asignar productos a las campaña
   param in pccodigo     : codigo campaña
   param in plistprod  : lista de productos seleccionados
   param out mensajes  : colección de objetos ob_iax_mensajes
   return              : number
  *************************************************************************/
  FUNCTION f_set_productos_campa(pccodigo IN NUMBER,
                                 psproduc IN NUMBER,
                                 pcactivi IN NUMBER,
                                 pcgarant IN NUMBER,
                                 mensajes OUT t_iax_mensajes) RETURN NUMBER;

  -- 21/03/2013. JLV.
  /*************************************************************************
   FUNCTION f_get_campaprd
   Funcion que perminte buscar productos/actividades/garantias de una campaña
   param in pccodigo    : codigo del campaña
   param out plistprod  : lista de productos (sys_refcursor)
   param out mensajes  : colección de objetos ob_iax_mensajes
   return              : number
  *************************************************************************/
  FUNCTION f_get_campaprd(pccodigo  IN NUMBER,
                          plistprod OUT sys_refcursor,
                          mensajes  OUT t_iax_mensajes) RETURN NUMBER;

  -- Fi Bug 40601
  /*************************************************************************
   FUNCTION f_get_campa
   Funcion que permite buscar una campaña
   param in pccodigo    : codigo del campaña
   param out plistprod  : lista de productos (sys_refcursor)
   param out mensajes  : colección de objetos ob_iax_mensajes
   return              : number
  *************************************************************************/
  FUNCTION f_get_campa(pccodigo  IN NUMBER,
                       plistprod OUT sys_refcursor,
                       mensajes  OUT t_iax_mensajes) RETURN NUMBER;

  /*************************************************************************
   FUNCTION f_get_estadocampana
   Funcion que permite recuperar los valores del estado de una campaña
   param out mensajes  : colección de objetos ob_iax_mensajes
   return    : ref cursor
  *************************************************************************/
  FUNCTION f_get_estadocampana(mensajes OUT t_iax_mensajes)
    RETURN sys_refcursor;

  /***************************************************************************************
   FUNCTION f_get_medios
   Funcion que permite recuperar los valores de los medios de comunicación de una campaña
   param out mensajes  : colección de objetos ob_iax_mensajes
   return    : ref cursor
  ****************************************************************************************/
  FUNCTION f_get_medios(mensajes OUT t_iax_mensajes) RETURN sys_refcursor;

  /*************************************************************************
   FUNCTION f_del_productos_campa
   Funcion que permite eliminar productos de una campaña
   param in pccodigo     : codigo campaña
   param in pcproduc  : código de producto
   return              : number
  *************************************************************************/
  FUNCTION f_del_productos_campa(pccodigo IN NUMBER,
                                 mensajes OUT t_iax_mensajes) RETURN NUMBER;

  /*************************************************************************
   FUNCTION f_get_agentecampanyes
   Funcion que perminte buscar las campañas en las que está un agente
   param in pcagente    : codigo de agente
   param out pquery  : select de llas campañas
   return              : number
  *************************************************************************/
  FUNCTION f_get_agentecampanyes(pcagente      IN NUMBER,
                                 plistagecampa OUT sys_refcursor,
                                 mensajes      OUT t_iax_mensajes)
    RETURN NUMBER;

  /*************************************************************************
   FUNCTION f_set_ageganador
   Funcion que permite asignar productos a las campaña
   param in pccodigo     : codigo campaña
   param in pcagente     : agente
   param in ptganador    : ganador (S/N)
   param in out mensajes  : t_iax_mensajes
   return              : number
  *************************************************************************/
  FUNCTION f_set_ageganador(pccodigo  IN NUMBER,
                            pcagente  IN NUMBER,
                            ptganador IN VARCHAR2,
                            mensajes  OUT t_iax_mensajes) RETURN NUMBER;

  /*************************************************************************
   FUNCTION f_get_documentos
   Funcion que perminte mostrar los deocumentos de una campañas
   param in pccodigo    : codigo de campaña
   param in plistdocumentos    : Lista de documentos de la campaña
   param out mensajes  : mensajes
   return              : number
  *************************************************************************/
  FUNCTION f_get_documentos(pccodigo        IN NUMBER,
                            plistdocumentos OUT sys_refcursor,
                            mensajes        OUT t_iax_mensajes) RETURN NUMBER;
   -- Fi Bug 40601
  /*************************************************************************
   FUNCTION f_get_campa_cierre
   Funcion que perminte realizar el cierre de campañas
   param out mensajes  : mensajes
   return              : SYS_REFCURSOR
  *************************************************************************/
  FUNCTION f_get_campa_cierre(pctipo    IN NUMBER,
                              pcagente  IN NUMBER,
                              pccampana IN NUMBER,
                              pnmes     IN NUMBER,
                              pnano     IN NUMBER,
                              pcramo    IN NUMBER,
                              pcempres  IN NUMBER,
                              psproduc  IN NUMBER,
                              pcsucurs  IN NUMBER,
                              mensajes  OUT T_IAX_MENSAJES)
    RETURN SYS_REFCURSOR;

   -- Fi Bug 40601
  /*************************************************************************
   FUNCTION f_get_campa_cierre
   Funcion que permite enviar correo de campaña
   param out mensajes  : mensajes
   return              : number
  *************************************************************************/
  FUNCTION F_GENERAR_CORREO(pctipo    IN NUMBER,
                            pcagente  IN NUMBER,
                            pccampana IN NUMBER,
                            pnmes     IN NUMBER,
                            pnano     IN NUMBER,
                            pcramo    IN NUMBER,
                            pcempres  IN NUMBER,
                            psproduc  IN NUMBER,
                            pcsucurs  IN NUMBER,
                            mensajes  OUT T_IAX_MENSAJES) RETURN NUMBER;

END pac_iax_campanas;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_CAMPANAS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_CAMPANAS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_CAMPANAS" TO "PROGRAMADORESCSI";
