--------------------------------------------------------
--  DDL for Package Body PAC_PROVNOTEC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_PROVNOTEC" 
IS
   /***********************************************************************************************
        Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
        1.0       -            -                 1. Creación de package
        1.1       14/09/06     CPM:             1.Se rehace el calculo de las PPPC según especificaciones de MV
        2.0       09/07/2009   ETM              2.BUG 0010676: CEM - Días de gestión de un recibo
        2.1       22/09/2009   NMM              2.1. 10676: CEM - Canviar paràmetre funció.
        3.0       06/05/2013   DCG              0026890: RSA003-Crear provisi?n de incobrables
        4.0       11/06/2013   DCG              0026214: RSA003 - Parametrizar PPNC
        5.0       29/10/2014   AQ               0033041: RSA300-Cambios en provisiones y pagos parciales
        6.0       09/03/2015   KJSC             BUG 35103-200056.KJSC. Se debe sustituir r.cempres por el número de recibo (nrecibo).
        7.0       13/10/2015   NMM              38020: Revisió codi
	8.0       15/10/2015   AAC              37369: Revisió codi
   ***********************************************************************************************/

   --(JAS)07.05.07 - Es modifica el cursor per tal que recuperi el camp "icomncs" al 15% per productes d'estalvi (en comptes del 12%)
   CURSOR c_polizas (fecha DATE, empresa NUMBER)
   IS
      SELECT   s.sseguro, s.npoliza, s.sproduc,
               DECODE (SIGN (MONTHS_BETWEEN (s.fcaranu, fecha) - 12),
                       1, ADD_MONTHS (s.fcaranu, -12),
                       s.fcaranu
                      ) fcaranu,
               NVL (r.panula, 0) panula, s.fcarpro, p.cgarant, p.fefeini,
               p.ffinefe,
               -- Bug 0026890 - 06/05/2013 - DCG - Ini
--               p.ipridev,
--               p.iprincs, p.nmovimi, p.nriesgo, p.icomage, p.icomncs, p.ipdevrc, p.ipncsrc,
--               p.icomrc, p.icncsrc,
                         NVL (p.ipridev_moncon, p.ipridev) ipridev,
               NVL (p.iprincs_moncon, p.iprincs) iprincs, p.nmovimi,
               p.nriesgo, NVL (p.icomage_moncon, p.icomage) icomage,
               NVL (p.icomncs_moncon, p.icomncs) icomncs,
               NVL (p.ipdevrc_moncon, p.ipdevrc) ipdevrc,
               NVL (p.ipncsrc_moncon, p.ipncsrc) ipncsrc,
               NVL (p.icomrc_moncon, p.icomrc) icomrc,
               NVL (p.icncsrc_moncon, p.icncsrc) icncsrc,
                                                         -- Bug 0026890 - 06/05/2013 - DCG - Fi
                                                         p.cramdgs, p.cramo,
               p.cmodali, p.ccolect, p.ctipseg
          FROM seguros s, codiram r, ppnc p
         WHERE s.sseguro = p.sseguro
           AND p.fcalcul = fecha
           AND p.cempres = empresa
           AND r.cramo = s.cramo
           AND f_prod_ahorro (s.sproduc) = 0
      ORDER BY cramo, sseguro;

   seg   c_polizas%ROWTYPE;

   --(JAS)07.05.07 - Es modifica el cursor per tal que recuperi el camp "icomncs" al 15% per productes d'estalvi (en comptes del 12%)
   CURSOR c_polizas_previo (fecha DATE, empresa NUMBER)
   IS
      SELECT   s.sseguro, s.npoliza, s.sproduc,
               DECODE (SIGN (MONTHS_BETWEEN (s.fcaranu, fecha) - 12),
                       1, ADD_MONTHS (s.fcaranu, -12),
                       s.fcaranu
                      ) fcaranu,
               NVL (r.panula, 0) panula, s.fcarpro, p.cgarant, p.fefeini,
               p.ffinefe,
               -- Bug 0026890 - 06/05/2013 - DCG - Ini
--               p.ipridev,
--               p.iprincs, p.nmovimi, p.nriesgo, p.icomage, p.icomncs,
--                                                                     --DECODE(s.cramo, 30, round(p.iprincs*pac_cuadre_adm.f_comi_conta(s.sseguro,s.sproduc,fecha),2),p.icomncs) icomncs,
--                                                                     p.ipdevrc, p.ipncsrc,
--               p.icomrc, p.icncsrc,
                         NVL (p.ipridev_moncon, p.ipridev) ipridev,
               NVL (p.iprincs_moncon, p.iprincs) iprincs, p.nmovimi,
               p.nriesgo, NVL (p.icomage_moncon, p.icomage) icomage,
               NVL (p.icomncs_moncon, p.icomncs) icomncs,
               NVL (p.ipdevrc_moncon, p.ipdevrc) ipdevrc,
               NVL (p.ipncsrc_moncon, p.ipncsrc) ipncsrc,
               NVL (p.icomrc_moncon, p.icomrc) icomrc,
               NVL (p.icncsrc_moncon, p.icncsrc) icncsrc,
                                                         -- Bug 0026890 - 06/05/2013 - DCG - Fi
                                                         p.cramdgs, p.cramo,
               p.cmodali, p.ccolect, p.ctipseg
          FROM seguros s, codiram r, ppnc_previo p
         WHERE s.sseguro = p.sseguro
           AND p.fcalcul = fecha
           AND p.cempres = empresa
           AND r.cramo = s.cramo
           AND f_prod_ahorro (s.sproduc) = 0
      ORDER BY cramo, sseguro;

   CURSOR c_recibos_ahorro (fecha DATE, empresa NUMBER)
   IS
      SELECT p.cramdgs, s.cramo, s.cmodali, s.ctipseg, s.ccolect, s.sseguro,
             r.nrecibo, d.cgarant, NVL (r.nriesgo, 1) nriesgo, r.nmovimi,
             r.fefecto, d.iconcep, NVL (c.panula, 100) panula
        FROM recibos r,
             seguros s,
             codiram c,
             productos p,
             detrecibos d,
             movrecibo m
       WHERE f_prod_ahorro (p.sproduc) = 1
         AND c.cempres = empresa
         AND s.sproduc = p.sproduc
         AND c.cramo = s.cramo
         AND r.sseguro = s.sseguro
         AND d.nrecibo = r.nrecibo
         AND d.cconcep = 0
         AND m.nrecibo = r.nrecibo
         AND m.fmovini <= fecha
         AND (m.fmovfin > fecha OR m.fmovfin IS NULL)
         AND (   m.cestrec = 0
              OR (    m.cestrec = 1
                  AND DECODE (NVL (m.ctipcob, -1),
                              --BUG 35103-200056.KJSC. Se debe sustituir r.cempres por el número de recibo (nrecibo).
                              -1, m.fmovini
                               + pac_adm.f_get_diasgest (r.nrecibo),
                               /*BUG 0010676: 22/09/2009 : NMM -- CEM - Substituïm el paràmetre de rebut pel de companyia */
                              -- -1, m.fmovini + pac_adm.f_get_diasgest(r.cempres),
                              m.fmovini
                             ) > fecha            -- estan en gestión de cobro
                 )
             )
         AND r.fefecto <= fecha
         AND pac_gestion_rec.f_recunif_list (r.nrecibo) = 0
         -- CPM 04/12/12 24893
         AND r.ctiprec <> 9;                                --No es un extorno

   CURSOR c_detalle (
      psseguro       NUMBER,
      pfechaini      DATE,
      pfechafin      DATE,
      pgarantia      NUMBER,
      pnriesgo       NUMBER,
      paux_factual   DATE
   )
   IS
      -- Se añade el concepto de DERECHOS DE REGISTRO (valor 6 del concepto)
      -- para las pppc, se tendran en cuenta como una prima.
      SELECT   r.nrecibo, r.fefecto, r.fvencim, r.ctiprec, r.femisio,

      -- Bug 0026890 - 06/05/2013 - DCG - Ini
