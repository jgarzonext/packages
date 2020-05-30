--------------------------------------------------------
--  DDL for Function F_PRIMA_FORPAG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_PRIMA_FORPAG" (
   ptablas IN VARCHAR2,
   pctipo IN NUMBER,
   pcmodo IN NUMBER,
   psseguro IN NUMBER,
   pnriesgo IN NUMBER,
   pcgarant IN NUMBER,
   piprianu IN NUMBER,
   pnmovimi IN NUMBER DEFAULT NULL,
   pcforpag IN NUMBER DEFAULT NULL,
   pfefecto IN DATE DEFAULT NULL)
   RETURN NUMBER AUTHID CURRENT_USER IS
    /* **************************************************************************************
       Función que te retorna la prima según la forma de pago
       pctipo: 1.- sólo recargo por fraccionamiento
                 2.- recargo por fraccionamiento más impuestos
                  (no se tienen en cuenta los impuestos que sólo se calculan en el primer recibo.
                   consorcio, clea....)
       pcmodo: 1.- toda la póliza
                 2.- a nivel de riesgo
               3.- a nivel de garantía
       piprianu: DEPENDIENDO DEL CPMODO ELEGIDO SE TENDRÁ QUE PASAR LA PRIMA ANUAL A NIVEL
                 DE GARANTÍA, RIESGO O SEGURO
       ptablas: 'EST', 'SOL', 'CAR'

       18/01/2005  MCA se incluye el nmovimi en los cursores para el modo 1 y 2

     Ver        Fecha        Autor             Descripción
    ---------  ----------  ---------------  ------------------------------------
    2.0        02/04/2009  XCG                1. Modificació de la funció. Utilizar la función ff_get_actividad para buscar la actividad BUG9614
    3.0        01/08/2009  NMM                2. 10864: CEM - Tasa aplicable en Consorcio.
    4.0        28/11/2011  JMP                3. 0018423: LCOL000 - Multimoneda
    5.0        06/01/2012  JTS                4. 20905: LCOL897 - INCIDENCIA IMPRESIONS
   *******************************************************************************************/

   --
   -- Garantías a nivel de Póliza o de riesgo dependiendo del parámetro pnriesgo.
   CURSOR cur_garantias(par_sseguro IN NUMBER, par_nriesgo IN NUMBER, par_nmovimi IN NUMBER) IS
      SELECT nriesgo, cgarant, NVL(iprianu, 0) iprianu
        FROM garanseg
       WHERE sseguro = par_sseguro
         AND(ffinefe IS NULL
             OR pnmovimi IS NOT NULL)   -- Que este vigente
         AND nriesgo = NVL(par_nriesgo, nriesgo)
         AND nmovimi = NVL(pnmovimi, nmovimi);

   --
   -- Garantías a nivel de Póliza o de riesgo dependiendo del parámetro pnriesgo.
   CURSOR cur_garantias_est(par_sseguro IN NUMBER, par_nriesgo IN NUMBER, par_nmovimi IN NUMBER) IS
      SELECT nriesgo, cgarant, NVL(iprianu, 0) iprianu
        FROM estgaranseg
       WHERE sseguro = par_sseguro
         AND cobliga = 1   -- Que este vigente
         AND nriesgo = NVL(par_nriesgo, nriesgo)
         AND nmovimi = NVL(pnmovimi, nmovimi);

   -- Garantías a nivel de Póliza o de riesgo dependiendo del parámetro pnriesgo.
   CURSOR cur_garantias_sol(par_sseguro IN NUMBER, par_nriesgo IN NUMBER) IS
      SELECT nriesgo, cgarant, NVL(iprianu, 0) iprianu
        FROM solgaranseg
       WHERE ssolicit = par_sseguro
         AND cobliga = 1   -- Que este vigente
         AND nriesgo = NVL(par_nriesgo, nriesgo);

   v_cramo        NUMBER;
   v_cmodali      NUMBER;
   v_ctipseg      NUMBER;
   v_ccolect      NUMBER;
   v_cforpag      NUMBER;
   v_cactivi      NUMBER;
   v_crecfrac     NUMBER;
   xprecarg       NUMBER;
   ximpuestos     NUMBER;
   xprecarg_1     NUMBER;
   ximpuestos_1   NUMBER;
   xnriesgo       NUMBER;
   xipriforpag    NUMBER;
   xipriforpag_1  NUMBER;
   -- Bug 10864.NMM.01/08/2009.
   w_climit       NUMBER;
   v_cmonimp      imprec.cmoneda%TYPE;   -- BUG 18423 - LCOL000 - Multimoneda
   vcderreg       NUMBER;   -- Bug 0020314 - FAL - 29/11/2011
   vfefecto       DATE;

