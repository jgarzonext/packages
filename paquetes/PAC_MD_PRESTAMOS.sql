--------------------------------------------------------
--  DDL for Package PAC_MD_PRESTAMOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_MD_PRESTAMOS" AS
   /******************************************************************************
      NOMBRE:      PAC_IAX_PRESTAMOS
      PROP脫SITO:   Contiene las funciones de gesti贸n de los prestamos

      REVISIONES:
      Ver        Fecha        Autor             Descripci贸n
      ---------  ----------  ---------------  ------------------------------------
      1.0        30/11/2011   DRA               1. 0019238: LCOL_T001- Pr猫stecs de p貌lisses de vida
      2.0        19/09/2012   MDS               2. 0023749: LCOL_T001-Autoritzaci? de prestecs
      3.0        01/10/2012   MDS               3. 0023772: LCOL_T001-Reversi? de prestecs
      4.0        25/10/2012   MDS               4. 0024192: LCOL898-Modificacions Notificaci? recaudo CxC
      5.0        30/11/2012   AEG               5. 0024898: LCOL_T001-QT5354: Los prestamos que son cancelados o reversados no deben mostrarse en SIR para eventuales pagos de cuotas.
      6.0        30/11/2012   JRV              15. 0024448: LCOL_T001-LCOL - qtracker 5181 - Calcul venciments quadre amortitzaci?
   ******************************************************************************/
   FUNCTION f_get_lstprestamos(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_get_detprestamo(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pctapres IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes,
      pcuotadesc IN NUMBER DEFAULT 0,
      phastahoy IN NUMBER DEFAULT 0)
      RETURN ob_iax_prestamo;

   FUNCTION f_consulta_presta(
      pcramo IN NUMBER,
      psproduc IN NUMBER,
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      pctapres IN VARCHAR2,
      pnnumide IN VARCHAR2,
      psnip IN VARCHAR2,
      pbuscar IN VARCHAR2,
      ptipoper IN NUMBER,
      pcactivi IN NUMBER,
      pfiltro IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_consulta_lstprst(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pctapres IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_get_prestamoseg(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pctapres IN VARCHAR2,
      pnerror OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_prestamoseg;

   FUNCTION f_get_prestamos(
      pctipdoc IN NUMBER,
      ptdoc IN VARCHAR2,
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      pctapres IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes,
      -- 2012/11/30 aeg BUG:0024898 se agrega el sig. parametro.
      pcestado IN NUMBER DEFAULT NULL,
      pcuotadesc IN NUMBER DEFAULT 0,
      phastahoy IN NUMBER DEFAULT 0)
      RETURN t_iax_prestamo;

   FUNCTION f_get_prestcuadro(
      pctapres IN VARCHAR2,
      pcmoneda IN VARCHAR2,
      psseguro IN NUMBER,
      pcempres IN NUMBER,
      mensajes IN OUT t_iax_mensajes,
      pcuotadesc IN NUMBER DEFAULT 0,
      phastahoy IN NUMBER DEFAULT 0)
      RETURN t_iax_prestcuadro;

   FUNCTION f_obtener_porcentaje(
      pfiniprest IN DATE,
      psproduc IN NUMBER,
      pinteres OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_insertar_prestamo(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      pctapres IN VARCHAR2,
      pfiniprest IN DATE,
      pffinprest IN DATE,
      pfalta IN DATE,
      picapital IN NUMBER,
      pcmoneda IN VARCHAR2,
      pporcen IN NUMBER,
      pctipo IN NUMBER,
      pctipban IN NUMBER,
      pcbancar IN VARCHAR2,
      pf1cuota IN DATE,
      pffecpag IN DATE,
      pcforpag IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_anula_prestamo(pctapres IN VARCHAR2, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

-- Bug 19238/104039 - 18/01/2012 - AMC - Se a帽aden nuevos parametros a la funci贸n
   FUNCTION f_get_cuotas(
      pctapres IN VARCHAR2,
      pticapital OUT NUMBER,
      ptiinteres OUT NUMBER,
      ptidemora OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_prestamocuotas;

-- Bug 24448/135145 LCOL_T001-LCOL - qtracker 5181 - Calcul venciments quadre amortitzaci?
   FUNCTION f_calc_demora_cuota(
      pcmoneda IN NUMBER,
      picapital IN NUMBER,
      pfvencim IN DATE,
      psseguro IN NUMBER,
      psproduc IN NUMBER,
      pfecha IN DATE,
      pidemora OUT NUMBER,
      mensajes IN OUT t_iax_mensajes,
      pforigen IN DATE)
      RETURN NUMBER;

   /*************************************************************************
       f_mov_prestamocuota
       Funcion para insertar movimiento en las cuotas del prestamo
       param in pctapres      : Identificador del pr茅stamo
       param in pfinicua     : Versi贸n del cuadro
       param in picappend    : capital pendiente
       param in pfvencim        : Fecha vencimiento de la cuota
       param in pidpago     : identificador del pago
       param in pnlinea      : identificador de la linea
       param out psmovcuo    : Secuencia movimiento cuota
       return              : 0 (todo Ok)
                             <> 0 (ha habido algun error)
    *************************************************************************/
   FUNCTION f_mov_prestamocuota(
      pctapres IN VARCHAR2,
      pfinicua IN DATE,
      picappend IN NUMBER,
      pfvencim IN DATE,
      pidpago IN NUMBER,
      pnlinea IN NUMBER,
      pfmovini IN DATE,
      pcestcuo IN NUMBER,
      psmovcuo OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
       f_mov_prestamopago
       Funcion para insertar movimiento en el pago del prestamo
       param in pctapres      : Identificador del pr茅stamo
       param in pnpago     : Versi贸n del cuadro
       param in pcestpag    : capital pendiente
       param in pcsubpag        : Fecha vencimiento de la cuota
       param in pfefecto     : identificador del pago
       param out pnmovpag    : N煤mero de movimiento del pago
       return              : 0 (todo Ok)
                             <> 0 (ha habido algun error)
    *************************************************************************/
   FUNCTION f_mov_prestamopago(
      pctapres IN VARCHAR2,
      pnpago IN NUMBER,
      pcestpag IN NUMBER,
      pcsubpag IN NUMBER,
      pfefecto IN DATE,
      pnmovpag OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   -- Ini Bug : 23749 - MDS - 19/09/2012
   /*************************************************************************
       f_mov_prestamos
       Funci髇 para insertar un movimiento de pr閟tamos
       param in  pctapres  : Identificador del pr閟tamo
       param in  pfalta    : Fecha de alta del pr閟tamo
       param in  pcestado  : Nuevo estado actual del pr閟tamo
       param in  pfmovini  : Fecha inicio de vigencia del nuevo estado
       param out psmovpres : Secuencia del nuevo movimiento
       return              : 0 (todo OK)
                             <> 0 (ha habido algun error)
    *************************************************************************/
   FUNCTION f_mov_prestamos(
      pctapres IN VARCHAR2,
      pfalta IN DATE,
      pcestado IN NUMBER,
      pfmovini IN DATE,
      psmovpres OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
       f_autorizar
       Funci髇 para autorizar un pr閟tamo
       param in  pctapres    : Identificador del pr閟tamo
       param in  pfalta      : Fecha de alta del pr閟tamo
       param in  pfautoriza  : Fecha de autorizaci髇 del pr閟tamo
       param in  pnmovimi    : N鷐ero de movimiento
       param in  pffecpag    : Fecha de efecto del pr閟tamo
       param in  picapital   : Capital del pr閟tamo
       return                : 0 (todo OK)
                               <> 0 (ha habido algun error)
    *************************************************************************/
   FUNCTION f_autorizar(
      pctapres IN VARCHAR2,
      pfalta IN DATE,
      pfautoriza IN DATE,
      pnmovimi IN NUMBER,
      pffecpag IN DATE,
      picapital IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

-- Fin Bug : 23749 - MDS - 19/09/2012

   -- Ini Bug 23772 - MDS - 01/10/2012

   /*************************************************************************
       f_reversar_prestamo
       Funci髇 para reversar un pr閟tamo
       param in  pctapres    : Identificador del pr閟tamo
       param in  pfalta      : Fecha de alta del pr閟tamo
       param in  pfrechaza   : Fecha de reversi髇 del pr閟tamo
       param in  pnmovimi    : N鷐ero de movimiento
       return                : 0 (todo OK)
                               <> 0 (ha habido algun error)
    *************************************************************************/
   FUNCTION f_reversar_prestamo(
      pctapres IN VARCHAR2,
      pfalta IN DATE,
      pfrechaza IN DATE,
      pnmovimi IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

-- Fin Bug 23772 - MDS - 01/10/2012
   FUNCTION f_permite_reversar(
      pctapres IN VARCHAR2,
      psepermite OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

-- Ini Bug 24192 - MDS - 26/10/2012
   FUNCTION f_fecha_ult_prest(
      p_ctapres IN VARCHAR2,
      p_falta OUT DATE,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

-- Fin Bug 24192 - MDS - 26/10/2012

   -- Bug 24448/135145 LCOL_T001-LCOL - qtracker 5181 - Calcul venciments quadre amortitzaci?
   FUNCTION f_calc_demora_cuota_prorr(
      pcmoneda IN NUMBER,
      picapital IN NUMBER,
      pforigen IN DATE,
      pfvencim IN DATE,
      psseguro IN NUMBER,
      psproduc IN NUMBER,
      pfecha IN DATE,
      pidemora OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;
-- BUG: 24448  11/03/2013  AMJ   Se hace la nota 140238 Fin
END pac_md_prestamos;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_PRESTAMOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_PRESTAMOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_PRESTAMOS" TO "PROGRAMADORESCSI";
