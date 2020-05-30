--------------------------------------------------------
--  DDL for Package Body PAC_IAX_ADM
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "AXIS"."PAC_IAX_ADM" AS
   /******************************************************************************
      NOMBRE:       PAC_IAX_ADM
      PROP¿SITO:  Funciones para datos de recibos

      REVISIONES:
      Ver        Fecha        Autor             Descripci¿n
      ---------  ----------  ---------------  ------------------------------------
      1.0        18/06/2008   JMR               1. Creaci¿n del package.
      1.1        11/03/2009   MCC               1. Gesti¿n de Impagados
      1.2        18/02/2010   JMF               2. 0012679 CEM - Treure la taula MOVRECIBOI
      2.0        11/10/2010   ICV               3. 0016140: AGA003 - filtro de estado de impresion en recibos
      3.0        04/11/2010   ICV               4. 0016325: CRT101 - Modificaci¿n de recibos para corredur¿a
      4.0        21/05/2010   ICV               5. 14586: CRT - A¿adir campo recibo compa¿ia
      5.0        17/06/2011   ICV               6. 0018838: CRT901 - Pantalla para modificar estado de un recibo
      6.0        29/05/2012   JGR               7. 0022327: MDP_A001-Consulta de recibos - 0115278
      6.1        30/05/2012   DCG               8. 0022327: MDP_A001-Consulta de recibos - 0115681
      7.0        12/09/2012   JGR               9. 0022763: MDP_A001-Unificacion / Desunificacion de recibos - 0119028
      8.0        12/12/2012   JGR              10. 0024754: (POSDE100)-Desarrollo-GAPS Administracion-Id 156 - Las consultas de facturas se puedan hacer por sucursal y regional
      9.0        06/11/2013   CEC              11. 0026295: RSA702-Desarrollar el modulo de Caja
      10.0       21/06/2019   SGM              12. IAXIS-4134 Reporte de acuerdo de pago 
      11.0       09/07/2019   DFR              11. IAXIS-3651 Proceso calculo de comisiones de outsourcing
      12.0       17/07/2019   DFR              12. IAXIS-3591 Visualizar los importes del recibo de manera ordenada y sin repetir conceptos.      
   ******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   /*************************************************************************
     Selecciona informaci¿n sobre recibos dependiendo de los par¿metros de entrada
      param in pnrecibo   :   numero de recibo.
      param in pcempres   :   empresa.
      param in psproduc   :   producto
      param in pnpoliza   :   p¿liza
      param in pncertif   :   certificado.
      param in pciprec    :   tipo de recibo.
      param in pcestrec   :   estado del recibo.
      param in pfemisioini:   fecha de emisi¿n. (inicio del rango)
      param in pfemisiofin:   fecha de emisi¿n.  ( fin del rango)
      param in pfefeini   :   fecha inicio efecto.  (inicio del rango)
      param in pfefefin   :   fecha fin efecto.  (inicio del rango)
      param in ptipo      :   nos indicar¿ si es tomador o asegurado ( tomador :=1, asegurado =2)
              (check que nos permitir¿ indicar si buscamos por los datos del tomador o por los datos del asegurado)
      param in psperson   :   c¿digo identificador de la persona
      param in pcreccia   :   recibo compa¿ia.

      Mensajes del tipo t_iax_mensajes

   *************************************************************************/
   FUNCTION f_get_consultarecibos(pnrecibo    IN NUMBER DEFAULT NULL,
                                  pcempres    IN NUMBER DEFAULT NULL,
                                  psproduc    IN NUMBER DEFAULT NULL,
                                  pnpoliza    IN NUMBER DEFAULT NULL,
                                  pncertif    IN NUMBER DEFAULT NULL,
                                  pciprec     IN NUMBER DEFAULT NULL,
                                  pcestrec    IN NUMBER DEFAULT NULL,
                                  pfemisioini IN DATE DEFAULT NULL,
                                  pfemisiofin IN DATE DEFAULT NULL,
                                  pfefeini    IN DATE DEFAULT NULL,
                                  pfefefin    IN DATE DEFAULT NULL,
                                  ptipo       IN NUMBER DEFAULT NULL,
                                  psperson    IN NUMBER DEFAULT NULL,
                                  pcreccia    IN VARCHAR2 DEFAULT NULL,
                                  --Bug 14586-PFA-21/05/2010- A¿adir campo recibo compa¿ia
                                  pcpolcia IN VARCHAR2 DEFAULT NULL,
                                  --Bug 14586-PFA-21/05/2010- A¿adir campo recibo compa¿ia
                                  -- Ini bug 18908 - 18/07/2011 - SRA
                                  pcramo     IN NUMBER,
                                  pcsucursal IN NUMBER,
                                  pcagente   IN NUMBER,
                                  pctipcob   IN NUMBER,
                                  -- Fin bug 18908 - 18/07/2011 - SRA
                                  pcondicion IN VARCHAR2,
                                  mensajes   OUT t_iax_mensajes)
      RETURN SYS_REFCURSOR IS
      vcursor  SYS_REFCURSOR;
      vnumerr  NUMBER;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(2000) := NULL;
      vobject  VARCHAR2(200) := 'PAC_IAX_ADM.Get_ConsultaRecibos';
   BEGIN
      --Recuperaci¿n de los recibos.
      vcursor := pac_md_adm.f_get_consultarecibos(pnrecibo, pcempres,
                                                  psproduc, pnpoliza,
                                                  pncertif, pciprec, pcestrec,
                                                  pfemisioini, pfemisiofin,
                                                  pfefeini, pfefefin, ptipo,
                                                  psperson, pcreccia,
                                                  pcpolcia,
                                                  -- Ini bug 18908 - 18/07/2011 - SRA
                                                  pcramo, pcsucursal,
                                                  pcagente, pctipcob,

                                                  -- Fin bug 18908 - 18/07/2011 - SRA
                                                  pcondicion, mensajes);
      --Tot ok
      RETURN vcursor;
   EXCEPTION
      WHEN e_param_error THEN
         IF vcursor%ISOPEN
         THEN
            CLOSE vcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN vcursor;
      WHEN OTHERS THEN
         IF vcursor%ISOPEN
         THEN
            CLOSE vcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam, NULL, SQLCODE,
                                           SQLERRM);
         RETURN vcursor;
   END f_get_consultarecibos;

   -- ini Bug 0012679 - 18/02/2010 - JMF
   /*************************************************************************
     Selecciona informaci¿n sobre recibos dependiendo de los par¿metros de entrada
      param in pnrecibo   :   numero de recibo.
      param in pcempres   :   empresa.
      param in psproduc   :   producto
      param in pnpoliza   :   p¿liza
      param in pncertif   :   certificado.
      param in pciprec    :   tipo de recibo.
      param in pcestrec   :   estado del recibo.
      param in pfemisioini:   fecha de emisi¿n. (inicio del rango)
      param in pfemisiofin:   fecha de emisi¿n.  ( fin del rango)
      param in pfefeini   :   fecha inicio efecto.  (inicio del rango)
      param in pfefefin   :   fecha fin efecto.  (inicio del rango)
      param in ptipo      :   nos indicar¿ si es tomador o asegurado ( tomador :=1, asegurado =2)
              (check que nos permitir¿ indicar si buscamos por los datos del tomador o por los datos del asegurado)
      param in psperson   :   c¿digo identificador de la persona.

      Mensajes del tipo t_iax_mensajes

   *************************************************************************/
   FUNCTION f_get_consultarecibos_mv(pnrecibo    IN NUMBER DEFAULT NULL,
                                     pcempres    IN NUMBER DEFAULT NULL,
                                     psproduc    IN NUMBER DEFAULT NULL,
                                     pnpoliza    IN NUMBER DEFAULT NULL,
                                     pncertif    IN NUMBER DEFAULT NULL,
                                     pciprec     IN NUMBER DEFAULT NULL,
                                     pcestrec    IN NUMBER DEFAULT NULL,
                                     pfemisioini IN DATE DEFAULT NULL,
                                     pfemisiofin IN DATE DEFAULT NULL,
                                     pfefeini    IN DATE DEFAULT NULL,
                                     pfefefin    IN DATE DEFAULT NULL,
                                     ptipo       IN NUMBER DEFAULT NULL,
                                     psperson    IN NUMBER DEFAULT NULL,
                                     precunif    IN NUMBER,
                                     pcestimp    IN NUMBER, --Bug.: 16140 - 11/10/2010 - ICV
                                     pcreccia    IN VARCHAR2, --Bug.: 14586 - 16/11/2010 - ICV
                                     pcpolcia    IN VARCHAR2, --Bug.: 14586 - 16/11/2010 - ICV
                                     pccompani   IN NUMBER, --Bug.: 16310 - 24/12/2010 - JBN
                                     pliquidad   IN NUMBER, --Bug.: 18732 - 07/06/201 - JBN)
                                     pfiltro     IN NUMBER,
                                     -- Ini bug 18908 - 18/07/2011 - SRA
                                     pcramo     IN NUMBER,
                                     pcsucursal IN NUMBER,
                                     pcagente   IN NUMBER,
                                     pctipcob   IN NUMBER,
                                     pdomi_sn   IN NUMBER,
                                     -- Fin bug 18908 - 18/07/2011 - SRA
                                     -- Inici Bug 20326/99335 - BFP 05/12/2011
                                     cbanco     IN NUMBER,
                                     ctipcuenta IN NUMBER,
                                     -- Fi Bug 20326/99335 - BFP 05/12/2011
                                     cobban     IN NUMBER, --BUG20501 - JTS - 28/12/2011
                                     prebut_ini VARCHAR2 DEFAULT NULL, --Bug 22080 - 25/06/2012
                                     -- Inici Bug 22327/115681 - DCG 30/05/2011
                                     pnanuali  IN NUMBER DEFAULT NULL,
                                     pnfracci  IN NUMBER DEFAULT NULL,
                                     ptipnegoc IN NUMBER DEFAULT NULL,
                                     -- Fi Bug 22327/115681 - DCG 30/05/2011
                                     pcondicion IN VARCHAR2 DEFAULT NULL,
                                     mensajes   OUT t_iax_mensajes,
                                     pctipage01 IN NUMBER DEFAULT NULL, -- 10. 0024754 POS JGR 12/12/2012
                                     pnreccaj   IN NUMBER DEFAULT NULL, -- BUG CONF-441 - 14/12/2016 - JAEG
                                     pcmreca    IN NUMBER DEFAULT NULL -- BUG CONF-441 - 14/12/2016 - JAEG
                                     ) RETURN SYS_REFCURSOR IS
      vcursor  SYS_REFCURSOR;
      vnumerr  NUMBER;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(2000) := NULL;
      vobject  VARCHAR2(200) := 'PAC_IAX_ADM.Get_ConsultaRecibos_mv';
   BEGIN
      --Recuperaci¿n de los recibos.
      vcursor := pac_md_adm.f_get_consultarecibos_mv(pnrecibo, pcempres,
                                                     psproduc, pnpoliza,
                                                     pncertif, pciprec,
                                                     pcestrec, pfemisioini,
                                                     pfemisiofin, pfefeini,
                                                     pfefefin, ptipo,
                                                     psperson, precunif,
                                                     pcestimp, pcreccia,
                                                     pcpolcia, pccompani,
                                                     pliquidad, pfiltro,
                                                     -- Ini bug 18908 - 18/07/2011 - SRA
                                                     pcramo, pcsucursal,
                                                     pcagente, pctipcob,
                                                     pdomi_sn,

                                                     -- Fin bug 18908 - 18/07/2011 - SRA
                                                     -- Inici Bug 20326/99335 - BFP 05/12/2011
                                                     cbanco, ctipcuenta,
                                                     -- Inici Bug 20326/99335 - BFP 05/12/2011
                                                     cobban,
                                                     --BUG20501 - JTS - 28/12/2011
                                                     prebut_ini,
                                                     --Bug 22080 - 25/06/2012
                                                     pnanuali, pnfracci,
                                                     ptipnegoc,
                                                     -- Inici Bug 22327/115681 - DCG 30/05/2011
                                                     pcondicion, mensajes,
                                                     pctipage01,
                                                     -- 10. 0024754 POS JGR 12/12/2012
                                                     NULL, pnreccaj, pcmreca
                                                     -- BUG CONF-441 - 14/12/2016 - JAEG
                                                     );
      --Tot ok
      RETURN vcursor;
   EXCEPTION
      WHEN e_param_error THEN
         IF vcursor%ISOPEN
         THEN
            CLOSE vcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN vcursor;
      WHEN OTHERS THEN
         IF vcursor%ISOPEN
         THEN
            CLOSE vcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam, NULL, SQLCODE,
                                           SQLERRM);
         RETURN vcursor;
   END f_get_consultarecibos_mv;

   -- fin Bug 0012679 - 18/02/2010 - JMF

   /*************************************************************************
     Se encarga de recuperar la informaci¿n de un recibo en concreto
      param in pnrecibo   :   numero de recibo.
      param in ptotagrup   :  0.- Importe del recibo 1.- Total agrupado
      Mensajes del tipo t_iax_mensajes
   *************************************************************************/
   FUNCTION f_get_datosrecibo(pnrecibo  IN NUMBER, -- numero de recibo.
                              ptotagrup IN NUMBER DEFAULT 0,
                              mensajes  OUT t_iax_mensajes)
      RETURN ob_iax_recibos IS
      recibo   ob_iax_recibos := ob_iax_recibos();
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(2000) := 'pnrecibo=' || pnrecibo || ' ptotagrup : ' ||
                                 ptotagrup;
      vobject  VARCHAR2(200) := 'PAC_IAX_GFI.F_Get_DatosRecibo';
   BEGIN
      recibo := pac_md_adm.f_get_datosrecibo(pnrecibo, ptotagrup, mensajes);
      RETURN recibo;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005,
                                           vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam, NULL, SQLCODE,
                                           SQLERRM);
         RETURN NULL;
   END f_get_datosrecibo;

   -- BUG12679:DRA:07/05/2010:Inici
   /*************************************************************************
     Se encarga de recuperar la informaci¿n de un recibo en concreto
      param in pnrecibo   :   numero de recibo.
      param in ptotagrup   :  0.- Importe del recibo 1.- Total agrupado
      Mensajes del tipo t_iax_mensajes
   *************************************************************************/
   FUNCTION f_get_datosrecibo_mv(pnrecibo  IN NUMBER, -- numero de recibo.
                                 ptotagrup IN NUMBER DEFAULT 0,
                                 mensajes  OUT t_iax_mensajes)
      RETURN ob_iax_recibos IS
      recibo   ob_iax_recibos := ob_iax_recibos();
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(2000) := 'pnrecibo=' || pnrecibo || ' ptotagrup : ' ||
                                 ptotagrup;
      vobject  VARCHAR2(200) := 'PAC_IAX_GFI.F_Get_DatosRecibo';
   BEGIN
      recibo := pac_md_adm.f_get_datosrecibo_mv(pnrecibo, ptotagrup,
                                                mensajes);
      RETURN recibo;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005,
                                           vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam, NULL, SQLCODE,
                                           SQLERRM);
         RETURN NULL;
   END f_get_datosrecibo_mv;

   -- BUG12679:DRA:07/05/2010:Fi

   /*************************************************************************
      Devuelve las descripciones para un cobrador bancario
      param in  p_ccobban    : Id. cobrador bancario
      param out p_tdescrip   : Descripci¿n del cobrador
      param out p_tcobban    : Nombre del cobrador
      param out mensajes   : Mensajes de error
      return                 : 0.- OK
                               1.- error
   *************************************************************************/
   FUNCTION f_descobrador(p_ccobban  IN NUMBER,
                          p_tdescrip OUT VARCHAR2,
                          p_tcobban  OUT VARCHAR2,
                          mensajes   OUT t_iax_mensajes) RETURN NUMBER IS
      v_pasexec NUMBER(8) := 1;
      v_param   VARCHAR2(200) := 'p_ccobban = ' || p_ccobban;
      v_object  VARCHAR2(200) := 'PAC_IAX_ADM.f_descobrador';
      v_error   NUMBER(8);
   BEGIN
      v_error := pac_md_adm.f_get_descobrador(p_ccobban, p_tdescrip,
                                              p_tcobban, mensajes);

      IF v_error != 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, v_error);
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000006,
                                           v_pasexec, v_param);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001,
                                           v_pasexec, v_param,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN 1;
   END f_descobrador;

   --Bug 9204-MCC-03/03/2009- Gesti¿n de impagados
   /*************************************************************************
          Funcion para obtener los datos de gesti¿n de impagados
          param in psseguro   : c¿digo de seguro
          param in pnrecibo   : N¿mero de recibo
          param in psmovrec   : Movimiento del recibo
          param out mensajes  : mensajes de error
          return           : 0 indica cambio realizado correctamente
                             <> 0 indica error
   *************************************************************************/
   FUNCTION f_get_impagados(psseguro IN NUMBER,
                            pnrecibo IN NUMBER,
                            psmovrec IN NUMBER,
                            mensajes OUT t_iax_mensajes) RETURN SYS_REFCURSOR IS
      vobject   VARCHAR2(500) := 'PAC_IAX_ADM.f_get_impagados';
      vparam    VARCHAR2(500) := 'par¿metros - psseguro: ' || psseguro ||
                                 ', pnrecibo: ' || pnrecibo ||
                                 ', psmovrec: ' || psmovrec;
      vpasexec  NUMBER(5) := 1;
      vnumerr   NUMBER(8) := 0;
      vcursor   SYS_REFCURSOR;
      vsquery   VARCHAR2(9000);
      vidioma   NUMBER := 2;
      v_max_reg NUMBER;
   BEGIN
      vcursor := pac_md_adm.f_get_impagados(psseguro, pnrecibo, psmovrec,
                                            mensajes);
      RETURN vcursor;
   EXCEPTION
      WHEN e_param_error THEN
         IF vcursor%ISOPEN
         THEN
            CLOSE vcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN vcursor;
      WHEN OTHERS THEN
         IF vcursor%ISOPEN
         THEN
            CLOSE vcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam, NULL, SQLCODE,
                                           SQLERRM);
         RETURN vcursor;
   END f_get_impagados;

   --FIN Bug 9204-MCC-03/03/2009- Gesti¿n de impagados

   /*************************************************************************
      --BUG 14438 - JTS - 12/05/2010
      Funci¿n que realiza la unificaci¿n de recibos
      param in p_nrecibos    : Lista de recibos a unificar
      param in out mensajes  : Mensajes de error
      return                 : 0.- OK
                               1.- error
   *************************************************************************/
   FUNCTION f_agruparecibo(p_nrecibos       IN CLOB,
                           p_nrecunif       OUT NUMBER,
                           mensajes         OUT t_iax_mensajes,
                           p_lstrecibosunif OUT SYS_REFCURSOR) --0031322/0175728:NSS:12/06/2014
    RETURN NUMBER IS
      v_pasexec NUMBER(8) := 1;
      v_param   VARCHAR2(2000) := 'p_nrecibos';
      v_object  VARCHAR2(200) := 'PAC_IAX_ADM.f_agruparecibo';
      v_error   NUMBER(8);
   BEGIN
      v_error := pac_md_adm.f_agruparecibo(p_nrecibos, p_nrecunif, mensajes,
                                           p_lstrecibosunif); --0031322/0175728:NSS:12/06/2014

      IF v_error != 0
      THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000006,
                                           v_pasexec, v_param);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001,
                                           v_pasexec, v_param,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_agruparecibo;

   /*************************************************************************
      --BUG 16325 - ICV - 04/11/2010
      Funci¿n que para actualizar los importes de los recibos
      param in out mensajes  : Mensajes de error
      return                 : 0.- OK
                               1.- error
   *************************************************************************/
   FUNCTION f_set_imprecibo(pnrecibo   IN NUMBER,
                            pnriesgo   IN NUMBER,
                            pit1dto    IN NUMBER,
                            piprinet   IN NUMBER,
                            pit1rec    IN NUMBER,
                            pit1con    IN NUMBER,
                            piips      IN NUMBER,
                            pidgs      IN NUMBER,
                            piarbitr   IN NUMBER,
                            pifng      IN NUMBER,
                            pfefecto   IN DATE,
                            pfvencim   IN DATE,
                            pcreccia   IN VARCHAR2,
                            picombru   IN NUMBER,
                            pcvalidado IN NUMBER,
                            mensajes   OUT t_iax_mensajes) RETURN NUMBER IS
      vcursor  SYS_REFCURSOR;
      vnumerr  NUMBER;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(2000) := 'par¿metros - pnrecibo: ' || pnrecibo ||
                                 ', pit1dto: ' || pit1dto || ', piprinet: ' ||
                                 piprinet || ', pit1rec: ' || pit1rec ||
                                 ', pit1con: ' || pit1con || ', piips: ' ||
                                 piips || ', pidgs: ' || pidgs ||
                                 ', piarbitr: ' || piarbitr || ', pifng: ' ||
                                 pifng || ', pFEFECTO: ' || pfefecto ||
                                 ', pFVENCIM: ' || pfvencim ||
                                 ', pCRECCIA: ' || pcreccia;
      vobject  VARCHAR2(200) := 'PAC_IAX_ADM.f_set_imprecibo';
   BEGIN
      IF pnrecibo IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      --Recuperaci¿n de los recibos.
      vnumerr := pac_md_adm.f_set_imprecibo(pnrecibo, pnriesgo, pit1dto,
                                            piprinet, pit1rec, pit1con, piips,
                                            pidgs, piarbitr, pifng, pfefecto,
                                            pfvencim, pcreccia, picombru,
                                            pcvalidado, mensajes);

      IF vnumerr <> 0
      THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam, NULL, SQLCODE,
                                           SQLERRM);
         RETURN 1;
   END f_set_imprecibo;

   /*************************************************************************
      --BUG 18838 - ICV - 17/06/2011
      Funci¿n para modificar el estado de los recibos
      param in out mensajes  : Mensajes de error
      return                 : 0.- OK
                               1.- error
   *************************************************************************/
   FUNCTION f_set_estadorec(pnrecibo IN NUMBER,
                            pcestrec IN NUMBER,
                            mensajes OUT t_iax_mensajes) RETURN NUMBER IS
      vnumerr  NUMBER;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(2000) := 'par¿metros - pnrecibo: ' || pnrecibo ||
                                 ', pcestrec: ' || pcestrec;
      vobject  VARCHAR2(200) := 'PAC_IAX_ADM.f_set_estadorec';
   BEGIN
      IF pnrecibo IS NULL OR
         pcestrec IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      --Recuperaci¿n de los recibos.
      vnumerr := pac_md_adm.f_set_estadorec(pnrecibo, pcestrec, mensajes);

      IF vnumerr <> 0
      THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam, NULL, SQLCODE,
                                           SQLERRM);
         RETURN 1;
   END f_set_estadorec;

   /**********************************************************************************************
      26/06/2012 - 43. 0022082: LCOL_A003-Mantenimiento de matriculas - 0117556
      Extrae la informaci¿n de las matr¿culas - para la consulta de matriculas
      pcempres     IN Empresa
      pnrecibo     IN Recibo.
      pccobban     IN Cobrador bancario
      pnmatric     IN N¿mero de matr¿cula
      pfenvini     IN Fecha env¿o desde
      pfenvfin     IN Fecha env¿o hasta
      pcidioma     IN C¿digo de idioma
      param out mensaje   : Tratamiento del mensaje
      return    = 0 indica cambio realizado correctamente
               <> 0 indica error

   ************************************************************************************************/
   FUNCTION f_get_matriculas(pcempres IN NUMBER,
                             pnpoliza IN NUMBER,
                             pncertif IN NUMBER,
                             pnrecibo IN NUMBER,
                             pccobban IN NUMBER,
                             pnmatric IN VARCHAR2,
                             pfenvini IN DATE,
                             pfenvfin IN DATE,
                             psperson IN NUMBER,
                             ptipo    IN NUMBER,
                             pcidioma IN NUMBER DEFAULT NULL,
                             mensajes OUT t_iax_mensajes) RETURN SYS_REFCURSOR IS
      vnumerr    NUMBER(8) := 0;
      vrefcursor SYS_REFCURSOR;
      vpasexec   NUMBER(8) := 1;
      vparam     VARCHAR2(200) := '';
      vobject    VARCHAR2(200) := 'PAC_IAX_ADM.F_GET_MATRICULAS';
      vnumerr    NUMBER := 0;
   BEGIN
      mensajes := t_iax_mensajes();
      --LLAMADA A LA FUNCI¿N
      vrefcursor := pac_md_adm.f_get_matriculas(pcempres, pnpoliza, pncertif,
                                                pnrecibo, pccobban, pnmatric,
                                                pfenvini, pfenvfin, psperson,
                                                ptipo, pcidioma, mensajes);
      RETURN vrefcursor;
   EXCEPTION
      --Se debe realizar el control de errores mediante  el PAC_IOBJ_MENSAJES.P_TRATARMENSAJE.
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005,
                                           vpasexec, vparam);
         RETURN vrefcursor;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN vrefcursor;
      WHEN OTHERS THEN
         IF vrefcursor%ISOPEN
         THEN
            CLOSE vrefcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN vrefcursor;
   END f_get_matriculas;

   /**********************************************************************************************
      26/06/2012 - 43. 0022082: LCOL_A003-Mantenimiento de matriculas - 0117556
      Extrae la informaci¿n de las matr¿culas - para la consulta de matriculas
      pcempres     IN Empresa
      pnrecibo     IN Recibo.
      pccobban     IN Cobrador bancario
      pnmatric     IN N¿mero de matr¿cula
      pfenvini     IN Fecha env¿o desde
      pfenvfin     IN Fecha env¿o hasta
      pcidioma     IN C¿digo de idioma
      param out mensaje   : Tratamiento del mensaje
      return    = 0 indica cambio realizado correctamente
               <> 0 indica error

   ************************************************************************************************/
   FUNCTION f_get_matriculas_det(pnmatric IN VARCHAR2,
                                 pcidioma IN NUMBER DEFAULT NULL,
                                 mensajes OUT t_iax_mensajes)
      RETURN SYS_REFCURSOR IS
      vnumerr    NUMBER(8) := 0;
      vrefcursor SYS_REFCURSOR;
      vpasexec   NUMBER(8) := 1;
      vparam     VARCHAR2(200) := '';
      vobject    VARCHAR2(200) := 'PAC_IAX_ADM.F_GET_MATRICULAS_DET';
      vnumerr    NUMBER := 0;
   BEGIN
      mensajes := t_iax_mensajes();
      --LLAMADA A LA FUNCI¿N
      vrefcursor := pac_md_adm.f_get_matriculas_det(pnmatric, pcidioma,
                                                    mensajes);
      RETURN vrefcursor;
   EXCEPTION
      --Se debe realizar el control de errores mediante  el PAC_IOBJ_MENSAJES.P_TRATARMENSAJE.
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005,
                                           vpasexec, vparam);
         RETURN vrefcursor;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN vrefcursor;
      WHEN OTHERS THEN
         IF vrefcursor%ISOPEN
         THEN
            CLOSE vrefcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN vrefcursor;
   END f_get_matriculas_det;

   /*************************************************************************
      29/05/2012 - 7. 0022327: MDP_A001-Consulta de recibos - 0115278
      Funci¿n que para actualizar los importes de los recibos
      param in out mensajes  : Mensajes de error
      return                 : 0.- OK
                               1.- error
   *************************************************************************/
   FUNCTION f_get_detrecibo_gtias(pnrecibo IN NUMBER,
                                  pcidioma IN NUMBER,
                                  pnriesgo IN NUMBER DEFAULT NULL,
                                  pcgarant IN NUMBER DEFAULT NULL,
                                  mensajes OUT t_iax_mensajes)
      RETURN SYS_REFCURSOR IS
      vcursor  SYS_REFCURSOR;
      vnumerr  NUMBER;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(2000) := 'par¿metros - pnrecibo: ' || pnrecibo ||
                                 ', pcidioma: ' || pcidioma ||
                                 ', pnriesgo: ' || pnriesgo ||
                                 ', pcgarant: ' || pcgarant;
      vobject  VARCHAR2(200) := 'PAC_IAX_ADM.f_get_detrecibo_gtias';
   BEGIN
      IF pnrecibo IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vcursor := pac_md_adm.f_get_detrecibo_gtias(pnrecibo, pcidioma,
                                                  pnriesgo, pcgarant,
                                                  mensajes);
      RETURN vcursor;
   EXCEPTION
      WHEN e_param_error THEN
         IF vcursor%ISOPEN
         THEN
            CLOSE vcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN vcursor;
      WHEN OTHERS THEN
         IF vcursor%ISOPEN
         THEN
            CLOSE vcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam, NULL, SQLCODE,
                                           SQLERRM);
         RETURN vcursor;
   END f_get_detrecibo_gtias;

   /*************************************************************************
      29/05/2012 - 7. 0022327: MDP_A001-Consulta de recibos - 0115278
      Extrae la informaci¿n detallada del recibo por garant¿as.
      param in out mensajes  : Mensajes de error
      return                 : 0.- OK
                               1.- error
   *************************************************************************/
   FUNCTION f_get_adm_recunif(pnrecibo IN NUMBER,
                              pcidioma IN NUMBER,
                              mensajes OUT t_iax_mensajes)
      RETURN SYS_REFCURSOR IS
      vcursor  SYS_REFCURSOR;
      vnumerr  NUMBER;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(2000) := 'par¿metros - pnrecibo: ' || pnrecibo ||
                                 ', pcidioma: ' || pcidioma;
      vobject  VARCHAR2(200) := 'PAC_IAX_ADM.f_get_adm_recunif';
   BEGIN
      IF pnrecibo IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vcursor := pac_md_adm.f_get_adm_recunif(pnrecibo, pcidioma, mensajes);
      RETURN vcursor;
   EXCEPTION
      WHEN e_param_error THEN
         IF vcursor%ISOPEN
         THEN
            CLOSE vcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN vcursor;
      WHEN OTHERS THEN
         IF vcursor%ISOPEN
         THEN
            CLOSE vcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam, NULL, SQLCODE,
                                           SQLERRM);
         RETURN vcursor;
   END f_get_adm_recunif;

   /*************************************************************************
      11/06/2012 - 7. 0022327: MDP_A001-Consulta de recibos - 0115278
      Extrae la informaci¿n detallada del recibo por garant¿as.
      param in out mensajes  : Mensajes de error
      return                 : 0.- OK
                               1.- error
   *************************************************************************/
   FUNCTION f_get_datosrecibo_det(pcempres IN NUMBER,
                                  pnrecibo IN NUMBER,
                                  pcidioma IN NUMBER,
                                  mensajes OUT t_iax_mensajes)
      RETURN SYS_REFCURSOR IS
      vcursor  SYS_REFCURSOR;
      vnumerr  NUMBER;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(2000) := 'par¿metros - pcempres:' || pcempres ||
                                 ' pnrecibo: ' || pnrecibo ||
                                 ', pcidioma: ' || pcidioma;
      vobject  VARCHAR2(200) := 'PAC_IAX_ADM.f_get_datosrecibo_det';
   BEGIN
      IF pnrecibo IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vcursor := pac_md_adm.f_get_datosrecibo_det(pcempres, pnrecibo,
                                                  pcidioma, mensajes);
      RETURN vcursor;
   EXCEPTION
      WHEN e_param_error THEN
         IF vcursor%ISOPEN
         THEN
            CLOSE vcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN vcursor;
      WHEN OTHERS THEN
         IF vcursor%ISOPEN
         THEN
            CLOSE vcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam, NULL, SQLCODE,
                                           SQLERRM);
         RETURN vcursor;
   END f_get_datosrecibo_det;

   /**********************************************************************************************
      11/06/2012 - 7. 0022327: MDP_A001-Consulta de recibos - 0115278
      Extrae la informaci¿n de la tala de complementos de recibos (hist¿rico de acciones)
      pnrecibo     IN Recibo.
      pcidioma     IN C¿digo de idioma
   ************************************************************************************************/
   FUNCTION f_get_recibos_comp(pnrecibo IN NUMBER,
                               pcidioma IN NUMBER,
                               mensajes OUT t_iax_mensajes)
      RETURN SYS_REFCURSOR IS
      vcursor  SYS_REFCURSOR;
      vnumerr  NUMBER;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(2000) := 'par¿metros - pnrecibo: ' || pnrecibo ||
                                 ', pcidioma: ' || pcidioma;
      vobject  VARCHAR2(200) := 'PAC_IAX_ADM.f_get_recibos_comp';
   BEGIN
      IF pnrecibo IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vcursor := pac_md_adm.f_get_recibos_comp(pnrecibo, pcidioma, mensajes);
      RETURN vcursor;
   EXCEPTION
      WHEN e_param_error THEN
         IF vcursor%ISOPEN
         THEN
            CLOSE vcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN vcursor;
      WHEN OTHERS THEN
         IF vcursor%ISOPEN
         THEN
            CLOSE vcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam, NULL, SQLCODE,
                                           SQLERRM);
         RETURN vcursor;
   END f_get_recibos_comp;

   /*************************************************************************
      17/07/2012 - 0022760: MDP_A001- Gedox a recibos
      Extrae los documentos asociados al recibo
      param in out mensajes  : Mensajes de error
      return                 : 0.- OK
                               1.- error
   *************************************************************************/
   FUNCTION f_get_recdocs(pnrecibo IN NUMBER,
                          mensajes OUT t_iax_mensajes) RETURN SYS_REFCURSOR IS
      v_pasexec NUMBER(8) := 1;
      v_param   VARCHAR2(2000) := 'par¿metros - pnrecibo: ' || pnrecibo;
      v_object  VARCHAR2(200) := 'PAC_IAX_ADM.f_get_recdocs';
      vnumerr   NUMBER;
      vcursor   SYS_REFCURSOR;
   BEGIN
      v_pasexec := 1;

      IF pnrecibo IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vcursor := pac_md_adm.f_get_recdocs(pnrecibo, mensajes);
      RETURN vcursor;
   EXCEPTION
      WHEN OTHERS THEN
         IF vcursor%ISOPEN
         THEN
            CLOSE vcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001,
                                           v_pasexec, v_param, NULL, SQLCODE,
                                           SQLERRM);
         RETURN vcursor;
   END f_get_recdocs;

   /*************************************************************************
      17/07/2012 - 0022760: MDP_A001- Gedox a recibos
      Actualiza el contador de impresiones del recibo
      param in out mensajes  : Mensajes de error
      return                 : 0.- OK
                               1.- error
   *************************************************************************/
   FUNCTION f_set_docimp(pnrecibo IN NUMBER,
                         pndocume IN NUMBER,
                         mensajes OUT t_iax_mensajes) RETURN NUMBER IS
      v_pasexec NUMBER(8) := 1;
      v_param   VARCHAR2(2000) := 'par¿metros - pnrecibo: ' || pnrecibo;
      v_object  VARCHAR2(200) := 'PAC_IAX_ADM.f_set_docimp';
      vnumerr   NUMBER;
   BEGIN
      IF pnrecibo IS NULL OR
         pndocume IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_adm.f_set_docimp(pnrecibo, pndocume, mensajes);

      IF vnumerr <> 0
      THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005,
                                           v_pasexec, v_param);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000006,
                                           v_pasexec, v_param);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001,
                                           v_pasexec, v_param,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_set_docimp;

   --7 (9). 0022763: MDP_A001-Unificacion / Desunificacion de recibos - 0119028 - Inicio
   /*******************************************************************************
   FUNCION PAC_GESTION_REC.F_DESAGRUPARECIBO
   Funci¿n que realiza la desunificaci¿n de recibos y opcionalmente anula el recibo.
   Cuando el PFANULAC est¿ informado (IS NOT NULL).

   Par¿metros:
     param in pnrecunif : N¿mero del recibo agrupado
     param in pfanulac : Fecha de anulaci¿n
     param in pcidioma : C¿digo de idioma
     return: number un n¿mero con el id del error, en caso de que todo vaya OK, retornar¿ un cero.
   ********************************************************************************/
   FUNCTION f_desagruparecibo(pnrecunif IN CLOB,
                              pfanulac  IN DATE DEFAULT NULL,
                              pcidioma  IN NUMBER DEFAULT NULL,
                              mensajes  OUT t_iax_mensajes) RETURN NUMBER IS
      err         NUMBER := 0;
      vobjectname VARCHAR2(500) := 'PAC_IAX_ADM.F_DESAGRUPARECIBOS';
      vparam      VARCHAR2(500) := 'par¿metros - pnrecunif: ' || pnrecunif ||
                                   ' - pfanulac: ' || pfanulac ||
                                   ' - pcidioma: ' || pcidioma;
      vpasexec    NUMBER(5) := 1;
   BEGIN
      IF (pnrecunif IS NULL)
      THEN
         RAISE e_param_error;
      END IF;

      err := pac_md_adm.f_desagruparecibo(pnrecunif, pfanulac, pcidioma,
                                          mensajes);

      IF err <> 0
      THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN err;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005,
                                           vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006,
                                           vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, err,
                                           vpasexec, vparam, NULL, SQLCODE,
                                           SQLERRM);
         RETURN NULL;
   END f_desagruparecibo;

   -- 7 (9). 0022763: MDP_A001-Unificacion / Desunificacion de recibos - 0119028 - Fin

   --  9.0       0026295: RSA702-Desarrollar el modulo de Caja
   FUNCTION f_get_consrecibos_multimoneda(pcempres IN NUMBER, -- La empresa se recoge de una variable global del contexto
                                          pnrecibo IN NUMBER, -- Si se informa por pantalla sino NULL
                                          pnpoliza IN NUMBER, -- Si se informa por pantalla sino NULL
                                          pitem    IN NUMBER, -- Si se informa por pantalla sino NULL
                                          pcestrec IN NUMBER, -- Siempre 0
                                          pcmonpag IN NUMBER, -- Moneda en que se va a pagar
                                          ptipo    IN NUMBER, -- Si se informa por pantalla sino NULL. Debe aparecer en la pantalla 1-Contratante 2-Riesgos 3-Pagador (poner check en pantalla como en cobro manual de recibos)
                                          psperson IN NUMBER, -- Si se informa por pantalla sino NULL
                                          pcidioma IN NUMBER,
                                          pfemisio IN DATE DEFAULT NULL,
                                          mensajes OUT t_iax_mensajes)
      RETURN SYS_REFCURSOR IS
      vcursor  SYS_REFCURSOR;
      vnumerr  NUMBER;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(2000) := NULL;
      vobject  VARCHAR2(200) := 'PAC_IAX_ADM.f_Get_Consrecibos_Multimoneda';
   BEGIN
      --Recuperaci¿n de los recibos.
      vcursor := pac_md_adm.f_get_consrecibos_multimoneda(pcempres, pnrecibo,
                                                          pnpoliza, pitem,
                                                          pcestrec, pcmonpag,
                                                          ptipo, psperson,
                                                          pcidioma, pfemisio,
                                                          mensajes);
      --Tot ok
      RETURN vcursor;
   EXCEPTION
      WHEN e_param_error THEN
         IF vcursor%ISOPEN
         THEN
            CLOSE vcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN vcursor;
      WHEN OTHERS THEN
         IF vcursor%ISOPEN
         THEN
            CLOSE vcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam, NULL, SQLCODE,
                                           SQLERRM);
         RETURN vcursor;
   END f_get_consrecibos_multimoneda;
   -- INI SGM 13. IAXIS-4134 Reporte de acuerdo de pago