-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------
   FUNCTION f_calcula_recargo_fracc(
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pcforpag IN NUMBER,
      piprianu IN NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER)
      RETURN NUMBER IS
      /***************************************************************************************
         retorna el porcentaje de recargo por fraccionamiento
      ****************************************************************************************/
      xprecarg       NUMBER;
      vcempres       NUMBER;
      vctipcon       NUMBER;
      vcfracci       NUMBER;
      vcbonifi       NUMBER;
      vcrecfra       NUMBER;
      virecfra       NUMBER;
      oiconcep       NUMBER;
      v_crecfra      NUMBER;
      verr           NUMBER;
      -- JLB - I - BUG 18423 COjo la moneda del producto
      vmoneda        monedas.cmoneda%TYPE;
      -- JLB - F - BUG 18423 COjo la moneda del producto
      vvmode         VARCHAR2(10);
   BEGIN
      -- LPS (10/09/2008). Se modifica la forma de obtener el recargo por el Nuevo módulo de impuestos.
      BEGIN
         SELECT cempres
           INTO vcempres
           FROM codiram
          WHERE cramo = pcramo;
      EXCEPTION
         WHEN OTHERS THEN
            xprecarg := 0;
      END;

      -- JLB - I - BUG 18423 COjo la moneda del producto
      vmoneda := pac_monedas.f_moneda_producto(pac_productos.f_get_sproduc(pcramo, pcmodali,
                                                                           pctipseg, pccolect));
      -- JLB - F - BUG 18423 COjo la moneda del producto
      verr := f_concepto(8, vcempres, f_sysdate, pcforpag, pcramo, pcmodali, pctipseg,
                         pccolect, pcactivi, pcgarant, vctipcon, xprecarg, vcfracci, vcbonifi,
                         vcrecfra, w_climit,   -- Bug 10864.NMM.01/08/2009.
                         v_cmonimp,   -- BUG 18423 - LCOL000 - Multimoneda
                         vcderreg);   -- Bug 0020314 - FAL - 29/11/2011

      IF verr <> 0 THEN   -- Si da error la función.
         virecfra := 0;
      ELSE
         SELECT DECODE(ptablas, 'EST', 'EST', 'SEG')
           INTO vvmode
           FROM DUAL;

         verr := pac_impuestos.f_calcula_impconcepto(xprecarg, piprianu / pcforpag,
                                                     piprianu / pcforpag, NULL, NULL, NULL,
                                                     NULL, NULL, NULL, vctipcon, pcforpag,
                                                     vcfracci, vcbonifi, vcrecfra, oiconcep,

                                                     -- JLB - I - BUG 18423 COjo la moneda del producto
                                                     NULL, NULL, NULL, vfefecto, psseguro,
                                                     pnriesgo, pcgarant, vmoneda, vvmode);
         -- JLB - F - BUG 18423 COjo la moneda del producto

         --virecfra := NVL(oiconcep, 0);
         virecfra :=
            f_round(NVL(oiconcep, 0),
                    pac_monedas.f_moneda_producto(pac_productos.f_get_sproduc(pcramo, pcmodali,
                                                                              pctipseg,
                                                                              pccolect)))
            * pcforpag;
      END IF;

      RETURN virecfra / pcforpag;
   END f_calcula_recargo_fracc;

