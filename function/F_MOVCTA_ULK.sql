--------------------------------------------------------
--  DDL for Function F_MOVCTA_ULK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_MOVCTA_ULK" (
   pnrecibo IN NUMBER,
   psmovrec IN NUMBER,
   pcodmov IN NUMBER,
   pcmovimi IN NUMBER,
   pfvalmov IN DATE,
   pfmovini IN DATE,
   pfmovdia IN DATE DEFAULT NULL,
   pcfeccob IN NUMBER DEFAULT NULL)
   RETURN NUMBER IS
   /******************************************************************************
   NOMBRE: F_MOVCTA_ULK
   PROPÓSITO:
   REVISIONES:

   Ver Fecha Autor Descripción
   --------- ---------- -------- ------------------------------------
   1.0 - - 1. Creación de función
   2.0 07/04/2009 RSC 2. Análisis adaptación productos indexados
   3.0 15/12/2009 NMM 3. 12274: CRE - ajuste de la fecha valor en redistribución (cambio de perfil).
   4.0 23/11/2010 ICV 4. 0016701: CRE - Impagament de rebuts
   5.0 14/03/2011 APD 5. 0015707: ENSA102 - Valors liquidatius - Estat actual
   6.0 09/06/2011 JMF 6. 0018767: ENSA102 - Cálculo de comisiones de suscripcción en Contribución definida
   7.0 24/10/2011 MDS 7. 0019291: ENSA102-Comisión Reguladora, recibos 11 y 12
   8.0 14/12/2011 JMP 8. 0018423: LCOL705 - Multimoneda
   ******************************************************************************/

   -- Bug 0018767 - JMF - 09/06/2011
   v_pgasto       comisionprod.pcomisi%TYPE;
   v_pretenc      retenciones.pretenc%TYPE;
   v_cmovimi_compensa ctaseguro.cmovimi%TYPE;
   v_cmovimi_detalle ctaseguro.cmovimi%TYPE;
   v_signo        NUMBER;
   v_icombru      vdetrecibos.icombru%TYPE;
   v_ccomi        ctaseguro.imovimi%TYPE;
   /***********************************************************************
           F_MOVCTA_ULK: Inserta o anula registros en la tabla ctaseguro
   Función especial para Unit Linked.
   - Sección correspondiente al módulo cuentas de ahorro
   Solo se generan apuntes de prima de riesgo y gastos fijos
   en nueva produccion (xctiprec = 0)
             Para movimientos de anulación se duplican los registros
             del recibo con importes negativos o cambiando compras por ventas
             Para CS, los movimientos de gastos, primas de riesgo se imputan
             a una cesta. Calculo de gastos sobre saldo.
     ***********************************************************************/
   nerror         NUMBER;
   xnnumlin       NUMBER;
   xnnumlinshw    NUMBER;
   xsseguro       NUMBER;
   xfefecto       DATE;
   xitotalr       NUMBER;
   xnnumlinant    NUMBER;
   xnnumlinantshw NUMBER;
   xcmovanuant    NUMBER;
   xcmovanuantshw NUMBER;
   xfcontabant    DATE;
   xfcontabantshw DATE;
   ximovimiant    NUMBER;
   ximovimiantshw NUMBER;
   xcmovimi       NUMBER;
   xcmovimishw    NUMBER;
   xccalint       NUMBER;
   xccalintshw    NUMBER;
   xctiprec       NUMBER;
   --Variables Unit Linked
   xcramo         NUMBER;
   xcmodali       NUMBER;
   xctipseg       NUMBER;
   xccolect       NUMBER;
   xidistrib      NUMBER;
   diascar        NUMBER;
   v_nrecibo_aux  NUMBER;
   -- Bug 9424 -- 20/03/2009 - RSC - Creación del producto PPJ Dinàmic
   v_cagrpro      NUMBER;
   v_ctipapor     NUMBER;
   v_sperapor     NUMBER;
   v_ctipaux      VARCHAR2(20);
   v_spermin      NUMBER;
   exp_no_data_found EXCEPTION;
   -- Alberto - fectrasp de ctaseguro
   v_fectrasp     DATE;
   cuantos_trasplaaportaciones NUMBER;
   cuentalin      NUMBER;

   CURSOR cur_anula_aport(seguro NUMBER, numlin NUMBER) IS
      SELECT   nnumlin, fcontab, imovimi, cmovanu, cmovimi
          FROM ctaseguro
         WHERE sseguro = seguro
           AND nnumlin < numlin
           AND smovrec <> psmovrec
           AND cmovimi IN(1, 2, 4, 8, 45)
      ORDER BY nnumlin DESC, fcontab DESC;

   CURSOR cur_anula_aport_shw(seguro NUMBER, numlin NUMBER) IS
      SELECT   nnumlin, fcontab, imovimi, cmovanu, cmovimi
          FROM ctaseguro_shadow
         WHERE sseguro = seguro
           AND nnumlin < numlin
           AND smovrec <> psmovrec
           AND cmovimi IN(1, 2, 4, 8, 45)
      ORDER BY nnumlin DESC, fcontab DESC;

   CURSOR cur_ctaseguro IS
      SELECT   nnumlin, fcontab, imovimi, cmovanu, cmovimi
          FROM ctaseguro
         WHERE nrecibo = pnrecibo
           AND smovrec <> psmovrec
      ORDER BY nnumlin DESC, fcontab DESC;

   CURSOR cur_ctaseguro_shw IS
      SELECT   nnumlin, fcontab, imovimi, cmovanu, cmovimi
          FROM ctaseguro_shadow
         WHERE nrecibo = pnrecibo
           AND smovrec <> psmovrec
      ORDER BY nnumlin DESC, fcontab DESC;

   -- Optimizacion posible forzar a utilizar el indice : M1CTASEG
   CURSOR cur_ctaseguro_general IS
      SELECT   c.nnumlin, c.fcontab, c.imovimi, c.cmovanu, c.cmovimi, c.ccalint
          FROM ctaseguro c
         WHERE c.nrecibo = pnrecibo
           AND c.cesta IS NULL
           AND 1 <= (SELECT COUNT(*)
                       FROM ctaseguro c2
                      WHERE c2.nrecibo = pnrecibo
                        AND c2.ccalint = c.ccalint
                        AND c2.cmovimi IN(45, 58))
      ORDER BY nnumlin DESC, fcontab DESC;

   CURSOR cur_ctaseguro_general_shw IS
      SELECT   c.nnumlin, c.fcontab, c.imovimi, c.cmovanu, c.cmovimi, c.ccalint
          FROM ctaseguro_shadow c
         WHERE c.nrecibo = pnrecibo
           AND c.cesta IS NULL
           AND 1 <= (SELECT COUNT(*)
                       FROM ctaseguro_shadow c2
                      WHERE c2.nrecibo = pnrecibo
                        AND c2.ccalint = c.ccalint
                        AND c2.cmovimi IN(45, 58))
      ORDER BY nnumlin DESC, fcontab DESC;

   --    Cursor sobre la distribución del modelo de inversión asociado a la póliza.
   -- Bug 21654 - RSC - 12/03/2012 - CRE - PPJ dinàmic:Error en suplement automàtic de canvi de perfil
   -- Añadimos pvvalorf
   CURSOR cur_segdisin2(seguro NUMBER, pvvalorf IN DATE) IS
      SELECT sseguro, ccesta, pdistrec, pdistuni, pdistext
        FROM segdisin2
       WHERE sseguro = seguro
         AND((pvvalorf BETWEEN finicio AND ffin)
             OR(pvvalorf >= finicio
                AND ffin IS NULL))
         AND nmovimi = (SELECT MAX(nmovimi)
                          FROM segdisin2
                         WHERE sseguro = seguro
                           AND((pvvalorf BETWEEN finicio AND ffin)
                               OR(pvvalorf >= finicio
                                  AND ffin IS NULL))
                           AND ffin IS NULL);

   CURSOR cur_segdisin2_act(seguro NUMBER) IS
      SELECT sseguro, ccesta, pdistrec, pdistuni, pdistext
        FROM segdisin2
       WHERE sseguro = seguro
         AND nmovimi = (SELECT MAX(nmovimi)
                          FROM segdisin2
                         WHERE sseguro = seguro
                           AND ffin IS NULL)
         AND ffin IS NULL;

   estado         VARCHAR2(1);   -- estado de los fondos asociados a una cesta dada
   hi_has         NUMBER := 0;   -- indica si existen fondos en estado semicerrado
   hi_hac         NUMBER := 0;   -- indica si existen fondos en estado cerrado
---------------------------------------------------------------------

   -- Siguiendo a F_MOVCTA
   xcfeccob       NUMBER;
