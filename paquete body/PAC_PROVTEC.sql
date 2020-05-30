--------------------------------------------------------
--  DDL for Package Body PAC_PROVTEC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_PROVTEC" IS
/****************************************************************************
   NOMBRE:       pac_provtec
   PROPÓSITO:    Agrupa las funciones que calculan las provisiones técnicas

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ----------------------------------
   1.0           -          -               Creació del package
   2.0        20/04/2009   FAL              Omitir llamada a F_PORCENREASEGRAMO (bug 9737)
   2.0        22/04/2009   FAL              Incluir los siniestros reaperturados (bug 9200)
   3.0        27/04/2009   APD                2. Bug 9685 - primero se ha de buscar para la actividad en concreto
                                                 y si no se encuentra nada ir a buscar a GARANFORMULA para la actividad cero
   3.1        27/04/2009   APD                3. Bug 9685 - en lugar de coger la actividad de la tabla seguros, llamar a la
                                                 función pac_seguros.ff_get_actividad
   3.2        16/06/2009   DCT              Bug 10328 - CRE - Incidencia cierre contable mayo09 - Provisión por prestaciones
                                            en productos de baja.
   4          30/06/2009   ETM                4.  0010462: IAX - REA - Eliminar tabla FACPENDIENTES
   5.0        19/10/2009   FAL                5.  0011497: CRE - Optimizar el cierre de provisiones
   6.0        06/11/2009   APD                6. Bug 11595: CEM - Siniestros. Adaptación al nuevo módulo de siniestros
   7.0        13/01/2010   JGR              BUG 12539 - 13/01/2010 - JGR - Errores en el cierre de provisiones de Diciembre (AXIS1501)
   8.0        15/02/2010   ASN              BUG 13621: CEM997 Controlar que no se generen las PPNC si se calculan las provisiones matemáticas
   8.1        02/06/2010   ASN              BUG:14200: CEM800 - Provisiones por prestaciones
   9.0        22/10/2010   AVT              BUG:16263: AGA003 - Error de definición de los contratos de reaseguro de los productos de hogar y comunidades.
  10.0        14/04/2011   JGR              BUG:18241: CEM_565 - 0018241: CEM - Depuració reassegurança AXIS
  11.0        19/12/2011   APD              0020384: LCOL_C001: Ajuste de comisiones para los cierres
  12.0        08/05/2012   APD              0021715: MDP_F001-Provisiones: modificacion de los procesos genericos
  13.0        06/08/2012   AVT              0022799: AGM800-Cuenta tecnica del reaseguro
  14.0        26/09/2012   AVT              0023771: AGM800-Modificaciones en la Cta. Tecnica
  15.0        08/05/2012   XVM              0024597: CRE800-Comptabilitat octubre 2012
  16.0        02/04/2013   DCG              0026211: CALI003-Errores en la Contabilidad y en las Provisiones
  17.0        22/04/2013   JMF              0026214: RSA003 - Parametrizar PPNC
  18.0        06/05/2013   DCG              0026890: RSA003-Crear provisi?n de incobrables
  19.0        02/12/2013   DCG              0026214: RSA003 - Parametrizar PPNC
  20.0        19/02/2014   DCG              0030219: CALI706-Informe PPNC cedida
  21.0        22/04/2015   KJSC             0035670/ 202759: Nueva funcion F_Commit_calcul_pplpgar
  22.0        07/05/2015   KJSC             0035672/202775 : Cálculo de coeficiente para distribución de siniestralidad
  23.0        14/07/2015   NMM              36816: Desquadratura de Asiento 6A.f_round's f_commit_calcul_pplp
****************************************************************************/

   /*****************************************************************************************/
/*    Esta package agrupa las funciones que calculan las provisiones técnicas y por lo   */
/*   tanto sustituye a los packages:                                                     */
/*            pac_provi (PPNC) - pac_ldg                                                 */
/*            pac_provipestab                                                            */
/*            pac_proviibnr                                                              */
/*            pac_provipplp                                                              */
/*                                                                                       */
/*                                                  */
/*       -- sE AÑADE EL PARÁMETRO PMODO PARA PODER HACER PREVIOS DE PROVISIONES */
/*****************************************************************************************/
-- cursores para el cálculo de las ppnc - ldg
   CURSOR c_polizas_ppnc(fecha DATE, empresa NUMBER) IS
      -- Bug 9685 - APD - 30/04/2009 - en lugar de coger la actividad de la tabla seguros, llamar a la función pac_seguros.ff_get_actividad
      -- Bug 0026214 - 22/04/2013 - JMF: anadir moneda
      SELECT c.cempres, s.cramo, s.cmodali, s.cduraci, s.nduraci, s.ctipseg, s.ccolect,
             s.sseguro, pac_seguros.ff_get_actividad(s.sseguro, r.nriesgo) cactivi, s.fvencim,
             s.fcaranu, s.fefecto, r.nriesgo, s.cagente, s.npoliza, s.ncertif,
             NVL(p.cramdgs, 0) cramdgs, NVL(c.pgasadm, 0) pgasadm, NVL(c.plimadm, 0) plimadm,
             NVL(c.pgasadq, 0) pgasadq, NVL(c.plimadq, 0) plimadq,
             DECODE(NVL(p.creaseg, 1), 0, 3, DECODE(NVL(s.ctiprea, 1), 2, 2, 0)) csegrea,
             p.sproduc, s.cforpag, d.cmoneda cmoneda,
             pac_monedas.f_cmoneda_t(d.cmoneda) cmoneda_t
        FROM productos p, seguros s, codidivisa d,
                                                  --MOVSEGURO m,  -- això ho comentem perquè es mira a f_vigente
                                                  riesgos r, codiram c
       WHERE d.cdivisa(+) = p.cdivisa
         AND(s.fvencim > fecha
             OR s.fvencim IS NULL)
          -- això ho comentem perquè es mira a f_vigente
          /*
            AND m.sseguro (+) = s.sseguro
            AND m.cmovseg (+) = 3        -- moviment d'anulació
            AND ( trunc ( m.fmovimi ) > fecha OR m.fmovimi IS NULL ) -- afegit trunc per seleccionar ok
         */
         AND pac_anulacion.f_anulada_al_emitir(s.sseguro) = 0
         -- afegim que es mira a f_vigente
-- BUG 11497 - 19/10/2009 - FAL - 11497: CRE - Optimizar el cierre de provisiones
--         AND 0 = f_vigente(s.sseguro, NULL, fecha)
         AND 1 = f_situacion_v(s.sseguro, fecha)
-- Fi BUG 11497 - 19/10/2009 - FAL
         AND (SELECT GREATEST(m2.fefecto, m2.femisio)
                FROM movseguro m2
               WHERE m2.sseguro = s.sseguro
                 AND m2.cmovseg = 0   --Alta
                                   ) < fecha + 1   --s.fefecto <= fecha
         AND s.csituac <> 4
         AND s.cramo = c.cramo
         AND c.cempres = empresa
         AND p.cramo = s.cramo
         AND p.cmodali = s.cmodali
         AND p.ctipseg = s.ctipseg
         AND p.ccolect = s.ccolect
         AND r.sseguro = s.sseguro
         -- BUG 12539 - 13/01/2010 - JGR - Errores en el cierre de provisiones de Diciembre (AXIS1501)
         AND EXISTS(SELECT 1
                      FROM garanseg g
                     WHERE g.sseguro = r.sseguro
                       AND g.nriesgo = r.nriesgo
                       AND g.iprianu != 0)
         -- Fi BUG 12539 - 13/01/2010 - JGR
         AND r.fefecto <= fecha;

-- BUG 11497 - 19/10/2009 - FAL - 11497: CRE - Optimizar el cierre de provisiones
--         AND(r.fanulac > fecha OR r.fanulac IS NULL);
-- Fi BUG 11497 - 19/10/2009 - FAL

   -- Bug 9685 - APD - 30/04/2009 - Fin
   CURSOR c_garantias_ppnc(
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
                  AND
                      --AND g.ffinefe IS NULL
                     (SELECT MAX(m.nmovimi)
                        FROM movseguro m,
                             garanseg ga   --DCG incluimos el garanseg para que seleccione correctamente el movimiento
                       WHERE m.sseguro = g.sseguro
                         AND m.sseguro =
                               ga.sseguro   --DCG incluimos el garanseg para que seleccione correctamente el movimiento
                         AND m.nmovimi =
                               ga.nmovimi   --DCG incluimos el garanseg para que seleccione correctamente el movimiento
                         AND TRUNC(m.fmovimi) <= fecha) = g.nmovimi)
               OR(s.csituac = 5
                  AND g.ffinefe IS NOT NULL
                  AND g.ffinefe <= fecha
                  AND g.nmovimi =
                        (SELECT MAX(nmovimi)
                                - 1   -- Número de moviment anterior al moviment de suplement que té retinguda la pòlissa
                           FROM movseguro
                          WHERE cmovseg = 1   -- Moviment de suplement
                            AND femisio IS NULL   -- Moviment encara no emés => És una proposta de suplement
                            AND sseguro = g.sseguro)))
           AND gg.cgarant = g.cgarant
           AND gg.cramo = wcramo
           AND gg.cmodali = wcmodali
           AND gg.ctipseg = wctipseg
           AND gg.ccolect = wccolect
           AND g.nriesgo = wnriesgo
           AND gg.cactivi = 0
           AND(NVL(gg.cprovis, 1) =
                  1   -- bug13621 ASN - CEM997 - Controlar que no se generen las PPNC si se calculan las provisiones matemáticas
               OR gg.creaseg IN(1, 4))   -- O se calcula PPNC o tiene reaseguro -- CPM 26/7/06: S'incorpora el tipus 4 (Reaseg. anual de P.U.)
           AND g.iprianu != 0
           AND r.sseguro = g.sseguro
           AND r.fefecto <= fecha
           AND(r.fanulac > fecha
               OR r.fanulac IS NULL)
           AND(g.nriesgo = r.nriesgo
               OR g.nriesgo IS NULL)
           AND fechafin > fecha
      ORDER BY g.cgarant;

-- cursores para el cálculo de las pestab
   -- Bug 21715 - APD - 08/05/2012 - se renombra el cursor pues NO se utilizará para
   -- el cálculo de la provision de estabilizacion
   --CURSOR c_polizas_pestab(fecha DATE, empresa NUMBER) IS
   CURSOR c_polizas_pestab_old(fecha DATE, empresa NUMBER) IS
   -- fin Bug 21715 - APD - 08/05/2012
--SELECT cempres, sseguro, cagente, cagrpro, cramo, cmodali, ctipseg,
--       ccolect, cactivi, npoliza, ncertif, nriesgo, cgarant, nmovimi,
--       SUM (primas) primas
      SELECT   cempres, sseguro, nriesgo, cgarant, nmovimi, cramo, cmodali, ctipseg, ccolect,
               cactivi, npoliza, ncertif, SUM(primas) primas
          FROM (SELECT cempres, sseguro, cagente, cagrpro, cramo, cmodali, ctipseg, ccolect,
                       cactivi, npoliza, ncertif, nriesgo, cgarant, nmovimi,
                       inovpro
                       -(ianureb_npac + ianupol_npac + ianureb_npan + ianupol_npan)
                       + isuplem + icartera
                       -(ianureb_carac + ianupol_carac + ianureb_caran + ianupol_caran)
                       + iaportex - iextorn primas
                  FROM hisventas
                 WHERE cempres = empresa
                   AND nmesven BETWEEN 1 AND TO_NUMBER(TO_CHAR(fecha, 'MM'))
                   AND nanyven = TO_CHAR(fecha, 'YYYY')
                UNION
                SELECT cempres, sseguro, cagente, cagrpro, cramo, cmodali, ctipseg, ccolect,
                       cactivi, npoliza, ncertif, nriesgo, cgarant, nmovimi,
                       inovpro
                       -(ianureb_npac + ianupol_npac + ianureb_npan + ianupol_npan)
                       + isuplem + icartera
                       -(ianureb_carac + ianupol_carac + ianureb_caran + ianupol_caran)
                       + iaportex - iextorn primas
                  FROM ventas
                 WHERE cempres = empresa
                   AND nmesven BETWEEN 1 AND TO_NUMBER(TO_CHAR(fecha, 'MM'))
                   AND nanyven = TO_CHAR(fecha, 'YYYY'))
      GROUP BY cempres, sseguro, nriesgo, cgarant, nmovimi, cramo, cmodali, ctipseg, ccolect,
               cactivi, npoliza, ncertif;