---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
   FUNCTION f_calcula_impuestos(
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pcforpag IN NUMBER,
      piprianu IN NUMBER,
      pcrecfrac IN NUMBER,
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pnriesgo IN NUMBER,
      pmode IN NUMBER)
      RETURN NUMBER IS
      /********************************************************************************************
        De momento SÓLO CALCULAMOS impuestos que no se calculan en el primer recibo
          Calculamos: IPS
                      ARB

          pcrecfrac: 1.- se aplica recargo
                      0.- No se aplica recargo

      *********************************************************************************************/
      xips_fracc     NUMBER;   --indicador de si aplicamos IPS al recargo por fraccionamiento
      xarb_fracc     NUMBER;   -- indicador de si se deben fraccionar los arbitrios
      ximp_boni      NUMBER;   -- indicador de si aplicamos los mpuestos sobre la prima bonificada
      xdgs_fracc     NUMBER;   -- indicador de si aplicamos CLEA al recargo por fraccionamiento
      xcimpdgs       NUMBER;   -- indicador de si la garantía calcula DGS (CLEA)
      xcimpips       NUMBER;   -- indicador de si la garantía calcula IPS
      xcderreg       NUMBER;   -- indicador de si la garantía calcula DER. REG.
      xcimparb       NUMBER;   -- indicador de si la garantía calcula ARBITRIOS
      xcimpfng       NUMBER;   -- indicador de si la garantía calcula FNG
      taxaips        NUMBER;   -- % de IPS
      taxaarb        NUMBER;   -- % de ARB
      taxafng        NUMBER;   -- % deFNG
      tot_recfrac    NUMBER;
      xirecfrac      NUMBER := 0;   -- importe de recargo por fraccionamiento de la garantía
      xips           NUMBER := 0;   -- importe IPS
      xarb           NUMBER := 0;   -- importe ARB
      xfng           NUMBER := 0;   -- importe FNG
      xdgs           NUMBER := 0;   -- importe DGS
      vcempres       NUMBER;   -- LPS (18/09/2008), para el nuevo módulo de impuestos.
      vnvalcon       NUMBER;   -- LPS (18/09/2008), para el nuevo módulo de impuestos.
      vctipcon       NUMBER;   -- LPS (18/09/2008), para el nuevo módulo de impuestos.
      vcfracci       NUMBER;   -- LPS (18/09/2008), para el nuevo módulo de impuestos.
      vcbonifi       NUMBER;   -- LPS (18/09/2008), para el nuevo módulo de impuestos.
      vcrecfra       NUMBER;   -- LPS (18/09/2008), para el nuevo módulo de impuestos.
      xicapital      NUMBER;   -- LPS (18/09/2008), para el nuevo módulo de impuestos.
      verr           NUMBER;   -- LPS (18/09/2008), para el nuevo módulo de impuestos.
   BEGIN
      -- LPS (10/09/2008). Se modifica la forma de obtener los impuestos por el Nuevo módulo de impuestos.
      BEGIN
         SELECT cempres
           INTO vcempres
           FROM codiram
          WHERE cramo = pcramo;
      EXCEPTION
         WHEN OTHERS THEN
            vcempres := NULL;
      END;

      -- Comentado (LPS 17/09/2008), para el nuevo módulo de impuestos.

      -- El IPS se aplica al recargo de fraccionamiento 0.- No, 1.- Si
      --xips_fracc := NVL(f_parinstalacion_n('IPS_FRACC'),1);
      -- Se debe fraccionar los arbitrios 0.- no 1.- Si
      --xarb_fracc := NVL(f_parinstalacion_n('ARB_FRAC'),1);
      -- Los impuestos: CLEA, arbitris se aplican sobre la prima bonificada o no
      --ximp_boni := NVL(f_parinstalacion_n('IMP_BONI'),0);
      -- La CLEA se aplica al recargo por fraccionamiento 0.- no, 1.- si
      --xdgs_fracc := NVL(f_parinstalacion_n('CLEA_FRACC'),0);
      BEGIN
         SELECT NVL(cimpdgs, 0), NVL(cimpips, 0), NVL(cderreg, 0), NVL(cimparb, 0),
                NVL(cimpfng, 0)
           INTO xcimpdgs, xcimpips, xcderreg, xcimparb,
                xcimpfng
           FROM garanpro
          WHERE cramo = pcramo
            AND cmodali = pcmodali
            AND ctipseg = pctipseg
            AND ccolect = pccolect
            AND cactivi = pcactivi
            AND cgarant = pcgarant;
      EXCEPTION
         WHEN OTHERS THEN
            BEGIN
               SELECT NVL(cimpdgs, 0), NVL(cimpips, 0), NVL(cderreg, 0), NVL(cimparb, 0),
                      NVL(cimpfng, 0)
                 INTO xcimpdgs, xcimpips, xcderreg, xcimparb,
                      xcimpfng
                 FROM garanpro
                WHERE cramo = pcramo
                  AND cmodali = pcmodali
                  AND ctipseg = pctipseg
                  AND ccolect = pccolect
                  AND cactivi = 0
                  AND cgarant = pcgarant;
            EXCEPTION
               WHEN OTHERS THEN
                  RETURN 0;
            END;
      END;

      IF pcrecfrac = 1 THEN
         xirecfrac := f_calcula_recargo_fracc(pcramo, pcmodali, pctipseg, pccolect, pcactivi,
                                              pcgarant, pcforpag, piprianu, psseguro,
                                              pnriesgo);
      ELSE
         xirecfrac := 0;
      END IF;

      --- Calculamos el IPS
      IF xcimpips > 0 THEN
         vctipcon := NULL;
         vnvalcon := NULL;
         vcfracci := NULL;
         vcbonifi := NULL;
         vcrecfra := NULL;
         verr := f_concepto(4, vcempres, f_sysdate, pcforpag, pcramo, pcmodali, pctipseg,
                            pccolect, pcactivi, pcgarant, vctipcon, vnvalcon, vcfracci,
                            vcbonifi, vcrecfra, w_climit,   -- Bug 10864.NMM.01/08/2009.
                            v_cmonimp,   -- BUG 18423 - LCOL000 - Multimoneda
                            vcderreg);   -- Bug 0020314 - FAL - 29/11/2011

         IF vcfracci = 0 THEN   -- si no es impuesto fraccionado no lo calculamos
            xips := 0;
         ELSE
            IF vctipcon = 4
               AND verr = 0 THEN   -- Para impuesto sobre capital (no sobre prima)
               verr := pac_impuestos.f_calcula_impuestocapital(psseguro, pnmovimi, pnriesgo,
                                                               pmode, 'CIMPIPS', xicapital,
                                                               pcgarant);
            END IF;

            IF verr <> 0 THEN   -- Si da error la función.
               xips := 0;
            ELSE
               IF NVL(vcrecfra, 0) = 1 THEN
                  tot_recfrac := xirecfrac;
               ELSE
                  tot_recfrac := 0;
               END IF;

               verr :=
                  pac_impuestos.f_calcula_impconcepto
                         (vnvalcon, piprianu / pcforpag, piprianu, NULL, NULL, NULL, xicapital,
                          tot_recfrac, NULL, vctipcon, pcforpag, vcfracci, vcbonifi, vcrecfra,
                          xips,
                          -- JLB - I - BUG 18423 COjo la moneda del producto
                          NULL, NULL, NULL, vfefecto, psseguro, pnriesgo, pcgarant,
                          pac_monedas.f_moneda_producto(pac_productos.f_get_sproduc(pcramo,
                                                                                    pcmodali,
                                                                                    pctipseg,
                                                                                    pccolect))
                                                                                              -- JLB - F - BUG 18423 COjo la moneda del producto
                  );

               IF verr <> 0 THEN   -- Si da error la función.
                  xips := 0;
               END IF;

               xips := NVL(xips, 0);
            END IF;
         END IF;
      END IF;

      --- Calculamos DGS
      IF xcimpdgs > 0 THEN
         vctipcon := NULL;
         vnvalcon := NULL;
         vcfracci := NULL;
         vcbonifi := NULL;
         vcrecfra := NULL;
         verr := f_concepto(5, vcempres, f_sysdate, pcforpag, pcramo, pcmodali, pctipseg,
                            pccolect, pcactivi, pcgarant, vctipcon, vnvalcon, vcfracci,
                            vcbonifi, vcrecfra, w_climit,   -- Bug 10864.NMM.01/08/2009.
                            v_cmonimp,   -- BUG 18423 - LCOL000 - Multimoneda
                            vcderreg);   -- Bug 0020314 - FAL - 29/11/2011

         IF vcfracci = 0 THEN   -- si no es impuesto fraccionado no lo calculamos
            xdgs := 0;
         ELSE
            IF vctipcon = 4
               AND verr = 0 THEN   -- Para impuesto sobre capital (no sobre prima)
               verr := pac_impuestos.f_calcula_impuestocapital(psseguro, pnmovimi, pnriesgo,
                                                               pmode, 'CIMPDGS', xicapital,
                                                               pcgarant);
            END IF;

            IF verr <> 0 THEN   -- Si da error la función.
               xdgs := 0;
            ELSE
               IF NVL(vcrecfra, 0) = 1 THEN
                  tot_recfrac := xirecfrac;
               ELSE
                  tot_recfrac := 0;
               END IF;

               verr :=
                  pac_impuestos.f_calcula_impconcepto
                         (vnvalcon, piprianu / pcforpag, piprianu, NULL, NULL, NULL, xicapital,
                          tot_recfrac, NULL, vctipcon, pcforpag, vcfracci, vcbonifi, vcrecfra,
                          xdgs,
                          -- JLB - I - BUG 18423 COjo la moneda del producto
                          NULL, NULL, NULL, vfefecto, psseguro, pnriesgo, pcgarant,
                          pac_monedas.f_moneda_producto(pac_productos.f_get_sproduc(pcramo,
                                                                                    pcmodali,
                                                                                    pctipseg,
                                                                                    pccolect))
                                                                                              -- JLB - F - BUG 18423 COjo la moneda del producto
                  );

               IF verr <> 0 THEN   -- Si da error la función.
                  xdgs := 0;
               END IF;

               xdgs := NVL(xdgs, 0);
            END IF;
         END IF;
      END IF;

      -- Calculamos los arbitrios
      IF xcimparb > 0 THEN
         vctipcon := NULL;
         vnvalcon := NULL;
         vcfracci := NULL;
         vcbonifi := NULL;
         vcrecfra := NULL;
         verr := f_concepto(6, vcempres, f_sysdate, pcforpag, pcramo, pcmodali, pctipseg,
                            pccolect, pcactivi, pcgarant, vctipcon, vnvalcon, vcfracci,
                            vcbonifi, vcrecfra, w_climit,   -- Bug 10864.NMM.01/08/2009.
                            v_cmonimp,   -- BUG 18423 - LCOL000 - Multimoneda
                            vcderreg);   -- Bug 0020314 - FAL - 29/11/2011

         IF vcfracci = 0 THEN   -- si no es impuesto fraccionado no lo calculamos
            xarb := 0;
         ELSE
            IF vctipcon = 4
               AND verr = 0 THEN   -- Para impuesto sobre capital (no sobre prima)
               verr := pac_impuestos.f_calcula_impuestocapital(psseguro, pnmovimi, pnriesgo,
                                                               pmode, 'CIMPARB', xicapital,
                                                               pcgarant);
            END IF;

            IF verr <> 0 THEN   -- Si da error la función.
               xarb := 0;
            ELSE
               IF NVL(vcrecfra, 0) = 1 THEN
                  tot_recfrac := xirecfrac;
               ELSE
                  tot_recfrac := 0;
               END IF;

               verr :=
                  pac_impuestos.f_calcula_impconcepto
                         (vnvalcon, piprianu / pcforpag, piprianu, NULL, NULL, NULL, xicapital,
                          tot_recfrac, NULL, vctipcon, pcforpag, vcfracci, vcbonifi, vcrecfra,
                          xarb,
                          -- JLB - I - BUG 18423 COjo la moneda del producto
                          NULL, NULL, NULL, vfefecto, psseguro, pnriesgo, pcgarant,
                          pac_monedas.f_moneda_producto(pac_productos.f_get_sproduc(pcramo,
                                                                                    pcmodali,
                                                                                    pctipseg,
                                                                                    pccolect))
                                                                                              -- JLB - F - BUG 18423 COjo la moneda del producto
                  );

               IF verr <> 0 THEN   -- Si da error la función.
                  xarb := 0;
               END IF;

               xarb := NVL(xarb, 0);
            END IF;
         END IF;
      END IF;

      --- Calculamos el FNG
      IF xcimpfng > 0 THEN
         vctipcon := NULL;
         vnvalcon := NULL;
         vcfracci := NULL;
         vcbonifi := NULL;
         vcrecfra := NULL;
         verr := f_concepto(7, vcempres, f_sysdate, pcforpag, pcramo, pcmodali, pctipseg,
                            pccolect, pcactivi, pcgarant, vctipcon, vnvalcon, vcfracci,
                            vcbonifi, vcrecfra, w_climit,   -- Bug 10864.NMM.01/08/2009.
                            v_cmonimp,   -- BUG 18423 - LCOL000 - Multimoneda
                            vcderreg);   -- Bug 0020314 - FAL - 29/11/2011

         IF vcfracci = 0 THEN   -- si no es impuesto fraccionado no lo calculamos
            xfng := 0;
         ELSE
            IF vctipcon = 4
               AND verr = 0 THEN   -- Para impuesto sobre capital (no sobre prima)
               verr := pac_impuestos.f_calcula_impuestocapital(psseguro, pnmovimi, pnriesgo,
                                                               pmode, 'CIMPFNG', xicapital,
                                                               pcgarant);
            END IF;

            IF verr <> 0 THEN   -- Si da error la función.
               xfng := 0;
            ELSE
               IF NVL(vcrecfra, 0) = 1 THEN
                  tot_recfrac := xirecfrac;
               ELSE
                  tot_recfrac := 0;
               END IF;

               verr :=
                  pac_impuestos.f_calcula_impconcepto
                         (vnvalcon, piprianu / pcforpag, piprianu, NULL, NULL, NULL, xicapital,
                          tot_recfrac, NULL, vctipcon, pcforpag, vcfracci, vcbonifi, vcrecfra,
                          xfng,
                          -- JLB - I - BUG 18423 COjo la moneda del producto
                          NULL, NULL, NULL, vfefecto, psseguro, pnriesgo, pcgarant,
                          pac_monedas.f_moneda_producto(pac_productos.f_get_sproduc(pcramo,
                                                                                    pcmodali,
                                                                                    pctipseg,
                                                                                    pccolect))
                                                                                              -- JLB - F - BUG 18423 COjo la moneda del producto
                  );

               IF verr <> 0 THEN   -- Si da error la función.
                  xfng := 0;
               END IF;

               xfng := NVL(xfng, 0);
            END IF;
         END IF;
      END IF;

      RETURN xips + xdgs + xarb + xfng;
   END f_calcula_impuestos;
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
BEGIN
   BEGIN
      IF ptablas = 'EST' THEN
         SELECT cramo, cmodali, ctipseg, ccolect,
                pac_seguros.ff_get_actividad(sseguro, pnriesgo, 'EST'), crecfra,
                DECODE(NVL(pcforpag, cforpag), 0, 1, NVL(pcforpag, cforpag))
           INTO v_cramo, v_cmodali, v_ctipseg, v_ccolect,
                v_cactivi, v_crecfrac,
                v_cforpag
           FROM estseguros
          WHERE sseguro = psseguro;

         BEGIN
            SELECT MAX(e.finiefe)
              INTO vfefecto
              FROM estgaranseg e
             WHERE e.sseguro = psseguro
               AND e.nriesgo = NVL(pnriesgo, e.nriesgo)
               AND e.nmovimi = (SELECT MAX(e1.nmovimi)
                                  FROM estgaranseg e1
                                 WHERE e1.sseguro = e.sseguro
                                   AND e1.nriesgo = e.nriesgo);
         EXCEPTION
            WHEN OTHERS THEN
               vfefecto := f_sysdate;
         END;
      ELSIF ptablas = 'SOL' THEN
         SELECT s.cramo, s.cmodali, s.ctipseg, s.ccolect,
                pac_seguros.ff_get_actividad(sseguro, pnriesgo, 'SOL'), p.crecfra,
                DECODE(NVL(pcforpag, s.cforpag), 0, 1, NVL(pcforpag, cforpag)), falta
           INTO v_cramo, v_cmodali, v_ctipseg, v_ccolect,
                v_cactivi, v_crecfrac,
                v_cforpag, vfefecto
           FROM solseguros s, productos p
          WHERE ssolicit = psseguro
            AND p.sproduc = s.sproduc;
      ELSE
         SELECT cramo, cmodali, ctipseg, ccolect,
                pac_seguros.ff_get_actividad(sseguro, pnriesgo), crecfra,
                DECODE(NVL(pcforpag, cforpag), 0, 1, NVL(pcforpag, cforpag))
           INTO v_cramo, v_cmodali, v_ctipseg, v_ccolect,
                v_cactivi, v_crecfrac,
                v_cforpag
           FROM seguros
          WHERE sseguro = psseguro;

         BEGIN
            SELECT MAX(m.fefecto)
              INTO vfefecto
              FROM movseguro m
             WHERE m.sseguro = psseguro
               AND m.nmovimi = (SELECT MAX(m1.nmovimi)
                                  FROM movseguro m1
                                 WHERE m1.sseguro = m.sseguro);
         EXCEPTION
            WHEN OTHERS THEN
               vfefecto := f_sysdate;
         END;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         --    error := 1 ;
         RETURN 0;
   END;

   vfefecto := NVL(pfefecto, vfefecto);

   IF pcmodo = 3 THEN   -- a nivel de garantía
      IF v_crecfrac = 1 THEN
         xprecarg := f_calcula_recargo_fracc(v_cramo, v_cmodali, v_ctipseg, v_ccolect,
                                             v_cactivi, pcgarant, v_cforpag, piprianu,
                                             psseguro, pnriesgo);
      ELSE
         xprecarg := 0;
      END IF;

      IF pctipo = 2 THEN
         ximpuestos := f_calcula_impuestos(v_cramo, v_cmodali, v_ctipseg, v_ccolect,
                                           v_cactivi, pcgarant, v_cforpag, piprianu,
                                           v_crecfrac, psseguro, pnmovimi, pnriesgo, pcmodo);
      END IF;

