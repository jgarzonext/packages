CREATE OR REPLACE PACKAGE pac_adm_cobparcial AS
/************************************************************************************************
   NOMBRE:      PAC_ADM_COBPARCIAL
   PROPÓSITO:   Nuevo paquete de la capa lógica que tendrá las funciones la gestiones
                con cobros parciales de recibos.

   REVISIONES:
   Ver  Fecha       Autor    Descripción
   ---  ----------  -------  ----------------------------------------------------------------------
   1.0  26/09/2012  JGR      0022346: LCOL_A003-Cobro parcial de los recibos Fase 2 (creación pack)
   2.0  25/10/2012  JGR      0022346: LCOL_A003-Cobro parcial de los recibos Fase 2 - 0127248
   3.0  08/10/2012  JGR      0022346: LCOL_A003-Cobro parcial de los recibos Fase 2 - 0127366
   4.0  19/10/2012  DCG      0023130: LCOL_F002-Provisiones para polizas estatales
   5.0  04/03/2013  JGR      0026022: LCOL: Liquidaciones de Colectivos - 0139541
   6.0  13/03/2013  AFM      0026301: RSA002 - Carga IPC. Añadir fichero de pagos. Se añade la
                                      función f_carga_pagos_masiva.
   7.0  14/05/2013  DCG      0026959: RSA701-Informar correctamente los importes de los cobros parciales en multimoneda.
   8.0  30/07/2013  DCG      0026959: RSA701-Informar correctamente los importes de los cobros parciales en multimoneda.
                                      Para LCOL se cobra en la moneda contable.
                                      Para RSA se cobra en la moneda del producto.
   9.0  18/10/2013  JGR      0028577: POSND100-Añadir nota en la agenda del recibo en el momento de que SAP nos envie un recaudo.
  10.0  04/02/2015  MDS      0032674: COLM004-Guardar los importes de recaudo a la fecha de recaudo
  11.0  07/06/2019  JLTS     IAXIS.4153: Se incluyen nuevos paráametros pnreccaj y pcmreca a la función f_set_detmovrecibo 
  12.0  18/07/2019  Shakti   IAXIS-4753: Ajuste campos Servicio I003
  13.0  01/08/2019  Shakti   13. IAXIS-4944 TAREAS CAMPOS LISTENER
  14.0  12/09/2019  DFRP     IAXIS-4884: Paquete de integración pagos SAP
  15.0  03/12/2019  DFRP     IAXIS-7640: Ajuste paquete listener para Recaudos SAP
  16.0  06/04/2020  JLTS     IAXIS-7584: Adicion de la función f_get_importe_cobrado ( Para el reporte DetEmisRecibos.jasper)
   ************************************************************************************************/

   /*******************************************************************************
   FUNCION PAC_LIQUIDA.F_GET_IMPORTE_COBRO_PARCIAL
   Inserta las comisiones indirectas de los recibos con pagos parciales pendientes
   de liquidar en las tablas de liquidaciones

   Parámetros:
      param in psmovrec   : Secuencial del movimiento
      param in pnorden    : Número de movimiento

      return: number un número con el id del error, en caso de que todo vaya OK, retornará un cero.
   ********************************************************************************/
   FUNCTION f_get_importe_cobro_parcial(
      pnrecibo IN NUMBER,
      psmovrec IN NUMBER DEFAULT NULL,
      pnorden IN NUMBER DEFAULT NULL,
      pimoncon IN NUMBER DEFAULT NULL)   -- Bug 0026959 - DCG - 30/07/2013
      RETURN NUMBER;

   /*************************************************************************
    FUNCTION f_set_detmovrecibo
      Inserta a la tabla DETMOVRECIBO, para informar los pagos parciales de recibos.

      PARAMETROS:

        PNRECIBO   N NUMBER(9)      Número de recibo.
        PSMOVREC   N NUMBER(8)      Secuencial del movimiento
        PNORDEN    N NUMBER         Número de movimiento --> Solo informar para UPDATE
        PIIMPORTE  N NUMBER(13,2)   Importe Cobrado
        PFMOVIMI   N DATE           Fecha de movimiento
        PFEFEADM   S DATE           Fecha efecto del movimiento a nivel administrativo
        PCUSUARI   N VARCHAR2(34)   Usuario que realiza el movimiento
        PSDEVOLU   N NUMBER (9)     Secuencia de devolucion
        PNNUMNLIN  N NUMBER(10)     Número de línea
        PCBANCAR1  N VARCHAR2(50)   Cuenta destinataria
        PNNUMORD   N NUMBER(10)     Número de orden
        PSMOVRECR  S NUMBER(8)      Secuencial del movimiento Recíproco
        PNORDENR   S NUMBER(2)      Número de movimiento Recíproco
        PTDESCRIP  S VARCHAR2(1000) Descripció de l'apunt del rebut
        PIIMPMON   S NUMBER(13,2)   Importe Cobrado en moneda contable
        PSPROCES   S NUMBER         Número de Proceso
        pimocon    S NUMBER         Si 1 cálculo en moncon

           return             : 0 -> Tot correcte
                                1 -> S'ha produit un error
   *************************************************************************/
   FUNCTION f_set_detmovrecibo(
      pnrecibo IN NUMBER,
      psmovrec IN NUMBER,
      pnorden IN NUMBER,
      piimporte IN NUMBER,
      pfmovimi IN DATE,
      pfefeadm IN DATE,
      pcusuari IN VARCHAR2,
      psdevolu IN NUMBER,
      pnnumnlin IN NUMBER,
      pcbancar1 IN VARCHAR2,
      pnnumord IN NUMBER,
      psmovrecr IN NUMBER DEFAULT NULL,
      pnordenr IN NUMBER DEFAULT NULL,
      ptdescrip IN VARCHAR2 DEFAULT NULL,
      piimpmon IN NUMBER DEFAULT NULL,
      psproces IN NUMBER DEFAULT NULL,   -- Bug 0026959 - DCG - 14/05/2013
      pimoncon IN NUMBER DEFAULT NULL,
      pitasa IN NUMBER DEFAULT NULL,   -- Bug 0026959 - DCG - 30/07/2013
      pfcambio IN DATE DEFAULT NULL,
      --pnreccaj IN NUMBER DEFAULT NULL, -- INI IAXIS-4153 
      pnreccaj IN varchar2 DEFAULT NULL, /*  Cambios de IAXIS-4753 */
      pcmreca IN NUMBER DEFAULT NULL,  -- INI IAXIS-4153 
      pctipotransap IN NUMBER DEFAULT NULL -- IAXIS-4884 12/09/2019
)   -- Bug 0032674 - MDS - 06/02/2015
      RETURN NUMBER;

   /*************************************************************************
    FUNCTION f_anula_rec
      Acciones a realizar para la anulación de los recibos que tienen cobros parciales.

      PARAMETROS:

        PNRECIBO   NUMBER    Número de recibo.
        PFANULAC   DATE      Fecha anulación
        PSMOVAGR   NUMBER    Código de secuencia movimientos de recibos agrupados
        PNO_ANUL   NUMBER    Si es un 1 no se anula la póliza

           return             : 0 -> Tot correcte
                                1 -> S'ha produit un error

   *************************************************************************/
   FUNCTION f_anula_rec(
      pnrecibo IN NUMBER,
      pfanulac IN DATE,
      psmovagr IN OUT NUMBER,
      pno_anul IN NUMBER DEFAULT 0)
      RETURN NUMBER;

   /*******************************************************************************
   FUNCION PAC_ADM_COBPARCIAL.F_COBRO_PARCIAL_RECIBO
   Registra los cobros parciales de los recibos.
   Sí los cobros parciales igualan el total del recibo este se dará por cobrado.
   Sí los cobros parciales superan el total del recibo dará un error.

   Parámetros:
     param in pnrecibo  : Número de recibo
     param in pctipcob  : Tipo de cobro (V.F.: 552)
     param in piparcial : Importe del cobro parcial (*)
     param in pcmoneda  : Código de moneda (inicialmente no se tiene en cuenta)
     param out pigenera : Importe del pago generado finalmente (normalmente coincidirá con el piparcial)
     param out pfcobrado: Fecha que cubriría el periodo cobrado
     param in pnocobrar : Cuando es 0 y se complete el importe total del recibo se cobrará el recibo, 1 NO
     param in piparcialm: Importe del cobro parcial en la moneda contable.
     param in psproces  : Proceso del cobro
     param in pfcobparc : Fecha del cobro parcial (fecha de valor de cambio)

     return: number un número con el id del error, en caso de que todo vaya OK, retornará un cero.

     (*) Si el pago parcial viene a nulo se generará el pago por el resto del importe pendiente de cobro
     Esta funcionalidad se penso para ahorrar pasos en la anulación de los recibo parciales (f_anula_rec).
   ********************************************************************************/
   FUNCTION f_cobro_parcial_recibo(
      --
      -- Inicio IAXIS-7640 03/12/2019
      --
      --pnrecibo IN NUMBER,
      pnrecibo IN VARCHAR2,
      --
      -- Fin IAXIS-7640 03/12/2019
      --
      pctipcob IN NUMBER,
      piparcial IN NUMBER,
      pcmoneda IN NUMBER,
      pigenera OUT NUMBER,
      pfcobrado OUT DATE,
      pnocobrar IN NUMBER DEFAULT 0,   -- 2.0  0022346 - 0127366
      -- Bug 0026959 - DCG - 14/05/2013 - Inici
      psproces IN NUMBER DEFAULT NULL,
      pfcobparc IN DATE DEFAULT NULL,
                                    -- Bug 0026959 - DCG - 14/05/2013 - Fi
      -- 9.0  18/10/2013  JGR      0028577 - Inicio
      pnrecsap IN VARCHAR2 DEFAULT NULL,
      pcususap IN VARCHAR2 DEFAULT NULL, -- 9.0  18/10/2013  JGR      0028577 - Final
      -- INI -IAXIS-4153 - JLTS 07/06/2019 Se adicionan los campos cmreca y nreccaj
      pnreccaj IN VARCHAR2 DEFAULT NULL, /* Cambios de IAXIS-4753 */
      pcmreca  IN NUMBER DEFAULT NULL,
      -- FIN -IAXIS-4153 - JLTS 07/06/2019
      pcindicaf IN VARCHAR2 DEFAULT NULL ,------Changes for 4944
      pcsucursal IN VARCHAR2 DEFAULT NULL ,------Changes for 4944
      pndocsap IN VARCHAR2 DEFAULT NULL, ------Changes for 4944
      pctipotransap IN NUMBER DEFAULT NULL -- IAXIS-4884 12/09/2019
   )
      RETURN NUMBER;

