--------------------------------------------------------
--  DDL for Package Body PAC_MD_ADM
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY PAC_MD_ADM AS
   /******************************************************************************
      NOMBRE:       PAC_MD_ADMIN
      PROP¿SITO: Funciones para consultas recibos
      REVISIONES:
      Ver        Fecha        Autor             Descripci¿n
      ---------  ----------  ---------------  ------------------------------------
      1.0        18/06/2008   JMR               1. Creaci¿n del package.
      1.1        18/02/2009   FAL               2. Afegir concepte comisi¿ del rebut
      1.2        02/03/2009   RSC               3. Adaptaci¿n iAxis a productos colectivos con certificados
      1.3        30/04/2009   DCT               4. Modificaci¿n funci¿n  f_get_datosrecibo
      1.4        11/03/2009   MCC               5. Gesti¿n de Impagados
      1.5        02/09/2009   DCT               6.BUG 0011031: CEM - Eliminacion parametro mensajes en PAC_ADM y PAC_MD_ADM
      1.6        18/02/2010   JMF               7. 0012679 CEM - Treure la taula MOVRECIBOI
      8.0        21/04/2010   DRA               8. 0014202: CRE - Par¿metro nuevo para el pac_adm
      9.0        23/07/2010   JGR               9. 0015473: MDP - Consulta recibos en el campo [Cobrador recibo] con informaci¿n incorrecta
     10.0        11/10/2010   ICV              10. 0016140: AGA003 - filtro de estado de impresion en recibos
     11.0        04/11/2010   ICV              11. 0016325: CRT101 - Modificaci¿n de recibos para corredur¿a
     12.0        21/05/2010   ICV              12. 14586: CRT - A¿adir campo recibo compa¿ia
     13.0        18/07/2011   SRA              13. 0018908: LCOL003 - Modificaci¿n de las pantallas de gesti¿n de recibos
     14.0        25/10/2011   JMF              14. 0019791: LCOL_A001-Modificaciones de fase 0 en la consulta de recibos
     15.0        15/11/2011   JMF              15. 0020010: LCOL_A001-Registrar los nuevos medios de pago
     16.0        03/01/2012   JMF              16. 0020761 LCOL_A001- Quotes targetes
     17.0        01/03/2012   APD              17. 0021421: LCOL_C001: Incidencia en el traspaso de cartera
     18.0        27/03/2012   JGR              18. 0020546: LCOL_A001 - UAT-ADM - Errors cobrant/descobrant rebuts - 104206
     19.0        29/05/2012   JGR              19. 0022327: MDP_A001-Consulta de recibos - 0115278
     19.1        30/05/2012   DCG              20. 0022327: MDP_A001-Consulta de recibos - 0115681
     20.0        07/08/2012   APD              20. 0022342: MDP_A001-Devoluciones
     21.0        12/09/2012   JGR              21. 0022763: MDP_A001-Unificacion / Desunificacion de recibos - 0119028
     22.0        12/12/2012   JGR              22. 0024754: (POSDE100)-Desarrollo-GAPS Administracion-Id 156 - Las consultas de facturas se puedan hacer por sucursal y regional
     23.0        09/08/2013   CEC              23. 0027691/149541: Incorporaci¿n de desglose de Recibos en la moneda del producto
     24.0        06/11/2013   CEC              24. 0026295: RSA702-Desarrollar el modulo de Caja
     25.0        04/06/2015   MDS              25. 0035803: UNIFICACION DE RECIBOS:: POLIZA 2011400028 (bug hermano interno)
     26.0        21/06/2019   SGM              26. IAXIS-4134 Reporte de acuerdo de pago
     27.0        20/05/2019   DFR              27. IAXIS-3651 Proceso calculo de comisiones de outsourcing     
     28.0        17/07/2019   DFR              28. IAXIS-3591 Visualizar los importes del recibo de manera ordenada y sin repetir conceptos.
     29.0        23/07/2019   SPV              29. IAXIS-4884 Paquete de integración pagos SAP (Validacion)
     30.0        01/08/2019   Shakti           30. IAXIS-4944 TAREAS CAMPOS LISTENER
	 31.0        09/08/2019   SPV              31. IAXIS-4924 P�lizas Migradas y Margen de tolerancia
     32.0        28/05/2020   ECP              32. IAXIS-13945. Error Pagador P�lizas
   ******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

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
      vobject   VARCHAR2(500) := 'PAC_ADM.f_get_impagados';
      vparam    VARCHAR2(500) := 'par¿metros - psseguro: ' || psseguro ||
                                 ', pnrecibo: ' || pnrecibo ||
                                 ', psmovrec: ' || psmovrec;
      vpasexec  NUMBER(5) := 1;
      vnumerr   NUMBER(8) := 0;
      vcursor   SYS_REFCURSOR;
      vsquery   VARCHAR2(10000);
      vidioma   NUMBER := pac_md_common.f_get_cxtidioma;
      v_max_reg NUMBER; -- n¿mero m¿xim de registres mostrats
   BEGIN
      vpasexec := 1;

      IF pnrecibo IS NULL AND
         psseguro IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      vsquery  := pac_adm.f_get_impagados(psseguro, pnrecibo, psmovrec,
                                          vidioma);
                                          
      -- BUG14202:DRA:22/04/2010
      vcursor := pac_iax_listvalores.f_opencursor(vsquery, mensajes);

      IF pac_md_log.f_log_consultas(vsquery,
                                    'PAC_MD_ADM.F_F_Get_ConsultaRecibos', 1,
                                    4, mensajes) <> 0
      THEN
         IF vcursor%ISOPEN
         THEN
            CLOSE vcursor;
         END IF;
      END IF;

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
   FUNCTION f_get_consultarecibos(pnrecibo    IN NUMBER,
                                  pcempres    IN NUMBER,
                                  psproduc    IN NUMBER,
                                  pnpoliza    IN NUMBER,
                                  pncertif    IN NUMBER,
                                  pctiprec    IN NUMBER,
                                  pcestrec    IN NUMBER,
                                  pfemisioini IN DATE,
                                  pfemisiofin IN DATE,
                                  pfefeini    IN DATE,
                                  pfefefin    IN DATE,
                                  ptipo       IN NUMBER,
                                  psperson    IN NUMBER,
                                  pcreccia    IN VARCHAR2,
                                  --Bug 14586-PFA-21/05/2010- A¿adir campo recibo compa¿ia
                                  pcpolcia IN VARCHAR2,
                                  --Bug 14586-PFA-21/05/2010- A¿adir campo recibo compa¿ia
                                  -- Ini bug 18908 - 18/07/2011 - SRA
                                  pcramo     IN NUMBER,
                                  pcsucursal IN NUMBER,
                                  pcagente   IN NUMBER,
                                  pctipcob   IN NUMBER,
                                  pcondicion IN VARCHAR2,
                                  -- Fin bug 18908 - 18/07/2011 - SRA
                                  mensajes IN OUT t_iax_mensajes)
      RETURN SYS_REFCURSOR IS
      vobjectname VARCHAR2(500) := 'PAC_MD_ADM.F_Get_ConsultaRecibos';
      vparam      VARCHAR2(500) := 'par¿metros - pnrecibo: ' || pnrecibo ||
                                   ', pcempres: ' || pcempres ||
                                   ', psproduc: ' || psproduc ||
                                   ', pnpoliza: ' || pnpoliza ||
                                   ', pncertif: ' || pncertif ||
                                   ', pctiprec: ' || pctiprec ||
                                   ', pcestrec: ' || pcestrec ||
                                   ', pfemisioini: ' || pfemisioini ||
                                   ', pfemisiofin: ' || pfemisiofin ||
                                   ', pfefeini: ' || pfefeini ||
                                   ', pfefefin: ' || pfefefin || ', ptipo' ||
                                   ptipo || ', psperson: ' || psperson ||
                                   ', pcreccia: ' || pcreccia --Bug 14586-PFA-21/05/2010
                                  -- Ini bug 18908 - 18/07/2011 - SRA
                                   || 'pcramo: ' || pcramo ||
                                   'pcsucursal: ' || pcsucursal ||
                                   'pcagente: ' || pcagente;
      -- Fin bug 18908 - 18/07/2011 - SRA
      vpasexec   NUMBER(5) := 1;
      vnumerr    NUMBER(8) := 0;
      vcursor    SYS_REFCURSOR;
      vsquery    VARCHAR2(9000);
      vidioma    NUMBER := pac_md_common.f_get_cxtidioma;
      v_max_reg  NUMBER; -- n¿mero m¿xim de registres mostrats
      vcondicion VARCHAR2(4000);
   BEGIN
      vpasexec := 1;

      IF pcondicion IS NOT NULL
      THEN
         vcondicion := pac_md_listvalores.f_get_lstcondiciones(NVL(pcempres,
                                                                   pac_md_common.f_get_cxtempresa),
                                                               f_user,
                                                               pcondicion,
                                                               mensajes);
      END IF;

      vsquery := pac_adm.f_get_consultarecibos(pnrecibo, pcempres, psproduc,
                                               pnpoliza, pncertif, pctiprec,
                                               pcestrec, pfemisioini,
                                               pfemisiofin, pfefeini,
                                               pfefefin, ptipo, psperson,
                                               pcreccia, pcpolcia, vidioma
                                               -- BUG14202:DRA:22/04/2010 -- Bug 14586-PFA-21/05/2010
                                               -- Ini bug 18908 - 18/07/2011 - SRA
                                              , pcramo, pcsucursal, pcagente,
                                               pac_md_common.f_get_cxtempresa,
                                               pctipcob, vcondicion);
      -- Fin bug 18908 - 18/07/2011 - SRA
      vcursor := pac_iax_listvalores.f_opencursor(vsquery, mensajes);

      IF pac_md_log.f_log_consultas(vsquery,
                                    'PAC_MD_ADM.F_F_Get_ConsultaRecibos', 1,
                                    4, mensajes) <> 0
      THEN
         IF vcursor%ISOPEN
         THEN
            CLOSE vcursor;
         END IF;
      END IF;

      RETURN vcursor;
   EXCEPTION
      WHEN OTHERS THEN
         IF vcursor%ISOPEN
         THEN
            CLOSE vcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001,
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
   FUNCTION f_get_consultarecibos_mv(pnrecibo    IN NUMBER,
                                     pcempres    IN NUMBER,
                                     psproduc    IN NUMBER,
                                     pnpoliza    IN NUMBER,
                                     pncertif    IN NUMBER,
                                     pctiprec    IN NUMBER,
                                     pcestrec    IN NUMBER,
                                     pfemisioini IN DATE,
                                     pfemisiofin IN DATE,
                                     pfefeini    IN DATE,
                                     pfefefin    IN DATE,
                                     ptipo       IN NUMBER,
                                     psperson    IN NUMBER,
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
                                     -- Inici Bug 20326/99335 - BFP 05/12/2011
                                     cobban     IN NUMBER, --BUG20501 - JTS - 28/12/2011
                                     prebut_ini VARCHAR2 DEFAULT NULL, --Bug 22080 - 25/06/2012
                                     -- Inici Bug 22327/115681 - DCG 30/05/2011
                                     pnanuali  IN NUMBER DEFAULT NULL,
                                     pnfracci  IN NUMBER DEFAULT NULL,
                                     ptipnegoc IN NUMBER DEFAULT NULL,
                                     -- Fi Bug 22327/115681 - DCG 30/05/2011
                                     pcondicion IN VARCHAR2 DEFAULT NULL,
                                     mensajes   IN OUT t_iax_mensajes,
                                     pctipage01 IN NUMBER DEFAULT NULL, -- 22. 0024754 POS JGR 12/12/2012
                                     pnrecunif  IN VARCHAR2 DEFAULT NULL, --0031322/0175728:NSS:12/06/2014
                                     pnreccaj   IN NUMBER DEFAULT NULL, -- BUG CONF-441 - 14/12/2016 - JAEG
                                     pcmreca    IN NUMBER DEFAULT NULL -- BUG CONF-441 - 14/12/2016 - JAEG
                                     ) RETURN SYS_REFCURSOR IS
      vobjectname VARCHAR2(500) := 'PAC_MD_ADM.F_Get_ConsultaRecibos_mv';
      vparam      VARCHAR2(500) := 'par¿metros - pnrecibo: ' || pnrecibo ||
                                   ', pcempres: ' || pcempres ||
                                   ', psproduc: ' || psproduc ||
                                   ', pnpoliza: ' || pnpoliza ||
                                   ', pncertif: ' || pncertif ||
                                   ', pctiprec: ' || pctiprec ||
                                   ', pcestrec: ' || pcestrec ||
                                   ', pfemisioini: ' || pfemisioini ||
                                   ', pfemisiofin: ' || pfemisiofin ||
                                   ', pfefeini: ' || pfefeini ||
                                   ', pfefefin: ' || pfefefin || ', ptipo' ||
                                   ptipo || ', psperson: ' || psperson ||
                                   ' ,pcestimp: ' || pcestimp ||
                                   ' pcreccia : ' || pcreccia ||
                                   ' pcpolica :' || pcpolcia ||
                                   'pccompani :' || pccompani ||
                                   'pliquidad: ' || pliquidad
                                  -- Ini bug 18908 - 18/07/2011 - SRA
                                   || 'pcramo: ' || pcramo ||
                                   'pcsucursal: ' || pcsucursal ||
                                   'pcagente: ' || pcagente || 'pctipcob: ' ||
                                   pctipcob || 'pdomi_sn: ' || pdomi_sn
                                  -- Fin bug 18908 - 18/07/2011 - SRA
                                  -- Inici Bug 20326/99335 - BFP 05/12/2011
                                   || 'cbanco: ' || cbanco ||
                                   'ctipcuenta: ' || ctipcuenta ||
                                   'cobban: ' || cobban
                                  -- Fi Bug 20326/99335 - BFP 05/12/2011
                                   || ' prebut_ini :' || prebut_ini --Bug 22080 - 25/06/2012
                                   || ' pnrecunif: ' || pnrecunif; --0031322/0175728:NSS:12/06/2014
      vpasexec    NUMBER(5) := 1;
      vnumerr     NUMBER(8) := 0;
      vcursor     SYS_REFCURSOR;
      vsquery     VARCHAR2(9000);
      vidioma     NUMBER := pac_md_common.f_get_cxtidioma;
      v_max_reg   NUMBER; -- n¿mero m¿xim de registres mostrats
      vcempres    NUMBER := pcempres;
      vcondicion  VARCHAR2(4000);
   BEGIN
      IF pcempres IS NULL
      THEN
         vcempres := pac_md_common.f_get_cxtempresa;
      END IF;

      IF pcondicion IS NOT NULL
      THEN
         vcondicion := pac_md_listvalores.f_get_lstcondiciones(vcempres,
                                                               f_user,
                                                               pcondicion,
                                                               mensajes);
      END IF;

      vpasexec := 1;
      vsquery  := pac_adm.f_get_consultarecibos_mv(pnrecibo, vcempres,
                                                   psproduc, pnpoliza,
                                                   pncertif, pctiprec,
                                                   pcestrec, pfemisioini,
                                                   pfemisiofin, pfefeini,
                                                   pfefefin, ptipo, psperson,
                                                   vidioma, precunif,
                                                   pcestimp, pcreccia,
                                                   pcpolcia, pccompani,
                                                   pliquidad, pfiltro,
                                                   --                                               -- Ini bug 18908 - 18/07/2011 - SRA
                                                   pcramo, pcsucursal,
                                                   pcagente, pctipcob,
                                                   pdomi_sn,

                                                   -- Fin bug 18908 - 18/07/2011 - SRA
                                                   -- Inici Bug 20326/99335 - BFP 05/12/2011
                                                   cbanco, ctipcuenta,
                                                   pac_md_common.f_get_cxtempresa,

                                                   -- Inici Bug 20326/99335 - BFP 05/12/2011
                                                   cobban,
                                                   --BUG20501 - JTS - 28/12/2011
                                                   prebut_ini,
                                                   --Bug 22080 - 25/06/2012
                                                   pnanuali, pnfracci,
                                                   ptipnegoc,
                                                   -- Inici Bug 22327/115681 - DCG 30/05/2011
                                                   vcondicion, pctipage01,
                                                   -- 22. 0024754 POS JGR 12/12/2012
                                                   pnrecunif,
                                                   --0031322/0175728:NSS:12/06/2014
                                                   pnreccaj, pcmreca
                                                   -- BUG CONF-441 - 14/12/2016 - JAEG
                                                   );
      vcursor  := pac_iax_listvalores.f_opencursor(vsquery, mensajes);

      IF pac_md_log.f_log_consultas(vsquery,
                                    'PAC_MD_ADM.F_F_Get_ConsultaRecibos_mv',
                                    1, 4, mensajes) <> 0
      THEN
         IF vcursor%ISOPEN
         THEN
            CLOSE vcursor;
         END IF;
      END IF;

      RETURN vcursor;
   EXCEPTION
      WHEN OTHERS THEN
         IF vcursor%ISOPEN
         THEN
            CLOSE vcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001,
                                           vpasexec, vparam, NULL, SQLCODE,
                                           SQLERRM);
         RETURN vcursor;
   END f_get_consultarecibos_mv;

   -- fin Bug 0012679 - 18/02/2010 - JMF

   /************************************************************************
      Recupera informaci¿n del recibo
   *************************************************************************/
   /*************************************************************************
       Se encarga de recuperar la lista de movrecibos de un recibo en concreto
       param in pnrecibo   :   numero de recibo.
       Mensajes del tipo t_iax_mensajes
   *************************************************************************/
   FUNCTION f_get_detrecibos_det(pnrecibo IN NUMBER,
                                 pconcep  IN NUMBER,
                                 mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_detrecibo_det IS
      vnumerr        NUMBER(8) := 0;
      squery         VARCHAR2(2000);
      cur            SYS_REFCURSOR;
      detrecibo_det  ob_iax_detrecibo_det := ob_iax_detrecibo_det();
      detrecibos_det t_iax_detrecibo_det := t_iax_detrecibo_det();
      vidioma        NUMBER := pac_md_common.f_get_cxtidioma;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'par¿metros - pnrecibo: ' || pnrecibo ||
                                      ', pconcep: ' || pconcep;
      vobject        VARCHAR2(200) := 'PAC_MD_ADM.F_Get_Detrecibos_det';
      numrecs        NUMBER;
      v_error        NUMBER;
      vnmovimi       NUMBER; -- Bug 26923/148935 - 11/07/2013 - AMC
   BEGIN
      vpasexec := 1;

      IF pnrecibo IS NULL OR
         pconcep IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      squery   := pac_adm.f_get_detrecibos_det(pac_md_common.f_get_cxtempresa,
                                               pnrecibo, pconcep); -- BUG14202:DRA:22/04/2010

      -- BUG14202:DRA:22/04/2010
      OPEN cur FOR squery;

      vpasexec := 4;

      LOOP
         FETCH cur
            INTO detrecibo_det.cgarant,
                 detrecibo_det.nriesgo,
                 detrecibo_det.iconcep,
                 detrecibo_det.iconcep_monpol,
                 detrecibo_det.cageven,
                 detrecibo_det.nmovima;

         EXIT WHEN cur%NOTFOUND;
         v_error := f_desgarantia(detrecibo_det.cgarant, vidioma,
                                  detrecibo_det.tgarant);

         DECLARE
            vsseguro  recibos.sseguro%TYPE;
            vfemisio  recibos.femisio%TYPE;
            vtriesgo1 VARCHAR2(250);
            vtriesgo2 VARCHAR2(250);
            vtriesgo3 VARCHAR2(250);
         BEGIN
            SELECT sseguro,
                   femisio,
                   nmovimi
              INTO vsseguro,
                   vfemisio,
                   vnmovimi -- Bug 26923/148935 - 11/07/2013 - AMC
              FROM recibos
             WHERE nrecibo = pnrecibo;

            v_error := f_desriesgo(vsseguro, detrecibo_det.nriesgo, vfemisio,
                                   vidioma, vtriesgo1, vtriesgo2, vtriesgo3,
                                   vnmovimi
                                   -- Bug 26923/148935 - 11/07/2013 - AMC
                                   );

            IF v_error = 0
            THEN
               IF vtriesgo1 IS NOT NULL
               THEN
                  detrecibo_det.triesgo := detrecibo_det.triesgo ||
                                           vtriesgo1;
               END IF;

               IF vtriesgo2 IS NOT NULL
               THEN
                  IF detrecibo_det.triesgo IS NOT NULL
                  THEN
                     detrecibo_det.triesgo := detrecibo_det.triesgo || ' ';
                  END IF;

                  detrecibo_det.triesgo := detrecibo_det.triesgo ||
                                           vtriesgo2;
               END IF;

               IF vtriesgo3 IS NOT NULL
               THEN
                  IF detrecibo_det.triesgo IS NOT NULL
                  THEN
                     detrecibo_det.triesgo := detrecibo_det.triesgo || ' ';
                  END IF;

                  detrecibo_det.triesgo := detrecibo_det.triesgo ||
                                           vtriesgo3;
               END IF;
            ELSE
               detrecibo_det.triesgo := NULL;
            END IF;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               detrecibo_det.triesgo := NULL;
         END;

         detrecibos_det.extend;
         detrecibos_det(detrecibos_det.last) := detrecibo_det;
         detrecibo_det := ob_iax_detrecibo_det();
         vpasexec := 6;
      END LOOP;

      CLOSE cur;

      RETURN detrecibos_det;
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
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_detrecibos_det;

   /*************************************************************************
       Se encarga de recuperar la lista de movrecibos de un recibo en concreto
       param in pnrecibo   :   numero de recibo.
       Mensajes del tipo t_iax_mensajes
   *************************************************************************/
   FUNCTION f_get_detrecibos(pnrecibo IN NUMBER,
                             mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_detrecibo IS
      vnumerr    NUMBER(8) := 0;
      squery     VARCHAR2(2000);
      squery1        VARCHAR2(2000);
      cur            sys_refcursor;
      cur_fcambio    sys_refcursor;
      detrecibo  ob_iax_detrecibo := ob_iax_detrecibo();
      detrecibos t_iax_detrecibo := t_iax_detrecibo();
      vidioma    NUMBER := pac_md_common.f_get_cxtidioma;
      vpasexec   NUMBER(8) := 1;
      vparam     VARCHAR2(500) := 'par¿metros - pnrecibo: ' || pnrecibo;
      vobject    VARCHAR2(200) := 'PAC_MD_ADM.F_Get_Detrecibos';
      numrecs    NUMBER;
      vcontador      NUMBER := 0;
   BEGIN
      IF pnrecibo IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      squery   := pac_adm.f_get_detrecibos(pac_md_common.f_get_cxtempresa,
                                           pnrecibo);
      cur      := pac_iax_listvalores.f_opencursor(squery, mensajes);
      squery1 := pac_adm.f_get_detrecibos_fcambio(pac_md_common.f_get_cxtempresa, pnrecibo);
      cur_fcambio := pac_iax_listvalores.f_opencursor(squery1, mensajes);
      vpasexec := 4;

      LOOP
         FETCH cur
            INTO detrecibo.cconcep,
                 detrecibo.iconcep,
                 detrecibo.iconcep_monpol;

         EXIT WHEN cur%NOTFOUND;
         vnumerr := f_desvalorfijo(27, vidioma, detrecibo.cconcep,
                                   detrecibo.tconcep);

         IF vnumerr <> 0
         THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
            RETURN NULL;
         END IF;

         vpasexec                := 5;
         detrecibo.detrecibo_det := f_get_detrecibos_det(pnrecibo,
                                                         detrecibo.cconcep,
                                                         mensajes);

         --IGIL_INI-CONF_603
         detrecibo.detrecibo_det_fcambio := f_get_detrecibos_det_fcambio(pnrecibo, detrecibo.cconcep, mensajes);
         --IGIL_FIN-CONF_603
         IF detrecibo.detrecibo_det IS NULL
         THEN
            RAISE e_object_error;
         END IF;

         vpasexec := 6;
         detrecibos.extend;
         detrecibos(detrecibos.last) := detrecibo;
         detrecibo := ob_iax_detrecibo();
         vpasexec := 7;
      END LOOP;

      CLOSE cur;

            LOOP
         FETCH cur_fcambio
          INTO detrecibo.cconcep_fcambio, detrecibo.iconcep_fcambio, detrecibo.iconcep_monpol_fcambio;

         EXIT WHEN cur_fcambio%NOTFOUND;
         vcontador := vcontador +1;
         vnumerr := f_desvalorfijo(27, vidioma, detrecibo.cconcep_fcambio, detrecibo.tconcep_fcambio);

         vpasexec := 8;
         detrecibos(vcontador).cconcep_fcambio := detrecibo.cconcep_fcambio;
         detrecibos(vcontador).iconcep_fcambio := detrecibo.iconcep_fcambio;
         detrecibos(vcontador).iconcep_monpol_fcambio := detrecibo.iconcep_monpol_fcambio;
         detrecibos(vcontador).tconcep_fcambio := detrecibo.tconcep_fcambio;
         detrecibo := ob_iax_detrecibo();
      END LOOP;

      CLOSE cur_fcambio;

      RETURN detrecibos;
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
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_detrecibos;
   -- INI SPV IAXIS-4884 Paquete de integración pagos SAP
    /*************************************************************************
       Procedimiento intero para comparar los importes
       de recibos procesados en SAP
    *************************************************************************/
    PROCEDURE p_validar_recaudo_sap(p_iprinet  IN OUT NUMBER,
                                    p_it1imp   IN OUT NUMBER,
                                    p_iderreg  IN OUT NUMBER,
                                    p_nrecibo NUMBER)IS
    CURSOR c_lee_int_men IS
      SELECT trunc(to_number(pac_con.f_tag(SINTERF,'valor','TMENIN')),0)
        FROM int_mensajes 
      WHERE cinterf = 'l003'
        AND tmenin LIKE '%<tipo>11</tipo>%'
        AND tmenin LIKE '%<idpago>'||to_char(p_nrecibo)||'</idpago>%';
       --
    CURSOR c_lee_int_men_iva IS
      SELECT trunc(to_number(pac_con.f_tag(SINTERF,'valor','TMENIN')),0)
        FROM int_mensajes 
      WHERE cinterf = 'l003'
        AND tmenin LIKE '%<tipo>12</tipo>%'
        AND tmenin LIKE '%<idpago>'||to_char(p_nrecibo)||'</idpago>%';
      --
      CURSOR c_lee_int_men_ge IS
      SELECT trunc(to_number(pac_con.f_tag(SINTERF,'valor','TMENIN')),0)
        FROM int_mensajes 
      WHERE cinterf = 'l003'
        AND tmenin LIKE '%<tipo>13</tipo>%'
        AND tmenin LIKE '%<idpago>'||to_char(p_nrecibo)||'</idpago>%';
       --
       v_val_prima NUMBER;
       v_val_iva   NUMBER;
       v_val_ge    NUMBER;
       --
       v_tot_rec_ia NUMBER;
    BEGIN
       --
       OPEN c_lee_int_men;
       FETCH c_lee_int_men INTO v_val_prima;
       --
       OPEN c_lee_int_men_iva;
       FETCH c_lee_int_men_iva INTO v_val_iva;
       --
       OPEN c_lee_int_men_ge;
       FETCH c_lee_int_men_ge INTO v_val_ge;
       --
       IF NVL(v_val_prima,0) <> 0 AND
          NVL(v_val_prima,0) < p_iprinet THEN
         --
         p_iprinet := p_iprinet - v_val_prima;
         --
       END IF;
       --
       IF NVL(v_val_iva,0) <> 0 AND
          NVL(v_val_iva,0) < p_it1imp THEN
         --
         p_it1imp := p_it1imp - v_val_iva;
         --
       END IF;
       --
       IF NVL(v_val_ge,0) <> 0 AND
          NVL(v_val_ge,0) < p_iderreg THEN
         --
         p_iderreg := p_iderreg - v_val_ge;
         --
       END IF;
       --
       CLOSE c_lee_int_men;
       CLOSE c_lee_int_men_iva;
       CLOSE c_lee_int_men_ge;
       --
    END p_validar_recaudo_sap;
    -- FIN SPV IAXIS-4884 Paquete de integración pagos SAP
   /*************************************************************************
       Se encarga de recuperar el vmovrecibo de un recibo en concreto
       param in pnrecibo   :   numero de recibo.
       Mensajes del tipo t_iax_mensajes
   *************************************************************************/
   FUNCTION f_get_vdetrecibos(pnrecibo IN NUMBER,
                              mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_vdetrecibo IS
      vnumerr     NUMBER(8) := 0;
      squery      VARCHAR2(2000);
      cur         SYS_REFCURSOR;
      vdetrecibo  ob_iax_vdetrecibo := ob_iax_vdetrecibo();
      vdetrecibos t_iax_vdetrecibo := t_iax_vdetrecibo();
      vidioma     NUMBER := pac_md_common.f_get_cxtidioma;
      vpasexec    NUMBER(8) := 1;
      vparam      VARCHAR2(500) := 'par¿metros - pnrecibo: ' || pnrecibo;
      vobject     VARCHAR2(200) := 'PAC_MD_ADM.F_Get_VDetrecibos';
      numrecs     NUMBER;
	  -- INI SPV IAXIS-4924 P�lizas Migradas y Margen de tolerancia
	  v_creccia recibos.creccia%TYPE;
	  -- FIN SPV IAXIS-4924 P�lizas Migradas y Margen de tolerancia
   BEGIN
      IF pnrecibo IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      squery   := pac_adm.f_get_vdetrecibos(pac_md_common.f_get_cxtempresa,
                                            pnrecibo, vidioma); -- BUG14202:DRA:22/04/2010
      -- BUG14202:DRA:22/04/2010
      cur      := pac_iax_listvalores.f_opencursor(squery, mensajes);
      vpasexec := 4;

      LOOP
         FETCH cur
            INTO vdetrecibo.iprinet,
                 vdetrecibo.irecext,
                 vdetrecibo.iconsor,
                 vdetrecibo.ireccon,
                 vdetrecibo.iips,
                 vdetrecibo.tiips,
                 vdetrecibo.idgs,
                 vdetrecibo.tidgs,
                 vdetrecibo.iarbitr,
                 vdetrecibo.tiarbitr,
                 vdetrecibo.ifng,
                 vdetrecibo.tifng,
                 vdetrecibo.irecfra,
                 vdetrecibo.idtotec,
                 vdetrecibo.idtocom,
                 vdetrecibo.icombru,
                 vdetrecibo.icomret,
                 vdetrecibo.idtoom,
                 vdetrecibo.ipridev,
                 vdetrecibo.itotpri,
                 vdetrecibo.itotdto,
                 vdetrecibo.itotcon,
                 vdetrecibo.itotimp,
                 vdetrecibo.itotalr,
                 vdetrecibo.iderreg,
                 vdetrecibo.itotrec,
                 vdetrecibo.icomdev,
                 vdetrecibo.iretdev,
                 vdetrecibo.icednet,
                 vdetrecibo.icedrex,
                 vdetrecibo.icedcon,
                 vdetrecibo.icedrco,
                 vdetrecibo.icedips,
                 vdetrecibo.iceddgs,
                 vdetrecibo.icedarb,
                 vdetrecibo.icedfng,
                 vdetrecibo.icedrfr,
                 vdetrecibo.iceddte,
                 vdetrecibo.iceddco,
                 vdetrecibo.icedcbr,
                 vdetrecibo.icedcrt,
                 vdetrecibo.iceddom,
                 vdetrecibo.icedpdv,
                 vdetrecibo.icedreg,
                 vdetrecibo.icedcdv,
                 vdetrecibo.icedrdv,
                 vdetrecibo.it1pri,
                 vdetrecibo.it1dto,
                 vdetrecibo.it1con,
                 vdetrecibo.it1imp,
                 vdetrecibo.it1rec,
                 vdetrecibo.it1totr,
                 vdetrecibo.it2pri,
                 vdetrecibo.it2dto,
                 vdetrecibo.it2con,
                 vdetrecibo.it2imp,
                 vdetrecibo.it2rec,
                 vdetrecibo.it2totr,
                 vdetrecibo.icomcia,
                 vdetrecibo.icombrui,
                 vdetrecibo.icomreti,
                 vdetrecibo.icomdevi,
                 vdetrecibo.icomdrti,
                 vdetrecibo.icombruc,
                 vdetrecibo.icomretc,
                 vdetrecibo.icomdevc,
                 vdetrecibo.icomdrtc,
                 vdetrecibo.iocorec,
                 vdetrecibo.iimp_1,
                 vdetrecibo.iimp_2,
                 vdetrecibo.iimp_3,
                 vdetrecibo.iimp_4 -- 18. 27/03/2012 JGR 0020546/104206
         ;

         EXIT WHEN cur%NOTFOUND;

         -- ini Bug 0019791 - 25/10/2011 - JMF
         DECLARE
            v_propio parempresas.tvalpar%TYPE;
            v_query  VARCHAR2(500);
            v_param  NUMBER;
         BEGIN
            v_propio := pac_parametros.f_parempresa_t(pac_md_common.f_get_cxtempresa,
                                                      'PAC_PROPIO');

            IF v_propio IS NULL
            THEN
               vdetrecibo.ipbruta := NULL;
            ELSE
               v_query := 'begin :v_param := ' || v_propio ||
                          '.ff_prima_bruta_recibo (' || pnrecibo ||
                          '); end;';

               EXECUTE IMMEDIATE v_query
                  USING OUT v_param;

               vdetrecibo.ipbruta := v_param;
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               vdetrecibo.ipbruta := NULL;
         END;
     -- INI BUG IAXIS-12983 JRVG 16/03/2020
     -- INI SPV IAXIS-4924 P�lizas Migradas y Margen de tolerancia
		 -- Buscamos el campo que indica si la poliza viene de migracion
		 /*BEGIN
		   --
		   SELECT creccia
		     INTO v_creccia
			FROM  recibos
			 WHERE nrecibo = pnrecibo;
			--
			-- Tomamos el valor del campo como recibo a validar si no es null es decir es migracion
			IF v_creccia IS NOT NULL THEN
			  --
			  p_validar_recaudo_sap( vdetrecibo.iprinet,
                                     vdetrecibo.it1imp,
                                     vdetrecibo.iderreg,
                                     v_creccia);
		    ELSE
			 -- Se maneja como se estableci� inicialmente si es de iAxis
			 -- INI SPV IAXIS-4884 Paquete de integraci�n pagos SAP
             -- Realiza validacion de datos con SAP
             p_validar_recaudo_sap( vdetrecibo.iprinet,
                                    vdetrecibo.it1imp,
                                    vdetrecibo.iderreg,
                                    pnrecibo);
            -- FIN SPV IAXIS-4884 Paquete de integraci�n pagos SAP
			END IF;
			--
		 EXCEPTION WHEN OTHERS THEN
		   -- En caso de que no exista el recibo y el proceso continue normalmente
		   v_creccia := 0;
		 END;*/
         -- FIN SPV IAXIS-4924 P�lizas Migradas y Margen de tolerancia
         -- fin Bug 0019791 - 25/10/2011 - JMF
     -- FIN BUG IAXIS-12983 JRVG 16/03/2020
         vdetrecibos.extend;
         vdetrecibos(vdetrecibos.last) := vdetrecibo;
         vdetrecibo := ob_iax_vdetrecibo();
         vpasexec := 6;
      END LOOP;

      CLOSE cur;

      RETURN vdetrecibos;
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
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_vdetrecibos;

   FUNCTION f_get_vdetrecibos_monpol(pnrecibo IN NUMBER,
                                     mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_vdetrecibo IS
      vnumerr     NUMBER(8) := 0;
      squery      VARCHAR2(2000);
      cur         SYS_REFCURSOR;
      vdetrecibo  ob_iax_vdetrecibo := ob_iax_vdetrecibo();
      vdetrecibos t_iax_vdetrecibo := t_iax_vdetrecibo();
      vidioma     NUMBER := pac_md_common.f_get_cxtidioma;
      vpasexec    NUMBER(8) := 1;
      vparam      VARCHAR2(500) := 'par¿metros - pnrecibo: ' || pnrecibo;
      vobject     VARCHAR2(200) := 'PAC_MD_ADM.F_Get_VDetrecibos_monpol';
      numrecs     NUMBER;
   BEGIN
      IF pnrecibo IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      squery   := pac_adm.f_get_vdetrecibos_monpol(pac_md_common.f_get_cxtempresa,
                                                   pnrecibo, vidioma); -- BUG14202:DRA:22/04/2010
      -- BUG14202:DRA:22/04/2010
      cur      := pac_iax_listvalores.f_opencursor(squery, mensajes);
      vpasexec := 4;

      LOOP
         FETCH cur
            INTO vdetrecibo.iprinet,
                 vdetrecibo.irecext,
                 vdetrecibo.iconsor,
                 vdetrecibo.ireccon,
                 vdetrecibo.iips,
                 vdetrecibo.tiips,
                 vdetrecibo.idgs,
                 vdetrecibo.tidgs,
                 vdetrecibo.iarbitr,
                 vdetrecibo.tiarbitr,
                 vdetrecibo.ifng,
                 vdetrecibo.tifng,
                 vdetrecibo.irecfra,
                 vdetrecibo.idtotec,
                 vdetrecibo.idtocom,
                 vdetrecibo.icombru,
                 vdetrecibo.icomret,
                 vdetrecibo.idtoom,
                 vdetrecibo.ipridev,
                 vdetrecibo.itotpri,
                 vdetrecibo.itotdto,
                 vdetrecibo.itotcon,
                 vdetrecibo.itotimp,
                 vdetrecibo.itotalr,
                 vdetrecibo.iderreg,
                 vdetrecibo.itotrec,
                 vdetrecibo.icomdev,
                 vdetrecibo.iretdev,
                 vdetrecibo.icednet,
                 vdetrecibo.icedrex,
                 vdetrecibo.icedcon,
                 vdetrecibo.icedrco,
                 vdetrecibo.icedips,
                 vdetrecibo.iceddgs,
                 vdetrecibo.icedarb,
                 vdetrecibo.icedfng,
                 vdetrecibo.icedrfr,
                 vdetrecibo.iceddte,
                 vdetrecibo.iceddco,
                 vdetrecibo.icedcbr,
                 vdetrecibo.icedcrt,
                 vdetrecibo.iceddom,
                 vdetrecibo.icedpdv,
                 vdetrecibo.icedreg,
                 vdetrecibo.icedcdv,
                 vdetrecibo.icedrdv,
                 vdetrecibo.it1pri,
                 vdetrecibo.it1dto,
                 vdetrecibo.it1con,
                 vdetrecibo.it1imp,
                 vdetrecibo.it1rec,
                 vdetrecibo.it1totr,
                 vdetrecibo.it2pri,
                 vdetrecibo.it2dto,
                 vdetrecibo.it2con,
                 vdetrecibo.it2imp,
                 vdetrecibo.it2rec,
                 vdetrecibo.it2totr,
                 vdetrecibo.icomcia,
                 vdetrecibo.icombrui,
                 vdetrecibo.icomreti,
                 vdetrecibo.icomdevi,
                 vdetrecibo.icomdrti,
                 vdetrecibo.icombruc,
                 vdetrecibo.icomretc,
                 vdetrecibo.icomdevc,
                 vdetrecibo.icomdrtc,
                 vdetrecibo.iocorec,
                 vdetrecibo.iimp_1,
                 vdetrecibo.iimp_2,
                 vdetrecibo.iimp_3,
                 vdetrecibo.iimp_4 -- 18. 27/03/2012 JGR 0020546/104206
         ;

         EXIT WHEN cur%NOTFOUND;

         -- ini Bug 0019791 - 25/10/2011 - JMF
         DECLARE
            v_propio parempresas.tvalpar%TYPE;
            v_query  VARCHAR2(500);
            v_param  NUMBER;
         BEGIN
            v_propio := pac_parametros.f_parempresa_t(pac_md_common.f_get_cxtempresa,
                                                      'PAC_PROPIO');

            IF v_propio IS NULL
            THEN
               vdetrecibo.ipbruta := NULL;
            ELSE
               v_query := 'begin :v_param := ' || v_propio ||
                          '.ff_prima_bruta_recibo (' || pnrecibo ||
                          '); end;';

               EXECUTE IMMEDIATE v_query
                  USING OUT v_param;

               vdetrecibo.ipbruta := v_param;
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               vdetrecibo.ipbruta := NULL;
         END;

         -- fin Bug 0019791 - 25/10/2011 - JMF
         vdetrecibos.extend;
         vdetrecibos(vdetrecibos.last) := vdetrecibo;
         vdetrecibo := ob_iax_vdetrecibo();
         vpasexec := 6;
      END LOOP;

      CLOSE cur;

      RETURN vdetrecibos;
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
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_vdetrecibos_monpol;

   /*************************************************************************
       Se encarga de recuperar la lista de movrecibos de un recibo en concreto
       param in pnrecibo   :   numero de recibo.
       Mensajes del tipo t_iax_mensajes
   *************************************************************************/
   FUNCTION f_get_movrecibos(pnrecibo IN NUMBER,
                             mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_movrecibo IS
      vnumerr    NUMBER(8) := 0;
      squery     VARCHAR2(2000);
      cur        SYS_REFCURSOR;
      movrecibo  ob_iax_movrecibo := ob_iax_movrecibo();
      movrecibos t_iax_movrecibo := t_iax_movrecibo();
      vidioma    NUMBER := pac_md_common.f_get_cxtidioma;
      vpasexec   NUMBER(8) := 1;
      vparam     VARCHAR2(500) := 'par¿metros - pnrecibo: ' || pnrecibo;
      vobject    VARCHAR2(200) := 'PAC_MD_ADM.F_Get_Movrecibos';
      numrecs    NUMBER;
   BEGIN
      IF pnrecibo IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      squery   := pac_adm.f_get_movrecibos(pnrecibo, vidioma);
      -- BUG14202:DRA:22/04/2010
      cur      := pac_iax_listvalores.f_opencursor(squery, mensajes);
      vpasexec := 4;

      -- Bug 19791/97335 - 08/11/2011 - AMC
      LOOP
         FETCH cur
            INTO movrecibo.smovrec,
                 movrecibo.cusuari,
                 movrecibo.smovagr,
                 movrecibo.cestrec,
                 movrecibo.cestant,
                 movrecibo.fmovini,
                 movrecibo.fmovfin,
                 movrecibo.fcontab,
                 movrecibo.fmovdia,
                 movrecibo.cmotmov,
                 movrecibo.ccobban,
                 movrecibo.cdelega,
                 movrecibo.ctipcob,
                 movrecibo.fefeadm,
                 movrecibo.testrec,
                 movrecibo.ttipcob,
                 movrecibo.cmotivo,
                 movrecibo.tmotivo,
                 movrecibo.nreccaj,
                 movrecibo.tmreca, --BUG CONF-441 - 14/12/2016 - JAEG
                 movrecibo.CINDICAF,-----Changes for 4944
                 movrecibo.CSUCURSAL;-----Changes for 4944
         EXIT WHEN cur%NOTFOUND;
         movrecibos.extend;
         movrecibos(movrecibos.last) := movrecibo;
         movrecibo := ob_iax_movrecibo();
         vpasexec := 6;
      END LOOP;

      -- Fi Bug 19791/97335 - 08/11/2011 - AMC
      CLOSE cur;

      RETURN movrecibos;
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
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_movrecibos;

   --Fin Bug 9204-MCC-03/03/2009-Restructuraci¿n del package

   /*************************************************************************
       Se encarga de recuperar la informaci¿n de un recibo en concreto
       param in pnrecibo   :   numero de recibo.
        param in ptotagrup   :  0.- Importe del recibo 1.- Total agrupado
       Mensajes del tipo t_iax_mensajes
   *************************************************************************/
   FUNCTION f_get_datosrecibo(pnrecibo  IN NUMBER,
                              ptotagrup IN NUMBER DEFAULT 0,
                              mensajes  IN OUT t_iax_mensajes)
      RETURN ob_iax_recibos IS
      vnumerr NUMBER(8) := 0;
      squery  VARCHAR2(4000);
      cur     SYS_REFCURSOR;
      recibo  ob_iax_recibos := ob_iax_recibos();
      --BUG 10014 SMARTINEZ 05/05/2009
      vidioma    NUMBER := pac_md_common.f_get_cxtidioma;
      vpasexec   NUMBER(8) := 1;
      n_cagente  NUMBER;
      vparam     VARCHAR2(500) := 'par¿metros - pnrecibo: ' || pnrecibo;
      vobject    VARCHAR2(200) := 'PAC_MD_ADM.F_Get_DatosRecibo';
      numrecs    NUMBER;
      comisbruta FLOAT;
      retencio   FLOAT;
      -- Bug 8745 - 02/03/2009 - RSC -    IAX: Adaptaci¿n iAxis a productos colectivos con certificados
      v_sseguro  NUMBER;
      v_esccero  NUMBER;
      v_tdescrip VARCHAR2(200); --> 20100723 - JGR - 0015473 - AXIS2105
      v_nada     t_iax_mensajes; --> 20100723 - JGR - 0015473 - AXIS2105
      -- Fin Bug  8745
      vparemp_monpol NUMBER := 0;
   BEGIN
      IF pnrecibo IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      --Mirem si agafem la moneda del producte o la moneda de cobrament. XPL#03012011#20592
      vparemp_monpol := NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa,
                                                          'MONEDA_POL'), 0);
      vpasexec       := 2;
      squery         := pac_adm.f_get_datosrecibo(pnrecibo, vidioma);
      -- BUG12679:DRA:28/04/2010
      vpasexec := 3;
      cur      := pac_iax_listvalores.f_opencursor(squery, mensajes);
      vpasexec := 4;

      -- Bug 8745 - 02/03/2009 - RSC -    IAX: Adaptaci¿n iAxis a productos colectivos con certificados
      -- Se asigna v_esccero
      -- Bug 14586-PFA-21/05/2010- A¿adir campo recibo compa¿ia
      -- Bug 0020010 - JMF - 15/11/2011: A¿adir ctipcob^
      -- BUG 0020761 - 03/01/2012 - JMF: ncuotar
      -- Bug 22342 - APD - 14/06/2012 - se a¿aden los campos caccpre, caccret y tobserv
      FETCH cur
         INTO recibo.nrecibo,
              recibo.cagente,
              recibo.cempres,
              recibo.nmovimi,
              recibo.sseguro,
              recibo.femisio,
              recibo.fefecto,
              recibo.fvencim,
              recibo.ctiprec,
              recibo.ttiprec,
              recibo.cdelega,
              recibo.ccobban,
              recibo.cestaux,
              recibo.nanuali,
              recibo.nfracci,
              recibo.cestimp,
              recibo.testimp,
              recibo.festimp,
              recibo.nriesgo,
              recibo.cforpag,
              recibo.tforpag,
              recibo.ctipban,
              recibo.cbancar,
              recibo.nmovanu,
              recibo.cretenc,
              recibo.pretenc,
              recibo.ncuacoa,
              recibo.ctipcoa,
              recibo.ttipcoa,
              recibo.cestsop,
              recibo.nperven,
              recibo.ctransf,
              recibo.cgescob,
              recibo.tgescob,
              recibo.cmanual,
              recibo.tmanual,
              recibo.cestrec,
              recibo.testrec,
              recibo.creccia,
              v_esccero,
              recibo.ctipcob,
              recibo.ncuotar,
              recibo.caccpre,
              recibo.caccret,
              recibo.tobserv;

      IF cur%NOTFOUND
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 101731);
         RAISE e_object_error;
      END IF;

      CLOSE cur;

      --INI BUG 38252/228158 Se comenta la inicializaci¿n del contexto ya que esto da problemas de navegaci¿n entre pantallas.
      /*BEGIN
         SELECT cagente
           INTO n_cagente
           FROM seguros
          WHERE sseguro = recibo.sseguro;

         --Informamos la variable de entorno cxtagenteprod con el agente del recibo que se est¿ consultando
         pac_md_common.p_set_cxtagenteprod(n_cagente);
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;*/
      --FIN BUG 38252/228158

      --BUG 9984  - 30/04/2009 - DCT
      IF recibo.ctipban IS NOT NULL
      THEN
         vnumerr := pac_descvalores.f_desctipocuenta(recibo.ctipban, vidioma,
                                                     recibo.ttipban);

         IF vnumerr <> 0
         THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
            RETURN NULL;
         END IF;
      END IF;

      -- Bug 8745 - 02/03/2009 - RSC -    IAX: Adaptaci¿n iAxis a productos colectivos con certificados
      IF v_esccero = 1
      THEN
         SELECT s.sseguro
           INTO v_sseguro
           FROM seguros s,
                seguros s2
          WHERE s.npoliza = s2.npoliza
            AND s.ncertif = 0
            AND s2.sseguro = recibo.sseguro;

         recibo.sseguro := v_sseguro;
      END IF;

      -- Fin Bug  9383
      vnumerr := f_desagente(recibo.cdelega, recibo.tdelega);
      --        IF vnumerr <>0 THEN
      --            PAC_IOBJ_MENSAJES.CREA_NUEVO_MENSAJE(mensajes,1,vnumerr);
      --            RETURN null;
      --        END IF;
      vnumerr := f_desagente(recibo.cagente, recibo.tagente);
      --Descripci¿n agente.
      --        IF vnumerr <>0 THEN
      --            PAC_IOBJ_MENSAJES.CREA_NUEVO_MENSAJE(mensajes,1,vnumerr);
      --            RETURN null;
      --        END IF;
      vnumerr := f_desempresa(recibo.cempres, NULL, recibo.tempres);

      -- Descripci¿n empresa.
      IF vnumerr <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RETURN NULL;
      END IF;

      vnumerr := f_desagente(f_gestor(recibo.cempres, recibo.cagente,
                                      f_sysdate), recibo.tgestor);

      IF vnumerr <> 0
      THEN
         recibo.tgestor := NULL;
      END IF;

      --vnumerr := f_desagente(recibo.ccobban, recibo.tcobban); --> 20100723 - JGR - 0015473 - AXIS2105
      -- 20121008 - JLTS - 0020278 - Se a¿ade el campo recibo.tdescrip en lugar de v_tdescrip
      vnumerr := f_get_descobrador(recibo.ccobban, recibo.tdescrip,
                                   recibo.tcobban, v_nada); --> 20100723 - JGR - 0015473 - AXIS2105

      IF vnumerr <> 0
      THEN
         -- recibo.tgestor := NULL; --> 20100723 - JGR - 0015473 - AXIS2105
         recibo.tcobban := NULL; --> 20100723 - JGR - 0015473 - AXIS2105
      END IF;

      IF NVL(ptotagrup, 0) = 1
      THEN
         --Importe total agrupado
         IF vparemp_monpol = 0
         THEN
            SELECT SUM(itotalr)
              INTO recibo.importe
              FROM vdetrecibos
             WHERE nrecibo IN
                   (SELECT nrecunif
                      FROM adm_recunif
                     WHERE nrecibo = pnrecibo --hijos si recibimos un padre
                    UNION
                    SELECT nrecibo
                      FROM adm_recunif
                     WHERE nrecibo = pnrecibo -- padre si recibos un padre
                    UNION
                    SELECT nrecibo
                      FROM recibos
                     WHERE nrecibo = pnrecibo -- en caso que no est¿ unificado
                    UNION
                    SELECT nrecibo -- los otros hijos de un padre, en caso de recibir un recibo hijo por parametro
                      FROM adm_recunif
                     WHERE nrecibo IN
                           (SELECT nrecibo
                              FROM adm_recunif
                             WHERE nrecunif = pnrecibo));
         ELSE
            SELECT SUM(itotalr)
              INTO recibo.importe
              FROM vdetrecibos_monpol
             WHERE nrecibo IN
                   (SELECT nrecunif
                      FROM adm_recunif
                     WHERE nrecibo = pnrecibo --hijos si recibimos un padre
                    UNION
                    SELECT nrecibo
                      FROM adm_recunif
                     WHERE nrecibo = pnrecibo -- padre si recibos un padre
                    UNION
                    SELECT nrecibo
                      FROM recibos
                     WHERE nrecibo = pnrecibo -- en caso que no est¿ unificado
                    UNION
                    SELECT nrecibo -- los otros hijos de un padre, en caso de recibir un recibo hijo por parametro
                      FROM adm_recunif
                     WHERE nrecibo IN
                           (SELECT nrecibo
                              FROM adm_recunif
                             WHERE nrecunif = pnrecibo));
         END IF;
      ELSE
         IF vparemp_monpol = 0
         THEN
            SELECT itotalr
              INTO recibo.importe
              FROM vdetrecibos
             WHERE nrecibo = pnrecibo;
         ELSE
            SELECT itotalr
              INTO recibo.importe
              FROM vdetrecibos_monpol
             WHERE nrecibo = pnrecibo;
         END IF;
      END IF;

      -- Bug 7657 - 18/02/2009 - FAL - Afegir concepte comisi¿ del rebut ((YSR) coaseguro cedido recibo unico)
      BEGIN
         IF vparemp_monpol = 0
         THEN
            SELECT DECODE(ctipcoa, 1, icombru + icedcbr, icombru),
                   DECODE(ctipcoa, 1, icomret + icedcrt, icomret)
              INTO comisbruta,
                   retencio
              FROM vdetrecibos v,
                   recibos     r
             WHERE r.nrecibo = recibo.nrecibo
               AND v.nrecibo = r.nrecibo;
         ELSE
            SELECT DECODE(ctipcoa, 1, icombru + icedcbr, icombru),
                   DECODE(ctipcoa, 1, icomret + icedcrt, icomret)
              INTO comisbruta,
                   retencio
              FROM vdetrecibos_monpol v,
                   recibos            r
             WHERE r.nrecibo = recibo.nrecibo
               AND v.nrecibo = r.nrecibo;
         END IF;

         recibo.icomisi := comisbruta - retencio;
      EXCEPTION
         WHEN OTHERS THEN
            recibo.icomisi := NULL;
      END;

      recibo.movrecibo := f_get_movrecibos(pnrecibo, mensajes);

      IF recibo.movrecibo IS NULL
      THEN
         RAISE e_object_error;
      END IF;

      recibo.detrecibo := f_get_detrecibos(pnrecibo, mensajes);

      IF recibo.detrecibo IS NULL
      THEN
         RAISE e_object_error;
      END IF;

      recibo.vdetrecibo := f_get_vdetrecibos(pnrecibo, mensajes);

      IF recibo.vdetrecibo IS NULL
      THEN
         RAISE e_object_error;
      END IF;

      -- Bug 22342 - APD - 14/06/2012
      recibo.taccpre := ff_desvalorfijo(800086, vidioma, recibo.caccpre);
      recibo.taccret := ff_desvalorfijo(800089, vidioma, recibo.caccret);
      -- fin Bug 22342 - APD - 14/06/2012
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
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_datosrecibo;

   -- BUG12679:DRA:07/05/2010:Inici
   /*************************************************************************
       Se encarga de recuperar la informaci¿n de un recibo en concreto
       param in pnrecibo   :   numero de recibo.
       param in ptotagrup   :  0.- Importe del recibo 1.- Total agrupado
       Mensajes del tipo t_iax_mensajes
   *************************************************************************/
   FUNCTION f_get_datosrecibo_mv(pnrecibo  IN NUMBER,
                                 ptotagrup IN NUMBER DEFAULT 0,
                                 mensajes  IN OUT t_iax_mensajes)
      RETURN ob_iax_recibos IS
      vnumerr NUMBER(8) := 0;
      squery  VARCHAR2(4000);
      cur     SYS_REFCURSOR;
      recibo  ob_iax_recibos := ob_iax_recibos();
      --BUG 10014 SMARTINEZ 05/05/2009
      vidioma           NUMBER := pac_md_common.f_get_cxtidioma;
      vpasexec          NUMBER(8) := 1;
      vparam            VARCHAR2(500) := 'par¿metros - pnrecibo: ' ||
                                         pnrecibo;
      vobject           VARCHAR2(200) := 'PAC_MD_ADM.F_Get_DatosRecibo_mv';
      comisbruta        FLOAT;
      comisbruta_monpol FLOAT;
      retencio          FLOAT;
      retencio_monpol   FLOAT;
      -- Bug 8745 - 02/03/2009 - RSC -    IAX: Adaptaci¿n iAxis a productos colectivos con certificados
      v_sseguro      NUMBER;
      v_esccero      NUMBER;
      v_tdescrip     VARCHAR2(200);
      v_nada         t_iax_mensajes;
      vparemp_monpol NUMBER := 0;
      -- Fin Bug  8745
      v_sperson      NUMBER;
      vctipapor      NUMBER(3);
      vctipaportante NUMBER(3);
      vdettiprec     NUMBER(3) := NULL;
   BEGIN
      IF pnrecibo IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      --Mirem si agafem la moneda del producte o la moneda de cobrament. XPL#03012011#20592
      vparemp_monpol := NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa,
                                                          'MONEDA_POL'), 0);
      vpasexec       := 2;
      squery         := pac_adm.f_get_datosrecibo_mv(pnrecibo, vidioma);
      -- BUG12679:DRA:28/04/2010
      vpasexec := 3;
      cur      := pac_iax_listvalores.f_opencursor(squery, mensajes);
      vpasexec := 4;

      -- Bug 8745 - 02/03/2009 - RSC -    IAX: Adaptaci¿n iAxis a productos colectivos con certificados
      -- Se asigna v_esccero
      -- BUG 0020761 - 03/01/2012 - JMF: ncuotar
      FETCH cur
         INTO recibo.nrecibo,
              recibo.cagente,
              recibo.cempres,
              recibo.nmovimi,
              recibo.sseguro,
              recibo.femisio,
              recibo.fefecto,
              recibo.fvencim,
              recibo.ctiprec,
              recibo.ttiprec,
              recibo.cdelega,
              recibo.ccobban,
              recibo.cestaux,
              recibo.nanuali,
              recibo.nfracci,
              recibo.cestimp,
              recibo.testimp,
              recibo.festimp,
              recibo.nriesgo,
              recibo.cforpag,
              recibo.tforpag,
              recibo.ctipban,
              recibo.cbancar,
              recibo.nmovanu,
              recibo.cretenc,
              recibo.pretenc,
              recibo.ncuacoa,
              recibo.ctipcoa,
              recibo.ttipcoa,
              recibo.cestsop,
              recibo.nperven,
              recibo.ctransf,
              recibo.cgescob,
              recibo.tgescob,
              recibo.cmanual,
              recibo.tmanual,
              recibo.cestrec,
              recibo.testrec,
              v_esccero,
              recibo.cvalidado,
              recibo.creccia,
              recibo.cmodifi,
              recibo.ncuotar,
              recibo.sperson,
              recibo.ctipcob,
              recibo.ttipcob,
              vctipapor,
              vctipaportante,
              --AAC_INI-CONF_OUTSOURCING-20160906
              recibo.cgescar;
      --AAC_FII-CONF_OUTSOURCING-20160906
      --La columna tipo recibo de detalle poliza puede requerir de algun literal especial que no est¿ en detvalores dependiendo de otros campos
      IF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa,
                                           'LIT_TIP_REC_ESPECIAL'), 0) = 1
      THEN
         IF recibo.ctiprec = 4 AND
            vctipapor = 4 AND
            vctipaportante = 4
         THEN
            vdettiprec := 15;
         ELSIF recibo.ctiprec = 4 AND
               vctipapor = 6 AND
               vctipaportante = 4
         THEN
            vdettiprec := 16;
         ELSIF recibo.ctiprec = 4 AND
               vctipapor = 7 AND
               vctipaportante = 4
         THEN
            vdettiprec := 17;
         ELSIF recibo.ctiprec = 3 AND
               vctipapor = 4 AND
               vctipaportante = 4
         THEN
            vdettiprec := 18;
         ELSIF recibo.ctiprec = 3 AND
               vctipapor = 1 AND
               vctipaportante = 1
         THEN
            vdettiprec := 19;
         ELSE
            vdettiprec := NULL;
         END IF;

         IF vdettiprec IS NOT NULL
         THEN
            BEGIN
               SELECT tatribu
                 INTO recibo.ttiprec
                 FROM detvalores
                WHERE cvalor = 8
                  AND catribu = vdettiprec
                  AND cidioma = vidioma;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  NULL;
            END;
         END IF;
      END IF;

      IF cur%NOTFOUND
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 101731);
         RAISE e_object_error;
      END IF;

      CLOSE cur;

      vpasexec := 5;

      --BUG 9984  - 30/04/2009 - DCT
      IF recibo.ctipban IS NOT NULL
      THEN
         vnumerr := pac_descvalores.f_desctipocuenta(recibo.ctipban, vidioma,
                                                     recibo.ttipban);

         IF vnumerr <> 0
         THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
            RETURN NULL;
         END IF;
      END IF;

      vpasexec := 6;

      -- Bug 8745 - 02/03/2009 - RSC -    IAX: Adaptaci¿n iAxis a productos colectivos con certificados
      --IF v_esccero = 0 THEN
      IF v_esccero = 1
      THEN
         SELECT s.sseguro
           INTO v_sseguro
           FROM seguros s,
                seguros s2
          WHERE s.npoliza = s2.npoliza
            AND s.ncertif = 0
            AND s2.sseguro = recibo.sseguro;

         recibo.sseguro := v_sseguro;
      END IF;

      -- Fin Bug  9383
      vnumerr := f_desagente(recibo.cdelega, recibo.tdelega);
      --        IF vnumerr <>0 THEN
      --            PAC_IOBJ_MENSAJES.CREA_NUEVO_MENSAJE(mensajes,1,vnumerr);
      --            RETURN null;
      --        END IF;
      vnumerr := f_desagente(recibo.cagente, recibo.tagente);
      --Descripci¿n agente.
      --        IF vnumerr <>0 THEN
      --            PAC_IOBJ_MENSAJES.CREA_NUEVO_MENSAJE(mensajes,1,vnumerr);
      --            RETURN null;
      --        END IF;
      vnumerr := f_desempresa(recibo.cempres, NULL, recibo.tempres);

      -- Descripci¿n empresa.
      IF vnumerr <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RETURN NULL;
      END IF;

      vnumerr := f_desagente(f_gestor(recibo.cempres, recibo.cagente,
                                      f_sysdate), recibo.tgestor);

      IF vnumerr <> 0
      THEN
         recibo.tgestor := NULL;
      END IF;

      vpasexec := 7;
      -- vnumerr := f_desagente(recibo.ccobban, recibo.tcobban);    --> 20100723 - JGR - 0015473 - AXIS2105
      -- 20121008 - JLTS - 0020278 - Se a¿ade el campo recibo.tdescrip en lugar de v_tdescrip
      vnumerr := f_get_descobrador(recibo.ccobban, recibo.tdescrip,
                                   recibo.tcobban, v_nada); --> 20100723 - JGR - 0015473 - AXIS2105

      IF vnumerr <> 0
      THEN
         -- recibo.tgestor := NULL; --> 20100723 - JGR - 0015473 - AXIS2105
         recibo.tcobban := NULL; --> 20100723 - JGR - 0015473 - AXIS2105
      END IF;

      IF NVL(ptotagrup, 0) = 1
      THEN
         --Importe total agrupado
         SELECT SUM(itotalr)
           INTO recibo.importe
           FROM vdetrecibos
          WHERE nrecibo IN
                (SELECT nrecunif
                   FROM adm_recunif
                  WHERE nrecibo = pnrecibo --hijos si recibimos un padre
                 UNION
                 SELECT nrecibo
                   FROM adm_recunif
                  WHERE nrecibo = pnrecibo -- padre si recibos un padre
                 UNION
                 SELECT nrecibo
                   FROM recibos
                  WHERE nrecibo = pnrecibo -- en caso que no est¿ unificado
                 UNION
                 SELECT nrecibo -- los otros hijos de un padre, en caso de recibir un recibo hijo por parametro
                   FROM adm_recunif
                  WHERE nrecibo IN (SELECT nrecibo
                                      FROM adm_recunif
                                     WHERE nrecunif = pnrecibo));

         IF vparemp_monpol <> 0
         THEN
            --bug 0027691/149541 se debe mostrar siempre el desglose en el monto de instalacion y si es distinto al monto del producto tambien se debe mostrar este.
            SELECT SUM(itotalr)
              INTO recibo.importe_monpol
              FROM vdetrecibos_monpol
             WHERE nrecibo IN
                   (SELECT nrecunif
                      FROM adm_recunif
                     WHERE nrecibo = pnrecibo --hijos si recibimos un padre
                    UNION
                    SELECT nrecibo
                      FROM adm_recunif
                     WHERE nrecibo = pnrecibo -- padre si recibos un padre
                    UNION
                    SELECT nrecibo
                      FROM recibos
                     WHERE nrecibo = pnrecibo -- en caso que no est¿ unificado
                    UNION
                    SELECT nrecibo -- los otros hijos de un padre, en caso de recibir un recibo hijo por parametro
                      FROM adm_recunif
                     WHERE nrecibo IN
                           (SELECT nrecibo
                              FROM adm_recunif
                             WHERE nrecunif = pnrecibo));
         END IF;
      ELSE
         --bug 0027691/149541 se debe mostrar siempre el desglose en el monto de instalacion y si es distinto al monto del producto tambien se debe mostrar este.
         SELECT itotalr
           INTO recibo.importe
           FROM vdetrecibos
          WHERE nrecibo = pnrecibo;

         IF vparemp_monpol <> 0
         THEN
            SELECT itotalr
              INTO recibo.importe_monpol
              FROM vdetrecibos_monpol
             WHERE nrecibo = pnrecibo;
         END IF;
      END IF;

      -- Bug 7657 - 18/02/2009 - FAL - Afegir concepte comisi¿ del rebut ((YSR) coaseguro cedido recibo unico)
      BEGIN
         --bug 0027691/149541 se debe mostrar siempre el desglose en el monto de instalacion y si es distinto al monto del producto tambien se debe mostrar este.
         SELECT DECODE(ctipcoa, 1, icombru + icedcbr, icombru),
                DECODE(ctipcoa, 1, icomret + icedcrt, icomret)
           INTO comisbruta,
                retencio
           FROM vdetrecibos v,
                recibos     r
          WHERE r.nrecibo = recibo.nrecibo
            AND v.nrecibo = r.nrecibo;

         IF vparemp_monpol <> 0
         THEN
            SELECT DECODE(ctipcoa, 1, icombru + icedcbr, icombru),
                   DECODE(ctipcoa, 1, icomret + icedcrt, icomret)
              INTO comisbruta_monpol,
                   retencio_monpol
              FROM vdetrecibos_monpol v,
                   recibos            r
             WHERE r.nrecibo = recibo.nrecibo
               AND v.nrecibo = r.nrecibo;

            recibo.icomisi_monpol := comisbruta_monpol - retencio_monpol;
         END IF;

         recibo.icomisi := comisbruta - retencio;
      EXCEPTION
         WHEN OTHERS THEN
            recibo.icomisi        := NULL;
            recibo.icomisi_monpol := NULL;
      END;

      vpasexec := 8;

      --BUG20501 - JTS - 28/12/2011
      BEGIN
         -- Bug 21421 - APD - 01/03/2012 - se debe buscar la sucursal de recibosredcom
         /*
                  SELECT sc.cagente
                    INTO recibo.csucursal
                    FROM segurosredcom sc, seguros s, recibos r
                   WHERE r.nrecibo = pnrecibo
                     AND r.sseguro = s.sseguro
                     AND s.sseguro = sc.sseguro
                     AND sc.ctipage = 2;
         */

         --22080 - ICV
         recibo.csucursal := pac_redcomercial.f_busca_padre(recibo.cempres,
                                                            recibo.cagente,
                                                            NULL,
                                                            recibo.fefecto);
         /*SELECT rc.cagente
          INTO recibo.csucursal
          FROM recibosredcom rc
         WHERE rc.nrecibo = recibo.nrecibo
           AND rc.cempres = recibo.cempres
           AND rc.ctipage = 2;*/

         -- fin Bug 21421 - APD - 01/03/2012
         vnumerr := f_desagente(recibo.csucursal, recibo.tsucursal);
      EXCEPTION
         WHEN OTHERS THEN
            recibo.csucursal := NULL;
            recibo.tsucursal := NULL;
      END;

      vpasexec := 9;

      --22080 - ICV - Datos del pagador
      IF recibo.sperson IS NULL
      THEN
