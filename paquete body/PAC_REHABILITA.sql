--------------------------------------------------------
--  DDL for Package Body PAC_REHABILITA
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY PAC_REHABILITA IS

/******************************************************************************
     NOMBRE:       PAC_REHABILITA
     PROP¿SITO:  Package para gestionar las rehabilitaciones de p¿lizas.

     REVISIONES:
     Ver        Fecha        Autor             Descripci¿n
     ---------  ----------  ---------------  ------------------------------------
     2.0        11/05/2009   ICV               2. Adaptaci¿n para IAX Bug.: 9784
     3.0        05/11/2009   JMF               3. bug 0011653 CRE - Anulaci¿n de recibos de colectivos
     4.0        12/01/2010   DRA               4. 0010093: CRE - Afegir filtre per RAM en els cercadors
     5.0        23/02/2010   LCF               5. 0009605: BUSCADORS - Afegir matricula,cpostal,desc
     6.0        25/08/2011   JMF               6. 0019274 LCOL_T001 - Rehabilitaciones control l¿mite tiempo desde que se anul¿ la p¿liza
     7.0        12/09/2011   JMF               7. 0019444: LCOL_T04: Parametrizaci¿n Rehabilitaci¿n
     8.0        11/10/2011   JMF               8. 0019743: LCOL: Rehabilitaci¿n: generar un recibo por cada recibo anulado en lugar de 1 agrupado
     9.0        14/11/2011   FAL               9. 0019627: GIP102 - Reunificaci¿n de recibos
    10.0        14/11/2011   APD              10. 0018946: LCOL_P001 - PER - Visibilidad en personas
    11.0        14/11/2011   RSC              11. 0019444: LCOL_T04: Parametrizaci¿n Rehabilitaci¿n
    12.0        20/01/2012   APD              12. 0020664: LCOL_T001-LCOL - UAT - TEC - Anulaciones y Rehabilitaciones
    13.0        07/02/2012   JMF              13. 0021028 LCOL - Duplicar rebuts en rehabilitacions de polisses
    14.0        10/10/2012   JMF              14. 0024003: LCOL: Rehabilitaci¿n de p¿lizas generaci¿n retorno
    15.0        14/08/2012   DCG              15. 0023183: LCOL_T020-COA-Circuit d'alta de propostes amb coasseguran
    16.0        13/11/2012   DCT              16. 0023817: LCOL - Anulaci¿n de colectivos
    17.0        21/11/2012   DRA              17. 0024802: LCOL_C001-LCOL: Anulaci?n de p?liza con co-corretaje
    18.0        27/02/2013   ECP              18. 0026070: LCOL_T010-LCOL - Revision incidencias qtracker (V). Nota 139289
    19.0        04/06/2013   ECP              19. 0026488: LCOL_T010-LCOL - Revision incidencias qtracker (VI) Nota 145822
    20.0        15/07/2013   JDS              20. 0027539: LCOL_T010-LCOL - Revision incidencias qtracker (VII)
    21.0        25/11/2013   DCT              21. 0024450 - INICIO - DCT - 25/11/2013 - LCOL_T010-LCOL - SUPLEMENTO DE SUSPENSI?N Y REINICIO DE VIGENCIAS
    22.0        10/02/2014   RDD              22. 0030017: 0010694: IAXIS NO ENVIA RECIBOS DE RETORNOS CUANDO SE GENERA LA REHABILITACI¿N DE UNA P¿LIZA
    23.0        04/03/2014   JGR              23. 0029431#c168400: LCOL_MILL-10603: + 10429#c57215 - Rehabilitaci¿n Anule recibos ctiprec = 14
    24.0        27/03/2014   MMM              24. 0030713: LCOL_F002-0011957-11958-11959: Se realizo anulacion en polizas...
    25.0        16/04/2014   JLTS             25. 0030417_0171145: Rehabilitaci¿n de un movimiento 322
    26.0        25/09/2014   RDD              26. 0028974: MSV0003-Desarrollo de Comisiones (COM04-Commercial Network Management)
    27.0        08/07/2015   ACL              27. 35888/209603 quitar UPPER a NNUMNIF
    28.0        28/05/2019   ECP              28. IAXIS-3592. Proceso de terminación por no pago
 ******************************************************************************/

   -- BUG 0024450 - INICIO - DCT - 25/11/2013 - LCOL_T010-LCOL - SUPLEMENTO DE SUSPENSI?N Y REINICIO DE VIGENCIAS. A¿adir pcmodo
   -- BUG0011653-05/11/2009-JMF-Canvi funci¿ afegir pcero.
   -- Antiga funci¿ F_REC_REHAB inclosa dins el package i renombrada com F_RECIBOS
   FUNCTION f_genrec(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pnrecibo OUT NUMBER,
      pcero IN NUMBER DEFAULT NULL,
      pcmodo IN NUMBER DEFAULT 0)
      RETURN NUMBER IS
      -- Bug 0024003 - 10/10/2012 - JMF
      vobj           VARCHAR2(200) := 'PAC_REHABILITA.f_genrec';
      vpar           VARCHAR2(200)
         := 'seg=' || psseguro || ' mov=' || pnmovimi || ' cer=' || pcero || ' pcmodo='
            || pcmodo;
      vpas           NUMBER := 1;
      xfcaranu       DATE;
      -- ini Bug 0031321 - 19/05/2014 - JMF
      d_xmovanul     DATE;
      -- d_xmovreha     DATE; -- bug 0032844 - 19/09/2014 - JMF
      -- fin Bug 0031321 - 19/05/2014 - JMF
      d_movdiadesde  DATE;   -- bug 0032844 - 19/09/2014 - JMF
      xfmovini       DATE;
      xcestrec       NUMBER;
      dummy          NUMBER;
      xsmovrec       NUMBER := 0;
      xnliqmen       NUMBER;
      error          NUMBER;
      xcagente       NUMBER;
      xcdelega       NUMBER;
      xfefecto       DATE;
      xfvencim       DATE;
      xtotprimaneta  NUMBER;
      xtotconsorcio  NUMBER;
      xnrecibo       NUMBER;
      vtipcer        VARCHAR2(10);   -- BUG0011653-05/11/2009-JMF
      n_sproduc      seguros.sproduc%TYPE;   -- Bug 0019743 - 11/10/2011 - JMF
      num_err        NUMBER := 0;
      v_cempres      NUMBER;
      v_nreciboclon  recibos.nrecibo%TYPE;   -- Bug 0021028 - 07/02/2012 - JMF
      v_retctiprec   recibos.ctiprec%TYPE;
      xfmovim        DATE;
      vcmotmov       movseguro.cmotmov%TYPE;

      -- ini bug 0032844 - 19/09/2014 - JMF
      --
      -- Caso p¿lizas temporales con 18 meses de anualidad o anulaciones anteriores a una anualidad,
      -- al realizar la rehabilitaci¿n no se restauran los recibos ya que existia una limitaci¿n
      -- de que el efecto del recibo fuera superior a la anualidad del seguro menos un a¿o.
      -- Se modifica para que busque por fecha de movimiento, teniendo en cuenta si existen movimientos
      -- de anulaciones, rehabilitaciones o ambas acciones en una p¿liza antes de rehabilitar.
      -- Tener en cuenta tambi¿n las suspensiones.
      -- fin bug 0032844 - 19/09/2014 - JMF
      --
      -- CURSOR recs_anul(cfdesde DATE, d_movdia DATE) IS
      CURSOR recs_anul(pc_movdia DATE) IS
         SELECT   d.cconcep concepto, d.cgarant garantia, d.nriesgo riesgo,
                  SUM(d.iconcep * DECODE(r.ctiprec, 9, -1, 1)) total
             FROM recibos r, movrecibo m, detrecibos d, movseguro ms
            WHERE r.nrecibo = m.nrecibo
              AND r.nrecibo = d.nrecibo
              AND r.sseguro = ms.sseguro
              AND r.nmovimi = ms.nmovimi
              AND r.esccero = NVL(pcero, r.esccero)   -- BUG0011653-05/11/2009-JMF
              AND m.fmovfin IS NULL
              AND r.sseguro = psseguro
              AND d.cconcep NOT IN(21, 15, 16, 71, 65, 66)   -- todos los conceptos excepto las ventas
              AND m.cestrec = 2   -- recibos anulados
              -- AND r.fefecto >= cfdesde   -- l¿mite inferior a tratar -- bug 0032844 - 19/09/2014 - JMF
              -- a partir de la darrera rehabilitaci¿
              AND m.fmovdia >= NVL(pc_movdia, m.fmovdia - 1)   -- bug 0032844 - 19/09/2014 - JMF
              -- BUG 0024450 - INICIO - DCT - 25/11/2013 - LCOL_T010-LCOL - SUPLEMENTO DE SUSPENSI?N Y REINICIO DE VIGENCIAS.
              --AND m.cmotmov <> 1   -- que no sea anulaci¿n por reemplazo
              AND m.cmotmov = DECODE(pcmodo, 0, 0, 391)
              -- BUG 0024450 - FIN - DCT - 25/11/2013 - LCOL_T010-LCOL - SUPLEMENTO DE SUSPENSI?N Y REINICIO DE VIGENCIAS. A¿adir pcmodo
              AND ms.cmovseg NOT IN(6, 3)   -- que no sea de regularizaci¿n
              AND r.ctiprec NOT IN(13, 15)   -- Bug 0024003 - 11/10/2012 - JMF
         GROUP BY d.cconcep, d.cgarant, d.nriesgo
         UNION
         SELECT   DECODE(d.cconcep,
                         0, 21,   -- prima neta a prima devengada
                         11, 15,   -- comisi¿n bruta
                         12, 16,   -- retenci¿n
                         50, 71,   -- prima neta cedida
                         61, 65,   -- comisi¿n cedida
                         62, 66,   -- retencion cedida
                         NULL),
                  d.cgarant, d.nriesgo,

                  --5261 jdomingo 9/6/2008 necessitem multiplicar per la forma de pagament
                  -- si ¿s prima devengada o comissi¿ devengada
                  -- (a l'anterior part de la select no ho fem perqu¿ ¿s prima devengada - cconcep 21,
                  -- que abans ¿s cconcep 0, i comissio devengada-cconcep 15, que abans es cconcep 11)
                  --sum(d.iconcep*decode(r.ctiprec,9,-1,1))
                  SUM(d.iconcep * DECODE(r.ctiprec, 9, -1, 1)
                      * DECODE(d.cconcep,
                               0, DECODE(s.cforpag, 0, 1, s.cforpag),
                               11, DECODE(s.cforpag, 0, 1, s.cforpag),
                               1))
             FROM recibos r, movrecibo m, detrecibos d, movseguro ms,
                  seguros s   --5261 jdomingo 9/6/2008 necessitem la taula per la forma de pagament
            WHERE r.nrecibo = m.nrecibo
              AND s.sseguro =
                    r.sseguro   --5261 jdomingo 9/6/2008 necessitem la taula per la forma de pagament
              AND r.nrecibo = d.nrecibo
              AND r.sseguro = ms.sseguro
              AND r.nmovimi = ms.nmovimi
              AND r.esccero = NVL(pcero, r.esccero)   -- BUG0011653-05/11/2009-JMF
              AND m.fmovfin IS NULL
              AND r.sseguro = psseguro
              AND d.cconcep IN(0, 11, 12, 50, 61, 62)   -- Solamente los conceptos de ventas
              AND m.cestrec = 2   -- recibos anulados
              -- AND r.fefecto >= cfdesde   -- l¿mite inferior a tratar -- Bug 0031321 - 19/05/2014 - JMF
              -- a partir de la ¿ltima rehabilitaci¿
              AND m.fmovdia >= NVL(pc_movdia, m.fmovdia - 1)   -- Bug 0031321 - 19/05/2014 - JMF
              -- BUG 0024450 - INICIO - DCT - 25/11/2013 - LCOL_T010-LCOL - SUPLEMENTO DE SUSPENSI?N Y REINICIO DE VIGENCIAS.
              --AND m.cmotmov <> 1   -- que no sea anulaci¿n por reemplazo
              AND m.cmotmov = DECODE(pcmodo, 0, 0, 391)
              -- BUG 0024450 - FIN - DCT - 25/11/2013 - LCOL_T010-LCOL - SUPLEMENTO DE SUSPENSI?N Y REINICIO DE VIGENCIAS. A¿adir pcmodo
              AND ms.cmovseg NOT IN(6, 3)   -- que no sea de regularizaci¿n
              AND r.ctiprec NOT IN(13, 15)   -- Bug 0024003 - 11/10/2012 - JMF
         GROUP BY d.cconcep, d.cgarant, d.nriesgo;

      -- Bug 0019743 - 11/10/2011 - JMF
      -- bug 0032844 - 19/09/2014 - JMF
      --CURSOR recs_anul_todos(cfdesde DATE, d_movdia DATE) IS
      CURSOR recs_anul_todos(pc_movdia DATE) IS
         SELECT DISTINCT r.nrecibo, r.cdelega, m.fmovini
                    FROM recibos r, movrecibo m, detrecibos d, movseguro ms
                   WHERE r.nrecibo = m.nrecibo
                     AND r.nrecibo = d.nrecibo
                     AND r.sseguro = ms.sseguro
                     AND r.nmovimi = ms.nmovimi
                     AND r.esccero = NVL(pcero, r.esccero)   -- BUG0011653-05/11/2009-JMF
                     AND m.fmovfin IS NULL
                     AND r.sseguro = psseguro
                     AND d.cconcep NOT IN(21, 15, 16, 71, 65, 66)   -- todos los conceptos excepto las ventas
                     AND m.cestrec = 2   -- recibos anulados
                     -- AND r.fefecto >= cfdesde   -- l¿mite inferior a tratar
                     -- a partir de la darrera rehabilitaci¿
                     AND m.fmovdia >= NVL(pc_movdia, m.fmovdia - 1)   -- Bug 0031321 - 19/05/2014 - JMF
                     -- BUG 0024450 - INICIO - DCT - 25/11/2013 - LCOL_T010-LCOL - SUPLEMENTO DE SUSPENSI?N Y REINICIO DE VIGENCIAS.
                     --AND m.cmotmov <> 1   -- que no sea anulaci¿n por reemplazo
                     AND m.cmotmov = DECODE(pcmodo, 0, 0, 391)
                     -- BUG 0024450 - FIN - DCT - 25/11/2013 - LCOL_T010-LCOL - SUPLEMENTO DE SUSPENSI?N Y REINICIO DE VIGENCIAS. A¿adir pcmodo
                     AND ms.cmovseg NOT IN(6, 3)   -- que no sea de regularizaci¿n
         UNION
         SELECT DISTINCT r.nrecibo, r.cdelega, m.fmovini
                    FROM recibos r, movrecibo m, detrecibos d, movseguro ms,
                         seguros s   --5261 jdomingo 9/6/2008 necessitem la taula per la forma de pagament
                   WHERE r.nrecibo = m.nrecibo
                     AND s.sseguro =
                           r.sseguro   --5261 jdomingo 9/6/2008 necessitem la taula per la forma de pagament
                     AND r.nrecibo = d.nrecibo
                     AND r.sseguro = ms.sseguro
                     AND r.nmovimi = ms.nmovimi
                     AND r.esccero = NVL(pcero, r.esccero)   -- BUG0011653-05/11/2009-JMF
                     AND m.fmovfin IS NULL
                     AND r.sseguro = psseguro
                     AND d.cconcep IN(0, 11, 12, 50, 61, 62)   -- Solamente los conceptos de ventas
                     AND m.cestrec = 2   -- recibos anulados
                     -- Bug 0032568 - AGM800-RECIBOS - Los recibos no se rehabilitan al rehabilitar la p¿liza - 18-VIII-2014 - dlF
                     --AND r.fefecto >= CASE WHEN cfdesde IS NULL THEN r.fefecto ELSE cfdesde END -- l¿mite inferior a tratar -- Bug 0031321 - 19/05/2014 - JMF
                     -- fin Bug 032568 - AGM800-RECIBOS - Los recibos no se rehabilitan al rehabilitar la p¿liza - 18-VIII-2014 - dlF
                     -- a partir de la ¿ltima rehabilitaci¿
                     AND m.fmovdia >= NVL(pc_movdia, m.fmovdia - 1)   -- Bug 0031321 - 19/05/2014 - JMF
                     -- BUG 0024450 - INICIO - DCT - 25/11/2013 - LCOL_T010-LCOL - SUPLEMENTO DE SUSPENSI?N Y REINICIO DE VIGENCIAS.
                     --AND m.cmotmov <> 1   -- que no sea anulaci¿n por reemplazo
                     AND m.cmotmov = DECODE(pcmodo, 0, 0, 391)
                     -- BUG 0024450 - FIN - DCT - 25/11/2013 - LCOL_T010-LCOL - SUPLEMENTO DE SUSPENSI?N Y REINICIO DE VIGENCIAS. A¿adir pcmodo
                     AND ms.cmovseg NOT IN(6, 3)   -- que no sea de regularizaci¿n
                                                ;
   BEGIN
      vpas := 1000;

      -- Localizamos la fecha de la pr¿xima cartera y el agente de la p¿liza
      -- Bug 0019743 - 11/10/2011 - JMF: afegir producte
      -- Bug 0021028 - 07/02/2012 - JMF: afegir empresa
      BEGIN
         vpas := 1010;

         SELECT fcaranu, cagente, sproduc, cempres
           INTO xfcaranu, xcagente, n_sproduc, v_cempres
           FROM seguros
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 101919;   -- error al acceder a la tabla seguros
      END;

      -- BUG 0024450 - INICIO - DCT - 25/11/2013 - LCOL_T010-LCOL - SUPLEMENTO DE SUSPENSI?N Y REINICIO DE VIGENCIAS.
      IF pcmodo = 0 THEN   --Si Rehabilitaci¿n
         -- Localizamos la ¿ltima anulaci¿n y rehabilitaci¿n
         BEGIN
            vpas := 1020;

            SELECT cmotmov
              INTO vcmotmov
              FROM movseguro
             WHERE sseguro = psseguro
               AND nmovimi = pnmovimi;
            -- CONF-274-25/11/2016-JLTS- Se adiciona la variable pac_suspension.vcod_reinicio en lugar del 392
            IF vcmotmov = pac_suspension.vcod_reinicio THEN
               SELECT fmovimi, NULL
                 INTO d_xmovanul, d_movdiadesde
                 FROM movseguro
                WHERE sseguro = psseguro
                  AND nmovimi < pnmovimi
                  AND cmotmov = 391
                  AND nmovimi = (SELECT MAX(m2.nmovimi)
                                   FROM movseguro m2
                                  WHERE m2.sseguro = movseguro.sseguro
                                    AND m2.nmovimi < pnmovimi
                                    AND m2.cmotmov = 391);
            ELSE
               -- Bug 0031321 - 19/05/2014 - JMF
               SELECT MAX(DECODE(cmovseg, 3, fmovimi, NULL)),
                      MAX(DECODE(cmovseg, 4, fmovimi, NULL))
                 INTO d_xmovanul,
                      d_movdiadesde
                 FROM movseguro
                WHERE sseguro = psseguro
                  AND nmovimi < pnmovimi
                  AND cmovseg IN(3, 4);
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 104349;   -- error al acceder a la tabla movseguro
         END;

         -- ini bug 0032844 - 19/09/2014 - JMF
         IF d_movdiadesde IS NULL THEN
            -- Si no existe rehabilitaci¿n, asignamos la ¿ltima fecha anulaci¿n
            d_movdiadesde := d_xmovanul;
         ELSIF d_xmovanul IS NOT NULL
               AND d_movdiadesde IS NOT NULL THEN
            IF d_xmovanul > d_movdiadesde THEN
               -- Si existen varias anulaciones y rehabilitaciones, nos quedamos con la fecha m¿s grande
               d_movdiadesde := d_xmovanul;
            END IF;
         END IF;
      -- fin bug 0032844 - 19/09/2014 - JMF
      ELSE
         BEGIN
            -- Bug 0031321 - 19/05/2014 - JMF
            -- CONF-274-25/11/2016-JLTS- Se adiciona la variable pac_suspension.vcod_reinicio en lugar del 392
            SELECT MAX(fmovimi)
              INTO d_movdiadesde
              FROM movseguro
             WHERE sseguro = psseguro
               AND nmovimi < pnmovimi
               AND cmotmov = pac_suspension.vcod_reinicio
               AND cmovseg <> 52;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 104349;   -- error al acceder a la tabla movseguro
         END;
      END IF;

      -- BUG 0024450 - FIN - DCT - 25/11/2013 - LCOL_T010-LCOL - SUPLEMENTO DE SUSPENSI?N Y REINICIO DE VIGENCIAS.

      -- Buscamos las fechas que debe tener el recibo que recoja las anulaciones
      BEGIN
         vpas := 1030;

         SELECT MIN(r.fefecto), MAX(r.fvencim)
           INTO xfefecto, xfvencim
           FROM recibos r, movrecibo m, movseguro ms
          WHERE r.nrecibo = m.nrecibo
            AND r.sseguro = ms.sseguro
            AND r.nmovimi = ms.nmovimi
            AND r.esccero = NVL(pcero, r.esccero)   -- BUG0011653-05/11/2009-JMF
            AND m.fmovfin IS NULL
            AND r.sseguro = psseguro
            AND m.cestrec = 2   -- recibos anulados
            -- AND r.fefecto >= ADD_MONTHS(xfcaranu, -12)   -- l¿mite inferior a tratar -- bug 0032844 - 19/09/2014 - JMF
            -- a partir de la darrera rehabilitaci¿
            AND m.fmovdia >= NVL(d_movdiadesde, m.fmovdia - 1)   -- bug 0032844 - 19/09/2014 - JMF
            -- BUG 0024450 - INICIO - DCT - 25/11/2013 - LCOL_T010-LCOL - SUPLEMENTO DE SUSPENSI?N Y REINICIO DE VIGENCIAS.
            --AND m.cmotmov <> 1   -- que no sea anulaci¿n por reemplazo
            AND m.cmotmov = DECODE(pcmodo, 0, 0, 391)
            -- BUG 0024450 - FIN - DCT - 25/11/2013 - LCOL_T010-LCOL - SUPLEMENTO DE SUSPENSI?N Y REINICIO DE VIGENCIAS. A¿adir pcmodo
            AND ms.cmovseg NOT IN(6, 3);   -- que no sea de regularizaci¿n ni anulaci¿n
      EXCEPTION
         WHEN OTHERS THEN
            NULL;   -- No hab¿a recibos anulados.
      END;

      -- Anulamos el recibo de PPE (que debe estar cobrado)
      BEGIN
         vpas := 1040;

         -- Bug 0031321 - 19/05/2014 - JMF: d_xmovanul
         SELECT r.nrecibo, fmovini, cestrec, r.cdelega
           INTO xnrecibo, xfmovini, xcestrec, xcdelega
           FROM recibos r, vdetrecibos v, movrecibo m
          WHERE r.sseguro = psseguro
            AND m.fmovdia >= NVL(d_xmovanul, m.fmovdia - 1)
            AND r.nrecibo = v.nrecibo
            AND r.nrecibo = m.nrecibo
            AND r.esccero = NVL(pcero, r.esccero)   -- BUG0011653-05/11/2009-JMF
            AND m.fmovfin IS NULL
            AND r.ctiprec NOT IN(12)
            AND v.itotpri = 0;   -- Recibo de la PPE anulada

         IF xcestrec = 1 THEN
            vpas := 1050;
            error := f_movrecibo(xnrecibo, 0, NULL, NULL, xsmovrec, xnliqmen, dummy,
                                 GREATEST(xfmovini, f_sysdate), NULL, xcdelega, NULL, NULL);

            IF error = 0 THEN
               vpas := 1060;
               error := f_movrecibo(xnrecibo, 2, NULL, NULL, xsmovrec, xnliqmen, dummy,
                                    GREATEST(xfmovini, f_sysdate), NULL, xcdelega, 0, NULL);

               IF error <> 0 THEN
                  RETURN error;
               END IF;

               vpas := 1065;

               -- BUG24802:DRA:20/11/2012:Inici
               IF pac_corretaje.f_tiene_corretaje(psseguro, NULL) = 1 THEN
                  vpas := 1066;
                  -- 24.0 - 27/03/2014 - MMM - 0030713: LCOL_F002-0011957-11958-11959: Se realizo anulacion en polizas... Inicio
                  --error := pac_corretaje.f_gen_comision_corr(psseguro, pnmovimi, xnrecibo);
                  error := pac_corretaje.f_reparto_corretaje(psseguro, pnmovimi, xnrecibo);

                  -- 24.0 - 27/03/2014 - MMM - 0030713: LCOL_F002-0011957-11958-11959: Se realizo anulacion en polizas... Fin
                  IF error <> 0 THEN
                     p_tab_error(f_sysdate, f_user, vobj, vpas, vpar,
                                 error || ' ' || SQLCODE || ' ' || SQLERRM);
                     RETURN error;
                  END IF;
               END IF;
            -- BUG24802:DRA:20/11/2012:Fi
            ELSE
               RETURN error;
            END IF;
         ELSE
            RETURN 109273;   -- El recibo de PPE No est¿ cobrado ¿¿¿???
         END IF;
      EXCEPTION
         WHEN OTHERS THEN
            NULL;   -- No existe recibo de ppe
      END;

      -- ini Bug 0019743 - 11/10/2011 - JMF
      vpas := 1070;

      IF NVL(f_parproductos_v(n_sproduc, 'RECIBOS_REHABILITA'), 0) = 1 THEN
         pnrecibo := 0;
         error := 0;
         vpas := 1080;

         -- bug 0032844 - 19/09/2014 - JMF
         FOR r1 IN recs_anul_todos(d_movdiadesde) LOOP
            -- crear un movimiento de recibo con cestrec = 0 y cestant = 2, fmovini = fefecto de la rehabilitaci¿n
            vpas := 1090;
            error := f_movrecibo(r1.nrecibo, 0, NULL, NULL, xsmovrec, xnliqmen, dummy,
                                 r1.fmovini, NULL, r1.cdelega, NULL, NULL);
            EXIT WHEN error <> 0;
            vpas := 1085;

            -- BUG24802:DRA:20/11/2012:Inici
            IF pac_corretaje.f_tiene_corretaje(psseguro, NULL) = 1 THEN
               vpas := 1086;
               -- 24.0 - 27/03/2014 - MMM - 0030713: LCOL_F002-0011957-11958-11959: Se realizo anulacion en polizas... Inicio
               --error := pac_corretaje.f_gen_comision_corr(psseguro, pnmovimi, r1.nrecibo);
               error := pac_corretaje.f_reparto_corretaje(psseguro, pnmovimi, r1.nrecibo);

               -- 24.0 - 27/03/2014 - MMM - 0030713: LCOL_F002-0011957-11958-11959: Se realizo anulacion en polizas... Fin
               IF error <> 0 THEN
                  p_tab_error(f_sysdate, f_user, vobj, vpas, vpar,
                              error || ' ' || SQLCODE || ' ' || SQLERRM);
                  RETURN error;
               END IF;
            END IF;

            -- BUG24802:DRA:20/11/2012:Fi
            -- Bug 0023183 - DCG - 14/08/2012 - LCOL_T020-COA-Circuit d'alta de propostes amb coasseguran
            error := f_insctacoas(r1.nrecibo, 1, v_cempres, xsmovrec, TRUNC(r1.fmovini));

            IF error != 0 THEN
               RETURN error;
            END IF;
         -- Fin Bug 0023183
         END LOOP;

         IF error <> 0 THEN
            RETURN error;   -- error en la generaci¿n del recibo de rehabilitaci¿n
         END IF;
      -- fin Bug 0019743 - 11/10/2011 - JMF

      -- ini Bug 0021028 - 07/02/2012 - JMF
      ELSIF NVL(f_parproductos_v(n_sproduc, 'RECIBOS_REHABILITA'), 0) = 2 THEN
         pnrecibo := 0;
         error := 0;
         vpas := 1100;

         -- bug 0032844 - 19/09/2014 - JMF
         FOR r1 IN recs_anul_todos(d_movdiadesde) LOOP
            -- ini Bug 0024003 - 11/10/2012 - JMF
            SELECT ctiprec
              INTO v_retctiprec
              FROM recibos
             WHERE nrecibo = r1.nrecibo;

            -- Los retornos los tratamos de forma diferente.
            IF v_retctiprec NOT IN(13, 15) THEN
               -- fin Bug 0024003 - 11/10/2012 - JMF

               -- duplicar el recibo anulado, fmovini = fefecto de la rehabilitaci¿n
               vpas := 1110;
               error := pac_adm.f_clonrecibo(1, r1.nrecibo, v_nreciboclon, xsmovrec, NULL,   --Bug 28617/158590 - 12/11/2013 - AMC
                                             1);
               ----
               vpas := 1120;

               UPDATE recibos
                  SET nmovimi = pnmovimi
                WHERE nrecibo = v_nreciboclon;

               -- Bug 0023183 - DCG - 14/08/2012 - LCOL_T020-COA-Circuit d'alta de propostes amb coasseguran
               error := f_insctacoas(r1.nrecibo, 1, v_cempres, xsmovrec, TRUNC(r1.fmovini));

               IF error != 0 THEN
                  RETURN error;
               END IF;

               -- Fin Bug 0023183
               -- ini Bug 0024003 - 11/10/2012 - JMF
               vpas := 1125;

               -- BUG24802:DRA:20/11/2012:Inici
               IF pac_corretaje.f_tiene_corretaje(psseguro, NULL) = 1 THEN
                  vpas := 1126;
                  -- 24.0 - 27/03/2014 - MMM - 0030713: LCOL_F002-0011957-11958-11959: Se realizo anulacion en polizas... Inicio
                  --error := pac_corretaje.f_gen_comision_corr(psseguro, pnmovimi, v_nreciboclon);
                  error := pac_corretaje.f_reparto_corretaje(psseguro, pnmovimi,
                                                             v_nreciboclon);

                  -- 24.0 - 27/03/2014 - MMM - 0030713: LCOL_F002-0011957-11958-11959: Se realizo anulacion en polizas... Fin
                  IF error <> 0 THEN
                     p_tab_error(f_sysdate, f_user, vobj, vpas, vpar,
                                 error || ' ' || SQLCODE || ' ' || SQLERRM);
                     RETURN error;
                  END IF;
               END IF;
            -- BUG24802:DRA:20/11/2012:Fi
            END IF;

            -- fin Bug 0024003 - 11/10/2012 - JMF

            ----
            EXIT WHEN error <> 0;
         END LOOP;

         IF error <> 0 THEN
            RETURN error;   -- error en la generaci¿n del recibo de rehabilitaci¿n
         END IF;

         -- ini Bug 0024003 - 10/10/2012 - JMF
         vpas := 1130;

         IF pac_retorno.f_tiene_retorno(NULL, psseguro, NULL) = 1 THEN
            vpas := 1140;
            error := pac_retorno.f_generar_retorno(psseguro, pnmovimi, NULL, NULL);

            IF error <> 0 THEN
               p_tab_error(f_sysdate, f_user, vobj, vpas, vpar,
                           error || ' ' || SQLCODE || ' ' || SQLERRM);
               RETURN error;
            END IF;
         END IF;

         -- fin Bug 0024003 - 10/10/2012 - JMF
         vpas := 1150;

         IF NVL(pac_parametros.f_parempresa_n(v_cempres, 'GESTIONA_COBPAG'), 0) = 1 THEN
            -- Funci¿n que procesa lors recibos de un movimiento de p¿liza
            vpas := 1160;
            error := pac_ctrl_env_recibos.f_proc_recpag_mov_clon(v_cempres, psseguro,
                                                                 pnmovimi, 4, NULL, 0);
            error := pac_ctrl_env_recibos.f_proc_recpag_mov(v_cempres, psseguro, pnmovimi, 4,
                                                            NULL);
         --Si ha dado error retornamos el error
         --De momento no retornamos el error
         /*IF error <> 0 THEN
             RETURN error;
          END IF;*/
         END IF;
      -- fin Bug 0021028 - 07/02/2012 - JMF
      ELSE
         -- Buscamos los recibos anulados desde la ¿ltima rehabilitaci¿n (o producci¿n)
          -- y que pertenezcan al ¿ltimo a¿o desde la fecha de anulaci¿n y generaremos un
          -- nuevo recibo con los datos de esos recibos y una venta igual a su prima.
         pnrecibo := 0;

         -- BUG0011653-05/11/2009-JMF-ini
         IF pcero = 1 THEN
            vtipcer := 'CERTIF0';
         ELSE
            vtipcer := NULL;
         END IF;

         -- BUG0011653-05/11/2009-JMF-fin
         vpas := 1170;

         -- bug 0032844 - 19/09/2014 - JMF
         FOR r IN recs_anul(d_movdiadesde) LOOP
            IF pnrecibo = 0 THEN   -- Creamos el recibo
               vpas := 1180;
               error := f_insrecibo(psseguro, xcagente, f_sysdate, xfefecto, xfvencim, 1,
                                    NULL, NULL, NULL, NULL, NULL, pnrecibo, 'R', NULL, NULL,
                                    pnmovimi, NULL, vtipcer);
               EXIT WHEN error <> 0;
            END IF;

            BEGIN
               vpas := 1190;

               INSERT INTO detrecibos
                           (nrecibo, cconcep, cgarant, nriesgo, iconcep)
                    VALUES (pnrecibo, r.concepto, r.garantia, r.riesgo, r.total);
            EXCEPTION
               WHEN OTHERS THEN
                  error := 109274;   -- error en la generaci¿n del recibo de rehabilitaci¿n
            END;

            EXIT WHEN error <> 0;
            -- Bug 0023183 - DCG - 14/08/2012 - LCOL_T020-COA-Circuit d'alta de propostes amb coasseguran
            vpas := 1195;

            IF f_sysdate < xfefecto THEN
               xfmovim := xfefecto;
            ELSE
               xfmovim := f_sysdate;
            END IF;

            BEGIN
               SELECT smovrec
                 INTO xsmovrec
                 FROM movrecibo
                WHERE nrecibo = pnrecibo;
            EXCEPTION
               WHEN OTHERS THEN
                  p_tab_error(f_sysdate, f_user,
                              'pac_rehabilita.f_genrec  num_recibo = ' || pnrecibo, vpas,
                              'WHEN OTHERS RETURN 104043', SQLERRM);
                  RETURN 104043;
            END;

            error := f_insctacoas(pnrecibo, 1, v_cempres, xsmovrec, TRUNC(xfmovim));

            IF error != 0 THEN
               RETURN error;
            END IF;
         -- Fin Bug 0023183
         END LOOP;

         -- Tratamos el recibo: calculamos los totales y tratamos el signo
         vpas := 1200;

         IF error = 0
            AND pnrecibo <> 0 THEN
            BEGIN
               vpas := 1210;

               SELECT NVL(SUM(DECODE(cconcep, 0, iconcep, 50, iconcep, 0)), 0),   -- total neta
                      NVL(SUM(DECODE(cconcep, 2, iconcep, 52, iconcep, 0)), 0)   -- total consorcio
                 INTO xtotprimaneta,
                      xtotconsorcio
                 FROM detrecibos
                WHERE nrecibo = pnrecibo
                  AND cconcep IN(0, 50, 2, 52);

               IF xtotprimaneta < 0
                  OR xtotconsorcio < 0 THEN
                  vpas := 1220;

                  UPDATE recibos
                     SET ctiprec = 9,   -- Si la prima es negativa,
                         cestimp = DECODE(cestimp, 4, 1, cestimp)
                   WHERE nrecibo = pnrecibo;   -- es tracta d' un extorn

                  vpas := 1230;
                  error := f_extornpos(pnrecibo, 'R', NULL);
               END IF;

               IF error = 0 THEN
                  vpas := 1240;
                  error := f_vdetrecibos('R', pnrecibo);
               END IF;

               IF error = 0 THEN
                  vpas := 1250;
                  error := f_rebnoimprim(pnrecibo, f_sysdate, dummy, 0);
               END IF;

               IF pnrecibo IS NOT NULL THEN
                  vpas := 1260;

                  SELECT cempres
                    INTO v_cempres
                    FROM recibos r
                   WHERE r.nrecibo = pnrecibo;

                  vpas := 1265;

                  -- BUG24802:DRA:20/11/2012:Inici
                  IF pac_corretaje.f_tiene_corretaje(psseguro, NULL) = 1 THEN
                     vpas := 1266;
                     -- 24.0 - 27/03/2014 - MMM - 0030713: LCOL_F002-0011957-11958-11959: Se realizo anulacion en polizas... Inicio
                     --error := pac_corretaje.f_gen_comision_corr(psseguro, pnmovimi, pnrecibo);
                     error := pac_corretaje.f_reparto_corretaje(psseguro, pnmovimi, pnrecibo);

                     -- 24.0 - 27/03/2014 - MMM - 0030713: LCOL_F002-0011957-11958-11959: Se realizo anulacion en polizas... Fin
                     IF error <> 0 THEN
                        p_tab_error(f_sysdate, f_user, vobj, vpas, vpar,
                                    error || ' ' || SQLCODE || ' ' || SQLERRM);
                        RETURN error;
                     END IF;
                  END IF;

                  -- BUG24802:DRA:20/11/2012:Fi

                  -- ini Bug 0024003 - 10/10/2012 - JMF
                  vpas := 1262;

                  IF pac_retorno.f_tiene_retorno(NULL, psseguro, NULL) = 1 THEN
                     vpas := 1264;
                     error := pac_retorno.f_generar_retorno(psseguro, NULL, pnrecibo, NULL);

                     IF error <> 0 THEN
                        p_tab_error(f_sysdate, f_user, vobj, vpas, vpar,
                                    error || ' ' || SQLCODE || ' ' || SQLERRM);
                        RETURN error;
                     END IF;
                  END IF;

                  -- fin Bug 0024003 - 10/10/2012 - JMF

                  --Bug.: 20923 - 14/01/2012 - ICV
                  vpas := 1270;

                  IF NVL(pac_parametros.f_parempresa_n(v_cempres, 'GESTIONA_COBPAG'), 0) = 1
                     AND error = 0 THEN
                     vpas := 1280;
                     error := pac_ctrl_env_recibos.f_proc_recpag_mov(v_cempres, psseguro,
                                                                     pnmovimi, 4, NULL);
                  END IF;
               END IF;
            EXCEPTION
               WHEN OTHERS THEN
                  error := 109274;   -- error en la generaci¿n del recibo de rehabilitaci¿n
            END;
         END IF;

         IF error <> 0 THEN
            RETURN error;   -- error en la generaci¿n del recibo de rehabilitaci¿n
         END IF;
      END IF;

      vpas := 1290;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobj, vpas, vpar,
                     'error=' || error || ' sqlcode=' || SQLCODE || ' ' || SQLERRM);
   END f_genrec;

   -- BUG0011653-05/11/2009-JMF-Canvi funci¿
   FUNCTION f_recibos(psseguro IN NUMBER, pnmovimi IN NUMBER, pnrecibo OUT NUMBER)
      RETURN NUMBER IS
      n_err          NUMBER;
      n_pro          NUMBER;
   BEGIN
      SELECT sproduc
        INTO n_pro
        FROM seguros
       WHERE sseguro = psseguro;

      IF NVL(f_parproductos_v(n_pro, 'RECUNIF'), 0) IN(1, 3) THEN   -- = 1 THEN -- BUG 0019627: GIP102 - Reunificaci¿n de recibos - FAL - 10/11/2011
         -- Para certificados cero.
         n_err := pac_rehabilita.f_genrec(psseguro, pnmovimi, pnrecibo, 1);

         IF n_err = 0 THEN
            -- Para resto certificados.
            n_err := pac_rehabilita.f_genrec(psseguro, pnmovimi, pnrecibo, 0);
         END IF;
      ELSE
