--------------------------------------------------------
--  DDL for Package PAC_MD_TRAMITADORES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_MD_TRAMITADORES" AS
   /******************************************************************************
      NOMBRE:     PAC_MD_TRAMITADORES
      PROPOSITO:  Funciones para recuperar valores

      REVISIONES:
      Ver        Fecha        Autor   Descripcion
     ---------  ----------  ------   ------------------------------------
      1.0        07/05/2012   AMC     1. Creacion del package.
      2.0        03/12/2012   JMF    0024964: LCOL_S001-SIN - Seleccion tramitador en alta siniestro (Id=2754)

   ******************************************************************************/

   /*************************************************************************
      Devuelve los siniestros que cumplan con el criterio de selección
      param in pnpoliza     : número de póliza
      param in pncert       : número de cerificado por defecto 0
      param in pnsinies     : número del siniestro1
      param in pcestsin     : Estado del siniestro
      param in pcramo       : Numero de ramo
      param in psproduc     : Numero de producto
      param in pfsinies     : Fecha del siniestro
      param in pctrami      : Codigo del tramitador
      param in pcactivi     : Codigo de la actividad
      param out mensajes    : mensajes de error
      return                : ref cursor

      Bug 21196/113187 - 07/05/2012 - AMC
   *************************************************************************/
   FUNCTION f_consulta_lstsini(
      pnpoliza IN NUMBER,
      pncertif IN NUMBER DEFAULT -1,
      pnsinies IN VARCHAR2,
      pcestsin IN NUMBER,
      pfiltro IN NUMBER,
      pcramo IN NUMBER,
      psproduc IN NUMBER,
      pfsinies IN DATE,
      pctrami IN VARCHAR2,
      pcactivi IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

    /*************************************************************************
        FUNCTION f_get_ctramitad
        Recupera els tramidors amb les seves descripcions
        param in pctramitad  : codi tramitador
        param in  out pttramitad  : Nombre de tramitador
        param out mensajes : missatges d'error
        return             : refcursor
   *************************************************************************/
   FUNCTION f_get_tramitador(
      pctramitad IN VARCHAR2,
      pttramitad IN OUT VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
        FUNCTION f_cambio_tramitador
        Inserta el movimiento de cambio de tramitador
        param in pctramitad  : codi tramitador
        param in pcunitra : codi de la unidad de tramitacion
        param in pctramitad : codi del tramitador
        param out mensajes : missatges d'error
        return             : 0 - Ok ; 1 - Ko
   *************************************************************************/
   FUNCTION f_cambio_tramitador(
      psiniestros IN VARCHAR2,
      pcunitra IN VARCHAR2,
      pctramitad IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Devuelve lista tramitadores para alta siniestro
      param in pcempres     : codigo empresa
      param out mensajes    : mensajes de error
      return                : ref cursor

      -- BUG 0024964 - 03/12/2012 - JMF
   *************************************************************************/
   FUNCTION f_get_tramitador_alta(pcempres IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;
END pac_md_tramitadores;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_TRAMITADORES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_TRAMITADORES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_TRAMITADORES" TO "PROGRAMADORESCSI";
