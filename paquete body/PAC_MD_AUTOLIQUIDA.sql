--------------------------------------------------------
--  DDL for Package Body PAC_MD_AUTOLIQUIDA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MD_AUTOLIQUIDA" AS
   /******************************************************************************
      NOMBRE:      PAC_MD_AUTOLIQUIDA
      PROP真SITO: Funciones para la liquidaci真n de comisiones

      REVISIONES:
      Ver        Fecha        Autor             Descripci真n
      ---------  ----------  ---------------  ------------------------------------
      1.0        27/05/2009   JRB                1. Creaci真n del package.

   ******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   FUNCTION f_get_autoliquidaciones(psproliq    IN NUMBER,
                                    pcempres    IN NUMBER,
                                    pfliquida   IN DATE,
                                    piimporte   IN NUMBER,
                                    pcagente    IN NUMBER,
                                    pcusuario   IN VARCHAR2,
                                    pcestado    IN NUMBER,
                                    pfcobro     IN DATE,
                                    pcurliquida OUT SYS_REFCURSOR,
                                    mensajes    IN OUT t_iax_mensajes) RETURN NUMBER IS
      v_pasexec NUMBER(8) := 1;
      v_param   VARCHAR2(200) := 'params : psproliq : ' || psproliq || ', pcempres : ' ||
                                 pcempres || ', pfliquida : ' || pfliquida ||
                                 ', piimporte : ' || piimporte || ', pcagente : ' ||
                                 pcagente || ', pcusuario : ' || pcusuario ||
                                 ', pcestado : ' || pcestado || ', pfcobro : ' || pfcobro;
      v_object  VARCHAR2(200) := 'PAC_md_autoLIQUIDAciones.f_get_autoliquidaciones';
      v_error   NUMBER(8);
      vsquery   VARCHAR2(4000);
   BEGIN
      IF psproliq IS NULL AND pcempres IS NULL AND pfliquida IS NULL AND
         piimporte IS NULL AND pcagente IS NULL AND pcusuario IS NULL AND
         pcestado IS NULL AND pfcobro IS NULL THEN
         RAISE e_param_error;
      END IF;

      v_error := pac_autoliquida.f_get_autoliquidaciones(psproliq,
                                                         pcempres,
                                                         pfliquida,
                                                         piimporte,
                                                         pcagente,
                                                         pcusuario,
                                                         pcestado,
                                                         pfcobro,
                                                         vsquery);

      IF v_error <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes,
                                              1,
                                              v_error);
         RAISE e_object_error;
      END IF;

      pcurliquida := pac_iax_listvalores.f_opencursor(vsquery,
                                                      mensajes);

      IF pac_md_log.f_log_consultas(vsquery,
                                    v_object,
                                    2,
                                    0,
                                    mensajes) <> 0 THEN
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

         IF pcurliquida%ISOPEN THEN
            CLOSE pcurliquida;
         END IF;

         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           v_object,
                                           1000006,
                                           v_pasexec,
                                           v_param,
                                           v_error);

         IF pcurliquida%ISOPEN THEN
            CLOSE pcurliquida;
         END IF;

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

         IF pcurliquida%ISOPEN THEN
            CLOSE pcurliquida;
         END IF;

         RETURN 1;
   END f_get_autoliquidaciones;

   FUNCTION f_get_autoliquidacion(psproliq IN NUMBER,
                                  pcempres IN NUMBER,
                                  pcagente IN NUMBER,
                                  pcurcab  OUT SYS_REFCURSOR,
                                  pcurcob  OUT SYS_REFCURSOR,
                                  pcurrec  OUT SYS_REFCURSOR,
                                  pcurapun OUT SYS_REFCURSOR,
                                  mensajes IN OUT t_iax_mensajes) RETURN NUMBER IS
      v_pasexec NUMBER(8) := 1;
      v_param   VARCHAR2(200) := 'params : psproliq : ' || psproliq || ', pcempres : ' ||
                                 pcempres || ', pcagente : ' || pcagente;
      v_object  VARCHAR2(200) := 'PAC_md_autoLIQUIDAciones.f_get_autoliquidacion';
      v_error   NUMBER(8);
      vcurcab   VARCHAR2(4000);
      vcurcob   VARCHAR2(4000);
      vcurrec   VARCHAR2(4000);
      vcurapun  VARCHAR2(4000);
   BEGIN
      IF psproliq IS NULL AND pcempres IS NULL AND pcagente IS NULL THEN
         RAISE e_param_error;
      END IF;

      v_error := pac_autoliquida.f_get_autoliquidacion(psproliq,
                                                       pcempres,
                                                       pcagente,
                                                       vcurcab,
                                                       vcurcob,
                                                       vcurrec,
                                                       vcurapun);

      IF v_error <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes,
                                              1,
                                              v_error);
         RAISE e_object_error;
      END IF;

      pcurcab := pac_iax_listvalores.f_opencursor(vcurcab,
                                                  mensajes);

      IF pac_md_log.f_log_consultas(vcurcab,
                                    v_object,
                                    2,
                                    0,
                                    mensajes) <> 0 THEN
         RAISE e_object_error;
      END IF;

      pcurcob := pac_iax_listvalores.f_opencursor(vcurcob,
                                                  mensajes);

      IF pac_md_log.f_log_consultas(vcurcob,
                                    v_object,
                                    2,
                                    0,
                                    mensajes) <> 0 THEN
         RAISE e_object_error;
      END IF;

      pcurrec := pac_iax_listvalores.f_opencursor(vcurrec,
                                                  mensajes);

      IF pac_md_log.f_log_consultas(vcurrec,
                                    v_object,
                                    2,
                                    0,
                                    mensajes) <> 0 THEN
         RAISE e_object_error;
      END IF;

      pcurapun := pac_iax_listvalores.f_opencursor(vcurapun,
                                                   mensajes);

      IF pac_md_log.f_log_consultas(vcurapun,
                                    v_object,
                                    2,
                                    0,
                                    mensajes) <> 0 THEN
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

         IF pcurcab%ISOPEN THEN
            CLOSE pcurcab;
         END IF;

         IF pcurcob%ISOPEN THEN
            CLOSE pcurcob;
         END IF;

         IF pcurrec%ISOPEN THEN
            CLOSE pcurrec;
         END IF;

         IF pcurapun%ISOPEN THEN
            CLOSE pcurapun;
         END IF;

         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           v_object,
                                           1000006,
                                           v_pasexec,
                                           v_param,
                                           v_error);

         IF pcurcab%ISOPEN THEN
            CLOSE pcurcab;
         END IF;

         IF pcurcob%ISOPEN THEN
            CLOSE pcurcob;
         END IF;

         IF pcurrec%ISOPEN THEN
            CLOSE pcurrec;
         END IF;

         IF pcurapun%ISOPEN THEN
            CLOSE pcurapun;
         END IF;

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

         IF pcurcab%ISOPEN THEN
            CLOSE pcurcab;
         END IF;

         IF pcurcob%ISOPEN THEN
            CLOSE pcurcob;
         END IF;

         IF pcurrec%ISOPEN THEN
            CLOSE pcurrec;
         END IF;

         IF pcurapun%ISOPEN THEN
            CLOSE pcurapun;
         END IF;

         RETURN 1;
   END f_get_autoliquidacion;

   FUNCTION f_get_autoliquidaage(psproliq   IN NUMBER,
                                 pcempres   IN NUMBER,
                                 pcageclave IN NUMBER,
                                 mensajes   IN OUT t_iax_mensajes)
      RETURN t_iax_autoliquidaage IS
      v_pasexec NUMBER(8) := 1;
      v_param   VARCHAR2(200) := 'params : psproliq : ' || psproliq || ', pcempres : ' ||
                                 pcempres || ', pcageclave : ' || pcageclave;
      v_object  VARCHAR2(200) := 'PAC_md_autoLIQUIDA.f_get_autoliquidaage';
      v_error   NUMBER(8);
      autoli    t_iax_autoliquidaage := t_iax_autoliquidaage();
   BEGIN
      IF pcempres IS NULL OR pcageclave IS NULL THEN
         RAISE e_param_error;
      END IF;

      autoli := pac_autoliquida.f_get_autoliquidaage(psproliq,
                                                     pcempres,
                                                     pcageclave);

      IF v_error <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes,
                                              1,
                                              v_error);
         RAISE e_object_error;
      END IF;

      RETURN autoli;
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
                                 mensajes     IN OUT t_iax_mensajes) RETURN NUMBER IS
      v_pasexec NUMBER(8) := 1;
      v_param   VARCHAR2(200) := 'params : pcempres : ' || pcempres || ', pcageclave : ' ||
                                 pcageclave || ', psproliq : ' || psproliq;
      v_object  VARCHAR2(200) := 'PAC_md_autoLIQUIDA.f_set_autoliquidaage';
      v_error   NUMBER(8);
   BEGIN
      IF pcempres IS NULL OR pcageclave IS NULL THEN
         RAISE e_param_error;
      END IF;

      v_error := pac_autoliquida.f_set_autoliquidaage(pcagente,
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
                                                      opsproliq);

      IF v_error <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes,
                                              1,
                                              v_error);
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
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           v_object,
                                           1000006,
                                           v_pasexec,
                                           v_param,
                                           v_error);
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
         RETURN 1;
   END f_set_autoliquidaage;

   FUNCTION f_set_autoliquidacion(pcmodo    IN VARCHAR2,
                                  pnliqmen  IN NUMBER,
                                  pcempres  IN NUMBER,
                                  pcagente  IN NUMBER,
                                  psproces  IN NUMBER,
                                  pocestado OUT NUMBER,
                                  mensajes  IN OUT t_iax_mensajes) RETURN NUMBER IS
      v_pasexec NUMBER(8) := 1;
      v_param   VARCHAR2(200) := 'params : pcmodo : ' || pcmodo || ', pnliqmen : ' ||
                                 pnliqmen || ', pcempres : ' || pcempres ||
                                 ', pcagente : ' || pcagente || ', psproces : ' ||
                                 psproces;
      v_object  VARCHAR2(200) := 'PAC_md_autoLIQUIDA.f_set_autoliquidacion';
      v_error   NUMBER(8);
   BEGIN
      IF pcagente IS NULL OR pcempres IS NULL OR pcmodo IS NULL OR pnliqmen IS NULL OR
         psproces IS NULL THEN
         RAISE e_param_error;
      END IF;

      v_error := pac_autoliquida.f_set_autoliquidacion(pcmodo,
                                                       pnliqmen,
                                                       pcempres,
                                                       pcagente,
                                                       psproces,
                                                       pocestado);

      IF v_error <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes,
                                              1,
                                              v_error);
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
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           v_object,
                                           1000006,
                                           v_pasexec,
                                           v_param,
                                           v_error);
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
                                 mensajes    IN OUT t_iax_mensajes) RETURN NUMBER IS
      v_pasexec NUMBER(8) := 1;
      v_param   VARCHAR2(500) := 'params : pcmodo : ' || pcmodo || ', pnliqmen : ' ||
                                 pnliqmen || ', pcempres : ' || pcempres ||
                                 ' , pcagente : ' || pcagente || ', pcestado : ' ||
                                 pcestado || ', pfliquida : ' || pfliquida ||
                                 ', pfcobro : ' || pfcobro || ', pctomador : ' ||
                                 pctomador || ' , pcusuario : ' || pcusuario ||
                                 ', piimporte :' || piimporte || ', psproliq :' ||
                                 psproliq || ', pidifglobal :' || pidifglobal;
      v_object  VARCHAR2(200) := 'PAC_md_autoLIQUIDA.f_set_autoliquidacab';
      v_error   NUMBER(8);
   BEGIN
      IF pcagente IS NULL OR pcempres IS NULL OR pcmodo IS NULL
        -- OR pnliqmen IS NULL
        -- OR pcestado IS NULL
         OR pfliquida IS NULL OR piimporte IS NULL THEN
         RAISE e_param_error;
      END IF;

      v_error := pac_autoliquida.f_set_autoliquidacab(pcmodo,
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
                                                      ponliqmen);

      IF v_error <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes,
                                              1,
                                              v_error);
         RETURN v_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           v_object,
                                           1000005,
                                           v_pasexec,
                                           v_param);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           v_object,
                                           1000006,
                                           v_pasexec,
                                           v_param,
                                           v_error);
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
                          mensajes     IN OUT t_iax_mensajes) RETURN NUMBER IS
      v_pasexec NUMBER(8) := 1;
      v_param   VARCHAR2(500) := 'params : pcmodo : ' || pcmodo || ', pnliqmen : ' ||
                                 pnliqmen || ', pcempres : ' || pcempres ||
                                 ' , pcagente : ' || pcagente || ', pnliqlin : ' ||
                                 pnliqlin || ', pnrecibo : ' || pnrecibo ||
                                 ', pctiprec : ' || pctiprec || ', pnfrafec : ' ||
                                 pnfrafec || ' , pfefecto : ' || pfefecto ||
                                 ', pitotalr :' || pitotalr || ', picomisi : ' ||
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
      v_object  VARCHAR2(200) := 'PAC_md_autoLIQUIDA.f_set_recibos';
      v_error   NUMBER(8);
   BEGIN
      IF pcmodo IS NULL OR pnliqmen IS NULL OR pcagente IS NULL OR pcempres IS NULL OR
         pnliqlin IS NULL OR pnrecibo IS NULL OR pctiprec IS NULL OR pnfrafec IS NULL OR
         pfefecto IS NULL OR pitotalr IS NULL OR picomisi IS NULL OR piretencom IS NULL OR
         psproces IS NULL OR ppl IS NULL THEN
         RAISE e_param_error;
      END IF;

      v_error := pac_autoliquida.f_set_recibos(pcmodo,
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
											   pcorteprod
											   --AAC_FI-CONF_379-20160927
											  );

      IF v_error <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes,
                                              1,
                                              v_error);
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
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           v_object,
                                           1000006,
                                           v_pasexec,
                                           v_param,
                                           v_error);
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
                         mensajes  IN OUT t_iax_mensajes) RETURN NUMBER IS
      v_pasexec NUMBER(8) := 1;
      v_param   VARCHAR2(3000) := 'params : pidcobro ' || pidcobro || ' psproliq : ' ||
                                  psproliq || ', pcagente : ' || pcagente ||
                                  ', pcempres : ' || pcempres || ', pncobro : ' ||
                                  pncobro || ' , pncdocu : ' || pncdocu || ', pfdocu : ' ||
                                  pfdocu || ', pncban : ' || pncban || ', piimporte : ' ||
                                  piimporte || ', ptobserva : ' || ptobserva;
      v_object  VARCHAR2(200) := 'PAC_md_autoLIQUIDA.f_set_cobros';
      v_error   NUMBER(8);
   BEGIN
      IF psproliq IS NULL OR pcagente IS NULL OR pcempres IS NULL OR pncobro IS NULL OR
         piimporte IS NULL
      --  OR ptobserva IS NULL
       THEN
         RAISE e_param_error;
      END IF;

      v_error := pac_autoliquida.f_set_cobros(pidcobro,
                                              pcagente,
                                              pcempres,
                                              psproliq,
                                              pncobro,
                                              pncdocu,
                                              pfdocu,
                                              pncban,
                                              piimporte,
                                              ptobserva);

      IF v_error <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes,
                                              1,
                                              v_error);
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
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           v_object,
                                           1000006,
                                           v_pasexec,
                                           v_param,
                                           v_error);
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
         RETURN 1;
   END f_set_cobros;

   FUNCTION f_set_ctas(pcmodo   IN VARCHAR2,
                       pcagente IN NUMBER,
                       pcempres IN NUMBER,
                       pnnumlin IN NUMBER,
                       pcproces IN NUMBER,
                       mensajes IN OUT t_iax_mensajes) RETURN NUMBER IS
      v_pasexec NUMBER(8) := 1;
      v_param   VARCHAR2(500) := 'params : pcmodo : ' || pcmodo || ', pcagente : ' ||
                                 pcagente || ', pcempres : ' || pcempres ||
                                 ', pnnumlin : ' || pnnumlin || ', pcproces : ' ||
                                 pcproces;
      v_object  VARCHAR2(200) := 'PAC_md_autoLIQUIDA.f_set_ctas';
      v_error   NUMBER(8);
   BEGIN
      IF pcmodo IS NULL OR pcagente IS NULL OR pcempres IS NULL OR pnnumlin IS NULL OR
         pcproces IS NULL THEN
         RAISE e_param_error;
      END IF;

      v_error := pac_autoliquida.f_set_ctas(pcmodo,
                                            pcagente,
                                            pcempres,
                                            pnnumlin,
                                            pcproces);

      IF v_error <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes,
                                              1,
                                              v_error);
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
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           v_object,
                                           1000006,
                                           v_pasexec,
                                           v_param,
                                           v_error);
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
         RETURN 1;
   END f_set_ctas;

   FUNCTION f_get_new_recibos(psproliq  IN NUMBER,
                              pcempres  IN NUMBER,
                              pcagente  IN NUMBER,
                              pctomador IN NUMBER,
                              pnrecibo  IN NUMBER,
                              pccurrec  OUT SYS_REFCURSOR,
                              mensajes  IN OUT t_iax_mensajes) RETURN NUMBER IS
      v_pasexec NUMBER(8) := 1;
      v_param   VARCHAR2(200) := 'params : psproliq : ' || psproliq || ', pcempres : ' ||
                                 pcempres || ', pcagente : ' || pcagente ||
                                 ', pctomador : ' || pctomador || ', pnrecibo : ' ||
                                 pnrecibo;
      v_object  VARCHAR2(200) := 'PAC_md_autoLIQUIDAciones.f_get_new_recibos';
      v_error   NUMBER(8);
      vsquery   VARCHAR2(4000);
   BEGIN
      IF pcempres IS NULL THEN
         RAISE e_param_error;
      END IF;

      v_error := pac_autoliquida.f_get_new_recibos(psproliq,
                                                   pcempres,
                                                   pcagente,
                                                   pctomador,
                                                   pnrecibo,
                                                   vsquery);

      IF v_error <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes,
                                              1,
                                              v_error);
         RAISE e_object_error;
      END IF;

      pccurrec := pac_iax_listvalores.f_opencursor(vsquery,
                                                   mensajes);

      IF pac_md_log.f_log_consultas(vsquery,
                                    v_object,
                                    2,
                                    0,
                                    mensajes) <> 0 THEN
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

         IF pccurrec%ISOPEN THEN
            CLOSE pccurrec;
         END IF;

         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           v_object,
                                           1000006,
                                           v_pasexec,
                                           v_param,
                                           v_error);

         IF pccurrec%ISOPEN THEN
            CLOSE pccurrec;
         END IF;

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

         IF pccurrec%ISOPEN THEN
            CLOSE pccurrec;
         END IF;

         RETURN 1;
   END f_get_new_recibos;

   FUNCTION f_get_new_ctas(pnliqmen IN NUMBER,
                           pcempres IN NUMBER,
                           pcagente IN NUMBER,
                           pcurctas OUT SYS_REFCURSOR,
                           mensajes IN OUT t_iax_mensajes) RETURN NUMBER IS
      v_pasexec NUMBER(8) := 1;
      v_param   VARCHAR2(200) := 'params : pcempres : ' || pcempres || ', pcagente : ' ||
                                 pcagente || ', pnliqmen : ' || pnliqmen;
      v_object  VARCHAR2(200) := 'PAC_md_autoLIQUIDAciones.f_get_new_ctas';
      v_error   NUMBER(8);
      vsquery   VARCHAR2(4000);
   BEGIN
      IF pcempres IS NULL OR pcagente IS NULL OR pnliqmen IS NULL THEN
         RAISE e_param_error;
      END IF;

      v_error := pac_autoliquida.f_get_new_ctas(pnliqmen,
                                                pcempres,
                                                pcagente,
                                                vsquery);

      IF v_error <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes,
                                              1,
                                              v_error);
         RAISE e_object_error;
      END IF;

      pcurctas := pac_iax_listvalores.f_opencursor(vsquery,
                                                   mensajes);

      IF pac_md_log.f_log_consultas(vsquery,
                                    v_object,
                                    2,
                                    0,
                                    mensajes) <> 0 THEN
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

         IF pcurctas%ISOPEN THEN
            CLOSE pcurctas;
         END IF;

         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           v_object,
                                           1000006,
                                           v_pasexec,
                                           v_param,
                                           v_error);

         IF pcurctas%ISOPEN THEN
            CLOSE pcurctas;
         END IF;

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

         IF pcurctas%ISOPEN THEN
            CLOSE pcurctas;
         END IF;

         RETURN 1;
   END f_get_new_ctas;

   FUNCTION f_get_ctas(psproliq IN NUMBER,
                       pcempres IN NUMBER,
                       pcagente IN NUMBER,
                       pcurctas OUT SYS_REFCURSOR,
                       mensajes IN OUT t_iax_mensajes) RETURN NUMBER IS
      v_pasexec NUMBER(8) := 1;
      v_param   VARCHAR2(200) := 'params : pcempres : ' || pcempres || ', pcagente : ' ||
                                 pcagente || ', psproliq : ' || psproliq;
      v_object  VARCHAR2(200) := 'PAC_md_autoLIQUIDAciones.f_get_ctas';
      v_error   NUMBER(8);
      vsquery   VARCHAR2(4000);
   BEGIN
      IF pcempres IS NULL OR pcagente IS NULL
      --OR pnliqmen IS NULL
       THEN
         RAISE e_param_error;
      END IF;

      v_error := pac_autoliquida.f_get_ctas(psproliq,
                                            pcempres,
                                            pcagente,
                                            vsquery);

      IF v_error <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes,
                                              1,
                                              v_error);
         RAISE e_object_error;
      END IF;

      pcurctas := pac_iax_listvalores.f_opencursor(vsquery,
                                                   mensajes);

      IF pac_md_log.f_log_consultas(vsquery,
                                    v_object,
                                    2,
                                    0,
                                    mensajes) <> 0 THEN
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

         IF pcurctas%ISOPEN THEN
            CLOSE pcurctas;
         END IF;

         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           v_object,
                                           1000006,
                                           v_pasexec,
                                           v_param,
                                           v_error);

         IF pcurctas%ISOPEN THEN
            CLOSE pcurctas;
         END IF;

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

         IF pcurctas%ISOPEN THEN
            CLOSE pcurctas;
         END IF;

         RETURN 1;
   END f_get_ctas;

   FUNCTION f_get_recibo(pnrecibo   IN NUMBER,
                         pcagente   IN NUMBER,
                         pctomador  IN NUMBER,
                         pcurrecibo OUT SYS_REFCURSOR,
                         mensajes   IN OUT t_iax_mensajes) RETURN NUMBER IS
      v_pasexec NUMBER(8) := 1;
      v_param   VARCHAR2(200) := 'params : pnrecibo : ' || pnrecibo || ', pcagente : ' ||
                                 pcagente || ', pctomador : ' || pctomador;
      v_object  VARCHAR2(200) := 'PAC_md_autoLIQUIDAciones.f_get_recibo';
      v_error   NUMBER(8);
      vsquery   VARCHAR2(4000);
   BEGIN
      IF pnrecibo IS NULL THEN
         RAISE e_param_error;
      END IF;

      v_error := pac_autoliquida.f_get_recibo(pnrecibo,
                                              pcagente,
                                              pctomador,
                                              vsquery);

      IF v_error <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes,
                                              1,
                                              v_error);
         RAISE e_object_error;
      END IF;

      pcurrecibo := pac_iax_listvalores.f_opencursor(vsquery,
                                                     mensajes);

      IF pac_md_log.f_log_consultas(vsquery,
                                    v_object,
                                    2,
                                    0,
                                    mensajes) <> 0 THEN
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

         IF pcurrecibo%ISOPEN THEN
            CLOSE pcurrecibo;
         END IF;

         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           v_object,
                                           1000006,
                                           v_pasexec,
                                           v_param,
                                           v_error);

         IF pcurrecibo%ISOPEN THEN
            CLOSE pcurrecibo;
         END IF;

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

         IF pcurrecibo%ISOPEN THEN
            CLOSE pcurrecibo;
         END IF;

         RETURN 1;
   END f_get_recibo;

   FUNCTION f_del_recibos(pnliqmen IN NUMBER,
                          pcempres IN NUMBER,
                          pcagente IN NUMBER,
                          mensajes IN OUT t_iax_mensajes) RETURN NUMBER IS
      v_pasexec NUMBER(8) := 1;
      v_param   VARCHAR2(500) := 'params : pnliqmen : ' || pnliqmen || ', pcagente : ' ||
                                 pcagente || ', pcempres : ' || pcempres;
      v_object  VARCHAR2(200) := 'PAC_md_autoLIQUIDA.f_del_recibos';
      v_error   NUMBER(8);
   BEGIN
      IF pnliqmen IS NULL OR pcempres IS NULL OR pcagente IS NULL THEN
         RAISE e_param_error;
      END IF;

      v_error := pac_autoliquida.f_del_recibos(pnliqmen,
                                               pcempres,
                                               pcagente);

      IF v_error <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes,
                                              1,
                                              v_error);
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
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           v_object,
                                           1000006,
                                           v_pasexec,
                                           v_param,
                                           v_error);
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
         RETURN 1;
   END f_del_recibos;

   FUNCTION f_del_cobros(pnliqmen IN NUMBER,
                         pcempres IN NUMBER,
                         pcagente IN NUMBER,
                         mensajes IN OUT t_iax_mensajes) RETURN NUMBER IS
      v_pasexec NUMBER(8) := 1;
      v_param   VARCHAR2(500) := 'params : pnliqmen : ' || pnliqmen || ', pcempres : ' ||
                                 pcempres || ', pcagente : ' || pcagente;
      v_object  VARCHAR2(200) := 'PAC_md_autoLIQUIDA.f_del_cobros';
      v_error   NUMBER(8);
   BEGIN
      IF pnliqmen IS NULL OR pcempres IS NULL OR pcagente IS NULL THEN
         RAISE e_param_error;
      END IF;

      v_error := pac_autoliquida.f_del_cobros(pnliqmen,
                                              pcempres,
                                              pcagente);

      IF v_error <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes,
                                              1,
                                              v_error);
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
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           v_object,
                                           1000006,
                                           v_pasexec,
                                           v_param,
                                           v_error);
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
         RETURN 1;
   END f_del_cobros;

   FUNCTION f_del_liquidacion(psproliq IN NUMBER,
                              pcempres IN NUMBER,
                              pcagente IN NUMBER,
                              pnliqmen IN NUMBER,
                              mensajes OUT t_iax_mensajes) RETURN NUMBER IS
      v_pasexec NUMBER(8) := 1;
      v_param   VARCHAR2(500) := 'params : psproliq : ' || psproliq || ', pcempres : ' ||
                                 pcempres || ', pcagente : ' || pcagente;
      v_object  VARCHAR2(200) := 'PAC_md_autoLIQUIDA.f_del_liquidacion';
      v_error   NUMBER(8);
   BEGIN
      IF psproliq IS NULL OR pcempres IS NULL OR pcagente IS NULL THEN
         RAISE e_param_error;
      END IF;

      v_error := pac_autoliquida.f_del_liquidacion(psproliq,
                                                   pcempres,
                                                   pcagente,
                                                   pnliqmen);

      IF v_error <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes,
                                              1,
                                              v_error);
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
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           v_object,
                                           1000006,
                                           v_pasexec,
                                           v_param,
                                           v_error);
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
         RETURN 1;
   END f_del_liquidacion;

   FUNCTION f_del_agenteclave(psproliq IN NUMBER,
                              pcempres IN NUMBER,
                              pcagente IN NUMBER,
                              mensajes OUT t_iax_mensajes) RETURN NUMBER IS
      v_pasexec NUMBER(8) := 1;
      v_param   VARCHAR2(500) := 'params : psproliq : ' || psproliq || ', pcempres : ' ||
                                 pcempres || ', pcagente : ' || pcagente;
      v_object  VARCHAR2(200) := 'PAC_md_autoLIQUIDA.f_del_agenteclave';
      v_error   NUMBER(8);
   BEGIN
      IF psproliq IS NULL OR pcempres IS NULL OR pcagente IS NULL THEN
         RAISE e_param_error;
      END IF;

      v_error := pac_autoliquida.f_del_agenteclave(psproliq,
                                                   pcempres,
                                                   pcagente);

      IF v_error <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes,
                                              1,
                                              v_error);
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
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           v_object,
                                           1000006,
                                           v_pasexec,
                                           v_param,
                                           v_error);
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
         RETURN 1;
   END f_del_agenteclave;
END pac_md_autoliquida;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_AUTOLIQUIDA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_AUTOLIQUIDA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_AUTOLIQUIDA" TO "PROGRAMADORESCSI";
