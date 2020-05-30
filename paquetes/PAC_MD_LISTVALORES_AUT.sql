--------------------------------------------------------
--  DDL for Package PAC_MD_LISTVALORES_AUT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_MD_LISTVALORES_AUT" AS
/******************************************************************************
 NOMBRE: PAC_MD_LISTVALORES_AUT
 PROPÃ“SITO: Funciones para recuperar valores

 REVISIONES:
 Ver Fecha Autor DescripciÃ³n
 --------- ---------- --------------- ------------------------------------
 1.0                                  1. Creacion del Package
 1.1       26/02/2009 DCM             BUG 9198 - 3 Parte
 1.2       18/06/2009 XPL             BUG 10219
 1.3       19/03/2013 JDS             0025202: LCOL_T031 - Adaptar pantalla riesgo - autos. Id 428
 1.4       28/03/2013 JDS             0025840: LCOL_T031-LCOL - Fase 3 - (Id 111, 112, 115) - Parametrización suplementos
 1.5       15/02/2013 ECP             Bug 25202/135707
 2.0       31/05/2013 ASN             0027045: LCOL_S010-SIN - Eliminar filtrado por producto en tramitación vehículo contrario (Id=7846)
 3.0       31/07/2013 JSV             0025894: LCOL_T031-LCOL - Parametrizaci?n AUTOS AX - MY CAR (6032)
 4.0       24/02/2014 JDS             0030256: LCOL999-Modificar modelo autos a?adiendo : CPESO, CTRANSMISION, NPUERTAS
******************************Âº************************************************/
   FUNCTION f_get_lstaccesoriosnoserie(p_cversion IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_get_lstdispositivosnoserie(p_cversion IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

--  *************************************************************************/
   FUNCTION f_get_lstaccesoriosserie(p_cversion IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
   Recupera los datos de una version, devuelve un SYS_REFCURSOR
   param out : mensajes de error
   return : ref cursor
   *************************************************************************/
   FUNCTION f_get_version(
      p_cversion IN VARCHAR2,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      phomologar IN NUMBER,
      pctramit IN NUMBER,   -- 27045:ASN:31/05/2013
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
   Recupera las modelos segun la marca, devuelve un SYS_REFCURSOR
   param out : mensajes de error
   return : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstmodelos(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pctipveh IN VARCHAR2,
      pcclaveh IN VARCHAR2,
      p_cmarca IN VARCHAR2,
      pctramit IN NUMBER,   -- 27045:ASN:31/05/2013
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
   Recupera las marcas segun el producto, devuelve un SYS_REFCURSOR
   param out : mensajes de error
   return : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstmarcas(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pctramit IN NUMBER,   -- 27045:ASN:30/05/2013
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_get_lstclaveh_pormarca(
      pcmarca IN VARCHAR2,
      p_ctipveh IN VARCHAR2,
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
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
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

-- Bug 10219 - XPL - 18/06/2009 -- Modificacions Sinistres
   /*************************************************************************
    Recupera los diferentes tipos de vehiculo, devuelve un SYS_REFCURSOR
    param out : mensajes de error
    return : ref cursor
    *************************************************************************/
   FUNCTION f_get_lstctipveh(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
    Recupera los diferentes clases de vehiculo, devuelve un SYS_REFCURSOR
    param out : mensajes de error
    return : ref cursor
    *************************************************************************/
   FUNCTION f_get_lstclaveh(p_ctipveh IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

-- FI BUG 9198 - 26/02/2009 - DCM Â¿ Se crean funciones para AUTOS.

   -- Bug 9247 - APD - 23/03/2009 -- Se crea la funcion f_get_lstmodalidades
   /*************************************************************************
    Recupera las modalidades permitidas en un producto y actividad, devuelve un SYS_REFCURSOR
    param out : mensajes de error
    return : ref cursor
    *************************************************************************/
   FUNCTION f_get_lstmodalidades(
      p_cramo IN NUMBER,
      p_cmodali IN NUMBER,
      p_ctipseg IN NUMBER,
      p_ccolect IN NUMBER,
      p_cactivi IN NUMBER,
      p_csimula IN BOOLEAN,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

-- Bug 9247 - APD - 23/03/2009 -- Se crea la funcion f_get_lstmodalidades
   FUNCTION f_get_lstctipveh_pormarca(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcmarca IN VARCHAR2,
      pctramit IN NUMBER,   -- 27045:ASN:31/05/2013
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_get_anyos_version(
      p_cversion IN VARCHAR2,
      p_nriesgo IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_get_lstaccesorios(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_get_taccesorio(pcaccesorio IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN VARCHAR2;

   FUNCTION f_get_lstdispositivos(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
    Recupera si un accesorio es asegurable, devuelve un SYS_REFCURSOR
    param out : mensajes de error
    return : ref cursor

    Bug 25578/135876 - 04/02/2013 - AMC
    *************************************************************************/
   FUNCTION f_get_lstasegurables(
      psproducto IN NUMBER,
      pcactivi IN NUMBER,
      pcaccesorio IN VARCHAR2,
      pctipo IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
    Recupera la lista de pesos, devuelve un SYS_REFCURSOR
    param out : mensajes de error
    return : ref cursor

    Bug 25202/135707 - 15/02/2013 - ECP
    *************************************************************************/
   FUNCTION f_get_lstpesos(psproduc IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   -- BUG 26968 - FAL - 29/07/2013
   FUNCTION f_get_lstctipveh_pormarcamodel(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcmarca IN VARCHAR2,
      pcmodelo IN VARCHAR2,
      pctramit IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

       /*************************************************************************
   Filtra versions
   param out : Condicio
   return : VARCHAR2

   Bug 0025894 - JSV (31/07/2013)
   *************************************************************************/
   FUNCTION f_filtra_versiones(psproduc IN NUMBER)
      RETURN VARCHAR2;

   /*************************************************************************
   Filtra models per desplegable de models
   param out : Condicio
   return : VARCHAR2

   Bug 0025894 - JSV (30/07/2013)
   *************************************************************************/
   FUNCTION f_filtra_modelos(psproduc IN NUMBER)
      RETURN VARCHAR2;

    /*************************************************************************
   Filtra marques per desplegable de marques
   param out : Condicio
   return : VARCHAR2

   Bug 0025894 - JSV (30/07/2013)
   *************************************************************************/
   FUNCTION f_filtra_marcas(psproduc IN NUMBER)
      RETURN VARCHAR2;
END pac_md_listvalores_aut;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_LISTVALORES_AUT" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_LISTVALORES_AUT" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_LISTVALORES_AUT" TO "PROGRAMADORESCSI";
