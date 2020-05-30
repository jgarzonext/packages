--------------------------------------------------------
--  DDL for Package Body PAC_MD_COA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MD_COA" IS
/******************************************************************************
   NAME:       pac_md_coa
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        29/05/2012                    1. Created this package body.
   2.0        29/05/2012    AVT             2. 0022076: LCOL_A004-Mantenimientos de cuenta tecnica del reaseguro y del coaseguro
   3.0        08/11/2012    AVT             3. 0023830: LCOL_A004 Ajustar el Manteniment dels Comptes de Reasseguranca (Nota: 22076/0123753)
   4.0        20/02/2013    FAL             4. 0025357: LCOL_T020-LCOL-COA Nuevos conceptos Cuenta Coaseguro
   5.0        05/07/2013    AVT             5. 0027260: LCOL_A004-Qtracker: 0008015: INCONSISTENCIAS RECAUDO PRIMAS
   6.0        16/12/2013    RCL             6. 0029347: LCOL_A004-Qtracker: 0010478: ERROR AJUSTES OPCION CUENTA TECNICA CEDIDO
   7.0        17/01/2014    JAM             7. 0027545: LCOL_A004-Qtracker: 0006911: El campo Fecha de Cierre no permite ser modificado (axiscoa003)
   8.0        11/06/2015    KBR             8. 0036409: Pendientes Modulo Coaseguro
******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

---------------------------------------------------------------------------------------------------------------------------------
   PROCEDURE p_agrega_where(p_where IN OUT VARCHAR2, p_add IN VARCHAR2) IS
   BEGIN
      IF p_where IS NOT NULL THEN
         p_where := p_where || ' and ';
      END IF;

      p_where := p_where || p_add;
   END p_agrega_where;

   /*************************************************************************
   Función que actualiza el estado de movimiento concreto de una cuenta de coaseguro
   *************************************************************************/
   -- Bug 32034 - SHA - 18/08/2014 - se crea la funcion
   FUNCTION f_set_estado_ctacoa(
      pccompani IN NUMBER,
      pcompapr IN NUMBER,
      pctipcoa IN NUMBER,
      pcempres IN NUMBER,
      psproces IN NUMBER,
      pcmovimi IN NUMBER,
      pfcierre IN DATE DEFAULT NULL,
      pestadonew IN NUMBER,
      pestadoold IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      v_object       VARCHAR2(500) := 'PAC_COA.f_set_estado_ctacoa';
      v_param        VARCHAR2(500)
         := 'params : pccompani : ' || pccompani || ', pcompapr : ' || pcompapr
            || ', pctipcoa : ' || pctipcoa || ' , pcempres : ' || pcempres || ', psproces : '
            || psproces || ', pfcierre : ' || pfcierre || ', pestadonew : ' || pestadonew
            || ', pestadoold : ' || pestadoold;
      vnumerr        NUMBER := 0;
      v_ttexto       VARCHAR2(1000);
      v_llinia       NUMBER := 0;
      vidioma        NUMBER;
   BEGIN
      vidioma := pac_md_common.f_get_cxtidioma;
      vnumerr := pac_coa.f_set_estado_ctacoa(pccompani, pcompapr, pctipcoa, pcempres,
                                             psproces, pcmovimi, pfcierre, pestadonew,
                                             pestadoold);

      IF vnumerr <> 0 THEN   -- hay errores
         v_ttexto := f_axis_literales(vnumerr, vidioma);
         ROLLBACK;
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005, vpasexec, v_param);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000006, vpasexec, v_param);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, vpasexec, v_param,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_set_estado_ctacoa;

   /***************************************************************************************************
   Función que setea a Pendiente el estado de aquellos movimientos de cuenta de coaseguro con estado 4
   ****************************************************************************************************/
   -- Bug 32034 - SHA - 18/08/2014 - se crea la funcion
   FUNCTION f_reset_estado(pcempres IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_object       VARCHAR2(500) := 'PAC_COA.f_reset_estado';
      v_param        VARCHAR2(500) := 'params : pcempres : ' || pcempres;
      v_pasexec      NUMBER(5) := 0;
      vnumerr        NUMBER := 0;
      v_ttexto       VARCHAR2(1000);
      vidioma        NUMBER;
   BEGIN
      vidioma := pac_md_common.f_get_cxtidioma;
      vnumerr := pac_coa.f_reset_estado(pcempres);

      IF vnumerr <> 0 THEN   -- hay errores
         v_ttexto := f_axis_literales(vnumerr, vidioma);
         ROLLBACK;
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005, v_pasexec, v_param);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000006, v_pasexec, v_param);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_reset_estado;