--         IF NVL(f_parproductos_v(n_pro, 'ADMITE_CERTIFICADOS'), 0) = 1
--            AND pac_seguros.f_es_col_agrup(psseguro, 'SEG') = 1 THEN
--            n_err := pac_rehabilita.f_genrec(psseguro, pnmovimi, pnrecibo, 1);
--         ELSE
         n_err := pac_rehabilita.f_genrec(psseguro, pnmovimi, pnrecibo);
--         END IF;
      END IF;

      RETURN n_err;
   END f_recibos;

   -- Antiga funci¿ F_REHABILITA inclosa dins el package
   FUNCTION f_rehabilita(
      psseguro IN NUMBER,
      pcmotmov IN NUMBER,
      pcagente IN NUMBER,
      pnmovimi OUT NUMBER)
      RETURN NUMBER IS
/*************************************************************************
    REHABILITA        Rehabilita una p¿liza
                Devuelve 0 si todo va bien y 1 sino
    ALLIBCTR

    Se introduce la funci¿n movseguro
                        y el par¿metro pfcarpro
    Se cambia a f_fcontab y se a¿ade el
                        par¿metro sec a f_movseguro
       El movim. de seguro se hace con fecha de
                        efecto la de anulaci¿n de la p¿liza
        Se duplican las garant¿as
      Se elimina el par¿metro fcarpro.
       Se inserta en historicoseguros.
    Se actualiza el campo cnotibaja a null
**************************************************************************/
      error          NUMBER;
      xfanulac       DATE;
   BEGIN
