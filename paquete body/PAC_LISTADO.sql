--------------------------------------------------------
--  DDL for Package Body PAC_LISTADO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_LISTADO" AS
/******************************************************************************
   NOMBRE:       pac_md_listado
   PROPÓSITO:    Contiene las funciones para el lanzamiento de listados a través de AXISCONNECT.

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        06/05/2009   JGM              1. Creación del package.
   2.0        06/05/2010   ICV              2. 0012746: APRB95 - lista de movimientos de saldo por cliente
   3.0        02/09/2019   Swapnil          3. Cambios de 4198
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
      p_codplan IN VARCHAR2,
      p_idioma IN NUMBER,
      pid OUT VARCHAR2)
      RETURN NUMBER IS
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(200)
         := 'P_cempres = ' || p_cempres || ', P_sproces = ' || p_sproces || ',p_cagente = '
            || p_cagente;
      v_error        NUMBER(8) := 0;
      v_fcierre      DATE;

      CURSOR c_pral IS
         SELECT DECODE(p_idioma, 7, '7', '6') "PAR_RTFIDIOMA", a.cagente "PAR_CAGENTE",
                p_cempres "PAR_CEMPRES", p_sproces "PAR_CPROCES",
                REPLACE(pac_gestion_rec.f_nom(a.sperson, a.cagente), ' '' ',
                        '´') "PAR_NOMBROK",
                REPLACE(d.tdomici, ' '' ', '´') "PAR_TDOMBROK", d.cpostal "PAR_POSTBROK",
                REPLACE(p.tpoblac, ' '' ', '´') "PAR_POBBROK"
           FROM agentes a,
                per_direcciones d,
                poblaciones p,
                per_detper e,
                redcomercial r,
                (SELECT cidioma, a.cagente   --into vidioma
                   FROM agentes a, per_detper p
                  WHERE a.sperson = p.sperson
                    --AND a.cagente = :agente
                    AND p.cagente = ff_agente_cpervisio(pac_md_common.f_get_cxtagente,
                                                        f_sysdate, 2)) idi
          WHERE e.sperson = a.sperson
            AND a.sperson = d.sperson
            AND p.cprovin = d.cprovin
            AND p.cpoblac = d.cpoblac
            AND d.ctipdir = (SELECT MAX(ctipdir)
                               FROM per_direcciones
                              WHERE sperson = d.sperson
                                AND ctipdir <= 2)
            AND r.cagente = a.cagente
            AND r.fmovfin IS NULL
            AND r.cempres = p_cempres
            AND idi.cagente = a.cagente
            AND e.cagente = ff_agente_cpervisio(pac_md_common.f_get_cxtagente, f_sysdate, 2)
            AND d.cagente = e.cagente
            AND((p_cagente IS NOT NULL
                 AND a.cagente = p_cagente)
                OR(p_cagente IS NULL
                   AND a.cagente IN(SELECT DISTINCT (cagente)
                                               FROM liqmovrec
                                              WHERE sproces = p_sproces)))
            AND((p_idioma = 7
                 AND NVL(idi.cidioma, f_usu_idioma) = 7)
                OR(p_idioma = 6
                   AND NVL(idi.cidioma, f_usu_idioma) <> 7)   -- los que no sean idioma 6 saldran com 6
                                                           );

----------------------------------------------------------
      CURSOR c_top(vproces NUMBER, vagente NUMBER, vidioma NUMBER) IS
         SELECT   ' ' tomador, TO_CHAR(fvalor, 'dd/mm/yyyy') fecha, co.cconcta_vis cconcta_vis,
                  d.tcconcta tcconcta, ' ' cramo, ' ' npoliza,
                  DECODE(c.cdebhab,
                         1, DECODE(SIGN(c.iimport), -1, NULL, c.iimport),
                         DECODE(SIGN(c.iimport), -1, -c.iimport, NULL)) debe,
                  DECODE(c.cdebhab,
                         2, DECODE(SIGN(c.iimport), -1, NULL, c.iimport),
                         DECODE(SIGN(c.iimport), -1, -c.iimport, NULL)) haber,
                  TO_CHAR(fvalor, 'dd') dia
             FROM ctactes c, codctactes co, desctactes d
            WHERE sproces = (SELECT MAX(sproces)
                               FROM ctactes c
                              WHERE sproces <> vproces
                                AND c.cagente = NVL(vagente, c.cagente))
              AND c.cconcta = 0
              AND c.cconcta = co.cconcta
              AND c.cconcta = d.cconcta
              AND d.cidioma = vidioma
              AND c.cagente = NVL(vagente, c.cagente)
         ORDER BY cagente, fvalor, c.cconcta;

----------------------------------------------------------
      CURSOR c_multi_up(vproces NUMBER, vagente NUMBER, vidioma NUMBER) IS
         SELECT   tomador, fecha, cconcta_vis, tcconcta, cramo, npoliza, debe, haber, dia,
                  letra_c1, letra_c2
             FROM (SELECT f_nombre(t.sperson, 1, c.cagente) tomador, c.smovrec,
                          c.nrecibo fecha, d.cconcta_vis, e.tcconcta, cramo, npoliza,
                          DECODE(c.cgescob,
                                 3, DECODE(SIGN(itotalr),
                                           -1, ' ',
                                           TO_CHAR(itotalr, 'FM9999999990D00')),
                                 DECODE(SIGN(icomisi),
                                        -1, TO_CHAR(-icomisi, 'FM9999999990D00'),
                                        ' ')) debe,
                          DECODE(c.cgescob,
                                 3, DECODE(SIGN(itotalr),
                                           -1, TO_CHAR(-itotalr, 'FM9999999990D00'),
                                           ' '),
                                 DECODE(SIGN(icomisi),
                                        -1, ' ',
                                        TO_CHAR(icomisi, 'FM9999999990D00'))) haber,
                          2 orden, TO_CHAR(fliquid, 'dd') dia,
                          DECODE(d.cconcta,
                                 99, DECODE(c.cgescob,
                                            3, DECODE(SIGN(itotalr), -1, '', 'C'),
                                            DECODE(SIGN(icomisi), -1, 'C', '')),
                                 '') letra_c1,
                          DECODE(d.cconcta,
                                 99, DECODE(c.cgescob,
                                            3, DECODE(SIGN(itotalr), -1, 'C', ''),
                                            DECODE(SIGN(icomisi), -1, '', 'C')),
                                 '') letra_c2
                     FROM liqmovrec c, recibos r, seguros s, codctactes d, desctactes e,
                          tomadores t
                    WHERE r.nrecibo = c.nrecibo
                      AND r.sseguro = s.sseguro
                      AND t.sseguro = s.sseguro
                      AND c.sproces = vproces
                      AND c.cagente = NVL(vagente, c.cagente)
                      AND e.cconcta = d.cconcta
                      AND d.cconcta = DECODE(c.cgescob, 3, 12, 99)
                      AND e.cidioma = vidioma
                   UNION ALL
                   SELECT f_nombre(t.sperson, 1, c.cagente) tomador, c.smovrec,
                          c.nrecibo fecha, d.cconcta_vis, e.tcconcta, cramo, npoliza,
                          DECODE(SIGN(icomisi),
                                 -1, TO_CHAR(-icomisi, 'FM9999999990D00'),
                                 ' ') debe,
                          DECODE(SIGN(icomisi),
                                 -1, ' ',
                                 TO_CHAR(icomisi, 'FM9999999990D00')) haber,
                          1 orden, TO_CHAR(fliquid, 'dd') dia, '' letra_c1, '' letra_c2
                     FROM liqmovrec c, recibos r, seguros s, codctactes d, desctactes e,
                          tomadores t
                    WHERE r.nrecibo = c.nrecibo
                      AND r.sseguro = s.sseguro
                      AND t.sseguro = s.sseguro
                      AND c.sproces = vproces
                      AND c.cagente = NVL(vagente, c.cagente)
                      AND c.cgescob = 3
                      AND d.cconcta = 12
                      AND e.cconcta = d.cconcta
                      AND e.cidioma = vidioma)
         ORDER BY smovrec ASC, orden;

----------------------------------------------------------
      CURSOR c_multi_down(vproces NUMBER, vagente NUMBER, vidioma NUMBER) IS
         SELECT   c.cagente,
                  DECODE(s.sseguro, NULL, '', f_nombre(s.sseguro, 1, c.cagente)) tomador,
                  TO_CHAR(fvalor, 'dd/mm/yyyy') fecha, cconcta_vis, tcconcta, cramo, npoliza,
                  DECODE(c.cdebhab,
                         1, DECODE(SIGN(c.iimport),
                                   -1, NULL,
                                   TO_CHAR(c.iimport, 'FM9999999990D00')),
                         DECODE(SIGN(c.iimport),
                                -1, TO_CHAR(-c.iimport, 'FM9999999990D00'),
                                NULL)) debe,
                  DECODE(c.cdebhab,
                         2, DECODE(SIGN(c.iimport),
                                   -1, NULL,
                                   TO_CHAR(c.iimport, 'FM9999999990D00')),
                         DECODE(SIGN(c.iimport),
                                -1, TO_CHAR(-c.iimport, 'FM9999999990D00'),
                                NULL)) haber,
                  TO_CHAR(c.fvalor, 'dd') dia
             FROM seguros s, ctactes c, codctactes co, desctactes d
            WHERE c.sproces = vproces
              AND c.cagente = NVL(vagente, c.cagente)
              AND c.cconcta = co.cconcta
              AND c.sseguro = s.sseguro(+)
              AND c.cconcta NOT IN(0, 99, 98)
              AND c.cconcta = d.cconcta
              AND d.cidioma = vidioma
         ORDER BY c.cagente, ffecmov, c.cconcta;

----------------------------------------------------------
      CURSOR c_bottom(vproces NUMBER, vagente NUMBER, vidioma NUMBER) IS
         SELECT   ' ' tomador, TO_CHAR(c.fvalor, 'dd/mm/yyyy') fecha, c.cconcta cconcta_vis,
                  tdescrip tcconcta, ' ' cramo, ' ' npoliza,
                  DECODE(c.cdebhab,
                         1, DECODE(SIGN(c.iimport), -1, NULL, c.iimport),
                         DECODE(SIGN(c.iimport), -1, -c.iimport, NULL)) debe,
                  DECODE(c.cdebhab,
                         2, DECODE(SIGN(c.iimport), -1, NULL, c.iimport),
                         DECODE(SIGN(c.iimport), -1, -c.iimport, NULL)) haber,
                  TO_CHAR(fvalor, 'dd') dia
             FROM ctactes c
            WHERE c.sproces = vproces
              AND c.cagente = NVL(vagente, c.cagente)
              AND c.cconcta = 0
         ORDER BY cagente, ffecmov, cconcta;

      CURSOR c_apra010(vproces NUMBER, vagente NUMBER, vcempres NUMBER) IS
         SELECT   s.npoliza, v.nrecibo, f_nombre(t.sperson, 1, s.cagente) tomador, r.fvencim,
                  v.itotalr,(NVL(v.icombru, 0) + NVL(v.icombrui, 0)) comision
             FROM vdetrecibos v, movrecibo m, recibos r, seguros s, cierres c, tomadores t
            WHERE s.sseguro = r.sseguro
              AND c.sproces = vproces
              AND c.ctipo = 17
              AND v.nrecibo = r.nrecibo
              AND t.sseguro = s.sseguro
              AND m.nrecibo = r.nrecibo
              AND m.smovrec = (SELECT MAX(smovrec)
                                 FROM movrecibo m2
                                WHERE m2.nrecibo = r.nrecibo)
              AND m.cestrec = 0   -- situació del rebut a pdte
              AND NVL(cestaux, 0) IN(0, 2)   -- que estigui en vigor (sino f_situarec <> 0)
              AND TRUNC(fperfin) >=
                               fmovini   -- f_situarec = 0 a data fperfin (data final de la liqui)
              AND(TRUNC(fperfin) < fmovfin
                  OR fmovfin IS NULL)   -- f_situarec = 0 a data fperfin (data final de la liqui)
              AND r.fefecto <= fperfin   -- i  data efecte del rebut no sigui posterior a la liqui
              AND s.cagente = NVL(vagente, s.cagente)
              AND s.cempres = vcempres
         ORDER BY s.npoliza, v.nrecibo;

----------------------------------------------------------
      v_id           VARCHAR2(30);
      vcontador      NUMBER(5) := 1;
      v_sum1         NUMBER(15, 3);
      v_sum2         NUMBER(15, 3);
      v_sum3         VARCHAR2(30);
      v_sum4         VARCHAR2(30);
      v_sum5         NUMBER(15, 3);
      v_sum6         VARCHAR2(30);
   BEGIN
      -- borramos registros con idem PROCESO
      DELETE      int_report_data
            WHERE ID = p_sproces;

      -- calculamos la fecha de cierre;
      SELECT MAX(fcierre)
        INTO v_fcierre
        FROM cierres
       WHERE sproces = p_sproces;

      --identificamos al listado con nomplant_proces_fecha
      v_id := p_codplan || '_' || p_sproces || '_' || TO_CHAR(f_sysdate, 'ddmmyyyy_HH24mmss');
      v_pasexec := 1;

      FOR pral IN c_pral LOOP
------------------------------------------
         IF p_codplan = 'APRA012' THEN
            DECLARE
            -- Sumatoris finals els poso des del principi.
            BEGIN
               --> v_sum1/v_sum2 --(TODO EL DEBE - TODO EL CRE) si positivo sum1 sino sum2 (cambiado de signo)
               SELECT SUM(debe), SUM(haber)
                 INTO v_sum1, v_sum2
                 FROM (SELECT   --top
                              NVL(SUM(DECODE(c.cdebhab, 1, NVL(c.iimport, 0), 0)), 0) debe,
                              NVL(SUM(DECODE(c.cdebhab, 2, NVL(c.iimport, 0), 0)), 0) haber
                         FROM ctactes c
                        WHERE sproces = (SELECT MAX(sproces)
                                           FROM ctactes c
                                          WHERE sproces <> p_sproces
                                            AND c.cagente = NVL(pral.par_cagente, c.cagente))
                          AND c.cconcta = 0
                          AND c.cagente = NVL(pral.par_cagente, c.cagente)
                       UNION ALL   -- bottom + multidown
                       SELECT NVL(SUM(DECODE(c.cdebhab, 1, NVL(c.iimport, 0), 0)), 0) debe,
                              NVL(SUM(DECODE(c.cdebhab, 2, NVL(c.iimport, 0), 0)), 0) haber
                         FROM ctactes c
                        WHERE c.sproces = p_sproces
                          AND c.cagente = NVL(pral.par_cagente, c.cagente)
                          AND c.cconcta NOT IN(0, 99, 98)
                       UNION ALL   --multiup
                       SELECT SUM(debe), SUM(haber)
                         FROM (SELECT SUM(DECODE(c.cgescob, 3, NVL(itotalr, 0), 0)) debe,
                                      SUM(DECODE(c.cgescob, 3, 0, NVL(icomisi, 0))) haber
                                 FROM liqmovrec c, codctactes d
                                WHERE c.sproces = p_sproces
                                  AND c.cagente = NVL(pral.par_cagente, c.cagente)
                                  AND d.cconcta = DECODE(c.cgescob, 3, 12, 99)
                               UNION ALL
                               SELECT 0 debe, SUM(NVL(icomisi, 0)) haber
                                 FROM liqmovrec c
                                WHERE c.sproces = p_sproces
                                  AND c.cagente = NVL(pral.par_cagente, c.cagente)
                                  AND c.cgescob = 3));

               IF v_sum1 - v_sum2 >= 0 THEN
                  v_sum1 := v_sum1 - v_sum2;
                  v_sum2 := NULL;
               ELSE
                  v_sum2 := -1 *(v_sum1 - v_sum2);
                  v_sum1 := NULL;
               END IF;

               /*SELECT SUM(NVL(icomisi, 0))
                 INTO v_sum1 --TODO EL DEBE - TODO EL CRE
                 FROM liqmovrec c, recibos r, seguros s
                WHERE r.nrecibo = c.nrecibo
                  AND r.sseguro = s.sseguro
                  AND c.sproces = p_sproces
                  AND c.cagente = NVL(pral.par_cagente, c.cagente)
                  AND NVL(icomisi, 0) < 0;

               v_pasexec := 6;

               SELECT SUM(NVL(icomisi, 0))
                 INTO v_sum2
                 FROM liqmovrec c, recibos r, seguros s
                WHERE r.nrecibo = c.nrecibo
                  AND r.sseguro = s.sseguro
                  AND c.sproces = p_sproces
                  AND c.cagente = NVL(pral.par_cagente, c.cagente)
                  AND NVL(icomisi, 0) >= 0;*/
               v_pasexec := 7;

               SELECT TO_CHAR(NVL(SUM(NVL(itotalr, 0)), 0), 'FM9999999990D00') cuatro,
                      TO_CHAR(NVL(SUM(NVL(icomisi, 0)), 0), 'FM9999999990D00') seis,
                      MAX(DECODE(a.cbancar, NULL, p.cbancar, a.cbancar)) tres
                 INTO v_sum4,
                      v_sum6,
                      v_sum3
                 FROM liqmovrec c, agentes a, per_ccc p
                WHERE fliquid BETWEEN TO_DATE('01/01/'
                                              || (SELECT TO_CHAR(MAX(fliquid), 'yyyy') anyo
                                                    FROM liqmovrec
                                                   WHERE sproces = p_sproces),
                                              'DD/MM/YYYY')
                                  AND TO_DATE('31/12/'
                                              || (SELECT TO_CHAR(MAX(fliquid), 'yyyy') anyo
                                                    FROM liqmovrec
                                                   WHERE sproces = p_sproces),
                                              'DD/MM/YYYY')
                  AND a.cagente = c.cagente
                  AND a.sperson = p.sperson(+)
                  AND c.cagente = NVL(pral.par_cagente, c.cagente);

               v_pasexec := 8;

               SELECT NVL(SUM(NVL(icomisi, 0)), 0)
                 INTO v_sum5
                 FROM liqmovrec c, recibos r, seguros s
                WHERE r.nrecibo = c.nrecibo
                  AND r.sseguro = s.sseguro
                  AND c.sproces = p_sproces
                  AND c.cagente = NVL(pral.par_cagente, c.cagente);

               v_pasexec := 9;
               v_pasexec := 10;
            EXCEPTION
               WHEN OTHERS THEN
                  ROLLBACK;
                  RETURN 1;
            END;
         ELSIF p_codplan = 'APRA010' THEN
            DECLARE
            -- Sumatoris finals els poso des del principi.
            BEGIN
               SELECT NVL(SUM(NVL(v.icombru, 0) + NVL(v.icombrui, 0)), 0)
                 INTO v_sum1
                 FROM vdetrecibos v, movrecibo m, recibos r, seguros s, cierres c
                WHERE s.sseguro = r.sseguro
                  AND c.sproces = p_sproces
                  AND c.ctipo = 17
                  AND v.nrecibo = r.nrecibo
                  AND m.nrecibo = r.nrecibo
                  AND m.smovrec = (SELECT MAX(smovrec)
                                     FROM movrecibo m2
                                    WHERE m2.nrecibo = r.nrecibo)
                  AND m.cestrec = 0   -- situació del rebut a pdte
                  AND NVL(cestaux, 0) IN(0, 2)   -- que estigui en vigor (sino f_situarec <> 0)
                  AND TRUNC(fperfin) >=
                               fmovini   -- f_situarec = 0 a data fperfin (data final de la liqui)
                  AND(TRUNC(fperfin) < fmovfin
                      OR fmovfin IS NULL)   -- f_situarec = 0 a data fperfin (data final de la liqui)
                  AND r.fefecto <=
                               fperfin   -- i  data efecte del rebut no sigui posterior a la liqui
                  AND s.cagente = NVL(pral.par_cagente, s.cagente)
                  AND s.cempres = p_cempres;

               v_pasexec := 10;
            EXCEPTION
               WHEN OTHERS THEN
                  ROLLBACK;
                  RETURN 1;
            END;
         END IF;

