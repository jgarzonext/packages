--------------------------------------------------------
--  DDL for Package Body PAC_MD_LISTADO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MD_LISTADO" AS
/******************************************************************************
   NOMBRE:       pac_md_listado
   PROPÓSITO:    Contiene las funciones para el lanzamiento de listados a través de AXISCONNECT.

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        06/05/2009   JGM              1. Creación del package.
   2.0        06/05/2010   ICV              2. 0012746: APRB95 - lista de movimientos de saldo por cliente
   3.0        03/06/2011   JTS              3. 18734: CRT003 - Modificación de los listados de Administración y Producción
   4.0        15/02/2012   JMF              4. 0021345: LCOL897-LCOL - UAT - TEC - Incidencias de Listados
   5.0        10/10/2012   MDS              5. 0023843: ENSA102-ENSA - Parametrizar los maps de administraci?n/recibos/siniestros
   6.0        28/01/2013   MDS              6. 0024743: (POSDE600)-Desarrollo-GAPS Tecnico-Id 146 - Modif listados para regional sucursal
   7.0        02/05/2013   JMF              7. 0025623 (POSDE200)-Desarrollo-GAPS - Comercial - Id 56
******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

/******************************************************************************
F_GENERAR_LISTADO - Lanza el listado de comisiones de APRA
      p_cempres IN NUMBER,
      p_sproces IN NUMBER,
      p_cagente IN NUMBER,
      mensajes OUT t_iax_mensajes)
Retorna 0 si OK 1 si KO
********************************************************************************/
   FUNCTION f_generar_listado(
      p_cempres IN NUMBER,
      p_sproces IN NUMBER,
      p_cagente IN NUMBER,
      p_fitxer1 IN OUT VARCHAR2,
      p_fitxer2 IN OUT VARCHAR2,
      p_fitxer3 IN OUT VARCHAR2,
      p_fitxer4 IN OUT VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(200)
         := 'P_cempres = ' || p_cempres || ', P_sproces = ' || p_sproces || ',p_cagente = '
            || p_cagente;
      v_object       VARCHAR2(200) := 'pac_md_listado.f_generar_listado';
      v_error        NUMBER(8) := 0;
      v_id           VARCHAR2(30);
      psinterf       NUMBER;
      perror         int_resultado.terror%TYPE;
   BEGIN
      v_error := pac_listado.f_generar_listado(p_cempres, p_sproces, p_cagente, 'APRA012', 7,
                                               v_id);

      IF v_error <> 0 THEN
         RETURN v_error;
      END IF;

      IF v_id IS NOT NULL THEN
         v_error :=
            pac_md_listado.f_crida_llistats
                                          (psinterf, p_cempres, NULL, NULL, NULL, p_sproces,
                                           'PDF',
                                           pac_md_common.f_get_parinstalacion_t('PLANTI_C')
                                           || '\APRA012_F.jrxml',
                                           pac_md_common.f_get_parinstalacion_t('PLANTI_C')
                                           || '\',
                                           'db01', perror, mensajes);

         IF v_error = 0 THEN
            SELECT destino
              INTO p_fitxer1
              FROM int_detalle_doc
             WHERE sinterf = psinterf;
         ELSE
            RETURN v_error;
         END IF;
      END IF;

      psinterf := NULL;
      v_error := pac_listado.f_generar_listado(p_cempres, p_sproces, p_cagente, 'APRA012', 6,
                                               v_id);

      IF v_error <> 0 THEN
         RETURN v_error;
      END IF;

      IF v_id IS NOT NULL THEN
         v_error :=
            pac_md_listado.f_crida_llistats
                                          (psinterf, p_cempres, NULL, NULL, NULL, p_sproces,
                                           'PDF',
                                           pac_md_common.f_get_parinstalacion_t('PLANTI_C')
                                           || '\APRA012_N.jrxml',
                                           pac_md_common.f_get_parinstalacion_t('PLANTI_C')
                                           || '\',
                                           'db01', perror, mensajes);

         IF v_error = 0 THEN
            SELECT destino
              INTO p_fitxer2
              FROM int_detalle_doc
             WHERE sinterf = psinterf;
         ELSE
            RETURN v_error;
         END IF;
      END IF;

      psinterf := NULL;
      v_error := pac_listado.f_generar_listado(p_cempres, p_sproces, p_cagente, 'APRA010', 7,
                                               v_id);

      IF v_error <> 0 THEN
         RETURN v_error;
      END IF;

      IF v_id IS NOT NULL THEN
         v_error :=
            pac_md_listado.f_crida_llistats
                                          (psinterf, p_cempres, NULL, NULL, NULL, p_sproces,
                                           'PDF',
                                           pac_md_common.f_get_parinstalacion_t('PLANTI_C')
                                           || '\APRA010_F.jrxml',
                                           pac_md_common.f_get_parinstalacion_t('PLANTI_C')
                                           || '\',
                                           'db01', perror, mensajes);

         IF v_error = 0 THEN
            SELECT destino
              INTO p_fitxer3
              FROM int_detalle_doc
             WHERE sinterf = psinterf;
         ELSE
            RETURN v_error;
         END IF;
      END IF;

      psinterf := NULL;
      v_error := pac_listado.f_generar_listado(p_cempres, p_sproces, p_cagente, 'APRA010', 6,
                                               v_id);

      IF v_error <> 0 THEN
         RETURN v_error;
      END IF;

      IF v_id IS NOT NULL THEN
         v_error :=
            pac_md_listado.f_crida_llistats
                                          (psinterf, p_cempres, NULL, NULL, NULL, p_sproces,
                                           'PDF',
                                           pac_md_common.f_get_parinstalacion_t('PLANTI_C')
                                           || '\APRA010_N.jrxml',
                                           pac_md_common.f_get_parinstalacion_t('PLANTI_C')
                                           || '\',
                                           'db01', perror, mensajes);

--------------------------------------------
         IF v_error = 0 THEN
            SELECT destino
              INTO p_fitxer4
              FROM int_detalle_doc
             WHERE sinterf = psinterf;
         ELSE
            RETURN v_error;
         END IF;
      END IF;

      psinterf := NULL;
--------------------------------------------
      v_pasexec := 2;
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
   END f_generar_listado;

   /*************************************************************************
      Impresió
      param in out  psinterf
      param in      pcempres:  codi d'empresa
      param in      pdatasource
      param in      pcidioma
      param in      pcmapead
      param out     perror
      param out     mensajes    missatges d'error

      return                    0/1 -> Tot OK/error

      Bug 14067 - 13/04/2010 - AMC
   *************************************************************************/
   FUNCTION f_genera_report(
      psinterf IN NUMBER,
      pcempres IN NUMBER,
      pdatasource IN VARCHAR2,
      pcidioma IN NUMBER,
      pcmapead IN VARCHAR2,   --Bug.: 12746 - 06/05/2010 - ICV
      perror OUT VARCHAR2,
      preport OUT VARCHAR2,
      mensajes OUT t_iax_mensajes,
      genera_report IN NUMBER DEFAULT 1)
      RETURN NUMBER IS
      vobject        VARCHAR2(200) := 'pac_md_listado.f_genera_report';
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
         := 'psinterf=' || psinterf || ' pcempres=' || pcempres || ' pdatasource='
            || pdatasource || ' pcidioma=' || pcidioma || ' pcmapead=' || pcmapead;
      v_error        NUMBER;
      terror         VARCHAR2(200);
      vcterminal     usuarios.cterminal%TYPE;
      v_id           VARCHAR2(30);
      vplantillaorigen VARCHAR2(200);
      vsinterf       NUMBER;
      --Bug.: 12746 - 06/05/2010 - ICV
      v_jasper       detplantillas.cinforme%TYPE;
      vtdescrip      VARCHAR2(250);   -- Bug 15743 - 14/10/2010 - XPL/AMC
      vtipofich      VARCHAR2(4) := 'PDF';
   BEGIN
      IF pcempres IS NULL
         OR pdatasource IS NULL
         OR pcidioma IS NULL
         OR pcmapead IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF genera_report = 2 THEN
         vtipofich := 'XLS';
      END IF;

      v_id := 1;

      --Ini Bug.: 12746 - 06/05/2010 - ICV
      --Buscamos que Jasper Reports Lanzar en Detplantillas apartir del map Recibido.
      -- Bug 15743 - 14/10/2010 - XPL/AMC
      BEGIN
         SELECT cinforme, tdescrip
           INTO v_jasper, vtdescrip
           FROM detplantillas d
          WHERE cmapead = pcmapead
            AND cidioma = pcidioma;
      EXCEPTION
         WHEN OTHERS THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9901184);
            RAISE e_object_error;
      END;

      -- Fi Bug 15743 - 14/10/2010 - XPL/AMC
      vplantillaorigen := pac_md_common.f_get_parinstalacion_t('PLANTI_C') || '\' || v_jasper;

      IF genera_report = 2 THEN
         vplantillaorigen := SUBSTR(vplantillaorigen, 1, INSTR(vplantillaorigen, '.', -1) - 1)
                             || '_EXCEL.'
                             || SUBSTR(vplantillaorigen, INSTR(vplantillaorigen, '.', -1) + 1);
      END IF;

      --Fin Bug.: 12746
      v_error :=
         pac_md_listado.f_crida_llistats
            (vsinterf, pcempres, NULL, NULL, NULL, v_id, vtipofich, vplantillaorigen,
             pac_md_common.f_get_parinstalacion_t('PLANTI_C') || '\' || vtdescrip || '.'
             || LOWER(vtipofich),   -- Bug 15743 - 14/10/2010 - XPL/AMC
             'CSV:' || pdatasource, perror, mensajes);

      IF v_error <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000001, terror);
         RAISE e_object_error;
      END IF;

      v_error := pac_listado.f_get_nombrereport(vsinterf, preport);

      IF v_error <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000001, terror);
         RAISE e_object_error;
      END IF;

      RETURN v_error;
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
   END f_genera_report;

    /******************************************************************************
      f_crida_llistats - Función que hace la llamada a los Jasper Reports
   ********************************************************************************/
   -- bug 0028554 - 13/03/2014 - JMF: parametro opcional pdestcopia
   FUNCTION f_crida_llistats(
      psinterf IN OUT NUMBER,
      pcempres IN NUMBER,
      pterminal IN VARCHAR2,
      pusuario IN VARCHAR2,
      ptpwd IN VARCHAR2,
      pid IN VARCHAR2,
      ptipodestino IN VARCHAR2,
      pplantillaorigen IN VARCHAR2,
      pdestino IN VARCHAR2,
      pdatasource IN VARCHAR2,
      perror OUT VARCHAR2,
      mensajes IN OUT t_iax_mensajes,
      pdestcopia IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER IS
      vobject        VARCHAR2(200) := 'pac_md_listado.f_crida_llistats';
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
         := psinterf || '|' || pcempres || '|' || pterminal || '|' || pusuario || '|' || ptpwd
            || '|' || pid || '|' || ptipodestino || '|' || pplantillaorigen || '|' || pdestino
            || '|' || pdatasource || '|' || pdestcopia;
      error          NUMBER;
      terror         VARCHAR2(200);
      vcterminal     usuarios.cterminal%TYPE;
   BEGIN
      IF pterminal IS NULL THEN
         error := pac_user.f_get_terminal(pac_md_common.f_get_cxtusuario, vcterminal);
      ELSE
         vcterminal := pterminal;
      END IF;

      IF error <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, error);
         RETURN 1;
      END IF;

      error := pac_listado.ff_crida_llistats(psinterf, pcempres, vcterminal, pusuario, ptpwd,
                                             pid, ptipodestino, pplantillaorigen, pdestino,
                                             pdatasource, perror, pdestcopia);

      IF error <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000001, terror);
      END IF;

      RETURN error;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_crida_llistats;

   /******************************************************************************
   f_importes_339
   --BUG18734 - JTS - 03/06/2011
   ********************************************************************************/
   FUNCTION f_importes_339(
      pcidioma VARCHAR2,
      pfinicial VARCHAR2,
      pffinal VARCHAR2,
      pcempres VARCHAR2,
      psproduc VARCHAR2,
      pcramo VARCHAR2,
      pcagrpro VARCHAR2,
      pcagente VARCHAR2)
      RETURN VARCHAR2 IS
      v_tobjeto      VARCHAR2(100) := 'PAC_MD_LISTADO.f_importes_339';
      v_tparam       VARCHAR2(1000)
         := '' || ' i=' || pcidioma || ' fi=' || pfinicial || ' ff=' || pffinal || ' e='
            || pcempres || ' p=' || psproduc || ' r=' || pcramo || ' g=' || pcagrpro || 'a='
            || pcagente;
      v_ntraza       NUMBER := 0;
      v_ttexto       VARCHAR2(32000);
      --
      v_sproduc      VARCHAR2(30);
      v_cramo        VARCHAR2(30);
      v_cagrpro      VARCHAR2(30);
      v_cagente      VARCHAR2(30);
      v_cagente2     VARCHAR2(50);
      v_finiefe      VARCHAR2(100);
      v_ffinefe      VARCHAR2(100);
      v_finiefe2     VARCHAR2(100);
      v_ffinefe2     VARCHAR2(100);
   BEGIN
      v_ntraza := 1000;

      IF psproduc IS NULL THEN
         v_sproduc := 's.sproduc';
      ELSE
         v_sproduc := psproduc;
      END IF;

      IF pcramo IS NULL THEN
         v_cramo := 's.cramo';
      ELSE
         v_cramo := pcramo;
      END IF;

      IF pcagrpro IS NULL THEN
         v_cagrpro := 's.cagrpro';
      ELSE
         v_cagrpro := pcagrpro;
      END IF;

      IF pcagente IS NULL THEN
         v_cagente := 's.cagente';
         v_cagente2 := 'pac_user.ff_get_cagente(f_user)';
      ELSE
         v_cagente := pcagente;
         v_cagente2 := pcagente;
      END IF;

      v_finiefe := LPAD(pfinicial, 8, '0');
      v_finiefe := 'to_date(' || CHR(39) || v_finiefe || CHR(39) || ',''ddmmyyyy'')';
      v_ffinefe := LPAD(pffinal, 8, '0');
      v_ffinefe := 'to_date(' || CHR(39) || v_ffinefe || CHR(39) || ',''ddmmyyyy'')';
      v_finiefe2 := LPAD(pfinicial, 8, '0');
      v_finiefe2 := 'to_date(' || CHR(39) || v_finiefe2 || ' 00:00:00' || CHR(39)
                    || ',''ddmmyyyy hh24:mi:ss'')';
      v_ffinefe2 := LPAD(pffinal, 8, '0');
      v_ffinefe2 := 'to_date(' || CHR(39) || v_ffinefe2 || ' 23:59:59' || CHR(39)
                    || ',''ddmmyyyy hh24:mi:ss'')';
      v_ntraza := 1010;
      -- Bug.: 0021345 - 15/02/2012 - JMF : Afegir camps ram i producte, que abans eren en el map.
      v_ttexto :=
         ' SELECT '
         || ' cramo|| '';'' || desramo || '';'' || sproduc || '';'' || desproducto || '';'' '
         || ' || ncontrato || '';'' || nsolici || '';'' || cagente || '';'' '
         || ' || nif_tomador || '';'' || tomador || '';'' || concepto || '';'' || importe || '';'' '
         || ' || fpago || '';'' ' || ' || DECODE(pac_parametros.f_parlistado_n(' || pcempres