--IAXIS-13495 -- 28/05/2020
BEGIN
   SELECT t.sperson
     INTO v_sperson
     FROM recibos r, gescobros t
    WHERE r.nrecibo = recibo.nrecibo AND t.sseguro = r.sseguro;
EXCEPTION
   WHEN NO_DATA_FOUND
   THEN
      BEGIN
         SELECT t.sperson
           INTO v_sperson
           FROM recibos r, tomadores t
          WHERE r.nrecibo = recibo.nrecibo
            AND t.sseguro = r.sseguro
            AND t.nordtom IN (SELECT MIN (tt.nordtom)
                                FROM tomadores tt
                               WHERE tt.sseguro = t.sseguro);
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            v_sperson := recibo.sperson;
      END;
      END;
      --IAXIS-13495 -- 28/05/2020     
      ELSE
         v_sperson := recibo.sperson;
      END IF;

      IF recibo.cbancar IS NOT NULL
      THEN
         BEGIN
            SELECT pc.fvencim
              INTO recibo.fvencim_ccc
              FROM per_ccc pc
             WHERE pc.cbancar = recibo.cbancar
               AND pc.sperson = v_sperson
               AND pc.cagente = ff_agente_cpervisio(recibo.cagente);
         EXCEPTION
            WHEN TOO_MANY_ROWS THEN
               BEGIN
                  SELECT pc.fvencim
                    INTO recibo.fvencim_ccc
                    FROM per_ccc pc
                   WHERE pc.cbancar = recibo.cbancar
                     AND pc.sperson = v_sperson
                     AND pc.cagente = ff_agente_cpervisio(recibo.cagente)
                     AND pc.fbaja IS NULL;
               EXCEPTION
                  WHEN OTHERS THEN
                     recibo.fvencim_ccc := NULL;
               END;
            WHEN OTHERS THEN
               recibo.fvencim_ccc := NULL;
         END;
      END IF;

      vpasexec := 10;

      IF v_sperson IS NOT NULL
      THEN
         recibo.tpagador := f_nombre(v_sperson, 3);
      END IF;

      vpasexec := 11;
      --FiBUG20501 - JTS - 28/12/2011
      recibo.movrecibo := f_get_movrecibos(pnrecibo, mensajes);

      IF recibo.movrecibo IS NULL
      THEN
         RAISE e_object_error;
      END IF;

      recibo.detrecibo := f_get_detrecibos(pnrecibo, mensajes);

      IF recibo.detrecibo IS NULL
      THEN
         RAISE e_object_error;
      END IF;

      recibo.vdetrecibo := f_get_vdetrecibos(pnrecibo, mensajes);

      -- 55.
      IF vparemp_monpol <> 0
      THEN
         recibo.vdetrecibo_monpol := f_get_vdetrecibos_monpol(pnrecibo,
                                                              mensajes);
      END IF;

      IF recibo.vdetrecibo IS NULL
      THEN
         RAISE e_object_error;
      END IF;

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
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_datosrecibo_mv;

   -- BUG12679:DRA:07/05/2010:Fi

   /*************************************************************************
      Devuelve las descripciones para un cobrador bancario
      param in  p_ccobban    : Id. cobrador bancario
      param out p_tdescrip   : Descripci¿n del cobrador
      param out p_tcobban    : Nombre del cobrador
      param in out mensajes  : Mensajes de error
      return                 : 0.- OK
                               1.- error
   *************************************************************************/
   FUNCTION f_get_descobrador(p_ccobban  IN NUMBER,
                              p_tdescrip OUT VARCHAR2,
                              p_tcobban  OUT VARCHAR2,
                              mensajes   IN OUT t_iax_mensajes) RETURN NUMBER IS
      v_pasexec NUMBER(8) := 1;
      v_param   VARCHAR2(200) := 'p_ccobban = ' || p_ccobban;
      v_object  VARCHAR2(200) := 'PAC_MD_ADM.f_descobrador';
      v_error   NUMBER(8);
   BEGIN
      v_error := f_descobrador(p_ccobban, p_tdescrip, p_tcobban);

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
   END f_get_descobrador;

   /*************************************************************************
      Devuelve el nivel de cobbancario
      param in  pdetpoliza    : Detalle de la poliza
      param in  ptipo         : 1-Agente, 2-banco.. producto
      param out pnivel        : Si existe ese nivel 1 : existe, 0 no existe
      param in out mensajes   : Mensajes de error
      return                  : 0.- OK
                                1.- error
   *************************************************************************/
   FUNCTION f_nivel_cobbancario(psproduc IN NUMBER,
                                ptipo    IN NUMBER,
                                pnivel   OUT NUMBER,
                                mensajes OUT t_iax_mensajes) RETURN NUMBER IS
      v_pasexec NUMBER(8) := 1;
      v_param   VARCHAR2(200) := 'ptipo = ' || ptipo;
      v_object  VARCHAR2(200) := 'PAC_MD_ADM.f_nivel_cobbancario';
      v_error   NUMBER(8);
      v_cont    NUMBER;
   BEGIN
      pnivel := 0;

      SELECT COUNT(1)
        INTO v_cont
        FROM cobbancariosel
       WHERE ((ptipo = 1 AND cagente IS NOT NULL) OR
             (ptipo = 2 AND cbanco IS NOT NULL));

      IF v_cont > 0
      THEN
         pnivel := 1;
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
   END f_nivel_cobbancario;

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
                           mensajes         IN OUT t_iax_mensajes,
                           p_lstrecibosunif OUT SYS_REFCURSOR) --0031322/0175728:NSS:12/06/2014
    RETURN NUMBER IS
      v_pasexec NUMBER(8) := 1;
      v_param   VARCHAR2(2000) := 'p_nrecibos';
      v_object  VARCHAR2(200) := 'PAC_MD_ADM.f_agruparecibo';
      v_error   NUMBER(8);
      --
      v_act      VARCHAR2(1);
      v_nrecibo  VARCHAR2(100);
      v_length   NUMBER;
      v_index    NUMBER;
      v_listarec t_lista_id;
      v_obrec    ob_lista_id;
      v_sel      VARCHAR(32000);
      v_cur      SYS_REFCURSOR;
      v_cidioma  NUMBER := pac_md_common.f_get_cxtidioma; -- 21. 0022763 / 0119028
      v_text     VARCHAR2(32000); -- 21. 0022763 / 0119028
      v_text2    VARCHAR2(32000); -- 21. 0022763 / 0119028
      v_conta    NUMBER := 0; -- 21. 0022763 / 0119028
      v_text3    VARCHAR2(32000); -- 21. 0022763 / 0119028
      v_conta3   NUMBER := 0; -- 21. 0022763 / 0119028
      v_sproces  NUMBER; -- bug 35803 - MDS - 04/06/2015
      v_nlinea   NUMBER; -- bug 35803 - MDS - 04/06/2015
   BEGIN
      v_index    := 1;
      v_length   := length(p_nrecibos);
      v_listarec := t_lista_id();

      -- INI bug 35803 - MDS - 04/06/2015
      SELECT sproces.nextval INTO v_sproces FROM dual;

      v_nlinea := 1;

      -- FIN bug 35803 - MDS - 04/06/2015
      WHILE v_index <= v_length
      LOOP
         v_act := SUBSTR(p_nrecibos, v_index, 1);

         IF v_act = ';'
         THEN
            v_obrec     := ob_lista_id();
            v_obrec.idd := v_nrecibo;
            v_listarec.extend;
            v_listarec(v_listarec.last) := v_obrec;

            -- INI bug 35803 - MDS - 04/06/2015
            INSERT INTO int_carga_unificar
               (proceso, nlinea, nrecibo)
            VALUES
               (v_sproces, v_nlinea, v_nrecibo);

            v_nlinea := v_nlinea + 1;
            -- FIN bug 35803 - MDS - 04/06/2015
            v_nrecibo := NULL;
         ELSIF v_index = v_length
         THEN
            v_nrecibo   := v_nrecibo || v_act;
            v_obrec     := ob_lista_id();
            v_obrec.idd := v_nrecibo;
            v_listarec.extend;
            v_listarec(v_listarec.last) := v_obrec;
            v_nrecibo := NULL;
         ELSE
            v_nrecibo := v_nrecibo || v_act;
         END IF;

         v_index := v_index + 1;
      END LOOP;

      v_pasexec := 2;
      --0031322/0175728:NSS;11/06/2014: Unificaci¿n de recibos
      v_error := pac_adm.f_agruparecibo_manual(NULL, NULL, NULL,
                                               pac_md_common.f_get_cxtempresa,
                                               v_listarec);

      IF v_error != 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, v_error);
         RAISE e_object_error;
      END IF;

      v_pasexec := 3;
      -- INI bug 35803 - MDS - 04/06/2015
      /*
            v_sel := 'SELECT nrecunif FROM adm_recunif ' || 'WHERE nrecibo IN('
                     || RTRIM(REPLACE(p_nrecibos, ';', ','), ',') || ')' || 'GROUP BY nrecunif';
      */
      v_sel := 'SELECT nrecunif FROM adm_recunif ' || 'WHERE nrecibo IN(' ||
               'select nrecibo from int_carga_unificar where proceso=' ||
               v_sproces || ') GROUP BY nrecunif';

      -- FIN bug 35803 - MDS - 04/06/2015

      --v_cur := pac_md_listvalores.f_opencursor(v_sel, mensajes);
      OPEN v_cur FOR v_sel;

      FETCH v_cur
         INTO p_nrecunif;

      CLOSE v_cur;

      IF p_nrecunif IS NULL
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes,
                                              -- 2,
                                              pac_md_common.f_get_cxtidioma,
                                              9901222);
         RAISE e_object_error;
         -- 21. 0022763: MDP_A001-Unificacion / Desunificacion de recibos - 0119028 - Inicio
      ELSE
         OPEN v_cur FOR v_sel;

         v_conta := 0;

         LOOP
            FETCH v_cur
               INTO p_nrecunif;

            EXIT WHEN v_cur%NOTFOUND;

            IF p_nrecunif IS NOT NULL
            THEN
               v_conta := v_conta + 1;

               IF v_conta = 1
               THEN
                  v_text2 := v_text2 || p_nrecunif;
               ELSE
                  v_text2 := v_text2 || ', ' || p_nrecunif;
               END IF;
            END IF;
         END LOOP;

         CLOSE v_cur;

         --ini bug 0031322/0175728:NSS:12/06/2014
         p_lstrecibosunif := pac_md_adm.f_get_consultarecibos_mv(NULL, NULL,
                                                                 NULL, NULL,
                                                                 NULL, NULL,
                                                                 NULL, NULL,
                                                                 NULL, NULL,
                                                                 NULL, 1,
                                                                 NULL, NULL,
                                                                 NULL, NULL,
                                                                 NULL, NULL,
                                                                 NULL, 1,
                                                                 NULL, NULL,
                                                                 NULL, NULL,
                                                                 NULL, NULL,
                                                                 NULL, NULL,
                                                                 NULL, NULL,
                                                                 NULL, NULL,
                                                                 NULL,
                                                                 mensajes,
                                                                 NULL,
                                                                 v_text2,
                                                                 NULL, NULL); --recibos agrupados resultantes
         --fin bug 0031322/0175728:NSS:12/06/2014

         -- BUSCAMOS POSIBLE RECIBOS NO AGRUPADOS

         -- INI bug 35803 - MDS - 04/06/2015

         /*
                  v_sel := 'SELECT nrecibo FROM recibos r ' || 'WHERE nrecibo IN('
                           || RTRIM(REPLACE(p_nrecibos, ';', ','), ',') || ')' || ' AND NOT EXISTS '
                           || ' (SELECT 1 FROM adm_recunif a ' || 'WHERE a.nrecibo = r.nrecibo )';
         */
         v_sel := 'SELECT nrecibo FROM recibos r ' || 'WHERE nrecibo IN(' ||
                  'select nrecibo from int_carga_unificar where proceso=' ||
                  v_sproces || ') AND NOT EXISTS ' ||
                  ' (SELECT 1 FROM adm_recunif a ' ||
                  'WHERE a.nrecibo = r.nrecibo )';

         -- FIN bug 35803 - MDS - 04/06/2015
         OPEN v_cur FOR v_sel;

         v_conta3 := 0;

         LOOP
            FETCH v_cur
               INTO p_nrecunif;

            EXIT WHEN v_cur%NOTFOUND;

            IF p_nrecunif IS NOT NULL
            THEN
               v_conta3 := v_conta3 + 1;

               IF v_conta3 = 1
               THEN
                  v_text3 := v_text3 || p_nrecunif;
               ELSE
                  v_text3 := v_text3 || ', ' || p_nrecunif;
               END IF;
            END IF;
         END LOOP;

         CLOSE v_cur;

         IF v_conta3 = 0
         THEN
            -- 9904228 Recibos agrupados generados (#1#): #2#
            v_text := f_axis_literales(9904228, v_cidioma);
         ELSE
            -- 9904286 Recibos agrupados generados (#1#): #2# No se han podido agrupar (#3#): #4#.
            v_text := f_axis_literales(9904286, v_cidioma);
            v_text := REPLACE(v_text, '#3#', v_conta3);
            v_text := REPLACE(v_text, '#4#', v_text3);
         END IF;

         v_text := REPLACE(v_text, '#1#', v_conta);
         v_text := REPLACE(v_text, '#2#', v_text2);
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 0, v_text);
         -- 21. 0022763: MDP_A001-Unificacion / Desunificacion de recibos - 0119028 - Fin
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
                            mensajes   IN OUT t_iax_mensajes) RETURN NUMBER IS
      v_pasexec NUMBER(8) := 1;
      v_param   VARCHAR2(2000) := 'par¿metros - pnrecibo: ' || pnrecibo ||
                                  ', pit1dto: ' || pit1dto ||
                                  ', piprinet: ' || piprinet ||
                                  ', pit1rec: ' || pit1rec || ', pit1con: ' ||
                                  pit1con || ', piips: ' || piips ||
                                  ', pidgs: ' || pidgs || ', piarbitr: ' ||
                                  piarbitr || ', pifng: ' || pifng ||
                                  ', pFEFECTO: ' || pfefecto ||
                                  ', pFVENCIM: ' || pfvencim ||
                                  ', pCRECCIA: ' || pcreccia;
      v_object  VARCHAR2(200) := 'PAC_MD_ADM.f_set_imprecibo';
      vnumerr   NUMBER;
   BEGIN
      v_pasexec := 1;

      IF pnrecibo IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_adm.f_set_imprecibo(pnrecibo, pnriesgo, pit1dto,
                                         piprinet, pit1rec, pit1con, piips,
                                         pidgs, piarbitr, pifng, pfefecto,
                                         pfvencim, pcreccia, picombru,
                                         pcvalidado);

      IF vnumerr <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      ELSE
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 0, 9000840);
      END IF;

      v_pasexec := 2;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005,
                                           v_pasexec, v_param);
         RETURN 1;
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
                            mensajes IN OUT t_iax_mensajes) RETURN NUMBER IS
      v_pasexec     NUMBER(8) := 1;
      v_param       VARCHAR2(2000) := 'par¿metros - pnrecibo: ' || pnrecibo ||
                                      ', pcestrec: ' || pcestrec;
      v_object      VARCHAR2(200) := 'PAC_MD_ADM.f_set_estadorec';
      vnumerr       NUMBER := 0;
      v_cestrec_act NUMBER;
      v_cestrec_ant NUMBER;
      v_ccobban     NUMBER;
      v_cdelega     NUMBER;
      wsmovagr      NUMBER := 0;
      wliqmen       NUMBER := 0;
      wliqlin       NUMBER := 0;
      v_cmodifi     NUMBER := 0;
   BEGIN
      SELECT cestrec,
             cestant
        INTO v_cestrec_act,
             v_cestrec_ant
        FROM movrecibo
       WHERE nrecibo = pnrecibo
         AND fmovfin IS NULL;

      v_pasexec := 2;

      --Info b¿sica del recibo
      SELECT ccobban,
             cdelega
        INTO v_ccobban,
             v_cdelega
        FROM recibos
       WHERE nrecibo = pnrecibo;

      IF ((pcestrec IN (0, 1, 2) AND pcestrec = v_cestrec_act) AND
         NOT (pcestrec = 0 AND (v_cestrec_act = 0 AND v_cestrec_ant = 1)) -- pendiente desde un impagado
         ) OR
         (pcestrec = 4 AND (v_cestrec_act = 0 AND v_cestrec_ant = 1)) -- impagado
      THEN
         vnumerr := 101915;
      END IF;

      v_pasexec := 3;

      IF vnumerr = 0
      THEN
         IF pcestrec = 0
         THEN
            --Pendiente
            IF (v_cestrec_act = 0 AND v_cestrec_ant = 1)
            THEN
               -- si esta impagado, tenemos que anular y hacer un update, porque sino nos lo podra impagado
               vnumerr := f_movrecibo(pnrecibo, 2, NULL, NULL, wsmovagr,
                                      wliqmen, wliqlin, f_sysdate, v_ccobban,
                                      v_cdelega, NULL, NULL, NULL, NULL, NULL,
                                      NULL, NULL, NULL, NULL, NULL, NULL,
                                      NULL, NULL, NULL, NULL, NULL, NULL,
                                      NULL, NULL, NULL, 0);

               IF vnumerr = 0
               THEN
                  BEGIN
                     UPDATE movrecibo
                        SET cestrec = 0, cestant = 0
                      WHERE nrecibo = pnrecibo
                        AND fmovfin IS NULL;
                  EXCEPTION
                     WHEN OTHERS THEN
                        vnumerr := 101915;
                  END;
               END IF;
            ELSE
               vnumerr := f_movrecibo(pnrecibo, 0, NULL, NULL, wsmovagr,
                                      wliqmen, wliqlin, f_sysdate, v_ccobban,
                                      v_cdelega, NULL, NULL, NULL, NULL, NULL,
                                      NULL, NULL, NULL, NULL, NULL, NULL,
                                      NULL, NULL, NULL, NULL, NULL, NULL,
                                      NULL, NULL, NULL, 0);
            END IF;
         ELSIF pcestrec = 1
         THEN
            --Cobrado
            IF v_cestrec_act = 2
            THEN
               --Si esta anulado hay que pasarlo a pendiente
               vnumerr := f_movrecibo(pnrecibo, 0, NULL, NULL, wsmovagr,
                                      wliqmen, wliqlin, f_sysdate, v_ccobban,
                                      v_cdelega, NULL, NULL, NULL, NULL, NULL,
                                      NULL, NULL, NULL, NULL, NULL, NULL,
                                      NULL, NULL, NULL, NULL, NULL, NULL,
                                      NULL, NULL, NULL, 0);
            END IF;

            vnumerr := f_movrecibo(pnrecibo, 1, NULL, NULL, wsmovagr,
                                   wliqmen, wliqlin, f_sysdate, v_ccobban,
                                   v_cdelega, NULL, NULL, NULL, NULL, NULL,
                                   NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                                   NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                                   NULL, 0);
         ELSIF pcestrec = 2
         THEN
            --anurec
            IF v_cestrec_act = 1
            THEN
               --Si esta pagado hay que pasarlo a pendiente
               vnumerr := f_movrecibo(pnrecibo, 0, NULL, NULL, wsmovagr,
                                      wliqmen, wliqlin, f_sysdate, v_ccobban,
                                      v_cdelega, NULL, NULL, NULL, NULL, NULL,
                                      NULL, NULL, NULL, NULL, NULL, NULL,
                                      NULL, NULL, NULL, NULL, NULL, NULL,
                                      NULL, NULL, NULL, 0);
            END IF;

            vnumerr := f_movrecibo(pnrecibo, 2, NULL, NULL, wsmovagr,
                                   wliqmen, wliqlin, f_sysdate, v_ccobban,
                                   v_cdelega, NULL, NULL, NULL, NULL, NULL,
                                   NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                                   NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                                   NULL, 0);
         ELSIF pcestrec = 3
         THEN
            --renta
            IF v_cestrec_act IN (1, 2)
            THEN
               --Si pagado o anulado hay que pasarlo a pendiente
               vnumerr := f_movrecibo(pnrecibo, 0, NULL, NULL, wsmovagr,
                                      wliqmen, wliqlin, f_sysdate, v_ccobban,
                                      v_cdelega, NULL, NULL, NULL, NULL, NULL,
                                      NULL, NULL, NULL, NULL, NULL, NULL,
                                      NULL, NULL, NULL, NULL, NULL, NULL,
                                      NULL, NULL, NULL, 0);
            END IF;

            vnumerr := f_movrecibo(pnrecibo, 3, NULL, NULL, wsmovagr,
                                   wliqmen, wliqlin, f_sysdate, v_ccobban,
                                   v_cdelega, NULL, NULL, NULL, NULL, NULL,
                                   NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                                   NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                                   NULL, 0);
         ELSIF pcestrec = 4
         THEN
            -- Impagado
            IF v_cestrec_act IN (0)
            THEN
               vnumerr := f_movrecibo(pnrecibo, 1, NULL, NULL, wsmovagr,
                                      wliqmen, wliqlin, f_sysdate, v_ccobban,
                                      v_cdelega, NULL, NULL, NULL, NULL, NULL,
                                      NULL, NULL, NULL, NULL, NULL, NULL,
                                      NULL, NULL, NULL, NULL, NULL, NULL,
                                      NULL, NULL, NULL, 0);
            ELSIF v_cestrec_act IN (2, 3)
            THEN
               vnumerr := f_movrecibo(pnrecibo, 0, NULL, NULL, wsmovagr,
                                      wliqmen, wliqlin, f_sysdate, v_ccobban,
                                      v_cdelega, NULL, NULL, NULL, NULL, NULL,
                                      NULL, NULL, NULL, NULL, NULL, NULL,
                                      NULL, NULL, NULL, NULL, NULL, NULL,
                                      NULL, NULL, NULL, 0);
               vnumerr := f_movrecibo(pnrecibo, 1, NULL, NULL, wsmovagr,
                                      wliqmen, wliqlin, f_sysdate, v_ccobban,
                                      v_cdelega, NULL, NULL, NULL, NULL, NULL,
                                      NULL, NULL, NULL, NULL, NULL, NULL,
                                      NULL, NULL, NULL, NULL, NULL, NULL,
                                      NULL, NULL, NULL, 0);
            END IF;

            vnumerr := f_movrecibo(pnrecibo, 0, NULL, NULL, wsmovagr,
                                   wliqmen, wliqlin, f_sysdate, v_ccobban,
                                   v_cdelega, NULL, NULL, NULL, NULL, NULL,
                                   NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                                   NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                                   NULL, 0);
         END IF;
      END IF;

      IF vnumerr <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      ELSE
         --updateamos el cmodifi de recibos
         SELECT cmodifi
           INTO v_cmodifi
           FROM recibos
          WHERE nrecibo = pnrecibo;

         --Si el recibo no esta modificado, o se le ha hecho una modificaci¿n de estado se marca como modificaci¿n de estado
         IF NVL(v_cmodifi, 0) IN (0, 2)
         THEN
            v_cmodifi := 2;
         ELSE
            --Si el recibo tiene una modificaci¿n diferente a la que vamos a realizar, se marca como varias modificaciones.
            v_cmodifi := 9;
         END IF;

         UPDATE recibos SET cmodifi = 1 WHERE nrecibo = pnrecibo;

         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 0, 9000840);
      END IF;

      v_pasexec := 4;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005,
                                           v_pasexec, v_param);
         RETURN 1;
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
   END f_set_estadorec;

   /*************************************************************************
      11/06/2012 - 19. 0022327: MDP_A001-Consulta de recibos - 0115278
      Extrae informaci¿n extra del recibo.
      param in out mensajes  : Mensajes de error
      return                 : 0.- OK
                               1.- error
   *************************************************************************/
   FUNCTION f_get_datosrecibo_det(pcempres IN NUMBER,
                                  pnrecibo IN NUMBER,
                                  pcidioma IN NUMBER DEFAULT NULL,
                                  mensajes IN OUT t_iax_mensajes)
      RETURN SYS_REFCURSOR IS
      v_pasexec NUMBER(8) := 1;
      v_param   VARCHAR2(2000) := 'par¿metros -  pcempres: ' || pcempres ||
                                  ', pnrecibo: ' || pnrecibo ||
                                  ', pcidioma: ' || pcidioma;
      v_object  VARCHAR2(200) := 'PAC_MD_ADM.f_get_datosrecibo_det';
      vnumerr   NUMBER;
      vcursor   SYS_REFCURSOR;
      vsquery   VARCHAR2(9000);
      vidioma   NUMBER := NVL(pcidioma, pac_md_common.f_get_cxtidioma);
      v_max_reg NUMBER; -- n¿mero m¿xim de registres mostrats
   BEGIN
      v_pasexec := 1;

      IF pnrecibo IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vsquery := pac_adm.f_get_datosrecibo_det(pcempres, pnrecibo, pcidioma);
      vcursor := pac_iax_listvalores.f_opencursor(vsquery, mensajes);

      IF pac_md_log.f_log_consultas(vsquery, v_object, 1, 4, mensajes) <> 0
      THEN
         IF vcursor%ISOPEN
         THEN
            CLOSE vcursor;
         END IF;
      END IF;

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
   END f_get_datosrecibo_det;

   /**********************************************************************************************
      11/06/2012 - 40. 0022327: MDP_A001-Consulta de recibos - 0115278
      Extrae la informaci¿n de la tala de complementos de recibos (hist¿rico de acciones)
      pnrecibo     IN Recibo.
      pcidioma     IN C¿digo de idioma
   ************************************************************************************************/
   FUNCTION f_get_recibos_comp(pnrecibo IN NUMBER,
                               pcidioma IN NUMBER DEFAULT NULL,
                               mensajes IN OUT t_iax_mensajes)
      RETURN SYS_REFCURSOR IS
      v_pasexec NUMBER(8) := 1;
      v_param   VARCHAR2(2000) := 'par¿metros -  pnrecibo: ' || pnrecibo ||
                                  ', pcidioma: ' || pcidioma;
      v_object  VARCHAR2(200) := 'PAC_MD_ADM.f_get_recibos_comp';
      vnumerr   NUMBER;
      vcursor   SYS_REFCURSOR;
      vsquery   VARCHAR2(9000);
      vidioma   NUMBER := NVL(pcidioma, pac_md_common.f_get_cxtidioma);
      v_max_reg NUMBER; -- n¿mero m¿xim de registres mostrats
   BEGIN
      v_pasexec := 1;

      IF pnrecibo IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vsquery := pac_adm.f_get_recibos_comp(pnrecibo, pcidioma);
      vcursor := pac_iax_listvalores.f_opencursor(vsquery, mensajes);

      IF pac_md_log.f_log_consultas(vsquery, v_object, 1, 4, mensajes) <> 0
      THEN
         IF vcursor%ISOPEN
         THEN
            CLOSE vcursor;
         END IF;
      END IF;

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
   END f_get_recibos_comp;

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
      vobjectname   VARCHAR2(500) := 'pac_md_adm.f_get_matriculas';
      vparam        VARCHAR2(50);
      vpasexec      NUMBER(5) := 1;
      vnumerr       NUMBER(8) := 0;
      vsquery       VARCHAR2(2000);
      vsquery_total VARCHAR2(9000);
      vrefcursor    SYS_REFCURSOR;
      ---
      vnum_dades NUMBER(9) := 0;
      vempresa   VARCHAR2(400);
      vnmatric   VARCHAR2(2000);
      vnpoliza   seguros.npoliza%TYPE;
      vtcobban   VARCHAR2(2000);
      vcbancar   notificaciones.cbancar%TYPE;
      vttipo     VARCHAR2(2000);
      vtbanco    VARCHAR2(2000);
      vtestado   VARCHAR2(2000);
      v_max_reg  parinstalacion.nvalpar%TYPE;
      vcont      NUMBER := 0;
      vmsg       VARCHAR2(500); -- Mostrar mensaje en pantalla si est¿ limitado
      e_error_controlat EXCEPTION;
   BEGIN
      v_max_reg := f_parinstalacion_n('N_MAX_REG'); -- Mostrar mensaje en pantalla si est¿ limitado

      --CONTROL DE PARAMETROS DE ENTRADA
      --Comprovaci¿ de par¿metres d'entrada
      IF pcempres IS NULL
      THEN
         vparam := 'Par¿metros 1';
         RAISE e_error_controlat;
      END IF;

      -- El cobrador bancario es obligatorio
      /*
      IF NVL(pac_parametros.f_parempresa_n(pcempres, 'DOMI_COBBAN'), 0) = 1 THEN
         IF pccobban IS NULL THEN
            vparam := 'Par¿metro - Cobban';
            RAISE e_error_controlat;

         END IF;
      END IF;
      */
      vsquery_total := pac_adm.f_get_matriculas(pcempres, pnpoliza, pncertif,
                                                pnrecibo, pccobban, pnmatric,
                                                pfenvini, pfenvfin, psperson,
                                                ptipo, pcidioma);

      IF vsquery_total IS NOT NULL
      THEN
         vrefcursor := pac_md_listvalores.f_opencursor(vsquery_total,
                                                       mensajes);

         IF vrefcursor IS NOT NULL
         THEN
            LOOP
               FETCH vrefcursor
                  INTO vnmatric,
                       vnpoliza,
                       vtcobban,
                       vcbancar,
                       vttipo,
                       vtbanco,
                       vtestado;

               vcont := vcont + 1;
               EXIT WHEN vrefcursor%NOTFOUND;
            END LOOP;

            --Si el cursor no te dades
            IF vnmatric IS NULL
            THEN
               IF vrefcursor%ISOPEN
               THEN
                  CLOSE vrefcursor;
               END IF;
            END IF;

            -- Mostrar mensaje en pantalla si est¿ limitado
            IF vcont > (v_max_reg + 1)
            THEN
               vmsg := f_axis_literales(9901234,
                                        pac_iax_common.f_get_cxtidioma);
               vmsg := REPLACE(vmsg, '{0}', v_max_reg);
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 0, vmsg);
            END IF;

            --INICIALIZAR DE NUEVO
            vrefcursor := pac_md_listvalores.f_opencursor(vsquery_total,
                                                          mensajes);
            RETURN vrefcursor;
         ELSE
            RETURN NULL;
         END IF;
      END IF;
   EXCEPTION
      WHEN e_error_controlat THEN
         IF vrefcursor%ISOPEN
         THEN
            CLOSE vrefcursor;
         END IF;

         IF vparam = 'Par¿metros 1'
         THEN
            -- El campo empresa ¿s obligatorio
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 0,
                                                 f_axis_literales(180500,
                                                                   pac_iax_common.f_get_cxtidioma));
         ELSE
            -- Falta informar el cobrador bancario
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 0,
                                                 f_axis_literales(120081,
                                                                   pac_iax_common.f_get_cxtidioma));
         END IF;

         RETURN vrefcursor;
      WHEN e_param_error THEN
         IF vrefcursor%ISOPEN
         THEN
            CLOSE vrefcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005,
                                           vpasexec, vparam);
         RETURN vrefcursor;
      WHEN e_object_error THEN
         IF vrefcursor%ISOPEN
         THEN
            CLOSE vrefcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006,
                                           vpasexec, vparam);
         RETURN NULL; --vrefcursor;
      WHEN OTHERS THEN
         IF vrefcursor%ISOPEN
         THEN
            CLOSE vrefcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001,
                                           vpasexec, vparam, NULL, SQLCODE,
                                           SQLERRM);
         RETURN NULL;
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
      vobjectname   VARCHAR2(500) := 'pac_md_adm.f_get_matriculas_det';
      vparam        VARCHAR2(50);
      vpasexec      NUMBER(5) := 1;
      vnumerr       NUMBER(8) := 0;
      vsquery       VARCHAR2(2000);
      vsquery_total VARCHAR2(9000);
      vrefcursor    SYS_REFCURSOR;
      ---
      vtempres   VARCHAR2(2000);
      vsproces   NUMBER;
      vnnumnif   VARCHAR2(2000);
      vtpagador  VARCHAR2(2000);
      vtestado   VARCHAR2(2000);
      vtcobban   VARCHAR2(2000);
      vcbancar   VARCHAR2(2000);
      vttipo     VARCHAR2(2000);
      vtbanco    VARCHAR2(2000);
      vnpoliza   VARCHAR2(2000);
      vnrecibo   VARCHAR2(2000);
      vfefecto   VARCHAR2(2000);
      vtestrec   VARCHAR2(2000);
      vsubestado VARCHAR2(2000);
      vfenvio    VARCHAR2(2000);
      vffiledev  VARCHAR2(2000);
      vcnotest   VARCHAR2(2000);
      vcnoterr   VARCHAR2(2000);
      vtfileenv  VARCHAR2(2000);
      vtfiledev  VARCHAR2(2000);
      ---
      vnum_dades NUMBER(9) := 0;
      v_max_reg  parinstalacion.nvalpar%TYPE;
      vcont      NUMBER := 0;
      vmsg       VARCHAR2(500); -- Mostrar mensaje en pantalla si est¿ limitado
      e_error_controlat EXCEPTION;
   BEGIN
      v_max_reg := f_parinstalacion_n('N_MAX_REG'); -- Mostrar mensaje en pantalla si est¿ limitado

      --CONTROL DE PARAMETROS DE ENTRADA
      --Comprovaci¿ de par¿metres d'entrada
      IF pnmatric IS NULL
      THEN
         vparam := 'Par¿metros 1';
         RAISE e_error_controlat;
      END IF;

      vsquery_total := pac_adm.f_get_matriculas_det(pnmatric, pcidioma);

      IF vsquery_total IS NOT NULL
      THEN
         vrefcursor := pac_md_listvalores.f_opencursor(vsquery_total,
                                                       mensajes);

         IF vrefcursor IS NOT NULL
         THEN
            LOOP
               FETCH vrefcursor
                  INTO vtempres,
                       vsproces,
                       vnnumnif,
                       vtpagador,
                       vtestado,
                       vtcobban,
                       vcbancar,
                       vttipo,
                       vtbanco,
                       vnpoliza,
                       vnrecibo,
                       vfefecto,
                       vtestrec,
                       vsubestado,
                       vfenvio,
                       vffiledev,
                       vcnotest,
                       vcnoterr,
                       vtfileenv,
                       vtfiledev;

               vcont := vcont + 1;
               EXIT WHEN vrefcursor%NOTFOUND;
            END LOOP;

            --Si el cursor no te dades
            IF vsproces IS NULL
            THEN
               IF vrefcursor%ISOPEN
               THEN
                  CLOSE vrefcursor;
               END IF;
            END IF;

            -- Mostrar mensaje en pantalla si est¿ limitado
            IF vcont > (v_max_reg + 1)
            THEN
               vmsg := f_axis_literales(9901234,
                                        pac_iax_common.f_get_cxtidioma);
               vmsg := REPLACE(vmsg, '{0}', v_max_reg);
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 0, vmsg);
            END IF;

            --INICIALIZAR DE NUEVO
            vrefcursor := pac_md_listvalores.f_opencursor(vsquery_total,
                                                          mensajes);
            RETURN vrefcursor;
         ELSE
            RETURN NULL;
         END IF;
      END IF;
   EXCEPTION
      WHEN e_error_controlat THEN
         IF vrefcursor%ISOPEN
         THEN
            CLOSE vrefcursor;
         END IF;

         IF vparam = 'Par¿metros 1'
         THEN
            -- Matr¿cula no informada
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 0,
                                                 f_axis_literales(9000993,
                                                                   pac_iax_common.f_get_cxtidioma));
         END IF;

         RETURN vrefcursor;
      WHEN e_param_error THEN
         IF vrefcursor%ISOPEN
         THEN
            CLOSE vrefcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005,
                                           vpasexec, vparam);
         RETURN vrefcursor;
      WHEN e_object_error THEN
         IF vrefcursor%ISOPEN
         THEN
            CLOSE vrefcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006,
                                           vpasexec, vparam);
         RETURN NULL; --vrefcursor;
      WHEN OTHERS THEN
         IF vrefcursor%ISOPEN
         THEN
            CLOSE vrefcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001,
                                           vpasexec, vparam, NULL, SQLCODE,
                                           SQLERRM);
         RETURN NULL;
   END f_get_matriculas_det;

   /*************************************************************************
      29/05/2012 - 19. 0022327: MDP_A001-Consulta de recibos - 0115278
      Funci¿n que para actualizar los importes de los recibos
      param in out mensajes  : Mensajes de error
      return                 : 0.- OK
                               1.- error
   *************************************************************************/
   FUNCTION f_get_detrecibo_gtias(pnrecibo IN NUMBER,
                                  pcidioma IN NUMBER,
                                  pnriesgo IN NUMBER DEFAULT NULL,
                                  pcgarant IN NUMBER DEFAULT NULL,
                                  mensajes IN OUT t_iax_mensajes)
      RETURN SYS_REFCURSOR IS
      v_pasexec NUMBER(8) := 1;
      v_param   VARCHAR2(2000) := 'par¿metros - pnrecibo: ' || pnrecibo ||
                                  ', pcidioma: ' || pcidioma ||
                                  ', pnriesgo: ' || pnriesgo ||
                                  ', pcgarant: ' || pcgarant;
      v_object  VARCHAR2(200) := 'PAC_MD_ADM.f_get_detrecibo_gtias';
      vnumerr   NUMBER;
      vcursor   SYS_REFCURSOR;
      --IAXIS-3592 -- ECP--27/05/2019
      vsquery   VARCHAR2(9000);
      --IAXIS-3592 -- ECP--27/05/2019
      vidioma   NUMBER := pac_md_common.f_get_cxtidioma;
      v_max_reg NUMBER; -- n¿mero m¿xim de registres mostrats
   BEGIN
      v_pasexec := 1;

      IF pnrecibo IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vsquery := pac_adm.f_get_detrecibo_gtias(pnrecibo, pcidioma, pnriesgo,
                                               pcgarant);
      vcursor := pac_iax_listvalores.f_opencursor(vsquery, mensajes);
      --genera error por el query ser muy grande
     /* IF pac_md_log.f_log_consultas(substr(vsquery,1,4000),
                                    'PAC_MD_ADM.F_f_get_detrecibo_gtias', 1,
                                    4, mensajes) <> 0
      THEN
         IF vcursor%ISOPEN
         THEN
            CLOSE vcursor;
         END IF;
      END IF;*/

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
   END f_get_detrecibo_gtias;

   /*************************************************************************
      29/05/2012 - 19. 0022327: MDP_A001-Consulta de recibos - 0115278
      Extrae la informaci¿n detallada del recibo por garant¿as.
      param in out mensajes  : Mensajes de error
      return                 : 0.- OK
                               1.- error
   *************************************************************************/
   FUNCTION f_get_adm_recunif(pnrecibo IN NUMBER,
                              pcidioma IN NUMBER,
                              mensajes IN OUT t_iax_mensajes)
      RETURN SYS_REFCURSOR IS
      v_pasexec NUMBER(8) := 1;
      v_param   VARCHAR2(2000) := 'par¿metros - pnrecibo: ' || pnrecibo ||
                                  ', pcidioma: ' || pcidioma;
      v_object  VARCHAR2(200) := 'PAC_MD_ADM.f_get_adm_recunif';
      vnumerr   NUMBER;
      vcursor   SYS_REFCURSOR;
      vsquery   VARCHAR2(9000);
      vidioma   NUMBER := pac_md_common.f_get_cxtidioma;
      v_max_reg NUMBER; -- n¿mero m¿xim de registres mostrats
   BEGIN
      v_pasexec := 1;

      IF pnrecibo IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vsquery := pac_adm.f_get_adm_recunif(pnrecibo, pcidioma);
      vcursor := pac_iax_listvalores.f_opencursor(vsquery, mensajes);

      IF pac_md_log.f_log_consultas(vsquery,
                                    'PAC_MD_ADM.F_f_get_adm_recunif', 1, 4,
                                    mensajes) <> 0
      THEN
         IF vcursor%ISOPEN
         THEN
            CLOSE vcursor;
         END IF;
      END IF;

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
   END f_get_adm_recunif;

   /*************************************************************************
      17/07/2012 - 0022760: MDP_A001- Gedox a recibos
      Extrae los documentos asociados al recibo
      param in out mensajes  : Mensajes de error
      return                 : 0.- OK
                               1.- error
   *************************************************************************/
   FUNCTION f_get_recdocs(pnrecibo IN NUMBER,
                          mensajes IN OUT t_iax_mensajes) RETURN SYS_REFCURSOR IS
      v_pasexec NUMBER(8) := 1;
      v_param   VARCHAR2(2000) := 'par¿metros - pnrecibo: ' || pnrecibo;
      v_object  VARCHAR2(200) := 'PAC_MD_ADM.f_get_recdocs';
      vnumerr   NUMBER;
      vcursor   SYS_REFCURSOR;
      vsquery   VARCHAR2(9000);
      vidioma   NUMBER := pac_md_common.f_get_cxtidioma;
   BEGIN
      v_pasexec := 1;

      IF pnrecibo IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      /*vsquery :=
      ' select nrecibo, ndocume, iddoc, fdate, tuser from recibo_documentos where nrecibo = '
      || pnrecibo || ' order by ndocume asc ';*/
      vsquery := ' SELECT dr.sseguro, dr.nrecibo, dr.iddocgedox iddoc,
       pac_axisgedox.f_get_descdoc(dr.iddocgedox) tdescrip,
       SUBSTR(pac_axisgedox.f_get_filedoc(dr.iddocgedox),
              INSTR(pac_axisgedox.f_get_filedoc(dr.iddocgedox), ''\'', -1) + 1,
              LENGTH(pac_axisgedox.f_get_filedoc(dr.iddocgedox))) fichero,
              pac_axisgedox.f_get_usuario(dr.iddocgedox) cusuari,
              (select tusunom from  usuarios where cusuari =pac_axisgedox.f_get_usuario(dr.iddocgedox)) tuser,
              pac_axisgedox.f_get_falta(dr.iddocgedox) fdate,
       rd.ndocume, rd.nimpresiones
  FROM documrecibos dr, recibo_documentos rd
 WHERE dr.nrecibo = rd.nrecibo(+)
   AND dr.iddocgedox = rd.iddoc(+)
   and dr.nrecibo = ' || pnrecibo ||
                 ' order by iddocgedox asc,ndocume asc ';
      vcursor := pac_md_listvalores.f_opencursor(vsquery, mensajes);

      IF pac_md_log.f_log_consultas(vsquery, 'PAC_MD_ADM.f_get_recdocs', 1,
                                    4, mensajes) <> 0
      THEN
         IF vcursor%ISOPEN
         THEN
            CLOSE vcursor;
         END IF;
      END IF;

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
                         mensajes IN OUT t_iax_mensajes) RETURN NUMBER IS
      v_pasexec NUMBER(8) := 1;
      v_param   VARCHAR2(2000) := 'par¿metros - pnrecibo: ' || pnrecibo;
      v_object  VARCHAR2(200) := 'PAC_MD_ADM.f_set_docimp';
      vnumerr   NUMBER;
   BEGIN
      IF pnrecibo IS NULL OR
         pndocume IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      UPDATE recibo_documentos
         SET nimpresiones = nimpresiones + 1
       WHERE nrecibo = pnrecibo
         AND ndocume = pndocume;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005,
                                           v_pasexec, v_param);
         RETURN 1;
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
   END f_set_docimp;

   -- 21. 0022763: MDP_A001-Unificacion / Desunificacion de recibos - 0119028 - Inicio
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
   FUNCTION f_desagruparecibo(p_nrecibos IN CLOB,
                              pfanulac   IN DATE DEFAULT NULL,
                              pcidioma   IN NUMBER DEFAULT NULL,
                              mensajes   IN OUT t_iax_mensajes) RETURN NUMBER IS
      err         NUMBER := 0;
      vobjectname VARCHAR2(500) := 'PAC_MD_ADM.F_DESAGRUPARECIBO';
      vparam      VARCHAR2(500) := 'par¿metros - p_nrecibos: ' ||
                                   p_nrecibos || ' - pfanulac: ' ||
                                   pfanulac || ' - pcidioma: ' || pcidioma;
      vpasexec    NUMBER(5) := 1;
      v_act       VARCHAR2(1);
      v_nrecibo   VARCHAR2(100);
      v_nrec      VARCHAR2(100);
      v_length    NUMBER;
      v_index     NUMBER;
      verror      NUMBER;
      vcempres    NUMBER := pac_md_common.f_get_cxtempresa;
      vsproces    NUMBER;
      vnnumlin    NUMBER;
      vfanulac    DATE := NVL(pfanulac, f_sysdate);
      vcidioma    NUMBER := NVL(pcidioma, pac_md_common.f_get_cxtidioma);
   BEGIN
      IF p_nrecibos IS NULL
      THEN
         RAISE e_param_error;
      ELSE
         -- 9903942 Desunificaci¿n de recibos
         --Insertamos en la tabla PROCESOSCAB el registro identificativo de proceso -----
         verror   := f_procesini(f_user, vcempres, 'INICIO',
                                 f_axis_literales(9903942, vcidioma),
                                 vsproces);
         v_index  := 1;
         v_length := length(p_nrecibos);

         WHILE v_index <= v_length
         LOOP
            v_act := SUBSTR(p_nrecibos, v_index, 1);

            IF v_act = ';'
            THEN
               v_nrec    := v_nrecibo;
               v_nrecibo := NULL;
            ELSIF v_index = v_length
            THEN
               v_nrecibo := v_nrecibo || v_act;
               v_nrec    := v_nrecibo;
               v_nrecibo := NULL;
            ELSE
               v_nrec    := NULL;
               v_nrecibo := v_nrecibo || v_act;
            END IF;

            v_index := v_index + 1;

            IF v_nrec IS NOT NULL
            THEN
               err := pac_gestion_rec.f_desagruparecibo(v_nrec, vfanulac,
                                                        vcidioma);

               -- 9904102 Desunificaci¿n de recibos
               IF err = 0
               THEN
                  err := f_proceslin(vsproces,
                                     SUBSTR(f_axis_literales(9904102,
                                                              vcidioma) || ':' ||
                                             v_nrec || ' OK', 1, 120), 0,
                                     vnnumlin);
               ELSE
                  err := f_proceslin(vsproces,
                                     SUBSTR(f_axis_literales(9904102,
                                                              vcidioma) || ':' ||
                                             v_nrec || ' ' ||
                                             f_axis_literales(err, vcidioma), 1,
                                             120), 0, vnnumlin);
                  RAISE NO_DATA_FOUND;
               END IF;
            END IF;
         END LOOP;
      END IF;

      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 109904);
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

   -- 21. 0022763: MDP_A001-Unificacion / Desunificacion de recibos - 0119028 - Fin

   -- 24.0        06/11/2013   CEC              24. 0026295: RSA702-Desarrollar el modulo de Caja
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
      vobjectname VARCHAR2(500) := 'PAC_MD_ADM.F_Get_Consrecibos_Multimoneda';
      vparam      VARCHAR2(500) := 'par¿metros - pnrecibo: ' || pnrecibo ||
                                   ', pcempres: ' || pcempres ||
                                   ', pnpoliza: ' || pnpoliza ||
                                   ', pcmonpag: ' || pcmonpag ||
                                   ', pitem: ' || pitem || ', pcestrec: ' ||
                                   pcestrec || ', ptipo' || ptipo ||
                                   ', psperson: ' || psperson ||
                                   ', pcidioma: ' || pcidioma ||
                                   ', pfemisio: ' || pfemisio;
      vpasexec    NUMBER(5) := 1;
      vnumerr     NUMBER(8) := 0;
      vcursor     SYS_REFCURSOR;
      vsquery     VARCHAR2(9000);
      vidioma     NUMBER := pac_md_common.f_get_cxtidioma;
      v_max_reg   NUMBER; -- n¿mero m¿xim de registres mostrats
      vcondicion  VARCHAR2(4000);
   BEGIN
      vpasexec := 1;
      vsquery  := pac_adm.f_get_consrecibos_multimoneda(pcempres, pnrecibo,
                                                        pnpoliza, pitem,
                                                        pcestrec, pcmonpag,
                                                        ptipo, psperson,
                                                        pcidioma, pfemisio);
      -- Fin bug 18908 - 18/07/2011 - SRA
      vcursor := pac_iax_listvalores.f_opencursor(vsquery, mensajes);

      IF pac_md_log.f_log_consultas(vsquery,
                                    'PAC_MD_ADM.F_Get_Consrecibos_Multimoneda',
                                    1, 4, mensajes) <> 0
      THEN
         IF vcursor%ISOPEN
         THEN
            CLOSE vcursor;
         END IF;
      END IF;

      RETURN vcursor;
   EXCEPTION
      WHEN OTHERS THEN
         IF vcursor%ISOPEN
         THEN
            CLOSE vcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001,
                                           vpasexec, vparam, NULL, SQLCODE,
                                           SQLERRM);
         RETURN vcursor;
   END f_get_consrecibos_multimoneda;
