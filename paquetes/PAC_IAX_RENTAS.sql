--------------------------------------------------------
--  DDL for Package PAC_IAX_RENTAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_IAX_RENTAS" AS
/******************************************************************************
   NOMBRE:       PAC_IAX_RENTAS
   PROPÓSITO: Nuevo paquete de la capa IAX que tendrá las funciones para la gestión de pagos renta.
              Controlar todos posibles errores con PAC_IOBJ_MNSAJES.P_TRATARMENSAJE


   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        16/06/2009   JGM                1. Creación del package.
   2.0        16/06/2009   JGM                1. Actualización Generacion Rentas
   3.0        11/02/2010   AMC                3. 0011392: CRE - Añadir a la consulta de pólizas las rentas.
   4.0        20/04/2010   ICV                4. 0012914: CEM - Reimprimir listados de pagos de rentas
   5.0        15/03/2010   JTS                5. 0013477 ENSA101 - Nueva pantalla de Gestión Pagos Rentas
******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

/*F_get_ProdRentas
Nueva función de la capa IAX que devolverá los productos parametrizados con prestación rentas

Parámetros

1. pcempres IN NUMBER
2. pcramo IN NUMBER
3. psproduc IN NUMBER
4. mensajes OUT T_IAX_MENSAJES

*/
   FUNCTION f_get_prodrentas(
      pcempres IN NUMBER,
      pcramo IN NUMBER,
      psproduc IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

/*
F_SetObjetoProdRenta:
Nueva función de la capa IAX que se encargará de insertar los productos seleccionados de los que se quiere generar pagos renta.

1. psproduc IN NUMBER
2. pcselecc IN NUMBER
3. mensajes OUT T_IAX_MENSAJES

*/
   FUNCTION f_setobjetoprodrenta(
      psproduc IN NUMBER,
      pcselecc IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

/*_set_Rentas
Nueva función de la capa IAX que se encargará de generar los pagos renta.

1. pempresa IN NUMBER
2. pfecha IN DATE
3. pctipo IN NUMBER
4. mensajes OUT T_IAX_MENSAJES

*/
   FUNCTION f_set_rentas(
      pcempres IN NUMBER,
      pfecha IN DATE,
      pctipo IN NUMBER,
      psproces IN NUMBER,   --Bug.: 12914 - ICV - 03/05/2010
      nommap1 OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

    /*************************************************************************
     Nueva función que seleccionará información sobre los pagos renta dependiendo de los parámetros de entrada.
     param in pcempres  :Codigo de empresa
     param in pcramo    :Codigo de ramo
     param in psproduc  :Codigo de producto
     param in pnpoliza  :Codigo de poliza
     param in pncertif  :Codigo de certificado
     param out    mensajes OUT T_IAX_MENSAJES
     Retorno Sys_Refcursor

     Bug 11392  11/02/2010  AMC
   *************************************************************************/
   FUNCTION f_get_consultapagos(
      pcempres IN NUMBER,
      pcramo IN NUMBER,
      psproduc IN NUMBER,
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
     función que recuperará la edad de un asegurado.

     param in  psseguro IN Codigo del seguro
     param in  pnriesgo IN Codigo del riesgo
     param in  pedadaseg OUT Edad del asegurado
     param out mensajes OUT T_IAX_MENSAJES

     Retorno :  0 --> Ok
                1 --> Error

     Bug 11392  11/02/2010  AMC
    *************************************************************************/
   FUNCTION f_edadaseg(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pedadaseg OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
    función que recuperará los datos de renta de una póliza.

    param in  psseguro IN Codigo del seguro
    param out mensajes OUT T_IAX_MENSAJES

    Retorno :  sys_refcursor

    Bug 11392  11/02/2010  AMC
   *************************************************************************/
   FUNCTION f_get_dat_renta(psseguro IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
    función que recuperará los pagos renta de una póliza.

    param in  psseguro IN Codigo del seguro
    param out mensajes OUT T_IAX_MENSAJES

    Retorno :  sys_refcursor

    Bug 11392  11/02/2010  AMC
   *************************************************************************/
   FUNCTION f_get_pagos_renta(psseguro IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
    función que recuperará el detalle del pago renta de una póliza.

    param in  psseguro IN Codigo del seguro
    param in  psrecren IN
    param out mensajes OUT T_IAX_MENSAJES

    Retorno :  sys_refcursor

    Bug 11392  11/02/2010  AMC
   *************************************************************************/
   FUNCTION f_get_detpago_renta(
      psseguro IN NUMBER,
      psrecren IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
    función que recuperará los datos de renta de un pago renta

    param in  psrecren IN
    param out mensajes OUT T_IAX_MENSAJES

    Retorno :  sys_refcursor

    Bug 11392  11/02/2010  AMC
   *************************************************************************/
   FUNCTION f_get_dat_polren(psrecren IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
    función que recuperará los movimientos del recibo de un pago renta.

    param in  psrecren IN
    param out mensajes OUT T_IAX_MENSAJES

    Retorno :  sys_refcursor

    Bug 11392  11/02/2010  AMC
   *************************************************************************/
   FUNCTION f_get_mov_recren(psrecren IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
    Funció F_CALC_RENTAS

    param in psrecren
    param in psseguro
    param in pctipcalc
    param in pctipban
    param out mensajes OUT T_IAX_MENSAJES
    Retorno :  number

    --BUG 13477 - JTS - 15/03/2010
   *************************************************************************/
   FUNCTION f_calc_rentas(
      psrecren IN NUMBER,
      psseguro IN NUMBER,
      pctipcalc IN NUMBER,
      pctipban IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
    Funció F_ACT_PAGO

    param in psrecren
    param in pibase
    param in ppretenc
    param in pisinret
    param in piretenc
    param in piconret
    param in pctipban
    param in pnctacor
    param out mensajes OUT T_IAX_MENSAJES
    Retorno :  number

    --BUG 13477 - JTS - 15/03/2010
   *************************************************************************/
   FUNCTION f_act_pago(
      psrecren IN NUMBER,
      pibase IN NUMBER,
      ppretenc IN NUMBER,
      pisinret IN NUMBER,
      piretenc IN NUMBER,
      piconret IN NUMBER,
      pctipban IN NUMBER,
      pnctacor IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
    Funció f_get_consultapagosrenta

    param in pcempres
    param in psproduc
    param in pnpoliza
    param in pncertif
    param in pcestado
    param out otpagorenta
    param out mensajes OUT T_IAX_MENSAJES
    Retorno :  number

    --BUG 13477 - JTS - 15/03/2010
   *************************************************************************/
   FUNCTION f_get_consultapagosrenta(
      pcempres IN NUMBER,
      psproduc IN NUMBER,
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      pcestado IN NUMBER,
      otpagorenta OUT t_iax_pagorenta,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
    Funció f_get_cab_renta

    param in psrecren
    param out oocabrenta
    param out mensajes OUT T_IAX_MENSAJES
    Retorno :  number

    --BUG 13477 - JTS - 15/03/2010
   *************************************************************************/
   FUNCTION f_get_cab_renta(
      psrecren IN NUMBER,
      oocabrenta OUT ob_iax_cabrenta,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
    Funció f_get_pagorenta

    param in psrecren
    param out oopagorenta
    param out mensajes OUT T_IAX_MENSAJES
    Retorno :  number

    --BUG 13477 - JTS - 15/03/2010
   *************************************************************************/
   FUNCTION f_get_pagorenta(
      psrecren IN NUMBER,
      oopagorenta OUT ob_iax_pagorenta,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
    Funció f_act_pagorenta

    param in psrecren
    param in pctipban
    param in pcuenta
    param in pbase
    param in pporcentaje
    param in pbruto
    param in pretencion
    param in pneto
    param in pestpag
    param in pfechamov
    param out mensajes OUT T_IAX_MENSAJES
    Retorno :  number

    --BUG 13477 - JTS - 15/03/2010
   *************************************************************************/
   FUNCTION f_act_pagorenta(
      psrecren IN NUMBER,
      pctipban IN NUMBER,
      pcuenta IN VARCHAR2,
      pbase IN NUMBER,
      pporcentaje IN NUMBER,
      pbruto IN NUMBER,
      pretencion IN NUMBER,
      pneto IN NUMBER,
      pestpag IN NUMBER,
      pfechamov IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
    Funció f_bloq_proxpagos

    param in psseguro
    param out mensajes OUT T_IAX_MENSAJES
    Retorno :  number

    --BUG 13477 - JTS - 15/03/2010
   *************************************************************************/
   FUNCTION f_bloq_proxpagos(psseguro IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
    Funció f_bloq_proxpagos

    param pfecha -- Fecha en que se ha informado la muerte
    param in psseguro -- Clave del Seguro
    param in psrecren --Por si se quiere precisar a un recibo
    param out mensajes OUT T_IAX_MENSAJES
    Retorno :  number

    --BUG 13477 - JTS - 15/03/2010
   *************************************************************************/
   FUNCTION f_anula_rec(
      pfecha IN DATE,   -- Fecha en que se ha informado la muerte
      pseguro IN NUMBER,   -- Clave del Seguro
      psrecren IN NUMBER DEFAULT NULL,   --Por si se quiere precisar a un recibo
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
    Funció f_actualiza_tipocalcul

    param in psseguro
    param in ptipocalcul
    param out mensajes OUT T_IAX_MENSAJES
    Retorno :  number

   *************************************************************************/
   FUNCTION f_actualiza_tipocalcul(
      psseguro IN NUMBER,
      ptipocalcul IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;
END pac_iax_rentas;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_RENTAS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_RENTAS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_RENTAS" TO "PROGRAMADORESCSI";
