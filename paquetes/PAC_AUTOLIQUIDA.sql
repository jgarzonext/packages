--------------------------------------------------------
--  DDL for Package PAC_AUTOLIQUIDA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_AUTOLIQUIDA" AS
   /******************************************************************************
      NOMBRE:      PAC_AUTOLIQUIDA
      PROPÓSITO:   Nuevo paquete de la capa lógica que tendrá las funciones para
                   la liquidación de comisiones automáticas.

      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.0        17/03/2015   JRB               1. Creación del package.

   ******************************************************************************/

   /*************************************************************************
     Función que consultará las autoliquidaciones
     param in pnliqmen   : código de la empresa
     param in pcempres   : Producto
     param in pfliquida   : Póliza
     param in piimporte   : Agente
     param in pcagente   : Fecha inicio emisión.
     param in pcusuario   : Fecha fin emisión.
     param in pcestado   : Fecha inicio efecto
     param in pfcobro   : Fecha fin efecto
     return out psquery   : varchar2
   */

   FUNCTION f_get_autoliquidaciones(psproliq  IN NUMBER,
                                    pcempres  IN NUMBER,
                                    pfliquida IN DATE,
                                    piimporte IN NUMBER,
                                    pcagente  IN NUMBER,
                                    pcusuario IN VARCHAR2,
                                    pcestado  IN NUMBER,
                                    pfcobro   IN DATE,
                                    psquery   OUT VARCHAR2) RETURN NUMBER;


   FUNCTION f_get_autoliquidacion(psproliq  IN NUMBER,
                                  pcempres  IN NUMBER,
                                  pcagente  IN NUMBER,
                                  psqrycab  OUT VARCHAR2,
                                  psqrycob  OUT VARCHAR2,
                                  psqryrec  OUT VARCHAR2,
                                  psqryapun OUT VARCHAR2) RETURN NUMBER;


   FUNCTION f_get_autoliquidacab(psproliq IN NUMBER,
                                 pcempres IN NUMBER,
                                 pcagente IN NUMBER,
                                 psqrycab OUT VARCHAR2) RETURN NUMBER;


   FUNCTION f_get_recibos(psproliq IN NUMBER,
                          pcempres IN NUMBER,
                          pcagente IN NUMBER,
                          psqryrec OUT VARCHAR2) RETURN NUMBER;


   FUNCTION f_get_new_recibos(psproliq  IN NUMBER,
                              pcempres  IN NUMBER,
                              pcagente  IN NUMBER,
                              pctomador IN NUMBER,
                              pnrecibo  IN NUMBER,
                              psqryrec  OUT VARCHAR2) RETURN NUMBER;


   FUNCTION f_get_cobros(psproliq IN NUMBER,
                         pcempres IN NUMBER,
                         pcagente IN NUMBER,
                         psqrycob OUT VARCHAR2) RETURN NUMBER;


   FUNCTION f_get_ctas(psproliq  IN NUMBER,
                       pcempres  IN NUMBER,
                       pcagente  IN NUMBER,
                       psqryapun OUT VARCHAR2) RETURN NUMBER;


   FUNCTION f_get_new_ctas(psproliq  IN NUMBER,
                           pcempres  IN NUMBER,
                           pcagente  IN NUMBER,
                           psqryapun OUT VARCHAR2) RETURN NUMBER;


   FUNCTION f_get_autoliquidaage(psproliq   IN NUMBER,
                                 pcempres   IN NUMBER,
                                 pcageclave IN NUMBER) RETURN t_iax_autoliquidaage;


   FUNCTION f_set_autoliquidaage(pcagente     IN NUMBER,
                                 pnliqmen     IN NUMBER,
                                 pcestautoliq IN NUMBER,
                                 piimporte    IN NUMBER,
                                 pcusuari     IN VARCHAR2,
                                 pfcobro      IN DATE,
                                 pcmarcado    IN NUMBER,
                                 pidifglobal  IN NUMBER,
                                 pfliquida    IN DATE,
                                 pcempres     IN NUMBER,
                                 pcageclave   IN NUMBER,
                                 psproliq     IN NUMBER,
                                 opsproliq    OUT NUMBER) RETURN NUMBER;


   FUNCTION f_set_autoliquidacion(pcmodo    IN VARCHAR2,
                                  pnliqmen  IN NUMBER,
                                  pcempres  IN NUMBER,
                                  pcagente  IN NUMBER,
                                  psproces  IN NUMBER,
                                  pocestado OUT NUMBER) RETURN NUMBER;


   FUNCTION f_set_autoliquidacab(pcmodo      IN VARCHAR2,
                                 pnliqmen    IN NUMBER,
                                 pcempres    IN NUMBER,
                                 pcagente    IN NUMBER,
                                 pcestado    IN NUMBER DEFAULT 1,
                                 pfliquida   IN DATE,
                                 pfcobro     IN DATE,
                                 pctomador   IN NUMBER,
                                 pcusuario   IN VARCHAR2,
                                 piimporte   IN NUMBER,
                                 psproliq    IN NUMBER,
                                 pidifglobal IN NUMBER,
                                 pcproces    OUT NUMBER,
                                 ponliqmen   OUT NUMBER,
                                 pcautoli    IN NUMBER DEFAULT 0) RETURN NUMBER;


   FUNCTION f_set_recibos(pcmodo       IN VARCHAR2,
                          pnliqmen     IN NUMBER,
                          pcempres     IN NUMBER,
                          pcagente     IN NUMBER,
                          pnliqlin     IN NUMBER,
                          pnrecibo     IN NUMBER,
                          pctiprec     IN NUMBER,
                          pnfrafec     IN NUMBER,
                          pfefecto     IN DATE,
                          pitotalr     IN NUMBER,
                          picomisi     IN NUMBER,
                          piretencom   IN NUMBER,
                          pidiferencia IN NUMBER,
                          psproces     IN NUMBER,
                          ppl          IN NUMBER,
                          pidiferpyg   IN NUMBER,
						  --AAC_INI-CONF_379-20160927
						  pimppend		IN	NUMBER,
						  pvabono		IN	NUMBER,
						  pfabono		IN	DATE,
						  pdocreau		IN 	NUMBER,
						  pcorteprod	IN	NUMBER
						  --AAC_FI-CONF_379-20160927
						  ) RETURN NUMBER;


   FUNCTION f_set_cobros(pidcobro IN NUMBER,
                         pcagente IN NUMBER,
                         pcempres IN NUMBER,
                         psproliq IN NUMBER,
                         pncobro  IN NUMBER,
                         /* 0:MODO REAL 1:MODO PREVIO*/
                         pncdocu   IN VARCHAR2,
                         pfdocu    IN DATE,
                         pncban    IN NUMBER,
                         piimporte IN NUMBER,
                         ptobserva IN VARCHAR2) RETURN NUMBER;


   FUNCTION f_set_ctas(pcmodo    IN VARCHAR2,
                       pcagente  IN NUMBER,
                       pcempres  IN NUMBER,
                       pnnumlin  IN NUMBER,
                       pcsproces IN NUMBER) RETURN NUMBER;


   FUNCTION f_get_recibo(pnrecibo  IN NUMBER,
                         pcagente  IN NUMBER,
                         pctomador IN NUMBER,
                         psqryrec  OUT VARCHAR2) RETURN NUMBER;


   FUNCTION f_del_recibos(pnliqmen IN NUMBER,
                          pcempres IN NUMBER,
                          pcagente IN NUMBER) RETURN NUMBER;


   FUNCTION f_del_cobros(psproliq IN NUMBER,
                         pcempres IN NUMBER,
                         pcagente IN NUMBER) RETURN NUMBER;

   FUNCTION f_del_liquidacion(psproliq IN NUMBER,
                              pcempres IN NUMBER,
                              pcagente IN NUMBER,
                              pnliqmen IN NUMBER) RETURN NUMBER;


   FUNCTION f_del_agenteclave(psproliq IN NUMBER,
                              pcempres IN NUMBER,
                              pcagente IN NUMBER) RETURN NUMBER;