--               (d.iconcep + NVL(d3.iconcep, 0)) prima, NVL(d2.iconcep, 0) comisio
               (  NVL (d.iconcep_monpol, d.iconcep)
                + NVL (d3.iconcep_monpol, NVL (d3.iconcep, 0))
               ) prima,
               NVL (d2.iconcep_monpol, NVL (d2.iconcep, 0)) comisio
          -- Bug 0026890 - 06/05/2013 - DCG - Fi
      FROM     recibos r,
               detrecibos d,
               detrecibos d2,
               seguros s,
               detrecibos d3
         WHERE r.fefecto BETWEEN pfechaini AND (pfechafin - 1)
           AND r.sseguro = psseguro
           AND d.nrecibo = r.nrecibo
           AND d.nriesgo = pnriesgo
           AND r.ctiprec <> 9                               --No es un extorno
           AND d.cgarant = pgarantia
           AND d.cconcep = 0
           AND d2.nrecibo(+) = r.nrecibo
           AND d2.cgarant(+) = pgarantia
           AND d2.cconcep(+) = 11
           AND d2.nriesgo(+) = pnriesgo
           AND d3.nrecibo(+) = r.nrecibo
           AND d3.cgarant(+) = pgarantia
           AND d3.cconcep(+) = 6
           AND d3.nriesgo(+) = pnriesgo
           AND r.sseguro = s.sseguro
           AND pac_gestion_rec.f_recunif_list (r.nrecibo) = 0
      -- CPM 04/12/12 24893
      ORDER BY r.fvencim;

   det   c_detalle%ROWTYPE;

-- Bug 0037369 - 16/10/2016 - AAC - Ini
   CURSOR c_recibos_sam (fecha DATE, empresa NUMBER)
   IS
      SELECT   r.nrecibo, s.sseguro, s.npoliza, s.sproduc, s.cramo, s.cmodali,
               s.ctipseg, s.ccolect, r.fefecto, NVL (p.cramdgs, 0) cramdgs,

               SUM (NVL (d.iconcep, 0)) iimporte, d.cgarant, r.nmovimi,
               d.nriesgo
          FROM recibos r, seguros s, productos p, detrecibos d, movrecibo m
         WHERE r.cempres = empresa
           and cestrec = 0
           AND r.sseguro = s.sseguro
           AND p.cramo = s.cramo
           AND p.cmodali = s.cmodali
           AND p.ctipseg = s.ctipseg
           AND p.ccolect = s.ccolect
           AND r.nrecibo = d.nrecibo
           AND d.cconcep IN (0)
           and r.nrecibo = m.nrecibo
           AND TRUNC (fecha) >= fmovini
           AND (TRUNC (fecha) < fmovfin OR fmovfin IS NULL)
           and trunc(fmovdia) <= trunc(fecha)
      GROUP BY r.nrecibo,
               s.sseguro,
               s.npoliza,
               s.sproduc,
               s.cramo,
               s.cmodali,
               s.ctipseg,
               s.ccolect,
               r.fefecto,
               NVL (p.cramdgs, 0),
               d.cgarant,
               r.nmovimi,
               d.nriesgo;

   rec   c_recibos_sam%ROWTYPE;

   -- Calcular fecha provision
   FUNCTION f_fecprov (
      p_pro   IN   NUMBER,
      p_seg   IN   NUMBER,
      p_mov   IN   NUMBER,
      p_efe   IN   DATE,
      p_act   IN   DATE
   )
      RETURN DATE
   IS
      v_ret         DATE;
      diasgracia    NUMBER;
      diaspartner   NUMBER;
   BEGIN
      IF NVL (f_parproductos_v (p_pro, 'GRACIA_PPPC'), 0) = 1
      THEN
         BEGIN
            SELECT crespue
              INTO diasgracia
              FROM pregunpolseg
             WHERE cpregun = 9015
               AND sseguro = p_seg
               AND nmovimi =
                      (SELECT MAX (p.nmovimi)
                         FROM pregunpolseg p
                        WHERE p.cpregun = 9015
                          AND p.sseguro = p_seg
                          AND p.nmovimi <= p_mov);
         EXCEPTION
            WHEN OTHERS
            THEN
               diasgracia := 0;
         END;

         BEGIN
            SELECT crespue
              INTO diaspartner
              FROM pregunpolseg
             WHERE cpregun = 427
               AND sseguro = p_seg
               AND nmovimi =
                      (SELECT MAX (p.nmovimi)
                         FROM pregunpolseg p
                        WHERE p.cpregun = 427
                          AND p.sseguro = p_seg
                          AND p.nmovimi <= p_mov);
         EXCEPTION
            WHEN OTHERS
            THEN
               diaspartner := 0;
         END;

         IF p_efe IS NULL
         THEN
            v_ret := NULL;
         ELSE
            -- 10/03/2014 sumar 30 dias
            v_ret := p_efe + diasgracia + diaspartner + 30;
         END IF;
      --IF v_ret >= p_act THEN
         -- Si supera fecha actual no mostramos fecha.
      --  v_ret := NULL;
      --END IF;
      ELSE
         v_ret := NULL;
      END IF;

      RETURN v_ret;
   END;

