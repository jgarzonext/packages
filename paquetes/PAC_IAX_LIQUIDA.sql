--------------------------------------------------------
--  DDL for Package PAC_IAX_LIQUIDA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_IAX_LIQUIDA" AS
/******************************************************************************
   NOMBRE:       PAC_IAX_LIQUIDA
   PROPÓSITO:    Contiene las funciones para la liquidación de comisiones

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        26/05/2009   JRB                1. Creación del package.
   2.0        03/05/2010   JTS                2. 0014301: APR707 - conceptos fiscales o no fiscales
   3.0        05/05/2010   MCA                3. 0014344: Incorporar a transferencias los pagos de liquidación de comisiones
   4.0        14/07/2011   ICV                4. 0018843: LCOL003 - Liquidación de comisiones
   5.0        22/09/2011   JMP                5. 0019197: LCOL_A001-Liquidacion de comisiones para colombia: sucursal/ADN y corte de cuentas (por el liquido)
   6.0        15/11/2011   JMF                6. 0020164: LCOL_A001-Liquidar solo a los agentes de tipo liquidacion por corte de cuenta o por el total
******************************************************************************/
   vselrecliq     t_iax_selrecliq;

/*************************************************************************/

   /*************************************************************************
       Función que seleccionará los recibos que se tienen que liquidar
       param in  P_cempres   : Empresa
       param in  P_sproduc   : Producto
       param in  P_npoliza   : Póliza
       param in  P_cagente   : Agente
       param in  P_femiini   : Fecha inicio emisión
       param in  P_femifin   : Fecha fin emisión
       param in  P_fefeini   : Fecha inicio efecto
       param in  P_fefefin   : Fecha fin efecto
       param in  P_fcobini   : Fecha inicio cobro
       param in  P_fcobfin   : Fecha fin cobro
       param out mensajes    : Mensajes de error
       return                : Objeto recibos
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
      mensajes OUT t_iax_mensajes)
      RETURN t_iax_recibos;

   /*************************************************************************
      Función que se encargará de cargar los parámetros de entrada en la colección.
      param in  P_nrecibo   : Nº de recibo devuelto
      param in  P_smovrec   : Identificador del movimiento del recibo
      param in  P_liqselec  : Indica si el recibo es seleccionado
      param out mensajes    : Mensajes de error
      return                : 0.-    OK
                              1.-    KO
   *************************************************************************/
   FUNCTION f_setobjetorecliqui(
      p_nrecibo IN NUMBER,
      p_smovrec IN NUMBER,
      p_liqselec IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
       Función que insertará los recibos que forman la liquidación
       param out mensajes    : mensajes de error
       return                : 0.-    OK
                               1.-    KO
   *************************************************************************/
   FUNCTION f_set_recliqui(mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
        Función que devuelve el objeto persistente
        param out mensajes    : mensajes de error
        return                : t_iax_selrecliq
     *************************************************************************/
   FUNCTION f_get_recliqui(mensajes OUT t_iax_mensajes)
      RETURN t_iax_selrecliq;

    /*************************************************************************
      Función que se encargará de inicializar el objeto persistente.
      param in  p_recibos   : Objeto recibos
      param out mensajes    : Mensajes de error
   *************************************************************************/
   FUNCTION f_liquida(p_recibos IN t_iax_recibos, mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

    /*************************************************************************
      Procedimiento que se automatiza la liquidación de recibos.
   *************************************************************************/
   PROCEDURE p_liquida_mens;

   /*************************************************************************
        Función que calcula el saldo de la cuenta corriente de un agente
        param in  pcempres    : código empresa
        param in  pcagente    : código de agente
        param out psaldo      : importe que representa el saldo
        param out mensajes    : mensajes de error
        return                : 0.-    OK
                                1.-    KO
     *************************************************************************/
   FUNCTION f_get_saldoagente(
      pcempres IN NUMBER,
      pcagente IN NUMBER,
      psaldo OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
        Función que devuelve las cuentas técnicas de un agente
        param in  pcagente    : código de agente
        param out pcurcuentastec      : cursor con las cuentas técnicas de un agente
        param out mensajes    : mensajes de error
        return                : 0.-    OK
                                1.-    KO
     *************************************************************************/
   FUNCTION f_get_ctas(
      pcagente IN NUMBER,
      pcurcuentastec OUT sys_refcursor,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
       Función que elimina una cuenta técnica de un agente
       param in  pcempres    : código empresa
       param in  pcagente    : código de agente
       param in  pnnumlin    : numero linea
       param out mensajes    : mensajes de error
       return                : 0.-    OK
                               1.-    KO
    *************************************************************************/
   FUNCTION f_del_ctas(
      pcempres IN NUMBER,
      pcagente IN NUMBER,
      pnnumlin IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
       Función que devuelve el detalle de una cuenta técnica de un agente
       param in  pcempres    : código empresa
       param in  pcagente    : código de agente
       param in  pnnumlin    : numero linea
       param out pcurdetcuent      : cursor con las cuentas técnicas de un agente
       param out mensajes    : mensajes de error
       return                : 0.-    OK
                               1.-    KO
    *************************************************************************/
   FUNCTION f_get_datos_cta(
      pcempres IN NUMBER,
      pcagente IN NUMBER,
      pnnumlin IN NUMBER,
      pcurdetcuent OUT sys_refcursor,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
       Función que insertará o modificará una cuenta técnica de un agente en función del pmodo
       param in  pcempres    : código empresa
       param in  pcagente    : código de agente
       param in  pnnumlin    : numero linea
       param in pCDEBHAB    : Codigo debe o haber ctactes
       param in pimporte     : Importe
       param in pndocume     : numero documento
       param in ptdescrip    : Texto
       param in pmodo        :
       param in pnrecibo     : num. recibos
       param in pnsinies     : num. siniestro
       param in pcconcepto   : codigo concepto cta. corriente
       param in pffecmov
       param out mensajes    : mensajes de error
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
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /******************************************************************
      Función que nos devuelve el sseguro pasandole el npoliza y ncertificado
        param in pnpoliza: num poliza
        param in pncertif: num certif
        param in PTABLAS : taula 'SOL','EST'...
        param out psseguro: sseguro
        param out mensajes
        param psucursal   : codigo de sucursal
        param psucadn     : codigo de ADN
        RETURN               : 0-ok : 1-error
    /*****************************************************************/
   FUNCTION f_get_sseguro(
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      ptablas IN VARCHAR2,
      psseguro OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /******************************************************************
      Función f_liquidaliq
      pcagente IN NUMBER,
      pcempres IN NUMBER,
      pmodo IN NUMBER,
      pfecliq IN DATE,   --Bug.: 18843 - 14/07/2011 - ICV
      psproces IN NUMBER,
      pruta OUT VARCHAR2,
      psucursal IN NUMBER,   -- BUG 19197 - 22/09/2011 - JMP
      padnsuc IN NUMBER,   -- BUG 19197 - 22/09/2011 - JMP
      pcliquido IN NUMBER   -- BUG 0020164 - 15/11/2011 - JMF
      mensajes OUT t_iax_mensajes)
      RETURN
    /*****************************************************************/
   FUNCTION f_liquidaliq(
      pcagente IN NUMBER,
      pcempres IN NUMBER,
      pmodo IN NUMBER,
      pfecliq IN DATE,
      psproces IN NUMBER,
      pruta OUT VARCHAR2,
      psucursal IN NUMBER,
      padnsuc IN NUMBER,
      pcliquido IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /******************************************************************
      Función que recuperará el mes de lcartera anterior de la empresa recibida por parámetro
        param in pcempres: codi empresa
        param out mensajes
        RETURN               : 0-ok : 1-error
    /*****************************************************************/
   FUNCTION f_get_mescarant(pcempres IN NUMBER, pmes OUT NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /******************************************************************
      Función que recuperará el año de lcartera anterior de la empresa recibida por parámetro
        param in pcempres: codi empresa
        param out mensajes
        RETURN               : 0-ok : 1-error
    /*****************************************************************/
   FUNCTION f_get_anyocarant(pcempres IN NUMBER, panyo OUT NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
       Función que devuelve la query a ejecutar para saber el dia inicio de liquidacion

       pctipo IN NUMBER
       RETURN VARCHAR2
   *************************************************************************/
   FUNCTION f_get_feciniliq(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
       Función que devuelve la query que devuelve los procesos de cierre
       0:MODO REAL 1:MODO PREVIO
       pctipo IN NUMBER
       RETURN VARCHAR2
   *************************************************************************/
   FUNCTION f_get_proc_cierres_liq(
      pmodo IN NUMBER,
      pfecliq IN DATE,
      pcempres IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;
END pac_iax_liquida;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_LIQUIDA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_LIQUIDA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_LIQUIDA" TO "PROGRAMADORESCSI";
