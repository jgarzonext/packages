--------------------------------------------------------
--  DDL for Package PAC_IAX_IMPAGA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_IAX_IMPAGA" IS
   /******************************************************************************
      NOMBRE:     PAC_IAX_IMPAGA
      PROPÓSITO:  Funciones para la gestión de impagados

      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.0        28/01/2010   NCC                1. BUG11425 : Creación del package.
      2.0        13/06/2012   APD                2. 0022342: MDP_A001-Devoluciones
   ******************************************************************************/
   -- Bug 22342 - APD - 13/06/2012 - se añade el parametro pcagente
   FUNCTION f_get_prodreprec(
      psidprodp IN NUMBER,
      psproduc IN NUMBER,
      pctipoimp IN NUMBER,
      pcagente IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_elimina_prodreprec(psidprodp IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   -- Bug 22342 - APD - 13/06/2012 - se añade el parametro pcagente
   FUNCTION f_set_prodreprec(
      psidprodp IN NUMBER,
      psproduc IN NUMBER,
      pfiniefe IN DATE,
      pctipoimp IN NUMBER,
      pctipnimp IN NUMBER,
      pcagente IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_detprodreprec(
      psidprodp IN NUMBER,
      pcmotivo IN NUMBER,
      pnimpagad IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_elimina_detprodreprec(
      psidprodp IN NUMBER,
      pcmotivo IN NUMBER,
      pnimpagad IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_set_detprodreprec(
      psidprodp IN NUMBER,
      pcmotivo IN NUMBER,
      pcmodimm IN NUMBER,
      pcactimm IN NUMBER,
      pcdiaavis IN NUMBER,
      pcmodelo IN NUMBER,
      pcactimp IN NUMBER,
      pndiaavis IN NUMBER,
      pnimpagad IN NUMBER,
      pmodo IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   -- Bug 22342 - APD - 13/06/2012 - se modifican los parametros de entrada
   FUNCTION f_get_impagados(
      psseguro IN NUMBER,
      pcramo IN NUMBER,
      psproduc IN NUMBER,
      pctiprec IN NUMBER,
      pfaccini IN DATE,
      pfaccfin IN DATE,
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      pnrecibo IN NUMBER,
      pnimpagad IN NUMBER,
      pcoficina IN NUMBER,
      pcagente IN NUMBER,
      pcmotivo IN NUMBER,
      pccarta IN NUMBER,
      pcactimp IN NUMBER,
      pcursor OUT sys_refcursor,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_detimpagado(
      psseguro IN NUMBER,
      pnrecibo IN NUMBER,
      pfaccion IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_set_impagado(
      psseguro IN NUMBER,
      pnrecibo IN NUMBER,
      pfaccion IN DATE,
      pfalta IN DATE,
      pcmotdev IN NUMBER,
      pcaccion IN NUMBER,
      pcsituac IN NUMBER,
      pttexto IN VARCHAR2,
      pterror IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_elimina_impagado(
      psseguro IN NUMBER,
      pnrecibo IN NUMBER,
      pfaccion IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_lstcartas(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   -- Funcion para modificar la acción o la carta de un impagado
   -- Bug 22342 - APD - 13/06/2012 - se crea la funcion
   FUNCTION f_set_acccarta(
      psseguro IN NUMBER,
      pnrecibo IN NUMBER,
      pcactimp IN NUMBER,
      pffejecu IN DATE,
      pcactact IN NUMBER,
      pccarta IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;
END pac_iax_impaga;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_IMPAGA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_IMPAGA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_IMPAGA" TO "PROGRAMADORESCSI";
