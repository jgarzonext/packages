--------------------------------------------------------
--  DDL for Package PAC_MD_RECHAZO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_MD_RECHAZO" AS
     /******************************************************************************
      NOMBRE:    PAC_MD_RECHAZO
      PROP¿SITO: Funciones para rechazo

      REVISIONES:
      Ver        Fecha        Autor             Descripci¿n
      ---------  ----------  ---------------  ------------------------------------
      1.0        11/02/2009   JMF                1. Creaci¿n del package.
      2.0        14/01/2013   DCT                2. Creaci¿n de la  funci¿n val_rechazo c¿mo especificaci¿n BUG 25583
   ******************************************************************************/

   /*************************************************************************
      Acciones del rechazo.
      param in     psseguro : C¿digo del seguro
      param in     pcmotmov : C¿digo del motivo
      param in     pnmovimi : N¿mero movimiento
      param in     paccion  : Acci¿n (3) si es rechazo ¿ (4) anulaci¿n del suplemento
      param in     ptobserv : Observaciones
      param in out mensajes : mensajes de error
   *************************************************************************/
   FUNCTION rechazo(
      psseguro IN NUMBER,
      pcmotmov IN NUMBER,
      pnmovimi IN NUMBER,
      paccion IN NUMBER,
      ptobserv IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes,
      pnorec IN NUMBER DEFAULT 0)
      RETURN NUMBER;

     /*************************************************************************
      Valida el rechazo.
      param in     psseguro : C¿digo del seguro
      param in     pcmotmov : C¿digo del motivo
      param in     pnmovimi : N¿mero movimiento
      param in     paccion  : Acci¿n (3) si es rechazo ¿ (4) anulaci¿n del suplemento
      param in     ptobserv : Observaciones
      param in out mensajes : mensajes de error
   *************************************************************************/
   FUNCTION val_rechazo(
      psseguro IN NUMBER,
      pcmotmov IN NUMBER,
      pnmovimi IN NUMBER,
      paccion IN NUMBER,
      ptobserv IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes,
      pskip IN NUMBER DEFAULT 0,
      pnorec IN NUMBER DEFAULT 0)
      RETURN NUMBER;

   /*************************************************************************
      Acciones del rechazo de colectivos
      param in     psseguro : C¿digo del seguro
      param in     pcmotmov : C¿digo del motivo
      param in     pnmovimi : N¿mero movimiento
      param in     paccion  : Acci¿n (3) si es rechazo ¿ (4) anulaci¿n del suplemento
      param in     ptobserv : Observaciones
      param in out mensajes : mensajes de error
   *************************************************************************/
   FUNCTION rechazo_col(
      psseguro IN NUMBER,
      pcmotmov IN NUMBER,
      pnmovimi IN NUMBER,
      paccion IN NUMBER,
      ptobserv IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes,
      pnorec IN NUMBER DEFAULT 0)
      RETURN NUMBER;
END pac_md_rechazo;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_RECHAZO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_RECHAZO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_RECHAZO" TO "PROGRAMADORESCSI";