--      xipriforpag :=
--         f_round(piprianu / v_cforpag
--                                     -- JLB - I - BUG 18423 COjo la moneda del producto
--                 ,
--                 pac_monedas.f_moneda_producto(pac_productos.f_get_sproduc(v_cramo, v_cmodali,
--                                                                           v_ctipseg,
--                                                                           v_ccolect))
--                                                                                      -- JLB - F - BUG 18423 COjo la moneda del producto
--         );
      xipriforpag :=
         f_round(piprianu *((30 * vtramo(-1, 291, v_cforpag)) / 360),
                 pac_monedas.f_moneda_producto(pac_productos.f_get_sproduc(v_cramo, v_cmodali,
                                                                           v_ctipseg,
                                                                           v_ccolect)));
   ELSIF pcmodo IN(2, 1) THEN   -- A NIVEL DE RIESGO O POLIZA
      IF pcmodo = 1 THEN
         xnriesgo := NULL;
      ELSE
         xnriesgo := pnriesgo;
      END IF;

      xprecarg := 0;
      ximpuestos := 0;
      xipriforpag := 0;

      IF ptablas = 'EST' THEN
         FOR c IN cur_garantias_est(psseguro, xnriesgo, pnmovimi) LOOP
            xprecarg_1 := 0;
            ximpuestos_1 := 0;
            xipriforpag_1 :=
               f_round(c.iprianu / v_cforpag,

                       -- JLB - I - BUG 18423 COjo la moneda del producto
                       pac_monedas.f_moneda_producto(pac_productos.f_get_sproduc(v_cramo,
                                                                                 v_cmodali,
                                                                                 v_ctipseg,
                                                                                 v_ccolect))
                                                                                            -- JLB - F - BUG 18423 COjo la moneda del producto
               );

            IF v_crecfrac = 1 THEN
               xprecarg_1 := f_calcula_recargo_fracc(v_cramo, v_cmodali, v_ctipseg, v_ccolect,
                                                     v_cactivi, c.cgarant, v_cforpag,
                                                     c.iprianu, psseguro, c.nriesgo);
            ELSE
               xprecarg_1 := 0;
            END IF;

            IF pctipo = 2 THEN
               ximpuestos_1 := f_calcula_impuestos(v_cramo, v_cmodali, v_ctipseg, v_ccolect,
                                                   v_cactivi, c.cgarant, v_cforpag, c.iprianu,
                                                   v_crecfrac, psseguro, pnmovimi, pnriesgo,
                                                   pcmodo);
            END IF;

            xipriforpag := xipriforpag + xipriforpag_1;
            xprecarg := xprecarg + xprecarg_1;
            ximpuestos := ximpuestos + ximpuestos_1;
         END LOOP;
      ELSIF ptablas = 'SOL' THEN
         FOR c IN cur_garantias_sol(psseguro, xnriesgo) LOOP
            xprecarg_1 := 0;
            ximpuestos_1 := 0;
            xipriforpag_1 :=
               f_round(c.iprianu / v_cforpag,

                       -- JLB - I - BUG 18423 COjo la moneda del producto
                       pac_monedas.f_moneda_producto(pac_productos.f_get_sproduc(v_cramo,
                                                                                 v_cmodali,
                                                                                 v_ctipseg,
                                                                                 v_ccolect))
                                                                                            -- JLB - F - BUG 18423 COjo la moneda del producto
               );

            IF v_crecfrac = 1 THEN
               xprecarg_1 := f_calcula_recargo_fracc(v_cramo, v_cmodali, v_ctipseg, v_ccolect,
                                                     v_cactivi, c.cgarant, v_cforpag,
                                                     c.iprianu, psseguro, c.nriesgo);
            ELSE
               xprecarg_1 := 0;
            END IF;

            IF pctipo = 2 THEN
               ximpuestos_1 := f_calcula_impuestos(v_cramo, v_cmodali, v_ctipseg, v_ccolect,
                                                   v_cactivi, c.cgarant, v_cforpag, c.iprianu,
                                                   v_crecfrac, psseguro, pnmovimi, pnriesgo,
                                                   pcmodo);
            END IF;

            xipriforpag := xipriforpag + xipriforpag_1;
            xprecarg := xprecarg + xprecarg_1;
            ximpuestos := ximpuestos + ximpuestos_1;
         END LOOP;
      ELSE
         FOR c IN cur_garantias(psseguro, pnriesgo, pnmovimi) LOOP
            xprecarg_1 := 0;
            ximpuestos_1 := 0;
            xipriforpag_1 :=
               f_round(c.iprianu / v_cforpag,

                       -- JLB - I - BUG 18423 COjo la moneda del producto
                       pac_monedas.f_moneda_producto(pac_productos.f_get_sproduc(v_cramo,
                                                                                 v_cmodali,
                                                                                 v_ctipseg,
                                                                                 v_ccolect))
                                                                                            -- JLB - F - BUG 18423 COjo la moneda del producto
               );

            IF v_crecfrac = 1 THEN
               xprecarg_1 := f_calcula_recargo_fracc(v_cramo, v_cmodali, v_ctipseg, v_ccolect,
                                                     v_cactivi, c.cgarant, v_cforpag,
                                                     c.iprianu, psseguro, c.nriesgo);
            ELSE
               xprecarg_1 := 0;
            END IF;

            IF pctipo = 2 THEN
               ximpuestos_1 := f_calcula_impuestos(v_cramo, v_cmodali, v_ctipseg, v_ccolect,
                                                   v_cactivi, c.cgarant, v_cforpag, c.iprianu,
                                                   v_crecfrac, psseguro, pnmovimi, pnriesgo,
                                                   pcmodo);
            END IF;

            xipriforpag := xipriforpag + xipriforpag_1;
            xprecarg := xprecarg + xprecarg_1;
            ximpuestos := ximpuestos + ximpuestos_1;
         END LOOP;
      END IF;
   END IF;

   IF pctipo = 1 THEN   -- SOLO RECARGO POR FRACCIONAMIENTO
      RETURN xipriforpag + xprecarg;
   ELSIF pctipo = 2 THEN
      RETURN xipriforpag + xprecarg + ximpuestos;
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      p_tab_error(f_sysdate, f_user, 'F_Prima_Forpag', 1,
                  'ptablas=' || ptablas || ';pctipo=' || pctipo || ';pcmodo=' || pcmodo
                  || ';psseguro=' || psseguro || ';pnriesgo=' || pnriesgo || ';pcgarant='
                  || pcgarant || ';piprianu=' || piprianu || ';pnmovimi=' || pnmovimi,
                  SQLERRM);
      RETURN 0;
END f_prima_forpag;

/

  GRANT EXECUTE ON "AXIS"."F_PRIMA_FORPAG" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_PRIMA_FORPAG" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_PRIMA_FORPAG" TO "PROGRAMADORESCSI";
