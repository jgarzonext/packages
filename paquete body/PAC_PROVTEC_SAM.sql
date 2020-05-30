--------------------------------------------------------
--  DDL for Package Body PAC_PROVTEC_SAM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_PROVTEC_SAM" IS
/****************************************************************************
   NOMBRE:       pac_provtec_sam
   PROPÓSITO:    Calculo de las provisiones técnicas genéricas de Sud AMerica

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ----------------------------------
   1.0           -          -               Creació del package
   2.0         03/09/2013  AFM              bug: 26422/151994. Se extrae Iva del calculo de la Provisión f_commit_calcul_rrcsam
****************************************************************************/

   -- cursores para el cálculo de las rrc
   CURSOR c_polizas_rrc(fecha DATE, empresa NUMBER) IS
      SELECT c.cempres, s.cramo, s.cmodali, s.cduraci, s.nduraci, s.ctipseg, s.ccolect,
             s.sseguro, pac_seguros.ff_get_actividad(s.sseguro, r.nriesgo) cactivi, s.fvencim,
             s.fcaranu, s.fefecto, r.nriesgo, s.cagente, s.npoliza, s.ncertif,
             NVL(p.cramdgs, 0) cramdgs, NVL(c.pgasadm, 0) pgasadm, NVL(c.plimadm, 0) plimadm,
             NVL(c.pgasadq, 0) pgasadq, NVL(c.plimadq, 0) plimadq,
             DECODE(NVL(p.creaseg, 1), 0, 3, DECODE(NVL(s.ctiprea, 1), 2, 2, 0)) csegrea,
             p.sproduc, s.cforpag, d.cmoneda cmoneda,
             pac_monedas.f_cmoneda_t(d.cmoneda) cmoneda_t, re.nrecibo, re.femisio
        FROM productos p, seguros s, codidivisa d, riesgos r, codiram c, recibos re
       WHERE d.cdivisa(+) = p.cdivisa
         AND pac_anulacion.f_anulada_al_emitir(s.sseguro) = 0
         AND f_situacion_v(s.sseguro, fecha) IN(0, 1)
         AND s.csituac <> 4
         -- Bug 0026430 - 11/03/2014 - JMF - No contar los parciales
         AND NOT EXISTS(SELECT 1
                          FROM detmovrecibo xx
                         WHERE xx.nrecibo = re.nrecibo)
         AND s.cramo = c.cramo
         AND c.cempres = empresa
         AND p.cramo = s.cramo
         AND p.cmodali = s.cmodali
         AND p.ctipseg = s.ctipseg
         AND p.ccolect = s.ccolect
         AND r.sseguro = s.sseguro
         AND s.sseguro = re.sseguro
         AND EXISTS(SELECT 1
                      FROM garanseg g
                     WHERE g.sseguro = r.sseguro
                       AND g.nriesgo = r.nriesgo
                       AND g.iprianu != 0)
         AND(re.femisio
             + GREATEST(30,
                        (SELECT crespue
                           FROM pregunpolseg
                          WHERE cpregun = 9015   -- Días de gracia
                            AND sseguro = re.sseguro
                            AND nmovimi = (SELECT MAX(nmovimi)
                                             FROM pregunpolseg
                                            WHERE cpregun = 9015
                                              AND sseguro = re.sseguro
                                              AND nmovimi <= re.nmovimi)))) >= fecha
         AND TRUNC(s.femisio) <= fecha;

   CURSOR c_garantias_rrc(
      wseguro NUMBER,
      wcramo NUMBER,
      wcmodali NUMBER,
      wctipseg NUMBER,
      wccolect NUMBER,
      fecha DATE,
      fechafin DATE,
      wnriesgo NUMBER) IS
      SELECT   g.cgarant, NVL(gg.precseg, 0) precseg,
               NVL(g.iprianu, 0) * NVL(nasegur, 1) iprianu,
               DECODE(NVL(gg.creaseg, 1), 0, 1, 0) cgarrea, g.nmovimi, g.finiefe, g.ffinefe,
               gg.cprovis, gg.cactivi
          FROM garanpro gg, garanseg g, riesgos r,
               seguros s   -- fem distinció si és o no suplement
         WHERE g.sseguro = wseguro
           AND g.finiefe <= fecha
           AND s.sseguro = g.sseguro   -- fem distinció si és o no suplement
           AND   -- fem distinció si és o no suplement
              (g.ffinefe > fecha
               OR(s.csituac != 5
                  AND (SELECT MAX(m.nmovimi)
                         FROM movseguro m, garanseg ga
                        WHERE m.sseguro = g.sseguro
                          AND m.sseguro = ga.sseguro
                          AND m.nmovimi = ga.nmovimi
                          AND TRUNC(m.fmovimi) <= fecha) = g.nmovimi)
               OR(s.csituac = 5
                  AND g.ffinefe IS NOT NULL
                  AND g.ffinefe <= fecha
                  AND g.nmovimi = (SELECT MAX(nmovimi) - 1
-- Número de moviment anterior al moviment de suplement que té retinguda la pòlissa
                                   FROM   movseguro
                                    WHERE cmovseg = 1   -- Moviment de suplement
                                      AND femisio IS NULL
                                      -- Moviment encara no emés => És una proposta de suplement
                                      AND sseguro = g.sseguro)))
           AND gg.cgarant = g.cgarant
           AND gg.cramo = wcramo
           AND gg.cmodali = wcmodali
           AND gg.ctipseg = wctipseg
           AND gg.ccolect = wccolect
           AND g.nriesgo = wnriesgo
           AND gg.cactivi = 0
           AND g.iprianu != 0
           AND r.sseguro = g.sseguro
           AND r.fefecto <= fecha
           AND(r.fanulac > fecha
               OR r.fanulac IS NULL)
           AND(g.nriesgo = r.nriesgo
               OR g.nriesgo IS NULL)
      ORDER BY g.cgarant;

