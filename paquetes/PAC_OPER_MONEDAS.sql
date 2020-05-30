--------------------------------------------------------
--  DDL for Package PAC_OPER_MONEDAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_OPER_MONEDAS" IS
/******************************************************************************
   NOMBRE:    PAC_OPER_MONEDAS
   PROPÓSITO: Funciones para realizar operaciones con monedas

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        25/10/2011   JMP                1. 0018423: LCOL000 - Multimoneda - Creación del package
   2.0        17/04/2012   JMF                0021897 LCOL_S001-SIN - Ajuste cambio moneda tras cierres (UAT 4208)
******************************************************************************/

   /*************************************************************************
    F_VDETRECIBOS_MONPOL
      Funcion que calcula los totales del recibo en la tabla VDETRECIBOS_MONPOL
      a partir de DETRECIBOS.ICONCEP_MONPOL.

      param in pnrecibo : número de recibo
      param in pmodo    : modo
      param in psproces : número de proceso
      return            : 0 (si todo correcto) o código de error
   *************************************************************************/
   FUNCTION f_vdetrecibos_monpol(
      pnrecibo IN NUMBER,
      pmodo IN VARCHAR2,
      psproces IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

   /*************************************************************************
    F_MONPOL
      Funcion que obtiene la moneda a nivel de póliza o la de la empresa en
      su defecto.

      param in psseguro : código de seguro
      return            : la moneda a nivel de póliza o la de la empresa en
                          su defecto
   *************************************************************************/
   FUNCTION f_monpol(psseguro NUMBER)
      RETURN NUMBER;

   /*************************************************************************
    F_MONCONTAB
      Funcion que obtiene la moneda de la contabilidad a partir de un código
      de seguro.

      param in psseguro : código de seguro
      return            : la moneda de la contabilidad
   *************************************************************************/
   FUNCTION f_moncontab(psseguro NUMBER)
      RETURN NUMBER;

   /*************************************************************************
    F_MONRES
      Funcion que obtiene la moneda de la reserva de un siniestro, a partir del
      nº de siniestro o del nº de pago.

      param in pnsinies : número de siniestro
      param in psidepag : número de pago
      return            : la moneda de la reserva
   *************************************************************************/
   FUNCTION f_monres(pnsinies NUMBER, psidepag NUMBER DEFAULT NULL)
      RETURN NUMBER;

   /*************************************************************************
    F_DATOS_CONTRAVAL
      Funcion que obtiene los datos necesarios para calcular los contravalores.

      param in psseguro : código de seguro
      param in pnrecibo : número de recibo
      param in pscontra : código de contrato reaseguro
      param in pfecha   : fecha máxima de cambio
      param in ptipomon : tipo moneda contravalor:
                          1 - póliza; 2 - empresa; 3 - contabilidad
      param out pitasa  : tasa a aplicar
      param out pfcambio: fecha de cambio a grabar
      param in pmodo    : modo
      param in psproces : número de proceso
      return            : 0 (si todo correcto) o código de error
   *************************************************************************/
   FUNCTION f_datos_contraval(
      psseguro NUMBER,
      pnrecibo NUMBER,
      pscontra NUMBER,
      pfecha IN DATE,
      ptipomon IN NUMBER,
      pitasa OUT NUMBER,
      pfcambio OUT DATE,
      pmodo IN VARCHAR2 DEFAULT 'R',
      psproces IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

   /*************************************************************************
    F_CONTRAVALORES_RECIBO
      Funcion que calcula los contravalores de un recibo.

      param in pnrecibo : número de recibo
      param in pnrecibo : número de recibo
      param in pmodo    : modo
      param in psproces : número de proceso
      return            : 0 (si todo correcto) o código de error
   *************************************************************************/
   FUNCTION f_contravalores_recibo(
      pnrecibo NUMBER,
      pmodo VARCHAR2,
      psproces NUMBER DEFAULT NULL)
      RETURN NUMBER;

   /*************************************************************************
    F_CONTRAVALORES_PROVMAT
      Funcion que calcula los contravalores de la tabla PROVMAT.

      param in psproces : código de proceso
      param in psseguro : código de seguro
      param in pnriesgo : número de riesgo
      param in pcgarant : código de garantía
      param in pfcalcul : fecha de cálculo
      return            : 0 (si todo correcto) o código de error
   *************************************************************************/
   FUNCTION f_contravalores_provmat(
      psproces NUMBER,
      psseguro NUMBER,
      pnriesgo NUMBER,
      pcgarant NUMBER,
      pfcalcul DATE)
      RETURN NUMBER;

   /*************************************************************************
    F_CONTRAVALORES_RESERVA
      Funcion que calcula los contravalores de las tablas SIN_TRAMITA_RESERVA.

      param in pnsinies: número de siniestro
      param in pntramit: número de tramitación
      param in pctipres: tipo de reserva
      param in pnmovres: número de movimiento de la reserva
      param in pcgarant: código de garantía
      param in pfcambio: fecha cambio (si es vacio sera fecha del dia).
      return            : 0 (si todo correcto) o código de error
   -- Bug 0021897 - 17/04/2012 - JMF
   *************************************************************************/
   FUNCTION f_contravalores_reserva(
      pnsinies NUMBER,
      pntramit NUMBER,
      pctipres NUMBER,
      pnmovres NUMBER,
      pcgarant NUMBER DEFAULT NULL,
      pfcambio DATE DEFAULT NULL)
      RETURN NUMBER;

   /*************************************************************************
    F_CONTRAVALORES_PAGOSINI
      Funcion que calcula los contravalores de las tablas SIN_TRAMITA_PAGO y
      SIN_TRAMITA_PAGO_GAR.

      param in psidepag : identificador del pago
      param in ptabla   : 1 - sin_tramita_pago; 2 - sin_tramita_pago_gar
      return            : 0 (si todo correcto) o código de error
   *************************************************************************/
   FUNCTION f_contravalores_pagosini(psidepag NUMBER, ptabla NUMBER)
      RETURN NUMBER;

   /*************************************************************************
    F_UPDATE_CTASEGURO_MONPOL
      Funcion que actualiza los importes de contravalor en una o varias filas
      de CTASEGURO.

      param in psseguro : identificador del seguro
      param in pfcontab : fecha contable
      param in pnnumlin : número de línea
      param in pfvalmov : fecha valor
      return            : 0 (si todo correcto) o código de error
   *************************************************************************/
   FUNCTION f_update_ctaseguro_monpol(
      psseguro NUMBER,
      pfcontab DATE,
      pnnumlin NUMBER,
      pfvalmov DATE DEFAULT NULL)
      RETURN NUMBER;

   /*************************************************************************
     F_UPDATE_CTASEGURO_SHW_MONPOL
       Funcion que actualiza los importes de contravalor en una o varias filas
       de CTASEGURO_SHADOW.

       param in psseguro : identificador del seguro
       param in pfcontab : fecha contable
       param in pnnumlin : número de línea
       param in pfvalmov : fecha valor
       return            : 0 (si todo correcto) o código de error
    *************************************************************************/
   FUNCTION f_update_ctaseguro_shw_monpol(
      psseguro NUMBER,
      pfcontab DATE,
      pnnumlin NUMBER,
      pfvalmov DATE DEFAULT NULL)
      RETURN NUMBER;

   /*************************************************************************
    F_CONTRAVALORES_PAGOSRENTA
      Funcion que calcula los contravalores de las tablas pagosrenta

      param in psrecren : identificador del pago de renta
      param in psseguro : identificador del seguro
      return            : 0 (si todo correcto) o código de error
   *************************************************************************/
   FUNCTION f_contravalores_pagosrenta(psrecren IN NUMBER, psseguro IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
    F_CONTRAVALORES_TMP_PAGOSRENTA
      Funcion que calcula los contravalores de las tablas pagosrenta

      param in psrecren : identificador del pago de renta
      param in psseguro : identificador del seguro
      return            : 0 (si todo correcto) o código de error
   *************************************************************************/
   FUNCTION f_contravalores_tmp_pagosrenta(
      pstmppare IN NUMBER,
      psseguro IN NUMBER,
      psperson IN NUMBER,
      pffecpag IN DATE)
      RETURN NUMBER;

   /*************************************************************************
    F_CONTRAVALORES_PLANRENTASEXTRA
      Funcion que calcula los contravalores de las tablas planrentasextra

      param in psseguro : identificador del seguro
      param in pnriesgo : número de riesgo
      param in pnmovimi : número de movimiento
      return            : 0 (si todo correcto) o código de error
   *************************************************************************/
   FUNCTION f_contravalores_planrentasextr(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER)
      RETURN NUMBER;

   error_params   EXCEPTION;
END pac_oper_monedas;

/

  GRANT EXECUTE ON "AXIS"."PAC_OPER_MONEDAS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_OPER_MONEDAS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_OPER_MONEDAS" TO "PROGRAMADORESCSI";