-- Ini bug 23843 - 10/10/2012 - MDS
         || ', ''CCOMPANI''), ' || ' 1, tcompani || '';'', ' || ' NULL)'
         || ' ||  numunidades || '';'' ' || ' || decode(nvl(pac_parametros.f_parlistado_n('
         || pcempres || ' ,''MONEDAINFORME''),0),0,NULL, '
         || 'pac_eco_monedas.f_obtener_moneda_informe(null, sproduc)||'';'')' || 'Linea '
-- Fin bug 23843 - 10/10/2012 - MDS
         || ' FROM (SELECT s.npoliza, s.ncertif, s.cramo, ff_desramo(s.cramo,' || pcidioma
         || ') desramo,'
         || '  s.sproduc, f_desproducto_t(s.cramo,s.cmodali,s.ctipseg,s.ccolect,1,' || pcidioma
         || ') desproducto,'
         || ' SUBSTR(f_formatopol(s.npoliza, s.ncertif, 1), 1, 50) ncontrato, s.sseguro, '
         || ' s.cagrpro, s.nsolici, s.cagente, '
         || ' SUBSTR(d.tnombre, 0, 20) || '' '' || SUBSTR(d.tapelli1, 0, 40) || '' '' '
         || ' || SUBSTR(d.tapelli2, 0, 20) tomador, '
         || ' p.nnumide nif_tomador, ctaseguro.imovimi importe, '
         || ' TO_CHAR(ctaseguro.fvalmov, ''dd/mm/yyyy'') fpago, '
         || ' DECODE(nnumlin, 1, ''i'', DECODE(ctaseguro.cmovimi, 51, ''ex'', ''e'')) tipoaport, '
         || ' DECODE(DECODE(nnumlin, 1, ''i'', DECODE(ctaseguro.cmovimi, 51, ''ex'', ''e'')), '
         || ' ''i'', f_axis_literales(107116, ' || pcidioma || '), '
         || ' ''ex'', f_axis_literales(500156, ' || pcidioma || ') || ''('' '
         || ' || f_axis_literales(109474, ' || pcidioma || ') || '')'', '
         || ' ''e'', f_axis_literales(180435, ' || pcidioma || ')) concepto, '
         || ' c.tcompani '