FUNCTION f_get_recibos_saldos(
          pnpoliza IN NUMBER,
          cur OUT sys_refcursor,
          mensajes OUT t_iax_mensajes)
     RETURN NUMBER
IS
     err         NUMBER := 0;
     vpasexec NUMBER(8) := 1;
     vobject  VARCHAR2 (500) := 'PAC_IAX_ADM.f_get_recibos_saldos';
     vparam   VARCHAR2 (500) := 'parámetros - pnpoliza' || pnpoliza;

BEGIN
     err := pac_md_adm.f_get_recibos_saldos(pnpoliza,cur,mensajes);
     vpasexec := 2;
     RETURN err;
EXCEPTION
WHEN OTHERS THEN
     pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, psqcode =>
     SQLCODE, psqerrm => SQLERRM);
     IF cur%ISOPEN THEN
          CLOSE cur;
     END IF;
     RETURN err;
END f_get_recibos_saldos;
   -- FIN SGM 13. IAXIS-4134 Reporte de acuerdo de pago
--
-- Inicio IAXIS-3651 09/07/2019 
--
/*************************************************************************
FUNCION f_calcula_comisiones
Funcion para calcular las comisiones del outsourcing por recibo gestionado
param in pnrecibo :  Número de recibo
return            :  0 indica comisión calculada correctamente. 
                 <> 0 Proceso incorrecto.
*************************************************************************/     
FUNCTION f_calcula_comisiones (pnrecibo IN NUMBER,
                              mensajes OUT t_iax_mensajes)
    RETURN NUMBER IS
    vsquery        VARCHAR2(5000);
    vobjectname    VARCHAR2(500) := 'pac_iax_adm.f_calcula_comisiones';
    vparam         VARCHAR2(1000);
    vpasexec       NUMBER(5) := 1;
    vnumerr        NUMBER(8) := 0;
 BEGIN

    vnumerr := pac_md_adm.f_calcula_comisiones(pnrecibo,mensajes);

    IF vnumerr <> 0 THEN
       RAISE e_object_error;
    END IF;

    COMMIT;
    RETURN 0;
 EXCEPTION
    WHEN e_param_error THEN
       pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
       ROLLBACK;
       RETURN 1;
    WHEN e_object_error THEN
      pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
       ROLLBACK;
       RETURN 1;
    WHEN OTHERS THEN
      pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                        NULL, SQLCODE, SQLERRM);
       ROLLBACK;
       RETURN 1;
 END f_calcula_comisiones;   