-----------------------------------------------------------------------
-----------------------------------------------------------------------
-----------------------------------------------------------------------
-- RRC
-----------------------------------------------------------------------
   FUNCTION f_comi_ces(
      pscomrea IN NUMBER,
      psseguro IN NUMBER,
      pcgarant IN NUMBER,
      pcomisi IN NUMBER,
      pfefecto IN DATE)
      RETURN NUMBER IS
      v_pasexec      NUMBER(8) := 0;
      v_param        VARCHAR2(500)
         := 'pscomrea: ' || pscomrea || ', psseguro: ' || psseguro || ', pcgarant: '
            || pcgarant || ', pcomisi: ' || pcomisi || ', pfefecto: ' || pfefecto;
      v_object       VARCHAR2(200) := 'pac_provtec_sam.f_comi_ces';
      v_numerr       NUMBER := 0;
      v_importe      NUMBER;
      v_pcomias      NUMBER;
      v_impant       NUMBER;
      v_impparctot   NUMBER;
      v_monedinst    NUMBER;
      v_comis        NUMBER;
   BEGIN
      IF pscomrea = 0
         OR pscomrea IS NULL THEN
         v_comis := pcomisi;
      ELSE
         v_importe := pac_reaseguro_rec.f_buscomgarant(pscomrea, psseguro, pcgarant, pfefecto,
                                                       v_pcomias);
         v_comis := v_pcomias;

         IF v_comis = 0 THEN
            v_comis := pcomisi;
         END IF;
      END IF;

      RETURN v_comis;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param,
                     'num_err=' || v_numerr || ' --> Error: ' || SQLERRM);
         RETURN 9000503;
   END f_comi_ces;

   FUNCTION f_commit_calcul_rrcsam(
      cempres IN NUMBER,
      aux_factual IN DATE,
      psproces IN NUMBER,
      pcidioma IN NUMBER,
      pcmoneda IN NUMBER,
      pmodo IN VARCHAR2 DEFAULT 'R')
      RETURN NUMBER IS
      v_obj          VARCHAR2(400) := 'PAC_PROVTEC_SAM.f_commit_calcul_rrcsam';
      ttexto         VARCHAR2(400);
      nlin           NUMBER;
      num_err        NUMBER := 0;
      conta_err      NUMBER := 0;
      wprimrrc_gar   NUMBER;
      wprimrrc_gar_moncon NUMBER;
      wnrecibo       NUMBER;
      wiprrcrc       NUMBER;
      wicrrcrc       NUMBER;
      wiprrcrc_moncon NUMBER;
      wicrrcrc_moncon NUMBER;
      w_cmoncon      parempresas.nvalpar%TYPE
                                     := pac_parametros.f_parempresa_n(cempres, 'MONEDACONTAB');
      -- Moneda de contablidad (numérico)
      w_cmoncon_t    monedas.cmonint%TYPE := pac_monedas.f_cmoneda_t(w_cmoncon);
      -- Moneda de contablidad (texto)
      pfcambio       DATE;
      -- Fecha del cambio vigente a la fecha actual
      witasa         NUMBER(15, 2);   -- Tasa vigente
      v_multimoneda  NUMBER(1) := 0;
      ffinal         DATE;
      aux_fefeini    DATE;
      wprorrata      NUMBER;
      wcmodcom       NUMBER;
      aux_fcalcul    DATE;
   BEGIN
      v_multimoneda := NVL(pac_parametros.f_parempresa_n(cempres, 'MULTIMONEDA'), 0);

      FOR reg IN c_polizas_rrc(aux_factual, cempres) LOOP
         num_err := f_fechainifin(reg.sseguro, aux_factual, reg.fvencim, reg.fcaranu, ffinal,
                                  aux_fefeini, wprorrata, wcmodcom);

         IF num_err != 0 THEN
            p_tab_error(f_sysdate, f_user, v_obj, 1213,
                        ' s=' || reg.sseguro || ' f=' || aux_factual || ' v=' || reg.fvencim
                        || ' v=' || reg.fcaranu,
                        'err=' || num_err || ' ' || SQLCODE || '-' || SQLERRM);
            num_err := 104349;
         END IF;

         IF num_err = 0 THEN
            -- Debemos incluir en la provisión los recibos a futuro, emitidos pero con efecto posterior al proceso de cálculo
            IF TO_DATE(aux_factual) < TO_DATE(reg.fefecto) THEN
               aux_fcalcul := reg.fefecto;
            ELSE
               aux_fcalcul := aux_factual;
            END IF;

            FOR gar IN c_garantias_rrc(reg.sseguro, reg.cramo, reg.cmodali, reg.ctipseg,
                                       reg.ccolect, aux_fcalcul, ffinal, reg.nriesgo) LOOP
               witasa := 1;
               pfcambio := aux_factual;

               IF v_multimoneda = 1 THEN
                  IF reg.cmoneda = w_cmoncon THEN
                     witasa := 1;
                     pfcambio := aux_factual;
                  ELSE
                     pfcambio := pac_eco_tipocambio.f_fecha_max_cambio(reg.cmoneda_t,
                                                                       w_cmoncon_t,
                                                                       aux_factual);

                     IF pfcambio IS NULL THEN
                        ttexto := f_axis_literales(9902592, pcidioma);
                        num_err := f_proceslin(psproces, ttexto || ' -RRC', reg.sseguro, nlin);
                        nlin := NULL;
                        num_err := 9902592;
                     END IF;

                     witasa := pac_eco_tipocambio.f_cambio(reg.cmoneda_t, w_cmoncon_t,
                                                           pfcambio);
                  END IF;
               END IF;

               SELECT SUM(NVL(iconcep, 0)), SUM(f_round(NVL(iconcep, 0) * witasa, w_cmoncon))
                 INTO wprimrrc_gar, wprimrrc_gar_moncon
                 FROM detrecibos
                WHERE nrecibo = reg.nrecibo
                  AND cgarant = gar.cgarant
                  AND nriesgo = reg.nriesgo
                  -- AND cconcep IN(0, 4); bug: 26422/151994
                  AND cconcep = 0;   -- bug: 26422/151994

               BEGIN
                  IF pmodo = 'R' THEN
                     INSERT INTO rrc_sam
                                 (cempres, fcalcul, sproces, cramdgs, cramo,
                                  cmodali, ctipseg, ccolect, sseguro,
                                  nmovimi, nriesgo, npoliza, ncertif,
                                  nrecibo, cgarant, fefeini, ffinefe,
                                  iprirrc, sproduc, cmoneda, fcambio, itasa,
                                  iprirrc_moncon)
                          VALUES (reg.cempres, aux_factual, psproces, reg.cramdgs, reg.cramo,
                                  reg.cmodali, reg.ctipseg, reg.ccolect, reg.sseguro,
                                  gar.nmovimi, reg.nriesgo, reg.npoliza, reg.ncertif,
                                  reg.nrecibo, gar.cgarant, aux_factual, ffinal,
                                  wprimrrc_gar, reg.sproduc, reg.cmoneda, pfcambio, witasa,
                                  wprimrrc_gar_moncon);
                  ELSIF pmodo = 'P' THEN
                     INSERT INTO rrc_sam_previo
                                 (cempres, fcalcul, sproces, cramdgs, cramo,
                                  cmodali, ctipseg, ccolect, sseguro,
                                  nmovimi, nriesgo, npoliza, ncertif,
                                  nrecibo, cgarant, fefeini, ffinefe,
                                  iprirrc, sproduc, cmoneda, fcambio, itasa,
                                  iprirrc_moncon)
                          VALUES (reg.cempres, aux_factual, psproces, reg.cramdgs, reg.cramo,
                                  reg.cmodali, reg.ctipseg, reg.ccolect, reg.sseguro,
                                  gar.nmovimi, reg.nriesgo, reg.npoliza, reg.ncertif,
                                  reg.nrecibo, gar.cgarant, aux_factual, ffinal,
                                  wprimrrc_gar, reg.sproduc, reg.cmoneda, pfcambio, witasa,
                                  wprimrrc_gar_moncon);
                  END IF;
               EXCEPTION
                  WHEN OTHERS THEN
                     num_err := 103869;
                     p_tab_error(f_sysdate, f_user, v_obj, 1331,
                                 'e=' || reg.cempres || ' c=' || aux_factual || ' p='
                                 || psproces || ' s=' || reg.sseguro || ' g=' || gar.cgarant,
                                 SQLCODE || '-' || SQLERRM);
               END;

               IF num_err != 0
                  AND num_err IS NOT NULL THEN
                  ROLLBACK;
                  ttexto := f_axis_literales(num_err, pcidioma);
                  num_err := f_proceslin(psproces, ttexto || ' -RRC', reg.sseguro, nlin);
                  nlin := NULL;
               END IF;
            END LOOP;
         ELSE
            ttexto := f_axis_literales(num_err, pcidioma);
            num_err := f_proceslin(psproces, ttexto || ' -RRC', reg.sseguro, nlin);
            nlin := NULL;
            conta_err := conta_err + 1;
         END IF;

         COMMIT;
      END LOOP;

      IF pmodo = 'R' THEN
         DELETE FROM rrc_sam
               WHERE NVL(iprirrc, 0) = 0
                 AND NVL(iprirrc_moncon, 0) = 0
                 AND sproces = psproces;
      ELSIF pmodo = 'P' THEN
         DELETE FROM rrc_sam_previo
               WHERE NVL(iprirrc, 0) = 0
                 AND NVL(iprirrc_moncon, 0) = 0
                 AND sproces = psproces;
      END IF;

      COMMIT;
      RETURN(conta_err);
   END f_commit_calcul_rrcsam;

