--------------------------------------------------------
--  DDL for Package Body PAC_MD_LIQUIDA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MD_LIQUIDA" AS
/******************************************************************************
   NOMBRE:      PAC_MD_LIQUIDA
   PROPÓSITO: Funciones para la liquidación de comisiones

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        27/05/2009   JRB                1. Creación del package.
   2.0        03/12/2009   SVJ                2. Modificación del package para incluir nuevas módulo
   3.0        03/05/2010   JTS                3. 0014301: APR707 - conceptos fiscales o no fiscales
   4.0        05/05/2010   MCA                4. 0014344: Incorporar a transferencias los pagos de liquidación de comisiones
   5.0        14/07/2011   ICV                5. 0018843: LCOL003 - Liquidación de comisiones
   6.0        22/09/2011   JMP                6. 0019197: LCOL_A001-Liquidacion de comisiones para colombia: sucursal/ADN y corte de cuentas (por el liquido)
   7.0        15/11/2011   JMF                7. 0020164: LCOL_A001-Liquidar solo a los agentes de tipo liquidacion por corte de cuenta o por el total
   8.0        26/11/2011   JMC                8. 0020169: AGM003-Liquidar a nivel superior del agente de producción.
   9.0        26/03/2012   JMC                9. 0021725: MDP - COM - Liquidación a nivel de mediador
  10.0        24/04/2012   APD               10. 0022065: LCOL_A001: Previo de liquidaciones
  11.0        22/05/2012   JMC               11. 0022337: AGM - Descuadre en la liquidación de comisiones
  12.0        13/06/2012   DCG               12. 0022414: LCOL_A001: Pantalla liquidacions, validació de la data de liquidació
  13.0        20/12/2012   JMF               0025198 LCOL_A001-LCOL Pantalla de liquidaciones
  14.0        24/12/2013   DCT               13. 0025841: LCOL_A003-Error al reimprimir una liquidacion ya realizada (añadir en la validación psproces IS NULL THEN)
  15.0        05/02/2013   AMJ               14. 0025910: LCOL: Enviament de correu en el proc?s de liquidaci?
  16.0        22/03/2013   JMF               0026398: LCOL_A003-LCOL: Proceso de liquidaci?n
  17.0        26/11/2013   FAL               17. 0029023: AGM800 - Agrupación de pago al grupo coordinación
  18.0        10/12/2015   AFM               18. Liquida por agente clave. 1.- Liquida todo agente clave. 2.- Liquida cada agente de la agrupación.

******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   /*************************************************************************
       Función que seleccionará los recibos que se tienen que liquidar
       param in P_cempres    : código empresa.
       param in P_sproduc    : Producto.
       param in P_npoliza    : Póliza.
       param in P_cagente    : Agente.
       param in P_femiini    : Fecha inicio emisión.
       param in P_femifin    : Fecha fin emisión.
       param in P_fefeini    : Fecha inicio efecto.
       param in P_fefefin    : Fecha fin efecto.
       param in P_fcobini    : Fecha inicio cobro.
       param in P_fcobfin    : Fecha fin cobro.
       param in/out mensajes : mensajes de error
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
      mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_recibos IS
      v_squery       VARCHAR2(10000);
      v_cur          sys_refcursor;
      v_rebuts       t_iax_recibos := t_iax_recibos();
      v_rebut        ob_iax_recibos := ob_iax_recibos();
      v_movrecs      t_iax_movrecibo := t_iax_movrecibo();
      v_movrec       ob_iax_movrecibo := ob_iax_movrecibo();
      v_detrecs      t_iax_detrecibo := t_iax_detrecibo();
      v_detrec       ob_iax_detrecibo := ob_iax_detrecibo();
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(200)
         := 'P_cempres = ' || p_cempres || ', P_sproduc = ' || p_sproduc || ', P_npoliza = '
            || p_npoliza || ', P_cagente = ' || p_cagente;
      v_object       VARCHAR2(200) := 'PAC_MD_LIQUIDA.f_consultarecibos';
      v_error        NUMBER(8) := 0;
   BEGIN
      IF p_cempres IS NULL THEN
         RAISE e_param_error;
      END IF;

      v_pasexec := 2;
      v_squery := pac_liquida.f_consultarecibos(p_cempres, p_sproduc, p_npoliza, p_cagente,
                                                p_femiini, p_femifin, p_fefeini, p_fefefin,
                                                p_fcobini, p_fcobfin,
                                                pac_md_common.f_get_cxtidioma);
      v_pasexec := 3;
      v_cur := pac_md_listvalores.f_opencursor(v_squery, mensajes);
      v_pasexec := 4;

      LOOP
         FETCH v_cur
          INTO v_rebut.nrecibo, v_rebut.cagente, v_rebut.sseguro, v_rebut.cempres,
               v_movrec.smovrec, v_movrec.fefeadm, v_rebut.fefecto, v_rebut.femisio,
               v_rebut.cgescob, v_detrec.tconcep;

         EXIT WHEN v_cur%NOTFOUND;
         v_pasexec := 5;
         v_movrecs.EXTEND;
         v_movrecs(v_movrecs.LAST) := v_movrec;
         v_movrec := ob_iax_movrecibo();
         v_detrecs.EXTEND;
         v_detrecs(v_detrecs.LAST) := v_detrec;
         v_detrec := ob_iax_detrecibo();
         v_rebut.movrecibo := v_movrecs;
         v_pasexec := 6;

         IF f_cestrec(v_rebut.nrecibo, f_sysdate) IS NOT NULL THEN
            v_rebut.testrec :=
               pac_md_listvalores.f_getdescripvalor
                        ('select tatribu from detvalores where cvalor = 1  and catribu = '
                         || f_cestrec(v_rebut.nrecibo, f_sysdate) || ' and cidioma = '
                         || pac_md_common.f_get_cxtidioma,
                         mensajes);
            v_pasexec := 7;
         ELSE
            v_rebut.testrec := '';
            v_pasexec := 8;
         END IF;

         v_rebut.detrecibo := v_detrecs;
         v_pasexec := 9;
         v_rebut.tagente := f_desagente_t(v_rebut.cagente);
         v_pasexec := 10;

         SELECT itotalr, icombru
           INTO v_rebut.importe, v_rebut.icomisi
           FROM vdetrecibos
          WHERE nrecibo = v_rebut.nrecibo;

         v_pasexec := 11;
         v_rebuts.EXTEND;
         v_rebuts(v_rebuts.LAST) := v_rebut;
         v_rebut := ob_iax_recibos();
         v_pasexec := 12;
      END LOOP;

      v_pasexec := 13;

      CLOSE v_cur;

      v_pasexec := 14;
      RETURN v_rebuts;
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
        Función que insertará los recibos que forman la liquidación
        param in  p_selrecliq : Coleccion T_IAX_SelRecLiq
        param out mensajes    : mensajes de error
        return                : NUMBER 0 / 1

   *************************************************************************/
   FUNCTION f_set_recliqui(p_selrecliq IN t_iax_selrecliq, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_objectname   VARCHAR2(500) := 'PAC_MD_LIQUIDA.f_set_RecLiqui';
      v_param        VARCHAR2(500) := 'parámetros - ';
      v_pasexec      NUMBER(5) := 1;
      v_numerr       NUMBER(8) := 0;
      v_sproliq      NUMBER;
      v_primero      BOOLEAN := FALSE;
   BEGIN
      FOR i IN p_selrecliq.FIRST .. p_selrecliq.LAST LOOP
         IF p_selrecliq(i).cselecc = 1 THEN
            v_pasexec := 2;

            IF v_primero = FALSE THEN
               SELECT sproliq.NEXTVAL
                 INTO v_sproliq
                 FROM DUAL;

               v_primero := TRUE;
               v_pasexec := 3;
            END IF;

            -- v_numerr := pac_liquida.f_set_recliqui(p_selrecliq(i).nrecibo,
                                                   -- p_selrecliq(i).smovrec, v_sproliq, 1, 0);  DE MOMENTO LO COMENTO!!!!!!!
            v_pasexec := 4;

            IF v_numerr <> 0 THEN
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, v_numerr);
               RAISE e_object_error;
            END IF;
         END IF;
      END LOOP;

      v_pasexec := 5;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_objectname, 1000005, v_pasexec,
                                           v_param);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_objectname, 1000006, v_pasexec,
                                           v_param, v_numerr);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_objectname, 1000001, v_pasexec,
                                           v_param, NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_set_recliqui;

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
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(200)
                          := 'params : pcempres : ' || pcempres || ', pcagente : ' || pcagente;
      v_object       VARCHAR2(200) := 'PAC_MD_LIQUIDA.f_get_saldoagente';
      v_error        NUMBER(8);
   BEGIN
      v_error := pac_liquida.f_get_saldoagente(pcempres, pcagente, psaldo);

      IF v_error <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, v_error);
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
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(200) := 'params : pcagente : ' || pcagente;
      v_object       VARCHAR2(200) := 'PAC_md_LIQUIDA.f_get_ctas';
      v_error        NUMBER(8);
      vsquery        VARCHAR2(3000);
   BEGIN
      IF pcagente IS NULL THEN
         RAISE e_param_error;
      END IF;

      v_error := pac_liquida.f_get_ctas(pcagente, pac_md_common.f_get_cxtidioma, vsquery);

      IF v_error <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, v_error);
         RAISE e_object_error;
      END IF;

      pcurcuentastec := pac_iax_listvalores.f_opencursor(vsquery, mensajes);

      IF pac_md_log.f_log_consultas(vsquery, 'PAC_MD_liquida.f_get_ctas', 2, 0, mensajes) <> 0 THEN
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
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(200)
         := 'params : pcempres : ' || pcempres || ', pcagente : ' || pcagente
            || ', pnnumlin : ' || pnnumlin;
      v_object       VARCHAR2(200) := 'PAC_md_LIQUIDA.f_del_ctas';
      v_error        NUMBER(8);
   BEGIN
      v_error := pac_liquida.f_del_ctas(pcempres, pcagente, pnnumlin);

      IF v_error <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, v_error);
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
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(200)
         := 'params : pcempres : ' || pcempres || ', pcagente : ' || pcagente
            || ', pnnumlin : ' || pnnumlin;
      v_object       VARCHAR2(200) := 'PAC_md_LIQUIDA.f_get_datos_cta';
      v_error        NUMBER(8);
      vsquery        VARCHAR2(4000);
   BEGIN
      IF pcempres IS NULL
         OR pcagente IS NULL
         OR pnnumlin IS NULL THEN
         RAISE e_param_error;
      END IF;

      v_error := pac_liquida.f_get_datos_cta(pcempres, pcagente, pnnumlin,
                                             pac_md_common.f_get_cxtidioma, vsquery);

      IF v_error <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, v_error);
         RAISE e_object_error;
      END IF;

      pcurdetcuent := pac_iax_listvalores.f_opencursor(vsquery, mensajes);

      IF pac_md_log.f_log_consultas(vsquery, 'PAC_MD_liquida.f_get_ctas', 2, 0, mensajes) <> 0 THEN
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
       param in pcimporte    : Codigo debe o haber
       param in pimporte     : Importe
       param in pndocume     : numero documento
       param in ptdescrip    : Texto
       param in pmodo        : 0-Modificación, 1-Inserción
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
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(500)
         := 'params : pcempres : ' || pcempres || ', pcagente : ' || pcagente
            || ', pnnumlin : ' || pnnumlin || ' , pCDEBHAB : ' || pcdebhab || ', pndocume : '
            || pndocume || ', ptdescrip : ' || ptdescrip || ', pmodo : ' || pmodo
            || ', pnrecibo : ' || pnrecibo || ' , pnsinies : ' || pnsinies || ', pcconcepto :'
            || ', pffecmov : ' || pffecmov || ', pcfiscal : ' || pcfiscal;
      v_object       VARCHAR2(200) := 'PAC_md_LIQUIDA.f_set_cta';
      v_error        NUMBER(8);
   BEGIN
      IF pcagente IS NULL
         OR pcempres IS NULL
         OR(pmodo = 0
            AND pnnumlin IS NULL) THEN
         RAISE e_param_error;
      END IF;

      v_error := pac_liquida.f_set_cta(pcempres, pcagente, psseguro, pnnumlin, pcdebhab,
                                       pimporte, pndocume, ptdescrip, pmodo, pnrecibo,
                                       pnsinies, pcconcepto, pffecmov, pfvalor, pcfiscal, NULL);

      IF v_error <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, v_error);
         RAISE e_object_error;
      END IF;

      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 9001950);
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
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(200)
         := 'params : pnpoliza : ' || pnpoliza || ', pncertif : ' || pncertif
            || ', ptablas : ' || ptablas;
      v_object       VARCHAR2(200) := 'PAC_md_LIQUIDA.f_get_sseguro';
      v_error        NUMBER(8);
   BEGIN
      v_error := pac_seguros.f_get_sseguro(pnpoliza, pncertif, ptablas, psseguro);

      IF v_error <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, v_error);
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
      pmodo IN NUMBER,                    -- 0:MODO REAL 1:MODO PREVIO
      pfecliq IN DATE,
      psproces IN NUMBER,
      pruta OUT VARCHAR2,
      mensajes IN OUT t_iax_mensajes,
      psucursal IN NUMBER DEFAULT NULL,   -- BUG 19197 - 22/09/2011 - JMP
      padnsuc IN NUMBER DEFAULT NULL,   -- BUG 19197 - 22/09/2011 - JMP
      pcliquido IN NUMBER DEFAULT NULL   -- BUG 0020164 - 15/11/2011 - JMF
        RETURN
    /*****************************************************************/
   FUNCTION f_liquidaliq(
      pcagente IN NUMBER,
      pcempres IN NUMBER,
      pmodo IN NUMBER,
      pfecliq IN DATE,
      psproces IN NUMBER,
      pruta OUT VARCHAR2,
      mensajes IN OUT t_iax_mensajes,
      psucursal IN NUMBER DEFAULT NULL,
      padnsuc IN NUMBER DEFAULT NULL,
      pcliquido IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      vdata          DATE;
      v_cerror       NUMBER;
      vsproces       NUMBER;
      vfproces       DATE;
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(200)
         := 'params : pcagente : ' || pcagente || ', pcempres : ' || pcempres || ', pmodo : '
            || pmodo || ' f=' || pfecliq || ' p=' || psproces || ' s=' || psucursal || ' a='
            || padnsuc || ' l=' || pcliquido;
      v_object       VARCHAR2(200) := 'PAC_md_LIQUIDA.f_liquidaliq';
      v_error        NUMBER(8);
      v_fproces      DATE;
      v_titulo       VARCHAR2(200);
      v_cproces      VARCHAR2(200);
      vidioma        NUMBER;
      num_err        NUMBER := 0;
      vsproliq       NUMBER;
      ss             VARCHAR2(3000);
      v_cursor       NUMBER;
      v_cur          sys_refcursor;
      v_subfi        VARCHAR2(10);
      v_filas        NUMBER;
      -- Bug 18843 - APD - 21/07/2011 - se añade la exception
      ex_nodeclared  EXCEPTION;
      PRAGMA EXCEPTION_INIT(ex_nodeclared, -6550);   -- Se debe declarar el componente
      -- Fin Bug 18843 - APD - 21/07/2011
      v_squery       VARCHAR2(2000);
      v_cagente      agentes.cagente%TYPE;
      -- Bug 22065 - APD - 24/04/2012
      v_ttexto       VARCHAR2(1000);   -- BUG 21725 - 26/03/2012 - JMC
      v_llinia       NUMBER := 0;   -- BUG 21725 - 26/03/2012 - JMC
      pultcierre     DATE;   --Ini BUG 22414 - 13/06/2012 - DCG
      -- fin Bug 22065 - APD - 24/04/2012
      v_existe_liquidacab NUMBER;
      -- BUG: 25910   AMJ  05/02/2013  0025910: LCOL: Enviament de correu en el proc?s de liquidaci?
      v_errorc       NUMBER;
      verror         NUMBER;
      vnprolin       NUMBER;
      v_cagentevision agentes.cagente%TYPE;
      v_liquida_ctipage NUMBER;
      v_ageclave     NUMBER;
   BEGIN
      v_pasexec := 100;
      vidioma := pac_md_common.f_get_cxtidioma;
      -- bug 35979 - 20/07/2015 - JMF si liquidamos por agente clave
      v_pasexec := 110;
      v_ageclave := NVL(pac_parametros.f_parempresa_n(pcempres, 'LIQUIDA_AGECLAVE'), 0);

      IF pfecliq IS NULL
         AND psproces IS NULL THEN
         v_pasexec := 115;
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 105308);
         RAISE e_object_error;
      END IF;

      v_pasexec := 120;

