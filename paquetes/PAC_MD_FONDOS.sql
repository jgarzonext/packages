--------------------------------------------------------
--  DDL for Package PAC_MD_FONDOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_MD_FONDOS" AUTHID CURRENT_USER
IS
   /******************************************************************************
      NOMBRE:     PAC_MD_FONDOS
      PROPÓSITO: Funciones para mantener fondos

      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.0        12/02/2014  NMM                1.Creació.
      2.0        07/10/2015  JCP                2. Modificacion buscar fondos, get fondo y set fondo
   ******************************************************************************/
    /****************************************************************************
        función que recupera los fondos que cumplen con el criterio de selección.

            param in: pcempres
            param in: pccodfon
            parm  in: ptfoncmp
            param in: pcmoneda
            param in: pcmanager
            param in: pcdividend
            param in out: mensajes
    *****************************************************************************/
   FUNCTION f_buscar_fondos(
      pcempres     IN       NUMBER,
      pccodfon     IN       NUMBER,
      ptfoncmp     IN       VARCHAR2,
      pcmoneda     IN       NUMBER,
      pcmanager    IN       NUMBER,
      pcdividend   IN       NUMBER,
      mensajes     IN OUT   t_iax_mensajes
   )
      RETURN sys_refcursor;

   /****************************************************************************
       función que recupera un fondo en concreto.

           param in: pcempres
           param in: pccodfon
           param out: ptfonabv
           param out: ptfoncmp
           param out: pcmoneda
           param out: pcmanager
           param out: pnmaxuni
           param out: pigasttran
           param out: pfinicio
           param out: pcclsfon
           param out: pctipfon

           param in out: mensajes
   *****************************************************************************/
   FUNCTION f_get_fondo(
      pcempres      IN       NUMBER,
      pccodfon      IN       NUMBER,
      ptfonabv      OUT      VARCHAR2,
      ptfoncmp      OUT      VARCHAR2,
      pcmoneda      OUT      NUMBER,
      pcmanager     OUT      NUMBER,
      pnmaxuni      OUT      NUMBER,
      pigasttran    OUT      NUMBER,
      pfinicio      OUT      DATE,
      pcclsfon      OUT      NUMBER,
      pctipfon      OUT      NUMBER,
      pcmodabo      OUT      NUMBER,
      pndayaft      OUT      NUMBER,
      pnperiodbon   OUT      NUMBER,
      pcdividend    OUT      NUMBER,
      mensajes      IN OUT   t_iax_mensajes
   )
      RETURN NUMBER;

     /******************************************************************************
    función que graba o actualiza la tabla fondos

    param in:       pcempres
   param in out:   pccodfon
   param in:       ptfonabv
   param in:       ptfoncmp
   param in:       pcmoneda
   param in:       pcmanager
   param in:       pnmaxuni
   param in:       pigasttran
   param in:       pfinicio
   param in:       pcclsfon
   param in:       pctipfon
   param in:       pcdividend
   param in out:   mensajes

   ******************************************************************************/
   FUNCTION f_set_fondo(
      pcempres      IN       NUMBER,
      pccodfon      IN OUT   NUMBER,
      ptfonabv      IN       VARCHAR2,
      ptfoncmp      IN       VARCHAR2,
      pcmoneda      IN       NUMBER,
      pcmanager     IN       NUMBER,
      pnmaxuni      IN       NUMBER,
      pigasttran    IN       NUMBER,
      pfinicio      IN       DATE,
      pcclsfon      IN       NUMBER,
      pctipfon      IN       NUMBER,
      pcmodabo      IN       NUMBER,
      pndayaft      IN       NUMBER,
      pnperiodbon   IN       NUMBER,
      pcdividend    IN       NUMBER,
      mensajes      IN OUT   t_iax_mensajes
   )
      RETURN NUMBER;

   /******************************************************************************
     función que recupera un modelo de inversion

     param in:       psproduc
     param in:       pcmodinv
     param out:      pmodelo
     param in out:   mensajes

    ******************************************************************************/
   FUNCTION f_get_modelinv(
      psproduc   IN       NUMBER,
      pcmodinv   IN       NUMBER,
      pmodelo    IN       t_iax_produlkmodelosinv,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN NUMBER;

   /******************************************************************************
     función que guarda un modelo de inversion

      param in     cramo
      param in     cmodali
      param in     ctipseg
      param in     ccolect
      param in     cmodinv
      param in     finicio
      param in     ffin
      param in out:   mensajes

    ******************************************************************************/
   FUNCTION f_set_modelinv(
      psproduc   IN       NUMBER,
      pcmodinv   IN       NUMBER,
      pidioma    IN       t_iax_info,
      mensajes   OUT      t_iax_mensajes
   )
      RETURN NUMBER;

   /******************************************************************************
    función que recupera los fondos de un  modelo de inversion

     param in     psproduc
     param in     pcmodinv
     param in     pmodinvfondo
     param in     mensajes
     param in out:   mensajes

   ******************************************************************************/
   FUNCTION f_get_modinvfondos(
      psproduc       IN       NUMBER,
      pcmodinv       IN       NUMBER,
      pmodinvfondo   OUT      t_iax_produlkmodinvfondo,
      mensajes       IN OUT   t_iax_mensajes
   )
      RETURN NUMBER;

    /******************************************************************************
    función que guarda un fondo en un  modelo de inversion

     param in     psproduc
     param in     pcmodinv
     param in     pmodinvfondo
     param in     mensajes
     param in out:   mensajes

   ******************************************************************************/
   FUNCTION f_set_modinvfondos(
      psproduc       IN       NUMBER,
      pcmodinv       IN       NUMBER,
      pmodinvfondo   IN       t_iax_produlkmodinvfondo,
      mensajes       IN OUT   t_iax_mensajes
   )
      RETURN NUMBER;

/******************************************************************************
    función que borra un fondo en un  modelo de inversion

     param in     pccodfon
     param in     pcmodinv
     param in     mensajes
     param in out:   mensajes

   ******************************************************************************/
   FUNCTION f_del_modinvfondos(
      pccodfon   IN       NUMBER,
      pcmodinv   IN       NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN NUMBER;

   /******************************************************************************
     función que recupera los fondos de un  modelo de inversion

      param in     psproduc
      param in     pcmodinv
      param in     pmodinvfondo
      param in     mensajes
      param in out:   mensajes

    ******************************************************************************/
   FUNCTION f_get_modinvfondosseg(
      psproduc       IN       NUMBER,
      pcmodinv       IN       NUMBER,
      pmodinvfondo   OUT      t_iax_produlkmodinvfondo,
      mensajes       IN OUT   t_iax_mensajes
   )
      RETURN NUMBER;

   FUNCTION f_get_diasdep(pccodfon IN NUMBER)
      RETURN NUMBER;

   /******************************************************************************
    función que recupera los fondos de un  modelo de inversion

     param in     psproduc
     param in     pcmodinv
     param in     pmodinvfondo
     param in     mensajes
     param in out:   mensajes

   ******************************************************************************/
   FUNCTION f_get_modinvfondos2(
      psproduc       IN       NUMBER,
      pcmodinv       IN       NUMBER,
      pmodinvfondo   OUT      t_iax_produlkmodinvfondo,
      mensajes       IN OUT   t_iax_mensajes
   )
      RETURN NUMBER;

   FUNCTION f_asign_dividends(
      pmodo        IN       VARCHAR2,
      plstfondos   IN       t_iax_info,
      pfvigencia   IN       DATE,
      pfvalmov     IN       DATE,
      piimpdiv     IN       NUMBER,
      mensajes     IN OUT   t_iax_mensajes
   )
      RETURN NUMBER;
END pac_md_fondos;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_FONDOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_FONDOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_FONDOS" TO "PROGRAMADORESCSI";