-----------------------------------------------------------------------
-----------------------------------------------------------------------
-----------------------------------------------------------------------
-- RRC_REA
-----------------------------------------------------------------------
   FUNCTION f_commit_calcul_rrcreasam(
      cempres IN NUMBER,
      aux_factual IN DATE,
      psproces IN NUMBER,
      pcidioma IN NUMBER,
      pcmoneda IN NUMBER,
      pmodo IN VARCHAR2 DEFAULT 'R')
      RETURN NUMBER IS
      v_obj          VARCHAR2(400) := 'PAC_PROVTEC_SAM.f_commit_calcul_rrcreasam';
      ttexto         VARCHAR2(400);
      nlin           NUMBER;
      num_err        NUMBER := 0;
      conta_err      NUMBER := 0;
      wprimrrc_gar   NUMBER;
      wprimrrc_gar_moncon NUMBER;
      wnrecibo       NUMBER;
      wiprrcrc       NUMBER;
      wicrrcrc       NUMBER;
      wiprrcrc_moncon NUMBER;
      wicrrcrc_moncon NUMBER;
      w_cmoncon      parempresas.nvalpar%TYPE
                                     := pac_parametros.f_parempresa_n(cempres, 'MONEDACONTAB');
      -- Moneda de contablidad (numérico)
      w_cmoncon_t    monedas.cmonint%TYPE := pac_monedas.f_cmoneda_t(w_cmoncon);
      -- Moneda de contablidad (texto)
      pfcambio       DATE;
      -- Fecha del cambio vigente a la fecha actual
      witasa         NUMBER(15, 2);   -- Tasa vigente
      v_multimoneda  NUMBER(1) := 0;
      ffinal         DATE;
      aux_fefeini    DATE;
      wprorrata      NUMBER;
      wcmodcom       NUMBER;
      wctramo        NUMBER;
      aux_fcalcul    DATE;
   BEGIN
      v_multimoneda := NVL(pac_parametros.f_parempresa_n(cempres, 'MULTIMONEDA'), 0);

      FOR reg IN c_polizas_rrc(aux_factual, cempres) LOOP
         num_err := f_fechainifin(reg.sseguro, aux_factual, reg.fvencim, reg.fcaranu, ffinal,
                                  aux_fefeini, wprorrata, wcmodcom);

         IF num_err != 0 THEN
            p_tab_error(f_sysdate, f_user, v_obj, 1213,
                        ' s=' || reg.sseguro || ' f=' || aux_factual || ' v=' || reg.fvencim
                        || ' v=' || reg.fcaranu,
                        'err=' || num_err || ' ' || SQLCODE || '-' || SQLERRM);
            num_err := 104349;
         END IF;

         IF num_err = 0 THEN
            -- Debemos incluir en la provisión los recibos a futuro, emitidos pero con efecto posterior al proceso de cálculo
            IF TO_DATE(aux_factual) < TO_DATE(reg.fefecto) THEN
               aux_fcalcul := reg.fefecto;
            ELSE
               aux_fcalcul := aux_factual;
            END IF;

            FOR gar IN c_garantias_rrc(reg.sseguro, reg.cramo, reg.cmodali, reg.ctipseg,
                                       reg.ccolect, aux_fcalcul, ffinal, reg.nriesgo) LOOP
               witasa := 1;
               pfcambio := aux_factual;

               IF v_multimoneda = 1 THEN
                  IF reg.cmoneda = w_cmoncon THEN
                     witasa := 1;
                     pfcambio := aux_factual;
                  ELSE
                     pfcambio := pac_eco_tipocambio.f_fecha_max_cambio(reg.cmoneda_t,
                                                                       w_cmoncon_t,
                                                                       aux_factual);

                     IF pfcambio IS NULL THEN
                        ttexto := f_axis_literales(9902592, pcidioma);
                        num_err := f_proceslin(psproces, ttexto || ' -RRC-REA', reg.sseguro,
                                               nlin);
                        nlin := NULL;
                        num_err := 9902592;
                     END IF;

                     witasa := pac_eco_tipocambio.f_cambio(reg.cmoneda_t, w_cmoncon_t,
                                                           pfcambio);
                  END IF;
               END IF;

               FOR f_nofac IN (SELECT DISTINCT ccompani
                                          FROM cuadroces cf, cesionesrea ce
                                         WHERE cf.nversio = ce.nversio
                                           AND cf.scontra = ce.scontra
                                           AND cf.ctramo = ce.ctramo
                                           AND ce.sseguro = reg.sseguro) LOOP   --No facultativo
                  IF reg.csegrea = 0
                     AND gar.cgarrea = 0 THEN   -- Tenemos Reaseguro
                     BEGIN
                        SELECT   r.nrecibo, ce.ctramo,
                                 SUM(NVL((ce.icesion
                                          * DECODE(tr.ctramo,
                                                   1, DECODE(SIGN((ce.icapces * tr.plocal / 100)
                                                                  - NVL(tr.imaxplo, 0)),
                                                             -1,(cc.pcesion
                                                                 *(100
                                                                   -((tr.plocal * tr.imaxplo)
                                                                     /((ce.icapces * tr.plocal)
                                                                       / 100))))
                                                              /(100 - tr.plocal),
                                                             cc.pcesion),
                                                   cc.pcesion)
                                          / 100)
                                         * rs.nfactor,
                                         0)),
                                 SUM(NVL((ce.icesion
                                          * DECODE(tr.ctramo,
                                                   1, DECODE(SIGN((ce.icapces * tr.plocal / 100)
                                                                  - NVL(tr.imaxplo, 0)),
                                                             -1,(cc.pcesion
                                                                 *(100
                                                                   -((tr.plocal * tr.imaxplo)
                                                                     /((ce.icapces * tr.plocal)
                                                                       / 100))))
                                                              /(100 - tr.plocal),
                                                             cc.pcesion),
                                                   cc.pcesion)
                                          * NVL(f_comi_ces(cc.ccomrea, s.sseguro, ce.cgarant,
                                                           cc.pctcomis, r.femisio),
                                                0)
                                          / 10000)
                                         * rs.nfactor,
                                         0))
                            INTO wnrecibo, wctramo,
                                 wiprrcrc,
                                 wicrrcrc
                            FROM seguros s,
                                 tramos tr,
                                 recibos r,
                                 cuadroces cc,
                                 reasegemi rs,
                                 productos pr,
                                 companias c,
                                 (SELECT icesion, icapces, ce.sseguro, ce.nversio, ce.ctramo,
                                         ce.scontra, ce.cgarant, ce.sfacult, ce.nmovimi,
                                         ce.nriesgo
                                    FROM cesionesrea ce, tramos tr
                                   WHERE tr.scontra = ce.scontra
                                     AND tr.nversio = ce.nversio
                                     AND tr.ctramo = ce.ctramo
                                     AND ce.fefecto <> ce.fvencim) ce
                           WHERE r.nrecibo = reg.nrecibo
                             AND ce.cgarant = gar.cgarant
                             AND cc.ccompani = f_nofac.ccompani
                             AND cc.ctramo = tr.ctramo
                             AND cc.scontra = tr.scontra
                             AND cc.nversio = tr.nversio
                             AND tr.scontra = ce.scontra
                             AND tr.nversio = ce.nversio
                             AND tr.ctramo = ce.ctramo
                             AND s.sseguro = ce.sseguro
                             AND s.sseguro = rs.sseguro
                             AND r.nrecibo = rs.nrecibo
                             AND rs.cmotces = 1
                             AND s.cramo = pr.cramo
                             AND s.cmodali = pr.cmodali
                             AND s.ctipseg = pr.ctipseg
                             AND s.ccolect = pr.ccolect
                             AND c.ccompani = cc.ccorred
                        GROUP BY r.nrecibo, ce.ctramo;

                        wiprrcrc_moncon := f_round(wiprrcrc * witasa, w_cmoncon);
                        wicrrcrc_moncon := f_round(wicrrcrc * witasa, w_cmoncon);
                     EXCEPTION
                        WHEN OTHERS THEN
                           wiprrcrc := 0;
                           wicrrcrc := 0;
                           wiprrcrc_moncon := 0;
                           wicrrcrc_moncon := 0;
                           wctramo := 0;
                     END;
                  ELSE
                     wiprrcrc := 0;
                     wicrrcrc := 0;
                     wiprrcrc_moncon := 0;
                     wicrrcrc_moncon := 0;
                     wctramo := 0;
                  END IF;

                  IF num_err != 0
                     AND num_err IS NOT NULL THEN
                     ROLLBACK;
                     ttexto := f_axis_literales(num_err, pcidioma);
                     num_err := f_proceslin(psproces, ttexto || ' -RRC-REA', reg.sseguro,
                                            nlin);
                     nlin := NULL;
                  END IF;

                  BEGIN
                     IF pmodo = 'R' THEN
                        INSERT INTO rrc_rea_sam
                                    (cempres, fcalcul, sproces, cramdgs,
                                     cramo, cmodali, ctipseg, ccolect,
                                     sseguro, nmovimi, nriesgo, npoliza,
                                     ncertif, nrecibo, cgarant, ccompani,
                                     ctramo, fefeini, ffinefe, iprrcrc, icrrcrc,
                                     sproduc, cmoneda, fcambio, itasa,
                                     iprrcrc_moncon, icrrcrc_moncon)
                             VALUES (reg.cempres, aux_factual, psproces, reg.cramdgs,
                                     reg.cramo, reg.cmodali, reg.ctipseg, reg.ccolect,
                                     reg.sseguro, gar.nmovimi, reg.nriesgo, reg.npoliza,
                                     reg.ncertif, reg.nrecibo, gar.cgarant, f_nofac.ccompani,
                                     wctramo, aux_factual, ffinal, wiprrcrc, wicrrcrc,
                                     reg.sproduc, reg.cmoneda, pfcambio, witasa,
                                     wiprrcrc_moncon, wicrrcrc_moncon);
                     ELSIF pmodo = 'P' THEN
                        INSERT INTO rrc_rea_sam_previo
                                    (cempres, fcalcul, sproces, cramdgs,
                                     cramo, cmodali, ctipseg, ccolect,
                                     sseguro, nmovimi, nriesgo, npoliza,
                                     ncertif, nrecibo, cgarant, ccompani,
                                     ctramo, fefeini, ffinefe, iprrcrc, icrrcrc,
                                     sproduc, cmoneda, fcambio, itasa,
                                     iprrcrc_moncon, icrrcrc_moncon)
                             VALUES (reg.cempres, aux_factual, psproces, reg.cramdgs,
                                     reg.cramo, reg.cmodali, reg.ctipseg, reg.ccolect,
                                     reg.sseguro, gar.nmovimi, reg.nriesgo, reg.npoliza,
                                     reg.ncertif, reg.nrecibo, gar.cgarant, f_nofac.ccompani,
                                     wctramo, aux_factual, ffinal, wiprrcrc, wicrrcrc,
                                     reg.sproduc, reg.cmoneda, pfcambio, witasa,
                                     wiprrcrc_moncon, wicrrcrc_moncon);
                     END IF;
                  EXCEPTION
                     WHEN OTHERS THEN
                        num_err := 103869;
                        p_tab_error(f_sysdate, f_user, v_obj, 1331,
                                    'e=' || reg.cempres || ' c=' || aux_factual || ' p='
                                    || psproces || ' s=' || reg.sseguro || ' g='
                                    || gar.cgarant || ' c=' || f_nofac.ccompani || ' nofac',
                                    SQLCODE || '-' || SQLERRM);
                  END;

                  IF num_err != 0
                     AND num_err IS NOT NULL THEN
                     ROLLBACK;
                     ttexto := f_axis_literales(num_err, pcidioma);
                     num_err := f_proceslin(psproces, ttexto || ' -RRCREA', reg.sseguro, nlin);
                     nlin := NULL;
                  END IF;
               END LOOP;

               FOR f_fac IN (SELECT DISTINCT ccompani
                                        FROM cuacesfac cf, cesionesrea ce
                                       WHERE cf.sfacult = ce.sfacult
                                         AND sseguro = reg.sseguro) LOOP   --Facultativo
                  IF reg.csegrea = 0
                     AND gar.cgarrea = 0 THEN   -- Tenemos Reaseguro
                     BEGIN
                        SELECT   r.nrecibo, ce.ctramo,
                                 SUM(NVL((ce.icesion
                                          * DECODE(tr.ctramo,
                                                   1, DECODE(SIGN((ce.icapces * tr.plocal / 100)
                                                                  - NVL(tr.imaxplo, 0)),
                                                             -1,(cc.pcesion
                                                                 *(100
                                                                   -((tr.plocal * tr.imaxplo)
                                                                     /((ce.icapces * tr.plocal)
                                                                       / 100))))
                                                              /(100 - tr.plocal),
                                                             cc.pcesion),
                                                   cc.pcesion)
                                          / 100)
                                         * rs.nfactor,
                                         0)),
                                 SUM(NVL((ce.icesion
                                          * DECODE(tr.ctramo,
                                                   1, DECODE(SIGN((ce.icapces * tr.plocal / 100)
                                                                  - NVL(tr.imaxplo, 0)),
                                                             -1,(cc.pcesion
                                                                 *(100
                                                                   -((tr.plocal * tr.imaxplo)
                                                                     /((ce.icapces * tr.plocal)
                                                                       / 100))))
                                                              /(100 - tr.plocal),
                                                             cc.pcesion),
                                                   cc.pcesion)
                                          * NVL(f_comi_ces(cc.ccomrea, s.sseguro, ce.cgarant,
                                                           cc.pcomisi, r.femisio),
                                                0)
                                          / 10000)
                                         * rs.nfactor,
                                         0))
                            INTO wnrecibo, wctramo,
                                 wiprrcrc,
                                 wicrrcrc
                            FROM seguros s,
                                 tramos tr,
                                 recibos r,
                                 cuacesfac cc,
                                 reasegemi rs,
                                 productos pr,
                                 companias c,
                                 (SELECT icesion, icapces, ce.sseguro, ce.nversio, ce.ctramo,
                                         ce.scontra, ce.cgarant, ce.sfacult, ce.nmovimi,
                                         ce.nriesgo
                                    FROM cesionesrea ce, tramos tr
                                   WHERE tr.scontra = ce.scontra
                                     AND tr.nversio = ce.nversio
                                     AND tr.ctramo = ce.ctramo
                                     AND ce.fefecto <> ce.fvencim) ce
                           WHERE r.nrecibo = reg.nrecibo
                             AND cc.sfacult = ce.sfacult
                             AND ce.cgarant = gar.cgarant
                             AND cc.ccompani = f_fac.ccompani
                             AND tr.scontra = ce.scontra
                             AND tr.nversio = ce.nversio
                             AND tr.ctramo = ce.ctramo
                             AND s.sseguro = ce.sseguro
                             AND s.sseguro = rs.sseguro
                             AND r.nrecibo = rs.nrecibo
                             AND rs.cmotces = 1
                             AND s.cramo = pr.cramo
                             AND s.cmodali = pr.cmodali
                             AND s.ctipseg = pr.ctipseg
                             AND s.ccolect = pr.ccolect
                             AND c.ccompani = cc.ccorred
                        GROUP BY r.nrecibo, ce.ctramo;

                        wiprrcrc_moncon := f_round(wiprrcrc * witasa, w_cmoncon);
                        wicrrcrc_moncon := f_round(wicrrcrc * witasa, w_cmoncon);
                     EXCEPTION
                        WHEN OTHERS THEN
                           wiprrcrc := 0;
                           wicrrcrc := 0;
                           wiprrcrc_moncon := 0;
                           wicrrcrc_moncon := 0;
                     END;
                  ELSE
                     wiprrcrc := 0;
                     wicrrcrc := 0;
                     wiprrcrc_moncon := 0;
                     wicrrcrc_moncon := 0;
                  END IF;

                  IF num_err != 0
                     AND num_err IS NOT NULL THEN
                     ROLLBACK;
                     ttexto := f_axis_literales(num_err, pcidioma);
                     num_err := f_proceslin(psproces, ttexto || ' -RRC-REA-FAC', reg.sseguro,
                                            nlin);
                     nlin := NULL;
                  END IF;

                  BEGIN
                     IF pmodo = 'R' THEN
                        INSERT INTO rrc_rea_sam
                                    (cempres, fcalcul, sproces, cramdgs,
                                     cramo, cmodali, ctipseg, ccolect,
                                     sseguro, nmovimi, nriesgo, npoliza,
                                     ncertif, nrecibo, cgarant, ccompani,
                                     ctramo, fefeini, ffinefe, iprrcrc, icrrcrc,
                                     sproduc, cmoneda, fcambio, itasa,
                                     iprrcrc_moncon, icrrcrc_moncon)
                             VALUES (reg.cempres, aux_factual, psproces, reg.cramdgs,
                                     reg.cramo, reg.cmodali, reg.ctipseg, reg.ccolect,
                                     reg.sseguro, gar.nmovimi, reg.nriesgo, reg.npoliza,
                                     reg.ncertif, reg.nrecibo, gar.cgarant, f_fac.ccompani,
                                     wctramo, aux_factual, ffinal, wiprrcrc, wicrrcrc,
                                     reg.sproduc, reg.cmoneda, pfcambio, witasa,
                                     wiprrcrc_moncon, wicrrcrc_moncon);
                     ELSIF pmodo = 'P' THEN
                        INSERT INTO rrc_rea_sam_previo
                                    (cempres, fcalcul, sproces, cramdgs,
                                     cramo, cmodali, ctipseg, ccolect,
                                     sseguro, nmovimi, nriesgo, npoliza,
                                     ncertif, nrecibo, cgarant, ccompani,
                                     ctramo, fefeini, ffinefe, iprrcrc, icrrcrc,
                                     sproduc, cmoneda, fcambio, itasa,
                                     iprrcrc_moncon, icrrcrc_moncon)
                             VALUES (reg.cempres, aux_factual, psproces, reg.cramdgs,
                                     reg.cramo, reg.cmodali, reg.ctipseg, reg.ccolect,
                                     reg.sseguro, gar.nmovimi, reg.nriesgo, reg.npoliza,
                                     reg.ncertif, reg.nrecibo, gar.cgarant, f_fac.ccompani,
                                     wctramo, aux_factual, ffinal, wiprrcrc, wicrrcrc,
                                     reg.sproduc, reg.cmoneda, pfcambio, witasa,
                                     wiprrcrc_moncon, wicrrcrc_moncon);
                     END IF;
                  EXCEPTION
                     WHEN OTHERS THEN
                        num_err := 103869;
                        p_tab_error(f_sysdate, f_user, v_obj, 1331,
                                    'e=' || reg.cempres || ' c=' || aux_factual || ' p='
                                    || psproces || ' s=' || reg.sseguro || ' g='
                                    || gar.cgarant || ' c=' || f_fac.ccompani || ' fac',
                                    SQLCODE || '-' || SQLERRM);
                  END;

                  IF num_err != 0
                     AND num_err IS NOT NULL THEN
                     ROLLBACK;
                     ttexto := f_axis_literales(num_err, pcidioma);
                     num_err := f_proceslin(psproces, ttexto || ' -RRCREafac', reg.sseguro,
                                            nlin);
                     nlin := NULL;
                  END IF;
               END LOOP;
            END LOOP;
         ELSE
            ttexto := f_axis_literales(num_err, pcidioma);
            num_err := f_proceslin(psproces, ttexto || ' -RRCREA', reg.sseguro, nlin);
            nlin := NULL;
            conta_err := conta_err + 1;
         END IF;

         COMMIT;
      END LOOP;

      IF pmodo = 'R' THEN
         DELETE FROM rrc_rea_sam
               WHERE NVL(iprrcrc, 0) = 0
                 AND NVL(iprrcrc_moncon, 0) = 0
                 AND NVL(icrrcrc, 0) = 0
                 AND NVL(icrrcrc_moncon, 0) = 0
                 AND sproces = psproces;
      ELSIF pmodo = 'P' THEN
         DELETE FROM rrc_rea_sam_previo
               WHERE NVL(iprrcrc, 0) = 0
                 AND NVL(iprrcrc_moncon, 0) = 0
                 AND NVL(icrrcrc, 0) = 0
                 AND NVL(icrrcrc_moncon, 0) = 0
                 AND sproces = psproces;
      END IF;

      COMMIT;
      RETURN(conta_err);
   END f_commit_calcul_rrcreasam;
END pac_provtec_sam;

/

  GRANT EXECUTE ON "AXIS"."PAC_PROVTEC_SAM" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_PROVTEC_SAM" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_PROVTEC_SAM" TO "PROGRAMADORESCSI";