-- fin recibos multimoneda;
--IGIL_INI-CONF_603
  FUNCTION f_get_detrecibos_det_fcambio(
      pnrecibo IN NUMBER,
      pconcep  IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
    RETURN t_iax_detrecibo_det
  IS
    vnumerr NUMBER(8) := 0;
    squery  VARCHAR2(2000);
    cur sys_refcursor;
    detrecibo_det_fcambio ob_iax_detrecibo_det := ob_iax_detrecibo_det();
    detrecibos_det_fcambio t_iax_detrecibo_det := t_iax_detrecibo_det();
    vidioma  NUMBER                                     := pac_md_common.f_get_cxtidioma;
    vpasexec NUMBER(8)                                  := 1;
    vparam   VARCHAR2(500)                              := 'par¿metros - pnrecibo: ' || pnrecibo || ', pconcep: ' || pconcep;
    vobject  VARCHAR2(200)                              := 'PAC_MD_ADM.F_Get_Detrecibos_det_fcambio';
    numrecs  NUMBER;
    v_error  NUMBER;
    vnmovimi NUMBER; -- Bug 26923/148935 - 11/07/2013 - AMC
  BEGIN
    vpasexec    := 1;
    IF pnrecibo IS NULL OR pconcep IS NULL THEN
      RAISE e_param_error;
    END IF;
    vpasexec := 2;
    squery   := pac_adm.f_get_detrecibos_det_fcambio(pac_md_common.f_get_cxtempresa, pnrecibo, pconcep); -- BUG14202:DRA:22/04/2010
    -- BUG14202:DRA:22/04/2010
    OPEN cur FOR squery;
    vpasexec := 4;
    LOOP
      FETCH cur
      INTO detrecibo_det_fcambio.cgarant,
        detrecibo_det_fcambio.nriesgo,
        detrecibo_det_fcambio.iconcep,
        detrecibo_det_fcambio.iconcep_monpol,
        detrecibo_det_fcambio.cageven,
        detrecibo_det_fcambio.nmovima;
      EXIT
    WHEN cur%NOTFOUND;
      v_error := f_desgarantia(detrecibo_det_fcambio.cgarant, vidioma, detrecibo_det_fcambio.tgarant);
      DECLARE
        vsseguro recibos.sseguro%TYPE;
        vfemisio recibos.femisio%TYPE;
        vtriesgo1 VARCHAR2(250);
        vtriesgo2 VARCHAR2(250);
        vtriesgo3 VARCHAR2(250);
      BEGIN
        SELECT sseguro,
          femisio,
          nmovimi
        INTO vsseguro,
          vfemisio,
          vnmovimi -- Bug 26923/148935 - 11/07/2013 - AMC
        FROM recibos
        WHERE nrecibo = pnrecibo;
        v_error      := f_desriesgo(vsseguro, detrecibo_det_fcambio.nriesgo, vfemisio, vidioma, vtriesgo1, vtriesgo2, vtriesgo3, vnmovimi -- Bug 26923/148935 - 11/07/2013 - AMC
        );
        IF v_error                         = 0 THEN
          IF vtriesgo1                    IS NOT NULL THEN
            detrecibo_det_fcambio.triesgo := detrecibo_det_fcambio.triesgo || vtriesgo1;
          END IF;
          IF vtriesgo2                       IS NOT NULL THEN
            IF detrecibo_det_fcambio.triesgo IS NOT NULL THEN
              detrecibo_det_fcambio.triesgo  := detrecibo_det_fcambio.triesgo || ' ';
            END IF;
            detrecibo_det_fcambio.triesgo := detrecibo_det_fcambio.triesgo || vtriesgo2;
          END IF;
          IF vtriesgo3                       IS NOT NULL THEN
            IF detrecibo_det_fcambio.triesgo IS NOT NULL THEN
              detrecibo_det_fcambio.triesgo  := detrecibo_det_fcambio.triesgo || ' ';
            END IF;
            detrecibo_det_fcambio.triesgo := detrecibo_det_fcambio.triesgo || vtriesgo3;
          END IF;
        ELSE
          detrecibo_det_fcambio.triesgo := NULL;
        END IF;
      EXCEPTION
      WHEN NO_DATA_FOUND THEN
        detrecibo_det_fcambio.triesgo := NULL;
      END;
      detrecibos_det_fcambio.EXTEND;
      detrecibos_det_fcambio(detrecibos_det_fcambio.LAST) := detrecibo_det_fcambio;
      detrecibo_det_fcambio                               := ob_iax_detrecibo_det();
      vpasexec                                            := 6;
    END LOOP;
    CLOSE cur;
    RETURN detrecibos_det_fcambio;
  EXCEPTION
  WHEN e_param_error THEN
    pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
    RETURN NULL;
  WHEN e_object_error THEN
    pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
    RETURN NULL;
  WHEN OTHERS THEN
    pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, psqcode => SQLCODE, psqerrm => SQLERRM);
    RETURN NULL;
  END f_get_detrecibos_det_fcambio;
