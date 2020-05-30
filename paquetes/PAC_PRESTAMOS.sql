--------------------------------------------------------
--  DDL for Package PAC_PRESTAMOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_PRESTAMOS" IS
   /******************************************************************************
       NOMBRE:      PAC_PRESTAMOS
       PROPÓSITO:   Funciones para la gestión de los prestamos

       REVISIONES:
       Ver        Fecha        Autor             Descripción
       ---------  ----------  ---------------  ------------------------------------
       1.0        21/10/2009   APD             1. Creación del package.Bug 9204
       2.0        01/12/2011   DRA             2. 0019238: LCOL_T001- Prèstecs de pòlisses de vida
       3.0        11/07/2012   JGR             3. 0022738: No se canceló la póliza 1541 despues de tres intetos de cobro no exitosos. - 0118685
       4.0        17/09/2011   MDS             4. 0023588: LCOL - Canvis pantalles de prestecs
       5.0        18/09/2012   MDS             5. 0023749: LCOL_T001-Autoritzaci? de prestecs
       6.0        27/09/2012   MDS             6. 0023821: LCOL_T001-Ajustar llistat prestecs pendents (qtracker 4364)
       7.0        01/10/2012   MDS             7. 0023772: LCOL_T001-Reversi? de prestecs
       8.0        01/10/2012   ASN             8. 0023746
       9.0        22/10/2012   MDS             9. 0024078: LCOL_F001-Din?mica comptable pr?stecs - Proc?s de tancament mensual
      10.0        05/11/2012   MDS            10. 0024553: LCOL_T001- qtracker 5348 - interessos prestecs anulats/cancelats/reversats
      11.0        10/12/2012   MDS            11. 0025005: LCOL_T001-QT 4367 -Llistat polisses anulades amb prestecs
      12.0        13/01/2013   JRV            12. 0024448: LCOL_T001-LCOL - qtracker 5181 - Calcul venciments quadre amortitzaci?
      13.0        11/03/2013   AMJ            13. 0024448: LCOL_T001-LCOL - qtracker 5181 - Calcul venciments quadre amortitzaci?

   ******************************************************************************/
   TYPE reg_amortiza IS RECORD(
      fefecto        DATE,
      fvencim        DATE,
      ncuota         NUMBER,
      icapital       NUMBER,
      intereses      NUMBER,
      icappend       NUMBER
   );

   TYPE tab_amortiza IS TABLE OF reg_amortiza
      INDEX BY BINARY_INTEGER;

   /*************************************************************************
      Funcion para obtener la fecha de alta de un prestamo
      param in p_ctapres  : Identificador del prestamo
      param out p_falta   :  Fecha de Alta del prestamo
      return              : 0 (todo Ok)
                            <> 0 (ha habido algun error)
   *************************************************************************/
   FUNCTION f_fecha_ult_prest(p_ctapres IN VARCHAR2, p_falta OUT DATE)
      RETURN NUMBER;

   FUNCTION f_obtener_porcentaje(
      pfiniprest IN DATE,
      psproduc IN NUMBER,
      pctipoint IN NUMBER,   -- 1 (Interes),  2 (Interes de mora)
      pinteres OUT NUMBER)
      RETURN NUMBER;

   /*************************************************************************
      Funcion para insertar los prestamos
      param in psseguro      : Identificador del seguro
      param in pnriesgo      : Identificador del riesgo
      param in pctapres      : Identificador del préstamo
      param in pfiniprest    : Fecha de inicio del préstamo
      param in pffinprest    : Fecha de vencimiento del préstamo
      param in pfalta        : Fecha de registro en iAxis
      param in picapital     : Capital del préstamo
      param in imoneda       : Moneda de gestión del préstamo
      param in pporcen       : Porcentaje de interés del préstamo
      param in pctipo        : Indicador de si el préstamo es automático o manual
      param in out pmensajes : Mensajes de Error
      return              : 0 (todo Ok)
                            <> 0 (ha habido algun error)
   *************************************************************************/
   FUNCTION f_insertar_prestamo(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      pctapres IN VARCHAR2,
      pfiniprest IN DATE,
      pffinprest IN DATE,
      pfalta IN DATE,
      picapital IN NUMBER,
      pcmoneda IN NUMBER,
      pporcen IN NUMBER,
      pctipo IN NUMBER,
      pctipban IN NUMBER,
      pcbancar IN VARCHAR2,
      pf1cuota IN DATE,
      pffecpag IN DATE,
      pcforpag IN NUMBER,
      pmodo IN NUMBER DEFAULT NULL   -- 3. 0022738 / 0118685 (+)
                                  )
      RETURN NUMBER;

   /*************************************************************************
      Funcion para insertar las cuotas del prestamo
      param in pctapres      : Identificador del préstamo
      param in pfinipres     : Fecha de inicio del préstamo
      param in pffinprest    : Fecha de vencimiento del préstamo
      param in pfalta        : Fecha de registro en iAxis
      param in picapital     : Capital del préstamo
      param in pcforpag      : Número de cuotas por año
      param in ptasa         : Porcentaje de interés del préstamo
      return              : 0 (todo Ok)
                            <> 0 (ha habido algun error)
   *************************************************************************/
   FUNCTION f_ins_prestcuadro(
      pctapres IN VARCHAR2,
      pfiniprest IN DATE,
      pffinprest IN DATE,
      pfalta IN DATE,
      picapital IN NUMBER,
      pcforpag IN NUMBER DEFAULT 12,
      ptasa IN NUMBER,
      pcmoneda IN NUMBER,
      pnmesdur IN NUMBER,
      pf1cuota IN DATE,
      pcempres IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_calcula_cuadro(
      pfiniprest IN DATE,
      pffinprest IN DATE,
      pfefecto IN DATE,
      picapital IN NUMBER,
      ptasa IN NUMBER,
      pcforpag IN NUMBER DEFAULT 12,
      pmodo IN NUMBER,
      pcuadro IN OUT tab_amortiza,
      pnmesdur IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_insert_cuota(
      pctapres IN VARCHAR2,
      pidpago IN NUMBER,
      pfpago IN DATE,
      picapital IN NUMBER,
      pfalta IN DATE,
      pcmoneda IN NUMBER,
      pcempres IN NUMBER,
      --26981/0171128
      pcestado IN NUMBER DEFAULT 4)
      RETURN NUMBER;

   FUNCTION f_get_cappend(pctapres IN VARCHAR2, pfalta IN DATE, pfefecto IN DATE)
      RETURN NUMBER;

   FUNCTION f_calc_demora_cuota(
      pcmoneda IN NUMBER,
      picapital IN NUMBER,
      pforigen IN DATE,
      pfvencim IN DATE,
      psseguro IN NUMBER,
      psproduc IN NUMBER,
      pfecha IN DATE,
      pidemora OUT NUMBER,
      pintdiames IN NUMBER DEFAULT 0)
      RETURN NUMBER;

   FUNCTION f_calc_interes(
      pcmoneda IN NUMBER,
      picapital IN NUMBER,
      pforigen IN DATE,
      psseguro IN NUMBER,
      psproduc IN NUMBER,
      pfecha IN DATE,
      pinteres OUT NUMBER,
      pctapres IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

   /*************************************************************************
       f_mov_prestamocuota
       Funcion para insertar movimiento en las cuotas del prestamo
       param in pctapres      : Identificador del préstamo
       param in pfinicua     : Versión del cuadro
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
      psmovcuo OUT NUMBER)
      RETURN NUMBER;

   /*************************************************************************
       f_mov_prestamopago
       Funcion para insertar movimiento en el pago del prestamo
       param in pctapres      : Identificador del préstamo
       param in pnpago     : Versión del cuadro
       param in pcestpag    : capital pendiente
       param in pcsubpag        : Fecha vencimiento de la cuota
       param in pfefecto     : identificador del pago
       param out pnmovpag    : Número de movimiento del pago
       return              : 0 (todo Ok)
                             <> 0 (ha habido algun error)
    *************************************************************************/
   FUNCTION f_mov_prestamopago(
      pctapres IN VARCHAR2,
      pnpago IN NUMBER,
      pcestpag IN NUMBER,
      pcsubpag IN NUMBER,
      pfefecto IN DATE,
      pnmovpag OUT NUMBER)
      RETURN NUMBER;

    -- Inicio  Bug: 0023253: LCOL_T001-qtracker 4813 - Primas pagades vs prestecs  HPM
   /*************************************************************************
        FUNCTION f_verif_pago_recb
        Verifica para una póliza si hay recibos pendientes para realizar un prestamo
        param in psseguro   : código de la poliza
        return             : 0 y -1 para porder calcular el prestamo en caso contrario devolverá el código del literal de error
   *************************************************************************/
   FUNCTION f_verif_pago_recb(psseguro IN NUMBER)
      RETURN NUMBER;

-- Fin  Bug: 0023253: LCOL_T001-qtracker 4813 - Primas pagades vs prestecs  HPM
   -- Ini Bug : 23588 - MDS - 17/09/2012
   FUNCTION f_get_totalpend(
      pctapres IN VARCHAR2,
      pfalta IN DATE,
      pfefecto IN DATE,
      psseguro IN NUMBER,
      psproduc IN NUMBER,
      pcmoneda IN NUMBER,
      pfiniprest IN DATE)
      RETURN NUMBER;

-- Fin : 23588 - MDS - 17/09/2012

   -- Ini Bug : 23749 - MDS - 18/09/2012
   /*************************************************************************
       f_mov_prestamos
       Función para insertar un movimiento de préstamos
       param in  pctapres  : Identificador del préstamo
       param in  pfalta    : Fecha de alta del préstamo
       param in  pcestado  : Nuevo estado actual del préstamo
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
      psmovpres OUT NUMBER)
      RETURN NUMBER;

   /*************************************************************************
       f_autorizar
       Función para autorizar un préstamo
       param in  pctapres    : Identificador del préstamo
       param in  pfalta      : Fecha de alta del préstamo
       param in  pfautoriza  : Fecha de autorización del préstamo
       param in  pnmovimi    : Número de movimiento
       param in  pffecpag    : Fecha de efecto del préstamo
       param in  picapital   : Capital del préstamo
       return                : 0 (todo OK)
                               <> 0 (ha habido algun error)
    *************************************************************************/
   FUNCTION f_autorizar(
      pctapres IN VARCHAR2,
      pfalta IN DATE,
      pfautoriza IN DATE,
      pnmovimi IN NUMBER,
      pffecpag IN DATE,
      picapital IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
       f_validar
       Función para validar un préstamo
       param in  pctapres    : Identificador del préstamo
       param in  pfalta      : Fecha de alta del préstamo
       param in  picapital   : Capital del préstamo
       param in  pfvalida    : Fecha de validación del préstamo
       param in  psseguro    : Identificador de seguro
       param in  pnriesgo    : Identificador de riesgo
       param in  pfiniprest  : Fecha de inicio del préstamo
       return                : 0 (todo OK)
                               <> 0 (ha habido algun error)
    *************************************************************************/
   FUNCTION f_validar(
      pctapres IN VARCHAR2,
      pfalta IN DATE,
      picapital IN NUMBER,
      pfvalida IN DATE,
      psseguro IN NUMBER DEFAULT NULL,
      pnriesgo IN NUMBER DEFAULT 1,
      pfiniprest IN DATE DEFAULT NULL,
      pmodo IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

   /*************************************************************************
      Funcion para anular el préstamo
      param in pctapres   : Identificador del préstamo
      param in pcestado   : Nuevo estado actual del préstamo
      return              : 0 (todo Ok)
                            <> 0 (ha habido algun error)
   *************************************************************************/
   FUNCTION f_anulacion(pctapres IN VARCHAR2, pcestado IN NUMBER DEFAULT 2)
      RETURN NUMBER;

-- Fin Bug : 23749 - MDS - 18/09/2012
   -- Ini Bug : 23821 - MDS - 27/09/2012
    /*************************************************************************
       f_calc_interesco_prestamo
       Función que calcula los Intereses causados corrientes de un préstamo
       param in  pctapres    : Identificador del préstamo
       param in  pfalta      : Fecha de alta del préstamo
       param in  pfvalida    : Fecha de inicio de cálculo de intereses
       param in  psseguro    : Identificador de seguro
       param in  pfiniprest  : Fecha de inicio del préstamo
       param in  pmodo       : 0-NO tener en cuenta los intereses si cancelado, 1-SI tener en cuenta los intereses si cancelado
       return                : Intereses
    *************************************************************************/
   FUNCTION f_calc_interesco_prestamo(
      pctapres IN VARCHAR2,
      pfalta IN DATE,
      pfvalida IN DATE,
      psseguro IN NUMBER,
      pfiniprest IN DATE,
      pmodo IN NUMBER DEFAULT 0)
      RETURN NUMBER;

   /*************************************************************************
      f_calc_interesdm_prestamo
      Función que calcula los Intereses causados de mora de un préstamo
      param in  pctapres    : Identificador del préstamo
      param in  pfalta      : Fecha de alta del préstamo
      param in  pfvalida    : Fecha de inicio de cálculo de intereses
      param in  psseguro    : Identificador de seguro
      param in  pfiniprest  : Fecha de inicio del préstamo
      param in  pmodo       : 0-NO tener en cuenta los intereses si cancelado, 1-SI tener en cuenta los intereses si cancelado
      return                : Intereses
   *************************************************************************/
   FUNCTION f_calc_interesdm_prestamo(
      pctapres IN VARCHAR2,
      pfalta IN DATE,
      pfvalida IN DATE,
      psseguro IN NUMBER,
      pfiniprest IN DATE,
      pmodo IN NUMBER DEFAULT 0)
      RETURN NUMBER;

   FUNCTION f_calcul_formulas_provi(
      psseguro IN NUMBER,
      pfecha IN DATE,
      pcampo IN VARCHAR2,
      pcgarant IN NUMBER DEFAULT NULL,
      pndetgar IN NUMBER DEFAULT NULL,
      psituac IN NUMBER DEFAULT 1)
      RETURN NUMBER;

-- Fin Bug : 23821 - MDS - 27/09/2012

   -- Ini Bug 23772 - MDS - 01/10/2012

   /*************************************************************************
       f_reversar_prestamo
       Función para reversar un préstamo
       param in  pctapres    : Identificador del préstamo
       param in  pfalta      : Fecha de alta del préstamo
       param in  pfrechaza   : Fecha de reversión del préstamo
       param in  pnmovimi    : Número de movimiento
       return                : 0 (todo OK)
                               <> 0 (ha habido algun error)
    *************************************************************************/
   FUNCTION f_reversar_prestamo(
      pctapres IN VARCHAR2,
      pfalta IN DATE,
      pfrechaza IN DATE,
      pnmovimi IN NUMBER)
      RETURN NUMBER;

-- Fin Bug 23772 - MDS - 01/10/2012

   -- 23746:ASN:01/10/2012 ini
   /*************************************************************************
    Devuelve el importe total en prestamos de una poliza (para calcular la penalizacion de la reserva)
    *************************************************************************/
   FUNCTION f_get_totalprest(psesion IN NUMBER, psseguro IN NUMBER, pfefecto IN NUMBER)
      RETURN NUMBER;

-- 23746:ASN:01/10/2012 fin
   FUNCTION f_permite_reversar(pctapres IN VARCHAR2, psepermite OUT NUMBER)
      RETURN NUMBER;

   -- Ini Bug 24078 - MDS - 22/10/2012
   PROCEDURE proceso_batch_cierre(
      pmodo IN NUMBER,
      pcempres IN NUMBER,
      pmoneda IN NUMBER,
      pcidioma IN NUMBER,
      pfperini IN DATE,
      pfperfin IN DATE,
      pfcierre IN DATE,
      pcerror OUT NUMBER,
      psproces OUT NUMBER,
      pfproces OUT DATE);

-- Fin Bug 24078 - MDS - 22/10/2012

   -- Ini Bug 24553 - MDS - 05/11/2011
    /*************************************************************************
       f_prestamo_cancelado
       Función que indica si un préstamo está cancelado o no
       param in  pctapres    : Identificador del préstamo
       param in  pfalta      : Fecha de alta del préstamo
       param in  pfvalida    : Fecha de validación (inicio de cálculo de intereses)
       return                : 0 - No cancelado
                               1 - Sí cancelado
    *************************************************************************/
   FUNCTION f_prestamo_cancelado(pctapres IN VARCHAR2, pfalta IN DATE, pfvalida IN DATE)
      RETURN NUMBER;

-- Fin Bug 24553 - MDS - 05/11/2011

   -- BUG:2448 JRV Cuadro de vencimiento de cuadro de armortizacion
   FUNCTION f_impcuota_yapagada(
      pctapres IN VARCHAR2,
      pfinicua IN DATE,
      picappend IN NUMBER,
      pnorden IN NUMBER,
      picapital OUT NUMBER,
      piinteres OUT NUMBER,
      pidemora OUT NUMBER,
      pfpago OUT DATE)
      RETURN NUMBER;

   -- BUG: 24448  11/03/2013  AMJ   Se hace la nota 140238 Ini
   FUNCTION f_calc_interesco_cuota(
      pctapres IN VARCHAR2,
      pfalta IN DATE,
      pfvalida IN DATE,
      psseguro IN NUMBER,
      pfefecto IN DATE,
      pfvencim IN DATE,
      pinterestot IN NUMBER,
      pmodo IN NUMBER DEFAULT 0)
      RETURN NUMBER;

   FUNCTION f_calc_interesco_total(
      pctapres IN VARCHAR2,
      pfalta IN DATE,
      pfvalida IN DATE,
      pfiniprest IN DATE,
      psseguro IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_calc_demora_cuota_prorr(
      pcmoneda IN NUMBER,
      picapital IN NUMBER,
      pforigen IN DATE,
      pfvencim IN DATE,
      psseguro IN NUMBER,
      psproduc IN NUMBER,
      pfecha IN DATE,
      pidemora OUT NUMBER)
      RETURN NUMBER;

-- BUG: 24448  11/03/2013  AMJ   Se hace la nota 140238  Fin
   FUNCTION f_impcuota_yapagada_moncia(
      pctapres IN VARCHAR2,
      pfinicua IN DATE,
      picappend IN NUMBER,
      pnorden IN NUMBER,
      picapital OUT NUMBER,
      piinteres OUT NUMBER,
      pidemora OUT NUMBER,
      pfpago OUT DATE)
      RETURN NUMBER;
END pac_prestamos;

/

  GRANT EXECUTE ON "AXIS"."PAC_PRESTAMOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_PRESTAMOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_PRESTAMOS" TO "PROGRAMADORESCSI";