--    Se obtiene la fecha de anulaci¿n del seguro
      BEGIN
         SELECT fanulac
           INTO xfanulac
           FROM seguros
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 105581;
      END;

      --    Se genera un movimiento en MOVSEGURO
      error := f_movseguro(psseguro, NULL, pcmotmov, 4, xfanulac, NULL, NULL, 0, NULL,
                           pnmovimi, f_sysdate, NULL);

      IF error <> 0 THEN
         RETURN error;
      END IF;

      -- Se llama a f_act_hisseg para guardar la situaci¿n anterior al suplemento.
      -- El nmovimi es el anterior al del suplemento, por eso se le resta uno al
      -- reci¿n creado.
      error := f_act_hisseg(psseguro, pnmovimi - 1);

      IF error <> 0 THEN
         RETURN error;
      END IF;

      -- Se actualiza la tabla SEGUROS
      BEGIN
         -- Bug 20664 - APD - 18/01/2012 - se elimina la condicion de que actualice
         -- la fvencim y en el where que filtre por cduraci = 0
         UPDATE seguros
            SET fanulac = NULL,
                csituac = 0,
                cagente = pcagente
          -- cnotibaja= null,
         WHERE  sseguro = psseguro;
      -- fin Bug 20664 - APD - 18/01/2012
      EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, 'pac_rehabilita.f_rehabilita', 1,
                        'psseguro:' || psseguro || ' pcmotmov:' || pcmotmov || ' pcagente:'
                        || pcagente,
                        SQLERRM);
            RETURN 1;
      END;

      BEGIN
         UPDATE seguros_ren
            SET ffinren = NULL,
                cmotivo = NULL
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      -- Si todo ha ido bien
      RETURN 0;
   END f_rehabilita;

   -- F_PREGUNTA
   -- Torna :
   --        0 si no cal fer cap pregunta abans de procedir a la rehabilitaci¿
   --        1 si s'ha de preguntar : S'han trobat extorns en estat pendent. Voleu anul¿lar ?
   --        2 si s'ha de preguntar : S'han trobat extorns en estat cobrat. Voleu descobrar i anul¿lar ?
   -- Bug 0019274 - 25/08/2011 - JMF: parametres
   FUNCTION f_pregunta(psseguro IN NUMBER)
      RETURN NUMBER IS
      v_pregunta     NUMBER(2) := 0;   -- retorna 0 per defecte.
      v_cestrec      NUMBER(2);
   BEGIN
    --Ini 3592 --ECP-- 29/05/2019 
      FOR rmovseguro IN (SELECT m.cmotmov, m.nmovimi, s.sproduc, m.cmovseg
                           FROM movseguro m, seguros s
                          WHERE m.sseguro = psseguro
                            AND m.nmovimi = (SELECT MAX(z.nmovimi)
                                               FROM movseguro z
                                              WHERE z.sseguro = psseguro
                                                AND z.cmovseg in (3,53))
                            AND s.sseguro = psseguro) LOOP
         -- Determinar si ¿s una anul¿laci¿ de l'efecte
          if  rmovseguro.cmovseg = 53 then
            v_pregunta := 0;
          else
         --IF nvl(f_parmotmov(rmovseguro.cmotmov, motmov_anul_efecto, rmovseguro.sproduc),0) = 1 THEN
            -- Si hi ha un rebut per l'anul¿laci¿ ¿s un extorno
            FOR rrecibos IN (SELECT r.nrecibo
                               FROM recibos r, vdetrecibos v
                              WHERE r.sseguro = psseguro
                                AND r.nmovimi = rmovseguro.nmovimi
                                AND r.ctiprec = 9   -- Recibos de extorno
                                AND v.itotalr != 0
                                AND v.nrecibo = r.nrecibo) LOOP
               -- Si est¿ en estat pendent
               v_cestrec := f_cestrec(rrecibos.nrecibo, NULL);
              

               IF v_cestrec = 0 THEN
                  v_pregunta := 1;
               ELSIF v_cestrec = 1 THEN
                  v_pregunta := 2;
               ELSE
                  v_pregunta := 0;
               END IF;
 
               EXIT;
            END LOOP;
         --END IF;
          end if;
          --Fin 3592 --ECP-- 29/05/2019 
        -- EXIT;
      END LOOP;

      RETURN v_pregunta;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_rehabilita.f_pregunta', 1,
                     'psseguro:' || psseguro||' motmov_anul_efecto-->'||motmov_anul_efecto, SQLERRM);
         RETURN(0);
   END f_pregunta;

   -- F_REASEGURO
   -- Torna :
   --        0 si tot OK
   --        altrament torna el n¿mero d'error
   --        p_error te el codi de l'error.
   --  NOTA :  La funci¿ pot tornar 0 + codi error :  No ¿s un error, per¿ s'ha de mostrar aquesta av¿s a l'usuari
   FUNCTION f_reaseguro(psseguro IN NUMBER, p_error OUT NUMBER)
      RETURN NUMBER IS
      v_nmovvig      movseguro.nmovimi%TYPE;
      v_sproces      NUMBER;
      v_error        literales.slitera%TYPE;
      v_desc_error   literales.tlitera%TYPE;
      v_moneda       NUMBER := f_parinstalacion_n('MONEDAINST');
   BEGIN
      p_error := NULL;

      -- Substituim la condici¿ per aquesta nova
      -- bug 011845: CRE - Ajustar reasseguran¿a estalvi: Afegir CREASEG = 1
      FOR rseguros IN
         (SELECT a.fefecto, a.fvencim, b.creaseg,
                 pac_monedas.f_moneda_producto(a.sproduc) cmoneda   -- BUG 18423 - I - 27/12/2011 - JLB - LCOL000 - Multimoneda
            FROM seguros a, productos b
           WHERE a.sseguro = psseguro
             AND b.sproduc = a.sproduc
             AND b.creaseg = 1) LOOP
         v_moneda := NVL(rseguros.cmoneda, v_moneda);

         IF rseguros.fefecto = rseguros.fvencim THEN
            NULL;
         --IF pcsituac = 3 THEN
         --   null; -- no hi ha cessi¿ al reasseguro. Control de la
         --         -- reahabilitaci¿ de les p¿lisses anul.lades al
         --        -- venciment.(fefecto = fvencim)
         ELSE
            SELECT sproces.NEXTVAL
              INTO v_sproces
              FROM DUAL;

            -- buscamos el ¿ltimo movimiento vigente
            IF pac_util.validar(f_buscanmovimi(psseguro, 1, 1, v_nmovvig), v_error,
                                v_desc_error) THEN
               v_error := f_buscactrrea(psseguro, v_nmovvig, v_sproces, 9, v_moneda);

               IF v_error = 99 THEN
                  v_error := 0;   -- no hay cesi¿n al reaseguro
               ELSIF v_error = 0 THEN
                  v_error := f_cessio(v_sproces, 9, v_moneda);

                  IF v_error = 99 THEN
                     --Falta el facultativo
                     --Se acepta lo hecho por la funci¿n f_cessio y damos el mensaje.
                     v_error := 105382;
                     COMMIT;
                  END IF;
               END IF;

               -- BUG 29011/163810 - RCL - 31/01/2013
               IF v_error <> 0 THEN
                  p_error := v_error;
               END IF;
            ELSE
               p_error := v_error;
            END IF;
         END IF;

         EXIT;
      END LOOP;

      RETURN(p_error);
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_rehabilita.f_reaseguro', 1,
                     'psseguro:' || psseguro, SQLERRM);
         p_error := 140999;
         RETURN p_error;
   END f_reaseguro;

   -- F_EJECUTA
   --   Torna 0 si tot OK, altrament torna el codi d'error i la descripci¿ a p_error_desc
   --
   --  Par¿metres entrada:
   --    psseguro :
   --    pcagente :     Si es NULL s'utilitza el codi actual de la taula Seguros
   --    pcmotmov :
   --    panula_extorno :   1 si usuari ha confirmat l'anul¿laci¿ . 0 si no.
   --  Par¿metres sortida:
   --    pxnrecibo :    N¿umero del rebut generat
   -- Bug 26151 - APD - 26/02/2013 - se a¿ade el parametro ptratar_recibo que indicara si no se debe
   -- realizar nada con los recibos (0) o seguir realizando lo que se hace hasta ahora con los recibos (1)
   FUNCTION f_ejecuta(
      psseguro IN NUMBER,
      pcagente IN NUMBER DEFAULT NULL,
      pcmotmov IN NUMBER,
      panula_extorno IN NUMBER,
      pxnrecibo OUT NUMBER,
      ptratar_recibo IN NUMBER DEFAULT 1)
      RETURN NUMBER IS
      -- ini Bug 0019274 - 25/08/2011 - JMF
      --v_error        literales.slitera%TYPE := 0;
      v_error        axis_literales.slitera%TYPE := 0;
      -- ini Bug 0019274 - 25/08/2011 - JMF
      v_error_desc   literales.tlitera%TYPE := 0;
      v_nmovimi      movseguro.nmovimi%TYPE;
      v_xnmovimi     movseguro.nmovimi%TYPE;
      v_hay_recibo_extorno_cobrado BOOLEAN := FALSE;
      v_nrecibo      recibos.nrecibo%TYPE;
      v_sproduc      seguros.sproduc%TYPE;
      v_cestrec      NUMBER;
      v_xcorrecto    NUMBER;
      v_sysdate CONSTANT DATE := f_sysdate;
      vv_nnumlin     ctaseguro.nnumlin%TYPE;
      v_anulefec     NUMBER;
      xestado_rbo    NUMBER;
      xnrecibo       recibos.nrecibo%TYPE;
      xparametro     VARCHAR2(7);
      dummy          NUMBER;
      xerror         NUMBER;
      -- Bug 19444: LCOL_T04: Parametrizaci¿n Rehabilitaci¿n
      v_resul_sini   NUMBER;
      -- Fin Bug 19444
      v_pagctiprec   recibos.ctiprec%TYPE;
      -- Ini Bug 139289 --ECP-- 28/02/2013
      v_nreciboclon  recibos.nrecibo%TYPE;
      v_ssmovrec     movrecibo.smovrec%TYPE := 0;
      v_sseguro      seguros.sseguro%TYPE;
      -- Fin Bug 139289 --ECP-- 28/02/2013
      vpasexec       NUMBER(5);
      vparam         VARCHAR2(200)
         := 'psseguro:' || psseguro || 'pcagente:' || pcagente || 'pcmotmov:' || pcmotmov
            || 'panula_extorno:' || panula_extorno;
      error_proc     EXCEPTION;
      v_res          NUMBER;
      v_admite_certificados NUMBER;
      v_escertifcero NUMBER;
      v_es_col_admin NUMBER;
      -- Ini 25. BUG 0030417_0171145 --JLTS-- 16/04/2014
      v_programado   NUMBER;
      v_nmovimi_prog movseguro.nmovimi%TYPE;
      v_fvencim_prog historicoseguros.fvencim%TYPE;
      -- Fin 25. BUG 0030417_0171145 --JLTS-- 16/04/2014
      v_listarec     t_lista_id := t_lista_id();
      vagente        recibos.cagente%TYPE;
      --IAXIS -3592
      perror            VARCHAR2 (250);
      vtipopago         NUMBER                     := 4;
      vemitido          NUMBER;
      vsinterf          NUMBER;
      vsmovrec          NUMBER;
      vterminal         VARCHAR2 (20);
     
       --IAXIS -3592
   BEGIN
      vpasexec := 1;

      --Recuperamos el ultimo movimiento de la poliza.
      SELECT NVL(MAX(nmovimi), 1)
        INTO v_nmovimi
        FROM movseguro
       WHERE sseguro = psseguro;

      vpasexec := 2;

      FOR rseguros IN (SELECT cagente, sproduc, fanulac, cempres
                         FROM seguros
                        WHERE sseguro = psseguro) LOOP
         vpasexec := 3;
         v_error := pac_redcomercial.valida_agenterehabilitacion(rseguros.cagente,
                                                                 rseguros.cempres,
                                                                 rseguros.fanulac, pcagente,
                                                                 v_xcorrecto);

         IF v_error = 0
            AND v_xcorrecto <> 0 THEN
            v_error := 108010;
         END IF;

         vpasexec := 31;

         IF NVL(f_parproductos_v(rseguros.sproduc, 'ADMITE_CERTIFICADOS'), 0) = 1 THEN
            v_admite_certificados := 1;
         ELSE
            v_admite_certificados := 0;
         END IF;

         IF pac_seguros.f_get_escertifcero(NULL, psseguro) = 1 THEN
            v_escertifcero := 1;
         ELSE
            v_escertifcero := 0;
         END IF;

         vpasexec := 4;

         -- ini Bug 0019274 - 25/08/2011 - JMF
         DECLARE
            n_dias_reha    NUMBER;
         BEGIN
            n_dias_reha := f_parproductos_v(rseguros.sproduc, 'DIAS_REHABILITACION');

            IF NVL(n_dias_reha, 0) > 0 THEN
               IF rseguros.fanulac < TRUNC(f_sysdate) - n_dias_reha THEN
                  -- Supera l¿mite de tiempo permitido para rehabilitar
                  v_error := 9902295;
               END IF;
            END IF;
         END;

         vpasexec := 5;

         --BUG:23817/128727
         DECLARE
            v_csituac      seguros.csituac%TYPE;
            v_npoliza      seguros.npoliza%TYPE;
            v_sseguro      seguros.sseguro%TYPE;
         BEGIN
            --Debemos mirar si el psseguro es certificado 0 no no lo es
            --0- No es certificado 0, 1-Es certificado 0
            IF v_escertifcero = 0 THEN
               BEGIN
                  --Debemos buscar la npoliza certificado 0
                  SELECT npoliza
                    INTO v_npoliza
                    FROM seguros
                   WHERE sseguro = psseguro;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     v_error := 100500;
               END;

               BEGIN
                  --Debemos buscar el sseguro de la p¿liza con certificado 0
                  SELECT sseguro
                    INTO v_sseguro
                    FROM seguros
                   WHERE npoliza = v_npoliza
                     AND ncertif = 0;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     v_error := 100500;
               END;

               IF pac_seguros.f_get_csituac(v_sseguro, 'SEG', v_csituac) = 0 THEN
                  IF v_csituac = 2 THEN
                     --Si la p¿liza esta anulada se deber¿ rehabilitar
                     v_error := 9904513;   --Se debe rehabilitar la p¿liza de certificado 0
                  END IF;
               END IF;
            END IF;
         END;

         -- fin Bug 0019274 - 25/08/2011 - JMF
         IF v_error = 0 THEN
            -- Bug 19444: LCOL_T04: Parametrizaci¿n Rehabilitaci¿n
            IF NVL(pac_parametros.f_parempresa_n(rseguros.cempres, 'MODULO_SINI'), 0) = 0 THEN
               vpasexec := 6;
               v_resul_sini := pac_sin.f_anu_sini_mov(psseguro, v_nmovimi);
            ELSIF NVL(pac_parametros.f_parempresa_n(rseguros.cempres, 'MODULO_SINI'), 0) = 1 THEN
               vpasexec := 7;
               v_resul_sini := pac_siniestros.f_anu_sini_mov(psseguro, v_nmovimi);
            END IF;

            -- Fin Bug 19444
            vpasexec := 8;

            --Controlamos si por causa de la baja tenia un siniestro.
            IF pac_util.validar(v_resul_sini, v_error, v_error_desc) THEN
               -- Per f_rehabilita utilitzar sempre error 101811 enlloc del que torni la funci¿.
               vpasexec := 9;

               IF pac_util.validar(f_rehabilita(psseguro, pcmotmov,
                                                NVL(pcagente, rseguros.cagente), v_xnmovimi) =
                                                                                             0,
                                   101811, v_error, v_error_desc) THEN
                  vpasexec := 10;

                  -- Bug 26151 - APD - 26/02/2013 -  se a¿ade el parametro ptratar_recibo
                  IF ptratar_recibo = 1 THEN
                     IF v_admite_certificados = 1
                        AND v_escertifcero = 1 THEN
                        v_res := 0;
                     ELSE
                        v_res := f_recibos(psseguro, v_xnmovimi, pxnrecibo);
                     END IF;

                     -- BUG0011653-05/11/2009-JMF Ahora f_recibos puede generar 2 recibos, pero pxnrecibo no se utiliza.
                     IF pac_util.validar(v_res, v_error, v_error_desc) THEN
                        vpasexec := 11;
                        --Ini IAXIS-3592 -- ECP -- 29/05/2019
                        -- Darrer moviment d'anul¿laci¿ de la p¿lissa
                        FOR rmovseguro IN (SELECT m.cmotmov, m.nmovimi, m.fefecto
                                             FROM movseguro m
                                            WHERE m.sseguro = psseguro
                                              AND m.nmovimi =
                                                    (SELECT MAX(z.nmovimi)
                                                       FROM movseguro z
                                                      WHERE z.sseguro = psseguro
                                                        AND z.cmovseg in (3,53))) LOOP
                         --Ini IAXIS-3592 -- ECP -- 29/05/2019
                           vpasexec := 12;
                           v_es_col_admin := pac_seguros.f_es_col_admin(psseguro, 'SEG');

                           --Ini Bug 26070 --ECP-- 28/02/2013
                           IF v_admite_certificados = 1
                              AND v_escertifcero = 1 THEN
                              FOR regs IN (SELECT *
                                             FROM detmovsegurocol
                                            WHERE sseguro_0 = psseguro
                                              AND nmovimi_0 = rmovseguro.nmovimi - 1) LOOP
                                 -- Bug QT:7740 - RSC - 17/06/2013
                                 IF v_es_col_admin = 1 THEN
                                    -- Fin Bug QT:7740

                                    -- Importante llamar con tratar_recibo = 0 para no generar recibos al rehabilitar los certificados.
                                    v_error := pac_rehabilita.f_ejecuta(regs.sseguro_cert,
                                                                        NULL, pcmotmov,
                                                                        panula_extorno,
                                                                        xnrecibo, 0);
                                 -- Bug QT:7740 - RSC - 17/06/2013
                                 ELSE
                                    -- Importante llamar con tratar_recibo = 0 para no generar recibos al rehabilitar los certificados.
                                    v_error := pac_rehabilita.f_ejecuta(regs.sseguro_cert,
                                                                        NULL, pcmotmov,
                                                                        panula_extorno,
                                                                        xnrecibo, 1);
                                 END IF;

                                 -- Fin bug QT:7740
                                 IF v_error <> 0 THEN
                                    RAISE error_proc;
                                 END IF;
                              END LOOP;
                           END IF;

                           --Fin Bug 26070 --ECP-- 28/02/2013

                           -- Bug 0024003 - 10/10/2012 - JMF: Tener en cuenta recibos de retorno
                           FOR extornos IN (SELECT r.nrecibo, r.fefecto, r.fvencim, esccero,
                                                   r.ctiprec, r.cagente
                                              FROM recibos r, vdetrecibos v, seguros s
                                             WHERE s.sseguro = r.sseguro
                                               AND r.sseguro = psseguro
                                               AND r.ctiprec IN
                                                                               -- Ini Bug 26488 -- ECP-- 04/06/2013 se cambia  (9, 15)  por  (1, 9, 15)
                                                                               -- Recibos de extorno + Recobro retorno
                                                               -- 23. 0029431#c168400: LCOL_MILL-10603: + 10429#c57215 - Inicio
                                                               -- (1, 9, 15)
                                                               (1, 9, 14, 15)
                                               -- 23. 0029431#c168400: LCOL_MILL-10603: + 10429#c57215 - Final
                                               -- Fin Bug 26488 -- ECP-- 04/06/2013
                                               AND v.itotalr != 0   -- Con importe != 0
                                               AND v.nrecibo = r.nrecibo
                                               AND r.nmovimi = rmovseguro.nmovimi
                                               --CESTAUX <>2 si es una poliza individual o si es colectivo una caratula (ncertif 0)
                                               AND((r.cestaux <> 2
                                                    AND((v_admite_certificados = 1
                                                         AND v_escertifcero = 1)
                                                        OR v_admite_certificados = 0
                                                        OR(v_admite_certificados = 1
                                                           AND v_escertifcero = 0
                                                           AND v_es_col_admin = 0)))
                                                   -- o CESTAUX  = 2 si es un certificado de un colectivo
                                                   OR(r.cestaux = 2
                                                      AND(v_admite_certificados = 1
                                                          AND v_escertifcero = 0)))) LOOP
                              vpasexec := 13;
                              xestado_rbo := f_cestrec(extornos.nrecibo, NULL);
                              vpasexec := 14;

                              IF xestado_rbo = 1
                                 OR(xestado_rbo = 0
                                    AND v_admite_certificados = 1
                                    AND v_escertifcero = 0
                                    AND v_es_col_admin = 1) THEN   -- extornos pagados o pendientes en certificados de colectivos (tiene que generar recibo)
                                 xnrecibo := 0;

                                 IF extornos.esccero = 1 THEN
                                    xparametro := 'CERTIF0';
                                 ELSE
                                    xparametro := NULL;
                                 END IF;

                                 -- ini Bug 0024003 - 10/10/2012 - JMF
                                 IF extornos.ctiprec = 15 THEN
                                    -- Si es un recobro de retorno, generamos un tipo retorno
                                    v_pagctiprec := 13;
                                 ELSE
                                    -- El resto de casos, generamos tipo suplemento como siempre
                                    -- Ini Bug 26488 -- ECP-- 04/06/2013  Se cambia v_pagctiprec := 1; por
                                    IF extornos.ctiprec = 9 THEN
                                       v_pagctiprec := 1;
                                    ELSE
                                       v_pagctiprec := 9;
                                    END IF;
                                 -- Fin Bug 26488 -- ECP-- 04/06/2013
                                 END IF;
                                 IF f_parproductos_v(rseguros.sproduc, 'REC_ANUL_REC_EXT') = 1 THEN
                                    vagente   := extornos.cagente;
                                 ELSE
                                    vagente := pcagente;
                                 END IF;

                                 vpasexec := 15;
                                 -- fin Bug 0024003 - 10/10/2012 - JMF
                                 v_error := f_insrecibo(psseguro, vagente, f_sysdate,
                                                        extornos.fefecto, extornos.fvencim,
                                                        v_pagctiprec, NULL, NULL, NULL, NULL,
                                                        NULL, xnrecibo, 'R', NULL, NULL,
                                                        v_nmovimi, NULL, xparametro);

                                 IF xnrecibo = 0 THEN
                                    v_error := 9901025;   -- error al crear recibo de rehabilitacion
                                 END IF;

                                 IF v_error <> 0 THEN
                                    RAISE error_proc;
                                 END IF;

                                 --Ini Bug 26070 --ECP-- 28/02/2013
                                 IF v_admite_certificados = 1
                                    AND v_escertifcero = 1 THEN
                                    UPDATE recibos
                                       SET cestaux = 0
                                     WHERE nrecibo = xnrecibo;
                                 END IF;

                                 --Fin Bug 26070 --ECP-- 28/02/2013
                                 vpasexec := 16;

                                 BEGIN
                                    INSERT INTO detrecibos
                                                (nrecibo, cconcep, cgarant, nriesgo, iconcep, fcambio)
                                       SELECT xnrecibo, cconcep, cgarant, nriesgo, iconcep, fcambio
                                         FROM detrecibos
                                        WHERE nrecibo = extornos.nrecibo;
                                 EXCEPTION
                                    WHEN OTHERS THEN
                                       v_error := 9901025;
                                 END;

                                 vpasexec := 17;

                                 IF v_error = 0 THEN
                                    BEGIN
                                       v_error := f_vdetrecibos('R', xnrecibo);

                                       IF v_error = 0 THEN
                                          v_error :=
                                                  f_rebnoimprim(xnrecibo, f_sysdate, dummy, 0);
                                       END IF;
                                    EXCEPTION
                                       WHEN OTHERS THEN
                                          v_error := 9901025;
                                    END;
                                 END IF;

                                 IF v_error <> 0 THEN
                                    RAISE error_proc;
                                 END IF;

                                 vpasexec := 18;

                                 -- BUG24802:DRA:20/11/2012:Inici
                                 IF pac_corretaje.f_tiene_corretaje(psseguro, NULL) = 1 THEN
                                    vpasexec := 19;
                                    -- 24.0 - 27/03/2014 - MMM - 0030713: LCOL_F002-0011957-11958-11959: Se realizo anulacion en polizas... Inicio
                                    --v_error := pac_corretaje.f_gen_comision_corr(psseguro, v_nmovimi, xnrecibo);
                                    v_error := pac_corretaje.f_reparto_corretaje(psseguro,
                                                                                 v_nmovimi,
                                                                                 xnrecibo);

                                    -- 24.0 - 27/03/2014 - MMM - 0030713: LCOL_F002-0011957-11958-11959: Se realizo anulacion en polizas... Fin
                                    IF v_error <> 0 THEN
                                       RAISE error_proc;
                                    END IF;
                                 END IF;

                                 -- BUG24802:DRA:20/11/2012:Fi
                                 --Ini Bug 26070 --ECP-- 28/02/2013
                                 IF v_admite_certificados = 1
                                    AND v_escertifcero = 1 THEN
                                    FOR v_recind IN (SELECT nrecibo
                                                       FROM adm_recunif a
                                                      WHERE nrecunif = extornos.nrecibo) LOOP
                                       -- Clonado
                                       v_error :=
                                          pac_adm.f_clonrecibo(0, v_recind.nrecibo,
                                                               v_nreciboclon, v_ssmovrec,
                                                               NULL, 1);

                                       IF v_error <> 0 THEN
                                          RAISE error_proc;
                                       END IF;

                                       -- Updateamos ctiprec y nmovimi
                                       SELECT sseguro
                                         INTO v_sseguro
                                         FROM recibos
                                        WHERE nrecibo = v_nreciboclon;

                                       SELECT MAX(nmovimi)
                                         INTO v_nmovimi
                                         FROM movseguro
                                        WHERE sseguro = v_sseguro;

                                       UPDATE recibos r
                                          SET nmovimi = v_nmovimi,
                                              -- Ini Bug 26488 -- ECP-- 04/06/2013  Se cambia  ctiprec = DECODE(ctiprec, 15, 13, 1) por
                                              ctiprec = DECODE(ctiprec, 15, 13, 9, 1, 9)
                                        --  Fin Bug 26488 -- ECP-- 04/06/2013
                                       WHERE  nrecibo = v_nreciboclon;

                                       INSERT INTO adm_recunif
                                                   (nrecibo, nrecunif)
                                            VALUES (v_nreciboclon, xnrecibo);
                                    END LOOP;
                                 END IF;

                                 --Fin Bug 26070 --ECP-- 28/02/2013
                                 --JMC- Si es un certificado de un colectivo, unificamos el recibo creado.
                                 IF v_admite_certificados = 1
                                    AND v_escertifcero = 0 THEN
                                    v_listarec := NULL;
                                    v_listarec := t_lista_id();
                                    v_listarec.EXTEND;
                                    v_listarec(v_listarec.LAST) := ob_lista_id();
                                    v_listarec(v_listarec.LAST).idd := xnrecibo;
                                    v_error :=
                                       pac_gestion_rec.f_agruparecibo(rseguros.sproduc,
                                                                      extornos.fefecto,
                                                                      f_sysdate,
                                                                      rseguros.cempres,
                                                                      v_listarec,
                                                                      v_pagctiprec);

                                    IF v_error <> 0 THEN
                                       RAISE error_proc;
                                    END IF;
                                 END IF;
                              ELSIF xestado_rbo = 0 THEN   -- extornos pendientes
                                 vpasexec := 20;

                                 IF pac_util.validar(f_anula_rec(extornos.nrecibo,
                                                                 TRUNC(f_sysdate)),
                                                     v_error, v_error_desc) THEN
                                    -- BUG24802:DRA:20/11/2012:Inici
                                    IF pac_corretaje.f_tiene_corretaje(psseguro, NULL) = 1 THEN
                                       vpasexec := 19;
                                        -- 24.0 - 27/03/2014 - MMM - 0030713: LCOL_F002-0011957-11958-11959: Se realizo anulacion... Inicio
                                       --v_error := pac_corretaje.f_gen_comision_corr(psseguro, v_nmovimi, xnrecibo, -1);
                                       v_error :=
                                          pac_corretaje.f_reparto_corretaje(psseguro,
                                                                            v_nmovimi,
                                                                            xnrecibo);

                                       -- 24.0 - 27/03/2014 - MMM - 0030713: LCOL_F002-0011957-11958-11959: Se realizo anulacion en polizas... Fin
                                       IF v_error <> 0 THEN
                                          RAISE error_proc;
                                       END IF;
                                    END IF;
                                 END IF;

                                 IF v_error <> 0 THEN
                                    RAISE error_proc;
                                 END IF;
                              END IF;

                              -- BUG 26605/0142535 - JLTS - Se insert el env¿o de recibos Ini
                              IF NVL(pac_parametros.f_parempresa_n(rseguros.cempres,
                                                                   'GESTIONA_COBPAG'),
                                     0) = 1
                                 AND v_error = 0 THEN
                                 vpasexec := 21;
                                 v_error :=
                                    pac_ctrl_env_recibos.f_proc_recpag_mov(rseguros.cempres,
                                                                           psseguro,
                                                                           v_nmovimi, 4, NULL);
                              END IF;
                           -- BUG 26605/0142535 - JLTS - Se insert el env¿o de recibos Fin
                           END LOOP;

                           -- BUG 11997 - 15/02/2010 - ASN - fin
                           vpasexec := 22;

                           -- Gravar una linea de saldo si la p¿lissa ¿s d'estalvi i no hi ha un rebut extorno cobrat
                           -- Bug 0019444 - 12/09/2011 - JMF: Comprobar si tiene garantia ahorro contratada
                           IF v_error IS NULL
                              OR v_error = 0 THEN
                              vpasexec := 23;

                              IF NOT v_hay_recibo_extorno_cobrado
                                 AND f_esahorro(v_nrecibo, psseguro, v_error) =
                                                                    1   -- Ignoro error F_ESAHORRO
                                 AND pac_seguros.f_tiene_garanahorro(v_nrecibo, psseguro,
                                                                     rseguros.fanulac) = 1 THEN
                                 vpasexec := 24;

                                 -- Anulamos el saldo de la anulaci¿n
                                 UPDATE ctaseguro
                                    SET cmovanu = 1
                                  WHERE sseguro = psseguro
                                    AND cmovimi = 0
                                    AND imovimi = 0
                                    AND nnumlin =
                                          (SELECT MAX(nnumlin)
                                             FROM ctaseguro
                                            WHERE sseguro = psseguro
                                              AND cmovimi = 0
                                              AND imovimi = 0);

                                 vpasexec := 25;

                                 -- Anulamos los movimientos de rescate y penalizaci¿n
                                 UPDATE ctaseguro
                                    SET cmovanu = 1
                                  WHERE sseguro = psseguro
                                    AND cmovimi IN(34, 27, 33, 31, 47);

                                 IF pac_ctaseguro.f_tiene_ctashadow(psseguro, NULL) = 1 THEN
                                    UPDATE ctaseguro_shadow
                                       SET cmovanu = 1
                                     WHERE sseguro = psseguro
                                       AND cmovimi = 0
                                       AND imovimi = 0
                                       AND nnumlin =
                                             (SELECT MAX(nnumlin)
                                                FROM ctaseguro_shadow
                                               WHERE sseguro = psseguro
                                                 AND cmovimi = 0
                                                 AND imovimi = 0);

                                    vpasexec := 25;

                                    -- Anulamos los movimientos de rescate y penalizaci¿n
                                    UPDATE ctaseguro_shadow
                                       SET cmovanu = 1
                                     WHERE sseguro = psseguro
                                       AND cmovimi IN(34, 27, 33, 31, 47);
                                 END IF;

                                  /*
                                  Se opta por grabar un saldo con la fecha de anulaci¿n. Pasa que para la rehabilitaci¿n
                                  de una p¿liza que ya ha vencido y que no ha pasado el proceso de renovaci¿n estaba
                                  llamando a la provisi¿n a dia de hoy y estaba retornando 0 ya que todavia no ha renovado ni
                                  nada.
                                 */
                                 vpasexec := 26;

                                 IF NVL(f_parproductos_v(rseguros.sproduc, 'REGSALDO_ANU'), 0) =
                                                                                              1 THEN
                                    IF pac_util.validar
                                          (pac_ctaseguro.f_inscta_prov_cap(psseguro,
                                                                           rseguros.fanulac,
                                                                           'R', NULL),
                                           v_error, v_error_desc) THEN
                                       v_error :=
                                          pac_ctaseguro.f_inscta_prov_cap_shw
                                                                            (psseguro,
                                                                             rseguros.fanulac,
                                                                             'R', NULL);
                                    END IF;
                                 END IF;
                              END IF;
                           END IF;

                           -- Ini 25. BUG 0030417_0171145 --JLTS-- 16/04/2014
                           IF rmovseguro.cmotmov = 322 THEN
                              SELECT COUNT(*)
                                INTO v_programado
                                FROM movseguro
                               WHERE sseguro = psseguro
                                 AND nmovimi =(rmovseguro.nmovimi - 1)
                                 AND cmotmov IN(236, 221);

                              IF v_programado = 1 THEN
                                 SELECT nmovimi
                                   INTO v_nmovimi_prog
                                   FROM movseguro
                                  WHERE sseguro = psseguro
                                    AND nmovimi =(rmovseguro.nmovimi - 1)
                                    AND cmotmov IN(236, 221);

                                 SELECT fvencim
                                   INTO v_fvencim_prog
                                   FROM historicoseguros
                                  WHERE sseguro = psseguro
                                    AND nmovimi =
                                          (SELECT MAX(h2.nmovimi)
                                             FROM historicoseguros h2
                                            WHERE h2.sseguro = historicoseguros.sseguro
                                              AND h2.nmovimi < v_nmovimi_prog);

                                 UPDATE seguros
                                    SET fvencim = v_fvencim_prog
                                  WHERE sseguro = psseguro;
                              END IF;
                           END IF;

                           -- Fin 25. BUG 0030417_0171145 --JLTS-- 16/04/2014
                           p_tab_error(f_sysdate, f_user, 'pac_rehabilita.f_ejecuta', vpasexec, vparam,
                        v_error||' rmovseguro.cmotmov-->'||rmovseguro.cmotmov||' psseguro-->'||psseguro);
                           --Ini IAXIS-3592 -- ECP -- 29/05/2019
                           IF rmovseguro.cmotmov = 321 THEN
                                BEGIN
                                  delete movrecibo a
                                  where a.nrecibo in(select r.nrecibo from recibos r where r.sseguro = psseguro)
                                   and a.cestrec = 3; 
                                END;
                                 BEGIN
                                  delete detmovrecibo_parcial a
                                  where a.nrecibo in(select r.nrecibo from recibos r where r.sseguro = psseguro)
                                  ;
                               
                                END;
                                BEGIN
                                  delete detmovrecibo a
                                  where a.nrecibo in(select r.nrecibo from recibos r where r.sseguro = psseguro)
                                  and a.smovrec = (select max(b.smovrec) from detmovrecibo b where b.nrecibo = a.nrecibo);
                                END;
                               
                                 BEGIN
                                  delete tmp_impagados a
                                  where a.nrecibo in(select r.nrecibo from recibos r where r.sseguro = psseguro);
                               
                                END;
                                begin
                                  update movrecibo a
                                  set  a.fmovfin = null
                                  where a.nrecibo in(select r.nrecibo from recibos r where r.sseguro = psseguro)
                                   and a.cestrec = 0;
                                  
                                end;
                                
                                begin
                                select r.nrecibo 
                                into v_nrecibo
                                from recibos r where r.sseguro = psseguro;
                                end;
                                 v_error :=
           pac_user.f_get_terminal (pac_md_common.f_get_cxtusuario, vterminal);
      v_error :=
         pac_con.f_emision_pagorec (rseguros.cempres,
                                    1,
                                    4,
                                     v_nrecibo,
                                    vsmovrec,
                                    vterminal,
                                    vemitido,
                                    vsinterf,
                                    perror,
                                    f_user,
                                    NULL,
                                    NULL,
                                    NULL,
                                    1
                                   );
                                 
                           END IF;
                           --Ini IAXIS-3592 -- ECP -- 29/05/2019
                           EXIT;
                        END LOOP;
                     END IF;
                  END IF;

                  --  fin Bug 26151 - APD - 26/02/2013
                  vpasexec := 27;
                  -- Bug 25542 - APD - 16/01/2013
                  -- Se actualiza la antiguedad de las personas de la poliza
                  v_error := pac_persona.f_antiguedad_personas_pol(psseguro);

                  IF v_error <> 0 THEN
                     RAISE error_proc;
                  END IF;
               -- Fin Bug 25542 - APD - 16/01/2013
               END IF;
            END IF;
         END IF;

         EXIT;
      END LOOP;

      vpasexec := 28;

      IF v_error < 0 THEN
         v_error := 140999;   -- Si ¿s un error Oracle tornem sempre aquests.
      END IF;

      vpasexec := 29;

      SELECT sproduc
        INTO v_sproduc
        FROM seguros
       WHERE sseguro = psseguro;

      IF NVL(f_parproductos_v(v_sproduc, 'POST_REHABILITACION'), 0) = 1 THEN
         v_error := pac_propio.f_post_rehabilitacion(psseguro);

         IF v_error <> 0 THEN
            p_tab_error(f_sysdate, f_user, 'pac_rehabilita.f_ejecuta', vpasexec, vparam,
                        v_error);
            RETURN v_error;
         END IF;
      END IF;

      RETURN(v_error);
   EXCEPTION
      WHEN error_proc THEN
         p_tab_error(f_sysdate, f_user, 'pac_rehabilita.f_ejecuta', vpasexec, vparam, v_error);
         RETURN(v_error);   -- p_desc_error contindra la descripci¿ de l'error
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_rehabilita.f_ejecuta', 99,
                     'psseguro:' || psseguro || 'pcagente:' || pcagente || 'pcmotmov:'
                     || pcmotmov || 'panula_extorno:' || panula_extorno,
                     SQLERRM);
         v_error := 140999;
         RETURN(v_error);   -- p_desc_error contindra la descripci¿ de l'error
   END f_ejecuta;

   /*************************************************************************
        FUNCTION F_GET_polizasanul
        Funci¿n que recuperar¿ p¿lizas anuladas y vencidas dependiendo de los par¿metros de entrada.
        param in Psproduc: Number. C¿digo de producto.
        param in Pnpoliza: Number. n¿ de p¿liza.
        param in Pncertif: Number. n¿ de certificado.
        param in Pnnumide: Varchar2. NIF/CIF del tomador/asegurado
        param in Pbuscar: VARCHAR2.  nombre del tomador/asegurado.
        param in Psnip: VARCHAR2.  c¿digo terceros del tomador/asegurado
        param in Ptipopersona: Number.  Determina si b¿squeda por tomador o asegurado
        param in Pidioma: Number.  idioma
        param in Pcagente : NUMBER.  C¿digo del agente
        param in Pcramo:  NUMBER   C¿digo del ramo
        param out Psquery: varchar2.  consulta a realizar construida en funci¿n de los par¿metros
        return             : Devolver¿ un number con el error producido.
                             0 en caso de que haya ido correctamente.

        -- BUG 9784 - 11/05/2009 - ICV - Adaptaci¿n para IAX Bug.: 9784
   *************************************************************************/
   FUNCTION f_get_polizasanul(
      psproduc IN NUMBER,
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      pnnumide IN VARCHAR2,
      pbuscar IN VARCHAR2,
      psnip IN VARCHAR2,
      ptipopersona IN NUMBER,
      pidioma IN NUMBER,
      pcmatric IN VARCHAR2,   --BUG19605:LCF:19/02/2010
      pcpostal IN VARCHAR2,   --BUG19605:LCF:19/02/2010
      ptdomici IN VARCHAR2,   --BUG19605:LCF:19/02/2010
      ptnatrie IN VARCHAR2,   --BUG19605:LCF:19/02/2010
      pcagente IN NUMBER,   -- BUG10093:DRA:12/01/2010
      pcramo IN NUMBER,   -- BUG10093:DRA:12/01/2010
      pcpolcia IN VARCHAR2,
      pccompani IN NUMBER,
      pcactivi IN NUMBER,
      pcempres IN NUMBER,
      pcagente_cxt IN NUMBER,
      pfilage IN NUMBER,
      psquery OUT VARCHAR2,
      pcsucursal IN NUMBER DEFAULT NULL,   -- Bug 22839/126886 - 29/10/2012 - AMC
      pcadm IN NUMBER DEFAULT NULL,   -- Bug 22839/126886 - 29/10/2012 - AMC
      pcmotor IN VARCHAR2 DEFAULT NULL,   -- BUG25177/132998:JLTS:18/12/2012
      pcchasis IN VARCHAR2 DEFAULT NULL,   -- BUG25177/132998:JLTS:18/12/2012
      pnbastid IN VARCHAR2 DEFAULT NULL   -- BUG25177/132998:JLTS:18/12/2012
                                       )
      RETURN NUMBER IS
      --Ini IAXIS-3592 -- ECP -- 28/05/2019
      buscar         VARCHAR2(1000);
      tabtp          VARCHAR2(40);
      subus          VARCHAR2(1000);
      auxnom         VARCHAR2(400);
      num_err        NUMBER := 0;
      vform          VARCHAR2(1000) := '';
   BEGIN
   --Ini IAXIS-3592 -- ECP -- 28/05/2019
      buscar :=
         buscar
         || ' where m.sseguro = s.sseguro and m.sseguro = pd.sseguro  and m.nmovimi in (SELECT MAX (nmovimi) FROM movseguro m2 '
         || ' WHERE m2.sseguro = s.sseguro and m2.cmovseg in (3,53)) and s.csituac IN (2, 3,18,19) and m.cmotmov = g.cmotmov and g.cidioma = '
         || pidioma;
   --Ini IAXIS-3592 -- ECP -- 28/05/2019
      IF NVL(psproduc, 0) <> 0 THEN
         buscar := buscar || ' and s.sproduc=' || psproduc;
      END IF;

      IF pnpoliza IS NOT NULL THEN
         buscar := buscar || ' and s.npoliza=' || pnpoliza;
      END IF;

      IF pncertif IS NOT NULL THEN
         buscar := buscar || ' and s.ncertif=' || pncertif;
      END IF;

      IF pcpolcia IS NOT NULL THEN
         buscar := buscar || ' and upper(s.cpolcia) like ' || CHR(39) || '%' || pcpolcia
                   || '%' || CHR(39);   -- BUG 14585 - PFA - Anadir campo poliza compania
      END IF;

      IF pcactivi IS NOT NULL THEN
         buscar := buscar || ' and s.cactivi = ' || pcactivi;
      END IF;

      IF pccompani IS NOT NULL THEN
         buscar := buscar || ' and s.CCOMPANI = ' || pccompani;
      END IF;

      IF pcagente IS NOT NULL THEN
         buscar := buscar || ' and s.cagente = ' || pcagente;
      END IF;

      IF pfilage = 0 THEN
         IF NVL(pac_parametros.f_parempresa_n(pcempres, 'FILTRO_AGE'), 0) = 1 THEN
            --Bug.: 0016730 - ICV - 06/05/2011
            buscar :=
               buscar
               || ' and s.cagente in (SELECT a.cagente
                                    FROM (SELECT     LEVEL nivel, cagente
                                                FROM redcomercial r
                                               WHERE
                                                  r.fmovfin is null
                                          START WITH
                                                  r.cagente = '
               || pcagente_cxt || ' AND r.cempres = ' || pcempres
               || ' and r.fmovfin is null
                                          CONNECT BY PRIOR r.cagente =(r.cpadre + 0)
                                                 AND PRIOR r.cempres =(r.cempres + 0)
                                                 and r.fmovfin is null
                                                 AND r.cagente >= 0) rr,
                                         agentes a
                                   where rr.cagente = a.cagente)';
         END IF;
      END IF;

      IF pcempres IS NOT NULL THEN
         buscar := buscar || ' and s.cempres = ' || pcempres;
      END IF;

      IF pcmatric IS NOT NULL THEN
         vform := vform || ' , autriesgos aut ';
         buscar := buscar
                   || ' and aut.sseguro = s.sseguro and upper(aut.cmatric)like upper(''%'
                   || pcmatric || '%'')';
      END IF;

      -- Bug 25177/133016 - 28/12/2012 - AMC
      IF pcmotor IS NOT NULL THEN
         IF vform IS NULL THEN
            vform := vform || ' , autriesgos aut ';
            buscar := buscar || ' and aut.sseguro = s.sseguro ';
         END IF;

         buscar := buscar || ' and upper(aut.codmotor)like upper(''%' || pcmotor || '%'')';
      END IF;

      IF pcchasis IS NOT NULL THEN
         IF vform IS NULL THEN
            vform := vform || ' , autriesgos aut ';
            buscar := buscar || ' and aut.sseguro = s.sseguro ';
         END IF;

         buscar := buscar || ' and upper(aut.cchasis)like upper(''%' || pcchasis || '%'')';
      END IF;

      IF pnbastid IS NOT NULL THEN
         IF vform IS NULL THEN
            vform := vform || ' , autriesgos aut ';
            buscar := buscar || ' and aut.sseguro = s.sseguro ';
         END IF;

         buscar := buscar || ' and upper(aut.nbastid)like upper(''%' || pnbastid || '%'')';
      END IF;

      -- Fi Bug 25177/133016 - 28/12/2012 - AMC
      IF pcpostal IS NOT NULL
         OR ptdomici IS NOT NULL THEN
         vform := vform || ' , sitriesgo sit ';
      END IF;

      IF pcpostal IS NOT NULL THEN
         buscar := buscar
                   || ' and sit.sseguro = s.sseguro and upper(sit.cpostal) like upper(''%'
                   || pcpostal || '%'')';
      END IF;

      IF ptdomici IS NOT NULL THEN
         buscar := buscar
                   || ' and sit.sseguro = s.sseguro and upper(sit.tdomici) like upper(''%'
                   || ptdomici || '%'')';
      END IF;

      IF ptnatrie IS NOT NULL THEN
         vform := vform || ' , riesgos rie ';
         buscar := buscar || ' and rie.sseguro = s.sseguro and rie.tnatrie like ''%'
                   || ptnatrie || '%''';
      END IF;

      -- BUG19605:LCF:19/02/2010:fi

      -- BUG10093:DRA:12/01/2010:inici
      IF pcagente IS NOT NULL THEN
         buscar := buscar || ' and s.cagente=' || pcagente;
      END IF;

      IF pcramo IS NOT NULL THEN
         buscar := buscar || ' and s.cramo=' || pcramo;
      END IF;

      -- Bug 22839/126886 - 29/10/2012 - AMC
      IF pcsucursal IS NOT NULL
         OR pcadm IS NOT NULL THEN
         vform := vform || ' ,seguredcom src ';
         buscar := buscar || ' AND s.sseguro = src.sseguro ';

         IF pcsucursal IS NOT NULL THEN
            buscar := buscar || ' AND src.c02 = ' || pcsucursal;
         END IF;

         IF pcadm IS NOT NULL THEN
            buscar := buscar || ' AND src.c03 = ' || pcadm;
         END IF;
      END IF;

      -- Fi Bug 22839/126886 - 29/10/2012 - AMC

      -- BUG10093:DRA:12/01/2010:fi
      buscar := buscar
                || ' and pac_parametros.F_PARPRODUCTO_N(s.SPRODUC,''PERMITE_REHABILITA'') = 1 ';

      -- buscar per personas
      IF (pnnumide IS NOT NULL
          OR NVL(psnip, ' ') <> ' '
          OR pbuscar IS NOT NULL)
         AND NVL(ptipopersona, 0) > 0 THEN
         IF ptipopersona = 1 THEN   -- Prenedor
            tabtp := 'TOMADORES';
         ELSIF ptipopersona = 2 THEN   -- Assegurat
            tabtp := 'ASEGURADOS';
         ELSIF ptipopersona = 3 THEN   -- Conductor
            tabtp := 'AUTCONDUCTORES';
         END IF;

         IF tabtp IS NOT NULL THEN
            subus := ' and s.sseguro IN (SELECT a.sseguro FROM ' || tabtp
                     || ' a, PERSONAS p WHERE a.sperson = p.sperson';

            IF pnnumide IS NOT NULL THEN
               --Bug 371152-21271 Busqueda de NIF minuscula KJSC 26/08/2015
               IF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa(),
                                                    'NIF_MINUSCULAS'),
                      0) = 1 THEN
                  subus := subus || ' AND UPPER(p.nnumnif) = UPPER(' || CHR(39)
                           || ff_strstd(pnnumide)   -- BUG 38344/217178 - 10/11/2015 - ACL
                           || CHR(39) || ')';
               ELSE
                  subus := subus || ' AND p.nnumnif = ' || CHR(39) || ff_strstd(pnnumide)
                           || CHR(39)   -- BUG 38344/217178 - 10/11/2015 - ACL
                                     || '';
               END IF;
            END IF;

            IF NVL(psnip, ' ') <> ' ' THEN
               subus := subus || ' AND upper(p.snip)=upper(''' || psnip || ''')';
            END IF;

            IF pbuscar IS NOT NULL THEN
               num_err := f_strstd(pbuscar, auxnom);

               IF num_err <> 0 THEN
                  RETURN num_err;
               END IF;

               subus := subus || ' AND upper(p.tbuscar) like upper(''%' || auxnom || '%'')';
            END IF;

            subus := subus || ')';
         END IF;
      END IF;

      -- Bug 18946 - APD - 14/11/2011 - se a¿ade el filtro por agentes_agente_pol
      buscar :=
         buscar
         || ' and (s.cagente,s.cempres) in (select aa.cagente, aa.cempres from agentes_agente_pol aa) ';
      -- Fin Bug 18946 - APD - 14/11/2011
      psquery :=
         'select s.cobjase, s.sseguro, s.cpolcia, s.npoliza, s.ncertif, f_nombre (pd.sperson, 1) tomador,'
         || 'PAC_IAXPAR_PRODUCTOS.f_get_parproducto(''ADMITE_CERTIFICADOS'', s.sproduc) mostra_certif,'
         || 'F_DESPRODUCTO_T(s.cramo, s.cmodali, s.ctipseg, s.ccolect, 1,' || pidioma
         || ') tproduc, s.fefecto, s.fvencim, s.fanulac, g.tmotmov, ff_desagente(s.cagente) tagente, s.femisio femisio, '
         || ' s.cactivi, ff_desactividad (s.cactivi, s.cramo, PAC_MD_COMMON.f_get_cxtidioma, 2) tactivi, '
         || ' ff_descompania(s.ccompani) tcompani, s.ccompani '
         || 'from seguros s, movseguro m, motmovseg g,tomadores pd ' || vform || buscar
         || subus || 'order by s.npoliza, s.ncertif';
      RETURN num_err;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'f_get_polizasanul', 1, 'When Others err:' || SQLCODE,
                     SQLERRM);
         RETURN 140897;
   END f_get_polizasanul;

    /*************************************************************************
        FUNCTION F_get_fsuplem
        Funci¿n que recuperar¿ la fecha de efecto del ¿ltimo suplemento realizado a la p¿liza.
        param in Psseguro: Number. Identificador del Seguro.
        return             : Date en caso correcto
                             Nulo en caso incorrecto

        -- BUG 9784 - 11/05/2009 - ICV - Adaptaci¿n para IAX Bug.: 9784
   *************************************************************************/
   FUNCTION f_get_fsuplem(psseguro IN NUMBER)
      RETURN DATE IS
      v_npoliza      seguros.npoliza%TYPE;
      v_ncertif      seguros.ncertif%TYPE;
      v_nsuplem      seguros.nsuplem%TYPE;
      v_fefepol      DATE;
      v_fefesupl     DATE;
      num_err        NUMBER := 0;
   BEGIN
      SELECT seg.npoliza, seg.ncertif
        INTO v_npoliza, v_ncertif
        FROM seguros seg
       WHERE seg.sseguro = psseguro;

      num_err := f_ultsupl(v_npoliza, v_ncertif, v_nsuplem, v_fefepol, v_fefesupl);

      IF num_err <> 0 THEN
         p_tab_error(f_sysdate, f_user, 'f_get_fsuplem', 1, 'num_err: ' || num_err, SQLERRM);
         RETURN NULL;
      END IF;

      RETURN v_fefesupl;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'f_get_fsuplem', 2, 'Others Sseguro: ' || psseguro,
                     SQLERRM);
         RETURN NULL;
   END f_get_fsuplem;

   /*************************************************************************
        FUNCTION F_get_motanul
        Funci¿n que recuperar¿ la descripci¿n del motivo de anulaci¿n de la p¿liza.
        param in Psseguro: Number. Identificador del Seguro.
        return             : Devuelve un varchar con el motivo de anulaci¿n en caso correcto
                             Nulo en caso incorrecto

        -- BUG 9784 - 11/05/2009 - ICV - Adaptaci¿n para IAX Bug.: 9784
   *************************************************************************/
   FUNCTION f_get_motanul(psseguro IN NUMBER, pidioma IN NUMBER)
      RETURN VARCHAR2 IS
      num_err        NUMBER := 0;
      v_tmotmov      motmovseg.tmotmov%TYPE;
      v_fanulac      DATE;
   BEGIN
      SELECT seg.fanulac
        INTO v_fanulac
        FROM seguros seg
       WHERE seg.sseguro = psseguro;

      num_err := f_desmotanu(psseguro, v_fanulac, pidioma, v_tmotmov);

      IF num_err <> 0 THEN
         p_tab_error(f_sysdate, f_user, 'f_get_motanul', 1, 'num_err: ' || num_err, SQLERRM);
         RETURN NULL;
      END IF;

      RETURN v_tmotmov;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'f_get_motanul', 2, 'Others: ' || num_err, SQLERRM);
         RETURN NULL;
   END f_get_motanul;

   /*************************************************************************
       FUNCTION f_recobra_extorno
       Genera un recibo por el importe de cada uno de los extornos generados en la anulacion
        param in Psseguro: Number.   Identificador del Seguro.
              in Pnmovimi: Number.   Movimiento de rehabilitacion
              in Pcagente: Varchar2. Codigo de Agente
        return           : 0 en caso correcto
                                  error en caso contrario
        BUG 11997 - 01/02/2010 - ASN
   *************************************************************************/
   FUNCTION f_recobra_extorno(psseguro IN NUMBER, pnmovimi IN NUMBER, pcagente IN VARCHAR2)
      RETURN NUMBER IS
      xnrecibo       recibos.nrecibo%TYPE;
      xparametro     VARCHAR2(7);
      dummy          NUMBER;
      error          NUMBER;

      CURSOR extornos(psseguro IN NUMBER) IS
         SELECT r.nrecibo, fefecto, fvencim, esccero
           FROM recibos r, vdetrecibos v
          WHERE r.sseguro = psseguro
            AND r.ctiprec = 9   -- Recibos de extorno
            AND v.itotalr != 0   -- Con importe != 0
            AND v.nrecibo = r.nrecibo
            AND r.nmovimi = (SELECT MAX(nmovimi)
                               FROM movseguro
                              WHERE sseguro = r.sseguro
                                AND cmovseg = 3)
            AND f_cestrec(r.nrecibo, NULL) = 1;   -- Cobrados
   BEGIN
      FOR r IN extornos(psseguro) LOOP
         xnrecibo := 0;

         IF r.esccero = 1 THEN
            xparametro := 'CERTIF0';
         ELSE
            xparametro := NULL;
         END IF;

         error := f_insrecibo(psseguro, pcagente, f_sysdate, r.fefecto, r.fvencim, 1, NULL,
                              NULL, NULL, NULL, NULL, xnrecibo, 'R', NULL, NULL, pnmovimi,
                              NULL, xparametro);

         IF xnrecibo = 0 THEN
            error := 777;   -- ********************************** BUSCAR MENSAJE Error al generar XXXX (?)
         END IF;

         EXIT WHEN error <> 0;

         BEGIN
            INSERT INTO detrecibos
                        (nrecibo, cconcep, cgarant, nriesgo, iconcep)
               SELECT xnrecibo, cconcep, cgarant, nriesgo, iconcep
                 FROM detrecibos
                WHERE nrecibo = r.nrecibo;
         EXCEPTION
            WHEN OTHERS THEN
               error := 777;
         END;

         IF error = 0 THEN
            BEGIN
               error := f_vdetrecibos('R', xnrecibo);

               IF error = 0 THEN
                  error := f_rebnoimprim(xnrecibo, f_sysdate, dummy, 0);
               END IF;
            EXCEPTION
               WHEN OTHERS THEN
                  error := 777;
            END;
         END IF;

         EXIT WHEN error <> 0;

         -- BUG24802:DRA:20/11/2012:Inici
         IF pac_corretaje.f_tiene_corretaje(psseguro, NULL) = 1 THEN
            -- 24.0 - 27/03/2014 - MMM - 0030713: LCOL_F002-0011957-11958-11959: Se realizo anulacion... Inicio
            --error := pac_corretaje.f_gen_comision_corr(psseguro, pnmovimi, xnrecibo);
            error := pac_corretaje.f_reparto_corretaje(psseguro, pnmovimi, xnrecibo);

            -- 24.0 - 27/03/2014 - MMM - 0030713: LCOL_F002-0011957-11958-11959: Se realizo anulacion en polizas... Fin
            IF error <> 0 THEN
               p_tab_error(f_sysdate, f_user, 'pac_rehabilita.f_recobra_extorno', 1,
                           'psseguro:' || psseguro || ' pnmovimi:' || pnmovimi || ' pcagente:'
                           || pcagente || ' xnrecibo:' || xnrecibo,
                           f_axis_literales(error, f_usu_idioma));
               RETURN error;
            END IF;
         END IF;
      -- BUG24802:DRA:20/11/2012:Fi
      END LOOP;

      RETURN error;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_rehabilita.f_recobra_extorno', 99,
                     'psseguro:' || psseguro || ' pnmovimi:' || pnmovimi, SQLERRM);
   END f_recobra_extorno;

   -- BUG 19276 Reemplazos jbn
    /*************************************************************************
       FUNCTION   F_VALIDA_REHABILITA
       validaciones necesarias para determinar si una p¿liza anulada se puede rehabilitar
        param in Psseguro: Number.   Identificador del Seguro.
              in Pnmovimi: Number.   Movimiento de rehabilitacion
              in Pcagente: Varchar2. Codigo de Agente
        return           : 0 en caso correcto
                                  error en caso contrario
   *************************************************************************/
   FUNCTION f_valida_rehabilita(psseguro IN NUMBER)
      RETURN NUMBER IS
      vsproduc       NUMBER;
      v_fanulac      DATE;
      vcmotmov       NUMBER;
      vcmotven       NUMBER;

      v_permite      NUMBER; --INI CONF_241 KJSC ANULACION GTEC17
      vrealiza       NUMBER;
      vcempres       seguros.cempres%TYPE;
      v_sysdate      NUMBER;
      v_anulacion    NUMBER; --FIN CONF_241 KJSC ANULACION GTEC17

   BEGIN

     vcempres := pac_md_common.f_get_cxtempresa;

      SELECT seg.fanulac, seg.sproduc
        INTO v_fanulac, vsproduc
        FROM seguros seg
       WHERE seg.sseguro = psseguro;

      -- Obtenemos el motivo de anulaci¿n
      -- Ini 3592 --ECP -- 29/05/2019
      BEGIN
         SELECT cmotmov, cmotven
           INTO vcmotmov, vcmotven
           FROM movseguro
          WHERE sseguro = psseguro
            AND cmovseg in (3,53)
            AND fefecto = TRUNC(v_fanulac)
            AND nmovimi = (SELECT MAX(nmovimi)   --Mira que sea el
                             FROM movseguro   --¿ltimo movimiento
                            WHERE sseguro = psseguro);
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 1;
      END;
 -- Fin 3592 --ECP -- 29/05/2019
      IF pac_parametros.f_parmotmov_n(vcmotmov, 'MOTMOV_PERMITE_REHAB', vsproduc) = 0
         OR(pac_parametros.f_parmotmov_n(vcmotven, 'MOTMOV_PERMITE_REHAB', vsproduc) = 0
            AND vcmotven IS NOT NULL) THEN
         RETURN 9902378;
      END IF;
      --INI CONF_241 KJSC ANULACION GTEC17
      IF NVL(pac_parametros.f_parempresa_n(vcempres, 'MES_ANULA_MES_REHAB'), 0) = 1
         AND vcmotmov in (221,321) THEN

         v_sysdate   := TO_CHAR(SYSDATE,'MMYYYY');
         v_anulacion := TO_CHAR(v_fanulac,'MMYYYY');

         IF v_sysdate =  v_anulacion THEN
           RETURN 0;
         ELSE
            RETURN 9909297;
         END IF;

         IF vcmotmov = 321 THEN
            v_permite := pac_cfg.f_get_user_accion_permitida(f_user, 'REHAB_POLIZA_IMP', NULL,
                                                            vcempres, vrealiza);
         ELSE
	           v_permite := pac_cfg.f_get_user_accion_permitida(f_user, 'REHAB_POLIZA', NULL,
                                                             vcempres, vrealiza);
         END IF;
         IF v_permite = 1 THEN
            RETURN 0;
         ELSE
            RETURN 109905;
         END IF;
      END IF;
      --FIN CONF_241 KJSC ANULACION GTEC17

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_rehabilita.F_VALIDA_REHABILITA', 1,
                     'psseguro:' || psseguro||'vrealiza'||vrealiza, SQLERRM);
   END f_valida_rehabilita;

-- fin BUG 19276 Reemplazos jbn
   FUNCTION f_set_solrehab(
      psseguro IN NUMBER,
      pcmotmov IN NUMBER,
      pnriesgo IN NUMBER,
      pfrehab IN DATE,
      ptobserv IN VARCHAR2)
      RETURN NUMBER IS
      num_err        NUMBER := 0;
      v_nmovimi      NUMBER;
      v_dummy        NUMBER := 0;
      wnorden        NUMBER;
      wnpoliza       NUMBER;
      pcclagd        NUMBER;
      vidapunte      NUMBER;
      v_cagente      NUMBER;
      v_ctipage      NUMBER;
      v_cempres      NUMBER;
      vcidioma       NUMBER;
      xfanulac       DATE;
   BEGIN
      SELECT MAX(nmovimi) + 1
        INTO v_nmovimi
        FROM movseguro m
       WHERE m.sseguro = psseguro;

      BEGIN
         SELECT fanulac
           INTO xfanulac
           FROM seguros
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 105581;
      END;

      /*   BEGIN
            SELECT cmovseg
              INTO wcmovseg
              FROM codimotmov
             WHERE cmotmov = pcmotmov;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 105561;
         END;*/

      --Comrpobamos que no exista ya una en estado pendiente
      SELECT COUNT('1')
        INTO v_dummy
        FROM sup_solicitud ss
       WHERE ss.sseguro = psseguro
         AND ss.nmovimi = v_nmovimi
         AND ss.cmotmov = pcmotmov
         AND ss.nriesgo = NVL(pnriesgo, 0)
         AND ss.cgarant = 0
         AND ss.cpregun = 0
         AND ss.cestsup = 0;

      IF NVL(v_dummy, 0) <> 0 THEN
         RETURN 9901731;
      END IF;

      --BUG 0016775 - 28/04/2011 - FAL - Se a¿ade secuencial para saber que baja imprimimr
      SELECT NVL(MAX(norden), 0) + 1
        INTO wnorden
        FROM sup_solicitud
       WHERE sseguro = psseguro;

      INSERT INTO sup_solicitud
                  (sseguro, nmovimi, cmotmov, nriesgo, cgarant,
                   tvalora,
                   tvalord, cpregun, cestsup,
                   festsup, cususol, tobserv, norden)
           VALUES (psseguro, v_nmovimi, pcmotmov, NVL(pnriesgo, 0), 0,
                   pac_md_listvalores.f_get_sit_pol_detalle(psseguro),
                   f_axis_literales(9001825, pac_md_common.f_get_cxtidioma), 0, 0,
                   NVL(pfrehab, f_sysdate), f_user, ptobserv, wnorden);

      --BUG 0016775 - 28/04/2011 - FAL - cambio situaci¿n Anulaci¿n ... si Nota informativa o Proyecto g¿rico
      UPDATE seguros
         SET csituac = DECODE(csituac, 12, 13, 14, 15)
       WHERE sseguro = psseguro
         AND csituac IN(12, 14);

      BEGIN
         --BUG 0016775 - 28/04/2011 - FAL - crear tarea en la agenda
         SELECT npoliza, cempres
           INTO wnpoliza, v_cempres
           FROM seguros
          WHERE sseguro = psseguro;

         SELECT DISTINCT s.cagente, r.ctipage, cidioma
                    INTO v_cagente, v_ctipage, vcidioma
                    FROM seguros s, redcomercial r
                   WHERE s.sseguro = psseguro
                     AND r.cagente = s.cagente
                     AND r.fmovini = (SELECT MAX(rr.fmovini)
                                        FROM redcomercial rr
                                       WHERE rr.cempres = v_cempres
                                         AND rr.cagente = s.cagente);

         pcclagd := 1;   -- C¿digo Clave Agenda 0:siniestro / 1:poliza
         num_err := pac_agenda.f_set_apunte(NULL, NULL, pcclagd, psseguro, 0, 0, 0,   --5, -- Lo asgino al grupo 0 -- OBSV
                                            pac_parametros.f_parempresa_t(v_cempres,
                                                                          'ENV_TAREAS_DEF'),
                                            f_axis_literales(9902334, vcidioma),   --9216
                                            f_axis_literales(9902335, vcidioma) || wnpoliza, 0,
                                            0, NULL, NULL, f_user, NULL, f_sysdate, f_sysdate,
                                            NULL, vidapunte);
         num_err :=
            pac_agenda.f_set_agenda
               (vidapunte, NULL, NULL, 0,   --Lo enviamos al nodo superior de la red comercial
                pac_parametros.f_parempresa_t(v_cempres, 'ENV_TAREAS_DEF'),   --enviamos la tarea al grupo gestion 921602
                pcclagd, psseguro, NULL, f_user, v_ctipage, v_cagente, v_cempres, vcidioma,
                'SUPLEMENTO_REHAB');
      EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, 'pac_anulacion.f_set_agenda', 1,
                        'Error no controlado', SQLERRM);
      END;

      RETURN num_err;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_rehabilita.f_set_solrehab', 1,
                     'Error no controlado', SQLERRM);
         RETURN 1000001;
   END f_set_solrehab;
END pac_rehabilita;

/