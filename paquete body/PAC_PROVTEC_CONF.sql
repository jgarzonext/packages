--------------------------------------------------------
--  DDL for Package Body PAC_PROVTEC_CONF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_PROVTEC_CONF" IS
/****************************************************************************
   NOMBRE:       pac_provtec_conf
   PROPÓSITO:    Agrupa las funciones que calculan las provisiones técnicas de Confianza

   REVISIONES:
   Ver   Fecha       Autor  Descripción
   ----- ----------  -----  ------------------------------------------------
   1.0   10/11/2016  ERH    CONF-469 - Parametrizacion Cierres - Administracion y Finanzas - Creación del package
   1.1   27/10/2017  AAB    CONF-403 - Se adiciona en el proceso batch cierre el llamdo a la funcion
                                       pac_contab_conf.f_importe_provision para que realice el insert a las tablas
                                       resumen de provisiones.
****************************************************************************/

   -- cursores para el cálculo de las upr
   CURSOR c_polizas_upr(fecha DATE, empresa NUMBER) IS
      SELECT c.cempres, s.cramo, s.cmodali, s.cduraci, s.nduraci, s.ctipseg, s.ccolect,
             s.sseguro, pac_seguros.ff_get_actividad(s.sseguro, r.nriesgo) cactivi, s.fvencim,
             s.fcaranu, s.fefecto, r.nriesgo, s.cagente, s.npoliza, s.ncertif,
             NVL(p.cramdgs, 0) cramdgs, NVL(c.pgasadm, 0) pgasadm, NVL(c.plimadm, 0) plimadm,
             NVL(c.pgasadq, 0) pgasadq, NVL(c.plimadq, 0) plimadq,
             DECODE(NVL(p.creaseg, 1), 0, 3, DECODE(NVL(s.ctiprea, 1), 2, 2, 0)) csegrea,
             p.sproduc, p.cdivisa cmoneda, pac_monedas.f_cmoneda_t(p.cdivisa) cmoneda_t,
             NVL(s.ndurcob, 0) ndurcob,
             NVL(pac_parametros.f_parproducto_n(s.sproduc, 'PROD_TARIF'),
                 s.sproduc) prod_tarif,
             s.ncuacoa
        FROM productos p, seguros s, riesgos r, codiram c
       WHERE (s.fvencim > fecha
              OR s.fvencim IS NULL)
         AND pac_anulacion.f_anulada_al_emitir(s.sseguro) = 0
         AND 1 = f_situacion_v(s.sseguro, fecha)
         AND (SELECT GREATEST(m2.fefecto, m2.femisio)
                FROM movseguro m2
               WHERE m2.sseguro = s.sseguro
                 AND m2.cmovseg = 0   --Alta
                                   ) < fecha + 1
         --s.fefecto <= fecha
         AND s.csituac <> 4
         AND s.cramo = c.cramo
         AND c.cempres = empresa
         AND p.cramo = s.cramo
         AND p.cmodali = s.cmodali
         AND p.ctipseg = s.ctipseg
         AND p.ccolect = s.ccolect
         AND r.sseguro = s.sseguro
         AND(s.cramo NOT IN(338, 340, 342)   -- 0029299: POS - Cambio de ramos CP y Excequias
             OR(s.cramo = 337
                AND s.cmodali <> 1))   -- VIDA INDIVIDUAL (POS)--bug 25615 --etm-- 17/09/2013
         --AND(s.sproduc IN(6007, 6008, 6006)   --0004135 UAT
          --    OR s.cramo <> 101)   -- 0006003 UAT (bug 24261)
         AND s.cempres = empresa
         AND EXISTS(SELECT 1
                      FROM garanseg g
                     WHERE g.sseguro = r.sseguro
                       AND g.nriesgo = r.nriesgo
                       AND g.iprianu != 0)
         AND r.fefecto <= fecha;

          --------Tasa bomberil terremoto e incendio

          CURSOR c_garantias_tasa_bomberil(fecha DATE, empresa NUMBER) IS
     SELECT  s.sseguro as sseguro,
 r.nrecibo as nrecibo,
 d.cgarant as cgarant,
 s.sproduc as sproduc,
 sum(DECODE(r.ctiprec, 9, -d.iconcep, d.iconcep)) as iprianu,
 sum(DECODE(r.ctiprec, 9, -d.iconcep_monpol, d.iconcep_monpol)) as iprianu_monpol,
 d.fcambio as fcambio

          FROM recibos r, seguros s, codiram c, productos p, detrecibos d, movrecibo m
         WHERE 1 = 1
           AND c.cempres = 24
           AND s.sproduc = p.sproduc
           AND c.cramo = s.cramo
           AND r.sseguro = s.sseguro
           AND d.nrecibo = r.nrecibo
		   AND d.iconcep <> 0
           AND d.cconcep IN(0,50) -- prima neta y cedida
           AND m.nrecibo = r.nrecibo
           AND m.fmovini between  TRUNC(fecha,'MM') and  fecha
           AND(m.fmovfin > fecha
              OR m.fmovfin IS NULL)
           AND r.cestaux IN(0, 1)
           AND m.cestrec in (0,2)
           and m.cestant = 0

           AND r.fefecto <= fecha
           AND r.ctiprec NOT IN
                 ( 13, 15)
           and d.cgarant in (7763, 7695 , 7770, 7774)
           group by R.NRECIBO, S.SSEGURO, D.CGARANT, d.fcambio,  s.sproduc;

   CURSOR c_garantias_upr(
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
               gg.cprovis, g.nriesgo, s.sseguro
          FROM garanpro gg, garanseg g, riesgos r,
               seguros s   -- fem distinció si és o no suplement
         WHERE g.sseguro = wseguro
           AND g.finiefe <= fecha
           AND s.sseguro = g.sseguro   -- fem distinció si és o no suplement
           AND   -- fem distinció si és o no suplement
              (g.ffinefe > fecha
               OR(s.csituac != 5
                  AND g.ffinefe IS NULL)
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
           AND(NVL(gg.cprovis, 1) = 1
-- bug13621 ASN - CEM997 - Controlar que no se generen las PPNC si se calculan las provisiones matemáticas
               OR gg.creaseg IN(1, 4))
-- O se calcula PPNC o tiene reaseguro -- CPM 26/7/06: S'incorpora el tipus 4 (Reaseg. anual de P.U.)
           AND g.iprianu != 0
           AND r.sseguro = g.sseguro
           AND r.fefecto <= fecha
           AND(r.fanulac > fecha
               OR r.fanulac IS NULL)
           AND(g.nriesgo = r.nriesgo
               OR g.nriesgo IS NULL)
           AND fechafin > fecha
      ORDER BY g.cgarant;


   -- cursores para el cálculo de las pplp

   -- BUG 20070 - MAD - 03/01/2012
   -- añadir la tabla sin_tramita_reserva para que vaya a nivel garantía
   CURSOR c_siniestros_pplp(fecha DATE, empresa NUMBER) IS
      SELECT c.cempres, s.cramo, s.cmodali, s.ctipseg, s.ccolect, s.sseguro, s.npoliza,
             s.ncertif, NVL(p.cramdgs, 0) cramdgs, sn.nsinies, p.cdivisa cmoneda,
             pac_monedas.f_cmoneda_t(p.cdivisa) cmoneda_t, str.cgarant, str.ntramit,
             str.ctipres, sn.ccausin
        FROM productos p, seguros s, sin_siniestro sn, sin_movsiniestro m, codiram c,
             sin_tramita_reserva str
       WHERE sn.fsinies <= fecha
         AND(m.cestsin IN(0, 4))
         AND s.sseguro = sn.sseguro
         AND s.cramo = c.cramo
         AND c.cempres = empresa
         AND p.cramo = s.cramo
         AND p.cmodali = s.cmodali
         AND p.ctipseg = s.ctipseg
         AND p.ccolect = s.ccolect
         AND sn.nsinies = m.nsinies
         AND str.nsinies = sn.nsinies
         AND str.nmovres = (SELECT MAX(nmovres)
                              FROM sin_tramita_reserva z
                             WHERE z.nsinies = str.nsinies
                               AND z.fmovres <= fecha)
         AND m.nmovsin = (SELECT MAX(nmovsin)
                            FROM sin_movsiniestro
                           WHERE nsinies = m.nsinies
                             AND festsin <= fecha)
         AND NVL(pac_parametros.f_parempresa_n(s.cempres, 'MODULO_SINI'), 0) = 1;

   ------
   CURSOR c_siniestros_rpti(empresa IN NUMBER, fecha IN DATE) IS
      SELECT c.cempres, s.cramo, s.cmodali, s.ctipseg, s.ccolect, s.sseguro, s.npoliza,
             s.ncertif, NVL(p.cramdgs, 0) cramdgs, sn.nsinies,
             NVL(s.cmoneda, p.cdivisa) cmoneda, st.ntramit, str.ireserva
        FROM productos p, seguros s, sin_siniestro sn, sin_movsiniestro m, codiram c,
             sin_tramitacion st, sin_tramita_reserva str
       WHERE sn.fsinies <= fecha
         AND(m.cestsin IN(0, 4))
         AND s.sseguro = sn.sseguro
         AND s.cramo = c.cramo
         AND c.cempres = empresa
         AND p.cramo = s.cramo
         AND p.cmodali = s.cmodali
         AND p.ctipseg = s.ctipseg
         AND p.ccolect = s.ccolect
         AND sn.nsinies = m.nsinies
         AND st.nsinies = sn.nsinies
         AND str.nsinies = st.nsinies
         AND str.fresini <= fecha
         AND str.fresfin > fecha
         AND m.nmovsin = (SELECT MAX(nmovsin)
                            FROM sin_movsiniestro
                           WHERE nsinies = m.nsinies
                             AND festsin <= fecha);

   CURSOR c_recibos_rtpi(fecha IN DATE, pcempres IN NUMBER) IS
      SELECT c.cempres, s.sseguro, s.sproduc, s.cramo, s.cmodali, s.ctipseg, s.ccolect,
             r.nrecibo, v.itotpri, v.itotimp, v.ipridev, iimp_1 iva, v.iderreg,
             f_cestrec(r.nrecibo, fecha), s.fcaranu, s.fcarpro, s.fvencim
        FROM productos p, seguros s, codiram c, recibos r, vdetrecibos v
       WHERE p.sproduc = s.sproduc
         AND s.sseguro = r.sseguro
         AND c.cramo = s.cramo
         AND c.cempres = pcempres
         AND r.ctiprec <> 9
         AND r.fefecto <= fecha
         AND r.nrecibo = v.nrecibo
         AND r.cestaux = 0
         AND r.fvencim >= fecha;

---------------------------------------
   CURSOR c_recibos_pcc(fecha IN DATE, pcempres IN NUMBER) IS
      SELECT c.cempres, s.sseguro, s.sproduc, s.cramo, s.cmodali, s.ctipseg, s.ccolect,
             r.nrecibo, v.itotpri, v.itotimp, v.ipridev, iimp_1 iva, v.iderreg,
             f_cestrec(r.nrecibo, fecha), s.fcaranu, s.fcarpro, s.fvencim
        FROM productos p, seguros s, codiram c, recibos r, vdetrecibos v
       WHERE p.sproduc = s.sproduc
         AND s.sseguro = r.sseguro
         AND c.cramo = s.cramo
         AND c.cempres = pcempres
         AND r.ctiprec <> 9
         AND r.fefecto <= fecha
         AND r.nrecibo = v.nrecibo
         AND r.cestaux = 0
         AND r.fvencim >= fecha;

   --f_vdetrecibos
   CURSOR c_recibos_ahorro(fecha DATE, empresa NUMBER) IS
      SELECT   p.sproduc, p.cramdgs, s.cramo, s.cmodali, s.ctipseg, s.ccolect, s.sseguro,
               r.nrecibo, d.cgarant, NVL(r.nriesgo, 1) nriesgo, r.nmovimi, r.fefecto,
               SUM(DECODE(cconcep, 0, DECODE(r.ctiprec, 9, -d.iconcep, d.iconcep), 0))
               + SUM(DECODE(cconcep, 8, DECODE(r.ctiprec, 9, -d.iconcep, d.iconcep), 0)) pneta,

               -- consideran prima neta, la prima neta + rec. fracc
               (SUM(DECODE(cconcep, 14, DECODE(r.ctiprec, 9, -d.iconcep, d.iconcep), 0)))
                                                                                       pgastos,

               --Como gastos solo los de  expe
               (SUM(DECODE(cconcep,
                           0, DECODE(r.ctiprec, 9, -d.iconcep_monpol, d.iconcep_monpol),
                           0))
                + SUM(DECODE(cconcep,
                             8, DECODE(r.ctiprec, 9, -d.iconcep_monpol, d.iconcep_monpol),
                             0))) pneta_monpol,
               (SUM(DECODE(cconcep,
                           14, DECODE(r.ctiprec, 9, -d.iconcep_monpol, d.iconcep_monpol),
                           0))) pgastos_monpol,
               SUM(DECODE(cconcep,
                          14, DECODE(r.ctiprec, 9, -d.iconcep, d.iconcep),
                          0)) pgastexp,
               SUM(DECODE(cconcep,
                          14, DECODE(r.ctiprec, 9, -d.iconcep_monpol, d.iconcep_monpol),
                          0)) pgastexp_moncon,
               NVL(c.panula, 100) panula,
               SUM(DECODE(cconcep, 4, DECODE(r.ctiprec, 9,-d.iconcep,d.iconcep), 0)) iva,
               (SUM(DECODE(cconcep, 0, DECODE(r.ctiprec, 9, -d.iconcep, d.iconcep), 0))
                + SUM(DECODE(cconcep, 1, DECODE(r.ctiprec, 9, -d.iconcep, d.iconcep), 0))
                + SUM(DECODE(cconcep, 2, DECODE(r.ctiprec, 9, -d.iconcep, d.iconcep), 0))
                + SUM(DECODE(cconcep, 3, DECODE(r.ctiprec, 9, -d.iconcep, d.iconcep), 0))
                -- + SUM(DECODE(cconcep, 4, DECODE(r.ctiprec, 9,-d.iconcep,d.iconcep), 0))  -- 6 0028444 - QT-8868/0041774 - Quitar concepto IVA(4)
                + SUM(DECODE(cconcep, 5, DECODE(r.ctiprec, 9, -d.iconcep, d.iconcep), 0))
                + SUM(DECODE(cconcep, 6, DECODE(r.ctiprec, 9, -d.iconcep, d.iconcep), 0))
                + SUM(DECODE(cconcep, 7, DECODE(r.ctiprec, 9, -d.iconcep, d.iconcep), 0))
                + SUM(DECODE(cconcep, 8, DECODE(r.ctiprec, 9, -d.iconcep, d.iconcep), 0))
                + SUM(DECODE(cconcep, 14, DECODE(r.ctiprec, 9, -d.iconcep, d.iconcep), 0))
                - SUM(DECODE(cconcep, 13, DECODE(r.ctiprec, 9, -d.iconcep, d.iconcep), 0)))
                                                                                       itotalr,
               (SUM(DECODE(cconcep,
                           0, DECODE(r.ctiprec, 9, -d.iconcep_monpol, d.iconcep_monpol),
                           0))
                + SUM(DECODE(cconcep,
                             1, DECODE(r.ctiprec, 9, -d.iconcep_monpol, d.iconcep_monpol),
                             0))
                + SUM(DECODE(cconcep,
                             2, DECODE(r.ctiprec, 9, -d.iconcep_monpol, d.iconcep_monpol),
                             0))
                + SUM(DECODE(cconcep,
                             3, DECODE(r.ctiprec, 9, -d.iconcep_monpol, d.iconcep_monpol),
                             0))
                -- + SUM(DECODE(cconcep, 4, DECODE(r.ctiprec, 9,-d.iconcep_monpol,d.iconcep_monpol), 0))  -- 6 0028444 - QT-8868/0041774 - Quitar concepto IVA(4)
                + SUM(DECODE(cconcep,
                             5, DECODE(r.ctiprec, 9, -d.iconcep_monpol, d.iconcep_monpol),
                             0))
                + SUM(DECODE(cconcep,
                             6, DECODE(r.ctiprec, 9, -d.iconcep_monpol, d.iconcep_monpol),
                             0))
                + SUM(DECODE(cconcep,
                             7, DECODE(r.ctiprec, 9, -d.iconcep_monpol, d.iconcep_monpol),
                             0))
                + SUM(DECODE(cconcep,
                             8, DECODE(r.ctiprec, 9, -d.iconcep_monpol, d.iconcep_monpol),
                             0))
                + SUM(DECODE(cconcep,
                             14, DECODE(r.ctiprec, 9, -d.iconcep_monpol, d.iconcep_monpol),
                             0))
                - SUM(DECODE(cconcep, 13, DECODE(r.ctiprec, 9, -d.iconcep, d.iconcep), 0)))
                                                                                itotalr_monpol,
               SUM(DECODE(cconcep,
                          50, DECODE(r.ctiprec, 9, -d.iconcep, d.iconcep),
                          0))
               + SUM(DECODE(cconcep, 58, DECODE(r.ctiprec, 9, -d.iconcep, d.iconcep), 0))
                                                                                     pneta_coa,

               -- consideran prima neta, la prima neta + rec. fracc
               (SUM(DECODE(cconcep, 64, DECODE(r.ctiprec, 9, -d.iconcep, d.iconcep), 0)))
                                                                                   pgastos_coa,

               --Como gastos solo los de  expe
               (SUM(DECODE(cconcep,
                           50, DECODE(r.ctiprec, 9, -d.iconcep_monpol, d.iconcep_monpol),
                           0))
                + SUM(DECODE(cconcep,
                             58, DECODE(r.ctiprec, 9, -d.iconcep_monpol, d.iconcep_monpol),
                             0))) pneta_monpol_coa,
               (SUM(DECODE(cconcep,
                           64, DECODE(r.ctiprec, 9, -d.iconcep_monpol, d.iconcep_monpol),
                           0))) pgastos_monpol_coa,
               SUM(DECODE(cconcep,
                          64, DECODE(r.ctiprec, 9, -d.iconcep, d.iconcep),
                          0)) pgastexp_coa,
               SUM(DECODE(cconcep,
                          64, DECODE(r.ctiprec, 9, -d.iconcep_monpol, d.iconcep_monpol),
                          0)) pgastexp_moncon_coa,
               (SUM(DECODE(cconcep, 50, DECODE(r.ctiprec, 9, -d.iconcep, d.iconcep), 0))
                + SUM(DECODE(cconcep, 51, DECODE(r.ctiprec, 9, -d.iconcep, d.iconcep), 0))
                + SUM(DECODE(cconcep, 52, DECODE(r.ctiprec, 9, -d.iconcep, d.iconcep), 0))
                + SUM(DECODE(cconcep, 53, DECODE(r.ctiprec, 9, -d.iconcep, d.iconcep), 0))
                + SUM(DECODE(cconcep, 54, DECODE(r.ctiprec, 9, -d.iconcep, d.iconcep), 0))
                + SUM(DECODE(cconcep, 55, DECODE(r.ctiprec, 9, -d.iconcep, d.iconcep), 0))
                + SUM(DECODE(cconcep, 56, DECODE(r.ctiprec, 9, -d.iconcep, d.iconcep), 0))
                + SUM(DECODE(cconcep, 57, DECODE(r.ctiprec, 9, -d.iconcep, d.iconcep), 0))
                + SUM(DECODE(cconcep, 58, DECODE(r.ctiprec, 9, -d.iconcep, d.iconcep), 0))
                + SUM(DECODE(cconcep, 64, DECODE(r.ctiprec, 9, -d.iconcep, d.iconcep), 0))
                - SUM(DECODE(cconcep, 63, DECODE(r.ctiprec, 9, -d.iconcep, d.iconcep), 0)))
                                                                                   itotalr_coa,
               (SUM(DECODE(cconcep,
                           50, DECODE(r.ctiprec, 9, -d.iconcep_monpol, d.iconcep_monpol),
                           0))
                + SUM(DECODE(cconcep,
                             51, DECODE(r.ctiprec, 9, -d.iconcep_monpol, d.iconcep_monpol),
                             0))
                + SUM(DECODE(cconcep,
                             52, DECODE(r.ctiprec, 9, -d.iconcep_monpol, d.iconcep_monpol),
                             0))
                + SUM(DECODE(cconcep,
                             53, DECODE(r.ctiprec, 9, -d.iconcep_monpol, d.iconcep_monpol),
                             0))
                + SUM(DECODE(cconcep,
                             54, DECODE(r.ctiprec, 9, -d.iconcep_monpol, d.iconcep_monpol),
                             0))
                + SUM(DECODE(cconcep,
                             55, DECODE(r.ctiprec, 9, -d.iconcep_monpol, d.iconcep_monpol),
                             0))
                + SUM(DECODE(cconcep,
                             56, DECODE(r.ctiprec, 9, -d.iconcep_monpol, d.iconcep_monpol),
                             0))
                + SUM(DECODE(cconcep,
                             57, DECODE(r.ctiprec, 9, -d.iconcep_monpol, d.iconcep_monpol),
                             0))
                + SUM(DECODE(cconcep,
                             58, DECODE(r.ctiprec, 9, -d.iconcep_monpol, d.iconcep_monpol),
                             0))
                + SUM(DECODE(cconcep,
                             64, DECODE(r.ctiprec, 9, -d.iconcep_monpol, d.iconcep_monpol),
                             0))
                - SUM(DECODE(cconcep, 63, DECODE(r.ctiprec, 9, -d.iconcep, d.iconcep), 0)))
                                                                            itotalr_monpol_coa,
               r.fvencim, s.fcaranu, p.cdivisa cmoneda, r.ncuacoa
          FROM recibos r, seguros s, codiram c, productos p, detrecibos d, movrecibo m
         WHERE 1 = 1
           --f_prod_ahorro(p.sproduc) = 1-- nos piden que sean todos los recibos
           AND c.cempres = empresa
           AND s.sproduc = p.sproduc
           AND c.cramo = s.cramo
           AND r.sseguro = s.sseguro
           AND d.nrecibo = r.nrecibo
		   AND d.iconcep <> 0        -- Bug 41904 - ACL 27/04/2016
           AND d.cconcep IN(0, 1, 2, 3, 4, 5, 6, 7, 8, 13, 14   --)
                                                             , 50, 51, 52, 53, 54, 55, 56, 57,
                            58, 63, 64)
           -- Prima neta ,contribuciones soat,der. registro,iva,tunt I de mora
           AND m.nrecibo = r.nrecibo
           AND m.fmovini <= fecha
-- IPH 35419 + NVL(pac_parametros.f_parproducto_n(s.sproduc, 'DIAS_PPPC'), 0)
           AND(m.fmovfin > fecha
-- IPH 35419 + NVL(pac_parametros.f_parproducto_n(s.sproduc, 'DIAS_PPPC'), 0)
               OR m.fmovfin IS NULL)
           AND r.cestaux IN(0, 1)
           AND(m.cestrec = 0
               OR(m.cestrec = 1
                  AND DECODE(NVL(m.ctipcob, -1),
                             /*BUG 0010676: 22/09/2009 : NMM -- CEM - Substituïm el paràmetre de rebut pel de companyia */
                             -1, m.fmovini + pac_adm.f_get_diasgest(r.cempres),
                             m.fmovini) > fecha
-- IPH 35419 +               + NVL(pac_parametros.f_parproducto_n(s.sproduc,'DIAS_PPPC'),0)
                 ))
           AND r.fefecto <= fecha
-- IPH 35419 +           + NVL(pac_parametros.f_parproducto_n(s.sproduc, 'DIAS_PPPC'), 0)
           -- excluimos recibos de ahorro
           AND r.ctiprec NOT IN
                 (9, 13, 15)   --No es un extorno (9), ni los retornos (13) ni los recobros de retornos (15) --BUG 35149
           --AND NVL(pac_adm.f_es_recibo_riesgo(r.nrecibo), 0) <> 1
           AND NVL(pac_adm.f_es_recibo_ahorro(r.nrecibo), 0) <> 1   --javendano bug 35149/202596
      GROUP BY p.sproduc, p.cramdgs, s.cramo, s.cmodali, s.ctipseg, s.ccolect, s.sseguro,
               r.nrecibo, d.cgarant, NVL(r.nriesgo, 1), r.nmovimi, r.fefecto,
               NVL(c.panula, 100), r.fvencim, s.fcaranu, p.cdivisa, r.ncuacoa
      ORDER BY p.sproduc, p.cramdgs, s.cramo, s.cmodali, s.ctipseg, s.ccolect, s.sseguro,
               r.nrecibo, d.cgarant, NVL(r.nriesgo, 1), r.nmovimi;

   FUNCTION f_provision_vigente(pcprovis IN NUMBER, pfcierre IN DATE, pcempres IN NUMBER)
      RETURN NUMBER IS
      v_vigente      NUMBER;
   BEGIN
      SELECT COUNT(*)
        INTO v_vigente
        FROM codprovi_emp
       WHERE cprovis = pcprovis
         AND cempres = pcempres
         AND(fbaja IS NULL
             OR fbaja > pfcierre);

      RETURN v_vigente;
   END f_provision_vigente;

   PROCEDURE proceso_batch_cierre(
      pmodo IN NUMBER,
      pcempres IN NUMBER,
      pmoneda IN NUMBER,
      pcidioma IN NUMBER,
      pfperini IN DATE,
      pfperfin IN DATE,
      pfcierre IN DATE,
      pcerror OUT NUMBER,
      psproces OUT NUMBER,
      pfproces OUT DATE) IS
--
--    Proceso que lanzará el proceso de cierre de provisiones
--
-- 15/9/04 CPM: Se añaden parámetros a la llamada, aunque no son necesarios
--      para que sea compatible con el resto de cierres programados.
      num_err        NUMBER := 0;
      text_error     VARCHAR2(500) := 0;
      pnnumlin       NUMBER;
      texto          VARCHAR2(400);
      conta_err      NUMBER := 0;
      v_titulo       VARCHAR2(50);
      xmodo          VARCHAR2(1);
      xmetodo        NUMBER(1) := 0;
   BEGIN
      IF pmodo = 1 THEN
         v_titulo := 'Proceso Cierre Diario (empresa ' || pcempres || ')';
         xmodo := 'P';
      ELSE
         v_titulo := 'Proceso Cierre Mensual';
         xmodo := 'R';
      END IF;

      --Insertamos en la tabla PROCESOSCAB el registro identificativo de proceso -----
      num_err := f_procesini(f_user, pcempres, 'PROVISIONES', v_titulo, psproces);
      COMMIT;

      IF num_err <> 0 THEN
         pcerror := 1;
         conta_err := conta_err + 1;
         texto := f_axis_literales(num_err, pcidioma);
         pnnumlin := NULL;
         num_err := f_proceslin(psproces,
                                SUBSTR('Provisiones ' || texto || ' ' || text_error, 1, 120),
                                0, pnnumlin);
         COMMIT;
      ELSE
         pcerror := 0;

         -- Borrado de los registros que se corresponden al mes y empresa que vamos a tratar
         BEGIN
            IF pmodo = 1 THEN
               -- Bug 0022072 - 30/04/2012 - JMF
               DELETE FROM prov_amocom_previo r
                     WHERE r.fcalcul = pfperfin
                       AND r.cempres = pcempres;

               COMMIT;

               DELETE FROM upr_previo r
                     WHERE r.fcalcul = pfperfin
                       AND r.cempres = pcempres;

               COMMIT;

               /*
               DELETE FROM ptpplp_lcol_previo r
                     WHERE r.fcalcul = pfperfin
                       AND r.cempres = pcempres;

               COMMIT;
               */
               DELETE FROM pppc_conf_previ r
                     WHERE r.fcalcul = pfperfin
                       AND r.cempres = pcempres;

               COMMIT;

                DELETE FROM pppc_conf_oct_previ r
                     WHERE r.fcalcul = pfperfin
                       AND r.cempres = pcempres;

               COMMIT;

               /*
               DELETE FROM pppc_pos_matriz_previ r
                     WHERE r.fcalcul = pfperfin
                       AND r.cempres = pcempres;

               COMMIT;
               */
               DELETE FROM provmat_previo r
                     WHERE r.fcalcul = pfperfin
                       AND r.cempres = pcempres;

               COMMIT;

               DELETE FROM pbex_previo p
                     WHERE p.fcalcul = pfperfin
                       AND p.cempres = pcempres;

               COMMIT;
            -- FIN BUG 20070 - MAD - 03/01/2012

            DELETE FROM TASA_BOMBERIL_PREVIO r
                     WHERE r.FCALCUL = pfperfin;

               COMMIT;

            ELSE
               -- Bug 0022072 - 30/04/2012 - JMF
               DELETE FROM prov_amocom r
                     WHERE r.fcalcul = pfperfin
                       AND r.cempres = pcempres;

               COMMIT;

               DELETE FROM upr r
                     WHERE r.fcalcul = pfperfin
                       AND r.cempres = pcempres;

               COMMIT;

               /*
               DELETE FROM ptpplp_lcol r
                     WHERE r.fcalcul = pfperfin
                       AND r.cempres = pcempres;

               COMMIT;
               */

               DELETE FROM pppc_conf r
                     WHERE r.fcalcul = pfperfin
                       AND r.cempres = pcempres;

               COMMIT;

               DELETE FROM pppc_conf_oct r
                     WHERE r.fcalcul = pfperfin
                       AND r.cempres = pcempres;

               COMMIT;

               /*
               DELETE FROM pppc_pos_matriz r
                     WHERE r.fcalcul = pfperfin
                       AND r.cempres = pcempres;

               COMMIT;
               */
               DELETE FROM provmat r
                     WHERE r.fcalcul = pfperfin
                       AND r.cempres = pcempres;

               COMMIT;

               DELETE FROM pbex p
                     WHERE p.fcalcul = pfperfin
                       AND p.cempres = pcempres;

               COMMIT;

               -- FIN BUG 20070 - MAD - 03/01/2012
               DELETE FROM ibnr_sam_facajus
                                           --WHERE fcalcul = pfperfin
               ;

               COMMIT;

               DELETE FROM ibnr_sam_siniestros
                                              -- WHERE fcalcul = pfperfin
               ;

               COMMIT;

               DELETE FROM ibnr_sam_sinacuml
                                            -- WHERE fcalcul = pfperfin
               ;

               COMMIT;

               DELETE FROM ibnr_sam_sinajus
                                           --WHERE fcalcul = pfperfin
               ;

               COMMIT;

               DELETE FROM ibnr_sam_sinacumajus
                                               --WHERE fcalcul = pfperfin
               ;

               COMMIT;

               DELETE FROM ibnr_sam_factdesa
                                            --WHERE fcalcul = pfperfin
               ;

               COMMIT;

               DELETE FROM ibnr_sam_tabdesa
                                           --WHERE fcalcul = pfperfin
               ;

               COMMIT;

               DELETE FROM ibnr_sam_facdesa_acum
                                                --WHERE fcalcul = pfperfin
               ;

               COMMIT;

               DELETE FROM ibnr_sam_upe
                                       --WHERE fcalcul = pfperfin
               ;

               COMMIT;

               DELETE FROM ibnr_sam_sin_pend
                                            --WHERE fcalcul = pfperfin
               ;

               COMMIT;

               DELETE FROM ibnr_sam_pdesacu
                                           --WHERE fcalcul = pfperfin
               ;

               COMMIT;

               DELETE FROM ibnr_sam_sin_papag
                                             --WHERE fcalcul = pfperfin
               ;

               COMMIT;

            DELETE FROM TASA_BOMBERIL r
                     WHERE r.FCALCUL = pfperfin;

               COMMIT;

            --DELETE FROM ibnr_sam_facdesa
                  --WHERE fcalcul = pfperfin;

            --COMMIT;

            --DELETE FROM ibnr_sam
                  --WHERE fcalcul = pfperfin;

            --COMMIT;
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, 'CIERRE PROVISIONES MAT PROCESO =' || psproces,
                           NULL, 'when others del delete del cierre =' || pfperfin, SQLERRM);
         END;

         -- Ejecutamos provisiones técnicas.
         -- La funciones en num_err, nos devuelven el número de errores que se han producido en el
         -- cálculo. Grabamos este número en el campo CERROR de CTRL_PROVIS.
         -- Ahora el cálculo de las provisiones PPNC y LDG se ejecuta a la vez, con lo cual sólo
         -- tenemos un registro de CTRL_PROVIS de control con el código 1
         IF f_provision_vigente(20, pfcierre, pcempres) = 1 THEN   -- sólo se calculan las provisiones que están pendientes
            num_err := pac_provtec_conf.f_commit_calcul_upr(pcempres, pfperfin, psproces,
                                                           pcidioma, pmoneda, xmodo);

            IF num_err <> 0 THEN
               conta_err := conta_err + 1;
               pcerror := 1;
            END IF;

            INSERT INTO ctrl_provis
                        (cempres, fcalcul, fmodifi, cprovis, sproces, cusuari, cerror)
                 VALUES (pcempres, pfperfin, f_sysdate, 20, psproces, f_user, pcerror);

            COMMIT;

            INSERT INTO ctrl_provis
                        (cempres, fcalcul, fmodifi, cprovis, sproces, cusuari, cerror)
                 VALUES (pcempres, pfperfin, f_sysdate, 13, psproces, f_user, pcerror);

            COMMIT;
         END IF;

         /*
         -- Las PPLP y PPPC (matriz) no se calcularán incialmente para POSITIVA, aunque la función "f_provision_vigente"
         -- impediría su ejecución, se comentan porque hacen servir tablas _LCOL.

         IF f_provision_vigente(21, pfcierre, pcempres) = 1 THEN   -- sólo se calculan las provisiones que están pendientes
            num_err := pac_provtec_conf.f_commit_calcul_pplp(pcempres, pfperfin, psproces,
                                                             pcidioma, pmoneda, xmodo);

            IF num_err <> 0 THEN
               conta_err := conta_err + 1;
               pcerror := 1;
            END IF;

            INSERT INTO ctrl_provis
                        (cempres, fcalcul, fmodifi, cprovis, sproces, cusuari, cerror)
                 VALUES (pcempres, pfperfin, f_sysdate, 21, psproces, f_user, pcerror);

            COMMIT;
         END IF;
         */

         -- Ejecutamos provisiones no técnicas
         IF f_provision_vigente(22, pfcierre, pcempres) = 1 THEN   -- sólo se calculan las provisiones que están pendientes

            -- Meodo de provision de cartera con negativos. 1 detvalores 8001176
            xmetodo := 1;
            num_err := pac_provtec_conf.f_commit_calcul_pppc_pd(pcempres, pfperfin, psproces,
                                                            pcidioma, pmoneda, xmodo, xmetodo);

            -- Meodo de provision de cartera sin  negativos. 2 8001176  8001176
            xmetodo := 2;
            num_err := pac_provtec_conf.f_commit_calcul_pppc_pd(pcempres, pfperfin, psproces,
                                                            pcidioma, pmoneda, xmodo, xmetodo);

            IF num_err <> 0 THEN
               conta_err := conta_err + 1;
               pcerror := 1;
            END IF;

            INSERT INTO ctrl_provis
                        (cempres, fcalcul, fmodifi, cprovis, sproces, cusuari, cerror)
                 VALUES (pcempres, pfperfin, f_sysdate, 22, psproces, f_user, pcerror);

            -- BUG 20070 - MAD - 03/01/2012
            -- tener en cuenta la provisión 23
            INSERT INTO ctrl_provis
                        (cempres, fcalcul, fmodifi, cprovis, sproces, cusuari, cerror)
                 VALUES (pcempres, pfperfin, f_sysdate, 23, psproces, f_user, pcerror);

            COMMIT;
         END IF;

         -- ini Bug 0022072 - 30/04/2012 - JMF
         IF f_provision_vigente(28, pfcierre, pcempres) = 1 THEN   -- sólo se calculan las provisiones que están pendientes
            num_err := pac_provtec_conf.f_commit_calcul_amocom(pcempres, pfperfin, psproces,
                                                              pcidioma, pmoneda, xmodo);

            IF num_err <> 0 THEN
               conta_err := conta_err + 1;
               pcerror := 1;
            END IF;

            INSERT INTO ctrl_provis
                        (cempres, fcalcul, fmodifi, cprovis, sproces, cusuari, cerror)
                 VALUES (pcempres, pfperfin, f_sysdate, 28, psproces, f_user, pcerror);

            COMMIT;
         END IF;

         -- fin Bug 0022072 - 30/04/2012 - JMF
         IF f_provision_vigente(99, pfcierre, pcempres) = 1 THEN
            -- sólo se calculan las provisiones que están pendientes
              -- Ejecutamos provisiones relacionadas con la tabla de mortalidad
            num_err := pac_provmat_formul.f_commit_calcul_pm_formul(pcempres, pfperfin,
                                                                    psproces, pcidioma,
                                                                    pmoneda, xmodo);

              --num_err := pac_provimat_pbex.f_commit_provmat(pcempres, pfcierre, psproces,
            --        pcidioma, pmoneda);
            IF num_err <> 0 THEN
               conta_err := conta_err + 1;
               pcerror := 1;
            END IF;

            INSERT INTO ctrl_provis
                        (cempres, fcalcul, fmodifi, cprovis, sproces, cusuari, cerror)
                 VALUES (pcempres, pfperfin, f_sysdate, 99, psproces, f_user, pcerror);

            COMMIT;
         END IF;

         IF f_provision_vigente(25, pfcierre, pcempres) = 1 THEN   -- sólo se calculan las provisiones que están pendientes
            num_err := pac_provtec_conf.f_commit_calcul_ibnr(pcempres, pfperfin, psproces,
                                                            pcidioma, pmoneda, xmodo);

            IF num_err <> 0 THEN
               conta_err := conta_err + 1;
               pcerror := 1;
            END IF;

            INSERT INTO ctrl_provis
                        (cempres, fcalcul, fmodifi, cprovis, sproces, cusuari, cerror)
                 VALUES (pcempres, pfperfin, f_sysdate, 25, psproces, f_user, pcerror);

            COMMIT;
         END IF;

         IF f_provision_vigente(11, pfcierre, pcempres) = 1 THEN   -- sólo se calculan las provisiones que están pendientes
            num_err := pac_provimat_pbex.f_commit_pbex(pcempres, pfperfin, psproces, pcidioma,
                                                       pmoneda, xmodo);

            IF num_err <> 0 THEN
               conta_err := conta_err + 1;
               pcerror := 1;
            END IF;

            INSERT INTO ctrl_provis
                        (cempres, fcalcul, fmodifi, cprovis, sproces, cusuari, cerror)
                 VALUES (pcempres, pfperfin, f_sysdate, 11, psproces, f_user, pcerror);

            COMMIT;
         END IF;

         IF f_provision_vigente(39, pfcierre, pcempres) = 1 THEN   -- sólo se calculan las provisiones que están pendientes

             -- Meodo de provision de cartera con negativos. 1
             xmetodo := 1;
             num_err := pac_provtec_conf.f_commit_calcul_pppc_pd(pcempres, pfperfin, psproces,
                                                            pcidioma, pmoneda, xmodo, xmetodo);

             -- Meodo de provision de cartera sin negativos. 2
             xmetodo := 2;
             num_err := pac_provtec_conf.f_commit_calcul_pppc_pd(pcempres, pfperfin, psproces,
                                                            pcidioma, pmoneda, xmodo, xmetodo);

            IF num_err <> 0 THEN
               conta_err := conta_err + 1;
               pcerror := 1;
            END IF;

            INSERT INTO ctrl_provis
                        (cempres, fcalcul, fmodifi, cprovis, sproces, cusuari, cerror)
                 VALUES (pcempres, pfperfin, f_sysdate, 39, psproces, f_user, pcerror);

            COMMIT;
         END IF;


                IF f_provision_vigente(41, pfcierre, pcempres) = 1 THEN   -- sólo se calculan las provisiones que están pendientes


             num_err := pac_provtec_conf.f_commit_calcul_tasabomberil(pcempres, pfperfin, psproces,
                                                            pcidioma, pmoneda, xmodo, pfcierre);



            IF num_err <> 0 THEN
               conta_err := conta_err + 1;
               pcerror := 1;
            END IF;

            INSERT INTO ctrl_provis
                        (cempres, fcalcul, fmodifi, cprovis, sproces, cusuari, cerror)
                 VALUES (pcempres, pfperfin, f_sysdate, 41, psproces, f_user, pcerror);

            COMMIT;
         END IF;


         -- METODO DE OCTAVOS-
         IF f_provision_vigente(40, pfcierre, pcempres) = 1 THEN   -- sólo se calculan las provisiones que están pendientes


            num_err := pac_provtec_conf.f_commit_calcul_pppc_oct(pcempres, pfperfin, psproces,
                                                            pcidioma, pmoneda, xmodo);

            IF num_err <> 0 THEN
               conta_err := conta_err + 1;
               pcerror := 1;
            END IF;

            INSERT INTO ctrl_provis
                        (cempres, fcalcul, fmodifi, cprovis, sproces, cusuari, cerror)
                 VALUES (pcempres, pfperfin, f_sysdate, 40, psproces, f_user, pcerror);

            COMMIT;
         END IF;



      END IF;

      num_err := f_procesfin(psproces, conta_err);
      pfproces := f_sysdate;
      pcerror := 0;
      COMMIT;
      -- Version 1.1
      -- Realiza el llamado para el insert a la tabla SUC_PPPC_RESU
      FOR c_ins_res IN (SELECT DISTINCT pac_contab_conf.f_division(p.sseguro,NULL) sucursal,p.fcalcul fecha
                          FROM PPPC_CONF p
                         WHERE p.sproces = psproces)  LOOP
         --
         num_err := pac_contab_conf.f_importe_provision(p_sproces => psproces,p_tip_provisi => 1,
                                                        p_fech_cierre => c_ins_res.fecha,p_sucursal => c_ins_res.sucursal);
         --
      END LOOP;
      -- Realiza el llamado para el insert a la tabla SUC_PPPC_OCTO_RESU
      FOR c_oct_res IN (SELECT DISTINCT pac_contab_conf.f_division(p.sseguro,NULL) sucursal,p.fcalcul fecha
                          FROM PPPC_CONF_OCT p
                         WHERE p.sproces = psproces)  LOOP
         --
         num_err := pac_contab_conf.f_importe_provision(p_sproces => psproces,p_tip_provisi => 2,
                                                        p_fech_cierre => c_oct_res.fecha,p_sucursal => c_oct_res.sucursal);
         --
      END LOOP;
      -- Version 1.1
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'CIERRE PROVISIONES MAT PROCESO =' || psproces, NULL,
                     'when others del cierre =' || pfperfin, SQLERRM);
         pcerror := 1;
   END proceso_batch_cierre;

   FUNCTION f_commit_calcul_upr(
      pcempres IN NUMBER,
      aux_factual IN DATE,
      psproces IN NUMBER,
      pcidioma IN NUMBER,
      pcmoneda IN NUMBER,
      pmodo IN VARCHAR2 DEFAULT 'R')
      RETURN NUMBER IS
      -- {  declaració de variables necessaries pel proces}
      -- control de error
      conta_err      NUMBER := 0;
      num_err        NUMBER := 0;
      -- Fechas
      wfini          DATE;   -- fecha inicio vigencia
      wffin          DATE;   -- fecha final vigencia
      wfact          DATE := aux_factual;
                                                              -- fecha actual
      -- Variables auxiliares
      wprorrata      NUMBER;   -- prorrata aplicada
      wcmodcom       NUMBER;   --  modo comision
      wnlinea        NUMBER;   -- linea del procesoslin
      wreasingarant  NUMBER;
      -- semaforo para marcar que se asigna todo el reaseguro a la 1ª garantia
      wpretenc       NUMBER;
      -- Variables de tipo texto
      wtexto         literales.tlitera%TYPE;
      -- Valores a calcular
      wgupr          NUMBER := 0;
      -- Reserva de riesgo en curso para la prima emitida bruta
      wga            NUMBER := 0;
      --  gastos de adquisición  causados en el momento de la emisión
      wk1            NUMBER;   -- Porcentaje del gasto de adquisición
      wfrr           NUMBER;   --NUMBER;
      --Factor de regimen de reservas, se recupera de la empresa
      wfrpt          NUMBER;   -- Factor de riesgo por transcurrir
      wgwp           NUMBER;   -- Prima emitida bruta
      wcupr          NUMBER;
      wcupr_moncon   NUMBER;
      -- 19. 26642 / 0141943 - Inicio -- 3.0   05/07/2013  MMM Igualar código con PAC_PROVTEC_LCOL
      vicupr_t       NUMBER;
      vicupr_moncon_t NUMBER;
      vicupr_2       NUMBER;
      vicupr_moncon_2 NUMBER;
      -- 19. 26642 / 0141943 - Final -- 3.0   05/07/2013  MMM Igualar código con PAC_PROVTEC_LCOL
      -- Reserva de riesgo en curso de la prima cedida  en Rea. proporcional
      wcwp           NUMBER;   -- Prima cedida en reaseguro proporcional
      wnupr          NUMBER;
      --  Reserva de riesgo rn curso para la prime neta de  Rea. proporcional
      wturp          NUMBER;
      -- Reserva de desviación  de sinistralidad para el  reamo de terremoto
      warpdsupr      NUMBER;
      -- Reserva de desviación de sinistralidad para el ramo ARP. *
      warpupr        NUMBER;
      -- Reserva de enfermedades de sinistralidad para el ramo ARP.*
      wnep           NUMBER;   -- prima neta devengada del reaseguro
      wtnwp          NUMBER;
      -- Prima neta de reaseguro proporcional a la cobertura de terremoto *
      wqgwp          NUMBER;
      -- prmia bruta emitida en el último trimestres **
      wogwp          NUMBER := 0;
      --valores entre el gwp y qgwp *
      wqcwp          NUMBER := 0;
      --  Prima cedida en rea. propoccional en el ult. trimestre **
      wocwp          NUMBER := 0;
      -- valores entre el cwp y el cgwp *
      wcc            NUMBER := 0;
      --provisión para la camara de compensacion, distribuiad por ADN y sucurusal*
      wc             NUMBER;   -- Porcentaje de comisión básica
      wdac           NUMBER := 0;
      -- Coste de adquisicuib diferido*
      wdacadn        NUMBER := 0;
      -- Coste de adquisicuib diferido pagado a la ADN*
      wrdac          NUMBER := 0;
      -- Coste de adquisicuib diferido para la comis recibida*
      wfre           NUMBER := 0;
                     -- Factor de regimen especial, por ramo y con vigencias*
      --{variables  de campos no necesarios fase 0}
      wpcf           NUMBER := 0;
      --Param  porcentaje de constribución FOSYGA *
      wk             NUMBER := 0;
      --Param para el porcentaj de ARPURP *
      wj             NUMBER := 0;
      --Param para el porcentaj de ARPDSUPR *
      wr             NUMBER := 0;
      --Param para el porcentaj de TURP *
      waupr          NUMBER;   -- Ajuste GAAP para la GURP *
      wasupr         NUMBER;   -- Ajuste GAAP para la GURP de SOAT *
      wareupr        NUMBER;
-- Ajuste GAAP sobre la GUPR de  los ramos con Regimes Especiales de reserva.*
      wcadn          NUMBER := 0;
-- Porcentaje pàgado a ala ADN ( no es fase 0, porque se aplica despues del primer año)*
      wfprtre        NUMBER := 1;
--**** Factor por  riesgo a transcurrir puede ser uno o el valor que establezca el usuario
      pfcambio       DATE;   -- Fecha del cambio vigente a la fecha actual
      witasa         NUMBER(15, 2);   -- Tasa vigente
      wprimanivel    NUMBER := 0;
      wcresp43       NUMBER;
      wcresp27       NUMBER;
      -- BUG 20070/107545 - 20/02/2012 - JMP - Añadir contravalores en la moneda de la contabilidad
      w_cmoncon      parempresas.nvalpar%TYPE
                                    := pac_parametros.f_parempresa_n(pcempres, 'MONEDACONTAB');
      -- Moneda de contablidad (numérico)
      w_cmoncon_t    monedas.cmonint%TYPE := pac_monedas.f_cmoneda_t(w_cmoncon);
                                             -- Moneda de contablidad (texto)
      -- FIN BUG 20070/107545 - 20/02/2012 - JMP - Añadir contravalores en la moneda de la contabilidad

      -- Ini Bug 21550 - MDS - 29/02/2012
      w_icage        upr.icage%TYPE := 0;
      w_icadn        upr.icadn%TYPE := 0;
      w_icage_nc     upr.icage_nc%TYPE := 0;
      w_icadn_nc     upr.icadn_nc%TYPE := 0;
-- Fin Bug 21550 - MDS - 29/02/2012
-- Bug 0023130 - DCG - 28/01/2013 - LCOL_F002-Provisiones para polizas estatales
      xploccoa       NUMBER;
      w_icage_coa    upr.icage%TYPE := 0;
      w_icadn_coa    upr.icadn%TYPE := 0;
      w_icage_nc_coa upr.icage_nc%TYPE := 0;
      w_icadn_nc_coa upr.icadn_nc%TYPE := 0;
-- Fin Bug 0023130 - DCG - 28/01/2013
   BEGIN
      -- wfrr := NVL(pac_parametros.f_parempresa_n(pcempres, 'FACT_RES'), 1);----bug 25615 --etm-- 17/09/2013
      FOR reg IN c_polizas_upr(aux_factual, pcempres) LOOP
		Wfrr := NVL ((pac_subtablas.f_detalle_valor_din(pcempres, 3317206, reg.fefecto, 3, 1, reg.sproduc)) ,
                        (NVL (TO_NUMBER(pac_parametros.f_parproducto_t(reg.sproduc, 'FACT_RES'), '9999.999'), 1))
                      );
         -- {obtenemos las fechas de inicio y fin }
         num_err := f_fechainifin(reg.sseguro, wfact, reg.fvencim, reg.fcaranu, wffin, wfini,
                                  wprorrata, wcmodcom);
         wprorrata := 1;

         IF num_err != 0 THEN
            wtexto := f_axis_literales(num_err, pcidioma);
            num_err := f_proceslin(psproces, wtexto || ' -UPR', reg.sseguro, wnlinea);
            wnlinea := NULL;
            num_err := 104349;
         END IF;

         IF num_err = 0 THEN
            -- Por cada póliza , inicializamos las variables a calcular
            wgupr := 0;
            wga := 0;
            wfrpt := 0;
            wcupr := 0;
            wcwp := 0;
            wreasingarant := 0;

            --  wk1 := reg.pgasadq;   -- % de los gastos de adquisición
            FOR gar IN c_garantias_upr(reg.sseguro, reg.cramo, reg.cmodali, reg.ctipseg,
                                       reg.ccolect, wfact, wffin, reg.nriesgo) LOOP
               wprimanivel := 0;

               /*
               -- 6006 - INDIVIDUAL PAGAMENTS PERMANENTS (DOLARS)
               -- 6006 - No es un producto de POSITIVA
               IF reg.sproduc = 6006 THEN
                  BEGIN
                     SELECT crespue   --0 DIFERENCIA DE PRIMA
                       INTO wprimanivel
                       FROM pregungaranseg
                      WHERE sseguro = reg.sseguro
                        AND cgarant = gar.cgarant
                        AND nriesgo = gar.nriesgo
                        AND nmovimi = gar.nmovimi
                        AND cpregun = 4045;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        wprimanivel := 1;
                  END;
               ELSE
                  wprimanivel := 0;
               END IF;
               */
               IF wprimanivel = 0 THEN
                  IF num_err = 0 THEN
                     IF (wffin - wfini) = 0 THEN
                        num_err := 105981;
                     ELSE
                        num_err := f_pcomisi(reg.sseguro, wcmodcom, wfact, wc, wpretenc,
                                             reg.cagente, reg.cramo, reg.cmodali, reg.ctipseg,
                                             reg.ccolect, reg.cactivi, gar.cgarant);
                     END IF;
                  END IF;

                  IF num_err = 0 THEN
                     IF reg.csegrea = 0
                        AND gar.cgarrea = 0 THEN   -- Tenemos Reaseguro
                        BEGIN
                           -- Calculem la cesió anual i no la fraccionada (a nivell de rebut). Per això necessitem
                           --  la taula CESIONESREA, pero el pcomisi, només està a nivell de companyia per lo qual
                           --  ens veiem obligats a calcularlo
                           SELECT SUM(icesion)   --, SUM(icomisi),
                              --SUM(icesion *((fvencim - aux_factual) /(fvencim - fefecto))),
                             -- SUM(icomisi *((fvencim - aux_factual) /(fvencim - fefecto)))
                           INTO   wcwp   --, wcomtotreaced_gar,
                              --wprimnoconsreaced_gar,
                             -- wcomnocons_gar
                           FROM   reaseguro r
                            WHERE r.sseguro = reg.sseguro
                              AND r.fefecto <= aux_factual
                              AND r.fvencim > aux_factual
                              AND r.nriesgo = reg.nriesgo
                              AND r.ctramo <> 0
                              AND(r.cgarant = gar.cgarant
                                  OR(wreasingarant = 0
                                     AND NVL(r.cgarant, 0) = 0));
                        EXCEPTION
                           WHEN OTHERS THEN
                              wcwp := 0;
                        -- wcomtotreaced_gar := 0;
                        -- wprimnoconsreaced_gar := 0;
                        -- wcomnocons_gar := 0;
                        END;

                        wreasingarant := 1;
                     --ja hem assignat a la primera garantia tota la reasegurança
                     ELSE
                        wcwp := 0;
                     -- wcomtotreaced_gar := 0;
                     -- wprimnoconsreaced_gar := 0;
                      --wcomnocons_gar := 0;
                     END IF;

                     ---- GASTOS DE ADQUISICION
                     BEGIN
                        SELECT crespue
                          INTO wcresp43
                          FROM pregunseg
                         WHERE cpregun = 4043
                           AND sseguro = reg.sseguro
                           AND nmovimi = gar.nmovimi
                           AND nriesgo = gar.nriesgo;
                     EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                           wcresp43 := 0;
                     END;

                     BEGIN
                        SELECT DECODE(crespue, 1, 1, 0)
                          INTO wcresp27
                          FROM pregunseg
                         WHERE cpregun = 4027
                           AND sseguro = reg.sseguro
                           AND nmovimi = gar.nmovimi
                           AND nriesgo = gar.nriesgo;
                     EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                           wcresp27 := 0;
                     END;

-- Ini BUG 23604 - MDS - 14/09/2012
/*
                     wk1 := NVL(pac_subtablas.f_vsubtabla(NULL, 1000, 333333, 1,
                                                          reg.prod_tarif, NVL(reg.ndurcob, 0),
                                                          wcresp43, gar.cgarant, wcresp27, 1),
                                0);
*/
                     wk1 := 0;

-- Ini BUG 23604 - MDS - 14/09/2012
-- 13. Bug 0024261 - 29/01/2013 - LCOL_F002-Contabilidad Vida Grupo - F2 / 0136601 - Inicio
                     BEGIN
                        SELECT ploccoa
                          INTO xploccoa
                          FROM coacuadro
                         WHERE ncuacoa = reg.ncuacoa
                           AND sseguro = reg.sseguro;

                        IF xploccoa IS NULL THEN
                           -- 4.0 MMM - 0027695: LCOL_F002-Provisiones: ERROR DE CONTABILIZACION BASE DE UPR CON COASEGURO CEDIDA - Inicio
                           --xploccoa := 0;
                           xploccoa := 100;
                        -- 4.0 MMM - 0027695: LCOL_F002-Provisiones: ERROR DE CONTABILIZACION BASE DE UPR CON COASEGURO CEDIDA - Fin
                        END IF;
                     EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                           -- 4.0 MMM - 0027695: LCOL_F002-Provisiones: ERROR DE CONTABILIZACION BASE DE UPR CON COASEGURO CEDIDA - Inicio
                           --xploccoa := 0;
                           xploccoa := 100;
                     -- 4.0 MMM - 0027695: LCOL_F002-Provisiones: ERROR DE CONTABILIZACION BASE DE UPR CON COASEGURO CEDIDA - Fin
                     END;

--                     wgwp := gar.iprianu;   -- prima emitida bruta
                     -- 4.0 0027695: LCOL_F002-Provisiones: ERROR DE CONTABILIZACION BASE DE UPR CON COASEGURO CEDIDA - Inicio
                     --wgwp := gar.iprianu *(100 - xploccoa) / 100;   -- prima emitida bruta menos la parte coasegurada
                     -- 7.0 - 10/10/2013 - MMM - 0027695: LCOL_F002-Provisiones ERROR DE CONTABILIZACION BASE DE UPR CON COASEGURO CEDIDA - Inicio
                     --wgwp := gar.iprianu *(xploccoa) / 100;   -- prima emitida bruta parte coasegurada
                     wgwp := gar.iprianu * wprorrata *(xploccoa) / 100;   -- prima emitida bruta parte coasegurada
                     -- 7.0 - 10/10/2013 - MMM - 0027695: LCOL_F002-Provisiones ERROR DE CONTABILIZACION BASE DE UPR CON COASEGURO CEDIDA - Fin

                     -- 4.0 0027695: LCOL_F002-Provisiones: ERROR DE CONTABILIZACION BASE DE UPR CON COASEGURO CEDIDA - Fin
-- 13. Bug 0024261 - 29/01/2013 - LCOL_F002-Contabilidad Vida Grupo - F2 / 0136601 - Fin
                     wfrpt := (wffin - wfact) /(wffin - wfini);
                     -- factor de riesgo
                     wga := wgwp * wk1;
                     -- gastos de adquisición , wgwp (prima bruta) * por % adqui
                     wgupr := (wgwp - wga) * wfrr * wfrpt;
                     /*
                     --{excepciones por ramo}
                     --[ Aviacion , navegacion, minas,petroleo]
                     wgupr := (wgwp - wga) * wfre * wfprtre;
                     wcupr := wfre * wcwp * wfprtre;
                     wnupr := (wgupr - wcupr);

                     --[ transporte ]
                     wgupr := wfre*(wogwp- wga)*wfprtre;
                     wcupr:= wfre* wocwp* wfprtre;
                     wnupr:= wgupr-wcupr;

                     --[ seguros de manejo ]
                     wgupr := wfre*(wogwp- wga)*wfprtre;
                     wcupr:= wfre* wcwp* wfprtre;
                     wnupr:= wgupr-wcupr;

                     --[ soat]
                     wgupr := (wgwp*(1-wpcf)-wcg-wga)*wfrr*wfrpt;-- donde cg no se explica lo que es
                     wcupr:= wfrr* wcwp* wfrpt;
                     wnupr:= wgupr-wcupr;

                     */
                     -- 7.0 - 10/10/2013 - MMM - 0027695: LCOL_F002-Provisiones ERROR DE CONTABILIZACION BASE DE UPR CON COASEGURO CEDIDA - Inicio
                     --wcupr := NVL(wcwp, 0) * wfrr * wfrpt;
                     wcupr := NVL(wcwp, 0) * wprorrata * wfrr * wfrpt;
                     -- 7.0 - 10/10/2013 - MMM - 0027695: LCOL_F002-Provisiones ERROR DE CONTABILIZACION BASE DE UPR CON COASEGURO CEDIDA - Fin
                     wnupr := wgupr - wcupr;
                     wturp := 0;
                     warpdsupr := 0;
                     warpupr := 0;
                     waupr := 0;
                     wasupr := 0;
                     wareupr := 0;
                     -- 7.0 - 10/10/2013 - MMM - 0027695: LCOL_F002-Provisiones ERROR DE CONTABILIZACION BASE DE UPR CON COASEGURO CEDIDA - Inicio
                     --wqgwp := wgwp * wprorrata * 90;   -- trimestral
                     wqgwp := wgwp * 90;   -- trimestral
                     -- 7.0 - 10/10/2013 - MMM - 0027695: LCOL_F002-Provisiones ERROR DE CONTABILIZACION BASE DE UPR CON COASEGURO CEDIDA - Fin
                     wogwp := 0;
                     wqcwp := wcwp * wprorrata * 90;   -- trimestral
                     wocwp := 0;

                     IF NVL(gar.cprovis, 1) = 1 THEN   -- bug 13621 ASN 23/03/2010
                        -- 7.0 - 10/10/2013 - MMM - 0027695: LCOL_F002-Provisiones ERROR DE CONTABILIZACION BASE DE UPR CON COASEGURO CEDIDA - Inicio
                        -- wnep := wgwp * wprorrata *(1 - gar.precseg / 100);
                        wnep := wgwp *(1 - gar.precseg / 100);
                        -- 7.0 - 10/10/2013 - MMM - 0027695: LCOL_F002-Provisiones ERROR DE CONTABILIZACION BASE DE UPR CON COASEGURO CEDIDA - Fin
                        -- CPM 24/02/04: Calculem les comisions d'agents no consumides
                        --wcomisiones_gar := wprimtotnetrecseg_gar *(wpcomage / 100);
                     -- Fi CPM
                     ELSE
                        wnep := 0;
                     -- wcomisiones_gar := 0;
                     END IF;

                     wtnwp := 0;

                     -- BUG 20070/107545 - 20/02/2012 - JMP - Añadir contravalores en la moneda de la contabilidad
                     IF reg.cmoneda = w_cmoncon THEN
                        witasa := 1;
                        pfcambio := aux_factual;
                     ELSE
                        pfcambio := pac_eco_tipocambio.f_fecha_max_cambio(reg.cmoneda_t,
                                                                          w_cmoncon_t,
                                                                          aux_factual);

                        IF pfcambio IS NULL THEN
                           wtexto := f_axis_literales(num_err, pcidioma);
                           num_err := f_proceslin(psproces, wtexto || ' -UPR', 9902592,
                                                  wnlinea);
                           wnlinea := NULL;
                           RETURN 9902592;
                        -- No se ha encontrado el tipo de cambio entre monedas
                        END IF;

                        witasa := pac_eco_tipocambio.f_cambio(reg.cmoneda_t, w_cmoncon_t,
                                                              pfcambio);
                     END IF;

                     -- Ini Bug 21550 - MDS - 29/02/2012
-- Bug 0024261 - DCG - 20/12/2012 - LCOL_F002-Contabilidad Vida Grupo - F2
-- Bug 0023130 - DCG - 25/09/2012 - LCOL_F002-Provisiones para polizas estatales
-- 13. Bug 0024261 - 29/01/2013 - LCOL_F002-Contabilidad Vida Grupo - F2 / 0136601 - Inicio
                     BEGIN
                        SELECT ploccoa
                          INTO xploccoa
                          FROM coacuadro
                         WHERE ncuacoa = reg.ncuacoa
                           AND sseguro = reg.sseguro;

                        IF xploccoa IS NULL THEN
                            -- 4.0 MMM - 0027695: LCOL_F002-Provisiones: ERROR DE CONTABILIZACION BASE DE UPR CON COASEGURO CEDIDA - Inicio
                           --xploccoa := 0;
                           xploccoa := 100;
                        -- 4.0 MMM - 0027695: LCOL_F002-Provisiones: ERROR DE CONTABILIZACION BASE DE UPR CON COASEGURO CEDIDA - Fin
                        END IF;
                     EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                            -- 4.0 MMM - 0027695: LCOL_F002-Provisiones: ERROR DE CONTABILIZACION BASE DE UPR CON COASEGURO CEDIDA - Inicio
                           --xploccoa := 0;
                           xploccoa := 100;
                     -- 4.0 MMM - 0027695: LCOL_F002-Provisiones: ERROR DE CONTABILIZACION BASE DE UPR CON COASEGURO CEDIDA - Fin
                     END;

--                     w_icage := wprorrata * xploccoa / 100 * gar.iprianu * wc / 100;
-- 13. Bug 0024261 - 29/01/2013 - LCOL_F002-Contabilidad Vida Grupo - F2 / 0136601 - Fin
--                     w_icage := wprorrata * gar.iprianu * wc / 100;
                     -- 7.0 - 10/10/2013 - MMM - 0027695: LCOL_F002-Provisiones ERROR DE CONTABILIZACION BASE DE UPR CON COASEGURO CEDIDA - Inicio
                     --w_icage := wprorrata * wgwp * wc / 100;
                     w_icage := wgwp * wc / 100;
                     -- 7.0 - 10/10/2013 - MMM - 0027695: LCOL_F002-Provisiones ERROR DE CONTABILIZACION BASE DE UPR CON COASEGURO CEDIDA - Fin

                     -- Fin Bug 0024261
                     w_icadn := 0;   -- De momento a 0
                     w_icage_nc := w_icage *((wffin - aux_factual) /(wffin - wfini));
                     w_icadn_nc := 0;   -- De momento a 0
-- 13. Bug 0024261 - 29/01/2013 - LCOL_F002-Contabilidad Vida Grupo - F2 / 0136601 - Inicio
                     w_icage_coa := wprorrata *(xploccoa) / 100 * gar.iprianu * wc / 100;   --parte coasegurada
                     w_icadn_coa := 0;   -- De momento a 0                                    --parte coasegurada
                     w_icage_nc_coa := w_icage_coa *((wffin - aux_factual) /(wffin - wfini));   --parte coasegurada
                     w_icadn_nc_coa := 0;   -- De momento a 0                                 --parte coasegurada
-- 13. Bug 0024261 - 29/01/2013 - LCOL_F002-Contabilidad Vida Grupo - F2 / 0136601 - Fin

                     -- Fin Bug 21550 - MDS - 29/02/2012

                     -- FIN BUG 20070/107545 - 20/02/2012 - JMP - Añadir contravalores en la moneda de la contabilidad
                     -- 3.0 05/07/2013  MMM Igualar código con PAC_PROVTEC_LCOL
                     wcupr_moncon := NVL(f_round(f_round(wcupr, reg.cmoneda) * witasa,
                                                 w_cmoncon),
                                         0);

                     -- 3.0 05/07/2013  MMM Igualar código con PAC_PROVTEC_LCOL
                     IF pmodo = 'P' THEN
                        BEGIN
                           INSERT INTO upr_previo
                                       (cempres, fcalcul, sproces, cramo,
                                        cmodali, ctipseg, ccolect, sseguro,
                                        nriesgo, nmovimi, cgarant, iprianu,
                                        igupr, icupr, inupr, iturp, iarpdsupr, iarpupr,
                                        iaupr, iasupr, iareupr, igwp, inep, itnwp, iqgwp,
                                        iowp, icwp, iqwp, iocwp, padq, iadqui, pcf, parpupr,
                                        parpdsupr, pturp, iprovcc, pcomisi, pcadn, idac,
                                        idacadn, icadqdifrea, ifactrres, ifactresp,
                                        ifactries, cmoneda, itasa, fini, ffin,
                                        inupr_moncon,
                                        icupr_moncon,
                                        iaupr_moncon,
                                        igupr_moncon,
                                        icwp_moncon,
                                        iprianu_moncon,
                                        inep_moncon,
                                        fcambio,
                                                -- Ini Bug 21550 - MDS - 29/02/2012
                                                -- Añadir campos
                                                icage, icadn, icage_nc, icadn_nc,
                                        icage_moncon,
                                        icadn_moncon,
                                        icage_nc_moncon,
                                        icadn_nc_moncon
                                                                      -- Fin Bug 21550 - MDS - 29/02/2012
                                                       -- Bug 0024261 - DCG - 28/01/2013 - LCOL_F002-Contabilidad Vida Grupo - F2
                           ,
                                        icage_coa, icadn_coa, icage_nc_coa,
                                        icadn_nc_coa,
                                        icage_moncon_coa,
                                        icadn_moncon_coa,
                                        icage_nc_moncon_coa,
                                        icadn_nc_moncon_coa
                                                           -- Bug 0024261 - DCG - 28/01/2013 - LCOL_F002-Contabilidad Vida Grupo - F2
                                       )
                                VALUES (pcempres, aux_factual, psproces, reg.cramo,
                                        reg.cmodali, reg.ctipseg, reg.ccolect, reg.sseguro,
                                        reg.nriesgo, gar.nmovimi, gar.cgarant, gar.iprianu,
                                        wgupr, wcupr, wnupr, wturp, warpdsupr, warpupr,
                                        waupr, wasupr, wareupr, wgwp, wnep, wtnwp, wqgwp,
                                        wocwp, wcwp, wgwp, wocwp, wk1, wga, wpcf, warpupr,
                                        warpdsupr, wturp, wcc, wc, wcadn, wdac,
                                        wdacadn, wrdac, wfrr, wfre,
                                        wfrpt, reg.cmoneda, witasa, wfini, wffin,
                                        f_round(f_round(wnupr, reg.cmoneda) * witasa,
                                                w_cmoncon),
                                        -- 3.0 05/07/2013  MMM  Igualar código con PAC_PROVTEC_LCOL
                                        --f_round(f_round(wcupr, reg.cmoneda) * witasa,
                                        --        w_cmoncon),
                                        wcupr_moncon,
                                        -- 3.0   05/07/2013  MMM  Igualar código con PAC_PROVTEC_LCOL
                                        f_round(f_round(waupr, reg.cmoneda) * witasa,
                                                w_cmoncon),
                                        f_round(f_round(wgupr, reg.cmoneda) * witasa,
                                                w_cmoncon),
                                        f_round(f_round(wcwp, reg.cmoneda) * witasa, w_cmoncon),
                                        f_round(f_round(gar.iprianu, reg.cmoneda) * witasa,
                                                w_cmoncon),
                                        f_round(f_round(wnep, reg.cmoneda) * witasa, w_cmoncon),
                                        pfcambio,
                                                 -- Ini Bug 21550 - MDS - 29/02/2012
                                                 -- Añadir campos
                                                 w_icage, w_icadn, w_icage_nc, w_icadn_nc,
                                        f_round(f_round(w_icage, reg.cmoneda) * witasa,
                                                w_cmoncon),
                                        f_round(f_round(w_icadn, reg.cmoneda) * witasa,
                                                w_cmoncon),
                                        f_round(f_round(w_icage_nc, reg.cmoneda) * witasa,
                                                w_cmoncon),
                                        f_round(f_round(w_icadn_nc, reg.cmoneda) * witasa,
                                                w_cmoncon)
                                                          -- Fin Bug 21550 - MDS - 29/02/2012
                                                          -- Bug 0024261 - DCG - 28/01/2013 - LCOL_F002-Contabilidad Vida Grupo - F2
                           ,
                                        w_icage_coa, w_icadn_coa, w_icage_nc_coa,
                                        w_icadn_nc_coa,
                                        f_round(f_round(w_icage_coa, reg.cmoneda) * witasa,
                                                w_cmoncon),
                                        f_round(f_round(w_icadn_coa, reg.cmoneda) * witasa,
                                                w_cmoncon),
                                        f_round(f_round(w_icage_nc_coa, reg.cmoneda) * witasa,
                                                w_cmoncon),
                                        f_round(f_round(w_icadn_nc_coa, reg.cmoneda) * witasa,
                                                w_cmoncon)
                                                          -- Bug 0024261 - DCG - 28/01/2013 - LCOL_F002-Contabilidad Vida Grupo - F2
                                       );
                        EXCEPTION
                           WHEN OTHERS THEN
                              num_err := 108468;
                        -- error al insertar en la tabla
                        END;
                     ELSIF pmodo = 'R' THEN
                        BEGIN
                           INSERT INTO upr
                                       (cempres, fcalcul, sproces, cramo,
                                        cmodali, ctipseg, ccolect, sseguro,
                                        nriesgo, nmovimi, cgarant, iprianu,
                                        igupr, icupr, inupr, iturp, iarpdsupr, iarpupr,
                                        iaupr, iasupr, iareupr, igwp, inep, itnwp, iqgwp,
                                        iowp, icwp, iqwp, iocwp, padq, iadqui, pcf, parpupr,
                                        parpdsupr, pturp, iprovcc, pcomisi, pcadn, idac,
                                        idacadn, icadqdifrea, ifactrres, ifactresp,
                                        ifactries, cmoneda, itasa, fini, ffin,
                                        inupr_moncon,
                                        icupr_moncon,
                                        iaupr_moncon,
                                        igupr_moncon,
                                        icwp_moncon,
                                        iprianu_moncon,
                                        inep_moncon,
                                        fcambio,
                                                -- Ini Bug 21550 - MDS - 29/02/2012
                                                -- Añadir campos
                                                icage, icadn, icage_nc, icadn_nc,
                                        icage_moncon,
                                        icadn_moncon,
                                        icage_nc_moncon,
                                        icadn_nc_moncon
                                                       -- Fin Bug 21550 - MDS - 29/02/2012
                                                       -- Bug 0024261 - DCG - 28/01/2013 - LCOL_F002-Contabilidad Vida Grupo - F2
                           ,
                                        icage_coa, icadn_coa, icage_nc_coa,
                                        icadn_nc_coa,
                                        icage_moncon_coa,
                                        icadn_moncon_coa,
                                        icage_nc_moncon_coa,
                                        icadn_nc_moncon_coa
                                                           -- Bug 0024261 - DCG - 28/01/2013 - LCOL_F002-Contabilidad Vida Grupo - F2
                                       )
                                VALUES (pcempres, aux_factual, psproces, reg.cramo,
                                        reg.cmodali, reg.ctipseg, reg.ccolect, reg.sseguro,
                                        reg.nriesgo, gar.nmovimi, gar.cgarant, gar.iprianu,
                                        wgupr, wcupr, wnupr, wturp, warpdsupr, warpupr,
                                        waupr, wasupr, wareupr, wgwp, wnep, wtnwp, wqgwp,
                                        wocwp, wcwp, wgwp, wocwp, wk1, wga, wpcf, warpupr,
                                        warpdsupr, wturp, wcc, wc, wcadn, wdac,
                                        wdacadn, wrdac, wfrr, wfre,
                                        wfrpt, reg.cmoneda, witasa, wfini, wffin,
                                        f_round(f_round(wnupr, reg.cmoneda) * witasa,
                                                w_cmoncon),
                                        -- 3.0   05/07/2013  MMM  Igualar código con PAC_PROVTEC_LCOL
                                        --f_round(f_round(wcupr, reg.cmoneda) * witasa,
                                        --        w_cmoncon),
                                        wcupr_moncon,
                                        -- 3.0   05/07/2013  MMM  Igualar código con PAC_PROVTEC_LCOL
                                        f_round(f_round(waupr, reg.cmoneda) * witasa,
                                                w_cmoncon),
                                        f_round(f_round(wgupr, reg.cmoneda) * witasa,
                                                w_cmoncon),
                                        f_round(f_round(wcwp, reg.cmoneda) * witasa, w_cmoncon),
                                        f_round(f_round(gar.iprianu, reg.cmoneda) * witasa,
                                                w_cmoncon),
                                        f_round(f_round(wnep, reg.cmoneda) * witasa, w_cmoncon),
                                        pfcambio,
                                                 -- Ini Bug 21550 - MDS - 29/02/2012
                                                 -- Añadir campos
                                                 w_icage, w_icadn, w_icage_nc, w_icadn_nc,
                                        f_round(f_round(w_icage, reg.cmoneda) * witasa,
                                                w_cmoncon),
                                        f_round(f_round(w_icadn, reg.cmoneda) * witasa,
                                                w_cmoncon),
                                        f_round(f_round(w_icage_nc, reg.cmoneda) * witasa,
                                                w_cmoncon),
                                        f_round(f_round(w_icadn_nc, reg.cmoneda) * witasa,
                                                w_cmoncon)
                                                          -- Fin Bug 21550 - MDS - 29/02/2012
                                                          -- Bug 0024261 - DCG - 28/01/2013 - LCOL_F002-Contabilidad Vida Grupo - F2
                           ,
                                        w_icage_coa, w_icadn_coa, w_icage_nc_coa,
                                        w_icadn_nc_coa,
                                        f_round(f_round(w_icage_coa, reg.cmoneda) * witasa,
                                                w_cmoncon),
                                        f_round(f_round(w_icadn_coa, reg.cmoneda) * witasa,
                                                w_cmoncon),
                                        f_round(f_round(w_icage_nc_coa, reg.cmoneda) * witasa,
                                                w_cmoncon),
                                        f_round(f_round(w_icadn_nc_coa, reg.cmoneda) * witasa,
                                                w_cmoncon)
                                                          -- Bug 0024261 - DCG - 28/01/2013 - LCOL_F002-Contabilidad Vida Grupo - F2
                                       );
                        EXCEPTION
                           WHEN OTHERS THEN
                              num_err := 108468;
                        -- error al insertar en la tabla
                        END;
                     ELSE
                        RETURN 9000505;   -- Error de parametres
                     END IF;

-- 3.0 MMM Igualar cambios LCOL - INICIO
------------------------------------------------------------
-- DESGLOSE POR COMPAÑÍAS REASEGURADORAS
-- SE GRABA POSTERIORMENTE POR LAS CONSTRAINTS
------------------------------------------------------------
-- IMPORTANTE:
-- CUALQUIER CAMBIO EN LA "SELECT" DEL CURSOR DEBERÁ HACERSE
-- EN LA SELECT QUE HACE EL SUM DE REASEGURO.ICESION (*1)
------------------------------------------------------------
                     IF NVL(wcupr_moncon, 0) <> 0
                        OR NVL(wcupr, 0) <> 0 THEN
                        -- Hacemos un sumatorio del desglose
                        SELECT NVL(SUM(icupr), 0), NVL(SUM(icupr_moncon), 0)
                          INTO vicupr_t, vicupr_moncon_t
                          FROM (SELECT   r.ccompani, SUM(icesion) * wfrr * wfrpt icupr,
                                         f_round(f_round(SUM(icesion) * wfrr
                                                         * wfrpt,
                                                         reg.cmoneda)
                                                 * witasa,
                                                 w_cmoncon) icupr_moncon
                                    FROM reaseguro r
                                   WHERE r.sseguro = reg.sseguro
                                     AND r.fefecto <= aux_factual
                                     AND r.fvencim > aux_factual
                                     AND r.nriesgo = reg.nriesgo
                                     AND r.ctramo <> 0
                                     AND(r.cgarant = gar.cgarant
                                         OR(wreasingarant = 0
                                            AND NVL(r.cgarant, 0) = 0))
                                GROUP BY r.ccompani);

                        FOR rrea IN
                           (SELECT   ccompani, icupr, icupr_moncon, ROWNUM
                                FROM (SELECT   r.ccompani, SUM(icesion) * wfrr * wfrpt icupr,
                                               f_round(f_round(SUM(icesion)
                                                               * wfrr * wfrpt,
                                                               reg.cmoneda)
                                                       * witasa,
                                                       w_cmoncon) icupr_moncon
                                          FROM reaseguro r
                                         WHERE r.sseguro = reg.sseguro
                                           AND r.fefecto <= aux_factual
                                           AND r.fvencim > aux_factual
                                           AND r.nriesgo = reg.nriesgo
                                           AND r.ctramo <> 0
                                           AND(r.cgarant = gar.cgarant
                                               OR(wreasingarant = 0
                                                  AND NVL(r.cgarant, 0) = 0))
                                      GROUP BY r.ccompani)
                            ORDER BY icupr DESC) LOOP
                           -- Restaremos al primer registro (el de mayor importe) el posible descuadre
                           vicupr_2 := rrea.icupr;
                           vicupr_moncon_2 := rrea.icupr_moncon;

                           IF rrea.ROWNUM = 1 THEN
                              IF vicupr_t != wcupr THEN
                                 vicupr_2 := vicupr_2 -(vicupr_t - wcupr);
                              END IF;

                              IF vicupr_moncon_2 != wcupr_moncon THEN
                                 vicupr_moncon_2 :=
                                             vicupr_moncon_2
                                             -(vicupr_moncon_t - wcupr_moncon);
                              END IF;
                           END IF;

                           IF pmodo = 'P' THEN
                              BEGIN
                                 INSERT INTO upr_rea_previo
                                             (cempres, fcalcul, sproces, cramo,
                                              cmodali, ctipseg, ccolect,
                                              sseguro, nriesgo, nmovimi,
                                              cgarant, ccompani, icupr,
                                              icupr_moncon)
                                      VALUES (pcempres, aux_factual, psproces, reg.cramo,
                                              reg.cmodali, reg.ctipseg, reg.ccolect,
                                              reg.sseguro, reg.nriesgo, gar.nmovimi,
                                              gar.cgarant, rrea.ccompani, vicupr_2,
                                              vicupr_moncon_2);
                              EXCEPTION
                                 WHEN OTHERS THEN
                                    num_err := 108468;
                              -- error al insertar en la tabla
                              END;
                           ELSIF pmodo = 'R' THEN
                              BEGIN
                                 INSERT INTO upr_rea
                                             (cempres, fcalcul, sproces, cramo,
                                              cmodali, ctipseg, ccolect,
                                              sseguro, nriesgo, nmovimi,
                                              cgarant, ccompani, icupr,
                                              icupr_moncon)
                                      VALUES (pcempres, aux_factual, psproces, reg.cramo,
                                              reg.cmodali, reg.ctipseg, reg.ccolect,
                                              reg.sseguro, reg.nriesgo, gar.nmovimi,
                                              gar.cgarant, rrea.ccompani, vicupr_2,
                                              vicupr_moncon_2);
                              EXCEPTION
                                 WHEN OTHERS THEN
                                    num_err := 108468;
                              -- error al insertar en la tabla
                              END;
                           END IF;
                        END LOOP;
                     END IF;
                  END IF;

                  -- 3.0 MMM Igualar cambios LCOL - FIN

                  -- {Tratamiento de errores}
                  IF num_err <> 0 THEN
                     wtexto := f_axis_literales(num_err, pcidioma);
                     num_err := f_proceslin(psproces, wtexto || ' -UPR', reg.sseguro, wnlinea);
                     wnlinea := NULL;
                     conta_err := conta_err + 1;
                  END IF;

                  num_err := 0;
               END IF;
            END LOOP;
         END IF;
      END LOOP;

      COMMIT;
      RETURN(conta_err);
   END f_commit_calcul_upr;

         /*
         -- Las PPLP y PPPC no se calcularán incialmente para POSITIVA, aunque la función "f_provision_vigente"
         -- impediría su ejecución, se comentan porque hacen servir tablas _LCOL.
         -- COMENTADAS : f_commit_calcul_pplp + f_commit_calcul_pppc

         FUNCTION f_commit_calcul_pplp(
            cempres IN NUMBER,
            aux_factual IN DATE,
            psproces IN NUMBER,
            pcidioma IN NUMBER,
            pcmoneda IN NUMBER,
            pmodo IN VARCHAR2 DEFAULT 'R')
            RETURN NUMBER IS
            aux_fefeini    DATE;
            ttexto         VARCHAR2(400);
            nlin           NUMBER;
            num_err        NUMBER := 0;
            conta_err      NUMBER := 0;
            provisio       NUMBER;
            vicompan       NUMBER;
            pfcambio       DATE;   -- Fecha de conversión vigente
            witasa         NUMBER(15, 2);   --valor de conversion a la efcha
            wcestpag       NUMBER;   -- tiene pagos penduientes
            wnumpag        NUMBER;   -- tiene pagos
            wtestpag       VARCHAR2(75);   -- HAY PRISA
            wtedad         VARCHAR2(2);
            -- BUG 20070/107545 - 20/02/2012 - JMP - Añadir contravalores en la moneda de la contabilidad
            w_cmoncon      parempresas.nvalpar%TYPE
                                           := pac_parametros.f_parempresa_n(cempres, 'MONEDACONTAB');
            -- Moneda de contablidad (numérico)
            w_cmoncon_t    monedas.cmonint%TYPE := pac_monedas.f_cmoneda_t(w_cmoncon);
                                                   -- Moneda de contablidad (texto)
         -- FIN BUG 20070/107545 - 20/02/2012 - JMP - Añadir contravalores en la moneda de la contabilidad
         BEGIN
            FOR reg IN c_siniestros_pplp(aux_factual, cempres) LOOP
               -- Esta función tiene en cuenta todos los pagos, tanto si están valorados como
               -- si no lo están.  El libor de siniestros, sólo tiene en cuenta los pagos
               -- que tienen valoración.

               -- BUG 20070 - MAD - 03/01/2012
               -- la función correcta por garantía es f_provisiogar en lugar de f_provisio
               --num_err := f_provisio(reg.nsinies, provisio, aux_factual);
               num_err := f_provisiogar(reg.nsinies, reg.cgarant, provisio, aux_factual);

               -- FIN BUG 20070 - MAD - 03/01/2012
               --
                  -- BUG 20070/107545 - 20/02/2012 - JMP - Añadir contravalores en la moneda de la contabilidad
               IF w_cmoncon = reg.cmoneda THEN
                  pfcambio := aux_factual;
                  witasa := 1;
               ELSE
                  pfcambio := pac_eco_tipocambio.f_fecha_max_cambio(reg.cmoneda_t, w_cmoncon_t,
                                                                    aux_factual);

                  IF pfcambio IS NULL THEN
                     RETURN 9902592;
                  -- No se ha encontrado el tipo de cambio entre monedas
                  END IF;

                  witasa := pac_eco_tipocambio.f_cambio(reg.cmoneda_t, w_cmoncon_t, pfcambio);
               END IF;

               -- FIN BUG 20070/107545 - 20/02/2012 - JMP - Añadir contravalores en la moneda de la contabilidad
               IF num_err <> 0 THEN
                  ROLLBACK;
                  ttexto := f_axis_literales(num_err, pcidioma);
                  num_err := f_proceslin(psproces, ttexto, reg.sseguro, nlin);
                  conta_err := conta_err + 1;
                  nlin := NULL;
                  COMMIT;
               ELSE
                  IF provisio <> 0 THEN
                     --BUG10328 - 18/06/2009 - DCT -
                     BEGIN
                        --Calculem el sumatori del icompan
                        SELECT NVL(SUM(icompan), 0)
                          INTO vicompan
                          FROM liqresreaaux
                         WHERE nsinies = reg.nsinies
                           AND fcierre = aux_factual;

                        SELECT COUNT(1)
                          INTO wcestpag
                          FROM sin_tramita_movpago snt, sin_tramita_pago sn
                         WHERE sn.nsinies = reg.nsinies
                           AND sn.sidepag = snt.sidepag
                           AND snt.nmovpag = (SELECT nmovpag
                                                FROM sin_tramita_movpago x
                                               WHERE x.sidepag = snt.sidepag
                                                 AND fcontab <= aux_factual)
                           AND sn.cestado = 0;   --pendiente

                        SELECT COUNT(1)
                          INTO wnumpag
                          FROM sin_tramita_pago
                         WHERE nsinies = reg.nsinies;

                        IF wcestpag = 0
                           AND wnumpag > 0 THEN
                           wtestpag := 'desembolsado';
                        ELSE
                           wtestpag := 'por desembolsar';
                        END IF;

                        --FI BUG10328 - 18/06/2009 - DCT -
                        IF pmodo = 'R' THEN
                           -- BUG 20070 - MAD - 03/01/2012
                           -- añadir el campo cgarant
                           INSERT INTO ptpplp_lcol
                                       (cempres, fcalcul, sproces, cramdgs, cramo,
                                        cmodali, ctipseg, ccolect, sseguro,
                                        nsinies, ipplpsd, ipplprc, cerror, cmoneda, itasa,
                                        cgarant, ccausini, cestpag,
                                        ipplpsd_moncon,
                                        ipplprc_moncon,
                                        fcambio)
                                VALUES (reg.cempres, aux_factual, psproces, reg.cramdgs, reg.cramo,
                                        reg.cmodali, reg.ctipseg, reg.ccolect, reg.sseguro,
                                        reg.nsinies, provisio, vicompan, 0, reg.cmoneda, witasa,
                                        reg.cgarant, reg.ccausin, wtestpag,
                                        f_round(f_round(provisio, reg.cmoneda) * witasa, w_cmoncon),
                                        f_round(f_round(vicompan, reg.cmoneda) * witasa, w_cmoncon),
                                        pfcambio);
                        ELSIF pmodo = 'P' THEN
                           -- BUG 20070 - MAD - 03/01/2012
                           -- añadir el campo cgarant
                           INSERT INTO ptpplp_lcol_previo
                                       (cempres, fcalcul, sproces, cramdgs, cramo,
                                        cmodali, ctipseg, ccolect, sseguro,
                                        nsinies, ipplpsd, ipplprc, cerror, cmoneda, itasa,
                                        cgarant, ccausini, cestpag,
                                        ipplpsd_moncon,
                                        ipplprc_moncon,
                                        fcambio)
                                VALUES (reg.cempres, aux_factual, psproces, reg.cramdgs, reg.cramo,
                                        reg.cmodali, reg.ctipseg, reg.ccolect, reg.sseguro,
                                        reg.nsinies, provisio, vicompan, 0, reg.cmoneda, witasa,
                                        reg.cgarant, reg.ccausin, wtestpag,
                                        f_round(f_round(provisio, reg.cmoneda) * witasa, w_cmoncon),
                                        f_round(f_round(vicompan, reg.cmoneda) * witasa, w_cmoncon),
                                        pfcambio);
                        END IF;
                     EXCEPTION
                        WHEN OTHERS THEN
                           ROLLBACK;
                           ttexto := f_axis_literales(104349, pcidioma);
                           num_err := f_proceslin(psproces, ttexto || ' PTPPLP', reg.sseguro, nlin);
                           conta_err := conta_err + 1;
                           nlin := NULL;
                           COMMIT;
                     END;

                     COMMIT;
                  END IF;
               END IF;
            END LOOP;

            RETURN conta_err;
         END f_commit_calcul_pplp;
   */
   FUNCTION f_commit_calcul_pppc(
      cempres IN NUMBER,
      aux_factual IN DATE,
      psproces IN NUMBER,
      pcidioma IN NUMBER,
      pcmoneda IN NUMBER,
      pmodo IN VARCHAR2 DEFAULT 'R')
      RETURN NUMBER IS
      --{declaracion de variables}
      -- variables auxiliares
      wtexto         axis_literales.tlitera%TYPE;
      num_err        NUMBER := 0;
      conta_err      NUMBER;
      wnlinea        NUMBER;
      wfact          DATE := aux_factual;
      wffin          DATE;
      wfini          DATE;
      wcmodcom       NUMBER;
      wprorrata      NUMBER;
      wdiascorridos  NUMBER;
      wtotalvig      NUMBER;
      wprovcartera   NUMBER;
      wrecgastos     NUMBER;
      wpprima        NUMBER(5, 2);
      wmatriz        NUMBER;
      wexpd          NUMBER;
      wexpd_moncon   NUMBER;
      pfcambio       DATE;   -- fecha de cambio
      witasa         NUMBER;
      wprovcarteraeco NUMBER;
      wmatrizeco     NUMBER;
      wexpdeco       NUMBER;
      w_dias         NUMBER;
      w_tedad_mat    VARCHAR2(100);
      w_tedad        VARCHAR2(100);
      w_ratio_local  NUMBER := 1;
      w_ratio_matriz NUMBER := 1;
      -- BUG 20070/107545 - 20/02/2012 - JMP - Añadir contravalores en la moneda de la contabilidad
      w_cmoncon      parempresas.nvalpar%TYPE
                                     := pac_parametros.f_parempresa_n(cempres, 'MONEDACONTAB');
      -- Moneda de contablidad (numérico)
      w_cmoncon_t    monedas.cmonint%TYPE := pac_monedas.f_cmoneda_t(w_cmoncon);
                                                   -- Moneda de contablidad (texto)
         -- FIN BUG 20070/107545 - 20/02/2012 - JMP - Añadir contravalores en la moneda de la contabilidad
      -- Bug 0023130 - DCG - 25/09/2012 - LCOL_F002-Provisiones para polizas estatales
      xploccoa       NUMBER;
      xpneta         NUMBER;
      xpneta_mon     NUMBER;
      xinsertar      NUMBER;
      asseguro       NUMBER;
      anmovimi       NUMBER;
      numageco       NUMBER;
      v_por_parc     NUMBER;
      v_c_porc_parc  NUMBER;
      wprovcartera2  NUMBER;
      wprovcarteraeco2 NUMBER;
      wmatriz2       NUMBER;
      wmatrizeco2    NUMBER;
      -- Bug 0024261 - DCG - 20/12/2012 - LCOL_F002-Contabilidad Vida Grupo - F2
      xpneta_coa_coa NUMBER;
      xpneta_mon_coa_coa NUMBER;
      wprovcartera_coa NUMBER;
      wprovcarteraeco_coa NUMBER;
      wmatriz_coa    NUMBER;
      wmatrizeco_coa NUMBER;
      wrecgastos_coa NUMBER;
      -- 3. MMM Igualar cambios LCOL. 25. 0027593: MMM LCOL_F003-0008417 Error en el calculo de la provision para primas mayores a 76 dias - Inicio
      wrecgastos_moncon NUMBER;
      wrecgastos_coa_moncon NUMBER;

      -- 3. MMM Igualar cambios LCOL. 25. 0027593: MMM LCOL_F003-0008417 Error en el calculo de la provision para primas mayores a 76 dias - Fin
      TYPE ARRAY IS TABLE OF c_recibos_ahorro%ROWTYPE;

      l_rec          ARRAY;

      CURSOR c_moratorio(pfini DATE, pffin DATE) IS
         SELECT   *
             FROM eco_tipocambio
            WHERE cmonori = 'MOR'
              AND((fcambio BETWEEN pfini AND pffin)
                  OR(fcambio = (SELECT MAX(fcambio)
                                  FROM eco_tipocambio
                                 WHERE cmonori = 'MOR'
                                   AND fcambio <= pfini)))
         ORDER BY fcambio;

      CURSOR c_meses(pfini DATE, pffin DATE) IS
         SELECT     LEVEL - 1 mes
               FROM DUAL
         CONNECT BY LEVEL <= CEIL(MONTHS_BETWEEN(pffin, pfini));

      v_ffin         DATE;
      v_fini         DATE;
      v_tasa         NUMBER;
      v_dias_mora    NUMBER;
      v_siguiente    DATE;
      v_imora        NUMBER := 0;
      v_dias_ano     NUMBER := 365;
   BEGIN
      OPEN c_recibos_ahorro(aux_factual, cempres);

      LOOP
         FETCH c_recibos_ahorro
         BULK COLLECT INTO l_rec LIMIT 4000;

         FOR i IN 1 .. l_rec.COUNT LOOP
            BEGIN
               -- SMF 30/03/2012
               --se substituye el uso de  la función de f_fechainifin y se toma como fechas las del recibo
               --num_err := f_fechainifin(rec.sseguro, wfact, rec.fvencim, rec.fcaranu, wffin,
               --                         wfini, wprorrata, wcmodcom);

               num_err := 0;
               wfini := l_rec(i).fefecto;
               wffin := l_rec(i).fvencim;


               IF num_err != 0 THEN
                  wtexto := f_axis_literales(num_err, pcidioma);
                  num_err := f_proceslin(psproces, wtexto || ' -PPPC 1', l_rec(i).sseguro,
                                         wnlinea);
                  wnlinea := NULL;
                  num_err := 104349;
               END IF;


               IF num_err = 0 THEN
                  wdiascorridos := wfact - wfini;

                  IF wdiascorridos = 366 THEN   -- SMF obra de arte según bug 21975
                     wdiascorridos := 365;
                  END IF;

                  wtotalvig := wffin - wfini;

--IPH BUG 35149   IF (wfact - l_rec(i).fefecto) >= 75 THEN   -- USANDO PARAMETROS - DIASPPPC
                  IF (wfact - l_rec(i).fefecto) >=
                         NVL(pac_parametros.f_parproducto_n(l_rec(i).sproduc, 'DIAS_PPPC'), 75) THEN
                     wrecgastos := l_rec(i).pgastos;
                     wrecgastos_coa := l_rec(i).pgastos_coa;
                     --3. MMM - Igualar cambios LCOL. 25. MMM 0027593: LCOL_F003-0008417 Error en el calculo de la provision para primas mayores a 76 dias - Inicio
                     wrecgastos_moncon := l_rec(i).pgastos_monpol;
                     wrecgastos_coa_moncon := l_rec(i).pgastos_monpol_coa;
                  --3. MMM - Igualar cambios LCOL. 25. MMM 0027593: LCOL_F003-0008417 Error en el calculo de la provision para primas mayores a 76 dias - Fin
                  ELSE
                     wrecgastos := 0;
                     wrecgastos_coa := 0;
                     --3. MMM - Igualar cambios LCOL. 25. MMM 0027593: LCOL_F003-0008417 Error en el calculo de la provision para primas mayores a 76 dias - Inicio
                     wrecgastos_moncon := 0;
                     wrecgastos_coa_moncon := 0;
                  --3. MMM - Igualar cambios LCOL. 25. MMM 0027593: LCOL_F003-0008417 Error en el calculo de la provision para primas mayores a 76 dias - Inicio
                  END IF;

                  --miramos si se trata de una excepcion
                  BEGIN
                     SELECT pprima
                       INTO wpprima
                       FROM pppc_excep
                      WHERE sseguro = l_rec(i).sseguro
                        AND nrecibo = l_rec(i).nrecibo;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        BEGIN
                           SELECT pprima
                             INTO wpprima
                             FROM pppc_excep
                            WHERE sseguro = l_rec(i).sseguro
                              AND nrecibo = 0;
                        EXCEPTION
                           WHEN OTHERS THEN
                              wpprima := 1;
                        END;
                     WHEN OTHERS THEN
                        wpprima := 1;
                  END;


                  -- Bug 0023130 - DCG - 25/09/2012 - LCOL_F002-Provisiones para polizas estatales
                  BEGIN
                     SELECT ploccoa
                       INTO xploccoa
                       FROM coacuadro
                      WHERE ncuacoa = l_rec(i).ncuacoa
                        AND sseguro = l_rec(i).sseguro;

                     IF xploccoa IS NULL THEN
                        xploccoa := 0;
                     END IF;
                  EXCEPTION
                     WHEN OTHERS THEN
                        xploccoa := 0;
                  END;

                  v_por_parc :=
                     pac_adm_cobparcial.f_get_porcentaje_cobro_parcial(l_rec(i).nrecibo, NULL,
                                                                       NULL);
                  v_c_porc_parc := 1 - v_por_parc;

                  IF v_c_porc_parc = 0 THEN
                     v_c_porc_parc := 1;
                  END IF;

                  -- 3. MMM. Igualar codigo LCOL. 0027593: LCOL_F003-0008417 Error en el calculo de la provision - Igualar código con PAC_PROVTEC_LCOL - INICIO                  --Icv 31/01/2013 -- 24261
                  xpneta := l_rec(i).pneta * /*(100 - xploccoa)*/ v_c_porc_parc;   /*/ 100*/
                  xpneta_mon := l_rec(i).pneta_monpol * /*(100 - xploccoa) */ v_c_porc_parc;   /*/ 100*/
                  --25.0 MMM 0027593: LCOL_F003-0008417 Error en el calculo de la provision para primas mayores a 76 dias - Inicio
                  --wprovcartera := (((xpneta * wpprima) +(wrecgastos)) * wdiascorridos)
                  --                / wtotalvig;
                  wprovcartera := ((xpneta * wpprima * wdiascorridos) / wtotalvig)
                                  +(wrecgastos);

                  --25.0 MMM 0027593: LCOL_F003-0008417 Error en el calculo de la provision para primas mayores a 76 dias - Fin
                  --wprovcartera := LEAST(wprovcartera,(xpneta * wpprima) + wrecgastos); --radd 14/05/2013 26961

                  -- IPH BUG 35149 -- --IPH BUG 35149 : CAMBIAMOS LOS DIAS EN HARDCODE POR EL VALOR DEL PARAMETRO DIAS_PPPC
                   /*
                   IF l_rec(i).sproduc <> 339 THEN
                      IF wdiascorridos <= 75 THEN
                         wprovcartera := 0;
                      ELSE
                         wprovcartera := LEAST(ABS(wprovcartera),
                                               ABS((xpneta * wpprima) + wrecgastos))
                                         * SIGN(xpneta);   --radd  26961
                      END IF;
                   ELSIF l_rec(i).sproduc = 339 THEN
                      IF wdiascorridos < 31 THEN
                         wprovcartera := 0;
                      ELSE
                         wprovcartera := LEAST(ABS(wprovcartera), ABS((xpneta) + wrecgastos))
                                         * SIGN(xpneta);   --radd  26961
                      END IF;
                   END IF;*/
                  IF wdiascorridos < NVL(pac_parametros.f_parproducto_n(l_rec(i).sproduc,
                                                                        'DIAS_PPPC'),
                                         75) THEN
                     wprovcartera := 0;
                  ELSE
                     wprovcartera := LEAST(ABS(wprovcartera), ABS((xpneta) + wrecgastos))
                                     * SIGN(xpneta);   --radd  26961
                  END IF;

                  --25.0 MMM 0027593: LCOL_F003-0008417 Error en el calculo de la provision para primas mayores a 76 dias - Inicio
                  --wprovcarteraeco := f_round((((xpneta_mon * wpprima) +(wrecgastos))
                  --                            * wdiascorridos)
                  --                           / wtotalvig,
                  --                           w_cmoncon);
                  wprovcarteraeco := f_round(((xpneta_mon * wpprima * wdiascorridos)
                                              / wtotalvig)
                                             +(wrecgastos_moncon),
                                             w_cmoncon);
                  --25.0 MMM 0027593: LCOL_F003-0008417 Error en el calculo de la provision para primas mayores a 76 dias - Fin
                  --wprovcarteraeco := LEAST(wprovcarteraeco,(xpneta_mon * wpprima) + wrecgastos);  --radd 14/05/2013  26961
                  wprovcarteraeco := f_round(LEAST(ABS(wprovcarteraeco),
                                                   ABS((xpneta_mon * wpprima)
                                                       + wrecgastos_moncon))
                                             * SIGN(xpneta_mon));   --radd 14/05/2013  26961
                  wmatriz := l_rec(i).itotalr * /*(100 - xploccoa)*/ v_c_porc_parc;   /*/ 100*/
                  wmatrizeco := l_rec(i).itotalr_monpol * /*(xploccoa)*/ v_c_porc_parc;   /*/ 100*/
-- Fin Bug 0023130

                  -- Bug 0024261 - DCG - 20/12/2012 - LCOL_F002-Contabilidad Vida Grupo - F2
                  xpneta_coa_coa := l_rec(i).pneta_coa /**(xploccoa)*/ * v_c_porc_parc;   /*/ 100*/
                  xpneta_mon_coa_coa := l_rec(i).pneta_monpol_coa   /**(xploccoa)*/
                                        * v_c_porc_parc;   /*/ 100*/
                  --25.0 MMM 0027593: LCOL_F003-0008417 Error en el calculo de la provision para primas mayores a 76 dias - Inicio
                  --wprovcartera_coa := (((xpneta_coa_coa * wpprima) +(wrecgastos_coa))
                  --                     * wdiascorridos)
                  --                    / wtotalvig;
                  wprovcartera_coa := ((xpneta_coa_coa * wpprima * wdiascorridos) / wtotalvig)
                                      +(wrecgastos_coa);

                     --25.0 MMM 0027593: LCOL_F003-0008417 Error en el calculo de la provision para primas mayores a 76 dias - Fin
                     --wprovcartera_coa := LEAST(wprovcartera_coa,
                     --                          (xpneta_coa_coa * wpprima) + wrecgastos_coa);   --radd 14/05/2013 26961
                    --IPH BUG 35149 : CAMBIAMOS LOS DIAS EN HARDCODE POR EL VALOR DEL PARAMETRO DIAS_PPPC
                  /*

                     IF l_rec(i).sproduc <> 339 THEN
                        IF wdiascorridos <= 75 THEN
                           wprovcartera_coa := 0;
                        ELSE
                           wprovcartera_coa := LEAST(ABS(wprovcartera_coa),
                                                     ABS((xpneta_coa_coa * wpprima)
                                                         + wrecgastos_coa))
                                               * SIGN(xpneta_coa_coa);
                        END IF;
                     ELSIF l_rec(i).sproduc = 339 THEN
                        IF wdiascorridos < 31 THEN
                           wprovcartera_coa := 0;
                        ELSE
                           wprovcartera_coa := LEAST(ABS(wprovcartera_coa),
                                                     ABS((xpneta_coa_coa) + wrecgastos_coa))
                                               * SIGN(xpneta_coa_coa);
                        END IF;
                     END IF; */
                  IF wdiascorridos < NVL(pac_parametros.f_parproducto_n(l_rec(i).sproduc,
                                                                        'DIAS_PPPC'),
                                         75) THEN
                     wprovcartera_coa := 0;
                  ELSE
                     wprovcartera_coa := LEAST(ABS(wprovcartera_coa),
                                               ABS((xpneta_coa_coa) + wrecgastos_coa))
                                         * SIGN(xpneta_coa_coa);
                  END IF;

                  --25.0 MMM 0027593: LCOL_F003-0008417 Error en el calculo de la provision para primas mayores a 76 dias - Inicio
                  --wprovcarteraeco_coa := f_round((((xpneta_mon_coa_coa * wpprima)
                  --                                 +(wrecgastos_coa))
                  --                                * wdiascorridos)
                  --                               / wtotalvig,
                  --                               w_cmoncon);
                  wprovcarteraeco_coa := f_round(((xpneta_mon_coa_coa * wpprima * wdiascorridos)
                                                  / wtotalvig)
                                                 +(wrecgastos_coa_moncon),
                                                 w_cmoncon);
                  --25.0 MMM 0027593: LCOL_F003-0008417 Error en el calculo de la provision para primas mayores a 76 dias - Fin
                  wprovcarteraeco_coa := f_round(LEAST(ABS(wprovcarteraeco_coa),
                                                       ABS((xpneta_mon_coa_coa * wpprima)
                                                           + wrecgastos_coa_moncon))
                                                 * SIGN(xpneta_mon_coa_coa));
                  wmatriz_coa := l_rec(i).itotalr_coa /**(xploccoa)*/ * v_c_porc_parc;   /*/ 100*/
                  wmatrizeco_coa := l_rec(i).itotalr_monpol_coa /**(xploccoa)*/ * v_c_porc_parc;   /*/ 100*/

                  -- Fin Bug 0023130
                  --  18.0 0026669: LCOL_F003-0007036: Provisi?n Gastos de Expedici?n - Inicio
                  --   IF (wfact - l_rec(i).fefecto) > 180 THEN   -- a partir de l 76 dias los gastos se provisionan al 100%
                -- BUG 35149 -- UTILIZAR PARAMETRO DIAS_PPPC EN LUGAR DE HARDCODE
--                 IF (wfact - l_rec(i).fefecto) > 76 THEN   -- a partir de l 76 dias los gastos se provisionan al 100%
                  IF (wfact - l_rec(i).fefecto) >
                         NVL(pac_parametros.f_parproducto_n(l_rec(i).sproduc, 'DIAS_PPPC'), 75) THEN
                     --  18.0 0026669: LCOL_F003-0007036: Provisi?n Gastos de Expedici?n - Final
                     wexpd := l_rec(i).pgastexp;
                     wexpd_moncon := f_round(l_rec(i).pgastexp_moncon, w_cmoncon);
                  ELSE
                     wexpd := 0;
                     wexpd_moncon := 0;
                  END IF;
               END IF;

                -- 3. MMM. Igualar codigo LCOL. 0027593: LCOL_F003-0008417 Error en el calculo de la provision - Igualar código con PAC_PROVTEC_LCOL - INICIO

               --{Se calculan los tramos de edad}
               w_dias := wfact - l_rec(i).fefecto;

               CASE
                  WHEN w_dias <= 30 THEN
                     w_tedad_mat := '0-30';
                  WHEN w_dias > 30
                  AND w_dias <= 60 THEN
                     w_tedad_mat := '31-60';
                  WHEN w_dias > 60
                  AND w_dias <= 90 THEN
                     w_tedad_mat := '61-90';
                  WHEN w_dias > 90
                  AND w_dias <= 180 THEN
                     w_tedad_mat := '91-180';
                  WHEN w_dias > 180
                  AND w_dias <= 270 THEN
                     w_tedad_mat := '181-270';
                  WHEN w_dias > 271
                  AND w_dias <= 360 THEN
                     w_tedad_mat := '271-360';
                  WHEN w_dias > 360 THEN
                     w_tedad_mat := '> 361';
               END CASE;

               CASE
                  WHEN w_dias <= 30 THEN
                     w_tedad := '0-30';
                  WHEN w_dias > 30
                  AND w_dias <= 60 THEN
                     w_tedad := '31-60';
                  WHEN w_dias > 60
                  AND w_dias <= 90 THEN
                     w_tedad := '61-90';
                  WHEN w_dias > 90
                  AND w_dias <= 180 THEN
                     w_tedad := '91-180';
                  WHEN w_dias > 180
                  AND w_dias <= 270 THEN
                     w_tedad := '181-270';
                  WHEN w_dias > 271
                  AND w_dias <= 360 THEN
                     w_tedad := '271-360';
                  WHEN w_dias > 360 THEN
                     w_tedad := '> 361';
               END CASE;


               --{calculamos  el importe del contravalor, lo guaradamos en los campos E Y
               -- y con la moneda definida para contabilidad}
               -- BUG 20070/107545 - 20/02/2012 - JMP - Añadir contravalores en la moneda de la contabilidad
               IF w_cmoncon = l_rec(i).cmoneda THEN
                  pfcambio := aux_factual;
                  witasa := 1;
               ELSE
                  -- 3. MMM. Igualar cambios LCOL. 24. MMM. 0027522: LCOL_PROD-0008272: Diferencia contabilidad amortizacion comisiones. INICIO
                     --pfcambio :=
                     --   pac_eco_tipocambio.f_fecha_max_cambio
                     --                                  (pac_monedas.f_cmoneda_t(l_rec(i).cmoneda),
                     --                                   w_cmoncon_t, aux_factual);
                  SELECT MAX(fcambio)
                    INTO pfcambio
                    FROM detrecibos d
                   WHERE d.nrecibo = l_rec(i).nrecibo;

                  -- 3. MMM. Igualar cambios LCOL. 24. MMM. 0027522: LCOL_PROD-0008272. FIN
                  IF pfcambio IS NULL THEN
                     num_err := 9902592;
                     wtexto := f_axis_literales(num_err, pcidioma);
                     num_err := f_proceslin(psproces, wtexto || ' -PPPC 2', l_rec(i).sseguro,
                                            wnlinea);
                     wnlinea := NULL;
                     num_err := 9902592;
                  -- No se ha encontrado el tipo de cambio entre monedas
                  END IF;

                  witasa :=
                     pac_eco_tipocambio.f_cambio(pac_monedas.f_cmoneda_t(l_rec(i).cmoneda),
                                                 w_cmoncon_t, pfcambio);
               END IF;

               -- FIN BUG 20070/107545 - 20/02/2012 - JMP - Añadir contravalores en la moneda de la contabilidad

               -- Bug 0023130 - DCG - 25/09/2012 - LCOL_F002-Provisiones para polizas estatales
               xinsertar := 1;

               IF w_dias < 120 THEN
                  BEGIN
                     SELECT crespue
                       INTO xinsertar
                       FROM pregunpolseg
                      WHERE cpregun = 4820
                        AND sseguro = l_rec(i).sseguro
                        AND nmovimi = (SELECT MAX(nmovimi)
                                         FROM pregunpolseg
                                        WHERE cpregun = 4820
                                          AND sseguro = l_rec(i).sseguro);
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        xinsertar := 0;
                  END;
               ELSE
                  xinsertar := 0;
               END IF;

                                   /****Interes moratorio*****/
               --select iconcep_monpol, fefecto, fvencim into iprima from detrecibos d, recibos r where r.nrecibo = l_rec(i).nrecibo and d.cgarant = l_rec(i).cgarant and d.cconcep = 0 and r.nrecibo = d.nrecibo;
               --IPH-35149  incorporamos el parametro DIAS_PPPC -
               --IF (aux_factual - l_rec(i).fefecto) > 30
               IF (aux_factual - l_rec(i).fefecto) >
                         NVL(pac_parametros.f_parproducto_n(l_rec(i).sproduc, 'DIAS_PPPC'), 75)
                  --IPH BUG 35149 --NO EXISTE PRODUCTO 339, sino ramp
                  --   AND l_rec(i).sproduc = 339 THEN
                  AND l_rec(i).cramo = 801 THEN
                  v_ffin := LEAST(aux_factual, l_rec(i).fvencim);

                  FOR mes IN c_meses(l_rec(i).fefecto, v_ffin) LOOP
                     v_ffin := LEAST(LAST_DAY(ADD_MONTHS(l_rec(i).fefecto, mes.mes)),
                                     l_rec(i).fvencim);
                     v_fini := ADD_MONTHS(l_rec(i).fefecto, mes.mes);
                     v_dias_ano := TO_DATE('3112' || TO_CHAR(v_fini, 'rrrr'), 'ddmmrrrr')
                                   - TO_DATE('0101' || TO_CHAR(v_fini, 'rrrr'), 'ddmmrrrr')
                                   + 1;

                     FOR mora IN c_moratorio(ADD_MONTHS(l_rec(i).fefecto, mes.mes), v_ffin) LOOP
                        SELECT MIN(fcambio)
                          INTO v_siguiente
                          FROM eco_tipocambio
                         WHERE cmonori = 'MOR'
                           AND fcambio > mora.fcambio;

                        v_dias_mora := LEAST(v_ffin, v_siguiente)
                                       - GREATEST(v_fini, mora.fcambio, l_rec(i).fefecto);
                        v_tasa := mora.itasa;
                        v_imora := v_imora
                                   +(l_rec(i).pneta
                                     *((POWER(1 +(v_tasa / 100),(v_dias_mora / v_dias_ano)))
                                       - 1));
                     END LOOP;

                     v_dias_mora := 1;
                     v_imora := v_imora
                                +(l_rec(i).pneta
                                  *((POWER(1 +(v_tasa / 100),(v_dias_mora / v_dias_ano))) - 1));

                  END LOOP;
               END IF;

               IF xinsertar = 0 THEN
                     -- BUG-NOTA: 35149-201457 FECHA: 07/04/2015 FSG Inicio...
                  --   BUG 35149 UTILIZAR EL PARAMETRO Y NO EL HARDCODE
                  --   IF w_dias < 75 THEN
                  IF w_dias < NVL(pac_parametros.f_parproducto_n(l_rec(i).sproduc,
                                                                 'DIAS_PPPC'),
                                  75) THEN
                     wprovcartera := 0;
                     wprovcarteraeco := 0;
                     wprovcartera_coa := 0;
                     wprovcarteraeco_coa := 0;
                  END IF;

                  -- BUG-NOTA: 35149-201457 FECHA: 07/04/2015 FSG Final.

                  --{Realizamos los insert corrspondientes}
                  IF pmodo = 'R' THEN
                     -- BUG 20070 - MAD - 03/01/2012
                     -- modificar la tabla pppc_pos

                     INSERT INTO pppc_conf
                                 (cempres, fcalcul, sproces, cramdgs,
                                  cramo, cmodali, ctipseg,
                                  ccolect, sseguro, nrecibo,
                                  nmovimi, finiefe, cgarant,
                                  nriesgo, ipppc, ipppc_moncon, iderreg,
                                  ipppc_coa, ipppc_moncon_coa,   -- Bug 0024261 - DCG - 20/12/2012 - LCOL_F002-Contabilidad Vida Grupo - F2
                                                              iderreg_moncon,
                                  cmoneda, cerror, tedad, fcambio, iprovmora)
                          VALUES (cempres, aux_factual, psproces, l_rec(i).cramdgs,
                                  l_rec(i).cramo, l_rec(i).cmodali, l_rec(i).ctipseg,
                                  l_rec(i).ccolect, l_rec(i).sseguro, l_rec(i).nrecibo,
                                  l_rec(i).nmovimi, l_rec(i).fefecto, l_rec(i).cgarant,
                                  l_rec(i).nriesgo, wprovcartera, wprovcarteraeco, wexpd,
                                  wprovcartera_coa, wprovcarteraeco_coa,   -- Bug 0024261 - DCG - 20/12/2012 - LCOL_F002-Contabilidad Vida Grupo - F2
                                                                        wexpd_moncon,
                                  l_rec(i).cmoneda, num_err, w_tedad, pfcambio, v_imora);
                  /*
                  -- insertar en la tabla pppc_pos_matriz
                  IF w_dias > 180 THEN
                     --BMS_OUTPUT.put_line('REAL_MATRIZ;' || l_rec(I).sseguro || ';'
                     --                     || l_rec(I).nrecibo);
                     INSERT INTO pppc_pos_matriz
                                 (cempres, fcalcul, sproces, cramdgs,
                                  cramo, cmodali, ctipseg,
                                  ccolect, sseguro, nrecibo,
                                  nmovimi, finiefe, cgarant,
                                  nriesgo, ipppmat, ipppmat_moncon, iderreg,
                                  iderreg_moncon, ipppmat_coa, ipppmat_moncon_coa,   -- Bug 0024261 - DCG - 20/12/2012 - LCOL_F002-Contabilidad Vida Grupo - F2
                                  cmoneda, cerror, tedad, fcambio)
                          VALUES (cempres, aux_factual, psproces, l_rec(i).cramdgs,
                                  l_rec(i).cramo, l_rec(i).cmodali, l_rec(i).ctipseg,
                                  l_rec(i).ccolect, l_rec(i).sseguro, l_rec(i).nrecibo,
                                  l_rec(i).nmovimi, l_rec(i).fefecto, l_rec(i).cgarant,
                                  l_rec(i).nriesgo, wmatriz, wmatrizeco, wexpd,
                                  wexpd_moncon, wmatriz_coa, wmatrizeco_coa,   -- Bug 0024261 - DCG - 20/12/2012 - LCOL_F002-Contabilidad Vida Grupo - F2
                                  l_rec(i).cmoneda, num_err, w_tedad, pfcambio);
                  END IF;
                  */
                  ELSE
                     -- BUG 20070 - MAD - 03/01/2012
                     -- modificar la tabla pppc_pos_previ
                     BEGIN
                     INSERT INTO pppc_conf_previ
                                 (cempres, fcalcul, sproces, cramdgs,
                                  cramo, cmodali, ctipseg,
                                  ccolect, sseguro, nrecibo,
                                  nmovimi, finiefe, cgarant,
                                  nriesgo, ipppc, ipppc_moncon, iderreg,
                                  ipppc_coa, ipppc_moncon_coa,   -- Bug 0024261 - DCG - 20/12/2012 - LCOL_F002-Contabilidad Vida Grupo - F2
                                                              iderreg_moncon,
                                  cmoneda, cerror, tedad, fcambio, iprovmora)
                          VALUES (cempres, aux_factual, psproces, nvl(l_rec(i).cramdgs,0),
                                  l_rec(i).cramo, l_rec(i).cmodali, l_rec(i).ctipseg,
                                  l_rec(i).ccolect, l_rec(i).sseguro, l_rec(i).nrecibo,
                                  l_rec(i).nmovimi, l_rec(i).fefecto, l_rec(i).cgarant,
                                  l_rec(i).nriesgo, wprovcartera, wprovcarteraeco, wexpd,
                                  wprovcartera_coa, wprovcarteraeco_coa,   -- Bug 0024261 - DCG - 20/12/2012 - LCOL_F002-Contabilidad Vida Grupo - F2
                                                                        wexpd_moncon,
                                  l_rec(i).cmoneda, num_err, w_tedad_mat, pfcambio, v_imora);
                    EXCEPTION
                    WHEN OTHERS THEN
                       p_tab_error(f_sysdate, f_user, 'pac_provtec_conf', 1,dbms_utility.format_error_backtrace , SQLERRM);
                    END;
                  /*
                  -- BUG 20070 - MAD - 03/01/2012-- insertar en la tabla pppc_pos_matriz_previ
                  IF w_dias > 180 THEN
                     --BMS_OUTPUT.put_line('PREVIO MATRIZ;' || l_rec(I).sseguro || ';'
                     --                     || l_rec(I).nrecibo || ';' || wmatrizeco);
                     INSERT INTO pppc_pos_matriz_previ
                                 (cempres, fcalcul, sproces, cramdgs,
                                  cramo, cmodali, ctipseg,
                                  ccolect, sseguro, nrecibo,
                                  nmovimi, finiefe, cgarant,
                                  nriesgo, ipppmat, ipppmat_moncon, iderreg,
                                  iderreg_moncon, ipppmat_coa, ipppmat_moncon_coa,   -- Bug 0024261 - DCG - 20/12/2012 - LCOL_F002-Contabilidad Vida Grupo - F2
                                  cmoneda, cerror, tedad, fcambio)
                          VALUES (cempres, aux_factual, psproces, l_rec(i).cramdgs,
                                  l_rec(i).cramo, l_rec(i).cmodali, l_rec(i).ctipseg,
                                  l_rec(i).ccolect, l_rec(i).sseguro, l_rec(i).nrecibo,
                                  l_rec(i).nmovimi, l_rec(i).fefecto, l_rec(i).cgarant,
                                  l_rec(i).nriesgo, wmatriz, wmatrizeco, wexpd,
                                  wexpd_moncon, wmatriz_coa, wmatrizeco_coa,   -- Bug 0024261 - DCG - 20/12/2012 - LCOL_F002-Contabilidad Vida Grupo - F2
                                  l_rec(i).cmoneda, num_err, w_tedad_mat, pfcambio);
                  END IF;
                  */

                  END IF;
               END IF;
            EXCEPTION
               WHEN OTHERS THEN
                  --ROLLBACK; RDD 25/02/2013 BUG:  26018; QTRACKER 6020;

                  wtexto := f_axis_literales(104349, pcidioma) || ' ERROR CON sseguro '
                            || l_rec(i).sseguro || '; RECIBO ' || l_rec(i).nrecibo || ';';
                  num_err := f_proceslin(psproces, wtexto || ' -PPPC 3 ', l_rec(i).sseguro,
                                         wnlinea);
                  conta_err := conta_err + 1;
                  wnlinea := NULL;
            --COMMIT;  RDD 25/02/2013 BUG:  26018; QTRACKER 6020;
            END;

            -- {Tratamiento de errores}
            IF num_err <> 0 THEN
               --BMS_OUTPUT.put_line('tratamiento de errores; sseguro ' || l_rec(i).sseguro
               --                     || ';' || l_rec(i).nrecibo || ';');
               wtexto := f_axis_literales(num_err, pcidioma) || ' ERROR CON sseguro '
                         || l_rec(i).sseguro || '; RECIBO ' || l_rec(i).nrecibo || ';';
               num_err := f_proceslin(psproces, wtexto || ' -PPPC 4', l_rec(i).sseguro,
                                      wnlinea);
               wnlinea := NULL;
               conta_err := conta_err + 1;
            END IF;
         END LOOP;

         EXIT WHEN c_recibos_ahorro%NOTFOUND;
      END LOOP;

      CLOSE c_recibos_ahorro;

      RETURN conta_err;
   END f_commit_calcul_pppc;


   FUNCTION f_commit_calcul_pppc_pd(
      cempres IN NUMBER,
      aux_factual IN DATE,
      psproces IN NUMBER,
      pcidioma IN NUMBER,
      pcmoneda IN NUMBER,
      pmodo IN VARCHAR2 DEFAULT 'R',
      pmetodo IN NUMBER)
      RETURN NUMBER IS
      --{declaracion de variables}
      -- variables auxiliares
      wtexto         axis_literales.tlitera%TYPE;
      num_err        NUMBER := 0;
      conta_err      NUMBER;
      wnlinea        NUMBER;
      wfact          DATE := aux_factual;
      wffin          DATE;
      wfini          DATE;
      wcmodcom       NUMBER;
      wprorrata      NUMBER;
      wdiascorridos  NUMBER;
      wtotalvig      NUMBER;
      wprovcartera   NUMBER;
      wrecgastos     NUMBER;
      wpprima        NUMBER(5, 2);
      wmatriz        NUMBER;
      wexpd          NUMBER;
      wexpd_moncon   NUMBER;
      pfcambio       DATE;   -- fecha de cambio
      witasa         NUMBER;
      wprovcarteraeco NUMBER;
      wmatrizeco     NUMBER;
      wexpdeco       NUMBER;
      w_dias         NUMBER;
      w_tedad_mat    VARCHAR2(100);
      w_tedad        VARCHAR2(100);
      w_ratio_local  NUMBER := 1;
      w_ratio_matriz NUMBER := 1;
      -- BUG 20070/107545 - 20/02/2012 - JMP - Añadir contravalores en la moneda de la contabilidad
      w_cmoncon      parempresas.nvalpar%TYPE
                                     := pac_parametros.f_parempresa_n(cempres, 'MONEDACONTAB');
      -- Moneda de contablidad (numérico)
      w_cmoncon_t    monedas.cmonint%TYPE := pac_monedas.f_cmoneda_t(w_cmoncon);
                                                   -- Moneda de contablidad (texto)
         -- FIN BUG 20070/107545 - 20/02/2012 - JMP - Añadir contravalores en la moneda de la contabilidad
      -- Bug 0023130 - DCG - 25/09/2012 - LCOL_F002-Provisiones para polizas estatales
      xploccoa       NUMBER;
      xpneta         NUMBER;
      xpneta_mon     NUMBER;
      xinsertar      NUMBER;
      asseguro       NUMBER;
      anmovimi       NUMBER;
      numageco       NUMBER;
      v_por_parc     NUMBER;
      v_c_porc_parc  NUMBER;
      wprovcartera2  NUMBER;
      wprovcarteraeco2 NUMBER;
      wmatriz2       NUMBER;
      wmatrizeco2    NUMBER;
      -- Bug 0024261 - DCG - 20/12/2012 - LCOL_F002-Contabilidad Vida Grupo - F2
      xpneta_coa_coa NUMBER;
      xpneta_mon_coa_coa NUMBER;
      wprovcartera_coa NUMBER;
      wprovcarteraeco_coa NUMBER;
      wmatriz_coa    NUMBER;
      wmatrizeco_coa NUMBER;
      wrecgastos_coa NUMBER;
      -- 3. MMM Igualar cambios LCOL. 25. 0027593: MMM LCOL_F003-0008417 Error en el calculo de la provision para primas mayores a 76 dias - Inicio
      wrecgastos_moncon NUMBER;
      wrecgastos_coa_moncon NUMBER;


       -- Provisión Prima y Gastos
      wproprigas_promadincfecha NUMBER;
      wproprigas_promadmadfecha NUMBER;

       -- Provisión Prima_IVA y Gastos
      wpropriivagas_promadincfecha NUMBER;
      wpropriivagas_promadmadfecha NUMBER;
      wfechames    date;

      -- 3. MMM Igualar cambios LCOL. 25. 0027593: MMM LCOL_F003-0008417 Error en el calculo de la provision para primas mayores a 76 dias - Fin
      TYPE ARRAY IS TABLE OF c_recibos_ahorro%ROWTYPE;

      l_rec          ARRAY;

      CURSOR c_moratorio(pfini DATE, pffin DATE) IS
         SELECT   *
             FROM eco_tipocambio
            WHERE cmonori = 'MOR'
              AND((fcambio BETWEEN pfini AND pffin)
                  OR(fcambio = (SELECT MAX(fcambio)
                                  FROM eco_tipocambio
                                 WHERE cmonori = 'MOR'
                                   AND fcambio <= pfini)))
         ORDER BY fcambio;

      CURSOR c_meses(pfini DATE, pffin DATE) IS
         SELECT     LEVEL - 1 mes
               FROM DUAL
         CONNECT BY LEVEL <= CEIL(MONTHS_BETWEEN(pffin, pfini));

      v_ffin                  DATE;
      v_fini                  DATE;
      v_tasa                  NUMBER;
      v_dias_mora             NUMBER;
      v_siguiente             DATE;
      v_imora                 NUMBER := 0;
      v_dias_ano              NUMBER := 365;
      v_num_dias_anios        CONSTANT NUMBER := 365;
      v_iva                   NUMBER;

   BEGIN
      OPEN c_recibos_ahorro(aux_factual, cempres);

      LOOP
         FETCH c_recibos_ahorro
         BULK COLLECT INTO l_rec LIMIT 4000;

         FOR i IN 1 .. l_rec.COUNT LOOP
            BEGIN
               -- SMF 30/03/2012
               --se substituye el uso de  la función de f_fechainifin y se toma como fechas las del recibo
               --num_err := f_fechainifin(rec.sseguro, wfact, rec.fvencim, rec.fcaranu, wffin,
               --                         wfini, wprorrata, wcmodcom);

               num_err := 0;
               wfini := l_rec(i).fefecto;
               wffin := l_rec(i).fvencim;
               v_iva := l_rec(i).iva;

               IF num_err != 0 THEN
                  wtexto := f_axis_literales(num_err, pcidioma);
                  num_err := f_proceslin(psproces, wtexto || ' -PPPC 1', l_rec(i).sseguro,
                                         wnlinea);
                  wnlinea := NULL;
                  num_err := 104349;
               END IF;


               IF num_err = 0 THEN
                  wdiascorridos := wfact - wfini;

                  IF wdiascorridos = 366 THEN   -- SMF obra de arte según bug 21975
                     wdiascorridos := 365;
                  END IF;

                  wtotalvig := wffin - wfini;
                  wfechames :=trunc(aux_factual,'mm');


--IPH BUG 35149   IF (wfact - l_rec(i).fefecto) >= 75 THEN   -- USANDO PARAMETROS - DIASPPPC
                  IF (wfact - l_rec(i).fefecto) >=
                         NVL(pac_parametros.f_parproducto_n(l_rec(i).sproduc, 'DIAS_PPPC'), 75) THEN
                     wrecgastos := l_rec(i).pgastos;
                     wrecgastos_coa := l_rec(i).pgastos_coa;
                     --3. MMM - Igualar cambios LCOL. 25. MMM 0027593: LCOL_F003-0008417 Error en el calculo de la provision para primas mayores a 76 dias - Inicio
                     wrecgastos_moncon := l_rec(i).pgastos_monpol;
                     wrecgastos_coa_moncon := l_rec(i).pgastos_monpol_coa;
                  --3. MMM - Igualar cambios LCOL. 25. MMM 0027593: LCOL_F003-0008417 Error en el calculo de la provision para primas mayores a 76 dias - Fin
                  ELSE
                     wrecgastos := 0;
                     wrecgastos_coa := 0;
                     --3. MMM - Igualar cambios LCOL. 25. MMM 0027593: LCOL_F003-0008417 Error en el calculo de la provision para primas mayores a 76 dias - Inicio
                     wrecgastos_moncon := 0;
                     wrecgastos_coa_moncon := 0;
                  --3. MMM - Igualar cambios LCOL. 25. MMM 0027593: LCOL_F003-0008417 Error en el calculo de la provision para primas mayores a 76 dias - Inicio
                  END IF;

                  --miramos si se trata de una excepcion
                  BEGIN
                     SELECT pprima
                       INTO wpprima
                       FROM pppc_excep
                      WHERE sseguro = l_rec(i).sseguro
                        AND nrecibo = l_rec(i).nrecibo;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        BEGIN
                           SELECT pprima
                             INTO wpprima
                             FROM pppc_excep
                            WHERE sseguro = l_rec(i).sseguro
                              AND nrecibo = 0;
                        EXCEPTION
                           WHEN OTHERS THEN
                              wpprima := 1;
                        END;
                     WHEN OTHERS THEN
                        wpprima := 1;
                  END;


                  --miramos si se trata de una exclusion
                  xinsertar := 0;
                  BEGIN
                     SELECT count(*)
                       INTO xinsertar
                       FROM exclus_provisiones
                      WHERE nrecibo = l_rec(i).nrecibo;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        BEGIN
                           SELECT count(*)
                             INTO xinsertar
                             FROM exclus_provisiones
                            WHERE nrecibo = l_rec(i).nrecibo;
                         --     AND nrecibo = 0;
                        EXCEPTION
                           WHEN OTHERS THEN
                              xinsertar := 1;
                        END;
                     WHEN OTHERS THEN
                        xinsertar := 1;
                  END;


                  -- Bug 0023130 - DCG - 25/09/2012 - LCOL_F002-Provisiones para polizas estatales
                  BEGIN
                     SELECT ploccoa
                       INTO xploccoa
                       FROM coacuadro
                      WHERE ncuacoa = l_rec(i).ncuacoa
                        AND sseguro = l_rec(i).sseguro;

                     IF xploccoa IS NULL THEN
                        xploccoa := 0;
                     END IF;
                  EXCEPTION
                     WHEN OTHERS THEN
                        xploccoa := 0;
                  END;

                  v_por_parc :=
                     pac_adm_cobparcial.f_get_porcentaje_cobro_parcial(l_rec(i).nrecibo, NULL,
                                                                       NULL);
                  v_c_porc_parc := 1 - v_por_parc;

                  IF v_c_porc_parc = 0 THEN
                     v_c_porc_parc := 1;
                  END IF;

                  -- 3. MMM. Igualar codigo LCOL. 0027593: LCOL_F003-0008417 Error en el calculo de la provision - Igualar código con PAC_PROVTEC_LCOL - INICIO                  --Icv 31/01/2013 -- 24261
                  xpneta := l_rec(i).pneta * /*(100 - xploccoa)*/ v_c_porc_parc;   /*/ 100*/
                  xpneta_mon := l_rec(i).pneta_monpol * /*(100 - xploccoa) */ v_c_porc_parc;   /*/ 100*/
                  --25.0 MMM 0027593: LCOL_F003-0008417 Error en el calculo de la provision para primas mayores a 76 dias - Inicio
                  --wprovcartera := (((xpneta * wpprima) +(wrecgastos)) * wdiascorridos)
                  --                / wtotalvig;
                  wprovcartera := ((xpneta * wpprima * wdiascorridos) / wtotalvig)
                                  +(wrecgastos);

                  --25.0 MMM 0027593: LCOL_F003-0008417 Error en el calculo de la provision para primas mayores a 76 dias - Fin
                  --wprovcartera := LEAST(wprovcartera,(xpneta * wpprima) + wrecgastos); --radd 14/05/2013 26961

                  -- IPH BUG 35149 -- --IPH BUG 35149 : CAMBIAMOS LOS DIAS EN HARDCODE POR EL VALOR DEL PARAMETRO DIAS_PPPC
                   /*
                   IF l_rec(i).sproduc <> 339 THEN
                      IF wdiascorridos <= 75 THEN
                         wprovcartera := 0;
                      ELSE
                         wprovcartera := LEAST(ABS(wprovcartera),
                                               ABS((xpneta * wpprima) + wrecgastos))
                                         * SIGN(xpneta);   --radd  26961
                      END IF;
                   ELSIF l_rec(i).sproduc = 339 THEN
                      IF wdiascorridos < 31 THENñññññññllll
                         wprovcartera := 0;
                      ELSE
                         wprovcartera := LEAST(ABS(wprovcartera), ABS((xpneta) + wrecgastos))
                                         * SIGN(xpneta);   --radd  26961
                      END IF;
                   END IF;*/

               IF xpneta < 0 AND pmetodo = 2 THEN

                     wproprigas_promadincfecha := 0;
                     wproprigas_promadmadfecha := 0;
                  wpropriivagas_promadincfecha := 0;
                  wpropriivagas_promadmadfecha := 0;

               ELSE
                  -- Provisión Prima y Gastos
                  IF wdiascorridos < NVL(pac_parametros.f_parproducto_n(l_rec(i).sproduc, 'DIAS_PPPC'),75) THEN

                     wproprigas_promadincfecha := 0;

                  ELSIF  wdiascorridos > v_num_dias_anios THEN

                         wproprigas_promadincfecha := (xpneta + wrecgastos);

                  ELSE
                         wproprigas_promadincfecha := ((aux_factual-wfechames)*((xpneta + wrecgastos)/(case when wtotalvig > v_num_dias_anios then v_num_dias_anios else case when wtotalvig<-1 then case when wtotalvig<-32 then wtotalvig else 31 end else case when wtotalvig=0 then 1 else wtotalvig end  end end)));
                  END IF;


                  IF wdiascorridos < NVL(pac_parametros.f_parproducto_n(l_rec(i).sproduc, 'DIAS_PPPC'),75) THEN

                     wproprigas_promadmadfecha := 0;

                  ELSIF  wdiascorridos > v_num_dias_anios THEN

                         wproprigas_promadmadfecha := (xpneta + wrecgastos);

                  ELSE
                         wproprigas_promadmadfecha := (1+(aux_factual-wfechames))*((xpneta + wrecgastos)/(case when wtotalvig > v_num_dias_anios then v_num_dias_anios else case when wtotalvig<-1 then case when wtotalvig<-32 then wtotalvig else 31 end else case when wtotalvig=0 then 1 else wtotalvig end  end end));
                  END IF;


                  -- Provisión Prima_IVA y Gastos
                   IF wdiascorridos < NVL(pac_parametros.f_parproducto_n(l_rec(i).sproduc, 'DIAS_PPPC'),75) THEN

                     wpropriivagas_promadincfecha := 0;

                  ELSIF  wdiascorridos > v_num_dias_anios THEN

                         wpropriivagas_promadincfecha := (xpneta + v_iva + wrecgastos);

                  ELSE
                         wpropriivagas_promadincfecha := ((aux_factual-wfechames)*((xpneta + v_iva + wrecgastos)/(case when wtotalvig > v_num_dias_anios then v_num_dias_anios else case when wtotalvig<-1 then case when wtotalvig<-32 then wtotalvig else 31 end else case when wtotalvig=0 then 1 else wtotalvig end  end end)));
                  END IF;


                  IF wdiascorridos < NVL(pac_parametros.f_parproducto_n(l_rec(i).sproduc, 'DIAS_PPPC'),75) THEN

                     wpropriivagas_promadmadfecha := 0;

                  ELSIF  wdiascorridos > v_num_dias_anios THEN

                         wpropriivagas_promadmadfecha := (xpneta + v_iva + wrecgastos);

                  ELSE

                         wpropriivagas_promadmadfecha := (1+(aux_factual-wfechames))*((xpneta + v_iva + wrecgastos)/(case when wtotalvig > v_num_dias_anios then v_num_dias_anios else case when wtotalvig<-1 then case when wtotalvig<-32 then wtotalvig else 31 end else case when wtotalvig=0 then 1 else wtotalvig end  end end));

                  END IF;
               END IF;


                  --25.0 MMM 0027593: LCOL_F003-0008417 Error en el calculo de la provision para primas mayores a 76 dias - Inicio
                  --wprovcarteraeco := f_round((((xpneta_mon * wpprima) +(wrecgastos))
                  --                            * wdiascorridos)
                  --                           / wtotalvig,
                  --                           w_cmoncon);
                  wprovcarteraeco := f_round(((xpneta_mon * wpprima * wdiascorridos)
                                              / wtotalvig)
                                             +(wrecgastos_moncon),
                                             w_cmoncon);
                  --25.0 MMM 0027593: LCOL_F003-0008417 Error en el calculo de la provision para primas mayores a 76 dias - Fin
                  --wprovcarteraeco := LEAST(wprovcarteraeco,(xpneta_mon * wpprima) + wrecgastos);  --radd 14/05/2013  26961
                  wprovcarteraeco := f_round(LEAST(ABS(wprovcarteraeco),
                                                   ABS((xpneta_mon * wpprima)
                                                       + wrecgastos_moncon))
                                             * SIGN(xpneta_mon));   --radd 14/05/2013  26961
                  wmatriz := l_rec(i).itotalr * /*(100 - xploccoa)*/ v_c_porc_parc;   /*/ 100*/
                  wmatrizeco := l_rec(i).itotalr_monpol * /*(xploccoa)*/ v_c_porc_parc;   /*/ 100*/
-- Fin Bug 0023130

                  -- Bug 0024261 - DCG - 20/12/2012 - LCOL_F002-Contabilidad Vida Grupo - F2
                  xpneta_coa_coa := l_rec(i).pneta_coa /**(xploccoa)*/ * v_c_porc_parc;   /*/ 100*/
                  xpneta_mon_coa_coa := l_rec(i).pneta_monpol_coa   /**(xploccoa)*/
                                        * v_c_porc_parc;   /*/ 100*/
                  --25.0 MMM 0027593: LCOL_F003-0008417 Error en el calculo de la provision para primas mayores a 76 dias - Inicio
                  --wprovcartera_coa := (((xpneta_coa_coa * wpprima) +(wrecgastos_coa))
                  --                     * wdiascorridos)
                  --                    / wtotalvig;
                  wprovcartera_coa := ((xpneta_coa_coa * wpprima * wdiascorridos) / wtotalvig)
                                      +(wrecgastos_coa);

                     --25.0 MMM 0027593: LCOL_F003-0008417 Error en el calculo de la provision para primas mayores a 76 dias - Fin
                     --wprovcartera_coa := LEAST(wprovcartera_coa,
                     --                          (xpneta_coa_coa * wpprima) + wrecgastos_coa);   --radd 14/05/2013 26961
                    --IPH BUG 35149 : CAMBIAMOS LOS DIAS EN HARDCODE POR EL VALOR DEL PARAMETRO DIAS_PPPC
                  /*

                     IF l_rec(i).sproduc <> 339 THEN
                        IF wdiascorridos <= 75 THEN
                           wprovcartera_coa := 0;
                        ELSE
                           wprovcartera_coa := LEAST(ABS(wprovcartera_coa),
                                                     ABS((xpneta_coa_coa * wpprima)
                                                         + wrecgastos_coa))
                                               * SIGN(xpneta_coa_coa);
                        END IF;
                     ELSIF l_rec(i).sproduc = 339 THEN
                        IF wdiascorridos < 31 THEN
                           wprovcartera_coa := 0;
                        ELSE
                           wprovcartera_coa := LEAST(ABS(wprovcartera_coa),
                                                     ABS((xpneta_coa_coa) + wrecgastos_coa))
                                               * SIGN(xpneta_coa_coa);
                        END IF;
                     END IF; */
                  IF wdiascorridos < NVL(pac_parametros.f_parproducto_n(l_rec(i).sproduc,
                                                                        'DIAS_PPPC'),
                                         75) THEN
                     wprovcartera_coa := 0;
                  ELSE
                     wprovcartera_coa := LEAST(ABS(wprovcartera_coa),
                                               ABS((xpneta_coa_coa) + wrecgastos_coa))
                                         * SIGN(xpneta_coa_coa);
                  END IF;

                  --25.0 MMM 0027593: LCOL_F003-0008417 Error en el calculo de la provision para primas mayores a 76 dias - Inicio
                  --wprovcarteraeco_coa := f_round((((xpneta_mon_coa_coa * wpprima)
                  --                                 +(wrecgastos_coa))
                  --                                * wdiascorridos)
                  --                               / wtotalvig,
                  --                               w_cmoncon);
                  wprovcarteraeco_coa := f_round(((xpneta_mon_coa_coa * wpprima * wdiascorridos)
                                                  / wtotalvig)
                                                 +(wrecgastos_coa_moncon),
                                                 w_cmoncon);
                  --25.0 MMM 0027593: LCOL_F003-0008417 Error en el calculo de la provision para primas mayores a 76 dias - Fin
                  wprovcarteraeco_coa := f_round(LEAST(ABS(wprovcarteraeco_coa),
                                                       ABS((xpneta_mon_coa_coa * wpprima)
                                                           + wrecgastos_coa_moncon))
                                                 * SIGN(xpneta_mon_coa_coa));
                  wmatriz_coa := l_rec(i).itotalr_coa /**(xploccoa)*/ * v_c_porc_parc;   /*/ 100*/
                  wmatrizeco_coa := l_rec(i).itotalr_monpol_coa /**(xploccoa)*/ * v_c_porc_parc;   /*/ 100*/

                  -- Fin Bug 0023130
                  --  18.0 0026669: LCOL_F003-0007036: Provisi?n Gastos de Expedici?n - Inicio
                  --   IF (wfact - l_rec(i).fefecto) > 180 THEN   -- a partir de l 76 dias los gastos se provisionan al 100%
                -- BUG 35149 -- UTILIZAR PARAMETRO DIAS_PPPC EN LUGAR DE HARDCODE
--                 IF (wfact - l_rec(i).fefecto) > 76 THEN   -- a partir de l 76 dias los gastos se provisionan al 100%
                  IF (wfact - l_rec(i).fefecto) >
                         NVL(pac_parametros.f_parproducto_n(l_rec(i).sproduc, 'DIAS_PPPC'), 75) THEN
                     --  18.0 0026669: LCOL_F003-0007036: Provisi?n Gastos de Expedici?n - Final
                     wexpd := l_rec(i).pgastexp;
                     wexpd_moncon := f_round(l_rec(i).pgastexp_moncon, w_cmoncon);
                  ELSE
                     wexpd := 0;
                     wexpd_moncon := 0;
                  END IF;
               END IF;

                -- 3. MMM. Igualar codigo LCOL. 0027593: LCOL_F003-0008417 Error en el calculo de la provision - Igualar código con PAC_PROVTEC_LCOL - INICIO

               --{Se calculan los tramos de edad}
               w_dias := wfact - l_rec(i).fefecto;

               CASE
                  WHEN w_dias <= 30 THEN
                     w_tedad_mat := '0-30';
                  WHEN w_dias > 30
                  AND w_dias <= 60 THEN
                     w_tedad_mat := '31-60';
                  WHEN w_dias > 60
                  AND w_dias <= 90 THEN
                     w_tedad_mat := '61-90';
                  WHEN w_dias > 90
                  AND w_dias <= 180 THEN
                     w_tedad_mat := '91-180';
                  WHEN w_dias > 180
                  AND w_dias <= 270 THEN
                     w_tedad_mat := '181-270';
                  WHEN w_dias > 271
                  AND w_dias <= 360 THEN
                     w_tedad_mat := '271-360';
                  WHEN w_dias > 360 THEN
                     w_tedad_mat := '> 361';
               END CASE;

               CASE
                  WHEN w_dias <= 30 THEN
                     w_tedad := '0-30';
                  WHEN w_dias > 30
                  AND w_dias <= 60 THEN
                     w_tedad := '31-60';
                  WHEN w_dias > 60
                  AND w_dias <= 90 THEN
                     w_tedad := '61-90';
                  WHEN w_dias > 90
                  AND w_dias <= 180 THEN
                     w_tedad := '91-180';
                  WHEN w_dias > 180
                  AND w_dias <= 270 THEN
                     w_tedad := '181-270';
                  WHEN w_dias > 271
                  AND w_dias <= 360 THEN
                     w_tedad := '271-360';
                  WHEN w_dias > 360 THEN
                     w_tedad := '> 361';
               END CASE;


               --{calculamos  el importe del contravalor, lo guaradamos en los campos E Y
               -- y con la moneda definida para contabilidad}
               -- BUG 20070/107545 - 20/02/2012 - JMP - Añadir contravalores en la moneda de la contabilidad
               IF w_cmoncon = l_rec(i).cmoneda THEN
                  pfcambio := aux_factual;
                  witasa := 1;
               ELSE
                  -- 3. MMM. Igualar cambios LCOL. 24. MMM. 0027522: LCOL_PROD-0008272: Diferencia contabilidad amortizacion comisiones. INICIO
                     --pfcambio :=
                     --   pac_eco_tipocambio.f_fecha_max_cambio
                     --                                  (pac_monedas.f_cmoneda_t(l_rec(i).cmoneda),
                     --                                   w_cmoncon_t, aux_factual);
                  SELECT MAX(fcambio)
                    INTO pfcambio
                    FROM detrecibos d
                   WHERE d.nrecibo = l_rec(i).nrecibo;

                  -- 3. MMM. Igualar cambios LCOL. 24. MMM. 0027522: LCOL_PROD-0008272. FIN
                  IF pfcambio IS NULL THEN
                     num_err := 9902592;
                     wtexto := f_axis_literales(num_err, pcidioma);
                     num_err := f_proceslin(psproces, wtexto || ' -PPPC 2', l_rec(i).sseguro,
                                            wnlinea);
                     wnlinea := NULL;
                     num_err := 9902592;
                  -- No se ha encontrado el tipo de cambio entre monedas
                  END IF;

                  witasa :=
                     pac_eco_tipocambio.f_cambio(pac_monedas.f_cmoneda_t(l_rec(i).cmoneda),
                                                 w_cmoncon_t, pfcambio);
               END IF;

               -- FIN BUG 20070/107545 - 20/02/2012 - JMP - Añadir contravalores en la moneda de la contabilidad

               -- Bug 0023130 - DCG - 25/09/2012 - LCOL_F002-Provisiones para polizas estatales

                 xinsertar := 0;

               IF xinsertar = 0 THEN
                     -- BUG-NOTA: 35149-201457 FECHA: 07/04/2015 FSG Inicio...
                  --   BUG 35149 UTILIZAR EL PARAMETRO Y NO EL HARDCODE
                  --   IF w_dias < 75 THEN
                  IF w_dias < NVL(pac_parametros.f_parproducto_n(l_rec(i).sproduc,
                                                                 'DIAS_PPPC'),
                                  75) THEN
                     wprovcartera := 0;
                     wprovcarteraeco := 0;
                     wprovcartera_coa := 0;
                     wprovcarteraeco_coa := 0;
                  END IF;

                  -- BUG-NOTA: 35149-201457 FECHA: 07/04/2015 FSG Final.

                  --{Realizamos los insert corrspondientes}
                  IF pmodo = 'R' THEN
                     -- BUG 20070 - MAD - 03/01/2012
                     -- modificar la tabla pppc_pos

                     INSERT INTO pppc_conf
                                 (cempres, fcalcul, sproces, cramdgs,
                                  cramo, cmodali, ctipseg,
                                  ccolect, sseguro, nrecibo,
                                  nmovimi, finiefe, cgarant,
                                  nriesgo, ipppc, ipppc_moncon, iderreg,
                                  ipppc_coa, ipppc_moncon_coa,   -- Bug 0024261 - DCG - 20/12/2012 - LCOL_F002-Contabilidad Vida Grupo - F2
                                                              iderreg_moncon,
                                  cmoneda, cerror, tedad, fcambio, iprovmora, cmetodo)
                          VALUES (cempres, aux_factual, psproces, l_rec(i).cramdgs,
                                  l_rec(i).cramo, l_rec(i).cmodali, l_rec(i).ctipseg,
                                  l_rec(i).ccolect, l_rec(i).sseguro, l_rec(i).nrecibo,
                                  l_rec(i).nmovimi, l_rec(i).fefecto, l_rec(i).cgarant,
                                  l_rec(i).nriesgo, wproprigas_promadincfecha, wproprigas_promadmadfecha, wexpd,
                                  wpropriivagas_promadincfecha, wpropriivagas_promadmadfecha,   -- Bug 0024261 - DCG - 20/12/2012 - LCOL_F002-Contabilidad Vida Grupo - F2
                                                                        wexpd_moncon,
                                  l_rec(i).cmoneda, num_err, w_tedad, pfcambio, v_imora, pmetodo);


                  /*
                  -- insertar en la tabla pppc_pos_matriz
                  IF w_dias > 180 THEN
                     --BMS_OUTPUT.put_line('REAL_MATRIZ;' || l_rec(I).sseguro || ';'
                     --                     || l_rec(I).nrecibo);
                     INSERT INTO pppc_pos_matriz
                                 (cempres, fcalcul, sproces, cramdgs,
                                  cramo, cmodali, ctipseg,
                                  ccolect, sseguro, nrecibo,
                                  nmovimi, finiefe, cgarant,
                                  nriesgo, ipppmat, ipppmat_moncon, iderreg,
                                  iderreg_moncon, ipppmat_coa, ipppmat_moncon_coa,   -- Bug 0024261 - DCG - 20/12/2012 - LCOL_F002-Contabilidad Vida Grupo - F2
                                  cmoneda, cerror, tedad, fcambio)
                          VALUES (cempres, aux_factual, psproces, l_rec(i).cramdgs,
                                  l_rec(i).cramo, l_rec(i).cmodali, l_rec(i).ctipseg,
                                  l_rec(i).ccolect, l_rec(i).sseguro, l_rec(i).nrecibo,
                                  l_rec(i).nmovimi, l_rec(i).fefecto, l_rec(i).cgarant,
                                  l_rec(i).nriesgo, wmatriz, wmatrizeco, wexpd,
                                  wexpd_moncon, wmatriz_coa, wmatrizeco_coa,   -- Bug 0024261 - DCG - 20/12/2012 - LCOL_F002-Contabilidad Vida Grupo - F2
                                  l_rec(i).cmoneda, num_err, w_tedad, pfcambio);
                  END IF;
                  */
                  ELSE
                     -- BUG 20070 - MAD - 03/01/2012
                     -- modificar la tabla pppc_pos_previ
                     BEGIN
                     INSERT INTO pppc_conf_previ
                                 (cempres, fcalcul, sproces, cramdgs,
                                  cramo, cmodali, ctipseg,
                                  ccolect, sseguro, nrecibo,
                                  nmovimi, finiefe, cgarant,
                                  nriesgo, ipppc, ipppc_moncon, iderreg,
                                  ipppc_coa, ipppc_moncon_coa,   -- Bug 0024261 - DCG - 20/12/2012 - LCOL_F002-Contabilidad Vida Grupo - F2
                                                              iderreg_moncon,
                                  cmoneda, cerror, tedad, fcambio, iprovmora, cmetodo)
                          VALUES (cempres, aux_factual, psproces, nvl(l_rec(i).cramdgs,0),
                                  l_rec(i).cramo, l_rec(i).cmodali, l_rec(i).ctipseg,
                                  l_rec(i).ccolect, l_rec(i).sseguro, l_rec(i).nrecibo,
                                  l_rec(i).nmovimi, l_rec(i).fefecto, l_rec(i).cgarant,
                                  l_rec(i).nriesgo, wproprigas_promadincfecha, wproprigas_promadmadfecha, wexpd,
                                  wpropriivagas_promadincfecha, wpropriivagas_promadmadfecha,   -- Bug 0024261 - DCG - 20/12/2012 - LCOL_F002-Contabilidad Vida Grupo - F2
                                                                        wexpd_moncon,
                                  l_rec(i).cmoneda, num_err, w_tedad_mat, pfcambio, v_imora, pmetodo);
                    EXCEPTION
                    WHEN OTHERS THEN
                       p_tab_error(f_sysdate, f_user, 'pac_provtec_conf', 1,dbms_utility.format_error_backtrace , SQLERRM);
                    END;
                  /*
                  -- BUG 20070 - MAD - 03/01/2012-- insertar en la tabla pppc_pos_matriz_previ
                  IF w_dias > 180 THEN
                     --BMS_OUTPUT.put_line('PREVIO MATRIZ;' || l_rec(I).sseguro || ';'
                     --                     || l_rec(I).nrecibo || ';' || wmatrizeco);
                     INSERT INTO pppc_pos_matriz_previ
                                 (cempres, fcalcul, sproces, cramdgs,
                                  cramo, cmodali, ctipseg,
                                  ccolect, sseguro, nrecibo,
                                  nmovimi, finiefe, cgarant,
                                  nriesgo, ipppmat, ipppmat_moncon, iderreg,
                                  iderreg_moncon, ipppmat_coa, ipppmat_moncon_coa,   -- Bug 0024261 - DCG - 20/12/2012 - LCOL_F002-Contabilidad Vida Grupo - F2
                                  cmoneda, cerror, tedad, fcambio)
                          VALUES (cempres, aux_factual, psproces, l_rec(i).cramdgs,
                                  l_rec(i).cramo, l_rec(i).cmodali, l_rec(i).ctipseg,
                                  l_rec(i).ccolect, l_rec(i).sseguro, l_rec(i).nrecibo,
                                  l_rec(i).nmovimi, l_rec(i).fefecto, l_rec(i).cgarant,
                                  l_rec(i).nriesgo, wmatriz, wmatrizeco, wexpd,
                                  wexpd_moncon, wmatriz_coa, wmatrizeco_coa,   -- Bug 0024261 - DCG - 20/12/2012 - LCOL_F002-Contabilidad Vida Grupo - F2
                                  l_rec(i).cmoneda, num_err, w_tedad_mat, pfcambio);
                  END IF;
                  */

                  END IF;
               END IF;
            EXCEPTION
               WHEN OTHERS THEN
                  --ROLLBACK; RDD 25/02/2013 BUG:  26018; QTRACKER 6020;

                  wtexto := f_axis_literales(104349, pcidioma) || ' ERROR CON sseguro '
                            || l_rec(i).sseguro || '; RECIBO ' || l_rec(i).nrecibo || ';';
                  num_err := f_proceslin(psproces, wtexto || ' -PPPC 3 ', l_rec(i).sseguro,
                                         wnlinea);
                  conta_err := conta_err + 1;
                  wnlinea := NULL;
            --COMMIT;  RDD 25/02/2013 BUG:  26018; QTRACKER 6020;
            END;

            -- {Tratamiento de errores}
            IF num_err <> 0 THEN
               --BMS_OUTPUT.put_line('tratamiento de errores; sseguro ' || l_rec(i).sseguro
               --                     || ';' || l_rec(i).nrecibo || ';');
               wtexto := f_axis_literales(num_err, pcidioma) || ' ERROR CON sseguro '
                         || l_rec(i).sseguro || '; RECIBO ' || l_rec(i).nrecibo || ';';
               num_err := f_proceslin(psproces, wtexto || ' -PPPC 4', l_rec(i).sseguro,
                                      wnlinea);
               wnlinea := NULL;
               conta_err := conta_err + 1;
            END IF;
         END LOOP;

         EXIT WHEN c_recibos_ahorro%NOTFOUND;
      END LOOP;

      CLOSE c_recibos_ahorro;

      RETURN conta_err;
   END f_commit_calcul_pppc_pd;


   FUNCTION f_commit_calcul_pppc_oct(
      cempres IN NUMBER,
      aux_factual IN DATE,
      psproces IN NUMBER,
      pcidioma IN NUMBER,
      pcmoneda IN NUMBER,
      pmodo IN VARCHAR2 DEFAULT 'R')
      RETURN NUMBER IS
      --{declaracion de variables}
      -- variables auxiliares
      wtexto         axis_literales.tlitera%TYPE;
      num_err        NUMBER := 0;
      conta_err      NUMBER;
      wnlinea        NUMBER;
      wfact          DATE := aux_factual;
      wffin          DATE;
      wfini          DATE;
      wcmodcom       NUMBER;
      wprorrata      NUMBER;
      wdiascorridos  NUMBER;
      wtotalvig      NUMBER;
      wprovcartera   NUMBER;
      wrecgastos     NUMBER;
      wpprima        NUMBER(5, 2);
      wmatriz        NUMBER;
      wexpd          NUMBER;
      wexpd_moncon   NUMBER;
      pfcambio       DATE;   -- fecha de cambio
      witasa         NUMBER;
      wprovcarteraeco NUMBER;
      wmatrizeco     NUMBER;
      wexpdeco       NUMBER;
      w_dias         NUMBER;
      w_tedad_mat    VARCHAR2(100);
      w_tedad        VARCHAR2(100);
      w_ratio_local  NUMBER := 1;
      w_ratio_matriz NUMBER := 1;
      -- BUG 20070/107545 - 20/02/2012 - JMP - Añadir contravalores en la moneda de la contabilidad
      w_cmoncon      parempresas.nvalpar%TYPE
                                     := pac_parametros.f_parempresa_n(cempres, 'MONEDACONTAB');
      -- Moneda de contablidad (numérico)
      w_cmoncon_t    monedas.cmonint%TYPE := pac_monedas.f_cmoneda_t(w_cmoncon);
                                                   -- Moneda de contablidad (texto)
         -- FIN BUG 20070/107545 - 20/02/2012 - JMP - Añadir contravalores en la moneda de la contabilidad
      -- Bug 0023130 - DCG - 25/09/2012 - LCOL_F002-Provisiones para polizas estatales
      xploccoa       NUMBER;
      xpneta         NUMBER;
      xpneta_mon     NUMBER;
      xinsertar      NUMBER;
      asseguro       NUMBER;
      anmovimi       NUMBER;
      numageco       NUMBER;
      v_por_parc     NUMBER;
      v_c_porc_parc  NUMBER;
      wprovcartera2  NUMBER;
      wprovcarteraeco2 NUMBER;
      wmatriz2       NUMBER;
      wmatrizeco2    NUMBER;
      -- Bug 0024261 - DCG - 20/12/2012 - LCOL_F002-Contabilidad Vida Grupo - F2
      xpneta_coa_coa NUMBER;
      xpneta_mon_coa_coa NUMBER;
      wprovcartera_coa NUMBER;
      wprovcarteraeco_coa NUMBER;
      wmatriz_coa    NUMBER;
      wmatrizeco_coa NUMBER;
      wrecgastos_coa NUMBER;
      -- 3. MMM Igualar cambios LCOL. 25. 0027593: MMM LCOL_F003-0008417 Error en el calculo de la provision para primas mayores a 76 dias - Inicio
      wrecgastos_moncon NUMBER;
      wrecgastos_coa_moncon NUMBER;


       -- Campos nuevos
      wprovfecini         NUMBER;
      wprovfecexp         NUMBER;
      wprovfecini_veinte  NUMBER;
      wprovfecexp_veinte  NUMBER;
      wprovfecini_ochenta NUMBER;
      wprovfecexp_ochenta NUMBER;
      wprovfecoct         NUMBER;
      wtotaldoc           NUMBER;

      wfechames    date;

      -- 3. MMM Igualar cambios LCOL. 25. 0027593: MMM LCOL_F003-0008417 Error en el calculo de la provision para primas mayores a 76 dias - Fin
      TYPE ARRAY IS TABLE OF c_recibos_ahorro%ROWTYPE;

      l_rec          ARRAY;

      CURSOR c_moratorio(pfini DATE, pffin DATE) IS
         SELECT   *
             FROM eco_tipocambio
            WHERE cmonori = 'MOR'
              AND((fcambio BETWEEN pfini AND pffin)
                  OR(fcambio = (SELECT MAX(fcambio)
                                  FROM eco_tipocambio
                                 WHERE cmonori = 'MOR'
                                   AND fcambio <= pfini)))
         ORDER BY fcambio;

      CURSOR c_meses(pfini DATE, pffin DATE) IS
         SELECT     LEVEL - 1 mes
               FROM DUAL
         CONNECT BY LEVEL <= CEIL(MONTHS_BETWEEN(pffin, pfini));

      v_ffin                  DATE;
      v_fini                  DATE;
      v_tasa                  NUMBER;
      v_dias_mora             NUMBER;
      v_siguiente             DATE;
      v_imora                 NUMBER := 0;
      v_dias_ano              NUMBER := 365;
      v_iva                   NUMBER;
      v_num_dias_anios        CONSTANT NUMBER := 365;


   BEGIN
      OPEN c_recibos_ahorro(aux_factual, cempres);

      LOOP
         FETCH c_recibos_ahorro
         BULK COLLECT INTO l_rec LIMIT 4000;

         FOR i IN 1 .. l_rec.COUNT LOOP
            BEGIN
               -- SMF 30/03/2012
               --se substituye el uso de  la función de f_fechainifin y se toma como fechas las del recibo
               --num_err := f_fechainifin(rec.sseguro, wfact, rec.fvencim, rec.fcaranu, wffin,
               --                         wfini, wprorrata, wcmodcom);

               num_err := 0;
               wfini := l_rec(i).fefecto;
               wffin := l_rec(i).fvencim;
               v_iva := l_rec(i).iva;



               IF num_err != 0 THEN
                  wtexto := f_axis_literales(num_err, pcidioma);
                  num_err := f_proceslin(psproces, wtexto || ' -PPPC 1', l_rec(i).sseguro,
                                         wnlinea);
                  wnlinea := NULL;
                  num_err := 104349;
               END IF;


               IF num_err = 0 THEN
                  wdiascorridos := wfact - wfini;

                  IF wdiascorridos = 366 THEN   -- SMF obra de arte según bug 21975
                     wdiascorridos := 365;
                  END IF;

                  wtotalvig := wffin - wfini;
                  wfechames :=trunc(aux_factual,'mm');


--IPH BUG 35149   IF (wfact - l_rec(i).fefecto) >= 75 THEN   -- USANDO PARAMETROS - DIASPPPC
                  IF (wfact - l_rec(i).fefecto) >=
                         NVL(pac_parametros.f_parproducto_n(l_rec(i).sproduc, 'DIAS_PPPC'), 75) THEN
                     wrecgastos := l_rec(i).pgastos;
                     wrecgastos_coa := l_rec(i).pgastos_coa;
                     --3. MMM - Igualar cambios LCOL. 25. MMM 0027593: LCOL_F003-0008417 Error en el calculo de la provision para primas mayores a 76 dias - Inicio
                     wrecgastos_moncon := l_rec(i).pgastos_monpol;
                     wrecgastos_coa_moncon := l_rec(i).pgastos_monpol_coa;
                  --3. MMM - Igualar cambios LCOL. 25. MMM 0027593: LCOL_F003-0008417 Error en el calculo de la provision para primas mayores a 76 dias - Fin
                  ELSE
                     wrecgastos := 0;
                     wrecgastos_coa := 0;
                     --3. MMM - Igualar cambios LCOL. 25. MMM 0027593: LCOL_F003-0008417 Error en el calculo de la provision para primas mayores a 76 dias - Inicio
                     wrecgastos_moncon := 0;
                     wrecgastos_coa_moncon := 0;
                  --3. MMM - Igualar cambios LCOL. 25. MMM 0027593: LCOL_F003-0008417 Error en el calculo de la provision para primas mayores a 76 dias - Inicio
                  END IF;

                  --miramos si se trata de una excepcion
                  BEGIN
                     SELECT pprima
                       INTO wpprima
                       FROM pppc_excep
                      WHERE sseguro = l_rec(i).sseguro
                        AND nrecibo = l_rec(i).nrecibo;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        BEGIN
                           SELECT pprima
                             INTO wpprima
                             FROM pppc_excep
                            WHERE sseguro = l_rec(i).sseguro
                              AND nrecibo = 0;
                        EXCEPTION
                           WHEN OTHERS THEN
                              wpprima := 1;
                        END;
                     WHEN OTHERS THEN
                        wpprima := 1;
                  END;

                  --miramos si se trata de una exclusion
                  xinsertar := 0;
                  BEGIN
                     SELECT count(*)
                       INTO xinsertar
                       FROM exclus_provisiones
                      WHERE nrecibo = l_rec(i).nrecibo;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        BEGIN
                           SELECT count(*)
                             INTO xinsertar
                             FROM exclus_provisiones
                            WHERE nrecibo = l_rec(i).nrecibo;
                         --     AND nrecibo = 0;
                        EXCEPTION
                           WHEN OTHERS THEN
                              xinsertar := 1;
                        END;
                     WHEN OTHERS THEN
                        xinsertar := 1;
                  END;

                  -- Bug 0023130 - DCG - 25/09/2012 - LCOL_F002-Provisiones para polizas estatales
                  BEGIN
                     SELECT ploccoa
                       INTO xploccoa
                       FROM coacuadro
                      WHERE ncuacoa = l_rec(i).ncuacoa
                        AND sseguro = l_rec(i).sseguro;

                     IF xploccoa IS NULL THEN
                        xploccoa := 0;
                     END IF;
                  EXCEPTION
                     WHEN OTHERS THEN
                        xploccoa := 0;
                  END;

                  v_por_parc :=
                     pac_adm_cobparcial.f_get_porcentaje_cobro_parcial(l_rec(i).nrecibo, NULL,
                                                                       NULL);
                  v_c_porc_parc := 1 - v_por_parc;

                  IF v_c_porc_parc = 0 THEN
                     v_c_porc_parc := 1;
                  END IF;

                  -- 3. MMM. Igualar codigo LCOL. 0027593: LCOL_F003-0008417 Error en el calculo de la provision - Igualar código con PAC_PROVTEC_LCOL - INICIO                  --Icv 31/01/2013 -- 24261
                  xpneta := l_rec(i).pneta * /*(100 - xploccoa)*/ v_c_porc_parc;   /*/ 100*/
                  xpneta_mon := l_rec(i).pneta_monpol * /*(100 - xploccoa) */ v_c_porc_parc;   /*/ 100*/
                  --25.0 MMM 0027593: LCOL_F003-0008417 Error en el calculo de la provision para primas mayores a 76 dias - Inicio
                  --wprovcartera := (((xpneta * wpprima) +(wrecgastos)) * wdiascorridos)
                  --                / wtotalvig;
                  wprovcartera := ((xpneta * wpprima * wdiascorridos) / wtotalvig)
                                  +(wrecgastos);

                  --25.0 MMM 0027593: LCOL_F003-0008417 Error en el calculo de la provision para primas mayores a 76 dias - Fin
                  --wprovcartera := LEAST(wprovcartera,(xpneta * wpprima) + wrecgastos); --radd 14/05/2013 26961

                  -- IPH BUG 35149 -- --IPH BUG 35149 : CAMBIAMOS LOS DIAS EN HARDCODE POR EL VALOR DEL PARAMETRO DIAS_PPPC
                   /*
                   IF l_rec(i).sproduc <> 339 THEN
                      IF wdiascorridos <= 75 THEN
                         wprovcartera := 0;
                      ELSE
                         wprovcartera := LEAST(ABS(wprovcartera),
                                               ABS((xpneta * wpprima) + wrecgastos))
                                         * SIGN(xpneta);   --radd  26961
                      END IF;
                   ELSIF l_rec(i).sproduc = 339 THEN
                      IF wdiascorridos < 31 THENñññññññllll
                         wprovcartera := 0;
                      ELSE
                         wprovcartera := LEAST(ABS(wprovcartera), ABS((xpneta) + wrecgastos))
                                         * SIGN(xpneta);   --radd  26961
                      END IF;
                   END IF;*/


                  -- Inicio campos nuevos
                  IF wdiascorridos < NVL(pac_parametros.f_parproducto_n(l_rec(i).sproduc, 'DIAS_PPPC'),76) THEN
                        wprovfecini := 0;
                  ELSE
                        wprovfecini := (xpneta + wrecgastos);
                  END IF;

                  IF wdiascorridos < NVL(pac_parametros.f_parproducto_n(l_rec(i).sproduc, 'DIAS_PPPC'),76) THEN
                        wprovfecexp := 0;
                  ELSE
                        wprovfecexp := (xpneta + wrecgastos);
                  END IF;


                  -- 20 % prima
                  IF wdiascorridos < NVL(pac_parametros.f_parproducto_n(l_rec(i).sproduc, 'DIAS_PPPC'),76) THEN
                        wprovfecini_veinte := 0;
                  ELSE
                        wprovfecini_veinte := (((xpneta + wrecgastos) * 20) / 100);
                  END IF;

                  IF wdiascorridos < NVL(pac_parametros.f_parproducto_n(l_rec(i).sproduc, 'DIAS_PPPC'),76) THEN
                        wprovfecexp_veinte := 0;
                  ELSE
                        wprovfecexp_veinte := (((xpneta + wrecgastos) * 20) / 100);
                  END IF;



                  -- 80 % prima
                  IF wdiascorridos < NVL(pac_parametros.f_parproducto_n(l_rec(i).sproduc, 'DIAS_PPPC'),76) THEN
                        wprovfecini_ochenta := 0;
                  ELSE
                        wprovfecini_ochenta := (((xpneta + wrecgastos) * 80) / 100);
                  END IF;


                  IF wdiascorridos < NVL(pac_parametros.f_parproducto_n(l_rec(i).sproduc, 'DIAS_PPPC'),76) THEN
                        wprovfecexp_ochenta := 0;
                  ELSE
                        wprovfecexp_ochenta := (((xpneta + wrecgastos) * 80) / 100);
                  END IF;


                  -- Octavo
                  IF wdiascorridos < 76 THEN
                        wprovfecoct := 0;
                  ELSIF wdiascorridos < 91 THEN
                        wprovfecoct := ((((xpneta + wrecgastos) * 80) / 100) * 83 / 360);
                  ELSIF wdiascorridos < 181 THEN
                        wprovfecoct := ((((xpneta + wrecgastos) * 80) / 100) * 3 / 8);
                  ELSIF wdiascorridos < 271 THEN
                        wprovfecoct := ((((xpneta + wrecgastos) * 80) / 100) * 5 / 8);
                  ELSIF wdiascorridos < 360 THEN
                        wprovfecoct := ((((xpneta + wrecgastos) * 80) / 100) * 7 / 8);
                  ELSE
                        wprovfecoct := (((xpneta + wrecgastos) * 80) / 100);
                  END IF;


                  -- total
                       wtotaldoc := (xpneta + (xpneta  * 16 / 100) + wrecgastos);


                  --25.0 MMM 0027593: LCOL_F003-0008417 Error en el calculo de la provision para primas mayores a 76 dias - Inicio
                  --wprovcarteraeco := f_round((((xpneta_mon * wpprima) +(wrecgastos))
                  --                            * wdiascorridos)
                  --                           / wtotalvig,
                  --                           w_cmoncon);
                  wprovcarteraeco := f_round(((xpneta_mon * wpprima * wdiascorridos)
                                              / wtotalvig)
                                             +(wrecgastos_moncon),
                                             w_cmoncon);
                  --25.0 MMM 0027593: LCOL_F003-0008417 Error en el calculo de la provision para primas mayores a 76 dias - Fin
                  --wprovcarteraeco := LEAST(wprovcarteraeco,(xpneta_mon * wpprima) + wrecgastos);  --radd 14/05/2013  26961
                  wprovcarteraeco := f_round(LEAST(ABS(wprovcarteraeco),
                                                   ABS((xpneta_mon * wpprima)
                                                       + wrecgastos_moncon))
                                             * SIGN(xpneta_mon));   --radd 14/05/2013  26961
                  wmatriz := l_rec(i).itotalr * /*(100 - xploccoa)*/ v_c_porc_parc;   /*/ 100*/
                  wmatrizeco := l_rec(i).itotalr_monpol * /*(xploccoa)*/ v_c_porc_parc;   /*/ 100*/
-- Fin Bug 0023130

                  -- Bug 0024261 - DCG - 20/12/2012 - LCOL_F002-Contabilidad Vida Grupo - F2
                  xpneta_coa_coa := l_rec(i).pneta_coa /**(xploccoa)*/ * v_c_porc_parc;   /*/ 100*/
                  xpneta_mon_coa_coa := l_rec(i).pneta_monpol_coa   /**(xploccoa)*/
                                        * v_c_porc_parc;   /*/ 100*/
                  --25.0 MMM 0027593: LCOL_F003-0008417 Error en el calculo de la provision para primas mayores a 76 dias - Inicio
                  --wprovcartera_coa := (((xpneta_coa_coa * wpprima) +(wrecgastos_coa))
                  --                     * wdiascorridos)
                  --                    / wtotalvig;
                  wprovcartera_coa := ((xpneta_coa_coa * wpprima * wdiascorridos) / wtotalvig)
                                      +(wrecgastos_coa);

                     --25.0 MMM 0027593: LCOL_F003-0008417 Error en el calculo de la provision para primas mayores a 76 dias - Fin
                     --wprovcartera_coa := LEAST(wprovcartera_coa,
                     --                          (xpneta_coa_coa * wpprima) + wrecgastos_coa);   --radd 14/05/2013 26961
                    --IPH BUG 35149 : CAMBIAMOS LOS DIAS EN HARDCODE POR EL VALOR DEL PARAMETRO DIAS_PPPC
                  /*

                     IF l_rec(i).sproduc <> 339 THEN
                        IF wdiascorridos <= 75 THEN
                           wprovcartera_coa := 0;
                        ELSE
                           wprovcartera_coa := LEAST(ABS(wprovcartera_coa),
                                                     ABS((xpneta_coa_coa * wpprima)
                                                         + wrecgastos_coa))
                                               * SIGN(xpneta_coa_coa);
                        END IF;
                     ELSIF l_rec(i).sproduc = 339 THEN
                        IF wdiascorridos < 31 THEN
                           wprovcartera_coa := 0;
                        ELSE
                           wprovcartera_coa := LEAST(ABS(wprovcartera_coa),
                                                     ABS((xpneta_coa_coa) + wrecgastos_coa))
                                               * SIGN(xpneta_coa_coa);
                        END IF;
                     END IF; */
                  IF wdiascorridos < NVL(pac_parametros.f_parproducto_n(l_rec(i).sproduc,
                                                                        'DIAS_PPPC'),
                                         75) THEN
                     wprovcartera_coa := 0;
                  ELSE
                     wprovcartera_coa := LEAST(ABS(wprovcartera_coa),
                                               ABS((xpneta_coa_coa) + wrecgastos_coa))
                                         * SIGN(xpneta_coa_coa);
                  END IF;

                  --25.0 MMM 0027593: LCOL_F003-0008417 Error en el calculo de la provision para primas mayores a 76 dias - Inicio
                  --wprovcarteraeco_coa := f_round((((xpneta_mon_coa_coa * wpprima)
                  --                                 +(wrecgastos_coa))
                  --                                * wdiascorridos)
                  --                               / wtotalvig,
                  --                               w_cmoncon);
                  wprovcarteraeco_coa := f_round(((xpneta_mon_coa_coa * wpprima * wdiascorridos)
                                                  / wtotalvig)
                                                 +(wrecgastos_coa_moncon),
                                                 w_cmoncon);
                  --25.0 MMM 0027593: LCOL_F003-0008417 Error en el calculo de la provision para primas mayores a 76 dias - Fin
                  wprovcarteraeco_coa := f_round(LEAST(ABS(wprovcarteraeco_coa),
                                                       ABS((xpneta_mon_coa_coa * wpprima)
                                                           + wrecgastos_coa_moncon))
                                                 * SIGN(xpneta_mon_coa_coa));
                  wmatriz_coa := l_rec(i).itotalr_coa /**(xploccoa)*/ * v_c_porc_parc;   /*/ 100*/
                  wmatrizeco_coa := l_rec(i).itotalr_monpol_coa /**(xploccoa)*/ * v_c_porc_parc;   /*/ 100*/

                  -- Fin Bug 0023130
                  --  18.0 0026669: LCOL_F003-0007036: Provisi?n Gastos de Expedici?n - Inicio
                  --   IF (wfact - l_rec(i).fefecto) > 180 THEN   -- a partir de l 76 dias los gastos se provisionan al 100%
                -- BUG 35149 -- UTILIZAR PARAMETRO DIAS_PPPC EN LUGAR DE HARDCODE
--                 IF (wfact - l_rec(i).fefecto) > 76 THEN   -- a partir de l 76 dias los gastos se provisionan al 100%
                  IF (wfact - l_rec(i).fefecto) >
                         NVL(pac_parametros.f_parproducto_n(l_rec(i).sproduc, 'DIAS_PPPC'), 75) THEN
                     --  18.0 0026669: LCOL_F003-0007036: Provisi?n Gastos de Expedici?n - Final
                     wexpd := l_rec(i).pgastexp;
                     wexpd_moncon := f_round(l_rec(i).pgastexp_moncon, w_cmoncon);
                  ELSE
                     wexpd := 0;
                     wexpd_moncon := 0;
                  END IF;
               END IF;

                -- 3. MMM. Igualar codigo LCOL. 0027593: LCOL_F003-0008417 Error en el calculo de la provision - Igualar código con PAC_PROVTEC_LCOL - INICIO

               --{Se calculan los tramos de edad}
               w_dias := wfact - l_rec(i).fefecto;

               CASE
                  WHEN w_dias <= 30 THEN
                     w_tedad_mat := '0-30';
                  WHEN w_dias > 30
                  AND w_dias <= 60 THEN
                     w_tedad_mat := '31-60';
                  WHEN w_dias > 60
                  AND w_dias <= 90 THEN
                     w_tedad_mat := '61-90';
                  WHEN w_dias > 90
                  AND w_dias <= 180 THEN
                     w_tedad_mat := '91-180';
                  WHEN w_dias > 180
                  AND w_dias <= 270 THEN
                     w_tedad_mat := '181-270';
                  WHEN w_dias > 271
                  AND w_dias <= 360 THEN
                     w_tedad_mat := '271-360';
                  WHEN w_dias > 360 THEN
                     w_tedad_mat := '> 361';
               END CASE;

               CASE
                  WHEN w_dias <= 30 THEN
                     w_tedad := '0-30';
                  WHEN w_dias > 30
                  AND w_dias <= 60 THEN
                     w_tedad := '31-60';
                  WHEN w_dias > 60
                  AND w_dias <= 90 THEN
                     w_tedad := '61-90';
                  WHEN w_dias > 90
                  AND w_dias <= 180 THEN
                     w_tedad := '91-180';
                  WHEN w_dias > 180
                  AND w_dias <= 270 THEN
                     w_tedad := '181-270';
                  WHEN w_dias > 271
                  AND w_dias <= 360 THEN
                     w_tedad := '271-360';
                  WHEN w_dias > 360 THEN
                     w_tedad := '> 361';
               END CASE;


               --{calculamos  el importe del contravalor, lo guaradamos en los campos E Y
               -- y con la moneda definida para contabilidad}
               -- BUG 20070/107545 - 20/02/2012 - JMP - Añadir contravalores en la moneda de la contabilidad
               IF w_cmoncon = l_rec(i).cmoneda THEN
                  pfcambio := aux_factual;
                  witasa := 1;
               ELSE
                  -- 3. MMM. Igualar cambios LCOL. 24. MMM. 0027522: LCOL_PROD-0008272: Diferencia contabilidad amortizacion comisiones. INICIO
                     --pfcambio :=
                     --   pac_eco_tipocambio.f_fecha_max_cambio
                     --                                  (pac_monedas.f_cmoneda_t(l_rec(i).cmoneda),
                     --                                   w_cmoncon_t, aux_factual);
                  SELECT MAX(fcambio)
                    INTO pfcambio
                    FROM detrecibos d
                   WHERE d.nrecibo = l_rec(i).nrecibo;

                  -- 3. MMM. Igualar cambios LCOL. 24. MMM. 0027522: LCOL_PROD-0008272. FIN
                  IF pfcambio IS NULL THEN
                     num_err := 9902592;
                     wtexto := f_axis_literales(num_err, pcidioma);
                     num_err := f_proceslin(psproces, wtexto || ' -PPPC 2', l_rec(i).sseguro,
                                            wnlinea);
                     wnlinea := NULL;
                     num_err := 9902592;
                  -- No se ha encontrado el tipo de cambio entre monedas
                  END IF;

                  witasa :=
                     pac_eco_tipocambio.f_cambio(pac_monedas.f_cmoneda_t(l_rec(i).cmoneda),
                                                 w_cmoncon_t, pfcambio);
               END IF;

               -- FIN BUG 20070/107545 - 20/02/2012 - JMP - Añadir contravalores en la moneda de la contabilidad

               -- Bug 0023130 - DCG - 25/09/2012 - LCOL_F002-Provisiones para polizas estatales
               xinsertar := 0;





               IF xinsertar = 0 THEN
                     -- BUG-NOTA: 35149-201457 FECHA: 07/04/2015 FSG Inicio...
                  --   BUG 35149 UTILIZAR EL PARAMETRO Y NO EL HARDCODE
                  --   IF w_dias < 75 THEN
                  IF w_dias < NVL(pac_parametros.f_parproducto_n(l_rec(i).sproduc,
                                                                 'DIAS_PPPC'),
                                  75) THEN
                     wprovcartera := 0;
                     wprovcarteraeco := 0;
                     wprovcartera_coa := 0;
                     wprovcarteraeco_coa := 0;
                  END IF;

                  -- BUG-NOTA: 35149-201457 FECHA: 07/04/2015 FSG Final.

                  --{Realizamos los insert corrspondientes}
                  IF pmodo = 'R' THEN
                     -- BUG 20070 - MAD - 03/01/2012
                     -- modificar la tabla pppc_pos

                     INSERT INTO PPPC_CONF_OCT
                                 (cempres, fcalcul, sproces, cramdgs,
                                  cramo, cmodali, ctipseg,
                                  ccolect, sseguro, nrecibo,
                                  nmovimi, finiefe, cgarant,
                                  nriesgo, ipppc, ipppc_moncon, iderreg,
                                  ipppc_coa, ipppc_moncon_coa,   -- Bug 0024261 - DCG - 20/12/2012 - LCOL_F002-Contabilidad Vida Grupo - F2
                                                              iderreg_moncon,
                                  cmoneda, cerror, tedad, fcambio, iprovmora,
                                  iprovfecini, iprovfecexp, iprovfecini_veinte,
                                  iprovfecexp_veinte, iprovfecini_ochenta, iprovfecexp_ochenta,
                                  iprovfecoct, itotaldoc)
                          VALUES (cempres, aux_factual, psproces, l_rec(i).cramdgs,
                                  l_rec(i).cramo, l_rec(i).cmodali, l_rec(i).ctipseg,
                                  l_rec(i).ccolect, l_rec(i).sseguro, l_rec(i).nrecibo,
                                  l_rec(i).nmovimi, l_rec(i).fefecto, l_rec(i).cgarant,
                                  l_rec(i).nriesgo, null, null, wexpd,
                                  null, null,   -- Bug 0024261 - DCG - 20/12/2012 - LCOL_F002-Contabilidad Vida Grupo - F2
                                                                        wexpd_moncon,
                                  l_rec(i).cmoneda, num_err, w_tedad, pfcambio, v_imora,
                                  wprovfecini, wprovfecexp, wprovfecini_veinte,
                                  wprovfecexp_veinte, wprovfecini_ochenta, wprovfecexp_ochenta,
                                  wprovfecoct, wtotaldoc);


                  /*
                  -- insertar en la tabla pppc_pos_matriz
                  IF w_dias > 180 THEN
                     --BMS_OUTPUT.put_line('REAL_MATRIZ;' || l_rec(I).sseguro || ';'
                     --                     || l_rec(I).nrecibo);
                     INSERT INTO pppc_pos_matriz
                                 (cempres, fcalcul, sproces, cramdgs,
                                  cramo, cmodali, ctipseg,
                                  ccolect, sseguro, nrecibo,
                                  nmovimi, finiefe, cgarant,
                                  nriesgo, ipppmat, ipppmat_moncon, iderreg,
                                  iderreg_moncon, ipppmat_coa, ipppmat_moncon_coa,   -- Bug 0024261 - DCG - 20/12/2012 - LCOL_F002-Contabilidad Vida Grupo - F2
                                  cmoneda, cerror, tedad, fcambio)
                          VALUES (cempres, aux_factual, psproces, l_rec(i).cramdgs,
                                  l_rec(i).cramo, l_rec(i).cmodali, l_rec(i).ctipseg,
                                  l_rec(i).ccolect, l_rec(i).sseguro, l_rec(i).nrecibo,
                                  l_rec(i).nmovimi, l_rec(i).fefecto, l_rec(i).cgarant,
                                  l_rec(i).nriesgo, wmatriz, wmatrizeco, wexpd,
                                  wexpd_moncon, wmatriz_coa, wmatrizeco_coa,   -- Bug 0024261 - DCG - 20/12/2012 - LCOL_F002-Contabilidad Vida Grupo - F2
                                  l_rec(i).cmoneda, num_err, w_tedad, pfcambio);
                  END IF;
                  */
                  ELSE
                     -- BUG 20070 - MAD - 03/01/2012
                     -- modificar la tabla pppc_pos_previ
                     BEGIN
                     INSERT INTO PPPC_CONF_OCT_PREVI
                                 (cempres, fcalcul, sproces, cramdgs,
                                  cramo, cmodali, ctipseg,
                                  ccolect, sseguro, nrecibo,
                                  nmovimi, finiefe, cgarant,
                                  nriesgo, ipppc, ipppc_moncon, iderreg,
                                  ipppc_coa, ipppc_moncon_coa,   -- Bug 0024261 - DCG - 20/12/2012 - LCOL_F002-Contabilidad Vida Grupo - F2
                                                              iderreg_moncon,
                                  cmoneda, cerror, tedad, fcambio, iprovmora,
                                  iprovfecini, iprovfecexp, iprovfecini_veinte,
                                  iprovfecexp_veinte, iprovfecini_ochenta, iprovfecexp_ochenta,
                                  iprovfecoct, itotaldoc)
                          VALUES (cempres, aux_factual, psproces, nvl(l_rec(i).cramdgs,0),
                                  l_rec(i).cramo, l_rec(i).cmodali, l_rec(i).ctipseg,
                                  l_rec(i).ccolect, l_rec(i).sseguro, l_rec(i).nrecibo,
                                  l_rec(i).nmovimi, l_rec(i).fefecto, l_rec(i).cgarant,
                                  l_rec(i).nriesgo, 1, 1, wexpd,
                                  1, 1,   -- Bug 0024261 - DCG - 20/12/2012 - LCOL_F002-Contabilidad Vida Grupo - F2
                                                                        wexpd_moncon,
                                  l_rec(i).cmoneda, num_err, w_tedad_mat, pfcambio, v_imora,
                                  wprovfecini, wprovfecexp, wprovfecini_veinte,
                                  wprovfecexp_veinte, wprovfecini_ochenta, wprovfecexp_ochenta,
                                  wprovfecoct, wtotaldoc);
                    EXCEPTION
                    WHEN OTHERS THEN
                       p_tab_error(f_sysdate, f_user, 'pac_provtec_conf', 1,dbms_utility.format_error_backtrace , SQLERRM);
                    END;
                  /*
                  -- BUG 20070 - MAD - 03/01/2012-- insertar en la tabla pppc_pos_matriz_previ
                  IF w_dias > 180 THEN
                     --BMS_OUTPUT.put_line('PREVIO MATRIZ;' || l_rec(I).sseguro || ';'
                     --                     || l_rec(I).nrecibo || ';' || wmatrizeco);
                     INSERT INTO pppc_pos_matriz_previ
                                 (cempres, fcalcul, sproces, cramdgs,
                                  cramo, cmodali, ctipseg,
                                  ccolect, sseguro, nrecibo,
                                  nmovimi, finiefe, cgarant,
                                  nriesgo, ipppmat, ipppmat_moncon, iderreg,
                                  iderreg_moncon, ipppmat_coa, ipppmat_moncon_coa,   -- Bug 0024261 - DCG - 20/12/2012 - LCOL_F002-Contabilidad Vida Grupo - F2
                                  cmoneda, cerror, tedad, fcambio)
                          VALUES (cempres, aux_factual, psproces, l_rec(i).cramdgs,
                                  l_rec(i).cramo, l_rec(i).cmodali, l_rec(i).ctipseg,
                                  l_rec(i).ccolect, l_rec(i).sseguro, l_rec(i).nrecibo,
                                  l_rec(i).nmovimi, l_rec(i).fefecto, l_rec(i).cgarant,
                                  l_rec(i).nriesgo, wmatriz, wmatrizeco, wexpd,
                                  wexpd_moncon, wmatriz_coa, wmatrizeco_coa,   -- Bug 0024261 - DCG - 20/12/2012 - LCOL_F002-Contabilidad Vida Grupo - F2
                                  l_rec(i).cmoneda, num_err, w_tedad_mat, pfcambio);
                  END IF;
                  */

                  END IF;
               END IF;
            EXCEPTION
               WHEN OTHERS THEN
                  --ROLLBACK; RDD 25/02/2013 BUG:  26018; QTRACKER 6020;

                  wtexto := f_axis_literales(104349, pcidioma) || ' ERROR CON sseguro '
                            || l_rec(i).sseguro || '; RECIBO ' || l_rec(i).nrecibo || ';';
                  num_err := f_proceslin(psproces, wtexto || ' -PPPC 3 ', l_rec(i).sseguro,
                                         wnlinea);
                  conta_err := conta_err + 1;
                  wnlinea := NULL;
            --COMMIT;  RDD 25/02/2013 BUG:  26018; QTRACKER 6020;
            END;

            -- {Tratamiento de errores}
            IF num_err <> 0 THEN
               --BMS_OUTPUT.put_line('tratamiento de errores; sseguro ' || l_rec(i).sseguro
               --                     || ';' || l_rec(i).nrecibo || ';');
               wtexto := f_axis_literales(num_err, pcidioma) || ' ERROR CON sseguro '
                         || l_rec(i).sseguro || '; RECIBO ' || l_rec(i).nrecibo || ';';
               num_err := f_proceslin(psproces, wtexto || ' -PPPC 4', l_rec(i).sseguro,
                                      wnlinea);
               wnlinea := NULL;
               conta_err := conta_err + 1;
            END IF;
         END LOOP;

         EXIT WHEN c_recibos_ahorro%NOTFOUND;
      END LOOP;

      CLOSE c_recibos_ahorro;

      RETURN conta_err;
   END f_commit_calcul_pppc_oct;


   FUNCTION f_commit_calcul_rtpi(
      cempres IN NUMBER,
      aux_factual IN DATE,
      psproces IN NUMBER,
      pcidioma IN NUMBER,
      pcmoneda IN NUMBER,
      pmodo IN VARCHAR2 DEFAULT 'R')
      RETURN NUMBER IS
      conta_err      NUMBER := 0;
   BEGIN
      --contiene cargas , fase 0b
      RETURN conta_err;
   END;

   -- Bug 002207f_commit_calcul_amocom2 - 30/04/2012 - JMF
   FUNCTION f_commit_calcul_amocom(
      pcempres IN NUMBER,
      aux_factual IN DATE,
      psproces IN NUMBER,
      pcidioma IN NUMBER,
      pcmoneda IN NUMBER,
      pmodo IN VARCHAR2 DEFAULT 'R')
      RETURN NUMBER IS
      -- {  declaració de variables necessaries pel proces}
      -- control de error
      conta_err      NUMBER := 0;
      num_err        NUMBER := 0;
      -- Fechas
      wfini          DATE;   -- fecha inicio vigencia
      wffin          DATE;   -- fecha final vigencia
      wfact          DATE := aux_factual;
                                                              -- fecha actual
      -- Variables auxiliares
      wprorrata      NUMBER;   -- prorrata aplicada
      wcmodcom       NUMBER;   --  modo comision
      wnlinea        NUMBER;   -- linea del procesoslin
      wreasingarant  NUMBER;
      -- semaforo para marcar que se asigna todo el reaseguro a la 1ª garantia
      wpretenc       NUMBER;
      -- Variables de tipo texto
      wtexto         literales.tlitera%TYPE;
      wc             NUMBER;   -- Porcentaje de comisión básic
      wfprtre        NUMBER := 1;
--**** Factor por  riesgo a transcurrir puede ser uno o el valor que establezca el usuario
      pfcambio       DATE;   -- Fecha del cambio vigente a la fecha actual
      witasa         NUMBER(15, 2);   -- Tasa vigente
      wprimanivel    NUMBER := 0;
      wcresp43       NUMBER;
      wcresp27       NUMBER;
      wnmovimi       NUMBER := 0;
      wfcaranu_aux   DATE;
      -- BUG 20070/107545 - 20/02/2012 - JMP - Añadir contravalores en la moneda de la contabilidad
      w_cmoncon      parempresas.nvalpar%TYPE
                                    := pac_parametros.f_parempresa_n(pcempres, 'MONEDACONTAB');
      -- Moneda de contablidad (numérico)
      w_cmoncon_t    monedas.cmonint%TYPE := pac_monedas.f_cmoneda_t(w_cmoncon);
                                             -- Moneda de contablidad (texto)
      -- FIN BUG 20070/107545 - 20/02/2012 - JMP - Añadir contravalores en la moneda de la contabilidad

      -- Ini Bug 21550 - MDS - 29/02/2012
      w_icage        upr.icage%TYPE := 0;
      w_icadn        upr.icadn%TYPE := 0;
      w_icage_nc     upr.icage_nc%TYPE := 0;
      w_icadn_nc     upr.icadn_nc%TYPE := 0;
      wcalprev       DATE;
      wprorratacom   NUMBER;
      wdias          NUMBER := 0;
      v_dias_pror    NUMBER := 0;
      -- 12. Bug 0024261 - 17/01/2013 - LCOL_F002-Contabilidad Vida Grupo - F2 / 0133453 - Inicio
      vicage_moncon  prov_amocom.icage_moncon%TYPE;
      vicadn_moncon  prov_amocom.icadn_moncon%TYPE;
      vicage_nc_moncon prov_amocom.icage_nc_moncon%TYPE;
      vicadn_nc_moncon prov_amocom.icadn_nc_moncon%TYPE;
      w_icage_coa    prov_amocom.icage_coa%TYPE;
      w_icadn_coa    prov_amocom.icadn_coa%TYPE;
      w_icage_nc_coa prov_amocom.icage_nc_coa%TYPE;
      w_icadn_nc_coa prov_amocom.icadn_nc_coa%TYPE;
      vicage_coa     prov_amocom.icage_coa%TYPE;
      vicadn_coa     prov_amocom.icadn_coa%TYPE;
      vicage_nc_coa  prov_amocom.icage_nc_coa%TYPE;
      vicadn_nc_coa  prov_amocom.icadn_nc_coa%TYPE;
      vicage_moncon_coa prov_amocom.icage_moncon_coa%TYPE;
      vicadn_moncon_coa prov_amocom.icadn_moncon_coa%TYPE;
      vicage_nc_moncon_coa prov_amocom.icage_nc_moncon_coa%TYPE;
      vicadn_nc_moncon_coa prov_amocom.icadn_nc_moncon_coa%TYPE;
      vicage         upr.icage%TYPE := 0;
      vicadn         upr.icadn%TYPE := 0;
      vicage_nc      upr.icage_nc%TYPE := 0;
      vicadn_nc      upr.icadn_nc%TYPE := 0;
      vprocoa        NUMBER;
      wiconcep       NUMBER;
      wctiprec       NUMBER;

      -- 12. Bug 0024261 - 17/01/2013 - LCOL_F002-Contabilidad Vida Grupo - F2 / 0133453 - Fin
      CURSOR c_recibo(pfecha IN DATE, empresa IN NUMBER) IS
         SELECT s.npoliza, d.*, r.fefecto, r.fvencim, s.sseguro,
                pac_monedas.f_cmoneda_t(p.cdivisa) cmoneda_t, p.cdivisa cmoneda, r.nmovimi,
                r.ctiprec, r.sperson, r.cagente
           FROM recibos r, detrecibos d, seguros s, productos p, movrecibo mr
          WHERE r.sseguro = s.sseguro
            AND r.nrecibo = d.nrecibo
            AND p.sproduc = s.sproduc
            AND r.fefecto <> r.fvencim
            -- bug 23720 ( los recibos con duración cero no se amortizan, ni los de comisiones de ahorro.
            AND r.ctiprec <> 5
            AND r.fefecto <= pfecha
            AND(r.fvencim >= TO_DATE('01/' || TO_CHAR(pfecha, 'MM/YYYY'), 'dd/mm/yyyy')   -- Bug 0024542 - 02/11/2012 - DCG
                OR NOT EXISTS(SELECT '1'
                                FROM prov_amocom
                               WHERE nrecibo = r.nrecibo))
            AND(d.cconcep = 11
-- Bug 0024261 - DCG - 21/11/2012 - LCOL_F002-Contabilidad Vida Grupo - F2
                OR(d.cconcep = 0
                   AND r.ctiprec IN(13, 15)))
-- FIN - Bug 0024261 - DCG
-- smf : se modifica para que tome las comisiones, no el importe de comisión devengado
            AND r.cempres = empresa
            AND r.cestaux = 0
            -- 28.0 - MMM - 0027851: LCOL_PROD-0008825: Diferencia contabilidad amortizacion comisiones P?liza 2457 - Inicio
            AND mr.nrecibo = r.nrecibo
            AND mr.smovrec = (SELECT MAX(mr1.smovrec)
                                FROM movrecibo mr1
                               WHERE mr1.nrecibo = mr.nrecibo
                                 AND mr1.fmovdia <= pfecha)
            AND mr.cestrec <> 2;

      --AND f_cestrec_mv(r.nrecibo, 2, pfecha) <> 2;

      /*AND 2 <> (SELECT cestrec
                  FROM movrecibo m
                 WHERE m.nrecibo = r.nrecibo
                   AND m.fmovfin IS NULL);*/
      -- 28.0 - MMM - 0027851: LCOL_PROD-0008825: Diferencia contabilidad amortizacion comisiones P?liza 2457 - Fin
      CURSOR c_recibo_retro(pfecha IN DATE, empresa IN NUMBER) IS
         SELECT DISTINCT r.nrecibo, r.ctiprec, r.fefecto, r.fvencim, d.iconcep,

                         -- 28.0 - MMM - 0027851: LCOL_PROD-0008825: Diferencia contabilidad amortizacion comisiones P?liza 2457  - Inicio
                         d.iconcep_monpol,
                                          -- 28.0 - MMM - 0027851: LCOL_PROD-0008825: Diferencia contabilidad amortizacion comisiones P?liza 2457  - Fin
                                          pac_monedas.f_cmoneda_t(p.cdivisa) cmoneda_t,
                         p.cdivisa cmoneda, d.cgarant, r.nmovimi, d.nriesgo, r.sseguro,
                         d.cconcep, r.sperson, r.cagente
                    FROM recibos r, detrecibos d, movrecibo m, seguros s, productos p
                   WHERE m.nrecibo = r.nrecibo
                     AND m.nrecibo = d.nrecibo
                     AND(d.cconcep = 11
                         -- Bug 0024261 - DCG - 21/11/2012 - LCOL_F002-Contabilidad Vida Grupo - F2
                         OR(d.cconcep = 0
                            AND r.ctiprec IN(13, 15)))
                     -- FIN - Bug 0024261 - DCG
                     AND s.sseguro = r.sseguro
                     AND r.cestaux = 0
                     AND s.sproduc = p.sproduc
                     --AND f_cestrec_mv(r.nrecibo, 2, pfecha) = 2
                                                               -- Esta anulado
                     --DCG
                     AND TRUNC(m.fmovdia) > TO_DATE('26/07/2012', 'dd/mm/yyyy')
                     AND m.nrecibo = r.nrecibo
                     AND m.smovrec = (SELECT MAX(mr.smovrec)
                                        FROM movrecibo mr
                                       WHERE mr.nrecibo = m.nrecibo
                                         AND mr.fmovdia <= pfecha)
                     AND m.cestrec = 2
                     -- INI Bug 0024542 - 02/11/2012 - DCG
                     AND r.nrecibo IN(SELECT nrecibo
                                        FROM prov_amocom)
--                     AND TRUNC(m.fmovini) < TO_DATE('27/07/2012', 'dd/mm/yyyy')
                     -- FIN Bug 0024542 - 02/11/2012 - DCG
                     -- 28.0 - MMM - 0027851: LCOL_PROD-0008825: Diferencia contabilidad amortizacion comisiones P?liza 2457 - Inicio
                     --AND 0 <= (SELECT NVL(SUM(icage), 0)
                     -- Condicion para que la anulacion solo la trate la primera vez
                     AND 0 <= (SELECT NVL(SUM(DECODE(r.ctiprec, 9, -icage, 15, -icage, icage)),
                                          0)
                                      + NVL(SUM(DECODE(r.ctiprec, 9, -icadn, 15, -icadn, icadn)),
                                            0)
                                 FROM prov_amocom
                                WHERE nrecibo = r.nrecibo
                                  AND fcalcul = (SELECT MAX(fcalcul)
                                                   FROM prov_amocom
                                                  WHERE nrecibo = m.nrecibo));
     /*   SELECT p.*, r.ctiprec
           FROM recibos r, detrecibos d, prov_amocom p, movrecibo m
          WHERE p.nrecibo = r.nrecibo
            AND m.nrecibo = p.nrecibo
            AND cestrec = 2
            AND fmovfin IS NULL
            AND m.fmovini BETWEEN pfecha AND ADD_MONTHS(pfecha, -1);*/
   -- Fin Bug 21550 - MDS - 29/02/2012
   BEGIN
      FOR rec IN c_recibo(aux_factual, pcempres) LOOP
         num_err := f_difdata(rec.fefecto, rec.fvencim, 3, 3, wdias);
         -- código comentado ya no se utiliza la comisión devengada--
         /*   IF NVL(pac_parametros.f_parempresa_n(pcempres, 'DIAS_PROR_REAL'), 0) = 0 THEN
               v_dias_pror := 360;
            ELSE
               --Dias reales de la anualidad
               --el mod 4 solo no sirve para saber si es bisiesto, lo más facil es restar fechas del año
               v_dias_pror := TO_DATE('3112' || TO_CHAR(wfini, 'yyyy'), 'ddmmyyyy')
                              - TO_DATE('0101' || TO_CHAR(wfini, 'yyyy'), 'ddmmyyyy') + 1;
            END IF;*/
         -- SMF Al no utilizar la prima devengada hay que calcular la prorrata por recibo
         num_err := f_difdata(rec.fefecto, rec.fvencim, 3, 3, v_dias_pror);

         IF NVL(v_dias_pror, 0) = 0 THEN
            v_dias_pror := 1;
         END IF;

         wprorrata := wdias / v_dias_pror;

         SELECT MAX(fcalcul)
           INTO wcalprev
           FROM prov_amocom
          WHERE cempres = pcempres
            AND sseguro = rec.sseguro
            AND nriesgo = rec.nriesgo
            AND nrecibo = rec.nrecibo
            AND cgarant = rec.cgarant
            AND fcalcul < aux_factual;

         num_err := f_difdata(GREATEST(rec.fefecto, NVL(wcalprev, rec.fefecto)),
                              LEAST(aux_factual, rec.fvencim), 3, 3, wdias);
         wprorratacom := wdias / v_dias_pror;

         -- Ini Bug 21550 - MDS - 29/02/2012
-- 13. Bug 0024261 - 29/01/2013 - LCOL_F002-Contabilidad Vida Grupo - F2 / 0136601 - Inicio
--         w_icage := wprorrata * rec.iconcep;
--         w_icadn := 0;   -- De momento a 0
--         w_icage_nc := rec.iconcep * wprorratacom;
--         w_icadn_nc := 0;   -- De momento a 0
         -- 13. Bug 0024261 - 29/01/2013 - LCOL_F002-Contabilidad Vida Grupo - F2 / 0136601 - Fin

         -- BMS_OUTPUT.put_line('R' || eso.npoliza || ' ' || eso.cgarant || ' ' || w_icage
         --                      || '  ' || w_icage_nc || '  '
          --                     || GREATEST(eso.fefecto, NVL(wcalprev, eso.fefecto)) || '  '
           --                    || LEAST(aux_factual, eso.fvencim) || ' ' || wdias || ' ');
         IF rec.cmoneda = w_cmoncon THEN
            witasa := 1;
            pfcambio := aux_factual;
         ELSE
            pfcambio := pac_eco_tipocambio.f_fecha_max_cambio(rec.cmoneda_t, w_cmoncon_t,
                                                              aux_factual);

            IF pfcambio IS NULL THEN
               wtexto := f_axis_literales(num_err, pcidioma);
               num_err := f_proceslin(psproces, wtexto || ' -AMOCOM', 9902592, wnlinea);
               wnlinea := NULL;
               num_err := 9902592;
            -- No se ha encontrado el tipo de cambio entre monedas
            END IF;

            witasa := pac_eco_tipocambio.f_cambio(rec.cmoneda_t, w_cmoncon_t, pfcambio);
         END IF;

         -- 13. Bug 0024261 - 29/01/2013 - LCOL_F002-Contabilidad Vida Grupo - F2 / 0136601 - Inicio
         -- Calcula la parte del coaseguro (cconcep = 61 y 50, este último cunado r.ctiprec IN(13, 15))  así también quedarán incluidos
         -- los cálculos de prorratas por fechas, tasas, moncon.
         BEGIN
            IF rec.cconcep = 11 THEN
               SELECT x.iconcep, y.ctiprec
                 INTO wiconcep, wctiprec
                 FROM detrecibos x, recibos y
                WHERE x.nrecibo = y.nrecibo
                  AND x.nrecibo = rec.nrecibo
                  AND x.nriesgo = rec.nriesgo
                  AND x.cgarant = rec.cgarant
                  AND x.cconcep = 61;
            ELSE
               SELECT x.iconcep, y.ctiprec
                 INTO wiconcep, wctiprec
                 FROM detrecibos x, recibos y
                WHERE x.nrecibo = y.nrecibo
                  AND x.nrecibo = rec.nrecibo
                  AND x.nriesgo = rec.nriesgo
                  AND x.cgarant = rec.cgarant
                  AND x.cconcep = 50
                  AND y.ctiprec IN(13, 15);
            END IF;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               wiconcep := 0;
               wctiprec := 0;
         END;

         w_icage := wprorrata *(rec.iconcep);
         w_icadn := 0;   -- De momento a 0
         w_icage_nc := (rec.iconcep) * wprorratacom;
         w_icadn_nc := 0;   -- De momento a 0
         w_icage_coa := wprorrata * wiconcep;
         w_icadn_coa := 0;   -- De momento a 0
         w_icage_nc_coa := wiconcep * wprorratacom;
         w_icadn_nc_coa := 0;   -- De momento a 0

--17.0         27/02/2013  DCG              0025872: LCOL_F002-Revisi?n Qtrackers contabilidad F2 (Nota: 0139248) (Cambiamos el 13 por el 15)
         SELECT DECODE(rec.ctiprec, 9, -1, 15, -1, 1) * w_icage,
                DECODE(rec.ctiprec, 9, -1, 15, -1, 1) * w_icadn,
                DECODE(rec.ctiprec, 9, -1, 15, -1, 1) * w_icage_nc,
                DECODE(rec.ctiprec, 9, -1, 15, -1, 1) * w_icadn_nc,
                DECODE
                   (rec.ctiprec,
                    9, -1,
                    15, -1,
                    1)   -- Bug 0024261 - DCG - 21/11/2012 - LCOL_F002-Contabilidad Vida Grupo - F2
                * f_round(f_round(w_icage, rec.cmoneda) * witasa, w_cmoncon),
                DECODE
                   (rec.ctiprec,
                    9, -1,
                    15, -1,
                    1)   -- Bug 0024261 - DCG - 21/11/2012 - LCOL_F002-Contabilidad Vida Grupo - F2
                * f_round(f_round(w_icadn, rec.cmoneda) * witasa, w_cmoncon),
                DECODE
                   (rec.ctiprec,
                    9, -1,
                    15, -1,
                    1)   -- Bug 0024261 - DCG - 21/11/2012 - LCOL_F002-Contabilidad Vida Grupo - F2
                * f_round(f_round(w_icage_nc, rec.cmoneda) * witasa, w_cmoncon),
                DECODE
                   (rec.ctiprec,
                    9, -1,
                    15, -1,
                    1)   -- Bug 0024261 - DCG - 21/11/2012 - LCOL_F002-Contabilidad Vida Grupo - F2
                * f_round(f_round(w_icadn_nc, rec.cmoneda) * witasa, w_cmoncon)
           INTO vicage,
                vicadn,
                vicage_nc,
                vicadn_nc,
                vicage_moncon,
                vicadn_moncon,
                vicage_nc_moncon,
                vicadn_nc_moncon
           FROM DUAL;

--17.0         27/02/2013  DCG              0025872: LCOL_F002-Revisi?n Qtrackers contabilidad F2 (Nota: 0139248) (Cambiamos el 13 por el 15)
         SELECT DECODE(wctiprec, 9, -1, 15, -1, 1) * w_icage_coa,
                DECODE(wctiprec, 9, -1, 15, -1, 1) * w_icadn_coa,
                DECODE(wctiprec, 9, -1, 15, -1, 1) * w_icage_nc_coa,
                DECODE(wctiprec, 9, -1, 15, -1, 1) * w_icadn_nc_coa,
                DECODE(wctiprec, 9, -1, 15, -1, 1)
                * f_round(f_round(w_icage_coa, rec.cmoneda) * witasa, w_cmoncon),
                DECODE(wctiprec, 9, -1, 15, -1, 1)
                * f_round(f_round(w_icadn_coa, rec.cmoneda) * witasa, w_cmoncon),
                DECODE(wctiprec, 9, -1, 15, -1, 1)
                * f_round(f_round(w_icage_nc_coa, rec.cmoneda) * witasa, w_cmoncon),
                DECODE(wctiprec, 9, -1, 15, -1, 1)
                * f_round(f_round(w_icadn_nc_coa, rec.cmoneda) * witasa, w_cmoncon)
           INTO vicage_coa,
                vicadn_coa,
                vicage_nc_coa,
                vicadn_nc_coa,
                vicage_moncon_coa,
                vicadn_moncon_coa,
                vicage_nc_moncon_coa,
                vicadn_nc_moncon_coa
           FROM DUAL;

         -- 13. Bug 0024261 - 29/01/2013 - LCOL_F002-Contabilidad Vida Grupo - F2 / 0136601 - Fin
         IF pmodo = 'P' THEN
            BEGIN
               INSERT INTO prov_amocom_previo
                           (cempres, fcalcul, sproces, sseguro, nriesgo,
                            nmovimi, cgarant, icage, icadn, icage_nc, icadn_nc,
                            icage_moncon, icadn_moncon, icage_nc_moncon, icadn_nc_moncon,
                            fcambio, cmoneda, nrecibo,
                            fefecto,
                            ffincal, fvencim
                                            -- 13. Bug 0024261 - 29/01/2013 - LCOL_F002-Contabilidad Vida Grupo - F2 / 0136601 - Inicio
               ,            icage_coa,
                            icadn_coa, icage_nc_coa, icadn_nc_coa, icage_moncon_coa,
                            icadn_moncon_coa, icage_nc_moncon_coa, icadn_nc_moncon_coa
                                                                                      -- 13. Bug 0024261 - 29/01/2013 - LCOL_F002-Contabilidad Vida Grupo - F2 / 0136601 - Fin
                           )
                    VALUES (pcempres, aux_factual, psproces, rec.sseguro, rec.nriesgo,
                            rec.nmovimi, rec.cgarant,
                                                     -- 13. Bug 0024261 - 29/01/2013 - LCOL_F002-Contabilidad Vida Grupo - F2 / 0136601 - Inicio
                                                     vicage, vicadn, vicage_nc, vicadn_nc,
                            vicage_moncon, vicadn_moncon, vicage_nc_moncon, vicadn_nc_moncon,
                            -- 13. Bug 0024261 - 29/01/2013 - LCOL_F002-Contabilidad Vida Grupo - F2 / 0136601 - Fin
                            pfcambio, rec.cmoneda, rec.nrecibo,
                            GREATEST(rec.fefecto, NVL(wcalprev, rec.fefecto)),
                            LEAST(aux_factual, rec.fvencim), rec.fvencim, vicage_coa,
                            vicadn_coa, vicage_nc_coa, vicadn_nc_coa, vicage_moncon_coa,
                            vicadn_moncon_coa, vicage_nc_moncon_coa, vicadn_nc_moncon_coa);
            EXCEPTION
               WHEN OTHERS THEN
                  num_err := 108468;   -- error al insertar en la tabla
            END;
         ELSIF pmodo = 'R' THEN
            BEGIN
               INSERT INTO prov_amocom
                           (cempres, fcalcul, sproces, sseguro, nriesgo,
                            nmovimi, cgarant, icage, icadn, icage_nc, icadn_nc,
                            icage_moncon, icadn_moncon, icage_nc_moncon, icadn_nc_moncon,
                            fcambio, cmoneda, nrecibo,
                            fefecto,
                            ffincal, fvencim
                                            -- 13. Bug 0024261 - 29/01/2013 - LCOL_F002-Contabilidad Vida Grupo - F2 / 0136601 - Inicio
               ,            icage_coa,
                            icadn_coa, icage_nc_coa, icadn_nc_coa, icage_moncon_coa,
                            icadn_moncon_coa, icage_nc_moncon_coa, icadn_nc_moncon_coa
                                                                                      -- 13. Bug 0024261 - 29/01/2013 - LCOL_F002-Contabilidad Vida Grupo - F2 / 0136601 - Fin
                           )
                    VALUES (pcempres, aux_factual, psproces, rec.sseguro, rec.nriesgo,
                            rec.nmovimi, rec.cgarant,
                                       -- 13. Bug 0024261 - 29/01/2013 - LCOL_F002-Contabilidad Vida Grupo - F2 / 0136601 - Inicio
--                                                      w_icage, w_icadn, w_icage_nc,
--                            w_icadn_nc,
                                       /*
                                       DECODE
                                          (rec.ctiprec,
                                           9, -1,
                                           13, -1,
                                           1)   -- Bug 0024261 - DCG - 21/11/2012 - LCOL_F002-Contabilidad Vida Grupo - F2
                                       * f_round(f_round(w_icage, rec.cmoneda) * witasa, w_cmoncon),
                                       DECODE
                                          (rec.ctiprec,
                                           9, -1,
                                           13, -1,
                                           1)   -- Bug 0024261 - DCG - 21/11/2012 - LCOL_F002-Contabilidad Vida Grupo - F2
                                       * f_round(f_round(w_icadn, rec.cmoneda) * witasa, w_cmoncon),
                                       DECODE
                                          (rec.ctiprec,
                                           9, -1,
                                           13, -1,
                                           1)   -- Bug 0024261 - DCG - 21/11/2012 - LCOL_F002-Contabilidad Vida Grupo - F2
                                       * f_round(f_round(w_icage_nc, rec.cmoneda) * witasa, w_cmoncon),
                                       DECODE
                                          (rec.ctiprec,
                                           9, -1,
                                           13, -1,
                                           1)   -- Bug 0024261 - DCG - 21/11/2012 - LCOL_F002-Contabilidad Vida Grupo - F2
                                       * f_round(f_round(w_icadn_nc, rec.cmoneda) * witasa, w_cmoncon),
                                       */
                                                     vicage, vicadn, vicage_nc, vicadn_nc,
                            vicage_moncon, vicadn_moncon, vicage_nc_moncon, vicadn_nc_moncon,
                            -- 13. Bug 0024261 - 29/01/2013 - LCOL_F002-Contabilidad Vida Grupo - F2 / 0136601 - Fin
                            pfcambio, rec.cmoneda, rec.nrecibo,
                            GREATEST(rec.fefecto, NVL(wcalprev, rec.fefecto)),
                            LEAST(aux_factual, rec.fvencim), rec.fvencim, vicage_coa,
                            vicadn_coa, vicage_nc_coa, vicadn_nc_coa, vicage_moncon_coa,
                            vicadn_moncon_coa, vicage_nc_moncon_coa, vicadn_nc_moncon_coa);
            EXCEPTION
               WHEN OTHERS THEN
                  num_err := 108468;   -- error al insertar en la tabla
            END;
         ELSE
            RETURN 9000505;   -- Error de parametres
         END IF;
      END LOOP;

      -- anulaciones de recibos
      FOR anu IN c_recibo_retro(aux_factual, pcempres) LOOP
         num_err := f_difdata(anu.fefecto, anu.fvencim, 3, 3, wdias);
         -- código comentado ya no se utiliza la comisión devengada--
         num_err := f_difdata(anu.fefecto, anu.fvencim, 3, 3, v_dias_pror);

         IF NVL(v_dias_pror, 0) = 0 THEN
            v_dias_pror := 1;
         END IF;

         wprorrata := wdias / v_dias_pror;

         SELECT MAX(fcalcul)
           INTO wcalprev
           FROM prov_amocom
          WHERE cempres = pcempres
            AND sseguro = anu.sseguro
            AND nriesgo = anu.nriesgo
            AND nrecibo = anu.nrecibo
            AND cgarant = anu.cgarant
            AND fcalcul < aux_factual;

         num_err := f_difdata(anu.fefecto, LEAST(wcalprev, anu.fvencim), 3, 3, wdias);
         wprorratacom := wdias / v_dias_pror;

         -- Ini Bug 21550 - MDS - 29/02/2012
-- 13. Bug 0024261 - 29/01/2013 - LCOL_F002-Contabilidad Vida Grupo - F2 / 0136601 - Inicio
--         w_icage := wprorrata * anu.iconcep * -1;
--         w_icadn := 0;   -- De momento a 0
--         w_icage_nc := anu.iconcep * wprorratacom * -1;
--         w_icadn_nc := 0;   -- De momento a 0
-- 13. Bug 0024261 - 29/01/2013 - LCOL_F002-Contabilidad Vida Grupo - F2 / 0136601 - Fin
         IF anu.cmoneda = w_cmoncon THEN
            witasa := 1;
            pfcambio := aux_factual;
         ELSE
            pfcambio := pac_eco_tipocambio.f_fecha_max_cambio(anu.cmoneda_t, w_cmoncon_t,
                                                              aux_factual);

            IF pfcambio IS NULL THEN
               wtexto := f_axis_literales(num_err, pcidioma);
               num_err := f_proceslin(psproces, wtexto || ' -AMOCOM', 9902592, wnlinea);
               wnlinea := NULL;
               num_err := 9902592;
            -- No se ha encontrado el tipo de cambio entre monedas
            END IF;

            witasa := pac_eco_tipocambio.f_cambio(anu.cmoneda_t, w_cmoncon_t, pfcambio);
         END IF;

-- 13. Bug 0024261 - 29/01/2013 - LCOL_F002-Contabilidad Vida Grupo - F2 / 0136601 - Inicio
         BEGIN
            IF anu.cconcep = 11 THEN
               SELECT x.iconcep, y.ctiprec
                 INTO wiconcep, wctiprec
                 FROM detrecibos x, recibos y
                WHERE x.nrecibo = y.nrecibo
                  AND x.nrecibo = anu.nrecibo
                  AND x.nriesgo = anu.nriesgo
                  AND x.cgarant = anu.cgarant
                  AND x.cconcep = 61;
            ELSE
               SELECT x.iconcep, y.ctiprec
                 INTO wiconcep, wctiprec
                 FROM detrecibos x, recibos y
                WHERE x.nrecibo = y.nrecibo
                  AND x.nrecibo = anu.nrecibo
                  AND x.nriesgo = anu.nriesgo
                  AND x.cgarant = anu.cgarant
                  AND x.cconcep = 50
                  AND y.ctiprec IN(13, 15);
            END IF;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               wiconcep := 0;
               wctiprec := 0;
         END;

         w_icage := wprorrata *(anu.iconcep) * -1;
         w_icadn := 0;   -- De momento a 0
         w_icage_nc := (anu.iconcep) * wprorratacom * -1;
         w_icadn_nc := 0;   -- De momento a 0
         w_icage_coa := wprorrata * wiconcep * -1;
         w_icadn_coa := 0;   -- De momento a 0
         w_icage_nc_coa := wiconcep * wprorratacom * -1;
         w_icadn_nc_coa := 0;   -- De momento a 0

--17.0         27/02/2013  DCG              0025872: LCOL_F002-Revisi?n Qtrackers contabilidad F2 (Nota: 0139248) (Cambiamos el 13 por el 15)
         SELECT DECODE(anu.ctiprec, 9, -1, 15, -1, 1) * w_icage,
                DECODE(anu.ctiprec, 9, -1, 15, -1, 1) * w_icadn,
                DECODE(anu.ctiprec, 9, -1, 15, -1, 1) * w_icage_nc,
                DECODE(anu.ctiprec, 9, -1, 15, -1, 1) * w_icadn_nc,
                DECODE
                   (anu.ctiprec,
                    9, -1,
                    15, -1,
                    1)   -- Bug 0024261 - DCG - 21/11/2012 - LCOL_F002-Contabilidad Vida Grupo - F2
                * f_round(f_round(w_icage, anu.cmoneda) * witasa, w_cmoncon),
                DECODE
                   (anu.ctiprec,
                    9, -1,
                    15, -1,
                    1)   -- Bug 0024261 - DCG - 21/11/2012 - LCOL_F002-Contabilidad Vida Grupo - F2
                * f_round(f_round(w_icadn, anu.cmoneda) * witasa, w_cmoncon),
                DECODE
                   (anu.ctiprec,
                    9, -1,
                    15, -1,
                    1)   -- Bug 0024261 - DCG - 21/11/2012 - LCOL_F002-Contabilidad Vida Grupo - F2
                * f_round(f_round(w_icage_nc, anu.cmoneda) * witasa, w_cmoncon),
                DECODE
                   (anu.ctiprec,
                    9, -1,
                    15, -1,
                    1)   -- Bug 0024261 - DCG - 21/11/2012 - LCOL_F002-Contabilidad Vida Grupo - F2
                * f_round(f_round(w_icadn_nc, anu.cmoneda) * witasa, w_cmoncon)
           INTO vicage,
                vicadn,
                vicage_nc,
                vicadn_nc,
                vicage_moncon,
                vicadn_moncon,
                vicage_nc_moncon,
                vicadn_nc_moncon
           FROM DUAL;

--17.0         27/02/2013  DCG              0025872: LCOL_F002-Revisi?n Qtrackers contabilidad F2 (Nota: 0139248) (Cambiamos el 13 por el 15)
         SELECT DECODE(wctiprec, 9, -1, 15, -1, 1) * w_icage_coa,
                DECODE(wctiprec, 9, -1, 15, -1, 1) * w_icadn_coa,
                DECODE(wctiprec, 9, -1, 15, -1, 1) * w_icage_nc_coa,
                DECODE(wctiprec, 9, -1, 15, -1, 1) * w_icadn_nc_coa,
                DECODE(wctiprec, 9, -1, 15, -1, 1)
                * f_round(f_round(w_icage_coa, anu.cmoneda) * witasa, w_cmoncon),
                DECODE(wctiprec, 9, -1, 15, -1, 1)
                * f_round(f_round(w_icadn_coa, anu.cmoneda) * witasa, w_cmoncon),
                DECODE(wctiprec, 9, -1, 15, -1, 1)
                * f_round(f_round(w_icage_nc_coa, anu.cmoneda) * witasa, w_cmoncon),
                DECODE(wctiprec, 9, -1, 15, -1, 1)
                * f_round(f_round(w_icadn_nc_coa, anu.cmoneda) * witasa, w_cmoncon)
           INTO vicage_coa,
                vicadn_coa,
                vicage_nc_coa,
                vicadn_nc_coa,
                vicage_moncon_coa,
                vicadn_moncon_coa,
                vicage_nc_moncon_coa,
                vicadn_nc_moncon_coa
           FROM DUAL;

-- 13. Bug 0024261 - 29/01/2013 - LCOL_F002-Contabilidad Vida Grupo - F2 / 0136601 - Fin
         IF pmodo = 'P' THEN
            BEGIN
               INSERT INTO prov_amocom_previo
                           (cempres, fcalcul, sproces, sseguro, nriesgo,
                            nmovimi, cgarant, icage, icadn, icage_nc, icadn_nc,
                            icage_moncon, icadn_moncon, icage_nc_moncon, icadn_nc_moncon,
                            fcambio, cmoneda, nrecibo, fefecto,
                            ffincal, fvencim
                                            -- 13. Bug 0024261 - 29/01/2013 - LCOL_F002-Contabilidad Vida Grupo - F2 / 0136601 - Inicio
               ,            icage_coa,
                            icadn_coa, icage_nc_coa, icadn_nc_coa, icage_moncon_coa,
                            icadn_moncon_coa, icage_nc_moncon_coa, icadn_nc_moncon_coa
                                                                                      -- 13. Bug 0024261 - 29/01/2013 - LCOL_F002-Contabilidad Vida Grupo - F2 / 0136601 - Fin
                           )
                    VALUES (pcempres, aux_factual, psproces, anu.sseguro, anu.nriesgo,
                            anu.nmovimi, anu.cgarant,
                                                                               -- 13. Bug 0024261 - 29/01/2013 - LCOL_F002-Contabilidad Vida Grupo - F2 / 0136601 - Inicio
                                                                               /*
                                                                               w_icage, w_icadn, w_icage_nc,
                                                     w_icadn_nc,
                                                     DECODE
                                                        (anu.ctiprec,
                                                         9, -1,
                                                         13, -1,
                                                         1)   -- Bug 0024261 - DCG - 21/11/2012 - LCOL_F002-Contabilidad Vida Grupo - F2
                                                     * f_round(f_round(w_icage, anu.cmoneda) * witasa, w_cmoncon),
                                                     DECODE
                                                        (anu.ctiprec,
                                                         9, -1,
                                                         13, -1,
                                                         1)   -- Bug 0024261 - DCG - 21/11/2012 - LCOL_F002-Contabilidad Vida Grupo - F2
                                                     * f_round(f_round(w_icadn, anu.cmoneda) * witasa, w_cmoncon),
                                                     DECODE
                                                        (anu.ctiprec,
                                                         9, -1,
                                                         13, -1,
                                                         1)   -- Bug 0024261 - DCG - 21/11/2012 - LCOL_F002-Contabilidad Vida Grupo - F2
                                                     * f_round(f_round(w_icage_nc, anu.cmoneda) * witasa, w_cmoncon),
                                                     DECODE
                                                        (anu.ctiprec,
                                                         9, -1,
                                                         13, -1,
                                                         1)   -- Bug 0024261 - DCG - 21/11/2012 - LCOL_F002-Contabilidad Vida Grupo - F2
                                                     * f_round(f_round(w_icadn_nc, anu.cmoneda) * witasa, w_cmoncon),
                                                     */
                                                     vicage, vicadn, vicage_nc, vicadn_nc,
                            vicage_moncon, vicadn_moncon, vicage_nc_moncon, vicadn_nc_moncon,
                            -- 13. Bug 0024261 - 29/01/2013 - LCOL_F002-Contabilidad Vida Grupo - F2 / 0136601 - Fin
                            pfcambio, anu.cmoneda, anu.nrecibo, anu.fefecto,
                            LEAST(aux_factual, anu.fvencim), anu.fvencim
                                                                        -- 13. Bug 0024261 - 29/01/2013 - LCOL_F002-Contabilidad Vida Grupo - F2 / 0136601 - Inicio
               ,            vicage_coa,
                            vicadn_coa, vicage_nc_coa, vicadn_nc_coa, vicage_moncon_coa,
                            vicadn_moncon_coa, vicage_nc_moncon_coa, vicadn_nc_moncon_coa
                                                                                         -- 13. Bug 0024261 - 29/01/2013 - LCOL_F002-Contabilidad Vida Grupo - F2 / 0136601 - Fin
                           );
            EXCEPTION
               WHEN OTHERS THEN
                  num_err := 108468;   -- error al insertar en la tabla
            END;
         ELSIF pmodo = 'R' THEN
            BEGIN
               INSERT INTO prov_amocom
                           (cempres, fcalcul, sproces, sseguro, nriesgo,
                            nmovimi, cgarant, icage, icadn, icage_nc, icadn_nc,
                            icage_moncon, icadn_moncon, icage_nc_moncon, icadn_nc_moncon,
                            fcambio, cmoneda, nrecibo, fefecto,
                            ffincal, fvencim
                                            -- 13. Bug 0024261 - 29/01/2013 - LCOL_F002-Contabilidad Vida Grupo - F2 / 0136601 - Inicio
               ,            icage_coa,
                            icadn_coa, icage_nc_coa, icadn_nc_coa, icage_moncon_coa,
                            icadn_moncon_coa, icage_nc_moncon_coa, icadn_nc_moncon_coa
                                                                                      -- 13. Bug 0024261 - 29/01/2013 - LCOL_F002-Contabilidad Vida Grupo - F2 / 0136601 - Fin
                           )
                    VALUES (pcempres, aux_factual, psproces, anu.sseguro, anu.nriesgo,
                            anu.nmovimi, anu.cgarant,
-- 13. Bug 0024261 - 29/01/2013 - LCOL_F002-Contabilidad Vida Grupo - F2 / 0136601 - Inicio
                                                      /*
                                                      w_icage, w_icadn, w_icage_nc,
                            w_icadn_nc,
                            DECODE
                               (anu.ctiprec,
                                9, -1,
                                13, -1,
                                1)   -- Bug 0024261 - DCG - 21/11/2012 - LCOL_F002-Contabilidad Vida Grupo - F2
                            * f_round(f_round(w_icage, anu.cmoneda) * witasa, w_cmoncon),
                            DECODE
                               (anu.ctiprec,
                                9, -1,
                                13, -1,
                                1)   -- Bug 0024261 - DCG - 21/11/2012 - LCOL_F002-Contabilidad Vida Grupo - F2
                            * f_round(f_round(w_icadn, anu.cmoneda) * witasa, w_cmoncon),
                            DECODE
                               (anu.ctiprec,
                                9, -1,
                                13, -1,
                                1)   -- Bug 0024261 - DCG - 21/11/2012 - LCOL_F002-Contabilidad Vida Grupo - F2
                            * f_round(f_round(w_icage_nc, anu.cmoneda) * witasa, w_cmoncon),
                            DECODE
                               (anu.ctiprec,
                                9, -1,
                                13, -1,
                                1)   -- Bug 0024261 - DCG - 21/11/2012 - LCOL_F002-Contabilidad Vida Grupo - F2
                            * f_round(f_round(w_icadn_nc, anu.cmoneda) * witasa, w_cmoncon),
                            */
                                                     vicage, vicadn, vicage_nc, vicadn_nc,
                            vicage_moncon, vicadn_moncon, vicage_nc_moncon, vicadn_nc_moncon,
                            -- 13. Bug 0024261 - 29/01/2013 - LCOL_F002-Contabilidad Vida Grupo - F2 / 0136601 - Fin
                            pfcambio, anu.cmoneda, anu.nrecibo, anu.fefecto,
                            LEAST(aux_factual, anu.fvencim), anu.fvencim
                                                                        -- 13. Bug 0024261 - 29/01/2013 - LCOL_F002-Contabilidad Vida Grupo - F2 / 0136601 - Inicio
               ,            vicage_coa,
                            vicadn_coa, vicage_nc_coa, vicadn_nc_coa, vicage_moncon_coa,
                            vicadn_moncon_coa, vicage_nc_moncon_coa, vicadn_nc_moncon_coa
                                                                                         -- 13. Bug 0024261 - 29/01/2013 - LCOL_F002-Contabilidad Vida Grupo - F2 / 0136601 - Fin
                           );
            EXCEPTION
               WHEN OTHERS THEN
                  num_err := 108468;   -- error al insertar en la tabla
            END;
         ELSE
            RETURN 9000505;
         -- Error de parametres
         END IF;
      END LOOP;

      COMMIT;
      RETURN(conta_err);
   END f_commit_calcul_amocom;

   FUNCTION f_commit_calcul_ibnr(
      pcempres IN NUMBER,
      aux_factual IN DATE,
      psproces IN NUMBER,
      pcidioma IN NUMBER,
      pcmoneda IN NUMBER,
      pmodo IN VARCHAR2 DEFAULT 'R')
      RETURN NUMBER IS
      -- {  declaració de variables necessaries pel proces}
      -- control de error
      conta_err      NUMBER := 0;
      num_err        NUMBER := 0;
      -- Fechas
      wfini          DATE;   -- fecha inicio vigencia
      wffin          DATE;   -- fecha final vigencia
      wfact          DATE := aux_factual;
                                                              -- fecha actual
      -- Variables auxiliares
      wprorrata      NUMBER;   -- prorrata aplicada
      wcmodcom       NUMBER;   --  modo comision
      wnlinea        NUMBER;   -- linea del procesoslin
      wreasingarant  NUMBER;
      -- semaforo para marcar que se asigna todo el reaseguro a la 1ª garantia
      wpretenc       NUMBER;
      -- Variables de tipo texto
      wtexto         literales.tlitera%TYPE;
      -- Valores a calcular
      wgupr          NUMBER := 0;
      -- Reserva de riesgo en curso para la prima emitida bruta
      wga            NUMBER := 0;
      --  gastos de adquisición  causados en el momento de la emisión
      wk1            NUMBER;   -- Porcentaje del gasto de adquisición
      wfrr           NUMBER(15, 3);   --NUMBER;
      --Factor de regimen de reservas, se recupera de la empresa
      wfrpt          NUMBER;   -- Factor de riesgo por transcurrir
      wgwp           NUMBER;   -- Prima emitida bruta
      wcupr          NUMBER;
      wcupr_moncon   NUMBER;
      -- 19. 26642 / 0141943 - Inicio -- 3.0   05/07/2013  MMM Igualar código con PAC_PROVTEC_LCOL
      vicupr_t       NUMBER;
      vicupr_moncon_t NUMBER;
      vicupr_2       NUMBER;
      vicupr_moncon_2 NUMBER;
      -- 19. 26642 / 0141943 - Final -- 3.0   05/07/2013  MMM Igualar código con PAC_PROVTEC_LCOL
      -- Reserva de riesgo en curso de la prima cedida  en Rea. proporcional
      wcwp           NUMBER;   -- Prima cedida en reaseguro proporcional
      wnupr          NUMBER;
      --  Reserva de riesgo rn curso para la prime neta de  Rea. proporcional
      wturp          NUMBER;
      -- Reserva de desviación  de sinistralidad para el  reamo de terremoto
      warpdsupr      NUMBER;
      -- Reserva de desviación de sinistralidad para el ramo ARP. *
      warpupr        NUMBER;
      -- Reserva de enfermedades de sinistralidad para el ramo ARP.*
      wnep           NUMBER;   -- prima neta devengada del reaseguro
      wtnwp          NUMBER;
      -- Prima neta de reaseguro proporcional a la cobertura de terremoto *
      wqgwp          NUMBER;
      -- prmia bruta emitida en el último trimestres **
      wogwp          NUMBER := 0;
      --valores entre el gwp y qgwp *
      wqcwp          NUMBER := 0;
      --  Prima cedida en rea. propoccional en el ult. trimestre **
      wocwp          NUMBER := 0;
      -- valores entre el cwp y el cgwp *
      wcc            NUMBER := 0;
      --provisión para la camara de compensacion, distribuiad por ADN y sucurusal*
      wc             NUMBER;   -- Porcentaje de comisión básica
      wdac           NUMBER := 0;
      -- Coste de adquisicuib diferido*
      wdacadn        NUMBER := 0;
      -- Coste de adquisicuib diferido pagado a la ADN*
      wrdac          NUMBER := 0;
      -- Coste de adquisicuib diferido para la comis recibida*
      wfre           NUMBER := 0;
                     -- Factor de regimen especial, por ramo y con vigencias*
      --{variables  de campos no necesarios fase 0}
      wpcf           NUMBER := 0;
      --Param  porcentaje de constribución FOSYGA *
      wk             NUMBER := 0;
      --Param para el porcentaj de ARPURP *
      wj             NUMBER := 0;
      --Param para el porcentaj de ARPDSUPR *
      wr             NUMBER := 0;
      --Param para el porcentaj de TURP *
      waupr          NUMBER;   -- Ajuste GAAP para la GURP *
      wasupr         NUMBER;   -- Ajuste GAAP para la GURP de SOAT *
      wareupr        NUMBER;
-- Ajuste GAAP sobre la GUPR de  los ramos con Regimes Especiales de reserva.*
      wcadn          NUMBER := 0;
-- Porcentaje pàgado a ala ADN ( no es fase 0, porque se aplica despues del primer año)*
      wfprtre        NUMBER := 1;
--**** Factor por  riesgo a transcurrir puede ser uno o el valor que establezca el usuario
      pfcambio       DATE;   -- Fecha del cambio vigente a la fecha actual
      witasa         NUMBER(15, 2);   -- Tasa vigente
      wprimanivel    NUMBER := 0;
      wcresp43       NUMBER;
      wcresp27       NUMBER;
      -- BUG 20070/107545 - 20/02/2012 - JMP - Añadir contravalores en la moneda de la contabilidad
      w_cmoncon      parempresas.nvalpar%TYPE
                                    := pac_parametros.f_parempresa_n(pcempres, 'MONEDACONTAB');
      -- Moneda de contablidad (numérico)
      w_cmoncon_t    monedas.cmonint%TYPE := pac_monedas.f_cmoneda_t(w_cmoncon);
                                             -- Moneda de contablidad (texto)
      -- FIN BUG 20070/107545 - 20/02/2012 - JMP - Añadir contravalores en la moneda de la contabilidad

      -- Ini Bug 21550 - MDS - 29/02/2012
      w_icage        upr.icage%TYPE := 0;
      w_icadn        upr.icadn%TYPE := 0;
      w_icage_nc     upr.icage_nc%TYPE := 0;
      w_icadn_nc     upr.icadn_nc%TYPE := 0;
-- Fin Bug 21550 - MDS - 29/02/2012
-- Bug 0023130 - DCG - 28/01/2013 - LCOL_F002-Provisiones para polizas estatales
      xploccoa       NUMBER;
      w_icage_coa    upr.icage%TYPE := 0;
      w_icadn_coa    upr.icadn%TYPE := 0;
      w_icage_nc_coa upr.icage_nc%TYPE := 0;
      w_icadn_nc_coa upr.icadn_nc%TYPE := 0;
-- Fin Bug 0023130 - DCG - 28/01/2013
      w_fecha_inicio DATE;
      factor_siguiente NUMBER := 1;
      fecha_siguiente DATE;
      fecha_siguiente2 DATE;
      valor          NUMBER;
      valor2         NUMBER;
      valor_actual   NUMBER := 1;
      valor_actual2  NUMBER := 0;
      meses          NUMBER := 60;
      w_fecha_fin    DATE;
      w_cgarant      NUMBER;
      vpinflac       NUMBER;
      vpower         NUMBER;
      valor_actual3  NUMBER := 0;
      valor_actual4  NUMBER := 0;
      vtotal         NUMBER := 0;
      vtotal2        NUMBER := 0;
      valor3         NUMBER := 0;

      CURSOR c_productos IS
         SELECT p.sproduc
           FROM productos p, codiram c
          WHERE c.cempres = pcempres
            AND c.cramo = p.cramo
            AND NVL(pac_parametros.f_parproducto_n(p.sproduc, 'IBNR_SAM_PROD'), 0) <> 0;

      CURSOR c_garantias_pagos IS
         SELECT DISTINCT (s.cgarant)
                    FROM sin_tramita_pago_gar s
                   WHERE s.cgarant IS NOT NULL;

      CURSOR c_garantias_reservas IS
         SELECT DISTINCT (s.cgarant)
                    FROM sin_tramita_reserva s
                   WHERE s.cgarant IS NOT NULL;
   BEGIN
      w_fecha_fin := ADD_MONTHS(LAST_DAY(TRUNC(aux_factual)), -1) + 1;

/***********************IBNR_SAM_FACAJUS********************/
      --Triángulo de factores de ajuste ibnr_sam_facajus
      FOR i IN 1 .. meses LOOP
         w_fecha_inicio := ADD_MONTHS(w_fecha_fin, -(meses - i));
         valor_actual := 1;

         FOR j IN REVERSE 0 ..(meses - i) LOOP
            BEGIN
               fecha_siguiente := ADD_MONTHS(w_fecha_inicio, j);

               SELECT pipc
                 INTO factor_siguiente
                 FROM ipc
                WHERE nanyo = TO_NUMBER(TO_CHAR(fecha_siguiente, 'rrrr'))
                  AND nmes = TO_NUMBER(TO_CHAR(fecha_siguiente, 'mm'))
                  AND ctipo = 5;

               valor := valor_actual *(1 +(factor_siguiente / 100));
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  valor := 1;
            END;

            BEGIN
               --inflac de pagos
               INSERT INTO ibnr_sam_facajus
                           (sproces, fcalcul, fcalcul_i, fcalcul_j, ctipo, pfactajus,
                            cmodo)
                    VALUES (psproces, w_fecha_fin, w_fecha_inicio, fecha_siguiente, 0, valor,
                            pmodo);
            EXCEPTION
               WHEN OTHERS THEN
                  p_tab_error(f_sysdate, f_user,
                              'pac_provtec_conf.f_commit_calcul_ibnr sproces=' || psproces, 21,
                              'error al insertar en ibnr_sam_facajus ctipo 0. fcalcul ='
                              || w_fecha_fin || ' fcalcul_i=' || w_fecha_inicio
                              || ' fcalcul_j=' || fecha_siguiente || ' pmodo=' || pmodo,
                              SQLERRM);
                  num_err := 108468;   -- error al insertar en la tabla
            END;

            BEGIN
               --inflac de reservas
               INSERT INTO ibnr_sam_facajus
                           (sproces, fcalcul, fcalcul_i, fcalcul_j, ctipo, pfactajus,
                            cmodo)
                    VALUES (psproces, w_fecha_fin, w_fecha_inicio, fecha_siguiente, 1, valor,
                            pmodo);
            EXCEPTION
               WHEN OTHERS THEN
                  p_tab_error(f_sysdate, f_user,
                              'pac_provtec_conf.f_commit_calcul_ibnr sproces=' || psproces, 22,
                              'error al insertar en ibnr_sam_facajus ctipo 1. fcalcul ='
                              || w_fecha_fin || ' fcalcul_i=' || w_fecha_inicio
                              || ' fcalcul_j=' || fecha_siguiente || ' pmodo=' || pmodo,
                              SQLERRM);
                  num_err := 108468;   -- error al insertar en la tabla
            END;

            valor_actual := valor;
         END LOOP;
      END LOOP;

/***********************IBNR_SAM_SINIESTROS********************/
--triangulos por producto
      FOR reg IN c_productos LOOP
--triángulo de siniestros pagados/reservados IBNR_SAM_SINIESTROS
         IF NVL(pac_parametros.f_parproducto_n(reg.sproduc, 'IBNR_SAM_PROD'), 0) = 1 THEN
--agrupa a nivel de garantia
            FOR gar IN c_garantias_reservas LOOP
               FOR i IN 1 .. meses LOOP
                  w_fecha_inicio := ADD_MONTHS(w_fecha_fin, -(meses - i));
                  valor_actual := 1;

                  FOR j IN REVERSE 0 ..(meses - i) LOOP
                     fecha_siguiente := ADD_MONTHS(w_fecha_inicio, j);

--siniestros pagados
                     BEGIN
                        SELECT   SUM(NVL(sp.isinret, 0)), sp.cgarant
                            INTO valor, w_cgarant
                            FROM sin_siniestro s, sin_tramita_pago_gar sp,
                                 sin_tramita_movpago st, sin_tramita_pago stp, seguros sg
                           WHERE TO_CHAR(s.falta, 'MM/RRRR') =
                                                             TO_CHAR(w_fecha_inicio, 'MM/RRRR')
                             AND s.nsinies = stp.nsinies
                             AND sp.sidepag = st.sidepag
                             AND sp.sidepag = stp.sidepag
                             AND s.sseguro = sg.sseguro
                             AND sg.sproduc = reg.sproduc
                             AND st.cestpag = 2   -- pagado
                             AND TO_CHAR(st.fefepag, 'MM/RRRR') =
                                                            TO_CHAR(fecha_siguiente, 'MM/RRRR')
                             AND(sp.isinret < pac_parametros.f_parproducto_n(reg.sproduc,
                                                                             'IBNR_SAM_MAX')
                                 OR pac_parametros.f_parproducto_n(reg.sproduc, 'IBNR_SAM_MAX') IS NULL)
                             AND sp.cgarant = gar.cgarant
                        GROUP BY sp.cgarant;
                     EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                           valor := 0;
                           w_cgarant := gar.cgarant;
                     END;

                     BEGIN
                        --siniestros pagados
                        INSERT INTO ibnr_sam_siniestros
                                    (sproces, fcalcul, fcalcul_i, fcalcul_j,
                                     ctipo, isinret, cmodo, cgarant, sproduc)
                             VALUES (psproces, w_fecha_fin, w_fecha_inicio, fecha_siguiente,
                                     0, NVL(valor, 0), pmodo, w_cgarant, reg.sproduc);
                     EXCEPTION
                        WHEN OTHERS THEN
                           p_tab_error
                              (f_sysdate, f_user,
                               'pac_provtec_conf.f_commit_calcul_ibnr sproces=' || psproces,
                               31,
                               'error al insertar en ibnr_sam_siniestros ctipo 0. fcalcul ='
                               || w_fecha_fin || ' fcalcul_i=' || w_fecha_inicio
                               || ' fcalcul_j=' || fecha_siguiente || ' pmodo=' || pmodo,
                               SQLERRM);
                           num_err := 108468;   -- error al insertar en la tabla
                     END;
                  END LOOP;
               END LOOP;
            END LOOP;

            FOR gar IN c_garantias_reservas LOOP
               FOR i IN 1 .. meses LOOP
                  w_fecha_inicio := ADD_MONTHS(w_fecha_fin, -(meses - i));
                  valor_actual := 1;

--siniestros reservados
                  FOR j IN REVERSE 0 ..(meses - i) LOOP
                     fecha_siguiente := ADD_MONTHS(w_fecha_inicio, j);

                     BEGIN
                        SELECT   SUM(NVL(sp.ireserva, 0)), sp.cgarant
                            INTO valor, w_cgarant
                            FROM sin_siniestro s, sin_tramita_reserva sp, seguros sg
                           WHERE TO_CHAR(s.falta, 'MM/RRRR') =
                                                             TO_CHAR(w_fecha_inicio, 'MM/RRRR')
                             AND s.nsinies = sp.nsinies
                             AND s.sseguro = sg.sseguro
                             AND sg.sproduc = reg.sproduc
                             AND TO_CHAR(sp.fresini, 'MM/RRRR') =
                                                            TO_CHAR(fecha_siguiente, 'MM/RRRR')
                             AND(sp.ireserva < pac_parametros.f_parproducto_n(reg.sproduc,
                                                                              'IBNR_SAM_MAX')
                                 OR pac_parametros.f_parproducto_n(reg.sproduc, 'IBNR_SAM_MAX') IS NULL)
                        GROUP BY sp.cgarant;
                     EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                           valor := 0;
                           w_cgarant := gar.cgarant;
                     END;

                     BEGIN
                        --siniestros reservados
                        INSERT INTO ibnr_sam_siniestros
                                    (sproces, fcalcul, fcalcul_i, fcalcul_j,
                                     ctipo, isinret, cmodo, cgarant, sproduc)
                             VALUES (psproces, w_fecha_fin, w_fecha_inicio, fecha_siguiente,
                                     1, NVL(valor, 0), pmodo, w_cgarant, reg.sproduc);
                     EXCEPTION
                        WHEN OTHERS THEN
                           p_tab_error
                              (f_sysdate, f_user,
                               'pac_provtec_conf.f_commit_calcul_ibnr sproces=' || psproces,
                               32,
                               'error al insertar en ibnr_sam_siniestros ctipo 1. fcalcul ='
                               || w_fecha_fin || ' fcalcul_i=' || w_fecha_inicio
                               || ' fcalcul_j=' || fecha_siguiente || ' pmodo=' || pmodo,
                               SQLERRM);
                           num_err := 108468;   -- error al insertar en la tabla
                     END;
                  END LOOP;
               END LOOP;
            END LOOP;
         ELSIF NVL(pac_parametros.f_parproducto_n(reg.sproduc, 'IBNR_SAM_PROD'), 0) = 2 THEN
--agrupa todo
            w_cgarant := 0;

            FOR i IN 1 .. meses LOOP
               w_fecha_inicio := ADD_MONTHS(w_fecha_fin, -(meses - i));
               valor_actual := 1;

               FOR j IN REVERSE 0 ..(meses - i) LOOP
                  fecha_siguiente := ADD_MONTHS(w_fecha_inicio, j);

                  --siniestros pagados
                  BEGIN
                     SELECT SUM(NVL(sp.isinret, 0))
                       INTO valor
                       FROM sin_siniestro s, sin_tramita_pago_gar sp, sin_tramita_movpago st,
                            sin_tramita_pago stp, seguros sg
                      WHERE TO_CHAR(s.falta, 'MM/RRRR') = TO_CHAR(w_fecha_inicio, 'MM/RRRR')
                        AND s.nsinies = stp.nsinies
                        AND sp.sidepag = st.sidepag
                        AND sp.sidepag = stp.sidepag
                        AND s.sseguro = sg.sseguro
                        AND sg.sproduc = reg.sproduc
                        AND st.cestpag = 2   -- pagado
                        AND TO_CHAR(st.fefepag, 'MM/RRRR') =
                                                            TO_CHAR(fecha_siguiente, 'MM/RRRR')
                        AND(sp.isinret < pac_parametros.f_parproducto_n(reg.sproduc,
                                                                        'IBNR_SAM_MAX')
                            OR pac_parametros.f_parproducto_n(reg.sproduc, 'IBNR_SAM_MAX') IS NULL);
                  EXCEPTION
                     WHEN OTHERS THEN
                        valor := 0;
                        w_cgarant := 0;
                  END;

                  BEGIN
                     --siniestros pagados
                     INSERT INTO ibnr_sam_siniestros
                                 (sproces, fcalcul, fcalcul_i, fcalcul_j, ctipo,
                                  isinret, cmodo, cgarant, sproduc)
                          VALUES (psproces, w_fecha_fin, w_fecha_inicio, fecha_siguiente, 0,
                                  NVL(valor, 0), pmodo, w_cgarant, reg.sproduc);
                  EXCEPTION
                     WHEN OTHERS THEN
                        p_tab_error
                            (f_sysdate, f_user,
                             'pac_provtec_conf.f_commit_calcul_ibnr sproces=' || psproces, 33,
                             'error al insertar en ibnr_sam_siniestros ctipo 0. fcalcul ='
                             || w_fecha_fin || ' fcalcul_i=' || w_fecha_inicio
                             || ' fcalcul_j=' || fecha_siguiente || ' pmodo=' || pmodo,
                             SQLERRM);
                        num_err := 108468;   -- error al insertar en la tabla
                  END;
               END LOOP;
            END LOOP;

            FOR i IN 1 .. meses LOOP
               w_fecha_inicio := ADD_MONTHS(w_fecha_fin, -(meses - i));
               valor_actual := 1;

               FOR j IN REVERSE 0 ..(meses - i) LOOP
                  fecha_siguiente := ADD_MONTHS(w_fecha_inicio, j);

--siniestros reservados
                  BEGIN
                     SELECT   SUM(NVL(sp.ireserva, 0))
                         INTO valor
                         FROM sin_siniestro s, sin_tramita_reserva sp, seguros sg
                        WHERE TO_CHAR(s.falta, 'MM/RRRR') = TO_CHAR(w_fecha_inicio, 'MM/RRRR')
                          AND s.nsinies = sp.nsinies
                          AND s.sseguro = sg.sseguro
                          AND sg.sproduc = reg.sproduc
                          AND TO_CHAR(sp.fresini, 'MM/RRRR') =
                                                            TO_CHAR(fecha_siguiente, 'MM/RRRR')
                          AND(sp.ireserva < pac_parametros.f_parproducto_n(reg.sproduc,
                                                                           'IBNR_SAM_MAX')
                              OR pac_parametros.f_parproducto_n(reg.sproduc, 'IBNR_SAM_MAX') IS NULL)
                     GROUP BY sp.cgarant;
                  EXCEPTION
                     WHEN OTHERS THEN
                        valor := 0;
                        w_cgarant := 0;
                  END;

                  BEGIN
                     --siniestros reservados
                     INSERT INTO ibnr_sam_siniestros
                                 (sproces, fcalcul, fcalcul_i, fcalcul_j, ctipo,
                                  isinret, cmodo, cgarant, sproduc)
                          VALUES (psproces, w_fecha_fin, w_fecha_inicio, fecha_siguiente, 1,
                                  NVL(valor, 0), pmodo, w_cgarant, reg.sproduc);
                  EXCEPTION
                     WHEN OTHERS THEN
                        p_tab_error
                            (f_sysdate, f_user,
                             'pac_provtec_conf.f_commit_calcul_ibnr sproces=' || psproces, 34,
                             'error al insertar en ibnr_sam_siniestros ctipo 1. fcalcul ='
                             || w_fecha_fin || ' fcalcul_i=' || w_fecha_inicio
                             || ' fcalcul_j=' || fecha_siguiente || ' pmodo=' || pmodo,
                             SQLERRM);
                        num_err := 108468;   -- error al insertar en la tabla
                  END;
               END LOOP;
            END LOOP;
         END IF;
      END LOOP;

/***********************IBNR_SAM_SINACUMUL********************/
--Triángulo de siniestros pagados/reservados acumulados
--triangulos por producto
      FOR reg IN c_productos LOOP
--triángulo de siniestros pagados/reservados IBNR_SAM_SINACUMUL
         IF NVL(pac_parametros.f_parproducto_n(reg.sproduc, 'IBNR_SAM_PROD'), 0) = 1 THEN
            FOR gar IN c_garantias_reservas LOOP
               w_cgarant := gar.cgarant;

               FOR i IN 1 .. meses LOOP
                  w_fecha_inicio := ADD_MONTHS(w_fecha_fin, -(meses - i));
                  valor_actual := 0;
                  valor_actual2 := 0;

                  --agrupa a nivel de garantia
                  FOR j IN REVERSE 0 ..(meses - i) LOOP
                     fecha_siguiente := ADD_MONTHS(w_fecha_inicio, j);

                     --siniestros pagados
                     BEGIN
                        SELECT isinret
                          INTO valor
                          FROM ibnr_sam_siniestros
                         WHERE fcalcul_i = w_fecha_inicio
                           AND fcalcul_j = fecha_siguiente
                           AND sproduc = reg.sproduc
                           AND cgarant = gar.cgarant
                           AND sproces = psproces
                           AND cmodo = pmodo
                           AND ctipo = 0;
                     EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                           valor := 0;
                           w_cgarant := gar.cgarant;
                     END;

                     valor_actual := valor_actual + valor;

                     BEGIN
                        --siniestros pagados
                        INSERT INTO ibnr_sam_sinacuml
                                    (sproces, fcalcul, fcalcul_i, fcalcul_j,
                                     ctipo, isinacu, cmodo, cgarant, sproduc)
                             VALUES (psproces, w_fecha_fin, w_fecha_inicio, fecha_siguiente,
                                     0, NVL(valor_actual, 0), pmodo, w_cgarant, reg.sproduc);
                     EXCEPTION
                        WHEN OTHERS THEN
                           p_tab_error
                              (f_sysdate, f_user,
                               'pac_provtec_conf.f_commit_calcul_ibnr sproces=' || psproces,
                               41,
                               'error al insertar en ibnr_sam_sinacuml ctipo 0. fcalcul ='
                               || w_fecha_fin || ' fcalcul_i=' || w_fecha_inicio
                               || ' fcalcul_j=' || fecha_siguiente || ' pmodo=' || pmodo,
                               SQLERRM);
                           num_err := 108468;   -- error al insertar en la tabla
                     END;
                  END LOOP;
               END LOOP;
            END LOOP;

            FOR gar IN c_garantias_reservas LOOP
               w_cgarant := gar.cgarant;

               FOR i IN 1 .. meses LOOP
                  w_fecha_inicio := ADD_MONTHS(w_fecha_fin, -(meses - i));
                  valor_actual := 0;
                  valor_actual2 := 0;

                  --agrupa a nivel de garantia
                  FOR j IN REVERSE 0 ..(meses - i) LOOP
                     fecha_siguiente := ADD_MONTHS(w_fecha_inicio, j);

                     --siniestros reservados
                     BEGIN
                        SELECT isinret
                          INTO valor
                          FROM ibnr_sam_siniestros
                         WHERE fcalcul_i = w_fecha_inicio
                           AND fcalcul_j = fecha_siguiente
                           AND sproduc = reg.sproduc
                           AND cgarant = gar.cgarant
                           AND sproces = psproces
                           AND cmodo = pmodo
                           AND ctipo = 1;
                     EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                           valor := 0;
                           w_cgarant := gar.cgarant;
                     END;

                     valor_actual2 := valor_actual2 + valor;

                     BEGIN
                        --siniestros pagados
                        INSERT INTO ibnr_sam_sinacuml
                                    (sproces, fcalcul, fcalcul_i, fcalcul_j,
                                     ctipo, isinacu, cmodo, cgarant, sproduc)
                             VALUES (psproces, w_fecha_fin, w_fecha_inicio, fecha_siguiente,
                                     1, NVL(valor_actual2, 0), pmodo, w_cgarant, reg.sproduc);
                     EXCEPTION
                        WHEN OTHERS THEN
                           p_tab_error
                              (f_sysdate, f_user,
                               'pac_provtec_conf.f_commit_calcul_ibnr sproces=' || psproces,
                               42,
                               'error al insertar en ibnr_sam_sinacuml ctipo 1. fcalcul ='
                               || w_fecha_fin || ' fcalcul_i=' || w_fecha_inicio
                               || ' fcalcul_j=' || fecha_siguiente || ' pmodo=' || pmodo,
                               SQLERRM);
                           num_err := 108468;   -- error al insertar en la tabla
                     END;
                  END LOOP;
               END LOOP;
            END LOOP;
         ELSIF NVL(pac_parametros.f_parproducto_n(reg.sproduc, 'IBNR_SAM_PROD'), 0) = 2 THEN
            --agrupa todo
            w_cgarant := 0;

            FOR i IN 1 .. meses LOOP
               w_fecha_inicio := ADD_MONTHS(w_fecha_fin, -(meses - i));
               valor_actual := 0;
               valor_actual2 := 0;

               FOR j IN REVERSE 0 ..(meses - i) LOOP
                  fecha_siguiente := ADD_MONTHS(w_fecha_inicio, j);
                  w_cgarant := 0;

                  --siniestros pagados
                  BEGIN
                     SELECT isinret
                       INTO valor
                       FROM ibnr_sam_siniestros
                      WHERE fcalcul_i = w_fecha_inicio
                        AND fcalcul_j = fecha_siguiente
                        AND sproduc = reg.sproduc
                        AND cgarant = 0
                        AND sproces = psproces
                        AND cmodo = pmodo
                        AND ctipo = 0;
                  EXCEPTION
                     WHEN OTHERS THEN
                        valor := 0;
                        w_cgarant := 0;
                  END;

                  valor_actual := valor_actual + valor;

                  BEGIN
                     --siniestros pagados
                     INSERT INTO ibnr_sam_sinacuml
                                 (sproces, fcalcul, fcalcul_i, fcalcul_j, ctipo,
                                  isinacu, cmodo, cgarant, sproduc)
                          VALUES (psproces, w_fecha_fin, w_fecha_inicio, fecha_siguiente, 0,
                                  NVL(valor_actual, 0), pmodo, w_cgarant, reg.sproduc);
                  EXCEPTION
                     WHEN OTHERS THEN
                        p_tab_error
                              (f_sysdate, f_user,
                               'pac_provtec_conf.f_commit_calcul_ibnr sproces=' || psproces,
                               43,
                               'error al insertar en ibnr_sam_sinacuml ctipo 0. fcalcul ='
                               || w_fecha_fin || ' fcalcul_i=' || w_fecha_inicio
                               || ' fcalcul_j=' || fecha_siguiente || ' pmodo=' || pmodo,
                               SQLERRM);
                        num_err := 108468;   -- error al insertar en la tabla
                  END;
               END LOOP;
            END LOOP;

            FOR i IN 1 .. meses LOOP
               w_fecha_inicio := ADD_MONTHS(w_fecha_fin, -(meses - i));
               valor_actual := 0;
               valor_actual2 := 0;

               FOR j IN REVERSE 0 ..(meses - i) LOOP
                  fecha_siguiente := ADD_MONTHS(w_fecha_inicio, j);

                  --siniestros reservados
                  BEGIN
                     SELECT isinret
                       INTO valor
                       FROM ibnr_sam_siniestros
                      WHERE fcalcul_i = w_fecha_inicio
                        AND fcalcul_j = fecha_siguiente
                        AND sproduc = reg.sproduc
                        AND cgarant = 0
                        AND sproces = psproces
                        AND cmodo = pmodo
                        AND ctipo = 1;
                  EXCEPTION
                     WHEN OTHERS THEN
                        valor := 0;
                        w_cgarant := 0;
                  END;

                  valor_actual2 := valor_actual2 + valor;

                  BEGIN
                     --siniestros pagados
                     INSERT INTO ibnr_sam_sinacuml
                                 (sproces, fcalcul, fcalcul_i, fcalcul_j, ctipo,
                                  isinacu, cmodo, cgarant, sproduc)
                          VALUES (psproces, w_fecha_fin, w_fecha_inicio, fecha_siguiente, 1,
                                  NVL(valor_actual2, 0), pmodo, w_cgarant, reg.sproduc);
                  EXCEPTION
                     WHEN OTHERS THEN
                        p_tab_error
                              (f_sysdate, f_user,
                               'pac_provtec_conf.f_commit_calcul_ibnr sproces=' || psproces,
                               44,
                               'error al insertar en ibnr_sam_sinacuml ctipo 1. fcalcul ='
                               || w_fecha_fin || ' fcalcul_i=' || w_fecha_inicio
                               || ' fcalcul_j=' || fecha_siguiente || ' pmodo=' || pmodo,
                               SQLERRM);
                        num_err := 108468;   -- error al insertar en la tabla
                  END;
               END LOOP;
            END LOOP;
         END IF;
      END LOOP;

/***********************IBNR_SAM_SINAJUS********************/
--Triángulo de siniestros pagados/reservados ajustados
--triangulos por producto
      FOR reg IN c_productos LOOP
--triángulo de siniestros pagados/reservados ajustados IBNR_SAM_SINAJUS
         IF NVL(pac_parametros.f_parproducto_n(reg.sproduc, 'IBNR_SAM_PROD'), 0) = 1 THEN
--agrupa a nivel de garantia
            FOR gar IN c_garantias_reservas LOOP
               w_cgarant := gar.cgarant;

               FOR i IN 1 .. meses LOOP
                  w_fecha_inicio := ADD_MONTHS(w_fecha_fin, -(meses - i));
                  valor_actual := 0;

                  FOR j IN REVERSE 0 ..(meses - i) LOOP
                     fecha_siguiente := ADD_MONTHS(w_fecha_inicio, j);

--siniestros pagados
                     BEGIN
                        SELECT isinret
                          INTO valor
                          FROM ibnr_sam_siniestros
                         WHERE fcalcul_i = w_fecha_inicio
                           AND fcalcul_j = fecha_siguiente
                           AND sproduc = reg.sproduc
                           AND cgarant = gar.cgarant
                           AND sproces = psproces
                           AND cmodo = pmodo
                           AND ctipo = 0;
                     EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                           valor := 0;
                           w_cgarant := gar.cgarant;
                     END;

                     BEGIN
                        SELECT pfactajus
                          INTO valor_actual
                          FROM ibnr_sam_facajus
                         WHERE fcalcul_i = w_fecha_inicio
                           AND fcalcul_j = fecha_siguiente
                           --AND sproduc = reg.sproduc
                           --AND cgarant = GAR.cgarant
                           AND sproces = psproces
                           AND cmodo = pmodo
                           AND ctipo = 0;
                     EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                           valor_actual := 0;
                           w_cgarant := gar.cgarant;
                     END;

                     valor := valor * valor_actual;

                     BEGIN
                        --siniestros pagados
                        INSERT INTO ibnr_sam_sinajus
                                    (sproces, fcalcul, fcalcul_i, fcalcul_j,
                                     ctipo, isinajus, cmodo, cgarant, sproduc)
                             VALUES (psproces, w_fecha_fin, w_fecha_inicio, fecha_siguiente,
                                     0, NVL(valor, 0), pmodo, w_cgarant, reg.sproduc);
                     EXCEPTION
                        WHEN OTHERS THEN
                           p_tab_error
                               (f_sysdate, f_user,
                                'pac_provtec_conf.f_commit_calcul_ibnr sproces=' || psproces,
                                51,
                                'error al insertar en ibnr_sam_sinajus ctipo 0. fcalcul ='
                                || w_fecha_fin || ' fcalcul_i=' || w_fecha_inicio
                                || ' fcalcul_j=' || fecha_siguiente || ' pmodo=' || pmodo,
                                SQLERRM);
                           num_err := 108468;   -- error al insertar en la tabla
                     END;
                  END LOOP;
               END LOOP;
            END LOOP;

            FOR gar IN c_garantias_reservas LOOP
               w_cgarant := gar.cgarant;

               FOR i IN 1 .. meses LOOP
                  w_fecha_inicio := ADD_MONTHS(w_fecha_fin, -(meses - i));
                  valor_actual := 0;

                  FOR j IN REVERSE 0 ..(meses - i) LOOP
                     fecha_siguiente := ADD_MONTHS(w_fecha_inicio, j);

--siniestros reservados
                     BEGIN
                        SELECT isinret
                          INTO valor
                          FROM ibnr_sam_siniestros
                         WHERE fcalcul_i = w_fecha_inicio
                           AND fcalcul_j = fecha_siguiente
                           AND sproduc = reg.sproduc
                           AND cgarant = gar.cgarant
                           AND sproces = psproces
                           AND cmodo = pmodo
                           AND ctipo = 1;
                     EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                           valor := 0;
                           w_cgarant := gar.cgarant;
                     END;

                     BEGIN
                        SELECT pfactajus
                          INTO valor_actual
                          FROM ibnr_sam_facajus
                         WHERE fcalcul_i = w_fecha_inicio
                           AND fcalcul_j = fecha_siguiente
                           --AND sproduc = reg.sproduc
                           --AND cgarant = GAR.cgarant
                           AND sproces = psproces
                           AND cmodo = pmodo
                           AND ctipo = 1;
                     EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                           valor_actual := 0;
                           w_cgarant := gar.cgarant;
                     END;

                     valor := valor * valor_actual;

                     BEGIN
                        --siniestros pagados
                        INSERT INTO ibnr_sam_sinajus
                                    (sproces, fcalcul, fcalcul_i, fcalcul_j,
                                     ctipo, isinajus, cmodo, cgarant, sproduc)
                             VALUES (psproces, w_fecha_fin, w_fecha_inicio, fecha_siguiente,
                                     1, NVL(valor, 0), pmodo, w_cgarant, reg.sproduc);
                     EXCEPTION
                        WHEN OTHERS THEN
                           p_tab_error
                               (f_sysdate, f_user,
                                'pac_provtec_conf.f_commit_calcul_ibnr sproces=' || psproces,
                                52,
                                'error al insertar en ibnr_sam_sinajus ctipo 1. fcalcul ='
                                || w_fecha_fin || ' fcalcul_i=' || w_fecha_inicio
                                || ' fcalcul_j=' || fecha_siguiente || ' pmodo=' || pmodo,
                                SQLERRM);
                           num_err := 108468;   -- error al insertar en la tabla
                     END;
                  END LOOP;
               END LOOP;
            END LOOP;
         ELSIF NVL(pac_parametros.f_parproducto_n(reg.sproduc, 'IBNR_SAM_PROD'), 0) = 2 THEN
--agrupa todo
            w_cgarant := 0;

            FOR i IN 1 .. meses LOOP
               w_fecha_inicio := ADD_MONTHS(w_fecha_fin, -(meses - i));
               valor_actual := 0;

               FOR j IN REVERSE 0 ..(meses - i) LOOP
                  fecha_siguiente := ADD_MONTHS(w_fecha_inicio, j);

                  --siniestros pagados
                  BEGIN
                     SELECT isinret
                       INTO valor
                       FROM ibnr_sam_siniestros
                      WHERE fcalcul_i = w_fecha_inicio
                        AND fcalcul_j = fecha_siguiente
                        AND sproduc = reg.sproduc
                        AND cgarant = 0
                        AND sproces = psproces
                        AND cmodo = pmodo
                        AND ctipo = 0;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        valor := 0;
                        w_cgarant := 0;
                  END;

                  BEGIN
                     SELECT pfactajus
                       INTO valor_actual
                       FROM ibnr_sam_facajus
                      WHERE fcalcul_i = w_fecha_inicio
                        AND fcalcul_j = fecha_siguiente
                        --AND sproduc = reg.sproduc
                        --AND cgarant = GAR.cgarant
                        AND sproces = psproces
                        AND cmodo = pmodo
                        AND ctipo = 0;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        valor_actual := 0;
                        w_cgarant := 0;
                  END;

                  valor := valor * valor_actual;

                  BEGIN
                     --siniestros pagados
                     INSERT INTO ibnr_sam_sinajus
                                 (sproces, fcalcul, fcalcul_i, fcalcul_j, ctipo,
                                  isinajus, cmodo, cgarant, sproduc)
                          VALUES (psproces, w_fecha_fin, w_fecha_inicio, fecha_siguiente, 0,
                                  NVL(valor, 0), pmodo, w_cgarant, reg.sproduc);
                  EXCEPTION
                     WHEN OTHERS THEN
                        p_tab_error
                               (f_sysdate, f_user,
                                'pac_provtec_conf.f_commit_calcul_ibnr sproces=' || psproces,
                                53,
                                'error al insertar en ibnr_sam_sinajus ctipo 0. fcalcul ='
                                || w_fecha_fin || ' fcalcul_i=' || w_fecha_inicio
                                || ' fcalcul_j=' || fecha_siguiente || ' pmodo=' || pmodo,
                                SQLERRM);
                        num_err := 108468;   -- error al insertar en la tabla
                  END;
               END LOOP;
            END LOOP;

            FOR i IN 1 .. meses LOOP
               w_fecha_inicio := ADD_MONTHS(w_fecha_fin, -(meses - i));
               valor_actual := 0;

               FOR j IN REVERSE 0 ..(meses - i) LOOP
                  fecha_siguiente := ADD_MONTHS(w_fecha_inicio, j);

--siniestros reservados
                  BEGIN
                     SELECT isinret
                       INTO valor
                       FROM ibnr_sam_siniestros
                      WHERE fcalcul_i = w_fecha_inicio
                        AND fcalcul_j = fecha_siguiente
                        AND sproduc = reg.sproduc
                        AND cgarant = 0
                        AND sproces = psproces
                        AND cmodo = pmodo
                        AND ctipo = 1;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        valor := 0;
                        w_cgarant := 0;
                  END;

                  BEGIN
                     SELECT pfactajus
                       INTO valor_actual
                       FROM ibnr_sam_facajus
                      WHERE fcalcul_i = w_fecha_inicio
                        AND fcalcul_j = fecha_siguiente
                        --AND sproduc = reg.sproduc
                        --AND cgarant = GAR.cgarant
                        AND sproces = psproces
                        AND cmodo = pmodo
                        AND ctipo = 1;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        valor_actual := 0;
                        w_cgarant := 0;
                  END;

                  valor := valor * valor_actual;

                  BEGIN
                     --siniestros pagados
                     INSERT INTO ibnr_sam_sinajus
                                 (sproces, fcalcul, fcalcul_i, fcalcul_j, ctipo,
                                  isinajus, cmodo, cgarant, sproduc)
                          VALUES (psproces, w_fecha_fin, w_fecha_inicio, fecha_siguiente, 1,
                                  NVL(valor, 0), pmodo, w_cgarant, reg.sproduc);
                  EXCEPTION
                     WHEN OTHERS THEN
                        p_tab_error
                               (f_sysdate, f_user,
                                'pac_provtec_conf.f_commit_calcul_ibnr sproces=' || psproces,
                                54,
                                'error al insertar en ibnr_sam_sinajus ctipo 1. fcalcul ='
                                || w_fecha_fin || ' fcalcul_i=' || w_fecha_inicio
                                || ' fcalcul_j=' || fecha_siguiente || ' pmodo=' || pmodo,
                                SQLERRM);
                        num_err := 108468;   -- error al insertar en la tabla
                  END;
               END LOOP;
            END LOOP;
         END IF;
      END LOOP;

      /***********************IBNR_SAM_SINACUMAJUS********************/
--Triángulo de siniestros pagados/reservados acumulados ajustados
--triangulos por producto
      FOR reg IN c_productos LOOP
--triángulo de siniestros pagados/reservados ajustados IBNR_SAM_SINACUMAJUS
         IF NVL(pac_parametros.f_parproducto_n(reg.sproduc, 'IBNR_SAM_PROD'), 0) = 1 THEN
--agrupa a nivel de garantia
            FOR gar IN c_garantias_reservas LOOP
               w_cgarant := gar.cgarant;

               FOR i IN 1 .. meses LOOP
                  w_fecha_inicio := ADD_MONTHS(w_fecha_fin, -(meses - i));
                  valor_actual := 0;

                  FOR j IN REVERSE 0 ..(meses - i) LOOP
                     fecha_siguiente := ADD_MONTHS(w_fecha_inicio, j);

--siniestros pagados
                     BEGIN
                        SELECT isinacu
                          INTO valor
                          FROM ibnr_sam_sinacuml
                         WHERE fcalcul_i = w_fecha_inicio
                           AND fcalcul_j = fecha_siguiente
                           AND sproduc = reg.sproduc
                           AND cgarant = gar.cgarant
                           AND sproces = psproces
                           AND cmodo = pmodo
                           AND ctipo = 0;
                     EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                           valor := 0;
                           w_cgarant := gar.cgarant;
                     END;

                     BEGIN
                        SELECT pfactajus
                          INTO valor_actual
                          FROM ibnr_sam_facajus
                         WHERE fcalcul_i = w_fecha_inicio
                           AND fcalcul_j = fecha_siguiente
                           --AND sproduc = reg.sproduc
                           --AND cgarant = GAR.cgarant
                           AND sproces = psproces
                           AND cmodo = pmodo
                           AND ctipo = 0;
                     EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                           valor_actual := 0;
                           w_cgarant := gar.cgarant;
                     END;

                     valor := valor * valor_actual;

                     BEGIN
                        --siniestros pagados
                        INSERT INTO ibnr_sam_sinacumajus
                                    (sproces, fcalcul, fcalcul_i, fcalcul_j,
                                     ctipo, isinajuc, cmodo, cgarant, sproduc)
                             VALUES (psproces, w_fecha_fin, w_fecha_inicio, fecha_siguiente,
                                     0, NVL(valor, 0), pmodo, w_cgarant, reg.sproduc);
                     EXCEPTION
                        WHEN OTHERS THEN
                           p_tab_error
                              (f_sysdate, f_user,
                               'pac_provtec_conf.f_commit_calcul_ibnr sproces=' || psproces,
                               61,
                               'error al insertar en ibnr_sam_sinacumajus ctipo 0. fcalcul ='
                               || w_fecha_fin || ' fcalcul_i=' || w_fecha_inicio
                               || ' fcalcul_j=' || fecha_siguiente || ' pmodo=' || pmodo,
                               SQLERRM);
                           num_err := 108468;   -- error al insertar en la tabla
                     END;
                  END LOOP;
               END LOOP;
            END LOOP;

            FOR gar IN c_garantias_reservas LOOP
               w_cgarant := gar.cgarant;

               FOR i IN 1 .. meses LOOP
                  w_fecha_inicio := ADD_MONTHS(w_fecha_fin, -(meses - i));
                  valor_actual := 0;

                  FOR j IN REVERSE 0 ..(meses - i) LOOP
                     fecha_siguiente := ADD_MONTHS(w_fecha_inicio, j);

--siniestros reservados
                     BEGIN
                        SELECT isinacu
                          INTO valor
                          FROM ibnr_sam_sinacuml
                         WHERE fcalcul_i = w_fecha_inicio
                           AND fcalcul_j = fecha_siguiente
                           AND sproduc = reg.sproduc
                           AND cgarant = gar.cgarant
                           AND sproces = psproces
                           AND cmodo = pmodo
                           AND ctipo = 1;
                     EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                           valor := 0;
                           w_cgarant := gar.cgarant;
                     END;

                     BEGIN
                        SELECT pfactajus
                          INTO valor_actual
                          FROM ibnr_sam_facajus
                         WHERE fcalcul_i = w_fecha_inicio
                           AND fcalcul_j = fecha_siguiente
                           --AND sproduc = reg.sproduc
                           --AND cgarant = GAR.cgarant
                           AND sproces = psproces
                           AND cmodo = pmodo
                           AND ctipo = 1;
                     EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                           valor_actual := 0;
                           w_cgarant := gar.cgarant;
                     END;

                     valor := valor * valor_actual;

                     BEGIN
                        --siniestros pagados
                        INSERT INTO ibnr_sam_sinacumajus
                                    (sproces, fcalcul, fcalcul_i, fcalcul_j,
                                     ctipo, isinajuc, cmodo, cgarant, sproduc)
                             VALUES (psproces, w_fecha_fin, w_fecha_inicio, fecha_siguiente,
                                     1, NVL(valor, 0), pmodo, w_cgarant, reg.sproduc);
                     EXCEPTION
                        WHEN OTHERS THEN
                           p_tab_error
                              (f_sysdate, f_user,
                               'pac_provtec_conf.f_commit_calcul_ibnr sproces=' || psproces,
                               62,
                               'error al insertar en ibnr_sam_sinacumajus ctipo 1. fcalcul ='
                               || w_fecha_fin || ' fcalcul_i=' || w_fecha_inicio
                               || ' fcalcul_j=' || fecha_siguiente || ' pmodo=' || pmodo,
                               SQLERRM);
                           num_err := 108468;   -- error al insertar en la tabla
                     END;
                  END LOOP;
               END LOOP;
            END LOOP;
         ELSIF NVL(pac_parametros.f_parproducto_n(reg.sproduc, 'IBNR_SAM_PROD'), 0) = 2 THEN
--agrupa todo
            w_cgarant := 0;

            FOR i IN 1 .. meses LOOP
               w_fecha_inicio := ADD_MONTHS(w_fecha_fin, -(meses - i));
               valor_actual := 0;

               FOR j IN REVERSE 0 ..(meses - i) LOOP
                  fecha_siguiente := ADD_MONTHS(w_fecha_inicio, j);

                  --siniestros pagados
                  BEGIN
                     SELECT isinacu
                       INTO valor
                       FROM ibnr_sam_sinacuml
                      WHERE fcalcul_i = w_fecha_inicio
                        AND fcalcul_j = fecha_siguiente
                        AND sproduc = reg.sproduc
                        AND cgarant = 0
                        AND sproces = psproces
                        AND cmodo = pmodo
                        AND ctipo = 0;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        valor := 0;
                        w_cgarant := 0;
                  END;

                  BEGIN
                     SELECT pfactajus
                       INTO valor_actual
                       FROM ibnr_sam_facajus
                      WHERE fcalcul_i = w_fecha_inicio
                        AND fcalcul_j = fecha_siguiente
                        --AND sproduc = reg.sproduc
                        --AND cgarant = GAR.cgarant
                        AND sproces = psproces
                        AND cmodo = pmodo
                        AND ctipo = 0;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        valor_actual := 0;
                        w_cgarant := 0;
                  END;

                  valor := valor * valor_actual;

                  BEGIN
                     --siniestros pagados
                     INSERT INTO ibnr_sam_sinacumajus
                                 (sproces, fcalcul, fcalcul_i, fcalcul_j, ctipo,
                                  isinajuc, cmodo, cgarant, sproduc)
                          VALUES (psproces, w_fecha_fin, w_fecha_inicio, fecha_siguiente, 0,
                                  NVL(valor, 0), pmodo, w_cgarant, reg.sproduc);
                  EXCEPTION
                     WHEN OTHERS THEN
                        p_tab_error
                           (f_sysdate, f_user,
                            'pac_provtec_conf.f_commit_calcul_ibnr sproces=' || psproces, 63,
                            'error al insertar en ibnr_sam_sinacumajus ctipo 0. fcalcul ='
                            || w_fecha_fin || ' fcalcul_i=' || w_fecha_inicio || ' fcalcul_j='
                            || fecha_siguiente || ' pmodo=' || pmodo,
                            SQLERRM);
                        num_err := 108468;   -- error al insertar en la tabla
                  END;
               END LOOP;
            END LOOP;

            FOR i IN 1 .. meses LOOP
               w_fecha_inicio := ADD_MONTHS(w_fecha_fin, -(meses - i));
               valor_actual := 0;

               FOR j IN REVERSE 0 ..(meses - i) LOOP
                  fecha_siguiente := ADD_MONTHS(w_fecha_inicio, j);

--siniestros reservados
                  BEGIN
                     SELECT isinacu
                       INTO valor
                       FROM ibnr_sam_sinacuml
                      WHERE fcalcul_i = w_fecha_inicio
                        AND fcalcul_j = fecha_siguiente
                        AND sproduc = reg.sproduc
                        AND cgarant = 0
                        AND sproces = psproces
                        AND cmodo = pmodo
                        AND ctipo = 1;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        valor := 0;
                        w_cgarant := 0;
                  END;

                  BEGIN
                     SELECT pfactajus
                       INTO valor_actual
                       FROM ibnr_sam_facajus
                      WHERE fcalcul_i = w_fecha_inicio
                        AND fcalcul_j = fecha_siguiente
                        --AND sproduc = reg.sproduc
                        --AND cgarant = GAR.cgarant
                        AND sproces = psproces
                        AND cmodo = pmodo
                        AND ctipo = 1;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        valor_actual := 0;
                        w_cgarant := 0;
                  END;

                  valor := valor * valor_actual;

                  BEGIN
                     --siniestros pagados
                     INSERT INTO ibnr_sam_sinacumajus
                                 (sproces, fcalcul, fcalcul_i, fcalcul_j, ctipo,
                                  isinajuc, cmodo, cgarant, sproduc)
                          VALUES (psproces, w_fecha_fin, w_fecha_inicio, fecha_siguiente, 1,
                                  NVL(valor, 0), pmodo, w_cgarant, reg.sproduc);
                  EXCEPTION
                     WHEN OTHERS THEN
                        p_tab_error
                           (f_sysdate, f_user,
                            'pac_provtec_conf.f_commit_calcul_ibnr sproces=' || psproces, 64,
                            'error al insertar en ibnr_sam_sinacumajus ctipo 1. fcalcul ='
                            || w_fecha_fin || ' fcalcul_i=' || w_fecha_inicio || ' fcalcul_j='
                            || fecha_siguiente || ' pmodo=' || pmodo,
                            SQLERRM);
                        num_err := 108468;   -- error al insertar en la tabla
                  END;
               END LOOP;
            END LOOP;
         END IF;
      END LOOP;

/***********************IBNR_SAM_FACTDESA********************/
--Triángulo de factores de desarrollo incremental
--triangulos por producto
      FOR reg IN c_productos LOOP
--triángulo de siniestros pagados/reservados ajustados IBNR_SAM_FACTDESA
         IF NVL(pac_parametros.f_parproducto_n(reg.sproduc, 'IBNR_SAM_PROD'), 0) = 1 THEN
--agrupa a nivel de garantia
            FOR gar IN c_garantias_reservas LOOP
               w_cgarant := gar.cgarant;

               FOR i IN 1 .. meses LOOP
                  w_fecha_inicio := ADD_MONTHS(w_fecha_fin, -(meses - i));
                  valor_actual := 0;

                  FOR j IN REVERSE 0 ..(meses - i) LOOP
                     fecha_siguiente := ADD_MONTHS(w_fecha_inicio, j);
                     fecha_siguiente2 := ADD_MONTHS(w_fecha_inicio, j + 1);

--siniestros pagados
                     BEGIN
                        SELECT isinacu
                          INTO valor
                          FROM ibnr_sam_sinacuml
                         WHERE fcalcul_i = w_fecha_inicio
                           AND fcalcul_j = fecha_siguiente
                           AND sproduc = reg.sproduc
                           AND cgarant = gar.cgarant
                           AND sproces = psproces
                           AND cmodo = pmodo
                           AND ctipo = 0;
                     EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                           valor := 0;
                           w_cgarant := gar.cgarant;
                     END;

                     BEGIN
                        SELECT isinacu
                          INTO valor_actual
                          FROM ibnr_sam_sinacuml
                         WHERE fcalcul_i = w_fecha_inicio
                           AND fcalcul_j = fecha_siguiente2
                           AND sproduc = reg.sproduc
                           AND cgarant = gar.cgarant
                           AND sproces = psproces
                           AND cmodo = pmodo
                           AND ctipo = 0;
                     EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                           valor := 0;
                           w_cgarant := gar.cgarant;
                     END;

                     BEGIN
                        valor := valor_actual / valor;
                     EXCEPTION
                        WHEN OTHERS THEN
                           valor := 0;
                     END;

                     BEGIN
                        --siniestros pagados
                        INSERT INTO ibnr_sam_factdesa
                                    (sproces, fcalcul, fcalcul_i, fcalcul_j,
                                     ctipo, ifacdes, cmodo, cgarant, sproduc)
                             VALUES (psproces, w_fecha_fin, w_fecha_inicio, fecha_siguiente,
                                     0, NVL(valor, 0), pmodo, w_cgarant, reg.sproduc);
                     EXCEPTION
                        WHEN OTHERS THEN
                           p_tab_error
                              (f_sysdate, f_user,
                               'pac_provtec_conf.f_commit_calcul_ibnr sproces=' || psproces,
                               71,
                               'error al insertar en ibnr_sam_factdesa ctipo 0. fcalcul ='
                               || w_fecha_fin || ' fcalcul_i=' || w_fecha_inicio
                               || ' fcalcul_j=' || fecha_siguiente || ' pmodo=' || pmodo,
                               SQLERRM);
                           num_err := 108468;   -- error al insertar en la tabla
                     END;
                  END LOOP;
               END LOOP;
            END LOOP;

            FOR gar IN c_garantias_reservas LOOP
               w_cgarant := gar.cgarant;

               FOR i IN 1 .. meses LOOP
                  w_fecha_inicio := ADD_MONTHS(w_fecha_fin, -(meses - i));
                  valor_actual := 0;

                  FOR j IN REVERSE 0 ..(meses - i) LOOP
                     fecha_siguiente := ADD_MONTHS(w_fecha_inicio, j);
                     fecha_siguiente2 := ADD_MONTHS(w_fecha_inicio, j + 1);

--siniestros reservados
                     BEGIN
                        SELECT isinacu
                          INTO valor
                          FROM ibnr_sam_sinacuml
                         WHERE fcalcul_i = w_fecha_inicio
                           AND fcalcul_j = fecha_siguiente
                           AND sproduc = reg.sproduc
                           AND cgarant = gar.cgarant
                           AND sproces = psproces
                           AND cmodo = pmodo
                           AND ctipo = 1;
                     EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                           valor := 0;
                           w_cgarant := gar.cgarant;
                     END;

                     BEGIN
                        SELECT isinacu
                          INTO valor_actual
                          FROM ibnr_sam_sinacuml
                         WHERE fcalcul_i = w_fecha_inicio
                           AND fcalcul_j = fecha_siguiente2
                           AND sproduc = reg.sproduc
                           AND cgarant = gar.cgarant
                           AND sproces = psproces
                           AND cmodo = pmodo
                           AND ctipo = 1;
                     EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                           valor := 0;
                           w_cgarant := gar.cgarant;
                     END;

                     BEGIN
                        valor := valor_actual / valor;
                     EXCEPTION
                        WHEN OTHERS THEN
                           valor := 0;
                     END;

                     BEGIN
                        --siniestros pagados
                        INSERT INTO ibnr_sam_factdesa
                                    (sproces, fcalcul, fcalcul_i, fcalcul_j,
                                     ctipo, ifacdes, cmodo, cgarant, sproduc)
                             VALUES (psproces, w_fecha_fin, w_fecha_inicio, fecha_siguiente,
                                     1, NVL(valor, 0), pmodo, w_cgarant, reg.sproduc);
                     EXCEPTION
                        WHEN OTHERS THEN
                           p_tab_error
                              (f_sysdate, f_user,
                               'pac_provtec_conf.f_commit_calcul_ibnr sproces=' || psproces,
                               72,
                               'error al insertar en ibnr_sam_factdesa ctipo 1. fcalcul ='
                               || w_fecha_fin || ' fcalcul_i=' || w_fecha_inicio
                               || ' fcalcul_j=' || fecha_siguiente || ' pmodo=' || pmodo,
                               SQLERRM);
                           num_err := 108468;   -- error al insertar en la tabla
                     END;
                  END LOOP;
               END LOOP;
            END LOOP;
         ELSIF NVL(pac_parametros.f_parproducto_n(reg.sproduc, 'IBNR_SAM_PROD'), 0) = 2 THEN
--agrupa todo
            w_cgarant := 0;

            FOR i IN 1 .. meses LOOP
               w_fecha_inicio := ADD_MONTHS(w_fecha_fin, -(meses - i));
               valor_actual := 0;

               FOR j IN REVERSE 0 ..(meses - i) LOOP
                  fecha_siguiente := ADD_MONTHS(w_fecha_inicio, j);
                  fecha_siguiente2 := ADD_MONTHS(w_fecha_inicio, j + 1);

                  --siniestros pagados
                  BEGIN
                     SELECT isinacu
                       INTO valor
                       FROM ibnr_sam_sinacuml
                      WHERE fcalcul_i = w_fecha_inicio
                        AND fcalcul_j = fecha_siguiente
                        AND sproduc = reg.sproduc
                        AND cgarant = 0
                        AND sproces = psproces
                        AND cmodo = pmodo
                        AND ctipo = 0;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        valor := 0;
                        w_cgarant := 0;
                  END;

                  BEGIN
                     SELECT isinacu
                       INTO valor_actual
                       FROM ibnr_sam_sinacuml
                      WHERE fcalcul_i = w_fecha_inicio
                        AND fcalcul_j = fecha_siguiente2
                        AND sproduc = reg.sproduc
                        AND cgarant = 0
                        AND sproces = psproces
                        AND cmodo = pmodo
                        AND ctipo = 0;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        valor := 0;
                        w_cgarant := 0;
                  END;

                  BEGIN
                     valor := valor_actual / valor;
                  EXCEPTION
                     WHEN OTHERS THEN
                        valor := 0;
                  END;

                  BEGIN
                     --siniestros pagados
                     INSERT INTO ibnr_sam_factdesa
                                 (sproces, fcalcul, fcalcul_i, fcalcul_j, ctipo,
                                  ifacdes, cmodo, cgarant, sproduc)
                          VALUES (psproces, w_fecha_fin, w_fecha_inicio, fecha_siguiente, 0,
                                  NVL(valor, 0), pmodo, w_cgarant, reg.sproduc);
                  EXCEPTION
                     WHEN OTHERS THEN
                        p_tab_error
                              (f_sysdate, f_user,
                               'pac_provtec_conf.f_commit_calcul_ibnr sproces=' || psproces,
                               73,
                               'error al insertar en ibnr_sam_factdesa ctipo 0. fcalcul ='
                               || w_fecha_fin || ' fcalcul_i=' || w_fecha_inicio
                               || ' fcalcul_j=' || fecha_siguiente || ' pmodo=' || pmodo,
                               SQLERRM);
                        num_err := 108468;   -- error al insertar en la tabla
                  END;
               END LOOP;
            END LOOP;

            FOR i IN 1 .. meses LOOP
               w_fecha_inicio := ADD_MONTHS(w_fecha_fin, -(meses - i));
               valor_actual := 0;

               FOR j IN REVERSE 0 ..(meses - i) LOOP
                  fecha_siguiente := ADD_MONTHS(w_fecha_inicio, j);
                  fecha_siguiente2 := ADD_MONTHS(w_fecha_inicio, j + 1);

--siniestros reservados
                  BEGIN
                     SELECT isinacu
                       INTO valor
                       FROM ibnr_sam_sinacuml
                      WHERE fcalcul_i = w_fecha_inicio
                        AND fcalcul_j = fecha_siguiente
                        AND sproduc = reg.sproduc
                        AND cgarant = 0
                        AND sproces = psproces
                        AND cmodo = pmodo
                        AND ctipo = 1;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        valor := 0;
                        w_cgarant := 0;
                  END;

                  BEGIN
                     SELECT isinacu
                       INTO valor_actual
                       FROM ibnr_sam_sinacuml
                      WHERE fcalcul_i = w_fecha_inicio
                        AND fcalcul_j = fecha_siguiente2
                        AND sproduc = reg.sproduc
                        AND cgarant = 0
                        AND sproces = psproces
                        AND cmodo = pmodo
                        AND ctipo = 1;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        valor := 0;
                        w_cgarant := 0;
                  END;

                  BEGIN
                     valor := valor_actual / valor;
                  EXCEPTION
                     WHEN OTHERS THEN
                        valor := 0;
                  END;

                  BEGIN
                     --siniestros pagados
                     INSERT INTO ibnr_sam_factdesa
                                 (sproces, fcalcul, fcalcul_i, fcalcul_j, ctipo,
                                  ifacdes, cmodo, cgarant, sproduc)
                          VALUES (psproces, w_fecha_fin, w_fecha_inicio, fecha_siguiente, 1,
                                  NVL(valor, 0), pmodo, w_cgarant, reg.sproduc);
                  EXCEPTION
                     WHEN OTHERS THEN
                        p_tab_error
                              (f_sysdate, f_user,
                               'pac_provtec_conf.f_commit_calcul_ibnr sproces=' || psproces,
                               74,
                               'error al insertar en ibnr_sam_factdesa ctipo 1. fcalcul ='
                               || w_fecha_fin || ' fcalcul_i=' || w_fecha_inicio
                               || ' fcalcul_j=' || fecha_siguiente || ' pmodo=' || pmodo,
                               SQLERRM);
                        num_err := 108468;   -- error al insertar en la tabla
                  END;
               END LOOP;
            END LOOP;
         END IF;
      END LOOP;

/***********************IBNR_SAM_TABDESA********************/
--Factores de desarrollo y factor de cola
--triangulos por producto
      FOR reg IN c_productos LOOP
--triángulo de siniestros pagados/reservados ajustados IBNR_SAM_TABDESA
         IF NVL(pac_parametros.f_parproducto_n(reg.sproduc, 'IBNR_SAM_PROD'), 0) = 1 THEN
--agrupa a nivel de garantia
            FOR gar IN c_garantias_reservas LOOP
               w_cgarant := gar.cgarant;

               FOR i IN 1 .. meses - 1 LOOP
                  w_fecha_inicio := ADD_MONTHS(w_fecha_fin, -(meses - i));
                  valor_actual := 0;

                  --FOR j IN REVERSE 0 ..(meses - i) LOOP
                     --fecha_siguiente := ADD_MONTHS(w_fecha_inicio, j);
                     --fecha_siguiente2 := ADD_MONTHS(w_fecha_inicio, j + 1);

                  --siniestros pagados
                  BEGIN
                     SELECT MEDIAN(ifacdes)
                       INTO valor
                       FROM ibnr_sam_factdesa
                      WHERE fcalcul_i = w_fecha_inicio
                        -- AND fcalcul_j = fecha_siguiente
                        AND sproduc = reg.sproduc
                        AND cgarant = gar.cgarant
                        AND sproces = psproces
                        AND cmodo = pmodo
                        AND ctipo = 0;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        valor := 0;
                        w_cgarant := gar.cgarant;
                  END;

                  BEGIN
                     --siniestros pagados
                     INSERT INTO ibnr_sam_tabdesa
                                 (sproces, fcalcul, fcalcul_i, ctipo, ifactajus,
                                  cmodo, cgarant, sproduc)
                          VALUES (psproces, w_fecha_fin, w_fecha_inicio, 0, NVL(valor, 0),
                                  pmodo, w_cgarant, reg.sproduc);
                  EXCEPTION
                     WHEN OTHERS THEN
                        p_tab_error
                               (f_sysdate, f_user,
                                'pac_provtec_conf.f_commit_calcul_ibnr sproces=' || psproces,
                                81,
                                'error al insertar en ibnr_sam_tabdesa ctipo 0. fcalcul ='
                                || w_fecha_fin || ' fcalcul_i=' || w_fecha_inicio
                                || ' fcalcul_j=' || fecha_siguiente || ' pmodo=' || pmodo,
                                SQLERRM);
                        num_err := 108468;   -- error al insertar en la tabla
                  END;
               END LOOP;
            END LOOP;

            FOR gar IN c_garantias_reservas LOOP
               w_cgarant := gar.cgarant;

               FOR i IN 1 .. meses - 1 LOOP
                  w_fecha_inicio := ADD_MONTHS(w_fecha_fin, -(meses - i));
                  valor_actual := 0;

--siniestros reservados
                  BEGIN
                     SELECT MEDIAN(ifacdes)
                       INTO valor
                       FROM ibnr_sam_factdesa
                      WHERE fcalcul_i = w_fecha_inicio
                        -- AND fcalcul_j = fecha_siguiente
                        AND sproduc = reg.sproduc
                        AND cgarant = gar.cgarant
                        AND sproces = psproces
                        AND cmodo = pmodo
                        AND ctipo = 1;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        valor := 0;
                        w_cgarant := gar.cgarant;
                  END;

                  BEGIN
                     --siniestros reservados
                     INSERT INTO ibnr_sam_tabdesa
                                 (sproces, fcalcul, fcalcul_i, ctipo, ifactajus,
                                  cmodo, cgarant, sproduc)
                          VALUES (psproces, w_fecha_fin, w_fecha_inicio, 1, NVL(valor, 0),
                                  pmodo, w_cgarant, reg.sproduc);
                  EXCEPTION
                     WHEN OTHERS THEN
                        p_tab_error
                               (f_sysdate, f_user,
                                'pac_provtec_conf.f_commit_calcul_ibnr sproces=' || psproces,
                                82,
                                'error al insertar en ibnr_sam_tabdesa ctipo 1. fcalcul ='
                                || w_fecha_fin || ' fcalcul_i=' || w_fecha_inicio
                                || ' fcalcul_j=' || fecha_siguiente || ' pmodo=' || pmodo,
                                SQLERRM);
                        num_err := 108468;   -- error al insertar en la tabla
                  END;
               END LOOP;
            END LOOP;
         ELSIF NVL(pac_parametros.f_parproducto_n(reg.sproduc, 'IBNR_SAM_PROD'), 0) = 2 THEN
--agrupa todo
            w_cgarant := 0;

            FOR i IN 1 .. meses - 1 LOOP
               w_fecha_inicio := ADD_MONTHS(w_fecha_fin, -(meses - i));
               valor_actual := 0;

               --siniestros pagados
               BEGIN
                  SELECT MEDIAN(ifacdes)
                    INTO valor
                    FROM ibnr_sam_factdesa
                   WHERE fcalcul_i = w_fecha_inicio
                     -- AND fcalcul_j = fecha_siguiente
                     AND sproduc = reg.sproduc
                     AND cgarant = 0
                     AND sproces = psproces
                     AND cmodo = pmodo
                     AND ctipo = 0;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     valor := 0;
                     w_cgarant := 0;
               END;

               BEGIN
                  --siniestros pagados
                  INSERT INTO ibnr_sam_tabdesa
                              (sproces, fcalcul, fcalcul_i, ctipo, ifactajus,
                               cmodo, cgarant, sproduc)
                       VALUES (psproces, w_fecha_fin, w_fecha_inicio, 0, NVL(valor, 0),
                               pmodo, w_cgarant, reg.sproduc);
               EXCEPTION
                  WHEN OTHERS THEN
                     p_tab_error
                               (f_sysdate, f_user,
                                'pac_provtec_conf.f_commit_calcul_ibnr sproces=' || psproces,
                                83,
                                'error al insertar en ibnr_sam_tabdesa ctipo 0. fcalcul ='
                                || w_fecha_fin || ' fcalcul_i=' || w_fecha_inicio
                                || ' fcalcul_j=' || fecha_siguiente || ' pmodo=' || pmodo,
                                SQLERRM);
                     num_err := 108468;   -- error al insertar en la tabla
               END;
            END LOOP;

            FOR i IN 1 .. meses - 1 LOOP
               w_fecha_inicio := ADD_MONTHS(w_fecha_fin, -(meses - i));
               valor_actual := 0;

--siniestros reservados
               BEGIN
                  SELECT MEDIAN(ifacdes)
                    INTO valor
                    FROM ibnr_sam_factdesa
                   WHERE fcalcul_i = w_fecha_inicio
                     -- AND fcalcul_j = fecha_siguiente
                     AND sproduc = reg.sproduc
                     AND cgarant = 0
                     AND sproces = psproces
                     AND cmodo = pmodo
                     AND ctipo = 1;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     valor := 0;
                     w_cgarant := 0;
               END;

               BEGIN
                  --siniestros reservados
                  INSERT INTO ibnr_sam_tabdesa
                              (sproces, fcalcul, fcalcul_i, ctipo, ifactajus,
                               cmodo, cgarant, sproduc)
                       VALUES (psproces, w_fecha_fin, w_fecha_inicio, 1, NVL(valor, 0),
                               pmodo, w_cgarant, reg.sproduc);
               EXCEPTION
                  WHEN OTHERS THEN
                     p_tab_error
                               (f_sysdate, f_user,
                                'pac_provtec_conf.f_commit_calcul_ibnr sproces=' || psproces,
                                84,
                                'error al insertar en ibnr_sam_tabdesa ctipo 1. fcalcul ='
                                || w_fecha_fin || ' fcalcul_i=' || w_fecha_inicio
                                || ' fcalcul_j=' || fecha_siguiente || ' pmodo=' || pmodo,
                                SQLERRM);
                     num_err := 108468;   -- error al insertar en la tabla
               END;
            END LOOP;
         END IF;

         -- END LOOP;
         --END LOOP;

         --FACTOR DE COLA
         IF NVL(pac_parametros.f_parproducto_n(reg.sproduc, 'IBNR_SAM_PROD'), 0) = 1 THEN
--agrupa a nivel de garantia
            FOR gar IN c_garantias_reservas LOOP
               w_cgarant := gar.cgarant;

--siniestros pagados
               BEGIN
                  SELECT AVG(ifactajus)
                    INTO valor
                    FROM ibnr_sam_tabdesa
                   WHERE
                         -- fcalcul_i = w_fecha_fin
                           -- AND fcalcul_j = fecha_siguiente
                          -- AND
                         sproduc = reg.sproduc
                     AND cgarant = gar.cgarant
                     AND sproces = psproces
                     AND cmodo = pmodo
                     AND ctipo = 0;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     valor := 0;
                     w_cgarant := gar.cgarant;
               END;

               BEGIN
                  --siniestros pagados
                  INSERT INTO ibnr_sam_tabdesa
                              (sproces, fcalcul, fcalcul_i, ctipo, ifactajus, cmodo,
                               cgarant, sproduc)
                       VALUES (psproces, w_fecha_fin, w_fecha_fin, 0, NVL(valor, 0), pmodo,
                               w_cgarant, reg.sproduc);
               EXCEPTION
                  WHEN OTHERS THEN
                     p_tab_error
                               (f_sysdate, f_user,
                                'pac_provtec_conf.f_commit_calcul_ibnr sproces=' || psproces,
                                85,
                                'error al insertar en ibnr_sam_tabdesa ctipo 0. fcalcul ='
                                || w_fecha_fin || ' fcalcul_i=' || w_fecha_inicio
                                || ' fcalcul_j=' || fecha_siguiente || ' pmodo=' || pmodo,
                                SQLERRM);
                     num_err := 108468;   -- error al insertar en la tabla
               END;
            END LOOP;

            FOR gar IN c_garantias_reservas LOOP
               w_cgarant := gar.cgarant;

--siniestros reservados
               BEGIN
                  SELECT AVG(ifactajus)
                    INTO valor
                    FROM ibnr_sam_tabdesa
                   WHERE
                         --fcalcul_i = w_fecha_fin
                           -- AND fcalcul_j = fecha_siguiente
                          -- AND
                         sproduc = reg.sproduc
                     AND cgarant = gar.cgarant
                     AND sproces = psproces
                     AND cmodo = pmodo
                     AND ctipo = 1;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     valor := 0;
                     w_cgarant := gar.cgarant;
               END;

               BEGIN
                  --siniestros pagados
                  INSERT INTO ibnr_sam_tabdesa
                              (sproces, fcalcul, fcalcul_i, ctipo, ifactajus, cmodo,
                               cgarant, sproduc)
                       VALUES (psproces, w_fecha_fin, w_fecha_fin, 1, NVL(valor, 0), pmodo,
                               w_cgarant, reg.sproduc);
               EXCEPTION
                  WHEN OTHERS THEN
                     p_tab_error
                               (f_sysdate, f_user,
                                'pac_provtec_conf.f_commit_calcul_ibnr sproces=' || psproces,
                                86,
                                'error al insertar en ibnr_sam_tabdesa ctipo 1. fcalcul ='
                                || w_fecha_fin || ' fcalcul_i=' || w_fecha_inicio
                                || ' fcalcul_j=' || fecha_siguiente || ' pmodo=' || pmodo,
                                SQLERRM);
                     num_err := 108468;   -- error al insertar en la tabla
               END;
            END LOOP;
         ELSIF NVL(pac_parametros.f_parproducto_n(reg.sproduc, 'IBNR_SAM_PROD'), 0) = 2 THEN
            --siniestros pagados
            BEGIN
               SELECT AVG(ifactajus)
                 INTO valor
                 FROM ibnr_sam_tabdesa
                WHERE
                      --fcalcul_i = w_fecha_fin
                        -- AND fcalcul_j = fecha_siguiente
                       -- AND
                      sproduc = reg.sproduc
                  AND cgarant = 0
                  AND sproces = psproces
                  AND cmodo = pmodo
                  AND ctipo = 0;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  valor := 0;
                  w_cgarant := 0;
            END;

            BEGIN
               --siniestros pagados
               INSERT INTO ibnr_sam_tabdesa
                           (sproces, fcalcul, fcalcul_i, ctipo, ifactajus, cmodo,
                            cgarant, sproduc)
                    VALUES (psproces, w_fecha_fin, w_fecha_fin, 0, NVL(valor, 0), pmodo,
                            w_cgarant, reg.sproduc);
            EXCEPTION
               WHEN OTHERS THEN
                  p_tab_error(f_sysdate, f_user,
                              'pac_provtec_conf.f_commit_calcul_ibnr sproces=' || psproces, 87,
                              'error al insertar en ibnr_sam_tabdesa ctipo 0. fcalcul ='
                              || w_fecha_fin || ' fcalcul_i=' || w_fecha_inicio
                              || ' fcalcul_j=' || fecha_siguiente || ' pmodo=' || pmodo,
                              SQLERRM);
                  num_err := 108468;   -- error al insertar en la tabla
            END;

            --siniestros reservados
            BEGIN
               SELECT AVG(ifactajus)
                 INTO valor
                 FROM ibnr_sam_tabdesa
                WHERE
                      --fcalcul_i = w_fecha_fin
                        -- AND fcalcul_j = fecha_siguiente
                       -- AND
                      sproduc = reg.sproduc
                  AND cgarant = 0
                  AND sproces = psproces
                  AND cmodo = pmodo
                  AND ctipo = 1;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  valor := 0;
                  w_cgarant := 0;
            END;

            BEGIN
               --siniestros pagados
               INSERT INTO ibnr_sam_tabdesa
                           (sproces, fcalcul, fcalcul_i, ctipo, ifactajus, cmodo,
                            cgarant, sproduc)
                    VALUES (psproces, w_fecha_fin, w_fecha_fin, 1, NVL(valor, 0), pmodo,
                            w_cgarant, reg.sproduc);
            EXCEPTION
               WHEN OTHERS THEN
                  p_tab_error(f_sysdate, f_user,
                              'pac_provtec_conf.f_commit_calcul_ibnr sproces=' || psproces, 88,
                              'error al insertar en ibnr_sam_tabdesa ctipo 1. fcalcul ='
                              || w_fecha_fin || ' fcalcul_i=' || w_fecha_inicio
                              || ' fcalcul_j=' || fecha_siguiente || ' pmodo=' || pmodo,
                              SQLERRM);
                  num_err := 108468;   -- error al insertar en la tabla
            END;
         END IF;
      END LOOP;

      /***********************IBNR_SAM_FACDESA_ACUM********************/
--Factores de desarrollo acumulados   (FDAj)
--triangulos por producto
      FOR reg IN c_productos LOOP
         valor_actual := 1;
         valor_actual2 := 0;

         IF NVL(pac_parametros.f_parproducto_n(reg.sproduc, 'IBNR_SAM_PROD'), 0) = 1 THEN
--agrupa a nivel de garantia
            FOR gar IN c_garantias_reservas LOOP
               w_cgarant := gar.cgarant;

--triángulo de siniestros pagados/reservados ajustados IBNR_SAM_FACDESA_ACUM
               FOR i IN 1 .. meses LOOP
                  w_fecha_inicio := ADD_MONTHS(w_fecha_fin, -(meses - i));

                  --FOR j IN REVERSE 0 ..(meses - i) LOOP
                     --fecha_siguiente := ADD_MONTHS(w_fecha_inicio, j);
                     --fecha_siguiente2 := ADD_MONTHS(w_fecha_inicio, j + 1);

                  --siniestros pagados
                  BEGIN
                     SELECT ifactajus
                       INTO valor
                       FROM ibnr_sam_tabdesa
                      WHERE fcalcul_i = w_fecha_inicio
                        -- AND fcalcul_j = fecha_siguiente
                        AND sproduc = reg.sproduc
                        AND cgarant = gar.cgarant
                        AND sproces = psproces
                        AND cmodo = pmodo
                        AND ctipo = 0;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        valor := 0;
                        w_cgarant := gar.cgarant;
                  END;

                  valor_actual := valor * valor_actual;

                  BEGIN
                     --siniestros pagados
                     INSERT INTO ibnr_sam_facdesa_acum
                                 (sproces, fcalcul, fcalcul_i, ctipo,
                                  ifactacum, cmodo, cgarant, sproduc)
                          VALUES (psproces, w_fecha_fin, w_fecha_inicio, 0,
                                  NVL(valor_actual, 0), pmodo, w_cgarant, reg.sproduc);
                  EXCEPTION
                     WHEN OTHERS THEN
                        p_tab_error
                           (f_sysdate, f_user,
                            'pac_provtec_conf.f_commit_calcul_ibnr sproces=' || psproces, 101,
                            'error al insertar en ibnr_sam_facdesa_acum ctipo 0. fcalcul ='
                            || w_fecha_fin || ' fcalcul_i=' || w_fecha_inicio || ' fcalcul_j='
                            || fecha_siguiente || ' pmodo=' || pmodo,
                            SQLERRM);
                        num_err := 108468;   -- error al insertar en la tabla
                  END;
               END LOOP;
            END LOOP;

            valor_actual := 1;
            valor_actual2 := 0;

            FOR gar IN c_garantias_reservas LOOP
               w_cgarant := gar.cgarant;

               FOR i IN 1 .. meses LOOP
                  w_fecha_inicio := ADD_MONTHS(w_fecha_fin, -(meses - i));

--siniestros reservados
                  BEGIN
                     SELECT MEDIAN(ifactajus)
                       INTO valor
                       FROM ibnr_sam_tabdesa
                      WHERE fcalcul_i = w_fecha_inicio
                        -- AND fcalcul_j = fecha_siguiente
                        AND sproduc = reg.sproduc
                        AND cgarant = gar.cgarant
                        AND sproces = psproces
                        AND cmodo = pmodo
                        AND ctipo = 1;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        valor := 0;
                        w_cgarant := gar.cgarant;
                  END;

                  valor_actual2 := valor * valor_actual2;

                  BEGIN
                     --siniestros reservados
                     INSERT INTO ibnr_sam_facdesa_acum
                                 (sproces, fcalcul, fcalcul_i, ctipo,
                                  ifactacum, cmodo, cgarant, sproduc)
                          VALUES (psproces, w_fecha_fin, w_fecha_inicio, 1,
                                  NVL(valor_actual2, 0), pmodo, w_cgarant, reg.sproduc);
                  EXCEPTION
                     WHEN OTHERS THEN
                        p_tab_error
                           (f_sysdate, f_user,
                            'pac_provtec_conf.f_commit_calcul_ibnr sproces=' || psproces, 102,
                            'error al insertar en ibnr_sam_facdesa_acum ctipo 1. fcalcul ='
                            || w_fecha_fin || ' fcalcul_i=' || w_fecha_inicio || ' fcalcul_j='
                            || fecha_siguiente || ' pmodo=' || pmodo,
                            SQLERRM);
                        num_err := 108468;   -- error al insertar en la tabla
                  END;
               END LOOP;
            END LOOP;
         END IF;

         IF NVL(pac_parametros.f_parproducto_n(reg.sproduc, 'IBNR_SAM_PROD'), 0) = 2 THEN
--agrupa todo
            w_cgarant := 0;
            valor_actual := 1;
            valor_actual2 := 0;

--triángulo de siniestros pagados/reservados ajustados IBNR_SAM_FACDESA_ACUM
            FOR i IN 1 .. meses LOOP
               w_fecha_inicio := ADD_MONTHS(w_fecha_fin, -(meses - i));

               --siniestros pagados
               BEGIN
                  SELECT MEDIAN(ifactajus)
                    INTO valor
                    FROM ibnr_sam_tabdesa
                   WHERE fcalcul_i = w_fecha_inicio
                     -- AND fcalcul_j = fecha_siguiente
                     AND sproduc = reg.sproduc
                     AND cgarant = 0
                     AND sproces = psproces
                     AND cmodo = pmodo
                     AND ctipo = 0;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     valor := 0;
                     w_cgarant := 0;
               END;

               valor_actual := valor * valor_actual;

               BEGIN
                  --siniestros pagados
                  INSERT INTO ibnr_sam_facdesa_acum
                              (sproces, fcalcul, fcalcul_i, ctipo,
                               ifactacum, cmodo, cgarant, sproduc)
                       VALUES (psproces, w_fecha_fin, w_fecha_inicio, 0,
                               NVL(valor_actual, 0), pmodo, w_cgarant, reg.sproduc);
               EXCEPTION
                  WHEN OTHERS THEN
                     p_tab_error
                          (f_sysdate, f_user,
                           'pac_provtec_conf.f_commit_calcul_ibnr sproces=' || psproces, 103,
                           'error al insertar en ibnr_sam_facdesa_acum ctipo 0. fcalcul ='
                           || w_fecha_fin || ' fcalcul_i=' || w_fecha_inicio || ' fcalcul_j='
                           || fecha_siguiente || ' pmodo=' || pmodo,
                           SQLERRM);
                     num_err := 108468;   -- error al insertar en la tabla
               END;
            END LOOP;

            valor_actual := 1;
            valor_actual2 := 0;

            FOR i IN 1 .. meses LOOP
               w_fecha_inicio := ADD_MONTHS(w_fecha_fin, -(meses - i));

--siniestros reservados
               BEGIN
                  SELECT MEDIAN(ifactajus)
                    INTO valor
                    FROM ibnr_sam_tabdesa
                   WHERE fcalcul_i = w_fecha_inicio
                     -- AND fcalcul_j = fecha_siguiente
                     AND sproduc = reg.sproduc
                     AND cgarant = 0
                     AND sproces = psproces
                     AND cmodo = pmodo
                     AND ctipo = 1;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     valor := 0;
                     w_cgarant := 0;
               END;

               valor_actual2 := valor * valor_actual2;

               BEGIN
                  --siniestros reservados
                  INSERT INTO ibnr_sam_facdesa_acum
                              (sproces, fcalcul, fcalcul_i, ctipo,
                               ifactacum, cmodo, cgarant, sproduc)
                       VALUES (psproces, w_fecha_fin, w_fecha_inicio, 1,
                               NVL(valor_actual2, 0), pmodo, w_cgarant, reg.sproduc);
               EXCEPTION
                  WHEN OTHERS THEN
                     p_tab_error
                          (f_sysdate, f_user,
                           'pac_provtec_conf.f_commit_calcul_ibnr sproces=' || psproces, 104,
                           'error al insertar en ibnr_sam_facdesa_acum ctipo 1. fcalcul ='
                           || w_fecha_fin || ' fcalcul_i=' || w_fecha_inicio || ' fcalcul_j='
                           || fecha_siguiente || ' pmodo=' || pmodo,
                           SQLERRM);
                     num_err := 108468;   -- error al insertar en la tabla
               END;
            -- END LOOP;
            END LOOP;
         END IF;
      END LOOP;

      /***********************IBNR_SAM_UPE********************/
--Determinación de la última perdida esperada (UPE)
--triangulos por producto
      FOR reg IN c_productos LOOP
         valor_actual := 0;
         valor_actual2 := 0;

         IF NVL(pac_parametros.f_parproducto_n(reg.sproduc, 'IBNR_SAM_PROD'), 0) = 1 THEN
--agrupa a nivel de garantia
            FOR gar IN c_garantias_reservas LOOP
               w_cgarant := gar.cgarant;

--triángulo de siniestros pagados/reservados ajustados IBNR_SAM_UPE
               FOR i IN 1 .. meses LOOP
                  w_fecha_inicio := ADD_MONTHS(w_fecha_fin, -(meses - i));
                  fecha_siguiente := ADD_MONTHS(w_fecha_fin, -(i + 1));

                  --FOR j IN REVERSE 0 ..(meses - i) LOOP
                     --fecha_siguiente := ADD_MONTHS(w_fecha_inicio, j);
                     --fecha_siguiente2 := ADD_MONTHS(w_fecha_inicio, j + 1);

                  --siniestros pagados
                  BEGIN
                     SELECT ifactacum
                       INTO valor
                       FROM ibnr_sam_facdesa_acum
                      WHERE fcalcul_i = fecha_siguiente
                        -- AND fcalcul_j = fecha_siguiente
                        AND sproduc = reg.sproduc
                        AND cgarant = gar.cgarant
                        AND sproces = psproces
                        AND cmodo = pmodo
                        AND ctipo = 0;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        valor := 0;
                        w_cgarant := gar.cgarant;
                  END;

                  BEGIN
                     SELECT isinacu
                       INTO valor_actual
                       FROM ibnr_sam_sinacuml
                      WHERE fcalcul_i = w_fecha_inicio
                        AND fcalcul_j = fecha_siguiente
                        AND sproduc = reg.sproduc
                        AND cgarant = gar.cgarant
                        AND sproces = psproces
                        AND cmodo = pmodo
                        AND ctipo = 0;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        valor_actual := 0;
                        w_cgarant := gar.cgarant;
                  END;

                  valor_actual := valor * valor_actual;

                  BEGIN
                     --siniestros pagados
                     INSERT INTO ibnr_sam_upe
                                 (sproces, fcalcul, fcalcul_i, fcalcul_j, ctipo,
                                  iupe, cmodo, cgarant, sproduc)
                          VALUES (psproces, w_fecha_fin, w_fecha_inicio, fecha_siguiente, 0,
                                  NVL(valor_actual, 0), pmodo, w_cgarant, reg.sproduc);
                  EXCEPTION
                     WHEN OTHERS THEN
                        p_tab_error
                                   (f_sysdate, f_user,
                                    'pac_provtec_conf.f_commit_calcul_ibnr sproces='
                                    || psproces,
                                    111,
                                    'error al insertar en ibnr_sam_upe ctipo 0. fcalcul ='
                                    || w_fecha_fin || ' fcalcul_i=' || w_fecha_inicio
                                    || ' fcalcul_j=' || fecha_siguiente || ' pmodo=' || pmodo,
                                    SQLERRM);
                        num_err := 108468;   -- error al insertar en la tabla
                  END;
               END LOOP;
            END LOOP;

            FOR gar IN c_garantias_reservas LOOP
               w_cgarant := gar.cgarant;

--siniestros reservados
               FOR i IN 1 .. meses LOOP
                  w_fecha_inicio := ADD_MONTHS(w_fecha_fin, -(meses - i));
                  fecha_siguiente := ADD_MONTHS(w_fecha_fin, -(i + 1));

                  BEGIN
                     SELECT ifactacum
                       INTO valor
                       FROM ibnr_sam_facdesa_acum
                      WHERE fcalcul_i = fecha_siguiente
                        -- AND fcalcul_j = fecha_siguiente
                        AND sproduc = reg.sproduc
                        AND cgarant = gar.cgarant
                        AND sproces = psproces
                        AND cmodo = pmodo
                        AND ctipo = 1;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        valor := 0;
                        w_cgarant := gar.cgarant;
                  END;

                  BEGIN
                     SELECT isinacu
                       INTO valor_actual
                       FROM ibnr_sam_sinacuml
                      WHERE fcalcul_i = w_fecha_inicio
                        AND fcalcul_j = fecha_siguiente
                        AND sproduc = reg.sproduc
                        AND cgarant = gar.cgarant
                        AND sproces = psproces
                        AND cmodo = pmodo
                        AND ctipo = 1;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        valor_actual := 0;
                        w_cgarant := gar.cgarant;
                  END;

                  valor_actual := valor * valor_actual;

                  BEGIN
                     --siniestros pagados
                     INSERT INTO ibnr_sam_upe
                                 (sproces, fcalcul, fcalcul_i, fcalcul_j, ctipo,
                                  iupe, cmodo, cgarant, sproduc)
                          VALUES (psproces, w_fecha_fin, w_fecha_inicio, fecha_siguiente, 1,
                                  NVL(valor_actual, 0), pmodo, w_cgarant, reg.sproduc);
                  EXCEPTION
                     WHEN OTHERS THEN
                        p_tab_error
                                   (f_sysdate, f_user,
                                    'pac_provtec_conf.f_commit_calcul_ibnr sproces='
                                    || psproces,
                                    112,
                                    'error al insertar en ibnr_sam_upe ctipo 1. fcalcul ='
                                    || w_fecha_fin || ' fcalcul_i=' || w_fecha_inicio
                                    || ' fcalcul_j=' || fecha_siguiente || ' pmodo=' || pmodo,
                                    SQLERRM);
                        num_err := 108468;   -- error al insertar en la tabla
                  END;
               END LOOP;
            END LOOP;
         END IF;

         valor_actual := 0;
         valor_actual2 := 0;

         IF NVL(pac_parametros.f_parproducto_n(reg.sproduc, 'IBNR_SAM_PROD'), 0) = 2 THEN
--agrupa todo
            w_cgarant := 0;

            FOR i IN 1 .. meses LOOP
               w_fecha_inicio := ADD_MONTHS(w_fecha_fin, -(meses - i));
               fecha_siguiente := ADD_MONTHS(w_fecha_fin, -(i + 1));

               --siniestros pagados
               BEGIN
                  SELECT ifactacum
                    INTO valor
                    FROM ibnr_sam_facdesa_acum
                   WHERE fcalcul_i = fecha_siguiente
                     -- AND fcalcul_j = fecha_siguiente
                     AND sproduc = reg.sproduc
                     AND cgarant = 0
                     AND sproces = psproces
                     AND cmodo = pmodo
                     AND ctipo = 0;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     valor := 0;
                     w_cgarant := 0;
               END;

               BEGIN
                  SELECT isinacu
                    INTO valor_actual
                    FROM ibnr_sam_sinacuml
                   WHERE fcalcul_i = w_fecha_inicio
                     AND fcalcul_j = fecha_siguiente
                     AND sproduc = reg.sproduc
                     AND cgarant = 0
                     AND sproces = psproces
                     AND cmodo = pmodo
                     AND ctipo = 0;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     valor_actual := 0;
                     w_cgarant := 0;
               END;

               valor_actual := valor * valor_actual;

               BEGIN
                  --siniestros pagados
                  INSERT INTO ibnr_sam_upe
                              (sproces, fcalcul, fcalcul_i, fcalcul_j, ctipo,
                               iupe, cmodo, cgarant, sproduc)
                       VALUES (psproces, w_fecha_fin, w_fecha_inicio, fecha_siguiente, 0,
                               NVL(valor_actual, 0), pmodo, w_cgarant, reg.sproduc);
               EXCEPTION
                  WHEN OTHERS THEN
                     p_tab_error(f_sysdate, f_user,
                                 'pac_provtec_conf.f_commit_calcul_ibnr sproces=' || psproces,
                                 113,
                                 'error al insertar en ibnr_sam_upe ctipo 0. fcalcul ='
                                 || w_fecha_fin || ' fcalcul_i=' || w_fecha_inicio
                                 || ' fcalcul_j=' || fecha_siguiente || ' pmodo=' || pmodo,
                                 SQLERRM);
                     num_err := 108468;   -- error al insertar en la tabla
               END;
            END LOOP;

            FOR i IN 1 .. meses LOOP
               w_fecha_inicio := ADD_MONTHS(w_fecha_fin, -(meses - i));
               fecha_siguiente := ADD_MONTHS(w_fecha_fin, -(i + 1));

--siniestros reservados
               BEGIN
                  SELECT ifactacum
                    INTO valor
                    FROM ibnr_sam_facdesa_acum
                   WHERE fcalcul_i = fecha_siguiente
                     -- AND fcalcul_j = fecha_siguiente
                     AND sproduc = reg.sproduc
                     AND cgarant = 0
                     AND sproces = psproces
                     AND cmodo = pmodo
                     AND ctipo = 1;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     valor := 0;
                     w_cgarant := 0;
               END;

               BEGIN
                  SELECT isinacu
                    INTO valor_actual
                    FROM ibnr_sam_sinacuml
                   WHERE fcalcul_i = w_fecha_inicio
                     AND fcalcul_j = fecha_siguiente
                     AND sproduc = reg.sproduc
                     AND cgarant = 0
                     AND sproces = psproces
                     AND cmodo = pmodo
                     AND ctipo = 1;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     valor_actual := 0;
                     w_cgarant := 0;
               END;

               valor_actual := valor * valor_actual;

               BEGIN
                  --siniestros pagados
                  INSERT INTO ibnr_sam_upe
                              (sproces, fcalcul, fcalcul_i, fcalcul_j, ctipo,
                               iupe, cmodo, cgarant, sproduc)
                       VALUES (psproces, w_fecha_fin, w_fecha_inicio, fecha_siguiente, 1,
                               NVL(valor_actual, 0), pmodo, w_cgarant, reg.sproduc);
               EXCEPTION
                  WHEN OTHERS THEN
                     p_tab_error(f_sysdate, f_user,
                                 'pac_provtec_conf.f_commit_calcul_ibnr sproces=' || psproces,
                                 114,
                                 'error al insertar en ibnr_sam_upe ctipo 1. fcalcul ='
                                 || w_fecha_fin || ' fcalcul_i=' || w_fecha_inicio
                                 || ' fcalcul_j=' || fecha_siguiente || ' pmodo=' || pmodo,
                                 SQLERRM);
                     num_err := 108468;   -- error al insertar en la tabla
               END;
            END LOOP;
         END IF;
      -- END LOOP;
      END LOOP;

/***********************IBNR_SAM_SIN_PEND********************/
--Cálculo de los siniestros pendientes totales  ( Avisados y no avisados)
--triangulos por producto
      FOR reg IN c_productos LOOP
         valor_actual := 0;
         valor_actual2 := 0;

         IF NVL(pac_parametros.f_parproducto_n(reg.sproduc, 'IBNR_SAM_PROD'), 0) = 1 THEN
--agrupa a nivel de garantia
            FOR gar IN c_garantias_reservas LOOP
               w_cgarant := gar.cgarant;

--triángulo de siniestros pendientes totales IBNR_SAM_SIN_PEND
               FOR i IN 1 .. meses LOOP
                  w_fecha_inicio := ADD_MONTHS(w_fecha_fin, -(meses - i));
                  fecha_siguiente := ADD_MONTHS(w_fecha_fin, -(i + 1));

                  --FOR j IN REVERSE 0 ..(meses - i) LOOP
                     --fecha_siguiente := ADD_MONTHS(w_fecha_inicio, j);
                     --fecha_siguiente2 := ADD_MONTHS(w_fecha_inicio, j + 1);

                  --siniestros pagados
                  BEGIN
                     SELECT isinajus
                       INTO valor
                       FROM ibnr_sam_sinajus
                      WHERE fcalcul_i = w_fecha_inicio
                        AND fcalcul_j = fecha_siguiente
                        AND sproduc = reg.sproduc
                        AND cgarant = gar.cgarant
                        AND sproces = psproces
                        AND cmodo = pmodo
                        AND ctipo = 0;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        valor := 0;
                        w_cgarant := gar.cgarant;
                  END;

                  BEGIN
                     SELECT iupe
                       INTO valor_actual
                       FROM ibnr_sam_upe
                      WHERE fcalcul_i = w_fecha_inicio
                        AND fcalcul_j = fecha_siguiente
                        AND sproduc = reg.sproduc
                        AND cgarant = gar.cgarant
                        AND sproces = psproces
                        AND cmodo = pmodo
                        AND ctipo = 0;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        valor_actual := 0;
                        w_cgarant := gar.cgarant;
                  END;

                  valor_actual := valor_actual - valor;

                  BEGIN
                     --siniestros pagados
                     INSERT INTO ibnr_sam_sin_pend
                                 (sproces, fcalcul, fcalcul_i, fcalcul_j, ctipo,
                                  ispt, cmodo, cgarant, sproduc)
                          VALUES (psproces, w_fecha_fin, w_fecha_inicio, fecha_siguiente, 0,
                                  NVL(valor_actual, 0), pmodo, w_cgarant, reg.sproduc);
                  EXCEPTION
                     WHEN OTHERS THEN
                        p_tab_error
                              (f_sysdate, f_user,
                               'pac_provtec_conf.f_commit_calcul_ibnr sproces=' || psproces,
                               121,
                               'error al insertar en ibnr_sam_sin_pend ctipo 0. fcalcul ='
                               || w_fecha_fin || ' fcalcul_i=' || w_fecha_inicio
                               || ' fcalcul_j=' || fecha_siguiente || ' pmodo=' || pmodo,
                               SQLERRM);
                        num_err := 108468;   -- error al insertar en la tabla
                  END;
               END LOOP;
            END LOOP;

            valor_actual := 0;
            valor_actual2 := 0;

            FOR gar IN c_garantias_reservas LOOP
               w_cgarant := gar.cgarant;

--triángulo de siniestros pendientes totales IBNR_SAM_SIN_PEND
               FOR i IN 1 .. meses LOOP
--siniestros reservados
                  w_fecha_inicio := ADD_MONTHS(w_fecha_fin, -(meses - i));
                  fecha_siguiente := ADD_MONTHS(w_fecha_fin, -(i + 1));

                  BEGIN
                     SELECT isinajus
                       INTO valor
                       FROM ibnr_sam_sinajus
                      WHERE fcalcul_i = w_fecha_inicio
                        AND fcalcul_j = fecha_siguiente
                        AND sproduc = reg.sproduc
                        AND cgarant = gar.cgarant
                        AND sproces = psproces
                        AND cmodo = pmodo
                        AND ctipo = 1;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        valor := 0;
                        w_cgarant := gar.cgarant;
                  END;

                  BEGIN
                     SELECT iupe
                       INTO valor_actual
                       FROM ibnr_sam_upe
                      WHERE fcalcul_i = w_fecha_inicio
                        AND fcalcul_j = fecha_siguiente
                        AND sproduc = reg.sproduc
                        AND cgarant = gar.cgarant
                        AND sproces = psproces
                        AND cmodo = pmodo
                        AND ctipo = 1;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        valor_actual := 0;
                        w_cgarant := gar.cgarant;
                  END;

                  valor_actual := valor_actual - valor;

                  BEGIN
                     --siniestros pagados
                     INSERT INTO ibnr_sam_sin_pend
                                 (sproces, fcalcul, fcalcul_i, fcalcul_j, ctipo,
                                  ispt, cmodo, cgarant, sproduc)
                          VALUES (psproces, w_fecha_fin, w_fecha_inicio, fecha_siguiente, 1,
                                  NVL(valor_actual, 0), pmodo, w_cgarant, reg.sproduc);
                  EXCEPTION
                     WHEN OTHERS THEN
                        p_tab_error
                              (f_sysdate, f_user,
                               'pac_provtec_conf.f_commit_calcul_ibnr sproces=' || psproces,
                               122,
                               'error al insertar en ibnr_sam_sin_pend ctipo 1. fcalcul ='
                               || w_fecha_fin || ' fcalcul_i=' || w_fecha_inicio
                               || ' fcalcul_j=' || fecha_siguiente || ' pmodo=' || pmodo,
                               SQLERRM);
                        num_err := 108468;   -- error al insertar en la tabla
                  END;
               END LOOP;
            END LOOP;
         END IF;

         valor_actual := 0;
         valor_actual2 := 0;

         IF NVL(pac_parametros.f_parproducto_n(reg.sproduc, 'IBNR_SAM_PROD'), 0) = 2 THEN
--agrupa todo
            w_cgarant := 0;

            FOR i IN 1 .. meses LOOP
               w_fecha_inicio := ADD_MONTHS(w_fecha_fin, -(meses - i));
               fecha_siguiente := ADD_MONTHS(w_fecha_fin, -(i + 1));

               BEGIN
                  SELECT isinajus
                    INTO valor
                    FROM ibnr_sam_sinajus
                   WHERE fcalcul_i = w_fecha_inicio
                     AND fcalcul_j = fecha_siguiente
                     AND sproduc = reg.sproduc
                     AND cgarant = 0
                     AND sproces = psproces
                     AND cmodo = pmodo
                     AND ctipo = 0;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     valor := 0;
                     w_cgarant := 0;
               END;

               BEGIN
                  SELECT iupe
                    INTO valor_actual
                    FROM ibnr_sam_upe
                   WHERE fcalcul_i = w_fecha_inicio
                     AND fcalcul_j = fecha_siguiente
                     AND sproduc = reg.sproduc
                     AND cgarant = 0
                     AND sproces = psproces
                     AND cmodo = pmodo
                     AND ctipo = 0;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     valor_actual := 0;
                     w_cgarant := 0;
               END;

               valor_actual := valor_actual - valor;

               BEGIN
                  --siniestros pagados
                  INSERT INTO ibnr_sam_sin_pend
                              (sproces, fcalcul, fcalcul_i, fcalcul_j, ctipo,
                               ispt, cmodo, cgarant, sproduc)
                       VALUES (psproces, w_fecha_fin, w_fecha_inicio, fecha_siguiente, 0,
                               NVL(valor_actual, 0), pmodo, w_cgarant, reg.sproduc);
               EXCEPTION
                  WHEN OTHERS THEN
                     p_tab_error
                              (f_sysdate, f_user,
                               'pac_provtec_conf.f_commit_calcul_ibnr sproces=' || psproces,
                               123,
                               'error al insertar en ibnr_sam_sin_pend ctipo 0. fcalcul ='
                               || w_fecha_fin || ' fcalcul_i=' || w_fecha_inicio
                               || ' fcalcul_j=' || fecha_siguiente || ' pmodo=' || pmodo,
                               SQLERRM);
                     num_err := 108468;   -- error al insertar en la tabla
               END;
            END LOOP;

            valor_actual := 0;
            valor_actual2 := 0;

            FOR i IN 1 .. meses LOOP
               w_fecha_inicio := ADD_MONTHS(w_fecha_fin, -(meses - i));
               fecha_siguiente := ADD_MONTHS(w_fecha_fin, -(i + 1));

--siniestros reservados
               BEGIN
                  SELECT isinajus
                    INTO valor
                    FROM ibnr_sam_sinajus
                   WHERE fcalcul_i = w_fecha_inicio
                     AND fcalcul_j = fecha_siguiente
                     AND sproduc = reg.sproduc
                     AND cgarant = 0
                     AND sproces = psproces
                     AND cmodo = pmodo
                     AND ctipo = 1;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     valor := 0;
                     w_cgarant := 0;
               END;

               BEGIN
                  SELECT iupe
                    INTO valor_actual
                    FROM ibnr_sam_upe
                   WHERE fcalcul_i = w_fecha_inicio
                     AND fcalcul_j = fecha_siguiente
                     AND sproduc = reg.sproduc
                     AND cgarant = 0
                     AND sproces = psproces
                     AND cmodo = pmodo
                     AND ctipo = 1;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     valor_actual := 0;
                     w_cgarant := 0;
               END;

               valor_actual := valor_actual - valor;

               BEGIN
                  --siniestros pagados
                  INSERT INTO ibnr_sam_sin_pend
                              (sproces, fcalcul, fcalcul_i, fcalcul_j, ctipo,
                               ispt, cmodo, cgarant, sproduc)
                       VALUES (psproces, w_fecha_fin, w_fecha_inicio, fecha_siguiente, 1,
                               NVL(valor_actual, 0), pmodo, w_cgarant, reg.sproduc);
               EXCEPTION
                  WHEN OTHERS THEN
                     p_tab_error
                              (f_sysdate, f_user,
                               'pac_provtec_conf.f_commit_calcul_ibnr sproces=' || psproces,
                               124,
                               'error al insertar en ibnr_sam_sin_pend ctipo 1. fcalcul ='
                               || w_fecha_fin || ' fcalcul_i=' || w_fecha_inicio
                               || ' fcalcul_j=' || fecha_siguiente || ' pmodo=' || pmodo,
                               SQLERRM);
                     num_err := 108468;   -- error al insertar en la tabla
               END;
            END LOOP;
         END IF;
      -- END LOOP;
      END LOOP;

/***********************IBNR_SAM_FACDESA_ACUM********************/
--Cálculo del porcentaje de desarrollo de los siniestros ( Porcentaje que resta de desarrollo de los siniestros de la ocurrencia "i").
--triangulos por producto
      FOR reg IN c_productos LOOP
         valor_actual := 0;
         valor_actual2 := 0;

         IF NVL(pac_parametros.f_parproducto_n(reg.sproduc, 'IBNR_SAM_PROD'), 0) = 1 THEN
--agrupa a nivel de garantia
            FOR gar IN c_garantias_reservas LOOP
               w_cgarant := gar.cgarant;
               valor_actual := 0;
               valor_actual2 := 0;

--triángulo de siniestros pagados/reservados ajustados IBNR_SAM_FACDESA_ACUM
               FOR i IN 1 .. meses LOOP
                  w_fecha_inicio := ADD_MONTHS(w_fecha_fin, -(meses - i));
                  fecha_siguiente := ADD_MONTHS(w_fecha_fin, -(i + 1));

                  --FOR j IN REVERSE 0 ..(meses - i) LOOP
                     --fecha_siguiente := ADD_MONTHS(w_fecha_inicio, j);
                     --fecha_siguiente2 := ADD_MONTHS(w_fecha_inicio, j + 1);

                  --siniestros pagados
                  BEGIN
                     SELECT ifactacum
                       INTO valor
                       FROM ibnr_sam_facdesa_acum
                      WHERE fcalcul_i = fecha_siguiente
                        -- AND fcalcul_j = fecha_siguiente
                        AND sproduc = reg.sproduc
                        AND cgarant = gar.cgarant
                        AND sproces = psproces
                        AND cmodo = pmodo
                        AND ctipo = 0;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        valor := 0;
                        w_cgarant := gar.cgarant;
                  END;

                  BEGIN
                     valor := 1 -(1 / valor);
                  EXCEPTION
                     WHEN OTHERS THEN
                        valor := 0;
                  END;

                  BEGIN
                     --siniestros pagados
                     INSERT INTO ibnr_sam_pdesacu
                                 (sproces, fcalcul, fcalcul_i, ctipo, pdesacu,
                                  cmodo, cgarant, sproduc)
                          VALUES (psproces, w_fecha_fin, w_fecha_inicio, 0, NVL(valor, 0),
                                  pmodo, w_cgarant, reg.sproduc);
                  EXCEPTION
                     WHEN OTHERS THEN
                        p_tab_error
                               (f_sysdate, f_user,
                                'pac_provtec_conf.f_commit_calcul_ibnr sproces=' || psproces,
                                131,
                                'error al insertar en ibnr_sam_pdesacu ctipo 0. fcalcul ='
                                || w_fecha_fin || ' fcalcul_i=' || w_fecha_inicio
                                || ' fcalcul_j=' || fecha_siguiente || ' pmodo=' || pmodo,
                                SQLERRM);
                        num_err := 108468;   -- error al insertar en la tabla
                  END;
               END LOOP;
            END LOOP;

            FOR gar IN c_garantias_reservas LOOP
               w_cgarant := gar.cgarant;
               valor_actual := 0;
               valor_actual2 := 0;

--siniestros reservados
--triángulo de siniestros pagados/reservados ajustados IBNR_SAM_FACDESA_ACUM
               FOR i IN 1 .. meses LOOP
                  w_fecha_inicio := ADD_MONTHS(w_fecha_fin, -(meses - i));
                  fecha_siguiente := ADD_MONTHS(w_fecha_fin, -(i + 1));

                  BEGIN
                     SELECT ifactacum
                       INTO valor
                       FROM ibnr_sam_facdesa_acum
                      WHERE fcalcul_i = fecha_siguiente
                        -- AND fcalcul_j = fecha_siguiente
                        AND sproduc = reg.sproduc
                        AND cgarant = gar.cgarant
                        AND sproces = psproces
                        AND cmodo = pmodo
                        AND ctipo = 1;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        valor := 0;
                        w_cgarant := gar.cgarant;
                  END;

                  BEGIN
                     valor := 1 -(1 / valor);
                  EXCEPTION
                     WHEN OTHERS THEN
                        valor := 0;
                  END;

                  BEGIN
                     --siniestros pagados
                     INSERT INTO ibnr_sam_pdesacu
                                 (sproces, fcalcul, fcalcul_i, ctipo, pdesacu,
                                  cmodo, cgarant, sproduc)
                          VALUES (psproces, w_fecha_fin, w_fecha_inicio, 1, NVL(valor, 0),
                                  pmodo, w_cgarant, reg.sproduc);
                  EXCEPTION
                     WHEN OTHERS THEN
                        p_tab_error
                               (f_sysdate, f_user,
                                'pac_provtec_conf.f_commit_calcul_ibnr sproces=' || psproces,
                                132,
                                'error al insertar en ibnr_sam_pdesacu ctipo 1. fcalcul ='
                                || w_fecha_fin || ' fcalcul_i=' || w_fecha_inicio
                                || ' fcalcul_j=' || fecha_siguiente || ' pmodo=' || pmodo,
                                SQLERRM);
                        num_err := 108468;   -- error al insertar en la tabla
                  END;
               END LOOP;
            END LOOP;
         END IF;

         valor_actual := 0;
         valor_actual2 := 0;

         IF NVL(pac_parametros.f_parproducto_n(reg.sproduc, 'IBNR_SAM_PROD'), 0) = 2 THEN
--agrupa todo
            w_cgarant := 0;

            FOR i IN 1 .. meses LOOP
               w_fecha_inicio := ADD_MONTHS(w_fecha_fin, -(meses - i));
               fecha_siguiente := ADD_MONTHS(w_fecha_fin, -(i + 1));

               --siniestros pagados
               BEGIN
                  SELECT ifactacum
                    INTO valor
                    FROM ibnr_sam_facdesa_acum
                   WHERE fcalcul_i = fecha_siguiente
                     -- AND fcalcul_j = fecha_siguiente
                     AND sproduc = reg.sproduc
                     AND cgarant = 0
                     AND sproces = psproces
                     AND cmodo = pmodo
                     AND ctipo = 0;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     valor := 0;
                     w_cgarant := 0;
               END;

               BEGIN
                  valor := 1 -(1 / valor);
               EXCEPTION
                  WHEN OTHERS THEN
                     valor := 0;
               END;

               BEGIN
                  --siniestros pagados
                  INSERT INTO ibnr_sam_pdesacu
                              (sproces, fcalcul, fcalcul_i, ctipo, pdesacu,
                               cmodo, cgarant, sproduc)
                       VALUES (psproces, w_fecha_fin, w_fecha_inicio, 0, NVL(valor, 0),
                               pmodo, w_cgarant, reg.sproduc);
               EXCEPTION
                  WHEN OTHERS THEN
                     p_tab_error
                               (f_sysdate, f_user,
                                'pac_provtec_conf.f_commit_calcul_ibnr sproces=' || psproces,
                                133,
                                'error al insertar en ibnr_sam_pdesacu ctipo 0. fcalcul ='
                                || w_fecha_fin || ' fcalcul_i=' || w_fecha_inicio
                                || ' fcalcul_j=' || fecha_siguiente || ' pmodo=' || pmodo,
                                SQLERRM);
                     num_err := 108468;   -- error al insertar en la tabla
               END;
            END LOOP;

            valor_actual := 0;
            valor_actual2 := 0;

            FOR i IN 1 .. meses LOOP
               w_fecha_inicio := ADD_MONTHS(w_fecha_fin, -(meses - i));
               fecha_siguiente := ADD_MONTHS(w_fecha_fin, -(i + 1));

--siniestros reservados
               BEGIN
                  SELECT ifactacum
                    INTO valor
                    FROM ibnr_sam_facdesa_acum
                   WHERE fcalcul_i = fecha_siguiente
                     -- AND fcalcul_j = fecha_siguiente
                     AND sproduc = reg.sproduc
                     AND cgarant = 0
                     AND sproces = psproces
                     AND cmodo = pmodo
                     AND ctipo = 1;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     valor := 0;
                     w_cgarant := 0;
               END;

               BEGIN
                  valor := 1 -(1 / valor);
               EXCEPTION
                  WHEN OTHERS THEN
                     valor := 0;
               END;

               BEGIN
                  --siniestros pagados
                  INSERT INTO ibnr_sam_pdesacu
                              (sproces, fcalcul, fcalcul_i, ctipo, pdesacu,
                               cmodo, cgarant, sproduc)
                       VALUES (psproces, w_fecha_fin, w_fecha_inicio, 1, NVL(valor, 0),
                               pmodo, w_cgarant, reg.sproduc);
               EXCEPTION
                  WHEN OTHERS THEN
                     p_tab_error
                               (f_sysdate, f_user,
                                'pac_provtec_conf.f_commit_calcul_ibnr sproces=' || psproces,
                                134,
                                'error al insertar en ibnr_sam_pdesacu ctipo 1. fcalcul ='
                                || w_fecha_fin || ' fcalcul_i=' || w_fecha_inicio
                                || ' fcalcul_j=' || fecha_siguiente || ' pmodo=' || pmodo,
                                SQLERRM);
                     num_err := 108468;   -- error al insertar en la tabla
               END;
            END LOOP;
         END IF;
      -- END LOOP;
      END LOOP;

/***********************IBNR_SAM_SIN_PAPAG********************/
--Patrón de pago de los siniestros
--triangulos por producto
      FOR reg IN c_productos LOOP
         valor_actual := 0;
         valor_actual2 := 0;
         valor := 0;

         IF NVL(pac_parametros.f_parproducto_n(reg.sproduc, 'IBNR_SAM_PROD'), 0) = 1 THEN
--agrupa a nivel de garantia
            FOR gar IN c_garantias_reservas LOOP
               w_cgarant := gar.cgarant;

--siniestros pagados

               --triángulo de Patrón de pago de los siniestros IBNR_SAM_SIN_PAPAG
               FOR i IN 1 .. meses LOOP
                  w_fecha_inicio := ADD_MONTHS(w_fecha_fin, -(meses - i));
                  valor_actual := valor;

                  --fecha_siguiente := ADD_MONTHS(w_fecha_fin, -(i + 1));

                  --FOR j IN REVERSE 0 ..(meses - i) LOOP
                     --fecha_siguiente := ADD_MONTHS(w_fecha_inicio, j);
                     --fecha_siguiente2 := ADD_MONTHS(w_fecha_inicio, j + 1);
                  BEGIN
                     SELECT pdesacu
                       INTO valor
                       FROM ibnr_sam_pdesacu
                      WHERE fcalcul_i = w_fecha_inicio
                        -- AND fcalcul_j = fecha_siguiente
                        AND sproduc = reg.sproduc
                        AND cgarant = gar.cgarant
                        AND sproces = psproces
                        AND cmodo = pmodo
                        AND ctipo = 0;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        valor := 0;
                        w_cgarant := gar.cgarant;
                  END;

                  BEGIN
                     --siniestros pagados
                     INSERT INTO ibnr_sam_sin_papag
                                 (sproces, fcalcul, fcalcul_i, ctipo,
                                  ppapag, cmodo, cgarant, sproduc)
                          VALUES (psproces, w_fecha_fin, w_fecha_inicio, 0,
                                  NVL(valor - valor_actual, 0), pmodo, w_cgarant, reg.sproduc);
                  EXCEPTION
                     WHEN OTHERS THEN
                        p_tab_error
                             (f_sysdate, f_user,
                              'pac_provtec_conf.f_commit_calcul_ibnr sproces=' || psproces,
                              141,
                              'error al insertar en ibnr_sam_sin_papag ctipo 0. fcalcul ='
                              || w_fecha_fin || ' fcalcul_i=' || w_fecha_inicio
                              || ' fcalcul_j=' || fecha_siguiente || ' pmodo=' || pmodo,
                              SQLERRM);
                        num_err := 108468;   -- error al insertar en la tabla
                  END;
               END LOOP;
            END LOOP;

            valor_actual := 0;
            valor_actual2 := 0;
            valor2 := 0;

            FOR gar IN c_garantias_reservas LOOP
               w_cgarant := gar.cgarant;

--siniestros reservados

               --triángulo de Patrón de pago de los siniestros IBNR_SAM_SIN_PAPAG
               FOR i IN 1 .. meses LOOP
                  w_fecha_inicio := ADD_MONTHS(w_fecha_fin, -(meses - i));
                  valor_actual2 := valor2;

                  BEGIN
                     SELECT pdesacu
                       INTO valor2
                       FROM ibnr_sam_pdesacu
                      WHERE fcalcul_i = w_fecha_inicio
                        -- AND fcalcul_j = fecha_siguiente
                        AND sproduc = reg.sproduc
                        AND cgarant = gar.cgarant
                        AND sproces = psproces
                        AND cmodo = pmodo
                        AND ctipo = 1;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        valor2 := 0;
                        w_cgarant := gar.cgarant;
                  END;

                  BEGIN
                     --siniestros pagados
                     INSERT INTO ibnr_sam_sin_papag
                                 (sproces, fcalcul, fcalcul_i, ctipo,
                                  ppapag, cmodo, cgarant,
                                  sproduc)
                          VALUES (psproces, w_fecha_fin, w_fecha_inicio, 1,
                                  NVL(valor2 - valor_actual2, 0), pmodo, w_cgarant,
                                  reg.sproduc);
                  EXCEPTION
                     WHEN OTHERS THEN
                        p_tab_error
                             (f_sysdate, f_user,
                              'pac_provtec_conf.f_commit_calcul_ibnr sproces=' || psproces,
                              142,
                              'error al insertar en ibnr_sam_sin_papag ctipo 1. fcalcul ='
                              || w_fecha_fin || ' fcalcul_i=' || w_fecha_inicio
                              || ' fcalcul_j=' || fecha_siguiente || ' pmodo=' || pmodo,
                              SQLERRM);
                        num_err := 108468;   -- error al insertar en la tabla
                  END;
               END LOOP;
            END LOOP;
         END IF;

         valor_actual := 0;
         valor_actual2 := 0;
         valor := 0;

         IF NVL(pac_parametros.f_parproducto_n(reg.sproduc, 'IBNR_SAM_PROD'), 0) = 2 THEN
            FOR i IN 1 .. meses LOOP
               w_fecha_inicio := ADD_MONTHS(w_fecha_fin, -(meses - i));
               --fecha_siguiente := ADD_MONTHS(w_fecha_fin, -(i + 1));

               --FOR j IN REVERSE 0 ..(meses - i) LOOP
                  --fecha_siguiente := ADD_MONTHS(w_fecha_inicio, j);
                  --fecha_siguiente2 := ADD_MONTHS(w_fecha_inicio, j + 1);

               --agrupa todo
              -- FOR gar IN c_garantias_pagos LOOP
--siniestros pagados
               valor_actual := valor;

               BEGIN
                  SELECT pdesacu
                    INTO valor
                    FROM ibnr_sam_pdesacu
                   WHERE fcalcul_i = w_fecha_inicio
                     -- AND fcalcul_j = fecha_siguiente
                     AND sproduc = reg.sproduc
                     AND cgarant = 0
                     AND sproces = psproces
                     AND cmodo = pmodo
                     AND ctipo = 0;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     valor := 0;
                     w_cgarant := 0;
               END;

               BEGIN
                  --siniestros pagados
                  INSERT INTO ibnr_sam_sin_papag
                              (sproces, fcalcul, fcalcul_i, ctipo,
                               ppapag, cmodo, cgarant, sproduc)
                       VALUES (psproces, w_fecha_fin, w_fecha_inicio, 0,
                               NVL(valor - valor_actual, 0), pmodo, w_cgarant, reg.sproduc);
               EXCEPTION
                  WHEN OTHERS THEN
                     p_tab_error
                             (f_sysdate, f_user,
                              'pac_provtec_conf.f_commit_calcul_ibnr sproces=' || psproces,
                              143,
                              'error al insertar en ibnr_sam_sin_papag ctipo 0. fcalcul ='
                              || w_fecha_fin || ' fcalcul_i=' || w_fecha_inicio
                              || ' fcalcul_j=' || fecha_siguiente || ' pmodo=' || pmodo,
                              SQLERRM);
                     num_err := 108468;   -- error al insertar en la tabla
               END;
            -- END LOOP;
            END LOOP;

            valor_actual := 0;
            valor_actual2 := 0;
            valor2 := 0;

            FOR i IN 1 .. meses LOOP
               w_fecha_inicio := ADD_MONTHS(w_fecha_fin, -(meses - i));
               --  FOR gar IN c_garantias_reservas LOOP
--siniestros reservados
               valor_actual2 := valor2;

               BEGIN
                  SELECT pdesacu
                    INTO valor2
                    FROM ibnr_sam_pdesacu
                   WHERE fcalcul_i = w_fecha_inicio
                     -- AND fcalcul_j = fecha_siguiente
                     AND sproduc = reg.sproduc
                     AND cgarant = 0
                     AND sproces = psproces
                     AND cmodo = pmodo
                     AND ctipo = 1;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     valor2 := 0;
                     w_cgarant := 0;
               END;

               BEGIN
                  --siniestros pagados
                  INSERT INTO ibnr_sam_sin_papag
                              (sproces, fcalcul, fcalcul_i, ctipo,
                               ppapag, cmodo, cgarant, sproduc)
                       VALUES (psproces, w_fecha_fin, w_fecha_inicio, 1,
                               NVL(valor2 - valor_actual2, 0), pmodo, w_cgarant, reg.sproduc);
               EXCEPTION
                  WHEN OTHERS THEN
                     p_tab_error
                             (f_sysdate, f_user,
                              'pac_provtec_conf.f_commit_calcul_ibnr sproces=' || psproces,
                              144,
                              'error al insertar en ibnr_sam_sin_papag ctipo 1. fcalcul ='
                              || w_fecha_fin || ' fcalcul_i=' || w_fecha_inicio
                              || ' fcalcul_j=' || fecha_siguiente || ' pmodo=' || pmodo,
                              SQLERRM);
                     num_err := 108468;   -- error al insertar en la tabla
               END;
             -- END LOOP;
            --  END LOOP;
            END LOOP;
         END IF;
      END LOOP;

/***********************IBNR_SAM_FACDESA********************/
--Factores de desarrollo de los siniestros pendientes totales ajustado por inflación (FSPTIi)
--triangulos por producto
      BEGIN
         w_fecha_inicio := ADD_MONTHS(w_fecha_fin, -(meses - 1));

         SELECT AVG(pipc)
           INTO vpinflac
           FROM ipc
          WHERE TO_DATE('01' || nmes || nanyo, 'ddmmrrrr') BETWEEN w_fecha_inicio AND w_fecha_fin;
      EXCEPTION
         WHEN OTHERS THEN
            vpinflac := 0;
      END;

      FOR reg IN c_productos LOOP
         valor_actual := 0;
         valor_actual2 := 0;

         IF NVL(pac_parametros.f_parproducto_n(reg.sproduc, 'IBNR_SAM_PROD'), 0) = 1 THEN
--agrupa a nivel de garantia
            FOR gar IN c_garantias_reservas LOOP
               w_cgarant := gar.cgarant;
--triángulo de Patrón de pago de los siniestros IBNR_SAM_FACDESA
               vpower := 1;

               FOR i IN 1 .. meses LOOP
                  w_fecha_inicio := ADD_MONTHS(w_fecha_fin, -(meses - i));

                  --fecha_siguiente := ADD_MONTHS(w_fecha_fin, -(i + 1));

                  --FOR j IN REVERSE 0 ..(meses - i) LOOP
                     --fecha_siguiente := ADD_MONTHS(w_fecha_inicio, j);
                     --fecha_siguiente2 := ADD_MONTHS(w_fecha_inicio, j + 1);

                  --siniestros pagados
                  --valor_actual := valor;
                  BEGIN
                     SELECT pdesacu
                       INTO valor
                       FROM ibnr_sam_pdesacu
                      WHERE fcalcul_i = w_fecha_inicio
                        -- AND fcalcul_j = fecha_siguiente
                        AND sproduc = reg.sproduc
                        AND cgarant = gar.cgarant
                        AND sproces = psproces
                        AND cmodo = pmodo
                        AND ctipo = 0;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        valor := 0;
                        w_cgarant := gar.cgarant;
                  END;

                  BEGIN
                     SELECT ppapag
                       INTO valor_actual
                       FROM ibnr_sam_sin_papag
                      WHERE fcalcul_i = w_fecha_inicio
                        -- AND fcalcul_j = fecha_siguiente
                        AND sproduc = reg.sproduc
                        AND cgarant = gar.cgarant
                        AND sproces = psproces
                        AND cmodo = pmodo
                        AND ctipo = 0;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        valor_actual := 0;
                        w_cgarant := gar.cgarant;
                  END;

                  BEGIN
                     IF vpower = 1 THEN
                        vtotal := valor_actual * POWER(vpinflac, vpower);
                        valor_actual2 := (1 / valor) * vtotal;
                     ELSE
                        vtotal := vtotal +(valor_actual * POWER(vpinflac, vpower));
                        --valor_actual2 := valor_actual2 + valor_actual * POWER (vpinflac, vpower);
                        valor_actual2 := (1 / valor) * vtotal;
                     END IF;
                  EXCEPTION
                     WHEN OTHERS THEN
                        valor_actual2 := 0;
                        vtotal := 0;
                  END;

                  BEGIN
                     --siniestros pagados
                     INSERT INTO ibnr_sam_facdesa
                                 (sproces, fcalcul, fcalcul_i, ctipo,
                                  ifactor, cmodo, cgarant, sproduc)
                          VALUES (psproces, w_fecha_fin, w_fecha_inicio, 0,
                                  NVL(valor_actual2, 0), pmodo, w_cgarant, reg.sproduc);
                  EXCEPTION
                     WHEN OTHERS THEN
                        p_tab_error
                               (f_sysdate, f_user,
                                'pac_provtec_conf.f_commit_calcul_ibnr sproces=' || psproces,
                                151,
                                'error al insertar en ibnr_sam_facdesa ctipo 0. fcalcul ='
                                || w_fecha_fin || ' fcalcul_i=' || w_fecha_inicio
                                || ' fcalcul_j=' || fecha_siguiente || ' pmodo=' || pmodo,
                                SQLERRM);
                        num_err := 108468;   -- error al insertar en la tabla
                  END;

                  vpower := vpower + 1;
               END LOOP;
            END LOOP;

            FOR gar IN c_garantias_reservas LOOP
               w_cgarant := gar.cgarant;
--triángulo de Patrón de pago de los siniestros IBNR_SAM_FACDESA
               vpower := 1;

               FOR i IN 1 .. meses LOOP
                  w_fecha_inicio := ADD_MONTHS(w_fecha_fin, -(meses - i));

--siniestros reservados
                  --valor_actual2 := valor2;
                  BEGIN
                     SELECT pdesacu
                       INTO valor2
                       FROM ibnr_sam_pdesacu
                      WHERE fcalcul_i = w_fecha_inicio
                        -- AND fcalcul_j = fecha_siguiente
                        AND sproduc = reg.sproduc
                        AND cgarant = gar.cgarant
                        AND sproces = psproces
                        AND cmodo = pmodo
                        AND ctipo = 1;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        valor2 := 0;
                        w_cgarant := gar.cgarant;
                  END;

                  BEGIN
                     SELECT ppapag
                       INTO valor_actual3
                       FROM ibnr_sam_sin_papag
                      WHERE fcalcul_i = w_fecha_inicio
                        -- AND fcalcul_j = fecha_siguiente
                        AND sproduc = reg.sproduc
                        AND cgarant = gar.cgarant
                        AND sproces = psproces
                        AND cmodo = pmodo
                        AND ctipo = 1;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        valor_actual3 := 0;
                        w_cgarant := gar.cgarant;
                  END;

                  BEGIN
                     IF vpower = 1 THEN
                        vtotal2 := valor_actual3 * POWER(vpinflac, vpower);
                        valor_actual4 := (1 / valor2) * vtotal2;
                     ELSE
                        vtotal2 := vtotal2 +(valor_actual3 * POWER(vpinflac, vpower));
                        --valor_actual2 := valor_actual2 + valor_actual * POWER (vpinflac, vpower);
                        valor_actual4 := (1 / valor2) * vtotal2;
                     END IF;
                  EXCEPTION
                     WHEN OTHERS THEN
                        valor_actual4 := 0;
                        vtotal2 := 0;
                  END;

                  BEGIN
                     --siniestros pagados
                     INSERT INTO ibnr_sam_facdesa
                                 (sproces, fcalcul, fcalcul_i, ctipo,
                                  ifactor, cmodo, cgarant, sproduc)
                          VALUES (psproces, w_fecha_fin, w_fecha_inicio, 1,
                                  NVL(valor_actual4, 0), pmodo, w_cgarant, reg.sproduc);
                  EXCEPTION
                     WHEN OTHERS THEN
                        p_tab_error
                               (f_sysdate, f_user,
                                'pac_provtec_conf.f_commit_calcul_ibnr sproces=' || psproces,
                                152,
                                'error al insertar en ibnr_sam_facdesa ctipo 1. fcalcul ='
                                || w_fecha_fin || ' fcalcul_i=' || w_fecha_inicio
                                || ' fcalcul_j=' || fecha_siguiente || ' pmodo=' || pmodo,
                                SQLERRM);
                        num_err := 108468;   -- error al insertar en la tabla
                  END;

                  vpower := vpower + 1;
               END LOOP;
            END LOOP;
         END IF;

         vtotal := 0;
         vtotal2 := 0;
         vpower := 1;

         IF NVL(pac_parametros.f_parproducto_n(reg.sproduc, 'IBNR_SAM_PROD'), 0) = 2 THEN
            --triángulo de Patrón de pago de los siniestros IBNR_SAM_FACDESA
            FOR i IN 1 .. meses LOOP
               w_fecha_inicio := ADD_MONTHS(w_fecha_fin, -(meses - i));

               --fecha_siguiente := ADD_MONTHS(w_fecha_fin, -(i + 1));

               --FOR j IN REVERSE 0 ..(meses - i) LOOP
                  --fecha_siguiente := ADD_MONTHS(w_fecha_inicio, j);
                  --fecha_siguiente2 := ADD_MONTHS(w_fecha_inicio, j + 1);

               --agrupa todo
              -- FOR gar IN c_garantias_pagos LOOP
--siniestros pagados
                  --valor_actual := valor;
               BEGIN
                  SELECT pdesacu
                    INTO valor
                    FROM ibnr_sam_pdesacu
                   WHERE fcalcul_i = w_fecha_inicio
                     -- AND fcalcul_j = fecha_siguiente
                     AND sproduc = reg.sproduc
                     AND cgarant = 0
                     AND sproces = psproces
                     AND cmodo = pmodo
                     AND ctipo = 0;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     valor := 0;
                     w_cgarant := 0;
               END;

               BEGIN
                  SELECT ppapag
                    INTO valor_actual
                    FROM ibnr_sam_sin_papag
                   WHERE fcalcul_i = w_fecha_inicio
                     -- AND fcalcul_j = fecha_siguiente
                     AND sproduc = reg.sproduc
                     AND cgarant = 0
                     AND sproces = psproces
                     AND cmodo = pmodo
                     AND ctipo = 0;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     valor_actual := 0;
                     w_cgarant := 0;
               END;

               BEGIN
                  IF vpower = 1 THEN
                     vtotal := valor_actual * POWER(vpinflac, vpower);
                     valor_actual2 := (1 / valor) * vtotal;
                  ELSE
                     vtotal := vtotal +(valor_actual * POWER(vpinflac, vpower));
                     --valor_actual2 := valor_actual2 + valor_actual * POWER (vpinflac, vpower);
                     valor_actual2 := (1 / valor) * vtotal;
                  END IF;
               EXCEPTION
                  WHEN OTHERS THEN
                     valor_actual2 := 0;
                     vtotal := 0;
               END;

               BEGIN
                  --siniestros pagados
                  INSERT INTO ibnr_sam_facdesa
                              (sproces, fcalcul, fcalcul_i, ctipo,
                               ifactor, cmodo, cgarant, sproduc)
                       VALUES (psproces, w_fecha_fin, w_fecha_inicio, 0,
                               NVL(valor_actual2, 0), pmodo, w_cgarant, reg.sproduc);
               EXCEPTION
                  WHEN OTHERS THEN
                     p_tab_error
                               (f_sysdate, f_user,
                                'pac_provtec_conf.f_commit_calcul_ibnr sproces=' || psproces,
                                153,
                                'error al insertar en ibnr_sam_facdesa ctipo 0. fcalcul ='
                                || w_fecha_fin || ' fcalcul_i=' || w_fecha_inicio
                                || ' fcalcul_j=' || fecha_siguiente || ' pmodo=' || pmodo,
                                SQLERRM);
                     num_err := 108468;   -- error al insertar en la tabla
               END;

               vpower := vpower + 1;
            END LOOP;

            vpower := 1;

            FOR i IN 1 .. meses LOOP
               w_fecha_inicio := ADD_MONTHS(w_fecha_fin, -(meses - i));

               --END LOOP;

               -- FOR gar IN c_garantias_reservas LOOP
--siniestros reservados
                  --valor_actual2 := valor2;
               BEGIN
                  SELECT pdesacu
                    INTO valor2
                    FROM ibnr_sam_pdesacu
                   WHERE fcalcul_i = w_fecha_inicio
                     -- AND fcalcul_j = fecha_siguiente
                     AND sproduc = reg.sproduc
                     AND cgarant = 0
                     AND sproces = psproces
                     AND cmodo = pmodo
                     AND ctipo = 1;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     valor2 := 0;
                     w_cgarant := 0;
               END;

               BEGIN
                  SELECT ppapag
                    INTO valor_actual3
                    FROM ibnr_sam_sin_papag
                   WHERE fcalcul_i = w_fecha_inicio
                     -- AND fcalcul_j = fecha_siguiente
                     AND sproduc = reg.sproduc
                     AND cgarant = 0
                     AND sproces = psproces
                     AND cmodo = pmodo
                     AND ctipo = 1;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     valor_actual3 := 0;
                     w_cgarant := 0;
               END;

               BEGIN
                  IF vpower = 1 THEN
                     vtotal2 := valor_actual3 * POWER(vpinflac, vpower);
                     valor_actual4 := (1 / valor2) * vtotal2;
                  ELSE
                     vtotal2 := vtotal2 +(valor_actual3 * POWER(vpinflac, vpower));
                     --valor_actual2 := valor_actual2 + valor_actual * POWER (vpinflac, vpower);
                     valor_actual4 := (1 / valor2) * vtotal2;
                  END IF;
               EXCEPTION
                  WHEN OTHERS THEN
                     valor_actual4 := 0;
                     vtotal2 := 0;
               END;

               BEGIN
                  --siniestros pagados
                  INSERT INTO ibnr_sam_facdesa
                              (sproces, fcalcul, fcalcul_i, ctipo,
                               ifactor, cmodo, cgarant, sproduc)
                       VALUES (psproces, w_fecha_fin, w_fecha_inicio, 1,
                               NVL(valor_actual4, 0), pmodo, w_cgarant, reg.sproduc);
               EXCEPTION
                  WHEN OTHERS THEN
                     p_tab_error
                               (f_sysdate, f_user,
                                'pac_provtec_conf.f_commit_calcul_ibnr sproces=' || psproces,
                                154,
                                'error al insertar en ibnr_sam_facdesa ctipo 1. fcalcul ='
                                || w_fecha_fin || ' fcalcul_i=' || w_fecha_inicio
                                || ' fcalcul_j=' || fecha_siguiente || ' pmodo=' || pmodo,
                                SQLERRM);
                     num_err := 108468;   -- error al insertar en la tabla
               END;

               -- END LOOP;
               vpower := vpower + 1;
            END LOOP;
         END IF;
      END LOOP;

--Cálculo de la reserva de siniestros ocurridos y no avisados o no suficientemente avisados ajustada por inflación
/***********************IBNR_SAM********************/
--Cálculo de la reserva de siniestros ocurridos y no avisados o no suficientemente avisados ajustada por inflación
--triangulos por producto
      FOR reg IN c_productos LOOP
         valor_actual := 0;
         valor_actual2 := 0;

         IF NVL(pac_parametros.f_parproducto_n(reg.sproduc, 'IBNR_SAM_PROD'), 0) = 1 THEN
--agrupa a nivel de garantia
            FOR gar IN c_garantias_reservas LOOP
               w_cgarant := gar.cgarant;

--triángulo de siniestros pendientes totales IBNR_SAM
               FOR i IN 1 .. meses LOOP
                  w_fecha_inicio := ADD_MONTHS(w_fecha_fin, -(meses - i));
                  fecha_siguiente := ADD_MONTHS(w_fecha_fin, -(i + 1));

                  --FOR j IN REVERSE 0 ..(meses - i) LOOP
                     --fecha_siguiente := ADD_MONTHS(w_fecha_inicio, j);
                     --fecha_siguiente2 := ADD_MONTHS(w_fecha_inicio, j + 1);

                  --siniestros pagados
                  BEGIN
                     SELECT ispt
                       INTO valor
                       FROM ibnr_sam_sin_pend
                      WHERE fcalcul_i = w_fecha_inicio
                        AND fcalcul_j = fecha_siguiente
                        AND sproduc = reg.sproduc
                        AND cgarant = gar.cgarant
                        AND sproces = psproces
                        AND cmodo = pmodo
                        AND ctipo = 0;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        valor := 0;
                        w_cgarant := gar.cgarant;
                  END;

                  BEGIN
                     SELECT ifactor
                       INTO valor2
                       FROM ibnr_sam_facdesa
                      WHERE fcalcul_i = w_fecha_inicio
                        AND sproduc = reg.sproduc
                        AND cgarant = gar.cgarant
                        AND sproces = psproces
                        AND cmodo = pmodo
                        AND ctipo = 0;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        valor2 := 0;
                        w_cgarant := gar.cgarant;
                  END;

                  BEGIN
                     SELECT isinret
                       INTO valor3
                       FROM ibnr_sam_siniestros
                      WHERE fcalcul_i = w_fecha_inicio
                        AND fcalcul_j = fecha_siguiente
                        AND sproduc = reg.sproduc
                        AND cgarant = gar.cgarant
                        AND sproces = psproces
                        AND cmodo = pmodo
                        AND ctipo = 0;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        valor3 := 0;
                        w_cgarant := gar.cgarant;
                  END;

                  vtotal := (valor * valor2) - valor3;

                  BEGIN
                     --siniestros pagados
                     INSERT INTO ibnr_sam
                                 (sproces, fcalcul, fcalcul_i, fcalcul_j, ctipo,
                                  ibnr, cmodo, cgarant, sproduc)
                          VALUES (psproces, w_fecha_fin, w_fecha_inicio, fecha_siguiente, 0,
                                  NVL(vtotal, 0), pmodo, w_cgarant, reg.sproduc);
                  EXCEPTION
                     WHEN OTHERS THEN
                        p_tab_error(f_sysdate, f_user,
                                    'pac_provtec_conf.f_commit_calcul_ibnr sproces='
                                    || psproces,
                                    161,
                                    'error al insertar en ibnr_sam ctipo 0. fcalcul ='
                                    || w_fecha_fin || ' fcalcul_i=' || w_fecha_inicio
                                    || ' fcalcul_j=' || fecha_siguiente || ' pmodo=' || pmodo,
                                    SQLERRM);
                        num_err := 108468;   -- error al insertar en la tabla
                  END;
               END LOOP;
            END LOOP;

            valor_actual := 0;
            valor_actual2 := 0;

            FOR gar IN c_garantias_reservas LOOP
               w_cgarant := gar.cgarant;

--triángulo de siniestros pendientes totales IBNR_SAM
               FOR i IN 1 .. meses LOOP
                  w_fecha_inicio := ADD_MONTHS(w_fecha_fin, -(meses - i));
                  fecha_siguiente := ADD_MONTHS(w_fecha_fin, -(i + 1));

--siniestros reservados
                  BEGIN
                     SELECT ispt
                       INTO valor
                       FROM ibnr_sam_sin_pend
                      WHERE fcalcul_i = w_fecha_inicio
                        AND fcalcul_j = fecha_siguiente
                        AND sproduc = reg.sproduc
                        AND cgarant = gar.cgarant
                        AND sproces = psproces
                        AND cmodo = pmodo
                        AND ctipo = 1;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        valor := 0;
                        w_cgarant := gar.cgarant;
                  END;

                  BEGIN
                     SELECT ifactor
                       INTO valor2
                       FROM ibnr_sam_facdesa
                      WHERE fcalcul_i = w_fecha_inicio
                        AND sproduc = reg.sproduc
                        AND cgarant = gar.cgarant
                        AND sproces = psproces
                        AND cmodo = pmodo
                        AND ctipo = 1;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        valor2 := 0;
                        w_cgarant := gar.cgarant;
                  END;

                  BEGIN
                     SELECT isinret
                       INTO valor3
                       FROM ibnr_sam_siniestros
                      WHERE fcalcul_i = w_fecha_inicio
                        AND fcalcul_j = fecha_siguiente
                        AND sproduc = reg.sproduc
                        AND cgarant = gar.cgarant
                        AND sproces = psproces
                        AND cmodo = pmodo
                        AND ctipo = 1;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        valor3 := 0;
                        w_cgarant := gar.cgarant;
                  END;

                  vtotal := (valor * valor2) - valor3;

                  BEGIN
                     --siniestros pagados
                     INSERT INTO ibnr_sam
                                 (sproces, fcalcul, fcalcul_i, fcalcul_j, ctipo,
                                  ibnr, cmodo, cgarant, sproduc)
                          VALUES (psproces, w_fecha_fin, w_fecha_inicio, fecha_siguiente, 1,
                                  NVL(vtotal, 0), pmodo, w_cgarant, reg.sproduc);
                  EXCEPTION
                     WHEN OTHERS THEN
                        p_tab_error(f_sysdate, f_user,
                                    'pac_provtec_conf.f_commit_calcul_ibnr sproces='
                                    || psproces,
                                    162,
                                    'error al insertar en ibnr_sam ctipo 1. fcalcul ='
                                    || w_fecha_fin || ' fcalcul_i=' || w_fecha_inicio
                                    || ' fcalcul_j=' || fecha_siguiente || ' pmodo=' || pmodo,
                                    SQLERRM);
                        num_err := 108468;   -- error al insertar en la tabla
                  END;
               END LOOP;
            END LOOP;
         END IF;

         valor_actual := 0;
         valor_actual2 := 0;

         IF NVL(pac_parametros.f_parproducto_n(reg.sproduc, 'IBNR_SAM_PROD'), 0) = 2 THEN
--agrupa todo
            w_cgarant := 0;

            FOR i IN 1 .. meses LOOP
               w_fecha_inicio := ADD_MONTHS(w_fecha_fin, -(meses - i));
               fecha_siguiente := ADD_MONTHS(w_fecha_fin, -(i + 1));

               BEGIN
                  SELECT ispt
                    INTO valor
                    FROM ibnr_sam_sin_pend
                   WHERE fcalcul_i = w_fecha_inicio
                     AND fcalcul_j = fecha_siguiente
                     AND sproduc = reg.sproduc
                     AND cgarant = 0
                     AND sproces = psproces
                     AND cmodo = pmodo
                     AND ctipo = 0;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     valor := 0;
                     w_cgarant := 0;
               END;

               BEGIN
                  SELECT ifactor
                    INTO valor2
                    FROM ibnr_sam_facdesa
                   WHERE fcalcul_i = w_fecha_inicio
                     AND sproduc = reg.sproduc
                     AND cgarant = 0
                     AND sproces = psproces
                     AND cmodo = pmodo
                     AND ctipo = 0;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     valor2 := 0;
                     w_cgarant := 0;
               END;

               BEGIN
                  SELECT isinret
                    INTO valor3
                    FROM ibnr_sam_siniestros
                   WHERE fcalcul_i = w_fecha_inicio
                     AND fcalcul_j = fecha_siguiente
                     AND sproduc = reg.sproduc
                     AND cgarant = 0
                     AND sproces = psproces
                     AND cmodo = pmodo
                     AND ctipo = 0;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     valor3 := 0;
                     w_cgarant := 0;
               END;

               vtotal := (valor * valor2) - valor3;

               BEGIN
                  --siniestros pagados
                  INSERT INTO ibnr_sam
                              (sproces, fcalcul, fcalcul_i, fcalcul_j, ctipo,
                               ibnr, cmodo, cgarant, sproduc)
                       VALUES (psproces, w_fecha_fin, w_fecha_inicio, fecha_siguiente, 0,
                               NVL(vtotal, 0), pmodo, w_cgarant, reg.sproduc);
               EXCEPTION
                  WHEN OTHERS THEN
                     p_tab_error(f_sysdate, f_user,
                                 'pac_provtec_conf.f_commit_calcul_ibnr sproces=' || psproces,
                                 163,
                                 'error al insertar en ibnr_sam ctipo 0. fcalcul ='
                                 || w_fecha_fin || ' fcalcul_i=' || w_fecha_inicio
                                 || ' fcalcul_j=' || fecha_siguiente || ' pmodo=' || pmodo,
                                 SQLERRM);
                     num_err := 108468;   -- error al insertar en la tabla
               END;
            END LOOP;

            valor_actual := 0;
            valor_actual2 := 0;

            FOR i IN 1 .. meses LOOP
               w_fecha_inicio := ADD_MONTHS(w_fecha_fin, -(meses - i));
               fecha_siguiente := ADD_MONTHS(w_fecha_fin, -(i + 1));

--siniestros reservados
               BEGIN
                  SELECT ispt
                    INTO valor
                    FROM ibnr_sam_sin_pend
                   WHERE fcalcul_i = w_fecha_inicio
                     AND fcalcul_j = fecha_siguiente
                     AND sproduc = reg.sproduc
                     AND cgarant = 0
                     AND sproces = psproces
                     AND cmodo = pmodo
                     AND ctipo = 1;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     valor := 0;
                     w_cgarant := 0;
               END;

               BEGIN
                  SELECT ifactor
                    INTO valor2
                    FROM ibnr_sam_facdesa
                   WHERE fcalcul_i = w_fecha_inicio
                     AND sproduc = reg.sproduc
                     AND cgarant = 0
                     AND sproces = psproces
                     AND cmodo = pmodo
                     AND ctipo = 1;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     valor2 := 0;
                     w_cgarant := 0;
               END;

               BEGIN
                  SELECT isinret
                    INTO valor3
                    FROM ibnr_sam_siniestros
                   WHERE fcalcul_i = w_fecha_inicio
                     AND fcalcul_j = fecha_siguiente
                     AND sproduc = reg.sproduc
                     AND cgarant = 0
                     AND sproces = psproces
                     AND cmodo = pmodo
                     AND ctipo = 1;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     valor3 := 0;
                     w_cgarant := 0;
               END;

               vtotal := (valor * valor2) - valor3;

               BEGIN
                  --siniestros pagados
                  INSERT INTO ibnr_sam
                              (sproces, fcalcul, fcalcul_i, fcalcul_j, ctipo,
                               ibnr, cmodo, cgarant, sproduc)
                       VALUES (psproces, w_fecha_fin, w_fecha_inicio, fecha_siguiente, 1,
                               NVL(vtotal, 0), pmodo, w_cgarant, reg.sproduc);
               EXCEPTION
                  WHEN OTHERS THEN
                     p_tab_error(f_sysdate, f_user,
                                 'pac_provtec_conf.f_commit_calcul_ibnr sproces=' || psproces,
                                 164,
                                 'error al insertar en ibnr_sam ctipo 1. fcalcul ='
                                 || w_fecha_fin || ' fcalcul_i=' || w_fecha_inicio
                                 || ' fcalcul_j=' || fecha_siguiente || ' pmodo=' || pmodo,
                                 SQLERRM);
                     num_err := 108468;   -- error al insertar en la tabla
               END;
            END LOOP;
         END IF;
      -- END LOOP;
      END LOOP;

      COMMIT;
      RETURN(num_err);
   END f_commit_calcul_ibnr;

   -- BUG 27305 - MDS - 20/03/2014
   PROCEDURE p_calculo_diario_iprovres(
      pcempres IN NUMBER,
      pcidioma IN NUMBER,
      pcerror OUT NUMBER,
      psproces OUT NUMBER,
      pfproces OUT DATE) IS
      v_titulo       VARCHAR2(50);
      v_traza        NUMBER;
      num_err        NUMBER := 0;
      conta_err      NUMBER := 0;
      texto          VARCHAR2(400);
      pnnumlin       NUMBER;
      vsproduc       NUMBER := 7004;   -- de momento sólo para CP
      vreserva       NUMBER;

      CURSOR c_garantias IS
         SELECT   s.sseguro, s.cactivi, s.sproduc, g.nriesgo, g.cgarant, g.nmovimi, g.finiefe,
                  gf.clave
             FROM seguros s, garanseg g, garanformula gf, movseguro mv
            WHERE s.sseguro = g.sseguro
              AND s.sproduc = gf.sproduc
              AND g.cgarant = gf.cgarant
              AND g.sseguro = mv.sseguro
              AND g.nmovimi = mv.nmovimi
              AND gf.ccampo = 'IPROVRES'
              AND gf.clave <> 1
              AND mv.femisio IS NOT NULL   -- el movimiento ha de estar emitido
              AND mv.cmovseg NOT IN(52, 3)   -- que no sea Anulación movimiento, Anulación póliza
              AND s.sproduc = vsproduc
              --
              --AND s.sseguro = NVL(psseguro, s.sseguro)
              --AND ROWNUM<500
              --
              AND(((NVL(f_parproductos_v(s.sproduc, 'ADMITE_CERTIFICADOS'), 0) = 1)
                   AND(s.ncertif <> 0))
                  OR((NVL(f_parproductos_v(s.sproduc, 'ADMITE_CERTIFICADOS'), 0) = 0)
                     AND(s.ncertif = 0)))
              AND NOT EXISTS(SELECT 1
                               FROM provmat_nmovimi_conf pv
                              WHERE pv.sseguro = g.sseguro
                                AND pv.nriesgo = g.nriesgo
                                AND pv.cgarant = g.cgarant
                                AND pv.nmovimi = g.nmovimi)
              AND(g.finiefe < f_sysdate)
         ORDER BY g.sseguro, g.nriesgo, g.cgarant, g.nmovimi, g.finiefe;
   BEGIN
      v_traza := 10;
      v_titulo := 'Proceso Cálculo Diario Provisiones';
      num_err := f_procesini(f_user, pcempres, 'CALCULO IPROVRES', v_titulo, psproces);
      COMMIT;

      IF num_err <> 0 THEN
         v_traza := 20;
         pcerror := 1;
         conta_err := conta_err + 1;
         texto := f_axis_literales(num_err, pcidioma);
         pnnumlin := NULL;
         num_err := f_proceslin(psproces, SUBSTR('CALCULO DIARIO IPROVRES' || texto, 1, 120),
                                0, pnnumlin);
         COMMIT;
      ELSE
         v_traza := 30;

         FOR reg IN c_garantias LOOP
            v_traza := 40;
            num_err := pac_calculo_formulas.calc_formul(reg.finiefe, reg.sproduc, reg.cactivi,
                                                        reg.cgarant, reg.nriesgo, reg.sseguro,
                                                        reg.clave, vreserva, reg.nmovimi,
                                                        NULL, 2, NULL, 'R');

            IF num_err <> 0 THEN
               v_traza := 50;
               pcerror := 1;
               conta_err := conta_err + 1;
               texto := f_axis_literales(num_err, pcidioma);
               pnnumlin := NULL;
               num_err := f_proceslin(psproces,
                                      SUBSTR('CALCULO DIARIO IPROVRES : ' || texto
                                             || 'sseguro=' || reg.sseguro || ' cgarant='
                                             || reg.cgarant || ' nmovimi=' || reg.nmovimi,
                                             1, 120),
                                      0, pnnumlin);
            ELSE
               v_traza := 60;

--            BMS_OUTPUT.put_line('reg.sseguro --> ' || reg.sseguro);
--            BMS_OUTPUT.put_line('reg.nriesgo --> ' || reg.nriesgo);
--            BMS_OUTPUT.put_line('reg.cgarant --> ' || reg.cgarant);
--            BMS_OUTPUT.put_line('reg.nmovimi --> ' || reg.nmovimi);
--            BMS_OUTPUT.put_line('reg.finiefe --> ' || reg.finiefe);
               INSERT INTO provmat_nmovimi_conf
                           (sseguro, nriesgo, cgarant, nmovimi, finiefe,
                            sproces, iprovres)
                    VALUES (reg.sseguro, reg.nriesgo, reg.cgarant, reg.nmovimi, reg.finiefe,
                            psproces, vreserva);
            END IF;

            v_traza := 70;
            COMMIT;
         END LOOP;
      END IF;

      v_traza := 80;
      num_err := f_procesfin(psproces, conta_err);
      pfproces := f_sysdate;
      COMMIT;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'CIERRE DIARIO IPROVRES=' || psproces, v_traza,
                     'when others del cierre', SQLERRM);
         pcerror := 1;
   END p_calculo_diario_iprovres;

   -- BUG 27305 - MDS - 21/03/2014
   PROCEDURE p_calculo_cierre_iprovres(
      pcempres IN NUMBER,
      pcidioma IN NUMBER,
      pfecha IN DATE,
      pcerror OUT NUMBER,
      psproces OUT NUMBER,
      pfproces OUT DATE) IS
      v_titulo       VARCHAR2(50);
      v_traza        NUMBER;
      num_err        NUMBER := 0;
      conta_err      NUMBER := 0;
      texto          VARCHAR2(400);
      pnnumlin       NUMBER;
      vsproduc       NUMBER := 7004;   -- de momento sólo para CP
      vinflreserva   NUMBER;
      vsmlvreserva   NUMBER;
      vipcreserva    NUMBER;
      vanyo          NUMBER;
      vmes           NUMBER;
      vinflcount     NUMBER;
      vsmlvcount     NUMBER;
      vipccount      NUMBER;
      vreserva       NUMBER;

      CURSOR c_garantias IS
         SELECT   s.sseguro, s.cactivi, s.sproduc, g.nriesgo, g.cgarant, mv.femisio,
                  mv.nmovimi, g.finiefe, gf.clave
             FROM seguros s, garanseg g, garanformula gf, movseguro mv
            WHERE s.sseguro = g.sseguro
              AND s.sproduc = gf.sproduc
              AND g.cgarant = gf.cgarant
              AND g.sseguro = mv.sseguro
              AND g.nmovimi = mv.nmovimi
              AND gf.ccampo = 'IPROVRES'
              AND gf.clave <> 1
              --            AND mv.femisio IS NOT NULL   -- el movimiento ha de estar emitido
              --            AND mv.cmovseg NOT IN(52, 3)   -- que no sea Anulación movimiento, Anulación póliza
              AND s.sproduc = vsproduc
              --
              --AND s.sseguro = NVL(psseguro, s.sseguro)
              --AND ROWNUM<500
              --
              AND(((NVL(f_parproductos_v(s.sproduc, 'ADMITE_CERTIFICADOS'), 0) = 1)
                   AND(s.ncertif <> 0))
                  OR((NVL(f_parproductos_v(s.sproduc, 'ADMITE_CERTIFICADOS'), 0) = 0)
                     AND(s.ncertif = 0)))
              AND(
                  -- pólizas que no tengan registro de provisión para el mes de cierre
                  NOT EXISTS(SELECT 1
                               FROM provmat_cierre_conf pv
                              WHERE pv.sseguro = g.sseguro
                                AND pv.nriesgo = g.nriesgo
                                AND pv.cgarant = g.cgarant
                                AND pv.fcalcul = pfecha)
                  -- pólizas que sí tengan registro de provisión para el mes de cierre,
                  -- y con un movimiento posterior
                  OR(EXISTS(SELECT 1
                              FROM provmat_cierre_conf pv
                             WHERE pv.sseguro = g.sseguro
                               AND pv.nriesgo = g.nriesgo
                               AND pv.cgarant = g.cgarant
                               AND pv.fcalcul = pfecha)
                     AND(EXISTS(SELECT 1
                                  FROM provmat_cierre_conf pv, movseguro m
                                 WHERE pv.sseguro = g.sseguro
                                   AND pv.nriesgo = g.nriesgo
                                   AND pv.cgarant = g.cgarant
                                   AND pv.fcalcul = pfecha
                                   AND pv.sseguro = m.sseguro
                                   AND pv.femisio < m.femisio
                                   AND m.femisio <= pfecha))))
              AND mv.nmovimi = (SELECT MAX(nmovimi)
                                  FROM movseguro
                                 WHERE sseguro = g.sseguro
                                   AND femisio <= pfecha
                                   AND fefecto <= pfecha)
         ORDER BY g.sseguro, g.nriesgo, g.cgarant;
   BEGIN
      v_traza := 10;
      v_titulo := 'Proceso Cálculo Cierre Provisiones';
      num_err := f_procesini(f_user, pcempres, 'CIERRE IPROVRES', v_titulo, psproces);
      COMMIT;

      IF num_err <> 0 THEN
         v_traza := 20;
         pcerror := 1;
         conta_err := conta_err + 1;
         texto := f_axis_literales(num_err, pcidioma);
         pnnumlin := NULL;
         num_err := f_proceslin(psproces, SUBSTR('CALCULO CIERRE IPROVRES ' || texto, 1, 120),
                                0, pnnumlin);
         COMMIT;
      ELSE
         v_traza := 30;
         -- comprobar previamente si está informada la Inflación, crecimiento por SMMLV, crecimiento por IPC del mes en curso
         -- de momento para CP reservas
         --    sproduc = 7004
         --    Inflación
         --    Crec. por SMMLV
         --    Crec. por IPC
         vinflreserva := NVL(pac_subtablas.f_vsubtabla(-1, 34011, 3, 3, vsproduc), 0);
         vsmlvreserva := NVL(pac_subtablas.f_vsubtabla(-1, 34011, 3, 2, vsproduc), 0);
         vipcreserva := NVL(pac_subtablas.f_vsubtabla(-1, 34011, 3, 1, vsproduc), 0);
         vanyo := TO_NUMBER(TO_CHAR(pfecha, 'YYYY'));
         vmes := TO_NUMBER(TO_CHAR(pfecha, 'MM'));

         -- Inflación es mensual
         SELECT COUNT(1)
           INTO vinflcount
           FROM ipc
          WHERE ctipo = vinflreserva
            AND nanyo = vanyo
            AND nmes = vmes;

         IF vinflcount = 0 THEN
            pnnumlin := NULL;
            num_err :=
               f_proceslin
                    (psproces,
                     SUBSTR('CALCULO CIERRE IPROVRES : No existe Inflación para Reserva'
                            || ' pfecha=' || pfecha,
                            1, 120),
                     0, pnnumlin);
         END IF;

         -- crecimiento por SMMLV es anual
         SELECT COUNT(1)
           INTO vsmlvcount
           FROM ipc
          WHERE ctipo = vsmlvreserva
            AND nanyo = vanyo
            AND nmes = 0;

         IF vsmlvcount = 0 THEN
            pnnumlin := NULL;
            num_err :=
               f_proceslin
                  (psproces,
                   SUBSTR
                      ('CALCULO CIERRE IPROVRES : No existe Crecimiento por SMMLV para Reserva'
                       || ' pfecha=' || pfecha,
                       1, 120),
                   0, pnnumlin);
         END IF;

         -- crecimiento por IPC es mensual
         SELECT COUNT(1)
           INTO vipccount
           FROM ipc
          WHERE ctipo = vipcreserva
            AND nanyo = vanyo
            AND nmes = vmes;

         IF vipccount = 0 THEN
            pnnumlin := NULL;
            num_err :=
               f_proceslin
                  (psproces,
                   SUBSTR
                      ('CALCULO CIERRE IPROVRES : No existe Crecimiento por IPC para Reserva'
                       || ' pfecha=' || pfecha,
                       1, 120),
                   0, pnnumlin);
         END IF;

         IF (vinflcount > 0)
            AND(vsmlvcount > 0)
            AND(vipccount > 0) THEN
            FOR reg IN c_garantias LOOP
               v_traza := 40;
               num_err := pac_calculo_formulas.calc_formul(pfecha, reg.sproduc, reg.cactivi,
                                                           reg.cgarant, reg.nriesgo,
                                                           reg.sseguro, reg.clave, vreserva,
                                                           reg.nmovimi, NULL, 2, NULL, 'R');

               IF num_err <> 0 THEN
                  v_traza := 50;
                  pcerror := 1;
                  conta_err := conta_err + 1;
                  texto := f_axis_literales(num_err, pcidioma);
                  pnnumlin := NULL;
                  num_err := f_proceslin(psproces,
                                         SUBSTR('CALCULO CIERRE IPROVRES : ' || texto
                                                || ' sseguro=' || reg.sseguro || ' cgarant='
                                                || reg.cgarant || ' nmovimi=' || reg.nmovimi,
                                                1, 120),
                                         0, pnnumlin);
               ELSE
                  v_traza := 60;

                  DELETE      provmat_cierre_conf
                        WHERE sseguro = reg.sseguro
                          AND nriesgo = reg.nriesgo
                          AND cgarant = reg.cgarant
                          AND fcalcul = pfecha;

                  INSERT INTO provmat_cierre_conf
                              (sseguro, nriesgo, cgarant, fcalcul, femisio,
                               nmovimi, sproces, iprovres)
                       VALUES (reg.sseguro, reg.nriesgo, reg.cgarant, pfecha, reg.femisio,
                               reg.nmovimi, psproces, vreserva);
               END IF;

               v_traza := 70;
               COMMIT;
            END LOOP;
         END IF;
      END IF;

      v_traza := 80;
      num_err := f_procesfin(psproces, conta_err);
      pfproces := f_sysdate;
      COMMIT;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'CIERRE DIARIO IPROVRES=' || psproces, v_traza,
                     'when others del cierre', SQLERRM);
         pcerror := 1;
   END p_calculo_cierre_iprovres;


 FUNCTION f_commit_calcul_tasabomberil(
      pcempres IN NUMBER,
      aux_factual IN DATE,
      psproces IN NUMBER,
      pcidioma IN NUMBER,
      pcmoneda IN NUMBER,
      pmodo IN VARCHAR2 DEFAULT 'R',
	  pfcierre IN DATE)
      RETURN NUMBER IS
      -- {  declaració de variables necessaries pel proces}
      -- control de error
      conta_err      NUMBER := 0;
      num_err        NUMBER := 0;
      -- Fechas
      wnlinea        NUMBER;   -- linea del procesoslin
      -- Variables de tipo texto
      wtexto         literales.tlitera%TYPE;
      wtasabom number;
   BEGIN
      -- wfrr := NVL(pac_parametros.f_parempresa_n(pcempres, 'FACT_RES'), 1);----bug 25615 --etm-- 17/09/2013
      FOR reg IN c_garantias_tasa_bomberil(aux_factual, pcempres) LOOP


                     wtasabom := NVL(PAC_PARAMETROS.F_PARPRODUCTO_N(reg.sproduc, 'TASA_BOMBERIL'),0);
                     IF wtasabom <> 0 THEN
                     IF pmodo = 'P' THEN
                        BEGIN
                           INSERT INTO TASA_BOMBERIL_PREVIO
                                       (SSEGURO, NRECIBO, CGARANT, SPROCES, IPRIMA, ITASABOMBERIL,
                                        FCIERRE, FCALCUL, CUSUARIO, IPRIMA_MONCON,
                                        ITASABOMBEROL_MONCON, FCAMBIO
                                       )
                                VALUES (  reg.sseguro, reg.nrecibo, reg.cgarant,psproces, reg.iprianu, (reg.iprianu * (wtasabom/100)),
                                        pfcierre, aux_factual, F_USER,
                                        reg.iprianu_monpol,
										(reg.iprianu_monpol * (wtasabom/100)),
                                        reg.fcambio
                                       );
                        EXCEPTION
                           WHEN OTHERS THEN
                              num_err := 108468;
                        -- error al insertar en la tabla
                        END;
                     ELSIF pmodo = 'R' THEN
                        BEGIN
                           INSERT INTO TASA_BOMBERIL
                                       (SSEGURO,NRECIBO, CGARANT, SPROCES, IPRIMA, ITASABOMBERIL,
                                        FCIERRE, FCALCUL, CUSUARIO, IPRIMA_MONCON,
                                        ITASABOMBEROL_MONCON, FCAMBIO
                                       )
                                VALUES ( reg.sseguro, reg.nrecibo, reg.cgarant,psproces, reg.iprianu, (reg.iprianu * (wtasabom/100)),
                                        pfcierre, aux_factual, F_USER,
                                        reg.iprianu_monpol,
										(reg.iprianu_monpol * (wtasabom/100)),
                                        reg.fcambio
                                       );
                        EXCEPTION
                           WHEN OTHERS THEN
                              num_err := 108468;
                        -- error al insertar en la tabla
                        END;
                     ELSE
                        RETURN 9000505;   -- Error de parametres
                     END IF;
                  END IF;
                  IF num_err <> 0 THEN
                     wtexto := f_axis_literales(num_err, pcidioma);
                     num_err := f_proceslin(psproces, wtexto || ' -UPR', reg.sseguro, wnlinea);
                     wnlinea := NULL;
                     conta_err := conta_err + 1;
                  END IF;

                  num_err := 0;

      END LOOP;

      COMMIT;
      RETURN(conta_err);
   END f_commit_calcul_tasabomberil;

END pac_provtec_conf;

/

  GRANT EXECUTE ON "AXIS"."PAC_PROVTEC_CONF" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_PROVTEC_CONF" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_PROVTEC_CONF" TO "PROGRAMADORESCSI";