--IGIL_FI-CONF_603
-- INI SGM 13. IAXIS-4134 Reporte de acuerdo de pago
FUNCTION f_get_recibos_saldos(
          pnpoliza IN NUMBER,
          cur OUT sys_refcursor,
          mensajes IN OUT t_iax_mensajes)
     RETURN NUMBER
IS
     vsquery VARCHAR2(4000);
     vnumerr NUMBER:=0;
     vparam  VARCHAR2 (500) := 'parámetros - pnpoliza: ' || pnpoliza;
     vobject  VARCHAR2(500) := 'PAC_MD_GESTION_REC.f_get_recibos_saldos';
     vpasexec NUMBER := 10;
BEGIN
     vpasexec:=20;
     vnumerr := pac_adm.f_get_recibos_saldos(pnpoliza,vsquery);
     IF vnumerr <> 0 THEN
          pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
          RAISE e_object_error;
     END IF;
     vpasexec := 30;
     cur := pac_iax_listvalores.f_opencursor(vsquery, mensajes);
     vpasexec := 40;
     RETURN vnumerr;
EXCEPTION
WHEN e_param_error THEN
     pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
     IF cur%ISOPEN THEN
          CLOSE cur;
     END IF;
     RETURN 1;
WHEN e_object_error THEN
     pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, vnumerr, vpasexec, vparam);
     IF cur%ISOPEN THEN
          CLOSE cur;
     END IF;
     RETURN 1;
