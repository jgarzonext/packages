--------------------------------------------------------
--  DDL for Package PAC_MD_CAMPANAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_MD_CAMPANAS" IS
  /******************************************************************************
     NOMBRE:       PAC_MD_CAMPANAS
     PROP¿SITO:    Funciones de la capa MD para realizar acciones sobre la tabla CAMPANAS

     REVISIONES:
     Ver        Fecha        Autor             Descripci¿n
     ---------  ----------  ---------------  ------------------------------------
     1.0        30/08/2011   FAL                1. Creaci¿n del package.0019298: LCOL_C001 - Desarrollo de campa¿as
  ******************************************************************************/

  /*************************************************************************
   Funci¿n que realiza la b¿squeda de campa¿as a partir de los criterios de consulta entrados
   param in pccodigo     : codigo campa¿a
   param in pcestado     : estado campa¿a
   param in pfinicam     : fecha inicio campa¿a
   param in pffincam     : fecha fin campa¿a
   param out ptcampanas  : colecci¿n de objetos ob_iax_campana
   param in out mensajes : colecci¿n de objetos ob_iax_mensajes
        return             : 0 busqueda correcta
                          <> 0 busqueda incorrecta
  *************************************************************************/
  FUNCTION f_buscar(pccodigo   IN NUMBER,

                    pcestado   IN VARCHAR2,
                    pfinicam   IN DATE,
                    pffincam   IN DATE,
                    ptcampanas OUT t_iax_campanas,
                    mensajes   IN OUT t_iax_mensajes) RETURN NUMBER;


  /*************************************************************************
   Funci¿n que permite ver/editar el detalle de la campa¿a
   param in pccodigo     : codigo campa¿a
   param out pobcampana  : objeto ob_iax_campana
   param out ptcampaprd  : lista objetos ob_iax_campaprd
   param out mensajes    : colecci¿n de objetos ob_iax_mensajes
        return             : 0 edici¿n correcta
                          <> 0 edici¿n incorrecta
  *************************************************************************/
  FUNCTION f_editar(pccodigo   IN NUMBER,

                    pobcampana OUT ob_iax_campanas,
                    mensajes   IN OUT t_iax_mensajes) RETURN NUMBER;


  /*************************************************************************
   Funci¿n que permite guardar los cambios realizados en  el detalle de la campa¿a
   param in pccodigo     : codigo campa¿a
   param in ptdescrip    : descripci¿¿n de la campa¿¿a
   param in pcestado    : estado de la campa¿¿a. Por defecto 'PE'
   param in pfinicam    : fecha inicio de la campa¿¿a
   param in pffincam    : fecha fin de la campa¿¿a
   param in pivalini    : Coste de lanzamiento de la campa¿¿a
   param in pipremio    : Coste del premio de la campa¿¿a
   param in pivtaprv    : Importe Previsto de las ventas de la campa¿¿a
   param in pivtarea    : Importe Real de las ventas de la campa¿¿a
   param in pcmedios    : Medios de comunicaci¿¿n de la campa¿¿a (max.8 medios diferentes)
   param in pnagecam    : Num. de agentes  participantes en la campa¿¿a
   param in pnagegan    : Num. de agentes  ganadores en la campa¿¿a
   param in ptobserv    : Observaciones de la campa¿¿a
   param out mensajes    : colecci¿n de objetos ob_iax_mensajes
        return             : 0 grabaci¿n correcta
                          <> 0 grabaci¿n incorrecta
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
                    mensajes  IN OUT t_iax_mensajes) RETURN NUMBER;


  /*************************************************************************
   Funci¿n que permite generar las cartas de alta/anulaci¿n de la campa¿a a los agentes asociados
   param in pccodigo     : codigo campa¿a
   param out mensajes    : colecci¿n de objetos ob_iax_mensajes
        return             : 0 generaci¿n cartas correcta
                          <> 0 generaci¿n cartas incorrecta
  *************************************************************************/
  FUNCTION f_cartear(pctipocarta IN VARCHAR2,
                     mensajes    IN OUT t_iax_mensajes) RETURN NUMBER;

  -- 31/08/2011. FAL. 0019298: LCOL_C001 - Desarrollo de campa¿as
  /*************************************************************************
   FUNCTION f_get_agentes_campa
   Funcion que permite buscar agentes que pueden participar en las campa¿as
   param in pcmodo     : modo acceso (ASIGNAR'|'DESASIGNAR')
   param in pccodigo   : c¿digo campa¿a
   param in pfinicam   : fecha inicio campa¿a
   param in pctipage   : tipo agente
   param in pcagente   : c¿digo agente
   param out plistage  : colecci¿n de objetos campaage
   param out mensajes  : colecci¿n de objetos ob_iax_mensajes
   return              : number
  *************************************************************************/
  FUNCTION f_get_agentes_campa(pcmodo   IN VARCHAR2,

                               pccodigo IN NUMBER,
                               pfinicam IN DATE,
                               pctipage IN NUMBER,
                               pcagente IN NUMBER,
                               plistage OUT t_iax_campaage,
                               mensajes IN OUT t_iax_mensajes) RETURN NUMBER;


  /*************************************************************************
   FUNCTION f_set_agentes_campa
   Funcion que permite asignar/eliminar agentes a las campa¿a
   param out plistage  : colecci¿n de objetos campaage
   param out mensajes  : colecci¿n de objetos ob_iax_mensajes
   return              : number
  *************************************************************************/
  FUNCTION f_set_agentes_campa(pcmodo   IN VARCHAR2,

                               pccodigo IN NUMBER,
                               pcagente IN NUMBER,
                               pctipage IN NUMBER,
                               pfinicam IN DATE,
                               pffincam IN DATE,
                               pimeta   IN NUMBER,
                               mensajes IN OUT t_iax_mensajes) RETURN NUMBER;


  -- Fi Bug 0019298

  -- 31/08/2011. FAL. 0019298: LCOL_C001 - Desarrollo de campa¿as
  /*************************************************************************
   FUNCTION f_get_productos_campa
   Funcion que perminte buscar productos/actividades/garantias de una EMPRESA a partir de los criterios de consulta entrados
   param in pcramo     : codigo del ramo
   param in psproduc   : c¿digo del producto
   param in pcactivi   : codigo de la actividad
   param in pcgarant   : codigo de la garantia
   param out plistprod  : lista de productos (sys_refcursor)
   param out mensajes  : colecci¿n de objetos ob_iax_mensajes
   return              : number
  *************************************************************************/
  FUNCTION f_get_productos_campa(pcramo    IN NUMBER,

                                 psproduc  IN NUMBER,
                                 pcactivi  IN NUMBER,
                                 pcgarant  IN NUMBER,
                                 plistprod OUT SYS_REFCURSOR,
                                 mensajes  IN OUT t_iax_mensajes)
    RETURN NUMBER;

  /*************************************************************************
   FUNCTION f_set_productos_campa
   Funcion que permite asignar productos a las campa¿a
   param in pccodigo     : codigo campa¿a
   param in plistprod  : lista de productos seleccionados
   param out mensajes  : colecci¿n de objetos ob_iax_mensajes
   return              : number
  *************************************************************************/
  FUNCTION f_set_productos_campa(pccodigo IN NUMBER,

                                 psproduc IN NUMBER,
                                 pcactivi IN NUMBER,
                                 pcgarant IN NUMBER,
                                 mensajes IN OUT t_iax_mensajes)
    RETURN NUMBER;

  /*************************************************************************
   FUNCTION f_get_campaprd
   Funcion que perminte buscar productos/actividades/garantias de una campa¿a
   param in pccodigo    : codigo de campa¿a
   param out plistprod  : lista de productos (sys_refcursor)
   param out mensajes  : colecci¿n de objetos ob_iax_mensajes
   return              : number
  *************************************************************************/
  FUNCTION f_get_campaprd(pccodigo  IN NUMBER,

                          plistprod OUT SYS_REFCURSOR,
                          mensajes  IN OUT t_iax_mensajes) RETURN NUMBER;

   -- Fi Bug 40601

  /*************************************************************************
   FUNCTION f_get_campa
   Funcion que perminte buscar una campa¿a
   param in pccodigo    : codigo de campa¿a
   param out plistprod  : lista de productos (sys_refcursor)
   param out mensajes  : colecci¿n de objetos ob_iax_mensajes
   return              : number
  *************************************************************************/
  FUNCTION f_get_campa(pccodigo  IN NUMBER,
                       plistprod OUT SYS_REFCURSOR,
                       mensajes  IN OUT t_iax_mensajes) RETURN NUMBER;

  /*************************************************************************
   FUNCTION f_get_estadocampana
   Funcion que permite recuperar los valores del estado de una campa¿a
   param out mensajes  : colecci¿n de objetos ob_iax_mensajes
   return    : ref cursor
  *************************************************************************/
  FUNCTION f_get_estadocampana(mensajes OUT t_iax_mensajes)
    RETURN SYS_REFCURSOR;

  /***************************************************************************************
   FUNCTION f_get_medios
   Funcion que permite recuperar los valores de los medios de comunicaci¿n de una campa¿a
   param out mensajes  : colecci¿n de objetos ob_iax_mensajes
   return    : ref cursor
  ****************************************************************************************/
  FUNCTION f_get_medios(mensajes OUT t_iax_mensajes) RETURN SYS_REFCURSOR;


  /*************************************************************************
   FUNCTION f_del_productos_campa
   Funcion que permite eliminar productos de una campa¿a
   param in pccodigo     : codigo campa¿a
   param in pcproduc  : c¿digo de producto
   return              : number
  *************************************************************************/
  FUNCTION f_del_productos_campa(pccodigo IN NUMBER,
                                 mensajes OUT t_iax_mensajes) RETURN NUMBER;

  /*************************************************************************
   FUNCTION f_get_agentecampanyes
   Funcion que perminte buscar las campa¿as en las que est¿ un agente
   param in pcagente    : codigo de agente
   param out pquery  : select de llas campa¿as
   return              : number
  *************************************************************************/
  FUNCTION f_get_agentecampanyes(pcagente      IN NUMBER,

                                 plistagecampa OUT SYS_REFCURSOR,
                                 mensajes      IN OUT t_iax_mensajes)
    RETURN NUMBER;

  /*************************************************************************
   FUNCTION f_set_ageganador
   Funcion que permite asignar productos a las campa¿a
   param in pccodigo     : codigo campa¿a
   param in pcagente     : agente
   param in ptganador    : ganador (S/N)
   return              : number
  *************************************************************************/
  FUNCTION f_set_ageganador(pccodigo  IN NUMBER,

                            pcagente  IN NUMBER,
                            ptganador IN VARCHAR2,
                            mensajes  IN OUT t_iax_mensajes) RETURN NUMBER;


  /*************************************************************************
   FUNCTION f_get_documentos
   Funcion que perminte mostrar los deocumentos de una campa¿as
   param in pccodigo    : codigo de campa¿a
   param in plistdocumentos    : Lista de documentos de la campa¿a
   param out mensajes  : mensajes
   return              : number
  *************************************************************************/
  FUNCTION f_get_documentos(pccodigo        IN NUMBER,

                            plistdocumentos OUT SYS_REFCURSOR,
                            mensajes        IN OUT t_iax_mensajes)
    RETURN NUMBER;
   -- Fi Bug 40601
  /***********************************************************************
  ***********************************************************************/

  FUNCTION f_get_campa_cierre(pctipo    IN NUMBER,
                              pcagente  IN NUMBER,
                              pccampana IN NUMBER,
                              pnmes     IN NUMBER,
                              pnano     IN NUMBER,
                              pcramo    IN NUMBER,
                              pcempres  IN NUMBER,
                              psproduc  IN NUMBER,
                              pcsucurs  IN NUMBER,
                              mensajes  IN OUT t_iax_mensajes)
    RETURN SYS_REFCURSOR;

   -- Fi Bug 40601
  /***********************************************************************
  ***********************************************************************/

  FUNCTION f_generar_correo(pctipo    IN NUMBER,
                            pcagente  IN NUMBER,
                            pccampana IN NUMBER,
                            pnmes     IN NUMBER,
                            pnano     IN NUMBER,
                            pcramo    IN NUMBER,
                            pcempres  IN NUMBER,
                            psproduc  IN NUMBER,
                            pcsucurs  IN NUMBER,
                            mensajes  IN OUT t_iax_mensajes) RETURN NUMBER;

END pac_md_campanas;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_CAMPANAS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_CAMPANAS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_CAMPANAS" TO "PROGRAMADORESCSI";
