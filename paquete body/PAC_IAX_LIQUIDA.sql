--------------------------------------------------------
--  DDL for Package Body PAC_IAX_LIQUIDA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IAX_LIQUIDA" AS
/******************************************************************************
   NOMBRE:       PAC_IAX_LIQUIDA
   PROPÓSITO:    Contiene las funciones para la liquidación de comisiones

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        26/05/2009   JRB                1. Creación del package.
   2.0        03/12/2009   SVJ                2. Modificación del package para incluir nuevas módulo
   3.0        03/05/2010   JTS                3. 0014301: APR707 - conceptos fiscales o no fiscales
   4.0        05/05/2010   MCA                4. 0014344: Incorporar a transferencias los pagos de liquidación de comisiones
   5.0        14/07/2011   ICV                5. 0018843: LCOL003 - Liquidación de comisiones
   6.0        22/09/2011   JMP                6. 0019197: LCOL_A001-Liquidacion de comisiones para colombia: sucursal/ADN y corte de cuentas (por el liquido)
   7.0        15/11/2011   JMF                7. 0020164: LCOL_A001-Liquidar solo a los agentes de tipo liquidacion por corte de cuenta o por el total
******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

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
      RETURN t_iax_recibos IS
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(200)
         := 'P_cempres = ' || p_cempres || ', P_sproduc = ' || p_sproduc || ', P_npoliza = '
            || p_npoliza || ', P_cagente = ' || p_cagente;
      v_object       VARCHAR2(200) := 'PAC_IAX_LIQUIDA.f_consultarecibos';
      v_recibos      t_iax_recibos;
      v_error        NUMBER(8) := 0;
   BEGIN
      v_recibos := pac_md_liquida.f_consultarecibos(p_cempres, p_sproduc, p_npoliza,
                                                    p_cagente, p_femiini, p_femifin,
                                                    p_fefeini, p_fefefin, p_fcobini,
                                                    p_fcobfin, mensajes);
      v_pasexec := 2;
      v_error := f_liquida(v_recibos, mensajes);

      IF v_error <> 0 THEN
         RETURN NULL;
      END IF;

      RETURN v_recibos;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005, v_pasexec, v_param);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000006, v_pasexec, v_param);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           NULL, SQLCODE, SQLERRM);
         RETURN NULL;
   END f_consultarecibos;

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
      RETURN NUMBER IS
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(200)
         := 'p_nrecibo = ' || p_nrecibo || ' p_smovrec = ' || p_smovrec || ' p_liqselec = '
            || p_liqselec;
      v_object       VARCHAR2(200) := 'PAC_IAX_LIQUIDA.f_setobjetorecliqui';
      v_error        NUMBER(8);
      trobat         BOOLEAN := FALSE;
      v_index        NUMBER := 0;
   BEGIN
      IF p_nrecibo IS NULL
         OR p_smovrec IS NULL
         OR p_liqselec IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF vselrecliq IS NOT NULL THEN
         FOR i IN vselrecliq.FIRST .. vselrecliq.LAST LOOP
            IF vselrecliq(i).nrecibo = p_nrecibo THEN   -- Si el trobem, el modifiq
               vselrecliq(i).smovrec := p_smovrec;
               vselrecliq(i).nrecibo := p_nrecibo;
               vselrecliq(i).cselecc := 1;
               vselrecliq(i).cestado := NVL(p_liqselec, 0);
               trobat := TRUE;
            END IF;
         END LOOP;
      ELSE
         vselrecliq := t_iax_selrecliq();
      END IF;

      v_pasexec := 2;

      IF trobat = FALSE THEN
         vselrecliq.EXTEND;
         v_index := vselrecliq.LAST;
         vselrecliq(v_index) := ob_iax_selrecliq();
         vselrecliq(v_index).smovrec := p_smovrec;
         vselrecliq(v_index).nrecibo := p_nrecibo;
         vselrecliq(v_index).cselecc := 1;
         vselrecliq(v_index).cestado := NVL(p_liqselec, 0);
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005, v_pasexec, v_param);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000006, v_pasexec, v_param);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_setobjetorecliqui;

   FUNCTION f_set_recliqui(mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(200);
      v_object       VARCHAR2(200) := 'PAC_IAX_LIQUIDA.f_set_recliqui';
      v_error        NUMBER(8);
   BEGIN
      v_error := pac_md_liquida.f_set_recliqui(vselrecliq, mensajes);

      IF v_error <> 0 THEN
         RAISE e_object_error;
      ELSE
         COMMIT;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005, v_pasexec, v_param);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000006, v_pasexec, v_param,
                                           v_error);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_set_recliqui;

   /*************************************************************************
        Función que devuelve el objeto persistente
        param out mensajes    : mensajes de error
        return                : t_iax_selrecliq
     *************************************************************************/
   FUNCTION f_get_recliqui(mensajes OUT t_iax_mensajes)
      RETURN t_iax_selrecliq IS
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(200);
      v_object       VARCHAR2(200) := 'PAC_IAX_LIQUIDA.f_get_recliqui';
      v_error        NUMBER(8);
   BEGIN
      RETURN vselrecliq;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005, v_pasexec, v_param);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000006, v_pasexec, v_param,
                                           v_error);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           NULL, SQLCODE, SQLERRM);
         RETURN NULL;
   END f_get_recliqui;

   /*************************************************************************
      Funcion que se encargará de inicializar el objeto persistente.
      param in  p_recibos   : Objeto recibos
      param out mensajes    : Mensajes de error
      return                : 0.-    OK
                                1.-    KO
   *************************************************************************/
   FUNCTION f_liquida(p_recibos IN t_iax_recibos, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(200) := NULL;
      v_object       VARCHAR2(200) := 'PAC_IAX_LIQUIDA.f_liquida';
      v_error        NUMBER(8) := 0;
   BEGIN
      IF p_recibos IS NULL THEN
         RAISE e_param_error;
      END IF;

      v_pasexec := 2;

      IF p_recibos.COUNT = 0 THEN
         RETURN 1;
      END IF;

      v_pasexec := 3;

      FOR i IN p_recibos.FIRST .. p_recibos.LAST LOOP
         v_error := f_setobjetorecliqui(p_recibos(i).nrecibo,
                                        p_recibos(i).movrecibo(i).smovrec, 1, mensajes);
      END LOOP;

      RETURN v_error;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005, v_pasexec, v_param);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000006, v_pasexec, v_param);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_liquida;

   /*************************************************************************
      Procedimiento que automatiza la liquidación de recibos.
   *************************************************************************/
   PROCEDURE p_liquida_mens IS
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(200) := NULL;
      v_object       VARCHAR2(200) := 'PAC_IAX_LIQUIDA.p_liquida_mens';
      v_error        NUMBER(8);
      mensajes       t_iax_mensajes;
      v_recibos      t_iax_recibos;
   BEGIN
      v_recibos := t_iax_recibos();
      v_recibos := f_consultarecibos(f_parinstalacion_n('EMPRESADEF'), NULL, NULL, NULL, NULL,
                                     NULL, NULL, NULL, NULL, NULL, mensajes);
      v_pasexec := 2;
      v_error := f_set_recliqui(mensajes);
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005, v_pasexec, v_param);
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000006, v_pasexec, v_param);
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           NULL, SQLCODE, SQLERRM);
   END p_liquida_mens;

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
      RETURN NUMBER IS
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(200)
                          := 'params : pcempres : ' || pcempres || ', pcagente : ' || pcagente;
      v_object       VARCHAR2(200) := 'PAC_IAX_LIQUIDA.f_get_saldoagente';
      v_error        NUMBER(8);
   BEGIN
      v_error := pac_md_liquida.f_get_saldoagente(pcempres, pcagente, psaldo, mensajes);

      IF v_error <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005, v_pasexec, v_param);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000006, v_pasexec, v_param,
                                           v_error);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_get_saldoagente;

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
      RETURN NUMBER IS
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(200) := 'params : pcagente : ' || pcagente;
      v_object       VARCHAR2(200) := 'PAC_IAX_LIQUIDA.f_get_ctas';
      v_error        NUMBER(8);
   BEGIN
      v_error := pac_md_liquida.f_get_ctas(pcagente, pcurcuentastec, mensajes);

      IF v_error <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         IF pcurcuentastec%ISOPEN THEN
            CLOSE pcurcuentastec;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005, v_pasexec, v_param);
         RETURN 1;
      WHEN e_object_error THEN
         IF pcurcuentastec%ISOPEN THEN
            CLOSE pcurcuentastec;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000006, v_pasexec, v_param,
                                           v_error);
         RETURN 1;
      WHEN OTHERS THEN
         IF pcurcuentastec%ISOPEN THEN
            CLOSE pcurcuentastec;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_get_ctas;

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
      RETURN NUMBER IS
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(200)
         := 'params : pcempres : ' || pcempres || ', pcagente : ' || pcagente
            || ', pnnumlin : ' || pnnumlin;
      v_object       VARCHAR2(200) := 'PAC_IAX_LIQUIDA.f_del_ctas';
      v_error        NUMBER(8);
   BEGIN
      v_error := pac_md_liquida.f_del_ctas(pcempres, pcagente, pnnumlin, mensajes);

      IF v_error <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005, v_pasexec, v_param);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000006, v_pasexec, v_param,
                                           v_error);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           NULL, SQLCODE, SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_del_ctas;

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
      RETURN NUMBER IS
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(200)
         := 'params : pcempres : ' || pcempres || ', pcagente : ' || pcagente
            || ', pnnumlin : ' || pnnumlin;
      v_object       VARCHAR2(200) := 'PAC_IAX_LIQUIDA.f_del_ctas';
      v_error        NUMBER(8);
   BEGIN
      v_error := pac_md_liquida.f_get_datos_cta(pcempres, pcagente, pnnumlin, pcurdetcuent,
                                                mensajes);

      IF v_error <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005, v_pasexec, v_param);

         IF pcurdetcuent%ISOPEN THEN
            CLOSE pcurdetcuent;
         END IF;

         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000006, v_pasexec, v_param,
                                           v_error);

         IF pcurdetcuent%ISOPEN THEN
            CLOSE pcurdetcuent;
         END IF;

         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           NULL, SQLCODE, SQLERRM);

         IF pcurdetcuent%ISOPEN THEN
            CLOSE pcurdetcuent;
         END IF;

         RETURN 1;
   END f_get_datos_cta;

   /*************************************************************************
       Función que insertará o modificará una cuenta técnica de un agente en función del pmodo
       param in  pcempres    : código empresa
       param in  pcagente    : código de agente
       param in  pnnumlin    : numero linea
       param in pCDEBHAB    : Codigo debe o haber
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
      RETURN NUMBER IS
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(500)
         := 'params : pcempres : ' || pcempres || ', pcagente : ' || pcagente
            || ', pnnumlin : ' || pnnumlin || ' , pcimporte : ' || pcdebhab || ', pndocume : '
            || pndocume || ', ptdescrip : ' || ptdescrip || ', pmodo : ' || pmodo
            || ', pnrecibo : ' || pnrecibo || ' , pnsinies : ' || pnsinies || ', pcconcepto :'
            || pcconcepto || ', pffecmov : ' || pffecmov || ', pcfiscal : ' || pcfiscal;
      v_object       VARCHAR2(200) := 'PAC_IAX_LIQUIDA.f_set_cta';
      v_error        NUMBER(8);
   BEGIN
      v_error := pac_md_liquida.f_set_cta(pcempres, pcagente, psseguro, pnnumlin, pcdebhab,
                                          pimporte, pndocume, ptdescrip, pmodo, pnrecibo,
                                          pnsinies, pcconcepto, pffecmov, pfvalor, pcfiscal,
                                          mensajes);

      IF v_error <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005, v_pasexec, v_param);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000006, v_pasexec, v_param,
                                           v_error);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           NULL, SQLCODE, SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_set_cta;

   /******************************************************************
      Función que nos devuelve el sseguro pasandole el npoliza y ncertificado
        param in pnpoliza: num poliza
        param in pncertif: num certif
        param in PTABLAS : taula 'SOL','EST'...
        param out psseguro: sseguro
        param out mensajes
        RETURN               : 0-ok : 1-error
    /*****************************************************************/
   FUNCTION f_get_sseguro(
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      ptablas IN VARCHAR2,
      psseguro OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(200)
         := 'params : pnpoliza : ' || pnpoliza || ', pncertif : ' || pncertif
            || ', ptablas : ' || ptablas;
      v_object       VARCHAR2(200) := 'PAC_IAX_LIQUIDA.f_get_sseguro';
      v_error        NUMBER(8);
   BEGIN
      v_error := pac_md_liquida.f_get_sseguro(pnpoliza, pncertif, ptablas, psseguro, mensajes);

      IF v_error <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005, v_pasexec, v_param);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000006, v_pasexec, v_param,
                                           v_error);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_get_sseguro;

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
      RETURN NUMBER IS
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
      RETURN NUMBER IS
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(200)
         := 'params : pcagente : ' || pcagente || ', pcempres : ' || pcempres || ', pmodo : '
            || pmodo;
      v_object       VARCHAR2(200) := 'PAC_IAX_LIQUIDA.f_liquidaliq';
      v_error        NUMBER(8);
   BEGIN
      v_error := pac_md_liquida.f_liquidaliq(pcagente, pcempres, pmodo, pfecliq, psproces,
                                             pruta, mensajes, psucursal, padnsuc, pcliquido);

      IF v_error <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005, v_pasexec, v_param);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000006, v_pasexec, v_param,
                                           v_error);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_liquidaliq;

   /******************************************************************
      Función que recuperará el mes de lcartera anterior de la empresa recibida por parámetro
        param in pcempres: codi empresa
        param out mensajes
        RETURN               : 0-ok : 1-error
    /*****************************************************************/
   FUNCTION f_get_mescarant(pcempres IN NUMBER, pmes OUT NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(200) := 'params : pcempres : ' || pcempres;
      v_object       VARCHAR2(200) := 'PAC_IAX_LIQUIDA.f_get_mescarant';
      v_error        NUMBER(8);
   BEGIN
      v_error := pac_md_liquida.f_get_mescarant(pcempres, pmes, mensajes);

      IF v_error <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005, v_pasexec, v_param);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000006, v_pasexec, v_param,
                                           v_error);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_get_mescarant;

   /******************************************************************
      Función que recuperará el año de lcartera anterior de la empresa recibida por parámetro
        param in pcempres: codi empresa
        param out mensajes
        RETURN               : 0-ok : 1-error
    /*****************************************************************/
   FUNCTION f_get_anyocarant(pcempres IN NUMBER, panyo OUT NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(200) := 'params : pcempres : ' || pcempres;
      v_object       VARCHAR2(200) := 'PAC_IAX_LIQUIDA.f_get_anyocarant';
      v_error        NUMBER(8);
   BEGIN
      v_error := pac_md_liquida.f_get_anyocarant(pcempres, panyo, mensajes);

      IF v_error <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005, v_pasexec, v_param);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000006, v_pasexec, v_param,
                                           v_error);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_get_anyocarant;

   /*************************************************************************
       Función que devuelve la query a ejecutar para saber el dia inicio de liquidacion

       pctipo IN NUMBER
       RETURN VARCHAR2
   *************************************************************************/
   FUNCTION f_get_feciniliq(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(200) := 'params : pctipo : ';
      v_object       VARCHAR2(200) := 'PAC_IAX_LIQUIDA.f_get_feciniliq';
      v_error        NUMBER(8);
      v_cursor       sys_refcursor;
   BEGIN
      v_error := pac_md_liquida.f_get_feciniliq(v_cursor, mensajes);

      IF v_error <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN v_cursor;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005, v_pasexec, v_param);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000006, v_pasexec, v_param,
                                           v_error);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           NULL, SQLCODE, SQLERRM);
         RETURN NULL;
   END f_get_feciniliq;

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
      RETURN sys_refcursor IS
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(200)
         := 'params : pmodo : ' || pmodo || ' pfecliq : ' || pfecliq || ' pcempres : '
            || pcempres;
      v_object       VARCHAR2(200) := 'PAC_IAX_LIQUIDA.f_get_proc_cierres_liq';
      v_error        NUMBER(8);
      v_squery       VARCHAR2(2000);
      v_cursor       sys_refcursor;
   BEGIN
      v_error := pac_md_liquida.f_get_proc_cierres_liq(pmodo, pfecliq, pcempres, v_cursor,
                                                       mensajes);

      IF v_error <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN v_cursor;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005, v_pasexec, v_param);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000006, v_pasexec, v_param,
                                           v_error);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           NULL, SQLCODE, SQLERRM);
         RETURN NULL;
   END f_get_proc_cierres_liq;
END pac_iax_liquida;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_LIQUIDA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_LIQUIDA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_LIQUIDA" TO "PROGRAMADORESCSI";