WHEN OTHERS THEN
     pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, psqcode =>
     SQLCODE, psqerrm => SQLERRM);
     IF cur%ISOPEN THEN
          CLOSE cur;
     END IF;
     RETURN 1;
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
    --vsquery        VARCHAR2(5000);
    vobjectname    VARCHAR2(500) := 'pac_md_recibos.f_calcula_comisiones';
    vparam         VARCHAR2(1000) := 'parmetros - pnrecibo: ' || pnrecibo;
    vpasexec       NUMBER(5) := 1;
    vnumerr        NUMBER(8) := 0;
 BEGIN

    vnumerr := pac_adm.f_calcula_comisiones(pnrecibo);

    IF vnumerr <> 0 THEN
       pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
       RAISE e_object_error;
    END IF;

    RETURN 0;
 EXCEPTION
    WHEN e_param_error THEN
       pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
       RETURN 1;
    WHEN e_object_error THEN
       pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
       RETURN 1;
    WHEN OTHERS THEN
       pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                        NULL, SQLCODE, SQLERRM);
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
    vobjectname VARCHAR2(500) := 'PAC_MD_ADM.f_get_info_pagos_out';
    vparam      VARCHAR2(500) := 'parámetros - nnumide: ' || pnnumide;
    vpasexec    NUMBER(5) := 1;
    vcursor     SYS_REFCURSOR;
    vsquery     VARCHAR2(2000);