-- Ini bug 23843 - 10/10/2012 - MDS
         || ', decode(nvl(pac_parametros.f_parlistado_n(' || pcempres
         || ',''VER_NUMUNI_ENMAPS''),0),0,NULL,(SELECT NVL(SUM(NVL(cts.nunidad,0)), 0) FROM ctaseguro cts WHERE cts.sseguro = s.sseguro AND cts.fvalmov <= TRUNC(f_sysdate))) numunidades'
-- Fin bug 23843 - 10/10/2012 - MDS
         || ' FROM seguros s, tomadores, productos, per_personas p, per_detper d, ctaseguro, '
         || ' companias c ' || ' ,agentes_agente_pol ap'   -- Bug 30393/173881 - 08/05/2014 - AMC
         || ' WHERE d.sperson = p.sperson '
         || ' AND d.cagente = ff_agente_cpervisio(s.cagente, f_sysdate, s.cempres) '
         || ' AND s.cempres = ap.cempres AND s.cagente = ap.cagente'   -- Bug 30393/173881 - 08/05/2014 - AMC
         || ' AND s.sseguro = tomadores.sseguro ' || ' AND p.sperson = tomadores.sperson '
         || ' AND tomadores.nordtom = 1 ' || ' AND s.sproduc = productos.sproduc '
         || ' AND s.sseguro = ctaseguro.sseguro ' || ' AND fvalmov BETWEEN' || ' ' || v_finiefe
         || ' AND ' || v_ffinefe || ' AND(cmovimi = 1 ' || ' OR cmovimi = 51 '
         || ' AND 9 = (SELECT ctiprec ' || ' FROM recibos '
         || ' WHERE nrecibo = ctaseguro.nrecibo)) ' || ' AND s.cempres = ' || pcempres
         || ' AND s.sproduc = ' || v_sproduc || ' AND s.cramo = ' || v_cramo
         || ' AND s.cagrpro = ' || v_cagrpro
         || ' and((nvl(pac_parametros.F_PARLISTADO_N(s.cempres,''AGENTE_VISION''),0)=0 '
         || ' and s.cagente = ' || v_cagente || ') '
         || ' or(nvl(pac_parametros.F_PARLISTADO_N(s.cempres,''AGENTE_VISION''),0)=1 '
         || ' AND(s.cagente,s.cempres)IN(SELECT r.cagente,r.cempres FROM redcomercial r '
         || ' WHERE r.fmovfin IS NULL AND LEVEL=DECODE(ff_agente_cpernivel(s.cagente),1,LEVEL,1) '
         || ' START WITH r.cagente=' || v_cagente2
         || ' CONNECT BY PRIOR r.cagente=r.cpadre AND PRIOR r.fmovfin IS NULL))) '
         || ' AND c.ccompani(+) = s.ccompani ' || ' UNION ALL '
         || ' SELECT s.npoliza, s.ncertif, s.cramo, ff_desramo(s.cramo,' || pcidioma
         || ') desramo,'
         || '  s.sproduc, f_desproducto_t(s.cramo,s.cmodali,s.ctipseg,s.ccolect,1,' || pcidioma
         || ') desproducto,'
         || ' SUBSTR(f_formatopol(s.npoliza, s.ncertif, 1), 1, 50) ncontrato, s.sseguro, '
         || ' s.cagrpro, s.nsolici, s.cagente, '
         || ' SUBSTR(d.tnombre, 0, 20) || '' '' || SUBSTR(d.tapelli1, 0, 40) || '' '' '
         || ' || SUBSTR(d.tapelli2, 0, 20) tomador, '
         || ' p.nnumide nif_tomador, v.itotalr importe, TO_CHAR(m.fmovini, '
         || ' ''dd/mm/yyyy'') fpago, ' || ' ''c'' tipoaport, f_axis_literales(102132, '
         || pcidioma || ') concepto, c.tcompani '
