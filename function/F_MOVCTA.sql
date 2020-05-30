--------------------------------------------------------
--  DDL for Function F_MOVCTA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_MOVCTA" (
   pnrecibo IN NUMBER,
   psmovrec IN NUMBER,
   pcodmov IN NUMBER,
   pcmovimi IN NUMBER,
   pfvalmov IN DATE,
   pfmovini IN DATE,
   pfmovdia IN DATE DEFAULT NULL,
   psseguro IN NUMBER DEFAULT NULL,
   pfefecrec IN DATE DEFAULT NULL,
   pctiprec IN NUMBER DEFAULT NULL,
   pcramo IN NUMBER DEFAULT NULL,
   pcmodali IN NUMBER DEFAULT NULL,
   pctipseg IN NUMBER DEFAULT NULL,
   pccolect IN NUMBER DEFAULT NULL,
   ppgasint IN NUMBER DEFAULT NULL,
   ppgasext IN NUMBER DEFAULT NULL,
   pcfeccob IN NUMBER DEFAULT NULL)
   RETURN NUMBER IS
   /***********************************************************************
           F_MOVCTA: Inserta o anula un registro en la cuenta de seguro del tipo
                           de aportaciones periódicas.
           Sección correspondiente al módulo cuentas de ahorro
           Canvia totalment els paràmetres, i realitza
           una alta o una anul.lació, segons el valor de pcmovim (1-Alta, 2-Anul.lació.
              S' afegeixen els paràmetres pcmovimi i pfvalmov,
           que són grabats directament, independentment de si estem en una alta o
           anul.lació.
           Se trunca el f_sysdate de fcontab
           Se le da a fcontab el valor de fefecto, en vez de pfmovimi
           Modificaciones para el tratamiento de los PJ. Para este
           producto se insertan o modifican 3 registros: uno de tipo aportación
           periódica y dos de tipo gastos.
           Cuando se anula un cobro se asigna al campo cmovanu de los tres registros
           el valor 1 y se crean otros tres registros con cmovanu = 0 e importe el
           mismo que tenía pero con signo negativo.
           -- Si el camp cfeccob de productos= 1, posem la data de
           -- efecte del cobrament (fmovini de movrecibo)
           -- La data fmovdia = f_sysdate, de totes maneres la passarem per parpàmetre
           -- i fmovini ve per paràmetre, per tant s'elimina les selects a movrecibo
           -- La select a productos, etc també es faran només si els paràmetres venen null;
              23-01-2007 JAS - En movimientos de aportación y rescates se realiza el cálculo de la provisión matemática
              insertando un registro de saldo (también se calculará el capital garantizado y capital de fallecimiento).
              También se elimina la particularidad del xramo = 33 and cmodali = 81.

   ******************************************************************************************************************************/
   xnnumlin       ctaseguro.nnumlin%TYPE;
   xnnumlinshw    ctaseguro_shadow.nnumlin%TYPE;
   xsseguro       recibos.sseguro%TYPE;
   xfefecto       recibos.fefecto%TYPE;
   xitotalr       pregunseg.crespue%TYPE;
   xnnumlinant    ctaseguro.nnumlin%TYPE;
   xnnumlinantshw ctaseguro_shadow.nnumlin%TYPE;
   xcmovanuant    ctaseguro.cmovanu%TYPE;
   xcmovanuantshw ctaseguro_shadow.cmovanu%TYPE;
   xfcontabant    ctaseguro.fcontab%TYPE;
   xfcontabantshw ctaseguro_shadow.fcontab%TYPE;
   ximovimiant    ctaseguro.imovimi%TYPE;
   ximovimiantshw ctaseguro_shadow.imovimi%TYPE;
   xctiprec       recibos.ctiprec%TYPE;
   xctipseg       seguros.ctipseg%TYPE;
   xccolect       seguros.ccolect%TYPE;
   xcramo         seguros.cramo%TYPE;
   xcmodali       seguros.cmodali%TYPE;