--------------------------------------
   num_err        NUMBER;
   xfvalor        DATE;   --> En PP guardamos la fecha valor del movimiento de aportación a anular
   xfvalorshw     DATE;
   v_entra        NUMBER := 0;
   seqgrupo       NUMBER;
   v_sproduc      NUMBER;
   vdistcomp      NUMBER;
   vpnlinanu      NUMBER;
   vdummy1        DATE;
   vdummy2        NUMBER;
   vdummy3        NUMBER;
   vdummy4        NUMBER;
   vr_ffecmov     DATE;
   vr_ffecmovshw  DATE;
   vr_fvalmov     DATE;
   vr_fvalmovshw  DATE;
   vr_nnumlin     NUMBER;
   vr_nnumlinshw  NUMBER;
   vr_cmovimi     NUMBER;
   vr_cmovimishw  NUMBER;
   viuniact       NUMBER;
   vacumpercent   NUMBER := 0;
   vimport        NUMBER := 0;
   vacumrounded   NUMBER := 0;
   -- JRH Tarea 6966
   vvalorf        DATE;
   vcontabf       DATE;
   -- Bug 19096 - RSC - 12/08/2011 - LCOL - Parametrización básica producto Vida Individual Pagos Permanentes
   v_agrupado     NUMBER;
   v_cempres      seguros.cempres%TYPE;
   v_cmultimon    parempresas.nvalpar%TYPE;
   v_tieneshw     NUMBER;

   -- Fin Bug 19096
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
      lffecmov OUT DATE,
      lffvalmov OUT DATE,
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
      --lffecmov      DATE;
      --lffvalmov     DATE;
      v_nmovimi      NUMBER;
      v_icapital     NUMBER;
      v_sproduc      NUMBER;
      -- Bug 019291 - 24/10/2011 - MDS - ENSA102-Comisión Reguladora
      -- declaración de variable v_ctiprec
      v_ctiprec      NUMBER;
   BEGIN
      -- Bug 019291 - 24/10/2011 - MDS - ENSA102-Comisión Reguladora
      -- obtener ctiprec del recibo
      BEGIN
         SELECT ctiprec
           INTO v_ctiprec
           FROM recibos
          WHERE nrecibo = pnrecibo;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN 101902;   -- Rebut no trobat a la taula RECIBOS
         WHEN OTHERS THEN
            RETURN 102367;   -- Error al llegir dades de RECIBOS
      END;

      -- Bug 019291 - 24/10/2011 - MDS - ENSA102-Comisión Reguladora
      -- no comprobar nada para el caso de recibos 11 y 12
      IF v_ctiprec NOT IN(11, 12) THEN
         -- Si els imports són 0, tornem sense fer rès
         IF NVL(pimovimi, 0) = 0
            AND NVL(pimovimi2, 0) = 0 THEN
            RETURN 0;
         END IF;
      END IF;

      lffecmov := pffecmov;
      lffvalmov := pffvalmov;

      IF pcfeccob IS NULL THEN
         aux_fmovdia := NVL(pfmovdia, TRUNC(f_sysdate));
      ELSIF pcfeccob = 0 THEN
         aux_fmovdia := NVL(pfmovdia, TRUNC(f_sysdate));
         lffecmov := TRUNC(f_sysdate);
         lffvalmov := TRUNC(f_sysdate);
      ELSE   -- Cal posar les dates de movrecibo
         lffecmov := pfmovini;
         aux_fmovdia := NVL(pfmovdia, TRUNC(f_sysdate));
         lffvalmov := lffecmov;
      END IF;

      num_err := pac_ctaseguro.f_insctaseguro(psseguro, aux_fmovdia, pnnumlin, lffecmov,
                                              lffvalmov, pcmovimi, pimovimi, pimovimi2,
                                              pnrecibo, pccalint, pcmovanu, pnsinies, psmovrec,
                                              NULL, 'R', NULL, NULL, NULL, NULL);

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      -- Quan estem tractant una aportació periòdica o extraordinària
      -- actualitzem la provisió matemàtica de l'assegurança. También en el caso de
      -- anulación de aportación (51)

      -- (Para los productos ULK no ponemos linea de Saldo para cada aportación)
      -- Para el caso de Ibex 35 Garantizado, para la parte de EUROPLAZO ya se encargará la función
      -- F_MOVCTA
      /*
        IF pcmovimi IN (1,2,51) AND NVL(F_PARPRODUCTOS_V(v_sproduc,'SALDO_AE'),0) = 1 THEN
               num_err := Pac_Ctaseguro.F_inscta_prov_cap (psseguro, TRUNC(lffvalmov),'R',NULL);
               IF num_err <> 0 THEN
                      RETURN num_err;
              END IF;
        END IF;
      */
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
      lffecmov OUT DATE,
      lffvalmov OUT DATE,
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
      --lffecmov      DATE;
      --lffvalmov     DATE;
      v_nmovimi      NUMBER;
      v_icapital     NUMBER;
      v_sproduc      NUMBER;
      -- Bug 019291 - 24/10/2011 - MDS - ENSA102-Comisión Reguladora
      -- declaración de variable v_ctiprec
      v_ctiprec      NUMBER;
      v_numlin_shw   NUMBER;
   BEGIN
      -- Bug 019291 - 24/10/2011 - MDS - ENSA102-Comisión Reguladora
      -- obtener ctiprec del recibo
      BEGIN
         SELECT ctiprec
           INTO v_ctiprec
           FROM recibos
          WHERE nrecibo = pnrecibo;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN 101902;   -- Rebut no trobat a la taula RECIBOS
         WHEN OTHERS THEN
            RETURN 102367;   -- Error al llegir dades de RECIBOS
      END;

      -- Bug 019291 - 24/10/2011 - MDS - ENSA102-Comisión Reguladora
      -- no comprobar nada para el caso de recibos 11 y 12
      IF v_ctiprec NOT IN(11, 12) THEN
         -- Si els imports són 0, tornem sense fer rès
         IF NVL(pimovimi, 0) = 0
            AND NVL(pimovimi2, 0) = 0 THEN
            RETURN 0;
         END IF;
      END IF;

      lffecmov := pffecmov;
      lffvalmov := pffvalmov;

      IF pcfeccob IS NULL THEN
         aux_fmovdia := NVL(pfmovdia, TRUNC(f_sysdate));
      ELSIF pcfeccob = 0 THEN
         aux_fmovdia := NVL(pfmovdia, TRUNC(f_sysdate));
         lffecmov := TRUNC(f_sysdate);
         lffvalmov := TRUNC(f_sysdate);
      ELSE   -- Cal posar les dates de movrecibo
         lffecmov := pfmovini;
         aux_fmovdia := NVL(pfmovdia, TRUNC(f_sysdate));
         lffvalmov := lffecmov;
      END IF;

      num_err := pac_ctaseguro.f_insctaseguro_shw(psseguro, aux_fmovdia, pnnumlin, lffecmov,
                                                  lffvalmov, pcmovimi, pimovimi, pimovimi2,
                                                  pnrecibo, pccalint, pcmovanu, pnsinies,
                                                  psmovrec, NULL, 'R', NULL, NULL, NULL, NULL);

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      -- Quan estem tractant una aportació periòdica o extraordinària
      -- actualitzem la provisió matemàtica de l'assegurança. También en el caso de
      -- anulación de aportación (51)

      -- (Para los productos ULK no ponemos linea de Saldo para cada aportación)
      -- Para el caso de Ibex 35 Garantizado, para la parte de EUROPLAZO ya se encargará la función
      -- F_MOVCTA
      /*
        IF pcmovimi IN (1,2,51) AND NVL(F_PARPRODUCTOS_V(v_sproduc,'SALDO_AE'),0) = 1 THEN
               num_err := Pac_Ctaseguro.F_inscta_prov_cap_shw (psseguro, TRUNC(lffvalmov),'R',NULL);
               IF num_err <> 0 THEN
                      RETURN num_err;
              END IF;
        END IF;
      */
      RETURN 0;
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         RETURN 104879;   -- Registre duplicat a CTASEGURO
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'f_movcta', 11,
                     'Error incontrolado al insertar en CTASEGURO-CTASEGURO_LIBRETA_SHADOW',
                     SQLERRM);
         RETURN 102555;   -- Error al insertar a la taula CTASEGURO
   END;

   FUNCTION update_ctaseguro(psseguro IN NUMBER, pfcontab IN DATE, pnnumlin IN NUMBER)
      RETURN NUMBER IS
   BEGIN
      UPDATE ctaseguro
         SET cmovanu = 1,
             imovim2 = NULL,
             imovim2_monpol = NULL   -- BUG 18423 - 15/12/2011 - JMP - LCOL705 - Multimoneda
       WHERE sseguro = psseguro
         AND fcontab = pfcontab
         AND nnumlin = pnnumlin;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         CLOSE cur_ctaseguro;

         RETURN 102537;   -- Error al modificar la taula CTASEGURO
   END;

   FUNCTION update_ctaseguro_shw(psseguro IN NUMBER, pfcontab IN DATE, pnnumlin IN NUMBER)
      RETURN NUMBER IS
   BEGIN
      UPDATE ctaseguro_shadow
         SET cmovanu = 1,
             imovim2 = NULL,
             imovim2_monpol = NULL   -- BUG 18423 - 15/12/2011 - JMP - LCOL705 - Multimoneda
       WHERE sseguro = psseguro
         AND fcontab = pfcontab
         AND nnumlin = pnnumlin;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         CLOSE cur_ctaseguro;

         RETURN 102537;   -- Error al modificar la taula CTASEGURO
   END;

   -- alberto
   -- funcion de desglose de fondos para los traspasos
   FUNCTION desglose_fondos(pimporte IN NUMBER)
      RETURN NUMBER IS
   BEGIN
      BEGIN
         SELECT NVL(MAX(nnumlin) + 1, 1)
           INTO xnnumlin
           FROM ctaseguro
          WHERE sseguro = xsseguro;

         IF v_tieneshw = 1 THEN
            SELECT NVL(MAX(nnumlin) + 1, 1)
              INTO xnnumlinshw
              FROM ctaseguro_shadow
             WHERE sseguro = xsseguro;
         END IF;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            xnnumlin := 1;
            xnnumlinshw := 1;
         WHEN OTHERS THEN
            RETURN 104882;   -- Error al llegir de CTASEGURO
      END;

      FOR valor IN cur_segdisin2(xsseguro, vvalorf) LOOP
         --FOR valor IN cur_segdisin2_act(xsseguro) LOOP
         -- Fin bug 21654

         --Calcula les distribucions
         vacumpercent := vacumpercent + (pimporte * valor.pdistrec) / 100;
         xidistrib := ROUND(vacumpercent - vacumrounded, 2);
         vacumrounded := vacumrounded + ROUND(vacumpercent - vacumrounded, 2);
         --Calcula les distribucions
         --xidistrib := (xitotalr * valor.pdistrec) / 100;

         --Obtenemos el estado de la cesta (consultamos el estado en que están sus fondos a fecha de efecto)
         nerror := pac_val_finv.f_valida_estado_cesta(valor.ccesta, vvalorf, estado);

         IF estado = 'C' THEN
            hi_hac := hi_hac + 1;
         END IF;

         -- Bug 15707 - APD - 14/03/2011 - el Traspaso de entrada (CMOVIMI = 8) se debe tratar como si fuera una aportación
         IF (xcmovimi = 1
             OR xcmovimi = 2
             OR xcmovimi = 4
             OR xcmovimi = 8) THEN
            BEGIN
               --cuentalin := cuentalin + 1;

               -- Si disponemos del valor liquidativo pues ya lo ponemos, es decir
               -- ya podemos calcular aqui el numero de participaciones que le tocan
               SELECT NVL(iuniactcmp, iuniact)
                 INTO viuniact
                 FROM tabvalces
                WHERE ccesta = valor.ccesta
                  AND TRUNC(fvalor) = TRUNC(vvalorf)
                                      + pac_md_fondos.f_get_diasdep(valor.ccesta);   -- Bug 22268 - RSC - 15/05/2012 - LCOL_A001-Revision circuito domiciliaciones (TRUNC)

               --Inserta registres a cuenta seguro.
               BEGIN
                  INSERT INTO ctaseguro
                              (sseguro, fcontab, nnumlin, ffecmov,
                               fvalmov, cmovimi, imovimi, imovim2,
                               nrecibo, ccalint, cmovanu, nsinies, smovrec, cesta,
                               nunidad, cestado, fasign)
                       VALUES (xsseguro, vcontabf, xnnumlin, xfefecto,
                               TRUNC(vvalorf + diascar), v_cmovimi_detalle, xidistrib, NULL,
                               pnrecibo, seqgrupo, 0, NULL, psmovrec, valor.ccesta,
                               (xidistrib / viuniact) * v_signo, '2', TRUNC(xfefecto));

                  -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
                  IF v_cmultimon = 1 THEN
                     num_err := pac_oper_monedas.f_update_ctaseguro_monpol(xsseguro, vcontabf,
                                                                           xnnumlin,
                                                                           TRUNC(vvalorf
                                                                                 + diascar));

                     IF num_err <> 0 THEN
                        RETURN num_err;
                     END IF;
                  END IF;
               -- FIN BUG 18423 - 15/12/2011 - JMP - Multimoneda
               EXCEPTION
                  WHEN DUP_VAL_ON_INDEX THEN
                     RETURN 104879;   -- Registre duplicat a CTASEGURO
                  WHEN OTHERS THEN
                     RETURN 102555;   -- Error al insertar a la taula CTASEGURO
               END;

                -- Para la impresión de libreta (para que los movimientos generales también tenga actualizada
               -- la fecha de asignación. Actualizamos el movimiento general anterior
               UPDATE ctaseguro
                  SET cestado = '2',
                      fasign = TRUNC(f_sysdate)
                WHERE sseguro = xsseguro
                  AND cmovimi = xcmovimi
                  AND ccalint = seqgrupo
                  AND nnumlin < xnnumlin;

               IF v_tieneshw = 1 THEN
                  SELECT iuniactcmpshw
                    INTO viuniact
                    FROM tabvalces
                   WHERE ccesta = valor.ccesta
                     AND TRUNC(fvalor) = TRUNC(vvalorf)
                                         + pac_md_fondos.f_get_diasdep(valor.ccesta);

                  BEGIN
                     INSERT INTO ctaseguro_shadow
                                 (sseguro, fcontab, nnumlin, ffecmov,
                                  fvalmov, cmovimi, imovimi,
                                  imovim2, nrecibo, ccalint, cmovanu, nsinies, smovrec,
                                  cesta, nunidad, cestado,
                                  fasign)
                          VALUES (xsseguro, vcontabf, xnnumlinshw, xfefecto,
                                  TRUNC(vvalorf + diascar), v_cmovimi_detalle, xidistrib,
                                  NULL, pnrecibo, seqgrupo, 0, NULL, psmovrec,
                                  valor.ccesta, (xidistrib / viuniact) * v_signo, '2',
                                  TRUNC(xfefecto));

                     -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
                     IF v_cmultimon = 1 THEN
                        num_err :=
                           pac_oper_monedas.f_update_ctaseguro_shw_monpol(xsseguro, vcontabf,
                                                                          xnnumlinshw,
                                                                          TRUNC(vvalorf
                                                                                + diascar));

                        IF num_err <> 0 THEN
                           RETURN num_err;
                        END IF;
                     END IF;
                  -- FIN BUG 18423 - 15/12/2011 - JMP - Multimoneda
                  EXCEPTION
                     WHEN DUP_VAL_ON_INDEX THEN
                        RETURN 104879;   -- Registre duplicat a CTASEGURO
                     WHEN OTHERS THEN
                        RETURN 102555;   -- Error al insertar a la taula CTASEGURO
                  END;

                   -- Para la impresión de libreta (para que los movimientos generales también tenga actualizada
                  -- la fecha de asignación. Actualizamos el movimiento general anterior
                  UPDATE ctaseguro_shadow
                     SET cestado = '2',
                         fasign = TRUNC(f_sysdate)
                   WHERE sseguro = xsseguro
                     AND cmovimi = xcmovimi
                     AND ccalint = seqgrupo
                     AND nnumlin < xnnumlinshw;

                  xnnumlinshw := xnnumlinshw + 1;
               END IF;

               -- Incrementamos numero de linea (por movimiento 58)
               xnnumlin := xnnumlin + 1;

               --ACTUALIZAR CESTA --> Aumentamos/Descontamos las participaciones asignadas al fondo en contratos
               UPDATE fondos
                  SET fondos.nparasi = NVL(fondos.nparasi, 0) +(xidistrib / viuniact)
                WHERE fondos.ccodfon = valor.ccesta;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  --Inserta registres a cuenta seguro.
                  BEGIN
                     INSERT INTO ctaseguro
                                 (sseguro, fcontab, nnumlin, ffecmov,
                                  fvalmov, cmovimi, imovimi,
                                  imovim2, nrecibo, ccalint, cmovanu, nsinies, smovrec,
                                  cesta, cestado)
                          VALUES (xsseguro, vcontabf, xnnumlin, xfefecto,
                                  TRUNC(vvalorf + diascar), v_cmovimi_detalle, xidistrib,
                                  NULL, pnrecibo, seqgrupo, 0, NULL, psmovrec,
                                  valor.ccesta, '1');

                     -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
                     IF v_cmultimon = 1 THEN
                        num_err :=
                           pac_oper_monedas.f_update_ctaseguro_monpol(xsseguro, vcontabf,
                                                                      xnnumlin,
                                                                      TRUNC(vvalorf + diascar));

                        IF num_err <> 0 THEN
                           RETURN num_err;
                        END IF;
                     END IF;

                     IF v_tieneshw = 1 THEN
                        INSERT INTO ctaseguro_shadow
                                    (sseguro, fcontab, nnumlin, ffecmov,
                                     fvalmov, cmovimi, imovimi,
                                     imovim2, nrecibo, ccalint, cmovanu, nsinies, smovrec,
                                     cesta, cestado)
                             VALUES (xsseguro, vcontabf, xnnumlinshw, xfefecto,
                                     TRUNC(vvalorf + diascar), v_cmovimi_detalle, xidistrib,
                                     NULL, pnrecibo, seqgrupo, 0, NULL, psmovrec,
                                     valor.ccesta, '1');

                        -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
                        IF v_cmultimon = 1 THEN
                           num_err :=
                              pac_oper_monedas.f_update_ctaseguro_shw_monpol(xsseguro,
                                                                             vcontabf,
                                                                             xnnumlinshw,
                                                                             TRUNC(vvalorf
                                                                                   + diascar));

                           IF num_err <> 0 THEN
                              RETURN num_err;
                           END IF;
                        END IF;

                        xnnumlinshw := xnnumlinshw + 1;
                     END IF;

                     -- FIN BUG 18423 - 15/12/2011 - JMP - Multimoneda
                     xnnumlin := xnnumlin + 1;
                  EXCEPTION
                     WHEN DUP_VAL_ON_INDEX THEN
                        RETURN 104879;   -- Registre duplicat a CTASEGURO
                     WHEN OTHERS THEN
                        RETURN 102555;   -- Error al insertar a la taula CTASEGURO
                  END;
            END;
         END IF;
      END LOOP;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         CLOSE cur_ctaseguro;

         RETURN 102537;   -- Error al modificar la taula CTASEGURO
   END;
   -- END DESGLOSE FONDOS
-- ------------------------------------------------------------------
--     INICIO
-- ------------------------------------------------------------------
BEGIN
   BEGIN
      SELECT sseguro, fefecto, ctiprec
        INTO xsseguro, xfefecto, xctiprec
        FROM recibos
       WHERE nrecibo = pnrecibo;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN 101902;   -- Rebut no trobat a la taula RECIBOS
      WHEN OTHERS THEN
         RETURN 102367;   -- Error al llegir dades de RECIBOS
   END;

   v_tieneshw := NVL(pac_ctaseguro.f_tiene_ctashadow(xsseguro, NULL), 0);

   --Buscar el producte
   BEGIN
      SELECT cramo, cmodali, ctipseg, ccolect, cempres, sproduc, cagrpro
        INTO xcramo, xcmodali, xctipseg, xccolect, v_cempres, v_sproduc, v_cagrpro
        FROM seguros
       WHERE sseguro = xsseguro;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 101903;   -- Error al llegir de GARANSEG
   END;

   v_cmultimon := NVL(pac_parametros.f_parempresa_n(v_cempres, 'MULTIMONEDA'), 0);   -- BUG 18423 - 15/12/2011 - JMP - LCOL705 - Multimoneda

   -- Bug 10828 - RSC - 08/09/2009 - CRE - Revisión de los productos PPJ dinámico y Pla Estudiant (ajustes)
   -- Esta variable diascar no sirve para nada pero no lo vamos a tocar. Me explico:
   -- Inicialmente los movimiento 45 en CTASEGURO los graba con FVALMOV = FECHA + 2 (diascar) pese a que para el
   -- valor liquidativo se utiliza el de FECHA. Al final machaca la FVALMOV grabada (FECHA + 2) con el valor
   -- de FECHA. Por tanto, diascar es inutil, pero funciona y no vamos a tocar demasiado esta función.
   BEGIN
      SELECT NVL(ndiacar, 2)
        INTO diascar
        FROM productos_ulk
       WHERE cramo = xcramo
         AND cmodali = xcmodali
         AND ctipseg = xctipseg
         AND ccolect = xccolect;
   EXCEPTION
      WHEN OTHERS THEN
         diascar := 2;
   END;

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

   -- Bug 0018767 - JMF - 09/06/2011
   vvalorf := NVL(pfvalmov, xfefecto);

   -- INI RLLF 18022014 Cambio para que coja el valor del fondo a día de hoy si es una fecha de efecto a futuros.
   IF (NVL(pac_parametros.f_parproducto_n(v_sproduc, 'CTASEGURO_AFUTUROS'), 0) = 1) THEN
      IF (TRUNC(vvalorf) > TRUNC(f_sysdate)) THEN   -- Cambio solicitado para que en caso de cobrar un recibo con fche de efecto a futuros
         vvalorf := TRUNC(f_sysdate);   -- coja el valor del fondo a día de hoy y genere ctaseguro.
      END IF;
   END IF;

   -- FIN RLLF 18022014 Cambio para que coja el valor del fondo a día de hoy si es una fecha de efecto a futuros.

   --num_err := f_pcomisi(xsseguro, 1, vvalorf, v_pgasto, v_pretenc, NULL, NULL, NULL, NULL,
   --                     NULL, NULL, NULL, NULL);

   ------------------------------------------------------------------------------
   IF pcodmov = 1 THEN   -- Insertar
------------------------------------------------------------------------------
/* Se ha incorporado el campo en la select de SEGUROS del principio
      num_err := f_sproduc(xcramo, xcmodali, xctipseg, xccolect, v_sproduc);

      IF num_err <> 0 THEN
         RETURN(num_err);
      END IF;
*/
      -- Si se trata de un producto mixto (Ibex 35 + EUROPLAZO)
      -- Entonces obtenemos el valor de prima a Ibex 35 de la pregunta automatica 1013
      IF NVL(f_parproductos_v(v_sproduc, 'PRODUCTO_MIXTO'), 0) = 1 THEN
         BEGIN
            SELECT NVL(crespue, 0)
              INTO xitotalr
              FROM pregunseg
             WHERE sseguro = xsseguro
               AND cpregun = 1013;   -- 1013 = Respuest del calculo del importe de capital a aplicar a la parte de Ibex 35
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 112002;   --xsseguro
         END;
      ELSE
         -- INI RLLF 1702014 Control generación ctaseguro en los recibos hijo.
         IF pnrecibo IS NOT NULL THEN
            IF NVL(f_parproductos_v(v_sproduc, 'CTASEGURO_RECHIJOS'), 0) != 1 THEN
               -- Bug 19096 - RSC - 12/08/2011 - LCOL - Parametrización básica producto Vida Individual Pagos Permanentes
               SELECT COUNT(*)
                 INTO v_agrupado
                 FROM adm_recunif
                WHERE nrecibo = pnrecibo;

               IF v_agrupado > 0 THEN
                  RETURN 0;   -- Si está agrupado no apuntaremos nada en CTASEGURO
               END IF;
            END IF;
         END IF;

         -- Fin Bug 19096
         -- FIN RLLF 1702014 Control generación ctaseguro en los recibos hijo.

         -- Fin Bug 19096

         -- Bug 9424 -- 20/03/2009 - RSC - Creación del producto PPJ Dinàmic
         IF NVL(f_parproductos_v(v_sproduc, 'DETRECIBO_CONCEPTOS'), 0) = 0 THEN
            BEGIN
               SELECT NVL(itotalr, 0), NVL(icombru, 0)
                 INTO xitotalr, v_icombru
                 FROM vdetrecibos
                WHERE nrecibo = pnrecibo;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  RETURN 101731;   -- Rebut no trobat a VDETRECIBOS
               WHEN OTHERS THEN
                  RETURN 103920;   -- Error al llegir de VDETRECIBOS
            END;
         ELSE
            BEGIN
               SELECT NVL(icombru, 0)
                 INTO v_icombru
                 FROM vdetrecibos
                WHERE nrecibo = pnrecibo;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  RETURN 101731;   -- Rebut no trobat a VDETRECIBOS
               WHEN OTHERS THEN
                  RETURN 103920;   -- Error al llegir de VDETRECIBOS
            END;

            -- Bug 9424 -- 20/03/2009 - RSC - Creación del producto PPJ Dinàmic
            BEGIN
               SELECT NVL(SUM(DECODE(d.cconcep, 13, -1 * d.iconcep, d.iconcep)), 0)
                 INTO xitotalr
                 FROM detrecibos d, recibos r, seguros s
                WHERE d.nrecibo = pnrecibo
                  AND d.nrecibo = r.nrecibo
                  AND r.sseguro = s.sseguro
                  AND d.cconcep IN(0, 1, 2, 3, 4, 5, 6, 7, 8, 14, 13)
                  AND NVL(f_pargaranpro_v(s.cramo, s.cmodali, s.ctipseg, s.ccolect, s.cactivi,
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
                                             s.cactivi, d.cgarant, 'TIPO'),
                             0) = 3;
            END;
         END IF;
      END IF;

      IF pcfeccob IS NULL THEN
         BEGIN
            SELECT cfeccob
              INTO xcfeccob
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
         xcfeccob := pcfeccob;
      END IF;

      IF xctiprec = 9 THEN   -- Es un extorn
         xitotalr :=(0 - xitotalr);
         xcmovimi := 51;
         xcfeccob := NULL;
      ELSE
         xcmovimi := pcmovimi;
      END IF;

      -- Obtebemos la sequence para la agrupación (1-45) o (51,58)
      SELECT scagrcta.NEXTVAL
        INTO seqgrupo
        FROM DUAL;

      -- JRH Tarea 6966 RSC 14/07/2008 ----------------------------------------------------
      --IF trunc(pfvalmov) > trunc(xfefecto) THEN
      --  vvalorf := trunc(NVL(pfvalmov,xfefecto));
      --ELSE
      --  vvalorf := trunc(xfefecto);
      --END IF;
      vcontabf := NVL(pfmovdia, f_sysdate);   -- fcontab para la distribución
----------------------------------------------------------------------
      vvalorf := NVL(pfvalmov, xfefecto);

      IF xctiprec = 10 THEN
         SELECT COUNT(1)
           INTO cuantos_trasplaaportaciones
           FROM trasplaaportaciones
          WHERE stras IN(SELECT stras
                           FROM trasplainout
                          WHERE nrecibo = pnrecibo);
      END IF;

      cuentalin := 0;

      -- Traspasos de entrda, grabamos trasplaaportaciones en ctaseguro
      IF xctiprec = 10
         AND NVL(cuantos_trasplaaportaciones, 0) > 0 THEN
         xnnumlin := NVL(xnnumlin, 0) + 1;
         xnnumlinshw := NVL(xnnumlinshw, 0) + 1;

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
               -- cuentalin := cuentalin + 1; La función desglose fondos ya lo hace
               num_err := insertar_ctaseguro(xsseguro, xfefecto,
                                             NVL(xnnumlin + cuentalin, cuentalin), xfefecto,
                                             vvalorf, xcmovimi, reg.importe_ant, NULL,
                                             pnrecibo, seqgrupo, 0, NULL, psmovrec, xcfeccob,
                                             xfefecto, vvalorf, v_fectrasp, reg.proce);

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
                                                    xfefecto, vvalorf,   --xfefecto,
                                                    xcmovimi, reg.importe_ant, NULL, pnrecibo,
                                                    seqgrupo, 0, NULL, psmovrec, xcfeccob,
                                                    xfefecto, vvalorf, v_fectrasp, reg.proce);

                  IF num_err <> 0 THEN
                     RETURN num_err;
                  END IF;
               END IF;

               num_err := desglose_fondos(reg.importe_ant);

               IF num_err <> 0 THEN
                  RETURN num_err;
               END IF;
            ELSIF reg.importe_post > 0 THEN
               --    cuentalin := cuentalin + 1;
               num_err := insertar_ctaseguro(xsseguro, xfefecto,
                                             NVL(xnnumlinshw + cuentalin, cuentalin),
                                             xfefecto, vvalorf,   --xfefecto,
                                             xcmovimi, reg.importe_post, NULL, pnrecibo,
                                             seqgrupo, 0, NULL, psmovrec, xcfeccob, xfefecto,
                                             vvalorf, v_fectrasp, reg.proce);

               IF num_err <> 0 THEN
                  RETURN num_err;
               END IF;

               -- ALBERT - Modificar TRASPLAAPORTACIONES con el nnumlin de la aportación insertada
               UPDATE trasplaaportaciones
                  SET nnumlin_post = NVL(xnnumlinshw + cuentalin, cuentalin)
                WHERE ROWID = reg.ROWID;

               IF v_tieneshw = 1 THEN
                  num_err := insertar_ctaseguro_shw(xsseguro, xfefecto,
                                                    NVL(xnnumlinshw + cuentalin, cuentalin),
                                                    xfefecto, vvalorf,   --xfefecto,
                                                    xcmovimi, reg.importe_post, NULL,
                                                    pnrecibo, seqgrupo, 0, NULL, psmovrec,
                                                    xcfeccob, xfefecto, vvalorf, v_fectrasp,
                                                    reg.proce);

                  IF num_err <> 0 THEN
                     RETURN num_err;
                  END IF;
               END IF;

               num_err := desglose_fondos(reg.importe_post);

               IF num_err <> 0 THEN
                  RETURN num_err;
               END IF;
            END IF;
         END LOOP;
      ELSE
         num_err := insertar_ctaseguro(xsseguro, xfefecto, NVL(xnnumlin + 1, 1), xfefecto,
                                       vvalorf,   --xfefecto,
                                       xcmovimi, xitotalr, NULL, pnrecibo, seqgrupo, 0, NULL,
                                       psmovrec, xcfeccob, xfefecto, vvalorf);

         IF num_err <> 0 THEN
            RETURN num_err;
         END IF;

         IF v_tieneshw = 1 THEN
            num_err := insertar_ctaseguro_shw(xsseguro, xfefecto, NVL(xnnumlinshw + 1, 1),
                                              xfefecto, vvalorf,   --xfefecto,
                                              xcmovimi, xitotalr, NULL, pnrecibo, seqgrupo, 0,
                                              NULL, psmovrec, xcfeccob, xfefecto, vvalorf);

            IF num_err <> 0 THEN
               RETURN num_err;
            END IF;
         END IF;

         BEGIN
            SELECT NVL(MAX(nnumlin) + 1, 1)
              INTO xnnumlin
              FROM ctaseguro
             WHERE sseguro = xsseguro;

            IF v_tieneshw = 1 THEN
               SELECT NVL(MAX(nnumlin) + 1, 1)
                 INTO xnnumlinshw
                 FROM ctaseguro_shadow
                WHERE sseguro = xsseguro;
            END IF;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               xnnumlin := 1;
               xnnumlinshw := 1;
            WHEN OTHERS THEN
               RETURN 104882;   -- Error al llegir de CTASEGURO
         END;

         -- Bug 019291 - 24/10/2011 - MDS - ENSA102-Comisión Reguladora
         -- para el caso de recibos 11 y 12, la comprobación es sobre icombru
         -- para el resto de recibo la comprobación sigue siendo sobre itotalr
         IF xctiprec IN(11, 12) THEN
            IF NVL(v_icombru, 0) = 0 THEN
               RETURN 0;
            END IF;
         ELSE
            -- Bug 9424 - 15/04/2009 - RSC - Creación del producto PPJ Dinámic
            -- Si el importe del recibo es 0 retornamos 0 y se acabó
            IF NVL(xitotalr, 0) = 0 THEN
               RETURN 0;
            END IF;
         -- Fin Bug 9424
         END IF;

         -- Bug 21654 - RSC - 12/03/2012 - CRE - PPJ dinàmic:Error en suplement automàtic de canvi de perfil
         FOR valor IN cur_segdisin2(xsseguro, vvalorf) LOOP
            --FOR valor IN cur_segdisin2_act(xsseguro) LOOP
            -- Fin bug 21654

            --Calcula les distribucions
            vacumpercent := vacumpercent + (xitotalr * valor.pdistrec) / 100;
            xidistrib := ROUND(vacumpercent - vacumrounded, 2);
            vacumrounded := vacumrounded + ROUND(vacumpercent - vacumrounded, 2);
            --Calcula les distribucions
            --xidistrib := (xitotalr * valor.pdistrec) / 100;

            --Obtenemos el estado de la cesta (consultamos el estado en que están sus fondos a fecha de efecto)
            nerror := pac_val_finv.f_valida_estado_cesta(valor.ccesta, vvalorf, estado);

            IF estado = 'C' THEN
               hi_hac := hi_hac + 1;
            END IF;

            -- Bug 15707 - APD - 14/03/2011 - el Traspaso de entrada (CMOVIMI = 8) se debe tratar como si fuera una aportación
            IF (xcmovimi = 1
                OR xcmovimi = 2
                OR xcmovimi = 4
                OR xcmovimi = 8) THEN
               BEGIN
                  -- Si disponemos del valor liquidativo pues ya lo ponemos, es decir
                  -- ya podemos calcular aqui el numero de participaciones que le tocan
                  SELECT NVL(iuniactcmp, iuniact)
                    INTO viuniact
                    FROM tabvalces
                   WHERE ccesta = valor.ccesta
                     AND TRUNC(fvalor) = TRUNC(vvalorf)
                                         + pac_md_fondos.f_get_diasdep(valor.ccesta);   -- Bug 22268 - RSC - 15/05/2012 - LCOL_A001-Revision circuito domiciliaciones (TRUNC)

                  --Inserta registres a cuenta seguro.
                  BEGIN
                     IF v_cagrpro = 11
                        AND pnrecibo IS NOT NULL THEN
                        SELECT ctipapor, sperson
                          INTO v_ctipapor, v_sperapor
                          FROM recibos r
                         WHERE r.nrecibo = pnrecibo;

                        IF v_ctipapor = 4 THEN
                           v_ctipaux := 'PR';
                        ELSIF v_ctipapor = 5 THEN
                           v_ctipaux := 'PA';
                        ELSIF v_ctipapor = 6 THEN
                           v_ctipaux := 'SP';
                        ELSIF v_ctipapor = 7 THEN
                           v_ctipaux := 'B';
                        END IF;

                        v_spermin := v_sperapor;
                     END IF;

                     --Fi Bug.: 18632
                     INSERT INTO ctaseguro
                                 (sseguro, fcontab, nnumlin, ffecmov,
                                  fvalmov, cmovimi, imovimi, imovim2, nrecibo,
                                  ccalint, cmovanu, nsinies, smovrec, cesta,
                                  nunidad, cestado, fasign, spermin,
                                  ctipapor)
                          VALUES (xsseguro, vcontabf, xnnumlin, xfefecto,
                                  TRUNC(vvalorf + diascar), 45, xidistrib, NULL, pnrecibo,
                                  seqgrupo, 0, NULL, psmovrec, valor.ccesta,
                                  xidistrib / viuniact, '2', TRUNC(xfefecto), v_spermin,
                                  v_ctipaux);

                     -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
                     IF v_cmultimon = 1 THEN
                        num_err :=
                           pac_oper_monedas.f_update_ctaseguro_monpol(xsseguro, vcontabf,
                                                                      xnnumlin,
                                                                      TRUNC(vvalorf + diascar));

                        IF num_err <> 0 THEN
                           RETURN num_err;
                        END IF;
                     END IF;
                  -- FIN BUG 18423 - 15/12/2011 - JMP - Multimoneda
                  EXCEPTION
                     WHEN DUP_VAL_ON_INDEX THEN
                        RETURN 104879;   -- Registre duplicat a CTASEGURO
                     WHEN OTHERS THEN
                        RETURN 102555;   -- Error al insertar a la taula CTASEGURO
                  END;

                   -- Para la impresión de libreta (para que los movimientos generales también tenga actualizada
                  -- la fecha de asignación. Actualizamos el movimiento general anterior
                  UPDATE ctaseguro
                     SET cestado = '2',
                         fasign = TRUNC(f_sysdate)
                   WHERE sseguro = xsseguro
                     AND cmovimi = xcmovimi
                     AND ccalint = seqgrupo
                     AND nnumlin < xnnumlin;

                  IF v_tieneshw = 1 THEN
                     SELECT iuniactcmpshw
                       INTO viuniact
                       FROM tabvalces
                      WHERE ccesta = valor.ccesta
                        AND TRUNC(fvalor) = TRUNC(vvalorf)
                                            + pac_md_fondos.f_get_diasdep(valor.ccesta);

                     BEGIN
                        INSERT INTO ctaseguro_shadow
                                    (sseguro, fcontab, nnumlin, ffecmov,
                                     fvalmov, cmovimi, imovimi, imovim2, nrecibo,
                                     ccalint, cmovanu, nsinies, smovrec, cesta,
                                     nunidad, cestado, fasign, spermin,
                                     ctipapor)
                             VALUES (xsseguro, vcontabf, xnnumlinshw, xfefecto,
                                     TRUNC(vvalorf + diascar), 45, xidistrib, NULL, pnrecibo,
                                     seqgrupo, 0, NULL, psmovrec, valor.ccesta,
                                     xidistrib / viuniact, '2', TRUNC(xfefecto), v_spermin,
                                     v_ctipaux);

                        -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
                        IF v_cmultimon = 1 THEN
                           num_err :=
                              pac_oper_monedas.f_update_ctaseguro_shw_monpol(xsseguro,
                                                                             vcontabf,
                                                                             xnnumlinshw,
                                                                             TRUNC(vvalorf
                                                                                   + diascar));

                           IF num_err <> 0 THEN
                              RETURN num_err;
                           END IF;
                        END IF;
                     -- FIN BUG 18423 - 15/12/2011 - JMP - Multimoneda
                     EXCEPTION
                        WHEN DUP_VAL_ON_INDEX THEN
                           RETURN 104879;   -- Registre duplicat a CTASEGURO
                        WHEN OTHERS THEN
                           RETURN 102555;   -- Error al insertar a la taula CTASEGURO
                     END;

                      -- Para la impresión de libreta (para que los movimientos generales también tenga actualizada
                     -- la fecha de asignación. Actualizamos el movimiento general anterior
                     UPDATE ctaseguro_shadow
                        SET cestado = '2',
                            fasign = TRUNC(f_sysdate)
                      WHERE sseguro = xsseguro
                        AND cmovimi = xcmovimi
                        AND ccalint = seqgrupo
                        AND nnumlin < xnnumlinshw;

                     xnnumlinshw := xnnumlinshw + 1;
                  END IF;

                  -- Incrementamos numero de linea (por movimiento 58)
                  xnnumlin := xnnumlin + 1;

                  --ACTUALIZAR CESTA --> Aumentamos/Descontamos las participaciones asignadas al fondo en contratos
                  UPDATE fondos
                     SET fondos.nparasi = NVL(fondos.nparasi, 0) +(xidistrib / viuniact)
                   WHERE fondos.ccodfon = valor.ccesta;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     --Inserta registres a cuenta seguro.
                     BEGIN
                        --Bug.: 18632 - ICV - 07/06/2011
                        IF v_cagrpro = 11
                           AND pnrecibo IS NOT NULL THEN
                           SELECT ctipapor, sperson
                             INTO v_ctipapor, v_sperapor
                             FROM recibos r
                            WHERE r.nrecibo = pnrecibo;

                           IF v_ctipapor = 4 THEN
                              v_ctipaux := 'PR';
                           ELSIF v_ctipapor = 5 THEN
                              v_ctipaux := 'PA';
                           ELSIF v_ctipapor = 6 THEN
                              v_ctipaux := 'SP';
                           ELSIF v_ctipapor = 7 THEN
                              v_ctipaux := 'B';
                           END IF;

                           v_spermin := v_sperapor;
                        END IF;

                        --Fi Bug.: 18632
                        INSERT INTO ctaseguro
                                    (sseguro, fcontab, nnumlin, ffecmov,
                                     fvalmov, cmovimi, imovimi, imovim2, nrecibo,
                                     ccalint, cmovanu, nsinies, smovrec, cesta, cestado,
                                     spermin, ctipapor)
                             VALUES (xsseguro, vcontabf, xnnumlin, xfefecto,
                                     TRUNC(vvalorf + diascar), 45, xidistrib, NULL, pnrecibo,
                                     seqgrupo, 0, NULL, psmovrec, valor.ccesta, '1',
                                     v_spermin, v_ctipaux);

                        -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
                        IF v_cmultimon = 1 THEN
                           num_err :=
                              pac_oper_monedas.f_update_ctaseguro_monpol(xsseguro, vcontabf,
                                                                         xnnumlin,
                                                                         TRUNC(vvalorf
                                                                               + diascar));

                           IF num_err <> 0 THEN
                              RETURN num_err;
                           END IF;
                        END IF;

                        IF v_tieneshw = 1 THEN
                           INSERT INTO ctaseguro_shadow
                                       (sseguro, fcontab, nnumlin, ffecmov,
                                        fvalmov, cmovimi, imovimi, imovim2,
                                        nrecibo, ccalint, cmovanu, nsinies, smovrec, cesta,
                                        cestado, spermin, ctipapor)
                                VALUES (xsseguro, vcontabf, xnnumlinshw, xfefecto,
                                        TRUNC(vvalorf + diascar), 45, xidistrib, NULL,
                                        pnrecibo, seqgrupo, 0, NULL, psmovrec, valor.ccesta,
                                        '1', v_spermin, v_ctipaux);

                           -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
                           IF v_cmultimon = 1 THEN
                              num_err :=
                                 pac_oper_monedas.f_update_ctaseguro_shw_monpol
                                                                             (xsseguro,
                                                                              vcontabf,
                                                                              xnnumlinshw,
                                                                              TRUNC(vvalorf
                                                                                    + diascar));

                              IF num_err <> 0 THEN
                                 RETURN num_err;
                              END IF;
                           END IF;

                           xnnumlinshw := xnnumlinshw + 1;
                        END IF;

                        -- FIN BUG 18423 - 15/12/2011 - JMP - Multimoneda
                        xnnumlin := xnnumlin + 1;
                     EXCEPTION
                        WHEN DUP_VAL_ON_INDEX THEN
                           RETURN 104879;   -- Registre duplicat a CTASEGURO
                        WHEN OTHERS THEN
                           RETURN 102555;   -- Error al insertar a la taula CTASEGURO
                     END;
               END;
            ELSIF xcmovimi = 51 THEN
               BEGIN
                  -- Si disponemos del valor liquidativo pues ya lo ponemos, es decir
                  -- ya podemos calcular aqui el numero de participaciones que le tocan
                  SELECT NVL(iuniactcmp, iuniact)
                    INTO viuniact
                    FROM tabvalces
                   WHERE ccesta = valor.ccesta
                     AND TRUNC(fvalor) = TRUNC(vvalorf)
                                         + pac_md_fondos.f_get_diasdep(valor.ccesta);   -- Bug 22268 - RSC - 15/05/2012 - LCOL_A001-Revision circuito domiciliaciones (TRUNC)

                  --Inserta registres a cuenta seguro.
                  BEGIN
                     --Bug.: 18632 - ICV - 07/06/2011
                     IF v_cagrpro = 11
                        AND pnrecibo IS NOT NULL THEN
                        SELECT ctipapor, sperson
                          INTO v_ctipapor, v_sperapor
                          FROM recibos r
                         WHERE r.nrecibo = pnrecibo;

                        IF v_ctipapor = 4 THEN
                           v_ctipaux := 'PR';
                        ELSIF v_ctipapor = 5 THEN
                           v_ctipaux := 'PA';
                        ELSIF v_ctipapor = 6 THEN
                           v_ctipaux := 'SP';
                        ELSIF v_ctipapor = 7 THEN
                           v_ctipaux := 'B';
                        END IF;

                        v_spermin := v_sperapor;
                     END IF;

                     --Fi Bug.: 18632
                     INSERT INTO ctaseguro
                                 (sseguro, fcontab, nnumlin, ffecmov, fvalmov, cmovimi,
                                  imovimi, imovim2, nrecibo, ccalint, cmovanu, nsinies,
                                  smovrec, cesta, nunidad, cestado,
                                  fasign, spermin, ctipapor)
                          VALUES (xsseguro, vcontabf, xnnumlin, TRUNC(xfefecto), vvalorf, 58,
                                  xidistrib, NULL, pnrecibo, seqgrupo, 0, NULL,
                                  psmovrec, valor.ccesta, xidistrib / viuniact, '2',
                                  TRUNC(xfefecto), v_spermin, v_ctipaux);

                     -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
                     IF v_cmultimon = 1 THEN
                        num_err := pac_oper_monedas.f_update_ctaseguro_monpol(xsseguro,
                                                                              vcontabf,
                                                                              xnnumlin,
                                                                              vvalorf);

                        IF num_err <> 0 THEN
                           RETURN num_err;
                        END IF;
                     END IF;
                  -- FIN BUG 18423 - 15/12/2011 - JMP - Multimoneda
                  EXCEPTION
                     WHEN DUP_VAL_ON_INDEX THEN
                        RETURN 104879;   -- Registre duplicat a CTASEGURO
                     WHEN OTHERS THEN
                        RETURN 102555;   -- Error al insertar a la taula CTASEGURO
                  END;

                  -- Para la impresión de libreta (para que los movimientos generales también tenga actualizada
                  -- la fecha de asignación. Actualizamos el movimiento general anterior
                  UPDATE ctaseguro
                     SET cestado = '2',
                         fasign = TRUNC(f_sysdate)
                   WHERE sseguro = xsseguro
                     AND cmovimi = 51
                     AND ccalint = seqgrupo
                     AND nnumlin < xnnumlin;

                  IF v_tieneshw = 1 THEN
                     SELECT iuniactcmpshw
                       INTO viuniact
                       FROM tabvalces
                      WHERE ccesta = valor.ccesta
                        AND TRUNC(fvalor) = TRUNC(vvalorf)
                                            + pac_md_fondos.f_get_diasdep(valor.ccesta);   -- Bug 22268 - RSC - 15/05/2012 - LCOL_A001-Revision circuito domiciliaciones (TRUNC)

                     --Inserta registres a cuenta seguro.
                     BEGIN
                        --Bug.: 18632 - ICV - 07/06/2011
                        IF v_cagrpro = 11
                           AND pnrecibo IS NOT NULL THEN
                           SELECT ctipapor, sperson
                             INTO v_ctipapor, v_sperapor
                             FROM recibos r
                            WHERE r.nrecibo = pnrecibo;

                           IF v_ctipapor = 4 THEN
                              v_ctipaux := 'PR';
                           ELSIF v_ctipapor = 5 THEN
                              v_ctipaux := 'PA';
                           ELSIF v_ctipapor = 6 THEN
                              v_ctipaux := 'SP';
                           ELSIF v_ctipapor = 7 THEN
                              v_ctipaux := 'B';
                           END IF;

                           v_spermin := v_sperapor;
                        END IF;

                        --Fi Bug.: 18632
                        INSERT INTO ctaseguro_shadow
                                    (sseguro, fcontab, nnumlin, ffecmov,
                                     fvalmov, cmovimi, imovimi, imovim2, nrecibo, ccalint,
                                     cmovanu, nsinies, smovrec, cesta, nunidad,
                                     cestado, fasign, spermin, ctipapor)
                             VALUES (xsseguro, vcontabf, xnnumlinshw, TRUNC(xfefecto),
                                     vvalorf, 58, xidistrib, NULL, pnrecibo, seqgrupo,
                                     0, NULL, psmovrec, valor.ccesta, xidistrib / viuniact,
                                     '2', TRUNC(xfefecto), v_spermin, v_ctipaux);

                        -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
                        IF v_cmultimon = 1 THEN
                           num_err :=
                              pac_oper_monedas.f_update_ctaseguro_shw_monpol(xsseguro,
                                                                             vcontabf,
                                                                             xnnumlinshw,
                                                                             vvalorf);

                           IF num_err <> 0 THEN
                              RETURN num_err;
                           END IF;
                        END IF;
                     -- FIN BUG 18423 - 15/12/2011 - JMP - Multimoneda
                     EXCEPTION
                        WHEN DUP_VAL_ON_INDEX THEN
                           RETURN 104879;   -- Registre duplicat a CTASEGURO
                        WHEN OTHERS THEN
                           RETURN 102555;   -- Error al insertar a la taula CTASEGURO
                     END;

                     -- Para la impresión de libreta (para que los movimientos generales también tenga actualizada
                     -- la fecha de asignación. Actualizamos el movimiento general anterior
                     UPDATE ctaseguro_shadow
                        SET cestado = '2',
                            fasign = TRUNC(f_sysdate)
                      WHERE sseguro = xsseguro
                        AND cmovimi = 51
                        AND ccalint = seqgrupo
                        AND nnumlin < xnnumlinshw;

                     xnnumlinshw := xnnumlinshw + 1;
                  END IF;

                  -- Incrementamos numero de linea (por movimiento 58)
                  xnnumlin := xnnumlin + 1;

                  --ACTUALIZAR CESTA --> Descontamos las participaciones asignadas al fondo en contratos
                  UPDATE fondos
                     SET fondos.nparasi = NVL(fondos.nparasi, 0) +(xidistrib / viuniact)
                   WHERE fondos.ccodfon = valor.ccesta;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     --Inserta registres a cuenta seguro.
                     BEGIN
                        --Bug.: 18632 - ICV - 07/06/2011
                        IF v_cagrpro = 11
                           AND pnrecibo IS NOT NULL THEN
                           SELECT ctipapor, sperson
                             INTO v_ctipapor, v_sperapor
                             FROM recibos r
                            WHERE r.nrecibo = pnrecibo;

                           IF v_ctipapor = 4 THEN
                              v_ctipaux := 'PR';
                           ELSIF v_ctipapor = 5 THEN
                              v_ctipaux := 'PA';
                           ELSIF v_ctipapor = 6 THEN
                              v_ctipaux := 'SP';
                           ELSIF v_ctipapor = 7 THEN
                              v_ctipaux := 'B';
                           END IF;

                           v_spermin := v_sperapor;
                        END IF;

                        --Fi Bug.: 18632
                        INSERT INTO ctaseguro
                                    (sseguro, fcontab, nnumlin, ffecmov, fvalmov,
                                     cmovimi, imovimi, imovim2, nrecibo, ccalint, cmovanu,
                                     nsinies, smovrec, cesta, cestado, spermin, ctipapor)
                             VALUES (xsseguro, vcontabf, xnnumlin, TRUNC(xfefecto), vvalorf,
                                     58, xidistrib, NULL, pnrecibo, seqgrupo, 0,
                                     NULL, psmovrec, valor.ccesta, '1', v_spermin, v_ctipaux);

                        -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
                        IF v_cmultimon = 1 THEN
                           num_err := pac_oper_monedas.f_update_ctaseguro_monpol(xsseguro,
                                                                                 vcontabf,
                                                                                 xnnumlin,
                                                                                 vvalorf);

                           IF num_err <> 0 THEN
                              RETURN num_err;
                           END IF;
                        END IF;

                        IF v_tieneshw = 1 THEN
                           INSERT INTO ctaseguro_shadow
                                       (sseguro, fcontab, nnumlin, ffecmov,
                                        fvalmov, cmovimi, imovimi, imovim2, nrecibo, ccalint,
                                        cmovanu, nsinies, smovrec, cesta, cestado, spermin,
                                        ctipapor)
                                VALUES (xsseguro, vcontabf, xnnumlinshw, TRUNC(xfefecto),
                                        vvalorf, 58, xidistrib, NULL, pnrecibo, seqgrupo,
                                        0, NULL, psmovrec, valor.ccesta, '1', v_spermin,
                                        v_ctipaux);

                           -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
                           IF v_cmultimon = 1 THEN
                              num_err :=
                                 pac_oper_monedas.f_update_ctaseguro_shw_monpol(xsseguro,
                                                                                vcontabf,
                                                                                xnnumlinshw,
                                                                                vvalorf);

                              IF num_err <> 0 THEN
                                 RETURN num_err;
                              END IF;
                           END IF;

                           xnnumlinshw := xnnumlinshw + 1;
                        END IF;

                        -- FIN BUG 18423 - 15/12/2011 - JMP - Multimoneda
                        xnnumlin := xnnumlin + 1;
                     EXCEPTION
                        WHEN DUP_VAL_ON_INDEX THEN
                           RETURN 104879;   -- Registre duplicat a CTASEGURO
                        WHEN OTHERS THEN
                           RETURN 102555;   -- Error al insertar a la taula CTASEGURO
                     END;
               END;
            END IF;
         END LOOP;
      END IF;

      --
      -- Desglose de Prima de riesgo y Gastos
      --
            --
      IF (NVL(pac_parametros.f_parproducto_n(v_sproduc, 'AHORRO_PREPAGABLE'), 0) = 1) THEN
         num_err := pac_ctaseguro.f_ins_desglose_aho(xsseguro, TRUNC(xfefecto), xcmovimi,
                                                     seqgrupo, 'R', v_cagrpro, v_sproduc,
                                                     NULL, NULL, NULL, pnrecibo, NULL);

         IF num_err <> 0 THEN
            RETURN num_err;
         END IF;

         IF v_tieneshw = 1 THEN
            num_err := pac_ctaseguro.f_ins_desglose_aho_shw(xsseguro, TRUNC(xfefecto),
                                                            xcmovimi, seqgrupo, 'R',
                                                            v_cagrpro, v_sproduc, NULL, NULL,
                                                            NULL, pnrecibo, NULL);

            IF num_err <> 0 THEN
               RETURN num_err;
            END IF;
         END IF;
      END IF;

      --

      --========================================================================================
-- ini Bug 0018767 - JMF - 09/06/2011
--========================================================================================
      IF NVL(f_parproductos_v(v_sproduc, 'DESCUENTA_SUSCRIP'), 0) = 1 THEN
         IF NVL(v_icombru, 0) <> 0 THEN
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

            -- Obtebemos la sequence para la agrupación (1-45) o (51,58)
            SELECT scagrcta.NEXTVAL
              INTO seqgrupo
              FROM DUAL;

            vcontabf := NVL(pfmovdia, f_sysdate);   -- fcontab para la distribución
            -- Bug 0018767 - JMF - 09/06/2011
            --xitotalr := xitotalr *(v_pgasto / 100);
            xitotalr := v_icombru;

            IF (xcmovimi = 1
                OR xcmovimi = 2
                OR xcmovimi = 4
                OR xcmovimi = 8) THEN
               -- Bug 019291 - 24/10/2011 - MDS - ENSA102-Comisión Reguladora
               -- para el caso de recibos 11 y 12, las comisiones son la 72,73,74,75
               -- para el resto de recibo siguen siendo las mismas
               IF xctiprec = 11 THEN
                  v_cmovimi_compensa := 72;
                  v_cmovimi_detalle := 73;
               ELSIF xctiprec = 12 THEN
                  v_cmovimi_compensa := 74;
                  v_cmovimi_detalle := 75;
               ELSE
                  v_cmovimi_compensa := 86;
                  v_cmovimi_detalle := 88;
               END IF;

               v_signo := -1;
            ELSIF xcmovimi = 51 THEN
               v_cmovimi_compensa := 89;
               v_cmovimi_detalle := 95;
               v_signo := 1;
            END IF;

----------------------------------------------------------------------
            vvalorf := NVL(pfvalmov, xfefecto);
            num_err := insertar_ctaseguro(xsseguro, xfefecto, NVL(xnnumlin + 1, 1), xfefecto,
                                          vvalorf,   --xfefecto,
                                          v_cmovimi_compensa, xitotalr, NULL, pnrecibo,
                                          seqgrupo, 0, NULL, psmovrec, xcfeccob, xfefecto,
                                          vvalorf);

            IF num_err <> 0 THEN
               RETURN num_err;
            END IF;

            IF v_tieneshw = 1 THEN
               num_err := insertar_ctaseguro_shw(xsseguro, xfefecto, NVL(xnnumlinshw + 1, 1),
                                                 xfefecto, vvalorf,   --xfefecto,
                                                 v_cmovimi_compensa, xitotalr, NULL, pnrecibo,
                                                 seqgrupo, 0, NULL, psmovrec, xcfeccob,
                                                 xfefecto, vvalorf);

               IF num_err <> 0 THEN
                  RETURN num_err;
               END IF;
            END IF;

            BEGIN
               SELECT NVL(MAX(nnumlin) + 1, 1)
                 INTO xnnumlin
                 FROM ctaseguro
                WHERE sseguro = xsseguro;

               IF v_tieneshw = 1 THEN
                  SELECT NVL(MAX(nnumlin) + 1, 1)
                    INTO xnnumlinshw
                    FROM ctaseguro_shadow
                   WHERE sseguro = xsseguro;
               END IF;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  xnnumlin := 1;
                  xnnumlinshw := 1;
               WHEN OTHERS THEN
                  RETURN 104882;   -- Error al llegir de CTASEGURO
            END;

            -- Bug 019291 - 24/10/2011 - MDS - ENSA102-Comisión Reguladora
            -- para el caso de recibos 11 y 12, la comprobación es sobre icombru
            -- para el resto de recibo la comprobación sigue siendo sobre itotalr
            IF xctiprec IN(11, 12) THEN
               IF NVL(v_icombru, 0) = 0 THEN
                  RETURN 0;
               END IF;
            ELSE
               -- Bug 9424 - 15/04/2009 - RSC - Creación del producto PPJ Dinámic
               -- Si el importe del recibo es 0 retornamos 0 y se acabó
               IF NVL(xitotalr, 0) = 0 THEN
                  RETURN 0;
               END IF;
            -- Fin Bug 9424
            END IF;

            -- Bug 21654 - RSC - 12/03/2012 - CRE - PPJ dinàmic:Error en suplement automàtic de canvi de perfil
            FOR valor IN cur_segdisin2(xsseguro, vvalorf) LOOP
               --FOR valor IN cur_segdisin2_act(xsseguro) LOOP
               -- Fin bug 21654

               --Calcula les distribucions
               vacumpercent := vacumpercent + (xitotalr * valor.pdistrec) / 100;
               xidistrib := ROUND(vacumpercent - vacumrounded, 2);
               vacumrounded := vacumrounded + ROUND(vacumpercent - vacumrounded, 2);
               --Calcula les distribucions
               --xidistrib := (xitotalr * valor.pdistrec) / 100;

               --Obtenemos el estado de la cesta (consultamos el estado en que están sus fondos a fecha de efecto)
               nerror := pac_val_finv.f_valida_estado_cesta(valor.ccesta, vvalorf, estado);

               IF estado = 'C' THEN
                  hi_hac := hi_hac + 1;
               END IF;

               -- Bug 15707 - APD - 14/03/2011 - el Traspaso de entrada (CMOVIMI = 8) se debe tratar como si fuera una aportación
               IF (xcmovimi = 1
                   OR xcmovimi = 2
                   OR xcmovimi = 4
                   OR xcmovimi = 8) THEN
                  BEGIN
                     -- Si disponemos del valor liquidativo pues ya lo ponemos, es decir
                     -- ya podemos calcular aqui el numero de participaciones que le tocan
                     SELECT NVL(iuniactcmp, iuniact)
                       INTO viuniact
                       FROM tabvalces
                      WHERE ccesta = valor.ccesta
                        AND TRUNC(fvalor) = TRUNC(vvalorf)
                                            + pac_md_fondos.f_get_diasdep(valor.ccesta);   -- Bug 22268 - RSC - 15/05/2012 - LCOL_A001-Revision circuito domiciliaciones (TRUNC)

                     --Inserta registres a cuenta seguro.
                     BEGIN
                        INSERT INTO ctaseguro
                                    (sseguro, fcontab, nnumlin, ffecmov,
                                     fvalmov, cmovimi, imovimi,
                                     imovim2, nrecibo, ccalint, cmovanu, nsinies, smovrec,
                                     cesta, nunidad, cestado,
                                     fasign)
                             VALUES (xsseguro, vcontabf, xnnumlin, xfefecto,
                                     TRUNC(vvalorf + diascar), v_cmovimi_detalle, xidistrib,
                                     NULL, pnrecibo, seqgrupo, 0, NULL, psmovrec,
                                     valor.ccesta, (xidistrib / viuniact) * v_signo, '2',
                                     TRUNC(xfefecto));

                        -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
                        IF v_cmultimon = 1 THEN
                           num_err :=
                              pac_oper_monedas.f_update_ctaseguro_monpol(xsseguro, vcontabf,
                                                                         xnnumlin,
                                                                         TRUNC(vvalorf
                                                                               + diascar));

                           IF num_err <> 0 THEN
                              RETURN num_err;
                           END IF;
                        END IF;
                     -- FIN BUG 18423 - 15/12/2011 - JMP - Multimoneda
                     EXCEPTION
                        WHEN DUP_VAL_ON_INDEX THEN
                           RETURN 104879;   -- Registre duplicat a CTASEGURO
                        WHEN OTHERS THEN
                           RETURN 102555;   -- Error al insertar a la taula CTASEGURO
                     END;

                      -- Para la impresión de libreta (para que los movimientos generales también tenga actualizada
                     -- la fecha de asignación. Actualizamos el movimiento general anterior
                     UPDATE ctaseguro
                        SET cestado = '2',
                            fasign = TRUNC(f_sysdate)
                      WHERE sseguro = xsseguro
                        AND cmovimi = xcmovimi
                        AND ccalint = seqgrupo
                        AND nnumlin < xnnumlin;

                     IF v_tieneshw = 1 THEN
                        SELECT iuniactcmpshw
                          INTO viuniact
                          FROM tabvalces
                         WHERE ccesta = valor.ccesta
                           AND TRUNC(fvalor) = TRUNC(vvalorf)
                                               + pac_md_fondos.f_get_diasdep(valor.ccesta);

                        BEGIN
                           INSERT INTO ctaseguro_shadow
                                       (sseguro, fcontab, nnumlin, ffecmov,
                                        fvalmov, cmovimi,
                                        imovimi, imovim2, nrecibo, ccalint, cmovanu, nsinies,
                                        smovrec, cesta,
                                        nunidad, cestado, fasign)
                                VALUES (xsseguro, vcontabf, xnnumlinshw, xfefecto,
                                        TRUNC(vvalorf + diascar), v_cmovimi_detalle,
                                        xidistrib, NULL, pnrecibo, seqgrupo, 0, NULL,
                                        psmovrec, valor.ccesta,
                                        (xidistrib / viuniact) * v_signo, '2', TRUNC(xfefecto));

                           -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
                           IF v_cmultimon = 1 THEN
                              num_err :=
                                 pac_oper_monedas.f_update_ctaseguro_shw_monpol
                                                                             (xsseguro,
                                                                              vcontabf,
                                                                              xnnumlinshw,
                                                                              TRUNC(vvalorf
                                                                                    + diascar));

                              IF num_err <> 0 THEN
                                 RETURN num_err;
                              END IF;
                           END IF;
                        -- FIN BUG 18423 - 15/12/2011 - JMP - Multimoneda
                        EXCEPTION
                           WHEN DUP_VAL_ON_INDEX THEN
                              RETURN 104879;   -- Registre duplicat a CTASEGURO
                           WHEN OTHERS THEN
                              RETURN 102555;   -- Error al insertar a la taula CTASEGURO
                        END;

                         -- Para la impresión de libreta (para que los movimientos generales también tenga actualizada
                        -- la fecha de asignación. Actualizamos el movimiento general anterior
                        UPDATE ctaseguro_shadow
                           SET cestado = '2',
                               fasign = TRUNC(f_sysdate)
                         WHERE sseguro = xsseguro
                           AND cmovimi = xcmovimi
                           AND ccalint = seqgrupo
                           AND nnumlin < xnnumlinshw;

                        xnnumlinshw := xnnumlinshw + 1;
                     END IF;

                     -- Incrementamos numero de linea (por movimiento 58)
                     xnnumlin := xnnumlin + 1;

                     --ACTUALIZAR CESTA --> Aumentamos/Descontamos las participaciones asignadas al fondo en contratos
                     UPDATE fondos
                        SET fondos.nparasi = NVL(fondos.nparasi, 0) +(xidistrib / viuniact)
                      WHERE fondos.ccodfon = valor.ccesta;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        --Inserta registres a cuenta seguro.
                        BEGIN
                           INSERT INTO ctaseguro
                                       (sseguro, fcontab, nnumlin, ffecmov,
                                        fvalmov, cmovimi,
                                        imovimi, imovim2, nrecibo, ccalint, cmovanu, nsinies,
                                        smovrec, cesta, cestado)
                                VALUES (xsseguro, vcontabf, xnnumlin, xfefecto,
                                        TRUNC(vvalorf + diascar), v_cmovimi_detalle,
                                        xidistrib, NULL, pnrecibo, seqgrupo, 0, NULL,
                                        psmovrec, valor.ccesta, '1');

                           -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
                           IF v_cmultimon = 1 THEN
                              num_err :=
                                 pac_oper_monedas.f_update_ctaseguro_monpol(xsseguro,
                                                                            vcontabf,
                                                                            xnnumlin,
                                                                            TRUNC(vvalorf
                                                                                  + diascar));

                              IF num_err <> 0 THEN
                                 RETURN num_err;
                              END IF;
                           END IF;

                           IF v_tieneshw = 1 THEN
                              INSERT INTO ctaseguro_shadow
                                          (sseguro, fcontab, nnumlin, ffecmov,
                                           fvalmov, cmovimi,
                                           imovimi, imovim2, nrecibo, ccalint, cmovanu,
                                           nsinies, smovrec, cesta, cestado)
                                   VALUES (xsseguro, vcontabf, xnnumlinshw, xfefecto,
                                           TRUNC(vvalorf + diascar), v_cmovimi_detalle,
                                           xidistrib, NULL, pnrecibo, seqgrupo, 0,
                                           NULL, psmovrec, valor.ccesta, '1');

                              -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
                              IF v_cmultimon = 1 THEN
                                 num_err :=
                                    pac_oper_monedas.f_update_ctaseguro_shw_monpol
                                                                             (xsseguro,
                                                                              vcontabf,
                                                                              xnnumlinshw,
                                                                              TRUNC(vvalorf
                                                                                    + diascar));

                                 IF num_err <> 0 THEN
                                    RETURN num_err;
                                 END IF;
                              END IF;

                              xnnumlinshw := xnnumlinshw + 1;
                           END IF;

                           -- FIN BUG 18423 - 15/12/2011 - JMP - Multimoneda
                           xnnumlin := xnnumlin + 1;
                        EXCEPTION
                           WHEN DUP_VAL_ON_INDEX THEN
                              RETURN 104879;   -- Registre duplicat a CTASEGURO
                           WHEN OTHERS THEN
                              RETURN 102555;   -- Error al insertar a la taula CTASEGURO
                        END;
                  END;
               ELSIF xcmovimi = 51 THEN
                  BEGIN
                     -- Si disponemos del valor liquidativo pues ya lo ponemos, es decir
                     -- ya podemos calcular aqui el numero de participaciones que le tocan
                     SELECT NVL(iuniactcmp, iuniact)
                       INTO viuniact
                       FROM tabvalces
                      WHERE ccesta = valor.ccesta
                        AND TRUNC(fvalor) = TRUNC(vvalorf)
                                            + pac_md_fondos.f_get_diasdep(valor.ccesta);   -- Bug 22268 - RSC - 15/05/2012 - LCOL_A001-Revision circuito domiciliaciones (TRUNC)

                     --Inserta registres a cuenta seguro.
                     BEGIN
                        INSERT INTO ctaseguro
                                    (sseguro, fcontab, nnumlin, ffecmov, fvalmov,
                                     cmovimi, imovimi, imovim2, nrecibo, ccalint,
                                     cmovanu, nsinies, smovrec, cesta, nunidad,
                                     cestado, fasign)
                             VALUES (xsseguro, vcontabf, xnnumlin, TRUNC(xfefecto), vvalorf,
                                     v_cmovimi_detalle, xidistrib, NULL, pnrecibo, seqgrupo,
                                     0, NULL, psmovrec, valor.ccesta, xidistrib / viuniact,
                                     '2', TRUNC(xfefecto));

                        -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
                        IF v_cmultimon = 1 THEN
                           num_err := pac_oper_monedas.f_update_ctaseguro_monpol(xsseguro,
                                                                                 vcontabf,
                                                                                 xnnumlin,
                                                                                 vvalorf);

                           IF num_err <> 0 THEN
                              RETURN num_err;
                           END IF;
                        END IF;
                     -- FIN BUG 18423 - 15/12/2011 - JMP - Multimoneda
                     EXCEPTION
                        WHEN DUP_VAL_ON_INDEX THEN
                           RETURN 104879;   -- Registre duplicat a CTASEGURO
                        WHEN OTHERS THEN
                           RETURN 102555;   -- Error al insertar a la taula CTASEGURO
                     END;

                     -- Para la impresión de libreta (para que los movimientos generales también tenga actualizada
                     -- la fecha de asignación. Actualizamos el movimiento general anterior
                     UPDATE ctaseguro
                        SET cestado = '2',
                            fasign = TRUNC(f_sysdate)
                      WHERE sseguro = xsseguro
                        AND cmovimi = 51
                        AND ccalint = seqgrupo
                        AND nnumlin < xnnumlin;

                     IF v_tieneshw = 1 THEN
                        SELECT iuniactcmpshw
                          INTO viuniact
                          FROM tabvalces
                         WHERE ccesta = valor.ccesta
                           AND TRUNC(fvalor) = TRUNC(vvalorf)
                                               + pac_md_fondos.f_get_diasdep(valor.ccesta);   -- Bug 22268 - RSC - 15/05/2012 - LCOL_A001-Revision circuito domiciliaciones (TRUNC)

                        --Inserta registres a cuenta seguro.
                        BEGIN
                           INSERT INTO ctaseguro_shadow
                                       (sseguro, fcontab, nnumlin, ffecmov,
                                        fvalmov, cmovimi, imovimi, imovim2,
                                        nrecibo, ccalint, cmovanu, nsinies, smovrec, cesta,
                                        nunidad, cestado, fasign)
                                VALUES (xsseguro, vcontabf, xnnumlinshw, TRUNC(xfefecto),
                                        vvalorf, v_cmovimi_detalle, xidistrib, NULL,
                                        pnrecibo, seqgrupo, 0, NULL, psmovrec, valor.ccesta,
                                        xidistrib / viuniact, '2', TRUNC(xfefecto));

                           -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
                           IF v_cmultimon = 1 THEN
                              num_err :=
                                 pac_oper_monedas.f_update_ctaseguro_shw_monpol(xsseguro,
                                                                                vcontabf,
                                                                                xnnumlinshw,
                                                                                vvalorf);

                              IF num_err <> 0 THEN
                                 RETURN num_err;
                              END IF;
                           END IF;
                        -- FIN BUG 18423 - 15/12/2011 - JMP - Multimoneda
                        EXCEPTION
                           WHEN DUP_VAL_ON_INDEX THEN
                              RETURN 104879;   -- Registre duplicat a CTASEGURO
                           WHEN OTHERS THEN
                              RETURN 102555;   -- Error al insertar a la taula CTASEGURO
                        END;

                        -- Para la impresión de libreta (para que los movimientos generales también tenga actualizada
                        -- la fecha de asignación. Actualizamos el movimiento general anterior
                        UPDATE ctaseguro_shadow
                           SET cestado = '2',
                               fasign = TRUNC(f_sysdate)
                         WHERE sseguro = xsseguro
                           AND cmovimi = 51
                           AND ccalint = seqgrupo
                           AND nnumlin < xnnumlinshw;

                        xnnumlinshw := xnnumlinshw + 1;
                     END IF;

                     -- Incrementamos numero de linea (por movimiento 58)
                     xnnumlin := xnnumlin + 1;

                     --ACTUALIZAR CESTA --> Descontamos las participaciones asignadas al fondo en contratos
                     UPDATE fondos
                        SET fondos.nparasi = NVL(fondos.nparasi, 0) +(xidistrib / viuniact)
                      WHERE fondos.ccodfon = valor.ccesta;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        --Inserta registres a cuenta seguro.
                        BEGIN
                           INSERT INTO ctaseguro
                                       (sseguro, fcontab, nnumlin, ffecmov,
                                        fvalmov, cmovimi, imovimi, imovim2,
                                        nrecibo, ccalint, cmovanu, nsinies, smovrec, cesta,
                                        cestado)
                                VALUES (xsseguro, vcontabf, xnnumlin, TRUNC(xfefecto),
                                        vvalorf, v_cmovimi_detalle, xidistrib, NULL,
                                        pnrecibo, seqgrupo, 0, NULL, psmovrec, valor.ccesta,
                                        '1');

                           -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
                           IF v_cmultimon = 1 THEN
                              num_err := pac_oper_monedas.f_update_ctaseguro_monpol(xsseguro,
                                                                                    vcontabf,
                                                                                    xnnumlin,
                                                                                    vvalorf);

                              IF num_err <> 0 THEN
                                 RETURN num_err;
                              END IF;
                           END IF;

                           IF v_tieneshw = 1 THEN
                              INSERT INTO ctaseguro_shadow
                                          (sseguro, fcontab, nnumlin, ffecmov,
                                           fvalmov, cmovimi, imovimi, imovim2,
                                           nrecibo, ccalint, cmovanu, nsinies, smovrec,
                                           cesta, cestado)
                                   VALUES (xsseguro, vcontabf, xnnumlinshw, TRUNC(xfefecto),
                                           vvalorf, v_cmovimi_detalle, xidistrib, NULL,
                                           pnrecibo, seqgrupo, 0, NULL, psmovrec,
                                           valor.ccesta, '1');

                              -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
                              IF v_cmultimon = 1 THEN
                                 num_err :=
                                    pac_oper_monedas.f_update_ctaseguro_shw_monpol
                                                                                 (xsseguro,
                                                                                  vcontabf,
                                                                                  xnnumlinshw,
                                                                                  vvalorf);

                                 IF num_err <> 0 THEN
                                    RETURN num_err;
                                 END IF;
                              END IF;

                              xnnumlinshw := xnnumlinshw + 1;
                           END IF;

                           -- FIN BUG 18423 - 15/12/2011 - JMP - Multimoneda
                           xnnumlin := xnnumlin + 1;
                        EXCEPTION
                           WHEN DUP_VAL_ON_INDEX THEN
                              RETURN 104879;   -- Registre duplicat a CTASEGURO
                           WHEN OTHERS THEN
                              RETURN 102555;   -- Error al insertar a la taula CTASEGURO
                        END;
                  END;
               END IF;
            END LOOP;
         END IF;
      END IF;

  --========================================================================================
  -- fin Bug 0018767 - JMF - 09/06/2011
  --========================================================================================
--========================================================================================

      -- actualizamos la FValmov de los registros añadidos
      IF nerror = 180442
         OR hi_hac > 0 THEN
         RETURN(180442);
      ELSE
         -- si todas las cestas del modelo de inversión están abiertas entonces
         -- la fecha de valor del movimiento será la de efecto.
         BEGIN
            UPDATE ctaseguro
               SET fvalmov = vvalorf
             WHERE sseguro = xsseguro
               AND fcontab = vcontabf   -- xfefecto
               AND cmovimi IN(5, 45, 88);

            -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
            IF v_cmultimon = 1 THEN
               FOR reg IN (SELECT sseguro, fcontab, nnumlin, fvalmov
                             FROM ctaseguro
                            WHERE sseguro = xsseguro
                              AND fcontab = vcontabf
                              AND cmovimi IN(5, 45, 88)) LOOP
                  num_err := pac_oper_monedas.f_update_ctaseguro_monpol(reg.sseguro,
                                                                        reg.fcontab,
                                                                        reg.nnumlin,
                                                                        reg.fvalmov);

                  IF num_err <> 0 THEN
                     RETURN num_err;
                  END IF;
               END LOOP;
            END IF;

            IF v_tieneshw = 1 THEN
               UPDATE ctaseguro_shadow
                  SET fvalmov = vvalorf
                WHERE sseguro = xsseguro
                  AND fcontab = vcontabf   -- xfefecto
                  AND cmovimi IN(5, 45, 88);

               -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
               IF v_cmultimon = 1 THEN
                  FOR reg IN (SELECT sseguro, fcontab, nnumlin, fvalmov
                                FROM ctaseguro_shadow
                               WHERE sseguro = xsseguro
                                 AND fcontab = vcontabf
                                 AND cmovimi IN(5, 45, 88)) LOOP
                     num_err := pac_oper_monedas.f_update_ctaseguro_shw_monpol(reg.sseguro,
                                                                               reg.fcontab,
                                                                               reg.nnumlin,
                                                                               reg.fvalmov);

                     IF num_err <> 0 THEN
                        RETURN num_err;
                     END IF;
                  END LOOP;
               END IF;
            END IF;
         -- FIN BUG 18423 - 15/12/2011 - JMP - Multimoneda
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 102555;   -- Error al insertar a la taula CTASEGURO
         END;
      END IF;
-----------------------------------------------------------------------------
   ELSIF pcodmov = 2 THEN   -- Anul·lar
--------------------------------------------------------------------------
/*
      num_err := f_sproduc(xcramo, xcmodali, xctipseg, xccolect, v_sproduc);

      IF num_err <> 0 THEN
         RETURN(num_err);
      END IF;
*/
      -- Anulamos los movimientos del recibo
      --nnumlin, fcontab, imovimi, cmovanu, cmovimi
      FOR regs IN cur_ctaseguro LOOP
         v_entra := 1;

         IF regs.cmovanu = 0 THEN
            num_err := update_ctaseguro(xsseguro, regs.fcontab, regs.nnumlin);

            IF num_err <> 0 THEN
               RETURN num_err;
            END IF;
         END IF;
      END LOOP;

      IF v_tieneshw = 1 THEN
         FOR regs IN cur_ctaseguro_shw LOOP
            v_entra := 1;

            IF regs.cmovanu = 0 THEN
               num_err := update_ctaseguro_shw(xsseguro, regs.fcontab, regs.nnumlin);

               IF num_err <> 0 THEN
                  RETURN num_err;
               END IF;
            END IF;
         END LOOP;
      END IF;

      -- Si entra = 0 no ha tratado ningun linea --> Rebut no trobat a CTASEGURO
      IF v_entra = 0 THEN
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

         --Bug.: 16701 - ICV - 23/11/2010
         IF NVL(f_parproductos_v(v_sproduc, 'DETRECIBO_CONCEPTOS'), 0) = 1 THEN
            BEGIN
               SELECT DISTINCT r.nrecibo
                          INTO v_nrecibo_aux
                          FROM detrecibos d, recibos r, seguros s
                         WHERE d.nrecibo = pnrecibo
                           AND d.nrecibo = r.nrecibo
                           AND r.sseguro = s.sseguro
                           AND d.cconcep IN(0, 1, 2, 3, 4, 5, 6, 7, 8, 14, 13)
                           AND NVL(f_pargaranpro_v(s.cramo, s.cmodali, s.ctipseg, s.ccolect,
                                                   s.cactivi, d.cgarant, 'TIPO'),
                                   0) IN(3, 4);
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  RETURN 0;
            END;
         END IF;

         --Fin Bug.
         RETURN 103071;   -- Rebut no trobat a la taula CTASEGURO
      END IF;

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
               num_err := update_ctaseguro_shw(xsseguro, regs2.fcontab, regs2.nnumlin);

               IF num_err <> 0 THEN
                  RETURN num_err;
               END IF;
            END LOOP;
         END IF;
      END IF;

      OPEN cur_ctaseguro_general;

      FETCH cur_ctaseguro_general
       INTO xnnumlinant, xfcontabant, ximovimiant, xcmovanuant, xcmovimi, xccalint;

      IF cur_ctaseguro_general%FOUND THEN
         IF v_tieneshw = 1 THEN
            OPEN cur_ctaseguro_general_shw;

            FETCH cur_ctaseguro_general_shw
             INTO xnnumlinantshw, xfcontabantshw, ximovimiantshw, xcmovanuantshw, xcmovimishw,
                  xccalintshw;
         END IF;

         IF pcfeccob IS NULL THEN
            BEGIN
               SELECT cfeccob
                 INTO xcfeccob
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
            xcfeccob := pcfeccob;
         END IF;

         -- Tenemos que anular el movimiento de Ctaseguro poniendo el movimiento cmovimi = 51
         IF xctiprec = 9 THEN   -- Es un extorn
            IF (NVL(f_parproductos_v(v_sproduc, 'PRODUCTO_MIXTO'), 0) = 1) THEN
               xcmovimi := pcmovimi;
            ELSE
               xcmovimi := 1;
               v_cmovimi_compensa := 86;
            END IF;
         ELSE
            xcmovimi := 51;
            v_cmovimi_compensa := 89;
         END IF;

         xcfeccob := NULL;
         -- JRH Tarea 6966  xfefecto := TO_DATE(TO_CHAR(xfefecto,'ddmmyyyy') || '23:58','ddmmyyyyhh24:mi');
         xfefecto := TRUNC(f_sysdate);

         -- Seleccionamos la fvalor
         BEGIN
            SELECT fvalmov
              INTO xfvalor
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
                 INTO xfvalorshw
                 FROM ctaseguro_shadow
                WHERE sseguro = xsseguro
                  AND nnumlin = xnnumlinantshw;
            EXCEPTION
               WHEN OTHERS THEN
                  NULL;
            END;
         END IF;

         -- Si existe una o más redistribuciones entre la aportación y la anulación de la
         -- aportación, entonces debemos poner la fvalor de la redistribución (consultado con Sa Nostra)
         BEGIN
            SELECT ffecmov, fvalmov, nnumlin, cmovimi
              INTO vr_ffecmov, vr_fvalmov, vr_nnumlin, vr_cmovimi
              FROM ctaseguro
             WHERE sseguro = xsseguro
               AND nnumlin > xnnumlinant
               AND cmovimi = 60
               AND ffecmov = (SELECT MAX(ffecmov)
                                FROM ctaseguro c2
                               WHERE c2.sseguro = xsseguro
                                 AND c2.nnumlin > xnnumlinant
                                 AND c2.cmovimi = 60);   -- Esto es por si hay más de una redistribución entre
                                                         -- la aportación y la anulación. En ese hipotetico caso
                                                         -- cogemos la fvalmov de la última redistribución.
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;

         IF vr_fvalmov IS NOT NULL
            AND xcmovimi = 51 THEN   -- movimiento de anulación y redistribución por en medio
            xfvalor := vr_fvalmov;
         END IF;

         IF v_tieneshw = 1 THEN
            BEGIN
               SELECT ffecmov, fvalmov, nnumlin, cmovimi
                 INTO vr_ffecmovshw, vr_fvalmovshw, vr_nnumlinshw, vr_cmovimishw
                 FROM ctaseguro_shadow
                WHERE sseguro = xsseguro
                  AND nnumlin > xnnumlinantshw
                  AND cmovimi = 60
                  AND ffecmov = (SELECT MAX(ffecmov)
                                   FROM ctaseguro_shadow c2
                                  WHERE c2.sseguro = xsseguro
                                    AND c2.nnumlin > xnnumlinantshw
                                    AND c2.cmovimi = 60);   -- Esto es por si hay más de una redistribución entre
                                                            -- la aportación y la anulación. En ese hipotetico caso
                                                            -- cogemos la fvalmov de la última redistribución.
            EXCEPTION
               WHEN OTHERS THEN
                  NULL;
            END;

            IF vr_fvalmovshw IS NOT NULL
               AND xcmovimi = 51 THEN   -- movimiento de anulación y redistribución por en medio
               xfvalorshw := vr_fvalmovshw;
            END IF;
         END IF;

         -- Obtebemos la sequence para la agrupación (1-45) o (51,58)
         SELECT scagrcta.NEXTVAL
           INTO seqgrupo
           FROM DUAL;

         -- Insertamos movimiento 51
         num_err := insertar_ctaseguro(xsseguro, xfefecto, NVL(xnnumlin + 1, 1),
                                       TRUNC(xfefecto), NVL(xfvalor, xfefecto), xcmovimi,
                                       NVL(0 - ximovimiant, 0), NVL(0 - ximovimiant, 0),
                                       pnrecibo, seqgrupo, 0, NULL, psmovrec, xcfeccob,
                                       xfefecto, xfvalor);

         IF num_err <> 0 THEN
            CLOSE cur_ctaseguro_general;

            IF cur_ctaseguro_general_shw%ISOPEN THEN
               CLOSE cur_ctaseguro_general_shw;
            END IF;

            RETURN num_err;
         END IF;

         IF v_tieneshw = 1 THEN
            num_err := insertar_ctaseguro_shw(xsseguro, xfefecto, NVL(xnnumlinshw + 1, 1),
                                              TRUNC(xfefecto), NVL(xfvalorshw, xfefecto),
                                              xcmovimi, NVL(0 - ximovimiantshw, 0),
                                              NVL(0 - ximovimiantshw, 0), pnrecibo, seqgrupo,
                                              0, NULL, psmovrec, xcfeccob, xfefecto,
                                              xfvalorshw);

            IF num_err <> 0 THEN
               CLOSE cur_ctaseguro_general;

               IF cur_ctaseguro_general_shw%ISOPEN THEN
                  CLOSE cur_ctaseguro_general_shw;
               END IF;

               RETURN num_err;
            END IF;
         END IF;

         ------------ //// CREAMOS LOS MOVIMIENTOS DETALLE AL 51 ///// -----------
         BEGIN
            SELECT NVL(MAX(nnumlin) + 1, 1)
              INTO xnnumlin
              FROM ctaseguro
             WHERE sseguro = xsseguro;

            IF v_tieneshw = 1 THEN
               SELECT NVL(MAX(nnumlin) + 1, 1)
                 INTO xnnumlinshw
                 FROM ctaseguro_shadow
                WHERE sseguro = xsseguro;
            END IF;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               xnnumlin := 1;
               xnnumlinshw := 1;
            WHEN OTHERS THEN
               RETURN 104882;   -- Error al llegir de CTASEGURO
         END;

         -- Bug 21654 - RSC - 12/03/2012 - CRE - PPJ dinàmic:Error en suplement automàtic de canvi de perfil
         FOR valor IN cur_segdisin2(xsseguro, NVL(xfvalor, xfefecto)) LOOP
            --FOR valor IN cur_segdisin2_act(xsseguro) LOOP
            -- Fin bug 21654

            --Calcula les distribucions
            vacumpercent := vacumpercent + (ximovimiant * valor.pdistrec) / 100;
            xidistrib := ROUND(vacumpercent - vacumrounded, 2);
            vacumrounded := vacumrounded + ROUND(vacumpercent - vacumrounded, 2);

            --Calcula les distribucions
            --xidistrib := (ximovimiant * valor.pdistrec) / 100;

            --Inserta registres a cuenta seguro.
            IF xcmovimi = 51 THEN
               BEGIN
                  -- Si disponemos del valor liquidativo pues ya lo ponemos, es decir
                  -- ya podemos calcular aqui el numero de participaciones que le tocan
                  SELECT NVL(iuniactcmp, iuniact)
                    INTO viuniact
                    FROM tabvalces
                   WHERE ccesta = valor.ccesta
                     AND TRUNC(fvalor) = TRUNC(NVL(xfvalor, xfefecto))
                                         + pac_md_fondos.f_get_diasdep(valor.ccesta);

                  BEGIN
                     --Bug.: 18632 - ICV - 07/06/2011
                     IF v_cagrpro = 11
                        AND pnrecibo IS NOT NULL THEN
                        SELECT ctipapor, sperson
                          INTO v_ctipapor, v_sperapor
                          FROM recibos r
                         WHERE r.nrecibo = pnrecibo;

                        IF v_ctipapor = 4 THEN
                           v_ctipaux := 'PR';
                        ELSIF v_ctipapor = 5 THEN
                           v_ctipaux := 'PA';
                        ELSIF v_ctipapor = 6 THEN
                           v_ctipaux := 'SP';
                        ELSIF v_ctipapor = 7 THEN
                           v_ctipaux := 'B';
                        END IF;

                        v_spermin := v_sperapor;
                     END IF;

                     --Fi Bug.: 18632
                     INSERT INTO ctaseguro
                                 (sseguro, fcontab, nnumlin,
                                  ffecmov, fvalmov, cmovimi, imovimi,
                                  imovim2, nrecibo, ccalint, cmovanu, nsinies, smovrec, cesta,
                                  nunidad, cestado, fasign, spermin,
                                  ctipapor)
                          VALUES (xsseguro, NVL(pfmovdia, f_sysdate), xnnumlin,
                                  TRUNC(xfefecto), NVL(xfvalor, xfefecto), 58, xidistrib,
                                  NULL, pnrecibo, seqgrupo, 0, NULL, psmovrec, valor.ccesta,
                                  (xidistrib / viuniact) * -1,   -- Mantis 12274.NMM.i.
                                                              '2', TRUNC(f_sysdate), v_spermin,
                                  v_ctipaux);

                     -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
                     IF v_cmultimon = 1 THEN
                        num_err := pac_oper_monedas.f_update_ctaseguro_monpol(xsseguro,
                                                                              NVL(pfmovdia,
                                                                                  f_sysdate),
                                                                              xnnumlin,
                                                                              NVL(xfvalor,
                                                                                  xfefecto));

                        IF num_err <> 0 THEN
                           RETURN num_err;
                        END IF;
                     END IF;
                  -- FIN BUG 18423 - 15/12/2011 - JMP - Multimoneda
                  EXCEPTION
                     WHEN DUP_VAL_ON_INDEX THEN
                        RETURN(104879);   -- Registre duplicat a CTASEGURO
                     WHEN OTHERS THEN
                        RETURN(102555);   -- Error al insertar a la taula CTASEGURO
                  END;

                  -- Para la impresión de libreta (para que los movimientos generales también tenga actualizada
                  -- la fecha de asignación. Actualizamos el movimiento general anterior
                  UPDATE ctaseguro
                     SET cestado = '2',
                         fasign = TRUNC(f_sysdate)
                   WHERE sseguro = xsseguro
                     AND cmovimi = 51
                     AND ccalint = seqgrupo
                     AND nnumlin < xnnumlin;

                  IF v_tieneshw = 1 THEN
                     SELECT iuniactcmpshw
                       INTO viuniact
                       FROM tabvalces
                      WHERE ccesta = valor.ccesta
                        AND TRUNC(fvalor) = TRUNC(NVL(xfvalorshw, xfefecto))
                                            + pac_md_fondos.f_get_diasdep(valor.ccesta);

                     BEGIN
                        --Bug.: 18632 - ICV - 07/06/2011

                        --Fi Bug.: 18632
                        INSERT INTO ctaseguro_shadow
                                    (sseguro, fcontab, nnumlin,
                                     ffecmov, fvalmov, cmovimi,
                                     imovimi, imovim2, nrecibo, ccalint, cmovanu, nsinies,
                                     smovrec, cesta, nunidad, cestado,
                                     fasign, spermin, ctipapor)
                             VALUES (xsseguro, NVL(pfmovdia, f_sysdate), xnnumlinshw,
                                     TRUNC(xfefecto), NVL(xfvalorshw, xfefecto), 58,
                                     xidistrib, NULL, pnrecibo, seqgrupo, 0, NULL,
                                     psmovrec, valor.ccesta, (xidistrib / viuniact) * -1,   -- Mantis 12274.NMM.i.
                                                                                         '2',
                                     TRUNC(f_sysdate), v_spermin, v_ctipaux);

                        -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
                        IF v_cmultimon = 1 THEN
                           num_err :=
                              pac_oper_monedas.f_update_ctaseguro_shw_monpol(xsseguro,
                                                                             NVL(pfmovdia,
                                                                                 f_sysdate),
                                                                             xnnumlinshw,
                                                                             NVL(xfvalorshw,
                                                                                 xfefecto));

                           IF num_err <> 0 THEN
                              RETURN num_err;
                           END IF;
                        END IF;
                     -- FIN BUG 18423 - 15/12/2011 - JMP - Multimoneda
                     EXCEPTION
                        WHEN DUP_VAL_ON_INDEX THEN
                           RETURN(104879);   -- Registre duplicat a CTASEGURO
                        WHEN OTHERS THEN
                           RETURN(102555);   -- Error al insertar a la taula CTASEGURO
                     END;

                     -- Para la impresión de libreta (para que los movimientos generales también tenga actualizada
                     -- la fecha de asignación. Actualizamos el movimiento general anterior
                     UPDATE ctaseguro_shadow
                        SET cestado = '2',
                            fasign = TRUNC(f_sysdate)
                      WHERE sseguro = xsseguro
                        AND cmovimi = 51
                        AND ccalint = seqgrupo
                        AND nnumlin < xnnumlinshw;

                     xnnumlinshw := xnnumlinshw + 1;
                  END IF;

                  -- incrementamos linea (por mov 58)
                  xnnumlin := xnnumlin + 1;

                  --ACTUALIZAR CESTA --> Descontamos las participaciones asignadas al fondo en contratos
                  UPDATE fondos
                     SET fondos.nparasi = NVL(fondos.nparasi, 0) +(xidistrib / viuniact)
                   WHERE fondos.ccodfon = valor.ccesta;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     BEGIN
                        --Bug.: 18632 - ICV - 07/06/2011
                        IF v_cagrpro = 11
                           AND pnrecibo IS NOT NULL THEN
                           SELECT ctipapor, sperson
                             INTO v_ctipapor, v_sperapor
                             FROM recibos r
                            WHERE r.nrecibo = pnrecibo;

                           IF v_ctipapor = 4 THEN
                              v_ctipaux := 'PR';
                           ELSIF v_ctipapor = 5 THEN
                              v_ctipaux := 'PA';
                           ELSIF v_ctipapor = 6 THEN
                              v_ctipaux := 'SP';
                           ELSIF v_ctipapor = 7 THEN
                              v_ctipaux := 'B';
                           END IF;

                           v_spermin := v_sperapor;
                        END IF;

                        --Fi Bug.: 18632
                        INSERT INTO ctaseguro
                                    (sseguro, fcontab, nnumlin,
                                     ffecmov, fvalmov, cmovimi, imovimi,
                                     imovim2, nrecibo, ccalint, cmovanu, nsinies, smovrec,
                                     cesta, cestado, spermin, ctipapor)
                             VALUES (xsseguro, NVL(pfmovdia, f_sysdate), xnnumlin,
                                     TRUNC(xfefecto), NVL(xfvalor, xfefecto), 58, xidistrib,
                                     NULL, pnrecibo, seqgrupo, 0, NULL, psmovrec,
                                     valor.ccesta, '1', v_spermin, v_ctipaux);

                        -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
                        IF v_cmultimon = 1 THEN
                           num_err :=
                              pac_oper_monedas.f_update_ctaseguro_monpol(xsseguro,
                                                                         NVL(pfmovdia,
                                                                             f_sysdate),
                                                                         xnnumlin,
                                                                         NVL(xfvalor,
                                                                             xfefecto));

                           IF num_err <> 0 THEN
                              RETURN num_err;
                           END IF;
                        END IF;

                        IF v_tieneshw = 1 THEN
                           --Fi Bug.: 18632
                           INSERT INTO ctaseguro_shadow
                                       (sseguro, fcontab, nnumlin,
                                        ffecmov, fvalmov, cmovimi,
                                        imovimi, imovim2, nrecibo, ccalint, cmovanu, nsinies,
                                        smovrec, cesta, cestado, spermin, ctipapor)
                                VALUES (xsseguro, NVL(pfmovdia, f_sysdate), xnnumlinshw,
                                        TRUNC(xfefecto), NVL(xfvalorshw, xfefecto), 58,
                                        xidistrib, NULL, pnrecibo, seqgrupo, 0, NULL,
                                        psmovrec, valor.ccesta, '1', v_spermin, v_ctipaux);

                           -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
                           IF v_cmultimon = 1 THEN
                              num_err :=
                                 pac_oper_monedas.f_update_ctaseguro_shw_monpol
                                                                             (xsseguro,
                                                                              NVL(pfmovdia,
                                                                                  f_sysdate),
                                                                              xnnumlinshw,
                                                                              NVL(xfvalorshw,
                                                                                  xfefecto));

                              IF num_err <> 0 THEN
                                 RETURN num_err;
                              END IF;
                           END IF;

                           xnnumlinshw := xnnumlinshw + 1;
                        END IF;

                        -- FIN BUG 18423 - 15/12/2011 - JMP - Multimoneda
                        xnnumlin := xnnumlin + 1;
                     EXCEPTION
                        WHEN DUP_VAL_ON_INDEX THEN
                           RETURN(104879);   -- Registre duplicat a CTASEGURO
                        WHEN OTHERS THEN
                           RETURN(102555);   -- Error al insertar a la taula CTASEGURO
                     END;
               END;
            -- Bug 15707 - APD - 14/03/2011 - el Traspaso de entrada (CMOVIMI = 8) se debe tratar como si fuera una aportación
            ELSIF(xcmovimi = 1
                  OR xcmovimi = 2
                  OR xcmovimi = 4
                  OR xcmovimi = 8) THEN
               BEGIN
                  -- Si disponemos del valor liquidativo pues ya lo ponemos, es decir
                  -- ya podemos calcular aqui el numero de participaciones que le tocan
                  SELECT NVL(iuniactcmp, iuniact)
                    INTO viuniact
                    FROM tabvalces
                   WHERE ccesta = valor.ccesta
                     AND TRUNC(fvalor) = TRUNC(NVL(xfvalor, xfefecto))
                                         + pac_md_fondos.f_get_diasdep(valor.ccesta);

                  BEGIN
                     --Bug.: 18632 - ICV - 07/06/2011
                     IF v_cagrpro = 11
                        AND pnrecibo IS NOT NULL THEN
                        SELECT ctipapor, sperson
                          INTO v_ctipapor, v_sperapor
                          FROM recibos r
                         WHERE r.nrecibo = pnrecibo;

                        IF v_ctipapor = 4 THEN
                           v_ctipaux := 'PR';
                        ELSIF v_ctipapor = 5 THEN
                           v_ctipaux := 'PA';
                        ELSIF v_ctipapor = 6 THEN
                           v_ctipaux := 'SP';
                        ELSIF v_ctipapor = 7 THEN
                           v_ctipaux := 'B';
                        END IF;

                        v_spermin := v_sperapor;
                     END IF;

                     --Fi Bug.: 18632
                     INSERT INTO ctaseguro
                                 (sseguro, fcontab, nnumlin,
                                  ffecmov, fvalmov, cmovimi, imovimi,
                                  imovim2, nrecibo, ccalint, cmovanu, nsinies, smovrec, cesta,
                                  nunidad, cestado, fasign, spermin,
                                  ctipapor)
                          VALUES (xsseguro, NVL(pfmovdia, f_sysdate), xnnumlin,
                                  TRUNC(xfefecto), NVL(xfvalor, xfefecto), 45, xidistrib,
                                  NULL, pnrecibo, seqgrupo, 0, NULL, psmovrec, valor.ccesta,
                                  xidistrib / viuniact, '2', TRUNC(f_sysdate), v_spermin,
                                  v_ctipaux);

                     -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
                     IF v_cmultimon = 1 THEN
                        num_err := pac_oper_monedas.f_update_ctaseguro_monpol(xsseguro,
                                                                              NVL(pfmovdia,
                                                                                  f_sysdate),
                                                                              xnnumlin,
                                                                              NVL(xfvalor,
                                                                                  xfefecto));

                        IF num_err <> 0 THEN
                           RETURN num_err;
                        END IF;
                     END IF;
                  -- FIN BUG 18423 - 15/12/2011 - JMP - Multimoneda
                  EXCEPTION
                     WHEN DUP_VAL_ON_INDEX THEN
                        RETURN 104879;   -- Registre duplicat a CTASEGURO
                     WHEN OTHERS THEN
                        RETURN 102555;   -- Error al insertar a la taula CTASEGURO
                  END;

                  -- Para la impresión de libreta (para que los movimientos generales también tenga actualizada
                  -- la fecha de asignación. Actualizamos el movimiento general anterior
                  -- Bug 15707 - APD - 14/03/2011 - el Traspaso de entrada (CMOVIMI = 8) se debe tratar como si fuera una aportación
                  UPDATE ctaseguro
                     SET cestado = '2',
                         fasign = TRUNC(f_sysdate)
                   WHERE sseguro = xsseguro
                     AND cmovimi IN(1, 2, 4, 8)
                     AND ccalint = seqgrupo
                     AND nnumlin < xnnumlin;

                  IF v_tieneshw = 1 THEN
                     SELECT iuniactcmpshw
                       INTO viuniact
                       FROM tabvalces
                      WHERE ccesta = valor.ccesta
                        AND TRUNC(fvalor) = TRUNC(NVL(xfvalorshw, xfefecto))
                                            + pac_md_fondos.f_get_diasdep(valor.ccesta);

                     BEGIN
                        --Bug.: 18632 - ICV - 07/06/2011

                        --Fi Bug.: 18632
                        INSERT INTO ctaseguro_shadow
                                    (sseguro, fcontab, nnumlin,
                                     ffecmov, fvalmov, cmovimi,
                                     imovimi, imovim2, nrecibo, ccalint, cmovanu, nsinies,
                                     smovrec, cesta, nunidad, cestado,
                                     fasign, spermin, ctipapor)
                             VALUES (xsseguro, NVL(pfmovdia, f_sysdate), xnnumlinshw,
                                     TRUNC(xfefecto), NVL(xfvalorshw, xfefecto), 45,
                                     xidistrib, NULL, pnrecibo, seqgrupo, 0, NULL,
                                     psmovrec, valor.ccesta, xidistrib / viuniact, '2',
                                     TRUNC(f_sysdate), v_spermin, v_ctipaux);

                        -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
                        IF v_cmultimon = 1 THEN
                           num_err :=
                              pac_oper_monedas.f_update_ctaseguro_shw_monpol(xsseguro,
                                                                             NVL(pfmovdia,
                                                                                 f_sysdate),
                                                                             xnnumlinshw,
                                                                             NVL(xfvalorshw,
                                                                                 xfefecto));

                           IF num_err <> 0 THEN
                              RETURN num_err;
                           END IF;
                        END IF;
                     -- FIN BUG 18423 - 15/12/2011 - JMP - Multimoneda
                     EXCEPTION
                        WHEN DUP_VAL_ON_INDEX THEN
                           RETURN 104879;   -- Registre duplicat a CTASEGURO
                        WHEN OTHERS THEN
                           RETURN 102555;   -- Error al insertar a la taula CTASEGURO
                     END;

                     -- Para la impresión de libreta (para que los movimientos generales también tenga actualizada
                     -- la fecha de asignación. Actualizamos el movimiento general anterior
                     -- Bug 15707 - APD - 14/03/2011 - el Traspaso de entrada (CMOVIMI = 8) se debe tratar como si fuera una aportación
                     UPDATE ctaseguro_shadow
                        SET cestado = '2',
                            fasign = TRUNC(f_sysdate)
                      WHERE sseguro = xsseguro
                        AND cmovimi IN(1, 2, 4, 8)
                        AND ccalint = seqgrupo
                        AND nnumlin < xnnumlinshw;

                     xnnumlinshw := xnnumlinshw + 1;
                  END IF;

                  -- Fin Bug 15707 - APD - 14/03/2011
                  -- incrementamos linea (por mov 45)
                  xnnumlin := xnnumlin + 1;

                  --ACTUALIZAR CESTA --> Aumentamos las participaciones asignadas al fondo en contratos
                  UPDATE fondos
                     SET fondos.nparasi = NVL(fondos.nparasi, 0) +(xidistrib / viuniact)
                   WHERE fondos.ccodfon = valor.ccesta;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     BEGIN
                        --Bug.: 18632 - ICV - 07/06/2011
                        IF v_cagrpro = 11
                           AND pnrecibo IS NOT NULL THEN
                           SELECT ctipapor, sperson
                             INTO v_ctipapor, v_sperapor
                             FROM recibos r
                            WHERE r.nrecibo = pnrecibo;

                           IF v_ctipapor = 4 THEN
                              v_ctipaux := 'PR';
                           ELSIF v_ctipapor = 5 THEN
                              v_ctipaux := 'PA';
                           ELSIF v_ctipapor = 6 THEN
                              v_ctipaux := 'SP';
                           ELSIF v_ctipapor = 7 THEN
                              v_ctipaux := 'B';
                           END IF;

                           v_spermin := v_sperapor;
                        END IF;

                        --Fi Bug.: 18632
                        INSERT INTO ctaseguro
                                    (sseguro, fcontab, nnumlin,
                                     ffecmov, fvalmov, cmovimi, imovimi,
                                     imovim2, nrecibo, ccalint, cmovanu, nsinies, smovrec,
                                     cesta, cestado, spermin, ctipapor)
                             VALUES (xsseguro, NVL(pfmovdia, f_sysdate), xnnumlin,
                                     TRUNC(xfefecto), NVL(xfvalor, xfefecto), 45, xidistrib,
                                     NULL, pnrecibo, seqgrupo, 0, NULL, psmovrec,
                                     valor.ccesta, '1', v_spermin, v_ctipaux);

                        -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
                        IF v_cmultimon = 1 THEN
                           num_err :=
                              pac_oper_monedas.f_update_ctaseguro_monpol(xsseguro,
                                                                         NVL(pfmovdia,
                                                                             f_sysdate),
                                                                         xnnumlin,
                                                                         NVL(xfvalor,
                                                                             xfefecto));

                           IF num_err <> 0 THEN
                              RETURN num_err;
                           END IF;
                        END IF;

                        IF v_tieneshw = 1 THEN
                           INSERT INTO ctaseguro_shadow
                                       (sseguro, fcontab, nnumlin,
                                        ffecmov, fvalmov, cmovimi,
                                        imovimi, imovim2, nrecibo, ccalint, cmovanu, nsinies,
                                        smovrec, cesta, cestado, spermin, ctipapor)
                                VALUES (xsseguro, NVL(pfmovdia, f_sysdate), xnnumlinshw,
                                        TRUNC(xfefecto), NVL(xfvalorshw, xfefecto), 45,
                                        xidistrib, NULL, pnrecibo, seqgrupo, 0, NULL,
                                        psmovrec, valor.ccesta, '1', v_spermin, v_ctipaux);

                           -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
                           IF v_cmultimon = 1 THEN
                              num_err :=
                                 pac_oper_monedas.f_update_ctaseguro_shw_monpol
                                                                             (xsseguro,
                                                                              NVL(pfmovdia,
                                                                                  f_sysdate),
                                                                              xnnumlinshw,
                                                                              NVL(xfvalorshw,
                                                                                  xfefecto));

                              IF num_err <> 0 THEN
                                 RETURN num_err;
                              END IF;
                           END IF;

                           xnnumlinshw := xnnumlinshw + 1;
                        END IF;

                        -- FIN BUG 18423 - 15/12/2011 - JMP - Multimoneda
                        xnnumlin := xnnumlin + 1;
                     EXCEPTION
                        WHEN DUP_VAL_ON_INDEX THEN
                           RETURN 104879;   -- Registre duplicat a CTASEGURO
                        WHEN OTHERS THEN
                           RETURN 102555;   -- Error al insertar a la taula CTASEGURO
                     END;
               END;
            END IF;
         END LOOP;

--========================================================================================
--========================================================================================
-- ini Bug 0018767 - JMF - 09/06/2011
--========================================================================================
         IF NVL(f_parproductos_v(v_sproduc, 'DESCUENTA_SUSCRIP'), 0) = 1 THEN
            BEGIN
               SELECT NVL(icombru, 0)
                 INTO v_icombru
                 FROM vdetrecibos
                WHERE nrecibo = pnrecibo;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  RETURN 101731;   -- Rebut no trobat a VDETRECIBOS
               WHEN OTHERS THEN
                  RETURN 103920;   -- Error al llegir de VDETRECIBOS
            END;

            IF NVL(v_icombru, 0) <> 0 THEN
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

               -- Bug 0018767 - JMF - 09/06/2011
               --ximovimiant := ximovimiant *(v_pgasto / 100);
               --ximovimiant := v_icombru;
               v_ccomi := v_icombru;

               IF (xcmovimi = 1
                   OR xcmovimi = 2
                   OR xcmovimi = 4
                   OR xcmovimi = 8) THEN
                  v_cmovimi_compensa := 86;
                  v_cmovimi_detalle := 88;
                  v_signo := -1;
               ELSIF xcmovimi = 51 THEN
                  v_cmovimi_compensa := 89;
                  v_cmovimi_detalle := 95;
                  v_signo := 1;
               END IF;

               -- Obtebemos la sequence para la agrupación (1-45) o (51,58)
               SELECT scagrcta.NEXTVAL
                 INTO seqgrupo
                 FROM DUAL;

               -- Insertamos movimiento 51
               num_err := insertar_ctaseguro(xsseguro, xfefecto, NVL(xnnumlin + 1, 1),
                                             TRUNC(xfefecto), NVL(xfvalor, xfefecto),
                                             v_cmovimi_compensa, NVL(0 - v_ccomi, 0),
                                             NVL(0 - v_ccomi, 0), pnrecibo, seqgrupo, 0, NULL,
                                             psmovrec, xcfeccob, xfefecto, xfvalor);

               IF num_err <> 0 THEN
                  CLOSE cur_ctaseguro_general;

                  IF cur_ctaseguro_general_shw%ISOPEN THEN
                     CLOSE cur_ctaseguro_general_shw;
                  END IF;

                  RETURN num_err;
               END IF;

               IF v_tieneshw = 1 THEN
                  num_err := insertar_ctaseguro_shw(xsseguro, xfefecto,
                                                    NVL(xnnumlinshw + 1, 1), TRUNC(xfefecto),
                                                    NVL(xfvalorshw, xfefecto),
                                                    v_cmovimi_compensa, NVL(0 - v_ccomi, 0),
                                                    NVL(0 - v_ccomi, 0), pnrecibo, seqgrupo,
                                                    0, NULL, psmovrec, xcfeccob, xfefecto,
                                                    xfvalorshw);

                  IF num_err <> 0 THEN
                     CLOSE cur_ctaseguro_general;

                     IF cur_ctaseguro_general_shw%ISOPEN THEN
                        CLOSE cur_ctaseguro_general_shw;
                     END IF;

                     RETURN num_err;
                  END IF;
               END IF;

               ------------ //// CREAMOS LOS MOVIMIENTOS DETALLE AL 51 ///// -----------
               BEGIN
                  SELECT NVL(MAX(nnumlin) + 1, 1)
                    INTO xnnumlin
                    FROM ctaseguro
                   WHERE sseguro = xsseguro;

                  IF v_tieneshw = 1 THEN
                     SELECT NVL(MAX(nnumlin) + 1, 1)
                       INTO xnnumlinshw
                       FROM ctaseguro_shadow
                      WHERE sseguro = xsseguro;
                  END IF;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     xnnumlin := 1;
                     xnnumlinshw := 1;
                  WHEN OTHERS THEN
                     RETURN 104882;   -- Error al llegir de CTASEGURO
               END;

               -- Bug 21654 - RSC - 12/03/2012 - CRE - PPJ dinàmic:Error en suplement automàtic de canvi de perfil
               FOR valor IN cur_segdisin2(xsseguro, NVL(xfvalor, xfefecto)) LOOP
                  --FOR valor IN cur_segdisin2_act(xsseguro) LOOP
                  -- Fin Bug 21654

                  --Calcula les distribucions
                  vacumpercent := vacumpercent + (v_ccomi * valor.pdistrec) / 100;
                  xidistrib := ROUND(vacumpercent - vacumrounded, 2);
                  vacumrounded := vacumrounded + ROUND(vacumpercent - vacumrounded, 2);

                  --Inserta registres a cuenta seguro.
                  IF xcmovimi = 51 THEN
                     BEGIN
                        -- Si disponemos del valor liquidativo pues ya lo ponemos, es decir
                        -- ya podemos calcular aqui el numero de participaciones que le tocan
                        SELECT NVL(iuniactcmp, iuniact)
                          INTO viuniact
                          FROM tabvalces
                         WHERE ccesta = valor.ccesta
                           AND TRUNC(fvalor) = TRUNC(NVL(xfvalor, xfefecto))
                                               + pac_md_fondos.f_get_diasdep(valor.ccesta);

                        BEGIN
                           INSERT INTO ctaseguro
                                       (sseguro, fcontab, nnumlin,
                                        ffecmov, fvalmov,
                                        cmovimi, imovimi, imovim2, nrecibo,
                                        ccalint, cmovanu, nsinies, smovrec, cesta,
                                        nunidad, cestado, fasign)
                                VALUES (xsseguro, NVL(pfmovdia, f_sysdate), xnnumlin,
                                        TRUNC(xfefecto), NVL(xfvalor, xfefecto),
                                        v_cmovimi_detalle, xidistrib, NULL, pnrecibo,
                                        seqgrupo, 0, NULL, psmovrec, valor.ccesta,
                                        (xidistrib / viuniact) * v_signo,   -- Mantis 12274.NMM.i.
                                                                         '2', TRUNC(f_sysdate));

                           -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
                           IF v_cmultimon = 1 THEN
                              num_err :=
                                 pac_oper_monedas.f_update_ctaseguro_monpol(xsseguro,
                                                                            NVL(pfmovdia,
                                                                                f_sysdate),
                                                                            xnnumlin,
                                                                            NVL(xfvalor,
                                                                                xfefecto));

                              IF num_err <> 0 THEN
                                 RETURN num_err;
                              END IF;
                           END IF;
                        -- FIN BUG 18423 - 15/12/2011 - JMP - Multimoneda
                        EXCEPTION
                           WHEN DUP_VAL_ON_INDEX THEN
                              RETURN(104879);   -- Registre duplicat a CTASEGURO
                           WHEN OTHERS THEN
                              RETURN(102555);   -- Error al insertar a la taula CTASEGURO
                        END;

                        -- Para la impresión de libreta (para que los movimientos generales también tenga actualizada
                        -- la fecha de asignación. Actualizamos el movimiento general anterior
                        UPDATE ctaseguro
                           SET cestado = '2',
                               fasign = TRUNC(f_sysdate)
                         WHERE sseguro = xsseguro
                           AND cmovimi = 51
                           AND ccalint = seqgrupo
                           AND nnumlin < xnnumlin;

                        IF v_tieneshw = 1 THEN
                           SELECT iuniactcmpshw
                             INTO viuniact
                             FROM tabvalces
                            WHERE ccesta = valor.ccesta
                              AND TRUNC(fvalor) =
                                    TRUNC(NVL(xfvalorshw, xfefecto))
                                    + pac_md_fondos.f_get_diasdep(valor.ccesta);

                           BEGIN
                              INSERT INTO ctaseguro_shadow
                                          (sseguro, fcontab, nnumlin,
                                           ffecmov, fvalmov,
                                           cmovimi, imovimi, imovim2, nrecibo,
                                           ccalint, cmovanu, nsinies, smovrec, cesta,
                                           nunidad, cestado,
                                           fasign)
                                   VALUES (xsseguro, NVL(pfmovdia, f_sysdate), xnnumlinshw,
                                           TRUNC(xfefecto), NVL(xfvalorshw, xfefecto),
                                           v_cmovimi_detalle, xidistrib, NULL, pnrecibo,
                                           seqgrupo, 0, NULL, psmovrec, valor.ccesta,
                                           (xidistrib / viuniact) * v_signo,   -- Mantis 12274.NMM.i.
                                                                            '2',
                                           TRUNC(f_sysdate));

                              -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
                              IF v_cmultimon = 1 THEN
                                 num_err :=
                                    pac_oper_monedas.f_update_ctaseguro_shw_monpol
                                                                             (xsseguro,
                                                                              NVL(pfmovdia,
                                                                                  f_sysdate),
                                                                              xnnumlinshw,
                                                                              NVL(xfvalorshw,
                                                                                  xfefecto));

                                 IF num_err <> 0 THEN
                                    RETURN num_err;
                                 END IF;
                              END IF;
                           -- FIN BUG 18423 - 15/12/2011 - JMP - Multimoneda
                           EXCEPTION
                              WHEN DUP_VAL_ON_INDEX THEN
                                 RETURN(104879);   -- Registre duplicat a CTASEGURO
                              WHEN OTHERS THEN
                                 RETURN(102555);   -- Error al insertar a la taula CTASEGURO
                           END;

                           -- Para la impresión de libreta (para que los movimientos generales también tenga actualizada
                           -- la fecha de asignación. Actualizamos el movimiento general anterior
                           UPDATE ctaseguro_shadow
                              SET cestado = '2',
                                  fasign = TRUNC(f_sysdate)
                            WHERE sseguro = xsseguro
                              AND cmovimi = 51
                              AND ccalint = seqgrupo
                              AND nnumlin < xnnumlinshw;

                           xnnumlinshw := xnnumlinshw + 1;
                        END IF;

                        -- incrementamos linea (por mov 58)
                        xnnumlin := xnnumlin + 1;

                        --ACTUALIZAR CESTA --> Descontamos las participaciones asignadas al fondo en contratos
                        UPDATE fondos
                           SET fondos.nparasi = NVL(fondos.nparasi, 0) +(xidistrib / viuniact)
                         WHERE fondos.ccodfon = valor.ccesta;
                     EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                           BEGIN
                              INSERT INTO ctaseguro
                                          (sseguro, fcontab, nnumlin,
                                           ffecmov, fvalmov,
                                           cmovimi, imovimi, imovim2, nrecibo,
                                           ccalint, cmovanu, nsinies, smovrec, cesta, cestado)
                                   VALUES (xsseguro, NVL(pfmovdia, f_sysdate), xnnumlin,
                                           TRUNC(xfefecto), NVL(xfvalor, xfefecto),
                                           v_cmovimi_detalle, xidistrib, NULL, pnrecibo,
                                           seqgrupo, 0, NULL, psmovrec, valor.ccesta, '1');

                              -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
                              IF v_cmultimon = 1 THEN
                                 num_err :=
                                    pac_oper_monedas.f_update_ctaseguro_monpol
                                                                              (xsseguro,
                                                                               NVL(pfmovdia,
                                                                                   f_sysdate),
                                                                               xnnumlin,
                                                                               NVL(xfvalor,
                                                                                   xfefecto));

                                 IF num_err <> 0 THEN
                                    RETURN num_err;
                                 END IF;
                              END IF;

                              IF v_tieneshw = 1 THEN
                                 INSERT INTO ctaseguro_shadow
                                             (sseguro, fcontab,
                                              nnumlin, ffecmov,
                                              fvalmov, cmovimi,
                                              imovimi, imovim2, nrecibo, ccalint, cmovanu,
                                              nsinies, smovrec, cesta, cestado)
                                      VALUES (xsseguro, NVL(pfmovdia, f_sysdate),
                                              xnnumlinshw, TRUNC(xfefecto),
                                              NVL(xfvalorshw, xfefecto), v_cmovimi_detalle,
                                              xidistrib, NULL, pnrecibo, seqgrupo, 0,
                                              NULL, psmovrec, valor.ccesta, '1');

                                 -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
                                 IF v_cmultimon = 1 THEN
                                    num_err :=
                                       pac_oper_monedas.f_update_ctaseguro_shw_monpol
                                                                             (xsseguro,
                                                                              NVL(pfmovdia,
                                                                                  f_sysdate),
                                                                              xnnumlinshw,
                                                                              NVL(xfvalorshw,
                                                                                  xfefecto));

                                    IF num_err <> 0 THEN
                                       RETURN num_err;
                                    END IF;
                                 END IF;

                                 xnnumlinshw := xnnumlinshw + 1;
                              END IF;

                              -- FIN BUG 18423 - 15/12/2011 - JMP - Multimoneda
                              xnnumlin := xnnumlin + 1;
                           EXCEPTION
                              WHEN DUP_VAL_ON_INDEX THEN
                                 RETURN(104879);   -- Registre duplicat a CTASEGURO
                              WHEN OTHERS THEN
                                 RETURN(102555);   -- Error al insertar a la taula CTASEGURO
                           END;
                     END;
                  -- Bug 15707 - APD - 14/03/2011 - el Traspaso de entrada (CMOVIMI = 8) se debe tratar como si fuera una aportación
                  ELSIF(xcmovimi = 1
                        OR xcmovimi = 2
                        OR xcmovimi = 4
                        OR xcmovimi = 8) THEN
                     BEGIN
                        -- Si disponemos del valor liquidativo pues ya lo ponemos, es decir
                        -- ya podemos calcular aqui el numero de participaciones que le tocan
                        SELECT NVL(iuniactcmp, iuniact)
                          INTO viuniact
                          FROM tabvalces
                         WHERE ccesta = valor.ccesta
                           AND TRUNC(fvalor) = TRUNC(NVL(xfvalor, xfefecto))
                                               + pac_md_fondos.f_get_diasdep(valor.ccesta);

                        BEGIN
                           INSERT INTO ctaseguro
                                       (sseguro, fcontab, nnumlin,
                                        ffecmov, fvalmov,
                                        cmovimi, imovimi, imovim2, nrecibo,
                                        ccalint, cmovanu, nsinies, smovrec, cesta,
                                        nunidad, cestado, fasign)
                                VALUES (xsseguro, NVL(pfmovdia, f_sysdate), xnnumlin,
                                        TRUNC(xfefecto), NVL(xfvalor, xfefecto),
                                        v_cmovimi_detalle, xidistrib, NULL, pnrecibo,
                                        seqgrupo, 0, NULL, psmovrec, valor.ccesta,
                                        (xidistrib / viuniact) * v_signo, '2', TRUNC(f_sysdate));

                           -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
                           IF v_cmultimon = 1 THEN
                              num_err :=
                                 pac_oper_monedas.f_update_ctaseguro_monpol(xsseguro,
                                                                            NVL(pfmovdia,
                                                                                f_sysdate),
                                                                            xnnumlin,
                                                                            NVL(xfvalor,
                                                                                xfefecto));

                              IF num_err <> 0 THEN
                                 RETURN num_err;
                              END IF;
                           END IF;
                        -- FIN BUG 18423 - 15/12/2011 - JMP - Multimoneda
                        EXCEPTION
                           WHEN DUP_VAL_ON_INDEX THEN
                              RETURN 104879;   -- Registre duplicat a CTASEGURO
                           WHEN OTHERS THEN
                              RETURN 102555;   -- Error al insertar a la taula CTASEGURO
                        END;

                        -- Para la impresión de libreta (para que los movimientos generales también tenga actualizada
                        -- la fecha de asignación. Actualizamos el movimiento general anterior
                        -- Bug 15707 - APD - 14/03/2011 - el Traspaso de entrada (CMOVIMI = 8) se debe tratar como si fuera una aportación
                        UPDATE ctaseguro
                           SET cestado = '2',
                               fasign = TRUNC(f_sysdate)
                         WHERE sseguro = xsseguro
                           AND cmovimi IN(1, 2, 4, 8)
                           AND ccalint = seqgrupo
                           AND nnumlin < xnnumlin;

                        IF v_tieneshw = 1 THEN
                           SELECT iuniactcmpshw
                             INTO viuniact
                             FROM tabvalces
                            WHERE ccesta = valor.ccesta
                              AND TRUNC(fvalor) =
                                    TRUNC(NVL(xfvalorshw, xfefecto))
                                    + pac_md_fondos.f_get_diasdep(valor.ccesta);

                           BEGIN
                              INSERT INTO ctaseguro_shadow
                                          (sseguro, fcontab, nnumlin,
                                           ffecmov, fvalmov,
                                           cmovimi, imovimi, imovim2, nrecibo,
                                           ccalint, cmovanu, nsinies, smovrec, cesta,
                                           nunidad, cestado,
                                           fasign)
                                   VALUES (xsseguro, NVL(pfmovdia, f_sysdate), xnnumlinshw,
                                           TRUNC(xfefecto), NVL(xfvalorshw, xfefecto),
                                           v_cmovimi_detalle, xidistrib, NULL, pnrecibo,
                                           seqgrupo, 0, NULL, psmovrec, valor.ccesta,
                                           (xidistrib / viuniact) * v_signo, '2',
                                           TRUNC(f_sysdate));

                              -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
                              IF v_cmultimon = 1 THEN
                                 num_err :=
                                    pac_oper_monedas.f_update_ctaseguro_shw_monpol
                                                                             (xsseguro,
                                                                              NVL(pfmovdia,
                                                                                  f_sysdate),
                                                                              xnnumlinshw,
                                                                              NVL(xfvalorshw,
                                                                                  xfefecto));

                                 IF num_err <> 0 THEN
                                    RETURN num_err;
                                 END IF;
                              END IF;
                           -- FIN BUG 18423 - 15/12/2011 - JMP - Multimoneda
                           EXCEPTION
                              WHEN DUP_VAL_ON_INDEX THEN
                                 RETURN 104879;   -- Registre duplicat a CTASEGURO
                              WHEN OTHERS THEN
                                 RETURN 102555;   -- Error al insertar a la taula CTASEGURO
                           END;

                           -- Para la impresión de libreta (para que los movimientos generales también tenga actualizada
                           -- la fecha de asignación. Actualizamos el movimiento general anterior
                           -- Bug 15707 - APD - 14/03/2011 - el Traspaso de entrada (CMOVIMI = 8) se debe tratar como si fuera una aportación
                           UPDATE ctaseguro_shadow
                              SET cestado = '2',
                                  fasign = TRUNC(f_sysdate)
                            WHERE sseguro = xsseguro
                              AND cmovimi IN(1, 2, 4, 8)
                              AND ccalint = seqgrupo
                              AND nnumlin < xnnumlinshw;

                           xnnumlinshw := xnnumlinshw + 1;
                        END IF;

                        -- Fin Bug 15707 - APD - 14/03/2011
                        -- incrementamos linea (por mov 45)
                        xnnumlin := xnnumlin + 1;

                        --ACTUALIZAR CESTA --> Aumentamos las participaciones asignadas al fondo en contratos
                        UPDATE fondos
                           SET fondos.nparasi = NVL(fondos.nparasi, 0) +(xidistrib / viuniact)
                         WHERE fondos.ccodfon = valor.ccesta;
                     EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                           BEGIN
                              INSERT INTO ctaseguro
                                          (sseguro, fcontab, nnumlin,
                                           ffecmov, fvalmov,
                                           cmovimi, imovimi, imovim2, nrecibo,
                                           ccalint, cmovanu, nsinies, smovrec, cesta, cestado)
                                   VALUES (xsseguro, NVL(pfmovdia, f_sysdate), xnnumlin,
                                           TRUNC(xfefecto), NVL(xfvalor, xfefecto),
                                           v_cmovimi_detalle, xidistrib, NULL, pnrecibo,
                                           seqgrupo, 0, NULL, psmovrec, valor.ccesta, '1');

                              -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
                              IF v_cmultimon = 1 THEN
                                 num_err :=
                                    pac_oper_monedas.f_update_ctaseguro_monpol
                                                                              (xsseguro,
                                                                               NVL(pfmovdia,
                                                                                   f_sysdate),
                                                                               xnnumlin,
                                                                               NVL(xfvalor,
                                                                                   xfefecto));

                                 IF num_err <> 0 THEN
                                    RETURN num_err;
                                 END IF;
                              END IF;

                              IF v_tieneshw = 1 THEN
                                 INSERT INTO ctaseguro_shadow
                                             (sseguro, fcontab,
                                              nnumlin, ffecmov,
                                              fvalmov, cmovimi,
                                              imovimi, imovim2, nrecibo, ccalint, cmovanu,
                                              nsinies, smovrec, cesta, cestado)
                                      VALUES (xsseguro, NVL(pfmovdia, f_sysdate),
                                              xnnumlinshw, TRUNC(xfefecto),
                                              NVL(xfvalorshw, xfefecto), v_cmovimi_detalle,
                                              xidistrib, NULL, pnrecibo, seqgrupo, 0,
                                              NULL, psmovrec, valor.ccesta, '1');

                                 -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
                                 IF v_cmultimon = 1 THEN
                                    num_err :=
                                       pac_oper_monedas.f_update_ctaseguro_shw_monpol
                                                                             (xsseguro,
                                                                              NVL(pfmovdia,
                                                                                  f_sysdate),
                                                                              xnnumlinshw,
                                                                              NVL(xfvalorshw,
                                                                                  xfefecto));

                                    IF num_err <> 0 THEN
                                       RETURN num_err;
                                    END IF;
                                 END IF;

                                 xnnumlinshw := xnnumlinshw + 1;
                              END IF;

                              -- FIN BUG 18423 - 15/12/2011 - JMP - Multimoneda
                              xnnumlin := xnnumlin + 1;
                           EXCEPTION
                              WHEN DUP_VAL_ON_INDEX THEN
                                 RETURN 104879;   -- Registre duplicat a CTASEGURO
                              WHEN OTHERS THEN
                                 RETURN 102555;   -- Error al insertar a la taula CTASEGURO
                           END;
                     END;
                  END IF;
               END LOOP;
            END IF;
         END IF;
--========================================================================================
-- fin Bug 0018767 - JMF - 09/06/2011
--========================================================================================
--========================================================================================
------------ //// ------------------------------------- ///// -----------
      ELSE
         --Bug.: 16701 - ICV - 23/11/2010
         IF NVL(f_parproductos_v(v_sproduc, 'DETRECIBO_CONCEPTOS'), 0) = 1 THEN
            BEGIN
               SELECT DISTINCT r.nrecibo
                          INTO v_nrecibo_aux
                          FROM detrecibos d, recibos r, seguros s
                         WHERE d.nrecibo = pnrecibo
                           AND d.nrecibo = r.nrecibo
                           AND r.sseguro = s.sseguro
                           AND d.cconcep IN(0, 1, 2, 3, 4, 5, 6, 7, 8, 14, 13)
                           AND NVL(f_pargaranpro_v(s.cramo, s.cmodali, s.ctipseg, s.ccolect,
                                                   s.cactivi, d.cgarant, 'TIPO'),
                                   0) IN(3, 4);
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  CLOSE cur_ctaseguro_general;

                  IF cur_ctaseguro_general_shw%ISOPEN THEN
                     CLOSE cur_ctaseguro_general_shw;
                  END IF;

                  RETURN 0;
            END;
         END IF;

         --Fin Bug.
         CLOSE cur_ctaseguro_general;

         RETURN 103071;   -- Rebut no trobat a la taula CTASEGURO
      END IF;

------------------------------------------------------------------------------
      IF cur_ctaseguro_general%ISOPEN THEN
         CLOSE cur_ctaseguro_general;
      END IF;

      IF cur_ctaseguro_general_shw%ISOPEN THEN
         CLOSE cur_ctaseguro_general_shw;
      END IF;
   END IF;

   RETURN 0;
-- BUG 21546_108724 - 08/02/2012 - JLTS - Cierre de posibles cursores abiertos, se adiciona EXCEPTION
EXCEPTION
   WHEN OTHERS THEN
      IF cur_ctaseguro_general%ISOPEN THEN
         CLOSE cur_ctaseguro_general;
      END IF;
END f_movcta_ulk;

/

  GRANT EXECUTE ON "AXIS"."F_MOVCTA_ULK" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_MOVCTA_ULK" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_MOVCTA_ULK" TO "PROGRAMADORESCSI";
