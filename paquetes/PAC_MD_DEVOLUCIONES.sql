--------------------------------------------------------
--  DDL for Package PAC_MD_DEVOLUCIONES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_MD_DEVOLUCIONES" AS
/******************************************************************************
   NOMBRE:      PAC_MD_DEVOLUCIONES
   PROPÓSITO: Funciones para la gestión de las devoluciones

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        18/05/2009   XPL             1. Creación del package.
   2.0        23/04/2012   JMF             2. 0022030: MDP_A001-Devoluciones: impresion y gestion de cartas
   3.0        26/07/2012   JGR             3. 0022086: LCOL_A003-Devoluciones - Fase 2 - 0117715
   4.0        11/06/2012   APD             4. 0022342: MDP_A001-Devoluciones
******************************************************************************/

   /*************************************************************************
        Función que seleccionará información sobre los procesos de devolució
        param in pcempres     : codigo empresa
        param in psedevolu    : nº proceso de devolución
        param in pfsoport     : fecha confección del soporte
        param in pfcarga      : fecha carga del soporte
        param out pdevoluciones  : ref cursor
        param out mensajes    : mensajes de error
        return                : NUMBER 0 / 1
     *************************************************************************/
   FUNCTION f_get_consulta_devol(
      pcempres IN NUMBER,
      psdevolu IN NUMBER,
      pfsoport IN DATE,
      pfcarga IN DATE,
      pdevoluciones OUT sys_refcursor,
      mensajes IN OUT t_iax_mensajes,
      pccobban IN NUMBER DEFAULT NULL,   -- 3.  0022086 / 0117715
      psperson IN NUMBER DEFAULT NULL,   -- 3.  0022086 / 0117715
      ptipo IN NUMBER DEFAULT NULL,   -- 3.  0022086 / 0117715
      pfcargaini IN DATE DEFAULT NULL,
      pfcargafin IN DATE DEFAULT NULL)
      RETURN NUMBER;

   /*************************************************************************
        Función que se encargará de recuperar la información de un procseo de
        devolución.
        param in psedevolu    : nº proceso de devolución
        param out pdevoluciones  : ref cursor
        param out mensajes    : mensajes de error
        return                : NUMBER 0 / 1
     *************************************************************************/
   FUNCTION f_get_datos_devolucion(
      psdevolu IN NUMBER,
      pdevoluciones OUT sys_refcursor,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
        Función que se encargará de devolver los recibos de una devolución
        param in psedevolu     : nº proceso de devolución
        param out plstrecibos  : ref cursor recibos de una devolución
        param out mensajes    : mensajes de error
        return                : NUMBER 0 / 1
     *************************************************************************/
   FUNCTION f_get_datos_recibos_devol(
      psdevolu IN NUMBER,
      plstrecibos OUT sys_refcursor,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
        Función que recuperará los recibos de un proceso de devolución y su estado de revisión
        param out mensajes    : mensajes de error
        return                : NUMBER 0 / 1
     *************************************************************************/
   FUNCTION f_get_rec_revis(
      psdevolu IN NUMBER,
      ptsitrecdev OUT t_iax_sitrecdev,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
        Función que recuperará los recibos de un proceso de devolución y su estado de revisión
        param out mensajes    : mensajes de error
        return                : NUMBER 0 / 1
     *************************************************************************/
   FUNCTION f_set_rec_revis(psitrecdev IN t_iax_sitrecdev, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
        Función que se encargará gde generar el listado de recibos devueltos para un proceso
        de devolución en concreto
        param in psedevolu     : nº proceso de devolución
        param out mensajes    : mensajes de error
        return                : NUMBER 0 / 1
     *************************************************************************/
   FUNCTION f_get_listado_devol(
      psdevolu IN NUMBER,
      pnomfichero OUT VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
        Función que se encargará gde generar las cartas de devoluciones de recibos de un proceso de devolución
        de devolución en concreto
        param in psedevolu     : nº proceso de devolución
        param out pplantilla  : 0=No tiene plantillas, 1=Si tiene plantillas
        param out mensajes    : mensajes de error
        return                : NUMBER 0 / 1
        -- Bug 0022030 - 23/04/2012 - JMF
     *************************************************************************/
   FUNCTION f_get_cartas_devol(
      psdevolu IN NUMBER,
      pplantilla OUT NUMBER,
      pnomfichero OUT VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
        Función que se encargará de cargar los recibos especificados en el fichero de devoluciones informado por param.
        de devolución en concreto
        param in pnomfitxer   : nombre del fichero de devolución
        param out mensajes    : mensajes de error
        return                : NUMBER 0 / 1
     *************************************************************************/
   FUNCTION f_get_carga_fichero(
      pcempres IN NUMBER,
      pnomfitxer IN VARCHAR2,
      psproces OUT NUMBER,
      p_fich_out OUT VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
        Función que realizará las devoluciones de los recibos especificados en el fichero y cargados en las
        tablas de devolución de recibos al hacer la carga previa del fichero.
        de devolución en concreto
        param out mensajes    : mensajes de error
        return                : NUMBER 0 / 1
     *************************************************************************/
   FUNCTION f_exec_devolu(mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
          Función que seleccionará información sobre las cartas de devolución
          param in psgescarta     : Id. carta
          param in pnpoliza     : nº poliza
          param in pnrecibo     : nº recibo
          param in pcestimp     : estado de impresión de carta
          param in pfini        : fecha inicio solicitud impresión
          param in pffin        : fecha fin solicitud impresión
          param in pcempres      : codigo de la empresa
          param in pcramo      : codigo del ramo
          param in psproduc      : codigo del producto
          param in pcagente      : codigo del agente
          param in pcremban      : Número de remesa interna de la entidad bancaria
          param out mensajes    : mensajes de error
          return                : NUMBER 0 / 1
       *************************************************************************/
   -- Bug 22342 - APD - 11/06/2012 - se añaden los parametros pcempres, pcramo,
   -- psproduc, pcagente, pcremban
   FUNCTION f_get_consulta_cartas(
      psgescarta IN NUMBER,
      pnpoliza IN NUMBER,
      pnrecibo IN NUMBER,
      pcestimp IN NUMBER,
      pfini IN DATE,
      pffin IN DATE,
      pcempres IN NUMBER,
      pcramo IN NUMBER,
      psproduc IN NUMBER,
      pcagente IN NUMBER,
      pcremban IN NUMBER,
      pcartas OUT sys_refcursor,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
          Función que modificará el estado de impresión de una carta
          param in psgescarta     : Id. carta
          param in pcestimp     : estado de impresión de carta
          param out mensajes    : mensajes de error
          return                : NUMBER 0 / 1
       *************************************************************************/
   FUNCTION f_set_estimp_carta(
      psdevolu IN NUMBER,
      pnrecibo IN NUMBER,
      pcestimp IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

/*************************************************************************
      Recupera el código y la descripción del proceso de devolución
      param out pdevoluciones : ref cursor
      param out mensajes : mensajes de error
      return             : 0(OK!)/1(Error)

          18/05/2009   XPL                 Maps.  Bug: 8957
*************************************************************************/
   FUNCTION f_get_devoluciones(
      pcempres IN NUMBER,
      pdevoluciones OUT sys_refcursor,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
       Recupera un path de directori
       param in pparam : valor de path
       param out ppath    : pàrametre PAT_VLIQ
       param out mensajes : missatge d'error
       return             : 0/1 -> Tot OK/Error
    ***********************************************************************/
   FUNCTION f_get_directorio(
      pparam IN VARCHAR2,
      ppath OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;
END pac_md_devoluciones;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_DEVOLUCIONES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_DEVOLUCIONES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_DEVOLUCIONES" TO "PROGRAMADORESCSI";
