--------------------------------------------------------
--  DDL for Package PAC_CTACLIENTE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_CTACLIENTE" AUTHID CURRENT_USER IS
   /******************************************************************************
      NOMBRE:     PAC_CTACLIENTE
      PROPÓSITO:  Funciones de la cuenta de cliente

      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.0        20/02/2013   XXX                1. Creación del package.
    ******************************************************************************/
   ggrabar        NUMBER := 1;

   FUNCTION f_numlin_next(
      pcempres IN NUMBER,
      psperson IN NUMBER,
      psseguro IN NUMBER,
      psproduc IN NUMBER)
      RETURN NUMBER;

   /******************************************************************************
      NOMBRE:     F_RECALCUL_SALDO
      PROPÓSITO:  Funcion que recalcula el SALDO en CTACLIENTE.
    *****************************************************************************/
   FUNCTION f_recalcul_saldo(
      pcempres IN NUMBER,
      psperson IN NUMBER,
      psseguro IN NUMBER,
      psproduc IN NUMBER,
      pffecmov IN DATE DEFAULT NULL,
      pnnumlin IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

   /******************************************************************************
      NOMBRE:     F_SALDO_CTACLIENTE
      PROPÓSITO:  Funcion que mira el saldo de un sseguro/sperson en CTACLIENTE.
    *****************************************************************************/
   FUNCTION f_saldo_ctacliente(
      pcempres IN NUMBER,
      psperson IN NUMBER,
      psseguro IN NUMBER,
      psproduc IN NUMBER,
      pssaldo OUT NUMBER,
      pssaldo_pro OUT NUMBER)
      RETURN NUMBER;

   /******************************************************************************
      NOMBRE:     F_INSCTACLIENTE
      PROPÓSITO:  Funcion génerica que Inserta un registro en cuenta cliente.
    *****************************************************************************/
   FUNCTION f_insctacliente(
      pcempres IN NUMBER,
      psperson IN NUMBER,
      psseguro IN NUMBER,
      pnnumlin IN NUMBER,
      pffecmov IN DATE,
      pffecval IN DATE,
      pcmovimi IN NUMBER,
      ptdescri IN VARCHAR2,
      piimppro IN NUMBER,
      pcmoneda IN VARCHAR2,
      piimpope IN NUMBER,
      piimpins IN NUMBER,
      pfcambio IN DATE,
      pnrecibo IN NUMBER,
      psproces IN NUMBER DEFAULT NULL,
      psproduc IN NUMBER DEFAULT NULL,
      pseqcaja IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

   /******************************************************************************
      NOMBRE:     F_TITULAR_CTACLIENTE
      PROPÓSITO:  Funcion que busca el titular ctacliente.
    *****************************************************************************/
   FUNCTION f_titular_ctacliente(
      psseguro IN NUMBER,
      pctipreb IN NUMBER,
      pnrecibo IN NUMBER,
      psperson IN OUT NUMBER)
      RETURN NUMBER;

   /******************************************************************************
      NOMBRE:     F_INS_MOVPAPCTACLI
      PROPÓSITO:  Funcion que se llama desde PAGOS MASIVOS.
    *****************************************************************************/
   FUNCTION f_ins_movpapctacli(
      pcempres IN NUMBER,
      psperson IN NUMBER,
      psseguro IN NUMBER,
      psproces IN NUMBER,
      piimppro IN NUMBER,
      pcmoneda IN NUMBER,
      piimpope IN NUMBER,
      pitasa IN NUMBER,
      piimpins IN NUMBER,
      pfmovto IN DATE,
      pctipreb IN NUMBER,
      pnrecibo IN NUMBER,
      pseqcaja IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

   /******************************************************************************
      NOMBRE:     F_INS_MOVPATCTACLI
      PROPÓSITO:  Funcion que se llama desde el modulo de CAJA. Pago de recibos
    *****************************************************************************/
   FUNCTION f_ins_movpatctacli(
      pcempres IN NUMBER,
      psperson IN NUMBER,
      psseguro IN NUMBER,
      psproduc IN NUMBER,
      piimppro IN NUMBER,
      pcmoneda IN NUMBER,
      piimpope IN NUMBER,
      piimpins IN NUMBER,
      pfmovto IN DATE,
      pnrecibo IN NUMBER,
      pseqcaja IN NUMBER DEFAULT NULL,
      pfefecto IN DATE DEFAULT NULL)
      RETURN NUMBER;

   /******************************************************************************
      NOMBRE:     F_INS_MOVRECCTACLI
      PROPÓSITO:  Funcion que inserta un recibo.
    *****************************************************************************/
   FUNCTION f_ins_movrecctacli(
      pcempres IN NUMBER,
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pnrecibo IN NUMBER,
      pcorigen IN NUMBER DEFAULT 0)
      RETURN NUMBER;

   /*************************************************************************
      Obtiene las polizas asociadas a un cliente
      param in sperson  : Codigo de persona
      param out mensajes : mensajes de error
      return             : referencia de cursor con el listado de polizas asociadas
   *************************************************************************/
   FUNCTION f_obtenerpolizas(psperson per_personas.sperson%TYPE, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

    /*************************************************************************
      Obtiene las personas asociadas a una poliza que hayan generado movimientos en la misma
      param in sperson  : Codigo de persona
      param out mensajes : mensajes de error
      return             : referencia de cursor con el listado de personas asociadas
   *************************************************************************/
   FUNCTION f_obtenerpersonas(psseguro seguros.sseguro%TYPE, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /******************************************************************************
      NOMBRE:     F_INS_PAGOINICTACLI
      PROPÓSITO:  Funcion que inserta el Mvto de pago Inicial en CTACLIENTE
    *****************************************************************************/
   FUNCTION f_ins_pagoinictacli(
      pcempres IN NUMBER,
      psperson IN NUMBER,
      psseguro IN NUMBER,
      pffecmov IN DATE,
      piimpope IN NUMBER,
      pcmoneda IN NUMBER,
      psproduc IN NUMBER,
      pseqcaja IN NUMBER,
      pfcambio IN DATE DEFAULT NULL,
      ptdescri IN VARCHAR2 DEFAULT NULL,   --BUG 32667:NSS:13/10/2014
      panula IN NUMBER DEFAULT 0)   --BUG 32667:NSS:13/10/2014
      RETURN NUMBER;

   /******************************************************************************
      NOMBRE:     F_UNIR_CTACLIENTE_PINICIAL
      PROPÓSITO:  Funcion que une las cuentas Clientes entre el Mvto de pago Inicial
                  y el Generado al emitir la póliza. Dejando pagado el recibo.
    *****************************************************************************/
   FUNCTION f_unir_ctacliente_pinicial(
      psseguro IN NUMBER,
      psproduc IN NUMBER,
      pfecha IN DATE,
      pnmovimi IN NUMBER)
      RETURN NUMBER;

   /******************************************************************************
      NOMBRE:     F_PAGO_RECIBO
      PROPÓSITO:  Funcion que genera el movimiento de pagado en un recibo
    *****************************************************************************/
   FUNCTION f_pago_recibo(pnrecibo IN NUMBER)
      RETURN NUMBER;

   /******************************************************************************
      NOMBRE:     F_PAGAR_RECIBO_CONSALDO
      PROPÓSITO:  Funcion que genera el pago si al emitir un recibo hay saldo
    *****************************************************************************/
   FUNCTION f_pagar_recibo_consaldo(
      pcempres IN NUMBER,
      psperson IN NUMBER,
      psseguro IN NUMBER,
      pcmovimi IN NUMBER,
      pnrecibo IN NUMBER,
      piimppro IN NUMBER,
      pisaldo_prod IN NUMBER)
      RETURN NUMBER;

   /******************************************************************************
      NOMBRE:     F_MOVCTACLIENTE_RECUNIF   --Bug 31135
      PROPÓSITO:  Funcion que genera el movimiento en ctacliente para los n-recibos unificados
    *****************************************************************************/
   FUNCTION f_movctacliente_recunif(precunif IN NUMBER, pcmovimi IN NUMBER)
      RETURN NUMBER;

   /******************************************************************************
       NOMBRE:     F_INSCTACLIENTE_SPL
       PROPÓSITO:  Funcion génerica que Inserta un registro en cuenta cliente., LOGICA MSV
     *****************************************************************************/
   FUNCTION f_insctacliente_spl(
      pcempres IN NUMBER,
      psperson IN NUMBER,
      psseguro IN NUMBER,
      pnnumlin IN NUMBER,
      pffecmov IN DATE,
      pffecval IN DATE,
      pcmovimi IN NUMBER,
      ptdescri IN VARCHAR2,
      piimppro IN NUMBER,
      pcmoneda IN VARCHAR2,
      piimpope IN NUMBER,
      piimpins IN NUMBER,
      pfcambio IN DATE,
      pnrecibo IN NUMBER,
      psproces IN NUMBER DEFAULT NULL,
      psproduc IN NUMBER DEFAULT NULL,
      pseqcaja IN NUMBER DEFAULT NULL,
      pnreembo IN NUMBER DEFAULT NULL)   --Bug 33886/199825 ACL 23/04/2015
      RETURN NUMBER;

   FUNCTION f_apunte_pago_spl(
      pcempres NUMBER,
      psseguro NUMBER,
      pimporte NUMBER,
      pncheque IN VARCHAR2 DEFAULT NULL,
      pcestchq IN NUMBER DEFAULT NULL,
      pcbanco IN NUMBER DEFAULT NULL,
      pccc IN VARCHAR2 DEFAULT NULL,
      pctiptar IN NUMBER DEFAULT NULL,
      pntarget IN VARCHAR2 DEFAULT NULL,
      pfcadtar IN VARCHAR2 DEFAULT NULL,
      pcmedmov IN NUMBER DEFAULT NULL,
      pcmoneop IN NUMBER DEFAULT 1,
      pnrefdeposito IN NUMBER DEFAULT NULL,
      pcautoriza IN NUMBER DEFAULT NULL,
      pnultdigtar IN NUMBER DEFAULT NULL,
      pncuotas IN NUMBER DEFAULT NULL,
      pccomercio IN NUMBER DEFAULT NULL,
      pdsbanco IN VARCHAR2 DEFAULT NULL,
      pctipche IN NUMBER DEFAULT NULL,
      pctipched IN NUMBER DEFAULT NULL,
      pcrazon IN NUMBER DEFAULT NULL,
      pdsmop IN VARCHAR2 DEFAULT NULL,
      pfautori IN DATE DEFAULT NULL,
      pcestado IN NUMBER DEFAULT NULL,
      psseguro_d IN NUMBER DEFAULT NULL,
      pseqcaja_o IN NUMBER DEFAULT NULL,
      psperson IN NUMBER DEFAULT NULL,
      pseqcaja OUT NUMBER,
      ptdescchk IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;

   FUNCTION f_cobrecibos_spl(
      psproduc NUMBER,
      psseguro NUMBER,
      pnrecibo NUMBER,
      pusucobro VARCHAR2,
      pfcobro DATE)
      RETURN NUMBER;

   FUNCTION f_transferible_spl(psseguro NUMBER)
      RETURN NUMBER;

--Bug 33886/199825  ACL 24/04/2015
   /******************************************************************************
      NOMBRE:     f_lee_ult_re
      PROPÓSITO:  Cursor que leerá el último registro en la tabla ctacliente para
                  la póliza que se envíe de parámetro
   *************************************************************************/
   FUNCTION f_lee_ult_re(pnpoliza IN seguros.npoliza%TYPE)
      RETURN sys_refcursor;

   /******************************************************************************
    NOMBRE:     F_CREA_REC_GASTO
    PROPÓSITO:  Función que genera un recibo de gasto cuando se supere el max No de devoluciones
   *****************************************************************************/
   FUNCTION f_crea_rec_gasto(psseguro IN seguros.sseguro%TYPE, pimonto IN NUMBER)
      RETURN NUMBER;

--Bug 33886/199825  ACL 24/04/2015
   /******************************************************************************
      NOMBRE:     f_upd_nre
      PROPÓSITO:  Realiza update al campo NREEMBO en la tabla ctacliente
      definido por los parámetros recibidos.
   *************************************************************************/
   FUNCTION f_upd_nre(
      pcempres IN NUMBER,
      psperson IN NUMBER,
      psseguro IN NUMBER,
      pnnumlin IN NUMBER,
      pnreembo IN NUMBER)
      RETURN NUMBER;

   -- Bug 33886/202377
   -- Función que recupera el numero de reembolsos de una poliza
   FUNCTION f_get_nroreembolsos(psseguro IN NUMBER, pnumreembo OUT NUMBER)
      RETURN NUMBER;

   -- Bug 33886/202377
   -- Función que actualiza el numero de reembolsos de una poliza
   FUNCTION f_actualiza_nroreembol(psseguro IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_apunte_spl(
      pcempres IN NUMBER,
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pnrecibo IN NUMBER,
      pcorigen IN NUMBER DEFAULT 0)
      RETURN NUMBER;
END pac_ctacliente;

/

  GRANT EXECUTE ON "AXIS"."PAC_CTACLIENTE" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_CTACLIENTE" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_CTACLIENTE" TO "PROGRAMADORESCSI";