-- Ini bug 23843 - 10/10/2012 - MDS
         || ', decode(nvl(pac_parametros.f_parlistado_n(' || pcempres
         || ',''VER_NUMUNI_ENMAPS''),0),0,NULL,(SELECT NVL(SUM(NVL(cts.nunidad,0)), 0) FROM ctaseguro cts WHERE cts.sseguro = s.sseguro AND cts.fvalmov <= TRUNC(f_sysdate))) numunidades'
-- Fin bug 23843 - 10/10/2012 - MDS
         || ' FROM seguros s, recibos r, movrecibo m, vdetrecibos v, tomadores t, per_personas p, '
         || ' per_detper d, companias c ' || ' WHERE d.sperson = p.sperson '
         || ' AND d.cagente = ff_agente_cpervisio(s.cagente, f_sysdate, s.cempres) '
         || ' AND s.sseguro = r.sseguro ' || ' AND s.sseguro = t.sseguro '
         || ' AND t.sperson = p.sperson ' || ' AND m.nrecibo = r.nrecibo '
         || ' AND r.nrecibo = v.nrecibo ' || ' AND m.ctipcob = 1 ' || ' AND m.fmovdia BETWEEN '
         || v_finiefe2 || ' AND ' || v_ffinefe2 || ' AND s.cempres = ' || pcempres
         || ' AND s.sproduc = ' || v_sproduc || ' AND s.cramo = ' || v_cramo
         || ' AND s.cagrpro = ' || v_cagrpro
         || ' and((nvl(pac_parametros.F_PARLISTADO_N(s.cempres,''AGENTE_VISION''),0)=0 '
         || ' and s.cagente = ' || v_cagente || ') '
         || ' or(nvl(pac_parametros.F_PARLISTADO_N(s.cempres,''AGENTE_VISION''),0)=1 '
         || ' AND(s.cagente,s.cempres)IN(SELECT r.cagente,r.cempres FROM redcomercial r '
         || ' WHERE r.fmovfin IS NULL AND LEVEL=DECODE(ff_agente_cpernivel(s.cagente),1,LEVEL,1) '
         || ' START WITH r.cagente=' || v_cagente2
         || ' CONNECT BY PRIOR r.cagente=r.cpadre AND PRIOR r.fmovfin IS NULL))) '
         || ' AND c.ccompani(+) = s.ccompani) ';
      v_ntraza := 9999;
      RETURN v_ttexto;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam || ': Error' || SQLCODE,
                     SQLERRM);
         RETURN 'select 1 linea from dual';
   END f_importes_339;

      /******************************************************************************
      f_importes_645
   -- BUG 24743 - MDS - 28/01/2013
   -- BUG 0025623 - 02/05/2013 - JMF: afegir pperage
   -- versión ampliada de f_importes_339, que incluye los campos Regional y Sucursal para el map 645 de POS
      ********************************************************************************/
   FUNCTION f_importes_645(
      pcidioma VARCHAR2,
      pfinicial VARCHAR2,
      pffinal VARCHAR2,
      pcempres VARCHAR2,
      psproduc VARCHAR2,
      pcramo VARCHAR2,
      pcagrpro VARCHAR2,
      pcagente VARCHAR2,
      pperage IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2 IS
      v_tobjeto      VARCHAR2(100) := 'PAC_MD_LISTADO.f_importes_645';
      v_tparam       VARCHAR2(1000)
         := '' || ' i=' || pcidioma || ' fi=' || pfinicial || ' ff=' || pffinal || ' e='
            || pcempres || ' p=' || psproduc || ' r=' || pcramo || ' g=' || pcagrpro || 'a='
            || pcagente || ' pa=' || pperage;
      v_ntraza       NUMBER := 0;
      v_ttexto       VARCHAR2(32000);
      --
      v_sproduc      VARCHAR2(30);
      v_cramo        VARCHAR2(30);
      v_cagrpro      VARCHAR2(30);
      v_cagente      VARCHAR2(100);
      v_cagente2     VARCHAR2(100);
      v_finiefe      VARCHAR2(100);
      v_ffinefe      VARCHAR2(100);
      v_finiefe2     VARCHAR2(100);
      v_ffinefe2     VARCHAR2(100);
   BEGIN
      v_ntraza := 1000;

      IF psproduc IS NULL THEN
         v_sproduc := 's.sproduc';
      ELSE
         v_sproduc := psproduc;
      END IF;

      IF pcramo IS NULL THEN
         v_cramo := 's.cramo';
      ELSE
         v_cramo := pcramo;
      END IF;

      IF pcagrpro IS NULL THEN
         v_cagrpro := 's.cagrpro';
      ELSE
         v_cagrpro := pcagrpro;
      END IF;

      -- BUG 0025623 - 02/05/2013 - JMF
      IF pperage IS NOT NULL THEN
         -- Buscar los agentes a partir de la persona
         v_cagente := ' and s.cagente in (select cagente from agentes where sperson='
                      || pperage || ')';
         v_cagente2 := ' r.cagente in (select cagente from agentes where sperson=' || pperage
                       || ')';
      ELSIF pcagente IS NOT NULL THEN
         -- Buscar un agente concreto
         v_cagente := ' and s.cagente = ' || pcagente;
         v_cagente2 := ' r.cagente=' || pcagente;
      ELSE
         -- Resto de casos
         v_cagente := NULL;
         v_cagente2 := 'r.cagente=pac_user.ff_get_cagente(f_user)';
      END IF;

      v_finiefe := LPAD(pfinicial, 8, '0');
      v_finiefe := 'to_date(' || CHR(39) || v_finiefe || CHR(39) || ',''ddmmyyyy'')';
      v_ffinefe := LPAD(pffinal, 8, '0');
      v_ffinefe := 'to_date(' || CHR(39) || v_ffinefe || CHR(39) || ',''ddmmyyyy'')';
      v_finiefe2 := LPAD(pfinicial, 8, '0');
      v_finiefe2 := 'to_date(' || CHR(39) || v_finiefe2 || ' 00:00:00' || CHR(39)
                    || ',''ddmmyyyy hh24:mi:ss'')';
      v_ffinefe2 := LPAD(pffinal, 8, '0');
      v_ffinefe2 := 'to_date(' || CHR(39) || v_ffinefe2 || ' 23:59:59' || CHR(39)
                    || ',''ddmmyyyy hh24:mi:ss'')';
      v_ntraza := 1010;
      -- Bug.: 0021345 - 15/02/2012 - JMF : Afegir camps ram i producte, que abans eren en el map.
      v_ttexto :=
         ' SELECT '
         || ' cramo|| '';'' || desramo || '';'' || sproduc || '';'' || desproducto || '';'' '
         || ' || femision || '';'' || ncontrato || '';'' || nsolici || '';'' || cagente || '';'' '
         || ' || nif_tomador || '';'' || tomador || '';'' || concepto || '';'' || importe || '';'' '
         || ' || fpago || '';'' '
-- Ini Bug 24743 - MDS - 28/01/2013
         || ' || pac_isqlfor.f_agente(pac_redcomercial.f_busca_padre(' || pcempres
         || ',cagente,1,f_sysdate))  || '';'' '
         || ' || pac_isqlfor.f_agente(pac_redcomercial.f_busca_padre(' || pcempres
         || ',cagente,2,f_sysdate))  || '';'' '
-- Fin Bug 24743 - MDS - 28/01/2013
         || ' || DECODE(pac_parametros.f_parlistado_n(' || pcempres
-- Ini bug 23843 - 10/10/2012 - MDS
         || ', ''CCOMPANI''), ' || ' 1, tcompani || '';'', ' || ' NULL)' || ' ||  numunidades '
         || 'Linea '
-- Fin bug 23843 - 10/10/2012 - MDS
         || ' FROM (SELECT s.npoliza, s.ncertif, s.cramo, ff_desramo(s.cramo,' || pcidioma
         || ') desramo,'
         || '  s.sproduc, f_desproducto_t(s.cramo,s.cmodali,s.ctipseg,s.ccolect,1,' || pcidioma
         || ') desproducto, to_char(s.femisio,''dd/mm/yyyy'') femision,'
         || ' SUBSTR(f_formatopol(s.npoliza, s.ncertif, 1), 1, 50) ncontrato, s.sseguro, '
         || ' s.cagrpro, s.nsolici, s.cagente, '
         || ' SUBSTR(d.tnombre, 0, 20) || '' '' || SUBSTR(d.tapelli1, 0, 40) || '' '' '
         || ' || SUBSTR(d.tapelli2, 0, 20) tomador, '
         || ' p.nnumide nif_tomador, ctaseguro.imovimi importe, '
         || ' TO_CHAR(ctaseguro.fvalmov, ''dd/mm/yyyy'') fpago, '
         || ' DECODE(nnumlin, 1, ''i'', DECODE(ctaseguro.cmovimi, 51, ''ex'', ''e'')) tipoaport, '
         || ' DECODE(DECODE(nnumlin, 1, ''i'', DECODE(ctaseguro.cmovimi, 51, ''ex'', ''e'')), '
         || ' ''i'', f_axis_literales(107116, ' || pcidioma || '), '
         || ' ''ex'', f_axis_literales(500156, ' || pcidioma || ') || ''('' '
         || ' || f_axis_literales(109474, ' || pcidioma || ') || '')'', '
         || ' ''e'', f_axis_literales(180435, ' || pcidioma || ')) concepto, '
         || ' c.tcompani '
-- Ini bug 23843 - 10/10/2012 - MDS
         || ', decode(nvl(pac_parametros.f_parlistado_n(' || pcempres
         || ',''VER_NUMUNI_ENMAPS''),0),0,NULL,(SELECT NVL(SUM(NVL(cts.nunidad,0)), 0) FROM ctaseguro cts WHERE cts.sseguro = s.sseguro AND cts.fvalmov <= TRUNC(f_sysdate))) numunidades'
-- Fin bug 23843 - 10/10/2012 - MDS
         || ' FROM seguros s, tomadores, productos, per_personas p, per_detper d, ctaseguro, '
         || ' companias c ' || ' WHERE d.sperson = p.sperson '
         || ' AND d.cagente = ff_agente_cpervisio(s.cagente, f_sysdate, s.cempres) '
         || ' AND s.sseguro = tomadores.sseguro ' || ' AND p.sperson = tomadores.sperson '
         || ' AND tomadores.nordtom = 1 ' || ' AND s.sproduc = productos.sproduc '
         || ' AND s.sseguro = ctaseguro.sseguro ' || ' AND fvalmov BETWEEN' || ' ' || v_finiefe
         || ' AND ' || v_ffinefe || ' AND(cmovimi = 1 ' || ' OR cmovimi = 51 '
         || ' AND 9 = (SELECT ctiprec ' || ' FROM recibos '
         || ' WHERE nrecibo = ctaseguro.nrecibo)) ' || ' AND s.cempres = ' || pcempres
         || ' AND s.sproduc = ' || v_sproduc || ' AND s.cramo = ' || v_cramo
         || ' AND s.cagrpro = ' || v_cagrpro
         || ' and((nvl(pac_parametros.F_PARLISTADO_N(s.cempres,''AGENTE_VISION''),0)=0 '
         || v_cagente || ') '
         || ' or(nvl(pac_parametros.F_PARLISTADO_N(s.cempres,''AGENTE_VISION''),0)=1 '
         || ' AND(s.cagente,s.cempres)IN(SELECT r.cagente,r.cempres FROM redcomercial r '
         || ' WHERE r.fmovfin IS NULL AND LEVEL=DECODE(ff_agente_cpernivel(s.cagente),1,LEVEL,1) '
         || ' START WITH ' || v_cagente2
         || ' CONNECT BY PRIOR r.cagente=r.cpadre AND PRIOR r.fmovfin IS NULL))) '
         || ' AND c.ccompani(+) = s.ccompani ' || ' UNION ALL '
         || ' SELECT s.npoliza, s.ncertif, s.cramo, ff_desramo(s.cramo,' || pcidioma
         || ') desramo,'
         || '  s.sproduc, f_desproducto_t(s.cramo,s.cmodali,s.ctipseg,s.ccolect,1,' || pcidioma
         || ') desproducto,TO_CHAR(s.femisio,''dd/mm/yyyy'') femision,'
         || ' SUBSTR(f_formatopol(s.npoliza, s.ncertif, 1), 1, 50) ncontrato, s.sseguro, '
         || ' s.cagrpro, s.nsolici, s.cagente, '
         || ' SUBSTR(d.tnombre, 0, 20) || '' '' || SUBSTR(d.tapelli1, 0, 40) || '' '' '
         || ' || SUBSTR(d.tapelli2, 0, 20) tomador, '
         || ' p.nnumide nif_tomador, v.itotalr importe, TO_CHAR(m.fmovini, '
         || ' ''dd/mm/yyyy'') fpago, ' || ' ''c'' tipoaport, f_axis_literales(102132, '
         || pcidioma || ') concepto, c.tcompani '
-- Ini bug 23843 - 10/10/2012 - MDS
         || ', decode(nvl(pac_parametros.f_parlistado_n(' || pcempres
         || ',''VER_NUMUNI_ENMAPS''),0),0,NULL,(SELECT NVL(SUM(NVL(cts.nunidad,0)), 0) FROM ctaseguro cts WHERE cts.sseguro = s.sseguro AND cts.fvalmov <= TRUNC(f_sysdate))) numunidades'
-- Fin bug 23843 - 10/10/2012 - MDS
         || ' FROM seguros s, recibos r, movrecibo m, vdetrecibos v, tomadores t, per_personas p, '
         || ' per_detper d, companias c ' || ' WHERE d.sperson = p.sperson '
         || ' AND d.cagente = ff_agente_cpervisio(s.cagente, f_sysdate, s.cempres) '
         || ' AND s.sseguro = r.sseguro ' || ' AND s.sseguro = t.sseguro '
         || ' AND t.sperson = p.sperson ' || ' AND m.nrecibo = r.nrecibo '
         || ' AND r.nrecibo = v.nrecibo ' || ' AND m.ctipcob = 1 ' || ' AND m.fmovdia BETWEEN '
         || v_finiefe2 || ' AND ' || v_ffinefe2 || ' AND s.cempres = ' || pcempres
         || ' AND s.sproduc = ' || v_sproduc || ' AND s.cramo = ' || v_cramo
         || ' AND s.cagrpro = ' || v_cagrpro
         || ' and((nvl(pac_parametros.F_PARLISTADO_N(s.cempres,''AGENTE_VISION''),0)=0 '
         || v_cagente || ') '
         || ' or(nvl(pac_parametros.F_PARLISTADO_N(s.cempres,''AGENTE_VISION''),0)=1 '
         || ' AND(s.cagente,s.cempres)IN(SELECT r.cagente,r.cempres FROM redcomercial r '
         || ' WHERE r.fmovfin IS NULL AND LEVEL=DECODE(ff_agente_cpernivel(s.cagente),1,LEVEL,1) '
         || ' START WITH ' || v_cagente2
         || ' CONNECT BY PRIOR r.cagente=r.cpadre AND PRIOR r.fmovfin IS NULL))) '
         || ' AND c.ccompani(+) = s.ccompani) ';
      v_ntraza := 8888;
      RETURN v_ttexto;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam || ': Error' || SQLCODE,
                     SQLERRM);
         RETURN 'select 1 linea from dual';
   END f_importes_645;
END pac_md_listado;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_LISTADO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_LISTADO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_LISTADO" TO "PROGRAMADORESCSI";