--Ini BUG 22414 - 13/06/2012 - DCG
      SELECT MAX(fcierre)
        INTO pultcierre
        FROM cierres
       WHERE ctipo = 17   --Tancament de comissions
         AND cestado = 1   --Estat tancat
         AND cempres = pcempres;

--Fin BUG 22414 - 13/06/2012 - DCG
      v_pasexec := 130;

      IF (pmodo = 0) THEN
--Ini BUG 22414 - 13/06/2012 - DCG
--         AND(pfecliq >= f_sysdate) THEN
--         --No se puede cerrar con fecha fin superior a fecha siempre y cuando no se haya lanzado ya el proceso (psproces  is null)
         IF pultcierre IS NOT NULL
            AND   -- Instalaciones que tienen cierre de comisiones
               (pfecliq <= pultcierre)
            AND psproces IS NULL THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 105556);
            RAISE e_object_error;
         END IF;
      END IF;

      v_pasexec := 140;

      -- Bug 35979/206802: KJSC Asignar varibale nueva al parametro 'LIQUIDA_AGECLAVE'
      -- bug 35979 - 20/07/2015 - JMF si liquidamos por agente clave
      IF v_ageclave IN(1, 2)   --  AFM  18. Se añade agrupación de agentes de tipo 2.
         AND pcagente IS NOT NULL THEN
         DECLARE
            vcageclave     agentes_comp.cageclave%TYPE;
         BEGIN
            SELECT MAX(cageclave)
              INTO vcageclave
              FROM agentes_comp
             WHERE cagente = pcagente;

            IF vcageclave IS NOT NULL THEN
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9908277);
               RAISE e_object_error;
            END IF;

            SELECT MAX(cageclave)
              INTO vcageclave
              FROM agentes_comp
             WHERE cageclave = pcagente;

            IF vcageclave IS NULL THEN
               v_ageclave := 0;
            END IF;
         END;
      END IF;

      v_pasexec := 150;

