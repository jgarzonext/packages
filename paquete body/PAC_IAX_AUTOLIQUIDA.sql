--------------------------------------------------------
--  DDL for Package Body PAC_IAX_AUTOLIQUIDA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IAX_AUTOLIQUIDA" AS
   /******************************************************************************
      NOMBRE:       PAC_IAX_AUTOLIQUIDA
      PROP真SITO:    Contiene las funciones para la liquidaci真n de comisiones

      REVISIONES:
      Ver        Fecha        Autor             Descripci真n
      ---------  ----------  ---------------  ------------------------------------
      1.0        26/05/2009   JRB                1. Creaci真n del package.

   ******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   /*************************************************************************
      Funci真n que seleccionar真 los recibos que se tienen que liquidar
      param in  P_cempres   : Empresa
      param in  P_sproduc   : Producto
      param in  P_npoliza   : P真liza
      param in  P_cagente   : Agente
      param in  P_femiini   : Fecha inicio emisi真n
      param in  P_femifin   : Fecha fin emisi真n
      param in  P_fefeini   : Fecha inicio efecto
      param in  P_fefefin   : Fecha fin efecto
      param in  P_fcobini   : Fecha inicio cobro
      param in  P_fcobfin   : Fecha fin cobro
      param out mensajes    : Mensajes de error
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
                                    mensajes    OUT t_iax_mensajes) RETURN NUMBER IS
      v_pasexec NUMBER(8) := 1;
      v_param   VARCHAR2(200) := 'params : psproliq : ' || psproliq || ', pcempres : ' ||
                                 pcempres || ', pfliquida : ' || pfliquida ||
                                 ', piimporte : ' || piimporte || ', pcagente : ' ||
                                 pcagente || ', pcusuario : ' || pcusuario ||
                                 ', pcestado : ' || pcestado || ', pfcobro : ' || pfcobro;
      v_object  VARCHAR2(200) := 'PAC_IAX_AUTOLIQUIDA.f_get_autoliquidaciones';
      v_error   NUMBER(8);
   BEGIN
      v_error := pac_md_autoliquida.f_get_autoliquidaciones(psproliq,
                                                            pcempres,
                                                            pfliquida,
                                                            piimporte,
                                                            pcagente,
                                                            pcusuario,
                                                            pcestado,
                                                            pfcobro,
                                                            pcurliquida,
                                                            mensajes);

      IF v_error <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         IF pcurliquida%ISOPEN THEN
            CLOSE pcurliquida;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           v_object,
                                           1000005,
                                           v_pasexec,
                                           v_param);
         RETURN 1;
      WHEN e_object_error THEN
         IF pcurliquida%ISOPEN THEN
            CLOSE pcurliquida;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           v_object,
                                           1000006,
                                           v_pasexec,
                                           v_param,
                                           v_error);
         RETURN 1;
      WHEN OTHERS THEN
         IF pcurliquida%ISOPEN THEN
            CLOSE pcurliquida;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           v_object,
                                           1000001,
                                           v_pasexec,
                                           v_param,
                                           NULL,
                                           SQLCODE,
                                           SQLERRM);
         RETURN 1;
   END f_get_autoliquidaciones;

   FUNCTION f_get_autoliquidacion(psproliq   IN NUMBER,
                                  pcempres   IN NUMBER,
                                  pcagente   IN NUMBER,
                                  pcurcab    OUT SYS_REFCURSOR,
                                  pcurdoccob OUT SYS_REFCURSOR,
                                  pcurrecpen OUT SYS_REFCURSOR,
                                  pcurapunt  OUT SYS_REFCURSOR,
                                  mensajes   OUT t_iax_mensajes) RETURN NUMBER IS
      v_pasexec NUMBER(8) := 1;
      v_param   VARCHAR2(200) := 'params : psproliq : ' || psproliq || ', pcempres : ' ||
                                 pcempres || ', pcagente : ' || pcagente;
      v_object  VARCHAR2(200) := 'PAC_IAX_AUTOLIQUIDA.f_get_autoliquidacion';
      v_error   NUMBER(8);
   BEGIN
      v_error := pac_md_autoliquida.f_get_autoliquidacion(psproliq,
                                                          pcempres,
                                                          pcagente,
                                                          pcurcab,
                                                          pcurdoccob,
                                                          pcurrecpen,
                                                          pcurapunt,
                                                          mensajes);

      IF v_error <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         IF pcurcab%ISOPEN THEN
            CLOSE pcurcab;
         END IF;

         IF pcurdoccob%ISOPEN THEN
            CLOSE pcurdoccob;
         END IF;

         IF pcurrecpen%ISOPEN THEN
            CLOSE pcurrecpen;
         END IF;

         IF pcurapunt%ISOPEN THEN
            CLOSE pcurapunt;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           v_object,
                                           1000005,
                                           v_pasexec,
                                           v_param);
         RETURN 1;
      WHEN e_object_error THEN
         IF pcurcab%ISOPEN THEN
            CLOSE pcurcab;
         END IF;

         IF pcurdoccob%ISOPEN THEN
            CLOSE pcurdoccob;
         END IF;

         IF pcurrecpen%ISOPEN THEN
            CLOSE pcurrecpen;
         END IF;

         IF pcurapunt%ISOPEN THEN
            CLOSE pcurapunt;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           v_object,
                                           1000006,
                                           v_pasexec,
                                           v_param,
                                           v_error);
         RETURN 1;
      WHEN OTHERS THEN
         IF pcurcab%ISOPEN THEN
            CLOSE pcurcab;
         END IF;

         IF pcurdoccob%ISOPEN THEN
            CLOSE pcurdoccob;
         END IF;

         IF pcurrecpen%ISOPEN THEN
            CLOSE pcurrecpen;
         END IF;

         IF pcurapunt%ISOPEN THEN
            CLOSE pcurapunt;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           v_object,
                                           1000001,
                                           v_pasexec,
                                           v_param,
                                           NULL,
                                           SQLCODE,
                                           SQLERRM);
         RETURN 1;
   END f_get_autoliquidacion;

   FUNCTION f_get_autoliquidaage(psproliq   IN NUMBER,
                                 pcempres   IN NUMBER,
                                 pcageclave IN NUMBER,
                                 mensajes   OUT t_iax_mensajes) RETURN t_iax_autoliquidaage IS
      v_pasexec NUMBER(8) := 1;
      v_param   VARCHAR2(200) := 'params : pcempres : ' || pcempres || ', pcageclave : ' ||
                                 pcageclave || ', psproliq : ' || psproliq;
      v_object  VARCHAR2(200) := 'PAC_IAX_AUTOLIQUIDA.f_set_autoliquidaage';
      v_error   NUMBER(8);
      autoliq   t_iax_autoliquidaage;
   BEGIN
      autoliq := pac_md_autoliquida.f_get_autoliquidaage(psproliq,
                                                         pcempres,
                                                         pcageclave,
                                                         mensajes);

      IF v_error <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN autoliq;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           v_object,
                                           1000005,
                                           v_pasexec,
                                           v_param);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           v_object,
                                           1000006,
                                           v_pasexec,
                                           v_param,
                                           v_error);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           v_object,
                                           1000001,
                                           v_pasexec,
                                           v_param,
                                           NULL,
                                           SQLCODE,
                                           SQLERRM);
         RETURN NULL;
   END f_get_autoliquidaage;

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
                                 mensajes     OUT t_iax_mensajes) RETURN NUMBER IS
      v_pasexec NUMBER(8) := 1;
      v_param   VARCHAR2(200) := 'params : pcempres : ' || pcempres || ', pcageclave : ' ||
                                 pcageclave || ', psproliq : ' || psproliq;
      v_object  VARCHAR2(200) := 'PAC_IAX_AUTOLIQUIDA.f_set_autoliquidaage';
      v_error   NUMBER(8);
   BEGIN
      v_error := pac_md_autoliquida.f_set_autoliquidaage(pcagente,
                                                         pnliqmen,
                                                         pcestautoliq,
                                                         piimporte,
                                                         pcusuari,
                                                         pfcobro,
                                                         pcmarcado,
                                                         pidifglobal,
                                                         pfliquida,
                                                         pcempres,
                                                         pcageclave,
                                                         psproliq,
                                                         opsproliq,
                                                         mensajes);

      IF v_error <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           v_object,
                                           1000005,
                                           v_pasexec,
                                           v_param);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           v_object,
                                           1000006,
                                           v_pasexec,
                                           v_param,
                                           v_error);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           v_object,
                                           1000001,
                                           v_pasexec,
                                           v_param,
                                           NULL,
                                           SQLCODE,
                                           SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_set_autoliquidaage;

   FUNCTION f_set_autoliquidacion(pcmodo    IN VARCHAR2,
                                  pnliqmen  IN NUMBER,
                                  pcempres  IN NUMBER,
                                  pcagente  IN NUMBER,
                                  psproces  IN NUMBER,
                                  pocestado OUT NUMBER,
                                  mensajes  OUT t_iax_mensajes) RETURN NUMBER IS
      v_pasexec NUMBER(8) := 1;
      v_param   VARCHAR2(200) := 'params : pcmodo : ' || pcmodo || ', pnliqmen : ' ||
                                 pnliqmen || ', pcempres : ' || pcempres ||
                                 ', pcagente : ' || pcagente || ', psproces : ' ||
                                 psproces;
      v_object  VARCHAR2(200) := 'PAC_IAX_AUTOLIQUIDA.f_set_autoliquidacion';
      v_error   NUMBER(8);
   BEGIN
      --hacemos commit antes.
      COMMIT;
      v_error := pac_md_autoliquida.f_set_autoliquidacion(pcmodo,
                                                          pnliqmen,
                                                          pcempres,
                                                          pcagente,
                                                          psproces,
                                                          pocestado,
                                                          mensajes);

      IF v_error <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           v_object,
                                           1000005,
                                           v_pasexec,
                                           v_param);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           v_object,
                                           1000006,
                                           v_pasexec,
                                           v_param,
                                           v_error);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           v_object,
                                           1000001,
                                           v_pasexec,
                                           v_param,
                                           NULL,
                                           SQLCODE,
                                           SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_set_autoliquidacion;

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
                                 mensajes    OUT t_iax_mensajes) RETURN NUMBER IS
      v_pasexec NUMBER(8) := 1;
      v_param   VARCHAR2(400) := 'params : pcmodo : ' || pcmodo || ', pnliqmen : ' ||
                                 pnliqmen || ', pcempres : ' || pcempres ||
                                 ', pcagente : ' || pcagente || ', pcestado : ' ||
                                 pcestado || ', pfliquida : ' || pfliquida ||
                                 ', pfcobro : ' || pfcobro || ', pctomador : ' ||
                                 pctomador || ', pcusuario : ' || pcusuario ||
                                 ', piimporte : ' || piimporte || ', psproliq : ' ||
                                 psproliq || ', pidifglobal : ' || pidifglobal;
      v_object  VARCHAR2(200) := 'PAC_IAX_AUTOLIQUIDA.f_set_autoliquidacab';
      v_error   NUMBER(8);
   BEGIN
      v_error := pac_md_autoliquida.f_set_autoliquidacab(pcmodo,
                                                         pnliqmen,
                                                         pcempres,
                                                         pcagente,
                                                         pcestado,
                                                         pfliquida,
                                                         pfcobro,
                                                         pctomador,
                                                         pcusuario,
                                                         piimporte,
                                                         psproliq,
                                                         pidifglobal,
                                                         pcproces,
                                                         ponliqmen,
                                                         mensajes);

      IF v_error <> 0 THEN
         RETURN v_error;
      END IF;

      --COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           v_object,
                                           1000005,
                                           v_pasexec,
                                           v_param);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           v_object,
                                           1000006,
                                           v_pasexec,
                                           v_param,
                                           v_error);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           v_object,
                                           1000001,
                                           v_pasexec,
                                           v_param,
                                           NULL,
                                           SQLCODE,
                                           SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_set_autoliquidacab;

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
                          mensajes     OUT t_iax_mensajes) RETURN NUMBER IS
      v_pasexec NUMBER(8) := 1;
      v_param   VARCHAR2(500) := 'params : pcmodo : ' || pcmodo || ', pnliqmen : ' ||
                                 pnliqmen || ', pcempres : ' || pcempres ||
                                 ', pcagente : ' || pcagente || ', pnliqlin : ' ||
                                 pnliqlin || ', pnrecibo : ' || pnrecibo ||
                                 ', pctiprec : ' || pctiprec || ', pnfrafec : ' ||
                                 pnfrafec || ', pfefecto : ' || pfefecto ||
                                 ', pitotalr : ' || pitotalr || ', picomisi : ' ||
                                 picomisi || ', piretencom : ' || piretencom ||
                                 ', pidiferencia : ' || pidiferencia || ', psproces : ' ||
                                 psproces || ', ppl : ' || ppl
								 --AAC_INI-CONF_379-20160927
								 || ', pimppend : ' || pimppend
								 || ', pvabono : ' || pvabono
								 || ', pfabono : ' || pfabono
								 || ', pdocreau : ' || pdocreau
								 || ', pcorteprod : ' || pcorteprod
								 --AAC_FI-CONF_379-20160927
								 ;
      v_object  VARCHAR2(200) := 'PAC_IAX_AUTOLIQUIDA.f_set_recibos';
      v_error   NUMBER(8);
   BEGIN
      v_error := pac_md_autoliquida.f_set_recibos(pcmodo,
                                                  pnliqmen,
                                                  pcempres,
                                                  pcagente,
                                                  pnliqlin,
                                                  pnrecibo,
                                                  pctiprec,
                                                  pnfrafec,
                                                  pfefecto,
                                                  pitotalr,
                                                  picomisi,
                                                  piretencom,
                                                  pidiferencia,
                                                  psproces,
                                                  ppl,
                                                  pidiferpyg,
												  --AAC_INI-CONF_379-20160927
												  pimppend,
												  pvabono,
												  pfabono,
												  pdocreau,
												  pcorteprod,
												  --AAC_FI-CONF_379-20160927
                                                  mensajes);

      IF v_error <> 0 THEN
         RAISE e_object_error;
      END IF;

      --COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           v_object,
                                           1000005,
                                           v_pasexec,
                                           v_param);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           v_object,
                                           1000006,
                                           v_pasexec,
                                           v_param,
                                           v_error);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           v_object,
                                           1000001,
                                           v_pasexec,
                                           v_param,
                                           NULL,
                                           SQLCODE,
                                           SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_set_recibos;

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
                         mensajes  OUT t_iax_mensajes) RETURN NUMBER IS
      v_pasexec NUMBER(8) := 1;
      v_param   VARCHAR2(3000) := 'params : idcobro: ' || pidcobro || ' pcagente : ' ||
                                  pcagente || ' pcempres : ' || pcempres ||
                                  ' psproliq : ' || psproliq || ', pncobro : ' || pncobro ||
                                  ', pncdocu : ' || pncdocu || ', pfdocu : ' || pfdocu ||
                                  ', pncban : ' || pncban || ', piimporte : ' ||
                                  piimporte || ', ptobserva : ' || ptobserva;
      v_object  VARCHAR2(200) := 'PAC_IAX_AUTOLIQUIDA.f_set_cobros';
      v_error   NUMBER(8);
   BEGIN
      v_error := pac_md_autoliquida.f_set_cobros(pidcobro,
                                                 pcagente,
                                                 pcempres,
                                                 psproliq,
                                                 pncobro,
                                                 pncdocu,
                                                 pfdocu,
                                                 pncban,
                                                 piimporte,
                                                 ptobserva,
                                                 mensajes);

      IF v_error <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           v_object,
                                           1000005,
                                           v_pasexec,
                                           v_param);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           v_object,
                                           1000006,
                                           v_pasexec,
                                           v_param,
                                           v_error);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           v_object,
                                           1000001,
                                           v_pasexec,
                                           v_param,
                                           NULL,
                                           SQLCODE,
                                           SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_set_cobros;

   FUNCTION f_set_ctas(pcmodo   IN VARCHAR2,
                       pcagente IN NUMBER,
                       pcempres IN NUMBER,
                       pnnumlin IN NUMBER,
                       pcproces IN NUMBER,
                       mensajes OUT t_iax_mensajes) RETURN NUMBER IS
      v_pasexec NUMBER(8) := 1;
      v_param   VARCHAR2(200) := 'params : pcmodo : ' || pcmodo || ', pcagente : ' ||
                                 pcagente || ', pcempres : ' || pcempres ||
                                 ', pnnumlin : ' || pnnumlin || ', pcproces : ' ||
                                 pcproces;
      v_object  VARCHAR2(200) := 'PAC_IAX_AUTOLIQUIDA.f_set_ctas';
      v_error   NUMBER(8);
   BEGIN
      v_error := pac_md_autoliquida.f_set_ctas(pcmodo,
                                               pcagente,
                                               pcempres,
                                               pnnumlin,
                                               pcproces,
                                               mensajes);

      IF v_error <> 0 THEN
         RAISE e_object_error;
      END IF;

      --COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           v_object,
                                           1000005,
                                           v_pasexec,
                                           v_param);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           v_object,
                                           1000006,
                                           v_pasexec,
                                           v_param,
                                           v_error);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           v_object,
                                           1000001,
                                           v_pasexec,
                                           v_param,
                                           NULL,
                                           SQLCODE,
                                           SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_set_ctas;

   FUNCTION f_get_new_recibos(psproliq  IN NUMBER,
                              pcempres  IN NUMBER,
                              pcagente  IN NUMBER,
                              pctomador IN NUMBER,
                              pnrecibo  IN NUMBER,
                              pccurrec  OUT SYS_REFCURSOR,
                              mensajes  OUT t_iax_mensajes) RETURN NUMBER IS
      v_pasexec NUMBER(8) := 1;
      v_param   VARCHAR2(200) := 'params : psproliq : ' || psproliq || ', pcempres : ' ||
                                 pcempres || ', pcagente : ' || pcagente ||
                                 ', pctomador : ' || pctomador || ', pnrecibo : ' ||
                                 pnrecibo;
      v_object  VARCHAR2(200) := 'PAC_IAX_AUTOLIQUIDA.f_get_new_recibos';
      v_error   NUMBER(8);
   BEGIN
      v_error := pac_md_autoliquida.f_get_new_recibos(psproliq,
                                                      pcempres,
                                                      pcagente,
                                                      pctomador,
                                                      pnrecibo,
                                                      pccurrec,
                                                      mensajes);

      IF v_error <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         IF pccurrec%ISOPEN THEN
            CLOSE pccurrec;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           v_object,
                                           1000005,
                                           v_pasexec,
                                           v_param);
         RETURN 1;
      WHEN e_object_error THEN
         IF pccurrec%ISOPEN THEN
            CLOSE pccurrec;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           v_object,
                                           1000006,
                                           v_pasexec,
                                           v_param,
                                           v_error);
         RETURN 1;
      WHEN OTHERS THEN
         IF pccurrec%ISOPEN THEN
            CLOSE pccurrec;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           v_object,
                                           1000001,
                                           v_pasexec,
                                           v_param,
                                           NULL,
                                           SQLCODE,
                                           SQLERRM);
         RETURN 1;
   END f_get_new_recibos;

   FUNCTION f_get_new_ctas(pnliqmen IN NUMBER,
                           pcempres IN NUMBER,
                           pcagente IN NUMBER,
                           pcurctas OUT SYS_REFCURSOR,
                           mensajes OUT t_iax_mensajes) RETURN NUMBER IS
      v_pasexec NUMBER(8) := 1;
      v_param   VARCHAR2(200) := 'params : pnliqmen : ' || pnliqmen || ', pcempres : ' ||
                                 pcempres || ', pcagente : ' || pcagente;
      v_object  VARCHAR2(200) := 'PAC_IAX_AUTOLIQUIDA.f_get_new_ctas';
      v_error   NUMBER(8);
   BEGIN
      v_error := pac_md_autoliquida.f_get_new_ctas(pnliqmen,
                                                   pcempres,
                                                   pcagente,
                                                   pcurctas,
                                                   mensajes);

      IF v_error <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         IF pcurctas%ISOPEN THEN
            CLOSE pcurctas;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           v_object,
                                           1000005,
                                           v_pasexec,
                                           v_param);
         RETURN 1;
      WHEN e_object_error THEN
         IF pcurctas%ISOPEN THEN
            CLOSE pcurctas;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           v_object,
                                           1000006,
                                           v_pasexec,
                                           v_param,
                                           v_error);
         RETURN 1;
      WHEN OTHERS THEN
         IF pcurctas%ISOPEN THEN
            CLOSE pcurctas;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           v_object,
                                           1000001,
                                           v_pasexec,
                                           v_param,
                                           NULL,
                                           SQLCODE,
                                           SQLERRM);
         RETURN 1;
   END f_get_new_ctas;

   FUNCTION f_get_ctas(psproliq IN NUMBER,
                       pcempres IN NUMBER,
                       pcagente IN NUMBER,
                       pcurctas OUT SYS_REFCURSOR,
                       mensajes OUT t_iax_mensajes) RETURN NUMBER IS
      v_pasexec NUMBER(8) := 1;
      v_param   VARCHAR2(200) := 'params : psproliq : ' || psproliq || ', pcempres : ' ||
                                 pcempres || ', pcagente : ' || pcagente;
      v_object  VARCHAR2(200) := 'PAC_IAX_AUTOLIQUIDA.f_get_ctas';
      v_error   NUMBER(8);
   BEGIN
      v_error := pac_md_autoliquida.f_get_ctas(psproliq,
                                               pcempres,
                                               pcagente,
                                               pcurctas,
                                               mensajes);

      IF v_error <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         IF pcurctas%ISOPEN THEN
            CLOSE pcurctas;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           v_object,
                                           1000005,
                                           v_pasexec,
                                           v_param);
         RETURN 1;
      WHEN e_object_error THEN
         IF pcurctas%ISOPEN THEN
            CLOSE pcurctas;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           v_object,
                                           1000006,
                                           v_pasexec,
                                           v_param,
                                           v_error);
         RETURN 1;
      WHEN OTHERS THEN
         IF pcurctas%ISOPEN THEN
            CLOSE pcurctas;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           v_object,
                                           1000001,
                                           v_pasexec,
                                           v_param,
                                           NULL,
                                           SQLCODE,
                                           SQLERRM);
         RETURN 1;
   END f_get_ctas;

   FUNCTION f_get_recibo(pnrecibo   IN NUMBER,
                         pcagente   IN NUMBER,
                         pctomador  IN NUMBER,
                         pcurrecibo OUT SYS_REFCURSOR,
                         mensajes   OUT t_iax_mensajes) RETURN NUMBER IS
      v_pasexec NUMBER(8) := 1;
      v_param   VARCHAR2(200) := 'params : pnrecibo : ' || pnrecibo || ', pcagente : ' ||
                                 pcagente || ', pctomador : ' || pctomador;
      v_object  VARCHAR2(200) := 'PAC_IAX_AUTOLIQUIDA.f_get_recibo';
      v_error   NUMBER(8);
   BEGIN
      v_error := pac_md_autoliquida.f_get_recibo(pnrecibo,
                                                 pcagente,
                                                 pctomador,
                                                 pcurrecibo,
                                                 mensajes);

      IF v_error <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         IF pcurrecibo%ISOPEN THEN
            CLOSE pcurrecibo;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           v_object,
                                           1000005,
                                           v_pasexec,
                                           v_param);
         RETURN 1;
      WHEN e_object_error THEN
         IF pcurrecibo%ISOPEN THEN
            CLOSE pcurrecibo;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           v_object,
                                           1000006,
                                           v_pasexec,
                                           v_param,
                                           v_error);
         RETURN 1;
      WHEN OTHERS THEN
         IF pcurrecibo%ISOPEN THEN
            CLOSE pcurrecibo;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           v_object,
                                           1000001,
                                           v_pasexec,
                                           v_param,
                                           NULL,
                                           SQLCODE,
                                           SQLERRM);
         RETURN 1;
   END f_get_recibo;

   FUNCTION f_del_recibos(pnliqmen IN NUMBER,
                          pcempres IN NUMBER,
                          pcagente IN NUMBER,
                          mensajes OUT t_iax_mensajes) RETURN NUMBER IS
      v_pasexec NUMBER(8) := 1;
      v_param   VARCHAR2(200) := 'params : pnliqmen : ' || pnliqmen || ', pcempres : ' ||
                                 pcempres || ', pcagente : ' || pcagente;
      v_object  VARCHAR2(200) := 'PAC_IAX_AUTOLIQUIDA.f_del_recibos';
      v_error   NUMBER(8);
   BEGIN
      v_error := pac_md_autoliquida.f_del_recibos(pnliqmen,
                                                  pcempres,
                                                  pcagente,
                                                  mensajes);

      IF v_error <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           v_object,
                                           1000005,
                                           v_pasexec,
                                           v_param);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           v_object,
                                           1000006,
                                           v_pasexec,
                                           v_param,
                                           v_error);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           v_object,
                                           1000001,
                                           v_pasexec,
                                           v_param,
                                           NULL,
                                           SQLCODE,
                                           SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_del_recibos;

   FUNCTION f_del_cobros(pnliqmen IN NUMBER,
                         pcempres IN NUMBER,
                         pcagente IN NUMBER,
                         mensajes OUT t_iax_mensajes) RETURN NUMBER IS
      v_pasexec NUMBER(8) := 1;
      v_param   VARCHAR2(200) := 'params : pnliqmen : ' || pnliqmen || ', pcempres : ' ||
                                 pcempres || ', pcagente : ' || pcagente;
      v_object  VARCHAR2(200) := 'PAC_IAX_AUTOLIQUIDA.f_del_cobros';
      v_error   NUMBER(8);
   BEGIN
      v_error := pac_md_autoliquida.f_del_cobros(pnliqmen,
                                                 pcempres,
                                                 pcagente,
                                                 mensajes);

      IF v_error <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           v_object,
                                           1000005,
                                           v_pasexec,
                                           v_param);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           v_object,
                                           1000006,
                                           v_pasexec,
                                           v_param,
                                           v_error);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           v_object,
                                           1000001,
                                           v_pasexec,
                                           v_param,
                                           NULL,
                                           SQLCODE,
                                           SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_del_cobros;

   FUNCTION f_del_liquidacion(psproliq IN NUMBER,
                              pcempres IN NUMBER,
                              pcagente IN NUMBER,
                              pnliqmen IN NUMBER,
                              mensajes OUT t_iax_mensajes) RETURN NUMBER IS
      v_pasexec NUMBER(8) := 1;
      v_param   VARCHAR2(200) := 'params : psproliq : ' || psproliq || ', pcempres : ' ||
                                 pcempres || ', pcagente : ' || pcagente;
      v_object  VARCHAR2(200) := 'PAC_IAX_AUTOLIQUIDA.f_del_liquidacion';
      v_error   NUMBER(8);
   BEGIN
      v_error := pac_md_autoliquida.f_del_liquidacion(psproliq,
                                                      pcempres,
                                                      pcagente,
                                                      pnliqmen,
                                                      mensajes);
      COMMIT;

      IF v_error <> 0 THEN
         RAISE e_object_error;
      END IF;


      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           v_object,
                                           1000005,
                                           v_pasexec,
                                           v_param);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           v_object,
                                           1000006,
                                           v_pasexec,
                                           v_param,
                                           v_error);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           v_object,
                                           1000001,
                                           v_pasexec,
                                           v_param,
                                           NULL,
                                           SQLCODE,
                                           SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_del_liquidacion;

   FUNCTION f_del_agenteclave(psproliq IN NUMBER,
                              pcempres IN NUMBER,
                              pcagente IN NUMBER,
                              mensajes OUT t_iax_mensajes) RETURN NUMBER IS
      v_pasexec NUMBER(8) := 1;
      v_param   VARCHAR2(200) := 'params : psproliq : ' || psproliq || ', pcempres : ' ||
                                 pcempres || ', pcagente : ' || pcagente;
      v_object  VARCHAR2(200) := 'PAC_IAX_AUTOLIQUIDA.f_del_agenteclave';
      v_error   NUMBER(8);
   BEGIN
      v_error := pac_md_autoliquida.f_del_agenteclave(psproliq,
                                                      pcempres,
                                                      pcagente,
                                                      mensajes);
      COMMIT;

      IF v_error <> 0 THEN
         RAISE e_object_error;
      END IF;


      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           v_object,
                                           1000005,
                                           v_pasexec,
                                           v_param);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           v_object,
                                           1000006,
                                           v_pasexec,
                                           v_param,
                                           v_error);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           v_object,
                                           1000001,
                                           v_pasexec,
                                           v_param,
                                           NULL,
                                           SQLCODE,
                                           SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_del_agenteclave;



END pac_iax_autoliquida;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_AUTOLIQUIDA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_AUTOLIQUIDA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_AUTOLIQUIDA" TO "PROGRAMADORESCSI";