--   xicombru       NUMBER(15, 2);
   xiprinet       vdetrecibos.iprinet%TYPE;
   xiprinet2      vdetrecibos.iprinet%TYPE;
   xiprinet3      vdetrecibos.iprinet%TYPE;
   xpgasint       productos.pgasint%TYPE;
   xpgasext       productos.pgasext%TYPE;
   xcmovimi       ctaseguro.cmovimi%TYPE;
   xcmovimishw    ctaseguro_shadow.cmovimi%TYPE;
   nreg           NUMBER;
   num_err        NUMBER;
   xcfeccob       productos.cfeccob%TYPE;   -- Per saber la data de cobrament
   fvalor         ctaseguro.fvalmov%TYPE;   --> En PP guardamos la fecha valor del movimiento de aportación a anular
   fvalorshw      ctaseguro.fvalmov%TYPE;
   v_capital      garanseg.icapital%TYPE;
   v_sproduc      seguros.sproduc%TYPE;
   seqgrupo       ctaseguro.ccalint%TYPE;
   v_cagrpro      seguros.cagrpro%TYPE;
   xcmovimipb     NUMBER;
   pnriesgo       recibos.nriesgo%TYPE;
   pnmovimi       recibos.nmovimi%TYPE;   --JRH 08/2008
   xapor_ant      trasplainout.iimptemp%TYPE;
   xapor_act      trasplainout.iimpanu%TYPE;
   xfantigi       trasplainout.fantigi%TYPE;
   vfvalmov       recibos.fefecto%TYPE;
   -- Bug 9424 -- 20/03/2009 - RSC - Creación del producto PPJ Dinàmic
   exp_no_data_found EXCEPTION;
   -- Bug 19096 - RSC - 12/08/2011 - LCOL - Parametrización básica producto Vida Individual Pagos Permanentes
   v_agrupado     NUMBER;
   -- BUG 18423 - I - 27/12/2011 - JLB - LCOL000 - Multimoneda
   vmoneda        monedas.cmoneda%TYPE;
   -- BUG 18423 - F - 27/12/2011 - JLB - LCOL000 - Multimoneda
   v_tieneshw     NUMBER;
   -- Alberto - fectrasp de ctaseguro
   v_fectrasp     DATE;
   cuantos_trasplaaportaciones NUMBER;
   cuentalin      NUMBER;

   -- Fin Bug 19096
   CURSOR cur_anula_aport(seguro NUMBER, numlin NUMBER) IS
      SELECT   nnumlin, fcontab, imovimi, cmovanu, cmovimi
          FROM ctaseguro
         WHERE sseguro = seguro
           AND nnumlin < numlin
           AND cmovimi IN(1, 2, 4, 8, 45)
      ORDER BY nnumlin DESC, fcontab DESC;

   CURSOR cur_anula_aport_shw(seguro NUMBER, numlin NUMBER) IS
      SELECT   nnumlin, fcontab, imovimi, cmovanu, cmovimi
          FROM ctaseguro_shadow
         WHERE sseguro = seguro
           AND nnumlin < numlin
           AND cmovimi IN(1, 2, 4, 8, 45)
      ORDER BY nnumlin DESC, fcontab DESC;

   CURSOR cur_ctaseguro IS
      SELECT   nnumlin, fcontab, imovimi, cmovanu, cmovimi
          FROM ctaseguro
         WHERE nrecibo = pnrecibo
      ORDER BY nnumlin DESC, fcontab DESC;

   CURSOR cur_ctaseguro_shw IS
      SELECT   nnumlin, fcontab, imovimi, cmovanu, cmovimi
          FROM ctaseguro_shadow
         WHERE nrecibo = pnrecibo
      ORDER BY nnumlin DESC, fcontab DESC;

   FUNCTION insertar_ctaseguro(
      psseguro IN NUMBER,
      pfefecto IN DATE,
      pnnumlin IN NUMBER,
      pffecmov IN DATE,
      pffvalmov IN DATE,
      pcmovimi IN NUMBER,
      pimovimi IN NUMBER,
      pimovimi2 IN NUMBER,
      pnrecibo IN NUMBER,
      pccalint IN NUMBER,
      pcmovanu IN NUMBER,
      pnsinies IN NUMBER,
      psmovrec IN NUMBER,
      pcfeccob IN NUMBER,
      pfectrasp IN DATE DEFAULT NULL,
      pctipapor IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      --
      -- De moment, no té importancia el que vingui
      -- pel pfvalmov. En el camp de CTASEGURO, grabem la data efecte (xfefecto).
      --
      -- Modifiquem la forma d'insertar, fent que la data de contabilitzacio
      -- del moviment sigui la data de creacio del rebut, de forma que
      -- es contabilitzi correctament el cas d'un cobrament d'un rebut que ens
      -- arriba despres del seu "tancament"
      -- Si els imports són 0, tornem sense fer rès
      -- pcfeccob = 1, les dates son les fmovini
      aux_fmovdia    DATE;
      encontrado     NUMBER;
      lffecmov       trasplainout.fantigi%TYPE;
      lffvalmov      trasplainout.fantigi%TYPE;
      v_nmovimi      NUMBER;
      v_icapital     NUMBER;
   BEGIN
      -- Si els imports són 0, tornem sense fer rès
      IF NVL(pimovimi, 0) = 0
         AND NVL(pimovimi2, 0) = 0 THEN
         RETURN 0;
      END IF;

      lffecmov := pffecmov;
      lffvalmov := pffvalmov;

      IF pcmovimi IN(8, 47, 56)   --JRH Tarea 6966
                               THEN
         aux_fmovdia := NVL(pfmovdia, f_sysdate);
      ELSE
         IF pcfeccob IS NULL THEN
            aux_fmovdia := NVL(pfmovdia, f_sysdate);
         ELSIF pcfeccob = 0 THEN
            aux_fmovdia := NVL(pfmovdia, f_sysdate);
            lffecmov := TRUNC(f_sysdate);
            lffvalmov := TRUNC(f_sysdate);
         ELSE   -- NP cal posar les dates de movrecibo
            lffecmov := pfmovini;
            aux_fmovdia := NVL(pfmovdia, f_sysdate);
            lffvalmov := lffecmov;
         END IF;
      END IF;

      num_err := pac_ctaseguro.f_insctaseguro(psseguro, aux_fmovdia, pnnumlin, lffecmov,
                                              lffvalmov, pcmovimi, pimovimi, pimovimi2,
                                              pnrecibo, pccalint, pcmovanu, pnsinies, psmovrec,
                                              NULL, 'R', NULL, NULL, NULL, NULL, NULL, NULL,
                                              NULL, NULL, NULL, pfectrasp, pctipapor);

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      --
      IF (NVL(pac_parametros.f_parproducto_n(v_sproduc, 'AHORRO_PREPAGABLE'), 0) = 1) THEN
         num_err := pac_ctaseguro.f_ins_desglose_aho(psseguro, aux_fmovdia, pcmovimi,
                                                     pccalint, 'R', v_cagrpro, v_sproduc,
                                                     NULL, NULL, NULL, pnrecibo, pnsinies);

         IF num_err <> 0 THEN
            RETURN num_err;
         END IF;
      END IF;

      SAVEPOINT importe_aportacion;   --JRH Tarea 6966

      -- Quan estem tractant una aportació periòdica o extraordiària
      -- actualitzem la provisió matemàtica de l'assegurança. También en el caso de
      -- anulación de aportación (51)
      --IF pcmovimi IN (1,2,51) AND NVL(F_PARPRODUCTOS_V(v_sproduc,'SALDO_AE'),0) = 1 THEN
      IF pcmovimi IN(1, 2, 8, 47, 51)
         AND NVL(f_parproductos_v(v_sproduc, 'SALDO_AE'), 0) = 1 THEN
         -- num_err := Pac_Ctaseguro.F_inscta_prov_cap (psseguro, lffvalmov,'R',NULL);
         -- num_err := Pac_Ctaseguro.F_inscta_prov_cap (psseguro, TRUNC(lffvalmov),'R',NULL);
         --num_err := Pac_Ctaseguro.F_inscta_prov_cap (psseguro, TRUNC(f_sysdate),'R',NULL);
         --IF num_err <> 0 THEN
           --RETURN num_err;
         --END IF;

         --JRH  Tarea 6966 Comentamos lo de arriba
         num_err := pac_ctaseguro.f_inscta_prov_cap(psseguro, TRUNC(lffvalmov), 'R', NULL,
                                                    TRUNC(lffecmov));

         IF num_err <> 0 THEN
            -- Desacemos lo que ha hecho pac_ctaseguro.f_inscta_prov_cap
            ROLLBACK TO importe_aportacion;
            RETURN 0;
         END IF;

         --JRH  Tarea 6966 Comentamos lo de arriba
         num_err := pac_ctaseguro.f_recalcular_lineas_saldo(psseguro, TRUNC(lffvalmov) + 1);

         IF num_err <> 0 THEN
            -- Desacemos lo que ha hecho pac_ctaseguro.f_inscta_prov_cap
            ROLLBACK TO importe_aportacion;
            RETURN 0;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         RETURN 104879;   -- Registre duplicat a CTASEGURO
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'f_movcta', 1,
                     'Error incontrolado al insertar en CTASEGURO-CTASEGURO_LIBRETA', SQLERRM);
         RETURN 102555;   -- Error al insertar a la taula CTASEGURO
   END;

   FUNCTION insertar_ctaseguro_shw(
      psseguro IN NUMBER,
      pfefecto IN DATE,
      pnnumlin IN NUMBER,
      pffecmov IN DATE,
      pffvalmov IN DATE,
      pcmovimi IN NUMBER,
      pimovimi IN NUMBER,
      pimovimi2 IN NUMBER,
      pnrecibo IN NUMBER,
      pccalint IN NUMBER,
      pcmovanu IN NUMBER,
      pnsinies IN NUMBER,
      psmovrec IN NUMBER,
      pcfeccob IN NUMBER,
      pfectrasp IN DATE DEFAULT NULL,
      pctipapor IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      --
      -- De moment, no té importancia el que vingui
      -- pel pfvalmov. En el camp de CTASEGURO, grabem la data efecte (xfefecto).
      --
      -- Modifiquem la forma d'insertar, fent que la data de contabilitzacio
      -- del moviment sigui la data de creacio del rebut, de forma que
      -- es contabilitzi correctament el cas d'un cobrament d'un rebut que ens
      -- arriba despres del seu "tancament"
      -- Si els imports són 0, tornem sense fer rès
      -- pcfeccob = 1, les dates son les fmovini
      aux_fmovdia    DATE;
      encontrado     NUMBER;
      lffecmov       trasplainout.fantigi%TYPE;
      lffvalmov      trasplainout.fantigi%TYPE;
      v_nmovimi      NUMBER;
      v_icapital     NUMBER;
   BEGIN
      -- Si els imports són 0, tornem sense fer rès
      IF NVL(pimovimi, 0) = 0
         AND NVL(pimovimi2, 0) = 0 THEN
         RETURN 0;
      END IF;

      lffecmov := pffecmov;
      lffvalmov := pffvalmov;

      IF pcmovimi IN(8, 47, 56)   --JRH Tarea 6966
                               THEN
         aux_fmovdia := NVL(pfmovdia, f_sysdate);
      ELSE
         IF pcfeccob IS NULL THEN
            aux_fmovdia := NVL(pfmovdia, f_sysdate);
         ELSIF pcfeccob = 0 THEN
            aux_fmovdia := NVL(pfmovdia, f_sysdate);
            lffecmov := TRUNC(f_sysdate);
            lffvalmov := TRUNC(f_sysdate);
         ELSE   -- NP cal posar les dates de movrecibo
            lffecmov := pfmovini;
            aux_fmovdia := NVL(pfmovdia, f_sysdate);
            lffvalmov := lffecmov;
         END IF;
      END IF;

      num_err := pac_ctaseguro.f_insctaseguro_shw(psseguro, aux_fmovdia, pnnumlin, lffecmov,
                                                  lffvalmov, pcmovimi, pimovimi, pimovimi2,
                                                  pnrecibo, pccalint, pcmovanu, pnsinies,
                                                  psmovrec, NULL, 'R', NULL, NULL, NULL, NULL,
                                                  NULL, NULL, NULL, NULL, NULL, pfectrasp,
                                                  pctipapor);

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      --
      IF (NVL(pac_parametros.f_parproducto_n(v_sproduc, 'AHORRO_PREPAGABLE'), 0) = 1) THEN
         num_err := pac_ctaseguro.f_ins_desglose_aho_shw(psseguro, aux_fmovdia, pcmovimi,
                                                         pccalint, 'R', v_cagrpro, v_sproduc,
                                                         NULL, NULL, NULL, pnrecibo, pnsinies);

         IF num_err <> 0 THEN
            RETURN num_err;
         END IF;
      END IF;

      SAVEPOINT importe_aportacion_shadow;   --JRH Tarea 6966

      -- Quan estem tractant una aportació periòdica o extraordiària
      -- actualitzem la provisió matemàtica de l'assegurança. También en el caso de
      -- anulación de aportación (51)
      --IF pcmovimi IN (1,2,51) AND NVL(F_PARPRODUCTOS_V(v_sproduc,'SALDO_AE'),0) = 1 THEN
      IF pcmovimi IN(1, 2, 8, 47, 51)
         AND NVL(f_parproductos_v(v_sproduc, 'SALDO_AE'), 0) = 1 THEN
         -- num_err := Pac_Ctaseguro.F_inscta_prov_cap (psseguro, lffvalmov,'R',NULL);
         -- num_err := Pac_Ctaseguro.F_inscta_prov_cap (psseguro, TRUNC(lffvalmov),'R',NULL);
         --num_err := Pac_Ctaseguro.F_inscta_prov_cap (psseguro, TRUNC(f_sysdate),'R',NULL);
         --IF num_err <> 0 THEN
           --RETURN num_err;
         --END IF;

         --JRH  Tarea 6966 Comentamos lo de arriba
         num_err := pac_ctaseguro.f_inscta_prov_cap_shw(psseguro, TRUNC(lffvalmov), 'R', NULL,
                                                        TRUNC(lffecmov));

         IF num_err <> 0 THEN
            -- Desacemos lo que ha hecho pac_ctaseguro.f_inscta_prov_cap
            ROLLBACK TO importe_aportacion_shadow;
            RETURN 0;
         END IF;

         --JRH  Tarea 6966 Comentamos lo de arriba
         num_err := pac_ctaseguro.f_recalcular_lineas_saldo_shw(psseguro, TRUNC(lffvalmov) + 1);

         IF num_err <> 0 THEN
            -- Desacemos lo que ha hecho pac_ctaseguro.f_inscta_prov_cap
            ROLLBACK TO importe_aportacion_shadow;
            RETURN 0;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         RETURN 104879;   -- Registre duplicat a CTASEGURO
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'f_movcta', 1,
                     'Error incontrolado al insertar en CTASEGURO-CTASEGURO_LIBRETA_SHADOW',
                     SQLERRM);
         RETURN 102555;   -- Error al insertar a la taula CTASEGURO
   END;

   FUNCTION update_ctaseguro(psseguro IN NUMBER, pfcontab IN DATE, pnnumlin IN NUMBER)
      RETURN NUMBER IS
      v_error        axis_literales.slitera%TYPE;
   BEGIN
      UPDATE ctaseguro
         SET cmovanu = 1,
             imovim2 = NULL,
             imovim2_monpol = NULL   -- BUG 18423 - 14/12/2011 - JMP - Multimoneda
       WHERE sseguro = psseguro
         AND fcontab = pfcontab
         AND nnumlin = pnnumlin;   --JRH  Tarea 6966  Esto esta mal es pfcontab ?

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         CLOSE cur_ctaseguro;

         IF cur_ctaseguro_shw%ISOPEN THEN
            CLOSE cur_ctaseguro_shw;
         END IF;

         RETURN 102537;   -- Error al modificar la taula CTASEGURO
   END;

   FUNCTION update_ctaseguro_shw(psseguro IN NUMBER, pfcontab IN DATE, pnnumlin IN NUMBER)
      RETURN NUMBER IS
      v_error        axis_literales.slitera%TYPE;
   BEGIN
      UPDATE ctaseguro_shadow
         SET cmovanu = 1,
             imovim2 = NULL,
             imovim2_monpol = NULL   -- BUG 18423 - 14/12/2011 - JMP - Multimoneda
       WHERE sseguro = psseguro
         AND fcontab = pfcontab
         AND nnumlin = pnnumlin;   --JRH  Tarea 6966  Esto esta mal es pfcontab ?

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         CLOSE cur_ctaseguro;

         IF cur_ctaseguro_shw%ISOPEN THEN
            CLOSE cur_ctaseguro_shw;
         END IF;

         RETURN 102537;   -- Error al modificar la taula CTASEGURO
   END;
