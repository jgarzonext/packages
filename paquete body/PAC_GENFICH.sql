--------------------------------------------------------
--  DDL for Package Body PAC_GENFICH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_GENFICH" AS
  /******************************************************************************
     NOMBRE:       PAC_GENFICH
     PROPÓSITO: Generación de ficheros

     REVISIONES:
     Ver        Fecha       Autor  Descripción
     ---------  ----------  -----  ------------------------------------
     1.0        22/07/2011  APD    Creación del package. (Bug 18843)
     2.0        05/08/2011  JMF    2. 0019217: MSG800-MSGV - Afegir camps en el llistat de liquidacions
     3.0        25/10/2011  DRA    3. 0019069: LCOL_C001 - Co-corretaje
     4.0        15/11/2011  APD    4. 0020153: LCOL_C001: Ajuste en el cálculo del recibo
     5.0        15/02/2012  APD    5. 0021303: LCOL_A001: Fichero de liquidación
     6.0        16/02/2012  APD    6. 0021377: LCOL_A001: Fichero de liquidaciones
     7.0        18/05/2012  JMF    7. 0022302: LCOL_A001: Llistat de liquidacions
     8.0        19/05/2012  MDS    8. 0022205: CALI704- Parametrització liquidacions
     9.0        25/06/2012  MCA    9. 0022637: LCOL: Listado de liquidación previa y real
    10.0        14/08/2012  ECP   10. 0023351: CALI: Porcentaje comisión en el listado de liquidación
    11.0        29/11/2012  LEC   11. 0022255: LCOL: Calculo de la comision teniendo en cuenta el recargo x fraccionamiento. pac_genfich
    12.0        09/01/2013  JMF   0025581: LCOL_C001-LCOL: Q-trackers de co-corretaje
    13.0        04/03/2013  DRA   13. 0025924: LCOL: Excel de liquidaciones con co-corretaje
    14.0        07/03/2013  MCA   14. 25924: Recargo de fraccionamiento
    15.0        09/09/2013  MCA   15. 28101: Agrupación prod contable y compañía
    16.0        01/10/2013  JGR   0028370: LCOL_A003-Error porcentaje de comisiones en el listado de liquidación - QT-9420
    17.0        01/10/2013  JLV   0028367: Al generar la liquidación previa de Oleoducto no se visualiza el % liquidado
    18.0        02/10/2013  MCA   28403: Liquidaci?n comisi?n Oleoducto
    19.0        29/10/2013  MCA   28660: Listado de liquidaciones
    20.0        22/01/2014  MMM   29790: LCOL En la liquidación de comisiones se muestra campo Saldo final de los apuntes automáticos (Liberty Web)
    21.0        08/01/2016  AFM   39738: Excel de liquidación descuadra vs pago real. No inicializa variable retención.
    22.0        30/08/2016  JLTS  CONF-276: Cambios en los procesos de comisiones (GCOM11)
  ******************************************************************************/

  /*************************************************************************
     FUNCTION f_llistat_comissions
     return               : 0 OK - 1 KO
  *************************************************************************/
  FUNCTION f_llistat_comissions(p_cempres IN NUMBER, p_cagente IN NUMBER,
                                p_sproliq IN NUMBER, p_cidioma IN NUMBER,
                                p_fecini IN DATE, p_fecfin IN DATE,
                                p_tipoproceso IN VARCHAR2,
                                p_rutafich OUT VARCHAR2) RETURN NUMBER IS
    fitx        utl_file.file_type;
    v_error     NUMBER;
    v_dividopor NUMBER;
    v_tempres   VARCHAR2(100);
    v_periodo   VARCHAR2(25);
    v_traza     NUMBER := 1;
    -- Bug 0022302 - JMF - 18/05/2012
    v_obj      VARCHAR2(200) := 'PAC_GENFICH.f_llistat_comissions';
    v_params   VARCHAR2(500) := 'e=' || p_cempres || ' a=' || p_cagente ||
                                ' l=' || p_sproliq || ' i=' || p_cidioma ||
                                ' 1=' || p_fecini || ' 2=' || p_fecfin ||
                                ' t=' || p_tipoproceso;
    v_prima    detrecibos.iconcep%TYPE; -- LECG Declaramos una variable para el recargo
    v_iconcep  detrecibos.iconcep%TYPE; -- LECG Declaramos una variable para el importe
    v_primaaux detrecibos.iconcep%TYPE;
    --Bug 36509 10/09/2015 KJSC Se ingresa consulta de agentes retenidos
    v_agenteret NUMBER;

    -- Bug 21230 - APD - 16/04/2012 - se añade el parametro pp_cagente al cursor
    -- se sustituye p_cagente por pp_cagente
    --Bug 22637 - MCA 25/06/2012 Sólo se tienen en cuenta los agentes de la liquidación
    CURSOR c_agentes(pp_cagente IN NUMBER) IS
    /*         SELECT   cempres, cagente, tnombre, sproliq, fliquid
                 FROM (SELECT   cempres, cagente,
                                pac_redcomercial.ff_desagente(cagente, p_cidioma) tnombre,
                                MAX(sproliq) sproliq, MAX(fliquid) fliquid
                           FROM liquidacab
                          WHERE sproliq = p_sproliq
                            AND cempres = p_cempres
                            AND cagente = NVL(pp_cagente, cagente)
                            AND ctipoliq = DECODE(p_tipoproceso, 'R', 0, 'P', 1)
                       GROUP BY cempres, cagente)
             ORDER BY cempres, cagente;*/
      -- INI CONF-276 - 30/08/2016 – JLTS – Inclusión del regiem fiscal
      SELECT cempres, cagente, tnombre, sproliq, fliquid, regfiscal
        FROM (SELECT l.cempres, l.cagente,
                      pac_redcomercial.ff_desagente(l.cagente, p_cidioma) tnombre,
                      MAX(l.sproliq) sproliq, MAX(l.fliquid) fliquid,
                      (SELECT ff_desvalorfijo(1045, p_cidioma, pr.cregfiscal)
                          FROM agentes ag, per_regimenfiscal pr
                         WHERE ag.sperson = pr.sperson
                           AND ag.cagente = l.cagente
                           AND pr.fefecto =
                               (SELECT MAX(pr2.fefecto)
                                  FROM per_regimenfiscal pr2
                                 WHERE pr2.sperson = pr.sperson
                                   AND pr2.cagente = pr.cagente)) regfiscal
                 FROM liquidacab l
                WHERE l.sproliq = p_sproliq
                  AND l.cempres = p_cempres
                  AND l.cagente = nvl(pp_cagente, cagente)
                  AND l.ctipoliq = decode(p_tipoproceso, 'R', 0, 'P', 1)
                GROUP BY l.cempres, l.cagente)
       ORDER BY cempres, cagente;
      -- FIN CONF-276 - 30/08/2016 – JLTS
    -- Bug 0019217 - JMF - 05/08/2011: afegir sseguro, cmodcon
    -- Bug 21303 - APD - 15/02/2012 - se añade nanuali
    -- Bug 0022302 - JMF - 18/05/2012: afegir ctiprec
    CURSOR c_recibos(vagente IN NUMBER) IS
      SELECT nrecibo, itotalr, iprinet, icomliq, iretenccom, fefecto,
             sseguro, cmodcon, nmovimi, nanuali, ctiprec, iconvoleducto, -- Bug 25988/145805 - 06/06/2013 - AMC
             ppartici --BUG 1890 AP 14/03/2018
        FROM (SELECT ll.nrecibo,
                      nvl(ll.itotalr_moncia, nvl(ll.itotalr, 0)) itotalr,
                      nvl(ll.iprinet_moncia, nvl(ll.iprinet, 0)) iprinet,
                      nvl(nvl(SUM(ll.icomisi_moncia), SUM(ll.icomisi)), 0) icomliq,
                      r.fefecto,

                      --NVL((SUM(ll.icomisi) * 0.16), 0) iiva,
                      nvl(nvl(SUM(ll.iretenccom_moncia), SUM(ll.iretenccom)),
                           0) iretenccom,
                      nvl((select ppartici from age_corretaje where cagente = vagente and sseguro = r.sseguro and NMOVIMI = (SELECT MAX (NMOVIMI) FROM AGE_CORRETAJE where cagente = vagente and sseguro = r.sseguro)),0) ppartici, --BUG 1890 AP 14/03/2018
                       --Bug 18843/91812-06/09/2011-AMC
                      MAX(r.sseguro) sseguro,
                      MAX(decode(r.nanuali, 1, 1, 2)) cmodcon, r.nmovimi,
                      r.nanuali, r.ctiprec,
                      nvl(nvl(SUM(ll.iconvoleod_moncia), SUM(ll.iconvoleducto)),
                           0) iconvoleducto -- Bug 25988/145805 - 06/06/2013 - AMC
                 FROM liquidacab lc, liquidalin ll, recibos r
                WHERE lc.cagente = ll.cagente
                  AND lc.cempres = ll.cempres
                  AND lc.nliqmen = ll.nliqmen
                  AND lc.sproliq = p_sproliq
                  AND lc.cempres = p_cempres
                  AND lc.cagente = nvl(vagente, lc.cagente)
                  AND r.nrecibo(+) = ll.nrecibo -- Bug 21230 - APD - 16/04/2012 - se añade el (+)
                  AND lc.ctipoliq = decode(p_tipoproceso, 'R', 0, 'P', 1)
                GROUP BY ll.nrecibo, ll.iprinet, ll.iprinet_moncia, ll.itotalr,
                         ll.itotalr_moncia, r.fefecto, r.nmovimi, r.nanuali,
                         r.ctiprec, iconvoleducto,r.sseguro -- Bug 25988/145805 - 06/06/2013 - AMC
               )
       ORDER BY nrecibo;

    CURSOR c_liquid(vagente IN NUMBER, vfliquid IN DATE) IS
      SELECT cconcta, tcconcta, iimport, tipolin, estado --, ccompani --, nnumlin  BUG 1896 AP 23/04/2018  cdebhab bug 28101 MCA se elimina el debe/haber
        FROM (SELECT d.cconcta, d.tcconcta,
                      SUM(decode(c.cdebhab, 1, c.iimport, 2, c.iimport * -1)) iimport,
                     -- c.tdescrip, BUG 1896 AP 23/04/2018
                      ff_desvalorfijo(693, p_cidioma, c.cmanual) tipolin,
                      ff_desvalorfijo(18, p_cidioma, c.cestado) estado,
                       -- c.nnumlin  Bug  28101  09/09/2013
                      pac_adm.f_cnvprodgaran_ext(c.sproduc, NULL) sproducconta
                    --  ccompani BUG 1896 AP 23/04/2018
                 FROM ctactes c, desctactes d
                WHERE c.sproces IS NULL
                  AND c.cempres = p_cempres
                  AND c.cagente = vagente
                     --  AND c.cmanual = 0
                  AND c.cestado = 1 -- los apuntes que están pdtes
                  AND c.fvalor <= vfliquid
                  AND d.cconcta = c.cconcta
                  AND d.cidioma = p_cidioma
                  AND p_tipoproceso = 'P'
                GROUP BY pac_adm.f_cnvprodgaran_ext(c.sproduc, NULL), --ccompani, BUG 1896 AP 23/04/2018
                          --Bug 28101  MCA   c.cdebhab,
                         d.cconcta, d.tcconcta, --c.tdescrip, BUG 1896 AP 23/04/2018
                         ff_desvalorfijo(693, p_cidioma, c.cmanual),
                         ff_desvalorfijo(18, p_cidioma, c.cestado) --Bug  28101  09/09/2013
               UNION ALL
               SELECT d.cconcta, d.tcconcta,
                      SUM(decode(c.cdebhab, 1, c.iimport, 2, c.iimport * -1)) iimport,
                    --  c.tdescrip, BUG 1896 AP 23/04/2018
                      ff_desvalorfijo(693, p_cidioma, c.cmanual) tipolin,
                      ff_desvalorfijo(18, p_cidioma, c.cestado) estado,
                       --c.nnumlin  Bug  28101  09/09/2013
                      pac_adm.f_cnvprodgaran_ext(c.sproduc, NULL) sproducconta
                    --  ccompani BUG 1896 AP 23/04/2018
                 FROM ctactes c, desctactes d
                WHERE c.sproces = p_sproliq
                  AND c.cempres = p_cempres
                  AND c.cagente = vagente
                  AND c.iimport <> 0
                     --AND c.cmanual = 0
                     -- 20.0 - 22/01/2014 - MMM - 29790: LCOL En la liquidación de comisiones se muestra campo Saldo final... - Inicio
                     --AND c.cconcta NOT IN (98, 99, 97)   --Bug  28403 Se incluye concepto Oleoducto para excluirlo
                  AND c.cconcta NOT IN (98, 99, 97, 96) --Bug  28403 Se incluye concepto Oleoducto para excluirlo
                     -- 20.0 - 22/01/2014 - MMM - 29790: LCOL En la liquidación de comisiones se muestra campo Saldo final... - Fin
                  AND d.cconcta = c.cconcta
                  AND d.cidioma = p_cidioma
                  AND p_tipoproceso = 'R'
                GROUP BY pac_adm.f_cnvprodgaran_ext(c.sproduc, NULL), --ccompani, BUG 1896 AP 23/04/2018
                          --Bug 28101  MCA   c.cdebhab,
                         d.cconcta, d.tcconcta, --c.tdescrip, BUG 1896 AP 23/04/2018
                         ff_desvalorfijo(693, p_cidioma, c.cmanual),
                         ff_desvalorfijo(18, p_cidioma, c.cestado)) --Bug  28101  09/09/2013
       ORDER BY sproducconta, cconcta ASC; --Bug 28660 MCA 29/10/2013  Ordernación de la visualización de los impuestos

    TYPE t_lits IS TABLE OF VARCHAR2(50);

    ttexto    VARCHAR2(100);
    v_ruta    VARCHAR2(100);
    v_tfitxer VARCHAR2(100);
    v_cad     VARCHAR2(600) := NULL;
    v_lits    t_lits := t_lits(f_axis_literales(101619, p_cidioma),
                                -- 'Empresa'
                               f_axis_literales(9000531, p_cidioma),
                                -- 'Cod. Agente',
                               f_axis_literales(105940, p_cidioma),
                                -- 'Des. Agente',
                               f_axis_literales(9902234, p_cidioma),
                                -- 'Periodo de Liquidacion’
                                -- INI CONF-276 - 30/08/2016 – JLTS – Inclusión del espacio y regiem fiscal
                                -- chr(10),
                                   '',
                                -- Campo vacio – descripción retenido
                               f_axis_literales(9902257, p_cidioma)); -- Regimen fiscal
                                -- FIN CONF-276 - 30/08/2016 – JLTS
    v_civa       NUMBER;
    v_ireten     NUMBER;
    v_riva       NUMBER;
    v_iretefuent NUMBER;
    v_iretica    NUMBER;
    v_regimen    NUMBER;
    v_tsucursal  VARCHAR2(100);
    v_tcanal     VARCHAR2(100);
    v_cpadre     NUMBER;
    v_ttotr      NUMBER := 0;
    v_tppar      NUMBER := 0;
    v_tipri      NUMBER := 0;
    v_ticom      NUMBER := 0;
    v_tscom      NUMBER := 0;
    v_tireten    NUMBER := 0;
    v_triva      NUMBER := 0;
    v_trfue      NUMBER := 0;
    v_trica      NUMBER := 0;
    v_toti       NUMBER := 0;
    v_tman       NUMBER := 0;
    v_trecs      NUMBER := 0;
    v_total      NUMBER := 0;
    v_totage     NUMBER := 0;
    v_fliquid    DATE;
    v_info       NUMBER := 0;
    v_info2      NUMBER := 0;
    v_cagen      NUMBER := 0;
    -- ini Bug 0019217 - JMF - 05/08/2011
    v_pcomisi    NUMBER;
    v_pretenc    NUMBER;
    v_polcert    VARCHAR2(100);
    v_tomador    VARCHAR2(500);
    v_fefectovig DATE; --BUG20342 - JTS - 02/12/2011
    v_sproduc    NUMBER; --BUG20342 - JTS - 02/12/2011
    v_fefectopol DATE; --BUG20342 - JTS - 02/12/2011
    -- fin Bug 0019217 - JMF - 05/08/2011
    v_cmodcom NUMBER;
    v_cagente NUMBER; -- Bug 21230 - APD - 16/04/2012
    -- Bug 0022302 - JMF - 18/05/2012
    v_pac_propio parempresas.tvalpar%TYPE;
    -- Ini Bug 22205 - MDS - 19/05/2012
    v_titulo_retencion VARCHAR2(50);
    v_dato_ireten      VARCHAR2(50);
    v_total_ireten     VARCHAR2(50);
    v_corretage        NUMBER;
    v_irecfra          NUMBER;
    v_titulo_comi      VARCHAR2(100);
    v_dato_comi        VARCHAR2(100);
    v_titulo_compa     VARCHAR2(100);
    v_dato_compa       VARCHAR2(100);
    v_dato_sproduc     NUMBER;
    t_sproduc          VARCHAR2(200);
    v_titulo_pro       VARCHAR2(100);
    vx_total_ireten    NUMBER;
    v_porcen_comi      NUMBER;
    v_porcen_dato      VARCHAR2(30);
    --Bug 28403  2/10/2013 Convenio Oleoducto
    v_ticomoleoduc  NUMBER := 0;
    v_total_oleoduc VARCHAR2(50);
    v_movimi        NUMBER;
    vparti          NUMBER;
    comi_corretaje  NUMBER := 0;
    comi_negocio    NUMBER := 0;
    v_pcomisi_age   NUMBER := 0;

    -- Fin Bug 22205 - MDS - 19/05/2012
    PROCEDURE busca_suc(p_emp IN NUMBER, p_age IN NUMBER, p_tip IN NUMBER,
                        p_suc OUT NUMBER) IS
      PROCEDURE p_interior(p_age IN NUMBER, p_tip IN NUMBER) IS
        v_tip redcomercial.ctipage%TYPE;
        v_pad redcomercial.cpadre%TYPE;
      BEGIN
        SELECT MAX(ctipage), MAX(cpadre)
          INTO v_tip, v_pad
          FROM redcomercial
         WHERE cempres = p_emp
           AND cagente = p_age
           AND fmovfin IS NULL;

        IF v_tip = p_tip THEN
          p_suc := p_age;
        ELSIF v_tip IS NULL THEN
          p_suc := NULL;
        ELSIF v_tip <> p_tip AND v_pad IS NOT NULL THEN
          p_interior(v_pad, p_tip);
        END IF;
      END;
    BEGIN
      p_suc := NULL;
      p_interior(p_age, p_tip);
    END;
  BEGIN
    v_ruta  := f_parinstalacion_t('INFORMES'); -- Ruta donde se generan los informes.
    v_traza := 2;

    BEGIN
      SELECT DISTINCT cagente
        INTO v_cagen
        FROM liquidacab lc
       WHERE lc.sproliq = p_sproliq;
    EXCEPTION
      WHEN OTHERS THEN
        v_cagen := NULL;
    END;

    -- Bug 0022302 - JMF - 18/05/2012
    v_pac_propio := pac_parametros.f_parempresa_t(p_cempres, 'PAC_PROPIO');

    IF p_tipoproceso = 'R' THEN
      IF v_cagen IS NOT NULL THEN
        v_tfitxer := f_axis_literales(9902253, p_cidioma) || '_' ||
                     p_cempres || '_' || v_cagen || '_' ||
                     to_char(p_fecfin, 'ddmmrrrr') || '_' || p_sproliq ||
                     '.csv';
      ELSE
        v_tfitxer := f_axis_literales(9902253, p_cidioma) || '_' ||
                     p_cempres || '_' || to_char(p_fecfin, 'ddmmrrrr') || '_' ||
                     p_sproliq || '.csv';
      END IF;
    ELSE
      IF v_cagen IS NOT NULL THEN
        v_tfitxer := f_axis_literales(9902254, p_cidioma) || '_' ||
                     p_cempres || '_' || v_cagen || '_' ||
                     to_char(p_fecfin, 'ddmmrrrr') || '_' || p_sproliq ||
                     '.csv';
      ELSE
        v_tfitxer := f_axis_literales(9902254, p_cidioma) || '_' ||
                     p_cempres || '_' || to_char(p_fecfin, 'ddmmrrrr') || '_' ||
                     p_sproliq || '.csv';
      END IF;
    END IF;

    v_traza    := 3;
    p_rutafich := f_parinstalacion_t('INFORMES_C') || '\' || v_tfitxer;
    --INI CONF-803 En confianza no genera no genera el listado
    IF NVL(pac_parametros.f_parempresa_t(pac_md_common.f_get_cxtempresa,'SO_SERV_FICH'),'WINDOWS') = 'UNIX' THEN
       p_rutafich := REPLACE(p_rutafich, '\', '/');
    END IF;
    --FIN CONF-803 En confianza no genera no genera el listado

    fitx       := utl_file.fopen(v_ruta, v_tfitxer, 'w');
    v_traza    := 4;

   -- CONF-276 - 30/08/2016 – JLTS – Se cambia el 4 por el 6 del LOOP
    FOR i IN 1 .. 6 LOOP
      ttexto := v_lits(i);

      IF v_cad IS NULL THEN
        v_cad := ttexto;
      ELSE
        v_cad := v_cad || ';' || ttexto;
      END IF;
    END LOOP;

    utl_file.put_line(fitx, v_cad);
    v_traza := 5;

    -- Bug 21230 - APD - 20/02/2012 - se añade el IF para saber de que modo
    -- se quiere insertar las comisiones indirectas
    IF nvl(pac_parametros.f_parempresa_n(p_cempres, 'CALC_COMIND'), 0) = 1 THEN
      -- por cuadros de comisión indirecta pero modalidad directa
      v_cagente := NULL; -- para que muestre las comisiones de todos los agentes
      -- ya sean de comision directa como indirecta
    ELSE
      v_cagente := p_cagente;
    END IF;

    -- cursores
    -- Bug 21230 - APD - 16/04/2012 - se añade el parametro v_cagente al cursor
    FOR reg IN c_agentes(v_cagente) LOOP
      v_info  := 0;
      v_info2 := 0;
      -- Bug 21377 - APD - 16/02/2012 - la cabecera del excel se ha de mostrar siempre,
      -- independientemente de si hay o no recibos
      v_error := f_desempresa(reg.cempres, NULL, v_tempres);
      v_traza := 6;

      --Bug 36509 10/09/2015 KJSC Se ingresa consulta de agentes retenidos
      SELECT COUNT(lr.sperson)
        INTO v_agenteret
        FROM lre_personas lr
       WHERE lr.sperson =
             (SELECT a.sperson FROM agentes a WHERE a.cagente = reg.cagente)
         AND lr.cclalis = 2
         AND lr.ctiplis = 48
         AND p_fecini BETWEEN nvl(lr.finclus, f_sysdate) AND
             nvl(lr.fexclus, f_sysdate);

      v_traza := 9;

      --Bug 36509 10/09/2015 KJSC Se verifica si el agente esta retenido.
/*
      IF v_agenteret > 0 THEN
        utl_file.put_line(fitx,
                          v_tempres || ';' || reg.cagente || ';' ||
                           reg.tnombre || ';' ||
                           to_char(p_fecfin, 'DD/MM/YYYY') || ';' || ' ' || ';' ||
                           f_axis_literales(9908438, p_cidioma));
        utl_file.put_line(fitx, '');
      ELSE
        utl_file.put_line(fitx,
                          v_tempres || ';' || reg.cagente || ';' ||
                           reg.tnombre || ';' ||
                           to_char(p_fecfin, 'DD/MM/YYYY'));
        utl_file.put_line(fitx, '');
      END IF;*/
         --Bug 36509 10/09/2015 KJSC Se verifica si el agente esta retenido.

         -- INI CONF-276 - 30/08/2016 – JLTS – Inclusión del regiem fiscal
         IF v_agenteret > 0 THEN
            UTL_FILE.put_line(fitx,
                              v_tempres || ';' || reg.cagente || ';' || reg.tnombre || ';'
                              || TO_CHAR(p_fecfin, 'DD/MM/YYYY') || ';' || ' ' || ';'
                              || f_axis_literales(9908438, p_cidioma) || ';' || reg.regfiscal);
            UTL_FILE.put_line(fitx, '');
         ELSE
            UTL_FILE.put_line(fitx,
                              v_tempres || ';' || reg.cagente || ';' || reg.tnombre || ';'
                              || TO_CHAR(p_fecfin, 'DD/MM/YYYY')|| ';;' || reg.regfiscal);
            UTL_FILE.put_line(fitx, '');
         END IF;
         -- FIN CONF-276 - 30/08/2016 – JLTS

      v_traza := 208;

      -- fin Bug 21377 - APD - 16/02/2012
      FOR reg2 IN c_recibos(reg.cagente) LOOP
        v_traza := 209;

        IF v_info = 0 THEN
          -- Bug 0019217 - JMF - 05/08/2011: Afegir camps
          -- Ini Bug 22205 - MDS - 19/05/2012
          IF nvl(pac_parametros.f_parempresa_n(p_cempres, 'VISUAL_RETENC'),
                 0) = 1 THEN
            v_titulo_retencion := f_axis_literales(101714, p_cidioma) || ';';
          ELSE
            v_titulo_retencion := NULL;
          END IF;

          -- Bug 25988/145805 - 06/06/2013 - AMC
          IF nvl(pac_parametros.f_parempresa_n(p_cempres,
                                               'SOBRECOMISION_EMISIO'), 0) = 1 THEN
            v_titulo_comi := f_axis_literales(9905677, p_cidioma) || ';' ||
                             f_axis_literales(9906014, p_cidioma) || ';'; --JLV 17.0
          ELSE
            v_titulo_comi := NULL;
          END IF;

          -- Fi Bug 25988/145805 - 06/06/2013 - AMC

          -- Bug 27141/146032 - 06/06/2013 - AMC
          IF nvl(pac_parametros.f_parempresa_n(p_cempres, 'MOSTRAR_COMPANIA'),
                 0) = 1 THEN
            v_titulo_compa := f_axis_literales(9902917, p_cidioma) || ';';
            v_titulo_pro   := f_axis_literales(100829, p_cidioma) || ';';
          ELSE
            v_titulo_compa := NULL;
            v_titulo_pro   := NULL;
          END IF;

          -- Fi Bug 27141/146032 - 06/06/2013 - AMC

          -- Fin Bug 22205 - MDS - 19/05/2012
          utl_file.put_line(fitx,
                            upper(';' ||
                                   f_axis_literales(109253, p_cidioma) -- NRECIBO
                                   || ';' ||
                                   f_axis_literales(100883, p_cidioma) -- Fecha Efecto
                                   || ';' ||
                                   f_axis_literales(89906170, p_cidioma) -- Comisión Ganada --BUG 1890 AP 14/03/2018
                                   || ';' ||
                                   f_axis_literales(89906169, p_cidioma) -- % Comisión Propia  --BUG 1890 AP 14/03/2018
                                   || ';' ||
                                   f_axis_literales(1000563, p_cidioma) -- Prima RBO --BUG 1890 AP 14/03/2018
                                   || ';' ||
                                   f_axis_literales(1000335, p_cidioma) -- Prima --BUG 1890 AP 14/03/2018
                                   -- Ini Bug 22205 - MDS - 19/05/2012
                                   || v_titulo_retencion -- RETENCIÓN
                                   -- Fin Bug 22205 - MDS - 19/05/2012
                                   || ';' || v_titulo_comi -- Bug 25988/145805 - 06/06/2013 - AMC
                                   ||
                                   f_axis_literales(89906167, p_cidioma) -- Comision por Corretaje --BUG 1890 AP 14/03/2018
                                   || ';' ||
                                   f_axis_literales(89906168, p_cidioma) -- % Participacion de Comision en Corretaje --BUG 1890 AP 14/03/2018
                                   || ';' ||
                                   f_axis_literales(100836, p_cidioma) -- Núm. póliza
                                   || ';' ||
                                   f_axis_literales(101027, p_cidioma) -- Tomador
                                   || ';' || v_titulo_compa -- Bug 27141/146032 - 06/06/2013 - AMC
                                   || v_titulo_pro));
          v_traza := 10;

          BEGIN
            SELECT nvalpar
              INTO v_regimen
              FROM per_parpersonas p, agentes a
             WHERE a.sperson = p.sperson
               AND a.cagente = reg.cagente
               AND p.cparam = 'TIPO_REGIMEN';
          EXCEPTION
            WHEN OTHERS THEN
              v_regimen := -1;
          END;

          v_traza := 11;
          v_ttotr := 0;
          v_tipri := 0;
          v_ticom := 0;
          v_info  := 1;
        END IF;

        v_civa   := 0;
        v_traza  := 12;
        v_ireten := reg2.iretenccom; --Bug 18843/91812-06/09/2011-AMC
        v_riva   :=  /*reg2.iretiva * */
         v_civa;

        IF v_regimen NOT IN (0, 2, 3) THEN
          v_iretefuent := 0;
        ELSE
          v_iretefuent := 0; --reg2.iretefuent;
        END IF;

        IF v_regimen NOT IN (2, 3) THEN
          v_iretica := 0;
        ELSE
          v_iretica := 0; -- reg2.iretica;
        END IF;

        v_corretage := pac_corretaje.f_tiene_corretaje(reg2.sseguro, NULL);

        IF v_corretage <> 1 THEN
          --JLV,
          -- Bug 21382 - APD - 17/02/2012 - se debe mostrar la media ponderada del % de
          -- comision
          -- se puede calcular:
          -- 1.- buscando el % de la f_pcomisi para cada garantia y luego
          -- hacer la media ponderada
          -- o
          -- 2.- buscar directamente el porcentaje de comision a partir de la prima neta y
          -- la comision
          -- se opta por hacerlo de la segunda opcion pues es mas rapido
          v_error := 0;

          IF nvl(reg2.iprinet, 1) = 0 THEN
            --Para los recibos de tipo 5 (comisión) que solo tienen una garnatía y no tienen prima neta.
            IF f_es_renovacion(reg2.sseguro) = 0 THEN
              -- es cartera
              v_cmodcom := 2;
            ELSE
              -- si es 1 es nueva produccion
              v_cmodcom := 1;
            END IF;

            -- ini Bug 0022302 - JMF - 18/05/2012: afegir ctiprec
            -- En los recibos de ahorro se ha de ir a mirar el de rendimiento a la tramo (si existe)
            v_pcomisi := NULL;
            v_error   := 0;

            IF reg2.ctiprec = 5 THEN
              SELECT MAX(sproduc)
                INTO v_sproduc
                FROM seguros
               WHERE sseguro = reg2.sseguro;

              DECLARE
                v_cadena VARCHAR2(1000);
              BEGIN
                v_cadena := ' BEGIN ' || v_pac_propio ||
                            '.proceso_liscomis_calcom( ' || v_sproduc ||
                            ', :v_error, :v_pcomisi); ' || ' END;';

                EXECUTE IMMEDIATE v_cadena
                  USING OUT v_error, OUT v_pcomisi;

                IF v_error <> 0 THEN
                  p_tab_error(f_sysdate, f_user, v_obj, v_traza,
                              'error=' || v_error, v_cadena);
                  v_error := 0;
                END IF;
              EXCEPTION
                WHEN OTHERS THEN
                  v_pcomisi := NULL;
                  v_error   := 0;
              END;
            END IF;

            IF v_error = 0 AND v_pcomisi IS NULL THEN
              -- Si no es recibo ahorro o no existes package, calculo normal.
              v_error := f_pcomisi(reg2.sseguro, v_cmodcom, reg2.fefecto,
                                   v_pcomisi, v_pretenc);
            END IF;
            -- fin Bug 0022302 - JMF - 18/05/2012
          ELSE
            -- ini Bug 0023351 - ECP- 14/08/2012
            IF nvl(pac_parametros.f_parempresa_n(p_cempres,
                                                 'COMISION_LISTADO'), 0) = 0 THEN
              --ini Bug 25924 -Tener en cuenta el recargo por fraccionamiento cuando es % ponderado
              BEGIN
                SELECT irecfra
                  INTO v_irecfra
                  FROM vdetrecibos_monpol
                 WHERE nrecibo = reg2.nrecibo;
              EXCEPTION
                WHEN OTHERS THEN
                  v_irecfra := 0;
              END;

              v_pcomisi := (nvl(reg2.icomliq, 0) * 100) /
                           nvl((reg2.iprinet +
                               v_irecfra * sign(reg2.iprinet)), 1);
              --fin Bug 25924
            ELSE
              -- Bug 20153 - APD - 15/11/2011 - se informa el parametro pfecha con el valor
              -- de la variable reg2.fefecto
              --BUG20342 - JTS - 02/12/2011
              SELECT sproduc, fefecto
                INTO v_sproduc, v_fefectopol
                FROM seguros
               WHERE sseguro = reg2.sseguro;

              IF nvl(pac_parametros.f_parproducto_t(v_sproduc,
                                                    'FVIG_COMISION'),
                     'FEFECTO_REC') = 'FEFECTO_REC' THEN
                v_fefectovig := reg2.fefecto; --Efecto del recibo
              ELSIF pac_parametros.f_parproducto_t(v_sproduc,
                                                   'FVIG_COMISION') =
                    'FEFECTO_POL' THEN
                --Efecto de la póliza
                BEGIN
                  SELECT to_date(crespue, 'YYYYMMDD')
                    INTO v_fefectovig
                    FROM pregunpolseg
                   WHERE sseguro = reg2.sseguro
                     AND nmovimi =
                         (SELECT MAX(p.nmovimi)
                            FROM pregunpolseg p
                           WHERE p.sseguro = reg2.sseguro)
                     AND cpregun = 4046;
                EXCEPTION
                  WHEN no_data_found THEN
                    v_fefectovig := v_fefectopol;
                END;
              ELSIF pac_parametros.f_parproducto_t(v_sproduc,
                                                   'FVIG_COMISION') =
                    'FEFECTO_RENOVA' THEN
                -- efecto a la renovacion
                v_fefectovig := to_date(frenovacion(NULL, reg2.sseguro, 2),
                                        'yyyymmdd');
              END IF;

              -- Bug 21303 - APD - 15/02/2012 - se añade nanuali
              v_error := f_pcomisi(reg2.sseguro, reg2.cmodcon, reg2.fefecto,
                                   v_pcomisi, v_pretenc, NULL, NULL, NULL,
                                   NULL, NULL, NULL, NULL, NULL, 'CAR',
                                   v_fefectovig, reg2.nanuali);
              --FIBUG20342
              -- fin Bug 20153 - APD - 15/11/2011
            END IF;
            -- fin Bug 0023351 - ECP- 14/08/2012
          END IF;
          -- fin Bug 21382 - APD - 17/02/2012
        END IF;

        -- BUG19069:DRA:25/10/2011:Fi
        IF nvl(v_error, 1) <> 0 THEN
          v_pcomisi := 0;
          v_pretenc := 0;
        END IF;

        BEGIN
          SELECT npoliza || '-' || ncertif,
                 f_nombre(t.sperson, 1, s.cagente)
            INTO v_polcert, v_tomador
            FROM tomadores t, seguros s
           WHERE t.nordtom = (SELECT MIN(t2.nordtom)
                                FROM tomadores t2
                               WHERE t2.sseguro = t.sseguro)
             AND t.sseguro = s.sseguro
             AND s.sseguro = reg2.sseguro;
        EXCEPTION
          WHEN OTHERS THEN
            v_polcert := NULL;
            v_tomador := NULL;
        END;

        -- fin Bug 0019217 - JMF - 05/08/2011

        -- Bug 0019217 - JMF - 05/08/2011: Afegir camps
        -- Ini Bug 22205 - MDS - 19/05/2012
        IF nvl(pac_parametros.f_parempresa_n(p_cempres, 'VISUAL_RETENC'), 0) = 1 THEN
          v_dato_ireten := v_ireten || ';';
        ELSE
          v_dato_ireten := NULL;
        END IF;

        v_traza := 121;

        -- Bug 25988/145805 - 06/06/2013 - AMC
        IF nvl(pac_parametros.f_parempresa_n(p_cempres,
                                             'SOBRECOMISION_EMISIO'), 0) = 1 THEN
          v_dato_comi   := reg2.iconvoleducto || ';';
          v_porcen_comi := nvl(reg2.iconvoleducto, 0) * 100;
        ELSE
          v_dato_comi := NULL;
        END IF;

        -- Fi Bug 25988/145805 - 06/06/2013 - AMC
        v_traza := 122;

        -- Bug 27141/146032 - 06/06/2013 - AMC
        IF nvl(pac_parametros.f_parempresa_n(p_cempres, 'MOSTRAR_COMPANIA'),
               0) = 1 THEN
          v_dato_compa := ff_descompania(pac_cuadre_adm.f_es_vida(reg2.sseguro));

          BEGIN
            SELECT sproduc
              INTO v_dato_sproduc
              FROM seguros s
             WHERE s.sseguro = reg2.sseguro;
          EXCEPTION
            WHEN OTHERS THEN
              v_dato_sproduc := NULL;
          END;

          IF v_dato_sproduc IS NOT NULL THEN
            v_error := f_dessproduc(v_dato_sproduc, 2, p_cidioma, t_sproduc);
          END IF;
        ELSE
          v_dato_compa := NULL;
          t_sproduc    := NULL;
        END IF;

        -- Fi Bug 27141/146032 - 06/06/2013 - AMC
        -- Fin Bug 22205 - MDS - 19/05/2012

        -- BUG 22255/130296 - LECG: 26/11/2012
        BEGIN
          -- BUG 25924/0138528 - JLTS - 20/02/2013 - Se cambia SELECT NVL(iconcep, 0) y se agrupa por nrecibo
          SELECT SUM(nvl(iconcep_monpol, iconcep))
            INTO v_iconcep
            FROM detrecibos
           WHERE nrecibo = reg2.nrecibo
             AND cconcep IN (8, 58) --Bug 27311  07/08/2013 MCA Sumamos los conceptos de R.fraccionamiento y R.Frac.Cedido
           GROUP BY nrecibo;
        EXCEPTION
          WHEN OTHERS THEN
            v_iconcep := 0;
        END;

        IF nvl(pac_parametros.f_parempresa_n(p_cempres, 'CONCEP_COMISION'),
               0) = 1 THEN
          -- 16.0  - 0028370: LCOL_A003-Error porcentaje de comisiones en el listado de liquidación - QT-9420 - Inicio
          -- v_prima := reg2.iprinet + v_iconcep;
          v_prima := reg2.iprinet + (v_iconcep * sign(reg2.iprinet));
          -- 16.0  - 0028370: LCOL_A003-Error porcentaje de comisiones en el listado de liquidación - QT-9420 - Final
        ELSE
          v_prima := reg2.iprinet;
        END IF;

        IF v_corretage = 1 THEN
          -- JLV El movimiento no ha de ser el del recibo, sino el de la póliza.
          BEGIN
            SELECT MAX(nmovimi)
              INTO v_movimi
              FROM movseguro
             WHERE sseguro = reg2.sseguro;
          EXCEPTION
            WHEN OTHERS THEN
              v_movimi := NULL;
          END;

          v_primaaux := pac_corretaje.f_impcor_agente(v_prima, reg.cagente,
                                                      reg2.sseguro,
                                                      nvl(v_movimi,
                                                           reg2.nmovimi));
          v_traza    := 200;

          --JLV  29363/162581. Ojo, si ha habido un cambio de agente de corretaje, el movimiento ha de ser el recibo.
          IF v_primaaux IS NULL THEN
            v_prima := pac_corretaje.f_impcor_agente(v_prima, reg.cagente,
                                                     reg2.sseguro,
                                                     reg2.nmovimi);
          ELSE
            v_prima := v_primaaux;
          END IF;

          --JLV 14/05/2013 si hay corretaje, calcular directamente el % de comisión a mostrar
          BEGIN
            v_pcomisi := abs(trunc(nvl(reg2.icomliq, 0) * 100 /
                                   nvl(v_prima, 1), 2));
          EXCEPTION
            WHEN OTHERS THEN
              v_pcomisi := 0;
          END;
        END IF;

        IF v_dato_comi IS NOT NULL THEN
          IF v_prima IS NULL OR v_prima = 0 THEN
            --v_prima := 1; --JLV 17/07/2014 bug 32231, si se juega con la prima, en los recibos de ahorro muestra un 1 en prima en vez de un 0.
            v_dividopor := 1;
          ELSE
            IF v_corretage = 1 THEN
              SELECT ppartici / 100
                INTO vparti
                FROM age_corretaje
               WHERE sseguro = (SELECT sseguro
                                  FROM recibos
                                 WHERE nrecibo = reg2.nrecibo)
                 AND islider = 1
                 AND nmovimi =
                     (SELECT MAX(nmovimi)
                        FROM age_corretaje
                       WHERE sseguro =
                             (SELECT sseguro
                                FROM recibos
                               WHERE nrecibo = reg2.nrecibo));

              v_dividopor := v_prima * vparti;
            ELSE
              v_dividopor := v_prima;
            END IF;
          END IF;

          v_porcen_comi := abs(trunc(v_porcen_comi / v_dividopor, 2));
          v_porcen_dato := ltrim(to_char(v_porcen_comi, '990d90')) || ';';
        ELSE
          v_porcen_dato := NULL;
        END IF;

        --INI BUG 1890 AP 14/03/2018
        IF pac_corretaje.f_tiene_corretaje(reg2.sseguro, null) = 0 then
              comi_negocio := reg2.icomliq;
              v_pcomisi_age := v_pcomisi;
            ELSIF pac_corretaje.f_tiene_corretaje(reg2.sseguro, null) = 1 then
              v_pcomisi_age := reg2.ppartici;
              comi_negocio := nvl((reg2.iprinet * v_pcomisi / 100),0);
	  END IF;
	  --FIN BUG 1890 AP 14/03/2018
        v_traza := 123;
        utl_file.put_line(fitx,
                          ';' || reg2.nrecibo || ';' ||
                           to_char(reg2.fefecto, 'DD/MM/YYYY') || ';' ||
                           reg2.icomliq || ';' ||
                           ltrim(to_char(v_pcomisi_age, '990d90')) || ';' ||
                           reg2.itotalr || ';' || nvl(reg2.iprinet, 0) || ';' -- Bug 22255 - LECG - 29/11/2012
                          -- Ini Bug 22205 - MDS - 19/05/2012
                           || v_dato_ireten -- RETENCIÓN
                          -- Fin Bug 22205 - MDS - 19/05/2012
                           || v_dato_comi -- Bug 25988/145805 - 06/06/2013 - AMC
                           || comi_negocio || ';' || v_pcomisi
                           || ';' || v_porcen_dato || v_polcert || ';' || v_tomador || ';' ||
                           v_dato_compa || ';' || t_sproduc
                           -- Bug 27141/146032 - 06/06/2013 - AMC
                          );
      --  v_ttotr := v_ttotr + reg2.itotalr;
        v_tppar := v_tppar;
     --   v_tipri := v_tipri + v_prima;
        -- v_tipri := v_tipri + reg2.iprinet + v_recargo; --- LECG Le sumamos al total de la prima el valor del recargo
        v_ticom   := v_ticom + reg2.icomliq;
        v_tscom   := v_tscom;
        v_tireten := v_tireten + v_ireten; --Bug 18843/91812-06/09/2011-AMC
        v_triva   := v_triva + v_riva;
        v_trfue   := v_trfue + v_iretefuent;
        v_trica   := v_trica + v_iretica;
        --Bug 28403 Bug convenio Oleoducto
        v_ticomoleoduc := v_ticomoleoduc + nvl(reg2.iconvoleducto, 0);
      END LOOP;

      -- Bug 21377 - APD - 16/02/2012 - solo se muestra el total de los importes
      -- de los recibos si hay
      IF nvl(v_info, 0) = 1 THEN
        -- Ini Bug 22205 - MDS - 19/05/2012
        IF nvl(pac_parametros.f_parempresa_n(p_cempres, 'VISUAL_RETENC'), 0) = 1 THEN
          v_total_ireten := ';' || v_tireten;
        ELSE
          v_total_ireten := NULL;
        END IF;

        -- Bug 28403 MCA total de convenio oleoducto
        IF nvl(pac_parametros.f_parempresa_n(p_cempres,
                                             'SOBRECOMISION_EMISIO'), 0) = 1 THEN
          v_total_oleoduc := ';;' || v_ticomoleoduc;
        ELSE
          v_total_oleoduc := NULL;
        END IF;

        -- Fin Bug 22205 - MDS - 19/05/2012
       --INI BUG 1890 AP 14/03/2018
       utl_file.put_line(fitx, '');
       utl_file.put_line(fitx, upper(';' ||
                                   f_axis_literales(89906171, p_cidioma) || ';' ||  ';' || v_ticom));
       utl_file.put_line(fitx, '');
       --FIN BUG 1890 AP 14/03/2018

             /*              ';' || ';' || ';' || v_ttotr || ';' || v_tipri || ';' ||
                           v_ticom || v_total_oleoduc --Bug 28403  MCA  Sumar oleoducto
                          -- Ini Bug 22205 - MDS - 19/05/2012
                           || v_total_ireten
                           -- RETENCIÓN
                          -- Fin Bug 22205 - MDS - 19/05/2012
                          );
        utl_file.put_line(fitx, ''); */
      END IF;

      -- fin Bug 21377 - APD - 16/02/2012
      FOR reg3 IN c_liquid(reg.cagente, reg.fliquid) LOOP
        IF nvl(v_info2, 0) = 0 THEN
          v_traza := 13;
          v_trecs := v_ticom + v_tscom + v_tireten - v_triva - v_trfue -
                     v_trica; --Bug 18843/91812-06/09/2011-AMC
          utl_file.put_line(fitx,
                            upper(';' ||
                                   f_axis_literales(100896, p_cidioma) || ';' --Descripción Concepto
                                   --|| f_axis_literales(9000715, p_cidioma) --Concepto Liquidación BUG 1896 AP 23/04/2018
                                   ||-- ' ' || BUG 1896 AP 23/04/2018
                                   --f_axis_literales(9901183, p_cidioma) || ';' || BUG 1896 AP 23/04/2018
                                   f_axis_literales(9001195, p_cidioma) || ';' || ';' --Tipo Apunte
                                   || f_axis_literales(100563, p_cidioma))); --Importe
          v_traza := 14;
          v_toti  := 0;
          v_info2 := 1;
        END IF;

        utl_file.put_line(fitx,
                          ';' || reg3.tcconcta || ';' || --reg3.tdescrip || ';' || BUG 1896 AP 23/04/2018
                           reg3.tipolin || ';' || ';' || reg3.iimport);
        v_toti := v_toti + reg3.iimport;
      END LOOP;

      IF nvl(v_info, 0) = 1 OR nvl(v_info2, 0) = 1 THEN
        v_traza := 15;
        v_tman  := v_toti + v_tireten - v_triva - v_trfue - v_trica; --Bug 18843/91812-06/09/2011-AMC

       /* IF nvl(v_info2, 0) = 1 THEN
          utl_file.put_line(fitx, ';' || ';' || ';' || ';' || ';' || v_toti);
        END IF; */

        v_total := v_trecs + v_tman;

        --Bug 26957-XVM-21/06/2013. Pasamos v_total_ireten a number quitandole ; si lo tiene.
        IF nvl(pac_parametros.f_parempresa_n(p_cempres, 'VISUAL_RETENC'), 0) = 1 THEN
          SELECT to_number(decode(instr(v_total_ireten, ';'), 1,
                                   substr(v_total_ireten, 2), v_total_ireten))
            INTO vx_total_ireten
            FROM dual;

          v_totage := (v_ticom - nvl(vx_total_ireten, 0)) + v_toti +
                      v_ticomoleoduc; --Bug 28403  se añade la sobrecomisión oleoducto
        ELSE
          v_totage := v_ticom + v_toti + v_ticomoleoduc; --Bug 28403  se añade la sobrecomisión oleoducto
        END IF;

        utl_file.put_line(fitx, '');
        utl_file.put_line(fitx,
                           ';' || ';' || ';' || -- BUG 1896 AP 23/04/2018
                           f_axis_literales(1000529, p_cidioma) || ': ' || ';' ||
                           v_totage);
        utl_file.put_line(fitx, '');
      END IF;

      v_info          := 0;
      v_info2         := 0;
      v_ttotr         := 0;
      v_tppar         := 0;
      v_tipri         := 0;
      v_ticom         := 0;
      v_tscom         := 0;
      v_tireten       := 0; --Bug 18843/91812-06/09/2011-AMC
      v_total_ireten  := 0; -- Bug 39738 - 08/01/2016 AFM
      vx_total_ireten := 0; -- Bug 39738 - 08/01/2016 AFM
      v_triva         := 0;
      v_trfue         := 0;
      v_trica         := 0;
      v_tman          := 0;
      v_total         := 0;
      v_totage        := 0;
      v_toti          := 0; -- Bug 22065 - APD - 23/04/2012 - se inicializa la variable
      v_ticomoleoduc  := 0; --Bug 28403  se inicializa variable
    END LOOP;

    v_traza := 16;
    utl_file.fclose(fitx);
    RETURN 0;
  EXCEPTION
    WHEN OTHERS THEN
      p_tab_error(f_sysdate, f_user, 'pac_genfich.f_llistat_comissions',
                  v_traza, v_params, SQLERRM);

      IF utl_file.is_open(fitx) THEN
        utl_file.fclose(fitx);
      END IF;

      RETURN 1;
  END f_llistat_comissions;

  /*************************************************************************
     FUNCTION f_llistat_impostos
     return               : 0 OK - 1 KO
  *************************************************************************/
  FUNCTION f_llistat_impostos(p_cempres IN NUMBER, p_periodo IN DATE,
                              p_rutafich OUT VARCHAR2) RETURN NUMBER IS
    fitx      utl_file.file_type;
    v_error   NUMBER;
    v_traza   NUMBER := 1;
    v_params  VARCHAR2(500) := 'p_cempres: ' || p_cempres ||
                               ' - p_periodo: ' || p_periodo;
    v_sseguro NUMBER;
    v_origen  VARCHAR2(20);
    p_sperson NUMBER;

    CURSOR periodo IS
      SELECT DISTINCT (sperson)
        FROM (SELECT DISTINCT (p.sperson)
                 FROM seguros s, tomadores t, personas_detalles p,
                      per_direcciones d, recibos rec, vdetrecibos v
                WHERE s.cempres = p_cempres
                  AND t.sseguro = s.sseguro
                  AND t.sperson = p.sperson
                  AND rec.sseguro = s.sseguro
                  AND rec.cagente = s.cagente
                  AND s.cagente = p.cagente
                  AND d.sperson = p.sperson
                  AND d.cdomici = t.cdomici
                  AND v.nrecibo = rec.nrecibo
                  AND (SELECT COUNT(1)
                         FROM detrecibos
                        WHERE cconcep = 41
                          AND nrecibo = rec.nrecibo) <> 0
                     --AND p.sperson = p_sperson
                  AND to_char(rec.femisio, 'mmrrrr') =
                      to_char(p_periodo, 'mmrrrr')
               UNION ALL
               SELECT DISTINCT (a.sperson)
                 FROM ctactes c, agentes a
                WHERE a.cagente = c.cagente
                     --AND a.sperson = p_sperson
                  AND c.cempres = p_cempres
                  AND c.cconcta IN (53, 54, 55, 56)
                  AND to_char(c.ffecmov, 'mmrrrr') =
                      to_char(p_periodo, 'mmrrrr')
               UNION ALL
               SELECT DISTINCT (sd.sperson)
                 FROM seguros s, sin_tramita_pago st,
                      sin_tramita_destinatario sd, sin_siniestro ss
                WHERE sd.nsinies = st.nsinies
                     --AND sd.sperson = p_sperson
                  AND st.nsinies = ss.nsinies
                  AND st.sperson = sd.sperson
                  AND ss.sseguro = s.sseguro
                  AND (nvl(st.iiva, 0) <> 0 OR nvl(st.ireteica, 0) <> 0 OR
                      nvl(st.ireteiva, 0) <> 0 OR nvl(st.iretenc, 0) <> 0)
                  AND to_char(st.fordpag, 'mmrrrr') =
                      to_char(p_periodo, 'mmrrrr'));

    CURSOR persona IS
      SELECT decode(p.ctipper, 1, 'N', 'J') tipoper, p.ctipide tipodoc,
             p.nnumide numdoc, p.tdigitoide digcheq,
             decode(p.ctipper, 1,
                     p.tnombre1 || ',' || p.tnombre2 || ',' || p.tapelli1 || ',' ||
                      p.tapelli2, p.tnombre1) nombre, d.tdomici direccion,
             d.cpoblac depto, d.cprovin ciudad, per.nvalpar activeco
        FROM personas_detalles p, per_direcciones d, per_parpersonas per
       WHERE d.sperson(+) = p.sperson
         AND per.sperson(+) = p.sperson
         AND per.cparam(+) = 'CCIIU'
         AND p.sperson = p_sperson;

    CURSOR impuestos IS
      SELECT decode(pac_cuadre_adm.f_es_vida(s.sseguro), 1, 2, 1) compania,
             pac_redcomercial.f_busca_padre(s.cempres, s.cagente, 2,
                                             s.fefecto) sucursal,
             to_char(rec.femisio, 'mm-rrrr') periodo, v.itotpri valor_base,
             (SELECT SUM(iconcep)
                 FROM detrecibos d, recibos r, seguros sg
                WHERE sg.sseguro = r.sseguro
                  AND sg.cempres = s.cempres
                  AND sg.sseguro = s.sseguro
                  AND d.nrecibo = r.nrecibo
                  AND d.cconcep = 41) valor_impuesto, '253500' cuenta_gasto,
             '01' auxiliar_gasto, 'Producción' origen, s.sseguro
        FROM seguros s, tomadores t, personas_detalles p, per_direcciones d,
             recibos rec, vdetrecibos v
       WHERE s.cempres = p_cempres
         AND t.sseguro = s.sseguro
         AND t.sperson = p.sperson
         AND rec.sseguro = s.sseguro
         AND rec.cagente = s.cagente
         AND s.cagente = p.cagente
         AND d.sperson = p.sperson
         AND d.cdomici = t.cdomici
         AND v.nrecibo = rec.nrecibo
         AND (SELECT COUNT(1)
                FROM detrecibos
               WHERE cconcep = 41
                 AND nrecibo = rec.nrecibo) <> 0
         AND p.sperson = p_sperson
         AND to_char(rec.femisio, 'mmrrrr') = to_char(p_periodo, 'mmrrrr')
      UNION ALL
      SELECT decode(pac_cuadre_adm.f_es_vida(c.sseguro), 1, 2, 1) compania,
             pac_redcomercial.f_busca_padre(c.cempres, c.cagente, 2,
                                             c.fvalor) sucursal,
             to_char(c.ffecmov, 'mm-rrrr') periodo,
             (SELECT SUM(iimport)
                 FROM ctactes
                WHERE cagente = c.cagente
                  AND nnumlin = c.nnumlin_depen) valor_base,
             (SELECT SUM(iimport)
                 FROM ctactes
                WHERE cconcta IN (53, 54, 55, 56)
                  AND cagente = c.cagente) valor_impuesto,
             '288105' cuenta_gasto, '07' auxiliar_gasto, 'Comisiones' origen,
             c.sproces sseguro
        FROM ctactes c, agentes a
       WHERE a.cagente = c.cagente
         AND a.sperson = p_sperson
         AND c.cempres = p_cempres
         AND c.cconcta IN (53, 54, 55, 56)
         AND to_char(c.ffecmov, 'mmrrrr') = to_char(p_periodo, 'mmrrrr')
       GROUP BY decode(pac_cuadre_adm.f_es_vida(c.sseguro), 1, 2, 1),
                c.cempres, c.cagente, c.fvalor,
                to_char(c.ffecmov, 'mm-rrrr'), c.sproces, c.cagente,
                c.nnumlin_depen
      UNION ALL
      SELECT decode(pac_cuadre_adm.f_es_vida(s.sseguro), 1, 2, 1) compania,
             pac_redcomercial.f_busca_padre(s.cempres, s.cagente, 2,
                                             s.fefecto) sucursal,

             --pac_agentes.f_get_cageliq(s.cempres, 2, s.cagente) sucursal,
             to_char(st.fordpag, 'mm-rrrr') periodo, st.isinret valor_base,
             nvl(st.iiva, 0) + nvl(st.ireteiva, 0) + nvl(st.ireteica, 0) +
              nvl(st.iretenc, 0) valor_impuesto,
             to_char(vi.cuenta) cuenta_gasto,
             to_char(vi.subcuenta) auxiliar_gasto, 'Siniestros' origen,
             s.sseguro
        FROM seguros s, sin_tramita_pago st, sin_tramita_destinatario sd,
             sin_siniestro ss, vista_interf_cuentas vi
       WHERE sd.nsinies = st.nsinies
         AND sd.sperson = p_sperson
         AND sd.sperson = st.sperson
         AND vi.sidepag = st.sidepag
         AND st.nsinies = ss.nsinies
         AND ss.sseguro = s.sseguro
         AND (nvl(st.iiva, 0) <> 0 OR nvl(st.ireteica, 0) <> 0 OR
             nvl(st.ireteiva, 0) <> 0 OR nvl(st.iretenc, 0) <> 0)
         AND to_char(st.fordpag, 'mmrrrr') = to_char(p_periodo, 'mmrrrr');

    CURSOR detalles IS
      SELECT 'PR' conpago, 'RIC' impuesto, 'PORCIMPU' porcimpu,
             SUM(d.iconcep) valor_impu, '253500' cuenta_gasto,
             '01' auxiliar_gasto
        FROM detrecibos d, recibos r, seguros s
       WHERE s.sseguro = r.sseguro
         AND s.cempres = p_cempres
         AND s.sseguro = v_sseguro
         AND d.nrecibo = r.nrecibo
         AND d.cconcep = 41
         AND v_origen = 'Producción'
       GROUP BY d.iconcep
      UNION ALL
      SELECT 'CO' conpago,
             decode(cconcta, 53, 'IVA', 54, 'RFT', 55, 'RIV', 56, 'RIC') impuesto,
             'PORCIMPU' porcimpu, SUM(iimport) valor_impu,
             decode(cconcta, 53, '253500', 54, '236005', 55, '255505', 56,
                     '251595') cuenta_gasto,
             decode(cconcta, 53, '050401', 54, '02', 55, '1704', 56, '04') auxiliar_gasto
        FROM ctactes c, agentes a
       WHERE
      --c.sproces = v_sseguro
      --AND
       a.cagente = c.cagente
       AND a.sperson = p_sperson
       AND c.cconcta IN (53, 54, 55, 56)
       AND v_origen = 'Comisiones'
       AND nvl(iimport, 0) <> 0
       GROUP BY cconcta
      UNION ALL
      SELECT 'IN' conpago, 'IVA' impuesto, 'PORCIMPU' porcimpu,
             SUM(iiva) valor_impu, '419595' cuenta_gasto,
             '12' auxiliar_gasto
        FROM seguros s, sin_tramita_pago st, sin_tramita_destinatario sd,
             sin_siniestro ss
       WHERE sd.nsinies = st.nsinies
         AND sd.sperson = p_sperson
         AND sd.sperson = st.sperson
         AND st.nsinies = ss.nsinies
         AND ss.sseguro = s.sseguro
         AND nvl(iiva, 0) <> 0
         AND v_origen = 'Siniestros'
       GROUP BY iiva
      UNION ALL
      SELECT 'IN' conpago, 'RIV' impuesto, 'PORCIMPU' porcimpu,
             SUM(ireteiva) valor_impu, '519095' cuenta_gasto,
             '4028' auxiliar_gasto
        FROM seguros s, sin_tramita_pago st, sin_tramita_destinatario sd,
             sin_siniestro ss
       WHERE sd.nsinies = st.nsinies
         AND sd.sperson = p_sperson
         AND sd.sperson = st.sperson
         AND st.nsinies = ss.nsinies
         AND ss.sseguro = s.sseguro
         AND nvl(ireteiva, 0) <> 0
         AND v_origen = 'Siniestros'
       GROUP BY ireteiva
      UNION ALL
      SELECT 'IN' conpago, 'RIC' impuesto, 'PORCIMPU' porcimpu,
             SUM(ireteica) valor_impu, '519095' cuenta_gasto,
             '4028' auxiliar_gasto
        FROM seguros s, sin_tramita_pago st, sin_tramita_destinatario sd,
             sin_siniestro ss
       WHERE sd.nsinies = st.nsinies
         AND sd.sperson = p_sperson
         AND sd.sperson = st.sperson
         AND st.nsinies = ss.nsinies
         AND ss.sseguro = s.sseguro
         AND nvl(ireteica, 0) <> 0
         AND v_origen = 'Siniestros'
       GROUP BY ireteica
      UNION ALL
      SELECT 'IN' conpago, 'RFT' impuesto, 'PORCIMPU' porcimpu,
             SUM(iretenc) valor_impu, '255505' cuenta_gasto,
             '04' auxiliar_gasto
        FROM seguros s, sin_tramita_pago st, sin_tramita_destinatario sd,
             sin_siniestro ss
       WHERE sd.nsinies = st.nsinies
         AND sd.sperson = p_sperson
         AND sd.sperson = st.sperson
         AND st.nsinies = ss.nsinies
         AND ss.sseguro = s.sseguro
         AND nvl(iretenc, 0) <> 0
         AND v_origen = 'Siniestros'
       GROUP BY iretenc;

    ttexto    VARCHAR2(100);
    v_ruta    VARCHAR2(100);
    v_tfitxer VARCHAR2(100);
    v_cad     VARCHAR2(600) := NULL;
    -- fin Bug 0019217 - JMF - 05/08/2011
  BEGIN
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(p_cempres,
                                                                        'USER_BBDD'))
      INTO v_error
      FROM dual;

    v_ruta     := f_parinstalacion_t('INFORMES'); -- Ruta donde se generan los informes.
    v_traza    := 2;
    v_tfitxer  := 'Carga_Impuestos_' || p_cempres || '_' ||
                  to_char(p_periodo, 'mm-rrrr') || '.csv';
    v_traza    := 3;
    p_rutafich := f_parinstalacion_t('INFORMES_C') || '\' || v_tfitxer;
    fitx       := utl_file.fopen(v_ruta, v_tfitxer, 'w');

    FOR period IN periodo LOOP
      p_sperson := period.sperson;

      FOR reg IN persona LOOP
        -- cabecera
        v_traza := 4;
        v_cad   := '0' || ',' || reg.tipoper || ',' || reg.tipodoc || ',' ||
                   reg.numdoc || ',' || reg.digcheq || ',' || reg.nombre || ',' ||
                   reg.direccion || ',' || reg.depto || ',' || reg.ciudad || ',' ||
                   reg.activeco;
        utl_file.put_line(fitx, v_cad);

        FOR reg1 IN impuestos LOOP
          v_traza := 5;
          v_cad   := '1' || ',' || reg.tipodoc || ',' || reg.numdoc || ',' ||
                     reg.digcheq || ',' || reg1.compania || ',' ||
                     reg1.sucursal || ',' || reg1.periodo || ',' ||
                     reg1.valor_base || ',' || reg1.valor_impuesto || ',' ||
                     reg1.cuenta_gasto || ',' || reg1.auxiliar_gasto || ',' ||
                     reg1.origen;
          utl_file.put_line(fitx, v_cad);
          v_sseguro := reg1.sseguro;
          v_origen  := reg1.origen;

          FOR reg2 IN detalles LOOP
            v_traza := 6;
            v_cad   := '2' || ',' || reg.tipodoc || ',' || reg.numdoc || ',' ||
                       reg.digcheq || ',' || reg1.compania || ',' ||
                       reg1.sucursal || ',' || reg1.periodo || ',' ||
                       reg2.conpago || ',' || reg2.impuesto || ',' ||
                       (reg2.valor_impu * 100 / reg1.valor_base) || ',' ||
                       reg1.valor_base || ',' || reg2.valor_impu || ',' ||
                       reg1.cuenta_gasto || ',' || reg1.auxiliar_gasto || ',' ||
                       reg2.cuenta_gasto || ',' || reg2.auxiliar_gasto || ',' ||
                       reg1.origen;
            utl_file.put_line(fitx, v_cad);
          END LOOP;
        END LOOP;
      END LOOP;
    END LOOP;

    v_traza := 7;
    utl_file.fclose(fitx);
    RETURN 0;
  EXCEPTION
    WHEN OTHERS THEN
      p_tab_error(f_sysdate, f_user, 'pac_genfich.f_llistat_impostos',
                  v_traza, v_params, SQLERRM);

      IF utl_file.is_open(fitx) THEN
        utl_file.fclose(fitx);
      END IF;

      RETURN 1;
  END f_llistat_impostos;
END pac_genfich;

/

  GRANT EXECUTE ON "AXIS"."PAC_GENFICH" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_GENFICH" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_GENFICH" TO "PROGRAMADORESCSI";