--AAC_INI-CONF_379-20160927
   FUNCTION f_pagos_gestion_outsourcing(pfecha	IN DATE,
										precaudo IN VARCHAR2,
										pproveedor IN VARCHAR2) RETURN NUMBER;
--AAC_FI-CONF_379-20160927

	FUNCTION f_update_irpf(
			v_psproliq	IN	NUMBER,
			v_pcempres	IN	NUMBER,
      v_pcagente IN NUMBER) RETURN NUMBER;

END pac_autoliquida;
/* Formatted on 23/03/2016 14:04 (Formatter Plus v.1.0) - (CSI-Factory Standard Format v.3.0) *//* Formatted on 23/03/2016 14:33 (Formatter Plus v.1.0) - (CSI-Factory Standard Format v.3.0) *//* Formatted on 28/03/2016 16:10 (Formatter Plus v.1.0) - (CSI-Factory Standard Format v.3.0) *//* Formatted on 28/03/2016 16:13 (Formatter Plus v.1.0) - (CSI-Factory Standard Format v.3.0) *//* Formatted on 28/03/2016 18:06 (Formatter Plus v.1.0) - (CSI-Factory Standard Format v.3.0) *//* Formatted on 30/03/2016 18:28 (Formatter Plus v.1.0) - (CSI-Factory Standard Format v.3.0) *//* Formatted on 30/03/2016 20:59 (Formatter Plus v.1.0) - (CSI-Factory Standard Format v.3.0) */

/

  GRANT EXECUTE ON "AXIS"."PAC_AUTOLIQUIDA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_AUTOLIQUIDA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_AUTOLIQUIDA" TO "PROGRAMADORESCSI";