BEGIN
   IF psseguro IS NULL
      OR pfefecrec IS NULL
      OR pctiprec IS NULL
      OR pcramo IS NULL
      OR pcmodali IS NULL
      OR pctipseg IS NULL
      OR pccolect IS NULL THEN
      BEGIN
         SELECT r.sseguro, r.fefecto, r.ctiprec, s.cramo, s.cmodali, s.ctipseg, s.ccolect,
                r.nriesgo, r.nmovimi
           INTO xsseguro, xfefecto, xctiprec, xcramo, xcmodali, xctipseg, xccolect,
                pnriesgo, pnmovimi
           FROM recibos r, seguros s
          WHERE nrecibo = pnrecibo
            AND r.sseguro = s.sseguro;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN 101902;   -- Rebut no trobat a la taula RECIBOS
         WHEN OTHERS THEN
            RETURN 102367;   -- Error al llegir dades de RECIBOS
      END;

      pnriesgo := NVL(pnriesgo, 1);
   ELSE
      xsseguro := psseguro;
      xfefecto := pfefecrec;
      xctiprec := pctiprec;
      xcramo := pcramo;
      xcmodali := pcmodali;
      xctipseg := pctipseg;
      xccolect := pccolect;
      pnriesgo := 1;   --JRH 08/2008 Pondremos el 1
      pnmovimi := 1;   --JRH 08/2008 Pondremos el 1
   END IF;

   -- Obtebemos la sequence para la agrupación para marcar en el unit linked las
   -- líneas de un mismo movimiento
   BEGIN
      SELECT sproduc, cagrpro
        INTO v_sproduc, v_cagrpro
        FROM seguros
       WHERE sseguro = xsseguro;
   END;

   IF v_cagrpro IN(11, 21) THEN   -- 12442.NMM.31/12/2009.
      SELECT scagrcta.NEXTVAL
        INTO seqgrupo
        FROM DUAL;
   ELSE
      seqgrupo := 0;
   END IF;

   v_tieneshw := NVL(pac_ctaseguro.f_tiene_ctashadow(xsseguro, NULL), 0);

   BEGIN
      SELECT MAX(nnumlin)
        INTO xnnumlin
        FROM ctaseguro
       WHERE sseguro = xsseguro;

      IF v_tieneshw = 1 THEN
         SELECT MAX(nnumlin)
           INTO xnnumlinshw
           FROM ctaseguro_shadow
          WHERE sseguro = xsseguro;
      END IF;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN 103066;   -- Assegurança no trobada a la taula CTASEGURO
      WHEN OTHERS THEN
         RETURN 104882;   -- Error al llegir de CTASEGURO
   END;

   IF pcodmov = 1 THEN   -- Insertar
      num_err := f_sproduc(xcramo, xcmodali, xctipseg, xccolect, v_sproduc);

      IF num_err <> 0 THEN
         RETURN(num_err);
      END IF;

      -- Si se trata de un producto mixto (Ibex 35 + EUROPLAZO)
      -- Entonces obtenemos el valor de prima a EUROPLAZO de la pregunta automatica 1012
      IF NVL(f_parproductos_v(v_sproduc, 'PRODUCTO_MIXTO'), 0) = 1 THEN
         BEGIN
            SELECT NVL(crespue, 0)
              INTO xitotalr
              FROM pregunseg
             WHERE sseguro = xsseguro
               AND cpregun = 1012;   -- 1012 = Respuest del calculo del importe de capital a aplicar a la parte de EUROPLAZO
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 112002;   --xsseguro
         END;

         xiprinet := 0;
      ELSE
         -- Bug 19096 - RSC - 12/08/2011 - LCOL - Parametrización básica producto Vida Individual Pagos Permanentes
         IF pnrecibo IS NOT NULL THEN
            -- INI RLLF 1702014 Control generación ctaseguro en los recibos hijo.
            IF NVL(f_parproductos_v(v_sproduc, 'CTASEGURO_RECHIJOS'), 0) != 1 THEN
               SELECT COUNT(*)
                 INTO v_agrupado
                 FROM adm_recunif
                WHERE nrecunif = pnrecibo;   -- Si es el recibo agrupador no debe hacer el apunte

               IF v_agrupado > 0 THEN
                  RETURN 0;   -- Si está agrupado no apuntaremos nada en CTASEGURO
               END IF;
            END IF;
         -- FIN RLLF 1702014 Control generación ctaseguro en los recibos hijo.
         END IF;

         -- Fin Bug 19096

         -- Bug 9424 -- 20/03/2009 - RSC - Creación del producto PPJ Dinàmic
         IF NVL(f_parproductos_v(v_sproduc, 'DETRECIBO_CONCEPTOS'), 0) = 0 THEN
            BEGIN
               SELECT NVL(itotalr, 0), NVL(iprinet, 0)
                 INTO xitotalr, xiprinet
                 FROM vdetrecibos
                WHERE nrecibo = pnrecibo;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  RETURN 101731;   -- Rebut no trobat a VDETRECIBOS
               WHEN OTHERS THEN
                  RETURN 103920;   -- Error al llegir de VDETRECIBOS
            END;
         ELSE
            -- Bug 9424 -- 20/03/2009 - RSC - Creación del producto PPJ Dinàmic
            BEGIN
               SELECT NVL(SUM(DECODE(d.cconcep, 13, -1 * d.iconcep, d.iconcep)), 0)
                 INTO xitotalr
                 FROM detrecibos d, recibos r, seguros s
                WHERE d.nrecibo = pnrecibo
                  AND d.nrecibo = r.nrecibo
                  AND r.sseguro = s.sseguro
                  AND d.cconcep IN(0, 1, 2, 3, 4, 5, 6, 7, 8, 14, 13)
                  AND NVL(f_pargaranpro_v(s.cramo, s.cmodali, s.ctipseg, s.ccolect,
                                          pac_seguros.ff_get_actividad(s.sseguro, d.nriesgo),
                                          d.cgarant, 'TIPO'),
                          0) = 4;

               IF xitotalr = 0 THEN
                  RAISE exp_no_data_found;
               END IF;
            EXCEPTION
               WHEN exp_no_data_found THEN
                  SELECT NVL(SUM(DECODE(d.cconcep, 13, -1 * d.iconcep, d.iconcep)), 0)
                    INTO xitotalr
                    FROM detrecibos d, recibos r, seguros s
                   WHERE d.nrecibo = pnrecibo
                     AND d.nrecibo = r.nrecibo
                     AND r.sseguro = s.sseguro
                     AND d.cconcep IN(0, 1, 2, 3, 4, 5, 6, 7, 8, 14, 13)
                     AND NVL(f_pargaranpro_v(s.cramo, s.cmodali, s.ctipseg, s.ccolect,
                                             pac_seguros.ff_get_actividad(s.sseguro, d.nriesgo),
                                             d.cgarant, 'TIPO'),
                             0) = 3;
            END;
         END IF;
      END IF;

      -- Si els paràmetres estan informats no es fa la select
      IF ppgasint IS NULL
         OR ppgasext IS NULL
         OR pcfeccob IS NULL THEN
         BEGIN
            SELECT pgasint, pgasext, cfeccob
              INTO xpgasint, xpgasext, xcfeccob
              FROM productos
             WHERE cramo = xcramo
               AND cmodali = xcmodali
               AND ctipseg = xctipseg
               AND ccolect = xccolect;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               RETURN 104347;
            WHEN OTHERS THEN
               RETURN 102705;
         END;
      ELSE
         xpgasint := ppgasint;
         xpgasext := ppgasext;
         xcfeccob := pcfeccob;
      END IF;

      xiprinet3 := f_round(xiprinet * xpgasint / 100,
                           -- BUG 18423 - I - 27/12/2011 - JLB - LCOL000 - Multimoneda
                              --2
                           pac_monedas.f_moneda_producto(v_sproduc)
                                                                   -- BUG 18423 - F - 27/12/2011 - JLB - LCOL000 - Multimoneda
                  );
      xiprinet2 := f_round(xiprinet * xpgasext / 100,
-- BUG 18423 - I - 27/12/2011 - JLB - LCOL000 - Multimoneda
     --2
                           pac_monedas.f_moneda_producto(v_sproduc)
                                                                   -- BUG 18423 - F - 27/12/2011 - JLB - LCOL000 - Multimoneda
                  );

      IF xctiprec = 9 THEN   -- Es un extorn
         xitotalr :=(0 - xitotalr);
         xcmovimi := 51;
         xcmovimipb := 19;
      ELSIF xctiprec = 10 THEN   -- Es un traspaso --JGM Cpina actualiza para traspasos
         -- CPM 2/1/06: Introducimos los datos en ctaseguro
         BEGIN   -- Buscamos los datos del traspaso
            SELECT fvalor, iimptemp, iimpanu, fantigi
              INTO xfefecto, xapor_ant, xapor_act, xfantigi
              FROM trasplainout
             WHERE sseguro = xsseguro
               AND cestado = 3   -- traspaso pdte. informar
               AND TRUNC(fsolici) = TRUNC(pfvalmov);

            -- Insertamos las aportaciones de años anteriores
            IF xapor_ant IS NOT NULL THEN
               num_err := insertar_ctaseguro(xsseguro, xfantigi, NVL(xnnumlin + 1, 1),
                                             xfantigi, xfantigi, 56, xapor_ant, NULL,
                                             pnrecibo, seqgrupo, 0, NULL, psmovrec, xcfeccob);

               IF num_err <> 0 THEN
                  RETURN num_err;
               END IF;

               xnnumlin := NVL(xnnumlin, 1) + 1;   -- Ya hemos insertado el traspaso

               IF v_tieneshw = 1 THEN
                  num_err := insertar_ctaseguro_shw(xsseguro, xfantigi,
                                                    NVL(xnnumlinshw + 1, 1), xfantigi,
                                                    xfantigi, 56, xapor_ant, NULL, pnrecibo,
                                                    seqgrupo, 0, NULL, psmovrec, xcfeccob);

                  IF num_err <> 0 THEN
                     RETURN num_err;
                  END IF;

                  xnnumlinshw := NVL(xnnumlinshw, 1) + 1;   -- Ya hemos insertado el traspaso
               END IF;
            END IF;

            -- Insertamos las aportaciones de este año
            IF xapor_act IS NOT NULL THEN
               num_err := insertar_ctaseguro(xsseguro, xfefecto, NVL(xnnumlin + 1, 1),
                                             xfefecto, xfefecto, 56, xapor_act, NULL,
                                             pnrecibo, seqgrupo, 0, NULL, psmovrec, xcfeccob);

               IF num_err <> 0 THEN
                  RETURN num_err;
               END IF;

               xnnumlin := xnnumlin + 1;   -- Ya hemos insertado el traspaso

               IF v_tieneshw = 1 THEN
                  num_err := insertar_ctaseguro_shw(xsseguro, xfefecto,
                                                    NVL(xnnumlinshw + 1, 1), xfefecto,
                                                    xfefecto, 56, xapor_act, NULL, pnrecibo,
                                                    seqgrupo, 0, NULL, psmovrec, xcfeccob);

                  IF num_err <> 0 THEN
                     RETURN num_err;
                  END IF;

                  xnnumlinshw := xnnumlinshw + 1;   -- Ya hemos insertado el traspaso
               END IF;
            END IF;

            -- Actualizamos la tabla de traspasos
            UPDATE trasplainout
               SET nnumlin = xnnumlin + 1,
                   cestado = 4   -- Confirmado
             WHERE sseguro = xsseguro
               AND cestado = 3   -- traspaso pdte. informar
               AND TRUNC(fsolici) = TRUNC(pfvalmov);
         EXCEPTION
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, 'f_movcta', 1, 'Datos del traspaso', SQLERRM);
         END;

         xcmovimi := pcmovimi;   --JGM Cpina actualiza para traspasos
         xcmovimipb := 9;   --JGM Cpina actualiza para traspasos
      ELSE
         xcmovimi := pcmovimi;
         xcmovimipb := 9;
      END IF;

      IF pcmovimi = 8 THEN
         vfvalmov := xfefecto;
      ELSE
         vfvalmov := NVL(pfvalmov, xfefecto);
      END IF;

      IF xctiprec = 10 THEN
         SELECT COUNT(1)
           INTO cuantos_trasplaaportaciones
           FROM trasplaaportaciones
          WHERE stras IN(SELECT stras
                           FROM trasplainout
                          WHERE nrecibo = pnrecibo);
      END IF;

      -- Traspasos de entrda, grabamos trasplaaportaciones en ctaseguro
      IF xctiprec = 10
         AND NVL(cuantos_trasplaaportaciones, 0) > 0 THEN   --JRH En principio , si no hay detalle hacemos el insert del recibo por el total. Habrái que hacer pantalla de trasplaaportaciones.
         cuentalin := 0;

         FOR reg IN (SELECT     ROWID, DECODE(cprocedencia, 2, 'PR', NULL) proce, ROWNUM,
                                importe_ant, importe_post, faporta
                           FROM trasplaaportaciones
                          WHERE stras IN(SELECT stras
                                           FROM trasplainout
                                          WHERE nrecibo = pnrecibo)
                     FOR UPDATE) LOOP
            IF reg.importe_ant > 0 THEN
               v_fectrasp := TO_DATE('31/12/2006', 'dd/mm/yyyy');
            ELSE
               v_fectrasp := reg.faporta;
            END IF;

            IF reg.importe_ant > 0 THEN
               cuentalin := cuentalin + 1;
               num_err := insertar_ctaseguro(xsseguro, xfefecto,
                                             NVL(xnnumlin + cuentalin, cuentalin), xfefecto,

                                             --NVL(pfvalmov,xfefecto), --JRH Tarea 6966
                                             vfvalmov, xcmovimi, reg.importe_ant, NULL,
                                             pnrecibo, seqgrupo, 0, NULL, psmovrec, xcfeccob,
                                             v_fectrasp, reg.proce);

               IF num_err <> 0 THEN
                  RETURN num_err;
               END IF;

               -- ALBERT - Modificar TRASPLAAPORTACIONES con el nnumlin de la aportación insertada
               UPDATE trasplaaportaciones
                  SET nnumlin_ant = NVL(xnnumlin + cuentalin, cuentalin)
                WHERE ROWID = reg.ROWID;

               IF v_tieneshw = 1 THEN
                  num_err := insertar_ctaseguro_shw(xsseguro, xfefecto,
                                                    NVL(xnnumlinshw + cuentalin, cuentalin),
                                                    xfefecto,
                                                    --NVL(pfvalmov,xfefecto), --JRH Tarea 6966
                                                    vfvalmov, xcmovimi, reg.importe_ant, NULL,
                                                    pnrecibo, seqgrupo, 0, NULL, psmovrec,
                                                    xcfeccob, v_fectrasp, reg.proce);

                  IF num_err <> 0 THEN
                     RETURN num_err;
                  END IF;
               END IF;
            END IF;

            IF reg.importe_post > 0 THEN
               cuentalin := cuentalin + 1;
               num_err := insertar_ctaseguro(xsseguro, xfefecto,
                                             NVL(xnnumlin + cuentalin, cuentalin), xfefecto,

                                             --NVL(pfvalmov,xfefecto), --JRH Tarea 6966
                                             vfvalmov, xcmovimi, reg.importe_post, NULL,
                                             pnrecibo, seqgrupo, 0, NULL, psmovrec, xcfeccob,
                                             reg.faporta, reg.proce);

               IF num_err <> 0 THEN
                  RETURN num_err;
               END IF;

               -- ALBERT - Modificar TRASPLAAPORTACIONES con el nnumlin de la aportación insertada
               UPDATE trasplaaportaciones
                  SET nnumlin_post = NVL(xnnumlin + cuentalin, cuentalin)
                WHERE ROWID = reg.ROWID;

               IF v_tieneshw = 1 THEN
                  num_err := insertar_ctaseguro_shw(xsseguro, xfefecto,
                                                    NVL(xnnumlinshw + cuentalin, cuentalin),
                                                    xfefecto,
                                                    --NVL(pfvalmov,xfefecto), --JRH Tarea 6966
                                                    vfvalmov, xcmovimi, reg.importe_post,
                                                    NULL, pnrecibo, seqgrupo, 0, NULL,
                                                    psmovrec, xcfeccob, reg.faporta,
                                                    reg.proce);

                  IF num_err <> 0 THEN
                     RETURN num_err;
                  END IF;
               END IF;
            END IF;
         END LOOP;
      ELSE
         num_err := insertar_ctaseguro(xsseguro, xfefecto, NVL(xnnumlin + 1, 1), xfefecto,

                                       --NVL(pfvalmov,xfefecto), --JRH Tarea 6966
                                       vfvalmov, xcmovimi, xitotalr, NULL, pnrecibo, seqgrupo,
                                       0, NULL, psmovrec, xcfeccob);

         IF num_err <> 0 THEN
            RETURN num_err;
         END IF;

         IF v_tieneshw = 1 THEN
            num_err := insertar_ctaseguro_shw(xsseguro, xfefecto, NVL(xnnumlinshw + 1, 1),
                                              xfefecto,
                                              --NVL(pfvalmov,xfefecto), --JRH Tarea 6966
                                              vfvalmov, xcmovimi, xitotalr, NULL, pnrecibo,
                                              seqgrupo, 0, NULL, psmovrec, xcfeccob);

            IF num_err <> 0 THEN
               RETURN num_err;
            END IF;
         END IF;
      END IF;

      IF xctiprec = 0 THEN   --JRH 08/2008 Si estamos en nueva producción
         BEGIN
            SELECT NVL(icapital, 0)   --JRH Buscamos si hay algún importe asociado a Part. en Benef.
              INTO v_capital
              FROM garanseg g, seguros s
             WHERE g.sseguro = xsseguro
               AND s.sseguro = g.sseguro
               AND g.nriesgo = pnriesgo
               AND g.finiefe = xfefecto
               AND g.nmovimi = pnmovimi   --JRH Ahora con pnmovimi 1
               AND f_pargaranpro_v(s.cramo, s.cmodali, s.ctipseg, s.ccolect,
                                   pac_seguros.ff_get_actividad(xsseguro, pnriesgo), g.cgarant,
                                   'TIPO') = 12;   -- P Benef.
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               v_capital := 0;
            WHEN OTHERS THEN
               RETURN 105756;
         END;

         IF v_capital <> 0 THEN
            BEGIN
               SELECT MAX(nnumlin)
                 INTO xnnumlin
                 FROM ctaseguro
                WHERE sseguro = xsseguro;

               IF v_tieneshw = 1 THEN
                  SELECT MAX(nnumlin)
                    INTO xnnumlinshw
                    FROM ctaseguro_shadow
                   WHERE sseguro = xsseguro;
               END IF;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  RETURN 103066;   -- Assegurança no trobada a la taula CTASEGURO
               WHEN OTHERS THEN
                  RETURN 104882;   -- Error al llegir de CTASEGURO
            END;

            num_err := insertar_ctaseguro(xsseguro, xfefecto, NVL(xnnumlin + 1, 1), xfefecto,
                                          xfefecto, xcmovimipb, v_capital, NULL, pnrecibo,
                                          seqgrupo, 0, NULL, psmovrec, xcfeccob);

            IF num_err <> 0 THEN
               RETURN num_err;
            END IF;

            IF v_tieneshw = 1 THEN
               num_err := insertar_ctaseguro_shw(xsseguro, xfefecto, NVL(xnnumlinshw + 1, 1),
                                                 xfefecto, xfefecto, xcmovimipb, v_capital,
                                                 NULL, pnrecibo, seqgrupo, 0, NULL, psmovrec,
                                                 xcfeccob);

               IF num_err <> 0 THEN
                  RETURN num_err;
               END IF;
            END IF;
         END IF;
      END IF;   --Si estamos en nueva producción

      RETURN 0;
   ELSIF pcodmov = 2 THEN   -- Anul.lar
      num_err := f_sproduc(xcramo, xcmodali, xctipseg, xccolect, v_sproduc);

      IF num_err <> 0 THEN
         RETURN(num_err);
      END IF;

      -- Bug 19096 - RSC - 12/08/2011 - LCOL - Parametrización básica producto Vida Individual Pagos Permanentes
      IF pnrecibo IS NOT NULL THEN
         -- INI RLLF 1702014 Control generación ctaseguro en los recibos hijo.
         IF NVL(f_parproductos_v(v_sproduc, 'CTASEGURO_RECHIJOS'), 0) != 1 THEN
            SELECT COUNT(*)
              INTO v_agrupado
              FROM adm_recunif
             WHERE nrecibo = pnrecibo;

            IF v_agrupado > 0 THEN
               RETURN 0;   -- Si está agrupado no apuntaremos nada en CTASEGURO
            END IF;
         END IF;
      -- FIN RLLF 1702014 Control generación ctaseguro en los recibos hijo.
      END IF;

      -- Fin Bug 19096

      -- Al anular un extorno (generamos un nuevo movimiento de aportación que anula el extorno)
      -- La función PAC_CALC_COMU.f_prima_satisfecha hace el SUM de aportaciones no anuladas, por eso
      -- al anula un cobro de extorno (y potseriormente rehabilitar la póliza) no debemos tener en cuenta
      -- las aportaciones satisfechas anteriores al extorno.
      IF xctiprec = 9 THEN   -- Es un extorn
         FOR regs2 IN cur_anula_aport(xsseguro, xnnumlin) LOOP
            num_err := update_ctaseguro(xsseguro, regs2.fcontab, regs2.nnumlin);

            IF num_err <> 0 THEN
               RETURN num_err;
            END IF;
         END LOOP;

         IF v_tieneshw = 1 THEN
            FOR regs2 IN cur_anula_aport_shw(xsseguro, xnnumlinshw) LOOP
               num_err := update_ctaseguro(xsseguro, regs2.fcontab, regs2.nnumlin);

               IF num_err <> 0 THEN
                  RETURN num_err;
               END IF;
            END LOOP;
         END IF;
      END IF;

      OPEN cur_ctaseguro;

      FETCH cur_ctaseguro
       INTO xnnumlinant, xfcontabant, ximovimiant, xcmovanuant, xcmovimi;

      IF cur_ctaseguro%FOUND THEN
         IF v_tieneshw = 1 THEN
            OPEN cur_ctaseguro_shw;

            FETCH cur_ctaseguro_shw
             INTO xnnumlinantshw, xfcontabantshw, ximovimiantshw, xcmovanuantshw, xcmovimishw;
         END IF;

         IF xcmovanuant = 0 THEN
            num_err := update_ctaseguro(xsseguro, xfcontabant, xnnumlinant);

            IF num_err <> 0 THEN
               CLOSE cur_ctaseguro;

               IF cur_ctaseguro_shw%ISOPEN THEN
                  CLOSE cur_ctaseguro_shw;
               END IF;

               RETURN num_err;
            END IF;

            IF v_tieneshw = 1 THEN
               num_err := update_ctaseguro_shw(xsseguro, xfcontabantshw, xnnumlinantshw);

               IF num_err <> 0 THEN
                  CLOSE cur_ctaseguro;

                  IF cur_ctaseguro_shw%ISOPEN THEN
                     CLOSE cur_ctaseguro_shw;
                  END IF;

                  RETURN num_err;
               END IF;
            END IF;

            IF ppgasint IS NULL
               OR ppgasext IS NULL
               OR pcfeccob IS NULL THEN
               BEGIN
                  SELECT pgasint, pgasext, cfeccob
                    INTO xpgasint, xpgasext, xcfeccob
                    FROM productos
                   WHERE cramo = xcramo
                     AND cmodali = xcmodali
                     AND ctipseg = xctipseg
                     AND ccolect = xccolect;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     RETURN 104347;
                  WHEN OTHERS THEN
                     RETURN 102705;
               END;
            ELSE
               xpgasint := ppgasint;
               xpgasext := ppgasext;
               xcfeccob := pcfeccob;
            END IF;

            -- Si el recibo es de planes de pensiones O AHORRO tenemos que anular el movimiento de Ctaseguro
            -- poniendo el movimiento cmovimi = 51
            IF xcmovimi = 9 THEN   --Si anulamos un a PB es un 19
               xcmovimi := 19;
            ELSE
               IF xctiprec = 9 THEN   -- Es un extorn
                  -- (esta casuistica se ha puesto para poner el mismo código de movimiento
                  -- que inicialmente (anulación de extorno), es decir aportación única (cmovimi = 2)
                  IF (NVL(f_parproductos_v(v_sproduc, 'PRODUCTO_MIXTO'), 0) = 1) THEN
                     xcmovimi := pcmovimi;
                  ELSE
                     xcmovimi := 1;
                  END IF;

                  xcmovimipb := 19;
               ELSE
                  xcmovimi := 51;
                  xcmovimipb := 19;
               END IF;
            END IF;

            fvalor := NULL;

            DECLARE
               grupo          seguros.cagrpro%TYPE;
            BEGIN
               SELECT cagrpro
                 INTO grupo
                 FROM seguros
                WHERE seguros.sseguro = xsseguro;

               IF grupo = 11 THEN
                  xcmovimi := 51;
                  xcfeccob := NULL;
                  xfefecto := TO_DATE(TO_CHAR(xfefecto, 'ddmmyyyy') || '23:58',
                                      'ddmmyyyyhh24:mi');

                  BEGIN
                     SELECT fvalmov
                       INTO fvalor
                       FROM ctaseguro
                      WHERE sseguro = xsseguro
                        AND nnumlin = xnnumlinant;
                  EXCEPTION
                     WHEN OTHERS THEN
                        NULL;
                  END;

                  IF v_tieneshw = 1 THEN
                     BEGIN
                        SELECT fvalmov
                          INTO fvalorshw
                          FROM ctaseguro_shadow
                         WHERE sseguro = xsseguro
                           AND nnumlin = xnnumlinantshw;
                     EXCEPTION
                        WHEN OTHERS THEN
                           NULL;
                     END;
                  END IF;
               ELSIF grupo IN(2, 10, 21) THEN   -- RSC 02/06/2008
                  --xcmovimi := 51; RSC 11/07/2008 No podia ser 51, si se anula un extorno (por tanto cmovimi = 1)
                  xcfeccob := NULL;
                  xfefecto := TRUNC(f_sysdate);

                  BEGIN
                     SELECT fvalmov
                       INTO fvalor
                       FROM ctaseguro
                      WHERE sseguro = xsseguro
                        AND nnumlin = xnnumlinant;
                  EXCEPTION
                     WHEN OTHERS THEN
                        NULL;
                  END;

                  IF v_tieneshw = 1 THEN
                     BEGIN
                        SELECT fvalmov
                          INTO fvalorshw
                          FROM ctaseguro_shadow
                         WHERE sseguro = xsseguro
                           AND nnumlin = xnnumlinantshw;
                     EXCEPTION
                        WHEN OTHERS THEN
                           NULL;
                     END;
                  END IF;
               END IF;
            EXCEPTION
               WHEN OTHERS THEN
                  NULL;
            END;

            num_err := insertar_ctaseguro(xsseguro, xfefecto, NVL(xnnumlin + 1, 1), xfefecto,
                                          NVL(fvalor, xfefecto), xcmovimi,
                                          NVL(0 - ximovimiant, 0), NVL(0 - ximovimiant, 0),
                                          pnrecibo, seqgrupo, 0, NULL, psmovrec, xcfeccob);

            IF num_err <> 0 THEN
               CLOSE cur_ctaseguro;

               IF cur_ctaseguro_shw%ISOPEN THEN
                  CLOSE cur_ctaseguro_shw;
               END IF;

               RETURN num_err;
            END IF;

            IF v_tieneshw = 1 THEN
               num_err := insertar_ctaseguro_shw(xsseguro, xfefecto, NVL(xnnumlinshw + 1, 1),
                                                 xfefecto, NVL(fvalorshw, xfefecto), xcmovimi,
                                                 NVL(0 - ximovimiantshw, 0),
                                                 NVL(0 - ximovimiantshw, 0), pnrecibo,
                                                 seqgrupo, 0, NULL, psmovrec, xcfeccob);

               IF num_err <> 0 THEN
                  CLOSE cur_ctaseguro;

                  IF cur_ctaseguro_shw%ISOPEN THEN
                     CLOSE cur_ctaseguro_shw;
                  END IF;

                  RETURN num_err;
               END IF;
            END IF;

            CLOSE cur_ctaseguro;

            IF cur_ctaseguro_shw%ISOPEN THEN
               CLOSE cur_ctaseguro_shw;
            END IF;

            RETURN 0;
         ELSIF xcmovanuant = 1 THEN
            CLOSE cur_ctaseguro;

            IF cur_ctaseguro_shw%ISOPEN THEN
               CLOSE cur_ctaseguro_shw;
            END IF;

            RETURN 102581;   -- Aquest moviment ja està anul.lat
         ELSE
            CLOSE cur_ctaseguro;

            IF cur_ctaseguro_shw%ISOPEN THEN
               CLOSE cur_ctaseguro_shw;
            END IF;

            RETURN 104881;   -- Valor incorrecte d' un camp de la BD
         END IF;
      ELSE
         CLOSE cur_ctaseguro;

         IF cur_ctaseguro_shw%ISOPEN THEN
            CLOSE cur_ctaseguro_shw;
         END IF;

         RETURN 103071;   -- Rebut no trobat a la taula CTASEGURO
      END IF;
   ELSE
      RETURN 101901;   -- Pas de paràmetres incorrectes a la funció
   END IF;
-- BUG 21546_108724 - 07/02/2012 - JLTS - Cierre de posibles cursores abiertos, se adiciona EXCEPTION
EXCEPTION
   WHEN OTHERS THEN
      IF cur_ctaseguro%ISOPEN THEN
         CLOSE cur_ctaseguro;
      END IF;

      IF cur_ctaseguro_shw%ISOPEN THEN
         CLOSE cur_ctaseguro_shw;
      END IF;

      RETURN 140999;
END;

/

  GRANT EXECUTE ON "AXIS"."F_MOVCTA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_MOVCTA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_MOVCTA" TO "PROGRAMADORESCSI";
