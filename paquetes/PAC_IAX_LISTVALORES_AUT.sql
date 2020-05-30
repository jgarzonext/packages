--------------------------------------------------------
--  DDL for Package PAC_IAX_LISTVALORES_AUT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_IAX_LISTVALORES_AUT" AS
/******************************************************************************
 NOMBRE: PAC_IAX_LISTVALORES_AUT
 PROPÃ“SITO: Funciones para recuperar valores

 REVISIONES:
 Ver Fecha Autor DescripciÃ³n
 --------- ---------- --------------- ------------------------------------
 1.0                                  1. Creacion del Package
 1.1       26/02/2009 DCM             BUG 9198 - 3 Parte
 1.2       18/06/2009 XPL             BUG 10219
 1.3       18/03/2013 APD             0025566: LCOL_T031-LCOL - Fase 3 - (Id 323) - Uso del vehiculo
 1.4       28/03/2013 JDS             0025840: LCOL_T031-LCOL - Fase 3 - (Id 111, 112, 115) - Parametrización suplementos
 1.5       15/02/2013 ECP             Bug 25202/135707
 2.0       31/05/2013 ASN             0027045: LCOL_S010-SIN - Eliminar filtrado por producto en tramitación vehículo contrario (Id=7846)
 3.0       24/02/2014 JDS             0030256: LCOL999-Modificar modelo autos a?adiendo : CPESO, CTRANSMISION, NPUERTAS

-- BUG 9198 - 26/02/2009 - DCM Â¿ Se crean funciones para AUTOS.

   /*************************************************************************
   Recupera los accesorios que se pueden dar de alta como accesorios extras,
   es decir no entran de serie, devuelve un SYS_REFCURSOR
   param out : mensajes de error
   return : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstaccesoriosnoserie(p_cversion IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
   Recupera los accesorios de serie segun la version,
   devuelve un SYS_REFCURSOR
   param out : mensajes de error
   return : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstaccesoriosserie(p_cversion IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
   Recupera los datos de una version, devuelve un SYS_REFCURSOR
   param out : mensajes de error
   return : ref cursor
   *************************************************************************/
   FUNCTION f_get_version(
      p_cversion IN VARCHAR2,
      phomologar IN NUMBER,
      pctramit IN NUMBER,   -- 27045:ASN:31/05/2013
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
   Recupera las marcas segun el producto, devuelve un SYS_REFCURSOR
   param out : mensajes de error
   return : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstmarcas(pctramit IN NUMBER, mensajes OUT t_iax_mensajes)
      -- 27045:ASN:30/05/2013
   RETURN sys_refcursor;

   /*************************************************************************
   Recupera las marcas segun el producto, devuelve un SYS_REFCURSOR
   param out : mensajes de error
   return : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstmarcas(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pctramit IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

      -- 27045:ASN:30/05/2013
   /*************************************************************************
   Recupera las modelos segun la marca, devuelve un SYS_REFCURSOR
   param out : mensajes de error
   return : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstmodelos(
      pctipveh IN VARCHAR2,
      pcclaveh IN VARCHAR2,
      p_cmarca IN VARCHAR2,
      pctramit IN NUMBER,   -- 27045:ASN:30/05/2013
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
    Recupera el numero de puertas de un modelo, devuelve un SYS_REFCURSOR
    param out : mensajes de error
    return : ref cursor
    *************************************************************************/
   FUNCTION f_get_lstnumpuertas(
      p_cmarca IN VARCHAR2,
      p_cmodelo IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
    Recupera los usos de un vehiculo, devuelve un SYS_REFCURSOR
    param out : mensajes de error
    return : ref cursor
    -- Bug 25566 - APD - se añaden los parametros p_sproduc y p_cactivi
    *************************************************************************/
   FUNCTION f_get_lstuso(
      p_cclaveh IN VARCHAR2,
      p_ctipveh IN VARCHAR2,
      p_sproduc IN NUMBER,
      p_cactivi IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
    Recupera los subusos de un vehiculo, devuelve un SYS_REFCURSOR
    param out : mensajes de error
    return : ref cursor
    -- Bug 25566 - APD - se añaden los parametros p_sproduc y p_cactivi
    *************************************************************************/
   FUNCTION f_get_lstsubuso(
      p_cclaveh IN VARCHAR2,
      p_ctipveh IN VARCHAR2,
      p_uso IN VARCHAR2,
      p_sproduc IN NUMBER,
      p_cactivi IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
    Recupera las versiones que existen en funciÃ³n de la marca, modelo,
   nÃºmero de puestas y motor de un vehÃ­culo, devuelve un SYS_REFCURSOR
    param out : mensajes de error
    return : ref cursor
    *************************************************************************/
   FUNCTION f_get_lstversiones(
      p_cmarca IN VARCHAR2,
      p_cmodelo IN VARCHAR2,
      p_numpuertas IN VARCHAR2,
      p_cmotor IN VARCHAR2,
      pctipveh IN VARCHAR2,
      pcclaveh IN VARCHAR2,
      pcversion IN VARCHAR2,
      pctramit IN NUMBER,   -- 27045:ASN:31/05/2013
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
    Recupera los diferentes tipos de vehiculo, devuelve un SYS_REFCURSOR
    param out : mensajes de error
    return : ref cursor
    *************************************************************************/
   FUNCTION f_get_lstctipveh(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

-- Bug 10219 - XPL - 18/06/2009 -- Modificacions Sinistres
   /*************************************************************************
    Recupera los diferentes clases de vehiculo, devuelve un SYS_REFCURSOR
    param out : mensajes de error
    return : ref cursor
    *************************************************************************/
   FUNCTION f_get_lstclaveh(p_ctipveh IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

-- FI BUG 9198 - 26/02/2009 - DCM Â¿ Se crean funciones para AUTOS.

   -- Bug 9247 - APD - 17/03/2009 -- Se crea la funcion f_get_lstmodalidades
   /*************************************************************************
    Recupera las modalidades permitidas en un producto y actividad, devuelve un SYS_REFCURSOR
    param out : mensajes de error
    return : ref cursor
    *************************************************************************/
   FUNCTION f_get_lstmodalidades(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

-- Bug 9247 - APD - 17/03/2009 -- Se crea la funcion f_get_lstmodalidades
   FUNCTION f_get_lstctipveh_pormarca(
      pcmarca IN VARCHAR2,
      pctramit IN NUMBER,   -- 27045:ASN:31/05/2013
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_get_lstclaveh_pormarca(
      pcmarca IN VARCHAR2,
      p_ctipveh IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
    Recupera los anyos de una version
    param out : mensajes de error
    return : ref cursor
    *************************************************************************/
   FUNCTION f_get_anyos_version(
      p_cversion IN VARCHAR2,
      p_nriesgo NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_get_lstaccesorios(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_get_lstdispositivos(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
    Recupera si un accesorio es asegurable, devuelve un SYS_REFCURSOR
    param out : mensajes de error
    return : ref cursor

    Bug 25578/135876 - 04/02/2013 - AMC
    *************************************************************************/
   FUNCTION f_get_lstasegurables(
      pcaccesorio IN VARCHAR2,
      pctipo IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
    Recupera la lista de pesos, devuelve un SYS_REFCURSOR
    param out : mensajes de error
    return : ref cursor

    Bug 25202/135707 - 15/02/2013 - ECP
    *************************************************************************/
   FUNCTION f_get_lstpesos(psproduc IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_get_lstctipveh_pormarcamodel(
      pcmarca IN VARCHAR2,
      pcmodel IN VARCHAR2,
      pctramit IN NUMBER,   -- 27045:ASN:31/05/2013
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;
END pac_iax_listvalores_aut;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_LISTVALORES_AUT" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_LISTVALORES_AUT" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_LISTVALORES_AUT" TO "PROGRAMADORESCSI";