---------------------------------------------------------------------------------------------------------------------------------

   /*************************************************************************
   Función que devuelve el detalle por poliza de las cuentas técnicas de coaseguro
   *************************************************************************/
   -- Bug 24462 - SHA - 14/01/2014 - se crea la funcion
   FUNCTION f_get_ctacoaseguro_det(
      pccompani IN NUMBER,
      pfcierre IN DATE,
      pciaprop IN NUMBER,
      ptipocoaseguro IN NUMBER,
      pcempres IN NUMBER,
      pcramo IN NUMBER,
      psproduc IN NUMBER,
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      pcestado IN NUMBER,
      psseguro IN NUMBER,
      pcinverfas IN NUMBER,   -- Bug 32034 - SHA - 11/08/2014
      psproces IN NUMBER,   -- Bug 32034 - SHA - 11/08/2014
      pliquidable IN NUMBER,   -- Bug 32034 - SHA - 11/08/2014
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'parámetros - pccompani:' || pccompani || ' - pfcierre:' || pfcierre
            || ' - pciaprop:' || pciaprop || ' - ptipocoaseguro:' || ptipocoaseguro;
      vobject        VARCHAR2(50) := 'pac_md_coa.f_get_ctacoaseguro_det';
      vcursor        sys_refcursor;
      vsquery        VARCHAR2(9000);
      vsquery2       VARCHAR2(9000);
      vidioma        NUMBER := pac_md_common.f_get_cxtidioma();
      v_max_reg      NUMBER := f_parinstalacion_n('N_MAX_REG');
      -- número màxim de registres mostrats
      v_where        VARCHAR2(4000);
      v_fcierre_ini  DATE;
      v_fcierre_fin  DATE;
   BEGIN
      vsquery :=
         'SELECT e.tempres, s.cempres, s.sseguro, c.ccompani, p.tcompani, c.ccompapr,'
         || '(select tcompani from companias where ccompani = c.ccompapr) tcompapr,'
         || 'c.ctipcoa, ff_desvalorfijo(800109, ' || vidioma || ', c.ctipcoa) ttipcoa,'
         || '(SELECT tramo FROM ramos WHERE cidioma = 2 AND cramo = s.cramo) tramo, '
         || 'f_desproducto_t(s.cramo, s.cmodali, s.ctipseg, s.ccolect, 1, ' || vidioma
         || ') tproduc, case when c.ctipcoa = 1 then LAST_DAY(TRUNC(c.fcierre))'
         || ' else LAST_DAY(TRUNC(c.fmovimi)) end fcierre, s.npoliza || ''-'' || s.ncertif poliza,'
         || 'NVL(c.cmoneda, s.cmoneda) cmoneda, m.cmonint tmoneda, SUM(TRUNC(DECODE(c.cestado, 4, 0, DECODE(cdebhab, 1, imovimi, -imovimi)))) isaldo, '
         || NVL(pliquidable, '0') || ' es_liquidable '
         || 'FROM ctacoaseguro c, companias p, empresas e, seguros s, monedas m, productos pd '
         || 'WHERE c.ccompani = p.ccompani'   --|| ' AND NVL(c.cmoneda, s.cmoneda) = m.cmoneda'
--         || ' AND m.cmoneda = s.cmoneda AND NVL(c.cmoneda, s.cmoneda) = s.cmoneda'
         || ' AND s.cramo = pd.cramo AND s.cmodali = pd.cmodali '
         || ' AND s.ctipseg = pd.ctipseg AND s.ccolect = pd.ccolect '
         || ' AND m.cmoneda = pd.cdivisa AND NVL(c.cmoneda, pd.cdivisa) = pd.cdivisa '
         || ' AND m.cidioma = ' || vidioma
         || ' AND c.imovimi <> 0'   --|| ' AND c.cmovimi <> 99' -- Bug 32034 - SHA - 11/08/2014
         || ' AND e.cempres(+) = c.cempres' || ' AND c.ctipcoa = s.ctipcoa'
         || ' AND s.ctipcoa > 0' || ' AND c.sseguro = s.sseguro';
      vpasexec := 2;

      IF pccompani IS NOT NULL THEN
         vsquery := vsquery || ' AND c.ccompani  = ' || pccompani;
      ELSE
         vsquery := vsquery || ' AND c.ccompani IS NULL';
      END IF;

      IF pciaprop IS NOT NULL THEN
         vsquery := vsquery || '  AND c.ccompapr   = ' || pciaprop;
      ELSE
         vsquery := vsquery || '  AND c.ccompapr IS NULL';
      END IF;

      IF ptipocoaseguro IS NOT NULL THEN
         vsquery := vsquery || '  AND c.ctipcoa   = ' || ptipocoaseguro;
      END IF;

      --Esto lo haremos en funcion del ctipcoa
      IF pfcierre IS NOT NULL THEN
         v_fcierre_ini := TO_DATE('01' || TO_CHAR(pfcierre, 'mmyyyy'), 'ddmmyyyy');
         v_fcierre_fin := LAST_DAY(pfcierre);

         IF ptipocoaseguro = 1 THEN
            --fcierre
            vsquery := vsquery || ' AND c.fcierre >= to_date('''
                       || TO_CHAR(v_fcierre_ini, 'dd/mm/yyyy') || ''',''dd/mm/yyyy'')'
                       || ' AND c.fcierre <= ' || 'to_date('''
                       || TO_CHAR(v_fcierre_fin, 'dd/mm/yyyy') || ''',''dd/mm/yyyy'')';
         ELSE
            --fmovimi
            vsquery := vsquery || ' AND c.fmovimi >= to_date('''
                       || TO_CHAR(v_fcierre_ini, 'dd/mm/yyyy') || ''',''dd/mm/yyyy'')'
                       || ' AND c.fmovimi <= ' || 'to_date('''
                       || TO_CHAR(v_fcierre_fin, 'dd/mm/yyyy') || ''',''dd/mm/yyyy'')';
         END IF;
      ELSE
         --La fecha es null
         IF ptipocoaseguro = 1 THEN
            --fcierre
            vsquery := vsquery || ' AND c.fcierre IS NULL ';
         ELSE
            --fmovimi
            vsquery := vsquery || ' AND c.fmovimi IS NULL ';
         END IF;
      END IF;

      IF pcempres IS NOT NULL THEN
         vsquery := vsquery || '  AND c.cempres   = ' || pcempres;
      END IF;

      IF pcramo IS NOT NULL THEN
         vsquery := vsquery || ' AND s.cramo  = ' || pcramo;
      END IF;

      IF psproduc IS NOT NULL THEN
         vsquery := vsquery || '  AND s.sproduc   = ' || psproduc;
      END IF;

      IF pcestado IS NOT NULL THEN
         vsquery := vsquery || '  AND c.cestado   = ' || pcestado;
      END IF;

      IF pncertif IS NULL
         AND pnpoliza IS NOT NULL THEN
         vsquery := vsquery || '  AND s.npoliza = ' || pnpoliza;
      ELSE
         IF psseguro IS NOT NULL THEN
            vsquery := vsquery || '  AND c.sseguro = ' || psseguro;
         END IF;
      END IF;

      IF pcinverfas IS NOT NULL THEN
         vsquery := vsquery || ' AND p.cinverfas  = ' || pcinverfas;
      END IF;

      IF psproces IS NOT NULL THEN
         vsquery :=
            vsquery
            || ' AND c.spagcoa in (SELECT DISTINCT SPAGCOA FROM PAGOS_CTATEC_COA WHERE SPROCES = '
            || psproces || ' ) ';
      END IF;

      -- Fi Bug 32034
      -- Bug 32034 - SHA - 11/08/2014
      IF pcestado IS NOT NULL
         AND pcestado = 0 THEN
         vsquery2 := vsquery || ' AND c.cmovimi = 99 ';
      ELSE
         IF psproces IS NOT NULL THEN
            vsquery2 := vsquery || ' AND c.cmovimi = 99 ';   --Liquidada
         ELSE
            IF pliquidable = 1 THEN
               vsquery2 := vsquery || ' AND c.cmovimi = 99 ';
            ELSE
               vsquery2 :=
                  vsquery || '  AND c.cmovimi <> 99 '
                  || ' and not exists (select 1
                                    from ctacoaseguro cc
                                    where cc.ccompani = c.ccompani
                                    and cc.ccompapr = c.ccompapr
                                    and cc.ctipcoa = c.ctipcoa
                                    and cc.fcierre = c.fcierre
                                    and cc.cmovimi = 99
                                    and cc.cempres = c.cempres
                                    and cc.sseguro = c.sseguro ';

               IF psproces IS NOT NULL THEN
                  vsquery2 := vsquery2 || ' and cc.cestado in (0,3))';
               ELSE
                  vsquery2 := vsquery2 || ' and cc.cestado = 1)';
               END IF;
            END IF;
         END IF;
      END IF;

      vsquery2 :=
         vsquery2
         || ' group by e.tempres, s.cempres, s.sseguro, c.ccompani, p.tcompani, c.ccompapr,'
         || 'c.ctipcoa, s.cramo, f_desproducto_t(s.cramo, s.cmodali, s.ctipseg, s.ccolect, 1, '
         || vidioma || '),'
         || '(case when c.ctipcoa = 1 then LAST_DAY(TRUNC(c.fcierre)) else LAST_DAY(TRUNC(c.fmovimi)) end),'
         || 's.npoliza, s.ncertif, NVL(c.cmoneda, s.cmoneda),m.cmonint';
      vpasexec := 3;
      vcursor := pac_iax_listvalores.f_opencursor(vsquery2, mensajes);
      vpasexec := 4;

      -- Fi Bug 32034
      IF pac_md_log.f_log_consultas(vsquery2, vobject, 1, 4, mensajes) <> 0 THEN
         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;
      END IF;

      vpasexec := 5;
      RETURN vcursor;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
   END f_get_ctacoaseguro_det;

   /*************************************************************************
   Función que devuelve las cuentas técnicas de coaseguro
   *************************************************************************/
   -- Bug 22076 - AVT - 29/05/2012 - se crea la funcion
   FUNCTION f_get_ctacoaseguro(
      pcempres IN empresas.cempres%TYPE DEFAULT pac_md_common.f_get_cxtempresa,
      pccompani IN NUMBER,
      pcramo IN NUMBER,
      psproduc IN NUMBER,
      pfcierre IN DATE,
      psseguro IN NUMBER,
      pcestado IN NUMBER,
      pciaprop IN NUMBER,
      ptipocoaseguro IN NUMBER,
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      pcinverfas IN NUMBER,   -- Bug 32034 - SHA - 11/08/2014
      psproces IN NUMBER,   -- Bug 32034 - SHA - 11/08/2014
      pfcierredesde IN DATE,
      pfcierrehasta IN DATE,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(400)
         := 'parámetros - pcempres:' || pcempres || ' - pccompani:' || pccompani
            || ' - pcramo:' || pcramo || ' - psproduc:' || psproduc || ' - pfcierre:'
            || pfcierre || ' - psseguro:' || psseguro || ' - pcestado:' || pcestado
            || ' - pciaprop:' || pciaprop || ' - ptipocoaseguro:' || ptipocoaseguro
            || ' - pnpoliza:' || pnpoliza || ' - pncertif:' || pncertif || ' - pcinverfas:'
            || pcinverfas || ' - psproces:' || psproces || ' - pfcierredesde:' || pfcierredesde
            || ' - pfcierrehasta:' || pfcierrehasta;
      vobject        VARCHAR2(50) := 'pac_md_coa.f_get_ctacoaseguro';
      vcursor        sys_refcursor;
      vsquery        VARCHAR2(9000);
      vsquery2       VARCHAR2(9000);
      vsquery3       VARCHAR2(9000);
      vidioma        NUMBER := pac_md_common.f_get_cxtidioma();
      v_max_reg      NUMBER := f_parinstalacion_n('N_MAX_REG');
      -- número màxim de registres mostrats
      v_where        VARCHAR2(4000);
      v_fcierre_ini  DATE;
      v_fcierre_fin  DATE;
      v_fcierredesde_ini  DATE;
      v_fcierredesde_fin  DATE;
      v_fcierrehasta_ini  DATE;
      v_fcierrehasta_fin  DATE;
   BEGIN
      vsquery :=
         'SELECT DISTINCT c.sseguro,c.cestado,sproces,c.ccompapr,'   -- Bug 32034 - SHA - 11/08/2014
         || '(select tcompani from companias where ccompani = c.ccompapr) tcompapr,'
         || 'c.ccompani,p.tcompani,'
         || 'case when c.ctipcoa = 1 then LAST_DAY(TRUNC(c.fcierre))'
         || ' else LAST_DAY(TRUNC(c.fmovimi)) end fcierre,'
         || 'c.ctipcoa,ff_desvalorfijo(800109,' || vidioma
         || ', c.ctipcoa) ttipcoa,NVL(c.cmoneda, s.cmoneda) cmoneda,'
         || 'm.cmonint tmoneda,SUM(TRUNC(DECODE(c.cestado,4,0,DECODE(cdebhab,1,imovimi,-imovimi)))) isaldo, CASE WHEN c.cmovimi = 99 THEN 1 ELSE 0 END es_liquidable ';
--      IF pcestado IS NOT NULL AND pcestado = 1 THEN --Si el estado es pendiente añadiremos a la query la lógica para saber si un registro puede ser liquidable o no
--        vsquery := vsquery || ', CASE WHEN c.cmovimi = 99 THEN 1 ELSE 0 END es_liquidable ';
--      END IF;
      vsquery :=
         vsquery || 'FROM ctacoaseguro c,companias p,empresas e,seguros s,monedas m, productos pd '
         || 'WHERE c.ccompani = p.ccompani'   --|| ' AND NVL(c.cmoneda, s.cmoneda) = m.cmoneda'
         || ' AND m.cidioma = ' || vidioma || ' AND c.imovimi <> 0'   --|| ' AND c.cmovimi <> 99'
         || ' AND e.cempres(+) = c.cempres' || ' AND c.ctipcoa = s.ctipcoa'
         || ' AND s.ctipcoa > 0' || ' AND c.sseguro = s.sseguro'
         || ' AND s.cramo = pd.cramo AND s.cmodali = pd.cmodali '
         || ' AND s.ctipseg = pd.ctipseg AND s.ccolect = pd.ccolect '
         || ' AND m.cmoneda = pd.cdivisa AND NVL(c.cmoneda, pd.cdivisa) = pd.cdivisa ';
      vpasexec := 2;

      IF pcempres IS NOT NULL THEN
         vsquery := vsquery || ' AND c.cempres = ' || pcempres;
      END IF;

      -- 23830 AVT 13-11-2012
--      IF pciaprop IS NOT NULL THEN
--         vsquery := vsquery || '  AND s.ccompani   = ' || pciaprop;
--      END IF;
      IF pccompani IS NOT NULL THEN
         vsquery := vsquery || ' AND c.ccompani = ' || pccompani;
      END IF;

      IF pcramo IS NOT NULL THEN
         vsquery := vsquery || ' AND s.cramo = ' || pcramo;
      END IF;

      IF psproduc IS NOT NULL THEN
         vsquery := vsquery || ' AND s.sproduc = ' || psproduc;
      END IF;

      IF pcestado IS NOT NULL THEN
         vsquery := vsquery || ' AND (c.cestado = ' || pcestado || ' OR c.cestado = 4) ';
      END IF;

--      IF pciaprop IS NOT NULL THEN
--         vsquery := vsquery || ' AND c.ccompapr = ' || pciaprop;
--      END IF;

      IF ptipocoaseguro IS NOT NULL THEN
         vsquery := vsquery || ' AND c.ctipcoa = ' || ptipocoaseguro;
      END IF;

      -- Bug 32034 - SHA - 11/08/2014
      IF pcinverfas IS NOT NULL THEN
         vsquery := vsquery || ' AND p.cinverfas = ' || pcinverfas;
      END IF;

      IF psproces IS NOT NULL THEN
         vsquery :=
            vsquery
            || ' AND c.spagcoa in (SELECT DISTINCT SPAGCOA FROM PAGOS_CTATEC_COA WHERE SPROCES = '
            || psproces || ' ) ';
      END IF;

      -- Fi Bug 32034
      IF pfcierre IS NOT NULL THEN
         v_fcierre_ini := TO_DATE('01' || TO_CHAR(pfcierre, 'mmyyyy'), 'ddmmyyyy');
         v_fcierre_fin := LAST_DAY(pfcierre);
         vsquery := vsquery || ' AND ((c.ctipcoa=1 AND c.fcierre>=' || 'to_date('''
                    || TO_CHAR(v_fcierre_ini, 'dd/mm/yyyy') || ''',''dd/mm/yyyy'')'
                    || ' AND c.fcierre<=' || 'to_date('''
                    || TO_CHAR(v_fcierre_fin, 'dd/mm/yyyy') || ''',''dd/mm/yyyy''))'
                    || ' OR (c.ctipcoa<>1 AND c.fmovimi >= ' || 'to_date('''
                    || TO_CHAR(v_fcierre_ini, 'dd/mm/yyyy') || ''',''dd/mm/yyyy'')'
                    || ' AND c.fmovimi<=' || 'to_date('''
                    || TO_CHAR(v_fcierre_fin, 'dd/mm/yyyy') || ''',''dd/mm/yyyy'')))';
      END IF;

      --INI CONF428
      IF pfcierredesde IS NOT NULL THEN
        -- v_fcierredesde_ini := TO_DATE('01' || TO_CHAR(pfcierredesde, 'mmyyyy'), 'ddmmyyyy');
        -- v_fcierredesde_fin := LAST_DAY(pfcierredesde);
         vsquery := vsquery || ' AND ((c.ctipcoa=1 AND c.fcierre>=' || 'to_date('''
                    || TO_CHAR(pfcierredesde, 'dd/mm/yyyy') || ''',''dd/mm/yyyy''))'
                    || ' OR (c.ctipcoa<>1 AND c.fmovimi >=' || 'to_date('''
                    || TO_CHAR(pfcierredesde, 'dd/mm/yyyy') || ''',''dd/mm/yyyy'')))';
      END IF;

      IF pfcierrehasta IS NOT NULL THEN
        -- v_fcierrehasta_ini := TO_DATE('01' || TO_CHAR(pfcierrehasta, 'mmyyyy'), 'ddmmyyyy');
        -- v_fcierrehasta_fin := LAST_DAY(pfcierrehasta);
         vsquery := vsquery || ' AND ((c.ctipcoa=1 AND c.fcierre<=' || 'to_date('''
                    || TO_CHAR(pfcierrehasta, 'dd/mm/yyyy') || ''',''dd/mm/yyyy''))'
                    || ' OR (c.ctipcoa<>1 AND c.fmovimi <=' || 'to_date('''
                    || TO_CHAR(pfcierrehasta, 'dd/mm/yyyy') || ''',''dd/mm/yyyy'')))';
      END IF;
      --FIN CONF428

      IF pncertif IS NULL
         AND pnpoliza IS NOT NULL THEN
         vsquery := vsquery || ' AND s.npoliza = ' || pnpoliza;
      ELSE
         IF psseguro IS NOT NULL THEN
            vsquery := vsquery || ' AND c.sseguro = ' || psseguro;
         END IF;
      END IF;

      vpasexec := 3;
      -- Bug 32034 - SHA - 11/08/2014
      --
      vsquery2 :=
         vsquery || ' AND c.cmovimi = 99 '
         || 'group by c.sseguro,c.sseguro,c.cestado, sproces,c.ccompapr,p.tcompani, c.ccompani,p.tcompani,'
         || '(case when c.ctipcoa = 1 then LAST_DAY(TRUNC(c.fcierre)) else LAST_DAY(TRUNC(c.fmovimi)) end),'
         || 'c.ctipcoa,ff_desvalorfijo(800109, ' || vidioma
         || ', c.ctipcoa),NVL(c.cmoneda, s.cmoneda),m.cmonint,CASE WHEN c.cmovimi = 99 THEN 1 ELSE 0 END';

--         IF pcestado IS NOT NULL AND pcestado = 1 THEN --Si el estado es pendiente añadiremos a la query la lógica para saber si un registro puede ser liquidable o no
--            vsquery2 := vsquery2 || ', CASE WHEN c.cmovimi = 99 THEN 1 ELSE 0 END ';
--         END IF;
      IF pcestado IS NOT NULL
         AND pcestado = 1 THEN   --Si miramos las pendientes tendremos en cuenta algunos casos sin Saldo (cmovimi 99)
         vsquery2 :=
            vsquery2 || ' UNION ' || vsquery || ' AND c.cmovimi = 99 '
            || ' and not exists (select 1 from ctacoaseguro cc where cc.ccompani=c.ccompani and cc.ccompapr=c.ccompapr and cc.ctipcoa=c.ctipcoa '
            || ' and cc.fcierre=c.fcierre and cc.cmovimi=99 and cc.cempres=c.cempres and cc.sseguro=c.sseguro ';

         IF psproces IS NOT NULL THEN
            vsquery2 := vsquery2 || ' and cc.cestado in (0,3))';
         ELSE
            vsquery2 := vsquery2 || ' and cc.cestado = 1)';
         END IF;

         vsquery2 :=
            vsquery2
            || ' group by c.sseguro,c.sseguro,c.cestado,sproces,c.ccompapr,p.tcompani,c.ccompani,p.tcompani,'
            || '(case when c.ctipcoa = 1 then LAST_DAY(TRUNC(c.fcierre)) else LAST_DAY(TRUNC(c.fmovimi)) end),'
            || 'c.ctipcoa,ff_desvalorfijo(800109, ' || vidioma
            || ', c.ctipcoa),NVL(c.cmoneda, s.cmoneda),m.cmonint,CASE WHEN c.cmovimi = 99 THEN 1 ELSE 0 END';
      END IF;

--          IF pcestado IS NOT NULL AND pcestado = 1 THEN --Si el estado es pendiente añadiremos a la query la lógica para saber si un registro puede ser liquidable o no
--                vsquery2 := vsquery2 || ', CASE WHEN c.cmovimi = 99 THEN 1 ELSE 0 END ';
--          END IF;
      -- Fi Bug 32034
      IF pcestado IS NOT NULL
         AND pcestado = 1 THEN   --Si el estado es pendiente añadiremos a la query la lógica para saber si un registro puede ser liquidable o no
         vsquery2 :=
            ' SELECT DISTINCT CESTADO,SPROCES,CCOMPAPR,tcompapr,CCOMPANI,TCOMPANI,FCIERRE,CTIPCOA,TTIPCOA,TMONEDA,SUM(TRUNC(ISALDO)) ISALDO,ES_LIQUIDABLE from ( '
            || vsquery2
            || ' ) GROUP BY CESTADO,SPROCES,CCOMPAPR,TCOMPAPR,CCOMPANI,TCOMPANI,FCIERRE,CTIPCOA,TTIPCOA,TMONEDA,ES_LIQUIDABLE ORDER BY TCOMPANI,TCOMPAPR,FCIERRE,SPROCES ';
      ELSE
         vsquery2 :=
            ' SELECT DISTINCT CESTADO,SPROCES,CCOMPAPR,tcompapr,CCOMPANI,TCOMPANI,FCIERRE,CTIPCOA,TTIPCOA,TMONEDA,SUM(TRUNC(ISALDO)) ISALDO from ( '
            || vsquery2
            || ' ) GROUP BY CESTADO,SPROCES,CCOMPAPR,TCOMPAPR,CCOMPANI,TCOMPANI,FCIERRE,CTIPCOA,TTIPCOA,TMONEDA ORDER BY TCOMPANI,TCOMPAPR,FCIERRE,SPROCES ';
      END IF;

      --      vsquery := vsquery || v_where;
      vpasexec := 4;
      vcursor := pac_iax_listvalores.f_opencursor(vsquery2, mensajes);
      vpasexec := 5;

      IF pac_md_log.f_log_consultas(vsquery2, vobject, 1, 4, mensajes) <> 0 THEN
         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;
      END IF;

      vpasexec := 6;
      RETURN vcursor;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
   END f_get_ctacoaseguro;

   /*************************************************************************
   Función que devuelve la cabecera de la cuenta técnica de coaseguro consultada
   *************************************************************************/
   -- Bug 22076 - AVT - 29/05/2012 - se crea la funcion
   FUNCTION f_get_cab_ctacoa(
      pcempres IN empresas.cempres%TYPE DEFAULT pac_md_common.f_get_cxtempresa,
      pccompapr IN NUMBER,
      pccompani IN NUMBER,
      psseguro IN NUMBER,
      pfcierre IN DATE,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'parámetros - pcempres:' || pcempres || ' - pccompani:' || pccompani
            || ' - psseguro:' || psseguro || ' - pfcierre:' || pfcierre;
      vobject        VARCHAR2(50) := 'pac_md_coa.f_get_cab_ctacoa';
      vcursor        sys_refcursor;
      vsquery        VARCHAR2(9000);
      vidioma        NUMBER := pac_md_common.f_get_cxtidioma();
      v_max_reg      NUMBER := f_parinstalacion_n('N_MAX_REG');
      -- número màxim de registres mostrats
      v_where        VARCHAR2(4000);
      v_aux          VARCHAR2(2000);
      v_fcierre_ini  DATE;
      v_fcierre_fin  DATE;
   BEGIN
      IF pfcierre IS NOT NULL THEN
         v_fcierre_ini := TO_DATE('01' || TO_CHAR(pfcierre, 'mmyyyy'), 'ddmmyyyy');
         v_fcierre_fin := LAST_DAY(pfcierre);
      END IF;

      vsquery :=
         'SELECT   c.cempres, e.tempres, c.ccompani, (SELECT tcompani '
         || ' FROM companias cc  WHERE cc.ccompani = c.ccompani) tcompani,'
--         || ' TRUNC(nvl(c.fcierre,c.fmovimi)) fcierre, c.ctipcoa, '   -- BUG 0025357/0138513 - FAL - 19/02/2013
         --|| ' nvl(c.fcontab,c.fmovimi) fcierre, c.ctipcoa, '
         || ' c.ctipcoa, ' || ' ff_desvalorfijo(800109, ' || vidioma || ', c.ctipcoa) ttipcoa,'
         || '(SELECT tramo FROM ramos WHERE cidioma = ' || vidioma
         || '  AND cramo = s.cramo) tramo,'
         || 'f_desproducto_t(s.cramo, s.cmodali, s.ctipseg, s.ccolect, 1, ' || vidioma
         || ' ) tproduc, c.sseguro, '
         || 's.npoliza, s.ncertif, c.sproduc, '   -- 27260 AVT 05/07/2013 SE QUITA -- c.sidepag,
         || ' SUM(TRUNC(DECODE(c.cmovimi,99, DECODE(c.cestado, 4, 0, DECODE(cdebhab, 1, imovimi, -imovimi)), null))) isaldo, '
         || ' SUM(TRUNC(DECODE(c.cmovimi,99, DECODE(c.cestado, 4, 0, DECODE(cdebhab, 1, imovimi_moncon, -imovimi_moncon)), null))) isaldo_moncon'
         || ' FROM ctacoaseguro c, seguros s, empresas e ';
      vpasexec := 2;
      v_aux := 'WHERE c.sseguro = s.sseguro AND c.ctipcoa = s.ctipcoa AND c.imovimi <> 0 '
               --|| ' AND c.cmovimi <> 99 '   --  27260 AVT 05/07/2013 SE EXCLUYE EL SALDO
               || ' AND c.cempres(+) = ' || pcempres || ' AND c.ccompani = ' || pccompani
               || ' AND c.sseguro = ' || psseguro || ' AND e.cempres(+) = c.cempres ';

      IF pfcierre IS NOT NULL THEN
         v_aux := v_aux || ' AND c.fmovimi >= ' || 'to_date('''
                  || TO_CHAR(v_fcierre_ini, 'dd/mm/yyyy')
                  || ''',''dd/mm/yyyy'') AND c.fmovimi <= ' || 'to_date('''
                  || TO_CHAR(v_fcierre_fin, 'dd/mm/yyyy') || ''',''dd/mm/yyyy'')';
      END IF;

      p_agrega_where(v_where, v_aux);
      vpasexec := 3;

      IF pccompapr IS NOT NULL THEN
         p_agrega_where(v_where, '  c.ccompapr   = ' || pccompapr);
      ELSE
         p_agrega_where(v_where, '  c.ccompapr IS NULL');
      END IF;

            /*IF v_max_reg IS NOT NULL THEN
               IF INSTR(vsquery, ' order by', -1, 1) > 0 THEN
                  -- se hace de esta manera para mantener el orden de los registros
                  vsquery := ' select * from (' || vsquery || ') where rownum <= ' || v_max_reg;
               ELSE
                  p_agrega_where(v_where, ' rownum <= ' || v_max_reg);
               END IF;
            END IF;
      */
      vsquery :=
         'select distinct cempres,tempres,ccompani,tcompani,ctipcoa,ttipcoa,tramo,tproduc,sseguro,npoliza,ncertif,sproduc,sum(TRUNC(isaldo)) isaldo,sum(TRUNC(isaldo_moncon)) isaldo_moncon from ( '
         || vsquery || v_where
         || ' GROUP BY c.cempres, e.tempres, c.ccompani, c.ctipcoa, s.cramo, s.cmodali, '   -- BUG 0025357/0138513 - FAL - 19/02/2013
         || '  s.ctipseg, s.ccolect, c.sseguro,  s.npoliza, s.ncertif, c.sproduc'   -- 27260 AVT 05/07/2013 SE QUITA -- c.sidepag,
         || ') group by cempres,tempres,ccompani,tcompani,ctipcoa,ttipcoa,tramo,tproduc,sseguro,npoliza,ncertif,sproduc';
      vpasexec := 4;
      vcursor := pac_iax_listvalores.f_opencursor(vsquery, mensajes);
      vpasexec := 5;

      IF pac_md_log.f_log_consultas(vsquery, vobject, 1, 4, mensajes) <> 0 THEN
         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;
      END IF;

      vpasexec := 6;
      RETURN vcursor;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
   END f_get_cab_ctacoa;

   /*************************************************************************
   Función que devuelve las cuentas técnicas de la coaseguradora consultada
   *************************************************************************/
   -- Bug 22076 - AVT - 29/05/2012 - se crea la funcion
   FUNCTION f_get_mov_ctacoa(
      pcempres IN empresas.cempres%TYPE DEFAULT pac_md_common.f_get_cxtempresa,
      pccompapr IN NUMBER,
      pccompani IN NUMBER,
      psseguro IN NUMBER,
      pfcierre IN DATE,
      pcestado IN NUMBER,   -- Bug 32034 - SHA - 11/08/2014
      psproces IN NUMBER,   -- Bug 32034 - SHA - 11/08/2014
      pliquidable IN NUMBER,   -- Bug 32034 - SHA - 11/08/2014
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'parámetros - pcempres:' || pcempres || ' - pccompani:' || pccompani
            || ' - psseguro:' || psseguro || ' - pfcierre:' || pfcierre || ' - pliquidable:'
            || pliquidable;
      vobject        VARCHAR2(50) := 'pac_md_coa.f_get_mov_ctacoa';
      vcursor        sys_refcursor;
      vsquery        VARCHAR2(9000);
      vidioma        NUMBER := pac_md_common.f_get_cxtidioma();
      v_max_reg      NUMBER := f_parinstalacion_n('N_MAX_REG');
      -- número màxim de registres mostrats
      v_where        VARCHAR2(4000);
      v_aux          VARCHAR2(2000);
      v_fcierre_ini  DATE;
      v_fcierre_fin  DATE;
   BEGIN
      IF pfcierre IS NOT NULL THEN
         v_fcierre_ini := TO_DATE('01' || TO_CHAR(pfcierre, 'mmyyyy'), 'ddmmyyyy');
         v_fcierre_fin := LAST_DAY(pfcierre);
      END IF;

      vsquery :=
         'SELECT c.nrecibo, c.sidepag, c.cimport, ' || ' ff_desvalorfijo(150, ' || vidioma
         || ' , c.cimport) tipoimp,' || ' c.smovcoa nnumlin, NVL(c.ctipmov, 0) ctipmov, '
         || ' ff_desvalorfijo(63, ' || vidioma || ' , NVL(c.ctipmov, 0)) ttipmov, '
         || ' c.fmovimi, NVL(c.cestado,1) cestado, ' || ' ff_desvalorfijo(800106, ' || vidioma
         || ' , NVL(c.cestado,1)) testado, ' || ' c.cmovimi, ff_desvalorfijo(152, ' || vidioma
         || ', c.cmovimi) tconcep,'
         || ' TRUNC(DECODE(c.cdebhab, 1, c.imovimi_moncon, 0)) idebe, TRUNC(DECODE(c.cdebhab, 2, c.imovimi_moncon, 0)) ihaber, '
         || ' NVL(c.cmoneda, s.cmoneda) cmoneda, c.ccompani, c.ctipcoa, c.cdebhab, '
         || ' c.imovimi iimport, s.npoliza, s.ncertif, m.tdescri tmoneda, c.tdescri, c.tdocume, c.fcontab '   --BUG 29347/161211 - 16/12/2013 - RCL - Afegim camp fcontab
         || ' FROM ctacoaseguro c , seguros s , monedas m, productos p ';
      vpasexec := 2;
      v_aux :=
         ' WHERE c.sseguro = s.sseguro AND c.imovimi <> 0 AND c.cempres = ' || pcempres
         || ' AND c.ccompani = ' || pccompani
         || ' AND c.sseguro = ' || psseguro
         || ' AND m.cidioma = ' || vidioma
         || ' AND c.imovimi <> 0
               AND c.cestado != 4
               AND NVL(c.cmoneda,s.cmoneda)=s.cmoneda
               AND s.cramo = p.cramo
               AND s.cmodali = p.cmodali
               AND s.ctipseg = p.ctipseg
               AND s.ccolect = p.ccolect
               AND m.cmoneda = p.cdivisa
               ';



      IF pfcierre IS NOT NULL THEN
         v_aux := v_aux || ' AND case when c.ctipcoa = 1 then c.fcierre else c.fmovimi end >= ' || 'to_date('''
                  || TO_CHAR(v_fcierre_ini, 'dd/mm/yyyy')
                  || ''',''dd/mm/yyyy'') AND case when c.ctipcoa = 1 then c.fcierre else c.fmovimi end <= ' || 'to_date('''
                  || TO_CHAR(v_fcierre_fin, 'dd/mm/yyyy') || ''',''dd/mm/yyyy'')';
      END IF;

      p_agrega_where(v_where, v_aux);
      vpasexec := 3;

      IF pccompapr IS NOT NULL THEN
         p_agrega_where(v_where, '  c.ccompapr   = ' || pccompapr);
      ELSE
         p_agrega_where(v_where, '  c.ccompapr IS NULL');
      END IF;

      -- Si filtramos por estado Pendiente o Liquidada, solo mostraremos los conceptos con el SPROCES igual al del Saldo (liquidado o pendiente)
      IF pcestado IS NOT NULL
         AND psproces IS NULL
         AND pliquidable = 1   --Cuando pliquidable es 1, el pcestado es 1
                            THEN
         p_agrega_where
            (v_where,
             ' c.sproces in (SELECT DISTINCT sproces
                               FROM ctacoaseguro cc, seguros ss
                              WHERE cc.sseguro = ss.sseguro
                                AND cc.fcierre >= TO_DATE('''
             || TO_CHAR(v_fcierre_ini, 'dd/mm/yyyy')
             || ''',''dd/mm/yyyy'')
                                AND cc.fcierre <= TO_DATE('''
             || TO_CHAR(v_fcierre_fin, 'dd/mm/yyyy')
             || ''',''dd/mm/yyyy'')
                                AND cc.ccompani = c.ccompani
                                AND cc.cempres = c.cempres
                                AND cc.imovimi <> 0
                                AND cc.cestado = '
             || pcestado || '               AND cc.sseguro = ' || psseguro
             || '
                                AND cmovimi = 99)');
         p_agrega_where
            (v_where,
             ' ( ( c.cestado = 0 AND c.cmovimi !=99 ) OR ( c.cestado = 1 AND c.cmovimi =99 ) )');
      ELSIF pcestado IS NOT NULL
            AND psproces IS NULL
            AND(pliquidable IS NULL
                OR pliquidable = 0) THEN
         --Si no es liquidable mostraremos en funcion del filtro de cestado
         p_agrega_where(v_where, ' c.cestado = ' || pcestado);
      ELSE
         --Otros casos
         -- Bug 32034 - SHA - 11/08/2014

         --Le enviamos un estado (deberia ser 0 - liquidado) y un numero de liquidacion
         --Enlazamos con el sproces del movimiento 99 (saldo liquidado)
         IF pcestado IS NOT NULL
            AND psproces IS NOT NULL THEN
            p_agrega_where(v_where, ' c.cestado = 0 ');
            p_agrega_where
               (v_where,
                ' c.sproces in (SELECT DISTINCT sproces
                               FROM ctacoaseguro cc, seguros ss
                              WHERE cc.sseguro = ss.sseguro
                                AND cc.fcierre >= TO_DATE('''
                || TO_CHAR(v_fcierre_ini, 'dd/mm/yyyy')
                || ''',''dd/mm/yyyy'')
                                AND cc.fcierre <= TO_DATE('''
                || TO_CHAR(v_fcierre_fin, 'dd/mm/yyyy')
                || ''',''dd/mm/yyyy'')
                                AND cc.ccompani = c.ccompani
                                AND cc.cempres = c.cempres
                                AND cc.imovimi <> 0
                                AND cc.cestado = c.cestado
                                AND cc.sseguro = '
                || psseguro || '
                                AND cmovimi = 99)');
         END IF;

         --Si le enviamos estado = NULL, no filtraremos por nada en relacion al ESTADO (caso del check ver todos) a menos que tambien tengamos un numero de liquidacion
         --En ese caso, enlazamos con el sproces del movimiento 99 (saldo liquidado)
         IF pcestado IS NULL
            AND psproces IS NOT NULL THEN
            p_agrega_where
               (v_where,
                ' c.sproces in (SELECT DISTINCT sproces
                               FROM ctacoaseguro cc, seguros ss
                              WHERE cc.sseguro = ss.sseguro
                                AND cc.fcierre >= TO_DATE('''
                || TO_CHAR(v_fcierre_ini, 'dd/mm/yyyy')
                || ''',''dd/mm/yyyy'')
                                AND cc.fcierre <= TO_DATE('''
                || TO_CHAR(v_fcierre_fin, 'dd/mm/yyyy')
                || ''',''dd/mm/yyyy'')
                                AND cc.ccompani = c.ccompani
                                AND cc.cempres = c.cempres
                                AND cc.imovimi <> 0
                                AND cc.cestado = c.cestado
                                AND cc.sseguro = '
                || psseguro || '
                                AND cmovimi = 99)');
         END IF;
      END IF;

      vsquery := vsquery || v_where || ' order by nnumlin,fmovimi,tconcep,cestado ';
      vpasexec := 4;
      vcursor := pac_iax_listvalores.f_opencursor(vsquery, mensajes);
      vpasexec := 5;

      IF pac_md_log.f_log_consultas(vsquery, vobject, 1, 4, mensajes) <> 0 THEN
         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;
      END IF;

      vpasexec := 6;
      RETURN vcursor;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
   END f_get_mov_ctacoa;

   /*************************************************************************
   Función que elimina un movimiento manual de la cuenta técnica del coaseguro
   *************************************************************************/
   -- Bug 22076 - AVT - 29/05/2012 - se crea la funcion
   FUNCTION f_del_mov_ctacoa(
      pcempres IN empresas.cempres%TYPE DEFAULT pac_md_common.f_get_cxtempresa,
      pccompani IN NUMBER,
      psseguro IN NUMBER,
      pfcierre IN DATE,
      pnnumlin IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(800)
         := ' pcempres:' || pcempres || ' - pccompani:' || pccompani || ' - psseguro:'
            || psseguro || ' - pfcierre:' || pfcierre || ' - pnnumlin:' || pnnumlin;
      vobject        VARCHAR2(50) := 'pac_coa_coa.f_del_mov_ctacoa';
      vnumerr        NUMBER := 0;
   BEGIN
      vnumerr := pac_coa.f_del_mov_ctacoa(pcempres, pccompani, psseguro, pfcierre, pnnumlin);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_del_mov_ctacoa;

   /*************************************************************************
   Función que apunta en la tabla de liquidación los importes pendientes de la cuenta técnica del coaseguro.
   *************************************************************************/
   -- Bug 22076 - AVT - 24/05/2012 - se crea la funcion
   FUNCTION f_liquida_ctatec_coa(
      pcempres IN empresas.cempres%TYPE DEFAULT pac_md_common.f_get_cxtempresa,
      pccompani IN NUMBER,
      pccompapr IN NUMBER,
      pfcierre IN DATE,
      pfcierredesde IN DATE,
      pfcierrehasta IN DATE,
      pctipcoa IN NUMBER,
      psproces_ant IN NUMBER,
      psproces_nou IN NUMBER,
      indice OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(800)
         := ' pcempres:' || pcempres || ' - pccompani:' || pccompani || ' - pccompapr:'
            || pccompapr || ' - pfcierre:' || pfcierre || ' - pfcierredesde:' || pfcierredesde
            || ' - pfcierrehasta:' || pfcierrehasta || ' - pctipcoa:' || pctipcoa
            || ' - psproces_ant:' || psproces_ant || ' - psproces_nou:' || psproces_nou;
      vobject        VARCHAR2(50) := 'pac_md_coa.f_liquida_ctatec_coa';
      vnumerr        NUMBER := 0;
      v_ttexto       VARCHAR2(1000);
      v_ttexto1      VARCHAR2(1000);
      v_ttexto2      VARCHAR2(1000);
      v_titulo       VARCHAR2(1000);
      v_llinia       NUMBER := 0;
      vidioma        NUMBER;
      v_sproces      NUMBER;
      indice_error   NUMBER;
   BEGIN
      vidioma := pac_md_common.f_get_cxtidioma;
      vpasexec := 2;

      vnumerr := pac_coa.f_liquida_ctatec_coa(pcempres, pccompani, pccompapr, pfcierre, pfcierredesde,
                                              pfcierrehasta, pctipcoa, psproces_ant, psproces_nou, indice);
      v_llinia := NULL;

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);   -- error interno.
         v_ttexto := f_axis_literales(vnumerr, vidioma);
         vnumerr := f_proceslin(psproces_nou, v_ttexto, 0, v_llinia);
         vnumerr := f_procesfin(psproces_nou, vnumerr);
         RAISE e_object_error;
      END IF;

      vnumerr := f_procesfin(psproces_nou, vnumerr);
      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, NULL,
                                           f_axis_literales(9000493,
                                                            pac_md_common.f_get_cxtidioma)
                                           || ' : ' || psproces_nou);
      ---
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_liquida_ctatec_coa;

    /*************************************************************************
       Función que insertará o modificará un movimiento de cuenta técnica en función del pmodo
   *************************************************************************/
   -- Bug 22076 - AVT - 25/05/2012 - se crea la funcion
   FUNCTION f_set_mov_ctacoa(
      pcempres IN empresas.cempres%TYPE DEFAULT pac_md_common.f_get_cxtempresa,
      pccompani IN NUMBER,
      pnnumlin IN NUMBER,
      pctipcoa IN NUMBER,
      pcdebhab IN NUMBER,
      psseguro IN NUMBER,
      pnrecibo IN NUMBER,
      psidepag IN NUMBER,
      pfcierre IN DATE,
      pcmovimi IN NUMBER,
      pcimport IN NUMBER,
      pimovimi IN NUMBER,
      pfcambio IN DATE,
      pcestado IN NUMBER,
      ptdescri IN VARCHAR2,
      ptdocume IN VARCHAR2,
      pmodo IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(800)
         := 'params pcempres : ' || pcempres || 'pccompani : ' || pccompani || ', pnnumlin : '
            || pnnumlin || ', pctipcoa : ' || pctipcoa || ' , psseguro : ' || psseguro
            || ', pnrecibo : ' || pnrecibo || ', psidepag : ' || psidepag || ', pfcierre : '
            || pfcierre || ', pcmovimi : ' || pcmovimi || ' , pimovimi : ' || pimovimi
            || ' pmodo:' || pmodo;
      vobject        VARCHAR2(50) := 'pac_md_coa.f_set_mov_ctacoa';
      vnumerr        NUMBER := 0;
      v_ttexto       VARCHAR2(1000);
      v_llinia       NUMBER := 0;
      vidioma        NUMBER;
   BEGIN
      vidioma := pac_md_common.f_get_cxtidioma;
      vnumerr := pac_coa.f_set_mov_ctacoa(pcempres, pccompani, pnnumlin, pctipcoa, pcdebhab,
                                          psseguro, pnrecibo, psidepag, pfcierre, pcmovimi,
                                          pcimport, pimovimi, pfcambio, pcestado, ptdescri,
                                          ptdocume, pmodo);

      IF vnumerr <> 0 THEN   -- hay errores
         v_ttexto := f_axis_literales(vnumerr, vidioma);
         ROLLBACK;
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_set_mov_ctacoa;

      /*******************************************************************************
   FUNCION F_REGISTRA_PROCESO
   Esta función deberá realizar una llamada a la función de la capa de negocio pac_coa.f_inicializa_liquida_coa
    Parámetros
     Entrada :
       Pfperini NUMBER : Fecha inicio
       Pcempres NUMBER : Empresa

     Salida :
       Mensajes   T_IAX_MENSAJES

    Retorna : NUMBER con el número de proceso.
   ********************************************************************************/
   FUNCTION f_registra_proceso(
      pfperini IN DATE,
      pcempres IN NUMBER,
      pnproceso OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := ' pfperini=' || pfperini || 'pcempres=' || pcempres;
      vobject        VARCHAR2(200) := 'PAC_MD_COA.F_REGISTRA_PROCESO';
      vnumerr        NUMBER;
      vtexto         VARCHAR2(100);
   BEGIN
      -- Control parametros entrada
      IF pfperini IS NULL
         OR pcempres IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_coa.f_inicializa_liquida_coa(pfperini, pcempres, 'LIQUIDACION COA',
                                                  pac_md_common.f_get_cxtidioma, pnproceso);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);   -- error interno.
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      --Se debe realizar el control de errores mediante  el PAC_IOBJ_MENSAJES.P_TRATARMENSAJE.
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_registra_proceso;



/*******************************************************************************
FUNCION F_GET_REMESA_DET
Esta función nos devolverá la consulta de remesas

********************************************************************************/
   -- Bug 22076 - AVT - 04/10/2012 - se crea la funcion
function F_GET_REMESA_DET(    --ramiro
  PCCOMPANI  in number,
  PCSUCURSAL in number,
  PFCIERRE  in date,
  PCIAPROP in number,
  PCTIPCOA in number,
  PCEMPRES in number,
  PCRAMO in number,
  PSPRODUC in number,
  PNPOLCIA in number,
  PCESTADO in number,
  PSSEGURO in number,
  PSMOVCOA IN NUMBER,
  MENSAJES OUT T_IAX_MENSAJES)
  return sys_refcursor  is
  VPASEXEC       number(8) := 1;
  vparam         VARCHAR2(200) :=  PCCOMPANI||','||PCSUCURSAL||','||PFCIERRE||','||PCIAPROP||','||
  PCTIPCOA||','||PCEMPRES||','||PCRAMO||','||PSPRODUC||','||PNPOLCIA||','||PCESTADO||','||psseguro;
  VOBJECT        varchar2(200) := 'PAC_IAX_COA.F_REGISTRA_PROCESO';
  VNUMERR        number := 0;
  VCURSOR            SYS_REFCURSOR;--ramiro
  VQUERY         VARCHAR(9000);
  VIDIOMA   VARCHAR2(3);

begin
    VIDIOMA := TO_CHAR(PAC_MD_COMMON.F_GET_CXTIDIOMA);
     -- cur := pac_md_coa.f_get_remesa_det (parametros..., mensajes);

     VQUERY :=' SELECT c.smovcoa smovcoa, c.ccompani ccompani, p.tcompani tcompani, c.ccompapr ccompapr, pac_isqlfor.f_agente(pac_agentes.f_get_cageliq('||TO_CHAR(PCEMPRES)||', 2, CSUCURSAL)) sucursal,CSUCURSAL,
     c.fcierre fcierre, c.npolcia npolcia, c.tdescri tdescri, c.cmoneda cmoneda, c.imovimi imovimi,
     c.cimport ctipcoa, ff_desvalorfijo(150, '|| VIDIOMA||', c.cimport) ttipcoa,  m.cmoneda CMONEDA,m.tdescri tdescriMonedas, c.CIMPORT CIMPORT,c.CDEBHAB CDEBHAB,c.CESTADO CESTADO,
     C.TDESCRI TDESCRI,C.TDOCUME TDOCUME
         FROM ctacoaseguro c, companias p, empresas e, monedas m
         WHERE c.ccompani = p.ccompani AND c.cmoneda = m.cmoneda AND m.cmoneda = c.cmoneda '||
         ' AND m.cidioma = '||VIDIOMA||
         ' AND c.imovimi <> 0'||
         ' AND e.cempres(+) = c.cempres'||
         ' AND NVL(c.ccompani, 0) = '||NVL(TO_CHAR(PCCOMPANI),'NVL(c.ccompani, 0)')||
         ' AND NVL(C.CEMPRES, 0) = '||NVL(TO_CHAR(PCEMPRES),'NVL(C.CEMPRES, 0)')||
         ' AND NVL(C.NPOLCIA, 0) = '||NVL(TO_CHAR(PNPOLCIA),'NVL(C.NPOLCIA, 0)')||
         ' AND NVL(C.CSUCURSAL, 0) = '||NVL(TO_CHAR(PCSUCURSAL),'NVL(C.CSUCURSAL, 0)')||
         ' AND NVL(C.CESTADO, 0) = '||NVL(TO_CHAR(PCESTADO),'NVL(C.CESTADO, 0)')||
         ' AND NVL(C.CTIPCOA, 0) = '||NVL(TO_CHAR(PCTIPCOA),'8 ')||
         ' AND NVL(C.SMOVCOA, 0) = '||NVL(TO_CHAR(PSMOVCOA),'NVL(C.SMOVCOA, 0)')||
         ' ORDER BY C.SMOVCOA';

    --p_control_error('VQUERY','VQUERY',VQUERY);

     vcursor := pac_iax_listvalores.f_opencursor(VQUERY, mensajes);

     commit;

      return vcursor;



EXCEPTION

WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         return VCURSOR;

WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         return VCURSOR;


end F_GET_REMESA_DET; --ramiro

/*******************************************************************************
FUNCION F_SET_REMESA_DET
Esta función nos devolverá la consulta de remesas

********************************************************************************/
 -- Bug 22076 - AVT - 04/10/2012 - se crea la funcion
 function f_set_remesa_ctacoa( pcempres IN NUMBER,  --ramiro
      pccompani IN NUMBER,
      pnnumlin IN NUMBER,
      pctipcoa IN NUMBER,
      pcdebhab IN NUMBER,
      psseguro IN NUMBER,
      pnrecibo IN NUMBER,
      psidepag IN NUMBER,
      pfcierre IN DATE,
      pcmovimi IN NUMBER,
      pcimport IN NUMBER,
      pimovimi IN NUMBER,
      pfcambio IN DATE,
      pcestado IN NUMBER,
      ptdescri IN VARCHAR2,
      ptdocume IN VARCHAR2,
      PMODO in number,
      PNPOLCIA in number,
      PCSUCURSAL in number,
      PMONEDA in number,
      psmvcoa in number,
      mensajes OUT t_iax_mensajes)
      return NUMBER is  --ramiro


    VPARAM         varchar2(2000) := PCEMPRES||','||PCCOMPANI||','||pnnumlin||','||pnpolcia||','||
    PCSUCURSAL||','||PCESTADO||','||PFCIERRE||','||PCMOVIMI||','||pctipcoa||','||PIMOVIMI||','||pmodo;
    vobject        VARCHAR2(200) := 'PAC_MD_COA.f_set_remesa_ctacoa';
    VPASEXEC       number(5) := 1;
    VIDIOMA  number(1) := PAC_MD_COMMON.F_GET_CXTIDIOMA;

    VNUMERR number(7);
    v_ttexto VARCHAR2(1000);

BEGIN

VNUMERR := PAC_COA.F_SET_REMESA_CTACOA (PCEMPRES, PCCOMPANI, PNNUMLIN, PCTIPCOA, PCDEBHAB, PSSEGURO,
                                        PNRECIBO, PSIDEPAG, PFCIERRE, PCMOVIMI, PCIMPORT, PIMOVIMI,
                                        PFCAMBIO, PCESTADO, PTDESCRI, PTDOCUME, PMODO, PNPOLCIA, PCSUCURSAL,
                                        PMONEDA,psmvcoa
                                        );

IF vnumerr <> 0 THEN   -- hay errores
   v_ttexto := f_axis_literales(vnumerr, vidioma);
   ROLLBACK;
   pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
   RAISE e_object_error;
END IF;


 pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, NULL, f_axis_literales(111313,PAC_MD_COMMON.F_GET_CXTIDIOMA));

RETURN 0;

EXCEPTION
WHEN e_param_error THEN
 ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, VPASEXEC, vparam);
         RETURN 1;
      WHEN e_object_error THEN
 ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, vnumerr, VPASEXEC, vparam);
         RETURN 1;
WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, vnumerr, VPASEXEC, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         return 1;

END f_set_remesa_ctacoa; --ramiro


END pac_md_coa;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_COA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_COA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_COA" TO "PROGRAMADORESCSI";
