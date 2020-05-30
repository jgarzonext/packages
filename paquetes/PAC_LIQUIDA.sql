--------------------------------------------------------
--  DDL for Package PAC_LIQUIDA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_LIQUIDA" IS
/******************************************************************************
   NOMBRE:      PAC_LIQUIDA
   PROPÓSITO:   Nuevo paquete de la capa lógica que tendrá las funciones para
                la liquidación de comisiones.

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        02/06/2009   JRB               1. Creación del package.
   2.0        28/12/2009   SVJ/MCA           2. Modificación del package para incluir nuevas módulo
   4.0        03/05/2010   JTS               4. 0014301: APR707 - conceptos fiscales o no fiscales
   5.0        05/05/2010   MCA               5. 0014344: Incorporar a transferencias los pagos de liquidación de comisiones
   6.0        27/07/2012   JGR               6. 0022753: MDP_A001-Cierre de remesa
   7.0        26/09/2012   JGR               7. 0022346: LCOL_A003-Cobro parcial de los recibos Fase 2
   8.0        20/11/2012   JGR               8. 0024803: (POSDE100)-Desarrollo-GAPS Administracion-Id 61 - Facturas intermediario
   9.0        26/11/2013   FAL               9. 0029023: AGM800 - Agrupación de pago al grupo coordinación

******************************************************************************/

   -- BUG - 0035181 - 200356 - 20/03/2015 - JMF - Contabilidad
   -- Averiguar si un recibo es autoliquidado (0-No, 1-Si)
   -- Se utiliza en selects de contabilidad DETMODCONTA_DIA
   FUNCTION f_esautoliquidado(p_rec IN NUMBER,  p_smovrec IN NUMBER)
      RETURN NUMBER;

   /***********************************************************************
   FUNCTION f_ccobban_autoliquida
   Devuelve código cobrador bancario de autoliquidaciones
   param in p_rec: recibo
   param in p_mov: smovrec del recibo
   return:         ccobban
   -- JMF  bug 0035609/0206695 10/06/2015
   ***********************************************************************/
   FUNCTION f_ccobban_autoliquida(p_rec IN NUMBER, p_mov IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
          Función que seleccionará los recibos que se tienen que liquidar
          param in p_cempres   : código de la empresa
          param in p_sproduc   : Producto
          param in p_npoliza   : Póliza
          param in p_cagente   : Agente
          param in p_femiini   : Fecha inicio emisión.
          param in p_femifin   : Fecha fin emisión.
          param in p_fefeini   : Fecha inicio efecto
          param in p_fefefin   : Fecha fin efecto
          param in p_fcobini   : Fecha inicio cobro
          param in p_fcobfin   : Fecha fin cobro.
          param in p_idioma    : Idioma
          return out psquery   : varchar2
   *************************************************************************/
   FUNCTION f_consultarecibos(
      p_cempres IN NUMBER,
      p_sproduc IN NUMBER,
      p_npoliza IN NUMBER,
      p_cagente IN NUMBER,
      p_femiini IN DATE,
      p_femifin IN DATE,
      p_fefeini IN DATE,
      p_fefefin IN DATE,
      p_fcobini IN DATE,
      p_fcobfin IN DATE,
      p_idioma IN NUMBER)
      RETURN CLOB;

   FUNCTION f_get_recibos_liq(
      p_cempres IN NUMBER,
      p_cagente IN NUMBER,
      p_fecini IN DATE,
      p_fecfin IN DATE)
      RETURN CLOB;

/*************************************************************************
          Función que insertará los recibos que forman la liquidación
          param in p_nrecibo   : Código recibo
          param in p_smovrec   : Movimiento recibo
          param in p_sproliq   : Código ID del proceso de liquidación asociado
          return 0 o error
   *************************************************************************/
   FUNCTION f_set_recliqui(
      p_nrecibo IN NUMBER,
      p_smovrec IN NUMBER,
      p_cgescob IN NUMBER,
      p_icomisi IN NUMBER,
      p_itotimp IN NUMBER,
      p_itotalr IN NUMBER,
      p_iprinet IN NUMBER,
      p_cestrec IN NUMBER,
      p_sproliq IN NUMBER,
      p_cestado IN NUMBER,
      pmodo IN NUMBER)
      RETURN NUMBER;

/*************************************************************************
          Función que retornará el signo a aplicar en función del tipo de recibo y del estado del recibo.
          param in p_nrecibo   : Código recibo
          param in p_smovrec   : Movimiento recibo
          return 1, -1 o error
   *************************************************************************/
   FUNCTION f_get_signo(p_nrecibo IN NUMBER, p_smovrec IN NUMBER, pmodo IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
       Función que calcula el saldo de la cuenta corriente de un agente
       param in  pcempres    : código empresa
       param in  pcagente    : código de agente
       param out psaldo      : importe que representa el saldo
       return                : 0.-    OK
                               1.-    KO
    *************************************************************************/
   FUNCTION f_get_saldoagente(pcempres IN NUMBER, pcagente IN NUMBER, psaldo OUT NUMBER)
      RETURN NUMBER;

   /*************************************************************************
        Función que devuelve las cuentas técnicas de un agente
        param in  pcagente    : código de agente
        param out psquery      : cursor con las cuentas técnicas de un agente
        return                : 0.-    OK
                                1.-    KO
     *************************************************************************/
   FUNCTION f_get_ctas(pcagente IN NUMBER, pcidioma IN NUMBER, psquery OUT VARCHAR2)
      RETURN NUMBER;

   /*************************************************************************
       Función que elimina una cuenta técnica de un agente
       param in  pcempres    : código empresa
       param in  pcagente    : código de agente
       param in  pnnumlin    : numero linea
       return                : 0.-    OK
                               1.-    KO
    *************************************************************************/
   FUNCTION f_del_ctas(pcempres IN NUMBER, pcagente IN NUMBER, pnnumlin IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
       Función que devuelve el detalle de una cuenta técnica de un agente
       param in  pcempres    : código empresa
       param in  pcagente    : código de agente
       param in  pnnumlin    : numero linea
       param out psquery      : cursor con las cuentas técnicas de un agente
       return                : 0.-    OK
                               1.-    KO
    *************************************************************************/
   FUNCTION f_get_datos_cta(
      pcempres IN NUMBER,
      pcagente IN NUMBER,
      pnnumlin IN NUMBER,
      pcidioma IN NUMBER,
      psquery OUT VARCHAR2)
      RETURN NUMBER;

   /*************************************************************************
*************************************************************************/
   FUNCTION f_calc_formula_agente(
      pcagente IN NUMBER,
      pclave IN NUMBER,
      pfecefe IN DATE,
      presultado OUT NUMBER,
      psproduc IN NUMBER DEFAULT 0)
      RETURN NUMBER;

   /*************************************************************************
       Función que insertará o modificará una cuenta técnica de un agente en función del pmodo
       param in  pcempres    : código empresa
       param in  pcagente    : código de agente
       param in  pnnumlin    : numero linea
       param in pcdebhab    : Codigo debe o haber
       param in pimporte     : Importe
       param in pndocume     : numero documento
       param in ptdescrip    : Texto
       param in pmodo        :
       param in pnrecibo     : num. recibos
       param in pnsinies     : num. siniestro
       param in pcconcepto   : codigo concepto cta. corriente
       param in pffecmov
       return                : 0.-    OK
                               1.-    KO
    *************************************************************************/
   FUNCTION f_set_cta(
      pcempres IN NUMBER,
      pcagente IN NUMBER,
      psseguro IN NUMBER,
      pnnumlin IN NUMBER,
      pcdebhab IN NUMBER,
      pimporte IN NUMBER,
      pndocume IN VARCHAR2,
      ptdescrip IN VARCHAR2,
      pmodo IN NUMBER,
      pnrecibo IN NUMBER,
      pnsinies IN NUMBER,
      pcconcepto IN NUMBER,
      pffecmov IN DATE,
      pfvalor IN DATE,
      pcfiscal IN NUMBER,
      psproduc IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

   /*************************************************************************
       Proceso que lanzará todos los procesos de cierres
       param in  pmodo
       param in  pcempres
       param in  pmoneda
       param in pcidioma
       param in pfperfin
       param in pfcierre
       param in ptdescrip
       param in pcerror
       param in psproces
       param in pfproces
    *************************************************************************/
   FUNCTION f_liquidaliq_age(
      pcagente IN NUMBER,
      pcempres IN NUMBER,
      pmodo IN NUMBER,   -- 0:MODO REAL 1:MODO PREVIO
      pfecliq IN DATE,
      pcidioma IN NUMBER,
      pcagentevision IN NUMBER,
      psproces IN OUT NUMBER,
      psmovagr IN NUMBER DEFAULT NULL,   -- 6. 0022753
      pnrecibo IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

   /*************************************************************************
       Función que devuelve el detalle de una cuenta técnica de un agente
       pcagente IN NUMBER,
      pcempres IN NUMBER,
      psproces IN NUMBER,
      pcidioma IN NUMBER,
      pfmovimi IN DATE,
      pmodo IN NUMBER,
       return                : 0.-    OK
                               1.-    KO
    *************************************************************************/
   FUNCTION f_set_resumen_ctactes(
      pcagente IN NUMBER,
      pcempres IN NUMBER,
      psproces IN NUMBER,
      pcidioma IN NUMBER,
      pfecliq IN DATE,
      pnliqmen IN NUMBER,
      pmodo IN NUMBER,
      pcagentevision IN NUMBER,
      psmovagr IN NUMBER DEFAULT NULL   -- 6. 0022753
                                     )
      RETURN NUMBER;

   /*************************************************************************
       Función que comprueba si a una fecha se puede realizar el cierre de comisiones.
               0 si todo va bien, y si no el número de error
      pfcierre IN DATE
      pcempres IN NUMBER,
      pmodo IN NUMBER,
       return                : 0.-    OK
                               NUM_ERR .-    KO
    *************************************************************************/
   FUNCTION f_validacion_cierre(pfcierre IN DATE, pcempres IN NUMBER)
      RETURN NUMBER;

-------------------------------------------------------------------
--
-- Proceso de cierre de liquidaciones
-------------------------------------------------------------------
-------------------------------------------------------------------
   PROCEDURE proceso_batch_cierre(
      pmodo IN NUMBER,   -- 0:MODO REAL 1:MODO PREVIO
      pcempres IN NUMBER,
      pmoneda IN NUMBER,
      pcidioma IN NUMBER,
      pfperini IN DATE,
      pfperfin IN DATE,
      pfcierre IN DATE,
      pcerror OUT NUMBER,
      psproces OUT NUMBER,
      pfproces OUT DATE);

   /*************************************************************************
       Procedimiento que actualiza con el sproces correspondiente al de la liquidación los apuntes
       manuales que estén incluidos en la liquidación.

      pagente IN NUMBER
      pcempres IN NUMBER
      psproces IN NUMBER
      pfecha IN DATE
   *************************************************************************/
   PROCEDURE p_apuntes_manuales(
      pagente IN NUMBER,
      pcempres IN NUMBER,
      psproces IN NUMBER,
      pfecliq IN DATE);

   /*************************************************************************
       Función que devuelve la query a ejecutar para saber el dia inicio de liquidacion

       pctipo IN NUMBER
       RETURN VARCHAR2
   *************************************************************************/
   FUNCTION f_get_feciniliq(pctipo IN NUMBER)
      RETURN VARCHAR2;

   /*************************************************************************
       Función que devuelve la query que devuelve los procesos de cierre
       0:MODO REAL 1:MODO PREVIO
       pctipo IN NUMBER
       RETURN VARCHAR2
   *************************************************************************/
   FUNCTION f_get_proc_cierres_liq(pmodo IN NUMBER, pfecliq IN DATE, pcempres IN NUMBER)
      RETURN VARCHAR2;

   /*************************************************************************
       Función que inserta el proceso de cierre

       RETURN NUMBER
   *************************************************************************/
   FUNCTION f_set_cierre_liq(
      pfperini IN DATE,
      pfperfin IN DATE,
      pfcierre IN DATE,
      pcempres IN NUMBER,
      pctipo IN NUMBER,
      pcestado IN NUMBER,
      psproces IN NUMBER,
      pfproces IN DATE)
      RETURN NUMBER;

   /*************************************************************************
       Función que elimina datos del previo

       RETURN NUMBER
   *************************************************************************/
   FUNCTION f_del_liq_previo(psproces IN NUMBER)
      RETURN NUMBER;

/*************************************************************************
       Función para insertar la cabecera de la liquidación
       RETURN NUMBER
   *************************************************************************/
   FUNCTION f_set_cabeceraliq(
      pcagente IN NUMBER,
      pnliqmen IN NUMBER,
      pfliquid IN DATE,
      pfmovimi IN DATE,
      pfcontab IN DATE,
      pcempres IN NUMBER,
      psproliq IN NUMBER,
      pntalon IN NUMBER,
      pcctatalon IN VARCHAR,
      pfingtalon DATE,
      pctipoliq IN NUMBER,
      pcestado IN NUMBER,
      pfcobro IN DATE,
      pctotalliq IN NUMBER)
      RETURN NUMBER;

   -- 7. 0022346: LCOL_A003-Cobro parcial de los recibos Fase 2 - Inicio
   /*******************************************************************************
   FUNCION PAC_LIQUIDA.F_SET_RECIBOS_PARCIAL_LIQ
   Inserta los recibos con pagos parciales pendientes de liquidar

   Parámetros:
      param in pcempres   : código de la empresa
      param in pcagente   : Agente
      param in pfecliq    : Fecha lquidación (hasta la que incluyen movimientos)
      param in psproces   : Código de todo el proceso de liquidación para todos los agentes
      param in pmodo      : Pmodo = 0 Real y 1 Previo
      param in psmovagr   : Secuencial de agrupación de recibos (movrecibo.smovagr)

      return: number un número con el id del error, en caso de que todo vaya OK, retornará un cero.
   ********************************************************************************/
   FUNCTION f_set_recibos_parcial_liq(
      pcempres IN NUMBER,
      pcagente IN NUMBER,
      pfecliq IN DATE,
      psproces IN NUMBER,
      pmodo IN NUMBER,
      pnliqmen OUT NUMBER,
      psmovagr IN NUMBER DEFAULT NULL,
      pnrecibo IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

   /*******************************************************************************
   FUNCION PAC_LIQUIDA.F_SET_RECIBOS_PARCIAL_LIQ_IND
   Inserta las comisiones indirectas de los recibos con pagos parciales pendientes
   de liquidar en las tablas de liquidaciones

   Parámetros:
      param in pcempres   : código de la empresa
      param in pcagente   : Agente
      param in pfecliq    : Fecha liquidación (hasta la que incluyen movimientos)
      param in pcageind   : Agente indirecto
      param in psproces   : Código de todo el proceso de liquidación para todos los agentes
      param in pmodo      : Pmodo = 0 Real y 1 Previo
      param in psmovagr   : Secuencial de agrupación de recibos (movrecibo.smovagr)

      return: number un número con el id del error, en caso de que todo vaya OK, retornará un cero.
   ********************************************************************************/
   FUNCTION f_set_recibos_parcial_liq_ind(
      pcempres IN NUMBER,
      pcagente IN NUMBER,
      pfecliq IN DATE,
      pcageind IN NUMBER,
      psproces IN NUMBER,
      pmodo IN NUMBER,
      pnliqmen OUT NUMBER,
      psmovagr IN NUMBER DEFAULT NULL,
      pnrecibo IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

-- 7. 0022346: LCOL_A003-Cobro parcial de los recibos Fase 2 - Fin

   -- BUG 29023 - FAL - 26/11/2013
   FUNCTION f_agrupa_pagocomisi_directas(pcempres IN NUMBER, vsproliq IN NUMBER)
      RETURN NUMBER;

-- FI BUG 29023 - FAL - 26/11/2013
   FUNCTION f_crea_conceptos_impuestos(
      pmodo IN NUMBER,
      pcagente IN ctactes.cagente%TYPE,
      pnnumlin IN ctactes.nnumlin%TYPE,
      pcdebhab IN ctactes.cdebhab%TYPE,
      pcconcta IN ctactes.cconcta%TYPE,
      pcestado IN ctactes.cestado%TYPE,
      pndocume IN ctactes.ndocume%TYPE,
      pffecmov IN ctactes.ffecmov%TYPE,
      piimport IN ctactes.iimport%TYPE,
      ptdescrip IN ctactes.tdescrip%TYPE,
      pcmanual IN ctactes.cmanual%TYPE,
      pcempres IN ctactes.cempres%TYPE,
      pnrecibo IN ctactes.nrecibo%TYPE,
      pnsinies IN ctactes.nsinies%TYPE,
      psseguro IN ctactes.sseguro%TYPE,
      pfvalor IN ctactes.fvalor%TYPE,
      psproces IN ctactes.sproces%TYPE,
      pcfiscal IN ctactes.cfiscal%TYPE,
      psproduc IN ctactes.sproduc%TYPE,
      pccompani IN ctactes.ccompani%TYPE   -- Bug 26964/146968 - 19/06/2013 - AMC
                                        )
      RETURN NUMBER;

   FUNCTION f_insert_cta(
      pmodo IN NUMBER,   -- 1 previo, 2 liquidación
      pcagente IN ctactes.cagente%TYPE,
      pnnumlin IN ctactes.nnumlin%TYPE,
      pcdebhab IN ctactes.cdebhab%TYPE,
      pcconcta IN ctactes.cconcta%TYPE,
      pcestado IN ctactes.cestado%TYPE,
      pndocume IN ctactes.ndocume%TYPE,
      pffecmov IN ctactes.ffecmov%TYPE,
      piimport IN ctactes.iimport%TYPE,
      ptdescrip IN ctactes.tdescrip%TYPE,
      pcmanual IN ctactes.cmanual%TYPE,
      pcempres IN ctactes.cempres%TYPE,
      pnrecibo IN ctactes.nrecibo%TYPE,
      pnsinies IN ctactes.nsinies%TYPE,
      psseguro IN ctactes.sseguro%TYPE,
      pfvalor IN ctactes.fvalor%TYPE,
      psproces IN ctactes.sproces%TYPE,
      pcfiscal IN ctactes.cfiscal%TYPE,
      pnnumlin_depen IN ctactes.nnumlin_depen%TYPE,
      psproduc IN ctactes.sproduc%TYPE,
      pccompani IN ctactes.ccompani%TYPE   -- Bug 26964/146968 - 19/06/2013 - AMC
                                        )
      RETURN NUMBER;

--MMS 20141006
   FUNCTION f_valor_recaudo(
      pnrecibo IN recibos.nrecibo%TYPE,
      psmovrec IN movrecibo.smovrec%TYPE,
      pimpiprinet OUT NUMBER,
      pimpiprinet_monpol OUT NUMBER,
      pimpicomisi OUT NUMBER,
      pimpicomisi_monpol OUT NUMBER,
      pimpicomret OUT NUMBER,
      pimpicomret_monpol OUT NUMBER,
      pimpitotalr OUT NUMBER,
      pimpitotalr_monpol OUT NUMBER,
      pimpitotimp OUT NUMBER,
      pimpitotimp_monpol OUT NUMBER)
      RETURN NUMBER;


   /******************************************************************************
   ******************************************************************************/
   FUNCTION f_validar_ccc_age(pcempres IN NUMBER,
                              psproliq IN NUMBER) RETURN NUMBER;

   FUNCTION f_signo_comision_age(pcempres IN NUMBER,
                                 psproliq IN NUMBER) RETURN NUMBER;

   /***********************************************************************
   FUNCTION f_esautoliqui_conta
   Averiguar si un recibo es autoliquidado (0-No, 1-Si)
   param in p_rec: recibo
   param in p_mov: smovrec del recibo
   return:         0/1
   PRBMANT-27 - MCA - Contabilidad  27/06/2016
   ***********************************************************************/
   FUNCTION f_esautoliq_conta(p_rec IN NUMBER,  p_smovrec IN NUMBER)
      RETURN NUMBER;
   /***********************************************************************
   FUNCTION f_ccobban_autoliquida
   Devuelve código cobrador bancario de autoliquidaciones
   param in p_rec: recibo
   param in p_mov: smovrec del recibo
   return:         ccobban
   PRBMANT-27 - MCA - Contabilidad  27/06/2016
   ***********************************************************************/
   FUNCTION f_ccobban_autoliq_conta(p_rec IN NUMBER, p_mov IN NUMBER)
      RETURN NUMBER;
   /***********************************************************************
   FUNCTION f_rec_agrupador
   Devuelve recibo agrupador, si es agrupado
   param in p_rec: recibo
   return:         nrecunif
   PRBMANT-27 - MCA - Contabilidad  27/06/2016
   ***********************************************************************/
   FUNCTION f_rec_agrupador(p_rec IN NUMBER)
      RETURN NUMBER;

   /***********************************************************************
   FUNCTION f_mov_agrupador
   Devuelve movimiento del recibo agrupador, si es agrupado
   param in p_rec: recibo
   return:         smovrec
   PRBMANT-27 - MCA - Contabilidad  27/06/2016
   ***********************************************************************/
   FUNCTION f_mov_agrupador(p_rec IN NUMBER, p_mov IN NUMBER)
      RETURN NUMBER;

	 -------------------------------------------------------------------
      --
      -- Proceso de actualización de IRPF
      -------------------------------------------------------------------
      -------------------------------------------------------------------
   PROCEDURE proceso_update_irpf(
    agente_ins IN NUMBER,
      icomisi IN NUMBER,
      vimpicomret IN OUT NUMBER,
      v_nrecibo IN NUMBER,
      v_nmovimi IN NUMBER,
      cagente IN NUMBER,
      signo   IN NUMBER,
      pcerror OUT NUMBER);

	FUNCTION f_insert_liquidafact_inter(sproces VARCHAR2, cagente NUMBER)
      RETURN NUMBER;

	-------------------------------------------------------------------
	 FUNCTION f_calc_formula_coaseguro(pccompani IN NUMBER,
                                     pclave      IN NUMBER,
                                     pfecefe     IN DATE,
                                     presultado  OUT NUMBER,
                                     psproduc    IN NUMBER DEFAULT 0)
      RETURN NUMBER;

END pac_liquida;

/

  GRANT EXECUTE ON "AXIS"."PAC_LIQUIDA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_LIQUIDA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_LIQUIDA" TO "PROGRAMADORESCSI";