------------------------------------------
         IF p_codplan = 'APRA012' THEN
            FOR reg IN c_top(pral.par_cproces, pral.par_cagente, pral.par_rtfidioma) LOOP
               INSERT INTO int_report_data
                           (ID, descripcion, n01, n02, d02,
                            n03, n04, v01,
                            v02, v03, v04, n05,
                            n06, v05, v06, n07, v07, v08, v09,
                            v10, v11, v12, v13, v14,
                            v15, v16, norden)
                    VALUES (p_sproces, v_id, pral.par_cempres, pral.par_cagente, v_fcierre,
                            pral.par_rtfidioma, pral.par_cproces, pral.par_nombrok,
                            pral.par_tdombrok, pral.par_postbrok, pral.par_pobbrok, v_sum1,
                            v_sum2, v_sum3, v_sum4, v_sum5, v_sum6, reg.tomador, reg.fecha,
                            reg.cconcta_vis, reg.tcconcta, reg.cramo, reg.npoliza, reg.debe,
                            reg.haber, reg.dia, vcontador);

               vcontador := vcontador + 1;
               v_pasexec := 3;
            END LOOP;

------------------------------------------
            FOR reg IN c_multi_up(pral.par_cproces, pral.par_cagente, pral.par_rtfidioma) LOOP
               INSERT INTO int_report_data
                           (ID, descripcion, n01, n02, d02,
                            n03, n04, v01,
                            v02, v03, v04, n05,
                            n06, v05, v06, n07, v07, v08, v09,
                            v10, v11, v12, v13, v14,
                            v15, v16, v17, v18, norden)
                    VALUES (p_sproces, v_id, pral.par_cempres, pral.par_cagente, v_fcierre,
                            pral.par_rtfidioma, pral.par_cproces, pral.par_nombrok,
                            pral.par_tdombrok, pral.par_postbrok, pral.par_pobbrok, v_sum1,
                            v_sum2, v_sum3, v_sum4, v_sum5, v_sum6, reg.tomador, reg.fecha,
                            reg.cconcta_vis, reg.tcconcta, reg.cramo, reg.npoliza, reg.debe,
                            reg.haber, reg.dia, reg.letra_c1, reg.letra_c2, vcontador);

               vcontador := vcontador + 1;
               v_pasexec := 4;
            END LOOP;

            FOR reg IN c_multi_down(pral.par_cproces, pral.par_cagente, pral.par_rtfidioma) LOOP
               INSERT INTO int_report_data
                           (ID, descripcion, n01, n02, d02,
                            n03, n04, v01,
                            v02, v03, v04, n05,
                            n06, v05, v06, n07, v07, v08, v09,
                            v10, v11, v12, v13, v14,
                            v15, v16, norden)
                    VALUES (p_sproces, v_id, pral.par_cempres, pral.par_cagente, v_fcierre,
                            pral.par_rtfidioma, pral.par_cproces, pral.par_nombrok,
                            pral.par_tdombrok, pral.par_postbrok, pral.par_pobbrok, v_sum1,
                            v_sum2, v_sum3, v_sum4, v_sum5, v_sum6, reg.tomador, reg.fecha,
                            reg.cconcta_vis, reg.tcconcta, reg.cramo, reg.npoliza, reg.debe,
                            reg.haber, reg.dia, vcontador);

               vcontador := vcontador + 1;
               v_pasexec := 4;
            END LOOP;