------------------------------------------------------------------------------------------------------------------------------------
-- ini BUG 0025198 - 20/12/2012 - JMF
-- bug 35979 - 20/07/2015 - JMF si liquidamos por agente clave, lo hacemos por job
      IF (pcagente IS NULL
          AND psproces IS NULL)
         OR(pcagente IS NOT NULL
            AND psproces IS NULL
            AND v_ageclave IN(1, 2)) THEN   --  AFM  18. Se añade agrupación de agentes de tipo 2.
         -- Proceso de liquidación tanto Real como Previo pero en background
         num_err := 0;
         v_pasexec := 160;

         IF pmodo = 1 THEN   -- PREVIO
            v_titulo := f_axis_literales(9900860, vidioma);
         ELSE   --REAL
            v_titulo := f_axis_literales(9900861, vidioma);
         END IF;

         v_pasexec := 170;
         v_titulo := v_titulo || ' ' || TO_CHAR(pfecliq, 'MM') || ' '
                     || f_axis_literales(101619, vidioma) || ' ' || pcempres || ' '
                     || f_axis_literales(100584, vidioma) || ' ' || pcagente;
         v_pasexec := 180;
         num_err := f_procesini(f_user, pcempres, 'COMISIONES ', v_titulo, vsproces);
         COMMIT;
         num_err := NULL;
         v_titulo := NULL;

         DECLARE
            FUNCTION f_nulos(p_camp IN VARCHAR2, p_tip IN NUMBER DEFAULT 1)
               RETURN VARCHAR2 IS
            BEGIN
               v_pasexec := 190;

               IF p_camp IS NULL THEN
                  RETURN ' null';
               ELSE
                  IF p_tip = 2 THEN
                     RETURN ' to_date(' || CHR(39) || p_camp || CHR(39) || ',''ddmmyyyy'')';
                  ELSE
                     RETURN ' ' || p_camp;
                  END IF;
               END IF;
            END;
         BEGIN
            v_pasexec := 200;

            -- Bug 0026398 - JMF - 22/03/2013 : validar que no existan 2 jobs
            SELECT COUNT(1)
              INTO num_err
              FROM user_jobs
             WHERE UPPER(what) LIKE 'P_EJECUTAR_LIQUIDACIONES%';

            IF num_err > 0 THEN
               -- Ya existe un proceso de liquidación activo
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9905165);
               RAISE e_object_error;
            END IF;

            v_pasexec := 210;
            num_err := pac_jobs.f_ejecuta_job(NULL,
                                              'P_EJECUTAR_LIQUIDACIONES(' || ' '
                                              || f_nulos(pcagente) || ',' || ' '
                                              || f_nulos(pcempres) || ',' || ' '
                                              || f_nulos(pmodo) || ',' || ' '
                                              || f_nulos(TO_CHAR(pfecliq, 'ddmmyyyy'), 2)
                                              || ',' || ' ' || f_nulos(vsproces) || ',' || ' '
                                              || f_nulos(psucursal) || ',' || ' '
                                              || f_nulos(padnsuc) || ',' || ' '
                                              || f_nulos(pcliquido) || ');',
                                              NULL);

            IF num_err > 0 THEN
               p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param,
                           ' men=' || num_err);
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 6, num_err);
               RETURN 1;
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, v_object, v_pasexec,
                           v_param || ' men=' || num_err, SQLCODE || ' ' || SQLERRM);
               pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec,
                                                 v_param, psqcode => SQLCODE,
                                                 psqerrm => SQLERRM);
               RETURN 1;
         END;

         IF vsproces IS NOT NULL THEN
            -- Proceso diferido
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 0,
                                                 f_axis_literales(9904687, vidioma) || ' '
                                                 || vsproces);
         END IF;

         RETURN 0;
      END IF;

      -- Si es una generación batch, tiene sproces informado pero no tiene registros en liquidacab
      v_pasexec := 220;

      SELECT COUNT(1)
        INTO v_existe_liquidacab
        FROM liquidacab
       WHERE sproliq = psproces;

      -- fin BUG 0025198 - 20/12/2012 - JMF
      v_pasexec := 230;

      IF psproces IS NOT NULL THEN
         vsproliq := psproces;
      END IF;

      IF psproces IS NULL
         OR(psproces IS NOT NULL
            AND v_existe_liquidacab = 0) THEN   --Si no tenemos sproces o es el PREVIO lanzamos la liquidación
         -- BUG 19197 - 22/09/2011 - JMP
         v_pasexec := 240;
         v_liquida_ctipage := pac_parametros.f_parempresa_n(pcempres, 'LIQUIDA_CTIPAGE');

         IF v_ageclave IN(1, 2)   -- --  AFM  18. Se añade agrupación de agentes de tipo 2.
            AND pcagente IS NOT NULL THEN
            -- bug 35979 - 20/07/2015 - JMF si liquidamos por agente clave, lo hacemos por job
            -- Si liquidamos agente clave, buscamos los agentes que dependen del agente agrupador
            v_pasexec := 250;
            v_squery := 'SELECT cagente FROM redcomercial r WHERE fmovfin IS NULL'
                        || ' AND cempres = ' || pcempres;
            v_squery :=
               v_squery
               || ' AND cagente in (select ac.cagente FROM agentes_comp ac where ac.cageclave='
               || pcagente || ')';
            v_pasexec := 260;

            IF pcliquido IS NOT NULL THEN
               v_squery := v_squery
                           || ' AND exists (select 1 from agentes a where nvl(a.cliquido,0)='
                           || pcliquido || ' and a.cagente=r.cagente)';
            END IF;
         ELSIF (psucursal IS NULL
                AND padnsuc IS NULL)
               OR pcagente IS NOT NULL THEN
            v_pasexec := 270;
            v_squery := 'SELECT cagente FROM redcomercial r WHERE fmovfin IS NULL'
                        || ' AND cempres = ' || pcempres;

            IF pcagente IS NOT NULL THEN
               IF v_liquida_ctipage IS NULL THEN
                  v_squery := v_squery || ' AND cagente = ' || pcagente;
               ELSE
                  v_squery := v_squery || ' and ctipage >= ' || v_liquida_ctipage
                              || ' AND (cagente = ' || pcagente
                              || ' OR pac_agentes.f_es_descendiente(' || pcempres || ','
                              || pcagente || ',cagente) = 1) ';
               END IF;
            END IF;

            v_pasexec := 280;

            -- Fin Bug : 20169 - 26/11/2011 - JMC
            -- ini BUG 0020164 - 15/11/2011 - JMF
            IF pcliquido IS NOT NULL THEN
               v_squery := v_squery
                           || ' AND exists (select 1 from agentes a where nvl(a.cliquido,0)='
                           || pcliquido || ' and a.cagente=r.cagente)';
            END IF;
         -- fin BUG 0020164 - 15/11/2011 - JMF
         ELSE
            v_pasexec := 290;
            v_squery := 'SELECT cagente FROM redcomercial r WHERE fmovfin IS NULL'
                        -- Ini Bug : 20169 - 26/11/2011 - JMC
                        || ' AND(pac_parametros.f_parempresa_n(' || pcempres
                        || ', ''LIQUIDA_CTIPAGE'') IS NULL'
                        || ' OR pac_parametros.f_parempresa_n(' || pcempres
                        || ', ''LIQUIDA_CTIPAGE'') <= ctipage)';

                        -- Fin Bug : 20169 - 26/11/2011 - JMC
            -- ini BUG 0020164 - 15/11/2011 - JMF
            IF pcliquido IS NOT NULL THEN
               v_squery := v_squery
                           || ' AND exists (select 1 from agentes a where nvl(a.cliquido,0)='
                           || pcliquido || ' and a.cagente=r.cagente)';
            END IF;

            v_pasexec := 300;
            -- fin BUG 0020164 - 15/11/2011 - JMF
            v_squery := v_squery || ' START WITH cempres = ' || pcempres || ' AND cagente = '
                        || NVL(padnsuc, psucursal) || ' CONNECT BY cpadre = PRIOR cagente'
                        || ' AND cempres = PRIOR cempres';
         END IF;

         v_pasexec := 310;
         v_cagentevision := pac_md_common.f_get_cxtagente;

         IF psucursal IS NOT NULL
            OR padnsuc IS NOT NULL
            OR pcagente IS NOT NULL THEN
            v_pasexec := 320;
            v_cur := pac_md_listvalores.f_opencursor(v_squery, mensajes);
            v_pasexec := 330;

            LOOP
               FETCH v_cur
                INTO v_cagente;

               EXIT WHEN v_cur%NOTFOUND;
               v_error := pac_liquida.f_liquidaliq_age(v_cagente, pcempres, pmodo, pfecliq,
                                                       vidioma, v_cagentevision, vsproliq);

               IF v_error <> 0 THEN
                  ROLLBACK;
                  verror := f_proceslin(vsproliq,
                                        SUBSTR('Agente: ' || v_cagente || ' modo: ' || pmodo,
                                               1, 120),
                                        1, vnprolin, 1);
               END IF;

               COMMIT;   --por rendimiento
            END LOOP;
         ELSE
            -- Bug 0026398 - JMF - 22/03/2013 : Rendimiento, evitamos cursor
            v_pasexec := 360;
            v_error := pac_liquida.f_liquidaliq_age(NULL, pcempres, pmodo, pfecliq, vidioma,
                                                    v_cagentevision, vsproliq);

            IF v_error <> 0 THEN
               ROLLBACK;
               verror := f_proceslin(vsproliq,
                                     SUBSTR('Agente: ' || v_cagente || ' modo: ' || pmodo, 1,
                                            120),
                                     1, vnprolin, 1);
            ELSE
               COMMIT;
            END IF;
         END IF;

         -- ini BUG 0025198 - 20/12/2012 - JMF: Finalizamos proceso
         v_pasexec := 370;
         v_error := f_procesfin(vsproliq, v_error);

         -- fin BUG 0025198 - 20/12/2012 - JMF

         --Ini BUG 22337 - 22/05/2012 - JMC
         --Si tiene definido un tipo de agente a liquidar, el resumen de cuentas técnicas se
         --realiza aqui. (AGM)
         IF NVL(pac_parametros.f_parempresa_n(pcempres, 'LIQUIDA_CTIPAGE'), 999) <> 999 THEN
            v_pasexec := 380;

            FOR x IN (SELECT   *
                          FROM liquidacab
                         WHERE sproliq = vsproliq
                      ORDER BY cagente, nliqmen) LOOP
               v_error := pac_liquida.f_set_resumen_ctactes(x.cagente, pcempres, vsproliq,
                                                            vidioma, x.fliquid, x.nliqmen,
                                                            pmodo,
                                                            pac_md_common.f_get_cxtagente);

               IF v_error <> 0 THEN   -- hay errores
                  v_ttexto := f_axis_literales(v_error, vidioma);
                  v_error := f_proceslin(psproces, v_ttexto, 0, v_llinia);
                  v_error := f_procesfin(vsproliq, 1);
                  ROLLBACK;
                  pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, v_error);
                  RAISE e_object_error;
               END IF;
            END LOOP;
         END IF;

         --Fin BUG 22337 - 22/05/2012 - JMC

         -- BUG 29023 - FAL - 26/11/2013
         IF NVL(pac_parametros.f_parempresa_n(pcempres, 'AGRUPA_PAGO_DIRECT'), 0) = 1
            AND pmodo <> 1 THEN
            v_pasexec := 400;
            v_error := pac_liquida.f_agrupa_pagocomisi_directas(pcempres, vsproliq);

            IF v_error <> 0 THEN   -- hay errores
               v_ttexto := f_axis_literales(v_error, vidioma);
               v_error := f_proceslin(psproces, v_ttexto, 0, v_llinia);
               v_error := f_procesfin(vsproliq, 1);
               ROLLBACK;
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, v_error);
               RAISE e_object_error;
            END IF;
         END IF;
      -- FI BUG 29023 - FAL - 26/11/2013
      END IF;

      v_pasexec := 410;

      IF DBMS_SQL.is_open(v_cursor) THEN
         DBMS_SQL.close_cursor(v_cursor);
      END IF;

      -- BUG 0025198 - 20/12/2012 - JMF: Si viene de batch no hace falta generar ficheros.
      IF (psproces IS NOT NULL
          AND v_existe_liquidacab = 0) THEN
         NULL;
      ELSE
         v_pasexec := 420;
         v_cursor := DBMS_SQL.open_cursor;
         v_subfi := pac_parametros.f_parempresa_t(pcempres, 'SUFIJO_EMP');
         ss := 'BEGIN ' || ' :num_err := PAC_GENFICH_' || v_subfi || '.'
               || 'f_llistat_comissions(:pcempres,:pcagente,:vsproliq,:vidioma,'
               || ':pfecini,:pfecfin,:pmodo,:pruta)' || ';' || ' END;';
         DBMS_SQL.parse(v_cursor, ss, DBMS_SQL.native);
         DBMS_SQL.bind_variable(v_cursor, 'pcempres', pcempres);
         DBMS_SQL.bind_variable(v_cursor, 'pcagente', pcagente);
         DBMS_SQL.bind_variable(v_cursor, 'vsproliq', vsproliq);
         DBMS_SQL.bind_variable(v_cursor, 'vidioma', vidioma);
         DBMS_SQL.bind_variable(v_cursor, 'pfecini', pfecliq);
         DBMS_SQL.bind_variable(v_cursor, 'pfecfin', pfecliq);
         v_pasexec := 430;

         IF pmodo = 0 THEN   --Modo Real: genera el listado real
            DBMS_SQL.bind_variable(v_cursor, 'pmodo', 'R');
         ELSE
            DBMS_SQL.bind_variable(v_cursor, 'pmodo', 'P');
         END IF;

         v_pasexec := 440;
         DBMS_SQL.bind_variable(v_cursor, 'pruta', pruta, 500);
         DBMS_SQL.bind_variable(v_cursor, 'num_err', num_err);

         -- Bug 18843 - APD - 21/07/2011 - si la llamada a la funcion no existe,
         -- se debe hacer la llamada a la funcion generica
         BEGIN
            v_pasexec := 450;
            v_filas := DBMS_SQL.EXECUTE(v_cursor);
         EXCEPTION
            WHEN ex_nodeclared THEN
               /*
                 Esta excepción (ORA-6550 saltará siempre que se realiza una llamada
                 a una función, procedimiento, etc. inexistente o no declarado.
               */
               v_pasexec := 460;

               IF DBMS_SQL.is_open(v_cursor) THEN
                  DBMS_SQL.close_cursor(v_cursor);
               END IF;

               v_pasexec := 470;
               v_cursor := DBMS_SQL.open_cursor;
               ss := 'BEGIN ' || ' :num_err := PAC_GENFICH' || '.'
                     || 'f_llistat_comissions(:pcempres,:pcagente,:vsproliq,:vidioma,'
                     || ':pfecini,:pfecfin,:pmodo,:pruta)' || ';' || ' END;';
               DBMS_SQL.parse(v_cursor, ss, DBMS_SQL.native);
               DBMS_SQL.bind_variable(v_cursor, 'pcempres', pcempres);
               DBMS_SQL.bind_variable(v_cursor, 'pcagente', pcagente);
               DBMS_SQL.bind_variable(v_cursor, 'vsproliq', vsproliq);
               DBMS_SQL.bind_variable(v_cursor, 'vidioma', vidioma);
               DBMS_SQL.bind_variable(v_cursor, 'pfecini', pfecliq);
               DBMS_SQL.bind_variable(v_cursor, 'pfecfin', pfecliq);
               v_pasexec := 480;

               IF pmodo = 0 THEN   --Modo Real: genera el listado real
                  DBMS_SQL.bind_variable(v_cursor, 'pmodo', 'R');
               ELSE
                  DBMS_SQL.bind_variable(v_cursor, 'pmodo', 'P');
               END IF;

               v_pasexec := 490;
               DBMS_SQL.bind_variable(v_cursor, 'pruta', pruta, 500);
               DBMS_SQL.bind_variable(v_cursor, 'num_err', num_err);
               v_filas := DBMS_SQL.EXECUTE(v_cursor);
         END;

         v_pasexec := 500;
         -- fin Bug 18843 - APD - 21/07/2011
         DBMS_SQL.variable_value(v_cursor, 'pruta', pruta);
         DBMS_SQL.variable_value(v_cursor, 'num_err', num_err);

         IF DBMS_SQL.is_open(v_cursor) THEN
            DBMS_SQL.close_cursor(v_cursor);
         END IF;

         --Borramos solo si se ejecuta la generación del excel para el previo
         v_pasexec := 510;

         IF pmodo = 1 THEN
            v_error := pac_liquida.f_del_liq_previo(vsproliq);

            IF v_error <> 0 THEN
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, v_error);
               RAISE e_object_error;
            END IF;
         END IF;
      END IF;

      IF num_err <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 107914);
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
         IF DBMS_SQL.is_open(v_cursor) THEN
            DBMS_SQL.close_cursor(v_cursor);
         END IF;

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
   FUNCTION f_get_mescarant(pcempres IN NUMBER, pmes OUT NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(200) := 'params : pcempres : ' || pcempres;
      v_object       VARCHAR2(200) := 'PAC_MD_LIQUIDA.f_get_mescarant';
      v_error        NUMBER(8);
      vfcarant       DATE;
   BEGIN
      IF pcempres IS NULL THEN
         RAISE e_param_error;
      END IF;

      v_error := f_antcar(pcempres, vfcarant);

      IF v_error <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, v_error);
         RAISE e_object_error;
      END IF;

      pmes := TO_NUMBER(TO_CHAR(vfcarant, 'MM'));
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
   FUNCTION f_get_anyocarant(
      pcempres IN NUMBER,
      panyo OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(200) := 'params : pcempres : ' || pcempres;
      v_object       VARCHAR2(200) := 'PAC_MD_LIQUIDA.f_get_anyocarant';
      v_error        NUMBER(8);
      vfcarant       DATE;
   BEGIN
      IF pcempres IS NULL THEN
         RAISE e_param_error;
      END IF;

      v_error := f_antcar(pcempres, vfcarant);

      IF v_error <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, v_error);
         RAISE e_object_error;
      END IF;

      panyo := TO_NUMBER(TO_CHAR(vfcarant, 'YYYY'));
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
   FUNCTION f_get_feciniliq(pcursor OUT sys_refcursor, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(200) := 'params :';
      v_object       VARCHAR2(200) := 'PAC_MD_LIQUIDA.f_get_feciniliq';
      v_error        NUMBER(8);
      v_squery       VARCHAR2(2000);
   BEGIN
      v_squery := pac_liquida.f_get_feciniliq(17);
      pcursor := pac_iax_listvalores.f_opencursor(v_squery, mensajes);

      IF mensajes IS NOT NULL THEN
         IF mensajes.COUNT > 0 THEN
            RAISE e_object_error;
         END IF;
      END IF;

      IF pac_md_log.f_log_consultas(v_squery, 'PAC_MD_liquida.f_get_feciniliq', 2, 0, mensajes) <>
                                                                                              0 THEN
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
      pcursor OUT sys_refcursor,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(200)
         := 'params : ' || ' pmodo : ' || pmodo || ' pfecliq : ' || pfecliq || 'pcempres : '
            || pcempres;
      v_object       VARCHAR2(200) := 'PAC_MD_LIQUIDA.f_get_proc_cierres_liq';
      v_error        NUMBER(8);
      v_squery       VARCHAR2(2000);
   BEGIN
      v_squery := pac_liquida.f_get_proc_cierres_liq(pmodo, pfecliq, pcempres);

      IF v_squery IS NULL THEN
         RETURN 0;
      END IF;

      pcursor := pac_iax_listvalores.f_opencursor(v_squery, mensajes);

      IF mensajes IS NOT NULL THEN
         IF mensajes.COUNT > 0 THEN
            RAISE e_object_error;
         END IF;
      END IF;

      IF pac_md_log.f_log_consultas(v_squery, 'PAC_MD_liquida.f_get_proc_cierres_liq', 2, 0,
                                    mensajes) <> 0 THEN
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
   END f_get_proc_cierres_liq;
END pac_md_liquida;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_LIQUIDA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_LIQUIDA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_LIQUIDA" TO "PROGRAMADORESCSI";
