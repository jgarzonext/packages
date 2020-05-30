--------------------------------------------------------
--  DDL for Package PAC_MD_AUTOLIQUIDA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_MD_AUTOLIQUIDA" AS
   /******************************************************************************
      NOMBRE:      PAC_MD_AUTOLIQUIDA
      PROP真SITO: Funciones para la liquidaci真n de comisiones

      REVISIONES:
      Ver        Fecha        Autor             Descripci真n
      ---------  ----------  ---------------  ------------------------------------
      1.0        27/05/2015   JRB                1. Creaci真n del package.
   ******************************************************************************/

   /*************************************************************************
      Funci真n que seleccionar真 los recibos que se tienen que liquidar
      param in P_cempres    : c真digo empresa.
      param in P_sproduc    : Producto.
      param in P_npoliza    : P真liza.
      param in P_cagente    : Agente.
      param in P_femiini    : Fecha inicio emisi真n.
      param in P_femifin    : Fecha fin emisi真n.
      param in P_fefeini    : Fecha inicio efecto.
      param in P_fefefin    : Fecha fin efecto.
      param in P_fcobini    : Fecha inicio cobro.
      param in P_fcobfin    : Fecha fin cobro.
      param in/out mensajes : mensajes de error
      return                : Objeto recibos
   *************************************************************************/
   FUNCTION f_get_autoliquidaciones(psproliq    IN NUMBER,
                                    pcempres    IN NUMBER,
                                    pfliquida   IN DATE,
                                    piimporte   IN NUMBER,
                                    pcagente    IN NUMBER,
                                    pcusuario   IN VARCHAR2,
                                    pcestado    IN NUMBER,
                                    pfcobro     IN DATE,
                                    pcurliquida OUT SYS_REFCURSOR,
                                    mensajes    IN OUT t_iax_mensajes) RETURN NUMBER;

   FUNCTION f_get_autoliquidacion(psproliq IN NUMBER,
                                  pcempres IN NUMBER,
                                  pcagente IN NUMBER,
                                  pcurcab  OUT SYS_REFCURSOR,
                                  pcurcob  OUT SYS_REFCURSOR,
                                  pcurrec  OUT SYS_REFCURSOR,
                                  pcurapun OUT SYS_REFCURSOR,
                                  mensajes IN OUT t_iax_mensajes) RETURN NUMBER;

   FUNCTION f_get_autoliquidaage(psproliq   IN NUMBER,
                                 pcempres   IN NUMBER,
                                 pcageclave IN NUMBER,
                                 mensajes   IN OUT t_iax_mensajes)
      RETURN t_iax_autoliquidaage;

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
                                 opsproliq    OUT NUMBER,
                                 mensajes     IN OUT t_iax_mensajes) RETURN NUMBER;

   FUNCTION f_set_autoliquidacion(pcmodo    IN VARCHAR2,
                                  pnliqmen  IN NUMBER,
                                  pcempres  IN NUMBER,
                                  pcagente  IN NUMBER,
                                  psproces  IN NUMBER,
                                  pocestado OUT NUMBER,
                                  mensajes  IN OUT t_iax_mensajes) RETURN NUMBER;

   FUNCTION f_set_autoliquidacab(pcmodo      IN VARCHAR2,
                                 pnliqmen    IN NUMBER,
                                 pcempres    IN NUMBER,
                                 pcagente    IN NUMBER,
                                 pcestado    IN NUMBER,
                                 pfliquida   IN DATE,
                                 pfcobro     IN DATE,
                                 pctomador   IN NUMBER,
                                 pcusuario   IN VARCHAR2,
                                 piimporte   IN NUMBER,
                                 psproliq    IN NUMBER,
                                 pidifglobal IN NUMBER,
                                 pcproces    OUT NUMBER,
                                 ponliqmen   OUT NUMBER,
                                 mensajes    IN OUT t_iax_mensajes) RETURN NUMBER;

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
						  pcorteprod	IN	NUMBER,
						  --AAC_FI-CONF_379-20160927
                          mensajes     IN OUT t_iax_mensajes) RETURN NUMBER;

   FUNCTION f_set_cobros(pidcobro  IN NUMBER,
                         pcagente  IN NUMBER,
                         pcempres  IN NUMBER,
                         psproliq  IN NUMBER,
                         pncobro   IN NUMBER,
                         pncdocu   IN VARCHAR2,
                         pfdocu    IN DATE,
                         pncban    IN NUMBER,
                         piimporte IN NUMBER,
                         ptobserva IN VARCHAR2,
                         mensajes  IN OUT t_iax_mensajes) RETURN NUMBER;

   FUNCTION f_set_ctas(pcmodo   IN VARCHAR2,
                       pcagente IN NUMBER,
                       pcempres IN NUMBER,
                       pnnumlin IN NUMBER,
                       pcproces IN NUMBER,
                       mensajes IN OUT t_iax_mensajes) RETURN NUMBER;

   FUNCTION f_get_new_recibos(psproliq  IN NUMBER,
                              pcempres  IN NUMBER,
                              pcagente  IN NUMBER,
                              pctomador IN NUMBER,
                              pnrecibo  IN NUMBER,
                              pccurrec  OUT SYS_REFCURSOR,
                              mensajes  IN OUT t_iax_mensajes) RETURN NUMBER;

   FUNCTION f_get_new_ctas(pnliqmen IN NUMBER,
                           pcempres IN NUMBER,
                           pcagente IN NUMBER,
                           pcurctas OUT SYS_REFCURSOR,
                           mensajes IN OUT t_iax_mensajes) RETURN NUMBER;

   FUNCTION f_get_ctas(psproliq IN NUMBER,
                       pcempres IN NUMBER,
                       pcagente IN NUMBER,
                       pcurctas OUT SYS_REFCURSOR,
                       mensajes IN OUT t_iax_mensajes) RETURN NUMBER;

   FUNCTION f_get_recibo(pnrecibo   IN NUMBER,
                         pcagente   IN NUMBER,
                         pctomador  IN NUMBER,
                         pcurrecibo OUT SYS_REFCURSOR,
                         mensajes   IN OUT t_iax_mensajes) RETURN NUMBER;

   FUNCTION f_del_recibos(pnliqmen IN NUMBER,
                          pcempres IN NUMBER,
                          pcagente IN NUMBER,
                          mensajes IN OUT t_iax_mensajes) RETURN NUMBER;

   FUNCTION f_del_cobros(pnliqmen IN NUMBER,
                         pcempres IN NUMBER,
                         pcagente IN NUMBER,
                         mensajes IN OUT t_iax_mensajes) RETURN NUMBER;

   FUNCTION f_del_liquidacion(psproliq IN NUMBER,
                              pcempres IN NUMBER,
                              pcagente IN NUMBER,
                              pnliqmen IN NUMBER,
                              mensajes OUT t_iax_mensajes) RETURN NUMBER;


   FUNCTION f_del_agenteclave(psproliq IN NUMBER,
                              pcempres IN NUMBER,
                              pcagente IN NUMBER,
                              mensajes OUT t_iax_mensajes) RETURN NUMBER;

END pac_md_autoliquida;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_AUTOLIQUIDA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_AUTOLIQUIDA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_AUTOLIQUIDA" TO "PROGRAMADORESCSI";