/* ------------------------------------NO POSEM EL DARRER APUNT
            FOR reg IN c_bottom(pral.par_cproces, pral.par_cagente, pral.par_rtfidioma) LOOP
               INSERT INTO int_report_data
                           (ID, descripcion, n01, n02, d02,
                            n03, n04, v01,
                            v02, v03, v04, n05,
                            n06, v05, v06, n07, v07, v08, v09,
                            v10, v11, v12, v13, v14,
                            v15, v16, norden)
                    VALUES (p_sproces, v_id, pral.par_cempres, pral.par_cagente, v_fcierre,
                            pral.par_rtfidioma, pral.par_cproces, pral.par_nombrok,
                            pral.par_tdombrok, pral.par_postbrok, pral.par_pobbrok, v_sum1,
                            v_sum2, v_sum3, v_sum4, v_sum5, v_sum6, reg.tomador, reg.fecha,
                            reg.cconcta_vis, reg.tcconcta, reg.cramo, reg.npoliza, reg.debe,
                            reg.haber, reg.dia, vcontador);

               vcontador := vcontador + 1;
               v_pasexec := 5;
            END LOOP;*/
----------------------------------
         ELSIF p_codplan = 'APRA010' THEN
            FOR reg IN c_apra010(pral.par_cproces, pral.par_cagente, p_cempres) LOOP
               INSERT INTO int_report_data
                           (ID, descripcion, n01, n02, d02,
                            n03, n04, v01,
                            v02, v03, v04,
                            v05, n05, v06, d01, n06,
                            n07, n08, norden)
                    VALUES (p_sproces, v_id, pral.par_cempres, pral.par_cagente, v_fcierre,
                            pral.par_rtfidioma, pral.par_cproces, pral.par_nombrok,
                            pral.par_tdombrok, pral.par_postbrok, pral.par_pobbrok,
                            reg.npoliza, reg.nrecibo, reg.tomador, reg.fvencim, reg.itotalr,
                            reg.comision, v_sum1, vcontador);

               vcontador := vcontador + 1;
               v_pasexec := 5;
            END LOOP;
         END IF;
      END LOOP;

      v_error := 0;

      IF vcontador = 1 THEN
         pid := NULL;   --no he insertado nada.
      ELSE
         pid := v_id;
         COMMIT;
      END IF;

      RETURN v_error;
   EXCEPTION
      WHEN OTHERS THEN
         ROLLBACK;
         RETURN 1;
   END f_generar_listado;

   /******************************************************************************
      f_get_nombrereport - Recupera el nombre del report
      psinterf IN NUMBER,
      pdestino OUT varchar2
      Retorna 0 si OK 1 si KO

      Bug 14067 - 13/04/2010 - AMC
   ********************************************************************************/
   FUNCTION f_get_nombrereport(psinterf IN NUMBER, pdestino OUT VARCHAR2)
      RETURN NUMBER IS
   BEGIN
      SELECT destino
        INTO pdestino
        FROM int_detalle_doc
       WHERE sinterf = psinterf;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_listado', 1, 'error no controlado', SQLERRM);
         RETURN 1;
   END f_get_nombrereport;

   PROCEDURE p_recupera_error(
      psinterf IN int_resultado.sinterf%TYPE,
      presultado OUT int_resultado.cresultado%TYPE,
      perror OUT int_resultado.terror%TYPE,
      pnerror OUT int_resultado.nerror%TYPE) IS
   BEGIN
      -- Recupero el error
      SELECT r1.cresultado, r1.tcampoerror || ' ' || r1.terror, r1.nerror
        INTO presultado, perror, pnerror
        FROM int_resultado r1
       WHERE r1.sinterf = psinterf
         AND r1.smapead = (SELECT MAX(r2.smapead)
                             FROM int_resultado r2
                            WHERE r2.sinterf = psinterf);
   EXCEPTION
      WHEN OTHERS THEN
         presultado := NULL;
         perror := NULL;
         pnerror := NULL;
   END;

   -- bug 0028554 - 13/03/2014 - JMF: parametro opcional pdestcopia
   FUNCTION ff_crida_llistats(
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
      pdestcopia IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER IS
      vlineaini      VARCHAR2(500);
      vresultado     NUMBER(10);
      vnerror        NUMBER(10);
      vccompani      NUMBER := pcempres;

      /* CAMBIOS DE 4198 - START */
      V_MSG         VARCHAR2 (32000);
      V_MSGOUT      VARCHAR2 (32000);
      VPARSER       XMLPARSER.PARSER;
      V_DOMDOC      XMLDOM.DOMDOCUMENT;
      VTFICHPATH    VARCHAR2 (500);
      VFICHERO      VARCHAR2 (500);
      VARCHIVO      VARCHAR2 (500);
      VCCODPLAN     DETPLANTILLAS.CCODPLAN%TYPE;
      VCFDIGITAL    CODIPLANTILLAS.CFDIGITAL%TYPE;
      VAPLICA       NUMBER :=1;
      VERROR        NUMBER;
      VPASEXEC      NUMBER (8)     := 0;
      VERRORMSG     VARCHAR2 (32000);
      VSINTERF      INT_MENSAJES.SINTERF%TYPE;      
      /* CAMBIOS DE 4198 - END */

   BEGIN
      IF psinterf IS NULL THEN
         pac_int_online.p_inicializar_sinterf;
         psinterf := pac_int_online.f_obtener_sinterf;
      END IF;

      vlineaini := pcempres || '|' || pterminal || '|' || pusuario || '|' || ptpwd || '|'
                   || pid || '|' || ptipodestino || '|' || pplantillaorigen || '|' || pdestino
                   || '|' || pdatasource || '|' || pdestcopia;
      vresultado := pac_int_online.f_int(vccompani, psinterf, 'I016', vlineaini);

      IF vresultado <> 0 THEN
         RETURN vresultado;   --error
      END IF;

      /* CAMBIOS DE 4198 - START */
      P_CONTROL_ERROR('TESTING I016','pac_listado.ff_crida_llistats:I016:' || psinterf,'vlineaini : ' || vlineaini ); 
      BEGIN
        IF PTIPODESTINO = 'PDF' THEN
          VPASEXEC  := 4;             
          VARCHIVO := SUBSTR(PPLANTILLAORIGEN,
                             INSTR(PPLANTILLAORIGEN, '\', -1) + 1,
                             LENGTH(PPLANTILLAORIGEN));

          BEGIN
            SELECT D.CCODPLAN
              INTO VCCODPLAN
              FROM DETPLANTILLAS D
             WHERE D.CIDIOMA = 8
               AND D.CINFORME = VARCHIVO;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              VAPLICA := 0;
          END;

          IF VAPLICA = 1 THEN
            VPASEXEC  := 5;         
            SELECT C.CFDIGITAL
              INTO VCFDIGITAL
              FROM CODIPLANTILLAS C
             WHERE C.CCODPLAN = VCCODPLAN;
            IF VCFDIGITAL = 1 THEN  
                  VPASEXEC  := 6;    
                  
                  PAC_INT_ONLINE.P_INICIALIZAR_SINTERF;    
                  VSINTERF := PAC_INT_ONLINE.F_OBTENER_SINTERF;
                                                
                  VTFICHPATH := SUBSTR(PDESTINO,0,(INSTR(PDESTINO, '\', -1) - 1));

                  VFICHERO := SUBSTR(PDESTINO,INSTR(PDESTINO, '\', -1) + 1,LENGTH(PDESTINO));

                  V_MSG    := '<?xml version="1.0"?>
                               <conversion_out>
                                     <sinterf>'||VSINTERF ||'</sinterf>
                                     <tipoorigen>'||PTIPODESTINO||'</tipoorigen>
                                     <tipodestino>'||PTIPODESTINO||'</tipodestino>
                                     <ficherodestino>'||VTFICHPATH || '/' || VFICHERO ||'</ficherodestino>
                                     <firma_digital>'||VCFDIGITAL ||'</firma_digital>
                                     <firma_electronica_cliente>S</firma_electronica_cliente>
                                     <firma_electronica_clienteimagen></firma_electronica_clienteimagen>
                                     <firma_electronica_clienteposicion></firma_electronica_clienteposicion>
                               </conversion_out>';
                  VPASEXEC  := 7; 
                     
                  INSERT INTO int_mensajes (sinterf,cinterf,finterf,tmenout,tmenin )
                  VALUES(VSINTERF,'I008',f_sysdate,v_msg,NULL);
                  COMMIT; 
                                                          
                  PAC_INT_ONLINE.PETICION_HOST(PAC_MD_COMMON.F_GET_CXTEMPRESA,
                                               'I008',
                                               V_MSG,
                                               V_MSGOUT);    
                  VPASEXEC  := 8;                                            
                  PARSEAR (V_MSGOUT, VPARSER);
                  VPASEXEC  := 9;    
                  V_DOMDOC := XMLPARSER.GETDOCUMENT (VPARSER);
                  VPASEXEC  := 10;    
                  VERROR := PAC_XML.BUSCARNODOTEXTO (V_DOMDOC, 'estado');
                  VPASEXEC  := 11; 
                  VERRORMSG := PAC_XML.BUSCARNODOTEXTO (V_DOMDOC, 'errorMsg');
                  VPASEXEC  := 12; 
                  IF VERROR <> 0
                  THEN
                  P_TAB_ERROR(F_SYSDATE,
                              F_USER,
                              'pac_listado.ff_crida_llistats : I008',
                              VPASEXEC,
                              VERROR,
                              'SINTERF :'||VSINTERF||':'||VERRORMSG);
                  END IF;                                                               
            END IF; 
          END IF;
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
        P_TAB_ERROR(F_SYSDATE,
                    F_USER,
                    'pac_listado.ff_crida_llistats : I008',
                    VPASEXEC,
                    VERROR,
                    'SINTERF :'||VSINTERF||':'||VERRORMSG);
      END;
      /* CAMBIOS DE 4198 - END */

      -- Recupero el error
      pac_listado.p_recupera_error(psinterf, vresultado, perror, vnerror);

      IF vresultado <> 0 THEN
         RETURN vresultado;
      END IF;

      IF NVL(vnerror, 0) <> 0 THEN
         RETURN vnerror;
      END IF;

      RETURN 0;   --todo ok
   END ff_crida_llistats;


   /* CAMBIOS DE 4198 - START */
   PROCEDURE PARSEAR(P_CLOB IN CLOB, P_PARSER IN OUT XMLPARSER.PARSER) IS
   BEGIN
     P_PARSER := XMLPARSER.NEWPARSER;
     XMLPARSER.SETVALIDATIONMODE(P_PARSER, FALSE);
   
     IF DBMS_LOB.GETLENGTH(P_CLOB) > 32767 THEN
       XMLPARSER.PARSECLOB(P_PARSER, P_CLOB);
     ELSE
       XMLPARSER.PARSEBUFFER(P_PARSER,
                             DBMS_LOB.SUBSTR(P_CLOB,
                                             DBMS_LOB.GETLENGTH(P_CLOB),
                                             1));
     END IF;
   END;
   /* CAMBIOS DE 4198 - END */

END pac_listado;

/

  GRANT EXECUTE ON "AXIS"."PAC_LISTADO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_LISTADO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_LISTADO" TO "PROGRAMADORESCSI";