--GROUP BY cempres, sseguro, cagente, cagrpro, cramo, cmodali, ctipseg,
       --ccolect, cactivi, npoliza, ncertif, nriesgo, cgarant, nmovimi;

   -- Bug 9685 - APD - 30/04/2009 - en lugar de coger la actividad de la tabla seguros, llamar a la función pac_seguros.ff_get_actividad
   -- NO se modifica este cursor pues no se utiliza (está obsoleto)
   -- Bug 9685 - APD - 30/04/2009 - Fin
   -- Bug 21715 - APD - 08/05/2012 - se renombra el cursor pues se utilizará para
   -- el cálculo de la provision de estabilizacion
   --CURSOR c_polizas_pestab_old(fecha DATE, empresa NUMBER) IS
   -- fin Bug 21715 - APD - 08/05/2012
   CURSOR c_polizas_pestab(fecha DATE, empresa NUMBER) IS
      SELECT c.cempres, s.cramo, s.cmodali, s.ctipseg, s.ccolect, s.sseguro, s.cactivi,
             s.fvencim, s.fcaranu, s.fefecto, s.npoliza, s.ncertif, NVL(p.cramdgs, 0) cramdgs,
             s.cduraci, s.nduraci
        FROM productos p, seguros s, codiram c
       WHERE ((s.fvencim > fecha
               AND TO_CHAR(s.fvencim, 'yyyy') <> TO_CHAR(fecha, 'yyyy'))
              OR s.fvencim IS NULL)
         AND(s.fanulac > fecha
             OR s.fanulac IS NULL)
         AND s.fefecto <= fecha
         AND s.csituac <> 4
         AND s.cramo = c.cramo
         AND c.cempres = empresa
         AND p.cramo = s.cramo
         AND p.cmodali = s.cmodali
         AND p.ctipseg = s.ctipseg
         AND p.ccolect = s.ccolect
         AND EXISTS(SELECT cgarant
                      FROM garanpro gp
                     WHERE gp.cramo = s.cramo
                       AND gp.cmodali = gp.cmodali
                       AND gp.ctipseg = gp.ctipseg
                       AND gp.ccolect = gp.ccolect
                       --AND gp.cactivi = 0
                       AND gp.cactivi = pac_seguros.ff_get_actividad(s.sseguro, 1)
                       AND gp.precseg IS NOT NULL);

   -- Bug 9685 - APD - 30/04/2009 - en lugar de coger la actividad de la tabla seguros, llamar a la función pac_seguros.ff_get_actividad
   -- NO se modifica este cursor pues no se utiliza (está obsoleto)
   -- Bug 9685 - APD - 30/04/2009 - Fin
   -- Bug 21715 - APD - 08/05/2012 - se renombra el cursor pues se utilizará para
   -- el cálculo de la provision de estabilizacion
   --CURSOR c_garantias_pestab_old(
   -- fin Bug 21715 - APD - 08/05/2012
   CURSOR c_garantias_pestab(
      fecha DATE,
      wffinal DATE,
      wcramo NUMBER,
      wcmodali NUMBER,
      wctipseg NUMBER,
      wccolect NUMBER,
      wseguro NUMBER) IS
      SELECT g.cgarant, g.nriesgo, NVL(g.iprianu, 0) * NVL(nasegur, 1) iprianu,
             NVL(gg.precseg, 0) precseg, g.finiefe, g.nmovimi
        FROM garanpro gg, garanseg g, riesgos r
       WHERE g.sseguro = wseguro
         AND g.finiefe <= fecha
         AND(g.ffinefe > fecha
             OR g.ffinefe IS NULL)
         AND gg.cgarant = g.cgarant
         AND gg.cramo = wcramo
         AND gg.cmodali = wcmodali
         AND gg.ctipseg = wctipseg
         AND gg.ccolect = wccolect
         --AND gg.cactivi = 0
         AND gg.cactivi = pac_seguros.ff_get_actividad(g.sseguro, r.nriesgo)
--         AND gg.cprovis IS NULL  -- bug 13621 ASN 23/03/2010
         AND NVL(gg.cprovis, 1) = 1
         AND g.iprianu <> 0
         AND gg.precseg IS NOT NULL
         AND r.sseguro = g.sseguro
         AND r.fefecto <= fecha
         AND(r.fanulac > fecha
             OR r.fanulac IS NULL)
         AND(g.nriesgo = r.nriesgo
             OR g.nriesgo IS NULL)
         AND wffinal > fecha;

-- cursores para el cálculo de las ibnr
   CURSOR c_siniestros_ibnr(fecha DATE, empresa NUMBER) IS
      -- BUG 11595 - 03/11/2009 - APD - Adaptación al nuevo módulo de siniestros
      -- se añade la UNION con las tablas nuevas de siniestros
      SELECT c.cempres, s.cramo, s.cmodali, s.ctipseg, s.ccolect, s.sseguro, s.npoliza,
             s.ncertif, NVL(p.cramdgs, 0) cramdgs, TO_CHAR(sn.nsinies) nsinies
        FROM productos p, seguros s, siniestros sn, codiram c
       WHERE sn.fsinies <= fecha
-- BUG 9200 - 22/04/2009 - FAL - Incluir siniestros reaperturados
         -- AND(sn.cestsin = 0
         AND(sn.cestsin IN(0, 4)
-- Fi BUG 9200 - 22/04/2009 - FAL
             OR(sn.cestsin <> 0
                AND sn.festsin > fecha))
         AND s.sseguro = sn.sseguro
         AND s.cramo = c.cramo
         AND c.cempres = empresa
         AND p.cramo = s.cramo
         AND p.cmodali = s.cmodali
         AND p.ctipseg = s.ctipseg
         AND p.ccolect = s.ccolect
         AND NVL(pac_parametros.f_parempresa_n(s.cempres, 'MODULO_SINI'), 0) = 0
      UNION
      SELECT c.cempres, s.cramo, s.cmodali, s.ctipseg, s.ccolect, s.sseguro, s.npoliza,
             s.ncertif, NVL(p.cramdgs, 0) cramdgs, sn.nsinies
        FROM productos p, seguros s, sin_siniestro sn, sin_movsiniestro m, codiram c
       WHERE sn.fsinies <= fecha
-- BUG 9200 - 22/04/2009 - FAL - Incluir siniestros reaperturados
         -- AND(sn.cestsin = 0
         AND(m.cestsin IN(0, 4)
-- Fi BUG 9200 - 22/04/2009 - FAL
               -- OR(m.cestsin <> 0 -- Bug.14200:ASN:21/04/2010
               -- AND m.festsin > fecha)
            )
         AND s.sseguro = sn.sseguro
         AND s.cramo = c.cramo
         AND c.cempres = empresa
         AND p.cramo = s.cramo
         AND p.cmodali = s.cmodali
         AND p.ctipseg = s.ctipseg
         AND p.ccolect = s.ccolect
         AND sn.nsinies = m.nsinies
         AND m.nmovsin = (SELECT MAX(nmovsin)
                            FROM sin_movsiniestro
                           WHERE nsinies = m.nsinies
                             -- Bug.14200:ASN:21/04/2010
                             AND festsin <= fecha)
--                             AND m.festsin <= fecha) -- Bug.14200:ASN:01/06/2010
         AND NVL(pac_parametros.f_parempresa_n(s.cempres, 'MODULO_SINI'), 0) = 1;

 --Bug 0035670/ 202759: KJSC Cursor utilizado para calculo de PTPPLPGAR
-- cursores para el cálculo de las pplp
   CURSOR c_siniestros_pplp(fecha DATE, empresa NUMBER) IS
      -- BUG 11595 - 03/11/2009 - APD - Adaptación al nuevo módulo de siniestros
      -- se añade la UNION con las tablas nuevas de siniestros
      SELECT c.cempres, s.cramo, s.cmodali, s.ctipseg, s.ccolect, s.sseguro, s.npoliza,
             s.ncertif, NVL(p.cramdgs, 0) cramdgs, TO_CHAR(sn.nsinies) nsinies
        FROM productos p, seguros s, siniestros sn, codiram c
       WHERE sn.fsinies <= fecha
-- BUG 9200 - 22/04/2009 - FAL - Incluir siniestros reaperturados
         -- AND(sn.cestsin = 0
         AND(sn.cestsin IN(0, 4)
-- Fi BUG 9200 - 22/04/2009 - FAL
             OR(sn.cestsin <> 0
                AND sn.festsin > fecha))
         AND s.sseguro = sn.sseguro
         AND s.cramo = c.cramo
         AND c.cempres = empresa
         AND p.cramo = s.cramo
         AND p.cmodali = s.cmodali
         AND p.ctipseg = s.ctipseg
         AND p.ccolect = s.ccolect
         AND NVL(pac_parametros.f_parempresa_n(s.cempres, 'MODULO_SINI'), 0) = 0
      UNION
      SELECT c.cempres, s.cramo, s.cmodali, s.ctipseg, s.ccolect, s.sseguro, s.npoliza,
             s.ncertif, NVL(p.cramdgs, 0) cramdgs, sn.nsinies
        FROM productos p, seguros s, sin_siniestro sn, sin_movsiniestro m, codiram c
       WHERE sn.fsinies <= fecha
-- BUG 9200 - 22/04/2009 - FAL - Incluir siniestros reaperturados
         -- AND(sn.cestsin = 0
         AND(m.cestsin IN(0, 4)
-- Fi BUG 9200 - 22/04/2009 - FAL
--             OR(m.cestsin <> 0  -- Bug.14200:ASN:21/04/2010
--                AND m.festsin > fecha)
            )
         AND s.sseguro = sn.sseguro
         AND s.cramo = c.cramo
         AND c.cempres = empresa
         AND p.cramo = s.cramo
         AND p.cmodali = s.cmodali
         AND p.ctipseg = s.ctipseg
         AND p.ccolect = s.ccolect
         AND sn.nsinies = m.nsinies
         AND m.nmovsin = (SELECT MAX(nmovsin)
                            FROM sin_movsiniestro
                           WHERE nsinies = m.nsinies
--                             AND m.festsin <= fecha   -- Bug.14200:ASN:21/04/2010
--                             AND festsin <= fecha   -- Bug.14200:ASN:02/06/2010
                             AND TRUNC(festsin) <= fecha   -- Bug.26214:DCG:02/12/2013
                                                        )
         AND NVL(pac_parametros.f_parempresa_n(s.cempres, 'MODULO_SINI'), 0) = 1;

-----------------------------------------------------------------------
-----------------------------------------------------------------------
-----------------------------------------------------------------------
-- PPNC (y LDG)
-----------------------------------------------------------------------
   FUNCTION f_commit_calcul_ppnc(
      cempres IN NUMBER,
      aux_factual IN DATE,
      psproces IN NUMBER,
      pcidioma IN NUMBER,
      pcmoneda IN NUMBER,
      pmodo IN VARCHAR2 DEFAULT 'R')
      RETURN NUMBER IS
      --
      n_traza        NUMBER := 0;
      --
      ttexto         VARCHAR2(400);
      nlin           NUMBER;
      num_err        NUMBER := 0;
      conta_err      NUMBER := 0;
--    wpnrea        NUMBER;
      aux_fefeini    DATE;
      wprimtotnetrecseg NUMBER;
      wprimnocons    NUMBER;
      wprimresultado NUMBER;
      wprimtotreaced NUMBER;
      wprimresultreaced NUMBER;
      wprimnoconsreaced NUMBER;
      wcomtotreaced  NUMBER;
      wcomnocons     NUMBER;
      wcomresultado  NUMBER;
      wcomisiones    NUMBER;
      wotrgastadq    NUMBER;
      wgastadq       NUMBER;
      wimplimgastadq NUMBER;
      wgastadqnocons NUMBER;
      wgastadqresult NUMBER;
      wotrgastadm    NUMBER;
      wimplimgastadm NUMBER;
      wgastadmnocons NUMBER;
      wgastadmresult NUMBER;
      wprimtotnetrecseg_gar NUMBER;
      wprimnocons_gar NUMBER;
      wprimresultado_gar NUMBER;
      wprimtotreaced_gar NUMBER;
      wprimresultreaced_gar NUMBER;
      wprimnoconsreaced_gar NUMBER;
      wcomtotreaced_gar NUMBER;
      wcomnocons_gar NUMBER;
      wcomresultado_gar NUMBER;
      wcomisiones_gar NUMBER;
      wcomisi_ncs_gar NUMBER;
      wotrgastadq_gar NUMBER;
      wgastadq_gar   NUMBER;
      wimplimgastadq_gar NUMBER;
      wgastadqnocons_gar NUMBER;
      wgastadqresult_gar NUMBER;
      wotrgastadm_gar NUMBER;
      wimplimgastadm_gar NUMBER;
      wgastadmnocons_gar NUMBER;
      wgastadmresult_gar NUMBER;
      wcomtotreaced_seg NUMBER;
      wcomnocons_seg NUMBER;
      wcomresultado_seg NUMBER;
      wprimacomisionseguro NUMBER;
      wprimtotreaced_gar_moncon NUMBER;   -- Bug 0026890 - 06/05/2013 - DCG -inici
      wcomtotreaced_gar_moncon NUMBER;
      wprimnoconsreaced_gar_moncon NUMBER;
      wcomnocons_gar_moncon NUMBER;
      wprimtotnetrecseg_gar_moncon NUMBER;
      wcomisi_ncs_gar_moncon NUMBER;
      wprimnocons_gar_moncon NUMBER;
      wcomisiones_gar_moncon NUMBER;   -- Bug 0026890 - 06/05/2013 - DCG -fi
      wsuma          NUMBER;
      wsegrea        NUMBER;
      wgarrea        NUMBER;
--    werror        NUMBER;
      wcmodcom       NUMBER;
      wpcomage       NUMBER;
      wpretenc       NUMBER;
      wseguro1       NUMBER;
      ffinal         DATE;
--    wtotreaseg        NUMBER;
      wprorrata      NUMBER;
      ffinal_rea     DATE;
      fini_rea       DATE;
      wreasingarant  NUMBER;
      bfraccionario  NUMBER(1) := NULL;
      pmes           VARCHAR2(2);   -- 22799 AVT 06/08/2012
      pany           VARCHAR2(4);   -- 22799 AVT 06/08/2012
      -- Bug 0026214 - 22/04/2013 - JMF
      w_cmoncon      parempresas.nvalpar%TYPE
                                     := pac_parametros.f_parempresa_n(cempres, 'MONEDACONTAB');
      -- Moneda de contablidad (numérico)
      w_cmoncon_t    monedas.cmonint%TYPE := pac_monedas.f_cmoneda_t(w_cmoncon);
      -- Moneda de contablidad (texto)
      pfcambio       DATE;   -- Fecha del cambio vigente a la fecha actual
      witasa         NUMBER(15, 2);   -- Tasa vigente
      v_multimoneda  NUMBER(1) := 0;
      -- Bug 0026214 - 22/04/2013 - JMF
      v_tiene_ppnc_rea NUMBER(3);   -- Bug 29775 - 01/04/2014 - JMF
      --Bug 35672/202775 KJSC cálculo de coeficiente para distribución de siniestralidad
      v_coef         NUMBER;
      v_coefdef      NUMBER;
      n_tipo_dissinppnc NUMBER;
      -- Bug 37018-218755 KJSC NUEVO CALCULO PARA PPNC
      v_diasmes      NUMBER;
      v_ffinal       NUMBER;
      v_ffinal1      NUMBER;
      v_valor        NUMBER;
      v_coef1        NUMBER;
      v_prorr        NUMBER;
      v_tasames      NUMBER;
      v_aux          NUMBER;
      v_frenova      NUMBER;
      v_frenova1     NUMBER;
      v_contador     NUMBER;
      v_frenovad     NUMBER;
      v_diasmes1     NUMBER;
      wicapces       NUMBER;
      wicomisi       NUMBER;
      wicapces_moncon NUMBER;
      wicomisi_moncon NUMBER;
      anobisies      NUMBER;
      wffinal        DATE;
   BEGIN
      n_traza := 100;
      v_multimoneda := NVL(pac_parametros.f_parempresa_n(cempres, 'MULTIMONEDA'), 0);
      n_traza := 110;

      FOR reg IN c_polizas_ppnc(aux_factual, cempres) LOOP
         --- JGM --18/09/2008 --busqueda de si producto fraccionario para luego--
         DECLARE
            vproduc        seguros.sproduc%TYPE;
            num_err        NUMBER;
         BEGIN
            n_traza := 120;

            SELECT sproduc
              INTO vproduc
              FROM seguros
             WHERE sseguro = reg.sseguro;

            n_traza := 120;
            num_err := f_parproductos(vproduc, 'FRACCIONARIO', bfraccionario);

            IF num_err <> 0 THEN
               bfraccionario := NULL;
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               bfraccionario := NULL;
         END;

------------------------------------------------------------------------
         n_traza := 130;
         num_err := f_fechainifin(reg.sseguro, aux_factual, reg.fvencim, reg.fcaranu, ffinal,
                                  aux_fefeini, wprorrata, wcmodcom);

         IF num_err != 0 THEN
            num_err := 104349;
         END IF;

         IF num_err = 0 THEN
            IF (ffinal - aux_fefeini) = 0 THEN
               num_err := 105981;
            ELSE
               -- Bug 20384 - APD - 19/12/2011 - el parametro pfecha de la f_pcomisi
               -- debe ser aux_factual
               n_traza := 140;
               num_err := f_pcomisi(reg.sseguro, wcmodcom, aux_factual, wpcomage, wpretenc,
                                    reg.cagente, reg.cramo, reg.cmodali, reg.ctipseg,
                                    reg.ccolect, reg.cactivi, NULL, NULL, 'HIS', aux_factual);

               -- joan
               IF NVL(num_err, 0) <> 0 THEN
                  p_tab_error(f_sysdate, f_user, 'pac_provtec.f_commit_calcul_ppnc', n_traza,
                              'f_pcomisi num_err=' || num_err,
                              's=' || reg.sseguro || ' m=' || wcmodcom || ' fr='
                              || aux_factual || ' a=' || reg.cagente || ' r=' || reg.cramo
                              || ' m=' || reg.cmodali || ' t=' || reg.ctipseg || ' c='
                              || reg.ccolect || ' a=' || reg.cactivi || ' f=' || 'HIS'
                              || ' f=' || aux_factual);
               END IF;
            -- fin Bug 20384 - APD - 19/12/2011
            END IF;
         END IF;

         IF num_err = 0 THEN
            n_traza := 150;
            wprimtotnetrecseg := 0;
            wprimnocons := 0;
            wprimresultado := 0;
            wprimtotreaced := 0;
            wprimresultreaced := 0;
            wprimnoconsreaced := 0;
            wcomtotreaced := 0;
            wcomnocons := 0;
            wcomresultado := 0;
            wcomisiones := 0;
            wotrgastadq := 0;
            wgastadq := 0;
            wimplimgastadq := 0;
            wgastadqnocons := 0;
            wgastadqresult := 0;
            wotrgastadm := 0;
            wimplimgastadm := 0;
            wgastadmnocons := 0;
            wgastadmresult := 0;
            wreasingarant := 0;
--        werror := 0;
            n_traza := 160;

            FOR gar IN c_garantias_ppnc(reg.sseguro, reg.cramo, reg.cmodali, reg.ctipseg,
                                        reg.ccolect, aux_factual, ffinal, reg.nriesgo) LOOP
               -- CPM 23/9/04: El cálculo de las PPNC se realizará tanto para pólizas que no se
               --  se calcule su provisión matemática (CPROVIS IS NULL) como para las pólizas
               --  que tengan reaseguro. El motivo es que el reaseguro se calcula anualmente
               --  por lo que se puede calculas su prima no consumida del reaseguro anual.
               --  Este problema aparece con las pólizas de prima única, que no tienen cálculo
               --  de primas no consumidas de la parte del seguro directo (porque se cálculan a
               --  través de las provisiones matématicas) pero si que tienen cálculo de primas
               --  no consumidas de la parte del reaseguro
               IF reg.csegrea = 0
                  AND gar.cgarrea = 0 THEN   -- Tenemos Reaseguro
                  witasa := 1;
                  pfcambio := aux_factual;

                  IF v_multimoneda = 1 THEN
                     -- BUG 20070/107545 - 20/02/2012 - JMP - Añadir contravalores en la moneda de la contabilidad
                     IF reg.cmoneda = w_cmoncon THEN
                        witasa := 1;
                        pfcambio := aux_factual;
                     ELSE
                        n_traza := 170;
                        pfcambio := pac_eco_tipocambio.f_fecha_max_cambio(reg.cmoneda_t,
                                                                          w_cmoncon_t,
                                                                          aux_factual);

                        IF pfcambio IS NULL THEN
                           ttexto := f_axis_literales(9902592, pcidioma);
                           num_err := f_proceslin(psproces, ttexto || ' -PPNCREA-' || n_traza,
                                                  reg.sseguro, nlin);
                           nlin := NULL;
                           num_err := 9902592;
                        -- No se ha encontrado el tipo de cambio entre monedas
                        END IF;

                        n_traza := 180;
                        witasa := pac_eco_tipocambio.f_cambio(reg.cmoneda_t, w_cmoncon_t,
                                                              pfcambio);
                     END IF;
                  END IF;

                  BEGIN
                     --Bug 0024597-XVM-13/11/2012.Inicio
                        -- Calculem la cesió anual i no la fraccionada (a nivell de rebut). Per això necessitem
                        -- la taula CESIONESREA, pero el pcomisi, només està a nivell de companyia per lo qual
                        -- ens veiem obligats a calcularlo

                     --12/9/06 CPM: Prorratearemos por fecha dependiendo del intervalo

                     --Bug.: 21715 - 21/03/2012 - ICV - Siempre se lleva a reaseguro sea o no sea fraccionario

                     -- JGM distinta select segun si es o no fraccionario --
                     IF NVL(bfraccionario, 0) <> 1 THEN
                        -- fi JGM --
                        ffinal_rea := ffinal;
                        fini_rea := aux_fefeini;
                     -- JGM -- select si fraccionario -- 18/09/2008
                     ELSE
                        ffinal_rea := NULL;
                        fini_rea := NULL;
                     END IF;

                     n_traza := 190;

                     IF NVL(pac_parametros.f_parempresa_n(cempres, 'PPNC_REASEG_FRACC'), 0) = 0 THEN
                        -- Bug 0026211 - 02/04/2013 - DCG - Ini
                        n_traza := 200;

						-- 16/03/2016 Inicio EEDA Bug- 0038522 Incorporación de f_difdata (módulo 360) en el cálculo de Reaseguro.
                        SELECT SUM(f_round((icesion
                                            *(f_difdata_consulta(NVL(fini_rea,fefecto),NVL(ffinal_rea, fvencim), 3, 3)
                                              / NVL(f_difdata_consulta(fefecto, fvencim, 3, 3),1) )),
                                           pcmoneda)),
                               SUM(f_round((icomisi
                                            *((f_difdata_consulta(NVL(fini_rea,fefecto),NVL(ffinal_rea, fvencim), 3, 3))
                                              /(NVL(f_difdata_consulta(fefecto, fvencim, 3, 3),1)))),
                                           pcmoneda)),
                               SUM(f_round((icesion
                                            *((f_difdata_consulta(aux_factual,NVL(ffinal_rea, fvencim), 3, 3))
                                              /(NVL(f_difdata_consulta(fefecto, fvencim, 3, 3),1)))),
                                           pcmoneda)),
                               SUM(f_round((icomisi
                                            *((f_difdata_consulta(aux_factual,NVL(ffinal_rea, fvencim), 3, 3))
                                              /(NVL(f_difdata_consulta(fefecto, fvencim, 3, 3),1)))),
                                           pcmoneda)),
                               SUM(f_round((icesion_moncon
                                            *((f_difdata_consulta(aux_factual,NVL(ffinal_rea, fvencim), 3, 3))
                                              /(NVL(f_difdata_consulta(fefecto, fvencim, 3, 3),1)))),
                                           w_cmoncon)),
                               SUM(f_round((icomisi_moncon
                                            *((f_difdata_consulta(aux_factual,NVL(ffinal_rea, fvencim), 3, 3))
                                              /(NVL(f_difdata_consulta(fefecto, fvencim, 3, 3),1)))),
                                           w_cmoncon)),
                               SUM(f_round((icesion_moncon
                                            *((f_difdata_consulta(aux_factual,NVL(ffinal_rea, fvencim), 3, 3))
                                              /(NVL(f_difdata_consulta(fefecto, fvencim, 3, 3),1)))),
                                           w_cmoncon)),
                               SUM(f_round((icomisi_moncon
                                            *((f_difdata_consulta(aux_factual,NVL(ffinal_rea, fvencim), 3, 3))
                                              /(NVL(f_difdata_consulta(fefecto, fvencim, 3, 3),1)))),
                                           w_cmoncon)),
					-- 16/03/2016 Fin
                               -- BUG 37018 -Ini
                               SUM(f_round(icesion, pcmoneda)),   --Bug 41012 09/03/2016 Ini-Fin
                               SUM(f_round(icomisi, pcmoneda)),
                               SUM(f_round(icesion_moncon, w_cmoncon)),
                               SUM(f_round(icomisi_moncon, w_cmoncon))
                           -- BUG 37018 -Fi
                          -- Bug 0026890 - 06/05/2013 - DCG - Fi
                        INTO   wprimtotreaced_gar,
                               wcomtotreaced_gar,
                               wprimnoconsreaced_gar,
                               wcomnocons_gar,
                               -- Bug 0026890 - 06/05/2013 - DCG - Ini
                               wprimtotreaced_gar_moncon,
                               wcomtotreaced_gar_moncon,
                               wprimnoconsreaced_gar_moncon,
                               wcomnocons_gar_moncon,
                               -- BUG 37018 -Ini
                               wicapces,
                               wicomisi,
                               wicapces_moncon,
                               wicomisi_moncon
                          -- BUG 37018 -Fi
                          -- Bug 0026890 - 06/05/2013 - DCG - Fi
                        FROM   reaseguro r
                         WHERE r.sseguro = reg.sseguro
                           AND r.fefecto <= aux_factual
                           AND r.fvencim > aux_factual
                           AND r.nriesgo = reg.nriesgo
                           AND r.ctramo <> 0
                           AND(r.cgarant = gar.cgarant
                               OR(wreasingarant = 0
                                  AND NVL(r.cgarant, 0) = 0))   -- 16263 AVT 22-10-2010
                                                             -- GROUP BY r.fefecto, r.fvencim -- 18241 JGR 14-04-2011 CEM_565
                        ;
                      /* END IF;
                     -- fi jgm*/
                     ELSE
                        n_traza := 210;

                        SELECT SUM(f_round(icapces, pcmoneda)),
                               SUM(f_round(icomisi, pcmoneda)),
                               SUM(f_round(icapces
                                           *((fvencim - aux_factual) /(fvencim - fefecto)),
                                           pcmoneda)),
                               SUM(f_round(icomisi
                                           *((fvencim - aux_factual) /(fvencim - fefecto)),
                                           pcmoneda)),
                               SUM(f_round(icapces_moncon, w_cmoncon)),
                               SUM(f_round(icomisi_moncon, w_cmoncon)),
                               SUM(f_round(icapces_moncon
                                           *((fvencim - aux_factual) /(fvencim - fefecto)),
                                           w_cmoncon)),
                               SUM(f_round(icomisi_moncon
                                           *((fvencim - aux_factual) /(fvencim - fefecto)),
                                           w_cmoncon))
                          INTO wprimtotreaced_gar,
                               wcomtotreaced_gar,
                               wprimnoconsreaced_gar,
                               wcomnocons_gar,
                               wprimtotreaced_gar_moncon,
                               wcomtotreaced_gar_moncon,
                               wprimnoconsreaced_gar_moncon,
                               wcomnocons_gar_moncon
                          FROM (SELECT   SUM
                                            (DECODE(tr.ctramo,
                                                    1, DECODE(SIGN((ce.icapces * tr.plocal
                                                                    / 100)
                                                                   - NVL(tr.imaxplo, 0)),
                                                              -1,(cc.pcesion
                                                                  *(100
                                                                    -((tr.plocal * tr.imaxplo)
                                                                      /((ce.icapces * tr.plocal)
                                                                        / 100))))
                                                               /(100 - tr.plocal),
                                                              cc.pcesion),
                                                    cc.pcesion)
                                             * ce.icesion / 100) icapces,
                                         SUM
                                            (DECODE(tr.ctramo,
                                                    1, DECODE(SIGN((ce.icapces * tr.plocal
                                                                    / 100)
                                                                   - NVL(tr.imaxplo, 0)),
                                                              -1,(cc.pcesion
                                                                  *(100
                                                                    -((tr.plocal * tr.imaxplo)
                                                                      /((ce.icapces * tr.plocal)
                                                                        / 100))))
                                                               /(100 - tr.plocal),
                                                              cc.pcesion),
                                                    cc.pcesion)
                                             * (SELECT ga.pcomias
                                                  FROM comgarant ga, comisreas com
                                                 WHERE ga.scomrea = com.scomrea
                                                   AND(ga.cgaraux = 0
                                                       OR(ga.cgaraux = NVL(ce.cgarant, 0)))
                                                   AND MONTHS_BETWEEN(ce.fefecto, reg.fefecto)
                                                       / 12 BETWEEN ga.canydes AND ga.canyhas
                                                   AND DECODE(reg.cduraci,
                                                              1, reg.nduraci,
                                                              2, reg.nduraci / 12,
                                                              3, MONTHS_BETWEEN(reg.fvencim,
                                                                                reg.fefecto)
                                                               / 12,
                                                              99) BETWEEN ga.cdurdes AND ga.cdurhas
                                                   AND com.ccomrea = cc.ccomrea
                                                   AND com.fcomini <= ce.fefecto
                                                   AND(com.fcomfin > ce.fvencim
                                                       OR com.fcomfin IS NULL))   --pcomisi
                                             * ce.icesion / 10000) icomisi,
                                         SUM
                                            (DECODE
                                                (tr.ctramo,
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
                                             * ce.icesion / 100)
                                         * witasa icapces_moncon,
                                         SUM
                                            (DECODE
                                                (tr.ctramo,
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
                                             * (SELECT ga.pcomias
                                                  FROM comgarant ga, comisreas com
                                                 WHERE ga.scomrea = com.scomrea
                                                   AND(ga.cgaraux = 0
                                                       OR(ga.cgaraux = NVL(ce.cgarant, 0)))
                                                   AND MONTHS_BETWEEN(ce.fefecto, reg.fefecto)
                                                       / 12 BETWEEN ga.canydes AND ga.canyhas
                                                   AND DECODE(reg.cduraci,
                                                              1, reg.nduraci,
                                                              2, reg.nduraci / 12,
                                                              3, MONTHS_BETWEEN(reg.fvencim,
                                                                                reg.fefecto)
                                                               / 12,
                                                              99) BETWEEN ga.cdurdes AND ga.cdurhas
                                                   AND com.ccomrea = cc.ccomrea
                                                   AND com.fcomini <= ce.fefecto
                                                   AND(com.fcomfin > ce.fvencim
                                                       OR com.fcomfin IS NULL))   --pcomisi
                                             * ce.icesion / 10000)
                                         * witasa icomisi_moncon,
                                         ce.fefecto, ce.fvencim
                                    FROM tramos tr, cuadroces cc, cesionesrea ce
                                   WHERE ce.sseguro = reg.sseguro
                                     AND ce.nriesgo = reg.nriesgo
                                     AND(ce.cgarant = gar.cgarant
                                         OR(wreasingarant = 0
                                            AND ce.cgarant IS NULL))
                                     AND ce.fefecto <= aux_factual
                                     AND ce.fvencim > aux_factual
                                     -- CPM 15/06/06: només agafem el moviment vigent
                                     AND(ce.fregula > aux_factual
                                         OR ce.fregula IS NULL)
                                     AND ce.cgenera NOT IN
                                           (6, 8, 30)   --7 :(4/8/06) la anulació del suplement sí que la tenim en compte
                                     -- Fi CPM
                                     AND cc.ctramo = tr.ctramo
-----------------------------------------------------------------
--  Canvio això per a que agafi el tram 1, que
-- tal i com estava, no l'agafa. (Es tema de vida).
-----------------------------------------------------------------
--AND cc.scontra = DECODE(tr.ctramo, 1, tr.nsegcon, tr.scontra)
--AND cc.nversio = DECODE(tr.ctramo, 1, tr.nsegver, tr.nversio)
                                     AND cc.scontra = tr.scontra
                                     AND cc.nversio = tr.nversio
-----------------------------------------------------------------
                                     AND tr.scontra = ce.scontra
                                     AND tr.nversio = ce.nversio
                                     AND tr.ctramo = ce.ctramo
                                GROUP BY ce.fefecto, ce.fvencim);
                     END IF;
                  EXCEPTION
                     WHEN OTHERS THEN
                        wprimtotreaced_gar := 0;
                        wcomtotreaced_gar := 0;
                        wprimnoconsreaced_gar := 0;
                        wcomnocons_gar := 0;
                        wprimtotreaced_gar_moncon := 0;
                        wcomtotreaced_gar_moncon := 0;
                        wprimnoconsreaced_gar_moncon := 0;
                        wcomnocons_gar_moncon := 0;
                  END;

                  --Bug 0024597-XVM-13/11/2012.Fin
                  wreasingarant := 1;   --ja hem assignat a la primera garantia tota la reasegurança
               ELSE
                  wprimtotreaced_gar := 0;
                  wcomtotreaced_gar := 0;
                  wprimnoconsreaced_gar := 0;
                  wcomnocons_gar := 0;
                  wprimtotreaced_gar_moncon := 0;
                  wcomtotreaced_gar_moncon := 0;
                  wprimnoconsreaced_gar_moncon := 0;
                  wcomnocons_gar_moncon := 0;
               END IF;

               -- CPM 23/9/04: Miramos si se ha de calcular la parte del seguro directo
--               IF gar.cprovis IS NULL THEN
               n_traza := 220;

               IF NVL(gar.cprovis, 1) = 1 THEN   -- bug 13621 ASN 23/03/2010
                  wprimtotnetrecseg_gar := gar.iprianu * wprorrata *(1 - gar.precseg / 100);
                  -- CPM 24/02/04: Calculem les comisions d'agents no consumides
                  wcomisiones_gar := wprimtotnetrecseg_gar *(wpcomage / 100);
                  n_traza := 230;
                  wprimtotnetrecseg_gar_moncon :=
                     f_round(gar.iprianu * wprorrata *(1 - gar.precseg / 100) * witasa,
                             w_cmoncon);
                  n_traza := 240;
                  wcomisiones_gar_moncon := f_round(wprimtotnetrecseg_gar_moncon
                                                    *(wpcomage / 100),
                                                    w_cmoncon);
               -- Fi CPM
               ELSE
                  wprimtotnetrecseg_gar := 0;
                  wcomisiones_gar := 0;
                  wprimtotnetrecseg_gar_moncon := 0;
                  wcomisiones_gar_moncon := 0;
               END IF;

               n_traza := 250;
               wprimtotnetrecseg := wprimtotnetrecseg + wprimtotnetrecseg_gar;
               wprimnocons_gar := wprimtotnetrecseg_gar
                                  *((ffinal - aux_factual) /(ffinal - aux_fefeini));
               wprimnocons := wprimnocons + wprimnocons_gar;
               wprimresultado_gar := wprimtotnetrecseg_gar - wprimnocons_gar;
               wprimresultado := wprimresultado + wprimresultado_gar;
               -- CPM 24/02/04: Calculem les comisions d'agents no consumides
               wcomisiones := wcomisiones + wcomisiones_gar;
               wcomisi_ncs_gar := wcomisiones_gar
                                  *((ffinal - aux_factual) /(ffinal - aux_fefeini));
               -- Fi CPM

               -- Calculamos la parte del reaseguro
               -- 15/5/06: Se cogen las fechas del reaseguro
               wprimtotreaced := wprimtotreaced + wprimtotreaced_gar;
               --wprimnoconsreaced_gar := wprimtotreaced_gar * ((ffinal_rea - aux_factual)/(ffinal_rea - fini_rea));
               wprimnoconsreaced := wprimnoconsreaced + wprimnoconsreaced_gar;
               wprimresultreaced_gar := wprimtotreaced_gar - wprimnoconsreaced_gar;
               wprimresultreaced := wprimresultreaced + wprimresultreaced_gar;
               wcomtotreaced := wcomtotreaced + wcomtotreaced_gar;
               --wcomnocons_gar := wcomtotreaced_gar * ((ffinal_rea - aux_factual)/(ffinal_rea - fini_rea));
               wcomnocons := wcomnocons + wcomnocons_gar;
               wcomresultado_gar := wcomtotreaced_gar - wcomnocons_gar;
               wcomresultado := wcomresultado + wcomresultado_gar;
               n_traza := 260;
               wprimnocons_gar_moncon := f_round(wprimtotnetrecseg_gar_moncon
                                                 *((ffinal - aux_factual)
                                                   /(ffinal - aux_fefeini)),
                                                 w_cmoncon);
               n_traza := 270;
               wcomisi_ncs_gar_moncon := f_round(wcomisiones_gar_moncon
                                                 *((ffinal - aux_factual)
                                                   /(ffinal - aux_fefeini)),
                                                 w_cmoncon);
               --Bug 35672/202775 KJSC cálculo de coeficiente para distribución de siniestralidad
               n_traza := 280;

               SELECT MAX(nvalpar)
                 INTO n_tipo_dissinppnc
                 FROM paractividad
                WHERE sproduc = reg.sproduc
                  AND cparame = 'TIPO_DISSINPPNC'
                  AND cactivi = reg.cactivi;

               IF NVL(n_tipo_dissinppnc, 0) != 0 THEN
                  n_traza := 290;

                  --dias mes
                  SELECT TO_NUMBER(TO_CHAR(LAST_DAY(aux_factual), 'DD'))
                    INTO v_diasmes
                    FROM DUAL;

                  --Bisiesto tomarlo 28
                  IF v_diasmes = 29 THEN
                     v_diasmes := 28;
                  END IF;

                  --valor (dd)
                  v_valor := TO_CHAR(aux_factual, 'dd');
                  --tasasin
                  v_coef :=
                     pac_subtablas.f_vsubtabla
                                           (-1, 7, 33, 1,
                                            pac_parametros.f_paractividad_n(reg.sproduc,
                                                                            reg.cactivi,
                                                                            'TIPO_DISSINPPNC'),
                                            TO_CHAR(aux_factual, 'mm'));
                  --(Tasas siniestralidad de los meses enteros hasta la fecha de renovación)
                  --Fecha de renovacion
                  v_frenovad := TO_CHAR(ffinal, 'dd');   --02

                  SELECT TO_NUMBER(TO_CHAR(LAST_DAY(ffinal), 'DD'))   --28
                    INTO v_diasmes1
                    FROM DUAL;

                  --Bisiesto tomarlo 28
                  IF v_frenovad = 29 THEN
                     v_frenovad := 28;
                  END IF;

                  IF v_diasmes1 = 29 THEN
                     v_diasmes1 := 28;
                  END IF;

                  IF v_frenovad = v_diasmes1 THEN
                     v_frenova := TO_CHAR(ffinal, 'mm');
                  ELSE
                     v_frenova := (TO_CHAR(ffinal, 'mm'));
                     IF v_frenova = 01 THEN
                        v_frenova := 12;
                     ELSE
                        v_frenova := (TO_CHAR(ffinal, 'mm'))-1;
                     END IF;
                  END IF;

                  v_aux := TO_CHAR(aux_factual, 'mm');
                  v_tasames := 0;

                  IF v_aux < v_frenova THEN
                     WHILE v_aux < v_frenova LOOP
                        v_aux := v_aux + 1;

                        IF v_aux > 12 THEN
                           v_aux := v_aux - 12;
                        END IF;

                        v_tasames :=
                           v_tasames
                           + pac_subtablas.f_vsubtabla
                                          (-1, 7, 33, 1,
                                           pac_parametros.f_paractividad_n(reg.sproduc,
                                                                           reg.cactivi,
                                                                           'TIPO_DISSINPPNC'),
                                           v_aux);
                     END LOOP;
                  ELSIF v_frenova < v_aux THEN
                     v_frenova1 := ((12 - v_aux) + v_frenova);
                     v_contador := 1;

                     WHILE v_contador <= v_frenova1 LOOP
                        v_aux := v_aux + 1;

                        IF v_aux > 12 THEN
                           v_aux := v_aux - 12;
                        END IF;

                        v_tasames :=
                           v_tasames
                           + pac_subtablas.f_vsubtabla
                                          (-1, 7, 33, 1,
                                           pac_parametros.f_paractividad_n(reg.sproduc,
                                                                           reg.cactivi,
                                                                           'TIPO_DISSINPPNC'),
                                           v_aux);

                        v_contador := v_contador + 1;
                     END LOOP;
                  END IF;

                  n_traza := 300;

                  wffinal := ffinal + 1;
                  --valor (ff)-1
                  v_ffinal :=(TO_CHAR(wffinal, 'DD') - 1);

                  --días del mes (nn)
                  SELECT TO_NUMBER(TO_CHAR(LAST_DAY(wffinal), 'DD'))
                    INTO v_ffinal1
                    FROM DUAL;

                  --tasasin
                  v_coef1 :=
                     pac_subtablas.f_vsubtabla
                                           (-1, 7, 33, 1,
                                            pac_parametros.f_paractividad_n(reg.sproduc,
                                                                            reg.cactivi,
                                                                            'TIPO_DISSINPPNC'),
                                            TO_CHAR(wffinal, 'mm'));

                  --mirar si año bisiesto
                  anobisies := ((wffinal - (ADD_MONTHS(wffinal, -12))) - (trunc((wffinal - (ADD_MONTHS(wffinal, -12)))/365) *365));

                  v_prorr := (wffinal - aux_fefeini - anobisies) / 365;

                  v_coefdef := ((((v_diasmes - v_valor) / v_diasmes) * v_coef) + v_tasames
                                + (v_ffinal / v_ffinal1) * v_coef1)
                               /(1200 * v_prorr);
                  wprimnocons_gar := f_round(wprimtotnetrecseg_gar * v_coefdef, pcmoneda);
                  wprimtotreaced_gar := wicapces;
                  wprimnoconsreaced_gar := f_round(wprimtotreaced_gar * v_coefdef, pcmoneda);
                  wcomisi_ncs_gar := f_round(wcomisiones_gar * v_coefdef, pcmoneda);
                  wcomtotreaced_gar := wicomisi;
                  wcomnocons_gar := f_round(wcomtotreaced_gar * v_coefdef, pcmoneda);
                  wprimnocons_gar_moncon := f_round(wprimtotnetrecseg_gar_moncon * v_coefdef,
                                                    w_cmoncon);
                  wprimtotreaced_gar_moncon := wicapces_moncon;
                  wprimnoconsreaced_gar_moncon :=
                                      f_round(wprimtotreaced_gar_moncon * v_coefdef, w_cmoncon);
                  wcomisi_ncs_gar_moncon := f_round(wcomisiones_gar_moncon * v_coefdef,
                                                    pcmoneda);
                  wcomtotreaced_gar_moncon := wicomisi_moncon;
                  wcomnocons_gar_moncon := f_round(wcomtotreaced_gar_moncon * v_coefdef,
                                                   w_cmoncon);
               END IF;

               --Fin Bug 35672/202775 KJSC cálculo de coeficiente para distribución de siniestralidad

               -- El package LDG grabará la tabla PPNC y LDG a la vez
               BEGIN
                  IF pmodo = 'R' THEN
                     n_traza := 310;

                     INSERT INTO ppnc
                                 (cempres, fcalcul, sproces, cramdgs, cramo,
                                  cmodali, ctipseg, ccolect, sseguro,
                                  npoliza, ncertif, cgarant,
                                  ipridev, iprincs, ipdevrc,
                                  ipncsrc, fefeini, ffinefe, nmovimi,
                                  nriesgo, icomage, icomncs, sproduc,
                                  icomrc, icncsrc, cmoneda, fcambio,
                                  itasa, ipridev_moncon,
                                  iprincs_moncon, ipdevrc_moncon,
                                  ipncsrc_moncon, icomage_moncon,
                                  icomncs_moncon, icomrc_moncon,
                                  icncsrc_moncon)
                          VALUES (reg.cempres, aux_factual, psproces, reg.cramdgs, reg.cramo,
                                  reg.cmodali, reg.ctipseg, reg.ccolect, reg.sseguro,
                                  reg.npoliza, reg.ncertif, gar.cgarant,
                                  wprimtotnetrecseg_gar, wprimnocons_gar, wprimtotreaced_gar,
                                  wprimnoconsreaced_gar, aux_fefeini, ffinal, gar.nmovimi,
                                  reg.nriesgo, wcomisiones_gar, wcomisi_ncs_gar, reg.sproduc,
                                  wcomtotreaced_gar, wcomnocons_gar, reg.cmoneda, pfcambio,
                                  witasa, wprimtotnetrecseg_gar_moncon,
                                  wprimnocons_gar_moncon, wprimtotreaced_gar_moncon,
                                  wprimnoconsreaced_gar_moncon, wcomisiones_gar_moncon,
                                  wcomisi_ncs_gar_moncon, wcomtotreaced_gar_moncon,
                                  wcomnocons_gar_moncon);
                  ELSIF pmodo = 'P' THEN
                     n_traza := 320;

                     INSERT INTO ppnc_previo
                                 (cempres, fcalcul, sproces, cramdgs, cramo,
                                  cmodali, ctipseg, ccolect, sseguro,
                                  npoliza, ncertif, cgarant,
                                  ipridev, iprincs, ipdevrc,
                                  ipncsrc, fefeini, ffinefe, nmovimi,
                                  nriesgo, icomage, icomncs, sproduc,
                                  icomrc, icncsrc, cmoneda, fcambio,
                                  itasa, ipridev_moncon,
                                  iprincs_moncon, ipdevrc_moncon,
                                  ipncsrc_moncon, icomage_moncon,
                                  icomncs_moncon, icomrc_moncon,
                                  icncsrc_moncon)
                          VALUES (reg.cempres, aux_factual, psproces, reg.cramdgs, reg.cramo,
                                  reg.cmodali, reg.ctipseg, reg.ccolect, reg.sseguro,
                                  reg.npoliza, reg.ncertif, gar.cgarant,
                                  wprimtotnetrecseg_gar, wprimnocons_gar, wprimtotreaced_gar,
                                  wprimnoconsreaced_gar, aux_fefeini, ffinal, gar.nmovimi,
                                  reg.nriesgo, wcomisiones_gar, wcomisi_ncs_gar, reg.sproduc,
                                  wcomtotreaced_gar, wcomnocons_gar, reg.cmoneda, pfcambio,
                                  witasa, wprimtotnetrecseg_gar_moncon,
                                  wprimnocons_gar_moncon, wprimtotreaced_gar_moncon,
                                  wprimnoconsreaced_gar_moncon, wcomisiones_gar_moncon,
                                  wcomisi_ncs_gar_moncon, wcomtotreaced_gar_moncon,
                                  wcomnocons_gar_moncon);
                  END IF;
               EXCEPTION
                  WHEN OTHERS THEN
                     ROLLBACK;
                     ttexto := n_traza || '-' || SQLCODE || ' ' || SQLERRM;
                     num_err := f_proceslin(psproces, ttexto || ' -PPNC-', reg.sseguro, nlin);
                     nlin := NULL;
                     num_err := 103869;
               END;

               IF num_err != 0
                  AND num_err IS NOT NULL THEN
                  ROLLBACK;
                  ttexto := f_axis_literales(num_err, pcidioma);
                  num_err := f_proceslin(psproces, ttexto || ' -PPNC-' || n_traza,
                                         reg.sseguro, nlin);
                  nlin := NULL;
               END IF;

               n_traza := 330;
               wotrgastadq_gar := wprimtotnetrecseg_gar *(reg.pgasadq / 100);
               wotrgastadq := wotrgastadq + wotrgastadq_gar;
               wgastadq_gar := wcomisiones_gar + wotrgastadq_gar;
               wgastadq := wgastadq + wgastadq_gar;
               wimplimgastadq_gar := wprimtotnetrecseg_gar *(reg.plimadq / 100);
               wimplimgastadq := wimplimgastadq + wimplimgastadq_gar;
               wgastadqnocons_gar := LEAST(wgastadq_gar, wimplimgastadq_gar)
                                     *((ffinal - aux_factual) /(ffinal - aux_fefeini));
               wgastadqnocons := wgastadqnocons + wgastadqnocons_gar;
               wgastadqresult_gar := LEAST(wgastadq_gar, wimplimgastadq_gar)
                                     - wgastadqnocons_gar;
               wgastadqresult := wgastadqresult + wgastadqresult_gar;
               wotrgastadm_gar := wprimtotnetrecseg_gar *(reg.pgasadm / 100);
               wotrgastadm := wotrgastadm + wotrgastadm_gar;
               wimplimgastadm_gar := wprimtotnetrecseg_gar *(reg.plimadm / 100);
               wimplimgastadm := wimplimgastadm + wimplimgastadm_gar;
               wgastadmnocons_gar := LEAST(wotrgastadm_gar, wimplimgastadm_gar)
                                     *((ffinal - aux_factual) /(ffinal - aux_fefeini));
               wgastadmnocons := wgastadmnocons + wgastadmnocons_gar;
               wgastadmresult_gar := LEAST(wotrgastadm_gar, wimplimgastadm_gar)
                                     - wgastadmnocons_gar;
               wgastadmresult := wgastadmresult + wgastadmresult_gar;
            END LOOP;

            n_traza := 340;
            wsuma := wprimtotnetrecseg + wprimnocons + wprimresultado + wprimtotreaced
                     + wprimresultreaced + wprimnoconsreaced + wcomtotreaced + wcomnocons
                     + wcomresultado + wcomisiones + wotrgastadq + wgastadq + wimplimgastadq
                     + wgastadqnocons + wgastadqresult + wotrgastadm + wimplimgastadm
                     + wgastadmnocons + wgastadmresult;

            IF wsuma != 0 THEN
               BEGIN
                  IF pmodo = 'R' THEN
                     NULL;   -- Se quita porque Cristina Pina me pide eliminar estas tablas --
                  END IF;
               EXCEPTION
                  WHEN OTHERS THEN
                     num_err := 103869;
               END;
            END IF;

            IF num_err != 0
               AND num_err IS NOT NULL THEN
               ROLLBACK;
               ttexto := f_axis_literales(num_err, pcidioma);
               num_err := f_proceslin(psproces, ttexto || ' -PPNC-' || n_traza, reg.sseguro,
                                      nlin);
               nlin := NULL;
               conta_err := conta_err + 1;
            END IF;
         ELSE
            ttexto := f_axis_literales(num_err, pcidioma);
            num_err := f_proceslin(psproces, ttexto || ' -PPNC-' || n_traza, reg.sseguro,
                                   nlin);
            nlin := NULL;
            conta_err := conta_err + 1;
         END IF;

         COMMIT;
      END LOOP;

      n_traza := 350;

-- NO VÁLIDO PARA CREDIT (si para financera) -- P_DRETS_REGISTRE_PPNC(psproces,pmodo);
      IF pmodo = 'R' THEN
         n_traza := 360;

         DELETE FROM ppnc
               WHERE ipridev <= 0
                 AND NVL(ipdevrc, 0) = 0
                 AND sproces = psproces;
      ELSIF pmodo = 'P' THEN
         n_traza := 370;

         DELETE FROM ppnc_previo
               WHERE ipridev <= 0
                 AND NVL(ipdevrc, 0) = 0
                 AND sproces = psproces;
      END IF;

      n_traza := 370;
      COMMIT;
      -- 2799 AVT 6/08/2012 FI ----------------------------------
      RETURN(conta_err);
   END f_commit_calcul_ppnc;

-----------------------------------------------------------------------
-- PPNC_RECARGO_FRACCI
-----------------------------------------------------------------------
   FUNCTION f_commit_calcul_ppnc_fracc(
      cempres IN NUMBER,
      aux_factual IN DATE,
      psproces IN NUMBER,
      pcidioma IN NUMBER,
      pcmoneda IN NUMBER,
      pmodo IN VARCHAR2 DEFAULT 'R')
      RETURN NUMBER IS
      ttexto         VARCHAR2(400);
      nlin           NUMBER;
      conta_err      NUMBER := 0;
      wprorrata      NUMBER;
      aux_fefeini    DATE;
      ffinal         DATE;
      wcmodcom       NUMBER;
      num_err        NUMBER := 0;
      vctipcon       NUMBER;
      vcfracci       NUMBER;
      vcbonifi       NUMBER;
      vcrecfra       NUMBER;
      w_climit       NUMBER;
      v_cmonimp      imprec.cmoneda%TYPE;
      vcderreg       NUMBER;
      xprecarg       NUMBER;
      xirecarg       NUMBER;
      xirecarg_nc    NUMBER;
   BEGIN
      FOR reg IN c_polizas_ppnc(aux_factual, cempres) LOOP
         num_err := f_fechainifin(reg.sseguro, aux_factual, reg.fvencim, reg.fcaranu, ffinal,
                                  aux_fefeini, wprorrata, wcmodcom);

         IF num_err != 0 THEN
            num_err := 104349;
         END IF;

         IF num_err = 0 THEN
            FOR gar IN c_garantias_ppnc(reg.sseguro, reg.cramo, reg.cmodali, reg.ctipseg,
                                        reg.ccolect, aux_factual, ffinal, reg.nriesgo) LOOP
               --Buscamos el porcentaje de recargo
               num_err := f_concepto(8, reg.cempres, gar.finiefe, reg.cforpag, reg.cramo,
                                     reg.cmodali, reg.ctipseg, reg.ccolect, gar.cactivi,
                                     gar.cgarant, vctipcon, xprecarg, vcfracci, vcbonifi,
                                     vcrecfra, w_climit, v_cmonimp, vcderreg);

               IF NVL(xprecarg, 0) <> 0 THEN
                  xirecarg := gar.iprianu / 100 * NVL(xprecarg, 0) * wprorrata;   --Recargo anual
                  xirecarg_nc := NVL(xirecarg, 0)
                                 *((ffinal - aux_factual) /(ffinal - aux_fefeini));   --Recargo anual no consumido

                  BEGIN
                     IF pmodo = 'R' THEN
                        --Se updatea la ppnc
                        UPDATE ppnc
                           SET precarg = xprecarg,
                               irecfra = xirecarg,
                               irecfranc = xirecarg_nc
                         WHERE sproces = psproces
                           AND cramdgs = reg.cramdgs
                           AND cramo = reg.cramo
                           AND cmodali = reg.cmodali
                           AND ctipseg = reg.ctipseg
                           AND ccolect = reg.ccolect
                           AND sseguro = reg.sseguro
                           AND nmovimi = gar.nmovimi
                           AND nriesgo = reg.nriesgo
                           AND cgarant = gar.cgarant;
                     ELSIF pmodo = 'P' THEN
                        --Se updatea la ppnc
                        UPDATE ppnc_previo
                           SET precarg = xprecarg,
                               irecfra = xirecarg,
                               irecfranc = xirecarg_nc
                         WHERE sproces = psproces
                           AND cramdgs = reg.cramdgs
                           AND cramo = reg.cramo
                           AND cmodali = reg.cmodali
                           AND ctipseg = reg.ctipseg
                           AND ccolect = reg.ccolect
                           AND sseguro = reg.sseguro
                           AND nmovimi = gar.nmovimi
                           AND nriesgo = reg.nriesgo
                           AND cgarant = gar.cgarant;
                     END IF;
                  EXCEPTION
                     WHEN OTHERS THEN
                        num_err := 103869;
                  END;
               END IF;

               IF num_err != 0
                  AND num_err IS NOT NULL THEN
                  ROLLBACK;
                  ttexto := f_axis_literales(num_err, pcidioma);
                  num_err := f_proceslin(psproces, ttexto || ' -PPNC_FRACC', reg.sseguro,
                                         nlin);
                  nlin := NULL;
               END IF;

               COMMIT;
            END LOOP;
         ELSE
            ttexto := f_axis_literales(num_err, pcidioma);
            num_err := f_proceslin(psproces, ttexto || ' -PPNC_FRACC', reg.sseguro, nlin);
            nlin := NULL;
            conta_err := conta_err + 1;
         END IF;
      END LOOP;

      COMMIT;
      RETURN(conta_err);
   END f_commit_calcul_ppnc_fracc;

-----------------------------------------------------------------------
-----------------------------------------------------------------------
-----------------------------------------------------------------------
-- PPNC REA
-----------------------------------------------------------------------
   -- Bug 0026214 - 22/04/2013 - JMF
   FUNCTION f_commit_calcul_ppncrea(
      cempres IN NUMBER,
      aux_factual IN DATE,
      psproces IN NUMBER,
      pcidioma IN NUMBER,
      pcmoneda IN NUMBER,
      pmodo IN VARCHAR2 DEFAULT 'R')
      RETURN NUMBER IS
      v_obj          VARCHAR2(400) := 'PAC_PROVTEC.f_commit_calcul_ppncrea';
      ttexto         VARCHAR2(400);
      nlin           NUMBER;
      num_err        NUMBER := 0;
      conta_err      NUMBER := 0;
      aux_fefeini    DATE;
      wprimtotnetrecseg NUMBER;
      wprimnocons    NUMBER;
      wprimresultado NUMBER;
      wprimtotreaced NUMBER;
      wprimresultreaced NUMBER;
      wprimnoconsreaced NUMBER;
      wcomtotreaced  NUMBER;
      wcomnocons     NUMBER;
      wcomresultado  NUMBER;
      wcomisiones    NUMBER;
      wotrgastadq    NUMBER;
      wgastadq       NUMBER;
      wimplimgastadq NUMBER;
      wgastadqnocons NUMBER;
      wgastadqresult NUMBER;
      wotrgastadm    NUMBER;
      wimplimgastadm NUMBER;
      wgastadmnocons NUMBER;
      wgastadmresult NUMBER;
      wprimresultado_gar NUMBER;
      wprimtotreaced_gar NUMBER;
      wprimresultreaced_gar NUMBER;
      wprimnoconsreaced_gar NUMBER;
      wcomtotreaced_gar NUMBER;
      wcomnocons_gar NUMBER;
      wcomresultado_gar NUMBER;
      wotrgastadq_gar NUMBER;
      wgastadq_gar   NUMBER;
      wimplimgastadq_gar NUMBER;
      wgastadqnocons_gar NUMBER;
      wgastadqresult_gar NUMBER;
      wotrgastadm_gar NUMBER;
      wimplimgastadm_gar NUMBER;
      wgastadmnocons_gar NUMBER;
      wgastadmresult_gar NUMBER;
      wcomtotreaced_seg NUMBER;
      wcomnocons_seg NUMBER;
      wcomresultado_seg NUMBER;
      wprimacomisionseguro NUMBER;
      wprimtotreaced_gar_moncon NUMBER;   -- Bug 0026890 - 06/05/2013 - DCG -inici
      wcomtotreaced_gar_moncon NUMBER;
      wprimnoconsreaced_gar_moncon NUMBER;
      wcomnocons_gar_moncon NUMBER;   -- Bug 0026890 - 06/05/2013 - DCG -fi
      wsuma          NUMBER;
      wsegrea        NUMBER;
      wgarrea        NUMBER;
      wcmodcom       NUMBER;
      wpcomage       NUMBER;
      wpretenc       NUMBER;
      wseguro1       NUMBER;
      ffinal         DATE;
      wprorrata      NUMBER;
      ffinal_rea     DATE;
      fini_rea       DATE;
      wreasingarant  NUMBER;
      bfraccionario  NUMBER(1) := NULL;
      pmes           VARCHAR2(2);   -- 22799 AVT 06/08/2012
      pany           VARCHAR2(4);   -- 22799 AVT 06/08/2012
      -- Bug 0026214 - 22/04/2013 - JMF
      w_cmoncon      parempresas.nvalpar%TYPE
                                     := pac_parametros.f_parempresa_n(cempres, 'MONEDACONTAB');
      -- Moneda de contablidad (numérico)
      w_cmoncon_t    monedas.cmonint%TYPE := pac_monedas.f_cmoneda_t(w_cmoncon);
      -- Moneda de contablidad (texto)
      pfcambio       DATE;   -- Fecha del cambio vigente a la fecha actual
      witasa         NUMBER(15, 2);   -- Tasa vigente
      v_multimoneda  NUMBER(1) := 0;
      -- Bug 0026214 - 22/04/2013 - JMF
      v_tiene_ppnc_rea NUMBER(3);   -- Bug 29775 - 01/04/2014 - JMF
      n_ctramo       NUMBER(2);

      CURSOR c1(
         n_sseguro NUMBER,
         n_ccompani NUMBER,
         n_nriesgo NUMBER,
         n_cgarant NUMBER,
         f_fefecto DATE,
         f_fvencim DATE,
         n_cduraci NUMBER,
         n_nduraci NUMBER) IS
         SELECT   SUM(f_round((icesion
                               *((NVL(ffinal_rea, fvencim) - NVL(fini_rea, fefecto))
                                 /(fvencim - fefecto))),
                              pcmoneda)) wprimtotreaced_gar,
                  SUM(f_round((icomisi
                               *((NVL(ffinal_rea, fvencim) - NVL(fini_rea, fefecto))
                                 /(fvencim - fefecto))),
                              pcmoneda)) wcomtotreaced_gar,
                  SUM(f_round((icesion
                               *((NVL(ffinal_rea, fvencim) - aux_factual) /(fvencim - fefecto))),
                              pcmoneda)) wprimnoconsreaced_gar,
                  SUM(f_round((icomisi
                               *((NVL(ffinal_rea, fvencim) - aux_factual) /(fvencim - fefecto))),
                              pcmoneda)) wcomnocons_gar,
                  SUM(f_round((icesion_moncon
                               *((NVL(ffinal_rea, fvencim) - NVL(fini_rea, fefecto))
                                 /(fvencim - fefecto))),
                              w_cmoncon)) wprimtotreaced_gar_moncon,
                  SUM(f_round((icomisi_moncon
                               *((NVL(ffinal_rea, fvencim) - NVL(fini_rea, fefecto))
                                 /(fvencim - fefecto))),
                              w_cmoncon)) wcomtotreaced_gar_moncon,
                  SUM(f_round((icesion_moncon
                               *((NVL(ffinal_rea, fvencim) - aux_factual) /(fvencim - fefecto))),
                              w_cmoncon)) wprimnoconsreaced_gar_moncon,
                  SUM(f_round((icomisi_moncon
                               *((NVL(ffinal_rea, fvencim) - aux_factual) /(fvencim - fefecto))),
                              w_cmoncon)) wcomnocons_gar_moncon,
                  ctramo
             FROM reaseguro r
            WHERE r.sseguro = n_sseguro
              AND r.ccompani = n_ccompani
              AND r.fefecto <= aux_factual
              AND(r.fvencim > aux_factual
                  OR r.fvencim IS NULL)
              AND r.nriesgo = n_nriesgo
              AND r.ctramo <> 0
              AND(r.cgarant = n_cgarant
                  OR(wreasingarant = 0
                     AND NVL(r.cgarant, 0) = 0))
              AND NVL(pac_parametros.f_parempresa_n(cempres, 'PPNC_REASEG_FRACC'), 0) = 0
         GROUP BY ctramo
         UNION
         SELECT   SUM(f_round(icapces, pcmoneda)) wprimtotreaced_gar,
                  SUM(f_round(icomisi, pcmoneda)) wcomtotreaced_gar,
                  SUM(f_round(icapces
                              *((fvencim - aux_factual) /(fvencim - fefecto)),
                              pcmoneda)) wprimnoconsreaced_gar,
                  SUM(f_round(icomisi
                              *((fvencim - aux_factual) /(fvencim - fefecto)),
                              pcmoneda)) wcomnocons_gar,
                  SUM(f_round(icapces_moncon, w_cmoncon)) wprimtotreaced_gar_moncon,
                  SUM(f_round(icomisi_moncon, w_cmoncon)) wcomtotreaced_gar_moncon,
                  SUM(f_round(icapces_moncon
                              *((fvencim - aux_factual) /(fvencim - fefecto)),
                              w_cmoncon)) wprimnoconsreaced_gar_moncon,
                  SUM(f_round(icomisi_moncon
                              *((fvencim - aux_factual) /(fvencim - fefecto)),
                              w_cmoncon)) wcomnocons_gar_moncon,
                  ctramo
             FROM (SELECT   SUM(DECODE(tr.ctramo,
                                       1, DECODE(SIGN((ce.icapces * tr.plocal / 100)
                                                      - NVL(tr.imaxplo, 0)),
                                                 -1,(cc.pcesion
                                                     *(100
                                                       -((tr.plocal * tr.imaxplo)
                                                         /((ce.icapces * tr.plocal) / 100))))
                                                  /(100 - tr.plocal),
                                                 cc.pcesion),
                                       cc.pcesion)
                                * ce.icesion / 100) icapces,
                            SUM
                               (DECODE(tr.ctramo,
                                       1, DECODE(SIGN((ce.icapces * tr.plocal / 100)
                                                      - NVL(tr.imaxplo, 0)),
                                                 -1,(cc.pcesion
                                                     *(100
                                                       -((tr.plocal * tr.imaxplo)
                                                         /((ce.icapces * tr.plocal) / 100))))
                                                  /(100 - tr.plocal),
                                                 cc.pcesion),
                                       cc.pcesion)
                                * (SELECT ga.pcomias
                                     FROM comgarant ga, comisreas com
                                    WHERE ga.scomrea = com.scomrea
                                      AND(ga.cgaraux = 0
                                          OR(ga.cgaraux = NVL(ce.cgarant, 0)))
                                      AND MONTHS_BETWEEN(ce.fefecto, f_fefecto) / 12
                                            BETWEEN ga.canydes
                                                AND ga.canyhas
                                      AND DECODE(n_cduraci,
                                                 1, n_nduraci,
                                                 2, n_nduraci / 12,
                                                 3, MONTHS_BETWEEN(f_fvencim, f_fefecto) / 12,
                                                 99) BETWEEN ga.cdurdes AND ga.cdurhas
                                      AND com.ccomrea = cc.ccomrea
                                      AND com.fcomini <= ce.fefecto
                                      AND(com.fcomfin > ce.fvencim
                                          OR com.fcomfin IS NULL))   --pcomisi
                                * ce.icesion / 10000) icomisi,
                            SUM(DECODE(tr.ctramo,
                                       1, DECODE(SIGN((ce.icapces * tr.plocal / 100)
                                                      - NVL(tr.imaxplo, 0)),
                                                 -1,(cc.pcesion
                                                     *(100
                                                       -((tr.plocal * tr.imaxplo)
                                                         /((ce.icapces * tr.plocal) / 100))))
                                                  /(100 - tr.plocal),
                                                 cc.pcesion),
                                       cc.pcesion)
                                * ce.icesion / 100)
                            * witasa icapces_moncon,
                            SUM
                               (DECODE(tr.ctramo,
                                       1, DECODE(SIGN((ce.icapces * tr.plocal / 100)
                                                      - NVL(tr.imaxplo, 0)),
                                                 -1,(cc.pcesion
                                                     *(100
                                                       -((tr.plocal * tr.imaxplo)
                                                         /((ce.icapces * tr.plocal) / 100))))
                                                  /(100 - tr.plocal),
                                                 cc.pcesion),
                                       cc.pcesion)
                                * (SELECT ga.pcomias
                                     FROM comgarant ga, comisreas com
                                    WHERE ga.scomrea = com.scomrea
                                      AND(ga.cgaraux = 0
                                          OR(ga.cgaraux = NVL(ce.cgarant, 0)))
                                      AND MONTHS_BETWEEN(f_fefecto, f_fefecto) / 12
                                            BETWEEN ga.canydes
                                                AND ga.canyhas
                                      AND DECODE(n_cduraci,
                                                 1, n_nduraci,
                                                 2, n_nduraci / 12,
                                                 3, MONTHS_BETWEEN(f_fvencim, f_fefecto) / 12,
                                                 99) BETWEEN ga.cdurdes AND ga.cdurhas
                                      AND com.ccomrea = cc.ccomrea
                                      AND com.fcomini <= ce.fefecto
                                      AND(com.fcomfin > ce.fvencim
                                          OR com.fcomfin IS NULL))   --pcomisi
                                * ce.icesion / 10000)
                            * witasa icomisi_moncon,
                            ce.fefecto, ce.fvencim, tr.ctramo
                       FROM tramos tr, cuadroces cc, cesionesrea ce
                      WHERE ce.sseguro = n_sseguro
                        AND cc.ccompani = n_ccompani
                        AND ce.nriesgo = n_nriesgo
                        AND(ce.cgarant = n_cgarant
                            OR(wreasingarant = 0
                               AND ce.cgarant IS NULL))
                        AND ce.fefecto <= aux_factual
                        AND(ce.fvencim > aux_factual
                            OR ce.fvencim IS NULL)
                        AND(ce.fregula > aux_factual
                            OR ce.fregula IS NULL)
                        AND ce.cgenera NOT IN(6, 8, 30)
                        AND cc.ctramo = tr.ctramo
                        AND cc.scontra = tr.scontra
                        AND cc.nversio = tr.nversio
                        AND tr.scontra = ce.scontra
                        AND tr.nversio = ce.nversio
                        AND tr.ctramo = ce.ctramo
                        AND NVL(pac_parametros.f_parempresa_n(cempres, 'PPNC_REASEG_FRACC'), 0) <>
                                                                                              0
                   GROUP BY ce.fefecto, ce.fvencim, tr.ctramo)
         GROUP BY ctramo;
   BEGIN
      v_multimoneda := NVL(pac_parametros.f_parempresa_n(cempres, 'MULTIMONEDA'), 0);

      FOR reg IN c_polizas_ppnc(aux_factual, cempres) LOOP
         --- JGM --18/09/2008 --busqueda de si producto fraccionario para luego--
         DECLARE
            vproduc        seguros.sproduc%TYPE;
            num_err        NUMBER;
         BEGIN
            SELECT sproduc
              INTO vproduc
              FROM seguros
             WHERE sseguro = reg.sseguro;

            num_err := f_parproductos(vproduc, 'FRACCIONARIO', bfraccionario);

            IF num_err <> 0 THEN
               bfraccionario := NULL;
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               bfraccionario := NULL;
         END;

------------------------------------------------------------------------
         num_err := f_fechainifin(reg.sseguro, aux_factual, reg.fvencim, reg.fcaranu, ffinal,
                                  aux_fefeini, wprorrata, wcmodcom);

         IF num_err != 0 THEN
            p_tab_error(f_sysdate, f_user, v_obj, 1213,
                        ' s=' || reg.sseguro || ' f=' || aux_factual || ' v=' || reg.fvencim
                        || ' v=' || reg.fcaranu,
                        'err=' || num_err || ' ' || SQLCODE || '-' || SQLERRM);
            num_err := 104349;
         END IF;

         wreasingarant := 0;

         IF num_err = 0 THEN
            FOR gar IN c_garantias_ppnc(reg.sseguro, reg.cramo, reg.cmodali, reg.ctipseg,
                                        reg.ccolect, aux_factual, ffinal, reg.nriesgo) LOOP
               -- CPM 23/9/04: El cálculo de las PPNC se realizará tanto para pólizas que no se
               --  se calcule su provisión matemática (CPROVIS IS NULL) como para las pólizas
               --  que tengan reaseguro. El motivo es que el reaseguro se calcula anualmente
               --  por lo que se puede calculas su prima no consumida del reaseguro anual.
               --  Este problema aparece con las pólizas de prima única, que no tienen cálculo
               --  de primas no consumidas de la parte del seguro directo (porque se cálculan a
               --  través de las provisiones matématicas) pero si que tienen cálculo de primas
               --  no consumidas de la parte del reaseguro
               FOR f_cia IN (SELECT DISTINCT ccompani, scontra, nversio
                                        FROM reaseguro
                                       WHERE sseguro = reg.sseguro) LOOP
                  -- Bug 0030219 - 19/02/2014 - DCG - INI
                  IF reg.csegrea = 0
                     AND gar.cgarrea = 0 THEN   -- Tenemos Reaseguro
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
                              num_err := f_proceslin(psproces, ttexto || ' -PPNC_REA',
                                                     reg.sseguro, nlin);
                              nlin := NULL;
                              num_err := 9902592;
                           -- No se ha encontrado el tipo de cambio entre monedas
                           END IF;

                           witasa := pac_eco_tipocambio.f_cambio(reg.cmoneda_t, w_cmoncon_t,
                                                                 pfcambio);
                        END IF;
                     END IF;

                     -- Calculem la cesió anual i no la fraccionada (a nivell de rebut). Per això necessitem
                     -- la taula CESIONESREA, pero el pcomisi, només està a nivell de companyia per lo qual
                     -- ens veiem obligats a calcularlo

                     -- distinta select segun si es o no fraccionario --
                     IF NVL(bfraccionario, 0) <> 1 THEN
                        ffinal_rea := ffinal;
                        fini_rea := aux_fefeini;
                     ELSE
                        ffinal_rea := NULL;
                        fini_rea := NULL;
                     END IF;

                     OPEN c1(reg.sseguro, f_cia.ccompani, reg.nriesgo, gar.cgarant,
                             reg.fefecto, reg.fvencim, reg.cduraci, reg.nduraci);

                     LOOP
                        FETCH c1
                         INTO wprimtotreaced_gar, wcomtotreaced_gar, wprimnoconsreaced_gar,
                              wcomnocons_gar, wprimtotreaced_gar_moncon,
                              wcomtotreaced_gar_moncon, wprimnoconsreaced_gar_moncon,
                              wcomnocons_gar_moncon, n_ctramo;

                        EXIT WHEN c1%NOTFOUND;

                        BEGIN
                           IF pmodo = 'R' THEN
                              INSERT INTO ppnc_rea
                                          (cempres, fcalcul, sproces, cramdgs,
                                           cramo, cmodali, ctipseg, ccolect,
                                           sseguro, npoliza, ncertif,
                                           cgarant, ccompani, fefeini, ffinefe,
                                           ipdevrc, ipncsrc,
                                           nmovimi, nriesgo, sproduc,
                                           icomrc, icncsrc, cmoneda,
                                           fcambio, itasa, ipdevrc_moncon,
                                           ipncsrc_moncon,
                                           icomrc_moncon, icncsrc_moncon,
                                           ntramo, ncontrato, nversion)
                                   VALUES (reg.cempres, aux_factual, psproces, reg.cramdgs,
                                           reg.cramo, reg.cmodali, reg.ctipseg, reg.ccolect,
                                           reg.sseguro, reg.npoliza, reg.ncertif,
                                           gar.cgarant, f_cia.ccompani, aux_factual, ffinal,
                                           wprimtotreaced_gar, wprimnoconsreaced_gar,
                                           gar.nmovimi, reg.nriesgo, reg.sproduc,
                                           wcomtotreaced_gar, wcomnocons_gar, reg.cmoneda,
                                           pfcambio, witasa, wprimtotreaced_gar_moncon,
                                           wprimnoconsreaced_gar_moncon,
                                           wcomtotreaced_gar_moncon, wcomnocons_gar_moncon,
                                           n_ctramo, f_cia.scontra, f_cia.nversio);
                           ELSIF pmodo = 'P' THEN
                              INSERT INTO ppnc_rea_previo
                                          (cempres, fcalcul, sproces, cramdgs,
                                           cramo, cmodali, ctipseg, ccolect,
                                           sseguro, npoliza, ncertif,
                                           cgarant, ccompani, fefeini, ffinefe,
                                           ipdevrc, ipncsrc,
                                           nmovimi, nriesgo, sproduc,
                                           icomrc, icncsrc, cmoneda,
                                           fcambio, itasa, ipdevrc_moncon,
                                           ipncsrc_moncon,
                                           icomrc_moncon, icncsrc_moncon,
                                           ntramo, ncontrato, nversion)
                                   VALUES (reg.cempres, aux_factual, psproces, reg.cramdgs,
                                           reg.cramo, reg.cmodali, reg.ctipseg, reg.ccolect,
                                           reg.sseguro, reg.npoliza, reg.ncertif,
                                           gar.cgarant, f_cia.ccompani, aux_factual, ffinal,
                                           wprimtotreaced_gar, wprimnoconsreaced_gar,
                                           gar.nmovimi, reg.nriesgo, reg.sproduc,
                                           wcomtotreaced_gar, wcomnocons_gar, reg.cmoneda,
                                           pfcambio, witasa, wprimtotreaced_gar_moncon,
                                           wprimnoconsreaced_gar_moncon,
                                           wcomtotreaced_gar_moncon, wcomnocons_gar_moncon,
                                           n_ctramo, f_cia.scontra, f_cia.nversio);
                           END IF;
                        EXCEPTION
                           WHEN OTHERS THEN
                              num_err := 103869;
                              p_tab_error(f_sysdate, f_user, v_obj, 1331,
                                          'e=' || reg.cempres || ' c=' || aux_factual || ' p='
                                          || psproces || ' s=' || reg.sseguro || ' g='
                                          || gar.cgarant || ' c=' || f_cia.ccompani,
                                          SQLCODE || '-' || SQLERRM);
                        END;
                     END LOOP;

                     CLOSE c1;
                  END IF;

                  IF num_err != 0
                     AND num_err IS NOT NULL THEN
                     ROLLBACK;
                     ttexto := f_axis_literales(num_err, pcidioma);
                     num_err := f_proceslin(psproces, ttexto || ' -PPNCREA', reg.sseguro,
                                            nlin);
                     nlin := NULL;
                  END IF;
               END LOOP;

               wreasingarant := 1;   --ja hem assignat a la primera garantia tota la reasegurança
            END LOOP;

            IF num_err != 0
               AND num_err IS NOT NULL THEN
               ROLLBACK;
               ttexto := f_axis_literales(num_err, pcidioma);
               num_err := f_proceslin(psproces, ttexto || ' -PPNCREA', reg.sseguro, nlin);
               nlin := NULL;
               conta_err := conta_err + 1;
            END IF;
         ELSE
            ttexto := f_axis_literales(num_err, pcidioma);
            num_err := f_proceslin(psproces, ttexto || ' -PPNCREA', reg.sseguro, nlin);
            nlin := NULL;
            conta_err := conta_err + 1;
         END IF;

         COMMIT;
      END LOOP;

      -- NO VÁLIDO PARA CREDIT (si para financera) -- P_DRETS_REGISTRE_PPNC(psproces,pmodo);
      IF pmodo = 'R' THEN
         DELETE FROM ppnc_rea
               WHERE NVL(ipdevrc, 0) <= 0
                 AND NVL(ipncsrc, 0) = 0
                 AND sproces = psproces;
      ELSIF pmodo = 'P' THEN
         DELETE FROM ppnc_rea_previo
               WHERE NVL(ipdevrc, 0) <= 0
                 AND NVL(ipncsrc, 0) = 0
                 AND sproces = psproces;
      END IF;

      COMMIT;

      -- 22799 AVT 01/08/2012  AGM TREU EL C?LCUL DE RESERVES DEL TANCMENT PER FER-LO POST PPNC
      IF NVL(pac_parametros.f_parempresa_n(cempres, 'REA_RESERV_PPNC'), 0) = 1
         AND pmodo = 'R' THEN
         SELECT COUNT(1)
           INTO v_tiene_ppnc_rea
           FROM codprovi_emp a
          WHERE cprovis = 19
            AND a.cempres = cempres;

         IF v_tiene_ppnc_rea > 0 THEN
            pmes := TO_CHAR(aux_factual, 'mm');
            pany := TO_CHAR(aux_factual, 'yyyy');

            IF pmes IN('03', '06', '09', '12') THEN
               num_err := pac_reaseguro_rec.f_diposit_ppnc_rea(cempres, pmes, pany, psproces);

               IF num_err != 0
                  AND num_err IS NOT NULL THEN
                  ROLLBACK;
                  ttexto := f_axis_literales(num_err, pcidioma);
                  num_err := f_proceslin(psproces, ttexto || ' -PPNC', 'REA_RESERV_PPNC',
                                         nlin);
                  nlin := NULL;
                  conta_err := conta_err + 1;
               ELSE
                  COMMIT;
               END IF;
            END IF;
         END IF;
      END IF;

      RETURN(conta_err);
   END f_commit_calcul_ppncrea;

   -- el cálculo de la provision de estabilizacion
   FUNCTION f_commit_calcul_pestab(
      cempres IN NUMBER,
      aux_factual IN DATE,
      psproces IN NUMBER,
      pcidioma IN NUMBER,
      pcmoneda IN NUMBER,
      pmodo IN VARCHAR2 DEFAULT 'R')
      RETURN NUMBER IS
      aux_fefeini    DATE;
      ttexto         VARCHAR2(60);
      nlin           NUMBER;
      num_err        NUMBER;
      conta_err      NUMBER := 0;
      wpestab        NUMBER;
      wpreaseg       NUMBER;
      werror         NUMBER;
      wgarrea        NUMBER;
      wsegrea        NUMBER;
      wpnrea         NUMBER;
      aux_ffinal     DATE;
      seguro         NUMBER;
      ffinal         DATE;
      wtotreaseg     NUMBER;
      wprorrata      NUMBER;
      wcmodcom       NUMBER;
      wprecseg       NUMBER;   -- Bug 21715 - APD - 08/05/2012
      wipridev       NUMBER;   -- Bug 21715 - APD - 08/05/2012
      v_lim_min      NUMBER;   -- Bug 21715 - APD - 08/05/2012
      v_rel_prim     NUMBER;   -- Bug 21715 - APD - 08/05/2012
   BEGIN
      -- % Límite mínimo provisión
      v_lim_min := NVL(pac_parametros.f_parempresa_n(cempres, 'LIM_MIN_PESTAB'), 0);

      IF v_lim_min = 0 THEN
         v_lim_min := 1;
      ELSE
         v_lim_min := v_lim_min / 100;
      END IF;

      -- Relación entre prima de comercial y prima de riesgo (P = 0,XXXX P")
      v_rel_prim := NVL(pac_parametros.f_parempresa_n(cempres, 'REL_PRIM_PESTAB'), 1);

      FOR reg IN c_polizas_pestab(aux_factual, cempres) LOOP
         num_err := f_fechainifin(reg.sseguro, aux_factual, reg.fvencim, reg.fcaranu, ffinal,
                                  aux_fefeini, wprorrata, wcmodcom);

         IF num_err != 0 THEN
            ROLLBACK;
            p_literal2(num_err, pcidioma, ttexto);
            num_err := f_proceslin(psproces, ttexto, reg.sseguro, nlin);
            conta_err := conta_err + 1;
            nlin := NULL;
            COMMIT;
         END IF;

         num_err := pac_llibsin.datos_rea_sin(reg.cramo, reg.cmodali, reg.ctipseg, reg.ccolect,
                                              reg.sseguro, wsegrea, ttexto);

         IF num_err = 0 THEN
            FOR gar IN c_garantias_pestab(aux_factual, ffinal, reg.cramo, reg.cmodali,
                                          reg.ctipseg, reg.ccolect, reg.sseguro) LOOP
               IF wsegrea = 0 THEN
                  num_err := pac_llibsin.datos_rea_gar(reg.cramo, reg.cmodali, reg.ctipseg,
                                                       reg.ccolect, gar.cgarant, reg.cactivi,
                                                       wgarrea, ttexto);

                  IF num_err != 0 THEN
                     EXIT;
                  END IF;

                  IF wgarrea = 0 THEN
                     werror := 0;
                     num_err := pac_llibsin.f_pnoreaseguro(reg.sseguro, gar.nriesgo,
                                                           gar.cgarant, gar.finiefe, wpnrea,
                                                           wtotreaseg);

                     IF num_err != 0 THEN
                        -- Miramos si hay facultativo pendiente
                        BEGIN
                           SELECT sseguro
                             INTO seguro
                             FROM cuafacul   -- BUG 10462: ETM:16/06/2009:--ANTES--facpendientes
                            WHERE sseguro = reg.sseguro
                              AND cestado = 1;   -- BUG 10462: ETM:30/06/2009:--AÑADIMOS-- CESTADO=1-

                           werror := 2;
                           --wpnrea := f_porcenreasegramo(reg.cramo, wtotreaseg);
                           wpnrea := 0;
                           num_err := 0;
                        EXCEPTION
                           WHEN OTHERS THEN
                              werror := 1;
                              --wpnrea := f_porcenreasegramo(reg.cramo, wtotreaseg);
                              wpnrea := 0;
                              num_err := 0;
                        END;
                     END IF;
                  ELSE
-- Garantía no reaegurable
                     wpnrea := 100;
                     wtotreaseg := 0;
                  END IF;
               ELSE
-- Producto o seguro no reasegurable
                  wpnrea := 100;
                  wtotreaseg := 0;
               END IF;

               wprecseg := gar.precseg / 100;   -- Bug 21715 - APD - 08/05/2012
               wipridev := gar.iprianu * wprorrata;   -- Bug 21715 - APD - 08/05/2012
               wpestab := f_round(GREATEST(wipridev * wprecseg * v_rel_prim,
                                           v_lim_min * wipridev),
                                  pcmoneda);   -- Bug 21715 - APD - 08/05/2012
               --wpestab := f_round(gar.iprianu * wprorrata *(gar.precseg / 100), pcmoneda);
               wpreaseg := f_round(wpestab *(wtotreaseg / 100) *(1 - wpnrea / 100), pcmoneda);

               BEGIN
                  IF pmodo = 'R' THEN
                     INSERT INTO pestab
                                 (cempres, fcalcul, sproces, cramdgs, cramo,
                                  cmodali, ctipseg, ccolect, sseguro,
                                  cgarant, ipestab, ipreaseg, cerror, nriesgo,
                                  nmovimi, ibase)
                          VALUES (reg.cempres, aux_factual, psproces, reg.cramdgs, reg.cramo,
                                  reg.cmodali, reg.ctipseg, reg.ccolect, reg.sseguro,
                                  gar.cgarant, wpestab, wpreaseg, werror, gar.nriesgo,
                                  gar.nmovimi, NULL);
                  ELSIF pmodo = 'P' THEN
                     INSERT INTO pestab_previo
                                 (cempres, fcalcul, sproces, cramdgs, cramo,
                                  cmodali, ctipseg, ccolect, sseguro,
                                  cgarant, ipestab, ipreaseg, cerror, nriesgo,
                                  nmovimi, ibase)
                          VALUES (reg.cempres, aux_factual, psproces, reg.cramdgs, reg.cramo,
                                  reg.cmodali, reg.ctipseg, reg.ccolect, reg.sseguro,
                                  gar.cgarant, wpestab, wpreaseg, werror, gar.nriesgo,
                                  gar.nmovimi, NULL);
                  END IF;
               EXCEPTION
                  WHEN OTHERS THEN
                     num_err := 103869;
                  -- Aunque se produzca un error queremos continuar con los siguientes.
               --EXIT;
               END;
            END LOOP;

            IF num_err != 0 THEN
               ROLLBACK;
               p_literal2(num_err, pcidioma, ttexto);
               num_err := f_proceslin(psproces, ttexto || ' - PESTAB', reg.sseguro, nlin);
               nlin := NULL;
               conta_err := conta_err + 1;
            END IF;
         ELSE
            p_literal2(num_err, pcidioma, ttexto);
            num_err := f_proceslin(psproces, ttexto || ' - PESTAB', reg.sseguro, nlin);
            nlin := NULL;
            conta_err := conta_err + 1;
         END IF;

         COMMIT;
      END LOOP;

      DELETE FROM pestab
            WHERE ipestab <= 0
              AND sproces = psproces;

      COMMIT;
      RETURN conta_err;
   END f_commit_calcul_pestab;

-----------------------------------------------------------------------
-- IBNR
-----------------------------------------------------------------------
   FUNCTION f_commit_calcul_ibnr(
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
      num_err        NUMBER;
      conta_err      NUMBER := 0;
      provisio       NUMBER;
      vicompan       NUMBER;
   BEGIN
      FOR reg IN c_siniestros_ibnr(aux_factual, cempres) LOOP
         -- Esta función tiene en cuenta todos los pagos, tanto si están valorados como
         -- si no lo están.  El libor de siniestros, sólo tiene en cuenta los pagos
         -- que tienen valoración.
         num_err := f_provisio(reg.nsinies, provisio, aux_factual, NULL, NULL);

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

                  --FI BUG10328 - 18/06/2009 - DCT -
                  IF pmodo = 'R' THEN
                     INSERT INTO ibnr
                                 (cempres, fcalcul, sproces, cramdgs, cramo,
                                  cmodali, ctipseg, ccolect, sseguro,
                                  nsinies, iibnrsd,
                                  iibnrrc, cerror)
                          VALUES (reg.cempres, aux_factual, psproces, reg.cramdgs, reg.cramo,
                                  reg.cmodali, reg.ctipseg, reg.ccolect, reg.sseguro,
                                  reg.nsinies, f_round((provisio * 5 / 100), pcmoneda),
                                  f_round((vicompan * 5 / 100), pcmoneda), 0);
                  ELSIF pmodo = 'P' THEN
                     INSERT INTO ibnr_previo
                                 (cempres, fcalcul, sproces, cramdgs, cramo,
                                  cmodali, ctipseg, ccolect, sseguro,
                                  nsinies, iibnrsd,
                                  iibnrrc, cerror)
                          VALUES (reg.cempres, aux_factual, psproces, reg.cramdgs, reg.cramo,
                                  reg.cmodali, reg.ctipseg, reg.ccolect, reg.sseguro,
                                  reg.nsinies, f_round((provisio * 5 / 100), pcmoneda),
                                  f_round((vicompan * 5 / 100), pcmoneda), 0);
                  END IF;
               EXCEPTION
                  WHEN OTHERS THEN
                     ROLLBACK;
                     ttexto := f_axis_literales(103869, pcidioma);
                     num_err := f_proceslin(psproces, ttexto || ' IBNR', reg.sseguro, nlin);
                     conta_err := conta_err + 1;
                     nlin := NULL;
                     COMMIT;
               END;

               COMMIT;
            END IF;
         END IF;
      END LOOP;

      RETURN conta_err;
   END f_commit_calcul_ibnr;

-----------------------------------------------------------------------
-- PPLP
-----------------------------------------------------------------------
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
      num_err        NUMBER;
      conta_err      NUMBER := 0;
      provisio_tmp   NUMBER := 0;
      provisio       NUMBER := 0;
      vicompan       NUMBER;
      --Bug.: 21715 - 28/03/2012 - ICV
      v_ippl         NUMBER := 0;
      v_ippp         NUMBER := 0;
      v_restot       NUMBER := 0;
      w_cmoncon      parempresas.nvalpar%TYPE
                                     := pac_parametros.f_parempresa_n(cempres, 'MONEDACONTAB'); --BUG40962-XVM


      CURSOR c1(pnsinies NUMBER, pfecha DATE) IS
         SELECT stm.cestval, stm.cestpag,
                DECODE(stp.ctippag, 7, -stp.isinret, stp.isinret) importe, stm.sidepag,
                stm.fefepag
           FROM sin_tramita_pago stp, sin_tramita_movpago stm
          WHERE stp.nsinies = pnsinies
            AND stp.sidepag = stm.sidepag
            AND stm.nmovpag = (SELECT MAX(nmovpag)
                                 FROM sin_tramita_movpago stm2
                                WHERE stm.sidepag = stm2.sidepag)
            AND TRUNC(stm.fefepag) < pfecha;
   BEGIN
      FOR reg IN c_siniestros_pplp(aux_factual, cempres) LOOP
         --Buscamos las reservas del siniestro teniendo en cuenta el estado de los pagos para restarlos o no
         --Lo calculamos de la misma manera que se hace en reaseguro
         provisio_tmp := 0;
         provisio := 0;
         FOR r_gar IN (SELECT UNIQUE cgarant
                                FROM valorasini
                               WHERE nsinies = reg.nsinies
                                 AND NVL(pac_parametros.f_parempresa_n(cempres, 'MODULO_SINI'),
                                         0) = 0
                       UNION
                       SELECT UNIQUE cgarant
                                FROM sin_tramita_reserva
                               WHERE nsinies = reg.nsinies
                                 AND NVL(pac_parametros.f_parempresa_n(cempres, 'MODULO_SINI'),
                                         0) = 1
                                 ) LOOP
            --BUG40962-XVM-Inicio
            num_err := f_provisiogar(reg.nsinies, r_gar.cgarant, provisio_tmp, aux_factual,1);
            --BUG40962--XVM-Fin
            provisio := provisio + provisio_tmp;
         END LOOP;

         IF NVL(pac_parametros.f_parempresa_n(cempres, 'MODULO_SINI'), 0) = 0 THEN
            v_ippl := 0;
            v_ippp := 0;
         ELSE
            --Exclusivo para el modulo nuevo volvemos a llamar a la f_provisio para calcular el importe de la reserva total del siniestro
            num_err := f_provisio(reg.nsinies, v_restot, aux_factual, 1);

            IF num_err <> 0 THEN
               v_ippl := v_restot;
               v_ippp := 0;

               FOR rc IN c1(reg.nsinies, aux_factual) LOOP
                  IF rc.cestpag IN(1, 2) THEN   --Aceptado pagado
                     --Pendientes de liquidar (Reserva total - Pagos Aceptados / Pagados
                     v_ippl := f_round(v_ippl, w_cmoncon) - f_round(rc.importe, w_cmoncon);

                     IF rc.cestpag = 2 THEN
                        --Pendiente de pagar (Pagos pagados)
                        v_ippp := f_round(rc.importe, w_cmoncon);
                     END IF;
                  END IF;
               END LOOP;
            END IF;
         END IF;

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
                  -- Bug 0026890 - 06/05/2013 - DCG - Ini
                  SELECT NVL(SUM(icompan_moncon), SUM(icompan))
                    -- Bug 0026890 - 06/05/2013 - DCG - Fi
                  INTO   vicompan
                    FROM liqresreaaux
                   WHERE nsinies = reg.nsinies
                     AND fcierre = aux_factual;

                  -- 36816.NMM
                  provisio := f_round(provisio, w_cmoncon);

                  --FI BUG10328 - 18/06/2009 - DCT -
                  IF pmodo = 'R' THEN
                     INSERT INTO ptpplp
                                 (cempres, fcalcul, sproces, cramdgs, cramo,
                                  cmodali, ctipseg, ccolect, sseguro,
                                  nsinies, ipplpsd, ipplprc, cerror, ippl, ippp)
                          VALUES (reg.cempres, aux_factual, psproces, reg.cramdgs, reg.cramo,
                                  reg.cmodali, reg.ctipseg, reg.ccolect, reg.sseguro,
                                  reg.nsinies, provisio, NVL(vicompan, 0), 0, v_ippl, v_ippp);
                  ELSIF pmodo = 'P' THEN
                     INSERT INTO ptpplp_previo
                                 (cempres, fcalcul, sproces, cramdgs, cramo,
                                  cmodali, ctipseg, ccolect, sseguro,
                                  nsinies, ipplpsd, ipplprc, cerror, ippl, ippp)
                          VALUES (reg.cempres, aux_factual, psproces, reg.cramdgs, reg.cramo,
                                  reg.cmodali, reg.ctipseg, reg.ccolect, reg.sseguro,
                                  reg.nsinies, provisio, NVL(vicompan, 0), 0, v_ippl, v_ippp);
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
----------------------------------------------------------------------------
-- IBNR_RAM
-- Se cambia la antigua función de mdp por nueva que va a utilizar prb
-- Calculo realizado para diferentes Agrupaciones de producto
----------------------------------------------------------------------------
   FUNCTION f_commit_calcul_ibnr_ram(
      pcempres IN NUMBER,
      aux_factual IN DATE,
      psproces IN NUMBER,
      pcidioma IN NUMBER,
      pcmoneda IN NUMBER,
      pmodo IN VARCHAR2 DEFAULT 'R')
      RETURN NUMBER IS
      --
      ttexto         VARCHAR2(400);
      nlin           NUMBER;
      num_err        NUMBER;
      conta_err      NUMBER := 0;
      n_anu          NUMBER(4);
      d_hoy          DATE;
      n_traza        NUMBER;
      --
      n_num0         NUMBER;   -- numero siniestros
      n_num1         NUMBER;
      n_num2         NUMBER;
      n_num3         NUMBER;
      n_imp0         NUMBER;   -- importe siniestros
      n_imp1         NUMBER;
      n_imp2         NUMBER;
      n_imp3         NUMBER;
      n_med1         NUMBER;   -- coste medio
      n_med2         NUMBER;
      n_med3         NUMBER;
      n_pt_nt        NUMBER;   -- importe primas anualidad actual
      n_qt_ct        NUMBER;   -- coste medio declarado anulidad, de la anualidad actual.
      n_numerador_nt NUMBER;   -- NT
      n_denominador_nt NUMBER;
      n_cociente_nt  NUMBER;
      n_resultado_nt1 NUMBER;
      n_resultado_nt2 NUMBER;
      n_resultado_nt3 NUMBER;
      n_numerador_ct NUMBER;   -- CT
      n_denominador_ct NUMBER;
      n_cociente_ct  NUMBER;
      n_resultado_ct1 NUMBER;
      n_resultado_ct2 NUMBER;
      n_resultado_ct3 NUMBER;
      --
      n_calculo      NUMBER;
      n_agrupacion_a1 NUMBER;
      n_agrupacion_a2 NUMBER;
      n_agrupacion_a3 NUMBER;
      n_agrupaciontot NUMBER;
      n_ibnr_inicio_ejer_1 NUMBER;
      n_ibnr_inicio_ejer_2 NUMBER;
      n_ibnr_inicio_ejer_3 NUMBER;
      n_ibnr_inicio_ejertot NUMBER;
      n_abierto_ejeant_1 NUMBER;
      n_abierto_ejeant_2 NUMBER;
      n_abierto_ejeant_3 NUMBER;
      n_abierto_ejeanttot NUMBER;
      n_global_porcen NUMBER;
      n_global_porcen_aplicado NUMBER;
      n_pendiente_declaracion NUMBER;
      n_distribucion_a1 NUMBER;
      n_distribucion_a2 NUMBER;
      n_distribucion_a3 NUMBER;
      n_insuficiencia_a1 NUMBER;
      n_insuficiencia_a2 NUMBER;
      n_insuficiencia_a3 NUMBER;
      n_total_porcentaje_a1 NUMBER;
      n_total_porcentaje_a2 NUMBER;
      n_total_porcentaje_a3 NUMBER;
      n_total_porcentajetot NUMBER;
      n_sobredotacion_a1 NUMBER;
      n_sobredotacion_a2 NUMBER;
      n_sobredotacion_a3 NUMBER;
      n_ibnr_final_a1 NUMBER;
      n_ibnr_final_a2 NUMBER;
      n_ibnr_final_a3 NUMBER;
      n_auxval_a     NUMBER;
      n_auxval_b     NUMBER;
      n_auxval_c     NUMBER;

      --
      CURSOR c1 IS
         SELECT DISTINCT cvalpar agrupa
                    FROM parproductos
                   WHERE cparpro = 'AGRUPA_IBNR';

      --
      -- Abiertos en ejercicio actual y que tienen fecha siniestro fechas anteriores
      CURSOR c2(pcemp NUMBER, pcagr NUMBER, pcanu NUMBER) IS
         SELECT sn.nsinies
           FROM sin_siniestro sn, sin_movsiniestro sm, seguros s, parproductos p
          WHERE p.cparpro = 'AGRUPA_IBNR'
            AND p.cvalpar = pcagr
            AND s.sproduc = p.sproduc
            AND s.cempres = pcemp
            AND sn.sseguro = s.sseguro
            AND sn.nsinies = sm.nsinies
            AND sn.fsinies < TO_DATE('01-01-' || TO_CHAR(pcanu), 'dd-mm-yyyy')
            AND sm.cestsin IN(0, 4)
            AND sm.nmovsin =
                  (SELECT MAX(nmovsin)
                     FROM sin_movsiniestro sm2
                    WHERE sm.nsinies = sm2.nsinies
                      AND TO_NUMBER(TO_CHAR(festsin, 'yyyy')) = pcanu)   --Siniestros abiertos en el año
            AND EXISTS(SELECT '1'
                         FROM sin_movsiniestro sm2
                        WHERE sm.nsinies = sm2.nsinies
                          AND sm.cestsin NOT IN(0, 4)
                          AND TO_NUMBER(TO_CHAR(festsin, 'yyyy')) = pcanu + 1);   --Ya no este abierto o reabierto a lo largo del año siguiente
   --
   BEGIN
      n_traza := 100;
      -- v_anyos_hist := NVL(pac_parametros.f_parempresa_n(pcempres, 'ANYOS_IBNR_RAM_HIST'), 3);
      n_anu := TO_NUMBER(TO_CHAR(aux_factual, 'yyyy'));
      d_hoy := f_sysdate;
      n_traza := 110;
      n_resultado_nt1 := 0;
      n_resultado_nt2 := 0;
      n_resultado_nt3 := 0;
      n_resultado_ct1 := 0;
      n_resultado_ct2 := 0;
      n_resultado_ct3 := 0;
      n_agrupacion_a1 := 0;
      n_agrupacion_a2 := 0;
      n_agrupacion_a3 := 0;
      n_ibnr_inicio_ejer_1 := 0;
      n_ibnr_inicio_ejer_2 := 0;
      n_ibnr_inicio_ejer_3 := 0;
      n_abierto_ejeant_1 := 0;
      n_abierto_ejeant_2 := 0;
      n_abierto_ejeant_3 := 0;
      n_traza := 120;

      FOR f1 IN c1 LOOP
---------------------------------------------------
---------------------------------------------------
-- PRIMERA PARTE: CALCULOS AGRUPACIONES PRODUCTO --
---------------------------------------------------
---------------------------------------------------
         n_traza := 130;
         -- obtencion de datos
         n_num1 := NVL(pac_subtablas.f_vsubtabla(-1, 10, 333, 2, f1.agrupa, 1, n_anu - 1,
                                                 NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                                                 d_hoy),
                       0);
         n_num2 := NVL(pac_subtablas.f_vsubtabla(-1, 10, 333, 2, f1.agrupa, 1, n_anu - 2,
                                                 NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                                                 d_hoy),
                       0);
         n_num3 := NVL(pac_subtablas.f_vsubtabla(-1, 10, 333, 2, f1.agrupa, 1, n_anu - 3,
                                                 NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                                                 d_hoy),
                       0);
         n_numerador_nt := n_num1 + n_num2 + n_num3;
         n_traza := 140;
         n_imp1 := NVL(pac_subtablas.f_vsubtabla(-1, 10, 333, 1, f1.agrupa, 1, n_anu - 1,
                                                 NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                                                 d_hoy),
                       0);
         n_imp2 := NVL(pac_subtablas.f_vsubtabla(-1, 10, 333, 1, f1.agrupa, 1, n_anu - 2,
                                                 NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                                                 d_hoy),
                       0);
         n_imp3 := NVL(pac_subtablas.f_vsubtabla(-1, 10, 333, 1, f1.agrupa, 1, n_anu - 3,
                                                 NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                                                 d_hoy),
                       0);
         n_traza := 150;
         n_numerador_ct := 0;

         IF n_num1 <> 0 THEN
            n_numerador_ct := n_numerador_ct +(n_imp1 / n_num1);
         END IF;

         IF n_num2 <> 0 THEN
            n_numerador_ct := n_numerador_ct +(n_imp2 / n_num2);
         END IF;

         IF n_num3 <> 0 THEN
            n_numerador_ct := n_numerador_ct +(n_imp3 / n_num3);
         END IF;

         n_traza := 160;
         n_pt_nt := NVL(pac_subtablas.f_vsubtabla(-1, 10, 333, 1, f1.agrupa, 2, n_anu - 0,
                                                  NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                                                  d_hoy),
                        0);
         n_imp1 := NVL(pac_subtablas.f_vsubtabla(-1, 10, 333, 1, f1.agrupa, 2, n_anu - 1, NULL,
                                                 NULL, NULL, NULL, NULL, NULL, NULL, d_hoy),
                       0);
         n_imp2 := NVL(pac_subtablas.f_vsubtabla(-1, 10, 333, 1, f1.agrupa, 2, n_anu - 2, NULL,
                                                 NULL, NULL, NULL, NULL, NULL, NULL, d_hoy),
                       0);
         n_imp3 := NVL(pac_subtablas.f_vsubtabla(-1, 10, 333, 1, f1.agrupa, 2, n_anu - 3, NULL,
                                                 NULL, NULL, NULL, NULL, NULL, NULL, d_hoy),
                       0);
         n_denominador_nt := n_num1 + n_num2 + n_num3;
         n_traza := 170;
         n_imp0 := NVL(pac_subtablas.f_vsubtabla(-1, 10, 333, 1, f1.agrupa, 3, n_anu - 0, NULL,
                                                 NULL, NULL, NULL, NULL, NULL, NULL, d_hoy),
                       0);
         n_imp1 := NVL(pac_subtablas.f_vsubtabla(-1, 10, 333, 1, f1.agrupa, 3, n_anu - 1, NULL,
                                                 NULL, NULL, NULL, NULL, NULL, NULL, d_hoy),
                       0);
         n_imp2 := NVL(pac_subtablas.f_vsubtabla(-1, 10, 333, 1, f1.agrupa, 3, n_anu - 2, NULL,
                                                 NULL, NULL, NULL, NULL, NULL, NULL, d_hoy),
                       0);
         n_imp3 := NVL(pac_subtablas.f_vsubtabla(-1, 10, 333, 1, f1.agrupa, 3, n_anu - 3, NULL,
                                                 NULL, NULL, NULL, NULL, NULL, NULL, d_hoy),
                       0);
         n_traza := 180;
         n_num0 := NVL(pac_subtablas.f_vsubtabla(-1, 10, 333, 2, f1.agrupa, 3, n_anu - 0, NULL,
                                                 NULL, NULL, NULL, NULL, NULL, NULL, d_hoy),
                       0);
         n_num1 := NVL(pac_subtablas.f_vsubtabla(-1, 10, 333, 2, f1.agrupa, 3, n_anu - 1, NULL,
                                                 NULL, NULL, NULL, NULL, NULL, NULL, d_hoy),
                       0);
         n_num2 := NVL(pac_subtablas.f_vsubtabla(-1, 10, 333, 2, f1.agrupa, 3, n_anu - 2, NULL,
                                                 NULL, NULL, NULL, NULL, NULL, NULL, d_hoy),
                       0);
         n_num3 := NVL(pac_subtablas.f_vsubtabla(-1, 10, 333, 2, f1.agrupa, 3, n_anu - 3, NULL,
                                                 NULL, NULL, NULL, NULL, NULL, NULL, d_hoy),
                       0);
         n_traza := 190;
         n_denominador_ct := 0;

         IF n_num1 <> 0 THEN
            n_denominador_ct := n_denominador_ct +(n_imp1 / n_num1);
         END IF;

         IF n_num2 <> 0 THEN
            n_denominador_ct := n_denominador_ct +(n_imp2 / n_num2);
         END IF;

         IF n_num3 <> 0 THEN
            n_denominador_ct := n_denominador_ct +(n_imp3 / n_num3);
         END IF;

         n_traza := 200;

         IF n_num0 <> 0 THEN
            n_qt_ct :=(n_imp0 / n_num0);
         ELSE
            n_qt_ct := 0;
         END IF;

         -- Calculos
         n_traza := 210;

         IF n_denominador_nt <> 0 THEN
            n_cociente_nt := n_numerador_nt / n_denominador_nt;
         ELSE
            n_cociente_nt := 0;
         END IF;

         n_traza := 220;

         IF n_denominador_ct <> 0 THEN
            n_cociente_ct := n_numerador_ct / n_denominador_ct;
         ELSE
            n_cociente_ct := 0;
         END IF;

         n_traza := 230;

         IF f1.agrupa = 1 THEN
            n_resultado_nt1 := n_cociente_nt * n_pt_nt;
            n_resultado_ct1 := n_cociente_ct * n_qt_ct;
            n_agrupacion_a1 := n_resultado_nt1 * n_resultado_ct1;
         ELSIF f1.agrupa = 2 THEN
            n_resultado_nt2 := n_cociente_nt * n_pt_nt;
            n_resultado_ct2 := n_cociente_ct * n_qt_ct;
            n_agrupacion_a2 := n_resultado_nt2 * n_resultado_ct2;
         ELSIF f1.agrupa = 3 THEN
            n_resultado_nt3 := n_cociente_nt * n_pt_nt;
            n_resultado_ct3 := n_cociente_ct * n_qt_ct;
            n_agrupacion_a3 := n_resultado_nt3 * n_resultado_ct3;
         END IF;

---------------------------------------
---------------------------------------
-- SEGUNDA PARTE: SINIEST. REAL IBNR --
---------------------------------------
---------------------------------------

         -- IBNR DOTADO COMIENZO EJERCICIO
         n_traza := 240;

         SELECT NVL(SUM(NVL(c.iibnrsd, 0)), 0)
           INTO n_calculo
           FROM parproductos a, seguros b, ibnr c
          WHERE a.cparpro = 'AGRUPA_IBNR'
            AND a.cvalpar = f1.agrupa
            AND b.cempres = pcempres
            AND b.sproduc = a.sproduc
            AND c.cramo = b.cramo
            AND c.cmodali = b.cmodali
            AND c.ctipseg = b.ctipseg
            AND c.ccolect = b.ccolect
            AND c.fcalcul = TO_DATE('31-12-' || TO_CHAR(n_anu - 1), 'dd-mm-yyyy');

         n_traza := 250;

         IF f1.agrupa = 1 THEN
            n_ibnr_inicio_ejer_1 := n_calculo;
         ELSIF f1.agrupa = 2 THEN
            n_ibnr_inicio_ejer_2 := n_calculo;
         ELSIF f1.agrupa = 3 THEN
            n_ibnr_inicio_ejer_3 := n_calculo;
         END IF;

         -- buscar SINIESTROS ABIERTOS EN anualidad DE EJ. ANTERIORES
         n_traza := 260;

         FOR f2 IN c2(pcempres, f1.agrupa, n_anu) LOOP
            n_traza := 270;
            num_err := f_provisio(f2.nsinies, n_calculo, aux_factual);

            IF num_err <> 0 THEN
               ttexto := '(l=' || n_traza || ') ' || f_axis_literales(151026, pcidioma);
               num_err := f_proceslin(psproces, ttexto, f2.nsinies, nlin);
               conta_err := conta_err + 1;
               nlin := NULL;
            ELSE
               n_traza := 280;

               IF f1.agrupa = 1 THEN
                  n_abierto_ejeant_1 := n_abierto_ejeant_1 + NVL(n_calculo, 0);
               ELSIF f1.agrupa = 2 THEN
                  n_abierto_ejeant_2 := n_abierto_ejeant_2 + NVL(n_calculo, 0);
               ELSIF f1.agrupa = 3 THEN
                  n_abierto_ejeant_3 := n_abierto_ejeant_3 + NVL(n_calculo, 0);
               END IF;
            END IF;
         END LOOP;
      END LOOP;

      n_traza := 290;
      ttexto := NULL;   -- Aqui guardaremos claves para tener info en caso de error inesperado

      IF conta_err = 0 THEN
         n_traza := 300;
         n_agrupaciontot := n_agrupacion_a1 + n_agrupacion_a2 + n_agrupacion_a3;
         n_ibnr_inicio_ejertot := n_ibnr_inicio_ejer_1 + n_ibnr_inicio_ejer_2
                                  + n_ibnr_inicio_ejer_3;
         n_abierto_ejeanttot := n_abierto_ejeant_1 + n_abierto_ejeant_2 + n_abierto_ejeant_3;
         n_traza := 310;

         IF n_ibnr_inicio_ejertot = 0 THEN
            n_global_porcen := 0;
         ELSE
            n_global_porcen := (n_abierto_ejeanttot / n_ibnr_inicio_ejertot) - 1;
         END IF;

         IF n_global_porcen < 0 THEN
            n_global_porcen := 0;
         END IF;

         n_traza := 320;
         n_global_porcen_aplicado := n_agrupaciontot *(1 + n_global_porcen);
         n_pendiente_declaracion := n_global_porcen_aplicado - n_agrupaciontot;
         n_traza := 330;

         IF n_agrupaciontot = 0 THEN
            n_distribucion_a1 := 0;
         ELSE
            n_distribucion_a1 := n_agrupacion_a1 / n_agrupaciontot;
            n_distribucion_a2 := n_agrupacion_a2 / n_agrupaciontot;
            n_distribucion_a3 := n_agrupacion_a3 / n_agrupaciontot;
         END IF;

         n_traza := 340;

         IF NVL(n_abierto_ejeant_1, 0) > NVL(n_agrupacion_a1, 0) THEN
            n_insuficiencia_a1 := 1;
         ELSE
            n_insuficiencia_a1 := 0;
         END IF;

         IF NVL(n_abierto_ejeant_2, 0) > NVL(n_agrupacion_a2, 0) THEN
            n_insuficiencia_a2 := 1;
         ELSE
            n_insuficiencia_a2 := 0;
         END IF;

         IF NVL(n_abierto_ejeant_3, 0) > NVL(n_agrupacion_a3, 0) THEN
            n_insuficiencia_a3 := 1;
         ELSE
            n_insuficiencia_a3 := 0;
         END IF;

         n_traza := 350;
         n_total_porcentaje_a1 := n_distribucion_a1 * n_insuficiencia_a1;
         n_total_porcentaje_a2 := n_distribucion_a2 * n_insuficiencia_a2;
         n_total_porcentaje_a3 := n_distribucion_a3 * n_insuficiencia_a3;
         n_total_porcentajetot := n_distribucion_a1 + n_total_porcentaje_a2
                                  + n_total_porcentaje_a3;
         n_traza := 360;
         n_sobredotacion_a1 := (n_pendiente_declaracion * n_total_porcentaje_a1)
                               / n_total_porcentajetot;
         n_sobredotacion_a2 := (n_pendiente_declaracion * n_total_porcentaje_a2)
                               / n_total_porcentajetot;
         n_sobredotacion_a3 := (n_pendiente_declaracion * n_total_porcentaje_a3)
                               / n_total_porcentajetot;
         n_traza := 370;
         n_ibnr_final_a1 := n_sobredotacion_a1 + n_agrupacion_a1;
         n_ibnr_final_a2 := n_sobredotacion_a2 + n_agrupacion_a2;
         n_ibnr_final_a3 := n_sobredotacion_a3 + n_agrupacion_a3;
----------------------------------------
----------------------------------------
-- TERCERA PARTE: GUARDAR INFORMACION --
----------------------------------------
----------------------------------------
         n_traza := 380;

         BEGIN
            IF pmodo = 'R' THEN
               FOR f1 IN c1 LOOP
                  ttexto := 'a=' || f1.agrupa;

                  IF f1.agrupa = 1 THEN
                     n_traza := 390;
                     n_auxval_a := n_ibnr_final_a1;
                     n_auxval_b := n_resultado_nt1;
                     n_auxval_c := n_resultado_ct1;
                  ELSIF f1.agrupa = 2 THEN
                     n_traza := 400;
                     n_auxval_a := n_ibnr_final_a2;
                     n_auxval_b := n_resultado_nt2;
                     n_auxval_c := n_resultado_ct2;
                  ELSIF f1.agrupa = 3 THEN
                     n_traza := 410;
                     n_auxval_a := n_ibnr_final_a3;
                     n_auxval_b := n_resultado_nt3;
                     n_auxval_c := n_resultado_ct3;
                  ELSE
                     n_traza := 420;
                     n_auxval_a := 0;
                     n_auxval_b := 0;
                     n_auxval_c := 0;
                  END IF;

                  IF NVL(n_auxval_b, 0) <> 0
                     OR NVL(n_auxval_c, 0) <> 0 THEN
                     n_traza := 430;

                     INSERT INTO ibnr_ram
                                 (cempres, fcalcul, sproces, cramo, iibnrsd, iibnrrc,
                                  fnt, fct, cerror, sproduc, cmoneda, fcambio, itasa,
                                  iibnrsd_moncon, iibnrrc_moncon, cagrupa)
                          VALUES (pcempres, aux_factual, psproces, 0, n_auxval_a, 0,
                                  n_auxval_b, n_auxval_c, 0, f1.agrupa, NULL, NULL, NULL,
                                  NULL, NULL, f1.agrupa);
                  END IF;
               END LOOP;
            ELSIF pmodo = 'P' THEN
               n_traza := 440;

               FOR f1 IN c1 LOOP
                  ttexto := 'a=' || f1.agrupa;

                  IF f1.agrupa = 1 THEN
                     n_traza := 450;
                     n_auxval_a := n_ibnr_final_a1;
                     n_auxval_b := n_resultado_nt1;
                     n_auxval_c := n_resultado_ct1;
                  ELSIF f1.agrupa = 2 THEN
                     n_traza := 460;
                     n_auxval_a := n_ibnr_final_a2;
                     n_auxval_b := n_resultado_nt2;
                     n_auxval_c := n_resultado_ct2;
                  ELSIF f1.agrupa = 3 THEN
                     n_traza := 470;
                     n_auxval_a := n_ibnr_final_a3;
                     n_auxval_b := n_resultado_nt3;
                     n_auxval_c := n_resultado_ct3;
                  ELSE
                     n_traza := 480;
                     n_auxval_a := 0;
                     n_auxval_b := 0;
                     n_auxval_c := 0;
                  END IF;

                  IF NVL(n_auxval_b, 0) <> 0
                     OR NVL(n_auxval_c, 0) <> 0 THEN
                     n_traza := 490;

                     INSERT INTO ibnr_ram_previo
                                 (cempres, fcalcul, sproces, cramo, iibnrsd, iibnrrc,
                                  fnt, fct, cerror, sproduc, cmoneda, fcambio, itasa,
                                  iibnrsd_moncon, iibnrrc_moncon, cagrupa)
                          VALUES (pcempres, aux_factual, psproces, 0, n_auxval_a, 0,
                                  n_auxval_b, n_auxval_c, 0, f1.agrupa, NULL, NULL, NULL,
                                  NULL, NULL, f1.agrupa);
                  END IF;
               END LOOP;
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               ROLLBACK;
               num_err := f_proceslin(psproces,
                                      f_axis_literales(103869, pcidioma) || ' IBNR_RAM',
                                      ttexto, nlin);
               conta_err := conta_err + 1;
               nlin := NULL;
               COMMIT;
         END;

         n_traza := 500;
         COMMIT;
      END IF;

      n_traza := 510;
      RETURN conta_err;
   EXCEPTION
      WHEN OTHERS THEN
         ROLLBACK;
         num_err := f_proceslin(psproces, n_traza || '-' || SQLCODE || '-' || SQLERRM, ttexto,
                                nlin);
         conta_err := conta_err + 1;
         nlin := NULL;
         COMMIT;
         RETURN conta_err;
   END f_commit_calcul_ibnr_ram;

   ----------------------------------------------------------------------------
-- IBNER
----------------------------------------------------------------------------
-- Bug 21715 - APD - se crea la funcion
   FUNCTION f_commit_calcul_ibner(
      pcempres IN NUMBER,
      aux_factual IN DATE,
      psproces IN NUMBER,
      pcidioma IN NUMBER,
      pcmoneda IN NUMBER,
      pmodo IN VARCHAR2 DEFAULT 'R')
      RETURN NUMBER IS
      aux_fefeini    DATE;
      ttexto         VARCHAR2(60);
      nlin           NUMBER;
      num_err        NUMBER;
      conta_err      NUMBER := 0;

      CURSOR c_ramo IS
         SELECT cramo
           FROM codiram cr
          WHERE cr.cempres = pcempres;

      v_anyos_hist   NUMBER;
      v_anyos_cont   NUMBER;
      v_por_def_ibner NUMBER;
      v_por_ibner_prod NUMBER;
      v_iibner_ant   ibner.iibner%TYPE := 0;   -- Importe IBNER
      v_iibner_act   ibner.iibner%TYPE := 0;   -- Importe IBNER
      v_por_ibner    NUMBER;
      v_cont         NUMBER;
      v_cont_ibnr_ram NUMBER;
      v_sproduc      NUMBER;
   BEGIN
      -- Periodicidad de cálculo anual
      IF TO_CHAR(aux_factual, 'DD/MM') = '31/12' THEN
         -- Se busca el porcentaje por defecto para el cálculo de la provision de IBNER
         -- en el caso que no se pueda obtener el porcentaje histórico debido a que no
         -- existen datos antiguos
         v_por_def_ibner := NVL(pac_parametros.f_parempresa_n(pcempres, 'POR_DEF_IBNER'), 0);

         IF v_por_def_ibner = 0 THEN
            v_por_def_ibner := 1;
         ELSE
            v_por_def_ibner := v_por_def_ibner / 100;
         END IF;

         -- Se busca el número de años del histórico de IBNR que se utilizan para calcular
         -- el porcentaje que se aplica para el cálculo de la Provisión de IBNER
         v_anyos_hist := NVL(pac_parametros.f_parempresa_n(pcempres, 'ANYOS_IBNER_HIST'), 5);

         FOR rc IN c_ramo LOOP
            v_iibner_ant := 0;
            v_por_ibner := 0;
            v_anyos_cont := v_anyos_hist;

            --Buscamos el Importe IBNR actual
            IF pmodo = 'R' THEN
               SELECT SUM(iibnrsd)
                 INTO v_iibner_act
                 FROM ibnr_ram i
                WHERE cempres = pcempres
                  --AND TRUNC(i.fcalcul) = aux_factual
                  AND TO_DATE('3112' || TO_CHAR(i.fcalcul, 'yyyy'), 'DDMMYYYY') =
                                    TO_DATE('3112' || TO_CHAR(aux_factual, 'yyyy'), 'DDMMYYYY')
                  AND cramo = rc.cramo;
            ELSIF pmodo = 'P' THEN
               SELECT SUM(iibnrsd)
                 INTO v_iibner_act
                 FROM ibnr_ram_previo i
                WHERE cempres = pcempres
                  --AND TRUNC(i.fcalcul) = aux_factual
                  AND TO_DATE('3112' || TO_CHAR(i.fcalcul, 'yyyy', 'DDMMYYYY')) =
                                    TO_DATE('3112' || TO_CHAR(aux_factual, 'yyyy'), 'DDMMYYYY')
                  AND cramo = rc.cramo;
            END IF;

            v_cont_ibnr_ram := 0;

            WHILE(v_anyos_cont <> 0) LOOP
               --Buscamos el Importe IBNR, tantos años como indiquen
               -- Al ser años anteriores (no año actual) ya sea pmodo = 'P' o 'R' se busca de la ppnc (real)
               SELECT SUM(iibnrsd), COUNT(1)
                 INTO v_iibner_ant, v_cont
                 FROM ibnr_ram i
                WHERE cempres = pcempres
                  AND TO_DATE('3112' || TO_CHAR(i.fcalcul, 'yyyy'), 'DDMMYYYY') =
                        TO_DATE('3112' || TO_CHAR(aux_factual, 'yyyy') - v_anyos_cont,
                                'DDMMYYYY')
                  AND cramo = rc.cramo;

               IF v_cont > 0 THEN
                  -- Se busca si hay un porcetaje definido por producto
                  v_por_ibner_prod := NVL(pac_parametros.f_parproducto_n(v_sproduc,
                                                                         'POR_IBNER'),
                                          0);

                  IF v_por_ibner_prod > 0 THEN
                     v_por_ibner := NVL(v_por_ibner, 0) + v_por_ibner_prod / 100;
                  ELSE
                     v_por_ibner := NVL(v_por_ibner, 0)
                                    +((v_iibner_act - v_iibner_ant) / v_iibner_ant);
                  END IF;

                  v_cont_ibnr_ram := v_cont_ibnr_ram + 1;
               END IF;

               --Contador de años
               v_anyos_cont := v_anyos_cont - 1;
            END LOOP;

            -- hay historico de provisiones ibnr
            IF v_cont_ibnr_ram > 0 THEN
               -- Media aritmetica
               v_por_ibner := v_por_ibner / v_cont_ibnr_ram;
            ELSE   -- no hay historico
               -- Si para algún ramo se carece  de la necesaria experiencia, se dota esta
               -- provisión aplicando un porcentaje del 5 por 100 a la provisión de prestaciones
               -- pendientes de liquidación o pago del seguro directo
               v_por_ibner := v_por_def_ibner;
            END IF;

            IF NVL(v_por_ibner, 0) < 0 THEN
               v_por_ibner := 0;
            END IF;

            v_iibner_act := f_round((NVL(v_iibner_act, 0) * v_por_ibner), pcmoneda);

            --INSERTAMOS
            BEGIN
               IF pmodo = 'R' THEN
                  INSERT INTO ibner
                              (cempres, fcalcul, iibner,
                               pratio, cerror, cramo, sproces)
                       VALUES (pcempres, aux_factual, v_iibner_act,
                               f_round(v_por_ibner * 100, pcmoneda), 0, rc.cramo, psproces);
               ELSIF pmodo = 'P' THEN
                  INSERT INTO ibner_previo
                              (cempres, fcalcul, iibner,
                               pratio, cerror, cramo, sproces)
                       VALUES (pcempres, aux_factual, v_iibner_act,
                               f_round(v_por_ibner * 100, pcmoneda), 0, rc.cramo, psproces);
               END IF;
            EXCEPTION
               WHEN OTHERS THEN
                  ROLLBACK;
                  ttexto := f_axis_literales(103869, pcidioma);
                  num_err := f_proceslin(psproces, ttexto || ' IBNER', rc.cramo, nlin);
                  conta_err := conta_err + 1;
                  nlin := NULL;
                  COMMIT;
            END;

            COMMIT;
         END LOOP;
      END IF;

      RETURN conta_err;
   END f_commit_calcul_ibner;

   ----------------------------------------------------------------------------
-- PTGILS
----------------------------------------------------------------------------
-- Bug 21715 - APD - se crea la funcion
   FUNCTION f_commit_calcul_ptgils(
      pcempres IN NUMBER,
      aux_factual IN DATE,
      psproces IN NUMBER,
      pcidioma IN NUMBER,
      pcmoneda IN NUMBER,
      pmodo IN VARCHAR2 DEFAULT 'R')
      RETURN NUMBER IS
      aux_fefeini    DATE;
      ttexto         VARCHAR2(400);
      nlin           NUMBER;
      num_err        NUMBER;
      conta_err      NUMBER := 0;
      provisio       NUMBER;
      vicompan       NUMBER;

      CURSOR c_ramo IS
         SELECT cramo
           FROM codiram cr
          WHERE cr.cempres = pcempres;

      -- Siniestros pendientes al inicio del año y que siguen pendientes hasta
      -- la fecha de cálculo de la provisión (v.f.6)
      CURSOR c_sinies_ptes_ptes(pcempres NUMBER, pcramo NUMBER, pfecha DATE) IS
         SELECT sn.nsinies
           FROM sin_siniestro sn, sin_movsiniestro sm, seguros s
          WHERE sn.sseguro = s.sseguro
            AND s.cramo = pcramo
            AND s.cempres = pcempres
            AND sn.nsinies = sm.nsinies
            AND sm.cestsin IN(0, 4)
            AND sm.nmovsin =
                  (SELECT MAX(nmovsin)
                     FROM sin_movsiniestro sm2
                    WHERE sm.nsinies = sm2.nsinies
                      AND festsin <= TO_DATE('3112' || TO_CHAR(pfecha, 'yyyy') - 1, 'DDMMYYYY'))   --Siniestros pendientes al inicio del año
            AND EXISTS(SELECT '1'
                         FROM sin_movsiniestro sm2
                        WHERE sm.nsinies = sm2.nsinies
                          AND sm2.cestsin IN(0, 4)
                          AND sm2.nmovsin = (SELECT MAX(sm3.nmovsin)
                                               FROM sin_movsiniestro sm3
                                              WHERE sm2.nsinies = sm3.nsinies
                                                AND festsin <= pfecha));   --siguen pendientes hasta pfecha

      -- Siniestros pendientes al inicio del año y que han sido cerrados hasta
      -- la fecha de cálculo de la provisión (v.f.6)
      CURSOR c_sinies_ptes_cerrados(pcempres NUMBER, pcramo NUMBER, pfecha DATE) IS
         SELECT sn.nsinies
           FROM sin_siniestro sn, sin_movsiniestro sm, seguros s
          WHERE sn.sseguro = s.sseguro
            AND s.cramo = pcramo
            AND s.cempres = pcempres
            AND sn.nsinies = sm.nsinies
            AND sm.cestsin IN(0, 4)
            AND sm.nmovsin =
                  (SELECT MAX(nmovsin)
                     FROM sin_movsiniestro sm2
                    WHERE sm.nsinies = sm2.nsinies
                      AND festsin <= TO_DATE('3112' || TO_CHAR(pfecha, 'yyyy') - 1, 'DDMMYYYY'))   --Siniestros pendientes al inicio del año
            AND EXISTS(SELECT '1'
                         FROM sin_movsiniestro sm2
                        WHERE sm.nsinies = sm2.nsinies
                          AND sm2.cestsin = 1
                          AND sm2.nmovsin = (SELECT MAX(sm3.nmovsin)
                                               FROM sin_movsiniestro sm3
                                              WHERE sm2.nsinies = sm3.nsinies
                                                AND festsin <= pfecha));   --Cerrado a pfecha

      -- Siniestros declarados en el año de la fecha de cálculo de la provisión
      -- y que siguen pendientes hasta la fecha de cálculo de la provisión (v.f.6)
      CURSOR c_sinies_declar_ptes(pcempres NUMBER, pcramo NUMBER, pfecha DATE) IS
         SELECT sn.nsinies, sn.fnotifi
           FROM sin_siniestro sn, sin_movsiniestro sm, seguros s
          WHERE s.sseguro = sn.sseguro
            AND s.cramo = pcramo
            AND s.cempres = pcempres
            AND TRUNC(sn.fnotifi) >= TO_DATE('0101' || TO_CHAR(pfecha, 'yyyy'), 'DDMMYYYY')
            AND TRUNC(sn.fnotifi) <= pfecha   --Siniestros declarados en el año
            AND sn.nsinies = sm.nsinies
            AND sm.cestsin IN(0, 4)
            AND sm.nmovsin = (SELECT MAX(nmovsin)
                                FROM sin_movsiniestro sm2
                               WHERE sm.nsinies = sm2.nsinies
                                 AND festsin <= pfecha);   --Siniestros pendientes hasta pfecha

      -- Siniestros declarados en el año de la fecha de cálculo de la provisión
      -- y que han sido cerrados hasta la fecha de cálculo de la provisión (v.f.6)
      CURSOR c_sinies_declar_cerrados(pcempres NUMBER, pcramo NUMBER, pfecha DATE) IS
         SELECT sn.nsinies
           FROM sin_siniestro sn, sin_movsiniestro sm, seguros s
          WHERE s.sseguro = sn.sseguro
            AND s.cramo = pcramo
            AND s.cempres = pcempres
            AND TRUNC(sn.fnotifi) >= TO_DATE('0101' || TO_CHAR(pfecha, 'yyyy'), 'DDMMYYYY')
            AND TRUNC(sn.fnotifi) <= pfecha   --Siniestros declarados en el año
            AND sn.nsinies = sm.nsinies
            AND sm.cestsin = 1
            AND sm.nmovsin = (SELECT MAX(nmovsin)
                                FROM sin_movsiniestro sm2
                               WHERE sm.nsinies = sm2.nsinies
                                 AND festsin <= pfecha);   --Siniestros pendientes hasta pfecha

--------------------------------
      -- % de tiempo estimado en las diferentes fases de tramitacion de un siniestro
      v_por_tiempo_apertura NUMBER;   -- % de tiempo estimado en la apertura
      v_por_tiempo_seguimiento NUMBER;   -- % de tiempo estimado en el seguimiento
      v_por_tiempo_cierre NUMBER;   -- % de tiempo estimado en el cierre
      --
      v_por_inflacion NUMBER;   -- % de inflacion previsto
      --
      v_por_ponderacion_prov NUMBER;   -- % de ponderacion de la provision
      v_por_ponderacion_prov_ibnr NUMBER;   -- % de ponderacion de la provision IBNR
--------------------------------
      v_ggi          NUMBER;   -- gasto global individual
      v_ggi_total    NUMBER;   -- gasto global total
      v_ggi_medio    NUMBER;   -- gasto global medio
      v_sinies_ptes_ptes NUMBER;   -- Nº de siniestros pendientes al iniciono de año y que siguen pendientes
      v_sinies_ptes_cerrados NUMBER;   -- Nº de siniestros pendientes al iniciono de año y que han sido cerrados
      v_sinies_declar_ptes NUMBER;   -- Nº de siniestros declarados en el año y que siguen pendientes
      v_sinies_declar_cerrados NUMBER;   -- Nº de siniestros declarados en el año y que han sido cerrados
      v_sinies_tramitados NUMBER;   -- Nº de siniestros tramitados (siniestros pendientes al inicio de año y declarados en el año)
      v_sinies_tramitados_ponderados NUMBER;   -- Nº de siniestros tramitados ponderados según el % de tiempo estimado
      v_sinies_cerrados NUMBER;   -- Nº total de siniestros cerrados (siniestros pendientes al inicio de año y declarados en el año)
      v_por_sinies_cerrados NUMBER;   -- % de siniestros cerrados
      v_periodo_medio NUMBER;   -- Periodo medio que resta para cerrar los siniestros pendientes
      v_periodo_medio_ptes NUMBER;   -- Periodo medio que resta para cerrar los siniestros pendientes para los siniestros pendientes al inicio del año
      v_periodo_medio_declar NUMBER;   -- Periodo medio que resta para cerrar los siniestros pendientes para los siniestros declarados en el año
      v_ndias_sinies_declar_ptes NUMBER;   --Nº de días que un siniestro declarado lleva pendiente hasta la fecha de cálculo de la provision
      v_ndias_medio_sin_declar_ptes NUMBER;   -- Nº de dias promedio de los siniestros declarados que aún están pendientes a la fecha de cálculo de la provision
      v_por_ndias_sin_declar_ptes NUMBER;   -- % anual del numero de dias de los siniestros declarados que aún están pendientes a la fecha de cálculo de la provision
      v_iptgils      NUMBER;   -- Importe de la provison PTGILS
      v_iptgils_ibnr NUMBER;   -- Importe de la provison PTGILS calculada a partir de la provision IBNR
      v_iptgils_total NUMBER;   -- Importe TOTAL de la provison PTGILS
      v_iibnrsd      ibnr_ram.iibnrsd%TYPE;
   BEGIN
      -- % de tiempo estimado en la fase de apertura de un siniestro
      v_por_tiempo_apertura := NVL(f_gettramo1(aux_factual, 7000, 1), 0);
      -- % de tiempo estimado en la fase de seguimiento de un siniestro
      v_por_tiempo_seguimiento := NVL(f_gettramo1(aux_factual, 7000, 2), 0);
      -- % de tiempo estimado en la fase de cierre de un siniestro
      v_por_tiempo_cierre := NVL(f_gettramo1(aux_factual, 7000, 3), 0);
      -- % de inflacion previsto
      v_por_inflacion := NVL(f_gettramo1(aux_factual, 7001, 1), 0);
      -- % de ponderacion de la provision
      v_por_ponderacion_prov := NVL(f_gettramo1(aux_factual, 7002, 1), 0);
      -- % de ponderacion de la provision IBNR
      v_por_ponderacion_prov_ibnr := NVL(f_gettramo1(aux_factual, 7002, 2), 0);

      FOR rc IN c_ramo LOOP
         v_ggi := 0;
         v_ggi_total := 0;
         v_ggi_medio := 0;
         v_sinies_ptes_ptes := 0;
         v_sinies_ptes_cerrados := 0;
         v_sinies_declar_ptes := 0;
         v_sinies_declar_cerrados := 0;
         v_sinies_tramitados := 0;
         v_sinies_tramitados_ponderados := 0;
         v_sinies_cerrados := 0;
         v_por_sinies_cerrados := 0;
         v_periodo_medio := 0;
         v_periodo_medio_ptes := 0;
         v_periodo_medio_declar := 0;
         v_ndias_sinies_declar_ptes := 0;
         v_ndias_medio_sin_declar_ptes := 0;
         v_por_ndias_sin_declar_ptes := 0;
         v_iptgils := 0;
         v_iptgils_ibnr := 0;
         v_iptgils_total := 0;

         -- 1.- Determinación del gasto unitario --
         -- Para cada ramo o modalidad objeto de cálculo se determina un gasto anual por siniestro
         -- sobre la base de dividir el gasto global del año que se imputa al ramo en cuestión entre
         -- el número de siniestros tramitados en ese año

         --Calculamos el total de siniestros pendientes al inicio del año y
         -- que siguen pendientes hasta la fecha de cálculo de la provisión (v.f.6)
         FOR rspp IN c_sinies_ptes_ptes(pcempres, rc.cramo, aux_factual) LOOP
            v_sinies_ptes_ptes := v_sinies_ptes_ptes + 1;
         END LOOP;

         --Calculamos el total de siniestros pendientes al inicio del año y
         -- que han sido cerrados hasta la fecha de cálculo de la provisión (v.f.6)
         FOR rspc IN c_sinies_ptes_cerrados(pcempres, rc.cramo, aux_factual) LOOP
            v_sinies_ptes_cerrados := v_sinies_ptes_cerrados + 1;
         END LOOP;

         --Calculamos el total de siniestros declarados en el año de la fecha de cálculo de la provisión
         -- y que siguen pendientes hasta la fecha de cálculo de la provisión (v.f.6)
         -- y el coste de dichos siniestros a fecha actual
         FOR rsdp IN c_sinies_declar_ptes(pcempres, rc.cramo, aux_factual) LOOP
            v_ggi := 0;
            num_err := f_provisio(rsdp.nsinies, v_ggi, aux_factual, 1);

            IF num_err <> 0 THEN
               num_err := f_proceslin(psproces, ttexto, rsdp.nsinies, nlin);
               conta_err := conta_err + 1;
               nlin := NULL;
            ELSE
               v_sinies_declar_ptes := v_sinies_declar_ptes + 1;
               v_ggi_total := NVL(v_ggi_total, 0) + NVL(v_ggi, 0);   --Coste de todos los siniestros a fecha actual
               v_ndias_sinies_declar_ptes := NVL(v_ndias_sinies_declar_ptes, 0)
                                             + NVL(TRUNC(aux_factual) - rsdp.fnotifi, 0);
            END IF;
         END LOOP;

         --Calculamos el total de siniestros declarados en el año de la fecha de cálculo de la provisión
         -- y que han sido cerrados hasta la fecha de cálculo de la provisión (v.f.6)
         -- y el coste de dichos siniestros a fecha a actual
         FOR rsdc IN c_sinies_declar_cerrados(pcempres, rc.cramo, aux_factual) LOOP
            v_ggi := 0;
            num_err := f_provisio(rsdc.nsinies, v_ggi, aux_factual, 1);

            IF num_err <> 0 THEN
               num_err := f_proceslin(psproces, ttexto, rsdc.nsinies, nlin);
               conta_err := conta_err + 1;
               nlin := NULL;
            ELSE
               v_sinies_declar_cerrados := v_sinies_declar_cerrados + 1;
               v_ggi_total := NVL(v_ggi_total, 0) + NVL(v_ggi, 0);   --Coste de todos los siniestros a fecha actual
            END IF;
         END LOOP;

         -- Nº de siniestros tramitados (siniestros pendientes al inicio de año y declarados en el año)
         v_sinies_tramitados := NVL(v_sinies_ptes_ptes, 0) + NVL(v_sinies_ptes_cerrados, 0)
                                + NVL(v_sinies_declar_ptes, 0)
                                + NVL(v_sinies_declar_cerrados, 0);
         -- Nº de siniestros tramitados ponderados según el % de tiempo estimado
         v_sinies_tramitados_ponderados := (NVL(v_sinies_ptes_ptes, 0)
                                            *(NVL(v_por_tiempo_apertura, 0) / 100))
                                           +(NVL(v_sinies_ptes_cerrados, 0)
                                             *((NVL(v_por_tiempo_seguimiento, 0)
                                                + NVL(v_por_tiempo_cierre, 0))
                                               / 100))
                                           +(NVL(v_sinies_declar_ptes, 0)
                                             *((NVL(v_por_tiempo_apertura, 0)
                                                + NVL(v_por_tiempo_seguimiento, 0))
                                               / 100))
                                           +(NVL(v_sinies_declar_cerrados, 0)
                                             *((NVL(v_por_tiempo_apertura, 0)
                                                + NVL(v_por_tiempo_seguimiento, 0)
                                                + NVL(v_por_tiempo_cierre, 0))
                                               / 100));

         -- Gasto global medio
         IF v_sinies_tramitados_ponderados = 0 THEN
            v_ggi_medio := 0;
         ELSE
            v_ggi_medio := v_ggi_total / v_sinies_tramitados_ponderados;
         END IF;

         -- 2.- Tiempo que resta para cerrar los siniestros pendientes --
         -- Se distinguen los siniestros pendientes que proceden de ejercicios anteriores
         -- de los declarados en el propio ejercicio

         --  Cálculo del tiempo (periodo) medio que resta para cerrar los siniestros pendientes
         -- para los siniestros pendientes al inicio del año

         -- Nº total de siniestros cerrados (siniestros pendientes al inicio de año y que han
         -- sido cerrados + nº de siniestros declarados en el año y que han sido cerrados)
         v_sinies_cerrados := NVL(v_sinies_ptes_cerrados, 0) + NVL(v_sinies_declar_cerrados, 0);

         -- % de siniestros cerrados
         IF v_sinies_tramitados = 0 THEN
            -- control para no dividir entre 0
            v_por_sinies_cerrados := 0;
         ELSE
            v_por_sinies_cerrados := NVL(v_sinies_cerrados, 0) / v_sinies_tramitados;
         END IF;

         -- Periodo medio que resta para cerrar los siniestros pendientes
         IF v_por_sinies_cerrados = 0 THEN
            -- control para no dividir entre 0
            v_periodo_medio := 0;
         ELSE
            v_periodo_medio := 1 / v_por_sinies_cerrados;
         END IF;

         -- Periodo medio que resta para cerrar los siniestros pendientes para los siniestros pendientes al inicio del año
         IF v_periodo_medio = 0 THEN
            -- control para que no salga un resultado negativo
            v_periodo_medio_ptes := 0;
         ELSE
            v_periodo_medio_ptes := v_periodo_medio - 1;
         END IF;

         --  Cálculo del tiempo (periodo) medio que resta para cerrar los siniestros pendientes
         -- para los siniestros declarados en el año

         -- Nº de dias promedio de los siniestros declarados que aún están pendientes a la fecha de cálculo de la provision
         IF v_sinies_declar_ptes = 0 THEN
            -- control para no dividir entre 0
            v_ndias_medio_sin_declar_ptes := 0;
         ELSE
            v_ndias_medio_sin_declar_ptes := NVL(v_ndias_sinies_declar_ptes, 0)
                                             / v_sinies_declar_ptes;
         END IF;

         -- % anual del numero de dias de los siniestros declarados que aún están pendientes a la fecha de cálculo de la provision
         v_por_ndias_sin_declar_ptes := NVL(v_ndias_medio_sin_declar_ptes, 0) / 365;

         IF v_periodo_medio = 0 THEN
            v_periodo_medio_declar := 0;
         ELSE
            v_periodo_medio_declar := NVL(v_periodo_medio, 0)
                                      - NVL(v_por_ndias_sin_declar_ptes, 0);
         END IF;

         -- 3.- Calculo de la provision --
         -- La Provisión se obtiene por separado para cada una de las categorías de siniestros pendientes,
         -- tanto de años anteriores como declarados en el ejercicio.
         -- En cada caso su importe se obtiene multiplicando el número de siniestros por el tiempo medio
         -- que falta para el cierre y por el gasto unitario anual que corresponda al ramo.
         -- Finalmente se incorpora el cálculo sobre los siniestros IBNRs así como una estimación de inflación

         -- Importe de la provison PTGILS
         v_iptgils := ((NVL(v_sinies_ptes_ptes, 0) * NVL(v_periodo_medio_ptes, 0))
                       +(NVL(v_sinies_declar_ptes, 0) * NVL(v_periodo_medio_declar, 0)))
                      * NVL(v_ggi_medio, 0) *(NVL(v_por_ponderacion_prov, 0) / 100)
                      *(1 -(NVL(v_por_inflacion, 0) / 100));

         -- Importe de la provison PTGILS calculada a partir de la provision IBNR
         --Buscamos el Importe IBNR actual
         IF pmodo = 'R' THEN
            SELECT SUM(iibnrsd)
              INTO v_iibnrsd
              FROM ibnr_ram i
             WHERE cempres = pcempres
               AND TRUNC(i.fcalcul) = aux_factual
               AND cramo = rc.cramo;
         ELSIF pmodo = 'P' THEN
            SELECT SUM(iibnrsd)
              INTO v_iibnrsd
              FROM ibnr_ram_previo i
             WHERE cempres = pcempres
               AND TRUNC(i.fcalcul) = aux_factual
               AND cramo = rc.cramo;
         END IF;

         v_iptgils_ibnr := (NVL(v_iibnrsd, 0) * NVL(v_periodo_medio, 0)) * NVL(v_ggi_medio, 0)
                           *(NVL(v_por_ponderacion_prov_ibnr, 0) / 100)
                           *(1 -(NVL(v_periodo_medio, 0) / 100));
         -- Importe TOTAL de la provison PTGILS
         v_iptgils_total := v_iptgils + v_iptgils_ibnr;

         --INSERTAMOS
         BEGIN
            IF pmodo = 'R' THEN
               INSERT INTO ptgils
                           (cempres, fcalcul, iptgils, cerror,
                            cramo, sproces)
                    VALUES (pcempres, aux_factual, f_round(v_iptgils_total, pcmoneda), 0,
                            rc.cramo, psproces);
            ELSIF pmodo = 'P' THEN
               INSERT INTO ptgils_previo
                           (cempres, fcalcul, iptgils, cerror,
                            cramo, sproces)
                    VALUES (pcempres, aux_factual, f_round(v_iptgils_total, pcmoneda), 0,
                            rc.cramo, psproces);
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               ROLLBACK;
               ttexto := f_axis_literales(103869, pcidioma);
               num_err := f_proceslin(psproces, ttexto || ' PTGILS', rc.cramo, nlin);
               conta_err := conta_err + 1;
               nlin := NULL;
               COMMIT;
         END;

         COMMIT;
      END LOOP;

      RETURN conta_err;
   END f_commit_calcul_ptgils;

-----------------------------------------------------------------------
-- PPLP desglosada por garantia
-----------------------------------------------------------------------
   FUNCTION f_commit_calcul_pplpgar(
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
      num_err        NUMBER;
      conta_err      NUMBER := 0;
      provisio       NUMBER;
      vicompan       NUMBER;
      --Bug.: 21715 - 28/03/2012 - ICV
      v_ippl         NUMBER := 0;
      v_ippp         NUMBER := 0;
      v_restot       NUMBER := 0;

      CURSOR c1(pnsinies NUMBER, pfecha DATE, pcgarant IN NUMBER) IS
         SELECT stm.cestval, stm.cestpag,
                DECODE(stp.ctippag, 7, -stpg.isinret, stpg.isinret) importe, stm.sidepag,
                stm.fefepag
           FROM sin_tramita_pago stp, sin_tramita_movpago stm, sin_tramita_pago_gar stpg
          WHERE stp.nsinies = pnsinies
            AND stp.sidepag = stm.sidepag
            AND stm.nmovpag = (SELECT MAX(nmovpag)
                                 FROM sin_tramita_movpago stm2
                                WHERE stm.sidepag = stm2.sidepag)
            AND TRUNC(stm.fefepag) < pfecha
            AND stpg.sidepag = stp.sidepag
            AND stpg.cgarant = pcgarant;

      CURSOR c2(pnsinies NUMBER) IS
         SELECT DISTINCT a.cgarant
                    FROM sin_tramita_reserva a
                   WHERE a.nsinies = pnsinies;
   BEGIN
      FOR reg IN c_siniestros_pplp(aux_factual, cempres) LOOP
         FOR f2 IN c2(reg.nsinies) LOOP
            -- Esta función tiene en cuenta todos los pagos, tanto si están valorados como
            -- si no lo están.  El libor de siniestros, sólo tiene en cuenta los pagos
            -- que tienen valoración.
            num_err := f_provisiogar(reg.nsinies, f2.cgarant, provisio, aux_factual);

            IF NVL(pac_parametros.f_parempresa_n(cempres, 'MODULO_SINI'), 0) = 0 THEN
               v_ippl := 0;
               v_ippp := 0;
            ELSE
               --Exclusivo para el modulo nuevo volvemos a llamar a la f_provisio para calcular el importe de la reserva total del siniestro
               num_err := f_provisio(reg.nsinies, v_restot, aux_factual, 1, f2.cgarant);

               IF num_err <> 0 THEN
                  v_ippl := v_restot;
                  v_ippp := 0;

                  FOR rc IN c1(reg.nsinies, aux_factual, f2.cgarant) LOOP
                     IF rc.cestpag IN(1, 2) THEN   --Aceptado pagado
                        v_ippl := v_ippl - rc.importe;   --Pendientes de liquidar (Reserva total - Pagos Aceptados / Pagados

                        IF rc.cestpag = 2 THEN
                           v_ippp := rc.importe;   --Pendiente de pagar (Pagos pagados)
                        END IF;
                     END IF;
                  END LOOP;
               END IF;
            END IF;

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
                     -- Bug 0026890 - 06/05/2013 - DCG - Ini
                     SELECT NVL(SUM(icompan_moncon), SUM(icompan))
                       -- Bug 0026890 - 06/05/2013 - DCG - Fi
                     INTO   vicompan
                       FROM liqresreaaux
                      WHERE nsinies = reg.nsinies
                        AND fcierre = aux_factual
                        AND cgarant = f2.cgarant;

                     --FI BUG10328 - 18/06/2009 - DCT -
                     IF pmodo = 'R' THEN
                        INSERT INTO ptpplpgar
                                    (cempres, fcalcul, sproces, cramdgs,
                                     cramo, cmodali, ctipseg, ccolect,
                                     sseguro, nsinies, ipplpsd, ipplprc, cerror,
                                     ippl, ippp, cgarant)
                             VALUES (reg.cempres, aux_factual, psproces, reg.cramdgs,
                                     reg.cramo, reg.cmodali, reg.ctipseg, reg.ccolect,
                                     reg.sseguro, reg.nsinies, provisio, NVL(vicompan, 0), 0,
                                     v_ippl, v_ippp, f2.cgarant);
                     ELSIF pmodo = 'P' THEN
                        INSERT INTO ptpplpgar_previo
                                    (cempres, fcalcul, sproces, cramdgs,
                                     cramo, cmodali, ctipseg, ccolect,
                                     sseguro, nsinies, ipplpsd, ipplprc, cerror,
                                     ippl, ippp, cgarant)
                             VALUES (reg.cempres, aux_factual, psproces, reg.cramdgs,
                                     reg.cramo, reg.cmodali, reg.ctipseg, reg.ccolect,
                                     reg.sseguro, reg.nsinies, provisio, NVL(vicompan, 0), 0,
                                     v_ippl, v_ippp, f2.cgarant);
                     END IF;
                  EXCEPTION
                     WHEN OTHERS THEN
                        ROLLBACK;
                        ttexto := f_axis_literales(104349, pcidioma);
                        num_err := f_proceslin(psproces, ttexto || ' PTPPLP', reg.sseguro,
                                               nlin);
                        conta_err := conta_err + 1;
                        nlin := NULL;
                        COMMIT;
                  END;

                  COMMIT;
               END IF;
            END IF;
         END LOOP;
      END LOOP;

      RETURN conta_err;
   END f_commit_calcul_pplpgar;

FUNCTION f_difdata_consulta(
   pdatain IN DATE,
   pdatafin IN DATE,
   ptipo IN NUMBER,
   punid IN NUMBER)
  RETURN NUMBER IS
/******************************************************************************
   NOMBRE:       F_DIFDATA_CONSULTA
   PROPÓSITO:  Realiza el llamado a la función f_difdata, con el return sin el uso de variables.
******************************************************************************/

   error          NUMBER;
   dini           NUMBER;
   dfin           NUMBER;
   mesini         NUMBER;
   mesfin         NUMBER;
   w_dias         NUMBER;
BEGIN

  error := f_difdata(pdatain, pdatafin, ptipo, punid, w_dias);

  if error != 0 then
     RETURN error;
  end if;

  RETURN (w_dias);

EXCEPTION
  WHEN OTHERS THEN
   RETURN 9904575; -- Proceso terminado con errores
END f_difdata_consulta;

END pac_provtec;

/

  GRANT EXECUTE ON "AXIS"."PAC_PROVTEC" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_PROVTEC" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_PROVTEC" TO "PROGRAMADORESCSI";