-- Bug 0023130 - DCG - 19/10/2012 - LCOL_F002-Provisiones para polizas estatales
/*******************************************************************************
   FUNCION PAC_LIQUIDA.F_GET_porcentaje_COBRO_PARCIAL
   Devuelve el porcentaje del pago parcial

   Parámetros:
      param in psmovrec   : Secuencial del movimiento
      param in pnorden    : Número de movimiento

      return: number un número con el %, en caso de que no vaya OK, retornará un cero.
   ********************************************************************************/
   FUNCTION f_get_porcentaje_cobro_parcial(
      pnrecibo IN NUMBER,
      psmovrec IN NUMBER DEFAULT NULL,
      pnorden IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

-- Fin Bug 0023130

   /*******************************************************************************
   FUNCION F_CARGA_PAGOS_MASIVA
   Trata los registros que vienen en la carga masiva de pagos. Bug 26301

   Parámetros:
      SPROCES  NUMBER Nro de proceso
      SSEGURO  NUMBER Clave de la póliza
      IMPORTE  NUMBER Importe en moneda de producto.
      CMONPAG  NUMBER Moneda de pago.
      IMPMPAG  NUMBER Importe en moneda de pago.
      ITASA    NUMBER Tasa que se ha aplicado al cambio.
      FMOVTO   NUMBER Fecha del movimiento y cuando se ha aplicado la tasa de cambio.
      CULTPAGO NUMBER Indica si es el último pago de la anualidad. 0-No y 1-Si

      number un número con el id del error, en caso de que todo vaya OK, retornará un cero.
   ********************************************************************************/
   FUNCTION f_carga_pagos_masiva(
      psproces IN NUMBER,
      psperson IN NUMBER,
      psseguro IN NUMBER,
      pimporte IN NUMBER,
      pcmonpag IN NUMBER,
      pimpmpag IN NUMBER,
      pitasa IN NUMBER,
      pfmovto IN DATE,
      pcultpago IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_genera_recibo(
      pcempres IN NUMBER,
      psseguro IN NUMBER,
      pnrecibo IN NUMBER,
      pfefecto IN DATE,
      pfvencim IN DATE,
      pfgracia IN DATE,
      pnmovimi IN NUMBER,
      ptipocert IN VARCHAR2,
      pcmoneda IN NUMBER,
      pnrecibo_out OUT NUMBER,
      pctiprec IN NUMBER,
      pnfactor IN NUMBER,
      pgasexp IN NUMBER,
      psmovagr IN NUMBER DEFAULT 0)
      RETURN NUMBER;

    --INI -IAXIS-7584 -JLTS -06/04/2020
    /******************************************************************************
    NAME:       F_GET_IMPORTE_COBRADO
    PURPOSE:    Seleccionar el valor según concepto y recibo del último movimiento de 
                pago parcial realizado
    BUG:        IAXIS-7584
     PARAMETRES:
       pnrecibo Número de recibo
       pcconcep Concepto
       piconcep concepto en pesos o moneda extrangera (1) ME y (2) COP
    ******************************************************************************/
    FUNCTION f_get_importe_cobrado(pnrecibo recibos.nrecibo%TYPE,
                                   pcconcep detmovrecibo_parcial.cconcep%TYPE,
                                   piconcep NUMBER) RETURN NUMBER;
    --FIN -IAXIS-7584 -JLTS -06/04/2020
END pac_adm_cobparcial;
/