/*************************************************************************
 FUNCION f_get_info_pagos_out
 Funcion para obtener la información por orden de pago para cada outsourcing
 param in pnnumide :  Outsourcing
 param in pnnumord :  Número de orden de pago
 return            :  0 indica comisión calculada correctamente. 
                   <> 0 Proceso incorrecto.
 *************************************************************************/
--       
 FUNCTION f_get_info_pagos_out(pnnumide IN VARCHAR2,
                               pnnumord IN NUMBER, 
                               mensajes OUT t_iax_mensajes)
    RETURN SYS_REFCURSOR IS
    vcursor  SYS_REFCURSOR;
    vnumerr  NUMBER;
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := NULL;
    vobject  VARCHAR2(200) := 'PAC_IAX_ADM.f_get_info_pagos_out';
 BEGIN
    -- Recuperaciòn de pagos por outsourcing
    vcursor := pac_md_adm.f_get_info_pagos_out(pnnumide, pnnumord, mensajes);
    --
    RETURN vcursor;
 EXCEPTION
    WHEN e_param_error THEN
       IF vcursor%ISOPEN
       THEN
          CLOSE vcursor;
       END IF;

       pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                         vpasexec, vparam);
       RETURN vcursor;
    WHEN OTHERS THEN
       IF vcursor%ISOPEN
       THEN
          CLOSE vcursor;
       END IF;

       pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                         vpasexec, vparam, NULL, SQLCODE,
                                         SQLERRM);
       RETURN vcursor;
 END f_get_info_pagos_out;
 /*************************************************************************
 FUNCION f_set_info_pago_out
 Funcion para actualizar la información por orden de pago para cada outsourcing
 param in pnnumord :  Número de orden de pago
 param in pcesterp :  Estado pago ERP
 param in pnprcerp :  Número de proceso ERP
 param in pffecpagerp :  Fecha de pago ERP
 param in pivalpagerp :  Valor pago ERP
 return            :  0 indica comisión calculada correctamente. 
                   <> 0 Proceso incorrecto.
 *************************************************************************/
 FUNCTION f_set_info_pago_out(pnnumord    IN NUMBER, 
                              pcesterp    IN NUMBER, 
                              pnprcerp    IN NUMBER, 
                              pffecpagerp IN DATE, 
                              pivalpagerp IN NUMBER, 
                              mensajes    OUT t_iax_mensajes)
    RETURN NUMBER IS
    vobjectname    VARCHAR2(500) := 'pac_iax_adm.f_set_info_pago_out';
    vparam      VARCHAR2(500) := 'parámetros - pnnumord: ' || pnnumord || ' - pcesterp '||pcesterp
                            || ' - pnprcerp '||pnprcerp|| ' - pffecpagerp '||pffecpagerp|| ' - pivalpagerp '||pivalpagerp ;
    vpasexec       NUMBER(5) := 1;
    vnumerr        NUMBER(8) := 0;
 BEGIN

    IF pnnumord IS NULL 
      OR pcesterp IS NULL 
      OR pnprcerp IS NULL
      OR pffecpagerp IS NULL
      OR pivalpagerp IS NULL 
    THEN
      RAISE e_param_error;
    END IF;   
 
    vnumerr := pac_md_adm.f_set_info_pago_out(pnnumord, pcesterp, pnprcerp, pffecpagerp, pivalpagerp, mensajes);

    IF vnumerr <> 0 THEN
       RAISE e_object_error;
    END IF;

    COMMIT;
    RETURN 0;
 EXCEPTION
    WHEN e_param_error THEN
       pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
       ROLLBACK;
       RETURN 1;
    WHEN e_object_error THEN
      pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
       ROLLBACK;
       RETURN 1;
    WHEN OTHERS THEN
      pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                        NULL, SQLCODE, SQLERRM);
       ROLLBACK;
       RETURN 1;
 END f_set_info_pago_out;
 --
 -- Fin IAXIS-3651 09/07/2019
 --   
 --
 -- Inicio IAXIS-3591 17/07/2019
 --
 /*************************************************************************
  FUNCION f_get_info_coa
  Funcion para obtener los importes distribuidos en las compañías aceptantes 
  param in pnnrecibo :  Número de recibo
  return             :  Cursor con compañías aceptantes y sus respectivos importes.
 *************************************************************************/
 --       
 FUNCTION f_get_info_coa(pnrecibo IN NUMBER,
                         mensajes OUT t_iax_mensajes)
    RETURN SYS_REFCURSOR IS
    vcursor  SYS_REFCURSOR;
    vnumerr  NUMBER;
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := NULL;
    vobject  VARCHAR2(200) := 'PAC_IAX_ADM.f_get_info_coa';
 BEGIN
    IF pnrecibo IS NULL 
    THEN
      RAISE e_param_error;
    END IF;   
    -- Recuperación de pagos por outsourcing
    vcursor := pac_md_adm.f_get_info_coa(pnrecibo, mensajes);
    --
    RETURN vcursor;
 EXCEPTION
    WHEN e_param_error THEN
       IF vcursor%ISOPEN
       THEN
          CLOSE vcursor;
       END IF;

       pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                         vpasexec, vparam);
       RETURN vcursor;
    WHEN OTHERS THEN
       IF vcursor%ISOPEN
       THEN
          CLOSE vcursor;
       END IF;

       pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                         vpasexec, vparam, NULL, SQLCODE,
                                         SQLERRM);
       RETURN vcursor;
 END f_get_info_coa;  
 --
 -- Fin IAXIS-3591 17/07/2019
 --
END pac_iax_adm;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_ADM" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_ADM" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_ADM" TO "PROGRAMADORESCSI";