-- Bug 0026214 - 11/06/2013 - DCG - Fi

   /*************************************************************************
      Recupera el porcentaje de anulación
      param in pmesini     : inicio de vigencia
      param in pmesfin    : fin  de vigencia
      param in pporcjudi : indica si se ha de buscar el porcentaje de las primas reclamadas judicialmente
   *************************************************************************/
   FUNCTION f_calc_porc_anula_pppc (
      pcempres      IN   NUMBER,
      aux_factual   IN   DATE,
      pcramo        IN   NUMBER,
      pmesini       IN   NUMBER,
      pmesfin       IN   NUMBER,
      pporcjudi     IN   NUMBER
   )
      RETURN NUMBER
   IS
      v_ipend        NUMBER := 0;
      v_ianulac      NUMBER := 0;
      v_porc         NUMBER := 0;
      v_anyos_hist   NUMBER;
      v_anyos_cont   NUMBER := 0;
   BEGIN
      v_anyos_hist :=
         NVL (pac_parametros.f_parempresa_n (pcempres, 'ANYOS_PPPC_HIST'), 3);
      v_anyos_cont := v_anyos_hist;

      WHILE (v_anyos_cont <> 0)
      LOOP
         v_ipend := 0;
         v_ianulac := 0;

         SELECT SUM (p.ipppc)
           INTO v_ipend
           FROM pppc p, recibos r
          WHERE p.cempres = pcempres
            AND p.fcalcul =
                   TO_DATE (   '3112'
                            || TO_CHAR (aux_factual, 'yyyy')
                            -  v_anyos_cont,
                            'DDMMYYYY'
                           )
            AND p.cramo = pcramo
            AND r.nrecibo = p.nrecibo
            AND (   pmesini IS NULL
                 OR MONTHS_BETWEEN (p.fcalcul, r.fefecto) < pmesini
                )
            AND (   pmesfin IS NULL
                 OR MONTHS_BETWEEN (p.fcalcul, r.fefecto) >= pmesfin
                );

         IF NVL (v_ipend, 0) <> 0
         THEN         --Si había prima pendiente miramos si se ha anulado algo
            SELECT SUM (p.ipppc)
              INTO v_ianulac
              FROM pppc p, recibos r, movrecibo m
             WHERE p.cempres = pcempres
               AND p.fcalcul =
                      TO_DATE (   '3112'
                               || TO_CHAR (aux_factual, 'yyyy')
                               -  v_anyos_cont,
                               'DDMMYYYY'
                              )
               AND p.cramo = pcramo
               AND r.nrecibo = p.nrecibo
               AND (   pmesini IS NULL
                    OR MONTHS_BETWEEN (p.fcalcul, r.fefecto) < pmesini
                   )
               AND (   pmesfin IS NULL
                    OR MONTHS_BETWEEN (p.fcalcul, r.fefecto) >= pmesfin
                   )
               AND m.nrecibo = r.nrecibo
               AND m.fmovfin IS NULL
               AND m.cestrec = 2;                                    --anulado
         END IF;

         IF NVL (v_ipend, 0) <> 0
         THEN
            v_porc := NVL (v_porc, 0) + (v_ianulac / v_ipend);
         ELSE
            v_porc := NVL (v_porc, 0) + 0;
         END IF;

         v_anyos_cont := v_anyos_cont - 1;
      END LOOP;

      IF v_porc <> 0
      THEN
         v_porc := ROUND (v_porc / v_anyos_hist, 4);
      ELSE
         v_porc := NULL;
      END IF;

      RETURN v_porc;
   END f_calc_porc_anula_pppc;

   FUNCTION f_commit_calcul_pppc (
      cempres       IN   NUMBER,
      aux_factual   IN   DATE,
      psproces      IN   NUMBER,
      pcidioma      IN   NUMBER,
      pcmoneda      IN   NUMBER,
      pmodo         IN   VARCHAR2 DEFAULT 'R'
   )
      RETURN NUMBER
   IS
      num_err         NUMBER        := 0;
      nlin            NUMBER;
      wprimcom        NUMBER;
      wcomis          NUMBER;
      wpnrea          NUMBER;
      ttexto          VARCHAR2 (60);
      wcempres        NUMBER;
      wcramo          NUMBER;
      wcmodali        NUMBER;
      wctipseg        NUMBER;
      wccolect        NUMBER;
      wcactivi        NUMBER;
      wcramdgs        NUMBER;
      wpanula         NUMBER;
      wfanual         DATE;
      wpnrea1         NUMBER;
      anulado         NUMBER;
      wfanulac        DATE;
      wsegrea         NUMBER;
      wgarrea         NUMBER;
      wdetalle        NUMBER;
      wprecseg        NUMBER;
      werror          NUMBER;
      wppnc_prima     NUMBER;
      wppnc_comisi    NUMBER;
      wipppc          NUMBER;
      wmeses          NUMBER;
      wreaseg_aux     NUMBER;
      wprec_aux       NUMBER;
      wseg_aux        NUMBER        := 0;
      i               NUMBER;
      wcomisi         NUMBER;
      wimpcomis       NUMBER;
      wccomisi        NUMBER;
      fechini         DATE;
      wtotreaseg      NUMBER;
      conta_err       NUMBER        := 0;
      calcular        NUMBER        := 0;
      fantigua        DATE;
      estado_rec      NUMBER;
      total_dev       NUMBER;
      total_rec       NUMBER;
      total_com_dev   NUMBER;
      total_com_rec   NUMBER;
      ffin_rec        DATE;
      wprimrea        NUMBER;
      wcom_rea        NUMBER;
      wppnc_rea       NUMBER;
      wppnc_comrea    NUMBER;
      --21715
      v_cramo_aux     NUMBER;
      wpanula6        NUMBER;
      wpanula36       NUMBER;
      wpanula3        NUMBER;
      wpanuljud       NUMBER;
      v_calcporc      NUMBER        := 0;
      wctramo         NUMBER;                 -- Bug 21715 - APD - 03/07/2012
      wnrecibo_aux    NUMBER;           -- Bug 24893/130890.i.NMM.2012.11.28.
      diasgracia      NUMBER;               -- Bug 0026890 - 06/05/2013 - DCG
      diaspartner     NUMBER;               -- Bug 0026890 - 06/05/2013 - DCG
   --
   --
   BEGIN
      IF pmodo = 'R'
      THEN
         OPEN c_polizas (aux_factual, cempres);

         FETCH c_polizas
          INTO seg;
      ELSE
         OPEN c_polizas_previo (aux_factual, cempres);

         FETCH c_polizas_previo
          INTO seg;
      END IF;

      -- Calcularemos la PPPC de los recibos de ahorro
      LOOP
         IF pmodo = 'R' AND c_polizas%NOTFOUND
         THEN
            EXIT;
         ELSIF pmodo = 'P' AND c_polizas_previo%NOTFOUND
         THEN
            EXIT;
         ELSE
            -- Inicializamos las variables
            total_dev := 0;
            total_rec := 0;
            total_com_dev := 0;
            total_com_rec := 0;
            calcular := 0;

            --Bug.: 21715 - 22/03/2012 - ICV
            IF v_cramo_aux IS NULL
            THEN
               v_cramo_aux := seg.cramo;
               v_calcporc := 1;
            ELSIF v_cramo_aux <> seg.cramo
            THEN
               v_cramo_aux := seg.cramo;
               v_calcporc := 1;
            ELSE
               v_calcporc := 0;
            END IF;

            IF NVL (pac_parametros.f_parempresa_n (cempres, 'POR_PPPC_HIST'),
                    0
                   ) = 1
            THEN
               IF NVL (v_calcporc, 0) = 1
               THEN
                  wpanula6 :=
                     NVL (f_calc_porc_anula_pppc (cempres,
                                                  aux_factual,
                                                  seg.cramo,
                                                  NULL,
                                                  6,
                                                  0
                                                 ),
                          100
                         );
                  wpanula36 :=
                     NVL (f_calc_porc_anula_pppc (cempres,
                                                  aux_factual,
                                                  seg.cramo,
                                                  6,
                                                  3,
                                                  0
                                                 ),
                          50
                         );
                  wpanula3 :=
                     NVL (f_calc_porc_anula_pppc (cempres,
                                                  aux_factual,
                                                  seg.cramo,
                                                  3,
                                                  NULL,
                                                  0
                                                 ),
                          25
                         );
               --wpanuljud := f_calc_porc_anula(cempres,aux_factual,seg.cramo,null,null,1); pendiente de definir
               END IF;
            ELSE
               wpanula6 := 100;                           --Mayor que 6 meses
               wpanula36 := 50;                           --Entre 3 y 6 meses
               wpanula3 := 25;                             --Menor de 3 meses
            END IF;

            -- Buscamos la fecha del primer recibo pendiente o en gestión de cobro
            SELECT MIN (r.fefecto)
              INTO fantigua
              FROM movrecibo m, recibos r
             WHERE m.nrecibo = r.nrecibo
               AND m.fmovini <= aux_factual
               AND (m.fmovfin > aux_factual OR m.fmovfin IS NULL)
               AND (   m.cestrec = 0
                    OR (    m.cestrec = 1
                        AND DECODE (NVL (m.ctipcob, -1),
                                    --BUG 35103-200056.KJSC. Se debe sustituir r.cempres por el número de recibo (nrecibo).
                                    -1, m.fmovini
                                     + pac_adm.f_get_diasgest (r.nrecibo),
                                     /*BUG 0010676: 22/09/2009 : NMM -- CEM - Substituïm el paràmetre de rebut pel de companyia */
                                    -- -1, m.fmovini + pac_adm.f_get_diasgest(r.cempres),
                                    m.fmovini
                                   ) > aux_factual
                       -- estan en gestión de cobro
                       )
                   )
               AND r.fefecto <= aux_factual
               AND r.ctiprec <> 9                           --No es un extorno
               AND r.fvencim > seg.fefeini
               AND r.sseguro = seg.sseguro;

            -- Si no hemos encontrado ningún recibo pendiente o en gestión, miramos si tenemos
            --  todos los recibos de la anualidad generados. Si nos falta alguno, realizaremos
            --  el calculo de las PPPC
            IF fantigua IS NOT NULL
            THEN
               calcular := 1;
            END IF;

            IF calcular = 1
            THEN
               -- Calculamos la antigüedad de la prima pendiente más antigua, para calcular
               --  el coeficiente a aplicar
               wmeses := MONTHS_BETWEEN (aux_factual, fantigua);
               wpanula := seg.panula;

               IF wpanula IS NULL OR wpanula = 0
               THEN                 -- no tenemos un coeficiente de anulación
                  IF wmeses >= 6
                  THEN
                     wpanula := wpanula6;
                     wctramo := 3;            -- Bug 21715 - APD - 03/07/2012
                  ELSIF wmeses >= 3 AND wmeses < 6
                  THEN
                     wpanula := wpanula36;
                     wctramo := 2;            -- Bug 21715 - APD - 03/07/2012
                  ELSE
                     wpanula := wpanula3;
                     wctramo := 1;            -- Bug 21715 - APD - 03/07/2012
                  END IF;
               END IF;

               -- CPM 2/4/08: Cogemos las primas devengadas ya calculadas en las ppnc
               total_dev := seg.ipridev;
               total_com_dev := seg.icomage;

               -- Abrimos el cursor de los recibos
               FOR det IN c_detalle (seg.sseguro,
                                     seg.fefeini,
                                     seg.ffinefe,
                                     seg.cgarant,
                                     seg.nriesgo,
                                     aux_factual
                                    )
               LOOP
                  --dbms_output.put_line('nrecibo='||det.nrecibo||' cgarant='||seg.cgarant||' valor='||det.prima);
                  --dbms_output.put_line('antes total_rec='||total_rec);

                  -- Acumulamos los valores
                  wprimcom := det.prima;
                  total_rec := total_rec + wprimcom;
                  ffin_rec := det.fvencim;
                  --dbms_output.put_line('total_rec='||total_rec);
                  --dbms_output.put_line('total_dev='||total_dev);
                  wcomisi := det.comisio;
                  total_com_rec := total_com_rec + wcomisi;

                  --DBMS_OUTPUT.put_line('recibo=' || det.nrecibo || ' det.ctiprec='
                  --                     || det.ctiprec);

                  -- Si tenemos un suplemento no tendremos en cuenta la PPNC pues ja la tienen
                  -- en cuenta el resto de recibos (pero si su prima)
                  IF det.ctiprec = 1
                  THEN                                     --Es un suplemento
                     -- Bug 24893/130890.i.NMM.2012.11.28.
                     BEGIN
                        SELECT MIN (nrecibo)
                          INTO wnrecibo_aux
                          FROM detrecibos
                         WHERE cgarant = seg.cgarant
                           AND nrecibo IN (
                                  SELECT nrecibo
                                    FROM recibos
                                   WHERE sseguro = seg.sseguro
                                         AND ctiprec <> 9);
                     END;

                     IF wnrecibo_aux = det.nrecibo
                     THEN
                        werror := 0;
                     ELSE
                        --DBMS_OUTPUT.put_line('valor=' || 0);
                        -- Bug 24893/130890.f.NMM.2012.11.28.
                        werror := 2;                       -- Es un suplement
                     END IF;
                  ELSE
                     werror := 0;
                  END IF;

                  -- Bug 24893 y 21715 CPM: Se reestructura teniendo en cuenta si calculamos o no prima no consumida, teniendo
                  -- en cuenta los casos en los que no ser realizará el cálculo, en caso de suplemento (werror = 2) o en caso
                  -- de que el recibo esté cobrado o anulado.
                  IF werror = 0
                  THEN
                     -- Miramos en que estado está este recibo en la fecha de cálculo
                     BEGIN
                        SELECT cestrec
                          INTO estado_rec
                          FROM movrecibo m, recibos r
                         WHERE m.nrecibo = r.nrecibo
                           AND m.fmovini <= aux_factual
                           AND (m.fmovfin > aux_factual OR m.fmovfin IS NULL
                               )
                           AND (   m.cestrec = 0
                                OR (    m.cestrec = 1
                                    AND DECODE
                                           (NVL (m.ctipcob, -1),
                                            -1, m.fmovini
                                             --BUG 35103-200056.KJSC. Se debe sustituir r.cempres por el número de recibo (nrecibo).
                                             + pac_adm.f_get_diasgest
                                                                    (r.nrecibo),
                                            /*BUG 0010676: 22/09/2009 : NMM -- CEM - Substituïm el paràmetre de rebut pel de companyia */
                                            --  + pac_adm.f_get_diasgest(r.cempres),
                                            m.fmovini
                                           ) > aux_factual
                                   -- estan en gestión de cobro
                                   )
                               )
                           AND r.nrecibo = det.nrecibo;

                        --DBMS_OUTPUT.put_line('recibo=' || det.nrecibo || ' cestrec='
                        --                     || estado_rec);
                        werror := 0;
                     --p_control_error('PPPC',det.nrecibo||'-'||seg.nriesgo, 'wrea='||wipppc||' wsin_rea='||(wprimcom - wcomisi - wppnc_prima + wppnc_comisi));
                     EXCEPTION
                        WHEN OTHERS
                        THEN
                           IF det.femisio > aux_factual
                           THEN -- No estaba creado en la fecha del cálculo
                                -- por tanto, consideramos que está pendiente
                              werror := 0;
                           ELSE              -- El rebut està cobrat o anulat.
                              --DBMS_OUTPUT.put_line('cobrat o anulat');
                              wipppc := 0;
                              werror := 1;
                           END IF;
                     END;
                  END IF;

                  IF werror <> 2
                  THEN                                   -- No es un suplement
                     wppnc_prima :=
                        f_round (  seg.iprincs
                                 * (det.fvencim - det.fefecto)
                                 / (seg.ffinefe - seg.fefeini),
                                 pcmoneda
                                );
                     wppnc_comisi :=
                        f_round (  seg.icomncs
                                 * (det.fvencim - det.fefecto)
                                 / (seg.ffinefe - seg.fefeini),
                                 pcmoneda
                                );
                     wprimrea :=
                        NVL (f_round (  seg.ipdevrc
                                      * (det.fvencim - det.fefecto)
                                      / (seg.ffinefe - seg.fefeini),
                                      pcmoneda
                                     ),
                             0
                            );
                     wcom_rea :=
                        NVL (f_round (  seg.icomrc
                                      * (det.fvencim - det.fefecto)
                                      / (seg.ffinefe - seg.fefeini),
                                      pcmoneda
                                     ),
                             0
                            );
                     wppnc_rea :=
                        NVL (f_round (  seg.ipncsrc
                                      * (det.fvencim - det.fefecto)
                                      / (seg.ffinefe - seg.fefeini),
                                      pcmoneda
                                     ),
                             0
                            );
                     wppnc_comrea :=
                        NVL (f_round (  seg.icncsrc
                                      * (det.fvencim - det.fefecto)
                                      / (seg.ffinefe - seg.fefeini),
                                      pcmoneda
                                     ),
                             0
                            );
                  --p_control_error('PPPC 2',det.nrecibo||'-'||seg.nriesgo, 'wprimrea='||wprimrea||' wcom_rea='||wcom_rea||' wppnc_rea='||wppnc_rea||'wppnc_comrea'||wppnc_comrea);
                  ELSE
                     wppnc_prima := 0;
                     wppnc_comisi := 0;
                     wprimrea := 0;
                     wppnc_rea := 0;
                     wcom_rea := 0;
                     wppnc_comrea := 0;
                  END IF;

                  IF werror <> 1
                  THEN
                     -- CPM 04/12/12 24893: El rebut no està cobrat (pot ser un suplement)
                                 --DBMS_OUTPUT.put_line('22 wprimrea=' || wprimrea || ' wcom_rea='
                                 --                     || wcom_rea || ' wppnc_rea=' || wppnc_rea
                                 --                     || 'wppnc_comrea' || wppnc_comrea);
                                 -- Bug 0026890 - 06/05/2013 - DCG - Ini
                     IF NVL (f_parproductos_v (seg.sproduc, 'GRACIA_PPPC'),
                             0) = 1
                     THEN
                        BEGIN
                           SELECT crespue
                             INTO diasgracia
                             FROM pregunpolseg
                            WHERE cpregun = 9015
                              AND sseguro = seg.sseguro
                              AND nmovimi = seg.nmovimi;
                        EXCEPTION
                           WHEN OTHERS
                           THEN
                              diasgracia := 0;
                        END;

                        BEGIN
                           SELECT crespue
                             INTO diaspartner
                             FROM pregunpolseg
                            WHERE cpregun = 427
                              AND sseguro = seg.sseguro
                              AND nmovimi = seg.nmovimi;
                        EXCEPTION
                           WHEN OTHERS
                           THEN
                              diaspartner := 0;
                        END;

                        IF (det.fefecto + diasgracia + diaspartner) >=
                                                                   aux_factual
                        THEN
                           wipppc := 0;
                        ELSE
                           wipppc :=
                                wprimcom
                              - wcomisi
                              - wppnc_prima
                              + wppnc_comisi
                              - (wprimrea - wppnc_rea - wcom_rea
                                 + wppnc_comrea
                                );
                        END IF;
                     ELSE
                        -- Bug 0026890 - 06/05/2013 - DCG - Fi
                        wipppc :=
                             wprimcom
                           - wcomisi
                           - wppnc_prima
                           + wppnc_comisi
                           - (wprimrea - wppnc_rea - wcom_rea + wppnc_comrea
                             );
                     -- Bug 0026890 - 06/05/2013 - DCG - Ini
                     END IF;
                  -- Bug 0026890 - 06/05/2013 - DCG - Fi
                  ELSE
                     wipppc := 0;
                  END IF;

                  -- Fi Bug 24893 y 21715 CPM

                  --dbms_output.put_line('wipppc='||wipppc);
                  wipppc := f_round (wipppc * (wpanula / 100), pcmoneda);

                  -- Insertamos los datos del recibo en la tabla correspondiente
                  BEGIN
                     IF pmodo = 'R'
                     THEN
                        -- Bug 21715 - APD - 02/07/2012 - se añaden los campos ipdevrc, ipncsrc, icomrc, icncsrc, ttramo
                        INSERT INTO pppc
                                    (cempres, fcalcul, sproces,
                                     cramdgs, cramo, cmodali,
                                     ctipseg, ccolect, sseguro,
                                     nrecibo, cgarant, nriesgo,
                                     nmovimi, finiefe, ipppc,
                                     cerror, iprimcom, ippncprima,
                                     ippnccomis, prea, pcom, icomis,
                                     ipdevrc, ipncsrc, icomrc,
                                     icncsrc, ctramo
                                    )
                             VALUES (cempres, aux_factual, psproces,
                                     seg.cramdgs, seg.cramo, seg.cmodali,
                                     seg.ctipseg, seg.ccolect, seg.sseguro,
                                     det.nrecibo, seg.cgarant, seg.nriesgo,
                                     seg.nmovimi, det.fefecto, wipppc,
                                     werror, wprimcom, wppnc_prima,
                                     wppnc_comisi, NULL, wpanula, wcomisi,
                                     wprimrea, wppnc_rea, wcom_rea,
                                     wppnc_comrea, wctramo
                                    );
                     ELSIF pmodo = 'P'
                     THEN
                        --dbms_output.put_line('Inserto previo. Sseguro= '||seg.sseguro||' - nrecibo='||det.nrecibo);
                        -- Bug 21715 - APD - 02/07/2012 - se añaden los campos ipdevrc, ipncsrc, icomrc, icncsrc, ttramo
                        INSERT INTO pppc_previo
                                    (cempres, fcalcul, sproces,
                                     cramdgs, cramo, cmodali,
                                     ctipseg, ccolect, sseguro,
                                     nrecibo, cgarant, nriesgo,
                                     nmovimi, finiefe, ipppc,
                                     cerror, iprimcom, ippncprima,
                                     ippnccomis, prea, pcom, icomis,
                                     ipdevrc, ipncsrc, icomrc,
                                     icncsrc, ctramo
                                    )
                             VALUES (cempres, aux_factual, psproces,
                                     seg.cramdgs, seg.cramo, seg.cmodali,
                                     seg.ctipseg, seg.ccolect, seg.sseguro,
                                     det.nrecibo, seg.cgarant, seg.nriesgo,
                                     seg.nmovimi, det.fefecto, wipppc,
                                     werror, wprimcom, wppnc_prima,
                                     wppnc_comisi, NULL, wpanula, wcomisi,
                                     wprimrea, wppnc_rea, wcom_rea,
                                     wppnc_comrea, wctramo
                                    );
                     END IF;
                  EXCEPTION
                     WHEN DUP_VAL_ON_INDEX
                     THEN
                        NULL;
                     WHEN OTHERS
                     THEN
                        ttexto := SUBSTR ('ALTRE ERROR ' || SQLERRM, 1, 60);
                        num_err := 103869;
                        EXIT;
                  END;
               END LOOP;

                       -- Miramos si existe prima todavía por cobrar. Si es así, construiremos un
                       --  recibo con el importe pendiente y realizaremos el cálculo de la PPPC
               --dbms_output.put_line(total_dev ||'>'|| total_rec);
               IF total_dev > total_rec
               THEN
                  wprimcom := total_dev - total_rec;
                  wppnc_prima :=
                     f_round (  seg.iprincs
                              * (seg.ffinefe - ffin_rec)
                              / (seg.ffinefe - seg.fefeini),
                              pcmoneda
                             );
                  wcomisi := total_com_dev - total_com_rec;
                  wppnc_comisi :=
                     f_round (  seg.icomncs
                              * (seg.ffinefe - ffin_rec)
                              / (seg.ffinefe - seg.fefeini),
                              pcmoneda
                             );
                  wprimrea :=
                     NVL (f_round (  seg.ipdevrc
                                   * (seg.ffinefe - ffin_rec)
                                   / (seg.ffinefe - seg.fefeini),
                                   pcmoneda
                                  ),
                          0
                         );
                  wcom_rea :=
                     NVL (f_round (  seg.icomrc
                                   * (seg.ffinefe - ffin_rec)
                                   / (seg.ffinefe - seg.fefeini),
                                   pcmoneda
                                  ),
                          0
                         );
                  wppnc_rea :=
                     NVL (f_round (  seg.ipncsrc
                                   * (seg.ffinefe - ffin_rec)
                                   / (seg.ffinefe - seg.fefeini),
                                   pcmoneda
                                  ),
                          0
                         );
                  wppnc_comrea :=
                     NVL (f_round (  seg.icncsrc
                                   * (seg.ffinefe - ffin_rec)
                                   / (seg.ffinefe - seg.fefeini),
                                   pcmoneda
                                  ),
                          0
                         );
                  wipppc :=
                       wprimcom
                     - wcomisi
                     - wppnc_prima
                     + wppnc_comisi
                     - (wprimrea - wppnc_rea - wcom_rea + wppnc_comrea);
                  wipppc := f_round (wipppc * (wpanula / 100), pcmoneda);

                  --dbms_output.put_line('Valores ippc'||wprimcom||'*'||wppnc_prima||'*'||wcomisi||'*'||wppnc_comisi||'*'||wipppc);
                  BEGIN
                     IF pmodo = 'R'
                     THEN
                        -- Bug 21715 - APD - 02/07/2012 - se añaden los campos ipdevrc, ipncsrc, icomrc, icncsrc
                        INSERT INTO pppc
                                    (cempres, fcalcul, sproces,
                                     cramdgs, cramo, cmodali,
                                     ctipseg, ccolect, sseguro,
                                     nrecibo, cgarant, nriesgo,
                                     nmovimi, finiefe, ipppc, cerror,
                                     iprimcom, ippncprima, ippnccomis,
                                     prea, pcom, icomis, ipdevrc,
                                     ipncsrc, icomrc, icncsrc
                                    )
                             VALUES (cempres, aux_factual, psproces,
                                     seg.cramdgs, seg.cramo, seg.cmodali,
                                     seg.ctipseg, seg.ccolect, seg.sseguro,
                                     99999999, seg.cgarant, seg.nriesgo,
                                     seg.nmovimi, ffin_rec, wipppc, werror,
                                     wprimcom, wppnc_prima, wppnc_comisi,
                                     NULL, wpanula, wcomisi, wprimrea,
                                     wppnc_rea, wcom_rea, wppnc_comrea
                                    );
                     ELSIF pmodo = 'P'
                     THEN
                        --dbms_output.put_line('Inserto previo. Sseguro= '||seg.sseguro||' - nrecibo=999999');
                        -- Bug 21715 - APD - 02/07/2012 - se añaden los campos ipdevrc, ipncsrc, icomrc, icncsrc
                        INSERT INTO pppc_previo
                                    (cempres, fcalcul, sproces,
                                     cramdgs, cramo, cmodali,
                                     ctipseg, ccolect, sseguro,
                                     nrecibo, cgarant, nriesgo,
                                     nmovimi, finiefe, ipppc, cerror,
                                     iprimcom, ippncprima, ippnccomis,
                                     prea, pcom, icomis, ipdevrc,
                                     ipncsrc, icomrc, icncsrc
                                    )
                             VALUES (cempres, aux_factual, psproces,
                                     seg.cramdgs, seg.cramo, seg.cmodali,
                                     seg.ctipseg, seg.ccolect, seg.sseguro,
                                     99999999, seg.cgarant, seg.nriesgo,
                                     seg.nmovimi, ffin_rec, wipppc, werror,
                                     wprimcom, wppnc_prima, wppnc_comisi,
                                     NULL, wpanula, wcomisi, wprimrea,
                                     wppnc_rea, wcom_rea, wppnc_comrea
                                    );
                     END IF;
                  EXCEPTION
                     WHEN DUP_VAL_ON_INDEX
                     THEN
                        NULL;
                     WHEN OTHERS
                     THEN
                        ttexto := SUBSTR ('ALTRE ERROR 2 ' || SQLERRM, 1, 60);
                        num_err := 103869;
                  --exit;
                  END;
               END IF;

               IF num_err != 0
               THEN
                  ROLLBACK;
                  num_err :=
                     f_proceslin (psproces,
                                  ttexto || ' - PPPC',
                                  seg.sseguro,
                                  nlin
                                 );
                  nlin := NULL;
                  conta_err := conta_err + 1;
               END IF;

               COMMIT;
            END IF;
         END IF;

         IF pmodo = 'R'
         THEN
            FETCH c_polizas
             INTO seg;
         ELSE
            FETCH c_polizas_previo
             INTO seg;
         END IF;
      END LOOP;

      IF c_polizas%ISOPEN
      THEN
         CLOSE c_polizas;
      END IF;

      IF c_polizas_previo%ISOPEN
      THEN
         --dbms_output.put_line('tanquem 2 ='||aux_factual);
         CLOSE c_polizas_previo;
      END IF;

      -- Insertamos los recibos de ahorro
      BEGIN
         FOR rah IN c_recibos_ahorro (aux_factual, cempres)
         LOOP
            IF pmodo = 'R'
            THEN
               INSERT INTO pppc
                           (cempres, fcalcul, sproces, cramdgs,
                            cramo, cmodali, ctipseg,
                            ccolect, sseguro, nrecibo,
                            cgarant, nriesgo, nmovimi,
                            finiefe,
                            ipppc, cerror,
                            iprimcom, ippncprima, ippnccomis, prea, pcom,
                            icomis
                           )
                    VALUES (cempres, aux_factual, psproces, rah.cramdgs,
                            rah.cramo, rah.cmodali, rah.ctipseg,
                            rah.ccolect, rah.sseguro, rah.nrecibo,
                            rah.cgarant, rah.nriesgo, rah.nmovimi,
                            rah.fefecto,
                            ROUND (rah.iconcep * (rah.panula / 100), 2), 0,
                            rah.iconcep, 0, 0, NULL, rah.panula,
                            0
                           );
            ELSIF pmodo = 'P'
            THEN
               INSERT INTO pppc_previo
                           (cempres, fcalcul, sproces, cramdgs,
                            cramo, cmodali, ctipseg,
                            ccolect, sseguro, nrecibo,
                            cgarant, nriesgo, nmovimi,
                            finiefe,
                            ipppc, cerror,
                            iprimcom, ippncprima, ippnccomis, prea, pcom,
                            icomis
                           )
                    VALUES (cempres, aux_factual, psproces, rah.cramdgs,
                            rah.cramo, rah.cmodali, rah.ctipseg,
                            rah.ccolect, rah.sseguro, rah.nrecibo,
                            rah.cgarant, rah.nriesgo, rah.nmovimi,
                            rah.fefecto,
                            ROUND (rah.iconcep * (rah.panula / 100), 2), 0,
                            rah.iconcep, 0, 0, NULL, rah.panula,
                            0
                           );
            END IF;
         END LOOP;
      EXCEPTION
         WHEN OTHERS
         THEN
            ttexto := SUBSTR ('ALTRE ERROR 3 ' || SQLERRM, 1, 60);
            ROLLBACK;
            num_err :=
                      f_proceslin (psproces, ttexto || ' - PPPC', NULL, nlin);
            nlin := NULL;
            conta_err := conta_err + 1;
      END;

      COMMIT;
      RETURN (conta_err);
   EXCEPTION
      WHEN OTHERS
      THEN
         IF c_polizas%ISOPEN
         THEN
            CLOSE c_polizas;
         END IF;

         IF c_polizas_previo%ISOPEN
         THEN
            CLOSE c_polizas_previo;
         END IF;

         p_tab_error (f_sysdate,
                      f_user,
                      'CIERRE PPPC =' || psproces,
                      NULL,
                      'when others del cierre =' || aux_factual,
                      SQLERRM
                     );
         RETURN (GREATEST (NVL (conta_err, 0), 1));
   END f_commit_calcul_pppc;

