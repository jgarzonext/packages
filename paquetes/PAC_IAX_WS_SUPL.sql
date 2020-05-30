--------------------------------------------------------
--  DDL for Package PAC_IAX_WS_SUPL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_IAX_WS_SUPL" AS
/******************************************************************************
   NOMBRE:       pac_iax_ws_supl
   PROPÓSITO:  Interficie para cada tipo de suplemento

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        28/07/2009   JRH                1. Creación del package. Bug 10776 reducción total
   2.0        15/09/2010   JRH                2. 0012278: Proceso de PB para el producto PEA.
******************************************************************************/

   /*************************************************************************
      Realiza la reduccion total de una póliza
      param in psseguro   : Número de seguro
      param in pfefecto   : Fecha del suplemento (puede ser nula)
      param out           : mensajes de error
      return              : 0 todo correcto
                            1 ha habido un error
   *************************************************************************/
   FUNCTION f_reduccion_total(
      psseguro IN NUMBER,
      pfefecto IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   -- BUG 12278 -  09/2010 - JRH  - 0012278: Proceso de PB para el producto PEA.

   /*************************************************************************
      f_suplemento_garant
      Realiza un suplemento asociado a garnatía (PB, Aport ext.,..)
      param in psseguro   : Número de seguro
      param in pnriesgo   : Riesgo
      param in pfecha   : Fecha del suplemento
      param in pimporte   : Importe
      param in pctipban   : Tipo banc.
      param in pcbancar   : Cuenta
      param in pcgarant   : Garantía asociada al suplemento
      param out           : pnmovimi
                            mensajes de error
      return              : 0 todo correcto
                            1 ha habido un error
   *************************************************************************/
   FUNCTION f_suplemento_garant(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pfecha IN DATE,
      pimporte IN NUMBER,
      pctipban IN NUMBER,
      pcbancar IN VARCHAR2,
      pcgarant IN NUMBER,
      pnmovimi OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;
-- Fi BUG 12278 -  09/2010 - JRH  - 0012278: Proceso de PB para el producto PEA.
END pac_iax_ws_supl;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_WS_SUPL" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_WS_SUPL" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_WS_SUPL" TO "PROGRAMADORESCSI";