BEGIN

  vpasexec := 1;
  vsquery  := pac_adm.f_get_info_pagos_out(pnnumide, pnnumord);
  vcursor := pac_iax_listvalores.f_opencursor(vsquery, mensajes);

  IF pac_md_log.f_log_consultas(vsquery,
                                  'PAC_MD_ADM.f_get_info_pagos_out',
                                  1, 4, mensajes) <> 0
    THEN
      IF vcursor%ISOPEN
        THEN
          CLOSE vcursor;
      END IF;
  END IF;
  
  RETURN vcursor;
EXCEPTION
  WHEN OTHERS THEN
    IF vcursor%ISOPEN
      THEN
        CLOSE vcursor;
    END IF;
    pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001,
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
--
FUNCTION f_set_info_pago_out(pnnumord    IN NUMBER, 
                             pcesterp    IN NUMBER, 
                             pnprcerp    IN NUMBER, 
                             pffecpagerp IN DATE, 
                             pivalpagerp IN NUMBER, 
                             mensajes OUT t_iax_mensajes)
    RETURN NUMBER IS
    vobjectname VARCHAR2(500) := 'PAC_MD_ADM.f_set_info_pago_out';
    vparam      VARCHAR2(500) := 'parámetros - pnnumord: ' || pnnumord || ' - pcesterp '||pcesterp
                            || ' - pnprcerp '||pnprcerp|| ' - pffecpagerp '||pffecpagerp|| ' - pivalpagerp '||pivalpagerp ;
    vpasexec    NUMBER(5) := 1;
    vnumerr     NUMBER := 0;
