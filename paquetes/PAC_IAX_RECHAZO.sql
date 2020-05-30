--------------------------------------------------------
--  DDL for Package PAC_IAX_RECHAZO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_IAX_RECHAZO" IS
   /******************************************************************************
      NOMBRE:    PAC_IAX_RECHAZO
      PROPÓSITO: Funciones para rechazo

      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.0        11/02/2009   JMF                1. Creación del package.
   ******************************************************************************/

   /*************************************************************************
      Generación del Rechazo.
      param in     psseguro : Código del seguro
      param in     pcmotmov : Código del motivo
      param in     pnmovimi : Número movimiento
      param in     paccion  : Acción (3) si es rechazo ó (4) anulación del suplemento
      param in     ptobserv : Observaciones
      param in out mensajes : mensajes de error
   *************************************************************************/
   FUNCTION rechazo(
      psseguro IN NUMBER,
      pcmotmov IN NUMBER,
      pnmovimi IN NUMBER,
      paccion IN NUMBER,
      ptobserv IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;
END pac_iax_rechazo;
 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_RECHAZO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_RECHAZO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_RECHAZO" TO "PROGRAMADORESCSI";