-- Bug 0026214 - 11/06/2013 - DCG - Ini
   FUNCTION f_commit_calcul_pppc_sam (
      cempres       IN   NUMBER,
      aux_factual   IN   DATE,
      psproces      IN   NUMBER,
      pcidioma      IN   NUMBER,
      pcmoneda      IN   NUMBER,
      pmodo         IN   VARCHAR2 DEFAULT 'R'
   )
      RETURN NUMBER
   IS
      num_err        NUMBER        := 0;
      nlin           NUMBER;
      wprimcom       NUMBER;
      ttexto         VARCHAR2 (60);
      wpanula        NUMBER;
      werror         NUMBER;
      wppnc_prima    NUMBER;
      wppnc_comisi   NUMBER;
      wipppc         NUMBER;
      wcomisi        NUMBER;
      conta_err      NUMBER        := 0;
      wprimrea       NUMBER;
      wcom_rea       NUMBER;
      wppnc_rea      NUMBER;
      wppnc_comrea   NUMBER;
      wctramo        NUMBER;
      diasgracia     NUMBER;
      diaspartner    NUMBER;
      wcobparc       NUMBER;
      vdif           NUMBER;
   --
   --
   BEGIN
      OPEN c_recibos_sam (aux_factual, cempres);

      FETCH c_recibos_sam
       INTO rec;

      -- Calcularemos la PPPC de los recibos incobrables
      LOOP
         IF c_recibos_sam%NOTFOUND
         THEN
            EXIT;
         ELSE
            -- Bug 0026430 - 11/03/2014 - JMF - No contar los parciales
            IF NVL (f_parproductos_v (rec.sproduc, 'GRACIA_PPPC'), 0) = 1
            THEN
               IF pac_provnotec.f_fecprov
                                         (rec.sproduc,
                                          rec.sseguro,
                                          rec.nmovimi,
                                          rec.fefecto,
                                          NULL
                                         )             --5.0 AQ >= aux_factual
                                          > aux_factual
               THEN                                         --34194 16/01/2105
                  wipppc := 0;
               -- Bug 0026430 - 11/03/2014 - JMF - No contar los parciales
               ELSE
                  BEGIN
                    SELECT SUM (NVL (iconcep, 0))
                       INTO wcobparc
                       FROM detmovrecibo_parcial dp, detmovrecibo d
                      WHERE dp.nrecibo = rec.nrecibo
                        AND cconcep IN (0)
                        AND cgarant = rec.cgarant
                        AND nriesgo = rec.nriesgo
                        and dp.nrecibo = d.nrecibo
                        and dp.smovrec = d.smovrec
                        and dp.norden = d.norden
                        and trunc(d.fmovimi) < aux_factual;
                  EXCEPTION
                     WHEN OTHERS
                     THEN
                        wcobparc := 0;
                  END;

                  vdif := rec.iimporte - nvl(wcobparc,0);

                  --5.0 AQ STart
                  SELECT pac_eco_tipocambio.f_importe_cambio
                                  ((SELECT m.cmonint
                                      FROM monedas m, productos pr
                                     WHERE m.cidioma = pcidioma
                                       AND m.cmoneda = pr.cdivisa
                                       AND pr.sproduc = rec.sproduc),
                                   (SELECT pac_monedas.f_cmoneda_t (nvalpar)
                                      FROM parempresas
                                     WHERE cempres = f_parinstalacion_n('EMPRESADEF') -- 38020.NMM
                                       AND cparam = 'MONEDACONTAB'),
                                   aux_factual,
                                   vdif,
                                   1
                                  )
                    INTO wipppc
                    FROM DUAL;
                --wipppc := rec.iimporte;
               --5.0 Fi AQ
               END IF;
            ELSE
               wipppc := 0;
            END IF;

            werror := 0;
            wprimcom := 0;
            wppnc_prima := 0;
            wppnc_comisi := 0;
            wpanula := 100;
            wcomisi := 0;
            wprimrea := 0;
            wppnc_rea := 0;
            wcom_rea := 0;
            wppnc_comrea := 0;
            wctramo := 3;

            IF wipppc <> 0
            THEN
               BEGIN
                  IF pmodo = 'R'
                  THEN
                     INSERT INTO pppc
                                 (cempres, fcalcul, sproces,
                                  cramdgs, cramo, cmodali,
                                  ctipseg, ccolect, sseguro,
                                  nrecibo, cgarant, nriesgo,
                                  nmovimi, finiefe, ipppc, cerror,
                                  iprimcom, ippncprima, ippnccomis, prea,
                                  pcom, icomis, ipdevrc, ipncsrc,
                                  icomrc, icncsrc, ctramo
                                 )
                          VALUES (cempres, aux_factual, psproces,
                                  rec.cramdgs, rec.cramo, rec.cmodali,
                                  rec.ctipseg, rec.ccolect, rec.sseguro,
                                  rec.nrecibo, rec.cgarant, rec.nriesgo,
                                  rec.nmovimi, rec.fefecto, wipppc, werror,
                                  wprimcom, wppnc_prima, wppnc_comisi, NULL,
                                  wpanula, wcomisi, wprimrea, wppnc_rea,
                                  wcom_rea, wppnc_comrea, wctramo
                                 );
                  ELSIF pmodo = 'P'
                  THEN
                     --dbms_output.put_line('Inserto previo. Sseguro= '||rec.sseguro||' - nrecibo='||det.nrecibo);
                     INSERT INTO pppc_previo
                                 (cempres, fcalcul, sproces,
                                  cramdgs, cramo, cmodali,
                                  ctipseg, ccolect, sseguro,
                                  nrecibo, cgarant, nriesgo,
                                  nmovimi, finiefe, ipppc, cerror,
                                  iprimcom, ippncprima, ippnccomis, prea,
                                  pcom, icomis, ipdevrc, ipncsrc,
                                  icomrc, icncsrc, ctramo
                                 )
                          VALUES (cempres, aux_factual, psproces,
                                  rec.cramdgs, rec.cramo, rec.cmodali,
                                  rec.ctipseg, rec.ccolect, rec.sseguro,
                                  rec.nrecibo, rec.cgarant, rec.nriesgo,
                                  rec.nmovimi, rec.fefecto, wipppc, werror,
                                  wprimcom, wppnc_prima, wppnc_comisi, NULL,
                                  wpanula, wcomisi, wprimrea, wppnc_rea,
                                  wcom_rea, wppnc_comrea, wctramo
                                 );
                  END IF;
               EXCEPTION
                  WHEN DUP_VAL_ON_INDEX
                  THEN
                     NULL;
                  WHEN OTHERS
                  THEN
                     ttexto :=
                              SUBSTR ('ALTRE ERROR INCOB.' || SQLERRM, 1, 60);
                     num_err := 103869;
                     EXIT;
               END;
            END IF;

            IF num_err != 0
            THEN
               ROLLBACK;
               num_err :=
                  f_proceslin (psproces,
                               ttexto || ' - INCOB',
                               rec.sseguro,
                               nlin
                              );
               nlin := NULL;
               conta_err := conta_err + 1;
            END IF;

            COMMIT;
         END IF;

         FETCH c_recibos_sam
          INTO rec;
      END LOOP;

      COMMIT;
      RETURN (conta_err);
   EXCEPTION
      WHEN OTHERS
      THEN
         IF c_recibos_sam%ISOPEN
         THEN
            CLOSE c_recibos_sam;
         END IF;

         p_tab_error (f_sysdate,
                      f_user,
                      'CIERRE PPPC_SAM =' || psproces,
                      NULL,
                      'when others del cierre =' || aux_factual,
                      SQLERRM
                     );
         RETURN (GREATEST (NVL (conta_err, 0), 1));
   END f_commit_calcul_pppc_sam;
-- Bug 0026214 - 11/06/2013 - DCG - Fi
END pac_provnotec;

/

  GRANT EXECUTE ON "AXIS"."PAC_PROVNOTEC" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_PROVNOTEC" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_PROVNOTEC" TO "PROGRAMADORESCSI";
