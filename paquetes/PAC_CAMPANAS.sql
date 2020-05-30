--------------------------------------------------------
--  DDL for Package PAC_CAMPANAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_CAMPANAS" IS
  /******************************************************************************
     NOMBRE:       PAC_CAMPANAS
     PROPÓSITO:    Funciones de la capa lógica para realizar acciones sobre la tabla CAMPANAS

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
   param out pquery      : select a ejcutar
        return             : 0 busqueda correcta
                          <> 0 busqueda incorrecta
  *************************************************************************/
  FUNCTION f_buscar(pccodigo IN VARCHAR2,
                    pcestado IN VARCHAR2,
                    pfinicam IN DATE,
                    pffincam IN DATE,
                    pquery   OUT VARCHAR2) RETURN NUMBER;

  /*************************************************************************
   Función que permite ver/editar el detalle de la campaña
   param in pccodigo     : codigo campaña
   param out pquery      : select a ejcutar (recupera datos de la campaña)
   param out pquery2     : select a ejcutar (recupera datos de los aprod/activ/garant asociados a la campaña)
        return             : 0 edición correcta
                          <> 0 edición incorrecta
  *************************************************************************/
  FUNCTION f_editar(pccodigo IN VARCHAR2,
                    pquery   OUT VARCHAR2,
                    pquery2  OUT VARCHAR2,
                    pquery3  OUT VARCHAR2,
                    pquery4  OUT VARCHAR2) RETURN NUMBER;

  /*************************************************************************
   Función que permite guardar los cambios realizados en  el detalle de la campaña
   param in pccodigo     : codigo campaña
   param in ptdescrip    : descripción campaña
   param in pcestado     : estado campaña
   param in pfinicam     : fecha inicio campaña
   param in pffincam     : fecha fin campaña
   param in pivalini     : coste lanzamiento campaña
   param in pipremio     : coste premio campaña
   param in pivtaprv     : importe previsto ventas campaña
   param in pivtarea     : importe real ventas campaña
   param in pcmedios     : medios de comunicación campaña
   param in pnagecam     : Num. agentes participan campaña
   param in pnagegan     : Num. agentes ganadores campaña.
   param in ptobserv     : observaciones campaña
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
                    pcconven  IN VARCHAR2) RETURN NUMBER;

  /*************************************************************************
   Función que permite guardar los cambios realizados en  el detalle de la campaña
   param in pccodigo     : código campaña
   param in psproduc     : código producto asociado a campaña
   param in pcactivi     : código actividad asociado a campaña
   param in pcgarant     : código garantia asociado a campaña
        return             : 0 grabación correcta
                          <> 0 grabación incorrecta
  *************************************************************************/
  FUNCTION f_grabar_campaprd(pccodigo IN VARCHAR2,
                             psproduc IN NUMBER,
                             pcactivi IN NUMBER,
                             pcgarant IN NUMBER) RETURN NUMBER;

  /*************************************************************************
   Función que permite generar las cartas de alta/anulación de la campaña a los agentes asociados
   param in pccodigo     : codigo campaña
        return             : 0 generación cartas correcta
                          <> 0 generación cartas incorrecta
  *************************************************************************/
  FUNCTION f_cartear(pctipocarta IN VARCHAR2, pccodigo IN VARCHAR2)
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
   param out pquery    : select a ejecutar
   return              : number
  *************************************************************************/
  FUNCTION f_get_agentes_campa(pcmodo   IN VARCHAR2,
                               pccodigo IN NUMBER,
                               pfinicam IN DATE,
                               pctipage IN NUMBER,
                               pcagente IN NUMBER,
                               pempresa IN NUMBER,
                               pquery   OUT VARCHAR2) RETURN NUMBER;

  /*************************************************************************
   FUNCTION f_set_agentes_campa
   Funcion que permite asignar/eliminar agentes a las campaña
   param in pcmodo     : modo acceso (ASIGNAR'|'DESASIGNAR')
   param in pccodigo   : código campaña
   param in pcagente   : fecha inicio campaña
   param in pctipage   : tipo agente
   param in pfinicam   : código agente
   param in pffincam   : fecha fin campaña
   return              : number
  *************************************************************************/
  FUNCTION f_set_agentes_campa(pcmodo   IN VARCHAR2,
                               pccodigo IN NUMBER,
                               pcagente IN NUMBER,
                               pctipage IN NUMBER,
                               pfinicam IN DATE,
                               pffincam IN DATE,
                               pimeta   IN NUMBER) RETURN NUMBER;

  -- Fi Bug 0019298

  -- 31/08/2011. FAL. 0019298: LCOL_C001 - Desarrollo de campañas
  /*************************************************************************
   FUNCTION f_get_productos_campa
   Funcion que perminte buscar productos/actividades/garantias de una EMPRESA a partir de los criterios de consulta entrados
   param in pcramo     : codigo del ramo
   param in psproduc   : código del producto
   param in pcactivi   : codigo de la actividad
   param in pcgarant   : codigo de la garantia
   param in pcidioma   : codigo del idioma
   param out pquery  : select de los productos
   return              : number
  *************************************************************************/
  FUNCTION f_get_productos_campa(pcramo   IN NUMBER,
                                 psproduc IN NUMBER,
                                 pcactivi IN NUMBER,
                                 pcgarant IN NUMBER,
                                 pcidioma IN NUMBER,
                                 pquery   OUT VARCHAR2) RETURN NUMBER;

  /*************************************************************************
   FUNCTION f_set_productos_campa
   Funcion que permite asignar productos a las campaña
   param in pccodigo     : codigo campaña
   param in plistprod  : lista de productos seleccionados
   return              : number
  *************************************************************************/
  FUNCTION f_set_productos_campa(pccodigo IN NUMBER,
                                 psproduc IN NUMBER,
                                 pcactivi IN NUMBER,
                                 pcgarant NUMBER) RETURN NUMBER;

  -- Fi Bug 0019298
  /*************************************************************************
   FUNCTION f_get_campaprd
   Funcion que perminte buscar productos/actividades/garantias de una EMPRESA a partir de los criterios de consulta entrados
   param in pccodigo     : codigo del ramo
   param out pquery  : select de los productos
   return              : number
  *************************************************************************/
  FUNCTION f_get_campaprd(pccodigo IN NUMBER, pquery OUT VARCHAR2)
    RETURN NUMBER;

  -- Fi Bug 40601
  /*************************************************************************
   FUNCTION f_get_campa
   Funcion que perminte buscar campañas de una EMPRESA a partir de los criterios de consulta entrados
   param in pccodigo     : codigo del ramo
   param out pquery  : select de los productos
   return              : number
  *************************************************************************/
  FUNCTION f_get_campa(pccodigo IN NUMBER, pquery OUT VARCHAR2) RETURN NUMBER;
  /*************************************************************************
   FUNCTION f_del_productos_campa
   Funcion que permite eliminar productos de una campaña
   param in pccodigo     : codigo campaña
   param in pcproduc  : código de producto
   return              : number
  *************************************************************************/
  FUNCTION f_del_productos_campa(pccodigo IN NUMBER) RETURN NUMBER;

  /*************************************************************************
   FUNCTION f_get_agentecampanyes
   Funcion que perminte buscar las campañas en las que está un agente
   param in pcagente    : codigo de agente
   param out pquery  : select de llas campañas
   return              : number
  *************************************************************************/
  FUNCTION f_get_agentecampanyes(pcagente IN NUMBER, pquery OUT VARCHAR2)
    RETURN NUMBER;

  /*************************************************************************
   FUNCTION f_set_ageganador
   Funcion que permite asignar productos a las campaña
   param in pccodigo     : codigo campaña
   param in pcagente     : agente
   param in ptganador    : ganador (S/N)
   return              : number
  *************************************************************************/
  FUNCTION f_set_ageganador(pccodigo  IN NUMBER,
                            pcagente  IN NUMBER,
                            ptganador IN VARCHAR2) RETURN NUMBER;

  FUNCTION f_ramos(pccodigo IN NUMBER) RETURN VARCHAR2;

  /*************************************************************************
   FUNCTION f_get_documentos
   Funcion que perminte mostrar los deocumentos de una campañas
   param in pccodigo    : codigo de campaña
   param out pquery  : select de los documentos
   return              : number
  *************************************************************************/
  FUNCTION f_get_documentos(pccodigo IN NUMBER, pquery OUT VARCHAR2)
    RETURN NUMBER;

  /***********************************************************************
     F_DESPRODUCTO: Obtención del Título o Rótulo de un Producto.
  ***********************************************************************/
  FUNCTION f_desproducto(psproduc IN NUMBER, pcidioma IN NUMBER)
    RETURN VARCHAR2;
  -- Fi Bug 40601
  /***********************************************************************
   f_get_agente_importe: Obtención del Importe.
  ***********************************************************************/
  FUNCTION f_get_agente_importe(pcagente  IN NUMBER,
                                pccampana IN NUMBER,
                                pnmes     IN NUMBER,
                                pnano     IN NUMBER,
                                pcramo    IN NUMBER,
                                pcempres  IN NUMBER,
                                psproduc  IN NUMBER,
                                pcsucurs  IN NUMBER) RETURN SYS_REFCURSOR;

  /***********************************************************************
   F_DESPRODUCTO: Obtención de la siniestralidad por Agente.
  ***********************************************************************/

  FUNCTION f_get_porc_agente_sinies(pcagente IN NUMBER) RETURN NUMBER;

  /***********************************************************************
   F_DESPRODUCTO: Obtención de la siniestralidad por Agente.
  ***********************************************************************/

  FUNCTION f_get_campa_cierre(pctipo    IN NUMBER,
                              pcagente  IN NUMBER,
                              pccampana IN NUMBER,
                              pnmes     IN NUMBER,
                              pnano     IN NUMBER,
                              pcramo    IN NUMBER,
                              pcempres  IN NUMBER,
                              psproduc  IN NUMBER,
                              pcsucurs  IN NUMBER) RETURN SYS_REFCURSOR;

  /***********************************************************************
   F_DESPRODUCTO: Obtención de la siniestralidad por Agente.
  ***********************************************************************/

  PROCEDURE proceso_batch_cierre(pmodo    IN NUMBER,
                                 pcempres IN NUMBER,
                                 pmoneda  IN NUMBER,
                                 pcidioma IN NUMBER,
                                 pfperini IN DATE,
                                 pfperfin IN DATE,
                                 pfcierre IN DATE,
                                 pcerror  OUT NUMBER,
                                 psproces OUT NUMBER,
                                 pfproces OUT DATE);

  /***********************************************************************
   F_DESPRODUCTO: Obtención de la siniestralidad por Agente.
  ***********************************************************************/

  FUNCTION f_generar_correo(pctipo    IN NUMBER,
                            pcagente  IN NUMBER,
                            pccampana IN NUMBER,
                            pnmes     IN NUMBER,
                            pnano     IN NUMBER,
                            pcramo    IN NUMBER,
                            pcempres  IN NUMBER,
                            psproduc  IN NUMBER,
                            pcsucurs  IN NUMBER) RETURN NUMBER;

  /***********************************************************************
  f_envia_correo: Envía mail
  ***********************************************************************/
  FUNCTION f_envia_correo RETURN NUMBER;
  -- Fi Bug 40601

END pac_campanas;

/

  GRANT EXECUTE ON "AXIS"."PAC_CAMPANAS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_CAMPANAS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_CAMPANAS" TO "PROGRAMADORESCSI";