BEGIN

  vpasexec := 1;
 
  vnumerr := pac_adm.f_set_info_pago_out(pnnumord, pcesterp, pnprcerp, pffecpagerp, pivalpagerp );

  IF vnumerr <> 0 THEN
    RAISE e_object_error;
  END IF;

  RETURN 0;
EXCEPTION
  WHEN e_param_error THEN
       pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
       RETURN 1;
    WHEN e_object_error THEN
       pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
       RETURN 1;
    WHEN OTHERS THEN
       pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                        NULL, SQLCODE, SQLERRM);
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
    vobjectname VARCHAR2(500) := 'PAC_MD_ADM.f_get_info_coa';
    vparam      VARCHAR2(500) := 'parámetros - pnrecibo: ' || pnrecibo;
    vpasexec    NUMBER(5) := 1;
    vcursor     SYS_REFCURSOR;
    vsquery     VARCHAR2(2000);
BEGIN

  vpasexec := 1;
  vsquery  := pac_adm.f_get_info_coa(pnrecibo);
  vcursor := pac_iax_listvalores.f_opencursor(vsquery, mensajes);

  IF pac_md_log.f_log_consultas(vsquery,
                                  'PAC_MD_ADM.f_get_info_coa',
                                  1, 4, mensajes) <> 0
    THEN
      IF vcursor%ISOPEN
        THEN
          CLOSE vcursor;
      END IF;
  END IF;

  RETURN vcursor;
EXCEPTION
  WHEN OTHERS THEN
    IF vcursor%ISOPEN
      THEN
        CLOSE vcursor;
    END IF;
    pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001,
                                         vpasexec, vparam, NULL, SQLCODE,
                                         SQLERRM);
    RETURN vcursor;
END f_get_info_coa;
--
-- Fin IAXIS-3591 17/07/2019
--
END pac_md_adm;

/